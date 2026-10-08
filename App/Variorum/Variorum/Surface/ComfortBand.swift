//
//  ComfortBand.swift
//  Variorum (Mac) — Surface (the pure surface authorities' home, beside
//  `ViewportCarry`, `LandingAim` and `LandingAuthority`)
//
//  **18l-c UNIT U8 (b) — THE COMFORT BAND.** Her question at the 18l-c
//  kickoff, verbatim: *"I know that exact on the screen cursor position is not
//  something we can offer when switching between modes, but could we ensure
//  that there is an offset from the top / bottom of the screen so a user isn't
//  navigating to a different mode and their text is on the extreme top or
//  bottom? or does that have the same challenges as exact cursor position? if
//  it's possible I'd like to see it done."* The roster's answer (YES — cheaper
//  than exact-position parity): a MODE-SWITCH landing clamps its resolved
//  place so the target rests inside a band — the surface's resting TOP AIR at
//  the top edge, about TWO LINES of room at the bottom — never at the extreme
//  edge; a place already inside the band stays EXACTLY where it is (the ruled
//  viewport-fraction carries are untouched mid-band).
//
//  **Scope is the mode switch's landing** — the callers decide that, never
//  this file: Write's bare mode-switch arrival (its #98(a) reveal and the
//  13u2b carry), the Takes article's ENTRY landing (her R-18l-13's road), and
//  note Read's mode-switch seed — **plus, since VX-85 (the 13o follow-up run,
//  its provisional call D-4), a SEARCH passage's landing in Write**, whose
//  find bar overlays the clip's top: the match rests in the band read against
//  the bar-adjusted viewport, never flush under the bar. Clicks, find STEPS
//  (⌘G — AppKit's finder reveals those) and note-opens keep their shipped
//  reveals.
//
//  **The two edges are NAMED, and they are the SURFACE's own numbers.** The
//  top is the surface's RESTING top air — the room its page shows above its
//  first line at rest (Write: the text container's 24-pt inset; the Takes
//  article: its column's 18-pt top padding — KnownIssues row 94's remedy
//  sketch; note Read's faces: their column lead / page room). The bottom is
//  `bottomLines` of the surface's own line height — one constant for every
//  surface, so taste is one line.
//
//  **A target TALLER than the band keeps its resolved place.** The band is a
//  promise about where a target that FITS rests; a taller one cannot rest
//  inside it, and the surfaces already rule what a tall target does (the
//  13u2b carry's tall-block rule, #116(c) — the caret reveal after it; the
//  Takes article's tall-row rule under R-Q1 — its top on screen). Clamping it
//  would move a tall block the carry deliberately placed. A named boundary,
//  recorded in the unit's record.
//
//  Pure: no view, no store, no clock — every number is handed in.
//

import CoreGraphics
import Foundation

