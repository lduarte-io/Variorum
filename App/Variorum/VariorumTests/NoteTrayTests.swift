//
//  NoteTrayTests.swift
//  VariorumTests
//
//  Phase 13j, batch 2 — the per-note TRAY (J2), the graveyard's removal
//  (J6), and the receipt's graduation (J8(a)).
//
//  Her founding report: *"you need to be able to see the archived blocks (or
//  deleted blocks) that are associated with a particular post, because just
//  going to the library you get a little lost."*
//
//  What this suite holds, in the brief's own order: the badge rule (deleted
//  only, away at zero), the two-section split, both Put backs round-tripping
//  to their REAL landings, the sealed diagnosis, and the graduated receipt —
//  plus the one thing the removal makes assertable, that no shipped copy
//  still points at the room J6 took away.
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The note's tray (13j J2/J6/J8a)")
struct NoteTrayTests {
    /// The two listings, read straight — what the panel's observation
    /// delivers, without the observation's timing.
    private static func snapshot(_ editor: EditorHarness) throws -> TrayViewModel.Snapshot {
        let postID = editor.postID
        return try editor.database.read { db -> TrayViewModel.Snapshot in
            TrayViewModel.Snapshot(
                deleted: try Queries.trayBlocks(db, postID: postID),
                originals: try Queries.preservedOriginals(db, postID: postID))
        }
    }

    // MARK: - The badge (her round-1 + round-5 rulings)

