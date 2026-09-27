//
//  LandingAim.swift
//  Variorum (Mac) — Surface (beside `LandingAuthority`, whose policies name
//  an aim kind, and `ViewportCarry`, whose `anchor(_:)` is the one door from
//  a fraction to a SwiftUI `UnitPoint`)
//
//  **18l-b UNIT U2 — THE AIM KIND.** The one landing authority converges ONE
//  number to zero: how far the target sits from where its landing puts it —
//  its "top", in the authority's own word (`LandingAuthority.noteTop`). Until
//  this unit every adopter computed that number in its own body, because
//  every adopter before note Read (18l U1) put its target at the viewport's
//  TOP, where the number is simply the row's top. Note Read's two faces rest
//  a block at a viewport FRACTION (the page at 0.08, the edit face centred,
//  or a fraction a mode switch carried), and the Takes article REVEALS a
//  block only when it is off screen, minimally, at the nearest edge (her
//  ruling R-Q1). Three answers to "where is home", so the policy now SAYS
//  which one it is — `LandingPolicy.aim` — and this file holds the three
//  arithmetics, pure, in one place (the charter's words: *"grow the
//  authority an aim kind (top · minimal-reveal · viewport-fraction —
//  `ViewportCarry.anchor` supplies the vocabulary)"*).
//
//  **What moved here, and why it is a MOVE.** Two brains were written
//  beside their surfaces and handed forward for this hoist: note Read's
//  fraction residual (18l U1's JC 2 — `ReadLandingResidual`, written *"for
//  18l-b U2 to hoist"*) and the Takes article's reveal decision and reveal
//  edge (17p batch a's `revealDecision` / `revealAnchor`, ruled R-Q1). Their
//  BODIES moved here unchanged; their old names stay reachable at their old
//  addresses as typealiases and one-line forwards (the 3C parity pattern),
//  so every pin that asked them a question asks it unmodified. Where a
//  landing PUTS a block is product and is not this file's to change: the
//  numbers below are the shipped ones, byte for byte.
//
//  Pure: no view, no store, no clock — every input handed in.
//

import CoreGraphics
import SwiftUI

/// **Where a landing puts its target — as POLICY data** (`LandingPolicy.aim`).
nonisolated enum LandingAimKind: String, Equatable, CaseIterable {
    /// The row's top at the viewport's top. The book Outline, the reading
    /// flow and the book Index pane (each aims `scrollTo(id, anchor: .top)`
    /// and reports the row's top as its residual — the identity arm below).
    case top
    /// Only when the row is not fully on screen, and then minimally, to the
    /// nearest edge — never to the top (her ruling R-Q1, *"remember + reveal
    /// only"*). The Takes article column. Home is ANY place where the row is
    /// fully on screen.
    case minimalReveal
    /// The block's f-point at the viewport's f-point (`ViewportCarry`'s
    /// definition, which is exactly `scrollTo(_:anchor:)`'s act), clamped by
    /// the page's own ends. Note Read's two faces; the fraction itself is the
    /// landing's (a resting anchor, or a fraction a mode switch carried).
    case viewportFraction
}

