//
//  CommitBarLayoutTests.swift
//  VariorumTests
//
//  pre-13u Act 10 wave 1, item 6 — **the bottom bar spreads back out.**
//  Her ruling: *"this bottom bar should be spread out again, unless the
//  window is small and it needs to be collapsed."* The shipped switch
//  collapsed below 1080 pt — an ORDINARY editor pane, which is exactly the
//  cramped two-row state her screenshot showed. The decision is a pure
//  function, and this pin holds the ruled behaviour: **red on old** — at
//  900 pt (an ordinary window's editor pane) the old bar used two rows.
//
//  ── THE ACT 10 CORRECTION ROUND, BATCH G — ROW 81 (a JUSTIFIED PIN EDIT) ──
//  The two-row fallback is RETIRED: F's walk at a ~950-pt window with an
//  inspector open (the bar ~316 pt) found it wrapping AND truncating every
//  label ("blo… · t… · c… · h…"). The collapse is now a FOLD — one row at
//  every width, the tail doors in a `more ▾` overflow — so `usesTwoRows`
//  became `arrangement(width:)` with the same 840-pt threshold and a second
//  one (600) below which the folded row itself would not fit. The three
//  pins below re-express item 6's ruling in the new vocabulary (the same
//  widths, the same verdicts: ordinary widths never collapse; small ones
//  do; an unmeasured bar never flashes a collapse), and the mounted pin
//  holds row 81's own promise: at F's widths the bar is ONE row and
//  nothing runs past its edge — with every member `fixedSize`, that IS
//  "no label truncates". RED ON OLD: at 316 pt the two-row VStack stands
//  twice as tall as the full row.
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@Suite("The bottom bar's arrangement by width (Act 10 item 6 · correction round row 81)")
struct CommitBarLayoutTests {
    @Test func ordinaryWidthsKeepTheFullRow() {
        // RED ON OLD (item 6): 900 < the shipped 1080 collapsed an ordinary pane.
        #expect(CommitBar.arrangement(width: 900) == .full)
        #expect(CommitBar.arrangement(width: 1000) == .full)
        #expect(CommitBar.arrangement(width: 1400) == .full)
    }

    @Test func genuinelySmallWidthsFoldAndTheNarrowestCompact() {
        // The book-inline form and a narrow split pane — the fallback her
        // ruling keeps, delivered as a fold (row 81), never two rows.
        #expect(CommitBar.arrangement(width: 700) == .folded)
        #expect(CommitBar.arrangement(width: 600) == .folded)
        #expect(CommitBar.arrangement(width: 500) == .compact)
        // F's walk: a ~950-pt window with an inspector open.
        #expect(CommitBar.arrangement(width: 316) == .compact)
    }

    @Test func anUnmeasuredBarNeverCollapses() {
        // Width 0 = the first pass before geometry lands: the full row, so
        // the bar does not flash a fold while mounting.
        #expect(CommitBar.arrangement(width: 0) == .full)
    }

    // MARK: - Row 81: one row, nothing past the edge, at F's widths

    /// The REAL bar mounted at the full width (the reference row), then at a
    /// ~950-pt window's bar (691 pt) and at F's inspector-open bar (316 pt):
    /// the row is exactly as tall as the full row (ONE row), and its frame
    /// ends inside the bar's padding (nothing overflows) — and since every
    /// member of a folded row is `fixedSize`, an overflow is the only way a
    /// label could fail to fit, so "inside the edge" is "no label
    /// truncates". RED ON OLD: at 316 the two-row VStack.
    @MainActor
    @Test func theBarStaysOneRowWithNothingPastItsEdgeAtNarrowMeasures() async throws {
        try await withEditor(seedBlocks: ["A block to stand in.", "And a second one."]) { h in
            try h.reload()
            let reference = try Self.mountedRow(h.model, width: 1200)
            #expect(reference.row.height > 0)
            for width: CGFloat in [691, 316] {
                let measured = try Self.mountedRow(h.model, width: width)
                #expect(measured.row.height <= reference.row.height + 1,
                        "at \(width) the bar is ONE row: \(measured.row.height) vs the full row's \(reference.row.height)")
                #expect(measured.row.maxX <= measured.bar - 12 + 0.5,
                        "at \(width) nothing runs past the bar's edge: row maxX \(measured.row.maxX) vs the edge \(measured.bar - 12)")
                #expect(measured.row.minX >= 12 - 0.5,
                        "at \(width) the row starts inside the bar's leading padding")
            }
        }
    }

    /// Mounts the real bar in a real window of `width` and reads the DEBUG
    /// oracle: the row's frame in the bar's own space, and the bar's width.
    @MainActor
    private static func mountedRow(
        _ model: EditorViewModel, width: CGFloat
    ) throws -> (row: CGRect, bar: CGFloat) {
        CommitBarGeometry.reset()
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: width, height: 200),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        defer {
            window.orderOut(nil)
            window.close()
        }
        let hosting = NSHostingView(
            rootView: CommitBar(model: model)
                .environment(ThemeStore(session: model.session)))
        hosting.frame = NSRect(x: 0, y: 0, width: width, height: 200)
        window.contentView = hosting
        window.orderFrontRegardless()
        for _ in 0..<40 {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            RunLoop.main.run(until: Date().addingTimeInterval(0.02))
            // The arrangement is decided by the MEASURED width, which lands
            // a pass after the first layout — settle until the oracle's bar
            // width is the window's.
            if let bar = CommitBarGeometry.barWidth, abs(bar - width) < 0.5,
               CommitBarGeometry.rowFrame != nil {
                break
            }
        }
        let row = try #require(CommitBarGeometry.rowFrame, "the bar reported its row at \(width)")
        let bar = try #require(CommitBarGeometry.barWidth, "…and its own width")
        return (row, bar)
    }
}
