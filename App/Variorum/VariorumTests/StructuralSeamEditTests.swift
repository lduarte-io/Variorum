//
//  StructuralSeamEditTests.swift
//  VariorumTests
//
//  Phase 9, review rounds 1–2 — the differential derivation's pure suite:
//  exact-edit equality on the happy paths, DIRECT pins for every guard
//  fallback (nil ⇒ the caller re-renders fully from the store): the round-1
//  seam-shape guards, the round-2 MAJOR's non-seam geometry correspondence,
//  and the author-directed retained-byte verification.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

/// One pre-edit world: the index (geometry) + the surface texts (bytes).
private struct OldWorld {
    let index: BlockRangeIndex
    let texts: [String]

    init(_ blocks: [(id: String, text: String)], tail: Int? = nil) {
        index = BlockRangeIndex(
            entries: blocks.map {
                BlockRangeIndex.Entry(
                    blockID: $0.id, variantID: "v-\($0.id)",
                    length: $0.text.utf16.count, editable: true)
            },
            tailLength: tail)
        texts = blocks.map(\.text)
    }

    func textAt(_ i: Int) -> String {
        guard i >= 0, i < texts.count else { return "" }
        return texts[i]
    }
}

private func freshSlots(_ blocks: [(id: String, text: String)]) -> [Queries.RenderedBlock] {
    blocks.map { slot($0.id, text: $0.text) }
}

private func derive(
    _ seam: StructuralSeam, old: OldWorld, fresh: [(id: String, text: String)]
) -> StructuralSeamEdit.Edit? {
    StructuralSeamEdit.derive(
        seam, oldIndex: old.index, oldTextAt: old.textAt, fresh: freshSlots(fresh))
}

@Suite("StructuralSeamEdit — happy-path derivations")
struct SeamEditHappyPathTests {
    @Test func divideDerivesTheSeamReplacementExactly() {
        let old = OldWorld([("b0", "Alpha one. Alpha two."), ("b1", "Tail.")])
        let edit = derive(
            .divide(entryIndex: 0, sourceID: "b0", successorID: "bN"),
            old: old,
            fresh: [("b0", "Alpha one."), ("bN", "Alpha two."), ("b1", "Tail.")])
        #expect(edit == StructuralSeamEdit.Edit(
            replaceRange: NSRange(location: 10, length: 11),
            replacement: "\nAlpha two.",
            attributeRuns: [.init(range: NSRange(location: 11, length: 10), blockID: "bN")]))
    }

    @Test func extractPrefixAndSuffixDeriveTheirEdgeEdits() {
        let old = OldWorld([("b0", "Intro. Rest of it.")])
        let prefix = derive(
            .extract(entryIndex: 0, edge: .prefix, sourceID: "b0", extractedID: "bX"),
            old: old, fresh: [("bX", "Intro."), ("b0", "Rest of it.")])
        #expect(prefix == StructuralSeamEdit.Edit(
            replaceRange: NSRange(location: 0, length: 7),
            replacement: "Intro.\n",
            attributeRuns: [.init(range: NSRange(location: 0, length: 6), blockID: "bX")]))

        let suffix = derive(
            .extract(entryIndex: 0, edge: .suffix, sourceID: "b0", extractedID: "bX"),
            old: old, fresh: [("b0", "Intro."), ("bX", "Rest of it.")])
        #expect(suffix == StructuralSeamEdit.Edit(
            replaceRange: NSRange(location: 6, length: 12),
            replacement: "\nRest of it.",
            attributeRuns: [.init(range: NSRange(location: 7, length: 11), blockID: "bX")]))
    }

    @Test func makeBlockDerivesBothSeparatorsAndTheSuffixReBracket() {
        let old = OldWorld([("b0", "AA. BB. CC.")])
        let edit = derive(
            .makeBlock(entryIndex: 0, sourceID: "b0", middleID: "bM", suffixID: "bS"),
            old: old, fresh: [("b0", "AA."), ("bM", "BB."), ("bS", "CC.")])
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
        let old = OldWorld([("b0", "One two."), ("b1", "Three.")])
        let spaced = derive(
            .merge(leadingIndex: 0, mergedID: "bM"),
            old: old, fresh: [("bM", "One two. Three.")])
        #expect(spaced == StructuralSeamEdit.Edit(
            replaceRange: NSRange(location: 8, length: 1),
            replacement: " ",
            attributeRuns: [.init(range: NSRange(location: 0, length: 15), blockID: "bM")]))

        // A whitespace-edged merge joins with NOTHING (the op's rule) —
        // stage it with a truly whitespace-edged lead so the verbatim
        // check agrees: "One two " + "Three." with no invented join.
        let bare = derive(
            .merge(leadingIndex: 0, mergedID: "bM"),
            old: OldWorld([("b0", "One two "), ("b1", "Three.")]),
            fresh: [("bM", "One two Three.")])
        #expect(bare == StructuralSeamEdit.Edit(
            replaceRange: NSRange(location: 8, length: 1),
            replacement: "",
            attributeRuns: [.init(range: NSRange(location: 0, length: 14), blockID: "bM")]))
    }

    @Test func laterEntriesDeriveInDocumentCoordinates() {
        let old = OldWorld([("a", "Lead."), ("b0", "Alpha one. Alpha two.")])
        let edit = derive(
            .divide(entryIndex: 1, sourceID: "b0", successorID: "bN"),
            old: old,
            fresh: [("a", "Lead."), ("b0", "Alpha one."), ("bN", "Alpha two.")])
        // "Lead." (5) + separator: b0 starts at 6; prefix 10 → seam at 16.
        #expect(edit?.replaceRange == NSRange(location: 16, length: 11))
    }
}

