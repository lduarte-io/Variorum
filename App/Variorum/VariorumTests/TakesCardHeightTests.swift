//
//  TakesCardHeightTests.swift
//  VariorumTests
//
//  QoL round 2026-07-29, batch 2 (L3 · L4) — the takes styles on LONG
//  blocks. Her reports:
//
//    L3 "the takes mode is not as useful as it needs to be on long
//        blocks. on the slot split mode it's limited in height - you
//        shoudl be able to see it at full length for that mode i think.
//        maybe the height of the block should even be draggable?"
//    L4 "equally, for margin grid, even when there is a long block, the
//        margin grid note is sticky note sized which isn't that helpful
//        for long blocks"
//
//  The shipped rule was ONE fixed card height (110) for carousel, slot
//  split AND the margin rail — S4-31b/N40's "the strip never changes
//  height as takes differ or pages turn". The sitting SUPERSEDED it FOR
//  SLOT SPLIT ONLY (full length + a shorten-drag) and capped the margin
//  card at 330 (3 × the card height) instead of pinning it. Carousel and
//  the rail's short-block strip keep the ruled 110 BYTE-UNCHANGED, and
//  that parity had never been pinned by anything — this suite creates it.
//
//  Measurement discipline, adopted from batch 1 verbatim: *"a pin for a
//  feature reached by input must be driven through an input path, or it
//  is a pin on our arithmetic, not on her experience."* Every hosted pin
//  here measures what a READER can see — `visibleRect.height` against
//  `PaneMeasurement.height` — never a constant we chose.
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
@Suite("Take card heights on long blocks (QoL batch 2 — L3 · L4)", .serialized)
struct TakesCardHeightTests {

    // MARK: - Harness (the TakesRailPagingTests board-hosting pattern)

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

    /// The fan CARDS' panes only (`role: "mini"` — the article cell is
    /// `"article"`, the stack's cards are `"card"`).
    private func cardPanes(in view: NSView) -> [PaneTextView] {
        panes(in: view).filter { $0.identifier?.rawValue.hasPrefix("pane:mini|") == true }
    }

    /// Every NSScrollView between a pane and the hosting root, nearest
    /// first — how the composition's clipping is read without guessing.
    private func scrollAncestors(of view: NSView, upTo root: NSView) -> [NSScrollView] {
        var found: [NSScrollView] = []
        var current: NSView? = view.superview
        while let node = current, node != root {
            if let scroll = node as? NSScrollView { found.append(scroll) }
            current = node.superview
        }
        return found
    }

    /// A post with ONE fanned block whose takes are as long as asked.
    private struct Fixture {
        let postID: String
        let blockID: String
        let variantIDs: [String]
    }

    private func makeFixture(
        session: AppSession, style: FanStyle, takes: Int, paragraphs: Int
    ) throws -> Fixture {
        let text = (1...paragraphs).map { i in
            "Paragraph \(i). " + Array(
                repeating: "honest prose words keep flowing along the measured line and wrap",
                count: 3
            ).joined(separator: " ") + "."
        }.joined(separator: "\n\n")
        let post = try session.operations.createPost(title: "long block fixture")
        let minted = try session.operations.newBlock(in: post.id, text: text)
        var ids = [minted.variant.id]
        for n in 2...max(takes, 1) where takes > 1 {
            let take = try session.operations.branchVariant(
                minted.block.id, from: minted.variant.id)
            try session.operations.autosave(take.id, text: text + "\n\ntake \(n).", charDelta: 9)
            ids.append(take.id)
        }
        try session.operations.setFanStyle(style)
        return Fixture(postID: post.id, blockID: minted.block.id, variantIDs: ids)
    }

