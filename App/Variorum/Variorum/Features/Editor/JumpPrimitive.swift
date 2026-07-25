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
    /// Lands the LINE containing `offset` (UTF-16) at the viewport top.
    ///
    /// 13c 1A (A4): this was "lands the FRAGMENT", which for a block taller
    /// than the viewport means "lands the block's first line" — see
    /// `FragmentLines`. Single-line fragments are byte-unchanged (the line's
    /// local minY is 0), so every existing caller — block-TOC jumps, scrub,
    /// caret restore — behaves exactly as before.
    static func jump(toOffset offset: Int, textView: NSTextView, scrollView: NSScrollView?) {
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
        let maxScroll = Double(max(0, docHeight - clip.bounds.height))
        let docLength = contentManager.offset(
            from: contentManager.documentRange.location,
            to: contentManager.documentRange.endLocation)
        guard docLength > 0 else { return }
        let clamped = min(max(0, offset), docLength)
        guard let target = contentManager.location(
            contentManager.documentRange.location, offsetBy: clamped)
        else { return }

        func scroll(to y: Double) {
            clip.scroll(to: NSPoint(x: 0, y: min(max(0, y), maxScroll)))
            scrollView.reflectScrolledClipView(clip)
            layoutManager.textViewportLayoutController.layoutViewport()
        }

        // 1. Proportional estimate → 2. single-fragment ensureLayout →
        // 3. bounded scroll correction. The closure scrolls to the loop's
        // proposed top, then measures the target fragment there.
        let estimate = Double(clamped) / Double(docLength) * Double(docHeight)
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
            return minY
        }
    }
}
