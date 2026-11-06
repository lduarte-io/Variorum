import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **VX-803 — the pinned group floats above the book's sort, in the ONE order
/// every book mode reads** (her rulings, `notes/plans/fixes/vx-808-arrivals-books.md`
/// §3: *"SEVERAL pins allowed; the pinned group floats on top and orders among
/// itself by the book's own sort"*; *"pins hold EVERYWHERE — Outline, Index,
/// Book, Read and the ⌘↑/⌘↓ stepper alike"*).
///
/// The float lives in `Queries.assembleReading`'s ORDER BY and nowhere else
/// (the B4 record's §0 traces every consumer to it), so these pins are the
/// order's whole contract: under every `sort_field` and direction — stored or
/// the A31 view-local override — the entries are the UNPINNED assembly
/// stably partitioned, pinned first. That is exactly "orders among itself by
/// the book's own sort", stated without re-deriving any sort here.
///
/// The pins are set by a direct row write (an instrument): the order is the
/// query's contract, independent of the op that writes the mark
/// (`MembershipPinOperationTests` pins that).
///
/// New capability: no red-on-old exists for an order term over a column no
/// pre-fix code wrote — these are characterization pins of the ruled order.
@Suite("VX-803 — pinned memberships float above the book's sort")
struct MembershipPinOrderTests {
    /// Five notes A…E added in that order (so manual = A B C D E), each with
    /// its own stamps written explicitly so every stamp sort is a DIFFERENT
    /// order than the manual one — and one note (D) has never crossed a major
    /// revision (the stamp sorts' nulls-last arm).
    struct World {
        let book: Reading
        let ids: [String]  // A, B, C, D, E
        var a: String { ids[0] }
        var b: String { ids[1] }
        var c: String { ids[2] }
        var d: String { ids[3] }
        var e: String { ids[4] }
    }

    private static func world(
        _ ops: Operations, _ db: AppDatabase,
        sortField: SortField = .manual, sortDir: SortDirection = .asc
    ) throws -> World {
        let book = try ops.createReading(
            name: "pins", kind: .book, sortField: sortField, sortDir: sortDir)
        var ids: [String] = []
        for title in ["A", "B", "C", "D", "E"] {
            let post = try ops.createPost(title: title)
            try ops.addPostToReading(post.id, to: book.id)
            ids.append(post.id)
        }
        // (entry_date, created_at, last_touched_at, last_major_revision_at)
        let stamps: [(String?, String, String, String?)] = [
            ("2026-07-04", "2026-07-02T12:00:00.000Z", "2026-07-25T12:00:00.000Z", "2026-07-13T12:00:00.000Z"),
            (nil, "2026-07-05T12:00:00.000Z", "2026-07-21T12:00:00.000Z", "2026-07-11T12:00:00.000Z"),
            ("2026-07-01", "2026-07-04T12:00:00.000Z", "2026-07-23T12:00:00.000Z", "2026-07-15T12:00:00.000Z"),
            ("2026-07-03", "2026-07-01T12:00:00.000Z", "2026-07-24T12:00:00.000Z", nil),
            (nil, "2026-07-03T12:00:00.000Z", "2026-07-22T12:00:00.000Z", "2026-07-12T12:00:00.000Z"),
        ]
        try db.write { db in
            for (id, s) in zip(ids, stamps) {
                try db.execute(
                    sql: """
                        UPDATE container
                        SET entry_date = ?, created_at = ?, last_touched_at = ?,
                            last_major_revision_at = ?
                        WHERE id = ?
                        """,
                    arguments: [s.0, s.1, s.2, s.3, id])
            }
        }
        return World(book: book, ids: ids)
    }

    /// The instrument: pin these members of the book (a since-when stamp each,
    /// deliberately NOT in the sort's order — the stamp is never an ordering key).
    private static func pin(_ db: AppDatabase, _ book: Reading, _ postIDs: [String]) throws {
        try db.write { db in
            for (i, id) in postIDs.enumerated() {
                try db.execute(
                    sql: """
                        UPDATE reading_post SET pinned_at = ?
                        WHERE reading_id = ? AND post_id = ? AND deleted_at IS NULL
                        """,
                    arguments: ["2026-08-0\(9 - i)T12:00:00.000Z", book.id, id])
            }
        }
    }

    private static func order(
        _ db: AppDatabase, _ book: Reading, _ order: Queries.ReadingOrder? = nil
    ) throws -> [Queries.ReadingEntry] {
        try db.read { try Queries.assembleReading($0, readingID: book.id, order: order) }
    }

    /// "Orders among itself by the book's own sort", as a value: the unpinned
    /// assembly, stably partitioned pinned-first.
    private static func floated(_ baseline: [String], pinned: Set<String>) -> [String] {
        baseline.filter { pinned.contains($0) } + baseline.filter { !pinned.contains($0) }
    }

