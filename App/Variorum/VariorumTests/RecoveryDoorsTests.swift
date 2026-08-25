//
//  RecoveryDoorsTests.swift
//  VariorumTests
//
//  Phase 13j, batch 3 — the FACES of the recovery doors:
//
//  · **J3's final grammar** (sitting rounds 4 + 5): the op-aware context row,
//    the ⌘K act, the History face's lineage row, and the read-only PEEK with
//    exactly two actions — Put back in note, Open this note's tray.
//  · **J5** (her mobile-gate ruling): the lens column says it IN PLACE when
//    its pick dangles, worded to the actual state, with one-click Restore.
//  · **The round-5 deleted-take ruling**: quiet rows in the block's History
//    face with Put back — one "past" surface per block.
//
//  The OPS and the READS behind all three are pinned core-side
//  (`VariorumCoreTests/RecoveryOpsTests.swift`); this suite is about the
//  doors — which render where, what they say, and what invoking them does.
//

import AppKit
import ConcurrencyExtras
import Dependencies
import Foundation
import GRDB
import SwiftUI  // NSHostingView — the A1 pin mounts the section for real
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The recovery doors — J3's peek, J5's lens notice, deleted takes (13j)")
struct RecoveryDoorsTests {
    // MARK: - The words

    /// Her ruled wording, and the ONE rule that keeps it honest: the row says
    /// which act released the original, and an op the door has no word for
    /// falls back to the generic sentence rather than inventing one.
    @Test func theDoorsWordsNameTheActThatReleasedTheOriginal() {
        #expect(OriginPeekCopy.doorVerb(op: "divide") == "See original from divide…")
        #expect(OriginPeekCopy.doorVerb(op: "merge") == "See original from merge…")
        #expect(OriginPeekCopy.doorVerb(op: "extract") == "See original from extract…")
        // Unknown and absent both degrade to the generic form — never
        // "See original from pool_copy…", and never a raw enum in her face.
        #expect(OriginPeekCopy.doorVerb(op: "pool_copy")
            == "See the original this came from…")
        #expect(OriginPeekCopy.doorVerb(op: nil) == "See the original this came from…")

