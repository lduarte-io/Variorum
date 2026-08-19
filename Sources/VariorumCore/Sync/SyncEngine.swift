import Dependencies
import Foundation
import GRDB

/// The push/pull engine (SyncSpec §4–5). The transport is a dumb CAS +
/// changefeed; every bit of merge intelligence lives here, client-side,
/// deterministic.
///
/// The standing discipline (the Phase 1 trap, SyncSpec §4): **every write
/// the engine makes on its own behalf runs in apply mode** — a bare
/// bookkeeping write re-enqueues the row it just pushed and the engine
/// pushes forever. The deliberate exceptions are repair writes and rescue/
/// conflict variants, which run inside the apply transaction where the
/// triggers are muted and therefore enqueue their outbox rows **explicitly**
/// (SyncSpec §7) — without that, repairs apply locally but never push and
/// the devices silently diverge.
public struct SyncEngine: Sendable {
    @Dependency(\.database) var database
    @Dependency(\.date) var date
    @Dependency(\.uuid) var uuid

    public let transport: any SyncTransport
    /// The E2EE key seam (Phase 14b): each round half asks the provider
    /// once and seals/opens every payload with the answer. The default is
    /// the UNENROLLED provider — post-14b there is no plaintext mode, so an
    /// engine nobody wired keys into refuses every round visibly (the
    /// designed pre-enrollment state; batch 3's enrollment flow installs
    /// the Keychain-backed provider).
    public let keyProvider: any SyncKeyProviding
    /// Rows per push batch / pull window (transport granularity; the pull
    /// APPLY transaction always covers everything fetched, so window size
    /// never affects convergence — the soak randomizes it to prove that).
    public var batchSize: Int
    /// One `push()` call re-pushes rejected-and-merged rows at most this
    /// many times; anything still dirty stays in the outbox for the next
    /// call. Bounded by design — retry/backoff hardening is Phase 12.
    public var maxPushIterations: Int

    public init(
        transport: any SyncTransport, batchSize: Int = 200, maxPushIterations: Int = 5,
        keyProvider: any SyncKeyProviding = UnenrolledKeyProvider()
    ) {
        self.transport = transport
        self.batchSize = batchSize
        self.maxPushIterations = maxPushIterations
        self.keyProvider = keyProvider
    }

    /// Ladder R1-1: the persisted rekey-in-progress marker's round guard —
    /// `AccountRekey.run` sets the marker before its vault write and
    /// clears it only when the whole road completes, so a crash anywhere
    /// between leaves it set across relaunches. While it is set, both
    /// round halves refuse with a self-explaining error naming the rerun
    /// road — outbox intact, cursor unmoved, the §12 refusal grammar.
    /// (`resyncReinitialize` is deliberately NOT guarded: the brain's own
    /// step 5 runs with the marker set.)
    private func refuseIfRekeyIncomplete() async throws {
        let incomplete = try await database.read { try AccountRekeyMarker.isSet($0) }
        guard !incomplete else { throw SyncError.accountRekeyIncomplete }
    }

    /// The round's crypto seam, or the visible refusal (Phase 14b): ANY
    /// provider throw maps to `SyncError.encryptionKeysUnavailable` — a
    /// self-explaining status naming the fix, pinned exactly like the §12
    /// lockstep-skew refusal. Called BEFORE any network contact, so a
    /// locked device refuses for free.
    private func roundCrypto() throws -> SyncPayloadCrypto {
        do {
            return SyncPayloadCrypto(keys: try keyProvider.currentKeys())
        } catch {
            throw SyncError.encryptionKeysUnavailable
        }
    }

    // MARK: - Push (SyncSpec §4)

