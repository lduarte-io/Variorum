//
//  MobileTakesBrowserTests.swift
//  VariorumMobileTests
//
//  Mobile Stage 2, batch 2 — the takes browser (M4/LK4): the sheet's
//  brain headless over the bare-storage seam, plus the sheet's pixels and
//  the two remaining doors (the bar's ⑂, the edit-menu item) over real
//  laid-out surfaces. The binding cores under test: all four verbs run
//  through the STANDING operations with the ops' real refusals speaking
//  (I10 on the last take, the chosen-slot guard, the seal, the take
//  lock); minting never chooses; card edits route to the edited take
//  ONLY; the in-page editor stands down while the sheet is up (P3's one
//  live pane); the badge tap now opens the browser (P15 retired).
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - Harness (the batch-1 fixture's shape, re-declared file-locally)

@MainActor
private func seedFannedPost(
    _ session: AppSession
) async throws -> (postID: String, blockA: String, a1: String, a2: String, blockB: String, b1: String) {
    try await session.runner.run { ops in
        let post = try ops.createPost(title: "browser", profile: .blog)
        let a = try ops.newBlock(in: post.id, text: "First block, as chosen.", at: .end)
        let b = try ops.newBlock(in: post.id, text: "Second block, fanless.", at: .end)
        let take = try ops.branchVariant(a.block.id, from: a.variant.id)
        try ops.autosave(take.id, text: "First block, the other way.", charDelta: 9)
        return (post.id, a.block.id, a.variant.id, take.id, b.block.id, b.variant.id)
    }
}

@MainActor
private func chosenVariantID(_ db: AppDatabase, blockID: String) async throws -> String? {
    try await db.read { db in
        try String.fetchOne(
            db,
            sql: """
                SELECT chosen_variant_id FROM container_block
                WHERE block_id = ? AND deleted_at IS NULL
                """,
            arguments: [blockID])
    }
}

@MainActor
private func variantStatus(_ db: AppDatabase, variantID: String) async throws -> String? {
    try await db.read { db in
        try String.fetchOne(
            db,
            sql: "SELECT status FROM variant WHERE id = ? AND deleted_at IS NULL",
            arguments: [variantID])
    }
}

@MainActor
private func liveActiveTakeIDs(_ db: AppDatabase, blockID: String) async throws -> [String] {
    try await db.read { db in
        try String.fetchAll(
            db,
            sql: """
                SELECT id FROM variant
                WHERE block_id = ? AND deleted_at IS NULL AND status = 'active'
                ORDER BY fan_position, id
                """,
            arguments: [blockID])
    }
}

@MainActor
private func adoptFreshHeader(_ model: MobileEditorViewModel, _ db: AppDatabase) async throws {
    let header = try await db.read { [postID = model.postID] in
        try Queries.containerHeader($0, containerID: postID)
    }
    model.adoptHeader(header)
}

@MainActor
private func makeBrowserSurface(
    _ session: AppSession, postID: String
) async -> (model: MobileEditorViewModel, surface: MobileWriteSurfaceView) {
    let model = MobileEditorViewModel(
        session: session, postID: postID,
        sleep: { _ in throw CancellationError() })
    model.tailIdleSleep = { _ in throw CancellationError() }
    let surface = MobileWriteSurfaceView()
    surface.frame = CGRect(x: 0, y: 0, width: 393, height: 700)
    model.attach(textView: surface.textView)
    await model.loadOnce()
    surface.layoutIfNeeded()
    return (model, surface)
}

// MARK: - The brain, headless

@MainActor
@Suite("Mobile takes browser — the four verbs (S2 batch 2)")
struct MobileTakesBrowserTests {
    // MARK: Open / cards

    @Test func openListsCardsInFanOrderWithChosenAndPeekStates() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            try await session.runner.run { ops in
                try ops.setTakeLabel(seed.a2, label: "the other way")
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            model.takesBrowser.open(blockID: seed.blockA)
            #expect(model.takesBrowser.openBlockID == seed.blockA)
            #expect(model.takesBrowser.headerOrdinal()?.k == 1)
            #expect(model.takesBrowser.headerOrdinal()?.n == 2)

            let cards = model.takesBrowser.cards()
            #expect(cards.map(\.variantID) == [seed.a1, seed.a2])
            #expect(cards.map(\.ordinal) == [1, 2])
            #expect(cards[0].isChosen && !cards[1].isChosen)
            #expect(cards[1].label == "the other way")
            #expect(!cards[0].isPeeked && !cards[1].isPeeked)

            // A peek is visible in the sheet too — and the CHOSEN ring
            // stays on the store's truth, never the peek (M6).
            model.takes.flip(blockID: seed.blockA, forward: true)
            let peeked = model.takesBrowser.cards()
            #expect(peeked[1].isPeeked)
            #expect(peeked[0].isChosen && !peeked[1].isChosen)
        }
    }

    @Test func openOnAFanlessBlockIsTheFanBirthDoor() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // A single-take block opens too (the 9d "Show Takes"
            // chicken-and-egg, the phone's edition): one chosen card, the
            // new-take doors beside it.
            model.takesBrowser.open(blockID: seed.blockB)
            let cards = model.takesBrowser.cards()
            #expect(cards.count == 1)
            #expect(cards[0].isChosen)

            let mint = await model.takesBrowser.newBlank()
            #expect(mint != nil)
            #expect(try await liveActiveTakeIDs(db, blockID: seed.blockB).count == 2)
            // Minting NEVER chooses (R90).
            #expect(try await chosenVariantID(db, blockID: seed.blockB) == seed.b1)
        }
    }

    // MARK: ✓ choose

    @Test func chooseMovesThePointerAndEndsAnyPeek() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // Peek a2 in-page, open the browser, then ✓ the peeked take
            // from a CARD: the pointer moves, the peek ends (the explicit
            // ✓ decides what the page shows), the page shows the truth.
            model.takes.flip(blockID: seed.blockA, forward: true)
            model.takesBrowser.open(blockID: seed.blockA)
            await model.takesBrowser.choose(variantID: seed.a2)

            #expect(try await chosenVariantID(db, blockID: seed.blockA) == seed.a2)
            #expect(!model.takes.isPeeking(seed.blockA))
            #expect(storage.string.hasPrefix("First block, the other way."))
            #expect(model.statusMessage == nil)
            #expect(model.takesBrowser.cards().first { $0.variantID == seed.a2 }?.isChosen == true)
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func chooseADifferentTakeThanThePeekAlsoEndsThePeek() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // Peeking a2 but choosing a1 (already chosen truth): the ✓ is
            // the deciding act — the peek ends and the page shows a1.
            model.takes.flip(blockID: seed.blockA, forward: true)
            #expect(storage.string.hasPrefix("First block, the other way."))
            model.takesBrowser.open(blockID: seed.blockA)
            await model.takesBrowser.choose(variantID: seed.a1)

            #expect(try await chosenVariantID(db, blockID: seed.blockA) == seed.a1)
            #expect(!model.takes.isPeeking(seed.blockA))
            #expect(storage.string.hasPrefix("First block, as chosen."))
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func chooseUnderASealedNoteRefusesAndSpeaks() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takesBrowser.open(blockID: seed.blockA)
            try await session.runner.run { ops in try ops.lockPost(seed.postID) }

            await model.takesBrowser.choose(variantID: seed.a2)

            #expect(model.statusMessage
                    == "This note is locked — unlock it on the Mac to choose a take.")
            #expect(try await chosenVariantID(db, blockID: seed.blockA) == seed.a1)
            // The sheet survives the refusal (reading stays free).
            #expect(model.takesBrowser.isOpen)
        }
    }

    // MARK: New take (the two Mac gestures)

    @Test func branchDisplayedMintsACopyBesideItsSourceAndBeginsEditing() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takesBrowser.open(blockID: seed.blockA)

            let mint = await model.takesBrowser.branchDisplayed()
            guard let mint else {
                Issue.record("branch minted nothing")
                return
            }
            // The copy gesture: the DISPLAYED take's text (chosen a1 —
            // nothing peeked), branched from it, beside it in fan order.
            #expect(mint.workingText == "First block, as chosen.")
            #expect(mint.parentVariantId == seed.a1)
            #expect(try await liveActiveTakeIDs(db, blockID: seed.blockA)
                    == [seed.a1, mint.id, seed.a2])
            // Minting never chooses; the minted card is LIVE for editing
            // (the Mac's ring-follow, the phone's reading).
            #expect(try await chosenVariantID(db, blockID: seed.blockA) == seed.a1)
            #expect(model.takesBrowser.editingVariantID == mint.id)
        }
    }

    @Test func branchDisplayedWhilePeekingInheritsThePeekedTakesText() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takes.flip(blockID: seed.blockA, forward: true)
            model.takesBrowser.open(blockID: seed.blockA)

            // "This one" is the page's displayed take — the PEEKED one
            // while peeking (the recorded PROVISIONAL reading).
            let mint = await model.takesBrowser.branchDisplayed()
            #expect(mint?.workingText == "First block, the other way.")
            #expect(mint?.parentVariantId == seed.a2)
        }
    }

    @Test func branchDisplayedCarriesUnflushedEditsIntoTheCopy() async throws {
        // The S2 ladder round-1 MAJOR's pin (the 13f R1-4 class): the
        // door flushes BEFORE the mint, so the copy carries the
        // keystrokes that summoned it. On the old code `branchVariant`
        // copied the store's older bytes past the dirty buffer.
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // An unflushed in-page edit on the DISPLAYED (chosen) take —
            // the debounce is held open by the injected sleep.
            let edited = "First block, as chosen. Sharpened."
            #expect(typeEdit(
                model, storage,
                range: NSRange(location: ("First block, as chosen." as NSString).length,
                               length: 0),
                replacement: " Sharpened."))
            #expect(model.autosave.isDirty)
            model.takesBrowser.open(blockID: seed.blockA)

            let mint = await model.takesBrowser.branchDisplayed()
            guard let mint else {
                Issue.record("branch minted nothing")
                return
            }
            // The copy holds the EDITED bytes — in the returned mint and
            // in the store's row — and the source flushed them too.
            #expect(mint.workingText == edited)
            #expect(try await storedText(db, variantID: mint.id) == edited)
            #expect(try await storedText(db, variantID: seed.a1) == edited)
            #expect(mint.parentVariantId == seed.a1)
        }
    }

    @Test func blankMintsAnEmptyTakeAtTheFanEnd() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takesBrowser.open(blockID: seed.blockA)

            let mint = await model.takesBrowser.newBlank()
            guard let mint else {
                Issue.record("blank minted nothing")
                return
            }
            #expect(mint.workingText == "")
            #expect(mint.parentVariantId == nil)
            #expect(try await liveActiveTakeIDs(db, blockID: seed.blockA)
                    == [seed.a1, seed.a2, mint.id])
            #expect(try await chosenVariantID(db, blockID: seed.blockA) == seed.a1)
            #expect(model.takesBrowser.editingVariantID == mint.id)
            #expect(model.takesBrowser.cards().last?.text == "")
        }
    }

    @Test func mintingUnderASealedNoteRefusesAndSpeaks() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takesBrowser.open(blockID: seed.blockA)
            try await session.runner.run { ops in try ops.lockPost(seed.postID) }

            let mint = await model.takesBrowser.newBlank()
            #expect(mint == nil)
            #expect(model.statusMessage
                    == "This note is locked — unlock it on the Mac to add a take.")
            #expect(try await liveActiveTakeIDs(db, blockID: seed.blockA).count == 2)
        }
    }

    // MARK: Edit any take (the card gate + routing)

    @Test func cardEditsRouteToTheEditedTakeOnly() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takesBrowser.open(blockID: seed.blockA)

            // Edit the NON-displayed take a2 through the card pipeline
            // (gate → change), then flush: a2 took the edit; a1 and the
            // pointer are untouched (never silently the chosen one).
            model.takesBrowser.beginEditing(variantID: seed.a2)
            #expect(model.takesBrowser.editingVariantID == seed.a2)
            let newText = "First block, the other way. Sharpened."
            #expect(model.takesBrowser.cardGateAllows(
                range: NSRange(location: 27, length: 0), replacement: " Sharpened."))
            model.takesBrowser.cardTextDidChange(newText)
            await model.autosave.flushNow()

            #expect(try await storedText(db, variantID: seed.a2) == newText)
            #expect(try await storedText(db, variantID: seed.a1)
                    == "First block, as chosen.")
            #expect(try await chosenVariantID(db, blockID: seed.blockA) == seed.a1)

            // The ledger is ONE: the sheet's card and the in-page peek
            // resolution agree on the edited bytes pre- and post-flush.
            #expect(model.surfaceKnownText(variantID: seed.a2) == newText)
            #expect(model.takesBrowser.cards().last?.text == newText)
        }
    }

    @Test func beginEditingALockedTakeRefusesAndSpeaks() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            try await session.runner.run { ops in try ops.lockVariant(seed.a2) }
            let fresh = try await db.read { [postID = model.postID] in
                try Queries.takesProjection($0, post: postID)
            }
            model.ingest(fresh)
            model.takesBrowser.open(blockID: seed.blockA)

            model.takesBrowser.beginEditing(variantID: seed.a2)
            #expect(model.takesBrowser.editingVariantID == nil)
            #expect(model.statusMessage
                    == "This take is locked — branch it or unlock it on the Mac to edit.")
        }
    }

    @Test func aRemoteLockMidCardEditRefusesTheNextKeystrokeAndKeepsPendingText() async throws {
        // The S2 ladder round-1 MINOR-1 pin: the belt's LOCKED half is
        // real. A take locked while its card is live (a remote lock
        // arriving by delivery) refuses the NEXT keystroke at the gate
        // with the standing copy — the old code admitted every keystroke
        // (seal-only belt) and the typed-after-lock text could never
        // land. The keep-pending half: text typed BEFORE the lock stays
        // pending through the gate refusal AND through the flush's own
        // refusal — nothing typed is ever dropped.
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takesBrowser.open(blockID: seed.blockA)

            // A pending, unflushed card edit on a2 (the debounce is held
            // open by the injected sleep).
            model.takesBrowser.beginEditing(variantID: seed.a2)
            let typed = "First block, the other way. Typed."
            #expect(model.takesBrowser.cardGateAllows(
                range: NSRange(location: 27, length: 0), replacement: " Typed."))
            model.takesBrowser.cardTextDidChange(typed)
            #expect(model.autosave.isDirty)

            // The remote lock lands mid-edit; the delivery adopts the
            // fresh fan (locked a2) even though the dirty buffer defers
            // the slot apply — the live card now reads locked.
            try await session.runner.run { ops in try ops.lockVariant(seed.a2) }
            let fresh = try await db.read { [postID = model.postID] in
                try Queries.takesProjection($0, post: postID)
            }
            model.ingest(fresh)

            // The next keystroke refuses AT THE GATE, with the standing
            // copy (red on old: the seal-only belt admitted it).
            #expect(!model.takesBrowser.cardGateAllows(
                range: NSRange(location: 34, length: 0), replacement: "x"))
            #expect(model.statusMessage
                    == "This take is locked — branch it or unlock it on the Mac to edit.")

            // KEEP-PENDING: the pre-lock typed bytes survive the refusal —
            // still the surface's record, still pending.
            #expect(model.surfaceKnownText(variantID: seed.a2) == typed)
            #expect(model.autosave.isDirty)

            // Even the flush's own refusal (the op's lockedVariant) keeps
            // them pending rather than dropping them; the store is safe.
            await model.autosave.flushNow()
            #expect(model.autosave.isDirty, "the refused entry stays pending")
            #expect(model.surfaceKnownText(variantID: seed.a2) == typed)
            #expect(try await storedText(db, variantID: seed.a2)
                    == "First block, the other way.")
        }
    }

    @Test func beginEditingUnderASealedNoteRefusesAndSpeaks() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            try await session.runner.run { ops in try ops.lockPost(seed.postID) }
            try await adoptFreshHeader(model, db)
            model.takesBrowser.open(blockID: seed.blockA)

            model.takesBrowser.beginEditing(variantID: seed.a2)
            #expect(model.takesBrowser.editingVariantID == nil)
            #expect(model.statusMessage
                    == "This note is locked — unlock it on the Mac to edit.")
        }
    }

    // MARK: Archive / delete (the ops' own refusals)

    @Test func archiveRemovesTheTakeFromTheFan() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takesBrowser.open(blockID: seed.blockA)

            await model.takesBrowser.archive(variantID: seed.a2)

            #expect(model.statusMessage == nil)
            #expect(try await variantStatus(db, variantID: seed.a2) == "archived")
            #expect(try await liveActiveTakeIDs(db, blockID: seed.blockA) == [seed.a1])
            // The sheet's cards follow the fresh fan.
            #expect(model.takesBrowser.cards().map(\.variantID) == [seed.a1])
        }
    }

    @Test func deletingTheChosenTakeRefusesThroughTheOpsOwnGuard() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takesBrowser.open(blockID: seed.blockA)

            // The chosen-slot guard (re-point first) — the op's real
            // refusal, spoken in the phone's words.
            await model.takesBrowser.delete(variantID: seed.a1)
            #expect(model.statusMessage
                    == "This take is what the note shows — choose another take first, "
                    + "then delete this one.")
            #expect(try await variantStatus(db, variantID: seed.a1) == "active")
        }
    }

    @Test func theLastActiveTakeRefusesArchiveAndDelete_I10() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takesBrowser.open(blockID: seed.blockA)

            // Archiving the CHOSEN take is allowed (the read-time rule
            // renders the block default in its place — AppSpec §7); the
            // fan is now a2 alone, and the slot's pointer targets an
            // ARCHIVED take.
            await model.takesBrowser.archive(variantID: seed.a1)
            #expect(model.statusMessage == nil)
            #expect(try await liveActiveTakeIDs(db, blockID: seed.blockA) == [seed.a2])

            // I10: a live block keeps at least one live active take — the
            // op refuses BOTH doors on the last one, and the refusal
            // speaks. (The DELETE door hears I10 here precisely because
            // no live slot points at a2 — the ops' chosen-slot guard runs
            // FIRST, so a last take that is ALSO chosen speaks the
            // chosen-slot refusal instead; the op's real order, pinned by
            // `deletingTheChosenTakeRefusesThroughTheOpsOwnGuard` and the
            // walk.)
            let i10Copy = "This is the block's only take — a block always keeps one. "
                + "To remove it all, use Delete Block in the \u{22EF} menu."
            await model.takesBrowser.archive(variantID: seed.a2)
            #expect(model.statusMessage == i10Copy)
            #expect(try await variantStatus(db, variantID: seed.a2) == "active")

            model.report(nil)
            await model.takesBrowser.delete(variantID: seed.a2)
            #expect(model.statusMessage == i10Copy)
            #expect(try await variantStatus(db, variantID: seed.a2) == "active")
        }
    }

    @Test func deletingALockedTakeRefusesThroughTheOp() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            try await session.runner.run { ops in try ops.lockVariant(seed.a2) }
            model.takesBrowser.open(blockID: seed.blockA)

            await model.takesBrowser.delete(variantID: seed.a2)
            #expect(model.statusMessage == "That take is locked — unlock it on the Mac first.")
            #expect(try await variantStatus(db, variantID: seed.a2) == "active")
        }
    }

    // MARK: Close (the page heals)

    @Test func closeFlushesPendingCardEditsAndHealsThePage() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takesBrowser.open(blockID: seed.blockA)

            // Edit the CHOSEN take's card (unflushed), then Done: the
            // flush lands, and the page shows the edited chosen text.
            model.takesBrowser.beginEditing(variantID: seed.a1)
            let newText = "First block, as chosen — reworked."
            #expect(model.takesBrowser.cardGateAllows(
                range: NSRange(location: 23, length: 0), replacement: " — reworked."))
            model.takesBrowser.cardTextDidChange(newText)
            await model.takesBrowser.close()

            #expect(!model.takesBrowser.isOpen)
            #expect(model.takesBrowser.editingVariantID == nil)
            #expect(try await storedText(db, variantID: seed.a1) == newText)
            #expect(storage.string
                    == "First block, as chosen — reworked.\nSecond block, fanless.")
            #expect(model.identityAuditFailures == 0)
        }
    }

    @Test func aBlockDeletedElsewhereForceClosesTheSheet() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takesBrowser.open(blockID: seed.blockA)

            try await session.runner.run { ops in try ops.deleteBlock(seed.blockA) }
            let fresh = try await db.read { [postID = model.postID] in
                try Queries.takesProjection($0, post: postID)
            }
            model.ingest(fresh)

            #expect(!model.takesBrowser.isOpen)
        }
    }
}

