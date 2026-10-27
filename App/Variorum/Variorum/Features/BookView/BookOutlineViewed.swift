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
    static let probe: CGFloat = 10

    /// **THE RULE, on its own:** the index of the last anchor (in the order
    /// given — the column's) whose top is known and at or above `probe`.
    /// nil ⇒ none is.
    static func viewedIndex(tops: [CGFloat?], probe: CGFloat = probe) -> Int? {
        var viewed: Int?
        for (index, top) in tops.enumerated() {
            if let top, top <= probe { viewed = index }
        }
        return viewed
    }

    /// **The rule, resolved through the rows** — one pass over the column in
    /// order, tracking the chapter heading in force, so a note's chapter is
    /// the heading above it on the page (never a second lookup that could
    /// disagree with what is drawn). `tops` is keyed by anchor id
    /// (`BookOutlineRows.Row.id`); a row it does not hold is skipped.
    ///
    /// Cost: O(rows) — one dictionary probe per row, no allocation beyond
    /// each row's id. Called at most once per run-loop turn (the caller
    /// coalesces), so the per-report cost stays O(1).
    static func pair(
        rows: [BookOutlineRows.Row], tops: [String: CGFloat], probe: CGFloat = probe
    ) -> Pair {
        var chapter: String?
        var viewed = Pair.nothingViewed
        for row in rows {
            switch row {
            case .chapter(let section): chapter = section.id
            case .unfiledHeading, .tagHeading: chapter = nil
            case .note: break
            }
            guard let top = tops[row.id], top <= probe else { continue }
            switch row {
            case .chapter(let section):
                viewed = Pair(sectionID: section.id)
            case .unfiledHeading, .tagHeading:
                // A group heading that is not a chapter names no chapter and
                // no note — the page's top is a heading between notes.
                viewed = .nothingViewed
            case .note(let entry):
                viewed = Pair(sectionID: chapter, postID: entry.postID)
            }
        }
        return viewed
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

    /// **The pinned line's POSITION words for a viewed pair** — the facts
    /// handed to the one wording brain (`NoteBoxCopy.viewedLine`):
    /// - the note's number in the column and the column's note count (a
    ///   windowed book's count is a floor — `truncated`; under the in-book
    ///   filter the number is unknown and omitted, `BookNoteBox.position`'s
    ///   own rule);
    /// - the chapter's NAME, only in a chaptered book (PROVISIONAL P-562-4)
    ///   — and there a note outside every chapter says the chapterless
    ///   group's one word (`BookPanelCopy.unfiled`; the surface contract's
    ///   "the chapterless group reads 'unfiled' everywhere").
    /// Empty when nothing is viewed.
    static func positionLine(
        pair: Pair, rows: [BookOutlineRows.Row],
        chaptered: Bool, filtered: Bool, truncated: Bool
    ) -> String {
        let index = pair.postID.flatMap { noteOrdinal(of: $0, in: rows) } ?? 0
        var total = 0
        var chapterName: String?
        for row in rows {
            switch row {
            case .note: total += 1
            case .chapter(let section) where section.id == pair.sectionID:
                chapterName = section.name
            default: break
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
            total: total, totalIsAtLeast: truncated)
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
