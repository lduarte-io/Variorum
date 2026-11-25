//
//  TagSuggestOrderTests.swift
//  VariorumTests
//
//  **VX-576 — tag pickers list most-used first** (the rider seated in the
//  VX-1036 run, batch 2). The ONE suggest brain (`TagChipAdder.suggestions`,
//  which the inline field — the masthead's ＃ and the book card's "+" —
//  calls) orders its matches by how many live notes wear each tag, most first,
//  BEFORE its cap; ties, and every caller that hands no counts, keep the
//  taxonomy's own path order byte for byte. Pure, so it runs headless too.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

private typealias Tag = VariorumCore.Tag

@MainActor
@Suite("VX-576 — the tag suggestions list most-used first")
struct TagSuggestOrderTests {
    private static let day = Date(timeIntervalSince1970: 0)
    private func tag(_ path: String) -> Tag {
        Tag(id: "id-" + path, name: path, path: path, createdAt: Self.day, updatedAt: Self.day)
    }
    /// The taxonomy as `Queries.allTags` hands it: by path.
    private var taxonomy: [Tag] { ["apple", "beans", "water", "week", "weeds", "wednesday"].sorted().map(tag) }

    @Test func withNoCountsTheOrderIsThePathOrderAsBefore() {
        let paths = TagChipAdder.suggestions(taxonomy, typed: "w", applied: []).map(\.path)
        #expect(paths == ["water", "wednesday", "weeds", "week"])
    }

    @Test func theMostUsedComeFirstAndTiesKeepThePathOrder() {
        let uses = ["id-week": 30, "id-water": 5, "id-weeds": 5]
        let paths = TagChipAdder.suggestions(taxonomy, typed: "w", applied: [], uses: uses).map(\.path)
        #expect(paths == ["week", "water", "weeds", "wednesday"],
                "30 first; water and weeds tie at 5 in path order; an unused tag last")
    }

    @Test func theOrderComesBeforeTheCapSoAMuchWornTagDeepInTheAlphabetStillShows() {
        let many = (0..<12).map { tag(String(format: "a%02d", $0)) } + [tag("zebra")]
        let uses = ["id-zebra": 9]
        let capped = TagChipAdder.suggestions(many, typed: "", applied: [], limit: 6, uses: uses)
        #expect(capped.first?.path == "zebra", "the cap keeps the most-used, wherever it sorts by path")
        #expect(capped.count == 6)
    }

    @Test func whatTheNoteWearsIsNeverSuggested() {
        let uses = ["id-week": 30]
        let paths = TagChipAdder.suggestions(taxonomy, typed: "we", applied: ["week"], uses: uses).map(\.path)
        #expect(!paths.contains("week"))
    }
}
