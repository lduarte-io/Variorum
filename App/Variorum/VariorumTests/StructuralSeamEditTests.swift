//
//  StructuralSeamEditTests.swift
//  VariorumTests
//
//  Phase 9, review round 1 (MINOR 5) — the differential derivation's pure
//  suite: exact-edit equality on the happy paths, and DIRECT pins for every
//  shape-guard fallback (nil ⇒ the caller re-renders fully from the store).
//  These branches guard text integrity on the one path that rewrites the
//  author's surface; before the extraction they were reachable only through
//  unstageable pipeline states and had no tests at all.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

private func indexOf(_ blocks: [(id: String, text: String)], tail: Int? = nil) -> BlockRangeIndex {
    BlockRangeIndex(
        entries: blocks.map {
            BlockRangeIndex.Entry(
                blockID: $0.id, variantID: "v-\($0.id)",
                length: $0.text.utf16.count, editable: true)
        },
        tailLength: tail)
}

private func freshSlots(_ blocks: [(id: String, text: String)]) -> [Queries.RenderedBlock] {
    blocks.map { slot($0.id, text: $0.text) }
}

@Suite("StructuralSeamEdit — happy-path derivations")
struct SeamEditHappyPathTests {
    @Test func divideDerivesTheSeamReplacementExactly() {
        let old = indexOf([("b0", "Alpha one. Alpha two."), ("b1", "Tail.")])
        let fresh = freshSlots([("b0", "Alpha one."), ("bN", "Alpha two."), ("b1", "Tail.")])
        let edit = StructuralSeamEdit.derive(
            .divide(entryIndex: 0, sourceID: "b0", successorID: "bN"),
            oldIndex: old, fresh: fresh)
        #expect(edit == StructuralSeamEdit.Edit(
            replaceRange: NSRange(location: 10, length: 11),
            replacement: "\nAlpha two.",
            attributeRuns: [.init(range: NSRange(location: 11, length: 10), blockID: "bN")]))
    }

    @Test func extractPrefixAndSuffixDeriveTheirEdgeEdits() {
        let old = indexOf([("b0", "Intro. Rest of it.")])
        let prefix = StructuralSeamEdit.derive(
            .extract(entryIndex: 0, edge: .prefix, sourceID: "b0", extractedID: "bX"),
            oldIndex: old, fresh: freshSlots([("bX", "Intro."), ("b0", "Rest of it.")]))
        #expect(prefix == StructuralSeamEdit.Edit(
            replaceRange: NSRange(location: 0, length: 7),
            replacement: "Intro.\n",
            attributeRuns: [.init(range: NSRange(location: 0, length: 6), blockID: "bX")]))

        let suffix = StructuralSeamEdit.derive(
            .extract(entryIndex: 0, edge: .suffix, sourceID: "b0", extractedID: "bX"),
            oldIndex: old, fresh: freshSlots([("b0", "Intro."), ("bX", "Rest of it.")]))
        #expect(suffix == StructuralSeamEdit.Edit(
            replaceRange: NSRange(location: 6, length: 12),
            replacement: "\nRest of it.",
            attributeRuns: [.init(range: NSRange(location: 7, length: 11), blockID: "bX")]))
    }

    @Test func makeBlockDerivesBothSeparatorsAndTheSuffixReBracket() {
        let old = indexOf([("b0", "AA. BB. CC.")])
        let edit = StructuralSeamEdit.derive(
            .makeBlock(entryIndex: 0, sourceID: "b0", middleID: "bM", suffixID: "bS"),
            oldIndex: old,
            fresh: freshSlots([("b0", "AA."), ("bM", "BB."), ("bS", "CC.")]))
        #expect(edit == StructuralSeamEdit.Edit(
            replaceRange: NSRange(location: 3, length: 5),
            replacement: "\nBB.\n",
            attributeRuns: [
                .init(range: NSRange(location: 4, length: 3), blockID: "bM"),
                // The untouched suffix text re-brackets to the fresh block.
                .init(range: NSRange(location: 8, length: 3), blockID: "bS"),
            ]))
    }

    @Test func mergeDerivesTheOneCharJoinForBothJoinKinds() {
        let old = indexOf([("b0", "One two."), ("b1", "Three.")])
        let spaced = StructuralSeamEdit.derive(
            .merge(leadingIndex: 0, mergedID: "bM"),
            oldIndex: old, fresh: freshSlots([("bM", "One two. Three.")]))
        #expect(spaced == StructuralSeamEdit.Edit(
            replaceRange: NSRange(location: 8, length: 1),
            replacement: " ",
            attributeRuns: [.init(range: NSRange(location: 0, length: 15), blockID: "bM")]))

        // A whitespace-edged merge joins with NOTHING (the op's rule).
        let bare = StructuralSeamEdit.derive(
            .merge(leadingIndex: 0, mergedID: "bM"),
            oldIndex: old, fresh: freshSlots([("bM", "One two.Three.")]))
        #expect(bare == StructuralSeamEdit.Edit(
            replaceRange: NSRange(location: 8, length: 1),
            replacement: "",
            attributeRuns: [.init(range: NSRange(location: 0, length: 14), blockID: "bM")]))
    }

    @Test func laterEntriesDeriveInDocumentCoordinates() {
        let old = indexOf([("a", "Lead."), ("b0", "Alpha one. Alpha two.")])
        let fresh = freshSlots([("a", "Lead."), ("b0", "Alpha one."), ("bN", "Alpha two.")])
        let edit = StructuralSeamEdit.derive(
            .divide(entryIndex: 1, sourceID: "b0", successorID: "bN"),
            oldIndex: old, fresh: fresh)
        // "Lead." (5) + separator: b0 starts at 6; prefix 10 → seam at 16.
        #expect(edit?.replaceRange == NSRange(location: 16, length: 11))
    }
}

