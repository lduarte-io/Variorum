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
        var top = min(max(0, initialTop), maxScroll)
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
            let next = min(max(0, minY), maxScroll)
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

    /// The line whose character range contains `offset` (fragment-local,
    /// UTF-16 — the structural API's unit). Past the last range ⇒ the last.
    static func lineIndex(atLocalOffset offset: Int, lineRanges: [NSRange]) -> Int? {
        guard !lineRanges.isEmpty else { return nil }
        for (i, range) in lineRanges.enumerated() where offset < range.upperBound { return i }
        return lineRanges.count - 1
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
        let maxScroll = Double(max(0, docHeight - clip.bounds.height))
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
            clip.scroll(to: NSPoint(x: 0, y: min(max(0, y), maxScroll)))
            scrollView.reflectScrolledClipView(clip)
            layoutManager.textViewportLayoutController.layoutViewport()
        }

        // 1. Proportional estimate → 2. single-fragment ensureLayout →
        // 3. bounded scroll correction. The closure scrolls to the loop's
        // proposed top, then measures the target fragment there.
        let estimate = Double(clamped) / Double(docLength) * textHeight - landingInset
        _ = JumpCorrectionLoop.run(
            initialTop: estimate,
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
