//
//  SearchGroupsTests.swift
//  VariorumCoreTests
//
//  13o U2, P1 — the answer sheet's core (Direction C, R-13o-15): the
//  composer's GROUP page (matches grouped by home, ranked by their best hit,
//  keyset-paged, top passages per group with snippets) and the COUNTS (the
//  band's honest per-kind numbers, living and under the facet), both over
//  the ONE hits builder `passages` already composes on; the `.docKind` leaf
//  (the Library's Blocks scope); the `DayBounds` range (the `when ▾` door).
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

private var utc: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    return calendar
}

private func parse(
    _ text: String, visibility: SearchVisibility = .living, filter: SearchFilter? = nil
) -> SearchQuery {
    var query = SearchQueryParser.parse(
        text, typeAhead: true, visibility: visibility, locale: Locale(identifier: "en_US"), calendar: utc)
    if let filter { query.filter = query.filter.map { .all([$0, filter]) } ?? filter }
    return query
}

private func groups(
    _ db: AppDatabase, _ text: String, wing: String = "", visibility: SearchVisibility = .living,
    filter: SearchFilter? = nil, after: SearchComposer.GroupCursor? = nil, limit: Int = 25,
    perGroup: Int = 3
) throws -> SearchGroupPage {
    try db.read { db in
        try Queries.searchGroups(
            db, query: parse(text, visibility: visibility, filter: filter),
            scope: SearchScope(wingID: wing), after: after, limit: limit, perGroup: perGroup,
            calendar: utc)
    }
}

private func counts(
    _ db: AppDatabase, _ text: String, wing: String = "", filter: SearchFilter? = nil
) throws -> SearchCounts? {
    try db.read { db in
        try Queries.searchCounts(
            db, query: parse(text, filter: filter), scope: SearchScope(wingID: wing), calendar: utc)
    }
}

/// Every group of a question, by paging to the end.
private func allGroups(
    _ db: AppDatabase, _ text: String, visibility: SearchVisibility = .living, limit: Int = 25
) throws -> [SearchGroup] {
    var all: [SearchGroup] = []
    var cursor: SearchComposer.GroupCursor?
    var pages = 0
    repeat {
        let page = try groups(db, text, visibility: visibility, after: cursor, limit: limit)
        all += page.groups
        cursor = page.next
        pages += 1
    } while cursor != nil && pages < 50
    return all
}

@Suite("13o U2 — the answer sheet's groups and counts")
struct SearchGroupsTests {
    // MARK: - Grouping

    @Test func passagesGroupUnderTheirHomeBestFirstWithTheTitleAsTheHead() throws {
        try withOperations { ops, db in
            let night = try ops.createPost(title: "The Night Office")
            for i in 0..<5 {
                _ = try ops.newBlock(in: night.id, text: "the dream number \(i) still wet on everything")
            }
            let titled = try ops.createPost(title: "A Dream Within a Dream")
            let quiet = try ops.createPost(title: "Quiet")
            let quietBlock = try ops.newBlock(in: quiet.id, text: "a dream once")

            let page = try groups(db, "dream ")
            #expect(Set(page.groups.map(\.homeID)) == [night.id, titled.id, quiet.id],
                    "one group per home, never one row per passage")
            #expect(page.groups.first?.homeID == titled.id, "a title hit outranks prose (its best hit leads)")

            let nightGroup = try #require(page.groups.first { $0.homeID == night.id })
            #expect(nightGroup.lineCount == 5 && nightGroup.hitCount == 5 && !nightGroup.titleMatched)
            #expect(nightGroup.lines.count == 3, "the top three passages ride the page; the rest wait behind all N ›")
            #expect(nightGroup.lines.allSatisfy { $0.kind == .take && $0.noteID == night.id })
            #expect(nightGroup.lines.allSatisfy { $0.snippet.contains { $0.isMatch && $0.text.lowercased() == "dream" } })
            #expect(nightGroup.note?.id == night.id && nightGroup.note?.kind == .post
                    && nightGroup.note?.title == "The Night Office", "the head is the catalog's own hit")

