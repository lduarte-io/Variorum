//
//  SearchOrderTests.swift
//  VariorumCoreTests
//
//  VX-819 batch 2 — VX-820, her R-819-2 (*"Full vocabulary"*): while a
//  search is live the sort door offers relevance (leading, the default) ·
//  edited · created · date · title, with direction, exactly like the
//  Library's own `sort ▾`. The core half: the answer sheet's group page
//  ordered by each group's HOME through the Library's own sort semantics
//  (`SearchOrder.home` → `SearchComposer.groups(…order:)` → `Queries
//  .searchGroups(…order:)`), keyset-paged so every group is reachable, the
//  passages inside a group still best-first, relevance byte-identical.
//
//  An Improvement — BUILD pins (the brief): the order is the Library's own
//  (the catalog's listing of the same notes is the oracle, every sort both
//  ways, paged one or two groups at a time so the keyset carries it); the
//  worn-day corner takes its place in the order; P1 holds (the FTS index
//  drives the home-ordered statement — no corpus walk).
//

import Foundation
import GRDB
import Testing

@testable import VariorumCore

private func ask(_ text: String) -> SearchQuery {
    SearchQueryParser.parse(text, typeAhead: true, visibility: .living, locale: Locale(identifier: "en_US"))
}

/// Every group of a question under an order, paged `limit` at a time.
private func ordered(
    _ db: AppDatabase, _ text: String, _ order: SearchOrder, limit: Int = 2
) throws -> [SearchGroup] {
    try db.read { db in
        var all: [SearchGroup] = []
        var cursor: SearchComposer.GroupCursor?
        var pages = 0
        repeat {
            let page = try Queries.searchGroups(
                db, query: ask(text), scope: SearchScope(wingID: ""), after: cursor, limit: limit,
                perGroup: 3, order: order)
            all += page.groups
            cursor = page.next
            pages += 1
        } while cursor != nil && pages < 100
        return all
    }
}

/// The Library's own listing of the store's notes under a sort — the oracle.
private func catalogOrder(
    _ db: AppDatabase, _ sort: Queries.LibrarySort, _ direction: SortDirection
) throws -> [String] {
    try db.read { db in
        try Queries.catalogNotesPage(db, query: "", sort: sort, direction: direction, limit: 500)
            .hits.map(\.id)
    }
}

private let offered: [Queries.LibrarySort] = [.lastTouched, .createdAt, .entryDate, .title]

@Suite("VX-820 — the answer sheet ordered by the Library's own sort")
struct SearchOrderTests {
    /// Six notes whose four orders all disagree: titles mixed in case (the
    /// title order folds it), two untitled (their names are their days),
    /// three stated days (one earlier than every birth — the date order is
    /// VX-758's: the stated day, else the written day), and edits touched
    /// out of birth order.
    private func sixNotes(_ ops: Operations) throws -> [String] {
        let specs: [(title: String?, day: String?)] = [
            ("cherry", nil), ("Apple", "2026-06-20"), (nil, "2026-06-15"),
            ("banana", nil), ("apple pie", nil), (nil, "2026-08-01"),
        ]
        var ids: [String] = []
        var takes: [String] = []
        for (index, spec) in specs.enumerated() {
            let note = try ops.createPost(title: spec.title, entryDate: spec.day)
            let block = try ops.seedBlock(in: note.id, text: "the lantern number \(index)")
            ids.append(note.id)
            takes.append(block.variant.id)
        }
        // Edited later, out of birth order: 3, then 0, then 5.
        for index in [3, 0, 5] {
            try ops.autosave(takes[index], text: "the lantern number \(index), again", charDelta: 7)
        }
        return ids
    }

