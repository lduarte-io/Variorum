//
//  TintRegistrationTests.swift
//  VariorumTests
//
//  The container→view registration pins (Phase 10 Step 8's traced
//  mis-registration, carried forward into Phase 13 C1's decoration layer):
//  TK2 fragment frames are TEXT-CONTAINER-relative, the overlay views live
//  in the TEXT VIEW — the mapping applies `textContainerOrigin` in exactly
//  one place (`BlockTint.viewRect`), and the decoration pass
//  (`refreshDecorations`, the 9d tint walk's successor) emits frames that
//  REGISTER with the text they decorate. Red on the old unconverted path
//  by the same mechanism the Phase 10 pin was.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("Decor registration — the pure mapping (Phase 10 Step 8 / Phase 13 C1)")
struct DecorRegistrationMappingTests {
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
@Suite("Decor registration in a real window (Phase 13 C1)", .serialized)
struct DecorRegistrationWindowTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// The registration pin, on the decoration pass: every emitted block
    /// frame must REGISTER with its block's text — frame top == the
    /// block's first fragment's top in VIEW coordinates (container +
    /// origin), frame bottom == the last fragment's bottom likewise.
    @Test func everyDecorFrameRegistersWithItsBlocksText() async throws {
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

            var captured = BlockDecor.State()
            h.model.decorSink = { captured = $0 }
            var appearance = EditorAppearance()
            appearance.seamsVisible = true  // R42's global toggle drives the pass
            h.model.appearance = appearance
            h.model.refreshDecorations()
            pump()
            #expect(captured.frames.count == 4, "all four blocks are in view")
            #expect(captured.entryCount == 4)
            #expect(captured.appearance.seamsVisible)

            // Ground truth straight from TK2, converted by the origin.
            let layoutManager = try #require(h.textView.textLayoutManager)
            let contentManager = try #require(layoutManager.textContentManager)
            let origin = h.textView.textContainerOrigin
            layoutManager.ensureLayout(for: layoutManager.documentRange)
            for span in captured.frames {
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
                        "entry \(span.entryIndex): frame top must sit on the text's view-space top")
                #expect(abs(span.frame.maxY - (last.maxY + origin.y)) < 0.5,
                        "entry \(span.entryIndex): frame bottom must sit on the text's view-space bottom")
            }

            // Frames tile the blocks in order (never overlap upward), and
            // the seam derivation yields one seam per interior boundary,
            // each strictly between its neighbors.
            for i in 1..<captured.frames.count {
                #expect(captured.frames[i].frame.minY
                    >= captured.frames[i - 1].frame.maxY - 0.5,
                    "frames never overlap upward")
            }
            let seams = BlockDecor.seamYs(captured.frames)
            #expect(seams.count == 3, "three interior boundaries")
            for (i, y) in seams.enumerated() {
                #expect(y >= captured.frames[i].frame.maxY - 0.5)
                #expect(y <= captured.frames[i + 1].frame.minY + 0.5)
            }

            // The column edges ride the inset (the badge/comment gutters
            // anchor off these).
            #expect(abs(captured.textLeft - origin.x) < 0.5)
            #expect(abs(captured.textRight
                - (h.textView.bounds.width - h.textView.textContainerInset.width)) < 0.5)

            // The calm default costs nothing: everything off ⇒ empty state.
            h.model.appearance = EditorAppearance()
            pump()
            #expect(captured.frames.isEmpty, "no decorations ⇒ no frames walked")
        }
    }
}
