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
        /// and `.incrementing` mints the same post id in every world, so this
        /// board would otherwise read a `takesViewMemory` and slot heights
        /// left for "post 0" by the tutorial spine's Takes lessons (the R1-7
        /// class, KnownIssues, owner 12; found at the 17p batch-a
        /// adjudication). The own suite is right for that class; it was NOT
        /// the red guard's mechanism (the Takes board renders the article
        /// unconditionally — the columns memory drives Lenses — and the
        /// scrubbed suite left that pin red: the cause was the landing spent
        /// against unrealized rows, J1).
        let defaults: UserDefaults
        var lastBlock: String { blocks[blocks.count - 1].block }
        var lastVariant: String { blocks[blocks.count - 1].variant }
    }

    /// One session, one note, N blocks — and the board mounted as many times
    /// as the body asks, each mount getting a FRESH `TakesViewModel` exactly
    /// as a real mode round trip does (`TakesBoardView`'s model is per-mount
    /// `@State`). Whatever survives a remount survives because it lives on
    /// the SESSION, which is the whole point of row 1.
    /// The fixture's prose: long enough to wrap once at the article's measure
    /// so the rows have real height.
    nonisolated private static func proseText(_ i: Int) -> String {
        "Paragraph \(i). Honest prose on the measured line, long enough to wrap "
            + "once at the article's measure so the rows have real height."
    }

    /// `text` builds block `i`'s text (1-based); the default is the prose
    /// above. The round-2 face pin hands in blocks WITH newlines.
    private func withSession(
        blocks: Int,
        windowHeight: CGFloat = 700,
        text: @escaping @MainActor (Int) -> String = { TakesArticleScrollTests.proseText($0) },
        _ body: @MainActor (
            _ session: AppSession, _ fixture: Fixture, _ db: AppDatabase,
            _ mount: @MainActor (TakesViewModel) async -> (NSWindow, NSHostingView<TakesBoardView>)
        ) async throws -> Void
    ) async throws {
        // 13s closeout — the Study-default harness class (`TerminalMetricsPin`
        // has the trace): every landing decision here consults the entry
        // band, whose line height reads `EditorDocument.baseFont` — a
        // process global a voiceless store's Study adoption leaves behind.
        // This suite's hand-placed frames are calibrated against Terminal.
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
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
            // The store carries the Terminal voice row so any in-test
            // adoption keeps the voice the frames were calibrated against.
            try session.operations.setThemeVoice(.terminal)
            let post = try session.operations.createPost(title: "article scroll fixture")
            var made: [(block: String, variant: String)] = []
            for i in 1...blocks {
                let minted = try session.operations.newBlock(in: post.id, text: text(i))
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
    /// the top of the page — never the raw content offset, which in a lazy
    /// column is not the same number for the same view twice (the rows above
    /// the fold are estimated until they are realized; measured here at 96 pt
    /// for a sixty-block note). The `into` half is this helper's own
    /// bookkeeping for choosing the top take; the memory itself is the ROW
    /// (the sub-row place is deliberately not promised — `ArticlePlace`).
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
        // memory is a PLACE (the row at the top of the page) precisely so
        // this pin can be stated in blocks.
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
                    the SESSION remembers where she left it (the row at the \
                    top of the page) — the half a remount can read
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

    // MARK: - The landing as a step machine (the 17p batch-a adjudication, J1)

    private func freshBoard(_ name: String, lastCurrentRow: String? = nil) -> TakesBoardLayout {
        let suite = "TakesArticleScroll-\(name)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return TakesBoardLayout(
            postID: "post", defaults: defaults, lastCurrentRow: lastCurrentRow)
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
        // Pure-board, so no `withSession` — the pin alone holds the Terminal
        // metrics these frames were measured against (the knife edge: row
        // bottom 660 sits inside the band at Terminal's line, below it at
        // Study's).
        let pin = TerminalMetricsPin()
        defer { pin.restore() }
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
        // The 17q ladder's R1-1 evolved this arm: the place used to be the
        // STRADDLING row `a` (restored with its top at the fold, 30 pt from
        // where she had it); it is now the first row at or below the fold,
        // with where its top sat — `theRestoreRemembersWhereTheRowSatAnd
        // PutsItBackThere` carries the rule whole.
        #expect(board.consumeArticleGeometry(
            geometry(offset: 100), remembered: nil, positionedByUser: false)
                == .remember(TakesBoardLayout.ArticlePlace(rowID: "b", into: 36, rowHeight: 60)),
                "scrolled: the first row at or below the fold, where its top sat, is the place")
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

            // The slot-height drag (the sanity pass's raise): it writes a
            // row's HEIGHT through no Operations call and no migration —
            // R1-2's measured mechanism — from two gesture doors.
            model.board.landArticle(on: far)
            model.beginSlotDrag(fixture.blocks[0].block)
            #expect(model.articleLanding == nil, "a slot-height drag is her hand")

            model.board.landArticle(on: far)
            model.resetSlotHeight(fixture.blocks[0].block)
            #expect(model.articleLanding == nil, "the handle's double-click is her hand")

            // The ladder's round 2 (R2-1): three bare-runner doors that change
            // the article's CONTENT HEIGHT with no focus migration and no gone
            // row — a callout frame, the note-wide split, takes-to-blocks —
            // were outside the arms and the kept-alive landing re-aimed after
            // them (measured on the round-1 tree: the split hauled 406 → 1047,
            // a callout above the landed row 65 → 75).
            model.board.landArticle(on: far)
            await model.applyCallout(
                .color(CalloutPalette.defaultName), blockID: fixture.blocks[0].block)
            #expect(model.articleLanding == nil, "a callout frame is her hand")

            _ = try session.operations.newBlock(in: fixture.postID, text: "One line.\nTwo lines.")
            model.board.landArticle(on: far)
            await model.splitEveryNewlineIntoBlocks()
            #expect(model.articleLanding == nil, "the note-wide split is her hand")

            _ = try session.operations.branchVariant(
                fixture.blocks[0].block, from: fixture.blocks[0].variant)
            model.board.landArticle(on: far)
            await model.turnTakesIntoBlocks(blockID: fixture.blocks[0].block)
            #expect(model.articleLanding == nil, "takes-to-blocks is her hand")

            // The ladder's round 3 (R3-1): the ⌘-click PICK summons the
            // selection banner ABOVE the article, which shrinks the article's
            // VIEWPORT by the banner's height — a third mechanism beside
            // content height and the live pane — so a landed row at the
            // foot reads as clipped and the kept-alive landing revealed after
            // her click (measured on the round-2 tree: 65 → 93, the banner's
            // 28 pt; round 1 had dismissed the pick as "a stroke overlay, no
            // layout effect" — true of the cell, blind to the banner). A
            // ⌘-click never migrates the ring (picking blocks is not writing
            // in one), so nothing else ends it. Both pick doors are arms;
            // `clearMergeSelection` is not (shared with the controller's
            // post-act clears, and a banner LEAVING can clip nothing).
            model.board.landArticle(on: far)
            model.toggleMergeSelection(fixture.blocks[0].block)
            #expect(model.articleLanding == nil, "a ⌘-click pick is her hand")

            model.board.landArticle(on: far)
            model.extendMergeSelection(to: fixture.blocks[1].block)
            #expect(model.articleLanding == nil, "a ⌘⇧-click extend is her hand")

            // …and the banner's Delete over that selection: rows REMOVED
            // through a bare runner with no `parkFocus` — the rule's letter
            // (content height), armed at the door even though the pick
            // before it has already ended the landing.
            model.board.landArticle(on: far)
            await model.deleteSelectedBlocks()
            #expect(model.articleLanding == nil, "deleting picked blocks is her hand")
        }
    }

    /// A GUARD, not a red-on-old pin (green on both sides — measured at the
    /// ladder's final word, so the same-value-write hazard was dismissed as
    /// hollow rather than "fixed"): `articleLanding` is observed (the view's
    /// `.onChange` rides it) and the geometry hook's her-hand branch writes
    /// `nil` on EVERY scroll frame once she has scrolled; if a same-value
    /// write ever started waking observers, the board's body would
    /// re-evaluate per frame. This pin is the tripwire for that.
    @Test func endingANothingPendingLandingWakesNoObserver() {
        let board = freshBoard("quiet")
        settle(board)
        #expect(board.articleLanding == nil)
        let woke = LockIsolated(0)
        withObservationTracking {
            _ = board.articleLanding
        } onChange: {
            woke.withValue { $0 += 1 }
        }
        _ = board.consumeArticleGeometry(
            geometry(offset: 120), remembered: nil, positionedByUser: true)
        _ = board.consumeArticleGeometry(
            geometry(offset: 240), remembered: nil, positionedByUser: true)
        board.clearArticleLanding()
        #expect(woke.value == 0,
                "nothing pending: her scroll and a clear wake no observer (\(woke.value))")

        // Non-vacuity: a real change does wake it.
        board.landArticle(on: "far")
        #expect(woke.value == 1, "a landing set wakes the observer once (\(woke.value))")
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

    /// **R2-1, the face — RED ON THE ROUND-1 TREE (65 → 75).** Entered on
    /// the last block, the board reveals it at the foot; she then puts a
    /// callout frame on a row ABOVE it through the cell menu's own door
    /// (`applyCallout(_:blockID:)`, a bare-runner road with no focus
    /// migration and no gone row). The frame pads that row, the landed row
    /// slips past the fold, and before the fix the kept-alive landing
    /// re-aimed the page after her menu pick (measured: 65 → 75, 18 more
    /// aims). A frame changes no row IDENTITY, so the landing was the ONLY
    /// mover here — which is what makes this the discriminating face pin
    /// (compare the split below).
    @Test func herCalloutAboveTheLandedRowLeavesThePageWhereItIs() async throws {
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

            // A frame on the row above the landed one. The hosted board's
            // `.task` observes the store, so the projection lands by itself;
            // the explicit adopt below makes the pin deterministic either way.
            await model.applyCallout(
                .color(CalloutPalette.defaultName), blockID: fixture.blocks[1].block)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: fixture.postID) })
            await settle(window, hosting, until: { false }, maxTurns: 16)
            let after = offset(article)
            #expect(model.articleLanding == nil, "the callout ended the landing")
            #expect(abs(after - before) < 2,
                    """
                    the page stays where it was after her callout (\(before) → \
                    \(after)) — before the fix the kept-alive landing re-aimed \
                    the far block to the foot after her menu pick
                    """)
        }
    }

    /// **R2-1's second door, mounted — RED ON THE ROUND-1 TREE (aims 11 → 64:
    /// the landing burned to its whole bound fighting the reflow below).** "Make every newline a
    /// block" (18c's U-6, the bottom bar's note row) over eleven three-line
    /// blocks above the landed one: the split ends the landing and spends no
    /// aim. **What this pin deliberately does NOT promise:** that the page's
    /// offset stays. Measured at the ladder's round 2 (a temporary probe,
    /// twice): the column's IDENTITY changes (22 rows inserted above), and on
    /// that SwiftUI keeps the bottom-anchored content — the last row stays at
    /// the foot and the offset moves by exactly the height inserted above it
    /// (406 → 1268) — with NO landing ever set and NO proxy scroll ever
    /// issued (a hand-scrolled page moved identically). That is the
    /// framework's own reflow on a structural act, not the landing's, and it
    /// is the same on both sides of this fix; the landing's 53 extra aims on
    /// the old tree merely fought it. Her block stays where she sees it.
    @Test func herNoteWideSplitEndsTheLandingAndSpendsNoAim() async throws {
        try await withSession(blocks: 12, text: { i in
            i == 12
                ? TakesArticleScrollTests.proseText(i)
                : "Line one of \(i).\nLine two of \(i).\nLine three of \(i)."
        }) { session, fixture, db, mount in
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
            #expect(offset(article) > 0, "non-vacuity: the landing revealed the far block")
            let aimsBefore = model.articleLandingAims
            #expect(aimsBefore > 0, "non-vacuity: the landing aimed")

            await model.splitEveryNewlineIntoBlocks()
            model.adopt(try await db.read { try Queries.takesProjection($0, post: fixture.postID) })
            await settle(window, hosting, until: { false }, maxTurns: 20)
            #expect(model.projection.slots.count > 12,
                    "non-vacuity: the split minted rows (\(model.projection.slots.count))")
            #expect(model.articleLanding == nil, "the split ended the landing")
            #expect(model.articleLandingAims == aimsBefore,
                    """
                    the landing spent no aim after her split (\(aimsBefore) → \
                    \(model.articleLandingAims)) — before the fix it re-aimed \
                    to its whole 64-aim bound against the framework's own reflow
                    """)
        }
    }

    /// **R3-1, the face — RED ON THE ROUND-2 TREE (65 → 93).** Entered on
    /// the last block, the board reveals it at the foot (measured at rest:
    /// the row at 571–617 in a 619 pt viewport, unchanged over 72 turns);
    /// she then ⌘-picks ONE row above it. The pick summons the selection
    /// banner ABOVE the article (`mergeSelectionBanner` precedes
    /// `singleColumnArticle` in the board's VStack), which shrinks the
    /// article's VIEWPORT by the banner's height — the landed row now reads
    /// as clipped at the foot, and before the fix the kept-alive landing
    /// revealed it after her click: 65 → 93 (exactly the banner's 28 pt),
    /// nine more aims. With NO landing pending the same pick moves the page
    /// not at all (the round-3 control), so the landing was the only mover.
    /// A ⌘-click deliberately never migrates the ring (picking blocks is not
    /// writing in one — `TakesBoardView`'s `onCommandClick`), which is why
    /// nothing else ended it. The viewport assertion pins the MECHANISM: a
    /// viewport-height change is the third way a landed row leaves the
    /// screen, beside content height and the live pane.
    @Test func herPickAboveTheLandedRowLeavesThePageWhereItIs() async throws {
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
            let aimsBefore = model.articleLandingAims
            let viewportBefore = article.contentView.bounds.height
            #expect(before > 0, "non-vacuity: the landing revealed the far block (\(before))")
            #expect(aimsBefore > 0, "non-vacuity: the landing aimed")

            model.toggleMergeSelection(fixture.blocks[0].block)
            await settle(window, hosting, until: { false }, maxTurns: 20)
            let after = offset(article)
            let viewportAfter = article.contentView.bounds.height
            #expect(viewportAfter < viewportBefore - 2,
                    """
                    non-vacuity, the mechanism: the pick's banner took room above \
                    the article (viewport \(viewportBefore) → \(viewportAfter))
                    """)
            #expect(model.articleLanding == nil, "the pick ended the landing")
            #expect(abs(after - before) < 2,
                    """
                    the page stays where it was after her pick (\(before) → \
                    \(after)) — before the fix the kept-alive landing revealed \
                    the far block again once the banner had shrunk the viewport
                    """)
            #expect(model.articleLandingAims == aimsBefore,
                    "the landing spent no aim after her pick (\(aimsBefore) → \(model.articleLandingAims))")
        }
    }

    /// **R3-1's whole road, mounted:** two picks, then the banner's Delete
    /// (rows REMOVED through a bare runner with no `parkFocus` — the rule's
    /// letter, armed at the door). Red on the round-2 tree for the same
    /// reason as the pin above (the picks moved the page 65 → 93 and the
    /// landing survived into the delete); measured on this tree: the delete
    /// itself moves nothing (its no-landing control 65 → 65), so the road's
    /// promise is the page at rest across all of it.
    @Test func herPickAndDeleteAboveTheLandedRowLeavesThePageWhereItIs() async throws {
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
            let aimsBefore = model.articleLandingAims
            #expect(before > 0, "non-vacuity: the landing revealed the far block (\(before))")
            #expect(aimsBefore > 0, "non-vacuity: the landing aimed")

            // Two rows above the landed one, picked and deleted. The hosted
            // board's `.task` observes the store, so the projection lands by
            // itself; the explicit adopt makes the pin deterministic.
            model.toggleMergeSelection(fixture.blocks[0].block)
            model.toggleMergeSelection(fixture.blocks[1].block)
            await model.deleteSelectedBlocks()
            model.adopt(try await db.read { try Queries.takesProjection($0, post: fixture.postID) })
            await settle(window, hosting, until: { false }, maxTurns: 20)
            let after = offset(article)
            #expect(model.projection.slots.count == 10,
                    "non-vacuity: the delete removed two rows (\(model.projection.slots.count))")
            #expect(model.articleLanding == nil, "the picks and the delete ended the landing")
            #expect(abs(after - before) < 2,
                    """
                    the page stays where it was across her picks and delete \
                    (\(before) → \(after)) — before the fix the kept-alive \
                    landing revealed the far block again after the first pick
                    """)
            #expect(model.articleLandingAims == aimsBefore,
                    "the landing spent no aim across the road (\(aimsBefore) → \(model.articleLandingAims))")
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

    // MARK: - 17q — THE LANDING WINS, AND WHAT "THE SAME BLOCK" MEANS
    //         (her R-Q20, keyed by her R-Q21)

    /// **HER RULING R-Q20 (2026-09-13, on J3): *"the block I came from
    /// wins."*** Her reasoning, verbatim: *"I'm inclined towards Only the
    /// block I came from, since switching between different modes is supposed
    /// to be seamless and keep the place you're writing in."*
    ///
    /// **…and HER RULING R-Q21 (2026-09-12, on J14) says what "the same
    /// block" MEANS: the note's CURRENT block did not CHANGE while she was
    /// away.** So a landing outranks the memory iff it names a different
    /// block than the one that was current when the board was last shown; a
    /// plain mode round trip restores exactly, and only a deliberate move to
    /// another block makes the landing win — the page then starts where a
    /// mount starts (the top) and the landing reveals from there, ONE move
    /// instead of two.
    ///
    /// **Red on the 17q-as-built rule** (`75d690ff`, which keyed "the same
    /// block" on the remembered ROW): the same-block arms below asked for
    /// `.scrollToRow`/`.wanted` and got `.remember(.top)`/`.settled`, because
    /// a block mid-page is never the row at the fold.
    @Test func theLandingOutranksAMoveToAnotherBlockButNotAPlainRoundTrip() {
        let left = TakesBoardLayout.ArticlePlace(rowID: "left")

        // (a) THE HARNESS'S ORDER — the landing is already pending when the
        // first geometry arrives (`landingModel` adopts before mounting, and
        // so does `CommandRoutingTests`). She MOVED: the block she comes back
        // on is not the one she left in, so the restore settles at once and
        // issues NO scroll.
        let a = freshBoard("outranks-pending", lastCurrentRow: "was-here")
        a.landArticle(on: "far")
        #expect(a.consumeArticleGeometry(
            geometry(offset: 0), remembered: left, positionedByUser: false,
            order: ["left", "far"]) == .remember(.top))
        #expect(a.articleRestore == .settled)
        #expect(a.articleRestoreAims == 0, "the landing wins WITHOUT a restore aim")
        #expect(a.articleReadyForLanding, "…and the landing may land at once")

        // (b) A PLAIN ROUND TRIP — the landing names the block that was
        // current when the board was last shown, so nothing moved while she
        // was away and the restore runs exactly as it does with no landing.
        // **Note the row it names is NOT the remembered one** — that is the
        // whole of R-Q21: her block sits mid-page, not at the fold.
        let b = freshBoard("outranks-same", lastCurrentRow: "was-here")
        b.landArticle(on: "was-here")
        #expect(b.consumeArticleGeometry(
            geometry(offset: 0), remembered: left, positionedByUser: false,
            order: ["left", "was-here"]) == .scrollToRow("left"))
        #expect(b.articleRestore == .wanted(left))

        // (c) NO LANDING — unchanged, the memory rules.
        let c = freshBoard("outranks-none", lastCurrentRow: "was-here")
        #expect(c.consumeArticleGeometry(
            geometry(offset: 0), remembered: left, positionedByUser: false,
            order: ["left", "far"]) == .scrollToRow("left"))

        // (d) THE APP'S ORDER — the geometry is first (the article's
        // ScrollView exists from the first layout; the projection arrives on
        // a `.task`), so the restore is already `.wanted` when the landing is
        // armed. A landing on ANOTHER block ends it on the spot — and it
        // cannot have moved anything, because before the projection the
        // column holds no rows and `scrollTo` on an id it does not hold is a
        // no-op.
        let d = freshBoard("outranks-wanted", lastCurrentRow: "was-here")
        #expect(d.consumeArticleGeometry(
            geometry(offset: 0), remembered: left, positionedByUser: false,
            order: nil) == .scrollToRow("left"))
        #expect(d.articleRestore == .wanted(left))
        d.landArticle(on: "far")
        #expect(d.articleRestore == .settled, "the arriving landing ended the pending restore")
        #expect(d.consumeArticleGeometry(
            geometry(offset: 0), remembered: left, positionedByUser: false,
            order: ["left", "far"]) == .remember(.top))

        // (e) …and a plain round trip's landing arriving mid-restore leaves
        // it running.
        let e = freshBoard("outranks-wanted-same", lastCurrentRow: "was-here")
        _ = e.consumeArticleGeometry(
            geometry(offset: 0), remembered: left, positionedByUser: false, order: nil)
        e.landArticle(on: "was-here")
        #expect(e.articleRestore == .wanted(left))

        // (f) The TOP remembered settles at once and issues no scroll (R1-1);
        // a landing that OUTRANKS wins there without a branch. (A landing
        // that does NOT outrank stands down at the TOP too — in both orders
        // since the 17q ladder's round 2, R2-1: `theTopStandDownHoldsIn
        // TheAppsOrderToo`, and arm `t` of the bloom pin for this order.)
        let f = freshBoard("outranks-top", lastCurrentRow: "was-here")
        f.landArticle(on: "far")
        #expect(f.consumeArticleGeometry(
            geometry(offset: 0), remembered: .top, positionedByUser: false,
            order: ["left", "far"]) == .remember(.top))
        #expect(f.articleRestoreAims == 0)

        // (g) THE TWO NIL CASES, stated. No landing ⇒ the memory rules
        // whatever we know about the last showing; a landing with NO recorded
        // prior current block ⇒ the landing rules, because "the same block"
        // is a claim about a showing we have no record of.
        #expect(TakesBoardLayout.landingOutranks(nil, lastCurrentRow: "was-here") == false)
        #expect(TakesBoardLayout.landingOutranks(nil, lastCurrentRow: nil) == false)
        #expect(TakesBoardLayout.landingOutranks("far", lastCurrentRow: nil))
        #expect(TakesBoardLayout.landingOutranks("far", lastCurrentRow: "was-here"))
        #expect(TakesBoardLayout.landingOutranks("was-here", lastCurrentRow: "was-here") == false)
    }

    @Test func aLandingOnAnotherBlockWinsOverTheRememberedPlace() async throws {
        try await withSession(blocks: 60) { session, fixture, db, mount in
            let router = session.commandRouter
            router.forgetCurrentBlock(for: fixture.postID)
            defer { router.forgetCurrentBlock(for: fixture.postID) }

            // Leave the page deep in the note, with NO landing.
            let first = try await landingModel(session: session, fixture: fixture, db: db)
            let (windowA, hostingA) = await mount(first)
            guard let articleA = articleScrollView(in: hostingA) else {
                Issue.record("no article scroll view on the first mount")
                return
            }
            scroll(articleA, to: 800)
            await settle(windowA, hostingA, until: { false }, maxTurns: 10)
            let remembered = session.editorRouter.takesArticlePlaces[fixture.postID]
            #expect(remembered?.rowID != nil,
                    "non-vacuity: she left the page on a ROW, not at the top")
            windowA.orderOut(nil)
            first.teardown()
            await settle(windowA, hostingA, until: { false }, maxTurns: 4)

            // …then come back from a FAR block — the note's last.
            let token = router.registerDetail(postID: fixture.postID, mode: .write) { _ in }
            defer { router.unregisterDetail(token) }
            router.noteFocusedBlock(
                fixture.lastBlock, variantID: fixture.lastVariant,
                postID: fixture.postID, utf16Offset: 0)

            let second = try await landingModel(session: session, fixture: fixture, db: db)
            let (windowB, hostingB) = await mount(second)
            guard let articleB = articleScrollView(in: hostingB) else {
                Issue.record("no article scroll view on the second mount")
                return
            }
            await settle(windowB, hostingB, until: { false }, maxTurns: 14)

            #expect(second.articleLandingAims > 0,
                    "non-vacuity: the landing really did aim the page")
            #expect(second.board.articleRestoreAims == 0,
                    """
                    the remembered place was NOT restored on the way \
                    (\(second.board.articleRestoreAims) restore aims) — before \
                    her R-Q20 the page went to the remembered row first and \
                    the reveal then moved it again: J3's double move
                    """)

            guard let last = articlePanes(in: hostingB).first(where: {
                $0.identifier?.rawValue == "pane:article|\(fixture.lastVariant)"
            }) else {
                Issue.record("the block she came from is not mounted")
                return
            }
            let visible = articleB.contentView.bounds
            let inViewport = last.convert(last.bounds, to: articleB.contentView)
            #expect(inViewport.maxY <= visible.maxY + 2,
                    "the block she came from is ON SCREEN (row \(inViewport), visible \(visible))")
        }
    }

    /// **THE ENTRY RING'S OWN ROAD, in a pin — and the "scrolled AWAY from
    /// her own block" arm** (17q piece 6; its premise corrected at the 17q
    /// ladder's sanity pass). Mount A is entered through the FACT — the N9
    /// entry arm, which is how the app's board always gets its ring — rather
    /// than through a click, so the ring is set by `landAuthorityFocus` and
    /// nothing else. Her hand then ends the entry landing (in the app a wheel
    /// scroll is `isPositionedByUser` and ends it; the harness's clip-view
    /// scroll is NOT, and a kept-alive landing re-reveals the block at the
    /// foot — which is what this pin's first version measured without saying
    /// so, so its "mid-page" premise never held), and her scroll takes her
    /// own block OFF the page. She leaves and comes back with nothing
    /// clicked. The mid-page arm is
    /// `aPlainRoundTripComesBackToTheSameLineNotOnlyTheSameRow`.
    ///
    /// **RE-ARMED AS THE RULED CHANGE (18l-c U8, her R-18l-13 — "caret anchors
    /// the editing modes"; the U8 RECORD names old → new).** OLD (17q): the
    /// landing STOOD DOWN (`articleLanding == nil`), the restore ran, and the
    /// page came back exactly as she left it WITHOUT her block on it (the
    /// resolver's stated consequence). NEW: the restore still runs (the page she
    /// left comes back first — the memory PLACES the page), and the entry landing
    /// then REVEALS her block, because a mode's private scroll memory never
    /// outranks a mode switch — her block is on screen, its row built, its take
    /// live. RED on the pre-U8 tree: her block off the page. (Named
    /// `theEntryRingsOwnRoadAlsoComesBackWhereSheLeftIt` until the U8 ladder's
    /// R1-1 rename — the page no longer simply ends where she left it when her
    /// block is off it.)
    @Test func theEntryRingsOwnRoadComesBackThenRevealsHerBlock() async throws {
        try await withSession(blocks: 60) { session, fixture, db, mount in
            let router = session.commandRouter
            router.forgetCurrentBlock(for: fixture.postID)
            defer { router.forgetCurrentBlock(for: fixture.postID) }
            let token = router.registerDetail(postID: fixture.postID, mode: .takes) { _ in }
            defer { router.unregisterDetail(token) }
            let hers = fixture.blocks[40]
            router.noteFocusedBlock(
                hers.block, variantID: hers.variant,
                postID: fixture.postID, utf16Offset: 0)

            let first = try await landingModel(session: session, fixture: fixture, db: db)
            let (windowA, hostingA) = await mount(first)
            guard let articleA = articleScrollView(in: hostingA) else {
                Issue.record("no article scroll view on the first mount")
                return
            }
            await settle(windowA, hostingA, until: { false }, maxTurns: 12)
            #expect(first.authority.livePane?.blockID == hers.block,
                    "non-vacuity: the ENTRY ring landed on her block")
            #expect(session.editorRouter.takesArticleCurrentRows[fixture.postID] != nil,
                    "the entry ring recorded it as the board's current block")
            // Her hand ends the entry landing (the model's own door — what a
            // wheel scroll does in the app), then her scroll takes her own
            // block off the page.
            first.clearArticleLanding()
            scroll(articleA, to: max(offset(articleA) - 300, 0))
            await settle(windowA, hostingA, until: { false }, maxTurns: 10)
            #expect(!isOnScreen(hers.variant, hostingA, articleA),
                    "non-vacuity: she scrolled AWAY from her own block")
            guard let before = topOfPage(hostingA, articleA) else {
                Issue.record("no take at the top of the page after scrolling")
                return
            }
            guard let wasAt = fixture.blocks.firstIndex(where: {
                $0.variant == before.variantID
            }) else {
                Issue.record("the top-of-page take is not one of the fixture's")
                return
            }

            windowA.orderOut(nil)
            first.teardown()
            await settle(windowA, hostingA, until: { false }, maxTurns: 4)

            let second = try await landingModel(session: session, fixture: fixture, db: db)
            let (windowB, hostingB) = await mount(second)
            guard let articleB = articleScrollView(in: hostingB) else {
                Issue.record("no article scroll view on the second mount")
                return
            }
            await settle(windowB, hostingB, until: { false }, maxTurns: 14)
            let revealedBy = Date().addingTimeInterval(4)
            while !isOnScreen(hers.variant, hostingB, articleB), Date() < revealedBy {
                await settle(windowB, hostingB, until: { false }, maxTurns: 2)
            }

            #expect(second.board.articleRestoreAims > 0,
                    "the restore ran — the page she left came back first (the memory places the page)")
            #expect(isOnScreen(hers.variant, hostingB, articleB),
                    """
                    R-18l-13: the entry landing then REVEALS her block — the memory never \
                    outranks a mode switch (red on the pre-U8 tree: the landing stood \
                    down and the page came back without it; top of page was block \(wasAt + 1))
                    """)
            #expect(second.articleLandingAims > 0,
                    "non-vacuity: the entry landing aimed the page (it no longer stands down)")
            #expect(second.authority.livePane?.blockID == hers.block,
                    "…and the ring is on her block, its row built")
        }
    }

    /// **THE PLAIN ROUND TRIP — RED ON THE 17q-AS-BUILT RULE** (`75d690ff`),
    /// and her ruling R-Q21's own pin. She leaves Takes with her block
    /// MID-PAGE (where a block she is writing in normally sits — not at the
    /// fold), goes to Write, comes straight back with nothing clicked: the
    /// page is exactly where she left it.
    ///
    /// The as-built rule keyed "the same block" on the remembered ROW, so a
    /// block mid-page never matched and the landing won: the restore never
    /// aimed (`articleRestoreAims == 0`) and the page opened at the top with
    /// her block revealed at the foot — a page that MOVES on a plain mode
    /// switch, which is what her own reason for R-Q20 argues against (J14).
    ///
    /// The first mount deliberately enters with NO fact, so nothing lands;
    /// the ring is then migrated to a mid-page block through the board's own
    /// door (`focus`) — a click in Takes — which is what makes that block
    /// both the note's current block AND this board's last-shown one.
    ///
    /// The third mirror — a remount with NO landing at all — is
    /// `aBoardLeftScrolledComesBackWhereSheLeftIt`, unchanged by 17q.
    @Test func aPlainRoundTripComesBackExactlyWhereSheLeftIt() async throws {
        try await withSession(blocks: 60) { session, fixture, db, mount in
            let router = session.commandRouter
            router.forgetCurrentBlock(for: fixture.postID)
            defer { router.forgetCurrentBlock(for: fixture.postID) }
            // The board REPORTS its ring through `noteFocusedBlock`, which
            // refuses a post that is not the active detail — so the click
            // below only becomes the note's current block with a detail
            // registered, exactly as the app has one.
            let token = router.registerDetail(postID: fixture.postID, mode: .takes) { _ in }
            defer { router.unregisterDetail(token) }

            let first = try await landingModel(session: session, fixture: fixture, db: db)
            let (windowA, hostingA) = await mount(first)
            guard let articleA = articleScrollView(in: hostingA) else {
                Issue.record("no article scroll view on the first mount")
                return
            }
            // The board's ENTRY ring is a write site too (`landAuthorityFocus`),
            // not only the click below — pinned here because the app's board
            // always gets its ring that way and a silent no-write would make
            // every entry look like "she moved blocks while away".
            #expect(session.editorRouter.takesArticleCurrentRows[fixture.postID] != nil,
                    "the entry ring recorded the board's current block")
            scroll(articleA, to: 800)
            await settle(windowA, hostingA, until: { false }, maxTurns: 10)
            guard let atTop = topOfPage(hostingA, articleA) else {
                Issue.record("no take at the top of the page after scrolling")
                return
            }
            guard let topIndex = fixture.blocks.firstIndex(where: {
                $0.variant == atTop.variantID
            }) else {
                Issue.record("the top-of-page take is not one of the fixture's")
                return
            }
            // Her block: two rows BELOW the fold — mid-page, visible, and
            // deliberately not the row the memory names.
            guard topIndex + 2 < fixture.blocks.count else {
                Issue.record("the fixture is too short for a mid-page block")
                return
            }
            let mid = fixture.blocks[topIndex + 2]
            first.focus(TakesViewModel.PaneKey(
                columnID: TakesViewModel.takesMainColumnID,
                blockID: mid.block, variantID: mid.variant))
            await settle(windowA, hostingA, until: { false }, maxTurns: 8)
            #expect(first.authority.livePane?.blockID == mid.block,
                    "non-vacuity: the ring really moved to the mid-page block")
            guard let before = topOfPage(hostingA, articleA) else {
                Issue.record("no take at the top of the page after the click")
                return
            }
            guard let wasAt = fixture.blocks.firstIndex(where: {
                $0.variant == before.variantID
            }) else {
                Issue.record("the top-of-page take is not one of the fixture's")
                return
            }
            #expect(fixture.blocks[wasAt].block != mid.block,
                    """
                    non-vacuity: her block is MID-PAGE, not the row at the \
                    fold — which is exactly the shape the as-built rule got \
                    wrong
                    """)

            windowA.orderOut(nil)
            first.teardown()
            await settle(windowA, hostingA, until: { false }, maxTurns: 4)

            // …and back, with nothing clicked: the note's current block is
            // still the one she was in.
            let second = try await landingModel(session: session, fixture: fixture, db: db)
            let (windowB, hostingB) = await mount(second)
            guard let articleB = articleScrollView(in: hostingB) else {
                Issue.record("no article scroll view on the second mount")
                return
            }
            await settle(windowB, hostingB, until: { false }, maxTurns: 14)

            // RE-ARMED AS THE RULED CHANGE (18l-c U8, her R-18l-13 — the U8
            // RECORD names old → new). OLD: `articleLanding == nil` — the
            // landing STOOD DOWN on the block she was already in. NEW: the
            // entry landing no longer stands down; it rides through the restore
            // and, her block being ON the page she left (mid-page, inside the
            // comfort band), it asks for NOTHING — zero aims, the page exact.
            // (Green on both sides by design: R-18l-13 changes nothing when the
            // memory and the caret agree.)
            #expect(second.articleLandingAims == 0,
                    """
                    the entry landing rode through the restore and aimed nothing — \
                    her block was already on the page she left (\(second.articleLandingAims) aims)
                    """)
            #expect(second.board.articleRestoreAims > 0,
                    """
                    the restore RAN (\(second.board.articleRestoreAims) aims) — \
                    the as-built rule let the landing outrank a plain round \
                    trip and never aimed at all
                    """)
            guard let after = topOfPage(hostingB, articleB) else {
                Issue.record("no take at the top of the page after the remount")
                return
            }
            guard let isAt = fixture.blocks.firstIndex(where: {
                $0.variant == after.variantID
            }) else {
                Issue.record("the top-of-page take is not one of the fixture's")
                return
            }
            #expect(abs(isAt - wasAt) <= 1,
                    """
                    a plain round trip comes back EXACTLY where she left it \
                    (block \(isAt + 1), left on block \(wasAt + 1) of \
                    \(fixture.blocks.count)) — the as-built rule opened at the \
                    top and revealed her block at the foot
                    """)
        }
    }

    // MARK: - The 17q ladder, round 1 — R1-2: the BLOOM door is never weighed
    //         against the memory (17o row 8's door keeps going there)

    private func isOnScreen(_ variantID: String, _ hosting: NSView, _ article: NSScrollView) -> Bool {
        guard let pane = articlePanes(in: hosting).first(where: {
            $0.identifier?.rawValue == "pane:article|\(variantID)"
        }) else { return false }
        let visible = article.contentView.bounds
        let frame = pane.convert(pane.bounds, to: article.contentView)
        return frame.minY >= visible.minY - 2 && frame.maxY <= visible.maxY + 2
    }

    /// **RED ON THE 17q TREE (`ac9c46fb`).** 17o row 8's door — Write's takes
    /// panel, *Open Takes mode* on a block — must GO there. Piece 6's
    /// stand-down (an ENTRY landing on the block she was in is cleared, so a
    /// plain round trip restores exactly) was written without distinguishing
    /// the two landing arms, so a BLOOM on the block the ring was last in —
    /// the ordinary road: she was in it on Takes, ⌘1, the panel on it,
    /// *Open Takes mode* — was cleared too; when she had scrolled that block
    /// off the page before leaving, the bloomed, ringed block came back OFF
    /// the page (measured at the ladder: `landing=nil`, `landingAims=0`, the
    /// block one point below the viewport). A bloom landing now rides through
    /// the restore and reveals afterwards — 17p's shipped road
    /// (`TakesBoardLayout.ArticleLandingKind`).
    @Test func theBloomDoorStillGoesToTheBlockTheRingWasLastIn() async throws {
        try await withSession(blocks: 60) { session, fixture, db, mount in
            let router = session.commandRouter
            router.forgetCurrentBlock(for: fixture.postID)
            defer { router.forgetCurrentBlock(for: fixture.postID) }
            let token = router.registerDetail(postID: fixture.postID, mode: .takes) { _ in }
            defer { router.unregisterDetail(token) }
            let hers = fixture.blocks[40]
            router.noteFocusedBlock(
                hers.block, variantID: hers.variant, postID: fixture.postID, utf16Offset: 0)

            let first = try await landingModel(session: session, fixture: fixture, db: db)
            let (windowA, hostingA) = await mount(first)
            guard let articleA = articleScrollView(in: hostingA) else {
                Issue.record("no article scroll view on the first mount")
                return
            }
            await settle(windowA, hostingA, until: { false }, maxTurns: 12)
            #expect(first.authority.livePane?.blockID == hers.block,
                    "non-vacuity: the entry ring is on her block")
            // Her scroll: her own block leaves the page (it was revealed at
            // the foot; half a page up puts it below the fold). Her hand ends
            // the entry landing first — in the app a wheel scroll is
            // `isPositionedByUser` and ends it; the harness's clip-view
            // scroll is not seen as hers, and the kept-alive landing would
            // otherwise re-reveal the block at the foot (measured at the
            // ladder: 300 pt up, the block back at `maxY == visible.maxY`).
            first.clearArticleLanding()
            scroll(articleA, to: max(offset(articleA) - 500, 0))
            await settle(windowA, hostingA, until: { false }, maxTurns: 10)
            #expect(!isOnScreen(hers.variant, hostingA, articleA),
                    "non-vacuity: she scrolled her block off the page")
            windowA.orderOut(nil)
            first.teardown()
            await settle(windowA, hostingA, until: { false }, maxTurns: 4)

            // Write's takes panel → *Open Takes mode* on HER block.
            router.pendingTakesLanding = .bloom(postID: fixture.postID, blockID: hers.block)
            let second = try await landingModel(session: session, fixture: fixture, db: db)
            let (windowB, hostingB) = await mount(second)
            guard let articleB = articleScrollView(in: hostingB) else {
                Issue.record("no article scroll view on the second mount")
                return
            }
            await settle(windowB, hostingB, until: { false }, maxTurns: 16)
            #expect(second.board.articleRestoreAims > 0,
                    "the restore ran — a bloom is not weighed against it")
            #expect(second.articleLandingAims > 0,
                    "non-vacuity: the bloom's landing really aimed the page")
            #expect(isOnScreen(hers.variant, hostingB, articleB),
                    """
                    row 8: the bloom door GOES to the block — on the 17q tree \
                    the stand-down cleared its landing and the page came back \
                    without it (\(second.board.articleRestoreAims) restore \
                    aims, \(second.articleLandingAims) landing aims)
                    """)
        }
    }

    /// The same rule, pure, in both mount orders — and the entry arm's
    /// stand-down now reaches a page left at the TOP too (the ladder's fold:
    /// one resolver, consulted once, whatever the memory holds).
    @Test func aBloomLandingRidesThroughTheRestoreInBothOrders() {
        let left = TakesBoardLayout.ArticlePlace(rowID: "left")

        // The pins' order: the bloom is pending at the first geometry, on the
        // block the ring was last in — the restore runs AND the landing lives.
        let a = freshBoard("bloom-pending", lastCurrentRow: "was-here")
        a.landArticle(on: "was-here", kind: .bloom)
        #expect(a.consumeArticleGeometry(
            geometry(offset: 0), remembered: left, positionedByUser: false,
            order: ["left", "was-here"]) == .scrollToRow("left"))
        #expect(a.articleRestore == .wanted(left))
        #expect(a.articleLanding == "was-here", "the bloom's landing survives the restore")

        // The app's order: the bloom arrives mid-restore, on ANOTHER block —
        // it does not end the restore either (17p's road: restore, then reveal).
        let d = freshBoard("bloom-wanted", lastCurrentRow: "was-here")
        _ = d.consumeArticleGeometry(
            geometry(offset: 0), remembered: left, positionedByUser: false, order: nil)
        d.landArticle(on: "far", kind: .bloom)
        #expect(d.articleRestore == .wanted(left))
        #expect(d.articleLanding == "far")

        // …and an ENTRY landing on the block she was in, at a page left at
        // the TOP. RE-ARMED AS THE RULED CHANGE (18l-c U8, her R-18l-13 — the
        // U8 RECORD names old → new). OLD: `t.articleLanding == nil` — it stood
        // down and the page came back at rest without her block. NEW: it rides
        // through exactly as the bloom does — the TOP restore still issues no
        // scroll, and the landing lives to reveal her block if the page at rest
        // does not show it.
        let t = freshBoard("entry-top-same", lastCurrentRow: "was-here")
        t.landArticle(on: "was-here")
        #expect(t.consumeArticleGeometry(
            geometry(offset: 0), remembered: .top, positionedByUser: false,
            order: ["left", "was-here"]) == .remember(.top))
        #expect(t.articleLanding == "was-here",
                "R-18l-13: the entry landing is never stood down by the memory (red on the pre-U8 tree: nil)")
        #expect(t.articleRestoreAims == 0)
    }

    // MARK: - The 17q ladder, round 1 — R1-1: the page comes back to the same
    //         LINE, not only the same row

    /// **RED ON THE 17q TREE (`ac9c46fb`) — the open row's mechanism.** The
    /// memory was the row STRADDLING the fold, restored with its top AT the
    /// fold, so every restored page sat lower by the straddle and the block
    /// she was in moved that far toward the page's edge (piece 6's walk,
    /// `17` → `18`; the ladder's probe: 571 → 618 pt below the fold on the
    /// 46-pt fixture). The memory now carries where the row's top SAT and
    /// the restore anchors it back there.
    @Test func theRestoreRemembersWhereTheRowSatAndPutsItBackThere() {
        let board = freshBoard("sub-row")
        board.noteArticleRowFrame("a", CGRect(x: 0, y: -30, width: 680, height: 60))
        board.noteArticleRowFrame("b", CGRect(x: 0, y: 36, width: 680, height: 60))
        board.noteArticleRowFrame("c", CGRect(x: 0, y: 102, width: 680, height: 60))
        let place = TakesBoardLayout.ArticlePlace(rowID: "b", into: 36, rowHeight: 60)
        #expect(board.consumeArticleGeometry(
            geometry(offset: 100), remembered: nil, positionedByUser: false)
                == .remember(place),
                "the first row at or below the fold, with where its top sat")

        // The restore aims the SAME row to the SAME line — an anchor, never a
        // nudge (the two 17p measurements on `ArticlePlace` still bind).
        let back = freshBoard("sub-row-back")
        let viewport = geometry(offset: 0).viewport
        let anchorY = TakesBoardLayout.ArticlePlace.anchorY(
            into: 36, rowHeight: 60, viewport: viewport)
        #expect(anchorY > 0 && anchorY < 1, "a unit point inside [0, 1] (\(anchorY))")
        #expect(back.consumeArticleGeometry(
            geometry(offset: 0), remembered: place, positionedByUser: false,
            order: ["a", "b", "c"]) == .scrollToRow("b", anchorY: anchorY))
        #expect(back.articleRestore == .wanted(place))
        // The row reports its top AT the fold — where 17p settled — and the
        // restore does not: that is 36 pt short of where she left it.
        back.noteArticleRowFrame("b", CGRect(x: 0, y: 0, width: 680, height: 60))
        #expect(back.consumeArticleGeometry(
            geometry(offset: 0), remembered: place, positionedByUser: false,
            order: ["a", "b", "c"]) == .scrollToRow("b", anchorY: anchorY),
                "the row at the fold is not where she left it — re-aim")
        #expect(back.articleRestoreAims == 2)
        // The row reports its top where it sat — settled, no scroll: INTO A
        // HOLD since the 17q ladder's round 3 (R3-1), because the row's
        // report is not the page's final word.
        back.noteArticleRowFrame("b", CGRect(x: 0, y: 36, width: 680, height: 60))
        #expect(back.consumeArticleGeometry(
            geometry(offset: 0), remembered: place, positionedByUser: false,
            order: ["a", "b", "c"]) == .wait)
        #expect(back.articleRestore == .holding(place))

        // **The fallbacks, sub-row where the anchor can express it** (the 17q
        // ladder's round 2, R2-3 — MEASURED on the mounted harness: a unit
        // point BELOW 0 is honoured linearly by `scrollTo` (a short straddler
        // aimed at −30 landed at −30.0 and settled), a row TALLER than the
        // viewport is not (aimed to sit −400 it landed at −838.5 and never
        // settled — SwiftUI aligns such a row's anchor point with the
        // viewport's top). So: no row below the fold fits → the SHORT
        // straddling row is remembered with where its top sat (negative) and
        // aimed there; a TALL straddler and the `below` branch stay at the
        // fold, 17p's rule, now with its reason measured.
        let tall = freshBoard("sub-row-tall")
        tall.noteArticleRowFrame("s", CGRect(x: 0, y: -30, width: 680, height: 60))
        tall.noteArticleRowFrame("t", CGRect(x: 0, y: 36, width: 680, height: 900))
        #expect(tall.consumeArticleGeometry(
            geometry(offset: 100), remembered: nil, positionedByUser: false)
                == .remember(TakesBoardLayout.ArticlePlace(rowID: "s", into: -30, rowHeight: 60)),
                "a short straddler keeps where its top sat (on the round-1 tree: `s` at the fold)")
        let below = TakesBoardLayout.ArticlePlace.anchorY(into: -30, rowHeight: 60, viewport: 700)
        #expect(below < 0 && below > -0.1, "a unit point below 0, honoured linearly (\(below))")
        // A TALL straddler aims at the fold (measured: a non-zero anchor on a
        // row taller than the viewport does not land where the arithmetic
        // says and never settles).
        let giant = freshBoard("sub-row-giant")
        giant.noteArticleRowFrame("g", CGRect(x: 0, y: -100, width: 680, height: 900))
        giant.noteArticleRowFrame("h", CGRect(x: 0, y: 806, width: 680, height: 60))
        #expect(giant.consumeArticleGeometry(
            geometry(offset: 100), remembered: nil, positionedByUser: false)
                == .remember(TakesBoardLayout.ArticlePlace(rowID: "g", into: 0, rowHeight: 900)))
        #expect(TakesBoardLayout.ArticlePlace.anchorY(into: -100, rowHeight: 900, viewport: 700) == 0)
        #expect(TakesBoardLayout.ArticlePlace.anchorY(into: 36, rowHeight: 900, viewport: 700) == 0)
        // The `below` branch (nothing straddles, the first row at or below
        // the fold does not fit): at the fold, 17p's rule.
        let gap = freshBoard("sub-row-gap")
        gap.noteArticleRowFrame("u", CGRect(x: 0, y: 3, width: 680, height: 900))
        #expect(gap.consumeArticleGeometry(
            geometry(offset: 100), remembered: nil, positionedByUser: false)
                == .remember(TakesBoardLayout.ArticlePlace(rowID: "u", into: 0, rowHeight: 900)))
        // A 17p-shaped place (into 0) aims exactly as 17p did.
        #expect(TakesBoardLayout.ArticlePlace.anchorY(into: 0, rowHeight: 60, viewport: 700) == 0)
    }

    /// **RED ON THE ROUND-1 TREE, mounted (the R2-3 gate's measurement, kept
    /// as the pin):** a SHORT row that straddled the fold — the last block of
    /// a short note scrolled up through the typewriter room, her "you only
    /// have two blocks" case; measured in USE at the round-2 review as a
    /// ~9 pt drop on an eight-block note (captures `32` → `33`) — is put back
    /// ABOVE the fold where its top sat, by a unit point below 0, and the
    /// restore settles on the row's own report. On the round-1 tree
    /// `anchorY` refused any negative `into`, the row came back AT the fold,
    /// and the settle (`into ± 2`) was never met.
    @Test func aShortRowStraddlingTheFoldComesBackAboveIt() async throws {
        try await withSession(blocks: 60) { session, fixture, db, mount in
            let router = session.commandRouter
            router.forgetCurrentBlock(for: fixture.postID)
            defer { router.forgetCurrentBlock(for: fixture.postID) }

            // A control mount: the fixture rows' real height, off the memory
            // the board itself writes for a fitting row.
            let control = try await landingModel(session: session, fixture: fixture, db: db)
            let (windowA, hostingA) = await mount(control)
            guard let articleA = articleScrollView(in: hostingA) else {
                Issue.record("no article scroll view on the control mount")
                return
            }
            scroll(articleA, to: 800)
            await settle(windowA, hostingA, until: { false }, maxTurns: 10)
            guard let known = session.editorRouter.takesArticlePlaces[fixture.postID],
                  known.rowID != nil, known.rowHeight > 0 else {
                Issue.record("the control mount remembered no row")
                return
            }
            let hers = fixture.blocks[19]
            let hersRow = control.projection.slots[19].placementID
            windowA.orderOut(nil)
            control.teardown()
            await settle(windowA, hostingA, until: { false }, maxTurns: 4)

            // What a short straddler's memory looks like since R2-3: block 20
            // with its top 30 pt ABOVE the fold.
            session.editorRouter.takesArticlePlaces[fixture.postID] =
                TakesBoardLayout.ArticlePlace(rowID: hersRow, into: -30, rowHeight: known.rowHeight)

            let second = try await landingModel(session: session, fixture: fixture, db: db)
            let (windowB, hostingB) = await mount(second)
            guard let articleB = articleScrollView(in: hostingB) else {
                Issue.record("no article scroll view on the second mount")
                return
            }
            await settle(windowB, hostingB, until: { false }, maxTurns: 20)
            // VX-337 (traced — the load-dependent half of this pin): this is a
            // PLAIN round trip (no landing waits), so a restore whose row
            // ARRIVES between geometry reports stays `.wanted` with the page
            // right, by design — `restArrived`'s doc. Whether a geometry
            // report happens to follow the arrival inside this window is
            // SwiftUI's pass ordering, which load moves; the restore's STATE
            // is therefore asserted as arrived-or-reached, and the page's own
            // position (below, unchanged) is the contract.
            #expect(restArrived(second.board.articleRestore, on: hersRow),
                    """
                    the restore reached her row (\(second.board.articleRestore), \
                    \(second.board.articleRestoreAims) aims)
                    """)
            // The pane sits a fixed inset below its row's top; the control
            // mount's fitting row gives the inset (pane top − row top).
            guard let controlPane = paneTopBelowTheFold(known.rowID!, control, hostingA, articleA)
            else {
                Issue.record("the control row's pane is not realized")
                return
            }
            let inset = controlPane - known.into
            guard let paneTop = distanceBelowTheFold(hers.variant, hostingB, articleB) else {
                Issue.record("her block is not realized after the remount")
                return
            }
            let rowTop = paneTop - inset
            // ±2 since the 17q ladder's round 3 (R3-1): the ±4 of round 2 hid
            // the re-resolution's `into · h/V` shortfall on this 46-pt row (~2.2).
            #expect(abs(rowTop - (-30)) <= 2,
                    """
                    the row's top is back ABOVE the fold where it sat (\(rowTop)) — on the \
                    round-1 tree a negative `into` aimed at the fold and the row came back at 0; \
                    on the round-2 tree it came back a fraction short (the settle was not final)
                    """)
        }
    }

    /// The pane's top below the fold for the row a placement id names.
    private func paneTopBelowTheFold(
        _ placementID: String, _ model: TakesViewModel, _ hosting: NSView, _ article: NSScrollView
    ) -> CGFloat? {
        guard let variant = model.projection.slots.first(where: { $0.placementID == placementID })?
                .variantID else { return nil }
        return distanceBelowTheFold(variant, hosting, article)
    }

    /// **RED ON THE 17q TREE (`ac9c46fb`), mounted:** her block MID-PAGE (her
    /// hand ended the entry landing, then her scroll put the block up the
    /// page), leave, come straight back — the block sits where it sat, to the
    /// line. The row-precision pins beside this one (`abs(isAt - wasAt) <=
    /// 1`) are what let a one-row shift pass for three rounds.
    @Test func aPlainRoundTripComesBackToTheSameLineNotOnlyTheSameRow() async throws {
        try await withSession(blocks: 60) { session, fixture, db, mount in
            let router = session.commandRouter
            router.forgetCurrentBlock(for: fixture.postID)
            defer { router.forgetCurrentBlock(for: fixture.postID) }
            let token = router.registerDetail(postID: fixture.postID, mode: .takes) { _ in }
            defer { router.unregisterDetail(token) }
            let hers = fixture.blocks[40]
            router.noteFocusedBlock(
                hers.block, variantID: hers.variant, postID: fixture.postID, utf16Offset: 0)

            let first = try await landingModel(session: session, fixture: fixture, db: db)
            let (windowA, hostingA) = await mount(first)
            guard let articleA = articleScrollView(in: hostingA) else {
                Issue.record("no article scroll view on the first mount")
                return
            }
            await settle(windowA, hostingA, until: { false }, maxTurns: 12)
            #expect(first.authority.livePane?.blockID == hers.block,
                    "non-vacuity: the entry ring landed on her block")
            // Her hand ends the landing (a wheel scroll would); her scroll
            // brings her block up the page, mid-page, off the fold.
            first.clearArticleLanding()
            scroll(articleA, to: offset(articleA) + 300)
            await settle(windowA, hostingA, until: { false }, maxTurns: 10)
            guard let intoA = distanceBelowTheFold(hers.variant, hostingA, articleA) else {
                Issue.record("her block is not realized after her scroll")
                return
            }
            #expect(intoA > 40, "non-vacuity: her block is mid-page, not at the fold (\(intoA))")
            windowA.orderOut(nil)
            first.teardown()
            await settle(windowA, hostingA, until: { false }, maxTurns: 4)

            let second = try await landingModel(session: session, fixture: fixture, db: db)
            let (windowB, hostingB) = await mount(second)
            guard let articleB = articleScrollView(in: hostingB) else {
                Issue.record("no article scroll view on the second mount")
                return
            }
            await settle(windowB, hostingB, until: { false }, maxTurns: 16)
            // RE-ARMED AS THE RULED CHANGE (18l-c U8, her R-18l-13 — the U8
            // RECORD names old → new). OLD: `articleLanding == nil` — "the entry
            // landing stood down". NEW: it rides through the restore and, her
            // block being on the page she left, it asks for NOTHING — zero aims
            // — while the page comes back to the same LINE (the assertion below,
            // unchanged). This pin is also the one that MEASURED the 17q race on
            // the first U8 green attempt (271 → 571): the ride-through's first
            // step now defers to the watch's quiet (`articleEntryRidesThrough`).
            let quietBy = Date().addingTimeInterval(2.5)
            while second.board.articleLanding != nil, Date() < quietBy {
                await settle(windowB, hostingB, until: { false }, maxTurns: 2)
            }
            #expect(second.articleLandingAims == 0,
                    "the entry landing rode through and aimed nothing (\(second.articleLandingAims) aims)")
            #expect(second.board.articleRestoreAims > 0, "the restore ran")
            guard let intoB = distanceBelowTheFold(hers.variant, hostingB, articleB) else {
                Issue.record("her block is not realized after the remount")
                return
            }
            #expect(abs(intoB - intoA) <= 4,
                    """
                    the page comes back to the same LINE: her block sat \
                    \(intoA) pt below the fold and sits \(intoB) now — on the \
                    17q tree the straddling row's top was aligned to the fold \
                    and the page came back a row lower
                    """)
        }
    }

    private func distanceBelowTheFold(
        _ variantID: String, _ hosting: NSView, _ article: NSScrollView
    ) -> CGFloat? {
        guard let pane = articlePanes(in: hosting).first(where: {
            $0.identifier?.rawValue == "pane:article|\(variantID)"
        }) else { return nil }
        let frame = pane.convert(pane.bounds, to: article.contentView)
        return frame.minY - article.contentView.bounds.minY
    }

    // MARK: - The 17q ladder, round 1 — R1-1's re-walk on her 262-block note:
    //         the two mechanisms the trace showed

    /// **THE OPEN ROW'S MECHANISM, measured on A Scandal in Bohemia at the
    /// ladder's re-walk — and GREEN ON BOTH SIDES HERE, said outright.** The
    /// board's FIRST geometry report arrives before `.onAppear`, where
    /// `landingEnabled` used to be set, and `rememberedArticlePlace` is gated
    /// on that flag — so in the app the first geometry read NO memory, settled
    /// the restore at once, and the entry landing then revealed her block
    /// from the top of the page (the trace: `remember TOP` with no `AIM`, the
    /// memory holding a row; captures `20` → `22`). **Which order the harness
    /// cannot reproduce, exactly** (the 17q ladder's round 2, R2-4): the
    /// `.onAppear`-vs-first-geometry order — this hosting view runs
    /// `.onAppear` before its first non-zero geometry, so the flag's timing
    /// (W-1) cannot go red here. The LANDING-vs-first-geometry order it DOES
    /// reproduce, by construction: on the bare-model road the projection
    /// arrives from the view's own `.task`, after the first layout — the
    /// app's order, and the road `aPageLeftAtRestComesBackAtRestOnTheApps
    /// Order` pins R2-1 on. This pin stands as the guard that the app's own
    /// road restores at all. The RED is `theTakesBoardIsTheTakesBoardFrom
    /// Construction` beside it, and the walk's frames.
    @Test func theRestoreReadsTheMemoryEvenWhenTheFirstGeometryPrecedesAppear() async throws {
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
            scroll(articleA, to: 800)
            await settle(windowA, hostingA, until: { false }, maxTurns: 10)
            guard let before = topOfPage(hostingA, articleA),
                  let wasAt = fixture.blocks.firstIndex(where: { $0.variant == before.variantID })
            else {
                Issue.record("no fixture take at the top of the page after scrolling")
                return
            }
            #expect(session.editorRouter.takesArticlePlaces[fixture.postID]?.rowID != nil,
                    "non-vacuity: the memory holds a row")
            windowA.orderOut(nil)
            first.teardown()
            await settle(windowA, hostingA, until: { false }, maxTurns: 4)

            // …and back the way the app mounts a board: a BARE model — no
            // `landingEnabled` set here, nothing adopted — the view's own
            // `.task` brings the projection after the first layout.
            let bare = TakesViewModel(
                session: session, postID: fixture.postID, defaults: fixture.defaults)
            let (windowB, hostingB) = await mount(bare)
            guard let articleB = articleScrollView(in: hostingB) else {
                Issue.record("no article scroll view on the second mount")
                return
            }
            await settle(windowB, hostingB, until: { false }, maxTurns: 16)
            #expect(bare.landingEnabled, "non-vacuity: the view made this THE takes board")
            #expect(bare.board.articleRestoreAims > 0,
                    """
                    the restore RAN — on the 17q tree the first geometry \
                    preceded `.onAppear`'s `landingEnabled`, read no memory and \
                    settled the restore at once, so the app never restored a page
                    """)
            guard let after = topOfPage(hostingB, articleB),
                  let isAt = fixture.blocks.firstIndex(where: { $0.variant == after.variantID })
            else {
                Issue.record("no fixture take at the top of the page after the remount")
                return
            }
            #expect(abs(isAt - wasAt) <= 1,
                    "the page came back (block \(isAt + 1), left on block \(wasAt + 1))")
        }
    }

    /// **The memory follows the ROWS** (measured at the re-walk: every
    /// scroll-geometry report carried the row frames of the PREVIOUS step —
    /// `529E` at −15 on the 3353 report, −45 only on the 3413 one — so a
    /// memory written from the scroll hook alone is one step stale: the row
    /// that sat at `into` before the step). Pure: the hook writes the stale
    /// place, the rows' arrival re-derives the true one; nothing is
    /// re-derived while a restore is pending, and a frame that did not move
    /// re-derives nothing.
    @Test func aRowFramesArrivalReDerivesTheMemoryTheScrollHookWroteOneStepStale() {
        let board = freshBoard("stale-step")
        let a57 = { (y: CGFloat) in CGRect(x: 0, y: y, width: 680, height: 57) }
        board.noteArticleRowFrame("a", a57(0))
        board.noteArticleRowFrame("b", a57(63))
        #expect(board.consumeArticleGeometry(
            geometry(offset: 100), remembered: nil, positionedByUser: false)
                == .remember(TakesBoardLayout.ArticlePlace(rowID: "a", into: 0, rowHeight: 57)))
        // The NEXT step's scroll hook runs with the previous step's frames.
        #expect(board.consumeArticleGeometry(
            geometry(offset: 130), remembered: nil, positionedByUser: false)
                == .remember(TakesBoardLayout.ArticlePlace(rowID: "a", into: 0, rowHeight: 57)),
                "one step stale: the hook still says `a` at the fold")
        // Then the rows say where they are now.
        #expect(board.noteArticleRowFrame("a", a57(-30)))
        #expect(board.noteArticleRowFrame("b", a57(33)))
        #expect(board.articleRowFramesMoved()
                == .remember(TakesBoardLayout.ArticlePlace(rowID: "b", into: 33, rowHeight: 57)),
                "the memory follows the rows, not the hook's stale frames")
        #expect(board.noteArticleRowFrame("b", a57(33)) == false, "a frame that did not move")

        let pending = freshBoard("stale-pending")
        _ = pending.consumeArticleGeometry(
            geometry(offset: 0), remembered: TakesBoardLayout.ArticlePlace(rowID: "x"),
            positionedByUser: false, order: nil)
        pending.noteArticleRowFrame("a", a57(10))
        #expect(pending.articleRowFramesMoved() == .wait,
                "a pending restore owns the page — nothing is remembered under it")
    }

    /// …and the write reaches the SESSION through the view model's row-frame
    /// door, equality-gated.
    @Test func theSessionsMemoryFollowsTheRowsFrameReports() async throws {
        try await withSession(blocks: 3) { session, fixture, db, _ in
            let model = try await landingModel(session: session, fixture: fixture, db: db)
            let rows = model.projection.slots.map(\.placementID)
            _ = model.consumeArticleGeometry(
                TakesBoardLayout.ArticleGeometry(offset: 100, content: 3000, viewport: 700),
                positionedByUser: false)
            #expect(session.editorRouter.takesArticlePlaces[fixture.postID] == nil,
                    "non-vacuity: no frames yet, nothing remembered")
            model.noteArticleRowFrame(rows[0], CGRect(x: 0, y: -30, width: 680, height: 57))
            model.noteArticleRowFrame(rows[1], CGRect(x: 0, y: 33, width: 680, height: 57))
            #expect(session.editorRouter.takesArticlePlaces[fixture.postID]
                    == TakesBoardLayout.ArticlePlace(rowID: rows[1], into: 33, rowHeight: 57),
                    "the rows' arrival wrote the place the hook could not")
        }
    }

    /// **RED ON THE 17q TREE:** which board a model is THE takes board for is
    /// a construction-time fact. Set only in `.onAppear`, the flag was false
    /// at the first geometry report — the one that decides the restore — and
    /// the memory read behind it returned nil (the re-walk's trace).
    @Test func theTakesBoardIsTheTakesBoardFromConstruction() async throws {
        try await withSession(blocks: 1) { session, fixture, _, _ in
            let bare = TakesViewModel(
                session: session, postID: fixture.postID, defaults: fixture.defaults)
            #expect(!bare.landingEnabled, "non-vacuity: a bare model is nobody's board")
            _ = TakesBoardView(session: session, postID: fixture.postID, model: bare)
            #expect(bare.landingEnabled,
                    """
                    constructing THE takes board on it makes it so — before any \
                    appear, so the first geometry report reads the memory
                    """)
        }
    }

    // MARK: - The 17q ladder, round 2 — R2-1: the TOP stand-down in the APP's
    //         order (the harness order had it all along)

    /// **RED ON THE ROUND-1 TREE (`9c57f977`).** A page left AT REST remembers
    /// the TOP, and the TOP settles at the first geometry without ever
    /// reaching `.wanted` — so `landArticle`'s `if case .wanted` consult never
    /// weighed the entry landing that arrives AFTERWARDS (the app's order:
    /// the projection lands on the view's `.task`), and a plain round trip to
    /// a page left at rest revealed her block again. Measured in USE at the
    /// round-2 review: the long note left at rest came back as the entry
    /// frame, byte-identical (captures `39` → `40`). The harness order stood
    /// it down all along (arm `t` of `aBloomLandingRidesThroughTheRestoreIn
    /// BothOrders`), which is why no pin saw it. The condition is now "the
    /// first geometry READ a memory", whichever state the restore is in.
    ///
    /// **RE-ARMED AS THE RULED CHANGE (18l-c U8, her R-18l-13 — the U8 RECORD
    /// names old → new).** The resolver is still consulted in the app's order
    /// (the ordering contract R2-1 fixed stands, and R-Q20's moved-block arm
    /// below is byte-unchanged), but its same-block arm no longer STANDS the
    /// entry landing DOWN. OLD: `same.articleLanding == nil`. NEW: the landing
    /// lives — at a page left at rest it reveals her block (the mounted twin is
    /// `aPageLeftAtRestComesBackAtRestThenRevealsHerBlock`, re-armed with it).
    /// (Named `theTopStandDownHoldsInTheAppsOrderToo` until the U8 ladder's
    /// R1-1 rename — the stand-down is retired; the new name covers all four
    /// arms: the same-block entry, the moved-block win and the bloom each
    /// keep their landing alive at a TOP memory, and the first entry at NONE
    /// — its arm is the no-memory control (`remembered: nil`).)
    @Test func aTopMemoryInTheAppsOrderKeepsEveryLandingAlive() {
        // The app's order at a TOP memory, the SAME block: R-18l-13 — it lives.
        let same = freshBoard("top-app-same", lastCurrentRow: "was-here")
        #expect(same.consumeArticleGeometry(
            geometry(offset: 0), remembered: .top, positionedByUser: false, order: nil)
                == .remember(.top))
        #expect(same.articleRestore == .settled)
        same.landArticle(on: "was-here")
        #expect(same.articleLanding == "was-here",
                """
                R-18l-13: a mode round trip to a page left at rest keeps the entry \
                landing, which reveals her block (red on the pre-U8 tree: stood down, nil)
                """)
        #expect(same.articleRestoreAims == 0)

        // …on a DIFFERENT block: the landing wins, as it always did there.
        let moved = freshBoard("top-app-moved", lastCurrentRow: "was-here")
        _ = moved.consumeArticleGeometry(
            geometry(offset: 0), remembered: .top, positionedByUser: false, order: nil)
        moved.landArticle(on: "far")
        #expect(moved.articleLanding == "far")
        #expect(moved.articleRestore == .settled)

        // The FIRST entry (no memory at all): nothing to come back to, so the
        // landing lives — 17o row 8's everyday road (green on both sides; the
        // guard against over-correcting).
        let fresh = freshBoard("top-app-first", lastCurrentRow: "was-here")
        _ = fresh.consumeArticleGeometry(
            geometry(offset: 0), remembered: nil, positionedByUser: false, order: nil)
        fresh.landArticle(on: "was-here")
        #expect(fresh.articleLanding == "was-here", "no memory ⇒ nothing to stand down for")

        // A BLOOM at a TOP memory is never weighed (R1-2's kind guard).
        let bloom = freshBoard("top-app-bloom", lastCurrentRow: "was-here")
        _ = bloom.consumeArticleGeometry(
            geometry(offset: 0), remembered: .top, positionedByUser: false, order: nil)
        bloom.landArticle(on: "was-here", kind: .bloom)
        #expect(bloom.articleLanding == "was-here")
    }

    /// **RED ON THE ROUND-1 TREE, mounted — the app's LANDING order** (the
    /// bare-model road: the first geometry arrives before the projection,
    /// which the view's own `.task` brings — the one order this harness
    /// reproduces by construction; the `.onAppear`-vs-geometry order of W-1 is
    /// the one it cannot). A page left at rest, her ring on a block below the
    /// fold, a plain round trip.
    ///
    /// **RE-ARMED AS THE RULED CHANGE (18l-c U8, her R-18l-13 — the U8 RECORD
    /// names old → new).** OLD: the page came back AT REST with her block off
    /// it (`articleLanding == nil`, zero aims, offset < 1, her block not on
    /// screen). NEW: the page left at rest is where the board starts (the TOP
    /// restore issues no scroll), and the entry landing then REVEALS her block
    /// — the caret anchors the editing modes. RED on the pre-U8 tree: her block
    /// off the page. (Named `aPageLeftAtRestComesBackAtRestOnTheAppsOrder`
    /// until the U8 ladder's R1-1 rename — the at-rest half is still true and
    /// the name keeps it; the reveal is the half the old name denied.)
    @Test func aPageLeftAtRestComesBackAtRestThenRevealsHerBlock() async throws {
        try await withSession(blocks: 60) { session, fixture, db, mount in
            let router = session.commandRouter
            router.forgetCurrentBlock(for: fixture.postID)
            defer { router.forgetCurrentBlock(for: fixture.postID) }
            let token = router.registerDetail(postID: fixture.postID, mode: .takes) { _ in }
            defer { router.unregisterDetail(token) }
            let hers = fixture.blocks[40]
            router.noteFocusedBlock(
                hers.block, variantID: hers.variant, postID: fixture.postID, utf16Offset: 0)
            // What the previous showing left behind: the page at rest, the
            // ring on block 41 (the session's two values, as the board's own
            // ring door and geometry hook write them).
            let projection = try await db.read {
                try Queries.takesProjection($0, post: fixture.postID)
            }
            guard let hersRow = projection.slots.first(where: { $0.blockID == hers.block })?
                    .placementID else {
                Issue.record("her block has no slot")
                return
            }
            session.editorRouter.takesArticlePlaces[fixture.postID] = .top
            session.editorRouter.takesArticleCurrentRows[fixture.postID] = hersRow

            let bare = TakesViewModel(
                session: session, postID: fixture.postID, defaults: fixture.defaults)
            let (window, hosting) = await mount(bare)
            guard let article = articleScrollView(in: hosting) else {
                Issue.record("no article scroll view")
                return
            }
            await settle(window, hosting, until: { false }, maxTurns: 16)
            let revealedBy = Date().addingTimeInterval(4)
            while !isOnScreen(hers.variant, hosting, article), Date() < revealedBy {
                await settle(window, hosting, until: { false }, maxTurns: 2)
            }
            #expect(bare.authority.livePane?.blockID == hers.block,
                    "non-vacuity: the entry ring is on her block")
            #expect(bare.board.articleRestoreAims == 0,
                    "the TOP memory issued no restore scroll (unchanged)")
            #expect(bare.articleLandingAims > 0,
                    "R-18l-13: the entry landing lived and aimed (red on the pre-U8 tree: stood down, 0 aims)")
            #expect(isOnScreen(hers.variant, hosting, article),
                    "R-18l-13: her block is REVEALED (red on the pre-U8 tree: left off the page at rest)")
        }
    }

    // MARK: - The 17q ladder, round 2 — R2-2: the memory follows the rows
    //         when the remembered row LEAVES (W-2's departure half)

    /// **RED ON THE ROUND-1 TREE (`9c57f977`), the view-model road.** W-2 made
    /// a row's ARRIVAL re-derive the memory; a row's DEPARTURE did not, and
    /// `articlePlaceNow` takes the lowest fitting frame — so a de-realized
    /// row's last frame (held until `forgetArticleRowFrame`) masked every
    /// other row's re-derivation while present and was then forgotten without
    /// one: the memory stayed one fling stale (measured on her 262-block note
    /// at the round-2 review: a fling from the entry frame to the top, ⌘1,
    /// ⌘2 → back at the entry frame, captures `35` → `36`). Here: the hook
    /// writes the pre-step answer; the other rows report; the remembered row
    /// leaves without a last report — the memory must follow the rows that
    /// remain. The write is DEFERRED to the end of the turn (see the teardown
    /// pin beside this one), so the assertion waits one.
    @Test func theMemoryFollowsTheRowsWhenTheRememberedRowLeaves() async throws {
        try await withSession(blocks: 3) { session, fixture, db, _ in
            let model = try await landingModel(session: session, fixture: fixture, db: db)
            let rows = model.projection.slots.map(\.placementID)
            let r = { (y: CGFloat) in CGRect(x: 0, y: y, width: 680, height: 50) }
            // The frames BEFORE a step: a at 18 (fits), b at 74, c at 130.
            model.noteArticleRowFrame(rows[0], r(18))
            model.noteArticleRowFrame(rows[1], r(74))
            model.noteArticleRowFrame(rows[2], r(130))
            _ = model.consumeArticleGeometry(
                TakesBoardLayout.ArticleGeometry(offset: 100, content: 3000, viewport: 700),
                positionedByUser: false)
            #expect(session.editorRouter.takesArticlePlaces[fixture.postID]
                    == TakesBoardLayout.ArticlePlace(rowID: rows[0], into: 18, rowHeight: 50),
                    "non-vacuity: the hook wrote the pre-step answer")
            // The step moved the page 100 pt: b and c report; a LEAVES without
            // a last report (SwiftUI de-realizes without one).
            model.noteArticleRowFrame(rows[1], r(-26))
            model.noteArticleRowFrame(rows[2], r(30))
            #expect(session.editorRouter.takesArticlePlaces[fixture.postID]?.rowID == rows[0],
                    "non-vacuity: the stale row masks the arrivals while it is present")
            model.forgetArticleRowFrame(rows[0])
            #expect(model.board.articleRowDepartures == 1, "non-vacuity: the departure happened")
            try await Task.sleep(for: .milliseconds(40))
            await Task.yield()
            #expect(session.editorRouter.takesArticlePlaces[fixture.postID]
                    == TakesBoardLayout.ArticlePlace(rowID: rows[2], into: 30, rowHeight: 50),
                    """
                    the memory follows the rows that remain when the remembered \
                    row leaves — on the round-1 tree it stayed at the stale row
                    """)
        }
    }

    /// **THE GUARD the departure half must carry** (the implementer's round-2
    /// rider, measured RED against a departure that writes at once): a board's
    /// UNMOUNT runs every row's `onDisappear` in one transaction, so a write
    /// per departure would re-derive the memory from a shrinking set of
    /// frames and let the last row to leave decide what she comes back to.
    /// The departure re-derivation is therefore deferred and coalesced to
    /// the end of the turn, when a teardown has left no rows to derive from —
    /// and `teardown()` closes the door regardless. Green on the round-1 tree
    /// (no departure wrote) and on the fix; red on the naive fix — the
    /// number is in the round-2 record.
    @Test func tearingTheBoardDownLeavesTheMemoryWhereTheLastGeometryPutIt() async throws {
        try await withSession(blocks: 60) { session, fixture, db, mount in
            let router = session.commandRouter
            router.forgetCurrentBlock(for: fixture.postID)
            defer { router.forgetCurrentBlock(for: fixture.postID) }

            let first = try await landingModel(session: session, fixture: fixture, db: db)
            let (window, hosting) = await mount(first)
            guard let article = articleScrollView(in: hosting) else {
                Issue.record("no article scroll view")
                return
            }
            scroll(article, to: 800)
            await settle(window, hosting, until: { false }, maxTurns: 10)
            guard let left = session.editorRouter.takesArticlePlaces[fixture.postID],
                  left.rowID != nil else {
                Issue.record("no row remembered after the scroll")
                return
            }
            let departuresBefore = first.board.articleRowDepartures

            // The mode round trip's first half, the way the app does it: the
            // board's subtree leaves the window (every row's `onDisappear`),
            // and the view's own `onDisappear` tears the model down.
            window.contentView = NSView()
            first.teardown()
            await settle(window, hosting, until: { false }, maxTurns: 6)
            try await Task.sleep(for: .milliseconds(40))
            await Task.yield()

            #expect(first.board.articleRowDepartures > departuresBefore,
                    "non-vacuity: the unmount ran the rows' departures (\(first.board.articleRowDepartures - departuresBefore))")
            #expect(session.editorRouter.takesArticlePlaces[fixture.postID] == left,
                    """
                    the memory is where the last settled geometry put it — a \
                    teardown's departures must not rewrite it from a shrinking \
                    set of rows (was \(String(describing: left)), now \
                    \(String(describing: session.editorRouter.takesArticlePlaces[fixture.postID])))
                    """)
        }
    }

    // MARK: - The 17q ladder, round 3 — R3-1: the settle is NOT FINAL. SwiftUI
    //         re-resolves the scroll target after the restore has stopped
    //         aiming, to `into · (1 − rowHeight/viewport)`; the memory then
    //         follows the drift. Invisible on 46-pt rows (a 2-pt shortfall),
    //         a third of `into` on a row a third of the page, the fold on a
    //         row nearly a page tall.

    /// A long block: `lines` wrapped lines in ONE block, so a row can be a
    /// third of the page (7 lines ≈ 296 pt at the harness's width) or nearly
    /// all of it (13 lines ≈ 542 pt).
    nonisolated private static func longProse(lines: Int) -> String {
        (1...lines).map {
            "Line \($0) of the long block. Honest prose on the measured line, long enough "
                + "to wrap once at the article's measure so the rows have real height."
        }.joined(separator: "\n")
    }

    /// The ROW's top below the fold for a variant's pane: the pane sits a
    /// fixed inset below its row's top, read off the page at rest (row 1
    /// sits at the column's 18-pt padding — `articlePlaceNow` says where).
    private func rowTopBelowTheFold(
        _ variantID: String, _ hosting: NSView, _ article: NSScrollView, inset: CGFloat
    ) -> CGFloat? {
        distanceBelowTheFold(variantID, hosting, article).map { $0 - inset }
    }

    /// **RED ON THE ROUND-2 TREE (`44f427de`), mounted — measured at the round-3
    /// review: 11 where 20 is owed.** A 7-line block (≈296 pt under a 638-pt
    /// viewport) is the first fitting row below the fold, 20 pt into the
    /// page; the board remembers it so; the return settles the row at 20 and
    /// then — after the lazy column's next measurement pass — SwiftUI
    /// re-resolves the scroll target to `20 · (1 − 296/638)` ≈ 11 with the
    /// restore no longer aiming, and the arrivals rewrite the memory to 11.
    /// Since R3-1 the restore HOLDS the place: it keeps re-aiming until her
    /// hand or a landing's own scroll, so the row stays at 20 and the memory
    /// is untouched.
    @Test func aLongRowAtTheFoldComesBackWhereItSatNotAFractionOfIt() async throws {
        try await withSession(
            blocks: 12, windowHeight: 719,
            text: { $0 == 6 ? Self.longProse(lines: 7) : Self.proseText($0) }
        ) { session, fixture, db, mount in
            let router = session.commandRouter
            router.forgetCurrentBlock(for: fixture.postID)
            defer { router.forgetCurrentBlock(for: fixture.postID) }
            let hers = fixture.blocks[5]

            let first = try await landingModel(session: session, fixture: fixture, db: db)
            let (windowA, hostingA) = await mount(first)
            guard let articleA = articleScrollView(in: hostingA) else {
                Issue.record("no article scroll view on the first mount")
                return
            }
            await settle(windowA, hostingA, until: { false }, maxTurns: 6)
            guard let atRest = first.board.articlePlaceNow,
                  let pane1 = distanceBelowTheFold(fixture.blocks[0].variant, hostingA, articleA),
                  let pane6 = distanceBelowTheFold(hers.variant, hostingA, articleA) else {
                Issue.record("the page at rest is not realized")
                return
            }
            let inset = pane1 - atRest.into
            let rowTop6 = pane6 - inset
            // Her scroll leaves the long row's top 20 pt below the fold — the
            // first fitting row, remembered with its `into` by the board.
            scroll(articleA, to: rowTop6 - 20)
            await settle(windowA, hostingA, until: { false }, maxTurns: 10)
            let row6 = first.projection.slots[5].placementID
            guard let left = session.editorRouter.takesArticlePlaces[fixture.postID],
                  left.rowID == row6, abs(left.into - 20) <= 2, left.rowHeight > 200 else {
                let remembered = String(describing: session.editorRouter.takesArticlePlaces[fixture.postID])
                Issue.record(
                    "non-vacuity: the board did not remember the long row 20 pt below the fold (\(remembered), viewport \(first.board.articleViewportHeight))")
                return
            }
            windowA.orderOut(nil)
            first.teardown()
            await settle(windowA, hostingA, until: { false }, maxTurns: 4)

            let second = try await landingModel(session: session, fixture: fixture, db: db)
            let (windowB, hostingB) = await mount(second)
            guard let articleB = articleScrollView(in: hostingB) else {
                Issue.record("no article scroll view on the second mount")
                return
            }
            // The yielding turns are where the view's own tasks run and the
            // column measures — the relayout that re-resolves the target.
            await settle(windowB, hostingB, until: { false }, maxTurns: 20)
            #expect(second.board.articleRestoreAims > 0, "the restore ran")
            guard let back = rowTopBelowTheFold(hers.variant, hostingB, articleB, inset: inset) else {
                Issue.record("the long row is not realized after the remount")
                return
            }
            #expect(abs(back - left.into) <= 2,
                    """
                    the long row's top is back where it sat (\(back) for \(left.into); row \
                    \(left.rowHeight) pt, viewport \(second.board.articleViewportHeight)) — on \
                    the round-2 tree it came back at `into · (1 − h/V)` ≈ 11 after the settle
                    """)
            let now = session.editorRouter.takesArticlePlaces[fixture.postID]
            #expect(now?.rowID == row6 && abs((now?.into ?? -99) - left.into) <= 2,
                    "the memory is not rewritten to the drift (\(String(describing: now)))")
        }
    }

    /// **RED ON THE ROUND-2 TREE (`44f427de`), mounted — measured at the round-3
    /// review: 0 where −15 is owed.** R2-3's own shape at the magnitude the
    /// rule produces: a 13-line block (≈542 pt) under a viewport six points
    /// taller, straddling the fold by 15 with nothing below it fitting — the
    /// board remembers `(row, −15)`; the return puts the row's top at −15
    /// (the proxy honours the negative anchor), and the next relayout
    /// re-resolves it to the FOLD, the memory following. With the hold the
    /// row stays where it sat.
    @Test func aTallStraddlerComesBackAboveTheFoldAndStaysThere() async throws {
        try await withSession(
            blocks: 12, windowHeight: 629,
            text: { $0 == 6 ? Self.longProse(lines: 13) : Self.proseText($0) }
        ) { session, fixture, db, mount in
            let router = session.commandRouter
            router.forgetCurrentBlock(for: fixture.postID)
            defer { router.forgetCurrentBlock(for: fixture.postID) }
            let hers = fixture.blocks[5]

            let first = try await landingModel(session: session, fixture: fixture, db: db)
            let (windowA, hostingA) = await mount(first)
            guard let articleA = articleScrollView(in: hostingA) else {
                Issue.record("no article scroll view on the first mount")
                return
            }
            await settle(windowA, hostingA, until: { false }, maxTurns: 6)
            guard let atRest = first.board.articlePlaceNow,
                  let pane1 = distanceBelowTheFold(fixture.blocks[0].variant, hostingA, articleA),
                  let pane6 = distanceBelowTheFold(hers.variant, hostingA, articleA) else {
                Issue.record("the page at rest is not realized")
                return
            }
            let inset = pane1 - atRest.into
            let rowTop6 = pane6 - inset
            // Her scroll leaves the tall row straddling the fold by 15: no row
            // below it fits, so the board remembers the straddler itself with
            // its negative `into` (R2-3's branch).
            scroll(articleA, to: rowTop6 + 15)
            await settle(windowA, hostingA, until: { false }, maxTurns: 10)
            let row6 = first.projection.slots[5].placementID
            guard let left = session.editorRouter.takesArticlePlaces[fixture.postID],
                  left.rowID == row6, abs(left.into + 15) <= 2 else {
                let remembered = String(describing: session.editorRouter.takesArticlePlaces[fixture.postID])
                Issue.record(
                    "non-vacuity: the board did not remember the straddler at −15 (\(remembered), viewport \(first.board.articleViewportHeight))")
                return
            }
            windowA.orderOut(nil)
            first.teardown()
            await settle(windowA, hostingA, until: { false }, maxTurns: 4)

            let second = try await landingModel(session: session, fixture: fixture, db: db)
            let (windowB, hostingB) = await mount(second)
            guard let articleB = articleScrollView(in: hostingB) else {
                Issue.record("no article scroll view on the second mount")
                return
            }
            await settle(windowB, hostingB, until: { false }, maxTurns: 20)
            #expect(second.board.articleRestoreAims > 0, "the restore ran")
            guard let back = rowTopBelowTheFold(hers.variant, hostingB, articleB, inset: inset) else {
                Issue.record("the tall row is not realized after the remount")
                return
            }
            #expect(abs(back - left.into) <= 2,
                    """
                    the straddler's top is back ABOVE the fold where it sat (\(back) for \
                    \(left.into); row \(left.rowHeight) pt, viewport \
                    \(second.board.articleViewportHeight)) — on the round-2 tree it settled at −15 \
                    and the next relayout put it AT the fold
                    """)
            let now = session.editorRouter.takesArticlePlaces[fixture.postID]
            #expect(now?.rowID == row6 && abs((now?.into ?? -99) - left.into) <= 2,
                    "the memory is not rewritten to the fold (\(String(describing: now)))")
        }
    }

    /// `.settled` or `.holding` — the row said so (R3-1: a hold IS settled,
    /// it just keeps watching).
    private func restIsReached(_ restore: TakesBoardLayout.ArticleRestore) -> Bool {
        switch restore {
        case .settled, .holding: return true
        case .undecided, .wanted: return false
        }
    }

    /// **VX-337 — what a PLAIN round trip's restore is allowed to be once
    /// the page is back**: `.settled`/`.holding` (a geometry report followed
    /// the row's arrival), OR still `.wanted` on HER row — the arrival came
    /// BETWEEN geometry reports (every geometry report carries the rows'
    /// previous frames, the 17q ladder's W-2), and with no landing waiting
    /// the restore keeps its own geometry cadence by design (18l-b U2's
    /// `restoreLooksAgainForAWaitingLanding` re-looks only for a waiting
    /// landing; `TakesArticleWatchTests.aRestoreWithNoLandingWaitingIsLeftToItsOwnCadence`
    /// pins that). Which of the two a mounted run lands in is SwiftUI's pass
    /// ordering — load moves it — so `restIsReached` alone was a
    /// load-dependent assertion of a state the design never promises. A
    /// pin using this asserts the page's own position beside it.
    private func restArrived(
        _ restore: TakesBoardLayout.ArticleRestore, on rowID: String
    ) -> Bool {
        switch restore {
        case .settled, .holding: return true
        case .wanted(let place): return place.rowID == rowID
        case .undecided: return false
        }
    }

    /// **VX-337's mechanism, deterministic (pure board — no window, no
    /// load):** the straddling-fold pin's exact shape — her row remembered
    /// 30 pt ABOVE the fold, a plain round trip, the restore's aim moving
    /// the page and its geometry report carrying the row's PREVIOUS frame,
    /// then the row reporting itself where it sat with no geometry report
    /// after it. The restore stays `.wanted` with the row at its place — the
    /// design's own state (no landing waits on it). RED ON THE OLD ASSERTION:
    /// `restIsReached` rejects that legal state, which is the whole-target
    /// run's failure ("restIsReached … → false" while the page assertion
    /// beside it held); `restArrived` accepts it and still rejects the
    /// shapes that are wrong.
    @Test func aPlainRoundTripsRestoreArrivingBetweenReportsIsArrivedNotLost() {
        let place = TakesBoardLayout.ArticlePlace(rowID: "r", into: -30, rowHeight: 46)
        let order = ["q", "r", "s"]
        let board = freshBoard("vx337-arrival")
        #expect(board.consumeArticleGeometry(
            geometry(offset: 0), remembered: place, positionedByUser: false, order: order)
                == .scrollToRow("r", anchorY: TakesBoardLayout.ArticlePlace.anchorY(
                    into: -30, rowHeight: 46, viewport: 700)),
                "the restore aims at her row")
        // The aim's own geometry report reads the row's PREVIOUS frame: off
        // its place, so it re-aims (absolute — no offset change follows).
        board.noteArticleRowFrame("r", CGRect(x: 0, y: 300, width: 680, height: 46))
        #expect(board.consumeArticleGeometry(
            geometry(offset: 800), remembered: place, positionedByUser: false, order: order)
                == .scrollToRow("r", anchorY: TakesBoardLayout.ArticlePlace.anchorY(
                    into: -30, rowHeight: 46, viewport: 700)))
        // SwiftUI's re-resolution: the row where it sat, reported by the ROW;
        // no geometry report follows.
        #expect(board.noteArticleRowFrame("r", CGRect(x: 0, y: -30, width: 680, height: 46)))
        #expect(board.articleRowFramesMoved() == .wait, "nothing is remembered under a pending restore")
        #expect(board.articleRestore == .wanted(place),
                "a plain round trip keeps its geometry cadence — the design's own state, the page right")
        #expect(!restIsReached(board.articleRestore),
                "the OLD assertion rejects this legal state — the whole-target run's red")
        #expect(restArrived(board.articleRestore, on: "r"), "the corrected assertion accepts it")
        // …and still rejects what IS wrong.
        #expect(!restArrived(.undecided, on: "r"), "no geometry report ever arrived")
        #expect(!restArrived(.wanted(TakesBoardLayout.ArticlePlace(
            rowID: "elsewhere", into: 0, rowHeight: 46)), on: "r"), "a restore wanting another row")
    }

    /// **THE HOLD, pure** (the 17q ladder's round 3, R3-1 — the compile-red
    /// class: `.holding` does not exist on the round-2 tree). The row's report
    /// at `into` settles the restore INTO A HOLD; under it nothing is
    /// remembered and a landing may be spent; a drift (SwiftUI's
    /// re-resolution after the settle, measured `into · (1 − h/V)`) is
    /// re-aimed with the same absolute anchor — on the round-2 tree that
    /// report REMEMBERED the drift; the hold ends at her hand (first, and
    /// remembering), at the her-hand funnel (`clearArticleLanding`, writing
    /// nothing), at a landing's own scroll (writing nothing), or at the
    /// budget (remembering the page as it shows — the drift decays across
    /// trips); an outranking entry landing ends it too, a stand-down keeps it.
    @Test func theRestoreHoldsThePlaceUntilHerHandOrALanding() {
        let place = TakesBoardLayout.ArticlePlace(rowID: "b", into: 36, rowHeight: 300)
        let anchor = TakesBoardLayout.ArticlePlace.anchorY(into: 36, rowHeight: 300, viewport: 700)
        let sat = CGRect(x: 0, y: 36, width: 680, height: 300)
        let drifted = CGRect(x: 0, y: 21, width: 680, height: 300)   // 36 · (1 − 300/700) ≈ 15 short

        // (a) The settle is a hold; nothing is remembered under it; a drift
        // re-aims; the row back in place waits without reading the order.
        let a = freshBoard("hold")
        #expect(a.consumeArticleGeometry(
            geometry(offset: 0), remembered: place, positionedByUser: false,
            order: ["a", "b", "c"]) == .scrollToRow("b", anchorY: anchor))
        a.noteArticleRowFrame("b", sat)
        #expect(a.consumeArticleGeometry(
            geometry(offset: 100), remembered: place, positionedByUser: false,
            order: ["a", "b", "c"]) == .wait)
        #expect(a.articleRestore == .holding(place), "settled INTO A HOLD, not to rest")
        #expect(a.articleReadyForLanding, "a landing may be spent during a hold (the bloom door)")
        a.noteArticleRowFrame("b", drifted)
        #expect(a.articleRowFramesMoved() == .wait,
                "nothing is remembered under a hold — the deferred departure writes nothing either")
        let aimsBefore = a.articleRestoreAims
        #expect(a.consumeArticleGeometry(
            geometry(offset: 115), remembered: place, positionedByUser: false,
            order: ["a", "b", "c"]) == .scrollToRow("b", anchorY: anchor),
                "the hold re-aims the same absolute anchor — the round-2 tree REMEMBERED the drift here")
        #expect(a.articleRestoreAims == aimsBefore + 1)
        a.noteArticleRowFrame("b", sat)
        #expect(a.consumeArticleGeometry(
            geometry(offset: 100), remembered: place, positionedByUser: false, order: nil) == .wait,
                "back in place: the hold waits (and never reads the slot order — P1)")
        #expect(a.articleRestore == .holding(place))
        // Her hand ends it FIRST — and remembers.
        a.noteArticleRowFrame("b", drifted)
        #expect(a.consumeArticleGeometry(
            geometry(offset: 400), remembered: place, positionedByUser: true,
            order: ["a", "b", "c"]) == .remember(TakesBoardLayout.ArticlePlace(rowID: "b", into: 21, rowHeight: 300)),
                "her hand outranks the hold before the row is even tested")
        #expect(a.articleRestore == .settled)

        // (b) The her-hand funnel ends it, writing nothing; the next report
        // remembers through the one road.
        let b = freshBoard("hold-funnel")
        _ = b.consumeArticleGeometry(
            geometry(offset: 0), remembered: place, positionedByUser: false, order: ["a", "b"])
        b.noteArticleRowFrame("b", sat)
        _ = b.consumeArticleGeometry(
            geometry(offset: 100), remembered: place, positionedByUser: false, order: ["a", "b"])
        #expect(b.articleRestore == .holding(place))
        b.clearArticleLanding()
        #expect(b.articleRestore == .settled, "a keystroke, a click, a structural act: the hold is over")
        b.noteArticleRowFrame("b", drifted)
        #expect(b.consumeArticleGeometry(
            geometry(offset: 115), remembered: place, positionedByUser: false, order: ["a", "b"])
                == .remember(TakesBoardLayout.ArticlePlace(rowID: "b", into: 21, rowHeight: 300)))

        // (c) A landing's own scroll ends it — a BLOOM pending through the
        // restore (R1-2's road), spent the moment the hold makes it ready.
        let c = freshBoard("hold-landing", lastCurrentRow: "was-here")
        c.landArticle(on: "far", kind: .bloom)
        _ = c.consumeArticleGeometry(
            geometry(offset: 0), remembered: place, positionedByUser: false, order: ["a", "b", "far"])
        c.noteArticleRowFrame("b", sat)
        #expect(c.articleLandingStep(order: ["a", "b", "far"]) == .wait, "not ready under a pending restore")
        _ = c.consumeArticleGeometry(
            geometry(offset: 100), remembered: place, positionedByUser: false, order: ["a", "b", "far"])
        #expect(c.articleRestore == .holding(place))
        #expect(c.articleLandingStep(order: ["a", "b", "far"]) == .reveal("far", .foot),
                "the bloom's reveal is spendable during a hold")
        #expect(c.articleRestore == .settled, "…and spending it ends the hold, so the two never fight")

        // (d) The budget: a hold refills the pocket on entry and, when even
        // that runs out, ends remembering the page as it shows.
        let d = freshBoard("hold-budget")
        _ = d.consumeArticleGeometry(
            geometry(offset: 0), remembered: place, positionedByUser: false, order: ["a", "b"])
        d.noteArticleRowFrame("b", sat)
        _ = d.consumeArticleGeometry(
            geometry(offset: 100), remembered: place, positionedByUser: false, order: ["a", "b"])
        let aimsAtHold = d.articleRestoreAims
        d.noteArticleRowFrame("b", drifted)
        for _ in 0..<TakesBoardLayout.articleRestoreAttempts {
            #expect(d.consumeArticleGeometry(
                geometry(offset: 115), remembered: place, positionedByUser: false, order: ["a", "b"])
                    == .scrollToRow("b", anchorY: anchor))
        }
        #expect(d.articleRestoreAims == aimsAtHold + TakesBoardLayout.articleRestoreAttempts,
                "the hold's own full pocket, refilled on entry")
        #expect(d.consumeArticleGeometry(
            geometry(offset: 115), remembered: place, positionedByUser: false, order: ["a", "b"])
                == .remember(TakesBoardLayout.ArticlePlace(rowID: "b", into: 21, rowHeight: 300)),
                "the budget end remembers the page as it shows — the drift decays across trips")
        #expect(d.articleRestore == .settled)

        // (e) An ENTRY landing arriving during a hold (the app's order): one
        // that outranks ends it; one on the SAME block — RE-ARMED AS THE RULED
        // CHANGE (18l-c U8, her R-18l-13; the U8 RECORD names old → new) — no
        // longer stands down: OLD `e.articleLanding == nil`; NEW it LIVES and
        // the hold keeps the page until the landing's own step spends (arm (c)'s
        // road: a reveal, if the held page does not show her block, ends the hold).
        let e = freshBoard("hold-entry", lastCurrentRow: "was-here")
        _ = e.consumeArticleGeometry(
            geometry(offset: 0), remembered: place, positionedByUser: false, order: nil)
        e.noteArticleRowFrame("b", sat)
        _ = e.consumeArticleGeometry(
            geometry(offset: 100), remembered: place, positionedByUser: false, order: nil)
        #expect(e.articleRestore == .holding(place))
        e.landArticle(on: "was-here")
        #expect(e.articleLanding == "was-here" && e.articleRestore == .holding(place),
                "R-18l-13: the same-block entry lives through the hold (red on the pre-U8 tree: stood down)")
        e.landArticle(on: "far")
        #expect(e.articleLanding == "far" && e.articleRestore == .settled,
                "she moved: the landing wins and the hold is over before it can fight the reveal")
    }
}
