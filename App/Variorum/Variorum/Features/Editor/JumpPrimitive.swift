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

@MainActor
enum JumpPrimitive {
    /// Lands the fragment containing `offset` (UTF-16) at the viewport top.
    static func jump(toOffset offset: Int, textView: NSTextView, scrollView: NSScrollView?) {
        guard let scrollView,
              let layoutManager = textView.textLayoutManager,
              let contentManager = layoutManager.textContentManager
        else { return }

        let clip = scrollView.contentView
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
                minY = Double(fragment.layoutFragmentFrame.minY)
                return false
            }
            return minY
        }
    }
}
