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

    /// THE ONE PREDICATE, pure (`SearchComposer.asksWords`): words the index
    /// serves take the words road; no text half takes the tag road; words
    /// that fold to nothing take the tag road when a tag can drive it; and a
    /// tree of only negations stays on the words road — where it keeps
    /// refusing — with or without a folded word or a tag beside it.
    @Test func theOnePredicateReadsTheTextHalfAsTheIndexDoes() {
        let flora = SearchFilter.tagPath("flora")
        #expect(SearchComposer.asksWords(question("red ")))
        #expect(SearchComposer.asksWords(question("red + #flora")), "a served word beside a symbol and a tag")
        #expect(SearchComposer.asksWords(question("1 + 1")))
        #expect(!SearchComposer.asksWords(question("#flora")))
        #expect(!SearchComposer.asksWords(question("— #flora")) && !SearchComposer.asksWords(question("+ #flora")))
        #expect(!SearchComposer.asksWords(SearchQuery(filter: .all([flora, .starred]))))
        #expect(SearchComposer.asksWords(SearchQuery(text: .not(.word("red")))))
        #expect(SearchComposer.asksWords(SearchQuery(text: .all([.word("—"), .not(.word("red"))]), filter: flora)),
                "a negation beside a folded word and a tag still refuses on the words road")
        #expect(SearchComposer.asksWords(SearchQuery(text: .all([.word("+"), .not(.word("red"))]), filter: flora)))
        // A tag the text-less road cannot drive from (under ANY) leaves a
        // folded word on the words road — the narrowing's own reading.
        #expect(SearchComposer.asksWords(SearchQuery(text: .word("—"), filter: .any([flora, .starred]))))
    }

    /// **The empty answer's decision, pure** (`SearchComposer
    /// .holdsNothingSearchable` — her R-980-5): ONLY a typed field whose words
    /// all fold to nothing and that names no tag. A wordful search with no
    /// hits, a folded word beside a tag (it is the tag alone), a field with no
    /// words at all, and a negation-only tree (it refuses in its own words)
    /// are not this state. The one reading both predicates derive from
    /// (`textHalf`) is pinned beside it.
    @Test func theEmptyAnswerSaysWhyOnlyForAFieldOfNothingSearchable() {
        let flora = SearchFilter.tagPath("flora")
        for text in ["—", "+", "#", "…", "\"—\"", "— +", "$ ©"] {
            #expect(SearchComposer.textHalf(question(text)) == .foldsToNothing, "\(text)")
            #expect(SearchComposer.holdsNothingSearchable(question(text)), "\(text) holds nothing searchable")
        }
        for text in ["zzyzx ", "red", "red +", "1 + 1", "— #flora", "+ #flora", "#flora"] {
            #expect(!SearchComposer.holdsNothingSearchable(question(text)), "\(text) is not that state")
        }
        #expect(SearchComposer.textHalf(question("zzyzx ")) == .served, "a wordful search with no hits is served")
        #expect(SearchComposer.textHalf(question("#flora")) == .absent)
        #expect(SearchComposer.textHalf(SearchQuery(text: .not(.word("red")))) == .served, "negations alone refuse")
        #expect(!SearchComposer.holdsNothingSearchable(SearchQuery(text: .not(.word("red")))))
        #expect(!SearchComposer.holdsNothingSearchable(SearchQuery(text: .all([.word("—"), .not(.word("red"))]))))
        #expect(!SearchComposer.holdsNothingSearchable(SearchQuery(filter: flora)))
    }

    /// **R-980-5 (her ruling of P-980-1, "Say why")** — a field holding ONLY
    /// punctuation or symbols asks nothing the index can serve and names no
    /// tag: it is still a TYPED SEARCH — the words road, never blanked into
    /// the Library at rest, with or without an armed day or book state beside
    /// it — its numbers say nothing under every facet (the band's honest
    /// "nothing found"), no listing is narrowed, a word that literally names a
    /// tag still offers it, and it holds nothing searchable, so the empty
    /// answer says WHY (the faces read `holdsNothingSearchable` — pinned in
    /// the app's `SearchEmptyAnswerSentenceTests`). Replaces the option (a)
    /// pin, whose face kept "Nothing matches".
    @Test(arguments: ["—", "+", "#", "…", "\"—\"", "— +", "$ ©"])
    func aFieldOfOnlyPunctuationOrSymbolsIsATypedSearchThatSaysWhy(_ text: String) throws {
        let asked = question(text)
        #expect(asked.text != nil && SearchComposer.asksWords(asked), "\(text) stays on the words road")
        #expect(SearchComposer.holdsNothingSearchable(asked), "\(text): the empty answer says why")
        var dated = asked
        dated.filter = .days(SearchDayRange(field: .edited, start: "2026-01-01T00:00:00Z", end: "2026-01-02T00:00:00Z"))
        var stated = asked
        stated.filter = .bookState(.living)
        #expect(SearchComposer.asksWords(dated) && SearchComposer.asksWords(stated),
                "\(text) beside an armed day or book state stays on the words road too")
        #expect(SearchComposer.holdsNothingSearchable(dated) && SearchComposer.holdsNothingSearchable(stated),
                "\(text) beside an armed day or book state still says why")
        try withOperations { ops, db in
            try flora(ops)
            let said = try answer(db, asked)
            for (facet, counts) in said.bands {
                let living = counts.flatMap { $0 }?.living
                #expect(living == nil || living == SearchCounts.Kinds(books: 0, notes: 0, passages: 0, scraps: 0),
                        "\(text) under \(facet): nothing found")
            }
            #expect(said.narrowedNotes.isEmpty && said.taggedBlocks.isEmpty && said.associatedBooks.isEmpty)
            let named = ["—", "+", "…"].filter { text.contains($0) }
            #expect(Set(said.offers) == Set(named), "\(text): a word that names a tag still offers it")
        }
    }
}