    public struct PushReport: Equatable, Sendable {
        public var accepted = 0
        /// Rejects merged locally this call (each re-pushes next iteration
        /// or next call).
        public var rejected = 0
        /// Rejects whose merged row references rows this store has not seen
        /// yet (a straggler, SyncSpec §5) — left enqueued untouched; a pull
        /// brings the referent, then the next push retries.
        public var deferred = 0
        /// Phase 13j: rows the server refused as PURGED (the ledger fence)
        /// — outbox entry dropped, local family removed. Never retried.
        public var purged = 0
        public var iterations = 0
        public init() {}
    }

    /// Drains the outbox: snapshot dirty rows → load current payloads (a
    /// tombstone is a push like any other) → CAS batch → accepted rows get
    /// their server-granted `sync_version` recorded in apply mode and leave
    /// the outbox **only if not re-dirtied since the snapshot**; rejected
    /// rows merge per SyncSpec §6 and re-push on the next iteration.
    @discardableResult
    public func push() async throws -> PushReport {
        // An unfinished re-key on THIS device refuses first (ladder
        // R1-1): rounds against a mid-re-key account can silently strand
        // the hosted copy — see `AccountRekeyMarker`. Before keys and
        // lockstep because its prescription (re-run the re-key door)
        // subsumes both; before any network contact by construction.
        try await refuseIfRekeyIncomplete()
        try ensureDeviceID()
        // Keys first (Phase 14b): absent/locked keys refuse the round
        // before any network contact — outbox intact, cursor unmoved.
        let crypto = try roundCrypto()
        try await verifySchemaLockstep()
        var report = PushReport()
        for _ in 0..<maxPushIterations {
            let batch: [SyncRow] = try await database.read { db in
                let entries = try Row.fetchAll(
                    db, sql: "SELECT table_name, row_id FROM sync_outbox")
                return try entries
                    .compactMap { entry -> SyncRow? in
                        guard let table = SyncSchema.table(named: entry["table_name"]) else { return nil }
                        return try SyncRow.fetch(db, table: table, rowID: entry["row_id"])
                    }
                    .sorted {
                        let (a, b) = (SyncSchema.applyOrderIndex(of: $0.table),
                                      SyncSchema.applyOrderIndex(of: $1.table))
                        return a == b ? ($0.rowID < $1.rowID) : (a < b)
                    }
            }
            guard !batch.isEmpty else { break }
            report.iterations += 1

            var madeProgress = false
            for chunk in stride(from: 0, to: batch.count, by: batchSize).map({
                Array(batch[$0..<min($0 + batchSize, batch.count)])
            }) {
                // THE SEAM, push half (Phase 14b): the wire carries sealed
                // payloads; `chunk` itself stays PLAINTEXT — it is what the
                // accept bookkeeping compares against the live row
                // (clear-vs-re-dirty) and what the reject path merges from.
                // Phase 14c: the round's held key id rides every call — the
                // server's vault-key-id fence compares it (THE DESIGN 2).
                let wireChunk = try chunk.map(crypto.encryptForWire)
                let rawOutcomes = try await transport.push(
                    wireChunk, activeKeyID: crypto.keys.corpusKeyID)
                // THE SEAM, reject-merge half: a reject's `current` row is
                // opened HERE, before the FK check and the merge — inland
                // logic sees plaintext only.
                let outcomes = try rawOutcomes.map { outcome -> SyncPushOutcome in
                    guard case .rejected(let current) = outcome, let current else {
                        return outcome
                    }
                    return .rejected(current: try crypto.decryptFromWire(current))
                }
                let processed: ChunkResult = try await applyingRemoteWithDeferredFKs { db in
                    var result = ChunkResult()
                    var touched = TouchedRows()
                    for (pushed, outcome) in zip(chunk, outcomes) {
                        switch outcome {
                        case .purged:
                            // Phase 13j (the memo's §2 ledger): the server
                            // says this id was PURGED. Drop the outbox
                            // entry — and the local copy, family-complete,
                            // or the two stores would never converge (the
                            // row would linger here as a live orphan no
                            // feed can ever correct, since its mirror rows
                            // no longer exist). Runs inside the apply
                            // transaction with the triggers muted, so the
                            // family removal's survivor detachment and
                            // intent completion enqueue EXPLICITLY (the
                            // SyncSpec §7 repair-write discipline).
                            let family = try PurgeFamily.expand(
                                db,
                                roots: [SyncPurgeTarget(table: pushed.table, rowID: pushed.rowID)])
                            try PurgeFamily.deleteLocal(
                                db, family: family, stamp: nowStamp(),
                                enqueue: { try self.enqueueExplicitly(db, table: $0, rowID: $1) })
                            try clearOutboxEntry(db, table: pushed.table, rowID: pushed.rowID)
                            result.purged += 1
                        case .accepted(let newVersion, let serverSeq):
                            try recordAccepted(
                                db, pushed: pushed, newVersion: newVersion, serverSeq: serverSeq)
                            result.accepted += 1
                        case .rejected(let current):
                            guard let current else {
                                // The server has no row for a non-zero base
                                // (mirror reset): rebase to 0; the next
                                // iteration re-pushes it as an insert.
                                try setLocalSyncVersion(db, table: pushed.table, rowID: pushed.rowID, to: 0)
                                result.rejected += 1
                                continue
                            }
                            // Merge against the CURRENT local row, never the
                            // pre-transport snapshot: an edit landing during
                            // the network await must be rescued, not
                            // clobbered-and-unenqueued (Phase 5 review
                            // BLOCKER — the reject-path twin of
                            // recordAccepted's content comparison).
                            guard let table = SyncSchema.table(named: pushed.table),
                                  let local = try SyncRow.fetch(db, table: table, rowID: pushed.rowID)
                            else {
                                // An outbox entry with no row cannot arise in
                                // production (rows are never physically
                                // deleted); leave it for the next drain.
                                result.deferred += 1
                                continue
                            }
                            if try foreignKeysSatisfiable(db, row: current.row, arriving: [:]) {
                                try merge(
                                    db, local: local, server: current.row,
                                    serverSeq: current.serverSeq, touched: &touched)
                                result.rejected += 1
                            } else {
                                // Merged row would reference rows this store
                                // has never seen (straggler): leave the row
                                // enqueued and untouched; pull first.
                                result.deferred += 1
                            }
                        }
                    }
                    // One repair pass per chunk transaction — batch-scoped
                    // like the pull path.
                    try runPostApplyRepairs(db, touched: touched)
                    return result
                }
                report.accepted += processed.accepted
                report.rejected += processed.rejected
                report.deferred += processed.deferred
                report.purged += processed.purged
                madeProgress = madeProgress || processed.accepted > 0 || processed.rejected > 0
                    || processed.purged > 0
            }
            guard madeProgress else { break }
        }
        return report
    }

