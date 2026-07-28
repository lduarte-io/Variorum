//
//  PhantomSpaceTests.swift
//  VariorumTests
//
//  Phase 13c, Batch 1C — the A46 investigation ("clicking does nothing at
//  all — it couldn't move your cursor into the phantom space and the down
//  arrow couldn't move you down either. nothing was actually there.") and
//  the memo's option-E MEASUREMENT.
//
//  THE VERDICT, measured in real windows through the real event route: the
//  phantom space below a post's last line is NOT a dead region. A click
//  there hits the editor's own text view and lands the caret at the END of
//  the document, which is what a text view is supposed to do with a click
//  over space that is not text — and it is also, precisely, "it couldn't
//  move your cursor INTO the phantom space." The down-arrow half was
//  already agreed correct. So the thing to remove is the PHANTOM, not a
//  hit-test bug: see `notes/plans/phase-13c-memo-block-extent.md` Q3.
//
//  What the batch DID find dead: a constant 6 pt strip at the very bottom
//  of every NSScrollView, where the clip view stops routing to the document
//  view. It reproduces on a VANILLA TK2 NSTextView with no Variorum code in
//  the picture (`theBottomStripIsAppKitsNotOurs`), so it is the platform's,
//  not ours — but it is pinned at its measured size so that if this class
//  ever grows from "a sliver above the commit bar" into the "paragraphs of
//  empty space" she reported, a test says so before she does (P-7).
//
//  These are CHARACTERIZATION pins, deliberately not red-on-old fixes: the
//  hallucination guard's own rule is that a finding whose mechanism does not
//  trace to the symptom is recorded and dismissed, never fixed.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Phantom space & the A46 click (13c 1C)", .serialized)
struct PhantomSpaceTests {
    private func pump(_ turns: Int = 3) {
        for _ in 0..<turns {
            RunLoop.main.run(until: Date().addingTimeInterval(0.03))
        }
    }

    /// 60 short blocks with ONE very long one in the middle — the corpus the
    /// 1A appendix measured the over-estimate on.
    private func corpus(longWords: Int = 3000, at index: Int = 30) -> [String] {
        var blocks = (0..<60).map { "short block \($0) of text here" }
        blocks[index] = (0..<longWords).map { "longword\($0 % 97)" }.joined(separator: " ")
        return blocks
    }

    private func mount(
        _ h: EditorHarness, height: CGFloat = 600, width: CGFloat = 760
    ) throws -> (NSScrollView, NSWindow) {
        let scrollView = try #require(h.textView.enclosingScrollView)
        scrollView.frame = NSRect(x: 0, y: 0, width: width, height: height)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = NSView(frame: NSRect(x: 0, y: 0, width: width, height: height))
        window.contentView?.addSubview(scrollView)
        window.makeKeyAndOrderFront(nil)
        window.layoutIfNeeded()
        window.display()
        pump()
        window.makeFirstResponder(h.textView)
        return (scrollView, window)
    }

    /// The view-space bottom of the last line the layout has actually drawn.
    private func lastTextBottom(_ textView: NSTextView) -> CGFloat {
        guard let layoutManager = textView.textLayoutManager else { return 0 }
        var bottom: CGFloat = 0
        layoutManager.enumerateTextLayoutFragments(from: nil, options: []) { fragment in
            if fragment.state == .layoutAvailable,
               let line = fragment.textLineFragments.last {
                bottom = max(
                    bottom,
                    fragment.layoutFragmentFrame.minY + line.typographicBounds.maxY)
            }
            return true
        }
        return bottom + textView.textContainerInset.height
    }

    /// A real click through the window's own hit-testing + event route. The
    /// mouse-up is posted first so NSTextView's tracking loop exits at once.
    /// Returns the view the click actually landed on.
    private func click(_ window: NSWindow, _ view: NSView, at point: CGPoint) -> NSView? {
        let inWindow = view.convert(point, to: nil)
        // `hitTest` takes a point in the RECEIVER'S SUPERVIEW space. This
        // used to convert into the content view's OWN space, which on a
        // titled window is a titlebar's worth off — harmless while the text
        // view covered everything below the last line, and exposed the
        // moment 13d's typewriter room put something else down there.
        let target = window.contentView?.hitTest(
            window.contentView!.superview!.convert(inWindow, from: nil))
        func event(_ type: NSEvent.EventType) -> NSEvent? {
            NSEvent.mouseEvent(
                with: type, location: inWindow, modifierFlags: [],
                timestamp: ProcessInfo.processInfo.systemUptime,
                windowNumber: window.windowNumber, context: nil,
                eventNumber: 0, clickCount: 1,
                pressure: type == .leftMouseDown ? 1 : 0)
        }
        guard let down = event(.leftMouseDown), let up = event(.leftMouseUp) else { return nil }
        NSApp.postEvent(up, atStart: true)
        target?.mouseDown(with: down)
        pump(1)
        return target
    }

