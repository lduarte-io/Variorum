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
        #expect(door.doors == [.contextMenu, .palette, .surface])
        #expect(door.shortcutLabel == nil, "no chord — her criterion was 'accessible if needed'")
        // The ⌘K row is real: declared, listed, and wired to a routed body
        // (an unwired palette act asserts in DEBUG by construction).
        #expect(ShellActions.paletteActs.contains(.showOriginBlock))
        #expect(!CapabilityRegistry.unhandledNote(
            for: .showOriginBlock, context: CapabilityContext()).isEmpty)
        // …and the History face's row is the `.surface` renderer.
        #expect(BlockPastSection.surfaceCapabilities.contains(.showOriginBlock))
    }

    /// The deleted take's door, declared (13j, round 5) — the act that had no
    /// op, no query and no door anywhere in the app until this batch.
    @Test func theDeletedTakesDoorIsDeclaredWhereItIsRendered() {
        let door = CapabilityRegistry.capability(.restoreTake)
        #expect(door.scope == .take)
        #expect(door.doors == [.surface])
        #expect(door.takesAccess == .native, "R118: not a Write privilege")
        #expect(!door.unavailableNote.isEmpty)
        #expect(BlockPastSection.surfaceCapabilities.contains(.restoreTake))
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
            let request = try #require(editor.model.originPeek)
            #expect(request.origin.blockID == slot.blockID)
            #expect(editor.model.trayRequest == nil, "the peek, not the batch-2 bridge")

            let peek = OriginPeekModel(
                session: editor.session, postID: editor.postID, origin: request.origin)
            await peek.start()
            #expect(peek.takes.map(\.id).sorted() == [chosen, take2.id].sorted(),
                    "the original's own takes, whole — the W preserved them")
        }
    }

    /// **The peek's two actions, both of them.** Put back lands the original
    /// beside its successors (the tray's composition, shared); Open this
    /// note's tray raises the tray over the peek — which is what keeps the
    /// batch-2 `revealBlockID` seam earning its place.
    @Test func thePeeksTwoActionsPutBackAndOpenTheTray() async throws {
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
            let peek = OriginPeekModel(
                session: editor.session, postID: editor.postID, origin: origin)

            #expect(!peek.traySheetShown)
            peek.openTray()
            #expect(peek.traySheetShown, "the tray opens OVER the peek, not instead of it")

            await peek.putBack()
            #expect(peek.statusMessage == TrayPath.putBackBeside)
            #expect(peek.placed)
            #expect(try editor.storeSlots().map(\.blockID)
                == [w.first.block.id, w.second.block.id, slot.blockID, tail],
                "after its last live successor — the tray's landing, shared")
        }
    }

    /// A sealed note DIAGNOSES rather than dumping the enum, in the peek
    /// exactly as in the tray (the J8 doctrine; both read one copy home).
    @Test func thePeeksPutBackDiagnosesASealedNote() async throws {
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
            let peek = OriginPeekModel(
                session: editor.session, postID: editor.postID, origin: origin)
            await peek.putBack()
            #expect(peek.statusMessage == TrayRefusalCopy.sealed)
            #expect(!peek.placed)
        }
    }

    /// The ⌘K row is context-blind by construction, so on a block with no
    /// original it SPEAKS instead of doing nothing (fire-and-speak, P-2).
    @Test func theRoutedActSpeaksWhereTheBlockHasNoOriginal() async throws {
        try await withEditor(seedBlocks: ["An ordinary block."]) { editor in
            editor.textView.setSelectedRange(NSRange(location: 0, length: 0))
            editor.model.updateCaretContext()
            editor.model.revealCaretBlockOrigin()
            #expect(editor.model.originPeek == nil)
            #expect(editor.model.statusMessage == OriginPeekCopy.noOriginHere)
        }
    }

    // MARK: - The History face's past region

    /// The block's past, as the face reads it: a lineage row for the
    /// original, quiet rows for the deleted takes, and NOTHING at all on an
    /// ordinary block (the region renders only where there is something to
    /// say — P-2, one surface over).
    @Test func theHistoryFacesPastRegionCarriesLineageAndDeletedTakes() async throws {
        try await withEditor(seedBlocks: ["Alpha one. Beta one."]) { editor in
            let ops = editor.session.operations
            let slot = try #require(try editor.storeSlots().first)
            let chosen = try #require(slot.variantID)
            let take2 = try ops.branchVariant(slot.blockID, from: chosen)
            try ops.autosave(take2.id, text: "Alpha two. Beta two.", charDelta: 0)
            let w = try ops.divideW(slot.blockID, cuts: [chosen: 10, take2.id: 10])
            try editor.reload()

            let successor = w.first.block.id
            let past = BlockPastModel(session: editor.session, blockID: successor)
            past.adopt(try await editor.database.read { try Queries.blockPast($0, blockID: successor, now: harnessNow) })
            #expect(!past.isEmpty)
            #expect(past.past.origins.map(\.blockID) == [slot.blockID])
            #expect(past.past.origins.first?.originOp == "divide")
            #expect(past.past.deletedTakes.isEmpty)

            // A deleted take on the successor joins the same region.
            let extra = try ops.branchVariant(successor, from: w.first.variants[0].id)
            try ops.setTakeLabel(extra.id, label: "second thoughts")
            try ops.deleteVariant(extra.id)
            past.adopt(try await editor.database.read { try Queries.blockPast($0, blockID: successor, now: harnessNow) })
            #expect(past.past.deletedTakes.map(\.id) == [extra.id])
            #expect(BlockPastCopy.rowLabel(past.past.deletedTakes[0]) == "second thoughts")

            // …and an ordinary block's face has nothing to show.
            let plain = try ops.newBlock(in: editor.postID, text: "ordinary")
            let plainPast = BlockPastModel(session: editor.session, blockID: plain.block.id)
            plainPast.adopt(try await editor.database.read {
                try Queries.blockPast($0, blockID: plain.block.id, now: harnessNow)
            })
            #expect(plainPast.isEmpty)
        }
    }

    /// Put back, from the face: the take returns to the fan, and the receipt
    /// says where it went.
    @Test func theHistoryFacesPutBackReturnsTheTakeToTheFan() async throws {
        try await withEditor(seedBlocks: ["shown"]) { editor in
            let ops = editor.session.operations
            let slot = try #require(try editor.storeSlots().first)
            let chosen = try #require(slot.variantID)
            let extra = try ops.branchVariant(slot.blockID, from: chosen)
            try ops.deleteVariant(extra.id)

            let past = BlockPastModel(session: editor.session, blockID: slot.blockID)
            await past.putBackTake(extra.id)
            #expect(past.statusMessage == BlockPastCopy.takeRestored)
            let fan = try await editor.database.read {
                try Queries.blockFan($0, blockID: slot.blockID)
            }
            #expect(fan.map(\.id).contains(extra.id))
        }
    }

    /// …and it DIAGNOSES a sealed note rather than dumping the enum, through
    /// the same copy home the tray uses.
    @Test func theHistoryFacesPutBackDiagnosesASealedNote() async throws {
        try await withEditor(seedBlocks: ["shown"]) { editor in
            let ops = editor.session.operations
            let slot = try #require(try editor.storeSlots().first)
            let chosen = try #require(slot.variantID)
            let extra = try ops.branchVariant(slot.blockID, from: chosen)
            try ops.deleteVariant(extra.id)
            try ops.lockPost(editor.postID)

            let past = BlockPastModel(session: editor.session, blockID: slot.blockID)
            await past.putBackTake(extra.id)
            #expect(past.statusMessage == TrayRefusalCopy.sealed)
        }
    }

    /// **THE A1 PIN (13j ladder A round 1, BLOCKER — red-on-old by
    /// behavioral revert).** Mounting the section over a REAL store must
    /// start its own observation and surface the block's past — NO `adopt`
    /// anywhere in this test. On the pre-fix code the starting `.task` sat
    /// INSIDE the `if !model.isEmpty` conditional, and `past` begins empty:
    /// the task could never attach, so the section was dead by construction
    /// on every real host while every adopt-driven pin above stayed green.
    @Test func theHistoryFaceSectionStartsItsOwnObservationWhenMounted() async throws {
        try await withEditor(seedBlocks: ["shown"]) { editor in
            let ops = editor.session.operations
            let slot = try #require(try editor.storeSlots().first)
            let chosen = try #require(slot.variantID)
            let extra = try ops.branchVariant(slot.blockID, from: chosen)
            try ops.deleteVariant(extra.id)

            let past = BlockPastModel(session: editor.session, blockID: slot.blockID)
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 480, height: 220),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(rootView: BlockPastSection(
                model: past, tokens: .fallback(for: .light), onSeeOrigin: { _ in }))
            hosting.frame = NSRect(x: 0, y: 0, width: 480, height: 220)
            window.contentView = hosting
            window.orderFrontRegardless()

            // Async-poll (never sync RunLoop pumping) until the observation
            // the MOUNT must start delivers the deleted take.
            for _ in 0..<80 where past.past.isEmpty {
                hosting.layoutSubtreeIfNeeded()
                window.displayIfNeeded()
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(25))
            }
            #expect(past.past.deletedTakes.map(\.id) == [extra.id],
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

            let past = BlockPastModel(session: editor.session, blockID: slot.blockID)
            await past.putBackTake(extra.id)
            #expect(past.statusMessage == BlockPastCopy.takeRestoredArchived,
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
            #expect(past.statusMessage == BlockPastCopy.takeRestored)
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

    /// The face's lifetime is the model's: opening the history builds the
    /// past for the CARET block, closing it lets go — so the observation of
    /// `variant` (the table autosave writes) never stands over a typing
    /// burst, and re-opening on a different block never shows the previous
    /// one's deleted takes.
    @Test func theWriteHistoryFaceOwnsThePastsLifetimeAndItsBlock() async throws {
        try await withEditor(seedBlocks: ["first", "second"]) { editor in
            #expect(editor.model.blockPast == nil)
            let slots = try editor.storeSlots()
            editor.textView.setSelectedRange(NSRange(location: 0, length: 0))
            editor.model.updateCaretContext()
            await editor.model.loadCommitHistory()
            #expect(editor.model.blockPast?.blockID == slots[0].blockID)

            // The caret moves to the second block and the face reloads.
            let range = try #require(
                editor.model.index.entries.firstIndex { $0.blockID == slots[1].blockID }
                    .map { editor.model.index.range(ofEntryAt: $0) })
            editor.textView.setSelectedRange(NSRange(location: range.location, length: 0))
            editor.model.updateCaretContext()
            await editor.model.loadCommitHistory()
            #expect(editor.model.blockPast?.blockID == slots[1].blockID)

            editor.model.toggleCommitHistory()
            #expect(editor.model.commitList == nil)
            #expect(editor.model.blockPast == nil, "closing the face lets the observation go")
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
