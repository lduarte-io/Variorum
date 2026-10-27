//
//  BookOutlineViewed.swift
//  Variorum (Mac)
//
//  VX-562 — THE VIEWED PAIR: which chapter and which note the book Outline's
//  viewport is showing right now. Pure, beside `BookOutlineRows`, because it
//  is the same kind of thing — one rule over the rows the column already
//  draws and the geometry they already report, inventing no state.
//
//  Her rulings, the whole reason it exists:
//  - *"maybe not [highlight the one you're typing in], it just follows what
//    your view is."* (2026-10-26) — so this reads the VIEW and never the
//    caret: it has no input that knows where the caret is, and no output that
//    reaches the book's focus authority (`BookViewModel.focus`, the caret
//    seeds, `pendingReveal`, the landing's aim). Its one writer is
//    `BookViewModel.noteOutlineViewed`, its readers are the navigator's marks
//    and the Outline's pinned line.
//  - *"make the note that you're currently on highlight on the left bar
//    ABSOLUTELY pre launch."* and *"show during scroll what # note you're in,
//    maybe what chapter you're in."* (the 10-21 improvements note).
//
//  ── THE RULE ─────────────────────────────────────────────────────────────
//  Given every row's top in the scroll's visible space (`BookView.
//  outlineSpace`, where `0` is the viewport's top edge) and a probe a little
//  below that edge, the viewed anchor is the LAST row, in column order, whose
//  top is at or above the probe. That is the row that owns the top of the
//  page: a tall expanded story whose top scrolled away long ago still owns it
//  while the next row's top is below the probe, which is exactly where the
//  Outline's own `topRow` rule (the FIRST row with `top ≥ −tolerance`) would
//  skip it — that rule answers "which row should a width change re-land", a
//  different question. Above the first row (the book's title block on screen)
//  nothing is viewed.
//
//  The rule is monotonic by construction (the set of rows at or above a probe
//  only grows as the probe moves down, so its last member never moves up),
//  and it reads only rows the column HAS — a row the caller's map does not
//  know is skipped, never guessed.
//
//  A HEADING that owns the top names the note it INTRODUCES (PROVISIONAL
//  P-562-7, ladder round 1's walk finding 11): the pin's "note N of M" used
//  to blink out at every chapter heading — every heading, in a
//  one-note-per-chapter book like Sherlock. Steady and monotonic now; the
//  chapter and the note never contradict.
//
//  ── THE END OF THE BOOK (R-562-B) ───────────────────────────────────────
//  The rows of the book's last screenful can never bring their tops to the
//  page's top edge — the column's foot follows them — so a probe fixed at
//  the edge never reached them by scrolling (ladder round 1, finding 1,
//  confirmed live on Sherlock: notes 11–13 on the page, the pin stuck at
//  10). Over the LAST viewport of scroll the probe SLIDES from the edge to
//  the page's foot, so at the bottom the last row is the viewed one and
//  every row of the last screenful is reached on the way down (`probe(_:)`).
//
//  ── THE ADOPTION (R-562-A) AND ITS RELEASES (R-562-C) ───────────────────
//  A landing is the one time the page's top is NOT what she chose to look at
//  — it is travelling, or it has put her target somewhere the rule would not
//  name (a row in the book's last screenful cannot reach the top). So the
//  follower adopts the landing's TARGET at the click (`adoptedPair`), holds
//  it through the travel, and afterwards lets it stand while the target's
//  row is on the page and she has not scrolled (`follow`); her scroll, a new
//  landing, an axis change or the target leaving the page returns it to the
//  rule. "She has not scrolled" is read from the page itself as well as from
//  her hand: the page's scroll OFFSET moving more than 8 pt from where the
//  landing left it (`BookOutlineFollower` — the whole adopt/release decision
//  in one value, table-tested without SwiftUI's event order).
//
//  App-side, never `Domain`: it is view geometry (the layer-placement note).
//

import CoreGraphics
import Foundation
import VariorumCore

