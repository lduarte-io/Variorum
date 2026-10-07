//
//  MobileBlockListTests.swift
//  VariorumMobileTests
//
//  Parity C4b item 5 — the in-note block list (her mid-chain ruling 11)
//  and block names' phone face. The rows ride `Queries.blockTOC` and the
//  ONE `tocHandle` brain (AppSpec §12's letter: the name where set, else
//  the first sentence DERIVED AT READ TIME, never stored); the tap rides
//  the VM's `jumpToBlock`.
//

import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("Mobile block list — the in-note TOC (parity C4b)")
struct MobileBlockListTests {
    /// The rows: reading order, the NAME where set, else the first
    /// sentence — and the derivation is read-time truth, never a stored
    /// copy: rename the block or edit its text and the handle follows
    /// on the next read with no row of its own anywhere.
    @Test func rowsCarryNamesElseFirstSentencesDerivedAtReadTime() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await session.runner.run { ops -> (post: String, a: String, b: String, b1: String, c: String) in
                let post = try ops.createPost(title: "toc", profile: .blog)
                let a = try ops.newBlock(
                    in: post.id, text: "The opening paragraph stands here.", at: .end)
                try ops.setBlockName(a.block.id, name: "opening")
                let b = try ops.newBlock(
                    in: post.id, text: "First sentence here. Second follows.", at: .end)
                let c = try ops.newBlock(in: post.id, text: "The fanned one.", at: .end)
                _ = try ops.branchVariant(c.block.id, from: c.variant.id)
                return (post.id, a.block.id, b.block.id, b.variant.id, c.block.id)
            }
            let model = MobileBlockListModel(session: session, postID: seed.post)
            await model.refresh()

            #expect(model.rows.map(\.blockID) == [seed.a, seed.b, seed.c])
            // The name where set…
            #expect(MobileBlockListModel.handle(model.rows[0]) == "opening")
            // …else the FIRST SENTENCE, derived (the one core brain).
            #expect(MobileBlockListModel.handle(model.rows[1]) == "First sentence here.")
            // The fan marker's truth rides the row.
            #expect(model.rows.map(\.hasFan) == [false, false, true])

