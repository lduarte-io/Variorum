//
//  SeamMergeTests.swift
//  VariorumTests
//
//  Phase 13d, batch 2 — QUESTIONS #34, her ruling at the 13c ratify walk
//  (2026-07-27), option (ii):
//
//      backspace at a seam between two TEXTED blocks MERGES when NEITHER
//      block has takes, and refuses-and-speaks when either does.
//
//  Why it was hers to rule rather than a quiet fix, in her own words (the
//  principle #34 quoted back at her): *"there is no other writing editor
//  where you can select a bunch of text, hit delete, and it doesn't delete…
//  if your text looks like basic text with no variants, it should behave
//  like basic text."*
//
//  This is the SECOND named exception to the ratified cross-block
//  destructive-edit refusal (AppSpec §14, 2026-07-06 Phase 6 closeout
//  delta). A7's empty-block carve (13c 1B) is the first, and this suite
//  keeps the two honest about each other: the carve's authorization is
//  *"there is no text to lose"* and it must not widen (its cannot-widen
//  pins live in `BlockDeletionAndRedoTests` and run unchanged); this one's
//  authorization is *"neither block has takes"*, and the load-bearing pins
//  here are the ones proving a FAN stops it — including a fan that arrives
//  while she is typing, which is the 13c R3-1 staleness class one door over.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@Suite("Backspace at a texted seam (13d, #34)")
@MainActor
struct SeamMergeTests {
    private func index(_ lengths: [Int], tail: Int? = nil, editable: Bool = true) -> BlockRangeIndex {
        BlockRangeIndex(
            entries: lengths.enumerated().map { i, length in
                BlockRangeIndex.Entry(
                    blockID: "b\(i)", variantID: "v\(i)", length: length, editable: editable)
            },
            tailLength: tail)
    }

    // MARK: - The geometry (pure)

    @Test func theSeparatorBetweenTwoTextedBlocksNamesThePair() {
        // ["alpha", "beta"] — surface "alpha\nbeta"; the separator is at 5.
        // Backspace at the start of "beta" and forward-delete at the end of
        // "alpha" propose the SAME range, which is why point 4's directional
        // parity is free: the gestures are one edit.
        let pair = index([5, 4]).textedSeamPair(
            deleting: NSRange(location: 5, length: 1), isDeletion: true)
        #expect(pair?.0 == 0)
        #expect(pair?.1 == 1)
    }