nonisolated enum BookOutlineViewed {
    /// What the Outline's viewport is showing: the chapter heading in force
    /// at the viewed row, and the note it is — either may be nil. A chapter
    /// heading names the chapter alone; a note names itself and its chapter
    /// (nil under the unfiled heading or a tag-path heading); above the first
    /// row both are nil.
    struct Pair: Equatable, Sendable {
        var sectionID: String?
        var postID: String?

        init(sectionID: String? = nil, postID: String? = nil) {
            self.sectionID = sectionID
            self.postID = postID
        }

        /// Nothing viewed — the title block is on screen, the book is empty,
        /// or the Outline is not showing.
        static let nothingViewed = Pair()
    }

    /// **How far below the viewport's top edge the probe sits** — the
    /// column's own row gap (`BookOutlineHeights.rowSpacing`, the same 10 pt;
    /// stated here because that type is main-actor and this rule is not, and
    /// pinned equal in `BookOutlineViewedTests`).
    ///
    /// The gap is the honest ε, for two reasons that are both pinned:
    /// - it is at least the Outline landing's tolerance (2 pt), so a row a
    ///   landing has put "at the top" is always the viewed row — a landed
    ///   target never reads as its predecessor;
    /// - a row whose top sits within one gap of the edge has a predecessor
    ///   that is ENTIRELY above the edge (its bottom is a gap above this
    ///   row's top), so the page's top really is this row's — only the gap
    ///   above it shows.
    ///
    /// This is the probe everywhere but the book's last viewport of scroll,
    /// where it slides (`probe(_:)`, R-562-B).
    static let probe: CGFloat = 10

    // MARK: R-562-B — the page's scroll, and the probe that slides at the end

    /// **Where the page stands in its scroll** — the scroll's own facts,
    /// read at geometry cadence (`BookView`'s scroll-geometry observer): the
    /// sliding probe's three inputs.
    struct Scroll: Equatable, Sendable {
        /// The page's height (the scroll's own frame). `0` = not yet
        /// measured: no foot is known, and the probe never slides.
        var viewport: CGFloat = 0
        /// How far the page has scrolled down from its top (`0` at rest).
        var offset: CGFloat = 0
        /// How far it CAN scroll — the maximum offset (`0` = the column fits
        /// the page and never moves).
        var travel: CGFloat = 0

        init(viewport: CGFloat = 0, offset: CGFloat = 0, travel: CGFloat = 0) {
            self.viewport = viewport
            self.offset = offset
            self.travel = travel
        }
    }

    /// **Everything the follower reads about the page**: every row's last
    /// reported top and height (in the scroll's visible space, `0` the
    /// page's top edge) and where the page stands in its scroll.
    struct Page: Equatable, Sendable {
        var tops: [String: CGFloat] = [:]
        var heights: [String: CGFloat] = [:]
        var scroll = Scroll()

        init(tops: [String: CGFloat] = [:], heights: [String: CGFloat] = [:], scroll: Scroll = Scroll()) {
            self.tops = tops
            self.heights = heights
            self.scroll = scroll
        }
    }

    /// **THE PROBE, where the page stands** (R-562-B, PROVISIONAL for her):
    /// the shipped edge probe while more than a viewport of scroll remains;
    /// over the LAST viewport of scroll it slides linearly from the edge to
    /// the page's FOOT as the remaining scroll runs out — so at the bottom the
    /// book's last row is the viewed one, and every row of the last
    /// screenful becomes viewed in turn on the way down.
    ///
    /// The slide spans the last `min(viewport, travel)` of scroll, so the
    /// probe is the edge at rest in EVERY book — §DESIGN's "at rest nothing is
    /// viewed" (the title block holds the page) stays true of a book shorter
    /// than two pages too, and a book that fits its page and cannot scroll
    /// keeps the edge probe (PROVISIONAL, the record's morning bundle — the
    /// ruling's text names the slide over the last viewport of scroll and
    /// does not speak to a scroll shorter than one).
    ///
    /// Monotonic: scrolling down moves every row's top up by the distance
    /// scrolled and never moves the probe up, so the set of rows at or above
    /// it only grows (pinned).
    static func probe(_ scroll: Scroll) -> CGFloat {
        let slide = min(scroll.viewport, scroll.travel)
        guard scroll.viewport > probe, slide > 0 else { return probe }
        let remaining = max(scroll.travel - scroll.offset, 0)
        guard remaining < slide else { return probe }
        let reached = 1 - remaining / slide
        return probe + reached * (scroll.viewport - probe)
    }

    // MARK: THE RULE

    /// **THE RULE** — the last row, in column order, whose top is known and
    /// at or above `probe`, named through the rows (`named(at:in:)`). `tops`
    /// is keyed by anchor id (`BookOutlineRows.Row.id`); a row it does not
    /// hold is skipped, never guessed. Above the first row nothing is viewed.
    ///
    /// Cost: O(rows) — one dictionary probe per row, and one short walk back
    /// to the heading in force. Called at most once per run-loop turn (the
    /// caller coalesces), so the per-report cost stays O(1).
    static func pair(
        rows: [BookOutlineRows.Row], tops: [String: CGFloat], probe: CGFloat = probe
    ) -> Pair {
        var viewed: Int?
        for (index, row) in rows.enumerated() {
            if let top = tops[row.id], top <= probe { viewed = index }
        }
        guard let viewed else { return .nothingViewed }
        return named(at: viewed, in: rows)
    }

    /// **What the row at `index` names** — the chapter heading in force at
    /// it (the row itself when it is one; nil under the unfiled heading or a
    /// tag-path heading), and its note:
    /// - a NOTE names itself;
    /// - a HEADING names the note it INTRODUCES — the first note under it
    ///   (PROVISIONAL P-562-7: *"a viewed heading resolves to the note it
    ///   introduces"*, so the pin says "note 11 of 13 · ‹XI›" at XI's heading
    ///   and its number never blinks out); a heading with no note under it
    ///   (an empty chapter) names its chapter alone.
    ///
    /// The chapter is read off the column itself — the heading above the row
    /// on the page — never a second lookup that could disagree with what is
    /// drawn.
    static func named(at index: Int, in rows: [BookOutlineRows.Row]) -> Pair {
        guard rows.indices.contains(index) else { return .nothingViewed }
        var chapter: String?
        inForce: for row in rows[...index].reversed() {
            switch row {
            case .chapter(let section):
                chapter = section.id
                break inForce
            case .unfiledHeading, .tagHeading:
                break inForce
            case .note:
                continue
            }
        }
        switch rows[index] {
        case .note(let entry):
            return Pair(sectionID: chapter, postID: entry.postID)
        case .chapter, .unfiledHeading, .tagHeading:
            let next = index + 1
            if rows.indices.contains(next), case .note(let entry) = rows[next] {
                return Pair(sectionID: chapter, postID: entry.postID)
            }
            return Pair(sectionID: chapter)
        }
    }

    // MARK: R-562-A — the follower ADOPTS a landing's target

    /// **The pair a landing's TARGET names** (R-562-A: *"the follower adopts
    /// a landing's TARGET at the click"* — the navigator note row, the
    /// chapter row, a reveal, the width change's re-land of the row that was
    /// at the top). It is THE RULE's own answer for the page the landing is
    /// making — the column with that row alone at the top (`named(at:in:)`,
    /// the same naming, so a note's chapter is the heading above it on the
    /// page and a heading names the note it introduces) — handed to the slot
    /// at the landing's START, so the highlight and the pinned line move at
    /// the click. nil when the column has no such row: nothing to adopt, and
    /// the rule stands.
    static func adoptedPair(anchor: String, rows: [BookOutlineRows.Row]) -> Pair? {
        guard let index = rows.firstIndex(where: { $0.id == anchor }) else { return nil }
        return named(at: index, in: rows)
    }

    /// **Is any part of a row inside the page?** `top` and `height` are the
    /// row's last report in the scroll's visible space (`0` the page's top
    /// edge); `viewport` is the page's height. On screen when its top is on
    /// the page, or when it starts above the page and reaches into it (a tall
    /// story spanning the top edge). A row that never reported is nowhere. A
    /// page not yet measured (`viewport ≤ 0`) has no known bottom edge, so a
    /// row is found off the page only above it — the hold is released on
    /// evidence, never on a missing number.
    static func isOnScreen(top: CGFloat?, height: CGFloat?, viewport: CGFloat) -> Bool {
        guard let top else { return false }
        let reachesIn = top >= 0 || top + max(height ?? 0, 0) > 0
        return reachesIn && (viewport <= 0 || top < viewport)
    }

    /// **R-562-A after the landing: does the adopted target still stand?**
    /// The geometric half of the ruling, pure: an adoption STANDS while the
    /// column still has its row and that row is on screen (`isOnScreen`) —
    /// the page shows the TARGET's pair, wherever on the page the target sits
    /// (a row in the book's last screenful never reaches the top, and it is
    /// still what she travelled to: finding F-1); otherwise the adoption is
    /// dropped and the page shows THE RULE's pair over the probe where the
    /// page stands (R-562-B) — *"a derivation that finds the adopted row
    /// off-screen resumes the rule by itself."* The ruling's other releases
    /// are ACTS or the page's own offset, and `BookOutlineFollower` makes
    /// them before asking; the travelling landing's freeze is its too (this
    /// is asked only once no landing is pending).
    static func follow(
        rows: [BookOutlineRows.Row], page: Page, adopted: String?
    ) -> (pair: Pair, adopted: String?) {
        if let adopted, let target = adoptedPair(anchor: adopted, rows: rows),
           isOnScreen(
               top: page.tops[adopted], height: page.heights[adopted],
               viewport: page.scroll.viewport) {
            return (target, adopted)
        }
        return (pair(rows: rows, tops: page.tops, probe: probe(page.scroll)), nil)
    }

    /// **The viewed note's place in the column** — 1-based, counting note
    /// rows in the order the page draws them (PROVISIONAL P-562-5: the
    /// number she sees climb as she scrolls; in a book whose chapters order
    /// the notes differently from the membership order, this is the page's
    /// order, not `NoteBoxCopy.whereLine`'s membership index). nil ⇒ the note
    /// is not on the page.
    static func noteOrdinal(of postID: String, in rows: [BookOutlineRows.Row]) -> Int? {
        var ordinal = 0
        for row in rows {
            guard case .note(let entry) = row else { continue }
            ordinal += 1
            if entry.postID == postID { return ordinal }
        }
        return nil
    }

    /// **The book's note count, as the pinned line says it** (ladder round
    /// 1, finding 3): the notes in the book's WINDOW
    /// (`BookViewModel.entryWindow`, widened by "show more ›") and whether
    /// the window is hiding later ones (`BookViewModel.truncated` — then the
    /// count is a floor, "300+"). ONE value feeds both halves of the line,
    /// so the count line and "note N of M" can never say two numbers.
    struct NoteTotal: Equatable, Sendable {
        var count: Int
        var isAtLeast: Bool

        init(count: Int, isAtLeast: Bool = false) {
            self.count = count
            self.isAtLeast = isAtLeast
        }
    }

    /// **The pinned line's POSITION words for a viewed pair** — the facts
    /// handed to the one wording brain (`NoteBoxCopy.viewedLine`):
    /// - the note's number in the column and the book's note total (`total`
    ///   — the same one the count line says; under the in-book filter the
    ///   number is unknown and omitted, `BookNoteBox.position`'s own rule);
    /// - the chapter's NAME, only in a chaptered book (PROVISIONAL P-562-4)
    ///   — and there a note outside every chapter says the chapterless
    ///   group's one word (`BookPanelCopy.unfiled`; the surface contract's
    ///   "the chapterless group reads 'unfiled' everywhere").
    /// Empty when nothing is viewed.
    static func positionLine(
        pair: Pair, rows: [BookOutlineRows.Row],
        chaptered: Bool, filtered: Bool, total: NoteTotal
    ) -> String {
        guard pair != .nothingViewed else { return "" }
        let index = pair.postID.flatMap { noteOrdinal(of: $0, in: rows) } ?? 0
        var chapterName: String?
        for row in rows {
            if case .chapter(let section) = row, section.id == pair.sectionID {
                chapterName = section.name
                break
            }
        }
        let chapter: String? = {
            guard chaptered else { return nil }
            if pair.sectionID != nil { return chapterName }
            return pair.postID != nil ? BookPanelCopy.unfiled : nil
        }()
        return NoteBoxCopy.viewedLine(
            chapter: chapter,
            index: BookNoteBox.position(index, filtered: filtered),
            total: total.count, totalIsAtLeast: total.isAtLeast)
    }

    /// **The pinned line, whole** — the book's count line, then the position
    /// words while a pair is viewed, BOTH from the one `total` (ladder round
    /// 1, finding 3: past the 300-note window the line read "300 notes ·
    /// note 12 of 300+" — two totals side by side). Pure, so the pin reads
    /// the sentence the line draws.
    static func pinLine(
        gathering: Bool, chapters: Int, archived: Int, total: NoteTotal,
        pair: Pair, rows: [BookOutlineRows.Row], chaptered: Bool, filtered: Bool
    ) -> String {
        let meta = BookViewCopy.metaLine(
            gathering: gathering, chapters: chapters,
            notes: total.count, notesAreAtLeast: total.isAtLeast, archived: archived)
        let position = positionLine(
            pair: pair, rows: rows, chaptered: chaptered, filtered: filtered, total: total)
        return BookViewCopy.outlinePinLine(meta: meta, position: position)
    }
}

