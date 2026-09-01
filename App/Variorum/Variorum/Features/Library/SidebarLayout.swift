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

    /// The column's fixed chrome at the generous pitch: the top padding,
    /// the group headers, the separators and the bottom status inset —
    /// everything that is not a row. Stated as one number so the fit test
    /// is one comparison; measured from the column's own constants below.
    /// 14 (top) + 3 × 22 (headers) + 3 × 19 (separators) + 96 (the status
    /// rows and the bottom padding) = 233.
    static let fixedChromeHeight: CGFloat = 233

    /// How many Open-strip rows show before the SECTION scrolls in place
    /// (Act 10 item 9's ruled window — the starred precedent's "~7").
    static let openStripWindow = 7

    /// Whether the column compresses its rows: true only when the
    /// generous layout for `rows` rows would not fit in `columnHeight`.
    /// `rows` counts every row the column is about to draw (areas, rail,
    /// starred, and the strip's rows up to its window).
    static func compressesRows(columnHeight: CGFloat, rows: Int) -> Bool {
        guard columnHeight > 0 else { return false }
        let generous = CGFloat(rows) * generousRowHeight + fixedChromeHeight
        return generous > columnHeight
    }

    /// The row height the column draws at.
    static func rowHeight(columnHeight: CGFloat, rows: Int) -> CGFloat {
        compressesRows(columnHeight: columnHeight, rows: rows)
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
