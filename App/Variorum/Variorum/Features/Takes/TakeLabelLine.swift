//
//  TakeLabelLine.swift
//  Variorum (Mac)
//
//  VX-352 (RUN VX-548, batch 2a — the run record
//  `notes/plans/fixes/vx-548-run-mcp-grant-pane-fixes.md`; PROVISIONAL MB-4) — A TAKE
//  CARD'S LABEL KEEPS THE PART THAT TELLS TAKES APART. The card header drew the label
//  as one `Text` cut at its tail, so in Terminal at a margin-grid card's width
//  "claude-code · english" read "claude-code · e…" (the VX-336 U5 STAGE RUN, step 12).
//
//  The rule is the core's, pure (`TakeLabelFace` — pinned headlessly): `parts` splits
//  the label into the client's name (yielding) and its own words (kept); `allocate`
//  gives the kept part its whole width first. This view only composes it: each part
//  is its own `Text` (one line, its tail truncating inside its own width), laid out by
//  `TakeLabelLayout`, which asks `allocate` for the widths — so the arithmetic the pins
//  read IS the arithmetic the card lays out. The whole label is its accessibility label;
//  its HOVER is the choose band's one `.help` (`TakeChooseHeader.bandHelp` — fix leg
//  2a-F2: this line draws inside the choose button, which is met as ONE element whose
//  help is the button's own, so a `.help` here was subsumed and is not set). A label
//  with no separator is one part: exactly the face it had.
//

import SwiftUI
import VariorumCore

struct TakeLabelLine: View {
    let label: String
    let tokens: VoiceTokens

    var body: some View {
        let parts = TakeLabelFace.parts(label)
        TakeLabelLayout(probeKey: label) {
            if let yielding = parts.yielding {
                part(yielding)
            }
            part(parts.kept)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
    }

    private func part(_ text: String) -> some View {
        Text(text)
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .lineLimit(1)
            .truncationMode(.tail)
    }
}

/// The label's parts in one line, at the widths `TakeLabelFace.allocate` gives
/// them (the yielding part first in reading order, the kept part after it;
/// one subview — no separator — is the kept part alone). Never wider than it
/// is offered; never wider than its parts' ideal.
struct TakeLabelLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let widths = widths(offered: proposal.width, subviews)
        var height: CGFloat = 0
        for (subview, width) in zip(subviews, widths) {
            height = max(height, subview.sizeThatFits(ProposedViewSize(width: width, height: proposal.height)).height)
        }
        return CGSize(width: widths.reduce(0, +), height: height)
    }

    /// The label this line draws — the DEBUG probe's key only.
    var probeKey: String = ""

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        let widths = widths(offered: bounds.width, subviews)
        for (subview, width) in zip(subviews, widths) {
            subview.place(
                at: CGPoint(x: x, y: bounds.midY), anchor: .leading,
                proposal: ProposedViewSize(width: width, height: bounds.height))
            x += width
        }
        #if DEBUG
        TakeLabelLayoutProbe.record(
            probeKey, placed: widths, ideals: subviews.map { $0.sizeThatFits(.unspecified).width })
        #endif
    }

    /// The parts' widths — the pure rule's, from each part's ideal width.
    private func widths(offered: CGFloat?, _ subviews: Subviews) -> [CGFloat] {
        let ideals = subviews.map { $0.sizeThatFits(.unspecified).width }
        switch ideals.count {
        case 2:
            let widths = TakeLabelFace.allocate(
                available: offered.map(Double.init), yielding: Double(ideals[0]), kept: Double(ideals[1]))
            return [CGFloat(widths.yielding), CGFloat(widths.kept)]
        case 1:
            let widths = TakeLabelFace.allocate(
                available: offered.map(Double.init), yielding: 0, kept: Double(ideals[0]))
            return [CGFloat(widths.kept)]
        default:
            return ideals
        }
    }
}

#if DEBUG
/// **VX-352's DEBUG geometry oracle** (the `TakeCardGeometry` precedent — a
/// no-op outside DEBUG): the widths each label line last PLACED its parts at,
/// beside their ideal widths, keyed by the label — so a Mac pin reads what the
/// real card laid out, not what the rule would say. Bounded: past
/// `limit` keys it starts over (a DEBUG run with many labels never grows
/// without end; a pin's own label is always the latest).
@MainActor
enum TakeLabelLayoutProbe {
    struct Placement: Equatable {
        let placed: [CGFloat]
        let ideals: [CGFloat]
    }

    static let limit = 256
    private(set) static var placements: [String: Placement] = [:]

    nonisolated static func record(_ key: String, placed: [CGFloat], ideals: [CGFloat]) {
        MainActor.assumeIsolated {
            if placements.count >= limit, placements[key] == nil { placements.removeAll() }
            placements[key] = Placement(placed: placed, ideals: ideals)
        }
    }

    /// A pin clears its label before each mount, so what it reads is that
    /// mount's own layout.
    static func forget(_ key: String) {
        placements[key] = nil
    }
}
#endif
