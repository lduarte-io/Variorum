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
    }

    /// table → rowID → current state. Rows are never removed: a tombstone is
    /// an ordinary accepted update (S2).
    private var tables: [String: [String: StoredRow]] = [:]
    private var seq: Int64 = 0

    // MARK: SyncTransport

    func push(_ batch: [SyncRow]) throws -> [SyncPushOutcome] {
        try batch.map { incoming in
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
                StoredRow(row: normalized, serverSeq: seq)
            return .accepted(newVersion: accepted.syncVersion, serverSeq: seq)
        }
    }

    func pull(since: Int64, limit: Int) -> [SyncPulledRow] {
        Array(
            tables.values
                .flatMap { $0.values }
                .filter { $0.serverSeq > since }
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
