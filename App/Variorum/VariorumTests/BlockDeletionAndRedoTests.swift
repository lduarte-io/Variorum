//
//  BlockDeletionAndRedoTests.swift
//  VariorumTests
//
//  Phase 13c, batch 1B — her three intake items, pinned:
//
//  A7  "I cant use backspace to delete empty blocks with no takes right now
//       which is too annoying - especially when there's an empty block right
//       at the start of the post."
//  A8  "I don't seem to have the ability to delete / archive empty blocks?"
//  A10 "i desperately need a 'redo' command to be able to undo my structural
//       undos for when that was an accident."
//
//  The load-bearing half of this suite is the CARVE-CANNOT-WIDEN section:
//  A7 is a deliberate, narrow exception to the ratified cross-block
//  destructive-edit refusal, legitimate ONLY because an empty block has no
//  text to lose. Every neighbouring case must still refuse, and those pins
//  are what keep the exception from growing into "backspace deletes blocks".
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@Suite("Empty-block deletion, the delete door, and structural redo (13c 1B)")
@MainActor
struct BlockDeletionAndRedoTests {
    // MARK: - A7, the pure carve (BlockRangeIndex)

    private func index(_ lengths: [Int], tail: Int? = nil, editable: Bool = true) -> BlockRangeIndex {
        BlockRangeIndex(
            entries: lengths.enumerated().map { i, length in
                BlockRangeIndex.Entry(
                    blockID: "b\(i)", variantID: "v\(i)", length: length, editable: editable)
            },
            tailLength: tail)
    }

