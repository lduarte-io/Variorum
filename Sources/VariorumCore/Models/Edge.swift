import Foundation
import GRDB

/// Typed block-to-block relationship — the whole lineage system is
/// `(fromBlock, toBlock, type)`: coarse, not forensic. `derivedFrom` reads
/// "source is derived from target" (target = ancestor). `versionOf` is
/// undirected; the operations layer stores it canonically as
/// `(min(id), max(id))` so devices converge (SyncSpec §7).
public struct Edge: VariorumRecord {
    public static let databaseTableName = "edge"

    public var id: String
    public var sourceBlockId: String
    public var targetBlockId: String
    public var type: EdgeType
    /// Which operation minted this edge: 'divide' | 'merge' | 'extract' |
    /// 'pool_copy' | 'manual' | nil. Deliberately un-CHECKed in the schema;
    /// the Phase 2 operations own the vocabulary.
    public var originOp: String?
    public var createdAt: Date
    public var deletedAt: Date?
    public var syncVersion: Int

    public init(
        id: String,
        sourceBlockId: String,
        targetBlockId: String,
        type: EdgeType,
        originOp: String? = nil,
        createdAt: Date,
        deletedAt: Date? = nil,
        syncVersion: Int = 0
    ) {
        self.id = id
        self.sourceBlockId = sourceBlockId
        self.targetBlockId = targetBlockId
        self.type = type
        self.originOp = originOp
        self.createdAt = createdAt
        self.deletedAt = deletedAt
        self.syncVersion = syncVersion
    }
}
