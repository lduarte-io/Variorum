//
//  TakesChooseRingTests.swift
//  VariorumTests
//
//  VX-222 (the VX-214 run) — her report: *"when you're in write mode, then
//  make a new take, then open takes mode, clicking on the choose button of
//  the new take is not replacing it as the chosen one … when you choose the
//  NEW take you just made (that isn't chosen), that works, but then choosing
//  the ORIGINAL take doesn't work anymore … the command always works."*
//
//  THE MECHANISM (traced and reproduced live; the run record's VX-222 RECORD
//  in `notes/plans/fixes/vx-214-settings-launch-polish.md`): the button and
//  ⌘⏎ are ONE road (`TakesViewModel.choose`), and the op always lands. What
//  fails is the RING. Arriving in Takes, the landing puts the ring on the
//  ARTICLE cell, keyed to the chosen (original) take. Choosing the new take
//  re-resolves the article — a stable-identity pane — to the new take, which
//  turns it read-only, but the ring stays keyed to the original: a pane
//  nothing renders. Choosing the original back makes that same pane LIVE in
//  place, and a live pane is buffer-authoritative (it never adopts projection
//  text) — so the page keeps showing the NEW take's words under the
//  original's ✓, and a keystroke there would write those words into the
//  ORIGINAL take. ⌘⏎ only "works" because it needs a click INTO a card
//  first, which moves the ring off the article.
//
//  THE RULE these pins hold (the architect's ruling, 2026-10-13): a ring whose
//  article cell changes take under it ENDS, by a flushed blur, at the one
//  projection door (`adopt`) — keyed on the column's MODEL resolution, never
//  on the viewport (a ring scrolled away keeps its place).
//
//  RED ON OLD: the first three tests; the last two are guards that hold on
//  both sides (rider 1 and the ⌘⏎ road).
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

private let originalText = "The original take, as the note first said it."
private let changedText = "The original take, with a few changed words."

@MainActor
private func freshDefaults(_ name: String) -> UserDefaults {
    let suite = "TakesChooseRingTests-\(name)"
    let defaults = UserDefaults(suiteName: suite)!
    defaults.removePersistentDomain(forName: suite)
    return defaults
}

/// One note, one block: the original take (chosen) and the take she made of
/// it in Write — minted through Write's take panel's own door (`branchTake`,
/// the ring onto the mint, a few words changed), exactly as the tour has her
/// do it. A second, plain block rides along for the guards.
@MainActor
private struct ChooseWorld {
    let postID: String
    let blockID: String
    let originalID: String
    let mintID: String
    let otherBlockID: String
    let otherVariantID: String

    static func make(_ session: AppSession, _ db: AppDatabase, defaults: UserDefaults) async throws -> ChooseWorld {
        let post = try session.operations.createPost(title: "the choose post")
        let minted = try session.operations.newBlock(in: post.id, text: originalText)
        let other = try session.operations.newBlock(in: post.id, text: "A second block, never fanned.")
        // Write's take panel: its OWN model (the panel-host shape — no
        // landings), the growth door's two calls, then her changed words.
        let panel = TakesViewModel(session: session, postID: post.id, defaults: defaults)
        panel.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
        let minting = await panel.branchTake(blockID: minted.block.id, from: minted.variant.id)
        let mint = try #require(minting)
        panel.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
        panel.focus(.init(columnID: "write-panel-main", blockID: minted.block.id, variantID: mint.id))
        panel.paneEdited(variantID: mint.id, newText: changedText)
        panel.teardown()
        await panel.autosave.flushNow()
        return ChooseWorld(
            postID: post.id, blockID: minted.block.id, originalID: minted.variant.id,
            mintID: mint.id, otherBlockID: other.block.id, otherVariantID: other.variant.id)
    }
}

@MainActor
private func withChooseWorld<T>(
    _ name: String,
    _ body: @MainActor (AppSession, AppDatabase, ChooseWorld, UserDefaults) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 222))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let defaults = freshDefaults(name)
        let world = try await ChooseWorld.make(session, db, defaults: defaults)
        return try await body(session, db, world, defaults)
    }
}

private func storeText(_ db: AppDatabase, _ variantID: String) async throws -> String {
    try await db.read { db in
        try String.fetchOne(
            db, sql: "SELECT working_text FROM variant WHERE id = ?",
            arguments: [variantID]) ?? "MISSING"
    }
}

private func chosen(_ db: AppDatabase, _ blockID: String) async throws -> String? {
    try await db.read { db in
        try String.fetchOne(
            db,
            sql: "SELECT chosen_variant_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
            arguments: [blockID])
    }
}