    /// Mount the real board on the fixture, bloom the block, and hand the
    /// body the mounted host.
    private func withBoard(
        style: FanStyle, takes: Int = 2, paragraphs: Int = 14,
        gridRows: Int = 2, gridCols: Int = 1, seed: UInt64 = 42,
        _ body: @MainActor (
            _ hosting: NSHostingView<TakesBoardView>, _ window: NSWindow,
            _ model: TakesViewModel, _ fixture: Fixture
        ) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        let defaults = UserDefaults.standard
        let savedRows = defaults.object(forKey: "takesGridRows")
        let savedCols = defaults.object(forKey: "takesGridCols")
        defaults.set(gridRows, forKey: "takesGridRows")
        defaults.set(gridCols, forKey: "takesGridCols")
        defer {
            if let savedRows { defaults.set(savedRows, forKey: "takesGridRows") }
            else { defaults.removeObject(forKey: "takesGridRows") }
            if let savedCols { defaults.set(savedCols, forKey: "takesGridCols") }
            else { defaults.removeObject(forKey: "takesGridCols") }
        }
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: seed))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let fixture = try makeFixture(
                session: session, style: style, takes: takes, paragraphs: paragraphs)
            let model = TakesViewModel(session: session, postID: fixture.postID)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: fixture.postID) })
            #expect(model.projection.fanStyle == style, "the store carries the style under test")
            defer { model.teardown() }

            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 1400, height: 900),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: TakesBoardView(
                    session: session, postID: fixture.postID, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 1400, height: 900)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { !panes(in: hosting).isEmpty })
            model.toggleExpanded(fixture.blockID)
            await settle(window, hosting, until: { !cardPanes(in: hosting).isEmpty })
            // The published heights land a turn after the first layout
            // (the accepted first-bloom settle) — give them their turns.
            await settle(window, hosting, until: { false }, maxTurns: 6)
            try await body(hosting, window, model, fixture)
        }
    }

    // MARK: - Step-1 measurement 1 (the RULING's item 7): is the rail's
    // `minHeight` floor load-bearing, or moot under uniform card heights?

    /// RECORDED MEASUREMENT, not a guard. The ruling's bar for deleting
    /// the floor is "prove STEADINESS, not just deadness" — this pin
    /// records what the floor is actually doing so the batch record states
    /// a fact instead of an inference.
    @Test func theRailFloorMeasuredAgainstItsContent() async throws {
        try await withBoard(style: .marginGrid, takes: 3, paragraphs: 14) {
            hosting, _, model, fixture in
            let cards = cardPanes(in: hosting)
            #expect(!cards.isEmpty, "the rail mounted its cards")
            guard let card = cards.first else {
                Issue.record("no rail card mounted")
                return
            }
            // Nearest-first: [in-card vertical clip, the strip's horizontal
            // scroll, the article's scroll]. The FLOOR acts on the strip —
            // the middle one — so read them all rather than guessing.
            let ancestors = scrollAncestors(of: card, upTo: hosting)
            let rows = model.railRowsPerColumn(
                slotText: model.projection.slots.first?.text)
            print("""
                MEASUREMENT-1 rail floor: cards=\(cards.count) rowsPerColumn=\(rows) \
                ancestorHeights(nearest first)=\(ancestors.map { $0.bounds.height.rounded() }) \
                cardVisibleHeights=\(cards.map { $0.visibleRect.height.rounded() })
                """)
        }
    }

    // MARK: - The card-height characterization, per style, on long text

    /// RECORDED MEASUREMENT + the batch's red-on-shipped subject: how much
    /// of a long take a reader can actually SEE in each style.
    @Test func visibleExtentOfALongTakePerStyle() async throws {
        for style in [FanStyle.carousel, .slotSplit, .marginGrid] {
            try await withBoard(style: style, takes: 2, paragraphs: 14) { hosting, _, _, _ in
                let cards = cardPanes(in: hosting)
                guard let card = cards.first else {
                    Issue.record("\(style): no card pane mounted")
                    return
                }
                let measured = PaneMeasurement.height(of: card)
                let visible = card.visibleRect.height
                let scrolls = scrollAncestors(of: card, upTo: hosting)
                print("""
                    MEASUREMENT-2 \(style): measured=\(measured.rounded()) \
                    visible=\(visible.rounded()) frame=\(card.bounds.height.rounded()) \
                    scrollAncestors=\(scrolls.count)
                    """)
            }
        }
    }
}
