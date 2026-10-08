//
//  JumpPrimitive.swift
//  Variorum
//
//  THE scroll-to-location primitive (accepted Phase 6 memo, surface 3): the
//  bounded hybrid jump — scroll to a proportional estimate, force layout of
//  the ONE target fragment (`.ensuresLayout` on a single enumeration — the
//  only ensureLayout this target ever performs, per P1), correct the scroll
//  offset, ≤6 iterations. Measured pixel-exact at ~7 ms flat from 50k to
//  200k words.
//
//  Banned alternatives (memo): `relocateViewport(to:)` — measured broken
//  (moves the viewport, never the scroll view); `scrollRangeToVisible` —
//  caret reveal only (lands mid-viewport by design). Never px-anchor across
//  reflow or relaunch — restore by text location through this primitive.
//

import AppKit

/// The correction loop, pure — testable against a fake geometry source.
nonisolated enum JumpCorrectionLoop {
    struct Result: Equatable, Sendable {
        let finalTop: Double
        let iterations: Int
        let converged: Bool
    }

    /// `targetMinY(top)` means: scroll to `top`, lay out the ONE target
    /// fragment, report its minY (nil = geometry unavailable — bail where we
    /// are). The driver's closure performs the real scroll; tests supply a
    /// fake geometry source.
    static func run(
        initialTop: Double,
        maxScroll: Double,
        tolerance: Double = 1.0,
        maxIterations: Int = 6,
        targetMinY: (Double) -> Double?
    ) -> Result {
        run(
            initialTop: initialTop, minScroll: 0, maxScroll: { maxScroll }, tolerance: tolerance,
            maxIterations: maxIterations, targetMinY: targetMinY)
    }

    /// The same loop with the scroll range read AS OF EACH CLAMP (18k C6b —
    /// the held walks' W-2). The driver's own layout can change the
    /// document's height while it steers: a range computed once, before the
    /// first pass, went stale under a jump into TK2-estimated geometry
    /// (a whole-document re-font had left the note under-estimated by
    /// thousands of points), every proposal clamped to it, and the
    /// "clamped at the document edge" arm below reported convergence a dozen
    /// paragraphs above the target. A constant range behaves exactly as
    /// before (the overload above).
    ///
    /// `minScroll` (VX-85, the 13o follow-up run) is the lowest scroll the
    /// clip may rest at — 0, as it always was, except while a find bar
    /// overlays the clip's top, when the clip may scroll that strip's height
    /// ABOVE the document so its first line can rest below the bar
    /// (`JumpPrimitive.findBarInsets`; AppKit's own contentInsets model).
    static func run(
        initialTop: Double,
        minScroll: Double = 0,
        maxScroll: () -> Double,
        tolerance: Double = 1.0,
        maxIterations: Int = 6,
        targetMinY: (Double) -> Double?
    ) -> Result {
        var top = min(max(minScroll, initialTop), maxScroll())
        var iterations = 0
        while true {
            guard let minY = targetMinY(top) else {
                return Result(finalTop: top, iterations: iterations, converged: false)
            }
            if abs(minY - top) < tolerance {
                return Result(finalTop: top, iterations: iterations, converged: true)
            }
            if iterations >= maxIterations {
                return Result(finalTop: top, iterations: iterations, converged: false)
            }
            let next = min(max(minScroll, minY), maxScroll())
            if next == top {
                // Clamped (target near the document edge): as close as the
                // scroll geometry allows.
                return Result(finalTop: top, iterations: iterations, converged: true)
            }
            top = next
            iterations += 1
        }
    }
}

