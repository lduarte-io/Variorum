import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-b U2 — THE DOOR'S READ SIDE (`Queries.bookArrivals`): the count the
/// Arrivals line says and the rows its expansion lists, by ONE predicate, and
/// bounded the way the plan §3 promises (book-scoped, never the corpus). The
/// arrivals here are minted by the REAL intake (a living book whose join dial
/// says "wait at Arrivals"), so the rows are exactly the shape U1 writes.
@Suite("13i-b U2 — the Arrivals line's query: count, listing, bounds")
struct ArrivalQueriesTests {
    private func rule(_ term: RuleTerm) throws -> String {
        try #require(try RuleGrammar.encode(term))
    }

    /// A living book on `#work` whose new matches WAIT at the door.
    private func guardedBook(
        _ ops: Operations, tag: VariorumCore.Tag, name: String = "guarded", maxPosts: Int? = nil
    ) throws -> Reading {
        try ops.createReading(
            name: name, kind: .book, querySpec: try rule(.tag(tag.id)),
            maxPosts: maxPosts, intakeSeating: .arrivals)
    }

    /// Tag a fresh note into the book's door; returns the note.
    private func ring(
        _ ops: Operations, _ tag: VariorumCore.Tag, title: String?, entryDate: String? = nil
    ) throws -> Container {
        let note = try ops.createPost(title: title, entryDate: entryDate)
        _ = try ops.applyTag(tag.id, toPost: note.id)
        return note
    }

    private func door(
        _ db: AppDatabase, _ readingID: String, limit: Int = 50
    ) throws -> Queries.BookArrivals {
        try db.read { try Queries.bookArrivals($0, readingID: readingID, limit: limit) }
    }

    private func arrivalRowIDs(_ db: AppDatabase, _ readingID: String) throws -> [String] {
        try db.read {
            try String.fetchAll(
                $0, sql: """
                    SELECT id FROM reading_post
                    WHERE reading_id = ? AND deleted_at IS NULL AND status = 'arrival'
                    ORDER BY rowid
                    """,
                arguments: [readingID])
        }
    }

