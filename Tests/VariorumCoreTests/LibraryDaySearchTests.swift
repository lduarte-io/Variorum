import Dependencies
import Foundation
import GRDB
import SQLCipher
import Testing

@testable import VariorumCore

/// **18h batch 2 — THE DAY SEARCH** (the 2026-09-12 use-report round, her
/// ledger row 11; ruling R-Q8: *"Build now, small filter in the Library"*).
///
/// Her words: *"how difficult it would be to implement being able to search
/// for any note edited on a particular day."*
///
/// RED ON OLD — a PRODUCT row, so the honest red is that the capability is
/// ABSENT: `searchCatalog` had no `editedOn:` parameter, there was no
/// `DayBounds` to hand it and no `editedOnClause` to explain, so these pins
/// do not compile on the pre-change tree. The recorded compile errors are in
/// the batch record.
///
/// ── WHAT THESE PINS DRIVE ────────────────────────────────────────────────
/// Every one asks the REAL `Queries.searchCatalog` on a REAL store whose
/// stamps were written by the REAL operations (a travelling clock, so the
/// edits and savepoints land on the days they claim) — nothing writes a
/// `last_touched_at` by hand, because a filter pinned against hand-written
/// stamps proves nothing about the stamps the app actually makes.
@Suite("The Library finds the notes edited on a day (18h batch 2, row 11)")
struct LibraryDaySearchTests {
    // MARK: - A clock she can move