            // Read-time, not stored: a rename and a text edit both land
            // in the NEXT read with no denormalized handle anywhere.
            try await session.runner.run { [a = seed.a, b1 = seed.b1] ops in
                try ops.setBlockName(a, name: nil)
                try ops.autosave(b1, text: "A rewritten start. And more.", charDelta: 5)
            }
            await model.refresh()
            #expect(MobileBlockListModel.handle(model.rows[0])
                == "The opening paragraph stands here.")
            #expect(MobileBlockListModel.handle(model.rows[1]) == "A rewritten start.")
        }
    }

    /// The tap's contract: the caret lands at the block's start and the
    /// block's first line arrives in the viewport (the hybrid-jump
    /// geometry — `.ensuresLayout` on exactly the target fragment). A
    /// block that has left the note refuses in plain words.
    @Test func aTapJumpsTheEditorToTheBlockAndADeadBlockRefuses() async throws {
        try await withEditorWorld { session, db in
            let blocks = (1...30).map { n in
                "Paragraph \(n) has enough words to take a visible line or two on the page."
            }
            let postID = try await makePost(session, blocks: blocks)
            let (model, surface) = await makeSurfaceEditor(session, postID: postID)
            surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
            surface.layoutIfNeeded()
            let view = surface.textView

            let list = MobileBlockListModel(session: session, postID: postID)
            await list.refresh()
            #expect(list.rows.count == 30)
            let target = list.rows[19]

            model.jumpToBlock(target.blockID)

            let range = try #require(model.rangeOfBlock(target.blockID))
            #expect(view.selectedRange == NSRange(location: range.location, length: 0))
            // The block's first line sits inside the visible band.
            // The door's own contract: the block's first line lands a
            // breath (24 pt) under the viewport's top edge — asserted
            // as the offset equality, which holds windowless too (the
            // headless harness gives the view no HEIGHT, so a
            // visible-band containment would read a zero viewport; the
            // pixels ride the chain-end look, the A1-masthead class).
            let geometry = try #require(view.firstLineGeometry(atOffset: range.location))
            let landingY = max(0, geometry.fragmentMinY + view.textContainerInset.top - 24)
            #expect(view.contentOffset.y > 0, "the jump scrolled at all")
            #expect(abs(view.contentOffset.y - landingY) <= 1,
                    "the block's first line sits a breath under the viewport top")

            // A dead block refuses in plain words (no platform named).
            let doomed = list.rows[0].blockID
            try await session.runner.run { ops in try ops.deleteBlock(doomed) }
            await model.refreshTakesFromStore()
            model.jumpToBlock(doomed)
            #expect(model.statusMessage == "That block is no longer in this note.")
            #expect(model.statusMessage?.contains("Mac") == false)
        }
    }

    /// The OPEN list re-reads on a delivery (parity D2 — the routed C4
    /// NIT: the sheet loaded once per presentation, so a remote divide
    /// or block arrival landing while it was open left the census one
    /// delivery stale; MobileSoul §5.3 — offline/sync races are the
    /// phone's normal). `start()` holds the observation for the
    /// sheet's life: the arrival lands in `rows` with NO refresh call.
    @Test func theOpenListReReadsOnADelivery() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await session.runner.run { ops -> String in
                let post = try ops.createPost(title: "live census", profile: .blog)
                _ = try ops.newBlock(in: post.id, text: "The first block stands.", at: .end)
                _ = try ops.newBlock(in: post.id, text: "The second block stands.", at: .end)
                return post.id
            }
            let model = MobileBlockListModel(session: session, postID: postID)
            let sheetLife = Task { await model.start() }
            defer { sheetLife.cancel() }
            await settle { model.rows.count == 2 }
            #expect(model.rows.count == 2, "the observation delivers the initial read")

            // A remote-shaped arrival while the sheet is open — through
            // ordinary operations, exactly what a sync apply produces.
            try await session.runner.run { ops in
                _ = try ops.newBlock(in: postID, text: "Arrived while open.", at: .end)
            }
            await settle { model.rows.count == 3 }
            #expect(model.rows.count == 3,
                    "the open list re-read on the delivery — no refresh call anywhere")
            #expect(model.rows.last.map(MobileBlockListModel.handle) == "Arrived while open.")
        }
    }

    /// The empty state speaks the structural doors' own standing
    /// sentence (one vocabulary for "no blocks yet"), and the chip's
    /// word is the bare voiced door (countless — recorded judgment: the
    /// list is the census).
    @Test func theEmptyStateAndChipWordAreThePinnedVocabulary() async throws {
        try await withEditorWorld { session, _ in
            let postID = try await session.runner.run { ops in
                try ops.createPost(title: "bare", profile: .blog).id
            }
            let model = MobileBlockListModel(session: session, postID: postID)
            await model.refresh()
            #expect(model.rows.isEmpty)
            #expect(MobileBlockListModel.emptyNote
                == "No blocks yet — type on the page and each finished paragraph becomes one.")
            #expect(MobileBlockListModel.chipWord == "blocks")
            #expect(!MobileBlockListModel.emptyNote.contains("Mac"))
        }
    }
}

// MARK: - PR20 — block multi-select (round 2, batch 7)

@MainActor
@Suite("Mobile block selection — pick several, delete once (batch 7 · PR20)")
struct MobileBlockSelectionTests {
    private func seedFourBlockNote(
        _ session: AppSession
    ) async throws -> (post: String, ids: [String]) {
        try await session.runner.run { ops in
            let post = try ops.createPost(title: "picks", profile: .blog)
            var ids: [String] = []
            for text in ["Alpha here.", "Beta here.", "Gamma here.", "Delta here."] {
                ids.append(try ops.newBlock(in: post.id, text: text, at: .end).block.id)
            }
            return (post.id, ids)
        }
    }

    private func liveBlockTexts(_ db: AppDatabase, post: String) async throws -> [String] {
        try await db.read { db in
            try Queries.renderPost(db, containerID: post).map { $0.text ?? "" }
        }
    }

