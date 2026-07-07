import Foundation
@testable import VariorumCore

/// The in-process stand-in for the Supabase mirror (SyncSpec §2/§4) — and it
/// must stay exactly this dumb: per-row compare-and-set, one global monotonic
/// `server_seq`, **no uniqueness constraints, no foreign keys, no domain
/// logic**. The real mirror deliberately accepts both sides of a race (two
/// live placements for one block, dangling references mid-batch) so clients
/// can repair deterministically; any check added here that Postgres won't
/// have hides a client bug the real server would let through.
actor FakeSyncServer: SyncTransport {
    private struct StoredRow {
        var row: SyncRow          // payload; row.syncVersion == current version
        var serverSeq: Int64      // stamped on every accepted change
        /// Logical-clock tick when the row was WRITTEN (seq assignment time).
        /// The A5 visibility horizon is measured against this — the fake twin
        /// of the mirror's `server_written_at` (03_visibility_horizon.sql).
        var writtenAt: Int64
        /// False while the writing transaction is still open (`holdPushes`):
        /// the row has a seq but is invisible to pulls — the visibility skew
        /// SyncSpec §5 documents (seq assigned at write time, row visible at
        /// commit time).
        var committed: Bool
    }

    /// table → rowID → current state. Rows are never removed: a tombstone is
    /// an ordinary accepted update (S2).
    private var tables: [String: [String: StoredRow]] = [:]
    private var seq: Int64 = 0

    // MARK: A5 machinery (in-flight transactions + visibility horizon)

    /// Logical server clock, in ticks; tests advance it explicitly.
    private var clock: Int64 = 0
    /// Rows written within the last `visibilityHorizon` ticks are never
    /// served — the changefeed fix (SyncSpec §5; the real RPC's
    /// `interval '2 seconds'` filter). **0 models the PRE-FIX server**, which
    /// is also exactly right for every synchronous suite: with no concurrent
    /// transactions there is no skew to hide from.
    private let visibilityHorizon: Int64
    /// While true, the NEXT push call's rows are stamped (seq + writtenAt)
    /// but stay invisible until `commitHeldPushes()` — one in-flight
    /// transaction later transactions commit around.
    private var holdingNextPush = false

    init(visibilityHorizon: Int64 = 0) {
        self.visibilityHorizon = visibilityHorizon
    }

    func advanceClock(by ticks: Int64) {
        clock += ticks
    }

    /// The next push call becomes one held-open transaction (subsequent
    /// pushes commit normally around it).
    func holdNextPush() {
        holdingNextPush = true
    }

    /// Commits the held transaction: its rows become visible AT THEIR
    /// ORIGINAL seqs (possibly below already-visible later seqs — the skew).
    func commitHeldPushes() {
        holdingNextPush = false
        for (table, rows) in tables {
            for (rowID, stored) in rows where !stored.committed {
                tables[table]![rowID]!.committed = true
            }
        }
    }

    // MARK: SyncTransport

    func push(_ batch: [SyncRow]) throws -> [SyncPushOutcome] {
        let heldTransaction = holdingNextPush
        holdingNextPush = false
        return try batch.map { incoming in
            let current = tables[incoming.table]?[incoming.rowID]
            let currentVersion = current?.row.syncVersion ?? 0
            guard incoming.syncVersion == currentVersion else {
                return .rejected(current: current.map {
                    SyncPulledRow(row: $0.row, serverSeq: $0.serverSeq)
                })
            }
            seq += 1
            var accepted = incoming
            accepted.syncVersion = currentVersion + 1
            // Wire fidelity (the plan's fake-server-drift risk): real
            // payloads cross jsonb, which normalizes scalar types
            // (`.real(0.0)` → `.integer(0)`). Round-trip every accepted row
            // through JSON so engine flows see the same normalization the
            // real mirror would produce.
            let normalized = try JSONDecoder().decode(
                SyncRow.self, from: JSONEncoder().encode(accepted))
            tables[incoming.table, default: [:]][incoming.rowID] =
                StoredRow(row: normalized, serverSeq: seq,
                          writtenAt: clock, committed: !heldTransaction)
            return .accepted(newVersion: accepted.syncVersion, serverSeq: seq)
        }
    }

    func pull(since: Int64, limit: Int) -> [SyncPulledRow] {
        Array(
            tables.values
                .flatMap { $0.values }
                .filter {
                    $0.committed && $0.serverSeq > since
                        && $0.writtenAt <= clock - visibilityHorizon
                }
                .sorted { $0.serverSeq < $1.serverSeq }
                .prefix(limit)
                .map { SyncPulledRow(row: $0.row, serverSeq: $0.serverSeq) })
    }

    // MARK: Test inspection

    var headSeq: Int64 { seq }

    func currentRow(table: String, rowID: String) -> SyncRow? {
        tables[table]?[rowID]?.row
    }

    func rowCount(table: String) -> Int {
        tables[table]?.count ?? 0
    }
}
