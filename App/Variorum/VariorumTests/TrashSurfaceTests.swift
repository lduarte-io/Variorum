//
//  TrashSurfaceTests.swift
//  VariorumTests
//
//  Phase 13j, batch 6 — the Trash's FACE, the 30-day clock where she reads
//  it, block ARCHIVE's doors, the Blocks-mode section's routing, and the
//  batch's two copy riders.
//
//  Her rulings under test: everything deleted rides one filterable listing
//  with "N days left" and Put back (round 3); archived things keep no clock
//  and say so (rounds 3 + 7); a preserved original moves VISIBLY onto the
//  family's clock when its last descendant is deleted, and the delete's own
//  receipt names it (round 8b); the Blocks mode's tray section becomes a door
//  onto the one panel (round 7).
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The Trash surface, block archive & the batch-6 riders (13j)")
struct TrashSurfaceTests {
    // MARK: - The clock, where she reads it

    /// The row's words: a countdown for deleted things, the promise of NO
    /// countdown for archived ones — one of the two, never both, never
    /// neither (her round-3 + round-7 distinction, rendered).
    @Test func theCountdownWordsAreTheWindowsOwnAnswer() {
        #expect(TrayPath.daysLeftLabel(30) == "30 days left")
        #expect(TrayPath.daysLeftLabel(1) == "1 day left")
        #expect(TrayPath.daysLeftLabel(0) == "leaves today")
        #expect(TrayPath.archivedForever.contains("no clock"))
        // The tray's first section takes back the name her round-2 ruling
        // gave it, because the state it names EXISTS now (batch 2 could not
        // honestly use it — no op wrote `archived_at`).
        #expect(TrayPath.deletedSection == "Deleted & archived")
        // The Trash surface names the window in words, so a countdown is
        // never a bare threat.
        #expect(RecoveryPath.windowNote.contains("30 days"))
        #expect(RecoveryPath.trashSection == "Trash")
    }

