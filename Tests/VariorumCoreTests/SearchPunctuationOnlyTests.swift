//
//  SearchPunctuationOnlyTests.swift
//  VariorumCoreTests
//
//  VX-888 (VX-915 batch 5) — the REPRO for the vx-819 batch-1 observation:
//  *"a question whose only 'words' are punctuation (e.g. `— #tag`) has
//  `text != nil` but nothing the index can serve — the sheet lists no groups
//  while the band reads the no-words branch's tag numbers."*
//
//  The pin is the observation's own claim, stated as the counts law it would
//  break (SurfaceContracts, The Library: "under a picked facet the band counts
//  what that facet lists; All keeps the whole question's counts"): for such a
//  question, under All and under every picked facet (VX-734's path), the band
//  (`Queries.searchCounts(…facet:…)`) says exactly what the Library SHOWS.
//  "What it shows" is the app's own routing, read here in core over the same
//  reads the app calls (`LibraryCatalogModel.listing` + `LibrarySearchModel
//  .listing` / `.books`): a question with WORDS (`query.text != nil` — the
//  app's `LibrarySearchQuestion.hasWords`) gets the answer sheet — its groups
//  and its Books section; a `#tag` alone gets the catalog's narrowed listing —
//  the tagged notes, the tagged blocks under Blocks, the associated books.
//
//  The verdict is recorded in `notes/plans/fixes/vx-915-recents-sweep.md`,
//  BATCH 5 — LIVE STATUS.
//

import Foundation
import GRDB
import Testing

@testable import VariorumCore

private func question(_ text: String) -> SearchQuery {
    SearchQueryParser.parse(text, typeAhead: true, visibility: .living, locale: Locale(identifier: "en_US"))
}

/// What the Library lists for a question under a facet (the app's routing).
private struct Shown: Equatable, CustomStringConvertible {
    var notes: Set<String> = []
    var passages = 0
    var scraps = 0
    var books: Set<String> = []
    var blocks: Set<String> = []

    var description: String {
        "notes \(notes.count) · passages \(passages) · scraps \(scraps) · books \(books.count) · blocks \(blocks.count)"
    }
}

private let library = SearchScope(wingID: "")

private func shown(_ db: AppDatabase, _ asked: SearchQuery, _ facet: SearchFacet) throws -> Shown {
    try db.read { db in
        var out = Shown()
        // The app's `hasWords` (`LibrarySearchQuestion.hasWords`): the field's
        // question has a text half.
        let hasWords = asked.text != nil
        // The Books section (facets All and Books): the associated books, then
        // (with words) every book a book or chapter hit names — over the
        // question narrowed to Books, as `LibrarySearchModel.books` reads it.
        if facet == .all || facet == .books {
            let booksAsked = SearchFacet.books.narrowing(asked)
            out.books.formUnion(
                try Queries.searchTagAssociations(db, query: booksAsked, scope: library).map(\.readingID))
            if hasWords {
                var cursor: SearchComposer.Cursor?
                repeat {
                    let page = try Queries.searchPassages(
                        db, query: booksAsked, scope: library, after: cursor, limit: 200)
                    out.books.formUnion(page.passages.compactMap(\.readingID))
                    cursor = page.next
                } while cursor != nil
            }
        }
        if hasWords {
            // The answer sheet's groups (every facet but Books), paged to the end.
            guard facet != .books else { return out }
            var cursor: SearchComposer.GroupCursor?
            var pages = 0
            repeat {
                let page = try Queries.searchGroups(
                    db, query: facet.narrowing(asked), scope: library, after: cursor, limit: 25, perGroup: 3)
                for group in page.groups {
                    if group.isPool {
                        out.scraps += group.lineCount
                    } else {
                        out.notes.insert(group.homeID)
                        out.passages += group.lineCount
                    }
                }
                cursor = page.next
                pages += 1
            } while cursor != nil && pages < 50
            return out
        }
        // A tag alone: the catalog's own narrowed listing (VX-84a, D-1).
        if facet == .all || facet == .notes {
            var cursor: Queries.CatalogCursor?
            var pages = 0
            repeat {
                let page = try Queries.catalogNotesPage(
                    db, query: "", after: cursor, limit: 50, wingID: "", narrowing: asked)
                out.notes.formUnion(page.hits.map(\.id))
                cursor = page.next
                pages += 1
            } while cursor != nil && pages < 50
        }
        if facet == .blocks {
            out.blocks.formUnion(try Queries.catalogTaggedBlocks(db, narrowing: asked, wingID: "").map(\.id))
        }
        return out
    }
}

