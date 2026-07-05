import Foundation
import GRDB

/// Tag application to a block — cheap, primarily serving the pool.
public struct BlockTag: VariorumRecord {
    public static let databaseTableName = "block_tag"

    public var id: String
    public var tagId: String
    public var blockId: String
    public var createdAt: Date
    public var deletedAt: Date?
    public var syncVersion: Int

    public init(
        id: String,
        tagId: String,
        blockId: String,
        createdAt: Date,
        deletedAt: Date? = nil,
        syncVersion: Int = 0
    ) {
        self.id = id
        self.tagId = tagId
        self.blockId = blockId
        self.createdAt = createdAt
        self.deletedAt = deletedAt
        self.syncVersion = syncVersion
    }
}
