//
//  TakesArticleScrollTests.swift
//  VariorumTests
//
//  17p batch a (the 2026-09-12 use-report round, ledger row 1) — HER RULING
//  R-Q1, "remember + reveal only": *"it's absolutely infuriating the way the
//  page keeps trying to jump to the bottom and now show the text above… even
//  if you left it scrolled up and you only have two blocks, if you leave and
//  come back to the page it won't be showing the top two — it's bizarre, it
//  should remember your scroll position."*
//
//  The measurement discipline is TakesRoomTests' and it is load-bearing here:
//  the article's position is a REAL NSScrollView's `contentView.bounds.origin.y`,
//  read off the mounted board, never an arithmetic model of it. The board is
//  hosted exactly as the room suite hosts it (a real window, a real hosting
//  view, a settle loop) because "where does the page open" is a question only
//  a laid-out scroll view can answer.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The takes article's scroll memory and its reveal rule (17p a, row 1)", .serialized)
struct TakesArticleScrollTests {

    // MARK: - Harness (TakesRoomTests' board-hosting pattern)

    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView,
        until predicate: () -> Bool, maxTurns: Int = 40
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.02)
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

    private func articlePanes(in view: NSView) -> [PaneTextView] {
        panes(in: view).filter { $0.identifier?.rawValue.hasPrefix("pane:article|") == true }
    }

    /// The ARTICLE's scroll view, read from the composition (the room suite's
    /// rule): the outermost `NSScrollView` between an article pane and the root.
    private func articleScrollView(in root: NSView) -> NSScrollView? {
        guard let pane = articlePanes(in: root).first else { return nil }
        var outermost: NSScrollView?
        var current: NSView? = pane.superview
        while let node = current, node != root {
            if let scroll = node as? NSScrollView { outermost = scroll }
            current = node.superview
        }
        return outermost
    }

    private struct Fixture {
        let postID: String
        let blocks: [(block: String, variant: String)]
        var lastBlock: String { blocks[blocks.count - 1].block }
        var lastVariant: String { blocks[blocks.count - 1].variant }
    }

    /// One session, one note, N blocks — and the board mounted as many times
    /// as the body asks, each mount getting a FRESH `TakesViewModel` exactly
    /// as a real mode round trip does (`TakesBoardView`'s model is per-mount
    /// `@State`). Whatever survives a remount survives because it lives on
    /// the SESSION, which is the whole point of row 1.
    private func withSession(
        blocks: Int,
        windowHeight: CGFloat = 700,
        _ body: @MainActor (
            _ session: AppSession, _ fixture: Fixture, _ db: AppDatabase,
            _ mount: @MainActor (TakesViewModel) async -> (NSWindow, NSHostingView<TakesBoardView>)
        ) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 42))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let post = try session.operations.createPost(title: "article scroll fixture")
            var made: [(block: String, variant: String)] = []
            for i in 1...blocks {
                let minted = try session.operations.newBlock(
                    in: post.id,
                    text: "Paragraph \(i). Honest prose on the measured line, long enough to wrap "
                        + "once at the article's measure so the rows have real height.")
                made.append((minted.block.id, minted.variant.id))
            }
            let fixture = Fixture(postID: post.id, blocks: made)

            var windows: [NSWindow] = []
            var hostings: [NSHostingView<TakesBoardView>] = []
            defer {
                for window in windows {
                    window.orderOut(nil)
                    window.close()
                }
            }
            let mount: @MainActor (TakesViewModel) async -> (
                NSWindow, NSHostingView<TakesBoardView>
            ) = { model in
                let window = NSWindow(
                    contentRect: NSRect(x: 60, y: 60, width: 1100, height: windowHeight),
                    styleMask: [.titled], backing: .buffered, defer: false)
                window.isReleasedWhenClosed = false
                let hosting = NSHostingView(
                    rootView: TakesBoardView(session: session, postID: post.id, model: model))
                hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: windowHeight)
                window.contentView = hosting
                window.makeKeyAndOrderFront(nil)
                windows.append(window)
                hostings.append(hosting)
                await settle(window, hosting, until: { !self.articlePanes(in: hosting).isEmpty })
                await settle(window, hosting, until: { false }, maxTurns: 8)
                return (window, hosting)
            }
            try await body(session, fixture, db, mount)
        }
    }

    /// A model wired the way the board's own entry wires it: landings enabled
    /// BEFORE the projection lands, so `consumeLandings` runs exactly as it
    /// does in the app (the `CommandRoutingTests` pattern).
    private func landingModel(
        session: AppSession, fixture: Fixture, db: AppDatabase
    ) async throws -> TakesViewModel {
        let model = TakesViewModel(session: session, postID: fixture.postID)
        model.landingEnabled = true
        model.adopt(try await db.read { try Queries.takesProjection($0, post: fixture.postID) })
        return model
    }

    private func offset(_ scroll: NSScrollView) -> CGFloat {
        scroll.contentView.bounds.origin.y
    }

    /// A real scroll, through the clip view the scroller drives — the room
    /// suite's rule that a pin must drive the surface, not a model of it.
    private func scroll(_ scroll: NSScrollView, to y: CGFloat) {
        scroll.contentView.scroll(to: NSPoint(x: 0, y: y))
        scroll.reflectScrolledClipView(scroll.contentView)
    }

    // MARK: - Row 1, half one: the page opens where the blocks are

    /// **RED ON THE PRE-FIX CODE.** Her three-block note, entered on its LAST
    /// block (she typed there in Write): the board must open at the TOP with
    /// every block on screen. Before this batch the N9 entry arm asked the
    /// article to put the current block's top at the viewport's top, and the
    /// typewriter room made that a legal place to stop — so the page showed
    /// the last block alone, with blocks 1–2 above the fold (her image 1).
    @Test func aThreeBlockNoteEnteredOnItsLastBlockOpensAtTheTop() async throws {
        try await withSession(blocks: 3) { session, fixture, db, mount in
            let router = session.commandRouter
            router.forgetCurrentBlock(for: fixture.postID)
            defer { router.forgetCurrentBlock(for: fixture.postID) }
            let token = router.registerDetail(postID: fixture.postID, mode: .write) { _ in }
            defer { router.unregisterDetail(token) }
            router.noteFocusedBlock(
                fixture.lastBlock, variantID: fixture.lastVariant,
                postID: fixture.postID, utf16Offset: 0)

            let model = try await landingModel(session: session, fixture: fixture, db: db)
            let (window, hosting) = await mount(model)
            guard let article = articleScrollView(in: hosting) else {
                Issue.record("no article scroll view")
                return
            }
            await settle(window, hosting, until: { false }, maxTurns: 10)

            // Non-vacuity: the board really did enter on the last block, and
            // the article really is scrollable (the room is under the rows).
            #expect(model.authority.livePane?.blockID == fixture.lastBlock,
                    "the ring entered on the note's current block")
            #expect((article.documentView?.frame.height ?? 0)
                    > article.contentView.bounds.height,
                    "non-vacuity: there IS somewhere to scroll to")
            #expect(articlePanes(in: hosting).count == 3,
                    "all three rows are realized")

            #expect(offset(article) == 0,
                    """
                    the article opens at the TOP (offset \(offset(article))) — \
                    every block on screen. Before the fix the entry landing put \
                    the last block's top at the viewport top and the blocks \
                    above it left the screen.
                    """)
        }
    }

    // MARK: - Row 1, half two: it remembers where she left it

    /// **RED ON THE PRE-FIX CODE.** Leave the page scrolled; come back; it is
    /// where she left it. The board's model is per-mount `@State`, so the
    /// memory can only live on the session — which is what this pin proves by
    /// mounting a SECOND board with a FRESH model.
    @Test func aBoardLeftScrolledComesBackWhereSheLeftIt() async throws {
        try await withSession(blocks: 12) { session, fixture, db, mount in
            let router = session.commandRouter
            router.forgetCurrentBlock(for: fixture.postID)
            defer { router.forgetCurrentBlock(for: fixture.postID) }

            let first = try await landingModel(session: session, fixture: fixture, db: db)
            let (windowA, hostingA) = await mount(first)
            guard let articleA = articleScrollView(in: hostingA) else {
                Issue.record("no article scroll view on the first mount")
                return
            }
            let travel = (articleA.documentView?.frame.height ?? 0)
                - articleA.contentView.bounds.height
            #expect(travel > 120, "non-vacuity: the article has real travel (\(travel))")
            let left: CGFloat = 120
            scroll(articleA, to: left)
            await settle(windowA, hostingA, until: { false }, maxTurns: 10)
            #expect(abs(offset(articleA) - left) < 1,
                    "non-vacuity: the scroll landed (\(offset(articleA)))")
            let remembered = session.editorRouter.takesArticleOffsets[fixture.postID]
            #expect(
                abs((remembered ?? -1) - left) < 2,
                """
                the SESSION remembers where she left it (\
                \(remembered.map { "\($0)" } ?? "nothing")) — the half a \
                remount can read
                """)

            // The mode round trip: this board goes away, a fresh one arrives.
            windowA.orderOut(nil)
            first.teardown()
            await settle(windowA, hostingA, until: { false }, maxTurns: 4)

            let second = try await landingModel(session: session, fixture: fixture, db: db)
            let (windowB, hostingB) = await mount(second)
            guard let articleB = articleScrollView(in: hostingB) else {
                Issue.record("no article scroll view on the second mount")
                return
            }
            await settle(windowB, hostingB, until: { false }, maxTurns: 12)

            #expect(abs(offset(articleB) - left) < 12,
                    """
                    the article came back where she left it (offset \
                    \(offset(articleB)), left at \(left)) — before the fix the \
                    board had no scroll memory at all and every entry started \
                    from the top or from the entry landing's block.
                    """)
        }
    }

    // MARK: - …and the landing still LANDS (the guard against over-correcting)

    /// Row 8 of the previous round — *"open takes mode in write from the takes
    /// menu is also not automatically navigating you to where the take is"* —
    /// must survive R-Q1. On a long note entered on a far block the board DOES
    /// move; what changed is HOW: the block is revealed at the foot of the
    /// viewport with everything above it still on screen, never hauled to the
    /// top. **Red on the pre-fix code in its second half** (the old anchor put
    /// the row's top at the viewport's top, i.e. `minY ≈ 0`).
    @Test func aLongNoteEnteredOnAFarBlockRevealsItWithoutHaulingItToTheTop() async throws {
        try await withSession(blocks: 12) { session, fixture, db, mount in
            let router = session.commandRouter
            router.forgetCurrentBlock(for: fixture.postID)
            defer { router.forgetCurrentBlock(for: fixture.postID) }
            let token = router.registerDetail(postID: fixture.postID, mode: .write) { _ in }
            defer { router.unregisterDetail(token) }
            router.noteFocusedBlock(
                fixture.lastBlock, variantID: fixture.lastVariant,
                postID: fixture.postID, utf16Offset: 0)

            let model = try await landingModel(session: session, fixture: fixture, db: db)
            let (window, hosting) = await mount(model)
            guard let article = articleScrollView(in: hosting) else {
                Issue.record("no article scroll view")
                return
            }
            await settle(window, hosting, until: { false }, maxTurns: 12)

            #expect(model.articleLanding == nil,
                    "non-vacuity: the landing request WAS spent")
            #expect(offset(article) > 0,
                    "the board went to the block she was in (offset \(offset(article)))")

            guard let last = articlePanes(in: hosting).first(where: {
                $0.identifier?.rawValue == "pane:article|\(fixture.lastVariant)"
            }) else {
                Issue.record("the last block's pane is not mounted")
                return
            }
            // The clip view's BOUNDS is the visible window onto the document
            // (its origin IS the scroll offset), so "on screen" is measured
            // against that rect, never against its height alone.
            let visible = article.contentView.bounds
            let inViewport = last.convert(last.bounds, to: article.contentView)
            #expect(inViewport.maxY <= visible.maxY + 2,
                    """
                    the block is ON SCREEN (row \(inViewport), visible \
                    \(visible), document \
                    \(article.documentView?.frame.height ?? 0))
                    """)
            #expect(inViewport.minY > visible.minY + 40,
                    """
                    …and it was revealed MINIMALLY, at the foot of the page \
                    with the blocks above it still visible (its top sits \
                    \(inViewport.minY - visible.minY) pt down the viewport) — \
                    not anchored to the top, which is what emptied the page in \
                    her report
                    """)
        }
    }

    // MARK: - The reveal rule, as a pure decision

    /// The landing REVEALS: it asks for a scroll only when the slot's row is
    /// not fully on screen, and never anchors it to the top. Pure, so the
    /// rule can be read without a window.
    @Test func theRevealDecisionOnlyMovesForARowThatIsNotFullyOnScreen() {
        let viewport: CGFloat = 700
        // Fully inside → nothing moves.
        #expect(TakesBoardLayout.revealDecision(
            rowFrame: CGRect(x: 0, y: 40, width: 680, height: 60), viewportHeight: viewport)
                == .none)
        // Flush with both edges → still inside.
        #expect(TakesBoardLayout.revealDecision(
            rowFrame: CGRect(x: 0, y: 0, width: 680, height: 700), viewportHeight: viewport)
                == .none)
        // Clipped at the bottom → reveal.
        #expect(TakesBoardLayout.revealDecision(
            rowFrame: CGRect(x: 0, y: 660, width: 680, height: 60), viewportHeight: viewport)
                == .reveal)
        // Scrolled off the top → reveal.
        #expect(TakesBoardLayout.revealDecision(
            rowFrame: CGRect(x: 0, y: -20, width: 680, height: 60), viewportHeight: viewport)
                == .reveal)
        // Not realized at all (a far row in a lazy column) → certainly not
        // on screen, so reveal.
        #expect(TakesBoardLayout.revealDecision(rowFrame: nil, viewportHeight: viewport)
                == .reveal)
        // A viewport we have not measured yet decides nothing, and the view's
        // own minimal scroll settles it.
        #expect(TakesBoardLayout.revealDecision(
            rowFrame: CGRect(x: 0, y: 40, width: 680, height: 60), viewportHeight: 0)
                == .reveal)
    }

    /// The same rule through the component that owns the frames — and the
    /// landing request is spent EXACTLY ONCE (the 17o batch-b BLOCKER's
    /// class: a landing seed that is never cleared re-lands on every later
    /// mount).
    @Test func theBoardRevealsAnOffScreenSlotLeavesAVisibleOneAloneAndSpendsItOnce() {
        let board = TakesBoardLayout(postID: "post", defaults: .standard)
        board.noteArticleViewport(height: 700)
        board.noteArticleRowFrame("near", CGRect(x: 0, y: 30, width: 680, height: 60))
        board.noteArticleRowFrame("far", CGRect(x: 0, y: 900, width: 680, height: 60))

        board.landArticle(on: "near")
        #expect(board.articleReveal(for: "near") == .none,
                "a slot already on screen is not scrolled to")
        board.clearArticleLanding()
        #expect(board.articleLanding == nil)

        board.landArticle(on: "far")
        #expect(board.articleReveal(for: "far") == .reveal)
        board.clearArticleLanding()
        #expect(board.articleLanding == nil, "the request is spent exactly once")

        // A row that scrolled away is forgotten, and an unknown slot reveals.
        board.forgetArticleRowFrame("near")
        #expect(board.articleReveal(for: "near") == .reveal)
    }
}
