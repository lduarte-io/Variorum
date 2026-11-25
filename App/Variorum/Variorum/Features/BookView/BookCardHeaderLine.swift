//
//  BookCardHeaderLine.swift
//  Variorum (Mac)
//
//  **VX-1038 (T-1) — a book card's header line**, split from
//  `BookCardTags.swift` because it is pure geometry (P-9): the title leads,
//  the note's pills sit at its trailing side (wrapping inside that area when
//  many), and a title that fills the line puts them on their own row under it
//  — a fixed place, never floating (the round-2 mockup's frame 1). Her words
//  (R-1036-18): *"I'd rather that the tags start out by being on the line next
//  to open and then go down to a second line if there are too many of them …
//  if the title is taking up the full length the tags can be on the next line
//  down, but I think that they should be in a deliberate area and always show
//  as a pill."*
//

import SwiftUI

// MARK: - T-1's layout (pure plan + the Layout that draws it)

/// **Where a card header's pills go** (T-1, the round-2 mockup's frame 1).
/// Pure, so the five states are pinned without a window:
/// - no pills and no "+" (the switch hidden) → the title has the line;
/// - the pills fit beside the title on one line → there, at the trailing side;
/// - they fit beside it only by wrapping → they wrap INSIDE the trailing area
///   (the title keeps its place, the card grows by the extra lines);
/// - the title fills the line → the pills take their OWN row directly under
///   it, at the title's start — a fixed place, never floating.
/// "Fills the line" is measured against a FLOOR for the trailing area: the
///   widest pill, and at least a third of the line where the pills would use
///   it — so a long title never squeezes the pills into a one-pill column
///   (PROVISIONAL P-1036-B2-2).
nonisolated enum BookCardHeaderPlan {
    enum Arrangement: Equatable, Sendable {
        /// No pills — the title has the line.
        case titleOnly
        /// On the title line: the trailing area's width and its rows (indices
        /// into the pills, right-aligned inside the area).
        case besideTitle(area: CGFloat, rows: [[Int]])
        /// Their own row(s) under the title, left-aligned at the title's start.
        case ownRow(rows: [[Int]])
    }

    /// The trailing area's floor, as a share of the line (P-1036-B2-2).
    static let floorShare: CGFloat = 1.0 / 3.0

    static func arrange(
        width: CGFloat, leadIdeal: CGFloat, trailing: CGFloat, pills: [CGFloat],
        gap: CGFloat, spacing: CGFloat, ownRowIndent: CGFloat
    ) -> Arrangement {
        guard !pills.isEmpty else { return .titleOnly }
        let available = max(0, width - (trailing > 0 ? trailing + gap : 0))
        let single = pills.reduce(0, +) + spacing * CGFloat(pills.count - 1)
        if leadIdeal + gap + single <= available {
            return .besideTitle(area: single, rows: [Array(pills.indices)])
        }
        let widest = pills.max() ?? 0
        let floor = max(widest, min(single, available * floorShare))
        if leadIdeal + gap + floor <= available {
            let area = available - leadIdeal - gap
            return .besideTitle(area: area, rows: rows(pills, available: area, spacing: spacing))
        }
        return .ownRow(rows: rows(pills, available: max(0, width - ownRowIndent), spacing: spacing))
    }

    /// The pills' rows — the chips' ONE row rule (`TrailingFlow.rows`), with
    /// the masthead's orphan rule: the LAST item is the "+", and it never
    /// starts a row alone (the pill before it comes down with it).
    static func rows(_ pills: [CGFloat], available: CGFloat, spacing: CGFloat) -> [[Int]] {
        TrailingFlow.keepingTogether(
            TrailingFlow.rows(widths: pills, available: available, spacing: spacing),
            keepWithPrevious: [pills.count - 1])
    }
}

/// A header item's part in the layout.
nonisolated enum BookCardHeaderRole: Equatable {
    /// The title and what rides beside it (the disclosure, the day, the
    /// badge — and on the open header, "open ↗"). Compressible: the title
    /// gives way first.
    case lead
    /// What stands at the far end (the card's "open ↗").
    case trailing
    /// A pill, or the "+" (the last item).
    case pill
    /// The "+" field's anchor: no room of its own; placed where the field
    /// slides out (the leading edge of the line holding the "+" — or, on
    /// the own row, the line's far end), so an overlay hung off it never
    /// moves a pill.
    case anchor
}