@Suite("StructuralSeamEdit — seam-shape fallbacks (round 1)")
struct SeamEditFallbackTests {
    private let old = OldWorld([("b0", "Alpha one. Alpha two."), ("b1", "Tail.")])

    @Test func divideRefusesWrongCountWrongIDsAndImpossiblePrefix() {
        // Count mismatch (+2: a concurrent mint landed in the fetch).
        #expect(derive(
            .divide(entryIndex: 0, sourceID: "b0", successorID: "bN"), old: old,
            fresh: [("b0", "Alpha one."), ("bN", "Alpha two."), ("b1", "Tail."), ("bZ", "Ghost.")])
            == nil)
        // The source slot carries a different block (concurrent reorder).
        #expect(derive(
            .divide(entryIndex: 0, sourceID: "b0", successorID: "bN"), old: old,
            fresh: [("bZ", "Alpha one."), ("bN", "Alpha two."), ("b1", "Tail.")])
            == nil)
        // The successor slot isn't the op's minted block.
        #expect(derive(
            .divide(entryIndex: 0, sourceID: "b0", successorID: "bN"), old: old,
            fresh: [("b0", "Alpha one."), ("bZ", "Alpha two."), ("b1", "Tail.")])
            == nil)
        // The "prefix" is longer than the old entry: the strict-prefix lean
        // no longer holds — refuse, never mis-slice.
        #expect(derive(
            .divide(entryIndex: 0, sourceID: "b0", successorID: "bN"), old: old,
            fresh: [("b0", "Alpha one, grown much longer than the source."), ("bN", "x"), ("b1", "Tail.")])
            == nil)
        // Entry index out of the old tiling.
        #expect(derive(
            .divide(entryIndex: 5, sourceID: "b0", successorID: "bN"), old: old,
            fresh: [("b0", "Alpha one."), ("bN", "Alpha two."), ("b1", "Tail.")])
            == nil)
    }

    @Test func extractRefusesSwappedOrderWrongSourceAndImpossibleRemainder() {
        // Prefix seam but the fresh order is source-first (shape mismatch).
        #expect(derive(
            .extract(entryIndex: 0, edge: .prefix, sourceID: "b0", extractedID: "bX"),
            old: old, fresh: [("b0", "Rest."), ("bX", "Intro."), ("b1", "Tail.")])
            == nil)
        // Suffix seam but the fresh order is extracted-first.
        #expect(derive(
            .extract(entryIndex: 0, edge: .suffix, sourceID: "b0", extractedID: "bX"),
            old: old, fresh: [("bX", "Rest."), ("b0", "Intro."), ("b1", "Tail.")])
            == nil)
        // The old entry at the seam isn't the op's source.
        #expect(derive(
            .extract(entryIndex: 1, edge: .suffix, sourceID: "b0", extractedID: "bX"),
            old: old, fresh: [("b0", "Alpha one. Alpha two."), ("bX", "x"), ("b1", "Tail.")])
            == nil)
        // Remainder longer than the old entry.
        #expect(derive(
            .extract(entryIndex: 1, edge: .suffix, sourceID: "b1", extractedID: "bX"),
            old: old,
            fresh: [("b0", "Alpha one. Alpha two."), ("b1", "Tail, now far longer than before."), ("bX", "x")])
            == nil)
        // Count mismatch.
        #expect(derive(
            .extract(entryIndex: 0, edge: .prefix, sourceID: "b0", extractedID: "bX"),
            old: old, fresh: [("bX", "Intro."), ("b0", "Rest.")])
            == nil)
    }

    @Test func makeBlockRefusesWrongCountWrongIDsAndOverlongHalves() {
        // Count mismatch (+1 instead of +2).
        #expect(derive(
            .makeBlock(entryIndex: 0, sourceID: "b0", middleID: "bM", suffixID: "bS"),
            old: old, fresh: [("b0", "AA."), ("bM", "BB."), ("b1", "Tail.")])
            == nil)
        // Middle slot isn't the op's mint.
        #expect(derive(
            .makeBlock(entryIndex: 0, sourceID: "b0", middleID: "bM", suffixID: "bS"),
            old: old, fresh: [("b0", "AA."), ("bZ", "BB."), ("bS", "CC."), ("b1", "Tail.")])
            == nil)
        // Suffix slot isn't the op's second mint.
        #expect(derive(
            .makeBlock(entryIndex: 0, sourceID: "b0", middleID: "bM", suffixID: "bS"),
            old: old, fresh: [("b0", "AA."), ("bM", "BB."), ("bZ", "CC."), ("b1", "Tail.")])
            == nil)
        // prefix + suffix longer than the old entry.
        #expect(derive(
            .makeBlock(entryIndex: 0, sourceID: "b0", middleID: "bM", suffixID: "bS"),
            old: old,
            fresh: [
                ("b0", "A prefix grown longer than the whole source ever was."),
                ("bM", "BB."),
                ("bS", "And a suffix grown longer too."), ("b1", "Tail."),
            ])
            == nil)
    }

    @Test func mergeRefusesWrongCountWrongIDAndNonVerbatimText() {
        // Count mismatch (nothing shrank).
        #expect(derive(
            .merge(leadingIndex: 0, mergedID: "bM"), old: old,
            fresh: [("bM", "Alpha one. Alpha two. Tail."), ("b1", "Tail.")])
            == nil)
        // The merged slot isn't the op's mint.
        #expect(derive(
            .merge(leadingIndex: 0, mergedID: "bM"), old: old,
            fresh: [("bZ", "Alpha one. Alpha two. Tail.")])
            == nil)
        // The merged text isn't the two halves verbatim (wrong length).
        #expect(derive(
            .merge(leadingIndex: 0, mergedID: "bM"), old: old,
            fresh: [("bM", "Something else entirely, wrong length.")])
            == nil)
        // No trailing neighbor in the old tiling.
        #expect(derive(
            .merge(leadingIndex: 1, mergedID: "bM"), old: old,
            fresh: [("bM", "Alpha one. Alpha two. Tail.")])
            == nil)
    }
}

