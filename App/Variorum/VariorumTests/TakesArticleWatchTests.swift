//
//  TakesArticleWatchTests.swift
//  VariorumTests
//
//  **18l-b UNIT U2 — the Takes article's landing, WATCHED by the one landing
//  authority** (`Surface/LandingAuthority.swift`, policy `.takesArticle`,
//  surface `TakesArticle`). What the watch adds on this surface, and what these
//  pins hold:
//
//  - **a landing has a LIFETIME** — it is watched from its first decided step
//    and it ENDS: `settled` once its row has sat revealed through the hold and
//    a quiet interval, `gaveup` at the watchdog or when its reveal cannot
//    arrive, `handedover` at her hand. Before this unit an article landing
//    lived until her hand (a request kept alive "against the lazy column's
//    own settling passes", 17p J1) — so a gesture nobody enumerated could be
//    fought by a landing that had settled long before (the class the 17p/17q
//    ladders met three times: R1-2, R2-1, R3-1);
//  - **the content-free signpost speaks on Takes** (`landing
//    surface=TakesArticle …` in her Console), the §1.2-class diagnostic this
//    surface never had;
//  - **a quiet miss is corrected** — a reveal whose aim moved nothing gets
//    re-spent after the quiet interval (the U1 synthetic-miss class).
//
//  The harness is `TakesArticleScrollTests`' board-hosting pattern (a real
//  window, a real hosting view, the article's real `NSScrollView`), copied
//  rather than shared so that file's 40 pins stay byte-unmodified (the 3C
//  proof this unit is held to).
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
@Suite("The Takes article's landing is watched by the one authority (18l-b U2)", .serialized)
struct TakesArticleWatchTests {

    // MARK: - Harness (`TakesArticleScrollTests`' pattern)

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

    private struct Fixture: @unchecked Sendable {
        let postID: String
        let blocks: [(block: String, variant: String)]
        let defaults: UserDefaults
    }

    nonisolated private static func proseText(_ i: Int) -> String {
        "Paragraph \(i). Honest prose on the measured line, long enough to wrap "
            + "once at the article's measure so the rows have real height."
    }

