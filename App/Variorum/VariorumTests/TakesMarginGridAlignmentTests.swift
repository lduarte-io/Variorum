//
//  TakesMarginGridAlignmentTests.swift
//  VariorumTests
//
//  VX-136 (the VX-143 run) — her report: *"the margin grid items are a little
//  bit weirdly misaligned when you have several - the new take area will push
//  others down and it looks weird."* RULED at the sitting (the question
//  tool's recommended option): **the margin grid defaults to TWO columns when
//  the block has more than 2 takes**; R74's choice stays hers.
//
//  What the captures showed (`TakesMarginGridCaptureTests`, the run record):
//  (1) at the shipped one-wide default, a fan of several takes is a single
//  stacked column and a new take lands on a later page; (2) each column
//  stacked its cards at their OWN heights, so with two columns on screen the
//  second row started at a different height in each column; (3) the dashed
//  new-take doors overran the one-card-wide rail by ~23 pt.
//
//  Every hosted pin measures what the screen holds — card panes and their
//  in-card clips through AppKit, the rail and its doors through the DEBUG
//  rail oracle — never a constant we chose.
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
@Suite("The margin grid — the ruled default, aligned rows, doors in the rail (VX-136)", .serialized)
struct TakesMarginGridAlignmentTests {
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

    private func cardPane(_ variantID: String, in view: NSView) -> PaneTextView? {
        panes(in: view).first { $0.identifier?.rawValue == "pane:mini|\(variantID)" }
    }

    /// The card's in-card clip (the capped card wraps its pane in a vertical
    /// ScrollView) — its frame in the window is the card's content box.
    private func clipFrame(of pane: NSView, upTo root: NSView) -> CGRect? {
        var node: NSView? = pane.superview
        while let current = node, current != root {
            if let scroll = current as? NSScrollView { return scroll.convert(scroll.bounds, to: nil) }
            node = current.superview
        }
        return nil
    }

    /// Visible = some of the card's clip is inside the strip's viewport.
    private func isOnScreen(_ pane: PaneTextView) -> Bool {
        guard let clip = pane.enclosingScrollView else { return false }
        return clip.visibleRect.width > 1 && clip.visibleRect.height > 1
    }

    static let sentence = "Honest prose keeps flowing along the measured line and wraps. "

    /// One long-ish block (past R24's strip threshold, so the grid shows)
    /// with `takes` takes whose texts are `lengths[i]` sentences BY FAN
    /// POSITION; `choice` nil = no stored column choice (the ruled default).
    private func withRail(
        lengths: [Int], choice: Int?, gridRows: Int = 2, seed: UInt64,
        _ body: @MainActor (
            _ hosting: NSHostingView<TakesBoardView>, _ window: NSWindow,
            _ model: TakesViewModel, _ session: AppSession,
            _ blockID: String, _ fan: [String]
        ) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        let defaults = UserDefaults.standard
        let savedRows = defaults.object(forKey: "takesGridRows")
        let savedCols = defaults.object(forKey: "takesGridCols")
        defaults.set(gridRows, forKey: "takesGridRows")
        if let choice { defaults.set(choice, forKey: "takesGridCols") }
        else { defaults.removeObject(forKey: "takesGridCols") }
        defer {
            if let savedRows { defaults.set(savedRows, forKey: "takesGridRows") }
            else { defaults.removeObject(forKey: "takesGridRows") }
            if let savedCols { defaults.set(savedCols, forKey: "takesGridCols") }
            else { defaults.removeObject(forKey: "takesGridCols") }
        }
        try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
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
            let post = try session.operations.createPost(title: "the grid")
            let minted = try session.operations.newBlock(
                in: post.id, text: String(repeating: Self.sentence, count: 5))
            for _ in 1..<lengths.count {
                _ = try session.operations.branchVariant(minted.block.id, from: minted.variant.id)
            }
            try session.operations.setFanStyle(.marginGrid)
            // Texts by FAN POSITION (branches land after their source, so
            // the order is read, never assumed).
            let fan = try await db.read {
                try Queries.takesProjection($0, post: post.id).fans[minted.block.id] ?? []
            }.map(\.id)
            #expect(fan.count == lengths.count, "the fixture's fan has every take")
            for (id, count) in zip(fan, lengths) {
                try session.operations.autosave(
                    id, text: String(repeating: Self.sentence, count: count), charDelta: 9)
            }

            let model = TakesViewModel(session: session, postID: post.id)
            model.adopt(try await db.read { try Queries.takesProjection($0, post: post.id) })
            defer { model.teardown() }
#if DEBUG
            TakeRailGeometry.reset(session.debugProbeScope)
#endif
            let window = NSWindow(
                contentRect: NSRect(x: 60, y: 60, width: 1500, height: 1000),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let hosting = NSHostingView(
                rootView: TakesBoardView(session: session, postID: post.id, model: model))
            hosting.frame = NSRect(x: 0, y: 0, width: 1500, height: 1000)
            window.contentView = hosting
            window.makeKeyAndOrderFront(nil)
            await settle(window, hosting, until: { !panes(in: hosting).isEmpty })
            model.toggleExpanded(minted.block.id)
            await settle(window, hosting, until: { cardPane(fan[0], in: hosting) != nil })
            // The measured heights land a turn after the first layout.
            await settle(window, hosting, until: { false }, maxTurns: 10)
            try await body(hosting, window, model, session, minted.block.id, fan)
        }
    }

