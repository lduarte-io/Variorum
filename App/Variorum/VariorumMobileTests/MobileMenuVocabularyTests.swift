//
//  MobileMenuVocabularyTests.swift
//  VariorumMobileTests
//
//  **ROUND 2, BATCH 9 — THE ⋯ VOCABULARY, held where she moved it.**
//  Her letter (2026-08-23,
//  `notes/author-reports/2026-08-23-device-walk-and-product-asks.md`)
//  named three things about the phone's ⋯ menus, and this suite holds all
//  three of them as facts rather than as intentions:
//
//  1. **Structural undo/redo in the note ⋯** — *"i want it easy to
//     access."* ALREADY BUILT (M20, batch 4 — after the 2026-08-21 build
//     her phone is running). The undo half was already driven end to end
//     (`MobileUndoDoorTests.theNoteActionsSheetUndoRowIsReachableAndActs`);
//     the REDO half had a receipt pin and no sheet pin, so it gets one
//     here.
//  2. **`Takes…` leaves the block ⋯** — *"it's already the middle bar."*
//     An ABSENCE over a POPULATED menu, beside a drive of the door that
//     stays: the bar's ⑂ really opens the browser (P-2 — removing a second
//     door must not orphan the capability).
//  3. **Block History moves to the per-take ⋯** — and the move is only
//     worth anything if the face arrives FOCUSED on the take whose card
//     was pressed, so the pin asserts that and not merely that a sheet
//     opened.
//
//  Every menu row here is driven through its real `UIAction` handler
//  (`MenuActionHandler`), which is the exact closure UIKit runs on a tap;
//  every SwiftUI row through `accessibilityActivate()` on the mounted
//  surface.
//

import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
private func seedFannedTwoBlockPost(
    _ session: AppSession
) async throws -> (postID: String, blockA: String, a1: String, a2: String, blockB: String) {
    try await session.runner.run { ops in
        let post = try ops.createPost(title: "menus", profile: .blog)
        let a = try ops.newBlock(in: post.id, text: "First block, as chosen.", at: .end)
        let b = try ops.newBlock(in: post.id, text: "Second block, fanless.", at: .end)
        let take = try ops.branchVariant(a.block.id, from: a.variant.id)
        try ops.autosave(take.id, text: "First block, the other way.", charDelta: 9)
        // A savepoint on EACH take, so "which run is expanded" is a
        // question the face can actually answer differently.
        _ = try ops.commit(a.variant.id, kind: .manual)
        _ = try ops.commit(take.id, kind: .manual)
        return (post.id, a.block.id, a.variant.id, take.id, b.block.id)
    }
}

@MainActor
private func cardMenuTitles(
    _ view: MobileTakesBrowserView, variantID: String
) throws -> [String] {
    let card = try #require(view.cardViews[variantID])
    let button = try #require(
        card.subviews.first { $0.accessibilityIdentifier == "takes.card.menu" } as? UIButton)
    return try #require(button.menu).children.compactMap { ($0 as? UIAction)?.title }
}

@MainActor
private func cardMenuElements(
    _ view: MobileTakesBrowserView, variantID: String
) throws -> [UIMenuElement] {
    let card = try #require(view.cardViews[variantID])
    let button = try #require(
        card.subviews.first { $0.accessibilityIdentifier == "takes.card.menu" } as? UIButton)
    return try #require(button.menu).children
}

@MainActor
@Suite("Mobile ⋯ vocabulary — her batch-9 moves")
struct MobileMenuVocabularyTests {

    // MARK: - D2 · Takes… leaves the block ⋯, and the middle bar still acts

    /// **THE ABSENCE, over a menu that is otherwise FULL** — never a
    /// vacuous check against an empty list — **and the surviving door
    /// driven in the same pin**, because her reason for removing the row
    /// was that another door already does the job, and a removal is only
    /// safe if that is true.
    ///
    /// **Red on old (behavioural revert):** put the `Takes…` element back
    /// into `MobileBlockMenuController.menuElements` (and its title back on
    /// `rowTitles`) and the absence assertions red.
    @Test func theBlockMenuDropsTakesAndTheBarsMiddleActStillOpensTheBrowser() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedFannedTwoBlockPost(session)
            let (model, surface) = await makeBrowserSurfaceForMenus(
                session, postID: seed.postID)