/// Line resolution INSIDE one layout fragment, pure.
///
/// **Why this exists (13c 1A, A4 — traced and reproduced):** a TK2 layout
/// fragment is a whole PARAGRAPH, and a Variorum block is always its own
/// paragraph (R26/R33). So a block taller than the viewport is ONE fragment,
/// and fragment-granularity scroll anchoring collapses every reading
/// position inside it to the block's first line: measured, scrolled to
/// y=2500 inside a 6127 pt block, `topVisibleOffset` answered the block's
/// start and the restore landed at y=225 — a 2275 pt leap backwards on every
/// width reflow (sidebar toggle, split divider, window resize). Both halves
/// of the anchor — read and restore — resolve to the LINE through here.
nonisolated enum FragmentLines {
    /// The line whose typographic bounds contain `y` (fragment-local).
    /// Above the first line ⇒ the first; below the last (the paragraph's
    /// trailing gap) ⇒ the last. nil ⇒ the fragment has no laid-out lines.
    static func lineIndex(atLocalY y: CGFloat, lineBounds: [CGRect]) -> Int? {
        guard !lineBounds.isEmpty else { return nil }
        for (i, bounds) in lineBounds.enumerated() where y < bounds.maxY { return i }
        return lineBounds.count - 1
    }

    /// **The line she is READING at fragment-local `y`** (18k C6b — the
    /// held walks' W-4): the first line whose baseline is at or below `y`,
    /// i.e. whose letters are still on screen under an edge at `y`. nil ⇒
    /// every line's baseline is above `y` — the edge is in the paragraph's
    /// trailing spacing or cuts only its last line's descenders, and the
    /// reading position belongs to what follows. `baselines` are fragment-
    /// local (a line's typographic top plus its `glyphOrigin.y`).
    static func readingLineIndex(atLocalY y: CGFloat, baselines: [CGFloat]) -> Int? {
        baselines.firstIndex { y <= $0 }
    }

    /// The line whose character range contains `offset` (fragment-local,
    /// UTF-16 — the structural API's unit). Past the last range ⇒ the last.
    static func lineIndex(atLocalOffset offset: Int, lineRanges: [NSRange]) -> Int? {
        guard !lineRanges.isEmpty else { return nil }
        for (i, range) in lineRanges.enumerated() where offset < range.upperBound { return i }
        return lineRanges.count - 1
    }
}

/// **A reading position WITH ITS PLACE on the page** (18l U0b — KnownIssues
/// row 87, her *"remove a newline … removing the whitespace between the
/// topmost line in the editor and the line at the top of the editor"*).
///
/// Every keeper of the reading position captured the OFFSET of the line she
/// is reading (`topVisibleOffset`) and replayed it through
/// `JumpPrimitive.jump`, whose contract is "that line AT the viewport top". An
/// offset cannot say where the line SAT, and two places are not "at the top":
///
/// - **The page's own top air.** At rest the page is scrolled to 0 and the
///   text container's 24-pt top inset shows above the first line (R9's
///   "generous top air"). Replaying offset 0 put the first line at the top —
///   the page scrolled by exactly that inset — on a backspace that deleted an
///   empty block (A7's carve lands through the full re-render), on a live
///   window resize, and on a voice switch. Measured: 24.0 pt in both voices.
/// - **Anywhere, for the full re-render.** A structural result that lands
///   through `renderFull` changed nothing above the anchor that the offset does
///   not carry, so the page must not move at all — the everyday gestures'
///   differential road's promise ("untouched text never moves", author
///   decision 2026-07-07), kept on the fallback road too. Snapping her line to
///   the top moved a wheel-scrolled page by the edge's offset inside its line.
///
/// Pure: the capture is the model's (it owns the geometry); this is the
/// arithmetic each restore reads, one rule per kind of restore.
nonisolated struct ReadingAnchor: Equatable, Sendable {
    /// The line she is reading (`EditorViewModel.topVisibleOffset` — the 18k
    /// C6b reading-line rule, unchanged).
    let offset: Int
    /// That line's top minus the viewport's top edge at capture, in view
    /// points: positive when the line sat below the edge (the page's top air;
    /// a paragraph gap), negative when the edge cut it.
    let inset: Double
    /// The viewport's top edge sat ABOVE the text container — in the page's
    /// top air, above every line of the note, where no text layout can move
    /// anything (it is the container's inset).
    let inPageTopAir: Bool

    /// The full re-render's landing: the line exactly where it was.
    var exactLandingInset: Double { inset }

    /// A RE-LAYOUT's landing (a width reflow, a re-font): the ruled rule —
    /// her reading line AT the top (13c 1A; 13u4 F2; 18k C6b and #147) —
    /// everywhere that rule was written for, and the page's top air kept as it
    /// was, which the rule never meant to take away (the first line was never
    /// at the top there in the first place).
    var reflowLandingInset: Double { inPageTopAir ? inset : 0 }

    /// **18l-b U-B5 (KnownIssues row 88) — the differential road's keeper.**
    /// A line the act did not write: its start lies strictly BEFORE the edit
    /// that began at `editLocation`, so nothing the act did can move it — the
    /// 2026-07-07 promise ("untouched text never moves"). A line at or after
    /// the edit is the act's to move (a paragraph inserted above it pushes it
    /// down) and is never "kept".
    func isUntouched(byEditAt editLocation: Int) -> Bool { offset < editLocation }

    /// How far the line has moved ON SCREEN since the capture: where it sits
    /// below the viewport's top edge now, less where it sat (`inset`). Zero on
    /// settled geometry; non-zero when TextKit re-based the laid-out text under
    /// a clip nothing moved (the U-B5 trace — a floating viewport re-estimated
    /// by a layout-forcing query that runs after the edit and before the
    /// viewport pass that consumes it).
    func displacement(lineTop: Double, viewportTop: Double) -> Double {
        (lineTop - viewportTop) - inset
    }
}

