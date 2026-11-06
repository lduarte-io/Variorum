//
//  SearchFacetTests.swift
//  VariorumCoreTests
//
//  VX-819 batch 1 — the Library's FACETS (the scope picker in the search
//  state, `SearchFacet`) and the numbers each facet's band says.
//
//  VX-734, her report: the Blocks facet said "Nothing matches" while the
//  band counted "3 notes · 6 passages". Her ruling R-819-1 (*"Widen Blocks"*):
//  the facet lists every block-level match "and its band counts what it
//  lists"; the sitting's coherent extension, PROVISIONAL: every facet's band
//  counts what that facet lists, All keeps the whole question's numbers — the
//  header can never disagree with the body.
//
//  The traced mechanism (the batch record's LIVE STATUS): the band read the
//  UN-scoped question's counts (D3, P-13o-U2-2) while each facet listed its
//  own narrowed answer. RED-ON-OLD: the counts pins below fail on the tree
//  whose facet-aware read still returns the whole question's numbers
//  (`8c2a25a99`, the behavior-preserving move of the facets to core) —
//  verified by reverting `Queries/SearchQueries.swift` to it.
//

import Foundation
import GRDB
import Testing

@testable import VariorumCore

private func question(_ text: String, visibility: SearchVisibility = .living) -> SearchQuery {
    SearchQueryParser.parse(text, typeAhead: true, visibility: visibility, locale: Locale(identifier: "en_US"))
}

private func counts(_ db: AppDatabase, _ query: SearchQuery, _ facet: SearchFacet) throws -> SearchCounts? {
    try db.read { db in
        try Queries.searchCounts(db, query: query, facet: facet, scope: SearchScope(wingID: ""))
    }
}

/// What a facet's answer sheet LISTS for a question with words: its groups
/// (paged to the end — every group has a road, R-13o-9) and the books its
/// Books section names (the name hits; this file's word questions carry no
/// typed tag, so no association joins them).
private struct SheetListing {
    let noteGroups: [SearchGroup]
    let poolGroups: [SearchGroup]
    let books: Set<String>

    var passages: Int { noteGroups.map(\.lineCount).reduce(0, +) }
    var scraps: Int { poolGroups.map(\.lineCount).reduce(0, +) }
}

private func sheet(_ db: AppDatabase, _ query: SearchQuery, _ facet: SearchFacet) throws -> SheetListing {
    let asked = facet.narrowing(query)
    return try db.read { db in
        var groups: [SearchGroup] = []
        var cursor: SearchComposer.GroupCursor?
        var pages = 0
        repeat {
            let page = try Queries.searchGroups(
                db, query: asked, scope: SearchScope(wingID: ""), after: cursor, limit: 25, perGroup: 3)
            groups += page.groups
            cursor = page.next
            pages += 1
        } while cursor != nil && pages < 50
        var books: Set<String> = []
        var passageCursor: SearchComposer.Cursor?
        repeat {
            let page = try Queries.searchPassages(
                db, query: asked, scope: SearchScope(wingID: ""), after: passageCursor, limit: 200)
            books.formUnion(page.passages.filter { $0.family == .books }.compactMap(\.readingID))
            passageCursor = page.next
        } while passageCursor != nil
        return SheetListing(
            noteGroups: groups.filter { !$0.isPool }, poolGroups: groups.filter(\.isPool), books: books)
    }
}

@Suite("VX-819 batch 1 — the Library's facets and their bands")
struct SearchFacetTests {
    /// One word, "orchid", in every kind the index holds: two book names and
    /// a chapter; a note's TITLE (and its take); takes, a block NAME, a take
    /// LABEL, a COMMENT and the FLOATING NOTES inside notes; two scraps; an
    /// archived note's title.
    private struct Orchids {
        let titled: Container, plain: Container, margins: Container, pool: Container, stored: Container
    }

    private func orchids(_ ops: Operations) throws -> Orchids {
        let book = try ops.createReading(name: "Orchid Book", kind: .book)
        _ = try ops.createSection(in: book.id, name: "Orchid Chapter")
        _ = try ops.createReading(name: "Second Orchid", kind: .book)
        let titled = try ops.createPost(title: "Orchid")
        _ = try ops.newBlock(in: titled.id, text: "orchid on the sill")
        let plain = try ops.createPost(title: "Plain")
        let block = try ops.newBlock(in: plain.id, text: "an orchid")
        _ = try ops.branchVariant(block.block.id, from: block.variant.id)
        try ops.setBlockName(block.block.id, name: "orchid name")
        let margins = try ops.createPost(title: "Margins")
        let quiet = try ops.newBlock(in: margins.id, text: "nothing to see")
        _ = try ops.addBlockComment(to: quiet.block.id, text: "an orchid comment")
        try ops.setTakeLabel(quiet.variant.id, label: "orchid take")
        try ops.updateFloatingNotes(margins.id, notes: "orchid floating")
        let pool = try ops.createPool(title: "Heap")
        _ = try ops.newBlock(in: pool.id, text: "orchid scrap one")
        _ = try ops.newBlock(in: pool.id, text: "orchid scrap two")
        let stored = try ops.createPost(title: "Stored orchid")
        try ops.archiveContainer(stored.id)
        return Orchids(titled: titled, plain: plain, margins: margins, pool: pool, stored: stored)
    }