    private struct ChunkResult: Sendable {
        var accepted = 0
        var rejected = 0
        var deferred = 0
        var purged = 0
    }

    // MARK: - Pull (SyncSpec §5)

    public struct PullReport: Equatable, Sendable {
        /// Locally-clean rows written verbatim (echoes of our own pushes
        /// included).
        public var applied = 0
        /// Locally-dirty rows merged per §6.
        public var merged = 0
        /// Repair writes (SyncSpec §7) made inside the apply transaction.
        public var repairs = 0
        public var newCursor: Int64 = 0
        /// True when the batch stopped early at a row whose referents have
        /// not reached the server yet (the other device's outbox still owes
        /// them); the cursor holds just before that row and the next pull
        /// retries. Self-heals when the owing device drains.
        public var stalled = false
        public init() {}
    }

    /// Fetches the changefeed to head, then applies **everything in one
    /// `applyingRemote` transaction** with `PRAGMA defer_foreign_keys = ON`
    /// set inside it (multi-row operations arrive as row sets; deferred FKs
    /// make the batch atomic-consistent at commit). Locally-clean rows are
    /// written verbatim with their server `sync_version`; locally-dirty rows
    /// merge per §6 and stay enqueued as long as local intent survives.
    /// Repairs run inside the same transaction, after rows land. The cursor
    /// advances inside the transaction — a rollback rewinds it with
    /// everything else.
    @discardableResult
    public func pull() async throws -> PullReport {
        // The unfinished-re-key guard, the push half's twin (ladder R1-1).
        try await refuseIfRekeyIncomplete()
        try ensureDeviceID()
        // Keys first (Phase 14b): absent/locked keys refuse the round
        // before any network contact — outbox intact, cursor unmoved.
        let crypto = try roundCrypto()
        try await verifySchemaLockstep()
        let since = try await database.read { try cursor($0) }
        let deviceID = try await database.read { db in
            try String.fetchOne(db, sql: "SELECT value FROM sync_state WHERE key = 'device_id'")
        }
        var pulled: [SyncPulledRow] = []
        var fetchCursor = since
        while true {
            // Phase 14c: the held key id rides the pull half too — both
            // round halves are fenced (THE DESIGN 2).
            //
            // Phase 13j: the device id rides the FIRST window only, where
            // `since` is this device's COMMITTED cursor — the server's
            // device_cursor upsert is what makes the purge horizon
            // computable. Mid-round windows pass nil: their `since` values
            // are uncommitted fetch positions, and recording one would
            // over-report what this device has integrated if the apply
            // below never commits.
            let window = try await transport.pull(
                since: fetchCursor, limit: batchSize, activeKeyID: crypto.keys.corpusKeyID,
                deviceID: fetchCursor == since ? deviceID : nil)
            guard !window.isEmpty else { break }
            // THE SEAM, pull half (Phase 14b): every arriving row is opened
            // BEFORE the apply transaction exists — a decrypt refusal
            // (plaintext-in-encrypted-column, tamper, wrong key) throws
            // here, with the cursor unmoved and nothing written. Everything
            // downstream (straggler guard, merge, repairs, apply) is
            // plaintext-only and byte-untouched.
            pulled.append(contentsOf: try window.map(crypto.decryptFromWire))
            fetchCursor = window.last!.serverSeq
        }
        var emptyReport = PullReport()
        emptyReport.newCursor = since
        guard !pulled.isEmpty else { return emptyReport }

        let batch = pulled
        return try await applyingRemoteWithDeferredFKs { db in
            var report = PullReport()
            // Straggler guard, to a FIXPOINT: rows apply in seq order up to
            // the first row whose FK closure is satisfiable neither locally
            // nor by a row in the APPLIED PREFIX. Satisfiability against the
            // full fetched set would let a prefix row lean on a referent
            // that itself stalls past the stop point — turning the designed
            // graceful stall into a deferred-FK commit failure and a
            // whole-batch rollback on every retry (Phase 5 review MAJOR).
            // The index strictly decreases, so the loop terminates.
            var stopIndex = batch.count
            while true {
                let prefixArriving = arrivingRowIDs(Array(batch[..<stopIndex]))
                var shrunk = stopIndex
                for (index, item) in batch[..<stopIndex].enumerated() {
                    guard try foreignKeysSatisfiable(db, row: item.row, arriving: prefixArriving) else {
                        shrunk = index
                        break
                    }
                }
                if shrunk == stopIndex { break }
                stopIndex = shrunk
            }

            var touched = TouchedRows()
            for item in batch[..<stopIndex] where item.row.isTombstoned {
                touched.arrivingDeadIDs[item.row.table, default: []].insert(item.row.rowID)
            }
            for item in batch[..<stopIndex] {
                if try isEnqueued(db, table: item.row.table, rowID: item.row.rowID),
                   let table = SyncSchema.table(named: item.row.table),
                   let local = try SyncRow.fetch(db, table: table, rowID: item.row.rowID) {
                    // Echo/stale guard (Phase 5 review BLOCKER): the
                    // changefeed replays this device's own accepted rows. A
                    // dirty local row with `local.syncVersion >=` the
                    // incoming version holds a PENDING CAS WIN — the next
                    // push lands it cleanly on top of that very version.
                    // Merging here would revert the buffer under the
                    // author's cursor and demote her newer text to a
                    // spurious 'conflict' card. Same version ⇒ same
                    // server state we already integrated; nothing to merge.
                    guard item.row.syncVersion > local.syncVersion else {
                        try recordSeq(db, table: item.row.table, rowID: item.row.rowID, seq: item.serverSeq)
                        continue  // stays enqueued; push ships the local intent
                    }
                    try merge(db, local: local, server: item.row,
                              serverSeq: item.serverSeq, touched: &touched)
                    report.merged += 1
                } else {
                    // Locally clean (or an outbox entry with no local row,
                    // impossible in production): write verbatim.
                    try writeResolvedRow(db, item.row, serverSeq: item.serverSeq, touched: &touched)
                    try recordSeq(db, table: item.row.table, rowID: item.row.rowID, seq: item.serverSeq)
                    report.applied += 1
                }
            }
            report.repairs = try runPostApplyRepairs(db, touched: touched) + touched.inlineRepairs
            let newCursor = stopIndex > 0 ? batch[stopIndex - 1].serverSeq : since
            try setCursor(db, newCursor)
            report.newCursor = newCursor
            report.stalled = stopIndex < batch.count
            return report
        }
    }