/// Where a mode switch's landing lets its target rest.
nonisolated struct ComfortBand: Equatable, Sendable {
    /// **THE NAMED CONSTANT — the room kept under a landed target**, in the
    /// surface's own lines (her *"an offset from the … bottom"*, the roster's
    /// *"about two lines of room at the bottom"*). Taste is this one number.
    static let bottomLines: CGFloat = 2

    /// Room between the viewport's top edge and the target's top: the
    /// surface's resting top air.
    let topAir: CGFloat
    /// Room between the target's bottom and the viewport's bottom edge.
    let bottomRoom: CGFloat

    init(topAir: CGFloat, bottomRoom: CGFloat) {
        self.topAir = max(0, topAir)
        self.bottomRoom = max(0, bottomRoom)
    }

    /// The surface's band: its resting top air, and `bottomLines` of its own
    /// line height.
    init(topAir: CGFloat, lineHeight: CGFloat) {
        self.init(topAir: topAir, bottomRoom: Self.bottomLines * max(0, lineHeight))
    }

    /// Does a target this tall FIT between the band's two edges in this
    /// viewport? A target that does not keeps its resolved place (the header).
    func fits(height: CGFloat, viewport: CGFloat) -> Bool {
        viewport > 0 && height >= 0 && height <= viewport - topAir - bottomRoom
    }

    /// **THE CLAMP.** A target whose resolved landing puts its top at `top`
    /// (relative to the viewport's top edge — negative above it) rests at the
    /// returned top: EXACTLY `top` when that is inside the band (the mid-band
    /// arm — a carried fraction stays exact), the band's TOP edge when it would
    /// rest in the top air or above the viewport, and the band's BOTTOM edge
    /// when its bottom would rest in the bottom room or below the viewport. A
    /// target that does not fit is returned unchanged.
    func clamp(top: CGFloat, height: CGFloat, viewport: CGFloat) -> CGFloat {
        guard fits(height: height, viewport: viewport) else { return top }
        return min(max(top, topAir), viewport - bottomRoom - height)
    }

    /// The same clamp in `ViewportCarry`'s fraction space (the block's
    /// f-point at the viewport's f-point, so its top sits at `f · (V − h)`):
    /// the fraction whose placement is the clamped top. Mid-band fractions
    /// come back EXACTLY (the ruled carries are untouched inside the band);
    /// a target that does not fit, or a viewport too short to hold any
    /// fraction, keeps its own.
    func clamp(fraction: Double, height: Double, viewport: Double) -> Double {
        let span = viewport - height
        guard span >= 1,
              fits(height: CGFloat(height), viewport: CGFloat(viewport))
        else { return fraction }
        let top = min(max(fraction, 0), 1) * span
        let clamped = Double(clamp(top: CGFloat(top), height: CGFloat(height),
                                   viewport: CGFloat(viewport)))
        guard abs(clamped - top) > 1e-9 else { return fraction }
        return clamped / span
    }

    // MARK: - Write's caret reveal, banded (#98(a) — then the band)

    /// **Where a mode switch rests Write's caret LINE** — the shipped #98(a)
    /// rule resolved first (a line already on screen stays exactly where it
    /// is; a line off screen lands at the viewport's top, `JumpPrimitive`'s
    /// contract), then the band clamps it: the off-screen line rests at the
    /// top air, not flush; a line on screen but in the top air or the bottom
    /// room moves the minimum into the band; a line mid-band never moves. The
    /// 1-pt slack is the reveal's own (the ladder's R1-11).
    func restCaretLine(top: CGFloat, height: CGFloat, viewport: CGFloat) -> CGFloat {
        let onScreen = top >= -1 && top + height <= viewport + 1
        return clamp(top: onScreen ? top : 0, height: height, viewport: viewport)
    }

    // MARK: - The Takes article's minimal reveal, banded (her R-Q1, with the
    //         band's edges standing in for the viewport's)

    /// **How far the row sits from home, the band standing in for the
    /// viewport** — 0 while the row rests inside the band (R-Q1's own
    /// "anywhere it is fully on screen", with the band's edges); otherwise the
    /// signed distance the page must scroll to bring it to the nearest band
    /// edge (positive: DOWN, the row too low; negative: UP, the row in the top
    /// air or above). The sign convention is `LandingAim`'s. A row taller than
    /// the band keeps the shipped rule (`LandingAim.MinimalReveal.residual` —
    /// its top on screen). Every non-zero answer is beyond half a point, so the
    /// article policy's 0.5 tolerance and "inside the band" are one statement.
    func revealResidual(rowFrame: CGRect, viewport: CGFloat) -> CGFloat {
        guard fits(height: rowFrame.height, viewport: viewport) else {
            return LandingAim.MinimalReveal.residual(rowFrame: rowFrame, viewportHeight: viewport)
        }
        let rest = clamp(top: rowFrame.minY, height: rowFrame.height, viewport: viewport)
        let residual = rowFrame.minY - rest
        return abs(residual) <= 0.5 ? 0 : residual
    }

    /// The reveal's DECISION, banded: `.none` exactly while `revealResidual`
    /// is 0 — one rule, never a second copy. A row the column has not realized
    /// (nil) reveals, as R-Q1's own decision says.
    func revealDecision(rowFrame: CGRect?, viewport: CGFloat) -> LandingAim.MinimalReveal.Decision {
        guard viewport > 0, let rowFrame else { return .reveal }
        return revealResidual(rowFrame: rowFrame, viewport: viewport) == 0 ? .none : .reveal
    }

    /// **The anchor's unit y a banded reveal hands `scrollTo`** — the row's
    /// f-point at the viewport's f-point (`ViewportCarry`'s definition, which
    /// IS `scrollTo(_:anchor:)`'s act), chosen so the row's top rests at the
    /// band's top edge (`.head`) or its bottom at the band's bottom edge
    /// (`.foot`). `rowHeight` is the row's measured height when the column has
    /// realized it, else the caller's estimate. nil when the row does not fit
    /// the band (or the viewport is not measured): the shipped edge anchor
    /// stands (`LandingAim.MinimalReveal.anchor`).
    func revealAnchorY(
        _ edge: LandingAim.MinimalReveal.Edge, rowHeight: CGFloat, viewport: CGFloat
    ) -> CGFloat? {
        let span = viewport - rowHeight
        guard span >= 1, fits(height: rowHeight, viewport: viewport) else { return nil }
        switch edge {
        case .head: return min(max(topAir / span, 0), 1)
        case .foot: return min(max((span - bottomRoom) / span, 0), 1)
        }
    }
}
