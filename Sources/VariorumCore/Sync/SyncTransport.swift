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
    ///
    /// `activeKeyID` (Phase 14c, THE DESIGN item 2 — the vault-key-id
    /// fence): the corpus key id this device's round seals with, compared
    /// server-side against the account's current `key_vault` row. A
    /// mismatch refuses the WHOLE round (`SyncError.encryptionKeysReplaced`
    /// — the CF-16 state), so a stale writer can never poison-push past a
    /// re-key. A REQUIRED parameter on the protocol, deliberately no
    /// default — wrappers forward, fakes enforce (the schemaVersion
    /// doctrine below): a wrapper that silently dropped the key id would
    /// bypass the fence in every test that composes it.
    func push(_ batch: [SyncRow], activeKeyID: String) async throws -> [SyncPushOutcome]

    /// Rows changed after `since`, ordered by `server_seq`, at most `limit`.
    /// State-based: each row appears once, in its current state, stamped
    /// with its latest seq — never an op log. `activeKeyID` as on `push`
    /// (both round halves are fenced).
    func pull(since: Int64, limit: Int, activeKeyID: String) async throws -> [SyncPulledRow]

    /// The mirror's deployed schema-version marker (SyncSpec §12's
    /// version-check mechanism — shipped with the Phase 11 lockstep event,
    /// the first post-sync migration to need it). The engine compares this
    /// against `SyncSchema.lockstepVersion` at the start of every round
    /// half and REFUSES on any mismatch (outbox intact, cursor unmoved).
    /// A pre-marker deployment (the 9c-era mirror, no `sync_meta` table)
    /// reports version 1. A hard protocol requirement, deliberately no
    /// default: wrappers forward, fakes declare — a transport that cannot
    /// answer must not sync.
    func schemaVersion() async throws -> Int
}
