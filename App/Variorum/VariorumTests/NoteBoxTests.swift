//
//  NoteBoxTests.swift
//  VariorumTests
//
//  18d batch 1 — the sidebar note box's BRAINS (her U-10). The face's
//  geometry oracle lives in `ShellChromeTests`; everything here is pure.
//
//  Red-on-old, stated once: none of this existed. The box is a new surface,
//  so its pins are the ruled shape written down as claims a function can be
//  asked about — the state rule her ruling names outright ("no note selected
//  when you haven't clicked into anything"), the book's own which-note rule
//  and its deliberate disagreement with `BookAnchor`, the shared height that
//  keeps the Open strip from moving, and the words.
//

import Foundation
import Testing
@testable import Variorum

@Suite("The note box's state rule (18d batch 1 — U-10)")
struct NoteBoxStateTests {
    /// **Her ruling's own sentence**: *"should show 'no note selected' when
    /// you haven't clicked into anything or you've clicked out of
    /// something."*
    @Test func nothingSelectedAndNothingLiveIsTheEmptyState() {
        #expect(NoteBoxState.from(selected: nil, live: nil) == .empty)
        #expect(NoteBoxState.from(selected: nil, live: nil).postID == nil)
    }

    @Test func aSelectedNoteThatIsNotLiveIsTheReadCheapState() {
        let state = NoteBoxState.from(selected: "n1", live: nil)
        #expect(state == .selected("n1"))
        #expect(state.postID == "n1")
        #expect(!state.isLive)
    }

    /// LIVE wins: the caret's note is also the book's selected note, and the
    /// box shows the bar rather than the door into it.
    @Test func theLiveNoteWinsOverTheSelectionItAlsoIs() {
        #expect(NoteBoxState.from(selected: "n1", live: "n1") == .live("n1"))
        #expect(NoteBoxState.from(selected: "n1", live: "n1").isLive)
        // A live note the selection rule has not caught up with still wins —
        // the box must never say "edit here" about a note under the caret.
        #expect(NoteBoxState.from(selected: nil, live: "n2") == .live("n2"))
    }
}

@Suite("Which note the book points at (18d batch 1)")
struct BookNoteBoxSubjectTests {
    /// The box stands in every EDITING mode and never in Read.
    @Test func theBoxStandsInTheEditingModesOnly() {
        #expect(BookNoteBox.shows(mode: .outline))
        #expect(BookNoteBox.shows(mode: .index))
        #expect(BookNoteBox.shows(mode: .spread))
        #expect(!BookNoteBox.shows(mode: .read))
    }

    @Test func outlinePointsAtItsFocusedNoteAndNothingElse() {
        #expect(BookNoteBox.selectedPost(
            mode: .outline, focusedPostID: "n1", spreadPostIDs: [], indexPostID: "n9") == "n1")
        // Expansion is not selection: several notes may be expanded at once,
        // so nothing focused means nothing selected.
        #expect(BookNoteBox.selectedPost(
            mode: .outline, focusedPostID: nil, spreadPostIDs: ["n2"], indexPostID: "n9") == nil)
    }

    @Test func indexPointsAtItsOwnSelection() {
        #expect(BookNoteBox.selectedPost(
            mode: .index, focusedPostID: "n1", spreadPostIDs: [], indexPostID: "n9") == "n9")
        #expect(BookNoteBox.selectedPost(
            mode: .index, focusedPostID: "n1", spreadPostIDs: [], indexPostID: nil) == nil)
    }

    /// The spread: the page under her hands keeps its claim; otherwise the
    /// left page, which is where the spread opened.
    @Test func theSpreadPointsAtThePageUnderHerHandsElseTheLeftPage() {
        #expect(BookNoteBox.selectedPost(
            mode: .spread, focusedPostID: "n2", spreadPostIDs: ["n1", "n2"],
            indexPostID: nil) == "n2")
        #expect(BookNoteBox.selectedPost(
            mode: .spread, focusedPostID: nil, spreadPostIDs: ["n1", "n2"],
            indexPostID: nil) == "n1")
        // A focus left behind on a note NOT on the spread does not claim it.
        #expect(BookNoteBox.selectedPost(
            mode: .spread, focusedPostID: "n7", spreadPostIDs: ["n1", "n2"],
            indexPostID: nil) == "n1")
        #expect(BookNoteBox.selectedPost(
            mode: .spread, focusedPostID: nil, spreadPostIDs: [], indexPostID: nil) == nil)
    }

    /// **THE DELIBERATE DISAGREEMENT WITH `BookAnchor`** (the reason this is
    /// its own rule): the anchor always falls back to the standing place, so
    /// a book she has ever put anywhere points at that note forever. The box
    /// must be able to say *"no note selected"*, which is her ruling's own
    /// sentence — so it does not fall back.
    @Test func theBoxHasNoStandingFallbackAndTheAnchorDoes() {
        let place = BookAnchor.Place(
            focusedPostID: nil, spreadPostIDs: [], pagedPostID: nil,
            indexPostID: nil, standingPostID: "carried")
        #expect(BookAnchor.currentPost(mode: .outline, readForm: .flow, place: place) == "carried")
        #expect(BookNoteBox.selectedPost(
            mode: .outline, focusedPostID: nil, spreadPostIDs: [], indexPostID: nil) == nil,
            "clicking out of a note empties the box; the carry still knows where she was")
    }

    /// Index has no full editor by design (P-3: a projection tier that
    /// upgrades ONE block), so its live note comes from its own pane's
    /// authority, never from the book's focus.
    @Test func theLiveNoteComesFromTheModesOwnLivenessAuthority() {
        #expect(BookNoteBox.livePost(
            mode: .outline, liveFocusedPostID: "n1", indexLivePostID: "n9") == "n1")
        #expect(BookNoteBox.livePost(
            mode: .spread, liveFocusedPostID: "n1", indexLivePostID: "n9") == "n1")
        #expect(BookNoteBox.livePost(
            mode: .index, liveFocusedPostID: "n1", indexLivePostID: "n9") == "n9")
        #expect(BookNoteBox.livePost(
            mode: .read, liveFocusedPostID: "n1", indexLivePostID: "n9") == nil)
        // An unfocused pane mounts no live editor — the book's own rule —
        // which is exactly the box's read-cheap second state.
        #expect(BookNoteBox.livePost(
            mode: .outline, liveFocusedPostID: nil, indexLivePostID: nil) == nil)
    }
}

