//
//  TintRegistrationTests.swift
//  VariorumTests
//
//  Phase 10 Step 8 — the "Show Blocks" tint ↔ text mis-registration
//  (KnownIssues row, trace-first): TK2 fragment frames are TEXT-CONTAINER-
//  relative, the overlay views live in the TEXT VIEW — the 9d tint emitted
//  container coordinates unconverted, so every stripe sat one
//  textContainerOrigin (8 px ≈ half a line) above its text and block
//  boundaries crossed lines mid-way. Pinned at the pure mapping layer AND
//  against real TK2 geometry in a window (red on old: the emitted span
//  minY missed the text's view-space top by the inset).
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("Tint registration (Phase 10 Step 8)")
struct TintRegistrationMappingTests {
    @Test func theContainerToViewMappingAppliesTheOrigin() {
        let rect = BlockTint.viewRect(
            containerTop: 80, containerBottom: 96,
            containerOrigin: CGPoint(x: 8, y: 8), viewWidth: 420)
        #expect(rect == CGRect(x: 0, y: 88, width: 420, height: 16))
    }

    @Test func theMappingNeverProducesNegativeHeights() {
        let rect = BlockTint.viewRect(
            containerTop: 50, containerBottom: 40,
            containerOrigin: .zero, viewWidth: 100)
        #expect(rect.height == 0)
    }
}

@MainActor
@Suite("Tint registration in a real window (Phase 10 Step 8)", .serialized)
struct TintRegistrationWindowTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// The red-on-old pin: every emitted stripe must REGISTER with its
    /// block's text — span top == the block's first fragment's top in VIEW
    /// coordinates (container + origin), span bottom == the last
    /// fragment's bottom likewise. The old path missed by exactly the
    /// inset on every span.
    @Test func everyStripeRegistersWithItsBlocksText() async throws {
        let long = (0..<40).map { "word\($0)" }.joined(separator: " ")  // wraps
        try await withEditor(seedBlocks: [long, "short block", long, "tail short"]) { h in
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 420, height: 600),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            defer {
                window.orderOut(nil)
                window.close()
            }
            let scrollView = try #require(h.textView.enclosingScrollView)
            window.contentView = scrollView
            window.orderFrontRegardless()
            pump()

            var captured: [EditorViewModel.BlockTintSpan] = []
            h.model.tintSink = { captured = $0 }
            h.model.blockTintEnabled = true
            h.model.refreshTint()
            pump()
            #expect(captured.count == 4, "all four blocks are in view")

            // Ground truth straight from TK2, converted by the origin.
            let layoutManager = try #require(h.textView.textLayoutManager)
            let contentManager = try #require(layoutManager.textContentManager)
            let origin = h.textView.textContainerOrigin
            layoutManager.ensureLayout(for: layoutManager.documentRange)
            for span in captured {
                let range = h.model.index.range(ofEntryAt: span.entryIndex)
                func fragmentFrame(at offset: Int) throws -> CGRect {
                    let location = try #require(contentManager.location(
                        contentManager.documentRange.location, offsetBy: offset))
                    var frame: CGRect?
                    layoutManager.enumerateTextLayoutFragments(from: location, options: []) {
                        frame = $0.layoutFragmentFrame
                        return false
                    }
                    return try #require(frame)
                }
                let first = try fragmentFrame(at: range.location)
                let last = try fragmentFrame(at: max(range.location, range.upperBound - 1))
                #expect(abs(span.frame.minY - (first.minY + origin.y)) < 0.5,
                        "entry \(span.entryIndex): stripe top must sit on the text's view-space top")
                #expect(abs(span.frame.maxY - (last.maxY + origin.y)) < 0.5,
                        "entry \(span.entryIndex): stripe bottom must sit on the text's view-space bottom")
            }

            // The stable-color rules stand untouched: never-adjacent, and
            // spans tile the blocks in order.
            for i in 1..<captured.count {
                #expect(captured[i].colorIndex != captured[i - 1].colorIndex)
                #expect(captured[i].frame.minY >= captured[i - 1].frame.maxY - 0.5,
                        "stripes never overlap upward")
            }
        }
    }
}
