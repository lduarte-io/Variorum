import Foundation
import GRDB

/// Curated reading membership: a post may live in many readings at once.
public struct ReadingPost: VariorumRecord {
    public static let databaseTableName = "reading_post"

    public var id: String
    public var readingId: String
    /// `container.id` where kind='post' (enforced by operations, Phase 2).
    public var postId: String
    /// Fractional-index key (AppSpec §6).
    public var position: String
    public var createdAt: Date
    public var deletedAt: Date?
    public var syncVersion: Int

    public init(
        id: String,
        readingId: String,
        postId: String,
        position: String,
        createdAt: Date,
        deletedAt: Date? = nil,
        syncVersion: Int = 0
    ) {
        self.id = id
        self.readingId = readingId
        self.postId = postId
        self.position = position
        self.createdAt = createdAt
        self.deletedAt = deletedAt
        self.syncVersion = syncVersion
    }
}