@Suite("The box is measured against the rail (18d batch 1 — U-10's 'same amount of room')")
struct NoteBoxHeightTests {
    /// ONE arithmetic, and it is the rail's: a header over the mode rows.
    /// The box takes it as a fixed frame, so the Open strip below never
    /// moves between a note and a book.
    @Test func theBoxTakesTheRailGroupsOwnHeight() {
        let rows = PostDetailView.Mode.allCases.count
        let generous = SidebarLayout.railGroupHeight(
            rowHeight: SidebarLayout.generousRowHeight, railRows: rows)
        #expect(generous == SidebarLayout.groupHeaderHeight
                + CGFloat(rows) * SidebarLayout.generousRowHeight)
        // It FOLLOWS the compression, because the rail does: a constant here
        // would hold at the generous pitch and lie in a short window.
        let compact = SidebarLayout.railGroupHeight(
            rowHeight: SidebarLayout.compactRowHeight, railRows: rows)
        #expect(compact < generous)
        #expect(compact == SidebarLayout.groupHeaderHeight
                + CGFloat(rows) * SidebarLayout.compactRowHeight)
    }

    /// The fit math counts the box exactly as it counts the rail — same rows,
    /// same headed group — so a column showing a book compresses at the same
    /// height as one showing a note.
    @Test func theColumnBudgetsTheBoxExactlyAsItBudgetsTheRail() {
        let rows = PostDetailView.Mode.allCases.count
        let withRail = SidebarLayout.rowCount(starred: 0, areas: 5, rail: rows, openNotes: 2)
        #expect(withRail == 5 + rows + 2)
        let height = CGFloat(withRail) * SidebarLayout.generousRowHeight
            + SidebarLayout.chromeHeight(headedGroups: 2)
        #expect(!SidebarLayout.compressesRows(
            columnHeight: height, rows: withRail, headedGroups: 2))
        #expect(SidebarLayout.compressesRows(
            columnHeight: height - 1, rows: withRail, headedGroups: 2))
    }
}

