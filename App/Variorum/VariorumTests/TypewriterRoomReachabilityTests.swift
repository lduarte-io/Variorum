//
//  TypewriterRoomReachabilityTests.swift
//  VariorumTests
//
//  QoL round 2026-07-29, batch 1 — **L5**, her words: *"i also think that
//  whitespace at the bottom was supposed to ship but i still am not seeing
//  the whitespace at the bottom. this is the bottom of a post in write, for
//  example."*
//
//  **THE PIN-GAP LESSON THIS FILE EXISTS TO CLOSE.** A22 shipped (13d batch
//  5) with eight green pins over a feature that could not be reached through
//  any real input path: every one of them entered the room by calling
//  `clip.scroll(to:)` or `constrainBoundsRect` directly — the one door the
//  feature did not need fixed. The batch's adopted rule:
//
//      "a pin for a feature reached by input must be driven through an input
//       path, or it is a pin on our arithmetic, not on her experience."
//
//  So nothing here touches `clip.scroll(to:)`. The room is entered by the
//  keyboard's own scroll commands (`scrollToEndOfDocument:`,
//  `scrollPageDown:` — NSResponder's, the same selectors ⌘↓ and ⇟ send) and
//  by a synthesized scroll wheel where the host can deliver one; its RANGE is
//  asserted at the NSScrollView level (`documentRect`, the scroller), which
//  is the quantity every clamp, elastic edge and caret reveal derives from.
//
//  Also here: **β1** (her ruling at the 2026-07-29 sitting's continuation —
//  *"Yes — keep ~2 lines"*), the reveal-with-padding half.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("A22 — the room through REAL input paths (QoL L5)", .serialized)
struct TypewriterRoomReachabilityTests {
    private func pump(_ turns: Int = 4) {
        for _ in 0..<turns {
            RunLoop.main.run(until: Date().addingTimeInterval(0.03))
        }
    }

    /// Short blocks only, deliberately: no long block means no over-estimated
    /// phantom, so "the bottom of the text" is honest without a heal pass.
    private func corpus(_ count: Int = 120) -> [String] {
        (0..<count).map { "Paragraph \($0) with a handful of ordinary words in it." }
    }

