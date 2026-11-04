import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **VX-758 — a book's date sort orders EVERY note** (her words, 2026-11-04:
/// *"in books, sorting by creation date doesn't seem to be diong anything
/// unless items have an entry date - it should use their creation date if
/// they don't have an entry date"*).
///
/// The traced truth (`notes/plans/fixes/vx-770-takes-compare-window.md`,
/// BATCH 5 › A): the book's **Entry date** arm piled every undated note last
/// in both directions, ordered among themselves by `id` — a random UUID — so
/// no pick ordered them. The **Created** arm was never broken (`created_at` is
/// NOT NULL). The fix gives the entry-date arm the Library's own date rule:
/// `COALESCE(entry_date, created_at)`, tie broken by `id`.
///
/// The fixture mixes dated and undated notes whose creation instants are
/// written explicitly (midday UTC, so the raw stamps and every reading of
/// "which day" agree in any zone the suites run in):
///
/// | note | entry_date | created_at |
/// |---|---|---|
/// | d10 | 2026-07-10 | the harness mint (2026-07-01T00:00:0…) |
/// | u05 | — | 2026-07-05T12:00:00.000Z |
/// | d01 | 2026-07-01 | the harness mint |
/// | u20 | — | 2026-07-20T12:00:00.000Z |
/// | u05late | — | 2026-07-05T15:00:00.000Z |
///
/// Minted in that order (so `id` order = mint order: the OLD tree's undated
/// pile reads u05, u20, u05late ascending).
@Suite("VX-758 — a book's date sort falls back to the creation stamp")
struct BookDateSortFallbackTests {
    struct World {
        let d10: String, u05: String, d01: String, u20: String, u05late: String
        /// Her date order, ascending: the entry date, else the creation stamp.
        var byDateAscending: [String] { [d01, u05, u05late, d10, u20] }
        /// The creation order, ascending (entry dates play no part).
        var byCreationAscending: [String] { [d10, d01, u05, u05late, u20] }
    }

    private static func mintNotes(_ ops: Operations, _ db: AppDatabase) throws -> World {
        let d10 = try ops.createPost(title: "dated 10th", entryDate: "2026-07-10")
        let u05 = try ops.createPost(title: "undated 5th")
        let d01 = try ops.createPost(title: "dated 1st", entryDate: "2026-07-01")
        let u20 = try ops.createPost(title: "undated 20th")
        let u05late = try ops.createPost(title: "undated 5th, later")
        try db.write { db in
            for (id, stamp) in [
                (u05.id, "2026-07-05T12:00:00.000Z"),
                (u20.id, "2026-07-20T12:00:00.000Z"),
                (u05late.id, "2026-07-05T15:00:00.000Z"),
            ] {
                try db.execute(
                    sql: "UPDATE container SET created_at = ? WHERE id = ?",
                    arguments: [stamp, id])
            }
        }
        return World(d10: d10.id, u05: u05.id, d01: d01.id, u20: u20.id, u05late: u05late.id)
    }

    private static func ids(_ world: World) -> [String] {
        [world.d10, world.u05, world.d01, world.u20, world.u05late]
    }

    // MARK: - The entry-date arm (the broken one)