            let titledGroup = try #require(page.groups.first { $0.homeID == titled.id })
            #expect(titledGroup.titleMatched && titledGroup.lineCount == 0 && titledGroup.lines.isEmpty,
                    "a title-only match is a head with no lines — the title is never a line under itself")

            let quietGroup = try #require(page.groups.first { $0.homeID == quiet.id })
            #expect(quietGroup.lines.map(\.sourceID) == [quietBlock.variant.id])
        }
    }

    @Test func booksAndChaptersAreNotGroupsAndScrapsGroupUnderTheirPool() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "Lantern Book", kind: .book)
            _ = try ops.createSection(in: book.id, name: "Lantern Chapter")
            let pool = try ops.createPool(title: "Heap")
            let scrap = try ops.newBlock(in: pool.id, text: "a lantern scrap")
            let wing = try ops.createWing(name: "Away")

            let page = try groups(db, "lantern ")
            #expect(page.groups.map(\.homeID) == [pool.id], "book and chapter hits are the Books section's")
            #expect(page.groups.first?.isPool == true && page.groups.first?.note == nil)
            #expect(page.groups.first?.lines.map(\.sourceID) == [scrap.variant.id])
            #expect(page.groups.first?.homeTitle == "Heap")
            #expect(try groups(db, "lantern ", wing: wing.id).groups.map(\.homeID) == [pool.id],
                    "scraps list in every wing — the shared room (P-13o-U1-5, RATIFIED)")
        }
    }

    // MARK: - Paging — a road to every group (R-13o-9)

    @Test func everyGroupIsReachableByPagingAndNoneTwice() throws {
        try withOperations { ops, db in
            var expected: Set<String> = []
            for i in 0..<57 {
                let note = try ops.createPost(title: "note \(i)")
                for j in 0..<(1 + i % 4) {
                    _ = try ops.newBlock(in: note.id, text: "quokka \(j) \(String(repeating: "pad ", count: i % 9))")
                }
                expected.insert(note.id)
            }
            var seen: [String] = []
            var cursor: SearchComposer.GroupCursor?
            var pages = 0
            repeat {
                let page = try groups(db, "quokka ", after: cursor, limit: 20)
                seen += page.groups.map(\.homeID)
                #expect(page.groups.allSatisfy { $0.lines.count == min(3, $0.lineCount) })
                cursor = page.next
                pages += 1
            } while cursor != nil && pages < 10
            #expect(pages == 3, "20 + 20 + 17")
            #expect(seen.count == 57 && Set(seen) == expected, "every group, exactly once")

            // Best first, across the page boundaries.
            let bests = try allGroups(db, "quokka ", limit: 20).compactMap(\.bestScore)
            #expect(bests == bests.sorted(), "the groups are ranked by their best hit throughout")
        }
    }

    // MARK: - The counts are the listing's (the band never claims what the sheet does not hold)

    @Test func theCountsAreExactlyWhatTheSheetLists() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "Orchid Book", kind: .book)
            _ = try ops.createSection(in: book.id, name: "Orchid Chapter")
            let other = try ops.createReading(name: "Second Orchid", kind: .book)
            let titled = try ops.createPost(title: "Orchid")
            _ = try ops.newBlock(in: titled.id, text: "orchid on the sill")
            let prose = try ops.createPost(title: "Plain")
            let block = try ops.newBlock(in: prose.id, text: "an orchid")
            _ = try ops.branchVariant(block.block.id, from: block.variant.id)
            try ops.setBlockName(block.block.id, name: "orchid name")
            let pool = try ops.createPool(title: "Heap")
            _ = try ops.newBlock(in: pool.id, text: "orchid scrap one")
            _ = try ops.newBlock(in: pool.id, text: "orchid scrap two")
            let stored = try ops.createPost(title: "Stored orchid")
            try ops.archiveContainer(stored.id)

            let c = try #require(try counts(db, "orchid "))
            let sheet = try allGroups(db, "orchid ")
            let books = try db.read { db in
                try Queries.searchPassages(
                    db, query: parse("orchid ", filter: .family(.books)), scope: SearchScope(wingID: ""),
                    limit: 500, calendar: utc)
            }
            #expect(c.living.books == Set(books.passages.compactMap(\.readingID)).count && c.living.books == 2,
                    "a book counts once, however many of its names match")
            #expect(c.living.notes == sheet.filter { !$0.isPool }.count && c.living.notes == 2)
            #expect(c.living.passages == sheet.filter { !$0.isPool }.map(\.lineCount).reduce(0, +)
                    && c.living.passages == 4, "takes (×2), the block name, the titled note's take")
            #expect(c.living.scraps == sheet.filter(\.isPool).map(\.lineCount).reduce(0, +) && c.living.scraps == 2)
            #expect(c.archivedPlaces == 1, "the archived note is what the facet would add")
            #expect(c.all.notes == 3 && c.kinds(.includingArchived) == c.all && c.kinds(.living) == c.living)
            #expect(try allGroups(db, "orchid ", visibility: .includingArchived).filter { !$0.isPool }.count
                    == c.all.notes, "…and the facet's numbers are its sheet's")
            #expect(try counts(db, "— ") == nil, "no words, no numbers")
            _ = other
        }
    }

    // MARK: - The worn day (R-13o-6) leads, merged with its own group

    @Test func theWornDayLeadsTheFirstPageAsOneGroup() throws {
        try withOperations { ops, db in
            let dated = try ops.createPost(entryDate: "2026-09-14")
            _ = try ops.newBlock(in: dated.id, text: "september came in grey")
            let other = try ops.createPost(title: "Calendar")
            _ = try ops.newBlock(in: other.id, text: "september 14 was a tuesday")

            let page = try groups(db, "september 14")
            #expect(page.groups.first?.homeID == dated.id, "the nameless note wearing the day leads")
            #expect(page.groups.filter { $0.homeID == dated.id }.count == 1, "one group, never two")
            #expect(page.groups.first?.titleMatched == true)
            #expect(Set(page.groups.map(\.homeID)) == [dated.id, other.id])
            let c = try #require(try counts(db, "september 14"))
            #expect(c.living.notes == 2, "the worn note is counted once")
        }
    }

    /// Ladder round 1, MINOR-1 (red-on-old, verified by revert): a worn note
    /// whose BODY hits rank beyond the page still leads with its TRUE group
    /// facts — hit and line counts read in ONE counts-style statement over
    /// the missing worn ids (`SearchComposer.wornGroupFacts`) — so the lead
    /// group carries a real "all N ›" road instead of the fabricated 1/0
    /// stub (R-13o-9: no listing without a road; the model's page dedupe
    /// would otherwise drop the ranked group and its lines with it). The
    /// next-page cursor stays sourced from the page's own groups, and a
    /// worn-ONLY note keeps its honest 1-hit head.
    @Test func aWornNoteRankedBeyondThePageLeadsWithItsTrueCounts() throws {
        try withOperations { ops, db in
            let titled = try ops.createPost(title: "September 14 Logbook")
            _ = try ops.newBlock(in: titled.id, text: "september 14 september 14 all day")
            let worn = try ops.createPost(entryDate: "2026-09-14")
            _ = try ops.newBlock(in: worn.id, text: "we met on september 14")
            _ = try ops.newBlock(in: worn.id, text: "september 14 again, later")

            let page = try groups(db, "september 14", limit: 1)
            #expect(page.groups.map(\.homeID) == [worn.id, titled.id],
                    "the worn note leads; the page's one ranked group follows")
            let lead = try #require(page.groups.first)
            #expect(lead.hitCount == 2 && lead.lineCount == 2,
                    "TRUE facts over the worn ids — never a fabricated 1/0")
            #expect(lead.titleMatched && lead.lines.isEmpty,
                    "counts-style: the road's numbers, not preview lines")
            #expect(lead.bestScore != nil, "its best hit's score rides too")
            #expect(page.next?.homeID == titled.id,
                    "the keyset cursor stays the page's own groups' — the lead never moves it")

            // The worn-ONLY control: no body hits, the honest 1-hit head.
            let bare = try ops.createPost(entryDate: "2026-09-15")
            _ = try ops.newBlock(in: bare.id, text: "nothing matching here")
            let barePage = try groups(db, "september 15", limit: 25)
            let bareLead = try #require(barePage.groups.first { $0.homeID == bare.id })
            #expect(bareLead.hitCount == 1 && bareLead.lineCount == 0 && bareLead.bestScore == nil)
        }
    }

    // MARK: - The Blocks scope's leaf

    @Test func theDocKindLeafNarrowsToOneKind() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "Ember")
            let named = try ops.newBlock(in: note.id, text: "ember prose")
            try ops.setBlockName(named.block.id, name: "ember name")
            let pool = try ops.createPool(title: "Heap")
            _ = try ops.newBlock(in: pool.id, text: "ember scrap")
            let blocks: SearchFilter = .any([.family(.scraps), .docKind(.blockName)])
            let page = try groups(db, "ember ", filter: blocks)
            #expect(Set(page.groups.map(\.homeID)) == [note.id, pool.id])
            #expect(page.groups.first { $0.homeID == note.id }?.lines.map(\.kind) == [.blockName],
                    "the note's prose and title stand aside; its block NAME is a block hit")
            #expect(SearchComposer.composeFilter(.docKind(.title), level: .note, wingID: "",
                                                 environment: try db.read { try Queries.searchEnvironment($0) }).sql == "1")
            #expect(Set(SearchDocKind.allCases.map(\.rawValue)) == Set(SearchIndex.sources.map(\.kind)),
                    "the leaf's vocabulary IS the index's")
        }
    }

    // MARK: - The Books section's rows (the catalog's own words)

    @Test func theBooksSectionReadsTheNamedBooksInTheOrderGiven() throws {
        try withOperations { ops, db in
            let first = try ops.createReading(name: "Zinnia", kind: .book)
            let gathering = try ops.createReading(
                name: "Aster", kind: .gathering, querySpec: try RuleGrammar.encode(.star))
            let gone = try ops.createReading(name: "Gone", kind: .book)
            try ops.deleteReading(gone.id)
            let hits = try db.read { db in
                try Queries.catalogBookHits(db, ids: [first.id, gone.id, gathering.id, "missing"])
            }
            #expect(hits.map(\.id) == [first.id, gathering.id], "in the order given; dead and missing dropped")
            #expect(hits.map(\.detail) == ["book", "gathering"], "the catalog's own nouns")
            #expect(hits.allSatisfy { $0.kind == .book })
            let listed = try db.read { try Queries.catalogBooks($0, query: "", limit: nil) }
            #expect(listed.first { $0.id == first.id } == hits.first,
                    "the same row the listing draws — one builder")
            #expect(try db.read { try Queries.catalogBookHits($0, ids: []) }.isEmpty)
        }
    }

    // MARK: - The range (the when door)

    @Test func aDayRangeTilesFirstThroughLastInclusive() throws {
        let range = try #require(DayBounds(firstDay: "2026-09-01", lastDay: "2026-09-14", calendar: utc))
        #expect(range.start == "2026-09-01T00:00:00.000Z" && range.end == "2026-09-15T00:00:00.000Z")
        #expect(range.day == "2026-09-01")
        #expect(DayBounds(firstDay: "2026-09-14", lastDay: "2026-09-14", calendar: utc)
                == DayBounds(day: "2026-09-14", calendar: utc), "one day is exactly one day")
        #expect(DayBounds(firstDay: "2026-09-14", lastDay: "2026-09-01", calendar: utc) == nil)
        #expect(DayBounds(firstDay: "2026-02-30", lastDay: "2026-03-01", calendar: utc) == nil)
        // Across a DST change, each end is the calendar's own.
        var newYork = Calendar(identifier: .gregorian)
        newYork.timeZone = TimeZone(identifier: "America/New_York")!
        let spring = try #require(DayBounds(firstDay: "2026-03-07", lastDay: "2026-03-08", calendar: newYork))
        #expect(spring.start == DayBounds(day: "2026-03-07", calendar: newYork)?.start
                && spring.end == DayBounds(day: "2026-03-08", calendar: newYork)?.end)
    }

    // MARK: - The plans

    @Test func theGroupAndCountStatementsAreDrivenByTheIndex() throws {
        let db = try AppDatabase.inMemory()
        let plans: [String] = try db.read { db in
            let environment = try Queries.searchEnvironment(db)
            var query = parse("harbor lights")
            query.filter = .all([.tagPath("life"), .family(.notes)])
            let group = try #require(try SearchComposer.groups(
                query, scope: SearchScope(wingID: ""), after: SearchComposer.GroupCursor(best: -1, homeID: "x"),
                limit: 25, perGroup: 3, environment: environment))
            let count = try #require(try SearchComposer.counts(
                query, scope: SearchScope(wingID: ""), wornLivingNoteIDs: "[]", wornAllNoteIDs: "[]",
                wornArchivedNoteIDs: "[]", environment: environment))
            return try [group, count].map { statement in
                try Row.fetchAll(db, sql: "EXPLAIN QUERY PLAN " + statement.sql,
                                 arguments: Queries.arguments(statement.arguments))
                    .map { $0["detail"] as String }.joined(separator: "\n")
            }
        }
        for plan in plans {
            #expect(plan.contains("SCAN search_fts VIRTUAL TABLE INDEX"), "the FTS index drives:\n\(plan)")
            #expect(plan.contains("SEARCH pl USING INDEX uq_cblock_ownership (block_id=?)"), "homes by I2:\n\(plan)")
            for alias in ["d", "pl", "c", "b", "r", "container", "variant", "search_doc"] {
                #expect(!plan.split(separator: "\n").contains { $0 == "SCAN \(alias)" || $0.hasPrefix("SCAN \(alias) ") },
                        "SCAN \(alias) is a corpus walk:\n\(plan)")
            }
        }
        // ONE walk ranks the groups (materialized), one more cuts the
        // snippets for the page's top rows only.
        #expect(plans[0].components(separatedBy: "SCAN search_fts VIRTUAL TABLE INDEX").count - 1 == 2,
                "two walks of the matches, never one per group:\n\(plans[0])")
        #expect(plans[0].contains("MATERIALIZE scored"), "the ranked matches are read once:\n\(plans[0])")
        #expect(plans[1].components(separatedBy: "SCAN search_fts VIRTUAL TABLE INDEX").count - 1 == 1,
                "the counts walk the matches once:\n\(plans[1])")
    }
}