    // MARK: - With words: each facet's band counts its own sheet (R-819-1)

    /// RED-ON-OLD (the bug's own screen, VX-734): under a picked facet the
    /// band said the WHOLE question's numbers — books and scraps under Notes,
    /// notes and passages the Blocks facet never listed.
    @Test func aPickedFacetsBandCountsExactlyWhatItsSheetLists() throws {
        try withOperations { ops, db in
            _ = try orchids(ops)
            let asked = question("orchid ")
            for facet in [SearchFacet.notes, .books, .blocks] {
                let c = try #require(try counts(db, asked, facet), "\(facet): words always count")
                let listed = try sheet(db, asked, facet)
                #expect(c.living.notes == listed.noteGroups.count, "\(facet): notes = its note groups")
                #expect(c.living.passages == listed.passages, "\(facet): passages = its groups' lines")
                #expect(c.living.scraps == listed.scraps, "\(facet): scraps = its scraps groups' lines")
                #expect(c.living.books == listed.books.count, "\(facet): books = its Books section")
                #expect(c.living.blocks == 0 && c.living.savepoints == 0)
            }
            // The facets' own shapes, said plainly.
            let notes = try #require(try counts(db, asked, .notes))
            #expect(notes.living.books == 0 && notes.living.scraps == 0,
                    "Notes never counts the books or the scraps it does not list")
            #expect(notes.archivedPlaces == 1, "the archived note is what the facet would add under Notes")
            let books = try #require(try counts(db, asked, .books))
            #expect(books.living.books == 2 && books.living.notes == 0 && books.living.passages == 0
                    && books.living.scraps == 0, "Books counts its books alone")
            let blocks = try #require(try counts(db, asked, .blocks))
            #expect(blocks.living.books == 0, "Blocks never counts a book")
            #expect(blocks.archivedPlaces == 0, "the archived note holds no block-level hit")
        }
    }

    /// All is the whole question — the numbers that tell her what every
    /// facet holds (P-13o-U2-2's reading, kept for All alone).
    @Test func allKeepsTheWholeQuestionsNumbers() throws {
        try withOperations { ops, db in
            _ = try orchids(ops)
            let asked = question("orchid ")
            let whole = try db.read { db in
                try Queries.searchCounts(db, query: asked, scope: SearchScope(wingID: ""))
            }
            #expect(try counts(db, asked, .all) == whole)
            #expect(whole?.living.books == 2 && whole?.living.scraps == 2)
        }
    }

    /// The archived facet's numbers are the facet's too (`all` vs `living`).
    @Test func underTheArchivedFacetAFacetsNumbersAreStillItsSheets() throws {
        try withOperations { ops, db in
            _ = try orchids(ops)
            let asked = question("orchid ", visibility: .includingArchived)
            let c = try #require(try counts(db, asked, .notes))
            let listed = try sheet(db, asked, .notes)
            #expect(c.all.notes == listed.noteGroups.count && c.all.notes == 4,
                    "the archived note joins under the facet — and is counted")
        }
    }

    // MARK: - A tag alone: each facet counts the ONE kind it lists

    /// RED-ON-OLD: a `#tag` typed alone narrows the catalog's own listing
    /// (VX-84a) — Notes lists the tagged notes, Blocks the tagged blocks,
    /// Books the associated books — but the band counted all three under
    /// every facet.
    @Test func aTagAlonesBandUnderAFacetCountsTheOneKindThatFacetLists() throws {
        try withOperations { ops, db in
            let flora = try ops.createTag(name: "flora")
            let rose = try ops.createPost(title: "Rose")
            let inRose = try ops.newBlock(in: rose.id, text: "a red one")
            _ = try ops.applyTag(flora.id, toPost: rose.id)
            _ = try ops.applyTag(flora.id, toBlock: inRose.block.id)
            let lily = try ops.createPost(title: "Lily")
            _ = try ops.newBlock(in: lily.id, text: "a white one")
            _ = try ops.applyTag(flora.id, toPost: lily.id)
            try ops.archiveContainer(lily.id)
            let pool = try ops.createPool(title: "Heap")
            let scrap = try ops.newBlock(in: pool.id, text: "a loose petal")
            _ = try ops.applyTag(flora.id, toBlock: scrap.block.id)
            let garden = try ops.createReading(
                name: "Garden", kind: .book, querySpec: try RuleGrammar.encode(.tag(flora.id)))

            let asked = question("#flora")
            let whole = try #require(try counts(db, asked, .all))
            #expect(whole.living.notes == 1 && whole.all.notes == 2 && whole.living.blocks == 2
                    && whole.living.books == 1 && whole.archivedPlaces == 1,
                    "All: the whole question — every facet's holdings")

            let listedNotes = try db.read { db in
                try Queries.catalogNotesPage(db, query: "", limit: 50, wingID: "", narrowing: asked)
            }
            let notes = try #require(try counts(db, asked, .notes))
            #expect(notes.living.notes == listedNotes.hits.count && notes.living.notes == 1)
            #expect(notes.living.blocks == 0 && notes.living.books == 0 && notes.all.blocks == 0,
                    "Notes lists no block and no book — it counts none")
            #expect(notes.archivedPlaces == 1, "the archived note is what the facet would add there")

            let listedBlocks = try db.read { db in
                try Queries.catalogTaggedBlocks(db, narrowing: asked, wingID: "")
            }
            let blocks = try #require(try counts(db, asked, .blocks))
            #expect(blocks.living.blocks == listedBlocks.count && blocks.living.blocks == 2)
            #expect(blocks.living.notes == 0 && blocks.all.notes == 0 && blocks.living.books == 0,
                    "Blocks lists no note and no book — it counts none")
            #expect(blocks.archivedPlaces == 0, "no archived block — nothing the facet would add")

            let associated = try db.read { db in
                try Queries.searchTagAssociations(db, query: asked, scope: SearchScope(wingID: ""))
            }
            let books = try #require(try counts(db, asked, .books))
            #expect(books.living.books == associated.count && associated.map(\.readingID) == [garden.id])
            #expect(books.living.notes == 0 && books.living.blocks == 0 && books.archivedPlaces == 0,
                    "Books lists the associated books alone")
        }
    }

    /// A facet whose kind holds nothing says so (zero numbers, never nil —
    /// the question still answers in another facet, so its chips stay).
    @Test func aFacetWithNothingOfItsKindCountsZeroNotNothing() throws {
        try withOperations { ops, db in
            let flora = try ops.createTag(name: "flora")
            let rose = try ops.createPost(title: "Rose")
            _ = try ops.newBlock(in: rose.id, text: "a red one")
            _ = try ops.applyTag(flora.id, toPost: rose.id)
            let blocks = try #require(try counts(db, question("#flora"), .blocks))
            #expect(blocks.living.isEmpty && blocks.all.isEmpty)
            #expect(try counts(db, question("#nothing"), .blocks) == nil,
                    "a question that finds nothing anywhere still counts nothing (no band numbers)")
        }
    }

    // MARK: - P1: a facet narrows per examined match, never walks the corpus

    @Test func everyFacetsGroupAndCountStatementsStayDrivenByTheIndex() throws {
        let db = try AppDatabase.inMemory()
        let plans: [(SearchFacet, String)] = try db.read { db in
            let environment = try Queries.searchEnvironment(db)
            var out: [(SearchFacet, String)] = []
            for facet in SearchFacet.allCases {
                let asked = facet.narrowing(question("harbor lights"))
                let group = try #require(try SearchComposer.groups(
                    asked, scope: SearchScope(wingID: ""), after: SearchComposer.GroupCursor(best: -1, homeID: "x"),
                    limit: 25, perGroup: 3, environment: environment))
                let count = try #require(try SearchComposer.counts(
                    asked, scope: SearchScope(wingID: ""), wornLivingNoteIDs: "[]", wornAllNoteIDs: "[]",
                    wornArchivedNoteIDs: "[]", environment: environment))
                for statement in [group, count] {
                    let plan = try Row.fetchAll(
                        db, sql: "EXPLAIN QUERY PLAN " + statement.sql,
                        arguments: Queries.arguments(statement.arguments))
                        .map { $0["detail"] as String }.joined(separator: "\n")
                    out.append((facet, plan))
                }
            }
            return out
        }
        for (facet, plan) in plans {
            #expect(plan.contains("SCAN search_fts VIRTUAL TABLE INDEX"), "\(facet): the FTS index drives:\n\(plan)")
            for alias in ["d", "pl", "c", "b", "r", "container", "variant", "search_doc", "block"] {
                #expect(!plan.split(separator: "\n").contains { $0 == "SCAN \(alias)" || $0.hasPrefix("SCAN \(alias) ") },
                        "\(facet): SCAN \(alias) is a corpus walk:\n\(plan)")
            }
        }
    }
}
