import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-d U4 — ARCHIVED MEMBERS IN BOOKS (her #169(a) ruling; the plan item 9):
/// THE ONE QUERY (`Queries.bookArchivedMembers` + its wing-grouped twin, one
/// predicate) and the two state-transition facts the brief asked to VERIFY —
/// `seatArrival` seats an archived waiter (as an ARCHIVED member, landing in
/// the archived line), and intake's automatic seats never seat or bell an
/// archived note. Those two are verifying pins of SHIPPED behaviour (green on
/// both sides by design — no code changed for them); the query's pins are new
/// API.
@Suite("13i-d U4 — a book's archived members: the one query, the seat, the intake")
struct ArchivedMembersTests {
    private func rule(_ term: RuleTerm) throws -> String {
        try #require(try RuleGrammar.encode(term))
    }

    private func archived(
        _ db: AppDatabase, _ readingID: String, limit: Int = 50
    ) throws -> Queries.BookArchivedMembers {
        try db.read { try Queries.bookArchivedMembers($0, readingID: readingID, limit: limit) }
    }

    private func shown(_ db: AppDatabase, _ readingID: String) throws -> [String] {
        try db.read { try Queries.assembleReading($0, readingID: readingID).map(\.postID) }
    }

    /// A book holding `titles` as members, in order.
    private func book(
        _ ops: Operations, _ titles: [String], name: String = "b"
    ) throws -> (Reading, [Container]) {
        let book = try ops.createReading(name: name, kind: .book)
        var notes: [Container] = []
        for title in titles {
            let note = try ops.createPost(title: title)
            try ops.addPostToReading(note.id, to: book.id)
            notes.append(note)
        }
        return (book, notes)
    }

    // MARK: - The one query

    @Test func aBookWithNothingArchivedAnswersNone() throws {
        try withOperations { ops, db in
            let (book, _) = try book(ops, ["a", "b"])
            #expect(try archived(db, book.id) == .none)
        }
    }

    @Test func archivedMembersAreCountedAndListedNewestArchivedFirst() throws {
        try withOperations { ops, db in
            let (book, notes) = try book(ops, ["one", "two", "three"])
            try ops.archiveContainer(notes[0].id)
            try ops.archiveContainer(notes[2].id)
            let answer = try archived(db, book.id)
            #expect(answer.count == 2)
            #expect(answer.rows.map(\.title) == ["three", "one"],
                    "newest-archived first — the Archived view's own order")
            #expect(answer.rows.map(\.postID) == [notes[2].id, notes[0].id])
            // Each row's id is its MEMBERSHIP row.
            let memberships = try db.read { db in
                try String.fetchAll(
                    db, sql: """
                        SELECT id FROM reading_post WHERE reading_id = ? AND post_id IN (?, ?)
                        ORDER BY post_id = ? DESC
                        """,
                    arguments: [book.id, notes[0].id, notes[2].id, notes[2].id])
            }
            #expect(answer.rows.map(\.id) == memberships)
            #expect(answer.rows.allSatisfy { !$0.archivedAt.isEmpty })
        }
    }

    @Test func theLimitBoundsTheListingNeverTheCount() throws {
        try withOperations { ops, db in
            let (book, notes) = try book(ops, ["a", "b", "c"])
            for note in notes { try ops.archiveContainer(note.id) }
            #expect(try archived(db, book.id, limit: 0) == .init(count: 3, rows: []))
            let two = try archived(db, book.id, limit: 2)
            #expect(two.count == 3)
            #expect(two.rows.count == 2)
        }
    }

    /// What is NOT an archived member: an archived WAITER (an arrival — the
    /// Arrivals line's), a removed member, a deleted note, another book's.
    @Test func onlyThisBooksLiveArchivedMembersCount() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "work")
            let book = try ops.createReading(
                name: "guarded", kind: .book, querySpec: try rule(.tag(tag.id)),
                intakeSeating: .arrivals)
            let other = try ops.createReading(name: "other", kind: .book)

            let kept = try ops.createPost(title: "kept")
            try ops.addPostToReading(kept.id, to: book.id)
            try ops.addPostToReading(kept.id, to: other.id)
            try ops.archiveContainer(kept.id)

            let waiter = try ops.createPost(title: "waiter")
            _ = try ops.applyTag(tag.id, toPost: waiter.id)
            try ops.archiveContainer(waiter.id)

            let removed = try ops.createPost(title: "removed")
            try ops.addPostToReading(removed.id, to: book.id)
            try ops.archiveContainer(removed.id)
            _ = try ops.removePostFromReading(removed.id, from: book.id)

            let gone = try ops.createPost(title: "gone")
            try ops.addPostToReading(gone.id, to: book.id)
            try ops.archiveContainer(gone.id)
            try ops.deleteContainer(gone.id)

            #expect(try archived(db, book.id).rows.map(\.title) == ["kept"])
            #expect(try archived(db, other.id).rows.map(\.title) == ["kept"],
                    "a note archived in two books is set aside in both")
        }
    }

    @Test func aGatheringNeverAnswersEvenWithAStrayMemberRow() throws {
        try withOperations { ops, db in
            let work = try ops.createTag(name: "work")
            let gathering = try ops.createReading(
                name: "g", kind: .gathering, querySpec: try rule(.tag(work.id)))
            let note = try ops.createPost(title: "stray")
            try ops.archiveContainer(note.id)
            try db.write { db in
                try db.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                        VALUES ('stray-1', ?, ?, 'a0', 'member', '2026-07-01T00:00:00.000Z')
                        """,
                    arguments: [gathering.id, note.id])
            }
            #expect(try archived(db, gathering.id) == .none)
        }
    }

    /// Item 9.5 — THE INDEX NEVER SHOWS ARCHIVED MEMBERS: while archived the
    /// assembly leaves the note out and the archived line has it; unarchived,
    /// it is back in the book's order and the line is empty.
    @Test func theAssemblyNeverShowsAnArchivedMemberAndUnarchiveReturnsIt() throws {
        try withOperations { ops, db in
            let (book, notes) = try book(ops, ["a", "b", "c"])
            try ops.archiveContainer(notes[1].id)
            #expect(try shown(db, book.id) == [notes[0].id, notes[2].id])
            #expect(try archived(db, book.id).rows.map(\.postID) == [notes[1].id])

            try ops.unarchiveContainer(notes[1].id)
            #expect(try shown(db, book.id) == notes.map(\.id), "back in its place")
            #expect(try archived(db, book.id) == .none)
        }
    }

    @Test func theWingCountsAreTheSamePredicateGroupedAndRideTheAggregates() throws {
        try withOperations { ops, db in
            let (first, a) = try book(ops, ["a1", "a2", "a3"], name: "first")
            let (second, b) = try book(ops, ["b1"], name: "second")
            let (plain, _) = try book(ops, ["c1"], name: "plain")
            try ops.archiveContainer(a[0].id)
            try ops.archiveContainer(a[2].id)
            try ops.archiveContainer(b[0].id)
            // A book in ANOTHER wing never counts in this one. (13i-d U5: a
            // book is born only in a LIVE wing now — the fixture mints one;
            // the assertions read its id where they read "w-2".)
            let otherWing = try ops.createWing(name: "w-2").id
            let away = try ops.createReading(name: "away", kind: .book, wingId: otherWing)
            try db.write { db in
                try db.execute(
                    sql: """
                        INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                        VALUES ('away-1', ?, ?, 'a0', 'member', '2026-07-01T00:00:00.000Z')
                        """,
                    arguments: [away.id, a[0].id])
            }
            let counts = try db.read { try Queries.archivedMemberCounts($0, wingID: "") }
            #expect(counts == [first.id: 2, second.id: 1], "books with none are absent")
            #expect(counts[plain.id] == nil)
            #expect(try db.read { try Queries.archivedMemberCounts($0, wingID: otherWing) }
                == [away.id: 1])
            for id in [first.id, second.id] {
                #expect(counts[id] == (try archived(db, id).count), "one predicate, two shapes")
            }
            let aggregates = try db.read { try Queries.bookcaseAggregates($0, wingID: "") }
            #expect(aggregates.archivedCounts == counts)
        }
    }

    /// P1 on the PLAN (the shipped statements): the book's rows drive through
    /// a book-scoped SEARCH, each note a primary-key SEEK, no SCAN; the wing
    /// statement drives from the wing's books.
    @Test func everyStatementIsDrivenByTheBookNeverTheCorpus() throws {
        try withOperations { ops, db in
            let (book, notes) = try book(ops, ["a", "b", "c"])
            for note in notes { try ops.archiveContainer(note.id) }
            for (name, sql, arguments) in [
                ("count", Queries.bookArchivedCountSQL, [book.id] as [any DatabaseValueConvertible]),
                ("rows", Queries.bookArchivedRowsSQL, [book.id, 10]),
                ("wing", Queries.wingArchivedCountsSQL, [""]),
            ] {
                let plan = try db.read { database in
                    try Row.fetchAll(
                        database, sql: "EXPLAIN QUERY PLAN \(sql)",
                        arguments: StatementArguments(arguments))
                        .map { ($0["detail"] as String?) ?? "" }
                }
                let joined = plan.joined(separator: "\n")
                #expect(joined.contains("SEARCH rp USING"),
                        "\(name): the book's own rows are searched; plan was:\n\(joined)")
                #expect(joined.contains("SEARCH c USING INDEX sqlite_autoindex_container_1"),
                        "\(name): each note is a PK seek; plan was:\n\(joined)")
                #expect(!joined.contains("SCAN rp") && !joined.contains("SCAN c"),
                        "\(name): never a scan of memberships or notes; plan was:\n\(joined)")
            }
        }
    }

    @Test func theObservationDeliversTheLineLive() async throws {
        try await withOperationsAsync { ops, db in
            let book = try ops.createReading(name: "b", kind: .book)
            let note = try ops.createPost(title: "set aside")
            try ops.addPostToReading(note.id, to: book.id)
            var iterator = db.observeBookArchivedMembers(book.id, limit: 5).makeAsyncIterator()
            #expect(try await iterator.next() == Queries.BookArchivedMembers.none)
            try ops.archiveContainer(note.id)
            let next = try #require(try await iterator.next())
            #expect(next.count == 1)
            #expect(next.rows.map(\.postID) == [note.id])
        }
    }

    // MARK: - The two verified facts (shipped behaviour, pinned)

    /// #169(a)(2): "Add seats one as an ARCHIVED member (it lands in the
    /// archived line)". VERIFIED: `seatArrival` reads `livePost` alone — it
    /// does NOT refuse an archived note. The same row flips to a member at the
    /// END, unsectioned; the note stays archived; the door empties; the
    /// archived line lists it; the Index (the assembly) does not.
    @Test func seatArrivalSeatsAnArchivedWaiterAsAnArchivedMember() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "work")
            let book = try ops.createReading(
                name: "guarded", kind: .book, querySpec: try rule(.tag(tag.id)),
                intakeSeating: .arrivals)
            let chapter = try ops.createSection(in: book.id, name: "I")
            let seated = try ops.createPost(title: "seated")
            try ops.addPostToReading(seated.id, to: book.id)
            try ops.assignPostToSection(seated.id, in: book.id, section: chapter.id)
            let waiter = try ops.createPost(title: "waiter")
            _ = try ops.applyTag(tag.id, toPost: waiter.id)
            try ops.archiveContainer(waiter.id)
            let door = try db.read { try Queries.bookArrivals($0, readingID: book.id, limit: 5) }
            let row = try #require(door.rows.first)
            #expect(row.archived, "the door marks it")

            let member = try ops.seatArrival(row.id)

            #expect(member.id == row.id, "the SAME row")
            #expect(member.status == .member)
            #expect(member.sectionId == nil, "unsectioned")
            let positions = try db.read { db in
                try String.fetchAll(
                    db, sql: """
                        SELECT position FROM reading_post
                        WHERE reading_id = ? AND deleted_at IS NULL AND status = 'member'
                        ORDER BY position, id
                        """, arguments: [book.id])
            }
            #expect(positions.last == member.position, "at the END")
            #expect(try db.read { try Container.fetchOne($0, key: waiter.id)?.archivedAt } != nil,
                    "seating never unarchives — it stays set aside")
            #expect(try db.read { try Queries.bookArrivals($0, readingID: book.id, limit: 5) }
                == .none)
            #expect(try archived(db, book.id).rows.map(\.postID) == [waiter.id],
                    "it lands in the archived line")
            #expect(try shown(db, book.id) == [seated.id], "the Index never shows it")
        }
    }

    /// "Intake's automatic seats still never seat one": an archived note is
    /// never seated OR belled — not by a tagging event, not by a book's birth
    /// (backfill), not by a resume (catch-up). VERIFIED: `matchesRule` and the
    /// sweep both require `archived_at IS NULL` (no change).
    @Test func intakeNeverSeatsOrBellsAnArchivedNote() throws {
        try withOperations { ops, db in
            let tag = try ops.createTag(name: "work")
            func rows(_ readingID: String) throws -> Int {
                try db.fetchInt(
                    "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
                    [readingID]) ?? 0
            }
            // EVENT: a living, auto-seating book hears a tag on an archived note.
            let living = try ops.createReading(
                name: "living", kind: .book, querySpec: try rule(.tag(tag.id)))
            let early = try ops.createPost(title: "early")
            try ops.archiveContainer(early.id)
            _ = try ops.applyTag(tag.id, toPost: early.id)
            #expect(try rows(living.id) == 0, "the tagging act seats nothing")

            // BACKFILL: a book born on the rule passes the archived match by.
            let born = try ops.createReading(
                name: "born", kind: .book, querySpec: try rule(.tag(tag.id)))
            #expect(try rows(born.id) == 0, "birth = intent, but never for an archived note")

            // CATCH-UP: finished, a match arrives archived, reopened.
            try ops.lockReading(living.id)
            let late = try ops.createPost(title: "late")
            _ = try ops.applyTag(tag.id, toPost: late.id)
            try ops.archiveContainer(late.id)
            try ops.unlockReading(living.id)
            #expect(try rows(living.id) == 0, "the resume's catch-up bells nothing archived")

            // Control: an UN-archived match does seat.
            let fresh = try ops.createPost(title: "fresh")
            _ = try ops.applyTag(tag.id, toPost: fresh.id)
            #expect(try rows(living.id) == 1)
        }
    }
}
