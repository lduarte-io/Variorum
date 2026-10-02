import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **13i-d U1 — THE BOOKCASE'S SHELVES, core half** (the sitting record §7,
/// §19, §20, §24; the plan's U1 RECORD, E1/E2). The shelf operations did not
/// exist before this unit (F-U1-1), so every pin here is a state-transition
/// pin over a new op — and the arithmetic pins (`placementWrites`) are the
/// pure brain both the op and the board read.
@Suite("Bookcase shelves — operations (13i-d U1)")
struct BookcaseShelfOperationsTests {
    private func strip(_ db: AppDatabase, wing: String = "") throws -> [String] {
        try db.read { try Queries.shelves($0, wingID: wing).map(\.name) }
    }

    private func reading(_ db: AppDatabase, _ id: String) throws -> Reading {
        try #require(try db.read { try Reading.fetchOne($0, key: id) })
    }

    private func mintWing(_ db: AppDatabase, id: String = "w2") throws {
        try db.write { db in
            try db.execute(sql: """
                INSERT INTO wing (id, name, position, created_at, updated_at)
                VALUES (?, 'Work', 'U', '2026-07-01T00:00:00.000Z', '2026-07-01T00:00:00.000Z')
                """, arguments: [id])
        }
    }

    @Test func aNewShelfAppendsToItsWingsStripAndANameIsRequired() throws {
        try withOperations { ops, db in
            _ = try ops.createShelf(name: "  The Work  ")
            _ = try ops.createShelf(name: "Ideas")
            _ = try ops.createShelf(name: "Ideas")  // duplicates are legal (no natural key)
            #expect(try strip(db) == ["The Work", "Ideas", "Ideas"], "trimmed; appended in order")
            #expect(throws: OperationError.invalidShelfName(name: "   ")) {
                try ops.createShelf(name: "   ")
            }
            #expect(throws: OperationError.wingNotFound(id: "nope")) {
                try ops.createShelf(name: "Elsewhere", wingID: "nope")
            }
            try mintWing(db)
            _ = try ops.createShelf(name: "Elsewhere", wingID: "w2")
            #expect(try strip(db) == ["The Work", "Ideas", "Ideas"], "shelves are per-wing")
            #expect(try strip(db, wing: "w2") == ["Elsewhere"])
        }
    }

    @Test func renameTrimsAndANoOpWritesNothing() throws {
        try withOperations { ops, db in
            let shelf = try ops.createShelf(name: "Welcome")
            try ops.renameShelf(shelf.id, to: " Front Room ")
            let renamed = try #require(try db.read { try Shelf.fetchOne($0, key: shelf.id) })
            #expect(renamed.name == "Front Room")
            try ops.renameShelf(shelf.id, to: "Front Room")
            let again = try #require(try db.read { try Shelf.fetchOne($0, key: shelf.id) })
            #expect(again.updatedAt == renamed.updatedAt, "a no-op rename writes nothing")
            #expect(throws: OperationError.invalidShelfName(name: "")) {
                try ops.renameShelf(shelf.id, to: "")
            }
        }
    }

    /// §7: ONE grapheme, monochrome — "No emoji, no color."
    @Test func aGlyphIsOneGraphemeAndNeverAnEmoji() throws {
        try withOperations { ops, db in
            let shelf = try ops.createShelf(name: "Night")
            func glyph() throws -> String? {
                try db.read { try Shelf.fetchOne($0, key: shelf.id) }?.glyph
            }
            try ops.setShelfGlyph(shelf.id, glyph: " \u{263E} ")
            #expect(try glyph() == "\u{263E}", "☾ — trimmed and stored")
            try ops.setShelfGlyph(shelf.id, glyph: "\u{13080}")
            #expect(try glyph() == "\u{13080}", "a hieroglyph is a glyph")
            #expect(throws: OperationError.invalidShelfGlyph(value: "\u{1F4DA}")) {
                try ops.setShelfGlyph(shelf.id, glyph: "\u{1F4DA}")  // 📚
            }
            #expect(throws: OperationError.invalidShelfGlyph(value: "\u{2600}\u{FE0F}")) {
                try ops.setShelfGlyph(shelf.id, glyph: "\u{2600}\u{FE0F}")  // ☀️ (emoji-styled)
            }
            #expect(throws: OperationError.invalidShelfGlyph(value: "ab")) {
                try ops.setShelfGlyph(shelf.id, glyph: "ab")
            }
            #expect(try glyph() == "\u{13080}", "a refusal keeps what was there")
            try ops.setShelfGlyph(shelf.id, glyph: "  ")
            #expect(try glyph() == nil, "blank clears")
            try ops.setShelfGlyph(shelf.id, glyph: "\u{25C6}")
            try ops.setShelfGlyph(shelf.id, glyph: nil)
            #expect(try glyph() == nil, "nil clears")
        }
    }

    /// §19: "Deleting a shelf returns its books to UNSHELVED" — and never
    /// touches a book: the pointer is left dangling, which IS unshelved.
    @Test func deletingAShelfNeverTouchesItsBooks() throws {
        try withOperations { ops, db in
            let shelf = try ops.createShelf(name: "Work")
            let book = try ops.createReading(name: "draft", kind: .book, shelfId: shelf.id)
            let before = try reading(db, book.id)
            try ops.deleteShelf(shelf.id)
            let after = try reading(db, book.id)
            #expect(after == before, "the book row is untouched — byte for byte")
            #expect(try strip(db).isEmpty)
            let live = Set(try db.read { try Queries.shelves($0, wingID: "").map(\.id) })
            #expect(BookcaseOrdering.resolvedShelf(of: after, liveShelfIDs: live) == nil,
                    "the dangling pointer reads as UNSHELVED")
            #expect(throws: OperationError.shelfNotFound(id: shelf.id)) {
                try ops.deleteShelf(shelf.id)
            }
        }
    }

    /// §24: drag a name, or Move to Start / Move to End.
    @Test func movingAShelfReordersTheStrip() throws {
        try withOperations { ops, db in
            let a = try ops.createShelf(name: "A")
            let b = try ops.createShelf(name: "B")
            let c = try ops.createShelf(name: "C")
            try ops.moveShelf(c.id, to: .before(a.id))
            #expect(try strip(db) == ["C", "A", "B"])
            try ops.moveShelf(c.id, to: .end)
            #expect(try strip(db) == ["A", "B", "C"])
            try ops.moveShelf(a.id, to: .after(b.id))
            #expect(try strip(db) == ["B", "A", "C"])
            try ops.moveShelf(c.id, to: .start)
            #expect(try strip(db) == ["C", "B", "A"])
            try mintWing(db)
            let foreign = try ops.createShelf(name: "X", wingID: "w2")
            #expect(throws: OperationError.shelfNotFound(id: foreign.id)) {
                try ops.moveShelf(a.id, to: .before(foreign.id))
            }
        }
    }

    /// Re-shelving: the book arrives NEVER-PLACED (its old key was the old
    /// shelf's); a shelf of another wing refuses; a no-op writes nothing.
    @Test func reShelvingClearsTheHandPositionAndStaysInTheWing() throws {
        try withOperations { ops, db in
            let work = try ops.createShelf(name: "Work")
            let ideas = try ops.createShelf(name: "Ideas")
            _ = try ops.createReading(name: "an early one", kind: .book, shelfId: work.id)
            let book = try ops.createReading(name: "draft", kind: .book, shelfId: work.id)
            try ops.placeReading(book.id, at: .top)
            #expect(try reading(db, book.id).shelfPosition != nil, "placed by hand")
            try ops.setReadingShelf(book.id, shelf: ideas.id)
            #expect(try reading(db, book.id).shelfId == ideas.id)
            #expect(try reading(db, book.id).shelfPosition == nil, "arrives never-placed")

            try db.write { try $0.execute(sql: "DELETE FROM sync_outbox") }
            try ops.setReadingShelf(book.id, shelf: ideas.id)
            let queued = try db.read {
                try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM sync_outbox") ?? 0
            }
            #expect(queued == 0, "a no-op re-shelve writes nothing")

            try ops.setReadingShelf(book.id, shelf: nil)
            #expect(try reading(db, book.id).shelfId == nil, "nil = unshelved")

            try mintWing(db)
            let foreign = try ops.createShelf(name: "X", wingID: "w2")
            #expect(throws: OperationError.shelfNotFound(id: foreign.id)) {
                try ops.setReadingShelf(book.id, shelf: foreign.id)
            }
            // Shelving is presentation, not assembly: a finished book moves.
            try ops.lockReading(book.id)
            try ops.setReadingShelf(book.id, shelf: work.id)
            #expect(try reading(db, book.id).shelfId == work.id)
        }
    }

    /// §19.1/§24 — the CONTEXT MINT's op half: a book minted onto a shelf
    /// lands there never-placed; a dead shelf or another wing's refuses.
    @Test func aBookMintedOntoAShelfLandsThere() throws {
        try withOperations { ops, db in
            let work = try ops.createShelf(name: "Work")
            let book = try ops.createReading(name: "draft", kind: .book, shelfId: work.id)
            #expect(try reading(db, book.id).shelfId == work.id)
            #expect(try reading(db, book.id).shelfPosition == nil)
            let plain = try ops.createReading(name: "plain", kind: .book)
            #expect(try reading(db, plain.id).shelfId == nil, "every other door: unshelved (§19)")
            try ops.deleteShelf(work.id)
            #expect(throws: OperationError.shelfNotFound(id: work.id)) {
                try ops.createReading(name: "late", kind: .book, shelfId: work.id)
            }
            try mintWing(db)
            let foreign = try ops.createShelf(name: "X", wingID: "w2")
            #expect(throws: OperationError.shelfNotFound(id: foreign.id)) {
                try ops.createReading(name: "stray", kind: .book, shelfId: foreign.id)
            }
        }
    }

    // MARK: - "My order" — the placement op over the real store

    private func sequence(_ db: AppDatabase, shelf: String?) throws -> [String] {
        try db.read { db in
            let live = Set(try Queries.shelves(db, wingID: "").map(\.id))
            let mates = try Queries.readings(db).filter {
                BookcaseOrdering.resolvedShelf(of: $0, liveShelfIDs: live) == shelf
            }
            return BookcaseOrdering.placementSequence(mates).map(\.name)
        }
    }

    @Test func sendToTopBottomAndBeforeWalkTheOneSequence() throws {
        try withOperations { ops, db in
            let shelf = try ops.createShelf(name: "Work")
            var ids: [String: String] = [:]
            for name in ["alpha", "bravo", "charlie", "delta"] {
                ids[name] = try ops.createReading(name: name, kind: .book, shelfId: shelf.id).id
            }
            #expect(try sequence(db, shelf: shelf.id) == ["alpha", "bravo", "charlie", "delta"],
                    "never-placed books read A–Z")
            try ops.placeReading(ids["delta"]!, at: .top)
            #expect(try sequence(db, shelf: shelf.id) == ["delta", "alpha", "bravo", "charlie"])
            try ops.placeReading(ids["alpha"]!, at: .bottom)
            #expect(try sequence(db, shelf: shelf.id) == ["delta", "bravo", "charlie", "alpha"],
                    "Send to Bottom lands after the never-placed run too")
            try ops.placeReading(ids["charlie"]!, at: .before(ids["bravo"]!))
            #expect(try sequence(db, shelf: shelf.id) == ["delta", "charlie", "bravo", "alpha"])
            // Into the never-placed run: two late books, a drop before the
            // second lands EXACTLY there — the first is materialized ahead.
            ids["echo"] = try ops.createReading(name: "echo", kind: .book, shelfId: shelf.id).id
            ids["fox"] = try ops.createReading(name: "fox", kind: .book, shelfId: shelf.id).id
            #expect(try sequence(db, shelf: shelf.id)
                    == ["delta", "charlie", "bravo", "alpha", "echo", "fox"])
            try ops.placeReading(ids["delta"]!, at: .before(ids["fox"]!))
            #expect(try sequence(db, shelf: shelf.id)
                    == ["charlie", "bravo", "alpha", "echo", "delta", "fox"])
            #expect(try reading(db, ids["echo"]!).shelfPosition != nil, "echo was materialized")
            #expect(try reading(db, ids["fox"]!).shelfPosition == nil, "fox was not touched")
        }
    }

    /// §20, her rider: the star is never encoded — Send to Top on an
    /// UNSTARRED book writes the smallest position all the same (the display
    /// floats the starred ones above it).
    @Test func theStarIsNeverPartOfTheSequence() throws {
        try withOperations { ops, db in
            let shelf = try ops.createShelf(name: "Work")
            let starred = try ops.createReading(name: "starred", kind: .book, shelfId: shelf.id)
            let plain = try ops.createReading(name: "plain", kind: .book, shelfId: shelf.id)
            try ops.setShelfPinned(starred.id, pinned: true)
            try ops.placeReading(starred.id, at: .top)
            try ops.placeReading(plain.id, at: .top)
            let p = try #require(try reading(db, plain.id).shelfPosition)
            let s = try #require(try reading(db, starred.id).shelfPosition)
            #expect(p < s, "the unstarred book holds the smallest position")
        }
    }

    @Test func aPlacementThatChangesNothingWritesNothingAndAForeignAnchorRefuses() throws {
        try withOperations { ops, db in
            let work = try ops.createShelf(name: "Work")
            let ideas = try ops.createShelf(name: "Ideas")
            let a = try ops.createReading(name: "a", kind: .book, shelfId: work.id)
            let b = try ops.createReading(name: "b", kind: .book, shelfId: work.id)
            let elsewhere = try ops.createReading(name: "c", kind: .book, shelfId: ideas.id)
            try db.write { try $0.execute(sql: "DELETE FROM sync_outbox") }
            try ops.placeReading(a.id, at: .top)                // already first
            try ops.placeReading(a.id, at: .before(b.id))       // already right before b
            try ops.placeReading(b.id, at: .bottom)             // already last
            let queued = try db.read {
                try Int.fetchOne($0, sql: "SELECT COUNT(*) FROM sync_outbox") ?? 0
            }
            #expect(queued == 0)
            #expect(throws: OperationError.placementAnchorNotOnShelf(
                readingID: a.id, anchorID: elsewhere.id)) {
                try ops.placeReading(a.id, at: .before(elsewhere.id))
            }
        }
    }

    /// The UNSHELVED run is one scope: a nil pointer and a dangling one (a
    /// deleted shelf) order together.
    @Test func theUnshelvedRunIsOneScopeDanglingIncluded() throws {
        try withOperations { ops, db in
            let doomed = try ops.createShelf(name: "Doomed")
            let orphan = try ops.createReading(name: "orphan", kind: .book, shelfId: doomed.id)
            let loose = try ops.createReading(name: "loose", kind: .book)
            try ops.deleteShelf(doomed.id)
            #expect(try sequence(db, shelf: nil) == ["loose", "orphan"])
            try ops.placeReading(orphan.id, at: .before(loose.id))
            #expect(try sequence(db, shelf: nil) == ["orphan", "loose"])
        }
    }
}

