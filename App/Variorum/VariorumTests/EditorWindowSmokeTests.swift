//
//  EditorWindowSmokeTests.swift
//  VariorumTests
//
//  Phase 7 Step 8 — the automatable slice of the TEXTKIT2_NOTES §5 matrix
//  on a REAL window with a 10k-word post: (a) canary silent through a real
//  editing session; (b) the hybrid jump lands its target block at the
//  viewport top; content-anchored restore across a width reflow (the
//  spike's −79-paragraph hazard); typing cost stays inside the frame budget
//  at 10k words. The interactive checks (live resize drag, visual draw
//  correctness, selection feel) remain the author's manual pass.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("10k-word window smoke (Step 8)", .serialized)
struct EditorWindowSmokeTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// ~10k words: 50 paragraph-blocks × 200 words.
    private var corpus: [String] {
        (0..<50).map { p in
            (0..<200).map { "word\(($0 &+ p) % 977)" }.joined(separator: " ") + " ¶\(p)"
        }
    }

    @Test func tenThousandWordPostStaysSnappyAndAnchored() async throws {
        try await withEditor(seedBlocks: corpus) { h in
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 900, height: 600),
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

            // (a) A real editing session with the canary armed: typing at
            // the start, middle, and end of the document.
            h.type("Start. ", at: 0)
            let middle = h.model.index.range(ofEntryAt: 25).location + 10
            h.type(" mid ", at: middle)
            h.type(" End.", at: (h.documentText as NSString).length)
            #expect(h.model.canaryMessage == nil)

            // (b) The bounded hybrid jump lands block 40 at the viewport top.
            let target = h.model.index.range(ofEntryAt: 40).location
            JumpPrimitive.jump(toOffset: target, textView: h.textView, scrollView: scrollView)
            pump()
            #expect(h.model.topVisibleOffset() == target)

            // Content-anchored restore across a width reflow (never
            // px-anchored — the memo's obligation; the notification wiring
            // is ScrollAnchorController's, driven manually here).
            let anchor = try #require(h.model.topVisibleOffset())
            window.setContentSize(NSSize(width: 600, height: 600))
            pump()
            h.model.restoreTopVisibleOffset(anchor)
            pump()
            #expect(h.model.topVisibleOffset() == anchor)

            // Typing cost at 10k words: 60 keystrokes mid-document through
            // the full pipeline (routing, index, attribute fix, autosave
            // record). Debug build, generous bound — the spike owns the
            // precise numbers; this guards against a pipeline regression
            // that scales with document size.
            let caret = h.model.index.range(ofEntryAt: 25).location + 4
            h.textView.setSelectedRange(NSRange(location: caret, length: 0))
            let t0 = ContinuousClock.now
            for _ in 0..<60 {
                h.textView.insertText("q", replacementRange: h.textView.selectedRange())
            }
            let elapsed = t0.duration(to: .now)
            let msPerKeystroke = Double(elapsed.components.attoseconds) / 1e15 / 60
                + Double(elapsed.components.seconds) * 1000 / 60
            #expect(msPerKeystroke < 16.7, "keystroke pipeline cost \(msPerKeystroke) ms")

            // And the store still matches the surface exactly.
            await h.flush()
            try expectStoreMatchesView(h)
            #expect(h.model.canaryMessage == nil)
        }
    }
}
