import Dependencies
import Foundation
import GRDB

/// **The janitor** (Phase 13j batch 6b — the memo's §4b: "a small periodic
/// pass, riding the existing sync scheduler"): the invisible half of
/// "really deleted". The 30-day clock HIDES (batch 6); this removes the
/// bytes — locally by physical row deletion, on the mirror through the
/// purge-execution RPC — and only when the HORIZON says every live device
/// on the account has already seen the deletion (else a stale peer's
/// re-push resurrects it; the ledger fences the stragglers).
///
/// It is idempotent, resumable, and never blocks anything the author is
/// doing: a family interrupted between its mirror purge and its local
/// removal is re-collected next pass (the mirror call is idempotent — the
/// ledger upsert conflicts silently); a family any of whose rows still owe
/// the server a push is SKIPPED this pass and re-collected when the drain
/// completes. **No horizon ⇒ no-op** — no server, no session, no recorded
/// device cursors all read as horizon 0, and nothing is ≤ 0.
///
/// The whole pass shares the engine's preflight discipline: the rekey
/// marker refuses first, keys refuse before any network contact, the §12
/// lockstep check refuses a schema-skewed mirror — outbox intact, cursor
/// unmoved, every time.
public struct PurgeJanitor: Sendable {
    @Dependency(\.database) var database
    @Dependency(\.date) var date

    /// The round transport (schema marker) and the purge surface — one
    /// object in production (`SupabaseTransport`) and in the fake.
    public let transport: any SyncTransport & SyncPurgeTransport
    public let keyProvider: any SyncKeyProviding

    /// At most this many TAKES are considered for savepoint pruning per
    /// pass (P1 politeness: the candidate query is corpus-history-shaped;
    /// the pass rides sync rounds, so the backlog drains across passes).
    public var pruningTakesPerPass: Int

    public init(
        transport: any SyncTransport & SyncPurgeTransport,
        keyProvider: any SyncKeyProviding,
        pruningTakesPerPass: Int = 64
    ) {
        self.transport = transport
        self.keyProvider = keyProvider
        self.pruningTakesPerPass = pruningTakesPerPass
    }

    // MARK: - Report

    public struct SweepReport: Equatable, Sendable {
        /// True when the pass stopped at "no horizon" — the designed safe
        /// no-op (no server-known device cursors yet, or none in-window).
        public var skippedNoHorizon = false
        /// Rows dropped locally by the ledger reconciliation scan (purges
        /// other devices executed that this store still held).
        public var ledgerRowsDropped = 0
        /// Families this pass purged (mirror + local).
        public var familiesPurged = 0
        /// Rows physically removed locally by those families.
        public var rowsPurgedLocally = 0
        /// Families collected but SKIPPED this pass (a member still owed a
        /// push, or its publication had not crossed the horizon).
        public var familiesDeferred = 0
        /// Savepoint purge intents minted by the pruning pass.
        public var pruneIntentsMinted = 0
        public init() {}
    }

    // MARK: - The sweep

