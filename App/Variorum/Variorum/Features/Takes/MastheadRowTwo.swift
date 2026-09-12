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
//  ── 18h batch 1: A THIRD SUBVIEW, THE STAMP (her ruling R-Q7) ────────────
//  *"a quiet stamp at the trailing end of the 'in no book' row — edited
//  today 1:33 AM; a click flips it to created …"* So row two now lays out
//  TWO OR THREE subviews: the chip, the cluster, and — when the host hands
//  one over — the stamp, at its ideal width, **always at the line's
//  trailing edge**. The cluster takes the width that remains BETWEEN them,
//  which is what keeps the right edge calm: the stamp is pinned where she
//  reads it and the tag cards reflow inside, rather than the stamp jumping
//  every time a tag goes on. On two lines the stamp rides the CHIP's line
//  (its right end) and the cluster still gets a full-width line below —
//  the door stays on the cards' line, exactly as row 80b ruled.
//
//  The cost, stated: at a narrow masthead the chip is proposed the width
//  LESS the stamp and its gap, so it ellipsizes at its tail a little
//  sooner than before. That yield is the one row 80b already ruled legal,
//  and it is the only thing the third subview takes from anyone.
//
//  Two subviews still lay out byte-identically (`stampWidth` 0 adds no gap
//  and no room), which is why the shipped `arrangement` pin and the mounted
//  row-58/80b pins hold unchanged.
//

import SwiftUI

struct MastheadRowTwo: Layout {
    /// The least room between the chip and the cluster on one line.
    var gap: CGFloat = 16
    /// The room between the chip's line and the cluster's when they stack.
    var lineSpacing: CGFloat = 4

    enum Arrangement: Equatable { case oneLine, twoLines }

    /// The decision, pure (pinned): one line when the chip's ideal width,
    /// the gap, the cluster's minimum line and the stamp's own tail (its
    /// gap + its width, when there is one) fit the width.
    ///
    /// `stampWidth` defaults to 0 and a 0 stamp adds NOTHING — not even a
    /// gap — so the two-subview decision is byte-identical to what shipped
    /// and its pin holds unchanged.
    nonisolated static func arrangement(
        width: CGFloat, chipWidth: CGFloat, clusterMinimum: CGFloat, gap: CGFloat,
        stampWidth: CGFloat = 0
    ) -> Arrangement {
        guard width.isFinite else { return .oneLine }
        let tail = stampWidth > 0 ? gap + stampWidth : 0
        return chipWidth + gap + clusterMinimum + tail <= width ? .oneLine : .twoLines
    }

    private struct Plan {
        var arrangement: Arrangement
        var chip: CGSize
        var chipBaseline: CGFloat
        var cluster: CGSize
        var clusterBaseline: CGFloat
        /// The stamp, when the host handed one over; `.zero` otherwise, and
        /// every arithmetic below reads as the two-subview shipped one.
        var stamp: CGSize = .zero
        var stampBaseline: CGFloat = 0
        /// TWO-LINES only: the height of the chip's line (the chip, or the
        /// chip and the stamp baseline-aligned), so the cluster's line
        /// starts below whichever is taller.
        var firstLineHeight: CGFloat = 0
        var height: CGFloat
        var width: CGFloat

        var hasStamp: Bool { stamp.width > 0 }
    }