    private func withSession(
        blocks: Int,
        windowHeight: CGFloat = 700,
        text: @escaping @MainActor (Int) -> String = { TakesArticleWatchTests.proseText($0) },
        _ body: @MainActor (
            _ session: AppSession, _ fixture: Fixture, _ db: AppDatabase,
            _ mount: @MainActor (TakesViewModel) async -> (NSWindow, NSHostingView<TakesBoardView>)
        ) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        let suiteName = "TakesArticleWatch-\(UUID().uuidString)"
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
            let post = try session.operations.createPost(title: "article watch fixture")
            var made: [(block: String, variant: String)] = []
            for i in 1...blocks {
                let minted = try session.operations.newBlock(in: post.id, text: text(i))
                made.append((minted.block.id, minted.variant.id))
            }
            let fixture = Fixture(postID: post.id, blocks: made, defaults: defaults)

            var windows: [NSWindow] = []
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
                await settle(window, hosting, until: { !self.articlePanes(in: hosting).isEmpty })
                await settle(window, hosting, until: { false }, maxTurns: 8)
                return (window, hosting)
            }
            try await body(session, fixture, db, mount)
        }
    }

    /// Landings enabled BEFORE the projection lands (the harness order every
    /// landing pin uses — `TakesArticleScrollTests.landingModel`).
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

    private func frameOnPage(
        _ variantID: String, _ hosting: NSView, _ article: NSScrollView
    ) -> CGRect? {
        guard let pane = articlePanes(in: hosting).first(where: {
            $0.identifier?.rawValue == "pane:article|\(variantID)"
        }) else { return nil }
        return pane.convert(pane.bounds, to: article.contentView)
    }

    private func isOnScreen(_ variantID: String, _ hosting: NSView, _ article: NSScrollView) -> Bool {
        guard let frame = frameOnPage(variantID, hosting, article) else { return false }
        let visible = article.contentView.bounds
        return frame.minY >= visible.minY - 2 && frame.maxY <= visible.maxY + 2
    }

    /// The entry fact, the way the app sets it: a detail registered and the
    /// note's current block reported (the reveal pins' road).
    private func enterOn(
        _ block: (block: String, variant: String), _ router: CommandRouter, _ postID: String
    ) -> UUID {
        router.forgetCurrentBlock(for: postID)
        let token = router.registerDetail(postID: postID, mode: .write) { _ in }
        router.noteFocusedBlock(block.block, variantID: block.variant, postID: postID, utf16Offset: 0)
        return token
    }

    // MARK: - RED ON OLD: a settled landing is OVER

    /// **RED ON THE PRE-U2 TREE** — the landing's LIFETIME. Entered on a far
    /// block, the board reveals it at the foot; nothing of hers happens after.
    /// The watch settles the landing once its row has sat revealed through the
    /// hold and a quiet interval — the request is OVER, and the page is where
    /// the reveal put it. Before this unit the request was kept "until her
    /// hand" however long ago it had settled (`articleLanding` still set seconds
    /// later), which is what let a gesture no arm enumerated be fought by a
    /// landing that had finished long before.
    @Test func aRevealedLandingIsOverOnceItHasSettledWithoutWaitingForHerHand() async throws {
        try await withSession(blocks: 12) { session, fixture, db, mount in
            let router = session.commandRouter
            let token = enterOn(fixture.blocks[11], router, fixture.postID)
            defer {
                router.unregisterDetail(token)
                router.forgetCurrentBlock(for: fixture.postID)
            }

            let model = try await landingModel(session: session, fixture: fixture, db: db)
            let (window, hosting) = await mount(model)
            guard let article = articleScrollView(in: hosting) else {
                Issue.record("no article scroll view")
                return
            }
            await settle(window, hosting, until: { false }, maxTurns: 12)
            #expect(model.articleLandingAims > 0, "non-vacuity: the landing really aimed the page")
            #expect(isOnScreen(fixture.blocks[11].variant, hosting, article),
                    "non-vacuity: the far block was revealed")
            let revealedAt = offset(article)
            #expect(revealedAt > 0, "non-vacuity: the page moved to reveal it (\(revealedAt))")

            // Nothing of hers: wait out the watch's hold and quiet interval
            // (1 s + 0.25 s from its first decided step), with slack.
            let deadline = Date().addingTimeInterval(4)
            while model.articleLanding != nil, Date() < deadline {
                await settle(window, hosting, until: { false }, maxTurns: 2)
            }
            #expect(model.articleLanding == nil,
                    """
                    the landing is OVER once it has settled — on the pre-U2 tree the \
                    request was kept until her hand (still \(String(describing: model.articleLanding)))
                    """)
            #expect(isOnScreen(fixture.blocks[11].variant, hosting, article),
                    "the block stays where the reveal put it")
            #expect(abs(offset(article) - revealedAt) < 2,
                    "the page did not move after the reveal (\(revealedAt) → \(offset(article)))")
        }
    }

    // MARK: - The U1 synthetic-miss form, on the article column

    /// **The quiet-miss class (U1's synthetic shape, on the article column).**
    /// A note whose first screen is 40 short lines and whose body is long
    /// paragraphs (the lazy column's average of what it has realized is WRONG
    /// for the rows it has not), entered on block 201 of 260 — the coldest
    /// landing, nothing below the first screen ever drawn. The block must come
    /// to rest ON SCREEN. (On note Read's edit face this shape missed entirely
    /// before U1's watch; this pin measures whether the article's own
    /// per-report re-aim already reaches it — the record says which.)
    @Test func aColdEntryIntoALongNoteOfUnevenBlocksArrivesOnScreen() async throws {
        let short = { (i: Int) in "“Yes,” said he, for the \(i)th time." }
        let sentence = "It was a long narrative sentence of the old kind, winding through "
            + "clauses and commas until the reader had nearly forgotten where it began. "
        let long = { (i: Int) in String(repeating: sentence, count: 1 + (i % 9)) }
        try await withSession(blocks: 260, text: { $0 <= 40 ? short($0) : long($0) }) {
            session, fixture, db, mount in
            let router = session.commandRouter
            let target = fixture.blocks[200]
            let token = enterOn(target, router, fixture.postID)
            defer {
                router.unregisterDetail(token)
                router.forgetCurrentBlock(for: fixture.postID)
            }

            let model = try await landingModel(session: session, fixture: fixture, db: db)
            let (window, hosting) = await mount(model)
            guard let article = articleScrollView(in: hosting) else {
                Issue.record("no article scroll view")
                return
            }
            let deadline = Date().addingTimeInterval(5)
            while !isOnScreen(target.variant, hosting, article), Date() < deadline {
                await settle(window, hosting, until: { false }, maxTurns: 2)
            }
            await settle(window, hosting, until: { false }, maxTurns: 8)
            let drawn = articlePanes(in: hosting).compactMap { pane -> Int? in
                let id = pane.identifier?.rawValue.replacingOccurrences(of: "pane:article|", with: "")
                return fixture.blocks.firstIndex { $0.variant == id }.map { $0 + 1 }
            }.sorted()
            print("[18l-b U2 synthetic] aims \(model.articleLandingAims), offset \(offset(article)), "
                  + "drawn \(drawn.first ?? -1)…\(drawn.last ?? -1), "
                  + "target frame \(String(describing: frameOnPage(target.variant, hosting, article))), "
                  + "visible \(article.contentView.bounds)")
            #expect(model.articleLandingAims > 0, "non-vacuity: the landing aimed")
            #expect(isOnScreen(target.variant, hosting, article),
                    "block 201 came to rest ON SCREEN (drawn \(drawn.first ?? -1)…\(drawn.last ?? -1))")
        }
    }

    // MARK: - The watch's story (new with the watch — DEBUG, per board)

    #if DEBUG
    private func story(_ model: TakesViewModel) -> [String] {
        model.board.article.landingStory.lines
    }

    private func doneLines(_ model: TakesViewModel) -> [String] {
        story(model).filter { $0.contains(" DONE: ") }
    }
    #endif

    /// **The landing's whole life, told once** — the entry landing on a far
    /// block is watched from its first decided step (`LAND`), and ENDS
    /// `settled` exactly once, with the Console line's shape. (The red-on-old
    /// for the lifetime is `aRevealedLandingIsOver…` above; this pins the
    /// story the watch files.)
    @Test func aSettledLandingTellsItsStoryOnceAndEndsSettled() async throws {
        #if DEBUG
        try await withSession(blocks: 12) { session, fixture, db, mount in
            let router = session.commandRouter
            let token = enterOn(fixture.blocks[11], router, fixture.postID)
            defer {
                router.unregisterDetail(token)
                router.forgetCurrentBlock(for: fixture.postID)
            }
            let model = try await landingModel(session: session, fixture: fixture, db: db)
            let (window, hosting) = await mount(model)
            let deadline = Date().addingTimeInterval(4)
            while model.articleLanding != nil, Date() < deadline {
                await settle(window, hosting, until: { false }, maxTurns: 2)
            }
            await settle(window, hosting, until: { false }, maxTurns: 10)
            let row = model.projection.slots[11].placementID
            print("[18l-b U2 story] \(story(model).joined(separator: " | "))")
            #expect(story(model).contains("\(row) LAND"), "the watch took the landing on its row")
            #expect(doneLines(model).count == 1, "ONE ending (\(doneLines(model)))")
            #expect(doneLines(model).first?.contains("DONE: settled at top=0.0") == true,
                    "settled at home — the row fully on screen (\(doneLines(model)))")
            #expect(story(model).contains { $0.hasPrefix("manifest rows=12 target=11 offset=-1") },
                    "the signpost's facts: 12 rows, the target's INDEX, no manifest offset (−1)")
        }
        #endif
    }

    #if DEBUG
    /// A landing asked for AFTER the entry landing has ended, on the note's
    /// FIRST block (above the page once the entry revealed the last one) —
    /// so the pin acts inside a watch it has just seen begin, never racing a
    /// hold that began during the mount.
    private func landFresh(
        _ model: TakesViewModel, _ window: NSWindow, _ hosting: NSView
    ) async -> String? {
        let deadline = Date().addingTimeInterval(4)
        while model.articleLanding != nil, Date() < deadline {
            await settle(window, hosting, until: { false }, maxTurns: 2)
        }
        guard model.articleLanding == nil else { return nil }
        let row = model.projection.slots[0].placementID
        model.board.landArticle(on: row)
        await settle(window, hosting, until: { self.story(model).contains("\(row) LAND") }, maxTurns: 10)
        return story(model).contains("\(row) LAND") ? row : nil
    }
    #endif

    /// **Her scroll hands a watched landing over — ONCE** (the her-hand rule
    /// the board already had — `isPositionedByUser` on the geometry road —
    /// now also ends the watch; every later her-hand frame, and every arm
    /// after it, is a no-op for the watch). The model's own road is the
    /// geometry hook's: `consumeArticleGeometry(_:positionedByUser: true)`.
    @Test func herScrollHandsTheWatchedLandingOverOnce() async throws {
        #if DEBUG
        try await withSession(blocks: 12) { session, fixture, db, mount in
            let router = session.commandRouter
            let token = enterOn(fixture.blocks[11], router, fixture.postID)
            defer {
                router.unregisterDetail(token)
                router.forgetCurrentBlock(for: fixture.postID)
            }
            let model = try await landingModel(session: session, fixture: fixture, db: db)
            let (window, hosting) = await mount(model)
            guard let row = await landFresh(model, window, hosting) else {
                Issue.record("non-vacuity: the fresh landing was never handed to the watch — \(story(model))")
                return
            }
            #expect(model.articleLanding == row, "non-vacuity: the watched landing is pending")
            let mine = { self.doneLines(model).filter { $0.hasPrefix("\(row) ") } }
            #expect(mine().isEmpty, "non-vacuity: nothing has ended it yet")

            let geometry = TakesBoardLayout.ArticleGeometry(offset: 400, content: 3000, viewport: 619)
            _ = model.consumeArticleGeometry(geometry, positionedByUser: true)
            _ = model.consumeArticleGeometry(geometry, positionedByUser: true)
            model.toggleExpanded(fixture.blocks[5].block)   // an arm, after her scroll
            await settle(window, hosting, until: { false }, maxTurns: 40)   // past any hold
            #expect(model.articleLanding == nil, "her scroll ended the landing")
            #expect(mine() == ["\(row) DONE: her scroll"],
                    "handed over ONCE, by her scroll — never re-filed (\(mine()))")
        }
        #endif
    }

    /// **The enumerated arms and the structural arm hand a watched landing
    /// over through the ONE funnel** (`clearArticleLanding`): a gesture door
    /// files `her gesture`; a content change (`noteProjectionArrived`) files
    /// `a content change` — each once.
    @Test func theArmsHandTheWatchedLandingOverThroughTheOneFunnel() async throws {
        #if DEBUG
        try await withSession(blocks: 12) { session, fixture, db, mount in
            let router = session.commandRouter
            let token = enterOn(fixture.blocks[11], router, fixture.postID)
            defer {
                router.unregisterDetail(token)
                router.forgetCurrentBlock(for: fixture.postID)
            }
            let model = try await landingModel(session: session, fixture: fixture, db: db)
            let (window, hosting) = await mount(model)
            guard let row = await landFresh(model, window, hosting) else {
                Issue.record("non-vacuity: the fresh landing was never handed to the watch — \(story(model))")
                return
            }
            let mine = { self.doneLines(model).filter { $0.hasPrefix("\(row) ") } }
            model.toggleExpanded(fixture.blocks[5].block)
            #expect(model.articleLanding == nil, "the bloom door ended it")
            #expect(mine() == ["\(row) DONE: her gesture"], "\(mine())")

            // A second landing on the same row, ended by a CONTENT change (a
            // block minted — the shape a sync arrival or an undo in another
            // window makes).
            model.board.landArticle(on: row)
            await settle(window, hosting, until: {
                self.story(model).filter { $0 == "\(row) LAND" }.count == 2
            }, maxTurns: 10)
            #expect(story(model).filter { $0 == "\(row) LAND" }.count == 2,
                    "non-vacuity: the second landing was watched")
            _ = try session.operations.newBlock(in: fixture.postID, text: "A block minted elsewhere.")
            model.adopt(try await db.read { try Queries.takesProjection($0, post: fixture.postID) })
            #expect(model.articleLanding == nil, "the structural arm ended it")
            #expect(mine() == ["\(row) DONE: her gesture", "\(row) DONE: a content change"],
                    "each landing ended once, each by its own door (\(mine()))")
            await settle(window, hosting, until: { false }, maxTurns: 10)
        }
        #endif
    }

    /// **Her R-Q21 plain round trip is never watched** — the entry landing
    /// STANDS DOWN before any step (the page she left comes back at rest),
    /// so no landing is handed to the authority and no signpost is filed:
    /// the ordering contract (the stand-down at `landArticle`, before
    /// anything moves) outranks the watch by construction. The app's order
    /// (a bare model; the projection from the view's `.task`).
    @Test func aStoodDownEntryLandingIsNeverWatched() async throws {
        #if DEBUG
        try await withSession(blocks: 60) { session, fixture, db, mount in
            let router = session.commandRouter
            let hers = fixture.blocks[40]
            router.forgetCurrentBlock(for: fixture.postID)
            let token = router.registerDetail(postID: fixture.postID, mode: .takes) { _ in }
            defer {
                router.unregisterDetail(token)
                router.forgetCurrentBlock(for: fixture.postID)
            }
            router.noteFocusedBlock(hers.block, variantID: hers.variant, postID: fixture.postID, utf16Offset: 0)
            let projection = try await db.read { try Queries.takesProjection($0, post: fixture.postID) }
            let hersRow = try #require(projection.slots.first { $0.blockID == hers.block }?.placementID)
            session.editorRouter.takesArticlePlaces[fixture.postID] = .top
            session.editorRouter.takesArticleCurrentRows[fixture.postID] = hersRow

            let bare = TakesViewModel(session: session, postID: fixture.postID, defaults: fixture.defaults)
            let (window, hosting) = await mount(bare)
            await settle(window, hosting, until: { false }, maxTurns: 30)
            #expect(bare.authority.livePane?.blockID == hers.block, "non-vacuity: the entry ring is on her block")
            #expect(bare.board.articleLanding == nil, "the entry landing stood down (her R-Q21)")
            #expect(!story(bare).contains { $0.hasSuffix(" LAND") },
                    "never handed to the watch: \(story(bare))")
        }
        #endif
    }

    // MARK: - The watch at the model level (no window): the correction and
    //         the watchdog

    private func freshScroll() -> TakesArticleScroll { TakesArticleScroll() }

    private func settleRestore(_ scroll: TakesArticleScroll) {
        _ = scroll.consumeArticleGeometry(
            TakesBoardLayout.ArticleGeometry(offset: 0, content: 3000, viewport: 700),
            remembered: nil, positionedByUser: false)
    }

    /// **A QUIET MISS IS CORRECTED** — the target never reports (the column
    /// has not built it), and no report arrives at all: after the quiet
    /// interval the watch asks for ONE correction (the view spends the step
    /// on it). A target at home asks for none.
    @Test func aQuietMissEarnsACorrectionAndAHomeTargetNone() async throws {
        let scroll = freshScroll()
        settleRestore(scroll)
        scroll.noteArticleRowFrame("a", CGRect(x: 0, y: 18, width: 680, height: 60))
        scroll.landArticle(on: "far")
        #expect(scroll.articleLandingStep(order: ["a", "far"]) == .reveal("far", .foot),
                "the first decided step aims — and hands the landing to the watch")
        #expect(scroll.articleLandingCorrections == 0)
        try await Task.sleep(for: .milliseconds(450))
        #expect(scroll.articleLandingCorrections == 1,
                "after the quiet interval, ONE correction for a target never seen (\(scroll.articleLandingCorrections))")
        #expect(scroll.articleLanding == "far", "the landing is still being watched")

        let home = freshScroll()
        settleRestore(home)
        home.noteArticleRowFrame("a", CGRect(x: 0, y: 18, width: 680, height: 60))
        home.noteArticleRowFrame("b", CGRect(x: 0, y: 84, width: 680, height: 60))
        home.landArticle(on: "b")
        #expect(home.articleLandingStep(order: ["a", "b"]) == .wait, "on screen: nothing to aim")
        try await Task.sleep(for: .milliseconds(1500))
        #expect(home.articleLandingCorrections == 0, "a target at home is never corrected")
        #expect(home.articleLanding == nil, "…and the watch settled it after the hold")
        #if DEBUG
        #expect(home.landingStory.lines.last?.hasPrefix("b DONE: settled at top=0.0 after 0 hops") == true,
                "\(home.landingStory.lines)")
        #endif
    }

    /// **THE WATCHDOG** — a watched landing whose row never comes home ends
    /// `gaveup` at the policy's time budget (the corrections spent first),
    /// rather than living until her hand.
    @Test func aLandingThatCannotArriveEndsAtTheWatchdog() async throws {
        let scroll = freshScroll()
        settleRestore(scroll)
        scroll.noteArticleRowFrame("a", CGRect(x: 0, y: 18, width: 680, height: 60))
        scroll.landArticle(on: "far")
        _ = scroll.articleLandingStep(order: ["a", "far"])
        let budget = LandingPolicy.takesArticle.timeBudget
        try await Task.sleep(for: .milliseconds(Int((budget + 0.9) * 1000)))
        #expect(scroll.articleLanding == nil, "the watchdog ended it")
        #expect(scroll.articleLandingCorrections == LandingPolicy.takesArticle.correctionBudget,
                "every correction was asked for first (\(scroll.articleLandingCorrections))")
        #if DEBUG
        #expect(scroll.landingStory.lines.last?.hasPrefix("far DONE: gave up at top=unrealized after 3 hops") == true,
                "\(scroll.landingStory.lines)")
        #endif
    }

    /// **The Takes policy and its word** — the aim kind, the tolerance that
    /// makes "home" and the reveal's `.none` one rule, the family's numbers,
    /// and the signpost stays content-free on the new surface.
    @Test func theTakesArticlePolicyAndItsSignpost() {
        let policy = LandingPolicy.takesArticle
        #expect(policy.surface == .takesArticle && LandingSurface.takesArticle.rawValue == "TakesArticle")
        #expect(policy.aim == .minimalReveal)
        #expect(policy.tolerance == 0.5, "the reveal decision's own half-point slack")
        #expect(policy.settleInterval == 0.25 && policy.minimumHold == 1.0 && policy.maxWait == 0.6)
        #expect(policy.correctionBudget == 3 && policy.timeBudget == 4)
        #expect(policy.correctionPace == .spacedByTheHold)
        #expect(policy.correctsAnUnreportedTarget && !policy.seedsFromLastReport)
        let line = LandingSignpost.line(
            surface: .takesArticle,
            facts: LandingFacts(rows: 262, targetIndex: 200, offset: -1, total: 90_000, derived: 230, exactAbove: false),
            corrections: 1, contentMoves: 4, elapsed: 1.26, outcome: .settled, top: 0)
        #expect(LandingSignpost.isContentFree(line), "\(line)")
        #expect(line == "landing surface=TakesArticle rows=262 target=200 offset=-1 total=90000 "
                + "derived=230 exact=0 hops=1 content=4 ms=1260 end=settled top=0")
    }
}