    // MARK: - The ruled default (her sitting, 2026-10-10)

    /// **RED ON OLD.** No column choice stored, four takes in a two-high grid
    /// ⇒ two columns of cards on screen side by side (the shipped default
    /// showed one column and paged the rest away).
    @Test func severalTakesShowTwoColumnsByDefault() async throws {
        try await withRail(lengths: [5, 5, 5, 5], choice: nil, seed: 1361) {
            hosting, _, _, _, _, fan in
            let visible = fan.compactMap { cardPane($0, in: hosting) }.filter(isOnScreen)
            let columns = Set(visible.map { Int(($0.convert($0.bounds, to: nil).minX / 10).rounded()) })
            #expect(columns.count == 2,
                    "more than two takes ⇒ two columns on screen by default (saw \(columns.count) column(s), \(visible.count) cards)")
            #expect(visible.count == 4, "all four takes on screen at once (saw \(visible.count))")
        }
    }

    /// **Her choice stands (R74) — characterization, green both sides.** A
    /// stored "1 wide" keeps one column, however many takes the block has.
    @Test func herStoredChoiceOfOneColumnStands() async throws {
        try await withRail(lengths: [5, 5, 5, 5], choice: 1, seed: 1362) {
            hosting, _, _, _, _, fan in
            let visible = fan.compactMap { cardPane($0, in: hosting) }.filter(isOnScreen)
            let columns = Set(visible.map { Int(($0.convert($0.bounds, to: nil).minX / 10).rounded()) })
            #expect(columns.count == 1, "her one-wide choice holds (saw \(columns.count) columns)")
        }
    }

    /// The default's pure rule: two takes stay one column; past two, two —
    /// never more columns than the fan fills; a choice always wins.
    @Test func theDefaultsRuleIsPerBlockAndHerChoiceWins() {
        #expect(TakesBoardLayout.effectiveGridCols(choice: nil, takeCount: 1, rowsPerColumn: 2) == 1)
        #expect(TakesBoardLayout.effectiveGridCols(choice: nil, takeCount: 2, rowsPerColumn: 2) == 1,
                "two takes: one column (the rule starts PAST two)")
        #expect(TakesBoardLayout.effectiveGridCols(choice: nil, takeCount: 3, rowsPerColumn: 2) == 2)
        #expect(TakesBoardLayout.effectiveGridCols(choice: nil, takeCount: 9, rowsPerColumn: 2) == 2,
                "two wide, not more — R74's menu stops at two")
        #expect(TakesBoardLayout.effectiveGridCols(choice: nil, takeCount: 3, rowsPerColumn: 3) == 1,
                "three takes in a three-high grid fill ONE column — no empty second")
        #expect(TakesBoardLayout.effectiveGridCols(choice: nil, takeCount: 3, rowsPerColumn: 1) == 2,
                "the one-high strip still shows two past two takes")
        #expect(TakesBoardLayout.effectiveGridCols(choice: 1, takeCount: 9, rowsPerColumn: 2) == 1,
                "her choice wins")
        #expect(TakesBoardLayout.effectiveGridCols(choice: 2, takeCount: 2, rowsPerColumn: 2) == 2,
                "her choice wins both ways")
    }

    // MARK: - The rows line up

    /// **RED ON OLD.** Two columns on screen; the first column's first card
    /// is long and the second column's first card is a one-liner — the
    /// second ROW must start at the same height in both columns.
    @Test func theSecondRowStartsAtTheSameHeightInEveryColumn() async throws {
        // Fan positions: [col 1 row 1, col 1 row 2, col 2 row 1, col 2 row 2].
        try await withRail(lengths: [9, 3, 1, 3], choice: 2, seed: 1363) {
            hosting, _, _, _, _, fan in
            guard let rowTwoLeft = cardPane(fan[1], in: hosting),
                  let rowTwoRight = cardPane(fan[3], in: hosting),
                  let rowOneLeft = cardPane(fan[0], in: hosting),
                  let rowOneRight = cardPane(fan[2], in: hosting),
                  let left = clipFrame(of: rowTwoLeft, upTo: hosting),
                  let right = clipFrame(of: rowTwoRight, upTo: hosting),
                  let topLeft = clipFrame(of: rowOneLeft, upTo: hosting),
                  let topRight = clipFrame(of: rowOneRight, upTo: hosting)
            else {
                Issue.record("the four cards did not all mount")
                return
            }
            #expect(abs(topLeft.height - topRight.height) > 40,
                    "the fixture's first row really is ragged (\(topLeft.height) vs \(topRight.height))")
            // AppKit window coordinates: a card's TOP edge is its maxY.
            #expect(abs(left.maxY - right.maxY) <= 1,
                    "row two's cards start together — left top \(left.maxY), right top \(right.maxY)")
            #expect(topRight.height <= TakesBoardLayout.railCardHeight,
                    "…and the short card is still a sticky note, never padded to its row (L4) — \(topRight.height)")
        }
    }

    /// The rows' pure rule: a row's slot is its tallest card across ALL the
    /// block's columns; unmeasured is one card-height; the reserve is the
    /// rows' sum — and where every column's tall card sits in the same row,
    /// that is the old tallest-column reserve to the point.
    @Test func theRowSlotsAreEachRowsTallestCard() {
        let card = TakesBoardLayout.railCardHeight
        let cap = TakesBoardLayout.marginCardCapHeight
        let gap = TakesBoardLayout.cardGap
        // Columns [900, 40] and [40, 900] — the staggered shape.
        let staggered: [CGFloat?] = [900, 40, 40, 900]
        #expect(TakesBoardLayout.railRowHeights(
            cardTextHeights: staggered, rowsPerColumn: 2) == [cap, cap])
        #expect(TakesBoardLayout.reservedRailHeight(
            cardTextHeights: staggered, rowsPerColumn: 2) == cap * 2 + gap,
                "the reserve is where the aligned grid actually ends")
        #expect(TakesBoardLayout.railRowHeights(
            cardTextHeights: [nil, nil, nil], rowsPerColumn: 2) == [card, card])
        #expect(TakesBoardLayout.railRowHeights(
            cardTextHeights: [nil], rowsPerColumn: 2) == [card],
                "one take, one row — never a phantom second row")
    }

    // MARK: - The new-take doors stay inside the rail

    /// **RED ON OLD.** At one column the rail is one card wide, and the
    /// dashed doors' one-line box overran it; the doors must sit inside the
    /// rail's own width.
    @Test func theNewTakeDoorsStayInsideAOneColumnRail() async throws {
#if DEBUG
        try await withRail(lengths: [5, 5], choice: nil, seed: 1364) {
            _, _, _, session, blockID, _ in
            let scope = session.debugProbeScope
            let rail = try #require(
                TakeRailGeometry.frame(.rail, blockID: blockID, in: scope), "the rail drew")
            let doors = try #require(
                TakeRailGeometry.frame(.doors, blockID: blockID, in: scope), "the doors drew")
            #expect(abs(rail.width - TakesBoardView.railWidth(columns: 1)) <= 0.5,
                    "two takes ⇒ the one-column rail (\(rail.width))")
            #expect(doors.maxX <= rail.maxX + 0.5,
                    "the doors end inside the rail — doors \(doors.minX)…\(doors.maxX), rail \(rail.minX)…\(rail.maxX)")
        }
#endif
    }
}