    /// HER ROAD: a hand-ordered book looked at through the order ▾'s
    /// "Entry date ↑/↓" — the read-time override (`BookViewModel.viewOrder` →
    /// `observeReading(order:)`).
    @Test(arguments: [SortDirection.asc, .desc])
    func lookingThroughEntryDateOrdersEveryNote(direction: SortDirection) throws {
        try withOperations { ops, db in
            let world = try Self.mintNotes(ops, db)
            let book = try ops.createReading(name: "mixed", kind: .book)
            for id in Self.ids(world) { try ops.addPostToReading(id, to: book.id) }
            let order = Queries.ReadingOrder(field: .entryDate, direction: direction)
            let entries = try db.read {
                try Queries.assembleReading($0, readingID: book.id, order: order)
            }
            let expected = direction == .asc
                ? world.byDateAscending : Array(world.byDateAscending.reversed())
            #expect(entries.map(\.postID) == expected,
                    "every note sorts by its entry date, else its creation stamp (\(direction))")
        }
    }

    /// The stored order (`setReadingSort` — "Save as This Book's Order", the
    /// journal trait's own date sort) reads the same rule: the override and
    /// the stored pair meet at one line (A31's "browsing shows what saving
    /// would show").
    @Test(arguments: [SortDirection.asc, .desc])
    func aBookSortedByEntryDateOrdersEveryNote(direction: SortDirection) throws {
        try withOperations { ops, db in
            let world = try Self.mintNotes(ops, db)
            let book = try ops.createReading(
                name: "mixed", kind: .book, sortField: .entryDate, sortDir: direction)
            for id in Self.ids(world) { try ops.addPostToReading(id, to: book.id) }
            let entries = try db.read { try Queries.assembleReading($0, readingID: book.id) }
            let expected = direction == .asc
                ? world.byDateAscending : Array(world.byDateAscending.reversed())
            #expect(entries.map(\.postID) == expected)
        }
    }

    /// A chaptered book: chapters govern, and inside each chapter the date
    /// rule holds — the undated notes are not piled at the chapter's end.
    @Test func insideAChapterEveryNoteSortsByItsDate() throws {
        try withOperations { ops, db in
            let world = try Self.mintNotes(ops, db)
            let book = try ops.createReading(name: "chaptered", kind: .book)
            for id in Self.ids(world) { try ops.addPostToReading(id, to: book.id) }
            let one = try ops.createSection(in: book.id, name: "one")
            let two = try ops.createSection(in: book.id, name: "two")
            // Chapter one: d10, u05, d01. Chapter two: u20, u05late.
            for id in [world.d10, world.u05, world.d01] {
                try ops.assignPostToSection(id, in: book.id, section: one.id)
            }
            for id in [world.u20, world.u05late] {
                try ops.assignPostToSection(id, in: book.id, section: two.id)
            }
            let entries = try db.read {
                try Queries.assembleReading(
                    $0, readingID: book.id,
                    order: .init(field: .entryDate, direction: .asc))
            }
            #expect(entries.map(\.postID) == [world.d01, world.u05, world.d10, world.u05late, world.u20])
            #expect(entries.map(\.sectionID) == [one.id, one.id, one.id, two.id, two.id])
        }
    }

    /// A gathering's assembly (no membership rows — the third arm) reads the
    /// same rule.
    @Test func aGatheringSortedByEntryDateOrdersEveryNote() throws {
        try withOperations { ops, db in
            let world = try Self.mintNotes(ops, db)
            let tag = try ops.createTag(name: "mixed")
            for id in Self.ids(world) { try ops.applyTag(tag.id, toPost: id) }
            let rule = try #require(try RuleGrammar.encode(.tag(tag.id)))
            let gathering = try ops.createReading(
                name: "mixed", kind: .gathering, sortField: .entryDate, sortDir: .desc,
                querySpec: rule)
            let entries = try db.read { try Queries.assembleReading($0, readingID: gathering.id) }
            #expect(entries.map(\.postID) == Array(world.byDateAscending.reversed()))
        }
    }

    // MARK: - The created arm (CHARACTERIZATION — never broken; green on both trees)

    /// "Created ↑/↓" orders every note by its creation instant, dated or not
    /// — the record's evidence that the Created arm is not the broken one.
    @Test(arguments: [SortDirection.asc, .desc])
    func lookingThroughCreatedOrdersEveryNoteByItsCreation(direction: SortDirection) throws {
        try withOperations { ops, db in
            let world = try Self.mintNotes(ops, db)
            let book = try ops.createReading(name: "mixed", kind: .book)
            for id in Self.ids(world) { try ops.addPostToReading(id, to: book.id) }
            let order = Queries.ReadingOrder(field: .createdAt, direction: direction)
            let entries = try db.read {
                try Queries.assembleReading($0, readingID: book.id, order: order)
            }
            let expected = direction == .asc
                ? world.byCreationAscending : Array(world.byCreationAscending.reversed())
            #expect(entries.map(\.postID) == expected)
        }
    }

    // MARK: - One date rule, two listings

    /// The book's date sort and the Library's date sort agree on the same
    /// notes (`Queries.library(sort: .entryDate)` — the precedent the fix
    /// reuses). The Library lists every live note, so the comparison is
    /// over these five only.
    @Test(arguments: [SortDirection.asc, .desc])
    func theBooksDateOrderIsTheLibrarysDateOrder(direction: SortDirection) throws {
        try withOperations { ops, db in
            let world = try Self.mintNotes(ops, db)
            let book = try ops.createReading(name: "mixed", kind: .book)
            for id in Self.ids(world) { try ops.addPostToReading(id, to: book.id) }
            let (bookOrder, libraryOrder) = try db.read { db in
                (try Queries.assembleReading(
                    db, readingID: book.id, order: .init(field: .entryDate, direction: direction))
                    .map(\.postID),
                 try Queries.library(db, sort: .entryDate, direction: direction).map(\.postID))
            }
            let mine = Set(Self.ids(world))
            #expect(bookOrder == libraryOrder.filter { mine.contains($0) })
        }
    }
}
