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

    @Test func backspaceBetweenTwoBLOCKSWITHTEXTStillREFUSES() async throws {
        // THE decisive carve-cannot-widen pin, and it corrects an
        // assumption worth recording: a BARE seam backspace between two
        // TEXTED blocks has always refused — the ratified "a cross-seam
        // delete just works" covers a SELECTION that spans text, and both
        // cross-block plans collect by intersection, which a lone separator
        // has none of. So the range shape A7 carves is the one shape that
        // did NOTHING before, and the carve changes behaviour for exactly
        // the empty-block case and nothing else. Joining two texted blocks
        // remains the explicit merge gesture (⌘⇧M).
        try await withEditor(seedBlocks: ["alpha", "beta"]) { harness in
            harness.replace(NSRange(location: 5, length: 1), with: "")
            await harness.flush()
            let unchanged = try harness.storeSlots().compactMap(\.text)
            #expect(unchanged == ["alpha", "beta"],
                    "two texted blocks are untouched — the carve never widened to them")
            #expect(harness.documentText == "alpha\nbeta")
            #expect(harness.session.undoStack.depth == 0, "nothing structural happened")
            #expect(harness.model.statusMessage?.isEmpty == false, "and the refusal SPEAKS")
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
                try Queries.trayBlocks(db, postID: harness.postID)
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
            for _ in 0..<2000 where stack.redoDepth != 0 {
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(1))
            }
            #expect(stack.redoDepth == 0)
            #expect(stack.depth == 1)
            let afterRedo = try harness.storeSlots().compactMap(\.text)
            #expect(afterRedo == ["beta"])

            // The outcome REPORTS — mode-independently, through the one
            // status surface (N4's letter, applied to the new door).
            #expect(harness.session.status.current?.text.contains("Redid") == true)
        }
    }
}
