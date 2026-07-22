//
//  CanvasBoardGeometry.swift
//  Variorum
//
//  Phase 13b, Stage 4 (4E — N30/S4-7, built to the Batch 4E Phase-1
//  ruling): the canvas board's PURE geometry brain — spread-grid default
//  placement for unpositioned cards (the pile dies) and the realized-set
//  culling function (LAZY REALIZATION: the ruled answer to her "do we
//  have any plan for if there were tons of long blocks in a post?").
//
//  The P1 bound lives here as arithmetic: the realized set is a pure
//  function of (frames, visibleRect, margin) — its size is bounded by the
//  viewport, INDEPENDENT of post size (pinned in CanvasBoardGeometryTests;
//  the hosted half rides the DEBUG materialization counter, the
//  ReadingFlow precedent). No SwiftUI lazy container does free 2D
//  placement, so the view filters its ForEach through `realized` and the
//  scroll geometry feeds `visibleRect` — virtualization by construction,
//  not by container.
//
//  Nothing here persists: spread-grid defaults are derived (index among
//  unpositioned cards, in pointer order); the store learns a position
//  only when the author drags (the A7 rule, untouched).
//

import CoreGraphics
import Foundation

nonisolated enum CanvasBoardGeometry {
    /// The default card size (resizable per card — sizes are LOCAL view
    /// memory this batch, the Phase-1 ruling's (b); `canvas_layout` has no
    /// size home and 4E has no core allowance).
    static let defaultCardSize = CGSize(width: 240, height: 170)
    /// Clamps for the resize grip.
    static let minCardSize = CGSize(width: 160, height: 90)
    static let maxCardSize = CGSize(width: 640, height: 600)
    /// Grid gutter between spread cards, and the board's top-left inset.
    static let gridGutter: CGFloat = 20
    static let boardInset: CGFloat = 20
    /// The culling margin: one default-card pitch in every direction, so
    /// scrolling reveals already-realized cards at the edge instead of
    /// popping blanks.
    static let cullingMargin: CGFloat = 260
    /// Re-cull hysteresis: the realized set recomputes only when the
    /// viewport has moved this far since the last cull (half the margin —
    /// scrolling never outruns the margin between culls).
    static let recullThreshold: CGFloat = 130
    /// The overview's scale floor (the fit-all ruling's option (i)): below
    /// this the overview clamps and scrolls for the rest.
    static let overviewScaleFloor: CGFloat = 0.25

    /// Square-ish spread: the column count for n unpositioned cards.
    static func spreadColumns(count: Int) -> Int {
        max(1, Int(Double(count).squareRoot().rounded(.up)))
    }

    /// Where the spread grid starts: the board inset when nothing is
    /// positioned, else BELOW the positioned cards' bounding box (the
    /// ruling's endorsed rider — defaults never hide under her
    /// arrangement).
    static func gridOrigin(positionedFrames: [CGRect]) -> CGPoint {
        guard let maxY = positionedFrames.map(\.maxY).max() else {
            return CGPoint(x: boardInset, y: boardInset)
        }
        return CGPoint(x: boardInset, y: maxY + gridGutter * 2)
    }

    /// The spread-grid default position for the card at `index` among the
    /// unpositioned cards (pointer order). Pitch rides the DEFAULT card
    /// size deliberately: resized cards may overlap their grid neighbors
    /// until dragged, and dragging is exactly what persists a position.
    static func spreadPosition(index: Int, columns: Int, origin: CGPoint) -> CGPoint {
        let pitchX = defaultCardSize.width + gridGutter
        let pitchY = defaultCardSize.height + gridGutter
        let column = index % max(columns, 1)
        let row = index / max(columns, 1)
        return CGPoint(
            x: origin.x + CGFloat(column) * pitchX,
            y: origin.y + CGFloat(row) * pitchY)
    }

    /// THE realized set (the 4E realization pin's subject): the cards
    /// whose frames intersect the visible rect inflated by `margin`.
    /// Pure — the view model feeds frames + the scroll geometry's visible
    /// rect; the ForEach renders exactly this set (plus the live pane's
    /// card and any in-flight drag, the caller's exemptions).
    static func realized(
        frames: [String: CGRect], visible: CGRect, margin: CGFloat = cullingMargin
    ) -> Set<String> {
        guard !visible.isEmpty else { return [] }
        let inflated = visible.insetBy(dx: -margin, dy: -margin)
        return Set(frames.filter { inflated.intersects($0.value) }.keys)
    }

    /// The bounding box of every card frame (fit-all's input).
    static func boundingBox(frames: some Collection<CGRect>) -> CGRect {
        guard let first = frames.first else { return .zero }
        return frames.dropFirst().reduce(first) { $0.union($1) }
    }

    /// Fit-all's scale: fit the bounding box into the viewport, never
    /// above 1:1, clamped at the floor (below the floor the overview
    /// scrolls for the rest — honest, not a lie of fit).
    static func fitScale(bounds: CGRect, viewport: CGSize) -> CGFloat {
        guard bounds.width > 0, bounds.height > 0,
              viewport.width > 0, viewport.height > 0 else { return 1 }
        let scale = min(viewport.width / bounds.width, viewport.height / bounds.height, 1)
        return max(scale, overviewScaleFloor)
    }

    /// Clamp a resize to the legal card range.
    static func clampedSize(_ size: CGSize) -> CGSize {
        CGSize(
            width: min(max(size.width, minCardSize.width), maxCardSize.width),
            height: min(max(size.height, minCardSize.height), maxCardSize.height))
    }
}