    private func mount(
        _ h: EditorHarness, height: CGFloat = 500, width: CGFloat = 760
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

    /// The document height the TEXT alone accounts for — the quantity her
    /// ruling measures the room from ("below the last line"), and the one the
    /// shipped mechanism did NOT use (it measured from `document.frame`,
    /// which `isVerticallyResizable` floors at the viewport).
    private func textContentHeight(_ textView: NSTextView) -> CGFloat {
        guard let layoutManager = textView.textLayoutManager else { return 0 }
        return layoutManager.usageBoundsForTextContainer.height
            + textView.textContainerInset.height * 2
    }

    /// The view-space bottom of the last line the layout has actually drawn
    /// (PhantomSpaceTests' helper, same arithmetic).
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

    /// How many points of empty space are visible below her LAST DRAWN LINE
    /// at the bottom of the viewport.
    ///
    /// **Measured against the drawn text, never against `usageBounds` or the
    /// document rect.** Step 1 found `usageBoundsForTextContainer` + insets
    /// sitting 686 pt BELOW the frame on a 120-paragraph corpus (2,235 vs
    /// 2,921) — TK2's estimate for un-laid-out short paragraphs — so a
    /// "room" measured that way is mostly phantom and drifts as layout
    /// proceeds. The last drawn line is stable and is what she looks at.
    private func visibleRoom(_ scrollView: NSScrollView, _ textView: NSTextView) -> CGFloat {
        scrollView.contentView.bounds.maxY - lastTextBottom(textView)
    }

    /// Scrolls to the very bottom through the PAGE-DOWN path (⇟), which step
    /// 1 measured as one that already honours the shipped allowance — so a
    /// pin entering this way tests what happens ONCE SHE IS THERE rather than
    /// re-testing entry.
    private func pageToTheBottom(_ scrollView: NSScrollView, _ textView: NSTextView) -> Int {
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
        return turns
    }

    private var lineHeight: CGFloat {
        TypewriterRoom.lineHeight(of: EditorDocument.baseFont)
    }

    /// A synthesized scroll wheel, continuous (trackpad-shaped) or discrete.
    /// Returns nil when the host cannot build one — reported, never silently
    /// skipped (batch 5's mouse-down honesty).
    private func wheelEvent(deltaY: Double, continuous: Bool, in window: NSWindow) -> NSEvent? {
        guard let cg = CGEvent(
            scrollWheelEvent2Source: nil, units: continuous ? .pixel : .line,
            wheelCount: 1, wheel1: Int32(deltaY), wheel2: 0, wheel3: 0)
        else { return nil }
        cg.setIntegerValueField(.scrollWheelEventIsContinuous, value: continuous ? 1 : 0)
        if continuous {
            cg.setDoubleValueField(.scrollWheelEventPointDeltaAxis1, value: deltaY)
        }
        cg.setIntegerValueField(.eventTargetUnixProcessID, value: Int64(getpid()))
        guard let event = NSEvent(cgEvent: cg) else { return nil }
        _ = window
        return event
    }

    // MARK: - STEP 1: the measurement the ruling asked for

    /// **THE MEASUREMENT (not an assertion about the fix).** The batch-5
    /// record states that the room "is reached by ordinary scrolling — wheel,
    /// trackpad, keyboard". That sentence was never measured; her report is
    /// the measurement. This prints what each real path actually reaches, so
    /// the batch record can state facts instead of inferences.
    ///
    /// It asserts only NON-VACUITY (the post really is scrollable and the
    /// room really is switched on) — the durable claims are the pins below.
    @Test func theRealScrollPathsMeasured() async throws {
        try await withEditor(seedBlocks: corpus()) { h in
            let (scrollView, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }
            let clip = scrollView.contentView
            let typewriter = try #require(scrollView as? TypewriterScrollView)

            let content = textContentHeight(h.textView)
            let viewport = clip.bounds.height
            #expect(content > viewport * 2, "non-vacuity: the post is genuinely scrollable")
            #expect(typewriter.typewriterRoom > 100, "non-vacuity: the room is on")

            @MainActor func deepest(_ label: String, _ drive: () -> Void) -> String {
                clip.scroll(to: .zero)  // setup only — never the measurement
                scrollView.reflectScrolledClipView(clip)
                pump(1)
                var last = -1.0
                var origin = clip.bounds.origin.y
                var turns = 0
                while abs(origin - last) > 0.5, turns < 400 {
                    last = origin
                    drive()
                    scrollView.reflectScrolledClipView(clip)
                    pump(1)
                    origin = clip.bounds.origin.y
                    turns += 1
                }
                return "\(label): origin \(origin) · room visible "
                    + "\(clip.bounds.maxY - content) pt (\(turns) drives)"
            }

            let keyboardEnd = deepest("scrollToEndOfDocument") {
                h.textView.scrollToEndOfDocument(nil)
            }
            let pageDown = deepest("scrollPageDown") { h.textView.scrollPageDown(nil) }
            let wheelContinuous = wheelEvent(deltaY: -120, continuous: true, in: window)
                .map { event in deepest("wheel (continuous)") { scrollView.scrollWheel(with: event) } }
                ?? "wheel (continuous): the host could not synthesize the event"
            let wheelDiscrete = wheelEvent(deltaY: -10, continuous: false, in: window)
                .map { event in deepest("wheel (discrete)") { scrollView.scrollWheel(with: event) } }
                ?? "wheel (discrete): the host could not synthesize the event"

            clip.scroll(to: .zero)
            scrollView.reflectScrolledClipView(clip)
            pump(1)
            let scroller = scrollView.verticalScroller

            print("""
                L5 step-1 measurement (macOS \(ProcessInfo.processInfo.operatingSystemVersionString)):
                  viewport \(viewport) · text content \(content) pt · room \(typewriter.typewriterRoom) pt
                  clip.documentRect.height \(clip.documentRect.height) \
                (text + room would be \(content + typewriter.typewriterRoom))
                  scroller knobProportion \(scroller?.knobProportion ?? -1) \
                (viewport / (text+room) would be \(viewport / (content + typewriter.typewriterRoom)))
                  verticalScrollElasticity \(scrollView.verticalScrollElasticity.rawValue) (0 = automatic)
                  \(keyboardEnd)
                  \(pageDown)
                  \(wheelContinuous)
                  \(wheelDiscrete)
                """)
        }
    }

    // MARK: - The range, at the NSScrollView level

    /// **RED ON SHIPPED.** The room has to live in the quantity AppKit
    /// derives every limit from — `documentRect` — or the scroller, the
    /// elastic edge, the discrete-wheel clamp and every caret reveal are
    /// blind to it. The shipped `constrainBoundsRect` allowance moves none of
    /// them: `documentRect` is the text's height alone, and the knob covers
    /// only the text (recorded as an accepted cost at 13d batch 5; it is a
    /// failing pin now).
    @Test func theDocumentRectCarriesTheRoomAndTheScrollerReflectsIt() async throws {
        try await withEditor(seedBlocks: corpus()) { h in
            let (scrollView, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }
            let clip = scrollView.contentView
            let typewriter = try #require(scrollView as? TypewriterScrollView)
            let room = typewriter.typewriterRoom
            #expect(room > 100, "non-vacuity: the room is on")

            // Toggling the room off and back is the instrument-independent
            // measurement: whatever AppKit thinks the text's height is, the
            // DOCUMENT RECT must grow by exactly the room. (Measuring against
            // `usageBoundsForTextContainer` would be measuring against a
            // number step 1 found 686 pt short of the drawn text.)
            let withRoom = clip.documentRect.height
            let knobWithRoom = try #require(scrollView.verticalScroller).knobProportion
            typewriter.typewriterRoomEnabled = false
            typewriter.updateTypewriterRoom()
            window.layoutIfNeeded()
            pump(2)
            let withoutRoom = clip.documentRect.height

            let inset = h.textView.textContainerInset.height
            #expect(abs((withRoom - withoutRoom) - (room - inset)) < 2,
                    """
                    the room must be part of the DOCUMENT RECT — every clamp AppKit \
                    computes reads that rect, which is why the clip-allowance \
                    mechanism was invisible to the knob, to ⌘↓, to the jump and to \
                    the scroll anchor (\(withoutRoom) → \(withRoom), room \(room), \
                    bottom inset \(inset): the room is measured from her LAST LINE, \
                    so the rect grows by room − inset)
                    """)

            // …and the scroller is sized from that rect, so the knob covers
            // the room too. On the shipped mechanism the knob read the text's
            // height while the reachable range was longer — the mismatch was
            // recorded at 13d batch 5 as an accepted cost.
            typewriter.typewriterRoomEnabled = true
            typewriter.updateTypewriterRoom()
            window.layoutIfNeeded()
            pump(2)
            let expected = clip.bounds.height / clip.documentRect.height
            #expect(abs(knobWithRoom - expected) < 0.02,
                    """
                    the knob must reflect the scrollable range it can actually \
                    reach (\(knobWithRoom) vs \(expected))
                    """)
        }
    }

    // MARK: - Reachability through real input paths

    /// **RED ON SHIPPED — the whole of her report.** ⌘↓ sends
    /// `scrollToEndOfDocument:`; "the end of the document" must include the
    /// room, which is only true if the room is IN the document. On the
    /// shipped allowance it lands at the text's end and there is no air below
    /// — her screenshot.
    @Test func scrollToEndOfDocumentLandsInTheRoom() async throws {
        try await withEditor(seedBlocks: corpus()) { h in
            let (scrollView, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }
            let clip = scrollView.contentView

            for _ in 0..<3 {
                h.textView.scrollToEndOfDocument(nil)
                scrollView.reflectScrolledClipView(clip)
                pump(1)
            }

            let room = visibleRoom(scrollView, h.textView)
            #expect(room > lineHeight * 3,
                    """
                    ⌘↓ must leave real air under her last line rather than parking it \
                    against the bottom edge (\(room) pt, one line \(lineHeight) pt). \
                    NSTextView's `scrollToEndOfDocument:` goes to the end of the TEXT \
                    by design, which is right — what was wrong is that the text's end \
                    WAS the document's end, so there was nowhere for it to breathe.
                    """)
        }
    }

    /// **CHARACTERIZATION — and a correction to the record.** Step 1
    /// measured that ⇟ (`scrollPageDown:`) and a synthesized scroll wheel
    /// BOTH already reach the shipped `constrainBoundsRect` allowance
    /// (origin 2,904 = frame 2,921 + room 483 − viewport 500, exactly). So
    /// the allowance is not blind to every path, and this fix must not be
    /// credited with fixing paging. Recorded as a characterization pin per
    /// the hallucination guard — it passes on both sides, and saying so is
    /// the point.
    ///
    /// What step 1 found genuinely blind: the scroller knob, ⌘↓
    /// (`scrollToEndOfDocument:`), `JumpPrimitive.maxScroll` and the
    /// anchor/reflow restore. The trackpad's elastic snap-back could not be
    /// synthesized in this host (batch 5's mouse-down class) and stays an
    /// honestly untested path.
    @Test func pagingAlreadyReachedTheAllowance() async throws {
        try await withEditor(seedBlocks: corpus()) { h in
            let (scrollView, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }
            let turns = pageToTheBottom(scrollView, h.textView)
            #expect(turns > 3, "non-vacuity: paging really walked the post")
            #expect(visibleRoom(scrollView, h.textView) > 100,
                    "paging reaches empty space below the last line")
        }
    }

    /// **The persistence half — CHARACTERIZATION, measured green on both
    /// sides.** Once she is in the empty space, a layout pass and a
    /// phantom-heal pass must leave her there and must not change the room's
    /// size. Measured on the shipped code (entering by paging, which step 1
    /// showed already works): it already holds. So this is NOT a red-on-old
    /// pin and the fix is not credited with it — it is the standing guard
    /// that Option A's document growth does not introduce an eviction the
    /// allowance never had. Recorded per the hallucination guard.
    @Test func theRoomSurvivesALayoutPassAndAHeal() async throws {
        var blocks = corpus(60)
        blocks[30] = (0..<1500).map { "longword\($0 % 97)" }.joined(separator: " ")
        try await withEditor(seedBlocks: blocks) { h in
            let (scrollView, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }
            let typewriter = try #require(scrollView as? TypewriterScrollView)

            _ = pageToTheBottom(scrollView, h.textView)
            let roomBefore = typewriter.typewriterRoom
            #expect(visibleRoom(scrollView, h.textView) > 100, "in the room to begin with")

            h.textView.needsLayout = true
            h.textView.layoutSubtreeIfNeeded()
            window.displayIfNeeded()
            pump(1)
            #expect(visibleRoom(scrollView, h.textView) > 100,
                    "a layout pass must not evict her from the room")

            _ = h.model.runLongBlockLayoutPass()
            window.displayIfNeeded()
            pump(1)
            #expect(abs(typewriter.typewriterRoom - roomBefore) < 1,
                    "the heal must not change the room's size")
            #expect(visibleRoom(scrollView, h.textView) > 100,
                    "…and must not evict her from it")
        }
    }

    /// **RED ON SHIPPED** (measured: the anchor answered **nil** at every room
    /// depth, so `ScrollAnchorController` kept a stale one and a width reflow
    /// restored an older position — the room visible fell to 0).
    ///
    /// **What fixed it is the frame, not a special case.** A read-time
    /// "answer the last line past the last fragment" fallback was written
    /// first and then REMOVED: with the room inside the document, maximum
    /// scroll puts the last line's top AT the viewport top, so the ordinary
    /// fragment lookup succeeds and the fallback never ran. Reverting it left
    /// every pin green, including a strengthened arm built to reach the
    /// past-every-fragment state (`theAnchorAnswersAtMaximumScroll`) — so it
    /// was unreachable defensive code in a heavily pinned path, which is the
    /// drift class 13d judgment call 1 names.
    @Test func aWidthReflowKeepsHerInTheRoom() async throws {
        try await withEditor(seedBlocks: corpus()) { h in
            let (scrollView, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }

            _ = pageToTheBottom(scrollView, h.textView)
            #expect(visibleRoom(scrollView, h.textView) > 100, "in the room to begin with")
            let anchor = h.model.topVisibleOffset()
            #expect(anchor != nil,
                    "the anchor must name where she is (the last line) rather than nothing")

            if let anchor {
                h.model.restoreTopVisibleOffset(anchor)
                pump(2)
            }
            #expect(visibleRoom(scrollView, h.textView) > 100,
                    """
                    replaying the anchor must keep her in the room, not yank her out \
                    (room now \(visibleRoom(scrollView, h.textView)) pt)
                    """)
        }
    }

    /// **CHARACTERIZATION — and the arm that retired a fallback.** Built to
    /// reach the one state a read-time anchor fallback would be for: a
    /// document taller than its drawn text by more than a viewport (a long
    /// block whose TK2 over-estimate is unhealed), where the viewport top
    /// could sit past every fragment. It cannot be reached by any real path —
    /// scrolling down lays the long block out on the way, which collapses the
    /// over-estimate before the bottom (measured: the top ends up 11 pt ABOVE
    /// the last drawn line, not past it). So the fallback was removed and this
    /// stays as the standing guard that the anchor answers at maximum scroll.
    @Test func theAnchorAnswersAtMaximumScroll() async throws {
        var blocks = (0..<40).map { "Paragraph \($0) with a handful of words." }
        blocks[20] = (0..<6000).map { "longword\($0 % 97)" }.joined(separator: " ")
        try await withEditor(seedBlocks: blocks) { h in
            let (scrollView, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }
            _ = pageToTheBottom(scrollView, h.textView)
            let air = visibleRoom(scrollView, h.textView)
            let past = scrollView.contentView.bounds.origin.y - lastTextBottom(h.textView)
            print("L5 anchor-arm probe: air \(air) pt · viewport top is \(past) pt past the last drawn line")
            #expect(h.model.topVisibleOffset() != nil,
                    """
                    the anchor must name a reading position even when the viewport top \
                    is past every laid-out fragment (top \(past) pt past the last drawn \
                    line) — answering nil leaves `ScrollAnchorController`'s anchor stale \
                    and a width reflow restores an older position
                    """)
        }
    }

    /// **RED ON SHIPPED.** `JumpPrimitive`'s `maxScroll` came from the
    /// document height, so a jump to the LAST block clamped a whole viewport
    /// short and could never bring it up to the top of the page. With the room
    /// inside the document it can — which is exactly what the room is for.
    /// (A22's own jump pin deliberately stepped around this case because it
    /// could not pass.)
    ///
    /// **Asserted in POINTS, deliberately.** The natural phrasing — "the
    /// anchor answers the last block" — drags in an unrelated 8 pt
    /// disagreement between the jump's line arithmetic and the anchor's
    /// (`typographicBounds` versus the paragraph gap that sits between two
    /// fragments), which predates this batch, shows up only at the document's
    /// last line, and is recorded in the batch record rather than fixed under
    /// cover of L5. What the room governs is how close to the top of the page
    /// the last line can be brought, and that is measured here directly.
    @Test func theJumpCanLandTheLastBlockAtTheViewportTop() async throws {
        try await withEditor(seedBlocks: corpus(80)) { h in
            let (scrollView, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }
            let clip = scrollView.contentView

            let last = h.model.index.entries.count - 1
            let target = h.model.index.range(ofEntryAt: last).location
            h.model.restoreTopVisibleOffset(target)
            pump(2)

            // The last line's TOP, in view space, against the viewport's top.
            let lastLineTop = lastTextBottom(h.textView) - lineHeight
            let distance = lastLineTop - clip.bounds.origin.y
            #expect(distance >= -1, "the last line must not be scrolled above the page")
            #expect(distance < lineHeight * 2,
                    """
                    a jump to the LAST block must be able to bring it to the top of \
                    the page (its line sits \(distance) pt below the viewport top; \
                    one line is \(lineHeight) pt). Without the room in the document \
                    the range ended a viewport earlier and this was ~a page.
                    """)
        }
    }

    /// **The measurement defect, pinned** (adopted Part-0 finding). The
    /// shipped allowance measured the room from `document.frame.height`,
    /// which `isVerticallyResizable` floors at the viewport — so on a short
    /// post the allowance began a whole viewport below three lines of text,
    /// and scrolling to the end would carry her text entirely off the top:
    /// "room that has swallowed the text", judgment call 7's own forbidden
    /// outcome. Measuring from the TEXT bottom is her ruling's literal words.
    @Test func theRoomNeverSwallowsAShortPostsText() async throws {
        try await withEditor(seedBlocks: ["One short line.", "And a second."]) { h in
            let (scrollView, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }

            _ = pageToTheBottom(scrollView, h.textView)

            let bottom = lastTextBottom(h.textView)
            let viewportTop = scrollView.contentView.bounds.origin.y
            #expect(bottom > 0, "non-vacuity: the text laid out")
            #expect(bottom > viewportTop,
                    """
                    her text must still be on screen at maximum scroll (text bottom \
                    \(bottom), viewport top \(viewportTop)) — a room measured from the \
                    DOCUMENT bottom scrolls a short post away
                    """)
        }
    }

    // MARK: - β1 — her ruling: ~2 lines of air under the caret while typing

    /// **HER RULING (2026-07-29, the sitting's continuation — "Yes — keep ~2
    /// lines").** Typing near the bottom of the page keeps about two lines of
    /// air below the caret's line instead of letting it sit against the bottom
    /// edge.
    ///
    /// **THREE earlier versions of this pin passed on the shipped code, i.e.
    /// were hollow, and the third one taught the most.** (a) A single
    /// insertion made from the top of a long post is a FAR reveal, and
    /// `scrollRangeToVisible` lands a far target mid-viewport by design (the
    /// Phase 6 memo's own note), so air appeared for free. (b) Typing after
    /// paging to the very bottom already sits in the room. (c) Typing with the
    /// caret's line EXACTLY flush at the bottom edge counts as not-visible to
    /// AppKit, so its own reveal fires and — now that the document carries the
    /// room — over-delivers 244 pt of air on its own, with β1's clearance
    /// never running (measured: applied 0 times).
    ///
    /// The state β1 actually governs is the one in between, and it is the
    /// ordinary one: her caret's line is VISIBLE but close to the bottom, so
    /// AppKit does nothing at all and she types along the edge of the page.
    /// The scroll that parks it there is declared SETUP; what TYPING does from
    /// there is the input under test, and the activation count proves this
    /// code — not AppKit — is what delivers it.
    @Test func typingNearTheBottomKeepsAboutTwoLinesOfAirBelowTheCaret() async throws {
        try await withEditor(seedBlocks: corpus()) { h in
            let (scrollView, window) = try mount(h)
            defer { window.orderOut(nil); window.close() }
            let clip = scrollView.contentView

            // SETUP (declared): caret at the end, its line VISIBLE but about
            // one line above the bottom edge — close enough that AppKit's own
            // reveal has nothing to do.
            let end = (h.textView.string as NSString).length
            h.textView.setSelectedRange(NSRange(location: end, length: 0))
            _ = pageToTheBottom(scrollView, h.textView)
            let bottom = lastTextBottom(h.textView)
            clip.scroll(to: NSPoint(x: 0, y: bottom + lineHeight - clip.bounds.height))
            scrollView.reflectScrolledClipView(clip)
            pump(1)
            let airBefore = clip.bounds.maxY - lastTextBottom(h.textView)
            #expect(airBefore > 0 && airBefore < lineHeight * 1.5,
                    "setup: her line is visible but hugging the bottom (\(airBefore) pt)")

            // THE INPUT.
            TypewriterCaretClearance.applied = 0
            h.type("x", at: end)
            scrollView.reflectScrolledClipView(clip)
            pump(2)

            let air = clip.bounds.maxY - lastTextBottom(h.textView)
            let wanted = h.textView.textContainerInset.height
                + TypewriterScrollView.caretClearanceLines * lineHeight
            print("""
                L5 β1 measurement: air \(airBefore) → \(air) pt (wanted \(wanted)) ·                 one line \(lineHeight) pt · clearance applied                 \(TypewriterCaretClearance.applied) time(s)
                """)
            #expect(TypewriterCaretClearance.applied == 1,
                    "β1's clearance is what delivers this, not AppKit's own reveal")
            #expect(air >= wanted - 2,
                    """
                    typing with her line hugging the bottom must leave ~2 lines of air                     under it (air \(air) pt, wanted \(wanted) pt, one line \(lineHeight) pt)
                    """)
        }
    }

    /// …and the padding is Write's alone: the inline (book-view) editor has no
    /// scroll view of its own and must be untouched by both halves of L5.
    @Test func theInlineEditorStaysRoomless() {
        let inline = EditorTextView.makeInlineEditor()
        #expect(inline.enclosingScrollView == nil,
                "the room is Write's full-document editor only")
    }
}
