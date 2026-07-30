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
                "the room is scroll EXTENT, not a content inset — the inset mechanism was measured to break hit testing over her own visible text, and the clip-allowance mechanism that replaced it was measured invisible to half the ways in (both stories in TypewriterScrollView)")

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
        // **UPDATED at the QoL round (2026-07-29, L5), with its reason.** This
        // asserted `== expected` — the room measured from the DOCUMENT's bottom
        // edge, which is what the clip-allowance mechanism did. The room is
        // measured from her LAST LINE now (her ruling's own words, "below the
        // last line"), so the extra scroll is the room LESS the bottom
        // container inset that always sat under that line. The old arithmetic
        // is what would have scrolled a short post's text off the top
        // (`theRoomNeverSwallowsAShortPostsText`, measured red at 412 pt).
        let inset = textView.textContainerInset.height
        #expect(abs((withRoom - withoutRoom) - (expected - inset)) < 1,
                "the extra scroll is the room less the bottom inset (\(withoutRoom) → \(withRoom), room \(expected), inset \(inset))")

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
    /// end of the text.**
    ///
    /// **REWRITTEN at the QoL round (2026-07-29, L5), and the rewrite is an
    /// UPGRADE.** The 13d version asserted a MECHANISM — that the scroll view
    /// itself answered `hitTest` in the room — plus a hand-invoked handler,
    /// because "AppKit's OWN delivery of a synthesized mouse-down could not be
    /// driven in this test host". Option A deletes that mechanism: the room is
    /// part of the document now, so a click there is an ordinary click past
    /// the last line and `NSTextView` answers it with
    /// `characterIndexForInsertion` — the end of the text, which is exactly
    /// what her ruling asks and exactly what 13c 1C measured for the phantom.
    /// So this pin now drives the window's real hit-testing and event route
    /// (`PhantomSpaceTests`' click helper, which demonstrably does move the
    /// caret), covering end to end what batch 5 had to leave unpinned.
    @Test func aClickInTheRoomLandsTheCaretAtTheEndOfTheText() async throws {
        let (scrollView, textView) = EditorTextView.makeEditor()
        let typewriter = try #require(scrollView as? TypewriterScrollView)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.contentView = NSView(frame: NSRect(x: 0, y: 0, width: 600, height: 400))
        scrollView.frame = NSRect(x: 0, y: 0, width: 600, height: 400)
        window.contentView?.addSubview(scrollView)
        textView.string = (1...200)
            .map { "Paragraph \($0) with some words in it." }.joined(separator: "\n")
        window.makeKeyAndOrderFront(nil)
        window.layoutIfNeeded()
        window.display()
        pump()
        defer { window.orderOut(nil); window.close() }

        // Page to the very bottom through a real input path.
        let clip = scrollView.contentView
        var last = -1.0
        var turns = 0
        while abs(clip.bounds.origin.y - last) > 0.5, turns < 300 {
            last = clip.bounds.origin.y
            textView.scrollPageDown(nil)
            scrollView.reflectScrolledClipView(clip)
            pump(1)
            turns += 1
        }
        #expect(typewriter.typewriterRoom > 0, "the room is on for this pin to mean anything")

        textView.setSelectedRange(NSRange(location: 0, length: 0))
        // A point deep in the room: below every drawn line, inside the viewport.
        var textBottom: CGFloat = 0
        try #require(textView.textLayoutManager)
            .enumerateTextLayoutFragments(from: nil, options: []) { fragment in
                if fragment.state == .layoutAvailable, let line = fragment.textLineFragments.last {
                    textBottom = max(
                        textBottom,
                        fragment.layoutFragmentFrame.minY + line.typographicBounds.maxY)
                }
                return true
            }
        textBottom += textView.textContainerInset.height
        let probe = CGPoint(x: 300, y: textBottom + (clip.bounds.maxY - textBottom) / 2)
        #expect(probe.y > textBottom, "the probe really is below her text")
        #expect(probe.y < clip.bounds.maxY, "…and inside the viewport")

        // AppKit's own hit test + event route.
        let inWindow = textView.convert(probe, to: nil)
        let target = try #require(window.contentView).hitTest(
            try #require(window.contentView?.superview).convert(inWindow, from: nil))
        #expect(target === textView,
                "the room belongs to the editor now — a click there reaches the text view")
        if let down = NSEvent.mouseEvent(
            with: .leftMouseDown, location: inWindow, modifierFlags: [],
            timestamp: ProcessInfo.processInfo.systemUptime,
            windowNumber: window.windowNumber, context: nil,
            eventNumber: 0, clickCount: 1, pressure: 1),
           let up = NSEvent.mouseEvent(
            with: .leftMouseUp, location: inWindow, modifierFlags: [],
            timestamp: ProcessInfo.processInfo.systemUptime,
            windowNumber: window.windowNumber, context: nil,
            eventNumber: 0, clickCount: 1, pressure: 0) {
            NSApp.postEvent(up, atStart: true)
            target?.mouseDown(with: down)
            pump(1)
        }
        #expect(textView.selectedRange()
            == NSRange(location: (textView.string as NSString).length, length: 0),
            "the caret lands at the END of the text — 'the room is space, not paper'")
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
        #expect(inline.typewriterRoom == 0,
                "…and carries no room on its frame either (QoL L5: the room is a document-frame property now)")
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
