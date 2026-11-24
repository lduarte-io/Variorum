import Dependencies
import Foundation
import GRDB
import SQLCipher
import Testing

@testable import VariorumCore

/// **VM-68 (the VM-64 run, batch 5) — the phone's Library pages, and its Pool
/// listing stops classifying every note on every re-read.** The record is
/// `notes/plans/fixes/vm-64-timing-and-lags.md` (§4 batch 5; §7 its closeout).
///
/// The phone's two note listings (All/Notes and Bookless) become keyset pages
/// through the Mac's own paging read (`Queries.catalogNotesPage`). The Bookless
/// listing is that read with the Pool's LOOSE predicate added — the same two
/// predicates the Mac's Pool statement (`notePoolListingSQL`) reads, now from
/// one home. These pins hold four things:
///
/// 1. **The Mac's two statements are byte-identical** to the builders as they
///    stood before this batch (frozen below, verbatim): a shared read moved
///    for the phone changes nothing the Mac runs, so its plans cannot move.
/// 2. **The loose pages, walked end to end, ARE `poolPosts`' loose class** —
///    every note once, in the Pool's own order — across books, arrivals,
///    tombstoned books, every kind of gathering rule, archived and deleted
///    notes, the never-touched arm and two wings.
/// 3. **Each hit carries its sort key**, equal to `Queries.library`'s stamp —
///    the value the phone's All interleaves books by.
/// 4. **P1:** a loose page seeks the touched index and stops when it fills —
///    its work is flat in the corpus while the old read's grows with it.
@Suite("VM-68 — the Library's pages, and the Pool's loose class paged")
struct LibraryPoolPagingTests {

    // MARK: - The frozen builders (the statements as they stood before VM-68)

    /// `Queries.notePoolListingSQL`, VERBATIM as of base `35a3bea7a`.
    private static func frozenNotePoolListingSQL(
        _ db: Database, wingID: String? = nil
    ) throws -> (sql: String, arguments: [(any DatabaseValueConvertible)?]) {
        var shownTerms: [String] = []
        var arguments: [(any DatabaseValueConvertible)?] = []
        var stars = Queries.StarContext()
        for reading in try Queries.readings(db, wingID: wingID)
        where reading.kind == .gathering && reading.archivedAt == nil {
            let term: RuleTerm?
            switch RuleGrammar.read(reading.querySpec) {
            case .malformed, .none: continue
            case .rule(let t): term = t
            }
            let match = Queries.ruleMatchSQL(
                term, wingID: reading.wingId, starredNoteIDs: try stars.ids(db, for: term))
            shownTerms.append(
                "COALESCE((" + match.conditions.joined(separator: " AND ") + "), 0)")
            arguments += match.arguments
        }
        let shown = shownTerms.isEmpty ? "0" : "(" + shownTerms.joined(separator: " OR ") + ")"
        let scope = wingID.map { Queries.wingScope(column: "c.wing_id", wingID: $0) }
        let wingFence = scope.map { "\n                  AND \($0.sql)" } ?? ""
        arguments += scope?.arguments ?? []
        return ("""
            SELECT id, title, entry_date, created_at, profile, stamp, shown, n FROM (
              SELECT id, title, entry_date, created_at, profile, stamp, shown,
                     ROW_NUMBER() OVER (PARTITION BY shown ORDER BY stamp DESC, id DESC) AS rn,
                     COUNT(*) OVER (PARTITION BY shown) AS n
              FROM (
                SELECT c.id AS id, c.title AS title, c.entry_date AS entry_date,
                       c.created_at AS created_at, c.profile AS profile,
                       COALESCE(c.last_touched_at, c.created_at) AS stamp,
                       CASE WHEN \(shown) THEN 1 ELSE 0 END AS shown
                FROM container c
                WHERE c.kind = 'post' AND c.deleted_at IS NULL AND c.archived_at IS NULL\(wingFence)
                  AND NOT EXISTS (SELECT 1 FROM reading_post rp
                                   WHERE rp.post_id = c.id AND rp.deleted_at IS NULL
                                     AND rp.status = 'member'
                                     AND EXISTS (SELECT 1 FROM reading r
                                                  WHERE r.id = rp.reading_id
                                                    AND r.deleted_at IS NULL
                                                    AND r.kind = 'book'))
              )
            )
            WHERE rn <= ?
            ORDER BY shown, stamp DESC, id DESC
            """, arguments)
    }

