//
//  CutFlowGeometry.swift
//  Variorum
//
//  QoL round 2026-07-29, batch 1 — **L1**, the divide ceremony's cut flow as
//  ONE BRAIN for measurement, layout, drawing and hit-testing.
//
//  The shipped flow used three mechanisms that had to agree and could not be
//  tested: `CutFlowLayout` placed subviews, a `GeometryReader` per slot
//  re-measured those placements into a `PreferenceKey` dictionary, and the drag
//  scored against that dictionary. It also realized a `Button` + `ZStack` +
//  hover tracker + `GeometryReader` per legal cut position — ~2,766 view
//  elements for three 400-word takes, each measured twice per layout pass
//  (measured: 6.3 s for ONE mount, 8.7 s for ONE click; at her real scale —
//  four 3,000-word takes — a single click did not complete inside a 600-second
//  test timeout).
//
//  Here the wrap arithmetic is a pure function over pre-measured token widths,
//  computed once per (take, width). The view draws from it and the pointer
//  resolves against it, so the two cannot disagree — and the arithmetic is
//  finally unit-testable, which the `Layout` conformance never was.
//

import AppKit
import Foundation

/// One take's cut flow, laid out: where every word sits and where every legal
/// cut position sits, in the flow's own coordinates.
struct CutFlowGeometry: Equatable {
    struct Token: Equatable {
        let text: String
        let frame: CGRect
    }

    struct Slot: Equatable {
        let boundary: Int
        let frame: CGRect
        /// A sentence end, newline or text edge — the gentle settle's visual
        /// half: drawn taller, and it catches a drag from slightly further.
        let isStrong: Bool
    }

    var tokens: [Token] = []
    var slots: [Slot] = []
    var size: CGSize = .zero

    /// Slot marks are a FIXED width, deliberately: the shipped flow gave the
    /// cut's own slot double width, so the entire paragraph re-wrapped every
    /// time the ✂ moved. Fixed widths make the layout independent of the cut,
    /// which is both calmer to look at and what lets one geometry serve every
    /// cut position (cache once per take, not once per placement).
    static let slotWidth: CGFloat = 9
    static let slotHeight: CGFloat = 18
    static let lineSpacing: CGFloat = 4
    /// Extra catch for strong slots, in points — the settle's geometry.
    static let strongPull: CGFloat = 4

    /// Lays a take's flow out at `width`. `strong` is the take's cached strong
    /// boundary set (never re-derived here — deriving it per call is the exact
    /// defect this type replaces).
    static func make(
        flow: [WCutPlacement.FlowItem],
        strong: Set<Int>,
        width: CGFloat,
        font: NSFont
    ) -> CutFlowGeometry {
        guard width > 0 else { return CutFlowGeometry() }
        var geometry = CutFlowGeometry()
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let lineHeight = max(slotHeight, (font.ascender - font.descender + font.leading).rounded(.up))

        var x: CGFloat = 0
        var y: CGFloat = 0
        var widest: CGFloat = 0

        func newline() {
            widest = max(widest, x)
            x = 0
            y += lineHeight + lineSpacing
        }

        for item in flow {
            switch item {
            case .slot(let boundary):
                if x > 0, x + slotWidth > width { newline() }
                geometry.slots.append(Slot(
                    boundary: boundary,
                    frame: CGRect(x: x, y: y, width: slotWidth, height: lineHeight),
                    isStrong: strong.contains(boundary)))
                x += slotWidth
            case .token(let text, let breaksLineAfter):
                let measured = (text as NSString).size(withAttributes: attributes).width.rounded(.up)
                if x > 0, x + measured > width { newline() }
                geometry.tokens.append(Token(
                    text: text,
                    frame: CGRect(x: x, y: y, width: measured, height: lineHeight)))
                x += measured
                if breaksLineAfter { newline() }
            }
        }
        widest = max(widest, x)
        geometry.size = CGSize(width: min(widest, width), height: y + lineHeight)
        return geometry
    }

    /// The slot nearest a point: row first (the slot whose line the pointer is
    /// on wins outright), then horizontal distance, with a few points of extra
    /// catch for strong slots. This is the drag's whole brain, and it reads
    /// only the cached frames — no text, no scanning.
    func nearestSlot(to point: CGPoint) -> Int? {
        var best: (boundary: Int, score: CGFloat)?
        for slot in slots {
            let dy = abs(point.y - slot.frame.midY)
            let dx = abs(point.x - slot.frame.midX)
            let pull = slot.isStrong ? Self.strongPull : 0
            // A full row of vertical distance outweighs any horizontal
            // distance within a row (rows are ~18 pt tall).
            let score = dy * 100 + max(0, dx - pull)
            if best == nil || score < best!.score { best = (slot.boundary, score) }
        }
        return best?.boundary
    }

    /// The frame of the slot at `boundary` — where the ✂ is drawn.
    func slotFrame(for boundary: Int) -> CGRect? {
        slots.first { $0.boundary == boundary }?.frame
    }
}
