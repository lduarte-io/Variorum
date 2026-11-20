//
//  MobileUndoDoorTests.swift
//  VariorumMobileTests
//
//  **M20 — the structural undo/redo door, HER OWN PROPOSAL** (round 2 §29's
//  R10). The round's §39 audit found it dropped, and worse: §30's R13 had
//  removed the whole-block delete's confirm *"on the strength of a
//  replacement I then failed to schedule"*, so the phone had neither.
//
//  What these pins are careful about, because it is the round's own trap
//  (b): the STACK was already proven at the API by batch 1b. Re-proving the
//  stack would be re-proving what was never broken. **What is missing is a
//  DOOR**, so the pins that matter here MOUNT the real masthead / the real
//  sheet and ACTIVATE the real control by its accessibility label.
//
//  Red-on-old is trivially satisfied for every one of them — none of these
//  controls existed on the pre-batch code, so every activation returns
//  false and the store never moves. Where a pin covers behaviour rather
//  than a new door (the receipt's `didSet` clearing), the revert
//  verification is recorded in the batch report.
//

import Foundation
import GRDB
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile structural undo/redo — M20's two doors")
struct MobileUndoDoorTests {
    // MARK: - The line's Undo (the door that matters most)
    //
    // **VM-61 (2026-11-19): the receipt left the masthead for the shell's ONE
    // line** (her VM-44 ruling; the note-write mockup's D4/D4b). These pins
    // follow it: a removal's Undo is the line's own real Button, mounted and
    // activated through UIKit's dispatch exactly as the masthead's was; a
    // divide and a landed undo say nothing, and their doors are the ⋯ sheet's.

    /// **THE PIN THIS ROW EXISTS FOR.** Delete two whole paragraphs with
    /// her own gesture — the one R13 stripped the confirm from — then mount
    /// the REAL message line and press the REAL "Undo" it carries. The blocks
    /// come back, in place, from a control a finger could reach.
    ///
    /// It drives `accessibilityActivate()`, which is UIKit's own activation
    /// dispatch for a SwiftUI Button (the road VoiceOver takes) — not the
    /// view model behind it, and not `MobileUndoDoor` directly.
    @Test func theReceiptsUndoButtonPutsDeletedBlocksBack() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(
                session, blocks: ["First para.", "Second para.", "Third para."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)

            // Her gesture: two whole paragraphs, deleted as ONE compound.
            let doomed = model.index.entries.prefix(2).map(\.blockID)
            await model.structural.deleteWholeBlockRun(Array(doomed))
            #expect(try await storedBlockTexts(db, postID: postID) == ["Third para."])
            #expect(model.statusMessage == MobileStructuralController.blocksDeletedStatus(2))
            #expect(model.statusAction == .undo, "the model records the way back")
            #expect(session.status.current?.leavesPage == true, "the line speaks it")

            try await withHostedSurface(
                MobileMessageLineView(model: MobileMessageLineModel(
                    status: session.status, voice: { .terminal }))
            ) { surface in
                // The REAL button is on the line.
                let undo = try #require(surface.element(labeled: MobileLine.undoLabel),
                                        "labels were \(surface.visibleLabels)")
                #expect(undo.accessibilityActivate(), "UIKit fires the real control")
                await surface.settle(30)
            }

