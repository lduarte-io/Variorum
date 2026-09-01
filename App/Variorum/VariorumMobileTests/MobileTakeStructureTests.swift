//
//  MobileTakeStructureTests.swift
//  VariorumMobileTests
//
//  Round 2, batch 7 — PL-10(a) and PL-10(d): the fan-ORDER door and the two
//  take↔block doors, on the phone.
//
//  **What these pins can and cannot drive, stated once.** The card ⋯'s rows
//  are UIKit `UIMenu` actions, and a `UIAction`'s handler is not invocable in
//  process (there is no public `perform`) — so the file follows the shape
//  this suite's neighbours already use and the harness header records: the
//  ROW is asserted on the REAL mounted card's REAL `UIMenu` (its title, its
//  order, its presence/absence and its `.disabled` state), and the ACT is
//  driven through the controller method that row is a one-line forward to.
//  The chrome door for "all takes to blocks" IS a real `UIButton`, so that
//  one is driven end to end by sending its `.touchUpInside`.
//

import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - Seeds & probes (file-local, this suite's own convention)

@MainActor
private func seedThreeTakePost(
    _ session: AppSession
) async throws -> (postID: String, blockA: String, a1: String, a2: String, a3: String,
                   blockB: String) {
    try await session.runner.run { ops in
        let post = try ops.createPost(title: "structure", profile: .blog)
        let a = try ops.newBlock(in: post.id, text: "Take one.", at: .end)
        let b = try ops.newBlock(in: post.id, text: "A second block.", at: .end)
        // **Each branch is taken from the PREVIOUS take, deliberately.**
        // `branchVariant` places a branch immediately AFTER ITS SOURCE (not
        // at the fan's end — `MIN(fan_position) > source`), so branching
        // twice from take one would seed `[a1, a3, a2]` and every ordering
        // assertion below would be reading a fan it did not describe.
        // Chaining makes the seed's order `[a1, a2, a3]` and says why.
        let t2 = try ops.branchVariant(a.block.id, from: a.variant.id)
        try ops.autosave(t2.id, text: "Take two.", charDelta: 3)
        let t3 = try ops.branchVariant(a.block.id, from: t2.id)
        try ops.autosave(t3.id, text: "Take three.", charDelta: 5)
        return (post.id, a.block.id, a.variant.id, t2.id, t3.id, b.block.id)
    }
}

@MainActor
private func fanOrder(_ db: AppDatabase, blockID: String) async throws -> [String] {
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
private func variantStatus(_ db: AppDatabase, variantID: String) async throws -> String? {
    try await db.read { db in
        try String.fetchOne(
            db, sql: "SELECT status FROM variant WHERE id = ?", arguments: [variantID])
    }
}

@MainActor
private func blockTexts(_ db: AppDatabase, postID: String) async throws -> [String] {
    try await db.read { db in
        try Queries.renderPost(db, containerID: postID).map { $0.text ?? "" }
    }
}

@MainActor
private func containerStamps(
    _ db: AppDatabase, postID: String
) async throws -> (touched: String?, churn: Double) {
    try await db.read { db in
        let row = try Row.fetchOne(
            db,
            sql: "SELECT last_touched_at, churn_accumulator FROM container WHERE id = ?",
            arguments: [postID])
        return (row?["last_touched_at"], row?["churn_accumulator"] ?? 0)
    }
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

/// Finds a real mounted control by its accessibility identifier anywhere
/// under a view. Written as a plain recursive walk rather than a key-path
/// `flatMap` because a `\.subviews` key path cannot be formed off the main
/// actor inside a `#require` macro expansion (measured, not guessed).
@MainActor
private func descendant(_ root: UIView, _ identifier: String) -> UIView? {
    for child in root.subviews {
        if child.accessibilityIdentifier == identifier { return child }
        if let found = descendant(child, identifier) { return found }
    }
    return nil
}

@MainActor
private func cardMenu(
    _ browserView: MobileTakesBrowserView, _ variantID: String
) throws -> UIMenu {
    let card = try #require(browserView.cardViews[variantID])
    let button = try #require(
        card.subviews.first { $0.accessibilityIdentifier == "takes.card.menu" } as? UIButton)
    return try #require(button.menu)
}

// MARK: - PL-10(a) — reorder takes

@MainActor
@Suite("Mobile takes — the fan's order (round 2, batch 7 · PL-10(a))")
struct MobileTakeReorderTests {
    /// **THE ACT.** A take steps one place, and the STORE's fan order moves
    /// with it — through the core `reorderTake` op, whose fractional-index
    /// arithmetic is its own.
    ///
    /// **Red on old (behavioural revert):** `moveTake`'s `.before(anchor)` /
    /// `.after(anchor)` swapped, or the whole method's op call removed —
    /// either reds the order assertions here.
    @Test func aTakeStepsOnePlaceInTheFanAndTheStoreFollows() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeTakePost(session)
            let (model, _) = await makeBrowserSurface(session, postID: seed.postID)
            model.takesBrowser.open(blockID: seed.blockA)
            #expect(try await fanOrder(db, blockID: seed.blockA)
                == [seed.a1, seed.a2, seed.a3])

            // The LAST take moves up one: 1, 3, 2.
            await model.takesBrowser.moveTake(variantID: seed.a3, by: -1)
            #expect(try await fanOrder(db, blockID: seed.blockA)
                == [seed.a1, seed.a3, seed.a2])
            #expect(model.statusMessage == MobileTakesBrowserController.movedUpNote)

            // And back down: 1, 2, 3 again — the round trip.
            await model.takesBrowser.moveTake(variantID: seed.a3, by: 1)
            #expect(try await fanOrder(db, blockID: seed.blockA)
                == [seed.a1, seed.a2, seed.a3])
            #expect(model.statusMessage == MobileTakesBrowserController.movedDownNote)

            // The CARDS follow the store (the sheet re-reads through the one
            // projection door), which is what makes the ordinal on each card
            // true after a move.
            await model.takesBrowser.moveTake(variantID: seed.a1, by: 1)
            #expect(model.takesBrowser.cards().map(\.variantID)
                == [seed.a2, seed.a1, seed.a3])
        }
    }

    /// **#57(c) — reordering the fan is NOT working on the prose.** No touch
    /// stamp, no churn: rearranging takes must never reshuffle the library's
    /// meaningful sort. The op owns this; the pin exists because a door that
    /// added a touch of its own would be invisible until her library moved.
    @Test func reorderingTheFanTouchesNeitherTheNoteNorItsChurn() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeTakePost(session)
            let (model, _) = await makeBrowserSurface(session, postID: seed.postID)
            model.takesBrowser.open(blockID: seed.blockA)
            let before = try await containerStamps(db, postID: seed.postID)

            await model.takesBrowser.moveTake(variantID: seed.a3, by: -1)

            let after = try await containerStamps(db, postID: seed.postID)
            #expect(after.touched == before.touched)
            #expect(after.churn == before.churn)
        }
    }

    /// **#57(e) — THE END GREYS RATHER THAN VANISHING, and a one-take fan
    /// draws neither row.** The Mac's ruled shape, in menu-row register: the
    /// card's furniture must not jump as takes move.
    ///
    /// **Red on old (behavioural revert):** drop the `attributes:` argument
    /// from the two move `UIAction`s (they become always-enabled) and the
    /// first two halves red; render the pair unconditionally (`if fanned`
    /// removed) and the fanless half reds.
    @Test func theMoveRowsGreyAtTheEndsAndAreAbsentOnAOneTakeFan() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedThreeTakePost(session)
            let (model, surface) = await makeBrowserSurface(session, postID: seed.postID)
            let browserView = try #require(surface.textView.takesBrowserView)

            model.takesBrowser.open(blockID: seed.blockA)
            let up = MobileEditorStyle.chromeCase(MobileTakesBrowserController.moveUpTitle)
            let down = MobileEditorStyle.chromeCase(MobileTakesBrowserController.moveDownTitle)

            func row(_ menu: UIMenu, _ title: String) throws -> UIAction {
                try #require(menu.children.compactMap { $0 as? UIAction }
                    .first { $0.title == title })
            }

            // FIRST card: "up" is present and DISABLED; "down" acts.
            let first = try cardMenu(browserView, seed.a1)
            #expect(try row(first, up).attributes.contains(.disabled))
            #expect(!(try row(first, down).attributes.contains(.disabled)))

            // MIDDLE card: both act.
            let middle = try cardMenu(browserView, seed.a2)
            #expect(!(try row(middle, up).attributes.contains(.disabled)))
            #expect(!(try row(middle, down).attributes.contains(.disabled)))

            // LAST card: "down" is present and DISABLED.
            let last = try cardMenu(browserView, seed.a3)
            #expect(!(try row(last, up).attributes.contains(.disabled)))
            #expect(try row(last, down).attributes.contains(.disabled))

            // A ONE-TAKE fan draws NEITHER row (P-2, and #57(e)'s own last
            // clause) — while every other row is still there, which is what
            // makes this an absence claim over a POPULATED surface.
            await model.takesBrowser.close()
            model.takesBrowser.open(blockID: seed.blockB)
            let fanless = try cardMenu(
                browserView, try #require(model.takesBrowser.cards().first).variantID)
            let titles = fanless.children.map(\.title)
            #expect(!titles.contains(up))
            #expect(!titles.contains(down))
            #expect(titles.contains(
                MobileEditorStyle.chromeCase(MobileTakesBrowserController.archiveTitle)))
            #expect(titles == MobileTakesBrowserController
                .cardRowTitles(fanned: false, locked: false)
                .map { MobileEditorStyle.chromeCase($0) })
        }
    }

    /// **The end refuses BY NAME, from the STORE — never from the frozen
    /// projection.** The disabled row is an enablement hint; a fan that
    /// moved under the card (a remote archive, a Mac delete) is caught here,
    /// and nothing is written.
    ///
    /// **Red on old (behavioural revert):** delete the
    /// `active.indices.contains(target)` guard in `moveTake` and the first
    /// half reds (the op would be handed a nonexistent anchor).
    @Test func steppingPastTheEndSpeaksAndWritesNothing() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeTakePost(session)
            let (model, _) = await makeBrowserSurface(session, postID: seed.postID)
            model.takesBrowser.open(blockID: seed.blockA)

            await model.takesBrowser.moveTake(variantID: seed.a1, by: -1)
            #expect(model.statusMessage == MobileTakesBrowserController.alreadyFirstRefusal)
            #expect(try await fanOrder(db, blockID: seed.blockA)
                == [seed.a1, seed.a2, seed.a3])

            await model.takesBrowser.moveTake(variantID: seed.a3, by: 1)
            #expect(model.statusMessage == MobileTakesBrowserController.alreadyLastRefusal)
            #expect(try await fanOrder(db, blockID: seed.blockA)
                == [seed.a1, seed.a2, seed.a3])
        }
    }

    /// **#57(a)/(b) — a LOCKED take moves, and an ARCHIVED one is neither
    /// stepped onto nor over.** Both are the op's ruled semantics; this pins
    /// that the DOOR composes them rather than adding a guard of its own.
    ///
    /// **Red on old (behavioural revert):** drop `.filter { $0.status ==
    /// .active }` in `moveTake` and the archived half reds — the step would
    /// land beside a card she cannot see.
    @Test func aLockedTakeMovesAndAnArchivedOneIsSteppedNeitherOntoNorOver() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeTakePost(session)
            let (model, _) = await makeBrowserSurface(session, postID: seed.postID)
            model.takesBrowser.open(blockID: seed.blockA)

            // The MIDDLE take is archived: the fan she sees is [a1, a3].
            try await session.runner.run { [a2 = seed.a2] ops in try ops.archiveVariant(a2) }
            await model.refreshTakesFromStore()
            #expect(model.takesBrowser.cards().map(\.variantID) == [seed.a1, seed.a3])

            // Stepping a3 UP lands it beside a1 — the card she was looking
            // at — not on the far side of the archived take.
            await model.takesBrowser.moveTake(variantID: seed.a3, by: -1)
            #expect(try await fanOrder(db, blockID: seed.blockA) == [seed.a3, seed.a1])
            #expect(model.takesBrowser.cards().map(\.variantID) == [seed.a3, seed.a1])

            // A LOCKED take still moves: the lock freezes the BUFFER, not
            // identity metadata (#57(a) — the op's own rule, unguarded here).
            try await session.runner.run { [a1 = seed.a1] ops in try ops.lockVariant(a1) }
            await model.refreshTakesFromStore()
            await model.takesBrowser.moveTake(variantID: seed.a1, by: -1)
            #expect(try await fanOrder(db, blockID: seed.blockA) == [seed.a1, seed.a3])
            #expect(model.statusMessage == MobileTakesBrowserController.movedUpNote)
        }
    }

    /// A SEALED note refuses the move through the op's own guard, and the
    /// door speaks it in the phone's words — never a raw enum dump.
    @Test func aSealedNoteRefusesTheMoveInWords() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeTakePost(session)
            let (model, _) = await makeBrowserSurface(session, postID: seed.postID)
            model.takesBrowser.open(blockID: seed.blockA)
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }

            await model.takesBrowser.moveTake(variantID: seed.a3, by: -1)
            let spoken = try #require(model.statusMessage)
            #expect(spoken == "This note is locked — unlock it to reorder takes.")
            #expect(!spoken.contains("lockedPost"))
            #expect(try await fanOrder(db, blockID: seed.blockA)
                == [seed.a1, seed.a2, seed.a3])
        }
    }
}