    /// **THE PURE RULE.** Toggle, order, prune — the parts that must not
    /// exist twice, and the parts a face cannot get right on its own. P1's
    /// letter rides here too: ids, never text.
    @Test func theSelectionTogglesReadsTheNotesOrderAndPrunesGhosts() {
        var selection = MobileBlockSelection()
        #expect(selection.isEmpty)

        selection.toggle("c")
        selection.toggle("a")
        #expect(selection.count == 2)
        #expect(selection.contains("a"))

        // The NOTE's order is the only order that means anything.
        #expect(selection.inOrder(["a", "b", "c", "d"]) == ["a", "c"])
        // A pick the order does not hold never reaches an act.
        #expect(selection.inOrder(["a", "b"]) == ["a"])

        // A second toggle un-picks.
        selection.toggle("a")
        #expect(!selection.contains("a"))
        #expect(selection.count == 1)

        // Pruning drops what the world no longer holds — a selection that
        // outlives its blocks offers acts on ghosts.
        selection.toggle("d")
        selection.prune(to: ["c"])
        #expect(selection.inOrder(["a", "b", "c", "d"]) == ["c"])

        selection.clear()
        #expect(selection.isEmpty)
    }

    /// Entering picking mode changes what a row TAP MEANS, and leaving drops
    /// the picks — so a forgotten highlight never follows her around.
    @Test func pickingModeChangesWhatATapMeansAndLeavingDropsThePicks() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedFourBlockNote(session)
            let model = MobileBlockListModel(session: session, postID: seed.post)
            await model.refresh()

            // At rest, a toggle does NOTHING: the row's tap is the jump.
            model.toggle(seed.ids[0])
            #expect(model.selection.isEmpty)

            model.enterSelection()
            model.toggle(seed.ids[2])
            model.toggle(seed.ids[0])
            #expect(model.pickedInOrder == [seed.ids[0], seed.ids[2]])

