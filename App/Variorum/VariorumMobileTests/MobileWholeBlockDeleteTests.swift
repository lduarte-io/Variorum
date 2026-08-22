//
//  MobileWholeBlockDeleteTests.swift
//  VariorumMobileTests
//
//  Mobile round 2, batch 1b — R18 ≡ M11: a text selection covering WHOLE
//  paragraphs plus delete DELETES them, instead of refusing.
//
//  The lineage matters for reading these pins. Batch 1 fixed her crash by
//  turning a trap into an honest refusal; this batch turns that refusal
//  into the act she was reaching for, by inheriting the Mac's 13j J9 road
//  through the shared brain (`BlockRangeIndex.wholeBlockDeletion` +
//  `caretLandingAfterRemoving`, both HOISTED out of Mac app code by this
//  batch — MobileSoul §3: parity is inheritance, never reimplementation).
//
//  WHICH PINS ARE RED ON WHICH TREE — stated precisely, because the batch
//  header used to claim "every behavioural pin below fails on the pre-batch
//  tree" and three of them could not (ladder round 1, MINOR 6). Three kinds
//  live here, and each test says which it is in its own doc line:
//
//  1. RED ON THE PRE-BATCH TREE (the batch's own gesture): every pin that
//     watches a whole-paragraph selection DELETE. Pre-batch the gate's
//     `.crossesBlockBoundary` arm refused unconditionally — the store kept
//     all its blocks and `statusMessage` carried the "spans more than one
//     block" line.
//  2. RED ON THE PRE-FIX TREE (the ladder's fixes, round 1): the gap-fence
//     pins (MINOR 3(a) — a not-yet-arrived block was tombstoned), the
//     nearest-surviving caret landing (MINOR 4 — an arbitrary pick named a
//     departing block), the landing's cost at 20,000 entries (MINOR 5 —
//     10.5 s measured on the pre-fix scan), the vanished-block sentence
//     (MINOR 2 — a raw enum dump), the stranded-original half of the
//     receipt (NIT 7), and the caret write at the ⋯ door (NIT 8).
//  3. BOUNDARY CHARACTERIZATIONS, green on BOTH trees by design: the cases
//     this road deliberately does NOT take — a type-over, a
//     seam keystroke, a sealed note. They are regression guards on the new
//     road, never evidence that it works, and they are labelled as such
//     rather than counted as red-on-old.
//
//  THE LIMITATION, AND ITS END (her correction, 2026-08-21 — §30; PAID at
//  M22, round 2 batch 3): a span covering a block only PARTIALLY is not a
//  whole-block run, so this file's road declines it. It used to REFUSE on
//  the phone, and the header used to call that "identical on both platforms…
//  a standing product question" — both halves wrong: the Mac routed exactly
//  that span to the ratified 2026-07-09 merge-then-edit, which made the
//  phone's refusal a PARITY GAP. The phone now runs the same shared brain
//  (`CrossBlockEditPlanner`, hoisted at M22) and MERGES the run before
//  applying the edit, so `aPartialSpanIsNotTheDeleteRoadButTheMergeRoad`
//  guards the BOUNDARY between the two roads instead of a refusal that no
//  longer exists. That road's own pins live in `MobileCrossBlockEditTests`.
//

import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - Seeds & probes

@MainActor
private func seedParagraphPost(
    _ session: AppSession, _ texts: [String] = ["Alpha one.", "Beta two.", "Gamma three."]
) async throws -> (postID: String, blockIDs: [String]) {
    try await session.runner.run { ops in
        let post = try ops.createPost(title: "whole-block delete", profile: .blog)
        let ids = try texts.map { try ops.newBlock(in: post.id, text: $0, at: .end).block.id }
        return (post.id, ids)
    }
}

@MainActor
private func liveTexts(_ db: AppDatabase, postID: String) async throws -> [String] {
    try await storedBlockTexts(db, postID: postID)
}

/// Drives the real gesture: the delegate gate sees the span, and the
/// storage mutation only happens if the gate allows it (it does not for a
/// whole-block run — the compound reproduces the intent instead). Then the
/// scheduled compound is awaited through the VM's own handle, so nothing
/// here spins on a guess about when the act landed.
@MainActor
private func deleteSpan(
    _ model: MobileEditorViewModel, _ storage: NSTextStorage, _ range: NSRange
) async {
    typeEdit(model, storage, range: range, replacement: "")
    await model.pendingGestureTask?.value
}

// MARK: - The pure brain (the hoist's own pins)

