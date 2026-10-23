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
/// The whole pass shares the engine's preflight discipline: keys refuse
/// before any network contact, the §12 lockstep check refuses a
/// schema-skewed mirror — outbox intact, cursor unmoved, every time.
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
        /// True when no SYNCED family could be considered — no server-known
        /// device cursors yet, or none in-window. (13j ladder B, B3: the
        /// pass no longer stops here — LOCAL-ONLY families, which need no
        /// horizon because no peer ever saw them, still purge below.)
        public var skippedNoHorizon = false
        /// Rows dropped locally by the ledger reconciliation scan (purges
        /// other devices executed that this store still held).
        public var ledgerRowsDropped = 0
        /// Families this pass purged (mirror + local, or local-only).
        public var familiesPurged = 0
        /// Rows physically removed locally by those families.
        public var rowsPurgedLocally = 0
        /// Families collected but SKIPPED this pass (a member still owed a
        /// push, or its publication had not crossed the horizon).
        public var familiesDeferred = 0
        /// Stale intents completed WITHOUT a purge (13j ladder B, B1): a
        /// live intent whose target row is LIVE again — restored since the
        /// confirm — is voided, never honored.
        public var staleIntentsCompleted = 0
        /// Savepoint purge intents minted by the pruning pass.
        public var pruneIntentsMinted = 0
        public init() {}
    }

    // MARK: - The preflight (one body, three doors — LADDER R1 F-R7)

    /// The janitor's preflight — the engine's refusal discipline in the
    /// engine's order (keys before any network contact, the §12 lockstep
    /// check), shared by `sweep()`,
    /// `reconcileLedger()` and `healPurgeOrphan` (which carried it
    /// verbatim ×3 until this hoist; the R2-M2 rationale at
    /// `reconcileLedger` explains why the pre-pass must never run naked).
    /// Returns the round's key id + its challenge signer on success (13y
    /// UNIT B: the proof is per-request — one signer per janitor pass,
    /// one nonce per RPC call); refuses by throw — outbox intact, cursor
    /// unmoved, every time.
    private func preflight() async throws -> (keyID: String, signer: SyncChallengeSigner) {
        let keyID: String
        let material: KeyProofMaterial
        do {
            let keys = try keyProvider.currentKeys()
            keyID = keys.corpusKeyID
            material = keys.keyProof
        } catch {
            throw SyncError.encryptionKeysUnavailable
        }
        let server = try await transport.schemaVersion()
        guard server == SyncSchema.lockstepVersion else {
            throw SyncError.schemaLockstepMismatch(
                client: SyncSchema.lockstepVersion, server: server)
        }
        return (keyID, SyncChallengeSigner(
            transport: transport, material: material, activeKeyID: keyID))
    }

    // MARK: - The sweep

    @discardableResult
    public func sweep() async throws -> SweepReport {
        // The engine's own preflight discipline, in the engine's order.
        let (keyID, signer) = try await preflight()

        var report = SweepReport()

        // 1. THE LEDGER SCAN (row-by-row reconciliation — the memo's §2).
        // Extracted as `reconcileLedger` (13j ladder B, B2): the scheduler
        // ALSO runs it BEFORE each round, so a returner's outbox is screened
        // against other devices' purges before anything is pushed — the
        // never-pushed-child orphan road closes without reordering the
        // round. Running it again here is cheap (since-scanPoint is empty
        // the second time) and keeps standalone `sweep()` callers whole.
        report.ledgerRowsDropped = try await reconcileLedger()

        // 2. THE HORIZON. Capped at our own committed cursor — everything
        // ≤ the cursor was genuinely served to us (the A5 visibility filter
        // guarantees served ⇒ committed), which is the client-side form of
        // the memo's "minus the visibility-skew margin". No horizon no
        // longer ends the pass (B3): LOCAL-ONLY families — every row
        // `sync_row_seq`-absent, so no peer ever saw them and there is no
        // one to strand — purge below with no mirror contact at all.
        let cursor = try await database.read { try Self.stateValue($0, "last_server_seq") }
        let horizon = min(
            try await signer.call(rpc: "sync_horizon") { proof in
                try await self.transport.syncHorizon(activeKeyID: keyID, keyProof: proof)
            }, cursor)
        if horizon <= 0 { report.skippedNoHorizon = true }

        // 3. COLLECTION: intent roots (live intents published before the
        // horizon, or never-synced ones — the local road needs no
        // publication) + 30-day tombstone roots.
        let now = date.now
        let roots = try await database.read { db in
            try Self.collectRoots(db, horizon: horizon, now: now)
        }

        // 4. One family at a time: expand + verdict → mirror purge (synced
        // families only) → local removal (ONE local transaction per family)
        // → advance the scan point past our own ledger entries (self-echo
        // skip). NOTE (B9): the scan point is a SELF-ECHO device, not a
        // completeness guarantee — a concurrent peer sweep's lower-seq
        // entries may be skipped by this advance; those families re-collect
        // through the 30-day road and converge there.
        var processed: Set<SyncPurgeTarget> = []
        for (root, localOnlyIntent) in roots {
            // B9: a root already taken by an earlier family this pass
            // (an intent on a 31-day tombstone is collected by BOTH arms)
            // is done — never a second executePurge, never double-counted.
            if processed.contains(root) { continue }
            let staged: (PurgeFamily.Expansion, Self.FamilyVerdict) = try await database.read { db in
                let family = try PurgeFamily.expand(db, roots: [root])
                return (family, try Self.familyVerdict(
                    db, family, horizon: horizon, road: .transported))
            }
            let expansion = staged.0
            var verdict = staged.1
            // An UNPUBLISHED intent (the local road's collection arm) may
            // only ever drive a LOCAL-ONLY purge: a synced family waits for
            // its intent to publish first, so a peer that pulls the intent
            // still learns "this is going" before it goes (memo §4a).
            if localOnlyIntent, verdict == .eligibleSynced { verdict = .deferred }
            switch verdict {
            case .stale:
                // 13j ladder B, B1: the intent's target (or a family row)
                // is LIVE again — restored since the confirm. A stale
                // intent is COMPLETED, never honored: void it so a later
                // re-delete can never be claimed by a leftover intent.
                report.staleIntentsCompleted += try await completeStaleIntents(root)
            case .deferred:
                report.familiesDeferred += 1
            case .eligibleLocalOnly:
                // B3 (her round-11 ruling): every row of this family is
                // `sync_row_seq`-absent — the mirror never saw any of it,
                // so there is nothing to strand, nothing to fence, and no
                // ledger entry to write. Local physical removal only.
                // R2-M3: nil = the family stopped reading `.eligibleLocalOnly`
                // between the staged read and the removal's own transaction
                // (a restore raced the gap) — deferred, re-collected next pass.
                if let removed = try await deleteFamilyLocally(root, road: .transported) {
                    report.familiesPurged += 1
                    report.rowsPurgedLocally += removed
                    processed.formUnion(expansion.rows)
                } else {
                    report.familiesDeferred += 1
                }
            case .eligibleSynced:
                let purgeRows = expansion.orderedRows
                let grantedSeq = try await signer.call(rpc: "sync_purge_execute") { proof in
                    try await self.transport.executePurge(
                        purgeRows, activeKeyID: keyID, keyProof: proof)
                }
                let removed: Int = try await database.write { db in
                    try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
                    // Re-expand inside the removal's own transaction (the
                    // projection lesson): the mirror has already purged, so
                    // whatever the family holds NOW goes — a restore that
                    // raced the await loses to the purge (the ruled
                    // purge-wins doctrine; its push would be
                    // 'purged'-refused).
                    let family = try PurgeFamily.expand(db, roots: [root])
                    try PurgeFamily.deleteLocal(db, family: family, stamp: self.nowStamp())
                    let scan = try Self.ledgerScanPoint(db)
                    if grantedSeq > scan {
                        try Self.setStateValue(db, Self.ledgerScanPointKey, grantedSeq)
                    }
                    return family.rows.count
                }
                report.familiesPurged += 1
                report.rowsPurgedLocally += removed
                processed.formUnion(expansion.rows)
            }
        }

        // 5. SAVEPOINT PRUNING (memo §4d): mint intents for prunable quiet
        // savepoints — Standard mode only; the setting is consulted before
        // ANY mint, and deliberate ⌘S commits never qualify (the brain
        // considers only kind='auto'; the op refuses manual rows outright).
        // The intents purge on a LATER pass, once published past the
        // horizon like every other root.
        let pruning = try await database.read { try Queries.historyPruning($0) }
        if pruning == .standard {
            let takes = pruningTakesPerPass
            let prunable = try await database.read { db in
                try Self.prunableSavepoints(db, takesPerPass: takes, now: now)
            }
            if !prunable.isEmpty {
                let minted = try Operations().requestPurge(
                    prunable.map { SyncPurgeTarget(table: "commit_point", rowID: $0) })
                report.pruneIntentsMinted = minted
            }
        }
        return report
    }

    // MARK: - The ledger reconciliation (extracted 13j ladder B, B2)

    /// The row-by-row reconciliation scan (the memo's §2): entries above our
    /// scan point name rows OTHER devices purged that this store may still
    /// hold — drop them family-complete and advance the scan point. The
    /// FLOOR gate comes first: a scan point below the floor means entries
    /// this device needs are gone — the SAY-SO-FIRST returner road (round
    /// 10), unless the reload was already acknowledged at this floor.
    ///
    /// **Callable BEFORE a round's drain** (B2): `SyncScheduler` runs it
    /// ahead of each round so a returner's outbox is screened against
    /// other devices' purges before anything pushes — `deleteLocal` sweeps
    /// the family's outbox entries, so a never-pushed CHILD of a purged
    /// family (the one row no ledger could ever name, because the server
    /// never saw its id) dies here instead of landing as a permanent
    /// mirror orphan under a missing parent. The consequence is the
    /// purge-wins doctrine's letter, named out loud: a returner's unpushed
    /// writing UNDER a purged family is discarded with the family.
    @discardableResult
    public func reconcileLedger() async throws -> Int {
        // R2-M2 (13j ladder B round 2): the pre-pass carries the SAME
        // preflight discipline as `sweep()` — the scheduler calls this
        // BEFORE each round, so without its own gates the ledger would be
        // consumed (rows dropped, `last_purge_seq` advanced) against a
        // mirror this client has refused to talk to: a mid-re-key store,
        // or a schema-skewed mirror whose seq semantics a future §12
        // event may have changed (the recorded per-tenant-sequence event
        // renumbers exactly what the floor and scan point compare).
        // Disagreement means refusal, never improvisation (SyncSpec §12)
        // — scan point unmoved, nothing dropped. When `sweep()` calls
        // this the checks re-run (one cheap RPC, twice per sweep); the
        // standalone scheduler entry is the one that must never be naked.
        let (keyID, signer) = try await preflight()
        let (scanPoint, acknowledgedFloor) = try await database.read { db in
            (try Self.ledgerScanPoint(db),
             try Self.stateValue(db, "purge_floor_acknowledged"))
        }
        let page = try await signer.call(rpc: "sync_purge_ledger") { proof in
            try await self.transport.purgeLedger(since: scanPoint, activeKeyID: keyID, keyProof: proof)
        }
        if page.floor > scanPoint && page.floor > acknowledgedFloor {
            throw SyncError.deviceLeftBehindReloadRequired(
                floor: page.floor, scanPoint: scanPoint)
        }
        guard !page.entries.isEmpty else { return 0 }
        let stamp = nowStamp()
        let maxSeq = page.entries.map(\.purgedSeq).max() ?? scanPoint
        return try await database.write { db in
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
            try Self.setStateValue(db, Self.ledgerScanPointKey, maxSeq)
            return count
        }
    }

    // MARK: - Collection

    /// The sweep's candidate roots. Three arms:
    ///  - live intents whose own publication crossed the horizon (the
    ///    synced intent road — a peer that pulls the intent learns "this
    ///    is going" BEFORE it goes);
    ///  - live intents the server has NEVER accepted (`sync_row_seq`
    ///    absent — 13j ladder B, B3: the local road's door; the family
    ///    verdict below purges these ONLY when the whole family is
    ///    local-only, so a synced family still waits for its published
    ///    intent);
    ///  - 30-day tombstone roots (the ordinary path — no intent needed):
    ///    containers and readings outright; blocks that are NOT a
    ///    same-stamp cascade victim of a same-stamp container (those ride
    ///    the container root); takes whose block is live (dead-block takes
    ///    ride the block root). `< :cutoff` (B8): the boundary stamp
    ///    belongs to the thing being recovered — every listing keeps it
    ///    with `>=`, so collection takes strictly older only.
    static func collectRoots(
        _ db: Database, horizon: Int64, now: Date
    ) throws -> [(root: SyncPurgeTarget, localOnlyIntent: Bool)] {
        var roots: [(SyncPurgeTarget, Bool)] = []
        let cutoff = TrashWindow.cutoffStamp(now: now)

        for row in try Row.fetchAll(
            db,
            sql: """
                SELECT pi.table_name AS t, pi.row_id AS r,
                       (s.server_seq IS NOT NULL) AS synced
                FROM purge_intent pi
                LEFT JOIN sync_row_seq s
                  ON s.table_name = 'purge_intent' AND s.row_id = pi.id
                 AND s.server_seq > 0
                WHERE pi.deleted_at IS NULL
                  AND (
                    (s.server_seq IS NOT NULL AND s.server_seq <= :horizon
                     AND NOT EXISTS (
                       SELECT 1 FROM sync_outbox o
                       WHERE o.table_name = 'purge_intent' AND o.row_id = pi.id))
                    OR s.server_seq IS NULL)
                ORDER BY pi.id
                """,
            arguments: ["horizon": horizon]) {
            roots.append((
                SyncPurgeTarget(table: row["t"], rowID: row["r"]),
                (row["synced"] as Int64? ?? 0) == 0))
        }

        func tombstoneRoots(_ sql: String) throws -> [String] {
            try String.fetchAll(db, sql: sql, arguments: ["cutoff": cutoff])
        }
        for id in try tombstoneRoots("""
            SELECT id FROM container
            WHERE deleted_at IS NOT NULL AND deleted_at < :cutoff ORDER BY id
            """) {
            roots.append((SyncPurgeTarget(table: "container", rowID: id), false))
        }
        for id in try tombstoneRoots("""
            SELECT id FROM reading
            WHERE deleted_at IS NOT NULL AND deleted_at < :cutoff ORDER BY id
            """) {
            roots.append((SyncPurgeTarget(table: "reading", rowID: id), false))
        }
        for id in try tombstoneRoots("""
            SELECT b.id FROM block b
            WHERE b.deleted_at IS NOT NULL AND b.deleted_at < :cutoff
              AND NOT EXISTS (
                SELECT 1 FROM container_block cb
                JOIN container cc ON cc.id = cb.container_id
                WHERE cb.block_id = b.id
                  AND cb.deleted_at = b.deleted_at
                  AND cc.deleted_at = b.deleted_at)
            ORDER BY b.id
            """) {
            roots.append((SyncPurgeTarget(table: "block", rowID: id), false))
        }
        for id in try tombstoneRoots("""
            SELECT v.id FROM variant v
            JOIN block b ON b.id = v.block_id AND b.deleted_at IS NULL
            WHERE v.deleted_at IS NOT NULL AND v.deleted_at < :cutoff
            ORDER BY v.id
            """) {
            roots.append((SyncPurgeTarget(table: "variant", rowID: id), false))
        }
        return roots
    }

    // MARK: - The family verdict

    enum FamilyVerdict: Equatable {
        /// Every row published ≤ horizon, nothing owed a push: mirror
        /// purge + local removal.
        case eligibleSynced
        /// Every row `sync_row_seq`-absent (13j ladder B, B3 — her round-11
        /// ruling): the mirror never saw any of it, so local removal only —
        /// no `executePurge`, no ledger entry, and the outbox does NOT
        /// disqualify (a never-configured install's rows sit there forever
        /// by construction; `deleteLocal` sweeps them with the family).
        case eligibleLocalOnly
        /// Not yet: a member still owes a push or hasn't crossed the
        /// horizon. Re-collected next pass — resumable, never partial.
        case deferred
        /// 13j ladder B, B1: a family row of a tombstoned kind is LIVE
        /// again — restored since the intent's confirm (⌥⌘Z, or a peer's
        /// Put back before the intent arrived). The family must NOT purge,
        /// and the standing intent is stale: complete it without honoring
        /// it. (Stranded originals and their own live sub-rows are exempt —
        /// they are live BY DESIGN and ride the family per round 8b;
        /// `commit_point` has no tombstone and is never checked — a naive
        /// liveness read there would void every pruning intent forever.)
        case stale
    }

    /// Which sweep is asking (13j ladder B round-1 residuals, Obs 1): the
    /// TRANSPORTED road treats a seq-absent-but-outbox-pending family as
    /// `.deferred` — `sync_row_seq` absence is not proof of mirror absence
    /// on a configured chain (`resyncReinitialize` clears the seq table
    /// wholesale while the mirror still holds every row; a sweep in that
    /// window would otherwise local-purge synced families into a transient
    /// resurrection). Cost: ONE round of latency for a family minted and
    /// deleted before it ever pushed — it drains, becomes synced, and
    /// purges through the ledgered road, which is the truer story for rows
    /// the mirror did see. The LOCAL road stays outbox-blind (her round-11
    /// letter: the never-configured install's rows sit in the outbox
    /// forever by construction, and no chain exists to have cleared seqs).
    enum SweepRoad: Equatable {
        case transported
        case localOnly
    }

    /// One consistent read-transaction verdict for a family (the fix
    /// placement the 6b response asked for): staleness first, then the
    /// local/synced split, then synced eligibility. `rowExists → skip`
    /// keeps its meaning — ABSENT is already-purged, proceed.
    static func familyVerdict(
        _ db: Database, _ family: PurgeFamily.Expansion, horizon: Int64,
        road: SweepRoad
    ) throws -> FamilyVerdict {
        let tombstonedKinds: Set<String> = [
            "container", "reading", "block", "variant",
            // VX-179 (2026-10-12): the comment true-delete door made
            // block_comment a purgeable root, so a restored comment must
            // read .stale here like its four elders — without this a
            // comment put back between intent and sweep is purged LIVE.
            "block_comment",
        ]
        var anySynced = false
        var allSyncedEligible = true
        var anyPendingSeqAbsent = false
        for target in family.rows {
            let seq = try Int64.fetchOne(
                db,
                sql: "SELECT server_seq FROM sync_row_seq WHERE table_name = ? AND row_id = ?",
                arguments: [target.table, target.rowID]) ?? 0
            if seq > 0 { anySynced = true }
            guard try rowExists(db, table: target.table, rowID: target.rowID) else {
                continue  // already gone locally — nothing to publish
            }
            if tombstonedKinds.contains(target.table),
               try rowIsLive(db, target),
               !(try isStrandedOriginSubtreeRow(db, target, family: family)) {
                return .stale
            }
            let pending = try Bool.fetchOne(
                db,
                sql: "SELECT EXISTS (SELECT 1 FROM sync_outbox WHERE table_name = ? AND row_id = ?)",
                arguments: [target.table, target.rowID]) ?? false
            if pending, seq <= 0 { anyPendingSeqAbsent = true }
            if pending || seq <= 0 || seq > horizon { allSyncedEligible = false }
        }
        if !anySynced {
            if road == .transported, anyPendingSeqAbsent { return .deferred }
            return .eligibleLocalOnly
        }
        return allSyncedEligible ? .eligibleSynced : .deferred
    }

    private static func rowIsLive(_ db: Database, _ target: SyncPurgeTarget) throws -> Bool {
        try Bool.fetchOne(
            db,
            sql: "SELECT deleted_at IS NULL FROM \(target.table) WHERE id = ?",
            arguments: [target.rowID]) ?? false
    }

    /// The round-8b exemption: a stranded origin joined the family LIVE by
    /// design, and `expandBlock` brought its own live variants with it.
    private static func isStrandedOriginSubtreeRow(
        _ db: Database, _ target: SyncPurgeTarget, family: PurgeFamily.Expansion
    ) throws -> Bool {
        guard !family.strandedOriginals.isEmpty else { return false }
        switch target.table {
        case "block":
            return family.strandedOriginals.contains(target.rowID)
        case "variant":
            let blockID = try String.fetchOne(
                db, sql: "SELECT block_id FROM variant WHERE id = ?",
                arguments: [target.rowID])
            return blockID.map(family.strandedOriginals.contains) ?? false
        default:
            return false
        }
    }

    // MARK: - The receipts' truth bit (R2-M1, 13j ladder B round 2)

    /// Whether ANY row of these targets' families has ever been accepted
    /// by the server (`sync_row_seq` present). The purge doors' receipts
    /// read this when NO chain is configured: a SIGNED-OUT store may
    /// still hold once-synced families, and for those `LocalPurge` defers
    /// forever (one synced member ⇒ the whole family waits) while no
    /// janitor exists — so a receipt claiming "the app's own cleanup
    /// removes the bytes" would be indefinitely false for exactly the
    /// rows it names. True ⇒ the bytes wait for a sign-in (the janitor's
    /// road); false ⇒ the local road really does take them. Family-wide,
    /// not root-only: a partial drain can sync a child under a
    /// never-accepted root, and one synced member is all the verdict
    /// needs to wait.
    public static func anyFamilyEverSynced(
        _ db: Database, targets: [SyncPurgeTarget]
    ) throws -> Bool {
        guard !targets.isEmpty else { return false }
        let family = try PurgeFamily.expand(db, roots: targets)
        for target in family.rows {
            let seq = try Int64.fetchOne(
                db,
                sql: "SELECT server_seq FROM sync_row_seq WHERE table_name = ? AND row_id = ?",
                arguments: [target.table, target.rowID]) ?? 0
            if seq > 0 { return true }
        }
        return false
    }

    // MARK: - Stale-intent completion + the local family removal

    /// Voids every live intent naming this root (13j ladder B, B1): the
    /// tombstone travels like any completion, so peers stop fencing too.
    /// Ordinary write — the outbox trigger captures it.
    private func completeStaleIntents(_ root: SyncPurgeTarget) async throws -> Int {
        let stamp = nowStamp()
        return try await database.write { db in
            let stale = try String.fetchAll(
                db,
                sql: """
                    SELECT id FROM purge_intent
                    WHERE table_name = ? AND row_id = ? AND deleted_at IS NULL
                    """,
                arguments: [root.table, root.rowID])
            for id in stale {
                try db.execute(
                    sql: "UPDATE purge_intent SET deleted_at = ?, updated_at = ? WHERE id = ?",
                    arguments: [stamp, stamp, id])
            }
            return stale.count
        }
    }

    /// Physically removes a LOCAL-ONLY family — with the verdict
    /// RE-CHECKED inside this write transaction (R2-M3, 13j ladder B
    /// round 2): the staged read's verdict is a DIFFERENT snapshot, and a
    /// restore (⌥⌘Z, or a peer's Put back applying) committing in the
    /// read→write gap would otherwise be physically removed with NO
    /// mirror copy anywhere — pure loss, with none of the eligibleSynced
    /// arm's purge-wins justification (there the mirror has ALREADY
    /// purged when the local write runs; here nothing external happened
    /// at all). `LocalPurge` has always verdicted in-transaction — this
    /// is the same shape on the transported road's local arm. Returns nil
    /// when the family no longer reads `.eligibleLocalOnly` in THIS
    /// snapshot; the sweep defers it. No pin, per the
    /// architectural-finding rules: the race needs a user write landing
    /// between two transactions of one sweep — unpinnable without
    /// scheduling hooks (the recorded race-endpoints class); the traced
    /// mechanism and this justification live here instead.
    private func deleteFamilyLocally(
        _ root: SyncPurgeTarget, road: SweepRoad
    ) async throws -> Int? {
        let stamp = nowStamp()
        return try await database.write { db in
            try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
            let family = try PurgeFamily.expand(db, roots: [root])
            guard try Self.familyVerdict(db, family, horizon: 0, road: road)
                == .eligibleLocalOnly
            else { return nil }
            try PurgeFamily.deleteLocal(db, family: family, stamp: stamp)
            return family.rows.count
        }
    }

    // MARK: - Pruning candidates

    /// Prunable quiet-savepoint ids across at most `takesPerPass` LIVE
    /// takes (a dead take's savepoints ride its purge), skipping rows
    /// already named by a standing intent. The per-take rule is
    /// `SavepointPruning.prunable` — one brain, consulted per take.
    /// Static so `LocalPurge` prunes by the same rule (13j ladder B, B3).
    static func prunableSavepoints(
        _ db: Database, takesPerPass: Int, now: Date
    ) throws -> [String] {
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
                "takes": takesPerPass,
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
                among: savepoints, now: now))
        }
        return prunable
    }

    // MARK: - The ledger-verified orphan heal (RUN B B2 row 9 — 17d P8)

    /// **THE LEDGER-VERIFIED ORPHAN HEAL** — the fix for the purge-window
    /// mirror orphan (the orchestrator's row-9 ruling: Shape A, with the
    /// tombstone-only narrowing). The traced class: a peer's cascade rows
    /// commit inside the A5 visibility band while this device's sweep
    /// expands the family from a store that never saw them — the mirror
    /// keeps rows referencing a container purged everywhere, no ledger
    /// entry names them, no device retains a root, and every pull stalls
    /// at them FOREVER (B1's two pinned constructions). The heal
    /// COMPLETES the family's purge — §4f's own act, through the EXISTING
    /// RPCs (zero server lines): the missing referent is proven purged by
    /// the ledger, so the stalled row can only be a late-arriving family
    /// member, and it goes where its family went.
    ///
    ///  1. **The ruled NARROWING** (checked FIRST — two field reads, no
    ///     network; LADDER R1 F-R5): the stalled row must itself be a
    ///     TOMBSTONE (the traced construction's shape — the peer's
    ///     cascade stamped it before the push). A LIVE stalled row is
    ///     NEVER healed, whatever the ledger says: an untraced class,
    ///     left stalled and honest under the status flag
    ///     (safe-by-refusal), recorded if ever observed.
    ///  2. **Preflight**: the reconcile's own discipline (keys, §12
    ///     lockstep) — refusal, never improvisation.
    ///  3. **The DISCRIMINATOR — exact, no timers**: EVERY missing
    ///     referent must be named in the purged-ids ledger (read from 0:
    ///     content-free and prunable by design; this path runs only on a
    ///     stall, which is rare and self-limiting). Any referent NOT
    ///     named is a genuine §5 straggler the owing device still owes —
    ///     heal NOTHING; the class self-heals when that device drains.
    ///     (Under a future non-zero floor a pruned entry cannot be
    ///     checked by id — the heal refuses there too; the ledger-pruning
    ///     rider owes the below-floor refinement.)
    ///  4. **The COMPLETION SET**: the stalled row plus the local
    ///     cascade residue carrying its EXACT stamp (the cascade
    ///     contract's discriminator — in the traced shape, the block and
    ///     take the purging device never saw), expanded family-complete
    ///     through `PurgeFamily`. `executePurge` removes them from the
    ///     mirror AND ledgers them (idempotent — a second device meeting
    ///     the same stall heals the same rows into the same entries);
    ///     `deleteLocal` takes the local residue in one transaction.
    ///
    /// **The row-19 fence, stated (KnownIssues, owner 12):** this is the
    /// narrow traced mechanism — a heal for the ledger-PROVEN
    /// purge-orphan class only. No parking, no retry policy, no
    /// drop-loudly framework: a stall this discriminator cannot prove
    /// permanent is left exactly as designed.
    ///
    /// Returns whether it healed; the scheduler triggers a follow-up
    /// round on true (the feed no longer carries the orphan, so the
    /// cursor proceeds).
    public func healPurgeOrphan(_ stall: SyncEngine.PullStall) async throws -> Bool {
        // 1. The ruled narrowing FIRST — two struct-field reads (LADDER R1
        // F-R5: the scheduler hands EVERY stalled clean round here, and the
        // common §5 transient class paid the preflight's schemaVersion RPC
        // per round for a refusal these two lines decide; a live-row stall
        // now costs zero network). The degenerate difference — a live
        // stall under a set rotation marker refuses by `false` here where
        // it refused by throw before — is unreachable in production: the
        // round's own pull refuses on the marker before any stall exists.
        guard let stamp = stall.tombstoneStamp else { return false }
        guard !stall.missingReferents.isEmpty else { return false }

        // 2. The preflight (the reconcile's discipline — F-R7's one body).
        let (keyID, signer) = try await preflight()

        // 3. The discriminator: every missing referent ledger-named.
        let page = try await signer.call(rpc: "sync_purge_ledger") { proof in
            try await self.transport.purgeLedger(
                since: 0, activeKeyID: keyID, keyProof: proof)
        }
        let named = Set(page.entries.map { "\($0.table)|\($0.rowID)" })
        for referent in stall.missingReferents {
            guard named.contains("\(referent.table)|\(referent.rowID)") else {
                return false
            }
        }

        // 4. The completion set: the stalled row + the local cascade
        // residue carrying its EXACT stamp, scoped to the stalled row's
        // OWN FK-CONNECTED family (LADDER R1 F-R4 — this replaced a
        // store-wide `deleted_at = ?` sweep of four whole tables, which a
        // millisecond stamp collision could point at an UNRELATED,
        // merely-tombstoned family: `executePurge` would remove and
        // LEDGER it before every live device saw its deletion — the
        // pre-horizon purge §4f exists to forbid, the exact guarantee
        // `p2aTheHorizonHoldsThePurgeWhileTheLaptopIsLive` pins. It was
        // also four unindexed full-table scans). The connection facts
        // ride the stall itself (`presentReferents` — the arriving row's
        // FK targets that resolved; the row has no local copy to read):
        // a present referent tombstoned at the stall's exact stamp is
        // cascade residue of the same event, and `PurgeFamily.expand`
        // reaches everything behind it (the traced X + VX shape whole).
        // A multi-placement family heals iteratively — one stalled row
        // per round, the scheduler's follow-up round reaching the next;
        // bounded, and every round progresses.
        let family: PurgeFamily.Expansion = try await database.read { db in
            var roots = [SyncPurgeTarget(table: stall.table, rowID: stall.rowID)]
            for referent in stall.presentReferents {
                guard let registered = SyncSchema.table(named: referent.table),
                      registered.hasTombstone,
                      try String.fetchOne(
                          db,
                          sql: "SELECT deleted_at FROM \(registered.name) WHERE \(registered.primaryKey) = ?",
                          arguments: [referent.rowID]) == stamp
                else { continue }
                roots.append(SyncPurgeTarget(table: referent.table, rowID: referent.rowID))
            }
            return try PurgeFamily.expand(db, roots: roots)
        }
        let healRows = family.orderedRows
        _ = try await signer.call(rpc: "sync_purge_execute") { proof in
            try await self.transport.executePurge(
                healRows, activeKeyID: keyID, keyProof: proof)
        }
        try await database.write { db in
            try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
            try PurgeFamily.deleteLocal(db, family: family, stamp: self.nowStamp())
        }
        return true
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
        let material: KeyProofMaterial
        do {
            let keys = try keyProvider.currentKeys()
            keyID = keys.corpusKeyID
            material = keys.keyProof
        } catch {
            throw SyncError.encryptionKeysUnavailable
        }
        let signer = SyncChallengeSigner(
            transport: transport, material: material, activeKeyID: keyID)
        _ = try await engine.push()
        try await engine.resyncReinitialize()
        let page = try await signer.call(rpc: "sync_purge_ledger") { proof in
            try await self.transport.purgeLedger(since: 0, activeKeyID: keyID, keyProof: proof)
        }
        try await database.write { db in
            try Self.setStateValue(db, "purge_floor_acknowledged", page.floor)
            let scan = try Self.ledgerScanPoint(db)
            if page.floor > scan {
                try Self.setStateValue(db, Self.ledgerScanPointKey, page.floor)
            }
        }
    }

    // MARK: - Local state helpers

    /// THE LEDGER SCAN POINT's one name: how far this device has reconciled the server's purged-ids ledger (the
    /// memo's §2). Every ledger advance moves it — the pre-round reconciliation, the sweep's own purges, the
    /// returner's reload — and it only ever grows. `PullStage` keys a stage's identity on it (VX-494 ladder R2,
    /// R2-1) through this name and `ledgerScanPoint(_:)`, never a copy of either (ladder R3, R3-4).
    static let ledgerScanPointKey = "last_purge_seq"

    /// The scan point as every reader reads it — an absent row is 0 (`stateValue`'s rule).
    static func ledgerScanPoint(_ db: Database) throws -> Int64 {
        try stateValue(db, ledgerScanPointKey)
    }

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

