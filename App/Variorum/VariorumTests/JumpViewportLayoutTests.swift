//
//  JumpViewportLayoutTests.swift
//  VariorumTests
//
//  18k C6 — KnownIssues row 65, item 1 (`RefontViewportTests`' 94-character
//  drift on macOS 27). THE PRIMITIVE'S OWN PROMISE, pinned where it broke.
//
//  `JumpPrimitive.jump` promises to land the LINE containing an offset at the
//  viewport top. Its correction loop scrolls, lays out the viewport, measures
//  the target line, and stops when the line's top agrees with the top it
//  ASKED FOR. On macOS 27 that stopped being the top it GOT: measured on this
//  rig, `NSTextViewportLayoutController.layoutViewport()` moves the clip view
//  by (about) the height change its own layout pass causes — +29 pt with the
//  document frame +29, −23.23 pt with the frame −23.5 — while the target line
//  stays where it was measured. The loop then reports "converged" with the
//  line one line-plus-gap off the top. A plain flipped document view keeps
//  its clip across a frame change on 27, and a bare `setFrameSize` on this
//  editor moves nothing either: the displacement lives only inside TK2's
//  viewport layout, and only when that pass changes the laid-out geometry —
//  a jump into a region TK2 has so far only ESTIMATED, which is exactly what
//  a re-font's restore (the whole document just invalidated) and a first
//  jump deep into a note both are. On macOS 26 the same road was exact.
//
//  The rig is `RefontViewportTests`' — a REAL window, a REAL scroll view, the
//  REAL coordinator applying a chrome — on the same 212-block fixture, because
//  that is where the displacement was measured deterministically.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("A jump lands its line where it converged (18k C6 — macOS 27)", .serialized)
struct JumpViewportLayoutTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// `RefontViewportTests`' fixture: 212 blocks of ~47 words.
    private var fixture: [String] {
        (0..<212).map { p in
            (0..<47).map { "word\(($0 &+ p) % 613)" }.joined(separator: " ") + " ¶\(p)."
        }
    }

    /// The chrome whose paragraph gap TK2's height ESTIMATE does not know
    /// about — so laying out any stretch of the note changes the document's
    /// height, which is the condition the displacement needs.
    private var tall: EditorSurfaceChrome {
        EditorSurfaceChrome(voice: .terminal, dark: false, inlineComments: true)
    }

    /// Display passes plus real suspensions (`RefontViewportTests.draw`'s
    /// reason: a nested runloop pump cannot drain the main queue from a
    /// main-actor test body).
    private func draw(_ textView: NSTextView) async {
        for _ in 0..<4 {
            textView.needsDisplay = true
            textView.window?.display()
            pump(0.02)
            try? await Task.sleep(for: .milliseconds(30))
        }
    }

    @Test func aJumpIntoEstimatedGeometryLandsItsLineAtTheViewportTop() async throws {
        let current = EditorTypography.current
        let adopted = EditorTypography.isAdopted
        let palette = MarkdownStyling.palette
        defer {
            EditorTypography.current = current
            EditorTypography.isAdopted = adopted
            MarkdownStyling.palette = palette
        }
        try await withEditor(seedBlocks: fixture) { h in
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
            // The app's order (`RefontViewportTests.adoptAndApply`).
            EditorTypography.adopt(tall.typography)
            EditorSurface.Coordinator(model: h.model)
                .applyChrome(tall, to: h.textView, scrollView: scrollView)
            await draw(h.textView)

            // Block 120's first line, deep in a note laid out only around
            // its top — the first jump she makes into it.
            let target = h.model.index.range(ofEntryAt: 120).location
            JumpPrimitive.jump(toOffset: target, textView: h.textView, scrollView: scrollView)

            let visibleTop = Double(scrollView.contentView.bounds.minY)
            let line = try #require(
                JumpPrimitive.lineSpan(ofOffset: target, in: h.textView),
                "the target line has no geometry at all")
            // Geometric: the line the loop converged on IS at the viewport
            // top (within the loop's own 1-pt tolerance) …
            #expect(
                abs(line.top - visibleTop) < 1,
                "the jump reported convergence with its line \(line.top - visibleTop) pt from the viewport top (clip \(visibleTop), line \(line.top), frame \(h.textView.frame.height))")
            // … and in the grammar every landing pin uses: the text at the
            // top is the text asked for.
            #expect(h.model.topVisibleOffset() == target)

            // And it stays there once the page is drawn.
            await draw(h.textView)
            #expect(h.model.topVisibleOffset() == target)
        }
    }
}
