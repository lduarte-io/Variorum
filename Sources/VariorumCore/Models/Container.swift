import Foundation
import GRDB

/// Posts and pools, unified (AppSpec §7): one table so the single live-unique
/// ownership index on `container_block.block_id` enforces I2 uniformly, and
/// "scrap" and "finished prose" are one object type. Pool rows leave
/// post-specific columns NULL.
public struct Container: VariorumRecord {
    public static let databaseTableName = "container"

    public var id: String
    public var ownerId: String?
    public var kind: ContainerKind
    public var title: String?
    public var profile: Profile?
    /// Posts (esp. journals): the ordering key. A calendar day as
    /// `"YYYY-MM-DD"` — deliberately a string, not a `Date`: an entry date has
    /// no time-of-day or timezone semantics, and the format sorts correctly
    /// as TEXT.
    public var entryDate: String?
    /// The post-level seal / "complete" — reversible (I6 applies here too).
    public var locked: Bool
    public var lockedAt: Date?
    /// Free-floating per-post notes area.
    public var floatingNotes: String?
    /// Per-post override of the global `default_segmentation` setting.
    public var segmentationDefault: Segmentation?
    /// The per-POST words-based extent TARGET (13b Stage 4, v1_12 — S4-28.1;
    /// `reading.word_target`'s twin). Display/progress semantics only:
    /// never an add/type-time refusal. nil = no target.
    public var wordTarget: Int?
    /// Any keystroke (sort: noisy).
    public var lastTouchedAt: Date?
    /// Crossed the churn threshold (sort: meaningful) — AppSpec §10.
    public var lastMajorRevisionAt: Date?
    public var churnAccumulator: Double
    public var baselineLength: Int
    public var createdAt: Date
    public var updatedAt: Date
    public var archivedAt: Date?
    public var deletedAt: Date?
    public var syncVersion: Int

    public init(
        id: String,
        ownerId: String? = nil,
        kind: ContainerKind,
        title: String? = nil,
        profile: Profile? = nil,
        entryDate: String? = nil,
        locked: Bool = false,
        lockedAt: Date? = nil,
        floatingNotes: String? = nil,
        segmentationDefault: Segmentation? = nil,
        wordTarget: Int? = nil,
        lastTouchedAt: Date? = nil,
        lastMajorRevisionAt: Date? = nil,
        churnAccumulator: Double = 0,
        baselineLength: Int = 0,
        createdAt: Date,
        updatedAt: Date,
        archivedAt: Date? = nil,
        deletedAt: Date? = nil,
        syncVersion: Int = 0
    ) {
        self.id = id
        self.ownerId = ownerId
        self.kind = kind
        self.title = title
        self.profile = profile
        self.entryDate = entryDate
        self.locked = locked
        self.lockedAt = lockedAt
        self.floatingNotes = floatingNotes
        self.segmentationDefault = segmentationDefault
        self.wordTarget = wordTarget
        self.lastTouchedAt = lastTouchedAt
        self.lastMajorRevisionAt = lastMajorRevisionAt
        self.churnAccumulator = churnAccumulator
        self.baselineLength = baselineLength
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.archivedAt = archivedAt
        self.deletedAt = deletedAt
        self.syncVersion = syncVersion
    }

    public static let containerBlocks = hasMany(ContainerBlock.self)
}
