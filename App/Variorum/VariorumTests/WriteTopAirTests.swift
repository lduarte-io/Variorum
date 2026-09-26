//
//  WriteTopAirTests.swift
//  VariorumTests
//
//  18l UNIT U0b — KnownIssues row 87. Her report (2026-09-25, verbatim):
//  *"when I am in write and remove a newline, the editor's height adjusts
//  removing the whitespace between the topmost line in the editor and the line
//  at the top of the editor."* Her captures
*[removed for publication]*
//  block 4/4, the caret on an EMPTY last block, the first line resting in the
//  page's top air → one backspace → block 3/3 (the tray count 6 → 7: the empty
//  block went to the tray) and the first line jumped UP against the masthead's
//  divider.
//
//  ── THE TRACED MECHANISM (the U0b RECORD carries the measurements) ─────────
//  The page's top air is NOT an inset that changes with the block count — it is
//  the container's fixed 24-pt top inset (`makeEditor`), above ALL text, and at
//  rest the page is scrolled to 0 so that air shows. The backspace on the empty
//  block is A7's carve (`runEmptyBlockDeletion`), a `seam: nil` structural
//  result, so it lands through `renderFull` — the full re-render — whose
//  scroll-anchor restore captures `topVisibleOffset()` (offset 0: the first
//  line) and replays it through `JumpPrimitive.jump`, whose contract is "the
//  line at the viewport TOP". A page resting in its top air has its first line
//  24 pt BELOW the top, so the restore scrolls it up by exactly the air. The
//  anchor could not express "where the line sat"; it only names the line.
//
//  The same restore snaps a MID-NOTE page by the edge's offset inside its line
//  (a full re-render where the differential road — the everyday gestures'
//  "untouched text never moves", author decision 2026-07-07 — moves nothing),
//  and the width-reflow and re-font keepers replay the same line-at-the-top
//  anchor, so a page resting in its top air loses it to a sidebar toggle or a
//  voice switch too. Every pin here is a REAL window, the REAL keystroke road
//  (`deleteBackward` / `insertNewline`) or the REAL coordinator, in both voices.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Write keeps the page's top air and its lines still (18l U0b — KnownIssues row 87)", .serialized)
struct WriteTopAirTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// `RefontViewportTests.draw`'s reason: a nested runloop pump cannot drain
    /// the main queue from a main-actor test body, and the settle hops that
    /// spend the parks are main-queue hops armed by a display pass.
    private func draw(_ h: EditorHarness) async {
        for _ in 0..<4 {
            h.textView.needsDisplay = true
            h.textView.window?.display()
            pump(0.02)
            try? await Task.sleep(for: .milliseconds(30))
        }
    }

    private func chrome(_ voice: ThemeVoice) -> EditorSurfaceChrome {
        EditorSurfaceChrome(voice: voice, dark: false, inlineComments: false)
    }

    *[removed for publication]*
    *[removed for publication]*
    private let herNote = [
        *[removed for publication]*
        "",
        "Ok for starters:",
        "",
    ]

    /// A long typed note (no blank lines) with an EMPTY block at `emptyAt` —
    /// the same gesture's mid-note and tail shapes.
    private func longNote(emptyAt: Int, count: Int = 60) -> [String] {
        (0..<count).map { p in
            p == emptyAt
                ? ""
                : (0..<(20 + (p &* 37) % 60)).map { "word\(($0 &+ p) % 613)" }
                    .joined(separator: " ") + " ¶\(p)."
        }
    }

    /// A REAL window at her Write column's proportions, the REAL coordinator
    /// (chrome birth in `voice`, the scroll-anchor controller installed —
    /// `EditorSurface.makeNSView`'s order), the page at rest.
    private func withWindowedEditor(
        _ blocks: [String], voice: ThemeVoice,
        _ body: @MainActor (EditorHarness, NSScrollView, NSWindow, EditorSurface.Coordinator) async throws -> Void
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
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 720, height: 780),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let scrollView = try #require(h.textView.enclosingScrollView)
            let coordinator = EditorSurface.Coordinator(model: h.model)
            defer {
                coordinator.uninstall()
                window.orderOut(nil)
                window.close()
            }
            window.contentView = scrollView
            window.orderFrontRegardless()
            pump()
            EditorTypography.adopt(chrome(voice).typography)
            coordinator.applyChrome(chrome(voice), to: h.textView, scrollView: scrollView)
            coordinator.install(scrollView: scrollView, textView: h.textView)
            await draw(h)
            try await body(h, scrollView, window, coordinator)
            await h.flush()
        }
    }

    /// Where the line holding `offset` sits below the viewport's top edge.
    private func lineY(_ offset: Int, _ h: EditorHarness, _ scrollView: NSScrollView) throws -> Double {
        let span = try #require(JumpPrimitive.lineSpan(ofOffset: offset, in: h.textView))
        return span.top - Double(scrollView.contentView.bounds.minY)
    }

    private func scroll(_ scrollView: NSScrollView, to y: Double, _ h: EditorHarness) async {
        scrollView.contentView.scroll(to: NSPoint(x: 0, y: y))
        scrollView.reflectScrolledClipView(scrollView.contentView)
        await draw(h)
    }

    /// Her backspace on the empty block the caret stands in: the REAL key
    /// binding's action, then the carve's flight to its landing.
    private func backspace(inEmptyBlock entry: Int, _ h: EditorHarness) async {
        let start = h.model.index.range(ofEntryAt: entry).location
        h.textView.setSelectedRange(NSRange(location: start, length: 0))
        h.textView.deleteBackward(nil)
        await h.flush()
        await draw(h)
    }

    // MARK: - Her gesture

    /// **THE PIN — her exact sequence.** The page at rest (its top air
    /// showing), the caret on the empty LAST block, one backspace: the block
    /// goes to the tray and NOTHING on the page moves.
    @Test(arguments: [ThemeVoice.terminal, ThemeVoice.study])
    func removingTheEmptyLastBlockKeepsTheTopAir(_ voice: ThemeVoice) async throws {
        try await withWindowedEditor(herNote, voice: voice) { h, scrollView, _, _ in
            let clipBefore = Double(scrollView.contentView.bounds.minY)
            let firstBefore = try lineY(0, h, scrollView)
            try #require(clipBefore < 0.5, "the premise: the page rests at its top (\(clipBefore))")
            try #require(firstBefore > 10, "the premise: the first line sits in the page's top air (\(firstBefore) pt down)")

            await backspace(inEmptyBlock: 3, h)

            #expect(try h.storeSlots().count == 3, "the premise: the carve landed (4 blocks → 3)")
            let clipAfter = Double(scrollView.contentView.bounds.minY)
            let firstAfter = try lineY(0, h, scrollView)
            #expect(
                abs(clipAfter - clipBefore) < 0.5,
                "\(voice): the page scrolled \(clipBefore) → \(clipAfter) pt on a backspace that moved no text above the caret")
            #expect(
                abs(firstAfter - firstBefore) < 0.5,
                "\(voice): the first line moved from \(firstBefore) to \(firstAfter) pt below the page's top — its air collapsed")
        }
    }

    /// **The round trip:** ⏎ at the end of her last line makes the empty block
    /// (the differential road), ⌫ takes it away again (the carve's) — the
    /// first line must not move at either step.
    @Test(arguments: [ThemeVoice.terminal, ThemeVoice.study])
    func addThenRemoveLeavesTheFirstLineWhereItWas(_ voice: ThemeVoice) async throws {
        try await withWindowedEditor(Array(herNote.dropLast()), voice: voice) { h, scrollView, _, _ in
            let firstBefore = try lineY(0, h, scrollView)
            try #require(firstBefore > 10, "the premise: the first line sits in the page's top air")

            let end = (h.documentText as NSString).length
            h.textView.setSelectedRange(NSRange(location: end, length: 0))
            h.textView.insertNewline(nil)
            await h.flush()
            await draw(h)
            #expect(try h.storeSlots().count == 4, "the premise: ⏎ made the empty block")
            let afterAdd = try lineY(0, h, scrollView)
            #expect(
                abs(afterAdd - firstBefore) < 0.5,
                "\(voice): ⏎ moved the first line \(firstBefore) → \(afterAdd)")

            await backspace(inEmptyBlock: 3, h)
            #expect(try h.storeSlots().count == 3, "the premise: ⌫ carved it away")
            let afterRemove = try lineY(0, h, scrollView)
            #expect(
                abs(afterRemove - firstBefore) < 0.5,
                "\(voice): ⌫ moved the first line \(firstBefore) → \(afterRemove)")
        }
    }

    // MARK: - The same gesture on a long note

    /// Mid-note: the page's top edge cuts a line (as any wheel-scrolled page
    /// does), the caret on an empty block further down the page, ⌫. The text
    /// between the edge and the carve did not change, so none of it may move.
    @Test(arguments: [ThemeVoice.terminal, ThemeVoice.study])
    func aMidNoteCarveMovesNothingOnThePage(_ voice: ThemeVoice) async throws {
        try await withWindowedEditor(longNote(emptyAt: 30), voice: voice) { h, scrollView, _, _ in
            let top = h.model.index.range(ofEntryAt: 26).location
            JumpPrimitive.jump(toOffset: top, textView: h.textView, scrollView: scrollView)
            await draw(h)
            // Five points into the line (above its baseline in both voices):
            // the line is still the one she is reading, cut by the edge.
            await scroll(scrollView, to: Double(scrollView.contentView.bounds.minY) + 5, h)
            let reference = h.model.index.range(ofEntryAt: 28).location
            let before = try lineY(reference, h, scrollView)
            try #require(before > 0 && before < 700, "the premise: the reference line is on the page (\(before))")

            await backspace(inEmptyBlock: 30, h)

            #expect(try h.storeSlots().count == 59, "the premise: the carve landed")
            let after = try lineY(reference, h, scrollView)
            #expect(
                abs(after - before) < 0.5,
                "\(voice): a line above the carve moved \(before) → \(after) pt from the top")
        }
    }

    /// At the tail: the note's end on the page, the caret on the empty LAST
    /// block, ⌫ — the lines above it stay where they were.
    @Test(arguments: [ThemeVoice.terminal, ThemeVoice.study])
    func aTailCarveOnALongNoteMovesNothingOnThePage(_ voice: ThemeVoice) async throws {
        try await withWindowedEditor(longNote(emptyAt: 59), voice: voice) { h, scrollView, _, _ in
            let top = h.model.index.range(ofEntryAt: 54).location
            JumpPrimitive.jump(toOffset: top, textView: h.textView, scrollView: scrollView)
            await draw(h)
            await scroll(scrollView, to: Double(scrollView.contentView.bounds.minY) + 5, h)
            let reference = h.model.index.range(ofEntryAt: 57).location
            let before = try lineY(reference, h, scrollView)
            try #require(before > 0 && before < 700, "the premise: the reference line is on the page (\(before))")

            await backspace(inEmptyBlock: 59, h)

            #expect(try h.storeSlots().count == 59, "the premise: the carve landed")
            let after = try lineY(reference, h, scrollView)
            #expect(
                abs(after - before) < 0.5,
                "\(voice): a line above the carve moved \(before) → \(after) pt from the top")
        }
    }

    // MARK: - The same anchor on the other two keepers (the class, not the path)

    /// A WIDTH reflow OUTSIDE live resize (a sidebar toggle, a split divider)
    /// with the page resting in its top air. **A GUARD, green on both sides —
    /// the row is HOLLOW as a defect** (the U0b RECORD): a frame-only change
    /// at scroll 0 posts no clip BOUNDS notification, so
    /// `ScrollAnchorController.boundsChanged`'s width branch has nothing to
    /// run on and nothing restores. Kept so the property stays pinned.
    @Test(arguments: [ThemeVoice.terminal, ThemeVoice.study])
    func aWidthReflowAtThePageTopKeepsTheTopAir(_ voice: ThemeVoice) async throws {
        try await withWindowedEditor(longNote(emptyAt: 30), voice: voice) { h, scrollView, window, _ in
            // An ordinary scroll away and back — the controller keeps its
            // anchor current on every scroll, exactly as it does for her.
            await scroll(scrollView, to: 300, h)
            await scroll(scrollView, to: 0, h)
            let firstBefore = try lineY(0, h, scrollView)
            try #require(firstBefore > 10, "the premise: the page rests in its top air")

            var frame = window.frame
            frame.size.width -= 160
            window.setFrame(frame, display: true)
            await draw(h)

            let firstAfter = try lineY(0, h, scrollView)
            #expect(
                abs(firstAfter - firstBefore) < 0.5,
                "\(voice): the width reflow moved the first line \(firstBefore) → \(firstAfter) pt below the top")
        }
    }

    /// A LIVE window resize (a corner drag — the controller captures at
    /// `willStartLiveResize` and restores at `didEndLiveResize`) with the page
    /// resting in its top air: the air stays. AppKit's own two notifications,
    /// posted around the resize exactly as a drag brackets it.
    @Test(arguments: [ThemeVoice.terminal, ThemeVoice.study])
    func aLiveResizeAtThePageTopKeepsTheTopAir(_ voice: ThemeVoice) async throws {
        try await withWindowedEditor(longNote(emptyAt: 30), voice: voice) { h, scrollView, window, _ in
            await scroll(scrollView, to: 300, h)
            await scroll(scrollView, to: 0, h)
            let firstBefore = try lineY(0, h, scrollView)
            try #require(firstBefore > 10, "the premise: the page rests in its top air")

            NotificationCenter.default.post(
                name: NSWindow.willStartLiveResizeNotification, object: window)
            var frame = window.frame
            frame.size.width -= 160
            window.setFrame(frame, display: true)
            await draw(h)
            NotificationCenter.default.post(
                name: NSWindow.didEndLiveResizeNotification, object: window)
            await draw(h)

            let firstAfter = try lineY(0, h, scrollView)
            #expect(
                abs(firstAfter - firstBefore) < 0.5,
                "\(voice): the live resize moved the first line \(firstBefore) → \(firstAfter) pt below the top")
        }
    }

    /// A RE-FONT (a voice switch — `keepingReadingPosition`'s park) with the
    /// page resting in its top air: the air stays. (The container's inset is
    /// the same in both voices, so "where it was" is the same number.)
    @Test(arguments: [ThemeVoice.terminal, ThemeVoice.study])
    func aRefontAtThePageTopKeepsTheTopAir(_ voice: ThemeVoice) async throws {
        try await withWindowedEditor(longNote(emptyAt: 30), voice: voice) { h, scrollView, _, coordinator in
            let firstBefore = try lineY(0, h, scrollView)
            try #require(firstBefore > 10, "the premise: the page rests in its top air")

            let other: ThemeVoice = voice == .terminal ? .study : .terminal
            EditorTypography.adopt(chrome(other).typography)
            coordinator.applyChrome(chrome(other), to: h.textView, scrollView: scrollView)
            await draw(h)

            let firstAfter = try lineY(0, h, scrollView)
            #expect(
                abs(firstAfter - firstBefore) < 0.5,
                "\(voice) → \(other): the re-font moved the first line \(firstBefore) → \(firstAfter) pt below the top")
        }
    }
}