    // MARK: - Manual order

    /// Under manual order the pinned group orders by `(position, id)` among
    /// itself, and the unpinned tail keeps its own `(position, id)` order.
    @Test func inAHandOrderedBookThePinnedGroupLeadsInItsOwnHandOrder() throws {
        try withOperations { ops, db in
            let w = try Self.world(ops, db)
            #expect(try Self.order(db, w.book).map(\.postID) == [w.a, w.b, w.c, w.d, w.e])
            try Self.pin(db, w.book, [w.e, w.c])
            let entries = try Self.order(db, w.book)
            #expect(entries.map(\.postID) == [w.c, w.e, w.a, w.b, w.d],
                    "C and E float, C before E (their hand order) — never by pin time")
            #expect(entries.map(\.pinned) == [true, true, false, false, false],
                    "each entry carries its pin fact from the same row")
        }
    }

    /// No pin anywhere: the order is byte-identical to the unpinned book's, and
    /// no entry claims a pin.
    @Test func aBookWithNoPinsReadsExactlyAsBefore() throws {
        try withOperations { ops, db in
            let w = try Self.world(ops, db)
            let entries = try Self.order(db, w.book)
            #expect(entries.map(\.postID) == w.ids)
            #expect(entries.allSatisfy { !$0.pinned })
        }
    }

    /// Every note pinned is the same order as none pinned — the group IS the
    /// book, ordered by the book's own sort.
    @Test func pinningEveryNoteChangesNothingAboutTheOrder() throws {
        try withOperations { ops, db in
            let w = try Self.world(ops, db)
            try Self.pin(db, w.book, w.ids)
            #expect(try Self.order(db, w.book).map(\.postID) == w.ids)
        }
    }

    // MARK: - Every sort field, both directions, stored and looked-through

    static let stampFields: [SortField] = [.entryDate, .createdAt, .lastTouched, .lastMajorRevision]

    /// The STORED sort (`setReadingSort`): the pinned group and the tail each
    /// order by the book's own sort.
    @Test(arguments: stampFields, [SortDirection.asc, .desc])
    func underEveryStoredSortThePinnedGroupOrdersByThatSort(
        field: SortField, direction: SortDirection
    ) throws {
        try withOperations { ops, db in
            let w = try Self.world(ops, db, sortField: field, sortDir: direction)
            let baseline = try Self.order(db, w.book).map(\.postID)
            // The fixture's stamps make the sort a real order, not the hand one
            // (else this would prove nothing about "by the sort").
            #expect(baseline != w.ids || field == .entryDate && direction == .asc,
                    "the fixture's \(field) \(direction) order differs from the hand order")
            try Self.pin(db, w.book, [w.b, w.d, w.e])
            let entries = try Self.order(db, w.book)
            #expect(entries.map(\.postID)
                    == Self.floated(baseline, pinned: [w.b, w.d, w.e]),
                    "\(field) \(direction): pinned first, each group by the sort")
            #expect(entries.map(\.pinned) == [true, true, true, false, false])
        }
    }

    /// The A31 view-local OVERRIDE ("a way of looking") floats the same way:
    /// the pinned group orders by the order she is looking through, and
    /// browsing still shows exactly what saving would show.
    @Test(arguments: stampFields, [SortDirection.asc, .desc])
    func lookingThroughAnyOrderTheFloatHoldsAndBrowsingShowsWhatSavingWould(
        field: SortField, direction: SortDirection
    ) throws {
        try withOperations { ops, db in
            let w = try Self.world(ops, db)
            let look = Queries.ReadingOrder(field: field, direction: direction)
            let baseline = try Self.order(db, w.book, look).map(\.postID)
            try Self.pin(db, w.book, [w.a, w.c])
            let browsed = try Self.order(db, w.book, look).map(\.postID)
            #expect(browsed == Self.floated(baseline, pinned: [w.a, w.c]))
            try ops.setReadingSort(w.book.id, field: field, direction: direction)
            #expect(try Self.order(db, w.book).map(\.postID) == browsed,
                    "A31's promise survives the float: the saved order reads as the browsed one")
        }
    }

    /// Manual looked-through on a stamp-sorted book: back to `(position, id)`
    /// in each group.
    @Test func lookingThroughManualOrdersEachGroupByHand() throws {
        try withOperations { ops, db in
            let w = try Self.world(ops, db, sortField: .createdAt, sortDir: .desc)
            try Self.pin(db, w.book, [w.d, w.b])
            let entries = try Self.order(db, w.book, .init(field: .manual, direction: .asc))
            #expect(entries.map(\.postID) == [w.b, w.d, w.a, w.c, w.e])
        }
    }

    // MARK: - Chapters (the B4 fork's (e) — PROVISIONAL P-808-B4-2)

    /// In a chaptered book chapters stay the frame: a pin floats to the top of
    /// ITS chapter (and of the unfiled group), never above the chapters.
    @Test func inAChapteredBookAPinFloatsWithinItsOwnChapter() throws {
        try withOperations { ops, db in
            let w = try Self.world(ops, db)
            let one = try ops.createSection(in: w.book.id, name: "one")
            let two = try ops.createSection(in: w.book.id, name: "two")
            // one: A B   two: C D   unfiled: E
            for id in [w.a, w.b] { try ops.assignPostToSection(id, in: w.book.id, section: one.id) }
            for id in [w.c, w.d] { try ops.assignPostToSection(id, in: w.book.id, section: two.id) }
            try Self.pin(db, w.book, [w.b, w.d, w.e])
            let entries = try Self.order(db, w.book)
            #expect(entries.map(\.postID) == [w.b, w.a, w.d, w.c, w.e])
            #expect(entries.map(\.sectionID) == [one.id, one.id, two.id, two.id, nil])
            #expect(entries.map(\.pinned) == [true, false, true, false, true])
        }
    }

    // MARK: - The cap and the filter ride the one order

    /// A capped book (`max_posts` lowered below membership — legal) shows the
    /// first N of the ONE order, so the pinned group is what the cap keeps
    /// first: the reader, the counts and the stepper all see the same N.
    @Test func aCappedBookCapsTheFloatedOrder() throws {
        try withOperations { ops, db in
            let w = try Self.world(ops, db)
            try Self.pin(db, w.book, [w.e])
            try ops.setReadingMaxPosts(w.book.id, maxPosts: 2)
            #expect(try Self.order(db, w.book).map(\.postID) == [w.e, w.a])
        }
    }

    /// The in-book filter narrows the floated order; it never re-sorts it.
    @Test func theInBookFilterKeepsTheFloat() throws {
        try withOperations { ops, db in
            let w = try Self.world(ops, db)
            let tag = try ops.createTag(name: "kept")
            for id in [w.a, w.c, w.e] { try ops.applyTag(tag.id, toPost: id) }
            try Self.pin(db, w.book, [w.e])
            let entries = try db.read {
                try Queries.assembleReading($0, readingID: w.book.id, filter: .tag(tag.id))
            }
            #expect(entries.map(\.postID) == [w.e, w.a, w.c])
        }
    }

    // MARK: - Arrivals seat below the pinned group

    /// Arrivals' seat-at-the-end (`seatArrival` — `readingPosition(.end)`) lands
    /// a seated note at the END OF THE UNPINNED TAIL, below the pinned group,
    /// by construction: the seat writes a position after every row and the
    /// seated row carries no pin.
    @Test func aSeatedArrivalLandsAtTheTailsEndBelowThePinnedGroup() throws {
        try withOperations { ops, db in
            let w = try Self.world(ops, db)
            try Self.pin(db, w.book, [w.c])
            let waiting = try ops.createPost(title: "waiting")
            try db.write { db in
                let last = try String.fetchOne(
                    db, sql: "SELECT MAX(position) FROM reading_post WHERE reading_id = ?",
                    arguments: [w.book.id])
                try db.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                        VALUES ('arrival-pin', ?, ?, ?, 'arrival', '2026-07-01T00:00:00.000Z')
                        """,
                    arguments: [w.book.id, waiting.id, FractionalIndex.between(last, nil)])
            }
            #expect(!(try Self.order(db, w.book).map(\.postID)).contains(waiting.id),
                    "a waiting arrival is never in the book's order")
            try ops.seatArrival("arrival-pin")
            let entries = try Self.order(db, w.book)
            #expect(entries.map(\.postID) == [w.c, w.a, w.b, w.d, w.e, waiting.id])
            #expect(entries.last?.pinned == false)
        }
    }

    // MARK: - Gatherings never float

    /// A gathering holds no membership rows: no entry is ever pinned, and its
    /// order is its rule's.
    @Test func aGatheringNeverFloats() throws {
        try withOperations { ops, db in
            let w = try Self.world(ops, db)
            let tag = try ops.createTag(name: "all")
            for id in w.ids { try ops.applyTag(tag.id, toPost: id) }
            try Self.pin(db, w.book, [w.e])
            let rule = try #require(try RuleGrammar.encode(.tag(tag.id)))
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, sortField: .createdAt, sortDir: .asc,
                querySpec: rule)
            let entries = try db.read { try Queries.assembleReading($0, readingID: gathering.id) }
            #expect(entries.map(\.postID) == [w.d, w.a, w.e, w.c, w.b],
                    "the gathering's own created-at order; the book's pin is the BOOK's")
            #expect(entries.allSatisfy { !$0.pinned })
        }
    }
}