    @Test func anEmptyDoorAnswersNothingEvenWithMembers() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try guardedBook(ops, tag: work)
            #expect(try door(db, book.id) == .none, "a fresh book: nothing waits")
            let member = try ops.createPost(title: "seated by hand")
            try ops.addPostToReading(member.id, to: book.id)
            #expect(try door(db, book.id) == .none,
                    "a MEMBER is never counted at the door (the 13i-a schema note)")
        }
    }

    @Test func theDoorCountsAndListsWhatWaitsInArrivalOrder() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try guardedBook(ops, tag: work)
            let first = try ring(ops, work, title: "first")
            let second = try ring(ops, work, title: "second")
            let third = try ring(ops, work, title: "third")

            let answer = try door(db, book.id)
            #expect(answer.count == 3)
            try #require(answer.rows.count == 3)
            #expect(answer.rows.map(\.postID) == [first.id, second.id, third.id],
                    "oldest arrival first — the order they rang (plan §3)")
            #expect(answer.rows.map(\.title) == ["first", "second", "third"])
            // The row id is the ARRIVAL ROW's — what the judgment ops take.
            #expect(answer.rows.map(\.id) == (try arrivalRowIDs(db, book.id)))
            // When it arrived: the row's own stamp, raw ISO text.
            let stamps = answer.rows.map(\.arrivedAt)
            #expect(stamps == stamps.sorted())
            #expect(stamps.allSatisfy { DateFormatter.variorumISO8601.date(from: $0) != nil })
        }
    }

    @Test func theLimitBoundsTheListingNeverTheCount() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try guardedBook(ops, tag: work)
            for i in 0..<5 { _ = try ring(ops, work, title: "n\(i)") }
            let windowed = try door(db, book.id, limit: 2)
            #expect(windowed.count == 5)
            #expect(windowed.rows.map(\.title) == ["n0", "n1"])
            // The collapsed line asks for the count alone.
            let collapsed = try door(db, book.id, limit: 0)
            #expect(collapsed == Queries.BookArrivals(count: 5, rows: []))
        }
    }

    @Test func judgedArrivalsLeaveTheDoor() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try guardedBook(ops, tag: work)
            let seated = try ring(ops, work, title: "seated")
            let dismissed = try ring(ops, work, title: "dismissed")
            let waiting = try ring(ops, work, title: "waiting")
            let rows = try door(db, book.id).rows
            try #require(rows.count == 3)
            try ops.seatArrival(rows[0].id)
            try ops.dismissArrival(rows[1].id)

            let answer = try door(db, book.id)
            #expect(answer.count == 1)
            #expect(answer.rows.map(\.postID) == [waiting.id])
            // And the seated one is a member now, never at the door.
            let members = try db.read { try Queries.assembleReading($0, readingID: book.id) }
            #expect(members.map(\.postID) == [seated.id])
            _ = dismissed
        }
    }

    @Test func anotherBooksArrivalsNeverCountHere() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let play = try ops.createTag(name: "play")
            let workBook = try guardedBook(ops, tag: work, name: "work book")
            let playBook = try guardedBook(ops, tag: play, name: "play book")
            _ = try ring(ops, work, title: "w")
            _ = try ring(ops, play, title: "p1")
            _ = try ring(ops, play, title: "p2")
            #expect(try door(db, workBook.id).count == 1)
            #expect(try door(db, playBook.id).count == 2)
        }
    }

    @Test func anArchivedNoteLeavesTheDoorWhileArchivedAndReturnsAfter() throws {
        // PROVISIONAL P-13ib-U2-2 — the book view's ambient-view rule.
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try guardedBook(ops, tag: work)
            let note = try ring(ops, work, title: "set aside")
            let rowID = try #require(try door(db, book.id).rows.first?.id)

            try ops.archiveContainer(note.id)
            #expect(try door(db, book.id) == .none)
            // The row itself stands untouched — only the face looks away.
            #expect(try arrivalRowIDs(db, book.id) == [rowID])

            try ops.unarchiveContainer(note.id)
            #expect(try door(db, book.id).rows.map(\.id) == [rowID])
        }
    }

    @Test func aDeletedNoteOrADeletedBookEmptiesTheDoor() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try guardedBook(ops, tag: work)
            let gone = try ring(ops, work, title: "gone")
            _ = try ring(ops, work, title: "stays")
            try ops.deleteContainer(gone.id)
            #expect(try door(db, book.id).rows.map(\.title) == ["stays"])
            try ops.deleteReading(book.id)
            #expect(try door(db, book.id) == .none)
        }
    }

    @Test func aGatheringNeverHasADoorEvenWithAStrayRow() throws {
        // The sitting record §1: a gathering holds nothing. A stray arrival
        // row standing on one (the reverted-bind class, U1's F-4) still
        // draws no line — the face is a BOOK's.
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let gathering = try ops.createReading(
                name: "gathering", kind: .gathering, querySpec: try rule(.tag(work.id)))
            let note = try ops.createPost(title: "stray")
            try db.write { db in
                try db.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                        VALUES ('stray-1', ?, ?, 'a0', 'arrival', '2026-07-01T00:00:00.000Z')
                        """,
                    arguments: [gathering.id, note.id])
            }
            #expect(try door(db, gathering.id) == .none)
        }
    }

    @Test func aNamelessNoteIsCalledByItsDay() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try guardedBook(ops, tag: work)
            _ = try ring(ops, work, title: nil, entryDate: "2026-09-30")
            #expect(try door(db, book.id).rows.map(\.title) == ["2026-09-30"],
                    "DisplayTitle.note — the one naming rule")
        }
    }

    @Test func aRungAgainNoteStandsOnItsNewRow() throws {
        // P-13ib-U1-1: a dismissal yields to a FRESH act, as a NEW arrival
        // row — the door lists the new ringing, never the dismissed one.
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try guardedBook(ops, tag: work)
            let note = try ring(ops, work, title: "again")
            let firstRow = try #require(try door(db, book.id).rows.first?.id)
            try ops.dismissArrival(firstRow)
            #expect(try door(db, book.id) == .none)

            try ops.removeTag(work.id, fromPost: note.id)
            _ = try ops.applyTag(work.id, toPost: note.id)
            let again = try door(db, book.id)
            #expect(again.count == 1)
            #expect(again.rows.first?.postID == note.id)
            #expect(again.rows.first?.id != firstRow)
        }
    }

    /// P1 on the PLAN (the `smartMembershipSQL` / `catalogPostsSQL`
    /// discipline — the shipped statements, never copies): the book's rows
    /// drive through a book-scoped index SEARCH and every note is a
    /// primary-key SEEK; neither table is ever SCANned.
    @Test func bothStatementsAreDrivenByTheBookNeverTheCorpus() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try guardedBook(ops, tag: work)
            for i in 0..<3 { _ = try ring(ops, work, title: "n\(i)") }
            for (name, sql, arguments) in [
                ("count", Queries.bookArrivalCountSQL, [book.id] as [any DatabaseValueConvertible]),
                ("rows", Queries.bookArrivalRowsSQL, [book.id, 10]),
            ] {
                let plan = try db.read { database in
                    try Row.fetchAll(
                        database, sql: "EXPLAIN QUERY PLAN \(sql)",
                        arguments: StatementArguments(arguments))
                        .map { ($0["detail"] as String?) ?? "" }
                }
                let joined = plan.joined(separator: "\n")
                #expect(plan.first?.hasPrefix("SEARCH rp USING") == true,
                        "\(name): the book's own rows drive; plan was:\n\(joined)")
                #expect(joined.contains("SEARCH c USING INDEX sqlite_autoindex_container_1"),
                        "\(name): each note is a PK seek; plan was:\n\(joined)")
                #expect(!joined.contains("SCAN rp") && !joined.contains("SCAN c"),
                        "\(name): no table scan; plan was:\n\(joined)")
            }
        }
    }

    @Test func theObservationDeliversTheDoorLive() async throws {
        try await withOperationsAsync { ops, db in
            let work = try ops.createTag(name: "work")
            let book = try guardedBook(ops, tag: work)
            var iterator = db.observeBookArrivals(book.id, limit: 5).makeAsyncIterator()
            #expect(try await iterator.next() == Queries.BookArrivals.none)
            let note = try ring(ops, work, title: "rang")
            let next = try #require(try await iterator.next())
            #expect(next.count == 1)
            #expect(next.rows.map(\.postID) == [note.id])
        }
    }
}
