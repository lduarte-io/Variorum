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

    // These two exercise the HAPPY road, where the mutators' answers are
    // uninteresting by construction (each call is legal on the fixture, and
    // the ranges asserted below are the real oracle). The mutators carry no
    // `@discardableResult` on purpose — a caller that ignores a refusal is
    // the bug MINOR 2 closed — so the discard is spelled out rather than
    // waived, which keeps the compiler's warning meaningful for the call
    // sites that must react (round-2 ladder round 2, NIT 1).

    @Test func blockEditsGrowAndShrinkTheOwner() {
        var index = threeBlocks()
        _ = index.applyBlockEdit(at: 1, lengthDelta: 5)
        #expect(index.range(ofEntryAt: 1) == NSRange(location: 4, length: 12))
        #expect(index.range(ofEntryAt: 2) == NSRange(location: 17, length: 5))
        _ = index.applyBlockEdit(at: 1, lengthDelta: -12)
        #expect(index.range(ofEntryAt: 1) == NSRange(location: 4, length: 0))
        #expect(index.documentLength == 3 + 1 + 0 + 1 + 5)
    }

    @Test func tailLifecycle() {
        var index = threeBlocks()
        #expect(index.tailRange == nil)
        _ = index.openTail()
        #expect(index.tailRange == NSRange(location: 18, length: 0))
        _ = index.applyTailEdit(lengthDelta: 4)
        #expect(index.tailRange == NSRange(location: 18, length: 4))
        _ = index.applyTailEdit(lengthDelta: -4)
        _ = index.closeTail()
        #expect(index.tailRange == nil)
        #expect(index.documentLength == 17)
    }

    // MARK: - The mutators REFUSE instead of trapping (mobile round 2, M1)

    /// Her two 2026-08-20 iPhone crashes were `precondition` failures in
    /// this band, and `precondition` survives `-O` — so the shipped app
    /// DIED where the surrounding design already had a name and a road for
    /// the state (`Refusal.indexDesync` → the view model's re-render from
    /// the store). The guarantee is unchanged and pinned here: the struct
    /// still cannot hold a negative length, and a refused mutation leaves
    /// the value BYTE-IDENTICAL. Only the delivery changed.
    ///
    /// RED ON THE PRE-FIX TREE by process death — today's code traps
    /// inside the mutator instead of returning `false`.
    ///
    /// (The results are bound to locals before `#expect` sees them: the
    /// macro decomposes its expression and cannot call a `mutating` member
    /// on the value it captures.)
    @Test func aBlockEditLargerThanItsEntryIsRefusedAndChangesNothing() {
        var index = threeBlocks()
        let refused = index.applyBlockEdit(at: 1, lengthDelta: -8)
        #expect(refused == false)
        #expect(index.entries.map(\.length) == [3, 7, 5], "a refusal mutates nothing")
        #expect(index.documentLength == 17)
        // The exact-fit boundary still applies (a block may go empty).
        let emptied = index.applyBlockEdit(at: 1, lengthDelta: -7)
        #expect(emptied)
        #expect(index.entries.map(\.length) == [3, 0, 5])
    }

    @Test func anOutOfRangeBlockEditIsRefused() {
        var index = threeBlocks()
        let past = index.applyBlockEdit(at: 3, lengthDelta: 1)
        let negative = index.applyBlockEdit(at: -1, lengthDelta: 1)
        #expect(past == false)
        #expect(negative == false)
        #expect(index.entries.map(\.length) == [3, 7, 5])
    }

    @Test func aTailEditLargerThanTheTailIsRefused() {
        var index = threeBlocks()
        let opened = index.openTail()
        #expect(opened)
        let grew = index.applyTailEdit(lengthDelta: 5)
        #expect(grew)
        let refused = index.applyTailEdit(lengthDelta: -6)
        #expect(refused == false)
        #expect(index.tailLength == 5, "a refusal mutates nothing")
        let emptied = index.applyTailEdit(lengthDelta: -5)
        #expect(emptied)
        #expect(index.tailLength == 0)
    }

    @Test func aTailEditWithNoOpenTailIsRefused() {
        var index = threeBlocks()
        #expect(index.tailLength == nil)
        let refused = index.applyTailEdit(lengthDelta: 1)
        #expect(refused == false)
        #expect(index.tailLength == nil)
    }

    /// The two tail gates (reached by Return-at-the-end and
    /// Return-then-Backspace — the two most ordinary gestures in the app
    /// after typing, which is why the stability survey ranked them beside
    /// the observed crash).
    @Test func theTailGatesRefuseInsteadOfTrapping() {
        var index = threeBlocks()
        let closeWithNoTail = index.closeTail()
        #expect(closeWithNoTail == false, "no tail to close")
        let opened = index.openTail()
        #expect(opened)
        let reopened = index.openTail()
        #expect(reopened == false, "already open")
        #expect(index.tailLength == 0)
        let grew = index.applyTailEdit(lengthDelta: 2)
        #expect(grew)
        let closedNonEmpty = index.closeTail()
        #expect(closedNonEmpty == false, "only an EMPTY tail closes")
        #expect(index.tailLength == 2)
        // A tail-only index (no entries) never opens or closes: the tiling
        // invariant says an entry-less document IS its tail.
        var empty = BlockRangeIndex(entries: [], tailLength: 0)
        let emptyClose = empty.closeTail()
        let emptyOpen = empty.openTail()
        #expect(emptyClose == false)
        #expect(emptyOpen == false)
        #expect(empty.tailLength == 0)
    }

    /// The disassembly of her crashed binary showed a live overflow trap
    /// (`b.vs`) beside the sign test. An unrepresentable sum is exactly as
    /// much "this delta does not describe me" as a negative one.
    @Test func anOverflowingDeltaIsRefusedRatherThanTrapped() {
        var index = threeBlocks()
        let overflowed = index.applyBlockEdit(at: 0, lengthDelta: .max)
        #expect(overflowed == false)
        #expect(index.entries[0].length == 3)
        let opened = index.openTail()
        #expect(opened)
        let grew = index.applyTailEdit(lengthDelta: .max)
        #expect(grew)
        let overflowedTail = index.applyTailEdit(lengthDelta: .max)
        #expect(overflowedTail == false)
        #expect(index.tailLength == Int.max)
    }

    @Test func crystallizeConvertsTailPrefixIntoEntries() {
        var index = BlockRangeIndex(slots: [slot("a", text: "one")], tail: "para\nrest")
        let crystallized = index.crystallize(
            minted: [("b", "vb", 4)],
            remainingTailLength: 4)
        #expect(crystallized)
        #expect(index.entries.map(\.blockID) == ["a", "b"])
        #expect(index.range(ofEntryAt: 1) == NSRange(location: 4, length: 4))
        #expect(index.tailRange == NSRange(location: 9, length: 4))
        // Doc: "one" 3 + sep + "para" 4 + sep + "rest" 4 = 13.
        #expect(index.documentLength == 13)
    }

    @Test func crystallizeCanCloseTheTail() {
        var index = BlockRangeIndex(slots: [], tail: "entry text")
        let crystallized = index.crystallize(minted: [("a", "va", 10)], remainingTailLength: nil)
        #expect(crystallized)
        #expect(index.entries.map(\.blockID) == ["a"])
        #expect(index.tailRange == nil)
        #expect(index.documentLength == 10)
    }

    // MARK: - VM-5 stability pass, MINOR 4: the band's two mutators refuse too

    /// **The CONTRACT of the conversion, not a red-on-old claim.** These two
    /// kept their `precondition`s through the round-2 conversion; their only
    /// callers (the shared `TailCrystallizer`'s attachment and `finishMint`)
    /// guard every precondition today, so no production road was ever
    /// observed — or traced — to trap (the VM-5 record). What is pinned here
    /// is the header's law, now true of all six: each named impossible
    /// state is REFUSED, and a refusal mutates NOTHING. (On the pre-fix code
    /// these calls would kill the test process by construction — that is the
    /// definition of the change, not evidence of a reachable bug.)
    @Test func theLeadingRunTransferRefusesInsteadOfTrapping() {
        var index = BlockRangeIndex(slots: [slot("a", text: "one")], tail: "\n\nx")
        let before = index
        let zero = index.transferTailPrefixToLastEntry(0)
        #expect(zero == false, "a run needs at least one unit")
        let longerThanTail = index.transferTailPrefixToLastEntry(4)
        #expect(longerThanTail == false, "the tail must contain the run")
        #expect(index == before, "a refusal mutates nothing")

        var closed = threeBlocks()
        let noTail = closed.transferTailPrefixToLastEntry(1)
        #expect(noTail == false, "no open tail to transfer from")
        var entryless = BlockRangeIndex(entries: [], tailLength: 3)
        let nothingToAttachTo = entryless.transferTailPrefixToLastEntry(1)
        #expect(nothingToAttachTo == false, "no entry to attach to")
        #expect(entryless.tailLength == 3)

        // …and the ordinary transfer still lands, bytes and total unchanged.
        let moved = index.transferTailPrefixToLastEntry(2)
        #expect(moved)
        #expect(index.entries.map(\.length) == [5])
        #expect(index.tailLength == 1)
        #expect(index.documentLength == before.documentLength)
    }

    @Test func crystallizeRefusesInsteadOfTrapping() {
        var closed = threeBlocks()
        let before = closed
        let noTail = closed.crystallize(minted: [("z", "vz", 1)], remainingTailLength: nil)
        #expect(noTail == false, "no open tail to crystallize")
        #expect(closed == before, "a refusal mutates nothing")

        var open = BlockRangeIndex(slots: [slot("a", text: "one")], tail: "para")
        let openBefore = open
        let nothingMinted = open.crystallize(minted: [], remainingTailLength: nil)
        #expect(nothingMinted == false, "a crystallization needs at least one mint")
        let negativeMint = open.crystallize(minted: [("b", "vb", -1)], remainingTailLength: nil)
        #expect(negativeMint == false, "this struct never holds a negative length")
        let negativeTail = open.crystallize(minted: [("b", "vb", 4)], remainingTailLength: -1)
        #expect(negativeTail == false)
        #expect(open == openBefore, "a refusal mutates nothing")
    }
}
