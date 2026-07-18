import Foundation
import GRDB

/// A chapter: a first-class, reorderable grouping of posts within one book
/// (Phase 13, v1_10 — rulings R28/R50; the sitting-1 BOOKS REVERSAL:
/// "actual books with posts in a particular order and real chapter
/// groupings you can reorder"). Ordered by fractional-index `position`
/// within its reading; no nesting (R28's letter — "we don't need nesting
/// readings for now"); no natural key (duplicate chapter names are legal).
///
/// Membership is the OTHER half: `reading_post.section_id` points here
/// (R50 — reading_post = which book; section_id = which chapter). A
/// dangling pointer reads as unsectioned; deleting a chapter never touches
/// the posts.
public struct ReadingSection: VariorumRecord {
    public static let databaseTableName = "reading_section"

    public var id: String
    public var readingId: String
    public var name: String
    /// Fractional-index key (AppSpec §6).
    public var position: String
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?
    public var syncVersion: Int

    public init(
        id: String,
        readingId: String,
        name: String,
        position: String,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date? = nil,
        syncVersion: Int = 0
    ) {
        self.id = id
        self.readingId = readingId
        self.name = name
        self.position = position
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.syncVersion = syncVersion
    }
}