    @discardableResult
    public func sweep() async throws -> SweepReport {
        // The engine's own preflight discipline, in the engine's order.
        let rekeyIncomplete = try await database.read { try AccountRekeyMarker.isSet($0) }
        guard !rekeyIncomplete else { throw SyncError.accountRekeyIncomplete }
        let keyID: String
        do {
            keyID = try keyProvider.currentKeys().corpusKeyID
        } catch {
            throw SyncError.encryptionKeysUnavailable
        }
        let server = try await transport.schemaVersion()
        guard server == SyncSchema.lockstepVersion else {
            throw SyncError.schemaLockstepMismatch(
                client: SyncSchema.lockstepVersion, server: server)
        }

        var report = SweepReport()
        let (cursor, scanPoint, acknowledgedFloor) = try await database.read { db in
            (try Self.stateValue(db, "last_server_seq"),
             try Self.stateValue(db, "last_purge_seq"),
             try Self.stateValue(db, "purge_floor_acknowledged"))
        }

        // 1. THE LEDGER SCAN (row-by-row reconciliation — the memo's §2):
        // entries above our scan point name rows OTHER devices purged that
        // this store may still hold. The FLOOR gate comes first: a scan
        // point below the floor means entries this device needs are gone —
        // the SAY-SO-FIRST returner road (round 10), unless the reload was
        // already acknowledged at this floor.
        let page = try await transport.purgeLedger(since: scanPoint, activeKeyID: keyID)
        if page.floor > scanPoint && page.floor > acknowledgedFloor {
            throw SyncError.deviceLeftBehindReloadRequired(
                floor: page.floor, scanPoint: scanPoint)
        }
        if !page.entries.isEmpty {
            let stamp = nowStamp()
            let maxSeq = page.entries.map(\.purgedSeq).max() ?? scanPoint
            let dropped: Int = try await database.write { db in
                try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
                let present = try page.entries.filter { entry in
                    try Self.rowExists(db, table: entry.table, rowID: entry.rowID)
                }
                var count = 0
                if !present.isEmpty {
                    let family = try PurgeFamily.expand(
                        db, roots: present.map { SyncPurgeTarget(table: $0.table, rowID: $0.rowID) })
                    count = family.rows.count
                    try PurgeFamily.deleteLocal(db, family: family, stamp: stamp)
                }
                try Self.setStateValue(db, "last_purge_seq", maxSeq)
                return count
            }
            report.ledgerRowsDropped = dropped
        }

        // 2. THE HORIZON. Capped at our own committed cursor — everything
        // ≤ the cursor was genuinely served to us (the A5 visibility filter
        // guarantees served ⇒ committed), which is the client-side form of
        // the memo's "minus the visibility-skew margin".
        let horizon = min(try await transport.syncHorizon(activeKeyID: keyID), cursor)
        guard horizon > 0 else {
            report.skippedNoHorizon = true
            return report
        }

        // 3. COLLECTION: intent roots (live intents published before the
        // horizon) + 30-day tombstone roots (published before the horizon,
        // cascade victims riding their root, nothing still owed a push).
        let roots = try await database.read { db in
            try self.collectRoots(db, horizon: horizon)
        }

        // 4. One family at a time: expand + verify → mirror purge → local
        // removal (ONE local transaction per family) → advance the scan
        // point past our own ledger entries (self-echo skip).
        for root in roots {
            let expansion: PurgeFamily.Expansion? = try await database.read { db in
                let family = try PurgeFamily.expand(db, roots: [root])
                return try self.familyIsEligible(db, family, horizon: horizon) ? family : nil
            }
            guard let expansion else {
                report.familiesDeferred += 1
                continue
            }
            let grantedSeq = try await transport.executePurge(
                expansion.orderedRows, activeKeyID: keyID)
            let stamp = nowStamp()
            let removed: Int = try await database.write { db in
                try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
                // Re-expand inside the removal's own transaction (the
                // projection lesson): the mirror has already purged, so
                // whatever the family holds NOW goes — a restore that
                // raced the await loses to the purge (the ruled
                // purge-wins doctrine; its push would be 'purged'-refused).
                let family = try PurgeFamily.expand(db, roots: [root])
                try PurgeFamily.deleteLocal(db, family: family, stamp: stamp)
                let scan = try Self.stateValue(db, "last_purge_seq")
                if grantedSeq > scan {
                    try Self.setStateValue(db, "last_purge_seq", grantedSeq)
                }
                return family.rows.count
            }
            report.familiesPurged += 1
            report.rowsPurgedLocally += removed
        }

        // 5. SAVEPOINT PRUNING (memo §4d): mint intents for prunable quiet
        // savepoints — Standard mode only; the setting is consulted before
        // ANY mint, and deliberate ⌘S commits never qualify (the brain
        // considers only kind='auto'; the op refuses manual rows outright).
        // The intents purge on a LATER pass, once published past the
        // horizon like every other root.
        let pruning = try await database.read { try Queries.historyPruning($0) }
        if pruning == .standard {
            let prunable = try await database.read { db in
                try self.prunableSavepoints(db)
            }
            if !prunable.isEmpty {
                let minted = try Operations().requestPurge(
                    prunable.map { SyncPurgeTarget(table: "commit_point", rowID: $0) })
                report.pruneIntentsMinted = minted
            }
        }
        return report
    }

    // MARK: - Collection