/// The pure placement arithmetic (`BookcaseOrdering.placementWrites`) — what
/// the op writes, at the edges a store rarely shows.
@Suite("Bookcase ordering — the pure rules (13i-d U1)")
struct BookcaseOrderingTests {
    private func book(_ id: String, _ position: String? = nil, name: String? = nil) -> Reading {
        Reading(id: id, name: name ?? id, kind: .book, shelfPosition: position,
                createdAt: Date(), updatedAt: Date())
    }

    @Test func aToZIsFindersRule() {
        let names = ["book 10", "Book 2", "apple", "Zebra"].map { ($0, $0) }
        #expect(names.sorted(by: BookcaseOrdering.nameAscending).map(\.0)
                == ["apple", "Book 2", "book 10", "Zebra"])
    }

    @Test func placedThenNeverPlacedAToZ() {
        let seq = BookcaseOrdering.placementSequence([
            book("z"), book("m", "V"), book("a"), book("k", "U"),
        ])
        #expect(seq.map(\.id) == ["k", "m", "a", "z"])
    }

    /// Equal keys (two devices' jitter colliding) never reach
    /// `FractionalIndex.between`'s `a < b` precondition: the lower bound is
    /// the largest key STRICTLY below the anchor.
    @Test func equalNeighbourKeysAreTolerated() throws {
        let seq = [book("a", "U"), book("b", "U"), book("c", "V"), book("x", "W")]
        var rng: any RandomNumberGenerator & Sendable = SeededGenerator(seed: 3)
        let writes = try #require(BookcaseOrdering.placementWrites(
            moving: "x", in: seq, to: .before("b"),
            between: { FractionalIndex.between($0, $1, using: &rng) }))
        #expect(writes.count == 1)
        #expect(writes[0].position < "U", "lands below both equal keys, never crashes")
    }

    @Test func anAnchorOffTheSequenceIsNilAndSelfAnchoringIsNil() {
        let seq = [book("a"), book("b")]
        #expect(BookcaseOrdering.placementWrites(moving: "a", in: seq, to: .before("q")) == nil)
        #expect(BookcaseOrdering.placementWrites(moving: "a", in: seq, to: .before("a")) == nil)
    }
}

