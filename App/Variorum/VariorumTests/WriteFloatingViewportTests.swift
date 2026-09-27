//
//  WriteFloatingViewportTests.swift
//  VariorumTests
//
//  18l-b UNIT U-B5 — KnownIssues row 88 (B5): *"⏎ right after a ⌘↓ landing
//  moves the page when a full re-render had invalidated the layout first."*
//  Measured in the app on the harness's full Study pass (`b5-return-after-
//  cmd-down`): the first visible line slid by ~440–660 pt of text under a clip
//  that never moved, and the new caret block went off-screen below.
//
//  ── THE TRACED MECHANISM (the U-B5 RECORD carries the instrumented runs) ──
//  1. A FULL re-render (the carve's `renderFull`) throws every layout fragment
//     back to an ESTIMATE; its exact restore lays out one island mid-note, and
//     ⌘↓ (`moveToEndOfDocument:`) lays out only the last page — which then
//     FLOATS on ~470 estimated paragraphs (the laid-out run directly above the
//     viewport is zero).
//  2. The tail ⏎ is the typed Return's `insertEmptyBlock` → the DIFFERENTIAL
//     structural rewrite: one storage edit (`"\n"` appended), no restore step
//     by design (2026-07-07: "untouched text never moves").
//  3. The first layout-forcing query after that edit which lays out the new
//     paragraph — with the editing ring on, `refreshDecorations` inside
//     TextKit's own selection fix (`_fixSelectionAfterChangeInCharacterRange:`
//     → `setSelectedRanges` → `updateCaretContext`), else the structural
//     result's badge/decoration refresh after it — makes TextKit re-estimate
//     the stretch above and RE-BASE the laid-out island in document space.
//     The clip is not moved (the jump road's viewport layout compensates by
//     moving the clip, 18k C6; an edit has no such pass), so the text above
//     the caret slides on screen.
//  Whether (and how far) TextKit re-bases depends on its layout history — the
//  app's full pass reproduces it every time, a fresh view never did. This rig
//  gives TextKit a whole-document layout first (the app's pass has laid most of
//  the story out by the time B5 fires), which is what makes it reproduce here:
//  measured in the rig on the pre-fix tree, both premises below hold.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Write keeps the lines above a tail ⏎ still on a floating viewport (18l-b U-B5 — KnownIssues row 88)", .serialized)
struct WriteFloatingViewportTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    /// `RefontViewportTests.draw`'s reason: a nested runloop pump cannot drain
    /// the main queue from a main-actor test body, and the settle hops are
    /// main-queue hops armed by a display pass.
    private func draw(_ h: EditorHarness) async {
        for _ in 0..<4 {
            h.textView.needsDisplay = true
            h.textView.window?.display()
            pump(0.02)
            try? await Task.sleep(for: .milliseconds(30))
        }
    }

    /// HER NOTE ITSELF: *A Scandal in Bohemia* exactly as the sample library
    /// seeds it (the recipe's note; real paragraph lengths are what TextKit
    /// estimates).
    private func scandal() throws -> [String] {
        let story = try #require(
            try SampleLibrarySeeder.loadStories().first { $0.title.contains("Scandal in Bohemia") },
            "the bundled Sherlock text carries A Scandal in Bohemia")
        return SegmentationRules.bulkSegments(story.text, mode: .paragraph)
    }

    /// Where the line holding `offset` sits below the viewport's top edge.
    private func lineY(_ offset: Int, _ h: EditorHarness, _ scrollView: NSScrollView) throws -> Double {
        let span = try #require(JumpPrimitive.lineSpan(ofOffset: offset, in: h.textView))
        return span.top - Double(scrollView.contentView.bounds.minY)
    }

    /// The layout fragments directly above the viewport's first that TextKit
    /// has really laid out (a run broken by the first estimate).
    private func laidOutRunAboveTheViewport(_ h: EditorHarness) -> Int? {
        guard let lm = h.textView.textLayoutManager,
              let start = lm.textViewportLayoutController.viewportRange?.location
        else { return nil }
        var run = 0
        var first = true
        lm.enumerateTextLayoutFragments(from: start, options: [.reverse]) { fragment in
            if first { first = false; return true }  // the viewport's own first fragment
            guard fragment.state == .layoutAvailable else { return false }
            run += 1
            return run < 3000
        }
        return run
    }

    /// **THE PIN — her B5, on the real roads end to end.** Her Write column's
    /// size, the REAL coordinator, the dev store's editing ring ON; the story
    /// laid out once (TextKit's history); then U0b's walk exactly: a blank line
    /// mid-note (a block's end) → ⏎ (an empty block below) → ⌫ (the carve — the
    /// full re-render) → ⌘↓ (the real selector) → ⏎ at the tail. The lines above
    /// the caret did not change, so none of them may move on screen.
    ///
    /// Terminal is a GUARD here (plain in the harness too — B5 never reproduced
    /// there: the monospace estimate is close to exact, so there is nothing to
    /// re-estimate); Study carries both premises that make it the B5 shape.
    @Test(arguments: [ThemeVoice.study, ThemeVoice.terminal])
    func aTailReturnOnAFloatingViewportLeavesTheLinesAboveItStill(_ voice: ThemeVoice) async throws {
        let current = EditorTypography.current
        let adopted = EditorTypography.isAdopted
        let palette = MarkdownStyling.palette
        defer {
            EditorTypography.current = current
            EditorTypography.isAdopted = adopted
            MarkdownStyling.palette = palette
        }
        let chrome = EditorSurfaceChrome(voice: voice, dark: false, inlineComments: false)
        try await withEditor(seedBlocks: try scandal()) { h in
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1209, height: 806),
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
            EditorTypography.adopt(chrome.typography)
            coordinator.applyChrome(chrome, to: h.textView, scrollView: scrollView)
            coordinator.install(scrollView: scrollView, textView: h.textView)
            await draw(h)
            h.model.appearance.indicator = .outline
            window.makeFirstResponder(h.textView)
            // TextKit's history: the whole story laid out once.
            let layoutManager = try #require(h.textView.textLayoutManager)
            layoutManager.ensureLayout(for: layoutManager.documentRange)
            await draw(h)

            // U0b's walk: a blank line mid-note (block 150's end) → ⏎ → ⌫.
            let blocks = try h.storeSlots().count
            JumpPrimitive.jump(
                toOffset: h.model.index.range(ofEntryAt: 144).location,
                textView: h.textView, scrollView: scrollView)
            await draw(h)
            h.textView.setSelectedRange(NSRange(
                location: h.model.index.range(ofEntryAt: 150).upperBound, length: 0))
            h.textView.insertNewline(nil)
            await h.flush()
            await draw(h)
            try #require(try h.storeSlots().count == blocks + 1, "the premise: ⏎ at a block's end made an empty block")
            h.textView.deleteBackward(nil)
            await h.flush()
            await draw(h)
            try #require(try h.storeSlots().count == blocks, "the premise: ⌫ carved it (the full re-render)")

            // ⌘↓ — the real selector the key sends.
            h.textView.moveToEndOfDocument(nil)
            await draw(h)
            await draw(h)
            let floating = try #require(laidOutRunAboveTheViewport(h))
            #expect(floating == 0,
                    "the premise: the viewport's laid-out island FLOATS on estimates (laid-out run above it: \(floating))")
            let reference = try #require(h.model.topVisibleOffset(), "the end landing resolves a reading line")
            let before = try lineY(reference, h, scrollView)
            let usageBefore = Double(layoutManager.usageBoundsForTextContainer.height)

            // ⏎ at the tail — the typed Return's differential rewrite.
            h.textView.insertNewline(nil)
            await h.flush()
            await draw(h)

            #expect(try h.storeSlots().count == blocks + 1, "the premise: the tail ⏎ minted the empty block below")
            let after = try lineY(reference, h, scrollView)
            let usageAfter = Double(layoutManager.usageBoundsForTextContainer.height)
            if voice == .study {
                // The B5 shape: TextKit re-estimated the stretch above — the
                // document grew by far more than the one new line. Without it
                // the pin could pass on a quiet road and prove nothing.
                let line = TypewriterRoom.lineHeight(of: EditorDocument.baseFont)
                #expect(usageAfter - usageBefore > 3 * line,
                        "the premise: TextKit re-estimated the estimated stretch (usage \(usageBefore) → \(usageAfter), one line is \(line))")
            }
            #expect(
                abs(after - before) < 0.5,
                "\(voice): the line the viewport was reading moved \(before) → \(after) pt from the top on a ⏎ that wrote nothing above it (usage \(usageBefore) → \(usageAfter))")
        }
    }
}

