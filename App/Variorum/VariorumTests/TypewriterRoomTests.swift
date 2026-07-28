//
//  TypewriterRoomTests.swift
//  VariorumTests
//
//  13d batch 5 — **A22, typewriter room** (author ruling, the 2026-07-28
//  sitting): about one viewport-page of scrollable allowance below the last
//  line of Write's full-document editor, ALWAYS ON, and a click in the room
//  lands the caret at the end of the text. "The room is space, not paper" —
//  so these pins hold both halves: the room EXISTS (and is reachable), and
//  it is not content (no stored byte moves, and the ratified edge-trimming
//  rules are untouched).
//

import AppKit
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("A22 — typewriter room (13d batch 5)", .serialized)
struct TypewriterRoomTests {
    private func pump(_ turns: Int = 4) {
        for _ in 0..<turns {
            RunLoop.main.run(until: Date().addingTimeInterval(0.03))
        }
    }

    // MARK: The rule, pure

    /// One viewport-page LESS ONE LINE — so at maximum scroll her last line
    /// sits at the top of the window rather than one pixel above it. The
    /// subtraction is the whole difference between room she can type into
    /// and room that has swallowed the text.
    @Test func theRoomIsAViewportLessOneLine() {
        #expect(TypewriterRoom.height(viewport: 800, lineHeight: 20) == 780)
        // Degenerate viewports never produce negative room.
        #expect(TypewriterRoom.height(viewport: 10, lineHeight: 20) == 0)
        #expect(TypewriterRoom.height(viewport: 0, lineHeight: 20) == 0)
        #expect(TypewriterRoom.height(viewport: 100, lineHeight: -5) == 100)

        // The line comes from the FONT's own metrics — never
        // NSLayoutManager.defaultLineHeight (a TK1 API; TEXTKIT2 §4).
        let font = NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        let line = TypewriterRoom.lineHeight(of: font)
        #expect(line >= font.ascender - font.descender)
        #expect(line > 0)
    }

    // MARK: The room, mounted