// MARK: - The LOCAL purge (13j ladder B, B3 — her round-11 ruling)

/// **The transportless half of "really deleted"** — the road the free,
/// local, never-signed-in install runs (her round-11 ruling: never-synced
/// things purge immediately; "really deleted" really true for the free v1
/// population).
///
/// It shares the janitor's collection, verdict, and family machinery —
/// ONE rule, two cadences — and touches NO wire: no preflight, no ledger,
/// no horizon, no `executePurge`. Only families whose EVERY row is
/// `sync_row_seq`-absent purge here (the per-FAMILY discriminator she
/// adopted): a family with one synced member has a mirror copy somewhere
/// and WAITS for the transported janitor. Racing a CONFIGURED chain would
/// not corrupt but could cost (13j ladder B residuals, Obs 2 — the exact
/// sentence): this road is outbox-blind, and after a `resyncReinitialize`
/// (seq table cleared wholesale, mirror intact) it would read synced
/// families as local-only — a local purge whose mirror copies re-arrive
/// on the next pull, i.e. **transient resurrection converging to
/// purged**. That is why the app gates this road on
/// `SyncSession.isConfigured` (a reinit implies a configured chain), and
/// why the transported sweep carries the seq-absent-but-pending deferral
/// this road deliberately does not (her round-11 letter: the
/// never-configured install's outbox is full by construction).
///
/// **The gate is best-effort, not a seal (R2-N1, 13j ladder B round 2 —
/// recorded, deliberately not hardened):** at launch the first tick can
/// run before a signed-in chain composes (`isConfigured` reads false
/// while the lazy auth restore + adoption + configure are still in
/// flight), so one sweep per launch may run over a configured-chain
/// store. A normal store is safe there — synced families read
/// `anySynced` and defer; a never-drained deleted family purging locally
/// is her round-11 ruling's letter. The one wrong sub-case is a crash
/// after `resyncReinitialize` before any re-drain (seqs cleared, mirror
/// intact): that launch's sweep would local-purge synced TOMBSTONED rows
/// and converge as the transient resurrection above — invisible-surface
/// rows only, re-served then ledger-purged. The candidate hardening
/// (skip whenever `sync_state.device_id` exists) was weighed and
/// declined: it would also stop never-synced trash from purging on a
/// SIGNED-OUT install, making the doors' local receipt false there — a
/// worse trade than a convergent, invisible transient.
/// Stale intents complete here too (B1's rule is road-independent),
/// and savepoint pruning mints by the same brain, so a local install's
/// quiet history prunes exactly like a synced one's.
public struct LocalPurge: Sendable {
    /// EXPLICITLY bindable (the A4 fence's lesson, applied before it could
    /// bite): the app passes its own session's store, so a sweep can never
    /// resolve the ambient installed database — in a test host that is the
    /// DEV STORE, and a physical-removal pass is the one thing that must
    /// never land there by dependency accident. Nil resolves the ambient
    /// dependency (the core tests' scoped worlds).
    private let database: AppDatabase
    @Dependency(\.date) var date

