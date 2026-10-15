//
//  LibraryControlsFlow.swift
//  Variorum (Mac)
//
//  VX-175 (the VX-283 run, U3 — P-U3-2 as RULED by the orchestrator,
//  2026-10-15): **the Library's controls row is one line when it fits,
//  otherwise two — search · scope on the first, mode · sort · when on the
//  second.** At the app's own 1240-pt default window with the info panel
//  open the row's single line (search · scope · mode · sort ▾ · when ▾) was
//  wider than the list column: the search field squeezed to a sliver and the
//  panel was pushed off the window's right edge (≈92 pt Study, ≈136 pt
//  Terminal — the 13n-c walk's F-R1-1). The ruled split keeps the one-line
//  ORDER (the row wraps after scope) and falls where the controls already
//  group: the field and scope say what is searched; mode, sort and when say
//  how it is shown (sort and when stand down WITH the mode in Timeline).
//
//  **A `Layout` over ONE set of views — never `ViewThatFits`** (the ruling):
//  `ViewThatFits` builds each candidate separately, so the row would hold two
//  search fields and swap them on the re-flow the info panel's opening
//  triggers — dropping her caret. Here the field is one view in either
//  arrangement. A line that fits places its controls exactly as the row's
//  old `HStack` did (`LibraryControlsFlowRule.distribute` — the HStack's own
//  least-flexible-first sharing), so a wide window is unchanged.
//

import SwiftUI

/// **The pure half** (VX-175): the HStack's distribution and the wrap
/// decision, over abstract children — what the layout asks, the pins drive.
nonisolated enum LibraryControlsFlowRule {
    /// One control as the row sees it: how flexible it is (its widest less
    /// its narrowest), the width and height it takes when offered a width,
    /// and its ideal width.
    struct Child {
        var flexibility: CGFloat
        var ideal: CGFloat
        var width: (CGFloat) -> CGFloat
        var height: (CGFloat) -> CGFloat
    }

    struct Arrangement: Equatable {
        var oneLine: Bool
        /// Each child's frame, in the row's own space (y down), in child order.
        var frames: [CGRect]
        var size: CGSize
    }

    /// **The HStack's distribution:** the least flexible child first, each
    /// offered an equal share of the width that is left (a child that cannot
    /// shrink to its share takes what it needs, and the rest get less).
    static func distribute(_ children: [Child], in width: CGFloat, spacing: CGFloat) -> [CGFloat] {
        guard !children.isEmpty else { return [] }
        var widths = Array(repeating: CGFloat(0), count: children.count)
        var remaining = width - spacing * CGFloat(children.count - 1)
        let order = children.indices.sorted {
            (children[$0].flexibility, $0) < (children[$1].flexibility, $1)
        }
        for (placed, index) in order.enumerated() {
            let share = max(0, remaining) / CGFloat(children.count - placed)
            let taken = children[index].width(share)
            widths[index] = taken
            remaining -= taken
        }
        return widths
    }

    /// **The wrap decision** (the ruling: one line only if the field keeps at
    /// least its placeholder width): the line, placed as the HStack places
    /// it, fits `width` AND leaves the field (child 0) at least its ideal —
    /// the field's ideal is its own prompt's width, so "never a sliver" means
    /// the field never truncates its own words while the row is one line.
    static func fitsOneLine(
        widths: [CGFloat], fieldIdeal: CGFloat, width: CGFloat, spacing: CGFloat
    ) -> Bool {
        guard let field = widths.first else { return true }
        let total = widths.reduce(0, +) + spacing * CGFloat(widths.count - 1)
        return total <= width + 0.5 && field >= fieldIdeal - 0.5
    }

    /// The whole arrangement: one line when it fits, else the first
    /// `lineOneCount` children on line 1 and the rest on line 2, each line
    /// distributed as an HStack, left-aligned, its children centred on it.
    static func arrange(
        _ children: [Child], lineOneCount: Int, width: CGFloat,
        spacing: CGFloat, lineSpacing: CGFloat
    ) -> Arrangement {
        guard !children.isEmpty else { return Arrangement(oneLine: true, frames: [], size: .zero) }
        let single = distribute(children, in: width, spacing: spacing)
        let oneLine = children.count <= lineOneCount
            || fitsOneLine(widths: single, fieldIdeal: children[0].ideal, width: width, spacing: spacing)
        let lines: [Range<Int>] = oneLine
            ? [children.indices]
            : [0..<lineOneCount, lineOneCount..<children.count]
        var frames = Array(repeating: CGRect.zero, count: children.count)
        var y: CGFloat = 0
        var rowWidth: CGFloat = 0
        for (number, line) in lines.enumerated() {
            let members = Array(children[line])
            let widths = oneLine ? single : distribute(members, in: width, spacing: spacing)
            let heights = zip(members, widths).map { $0.height($1) }
            let lineHeight = heights.max() ?? 0
            var x: CGFloat = 0
            for (offset, index) in line.enumerated() {
                frames[index] = CGRect(
                    x: x, y: y + (lineHeight - heights[offset]) / 2,
                    width: widths[offset], height: heights[offset])
                x += widths[offset] + spacing
            }
            rowWidth = max(rowWidth, x - spacing)
            y += lineHeight + (number < lines.count - 1 ? lineSpacing : 0)
        }
        return Arrangement(oneLine: oneLine, frames: frames, size: CGSize(width: rowWidth, height: y))
    }
}

/// **The controls row's layout** (VX-175): the search field FIRST, scope
/// second, then mode · sort · when — one line when the rule says it fits,
/// else the first two on line 1 and the rest on line 2.
struct LibraryControlsFlow: Layout {
    var spacing: CGFloat = 10
    var lineSpacing: CGFloat = 8
    /// Search · scope.
    var lineOneCount: Int = 2

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrangement(width: proposal.width ?? .infinity, subviews: subviews).size
    }

    func placeSubviews(
        in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) {
        let arranged = arrangement(width: bounds.width, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let frame = arranged.frames[index]
            subview.place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(width: frame.width, height: frame.height))
        }
    }

    private func arrangement(width: CGFloat, subviews: Subviews) -> LibraryControlsFlowRule.Arrangement {
        let children = subviews.map { subview in
            let narrowest = subview.sizeThatFits(ProposedViewSize(width: 0, height: nil)).width
            let widest = subview.sizeThatFits(ProposedViewSize(width: .infinity, height: nil)).width
            return LibraryControlsFlowRule.Child(
                flexibility: widest - narrowest,
                ideal: subview.sizeThatFits(.unspecified).width,
                width: { subview.sizeThatFits(ProposedViewSize(width: $0, height: nil)).width },
                height: { subview.sizeThatFits(ProposedViewSize(width: $0, height: nil)).height })
        }
        return LibraryControlsFlowRule.arrange(
            children, lineOneCount: lineOneCount, width: width,
            spacing: spacing, lineSpacing: lineSpacing)
    }
}
