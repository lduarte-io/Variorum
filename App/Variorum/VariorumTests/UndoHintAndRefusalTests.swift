//
//  UndoHintAndRefusalTests.swift
//  VariorumTests
//
//  Phase 13j, batch 1 — the mini-round's other two items:
//
//  • J7, her live ruling: *"if a user is spamming command z, i think it
//    should prompt them to do a structural undo if it's not doing a regular
//    undo."* The hint fires exactly on (text stack empty ∧ structural stack
//    holds entries), and the chord is NEVER consumed.
//  • J8, copy truth: the delete receipt stops promising a tray that has no
//    face, and the `.crossesBlockBoundary` refusal DIAGNOSES instead of
//    listing three maybes.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@Suite("Undo hint + refusal truth (13j J7/J8)")
@MainActor
struct UndoHintAndRefusalTests {

    // MARK: - J7, the rule (pure)

    /// **The fire/no-fire matrix, exactly as her ruling states it.**
    @Test func theHintFiresOnlyWhenTheTextStackIsEmptyAndTheStructuralOneIsNot() {
        // Fires: nothing in the text, something structural.
        #expect(EditorUndoHint.message(
            for: .undo, textStackHasEntries: false,
            structuralUndoLabel: "Delete Blocks", structuralRedoLabel: nil) != nil)
        // Quiet: the text stack can still undo — ⌘Z is doing its job.
        #expect(EditorUndoHint.message(
            for: .undo, textStackHasEntries: true,
            structuralUndoLabel: "Delete Blocks", structuralRedoLabel: nil) == nil)
        // Quiet: nothing anywhere — a fresh note must not lecture.
        #expect(EditorUndoHint.message(
            for: .undo, textStackHasEntries: false,
            structuralUndoLabel: nil, structuralRedoLabel: nil) == nil)
        // The redo mirror, same three shapes.
        #expect(EditorUndoHint.message(
            for: .redo, textStackHasEntries: false,
            structuralUndoLabel: nil, structuralRedoLabel: "Delete Blocks") != nil)
        #expect(EditorUndoHint.message(
            for: .redo, textStackHasEntries: true,
            structuralUndoLabel: nil, structuralRedoLabel: "Delete Blocks") == nil)
        #expect(EditorUndoHint.message(
            for: .redo, textStackHasEntries: false,
            structuralUndoLabel: "Delete Blocks", structuralRedoLabel: nil) == nil,
            "a structural UNDO entry is not a reason to talk about redo")
    }

    /// The line names the keys her ruling named, and says nothing about ⌘Z
    /// having done anything — it didn't.
    @Test func theHintNamesTheStructuralKeys() throws {
        let undo = try #require(EditorUndoHint.message(
            for: .undo, textStackHasEntries: false,
            structuralUndoLabel: "Divide", structuralRedoLabel: nil))
        #expect(undo.contains("\u{2325}\u{2318}Z"), "⌥⌘Z")
        #expect(undo.contains("\u{21e7}\u{2325}\u{2318}Z"), "⇧⌥⌘Z")
        let redo = try #require(EditorUndoHint.message(
            for: .redo, textStackHasEntries: false,
            structuralUndoLabel: nil, structuralRedoLabel: "Divide"))
        #expect(redo.contains("\u{21e7}\u{2325}\u{2318}Z"))
    }

    // MARK: - J7, the chord classifier (pure)

    private static func zEvent(_ modifiers: NSEvent.ModifierFlags) -> NSEvent {
        NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: modifiers, timestamp: 0,
            windowNumber: 0, context: nil,
            characters: modifiers.contains(.shift) ? "Z" : "z",
            charactersIgnoringModifiers: modifiers.contains(.shift) ? "Z" : "z",
            isARepeat: false, keyCode: 6)!
    }

    /// ⌘Z and ⌘⇧Z are the hint's chords; the STRUCTURAL keys are not — they
    /// are already the door it points at, and eating them would be the one
    /// thing this feature must never do.
    @Test func onlyTheTextUndoChordsAreTheHints() {
        #expect(EditorTextView.undoHintChord(for: Self.zEvent(.command)) == .undo)
        #expect(EditorTextView.undoHintChord(for: Self.zEvent([.command, .shift])) == .redo)
        #expect(EditorTextView.undoHintChord(for: Self.zEvent([.command, .option])) == nil)
        #expect(EditorTextView.undoHintChord(
            for: Self.zEvent([.command, .option, .shift])) == nil)
        #expect(EditorTextView.undoHintChord(for: Self.zEvent([])) == nil)
        // Caps lock and the keypad flags are state, not meaning (the 13d F-2
        // lesson, applied here too).
        #expect(EditorTextView.undoHintChord(
            for: Self.zEvent([.command, .capsLock])) == .undo)
    }

    // MARK: - J7, end to end through the real key path

    /// **A real ⌘Z, in a real key window, on the real editor.** After a
    /// structural delete the text stack is empty by design (the store-led
    /// rewrite clears it) and the structural stack holds the entry — so the
    /// press speaks, and `performKeyEquivalent` does NOT claim the key.
    @Test func commandZAfterAStructuralChangeSpeaksTheHintAndKeepsTheKey() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { harness in
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 600, height: 400),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer { window.orderOut(nil); window.close() }
            let host = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
            host.addSubview(harness.textView)
            window.contentView = host
            window.makeKeyAndOrderFront(nil)
            window.makeFirstResponder(harness.textView)

            // A structural act: delete the caret block through the ordinary door.
            harness.textView.setSelectedRange(NSRange(location: 0, length: 0))
            harness.model.updateCaretContext()
            await harness.model.deleteCaretBlock()
            await harness.flush()
            #expect(harness.session.undoMenuState.topLabel == "Delete Block")

            harness.textView.undoManager?.removeAllActions()
            #expect(harness.textView.undoManager?.canUndo == false,
                    "nothing left in the TEXT stack — her exact moment")
            harness.model.showStatus("")

            let claimed = harness.textView.performKeyEquivalent(with: Self.zEvent(.command))
            #expect(claimed == false, "the key is NEVER consumed — ⌘Z falls straight through")
            #expect(harness.model.statusMessage == EditorUndoHint.message(
                for: .undo, textStackHasEntries: false,
                structuralUndoLabel: "Delete Block", structuralRedoLabel: nil))
        }
    }

    /// …and with something in the TEXT stack, ⌘Z is doing its job and the
    /// hint stays quiet.
    @Test func commandZWithTextToUndoSaysNothing() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { harness in
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 600, height: 400),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer { window.orderOut(nil); window.close() }
            let host = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
            host.addSubview(harness.textView)
            window.contentView = host
            window.makeKeyAndOrderFront(nil)
            window.makeFirstResponder(harness.textView)

            harness.textView.setSelectedRange(NSRange(location: 0, length: 0))
            harness.model.updateCaretContext()
            await harness.model.deleteCaretBlock()
            await harness.flush()

            // Type — that is a text-stack entry.
            harness.type("x", at: 0)
            await harness.flush()
            #expect(harness.textView.undoManager?.canUndo == true)
            harness.model.showStatus("")

            _ = harness.textView.performKeyEquivalent(with: Self.zEvent(.command))
            #expect(harness.model.statusMessage == "",
                    "⌘Z has text to undo — the sign stays down")
        }
    }

    // MARK: - J8(a): the receipt tells the truth

    /// **The tray this copy used to promise has no face anywhere** (her first
    /// morning back, report 1 — `restoreBlock` and `last_container_id` are
    /// faceless ops). Until batch 2 builds it, no delete receipt may name it.
    /// **GRADUATED at batch 2** (13j J8(a), as the batch-1 record promised).
    /// The claim is the same one it always was — *a receipt may only name a
    /// surface that has a door* — and what changed is the world: batch 2
    /// built the tray, so the pin flips from "must not name it" to "names it
    /// AND the door is real". The stronger form is deliberate: asserting the
    /// string alone would let the copy survive a future removal of the door
    /// it names, which is the exact defect this pin exists for.
    @Test func everyDeleteReceiptNamesTheTrayAndTheTrayHasARealDoor() {
        let lines = [
            BlockSelectionCopy.deletedNote(1),
            BlockSelectionCopy.deletedNote(4),
            BlockSelectionCopy.deleteHelp,
        ]
        for line in lines {
            #expect(line.contains(TrayPath.menuLabel),
                    "the tray exists now, so the receipt names it: \"\(line)\"")
        }
        // The named surface is a DECLARED, RENDERED act — not a sentence.
        let act = CapabilityRegistry.capability(.showNoteTray)
        #expect(act.verb == TrayPath.menuLabel)
        // GRADUATED at the post-13l polish round, batch 3 (her C1 ruling —
        // the door moved to the masthead icon and the `note ▾` item went
        // with it). The pin's own point survives exactly: the receipt may
        // only name a surface that HAS a door, and here are its renderers.
        // **A JUSTIFIED EDIT** (the architect's adjudication 1, batch 4): the
        // ⌘K row joins the three surfaces. What this pin is about is
        // untouched — a receipt may only name a surface that HAS a door —
        // and one more door can only make that more true.
        #expect(act.doors == [.surface, .palette])
        #expect(PostDetailView.surfaceCapabilities.contains(.showNoteTray))
        #expect(ContextBar.surfaceCapabilities.contains(.showNoteTray))
        #expect(!CommitBar.renderedCapabilities.contains(.showNoteTray))
        // …and the interim truth survives beside it: ⌥⌘Z is still named,
        // because the two roads are different promises (one dies with the
        // session, one does not).
        #expect(BlockSelectionCopy.deletedNote(1).contains("\u{2325}\u{2318}Z"))
        #expect(BlockSelectionCopy.deletedNote(4).contains("in one go"),
                "the compound's one-mistake-to-reverse promise survives")
    }

    /// One receipt, every delete door — Write's block delete, the Takes
    /// board's, and the multi-delete compound cannot drift on the sentence.
    @Test func everyDeleteDoorSpeaksTheSameReceipt() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { harness in
            harness.textView.setSelectedRange(NSRange(location: 0, length: 0))
            harness.model.updateCaretContext()
            await harness.model.deleteCaretBlock()
            await harness.flush()
            #expect(harness.model.statusMessage == BlockSelectionCopy.deletedNote(1))
        }
    }

    // MARK: - J8(b): the refusal diagnoses

    private static func index(
        _ entries: [(len: Int, variant: String?, editable: Bool)], tail: Int? = nil
    ) -> BlockRangeIndex {
        BlockRangeIndex(
            entries: entries.enumerated().map {
                BlockRangeIndex.Entry(
                    blockID: "b\($0.offset)", variantID: $0.element.variant,
                    length: $0.element.len, editable: $0.element.editable)
            },
            tailLength: tail)
    }

    /// Every branch of the diagnosis, each traced to the guard it mirrors.
    @Test func eachRefusalNamesTheConditionThatActuallyDeclined() {
        // A seam keystroke beside a FANNED block: A7 declines (takes are
        // text), #34 declines (needs text on both sides).
        let seam = Self.index([(0, "v0", true), (3, "v1", true)])
        #expect(CrossBlockRefusal.diagnose(
            range: NSRange(location: 0, length: 1), index: seam,
            slots: [slot("b0", text: "", fan: 2), slot("b1", text: "bbb")])
            == .seamBesideFan)
        // …and beside one carrying prose the slot does not show — the ONE
        // core guard (`carriesUnshownText`) split into the two kinds it
        // joins, because "an archived take or a comment" would be a guess.
        #expect(CrossBlockRefusal.diagnose(
            range: NSRange(location: 0, length: 1), index: seam,
            slots: [slot("b0", text: "", archived: 1), slot("b1", text: "bbb")])
            == .seamBesideArchivedTake)
        #expect(CrossBlockRefusal.diagnose(
            range: NSRange(location: 0, length: 1), index: seam,
            slots: [slot("b0", text: "", comments: 2), slot("b1", text: "bbb")])
            == .seamBesideComment)
        // A locked take at the seam outranks both — nothing can write there.
        let lockedSeam = Self.index([(0, "v0", false), (3, "v1", true)])
        #expect(CrossBlockRefusal.diagnose(
            range: NSRange(location: 0, length: 1), index: lockedSeam,
            slots: [slot("b0", text: "", fan: 2), slot("b1", text: "bbb")])
            == .lockedTake)
        // A gap slot says GAP, never "locked".
        let gapSeam = Self.index([(0, nil, false), (3, "v1", true)])
        #expect(CrossBlockRefusal.diagnose(
            range: NSRange(location: 0, length: 1), index: gapSeam,
            slots: [slot("b0", variant: nil, text: nil), slot("b1", text: "bbb")])
            == .unsyncedBlock)

        // A span reaching into the open tail.
        let tailed = Self.index([(2, "v0", true), (3, "v1", true)], tail: 4)
        #expect(CrossBlockRefusal.diagnose(
            range: NSRange(location: 3, length: 5), index: tailed,
            slots: [slot("b0", text: "aa"), slot("b1", text: "bbb")])
            == .openTail)

        // A multi-block span containing a locked take.
        let lockedMiddle = Self.index([(2, "v0", true), (3, "v1", false), (1, "v2", true)])
        #expect(CrossBlockRefusal.diagnose(
            range: NSRange(location: 1, length: 5), index: lockedMiddle,
            slots: [slot("b0", text: "aa"), slot("b1", text: "bbb", locked: true),
                    slot("b2", text: "c")])
            == .lockedTake)

        // The residual: a boundary crossed with a block covered in part.
        let clean = Self.index([(2, "v0", true), (3, "v1", true), (1, "v2", true)])
        #expect(CrossBlockRefusal.diagnose(
            range: NSRange(location: 1, length: 5), index: clean,
            slots: [slot("b0", text: "aa"), slot("b1", text: "bbb"), slot("b2", text: "c")])
            == .partialBlockAcrossSeam)
    }

    /// **The words stop guessing.** The shipped line named three causes at
    /// once; no diagnosis may do that again, and each names its own road out.
    @Test func noRefusalLineListsCausesItDidNotEstablish() {
        let causes: [CrossBlockRefusal.Cause] = [
            .seamBesideFan, .seamBesideArchivedTake, .seamBesideComment,
            .lockedTake, .unsyncedBlock, .openTail, .partialBlockAcrossSeam,
        ]
        for cause in causes {
            // The CAUSE half names one thing. (The ROAD half may offer a
            // choice of ways out — that is help, not a guess.)
            let clause = CrossBlockRefusal.causeClause(for: cause)
            #expect(!clause.contains(" or "),
                    "\"\(clause)\" offers a menu of causes instead of naming one")
            #expect(!clause.isEmpty)
            #expect(!CrossBlockRefusal.roadClause(for: cause).isEmpty,
                    "every refusal leaves a road out")
            // The specific guess her screenshot showed is gone from the app.
            #expect(!CrossBlockRefusal.message(for: cause)
                .contains("a locked take, unsynced text"))
        }
    }

    /// **THE A2 PIN (13j ladder A round 1, MAJOR — red-on-old).** After the
    /// J4b flip ⌘⇧M carries every take along and ⌥⌘⇧M pairs by hand — and
    /// BOTH fan-fold refusals must teach exactly that. The pre-fix
    /// `.seamBesideFan` road still said "use Merge Blocks (⌘⇧M) to pair the
    /// takes yourself": the batch-4 copy sweep was site-directed and fixed
    /// only the texted-seam twin, so the same sentence lived on in its
    /// second home — inside J8(b)'s own file. The close is structural: both
    /// speakers now END IN the one shared roads constant, so they cannot
    /// drift apart again.
    @Test func theSeamFanRoadTeachesTheFlippedDefaultsFromOneHome() {
        let road = CrossBlockRefusal.roadClause(for: .seamBesideFan)
        #expect(!road.contains("to pair the takes yourself"),
                "⌘⇧M does not pair any more — hand-pairing is the ceremony's")
        #expect(road.contains("brings every take along"))
        #expect(road.contains("Merge choosing takes (⌥⌘⇧M)"))
        #expect(road.hasSuffix(FannedDefaultsCopy.fanFoldRoads),
                "one home: the diagnosis speaks the shared roads sentence")
        #expect(EditorSurfaceController.seamFanRefusal(leading: 2, trailing: 1)
            .hasSuffix(FannedDefaultsCopy.fanFoldRoads),
                "…and so does the texted-seam refusal")
    }

    /// The refusal her screenshot showed is now the DELETE road, so the only
    /// selections that still speak are the ones her ruling left alone — and
    /// they say which block, and why.
    @Test func aPartialCrossBlockSelectionSpeaksTheDiagnosis() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two.", "Gamma three."]) { harness in
            // Lock the middle take so no road can write into it.
            let middle = try #require(harness.model.index.entries[1].variantID)
            try await harness.session.runner.run { ops in try ops.lockVariant(middle) }
            try harness.reload()

            // Half of block 0 through half of block 1 — a partial span.
            harness.replace(NSRange(location: 6, length: 10), with: "")
            await harness.flush()
            #expect(harness.model.statusMessage
                == CrossBlockRefusal.message(for: .lockedTake),
                "it names the LOCK — the one thing that actually declined")
        }
    }
}
