//
//  TakesRailPagingTests.swift
//  VariorumTests
//
//  Phase 13b, Stage 1a — the AD-2 pin (the app-drive's fan-truncation
//  finding): a margin-grid block saying "takes · 4" rendered exactly TWO
//  cards — the rail's card row was a horizontal ScrollView that realized
//  EVERY card and silently clipped all past the rail's width (gridCols ×
//  220pt): no pager, no scrollbar, no affordance; half the fan
//  unreachable from the flagship takes surface. The fix is the board's
//  own discrete-paging grammar (the carousel's): only the visible page's
//  cards render, and an explicit ◀ x–y of n ▶ door walks the rest.
//
//  RED on the pre-fix code: the rendered-card count exceeds the page
//  capacity (4 cards where 2 fit — the clipped-unreachable shape).
//  Verified by behavioral revert of the rail's view half.
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
@Suite("Margin-rail paging (AD-2, 13b 1a)", .serialized)
struct TakesRailPagingTests {
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

    private func cardVariantIDs(in view: NSView) -> [String] {
        panes(in: view).compactMap { pane in
            guard let raw = pane.identifier?.rawValue,
                  raw.hasPrefix("pane:mini|") else { return nil }
            return String(raw.dropFirst("pane:mini|".count))
        }
    }

    @Test func everyTakeOfAFourTakeFanIsACardOnSomeExplicitPage() async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        // The board reads its density from standard defaults (@AppStorage):
        // pin AD-2's exact configuration and restore after.
        let defaults = UserDefaults.standard
        let savedRows = defaults.object(forKey: "takesGridRows")
        let savedCols = defaults.object(forKey: "takesGridCols")
        defaults.set(2, forKey: "takesGridRows")
        defaults.set(1, forKey: "takesGridCols")
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            // AD-2's shape: one block, FOUR takes — long text so the rail
            // keeps the grid (not the R24 strip).
            let longText = String(repeating: "prose that outgrows the strip rule. ", count: 8)
            let (postID, blockID, fanIDs): (String, String, [String]) = try {
                let post = try session.operations.createPost(title: "the night we decided")
                let minted = try session.operations.newBlock(in: post.id, text: longText)
                var ids = [minted.variant.id]
                for n in 2...4 {
                    let take = try session.operations.branchVariant(
                        minted.block.id, from: minted.variant.id)
                    try session.operations.autosave(
                        take.id, text: longText + "take \(n).", charDelta: 8)
                    ids.append(take.id)
                }
                // The STORE carries the style (the board's own observation
                // adopts from the store on mount — a hand-built projection
                // would be overwritten).
                try session.operations.setFanStyle(.marginGrid)
                return (post.id, minted.block.id, ids)
            }()