            // The store moved, and the blocks came back IN PLACE.
            #expect(try await storedBlockTexts(db, postID: postID)
                == ["First para.", "Second para.", "Third para."])
        }
    }

    /// **A landed undo says nothing, and its Redo is the ⋯ sheet's** (VM-61 —
    /// her ruling: no line for an ordinary act; the note-write mockup's table,
    /// "Undo · Redo — nothing said; the page shows it"). This pin used to
    /// press the receipt's own Redo — R10's ping-pong, retired with the
    /// masthead receipt; the line drops "Undid: …" and the persistent door
    /// carries the Redo.
    @Test func theReceiptsRedoButtonReAppliesWhatWasUndone() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(
                session, blocks: ["First para.", "Second para."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)

            await model.structural.deleteWholeBlockRun([model.index.entries[0].blockID])
            await model.undoDoor.beginUndo(from: .receipt)
            #expect(try await storedBlockTexts(db, postID: postID)
                == ["First para.", "Second para."])
            #expect(model.statusMessage == StructuralUndoCopy.undone("Delete Blocks"))
            #expect(model.statusAction == .redo, "the model records the way forward")
            #expect(session.status.current == nil, "the line says nothing for a landed undo")

            try await withHostedSurface(
                MobileWriteScreen(session: session, postID: postID, editor: model)
            ) { surface in
                #expect(surface.activate(MobileNoteActionsSheet.doorLabel))
                await surface.settle(40)
                #expect(surface.activate("Redo Delete Blocks"),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(30)
            }
            #expect(try await storedBlockTexts(db, postID: postID) == ["Second para."])
        }
    }

    /// **Divide says nothing, and its way back is the ⋯ sheet's** (VM-61 —
    /// the note-write mockup's D3: "Nothing is said: nothing left the page").
    /// The masthead's bare Undo for the silent acts retired with the masthead
    /// receipt; a divide puts nothing on the line, and the persistent door
    /// undoes it.
    @Test func aSilentStructuralActStillWearsTheUndoDoor() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["One two three four."])
            let (model, surfaceView) = await makeSurfaceEditor(session, postID: postID)

            surfaceView.textView.selectedRange = NSRange(location: 8, length: 0)
            await model.structural.divide(atSurfaceCaret: 8)
            #expect(try await storedBlockTexts(db, postID: postID) == ["One two", "three four."])
            #expect(model.statusMessage == nil, "divide still says nothing")
            #expect(model.statusAction == .undo, "the model records the way back")
            #expect(session.status.current == nil, "and the line says nothing either")

            try await withHostedSurface(
                MobileWriteScreen(session: session, postID: postID, editor: model)
            ) { surface in
                #expect(surface.activate(MobileNoteActionsSheet.doorLabel))
                await surface.settle(40)
                #expect(surface.activate("Undo Divide"), "labels were \(surface.visibleLabels)")
                await surface.settle(30)
            }
            #expect(try await storedBlockTexts(db, postID: postID) == ["One two three four."])
        }
    }

    /// **The stale-receipt guard, driven through a REAL refusal.**
    /// `statusMessage`'s `didSet` clears the action, so a new sentence can
    /// never keep an old Undo standing beside it offering to reverse
    /// something the sentence does not name.
    ///
    /// It is pinned through the GATE's own refusal road
    /// (`MobileEditorViewModel.refuse`), which assigns `statusMessage`
    /// DIRECTLY — one of eight such sites. Pinning it through
    /// `report(_:action:)` would have proven nothing: that door writes the
    /// action itself, so it stays correct with the `didSet` removed
    /// (measured — the first draft of this pin was green on the reverted
    /// tree, which is exactly the false-green shape this batch is under
    /// orders to avoid).
    ///
    /// **Red on old, by behavioural revert:** with the `didSet` deleted the
    /// Undo action survives the refusal and this pin fails. Verified.
    @Test func aRefusalDropsTheOldReceiptsAction() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(
                session, blocks: ["Alpha one.", "Beta two.", "Gamma three."])
            let (model, storage) = makeEditor(session, postID: postID)
            await model.loadOnce()
            // **A LOCKED take makes the cross-block span REFUSE at the gate**
            // rather than route to the compound. *(13u1 UNIT 2: this used to
            // be a FANNED block, which refused before her item 5 ruling made
            // a fanned span the compound's ordinary road. A lock is now one
            // of the only two things a cross-block edit refuses for —
            // R-13u-1, refuse whole, naming the lock — so it is what this
            // pin drives; the pin's own subject, the receipt's stale Undo,
            // is untouched.)*
            try await session.runner.run { [slot = model.slots[1]] ops in
                try ops.lockVariant(slot.variantID!)
            }
            await model.refreshTakesFromStore()
            model.applyProjection(try await session.database.read {
                [postID] db in try Queries.renderPost(db, containerID: postID)
            })

            // A structural act leaves a receipt WITH its Undo.
            await model.structural.deleteBlock(blockID: model.index.entries[2].blockID)
            #expect(model.statusAction == .undo)
            #expect(try await storedBlockTexts(db, postID: postID)
                == ["Alpha one.", "Beta two."])

            // Now a refused keystroke speaks through the direct-assignment
            // road: the sentence changes, and the stale Undo goes with it.
            typeEdit(model, storage, range: NSRange(location: 6, length: 10), replacement: "")
            await model.pendingGestureTask?.value
            #expect(model.statusMessage == CrossBlockRefusal.message(
                for: .lockedTake, fanRoads: MobileEditorViewModel.fanFoldRoads),
                    "the refusal DIAGNOSES: \(model.statusMessage ?? "nil")")
            #expect(model.statusAction == nil, "the action never outlives its sentence")
        }
    }

    // MARK: - The persistent door (the ⋯ sheet)

    /// **The companion door, driven end to end**: open the REAL ⋯ sheet
    /// from the REAL masthead, find the REAL "Undo Delete Blocks" row, and
    /// press it. This is the road for an act whose receipt has passed.
    @Test func theNoteActionsSheetUndoRowIsReachableAndActs() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(
                session, blocks: ["Keep me.", "Delete me."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            await model.structural.deleteBlock(blockID: model.index.entries[1].blockID)
            #expect(try await storedBlockTexts(db, postID: postID) == ["Keep me."])

            try await withHostedSurface(
                MobileWriteScreen(session: session, postID: postID, editor: model)
            ) { surface in
                // The masthead's ⋯ — a real control with a real label.
                #expect(surface.activate(MobileNoteActionsSheet.doorLabel),
                        "the ⋯ door is on the masthead and activates")
                await surface.settle(40)
                // The sheet is up and its rows are real Buttons.
                #expect(surface.visibleLabels.contains("Undo Delete Block"),
                        "labels were \(surface.visibleLabels)")
                #expect(surface.activate("Undo Delete Block"))
                await surface.settle(40)
            }
            #expect(try await storedBlockTexts(db, postID: postID)
                == ["Keep me.", "Delete me."])
        }
    }

    /// The sheet renders a row for an END THE STACK ACTUALLY HAS, and none
    /// for one it does not (P-2: a door that can never act isn't rendered).
    /// A fresh note has no structural history, so neither row exists.
    @Test func theSheetRendersNoUndoRowWithAnEmptyStack() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["Nothing done yet."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)

            try await withHostedSurface(
                MobileWriteScreen(session: session, postID: postID, editor: model)
            ) { surface in
                #expect(surface.activate(MobileNoteActionsSheet.doorLabel))
                await surface.settle(40)
                let labels = surface.visibleLabels
                #expect(!labels.contains { $0.hasPrefix("Undo ") }, "labels were \(labels)")
                #expect(!labels.contains { $0.hasPrefix("Redo ") })
                // …but the sheet IS up, so the absence is a rendering fact
                // and not a failure to open.
                #expect(labels.contains(MobileEditorViewModel.deleteNoteTitle))
            }
        }
    }

    // MARK: - A12's destructive-undo warning (the phone's half)

    /// **The insurance class asks first, and the REAL alert presents.** Her
    /// 13d A12 ruling: the confirm fires only when the undo would set aside
    /// text edited since the operation.
    ///
    /// The class is precise, and the pin had to be traced to it rather than
    /// guessed: only `divide`, `extract` and the take edits register
    /// pre-images (`UndoStack.Entry.insuring`), because only their inverses
    /// OVERWRITE a buffer. A delete's inverse is a tombstone flip and sets
    /// nothing aside — so this pin divides, types into the source half, and
    /// then undoes.
    @Test func undoWarnsBeforeDiscardingWritingDoneSince() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["One two three four."])
            let (model, surfaceView) = await makeSurfaceEditor(session, postID: postID)

            await model.structural.divide(atSurfaceCaret: 8)
            #expect(try await storedBlockTexts(db, postID: postID)
                == ["One two", "three four."])

            // Edit the FIRST half — the variant whose pre-image the divide
            // captured, and so the buffer the inverse would restore over.
            //
            // Through the autosave coordinator rather than the text view,
            // deliberately: the coordinator is the exact seam the editor's
            // own `recordAutosave` writes to, so the buffer is pending and
            // then stored by the same road a keystroke takes — and the pin
            // stays clear of a PRE-EXISTING routing gap this batch found and
            // reported (the first typed edit after a divide takes the
            // desync-recovery road; reproduced identically on the pre-batch
            // tree, so it is neither this batch's to cause nor to fix).
            let sourceVariant = try #require(model.index.entries[0].variantID)
            model.autosave.record(
                variantID: sourceVariant, text: "One two more", charDelta: 5)
            await model.autosave.flushNow()
            #expect(try await storedBlockTexts(db, postID: postID)
                == ["One two more", "three four."])
            // The surface catches up to the store before the screen mounts:
            // this pin wrote through the coordinator rather than the text
            // view, so the editor has not seen the new bytes, and mounting
            // over a surface that disagrees with the store is a desync by
            // design (the editor's own honest recovery road).
            await model.refreshTakesFromStore()

            try await withHostedSurface(
                MobileWriteScreen(session: session, postID: postID, editor: model)
            ) { surface in
                // VM-61: the RECEIPT surface's Undo is the one line's door
                // (`MobileLine.Undo.structural`), drawn on a removal; a divide
                // no longer draws a line, so this pin presses the door the
                // line presses. The subject — A12's host on the receipt
                // surface and its confirm→act edge — is unchanged.
                await model.undoDoor.beginUndo(from: .receipt)
                await surface.settle(40)
                let alert = try #require(surface.presentedAlert,
                                         "A12's warning must actually present")
                #expect(alert.title == StructuralUndoCopy.discardingUndoQuestion(
                    .init(label: "Divide", bufferCount: 1)))
                #expect(alert.title == "Undo Divide?")
                // Batch 6a renamed the door the sentence points at — "Take
                // History…" became "Block History…", because the face it
                // opens is the whole BLOCK's past. The pin follows the door
                // and now reads the SHARED name, so the two can never drift
                // again. Its claim is unchanged: the phone's detail names a
                // phone road, never ⌘S.
                #expect(alert.message?.contains(BlockHistoryPath.name) == true,
                        "the phone's detail names its own road, never ⌘S")
                #expect(alert.message?.contains("⌘") == false)
                #expect(surface.alertActionTitles.map { $0.lowercased() }
                    .contains("undo"))
                #expect(surface.alertActionTitles.map { $0.lowercased() }
                    .contains("cancel"))

                // Nothing happened while the question stood.
                #expect(try await storedBlockTexts(db, postID: postID)
                    == ["One two more", "three four."])
                #expect(model.undoDoor.pendingWarning != nil)

                // **THE CONFIRM→ACT EDGE, DRIVEN** (batch 4.5b's BLOCKER).
                // The shipped pin called `confirmPendingUndo()` directly,
                // while the pending warning was still set — and that was the
                // one edge with no coverage. Pressing the real **Undo**
                // CANCELLED the undo: SwiftUI's `isPresented` write-back ran
                // `cancelPendingUndo()` inside tap handling, so the enqueued
                // `Task` found nothing to confirm and the receipt read
                // "Undo cancelled — nothing changed."
                //
                // This taps the real action and lands the write-back in the
                // same synchronous turn, which is what a tap is.
                #expect(surface.tapAlertAction(
                    "Undo", writeBack: { model.undoDoor.warningAtReceipt = false }),
                        "the warning's Undo action must be drivable")
                await surface.settle(40)
                #expect(try await storedBlockTexts(db, postID: postID)
                    == ["One two three four."])
                #expect(model.statusMessage != StructuralUndoCopy.undoCancelled,
                        "pressing Undo must never report a cancellation")
            }
        }
    }

    /// The ordinary undo — nothing edited since — asks NOTHING (A12's other
    /// half: every other structural undo stays silent).
    @Test func anOrdinaryUndoAsksNothing() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["One two three four."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            await model.structural.divide(atSurfaceCaret: 8)

            await model.undoDoor.beginUndo(from: .receipt)
            #expect(model.undoDoor.pendingWarning == nil, "no question was asked")
            #expect(try await storedBlockTexts(db, postID: postID)
                == ["One two three four."])
        }
    }

    /// **The REAL Cancel button still cancels** — the other half of 4.5b's
    /// fix, and the half a careless fix would have broken. The setter no
    /// longer decides that the alert closing means she cancelled (it cannot
    /// know which button was pressed); the Cancel button decides, explicitly,
    /// and it must still say so.
    @Test func theRealCancelButtonStillCancelsAndSaysSo() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["One two three four."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            await model.structural.divide(atSurfaceCaret: 8)
            // `.first`, never `[0]` — an index taken right after a size is a
            // runner-killer under a red-on-old revert.
            let sourceVariant = try #require(model.index.entries.first?.variantID)
            model.autosave.record(
                variantID: sourceVariant, text: "One two more", charDelta: 5)
            await model.autosave.flushNow()
            // **The surface catches up BEFORE the screen mounts, and this
            // line is load-bearing rather than tidy.** This pin wrote through
            // the autosave coordinator, not the text view, so the editor has
            // not seen the new bytes; mounting over a surface that disagrees
            // with the store is a desync by design and fires the editor's
            // assertion seam (`MobileEditorViewModel.swift:1540`). Omitting
            // it crashed this pin exactly that way once — a TRACED harness
            // omission with the sibling pin's own recorded mechanism, never
            // "assertion noise": that seam exists to surface routing
            // failures, and reading a 1540 fatal as noise is the round's
            // green-over-nothing failure inverted.
            await model.refreshTakesFromStore()

            try await withHostedSurface(
                MobileWriteScreen(session: session, postID: postID, editor: model)
            ) { surface in
                // VM-61: the door the one line presses (see the pin above).
                await model.undoDoor.beginUndo(from: .receipt)
                await surface.settle(40)
                _ = try #require(surface.presentedAlert)
                #expect(surface.tapAlertAction(
                    "Cancel", writeBack: { model.undoDoor.warningAtReceipt = false }),
                        "the warning's Cancel action must be drivable")
                await surface.settle(40)
            }
            #expect(model.statusMessage == StructuralUndoCopy.undoCancelled)
            #expect(try await storedBlockTexts(db, postID: postID)
                == ["One two more", "three four."], "nothing moved")
        }
    }

    /// Cancelling leaves the store alone and says so.
    @Test func cancellingTheWarningChangesNothing() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["One two three four."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            await model.structural.divide(atSurfaceCaret: 8)
            let sourceVariant = try #require(model.index.entries[0].variantID)
            model.autosave.record(
                variantID: sourceVariant, text: "One two more", charDelta: 5)
            await model.autosave.flushNow()

            await model.undoDoor.beginUndo(from: .receipt)
            #expect(model.undoDoor.pendingWarning != nil)
            model.undoDoor.cancelPendingUndo()
            #expect(model.statusMessage == StructuralUndoCopy.undoCancelled)
            #expect(try await storedBlockTexts(db, postID: postID)
                == ["One two more", "three four."])
        }
    }

    // MARK: - VM-16: a QUIET press speaks a refusal and offers no way back
    //
    // **Re-shaped at the merge-in (VM-78, main's VM-61 line):** a press now
    // speaks on the shell's ONE line, so each pin asserts the rule where she
    // reads it — `session.status.current` — as well as on the model's own
    // record (`statusMessage` / `statusAction`, which the line's doors still
    // keep — VM-61's AD-14 precedent). A quiet press is a REFUSAL on the line
    // with no action, and records no way back; a landed press is VM-61's
    // ordinary act — nothing on the line — and records its way back.

    /// **The ticket's own pin (VM-16 — VX-276's rule, phone side).** Register
    /// X (her Delete Block) then Y (a divide); undo Y — Y now waits on the
    /// redo stack; reverse X through an undo-less door (her Put back from
    /// the tray, which registers nothing and clears no future); then undo.
    /// X's inverse finds its block already back and writes nothing — a
    /// QUIET press, so the stack RETIRES X and leaves Y on the redo stack.
    ///
    /// **Red on old:** the door read `undo(with:)`'s label, so this press
    /// said "Undid: Delete Block" and offered a Redo whose press would
    /// re-apply Y — the divide, an entry the sentence never named. **Red
    /// against main's door as merged** (`MobileUndoDoor.swift` at VM-55's
    /// merge): the same press is classed ordinary, so the one line says
    /// NOTHING, while the model records "Undid: Delete Block" and `.redo`.
    @Test func aQuietUndoSpeaksTheRefusalAndOffersNoRedo() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(
                session, blocks: ["One two three four.", "Delete me."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            let stack = session.undoStack

            // X — her Delete Block on the second paragraph.
            let doomed = try #require(model.index.entries.last?.blockID)
            await model.structural.deleteBlock(blockID: doomed)
            #expect(try await storedBlockTexts(db, postID: postID) == ["One two three four."])
            // Y — a divide.
            await model.structural.divide(atSurfaceCaret: 8)
            #expect(try await storedBlockTexts(db, postID: postID) == ["One two", "three four."])

            // Undo Y: it changed something, so Y waits on the redo stack.
            await model.undoDoor.beginUndo(from: .receipt)
            #expect(try await storedBlockTexts(db, postID: postID) == ["One two three four."])
            #expect(model.statusMessage == StructuralUndoCopy.undone("Divide"))
            #expect(model.statusAction == .redo, "a landed undo still offers its redo")
            #expect(session.status.current == nil, "a landed undo says nothing on the line")
            #expect(stack.topRedoLabel == "Divide")

            // X reversed through an undo-less door — her Put back.
            _ = try await session.runner.run { ops in try ops.restoreBlock(doomed) }
            await model.refreshTakesFromStore()
            #expect(try await storedBlockTexts(db, postID: postID)
                == ["One two three four.", "Delete me."])
            #expect(stack.topLabel == "Delete Block", "her Put back registered nothing")
            #expect(stack.topRedoLabel == "Divide", "…and cleared no future")

            // The quiet press.
            await model.undoDoor.beginUndo(from: .receipt)
            #expect(model.statusMessage
                == "Nothing to undo — Delete Block was already undone or changed since.",
                    "the refusal, in the shared words: \(model.statusMessage ?? "nil")")
            #expect(model.statusMessage == StructuralUndoCopy.undoFoundNothing("Delete Block"))
            #expect(model.statusAction == nil,
                    "no Redo is offered — the redo stack's top is the divide, not this entry")
            // Where she reads it: the one line, as a refusal, with no door.
            let line = try #require(session.status.current,
                                    "a quiet press speaks on the one line — it said nothing")
            #expect(line.kind == .refusal, "a quiet press is a refusal, never an ordinary act")
            #expect(line.text == StructuralUndoCopy.undoFoundNothing("Delete Block"))
            #expect(line.action == nil, "the line offers no way back either")
            // The stack did what VX-246 U2 says, so the door's words are the
            // only thing this pin is about.
            #expect(stack.depth == 0, "the quiet entry is retired")
            #expect(stack.topRedoLabel == "Divide", "the redo future stands as it was")
            #expect(try await storedBlockTexts(db, postID: postID)
                == ["One two three four.", "Delete me."], "her Put back stands")
        }
    }

    /// **The mirror (VM-16): a quiet REDO offers no Undo.** Register W (a
    /// divide) then X (her Delete Block); undo X — the block comes back and X
    /// waits on the redo stack; the block then dies by a road that is no door
    /// of this session's (another device's delete, landing by sync — a
    /// stackless operations instance stands for it: it writes the same rows
    /// and touches no session stack); then redo. X's re-apply finds its block
    /// already gone and writes nothing — quiet, so X is RETIRED and the undo
    /// stack stays as it was.
    ///
    /// **Red on old:** the door said "Redid: Delete Block" and offered an Undo
    /// whose press would take back W — the divide. **Red against main's door
    /// as merged:** the press is classed ordinary, so the one line says
    /// nothing, while the model records "Redid: Delete Block" and `.undo`.
    @Test func aQuietRedoSpeaksTheRefusalAndOffersNoUndo() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(
                session, blocks: ["One two three four.", "Delete me."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            let stack = session.undoStack

            // W — a divide, which stays on the undo stack throughout.
            await model.structural.divide(atSurfaceCaret: 8)
            #expect(try await storedBlockTexts(db, postID: postID)
                == ["One two", "three four.", "Delete me."])
            // X — her Delete Block.
            let doomed = try #require(model.index.entries.last?.blockID)
            await model.structural.deleteBlock(blockID: doomed)
            #expect(try await storedBlockTexts(db, postID: postID) == ["One two", "three four."])

            // Undo X: the block comes back; X waits on the redo stack.
            await model.undoDoor.beginUndo(from: .receipt)
            #expect(try await storedBlockTexts(db, postID: postID)
                == ["One two", "three four.", "Delete me."])
            #expect(stack.topRedoLabel == "Delete Block")
            #expect(stack.topLabel == "Divide")

            // The block dies elsewhere: no entry, no cleared future.
            try Operations(undoStack: nil).deleteBlock(doomed)
            await model.refreshTakesFromStore()
            #expect(try await storedBlockTexts(db, postID: postID) == ["One two", "three four."])
            #expect(stack.topRedoLabel == "Delete Block", "the other delete cleared no future")

            // The quiet press.
            await model.undoDoor.redo()
            #expect(model.statusMessage
                == "Nothing to redo — it changed again after Delete Block was undone.",
                    "the refusal, in the shared words: \(model.statusMessage ?? "nil")")
            #expect(model.statusMessage == StructuralUndoCopy.redoFoundNothing("Delete Block"))
            #expect(model.statusAction == nil,
                    "no Undo is offered — the undo stack's top is the divide, not this entry")
            let line = try #require(session.status.current,
                                    "a quiet press speaks on the one line — it said nothing")
            #expect(line.kind == .refusal, "a quiet press is a refusal, never an ordinary act")
            #expect(line.text == StructuralUndoCopy.redoFoundNothing("Delete Block"))
            #expect(line.action == nil, "the line offers no way back either")
            #expect(stack.redoDepth == 0, "the quiet entry is retired")
            #expect(stack.topLabel == "Divide", "the undo history stands as it was")
        }
    }

    /// **The control: a press that CHANGED something keeps its way back**
    /// (green on both sides — the fix must not strip the ping-pong her R10
    /// asked for). A landed redo records its Undo, exactly as before, and —
    /// VM-61's class, main's door — says nothing on the one line (its Undo is
    /// the ⋯ sheet's).
    @Test func aLandedRedoStillOffersItsUndo() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(session, blocks: ["One two three four."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            await model.structural.divide(atSurfaceCaret: 8)
            await model.undoDoor.beginUndo(from: .receipt)
            await model.undoDoor.redo()
            #expect(try await storedBlockTexts(db, postID: postID) == ["One two", "three four."])
            #expect(model.statusMessage == StructuralUndoCopy.redone("Divide"))
            #expect(model.statusAction == .undo)
            #expect(session.status.current == nil, "a landed redo is ordinary — nothing on the line")
        }
    }

    /// **The warning is honest because the door FLUSHES first.** Type into
    /// the source half and DO NOT flush: the ROW still holds the divide's
    /// own output, so `wouldInsure` (currentText != preImage.postOpText)
    /// answers NO to a question whose true answer is YES. The door's flush
    /// is what makes it fire.
    ///
    /// **Red on old, by behavioural revert:** with `flushPendingText()`
    /// removed from `beginUndo`, this pin fails — the warning is nil and the
    /// undo silently discards the typing. Verified.
    @Test func theWarningSeesTypingThatIsStillPending() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await makePost(session, blocks: ["One two three four."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            await model.structural.divide(atSurfaceCaret: 8)

            // Edited, NOT flushed — the autosave clock is disabled in this
            // harness, so the bytes live only in the coordinator.
            let sourceVariant = try #require(model.index.entries[0].variantID)
            model.autosave.record(
                variantID: sourceVariant, text: "One two more", charDelta: 5)
            #expect(model.autosave.isDirty, "the precondition this pin turns on")

            await model.undoDoor.beginUndo(from: .receipt)
            #expect(model.undoDoor.pendingWarning != nil,
                    "the flush is what lets A12 see the pending keystrokes")
        }
    }
}
