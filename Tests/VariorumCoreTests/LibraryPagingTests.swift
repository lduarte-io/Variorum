import Dependencies
import Foundation
import GRDB
import SQLCipher
import Testing

@testable import VariorumCore

/// **17y B1 item (k) — THE LIBRARY'S NOTES, PAGED** (her launch-blocker
/// report: "the fact that the library only shows you the first 40 notes is
/// completely unacceptable… we need an area in which people can scroll
/// through ALL of their notes").
///
/// `Queries.catalogNotesPage` is the read the Library's infinite scroll walks:
/// keyset pages on each sort's own `(key, id)`. These pins hold three things
/// against the REAL store written by the REAL operations:
///
/// 1. **Walking the pages lists every note exactly once, in exactly the
///    order the catalog has always listed them** — every sort, both
///    directions, a typed query and a wing — compared with `searchCatalog`'s
///    note arm asked UNCAPPED (the order she already knows).
/// 2. **The edited sort SEEKS `idx_container_touched`** (`EXPLAIN QUERY
///    PLAN` over the shipped statement) — its pages cost the page.
/// 3. **A deep page costs what the first page costs** (the VM step count,
///    `SQLITE_STMTSTATUS_VM_STEP`) — every sort; keyset never re-reads the
///    rows behind it the way OFFSET would.
///
/// The model's half (a scroll asks for the next page and never re-reads what
/// stands) and the views' (both Library views scroll the whole corpus) are
/// the Mac suites'.
@Suite("17y B1 (k) — the Library's notes, paged on each sort's own keyset")
struct LibraryPagingTests {
    private final class TravellingClock: @unchecked Sendable {
        private let state = LockIsolated(Date(timeIntervalSince1970: 1_780_000_000))
        func jump(_ seconds: TimeInterval) {
            state.withValue { $0 = $0.addingTimeInterval(seconds) }
        }
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(0.001) }
                return value
            }
        }
    }

    private func withCorpus<T>(
        notes: Int = 97, untouchedEvery: Int = 9,
        _ body: (Operations, AppDatabase, [String]) throws -> T
    ) throws -> T {
        let db = try AppDatabase.inMemory()
        let clock = TravellingClock()
        return try withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 23))
        } operation: {
            let ops = Operations()
            var ids: [String] = []
            let words = ["apple", "Apple", "banana", "Zebra", "émile", "moss", "Moss"]
            for i in 0..<notes {
                clock.jump(Double((i * 7_919) % 5_000))
                // Every 6th note is untitled (it lists under its date), every
                // 4th carries an entry date, titles collide across case.
                let title: String? = i % 6 == 2 ? nil : "\(words[i % words.count]) \(i % 11)"
                let entry: String? = i % 4 == 1
                    ? String(format: "2026-0%d-%02d", 1 + i % 8, 1 + i % 27) : nil
                let post = try ops.createPost(title: title, entryDate: entry)
                ids.append(post.id)
                // Every 9th note is NEVER touched (no block: its edit stamp
                // stays NULL — the edited sort's second arm).
                guard i % untouchedEvery != 4 else { continue }
                clock.jump(Double((i * 104_729) % 90_000))
                let block = try ops.newBlock(in: post.id, text: "body \(i)")
                if i % 5 == 3 {
                    _ = try ops.commit(block.variant.id)  // a major revision stamp
                }
            }
            // Out of every listing: an archived note and a deleted one.
            try ops.archiveContainer(ids[10])
            try ops.deleteContainer(ids[11])
            return try body(ops, db, ids)
        }
    }

    /// The catalog's own uncapped note order — what the pages must equal.
    private func uncapped(
        _ db: AppDatabase, query: String = "", sort: Queries.LibrarySort,
        direction: SortDirection, wingID: String? = nil
    ) throws -> [String] {
        try db.read {
            try Queries.searchCatalog(
                $0, query: query, limitPerKind: nil, sort: sort, direction: direction,
                wingID: wingID)
            .filter { $0.kind == .post }.map(\.id)
        }
    }

    private func walk(
        _ db: AppDatabase, query: String = "", sort: Queries.LibrarySort,
        direction: SortDirection, pageSize: Int, wingID: String? = nil
    ) throws -> (ids: [String], pages: Int) {
        var cursor: Queries.CatalogCursor?
        var ids: [String] = []
        var pages = 0
        repeat {
            let page = try db.read {
                try Queries.catalogNotesPage(
                    $0, query: query, sort: sort, direction: direction,
                    after: cursor, limit: pageSize, wingID: wingID)
            }
            ids += page.hits.map(\.id)
            cursor = page.next
            pages += 1
            #expect(pages < 1_000, "the walk must end")
        } while cursor != nil && pages < 1_000
        return (ids, pages)
    }

    static let sorts: [Queries.LibrarySort] = [
        .lastTouched, .createdAt, .entryDate, .title, .lastMajorRevision,
    ]

    /// **Claim 1.** Every sort, both ways: the pages, end to end, ARE the
    /// catalog's uncapped order — no note missing, none twice.
    @Test(arguments: LibraryPagingTests.sorts)
    func walkingThePagesListsEveryNoteOnceInTheCatalogsOrder(
        _ sort: Queries.LibrarySort
    ) throws {
        try withCorpus { _, db, _ in
            for direction in [SortDirection.desc, .asc] {
                let expected = try uncapped(db, sort: sort, direction: direction)
                #expect(expected.count == 95, "97 notes less the archived and the deleted one")
                for size in [1, 7, 40, 200] {
                    let walked = try walk(db, sort: sort, direction: direction, pageSize: size)
                    #expect(walked.ids == expected,
                            "\(sort) \(direction) in pages of \(size)")
                    #expect(Set(walked.ids).count == walked.ids.count, "no note twice")
                }
            }
        }
    }

    /// The typed query and the wing compose with the pages exactly as with
    /// the catalog.
    @Test func theQueryAndTheWingComposeWithThePages() throws {
        try withCorpus { ops, db, _ in
            let wing = try ops.createWing(name: "elsewhere")
            _ = try ops.createPost(title: "moss in another wing", wingId: wing.id)
            for sort in Self.sorts {
                for (query, wingID) in [("moss", ""), ("Apple 3", ""), ("2026-03", ""),
                                        ("moss", wing.id), ("", wing.id)] {
                    let expected = try uncapped(
                        db, query: query, sort: sort, direction: .desc, wingID: wingID)
                    let walked = try walk(
                        db, query: query, sort: sort, direction: .desc, pageSize: 4,
                        wingID: wingID)
                    #expect(walked.ids == expected, "\(sort) query=\(query) wing=\(wingID)")
                }
            }
        }
    }

    /// A page that IS the last says so: no cursor, and a page of exactly the
    /// remaining count does not invent another.
    @Test func theLastPageCarriesNoCursor() throws {
        try withCorpus(notes: 20) { _, db, _ in
            let all = try db.read {
                try Queries.catalogNotesPage($0, query: "", limit: 18)
            }
            #expect(all.hits.count == 18)
            #expect(all.next == nil, "18 live notes in a page of 18 — nothing follows")
            let short = try db.read {
                try Queries.catalogNotesPage($0, query: "", limit: 17)
            }
            #expect(short.next != nil)
        }
    }

    /// The sort's key and its `ORDER BY` expression are one fact
    /// (`expression` = key + collation) — the cursor compares what the order
    /// sorts by.
    @Test(arguments: LibraryPagingTests.sorts)
    func theCursorsKeyIsTheOrdersKey(_ sort: Queries.LibrarySort) {
        #expect(sort.expression == sort.keyExpression + sort.keyCollation)
    }

    // MARK: - P1

    /// **Claim 2.** The edited sort's touched arm SEEKS the timeline's own
    /// index, from the cursor — never a scan of the notes behind it.
    @Test func theEditedSortSeeksTheTouchedIndexFromTheCursor() throws {
        try withCorpus(notes: 30) { _, db, _ in
            let sql = Queries.catalogNotesPageSQL(
                sort: .lastTouched, direction: .desc, hasCursor: true, wingScope: nil)
            let plan = try db.read { database in
                try Row.fetchAll(
                    database, sql: "EXPLAIN QUERY PLAN \(sql)",
                    arguments: ["", "%%", "%%", "k", "id", 11, "", "%%", "%%", "k", "id", 11, 10])
                .map { $0["detail"] as String }
            }
            #expect(plan.contains { $0.contains("idx_container_touched") && $0.contains("<") },
                    "the touched arm seeks the index from the cursor: \(plan)")
        }
    }

    /// **Claim 3.** A page deep in the corpus costs what the first page costs
    /// (VM steps) — every sort. The edited sort's page is also small in
    /// ABSOLUTE terms (a seek); the unindexed sorts' pages are one bounded
    /// top-N pass over the live notes each (∝ the note count, flat in depth —
    /// the record's measured decision, no new index).
    @Test(arguments: LibraryPagingTests.sorts)
    func aDeepPageCostsWhatTheFirstPageCosts(_ sort: Queries.LibrarySort) throws {
        try withCorpus(notes: 600) { _, db, _ in
            func steps(after cursor: Queries.CatalogCursor?) throws -> Int {
                try db.read { database in
                    let sql = Queries.catalogNotesPageSQL(
                        sort: sort, direction: .desc, hasCursor: cursor != nil, wingScope: nil)
                    let statement = try database.makeStatement(sql: sql)
                    var arm: [(any DatabaseValueConvertible)?] = ["", "%%", "%%"]
                    if let cursor { arm += [cursor.key, cursor.id] }
                    arm.append(41)
                    var arguments = arm
                    if sort == .lastTouched { arguments += arm + [41] }
                    try statement.setArguments(StatementArguments(arguments))
                    _ = try Row.fetchAll(statement)
                    return Int(sqlite3_stmt_status(
                        statement.sqliteStatement, SQLITE_STMTSTATUS_VM_STEP, 0))
                }
            }
            // The cursor 500 notes deep.
            var cursor: Queries.CatalogCursor?
            for _ in 0..<5 {
                cursor = try db.read {
                    try Queries.catalogNotesPage($0, query: "", sort: sort, after: cursor, limit: 100)
                }.next
            }
            let first = try steps(after: nil)
            let deep = try steps(after: try #require(cursor))
            #expect(Double(deep) <= Double(first) * 1.5,
                    "\(sort): page one \(first) steps, a page 500 deep \(deep)")
        }
    }

    /// The edited sort's page is a SEEK: with the never-touched notes held
    /// fixed, quadrupling the corpus leaves the page's work where it was
    /// (the unindexed sorts' pages grow with it — the record's measured
    /// decision).
    @Test func theEditedSortsPageWorkIsFlatInTheCorpus() throws {
        func pageSteps(notes: Int) throws -> (edited: Int, created: Int) {
            try withCorpus(notes: notes, untouchedEvery: notes / 10) { _, db, _ in
                func steps(_ sort: Queries.LibrarySort) throws -> Int {
                    try db.read { database in
                        let sql = Queries.catalogNotesPageSQL(
                            sort: sort, direction: .desc, hasCursor: false, wingScope: nil)
                        let statement = try database.makeStatement(sql: sql)
                        let arm: [(any DatabaseValueConvertible)?] = ["", "%%", "%%", 41]
                        try statement.setArguments(StatementArguments(
                            sort == .lastTouched ? arm + arm + [41] : arm))
                        _ = try Row.fetchAll(statement)
                        return Int(sqlite3_stmt_status(
                            statement.sqliteStatement, SQLITE_STMTSTATUS_VM_STEP, 0))
                    }
                }
                return (try steps(.lastTouched), try steps(.createdAt))
            }
        }
        let small = try pageSteps(notes: 300)
        let large = try pageSteps(notes: 1_200)
        #expect(Double(large.edited) <= Double(small.edited) * 1.5,
                "the edited page: \(small.edited) steps at 300 notes, \(large.edited) at 1,200")
        #expect(large.created > small.created * 3,
                "the created page is a bounded pass over the notes (recorded, not hidden): \(small.created) → \(large.created)")
    }

    /// **The Library HOLDS one observation per window — the ownership facts
    /// of the near pages' notes** (17y B1 (k); the U1 P1-pin pattern): its
    /// tracked region is blind to a keystroke (autosave rewrites `variant`
    /// and the `container` row) and wakes only for a membership or a book.
    @Test func theHeldOwnershipFactsAreBlindToAKeystroke() async throws {
        let queue = try DatabaseQueue()
        try AppDatabase.migrator.migrate(queue)
        let region = LockIsolated<DatabaseRegion?>(nil)
        let observation = ValueObservation
            .tracking { try Queries.ownershipFacts($0, postIDs: ["a", "b"], inBook: nil) }
            .handleEvents(willTrackRegion: { region.setValue($0) })
        var values = observation.values(in: queue).makeAsyncIterator()
        _ = try await values.next()
        let tracked = try #require(region.value)
        #expect(!tracked.isModified(byEventsOfKind: .update(
            tableName: "variant", columnNames: ["working_text", "updated_at"])))
        #expect(!tracked.isModified(byEventsOfKind: .update(
            tableName: "container",
            columnNames: ["last_touched_at", "updated_at", "churn_accumulator", "title"])))
        #expect(tracked.isModified(byEventsOfKind: .insert(tableName: "reading_post")),
                "…while a membership wakes it")
    }
}
