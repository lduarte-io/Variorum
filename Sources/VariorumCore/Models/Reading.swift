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
    /// Declared "done" — reversible. Since 13i this is FINISHED (sitting
    /// record §5: the assembly frozen, intake paused, text still editable).
    public var locked: Bool
    // ——— the 13i-a lockstep bundle (v1_18; sitting record §11) ———
    /// The wing this book lives on. '' = the virtual Home wing (R-13ia-2);
    /// books never span wings.
    public var wingId: String
    /// The shelf (Bookcase grouping). nil OR dangling = UNSHELVED (§19's
    /// ruling: unshelved books show at the top of All, in no shelf's solo).
    public var shelfId: String?
    /// Within-shelf hand position ("my order", §24): fractional index; nil =
    /// never placed — appends after every placed book. Starred floats first
    /// under ANY order; this column never encodes the star.
    public var shelfPosition: String?
    /// The one star (absorbs the old pin list, §7): floats the book to its
    /// shelf's top and joins the upper-left Starred section.
    public var starred: Bool
    /// The OWNED flag (§6; 13i-c's operations enforce; the §7 exclusivity
    /// repair converges races). Membership exclusivity, never containment.
    public var owned: Bool
    /// SEALED = Finished + text immutability (§5). The stamp is the
    /// exact-stamp key members' seals match for the unseal.
    public var sealedAt: Date?
    /// A gathering's hide-owned toggle (§6): nil = follow the global
    /// default (SHOW, badged); 0/1 explicit.
    public var hideOwned: Bool?
    /// The join dial (§4): how intake seats new matches. nil on gatherings.
    public var intakeSeating: IntakeSeating?
    /// The outflow (§4): notes minted inside this book get this tag.
    public var autoTagId: String?
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
        wingId: String = "",
        shelfId: String? = nil,
        shelfPosition: String? = nil,
        starred: Bool = false,
        owned: Bool = false,
        sealedAt: Date? = nil,
        hideOwned: Bool? = nil,
        intakeSeating: IntakeSeating? = nil,
        autoTagId: String? = nil,
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
        self.wingId = wingId
        self.shelfId = shelfId
        self.shelfPosition = shelfPosition
        self.starred = starred
        self.owned = owned
        self.sealedAt = sealedAt
        self.hideOwned = hideOwned
        self.intakeSeating = intakeSeating
        self.autoTagId = autoTagId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.syncVersion = syncVersion
    }

    public static let readingPosts = hasMany(ReadingPost.self)
}