            model.exitSelection()
            #expect(!model.isSelecting)
            #expect(model.selection.isEmpty)
        }
    }

    /// **A remote delete PRUNES the picks — and the assertion that matters is
    /// the COUNT, not the act's target.**
    ///
    /// **The first version of this pin was HOLLOW and it is recorded rather
    /// than quietly fixed.** It asserted `pickedInOrder`, which passes with
    /// the prune REMOVED: `inOrder` already filters to blocks the note's
    /// order holds, so the act could never address a ghost either way. What
    /// the prune actually protects is what she READS — `selection.count`
    /// feeds the banner AND the delete verb, so an unpruned pick makes the
    /// door say *"Delete 2 Blocks…"* over a gesture that can only reach one.
    /// That is the Mac's own stated reason for the rule, verbatim: *"the
    /// count in the banner would be a lie."*
    ///
    /// **Red on old (behavioural revert):** drop the `selection.prune(...)`
    /// line from `adopt` and the count/verb assertions red while the
    /// `pickedInOrder` control stays green — which is exactly the finding.
    @Test func aBlockDeletedElsewhereDropsOutOfThePicksAndOutOfTheCount() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedFourBlockNote(session)
            let model = MobileBlockListModel(session: session, postID: seed.post)
            await model.refresh()
            model.enterSelection()
            model.toggle(seed.ids[1])
            model.toggle(seed.ids[3])
            #expect(model.selection.count == 2)

            try await session.runner.run { [id = seed.ids[1]] ops in
                try ops.deleteBlock(id)
            }
            await model.refresh()

            // The ACT could never have reached the ghost (the control —
            // `inOrder` reads the note's order).
            #expect(model.pickedInOrder == [seed.ids[3]])
            // What the prune is FOR: the number she reads is true.
            #expect(model.selection.count == 1)
            #expect(MobileBlockSelectionCopy.deleteVerb(picked: model.selection.count)
                == "Delete Block…")
            #expect(MobileBlockSelectionCopy.bannerLabel(picked: model.selection.count)
                == "1 block picked")
        }
    }

    /// **THE ACT, DRIVEN INSIDE THE REAL SHEET, END TO END** — the Select
    /// door, two row taps, the delete door, the REAL confirm, and the store.
    ///
    /// The confirm's PRESENTATION is real; its EFFECT rides
    /// `tapAlertAction(_:writeBack:)` — the harness's recorded split, because
    /// a `UIAlertController`'s own buttons measurably do not activate in
    /// process.
    ///
    /// **Red on old (behavioural revert):** make the row's tap always call
    /// `onJump` (drop the `model.isSelecting` arm) and the picks never form,
    /// so the delete door never appears — this reds at the `activate` for it.
    @Test func pickingTwoBlocksAndConfirmingDeletesExactlyThoseTwo() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFourBlockNote(session)
            let list = MobileBlockListModel(session: session, postID: seed.post)
            var deleted: [String] = []
            try await withHostedSurface(
                MobileBlockListSheet(
                    model: list, tokens: .terminalLight,
                    onDeleteBlocks: { ids in
                        deleted = ids
                        do {
                            try await session.runner.run { [stack = session.undoStack] ops in
                                try stack.withCompound(
                                    label: "Delete Blocks", operations: ops
                                ) {
                                    for id in ids { try ops.deleteBlock(id) }
                                }
                            }
                            return true
                        } catch { return false }
                    },
                    onJump: { _ in })
            ) { surface in
                await surface.settle(40)
                // The door is CHROME and it is there.
                #expect(surface.activate(MobileBlockSelectionCopy.selectLabel),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)

                // Two rows, tapped by their real handles.
                #expect(surface.activate(MobileBlockListModel.handle(list.rows[1])))
                await surface.settle(40)
                #expect(surface.activate(MobileBlockListModel.handle(list.rows[3])))
                await surface.settle(40)
                #expect(list.selection.count == 2)

                // The banner's act names the count.
                let verb = MobileBlockSelectionCopy.deleteVerb(picked: 2)
                #expect(verb == "Delete 2 Blocks…")
                #expect(surface.activate(verb), "labels were \(surface.visibleLabels)")
                await surface.settle(40)

                // ONE confirm, real, and ASKING IS NOT DOING.
                let alert = try #require(surface.presentedAlert)
                #expect(alert.title == "Delete 2 Blocks")
                #expect(try await liveBlockTexts(db, post: seed.post).count == 4)

                #expect(surface.tapAlertAction(
                    MobileBlockSelectionCopy.confirmActionTitle,
                    writeBack: { list.deleteConfirmPresented = false }))
                await surface.settle(80)

                // Exactly those two, in the NOTE's order.
                #expect(deleted == [seed.ids[1], seed.ids[3]])
                #expect(try await liveBlockTexts(db, post: seed.post)
                    == ["Alpha here.", "Gamma here."])
                // …and picking mode is put away on the success road.
                #expect(!list.isSelecting)
            }
        }
    }

    /// **ONE compound undo entry over every picked block** — a multi-delete
    /// is ONE mistake to reverse (#59(g)), which is what makes deleting
    /// several safe at all. Composed from `deleteWholeBlockRun`, whose
    /// compound this is; the pin guards against a future second road.
    @Test func theBulkDeleteIsOneUndoEntryThatBringsThemAllBack() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFourBlockNote(session)
            let model = MobileEditorViewModel(
                session: session, postID: seed.post,
                sleep: { _ in throw CancellationError() })
            model.tailIdleSleep = { _ in throw CancellationError() }
            let surface = MobileWriteSurfaceView()
            surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
            model.attach(textView: surface.textView)
            await model.loadOnce()
            let before = session.undoStack.depth

            await model.structural.deleteWholeBlockRun([seed.ids[0], seed.ids[2]])

            #expect(try await liveBlockTexts(db, post: seed.post)
                == ["Beta here.", "Delta here."])
            #expect(session.undoStack.depth == before + 1, "one mistake, one entry")
            #expect(session.undoStack.topLabel == "Delete Blocks")

            _ = try await session.runner.run { [stack = session.undoStack] ops in
                try stack.undo(with: ops)
            }
            #expect(try await liveBlockTexts(db, post: seed.post)
                == ["Alpha here.", "Beta here.", "Gamma here.", "Delta here."])
        }
    }

    /// **THE CONFIRM IS IN-DOCTRINE, and its words compose the single-block
    /// door's own promise** — the two delete doors must not promise
    /// different roads back. It also must never name a Mac chord: this
    /// phone's undo road is the receipt's button and the note ⋯.
    @Test func theConfirmComposesTheOneRoadBackAndNamesNoChord() {
        let one = MobileBlockSelectionCopy.confirmDetail(picked: 1)
        let many = MobileBlockSelectionCopy.confirmDetail(picked: 3)
        #expect(one.hasPrefix("The block leaves this note"))
        #expect(many.hasPrefix("3 blocks leave this note"))
        for line in [one, many] {
            #expect(line.contains(MobileNoteTrayModel.putBackRoadPhrase.dropFirst()))
            #expect(line.contains("\(TrashWindow.days) days"))
            #expect(!line.contains("⌥"))
            #expect(!line.contains("⌘"))
            #expect(!line.contains("Mac"))
        }
        // The banner teaches no gesture this phone does not have.
        let banner = MobileBlockSelectionCopy.bannerLabel(picked: 2)
        #expect(banner == "2 blocks picked")
        #expect(!banner.contains("⌘"))
        #expect(!banner.contains("click"))
    }

    /// **AT REST THE SHEET IS EXACTLY AS CALM AS THE ONE THAT SHIPPED**
    /// (#59(l)'s rule): no banner, no delete door, no pick marks — and an
    /// absence claim over a POPULATED surface, since the rows and the
    /// Select door are both right there.
    @Test func atRestThereIsNoBannerAndNoDeleteDoor() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedFourBlockNote(session)
            let list = MobileBlockListModel(session: session, postID: seed.post)
            try await withHostedSurface(
                MobileBlockListSheet(
                    model: list, tokens: .terminalLight,
                    onDeleteBlocks: { _ in true }, onJump: { _ in })
            ) { surface in
                await surface.settle(40)
                let labels = surface.visibleLabels
                // POPULATED: the rows and the entry door are on screen.
                #expect(labels.contains(MobileBlockListModel.handle(list.rows[0])))
                #expect(labels.contains(MobileBlockSelectionCopy.selectLabel))
                // ABSENT: nothing about picking.
                #expect(!labels.contains(MobileBlockSelectionCopy.deleteVerb(picked: 1)))
                #expect(!labels.contains(MobileBlockSelectionCopy.doneSelectingLabel))
                #expect(surface.presentedAlert == nil)
            }
        }
    }

    /// **MERGE SELECTED IS DELIBERATELY NOT BUILT** — batch 9's proposal (A)
    /// recommends it, but it is PROPOSE-ONLY and awaits her ruling. This
    /// pins the absence so a later batch adds it by DECISION rather than
    /// discovering the gap; the selection brain carries no `isContiguousRun`
    /// for the same reason (a merge precondition with no merge).
    @Test func thereIsNoMergeSelectedDoorAndTheAbsenceIsRuled() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedFourBlockNote(session)
            let list = MobileBlockListModel(session: session, postID: seed.post)
            try await withHostedSurface(
                MobileBlockListSheet(
                    model: list, tokens: .terminalLight,
                    onDeleteBlocks: { _ in true }, onJump: { _ in })
            ) { surface in
                await surface.settle(40)
                #expect(surface.activate(MobileBlockSelectionCopy.selectLabel))
                await surface.settle(40)
                #expect(surface.activate(MobileBlockListModel.handle(list.rows[0])))
                await surface.settle(40)
                #expect(surface.activate(MobileBlockListModel.handle(list.rows[1])))
                await surface.settle(40)
                // Two ADJACENT blocks picked — the exact shape a merge door
                // would light up for. The delete door is there; no merge is.
                #expect(list.selection.count == 2)
                let labels = surface.visibleLabels.map { $0.lowercased() }
                #expect(labels.contains(
                    MobileBlockSelectionCopy.deleteVerb(picked: 2).lowercased()))
                #expect(!labels.contains { $0.contains("merge") })
            }
        }
    }

    /// **PICKING MODE DOES NOT OUTLIVE THE SHEET** (the batch-7 fix wave,
    /// cold review MINOR 1). `exitSelection`'s own doc states the rule —
    /// *"a selection that outlived its surface would offer acts on blocks
    /// she is no longer looking at"* — but the sheet's PRIMARY exit, its
    /// Done, only called `dismiss()`. The model is `@State` on the screen
    /// and outlives the presentation, so the sheet came back in picking
    /// mode with the old picks armed and `Delete N Blocks…` on the banner.
    ///
    /// Driven at the REAL Done door, by the VoiceOver name that distinguishes
    /// it from the Select/Done toggle beside it.
    ///
    /// **Red on old (behavioural revert):** drop `model.exitSelection()`
    /// from that button's closure and both assertions red.
    @Test func theSheetsOwnDoneLeavesPickingModeAndDropsThePicks() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedFourBlockNote(session)
            let list = MobileBlockListModel(session: session, postID: seed.post)
            try await withHostedSurface(
                MobileBlockListSheet(
                    model: list, tokens: .terminalLight,
                    onDeleteBlocks: { _ in true }, onJump: { _ in })
            ) { surface in
                await surface.settle(40)
                #expect(surface.activate(MobileBlockSelectionCopy.selectLabel))
                await surface.settle(40)
                #expect(surface.activate(MobileBlockListModel.handle(list.rows[1])))
                await surface.settle(40)
                #expect(list.selection.count == 1, "picked, over a populated sheet")

                // The sheet's own dismiss — the door labelled plain "Done",
                // NOT the "done picking" toggle beside it. Its label is the
                // VOICED chrome word (Terminal lowercases), read from the
                // same tokens the sheet was mounted with rather than typed.
                let dismissDoor = VoiceTokens.terminalLight.chromeLabel("Done")
                #expect(surface.visibleLabels.contains(
                    MobileBlockSelectionCopy.doneSelectingLabel),
                        "the toggle is distinct: \(surface.visibleLabels)")
                #expect(surface.activate(dismissDoor),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)

                #expect(!list.isSelecting, "the mode does not outlive the surface")
                #expect(list.selection.isEmpty)
            }
        }
    }

    /// **THE MODE'S EXIT SURVIVES AN EMPTIED NOTE** (MINOR 1's rider). The
    /// Select/Done chrome used to render only over a non-empty listing, so
    /// if every row left the note WHILE she was picking — a remote delete of
    /// the whole note's blocks — `isSelecting` stayed true with no button to
    /// leave by, the banner reading "Tap blocks to pick them." over nothing.
    ///
    /// **Red on old (behavioural revert):** drop `|| model.isSelecting` from
    /// the chrome's condition and the Done-picking door is gone from the
    /// tree — the presence assertion reds.
    @Test func theDonePickingDoorSurvivesTheLastRowLeaving() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedFourBlockNote(session)
            let list = MobileBlockListModel(session: session, postID: seed.post)
            try await withHostedSurface(
                MobileBlockListSheet(
                    model: list, tokens: .terminalLight,
                    onDeleteBlocks: { _ in true }, onJump: { _ in })
            ) { surface in
                await surface.settle(40)
                #expect(surface.activate(MobileBlockSelectionCopy.selectLabel))
                await surface.settle(40)
                #expect(list.isSelecting)

                // Every block leaves the note while she is picking.
                try await session.runner.run { [ids = seed.ids] ops in
                    for id in ids { try ops.deleteBlock(id) }
                }
                await list.refresh()
                await surface.settle(60)
                #expect(list.rows.isEmpty)

                // The way out is still on screen, and it works.
                #expect(surface.visibleLabels
                    .contains(MobileBlockSelectionCopy.doneSelectingLabel),
                        "labels were \(surface.visibleLabels)")
                #expect(surface.activate(MobileBlockSelectionCopy.doneSelectingLabel))
                await surface.settle(40)
                #expect(!list.isSelecting)
            }
        }
    }

    /// **THE ACT'S OWN ANSWER DECIDES, NOT A RE-READ** (the fix wave, cold
    /// review MINOR 3 — the record's own §11-4 question, answered).
    ///
    /// `deletePicked` used to infer "landed" from an emptied selection,
    /// which put the whole discrimination on `refresh()` reaching `adopt` —
    /// and `refresh()` SWALLOWS a read failure, leaving rows and picks
    /// stale. A read that threw right after a delete that SUCCEEDED made the
    /// app read its own success as a refusal: picking mode stayed on and
    /// `Delete N Blocks…` stayed armed over blocks that were already gone.
    ///
    /// The double here stands for exactly that world: the act reports that
    /// it landed while the listing does not move (a stale or failed read).
    /// The exit must follow the ACT.
    ///
    /// **Red on old (behavioural revert):** restore
    /// `if model.selection.isEmpty { model.exitSelection() }` in place of
    /// the returned outcome and the landed half reds — the picks are still
    /// there, so the old road reads the success as a refusal.
    @Test func theExitFollowsTheActsOutcomeNotTheListingsReRead() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedFourBlockNote(session)

            // 1 — LANDED, with a listing that never moves.
            let landedList = MobileBlockListModel(session: session, postID: seed.post)
            try await withHostedSurface(
                MobileBlockListSheet(
                    model: landedList, tokens: .terminalLight,
                    onDeleteBlocks: { _ in true }, onJump: { _ in })
            ) { surface in
                await surface.settle(40)
                #expect(surface.activate(MobileBlockSelectionCopy.selectLabel))
                await surface.settle(40)
                #expect(surface.activate(MobileBlockListModel.handle(landedList.rows[1])))
                await surface.settle(40)
                #expect(surface.activate(MobileBlockSelectionCopy.deleteVerb(picked: 1)),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
                #expect(surface.tapAlertAction(
                    MobileBlockSelectionCopy.confirmActionTitle,
                    writeBack: { landedList.deleteConfirmPresented = false }))
                await surface.settle(80)

                // Nothing was deleted, so the re-read still holds the pick —
                // and picking mode is put away anyway, because the ACT said
                // it landed.
                #expect(landedList.rows.count == 4, "the listing did not move")
                #expect(!landedList.isSelecting)
                #expect(landedList.selection.isEmpty)
            }

            // 2 — REFUSED: her picks stay for the retry (#59(k)).
            let refusedList = MobileBlockListModel(session: session, postID: seed.post)
            try await withHostedSurface(
                MobileBlockListSheet(
                    model: refusedList, tokens: .terminalLight,
                    onDeleteBlocks: { _ in false }, onJump: { _ in })
            ) { surface in
                await surface.settle(40)
                #expect(surface.activate(MobileBlockSelectionCopy.selectLabel))
                await surface.settle(40)
                #expect(surface.activate(MobileBlockListModel.handle(refusedList.rows[1])))
                await surface.settle(40)
                #expect(surface.activate(MobileBlockSelectionCopy.deleteVerb(picked: 1)))
                await surface.settle(40)
                #expect(surface.tapAlertAction(
                    MobileBlockSelectionCopy.confirmActionTitle,
                    writeBack: { refusedList.deleteConfirmPresented = false }))
                await surface.settle(80)

                #expect(refusedList.isSelecting, "a refusal keeps the mode")
                #expect(refusedList.selection.count == 1, "and keeps her picks")
            }
        }
    }

    /// **THE JOIN, ON THE REAL SCREEN** (the fix wave, cold review MINOR 2).
    ///
    /// The batch's two PR20 pins covered the two halves separately and
    /// neither crossed the seam: one hosts the sheet with a HAND-WRITTEN
    /// `onDeleteBlocks` (proving the gesture, not the app's road), the other
    /// calls `deleteWholeBlockRun` DIRECTLY (proving the road, not the
    /// sheet's use of it). So the whole feature could be disconnected in
    /// `MobileWriteView` — `onDeleteBlocks: nil` — and every pin stayed
    /// green while the Select door simply stopped rendering.
    ///
    /// This drives the REAL screen: its masthead chip, its sheet, its
    /// injected closure, and the ONE compound entry that closure's road
    /// registers.
    ///
    /// **Red on old (behavioural revert):** pass `onDeleteBlocks: nil` at
    /// `MobileWriteView`'s `MobileBlockListSheet` and the Select door is not
    /// in the tree — the activate reds, and so does everything after it.
    @Test func theRealScreenWiresPickingToTheOneDeleteRoad() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFourBlockNote(session)
            let (editor, _) = makeEditor(session, postID: seed.post)
            await editor.loadOnce()
            let before = session.undoStack.depth
            try await withHostedSurface(
                MobileWriteScreen(session: session, postID: seed.post, editor: editor)
            ) { surface in
                await surface.settle(60)
                #expect(surface.activate("Blocks"), "labels were \(surface.visibleLabels)")
                await surface.settle(60)

                #expect(surface.activate(MobileBlockSelectionCopy.selectLabel),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
                #expect(surface.activate("Beta here."), "labels were \(surface.visibleLabels)")
                await surface.settle(40)
                #expect(surface.activate("Delta here."))
                await surface.settle(40)

                #expect(surface.activate(MobileBlockSelectionCopy.deleteVerb(picked: 2)),
                        "labels were \(surface.visibleLabels)")
                await surface.settle(40)
                #expect(surface.presentedAlert?.title == "Delete 2 Blocks")
                #expect(surface.activateAlertAction(
                    MobileBlockSelectionCopy.confirmActionTitle))
                await surface.settle(120)

                // The store moved…
                let after = try await liveBlockTexts(db, post: seed.post)
                #expect(after == ["Alpha here.", "Gamma here."])
                // …through the ONE road: one compound entry, its label.
                #expect(session.undoStack.depth == before + 1)
                #expect(session.undoStack.topLabel == "Delete Blocks")
            }
        }
    }
}
