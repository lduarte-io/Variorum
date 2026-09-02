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

    /// Marks an item that never starts a line by itself: when the row rule
    /// would wrap it alone, the item before it comes down with it (the ＃
    /// door after the cards — the first walk on the fixed row showed five
    /// cards exactly filling a line and the door orphaned on the next).
    struct KeepWithPreviousKey: LayoutValueKey {
        static let defaultValue = false
    }

    /// The orphan rule, applied AFTER the row rule (pure — pinned): a row
    /// that begins with a keep-with-previous item takes the last item of
    /// the row before it, provided that row keeps at least one item.
    nonisolated static func keepingTogether(
        _ rows: [[Int]], keepWithPrevious: Set<Int>
    ) -> [[Int]] {
        var rows = rows
        var index = 1
        while index < rows.count {
            if let first = rows[index].first, keepWithPrevious.contains(first),
               rows[index - 1].count >= 2 {
                let moved = rows[index - 1].removeLast()
                rows[index].insert(moved, at: 0)
            }
            index += 1
        }
        return rows
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
        var keepWithPrevious = Set<Int>()   // positions within `items`
        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            sizes.append(size)
            baselines.append(subview.dimensions(in: .unspecified)[VerticalAlignment.firstTextBaseline])
            if subview[AnchorKey.self] {
                anchor = index
            } else {
                if subview[KeepWithPreviousKey.self] { keepWithPrevious.insert(items.count) }
                items.append(index)
            }
        }
        // Row 80b: the reserve YIELDS when honoring it would starve the
        // line's minimum (the widest item with its keep-with-previous item
        // beside it) — a full-width line the row-2 layout gave the cluster
        // has nothing to its left for the field to reach, so the room the
        // reserve kept is the line's own. On a one-line row the layout only
        // chooses one line when the minimum WITH the reserve fits, so the
        // reserve never yields beside the chip.
        let bareMinimum = Self.minimumLineWidth(
            widths: items.map { sizes[$0].width }, keepWithPrevious: keepWithPrevious,
            spacing: itemSpacing, leadingReserve: 0)
        let available = width.isFinite
            ? min(width, max(width - leadingReserve, bareMinimum))
            : .infinity
        let rows = Self.keepingTogether(
            Self.rows(widths: items.map { sizes[$0].width }, available: available, spacing: itemSpacing),
            keepWithPrevious: keepWithPrevious)
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

    /// **The flow's MINIMUM line width** (row 80b): the widest item, plus —
    /// when an item is marked keep-with-previous (the ＃ door) — that item
    /// and a spacing beside it, plus the leading reserve. A host that offers
    /// the flow at least this can lay every item on some line with the door
    /// beside a card; offered less, a card would overflow the flow's edge
    /// and the door would orphan (her screenshot). SwiftUI's convention: a
    /// ZERO-width proposal is answered with this minimum.
    nonisolated static func minimumLineWidth(
        widths: [CGFloat], keepWithPrevious: Set<Int>, spacing: CGFloat, leadingReserve: CGFloat
    ) -> CGFloat {
        let widest = widths.enumerated().filter { !keepWithPrevious.contains($0.offset) }
            .map(\.element).max() ?? 0
        let widestKept = widths.enumerated().filter { keepWithPrevious.contains($0.offset) }
            .map(\.element).max() ?? 0
        return leadingReserve + widest + (widestKept > 0 ? spacing + widestKept : 0)
    }

    private func minimumWidth(subviews: Subviews) -> CGFloat {
        var widths: [CGFloat] = []
        var kept = Set<Int>()
        for subview in subviews where !subview[AnchorKey.self] {
            if subview[KeepWithPreviousKey.self] { kept.insert(widths.count) }
            widths.append(subview.sizeThatFits(.unspecified).width)
        }
        return Self.minimumLineWidth(
            widths: widths, keepWithPrevious: kept, spacing: itemSpacing,
            leadingReserve: leadingReserve)
    }

    func sizeThatFits(
        proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) -> CGSize {
        let proposed = proposal.width
        // Row 80b: a zero-width proposal asks for the minimum (the
        // convention `MastheadRowTwo` relies on to decide one line or two).
        if proposed == 0 {
            let plan = plan(width: .infinity, subviews: subviews)
            return CGSize(width: minimumWidth(subviews: subviews), height: plan.height)
        }
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
            // Row 90 (the correction round, batch G — found at a ~950-pt
            // window with an inspector open, the masthead ~270): a line
            // WIDER than the flow's bounds — one card wider than the room
            // right of the path chip — used to start LEFT of the flow's own
            // edge (`maxX − width` < `minX`) and draw over the chip. The
            // line now starts no earlier than the flow's leading edge, and
            // an item that would still run past the trailing edge is
            // PROPOSED the width that remains, so a chrome label truncates
            // (P-8) instead of covering its neighbour.
            var x = max(bounds.minX, bounds.maxX - line.width)
            lastLineLeading = x
            lastLineTop = y
            lastLineHeight = line.height
            for index in line.members {
                var size = plan.sizes[index]
                size.width = min(size.width, max(0, bounds.maxX - x))
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

    /// Mark this item as one that never starts a `TrailingFlow` line alone
    /// (the item before it wraps with it).
    func keepsWithPrevious() -> some View {
        layoutValue(key: TrailingFlow.KeepWithPreviousKey.self, value: true)
    }
}