@MainActor
enum JumpPrimitive {
    /// **Where the line containing `offset` sits**, in the text view's own
    /// coordinates (the fragment frame plus the container origin — the exact
    /// geometry `jump` steers, so a caller asking "is it on screen?" and the
    /// jump that answers "put it on screen" can never disagree). Lays out the
    /// ONE target fragment, like `jump` (P1); nil when the geometry is
    /// unavailable.
    ///
    /// 17o batch b: the landing reveal's guard reads this — a caret already
    /// inside the visible rect must not be "revealed", because moving a page
    /// she can already see is exactly the lurch a reveal is meant to avoid.
    static func lineTop(ofOffset offset: Int, in textView: NSTextView) -> Double? {
        lineSpan(ofOffset: offset, in: textView)?.top
    }

    /// The line's vertical SPAN (top and bottom), same geometry as `lineTop`
    /// — the ladder's R1-11: "is it on screen?" has to see the line's bottom
    /// too, or a line whose top is inside the viewport and whose body is
    /// clipped below it counts as visible and is never revealed.
    static func lineSpan(
        ofOffset offset: Int, in textView: NSTextView
    ) -> (top: Double, bottom: Double)? {
        guard let layoutManager = textView.textLayoutManager,
              let contentManager = layoutManager.textContentManager
        else { return nil }
        let length = contentManager.offset(
            from: contentManager.documentRange.location,
            to: contentManager.documentRange.endLocation)
        let clamped = min(max(0, offset), length)
        // 17o batch b's ladder, round 2 — R2-1: the document's END location
        // is inside no element's range, so enumerating FROM it yields no
        // fragment at all — and a landing at the note's end (the caret
        // resting where she stopped typing, then ⌘2 → ⌘1) is the ordinary
        // case, not a corner. Enumerate from the character before it; the
        // LOCAL offset below stays `clamped`, whose past-the-last-range rule
        // (`FragmentLines.lineIndex`) resolves to the LAST line, never the
        // one before. (Measured: `span nil` at the end of a 250-paragraph
        // note, the visibility guard skipped, the page hauled to maxScroll.)
        let probe = clamped == length && length > 0 ? clamped - 1 : clamped
        guard let target = contentManager.location(
            contentManager.documentRange.location, offsetBy: probe)
        else { return nil }
        var span: (top: Double, bottom: Double)?
        layoutManager.enumerateTextLayoutFragments(
            from: target, options: [.ensuresLayout]
        ) { fragment in
            let frame = fragment.layoutFragmentFrame
            let fragmentTop = Double(frame.minY)
            let fragmentStart = contentManager.offset(
                from: contentManager.documentRange.location,
                to: fragment.rangeInElement.location)
            let lines = fragment.textLineFragments
            if let i = FragmentLines.lineIndex(
                atLocalOffset: max(0, clamped - fragmentStart),
                lineRanges: lines.map(\.characterRange)) {
                let bounds = lines[i].typographicBounds
                span = (fragmentTop + Double(bounds.minY), fragmentTop + Double(bounds.maxY))
            } else {
                span = (fragmentTop, Double(frame.maxY))
            }
            return false
        }
        guard let span else { return nil }
        let origin = Double(textView.textContainerOrigin.y)
        return (span.top + origin, span.bottom + origin)
    }