    public var pruningTakesPerPass: Int

    public init(database: AppDatabase? = nil, pruningTakesPerPass: Int = 64) {
        if let database {
            self.database = database
        } else {
            @Dependency(\.database) var ambient
            self.database = ambient
        }
        self.pruningTakesPerPass = pruningTakesPerPass
    }

    public struct SweepReport: Equatable, Sendable {
        public var familiesPurged = 0
        public var rowsPurgedLocally = 0
        public var staleIntentsCompleted = 0
        public var pruneIntentsMinted = 0
        public init() {}
    }

    @discardableResult
    public func sweep() async throws -> SweepReport {
        var report = SweepReport()
        let now = date.now
        let roots = try await database.read { db in
            // Horizon 0: no synced family is ever eligible on this road.
            try PurgeJanitor.collectRoots(db, horizon: 0, now: now)
        }
        var processed: Set<SyncPurgeTarget> = []
        for (root, _) in roots {
            if processed.contains(root) { continue }
            let stamp = DateFormatter.variorumISO8601.string(from: now)
            let outcome: (verdict: PurgeJanitor.FamilyVerdict, rows: Int, stale: Int) =
                try await database.write { db in
                    try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
                    let family = try PurgeFamily.expand(db, roots: [root])
                    let verdict = try PurgeJanitor.familyVerdict(
                        db, family, horizon: 0, road: .localOnly)
                    switch verdict {
                    case .stale:
                        let stale = try String.fetchAll(
                            db,
                            sql: """
                                SELECT id FROM purge_intent
                                WHERE table_name = ? AND row_id = ? AND deleted_at IS NULL
                                """,
                            arguments: [root.table, root.rowID])
                        for id in stale {
                            try db.execute(
                                sql: "UPDATE purge_intent SET deleted_at = ?, updated_at = ? WHERE id = ?",
                                arguments: [stamp, stamp, id])
                        }
                        return (verdict, 0, stale.count)
                    case .eligibleLocalOnly:
                        try PurgeFamily.deleteLocal(db, family: family, stamp: stamp)
                        return (verdict, family.rows.count, 0)
                    case .eligibleSynced, .deferred:
                        return (verdict, 0, 0)
                    }
                }
            report.staleIntentsCompleted += outcome.stale
            if outcome.verdict == .eligibleLocalOnly {
                report.familiesPurged += 1
                report.rowsPurgedLocally += outcome.rows
                processed.insert(root)
            }
        }

        // Pruning by the one brain (memo §4d) — a local install's minted
        // intents are themselves never-synced, so the NEXT local sweep
        // takes the named savepoints through the local road above.
        let pruning = try await database.read { try Queries.historyPruning($0) }
        if pruning == .standard {
            let takes = pruningTakesPerPass
            let prunable = try await database.read { db in
                try PurgeJanitor.prunableSavepoints(db, takesPerPass: takes, now: now)
            }
            if !prunable.isEmpty {
                // The op bound to THIS sweep's store (the explicit-database
                // fence above): never the ambient installed one. R2-N2
                // (13j ladder B round 2): the CALL runs inside the
                // `withDependencies` scope, not just the construction —
                // `@Dependency` resolves as captured-initials merged with
                // the CALL-SITE task-locals, call-site preferred, so an
                // escaped op invoked under some future
                // `withDependencies { $0.database = other }` scope would
                // silently re-point the mint at the other store while the
                // family removals above stayed bound. In-scope, the
                // binding is structural, not circumstantial.
                report.pruneIntentsMinted = try withDependencies {
                    $0.database = database
                } operation: {
                    try Operations().requestPurge(
                        prunable.map { SyncPurgeTarget(table: "commit_point", rowID: $0) })
                }
            }
        }
        return report
    }
}