            let model = TakesViewModel(session: session, postID: postID)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: postID) })
            #expect(model.projection.fanStyle == .marginGrid)
            defer { model.teardown() }

            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1200, height: 800),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: TakesBoardView(session: session, postID: postID, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 800)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { !panes(in: hosting).isEmpty })

            model.toggleExpanded(blockID)
            await settle(window, hosting, until: { !cardVariantIDs(in: hosting).isEmpty })

            // THE AD-2 RED: 2 high × 1 wide fits TWO cards — the pre-fix
            // rail rendered all FOUR (two of them clipped past the rail's
            // width, unreachable); the paged rail renders exactly the
            // visible page.
            let firstPage = cardVariantIDs(in: hosting)
            #expect(firstPage.count == 2,
                    "the rail renders exactly the visible page, never clipped extras (rendered \(firstPage.count))")

            // The explicit door covers the WHOLE fan: walk the pages and
            // collect every take that becomes visible.
            var seen = Set(firstPage)
            let pageKey = "rail-\(blockID)"
            for _ in 0..<3 {
                model.stepPage(pageKey, by: 1, limit: 1)
                await settle(window, hosting, until: { false }, maxTurns: 3)
                seen.formUnion(cardVariantIDs(in: hosting))
            }
            #expect(seen == Set(fanIDs),
                    "every active take is a card on SOME page — none is unreachable (saw \(seen.count) of \(fanIDs.count))")
        }
    }

    /// 13b Stage 3F pin (the Stage 2 sweep table (a)'s recorded residual;
    /// red-on-old, behavioral-revert verified): a mint at the end of a
    /// LONG open fan landed BEHIND the pager — the fan was open, the
    /// counter ticked, the ◀ x–y of n ▶ door advertised it, but the
    /// revealed card sat on a later page. `revealTake` now pages to the
    /// card (parking until the mint's projection arrives — the real mint
    /// sequence, exercised here).
    @Test func aRevealedMintOnALongFanPagesTheRailToItsCard() async throws {
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 9))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let longText = String(repeating: "prose that outgrows the strip rule. ", count: 8)
            let post = try session.operations.createPost(title: "the long fan")
            let minted = try session.operations.newBlock(in: post.id, text: longText)
            // A CHAIN of branches (each from the previous) lands each mint
            // after its source: fan order 1…5, deterministic.
            var lastID = minted.variant.id
            for _ in 2...5 {
                lastID = try session.operations.branchVariant(minted.block.id, from: lastID).id
            }
            try session.operations.setFanStyle(.marginGrid)

            let model = TakesViewModel(session: session, postID: post.id)
            model.gridRows = 2
            model.gridCols = 1
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
            defer { model.teardown() }

            // The real mint sequence: the op lands, the reveal runs BEFORE
            // the projection catches up (the observation lags), the fresh
            // projection then arrives.
            let sixth = try session.operations.branchVariant(minted.block.id, from: lastID)
            model.revealTake(blockID: minted.block.id, variantID: sixth.id)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })

            // 6 takes at 2-high, 1-wide ⇒ 3 columns, last legal offset 2;
            // the mint is in column 2 — the pager must show it.
            let key = TakesViewModel.railPageKey(minted.block.id)
            #expect(model.pageOffset(key, limit: 2) == 2,
                    "the rail pages to the revealed mint's column — never a mint behind the door")
        }
    }

    /// NIT-2 pin (13b Stage 3 ladder round 1; free with the tidy —
    /// red-on-old by behavioral revert): a parked reveal for a take that
    /// NEVER arrives (a refused mint, a raced delete) used to re-park on
    /// every adopt forever — an O(1) zombie whose stale page-jump could
    /// fire on any later projection that happened to contain the id. The
    /// budget (2 adopts past the park — the real mint sequence resolves on
    /// the first, a stale emission on the second) drops it; a projection
    /// arriving AFTER the budget must not page.
    @Test func aRevealForATakeThatNeverArrivesStopsRetrying() async throws {
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 9))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let longText = String(repeating: "prose that outgrows the strip rule. ", count: 8)
            let post = try session.operations.createPost(title: "the zombie park")
            let minted = try session.operations.newBlock(in: post.id, text: longText)
            var lastID = minted.variant.id
            for _ in 2...5 {
                lastID = try session.operations.branchVariant(minted.block.id, from: lastID).id
            }
            try session.operations.setFanStyle(.marginGrid)

            let model = TakesViewModel(session: session, postID: post.id)
            model.gridRows = 2
            model.gridCols = 1
            let stale = try await db.read { try Queries.takesProjection($0, post: post.id) }
            model.adopt(stale)
            defer { model.teardown() }

            // The mint lands and the reveal parks (the adopted projection
            // predates it)…
            let sixth = try session.operations.branchVariant(minted.block.id, from: lastID)
            model.revealTake(blockID: minted.block.id, variantID: sixth.id)
            // …and two more STALE emissions exhaust the budget (the real
            // sequence resolves on the first; two misses = not coming).
            model.adopt(stale)
            model.adopt(stale)
            // The take finally arrives — three adopts late. The park was
            // dropped: no surprise page-jump long after the reveal.
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
            let key = TakesViewModel.railPageKey(minted.block.id)
            #expect(model.pageOffset(key, limit: 2) == 0,
                    "the exhausted park never pages — the zombie is retired")
        }
    }
}
