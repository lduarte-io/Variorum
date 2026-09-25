//
//  ScrollAnchorTests.swift
//  VariorumTests
//
//  Phase 13c, Batch 1A — the reading-position anchor in a REAL window
//  (her A4: "the editor jumps around when one block is taller than the
//  screen").
//
//  The anchor is `topVisibleOffset()` (read on every scroll) →
//  `restoreTopVisibleOffset()` (replayed on every width reflow: sidebar
//  toggle, split divider, window resize, live-resize end). It is the
//  Phase 6 memo's standing rule — "never px-anchor across reflow, restore
//  by text location" — and it had two independent defects, both traced and
//  reproduced before either was touched:
//
//  1. FRAGMENT GRANULARITY. A Variorum block is always its own paragraph
//     (R26/R33) and a paragraph is ONE TK2 layout fragment, so a block
//     taller than the viewport collapsed every reading position inside it
//     to the block's start. Measured on the pre-fix code: scrolled to
//     y=2500 inside a 6127 pt block, the anchor answered the block's first
//     character and the restore landed at y=225.
//  2. COORDINATE SPACE. `textLayoutFragment(for:)` takes a TEXT-CONTAINER
//     point; this site passed a VIEW point, so every anchor sat one
//     container inset too low and named the block BELOW the one at the
//     viewport top. (The decoration pass converts; this one did not — the
//     Phase 10 container↔view mis-registration class, one site over.)
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Scroll anchor over tall blocks (13c 1A — A4)", .serialized)
struct ScrollAnchorTests {
    private func pump(_ turns: Int = 4) {
        for _ in 0..<turns {
            RunLoop.main.run(until: Date().addingTimeInterval(0.03))
        }
    }

