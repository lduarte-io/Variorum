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
//  RED-ON-OLD: every behavioural pin below fails on the pre-batch tree,
//  where the gate's `.crossesBlockBoundary` arm refuses unconditionally —
//  the store keeps all its blocks and `statusMessage` carries the
//  "spans more than one block" line. Verified by behavioural revert; the
//  record is in the batch report.
//
//  THE HONEST LIMITATION, pinned as such rather than papered over: a span
//  that covers a block only PARTIALLY is not a whole-block run and still
//  refuses — identically on both platforms. Whether a partial multi-block
//  span should merge-then-edit is a standing product question the author
//  holds; `aPartialSpanStillRefusesExactlyAsBefore` is its characterization.
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

    /// **THE COST, measured rather than argued (P1/P-8).** The plan walks
    /// the entry TILING — block count, never character count — and it does
    /// so at GESTURE cadence, not keystroke cadence, because the one
    /// keystroke-cadence caller of the arm that reaches it (a backspace at
    /// a seam) is a ONE-CHARACTER range, which the brain's first guard
    /// answers before any allocation. Both halves are pinned here: the
    /// seam range costs nothing at 20,000 entries, and a real gesture over
    /// the same index stays far under a generous ceiling — generous on
    /// purpose, so the pin catches a quadratic regression (which at this
    /// size would take seconds) without being a stopwatch.
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
        print("PERF[plan] wholeBlockDeletion @20k blocks — seam×1000 \(seamCost) · gesture \(gestureCost)")
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

    /// **THE HONEST LIMITATION, characterized.** A span that opens
    /// MID-paragraph and runs on is not a whole-block run: it keeps today's
    /// behaviour exactly — the cross-block refusal, nothing deleted. This
    /// pin passes on BOTH trees by design; it exists so the boundary is
    /// recorded as behaviour rather than discovered as a surprise.
    @Test func aPartialSpanStillRefusesExactlyAsBefore() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedParagraphPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // "one.\nBeta " — opens inside block 0, closes inside block 1.
            let span = NSRange(location: 6, length: 10)
            #expect(model.planWholeBlockDeletion(range: span, replacement: "") == nil)
            await deleteSpan(model, storage, span)

            #expect(try await liveTexts(db, postID: seed.postID)
                == ["Alpha one.", "Beta two.", "Gamma three."],
                    "nothing deleted — the partial case is untouched by this batch")
            #expect(model.statusMessage
                == model.message(for: BlockRangeIndex.Refusal.crossesBlockBoundary))
        }
    }

    /// Typing OVER a whole-block span is a replacement, not a delete, and
    /// keeps its own road — the typed characters are never dropped on the
    /// floor by a delete compound.
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

    /// The no-redirect principle holds on this batch's new copy: nothing it
    /// can say names the other platform, or a door this phone lacks.
    @Test func theReceiptsNameNothingThePhoneDoesNotHave() {
        for line in [MobileStructuralController.blocksDeletedStatus(1),
                     MobileStructuralController.blocksDeletedStatus(3)] {
            #expect(!line.contains("Mac"))
            #expect(!line.lowercased().contains("tray"))
            #expect(!line.contains("\u{2325}\u{2318}Z"), "there is no undo door on this phone yet")
        }
        #expect(MobileStructuralController.blocksDeletedStatus(1)
            == MobileStructuralController.blockDeletedStatus,
                "N = 1 reuses the pinned sentence — the two doors cannot fork")
    }
}