@Suite("The note box's words (18d batch 1)")
struct NoteBoxCopyTests {
    private let now = Date(timeIntervalSince1970: 1_788_000_000)  // 2026-08-29
    private var calendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }
    private let locale = Locale(identifier: "en_US_POSIX")

    /// Mockup figure C, state 2: *"chapter 2 · 5 of 12 in this book"*.
    @Test func theWhereLineNamesTheChapterThePlaceAndTheBook() {
        #expect(NoteBoxCopy.whereLine(chapter: "chapter 2", index: 5, total: 12, block: nil)
                == "chapter 2 · 5 of 12 in this book")
        // A flat (unsectioned) book simply omits the chapter.
        #expect(NoteBoxCopy.whereLine(chapter: nil, index: 5, total: 12, block: nil)
                == "5 of 12 in this book")
        #expect(NoteBoxCopy.whereLine(chapter: "   ", index: 5, total: 12, block: nil)
                == "5 of 12 in this book")
    }

    /// The round-end Fable pass, NIT-3: a book longer than the entry window
    /// knows only a FLOOR, and the line says `300+` rather than a count it
    /// does not hold (`BookView.identity(of:)` passes `model.truncated`).
    /// A copy-truth pin over a new parameter — not red-on-old by nature.
    @Test func theWhereLineSaysAFloorForAWindowedBook() {
        #expect(NoteBoxCopy.whereLine(
                    chapter: nil, index: 5, total: 300, totalIsAtLeast: true, block: nil)
                == "5 of 300+ in this book")
        #expect(NoteBoxCopy.whereLine(
                    chapter: "one", index: 5, total: 300, totalIsAtLeast: true,
                    block: BlockLineLabel.caret(ordinal: 3, of: 41))
                == "one · 5 of 300+ · block 3/41")
        #expect(NoteBoxIdentity(postID: "p", title: "t").totalIsAtLeast == false,
                "the default is a real count")
    }

    /// State 3: the caret's block joins the line, and "in this book" gives up
    /// its words to it. The block half is the BAR's own label, handed in.
    @Test func theWhereLineTakesTheCaretsBlockWhileLive() {
        let block = BlockLineLabel.caret(ordinal: 3, of: 41)
        #expect(NoteBoxCopy.whereLine(chapter: "chapter 2", index: 5, total: 12, block: block)
                == "chapter 2 · 5 of 12 · block 3/41")
        #expect(NoteBoxCopy.whereLine(chapter: nil, index: 0, total: 0, block: block)
                == "block 3/41")
        #expect(NoteBoxCopy.whereLine(chapter: nil, index: 0, total: 0, block: nil) == "")
    }

    @Test func theCountsLineSaysWordsAndBlocksAndCountsOne() {
        #expect(NoteBoxCopy.countsLine(words: 3214, blocks: 41).hasSuffix("41 blocks"))
        #expect(NoteBoxCopy.countsLine(words: 3214, blocks: 41).contains(" · "))
        #expect(NoteBoxCopy.countsLine(words: 1, blocks: 1) == "1 word · 1 block")
        #expect(NoteBoxCopy.countsLine(words: 0, blocks: 0) == "0 words · 0 blocks")
    }

    /// The stamps line speaks the ONE stamp rule's glance words, and it says
    /// only what it knows.
    ///
    /// VX-351 (the VX-348 run, U4 — her R-VX348-1/3), a JUSTIFIED EDIT: this
    /// pin was "DATE-ONLY … no time of day, ever" — the old rule her ruling
    /// retires (a note edited a minute ago read "edited Aug 29" here while
    /// every other stamp said "today 9:20 PM"). Today's edit carries its time;
    /// a day past today carries none (the glances stay calm).
    @Test func theStampsLineSpeaksTheGlanceRuleAndOmitsWhatItDoesNotKnow() {
        let edited = Date(timeIntervalSince1970: 1_788_000_000)
        let saved = Date(timeIntervalSince1970: 1_787_800_000)
        let both = NoteBoxCopy.stampsLine(
            edited: edited, saved: saved, now: now, calendar: calendar, locale: locale)
        #expect(both != nil)
        #expect(both?.hasPrefix("edited today ") == true, "\(both ?? "nil")")
        #expect(both?.contains(" · saved ") == true)
        // Today's edit carries its time; the commit two days back, none.
        #expect(both?.contains(":") == true)
        #expect(both?.hasSuffix(" · saved Aug 27") == true, "\(both ?? "nil")")
        // A note nobody has committed says only when it was edited.
        let editedOnly = NoteBoxCopy.stampsLine(
            edited: edited, saved: nil, now: now, calendar: calendar, locale: locale)
        #expect(editedOnly?.contains("saved") == false)
        #expect(NoteBoxCopy.stampsLine(
            edited: nil, saved: nil, now: now, calendar: calendar, locale: locale) == nil)
    }

    /// A day from another YEAR carries it — "Sep 4" for something written two
    /// years ago is a lie told by omission.
    @Test func aDayFromAnotherYearCarriesTheYear() {
        let thisYear = NoteBoxCopy.day(
            Date(timeIntervalSince1970: 1_788_000_000), now: now,
            calendar: calendar, locale: locale)
        #expect(!thisYear.contains("2026"))
        let older = NoteBoxCopy.day(
            Date(timeIntervalSince1970: 1_700_000_000), now: now,
            calendar: calendar, locale: locale)
        #expect(older.contains("2023"), "\(older)")
    }
}
