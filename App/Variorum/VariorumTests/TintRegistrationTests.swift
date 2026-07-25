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

    // MARK: The paragraph-gap correction (13c 1A — A40)

    /// TK2 folds the paragraph's trailing gap into `layoutFragmentFrame`;
    /// a block's visual extent is its TEXT. Measured on the terminal voice:
    /// a one-line paragraph is 17 pt of text in a 24 pt frame.
    @Test func theTextBottomExcludesTheTrailingParagraphGap() {
        #expect(BlockDecor.textBottom(
            fragmentMinY: 24, fragmentMaxY: 48, lastLineMaxY: 17) == CGFloat(41))
    }

    /// The document's LAST paragraph carries no trailing gap — frame and
    /// text bottom already agree, and the correction is a no-op.
    @Test func theTextBottomIsAnIdentityWhenThereIsNoTrailingGap() {
        #expect(BlockDecor.textBottom(
            fragmentMinY: 48, fragmentMaxY: 65, lastLineMaxY: 17) == CGFloat(65))
    }

    /// A fragment TK2 has not laid out yet reports no line fragments; the
    /// correction degrades to the frame — the pre-fix value, never worse.
    @Test func anUnlaidFragmentDegradesToItsFrame() {
        #expect(BlockDecor.textBottom(
            fragmentMinY: 0, fragmentMaxY: 4964, lastLineMaxY: nil) == CGFloat(4964))
    }

    /// Never past the frame, whatever a line reports.
    @Test func theTextBottomNeverExceedsTheFragmentFrame() {
        #expect(BlockDecor.textBottom(
            fragmentMinY: 0, fragmentMaxY: 24, lastLineMaxY: 99) == CGFloat(24))
    }

    /// R17's white-gap rule is BINDING — and with real gaps it works as
    /// written. Terminal-voice geometry: 17 pt lines, a 7 pt uniform gap.
    @Test func theCalloutLeavesTheWhiteGapItPromises() {
        let above = CGRect(x: 0, y: 0, width: 700, height: 17)
        let block = CGRect(x: 0, y: 24, width: 700, height: 17)
        let below = CGRect(x: 0, y: 48, width: 700, height: 17)
        let rect = BlockDecor.calloutRect(
            block: block,
            gapAbove: block.minY - above.maxY,
            gapBelow: below.minY - block.maxY,
            textLeft: 60, textRight: 640)
        #expect(rect.minY - above.maxY >= 6, "≥ minWhiteGap of base background above")
        #expect(below.minY - rect.maxY >= 6, "≥ minWhiteGap of base background below")
    }

    /// The same rule on the PRE-FIX inputs — the mechanism behind her
    /// report, stated as a test so it cannot come back unnoticed. When
    /// block frames swallow the paragraph gap the neighbours ABUT, so
    /// `verticalPad` receives 0, returns 0, and the wash it pads is already
    /// a whole gap too tall: zero white background, the colour running
    /// straight into the next block ("the color spreads underneath it").
    @Test func swallowedGapsLeaveNoWhiteAtAll() {
        let above = CGRect(x: 0, y: 0, width: 700, height: 24)
        let block = CGRect(x: 0, y: 24, width: 700, height: 24)
        let below = CGRect(x: 0, y: 48, width: 700, height: 17)
        #expect(BlockDecor.verticalPad(gap: block.minY - above.maxY) == CGFloat(0))
        let rect = BlockDecor.calloutRect(
            block: block,
            gapAbove: block.minY - above.maxY,
            gapBelow: below.minY - block.maxY,
            textLeft: 60, textRight: 640)
        #expect(below.minY - rect.maxY == CGFloat(0), "no white background at all")
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
                func fragmentFrame(
                    at offset: Int
                ) throws -> (frame: CGRect, lastLineMaxY: CGFloat?) {
                    let location = try #require(contentManager.location(
                        contentManager.documentRange.location, offsetBy: offset))
                    var found: (CGRect, CGFloat?)?
                    layoutManager.enumerateTextLayoutFragments(from: location, options: []) {
                        found = ($0.layoutFragmentFrame,
                                 $0.textLineFragments.last?.typographicBounds.maxY)
                        return false
                    }
                    let resolved = try #require(found)
                    return (resolved.0, resolved.1)
                }
                let first = try fragmentFrame(at: range.location)
                let last = try fragmentFrame(at: max(range.location, range.upperBound - 1))
                #expect(abs(span.frame.minY - (first.frame.minY + origin.y)) < 0.5,
                        "entry \(span.entryIndex): frame top must sit on the text's view-space top")
                // 13c 1A (A40) — THE CORRECTED GROUND TRUTH. This assertion
                // used to read `last.maxY`, the layout FRAGMENT's bottom,
                // which TK2 measures a whole paragraph gap below the text
                // (24 pt frame around a 17 pt line in the terminal voice).
                // The test's own prose said "the text's view-space bottom"
                // all along; only the assertion disagreed, so the decoration
                // layer's mis-mapping was pinned in place rather than caught.
                // Ground truth is now the last LINE's typographic bottom.
                let textBottom = last.frame.minY
                    + (last.lastLineMaxY ?? last.frame.height)
                #expect(abs(span.frame.maxY - (textBottom + origin.y)) < 0.5,
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

            // 13c 1A (A40), red-on-old: consecutive block frames leave a REAL
            // gap — the uniform per-paragraph gap belongs to NEITHER block.
            // Pre-fix every interior gap measured 0.0, because each frame
            // swallowed the gap below it; the seams therefore landed on the
            // next block's first line instead of centred in the white.
            let gap = EditorTypography.current.paragraphSpacing
            for i in 1..<captured.frames.count {
                let measured = captured.frames[i].frame.minY
                    - captured.frames[i - 1].frame.maxY
                #expect(abs(measured - gap) < 1.0,
                        "gap \(i) is the uniform paragraph gap (\(measured) vs \(gap))")
            }
            for (i, y) in seams.enumerated() {
                let above = captured.frames[i].frame.maxY
                let below = captured.frames[i + 1].frame.minY
                #expect(y > above + 0.5 && y < below - 0.5,
                        "seam \(i) sits INSIDE the white gap, not on either block's text")
            }

            // The calm default costs nothing: everything off ⇒ empty state.
            h.model.appearance = EditorAppearance()
            pump()
            #expect(captured.frames.isEmpty, "no decorations ⇒ no frames walked")
        }
    }
}
