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

    // `@unchecked`: `UserDefaults` is documented thread-safe but not `Sendable`.
    private struct Fixture: @unchecked Sendable {
        let postID: String
        let blocks: [(block: String, variant: String)]
        /// The session's OWN defaults. The test host is the dev-store app, so
        /// `.standard` is shared with every other suite AND with hand walks —
        /// and `.incrementing` mints the same post id in every world, so a
        /// `takesViewMemory` left by a Lenses lesson (four columns, alignment
        /// locked) mounted THIS board as a four-column Lenses board and the
        /// reveal guard read offset 0 with no article pane (the R1-7 class,
        /// KnownIssues, owner 12; found at the 17p batch-a adjudication).
        let defaults: UserDefaults
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
        let suiteName = "TakesArticleScroll-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        defer { defaults.removePersistentDomain(forName: suiteName) }
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
            let fixture = Fixture(postID: post.id, blocks: made, defaults: defaults)

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
        let model = TakesViewModel(
            session: session, postID: fixture.postID, defaults: fixture.defaults)
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

    /// **What "where she left it" MEANS on this surface**: which take is at
    /// the top of the page, and how far into it she is — never the raw
    /// content offset, which in a lazy column is not the same number for the
    /// same view twice (the rows above the fold are estimated until they are
    /// realized; measured here at 96 pt for a sixty-block note).
    private func topOfPage(
        _ hosting: NSView, _ article: NSScrollView
    ) -> (variantID: String, into: CGFloat)? {
        let visible = article.contentView.bounds
        var best: (String, CGFloat)?
        for pane in articlePanes(in: hosting) {
            let rect = pane.convert(pane.bounds, to: article.contentView)
            let into = rect.minY - visible.minY
            guard rect.maxY > visible.minY else { continue }   // above the fold
            if best == nil || into < best!.1 {
                let id = pane.identifier?.rawValue
                    .replacingOccurrences(of: "pane:article|", with: "") ?? ""
                best = (id, into)
            }
        }
        return best.map { (variantID: $0.0, into: $0.1) }
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
        // SIXTY blocks on purpose: a column this long is genuinely lazy, so
        // the rows above the fold are ESTIMATED until realized and a raw
        // pixel offset does not mean the same thing on the way back. The
        // memory is a PLACE (a row plus how far into it) precisely so this
        // pin can be tight.
        try await withSession(blocks: 60) { session, fixture, db, mount in
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
            #expect(travel > 800, "non-vacuity: the article has real travel (\(travel))")
            let left: CGFloat = 800
            scroll(articleA, to: left)
            await settle(windowA, hostingA, until: { false }, maxTurns: 10)
            #expect(abs(offset(articleA) - left) < 1,
                    "non-vacuity: the scroll landed (\(offset(articleA)))")
            guard let before = topOfPage(hostingA, articleA) else {
                Issue.record("no take at the top of the page after scrolling")
                return
            }
            #expect(session.editorRouter.takesArticlePlaces[fixture.postID] != nil,
                    """
                    the SESSION remembers where she left it (a row plus how \
                    far into it) — the half a remount can read
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

            guard let after = topOfPage(hostingB, articleB) else {
                Issue.record("no take at the top of the page after the remount")
                return
            }
            #expect(offset(articleB) > 200,
                    """
                    non-vacuity: the page really is deep in the note \
                    (\(offset(articleB))) — before the fix a remount started \
                    from the top or from the entry landing's block
                    """)
            let index = { (variantID: String) -> Int? in
                fixture.blocks.firstIndex { $0.variant == variantID }
            }
            guard let wasAt = index(before.variantID), let isAt = index(after.variantID) else {
                Issue.record("the top-of-page take is not one of the fixture's")
                return
            }
            #expect(abs(isAt - wasAt) <= 1,
                    """
                    the page came back on the block she was reading (block \
                    \(isAt + 1), left on block \(wasAt + 1) of \
                    \(fixture.blocks.count)) — the memory is the BLOCK, and \
                    the sub-row place is deliberately NOT promised (the two \
                    measurements behind that are on `ArticlePlace`)
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

            #expect(model.articleLandingAims > 0,
                    "non-vacuity: the landing really aimed the page")
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
        // A row TALLER than the page is on screen when its top is.
        #expect(TakesBoardLayout.revealDecision(
            rowFrame: CGRect(x: 0, y: 10, width: 680, height: 900), viewportHeight: viewport)
                == .none)
        #expect(TakesBoardLayout.revealDecision(
            rowFrame: CGRect(x: 0, y: -50, width: 680, height: 900), viewportHeight: viewport)
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

    // MARK: - The landing as a step machine (the 17p batch-a adjudication, J1)

    private func freshBoard(_ name: String) -> TakesBoardLayout {
        let suite = "TakesArticleScroll-\(name)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return TakesBoardLayout(postID: "post", defaults: defaults)
    }

    private func settle(_ board: TakesBoardLayout, byUser: Bool = false) {
        _ = board.consumeArticleGeometry(
            geometry(offset: 0), remembered: nil, positionedByUser: byUser)
    }

    private func geometry(offset: CGFloat) -> TakesBoardLayout.ArticleGeometry {
        TakesBoardLayout.ArticleGeometry(offset: offset, content: 3000, viewport: 700)
    }

    /// Measured at the adjudication (the layout's `ArticleLandingStep` doc
    /// carries the three numbers): the request waits for rows, aims by
    /// direction at a row it cannot see, re-aims as the column's placeholder
    /// frames give way to measured ones, and ENDS AT HER HAND — never at a
    /// frame that may be a placeholder. Red on old: the old spend cleared the
    /// request on the first report and never aimed again.
    @Test func theLandingWaitsForRowsAimsByDirectionAndStaysUntilHerHand() {
        let board = freshBoard("steps")
        let order = ["a", "b", "c", "far"]
        board.landArticle(on: "far")

        // No geometry yet → wait, and the request is kept.
        #expect(board.articleLandingStep(order: order) == .wait)
        #expect(board.articleLanding == "far")

        // Geometry, but the column has laid out nothing → still wait.
        settle(board)
        #expect(board.articleLandingStep(order: order) == .wait)
        #expect(board.articleLanding == "far")
        #expect(board.articleLandingAims == 0)

        // Rows realized above the target → aim at the foot; request kept.
        board.noteArticleRowFrame("a", CGRect(x: 0, y: 0, width: 680, height: 60))
        board.noteArticleRowFrame("b", CGRect(x: 0, y: 66, width: 680, height: 60))
        #expect(board.articleLandingStep(order: order) == .reveal("far", .foot))
        #expect(board.articleLanding == "far")
        #expect(board.articleLandingAims == 1)

        // The row realized but still below the fold → to the foot; a row
        // realized above the fold → to the head. Never the far edge.
        board.noteArticleRowFrame("far", CGRect(x: 0, y: 900, width: 680, height: 60))
        #expect(board.articleLandingStep(order: order) == .reveal("far", .foot))
        board.noteArticleRowFrame("far", CGRect(x: 0, y: -300, width: 680, height: 60))
        #expect(board.articleLandingStep(order: order) == .reveal("far", .head))
        #expect(board.articleLanding == "far")

        // The row reports itself on screen → nothing to do, request KEPT
        // (that frame may be a placeholder pass).
        board.noteArticleRowFrame("far", CGRect(x: 0, y: 600, width: 680, height: 60))
        #expect(board.articleLandingStep(order: order) == .wait)
        #expect(board.articleLanding == "far")

        // …and when a later pass pushes it below the fold, it is re-aimed.
        board.noteArticleRowFrame("far", CGRect(x: 0, y: 700, width: 680, height: 60))
        #expect(board.articleLandingStep(order: order) == .reveal("far", .foot))
        #expect(board.articleLandingAims == 4)

        // Her hand ends it.
        settle(board, byUser: true)
        #expect(board.articleLanding == nil)
        #expect(board.articleLandingStep(order: order) == .done)
    }

    /// A landing naming a row the note no longer holds ends at once; one
    /// naming a row the column never realizes ends after the bounded aims.
    @Test func theLandingEndsForAGoneRowAndAfterItsBoundedAims() {
        let board = freshBoard("bounded")
        settle(board)
        board.noteArticleRowFrame("a", CGRect(x: 0, y: 0, width: 680, height: 60))
        board.landArticle(on: "gone")
        #expect(board.articleLandingStep(order: ["a"]) == .done)
        #expect(board.articleLanding == nil)

        board.landArticle(on: "late")
        for _ in 0..<TakesBoardLayout.articleLandingAttempts {
            #expect(board.articleLandingStep(order: ["a", "late"]) == .reveal("late", .foot))
        }
        #expect(board.articleLandingStep(order: ["a", "late"]) == .done)
        #expect(board.articleLanding == nil)
    }

    @Test func theLandingAimsAtTheHeadForARowAboveTheRealizedOnes() {
        let board = freshBoard("head")
        settle(board)
        board.noteArticleRowFrame("c", CGRect(x: 0, y: 0, width: 680, height: 60))
        board.noteArticleRowFrame("d", CGRect(x: 0, y: 66, width: 680, height: 60))
        board.landArticle(on: "a")
        #expect(board.articleLandingStep(order: ["a", "b", "c", "d"]) == .reveal("a", .head))
        // Pure: a realized row goes by its frame; an unknown id takes the foot.
        #expect(TakesBoardLayout.revealAnchor(
            for: "c", rowFrame: CGRect(x: 0, y: -10, width: 680, height: 60),
            order: ["a", "b", "c", "d"], realizedRows: ["c", "d"]) == .head)
        #expect(TakesBoardLayout.revealAnchor(
            for: "c", rowFrame: CGRect(x: 0, y: 800, width: 680, height: 60),
            order: ["a", "b", "c", "d"], realizedRows: ["c", "d"]) == .foot)
        #expect(TakesBoardLayout.revealAnchor(
            for: "zz", rowFrame: nil, order: ["a", "b"], realizedRows: ["a"]) == .foot)
    }

    /// Her hand outranks a pending landing (the 17o batch-b BLOCKER's class:
    /// a request that outlives its moment must never haul the page later).
    @Test func herOwnScrollCancelsAPendingLanding() {
        let board = freshBoard("hand")
        board.landArticle(on: "far")
        settle(board, byUser: true)
        #expect(board.articleLanding == nil)
        #expect(board.articleLandingStep(order: ["a", "far"]) == .done)
    }

    // MARK: - The ladder's round 1 (fable-reviewer, 2026-09-12)

    /// **R1-1 — RED ON THE ROUND-1 TREE (18.0 where 0 is owed).** A page left
    /// at the TOP comes back at the top. The column's own top padding put row
    /// 1 at `minY 18` in `.scrollView` space, so the memory said "row 1" and
    /// the restore aligned that row's top with the viewport's top — 18 pt
    /// down, on every return. The two- and three-block notes she reported
    /// are exactly this road; the memory now carries the TOP as a place of
    /// its own, and a mount that starts there issues no scroll at all.
    @Test func aBoardLeftAtTheTopComesBackAtTheTop() async throws {
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
            await settle(windowA, hostingA, until: { false }, maxTurns: 10)
            #expect(offset(articleA) == 0, "non-vacuity: the first mount is at the top")
            #expect((articleA.documentView?.frame.height ?? 0)
                    > articleA.contentView.bounds.height,
                    "non-vacuity: there IS somewhere to scroll to")
            #expect(session.editorRouter.takesArticlePlaces[fixture.postID] != nil,
                    "non-vacuity: the session remembered a place")

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
            #expect(offset(articleB) == 0,
                    """
                    a page left at the TOP comes back at the top (offset \
                    \(offset(articleB))) — the round-1 tree came back 18 pt \
                    down, the column's top padding, on every return
                    """)
        }
    }

    /// R1-1's rule, pure: a page at rest remembers the TOP itself (not the
    /// row the column's padding holds 18 pt below the fold), a mount with the
    /// top remembered is ready at once and issues no scroll, and a scrolled
    /// page remembers the row at the top of the viewport.
    @Test func theTopOfThePageIsRememberedAsTheTopAndRestoresWithoutAScroll() {
        let board = freshBoard("top")
        board.noteArticleRowFrame("a", CGRect(x: 0, y: 18, width: 680, height: 60))
        #expect(board.consumeArticleGeometry(
            geometry(offset: 0), remembered: nil, positionedByUser: false)
                == .remember(.top),
                "at rest the memory is the top, never the padded first row")

        let again = freshBoard("top-again")
        #expect(again.consumeArticleGeometry(
            geometry(offset: 0), remembered: .top, positionedByUser: false)
                == .remember(.top),
                "the top remembered: no scroll is issued")
        #expect(again.articleReadyForLanding, "…and a landing may be considered at once")

        board.noteArticleRowFrame("a", CGRect(x: 0, y: -30, width: 680, height: 60))
        board.noteArticleRowFrame("b", CGRect(x: 0, y: 36, width: 680, height: 60))
        #expect(board.consumeArticleGeometry(
            geometry(offset: 100), remembered: nil, positionedByUser: false)
                == .remember(TakesBoardLayout.ArticlePlace(rowID: "a")),
                "scrolled: the row at the top of the viewport is the place")
    }

    /// **R1-2 — RED ON THE ROUND-1 TREE.** Every board gesture is her hand:
    /// a bloom, expand-all, close-all, and any Operations call through the
    /// board's plumbing end a pending landing exactly as a scroll, a click
    /// away or a keystroke do. Before, the kept-alive request survived them
    /// and re-aimed the page after her own click.
    @Test func herBoardGesturesEndAPendingLanding() async throws {
        try await withSession(blocks: 3) { session, fixture, db, _ in
            let model = try await landingModel(session: session, fixture: fixture, db: db)
            let far = model.projection.slots[2].placementID

            model.board.landArticle(on: far)
            model.toggleExpanded(fixture.blocks[0].block)
            #expect(model.articleLanding == nil, "a bloom is her hand")

            model.board.landArticle(on: far)
            model.expandAllFans()
            #expect(model.articleLanding == nil, "expand-all is her hand")

            model.board.landArticle(on: far)
            model.closeAllFans()
            #expect(model.articleLanding == nil, "close-all is her hand")

            model.board.landArticle(on: far)
            await model.choose(blockID: fixture.blocks[0].block, variantID: fixture.blocks[0].variant)
            #expect(model.articleLanding == nil, "an Operations call through `run` is her hand")
        }
    }

    /// **R1-2, the face — RED ON THE ROUND-1 TREE (65 → 97).** Entered on
    /// the last block, the board reveals it at the foot; she then blooms a
    /// row ABOVE it. The page stays where it is — the landing does not re-aim
    /// after her own gesture and scroll the top rows off the screen.
    @Test func herBloomAboveTheLandedRowLeavesThePageWhereItIs() async throws {
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
            let before = offset(article)
            #expect(before > 0, "non-vacuity: the landing revealed the far block (\(before))")
            #expect(model.articleLandingAims > 0, "non-vacuity: the landing aimed")

            // A row on screen ABOVE the landed one blooms (its footer grows).
            model.toggleExpanded(fixture.blocks[1].block)
            await settle(window, hosting, until: { false }, maxTurns: 14)
            let after = offset(article)
            #expect(model.articleLanding == nil, "the bloom ended the landing")
            #expect(abs(after - before) < 2,
                    """
                    the page stays where it was after her bloom (\(before) → \
                    \(after)) — before the fix the kept-alive landing re-aimed \
                    the far block to the foot and the top rows left the screen
                    """)
        }
    }

    /// **R1-3 (P1).** The landing step runs from every realized row's frame
    /// report at scroll rate; with nothing pending it must never build the
    /// note's slot order (an O(N) map in the block count). The order is an
    /// autoclosure the board evaluates only past its guards — pinned by
    /// counting the evaluations. (On the round-1 tree the view model built the
    /// array before the call, unconditionally, by construction.)
    @Test func theLandingStepReadsTheSlotOrderOnlyWhenARequestIsPending() {
        let board = freshBoard("order")
        var reads = 0
        let order: () -> [String] = {
            reads += 1
            return ["a", "far"]
        }
        _ = board.articleLandingStep(order: order())
        settle(board)
        _ = board.articleLandingStep(order: order())
        board.noteArticleRowFrame("a", CGRect(x: 0, y: 0, width: 680, height: 60))
        _ = board.articleLandingStep(order: order())
        #expect(reads == 0, "nothing pending: the order is never read (\(reads))")

        board.landArticle(on: "far")
        #expect(board.articleLandingStep(order: order()) == .reveal("far", .foot))
        #expect(reads == 1, "a pending landing reads it once per step (\(reads))")
    }

    /// **R1-4 — RED ON THE ROUND-1 TREE (aims 0, ready false).** A memory
    /// naming a row the note no longer holds (a block deleted, merged or
    /// divided away while she was in Write or on the phone) settles the
    /// restore at once, so the entry landing still lands and the memory is
    /// corrected. Before, `scrollTo` on the gone row was a no-op, the
    /// geometry stopped changing, the aim bound (counted per report) was
    /// never reached, and the restore starved the landing for the rest of
    /// the session's entries into that note.
    @Test func aMemoryOfARowTheNoteNoLongerHoldsSettlesAndLetsTheLandingLand() async throws {
        try await withSession(blocks: 12) { session, fixture, db, mount in
            let router = session.commandRouter
            router.forgetCurrentBlock(for: fixture.postID)
            defer { router.forgetCurrentBlock(for: fixture.postID) }
            let token = router.registerDetail(postID: fixture.postID, mode: .write) { _ in }
            defer { router.unregisterDetail(token) }
            router.noteFocusedBlock(
                fixture.lastBlock, variantID: fixture.lastVariant,
                postID: fixture.postID, utf16Offset: 0)
            session.editorRouter.takesArticlePlaces[fixture.postID]
                = TakesBoardLayout.ArticlePlace(rowID: "gone-row")

            let model = try await landingModel(session: session, fixture: fixture, db: db)
            let (window, hosting) = await mount(model)
            guard let article = articleScrollView(in: hosting) else {
                Issue.record("no article scroll view")
                return
            }
            await settle(window, hosting, until: { false }, maxTurns: 16)
            #expect(model.articleLandingAims > 0,
                    "the landing still lands under a stale memory (aims \(model.articleLandingAims))")
            #expect(offset(article) > 0,
                    "the board went to the block she was in (offset \(offset(article)))")
            #expect(session.editorRouter.takesArticlePlaces[fixture.postID]?.rowID != "gone-row",
                    "the stale memory was corrected once the page settled")
        }
    }

    /// R1-4's rule, pure: a remembered row the note no longer holds settles
    /// the restore at once (the memory corrected to where the page is), while
    /// a note whose slots are not yet KNOWN keeps the aim — the projection may
    /// still be loading at the first geometry report, and settling then would
    /// lose the memory.
    @Test func aRememberedRowTheNoteNoLongerHoldsSettlesAtOnce() {
        let board = freshBoard("gone-memory")
        board.noteArticleRowFrame("a", CGRect(x: 0, y: 18, width: 680, height: 60))
        #expect(board.consumeArticleGeometry(
            geometry(offset: 0), remembered: TakesBoardLayout.ArticlePlace(rowID: "gone"),
            positionedByUser: false, order: ["a"])
                == .remember(.top),
                "a gone row: settled at once, the memory corrected")
        #expect(board.articleReadyForLanding, "…and the landing may land")

        let late = freshBoard("slots-not-yet-known")
        #expect(late.consumeArticleGeometry(
            geometry(offset: 0), remembered: TakesBoardLayout.ArticlePlace(rowID: "x"),
            positionedByUser: false, order: nil)
                == .scrollToRow("x"),
                "slots unknown: the aim is kept until the projection lands")
        #expect(!late.articleReadyForLanding)
    }
}