            // The menu is POPULATED — this is not an empty-list pass.
            let titles = model.blockMenu.menuElements(blockID: seed.blockA).map(\.title)
            #expect(titles.count >= 8, "the block ⋯ is full: \(titles)")
            #expect(!titles.contains(MobileEditorStyle.chromeCase("Takes…")),
                    "no takes row survives in the block ⋯: \(titles)")
            #expect(!MobileBlockMenuController.rowTitles.contains("Takes…"))

            // …and the DOOR SHE NAMED really acts: the bar's middle act (⑂)
            // opens the browser on the caret's block. Driven through the
            // real controller the real button targets.
            let bar = MobileKeyboardBarController(textView: surface.textView)
            // **"⑂ is literally the middle" — asserted against the REAL
            // BAR** (batch 9's fix wave, cold-review NIT 2). This line
            // used to compare `restingActLabels` to its own literal,
            // which cannot fail; `MobileMarkdownTests` already anchors
            // that constant to the rendered items, so what this pin owed
            // was the LINK from the middle door to the act fired below.
            let toolbar = try #require(bar.makeBar() as? UIToolbar)
            // The label rides the item OR its custom view (the ⋯ door is
            // a button) — the markdown suite's own walk shape.
            func label(_ item: UIBarButtonItem) -> String? {
                item.accessibilityLabel
                    ?? (item.customView as? UIButton)?.accessibilityLabel
            }
            let acts = (toolbar.items ?? []).filter { label($0) != nil }
            #expect(acts.count == 3, "the resting bar is three doors")
            #expect(acts.compactMap(label)
                    == MobileKeyboardBarController.restingActLabels)
            #expect(acts[1].action == #selector(MobileKeyboardBarController.fireTakes),
                    "the middle door is the act this pin then fires")
            let range = try #require(model.rangeOfBlock(seed.blockA))
            surface.textView.selectedRange = NSRange(location: range.location + 1, length: 0)
            #expect(!model.takesBrowser.isOpen)
            bar.fireTakes()
            #expect(model.takesBrowser.isOpen, "the middle bar opens the browser")
            #expect(model.takesBrowser.openBlockID == seed.blockA)
        }
    }

    // MARK: - D3 · Block History moves to the per-take ⋯

    /// **HER MOVE, driven end to end from the take card's own ⋯ row**, and
    /// the assertion that makes the move worth making: the face opens
    /// FOCUSED on the take whose card was pressed — not on the block's
    /// displayed take, which is all the retired block-⋯ row could ever know.
    ///
    /// **Red on old (behavioural revert):** drop the history `UIAction` from
    /// `MobileTakesCardView.apply`'s menu and `MenuActionHandler.activate`
    /// returns false — the row is not there to drive. Revert the FOCUS
    /// instead (`open(blockID:focused:)` ignoring `focused`) and the
    /// expansion assertion reds while the rest stays green.
    @Test func theTakeCardsMenuOpensBlockHistoryFocusedOnThatTake() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedFannedTwoBlockPost(session)
            let (model, surface) = await makeBrowserSurfaceForMenus(
                session, postID: seed.postID)
            let browserView = try #require(surface.textView.takesBrowserView)

            model.takesBrowser.open(blockID: seed.blockA)
            #expect(model.takesBrowser.openBlockID == seed.blockA)

            // The row exists on the SECOND take's card — the one that is
            // NOT the block's chosen/displayed take, so "focused" can only
            // be right for one reason.
            let titles = try cardMenuTitles(browserView, variantID: seed.a2)
            #expect(titles.first
                    == MobileEditorStyle.chromeCase(
                        MobileTakesBrowserController.historyTitle),
                    "history leads the take card's ⋯: \(titles)")

            #expect(MenuActionHandler.activate(
                MobileEditorStyle.chromeCase(MobileTakesBrowserController.historyTitle),
                in: try cardMenuElements(browserView, variantID: seed.a2)),
                    "the history row's real handler must be drivable")
            for _ in 0..<40 {
                try? await Task.sleep(for: .milliseconds(10))
                await Task.yield()
            }

            // One sheet at a time: the browser let go, the face is up.
            #expect(!model.takesBrowser.isOpen, "the browser closed before the face opened")
            #expect(model.blockHistory.isOpen)
            #expect(model.blockHistory.openBlockID == seed.blockA)
            #expect(model.blockHistory.focusedVariantID == seed.a2,
                    "the face focuses the take whose card was pressed")
            #expect(model.blockHistory.expandedTakes == [seed.a2],
                    "…and that take's savepoint run is the expanded one")

            // The face really rendered that take's savepoints, not the
            // other take's (both have one, so this can tell them apart).
            let savepoints = model.blockHistory.rows().compactMap { row -> String? in
                if case .savepoint(let variantID, _, _) = row { return variantID }
                return nil
            }
            #expect(savepoints == [seed.a2], "rows were \(model.blockHistory.rows().count)")
        }
    }

    /// The other half of "MOVE": the block ⋯ has no history row left, held
    /// over a populated menu.
    ///
    /// **Red on old:** restore the `historyTitle` element in
    /// `menuElements` and this reds.
    @Test func theBlockMenuNoLongerCarriesTheHistoryDoor() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedFannedTwoBlockPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            let titles = model.blockMenu.menuElements(blockID: seed.blockA).map(\.title)
            #expect(titles.count >= 8, "the block ⋯ is full: \(titles)")
            #expect(!titles.contains { $0.localizedCaseInsensitiveContains("history") },
                    "the history door left this menu: \(titles)")
            // Commit STAYED — she moved the listing, not the act.
            #expect(titles.contains(
                MobileEditorStyle.chromeCase(MobileBlockMenuController.commitTitle)))
        }
    }

    /// **THE ORDER IS THE CONTRACT, and it is pinned because the wrong order
    /// STRANDS HER EDITOR READ-ONLY** — measured during deliverable 5's
    /// trace, not guessed.
    ///
    /// Three overlay sheets (takes browser · comments · block history) each
    /// save the page's `isEditable`, force it false, and restore what they
    /// saved. Interleave two and the inner one saves the OUTER one's `false`,
    /// so the last restore leaves the page non-editable with no sheet up. The
    /// probe drove exactly that and read `editable=false` at the end.
    ///
    /// Batch 9's new door is the first road in the app that goes from one of
    /// these sheets to another, so it is the first that could produce it.
    /// `openHistory` closes the browser BEFORE opening the face, which makes
    /// the pairs properly nested — and this pin is what keeps that true.
    ///
    /// **Red on old (behavioural revert):** swap the two lines in
    /// `MobileTakesBrowserController.openHistory` so the face opens before
    /// the browser closes, and the final assertion reds with the page stuck
    /// read-only.
    @Test func theHistoryDoorLeavesThePageEditableAfterwards() async throws {
        try await withEditorWorld { session, _ in
            let seed = try await seedFannedTwoBlockPost(session)
            let (model, surface) = await makeBrowserSurfaceForMenus(
                session, postID: seed.postID)
            let browserView = try #require(surface.textView.takesBrowserView)
            #expect(surface.textView.isEditable, "the page starts editable")

            model.takesBrowser.open(blockID: seed.blockA)
            browserView.render()
            #expect(!surface.textView.isEditable, "the browser stands the page down")

            await model.takesBrowser.openHistory(variantID: seed.a2)
            surface.textView.takesBrowserView?.render()
            surface.textView.blockHistorySheetView?.render()
            #expect(model.blockHistory.isOpen)

            model.blockHistory.close()
            surface.textView.blockHistorySheetView?.render()
            #expect(surface.textView.isEditable,
                    "with both sheets down the page is writable again")
        }
    }

    // MARK: - D1 · the verify-first half: REDO is already reachable and acts

    /// **Her first ask was already built** (M20, batch 4 — one day after the
    /// build her phone is running), and the undo half is already pinned
    /// through the sheet. This is the REDO half, which had only a RECEIPT
    /// pin: open the REAL masthead ⋯, find the REAL "Redo …" row, press it,
    /// and read the store.
    ///
    /// **Red on old (behavioural revert):** delete `redoRow` from
    /// `MobileNoteActionsSheet`'s body and the row's label is absent, so the
    /// `activate` fails and the store assertion reds with it.
    @Test func theNoteActionsSheetRedoRowIsReachableAndActs() async throws {
        try await withEditorWorld { session, db in
            let postID = try await makePost(
                session, blocks: ["Keep me.", "Delete me."])
            let (model, _) = await makeSurfaceEditor(session, postID: postID)
            await model.structural.deleteBlock(blockID: model.index.entries[1].blockID)
            await model.undoDoor.beginUndo(from: .receipt)
            #expect(try await storedBlockTexts(db, postID: postID)
                == ["Keep me.", "Delete me."], "the undo landed; a redo is now offered")

            try await withHostedSurface(
                MobileWriteScreen(session: session, postID: postID, editor: model)
            ) { surface in
                #expect(surface.activate(MobileNoteActionsSheet.doorLabel),
                        "the ⋯ door is on the masthead and activates")
                await surface.settle(40)
                #expect(surface.visibleLabels.contains("Redo Delete Block"),
                        "labels were \(surface.visibleLabels)")
                #expect(surface.activate("Redo Delete Block"))
                await surface.settle(40)
            }
            #expect(try await storedBlockTexts(db, postID: postID) == ["Keep me."])
        }
    }
}

/// The browser harness, file-local (the takes suite's own shape).
@MainActor
private func makeBrowserSurfaceForMenus(
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
