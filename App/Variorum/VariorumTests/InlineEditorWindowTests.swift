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
