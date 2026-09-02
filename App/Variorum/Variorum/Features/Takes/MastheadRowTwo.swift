//
//  MastheadRowTwo.swift
//  Variorum (Mac)
//
//  The Act 10 correction round, batch G — **row 80b (her live find):** with
//  the tray inspector open in a ~1740-pt window the detail is ≈ 590 pt and
//  the masthead's SECOND row collided — the `sherlock holmes ×` card drawn
//  OVER the path chip's words, and the ＃ door orphaned on a line of its own
//  below. Row 2 was an `HStack` of the chip (`fixedSize`, priority 1) and
//  the tag cluster (`frame(maxWidth: .infinity)` around `TrailingFlow`):
//  when chip + gap + the flow's narrowest line (one card + the 196-pt field
//  reserve) exceeded the width, the chip won its width, the flow was
//  offered LESS than its minimum and placed its items from the right edge
//  regardless (a `Layout` does not clip) — over the chip — and, the one card
//  not fitting alone, `keepsWithPrevious` had nothing to pull, so the door
//  dropped to a line by itself.
//
//  This layout makes row 2 WIDTH-AWARE: it asks the cluster its minimum
//  line (a zero-width proposal — `TrailingFlow` answers with the widest
//  card + the door beside it + the reserve) and lays the two out on ONE
//  line — the chip leading at its ideal width, the cluster in the width
//  that remains, first text baselines aligned — when chip + gap + minimum
//  fit; otherwise on TWO lines: the chip on its own line, ellipsizing at
//  its tail rather than pushing (it is proposed no more than the width),
//  and the cluster BELOW it on a full-width line, right-aligned as always,
//  the door on the cards' line. The chip is never covered; the door never
//  orphans. Pure where it can be (`arrangement(...)`, pinned).
//

import SwiftUI

struct MastheadRowTwo: Layout {
    /// The least room between the chip and the cluster on one line.
    var gap: CGFloat = 16
    /// The room between the chip's line and the cluster's when they stack.
    var lineSpacing: CGFloat = 4

    enum Arrangement: Equatable { case oneLine, twoLines }

    /// The decision, pure (pinned): one line when the chip's ideal width,
    /// the gap and the cluster's minimum line fit the width.
    nonisolated static func arrangement(
        width: CGFloat, chipWidth: CGFloat, clusterMinimum: CGFloat, gap: CGFloat
    ) -> Arrangement {
        guard width.isFinite else { return .oneLine }
        return chipWidth + gap + clusterMinimum <= width ? .oneLine : .twoLines
    }

    private struct Plan {
        var arrangement: Arrangement
        var chip: CGSize
        var chipBaseline: CGFloat
        var cluster: CGSize
        var clusterBaseline: CGFloat
        var height: CGFloat
        var width: CGFloat
    }

    private func plan(width: CGFloat, subviews: Subviews) -> Plan? {
        guard subviews.count == 2 else { return nil }
        let chipIdeal = subviews[0].sizeThatFits(.unspecified)
        let clusterMinimum = subviews[1].sizeThatFits(ProposedViewSize(width: 0, height: nil)).width
        let arrangement = Self.arrangement(
            width: width, chipWidth: chipIdeal.width, clusterMinimum: clusterMinimum, gap: gap)
        switch arrangement {
        case .oneLine:
            let clusterWidth = width.isFinite ? max(0, width - chipIdeal.width - gap) : nil
            let cluster = subviews[1].sizeThatFits(ProposedViewSize(width: clusterWidth, height: nil))
            let chipBaseline = subviews[0].dimensions(in: ProposedViewSize(chipIdeal))[
                VerticalAlignment.firstTextBaseline]
            let clusterBaseline = subviews[1].dimensions(
                in: ProposedViewSize(width: clusterWidth, height: nil))[VerticalAlignment.firstTextBaseline]
            let baseline = max(chipBaseline, clusterBaseline)
            let height = max(
                baseline - chipBaseline + chipIdeal.height,
                baseline - clusterBaseline + cluster.height)
            return Plan(
                arrangement: .oneLine, chip: chipIdeal, chipBaseline: chipBaseline,
                cluster: cluster, clusterBaseline: clusterBaseline, height: height,
                width: width.isFinite ? width : chipIdeal.width + gap + cluster.width)
        case .twoLines:
            let chipWidth = min(chipIdeal.width, width)
            let chip = subviews[0].sizeThatFits(ProposedViewSize(width: chipWidth, height: nil))
            let cluster = subviews[1].sizeThatFits(ProposedViewSize(width: width, height: nil))
            return Plan(
                arrangement: .twoLines, chip: CGSize(width: chipWidth, height: chip.height),
                chipBaseline: 0, cluster: cluster, clusterBaseline: 0,
                height: chip.height + lineSpacing + cluster.height, width: width)
        }
    }

    func sizeThatFits(
        proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) -> CGSize {
        guard let plan = plan(width: proposal.width ?? .infinity, subviews: subviews) else {
            return .zero
        }
        return CGSize(width: plan.width, height: plan.height)
    }

    func placeSubviews(
        in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) {
        guard let plan = plan(width: bounds.width, subviews: subviews) else { return }
        switch plan.arrangement {
        case .oneLine:
            let baseline = max(plan.chipBaseline, plan.clusterBaseline)
            subviews[0].place(
                at: CGPoint(x: bounds.minX, y: bounds.minY + baseline - plan.chipBaseline),
                proposal: ProposedViewSize(plan.chip))
            subviews[1].place(
                at: CGPoint(
                    x: bounds.minX + plan.chip.width + gap,
                    y: bounds.minY + baseline - plan.clusterBaseline),
                proposal: ProposedViewSize(plan.cluster))
        case .twoLines:
            subviews[0].place(
                at: CGPoint(x: bounds.minX, y: bounds.minY),
                proposal: ProposedViewSize(plan.chip))
            subviews[1].place(
                at: CGPoint(x: bounds.minX, y: bounds.minY + plan.chip.height + lineSpacing),
                proposal: ProposedViewSize(width: bounds.width, height: plan.cluster.height))
        }
    }
}