    // MARK: - Wipe-and-repush re-initialization (Phase 14b, ruling R-2)

    /// The CLIENT half of wipe-and-repush — core semantics only (batch 3
    /// productizes the door behind an explicit, announced act; this is the
    /// harness-proven function the gate runs after the mirror's data-table
    /// truncate). No in-place migration machinery exists: local SQLite is
    /// truth, the mirror is a peer, so the mirror re-initializes by
    /// truncate + a full re-push through the (now encrypting) serializer.
    ///
    /// One plain write transaction — deliberately NOT apply mode: the
    /// `sync_version = 0` sweeps fire the outbox triggers, which is the
    /// goal, and the explicit outbox INSERTs guarantee totality regardless
    /// (tombstoned rows, `commit_point`, `setting` — EVERY row of EVERY
    /// synced table re-pushes; tombstones must reach the fresh mirror or a
    /// later device would resurrect the dead).
    ///
    ///  - every synced row's `sync_version` → 0 (the CAS base for a fresh
    ///    insert against an empty mirror);
    ///  - `sync_row_seq` cleared (no row has a server seq anymore — repair
    ///    ranking starts over, SyncSpec §3);
    ///  - the pull cursor cleared (the next pull reads from 0; the global
    ///    `server_seq` itself is NEVER reset — SyncSpec §9);
    ///  - EVERY row enqueued into the outbox.
    ///
    /// `device_id` survives: device identity is not sync bookkeeping.
    public func resyncReinitialize() async throws {
        try await database.write { db in
            for table in SyncSchema.tables {
                try db.execute(sql: "UPDATE \(table.name) SET sync_version = 0")
                try db.execute(sql: """
                    INSERT OR REPLACE INTO sync_outbox (table_name, row_id, queued_at)
                    SELECT '\(table.name)', \(table.primaryKey),
                           strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
                    FROM \(table.name)
                    """)
            }
            try db.execute(sql: "DELETE FROM sync_row_seq")
            try db.execute(sql: "DELETE FROM sync_state WHERE key = 'last_server_seq'")
        }
    }