nonisolated struct BookCardHeaderRoleKey: LayoutValueKey {
    static let defaultValue: BookCardHeaderRole = .pill
}

extension View {
    func bookCardHeaderRole(_ role: BookCardHeaderRole) -> some View {
        layoutValue(key: BookCardHeaderRoleKey.self, value: role)
    }
}

/// **The header line** — the plan, drawn. Items on the title line align on
/// their FIRST TEXT BASELINE (the chips' rows-10/11 discipline); each further
/// row of pills stacks under the one before it.
struct BookCardHeaderLine: Layout {
    var gap: CGFloat = 8
    var spacing: CGFloat = 4
    var lineSpacing: CGFloat = 4
    /// Where the own row starts — the title's leading edge (past the fold
    /// disclosure).
    var ownRowIndent: CGFloat = 0

    private struct Plan {
        var lead: Int?
        var trailing: Int?
        var anchor: Int?
        var pills: [Int] = []
        var sizes: [CGSize] = []
        var baselines: [CGFloat] = []
        var arrangement: BookCardHeaderPlan.Arrangement = .titleOnly
    }

    private func plan(width: CGFloat, subviews: Subviews) -> Plan {
        var plan = Plan()
        for (index, subview) in subviews.enumerated() {
            plan.sizes.append(subview.sizeThatFits(.unspecified))
            plan.baselines.append(subview.dimensions(in: .unspecified)[VerticalAlignment.firstTextBaseline])
            switch subview[BookCardHeaderRoleKey.self] {
            case .lead: plan.lead = index
            case .trailing: plan.trailing = index
            case .anchor: plan.anchor = index
            case .pill: plan.pills.append(index)
            }
        }
        plan.arrangement = BookCardHeaderPlan.arrange(
            width: width,
            leadIdeal: plan.lead.map { plan.sizes[$0].width } ?? 0,
            trailing: plan.trailing.map { plan.sizes[$0].width } ?? 0,
            pills: plan.pills.map { plan.sizes[$0].width },
            gap: gap, spacing: spacing, ownRowIndent: ownRowIndent)
        return plan
    }

    /// One row of pills' height and baseline (from its top).
    private func row(_ members: [Int], _ plan: Plan) -> (height: CGFloat, baseline: CGFloat) {
        let items = members.map { plan.pills[$0] }
        let baseline = items.map { plan.baselines[$0] }.max() ?? 0
        let height = items.map { baseline - plan.baselines[$0] + plan.sizes[$0].height }.max() ?? 0
        return (height, baseline)
    }

    /// The title line's members (lead, trailing, and — beside the title —
    /// the first pill row), their shared baseline and the line's height.
    private func titleLine(_ plan: Plan) -> (baseline: CGFloat, height: CGFloat) {
        var members: [Int] = [plan.lead, plan.trailing].compactMap { $0 }
        if case .besideTitle(_, let rows) = plan.arrangement, let first = rows.first {
            members += first.map { plan.pills[$0] }
        }
        let baseline = members.map { plan.baselines[$0] }.max() ?? 0
        let height = members.map { baseline - plan.baselines[$0] + plan.sizes[$0].height }.max() ?? 0
        return (baseline, height)
    }