    /// `Queries.catalogNotesPageSQL`, VERBATIM as of base `35a3bea7a`.
    private static func frozenCatalogNotesPageSQL(
        sort: Queries.LibrarySort, direction: SortDirection, hasCursor: Bool, wingScope: String?,
        narrowing: SearchComposer.ListingNarrowing? = nil
    ) -> String {
        let dir = direction == .desc ? "DESC" : "ASC"
        let comparison = direction == .desc ? "<" : ">"
        func arm(
            key: String, collation: String, extraWhere: String, index: String? = nil
        ) -> String {
            let cursor = hasCursor
                ? "\n  AND (\(key)\(collation), id) \(comparison) (?, ?)" : ""
            let wing = wingScope.map { "\n  AND \($0)" } ?? ""
            if let narrowing {
                return """
                    SELECT c.id AS id, c.title AS title, c.entry_date AS entry_date,
                           c.created_at AS created_at, c.profile AS profile,
                           COALESCE(c.last_touched_at, c.created_at) AS touched_at,
                           (c.archived_at IS NOT NULL) AS archived,
                           \(key) AS sort_key
                    FROM (\(narrowing.driver)) t
                    CROSS JOIN container c ON c.id = t.tagged_id
                    WHERE \(narrowing.conditions)\(extraWhere)
                      AND (? = '' OR COALESCE(title, '') LIKE ? ESCAPE '\\' OR COALESCE(entry_date, '') LIKE ? ESCAPE '\\')\(wing)\(cursor)
                    ORDER BY \(key)\(collation) \(dir), id \(dir)
                    LIMIT ?
                    """
            }
            return """
                SELECT id, title, entry_date, created_at, profile,
                       COALESCE(last_touched_at, created_at) AS touched_at,
                       \(key) AS sort_key
                FROM container\(index.map { " INDEXED BY \($0)" } ?? "")
                WHERE kind = 'post' AND deleted_at IS NULL AND archived_at IS NULL\(extraWhere)
                  AND (? = '' OR COALESCE(title, '') LIKE ? ESCAPE '\\' OR COALESCE(entry_date, '') LIKE ? ESCAPE '\\')\(wing)\(cursor)
                ORDER BY \(key)\(collation) \(dir), id \(dir)
                LIMIT ?
                """
        }
        switch sort {
        case .lastTouched:
            let touched = arm(
                key: "last_touched_at", collation: "",
                extraWhere: " AND last_touched_at IS NOT NULL",
                index: "idx_container_touched")
            let untouched = arm(
                key: "created_at", collation: "",
                extraWhere: " AND last_touched_at IS NULL",
                index: "idx_container_touched")
            return """
                SELECT * FROM (\(touched))
                UNION ALL
                SELECT * FROM (\(untouched))
                ORDER BY sort_key \(dir), id \(dir)
                LIMIT ?
                """
        case .entryDate, .createdAt, .lastMajorRevision, .title:
            return arm(key: sort.keyExpression, collation: sort.keyCollation, extraWhere: "")
        }
    }

    /// A bound argument, spelled for comparison (`DatabaseValue` is the
    /// statement's own view of it).
    private static func spelled(_ arguments: [(any DatabaseValueConvertible)?]) -> [String] {
        arguments.map { ($0?.databaseValue ?? .null).description }
    }