// MARK: - PL-10(d) — take ↔ block

@MainActor
@Suite("Mobile takes — take ↔ block (round 2, batch 7 · PL-10(d))")
struct MobileTakeToBlockTests {
    /// **AR-1, composed: the new block gets a COPY and the original is
    /// ARCHIVED** — never a row move. The note gains a block below the
    /// source and the source keeps reading what it read.
    ///
    /// **Red on old (behavioural revert):** remove the `takeToBlockBelow`
    /// call from the door and the whole test reds.
    @Test func aTakeBecomesTheBlockBelowAndTheOriginalIsArchived() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeTakePost(session)
            let (model, _) = await makeBrowserSurface(session, postID: seed.postID)
            model.takesBrowser.open(blockID: seed.blockA)

            await model.takesBrowser.takeToBlockBelow(variantID: seed.a3)

            // The minted block stands IMMEDIATELY below the source, carrying
            // the take's text; the source block still shows take one.
            #expect(try await blockTexts(db, postID: seed.postID)
                == ["Take one.", "Take three.", "A second block."])
            // The original is ARCHIVED (a), not deleted — it keeps its
            // commits, and the archived listing is the road back.
            #expect(try await variantStatus(db, variantID: seed.a3) == "archived")
            #expect(try await fanOrder(db, blockID: seed.blockA) == [seed.a1, seed.a2])
            #expect(model.statusMessage == MobileTakeStructureCopy.movedNote)
            #expect(model.statusAction == .undo)
        }
    }

    /// **THE UNDO ENTRY IS THE OP'S, AND THERE IS EXACTLY ONE.** The door
    /// registers nothing — a second registration would be two entries for
    /// one act, and one undo would leave the store half-reverted.
    ///
    /// **Red on old (behavioural revert):** add a `session.undoStack
    /// .register(...)` beside the op call in `takeToBlockBelow` and the
    /// count assertion reds.
    @Test func theConversionRegistersExactlyOneUndoEntryAndItRoundTrips() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeTakePost(session)
            let (model, _) = await makeBrowserSurface(session, postID: seed.postID)
            model.takesBrowser.open(blockID: seed.blockA)
            let before = session.undoStack.depth

            await model.takesBrowser.takeToBlockBelow(variantID: seed.a3)
            #expect(session.undoStack.depth == before + 1)

            // ONE undo returns the store whole: the minted block goes, the
            // archived take comes back.
            _ = try await session.runner.run { [stack = session.undoStack] ops in
                try stack.undo(with: ops)
            }
            #expect(try await blockTexts(db, postID: seed.postID)
                == ["Take one.", "A second block."])
            #expect(try await variantStatus(db, variantID: seed.a3) == "active")

            // And REDO puts it back (13c A10: every leg carries both halves).
            _ = try await session.runner.run { [stack = session.undoStack] ops in
                try stack.redo(with: ops)
            }
            #expect(try await blockTexts(db, postID: seed.postID)
                == ["Take one.", "Take three.", "A second block."])
            #expect(try await variantStatus(db, variantID: seed.a3) == "archived")
        }
    }

    /// **#58(c)/(d) — the whole fan converts, the block KEEPS SHOWING what
    /// it showed, and blank takes are skipped AND counted in the receipt.**
    ///
    /// **Red on old (behavioural revert):** drop `skippedBlanks:` from the
    /// receipt call (pass 0) and the receipt half reds while the store half
    /// stays green — which is the point: the count is a promise the door
    /// makes, and a silent skip is what #58(d) exists to prevent.
    @Test func allTakesBecomeBlocksBelowAndTheReceiptCountsTheBlanksItSkipped() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeTakePost(session)
            // A fourth, BLANK take — nothing to make a block from.
            let blank = try await session.runner.run { [a = seed.blockA] ops in
                try ops.newBlankVariant(a)
            }
            let (model, _) = await makeBrowserSurface(session, postID: seed.postID)
            model.takesBrowser.open(blockID: seed.blockA)

            await model.takesBrowser.takesToBlocks()

            // The note reads exactly as it read, with the alternates below.
            #expect(try await blockTexts(db, postID: seed.postID)
                == ["Take one.", "Take two.", "Take three.", "A second block."])
            // The shown take STAYED; the two with prose left; the blank did
            // not (it is still an active take of the source block).
            #expect(try await fanOrder(db, blockID: seed.blockA) == [seed.a1, blank.id])
            #expect(try await variantStatus(db, variantID: seed.a2) == "archived")
            #expect(try await variantStatus(db, variantID: seed.a3) == "archived")

            let spoken = try #require(model.statusMessage)
            #expect(spoken == MobileTakeStructureCopy.convertedNote(
                blocks: 2, skippedBlanks: 1))
            #expect(spoken.contains("1 blank take was left alone"))
            #expect(model.statusAction == .undo)
        }
    }

    /// **The chrome door, driven end to end** — a real `UIButton` in the
    /// mounted sheet, and it renders ONLY where it can act (P-2).
    ///
    /// **Red on old (behavioural revert):** set `takesToBlocksButton
    /// .isHidden = false` unconditionally and the fanless half reds; remove
    /// its `.touchUpInside` action and the driven half does.
    @Test func theAllTakesToBlocksDoorRendersOnlyOnAFanAndActsWhenPressed() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeTakePost(session)
            let (model, surface) = await makeBrowserSurface(session, postID: seed.postID)
            let browserView = try #require(surface.textView.takesBrowserView)
            @MainActor func door() throws -> UIButton {
                let found = descendant(browserView, "takes.browser.takesToBlocks")
                return try #require(found as? UIButton)
            }

            // A FANLESS block: the row is not there at all, while the mint
            // footer beside it is — an absence over a POPULATED surface.
            model.takesBrowser.open(blockID: seed.blockB)
            surface.layoutIfNeeded()
            #expect(try door().isHidden)
            let branch = descendant(browserView, "takes.browser.branch")
            #expect(try #require(branch).isHidden == false)

            // A FANNED block: the row appears and the press converts.
            await model.takesBrowser.close()
            model.takesBrowser.open(blockID: seed.blockA)
            surface.layoutIfNeeded()
            #expect(!(try door().isHidden))
            #expect(try door().title(for: .normal) == MobileEditorStyle.chromeCase(
                MobileTakesBrowserController.takesToBlocksTitle))

            try door().sendActions(for: .touchUpInside)
            try await Task.sleep(nanoseconds: 200_000_000)
            #expect(try await blockTexts(db, postID: seed.postID)
                == ["Take one.", "Take two.", "Take three.", "A second block."])
        }
    }

    /// **THE ROW STANDS DOWN WHILE SHE TYPES — AND IT COMES BACK** (the
    /// batch-7 fix wave, cold review MAJOR 2).
    ///
    /// The batch hid the actions row while a card is live, for a real
    /// reason (the A1 gate defect: with the keyboard up, 30 pt of chrome
    /// cut the live card's top off). But the rule it was justified by is
    /// *"while a take is being WRITTEN"*, and nothing a user could do ended
    /// a card's live state — every caller of `endEditing()` was either the
    /// sheet's own close, the opening of a DIFFERENT block, or a remote
    /// vanish — so the row disappeared on an ordinary action and came back
    /// only by closing the whole browser and reopening it.
    ///
    /// The road is iOS's own, on the scroll this sheet already owns: the
    /// card list dismisses the keyboard on a drag, that resigns the shared
    /// card editor, and the live state now FOLLOWS the responder. Driven
    /// here through the real responder transition that dismissal performs.
    ///
    /// **Red on old (behavioural revert):** delete
    /// `MobileTakesBrowserView.textViewDidEndEditing` and the card stays
    /// live after the resign, so the row never returns — the third block
    /// below reds, and the act it holds is unreachable.
    @Test func endingACardsLiveStateBringsTheActionsRowBack() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeTakePost(session)
            let (model, surface) = await makeBrowserSurface(session, postID: seed.postID)
            let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 700))
            window.addSubview(surface)
            window.makeKeyAndVisible()
            defer { window.isHidden = true }
            let browserView = try #require(surface.textView.takesBrowserView)
            @MainActor func door() throws -> UIButton {
                try #require(descendant(browserView, "takes.browser.takesToBlocks") as? UIButton)
            }
            @MainActor func cardsScroll(in root: UIView) -> UIScrollView? {
                for sub in root.subviews {
                    if let scroll = sub as? UIScrollView, !(scroll is UITextView) {
                        return scroll
                    }
                    if let hit = cardsScroll(in: sub) { return hit }
                }
                return nil
            }

            // 1 — a fanned block at rest: the row is there.
            model.takesBrowser.open(blockID: seed.blockA)
            surface.layoutIfNeeded()
            #expect(!(try door().isHidden))

            // 2 — a card goes live and the row stands down (the shipped
            // rule, and the 30 pt the A1 pin is about).
            model.takesBrowser.beginEditing(variantID: seed.a2)
            surface.layoutIfNeeded()
            #expect(try door().isHidden)
            #expect(browserView.cardEditor.isFirstResponder)

            // THE CONTROL: moving the live editor to ANOTHER card is the
            // app rehosting its one editor, not her stopping — the resign
            // that transition performs must never end the live state.
            model.takesBrowser.beginEditing(variantID: seed.a3)
            #expect(model.takesBrowser.editingVariantID == seed.a3)
            surface.layoutIfNeeded()
            #expect(try door().isHidden)

            // 3 — HER ROAD OUT: the card list puts the keyboard away on a
            // drag, which resigns the card editor. The gesture is the
            // scroll's own dismiss mode; the resign is what it delivers.
            #expect(cardsScroll(in: browserView)?.keyboardDismissMode == .onDrag)
            _ = browserView.cardEditor.resignFirstResponder()
            #expect(model.takesBrowser.editingVariantID == nil,
                    "the live state follows the responder")
            surface.layoutIfNeeded()
            #expect(!(try door().isHidden), "the row comes back")

            // …and it ACTS — the door is not merely drawn again.
            try door().sendActions(for: .touchUpInside)
            try await Task.sleep(nanoseconds: 200_000_000)
            #expect(try await blockTexts(db, postID: seed.postID)
                == ["Take one.", "Take two.", "Take three.", "A second block."])
        }
    }

    /// **The one-take refusal SPEAKS, and it names the phone's own door.**
    /// I10 through this door means "there is no other take left behind", so
    /// pointing at Delete Block (the delete door's answer) would be wrong —
    /// and pointing at a Mac chord would be the no-redirect breach.
    ///
    /// **Red on old (behavioural revert):** delete the `case
    /// .lastActiveVariant where verb == .takeToBlock` arm and the sentence
    /// falls through to the delete door's words — the assertion reds.
    @Test func movingTheOnlyTakeOutRefusesAndNamesDivideOnThisPhone() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeTakePost(session)
            let (model, _) = await makeBrowserSurface(session, postID: seed.postID)
            model.takesBrowser.open(blockID: seed.blockB)
            let only = try #require(model.takesBrowser.cards().first).variantID

            await model.takesBrowser.takeToBlockBelow(variantID: only)

            let spoken = try #require(model.statusMessage)
            #expect(spoken.contains(MobileBlockMenuController.divideTitle))
            #expect(!spoken.contains("⌘"))
            #expect(!spoken.contains("lastActiveVariant"))
            #expect(!spoken.contains("Delete Block"))
            // Nothing was minted.
            #expect(try await blockTexts(db, postID: seed.postID).count == 2)
        }
    }

    /// **A BLANK take refuses by name rather than minting an empty block**
    /// (#58(d)'s single-take half), and the words are the Mac's own — this
    /// error had no arm on the phone before and would have dumped the raw
    /// enum.
    @Test func aBlankTakeRefusesToBecomeABlockInWords() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeTakePost(session)
            let blank = try await session.runner.run { [a = seed.blockA] ops in
                try ops.newBlankVariant(a)
            }
            let (model, _) = await makeBrowserSurface(session, postID: seed.postID)
            model.takesBrowser.open(blockID: seed.blockA)

            await model.takesBrowser.takeToBlockBelow(variantID: blank.id)

            let spoken = try #require(model.statusMessage)
            #expect(spoken == "That take is empty — there's no text to become a block.")
            #expect(!spoken.contains("emptyTakeCannotBecomeABlock"))
            #expect(try await blockTexts(db, postID: seed.postID).count == 2)
        }
    }

    /// **The card ⋯ carries the new row in the ruled ORDER, and the order
    /// lives in ONE place** (`cardRowTitles`, which is also what the drift
    /// pin reads). `Take to New Block Below` is deliberately NOT
    /// `.destructive`: nothing is destroyed.
    ///
    /// **Red on old (behavioural revert):** move the take→block row below
    /// Delete Take in `apply` and the order assertion reds; give it
    /// `.destructive` and the last half does.
    @Test func theCardMenuCarriesTheStructureRowInOrderAndItIsNotDestructive() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedThreeTakePost(session)
            let (model, surface) = await makeBrowserSurface(session, postID: seed.postID)
            let browserView = try #require(surface.textView.takesBrowserView)
            model.takesBrowser.open(blockID: seed.blockA)

            let menu = try cardMenu(browserView, seed.a2)
            #expect(menu.children.map(\.title)
                == MobileTakesBrowserController
                    .cardRowTitles(fanned: true, locked: false)
                    .map { MobileEditorStyle.chromeCase($0) })
            #expect(MobileTakesBrowserController.cardRowTitles(fanned: true, locked: false)
                == ["Block History…", "Label Take…", "Move Take Up", "Move Take Down",
                    "Lock Take", "Take to New Block Below", "Archive Take", "Delete Take"])

            let structure = try #require(
                menu.children.compactMap { $0 as? UIAction }.first {
                    $0.title == MobileEditorStyle.chromeCase(
                        MobileTakesBrowserController.takeToBlockTitle)
                })
            #expect(!structure.attributes.contains(.destructive))
            let delete = try #require(
                menu.children.compactMap { $0 as? UIAction }.first {
                    $0.title == MobileEditorStyle.chromeCase(
                        MobileTakesBrowserController.deleteTitle)
                })
            #expect(delete.attributes.contains(.destructive))
        }
    }

    /// **The structural doors take the LATCH** — the `commitNow` rider's own
    /// criterion applied forward, because the chrome door is a persistent
    /// button and both doors await a flush before they write.
    ///
    /// **WHAT THE LATCH ACTUALLY CHANGES, TRACED RATHER THAN ASSUMED — and
    /// the first version of this pin was HOLLOW, which is recorded here
    /// rather than quietly fixed.** It first asserted the STORE, on the
    /// guess that a second flight would mint a second run of blocks. It
    /// passed with the latch REMOVED: the op is not idempotent by accident
    /// but by validation — the second flight finds every alternate already
    /// archived and throws `noConvertibleTakes`, so the rows are right
    /// either way.
    ///
    /// The real difference is what she READS. Without the latch the second
    /// flight's refusal lands on the status line and OVERWRITES the receipt
    /// she earned — *"This block has no other takes with text in them"* about
    /// a conversion that just succeeded. With it, the second flight returns
    /// the latch's `nil`, which is its whole documented contract: *"`nil`
    /// means this gesture was already in flight, which is not a refusal and
    /// must never be reported as one."*
    ///
    /// **Red on old (behavioural revert):** replace `structureLatch.run` with
    /// a fresh `MobileWriteLatch().run` (a latch that never latches) and the
    /// RECEIPT assertion reds while the store assertion stays green — which
    /// is precisely the finding.
    @Test func aSecondPressWhileTheConversionIsInFlightIsNotReportedAsARefusal() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedThreeTakePost(session)
            let (model, _) = await makeBrowserSurface(session, postID: seed.postID)
            model.takesBrowser.open(blockID: seed.blockA)

            async let first: Void = model.takesBrowser.takesToBlocks()
            async let second: Void = model.takesBrowser.takesToBlocks()
            _ = await (first, second)

            // Exactly ONE conversion landed (true with OR without the latch —
            // the op validates; kept as the control that says so).
            #expect(try await blockTexts(db, postID: seed.postID)
                == ["Take one.", "Take two.", "Take three.", "A second block."])

            // And the RECEIPT she earned is the one still on screen.
            #expect(model.statusMessage == MobileTakeStructureCopy.convertedNote(
                blocks: 2, skippedBlanks: 0))
            #expect(model.statusMessage?.contains("no other takes") != true)
            #expect(model.statusAction == .undo)
        }
    }
}