    // MARK: - The §12 version check (Phase 11, Step A1)

    /// SyncSpec §12's version-check mechanism, shipped with the first
    /// post-sync migration that needs it (the Phase 11 lockstep event):
    /// every round half opens by comparing the mirror's deployed schema
    /// marker against this client's `SyncSchema.lockstepVersion`. ANY
    /// mismatch — behind OR ahead — refuses the round with a visible,
    /// self-explaining error; the outbox keeps everything and the cursor
    /// never moves. Stalling is free (offline is free); a client that
    /// guessed would push columns `jsonb_populate_record` silently drops,
    /// or pull tables it has no home for.
    public func verifySchemaLockstep() async throws {
        let server = try await transport.schemaVersion()
        guard server == SyncSchema.lockstepVersion else {
            throw SyncError.schemaLockstepMismatch(
                client: SyncSchema.lockstepVersion, server: server)
        }
    }

    // MARK: - Accept bookkeeping

    /// The Phase 1 trap made concrete: this runs inside apply mode. The
    /// outbox entry is cleared **only if the row still matches what was
    /// pushed** — a row re-dirtied mid-push keeps its entry and re-pushes
    /// (clearing it would lose the newer edit forever; the plan's named
    /// clear-vs-re-dirty race).
    private func recordAccepted(
        _ db: Database, pushed: SyncRow, newVersion: Int, serverSeq: Int64
    ) throws {
        try setLocalSyncVersion(db, table: pushed.table, rowID: pushed.rowID, to: newVersion)
        try recordSeq(db, table: pushed.table, rowID: pushed.rowID, seq: serverSeq)
        guard let table = SyncSchema.table(named: pushed.table),
              let current = try SyncRow.fetch(db, table: table, rowID: pushed.rowID),
              current.columns == pushed.columns
        else { return }
        try clearOutboxEntry(db, table: pushed.table, rowID: pushed.rowID)
    }