    static let sorts: [Queries.LibrarySort] = [
        .lastTouched, .createdAt, .entryDate, .title, .lastMajorRevision,
    ]

    // MARK: - 1 · The Mac's statements, byte for byte

    /// **The Mac's catalog page is the statement it always was** — every sort,
    /// both directions, with and without a cursor, a wing scope and a
    /// narrowing: the page read's builder with no Pool filter is byte-identical
    /// to the frozen pre-VM-68 builder.
    @Test(arguments: LibraryPoolPagingTests.sorts)
    func theMacsCatalogPageStatementIsByteIdentical(_ sort: Queries.LibrarySort) {
        let narrowing = SearchComposer.ListingNarrowing(
            driver: "SELECT 'n' AS tagged_id", driverArguments: [],
            conditions: "c.kind = 'post'", conditionArguments: [])
        for direction in [SortDirection.desc, .asc] {
            for hasCursor in [false, true] {
                for wingScope in [nil, "wing_id = ?"] as [String?] {
                    for narrowed in [nil, narrowing] as [SearchComposer.ListingNarrowing?] {
                        #expect(
                            Queries.catalogNotesPageSQL(
                                sort: sort, direction: direction, hasCursor: hasCursor,
                                wingScope: wingScope, narrowing: narrowed)
                                == Self.frozenCatalogNotesPageSQL(
                                    sort: sort, direction: direction, hasCursor: hasCursor,
                                    wingScope: wingScope, narrowing: narrowed),
                            "\(sort) \(direction) cursor=\(hasCursor) wing=\(String(describing: wingScope)) narrowed=\(narrowed != nil)")
                    }
                }
            }
        }
    }

    /// **The Mac's Pool is the statement it always was** — no gathering, every
    /// kind of gathering rule (a tag, a ★, a NOT, a malformed and an archived
    /// one), every wing scope: text AND arguments identical to the frozen
    /// pre-VM-68 builder.
    @Test func theMacsPoolStatementIsByteIdentical() throws {
        try withOperations { ops, db in
            func compare(_ label: String) throws {
                var scopes: [String?] = [nil, ""]
                if let wing = try db.read({ try Queries.wings($0) }).first?.id { scopes.append(wing) }
                for scope in scopes {
                    let shipped = try db.read { try Queries.notePoolListingSQL($0, wingID: scope) }
                    let frozen = try db.read { try Self.frozenNotePoolListingSQL($0, wingID: scope) }
                    #expect(shipped.sql == frozen.sql, "\(label) wing=\(String(describing: scope))")
                    #expect(Self.spelled(shipped.arguments) == Self.spelled(frozen.arguments),
                            "\(label) wing=\(String(describing: scope))")
                }
            }
            try compare("no gathering")
            let other = try ops.createWing(name: "elsewhere")
            let red = try ops.createTag(name: "red")
            let blue = try ops.createTag(name: "blue", wingID: other.id)
            let starred = try ops.createPost(title: "starred")
            try ops.setStarred(.post(starred.id), starred: true)
            _ = try ops.createReading(
                name: "reds", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(red.id)))
            _ = try ops.createReading(
                name: "stars", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            _ = try ops.createReading(
                name: "not red", kind: .gathering,
                querySpec: try RuleGrammar.encode(.and([.star, .not(.tag(red.id))])))
            _ = try ops.createReading(name: "corrupt", kind: .gathering, querySpec: "not json")
            let archived = try ops.createReading(
                name: "old reds", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(red.id)))
            try ops.archiveReading(archived.id)
            _ = try ops.createReading(
                name: "blues", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(blue.id)),
                wingId: other.id)
            try compare("six gatherings over two wings")
        }
    }

    // MARK: - The corpus

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

    /// **Every class the Pool's two predicates decide**, over two wings: notes
    /// in a live book (home), in a book later deleted (no home), with only an
    /// ARRIVAL row (no home), with a stray MEMBER row on a gathering (no
    /// home); gatherings by tag, by ★, by a NOT, a malformed one and an
    /// archived one, and one in the other wing; starred, archived, deleted and
    /// never-touched notes (the edited sort's second arm).
    private func withPoolCorpus<T>(
        notes: Int = 160, _ body: (Operations, AppDatabase, _ elsewhere: String) throws -> T
    ) throws -> T {
        let db = try AppDatabase.inMemory()
        let clock = TravellingClock()
        return try withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 68))
        } operation: {
            let ops = Operations()
            let elsewhere = try ops.createWing(name: "elsewhere")
            let red = try ops.createTag(name: "red")
            let blue = try ops.createTag(name: "blue", wingID: elsewhere.id)
            let bookA = try ops.createReading(name: "A", kind: .book)
            let bookB = try ops.createReading(name: "B", kind: .book)
            let bookC = try ops.createReading(name: "C", kind: .book, wingId: elsewhere.id)
            let reds = try ops.createReading(
                name: "reds", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(red.id)))
            _ = try ops.createReading(
                name: "stars", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            _ = try ops.createReading(
                name: "starred but not red", kind: .gathering,
                querySpec: try RuleGrammar.encode(.and([.star, .not(.tag(red.id))])))
            _ = try ops.createReading(name: "corrupt", kind: .gathering, querySpec: "not json")
            let retired = try ops.createReading(
                name: "old reds", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(red.id)))
            try ops.archiveReading(retired.id)
            _ = try ops.createReading(
                name: "blues", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(blue.id)),
                wingId: elsewhere.id)

            for i in 0..<notes {
                clock.jump(Double((i * 7_919) % 5_000))
                let away = i % 5 == 4
                let wing = away ? elsewhere.id : ""
                let post = try ops.createPost(title: i % 6 == 2 ? nil : "note \(i)", wingId: wing)
                if i % 9 != 4 {  // every 9th never touched
                    clock.jump(Double((i * 104_729) % 90_000))
                    _ = try ops.newBlock(in: post.id, text: "body \(i)")
                }
                if i % 7 == 1 { _ = try ops.addPostToReading(post.id, to: away ? bookC.id : bookA.id) }
                if i % 11 == 2, !away { _ = try ops.addPostToReading(post.id, to: bookB.id) }
                if i % 3 == 0 { _ = try ops.applyTag(away ? blue.id : red.id, toPost: post.id) }
                if i % 4 == 1 { try ops.setStarred(.post(post.id), starred: true) }
                // (Only where the note holds no row there already — the pair is
                // unique among live rows.)
                if i % 19 == 0, !away, i % 7 != 1 {
                    try insertReadingPost(db, reading: bookA.id, post: post.id, status: "arrival", n: i)
                }
                if i % 23 == 7, !away {
                    try insertReadingPost(db, reading: reds.id, post: post.id, status: "member", n: i)
                }
                if i % 13 == 6 { try ops.archiveContainer(post.id) }
                if i % 17 == 8 { try ops.deleteContainer(post.id) }
            }
            _ = try ops.deleteReading(bookB.id)
            return try body(ops, db, elsewhere.id)
        }
    }

    /// A raw membership row (an arrival, or a stray member row on a gathering
    /// — rows no door mints here but sync can carry; the Pool's predicate
    /// must read them as no home).
    private func insertReadingPost(
        _ db: AppDatabase, reading: String, post: String, status: String, n: Int
    ) throws {
        try db.write { db in
            try db.execute(
                sql: """
                    INSERT INTO reading_post (id, reading_id, post_id, position, status, created_at)
                    VALUES (?, ?, ?, ?, ?, ?)
                    """,
                arguments: ["raw-\(n)-\(status)", reading, post, "zz\(n)V", status,
                            "2026-07-01T00:00:00.000Z"])
        }
    }

    private func walk(
        _ db: AppDatabase, sort: Queries.LibrarySort = .lastTouched, pageSize: Int,
        wingID: String?, poolLoose: Bool
    ) throws -> (ids: [String], keys: [String]) {
        var cursor: Queries.CatalogCursor?
        var ids: [String] = []
        var keys: [String] = []
        var pages = 0
        repeat {
            let page = try db.read {
                try Queries.catalogNotesPage(
                    $0, query: "", sort: sort, direction: .desc, after: cursor, limit: pageSize,
                    wingID: wingID, poolLoose: poolLoose)
            }
            #expect(page.keys.count == page.hits.count, "one key per hit")
            ids += page.hits.map(\.id)
            keys += page.keys
            cursor = page.next
            pages += 1
        } while cursor != nil && pages < 2_000
        #expect(pages < 2_000, "the walk must end")
        return (ids, keys)
    }

    // MARK: - 2 · The loose pages ARE the Pool's loose class

    /// **Walked end to end, in pages of any size, the loose pages list
    /// exactly `poolPosts`' rows, in `poolPosts`' order** — every wing scope
    /// (all wings, Home, the other wing), with their stamps.
    @Test func walkingTheLoosePagesListsThePoolsLooseClassExactly() throws {
        try withPoolCorpus { _, db, elsewhere in
            let live = try db.read {
                try Int.fetchOne($0, sql: """
                    SELECT COUNT(*) FROM container
                    WHERE kind = 'post' AND deleted_at IS NULL AND archived_at IS NULL
                    """) ?? 0
            }
            for scope in [nil, "", elsewhere] as [String?] {
                let pool = try db.read { try Queries.poolPosts($0, limit: 10_000, wingID: scope) }
                let expected = pool.map(\.postID)
                #expect(expected.count >= 10, "a pool worth paging (\(String(describing: scope)))")
                #expect(expected.count < live, "the loose class is a proper part of the notes")
                for size in [1, 4, 50, 500] {
                    let walked = try walk(db, pageSize: size, wingID: scope, poolLoose: true)
                    #expect(walked.ids == expected,
                            "wing=\(String(describing: scope)) in pages of \(size)")
                    #expect(walked.keys == pool.map(\.stamp),
                            "each hit's key is the Pool's own stamp")
                }
            }
        }
    }

    /// The loose class FOLLOWS the Pool's own deciding acts — a note filed
    /// into a book leaves it; tagging a note a gathering collects tucks it;
    /// un-filing returns it — because the page reads the Pool's predicates,
    /// not a copy of them.
    @Test func theLooseClassMovesWithTheActsThatMoveThePool() throws {
        try withOperations { ops, db in
            let red = try ops.createTag(name: "red")
            let book = try ops.createReading(name: "book", kind: .book)
            _ = try ops.createReading(
                name: "reds", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(red.id)))
            let a = try ops.createPost(title: "a")
            let b = try ops.createPost(title: "b")
            func loose() throws -> Set<String> {
                Set(try walk(db, pageSize: 1, wingID: "", poolLoose: true).ids)
            }
            func pool() throws -> Set<String> {
                Set(try db.read { try Queries.poolPosts($0, limit: 50, wingID: "") }.map(\.postID))
            }
            #expect(try loose() == [a.id, b.id])
            _ = try ops.addPostToReading(a.id, to: book.id)
            #expect(try loose() == [b.id])
            _ = try ops.applyTag(red.id, toPost: b.id)
            #expect(try loose().isEmpty, "a gathering's note is tucked, not loose")
            try ops.removePostFromReading(a.id, from: book.id)
            #expect(try loose() == [a.id])
            #expect(try loose() == (try pool()))
        }
    }

    // MARK: - 3 · Each hit carries its sort key

    /// **The page's keys ARE `Queries.library`'s stamps** for every sort the
    /// phone offers — the value its All interleaves books by — and its ids are
    /// `Queries.library`'s rows, in order.
    @Test(arguments: [Queries.LibrarySort.lastTouched, .createdAt, .entryDate, .lastMajorRevision])
    func thePagesKeysAreTheLibrarysStamps(_ sort: Queries.LibrarySort) throws {
        try withPoolCorpus { _, db, _ in
            for scope in [nil, ""] as [String?] {
                let library = try db.read {
                    try Queries.library($0, sort: sort, direction: .desc, wingID: scope)
                }
                let walked = try walk(db, sort: sort, pageSize: 7, wingID: scope, poolLoose: false)
                #expect(walked.ids == library.map(\.postID), "\(sort) wing=\(String(describing: scope))")
                #expect(walked.keys == library.map(\.stamp), "\(sort) wing=\(String(describing: scope))")
            }
        }
    }

    // MARK: - 4 · P1

    /// The loose page's statement, its arguments for a page after `cursor`.
    private func loosePage(
        _ db: Database, after cursor: Queries.CatalogCursor?, limit: Int
    ) throws -> (sql: String, arguments: StatementArguments) {
        let pool = try Queries.poolLooseFilter(db, wingID: nil)
        let sql = Queries.catalogNotesPageSQL(
            sort: .lastTouched, direction: .desc, hasCursor: cursor != nil, wingScope: nil,
            poolLoose: pool.sql)
        var arm: [(any DatabaseValueConvertible)?] = pool.arguments + ["", "%%", "%%"]
        if let cursor { arm += [cursor.key, cursor.id] }
        arm.append(limit + 1)
        return (sql, StatementArguments(arm + arm + [limit + 1]))
    }

    /// **The loose page SEEKS the touched index from the cursor** (both arms
    /// name it; the touched arm's seek is bounded by the cursor) — never a
    /// scan of the notes behind it, never a sort of the whole Pool.
    @Test func theLoosePageSeeksTheTouchedIndexFromTheCursor() throws {
        try withPoolCorpus(notes: 60) { _, db, _ in
            let plan = try db.read { database -> [String] in
                let page = try loosePage(
                    database, after: Queries.CatalogCursor(key: "k", id: "id"), limit: 10)
                return try Row.fetchAll(
                    database, sql: "EXPLAIN QUERY PLAN \(page.sql)", arguments: page.arguments)
                .map { $0["detail"] as String }
            }
            #expect(plan.contains { $0.contains("idx_container_touched") && $0.contains("<") },
                    "the touched arm seeks the index from the cursor: \(plan)")
            #expect(!plan.contains { $0.hasPrefix("SCAN container") || $0.hasPrefix("SCAN c ") || $0 == "SCAN c" },
                    "no arm scans the container table: \(plan)")
            #expect(plan.contains { $0.contains("idx_reading_post_post") },
                    "the home probe is an indexed seek per walked note: \(plan)")
        }
    }

    /// **The record's plans** (the brief asks for one per held read): the
    /// phone's two held first pages — the note listing under the edited sort
    /// and the Bookless listing — as SQLite plans them, all wings and Home's
    /// scope. Printed (`VM68-PLAN|…`), and held to the two shapes above.
    @Test func thePlansOfTheTwoHeldPagesAreSeeks() throws {
        try withPoolCorpus(notes: 60) { _, db, _ in
            for (label, wing) in [("all-wings", nil), ("home", "")] as [(String, String?)] {
                for poolLoose in [false, true] {
                    let plan = try db.read { database -> [String] in
                        let pool = poolLoose ? try Queries.poolLooseFilter(database, wingID: wing) : nil
                        let scope = wing.map { Queries.wingScope(column: "wing_id", wingID: $0) }
                        let sql = Queries.catalogNotesPageSQL(
                            sort: .lastTouched, direction: .desc, hasCursor: false,
                            wingScope: scope?.sql, poolLoose: pool?.sql)
                        let arm: [(any DatabaseValueConvertible)?] =
                            (pool?.arguments ?? []) + ["", "%%", "%%"] + (scope?.arguments ?? []) + [201]
                        return try Row.fetchAll(
                            database, sql: "EXPLAIN QUERY PLAN \(sql)",
                            arguments: StatementArguments(arm + arm + [201]))
                        .map { $0["detail"] as String }
                    }
                    let name = poolLoose ? "bookless-head" : "notes-head"
                    for line in plan { print("VM68-PLAN|\(name)|\(label)|\(line)") }
                    #expect(plan.contains { $0.contains("idx_container_touched") },
                            "\(name) \(label) walks the touched index: \(plan)")
                    #expect(!plan.contains { $0.hasPrefix("SCAN container") || $0 == "SCAN c" || $0.hasPrefix("SCAN c ") },
                            "\(name) \(label) never scans the notes: \(plan)")
                }
            }
        }
    }

    /// **A loose page's work is flat in the corpus; the Pool statement's is
    /// not.** With the corpus quadrupled (every note bookless; two gatherings
    /// over a tag and the ★ that a FIXED few notes wear, so loose notes are
    /// plentiful), the first loose page's VM steps stay where they were while
    /// `notePoolListing`'s — every note classified against every gathering,
    /// then window-counted — grow with the notes. The BEFORE of the phone's
    /// Bookless re-read, recorded beside the AFTER.
    ///
    /// The never-touched notes are held FIXED too (ten), as the Mac's own pin
    /// holds them (`LibraryPagingTests.theEditedSortsPageWorkIsFlatInTheCorpus`):
    /// the edited sort's second arm walks every never-touched note — a note no
    /// block was ever written into — and sorts them by birth, so it costs ∝
    /// those notes by the paging read's recorded design, never ∝ the corpus.
    @Test func theLoosePagesWorkIsFlatInTheCorpusWhileThePoolsGrows() throws {
        func steps(notes: Int) throws -> (page: Int, pool: Int) {
            try withOperations { ops, db in
                let red = try ops.createTag(name: "red")
                _ = try ops.createReading(
                    name: "reds", kind: .gathering, querySpec: try RuleGrammar.encode(.tag(red.id)))
                _ = try ops.createReading(
                    name: "stars", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
                for i in 0..<notes {
                    let post = try ops.createPost(title: "note \(i)")
                    if i >= 10 { _ = try ops.newBlock(in: post.id, text: "body \(i)") }
                    if i % 37 == 0, i < 370 { _ = try ops.applyTag(red.id, toPost: post.id) }
                    if i % 61 == 1, i < 300 { try ops.setStarred(.post(post.id), starred: true) }
                }
                return try db.read { database in
                    func run(_ sql: String, _ arguments: StatementArguments) throws -> Int {
                        let statement = try database.makeStatement(sql: sql)
                        try statement.setArguments(arguments)
                        _ = try Row.fetchAll(statement)
                        return Int(sqlite3_stmt_status(
                            statement.sqliteStatement, SQLITE_STMTSTATUS_VM_STEP, 0))
                    }
                    let page = try loosePage(database, after: nil, limit: 40)
                    let pool = try Queries.notePoolListingSQL(database, wingID: nil)
                    return (try run(page.sql, page.arguments),
                            try run(pool.sql, StatementArguments(pool.arguments + [40])))
                }
            }
        }
        let small = try steps(notes: 300)
        let large = try steps(notes: 1_200)
        print("VM68-STEPS|loose-page|300=\(small.page)|1200=\(large.page)")
        print("VM68-STEPS|pool-listing|300=\(small.pool)|1200=\(large.pool)")
        #expect(Double(large.page) <= Double(small.page) * 1.5,
                "the loose page: \(small.page) steps at 300 notes, \(large.page) at 1,200")
        #expect(large.pool > small.pool * 3,
                "the Pool statement classifies every note (recorded, the before): \(small.pool) → \(large.pool)")
    }
}