    /// The mechanism, measured rather than asserted: the scroll view carries
    /// the room as a bottom content inset, the clip's own height is NOT
    /// reduced by it (a shrunken viewport would be a defect, not a feature),
    /// and the constrained scroll range grows by exactly the room.
    @Test func theEditorCarriesAViewportOfRoomWithoutShrinkingTheViewport() async throws {
        let (scrollView, textView) = EditorTextView.makeEditor()
        let typewriter = try #require(scrollView as? TypewriterScrollView)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentView = scrollView
        scrollView.frame = NSRect(x: 0, y: 0, width: 600, height: 400)
        textView.string = (1...200)
            .map { "Paragraph \($0) with some words in it." }.joined(separator: "\n")
        window.layoutIfNeeded()
        pump()

        let clipHeight = scrollView.contentView.bounds.height
        let expected = TypewriterRoom.height(
            viewport: clipHeight, lineHeight: TypewriterRoom.lineHeight(of: EditorDocument.baseFont))
        #expect(expected > 100, "a 400pt viewport really does buy real room")
        #expect(abs(typewriter.typewriterRoom - expected) < 1)
        #expect(abs(clipHeight - 400) < 1,
                "the viewport is NOT shrunk by the room (clip \(clipHeight))")
        #expect(scrollView.contentInsets.bottom == 0,
                "the room is an ALLOWANCE, not a content inset — the inset mechanism was measured to break hit testing over her own visible text (see TypewriterScrollView)")

        // The scrollable range grew by exactly the room.
        func maxScroll() -> CGFloat {
            scrollView.contentView.constrainBoundsRect(
                NSRect(x: 0, y: 100_000,
                       width: scrollView.contentView.bounds.width,
                       height: scrollView.contentView.bounds.height)).origin.y
        }
        let withRoom = maxScroll()
        typewriter.typewriterRoomEnabled = false
        typewriter.updateTypewriterRoom()
        window.layoutIfNeeded()
        pump(2)
        let withoutRoom = maxScroll()
        #expect(typewriter.typewriterRoom == 0)
        #expect(abs((withRoom - withoutRoom) - expected) < 1,
                "the room is exactly the extra scroll (\(withoutRoom) → \(withRoom))")

        window.contentView = nil
    }

    /// The room follows the window: a resize re-computes it, and a pass that
    /// changes nothing writes nothing (the change-gate — a setting that
    /// chases its own layout is the loop class this phase keeps closing).
    @Test func theRoomFollowsTheViewportAndAStablePassWritesNothing() async throws {
        let (scrollView, _) = EditorTextView.makeEditor()
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.borderless], backing: .buffered, defer: false)
        window.contentView = scrollView
        window.layoutIfNeeded()
        pump()
        let typewriter0 = try #require(scrollView as? TypewriterScrollView)
        let tall = typewriter0.typewriterRoom

        window.setContentSize(NSSize(width: 600, height: 200))
        window.layoutIfNeeded()
        pump()
        let short = typewriter0.typewriterRoom
        #expect(short < tall, "a shorter window means less room (\(tall) → \(short))")

        // …and re-running the update on an unchanged viewport is a no-op.
        typewriter0.updateTypewriterRoom()
        typewriter0.updateTypewriterRoom()
        #expect(typewriter0.typewriterRoom == short)

        window.contentView = nil
    }

    /// **Her ruling's second half: a click in the room lands the caret at the
    /// end of the text.** Two halves, both pinned: the room is HIT-TESTABLE
    /// to the scroll view (measured: without the override a background view
    /// inside the scroll view swallows it), and the click's handler lands the
    /// caret through the text view's own insertion-point arithmetic — which
    /// for a point past every line IS the end, the same answer a click in the
    /// phantom gives (batch 1C).
    ///
    /// **Stated rather than claimed:** AppKit's OWN delivery of a synthesized
    /// mouse-down could not be driven in this test host — `NSApp.sendEvent`
    /// and `window.sendEvent` both leave the caret untouched here (measured,
    /// with the hit test already answering correctly), so the pin invokes the
    /// handler the hit test selects. What is unpinned is AppKit's routing,
    /// not our code.
    @Test func aClickInTheRoomLandsTheCaretAtTheEndOfTheText() async throws {
        let (scrollView, textView) = EditorTextView.makeEditor()
        let typewriter = try #require(scrollView as? TypewriterScrollView)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.contentView = scrollView
        textView.string = (1...200)
            .map { "Paragraph \($0) with some words in it." }.joined(separator: "\n")
        window.makeKeyAndOrderFront(nil)
        window.layoutIfNeeded()
        pump()

        let clip = scrollView.contentView
        let maxY = clip.constrainBoundsRect(
            NSRect(x: 0, y: 100_000, width: clip.bounds.width, height: clip.bounds.height)).origin.y
        clip.scroll(to: NSPoint(x: 0, y: maxY))
        scrollView.reflectScrolledClipView(clip)
        pump()

        textView.setSelectedRange(NSRange(location: 0, length: 0))
        let roomPoint = NSPoint(x: 100, y: textView.frame.maxY + 40)
        #expect(clip.bounds.contains(roomPoint), "the probe point really is visible room")
        let inWindow = clip.convert(roomPoint, to: nil)

        // (a) the room routes to us — the half that had to be built.
        let superPoint = try #require(scrollView.superview).convert(inWindow, from: nil)
        #expect(typewriter.hitTest(superPoint) === typewriter,
                "the room is hit-testable; without this the click is dropped entirely")
        // …and everything else still routes as AppKit intends.
        let textPointInWindow = clip.convert(
            NSPoint(x: 100, y: clip.bounds.minY + 5), to: nil)
        let overText = try #require(scrollView.superview).convert(textPointInWindow, from: nil)
        #expect(typewriter.hitTest(overText) !== typewriter,
                "a point over the TEXT still belongs to the text view")

        // (b) the handler lands the caret at the end of the text.
        let click = try #require(NSEvent.mouseEvent(
            with: .leftMouseDown, location: inWindow, modifierFlags: [], timestamp: 0,
            windowNumber: window.windowNumber, context: nil, eventNumber: 0,
            clickCount: 1, pressure: 1))
        typewriter.mouseDown(with: click)
        pump()

        #expect(textView.selectedRange()
            == NSRange(location: (textView.string as NSString).length, length: 0),
            "the caret lands at the END of the text — 'the room is space, not paper'")
        #expect(window.firstResponder === textView, "…and the editor took the keyboard")

        window.contentView = nil
    }

    /// **THE PIN THIS BATCH EARNED THE HARD WAY.** The first mechanism
    /// (`contentInsets.bottom`) measured perfectly on scroll range, viewport
    /// height and scroller proportion — and silently made every click below
    /// the top ~17 pt of the viewport miss the text view, at depths where
    /// her prose was VISIBLY DRAWN. Nothing in the room's own pins could
    /// see it, because they only ever asked about the room. So this asks the
    /// opposite question, permanently: **wherever text is drawn, a click
    /// still reaches the editor.**
    @Test func theRoomNeverStealsAClickOverHerText() async throws {
        let (scrollView, textView) = EditorTextView.makeEditor()
        let typewriter = try #require(scrollView as? TypewriterScrollView)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.contentView = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        scrollView.frame = NSRect(x: 0, y: 0, width: 600, height: 400)
        window.contentView?.addSubview(scrollView)
        textView.string = (1...200)
            .map { "Paragraph \($0) with some words in it." }.joined(separator: "\n")
        window.makeKeyAndOrderFront(nil)
        window.layoutIfNeeded()
        window.display()
        pump()

        #expect(typewriter.typewriterRoom > 0, "the room is on for this pin to mean anything")
        let clip = scrollView.contentView
        // Walk the viewport in 25pt steps: every step that sits over the
        // DOCUMENT must hit the text view; only steps past its end may be
        // the room's.
        var overDocument = 0
        for depth in stride(from: 4.0, to: clip.bounds.height, by: 25.0) {
            let inClip = NSPoint(x: 300, y: clip.bounds.minY + depth)
            let overText = inClip.y < (scrollView.documentView?.frame.maxY ?? 0)
            guard overText else { continue }
            overDocument += 1
            let inWindow = clip.convert(inClip, to: nil)
            let hit = try #require(scrollView.superview).hitTest(
                try #require(scrollView.superview).convert(inWindow, from: nil))
            #expect(hit === textView,
                    "a click \(depth) pt down the viewport is over her text and must reach the editor (hit \(hit.map { String(describing: type(of: $0)) } ?? "nil"))")
        }
        #expect(overDocument > 10, "non-vacuity: the walk really covered the page")

        window.contentView = nil
    }

    /// The INLINE editor (the book view's, inside someone else's scroll) is
    /// deliberately untouched: her ask and the A47b story are both the post
    /// editor, and a per-post inline surface with a page of room below each
    /// one would be a different feature nobody ruled.
    @Test func onlyWritesFullDocumentEditorCarriesTheRoom() {
        let (scrollView, _) = EditorTextView.makeEditor()
        #expect(scrollView is TypewriterScrollView)
        let inline = EditorTextView.makeInlineEditor()
        #expect(inline.enclosingScrollView == nil,
                "the inline editor has no scroll view of its own to inset")
    }

    // MARK: The room is ALLOWANCE, never content

    /// Zero stored bytes: the room writes nothing, and the ratified
    /// edge-trimming rules stay exactly as they were — which is the OTHER
    /// half of her ruling ("should we just stop trimming?" → no; the room is
    /// the real answer). A whitespace-only tail still never mints.
    @Test func theRoomStoresNothingAndTheTrimmingRulesAreUntouched() async throws {
        try await withEditor(seedBlocks: ["alpha", "beta"]) { h in
            func snapshot() throws -> (text: String, rows: [String], outbox: Int) {
                try h.database.read { db in
                    (try Queries.renderedText(db, containerID: h.postID),
                     try String.fetchAll(db, sql: "SELECT working_text FROM variant ORDER BY id"),
                     try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? -1)
                }
            }
            let before = try snapshot()

            // Mount, scroll into the room, click in it — the whole gesture.
            let scrollView = try #require(h.textView.enclosingScrollView as? TypewriterScrollView)
            scrollView.updateTypewriterRoom()
            let clip = scrollView.contentView
            clip.scroll(to: NSPoint(x: 0, y: 100_000))
            scrollView.reflectScrolledClipView(clip)
            await h.flush()

            let after = try snapshot()
            #expect(after == before, "the room moved not one stored byte")

            // And the ratified edge rule still holds: newlines typed past the
            // last block are an open tail, and a whitespace-only tail NEVER
            // mints (the very rule that made her hand-built room evaporate —
            // deliberately unchanged, because A22 replaces the need for it).
            h.type("\n\n\n", at: (h.textView.string as NSString).length)
            await h.model.idleMintTail()
            await h.flush()
            #expect(try h.storeSlots().compactMap(\.text) == ["alpha", "beta\n\n\n"],
                    "unchanged by A22: no new BLOCK is minted from a whitespace-only tail (the ratified never-mints rule), while the run itself attaches to the preceding block as ordinary trailing content (the 2026-07-12 spacing ruling's k−1 ownership). Both rules stand exactly as they were — the room replaces the NEED to type them, it does not change what typing them does")
        }
    }

    /// The hybrid jump still lands TEXT correctly with room below it — the
    /// room enlarges `maxScroll`, and the Phase 6 primitive's correction loop
    /// is measurement-driven, so the landing stays exact.
    @Test func theJumpStillLandsTheTargetWithRoomBelow() async throws {
        try await withEditor(seedBlocks: (1...40).map { "Block \($0) of the post." }) { h in
            let scrollView = try #require(h.textView.enclosingScrollView)
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
                styleMask: [.borderless], backing: .buffered, defer: false)
            window.contentView = scrollView
            window.layoutIfNeeded()
            pump()

            // A target comfortably inside the scrollable range (a target
            // BELOW it clamps for the ordinary reason — there is not a
            // viewport of document left under it — which is not what this
            // pin is about).
            let typewriter = try #require(scrollView as? TypewriterScrollView)
            let target = h.model.index.range(ofEntryAt: 10).location
            h.model.restoreTopVisibleOffset(target)
            pump()
            let landed = try #require(h.model.topVisibleOffset())
            #expect(abs(landed - target) <= 2,
                    "the jump lands the target line at the viewport top (\(landed) vs \(target))")
            #expect(typewriter.typewriterRoom > 0, "…with the room still there")

            // …and the landing is the SAME without the room, so the room is
            // provably not a variable in it.
            typewriter.typewriterRoomEnabled = false
            typewriter.updateTypewriterRoom()
            window.layoutIfNeeded()
            pump()
            h.model.restoreTopVisibleOffset(target)
            pump()
            #expect(h.model.topVisibleOffset() == landed)

            window.contentView = nil
        }
    }
}