/// The read side (E2): the wing-scoped snapshot, the arrival counts and the
/// P1 shape of the held observation.
@Suite("Bookcase reads (13i-d U1)")
struct BookcaseReadTests {
    @Test func theSnapshotIsOneWingsShelvesAndBooks() throws {
        try withOperations { ops, db in
            try db.write { db in
                try db.execute(sql: """
                    INSERT INTO wing (id, name, position, created_at, updated_at)
                    VALUES ('w2', 'Work', 'U', '2026-07-01T00:00:00.000Z', '2026-07-01T00:00:00.000Z')
                    """)
            }
            let home = try ops.createShelf(name: "Home shelf")
            _ = try ops.createShelf(name: "Away shelf", wingID: "w2")
            let mine = try ops.createReading(name: "mine", kind: .book, shelfId: home.id)
            _ = try ops.createReading(name: "away", kind: .book, wingId: "w2")
            let snapshot = try db.read { try Queries.bookcase($0, wingID: "") }
            #expect(snapshot.shelves.map(\.name) == ["Home shelf"])
            #expect(snapshot.books.map(\.reading.id) == [mine.id])
            #expect(try db.read { try Queries.bookshelf($0) }.count == 2,
                    "no wing = the shipped all-wings read (the phone's)")
        }
    }

    /// The row's accent count (§4): pending arrivals on a BOOK; a dismissed
    /// one is decided; an ARCHIVED waiter still counts (13i-d U4's ruled
    /// truth, #169(a)(2)); a gathering always reads 0.
    @Test func theArrivalCountIsABooksPendingRows() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(parent: nil, name: "ideas")
            let rule = try RuleGrammar.encode(.tag(tag.id))
            let book = try ops.createReading(
                name: "collecting", kind: .book, querySpec: rule, intakeSeating: .arrivals)
            _ = try ops.createReading(name: "shows", kind: .gathering, querySpec: rule)
            let posts = try (0..<3).map { try ops.createPost(title: "n\($0)") }
            for post in posts { _ = try ops.applyTag(tag.id, toPost: post.id) }
            func count(_ name: String) throws -> Int {
                try db.read { try Queries.bookshelf($0, wingID: "") }
                    .first { $0.reading.name == name }?.arrivalCount ?? -1
            }
            #expect(try count("collecting") == 3)
            #expect(try count("shows") == 0, "a gathering holds nothing")
            let waiting = try db.read {
                try Queries.bookArrivals($0, readingID: book.id, limit: 10).rows
            }
            try ops.dismissArrival(waiting[0].id)
            #expect(try count("collecting") == 2, "a dismissal is decided")
            try ops.archiveContainer(posts[1].id)
            #expect(try count("collecting") == 2, "an archived waiter still counts (U4's truth)")
        }
    }

    /// **P1 — the held snapshot never reads `container`.** Autosave rewrites
    /// the container row WHOLE (`Container.update`), so any `container`
    /// column in the tracked region would wake the Bookcase at keystroke
    /// rate. Red-on-old by construction: the arrival count's natural shape
    /// (`bookArrivalSource`'s `CROSS JOIN container`) turns this red.
    @Test func theHeldSnapshotsRegionIsBlindToAutosave() async throws {
        let queue = try DatabaseQueue()
        try AppDatabase.migrator.migrate(queue)
        // One book, so the listing reads past its empty-store early return
        // and the region is the populated store's.
        try await queue.write { db in
            try db.execute(sql: """
                INSERT INTO reading (id, name, kind, created_at, updated_at)
                VALUES ('r', 'r', 'book', '2026-07-01T00:00:00.000Z', '2026-07-01T00:00:00.000Z')
                """)
        }
        let region = LockIsolated<DatabaseRegion?>(nil)
        let observation = ValueObservation
            .tracking { try Queries.bookcase($0, wingID: "") }
            .handleEvents(willTrackRegion: { tracked in region.setValue(tracked) })
        var values = observation.values(in: queue).makeAsyncIterator()
        _ = try await values.next()
        let tracked = try #require(region.value)
        let containerColumns: Set<String> = [
            "last_touched_at", "updated_at", "churn_accumulator", "title", "archived_at",
            "deleted_at",
        ]
        #expect(!tracked.isModified(byEventsOfKind: .update(
            tableName: "container", columnNames: containerColumns)),
            "a keystroke's container write must not wake the Bookcase")
        #expect(!tracked.isModified(byEventsOfKind: .update(
            tableName: "variant", columnNames: ["working_text", "updated_at"])))
        #expect(tracked.isModified(byEventsOfKind: .insert(tableName: "shelf")),
                "…while a shelf write does")
        #expect(tracked.isModified(byEventsOfKind: .insert(tableName: "reading_post")),
                "…and so does a membership or an arrival")
    }

    /// The one-shot aggregates: a book's last edit is its newest member's
    /// stamp; an empty book falls back to its own birth; a gathering's count
    /// and stamp come from what it shows.
    @Test func lastEditedIsDerivedFromTheMembersAndGatheringsCountWhatTheyShow() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(parent: nil, name: "t")
            let empty = try ops.createReading(name: "empty", kind: .book)
            let book = try ops.createReading(name: "book", kind: .book)
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(tag.id)))
            let older = try ops.createPost(title: "older")
            let newer = try ops.createPost(title: "newer")
            try ops.addPostToReading(older.id, to: book.id)
            try ops.addPostToReading(newer.id, to: book.id)
            _ = try ops.applyTag(tag.id, toPost: older.id)
            let made = try ops.newBlock(in: newer.id, text: "typed", at: .end)
            try ops.autosave(made.variant.id, text: "typed more", charDelta: 5)
            let aggregates = try db.read { try Queries.bookcaseAggregates($0, wingID: "") }
            let newerStamp = try db.read {
                try String.fetchOne($0, sql: """
                    SELECT COALESCE(last_touched_at, created_at) FROM container WHERE id = ?
                    """, arguments: [newer.id])
            }
            #expect(aggregates.lastEdited[book.id] == newerStamp, "the newest member's stamp")
            #expect(aggregates.lastEdited[empty.id]
                    == DateFormatter.variorumISO8601.string(from: empty.createdAt),
                    "an empty book sorts by its birth")
            #expect(aggregates.gatheringCounts[gathering.id] == 1)
            #expect(aggregates.gatheringCounts[book.id] == nil, "a book's count is its members")
        }
    }
}
