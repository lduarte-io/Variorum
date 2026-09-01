//
//  TrailingFlow.swift
//  Variorum (Mac)
//
//  The Act 10 correction round, batch A — row 58: **the masthead's second
//  row is ONE layout, and the path chip and the tag cluster never
//  intersect.** Her walk found the `~/book` chip drawn UNDER the first tag
//  cards on any note with several tags, and gone entirely under the open
//  tag field. The chip was centered on the masthead's full width behind an
//  inset the 240-pt title floor capped, so past three cards the cards ran
//  over it; the open field's overlay reached 196 pt further left and the
//  chip was faded out rather than moved.
//
//  This layout is the cluster's half of the answer: a RIGHT-ALIGNED
//  WRAPPING ROW. The cards (and the ＃ door after them) fill from the right
//  edge and wrap onto further lines exactly when the width says so —
//  nothing clips, nothing hides, no door moves. Every line keeps
//  `leadingReserve` free at its LEFT, which is where the inline tag field
//  slides out of the ＃ — so the field never reaches what sits left of the
//  flow (the path chip), whichever line the ＃ is on. One subview may be
//  tagged the FIELD ANCHOR (`TrailingFlow.anchored()`): it takes no room
//  and is placed at the last line's leading edge with that line's height,
//  so an overlay hung off it sits beside the ＃'s line.
//
//  The row-breaking rule is a PURE brain (`rows(widths:available:spacing:)`)
//  — the same signature and the same rule the phone's `MobileChipFlow`
//  carries (a deliberate twin, recorded in the round's record for the
//  Shared/ hoist at the next touch of either — the forked-brains row's
//  discipline: a hoist is a move, never a rewrite, so the two are kept
//  byte-compatible here). Items on one line align on their FIRST TEXT
//  BASELINE (rows 10/11's discipline), and the flow reports its first
//  line's baseline upward so a `.firstTextBaseline` row beside it — the
//  path chip — sits on the cards' line.
//

import SwiftUI

struct TrailingFlow: Layout {
    var itemSpacing: CGFloat = 4
    var lineSpacing: CGFloat = 4
    /// Room every line keeps free at its leading edge (the inline tag
    /// field's width plus its gap). Zero for a plain wrapping row.
    var leadingReserve: CGFloat = 0

    /// Marks the ONE subview the layout places at the last line's leading
    /// edge with zero width (an overlay anchor); it never counts as an item.
    struct AnchorKey: LayoutValueKey {
        static let defaultValue = false
    }

    /// The ONE row-breaking rule: greedy fill, break when the next item
    /// (plus its leading spacing) would cross the available width; an item
    /// wider than the whole line gets a line of its own (never dropped).
    /// Byte-compatible with `MobileChipFlow.rows`.
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

    /// One laid-out line: which items (indices into `items`), its width,
    /// its height, and the baseline every item on it aligns to (measured
    /// from the line's top).
    struct Line {
        var members: [Int]
        var width: CGFloat
        var height: CGFloat
        var baseline: CGFloat
    }

    /// Everything a pass needs, computed once per pass from the subviews'
    /// ideal sizes and baselines.
    private struct Plan {
        var items: [Int]            // subview indices that are items
        var anchor: Int?            // the anchor subview, if any
        var sizes: [CGSize]         // per subview
        var baselines: [CGFloat]    // per subview (first text baseline from its top)
        var lines: [Line]
        var contentWidth: CGFloat   // the widest line
        var height: CGFloat
    }

    private func plan(width: CGFloat, subviews: Subviews) -> Plan {
        var items: [Int] = []
        var anchor: Int?
        var sizes: [CGSize] = []
        var baselines: [CGFloat] = []
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            sizes.append(size)
            baselines.append(subview.dimensions(in: .unspecified)[VerticalAlignment.firstTextBaseline])
            if subview[AnchorKey.self] {
                anchor = index
            } else {
                items.append(index)
            }
        }
        let available = width.isFinite ? max(0, width - leadingReserve) : .infinity
        let rows = Self.rows(
            widths: items.map { sizes[$0].width }, available: available, spacing: itemSpacing)
        var lines: [Line] = []
        for row in rows {
            let members = row.map { items[$0] }
            let lineWidth = members.map { sizes[$0].width }.reduce(0, +)
                + CGFloat(max(members.count - 1, 0)) * itemSpacing
            let baseline = members.map { baselines[$0] }.max() ?? 0
            let height = members.map { baseline - baselines[$0] + sizes[$0].height }.max() ?? 0
            lines.append(Line(members: members, width: lineWidth, height: height, baseline: baseline))
        }
        let height = lines.map(\.height).reduce(0, +)
            + CGFloat(max(lines.count - 1, 0)) * lineSpacing
        return Plan(
            items: items, anchor: anchor, sizes: sizes, baselines: baselines, lines: lines,
            contentWidth: lines.map(\.width).max() ?? 0, height: height)
    }

    func sizeThatFits(
        proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) -> CGSize {
        let proposed = proposal.width
        let plan = plan(width: proposed ?? .infinity, subviews: subviews)
        // A finite proposal is answered with itself (the flow fills the
        // width it is given and right-aligns inside it); nil or infinite
        // with the content's own width PLUS the reserve — the reserve is
        // part of what the flow needs, or a host with room would hand it
        // exactly its cards' width and it would wrap for nothing.
        let width = (proposed?.isFinite == true) ? proposed! : plan.contentWidth + leadingReserve
        return CGSize(width: width, height: plan.height)
    }

    func placeSubviews(
        in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) {
        let plan = plan(width: bounds.width, subviews: subviews)
        var y = bounds.minY
        var lastLineLeading = bounds.maxX
        var lastLineTop = bounds.minY
        var lastLineHeight: CGFloat = 0
        for line in plan.lines {
            var x = bounds.maxX - line.width
            lastLineLeading = x
            lastLineTop = y
            lastLineHeight = line.height
            for index in line.members {
                let size = plan.sizes[index]
                subviews[index].place(
                    at: CGPoint(x: x, y: y + (line.baseline - plan.baselines[index])),
                    proposal: ProposedViewSize(size))
                x += size.width + itemSpacing
            }
            y += line.height + lineSpacing
        }
        if let anchor = plan.anchor {
            subviews[anchor].place(
                at: CGPoint(x: lastLineLeading, y: lastLineTop),
                proposal: ProposedViewSize(width: 0, height: lastLineHeight))
        }
    }

    /// The first line's baseline, so a `.firstTextBaseline` host aligns its
    /// neighbours to the cards' line rather than to the flow's bottom.
    func explicitAlignment(
        of guide: VerticalAlignment, in bounds: CGRect, proposal: ProposedViewSize,
        subviews: Subviews, cache: inout ()
    ) -> CGFloat? {
        guard guide == .firstTextBaseline || guide == .lastTextBaseline else { return nil }
        let plan = plan(width: bounds.width, subviews: subviews)
        guard let first = plan.lines.first else { return nil }
        if guide == .firstTextBaseline { return first.baseline }
        let lastTop = plan.height - (plan.lines.last?.height ?? 0)
        return lastTop + (plan.lines.last?.baseline ?? 0)
    }
}

extension View {
    /// Mark this view as a `TrailingFlow`'s field anchor: no room of its
    /// own, placed at the last line's leading edge with the line's height.
    func trailingFlowAnchor() -> some View {
        layoutValue(key: TrailingFlow.AnchorKey.self, value: true)
    }
}
