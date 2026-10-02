import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **13i-d U2, ACT 0 — THE UNION STAR** (the U1 record's F-U1-2, proposal
/// (A), RULED by the architect's adjudication after U1; her R-13id-5 on its
/// one visible consequence: the daily Journal and Quicknotes KEEP their
/// born-starred state).
///
/// Before this act a book's star was TWO stores that never met: the 13f
/// STAR (the synced `starred` setting list — the sidebar's Starred section,
/// star-time order, the cap) and 13i-a's `reading.starred` column (written
/// only by `setShelfPinned` — the shelf's float). The sitting record §7 rules
/// ONE mechanism ("a starred book joins the upper-left Starred section";
/// "pinned books become starred"). The ruled shape, pinned here:
///
/// - ONE truth, read as the UNION: a reading is starred iff its column is
///   set OR its key is in the list;
/// - every star write on a reading writes BOTH stores in one transaction,
///   and un-starring clears both;
/// - `Queries.starred` lists the list's live entries in star order, THEN the
///   column-only live readings A–Z (the 13i-a-migrated pins finally show);
/// - `Queries.shelfPins` and the cap read the union;
/// - `setShelfPinned` routes through the same write.
///
/// Every pin below is RED on the pre-ACT-0 tree (run before the fix — the
/// record carries the counts); the deliberate meaning flip is the Starred
/// section GAINING column-only books, which no earlier pin asserted against.
@Suite("The union star (13i-d U2 ACT 0 — F-U1-2 (A), R-13id-5)")
struct UnionStarTests {
    /// A COLUMN-only star — the shape every 13i-a-migrated shelf pin and
    /// every pre-ACT-0 pin/mint left behind.
    private func setColumnStar(_ db: AppDatabase, _ readingID: String) throws {
        try db.write { db in
            try db.execute(sql: "UPDATE reading SET starred = 1 WHERE id = ?",
                           arguments: [readingID])
        }
    }

    /// A LIST-only star — the shape every pre-ACT-0 13f star on a book left
    /// behind (the row's ★ door wrote the setting and never the column).
    private func setListStars(_ db: AppDatabase, _ keys: [String]) throws {
        let json = String(decoding: try JSONEncoder().encode(keys), as: UTF8.self)
        // `upsertSetting`'s own two-statement shape (an `ON CONFLICT` upsert
        // fires the insert AND update outbox triggers in one statement).
        try db.write { db in
            try db.execute(sql: "UPDATE setting SET value = ? WHERE key = 'starred'",
                           arguments: [json])
            if db.changesCount == 0 {
                try db.execute(sql: "INSERT INTO setting (key, value) VALUES ('starred', ?)",
                               arguments: [json])
            }
        }
    }

    private func column(_ db: AppDatabase, _ readingID: String) throws -> Bool {
        try db.read { try Queries.reading($0, id: readingID)?.starred } ?? false
    }

    // MARK: - The read: one truth, the union

    /// THE RULED MIGRATION, made visible: a column-only starred book (a
    /// migrated pin) joins the Starred section — after the list's entries,
    /// A–Z among themselves.
    @Test func columnOnlyStarredBooksJoinTheStarredSectionAfterTheListAToZ() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the storm", profile: .generic)
            let zed = try ops.createReading(name: "Zed", kind: .book)
            let alpha = try ops.createReading(name: "alpha", kind: .book)
            try ops.setStarred(.post(note.id), starred: true)
            try setColumnStar(db, zed.id)
            try setColumnStar(db, alpha.id)

            #expect(try db.read { try Queries.starred($0) }.map(\.target)
                    == [.post(note.id), .reading(alpha.id), .reading(zed.id)],
                    "the list in star order, then column-only books A–Z")
            #expect(try db.read { try Queries.starred($0) }.map(\.name)
                    == ["the storm", "alpha", "Zed"])
        }
    }

    /// The other half of the union: a list-only starred book (a pre-ACT-0
    /// 13f star) FLOATS — `shelfPins` (the phone's float, and the cap's
    /// count) reads it.
    @Test func listOnlyStarredBooksAreShelfPinsToo() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "Orbit", kind: .book)
            let plain = try ops.createReading(name: "plain", kind: .book)
            try setListStars(db, ["reading:\(book.id)"])
            #expect(try db.read { try Queries.shelfPins($0) } == [book.id],
                    "a starred book floats, whichever store carried its star")
            #expect(try db.read { try Queries.shelfPins($0) }.contains(plain.id) == false)
        }
    }

    /// The Bookcase's held snapshot carries the union per row (`ShelfBook.
    /// starred`) — the board's float and ★ read it. NEW API, so its red is
    /// proved by a behavioural revert (the record names it): reading the
    /// column alone turns this red.
    @Test func theBookcaseSnapshotCarriesTheUnion() throws {
        try withOperations { ops, db in
            let listed = try ops.createReading(name: "listed", kind: .book)
            let column = try ops.createReading(name: "column", kind: .book)
            let plain = try ops.createReading(name: "plain", kind: .book)
            try setListStars(db, ["reading:\(listed.id)"])
            try setColumnStar(db, column.id)
            let books = try db.read { try Queries.bookcase($0, wingID: "") }.books
            let starred = Dictionary(uniqueKeysWithValues: books.map { ($0.reading.id, $0.starred) })
            #expect(starred[listed.id] == true, "a list-only star floats")
            #expect(starred[column.id] == true, "a column-only star floats")
            #expect(starred[plain.id] == false)
        }
    }

    // MARK: - The write: both stores, one transaction

    @Test func starringABookWritesBothStores() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "Orbit", kind: .book)
            try ops.setStarred(.reading(book.id), starred: true)
            #expect(try column(db, book.id), "the column floats it on the shelf")
            #expect(try db.read { try Queries.starredTargets($0) } == [.reading(book.id)],
                    "the list keeps star-time order")
            #expect(try db.read { try Queries.shelfPins($0) } == [book.id])
        }
    }

    @Test func unstarringABookClearsBothStores() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "Orbit", kind: .book)
            // Both stores set, whichever way they got there.
            try setColumnStar(db, book.id)
            try setListStars(db, ["reading:\(book.id)"])

            try ops.setStarred(.reading(book.id), starred: false)
            #expect(try column(db, book.id) == false)
            #expect(try db.read { try Queries.starredTargets($0) }.isEmpty)
            #expect(try db.read { try Queries.starred($0) }.isEmpty)
            #expect(try db.read { try Queries.shelfPins($0) }.isEmpty)
        }
    }

    /// `setShelfPinned` routes through the same write: a pin IS a star (it
    /// joins the Starred section in star order), and an unpin clears the
    /// 13f list too.
    @Test func pinningIsStarringBothWays() throws {
        try withOperations { ops, db in
            let first = try ops.createReading(name: "first", kind: .book)
            let second = try ops.createReading(name: "second", kind: .book)
            try ops.setShelfPinned(second.id, pinned: true)
            try ops.setShelfPinned(first.id, pinned: true)
            #expect(try db.read { try Queries.starred($0) }.map(\.target)
                    == [.reading(second.id), .reading(first.id)],
                    "pin time is star time — the Starred section's order")

            // A 13f star unpinned through the shelf door leaves NO store set.
            try setListStars(db, ["reading:\(first.id)", "reading:\(second.id)"])
            try ops.setShelfPinned(first.id, pinned: false)
            #expect(try db.read { try Queries.starred($0) }.map(\.target) == [.reading(second.id)])
            #expect(try column(db, first.id) == false)
        }
    }

    /// Ladder A round 1, NIT 4: ONE "A–Z" everywhere she reads one — the
    /// Starred section's column-only tail sorts with the Bookcase's own rule
    /// (`BookcaseOrdering.nameAscending`, Finder's digit-aware compare), so
    /// "Book 2" precedes "Book 10" in the section exactly as on the board.
    /// RED on the shipped tail (the SQL's `COLLATE NOCASE` put "Book 10"
    /// first).
    @Test func theColumnOnlyTailUsesTheBoardsOwnAToZ() throws {
        try withOperations { ops, db in
            let ten = try ops.createReading(name: "Book 10", kind: .book)
            let two = try ops.createReading(name: "Book 2", kind: .book)
            try setColumnStar(db, ten.id)
            try setColumnStar(db, two.id)
            #expect(try db.read { try Queries.starred($0) }.map(\.name) == ["Book 2", "Book 10"],
                    "the tail reads in the board's digit-aware A\u{2013}Z")
        }
    }

    // MARK: - The cap counts the union

    @Test func theCapCountsColumnOnlyStars() throws {
        try withOperations { ops, db in
            for index in 0..<(Operations.starLimit - 1) {
                let note = try ops.createPost(title: "n\(index)", profile: .generic)
                try ops.setStarred(.post(note.id), starred: true)
            }
            let pinned = try ops.createReading(name: "pinned", kind: .book)
            try setColumnStar(db, pinned.id)  // the fifteenth star, column-only
            let one = try ops.createPost(title: "one too many", profile: .generic)

            #expect(throws: OperationError.starLimitReached(limit: Operations.starLimit)) {
                try ops.setStarred(.post(one.id), starred: true)
            }
            // Re-starring something already starred is never refused by the
            // cap — it is already counted.
            #expect(throws: Never.self) {
                try ops.setStarred(.reading(pinned.id), starred: true)
            }
        }
    }

    // MARK: - R-13id-5: born starred, and visibly so

    /// Her ruling: the daily Journal KEEPS its born-starred state — it floats
    /// atop the Bookcase AND appears in the Starred section.
    @Test func theDailyJournalIsBornStarredInTheStarredSection() throws {
        try withOperations { ops, db in
            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-07-28")
            guard case .shelved(let bookID) = ops.shelveInDailyJournalBook(entry.container.id)
            else {
                Issue.record("the daily Journal was not minted")
                return
            }
            #expect(try db.read { try Queries.starred($0) }.map(\.target) == [.reading(bookID)])
            #expect(try column(db, bookID))
        }
    }

    @Test func quicknotesIsBornStarredInTheStarredSection() throws {
        try withOperations { ops, db in
            let quicknotes = try #require(try ops.ensureQuicknotesBook())
            #expect(try db.read { try Queries.starred($0) }.map(\.target)
                    == [.reading(quicknotes)])
        }
    }
}
