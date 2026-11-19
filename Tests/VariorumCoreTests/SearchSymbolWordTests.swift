//
//  SearchSymbolWordTests.swift
//  VariorumCoreTests
//
//  VX-955 (the VX-980 run, batch 1; `notes/plans/fixes/vx-980-search-fixes.md`)
//  — a SYMBOL word beside real words emptied the whole answer: `red` found
//  the note, `red +` found nothing. The composer asked the index about `+`
//  (it counted every symbol as a token character), the index's tokenizer
//  found no token in it, so the phrase `"+"` matched no row and the implicit
//  AND matched nothing. The pins: each such question finds exactly what its
//  words without the symbol find — the answer sheet's groups AND the band's
//  numbers — RED on the pre-fix tree. The controls hold on both trees.
//

import Foundation
import GRDB
import Testing

@testable import VariorumCore

private let library = SearchScope(wingID: "")

private func question(_ text: String) -> SearchQuery {
    SearchQueryParser.parse(text, typeAhead: true, visibility: .living, locale: Locale(identifier: "en_US"))
}

/// Every group the answer sheet lists for a question (paged to the end).
private func listedHomes(_ db: AppDatabase, _ asked: SearchQuery) throws -> Set<String> {
    try db.read { db in
        var homes: Set<String> = []
        var cursor: SearchComposer.GroupCursor?
        var pages = 0
        repeat {
            let page = try Queries.searchGroups(db, query: asked, scope: library, after: cursor, limit: 25, perGroup: 3)
            homes.formUnion(page.groups.map(\.homeID))
            cursor = page.next
            pages += 1
        } while cursor != nil && pages < 50
        return homes
    }
}

private func band(_ db: AppDatabase, _ asked: SearchQuery) throws -> SearchCounts? {
    try db.read { db in try Queries.searchCounts(db, query: asked, scope: library) }
}

@Suite("VX-955 — a symbol word beside real words finds what the words find")
struct SearchSymbolWordTests {
    private struct Corpus {
        let rose: String, petals: String, sums: String, plus: String, recipe: String, power: String
    }

    private func corpus(_ ops: Operations) throws -> Corpus {
        func note(_ title: String, _ text: String) throws -> String {
            let post = try ops.createPost(title: title)
            _ = try ops.newBlock(in: post.id, text: text)
            return post.id
        }
        return Corpus(
            rose: try note("Rose", "a red rose by the gate"),
            petals: try note("Petals", "red petals fall"),
            sums: try note("Sums", "1 + 1 makes 2"),
            plus: try note("Plus", "a + b"),
            recipe: try note("Recipe", "½ cup of sugar"),
            power: try note("Power", "the power ² of ten"))
    }

    /// THE PINS — the symbol word's question answers exactly what the same
    /// words without it answer (and that answer is not empty). A word the
    /// symbol FOLLOWS is finished, so its twin is typed finished too
    /// (`"red "`); a word that ends the field is the type-ahead prefix on
    /// both sides.
    @Test(arguments: [
        ("red +", "red "), ("red $", "red "), ("red ©", "red "), ("1 + 1", "1 1"),
        ("+ red", "red"), ("red + ", "red "),
    ])
    func aSymbolWordBesideRealWordsFindsWhatTheWordsFind(_ pair: (String, String)) throws {
        try withOperations { ops, db in
            _ = try corpus(ops)
            let (asked, words) = (question(pair.0), question(pair.1))
            let expected = try listedHomes(db, words)
            #expect(!expected.isEmpty, "the words alone find something (\(pair.1))")
            #expect(try listedHomes(db, asked) == expected,
                    "\(pair.0) lists what \(pair.1) lists")
            #expect(try band(db, asked) == band(db, words),
                    "\(pair.0)'s band says what \(pair.1)'s says")
        }
    }

    /// The CONTROLS — green on both trees: a dash was already a separator in
    /// both rules; a symbol INSIDE a quoted phrase of real words; the type-
    /// ahead prefix; number-class characters the index keeps as tokens.
    @Test func theControlsHoldOnBothTrees() throws {
        try withOperations { ops, db in
            let c = try corpus(ops)
            #expect(try listedHomes(db, question("red —")) == listedHomes(db, question("red")))
            #expect(try band(db, question("red —")) == band(db, question("red")))
            #expect(try listedHomes(db, question("\"a + b\" ")) == [c.plus], "a phrase holding a symbol")
            #expect(try listedHomes(db, question("red pet")) == [c.petals], "the tail is a prefix")
            #expect(try listedHomes(db, question("½ ")) == [c.recipe], "½ is a number to the index")
            #expect(try listedHomes(db, question("² ")) == [c.power], "² is a number to the index")
            #expect(try listedHomes(db, question("red ")) == [c.rose, c.petals])
        }
    }

    /// NEGATION (an AST form — v1's field types none): a question of only
    /// negations refuses exactly as before, a dash beside a negation refuses
    /// on both trees, and a symbol beside a POSITIVE word is still nothing.
    @Test func negationStillRefusesAndAPositiveWordStillAnswers() throws {
        try withOperations { ops, db in
            let c = try corpus(ops)
            #expect(throws: SearchComposer.Refusal.negativeOnlyText) {
                try band(db, SearchQuery(text: .not(.word("red"))))
            }
            #expect(throws: SearchComposer.Refusal.negativeOnlyText) {
                try band(db, SearchQuery(text: .all([.word("—"), .not(.word("red"))])))
            }
            #expect(try listedHomes(db, SearchQuery(text: .all([.word("rose"), .not(.word("+"))]))) == [c.rose])
        }
    }

    /// THE PIN for the negation row (RED on the pre-fix tree): a symbol word
    /// beside a negation reads EXACTLY as a dash does — it folds to nothing,
    /// so only the negation is left and the index refuses it. On the old tree
    /// it was asked (`("+" NOT "red")`) and "answered" with nothing, the
    /// empty phrase being VX-955 itself.
    @Test func aSymbolWordBesideANegationReadsAsADashDoes() throws {
        try withOperations { ops, db in
            _ = try corpus(ops)
            #expect(throws: SearchComposer.Refusal.negativeOnlyText) {
                try band(db, SearchQuery(text: .all([.word("+"), .not(.word("red"))])))
            }
        }
    }
}
