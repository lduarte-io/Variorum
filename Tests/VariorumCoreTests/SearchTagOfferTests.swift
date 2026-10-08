//
//  SearchTagOfferTests.swift
//  VariorumCoreTests
//
//  VX-84b (the 13o follow-up run, VX-83) — her report: the plain word
//  `exampletag` answered "nothing found" though a note is tagged
//  `exampletag` (§M1(b): nothing in the index carries tag paths — by design,
//  R-13o-4's fence). The provisional call D-2: a word that NAMES a tag OFFERS
//  the tag (the band's `tag: #path ›`); the ranked stream stays text-honest.
//  The rule's one pure home is `SearchTagOffer`; D-2 RATIFIED at the run's
//  sitting (R-VX83-1 — the offer is the explicit act; the fold-in is dead).
//
//  Red-on-old: a new road (no offer existed). Verified by REVERT — the rule's
//  body short-circuited to `[]` turns every offering cell red (the U-A
//  RECORD); the Mac press's routing is `LibraryTagListingTests`.
//

import Foundation
import GRDB
import Testing

@testable import VariorumCore

private func query(_ text: String) -> SearchQuery {
    SearchQueryParser.parse(text, typeAhead: true, visibility: .living, locale: Locale(identifier: "en_US"))
}

private func offers(_ text: String, _ vocabulary: [String]) -> [String] {
    SearchTagOffer.offers(for: query(text), vocabulary: vocabulary).map(\.path)
}

@Suite("VX-84b — a word that names a tag offers the tag")
struct SearchTagOfferTests {
    @Test func aWordThatIsALeafOffersItsTag() {
        #expect(offers("exampletag ", ["exampletag", "other"]) == ["exampletag"], "her exact case")
        #expect(offers("EXAMPLETAG ", ["exampletag"]) == ["exampletag"], "case folded")
        #expect(offers("cafe ", ["café"]) == ["café"], "diacritics folded — the index's own sameness (R-13o-11)")
        #expect(offers("goals ", ["life", "life/goals"]) == ["life/goals"], "a child by its LEAF")
        #expect(offers("life ", ["life", "life/goals"]) == ["life"], "the parent's leaf is its own")
        #expect(SearchTagOffer.offers(for: query("dream journal "), vocabulary: ["dream"])
                == [SearchTagOffer.Offer(path: "dream", word: "dream")], "the naming word rides the offer")
        #expect(offers("\"old house\" ", ["old house"]) == ["old house"], "a quoted phrase names a spaced leaf")
    }

    @Test func onlyTheStillTypedTailOffersByPrefix() {
        #expect(offers("examp", ["exampletag"]) == ["exampletag"], "the type-ahead tail (≥ 2, the parser's rule)")
        #expect(offers("e", ["exampletag"]).isEmpty, "one character is never a prefix")
        #expect(offers("examp ", ["exampletag"]).isEmpty, "a FINISHED word must be the leaf")
        #expect(offers("examp night", ["exampletag"]).isEmpty, "…only the tail is still being typed")
        #expect(offers("tag", ["exampletag"]).isEmpty, "a prefix of the LEAF, never a substring")
    }

    @Test func aTypedTagIsNeverOfferedAndTheOffersAreOrderedAndBounded() {
        #expect(offers("#dream dream ", ["dream"]).isEmpty, "already asked")
        #expect(offers("dre", ["dreams", "dream", "a/dream", "dreary", "dredge"])
                == ["dream", "dreams", "dreary"], "shallower first, then the path; at most three")
        #expect(offers("dream dre", ["dreary", "dream"]) == ["dream", "dreary"], "exact before prefix")
        #expect(offers("#x", ["x"]).isEmpty, "no words — nothing to offer")
        #expect(offers("dream ", []).isEmpty)
    }

    @Test func theReadOffersOnlyTheWingsLiveTags() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "Second")
            _ = try ops.createTag(name: "exampletag")
            _ = try ops.createTag(name: "awaytag", wingID: wing.id)
            let gone = try ops.createTag(name: "gonetag")
            try ops.deleteTag(gone.id)
            func read(_ text: String, wing: String = "") throws -> [String] {
                try db.read { db in
                    try Queries.searchTagOffers(db, query: query(text), scope: SearchScope(wingID: wing))
                }.map(\.path)
            }
            #expect(try read("exampletag ") == ["exampletag"])
            #expect(try read("awaytag ").isEmpty, "another wing's tag is not this wing's")
            #expect(try read("awaytag ", wing: wing.id) == ["awaytag"])
            #expect(try read("gonetag ").isEmpty, "a deleted tag is never offered")
            #expect(try db.read { db in
                try Queries.searchTagOffers(db, query: query("exampletag "), scope: SearchScope(wingID: "", within: .note(id: "x")))
            }.isEmpty, "the Library's band alone offers")
        }
    }
}