// MARK: - The keeper's own contract (landed WITH the fix; the pin above is the red-first one)

@MainActor
@Suite("The differential road's keeper holds only untouched lines that moved (18l-b U-B5)", .serialized)
struct UntouchedLineKeeperTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func draw(_ h: EditorHarness) async {
        for _ in 0..<4 {
            h.textView.needsDisplay = true
            h.textView.window?.display()
            pump(0.02)
            try? await Task.sleep(for: .milliseconds(30))
        }
    }

    private func lineY(_ offset: Int, _ h: EditorHarness, _ scrollView: NSScrollView) throws -> Double {
        let span = try #require(JumpPrimitive.lineSpan(ofOffset: offset, in: h.textView))
        return span.top - Double(scrollView.contentView.bounds.minY)
    }

    /// **The pure rule.** A line is the keeper's only when it starts strictly
    /// BEFORE the edit (text the act did not write — and whose place the act
    /// does not move); its displacement is where it sits now less where it sat.
    @Test func theRuleIsTheLinesStartBeforeTheEditAndItsScreenPlace() {
        let anchor = ReadingAnchor(offset: 100, inset: 12, inPageTopAir: false)
        #expect(anchor.isUntouched(byEditAt: 101))
        #expect(anchor.isUntouched(byEditAt: 5_000))
        #expect(!anchor.isUntouched(byEditAt: 100), "an edit AT the line's start writes before it — the act moves it")
        #expect(!anchor.isUntouched(byEditAt: 40), "an edit above the line is the act's own movement")
        #expect(anchor.displacement(lineTop: 1_012, viewportTop: 1_000) == 0, "sitting where it sat")
        #expect(anchor.displacement(lineTop: 1_092, viewportTop: 1_000) == 80, "TextKit re-based it 80 pt down")
        #expect(anchor.displacement(lineTop: 1_092, viewportTop: 1_080) == 0, "the clip followed — nothing to keep")
        let cut = ReadingAnchor(offset: 7, inset: -9.5, inPageTopAir: false)
        #expect(cut.displacement(lineTop: 490.5, viewportTop: 500) == 0, "an edge that cuts the line keeps its cut")
    }

    /// Her story, her column, the ring on, the story laid out once (TextKit's
    /// history), the page mid-note; `carve` runs U0b's ⏎ + ⌫ there (the full
    /// re-render that makes the end island FLOAT); then ⌘↓. Returns the
    /// reading line's offset and place before the tail ⏎, and after it.
    private func tailReturn(
        carve: Bool, _ body: @MainActor (EditorHarness, NSScrollView, Int, Double, Double) throws -> Void
    ) async throws {
        let current = EditorTypography.current
        let adopted = EditorTypography.isAdopted
        let palette = MarkdownStyling.palette
        defer {
            EditorTypography.current = current
            EditorTypography.isAdopted = adopted
            MarkdownStyling.palette = palette
        }
        let chrome = EditorSurfaceChrome(voice: .study, dark: false, inlineComments: false)
        let story = try #require(
            try SampleLibrarySeeder.loadStories().first { $0.title.contains("Scandal in Bohemia") })
        try await withEditor(seedBlocks: SegmentationRules.bulkSegments(story.text, mode: .paragraph)) { h in
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 1209, height: 806),
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
            EditorTypography.adopt(chrome.typography)
            coordinator.applyChrome(chrome, to: h.textView, scrollView: scrollView)
            coordinator.install(scrollView: scrollView, textView: h.textView)
            await draw(h)
            h.model.appearance.indicator = .outline
            window.makeFirstResponder(h.textView)
            let layoutManager = try #require(h.textView.textLayoutManager)
            layoutManager.ensureLayout(for: layoutManager.documentRange)
            await draw(h)
            JumpPrimitive.jump(
                toOffset: h.model.index.range(ofEntryAt: 144).location,
                textView: h.textView, scrollView: scrollView)
            await draw(h)
            if carve {
                h.textView.setSelectedRange(NSRange(
                    location: h.model.index.range(ofEntryAt: 150).upperBound, length: 0))
                h.textView.insertNewline(nil)
                await h.flush()
                await draw(h)
                h.textView.deleteBackward(nil)
                await h.flush()
                await draw(h)
            }
            h.textView.moveToEndOfDocument(nil)
            await draw(h)
            await draw(h)
            let reference = try #require(h.model.topVisibleOffset())
            let before = try lineY(reference, h, scrollView)
            h.textView.insertNewline(nil)
            await h.flush()
            await draw(h)
            try body(h, scrollView, reference, before, try lineY(reference, h, scrollView))
        }
    }

    /// **The witness, both ways.** On B5's road (the island floats) TextKit
    /// moves the reading line and the keeper puts it back — exactly once; on a
    /// page that does NOT float (no full re-render before ⌘↓, so the end sits
    /// on laid-out text) nothing moves and the keeper never runs.
    @Test(arguments: [true, false])
    func theKeeperRunsExactlyWhereTextKitMovedTheLine(_ carve: Bool) async throws {
        try await tailReturn(carve: carve) { h, _, _, before, after in
            #expect(abs(after - before) < 0.5, "the reading line held (\(before) → \(after))")
            #expect(h.model.untouchedLineRestores == (carve ? 1 : 0),
                    "carve \(carve): the keeper ran \(h.model.untouchedLineRestores) time(s)")
        }
    }

    /// **The fence — the act's own movement is shipped.** A ⏎ at the END of a
    /// block ABOVE the viewport's reading line (the caret put there without
    /// scrolling) inserts an empty block above that line: the act MOVES it,
    /// one block down, and the keeper must stay out (the line starts after the
    /// edit). A synthetic note, every line laid out (settled geometry).
    @Test func anActThatWritesAboveTheReadingLineKeepsItsOwnMovement() async throws {
        let note = (0..<80).map { p in
            (0..<(18 + (p &* 29) % 40)).map { "word\(($0 &+ p) % 409)" }.joined(separator: " ") + " ¶\(p)."
        }
        try await withEditor(seedBlocks: note) { h in
            let window = NSWindow(
                contentRect: NSRect(x: 80, y: 80, width: 900, height: 700),
                styleMask: [.titled, .resizable], backing: .buffered, defer: false)
            window.isReleasedWhenClosed = false
            let scrollView = try #require(h.textView.enclosingScrollView)
            defer {
                window.orderOut(nil)
                window.close()
            }
            window.contentView = scrollView
            window.orderFrontRegardless()
            pump()
            let layoutManager = try #require(h.textView.textLayoutManager)
            layoutManager.ensureLayout(for: layoutManager.documentRange)
            await draw(h)
            JumpPrimitive.jump(
                toOffset: h.model.index.range(ofEntryAt: 40).location,
                textView: h.textView, scrollView: scrollView)
            await draw(h)
            let reference = try #require(h.model.topVisibleOffset())
            let before = try lineY(reference, h, scrollView)
            // Block 30's end is above the viewport: the caret goes there, the
            // page does not move, and ⏎ makes the empty block below IT.
            let blocks = try h.storeSlots().count
            h.textView.setSelectedRange(NSRange(
                location: h.model.index.range(ofEntryAt: 30).upperBound, length: 0))
            h.textView.insertNewline(nil)
            await h.flush()
            await draw(h)
            #expect(try h.storeSlots().count == blocks + 1, "the premise: the empty block was made")
            // The reference's TEXT moved one character on (the separator); its
            // line moved down by the new block's line.
            let after = try lineY(reference + 1, h, scrollView)
            // (Measured: exactly one empty block's line — 10.0 pt in this harness's
            // default typography.)
            #expect(after - before >= 5, "the act pushed the line down (\(before) → \(after)) — shipped")
            #expect(h.model.untouchedLineRestores == 0, "the keeper stayed out of a line the act moved")
        }
    }
}
