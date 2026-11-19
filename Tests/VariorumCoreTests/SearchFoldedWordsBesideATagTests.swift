//
//  SearchFoldedWordsBesideATagTests.swift
//  VariorumCoreTests
//
//  VX-954 (the VX-980 run, batch 1; `notes/plans/fixes/vx-980-search-fixes.md`)
//  — a dash beside a tag answered LESS than the tag alone: `#flora` read
//  "1 book · 2 notes · 1 block" over the narrowed listing, `— #flora` read
//  "1 book" over a sheet holding only the book. The dash gave the question a
//  text half (`query.text != nil`), so every reader of the text-less TAG road
//  — the narrowing, the facet band's arm, the tag offers — stayed off, while
//  the words road had nothing the index could serve.
//
//  The pins: a word list that FOLDS TO NOTHING (punctuation or symbols the
//  index's tokenizer drops) beside a tag answers EXACTLY what the tag alone
//  answers — the band under All and under every facet, the narrowed notes,
//  the tagged blocks, the associated books and the tag offers. RED on the
//  pre-fix tree. VX-955's symbol word (`+ #flora`) takes the same road: the
//  two fixes agree.
//

import Foundation
import GRDB
import Testing

@testable import VariorumCore

private let library = SearchScope(wingID: "")

private func question(_ text: String) -> SearchQuery {
    SearchQueryParser.parse(text, typeAhead: true, visibility: .living, locale: Locale(identifier: "en_US"))
}

/// Everything a question answers on the readers the tag road owns.
private struct Answer: Equatable, CustomStringConvertible {
    var bands: [String: SearchCounts?] = [:]
    var narrowedNotes: [String] = []
    var taggedBlocks: [String] = []
    var associatedBooks: [String] = []
    var offers: [String] = []

    var description: String {
        let counts = bands.keys.sorted().map { facet in
            "\(facet): " + (bands[facet].flatMap { $0 }.map { "\($0.living)" } ?? "nil")
        }
        return "bands [\(counts.joined(separator: "; "))] · notes \(narrowedNotes.count) · blocks \(taggedBlocks.count)"
            + " · books \(associatedBooks.count) · offers \(offers)"
    }
}

private func answer(_ db: AppDatabase, _ asked: SearchQuery) throws -> Answer {
    try db.read { db in
        var out = Answer()
        for facet in [SearchFacet.all, .notes, .books, .blocks] {
            out.bands["\(facet)"] = try Queries.searchCounts(db, query: asked, facet: facet, scope: library)
        }
        var cursor: Queries.CatalogCursor?
        var pages = 0
        repeat {
            let page = try Queries.catalogNotesPage(
                db, query: "", after: cursor, limit: 50, wingID: "", narrowing: asked)
            out.narrowedNotes += page.hits.map(\.id)
            cursor = page.next
            pages += 1
        } while cursor != nil && pages < 50
        out.taggedBlocks = try Queries.catalogTaggedBlocks(db, narrowing: asked, wingID: "").map(\.id)
        out.associatedBooks = try Queries.searchTagAssociations(db, query: asked, scope: library).map(\.readingID)
        out.offers = try Queries.searchTagOffers(db, query: asked, scope: library).map(\.path)
        return out
    }
}

@Suite("VX-954 — a word that folds to nothing beside a tag answers what the tag alone answers")
struct SearchFoldedWordsBesideATagTests {
    /// VX-888's fixture (a tag, `flora`, on two notes — one also on a block
    /// of its own — on a scrap's block, and the rule of one living book),
    /// plus tags NAMED by the punctuation itself, so a reader that still
    /// treated the punctuation as words would OFFER them.
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
        for name in ["—", "…", "-", "+"] { _ = try ops.createTag(name: name) }
    }

    /// THE PINS — VX-888's six shapes (the observation's own, a dash after
    /// the tag, a quoted dash, an ellipsis, a hyphen, and VX-955's symbol).
    @Test(arguments: ["— #flora", "#flora —", "\"—\" #flora", "… #flora", "- #flora", "+ #flora"])
    func aFoldedWordBesideATagAnswersWhatTheTagAloneAnswers(_ text: String) throws {
        try withOperations { ops, db in
            try flora(ops)
            let alone = try answer(db, question("#flora"))
            // Two notes, two blocks (the Rose block and the scrap), one book.
            #expect(alone.narrowedNotes.count == 2 && alone.taggedBlocks.count == 2
                    && alone.associatedBooks.count == 1 && alone.offers.isEmpty,
                    "the tag alone: \(alone)")
            let beside = try answer(db, question(text))
            #expect(beside == alone, "\(text) answers \(beside), but #flora answers \(alone)")
        }
    }
}