// MARK: - The pixels + the two remaining doors (real surfaces)

@MainActor
@Suite("Mobile takes browser — sheet pixels, ⑂, the edit menu (S2 batch 2)")
struct MobileTakesBrowserSurfaceTests {
    @Test func theSheetOpensOverTheDimmedPageAndThePageStandsDown() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, surface) = await makeBrowserSurface(session, postID: seed.postID)
            let view = surface.textView
            guard let browserView = view.takesBrowserView else {
                Issue.record("browser view not installed")
                return
            }
            #expect(browserView.isHidden)
            #expect(view.isEditable)

            model.takesBrowser.open(blockID: seed.blockA)

            // The sheet rides OVER the page in the same screen (LK4's
            // ratified shape) — and the in-page editor stands down (P3:
            // one live pane; the sheet's card editor is the only
            // candidate while open).
            #expect(!browserView.isHidden)
            #expect(browserView.superview === surface)
            #expect(!view.isEditable)
            #expect(browserView.cardViews.count == 2)

            await model.takesBrowser.close()
            #expect(browserView.isHidden)
            #expect(view.isEditable)
            #expect(model.identityAuditFailures == 0)
            #expect(!view.canaryFired)
        }
    }

    @Test func aTappedCardHostsTheOneLiveEditorAndTypingLandsInThatTake() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, surface) = await makeBrowserSurface(session, postID: seed.postID)
            let view = surface.textView
            guard let browserView = view.takesBrowserView else {
                Issue.record("browser view not installed")
                return
            }
            model.takesBrowser.open(blockID: seed.blockA)
            model.takesBrowser.beginEditing(variantID: seed.a2)

            // ONE live editor: the shared card editor sits in a2's card;
            // the page stands down; its delegate is the browser's gate.
            let editor = browserView.cardEditor
            #expect(editor.superview === browserView.cardViews[seed.a2])
            #expect(editor.delegate === browserView)
            #expect(!view.isEditable)
            #expect(editor.text == "First block, the other way.")

            // Type through the card editor's own input path.
            editor.selectedRange = NSRange(location: editor.text.utf16.count, length: 0)
            editor.insertText(" More.")
            browserView.textViewDidChange(editor)
            await model.autosave.flushNow()

            #expect(try await storedText(db, variantID: seed.a2)
                    == "First block, the other way. More.")
            #expect(try await storedText(db, variantID: seed.a1)
                    == "First block, as chosen.")

            // Moving the live editor to another card moves THE editor
            // (never a second one).
            model.takesBrowser.beginEditing(variantID: seed.a1)
            #expect(editor.superview === browserView.cardViews[seed.a1])
            #expect(editor.text == "First block, as chosen.")
        }
    }

    @Test func theCardGrammarRendersChosenPeekingAndTheMenuDoors() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, surface) = await makeBrowserSurface(session, postID: seed.postID)
            guard let browserView = surface.textView.takesBrowserView else {
                Issue.record("browser view not installed")
                return
            }
            model.takes.flip(blockID: seed.blockA, forward: true)
            model.takesBrowser.open(blockID: seed.blockA)

            let chosenCard = try #require(browserView.cardViews[seed.a1])
            let peekedCard = try #require(browserView.cardViews[seed.a2])

            // The chosen card wears the state, never an inert ✓ door
            // (P-2); the peeked card wears the takes register (the
            // in-page marker's grammar carried into the sheet).
            func subview(_ card: MobileTakesCardView, _ id: String) -> UIView? {
                card.subviews.first { $0.accessibilityIdentifier == id }
            }
            #expect((subview(chosenCard, "takes.card.choose") as? UIButton)?.isHidden == true)
            #expect((subview(peekedCard, "takes.card.choose") as? UIButton)?.isHidden == false)
            #expect((subview(chosenCard, "takes.card.state") as? UILabel)?.text == "✓ chosen")
            #expect((subview(peekedCard, "takes.card.state") as? UILabel)?.text == "peeking")
            #expect(peekedCard.backgroundColor == MobileEditorStyle.face.takeTint)

            // Each card's ⋯ carries exactly the two lifecycle doors.
            let menu = try #require((subview(chosenCard, "takes.card.menu") as? UIButton)?.menu)
            #expect(menu.children.compactMap { ($0 as? UIAction)?.title }
                    == ["Archive Take", "Delete Take"])
        }
    }

    @Test func beginEditingRaisesKeyboardFocusOnTheCardEditor() async throws {
        // The S2 ladder round-1 MINOR-2 pin, window-hosted (first
        // responder needs a window): activating a card raises focus on
        // the ONE card editor — one tap, not two. The on-device keyboard
        // feel still rides the S2 feel round.
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, surface) = await makeBrowserSurface(session, postID: seed.postID)
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 700))
            window.addSubview(surface)
            window.makeKeyAndVisible()
            defer { window.isHidden = true }
            guard let browserView = surface.textView.takesBrowserView else {
                Issue.record("browser view not installed")
                return
            }

            model.takesBrowser.open(blockID: seed.blockA)
            #expect(!browserView.cardEditor.isFirstResponder)

            model.takesBrowser.beginEditing(variantID: seed.a2)
            #expect(browserView.cardEditor.isFirstResponder,
                    "activation raises focus — typing lands instantly")

            // Moving the live editor to another card keeps focus with it.
            model.takesBrowser.beginEditing(variantID: seed.a1)
            #expect(browserView.cardEditor.isFirstResponder)

            // Done resigns (the standing detach posture).
            await model.takesBrowser.close()
            #expect(!browserView.cardEditor.isFirstResponder)
        }
    }

    @Test func theBarsSeventhActOpensTheBrowserOnTheCaretsBlock() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, surface) = await makeBrowserSurface(session, postID: seed.postID)
            let view = surface.textView
            let bar = MobileKeyboardBarController(textView: view)

            // Caret inside the SECOND block (fanless — ⑂ still opens: the
            // browser is the fan-birth door).
            let bStart = ("First block, as chosen.\n" as NSString).length
            view.selectedRange = NSRange(location: bStart + 3, length: 0)
            bar.fireTakes()
            #expect(model.takesBrowser.openBlockID == seed.blockB)
            await model.takesBrowser.close()

            // A caret at a block's very END (the separator seat) still
            // resolves ITS block — the boundary-tolerant read.
            view.selectedRange = NSRange(location: bStart - 1, length: 0)
            bar.fireTakes()
            #expect(model.takesBrowser.openBlockID == seed.blockA)
            await model.takesBrowser.close()
        }
    }

    @Test func theBarsTakesActRefusesHonestlyOutsideAnyBlock() async throws {
        try await withEditorWorld { session, db in
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "empty", profile: .blog)
            }
            let (model, surface) = await makeBrowserSurface(session, postID: post.id)
            let bar = MobileKeyboardBarController(textView: surface.textView)

            // An empty post is all open tail — no block to open on; the
            // door fires and SPEAKS instead of sitting silent (P-2).
            bar.fireTakes()
            #expect(!model.takesBrowser.isOpen)
            #expect(model.statusMessage == "Tap into a block first — takes live on blocks.")
        }
    }

    @Test func theEditMenuOffersTakesInsideABlockAndNotInTheTail() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, surface) = await makeBrowserSurface(session, postID: seed.postID)
            let view = surface.textView
            let delegate = try #require(view.delegate as? MobileEditorGateDelegate)

            // Inside a block: the system's suggestions ride first, then
            // the one custom item (never a second UIEditMenuInteraction —
            // the menu composes onto UITextView's own).
            let suggested = [UIAction(title: "Copy") { _ in }]
            let menu = try #require(delegate.textView(
                view, editMenuForTextIn: NSRange(location: 2, length: 3),
                suggestedActions: suggested))
            let titles = menu.children.compactMap { ($0 as? UIAction)?.title }
            #expect(titles == ["Copy", MobileEditMenu.takesTitle])
            // S4: the Block submenu joins beside Takes… (the ⋯ menu's
            // rows from the ONE builder — the flat Takes… item is
            // byte-untouched; this assertion widened WITH the door).
            #expect(menu.children.compactMap { ($0 as? UIMenu)?.title }
                == [MobileEditMenu.blockTitle])

            // The brain resolves the range's block (boundary-tolerant).
            #expect(MobileEditMenu.takesTarget(
                model: model, range: NSRange(location: 2, length: 3)) == seed.blockA)

            // An empty post's surface is all tail: no block, no item.
            let empty = try await session.runner.run { ops in
                try ops.createPost(title: "tail only", profile: .blog)
            }
            let (emptyModel, emptySurface) = await makeBrowserSurface(session, postID: empty.id)
            let emptyDelegate = try #require(
                emptySurface.textView.delegate as? MobileEditorGateDelegate)
            let tailMenu = try #require(emptyDelegate.textView(
                emptySurface.textView, editMenuForTextIn: NSRange(location: 0, length: 0),
                suggestedActions: suggested))
            #expect(tailMenu.children.compactMap { ($0 as? UIAction)?.title } == ["Copy"])
            let tailSubmenus = tailMenu.children.compactMap { ($0 as? UIMenu)?.title }
            #expect(tailSubmenus == [])
            #expect(MobileEditMenu.takesTarget(
                model: emptyModel, range: NSRange(location: 0, length: 0)) == nil)
        }
    }

    @Test func theBadgeTapOpensTheBrowser_P15Retired() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, surface) = await makeBrowserSurface(session, postID: seed.postID)
            guard let chrome = surface.textView.takesChrome else {
                Issue.record("takes chrome not installed")
                return
            }

            chrome.badgeTapped(seed.blockA)

            // LK3's letter: the tap is the door — the BROWSER opens
            // (batch 1's interim pill reveal, P15, retired as planned);
            // nothing peeked, nothing chosen, nothing written.
            #expect(model.takesBrowser.openBlockID == seed.blockA)
            #expect(!model.takes.isPeeking(seed.blockA))
            #expect(try await chosenVariantID(db, blockID: seed.blockA) == seed.a1)
            #expect(surface.textView.takesBrowserView?.isHidden == false)
        }
    }
}