    private func collectRoots(_ db: Database, horizon: Int64) throws -> [SyncPurgeTarget] {
        var roots: [SyncPurgeTarget] = []
        let cutoff = TrashWindow.cutoffStamp(now: date.now)

        // Live intents whose own publication crossed the horizon.
        for row in try Row.fetchAll(
            db,
            sql: """
                SELECT pi.id AS intent_id, pi.table_name AS t, pi.row_id AS r
                FROM purge_intent pi
                JOIN sync_row_seq s ON s.table_name = 'purge_intent' AND s.row_id = pi.id
                WHERE pi.deleted_at IS NULL
                  AND s.server_seq > 0 AND s.server_seq <= :horizon
                  AND NOT EXISTS (
                    SELECT 1 FROM sync_outbox o
                    WHERE o.table_name = 'purge_intent' AND o.row_id = pi.id)
                ORDER BY pi.id
                """,
            arguments: ["horizon": horizon]) {
            roots.append(SyncPurgeTarget(table: row["t"], rowID: row["r"]))
        }

        // 30-day tombstone roots (the ordinary path — no intent needed).
        // Publication and pending-push checks ride the family verification;
        // here only the ROOT shape is selected: containers and readings
        // outright; blocks that are NOT a same-stamp cascade victim of a
        // same-stamp container (those ride the container root); takes whose
        // block is live (dead-block takes ride the block root).
        func tombstoneRoots(_ sql: String) throws -> [String] {
            try String.fetchAll(db, sql: sql, arguments: ["cutoff": cutoff])
        }
        for id in try tombstoneRoots("""
            SELECT id FROM container
            WHERE deleted_at IS NOT NULL AND deleted_at <= :cutoff ORDER BY id
            """) {
            roots.append(SyncPurgeTarget(table: "container", rowID: id))
        }
        for id in try tombstoneRoots("""
            SELECT id FROM reading
            WHERE deleted_at IS NOT NULL AND deleted_at <= :cutoff ORDER BY id
            """) {
            roots.append(SyncPurgeTarget(table: "reading", rowID: id))
        }
        for id in try tombstoneRoots("""
            SELECT b.id FROM block b
            WHERE b.deleted_at IS NOT NULL AND b.deleted_at <= :cutoff
              AND NOT EXISTS (
                SELECT 1 FROM container_block cb
                JOIN container cc ON cc.id = cb.container_id
                WHERE cb.block_id = b.id
                  AND cb.deleted_at = b.deleted_at
                  AND cc.deleted_at = b.deleted_at)
            ORDER BY b.id
            """) {
            roots.append(SyncPurgeTarget(table: "block", rowID: id))
        }
        for id in try tombstoneRoots("""
            SELECT v.id FROM variant v
            JOIN block b ON b.id = v.block_id AND b.deleted_at IS NULL
            WHERE v.deleted_at IS NOT NULL AND v.deleted_at <= :cutoff
            ORDER BY v.id
            """) {
            roots.append(SyncPurgeTarget(table: "variant", rowID: id))
        }
        return roots
    }

    /// Every family row must be PUBLISHED BEFORE THE HORIZON (its latest
    /// server-accepted state — which includes its tombstone — has been seen
    /// by every live device) and OWE THE SERVER NOTHING (a pending outbox
    /// entry means the local state diverges from the accepted one; purging
    /// under it would strand the mirror's live copy). Any failure defers
    /// the WHOLE family to a later pass — resumable, never partial.
    private func familyIsEligible(
        _ db: Database, _ family: PurgeFamily.Expansion, horizon: Int64
    ) throws -> Bool {
        for target in family.rows {
            let pending = try Bool.fetchOne(
                db,
                sql: "SELECT EXISTS (SELECT 1 FROM sync_outbox WHERE table_name = ? AND row_id = ?)",
                arguments: [target.table, target.rowID]) ?? false
            if pending { return false }
            guard try Self.rowExists(db, table: target.table, rowID: target.rowID) else {
                continue  // already gone locally — nothing to publish
            }
            let seq = try Int64.fetchOne(
                db,
                sql: "SELECT server_seq FROM sync_row_seq WHERE table_name = ? AND row_id = ?",
                arguments: [target.table, target.rowID]) ?? 0
            guard seq > 0, seq <= horizon else { return false }
        }
        return true
    }

    // MARK: - Pruning candidates

