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

    /// How many rows **STARRED** shows before it scrolls in place (13u2 item
    /// 10 — her words: *"I'm fine with where starred items are on the mac but
    /// make sure in 13u that it says that starred items should only show up
    /// to like 7 items and then it should start scrolling"*; placement
    /// unchanged, a bounded-list fix only).
    ///
    /// **VX-285 SPLIT THE CONSTANT** (the VX-283 run, U1). It was ONE constant
    /// for two sections — Starred and the Open strip (Act 10 item 9's ruled
    /// window, *"the starred precedent's ~7"*) — so the two could not drift.
    /// Her VX-285 ask is that they now DIFFER, and on purpose: *"Open tabs
    /// should extend the full height of the screen that they can (until the
    /// synced portion of the bottom row starts, wherever that is)"*, while
    /// Starred keeps its ~7 in her own words above. So this window is
    /// Starred's alone; the Open list's height is `openListMaxHeight` below.
    /// The `scrollingSection…` names stay (Starred is the one scrolling
    /// section with a window), and the strip's `openStripWindow` /
    /// `openStripMaxHeight` names are GONE rather than left answering 7 —
    /// a name still reading seven would be the old cap, lying.
    static let scrollingSectionWindow = 7

    /// Whether the column compresses its rows: true only when the
    /// generous layout for `rows` rows would not fit in `columnHeight`.
    /// `rows` counts every row the column is about to draw (areas, rail,
    /// starred, and the strip's rows up to `openListFitRows`).
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

    /// Starred's tallest form: the ruled window plus half a row, so a
    /// scrollable section visibly shows there is more below.
    static func scrollingSectionMaxHeight(rowHeight: CGFloat) -> CGFloat {
        rowHeight * (CGFloat(scrollingSectionWindow) + 0.5)
    }

    /// How many rows Starred contributes to the fit test — its own rows,
    /// capped at the window it scrolls inside.
    static func scrollingSectionRowsCounted(rows: Int) -> Int {
        min(rows, scrollingSectionWindow)
    }

    // MARK: - The Open list's height (VX-285 — the VX-283 run, U1)
    //
    // Her words (2026-10-13): *"I don't like that the open tabs cut off like
    // this - they should extend further down if there's the space for it
    // (though they should always stop before the syncing area begins."*
    //
    // The traced mechanism the old shape had: the strip's scroll view was
    // capped at `rowHeight × 7.5` (225 pt at the generous pitch) whatever
    // the window, so a tall window left the outer last-resort scroll's
    // unused room standing empty below an eighth row clipped mid-text. The
    // sync footer is OUTSIDE that outer scroll (`SidebarView`'s `bottom`,
    // composed by `RootView.statusRows`), so "stop before the syncing area"
    // is exactly "stop at the bottom of the outer scroll's visible height".
    //
    // So the list's tallest form is the room left under it: the outer
    // scroll's VISIBLE height, less where the list's top sits in the
    // column's content (MEASURED — what stands above it varies: starred, the
    // rail or the note box, the areas), less the content's bottom padding.
    // Filled exactly, the column's content is exactly the visible height, so
    // the outer scroll stays inert at every ordinary size.

    /// The column content's bottom padding — the air under the last group,
    /// and the last term of the Open list's height (`openListMaxHeight`).
    static let contentBottomPadding: CGFloat = 12

    /// The Open list's FLOOR, in rows: in a window too short to give it this
    /// much, the list takes this anyway and the outer last-resort scroll
    /// carries the rest (the record's "short windows fall back to the outer
    /// scroll"). Three rows and the half row that says there is more —
    /// Starred's own "visibly shows there is more" idiom. PROVISIONAL
    /// (P-U1-4): the record says "a few rows" and names no number.
    static let openListFloorRows: CGFloat = 3.5

    /// **The Open list's tallest form** (VX-285): the room between where it
    /// starts and the bottom of the column's visible scroll — the sync
    /// footer's top edge — floored at `openListFloorRows`. Rounded DOWN so
    /// the filled column can never come out a fraction taller than what it
    /// shows (which would wake the outer scroll's bounce for a hair).
    ///
    /// `visibleHeight` is the outer scroll's visible height and `listTop`
    /// the list's top in the column's content space (the content's own top
    /// padding included). Either one unmeasured (0 — the first pass before
    /// geometry lands) answers the floor: a list that has not been measured
    /// never claims room it may not have.
    static func openListMaxHeight(
        visibleHeight: CGFloat, listTop: CGFloat, bottomPadding: CGFloat, rowHeight: CGFloat
    ) -> CGFloat {
        let floor = rowHeight * openListFloorRows
        guard visibleHeight > 0, listTop > 0 else { return floor }
        return max((visibleHeight - listTop - bottomPadding).rounded(.down), floor)
    }

    /// **Do the Open list's rows fit its tallest form?** (VX-285 — the old
    /// `count <= 7` switch, which only ever asked about the old window.)
    /// True ⇒ the list hugs its rows; false ⇒ it takes `maxHeight` and
    /// scrolls in place.
    static func openListRowsFit(rows: Int, rowHeight: CGFloat, maxHeight: CGFloat) -> Bool {
        CGFloat(rows) * rowHeight <= maxHeight
    }

    /// How many of the Open list's rows the column's FIT TEST counts — the
    /// question of whether the whole column draws at the generous or the
    /// compact pitch. **Seven, deliberately UNCHANGED by VX-285:** her ask
    /// moves how far the list may grow, not when the column compresses, so
    /// the compression thresholds read exactly as they did before the split.
    /// (Counting the list at its floor instead would keep the generous pitch
    /// in more short windows, with fewer rows showing — a different trade,
    /// and not one she asked for.)
    static let openListFitRows = 7

    /// The Open strip's rows in the fit test, capped at `openListFitRows`.
    static func openStripRowsCounted(openNotes: Int) -> Int {
        min(openNotes, openListFitRows)
    }

    /// The whole column's row count, for the fit test. **Starred is capped
    /// at its window too (13u2 item 10):** an eighth starred note scrolls
    /// inside the section, so it must not push the whole column into the
    /// compact pitch — which is exactly what an uncapped count did.
    static func rowCount(starred: Int, areas: Int, rail: Int, openNotes: Int) -> Int {
        scrollingSectionRowsCounted(rows: starred)
            + areas + rail + openStripRowsCounted(openNotes: openNotes)
    }

    // MARK: - A scrolling section's window (U1b — F-1 and F-2, the VX-283 run)
    //
    // The two scrolling sections (Starred, the Open list) answer two
    // questions from ONE reading of their scroll view — where its visible
    // window sits over its rows — and both answers are pure:
    //
    // F-2 (the orchestrator's eye on U1's walk, PROVISIONAL P-U1-6): a
    // scrolled section sliced its partial row through the letters right under
    // its header — a hard clip that read unfinished. Each edge now FADES over
    // about half a row, and only where content lies beyond it: the top only
    // once scrolled down, the bottom only while more lies below. The depth
    // grows with the content beyond the edge (capped at the half row), so the
    // fade eases in as the list starts to move instead of popping in whole.
    //
    // F-1 (the walker's O-1): the note she had just opened could sit with its
    // highlighted row cut at the list's bottom edge. The traced mechanism (the
    // U1b record): the reveal was ONE minimal `scrollTo` per newest note,
    // issued against whatever viewport stood when it ran — and the Open
    // list's viewport is a function of measurements that land a pass later
    // (`openListMaxHeight`'s two, the rail arriving, the column's pitch
    // flipping 30 ↔ 24 under a 0.22 s animation), while returning to the note
    // she was already in never revealed at all (its recency did not change).
    // So the reveal is a decision over the window as it NOW stands, asked on
    // a current-row change AND on every viewport-height change — and since
    // F-2 fades the edges, "in view" means clear of the fades too.

    /// A scrolling section's visible window over its rows, in the scroll
    /// content's space: the visible top, the visible height, the content's
    /// height. Unmeasured (a zero viewport) until the scroll view reports.
    nonisolated struct ScrollWindow: Equatable, Sendable {
        var offset: CGFloat
        var viewport: CGFloat
        var content: CGFloat

        static let unmeasured = ScrollWindow(offset: 0, viewport: 0, content: 0)
        var isMeasured: Bool { viewport > 0 }
    }

    /// How deep each edge of a scrolling section fades — 0 where nothing lies
    /// beyond that edge.
    nonisolated struct EdgeFades: Equatable, Sendable {
        var top: CGFloat
        var bottom: CGFloat

        static let none = EdgeFades(top: 0, bottom: 0)
    }

    /// F-2's full depth, in rows: *"about half a row"* (P-U1-6).
    static let edgeFadeRows: CGFloat = 0.5

    /// F-2's full depth at the drawn pitch.
    static func edgeFadeDepth(rowHeight: CGFloat) -> CGFloat {
        rowHeight * edgeFadeRows
    }

    /// Below half a point, an edge does not fade (a rounding hair of content
    /// beyond an edge is not "more").
    private static let fadeSlack: CGFloat = 0.5

    /// **F-2 — which edges fade, and how deep:** the content beyond each edge,
    /// capped at `depth`. A window that holds all its content fades nowhere;
    /// an unmeasured one fades nowhere.
    static func edgeFades(_ window: ScrollWindow, depth: CGFloat) -> EdgeFades {
        guard window.isMeasured, depth > 0 else { return .none }
        let above = max(0, window.offset)
        let below = max(0, window.content - (window.offset + window.viewport))
        func settled(_ beyond: CGFloat) -> CGFloat {
            beyond < fadeSlack ? 0 : min(depth, beyond)
        }
        return EdgeFades(top: settled(above), bottom: settled(below))
    }

    /// **F-1 — the reveal.** Row `row` of `rows` (each `rowHeight` tall, the
    /// first at the content's top): nil when it already stands wholly in the
    /// window AND clear of both fades — or when nothing is measured yet;
    /// otherwise the `UnitPoint.y` to hand `ScrollViewProxy.scrollTo(_:anchor:)`
    /// so the row lands one fade's depth inside the edge it was beyond (none
    /// past the first row or the last, where nothing lies beyond to fade).
    ///
    /// The anchor arithmetic: `scrollTo` aligns the point `y × rowHeight` down
    /// the row with the point `y × viewport` down the window, so the row's top
    /// lands `y × (viewport − rowHeight)` below the window's top. A row that
    /// must sit `margin` below the top asks `margin / room`; one that must sit
    /// `margin` above the bottom asks `(room − margin) / room`
    /// (`room = viewport − rowHeight`).
    static func revealAnchor(
        row: Int, rows: Int, rowHeight: CGFloat, window: ScrollWindow, depth: CGFloat
    ) -> CGFloat? {
        guard window.isMeasured, rowHeight > 0, row >= 0, row < rows else { return nil }
        let top = CGFloat(row) * rowHeight
        let bottom = top + rowHeight
        let fades = edgeFades(window, depth: depth)
        let clearTop = window.offset + fades.top
        let clearBottom = window.offset + window.viewport - fades.bottom
        let above = top < clearTop - fadeSlack
        let below = bottom > clearBottom + fadeSlack
        guard above || below else { return nil }
        let room = window.viewport - rowHeight
        // A window shorter than one row can only show the row's top.
        guard room > 0 else { return 0 }
        if above {
            let margin = min(depth, top)
            return min(max(margin / room, 0), 1)
        }
        let margin = min(depth, CGFloat(rows - 1 - row) * rowHeight)
        return min(max((room - margin) / room, 0), 1)
    }
}