    /// The ops stamp from `@Dependency(\.date)`, so "Monday" and "Tuesday"
    /// are made by moving this and writing. Each read advances a
    /// millisecond, so ordering inside a day stays deterministic and two
    /// stamps in one day are still distinct.
    private final class TravellingClock: @unchecked Sendable {
        private let state = LockIsolated(Date(timeIntervalSince1970: 0))
        func set(_ iso: String) {
            state.setValue(DateFormatter.variorumISO8601.date(from: iso)!)
        }
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(0.001) }
                return value
            }
        }
    }

    private func withTravellingClock<T>(
        _ body: (Operations, AppDatabase, TravellingClock) throws -> T
    ) throws -> T {
        let db = try AppDatabase.inMemory()
        let clock = TravellingClock()
        clock.set("2026-09-07T09:00:00.000Z")
        return try withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
        } operation: {
            try body(Operations(), db, clock)
        }
    }

    /// Her calendar for these pins is UTC, so "Monday" in the fixture and
    /// "Monday" in the bounds are the same twenty-four hours and the pin is
    /// about the UNION, not about timezones (`DayBoundsTests` owns those).
    private var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private func bounds(_ day: String) throws -> DayBounds {
        try #require(DayBounds(day: day, calendar: utc))
    }

    private func notesFound(
        _ db: AppDatabase, on day: String, query: String = "",
        sort: Queries.LibrarySort = .lastTouched, direction: SortDirection = .desc
    ) throws -> [String] {
        try db.read { database in
            try Queries.searchCatalog(
                database, query: query, sort: sort, direction: direction,
                editedOn: try bounds(day))
            .filter { $0.kind == .post }
            .map(\.id)
        }
    }

    private func allHits(_ db: AppDatabase, on day: String, query: String = "") throws
        -> [Queries.CatalogHit]
    {
        try db.read { database in
            try Queries.searchCatalog(
                database, query: query, editedOn: try bounds(day))
        }
    }

    // MARK: - The two readings of "edited on this day"

    /// HER CASE, and the caveat's own shape: one note, typed on Monday and
    /// again on Tuesday. The store keeps ONE edit stamp (AppSpec §10 —
    /// coarse, not forensic), so by that stamp alone the note belongs to
    /// Tuesday and Monday knows nothing about it.
    @Test func aNoteEditedMondayThenTuesdayAnswersForTuesdayByItsStamp() throws {
        try withTravellingClock { ops, db, clock in
            clock.set("2026-09-07T09:00:00.000Z")  // Monday
            let note = try ops.createPost(title: "the long one")
            let block = try ops.newBlock(in: note.id, text: "monday words")

            clock.set("2026-09-08T10:00:00.000Z")  // Tuesday
            try ops.autosave(block.variant.id, text: "monday words, tuesday words", charDelta: 15)

            #expect(try notesFound(db, on: "2026-09-08") == [note.id],
                    "Tuesday is the day its one stamp remembers")
            #expect(try notesFound(db, on: "2026-09-07") == [],
                    "Monday's edit is not in the store as a day — the caveat, pinned")
        }
    }

    /// THE UNION'S POINT. Same note, same two days — but a savepoint landed
    /// on Monday (since 13j one lands per changed take when she leaves a
    /// note, `closeAutoCommit`, with the idle timer behind it). Now Monday
    /// answers too, and Tuesday still does.
    @Test func aSavepointFromMondayBringsTheNoteBackForMonday() throws {
        try withTravellingClock { ops, db, clock in
            clock.set("2026-09-07T09:00:00.000Z")
            let note = try ops.createPost(title: "the long one")
            let block = try ops.newBlock(in: note.id, text: "monday words")
            _ = try ops.commit(block.variant.id, kind: .auto)  // leaving the note

            clock.set("2026-09-08T10:00:00.000Z")
            try ops.autosave(block.variant.id, text: "monday words, tuesday words", charDelta: 15)

            #expect(try notesFound(db, on: "2026-09-07") == [note.id],
                    "the savepoint is Monday's evidence")
            #expect(try notesFound(db, on: "2026-09-08") == [note.id],
                    "and the stamp is still Tuesday's")
        }
    }

    @Test func aNoteWithNeitherAStampNorASavepointOnTheDayIsAbsent() throws {
        try withTravellingClock { ops, db, clock in
            clock.set("2026-09-07T09:00:00.000Z")
            let note = try ops.createPost(title: "quiet")
            let block = try ops.newBlock(in: note.id, text: "written monday")
            _ = try ops.commit(block.variant.id, kind: .auto)

            #expect(try notesFound(db, on: "2026-09-09") == [],
                    "nothing of this note happened on Wednesday")
            #expect(try notesFound(db, on: "2026-09-06") == [])
            #expect(try notesFound(db, on: "2026-09-07") == [note.id])
        }
    }

    /// The mint IS an edit for a note never typed in again — the same
    /// `COALESCE(last_touched_at, created_at)` the row's own stamp displays,
    /// so the filter can never disagree with the words beside it.
    @Test func anUntouchedNotesMintCountsAsItsEdit() throws {
        try withTravellingClock { ops, db, clock in
            clock.set("2026-09-09T14:00:00.000Z")
            let note = try ops.createPost(title: "born and left alone")
            let touched = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [note.id])
            #expect(touched == nil, "nothing has touched it — the COALESCE's own case")
            #expect(try notesFound(db, on: "2026-09-09") == [note.id])
            #expect(try notesFound(db, on: "2026-09-08") == [])
        }
    }

    /// The savepoint half is CORRELATED — a commit on another note's block
    /// never answers here. (Written as one store with two notes, because
    /// that is the shape that would break if the `EXISTS` lost its
    /// `cb.container_id = container.id`.)
    @Test func aSavepointOnAnotherNotesBlockNeverAnswersHere() throws {
        try withTravellingClock { ops, db, clock in
            clock.set("2026-09-07T09:00:00.000Z")
            let mine = try ops.createPost(title: "mine")
            _ = try ops.newBlock(in: mine.id, text: "mine")
            let theirs = try ops.createPost(title: "theirs")
            let theirBlock = try ops.newBlock(in: theirs.id, text: "theirs")

            clock.set("2026-09-09T11:00:00.000Z")  // only THEIR note gets Wednesday
            _ = try ops.commit(theirBlock.variant.id, kind: .auto)

            #expect(try notesFound(db, on: "2026-09-09") == [theirs.id])
        }
    }

    /// A savepoint on a take of a block the note HELD and no longer holds is
    /// not this note's day: the placement join is live (I2). Pinned so the
    /// join's `deleted_at IS NULL` cannot be dropped as decoration.
    @Test func aSavepointOnADeletedBlockNoLongerAnswersForTheNote() throws {
        try withTravellingClock { ops, db, clock in
            clock.set("2026-09-07T09:00:00.000Z")
            let note = try ops.createPost(title: "shrinking")
            let kept = try ops.newBlock(in: note.id, text: "kept")
            let cut = try ops.newBlock(in: note.id, text: "cut")

            clock.set("2026-09-09T11:00:00.000Z")
            _ = try ops.commit(cut.variant.id, kind: .auto)
            #expect(try notesFound(db, on: "2026-09-09") == [note.id])

            clock.set("2026-09-10T11:00:00.000Z")
            try ops.deleteBlock(cut.block.id)
            #expect(try notesFound(db, on: "2026-09-09") == [],
                    "the block left; its savepoint is no longer this note's evidence")
            _ = kept
        }
    }

    // MARK: - What the listing becomes while a day is set

    /// Books and blocks carry no edit stamp, so they stand down while a day
    /// is set (the batch's call, QUESTIONS #104): the answer to "on Sep 9"
    /// is notes, or nothing.
    @Test func onlyNotesAnswerADay() throws {
        try withTravellingClock { ops, db, clock in
            clock.set("2026-09-09T09:00:00.000Z")
            let note = try ops.createPost(title: "shelf note")
            let block = try ops.newBlock(in: note.id, text: "shelf words")
            try ops.setBlockName(block.block.id, name: "shelf")
            _ = try ops.createReading(name: "shelf", kind: .curated)

            // Without a day, the same query answers with all three kinds.
            let open = try db.read { database in
                try Queries.searchCatalog(database, query: "shelf")
            }
            #expect(Set(open.map(\.kind)) == [.book, .post, .block])

            let day = try allHits(db, on: "2026-09-09", query: "shelf")
            #expect(day.map(\.kind) == [.post])
            #expect(day.map(\.id) == [note.id])
        }
    }

    /// The day is an ARM of the one query, so the typed query and the sort
    /// still do their jobs beside it (review focus F-5: a parameter, never a
    /// second listing).
    @Test func theDayComposesWithTheTypedQueryAndTheSort() throws {
        try withTravellingClock { ops, db, clock in
            clock.set("2026-09-09T09:00:00.000Z")
            let apple = try ops.createPost(title: "apple")
            _ = try ops.newBlock(in: apple.id, text: "a")
            clock.set("2026-09-09T15:00:00.000Z")
            let banana = try ops.createPost(title: "banana")
            _ = try ops.newBlock(in: banana.id, text: "b")
            clock.set("2026-09-10T09:00:00.000Z")
            let cherry = try ops.createPost(title: "cherry apple")
            _ = try ops.newBlock(in: cherry.id, text: "c")

            #expect(try notesFound(db, on: "2026-09-09") == [banana.id, apple.id],
                    "edited, newest first — the day's own notes")
            #expect(try notesFound(db, on: "2026-09-09", direction: .asc) == [apple.id, banana.id])
            #expect(try notesFound(db, on: "2026-09-09", sort: .title, direction: .asc)
                    == [apple.id, banana.id])
            #expect(try notesFound(db, on: "2026-09-09", query: "apple") == [apple.id],
                    "the typed query narrows the day, and the day narrows the query")
            #expect(try notesFound(db, on: "2026-09-10", query: "apple") == [cherry.id])
        }
    }

    /// An archived or deleted note is not in the Library, day or no day —
    /// the arm rides the existing WHERE rather than replacing it.
    @Test func archivedAndDeletedNotesStayOutOfTheDaysAnswer() throws {
        try withTravellingClock { ops, db, clock in
            clock.set("2026-09-09T09:00:00.000Z")
            let live = try ops.createPost(title: "live")
            _ = try ops.newBlock(in: live.id, text: "l")
            let archived = try ops.createPost(title: "archived")
            _ = try ops.newBlock(in: archived.id, text: "a")
            let deleted = try ops.createPost(title: "deleted")
            _ = try ops.newBlock(in: deleted.id, text: "d")
            try ops.archiveContainer(archived.id)
            try ops.deleteContainer(deleted.id)

            #expect(try notesFound(db, on: "2026-09-09") == [live.id])
        }
    }

    /// The day search lands on the DAY BOUNDARY exactly: 23:59:59.999 of the
    /// day is in, 00:00:00.000 of the next day is out (half-open).
    @Test func theWindowIsHalfOpenAtBothEnds() throws {
        try withTravellingClock { ops, db, clock in
            clock.set("2026-09-09T23:59:59.998Z")
            let lastMinute = try ops.createPost(title: "just before midnight")
            clock.set("2026-09-10T00:00:00.000Z")
            let firstMoment = try ops.createPost(title: "midnight")

            #expect(try notesFound(db, on: "2026-09-09") == [lastMinute.id])
            #expect(try notesFound(db, on: "2026-09-10") == [firstMoment.id])
        }
    }

    // MARK: - The measurement (17c's discipline: the plan and the counts)

    /// **THE PLAN PIN.** `EXPLAIN QUERY PLAN` over the SHIPPED statement
    /// (`catalogPostsSQL` — the pin explains the string the query runs, not a
    /// retyped copy). What it must show: the savepoint arm reached through
    /// the note's OWN placements and takes, ending at `idx_commit_variant`,
    /// so the `commit_point` read is bounded by this note's savepoints —
    /// never a full scan of every savepoint in the corpus (P1).
    ///
    /// This is the pin that decides whether `commit_point(created_at)` needs
    /// an index of its own; the verdict is in the batch record.
    @Test func theSavepointArmIsBoundedByTheNotesOwnSavepoints() throws {
        try withTravellingClock { ops, db, clock in
            clock.set("2026-09-09T09:00:00.000Z")
            let note = try ops.createPost(title: "planned")
            let block = try ops.newBlock(in: note.id, text: "words")
            _ = try ops.commit(block.variant.id, kind: .auto)

            let sql = Queries.catalogPostsSQL(
                sort: .lastTouched, direction: .desc, editedOn: try bounds("2026-09-09"))
            let plan = try db.read { database in
                try String.fetchAll(
                    database, sql: "EXPLAIN QUERY PLAN \(sql)",
                    arguments: ["", "%%", "%%",
                                try bounds("2026-09-09").start, try bounds("2026-09-09").end,
                                try bounds("2026-09-09").start, try bounds("2026-09-09").end,
                                40],
                    adapter: SuffixRowAdapter(fromIndex: 3))
            }
            let text = plan.joined(separator: "\n")

            #expect(text.contains("idx_cblock_order"),
                    "the note's own placements are the correlated hook\n\(text)")
            #expect(text.contains("idx_variant_block"),
                    "its blocks' takes, by index\n\(text)")
            #expect(text.contains("idx_commit_variant"),
                    "and the savepoints by take — bounded, not scanned\n\(text)")
            #expect(!text.contains("SCAN commit_point"),
                    "a full savepoint scan would make the cost corpus-shaped (P1)\n\(text)")
        }
    }

    /// **THE STATEMENT COUNT.** The day search is ONE statement — not one
    /// per note, and not the three arms the open catalog runs (books and
    /// blocks stand down). Counted by tracing the connection, so the claim is
    /// measured rather than asserted.
    @Test func theDaySearchIsOneStatementWhereTheOpenCatalogIsThree() throws {
        try withTravellingClock { ops, db, clock in
            clock.set("2026-09-09T09:00:00.000Z")
            for index in 0..<12 {
                let note = try ops.createPost(title: "note \(index)")
                let block = try ops.newBlock(in: note.id, text: "words \(index)")
                _ = try ops.commit(block.variant.id, kind: .auto)
            }

            func statements(_ body: (Database) throws -> Void) throws -> Int {
                try db.read { database in
                    let count = LockIsolated(0)
                    let counting = LockIsolated(true)
                    database.trace(options: .statement) { _ in
                        if counting.value { count.withValue { $0 += 1 } }
                    }
                    try body(database)
                    counting.setValue(false)
                    return count.value
                }
            }

            let withDay = try statements { database in
                _ = try Queries.searchCatalog(
                    database, query: "note", editedOn: try bounds("2026-09-09"))
            }
            let without = try statements { database in
                _ = try Queries.searchCatalog(database, query: "note")
            }
            #expect(withDay == 1, "one bounded statement, whatever the corpus holds")
            #expect(without == 3, "the open catalog's three arms, unchanged")
        }
    }

    /// **THE WORK COUNT** (`SQLITE_STMTSTATUS_VM_STEP`): the day search's
    /// cost tracks the NOTES it walks, never the savepoints the corpus holds.
    /// Ten times the savepoints on ten times the notes must not be a hundred
    /// times the work.
    @Test func theDaySearchsWorkTracksTheNotesNotTheSavepoints() throws {
        func steps(notes: Int, savepointsEach: Int) throws -> Int {
            try withTravellingClock { ops, db, clock in
                clock.set("2026-09-09T09:00:00.000Z")
                for index in 0..<notes {
                    let note = try ops.createPost(title: "note \(index)")
                    let block = try ops.newBlock(in: note.id, text: "words")
                    for _ in 0..<savepointsEach {
                        _ = try ops.commit(block.variant.id, kind: .auto)
                    }
                }
                let day = try bounds("2026-09-09")
                let sql = Queries.catalogPostsSQL(
                    sort: .lastTouched, direction: .desc, editedOn: day)
                return try db.read { database in
                    let statement = try database.makeStatement(sql: sql)
                    _ = try Row.fetchAll(
                        statement,
                        arguments: ["", "%%", "%%", day.start, day.end, day.start, day.end, 40])
                    return Int(sqlite3_stmt_status(
                        statement.sqliteStatement, SQLITE_STMTSTATUS_VM_STEP, 0))
                }
            }
        }

        let small = try steps(notes: 4, savepointsEach: 2)
        let manySavepoints = try steps(notes: 4, savepointsEach: 20)
        let manyNotes = try steps(notes: 40, savepointsEach: 2)

        // Ten times the savepoints per note barely moves it — the arm stops
        // at the FIRST savepoint in the window (EXISTS), and the stamp arm
        // answers most notes before the subquery runs at all.
        #expect(Double(manySavepoints) < Double(small) * 3,
                "savepoints: \(small) → \(manySavepoints)")
        // Ten times the notes costs about ten times — the honest shape: the
        // listing walks the notes it lists.
        #expect(Double(manyNotes) < Double(small) * 20,
                "notes: \(small) → \(manyNotes)")
    }
}
