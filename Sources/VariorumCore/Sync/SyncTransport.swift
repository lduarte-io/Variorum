import Foundation

/// One pulled row: the server-current payload (`row.syncVersion` = the
/// server's current version) plus the `server_seq` stamped when the server
/// last accepted a change to it. `server_seq` is the ONLY ordering authority
/// in the protocol (SyncSpec §9).
public struct SyncPulledRow: Equatable, Sendable, Codable {
    public let row: SyncRow
    public let serverSeq: Int64

    public init(row: SyncRow, serverSeq: Int64) {
        self.row = row
        self.serverSeq = serverSeq
    }
}

/// Per-row push verdict (SyncSpec §4). The server merges nothing: accept is
/// a compare-and-set (`base == current sync_version`), reject carries the
/// current server row so the client can merge deterministically and push
/// again. `rejected(current: nil)` is the degenerate mismatch where the
/// server has no row at all for a non-zero base.
public enum SyncPushOutcome: Equatable, Sendable {
    case accepted(newVersion: Int, serverSeq: Int64)
    case rejected(current: SyncPulledRow?)
}

/// The transport seam (SyncSpec §2): exactly two endpoints. The in-process
/// fake server (test support) and the Supabase RPC client are two
/// implementations of this one protocol — the engine never knows which it
/// is talking to.
public protocol SyncTransport: Sendable {
    /// Pushes a batch; the result array is per-row, index-aligned with the
    /// batch. Each `SyncRow.syncVersion` is the CAS base (the row's last
    /// server-accepted version; 0 for never-accepted rows).
    func push(_ batch: [SyncRow]) async throws -> [SyncPushOutcome]

    /// Rows changed after `since`, ordered by `server_seq`, at most `limit`.
    /// State-based: each row appears once, in its current state, stamped
    /// with its latest seq — never an op log.
    func pull(since: Int64, limit: Int) async throws -> [SyncPulledRow]
}
