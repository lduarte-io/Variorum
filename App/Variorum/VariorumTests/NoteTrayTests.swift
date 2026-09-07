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
                deleted: try Queries.trayBlocks(db, postID: postID, now: harnessNow),
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
                books: [], isNote: true,
                // (Ladder B round-1 residuals, item 1 — annotated pin
                // edit: TrayFace dropped preservedCount with the tooltip's
                // originals clause; `preserved` stays a parameter here so
                // the CLAIM — the badge is deleted-only whatever originals
                // exist — keeps its two-axis matrix.)
                trayFace: ContextBar.TrayFace(
                    deletedCount: deleted, onOpen: {}),
                onBack: {}, onForward: {}, onOpenBook: { _ in })
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

    /// K11's constant icon row is untouched by the new door — the aiming
    /// targets stay a fixed cluster, which is her stated reason for the
    /// ruling. The tray badge rides after them. *(Three doors since Act 10
    /// item 5 moved the ＃ to the masthead cluster.)*
    @Test func theConstantIconsAreUnchangedByTheTrayDoor() {
        #expect(ContextBarDoors.iconRow(isNote: true) == [.back, .book, .forward])
        #expect(ContextBarDoors.iconRow(isNote: false) == [.back, .forward])
        #expect(ContextBarDoors.Icon.allCases.count == 3)
    }

    /// The tooltip names the ONE number the badge shows — deleted blocks.
    ///
    /// **GRADUATED (13j ladder B round-1 residuals, item 1 — a RULED
    /// change, never a quietly relaxed pin):** the old claim asserted the
    /// "plus N originals" clause. That count came from the fate-blind
    /// `trayCounts`, so a `.gone` original (family expired or Delete Now
    /// named it) still counted — a number the panel truthfully does not
    /// show, under the exact "put any of them back" promise the B5 call
    /// ruled out. The clause is gone; this pin now asserts its ABSENCE at
    /// every count, which is what makes it red if the clause ever
    /// returns without a fate-aware source.
    @Test func theBadgeTooltipNamesTheDeletedCountAndNeverOriginals() {
        let one = WorkspaceNaming.trayDoorHelp(deleted: 1)
        #expect(one.contains("1 block deleted"))
        #expect(one.contains("put any of them back"))
        let three = WorkspaceNaming.trayDoorHelp(deleted: 3)
        #expect(three.contains("3 blocks deleted"), "plural stays plural")
        for help in [one, three] {
            #expect(!help.contains("original"),
                    "the tooltip may not promise a fate it cannot see: \(help)")
        }
    }

    // MARK: - The registry: ONE act, its doors (P-1)

    /// **GRADUATED at the post-13l polish round, batch 3 (a JUSTIFIED PIN
    /// EDIT — the ruled change IS the behaviour change).** Her C1 ruling:
    /// *"the note tray should move to being an icon next to the scraps and
    /// reference icon and open in the side bar"*, and *"the note ▾ menu item
    /// and ⌫ badge choreography follow the move"*. So the `.bottomBar` door
    /// is GONE and the act is `.surface`-only, with three renderers instead
    /// of two. The pin's own claim is unchanged and is checked at the same
    /// strength: one act, declared once, every renderer naming it.
    @Test func theTrayIsDeclaredOnceWithAllItsDoors() {
        let act = CapabilityRegistry.capability(.showNoteTray)
        #expect(act.verb == TrayPath.menuLabel)
        #expect(act.scope == .post)
        // The masthead icon, the ⌫ badge and the scraps area's own — all
        // surfaces; the `note ▾` item moved with the panel. **A JUSTIFIED
        // EDIT** (the post-13l polish round, the architect's adjudication 1):
        // ⌘K joins them, because a book spread's inline note mounts an editor
        // with no masthead and no context bar — the one place the tray was
        // unreachable, named as batch 3's own discoverability cost.
        #expect(act.doors == [.surface, .palette])
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
        // Every renderer names it (the walk asserts the rest).
        #expect(PostDetailView.surfaceCapabilities.contains(.showNoteTray))
        #expect(ContextBar.surfaceCapabilities.contains(.showNoteTray))
        #expect(PoolDetailView.surfaceCapabilities.contains(.showNoteTray))
        #expect(!CommitBar.renderedCapabilities.contains(.showNoteTray))
        #expect(!TakesBottomBar.renderedCapabilities.contains(.showNoteTray))
    }

    /// **The FALLBACK road, and why it is not vestigial** (graduated at the
    /// post-13l polish round, batch 3).
    ///
    /// The tray's home is the post detail's side panel now, so a door asks
    /// the router first. This editor, though, is also composed where there is
    /// no post detail and therefore no inspector — the scraps editor's own
    /// hosts and the book-inline form — and a door that could not act in
    /// those contexts would be a door that should not have been rendered
    /// (P-2). So with no detail registered the request still lands: the
    /// model's own sheet. The panel road is pinned over the REAL mounted
    /// surface in `TrayPanelMoveTests`.
    @Test func aTrayDoorWithNoSidePanelToOpenFallsBackToItsOwnSheet() async throws {
        try await withEditor(seedBlocks: ["Alpha."]) { editor in
            #expect(editor.model.trayRequest == nil)
            #expect(editor.session.commandRouter.activePostID == nil,
                    "no post detail is mounted in this harness")
            editor.model.requestNoteTray()
            let request = try #require(editor.model.trayRequest)
            #expect(request.postID == editor.postID)
            #expect(request.revealBlockID == nil, "no reveal — she just opened it")
        }
    }

    // MARK: - The two sections

    /// **GRADUATED, and the graduation IS her G5 ruling** (the post-13l
    /// polish round, ledger row 20): her round-2 split put deleted blocks and
    /// preserved originals in two visible sections of this panel; her G5
    /// ruling moved the UNCLOCKED originals out entirely — *"the tray audits
    /// what is LEAVING; lineage holds what is KEPT"* — so what this pin
    /// asserts now is that the tray shows the deletion and does NOT show an
    /// original that is not going anywhere. The original's own home is the
    /// Block History pane's came-from, pinned in `RecoveryDoorsTests`.
    @Test func theTrayListsWhatIsLeavingAndNotAnOriginalThatIsKept() async throws {
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
            #expect(model.stranded.isEmpty,
                    "the original's family is alive, so it is not on any clock")
            #expect(!model.isEmpty)
            // The original really EXISTS and is really unplaced — it simply
            // is not this panel's to list any more.
            let origins = try await editor.database.read {
                [blockID = try editor.storeSlots()[0].blockID] db in
                try Queries.unplacedOrigins(db, ofBlock: blockID)
            }
            #expect(origins.map(\.blockID) == [slot.blockID])
        }
    }

    /// **The section names, GRADUATED TWICE — the same claim, the next side
    /// of a ruling** (13j batch 6, then the post-13l polish round's row 20).
    ///
    /// Batch 2 verified that NO shipped operation wrote `block.archived_at`
    /// and named the section "Deleted" for it: naming a state the product
    /// cannot produce is the same defect as naming a door that does not
    /// exist. Her round-7 ruling BUILT the state (`archiveBlock`), so the
    /// name her round-2 ruling wanted came back with it — as ONE header,
    /// *"Deleted & archived"*, holding a forever-list and a countdown
    /// together. Her G5 ruling splits them, for the reason her B2 ruling gave
    /// one level up (*"separating archive and trash more makes sense"*), and
    /// the pin keeps its claim in the stronger form: each heading may name
    /// only what its own section can hold, and the clock is what tells them
    /// apart.
    @Test func theTraysSectionsNameOnlyStatesTheProductCanProduce() {
        #expect(TrayPath.archivedSection.contains("no clock"),
                "the forever section says so in its own header")
        #expect(TrayPath.leavingSection.contains("\(TrashWindow.days)-day"),
                "and the other one wears the clock")
        #expect(!TrayPath.archivedSection.lowercased().contains("delet"),
                "the two states never share a header again")
        // The archived state is real: the act is declared with its doors, and
        // the tray has a listing to put an archived block in.
        #expect(CapabilityRegistry.capability(.archiveBlock).verb == "Archive Block")
        #expect(TrayPath.archivedForever.contains("no clock"),
                "…and the row says what makes it different from a deleted one")
        // The leaving section says what it is FOR — her "never a surprise".
        for word in ["blocks", "takes", "originals"] {
            #expect(TrayPath.leavingExplainer.lowercased().contains(word),
                    "the explainer names every population it holds: \(word)")
        }
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
            // 13l row 26 (a JUSTIFIED and STRENGTHENING pin edit): the
            // sentence now names what it landed IN, so this asserts the home
            // kind as well as the landing. A note's tray still says "note".
            #expect(model.statusMessage == TrayPath.putBackAtEnd(.post))
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
        // **GRADUATED at the post-13l polish round, batch 3** (a justified
        // pin edit, and the claim gets STRONGER): this asserted the phrase
        // named the ⌫ BADGE's glyph. Her C1 ruling made the masthead icon the
        // named door, and the badge is deleted-only by her #67(a) ruling — so
        // a receipt pointing at the badge can point at a door that is not on
        // screen. What the pin holds now is the property that mattered all
        // along: the phrase names a door that is ALWAYS there.
        #expect(!TrayPath.doorPhrase.contains(TrayPath.doorGlyph),
                "never the badge — it hides at zero")
        #expect(TrayPath.doorPhrase == TrayPath.doorPhrase(for: .post))
        #expect(TrayPath.doorPhrase.contains("icon"))
        #expect(PostDetailView.inspectorDoors.contains { $0.panel.isTray },
                "…and that icon is really rendered, from the masthead's table")
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
            // 18f ladder R1-4: the unchecked take's caption lives on the card.
            CeremonyCardCopy.status(.original, words: nil),
            DivideWCeremony.releasedOriginalNote(uncheckedTakes: 2) ?? "",
            CapabilityRegistry.capability(.showOriginBlock).unavailableNote,
            HelperCheatSheet.summary,
        ]
        for line in lines {
            #expect(!line.lowercased().contains("unplaced"),
                    "the room is gone; this sentence must not name it: \(line)")
        }
        // …and the two that TEACH the road name the place AND its door.
        // **A JUSTIFIED EDIT** (the post-13l polish round, ledger row 17):
        // the DESTINATION moved — her G5 ruling puts an unclocked original in
        // lineage, not the tray — so the ceremony's explainer names the Block
        // History pane and its door instead. The claim is what it always was:
        // a sentence that teaches a road names a place that exists and the
        // way into it.
        #expect(DivideWCeremony.checklistExplainer
            .contains(BlockHistoryPath.doorPhrase))
        #expect(DivideWCeremony.checklistExplainer.contains(BlockHistoryPath.name))
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

    /// **Row 68 (the Act 10 correction round): the reveal that names a KEPT
    /// original.** The Came-from region's "Open this note's tray" on an
    /// UNCLOCKED origin landed with no mark and no sentence — the origin is
    /// deliberately not listed (G5 moved what is KEPT to lineage), and
    /// `revealMissing` is deliberately false (the row exists). The third
    /// arrival state says where the block actually lives. Driven through the
    /// REAL store: a merge releases both sources whole, and the reveal names
    /// one while its family is alive (nothing counting).
    ///
    /// **RED ON OLD** by behavioural revert (drop the `revealKeptInLineage`
    /// latch assignment): the walked silence comes back — no missing line,
    /// no lineage line, nothing marked.
    @Test func aRevealForAKeptOriginalSaysItLivesInLineage() async throws {
        try await withEditor(seedBlocks: ["First half.", "Second half."]) { editor in
            let ops = editor.session.operations
            let slots = try editor.storeSlots()
            _ = try ops.merge(slots[0].blockID, slots[1].blockID)

            let now = editor.session.now
            let snapshot = try await editor.session.database.read {
                db -> TrayViewModel.Snapshot in
                TrayViewModel.Snapshot(
                    deleted: try Queries.trayBlocks(db, postID: editor.postID, now: now),
                    archived: try Queries.archivedBlocks(db, postID: editor.postID),
                    originals: try Queries.preservedOriginals(db, postID: editor.postID),
                    strandedFates: try Queries.originFamilyClocks(
                        db, postID: editor.postID, now: now),
                    takes: try Queries.trayTakes(db, postID: editor.postID, now: now))
            }
            let revealed = try #require(snapshot.originals.first?.blockID)

            let model = TrayViewModel(
                session: editor.session, postID: editor.postID,
                revealBlockID: revealed)
            model.adopt(snapshot)
            #expect(!model.revealMissing,
                    "the row exists — 'it isn't here' would be the arrival-time lie")
            #expect(model.revealKeptInLineage,
                    "the third state: kept whole, living under Came from")
            #expect(model.stranded.isEmpty, "nothing is counting — the family is alive")
            #expect(!RecoveryCopy.trayRevealKeptInLineage(.post).isEmpty)
        }
    }

    // MARK: - The post-13l polish round (ledger rows 1 and 6)

    /// **ROW 1 (her A1 ruling on the walk's P-4).** A successful Put back
    /// from a REVEALED row was followed by *"The block you asked to see isn't
    /// in this note's tray."* — because by then it was true: the row had left
    /// the tray by succeeding. Her word: *"that just seems sloppy, it should
    /// show a success message if anything."*
    ///
    /// The line is an ARRIVAL-time explanation ("why is nothing marked when I
    /// got here?"), so it is decided on the first loaded listing and never
    /// revisited. This drives the exact sequence the walk did: arrive with the
    /// row present (nothing missing), then let the listing lose it — which is
    /// what a successful Put back produces — and the explanation must stay
    /// off, leaving the receipt standing alone.
    ///
    /// **RED ON OLD** by behavioural revert (restore the computed
    /// `revealMissing`): this reds on the second `#expect`, reading back the
    /// stale not-found line under a success.
    @Test func aRevealThatSucceedsIsNotFollowedByTheNotFoundLine() async throws {
        try await withEditor(seedBlocks: ["Alpha."]) { editor in
            let model = TrayViewModel(
                session: editor.session, postID: editor.postID, revealBlockID: "b1")
            model.adopt(TrayViewModel.Snapshot(
                deleted: [Queries.TrayItem(blockID: "b1", deletedAt: "x", text: "t")]))
            #expect(!model.revealMissing, "it is right there — nothing to explain")

            // The listing after a successful Put back: the row is gone
            // BECAUSE the act worked.
            model.adopt(TrayViewModel.Snapshot())
            #expect(!model.revealMissing,
                    "a row that left by SUCCEEDING is not a row she could not find")
        }
    }

    /// **ROW 6 (her A6 ruling on the walk's P-5(a): *"the color: should be
    /// fixed"*).** The panel painted its one status slot red for every
    /// message class, so the receipt that IS the surface's whole point read
    /// as an error. The class is decided where the message is produced —
    /// a landing is a receipt, a refusal is a refusal — and the view colours
    /// from the class.
    ///
    /// **RED ON OLD** by behavioural revert (have the three put-back doors
    /// set `.refusal(…)` on success, which is the pre-fix single red slot):
    /// this reds on the first `#expect`, reading back a success classed as an
    /// error.
    @Test func theTrayTellsAReceiptFromARefusal() async throws {
        try await withEditor(seedBlocks: ["First.", "Second."]) { editor in
            let ops = editor.session.operations
            let doomed = try #require(try editor.storeSlots().last).blockID
            try ops.deleteBlock(doomed)

            let model = TrayViewModel(session: editor.session, postID: editor.postID)
            await model.putBackDeleted(doomed)
            #expect(model.status == .receipt(TrayPath.putBackWhereItWas))
            #expect(model.status?.isRefusal == false,
                    "a success is not painted as an error")

            // …and a real refusal still reads as one, in the same slot.
            try ops.deleteBlock(doomed)
            try ops.lockPost(editor.postID)
            await model.putBackDeleted(doomed)
            #expect(model.status == .refusal(TrayRefusalCopy.sealed))
            #expect(model.status?.isRefusal == true)

            // The forwarder keeps every shipped pin riding unmodified.
            #expect(model.statusMessage == TrayRefusalCopy.sealed)
        }
    }
}
