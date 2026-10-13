//
//  SidebarLayout.swift
//  Variorum (Mac) — Core/Views (the shared Mac-chrome home)
//
//  **HOISTED from `Features/Library/` at the 18d ladder's round-2 MINOR-4.**
//  It is a pure layout brain — a `nonisolated enum` of constants and pure
//  functions over `Foundation` alone — and its readers are no longer one
//  feature's: `Core/Views/SidebarNoteBox` reads its grammar numbers, its
//  header height and `railGroupHeight`. Round 1's MINOR-7 moved the three
//  grammar numbers OUT of `SidebarView` into this brain, which reversed the
//  coupling one step and left it standing: the shared-chrome home was still
//  reading a `Features/Library/` type, which is the direction the placement
//  rule forbids (components — and the brains they read — move UP; a feature
//  is never reached down into). The file's address is the whole fix; not a
//  line of it changed. **Its consumers, all same-module:**
//  `Core/Views/SidebarNoteBox`, `Features/Library/SidebarView`, and the pins
//  `ShellChromeTests` · `NoteBoxTests` · `NoteBoxMountTests` (plus one doc
//  reference in `Features/BookView/BookView.swift`).
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
    /// strip — each one `groupHeaderHeight` of header and `separatorHeight`
    /// of separator): the top padding, the headers, the separators and the
    /// bottom status inset — everything that is not a row. It is
    /// `chromeHeight(headedGroups: 3)` and nothing else, which is the point:
    /// **the arithmetic is not restated here.** Ladder R1-12: the fit test
    /// counts the groups ACTUALLY present (`chromeHeight(headedGroups:)`) —
    /// a column with no starred group and no rail carries one header and one
    /// separator, two groups' worth less, and used to compress a little early.
    ///
    /// 17o c/d/e ladder round 1, MINOR-2: this paragraph used to spell the
    /// sum out — *"each a 22-pt header … = 233"* — and row 13 moved
    /// `groupHeaderHeight` 22 → 30 (the value is 257) without it. Row 13's
    /// own stated point is that the header's drawn height and the height the
    /// column budgets *"can never drift apart — the drift would be silent"*;
    /// a doc that re-types the sum is that same silent drift one layer up,
    /// so it names the constants and lets them carry the number. The test
    /// beside it does the same (`ShellChromeTests`
    /// `theChromeCountsOnlyTheHeadedGroupsPresent`, rewritten at row 13 to
    /// compute from the constants rather than a copied 41).
    static let fixedChromeHeight: CGFloat = chromeHeight(headedGroups: 3)

    // MARK: - The column's grammar (the mockup's `.sb-group` / `.sb-row`)
    //
    // **They live HERE since the 18d ladder's MINOR-7.** They were private
    // to `SidebarView`; batch 1 un-private'd two of them so the note box —
    // which lives in `Core/Views/`, the shared-chrome home — could land its
    // contents on the column's one left edge. That inverts the placement
    // rule's direction: components move UP into the shared home, and the
    // shared home must never reach DOWN into a feature for numbers (a
    // Library edit could then move a shared component silently). This
    // layout brain is where the fit math already lives and what the box
    // already reads (`groupHeaderHeight`, `railGroupHeight`), so the three
    // numbers move here and both readers ask the same place.

    /// The mockup's `.sb-group`: 12 pt of side padding around its rows.
    static let groupPadding: CGFloat = 12
    /// The mockup's `.sb-row`: 8 pt of side padding inside the row.
    static let rowPadding: CGFloat = 8
    /// **The column's content edge** — where a row's words (and a header's)
    /// land: the group's side padding plus the row's. VX-218: the bottom
    /// status family (protection + sync rows) sits on it too, so its words
    /// line up with everything above them instead of hugging the window's
    /// rounded corner.
    static let contentInset: CGFloat = groupPadding + rowPadding
    /// Row 13 (17o batch d): the air between a group header's words and the
    /// first row's wash under them.
    static let headerAir: CGFloat = 6

    static let topPadding: CGFloat = 14
    /// 17o batch d (ledger row 13): the header ROW's pitch. It was 22 with
    /// the words bottom-aligned and nothing under them, which is how the
    /// header came to touch the first row's wash; it is the column's own
    /// generous pitch now, with `headerAir` below the words.
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

    /// **THE ONE MEASUREMENT the "this note" rail and the note BOX share**
    /// (18d batch 1, her U-10: the box is *"measured to take up the same
    /// amount of room"* as the rail). The rail draws a header over its mode
    /// rows and nothing else, so its group is exactly that arithmetic — and
    /// the box takes it as a fixed frame, which is what keeps the Open strip
    /// below from moving between a note and a book, or between the box's
    /// three states.
    ///
    /// It is a FUNCTION of the drawn row height, not a constant, because the
    /// column compresses (`rowHeight`) — a constant would hold at the
    /// generous pitch and lie in a short window, which is the silent drift
    /// row 13 fixed one layer down. `SidebarGeometry.railGroupHeight` (DEBUG)
    /// publishes what the rail actually drew, and the box publishes what IT
    /// drew, so the pin compares two measured rectangles rather than trusting
    /// this line.
    static func railGroupHeight(rowHeight: CGFloat, railRows: Int) -> CGFloat {
        groupHeaderHeight + CGFloat(railRows) * rowHeight
    }

    /// How many rows a SCROLLING sidebar section shows before it scrolls in
    /// place. **ONE constant for the two sections that have one**, because
    /// two sections carrying one ruled number must not drift:
    ///
    /// - the **Open strip** (Act 10 item 9's ruled window), and
    /// - **Starred** (13u2 item 10 — her words: *"I'm fine with where starred
    ///   items are on the mac but make sure in 13u that it says that starred
    ///   items should only show up to like 7 items and then it should start
    ///   scrolling"*; placement unchanged, a bounded-list fix only).
    ///
    /// Act 10 item 9 called its own window "the starred precedent's ~7" —
    /// **which the starred section did not actually have**: it rendered every
    /// starred row, unbounded, and the column compressed to fit them. This is
    /// the precedent made real.
    static let scrollingSectionWindow = 7

    /// The Open strip's name for it (kept so the strip's own call sites and
    /// pins read as they did).
    static var openStripWindow: Int { scrollingSectionWindow }

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

    /// A scrolling section's tallest form: the ruled window plus half a row,
    /// so a scrollable section visibly shows there is more below.
    static func scrollingSectionMaxHeight(rowHeight: CGFloat) -> CGFloat {
        rowHeight * (CGFloat(scrollingSectionWindow) + 0.5)
    }

    /// The Open strip's name for it (its call sites and pins read unchanged).
    static func openStripMaxHeight(rowHeight: CGFloat) -> CGFloat {
        scrollingSectionMaxHeight(rowHeight: rowHeight)
    }

    /// How many rows a scrolling section contributes to the fit test — its
    /// own rows, capped at the window it scrolls inside.
    static func scrollingSectionRowsCounted(rows: Int) -> Int {
        min(rows, scrollingSectionWindow)
    }

    /// The Open strip's name for it.
    static func openStripRowsCounted(openNotes: Int) -> Int {
        scrollingSectionRowsCounted(rows: openNotes)
    }

    /// The whole column's row count, for the fit test. **Starred is capped
    /// at its window too (13u2 item 10):** an eighth starred note scrolls
    /// inside the section, so it must not push the whole column into the
    /// compact pitch — which is exactly what an uncapped count did.
    static func rowCount(starred: Int, areas: Int, rail: Int, openNotes: Int) -> Int {
        scrollingSectionRowsCounted(rows: starred)
            + areas + rail + openStripRowsCounted(openNotes: openNotes)
    }
}