    @Test func theSeparatorBeforeAnEmptyBlockNamesThatBlock() {
        // ["", "hello"] — surface "\nhello"; the separator is at 0.
        // This is HER case: an empty block at the very start of the post,
        // and the only gesture that can reach it (backspace from the start
        // of the block below, or forward-delete from inside the empty one).
        #expect(index([0, 5]).emptyBlockDeletion(
            replacing: NSRange(location: 0, length: 1), isDeletion: true) == 0)
    }

    @Test func theSeparatorAfterAnEmptyBlockNamesThatBlock() {
        // ["hello", ""] — surface "hello\n"; the separator is at 5.
        #expect(index([5, 0]).emptyBlockDeletion(
            replacing: NSRange(location: 5, length: 1), isDeletion: true) == 1)
    }

    @Test func aMiddleEmptyBlockIsReachedFromEitherSide() {
        // ["a", "", "b"] — separators at 1 and 2, both naming entry 1.
        let idx = index([1, 0, 1])
        #expect(idx.emptyBlockDeletion(
            replacing: NSRange(location: 1, length: 1), isDeletion: true) == 1)
        #expect(idx.emptyBlockDeletion(
            replacing: NSRange(location: 2, length: 1), isDeletion: true) == 1)
    }

    @Test func twoEmptyNeighboursResolveToTheOneBEFORETheSeparator() {
        // Backspace means "remove what is behind me"; preferring the block
        // AFTER would delete the very block the caret sits in and would
        // never converge under repeated presses.
        #expect(index([1, 0, 0, 1]).emptyBlockDeletion(
            replacing: NSRange(location: 2, length: 1), isDeletion: true) == 1)
    }

    // MARK: - A7, THE CARVE CANNOT WIDEN

    @Test func aSeamBetweenTWOBLOCKSWITHTEXTIsNeverTheCarve() {
        #expect(index([5, 5]).emptyBlockDeletion(
            replacing: NSRange(location: 5, length: 1), isDeletion: true) == nil,
            "two blocks with text keep the ratified cross-block behaviour")
    }

    @Test func aRangeThatIsNotExactlyOneSeparatorIsNeverTheCarve() {
        let idx = index([0, 5])
        // Two characters: the separator plus a byte of the block below.
        #expect(idx.emptyBlockDeletion(
            replacing: NSRange(location: 0, length: 2), isDeletion: true) == nil)
        // A caret-only range (length 0) proposes no deletion at all.
        #expect(idx.emptyBlockDeletion(
            replacing: NSRange(location: 0, length: 0), isDeletion: true) == nil)
        // A one-character range INSIDE a block is that block's own edit.
        #expect(idx.emptyBlockDeletion(
            replacing: NSRange(location: 2, length: 1), isDeletion: true) == nil)
    }

    @Test func typingOverASeamIsNeverTheCarve() {
        #expect(index([0, 5]).emptyBlockDeletion(
            replacing: NSRange(location: 0, length: 1), isDeletion: false) == nil,
            "a replacement is a different gesture — only a DELETION carves")
    }

    @Test func theTailSeparatorIsNeverTheCarve() {
        // ["", ""] with an open tail: the separator before the tail belongs
        // to `closeTail`, and the carve must not steal it.
        let idx = index([0, 0], tail: 0)
        #expect(idx.tailSeparatorOffset == 1)
        #expect(idx.emptyBlockDeletion(
            replacing: NSRange(location: 1, length: 1), isDeletion: true) == nil)
    }

    @Test func aSingleBlockPostHasNoSeparatorToCarve() {
        #expect(index([0]).emptyBlockDeletion(
            replacing: NSRange(location: 0, length: 1), isDeletion: true) == nil)
        #expect(index([]).emptyBlockDeletion(
            replacing: NSRange(location: 0, length: 1), isDeletion: true) == nil)
    }

    @Test func aFANNEDEmptyBlockKeepsTheRefusal() async throws {
        // Takes are TEXT. A seam-key must never take one away unseen, so
        // the fan guard sits with the caller, where arity is known.
        try await withEditor(seedBlocks: ["", "hello"]) { harness in
            let slots = try harness.storeSlots()
            _ = try harness.session.operations.branchVariant(
                slots[0].blockID, from: try #require(slots[0].variantID))
            try harness.reload()

            #expect(harness.model.planEmptyBlockDeletion(
                range: NSRange(location: 0, length: 1), replacement: "") == nil,
                "an empty block that carries takes is not the carve")
            // …and the pure index still names it — proving the guard is the
            // caller's, exactly where the fan is visible.
            #expect(harness.model.index.emptyBlockDeletion(
                replacing: NSRange(location: 0, length: 1), isDeletion: true) == 0)
        }
    }

    @Test func aLOCKEDEmptyBlockKeepsTheRefusal() async throws {
        try await withEditor(seedBlocks: ["", "hello"]) { harness in
            let slots = try harness.storeSlots()
            try harness.session.operations.lockVariant(try #require(slots[0].variantID))
            try harness.reload()
            #expect(harness.model.planEmptyBlockDeletion(
                range: NSRange(location: 0, length: 1), replacement: "") == nil,
                "a locked take's guard means something here too")
        }
    }

    /// **The fourth guard** (13c Stage 1 ladder round 1, R1-1). An ARCHIVED
    /// take is out of the fan but is still TEXT, and `deleteBlock` cascades
    /// it away with the block — so a block that renders empty with
    /// `activeVariantCount == 1` could still be carrying prose, and the
    /// carve's whole authorization ("there is no text to lose") failed
    /// there. Reachable in three ordinary gestures, all legal: branch a
    /// take, archive the one with the prose (the other is still active, so
    /// I10 is satisfied), blank the survivor (R90's power gesture).
    ///
    /// Recoverable via ⌥⌘Z and the tray, so this was never data loss — but
    /// the NARROWNESS is what the carve was granted on, and none of the
    /// nine original cannot-widen pins reached this state.
    @Test func anARCHIVEDTakeCarryingProseKeepsTheRefusal() async throws {
        try await withEditor(seedBlocks: ["prose", "hello"]) { harness in
            let slots = try harness.storeSlots()
            let blockID = slots[0].blockID
            let original = try #require(slots[0].variantID)
            let branch = try harness.session.operations.branchVariant(blockID, from: original)
            // Legal: the branch is active, so archiving the original is not
            // the last-active refusal.
            try harness.session.operations.archiveVariant(original)
            // …and blanking the survivor is an ordinary edit.
            try harness.session.operations.autosave(branch.id, text: "", charDelta: -5)
            try harness.reload()

            let after = try harness.storeSlots()
            #expect(after[0].text == "", "the block renders EMPTY")
            #expect(after[0].activeVariantCount == 1,
                    "…and the fan count cannot see the archived take — the trap")
            #expect(harness.model.index.entries[0].length == 0)
            // The pure index still names it: the guard is the caller's,
            // where the store is known (the fan/lock pins' shape).
            #expect(harness.model.index.emptyBlockDeletion(
                replacing: NSRange(location: 0, length: 1), isDeletion: true) == 0)

            #expect(harness.model.planEmptyBlockDeletion(
                range: NSRange(location: 0, length: 1), replacement: "") == nil,
                "an archived take carries prose — deleting the block would cascade it away")
        }
    }

    /// **The fifth guard** (13c Stage 1 ladder round 2, R2-1) — R1-1's
    /// class, one guard short, convicted by the same sentence: the carve
    /// was authorized ONLY on *"there is no text to lose"*, and a COMMENT is
    /// authored text. `addBlockComment` has no empty-block rule, and a note
    /// on an empty block is an ordinary thing to write (*"I'll rewrite this
    /// — see the note"*); `deleteBlock` then fires v1_8's cascade over it.
    ///
    /// Worse than the archived-take case in one specific way, and that is
    /// why the guard is owed rather than merely tidy: `Queries
    /// .deletedBlockComments` is keyed by BLOCK, so once the block is only
    /// in the tray the notes have no recovery surface at all — AppSpec §7's
    /// ratified *"deleted comments are visible and resurrectable… never
    /// skimpy"* silently stops holding for this path.
    @Test func aBLOCKCOMMENTKeepsTheRefusal() async throws {
        try await withEditor(seedBlocks: ["", "hello"]) { harness in
            let slots = try harness.storeSlots()
            let blockID = slots[0].blockID
            _ = try harness.session.operations.addBlockComment(
                to: blockID, text: "I'll rewrite this — see the note")
            try harness.reload()

            let after = try harness.storeSlots()
            #expect(after[0].text == "", "the block renders EMPTY")
            #expect(after[0].activeVariantCount == 1, "no fan")
            #expect(after[0].liveVariantCount == 1, "…and no archived take — R1-1's guard is satisfied")
            #expect(after[0].commentCount == 1, "the note is the only unshown text")
            // The pure index still names it: the guard is the caller's,
            // where the store is known (the fan/lock/archive pins' shape).
            #expect(harness.model.index.emptyBlockDeletion(
                replacing: NSRange(location: 0, length: 1), isDeletion: true) == 0)

            #expect(harness.model.planEmptyBlockDeletion(
                range: NSRange(location: 0, length: 1), replacement: "") == nil,
                "a commented block carries prose — deleting it would cascade the note away")
        }
    }

    /// …and end to end through the REAL keystroke path: her exact gesture
    /// on her exact case (an empty FIRST block), with a note on it. The
    /// block must survive, and the store must still hold the comment.
    @Test func backspaceLeavesACommentedEmptyBlockAlone() async throws {
        try await withEditor(seedBlocks: ["", "hello"]) { harness in
            let blockID = try harness.storeSlots()[0].blockID
            _ = try harness.session.operations.addBlockComment(to: blockID, text: "see the note")
            try harness.reload()

            harness.replace(NSRange(location: 0, length: 1), with: "")
            await harness.flush()

            let texts = try harness.storeSlots().compactMap(\.text)
            #expect(texts == ["", "hello"], "the commented empty block SURVIVES")
            #expect(harness.documentText == "\nhello")
            #expect(harness.model.index.entries.count == 2)
            let notes = try await harness.database.read { db in
                try Queries.blockComments(db, blockID: blockID)
            }
            #expect(notes.count == 1, "…and its working note is still there")
            #expect(harness.session.undoStack.depth == 0, "nothing structural happened")
        }
    }

    /// **THE guard the guard list could not be** (13c Stage 1 ladder round
    /// 3, R3-1 — the class's third and last instance, and the one that ended
    /// the pattern rather than extending it).
    ///
    /// R1-1 and R2-1 each added a condition to `planEmptyBlockDeletion`.
    /// Both read `model.slots`, which the projection engine **deliberately
    /// holds stale**: `EditorProjectionPolicy.decide` returns
    /// `.deferUntilClean` whenever the buffer is dirty (or a mint or
    /// structural flight is up), and autosave's debounce re-arms on every
    /// keystroke — so for a whole typing burst that array is frozen at
    /// whatever the store said before she started. A comment landing in that
    /// window is invisible to every guard, and the run path re-verified only
    /// the TEXT, which really was empty. The block went, and with it a note
    /// that `Queries.deletedBlockComments` — keyed by block — could no
    /// longer surface at all.
    ///
    /// **The tell, and it is why the earlier pins were green:** every other
    /// carve pin calls `harness.reload()` between the ops write and the
    /// plan, hand-refreshing the projection production does not. They
    /// rehearsed a state production never reaches. **This one deliberately
    /// does not reload** — it drives the frozen projection on purpose.
    ///
    /// The fix is not a sixth guard: the authorization now lives in
    /// `Operations.deleteBlock(_:requiring:)`, re-read inside the
    /// tombstone's own transaction, where it cannot be a snapshot.
    @Test func aCommentArrivingWhileSheIsTypingStillStopsTheCarve() async throws {
        try await withEditor(seedBlocks: ["", "hello"]) { harness in
            let blockID = try harness.storeSlots()[0].blockID

            // She is typing: autosave holds the edit for its debounce, so
            // the editor is BUSY and every arriving projection defers.
            harness.type("X", at: 3)
            #expect(harness.model.autosave.isDirty, "the burst — this pin's precondition")

            // Meanwhile a comment lands on the EMPTY block. From sync, or
            // from her own comments sheet, which never touches this buffer.
            _ = try harness.session.operations.addBlockComment(
                to: blockID, text: "I'll rewrite this — see the note")

            // The observation delivers, and the engine defers it. This is
            // the frozen array the guards were reading.
            let fresh = try harness.storeSlots()
            #expect(fresh[0].commentCount == 1, "the STORE knows about the note")
            harness.model.applyProjection(fresh)
            #expect(harness.model.slots[0].commentCount == 0,
                    "…and the editor's projection deliberately does not — the freeze, reproduced")
            #expect(harness.model.planEmptyBlockDeletion(
                range: NSRange(location: 0, length: 1), replacement: "") != nil,
                "so the plan-time guards PASS on stale data — which is the finding")

            // Her keystroke, through the real path.
            harness.replace(NSRange(location: 0, length: 1), with: "")
            await harness.flush()

            let after = try harness.storeSlots()
            #expect(after.count == 2, "the empty block SURVIVES — the plan was stale, the operation was not")
            #expect(after[0].blockID == blockID)
            let notes = try await harness.database.read { db in
                try Queries.blockComments(db, blockID: blockID)
            }
            #expect(notes.count == 1, "…and her note is still there")
            #expect(harness.session.undoStack.depth == 0, "nothing structural happened")
            #expect(harness.model.statusMessage?.isEmpty == false, "and the refusal SPEAKS (P-2)")
        }
    }

    /// PROVISIONAL, and pinned as the shipped reading (13c R2-1, QUESTIONS
    /// #40): a NAMED or CALLOUT empty block still carves. Both are columns
    /// ON the block row — the tombstone keeps them, undo and `restoreBlock`
    /// bring them back with the block, and the tray lists the block BY its
    /// name — so neither becomes unrecoverable, which is the line the two
    /// counted kinds cross. Guarding on every datum attached to a block
    /// (tags cascade too) would narrow the carve out of existence.
    @Test func aNAMEDOrCALLOUTEmptyBlockStillCarves_PROVISIONAL() async throws {
        try await withEditor(seedBlocks: ["", "hello"]) { harness in
            let blockID = try harness.storeSlots()[0].blockID
            try harness.session.operations.setBlockName(blockID, name: "intro")
            try harness.session.operations.setBlockPresentation(
                blockID, BlockPresentation(color: "sand", emoji: "💡"))
            try harness.reload()

            #expect(harness.model.planEmptyBlockDeletion(
                range: NSRange(location: 0, length: 1), replacement: "") != nil,
                "the shipped reading: a name/frame rides the block row and revives with it")
        }
    }

    @Test func theCarveAndTheTwoCrossBlockPlansAreMUTUALLYEXCLUSIVE() async throws {
        // The carve runs FIRST in `shouldChangeText`; this is why that is
        // safe. Both cross-block plans collect their targets by INTERSECTION
        // (`length > 0`), and a lone separator intersects nothing — so they
        // can never see the carve's range, and every range they DO see has
        // no carve. Surface: "\nalpha\nbeta".
        try await withEditor(seedBlocks: ["", "alpha", "beta"]) { harness in
            #expect(harness.documentText == "\nalpha\nbeta")
            let separator = NSRange(location: 0, length: 1)
            #expect(harness.model.planEmptyBlockDeletion(
                range: separator, replacement: "") != nil)
            #expect(harness.model.planCrossBlockEdit(range: separator, replacement: "") == nil)
            #expect(harness.model.planVisibleTakeEdit(range: separator, replacement: "") == nil)

            // A genuine cross-block span ("pha\nbe"): the plans fire, the
            // carve doesn't.
            let span = NSRange(location: 3, length: 6)
            #expect(harness.model.planEmptyBlockDeletion(range: span, replacement: "") == nil)
            #expect(harness.model.planCrossBlockEdit(range: span, replacement: "") != nil)
        }
    }

    // MARK: - A7, end to end through the real keystroke path

    @Test func backspaceAtTheStartOfThePostDeletesTheEmptyFirstBlock() async throws {
        // Her exact case, driven through the REAL NSTextInputClient path:
        // shouldChangeTextIn → the carve → the structural door.
        try await withEditor(seedBlocks: ["", "hello"]) { harness in
            #expect(harness.documentText == "\nhello")
            let emptyID = try harness.storeSlots()[0].blockID

            // Backspace with the caret at the start of "hello".
            harness.replace(NSRange(location: 0, length: 1), with: "")
            await harness.flush()

            let texts = try harness.storeSlots().compactMap(\.text)
            #expect(texts == ["hello"], "the empty block is gone; the text block is untouched")
            #expect(harness.documentText == "hello")
            #expect(harness.model.index.entries.count == 1)

            // ONE undo entry, and it is the block deletion — the buffer
            // compare-and-set that guards the store registers nothing.
            let stack = harness.session.undoStack
            #expect(stack.depth == 1)
            #expect(stack.topLabel == "Delete Block")

            try await harness.session.runner.run { ops in _ = try stack.undo(with: ops) }
            try harness.reload()
            let restoredID = try harness.storeSlots().map(\.blockID).first
            #expect(restoredID == emptyID)
            #expect(harness.documentText == "\nhello")

            // …and A10 puts it back.
            try await harness.session.runner.run { ops in _ = try stack.redo(with: ops) }
            try harness.reload()
            let afterRedo = try harness.storeSlots().compactMap(\.text)
            #expect(afterRedo == ["hello"])
        }
    }

    @Test func forwardDeleteFromInsideAnEmptyBlockDeletesItToo() async throws {
        try await withEditor(seedBlocks: ["alpha", "", "beta"]) { harness in
            #expect(harness.documentText == "alpha\n\nbeta")
            // Forward-delete from the empty block (offset 6) removes the
            // separator at 6 — the neighbour BEFORE it has text, so the
            // empty block after it is the one named.
            harness.replace(NSRange(location: 6, length: 1), with: "")
            await harness.flush()

            let after = try harness.storeSlots().compactMap(\.text)
            #expect(after == ["alpha", "beta"])
            #expect(harness.documentText == "alpha\nbeta")
        }
    }

    /// THE decisive carve-cannot-widen pin — and its *behavioural* half was
    /// superseded by her ruling, so the pin keeps the half that is this
    /// suite's job and hands the other half over by name.
    ///
    /// **What it recorded (13c 1B, and still true):** a bare seam backspace
    /// between two TEXTED blocks intersects neither neighbour, so both
    /// cross-block plans return nil for it and A7's carve never names it —
    /// the range shape A7 carves is the one shape that did NOTHING before,
    /// and the carve changed behaviour for the empty-block case only.
    ///
    /// **What changed (13d batch 2, QUESTIONS #34 option (ii)):** that
    /// keystroke is no longer a refusal — it MERGES when neither block has
    /// takes. A ruled flip, not a bug fix. The behaviour now lives in
    /// `SeamMergeTests`; what stays here is the carve's own narrowness: it
    /// still does not name a texted seam, and the block that owns that seam
    /// is a different act entirely.
    @Test func theCarveStillNeverNamesASeamBetweenTwoBLOCKSWITHTEXT() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta"]) { harness in
            let separator = NSRange(location: 5, length: 1)
            #expect(harness.model.index.emptyBlockDeletion(
                replacing: separator, isDeletion: true) == nil,
                "the carve never widened to texted blocks")
            #expect(harness.model.planEmptyBlockDeletion(
                range: separator, replacement: "") == nil)
            // …and the act that DOES own that seam is the seam merge (#34).
            #expect(harness.model.planSeamMerge(range: separator, replacement: "") != nil)
        }
    }

    // MARK: - A8, the delete door

    @Test func theDeleteBlockCapabilityIsDeclaredAndNativeInBothEditors() {
        let capability = CapabilityRegistry.capability(.deleteBlock)
        #expect(capability.verb == "Delete Block")
        #expect(capability.scope == .block)
        #expect(capability.takesAccess == .native)
        #expect(!capability.unavailableNote.isEmpty)
        #expect(CapabilityRegistry.availability(
            .deleteBlock, in: CapabilityContext(mode: .takes)) == .act)
        #expect(CapabilityRegistry.availability(
            .deleteBlock,
            in: CapabilityContext(mode: .write, writeEditorAttached: true)) == .act)
        #expect(CapabilityRegistry.availability(
            .deleteBlock, in: CapabilityContext(mode: .lenses)) == .act)
        #expect(!CapabilityRegistry.isEnabled(
            .deleteBlock, in: CapabilityContext(mode: nil)),
            "honestly grey with no post open")
    }

    @Test func theWriteDoorDeletesTheCaretBlock() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta", "gamma"]) { harness in
            harness.textView.setSelectedRange(NSRange(location: 7, length: 0))  // inside "beta"
            harness.model.updateCaretContext()
            await harness.model.deleteCaretBlock()
            await harness.flush()

            let remaining = try harness.storeSlots().compactMap(\.text)
            #expect(remaining == ["alpha", "gamma"])
            #expect(harness.documentText == "alpha\ngamma")
            #expect(harness.session.undoStack.topLabel == "Delete Block")
        }
    }

    @Test func theWriteDoorSpeaksInsteadOfGoingSilentWithNoCaretBlock() async throws {
        // P-2: a rendered door acts or speaks. An empty post has no block
        // to delete, and saying so beats a dead key.
        try await withEditor { harness in
            await harness.model.deleteCaretBlock()
            #expect(harness.model.statusMessage?.isEmpty == false)
            #expect(harness.session.undoStack.depth == 0)
        }
    }

    @Test func deletingThePostsLastBlockIsAllowedAndLandsInTheFreshPostState() async throws {
        // Decided against the spec and recorded: NO invariant makes a
        // post's block count load-bearing (I10 governs variants under a
        // live block), and the blockless post is an explicitly-modelled
        // state — it is what a fresh post is. Refusing would be invented
        // product behaviour; the tray, ⌥⌘Z and ⇧⌥⌘Z are the recovery.
        try await withEditor(seedBlocks: ["only"]) { harness in
            harness.textView.setSelectedRange(NSRange(location: 2, length: 0))
            harness.model.updateCaretContext()
            await harness.model.deleteCaretBlock()
            await harness.flush()

            let emptied = try harness.storeSlots()
            #expect(emptied.isEmpty)
            #expect(harness.model.index.entries.isEmpty)
            #expect(harness.documentText == "")
            // The tray reaches it, and undo puts it back.
            let tray = try await harness.database.read { db in
                try Queries.trayBlocks(db, postID: harness.postID, now: harnessNow)
            }
            #expect(tray.count == 1)

            // …and the editor still works: typing rebuilds from the
            // fresh-post state.
            harness.type("new text", at: 0)
            await harness.flush()
            #expect(harness.documentText == "new text")
        }
    }

    // MARK: - A10, the app half

    @Test func theRedoMenuTitleMirrorsTheUndoOne() {
        #expect(EditorCommands.redoMenuTitle(for: "Divide") == "Redo Divide")
        #expect(EditorCommands.redoMenuTitle(for: nil) == "Redo Structural Change")
        #expect(EditorCommands.undoMenuTitle(for: "Divide") == "Undo Divide")
    }

    @Test func theRedoCapabilityIsDeclaredAndGatedOnTheRedoStack() {
        let capability = CapabilityRegistry.capability(.structuralRedo)
        #expect(capability.verb == "Redo Structural Change")
        #expect(capability.scope == .app)
        #expect(capability.shortcutLabel == "⇧⌥⌘Z")
        #expect(EditorCommands.keyEquivalent(for: .structuralRedo) != nil,
                "the declared shortcut has exactly one key wiring")
        #expect(!CapabilityRegistry.isEnabled(
            .structuralRedo, in: CapabilityContext(mode: .write, writeEditorAttached: true)),
            "nothing to redo ⇒ honestly grey")
        #expect(CapabilityRegistry.isEnabled(
            .structuralRedo, in: CapabilityContext(redoAvailable: true)),
            "and it is available on EVERY surface — structural undo/redo is app scope")
    }

    @Test func theUndoMirrorProjectsBothEndsOfTheStack() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta"]) { harness in
            let stack = harness.session.undoStack
            let mirror = harness.session.undoMenuState

            harness.textView.setSelectedRange(NSRange(location: 0, length: 0))
            harness.model.updateCaretContext()
            await harness.model.deleteCaretBlock()
            await harness.flush()
            mirror.refresh(from: stack)
            #expect(mirror.topLabel == "Delete Block")
            #expect(mirror.topRedoLabel == nil)

            try await harness.session.runner.run { ops in _ = try stack.undo(with: ops) }
            mirror.refresh(from: stack)
            #expect(mirror.topLabel == nil)
            #expect(mirror.topRedoLabel == "Delete Block")

            try await harness.session.runner.run { ops in _ = try stack.redo(with: ops) }
            mirror.refresh(from: stack)
            #expect(mirror.topLabel == "Delete Block")
            #expect(mirror.topRedoLabel == nil)
        }
    }

    /// **13g batch 5 — the kickoff sweep's flaky-pin fix. Poll the LAST
    /// signal in the chain, never an earlier one.**
    ///
    /// This pin failed once in a full suite run (2026-07-30, QoL batch 2:
    /// "Redid" never reached the status text) and was clean on every run
    /// since. The traced mechanism is the PIN's, not the door's:
    /// `ShellActions.structuralRedo` runs the re-apply inside
    /// `session.runner.run` — an actor hop off the main thread — and
    /// `UndoStack.redo` moves BOTH stacks under its lock and returns
    /// BEFORE the door's `Task { @MainActor }` continuation can resume and
    /// call `status.speak`. So `redoDepth == 0` becomes true strictly
    /// earlier than the status this test asserts, and a poll that exits on
    /// the stack can land inside that window. `theRedoReportArrivesAfterTheStackHasAlreadyMoved`
    /// below holds the window open on purpose and proves it.
    @Test func theShellRedoActionRunsThroughTheRunnerAndReports() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta"]) { harness in
            let actions = ShellActions(session: harness.session, shell: ShellRouter())
            let stack = harness.session.undoStack

            harness.textView.setSelectedRange(NSRange(location: 0, length: 0))
            harness.model.updateCaretContext()
            await harness.model.deleteCaretBlock()
            await harness.flush()
            try await harness.session.runner.run { ops in _ = try stack.undo(with: ops) }
            #expect(stack.redoDepth == 1)

            actions.structuralRedo()
            await settleUntilRedoIsReported(harness)

            #expect(stack.redoDepth == 0)
            #expect(stack.depth == 1)
            let afterRedo = try harness.storeSlots().compactMap(\.text)
            #expect(afterRedo == ["beta"])

            // The outcome REPORTS — mode-independently, through the one
            // status surface (N4's letter, applied to the new door).
            #expect(harness.session.status.current?.text.contains("Redid") == true)
        }
    }

    /// **The mechanism, held open so it is deterministic** (13g batch 5).
    ///
    /// `UndoStack.notifyChange()` fires on the MUTATING thread, inside
    /// `redo(with:)`, *after* both stacks have moved and *before* the call
    /// returns — so blocking it blocks the runner, and therefore blocks the
    /// door's main-actor continuation, while `redoDepth` already reads 0.
    /// That is exactly the flake's window, at 150 ms instead of a few
    /// microseconds. Under the fixed polling this pin is green; under the
    /// old polling (exit as soon as `redoDepth == 0`) it fails on the
    /// status expectation every single run.
    ///
    /// DISCRIMINATING REVERT: replace `settleUntilRedoIsReported` with
    /// `for _ in 0..<2000 where stack.redoDepth != 0 { … }` ⇒ RED here,
    /// green everywhere else.
    @Test func theRedoReportArrivesAfterTheStackHasAlreadyMoved() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta"]) { harness in
            let actions = ShellActions(session: harness.session, shell: ShellRouter())
            let stack = harness.session.undoStack

            harness.textView.setSelectedRange(NSRange(location: 0, length: 0))
            harness.model.updateCaretContext()
            await harness.model.deleteCaretBlock()
            await harness.flush()
            try await harness.session.runner.run { ops in _ = try stack.undo(with: ops) }
            #expect(stack.redoDepth == 1)

            // Widen the real window; installed only for this one act.
            stack.setChangeObserver { Thread.sleep(forTimeInterval: 0.15) }
            defer { stack.setChangeObserver(nil) }

            actions.structuralRedo()
            await settleUntilRedoIsReported(harness)

            #expect(stack.redoDepth == 0, "the stacks moved")
            #expect(stack.depth == 1)
            #expect(harness.session.status.current?.text.contains("Redid") == true,
                    "and the report still arrives, however late the door's continuation is")
        }
    }

    /// Bounded async poll on the ASSERTED signal (the standing async-poll
    /// rule — never a sync RunLoop pump). 4 s of headroom, because the pin
    /// above deliberately delays the door by 150 ms.
    private func settleUntilRedoIsReported(_ harness: EditorHarness) async {
        for _ in 0..<4000
        where harness.session.status.current?.text.contains("Redid") != true {
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(1))
        }
    }
}