@Suite("The shared whole-block-delete brain (R18's hoist)")
@MainActor
struct MobileWholeBlockDeleteBrainTests {

    private static func index(_ lengths: [Int], tail: Int? = nil) -> BlockRangeIndex {
        BlockRangeIndex(
            entries: lengths.enumerated().map {
                BlockRangeIndex.Entry(
                    blockID: "b\($0.offset)", variantID: "v\($0.offset)",
                    length: $0.element, editable: true)
            },
            tailLength: tail)
    }

    /// The same tiling with entry `gap` still waiting for its variant — the
    /// shape a sync arrival leaves behind (`variantID == nil`, `editable`
    /// false: the editor renders the block and refuses to type into it).
    private static func indexWithGap(_ lengths: [Int], gap: Int) -> BlockRangeIndex {
        BlockRangeIndex(
            entries: lengths.enumerated().map {
                BlockRangeIndex.Entry(
                    blockID: "b\($0.offset)",
                    variantID: $0.offset == gap ? nil : "v\($0.offset)",
                    length: $0.element, editable: $0.offset != gap)
            },
            tailLength: nil)
    }

    /// The plan is the geometry PLUS one rule: delete, never type-over.
    @Test func thePlanNamesTheBlocksAWholeSpanCovers() {
        // "aa\nbbb\nc" — starts 0/3/7, ends 2/6/8.
        let index = Self.index([2, 3, 1])
        #expect(index.wholeBlockDeletion(
            covering: NSRange(location: 3, length: 4), replacement: "") == ["b1"])
        #expect(index.wholeBlockDeletion(
            covering: NSRange(location: 0, length: 7), replacement: "") == ["b0", "b1"])
        #expect(index.wholeBlockDeletion(
            covering: NSRange(location: 0, length: 8), replacement: "") == ["b0", "b1", "b2"])
    }

    /// A type-over is a REPLACEMENT and keeps its own road — the typed
    /// characters must never be dropped on the floor by a delete compound.
    @Test func aTypeOverOfAWholeSpanIsNotADelete() {
        let index = Self.index([2, 3, 1])
        #expect(index.wholeBlockDeletion(
            covering: NSRange(location: 3, length: 4), replacement: "X") == nil)
    }

    /// **THE GAP FENCE (ladder MINOR 3(a)) — RED ON THE PRE-FIX TREE**,
    /// where the run walked straight past `variantID == nil` and the plan
    /// named the not-yet-arrived block for tombstoning. Under
    /// tombstone-wins that takes the peer's paragraph when the variant
    /// lands — text she has never seen — one keystroke after the editor
    /// told her that block was read-only until it syncs.
    @Test func aRunContainingANotYetArrivedBlockHasNoPlan() {
        let index = Self.indexWithGap([2, 3, 1], gap: 1)
        // "aa\nbbb\nc" — the whole document, geometry-perfect as a run.
        let all = NSRange(location: 0, length: 8)
        #expect(index.wholeBlockRun(covering: all) == 0...2,
                "the GEOMETRY is a whole-block run — the fence is what declines")
        #expect(index.wholeBlockDeletion(covering: all, replacement: "") == nil)
        #expect(index.wholeBlockRunAwaitsSync(covering: all))

        // The blocks that DID arrive still delete: the fence is the gap,
        // never the neighbourhood of one.
        #expect(index.wholeBlockDeletion(
            covering: NSRange(location: 0, length: 3), replacement: "") == ["b0"])
        #expect(!index.wholeBlockRunAwaitsSync(covering: NSRange(location: 0, length: 3)))
    }

    /// A LOCKED take is deliberately NOT fenced (QUESTIONS #33(a)'s
    /// unrestricted delete — the ⋯ door has always taken a locked take's
    /// block). Kind 3: green on both trees, and it is here so the gap fence
    /// above can never quietly grow into an editability fence.
    @Test func aRunContainingALockedTakeStillPlans() {
        let locked = BlockRangeIndex(
            entries: [
                BlockRangeIndex.Entry(blockID: "b0", variantID: "v0", length: 2, editable: true),
                BlockRangeIndex.Entry(blockID: "b1", variantID: "v1", length: 3, editable: false),
            ],
            tailLength: nil)
        #expect(locked.wholeBlockDeletion(
            covering: NSRange(location: 0, length: 6), replacement: "") == ["b0", "b1"])
        #expect(!locked.wholeBlockRunAwaitsSync(covering: NSRange(location: 0, length: 6)))
    }

    /// A span that is not a run at all reports no gap either — the copy
    /// chooser must not blame sync for a partial selection.
    @Test func aSpanThatIsNoRunReportsNoGap() {
        let index = Self.indexWithGap([2, 3, 1], gap: 1)
        #expect(!index.wholeBlockRunAwaitsSync(covering: NSRange(location: 4, length: 4)))
    }

    /// Partial coverage answers nil — the limitation, stated in the brain.
    @Test func aPartialSpanHasNoPlan() {
        let index = Self.index([2, 3, 1])
        // Opens mid-"bbb" and runs to the document end.
        #expect(index.wholeBlockDeletion(
            covering: NSRange(location: 4, length: 4), replacement: "") == nil)
    }

    /// The caret lands below the run when anything survives below it…
    @Test func theCaretLandsBelowTheRunWhenSomethingSurvivesThere() {
        let index = Self.index([2, 3, 1])
        let landing = index.caretLandingAfterRemoving(["b0", "b1"])
        #expect(landing.blockID == "b2")
        #expect(landing.offset == 0)
    }

    /// …and at the END of the block ABOVE it when nothing does.
    @Test func theCaretLandsAtTheEndOfTheBlockAboveWhenTheRunTakesTheTail() {
        let index = Self.index([2, 3, 1])
        let landing = index.caretLandingAfterRemoving(["b1", "b2"])
        #expect(landing.blockID == "b0")
        #expect(landing.offset == 2, "the END of the surviving block above")
    }

    /// A run that takes EVERYTHING has no survivor to name — the honest
    /// answer is the departed block, and both platforms' callers treat that
    /// as a no-op (the phone's `rangeOfBlock` simply finds nothing).
    @Test func aRunThatTakesEverythingNamesTheDepartedBlock() {
        let index = Self.index([2, 3, 1])
        #expect(index.caretLandingAfterRemoving(["b0", "b1", "b2"]).blockID == "b0")
        #expect(index.caretLandingAfterRemoving(["b0", "b1", "b2"]).offset == 0)
    }

    /// **NEAREST SURVIVING, not "just past the edges" (ladder MINOR 4) —
    /// RED ON THE PRE-FIX TREE**, which read only `last + 1` and
    /// `first - 1` and so named `b0` here: a block being deleted, while
    /// `b1` sat there surviving. The phone's own gesture is always
    /// contiguous (where both readings agree); the Mac's ⌘-click pick is
    /// not, and this is now the SHARED brain's stated rule.
    @Test func anArbitraryPickLandsOnTheNearestSURVIVINGBlock() {
        let index = Self.index([2, 3, 1])
        let landing = index.caretLandingAfterRemoving(["b0", "b2"])
        #expect(landing.blockID == "b1", "b1 survives between the picked pair")
        #expect(landing.offset == 0)
    }

    /// Order-independent: the rule reads the run's EDGES after sorting, not
    /// the caller's array order.
    @Test func theLandingReadsTheRunsEdgesNotTheCallersOrder() {
        let index = Self.index([2, 3, 1])
        let forwards = index.caretLandingAfterRemoving(["b0", "b1"])
        let backwards = index.caretLandingAfterRemoving(["b1", "b0"])
        #expect(forwards.blockID == "b2")
        #expect(backwards.blockID == forwards.blockID)
        #expect(backwards.offset == forwards.offset)
    }

    /// **THE COST, measured rather than argued (P1/P-8) — BOTH HALVES OF
    /// THE GESTURE (ladder MINOR 5).** The plan walks the entry TILING —
    /// block count, never character count — and it does so at GESTURE
    /// cadence, not keystroke cadence, because the one keystroke-cadence
    /// caller of the arm that reaches it (a backspace at a seam) is a
    /// ONE-CHARACTER range, which the brain's first guard answers before
    /// any allocation.
    ///
    /// **The LANDING is measured here too, and it is why this pin grew.**
    /// The batch measured only the plan; the landing was O(N·M) — a
    /// `firstIndex` scan per block ID — and a Select All makes M = N, which
    /// at this pin's own 20,000-entry ceiling was ~0.9 s of MAIN-ACTOR work
    /// the pin could not see. A claim with half its surface unmeasured is
    /// how that shipped, so the whole gesture is under the clock now: plan,
    /// then landing over EVERY block the plan named.
    @Test func thePlanStaysCheapAtTwentyThousandBlocks() {
        let index = Self.index(Array(repeating: 40, count: 20_000))
        let seam = NSRange(location: 40, length: 1)
        let clock = ContinuousClock()

        let seamCost = clock.measure {
            for _ in 0..<1_000 {
                #expect(index.wholeBlockDeletion(covering: seam, replacement: "") == nil)
            }
        }
        // 1,000 early-outs, so a per-call walk would be 20 million entry
        // visits — unmissable if the guard ever moves below the loop.
        #expect(seamCost < .milliseconds(200),
                "the one-character guard answers before the tiling walk")

        // A real gesture: three whole blocks in the middle of the note.
        let span = NSRange(location: 41, length: 3 * 41)
        var planned: [String]?
        let gestureCost = clock.measure { planned = index.wholeBlockDeletion(
            covering: span, replacement: "") }
        #expect(planned?.count == 3)
        #expect(gestureCost < .milliseconds(50))

        // THE LANDING, at the worst shape the surface can produce: Select
        // All, so the landing is asked about all 20,000 IDs at once (M = N).
        // The pre-fix scan measured ~0.9 s here; one position map plus one
        // survivor scan is linear, and the ceiling is generous enough to
        // stay a regression detector rather than a stopwatch — a
        // re-quadratic landing would take a hundred times it.
        let everyID = index.entries.map(\.blockID)
        var landing: (blockID: String, offset: Int)?
        let landingCost = clock.measure { landing = index.caretLandingAfterRemoving(everyID) }
        #expect(landing?.blockID == "b0", "nothing survives — the departed block, honestly named")
        #expect(landingCost < .milliseconds(100))

        // …and the everyday shape beside it: a three-block run out of
        // 20,000, where the pre-fix scan was already 3 × 20,000 visits.
        let runIDs = planned ?? []
        let runLandingCost = clock.measure { _ = index.caretLandingAfterRemoving(runIDs) }
        #expect(runLandingCost < .milliseconds(50))

        print("""
            PERF[plan] wholeBlockDeletion @20k blocks — seam×1000 \(seamCost) · \
            gesture \(gestureCost) · landing(select-all) \(landingCost) · \
            landing(3-run) \(runLandingCost)
            """)
    }

    /// IDs the index no longer holds are dropped, never trapped on — a
    /// block another pane deleted between the gesture and the press is
    /// exactly this case, and the caret must still have somewhere to go.
    @Test func unknownBlockIDsAreDroppedRatherThanTrappedOn() {
        let index = Self.index([2, 3, 1])
        #expect(index.caretLandingAfterRemoving(["ghost", "b0"]).blockID == "b1")
        #expect(index.caretLandingAfterRemoving(["ghost"]).blockID == "ghost",
                "nothing known left to name — the caller's lookup finds nothing and stands still")
    }
}

