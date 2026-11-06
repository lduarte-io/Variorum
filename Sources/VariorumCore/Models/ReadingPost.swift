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
    /// The membership's chapter (Phase 13, v1_10 — R50: reading_post =
    /// which book; section_id = which chapter within it). Nullable =
    /// unsectioned; a DANGLING pointer (tombstoned section) also reads as
    /// unsectioned — the chosen-variant fallback class.
    public var sectionId: String?
    public var createdAt: Date
    public var deletedAt: Date?
    public var syncVersion: Int
    /// 13i-a (v1_18): member = seated membership (truth, counted, ordered);
    /// arrival = intake's bell waiting at the door (sitting record §4).
    public var status: MembershipStatus
    /// VX-808 (v1_37 — the run record `notes/plans/fixes/vx-808-arrivals-books.md`
    /// §5): WHY an ARRIVAL waits — canonical JSON (`ArrivalProvenance`), read
    /// only on a LIVE ARRIVAL row; NULL = an arrival older than the column.
    /// Every road that mints or re-poses an arrival writes it; ENCRYPTED under
    /// E2EE (an AI-authored reason is prose).
    public var arrivalProvenance: String?
    /// VX-803 (v1_37 — the run record §5, Unit B4): the membership PIN —
    /// non-nil = pinned, the stamp doubling as since-when. Meaningful on a live
    /// MEMBER row: a pinned membership floats above the book's sort, the pinned
    /// group ordering among itself by that same sort (`Queries.assembleReading`
    /// — the ONE order every book mode reads). Written only by
    /// `Operations.setMembershipPinned` and carried by the exact-slot copies.
    /// PLAIN under E2EE (a bare timestamp).
    public var pinnedAt: Date?

    public init(
        id: String,
        readingId: String,
        postId: String,
        position: String,
        sectionId: String? = nil,
        status: MembershipStatus = .member,
        createdAt: Date,
        deletedAt: Date? = nil,
        syncVersion: Int = 0,
        arrivalProvenance: String? = nil,
        pinnedAt: Date? = nil
    ) {
        self.id = id
        self.readingId = readingId
        self.postId = postId
        self.position = position
        self.sectionId = sectionId
        self.status = status
        self.createdAt = createdAt
        self.deletedAt = deletedAt
        self.syncVersion = syncVersion
        self.arrivalProvenance = arrivalProvenance
        self.pinnedAt = pinnedAt
    }
}
