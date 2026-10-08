//
//  SearchFindSeedSpanTests.swift
//  VariorumCoreTests
//
//  VX-86 (the 13o follow-up run, VX-83) — her report: *"also only the first
//  word of what you searched is filled in"* ("sherlock holmes" landed with the
//  find bar armed as "Sherlock"). The traced mechanism (§M3 of
//  `notes/plans/fixes/vx-83-search-followup.md`): FTS5 marks EACH matched
//  term's occurrence as its own run, and the landing took the snippet's FIRST
//  run alone. The rule (D-3): the needle is the first CONTIGUOUS matched span
//  — whitespace-only gaps coalesce, anything else ends it.
//
//  The mechanism pin reads a REAL snippet through `Queries.searchPassages`
//  (so a future FTS5 that marked a phrase as one run would say so here); the
//  rule's cells are pure. Red-on-old: the rule's body reverted to "the first
//  matched run" (the shipped `SearchLanding.findSeed` letter) turns the
//  coalescing cells red — recorded in the U-A RECORD; the app's own arm is
//  `LibrarySearchLandingTests`.
//

import Foundation
import GRDB
import Testing

@testable import VariorumCore

private func segments(_ marked: String) -> [SearchSnippetSegment] {
    SearchComposer.snippetSegments(marked)
}

@Suite("VX-86 — the find seed's needle is the first contiguous matched span")
struct SearchFindSeedSpanTests {
    // MARK: - The mechanism (a real snippet)

    @Test func ftsMarksEachTermOfATwoWordQueryAsItsOwnRun() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "Baker Street")
            _ = try ops.newBlock(in: post.id, text: "It was Sherlock Holmes who knocked first.")
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(identifier: "UTC")!
            let query = SearchQueryParser.parse(
                "sherlock holmes", typeAhead: true, visibility: .living,
                locale: Locale(identifier: "en_US"), calendar: calendar)
            let page = try db.read { db in
                try Queries.searchPassages(db, query: query, scope: SearchScope(wingID: ""), calendar: calendar)
            }
            let take = try #require(page.passages.first { $0.kind == .take })
            #expect(take.snippet.filter(\.isMatch).map(\.text) == ["Sherlock", "Holmes"],
                    "two runs, one per term — the trace's premise")
            #expect(SearchSnippetSegment.firstMatchedSpan(take.snippet) == "Sherlock Holmes",
                    "…and the needle is the words as she wrote them, whole")
        }
    }

    // MARK: - The rule's cells (pure)

    @Test func adjacentRunsSeparatedBySpacesCoalesceAsWritten() {
        #expect(SearchSnippetSegment.firstMatchedSpan(segments("It was \u{2}Sherlock\u{3} \u{2}Holmes\u{3} who"))
                == "Sherlock Holmes")
        #expect(SearchSnippetSegment.firstMatchedSpan(segments("\u{2}the\u{3}  \u{2}Old\u{3}\t\u{2}Harbor\u{3}."))
                == "the  Old\tHarbor", "the spacing is the text's own — the literal find meets it")
        #expect(SearchSnippetSegment.firstMatchedSpan(segments("a \u{2}Café\u{3}\u{2}s\u{3} b"))
                == "Cafés", "two marked runs abutting are one span")
    }

    @Test func scatteredTermsKeepTheFirstRun() {
        #expect(SearchSnippetSegment.firstMatchedSpan(
            segments("\u{2}Sherlock\u{3} said that \u{2}Holmes\u{3} was")) == "Sherlock",
                "another word between them — the bar cannot hold a disjunction")
        #expect(SearchSnippetSegment.firstMatchedSpan(
            segments("\u{2}Sherlock\u{3}-\u{2}Holmes\u{3}")) == "Sherlock",
                "punctuation is not whitespace")
        #expect(SearchSnippetSegment.firstMatchedSpan(
            segments("\u{2}Sherlock\u{3}\n\u{2}Holmes\u{3}")) == "Sherlock",
                "a newline ends the span — the find bar holds one line (I4: newlines are content)")
        #expect(SearchSnippetSegment.firstMatchedSpan(
            segments("\u{2}Sherlock\u{3} \u{2}Holmes\u{3} and later \u{2}Watson\u{3}"))
                == "Sherlock Holmes", "the FIRST contiguous span, never a later one")
    }

    @Test func aSingleRunAndNothingMarked() {
        #expect(SearchSnippetSegment.firstMatchedSpan(segments("…a \u{2}Café\u{3} by the sea…")) == "Café")
        #expect(SearchSnippetSegment.firstMatchedSpan(segments("no marks here")) == nil)
        #expect(SearchSnippetSegment.firstMatchedSpan([]) == nil)
        #expect(SearchSnippetSegment.firstMatchedSpan(
            segments("x \u{2}Holmes\u{3} ")) == "Holmes", "a trailing gap with no run after it is not the span's")
    }
}
