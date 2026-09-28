//
//  TakesEntryBandTests.swift
//  VariorumTests
//
//  **18l-c UNIT U8 — the Takes article's MODE-SWITCH landing: the comfort band
//  and the arrival flash, on a real mounted board** (the
//  `TakesArticleWatchTests` harness, copied — that file's pins ride as they
//  are). What these hold:
//
//  - **(b) the band on the ENTRY landing** (her *"an offset from the top /
//    bottom of the screen so a user isn't navigating to a different mode and
//    their text is on the extreme top or bottom"*): a far block revealed from
//    a fresh board rests two lines ABOVE the viewport's foot, never at it; a
//    block above the page she left rests at the article's resting top air —
//    KnownIssues row 94's remedy, taken on this road — never flush with the
//    viewport's top; a block already inside the band does not move at all
//    (mid-band EXACT);
//  - **(a) the flash on the ENTRY landing only**: once the landing has put the
//    row home, that row's cell draws the flash (fill + border) — and a find
//    step or a bloom never flashes; with her setting OFF, nothing is drawn.
//
//  RED on the pre-U8 tree for the band arms (the shipped reveal rests a far
//  row flush at the foot and a head-revealed row flush at the top — row 94's
//  sighting) and, by construction, for the flash (no arrival existed).
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
@Suite("18l-c U8 — the Takes entry landing's comfort band and arrival flash", .serialized)
struct TakesEntryBandTests {

    // MARK: - Harness (`TakesArticleWatchTests`' pattern)

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