    @Test func eachHomeOrderListsTheGroupsInTheLibrarysOwnOrderAcrossPages() throws {
        try withOperations { ops, db in
            let ids = try sixNotes(ops)
            #expect(Set(try catalogOrder(db, .lastTouched, .desc)) == Set(ids), "premise: the fixture is the store")
            var orders: Set<[String]> = []
            for sort in offered {
                for direction in [SortDirection.desc, .asc] {
                    let expected = try catalogOrder(db, sort, direction)
                    for limit in [1, 2, 25] {
                        let listed = try ordered(db, "lantern", .home(sort, direction), limit: limit)
                        #expect(listed.map(\.homeID) == expected,
                                "\(sort) \(direction), \(limit) a page: the sheet's groups in the Library's own order")
                        #expect(listed.allSatisfy { $0.lineCount == 1 && $0.lines.count == 1 })
                    }
                    orders.insert(expected)
                }
            }
            #expect(orders.count == 8, "premise: the eight orders are eight different lists (\(orders.count))")
        }
    }

    @Test func relevanceIsTheShippedStatementAndTheShippedOrder() throws {
        try withOperations { ops, db in
            _ = try sixNotes(ops)
            try db.read { db in
                let environment = try Queries.searchEnvironment(db)
                let shipped = try #require(try SearchComposer.groups(
                    ask("lantern"), scope: SearchScope(wingID: ""), after: nil, limit: 25, perGroup: 3,
                    environment: environment))
                let relevance = try #require(try SearchComposer.groups(
                    ask("lantern"), scope: SearchScope(wingID: ""), after: nil, limit: 25, perGroup: 3,
                    order: .relevance, environment: environment))
                #expect(relevance == shipped)
                #expect(!shipped.sql.contains("home_key"), "relevance selects no home key — byte for byte")
                let page = try Queries.searchGroups(db, query: ask("lantern"), scope: SearchScope(wingID: ""))
                let scores = page.groups.compactMap(\.bestScore)
                #expect(scores.count == 6 && scores == scores.sorted(), "best first")
            }
        }
    }

    /// The order re-ranks GROUPS; a group's own passages stay best-first
    /// under every order (the brief — the order never reshuffles a note).
    @Test func aGroupsPassagesKeepTheirBestFirstOrderUnderEveryOrder() throws {
        try withOperations { ops, db in
            let rich = try ops.createPost(title: "Rich")
            for text in ["lantern", "a lantern lantern lantern here", "one lantern among many many other words here"] {
                _ = try ops.seedBlock(in: rich.id, text: text)
            }
            let other = try ops.createPost(title: "Other")
            _ = try ops.seedBlock(in: other.id, text: "a lantern too")
            let best = try ordered(db, "lantern", .relevance, limit: 25)
                .first { $0.homeID == rich.id }?.lines.map(\.sourceID)
            #expect(best?.count == 3)
            for sort in offered {
                for direction in [SortDirection.desc, .asc] {
                    let lines = try ordered(db, "lantern", .home(sort, direction))
                        .first { $0.homeID == rich.id }?.lines.map(\.sourceID)
                    #expect(lines == best, "\(sort) \(direction): the note's passages in their best-first order")
                }
            }
        }
    }

    /// Scraps groups take their place by their POOL's key, the notes' rule.
    @Test func aScrapsGroupTakesItsPlaceByItsPoolsKey() throws {
        try withOperations { ops, db in
            let first = try ops.createPost(title: "First")
            _ = try ops.seedBlock(in: first.id, text: "a lantern note")
            let pool = try ops.createPool(title: "Heap")
            _ = try ops.seedBlock(in: pool.id, text: "a lantern scrap")
            let last = try ops.createPost(title: "Last")
            _ = try ops.seedBlock(in: last.id, text: "another lantern note")
            #expect(try ordered(db, "lantern", .home(.createdAt, .asc), limit: 1).map(\.homeID)
                    == [first.id, pool.id, last.id])
            #expect(try ordered(db, "lantern", .home(.createdAt, .desc), limit: 1).map(\.homeID)
                    == [last.id, pool.id, first.id])
        }
    }

    /// **The worn-day corner** (R-13o-6): under relevance the nameless notes
    /// wearing the named day LEAD; under a home order each takes its place
    /// in the order — a worn-ONLY note (no index hit, so no row of the
    /// statement) placed by its key on the page whose range holds it, a worn
    /// note WITH hits listed once at its own place — every group once,
    /// across the pages, the band's count and the sheet in agreement.
    @Test func aNamelessNoteWearingTheDayTakesItsPlaceInTheOrder() throws {
        try withOperations { ops, db in
            let early = try ops.createPost(title: "Logbook")
            _ = try ops.seedBlock(in: early.id, text: "september 14 was grey")
            let wornOnly = try ops.createPost(entryDate: "2026-09-14")
            _ = try ops.seedBlock(in: wornOnly.id, text: "nothing matching here")
            let wornHit = try ops.createPost(entryDate: "2026-09-14")
            _ = try ops.seedBlock(in: wornHit.id, text: "we met on september 14")
            let late = try ops.createPost(title: "Diary")
            _ = try ops.seedBlock(in: late.id, text: "september 14 again")

            // Relevance: the worn notes lead (unchanged).
            let relevance = try ordered(db, "september 14", .relevance, limit: 25).map(\.homeID)
            #expect(Set(relevance.prefix(2)) == [wornOnly.id, wornHit.id])

            let birth = [early.id, wornOnly.id, wornHit.id, late.id]
            for limit in [1, 2, 3, 25] {
                #expect(try ordered(db, "september 14", .home(.createdAt, .asc), limit: limit).map(\.homeID) == birth,
                        "created ↑, \(limit) a page: each in its place, once")
                #expect(try ordered(db, "september 14", .home(.createdAt, .desc), limit: limit).map(\.homeID)
                        == birth.reversed(), "created ↓, \(limit) a page")
                // The date order: the two worn notes' stated day (Sep 14)
                // follows both births (Jul 1) — VX-758's rule.
                let byDate = try ordered(db, "september 14", .home(.entryDate, .asc), limit: limit).map(\.homeID)
                #expect(byDate == [early.id, late.id] + [wornOnly.id, wornHit.id].sorted(),
                        "date ↑, \(limit) a page: \(byDate)")
            }
            let sheet = try ordered(db, "september 14", .home(.createdAt, .asc), limit: 1)
            #expect(sheet.first { $0.homeID == wornOnly.id }.map { $0.titleMatched && $0.hitCount == 1 } == true,
                    "the worn-only note keeps its honest 1-hit head")
            #expect(sheet.first { $0.homeID == wornHit.id }?.titleMatched == true,
                    "a worn note with hits says its name matched on any page")
            let counted = try db.read { db in
                try Queries.searchCounts(db, query: ask("september 14"), scope: SearchScope(wingID: ""))
            }
            #expect(counted?.living.notes == sheet.count, "the band's notes are the sheet's groups")
        }
    }

    /// The Swift half of the order agrees with SQLite's: `BINARY` is the
    /// UTF-8 bytes then length, `NOCASE` folds the 26 ASCII capitals only.
    @Test func theOrdersSwiftComparisonIsSQLitesOwn() throws {
        let words = ["apple", "Apple", "APPLE pie", "banana", "Émile", "émile", "zoe", "Zoe", "", "a", "ab", "aB"]
        try withOperations { _, db in
            for nocase in [false, true] {
                let sqlite = try db.read { db in
                    try String.fetchAll(
                        db,
                        sql: "SELECT value FROM json_each(?) ORDER BY value\(nocase ? " COLLATE NOCASE" : ""), value",
                        arguments: [String(decoding: try JSONEncoder().encode(words), as: UTF8.self)])
                }
                let swift = words.sorted {
                    let c = SearchOrder.compareText($0, $1, foldingCase: nocase)
                    return c != 0 ? c < 0 : SearchOrder.compareText($0, $1, foldingCase: false) < 0
                }
                #expect(swift == sqlite, "nocase \(nocase): \(swift) vs \(sqlite)")
            }
        }
    }

    /// **One case-folding truth** (the VX-819 ladder's F5): the Swift merge's
    /// fold (`SearchOrder.foldsCase`) and the statement's collation
    /// (`LibrarySort.keyCollation`) both read `LibrarySort.foldsCase`, for
    /// every sort the Library knows and both directions. A GUARD (no bug was
    /// claimed — the two copies agreed): a future restated literal on either
    /// side fails here.
    @Test func theSwiftFoldAndTheStatementsCollationAreOneTruth() {
        let every: [Queries.LibrarySort] = [.lastTouched, .createdAt, .entryDate, .lastMajorRevision, .title]
        for sort in every {
            #expect(sort.keyCollation == (sort.foldsCase ? " COLLATE NOCASE" : ""), "\(sort): the SQL reads the truth")
            for direction in [SortDirection.desc, .asc] {
                #expect(SearchOrder.home(sort, direction).foldsCase == sort.foldsCase,
                        "\(sort) \(direction): the Swift merge reads the same truth")
            }
        }
        #expect(Queries.LibrarySort.title.foldsCase, "the title's key folds — the catalog's own NOCASE")
        #expect(!SearchOrder.relevance.foldsCase, "relevance has no key to fold")
    }

    // MARK: - P1: a home order is the same walk, driven by the index

    @Test func everyHomeOrderedStatementStaysDrivenByTheIndex() throws {
        let db = try AppDatabase.inMemory()
        let plans: [(String, String)] = try db.read { db in
            let environment = try Queries.searchEnvironment(db)
            var out: [(String, String)] = []
            for sort in offered {
                for cursor in [nil, SearchComposer.GroupCursor(best: 0, homeID: "x", key: "k")] {
                    let statement = try #require(try SearchComposer.groups(
                        ask("harbor lights"), scope: SearchScope(wingID: ""), after: cursor,
                        limit: 25, perGroup: 3, order: .home(sort, .desc), environment: environment))
                    let plan = try Row.fetchAll(
                        db, sql: "EXPLAIN QUERY PLAN " + statement.sql,
                        arguments: Queries.arguments(statement.arguments))
                        .map { $0["detail"] as String }.joined(separator: "\n")
                    out.append(("\(sort) cursor \(cursor != nil)", plan))
                }
            }
            return out
        }
        for (name, plan) in plans {
            #expect(plan.contains("SCAN search_fts VIRTUAL TABLE INDEX"), "\(name): the FTS index drives:\n\(plan)")
            for alias in ["d", "pl", "c", "b", "r", "container", "variant", "search_doc", "block"] {
                #expect(!plan.split(separator: "\n").contains { $0 == "SCAN \(alias)" || $0.hasPrefix("SCAN \(alias) ") },
                        "\(name): SCAN \(alias) is a corpus walk:\n\(plan)")
            }
        }
    }
}
