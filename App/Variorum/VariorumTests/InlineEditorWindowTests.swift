//
//  InlineEditorWindowTests.swift
//  VariorumTests
//
//  Phase 10 review round 1 — the inline (book-view) editor in a real
//  window: overlays cover the whole focused post (MINOR 5 — no
//  viewport-pruned staleness class), and the per-edit height maintenance
//  is MEASURED at 10k words (MINOR 6 — the review bar: measured, never
//  asserted; TEXTKIT2_NOTES §2 names whole-document ensureLayout as the
//  dangerous API, so the warm cost gets a number).
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Inline editor in a window (Phase 10 round 1)", .serialized)
struct InlineEditorWindowTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// ~10k words across 50 blocks (the smoke-test corpus shape).
    private var corpus: [String] {
        (0..<50).map { p in
            (0..<200).map { "word\(($0 &+ p) % 977)" }.joined(separator: " ") + " ¶\(p)"
        }
    }

    /// Builds an inline editor (bare content-sized text view, no own
    /// scroll view) inside a SHORT window, so the container clips it —
    /// exactly the book view's shape.
    @MainActor
    private func makeInlineWindow(
        _ h: EditorHarness
    ) -> (window: NSWindow, coordinator: InlineEditorSurface.Coordinator) {
        let window = NSWindow(
            contentRect: NSRect(x: 80, y: 80, width: 700, height: 300),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 700, height: 300))
        window.contentView = container
        container.addSubview(h.textView)
        let coordinator = InlineEditorSurface.Coordinator(model: h.model)
        coordinator.install(textView: h.textView as! EditorTextView) { height in
            h.textView.frame = NSRect(x: 0, y: 0, width: 700, height: height)
        }
        window.orderFrontRegardless()
        return (window, coordinator)
    }

    /// MINOR 5 (red-on-old): a fanned block far below the container's
    /// clipped viewport still badges — inline overlays cover the whole
    /// focused post, because nothing re-fires them when the CONTAINER
    /// scrolls (the staleness class is removed, not raced).
    @Test func inlineBadgesCoverTheWholePostNotJustTheClippedViewport() async throws {
        try await withInlineEditor(seedBlocks: corpus) { h in
            let (window, coordinator) = makeInlineWindow(h)
            defer {
                coordinator.uninstall()
                window.orderOut(nil)
                window.close()
            }
            coordinator.remeasure()
            pump()
            #expect(h.textView.visibleRect.height < h.textView.bounds.height,
                    "the container clips the inline surface (the book-view shape)")

            // Fan a block far below the visible region.
            let slots = try h.storeSlots()
            let deep = slots[40]
            _ = try h.session.operations.branchVariant(deep.blockID, from: deep.variantID!)
            try h.reload()
            h.model.refreshBadges()
            #expect(h.model.badges.map(\.blockID) == [deep.blockID],
                    "the off-viewport fanned block badges — no stale pruning")
            let frame = try #require(h.model.badges.first?.frame)
            #expect(!h.textView.visibleRect.intersects(frame),
                    "and it really is outside the clipped viewport")
        }
    }

    /// MINOR 6 (the measurement the review asked for): the inline
    /// editor's per-edit height maintenance — ensureLayout(documentRange)
    /// + usageBounds on a WARM 10k-word document — measured through the
    /// real coordinator, plus the full keystroke+remeasure pipeline.
    /// Debug build, generous frame-budget bound; the number prints for
    /// the closeout.
    @Test func inlineHeightMaintenanceStaysInsideTheFrameBudgetAtTenThousandWords() async throws {
        try await withInlineEditor(seedBlocks: corpus) { h in
            let (window, coordinator) = makeInlineWindow(h)
            defer {
                coordinator.uninstall()
                window.orderOut(nil)
                window.close()
            }
            coordinator.remeasure()  // the cold pass (layout warms here)
            pump()

            func ms(_ elapsed: Duration) -> Double {
                Double(elapsed.components.seconds) * 1000
                    + Double(elapsed.components.attoseconds) / 1e15
            }

            // The warm remeasure alone.
            var t0 = ContinuousClock.now
            for _ in 0..<60 { coordinator.remeasure() }
            let warmRemeasure = ms(t0.duration(to: .now)) / 60
            print("Phase 10 round 1 [10k words]: warm inline remeasure \(warmRemeasure) ms")

            // The full pipeline: keystroke mid-document + the remeasure the
            // coordinator's edit observer performs.
            let caret = h.model.index.range(ofEntryAt: 25).location + 4
            h.textView.setSelectedRange(NSRange(location: caret, length: 0))
            t0 = ContinuousClock.now
            for _ in 0..<60 {
                h.textView.insertText("q", replacementRange: h.textView.selectedRange())
                coordinator.remeasure()
            }
            let perKeystroke = ms(t0.duration(to: .now)) / 60
            print("Phase 10 round 1 [10k words]: inline keystroke + remeasure \(perKeystroke) ms")
            #expect(warmRemeasure < 16.7, "warm remeasure \(warmRemeasure) ms")
            #expect(perKeystroke < 16.7, "keystroke + remeasure \(perKeystroke) ms")
            await h.flush()
            try expectStoreMatchesView(h)
        }
    }

    /// MINOR-2 pin (13b Stage 3 ladder round 1; CONFIRMED — red on the
    /// pre-fix code and by behavioral revert, the badge 816pt from the
    /// reflowed fragment): the inline (book-view) editor's WIDTH-REFLOW
    /// axis. The N14 settle trigger keyed ONLY on storage generation — a
    /// geometry-only width change (the book column resizing) re-lays the
    /// text but bumped no generation, `applyChrome` is equality-gated, and
    /// the inline form has no ScrollAnchorController (the detail editor's
    /// resize→refreshBadges coverage is scrollView-only) — so the ⑂
    /// badge/decor frames sat at pre-reflow positions until the next
    /// keystroke or remount: the fixed cold-mount class one INPUT AXIS
    /// over. The fix: the width reflow joins the generation's inputs
    /// (`EditorTextView.onWidthReflow`), and the handler schedules the
    /// coalesced delivery DIRECTLY — TK2 invalidates lazily, so a bare
    /// frame change guarantees no display pass to report through.
    /// HARNESS NOTE (load-bearing): the before phase must reach the
    /// steady state (delivered == generation) through the settle path —
    /// a pending undelivered mount generation would heal the reflow by
    /// accident and mask the red.
    @Test func inlineBadgesTrackAWidthReflow() async throws {
        // Long wrapping prose between two fanned blocks: narrowing the
        // wrapper moves the last fan's block down by hundreds of points.
        let blocks = ["First fanned block."]
            + (0..<6).map { p in
                (0..<80).map { "word\(($0 &+ p) % 977)" }.joined(separator: " ")
            }
            + ["Last fanned block."]
        try await withInlineEditor(seedBlocks: blocks) { h in
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 700, height: 300),
                styleMask: [.titled], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let container = NSView(frame: NSRect(x: 0, y: 0, width: 700, height: 300))
            window.contentView = container
            container.addSubview(h.textView)
            let textView = h.textView
            // The wrapper width is SwiftUI's in the app; the height report
            // follows it (the real InlineEditorSurface shape).
            var wrapperWidth: CGFloat = 700
            // 18k C2: …and SwiftUI lays the wrapper out at that width right
            // after `makeNSView`, BEFORE any height report — the report sets
            // the height, never the width. This harness used to reach 700 pt
            // only through `install`'s synchronous report; the report now
            // arrives on the next turn, so the mount's width is set the way
            // the app sets it (traced: without this line the width first
            // changed AFTER the reload, and TextKit's first measure at the new
            // width — 880 pt against a converged 915 — became the steady state).
            textView.frame.size.width = wrapperWidth
            let coordinator = InlineEditorSurface.Coordinator(model: h.model)
            coordinator.install(textView: textView) { height in
                textView.frame = NSRect(x: 0, y: 0, width: wrapperWidth, height: height)
            }
            window.orderFrontRegardless()
            defer {
                coordinator.uninstall()
                window.orderOut(nil)
                window.close()
            }

            // Fan the first and last blocks.
            let slots = try h.storeSlots()
            let first = try #require(slots.first)
            let last = try #require(slots.last)
            _ = try h.session.operations.branchVariant(
                first.blockID, from: #require(first.variantID))
            _ = try h.session.operations.branchVariant(
                last.blockID, from: #require(last.variantID))
            try h.reload()
            // Reach the app's STEADY state through the settle path itself:
            // warm full layout, force the display pass, and let the
            // trigger deliver every pending generation — "badges
            // delivered" (the routing's premise) with delivered ==
            // generation, exactly the state a live editor idles in.
            coordinator.remeasure()
            window.layoutIfNeeded()
            window.display()

            /// Ground truth: entry i's first laid-out fragment, in view
            /// coordinates — the same frame `refreshBadges` computes from.
            @MainActor func fragmentY(entry i: Int) -> CGFloat? {
                guard let lm = textView.textLayoutManager,
                      let cm = lm.textContentManager else { return nil }
                let range = h.model.index.range(ofEntryAt: i)
                guard let location = cm.location(
                    cm.documentRange.location, offsetBy: range.location) else { return nil }
                var frame: CGRect?
                lm.enumerateTextLayoutFragments(from: location, options: []) { fragment in
                    frame = fragment.layoutFragmentFrame
                    return false
                }
                return frame.map {
                    $0.offsetBy(
                        dx: textView.textContainerOrigin.x,
                        dy: textView.textContainerOrigin.y).origin.y
                }
            }
            @MainActor func badgeY(_ blockID: String) -> CGFloat? {
                h.model.badges.first { $0.blockID == blockID }?.frame.origin.y
            }
            // The proven N14-pin wait: async polling drains the settle
            // trigger's main-queue hop; the display call gives any
            // draw-pass report its chance too.
            @MainActor func pumpUntil(_ condition: @MainActor () -> Bool) async {
                for _ in 0..<400 {
                    if condition() { return }
                    window.displayIfNeeded()
                    await Task.yield()
                    try? await Task.sleep(for: .milliseconds(5))
                }
            }
            let lastEntry = blocks.count - 1
            await pumpUntil {
                guard let y = badgeY(last.blockID),
                      let truth = fragmentY(entry: lastEntry) else { return false }
                return abs(y - truth) < 1
            }
            let before = try #require(badgeY(last.blockID))
            #expect(abs(before - (fragmentY(entry: lastEntry) ?? -1)) < 1,
                    "delivered at the real frame before the reflow (steady state)")

            // THE REFLOW: the wrapper narrows — the app's path is a SwiftUI
            // width change (updateNSView = equality-gated applyChrome +
            // remeasure), the frame following via the height report. NO
            // storage edit rides it — the axis under test.
            wrapperWidth = 360
            textView.setFrameSize(NSSize(width: 360, height: textView.frame.height))
            coordinator.remeasure()
            // Every chance to heal: display passes + queue turns (the
            // settle trigger's async hop rides these when it fires at all).
            await pumpUntil {
                guard let y = badgeY(last.blockID),
                      let truth = fragmentY(entry: lastEntry) else { return false }
                return abs(y - truth) < 1
            }

            let truth = try #require(fragmentY(entry: lastEntry))
            #expect(truth - before > 40,
                    "the reflow genuinely moved the block (non-vacuity)")
            let after = try #require(badgeY(last.blockID))
            #expect(abs(after - truth) < 1,
                    "the ⑂ badge tracks the reflowed fragment geometry (MINOR-2)")
        }
    }
}

/// `withEditor`'s inline twin: the bare content-sized text view, attached
/// with NO scroll view — the book view's editor shape.
@MainActor
func withInlineEditor<T>(
    seedBlocks: [String] = [],
    _ body: @MainActor (EditorHarness) async throws -> T
) async throws -> T {
    try await withEditorWorld(posts: [seedBlocks]) { w in
        let h = try await w.focus(w.postIDs[0])!
        return try await body(h)
    }
}