// MARK: - The phone's face

@Suite("Whole-block selection + delete on the phone (R18 ≡ M11)")
@MainActor
struct MobileWholeBlockDeleteTests {

    /// **HER CASE.** Select a whole paragraph the way a drag or a
    /// double-tap-drag does — the paragraph plus the newline the eye sees at
    /// its end — and delete. The paragraph GOES; the refusal never appears.
    ///
    /// RED ON OLD: pre-batch this leaves all three blocks in the store and
    /// `statusMessage` reads "This edit spans more than one block…".
    @Test func aWholeParagraphSelectionDeletesTheBlock() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedParagraphPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // "Alpha one.\nBeta two.\nGamma three."
            let beta = model.index.range(ofEntryAt: 1)
            await deleteSpan(
                model, storage, NSRange(location: beta.location, length: beta.length + 1))

            #expect(try await liveTexts(db, postID: seed.postID) == ["Alpha one.", "Gamma three."],
                    "the selected paragraph is gone — not emptied, not merged")
            #expect(model.statusMessage == MobileStructuralController.blockDeletedStatus,
                    "the delete's own receipt speaks, never the cross-block refusal")
            #expect(model.index.entries.count == 2, "the surface healed to the store's shape")
        }
    }

    /// The other newline the eye can include: a drag that opens on the
    /// separator ABOVE the paragraph. Same answer — the brain accepts at
    /// most one separator hanging off each end.
    @Test func aSelectionOpeningOnTheLeadingSeparatorDeletesTheSameBlock() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedParagraphPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            let beta = model.index.range(ofEntryAt: 1)
            await deleteSpan(
                model, storage,
                NSRange(location: beta.location - 1, length: beta.length + 1))

            #expect(try await liveTexts(db, postID: seed.postID) == ["Alpha one.", "Gamma three."])
            #expect(model.statusMessage == MobileStructuralController.blockDeletedStatus)
        }
    }

    /// **Her literal report's shape: the LAST paragraph of the note.**
    /// Batch 1's crash lived exactly here; batch 1 made it refuse; this
    /// makes it work.
    ///
    /// *The caret WRITE is deliberately not asserted here.* This harness is
    /// headless (`makeEditor` attaches a bare `NSTextStorage`, so
    /// `model.textView` is nil) and the write is a no-op with no text view;
    /// what IS pinned is the decision that drives it — the brain's landing,
    /// read from the same pre-delete index the door reads. The write itself
    /// is one line over that answer and needs a real `MobileEditorTextView`
    /// to observe; recorded rather than faked.
    @Test func theLastParagraphGoesAndTheLandingNamesTheBlockAbove() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedParagraphPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            let gamma = model.index.range(ofEntryAt: 2)
            let landing = model.index.caretLandingAfterRemoving([seed.blockIDs[2]])
            #expect(landing.blockID == seed.blockIDs[1])
            #expect(landing.offset == model.index.entries[1].length,
                    "the END of the paragraph above — the eye's expectation")

            await deleteSpan(
                model, storage,
                NSRange(location: gamma.location - 1, length: gamma.length + 1))

            #expect(try await liveTexts(db, postID: seed.postID) == ["Alpha one.", "Beta two."])
            #expect(model.index.entries.count == 2)
            #expect(model.statusMessage == MobileStructuralController.blockDeletedStatus)
        }
    }

    /// The middle-paragraph landing: the block BELOW the run, at its start.
    @Test func aMiddleParagraphsLandingNamesTheBlockBelowIt() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedParagraphPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            let landing = model.index.caretLandingAfterRemoving([seed.blockIDs[1]])
            #expect(landing.blockID == seed.blockIDs[2])
            #expect(landing.offset == 0)
        }
    }

    /// SEVERAL whole paragraphs in one selection go together, under ONE
    /// compound — N paragraphs deleted is one mistake to reverse, not N.
    @Test func aRunOfWholeParagraphsGoesUnderOneUndoEntry() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedParagraphPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            let alpha = model.index.range(ofEntryAt: 0)
            let beta = model.index.range(ofEntryAt: 1)
            await deleteSpan(
                model, storage,
                NSRange(location: alpha.location, length: beta.upperBound - alpha.location + 1))

            #expect(try await liveTexts(db, postID: seed.postID) == ["Gamma three."])
            #expect(model.statusMessage == "2 blocks deleted.")

            let stack = session.undoStack
            // The Mac's own compound label, shared so a future undo door on
            // this phone reads the same words.
            #expect(stack.topLabel == "Delete Blocks")
            try await session.runner.run { ops in _ = try stack.undo(with: ops) }
            #expect(try await liveTexts(db, postID: seed.postID)
                == ["Alpha one.", "Beta two.", "Gamma three."],
                    "ONE undo restores the whole run — not two")
            try await session.runner.run { ops in _ = try stack.redo(with: ops) }
            #expect(try await liveTexts(db, postID: seed.postID) == ["Gamma three."],
                    "and the redo takes them away again (every leg carries one)")
        }
    }

    /// **THE BOUNDARY BETWEEN THE TWO ROADS.** A span that opens
    /// MID-paragraph and runs on is not a whole-block run: this file's
    /// delete road declines it, and nothing here deletes a block.
    ///
    /// **ITS SECOND HALF WAS RETIRED AT M22, exactly as it predicted.** The
    /// pin used to assert that such a span "still refuses exactly as
    /// before", while recording that the Mac merges-then-edits it under the
    /// ratified 2026-07-09 rule and that the phone owed that road. Batch 3
    /// paid it: the span now MERGES the run and applies the edit
    /// (`MobileCrossBlockEditTests` carries that road's pins). So what this
    /// pin guards today is the boundary itself — the delete road must not
    /// widen onto partial spans, and the merge road must not delete a block.
    @Test func aPartialSpanIsNotTheDeleteRoadButTheMergeRoad() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedParagraphPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // "one.\nBeta " — opens inside block 0, closes inside block 1.
            let span = NSRange(location: 6, length: 10)
            #expect(model.planWholeBlockDeletion(range: span, replacement: "") == nil,
                    "not a whole-block run — the delete road declines")
            await deleteSpan(model, storage, span)

            #expect(try await liveTexts(db, postID: seed.postID)
                == ["Alpha two.", "Gamma three."],
                    "the two paragraphs JOINED and the span went with the join (M22)")
            #expect(model.statusMessage == nil, "and nothing was refused")
        }
    }

    /// Typing OVER a whole-block span is a replacement, not a delete, and
    /// keeps its own road — the typed characters are never dropped on the
    /// floor by a delete compound.
    ///
    /// **BOUNDARY CHARACTERIZATION (kind 3): green on both trees.** A
    /// type-over never deleted a block before this road existed either;
    /// this pin guards the new road from widening onto it.
    @Test func typingOverAWholeBlockSpanIsNotADelete() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedParagraphPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            let beta = model.index.range(ofEntryAt: 1)
            let span = NSRange(location: beta.location, length: beta.length + 1)
            #expect(model.planWholeBlockDeletion(range: span, replacement: "X") == nil)
            typeEdit(model, storage, range: span, replacement: "X")
            await model.pendingGestureTask?.value

            #expect(try await liveTexts(db, postID: seed.postID)
                == ["Alpha one.", "Beta two.", "Gamma three."],
                    "no block was deleted by a type-over")
        }
    }

    /// A SEAM keystroke keeps every case the two carves were ruled: a
    /// one-character range never reaches this road (the brain excludes it
    /// before any walk), so backspace at a seam still refuses on the phone
    /// exactly as it did.
    ///
    /// **BOUNDARY CHARACTERIZATION (kind 3): green on both trees.** Its job
    /// is to catch the new road stealing the seam geometry A7 and #34 own —
    /// a regression guard, not evidence the gesture works.
    @Test func aSeamBackspaceIsNotAWholeBlockDelete() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedParagraphPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            let beta = model.index.range(ofEntryAt: 1)
            let seam = NSRange(location: beta.location - 1, length: 1)
            #expect(model.planWholeBlockDeletion(range: seam, replacement: "") == nil)
            await deleteSpan(model, storage, seam)

            #expect(try await liveTexts(db, postID: seed.postID)
                == ["Alpha one.", "Beta two.", "Gamma three."])
        }
    }

    /// **A SEALED note refuses with NOTHING deleted** (P-2's letter: the
    /// gate's own lock answer stops the gesture before it is armed, and the
    /// compound's legs would refuse through the operation besides).
    ///
    /// **BOUNDARY CHARACTERIZATION (kind 3): green on both trees.** The
    /// seal refused this keystroke before the road existed; the pin exists
    /// so the road can never be built past the seal later.
    @Test func aSealedNoteRefusesAndDeletesNothing() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedParagraphPost(session)
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            #expect(model.isSealed)
            let beta = model.index.range(ofEntryAt: 1)
            let span = NSRange(location: beta.location, length: beta.length + 1)
            #expect(model.planWholeBlockDeletion(range: span, replacement: "") != nil,
                    "the span IS a whole-block run — the seal is what stops it, not the geometry")

            await deleteSpan(model, storage, span)
            #expect(try await liveTexts(db, postID: seed.postID)
                == ["Alpha one.", "Beta two.", "Gamma three."],
                    "the seal held — nothing deleted")
            #expect(model.statusMessage == "This note is locked — unlock it to edit.")
        }
    }

    /// **THE GAP FENCE'S FACE (ladder MINOR 3(a)) — RED ON THE PRE-FIX
    /// TREE**, where Select All → ⌫ tombstoned the not-yet-arrived block
    /// along with the two she can read. Under tombstone-wins that takes the
    /// peer's paragraph the moment its variant lands — text she has never
    /// seen — one keystroke after this same editor told her the block was
    /// read-only until it syncs. Now the gesture declines and says exactly
    /// that; the arrived blocks are untouched too, because a run is one
    /// act.
    @Test func aRunCoveringANotYetArrivedBlockRefusesAndSaysWhy() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedParagraphPost(session)
            // The SyncSpec §5 gap state, manufactured: the block row has
            // arrived, its variant has not (only sync apply order produces
            // this locally, so the seed writes the row state directly).
            try await db.write { [blockID = seed.blockIDs[1]] db in
                try db.execute(
                    sql: "UPDATE variant SET deleted_at = ? WHERE block_id = ?",
                    arguments: ["2026-08-21T00:00:00Z", blockID])
            }
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            #expect(model.index.entries[1].variantID == nil, "the middle slot is a gap")

            let whole = NSRange(location: 0, length: model.index.documentLength)
            #expect(model.planWholeBlockDeletion(range: whole, replacement: "") == nil)
            await deleteSpan(model, storage, whole)

            #expect(model.statusMessage == model.message(for: BlockRangeIndex.Refusal.readOnlySlot),
                    "the refusal names sync, not a boundary problem that isn't there")
            let live = try await db.read { [postID = seed.postID] db in
                try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM container_block
                        WHERE container_id = ? AND deleted_at IS NULL
                        """,
                    arguments: [postID]) ?? -1
            }
            #expect(live == 3, "nothing was deleted — not the gap, and not its neighbours")
        }
    }

    /// **A BLOCK THE STORE HAS ALREADY LOST speaks (ladder MINOR 2) — RED
    /// ON THE PRE-FIX TREE**, where her status line read
    /// `blockNotFound(id: "…")`. The race is real at this door: a second ⌫
    /// during the first compound's flush re-plans now-stale IDs. The
    /// compound's atomic rollback means she meets it with NOTHING deleted,
    /// and the sentence has to carry that or a rolled-back gesture reads as
    /// a half-done one.
    @Test func aVanishedBlockRefusesInWordsAndSaysNothingWasDeleted() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedParagraphPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            await model.structural.deleteWholeBlockRun([seed.blockIDs[0], "ghost-block"])

            let status = try #require(model.statusMessage)
            #expect(!status.contains("blockNotFound"), "never the raw enum")
            #expect(status.contains("Nothing was deleted"))
            #expect(!status.contains("Mac"))
            #expect(try await liveTexts(db, postID: seed.postID)
                == ["Alpha one.", "Beta two.", "Gamma three."],
                    "the compound rolled back whole — which is what the words promise")
        }
    }

    /// **THE STRANDING SENTENCE reaches the phone (ladder NIT 7) — RED ON
    /// THE PRE-FIX TREE**, where the receipt said only "2 blocks deleted."
    /// Deleting a divide's two successors together is the commonest way to
    /// strand the original it preserved, and this door is what makes that
    /// one keystroke. Her named failure mode is believing an ancestor is a
    /// guaranteed backup, so the delete that changes that says so.
    @Test func deletingBothHalvesOfADivideNamesTheStrandedOriginal() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "stranded", profile: .blog)
                let made = try ops.newBlock(in: post.id, text: "Alpha beta gamma.", at: .end)
                // A fan, so the divide takes the duplicate-shape road that
                // PRESERVES the original whole (her Q-M2 ruling).
                _ = try ops.newBlankVariant(made.block.id)
                _ = try ops.divideDuplicating(
                    made.block.id, displayedVariantID: made.variant.id, cut: 6)
                return post.id
            }
            let (model, storage) = makeEditor(session, postID: post)
            await model.loadOnce()
            #expect(model.index.entries.count == 2, "B and C stand where A did")

            await deleteSpan(
                model, storage, NSRange(location: 0, length: model.index.documentLength))

            #expect(model.statusMessage
                == "2 blocks deleted." + MobileStructuralController.strandedOriginalNote(1))
            #expect(try await liveTexts(db, postID: post) == [])
        }
    }

    /// **THE CARET WRITE, pinned at last (ladder NIT 8).** Batch 1b
    /// recorded it as an honest gap — the headless harness has no text view,
    /// so the write was a no-op there. The real surface has one, so both
    /// delete doors are pinned on it now: the ⋯ menu's single-block act
    /// (which landed the caret NOWHERE before this fix — RED ON THE PRE-FIX
    /// TREE) and the selection gesture beside it.
    @Test func bothDeleteDoorsLandTheCaretOnTheSurvivingBlock() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedParagraphPost(session)
            let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
            surface.textView.selectedRange = NSRange(location: 0, length: 0)

            // The ⋯ door: delete the MIDDLE block — the caret lands at the
            // start of the block below it, which is now "Gamma three."
            await model.structural.deleteBlock(blockID: seed.blockIDs[1])
            let afterMenu = try #require(model.rangeOfBlock(seed.blockIDs[2]))
            #expect(surface.textView.selectedRange
                == NSRange(location: afterMenu.location, length: 0))

            // The gesture: delete the LAST block — the caret lands at the
            // END of the block above.
            let gamma = try #require(model.rangeOfBlock(seed.blockIDs[2]))
            await model.structural.deleteWholeBlockRun([seed.blockIDs[2]])
            let alpha = try #require(model.rangeOfBlock(seed.blockIDs[0]))
            #expect(surface.textView.selectedRange
                == NSRange(location: alpha.upperBound, length: 0))
            #expect(gamma.length > 0, "the block really was there before the gesture")
        }
    }

    /// A FANNED block goes with its takes (#66(b) — her ratified
    /// consequence on the Mac, inherited here because the act is the same
    /// unrestricted `deleteBlock` the ⋯ menu already runs).
    @Test func aFannedParagraphGoesTakesAndAll() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedParagraphPost(session)
            try await session.runner.run { [blockID = seed.blockIDs[1]] ops in
                _ = try ops.newBlankVariant(blockID)
            }
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            let beta = model.index.range(ofEntryAt: 1)
            await deleteSpan(
                model, storage, NSRange(location: beta.location, length: beta.length + 1))

            #expect(try await liveTexts(db, postID: seed.postID) == ["Alpha one.", "Gamma three."])
            let liveTakes = try await db.read { [blockID = seed.blockIDs[1]] db in
                try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM variant
                        WHERE block_id = ? AND deleted_at IS NULL
                        """,
                    arguments: [blockID]) ?? -1
            }
            #expect(liveTakes == 0, "the block's takes went with it (the cascade)")
        }
    }

    /// The no-redirect principle holds on this batch's copy: nothing it can
    /// say names the other platform, or a door this phone lacks.
    ///
    /// **ROUND 2 BATCH 4 UPDATED TWO OF ITS CLAUSES, because the doors they
    /// denied now exist.** The "no Trash" clause is replaced by its
    /// positive: PR2 built the Trash, so the stranding sentence NAMES it
    /// (13j J8(a) read forwards — withholding a destination she can now
    /// reach would be the same defect wearing the other coat). The chord
    /// clause stays, and stays for its real reason: the phone HAS an undo
    /// door since M20, but it has no chord culture, so a receipt must never
    /// name ⌥⌘Z. The tray clause is untouched — that face is batch 5's.
    @Test func theReceiptsNameNothingThePhoneDoesNotHave() {
        for line in [MobileStructuralController.blocksDeletedStatus(1),
                     MobileStructuralController.blocksDeletedStatus(3),
                     MobileStructuralController.strandedOriginalNote(1),
                     MobileStructuralController.strandedOriginalNote(2)] {
            #expect(!line.contains("Mac"))
            #expect(!line.lowercased().contains("tray"))
            #expect(!line.lowercased().contains("forever"),
                    "these are tombstones, not purges")
            #expect(!line.contains("\u{2325}\u{2318}Z"),
                    "no chord culture on this phone — the undo door is a button")
        }
        for line in [MobileStructuralController.strandedOriginalNote(1),
                     MobileStructuralController.strandedOriginalNote(2)] {
            #expect(line.contains(RecoveryCopy.trashSection),
                    "the destination is named now that she can open it")
        }
        #expect(MobileStructuralController.blocksDeletedStatus(1)
            == MobileStructuralController.blockDeletedStatus,
                "N = 1 reuses the pinned sentence — the two doors cannot fork")
    }

    /// **THE GESTURE ASKS NOTHING, and that is her ruling** (2026-08-21,
    /// round 2 ladder R13 — *"it's fine to have no confirm"*, superseding
    /// the ladder's MAJOR 1). The ⋯ menu row still confirms; this road is a
    /// keystroke and does not. Pinned so a later session cannot re-add
    /// ceremony here by reflex: the answer to "no way back" is M20's
    /// undo/redo door and M21's tray, not a dialog.
    ///
    /// Driven on the REAL surface, through the delegate `attach` installed
    /// on the real text view — the same call UIKit makes for ⌫ — with a
    /// confirm seam that would RECORD any question the road decided to ask.
    @Test func theKeystrokeDeletesWithoutAskingAnything() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedParagraphPost(session)
            let (model, surface) = await makeSurfaceEditor(session, postID: seed.postID)
            var asked = 0
            model.blockMenu.confirmDestructive = { _, _, _, completion in
                asked += 1
                completion(true)
            }

            let whole = NSRange(location: 0, length: model.index.documentLength)
            surface.textView.selectedRange = whole
            let allowed = surface.textView.delegate?.textView?(
                surface.textView, shouldChangeTextIn: whole, replacementText: "")
            await model.pendingGestureTask?.value

            #expect(allowed == false, "the storage never half-applies a cross-block delete")
            #expect(asked == 0, "no ceremony on the keystroke — her ruling")
            #expect(try await liveTexts(db, postID: seed.postID) == [])
            #expect(model.statusMessage == "3 blocks deleted.")
        }
    }
}
