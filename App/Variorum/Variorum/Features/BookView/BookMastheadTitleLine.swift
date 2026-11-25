//
//  BookMastheadTitleLine.swift
//  Variorum (Mac)
//
//  **VX-1014 — the book masthead's TITLE LINE: the name, the search door, the
//  trailing doors (Arrivals on a book, the gear), never wider than its
//  column.** The line was an `HStack` whose open field carried a hard 90-pt
//  floor. SwiftUI offers an HStack's room least-flexible-first, so a SHORT
//  name (less flexible than the field) kept its whole width and the field then
//  took its floor whatever was left: the line outgrew its room, the
//  navigator's flexible frame adopted it, and `SideColumn`'s fixed
//  `.frame(width:)` centred the oversized navigator over BOTH its edges — the
//  sidebar overlapped on the left, the 🔍 and the gear clipped on the right
//  (her sighting at the VX-980 gate; measured in
//  `notes/plans/fixes/vx-1082-nov-24-fixes.md`, BATCH S).
//
//  Now ONE Layout decides the widths at WHOLE POINTS from what its subviews
//  measure (the masthead mode row's precedent, `BookMastheadModeRow` — the
//  Library controls-row law: never `ViewThatFits`, stable inputs, whole
//  points): the doors keep their own widths; the open field takes its own
//  shipped floor first — never past the room — then the name its whole
//  width, then the field grows to its shipped ceiling; the name yields
//  whatever is left (it truncates — "the title line, which truncates and so
//  always yields", the masthead's own stated intent). At rest (the bare 🔍)
//  the line is byte-for-byte the HStack's: the name, the gap, the doors at
//  the trailing edge. The share rule is PROVISIONAL (P-1014-1 in the record).
//

import SwiftUI

/// **The title line's widths, pure** (pinned by `BookMastheadTitleLineRuleTests`).
nonisolated enum BookMastheadTitleLineRule {
    /// The gaps the shipped HStack drew: name → door = its 4-pt spacing, the
    /// `Spacer(minLength: 2)`, and the spacing again; door → each trailing
    /// door, the spacing.
    static let nameGap: CGFloat = 10
    static let doorGap: CGFloat = 4
    /// The OPEN field's own floor while the column can hold it — the shipped
    /// `minWidth: 90`. Below it only when the column cannot.
    static let fieldFloor: CGFloat = 90

    struct Widths: Equatable {
        /// The name's room (it truncates inside it; 0 hides it).
        let name: CGFloat
        /// The search door's width (the field plus its 🔍, or the bare 🔍).
        let door: CGFloat
        /// Everything the line occupies — the room, unless even the bare
        /// doors outgrow it (a column narrower than any floor allows).
        let line: CGFloat
    }

    /// - `room`: the width the column offers the line.
    /// - `nameIdeal`: the name's whole width.
    /// - `doorMin` / `doorMax`: the door with its field at nothing / at its
    ///   ceiling — EQUAL while the field rests (the bare 🔍).
    /// - `trailing`: the trailing doors' widths, in order.
    static func widths(
        room: CGFloat, nameIdeal: CGFloat, doorMin: CGFloat, doorMax: CGFloat, trailing: [CGFloat]
    ) -> Widths {
        let room = max(0, room.rounded(.down))
        let fixed = nameGap + trailing.reduce(0) { $0 + doorGap + $1.rounded(.up) }
        let avail = max(0, room - fixed)
        let lowest = doorMin.rounded(.up)
        let highest = max(lowest, doorMax.rounded(.down))
        // The field's own floor first, then the name whole, then the field's
        // growth to its ceiling — never past the room, never under the bare 🔍.
        let floor = min(lowest + fieldFloor, highest)
        let wanted = max(floor, avail - nameIdeal.rounded(.up))
        let door = max(lowest, min(wanted, highest, avail))
        let name = max(0, avail - door)
        return Widths(name: name, door: door, line: fixed + door + name)
    }
}

/// **The title line** — subviews in order: the NAME, the SEARCH DOOR, then the
/// trailing doors. Each is vertically centred, as the HStack's default
/// alignment placed them.
struct BookMastheadTitleLine: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard subviews.count >= 2 else { return .zero }
        let widths = plan(proposal.width, subviews)
        let heights = allotted(widths, subviews).map { subview, width in
            subview.sizeThatFits(ProposedViewSize(width: width, height: proposal.height)).height
        }
        return CGSize(width: widths.line, height: heights.max() ?? 0)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        guard subviews.count >= 2 else { return }
        let widths = plan(bounds.width, subviews)
        // The name at the leading edge; the doors at the trailing edge, as the
        // Spacer put them.
        subviews[0].place(
            at: CGPoint(x: bounds.minX, y: bounds.midY), anchor: .leading,
            proposal: ProposedViewSize(width: widths.name, height: bounds.height))
        var x = bounds.minX + widths.line
        for subview in subviews.dropFirst(2).reversed() {
            let width = subview.sizeThatFits(.unspecified).width.rounded(.up)
            x -= width
            subview.place(
                at: CGPoint(x: x, y: bounds.midY), anchor: .leading,
                proposal: ProposedViewSize(width: width, height: bounds.height))
            x -= BookMastheadTitleLineRule.doorGap
        }
        x -= widths.door
        subviews[1].place(
            at: CGPoint(x: x, y: bounds.midY), anchor: .leading,
            proposal: ProposedViewSize(width: widths.door, height: bounds.height))
    }

    /// The rule over what the subviews measure. An unspecified width asks
    /// for the line's ideal: the name whole and the door at its own ideal.
    private func plan(_ proposed: CGFloat?, _ subviews: Subviews) -> BookMastheadTitleLineRule.Widths {
        let nameIdeal = subviews[0].sizeThatFits(.unspecified).width
        let door = subviews[1]
        let doorMin = door.sizeThatFits(ProposedViewSize(width: 0, height: nil)).width
        let doorMax = door.sizeThatFits(ProposedViewSize(width: .infinity, height: nil)).width
        let trailing = subviews.dropFirst(2).map { $0.sizeThatFits(.unspecified).width }
        let room: CGFloat
        if let proposed, proposed.isFinite {
            room = proposed
        } else {
            room = BookMastheadTitleLineRule.nameGap + nameIdeal.rounded(.up)
                + door.sizeThatFits(.unspecified).width.rounded(.up)
                + trailing.reduce(0) { $0 + BookMastheadTitleLineRule.doorGap + $1.rounded(.up) }
        }
        return BookMastheadTitleLineRule.widths(
            room: room, nameIdeal: nameIdeal, doorMin: doorMin, doorMax: doorMax, trailing: trailing)
    }

    /// Each subview with the width it is given.
    private func allotted(
        _ widths: BookMastheadTitleLineRule.Widths, _ subviews: Subviews
    ) -> [(LayoutSubview, CGFloat)] {
        [(subviews[0], widths.name), (subviews[1], widths.door)]
            + subviews.dropFirst(2).map { ($0, $0.sizeThatFits(.unspecified).width.rounded(.up)) }
    }
}