/// The band's numbers under a facet (the living corpus — the band's default).
private func band(_ db: AppDatabase, _ asked: SearchQuery, _ facet: SearchFacet) throws -> SearchCounts.Kinds {
    let counts = try db.read { db in
        try Queries.searchCounts(db, query: asked, facet: facet, scope: library)
    }
    return counts?.living ?? SearchCounts.Kinds(books: 0, notes: 0, passages: 0, scraps: 0)
}

@Suite("VX-888 — a question whose only words are punctuation: the band says what the Library shows")
struct SearchPunctuationOnlyTests {
    /// A tag, `flora`, on two notes (one also on a block of its own), on a
    /// scrap's block, and the rule of one living book — so every kind a tag
    /// alone lists has something in it.
    private func flora(_ ops: Operations) throws {
        let flora = try ops.createTag(name: "flora")
        let rose = try ops.createPost(title: "Rose")
        let inRose = try ops.newBlock(in: rose.id, text: "a red one")
        _ = try ops.applyTag(flora.id, toPost: rose.id)
        _ = try ops.applyTag(flora.id, toBlock: inRose.block.id)
        let lily = try ops.createPost(title: "Lily")
        _ = try ops.newBlock(in: lily.id, text: "a white one")
        _ = try ops.applyTag(flora.id, toPost: lily.id)
        let pool = try ops.createPool(title: "Heap")
        let scrap = try ops.newBlock(in: pool.id, text: "a loose petal")
        _ = try ops.applyTag(flora.id, toBlock: scrap.block.id)
        _ = try ops.createReading(
            name: "Garden", kind: .book, querySpec: try RuleGrammar.encode(.tag(flora.id)))
    }

    /// Checks the counts law for one question: each picked facet's band is
    /// what that facet shows; All's band is the whole question — what All
    /// shows, with the blocks the Blocks facet lists (All lists no block row).
    private func expectTheBandSaysWhatIsShown(
        _ db: AppDatabase, _ text: String, sourceLocation: SourceLocation = #_sourceLocation
    ) throws {
        let asked = question(text)
        for facet in [SearchFacet.notes, .books, .blocks] {
            let said = try band(db, asked, facet)
            let listed = try shown(db, asked, facet)
            #expect(said.notes == listed.notes.count && said.passages == listed.passages
                    && said.scraps == listed.scraps && said.books == listed.books.count
                    && said.blocks == listed.blocks.count,
                    "\(text) under \(facet): the band says \(said) but the Library shows \(listed)",
                    sourceLocation: sourceLocation)
        }
        let said = try band(db, asked, .all)
        let listed = try shown(db, asked, .all)
        let blocks = try shown(db, asked, .blocks).blocks.count
        #expect(said.notes == listed.notes.count && said.passages == listed.passages
                && said.scraps == listed.scraps && said.books == listed.books.count && said.blocks == blocks,
                "\(text) under All: the band says \(said) but the Library shows \(listed) (+ \(blocks) blocks under Blocks)",
                sourceLocation: sourceLocation)
    }

    /// THE REPRO — the observation's question and its punctuation-only
    /// siblings: a dash (the observation's own), a dash typed after the tag,
    /// a quoted dash, an ellipsis, and a lone symbol.
    @Test(arguments: ["— #flora", "#flora —", "\"—\" #flora", "… #flora", "- #flora", "+ #flora"])
    func aPunctuationOnlyQuestionsBandSaysWhatTheLibraryShows(_ text: String) throws {
        try withOperations { ops, db in
            try flora(ops)
            try expectTheBandSaysWhatIsShown(db, text)
        }
    }

    /// The controls — the oracle reads both roads honestly: a tag alone (the
    /// narrowed listing) and a real word beside the tag (the answer sheet).
    @Test(arguments: ["#flora", "red #flora", "petal #flora"])
    func theOraclesControlsAgreeOnBothRoads(_ text: String) throws {
        try withOperations { ops, db in
            try flora(ops)
            try expectTheBandSaysWhatIsShown(db, text)
        }
    }
}
