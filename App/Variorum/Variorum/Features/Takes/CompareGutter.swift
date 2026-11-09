//
//  CompareGutter.swift
//  Variorum (Mac)
//
//  **VX-770 batch 2 — VX-728, Compare's comment gutter (her R-770-2: "Yes,
//  show them"; the orchestrator's P-770-3, PROVISIONAL — option (B) of the
//  batch record's B2-F1).**
//
//  Compare's columns are equal-width cells whose prose fills the column — no
//  whitespace gutter exists, so Write's ladder, asked as-is, answers "yields"
//  (draw nothing). P-770-3 gives every Compare cell a LANE: a leading strip of
//  whitespace whose width is a pure function of the COLUMN'S WIDTH and of
//  nothing else — never of whether the block, the note or the board holds a
//  comment. So adding or deleting a comment can never move the prose's
//  measure or left edge (the contract's one law; ProseGutter's own doctrine,
//  "a surface's horizontal geometry is a pure function of its own width"),
//  and Write's ladder (`BlockDecor.commentFace`) picks the face inside it:
//  Write's card where the lane is wide, Write's badge where it is narrow,
//  nothing where the column cannot spare a lane at all.
//
//  THE TASTE COST IS HERS (the ruling's rider 4, her morning bundle): wide
//  columns carry the card lane whether or not anything is commented. Her
//  "too much" is one function below — flip `lane` to always answer the badge
//  lane (option C) or zero (with a strip badge, option A); the faces are
//  unchanged either way.
//
//  **VX-848 (her ruling 2026-11-04, amending P-770-3's default — the VX-915
//  run, batch 2; the threshold PROVISIONAL P-915-B2-1):** the lane's
//  EXISTENCE stays a pure function of the column's width, but the FORM tier
//  flips — the 38-pt badge lane is the wide-column default, and the card
//  lane is kept for genuinely wide layouts: a column that keeps WRITE'S WHOLE
//  MEASURE beside the card lane (`readingMeasure` = `EditorTypography.
//  maxColumnWidth`, 680 — a column ≥ 866 pt). That is Write's own condition
//  for a card (its prose capped at 680, a card only where ≥ 150 of gutter is
//  left over — `gutterFitsCards`), applied per column: a card never costs the
//  prose its measure. The default window's two 499-pt columns now carry the
//  badge lane (≈425 pt of prose, was ≈313); the recorded alternative is a
//  425-pt floor (cards wherever they leave no less than the default badge
//  lane does).
//

import CoreGraphics

nonisolated enum CompareGutter {
    /// **The card lane** — the narrowest gutter Write's ladder seats a CARD
    /// in (`BlockDecor.gutterFitsCards`'s threshold; pinned to it). The card
    /// it seats is `cardLane − BlockDecor.leftCardLane` wide.
    static let cardLane: CGFloat = 150

    /// **The badge lane** — Write's shipped count badge, its air to the
    /// prose and the view's edge margin: exactly the room `commentBadgeRect`
    /// gives a full 32-pt badge.
    static let badgeLane: CGFloat =
        BlockDecor.commentBadgeSize.width + BlockDecor.commentBadgeAir + BlockDecor.edgeMargin

    /// What a Compare cell spends beside its prose besides the lane: the
    /// cell's row spacing after the lane (4), the lineage rail and the drag
    /// handle with their spacing (≈ 20), and the pane's two container insets
    /// (2 × 6). An estimate used only to decide which lane a column can
    /// afford — never a layout input.
    static let cellChrome: CGFloat = 36

    /// The narrowest prose a column keeps while it carries the CARD lane —
    /// VX-848 (PROVISIONAL P-915-B2-1): Write's whole measure, by reference
    /// (the two can never drift), so cards stand only beside a column that
    /// reads as wide as Write — a column ≥ 866 pt (680 + 150 + 36). Was 300,
    /// which gave the two-column default window (499-pt columns) cards and
    /// ~313 pt of prose.
    static let readingMeasure: CGFloat = EditorTypography.maxColumnWidth

    /// The narrowest prose a column keeps while it carries the BADGE lane —
    /// below it the column's prose wins and the comments yield (Write's
    /// ladder's last rung).
    static let narrowMeasure: CGFloat = 160

    /// **THE LANE — a function of the column's width ONLY.**
    static func lane(columnWidth: CGFloat) -> CGFloat {
        if columnWidth - cardLane - cellChrome >= readingMeasure { return cardLane }
        if columnWidth - badgeLane - cellChrome >= narrowMeasure { return badgeLane }
        return 0
    }

    /// The board's rows' column width: the rows' content (the board less its
    /// inset on both sides) shared by `columns` cells `spacing` apart.
    static func columnWidth(
        boardWidth: CGFloat, columns: Int, inset: CGFloat, spacing: CGFloat
    ) -> CGFloat {
        let count = CGFloat(max(columns, 1))
        return max(0, (boardWidth - 2 * inset - spacing * (count - 1)) / count)
    }
}
