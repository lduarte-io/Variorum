//
//  SidebarLayout.swift
//  Variorum (Mac)
//
//  The Act 10 correction round, batch A (rows 2 + 3) — the sidebar column's
//  DECISIONS, as pure functions (the bottom bar's `CommitBar.usesTwoRows`
//  precedent: a threshold the view consults, pinnable without a window).
//
//  ── WHAT SHE SAID, AND WHAT WAS MEASURED ────────────────────────────────
//  *"the tabs used to be right below the modes, and the tab spacing has
//  gotten less generous. It's more compressed now than it was and honestly
//  a bit hard to read now."* Measured on the dev build before any code
//  moved (the AX tree): the five areas AND the eight-mode rail were 32 pt
//  List rows — unchanged since before Act 10 — while the OPEN strip's rows,
//  which Act 10 item 9 moved out of the List into a bottom rail, had
//  become ~21 pt (4 pt padding, a 19 pt floor, 1 pt spacing). Her "tabs"
//  are the open notes (her own browser-tabs word, the round-7 ruling), and
//  they had lost the List's pitch. So the rule below gives EVERY row of the
//  column one generous pitch, and compresses only when the column is too
//  short for it — never by default.
//
//  ── WHY A FUNCTION OF THE COLUMN'S HEIGHT AND THE ROW COUNT ─────────────
//  A fixed pixel threshold would compress a sidebar with three rows in a
//  short window that had room for them, or refuse to compress twenty rows
//  in a window that had not. The honest question is "does the generous
//  layout fit?", so that is the function: rows × the generous pitch + the
//  column's fixed chrome, against the height the column actually has. An
//  unmeasured column (height 0, the first pass before geometry lands) never
//  compresses — the bar's own third pin, so the column does not flash
//  compact while mounting.
//

import Foundation

nonisolated enum SidebarLayout {
    /// The generous row — the pitch the mockup's `.sb-row` grammar gives
    /// (5 px padding around a 13 pt line) rounded to the List's own feel;
    /// what her "tabs" had before Act 10 moved them out of the List.
    static let generousRowHeight: CGFloat = 30
    /// The compact row — only under a column that cannot hold the
    /// generous layout; still a whole 13 pt line with air, never a squeeze.
    static let compactRowHeight: CGFloat = 24

    /// The column's fixed chrome at the generous pitch, for a column that
    /// carries all THREE headed groups (starred · the note's rail · the Open
    /// strip — each a 22-pt header and a 19-pt separator): the top padding,
    /// the headers, the separators and the bottom status inset — everything
    /// that is not a row. 14 (top) + 3 × 22 + 3 × 19 + 96 (the status rows
    /// and the bottom padding) = 233. Ladder R1-12: the fit test counts the
    /// groups ACTUALLY present (`chromeHeight(headedGroups:)`) — a column
    /// with no starred group and no rail carries one header and one
    /// separator, ~80 pt less, and used to compress a little early.
    static let fixedChromeHeight: CGFloat = chromeHeight(headedGroups: 3)

    static let topPadding: CGFloat = 14
    /// 17o batch d (ledger row 13): the header ROW's pitch. It was 22 with
    /// the words bottom-aligned and nothing under them, which is how the
    /// header came to touch the first row's wash; it is the column's own
    /// generous pitch now, with `SidebarView.headerAir` below the words.
    /// **The fit math reads THIS**, so the header's height and the height
    /// the column budgets for it can never drift apart — the drift would be
    /// silent (a column that fails to compress when it should).
    static let groupHeaderHeight: CGFloat = 30
    static let separatorHeight: CGFloat = 19
    static let bottomInset: CGFloat = 96

    /// The chrome for a column carrying `headedGroups` of the three headed
    /// groups (the five areas carry neither a header nor a separator).
    static func chromeHeight(headedGroups: Int) -> CGFloat {
        topPadding + CGFloat(headedGroups) * (groupHeaderHeight + separatorHeight) + bottomInset
    }

    /// How many Open-strip rows show before the SECTION scrolls in place
    /// (Act 10 item 9's ruled window — the starred precedent's "~7").
    static let openStripWindow = 7

    /// Whether the column compresses its rows: true only when the
    /// generous layout for `rows` rows would not fit in `columnHeight`.
    /// `rows` counts every row the column is about to draw (areas, rail,
    /// starred, and the strip's rows up to its window).
    static func compressesRows(columnHeight: CGFloat, rows: Int, headedGroups: Int = 3) -> Bool {
        guard columnHeight > 0 else { return false }
        let generous = CGFloat(rows) * generousRowHeight + chromeHeight(headedGroups: headedGroups)
        return generous > columnHeight
    }

    /// The row height the column draws at.
    static func rowHeight(columnHeight: CGFloat, rows: Int, headedGroups: Int = 3) -> CGFloat {
        compressesRows(columnHeight: columnHeight, rows: rows, headedGroups: headedGroups)
            ? compactRowHeight : generousRowHeight
    }

    /// The Open strip's tallest form: the ruled window plus half a row, so
    /// a scrollable strip visibly shows there is more below.
    static func openStripMaxHeight(rowHeight: CGFloat) -> CGFloat {
        rowHeight * (CGFloat(openStripWindow) + 0.5)
    }

    /// How many rows the strip contributes to the fit test — its own rows,
    /// capped at the window it scrolls inside.
    static func openStripRowsCounted(openNotes: Int) -> Int {
        min(openNotes, openStripWindow)
    }

    /// The whole column's row count, for the fit test.
    static func rowCount(starred: Int, areas: Int, rail: Int, openNotes: Int) -> Int {
        starred + areas + rail + openStripRowsCounted(openNotes: openNotes)
    }
}
