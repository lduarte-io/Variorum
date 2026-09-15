//
//  BookOutlineRows.swift
//  Variorum
//
//  The Act 10 correction round, batch B (rows 9/12/14/44/47) — Outline's
//  rows, FLATTENED: one lazy item per chapter heading, unfiled heading,
//  tag-path heading and note, each carrying the anchor id the page lands
//  on. Pure, so the flattening is pinned rather than observed.
//
//  Why flat: `ScrollViewProxy.scrollTo` reaches an UNREALIZED row of a
//  `LazyVStack` only through the row's own `ForEach` identity — an explicit
//  `.id` on a view that has not been built yet is unknown to the reader
//  (measured in this round's harness: a reveal of an off-screen card moved
//  nothing; the same reveal by the ForEach identity landed). With nested
//  `ForEach`es (groups, then entries) the chapter heading's identity was an
//  `Optional<String>` group id shared with its entries' container, and the
//  card's `page-<id>` anchor lived INSIDE the row. One flat list makes every
//  landing target a first-class lazy identity — the grouping itself is
//  still `BookStructureModel.grouped` (chapters) and `sectionHeader(at:)`'s
//  rule (tag paths); nothing here re-decides an order.
//

import Foundation
import VariorumCore

nonisolated enum BookOutlineRows {
    enum Row: Identifiable, Equatable {
        /// A real chapter heading (curated books with live sections).
        case chapter(ReadingSection)
        /// The trailing "unfiled" heading (ratified: strays trail).
        case unfiledHeading
        /// A smart book's tag-path heading (`grouping_tag_id` sectioning).
        case tagHeading(path: String, ordinal: Int)
        /// One note's row — a card, or the expanded note.
        case note(Queries.ReadingEntry)

        /// The landing anchor — what `scrollTo` targets and what the
        /// geometry oracle reports under.
        var id: String {
            switch self {
            case .chapter(let section): Self.chapterAnchor(section.id)
            case .unfiledHeading: "unfiled"
            case .tagHeading(_, let ordinal): "path-\(ordinal)"
            case .note(let entry): Self.noteAnchor(entry.postID)
            }
        }

        static func chapterAnchor(_ sectionID: String) -> String { "chapter-\(sectionID)" }
        static func noteAnchor(_ postID: String) -> String { "page-\(postID)" }
    }

    /// Chaptered books: each group's heading (or the unfiled heading), then
    /// its notes — `grouped`'s order, rendered.
    static func rows(
        grouped: [(section: ReadingSection?, entries: [Queries.ReadingEntry])]
    ) -> [Row] {
        var result: [Row] = []
        for group in grouped {
            if let section = group.section {
                result.append(.chapter(section))
            } else {
                result.append(.unfiledHeading)
            }
            result.append(contentsOf: group.entries.map { .note($0) })
        }
        return result
    }

    /// Flat books (smart, or curated without chapters): a tag-path heading
    /// where the section differs from the previous entry's (the
    /// `sectionHeader(at:)` rule, restated over the whole list so the row
    /// list is one pure value).
    static func rows(flat entries: [Queries.ReadingEntry]) -> [Row] {
        var result: [Row] = []
        for (i, entry) in entries.enumerated() {
            if let path = entry.sectionPath,
               i == 0 || entries[i - 1].sectionPath != path {
                result.append(.tagHeading(path: path, ordinal: i))
            }
            result.append(.note(entry))
        }
        return result
    }

    // MARK: - The column's SEGMENTS (row 53 — one container per row scale)

    /// A stretch of Outline's column: a RUN of small rows (chapter headings,
    /// cards) that share one lazy container, or ONE expanded note standing
    /// as a direct child of the column.
    ///
    /// Why the split exists (the orchestrator's walk, row 53 — traced on
    /// the dev store): a `LazyVStack` estimates every row it has not
    /// realized at the AVERAGE of the rows it has measured. Cards are
    /// ~100 pt and an expanded story ~20,000 pt; once a few stories have
    /// been measured the average is thousands of points per card, the
    /// container's content estimate inflates toward rows × average (the
    /// trace's asymptote: 26 rows → ~126,000 pt against ~50,000 real), and
    /// every far target's position is off by tens of thousands of points —
    /// no scroll request can realize it. Runs of small rows keep their own
    /// lazy container (uniform rows, honest estimates); an expanded note
    /// leaves the lazy containers entirely and is virtualized by the book
    /// itself (`OutlinePostRow`: a placeholder of its remembered height
    /// when far from the viewport, the real surface when near — P3 for the
    /// heavy unit, exact geometry for the column).
    enum Segment: Identifiable, Equatable {
        case run([Row])
        case expanded(Queries.ReadingEntry)

        var id: String {
            switch self {
            case .run(let rows): "run-" + (rows.first?.id ?? "empty")
            case .expanded(let entry): Row.noteAnchor(entry.postID)
            }
        }
    }

    /// Split the flat row list at every expanded note — **and at every change
    /// of ROW SCALE** (13u2 UNIT A). Pure — pinned.
    ///
    /// **Why the second split** (measured, 13u2 UNIT A; it is this file's own
    /// doctrine applied one level down): a `LazyVStack` estimates every row it
    /// has not realized at the AVERAGE of the rows it HAS measured, so a
    /// container holding two different row scales reports a content height
    /// that swings as the scroll changes WHICH kind is realized. A run mixing
    /// chapter headings (~51 pt) with note cards (~103 pt) swung the column by
    /// 68–74 pt per pass — enough to walk a landed target off the top of the
    /// page and keep it moving (`openingACollapsedStoryLandsAtItsTopWith
    /// ThreeStoriesExpanded` never converged, 13 hops and still 74 pt out).
    /// Proven by elimination: with the deltas instrumented, NOT ONE anchored
    /// row changed height during the drift — every point of it was the lazy
    /// estimate for rows that had not been realized.
    ///
    /// The header above already says why stories leave the lazy containers
    /// ("uniform rows, honest estimates"); headings and cards are the same
    /// claim at a smaller ratio, and the ratio is what decides. A run is now
    /// all-headings or all-cards, so its average IS its rows.
    static func segments(rows: [Row], isExpanded: (String) -> Bool) -> [Segment] {
        var result: [Segment] = []
        var run: [Row] = []
        func flush() {
            if !run.isEmpty { result.append(.run(run)); run = [] }
        }
        for row in rows {
            if case .note(let entry) = row, isExpanded(entry.postID) {
                flush()
                result.append(.expanded(entry))
                continue
            }
            if let last = run.last, isCardScale(last) != isCardScale(row) { flush() }
            run.append(row)
        }
        flush()
        return result
    }

    /// The two row SCALES a run may hold: a collapsed note's card, or one of
    /// the headings. Only the distinction matters, never the numbers — a
    /// container of one scale estimates its unrealized rows correctly whatever
    /// that scale turns out to be.
    static func isCardScale(_ row: Row) -> Bool {
        if case .note = row { return true }
        return false
    }

    // MARK: - The card's preview (row 45) and the gutter's line (row 13)

    /// The words a collapsed card previews (the correction round, row 45 —
    /// "A Scandal in Bohemia" previewed as "I."): the first ~`words` words
    /// ACROSS the note's leading blocks, skipping a LONE heading or numeral
    /// block at the front (a markdown heading; or a one-/two-word stub such
    /// as `I.`, `II`, `1.`), joined across block breaks by a space, with an
    /// ellipsis where the note goes on. Derived at read time from the
    /// rendered texts, never stored. A note that is ONLY a stub previews the
    /// stub (never an empty card).
    static func cardPreview(blocks: [String], words limit: Int = 40) -> String {
        let texts = blocks
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !texts.isEmpty else { return "" }
        var leading = texts[...]
        // Skip stubs at the front — but never the whole note.
        while leading.count > 1, let first = leading.first, isLoneHeadingOrNumeral(first) {
            leading = leading.dropFirst()
        }
        var pieces: [String] = []
        var budget = limit
        var truncated = false
        for text in leading {
            // The block's words, as ranges, so the slice keeps its own
            // punctuation and spacing.
            var ranges: [Range<String.Index>] = []
            text.enumerateSubstrings(in: text.startIndex..., options: .byWords) { _, range, _, stop in
                ranges.append(range)
                if ranges.count > budget { stop = true }
            }
            if ranges.count > budget {
                let cut = ranges[budget - 1].upperBound
                pieces.append(String(text[..<cut]))
                truncated = true
                budget = 0
                break
            }
            pieces.append(text)
            budget -= ranges.count
            if budget <= 0 {
                // Exactly at the cap — anything after this block is elided.
                truncated = leading.last != text
                break
            }
        }
        let joined = pieces
            .map { $0.replacingOccurrences(of: "\n", with: " ") }
            .joined(separator: " ")
        return truncated ? joined + "…" : joined
    }

    /// A block that is a heading or a numeral by itself: a markdown heading
    /// line (`NoteIndexOutline`'s rule), or at most two "words" in at most
    /// twelve characters — `I.`, `II`, `1.`, `Part 2`, `Chapter 3`. Ladder
    /// R1-13: a short SENTENCE — one that ends in a full stop, a question
    /// or an exclamation mark and is not a lone numeral-like token — is a
    /// preview, never a stub (`Dear reader.` and `Chapter one.` open the
    /// card; `I.` and `IV.` still do not).
    static func isLoneHeadingOrNumeral(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.contains("\n") else { return false }
        if NoteIndexOutline.headingLevel(of: trimmed) != nil { return true }
        guard trimmed.count <= 12 else { return false }
        var words = 0
        trimmed.enumerateSubstrings(
            in: trimmed.startIndex..., options: [.byWords, .substringNotRequired]
        ) { _, _, _, _ in words += 1 }
        guard words <= 2 else { return false }
        if let last = trimmed.last, ".!?".contains(last) {
            // A terminated text is a sentence unless what precedes the mark
            // is one numeral-like token: digits, or a Roman numeral.
            let body = trimmed.dropLast().trimmingCharacters(in: .whitespaces)
            return isNumeralToken(body)
        }
        return true
    }

    /// `1`, `12`, `I`, `IV`, `XLII` — never `one`, never two words. Ladder
    /// R2-11: a Roman numeral is UPPERCASE and at most five letters — a
    /// word that happens to spell in I·V·X·L·C·D·M (`Mild.`, `Dim.`,
    /// `Civic.`, `Mimic.`) is a sentence and previews like one; `iv.` is
    /// prose too (a numeral heading is set in capitals).
    private static func isNumeralToken(_ token: String) -> Bool {
        guard !token.isEmpty, !token.contains(" ") else { return false }
        if token.allSatisfy(\.isNumber) { return true }
        let roman = Set("IVXLCDM")
        return token.count <= 5 && token.allSatisfy { roman.contains($0) }
    }

    // (The details gutter's line LEFT this file at 18d batch 1: U-17 retires
    // the gutter entirely and state 2 of the sidebar's note box carries the
    // note's facts now, so the function moved to its only remaining consumer
    // — `NoteBoxCopy.takesLine` — rather than being called across a feature
    // boundary. Its claim and its pin are unchanged; the pin moved with it.)

    // MARK: - The navigator's duplicate line (row 8)

    /// Does this chapter's ONE note say the chapter's name? Then the
    /// navigator collapses the note line INTO the chapter row (the Sherlock
    /// book: chapter "A Scandal in Bohemia" over note "A Scandal in
    /// Bohemia"); the chapter row opens the note. `BookNaming.key` is the
    /// comparison — ends-trimmed, case-folded — so the field guide's
    /// differently-named chapters and notes are untouched.
    static func noteLineCollapsesIntoChapter(
        section: ReadingSection, entries: [Queries.ReadingEntry]
    ) -> Bool {
        guard entries.count == 1, let only = entries.first else { return false }
        return BookNaming.sameName(only.displayTitle, section.name)
    }

    /// What a navigator NOTE row does — and a one-note chapter's COLLAPSED
    /// row, which IS that note's row (row 8) — decided by the TAB.
    enum NavigatorRowAct: Equatable {
        /// Outline (and Index, where the navigator is hidden): open the
        /// note for editing — focus + reveal, as row 8 built it.
        case openTheNote
        /// The spread ("Book"): page-jump to the note (13b 4F).
        case showOnSpread
        /// Read ▸ Scroll: the flow lands on the story — its chapter's
        /// heading when it opens the chapter, the same landing road the
        /// chapter rows use (`FlowRows.landingAnchor`).
        case landTheFlow
        /// Read ▸ Pages: the reader turns to the story's first page.
        case turnThePages
    }

    /// **R-cor-17 (2026-09-02, her ruling on round 2's R2-10):** in the
    /// book's READ tab — Scroll AND Pages — a navigator note row LANDS THE
    /// READ PAGE at that story; chapter rows and note rows alike land it,
    /// and the navigator NEVER leaves Read (a note row used to take the
    /// note-open road into Outline — batch H's door piece had made only
    /// the collapsed one-note chapter row the chapter's act in Read, and
    /// round 2 recorded the three-way seam). Outline keeps opening the
    /// note for editing; the spread keeps its page-jump — and the collapsed
    /// one-note chapter row takes the NOTE row's act in every tab (it IS
    /// the note's row), which also closes the reviewer's spread half of the
    /// seam (it left the Book tab for Outline while a plain note row there
    /// page-jumped). Pure; pinned.
    static func navigatorNoteRowAct(
        mode: BookStructureModel.ViewMode, readForm: BookStructureModel.ReadForm
    ) -> NavigatorRowAct {
        // Pattern matches, not `==`: the models' Equatable conformances are
        // main-actor isolated and this brain is nonisolated.
        switch mode {
        case .read:
            if case .pages = readForm { return .turnThePages }
            return .landTheFlow
        case .spread:
            return .showOnSpread
        case .outline, .index:
            return .openTheNote
        }
    }
}
