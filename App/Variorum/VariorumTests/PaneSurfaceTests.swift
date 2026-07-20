//
//  PaneSurfaceTests.swift
//  VariorumTests
//
//  Phase 13b, Stage 1a — the pane surface's own pins:
//  - N2 (red-on-old): the TK2→TK1 canary is RENDERED. The old
//    TakePaneView captured the canary message into a private var nothing
//    read — a fallback in any take pane was invisible while ReadPostView
//    rendered its own. The unified surface publishes the message into a
//    rendered banner; this pin drives the FULL path (notification →
//    canary → publish → banner) and fails when the publish wiring is
//    reverted (message unpublished, no banner height).
//

import AppKit
import SwiftUI
import Testing
@testable import Variorum

@MainActor
@Suite("Pane surface (13b 1a)", .serialized)
struct PaneSurfaceTests {
    private func pump(_ turns: Int = 4) {
        for _ in 0..<turns {
            RunLoop.main.run(until: Date().addingTimeInterval(0.04))
        }
    }

    private func findPane(_ view: NSView) -> PaneTextView? {
        if let pane = view as? PaneTextView { return pane }
        for sub in view.subviews {
            if let found = findPane(sub) { return found }
        }
        return nil
    }

    @Test func aTK1FallbackRendersAVisibleBannerInThePane() async throws {
        // The memo posture stops the world on fire in debug builds BY
        // DESIGN; the pin swaps the assertion for a no-op for exactly this
        // scope so the fire→render path can run to the banner.
        let originalHandler = FallbackCanary.assertionHandler
        FallbackCanary.assertionHandler = { _ in }
        defer { FallbackCanary.assertionHandler = originalHandler }

        let host = NSHostingController(
            rootView: PaneSurfaceView(text: "a take pane", isLive: false)
                .frame(width: 400))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentViewController = host
        host.view.layoutSubtreeIfNeeded()
        pump()

        let pane = try #require(findPane(host.view))
        let heightBefore = host.view.fittingSize.height

        // The real trigger: AppKit announces the TK2→TK1 downgrade for
        // exactly this text view.
        NotificationCenter.default.post(
            name: NSTextView.willSwitchToNSLayoutManagerNotification, object: pane)
        pump()
        host.view.layoutSubtreeIfNeeded()
        pump()

        // The message was PUBLISHED for rendering (the old code swallowed
        // it into a private var — reverting the publish wiring reds this)…
        #expect(pane.lastPublishedCanary?.contains("TextKit 2") == true,
                "the canary message reached the rendered surface")
        // …and the banner actually RENDERS: the pane's composition grew by
        // the banner's height.
        let heightAfter = host.view.fittingSize.height
        #expect(heightAfter > heightBefore + 10,
                "the fallback banner adds visible height (\(heightBefore) → \(heightAfter))")

        window.contentViewController = nil
    }

    @Test func theMeasurementBrainMatchesTheRenderedPaneHeight() async throws {
        // The ONE measurement brain (P-3): a mounted pane's rendered
        // height equals PaneMeasurement's answer at the same width — the
        // clipped-take class is a divergence between these two numbers.
        let host = NSHostingController(
            rootView: PaneSurfaceView(
                text: "one\n\ntwo\n\nthree paragraphs of prose", isLive: false)
                .frame(width: 400))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 600),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentViewController = host
        host.view.layoutSubtreeIfNeeded()
        pump(6)
        host.view.layoutSubtreeIfNeeded()

        let pane = try #require(findPane(host.view))
        let measured = PaneMeasurement.height(of: pane)
        #expect(measured > 24, "multi-paragraph text measures past the floor")
        #expect(abs(pane.bounds.height - max(measured, 24)) < 2,
                "rendered height \(pane.bounds.height) tracks the one brain's \(measured)")

        window.contentViewController = nil
    }
}