    /// Prunable quiet-savepoint ids across at most `pruningTakesPerPass`
    /// LIVE takes (a dead take's savepoints ride its purge), skipping rows
    /// already named by a standing intent. The per-take rule is
    /// `SavepointPruning.prunable` — one brain, consulted per take.
    private func prunableSavepoints(_ db: Database) throws -> [String] {
        let candidates = try String.fetchAll(
            db,
            sql: """
                SELECT v.id FROM variant v
                JOIN commit_point cp ON cp.variant_id = v.id AND cp.kind = 'auto'
                WHERE v.deleted_at IS NULL
                GROUP BY v.id
                HAVING COUNT(*) > :keep
                ORDER BY v.id
                LIMIT :takes
                """,
            arguments: [
                "keep": SavepointPruning.keepNewestQuiet,
                "takes": pruningTakesPerPass,
            ])
        var prunable: [String] = []
        for variantID in candidates {
            let rows = try Row.fetchAll(
                db,
                sql: """
                    SELECT cp.id AS id, cp.kind AS kind, cp.created_at AS created_at
                    FROM commit_point cp
                    WHERE cp.variant_id = ?
                      AND NOT EXISTS (
                        SELECT 1 FROM purge_intent pi
                        WHERE pi.table_name = 'commit_point' AND pi.row_id = cp.id)
                    """,
                arguments: [variantID])
            let savepoints = rows.compactMap { row -> SavepointPruning.Savepoint? in
                guard let created = DateFormatter.variorumISO8601.date(
                    from: row["created_at"] ?? "") else { return nil }
                return SavepointPruning.Savepoint(
                    id: row["id"], kind: row["kind"], createdAt: created)
            }
            prunable.append(contentsOf: SavepointPruning.prunable(
                among: savepoints, now: date.now))
        }
        return prunable
    }

    // MARK: - The returner road (round 10 — SAY SO FIRST)

    /// **The reload a left-behind device runs after the say-so** (her
    /// round-10 ruling, the memo's §2 returner): a device whose ledger
    /// scan point sits below the coverage floor cannot be reconciled
    /// row-by-row — the sweep refuses with
    /// `deviceLeftBehindReloadRequired` (the say-so; its wording is her
    /// round-10 class), and THIS is the road it names, run only on the
    /// user's go:
    ///
    ///  1. **unsynced writes pushed FIRST** ("anything written here first
    ///     gets saved up; nothing typed is lost") — the ordinary drain;
    ///     purged ids among them are ledger-refused and dropped, family
    ///     and all;
    ///  2. **the existing `resyncReinitialize`** — every local row
    ///     re-enqueues at base 0 and the cursor rewinds, so the next
    ///     rounds re-read the account from the beginning and re-offer
    ///     everything local (server-newer rows CAS-reject and merge;
    ///     ledger-fenced rows drop);
    ///  3. the floor is ACKNOWLEDGED (`purge_floor_acknowledged`) so the
    ///     sweep's gate opens again, and the ledger scan point resumes AT
    ///     the floor — coverage below it is gone by definition.
    ///
    /// The caller triggers ordinary rounds afterwards; the road itself
    /// composes existing machinery and invents no second sync mechanism.
    /// (Unreachable in production until ledger pruning advances the floor;
    /// proven against the fake server's settable floor. The future
    /// pruning rider owes the Mac face — P-2 renders no door for a state
    /// that cannot occur, recorded in the batch record.)
    public func reonboardFromAccount(using engine: SyncEngine) async throws {
        let keyID: String
        do {
            keyID = try keyProvider.currentKeys().corpusKeyID
        } catch {
            throw SyncError.encryptionKeysUnavailable
        }
        _ = try await engine.push()
        try await engine.resyncReinitialize()
        let page = try await transport.purgeLedger(since: 0, activeKeyID: keyID)
        try await database.write { db in
            try Self.setStateValue(db, "purge_floor_acknowledged", page.floor)
            let scan = try Self.stateValue(db, "last_purge_seq")
            if page.floor > scan {
                try Self.setStateValue(db, "last_purge_seq", page.floor)
            }
        }
    }

    // MARK: - Local state helpers

    private static func stateValue(_ db: Database, _ key: String) throws -> Int64 {
        try String.fetchOne(
            db, sql: "SELECT value FROM sync_state WHERE key = ?", arguments: [key])
            .flatMap(Int64.init) ?? 0
    }

    private static func setStateValue(_ db: Database, _ key: String, _ value: Int64) throws {
        try db.execute(
            sql: "INSERT OR REPLACE INTO sync_state (key, value) VALUES (?, ?)",
            arguments: [key, String(value)])
    }

    static func rowExists(_ db: Database, table: String, rowID: String) throws -> Bool {
        guard let registered = SyncSchema.table(named: table) else { return false }
        return try Bool.fetchOne(
            db,
            sql: "SELECT EXISTS (SELECT 1 FROM \(registered.name) WHERE \(registered.primaryKey) = ?)",
            arguments: [rowID]) ?? false
    }

    private func nowStamp() -> String {
        DateFormatter.variorumISO8601.string(from: date.now)
    }
}