    @Test func aMiddleSeamIsNamedFromEitherSide() {
        // ["a", "bb", "c"] — separators at 1 and 3.
        let idx = index([1, 2, 1])
        #expect(idx.textedSeamPair(
            deleting: NSRange(location: 1, length: 1), isDeletion: true)?.0 == 0)
        #expect(idx.textedSeamPair(
            deleting: NSRange(location: 4, length: 1), isDeletion: true)?.0 == 1)
    }

    // MARK: - …and it cannot widen either

    @Test func anEmptyNeighbourIsNeverTheSeamMerge() {
        // A7's carve owns those, and the two are mutually exclusive BY
        // CONSTRUCTION: one requires a zero-length neighbour, the other
        // requires neither.
        #expect(index([0, 5]).textedSeamPair(
            deleting: NSRange(location: 0, length: 1), isDeletion: true) == nil)
        #expect(index([5, 0]).textedSeamPair(
            deleting: NSRange(location: 5, length: 1), isDeletion: true) == nil)
    }

    @Test func aRangeThatIsNotExactlyOneSeparatorIsNeverTheSeamMerge() {
        let idx = index([5, 4])
        // The separator plus a byte of the block below.
        #expect(idx.textedSeamPair(
            deleting: NSRange(location: 5, length: 2), isDeletion: true) == nil)
        // A caret-only range proposes no deletion at all.
        #expect(idx.textedSeamPair(
            deleting: NSRange(location: 5, length: 0), isDeletion: true) == nil)
        // A one-character range INSIDE a block is that block's own edit.
        #expect(idx.textedSeamPair(
            deleting: NSRange(location: 2, length: 1), isDeletion: true) == nil)
    }

    @Test func typingOverASeamIsNeverTheSeamMerge() {
        #expect(index([5, 4]).textedSeamPair(
            deleting: NSRange(location: 5, length: 1), isDeletion: false) == nil,
            "a replacement is a different gesture — only a DELETION joins")
    }

    @Test func theTailSeparatorIsNeverTheSeamMerge() {
        // The separator before an open tail belongs to `closeTail`; neither
        // seam act may steal it.
        let idx = index([5, 4], tail: 0)
        #expect(idx.tailSeparatorOffset == 10)
        #expect(idx.textedSeamPair(
            deleting: NSRange(location: 10, length: 1), isDeletion: true) == nil)
        // …and the real seam inside the same document still answers.
        #expect(idx.textedSeamPair(
            deleting: NSRange(location: 5, length: 1), isDeletion: true)?.0 == 0)
    }

    @Test func aSingleBlockPostHasNoSeamToJoin() {
        #expect(index([5]).textedSeamPair(
            deleting: NSRange(location: 5, length: 1), isDeletion: true) == nil)
        #expect(index([]).textedSeamPair(
            deleting: NSRange(location: 0, length: 1), isDeletion: true) == nil)
    }

    @Test func theCarveAndTheSeamMergeAreMUTUALLYEXCLUSIVEAtEverySeparator() {
        // Both run off ONE geometry brain (`interEntrySeparatorPair`), and
        // exactly one of them can answer for any separator: A7's needs an
        // empty neighbour, #34's needs two texted ones.
        let idx = index([0, 5, 4, 0])  // "" · "alpha" · "beta" · ""
        for offset in 0...idx.documentLength {
            let range = NSRange(location: offset, length: 1)
            let carve = idx.emptyBlockDeletion(replacing: range, isDeletion: true)
            let seam = idx.textedSeamPair(deleting: range, isDeletion: true)
            #expect(carve == nil || seam == nil, "both answered at \(offset)")
        }
        // …and both are reachable in that same document (non-vacuity).
        #expect(idx.emptyBlockDeletion(
            replacing: NSRange(location: 0, length: 1), isDeletion: true) == 0)
        #expect(idx.textedSeamPair(
            deleting: NSRange(location: 6, length: 1), isDeletion: true)?.0 == 1)
    }

    @Test func theSeamPlanIsInvisibleToTheTwoCrossBlockPlans() async throws {
        // Which is why `shouldChangeText` can run them in sequence: both
        // cross-block plans collect targets by INTERSECTION (`length > 0`),
        // and a lone separator intersects nothing.
        try await withEditor(seedBlocks: ["alpha", "beta"]) { harness in
            let separator = NSRange(location: 5, length: 1)
            #expect(harness.model.planSeamMerge(range: separator, replacement: "") != nil)
            #expect(harness.model.planEmptyBlockDeletion(range: separator, replacement: "") == nil)
            #expect(harness.model.planCrossBlockEdit(range: separator, replacement: "") == nil)
            #expect(harness.model.planVisibleTakeEdit(range: separator, replacement: "") == nil)

            // A genuine cross-block span still routes to the ratified
            // merge-then-edit compound, untouched by this batch.
            let span = NSRange(location: 3, length: 4)  // "ha\nb"
            #expect(harness.model.planSeamMerge(range: span, replacement: "") == nil)
            #expect(harness.model.planCrossBlockEdit(range: span, replacement: "") != nil)
        }
    }

    // MARK: - The ruling, end to end through the real keystroke path

    @Test func backspaceAtATextedSeamMERGESTheTwoBlocks() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta"]) { harness in
            #expect(harness.documentText == "alpha\nbeta")

            // Backspace with the caret at the start of "beta".
            harness.replace(NSRange(location: 5, length: 1), with: "")
            await harness.flush()

            let texts = try harness.storeSlots().compactMap(\.text)
            #expect(texts == ["alpha beta"],
                    "ONE block, joined by the canon merge rule (a single space at the join)")
            #expect(harness.documentText == "alpha beta")
            #expect(harness.model.index.entries.count == 1)

            // It is the ORDINARY merge: one undo entry, the operation's own
            // label, and the caret at the join.
            let stack = harness.session.undoStack
            #expect(stack.depth == 1)
            #expect(stack.topLabel == "Merge")
            #expect(harness.textView.selectedRange().location == 6,
                    "the caret sits where the joined half begins")
            #expect(harness.model.statusMessage?.isEmpty == false,
                    "and the act speaks — ⌘Z cannot take a structural change back")

            // Undo restores both blocks; redo re-applies (13c 1B's totality).
            try await harness.session.runner.run { ops in _ = try stack.undo(with: ops) }
            try harness.reload()
            let texts1 = try harness.storeSlots().compactMap(\.text)
            #expect(texts1 == ["alpha", "beta"])
            #expect(harness.documentText == "alpha\nbeta")

            try await harness.session.runner.run { ops in _ = try stack.redo(with: ops) }
            try harness.reload()
            let texts2 = try harness.storeSlots().compactMap(\.text)
            #expect(texts2 == ["alpha beta"])
        }
    }

    @Test func forwardDeleteAtTheEndOfABlockMERGESTooTheSameWay() async throws {
        // Point 4's parity, at the surface: the carve accepts any deletion of
        // exactly one inter-entry separator — backspace from the block below,
        // forward-delete from the block above, or selecting the separator and
        // deleting it. All three propose the SAME edit, so the merge case
        // accepts identically, by construction rather than by three wirings.
        try await withEditor(seedBlocks: ["alpha", "beta", "gamma"]) { harness in
            #expect(harness.documentText == "alpha\nbeta\ngamma")
            // Forward-delete with the caret at the END of "beta" (offset 10).
            harness.replace(NSRange(location: 10, length: 1), with: "")
            await harness.flush()

            let texts3 = try harness.storeSlots().compactMap(\.text)
            #expect(texts3 == ["alpha", "beta gamma"])
            #expect(harness.documentText == "alpha\nbeta gamma")
            #expect(harness.session.undoStack.topLabel == "Merge")
        }
    }

    @Test func selectingTheSeparatorAndDeletingMERGESTooTheSameWay() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta"]) { harness in
            harness.textView.setSelectedRange(NSRange(location: 5, length: 1))
            harness.replace(harness.textView.selectedRange(), with: "")
            await harness.flush()
            let texts4 = try harness.storeSlots().compactMap(\.text)
            #expect(texts4 == ["alpha beta"])
        }
    }

    // MARK: - …and it refuses-and-speaks where a fan hangs on the seam

    @Test func aFANNEDSeamREFUSESAndNamesTheDoorThatCanFoldIt() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta"]) { harness in
            let slots = try harness.storeSlots()
            _ = try harness.session.operations.branchVariant(
                slots[0].blockID, from: try #require(slots[0].variantID))
            try harness.reload()
            let depthBefore = harness.session.undoStack.depth

            harness.replace(NSRange(location: 5, length: 1), with: "")
            await harness.flush()

            let texts5 = try harness.storeSlots().compactMap(\.text)
            #expect(texts5 == ["alpha", "beta"],
                    "a keystroke must never fold a fan away")
            #expect(harness.documentText == "alpha\nbeta")
            #expect(harness.session.undoStack.depth == depthBefore,
                    "nothing structural happened")
            let message = try #require(harness.model.statusMessage)
            #expect(message.contains("takes"), "the fan is NAMED")
            #expect(message.contains("⌘⇧M"), "…and the explicit door is pointed at")
        }
    }

    @Test func aFanOnTheTRAILINGBlockRefusesJustTheSame() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta"]) { harness in
            let slots = try harness.storeSlots()
            _ = try harness.session.operations.branchVariant(
                slots[1].blockID, from: try #require(slots[1].variantID))
            try harness.reload()

            harness.replace(NSRange(location: 5, length: 1), with: "")
            await harness.flush()

            let texts6 = try harness.storeSlots().compactMap(\.text)
            #expect(texts6 == ["alpha", "beta"])
            #expect(harness.model.statusMessage?.contains("below") == true,
                    "…and it says WHICH side carries the fan")
        }
    }

    @Test func theRefusalNamesTheSideThatCarriesTheFan() {
        #expect(EditorSurfaceController.seamFanRefusal(leading: 3, trailing: 1)
            .hasPrefix("The block above has takes"))
        #expect(EditorSurfaceController.seamFanRefusal(leading: 1, trailing: 2)
            .hasPrefix("The block below has takes"))
        #expect(EditorSurfaceController.seamFanRefusal(leading: 2, trailing: 2)
            .hasPrefix("Both blocks at this seam have takes"))
        #expect(EditorSurfaceController.seamFanRefusal(leading: 2, trailing: 1)
            .contains("Merge Blocks (⌘⇧M)"))
    }

    /// **THE pin this design exists for** — the 13c R3-1 class, one door
    /// over, and the reason the fan question is NOT asked at plan time.
    ///
    /// `model.slots` is deliberately frozen while the editor is busy
    /// (`EditorProjectionPolicy.decide` defers every delivery whenever the
    /// buffer is dirty, and autosave's debounce re-arms on each keystroke),
    /// so a plan-time fan guard reading it would pass on stale data for a
    /// whole typing burst — and a keystroke would then fold away a fan that
    /// arrived from sync, or from her own takes surface, mid-sentence.
    ///
    /// So the fan is read ONCE, from the store, at run time — the merge
    /// ceremony's own threshold read (S4-23 ruling 4), shared by name with
    /// the ⌘⇧M door. This pin drives the frozen projection on purpose: it
    /// deliberately does NOT call `reload()`.
    @Test func aFanArrivingWhileSheIsTypingStillStopsTheMerge() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta"]) { harness in
            let trailingID = try harness.storeSlots()[1].blockID
            let trailingVariant = try #require(try harness.storeSlots()[1].variantID)

            // She is typing: autosave holds the edit for its debounce, so the
            // editor is BUSY and every arriving projection defers.
            harness.type("X", at: 0)
            #expect(harness.model.autosave.isDirty, "the burst — this pin's precondition")
            #expect(harness.documentText == "Xalpha\nbeta")

            // Meanwhile a take is born on the block below. From sync, or from
            // her own takes surface, which never touches this buffer.
            _ = try harness.session.operations.branchVariant(
                trailingID, from: trailingVariant)

            // The observation delivers, and the engine defers it. This is the
            // frozen array a plan-time guard would have been reading.
            let fresh = try harness.storeSlots()
            #expect(fresh[1].activeVariantCount == 2, "the STORE knows about the take")
            harness.model.applyProjection(fresh)
            #expect(harness.model.slots[1].activeVariantCount == 1,
                    "…and the editor's projection deliberately does not — the freeze, reproduced")
            #expect(harness.model.planSeamMerge(
                range: NSRange(location: 6, length: 1), replacement: "") != nil,
                "the PLAN is stale-blind by design — it never asks about the fan")

            // Her keystroke, through the real path.
            harness.replace(NSRange(location: 6, length: 1), with: "")
            await harness.flush()

            let after = try harness.storeSlots()
            // Indexed by `first`/`dropFirst` deliberately: when this pin goes
            // RED it is because the blocks MERGED, and a subscript would then
            // trap and take the whole run's evidence with it (observed while
            // verifying the revert).
            #expect(after.count == 2, "both blocks SURVIVE — the plan was stale, the run was not")
            #expect(after.first?.text == "Xalpha", "…and her typing landed")
            #expect(after.dropFirst().first?.activeVariantCount == 2,
                    "…and the take is untouched")
            #expect(harness.session.undoStack.depth == 0, "nothing structural happened")
            #expect(harness.model.statusMessage?.contains("takes") == true, "and it SPEAKS (P-2)")
        }
    }

    // MARK: - The standing refusals this batch must not route around

    /// A sealed post never reaches the seam act at all — the surface itself
    /// goes read-only when the header lands (`adoptHeader`), so the keystroke
    /// never becomes a proposed edit. That is the standing seal behaviour and
    /// this batch must not route around it; the pin observes the mechanism
    /// (a non-editable surface) rather than a message the seal has no
    /// occasion to print.
    @Test func aSealedPostStillRefusesTheSeamKeystroke() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta"]) { harness in
            try harness.session.operations.lockPost(harness.postID)
            try harness.reload()
            #expect(harness.textView.isEditable == false, "the seal freezes the surface")

            harness.replace(NSRange(location: 5, length: 1), with: "")
            await harness.flush()

            let texts7 = try harness.storeSlots().compactMap(\.text)
            #expect(texts7 == ["alpha", "beta"],
                    "the seal refuses everything under the post — before any plan runs")
            #expect(harness.session.undoStack.depth == 0)
            #expect(harness.documentText == "alpha\nbeta")

            // …and the refusal DOES speak on the door that can be pressed
            // under a seal: an unsealed-surface plan is what the seam act
            // consumes, so the model's own guard is the one that speaks.
            #expect(harness.model.shouldChangeText(
                in: NSRange(location: 5, length: 1), replacement: "") == false)
            #expect(harness.model.statusMessage?.contains("sealed") == true)
        }
    }

    @Test func anEmptyBlockAtTheSeamStillTakesTheCarveNotTheMerge() async throws {
        // Precedence, at the surface: A7 first, unchanged. The block goes;
        // nothing is joined.
        try await withEditor(seedBlocks: ["alpha", "", "beta"]) { harness in
            harness.replace(NSRange(location: 5, length: 1), with: "")
            await harness.flush()

            let texts8 = try harness.storeSlots().compactMap(\.text)
            #expect(texts8 == ["alpha", "beta"],
                    "the empty block was DELETED — not merged into its neighbour")
            #expect(harness.session.undoStack.topLabel == "Delete Block")
        }
    }
}
