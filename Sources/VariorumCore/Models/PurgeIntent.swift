import Foundation
import GRDB

/// **The purge intent** (Phase 13j batch 6b — the memo's §5a, her round-8
/// pre-authorization): one synced row per thing being physically purged.
/// "This is going, everywhere" — Delete Now / Empty Trash mint them for
/// Trash rows, the savepoint-pruning pass mints them for prunable quiet
/// savepoints, and the janitor tombstones them when the purge completes.
///
/// `tableName`/`rowId` name the ROOT of the family to purge (container /
/// reading / block / variant / commit_point); the family expansion is the
/// client's (`PurgeFamily` — the server stays dumb, SyncSpec §2). All
/// columns are PLAIN under E2EE: ids and enums only, no user words by
/// design.
///
/// Deliberately no FK on the named row — the row it names is exactly the
/// row the janitor will physically DELETE.
public struct PurgeIntent: VariorumRecord {
    public static let databaseTableName = "purge_intent"

    public var id: String
    public var ownerId: String?
    /// 'container' | 'reading' | 'block' | 'variant' | 'commit_point' |
    /// 'block_comment' (VX-179's "Delete forever…" in the comments panel)
    /// (enforced by `Operations.requestPurge`, never by CHECK — the memo's
    /// §5a DDL carries no constraint so sync application can never refuse
    /// a future kind it has a local home for).
    public var tableName: String
    public var rowId: String
    /// ISO-8601, display/audit only — NEVER ordering (SyncSpec §9).
    public var requestedAt: Date
    public var createdAt: Date
    public var updatedAt: Date
    /// Tombstoned when the janitor completes the purge. A tombstoned
    /// intent still HIDES its named row from every surface (the fence
    /// reads intents regardless of state — purged stays purged).
    public var deletedAt: Date?
    public var syncVersion: Int

    public init(
        id: String,
        ownerId: String? = nil,
        tableName: String,
        rowId: String,
        requestedAt: Date,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date? = nil,
        syncVersion: Int = 0
    ) {
        self.id = id
        self.ownerId = ownerId
        self.tableName = tableName
        self.rowId = rowId
        self.requestedAt = requestedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.syncVersion = syncVersion
    }
}
