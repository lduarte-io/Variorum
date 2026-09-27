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
}
