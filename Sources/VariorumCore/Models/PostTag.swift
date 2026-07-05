import Foundation
import GRDB

/// Tag application to a post. Two tables (post_tag/block_tag) instead of one
/// polymorphic `tagging` so foreign keys are real (AppSpec §7 delta).
public struct PostTag: VariorumRecord {
    public static let databaseTableName = "post_tag"

    public var id: String
    public var tagId: String
    /// `container.id` where kind='post' (enforced by operations, Phase 2).
    public var postId: String
    public var createdAt: Date
    public var deletedAt: Date?
    public var syncVersion: Int

    public init(
        id: String,
        tagId: String,
        postId: String,
        createdAt: Date,
        deletedAt: Date? = nil,
        syncVersion: Int = 0
    ) {
        self.id = id
        self.tagId = tagId
        self.postId = postId
        self.createdAt = createdAt
        self.deletedAt = deletedAt
        self.syncVersion = syncVersion
    }
}