    /// **A46, answered.** The space below the last line — the phantom she
    /// reported — is the editor's own text view, and clicking it moves the
    /// caret to the end of the document. It cannot put the caret *inside*
    /// the phantom because there is no text there; that is the report, and
    /// it is correct behaviour, not a dead click.
    @Test func aClickInThePhantomLandsTheCaretAtTheDocumentEnd() async throws {
        try await withEditor(seedBlocks: corpus()) { h in
            let (scrollView, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }
            let textView = h.textView
            let viewport = scrollView.frame.height

            // One move to the bottom, never visiting the long block — the
            // state in which the document's height still carries the
            // estimate error.
            scrollView.contentView.scroll(
                to: CGPoint(x: 0, y: textView.frame.height - viewport))
            scrollView.reflectScrolledClipView(scrollView.contentView)
            window.displayIfNeeded()
            pump()

            let bottomOfText = lastTextBottom(textView)
            let clip = scrollView.contentView.bounds
            #expect(clip.maxY > bottomOfText,
                    "the reproduction needs empty space below the last line")

            textView.setSelectedRange(NSRange(location: 0, length: 0))
            // Probe the MIDDLE of the phantom rather than a fixed 20 pt
            // below the last line: the phantom's own bottom few points are
            // AppKit's non-routing sliver (this suite's
            // `theBottomStripIsAppKitsNotOurs`), and 13d's typewriter room
            // changed where the scroll settles, which put the old fixed
            // probe inside it. A construction detail — the BEHAVIOUR under
            // test is unchanged, and the room is provably not a variable in
            // it (`TypewriterRoomTests.theRoomNeverStealsAClickOverHerText`
            // holds the general form).
            let phantom = textView.frame.height - bottomOfText
            #expect(phantom > 8, "the reproduction needs a phantom to click in (\(phantom) pt)")
            let probe = CGPoint(x: 380, y: bottomOfText + phantom / 2)
            let target = click(window, textView, at: probe)
            #expect(target === textView,
                    "the phantom belongs to the editor — a click there must reach it, not fall through to the scroll view's background")
            #expect(textView.selectedRange().location == (textView.string as NSString).length,
                    "a click below the last line lands the caret at the document end")
        }
    }

    /// The one region that genuinely does not route ANYWHERE: a thin strip
    /// at the very bottom of the scroll view. Pinned at its measured size —
    /// if this class ever grows into the "paragraphs of empty space" A46
    /// described, this fails first (P-7).
    ///
    /// **13d batch 5 (A22) re-scoped what "dead" means, and the re-scoping
    /// is the point.** Below the last line there are now TWO regions: the
    /// phantom (inside the document — the text view's) and the typewriter
    /// room (below it — the scroll view's, which lands the caret at the end
    /// of the text). Both ROUTE, so neither is dead; what this walks for is
    /// the strip that routes to neither. The un-re-scoped version of this
    /// pin fired at 483 pt the moment the room shipped — which is exactly
    /// what it was written to do, and it caught a real defect in the room's
    /// first mechanism on the way (see `TypewriterScrollView`).
    @Test func theDeadStripAtTheBottomOfTheScrollViewStaysASliver() async throws {
        try await withEditor(seedBlocks: ["alpha beta", "gamma delta"]) { h in
            let (scrollView, window) = try mount(h, height: 500)
            defer { window.orderOut(nil); window.close() }
            let textView = h.textView
            let clip = scrollView.contentView.bounds

            // Walk up from the bottom of the visible rect until a point
            // routes somewhere that acts on it.
            var dead: CGFloat = 0
            while dead < clip.height {
                let point = CGPoint(x: 380, y: clip.maxY - dead - 0.5)
                let inWindow = textView.convert(point, to: nil)
                let hit = window.contentView?.hitTest(
                    window.contentView!.superview!.convert(inWindow, from: nil))
                if hit === textView || hit === scrollView { break }
                dead += 1
            }
            #expect(dead <= 8,
                    "the un-routed strip at the bottom of the editor is \(dead) pt — a sliver above the commit bar, never a readable band of page")

            // (That the ROOM itself routes and lands the caret is
            // `TypewriterRoomTests`' — here the short document fills the
            // viewport, so the room sits below the visible area entirely.)
        }
    }

    /// …and it is AppKit's, not ours: a vanilla TK2 text view in a vanilla
    /// scroll view, configured the way Apple documents, has the same strip.
    /// (Recorded so nobody hunts a Variorum cause for it again.)
    @Test func theBottomStripIsAppKitsNotOurs() async throws {
        let height: CGFloat = 400
        let textView = NSTextView(usingTextLayoutManager: true)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.size = NSSize(
            width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.string = "hello"
        let scrollView = NSScrollView(
            frame: NSRect(x: 0, y: 0, width: 600, height: height))
        scrollView.hasVerticalScroller = true
        scrollView.documentView = textView
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: height),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: height))
        window.contentView?.addSubview(scrollView)
        window.makeKeyAndOrderFront(nil)
        window.layoutIfNeeded()
        window.display()
        pump()
        defer { window.orderOut(nil); window.close() }

        let gap = scrollView.contentView.bounds.height - textView.frame.height
        #expect(gap > 0 && gap <= 8,
                "vanilla AppKit leaves \(gap) pt of clip the document view never covers")
    }

    /// **The memo's Part 2, pinned:** TK2 over-reports a long block's height
    /// until the block is laid out, and the error is set by the SINGLE
    /// longest block — the mechanism behind the phantom.
    @Test func aLongBlockOverReportsItsHeightUntilItIsLaidOut() async throws {
        try await withEditor(seedBlocks: corpus()) { h in
            let (_, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }
            let layoutManager = try #require(h.textView.textLayoutManager)
            let contentManager = try #require(layoutManager.textContentManager)
            let range = h.model.index.range(ofEntryAt: 30)
            let start = try #require(contentManager.location(
                contentManager.documentRange.location, offsetBy: range.location))
            let end = try #require(contentManager.location(
                contentManager.documentRange.location, offsetBy: range.upperBound))

            func longBlock() -> (height: CGFloat, laidOut: Bool) {
                var result: (CGFloat, Bool) = (0, false)
                layoutManager.enumerateTextLayoutFragments(
                    from: start, options: []
                ) { fragment in
                    result = (fragment.layoutFragmentFrame.height,
                              fragment.state == .layoutAvailable)
                    return false
                }
                return result
            }

            let estimated = longBlock()
            #expect(!estimated.laidOut, "the long block starts as an estimate")
            layoutManager.ensureLayout(for: try #require(NSTextRange(location: start, end: end)))
            let measured = longBlock()
            #expect(measured.laidOut)
            #expect(measured.height < estimated.height,
                    "the estimate over-reports: \(estimated.height) → \(measured.height)")
        }
    }

    /// **MEMO OPTION E — the measurement, not a build.** Laying out ONE long
    /// block's own text range costs work proportional to that BLOCK, and the
    /// per-word rate is flat across block sizes (P1's actual requirement).
    /// Numbers print for the memo; the assertion guards the SHAPE.
    @Test(arguments: [1000, 3000, 12000, 25000])
    func layingOutOneLongBlockCostsOneBlockNotTheDocument(words: Int) async throws {
        try await withEditor(seedBlocks: corpus(longWords: words)) { h in
            let (scrollView, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }
            let textView = h.textView
            let layoutManager = try #require(textView.textLayoutManager)
            let contentManager = try #require(layoutManager.textContentManager)
            let range = h.model.index.range(ofEntryAt: 30)
            let start = try #require(contentManager.location(
                contentManager.documentRange.location, offsetBy: range.location))
            let end = try #require(contentManager.location(
                contentManager.documentRange.location, offsetBy: range.upperBound))
            let blockRange = try #require(NSTextRange(location: start, end: end))

            func fragment() -> (height: CGFloat, laidOut: Bool) {
                var result: (CGFloat, Bool) = (0, false)
                layoutManager.enumerateTextLayoutFragments(from: start, options: []) { f in
                    result = (f.layoutFragmentFrame.height, f.state == .layoutAvailable)
                    return false
                }
                return result
            }

            let before = fragment()
            let started = ContinuousClock.now
            layoutManager.ensureLayout(for: blockRange)
            let elapsed = started.duration(to: .now)
            let ms = Double(elapsed.components.seconds) * 1000
                + Double(elapsed.components.attoseconds) / 1e15
            let after = fragment()

            // Does the effect survive scrolling away and back?
            let viewport = scrollView.frame.height
            scrollView.contentView.scroll(
                to: CGPoint(x: 0, y: max(0, textView.frame.height - viewport)))
            scrollView.reflectScrolledClipView(scrollView.contentView)
            window.displayIfNeeded()
            pump()
            scrollView.contentView.scroll(to: .zero)
            scrollView.reflectScrolledClipView(scrollView.contentView)
            window.displayIfNeeded()
            pump()
            let travelled = fragment()

            print("13c 1C option E [\(words)w]: \(String(format: "%.2f", ms)) ms · "
                + "block \(before.height) → \(after.height) pt "
                + "(phantom removed \(before.height - after.height) pt) · "
                + "still laid out after travel: \(travelled.laidOut) · "
                + "\(String(format: "%.2f", ms / Double(words) * 1000)) ms per 1k words")

            #expect(!before.laidOut && after.laidOut)
            #expect(after.height < before.height, "the phantom collapses for that block")
            #expect(travelled.laidOut,
                    "the effect must survive scrolling away and back, or E would have to be re-done")
            // Debug build, generous: the shape that matters is per-word cost
            // flat in BLOCK size (never document size). Phase 6's measured
            // full-document rate is 105 ms / 50k words = 2.1 ms per 1k.
            #expect(ms / Double(words) * 1000 < 6.0,
                    "\(String(format: "%.2f", ms / Double(words) * 1000)) ms per 1k words")
        }
    }
}