    private func height(_ plan: Plan) -> CGFloat {
        let line = titleLine(plan)
        switch plan.arrangement {
        case .titleOnly:
            return line.height
        case .besideTitle(_, let rows):
            let more = rows.dropFirst().map { row($0, plan).height + lineSpacing }.reduce(0, +)
            return line.height + more
        case .ownRow(let rows):
            return line.height + rows.map { row($0, plan).height + lineSpacing }.reduce(0, +)
        }
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        let plan = plan(width: width, subviews: subviews)
        if width.isFinite { return CGSize(width: width, height: height(plan)) }
        let ideal = (plan.lead.map { plan.sizes[$0].width } ?? 0)
            + (plan.trailing.map { plan.sizes[$0].width + gap } ?? 0)
            + (plan.pills.isEmpty ? 0
               : gap + plan.pills.map { plan.sizes[$0].width }.reduce(0, +)
                 + spacing * CGFloat(plan.pills.count - 1))
        return CGSize(width: ideal, height: height(plan))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let plan = plan(width: bounds.width, subviews: subviews)
        let line = titleLine(plan)
        let trailingWidth = plan.trailing.map { plan.sizes[$0].width } ?? 0
        let trailingRoom = plan.trailing == nil ? 0 : trailingWidth + gap
        func place(_ index: Int, x: CGFloat, lineTop: CGFloat, lineBaseline: CGFloat, width: CGFloat? = nil) {
            let size = plan.sizes[index]
            subviews[index].place(
                at: CGPoint(x: x, y: lineTop + lineBaseline - plan.baselines[index]),
                proposal: ProposedViewSize(width: width ?? size.width, height: size.height))
        }
        // The trailing door stands at the far end of the title line.
        if let trailing = plan.trailing {
            place(trailing, x: bounds.maxX - trailingWidth, lineTop: bounds.minY, lineBaseline: line.baseline)
        }
        var anchorPoint = CGPoint(x: bounds.maxX - trailingRoom, y: bounds.minY)
        var anchorHeight = line.height
        switch plan.arrangement {
        case .titleOnly:
            if let lead = plan.lead {
                place(lead, x: bounds.minX, lineTop: bounds.minY, lineBaseline: line.baseline,
                      width: max(0, bounds.width - trailingRoom))
            }
        case .besideTitle(let area, let rows):
            let areaMaxX = bounds.maxX - trailingRoom
            if let lead = plan.lead {
                place(lead, x: bounds.minX, lineTop: bounds.minY, lineBaseline: line.baseline,
                      width: max(0, areaMaxX - area - gap - bounds.minX))
            }
            var top = bounds.minY
            for (r, members) in rows.enumerated() {
                let metrics = r == 0 ? (height: line.height, baseline: line.baseline) : row(members, plan)
                let widths = members.map { plan.sizes[plan.pills[$0]].width }
                let rowWidth = widths.reduce(0, +) + spacing * CGFloat(max(members.count - 1, 0))
                var x = areaMaxX - rowWidth
                anchorPoint = CGPoint(x: x, y: top)
                anchorHeight = metrics.height
                for member in members {
                    place(plan.pills[member], x: x, lineTop: top, lineBaseline: metrics.baseline)
                    x += plan.sizes[plan.pills[member]].width + spacing
                }
                top += metrics.height + lineSpacing
            }
        case .ownRow(let rows):
            if let lead = plan.lead {
                place(lead, x: bounds.minX, lineTop: bounds.minY, lineBaseline: line.baseline,
                      width: max(0, bounds.width - trailingRoom))
            }
            var top = bounds.minY + line.height + lineSpacing
            for members in rows {
                let metrics = row(members, plan)
                var x = bounds.minX + ownRowIndent
                for member in members {
                    place(plan.pills[member], x: x, lineTop: top, lineBaseline: metrics.baseline)
                    x += plan.sizes[plan.pills[member]].width + spacing
                }
                // On the own row the field slides out from the line's far end.
                anchorPoint = CGPoint(x: bounds.maxX, y: top)
                anchorHeight = metrics.height
                top += metrics.height + lineSpacing
            }
        }
        if let anchor = plan.anchor {
            subviews[anchor].place(
                at: anchorPoint, proposal: ProposedViewSize(width: 0, height: anchorHeight))
        }
    }

    /// The title line's baseline, so a `.firstTextBaseline` host aligns to it.
    func explicitAlignment(
        of guide: VerticalAlignment, in bounds: CGRect, proposal: ProposedViewSize,
        subviews: Subviews, cache: inout ()
    ) -> CGFloat? {
        guard guide == .firstTextBaseline else { return nil }
        return titleLine(plan(width: bounds.width, subviews: subviews)).baseline
    }
}