    /// **The count is DELETED-only, and the door is away at zero.** Round 5,
    /// stated: preserved originals show in the panel but must never inflate
    /// an urgent-looking number; round 1: the badge is visible ONLY when the
    /// note has deleted something.
    @Test func theBadgeCountsDeletedOnlyAndHidesWhenThereAreNone() {
        func bar(deleted: Int, preserved: Int) -> ContextBar {
            ContextBar(
                tokens: .fallback(for: .light), originLabel: nil, forwardLabel: nil,
                books: [],
                tagFace: ContextBar.TagFace(
                    tags: [], allTags: [], onApply: { _ in }, onRemove: { _ in }),
                tagsFolded: false,
                trayFace: ContextBar.TrayFace(
                    deletedCount: deleted, preservedCount: preserved, onOpen: {}),
                onBack: {}, onForward: {}, onOpenBook: { _ in }, onToggleTags: {})
        }
        #expect(!bar(deleted: 0, preserved: 0).trayDoorShown)
        // Even with originals waiting: the panel has them, the badge does not
        // claim them (the note-menu door is how she reaches those).
        #expect(!bar(deleted: 0, preserved: 3).trayDoorShown)
        #expect(bar(deleted: 1, preserved: 0).trayDoorShown)
        #expect(bar(deleted: 2, preserved: 5).trayDoorShown)
        #expect(TrayPath.doorLabel(deleted: 2) == "\(TrayPath.doorGlyph) 2",
                "the glyph and the DELETED count, nothing else")
    }

    /// K11's constant icon row is untouched by the new door — the four
    /// aiming targets stay a fixed cluster, which is her stated reason for
    /// the ruling. The tray badge rides after them.
    @Test func theFourConstantIconsAreUnchangedByTheTrayDoor() {
        #expect(ContextBarDoors.iconRow(isNote: true) == [.back, .book, .tags, .forward])
        #expect(ContextBarDoors.iconRow(isNote: false) == [.back, .forward])
        #expect(ContextBarDoors.Icon.allCases.count == 4)
    }

    /// The tooltip names both counts, because the glyph can name neither —
    /// and a badge reading "3" over a four-row panel would read as a
    /// miscount.
    @Test func theBadgeTooltipNamesBothCountsHonestly() {
        let onlyDeleted = WorkspaceNaming.trayDoorHelp(deleted: 1, preserved: 0)
        #expect(onlyDeleted.contains("1 block deleted"))
        #expect(!onlyDeleted.contains("original"), "nothing to mention: \(onlyDeleted)")
        let both = WorkspaceNaming.trayDoorHelp(deleted: 3, preserved: 1)
        #expect(both.contains("3 blocks deleted"))
        #expect(both.contains("1 original"))
        #expect(WorkspaceNaming.trayDoorHelp(deleted: 2, preserved: 2)
            .contains("2 originals"), "plural stays plural")
    }

    // MARK: - The registry: ONE act, TWO doors (P-1)

    @Test func theTrayIsDeclaredOnceWithBothItsDoors() {
        let act = CapabilityRegistry.capability(.showNoteTray)
        #expect(act.verb == TrayPath.menuLabel)
        #expect(act.scope == .post)
        #expect(act.doors == [.surface, .bottomBar],
                "the context bar's badge and the note ▾ item — declared together")
        #expect(act.takesAccess == .native, "R118: not a Write privilege")
        // Acts wherever a note is on screen; honestly grey at a place.
        #expect(CapabilityRegistry.availability(
            .showNoteTray, in: CapabilityContext(mode: .write)) == .act)
        #expect(CapabilityRegistry.availability(
            .showNoteTray, in: CapabilityContext(mode: .takes)) == .act)
        #expect(CapabilityRegistry.availability(
            .showNoteTray,
            in: CapabilityContext(writeEditorAttached: true)) == .act,
            "the book-inline / pool editors carry no mode and still hold a note")
        #expect(!CapabilityRegistry.isEnabled(
            .showNoteTray, in: CapabilityContext(mode: nil)))
        // Both renderers name it (the walk asserts the rest).
        #expect(ContextBar.surfaceCapabilities.contains(.showNoteTray))
        #expect(CommitBar.renderedCapabilities.contains(.showNoteTray))
        #expect(TakesBottomBar.renderedCapabilities.contains(.showNoteTray))
    }

    /// The named door is the one that is ALWAYS there — a badge that hides
    /// at zero cannot be the only way in, which is the whole reason the act
    /// carries two doors.
    @Test func theNoteMenuDoorRaisesTheTrayForThisNote() async throws {
        try await withEditor(seedBlocks: ["Alpha."]) { editor in
            #expect(editor.model.trayRequest == nil)
            editor.model.requestNoteTray()
            let request = try #require(editor.model.trayRequest)
            #expect(request.postID == editor.postID)
            #expect(request.revealBlockID == nil, "no reveal — she just opened it")
        }
    }

    // MARK: - The two sections

    /// The panel splits what it is handed exactly as her round-2 ruling
    /// asked: deleted blocks and preserved originals, visibly apart.
    @Test func theTraySplitsDeletedFromPreservedOriginals() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Beta one."]) { editor in
            let ops = editor.session.operations
            let slot = try #require(try editor.storeSlots().first)
            let chosen = try #require(slot.variantID)
            let take2 = try ops.branchVariant(slot.blockID, from: chosen)
            try ops.autosave(take2.id, text: "Alpha two. Beta two.", charDelta: 0)
            _ = try ops.divideW(slot.blockID, cuts: [chosen: 10, take2.id: 10])
            let extra = try ops.newBlock(in: editor.postID, text: "Doomed.")
            try ops.deleteBlock(extra.block.id)

            let model = TrayViewModel(session: editor.session, postID: editor.postID)
            model.adopt(try Self.snapshot(editor))
            #expect(model.deleted.map(\.blockID) == [extra.block.id])
            #expect(model.originals.map(\.blockID) == [slot.blockID])
            #expect(!model.isEmpty)
        }
    }

    /// **The VERIFIED section name.** No shipped operation writes
    /// `block.archived_at` — there is no `archiveBlock` anywhere — so the
    /// first section says "Deleted" rather than the sitting's provisional
    /// "Deleted & archived". Naming a state the product cannot produce is
    /// the same defect as naming a door that does not exist.
    @Test func theDeletedSectionDoesNotClaimAnArchivedStateNothingProduces() {
        #expect(TrayPath.deletedSection == "Deleted")
        #expect(!TrayPath.deletedSection.lowercased().contains("archiv"))
    }

    // MARK: - Put back

    /// **The deleted block's landing — MOVED by a ruling, not a bug fix.**
    ///
    /// Batch 2 verified and pinned the shipped behaviour: `restoreBlock` left
    /// the old placement row tombstoned and minted a FRESH one at the note's
    /// end, so Put back and ⌥⌘Z landed a block in two different places, and
    /// this row's receipt had to say "at the end". The architect's F2 ruling
    /// (batch 3; PROVISIONAL, her ratify at QUESTIONS #67 F2) aligned the op
    /// to the restore family's exact-row religion — so the block comes back
    /// WHERE IT WAS and the receipt says that. The op's own answer drives the
    /// receipt, which is what keeps the fallback honest (next arm).
    @Test func putBackReturnsADeletedBlockToItsOwnPlace() async throws {
        try await withEditor(seedBlocks: ["First.", "Second.", "Third."]) { editor in
            let slots = try editor.storeSlots()
            let middle = slots[1].blockID
            try editor.session.operations.deleteBlock(middle)
            #expect(try editor.storeSlots().map(\.blockID) == [slots[0].blockID, slots[2].blockID])

            let model = TrayViewModel(session: editor.session, postID: editor.postID)
            await model.putBackDeleted(middle)
            #expect(model.statusMessage == TrayPath.putBackWhereItWas)
            #expect(try editor.storeSlots().map(\.blockID)
                == [slots[0].blockID, middle, slots[2].blockID],
                "between its neighbours, on its own revived placement row")
            #expect(try editor.storeSlots().map(\.text)
                == ["First.", "Second.", "Third."])
        }
    }

    /// …and the FALLBACK's receipt is still true: a released original that
    /// was deleted later has no placement row carrying its tombstone, so it
    /// lands at the end and the row says so rather than promising a place it
    /// cannot reach.
    @Test func putBackSaysAtTheEndWhenNoOldPlaceCanRevive() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Beta one.", "Tail."]) { editor in
            let ops = editor.session.operations
            let slot = try #require(try editor.storeSlots().first)
            let chosen = try #require(slot.variantID)
            let take2 = try ops.branchVariant(slot.blockID, from: chosen)
            try ops.autosave(take2.id, text: "Alpha two. Beta two.", charDelta: 0)
            _ = try ops.divideW(slot.blockID, cuts: [chosen: 10, take2.id: 10])
            try ops.deleteBlock(slot.blockID)

            let model = TrayViewModel(session: editor.session, postID: editor.postID)
            await model.putBackDeleted(slot.blockID)
            #expect(model.statusMessage == TrayPath.putBackAtEnd)
            #expect(try editor.storeSlots().map(\.blockID).last == slot.blockID)
        }
    }

    /// **The preserved original's landing** — composed at the face over
    /// `placeBlock` (the W-reversal road; no operation's semantics change):
    /// immediately after its LAST live successor in this note.
    @Test func putBackReturnsAPreservedOriginalBesideItsSuccessors() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Beta one.", "Tail."]) { editor in
            let ops = editor.session.operations
            let slot = try #require(try editor.storeSlots().first)
            let chosen = try #require(slot.variantID)
            let take2 = try ops.branchVariant(slot.blockID, from: chosen)
            try ops.autosave(take2.id, text: "Alpha two. Beta two.", charDelta: 0)
            let w = try ops.divideW(slot.blockID, cuts: [chosen: 10, take2.id: 10])
            let tail = try #require(try editor.storeSlots().last).blockID

            let model = TrayViewModel(session: editor.session, postID: editor.postID)
            await model.putBackOriginal(slot.blockID)
            #expect(model.statusMessage == "Put back where it came from.")
            #expect(try editor.storeSlots().map(\.blockID)
                == [w.first.block.id, w.second.block.id, slot.blockID, tail],
                "after C, the last live successor — not at the note's end")
        }
    }

    /// …and at the note's end when no successor survives (the case round 2
    /// named as the global listing's only unique one).
    @Test func putBackLandsAtTheEndWhenNoSuccessorSurvives() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Beta one.", "Tail."]) { editor in
            let ops = editor.session.operations
            let slot = try #require(try editor.storeSlots().first)
            let chosen = try #require(slot.variantID)
            let take2 = try ops.branchVariant(slot.blockID, from: chosen)
            try ops.autosave(take2.id, text: "Alpha two. Beta two.", charDelta: 0)
            let w = try ops.divideW(slot.blockID, cuts: [chosen: 10, take2.id: 10])
            try ops.deleteBlock(w.first.block.id)
            try ops.deleteBlock(w.second.block.id)
            let tail = try #require(try editor.storeSlots().last).blockID

            let model = TrayViewModel(session: editor.session, postID: editor.postID)
            await model.putBackOriginal(slot.blockID)
            #expect(model.statusMessage == "Put back at the end of this note.")
            #expect(try editor.storeSlots().map(\.blockID) == [tail, slot.blockID])
        }
    }

    /// **The seal DIAGNOSES** (the J8 doctrine, P-2): the tray still reads
    /// freely, and Put back answers with the way out rather than a raw enum.
    @Test func putBackUnderASealedNoteDiagnosesInsteadOfDumpingTheEnum() async throws {
        try await withEditor(seedBlocks: ["First.", "Second."]) { editor in
            let ops = editor.session.operations
            let doomed = try #require(try editor.storeSlots().last).blockID
            try ops.deleteBlock(doomed)
            try ops.lockPost(editor.postID)

            let model = TrayViewModel(session: editor.session, postID: editor.postID)
            // Reading is free — the listing loads under the seal.
            model.adopt(try Self.snapshot(editor))
            #expect(model.deleted.map(\.blockID) == [doomed])

            await model.putBackDeleted(doomed)
            #expect(model.statusMessage == TrayRefusalCopy.sealed)
            #expect(model.statusMessage?.contains("unseal") == true,
                    "a diagnosis names the way out")
            #expect(try editor.storeSlots().count == 1, "nothing moved")
        }
    }

    // MARK: - J8(a): the receipt GRADUATES

    /// Batch 1 withdrew the tray promise because the tray had no door.
    /// Batch 2 built the door, so the promise returns — naming BOTH roads,
    /// since ⌥⌘Z dies with the session and the tray does not.
    @Test func theDeleteReceiptNamesTheRealTrayAndItsRealDoor() {
        for line in [BlockSelectionCopy.deletedNote(1),
                     BlockSelectionCopy.deletedNote(4),
                     BlockSelectionCopy.deleteHelp] {
            #expect(line.contains(TrayPath.menuLabel),
                    "the tray EXISTS now and the copy names it: \(line)")
        }
        // …and the receipts teach the door, not just the place.
        #expect(BlockSelectionCopy.deletedNote(1).contains(TrayPath.doorPhrase))
        #expect(BlockSelectionCopy.deletedNote(4).contains(TrayPath.doorPhrase))
        // The immediate road survives the graduation, plural intact.
        #expect(BlockSelectionCopy.deletedNote(1).contains("\u{2325}\u{2318}Z"))
        #expect(BlockSelectionCopy.deletedNote(4).contains("in one go"))
        // The named door is a REAL, declared one.
        #expect(CapabilityRegistry.capability(.showNoteTray).verb == TrayPath.menuLabel)
        #expect(TrayPath.doorPhrase.contains(TrayPath.doorGlyph))
    }

    /// One receipt, every delete door — still true after the graduation
    /// (batch 1 collapsed the three hand-written copies into one).
    @Test func everyDeleteDoorStillSpeaksTheOneGraduatedReceipt() async throws {
        try await withEditor(seedBlocks: ["Alpha one.", "Beta two."]) { harness in
            harness.textView.setSelectedRange(NSRange(location: 0, length: 0))
            harness.model.updateCaretContext()
            await harness.model.deleteCaretBlock()
            await harness.flush()
            #expect(harness.model.statusMessage == BlockSelectionCopy.deletedNote(1))
            #expect(harness.model.statusMessage?.contains(TrayPath.menuLabel) == true)
        }
    }

    // MARK: - J6: the graveyard is gone, and nothing points at it

    /// The removal's assertable half: no shipped copy constant names the
    /// listing her round-2 ruling took away, and the ceremony/merge/helper
    /// sentences that used to point there now point at the tray.
    @Test func noShippedCopyStillPointsAtTheRemovedUnplacedListing() {
        let lines = [
            DivideWCeremony.checklistExplainer,
            DivideWCeremony.uncheckedRowNote,
            DivideWCeremony.releasedOriginalNote(uncheckedTakes: 2) ?? "",
            CapabilityRegistry.capability(.showOriginBlock).unavailableNote,
            HelperCheatSheet.summary,
        ]
        for line in lines {
            #expect(!line.lowercased().contains("unplaced"),
                    "the room is gone; this sentence must not name it: \(line)")
        }
        // …and the two that TEACH the road name the tray AND its door.
        #expect(DivideWCeremony.checklistExplainer.contains(TrayPath.doorPhrase))
        #expect(CapabilityRegistry.capability(.showOriginBlock)
            .unavailableNote.contains(TrayPath.menuLabel))
    }

    /// The QUERY survives the room (the sitting's words: a debug query, not
    /// a room in the house) — so a future safety net has something to read,
    /// and its removal would be a deliberate act rather than a side effect.
    @Test func theUnplacedQuerySurvivesAsTheDeveloperSafetyNet() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Beta one."]) { editor in
            let ops = editor.session.operations
            let slot = try #require(try editor.storeSlots().first)
            let chosen = try #require(slot.variantID)
            let take2 = try ops.branchVariant(slot.blockID, from: chosen)
            try ops.autosave(take2.id, text: "Alpha two. Beta two.", charDelta: 0)
            _ = try ops.divideW(slot.blockID, cuts: [chosen: 10, take2.id: 10])
            let unplaced = try editor.database.read { try Queries.unplacedBlocks($0) }
            #expect(unplaced.map(\.blockID) == [slot.blockID])
        }
    }

    // MARK: - The row's two pure derivations

    @Test func aRowShowsOneLineAndAnHonestStamp() {
        #expect(TrayRowPreview.line("First line.\nSecond line.") == "First line.")
        #expect(TrayRowPreview.line(nil) == "(empty block)")
        #expect(TrayRowPreview.line("") == "(empty block)")
        #expect(TrayRowPreview.line("   \nreal") == "(empty block)",
                "a whitespace-only first line is not an identity")
        #expect(TrayRowPreview.line(String(repeating: "x", count: 200), limit: 10)
            == String(repeating: "x", count: 10) + "\u{2026}")
        // The stamp reads through the ONE canonical parser, and unparseable
        // text renders nothing rather than raw ISO.
        let stamp = DateFormatter.variorumISO8601.string(
            from: Date(timeIntervalSince1970: 1_782_864_000))
        #expect(TrayRowPreview.stampText(stamp, verb: "deleted")?.hasPrefix("deleted ") == true)
        #expect(TrayRowPreview.stampText("not a date", verb: "deleted") == nil)
    }

    // MARK: - The visual loop
    //
    // **The PANEL cannot be captured offscreen — measured, not assumed.**
    // A capture arm was written against the 13k `ContextBarCaptureTests`
    // pattern and rendered the unsupported-view placeholder: SwiftUI `List`
    // is NSTableView-backed, and `ImageRenderer` will not draw one. Recorded
    // here in the same register that harness uses for the book dropdown's
    // popover, so nobody re-derives it: the panel is a HAND-CHECK item.
    //
    // The BADGE renders fine and is captured — `ContextBarCaptureTests`
    // states 7 and 8, beside states 1–6 which all carry an empty tray and so
    // are byte-unchanged. That pair is the picture her round-1 ruling asks
    // for: calm at rest, one quiet ⌫ N once the note has deleted something.

    /// The reveal's honest miss: a block the note's tray does not hold says
    /// so in one quiet line rather than marking nothing in silence.
    @Test func aRevealForABlockThisTrayDoesNotHoldSaysSo() async throws {
        try await withEditor(seedBlocks: ["Alpha."]) { editor in
            let model = TrayViewModel(
                session: editor.session, postID: editor.postID,
                revealBlockID: "somewhere-else")
            #expect(!model.revealMissing, "nothing is missing until the listing loads")
            model.adopt(TrayViewModel.Snapshot())
            #expect(model.revealMissing)

            let present = TrayViewModel(
                session: editor.session, postID: editor.postID, revealBlockID: "b1")
            present.adopt(TrayViewModel.Snapshot(
                deleted: [Queries.TrayItem(blockID: "b1", deletedAt: "x", text: "t")]))
            #expect(!present.revealMissing)
        }
    }
}