        // The lineage row names the act AND the date, and an unparseable
        // stamp renders no date rather than raw ISO text.
        let row = OriginPeekCopy.lineageRow(op: "divide", at: "2026-08-18T09:30:00.000Z")
        #expect(row.hasPrefix("From a divide on "))
        #expect(row.hasSuffix(" — the original is preserved"))
        #expect(OriginPeekCopy.lineageRow(op: "merge", at: "not a stamp")
            == "From a merge — the original is preserved")
        // The peek's heading is the same sentence — one fact, one wording.
        #expect(OriginPeekCopy.heading(op: "divide", at: "2026-08-18T09:30:00.000Z") == row)
    }

    /// **J5's notice is worded to the ACTUAL state** — her ruling says
    /// "archived", and archived and deleted are different things with
    /// different roads back. A single hedged sentence covering both would be
    /// the guessing-copy defect J8 closed one batch ago.
    @Test func theLensNoticeSaysWhichStateThePickIsIn() {
        #expect(LensFallbackCopy.notice(for: .archived).contains("archived"))
        #expect(LensFallbackCopy.notice(for: .deleted).contains("deleted"))
        #expect(!LensFallbackCopy.notice(for: .archived).contains("deleted"))
        #expect(!LensFallbackCopy.notice(for: .deleted).contains("archived"))
        for state in [Queries.DanglingPick.State.archived, .deleted, .gone, .foreign] {
            #expect(LensFallbackCopy.notice(for: state).contains("showing the note's take"),
                    "every notice says what she is looking at instead")
        }
        // The two states with no road carry no button — a Restore that could
        // only fail is exactly the door P-2 forbids.
        #expect(Queries.DanglingPick(variantID: "v", state: .archived).isRestorable)
        #expect(Queries.DanglingPick(variantID: "v", state: .deleted).isRestorable)
        #expect(!Queries.DanglingPick(variantID: "v", state: .gone).isRestorable)
        #expect(!Queries.DanglingPick(variantID: "v", state: .foreign).isRestorable)
    }

    // MARK: - The registry: three summoned doors, no ambient chrome

    @Test func theLineageActDeclaresItsThreeSummonedDoors() {
        let door = CapabilityRegistry.capability(.showOriginBlock)
        // **A JUSTIFIED EDIT** (the post-13l polish round, ledger row 17):
        // the `.surface` door was the quiet lineage ROW inside the History
        // face, and the History face is now the Block History PANE, whose
        // came-from region is where this act LANDS rather than a door onto
        // it. TWO summoned doors — which is exactly what her round-4
        // criterion asked for and what the rest of this pin has always said.
        #expect(door.doors == [.contextMenu, .palette])
        #expect(door.shortcutLabel == nil, "no chord — her criterion was 'accessible if needed'")
        // The ⌘K row is real: declared, listed, and wired to a routed body
        // (an unwired palette act asserts in DEBUG by construction).
        #expect(ShellActions.paletteActs.contains(.showOriginBlock))
        #expect(!CapabilityRegistry.unhandledNote(
            for: .showOriginBlock, context: CapabilityContext()).isEmpty)
        // …and no surface renders it as a row any more: it is the act the
        // pane ANSWERS, not one the pane offers.
        #expect(!BlockHistoryPane.surfaceCapabilities.contains(.showOriginBlock))
    }

    /// The deleted take's door, declared (13j, round 5) — the act that had no
    /// op, no query and no door anywhere in the app until this batch.
    @Test func theDeletedTakesDoorIsDeclaredWhereItIsRendered() {
        let door = CapabilityRegistry.capability(.restoreTake)
        #expect(door.scope == .take)
        #expect(door.doors == [.surface])
        #expect(door.takesAccess == .native, "R118: not a Write privilege")
        #expect(!door.unavailableNote.isEmpty)
        #expect(BlockHistoryPane.surfaceCapabilities.contains(.restoreTake),
                "the pane's deleted-takes region is where the row lives now")
        // Grey where no note is open, live wherever takes are edited.
        #expect(!CapabilityRegistry.isEnabled(.restoreTake, in: CapabilityContext(mode: nil)))
        #expect(CapabilityRegistry.availability(
            .restoreTake, in: CapabilityContext(mode: .takes)) == .act)
    }

    // MARK: - J3: the door acts, and the peek's two actions

    /// End to end through a real divide-W: the context row appears with her
    /// ruled words, invoking it raises the PEEK (not the tray, not a
    /// navigation), and the peek shows the original's OWN takes.
    @Test func theContextRowOpensThePeekAtTheOriginAndItShowsItsTakes() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Beta one."]) { editor in
            let ops = editor.session.operations
            let slot = try #require(try editor.storeSlots().first)
            let chosen = try #require(slot.variantID)
            let take2 = try ops.branchVariant(slot.blockID, from: chosen)
            try ops.autosave(take2.id, text: "Alpha two. Beta two.", charDelta: 0)
            let w = try ops.divideW(slot.blockID, cuts: [chosen: 10, take2.id: 10])
            try editor.reload()
            editor.model.adoptUnplacedOrigins(try await editor.database.read {
                [postID = editor.postID] db in
                try Queries.unplacedOrigins(db, inContainer: postID)
            })
            editor.textView.setSelectedRange(NSRange(location: 0, length: 0))
            editor.model.updateCaretContext()
            #expect(editor.model.caretBlockID == w.first.block.id)

            let titles = editor.model.contextMenuItems().map(\.title)
            #expect(titles.contains(OriginPeekCopy.doorVerb(op: "divide")))

            editor.model.revealCaretBlockOrigin()
            let request = try #require(editor.model.blockHistoryRequest)
            #expect(request.blockID == w.first.block.id,
                    "the pane is the SUCCESSOR's — its came-from names the original")
            #expect(editor.model.trayRequest == nil, "the pane, not the batch-2 bridge")

            let history = BlockHistoryModel(
                session: editor.session, postID: editor.postID,
                blockID: request.blockID)
            history.adopt(try await editor.database.read {
                [blockID = request.blockID] db in
                try Queries.blockHistory(db, blockID: blockID, now: harnessNow)
            })
            #expect(history.history.origins.map(\.origin.blockID) == [slot.blockID])
            // The original's own TEXT rides the region, so the row is
            // recognisable without a second surface to open (what the peek's
            // whole panel existed for).
            #expect(history.history.origins.first?.text?.isEmpty == false)
            _ = (chosen, take2)
        }
    }

    /// **The came-from region's two doors, both of them** — the peek's two
    /// actions, absorbed (the post-13l polish round, ledger row 17).
    /// **Bring back** lands the original beside its successors through the
    /// one shared composition the tray's own door calls; **Open this note's
    /// tray** is raised as a CALLBACK the host answers, which is how the
    /// peek's nested sheet dissolves rather than moving (adjudication 3) —
    /// and it is what keeps the batch-2 `revealBlockID` seam earning its
    /// place.
    @Test func theCameFromRegionsTwoDoorsBringBackAndOpenTheTray() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Beta one.", "Tail."]) { editor in
            let ops = editor.session.operations
            let slot = try #require(try editor.storeSlots().first)
            let chosen = try #require(slot.variantID)
            let take2 = try ops.branchVariant(slot.blockID, from: chosen)
            try ops.autosave(take2.id, text: "Alpha two. Beta two.", charDelta: 0)
            let w = try ops.divideW(slot.blockID, cuts: [chosen: 10, take2.id: 10])
            let tail = try #require(try editor.storeSlots().last).blockID

            let originBlockID = w.first.block.id
            let origins = try await editor.database.read { db in
                try Queries.unplacedOrigins(db, ofBlock: originBlockID)
            }
            let origin = try #require(origins.first)
            let history = BlockHistoryModel(
                session: editor.session, postID: editor.postID,
                blockID: originBlockID)

            // The tray door is a request the HOST answers — the pane never
            // opens a panel over itself.
            var trayAskedFor: String?
            let pane = BlockHistoryPane(
                session: editor.session,
                request: BlockHistoryRequest(
                    postID: editor.postID, blockID: originBlockID),
                onOpenTray: { trayAskedFor = $0 }, model: history)
            pane.onOpenTray?(origin.blockID)
            #expect(trayAskedFor == origin.blockID,
                    "the host decides where the tray opens — no sheet over a sheet")

            await history.bringBack(origin.blockID)
            #expect(history.status == .receipt(TrayPath.putBackBeside))
            #expect(try editor.storeSlots().map(\.blockID)
                == [w.first.block.id, w.second.block.id, slot.blockID, tail],
                "after its last live successor — the tray's landing, shared")
        }
    }

    /// A sealed note DIAGNOSES rather than dumping the enum, in the pane
    /// exactly as in the tray (the J8 doctrine; both read one copy home).
    @Test func theCameFromsBringBackDiagnosesASealedNote() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Beta one."]) { editor in
            let ops = editor.session.operations
            let slot = try #require(try editor.storeSlots().first)
            let chosen = try #require(slot.variantID)
            let take2 = try ops.branchVariant(slot.blockID, from: chosen)
            try ops.autosave(take2.id, text: "Alpha two. Beta two.", charDelta: 0)
            let w = try ops.divideW(slot.blockID, cuts: [chosen: 10, take2.id: 10])
            try ops.lockPost(editor.postID)

            let originBlockID = w.first.block.id
            let origins = try await editor.database.read { db in
                try Queries.unplacedOrigins(db, ofBlock: originBlockID)
            }
            let origin = try #require(origins.first)
            let history = BlockHistoryModel(
                session: editor.session, postID: editor.postID,
                blockID: originBlockID)
            await history.bringBack(origin.blockID)
            #expect(history.status == .refusal(TrayRefusalCopy.sealed))
            #expect(history.status?.isRefusal == true)
        }
    }

    /// The ⌘K row is context-blind by construction, so on a block with no
    /// original it SPEAKS instead of doing nothing (fire-and-speak, P-2).
    @Test func theRoutedActSpeaksWhereTheBlockHasNoOriginal() async throws {
        try await withEditor(seedBlocks: ["An ordinary block."]) { editor in
            editor.textView.setSelectedRange(NSRange(location: 0, length: 0))
            editor.model.updateCaretContext()
            editor.model.revealCaretBlockOrigin()
            #expect(editor.model.blockHistoryRequest == nil)
            #expect(editor.model.statusMessage == OriginPeekCopy.noOriginHere)
        }
    }

    // MARK: - The Block History pane's regions (the post-13l polish round)

    /// The block's whole time, as the PANE reads it: its came-from, its
    /// deleted takes, and nothing at all on an ordinary block (a region
    /// renders only where there is something to say — P-2).
    @Test func theBlockHistoryPaneCarriesLineageAndDeletedTakes() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Beta one."]) { editor in
            let ops = editor.session.operations
            let slot = try #require(try editor.storeSlots().first)
            let chosen = try #require(slot.variantID)
            let take2 = try ops.branchVariant(slot.blockID, from: chosen)
            try ops.autosave(take2.id, text: "Alpha two. Beta two.", charDelta: 0)
            let w = try ops.divideW(slot.blockID, cuts: [chosen: 10, take2.id: 10])
            try editor.reload()

            let successor = w.first.block.id
            let past = BlockHistoryModel(
                session: editor.session, postID: editor.postID, blockID: successor)
            past.adopt(try await editor.database.read {
                try Queries.blockHistory($0, blockID: successor, now: harnessNow)
            })
            #expect(!past.isEmpty)
            #expect(past.history.origins.map(\.origin.blockID) == [slot.blockID])
            #expect(past.history.origins.first?.origin.originOp == "divide")
            #expect(past.history.deletedTakes.isEmpty)

            // A deleted take on the successor joins the same region.
            let extra = try ops.branchVariant(successor, from: w.first.variants[0].id)
            try ops.setTakeLabel(extra.id, label: "second thoughts")
            try ops.deleteVariant(extra.id)
            past.adopt(try await editor.database.read {
                try Queries.blockHistory($0, blockID: successor, now: harnessNow)
            })
            #expect(past.history.deletedTakes.map(\.id) == [extra.id])
            #expect(BlockPastCopy.rowLabel(past.history.deletedTakes[0]) == "second thoughts")

            // …and an ordinary block's pane has nothing to show.
            let plain = try ops.newBlock(in: editor.postID, text: "ordinary")
            let plainPast = BlockHistoryModel(
                session: editor.session, postID: editor.postID, blockID: plain.block.id)
            plainPast.adopt(try await editor.database.read {
                try Queries.blockHistory($0, blockID: plain.block.id, now: harnessNow)
            })
            #expect(plainPast.isEmpty)
        }
    }

    /// Put back, from the pane: the take returns to the fan, and the receipt
    /// says where it went.
    @Test func theBlockHistoryPanesPutBackReturnsTheTakeToTheFan() async throws {
        try await withEditor(seedBlocks: ["shown"]) { editor in
            let ops = editor.session.operations
            let slot = try #require(try editor.storeSlots().first)
            let chosen = try #require(slot.variantID)
            let extra = try ops.branchVariant(slot.blockID, from: chosen)
            try ops.deleteVariant(extra.id)

            let past = BlockHistoryModel(
                session: editor.session, postID: editor.postID, blockID: slot.blockID)
            await past.putBackTake(extra.id)
            #expect(past.status == .receipt(BlockPastCopy.takeRestored))
            let fan = try await editor.database.read {
                try Queries.blockFan($0, blockID: slot.blockID)
            }
            #expect(fan.map(\.id).contains(extra.id))
        }
    }

    /// …and it DIAGNOSES a sealed note rather than dumping the enum, through
    /// the same copy home the tray uses.
    @Test func theBlockHistoryPanesPutBackDiagnosesASealedNote() async throws {
        try await withEditor(seedBlocks: ["shown"]) { editor in
            let ops = editor.session.operations
            let slot = try #require(try editor.storeSlots().first)
            let chosen = try #require(slot.variantID)
            let extra = try ops.branchVariant(slot.blockID, from: chosen)
            try ops.deleteVariant(extra.id)
            try ops.lockPost(editor.postID)

            let past = BlockHistoryModel(
                session: editor.session, postID: editor.postID, blockID: slot.blockID)
            await past.putBackTake(extra.id)
            #expect(past.status == .refusal(TrayRefusalCopy.sealed))
        }
    }

    /// **THE A1 PIN, CARRIED FORWARD ONTO THE PANE** (13j ladder A round 1,
    /// BLOCKER). Mounting the pane over a REAL store must start its own
    /// observation and surface the block's past — NO `adopt` anywhere in this
    /// test. The defect it caught (a starting `.task` inside an
    /// `if !model.isEmpty`, on a model that begins empty, so the task could
    /// never attach) is exactly the class a rewritten surface can reopen, so
    /// it moves with the surface rather than retiring with it.
    @Test func theBlockHistoryPaneStartsItsOwnObservationWhenMounted() async throws {
        try await withEditor(seedBlocks: ["shown"]) { editor in
            let ops = editor.session.operations
            let slot = try #require(try editor.storeSlots().first)
            let chosen = try #require(slot.variantID)
            let extra = try ops.branchVariant(slot.blockID, from: chosen)
            try ops.deleteVariant(extra.id)

            let past = BlockHistoryModel(
                session: editor.session, postID: editor.postID, blockID: slot.blockID)
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 480, height: 220),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(rootView: BlockHistoryPane(
                session: editor.session,
                request: BlockHistoryRequest(
                    postID: editor.postID, blockID: slot.blockID),
                model: past))
            hosting.frame = NSRect(x: 0, y: 0, width: 480, height: 220)
            window.contentView = hosting
            window.orderFrontRegardless()

            // Async-poll (never sync RunLoop pumping) until the observation
            // the MOUNT must start delivers the deleted take.
            for _ in 0..<80 where past.history.deletedTakes.isEmpty {
                hosting.layoutSubtreeIfNeeded()
                window.displayIfNeeded()
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(25))
            }
            #expect(past.history.deletedTakes.map(\.id) == [extra.id],
                    "the mount starts the observation — no adopt seam in this test")
        }
    }

    /// **THE A3 PIN (13j ladder A round 1 — red-on-old).** The restore is an
    /// exact flip (#68(b), ruled): a take ARCHIVED when it was deleted comes
    /// back archived — into the archived listing, not the fan — and the
    /// receipt must say which. The pre-fix door claimed the fan for every
    /// restored take, and its Put-back help promised "its place in the fan".
    @Test func putBackOfAnArchivedDeletedTakeDoesNotClaimTheFan() async throws {
        try await withEditor(seedBlocks: ["shown"]) { editor in
            let ops = editor.session.operations
            let slot = try #require(try editor.storeSlots().first)
            let chosen = try #require(slot.variantID)
            let extra = try ops.branchVariant(slot.blockID, from: chosen)
            try ops.archiveVariant(extra.id)
            try ops.deleteVariant(extra.id)

            // The row knows its status, so the help words to it BEFORE the
            // act (the receipt is the act's own answer, below).
            let listed = try await editor.database.read { [blockID = slot.blockID] db in
                try Queries.deletedTakes(db, blockID: blockID, now: harnessNow)
            }
            #expect(BlockPastCopy.putBackHelp(try #require(listed.first))
                .contains("archived takes"))

            let past = BlockHistoryModel(
                session: editor.session, postID: editor.postID, blockID: slot.blockID)
            await past.putBackTake(extra.id)
            #expect(past.status == .receipt(BlockPastCopy.takeRestoredArchived),
                    "the receipt reads the op's own status — never \"the fan\" here")
            let status = try await editor.database.read { [id = extra.id] db in
                try Variant.fetchOne(db, key: id)?.status
            }
            #expect(status == .archived, "the exact flip stands — nothing un-archived")

            // An ACTIVE deleted take keeps the fan receipt, and its help
            // still names the fan.
            let active = try ops.branchVariant(slot.blockID, from: chosen)
            try ops.deleteVariant(active.id)
            let activeRow = try await editor.database.read { [blockID = slot.blockID] db in
                try Queries.deletedTakes(db, blockID: blockID, now: harnessNow)
            }
            #expect(BlockPastCopy.putBackHelp(try #require(activeRow.first))
                .contains("fan"))
            await past.putBackTake(active.id)
            #expect(past.status == .receipt(BlockPastCopy.takeRestored))
        }
    }

    /// **A3's LENS half (red-on-old).** Restoring a deleted pick that comes
    /// back ARCHIVED must not claim the lens is showing it again — the pick
    /// still dangles (now as archived, Restore now offering unarchive), and
    /// the second click heals it. The truthful two-click chain, pinned.
    @Test func theLensRestoreOfAnArchivedDeletedPickSaysItCameBackArchived() async throws {
        try await withLensBoard { board in
            let ops = board.session.operations
            let slot = try #require(board.model.projection.slots.first)
            let chosen = try #require(slot.variantID)
            let take2 = try ops.branchVariant(slot.blockID, from: chosen)
            let lens = try ops.createLens(post: board.postID, name: "thread")
            _ = try ops.setLensChoice(lens: lens.id, block: slot.blockID, variant: take2.id)
            board.model.addLensColumn(lens.id)
            try board.reload()
            let column = try #require(board.model.columns.first {
                if case .lens = $0.kind { return true } else { return false }
            })

            try ops.archiveVariant(take2.id)
            try ops.deleteVariant(take2.id)
            try board.reload()
            let deleted = try #require(board.model.danglingPick(columnID: column.id, slot: slot))
            #expect(deleted.state == .deleted)

            await board.model.restoreDanglingPick(deleted)
            #expect(board.model.statusMessage == LensFallbackCopy.restoredDeletedButArchived,
                    "not \"showing its pick again\" — the pick still dangles, archived")
            try board.reload()
            let archived = try #require(board.model.danglingPick(columnID: column.id, slot: slot))
            #expect(archived.state == .archived, "the notice re-renders truthfully")

            // The second click heals it — the chain the receipt teaches.
            await board.model.restoreDanglingPick(archived)
            #expect(board.model.statusMessage == LensFallbackCopy.restoredArchived)
            try board.reload()
            #expect(board.model.danglingPick(columnID: column.id, slot: slot) == nil)
            #expect(board.model.projection.lensSelections[lens.id]?[slot.blockID] == take2.id)
        }
    }

    /// **The pane's lifetime is its own, and so is its BLOCK** — the same two
    /// properties the two absorbed history faces had to keep by hand, now
    /// structural (the post-13l polish round, ledger row 17).
    ///
    /// What the old pin drove: opening the history built a past model for the
    /// CARET block, moving the caret rebuilt it, and closing let it go — so
    /// the observation of `variant` (the table autosave writes) never stood
    /// over a typing burst. The pane keeps all three by construction: the
    /// REQUEST carries the block, its identity is the request, and the view's
    /// own `.task` owns the observation's lifetime — so a different caret is
    /// a different request and a closed panel is a cancelled task, with no
    /// model bookkeeping to get wrong.
    @Test func theHistoryRequestCarriesTheCaretsBlockAndItsTake() async throws {
        try await withEditor(seedBlocks: ["first", "second"]) { editor in
            #expect(editor.model.blockHistoryRequest == nil)
            let slots = try editor.storeSlots()
            editor.textView.setSelectedRange(NSRange(location: 0, length: 0))
            editor.model.updateCaretContext()
            editor.model.requestBlockHistory()
            #expect(editor.model.blockHistoryRequest?.blockID == slots[0].blockID)
            #expect(editor.model.blockHistoryRequest?.focusedVariantID
                == slots[0].variantID)

            // The caret moves to the second block: a fresh request, a
            // different panel identity, so the pane cannot show the first
            // block's takes under the second block's name.
            let range = try #require(
                editor.model.index.entries.firstIndex { $0.blockID == slots[1].blockID }
                    .map { editor.model.index.range(ofEntryAt: $0) })
            editor.textView.setSelectedRange(NSRange(location: range.location, length: 0))
            editor.model.updateCaretContext()
            let first = try #require(editor.model.blockHistoryRequest)
            editor.model.requestBlockHistory()
            let second = try #require(editor.model.blockHistoryRequest)
            #expect(second.blockID == slots[1].blockID)
            #expect(second.id != first.id, "a different block is a different panel")

            // With the caret nowhere in a block, the door SPEAKS rather than
            // opening a pane on a block it cannot name (P-2).
            editor.type("\n", at: try editor.storeSlots()
                .map { $0.text ?? "" }.joined(separator: "\n\n").utf16.count)
            editor.model.updateCaretContext()
            if editor.model.caretBlockID == nil {
                editor.model.blockHistoryRequest = nil
                editor.model.requestBlockHistory()
                #expect(editor.model.blockHistoryRequest == nil)
                #expect(editor.model.statusMessage
                    == CapabilityRegistry.capability(.showBlockHistory).unavailableNote)
            }
        }
    }

    // MARK: - J5: the lens says it in place

    /// The notice renders on the LENS column that made the pick, and only
    /// there — a scratch column's picks are view-local and cannot dangle
    /// across a session, and the Chosen column made no pick at all.
    @Test func onlyALensColumnWithADanglingPickShowsTheNotice() async throws {
        try await withLensBoard { board in
            let ops = board.session.operations
            let slot = try #require(board.model.projection.slots.first)
            let chosen = try #require(slot.variantID)
            let take2 = try ops.branchVariant(slot.blockID, from: chosen)
            let lens = try ops.createLens(post: board.postID, name: "thread")
            _ = try ops.setLensChoice(lens: lens.id, block: slot.blockID, variant: take2.id)
            board.model.addLensColumn(lens.id)
            board.model.addScratchColumn()
            try board.reload()

            let lensColumn = try #require(board.model.columns.first {
                if case .lens = $0.kind { return true } else { return false }
            })
            let scratch = try #require(board.model.columns.first {
                if case .scratch = $0.kind { return true } else { return false }
            })
            let main = try #require(board.model.columns.first { $0.kind == .main })

            // Healthy: no notice anywhere.
            #expect(board.model.danglingPick(columnID: lensColumn.id, slot: slot) == nil)

            try ops.archiveVariant(take2.id)
            try board.reload()
            let pick = try #require(
                board.model.danglingPick(columnID: lensColumn.id, slot: slot))
            #expect(pick == Queries.DanglingPick(variantID: take2.id, state: .archived))
            #expect(board.model.danglingPick(columnID: scratch.id, slot: slot) == nil,
                    "a scratch column's picks are view-local — they cannot dangle")
            #expect(board.model.danglingPick(columnID: main.id, slot: slot) == nil,
                    "the Chosen column made no pick to dangle")
        }
    }

    /// **One click back.** Restore routes by the pick's actual state — an
    /// archived take through the road that has shipped since 13b Stage 3
    /// (`unarchiveVariant`, the archived listing's own button), a deleted one
    /// through 13j's new op — and the lens shows its pick again either way.
    @Test func theNoticesRestoreRoundTripsBothStates() async throws {
        try await withLensBoard { board in
            let ops = board.session.operations
            let slot = try #require(board.model.projection.slots.first)
            let chosen = try #require(slot.variantID)
            let take2 = try ops.branchVariant(slot.blockID, from: chosen)
            try ops.autosave(take2.id, text: "the lens's take", charDelta: 0)
            let lens = try ops.createLens(post: board.postID, name: "thread")
            _ = try ops.setLensChoice(lens: lens.id, block: slot.blockID, variant: take2.id)
            board.model.addLensColumn(lens.id)
            try board.reload()
            let column = try #require(board.model.columns.first {
                if case .lens = $0.kind { return true } else { return false }
            })

            // ARCHIVED → unarchiveVariant.
            try ops.archiveVariant(take2.id)
            try board.reload()
            await board.model.restoreDanglingPick(
                try #require(board.model.danglingPick(columnID: column.id, slot: slot)))
            #expect(board.model.statusMessage == LensFallbackCopy.restoredArchived)
            try board.reload()
            #expect(board.model.danglingPick(columnID: column.id, slot: slot) == nil)
            #expect(board.model.projection.lensSelections[lens.id]?[slot.blockID] == take2.id)

            // DELETED → restoreVariant.
            try ops.deleteVariant(take2.id)
            try board.reload()
            let deleted = try #require(board.model.danglingPick(columnID: column.id, slot: slot))
            #expect(deleted.state == .deleted)
            await board.model.restoreDanglingPick(deleted)
            #expect(board.model.statusMessage == LensFallbackCopy.restoredDeleted)
            try board.reload()
            #expect(board.model.danglingPick(columnID: column.id, slot: slot) == nil)
            #expect(board.model.projection.lensSelections[lens.id]?[slot.blockID] == take2.id)
        }
    }

    /// A dangling pick with nowhere to go says so rather than offering a
    /// button that could only fail.
    @Test func aPickWithNoRoadBackSaysSo() async throws {
        try await withLensBoard { board in
            await board.model.restoreDanglingPick(
                Queries.DanglingPick(variantID: "gone", state: .gone))
            #expect(board.model.statusMessage == LensFallbackCopy.nothingToRestore)
        }
    }

    // MARK: - Harness (the OriginBlockDoorTests Board shape, lens-flavoured)

    @MainActor
    private struct LensBoard {
        let session: AppSession
        let database: AppDatabase
        let model: TakesViewModel
        let postID: String

        func reload() throws {
            model.adopt(try database.read { try Queries.takesProjection($0, post: postID) })
        }
    }

    private func withLensBoard<T>(
        _ body: @MainActor (LensBoard) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "J5")
            _ = try session.operations.newBlock(in: post.id, text: "Alpha.")
            // A SCOPED defaults suite: the board remembers its columns per
            // post, and deterministic UUIDs make every suite's post the same
            // id — without this a neighbouring test's saved columns arrive
            // here (the standing `freshDefaults` discipline).
            let model = TakesViewModel(
                session: session, postID: post.id,
                defaults: UserDefaults(suiteName: "13j-recovery-doors.\(UUID().uuidString)")!)
            model.host = .lenses
            let board = LensBoard(
                session: session, database: db, model: model, postID: post.id)
            try board.reload()
            return try await body(board)
        }
    }
}
