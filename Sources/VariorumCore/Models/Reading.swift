import Foundation
import GRDB

/// A book / chapter / on-demand collection: an ordered pointer list over
/// posts. Posts are non-exclusively pointed at — the deliberate asymmetry
/// with blocks that makes on-demand books work (OverallModel §2).
public struct Reading: VariorumRecord {
    public static let databaseTableName = "reading"

    public var id: String
    public var ownerId: String?
    public var name: String
    public var kind: ReadingKind
    /// 'journal' | 'book' | 'collection' — informal vocabulary, deliberately
    /// un-CHECKed (unlike `Container.profile`).
    public var profile: String?
    public var sortField: SortField
    public var sortDir: SortDirection
    /// Section the book by a hierarchical tag root.
    public var groupingTagId: String?
    /// JSON predicate for smart readings.
    public var querySpec: String?
    /// Extent constraint (e.g. a fixed-length journal).
    public var maxPosts: Int?
    /// The words-based extent TARGET (Phase 13, v1_11 — bounded-length
    /// notebooks, §14 item 10). Display/progress semantics only: never an
    /// add-time refusal (edits change word counts; membership can't
    /// enforce them). nil = unbounded.
    public var wordTarget: Int?
    /// Declared "done" — reversible.
    public var locked: Bool
    public var createdAt: Date
    public var updatedAt: Date
    public var deletedAt: Date?
    public var syncVersion: Int

    public init(
        id: String,
        ownerId: String? = nil,
        name: String,
        kind: ReadingKind,
        profile: String? = nil,
        sortField: SortField = .manual,
        sortDir: SortDirection = .asc,
        groupingTagId: String? = nil,
        querySpec: String? = nil,
        maxPosts: Int? = nil,
        wordTarget: Int? = nil,
        locked: Bool = false,
        createdAt: Date,
        updatedAt: Date,
        deletedAt: Date? = nil,
        syncVersion: Int = 0
    ) {
        self.id = id
        self.ownerId = ownerId
        self.name = name
        self.kind = kind
        self.profile = profile
        self.sortField = sortField
        self.sortDir = sortDir
        self.groupingTagId = groupingTagId
        self.querySpec = querySpec
        self.maxPosts = maxPosts
        self.wordTarget = wordTarget
        self.locked = locked
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.syncVersion = syncVersion
    }

    public static let readingPosts = hasMany(ReadingPost.self)
}
