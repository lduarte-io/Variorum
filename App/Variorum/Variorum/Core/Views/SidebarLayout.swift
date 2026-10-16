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

    // MARK: - The column's one transition beat (U1b — the orchestrator's ruling on P-U1b-5)

    /// **The rail's transition, in seconds — named ONCE.** The "this note"
    /// rail and the note box arrive and leave on it (row 24's sidebar half:
    /// *"nothing on the left ever snaps"* — `SidebarView`'s two `.animation`
    /// modifiers read it), and the scrolling sections' second reveal waits
    /// past it (`transitionSettle`). It was a literal 0.22 at both modifiers;
    /// a settle hard-coded beside them would drift silently the day the
    /// motion's duration changed (`SidebarTransitionBeatTests` pins both
    /// halves).
    static let railTransition: TimeInterval = 0.22

    /// The margin a section waits past `railTransition` before it asks its
    /// reveal again: the transition's LAST frame must have landed (a frame or
    /// more at any refresh rate) and its reading been delivered.
    static let transitionSettleMargin: TimeInterval = 0.08

    /// **When a scrolling section asks its reveal again** — strictly after the
    /// rail's transition (U1b's stage window: a reveal resolved mid-transition
    /// rested short; P-U1b-5, ruled (a)).
    static var transitionSettle: TimeInterval { railTransition + transitionSettleMargin }

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
    // once scrolled down, the bottom only while more lies below. **U1d, her
    // ruling on the memo (*"The fade, reshaped"*):** the depth no longer grows
    // with the content beyond (a few-point fade read as a slice — the re-walk's
    // O-2); it is the full half row whenever more lies beyond, its STRENGTH
    // eases in with the content beyond instead, and it is never fully solid at
    // the very edge (`edgeFadeCap` — O-3's empty band).
    //
    // F-1 (the walker's O-1): the note she had just opened could sit with its
    // highlighted row cut at the list's bottom edge. The traced mechanism (the
    // U1b record): the reveal was ONE minimal `scrollTo` per newest note,
    // issued against whatever viewport stood when it ran — and the Open
    // list's viewport is a function of measurements that land a pass later
    // (`openListMaxHeight`'s two, the rail arriving, the column's pitch
    // flipping 30 ↔ 24 under the rail's transition), while returning to the note
    // she was already in never revealed at all (its recency did not change).
    // So the reveal is a decision over the window as it NOW stands — an exact
    // content offset, landed through the section's proxy, re-asked on every
    // input axis (P-U1b-6; on EVERY viewport reading since P-U1c-1,
    // `readingAsk`) — and since F-2 fades the edges, "in view" means clear of
    // the fades too.

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

    /// ONE edge's fade (U1d — her ruling on the memo, *"The fade, reshaped"*):
    /// how deep it reaches into the window, and how STRONG it is. The overlay
    /// paints the room from `opacity` at the very edge down to nothing `depth`
    /// points in.
    nonisolated struct EdgeFade: Equatable, Sendable {
        /// 0 where nothing lies beyond the edge; otherwise the FULL half row —
        /// never a few-point fade (the re-walk's O-2: a shallow fade read as a
        /// slice through the letters).
        var depth: CGFloat
        /// 0…1 — eased with the content beyond the edge, so the fade arrives
        /// gradually instead of popping in (it is the STRENGTH that eases now,
        /// never the depth) — whole once the row's text padding lies beyond
        /// (P-U1e-1).
        var strength: CGFloat

        /// The opacity at the very edge: the strength under the cap, so the
        /// fade is never fully solid and a hint of the partial row always shows
        /// (the re-walk's O-3: a partial row under a solid outer half left an
        /// empty band with no "there is more").
        var opacity: CGFloat { strength * SidebarLayout.edgeFadeCap }

        static let none = EdgeFade(depth: 0, strength: 0)
    }

    /// How each edge of a scrolling section fades — `.none` where nothing lies
    /// beyond that edge.
    nonisolated struct EdgeFades: Equatable, Sendable {
        var top: EdgeFade
        var bottom: EdgeFade

        static let none = EdgeFades(top: .none, bottom: .none)
    }

    /// F-2's full depth, in rows: *"about half a row"* (P-U1-6) — and since
    /// U1d, her words: *"always half a row deep when there's more beyond"*.
    static let edgeFadeRows: CGFloat = 0.5

    /// F-2's full depth at the drawn pitch.
    static func edgeFadeDepth(rowHeight: CGFloat) -> CGFloat {
        rowHeight * edgeFadeRows
    }

    /// **The fade's cap** — the most it ever covers at the very edge (U1d, her
    /// ruling: *"never fully solid so a hint of the next row always shows"*).
    /// PROVISIONAL (P-U1d-3): chosen by eye from offscreen renders of the
    /// shallow-overflow and partial-row states in both voices and both
    /// appearances — the U1d record carries the comparison and the reason.
    static let edgeFadeCap: CGFloat = 0.8

    /// Below half a point, an edge does not fade (a rounding hair of content
    /// beyond an edge is not "more").
    private static let fadeSlack: CGFloat = 0.5

    /// **The sidebar row's text LINE, in points — MEASURED** (P-U1e-1, the
    /// orchestrator's ruling on U1d's re-walk, the VX-283 run). Both voices'
    /// row title is a 13-pt system font (Study: `.system(size: 13)`; Terminal:
    /// the same size, monospaced), whose line box is 16 pt in either
    /// (`NSLayoutManager.defaultLineHeight` 16.0; ascender 12.57, descender
    /// 2.74, no leading — the same for both designs), centred in the row by
    /// `rowChrome`. So a row's text padding — above the line and below it — is
    /// `(rowHeight − 16) / 2`: 7 pt at the generous pitch, 4 at the compact.
    /// Measured offscreen at P-U1e-1 (the U2 record): the first INK sits 7.25–
    /// 7.5 pt above a 30-pt row's bottom (the descenders of "export: it's all
    /// yours") and 4.25–4.5 above a 24-pt row's, 9.25–10.5 / 6.25–7.5 below
    /// their tops (both voices, regular and semibold) — never inside the
    /// padding.
    static let rowTextLineHeight: CGFloat = 16

    /// **How far beyond an edge the fade takes to reach full strength**
    /// (P-U1e-1, PROVISIONAL): the row's own text padding at the drawn pitch —
    /// so by the time an edge's clip can reach a row's ink, the fade over it
    /// stands at full strength (its cap). It was the half row (U1d's P-U1d-2),
    /// 12–15 pt — longer than the padding (4–7 pt), so between the two the clip
    /// cut ink under a weak fade (the re-walk's R4 at 7–9 pt short:
    /// "export: it's all yours" sliced through its descenders). Never below a
    /// point (no division by a hair).
    static func edgeFadeRampDistance(rowHeight: CGFloat) -> CGFloat {
        max(1, (rowHeight - rowTextLineHeight) / 2)
    }

    /// **F-2, reshaped at U1d — which edges fade, how deep and how strong.**
    /// An edge with more than the slack beyond it fades the FULL `depth`
    /// (half a row); its strength is the content beyond it over the RAMP —
    /// since P-U1e-1 the row's text padding (`edgeFadeRampDistance`), read
    /// from the pitch the depth is half of unless a ramp is given — capped at
    /// 1: the fade eases in over the first few points of scroll (never a pop)
    /// and stands whole before the clip can reach ink. A window that holds all
    /// its content fades nowhere; an unmeasured one fades nowhere.
    static func edgeFades(_ window: ScrollWindow, depth: CGFloat, ramp: CGFloat? = nil) -> EdgeFades {
        guard window.isMeasured, depth > 0 else { return .none }
        let reach = ramp ?? edgeFadeRampDistance(rowHeight: depth / edgeFadeRows)
        let above = max(0, window.offset)
        let below = max(0, window.content - (window.offset + window.viewport))
        func fade(_ beyond: CGFloat) -> EdgeFade {
            beyond < fadeSlack ? .none : EdgeFade(depth: depth, strength: min(1, beyond / max(reach, 1)))
        }
        return EdgeFades(top: fade(above), bottom: fade(below))
    }

    /// **F-1 — the reveal, as an EXACT content offset** (the orchestrator's
    /// ruling P-U1b-6, after U1b's re-run: the anchor-fraction road it
    /// replaces resolved the row through the lazy stack's own idea of where it
    /// sat, which goes stale while the pitch flips — the Starred pin rested
    /// 2 pt short). Row `row` of `rows`, each `rowHeight` tall, the first at
    /// the content's top: nil when it already stands wholly in the window AND
    /// clear of both fades, or nothing is measured yet; otherwise the content
    /// offset that lands it one fade's depth inside the edge it was beyond
    /// (none past the first row or the last, where nothing lies beyond to
    /// fade), clamped to what the window as read can scroll to. A second
    /// reveal from its own result moves nothing (pinned).
    ///
    /// **The bound on that fixed point** (the VX-283 ladder's R1-3): it holds
    /// at every viewport of at least `rowHeight + 2 × depth − fadeSlack` (two
    /// rows less half a point, the depth being the half row: 59.5 pt at 30,
    /// 47.5 at 24), and at a window no taller than one row (the arm that
    /// shows the row's top). Between the two a reveal can BOUNCE: the below
    /// arm lands the row's top inside the top fade, so the next ask answers
    /// the above arm's offset and the one after it the below arm's again —
    /// pitch 30, viewport 45, a middle row: 150 ↔ 135 (the first and last
    /// rows bounce under `rowHeight + depth − fadeSlack`). No SETTLED window
    /// lies in that band: only a section whose content runs past its window
    /// has a fade at all, and a section scrolls only at the Open list's
    /// 3½-row floor (`openListFloorRows`) or more, or at Starred's 7½-row
    /// window; a section that hugs its rows fades nowhere, so every row
    /// answers nil. A frame stream can pass through the band (a one-row Open
    /// list growing to two asks on every frame, if the growth animates), but
    /// it ends on its settled reading, outside it. Hence the fixed-point
    /// pin's smallest window, 105 pt. A future section that can SETTLE
    /// scrolling under two rows must widen the `viewport <= rowHeight` arm
    /// to this bound, with a red-on-old pin.
    static func revealOffset(
        row: Int, rows: Int, rowHeight: CGFloat, window: ScrollWindow, depth: CGFloat
    ) -> CGFloat? {
        guard window.isMeasured, rowHeight > 0, row >= 0, row < rows else { return nil }
        let top = CGFloat(row) * rowHeight
        let bottom = top + rowHeight
        let fades = edgeFades(window, depth: depth)
        let above = top < window.offset + fades.top.depth - fadeSlack
        let below = bottom > window.offset + window.viewport - fades.bottom.depth + fadeSlack
        guard above || below else { return nil }
        let wanted: CGFloat
        if above || window.viewport <= rowHeight {
            // A window shorter than one row can only show the row's top.
            wanted = top - (window.viewport <= rowHeight ? 0 : min(depth, top))
        } else {
            wanted = bottom + min(depth, CGFloat(rows - 1 - row) * rowHeight) - window.viewport
        }
        let limit = max(0, window.content - window.viewport)
        return min(max(wanted, 0), limit)
    }

    // MARK: - What one reading asks of the reveal (U1c — P-U1c-1, the VX-283 run)
    //
    // The traced mechanism (U1c — the probe and the mounted rig agree): the
    // rail's implicit animation delivers a section's viewport change as a
    // stream of per-frame readings, its top held, and the content's change in
    // ONE step at the commit. The trigger used to re-ask only when one
    // reading's viewport stepped more than half a point from the PREVIOUS
    // reading — so an ease's slow tail, every step below that, shrank the
    // viewport under an offset nothing moved again, and the current row ended
    // the beat cut by the tail's sum (1–2 pt in the mounted rig, 15 at a fine
    // cadence), until the settled backstop landed it 0.30 s later.

    /// What one reading of a scrolling section asks of its reveal.
    nonisolated enum ReadingAsk: Equatable, Sendable {
        /// Nothing that moves the current row: her own scroll (an offset-only
        /// change), or a content change from a row closing elsewhere (P-U1b-7).
        case none
        /// The viewport moved — an animated resize's frame, a window resize —
        /// so reveal NOW from this reading, however small the step (P-U1c-1).
        /// A reading arrives on every frame and the last one at the settled
        /// height, so this lands the row exactly when the motion ends; it
        /// schedules no settled check (the orchestrator's sub-call 2).
        case revealNow
        /// The content height changed under an unchanged row count — the
        /// pitch flip's own signal (P-U1b-6) — a DISCRETE request: reveal now
        /// and once more after the column's transition (`transitionSettle`).
        case request
    }

    /// **What a reading asks** (P-U1c-1): a content change under an unchanged
    /// row count is a discrete request; otherwise ANY viewport change reveals
    /// now; an offset-only change asks nothing. (The mount's first reading is
    /// the section's own bookkeeping, a request before any of this.)
    static func readingAsk(old: ScrollWindow, new: ScrollWindow, rowsChanged: Bool) -> ReadingAsk {
        if abs(new.content - old.content) > 0.5, !rowsChanged { return .request }
        if new.viewport != old.viewport { return .revealNow }
        return .none
    }

    // MARK: - Follow, not every change (U1d — her ruling on the memo, R6)
    //
    // Her words (2026-10-15, the question tool): the list keeps the current
    // note in view *"Only on your next act"* — after an open, ⇧⌘W, ✕, Close
    // All or back/forward; *"once you scroll by hand it stays where you put it
    // until your next one of those; resizing the window never pulls it back."*
    //
    // The traced defect (the re-walk's R6 — three pull-backs with no input):
    // U1b/U1c's reveal had no idea of HER scroll beyond "an offset-only reading
    // asks nothing" (`readingAsk`), so ANY later reading that moved the
    // viewport or the content — a resize (P-U1b-2 re-revealed on purpose), or
    // whatever moved them in the re-walk with no input (not identified, and it
    // need not be: the class is every such reading) — and any pitch change
    // re-asked, and the reveal snapped the list back to the current row. So the section
    // now FOLLOWS explicitly: a discrete act starts following, a hand scroll
    // stops it, and while it is stopped no reading, pitch change or settled
    // check may reveal.

    /// A scrolling section's follow state — a PURE model fed three kinds of
    /// input: a discrete ACT (the current row changing; the section's first
    /// appearance is its initial state), a scroll PHASE change (hers or not),
    /// and every reveal ASK (a reading's, the pitch's, the settled check's).
    nonisolated struct SectionFollow: Equatable, Sendable {
        /// Following: the section keeps its current row in view. A section
        /// FOLLOWS from its first appearance.
        private(set) var following = true

        /// A discrete act — the current row changed (an open, a landing, a
        /// return): follow it again, whatever her hand did before.
        mutating func act() { following = true }

        /// The scroll view's phase changed. `hers` — a hand scroll (the phase
        /// is interacting or decelerating): following ends until the next act.
        /// Any other phase (idle, the app's own animated scroll) changes
        /// nothing — her scroll's END does not resume following either.
        mutating func phase(hers: Bool) {
            if hers { following = false }
        }

        /// What an ask may do: itself while following; nothing while not.
        func gate(_ ask: ReadingAsk) -> ReadingAsk {
            following ? ask : .none
        }
    }

    // MARK: - The Open list's drop (U2 — VX-288, the light version; the VX-283 run)
    //
    // Her words (2026-10-13): *"the dragging between open notes in there needs
    // to be smoother - it should be as smooth as the editor drag with a nice
    // little line showing as you hover and a nice fit / snap into place because
    // right now it feels janky to use."* Her ruling on the shape: the light
    // version first (the system drag kept).
    //
    // The traced bug under the jank (the U2 record): each row was its own drop
    // target and every drop landed in the GAP BEFORE the row under the pointer
    // (`toOffset: target`, the onMove convention's pre-move gap) whatever half of
    // the row the pointer was on — so the row just below the dragged one was
    // unreachable (a drop there changed nothing), every downward drop landed one
    // row short, and the slot after the last row could not be reached at all.
    // The rule is now pure, and the half of the row decides.

    /// The Open list's drop, as pure decisions over the list's rows (each
    /// `rowHeight` tall, the first at the content's top — the same row model the
    /// section window reads).
    nonisolated enum OpenListDrop {
        /// Where a drag over the list is pointing.
        enum Hover: Equatable, Sendable {
            /// Over the rows — the pointer's y in the list's VIEWPORT (the scroll
            /// view's visible top is 0). Held in the viewport, not the content, so
            /// a scroll under a still pointer moves the gap it names (the line's
            /// scroll axis).
            case rows(viewportY: CGFloat)
            /// Over the END ZONE under the last row: the slot after it.
            case end
        }

        /// The insertion line's thickness — the book navigator's 2-pt line in
        /// the ring token (`BookView`'s precedent).
        static let lineThickness: CGFloat = 2

        /// The end zone's tallest form — the book navigator's own 28-pt end
        /// zone (`BookView`'s precedent; 13f W11a's lesson: 14 pt was "nothing").
        static let endZoneMaxHeight: CGFloat = 28

        /// **The gap a pointer at `y` (the rows' own space) names**, 0…rows:
        /// on a row's LOWER half the gap after it, on its UPPER half the gap
        /// before it (the midpoint counts as lower — the editor's block drag
        /// settles its bar the same way); above the first row the first gap;
        /// below the last row the end. nil before the rows are laid out.
        static func gap(at y: CGFloat, rowHeight: CGFloat, rows: Int) -> Int? {
            guard rowHeight > 0, rows > 0, y.isFinite else { return nil }
            guard y > 0 else { return 0 }
            let row = Int((y / rowHeight).rounded(.down))
            guard row < rows else { return rows }
            let within = y - CGFloat(row) * rowHeight
            return within >= rowHeight / 2 ? row + 1 : row
        }

        /// **A row's own location in the rows' space** (U2c, P-U2b-1): each
        /// Open row is its own drop, and its drop session reports the pointer
        /// in THAT row's space (the SDK: "the location of the drag in the
        /// coordinate space of the drop view"); the row's index × the pitch
        /// places it in the rows' space that `gap(at:)` reads — the rows abut
        /// (spacing 0, each exactly `rowHeight` tall, the first at the top).
        static func contentY(row: Int, yInRow: CGFloat, rowHeight: CGFloat) -> CGFloat {
            CGFloat(row) * rowHeight + yInRow
        }

        /// The gap a hover names, read against the list's scroll offset NOW.
        static func gap(for hover: Hover, offset: CGFloat, rowHeight: CGFloat, rows: Int) -> Int? {
            switch hover {
            case .rows(let viewportY): gap(at: viewportY + offset, rowHeight: rowHeight, rows: rows)
            case .end: rows > 0 && rowHeight > 0 ? rows : nil
            }
        }

        /// **Where the dragged row goes** — the onMove destination (a PRE-move
        /// gap index, `OpenNotes.move`'s convention), which IS the gap. nil
        /// where the drop would change nothing: the dragged row's own two gaps
        /// (just before it and just after it), or an index off the list —
        /// §12's false-offer rule: no line there, and no drop.
        static func destination(gap: Int, dragged: Int, rows: Int) -> Int? {
            guard rows > 0, (0..<rows).contains(dragged), (0...rows).contains(gap) else { return nil }
            guard gap != dragged, gap != dragged + 1 else { return nil }
            return gap
        }

        /// **The insertion line's top, in the list's VIEWPORT** — nil where no
        /// line is drawn: nothing hovering, no drag of this list's in flight,
        /// nothing laid out or read yet, or a gap where the drop would change
        /// nothing. The line sits centred on the boundary the gap names, held
        /// inside the rows at the two ends and inside the window (a boundary
        /// half a row past a scrolled edge shows at that edge). Every input is
        /// an argument — the pointer, the scroll window, the rows, the pitch,
        /// the dragged row — so the line re-derives on each of them (the
        /// overlay/sink delivery law: hover, scroll, list change).
        static func lineTop(
            hover: Hover?, dragged: Int?, rows: Int, rowHeight: CGFloat, window: ScrollWindow
        ) -> CGFloat? {
            guard let hover, let dragged, window.isMeasured,
                  let gap = gap(for: hover, offset: window.offset, rowHeight: rowHeight, rows: rows),
                  destination(gap: gap, dragged: dragged, rows: rows) != nil
            else { return nil }
            let inRows = min(max(CGFloat(gap) * rowHeight - lineThickness / 2, 0),
                             max(CGFloat(rows) * rowHeight - lineThickness, 0))
            return min(max(inRows - window.offset, 0), max(window.viewport - lineThickness, 0))
        }

        /// **The end zone's height** — the room the list leaves under its rows
        /// above the column's bottom padding (the same two measurements as
        /// `openListMaxHeight`), capped at `endZoneMaxHeight`, so the zone never
        /// pushes the column past the sync footer. 0 when the rows fill the list
        /// (it scrolls; the last row's lower half is then the end slot) or before
        /// anything is measured.
        static func endZoneHeight(
            visibleHeight: CGFloat, listTop: CGFloat, bottomPadding: CGFloat, rows: Int,
            rowHeight: CGFloat
        ) -> CGFloat {
            guard visibleHeight > 0, listTop > 0, rows > 0, rowHeight > 0 else { return 0 }
            let room = visibleHeight - listTop - bottomPadding - CGFloat(rows) * rowHeight
            return max(0, min(endZoneMaxHeight, room.rounded(.down)))
        }
    }
}