nonisolated enum LandingAim {
    /// **The vocabulary door** — a fraction becomes the `UnitPoint` a SwiftUI
    /// `scrollTo` is handed, through `ViewportCarry.anchor(_:)` and nothing
    /// else: 0 is the top edge (the `.top` kind's aim, the reveal's head),
    /// 1 the bottom edge (the reveal's foot), anything between a carried or
    /// resting fraction.
    static func anchor(fraction: Double) -> UnitPoint {
        ViewportCarry.anchor(fraction)
    }

    /// What a surface can see of its target at one moment, in the target
    /// column's own terms. `rowFrame` is the row's frame relative to the
    /// viewport (`minY == 0` is the viewport's top edge) — nil when the row
    /// is not realized. The page facts matter only to the fraction arm's
    /// clamp; the fraction only to the fraction arm.
    nonisolated struct Sighting: Equatable {
        var rowFrame: CGRect?
        var viewportHeight: CGFloat
        var fraction: CGFloat = 0
        var offset: CGFloat = 0
        var minOffset: CGFloat = 0
        var maxOffset: CGFloat = 0
    }

    /// **THE ONE QUESTION the authority converges, answered per kind:** how
    /// far is the target from home, in points (0 is home; positive means the
    /// page must scroll DOWN to bring it home). nil when the surface cannot
    /// yet say — the row is not realized, or the viewport not measured — which
    /// the authority reads as "unreported" (`LandingPolicy
    /// .correctsAnUnreportedTarget` decides what that earns).
    static func residual(_ kind: LandingAimKind, _ sighting: Sighting) -> CGFloat? {
        guard sighting.viewportHeight > 0, let row = sighting.rowFrame else { return nil }
        switch kind {
        case .top:
            return row.minY
        case .minimalReveal:
            return MinimalReveal.residual(rowFrame: row, viewportHeight: sighting.viewportHeight)
        case .viewportFraction:
            return ViewportFraction.residual(
                blockTop: row.minY, blockHeight: row.height,
                viewportHeight: sighting.viewportHeight, anchorY: sighting.fraction,
                offset: sighting.offset, minOffset: sighting.minOffset,
                maxOffset: sighting.maxOffset)
        }
    }

    // MARK: - The viewport-fraction arm (hoisted from note Read — 18l U1, JC 2)

    /// **Note Read's resting-anchor arithmetic, moved here unchanged**
    /// (`ReadLandingResidual` is now this type's old name, a typealias in
    /// `Features/ReadMode/ReadNoteLanding.swift`; its pins in
    /// `ReadNoteHeightsTests` ride unmodified).
    nonisolated enum ViewportFraction {
        /// **The landed block's distance from its resting place, in points**
        /// — 0 is home; positive means the block sits BELOW it (the page
        /// must scroll down to bring it home).
        ///
        /// - `blockTop`: the block's top relative to the viewport's top.
        /// - `anchorY`: the fraction (`ViewportCarry` — the block's
        ///   anchor-point at the viewport's anchor-point; 0.08 the page, 0.5
        ///   the edit face).
        /// - `offset` / `minOffset` / `maxOffset`: where the page is and how
        ///   far it can go. A resting place the page cannot reach is
        ///   replaced by the nearest one it can — so the first block of a
        ///   note, "centred", is home at the page's top rather than a
        ///   landing that can never finish.
        static func residual(
            blockTop: CGFloat, blockHeight: CGFloat, viewportHeight: CGFloat, anchorY: CGFloat,
            offset: CGFloat, minOffset: CGFloat, maxOffset: CGFloat
        ) -> CGFloat {
            let rest = CGFloat(ViewportCarry.topInset(
                fraction: Double(anchorY), blockHeight: Double(blockHeight),
                viewportHeight: Double(viewportHeight)))
            let wanted = offset + blockTop - rest
            let reachable = min(max(wanted, minOffset), max(minOffset, maxOffset))
            return reachable - offset
        }
    }

    // MARK: - The minimal-reveal arm (hoisted from the Takes article — 17p
    //         batch a, her ruling R-Q1)

    /// **The Takes article's reveal rule, moved here unchanged**
    /// (`TakesArticleScroll.ArticleReveal` / `.ArticleRevealAim` are now
    /// typealiases of `Decision` / `Edge`, and `revealDecision` /
    /// `revealAnchor` one-line forwards to `decision` / `edge`; their pins in
    /// `TakesArticleScrollTests` ride unmodified).
    nonisolated enum MinimalReveal {
        /// What a landing may ask the article for. **Never a top anchor:**
        /// her words on the shipped behaviour were *"the page keeps trying to
        /// jump to the bottom and now show the text above"* — anchoring a
        /// slot's top at the viewport's top is exactly what pushed every
        /// earlier block off the screen, and the typewriter room made the
        /// LAST block a legal place to stop. A landing now either does
        /// nothing or reveals, minimally.
        nonisolated enum Decision: Equatable {
            /// The slot is already fully on screen; the page does not move.
            case none
            /// The slot is not fully on screen: scroll the minimum that shows
            /// it (`anchor: nil`), never to the top.
            case reveal
        }

        /// Which edge of the page a reveal puts the row at — the MINIMAL
        /// scroll stated as an edge: a row below the fold comes up to the
        /// foot (the rows above it stay), a row above the fold comes down to
        /// the head. A row the column has not realized is placed by which
        /// side of the realized rows it lies on. A model-side word, mapped to
        /// a SwiftUI anchor by `anchor(_:)` below. Never the far edge: her
        /// words on the shipped behaviour were *"the page keeps trying to
        /// jump to the bottom and now show the text above"*.
        nonisolated enum Edge: Equatable {
            case head
            case foot
        }

        /// **THE RULE, pure.** `rowFrame` is the row's frame in the article
        /// scroll view's own space (`.scrollView`), i.e. `minY == 0` is the
        /// viewport's top edge. A row we have no frame for is one a lazy
        /// column has not realized — which is proof it is NOT on screen, so
        /// it reveals; and a viewport we have not measured yet decides
        /// nothing, so it reveals too and the view's own minimal scroll
        /// settles the rest.
        static func decision(rowFrame: CGRect?, viewportHeight: CGFloat) -> Decision {
            guard viewportHeight > 0, let rowFrame else { return .reveal }
            // A row TALLER than the viewport can never be fully on screen; it
            // is revealed when its top is (nothing above it could stay
            // visible anyway, so "minimal" and "top" coincide for that one
            // shape).
            if rowFrame.height > viewportHeight {
                return rowFrame.minY >= -0.5 && rowFrame.minY < viewportHeight - 0.5
                    ? .none : .reveal
            }
            // A generous pixel of slack: a row flush with an edge is on
            // screen.
            return rowFrame.minY >= -0.5 && rowFrame.maxY <= viewportHeight + 0.5
                ? .none : .reveal
        }

        /// Pure: which edge reaches the row. A realized row goes by its frame
        /// — above the fold → `.head`, else `.foot`. An unrealized row lies
        /// beyond the realized rows on one side — below them → `.foot` (it
        /// lands at the foot with the rows above it still showing), above
        /// them → `.head`. A shape that says neither takes `.foot` (a landing
        /// is a block she was working in, and the page opens at the top).
        static func edge(
            for placementID: String, rowFrame: CGRect?, order: [String], realizedRows: Set<String>
        ) -> Edge {
            if let rowFrame { return rowFrame.minY < 0 ? .head : .foot }
            guard let target = order.firstIndex(of: placementID) else { return .foot }
            let indices = order.indices.filter { realizedRows.contains(order[$0]) }
            guard let low = indices.min(), let high = indices.max() else { return .foot }
            if target > high { return .foot }
            if target < low { return .head }
            return .foot
        }

        /// **The kind's residual — NEW at 18l-b U2**, and it is the decision
        /// above restated as the number the authority converges, so that the
        /// authority's "home" and the article's own `.none` are ONE rule:
        /// exactly 0 while `decision` says `.none`; otherwise the signed
        /// distance the minimal reveal moves the page — negative for a row
        /// above the fold (its top, to the head), positive for a row below
        /// (its bottom past the foot; a TALL row's top, which is what its
        /// reveal brings to the head). Every non-zero answer is more than the
        /// decision's half-point slack in magnitude, so a policy tolerance of
        /// 0.5 makes "within tolerance" and "on screen" the same statement.
        static func residual(rowFrame: CGRect, viewportHeight: CGFloat) -> CGFloat {
            if decision(rowFrame: rowFrame, viewportHeight: viewportHeight) == .none { return 0 }
            if rowFrame.minY < -0.5 { return rowFrame.minY }
            if rowFrame.height > viewportHeight { return rowFrame.minY }
            return rowFrame.maxY - viewportHeight
        }

        /// The SwiftUI anchor a reveal hands `scrollTo` — the head is the top
        /// edge, the foot the bottom edge, through the one vocabulary door
        /// (`ViewportCarry.anchor`): `UnitPoint(x: 0.5, y: 0)` and
        /// `UnitPoint(x: 0.5, y: 1)`, the exact values `.top` and `.bottom`
        /// always were.
        static func anchor(_ edge: Edge) -> UnitPoint {
            LandingAim.anchor(fraction: edge == .head ? 0 : 1)
        }
    }
}