    private func setLocalSyncVersion(
        _ db: Database, table: String, rowID: String, to version: Int
    ) throws {
        guard let table = SyncSchema.table(named: table) else { return }
        try db.execute(
            sql: "UPDATE \(table.name) SET sync_version = ? WHERE \(table.primaryKey) = ?",
            arguments: [version, rowID])
    }

    // MARK: - Apply-transaction plumbing

    /// One apply-mode transaction with deferred FK enforcement — the pragma
    /// must be executed INSIDE the transaction (it resets at commit;
    /// SyncSpec §5, Phase 5 plan risk list).
    func applyingRemoteWithDeferredFKs<T>(_ body: (Database) throws -> T) throws -> T {
        try database.applyingRemote { db in
            try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
            return try body(db)
        }
    }

    /// The async twin the engine's own paths use, so an apply transaction
    /// never blocks a cooperative-pool thread (Phase 5 review).
    func applyingRemoteWithDeferredFKs<T: Sendable>(
        _ body: @escaping @Sendable (Database) throws -> T
    ) async throws -> T {
        try await database.applyingRemote { db in
            try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
            return try body(db)
        }
    }

    /// All row IDs arriving in this batch, by table — a forward-referenced
    /// parent inside the batch satisfies a child under deferred FKs.
    private func arrivingRowIDs(_ pulled: [SyncPulledRow]) -> [String: Set<String>] {
        var arriving: [String: Set<String>] = [:]
        for item in pulled {
            arriving[item.row.table, default: []].insert(item.row.rowID)
        }
        return arriving
    }

    /// True when every non-NULL FK value in the row resolves to a row that
    /// exists locally (live or tombstoned) or arrives in this batch. FK
    /// columns are introspected from the live schema, never hardcoded.
    func foreignKeysSatisfiable(
        _ db: Database, row: SyncRow, arriving: [String: Set<String>]
    ) throws -> Bool {
        for fk in try foreignKeyColumns(db, table: row.table) {
            guard case .text(let target) = row.columns[fk.column] else { continue }
            if arriving[fk.targetTable]?.contains(target) == true { continue }
            let exists = try Bool.fetchOne(
                db,
                sql: "SELECT EXISTS (SELECT 1 FROM \(fk.targetTable) WHERE \(fk.targetPrimaryKey) = ?)",
                arguments: [target]) ?? false
            guard exists else { return false }
        }
        return true
    }