    /// Wait (bounded) for a predicate, turning the run loop between looks.
    private func wait(
        _ window: NSWindow, _ hosting: NSView, seconds: TimeInterval,
        until predicate: () -> Bool
    ) async {
        let deadline = Date().addingTimeInterval(seconds)
        while !predicate(), Date() < deadline {
            await settle(window, hosting, until: { false }, maxTurns: 2)
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
        flashOn: Bool = true,
        _ body: @MainActor (
            _ session: AppSession, _ fixture: Fixture, _ db: AppDatabase,
            _ mount: @MainActor (TakesViewModel) async -> (NSWindow, NSView)
        ) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        let suiteName = "TakesEntryBand-\(UUID().uuidString)"
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
            let post = try session.operations.createPost(title: "entry band fixture")
            var made: [(block: String, variant: String)] = []
            for i in 1...blocks {
                let minted = try session.operations.newBlock(in: post.id, text: Self.proseText(i))
                made.append((minted.block.id, minted.variant.id))
            }
            if !flashOn { try session.operations.setArrivalFlash(false) }
            // Her settings, as the app hands them down (the one store every
            // surface reads — a board with no store reads the defaults).
            let theme = ThemeStore(session: session)
            let observing = Task { await theme.start() }
            defer { observing.cancel() }
            let fixture = Fixture(postID: post.id, blocks: made, defaults: defaults)

            var windows: [NSWindow] = []
            defer {
                for window in windows {
                    window.orderOut(nil)
                    window.close()
                }
            }
            let mount: @MainActor (TakesViewModel) async -> (NSWindow, NSView) = { model in
                let window = NSWindow(
                    contentRect: NSRect(x: 60, y: 60, width: 1100, height: 700),
                    styleMask: [.titled], backing: .buffered, defer: false)
                window.isReleasedWhenClosed = false
                let hosting = NSHostingView(
                    rootView: TakesBoardView(session: session, postID: post.id, model: model)
                        .environment(theme))
                hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: 700)
                window.contentView = hosting
                window.makeKeyAndOrderFront(nil)
                windows.append(window)
                await self.settle(window, hosting, until: {
                    !self.articlePanes(in: hosting).isEmpty && theme.settings.arrivalFlash == flashOn
                })
                await self.settle(window, hosting, until: { false }, maxTurns: 8)
                return (window, hosting)
            }
            try await body(session, fixture, db, mount)
        }
    }

    private func landingModel(
        session: AppSession, fixture: Fixture, db: AppDatabase
    ) async throws -> TakesViewModel {
        let model = TakesViewModel(
            session: session, postID: fixture.postID, defaults: fixture.defaults)
        model.landingEnabled = true
        model.adopt(try await db.read { try Queries.takesProjection($0, post: fixture.postID) })
        return model
    }

    /// A pane's frame in the article's viewport space (0 = the viewport's top).
    private func frameInViewport(
        _ variantID: String, _ hosting: NSView, _ article: NSScrollView
    ) -> CGRect? {
        guard let pane = articlePanes(in: hosting).first(where: {
            $0.identifier?.rawValue == "pane:article|\(variantID)"
        }) else { return nil }
        let frame = pane.convert(pane.bounds, to: article.contentView)
        return frame.offsetBy(dx: 0, dy: -article.contentView.bounds.minY)
    }

    /// The entry fact, the way the app sets it (the reveal pins' road).
    private func enterOn(
        _ block: (block: String, variant: String), _ router: CommandRouter, _ postID: String
    ) -> UUID {
        router.forgetCurrentBlock(for: postID)
        let token = router.registerDetail(postID: postID, mode: .write) { _ in }
        router.noteFocusedBlock(block.block, variantID: block.variant, postID: postID, utf16Offset: 0)
        return token
    }

    /// The article cell's padding + the take pane's text inset (the cell's
    /// top sits this far above the pane's text frame).
    private var cellInset: CGFloat { TakesBoardView.articleCellPadding }

    // MARK: - (b) THE BAND — the foot

    /// **A far block, entered from a fresh board** (no memory — the page opens
    /// at the top and the entry landing reveals minimally downward): its row
    /// rests `ComfortBand.bottomLines` lines ABOVE the viewport's foot. RED on
    /// the pre-U8 tree: the shipped foot reveal rests it flush with the bottom.
    @Test func aFarEntryRestsTwoLinesAboveTheFootNeverAtTheEdge() async throws {
        try await withSession(blocks: 60) { session, fixture, db, mount in
            let router = session.commandRouter
            let target = fixture.blocks[40]
            let token = enterOn(target, router, fixture.postID)
            defer { router.unregisterDetail(token); router.forgetCurrentBlock(for: fixture.postID) }
            let model = try await landingModel(session: session, fixture: fixture, db: db)
            let (window, hosting) = await mount(model)
            let article = try #require(articleScrollView(in: hosting))
            await wait(window, hosting, seconds: 4) { model.articleLanding == nil }
            await settle(window, hosting, until: { false }, maxTurns: 6)
            let row = try #require(frameInViewport(target.variant, hosting, article),
                                   "the entry landing revealed block 41")
            let viewport = article.contentView.bounds.height
            let band = model.board.article.entryBand
            let bottom = row.maxY + cellInset   // the cell's bottom (the row's)
            print("[18l-c U8 band foot] row \(row.minY)…\(row.maxY) · viewport \(viewport) · room \(viewport - bottom) · aims \(model.articleLandingAims)")
            #expect(model.articleLandingAims > 0, "non-vacuity: the landing aimed")
            #expect(abs((viewport - bottom) - band.bottomRoom) <= 3,
                    """
                    the row rests \(band.bottomRoom) pt (two lines) above the foot — measured \
                    \(viewport - bottom) (red on the pre-U8 tree: 0, flush with the bottom)
                    """)
        }
    }

    // MARK: - (b) THE BAND — the head (KnownIssues row 94's road)

    /// **A block ABOVE the page she left**: in Takes on block 21, she scrolls
    /// DOWN until it is above the fold, leaves, comes back (a mode round trip,
    /// nothing clicked) — R-18l-13's ride-through restores her page and then
    /// reveals her block at the HEAD, which the band rests at the article's
    /// resting top air (18 pt — row 94's sketch). RED on the pre-U8 tree
    /// twice over: the stand-down left her block off the page; and the head
    /// reveal (had it run) rests the row flush with the viewport's top.
    @Test func aBlockAboveThePageSheLeftRestsAtTheTopAirNeverFlush() async throws {
        try await withSession(blocks: 60) { session, fixture, db, mount in
            let router = session.commandRouter
            let target = fixture.blocks[20]
            let token = enterOn(target, router, fixture.postID)
            defer { router.unregisterDetail(token); router.forgetCurrentBlock(for: fixture.postID) }
            // Showing 1: the entry reveals block 21; her hand, then her scroll
            // DOWN puts it well above the page.
            let first = try await landingModel(session: session, fixture: fixture, db: db)
            let (window1, hosting1) = await mount(first)
            let article1 = try #require(articleScrollView(in: hosting1))
            await wait(window1, hosting1, seconds: 4) { first.articleLanding == nil }
            first.clearArticleLanding()
            article1.contentView.scroll(to: NSPoint(x: 0, y: article1.contentView.bounds.minY + 1200))
            article1.reflectScrolledClipView(article1.contentView)
            await settle(window1, hosting1, until: { false }, maxTurns: 12)
            #expect(frameInViewport(target.variant, hosting1, article1).map { $0.maxY < 0 } ?? true,
                    "non-vacuity: her block is ABOVE the page she leaves")
            window1.contentView = nil
            first.teardown()
            window1.orderOut(nil)

            // Showing 2 — the round trip.
            let model = try await landingModel(session: session, fixture: fixture, db: db)
            let (window, hosting) = await mount(model)
            let article = try #require(articleScrollView(in: hosting))
            await wait(window, hosting, seconds: 5) {
                frameInViewport(target.variant, hosting, article).map { $0.minY >= 0 } ?? false
                    && model.articleLanding == nil
            }
            await settle(window, hosting, until: { false }, maxTurns: 6)
            let row = try #require(frameInViewport(target.variant, hosting, article),
                                   "R-18l-13: her block is revealed on the round trip")
            let top = row.minY - cellInset   // the cell's top (the row's)
            print("[18l-c U8 band head] row top \(top) · aims \(model.articleLandingAims) · restore aims \(model.board.articleRestoreAims)")
            #expect(model.board.articleRestoreAims > 0, "non-vacuity: the page she left came back first")
            #expect(abs(top - TakesArticleScroll.articleTopAir) <= 3,
                    """
                    the row rests at the article's resting top air (\(TakesArticleScroll.articleTopAir)) — \
                    measured \(top) (row 94's shape: 0, the air eaten)
                    """)
        }
    }

    // MARK: - (b) THE BAND — mid-band exact

    /// **A block already inside the band does not move** — entered on block 3
    /// of a fresh board (on the page at rest, mid-band): the page stays at
    /// rest and her row rests inside the band. (The lazy column may spend an
    /// aim on a row it has not realized at the first step — a scroll the page
    /// at its top cannot take; measured 2, moving nothing.) **NOT green on
    /// both sides — measured by R-U8-3 (the band switched off):** the shipped,
    /// unbanded reveal moved this page 130 pt on the same entry and left the
    /// row outside the band (a first step judging an unrealized / placeholder
    /// row and aiming its `.bottom` edge); the banded anchor's aim clamps at
    /// the page's top instead. Recorded in the U8 RECORD (NOTICED).
    @Test func anEntryAlreadyInsideTheBandDoesNotMove() async throws {
        try await withSession(blocks: 60) { session, fixture, db, mount in
            let router = session.commandRouter
            let token = enterOn(fixture.blocks[2], router, fixture.postID)
            defer { router.unregisterDetail(token); router.forgetCurrentBlock(for: fixture.postID) }
            let model = try await landingModel(session: session, fixture: fixture, db: db)
            let (window, hosting) = await mount(model)
            let article = try #require(articleScrollView(in: hosting))
            await wait(window, hosting, seconds: 4) { model.articleLanding == nil }
            #expect(article.contentView.bounds.minY < 1, "the page at rest, exactly — the band moved nothing")
            let row = try #require(frameInViewport(fixture.blocks[2].variant, hosting, article))
            let band = model.board.article.entryBand
            #expect(row.minY - cellInset >= band.topAir - 0.5
                        && row.maxY + cellInset <= article.contentView.bounds.height - band.bottomRoom + 0.5,
                    "her row rests inside the band (\(row.minY)…\(row.maxY))")
        }
    }

    // MARK: - (a) THE FLASH — entry only, once, and her setting

    #if DEBUG
    /// **The entry landing's arrival flashes its row** — the arrival names her
    /// row once the landing has put it home, the cell draws the flash's fill
    /// and border at full strength, and the arrival clears itself when the
    /// flash is over. Red on the pre-U8 tree by construction (no arrival).
    @Test func theEntryLandingFlashesItsRowOnceItArrives() async throws {
        try await withSession(blocks: 60) { session, fixture, db, mount in
            ArrivalFlashOracle.reset()
            let router = session.commandRouter
            let target = fixture.blocks[40]
            let token = enterOn(target, router, fixture.postID)
            defer { router.unregisterDetail(token); router.forgetCurrentBlock(for: fixture.postID) }
            let model = try await landingModel(session: session, fixture: fixture, db: db)
            let row = try #require(model.projection.slots.first { $0.blockID == target.block }?.placementID)
            let (window, hosting) = await mount(model)
            await wait(window, hosting, seconds: 3) { model.board.article.articleArrival != nil }
            #expect(model.board.article.articleArrival?.placementID == row,
                    "the arrival names her row")
            await settle(window, hosting, until: { false }, maxTurns: 6)
            let key = "takes|\(ObjectIdentifier(model.board.article))|\(row)"
            let seen = ArrivalFlashOracle.seen[key]
            #expect((seen?.peakFill ?? 0) > 0.9 && (seen?.peakStroke ?? 0) > 0.9,
                    "the cell drew the flash — fill and border — at full strength: \(String(describing: seen))")
            // (Keyed by THIS board — a dropped board of an earlier test can
            // outlive it in the runner's autorelease pool, TEXTKIT2 §3's C8 note.)
            let mine = ArrivalFlashOracle.seen.keys.filter {
                $0.hasPrefix("takes|\(ObjectIdentifier(model.board.article))|")
            }
            #expect(mine == [key], "…on her row alone: \(mine.sorted())")
            await wait(window, hosting, seconds: 3) { model.board.article.articleArrival == nil }
            #expect(model.board.article.articleArrival == nil, "the flash is over and gone")
        }
    }

    /// **Her setting OFF draws nothing** (R-18l-7: *"you should also be able to
    /// turn this flash … setting off"*). The arrival still happens (a fact of
    /// the landing); the face is never mounted.
    @Test func withTheSettingOffTheArrivalDrawsNoFlash() async throws {
        try await withSession(blocks: 60, flashOn: false) { session, fixture, db, mount in
            ArrivalFlashOracle.reset()
            let router = session.commandRouter
            let target = fixture.blocks[40]
            let token = enterOn(target, router, fixture.postID)
            defer { router.unregisterDetail(token); router.forgetCurrentBlock(for: fixture.postID) }
            let model = try await landingModel(session: session, fixture: fixture, db: db)
            let (window, hosting) = await mount(model)
            await wait(window, hosting, seconds: 3) { model.board.article.articleArrival != nil }
            #expect(model.board.article.articleArrival != nil, "non-vacuity: the entry arrived")
            await settle(window, hosting, until: { false }, maxTurns: 6)
            let mine = ArrivalFlashOracle.seen.keys.filter {
                $0.hasPrefix("takes|\(ObjectIdentifier(model.board.article))|")
            }
            #expect(mine.isEmpty, "the setting OFF: no flash face was drawn on this board (\(mine))")
        }
    }

    /// **A bloom and a find step never flash** — they are her in-mode acts
    /// (U7's decision 9: find-nav is in-mode navigation); only the mode
    /// switch's ENTRY landing does. Green on both sides by construction: the
    /// guard that the flash never leaks onto the other landing kinds.
    @Test func aBloomOrAFindStepNeverFlashes() async throws {
        try await withSession(blocks: 60) { session, fixture, db, mount in
            ArrivalFlashOracle.reset()
            let router = session.commandRouter
            router.forgetCurrentBlock(for: fixture.postID)
            let token = router.registerDetail(postID: fixture.postID, mode: .takes) { _ in }
            defer { router.unregisterDetail(token); router.forgetCurrentBlock(for: fixture.postID) }
            // The fan panel's "Open Takes mode" on block 41 — a BLOOM landing.
            router.pendingTakesLanding = .bloom(postID: fixture.postID, blockID: fixture.blocks[40].block)
            let model = try await landingModel(session: session, fixture: fixture, db: db)
            let (window, hosting) = await mount(model)
            await wait(window, hosting, seconds: 4) { model.articleLanding == nil }
            #expect(model.articleLandingAims > 0, "non-vacuity: the bloom landed")
            // …then a find step to a far block.
            model.find.open()
            model.find.setQuery("Paragraph 55.")
            model.find.next()
            await wait(window, hosting, seconds: 4) { model.articleLanding == nil }
            #expect(model.board.article.articleArrival == nil, "no arrival for a bloom or a find")
            let mine = ArrivalFlashOracle.seen.keys.filter {
                $0.hasPrefix("takes|\(ObjectIdentifier(model.board.article))|")
            }
            #expect(mine.isEmpty, "no flash drawn on this board: \(mine.sorted())")
            model.find.close()
        }
    }
    #endif
}
