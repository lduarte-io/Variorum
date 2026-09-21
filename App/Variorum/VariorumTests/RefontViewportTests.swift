//
//  RefontViewportTests.swift
//  VariorumTests
//
//  13u4 UNIT F2 — KnownIssues row 53: a re-font that SHRINKS the document
//  strands the full-document editor's viewport (UNIT S1's walk: only the
//  last line draws and the rest of the page is blank; ⌘↑ heals it).
//
//  The rig is `EditorWindowSmokeTests`' — a REAL window, a REAL scroll view,
//  a REAL `EditorSurface.Coordinator` — on UNIT S1's own fixture shape
//  (*The Adventure of the Copper Beeches*: 212 blocks, ~10k words), with the
//  caret driven to the document end exactly as her ⌘↓ did.
//
//  What these pins assert is the promise the app already makes on the OTHER
//  reflow it knows about (a width change — `ScrollAnchorController`): **the
//  text she was looking at is still the text she is looking at.** The
//  existing smoke test says it in the same grammar
//  (`#expect(h.model.topVisibleOffset() == anchor)`).
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("A re-font keeps her reading position (13u4 UNIT F2 — row 53)", .serialized)
struct RefontViewportTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// UNIT S1's fixture SHAPE: 212 blocks of ~47 words (*Copper Beeches* is
    /// 212 blocks / 9,999 words). The count is what matters — the
    /// inline-comment room is a per-PARAGRAPH 22 pt, so the shrink this
    /// suite drives is 212 × 22 ≈ 4,664 pt of document.
    private var copperBeechesShape: [String] {
        (0..<212).map { p in
            (0..<47).map { "word\(($0 &+ p) % 613)" }.joined(separator: " ") + " ¶\(p)."
        }
    }

    /// The two chromes the inline-comments toggle produces. TALL is the
    /// document with the comment room; SHORT is without it.
    private var tall: EditorSurfaceChrome {
        EditorSurfaceChrome(voice: .terminal, dark: false, inlineComments: true)
    }

    private var short: EditorSurfaceChrome {
        EditorSurfaceChrome(voice: .terminal, dark: false, inlineComments: false)
    }

    /// Study's 16-pt Iowan is taller than Terminal's 14-pt mono, so a
    /// Study → Terminal switch is the VOICE occasion's shrink.
    private var studyVoice: EditorSurfaceChrome {
        EditorSurfaceChrome(voice: .study, dark: false, inlineComments: false)
    }

    /// One line of geometry for a failure message — the trace, printed by the
    /// red run itself rather than by a probe that has to be removed later.
    private func facts(_ h: EditorHarness, _ scrollView: NSScrollView) -> String {
        let clip = scrollView.contentView.bounds
        let usage = h.textView.textLayoutManager?.usageBoundsForTextContainer.height ?? -1
        return "visibleY=\(clip.origin.y) viewport=\(clip.height)"
            + " frame=\(h.textView.frame.height) usage=\(usage)"
            + " room=\(h.textView.typewriterRoom)"
            + " gap=\(EditorTypography.current.paragraphSpacing)"
            + " font=\(EditorTypography.current.font.pointSize)"
            + " drawnInViewport=\(drawnHeightInViewport(h.textView, scrollView))"
            + " top=\(String(describing: h.model.topVisibleOffset()))"
            + " len=\(h.model.index.documentLength)"
    }

    /// How many points of the viewport are covered by text fragments — the
    /// symptom itself, in a number. Never `.ensuresLayout` (TRACE D-6's own
    /// caveat: a probe that forces the layout it counts is measuring itself).
    private func drawnHeightInViewport(_ textView: NSTextView, _ scrollView: NSScrollView) -> Double {
        guard let layoutManager = textView.textLayoutManager,
              let contentManager = layoutManager.textContentManager
        else { return 0 }
        let visible = scrollView.contentView.bounds
        let originY = textView.textContainerOrigin.y
        var covered: Double = 0
        layoutManager.enumerateTextLayoutFragments(
            from: contentManager.documentRange.location, options: []
        ) { fragment in
            let frame = fragment.layoutFragmentFrame.offsetBy(dx: 0, dy: originY)
            if frame.maxY < visible.minY { return true }
            if frame.minY > visible.maxY { return false }
            covered += Double(min(frame.maxY, visible.maxY) - max(frame.minY, visible.minY))
            return true
        }
        return covered
    }

    /// **THE APP'S OWN ORDER, and the pins drive it exactly** (`ThemeStore
    /// .start`): a settings value LANDS → `EditorTypography.adopt` moves the
    /// one global typography → SwiftUI rebuilds the chrome from those same
    /// settings → the coordinator applies it and the surface re-fonts from
    /// the adopted `current`. A pin that only applied a chrome would measure
    /// `applyVoiceChrome`'s not-yet-adopted fallback instead, which is a
    /// different road with a different answer (the first cut of this suite
    /// did exactly that, and every frame came back the same height).
    private func adoptAndApply(
        _ chrome: EditorSurfaceChrome,
        _ h: EditorHarness, _ scrollView: NSScrollView,
        _ coordinator: EditorSurface.Coordinator
    ) {
        EditorTypography.adopt(chrome.typography)
        coordinator.applyChrome(chrome, to: h.textView, scrollView: scrollView)
        draw(h)
    }

    /// **A NOTE WHOSE GEOMETRY THE APP HAS MEASURED.** TK2 lays out the
    /// viewport and ESTIMATES the rest, and the estimate is what makes a
    /// harness disagree with her app: the first cut of these pins measured a
    /// document whose height barely moved for a 22-pt-per-paragraph change,
    /// because the un-laid-out majority's estimate does not know about the
    /// paragraph style. One `ensureLayout` over the document (a TEST cost —
    /// TEXTKIT2 §2's "resource-intensive", which is exactly why production
    /// never does it) puts the rig in the state a note she has been reading
    /// is in, and the symptom row 53 photographed appears at once.
    @MainActor private func layEverythingOut(_ h: EditorHarness) {
        guard let layoutManager = h.textView.textLayoutManager,
              let contentManager = layoutManager.textContentManager else { return }
        layoutManager.ensureLayout(for: contentManager.documentRange)
        draw(h)
    }

    /// A real display pass (which is what arms the surface's settle hop —
    /// `EditorTextView.viewWillDraw`), then the runloop turn the hop lands on.
    private func draw(_ h: EditorHarness) {
        h.textView.window?.display()
        pump()
        h.textView.window?.display()
        pump()
    }

    /// A windowed editor on the fixture, with the three process globals
    /// `applyVoiceChrome` can reach put back on BOTH exits (the harness's
    /// `withAdoptedTheme` rule — these are shared across parallel suites).
    private func withWindowedEditor(
        _ body: @MainActor (EditorHarness, NSScrollView, EditorSurface.Coordinator) async throws -> Void
    ) async throws {
        let current = EditorTypography.current
        let adopted = EditorTypography.isAdopted
        let palette = MarkdownStyling.palette
        defer {
            EditorTypography.current = current
            EditorTypography.isAdopted = adopted
            MarkdownStyling.palette = palette
        }
        try await withEditor(seedBlocks: copperBeechesShape) { h in
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
            try await body(h, scrollView, EditorSurface.Coordinator(model: h.model))
        }
    }

    /// Her ⌘↓: the caret to the document end, the page scrolled to it.
    private func caretToTheEnd(_ h: EditorHarness) {
        h.model.jumpToDocumentEnd()
        pump()
    }

    /// The ordinary reading position: block 120's first line at the viewport
    /// top, which is where a re-font meets her most of the time.
    private func readingDeepInTheNote(_ h: EditorHarness) -> Int {
        let target = h.model.index.range(ofEntryAt: 120).location
        JumpPrimitive.jump(
            toOffset: target, textView: h.textView,
            scrollView: h.textView.enclosingScrollView)
        pump()
        return target
    }

    // MARK: - The defect: the SHRINKING direction

    @Test func aShrinkingRefontKeepsTheLineAtTheViewportTop() async throws {
        try await withWindowedEditor { h, scrollView, coordinator in
            adoptAndApply(tall, h, scrollView, coordinator)
            _ = readingDeepInTheNote(h)
            let before = try #require(
                h.model.topVisibleOffset(),
                "the fixture must resolve a top line before the re-font")
            let beforeFacts = facts(h, scrollView)

            adoptAndApply(short, h, scrollView, coordinator)

            #expect(
                h.model.topVisibleOffset() == before,
                """
                the shrinking re-font moved her reading position.
                BEFORE \(beforeFacts)
                AFTER  \(facts(h, scrollView))
                """)
        }
    }

    /// Her own gesture, exactly: ⌘↓ to the end, then inline comments OFF.
    /// The symptom UNIT S1 captured is the second half — one line drawn and
    /// the rest of the page blank — so this pin asserts the VIEWPORT is
    /// still full of her prose as well as anchored.
    @Test func herFixtureGestureLeavesThePageDrawn() async throws {
        try await withWindowedEditor { h, scrollView, coordinator in
            adoptAndApply(tall, h, scrollView, coordinator)
            layEverythingOut(h)
            caretToTheEnd(h)
            let before = try #require(
                h.model.topVisibleOffset(),
                "the tail-scrolled viewport must resolve a top line")
            let drawnBefore = drawnHeightInViewport(h.textView, scrollView)
            let beforeFacts = facts(h, scrollView)

            adoptAndApply(short, h, scrollView, coordinator)

            let afterFacts = facts(h, scrollView)
            #expect(
                h.model.topVisibleOffset() == before,
                "the tail re-font moved her reading position.\nBEFORE \(beforeFacts)\nAFTER  \(afterFacts)")
            // The document genuinely shrank, so the page cannot hold as much
            // as it did — but it must not collapse to the one line row 53
            // photographed. Half of what was drawn is a floor the shrink's
            // own arithmetic clears comfortably (the room below the last
            // line is the only honest blank).
            let drawnAfter = drawnHeightInViewport(h.textView, scrollView)
            #expect(
                drawnAfter > drawnBefore / 2,
                "the page emptied: \(drawnBefore) pt of prose before, \(drawnAfter) after.\nAFTER \(afterFacts)")
        }
    }

    /// The brief's own condition: ⌘↑ is the symptom's healer, never the
    /// fix's shape. The caret does not move for a re-font.
    @Test func aRefontNeverMovesTheCaret() async throws {
        try await withWindowedEditor { h, scrollView, coordinator in
            adoptAndApply(tall, h, scrollView, coordinator)
            caretToTheEnd(h)
            let caret = h.textView.selectedRange()

            adoptAndApply(short, h, scrollView, coordinator)

            #expect(h.textView.selectedRange() == caret)
        }
    }

    // MARK: - The other direction, and the other occasion

    @Test func aGrowingRefontKeepsTheLineAtTheViewportTopToo() async throws {
        try await withWindowedEditor { h, scrollView, coordinator in
            adoptAndApply(short, h, scrollView, coordinator)
            _ = readingDeepInTheNote(h)
            let before = try #require(h.model.topVisibleOffset())
            let beforeFacts = facts(h, scrollView)

            adoptAndApply(tall, h, scrollView, coordinator)

            #expect(
                h.model.topVisibleOffset() == before,
                "the growing re-font moved her reading position.\nBEFORE \(beforeFacts)\nAFTER  \(facts(h, scrollView))")
        }
    }

    /// The VOICE occasion (Study's 16-pt Iowan → Terminal's 14-pt mono is a
    /// shrink). The line BREAKING changes with the font, so the anchored
    /// offset need not start a line in the new voice — the promise is
    /// geometric: the anchored text is at the viewport top, within a line.
    @Test func aVoiceSwitchKeepsHerPlaceInBothDirections() async throws {
        try await withWindowedEditor { h, scrollView, coordinator in
            adoptAndApply(studyVoice, h, scrollView, coordinator)
            let anchor = readingDeepInTheNote(h)

            adoptAndApply(short, h, scrollView, coordinator)  // → Terminal: shrink
            let shrunk = try #require(
                JumpPrimitive.lineSpan(ofOffset: anchor, in: h.textView),
                "Study → Terminal: the anchored block has no geometry at all. \(facts(h, scrollView))")
            #expect(
                abs(shrunk.top - Double(scrollView.contentView.bounds.minY)) < 30,
                "Study → Terminal left the anchored block \(shrunk.top - Double(scrollView.contentView.bounds.minY)) pt from the viewport top. \(facts(h, scrollView))")

            adoptAndApply(studyVoice, h, scrollView, coordinator)  // → Study: grow
            let grown = try #require(
                JumpPrimitive.lineSpan(ofOffset: anchor, in: h.textView),
                "Terminal → Study: the anchored block has no geometry at all. \(facts(h, scrollView))")
            #expect(
                abs(grown.top - Double(scrollView.contentView.bounds.minY)) < 30,
                "Terminal → Study left the anchored block \(grown.top - Double(scrollView.contentView.bounds.minY)) pt from the viewport top. \(facts(h, scrollView))")
        }
    }

    // MARK: - TRACE (temporary, 13u4 UNIT F2 piece 3 — removed once recorded)

    @Test func traceTheShrink() async throws {
        try await withWindowedEditor { h, scrollView, coordinator in
            @MainActor func report(_ label: String) {
                Issue.record("TRACE \(label) | \(facts(h, scrollView))")
            }
            adoptAndApply(tall, h, scrollView, coordinator)
            report("1 tall, viewport-only layout")
            layEverythingOut(h)
            report("2 tall, WHOLE document laid out")
            caretToTheEnd(h)
            report("3 tall, caret at the end")
            adoptAndApply(short, h, scrollView, coordinator)
            report("4 short, right after the re-font")
            pump(0.3)
            report("5 short, +0.3s")
            layEverythingOut(h)
            report("6 short, WHOLE document laid out again")
            h.textView.setSelectedRange(NSRange(location: 0, length: 0))
            h.textView.scrollRangeToVisible(NSRange(location: 0, length: 0))
            draw(h)
            report("7 short, after the cmd-up heal")
        }
    }

    // MARK: - The guard: a COLOUR-only change is not a re-font

    /// The cheap road (18g's R1-1 carve) must stay cheap — a palette click
    /// moves no base attribute, so it must neither re-font nor scroll.
    @Test func aColourOnlyChangeMovesNothing() async throws {
        try await withWindowedEditor { h, scrollView, coordinator in
            adoptAndApply(short, h, scrollView, coordinator)
            _ = readingDeepInTheNote(h)
            let before = try #require(h.model.topVisibleOffset())
            let frame = h.textView.frame.height
            let visibleY = scrollView.contentView.bounds.origin.y

            let repainted = EditorSurfaceChrome(
                voice: .terminal, dark: true, inlineComments: false)
            #expect(repainted.needsStorageRefresh(from: short) == false)
            adoptAndApply(repainted, h, scrollView, coordinator)

            #expect(h.model.topVisibleOffset() == before)
            #expect(h.textView.frame.height == frame)
            #expect(scrollView.contentView.bounds.origin.y == visibleY)
        }
    }
}