@Suite("StructuralSeamEdit — non-seam geometry correspondence (round 2, MAJOR)")
struct SeamEditNonSeamGeometryTests {
    // Three blocks so every seam has non-seam neighbors on both sides.
    private let old = OldWorld([
        ("a", "Front matter."),
        ("b0", "Alpha one. Alpha two."),
        ("z", "Back matter."),
    ])

    @Test func divideRefusesWhenANonSeamSlotChangedLength() {
        // A concurrent write grew the LAST block between op and fetch: the
        // rebuilt index would claim a length the surface doesn't show —
        // wrong autosave offsets, unhealable deliveries. Refuse → full render.
        #expect(derive(
            .divide(entryIndex: 1, sourceID: "b0", successorID: "bN"), old: old,
            fresh: [("a", "Front matter."), ("b0", "Alpha one."), ("bN", "Alpha two."),
                    ("z", "Back matter, but grown longer now.")])
            == nil)
        // Same on the LEADING side.
        #expect(derive(
            .divide(entryIndex: 1, sourceID: "b0", successorID: "bN"), old: old,
            fresh: [("a", "Front!"), ("b0", "Alpha one."), ("bN", "Alpha two."),
                    ("z", "Back matter.")])
            == nil)
        // And when a non-seam slot's IDENTITY changed (concurrent reorder).
        #expect(derive(
            .divide(entryIndex: 1, sourceID: "b0", successorID: "bN"), old: old,
            fresh: [("swapped", "Front matter."), ("b0", "Alpha one."), ("bN", "Alpha two."),
                    ("z", "Back matter.")])
            == nil)
    }

    @Test func extractAndMakeBlockAndMergeRefuseNonSeamDrift() {
        #expect(derive(
            .extract(entryIndex: 1, edge: .suffix, sourceID: "b0", extractedID: "bX"),
            old: old,
            fresh: [("a", "Front matter."), ("b0", "Alpha one."), ("bX", "Alpha two."),
                    ("z", "Back matter, longer.")])
            == nil)
        let makeOld = OldWorld([("a", "Front matter."), ("b0", "AA. BB. CC."), ("z", "Back matter.")])
        #expect(derive(
            .makeBlock(entryIndex: 1, sourceID: "b0", middleID: "bM", suffixID: "bS"),
            old: makeOld,
            fresh: [("a", "Front matter, drifted."), ("b0", "AA."), ("bM", "BB."), ("bS", "CC."),
                    ("z", "Back matter.")])
            == nil)
        let mergeOld = OldWorld([("a", "Front matter."), ("b0", "One two."), ("b1", "Three."), ("z", "Back matter.")])
        #expect(derive(
            .merge(leadingIndex: 1, mergedID: "bM"), old: mergeOld,
            fresh: [("a", "Front matter."), ("bM", "One two. Three."), ("z", "Back matter GREW.")])
            == nil)
    }

    @Test func alignedNonSeamSlotsStillDerive() {
        // The guard is correspondence, not paranoia: untouched neighbors
        // (same ID, same length) pass and the seam derives normally.
        let edit = derive(
            .divide(entryIndex: 1, sourceID: "b0", successorID: "bN"), old: old,
            fresh: [("a", "Front matter."), ("b0", "Alpha one."), ("bN", "Alpha two."),
                    ("z", "Back matter.")])
        #expect(edit != nil)
    }
}