@Suite("StructuralSeamEdit — every shape-guard fallback refuses (MINOR 5's payoff)")
struct SeamEditFallbackTests {
    private let old = indexOf([("b0", "Alpha one. Alpha two."), ("b1", "Tail.")])

    @Test func divideRefusesWrongCountWrongIDsAndImpossiblePrefix() {
        // Count mismatch (+2: a concurrent mint landed in the fetch).
        #expect(StructuralSeamEdit.derive(
            .divide(entryIndex: 0, sourceID: "b0", successorID: "bN"),
            oldIndex: old,
            fresh: freshSlots([("b0", "Alpha one."), ("bN", "Alpha two."), ("b1", "Tail."), ("bZ", "Ghost.")]))
            == nil)
        // The source slot carries a different block (concurrent reorder).
        #expect(StructuralSeamEdit.derive(
            .divide(entryIndex: 0, sourceID: "b0", successorID: "bN"),
            oldIndex: old,
            fresh: freshSlots([("bZ", "Alpha one."), ("bN", "Alpha two."), ("b1", "Tail.")]))
            == nil)
        // The successor slot isn't the op's minted block.
        #expect(StructuralSeamEdit.derive(
            .divide(entryIndex: 0, sourceID: "b0", successorID: "bN"),
            oldIndex: old,
            fresh: freshSlots([("b0", "Alpha one."), ("bZ", "Alpha two."), ("b1", "Tail.")]))
            == nil)
        // The "prefix" is longer than the old entry (a remote rewrite): the
        // strict-prefix lean no longer holds — refuse, never mis-slice.
        #expect(StructuralSeamEdit.derive(
            .divide(entryIndex: 0, sourceID: "b0", successorID: "bN"),
            oldIndex: old,
            fresh: freshSlots([("b0", "Alpha one, grown much longer than the source."), ("bN", "x"), ("b1", "Tail.")]))
            == nil)
        // Entry index out of the old tiling.
        #expect(StructuralSeamEdit.derive(
            .divide(entryIndex: 5, sourceID: "b0", successorID: "bN"),
            oldIndex: old,
            fresh: freshSlots([("b0", "Alpha one."), ("bN", "Alpha two."), ("b1", "Tail.")]))
            == nil)
    }

    @Test func extractRefusesSwappedOrderWrongSourceAndImpossibleRemainder() {
        // Prefix seam but the fresh order is source-first (shape mismatch).
        #expect(StructuralSeamEdit.derive(
            .extract(entryIndex: 0, edge: .prefix, sourceID: "b0", extractedID: "bX"),
            oldIndex: old,
            fresh: freshSlots([("b0", "Rest."), ("bX", "Intro."), ("b1", "Tail.")]))
            == nil)
        // Suffix seam but the fresh order is extracted-first.
        #expect(StructuralSeamEdit.derive(
            .extract(entryIndex: 0, edge: .suffix, sourceID: "b0", extractedID: "bX"),
            oldIndex: old,
            fresh: freshSlots([("bX", "Rest."), ("b0", "Intro."), ("b1", "Tail.")]))
            == nil)
        // The old entry at the seam isn't the op's source.
        #expect(StructuralSeamEdit.derive(
            .extract(entryIndex: 1, edge: .suffix, sourceID: "b0", extractedID: "bX"),
            oldIndex: old,
            fresh: freshSlots([("b0", "Alpha one. Alpha two."), ("bX", "x"), ("b1", "Tail.")]))
            == nil)
        // Remainder longer than the old entry (remote rewrite mid-window).
        #expect(StructuralSeamEdit.derive(
            .extract(entryIndex: 1, edge: .suffix, sourceID: "b1", extractedID: "bX"),
            oldIndex: old,
            fresh: freshSlots([("b0", "Alpha one. Alpha two."), ("b1", "Tail, now far longer than before."), ("bX", "x")]))
            == nil)
        // Count mismatch.
        #expect(StructuralSeamEdit.derive(
            .extract(entryIndex: 0, edge: .prefix, sourceID: "b0", extractedID: "bX"),
            oldIndex: old,
            fresh: freshSlots([("bX", "Intro."), ("b0", "Rest.")]))
            == nil)
    }

    @Test func makeBlockRefusesWrongCountWrongIDsAndOverlongHalves() {
        // Count mismatch (+1 instead of +2).
        #expect(StructuralSeamEdit.derive(
            .makeBlock(entryIndex: 0, sourceID: "b0", middleID: "bM", suffixID: "bS"),
            oldIndex: old,
            fresh: freshSlots([("b0", "AA."), ("bM", "BB."), ("b1", "Tail.")]))
            == nil)
        // Middle slot isn't the op's mint.
        #expect(StructuralSeamEdit.derive(
            .makeBlock(entryIndex: 0, sourceID: "b0", middleID: "bM", suffixID: "bS"),
            oldIndex: old,
            fresh: freshSlots([("b0", "AA."), ("bZ", "BB."), ("bS", "CC."), ("b1", "Tail.")]))
            == nil)
        // Suffix slot isn't the op's second mint.
        #expect(StructuralSeamEdit.derive(
            .makeBlock(entryIndex: 0, sourceID: "b0", middleID: "bM", suffixID: "bS"),
            oldIndex: old,
            fresh: freshSlots([("b0", "AA."), ("bM", "BB."), ("bZ", "CC."), ("b1", "Tail.")]))
            == nil)
        // prefix + suffix longer than the old entry: the strict-edges lean
        // no longer holds — refuse.
        #expect(StructuralSeamEdit.derive(
            .makeBlock(entryIndex: 0, sourceID: "b0", middleID: "bM", suffixID: "bS"),
            oldIndex: old,
            fresh: freshSlots([
                ("b0", "A prefix grown longer than the whole source ever was."),
                ("bM", "BB."),
                ("bS", "And a suffix grown longer too."), ("b1", "Tail."),
            ]))
            == nil)
    }

    @Test func mergeRefusesWrongCountWrongIDAndImpossibleJoin() {
        // Count mismatch (nothing shrank).
        #expect(StructuralSeamEdit.derive(
            .merge(leadingIndex: 0, mergedID: "bM"),
            oldIndex: old,
            fresh: freshSlots([("bM", "Alpha one. Alpha two. Tail."), ("b1", "Tail.")]))
            == nil)
        // The merged slot isn't the op's mint.
        #expect(StructuralSeamEdit.derive(
            .merge(leadingIndex: 0, mergedID: "bM"),
            oldIndex: old,
            fresh: freshSlots([("bZ", "Alpha one. Alpha two. Tail.")]))
            == nil)
        // join ∉ {0, 1}: the merged text isn't the two halves verbatim
        // (a remote rewrite mid-window) — refuse, never mis-bracket.
        #expect(StructuralSeamEdit.derive(
            .merge(leadingIndex: 0, mergedID: "bM"),
            oldIndex: old,
            fresh: freshSlots([("bM", "Something else entirely, wrong length.")]))
            == nil)
        // No trailing neighbor in the old tiling.
        #expect(StructuralSeamEdit.derive(
            .merge(leadingIndex: 1, mergedID: "bM"),
            oldIndex: old,
            fresh: freshSlots([("bM", "Alpha one. Alpha two. Tail.")]))
            == nil)
    }
}