    private func foreignKeyColumns(
        _ db: Database, table: String
    ) throws -> [(column: String, targetTable: String, targetPrimaryKey: String)] {
        try Row.fetchAll(db, sql: "PRAGMA foreign_key_list(\(table))").compactMap { fk in
            let targetTable: String = fk["table"]
            guard let target = SyncSchema.table(named: targetTable) else { return nil }
            return (fk["from"], targetTable, target.primaryKey)
        }
    }

    // MARK: - Local sync-state helpers

    func cursor(_ db: Database) throws -> Int64 {
        let value = try String.fetchOne(
            db, sql: "SELECT value FROM sync_state WHERE key = 'last_server_seq'")
        return value.flatMap(Int64.init) ?? 0
    }

    func setCursor(_ db: Database, _ seq: Int64) throws {
        try db.execute(
            sql: "INSERT OR REPLACE INTO sync_state (key, value) VALUES ('last_server_seq', ?)",
            arguments: [String(seq)])
    }

    /// Mints `sync_state.device_id` once (SyncSpec §3). `sync_state` is
    /// local-only — no triggers watch it, so a plain write is safe.
    func ensureDeviceID() throws {
        let existing = try database.read { db in
            try String.fetchOne(db, sql: "SELECT value FROM sync_state WHERE key = 'device_id'")
        }
        guard existing == nil else { return }
        let id = uuid().uuidString
        try database.write { db in
            try db.execute(
                sql: "INSERT OR IGNORE INTO sync_state (key, value) VALUES ('device_id', ?)",
                arguments: [id])
        }
    }

    /// Per-row server_seq bookkeeping (v1_3): what makes "higher server_seq
    /// wins" decidable client-side. Rows the server never accepted rank 0.
    func recordSeq(_ db: Database, table: String, rowID: String, seq: Int64) throws {
        try db.execute(
            sql: "INSERT OR REPLACE INTO sync_row_seq (table_name, row_id, server_seq) VALUES (?, ?, ?)",
            arguments: [table, rowID, seq])
    }

    func knownSeq(_ db: Database, table: String, rowID: String) throws -> Int64 {
        try Int64.fetchOne(
            db,
            sql: "SELECT server_seq FROM sync_row_seq WHERE table_name = ? AND row_id = ?",
            arguments: [table, rowID]) ?? 0
    }

    func isEnqueued(_ db: Database, table: String, rowID: String) throws -> Bool {
        try Bool.fetchOne(
            db,
            sql: "SELECT EXISTS (SELECT 1 FROM sync_outbox WHERE table_name = ? AND row_id = ?)",
            arguments: [table, rowID]) ?? false
    }

    /// The explicit enqueue for writes made while the triggers are muted —
    /// repairs and rescue variants MUST reach the outbox or the devices
    /// silently diverge (SyncSpec §7; every repair test asserts this row).
    func enqueueExplicitly(_ db: Database, table: String, rowID: String) throws {
        try db.execute(
            sql: """
                INSERT OR REPLACE INTO sync_outbox (table_name, row_id, queued_at)
                VALUES (?, ?, strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
                """,
            arguments: [table, rowID])
    }

    func clearOutboxEntry(_ db: Database, table: String, rowID: String) throws {
        try db.execute(
            sql: "DELETE FROM sync_outbox WHERE table_name = ? AND row_id = ?",
            arguments: [table, rowID])
    }

    // MARK: - Shared timestamp

    /// Repair tombstones and rescue variants stamp with the injected clock,
    /// in the canonical format. Wall time is display/domain data only —
    /// never sync ordering (SyncSpec §9).
    func nowStamp() -> String {
        DateFormatter.variorumISO8601.string(from: date.now)
    }
}