    private func plan(width: CGFloat, subviews: Subviews) -> Plan? {
        guard subviews.count == 2 || subviews.count == 3 else { return nil }
        let chipIdeal = subviews[0].sizeThatFits(.unspecified)
        let clusterMinimum = subviews[1].sizeThatFits(ProposedViewSize(width: 0, height: nil)).width
        // The stamp is `fixedSize`d chrome: its ideal width IS its width.
        let stamp = subviews.count == 3 ? subviews[2].sizeThatFits(.unspecified) : .zero
        let stampBaseline = subviews.count == 3
            ? subviews[2].dimensions(in: ProposedViewSize(stamp))[VerticalAlignment.firstTextBaseline]
            : 0
        let tail = stamp.width > 0 ? gap + stamp.width : 0
        let arrangement = Self.arrangement(
            width: width, chipWidth: chipIdeal.width, clusterMinimum: clusterMinimum,
            gap: gap, stampWidth: stamp.width)
        switch arrangement {
        case .oneLine:
            let clusterWidth = width.isFinite
                ? max(0, width - chipIdeal.width - gap - tail) : nil
            let cluster = subviews[1].sizeThatFits(ProposedViewSize(width: clusterWidth, height: nil))
            let chipBaseline = subviews[0].dimensions(in: ProposedViewSize(chipIdeal))[
                VerticalAlignment.firstTextBaseline]
            let clusterBaseline = subviews[1].dimensions(
                in: ProposedViewSize(width: clusterWidth, height: nil))[VerticalAlignment.firstTextBaseline]
            let baseline = max(chipBaseline, max(clusterBaseline, stampBaseline))
            var height = max(
                baseline - chipBaseline + chipIdeal.height,
                baseline - clusterBaseline + cluster.height)
            if stamp.width > 0 {
                height = max(height, baseline - stampBaseline + stamp.height)
            }
            return Plan(
                arrangement: .oneLine, chip: chipIdeal, chipBaseline: chipBaseline,
                cluster: cluster, clusterBaseline: clusterBaseline,
                stamp: stamp, stampBaseline: stampBaseline, height: height,
                width: width.isFinite ? width : chipIdeal.width + gap + cluster.width + tail)
        case .twoLines:
            // The stamp rides the CHIP's line, so the chip is offered the
            // width less the stamp's tail — it ellipsizes a little sooner,
            // which is row 80b's own ruled yield.
            let chipWidth = min(chipIdeal.width, max(0, width - tail))
            let chip = subviews[0].sizeThatFits(ProposedViewSize(width: chipWidth, height: nil))
            let cluster = subviews[1].sizeThatFits(ProposedViewSize(width: width, height: nil))
            let chipBaseline = subviews[0].dimensions(
                in: ProposedViewSize(width: chipWidth, height: nil))[VerticalAlignment.firstTextBaseline]
            let baseline = max(chipBaseline, stampBaseline)
            let firstLine = stamp.width > 0
                ? max(baseline - chipBaseline + chip.height, baseline - stampBaseline + stamp.height)
                : chip.height
            return Plan(
                arrangement: .twoLines, chip: CGSize(width: chipWidth, height: chip.height),
                chipBaseline: chipBaseline, cluster: cluster, clusterBaseline: 0,
                stamp: stamp, stampBaseline: stampBaseline, firstLineHeight: firstLine,
                height: firstLine + lineSpacing + cluster.height, width: width)
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
            let baseline = max(plan.chipBaseline,
                               max(plan.clusterBaseline,
                                   plan.hasStamp ? plan.stampBaseline : 0))
            subviews[0].place(
                at: CGPoint(x: bounds.minX, y: bounds.minY + baseline - plan.chipBaseline),
                proposal: ProposedViewSize(plan.chip))
            subviews[1].place(
                at: CGPoint(
                    x: bounds.minX + plan.chip.width + gap,
                    y: bounds.minY + baseline - plan.clusterBaseline),
                proposal: ProposedViewSize(plan.cluster))
            if plan.hasStamp {
                // The line's TRAILING edge — pinned there so the tag cards
                // reflow inside it rather than shoving it about.
                subviews[2].place(
                    at: CGPoint(
                        x: bounds.maxX - plan.stamp.width,
                        y: bounds.minY + baseline - plan.stampBaseline),
                    proposal: ProposedViewSize(plan.stamp))
            }
        case .twoLines:
            let baseline = max(plan.chipBaseline, plan.hasStamp ? plan.stampBaseline : 0)
            subviews[0].place(
                at: CGPoint(
                    x: bounds.minX,
                    y: bounds.minY + (plan.hasStamp ? baseline - plan.chipBaseline : 0)),
                proposal: ProposedViewSize(plan.chip))
            if plan.hasStamp {
                subviews[2].place(
                    at: CGPoint(
                        x: bounds.maxX - plan.stamp.width,
                        y: bounds.minY + baseline - plan.stampBaseline),
                    proposal: ProposedViewSize(plan.stamp))
            }
            let firstLine = plan.hasStamp ? plan.firstLineHeight : plan.chip.height
            subviews[1].place(
                at: CGPoint(x: bounds.minX, y: bounds.minY + firstLine + lineSpacing),
                proposal: ProposedViewSize(width: bounds.width, height: plan.cluster.height))
        }
    }
}
