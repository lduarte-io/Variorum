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

    func sizeThatFits(
        proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) -> CGSize {
        let available = proposal.width ?? .infinity
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let rows = Self.rows(
            widths: sizes.map(\.width), available: available, spacing: hSpacing)
        let height = rows.map { row in
            row.map { sizes[$0].height }.max() ?? 0
        }.reduce(0, +) + CGFloat(max(rows.count - 1, 0)) * vSpacing
        let contentWidth = rows.map { row in
            row.map { sizes[$0].width }.reduce(0, +)
                + CGFloat(max(row.count - 1, 0)) * hSpacing
        }.max() ?? 0
        return CGSize(width: proposal.width ?? contentWidth, height: height)
    }

    func placeSubviews(
        in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews,
        cache: inout ()
    ) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let rows = Self.rows(
            widths: sizes.map(\.width), available: bounds.width, spacing: hSpacing)
        var y = bounds.minY
        for row in rows {
            let rowHeight = row.map { sizes[$0].height }.max() ?? 0
            var x = bounds.minX
            for index in row {
                subviews[index].place(
                    at: CGPoint(x: x, y: y + (rowHeight - sizes[index].height) / 2),
                    proposal: ProposedViewSize(sizes[index]))
                x += sizes[index].width + hSpacing
            }
            y += rowHeight + vSpacing
        }
    }
}