@Suite("StructuralSeamEdit — retained-byte verification (author-directed, round-1 MINOR 3 follow-up)")
struct SeamEditRetainedByteTests {
    // Every doctored projection below keeps GEOMETRY identical (same
    // lengths, same IDs, same counts) and changes only BYTES in a region
    // the differential edit deliberately does not rewrite — exactly the
    // divergence the old length-arithmetic guards could not see.

    @Test func divideRefusesASameLengthRewriteOfTheKeptFirstHalf() {
        let old = OldWorld([("b0", "Alpha one. Alpha two."), ("b1", "Tail.")])
        // "Omega one." is 10 units like "Alpha one." — the retained prefix
        // on the surface would silently disagree with the store.
        #expect(derive(
            .divide(entryIndex: 0, sourceID: "b0", successorID: "bN"), old: old,
            fresh: [("b0", "Omega one."), ("bN", "Alpha two."), ("b1", "Tail.")])
            == nil)
    }

    @Test func extractRefusesSameLengthRewritesOfTheRetainedRemainder() {
        let old = OldWorld([("b0", "Intro. Rest of it.")])
        // Prefix edge: the retained SUFFIX bytes drifted (same length).
        #expect(derive(
            .extract(entryIndex: 0, edge: .prefix, sourceID: "b0", extractedID: "bX"),
            old: old, fresh: [("bX", "Intro."), ("b0", "Rest of at.")])
            == nil)
        // Suffix edge: the retained PREFIX bytes drifted (same length).
        #expect(derive(
            .extract(entryIndex: 0, edge: .suffix, sourceID: "b0", extractedID: "bX"),
            old: old, fresh: [("b0", "Outro!"), ("bX", "Rest of it.")])
            == nil)
    }

    @Test func makeBlockRefusesSameLengthRewritesOfEitherKeptEdge() {
        let old = OldWorld([("b0", "AA. BB. CC.")])
        // The kept prefix drifted.
        #expect(derive(
            .makeBlock(entryIndex: 0, sourceID: "b0", middleID: "bM", suffixID: "bS"),
            old: old, fresh: [("b0", "XX."), ("bM", "BB."), ("bS", "CC.")])
            == nil)
        // The kept suffix drifted.
        #expect(derive(
            .makeBlock(entryIndex: 0, sourceID: "b0", middleID: "bM", suffixID: "bS"),
            old: old, fresh: [("b0", "AA."), ("bM", "BB."), ("bS", "XX.")])
            == nil)
    }

    @Test func mergeRefusesASameLengthRewriteOfEitherHalf() {
        let old = OldWorld([("b0", "One two."), ("b1", "Three.")])
        // Same length as "One two. Three." but the lead half's bytes moved.
        #expect(derive(
            .merge(leadingIndex: 0, mergedID: "bM"), old: old,
            fresh: [("bM", "One TWO. Three.")])
            == nil)
        // And the trail half's bytes.
        #expect(derive(
            .merge(leadingIndex: 0, mergedID: "bM"), old: old,
            fresh: [("bM", "One two. THREE.")])
            == nil)
    }

    @Test func aSurfaceIndexDisagreementRefusesToo() {
        // The oldTextAt closure must agree with the index's lengths — a
        // desynced surface never feeds a differential edit.
        let index = BlockRangeIndex(
            entries: [BlockRangeIndex.Entry(blockID: "b0", variantID: "v", length: 21, editable: true),
                      BlockRangeIndex.Entry(blockID: "b1", variantID: "v1", length: 5, editable: true)],
            tailLength: nil)
        let edit = StructuralSeamEdit.derive(
            .divide(entryIndex: 0, sourceID: "b0", successorID: "bN"),
            oldIndex: index,
            oldTextAt: { _ in "short" },  // disagrees with length 21
            fresh: freshSlots([("b0", "Alpha one."), ("bN", "Alpha two."), ("b1", "Tail.")]))
        #expect(edit == nil)
    }
}
