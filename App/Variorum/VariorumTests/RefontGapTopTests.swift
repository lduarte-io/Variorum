//
//  RefontGapTopTests.swift
//  VariorumTests
//
//  18k C6b — the held walks' W-4 (KnownIssues: "After an inline-comments (or
//  paragraph-gap) toggle, Write can leave the PREVIOUS paragraph's last line
//  at the top of the page"). 13u4 UNIT F2's promise, where it did not hold:
//  **the line she was reading stays at the top** — and when the page's top
//  edge sits in the GAP between two paragraphs, the line she is reading is
//  the one BELOW the gap, the first line of the following paragraph.
//
//  The rig is `RefontViewportTests`' (a REAL window, a REAL scroll view, the
//  REAL coordinator applying a chrome in the app's adopt-then-apply order).
//  What it adds is HER NOTE'S SHAPE. The sample library's stories are
//  Gutenberg text with a blank line between paragraphs, and bulk entry keeps
//  that blank line as CONTENT (`SegmentationRules.bulkSegments`' k−1 rule:
//  each block carries one trailing newline, the editor's separator re-makes
//  the second). So on *The Adventure of the Copper Beeches* the page shows an
//  EMPTY paragraph between every two, and the gap she sees is three zones,
//  top to bottom: the paragraph's own trailing spacing (`paragraphSpacing`,
//  part of ITS layout fragment), the blank line, and the blank line's own
//  trailing spacing. The edge can rest in any of them, and the capture
//  (`topVisibleOffset`) used to name the line whose fragment it hit — the
//  previous paragraph's LAST line in the first zone (the walk's exact
//  symptom) and the BLANK line in the other two — so the restore put that
//  line at the top and hers one line (plus a gap) lower.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("A re-font at a paragraph-gap top keeps HER line at the top (18k C6b — W-4)", .serialized)
struct RefontGapTopTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// HER NOTE'S SHAPE: *Copper Beeches*' 212 paragraphs of varied length,
    /// each block carrying the one trailing newline bulk entry keeps for the
    /// blank line between paragraphs (the last paragraph has none — nothing
    /// follows it). The page therefore reads paragraph · blank line ·
    /// paragraph, exactly as her note does.
    private var herNoteShape: [String] {
        (0..<212).map { p in
            let words = 8 + (p &* 37) % 90
            let text = (0..<words).map { "word\(($0 &+ p) % 613)" }.joined(separator: " ") + " ¶\(p)."
            return p == 211 ? text : text + "\n"
        }
    }

    /// A TYPED note's shape — no blank line between paragraphs, so the gap is
    /// the paragraph spacing alone (`RefontViewportTests`' fixture).
    private var typedNoteShape: [String] {
        (0..<212).map { p in
            (0..<47).map { "word\(($0 &+ p) % 613)" }.joined(separator: " ") + " ¶\(p)."
        }
    }

    /// Inline comments ON (the taller document) and OFF (the found state).
    private var commentsOn: EditorSurfaceChrome {
        EditorSurfaceChrome(voice: .terminal, dark: false, inlineComments: true)
    }

    private var commentsOff: EditorSurfaceChrome {
        EditorSurfaceChrome(voice: .terminal, dark: false, inlineComments: false)
    }

    /// `RefontViewportTests.draw`'s reason: a nested runloop pump cannot drain
    /// the main queue from a main-actor test body, and the settle hop that
    /// spends the park is a main-queue hop armed by a display pass.
    private func draw(_ h: EditorHarness) async {
        for _ in 0..<4 {
            h.textView.needsDisplay = true
            h.textView.window?.display()
            pump(0.02)
            try? await Task.sleep(for: .milliseconds(30))
        }
    }

    /// The app's order (`ThemeStore.start`): adopt, then apply.
    private func adoptAndApply(
        _ chrome: EditorSurfaceChrome,
        _ h: EditorHarness, _ scrollView: NSScrollView,
        _ coordinator: EditorSurface.Coordinator
    ) async {
        EditorTypography.adopt(chrome.typography)
        coordinator.applyChrome(chrome, to: h.textView, scrollView: scrollView)
        await draw(h)
    }

    private func withWindowedEditor(
        _ blocks: [String],
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
        try await withEditor(seedBlocks: blocks) { h in
            // Her Write column: a 664-pt measure at a 780-pt page.
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 720, height: 780),
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
            let coordinator = EditorSurface.Coordinator(model: h.model)
            await adoptAndApply(commentsOff, h, scrollView, coordinator)
            try await body(h, scrollView, coordinator)
        }
    }

    /// Where the page's top edge rests inside the gap above her paragraph.
    enum Zone: String, CaseIterable, Sendable, CustomTestStringConvertible {
        /// The previous paragraph's last line, below its BASELINE — only its
        /// descenders on screen. The C6b walk's own find (Study, at the end
        /// of the note after ⌘↓: a 3-pt sliver of the line above): to her eye
        /// this IS a gap top, and the capture named the sliver's line.
        case belowThePreviousBaseline
        /// The previous paragraph's own trailing spacing — the walk's W-4.
        case belowTheParagraph
        /// The blank line between the two paragraphs.
        case onTheBlankLine
        /// The blank line's own trailing spacing, just above her first line.
        case belowTheBlankLine
        var testDescription: String { rawValue }
    }

    /// The geometry of the gap above block `n` on her note's shape.
    private struct Gap {
        let herStart: Int
        let paragraphBaseline: Double
        let paragraphBottom: Double
        let blankTop: Double
        let blankBottom: Double
        let herTop: Double
    }

    private func gap(above n: Int, _ h: EditorHarness) throws -> Gap {
        let previous = h.model.index.range(ofEntryAt: n - 1)
        let herStart = h.model.index.range(ofEntryAt: n).location
        // The previous block's last TEXT character sits before its trailing
        // newline; the blank paragraph is the separator after the block.
        let paragraph = try #require(
            JumpPrimitive.lineSpan(ofOffset: previous.upperBound - 2, in: h.textView))
        let blank = try #require(
            JumpPrimitive.lineSpan(ofOffset: previous.upperBound, in: h.textView))
        let her = try #require(JumpPrimitive.lineSpan(ofOffset: herStart, in: h.textView))
        // Leading is 0 in both voices, so the baseline sits one descent
        // above the line's bottom (TK2's `glyphOrigin.y`: 14 of 17 in
        // Terminal, 17 of 22 in Study — measured).
        let descent = Double(abs(EditorDocument.baseFont.descender))
        return Gap(
            herStart: herStart, paragraphBaseline: paragraph.bottom - descent,
            paragraphBottom: paragraph.bottom,
            blankTop: blank.top, blankBottom: blank.bottom, herTop: her.top)
    }

    /// Brings the gap above block `n` into the middle of the page first, so
    /// both paragraphs beside it are LAID OUT before anything is measured: a
    /// fragment just above a landing is still an estimate, and it moves by a
    /// gap's worth the moment it is laid out (measured on the typed shape — the
    /// first cut of this rig placed its edge on geometry that then shifted).
    private func bringIntoView(_ n: Int, _ h: EditorHarness, _ scrollView: NSScrollView) async {
        let herStart = h.model.index.range(ofEntryAt: n).location
        JumpPrimitive.jump(toOffset: herStart, textView: h.textView, scrollView: scrollView)
        await draw(h)
        let y = Double(scrollView.contentView.bounds.minY) - 300
        scrollView.contentView.scroll(to: NSPoint(x: 0, y: y))
        scrollView.reflectScrolledClipView(scrollView.contentView)
        await draw(h)
    }

    /// Scrolls the page so its top edge rests in `zone` above block `n`, and
    /// REQUIRES that it does (a mis-placed edge must never count as a pass).
    private func placeEdge(
        _ zone: Zone, above n: Int, _ h: EditorHarness, _ scrollView: NSScrollView
    ) async throws -> Int {
        let herStart = h.model.index.range(ofEntryAt: n).location
        await bringIntoView(n, h, scrollView)
        let g = try gap(above: n, h)
        let y: Double = switch zone {
        case .belowThePreviousBaseline: g.paragraphBaseline + 0.5
        case .belowTheParagraph: (g.paragraphBottom + g.blankTop) / 2
        case .onTheBlankLine: (g.blankTop + g.blankBottom) / 2
        case .belowTheBlankLine: (g.blankBottom + g.herTop) / 2
        }
        scrollView.contentView.scroll(to: NSPoint(x: 0, y: y))
        scrollView.reflectScrolledClipView(scrollView.contentView)
        await draw(h)
        let now = try gap(above: n, h)
        let edge = Double(scrollView.contentView.bounds.minY)
        let inZone = switch zone {
        // The probe (one point under the edge) must also fall below the
        // baseline and inside the line's box.
        case .belowThePreviousBaseline: edge > now.paragraphBaseline && edge + 1 < now.paragraphBottom
        case .belowTheParagraph: edge > now.paragraphBottom && edge < now.blankTop
        case .onTheBlankLine: edge > now.blankTop && edge < now.blankBottom
        case .belowTheBlankLine: edge > now.blankBottom && edge < now.herTop
        }
        try #require(
            inZone,
            "the rig must rest the edge in \(zone.rawValue): edge \(edge), paragraph bottom \(now.paragraphBottom), blank \(now.blankTop)–\(now.blankBottom), her top \(now.herTop)")
        return herStart
    }

    /// Her line — the first line of the paragraph below the gap — is at the
    /// viewport top, in both grammars the landing pins use.
    private func expectHerLineAtTheTop(
        _ herStart: Int, _ h: EditorHarness, _ scrollView: NSScrollView,
        _ when: String, sourceLocation: SourceLocation = #_sourceLocation
    ) {
        let top = h.model.topVisibleOffset()
        let edge = Double(scrollView.contentView.bounds.minY)
        let herTop = JumpPrimitive.lineSpan(ofOffset: herStart, in: h.textView)?.top
        #expect(
            top == herStart,
            "\(when): the line at the top is offset \(String(describing: top)), hers is \(herStart) (her line \(herTop.map { $0 - edge } ?? .nan) pt below the edge)",
            sourceLocation: sourceLocation)
        #expect(
            herTop.map { abs($0 - edge) < 1 } == true,
            "\(when): her line is \(herTop.map { $0 - edge } ?? .nan) pt from the viewport top",
            sourceLocation: sourceLocation)
    }

    // MARK: - The capture

    /// The read half, alone: with the edge in the gap, the reading position
    /// the app captures IS her line — not the previous paragraph's last line,
    /// and not the blank line between them.
    @Test(arguments: Zone.allCases)
    func theCaptureAtAGapTopNamesHerLine(_ zone: Zone) async throws {
        try await withWindowedEditor(herNoteShape) { h, scrollView, _ in
            let herStart = try await placeEdge(zone, above: 120, h, scrollView)
            #expect(
                h.model.topVisibleOffset() == herStart,
                "with the edge \(zone.rawValue), the captured reading position is \(String(describing: h.model.topVisibleOffset())), not her line \(herStart)")
        }
    }

    // MARK: - The walk's gesture

    /// W-4 exactly: the edge in the gap, inline comments ON, then OFF. Her
    /// line is at the top after BOTH (the walk saw the previous paragraph's
    /// last line on top after the first).
    @Test(arguments: Zone.allCases)
    func aGapTopRefontKeepsHerLineAtTheTop(_ zone: Zone) async throws {
        try await withWindowedEditor(herNoteShape) { h, scrollView, coordinator in
            let herStart = try await placeEdge(zone, above: 120, h, scrollView)

            await adoptAndApply(commentsOn, h, scrollView, coordinator)
            expectHerLineAtTheTop(herStart, h, scrollView, "comments ON from \(zone.rawValue)")

            await adoptAndApply(commentsOff, h, scrollView, coordinator)
            expectHerLineAtTheTop(herStart, h, scrollView, "then OFF")
        }
    }

    /// A TYPED note has no blank line — its gap is the paragraph spacing
    /// alone, which belongs to the PREVIOUS paragraph's fragment. Same rule.
    @Test func aTypedNotesGapTopKeepsHerLineAtTheTop() async throws {
        try await withWindowedEditor(typedNoteShape) { h, scrollView, coordinator in
            let herStart = h.model.index.range(ofEntryAt: 120).location
            await bringIntoView(120, h, scrollView)
            let before = try #require(
                JumpPrimitive.lineSpan(ofOffset: herStart - 2, in: h.textView))
            let her = try #require(JumpPrimitive.lineSpan(ofOffset: herStart, in: h.textView))
            scrollView.contentView.scroll(to: NSPoint(x: 0, y: (before.bottom + her.top) / 2))
            scrollView.reflectScrolledClipView(scrollView.contentView)
            await draw(h)
            let edge = Double(scrollView.contentView.bounds.minY)
            let nowBefore = try #require(
                JumpPrimitive.lineSpan(ofOffset: herStart - 2, in: h.textView))
            let nowHer = try #require(JumpPrimitive.lineSpan(ofOffset: herStart, in: h.textView))
            try #require(
                edge > nowBefore.bottom && edge < nowHer.top,
                "the rig must rest the edge in the paragraph spacing: \(nowBefore.bottom) < \(edge) < \(nowHer.top)")

            await adoptAndApply(commentsOn, h, scrollView, coordinator)
            expectHerLineAtTheTop(herStart, h, scrollView, "typed note, comments ON")
            await adoptAndApply(commentsOff, h, scrollView, coordinator)
            expectHerLineAtTheTop(herStart, h, scrollView, "typed note, then OFF")
        }
    }

    // MARK: - The guard: a line cut by the edge is still the line she is reading

    /// A text line STRADDLING the edge stays the anchor (the walk's PASS
    /// rows): the capture names it, and a re-font puts it whole at the top.
    @Test func aLineStraddlingTheEdgeStaysTheAnchor() async throws {
        try await withWindowedEditor(herNoteShape) { h, scrollView, coordinator in
            let herStart = h.model.index.range(ofEntryAt: 120).location
            await bringIntoView(120, h, scrollView)
            let her = try #require(JumpPrimitive.lineSpan(ofOffset: herStart, in: h.textView))
            scrollView.contentView.scroll(to: NSPoint(x: 0, y: (her.top + her.bottom) / 2))
            scrollView.reflectScrolledClipView(scrollView.contentView)
            await draw(h)
            #expect(h.model.topVisibleOffset() == herStart)

            await adoptAndApply(commentsOn, h, scrollView, coordinator)
            expectHerLineAtTheTop(herStart, h, scrollView, "a straddled line, comments ON")
        }
    }
}
