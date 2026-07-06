//
//  BlockRangeIndexTests.swift
//  VariorumTests
//
//  Phase 7 Step 3 — the hard core's pure layer, exhaustively: edit routing
//  at every boundary class, the confirmed cross-block refuse/clamp rule
//  (interpretation 3a), tail gestures, grapheme edge cases (UTF-16 offsets,
//  the Phase 3 unit decision), and the mutation bookkeeping.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("BlockRangeIndex (Step 3)")
struct BlockRangeIndexTests {
    /// "one" (0-3) · sep 3 · "two two" (4-11) · sep 11 · "three" (12-17)
    private func threeBlocks() -> BlockRangeIndex {
        BlockRangeIndex(
            slots: [slot("a", text: "one"), slot("b", text: "two two"), slot("c", text: "three")],
            tail: nil)
    }

    private func verdict(
        _ index: BlockRangeIndex, _ location: Int, _ length: Int,
        newline: Bool = false, mode: Segmentation = .paragraph
    ) -> BlockRangeIndex.Verdict {
        index.verdict(
            replacing: NSRange(location: location, length: length),
            replacementIsSingleNewline: newline,
            segmentation: mode)
    }

    // MARK: - Insertions at every boundary class

    @Test func insertionsInsideABlockBelongToIt() {
        let index = threeBlocks()
        #expect(verdict(index, 0, 0) == .block(index: 0))   // start of doc
        #expect(verdict(index, 1, 0) == .block(index: 0))   // middle
        #expect(verdict(index, 3, 0) == .block(index: 0))   // end of block a (append)
        #expect(verdict(index, 4, 0) == .block(index: 1))   // start of block b (prepend)
        #expect(verdict(index, 7, 0) == .block(index: 1))   // middle of b
        #expect(verdict(index, 11, 0) == .block(index: 1))  // end of b
        #expect(verdict(index, 12, 0) == .block(index: 2))  // start of c
        #expect(verdict(index, 17, 0) == .block(index: 2))  // doc end (no tail): append to c
    }

    @Test func enterInsideABlockIsContent() {
        // I4: a newline inside (or at a non-last block's edge) never splits.
        let index = threeBlocks()
        #expect(verdict(index, 1, 0, newline: true) == .block(index: 0))
        #expect(verdict(index, 3, 0, newline: true) == .block(index: 0))
        #expect(verdict(index, 4, 0, newline: true) == .block(index: 1))
    }

    @Test func enterAtDocumentEndOpensTheTail() {
        let index = threeBlocks()
        #expect(verdict(index, 17, 0, newline: true) == .openTail)
    }

    @Test func enterAtDocumentEndIsContentInOneBlockMode() {
        // one_block posts never crystallize: Enter stays content forever.
        let index = threeBlocks()
        #expect(verdict(index, 17, 0, newline: true, mode: .oneBlock) == .block(index: 2))
    }

    @Test func pasteAtDocumentEndIsBlockContentNotTailOpening() {
        // Only a typed single newline opens the tail.
        let index = threeBlocks()
        #expect(verdict(index, 17, 0, newline: false) == .block(index: 2))
    }

    // MARK: - Replacements and deletions

    @Test func editsFullyInsideOneBlockAreAllowed() {
        let index = threeBlocks()
        #expect(verdict(index, 0, 3) == .block(index: 0))    // whole block a
        #expect(verdict(index, 5, 2) == .block(index: 1))    // inside b
        #expect(verdict(index, 12, 5) == .block(index: 2))   // whole block c
    }

    @Test func crossBoundaryEditsRefuse() {
        // Confirmed interpretation 3a: refuse/clamp until Phase 9's gestures.
        let index = threeBlocks()
        #expect(verdict(index, 3, 1) == .refuse(.crossesBlockBoundary))    // the separator alone
        #expect(verdict(index, 2, 3) == .refuse(.crossesBlockBoundary))    // a-end across sep into b
        #expect(verdict(index, 0, 12) == .refuse(.crossesBlockBoundary))   // a + sep + b
        #expect(verdict(index, 0, 17) == .refuse(.crossesBlockBoundary))   // select-all
        #expect(verdict(index, 10, 3) == .refuse(.crossesBlockBoundary))   // b into c
    }

    @Test func backspaceAtBlockStartRefuses() {
        // Deleting the separator before a block would be an implicit merge.
        let index = threeBlocks()
        #expect(verdict(index, 3, 1) == .refuse(.crossesBlockBoundary))
        #expect(verdict(index, 11, 1) == .refuse(.crossesBlockBoundary))
    }

    // MARK: - Read-only slots

    @Test func gapAndLockedSlotsRefuse() {
        let index = BlockRangeIndex(
            slots: [
                slot("a", text: "one"),
                slot("gap", variant: nil, text: nil),
                slot("c", text: "three", locked: true),
            ],
            tail: nil)
        // gap is zero-length at offset 4.
        #expect(verdict(index, 4, 0) == .refuse(.readOnlySlot))
        #expect(verdict(index, 5, 2) == .refuse(.lockedVariant))
    }

    // MARK: - Empty blocks

