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
    /// Rows per push batch / pull window (transport granularity; the pull
    /// APPLY transaction always covers everything fetched, so window size
    /// never affects convergence — the soak randomizes it to prove that).
    public var batchSize: Int
    /// One `push()` call re-pushes rejected-and-merged rows at most this
    /// many times; anything still dirty stays in the outbox for the next
    /// call. Bounded by design — retry/backoff hardening is Phase 12.
    public var maxPushIterations: Int

    public init(transport: any SyncTransport, batchSize: Int = 200, maxPushIterations: Int = 5) {
        self.transport = transport
        self.batchSize = batchSize
        self.maxPushIterations = maxPushIterations
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
        try ensureDeviceID()
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
                let outcomes = try await transport.push(chunk)
                try applyingRemoteWithDeferredFKs { db in
                    for (pushed, outcome) in zip(chunk, outcomes) {
                        switch outcome {
                        case .accepted(let newVersion, let serverSeq):
                            try recordAccepted(
                                db, pushed: pushed, newVersion: newVersion, serverSeq: serverSeq)
                            report.accepted += 1
                            madeProgress = true
                        case .rejected(let current):
                            guard let current else {
                                // The server has no row for a non-zero base
                                // (mirror reset): rebase to 0; the next
                                // iteration re-pushes it as an insert.
                                try setLocalSyncVersion(db, table: pushed.table, rowID: pushed.rowID, to: 0)
                                report.rejected += 1
                                madeProgress = true
                                continue
                            }
                            if try foreignKeysSatisfiable(db, row: current.row, arriving: [:]) {
                                var touched = TouchedRows()
                                try merge(
                                    db, local: pushed, server: current.row,
                                    serverSeq: current.serverSeq, touched: &touched)
                                try runPostApplyRepairs(db, touched: touched)
                                report.rejected += 1
                                madeProgress = true
                            } else {
                                // Merged row would reference rows this store
                                // has never seen (straggler): leave the row
                                // enqueued and untouched; pull first.
                                report.deferred += 1
                            }
                        }
                    }
                }
            }
            guard madeProgress else { break }
        }
        return report
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
        try ensureDeviceID()
        let since = try await database.read { try cursor($0) }
        var pulled: [SyncPulledRow] = []
        var fetchCursor = since
        while true {
            let window = try await transport.pull(since: fetchCursor, limit: batchSize)
            guard !window.isEmpty else { break }
            pulled.append(contentsOf: window)
            fetchCursor = window.last!.serverSeq
        }
        var report = PullReport()
        report.newCursor = since
        guard !pulled.isEmpty else { return report }

        try applyingRemoteWithDeferredFKs { db in
            // Straggler guard: rows apply in seq order up to the first row
            // whose FK closure is satisfiable neither locally nor by any row
            // in this batch (deferred FKs resolve in-batch forward references
            // at commit; a truly absent referent would fail the commit and
            // wedge the pull forever).
            let arriving = arrivingRowIDs(pulled)
            var stopIndex = pulled.count
            for (index, item) in pulled.enumerated() {
                guard try foreignKeysSatisfiable(db, row: item.row, arriving: arriving) else {
                    stopIndex = index
                    break
                }
            }

            var touched = TouchedRows()
            for item in pulled[..<stopIndex] {
                if try isEnqueued(db, table: item.row.table, rowID: item.row.rowID),
                   let table = SyncSchema.table(named: item.row.table),
                   let local = try SyncRow.fetch(db, table: table, rowID: item.row.rowID) {
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
            let newCursor = stopIndex > 0 ? pulled[stopIndex - 1].serverSeq : since
            try setCursor(db, newCursor)
            report.newCursor = newCursor
            report.stalled = stopIndex < pulled.count
        }
        return report
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