@MainActor
@Suite("Takes choose — the article ring (VX-222)", .serialized)
struct TakesChooseRingTests {
    private func pump(_ seconds: TimeInterval = 0.03) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool, maxTurns: Int = 60
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            if predicate() { return }
        }
    }

    private func panes(in view: NSView) -> [PaneTextView] {
        var found: [PaneTextView] = []
        if let pane = view as? PaneTextView { found.append(pane) }
        for sub in view.subviews { found.append(contentsOf: panes(in: sub)) }
        return found
    }

    private func articlePane(_ hosting: NSView) -> PaneTextView? {
        panes(in: hosting).first { $0.identifier?.rawValue.hasPrefix("pane:article|") == true }
    }

    private func fresh(_ db: AppDatabase, _ postID: String) async throws -> Queries.TakesProjection {
        try await db.read { try Queries.takesProjection($0, post: postID) }
    }

    // MARK: - Her flow, on the real board (RED ON OLD)

    /// Write's panel mints the take and she changes a few words; "Open Takes
    /// mode" parks the `.bloom` landing; the REAL board mounts with its
    /// observation running; then the card button's exact call — `choose` —
    /// new, then the original back. The page must show the original, and no
    /// pane she can type into may hold another take's words: the worst
    /// consequence (her keystroke writing the new take's text into the
    /// original) is driven through the real edit door wherever it is open.
    @Test func choosingTheOriginalBackShowsItAndNoKeystrokeReachesTheWrongTake() async throws {
        try await withChooseWorld("flow") { session, db, world, defaults in
            // "Open Takes mode" (`WriteTakesPanel`'s act).
            session.commandRouter.pendingTakesLanding =
                .bloom(postID: world.postID, blockID: world.blockID)
            let board = TakesViewModel(session: session, postID: world.postID, defaults: defaults)
            let observing = Task { await board.start() }
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1200, height: 800),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                board.teardown()
                observing.cancel()
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: TakesBoardView(session: session, postID: world.postID, model: board))
            hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 800)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: {
                articlePane(hosting) != nil && board.focusedPane != nil
            })

            // Her entry state (non-vacuity): the landing rang the ARTICLE,
            // keyed to the original — the chosen take.
            let entryRing = TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: world.blockID, variantID: world.originalID)
            #expect(board.focusedPane == entryRing, "the landing rings the article on the original")
            #expect(articlePane(hosting)?.string == originalText)

            // The card button's call: the NEW take.
            await board.choose(blockID: world.blockID, variantID: world.mintID)
            await settle(window, hosting, until: {
                articlePane(hosting)?.identifier?.rawValue == "pane:article|\(world.mintID)"
            })
            #expect(try await chosen(db, world.blockID) == world.mintID)
            #expect(articlePane(hosting)?.string == changedText,
                    "choosing the new take shows it — the half of her report that worked")

            // …and the ORIGINAL back — the half that failed.
            await board.choose(blockID: world.blockID, variantID: world.originalID)
            await settle(window, hosting, until: {
                articlePane(hosting)?.identifier?.rawValue == "pane:article|\(world.originalID)"
            })
            await settle(window, hosting, until: { false }, maxTurns: 6)
            #expect(try await chosen(db, world.blockID) == world.originalID, "the op landed (it always did)")
            let article = try #require(articlePane(hosting))
            #expect(article.string == originalText,
                    "the page shows the original once it is chosen again (shows: \(article.string))")

            // No pane she can type into holds another take's words.
            for pane in panes(in: hosting) where pane.isEditable {
                let id = pane.identifier?.rawValue ?? ""
                let variantID = String(id.split(separator: "|").last ?? "")
                let store = try await storeText(db, variantID)
                #expect(pane.string == store,
                        "the editable pane \(id) shows its own take's text (shows: \(pane.string))")
            }

            // The worst consequence, through the real edit door: wherever the
            // article is open for typing, a keystroke must land in the take it
            // shows — never carry the new take's words into the original.
            if article.isEditable {
                window.makeFirstResponder(article)
                article.setSelectedRange(NSRange(location: (article.string as NSString).length, length: 0))
                article.insertText("!", replacementRange: article.selectedRange())
                await board.autosave.flushNow()
            }
            let originalNow = try await storeText(db, world.originalID)
            #expect(!originalNow.contains("changed words"),
                    "no keystroke may write the new take's words into the original (original: \(originalNow))")
            #expect(try await storeText(db, world.mintID) == changedText,
                    "the new take keeps its own words")
        }
    }

    // MARK: - The rule at the model (RED ON OLD)

    /// The stranding itself: the article ring is keyed to the original;
    /// choosing the new take re-resolves the article under it — the ring
    /// ends (flushed), so it can never come back to life over the new
    /// take's text when the original is chosen again.
    @Test func aChoiceThatChangesTheArticlesTakeEndsTheRing() async throws {
        try await withChooseWorld("strand") { session, db, world, defaults in
            let model = TakesViewModel(session: session, postID: world.postID, defaults: defaults)
            model.adopt(try await fresh(db, world.postID))
            let ring = TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: world.blockID, variantID: world.originalID)
            model.landAuthorityFocus(ring)   // the entry landing's door
            #expect(model.focusedPane == ring)

            await model.choose(blockID: world.blockID, variantID: world.mintID)
            model.adopt(try await fresh(db, world.postID))
            #expect(model.focusedPane == nil,
                    "the article now shows another take — the ring keyed to the original ends")

            await model.choose(blockID: world.blockID, variantID: world.originalID)
            model.adopt(try await fresh(db, world.postID))
            #expect(!model.isPaneLive(ring),
                    "choosing the original back never revives a live article over the other take's text")
        }
    }

    /// The same hazard from the other side: ⌃⌘→ from the article steps the
    /// ring onto the next take's id while the article still shows the chosen
    /// one. Choosing that take must not turn the article live in place over
    /// the text it was showing — the article's take changed, so the ring ends.
    @Test func aSteppedRingIsNotRevivedLiveByChoosingItsTake() async throws {
        try await withChooseWorld("step") { session, db, world, defaults in
            let model = TakesViewModel(session: session, postID: world.postID, defaults: defaults)
            model.adopt(try await fresh(db, world.postID))
            model.landAuthorityFocus(.init(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: world.blockID, variantID: world.originalID))
            await model.stepTakes(by: 1)
            let stepped = TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: world.blockID, variantID: world.mintID)
            #expect(model.focusedPane == stepped, "non-vacuity: ⌃⌘→ moved the article ring to the mint's id")

            await model.choose(blockID: world.blockID, variantID: world.mintID)
            model.adopt(try await fresh(db, world.postID))
            #expect(!model.isPaneLive(stepped),
                    "the article changed take under the ring — it must not go live over the old take's text")
        }
    }

    // MARK: - Guards that hold on both sides

    /// Rider 1 (the architect's guard): "no longer renders" is the column's
    /// MODEL, never the viewport. A ring whose row scrolled out of the lazy
    /// article, and adoptions that leave the article's take alone (another
    /// block's edit, an identical re-read), keep the ring exactly where it is.
    @Test func theRingSurvivesScrollAwayAndAdoptionsThatLeaveItsTakeAlone() async throws {
        try await withChooseWorld("cull") { session, db, world, defaults in
            let model = TakesViewModel(session: session, postID: world.postID, defaults: defaults)
            model.adopt(try await fresh(db, world.postID))
            let ring = TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: world.blockID, variantID: world.originalID)
            model.focus(ring)
            model.rowAppeared(world.blockID)
            model.rowDisappeared(world.blockID)   // scrolled out of the lazy article

            try await session.runner.run { [world] ops in
                try ops.autosave(world.otherVariantID, text: "Another block, edited elsewhere.", charDelta: 8)
            }
            model.adopt(try await fresh(db, world.postID))
            model.adopt(try await fresh(db, world.postID))
            #expect(model.focusedPane == ring, "scrolling away and unrelated adoptions never end the ring")
            #expect(model.isPaneLive(ring))
        }
    }

    /// The ⌘⏎ road, unchanged: a ring in a FAN card (her click into the take)
    /// survives choosing that take — the fan renders the whole fan, chosen or
    /// not, so the card she is in is still there.
    @Test func aRingInAFanCardSurvivesChoosingItsTake() async throws {
        try await withChooseWorld("fan") { session, db, world, defaults in
            let model = TakesViewModel(session: session, postID: world.postID, defaults: defaults)
            model.adopt(try await fresh(db, world.postID))
            let card = TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesFanColumnID,
                blockID: world.blockID, variantID: world.mintID)
            model.focus(card)
            await model.chooseFocusedTake()   // ⌘⏎
            model.adopt(try await fresh(db, world.postID))
            #expect(try await chosen(db, world.blockID) == world.mintID)
            #expect(model.focusedPane == card, "the ring stays in the card she clicked into")
        }
    }
}