// MARK: - THE FOLLOWER: R-562-A's adoption and every release, as ONE value

/// **What the Outline's follower decides, and only that** (ladder round 1,
/// finding 6 — partial, as ruled: the ADOPT / RELEASE decision consolidated
/// into one value the view's wiring merely feeds, so the orderings the
/// ruling depends on are table-tested headless instead of living across
/// eight call sites and SwiftUI's event delivery).
///
/// The acts, each one line in the view:
/// - **a landing STARTS** (`landingStarted`) — adopt its target; the slot
///   says it at once (R-562-A, "at the click");
/// - **an axis changes** (`axisChanged` — the entries, the chapters, an
///   expansion or a collapse) — a STANDING adoption lets go; one whose
///   landing still travels is its landing's (the navigator click is itself
///   an expansion: `focus` unfolds the note in the same act as the reveal,
///   and SwiftUI's order between the two is not ours);
/// - **her hand on the page** (`userScrolled` — the user scroll phase) and
///   **the Outline leaving** (`forget`) — let go;
/// - **the look** (`look`) — frozen while a landing travels; otherwise the
///   adoption also lets go once the page's scroll OFFSET has moved more than
///   `offsetRelease` from where its landing left it (R-562-C: every input
///   that really scrolls the page — a phase-less wheel, keyboard paging, a
///   scroller drag — not only the phased one), then `follow` answers.
nonisolated struct BookOutlineFollower: Equatable, Sendable {
    typealias Pair = BookOutlineViewed.Pair

    /// The adopted landing target's anchor id — nil ⇒ the follower is the
    /// rule.
    private(set) var adopted: String?
    /// **R-562-C's key: the page's scroll offset when the adoption's landing
    /// ended** — written by the first look that finds no landing pending
    /// (the landing's own end asks first: `LandingAuthority.finish` calls
    /// `onFinish` last), nil while the landing still travels.
    private(set) var settledOffset: CGFloat?

    /// **How far the page may move under a standing adoption before it is
    /// let go** (R-562-C, a named pinned constant): 8 pt. Settle wobble stays
    /// under it — the F-1 page that cannot move included — and anything that
    /// really scrolls the page is well past it.
    static let offsetRelease: CGFloat = 8

    init() {}

    /// A landing STARTS on `anchor`: adopt its target (R-562-A). Returns the
    /// pair the slot says at once — nil when the column has no such row
    /// (nothing adopted; the freeze holds the page as it was and the
    /// landing's end asks the rule). Every landing re-adopts: a new landing
    /// is one of the releases, by replacing.
    mutating func landingStarted(anchor: String, rows: [BookOutlineRows.Row]) -> Pair? {
        settledOffset = nil
        let target = BookOutlineViewed.adoptedPair(anchor: anchor, rows: rows)
        adopted = target == nil ? nil : anchor
        return target
    }

    /// An AXIS changed — the entries, the chapters, an expansion or a
    /// collapse: a STANDING adoption lets go; a travelling one is its
    /// landing's, whose end asks `follow` against the column as it then
    /// stands.
    mutating func axisChanged(landingPending: Bool) {
        guard !landingPending else { return }
        letGo()
    }

    /// Her hand on the page (the user scroll phase): let go — FIRST, so a
    /// landing her scroll ends delivers the rule's pair, not the target's.
    mutating func userScrolled() {
        letGo()
    }

    /// The Outline left: its page is gone, and so is what it adopted.
    mutating func forget() {
        letGo()
    }

    /// **The look** — what the page shows, or nil while a landing travels
    /// (frozen: publish nothing). A standing adoption first meets R-562-C:
    /// its key is taken at the first look after its landing, and once the
    /// page's offset has moved more than `offsetRelease` from it the
    /// adoption lets go. Then `follow`: the target while its row is on the
    /// page, else the rule over the probe where the page stands.
    mutating func look(
        rows: [BookOutlineRows.Row], page: BookOutlineViewed.Page, landingPending: Bool
    ) -> Pair? {
        guard !landingPending else { return nil }
        if adopted != nil {
            if let settledOffset {
                if abs(page.scroll.offset - settledOffset) > Self.offsetRelease { letGo() }
            } else {
                settledOffset = page.scroll.offset
            }
        }
        let followed = BookOutlineViewed.follow(rows: rows, page: page, adopted: adopted)
        if followed.adopted == nil { letGo() }
        return followed.pair
    }

    private mutating func letGo() {
        adopted = nil
        settledOffset = nil
    }
}

