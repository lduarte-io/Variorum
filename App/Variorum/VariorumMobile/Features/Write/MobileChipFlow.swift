//
//  MobileChipFlow.swift
//  VariorumMobile
//
//  Parity D2 — the masthead chip crowding's honest answer (the routed
//  PC4b-4 + PC5-5 item: the identity chips grew to FIVE — date · tags ·
//  more info · blocks · lens — on one non-wrapping HStack, whose
//  lineLimit(1) chips would compress and clip the moment their content
//  grew: "lens: the other reading", "more info · 2", several tags).
//
//  The answer is OVERFLOW, not grouping or priority: the chips WRAP
//  onto further lines exactly when their content demands it — nothing
//  clips, nothing hides, no door moves behind a menu, and the calm
//  default holds (five bare words fit one line; the masthead grows only
//  when the note's identity genuinely has more to say). PROVISIONAL for
//  her sitting — grouping (one door, a sheet of surfaces) and priority
//  (a ⋯ tuck) were the other candidates, each one refactor away.
//
//  The row-breaking is a PURE brain (`rows(widths:available:spacing:)`)
//  so the arithmetic pins headlessly; the `Layout` conformance is its
//  thin SwiftUI face (the not-headless-testable class, recorded — the
//  screenshot walk carries its evidence).
//

import SwiftUI

struct MobileChipFlow: Layout {
    var hSpacing: CGFloat = 12
    var vSpacing: CGFloat = 4

    /// The ONE row-breaking rule: greedy fill, break when the next chip
    /// (plus its leading spacing) would cross the available width; a
    /// chip wider than the whole line gets a line of its own (never
    /// dropped). Pure — pinned in MobileChipFlowTests.
    nonisolated static func rows(
        widths: [CGFloat], available: CGFloat, spacing: CGFloat
    ) -> [[Int]] {
        var rows: [[Int]] = []
        var current: [Int] = []
        var x: CGFloat = 0
        for (index, width) in widths.enumerated() {
            if current.isEmpty {
                current = [index]
                x = width
            } else if x + spacing + width <= available {
                current.append(index)
                x += spacing + width
            } else {
                rows.append(current)
                current = [index]
                x = width
            }
        }
        if !current.isEmpty { rows.append(current) }
        return rows
    }

    /// An over-wide chip (a long lens name, many tag leaves — user text)
    /// CLAMPS to the available width so its `lineLimit(1)` truncation
    /// re-engages (D ladder R1-1: the ideal-width proposal let user text
    /// overflow the screen edge where the pre-D2 HStack truncated).
    /// Pure — the row brain and both layout passes share it.
    nonisolated static func clampedWidths(
        _ widths: [CGFloat], available: CGFloat
    ) -> [CGFloat] {
        guard available.isFinite else { return widths }
        return widths.map { min($0, available) }
    }

    func sizeThatFits(
        proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) -> CGSize {
        let available = proposal.width ?? .infinity
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let rows = Self.rows(
            widths: Self.clampedWidths(sizes.map(\.width), available: available),
            available: available, spacing: hSpacing)
        let height = rows.map { row in
            row.map { sizes[$0].height }.max() ?? 0
        }.reduce(0, +) + CGFloat(max(rows.count - 1, 0)) * vSpacing
        let contentWidth = rows.map { row in
            row.map { sizes[$0].width }.reduce(0, +)
                + CGFloat(max(row.count - 1, 0)) * hSpacing
        }.max() ?? 0
        // A nil OR infinite proposal answers with content width (D ladder
        // NIT R1-3 — echoing .infinity breaks any host that trusts it).
        let proposed = proposal.width
        let width = (proposed?.isFinite == true) ? proposed! : contentWidth
        return CGSize(width: width, height: height)
    }

    func placeSubviews(
        in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews,
        cache: inout ()
    ) {
        let ideal = subviews.map { $0.sizeThatFits(.unspecified) }
        let clamped = Self.clampedWidths(ideal.map(\.width), available: bounds.width)
        let rows = Self.rows(
            widths: clamped, available: bounds.width, spacing: hSpacing)
        var y = bounds.minY
        for row in rows {
            let rowHeight = row.map { ideal[$0].height }.max() ?? 0
            var x = bounds.minX
            for index in row {
                subviews[index].place(
                    at: CGPoint(x: x, y: y + (rowHeight - ideal[index].height) / 2),
                    proposal: ProposedViewSize(
                        width: clamped[index], height: ideal[index].height))
                x += clamped[index] + hSpacing
            }
            y += rowHeight + vSpacing
        }
    }
}