    /// **What a SHOWN find bar covers of the clip** (VX-85, the 13o follow-up
    /// run — MEASURED on macOS 27.0 by a headless AppKit probe): the scroll
    /// view lays its `NSTextFinderBarView` (32 pt) OVER the clip's top edge —
    /// the clip keeps its whole frame and its bounds origin does not move —
    /// and says so through the CLIP's own `contentInsets` (top 32 · bottom 6).
    /// So the clip's top strip is exactly where a landing's line is hidden.
    /// Zero whenever no bar is shown, so every caller that reads it is
    /// byte-unchanged without one (whatever else might set an inset).
    /// Re-measure at the next point release (TEXTKIT2_NOTES §5's matrix).
    static func findBarInsets(of scrollView: NSScrollView) -> (top: Double, bottom: Double) {
        guard scrollView.isFindBarVisible else { return (0, 0) }
        let insets = scrollView.contentView.contentInsets
        return (Double(max(0, insets.top)), Double(max(0, insets.bottom)))
    }

    /// Lands the LINE containing `offset` (UTF-16) at the viewport top —
    /// or, with `landingInset`, that many points BELOW the viewport top.
    ///
    /// 13c 1A (A4): this was "lands the FRAGMENT", which for a block taller
    /// than the viewport means "lands the block's first line" — see
    /// `FragmentLines`. Single-line fragments are byte-unchanged (the line's
    /// local minY is 0), so every existing caller — block-TOC jumps, scrub,
    /// caret restore — behaves exactly as before.
    ///
    /// **`landingInset` (13u2b UNIT 3)** is the whole of the mode-switch
    /// carry's AppKit half, and it needs no new scroll machinery: the
    /// correction loop converges `top` to whatever its closure reports, so a
    /// closure reporting `minY − inset` converges to a scroll offset that
    /// leaves exactly `inset` points between the viewport's top and the line.
    /// It defaults to 0, where every existing caller is byte-unchanged, and it
    /// may be NEGATIVE (a block taller than the viewport, scrolled past its
    /// top — `ViewportCarry.topInset` says when).
    static func jump(
        toOffset offset: Int, textView: NSTextView, scrollView: NSScrollView?,
        landingInset: Double = 0
    ) {
        guard let scrollView,
              let layoutManager = textView.textLayoutManager,
              let contentManager = layoutManager.textContentManager
        else { return }

        let clip = scrollView.contentView
        // 13c 1A: fragment geometry is TEXT-CONTAINER-relative; the scroll
        // offset this loop steers is VIEW-relative. The conversion was
        // missing, so every jump landed its target one container inset
        // BELOW the viewport top — invisible on its own because
        // `topVisibleOffset` carried the identical error and the two
        // cancelled on the round trip. Both halves are converted now, so
        // read-then-restore is exact by construction rather than by two
        // errors agreeing. (The Phase 10 container↔view class; the same
        // conversion `refreshDecorations` applies.)
        let containerOriginY = Double(textView.textContainerOrigin.y)
        let docHeight = textView.frame.height
        // QoL round 2026-07-29 (L5): the typewriter room is part of the
        // document now, so the scroll RANGE includes it — which is what lets a
        // jump put the LAST block at the viewport top instead of clamping a
        // viewport short of it (measured: 1,431 units short before this).
        // The proportional ESTIMATE deliberately excludes the room: the room
        // holds no text, so counting it would bias every guess downward. With
        // no room the two are the same number and the behaviour is unchanged.
        let room = Double((textView as? EditorTextView)?.typewriterRoom ?? 0)
        let textHeight = max(1, Double(docHeight) - room)
        // 18k C6b (the held walks' W-2): the scroll RANGE is the one the LAST
        // pass left, read at every use — never a number taken once from the
        // frame at entry. A jump into TK2-estimated geometry lays that
        // geometry out as it steers, and a whole-document re-font can leave
        // the note under-estimated by thousands of points: measured, her
        // Study walk's restore entered on a 18,276-pt frame, its first pass
        // grew the frame to 20,853, and every proposal after that clamped to
        // the entry range's 17,448 while the line sat at 19,816 — "converged"
        // 2,368 pt above it. On a frame that does not move (every settled
        // landing) this is the same number it always was.
        func maxScroll() -> Double { Double(max(0, textView.frame.height - clip.bounds.height)) }
        // VX-85: while a find bar overlays the clip's top, the clip may rest
        // that strip's height above the document (AppKit's contentInsets
        // model), so a landing that asks for the bar's height of air can
        // place even the FIRST line below the bar. Without a bar this is 0 —
        // the floor every jump has always had.
        let minScroll = -findBarInsets(of: scrollView).top
        let docLength = contentManager.offset(
            from: contentManager.documentRange.location,
            to: contentManager.documentRange.endLocation)
        guard docLength > 0 else { return }
        let clamped = min(max(0, offset), docLength)
        // R2-1: the same end-of-document rule as `lineSpan` (`docLength > 0`
        // is guarded above). Without it the closure's enumeration yields
        // nothing, the loop bails AFTER its first scroll, and the page sits
        // at the clamped proportional estimate — `maxScroll`, which with the
        // typewriter room is "the last line at the viewport top": on a short
        // note the whole note scrolled off but its last line.
        let probe = clamped == docLength ? clamped - 1 : clamped
        guard let target = contentManager.location(
            contentManager.documentRange.location, offsetBy: probe)
        else { return }

        func scroll(to y: Double) {
            let wanted = min(max(minScroll, y), maxScroll())
            clip.scroll(to: NSPoint(x: 0, y: wanted))
            scrollView.reflectScrolledClipView(clip)
            layoutManager.textViewportLayoutController.layoutViewport()
            // 18k C6 (macOS 27 — KnownIssues row 65, item 1): the viewport
            // layout above can MOVE THE CLIP by about the height change its
            // own pass causes (measured +29 pt with the frame +29, −23.23
            // with the frame −23.5), while the target line stays put. The
            // loop below judges convergence against the top it ASKED for, so
            // it reported "converged" with the line a line-plus-gap off the
            // top — the re-font restore's one-line slip. Put the clip back
            // where it was asked to be, once: the geometry that pass settled
            // no longer changes, so the second layout leaves it (9 of 9
            // measured). A clamp at a maximum the pass SHRANK is not a
            // displacement and is left alone. On settled geometry the clip is
            // already where it was asked to be and none of this runs.
            let reachable = min(wanted, maxScroll())
            if abs(Double(clip.bounds.origin.y) - reachable) >= 0.5 {
                clip.scroll(to: NSPoint(x: 0, y: wanted))
                scrollView.reflectScrolledClipView(clip)
                layoutManager.textViewportLayoutController.layoutViewport()
            }
        }

        // 1. Proportional estimate → 2. single-fragment ensureLayout →
        // 3. bounded scroll correction. The closure scrolls to the loop's
        // proposed top, then measures the target fragment there.
        let estimate = Double(clamped) / Double(docLength) * textHeight - landingInset
        _ = JumpCorrectionLoop.run(
            initialTop: estimate,
            minScroll: minScroll,
            maxScroll: maxScroll
        ) { top in
            scroll(to: top)
            var minY: Double?
            layoutManager.enumerateTextLayoutFragments(
                from: target, options: [.ensuresLayout]
            ) { fragment in
                let fragmentTop = Double(fragment.layoutFragmentFrame.minY)
                // The target LINE inside the fragment (A4). `rangeInElement`
                // is documented "relative to the document origin", and a
                // line's `characterRange` is fragment-local, so the two
                // compose into the line's offset within this paragraph.
                let fragmentStart = contentManager.offset(
                    from: contentManager.documentRange.location,
                    to: fragment.rangeInElement.location)
                let lines = fragment.textLineFragments
                if let i = FragmentLines.lineIndex(
                    atLocalOffset: max(0, clamped - fragmentStart),
                    lineRanges: lines.map(\.characterRange)) {
                    minY = fragmentTop + Double(lines[i].typographicBounds.minY)
                        + containerOriginY
                } else {
                    minY = fragmentTop + containerOriginY
                }
                return false
            }
            // The loop steers `top` toward what this reports, so reporting the
            // line's own minY lands it at the viewport top and reporting
            // `minY − inset` lands it `inset` points below (0 by default).
            return minY.map { $0 - landingInset }
        }
    }
}
