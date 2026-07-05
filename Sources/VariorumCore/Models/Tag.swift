import Foundation
import GRDB

/// Hierarchical, path-style tag. `path` (e.g. 'life/goals/2024') is the ONE
/// deliberate denormalization in the model — parent names copied downward;
/// `renameTag` (Phase 2) rewrites the subtree's paths in one transaction.
public struct Tag: VariorumRecord {
    public static let databaseTableName = "tag"

    public var id: String
    public var ownerId: String?
    public var parentId: String?
    public var name: String
    public var path: String
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?
    public var syncVersion: Int

    public init(
        id: String,
        ownerId: String? = nil,
        parentId: String? = nil,
        name: String,
        path: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date? = nil,
        syncVersion: Int = 0
    ) {
        self.id = id
        self.ownerId = ownerId
        self.parentId = parentId
        self.name = name
        self.path = path
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.syncVersion = syncVersion
    }

    public static let children = hasMany(Tag.self, using: ForeignKey(["parent_id"]))
}