    /// Mounts a seeded post's detail editor in a real window and lays it out
    /// fully, so every assertion reads measured geometry rather than TK2's
    /// estimates.
    private func inWindow(
        _ h: EditorHarness, height: CGFloat = 500,
        _ body: @MainActor (NSScrollView, NSWindow) throws -> Void
    ) throws {
        let scrollView = try #require(h.textView.enclosingScrollView)
        scrollView.frame = NSRect(x: 0, y: 0, width: 760, height: height)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 760, height: height),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = NSView(frame: NSRect(x: 0, y: 0, width: 760, height: height))
        window.contentView?.addSubview(scrollView)
        window.orderFrontRegardless()
        window.layoutIfNeeded()
        window.display()
        pump()
        defer {
            window.orderOut(nil)
            window.close()
        }
        if let layoutManager = h.textView.textLayoutManager {
            layoutManager.ensureLayout(for: layoutManager.documentRange)
        }
        try body(scrollView, window)
    }

    private func scroll(_ scrollView: NSScrollView, _ window: NSWindow, to y: CGFloat) {
        scrollView.contentView.scroll(to: CGPoint(x: 0, y: y))
        scrollView.reflectScrolledClipView(scrollView.contentView)
        window.displayIfNeeded()
        pump(2)
    }

    /// A post whose block 3 is far taller than any viewport.
    private var tallBlockCorpus: [String] {
        var blocks = (0..<10).map { p in
            (0..<40).map { "word\(($0 &+ p) % 977)" }.joined(separator: " ")
        }
        blocks[3] = (0..<4000).map { "long\($0 % 97)" }.joined(separator: " ")
        return blocks
    }

    /// RED-ON-OLD (defect 1). Deep inside a block taller than the viewport,
    /// the anchor must name where the reader IS — not the block's start.
    @Test func theAnchorResolvesInsideABlockTallerThanTheViewport() async throws {
        try await withEditor(seedBlocks: tallBlockCorpus) { h in
            try inWindow(h) { scrollView, window in
                scroll(scrollView, window, to: 2500)
                let tallStart = h.model.index.range(ofEntryAt: 3).location
                let anchor = try #require(h.model.topVisibleOffset())
                // Pre-fix this was exactly `tallStart` at every depth.
                #expect(anchor > tallStart + 5_000,
                        "anchor \(anchor) must sit deep inside the tall block (starts at \(tallStart)), not at its first character")
                #expect(anchor < h.model.index.range(ofEntryAt: 3).upperBound,
                        "and still inside that block")
            }
        }
    }

    /// RED-ON-OLD (defect 1), the consequence she lives with: a width
    /// reflow replays the anchor, and the reading position must survive it.
    /// Pre-fix this leapt 2500 → 225.
    @Test func aWidthReflowKeepsTheReadingPositionInsideATallBlock() async throws {
        try await withEditor(seedBlocks: tallBlockCorpus) { h in
            try inWindow(h) { scrollView, window in
                scroll(scrollView, window, to: 2500)
                let before = scrollView.contentView.bounds.origin.y
                #expect(before == CGFloat(2500))
                let anchor = try #require(h.model.topVisibleOffset())
                h.model.restoreTopVisibleOffset(anchor)
                pump(3)
                let after = scrollView.contentView.bounds.origin.y
                // The round trip is LINE-quantised and nothing more: the
                // anchor names the line at the top, the restore puts that
                // line's top at the top, so the error is bounded by one line
                // height (17 pt in the terminal voice). The defect was a
                // 2275 pt leap.
                #expect(abs(after - before) <= 17,
                        "reading position survived the reflow (\(before) → \(after))")
            }
        }
    }

    /// RED-ON-OLD (defect 2). With short blocks a container-inset error
    /// crosses whole blocks: the anchor must name the block actually AT the
    /// viewport top. Pre-fix it named the one below at every stop.
    @Test func theAnchorNamesTheBlockAtTheViewportTopNotTheOneBelow() async throws {
        let blocks = (0..<40).map { "block number \($0) short" }
        try await withEditor(seedBlocks: blocks) { h in
            try inWindow(h, height: 300) { scrollView, window in
                let textView = h.textView
                let layoutManager = try #require(textView.textLayoutManager)
                let origin = textView.textContainerOrigin

                /// Ground truth: the first entry whose LETTERS are still at
                /// or below the anchor's probe (one point under the viewport
                /// top) — its baseline on screen — the block she is reading.
                ///
                /// 18k C6b (W-4) re-mechanized this from "the last entry whose
                /// FRAGMENT top is at or above the viewport top". A TK2 layout
                /// fragment includes its paragraph's trailing spacing, so that
                /// definition answered the block ABOVE whenever the edge sat
                /// in the gap below it — a block with none of its text on
                /// screen, and the very choice the held walks' W-4 traced (the
                /// previous paragraph's last line restored to the top). The
                /// defect this pin exists for is unchanged and still bites:
                /// the uncorrected container point names the block BELOW at
                /// BOTH stops (the scroll to 200 lands on a line, the one to
                /// 500 in a gap) — proven by that mutation in the C6b record.
                /// Every block here is one line with no blank paragraph, so
                /// "its letters are on screen" is its last line's baseline.
                @MainActor func topEntry(_ top: CGFloat) -> Int {
                    var baselines: [CGFloat] = []
                    layoutManager.enumerateTextLayoutFragments(
                        from: layoutManager.documentRange.location, options: []
                    ) { fragment in
                        let last = fragment.textLineFragments.last
                        let baseline = (last?.typographicBounds.minY ?? 0) + (last?.glyphOrigin.y ?? 0)
                        baselines.append(fragment.layoutFragmentFrame.minY + origin.y + baseline)
                        return true
                    }
                    return baselines.firstIndex { $0 >= top + 1 } ?? baselines.count - 1
                }
                @MainActor func entry(containing offset: Int) -> Int {
                    var start = 0
                    for (i, e) in h.model.index.entries.enumerated() {
                        if offset >= start, offset <= start + e.length { return i }
                        start += e.length + 1
                    }
                    return -1
                }

                for target: CGFloat in [200, 500] {
                    scroll(scrollView, window, to: target)
                    let top = scrollView.contentView.bounds.origin.y
                    let anchor = try #require(h.model.topVisibleOffset())
                    #expect(entry(containing: anchor) == topEntry(top),
                            "at scrollTop \(top) the anchor must name the block at the top")
                }
            }
        }
    }

    /// Ordinary short blocks are the everyday path and must be untouched:
    /// the anchor still lands on the block's own start (one line ⇒ the
    /// line's offset IS the block's offset), so nothing about the common
    /// case changed with the tall-block fix.
    @Test func shortBlocksStillAnchorAtTheirOwnStart() async throws {
        let blocks = (0..<40).map { "block number \($0) short" }
        try await withEditor(seedBlocks: blocks) { h in
            try inWindow(h, height: 300) { scrollView, window in
                scroll(scrollView, window, to: 200)
                let anchor = try #require(h.model.topVisibleOffset())
                var starts: [Int] = []
                var start = 0
                for e in h.model.index.entries {
                    starts.append(start)
                    start += e.length + 1
                }
                #expect(starts.contains(anchor),
                        "a one-line block's anchor is the block's own start")
            }
        }
    }
}