    /// GRADUATED at batch 6b (a consequential pin edit, annotated in place
    /// — the batch-2/3 precedent): this pin shipped at batch 6 asserting NO
    /// purge door existed, because their backing (the sync-visible purge
    /// intent) was schema-shaped and STOP-gated. Batch 6b built the backing
    /// (v1_14 + the janitor), so the claim graduates to its ruled form: the
    /// doors EXIST, they are REGISTRY-DECLARED, and the Trash surface is
    /// their ONLY renderer, forever (her round-3 rider — "never accidental
    /// full delete from within a note"). The surface-walk union in
    /// `CapabilityRegistryTests` enforces the only-renderer half by
    /// construction; `TrashPurgeDoorsTests` carries the doors' behavior.
    @Test func thePurgeDoorsExistAndLiveInTheTrashOnly() {
        #expect(RecoveryView.surfaceCapabilities.contains(.deleteNow))
        #expect(RecoveryView.surfaceCapabilities.contains(.emptyTrash))
        for capability in CapabilityRegistry.all
        where capability.id == .deleteNow || capability.id == .emptyTrash {
            #expect(capability.doors == [.surface],
                    "\(capability.id): a purge act may never grow a menu/bar/palette door — in-Trash only is her rider's letter")
            #expect(capability.unavailableNote.contains("Trash"))
        }
    }

    // MARK: - The listing's face

    @Test func theTrashListsEveryKindWithItsContextAndOneVerb() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { editor in
            let blockID = try #require(editor.model.slots.first?.blockID)
            try await editor.session.runner.run { (ops: Operations) in
                try ops.deleteBlock(blockID)
                let book = try ops.createReading(name: "orbit", kind: .curated)
                try ops.deleteReading(book.id)
                let doomed = try ops.createPost(title: "doomed")
                try ops.deleteContainer(doomed.id)
            }
            let rows: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            let model = RecoveryViewModel(session: editor.session)
            model.adopt(archived: [], trash: rows)
            #expect(Set(model.trash.map(\.kind)) == [.block, .book, .note])
            // Every row wears a countdown read from the session's own clock.
            for row in model.trash {
                #expect(model.daysLeft(row) == 30, "deleted just now — the full window")
            }
            // The block row carries its note's context and the note is live,
            // so the open-there door has something to open.
            let blockRow = try #require(model.trash.first { $0.kind == .block })
            #expect(blockRow.noteID == editor.postID)
            #expect(blockRow.noteIsDeleted == false)
            #expect(RecoveryPath.rowKind(.preservedOriginal) == "preserved original")
        }
    }

    @Test func putBackFromTheTrashUsesEachKindsOwnRoad() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { editor in
            let blockID = try #require(editor.model.slots.first?.blockID)
            try await editor.session.runner.run { (ops: Operations) in try ops.deleteBlock(blockID) }
            let rows: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            let model = RecoveryViewModel(session: editor.session)
            await model.putBack(try #require(rows.first))
            #expect(model.lastError == nil)
            let live: [String] = try await editor.database.read { db in
                try Queries.renderPost(db, containerID: editor.postID).map(\.blockID)
            }
            #expect(live.contains(blockID), "the block is back in its note")
        }
    }

    /// **PUT BACK SAYS WHERE IT LANDED HERE TOO** — the hoist of the drift
    /// §49's MAJOR named (mobile round 2, batch 4.5b).
    ///
    /// The phone's Trash shipped a near-verbatim copy of `RecoveryViewModel`
    /// and it had already diverged in its first week, in exactly one place:
    /// the phone read `restoreBlock`'s LANDING and told her where the block
    /// went, while this model wrote `_ = try ops.restoreBlock(…)` and threw
    /// the answer away — so Put back landed **silently on the Mac**, even
    /// though `RecoveryView` renders `receipt` right beside `lastError`. Two
    /// recovery surfaces answering *"where did it go?"* two different ways is
    /// what M-C forbids, and shared WORDS could not have prevented it because
    /// the divergence was one layer under them, in the decision about which
    /// word to say. Both platforms now run `TrashPutBack`.
    ///
    /// **Red on old:** with the discarding `_ = try ops.restoreBlock(…)`
    /// restored, `receipt` is nil and this pin fails.
    @Test func putBackOnTheMacAlsoSaysWhereItLanded() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { editor in
            let blockID = try #require(editor.model.slots.first?.blockID)
            try await editor.session.runner.run { (ops: Operations) in try ops.deleteBlock(blockID) }
            let rows: [Queries.TrashItem] = try await editor.database.read { db in
                try Queries.trash(db, now: harnessNow)
            }
            let model = RecoveryViewModel(session: editor.session)
            await model.putBack(try #require(rows.first))
            #expect(model.lastError == nil)
            #expect(model.receipt == RecoveryCopy.putBackWhereItWas,
                    "the Mac repeats the op's own answer, exactly as the phone does")
        }
    }

    // MARK: - Block archive (her round-7 ruling), where she meets it

    @Test func theWriteDoorArchivesTheCaretBlockAndSaysWhereItWent() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { editor in
            let blockID = try #require(editor.model.slots.first?.blockID)
            editor.textView.setSelectedRange(NSRange(location: 2, length: 0))
            editor.model.updateCaretContext()
            await editor.model.archiveCaretBlock()
            try editor.reload()

            #expect(!editor.model.slots.map(\.blockID).contains(blockID),
                    "the note renders on without it — no view-level filtering needed")
            let archived: [String] = try await editor.database.read { db in
                try Queries.archivedBlocks(db, postID: editor.postID).map(\.blockID)
            }
            #expect(archived == [blockID])
            // The receipt names the door she can actually see: the note menu
            // item, never the ⌫ badge (which counts deleted only).
            let status = try #require(editor.model.statusMessage)
            #expect(status.contains(TrayPath.menuLabel))
            #expect(status.contains("no countdown"))
            // And the tray lists it with no clock.
            let counts: Queries.TrayCounts = try await editor.database.read { db in
                try Queries.trayCounts(db, postID: editor.postID, now: harnessNow)
            }
            #expect(counts.archived == 1)
            #expect(counts.deleted == 0)
        }
    }

    @Test func theArchiveActIsDeclaredWithBothItsDoors() {
        let capability = CapabilityRegistry.capability(.archiveBlock)
        #expect(capability.verb == "Archive Block")
        #expect(capability.scope == .block)
        #expect(capability.doors == [.menuBar, .contextMenu])
        // It acts where blocks live, and is honestly grey with no note open.
        #expect(CapabilityRegistry.availability(
            .archiveBlock, in: CapabilityContext(mode: .write, writeEditorAttached: true))
                == .act)
        #expect(CapabilityRegistry.availability(
            .archiveBlock, in: CapabilityContext(mode: .takes)) == .act,
            "Takes is never behind Write (R118)")
        #expect(CapabilityRegistry.availability(
            .archiveBlock, in: CapabilityContext(mode: nil)) == .unavailable)
    }

    @Test func theBlockContextMenuCarriesTheArchiveRow() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { editor in
            editor.textView.setSelectedRange(NSRange(location: 2, length: 0))
            editor.model.updateCaretContext()
            let titles = editor.model.contextMenuItems().map(\.title)
            #expect(titles.contains("Archive Block"))
        }
    }

    // MARK: - The stranded original (her round-8b ruling)

    @Test func theDeleteReceiptNamesAnOriginalItJustStranded() async throws {
        try await withEditor(seedBlocks: ["First half. Second half.", "Beta two."]) { editor in
            let blockID = try #require(editor.model.slots.first?.blockID)
            let variantID = try #require(editor.model.slots.first?.variantID)
            let w = try await editor.session.runner.run { ops -> Operations.DivideWResult in
                _ = try ops.branchVariant(blockID, from: variantID)
                return try ops.divideW(blockID, cuts: [variantID: 12])
            }
            try await editor.session.runner.run { (ops: Operations) in
                try ops.deleteBlock(w.first.block.id)
            }
            // One descendant still lives: nothing to say.
            #expect(await StrandedOriginals.note(
                session: editor.session, blockIDs: [w.first.block.id]) == nil)

            try await editor.session.runner.run { (ops: Operations) in
                try ops.deleteBlock(w.second.block.id)
            }
            let note = try #require(await StrandedOriginals.note(
                session: editor.session, blockIDs: [w.second.block.id]))
            #expect(note.contains("rides the Trash"))

            // …and the tray MOVES the row: out of the forever section, into
            // the clock-bearing one (the visible move her ruling asked for).
            // (Ladder B, B5 — annotated pin edit, claim unchanged: the
            // clocks query gained `now:` and answers FATES.)
            let clocks: [String: Queries.OriginFamilyFate] = try await editor.database.read { db in
                try Queries.originFamilyClocks(db, postID: editor.postID, now: harnessNow)
            }
            #expect(clocks[blockID] != nil)
            let stranded: [String] = try await editor.database.read { db in
                try Queries.strandedOriginals(db, now: harnessNow).map(\.id)
            }
            #expect(stranded == [blockID])
            #expect(TrayPath.goesWithItsFamily.contains("goes with its deleted blocks"))
        }
    }

    /// **THE COMPOUND DOORS SAY IT TOO** (13j batch 7 — traced while the
    /// deletion chapter was being written, fixed at both sites).
    ///
    /// Batch 6 wired the stranding sentence into the two SINGLE-block delete
    /// doors and left the compound ones without it — and the compound is the
    /// likeliest door to strand a preserved original: picking a divide's two
    /// successors together and deleting them in one gesture is precisely how
    /// a family's last live descendant goes. Her round-8b failure mode is
    /// someone believing "the ancestor being there in that one ancestor tray
    /// is their guaranteed backup", and a receipt that stayed silent in the
    /// very case that moves it is the J8 defect exactly.
    ///
    /// RED ON OLD (behavioral revert, run and recorded in the batch-7
    /// record): with both appends removed, Write's arm reported only
    /// "2 blocks deleted — …" and the board's the same; both halves of this
    /// test went red.
    @Test func bothMultiDeleteDoorsNameAnOriginalTheyJustStranded() async throws {
        try await withEditor(seedBlocks: ["First half. Second half.", "Beta two."]) { editor in
            let blockID = try #require(editor.model.slots.first?.blockID)
            let variantID = try #require(editor.model.slots.first?.variantID)
            let w = try await editor.session.runner.run { ops -> Operations.DivideWResult in
                _ = try ops.branchVariant(blockID, from: variantID)
                return try ops.divideW(blockID, cuts: [variantID: 12])
            }
            try editor.reload()

            // WRITE's compound: both successors picked, one gesture.
            for successor in [w.first.block.id, w.second.block.id] {
                let i = try #require(
                    editor.model.index.entries.firstIndex { $0.blockID == successor })
                #expect(editor.model.pickBlock(
                    atOffset: editor.model.index.range(ofEntryAt: i).location,
                    extending: false))
            }
            await editor.model.deleteSelectedBlocks()
            await editor.flush()
            let written = try #require(editor.model.statusMessage)
            #expect(written.hasPrefix(BlockSelectionCopy.deletedNote(2)))
            #expect(written.hasSuffix(BlockSelectionCopy.strandedOriginalNote(1)),
                    "the receipt names the original it just put on the clock: \(written)")

            // THE BOARD's compound: the same act, the same sentence. Put the
            // pair back first so the board has the same world to delete.
            try await editor.session.runner.run { (ops: Operations) in
                _ = try ops.restoreBlock(w.first.block.id)
                _ = try ops.restoreBlock(w.second.block.id)
            }
            let takes = TakesViewModel(session: editor.session, postID: editor.postID)
            takes.adopt(try await editor.database.read { [postID = editor.postID] db in
                try Queries.takesProjection(db, post: postID)
            })
            takes.toggleMergeSelection(w.first.block.id)
            takes.toggleMergeSelection(w.second.block.id)
            await takes.deleteSelectedBlocks()
            let spoken = try #require(takes.statusMessage)
            #expect(spoken.hasPrefix(BlockSelectionCopy.deletedNote(2)))
            #expect(spoken.hasSuffix(BlockSelectionCopy.strandedOriginalNote(1)),
                    "…and the board's door says the same thing: \(spoken)")
        }
    }

    // MARK: - The riders

    /// **R2-N2 absorbed** (LADDER A round 2): the always-mounted past section
    /// is zero-size on the common case, and the sheet's `spacing: 8` was
    /// paying for it twice. The decision is a value, so it can be held
    /// without measuring SwiftUI.
    @Test func theHistorySheetStopsPayingForAnEmptyPastSection() {
        #expect(TakesBottomBar.pastSectionTopPadding(pastEmpty: true) == -8,
                "one stack gap cancelled — the doubled 16 pt space is gone")
        #expect(TakesBottomBar.pastSectionTopPadding(pastEmpty: false) == 0,
                "…and a section with content keeps the sheet's own spacing")
    }

    /// **The enum-dump straggler, worded** (the round-1 sanity pass's routed
    /// observation): `noRenderableVariant` is reachable through every
    /// structural door on a gap slot, and spoke "Refused: <enum>".
    @Test func theGapSlotRefusalSpeaksInsteadOfDumpingItsEnum() {
        let message = OpsRefusalCopy.message(
            for: OperationError.noRenderableVariant(blockID: "b1"))
        #expect(!message.contains("noRenderableVariant"), "no raw dump: \(message)")
        #expect(!message.contains("Refused:"))
        #expect(message.contains("no text here yet"))
    }
}