// MARK: - The navigator's marks (one rule for every mode)

/// **Which navigator rows say "you are here"** — pure, so the per-mode
/// answer is one table rather than an expression repeated at three rows.
///
/// - OUTLINE (VX-562, her ruling): the note the page is SHOWING — the viewed
///   note, never the caret's. A chapter row wears the quieter viewed-chapter
///   wash when its chapter is the viewed pair's.
/// - Every other mode, byte-identical to before: the focused note, and in the
///   spread BOTH pages on screen (13b 4F; 13c 2B). No chapter wash (the
///   follower runs in Outline only — PROVISIONAL P-562-2).
nonisolated enum BookNavigatorMark {
    /// `spreadPostIDs`: the spread's pages (`BookNoteBox.selectedPost`'s
    /// input, the same facts) — read only in the spread.
    static func note(
        mode: BookStructureModel.ViewMode, postID: String,
        focusedPostID: String?, viewedPostID: String?, spreadPostIDs: [String]
    ) -> Bool {
        // A `switch`, not `==`: `ViewMode`'s synthesized Equatable is
        // main-actor isolated (it is nested in the structure model).
        switch mode {
        case .outline:
            return viewedPostID == postID
        case .spread:
            return focusedPostID == postID || spreadPostIDs.contains(postID)
        case .index, .read:
            return focusedPostID == postID
        }
    }

    static func chapter(
        mode: BookStructureModel.ViewMode, sectionID: String, viewedSectionID: String?
    ) -> Bool {
        switch mode {
        case .outline: return viewedSectionID == sectionID
        case .index, .spread, .read: return false
        }
    }
}