    @Test func emptyBlocksResolveUnambiguously() {
        // "one" (0-3) · sep 3 · "" (4,4) · sep 4 · "three" (5-10)
        let index = BlockRangeIndex(
            slots: [slot("a", text: "one"), slot("b", text: ""), slot("c", text: "three")],
            tail: nil)
        #expect(verdict(index, 3, 0) == .block(index: 0))
        #expect(verdict(index, 4, 0) == .block(index: 1))  // the empty slot
        #expect(verdict(index, 5, 0) == .block(index: 2))
    }

    // MARK: - The tail

    @Test func tailEditsAreTailEdits() {
        // "one" (0-3) · sep 3 · tail "draft" (4-9)
        let index = BlockRangeIndex(slots: [slot("a", text: "one")], tail: "draft")
        #expect(verdict(index, 4, 0) == .tail)
        #expect(verdict(index, 9, 0) == .tail)
        #expect(verdict(index, 4, 5) == .tail)
        // Block ↔ tail crossings refuse.
        #expect(verdict(index, 2, 4) == .refuse(.crossesBlockBoundary))
        #expect(verdict(index, 3, 1) == .refuse(.crossesBlockBoundary))  // the tail separator, tail non-empty
    }

    @Test func deletingTheSeparatorOfAnEmptyTailClosesIt() {
        let index = BlockRangeIndex(slots: [slot("a", text: "one")], tail: "")
        #expect(verdict(index, 3, 1) == .closeTail)
    }

    @Test func anEmptyPostRoutesEverythingToTheTail() {
        let index = BlockRangeIndex(slots: [], tail: "")
        #expect(index.tailRange == NSRange(location: 0, length: 0))
        #expect(verdict(index, 0, 0) == .tail)
        #expect(verdict(index, 0, 0, newline: true) == .tail)
    }

    // MARK: - Desync posture (review round 1, MINOR 7)

    @Test func outOfRangeEditsRefuseAsDesyncNeverCrash() {
        // If the index ever stops describing the storage, the verdict is a
        // refusal that triggers store-truth recovery — not a release crash.
        let index = threeBlocks()
        #expect(verdict(index, 18, 0) == .refuse(.indexDesync))   // doc is 17
        #expect(verdict(index, 10, 20) == .refuse(.indexDesync))
    }

    // MARK: - Graphemes (UTF-16 discipline)

    @Test func utf16OffsetsCarrySurrogatePairsAndCombiningMarks() {
        // "🦉x" = 3 UTF-16 units; "e\u{301}fin" (é decomposed) = 5 units.
        let owl = "🦉x"
        let index = BlockRangeIndex(
            slots: [slot("a", text: owl), slot("b", text: "e\u{301}fin")],
            tail: nil)
        #expect(index.range(ofEntryAt: 0) == NSRange(location: 0, length: 3))
        #expect(index.range(ofEntryAt: 1) == NSRange(location: 4, length: 5))
        // Insertions inside the owl's surrogate pair still route to block a
        // (the editor never produces them, but the math must not leak).
        #expect(verdict(index, 1, 0) == .block(index: 0))
        #expect(verdict(index, 3, 0) == .block(index: 0))
        #expect(verdict(index, 4, 0) == .block(index: 1))
    }

    // MARK: - Mutations

    @Test func blockEditsGrowAndShrinkTheOwner() {
        var index = threeBlocks()
        index.applyBlockEdit(at: 1, lengthDelta: 5)
        #expect(index.range(ofEntryAt: 1) == NSRange(location: 4, length: 12))
        #expect(index.range(ofEntryAt: 2) == NSRange(location: 17, length: 5))
        index.applyBlockEdit(at: 1, lengthDelta: -12)
        #expect(index.range(ofEntryAt: 1) == NSRange(location: 4, length: 0))
        #expect(index.documentLength == 3 + 1 + 0 + 1 + 5)
    }

    @Test func tailLifecycle() {
        var index = threeBlocks()
        #expect(index.tailRange == nil)
        index.openTail()
        #expect(index.tailRange == NSRange(location: 18, length: 0))
        index.applyTailEdit(lengthDelta: 4)
        #expect(index.tailRange == NSRange(location: 18, length: 4))
        index.applyTailEdit(lengthDelta: -4)
        index.closeTail()
        #expect(index.tailRange == nil)
        #expect(index.documentLength == 17)
    }

    @Test func crystallizeConvertsTailPrefixIntoEntries() {
        var index = BlockRangeIndex(slots: [slot("a", text: "one")], tail: "para\nrest")
        index.crystallize(
            minted: [("b", "vb", 4)],
            remainingTailLength: 4)
        #expect(index.entries.map(\.blockID) == ["a", "b"])
        #expect(index.range(ofEntryAt: 1) == NSRange(location: 4, length: 4))
        #expect(index.tailRange == NSRange(location: 9, length: 4))
        // Doc: "one" 3 + sep + "para" 4 + sep + "rest" 4 = 13.
        #expect(index.documentLength == 13)
    }

    @Test func crystallizeCanCloseTheTail() {
        var index = BlockRangeIndex(slots: [], tail: "entry text")
        index.crystallize(minted: [("a", "va", 10)], remainingTailLength: nil)
        #expect(index.entries.map(\.blockID) == ["a"])
        #expect(index.tailRange == nil)
        #expect(index.documentLength == 10)
    }
}
