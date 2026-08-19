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
            let clocks: [String: String] = try await editor.database.read { db in
                try Queries.originFamilyClocks(db, postID: editor.postID)
            }
            #expect(clocks[blockID] != nil)
            let stranded: [String] = try await editor.database.read { db in
                try Queries.strandedOriginals(db, now: harnessNow).map(\.id)
            }
            #expect(stranded == [blockID])
            #expect(TrayPath.goesWithItsFamily.contains("goes with its deleted blocks"))
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
