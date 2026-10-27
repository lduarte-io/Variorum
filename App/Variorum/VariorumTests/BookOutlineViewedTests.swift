//
//  BookOutlineViewedTests.swift
//  VariorumTests
//
//  VX-562 — the book Outline's VIEWED PAIR, pinned as a pure rule: the last
//  row in column order whose top is at or above the probe, resolved through
//  the rows to (chapter, note); the note's place on the page; the pinned
//  line's position words through the one wording brain; and the navigator's
//  one mark table. New capability — these are born with the code they pin
//  (no red-on-old by nature; the record's §DESIGN Evidence names them).
//
//  The geometry the tables stand in for is `BookView.outlineSpace`: a row's
//  top in the scroll's VISIBLE space, `0` the viewport's top edge, negative
//  above it.
//

import CoreGraphics
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("VX-562 — the Outline's viewed pair (pure)")
struct BookOutlineViewedTests {
    private func entry(_ id: String, path: String? = nil) -> Queries.ReadingEntry {
        Queries.ReadingEntry(postID: id, title: nil, entryDate: nil, sectionPath: path)
    }

    private func section(_ id: String, _ name: String? = nil) -> ReadingSection {
        ReadingSection(
            id: id, readingId: "book", name: name ?? id, position: id,
            createdAt: Date(timeIntervalSince1970: 0), updatedAt: Date(timeIntervalSince1970: 0))
    }

    /// A chaptered book's column: chapter one (a, b), chapter two (c — the
    /// long story), then the unfiled heading and d.
    private var chaptered: [BookOutlineRows.Row] {
        BookOutlineRows.rows(grouped: [
            (section("s1", "chapter one"), [entry("a"), entry("b")]),
            (section("s2", "chapter two"), [entry("c")]),
            (nil, [entry("d")]),
        ])
    }

    private typealias Pair = BookOutlineViewed.Pair

    // MARK: - The rule

    /// At rest at the book's top, the title block holds the page: every row
    /// starts below the probe, so nothing is viewed — no highlight, no
    /// position words (P-562-3's "whenever a viewed note resolves").
    @Test func atTheTopOfTheBookNothingIsViewed() {
        let tops: [String: CGFloat] = [
            "chapter-s1": 120, "page-a": 170, "page-b": 280, "chapter-s2": 390,
            "page-c": 440, "unfiled": 16_900, "page-d": 16_950,
        ]
        #expect(BookOutlineViewed.pair(rows: chaptered, tops: tops) == .nothingViewed)
    }

    /// The case the Outline's own `topRow` rule gets wrong: a story far
    /// taller than the viewport, scrolled deep, owns the page — its top is
    /// thousands of points above the edge and the next row's is below it.
    @Test func aTallStorySpanningTheViewportIsTheViewedNote() {
        let tops: [String: CGFloat] = [
            "chapter-s1": -9_000, "page-a": -8_950, "page-b": -8_840, "chapter-s2": -8_730,
            "page-c": -8_680, "unfiled": 7_500, "page-d": 7_550,
        ]
        #expect(BookOutlineViewed.pair(rows: chaptered, tops: tops)
                == Pair(sectionID: "s2", postID: "c"),
                "the story whose top scrolled away long ago still owns the page — with its chapter")
    }

    /// Between chapters: a chapter heading at the top names the chapter
    /// alone; once its first note's top crosses the probe, the note joins it.
    @Test func aChapterHeadingNamesTheChapterAloneUntilItsFirstNoteArrives() {
        var tops: [String: CGFloat] = [
            "chapter-s1": -600, "page-a": -550, "page-b": -440, "chapter-s2": 0,
            "page-c": 50, "unfiled": 17_000, "page-d": 17_050,
        ]
        #expect(BookOutlineViewed.pair(rows: chaptered, tops: tops) == Pair(sectionID: "s2"),
                "the heading landed at the top: the chapter, no note")
        tops["chapter-s2"] = -40
        tops["page-c"] = 11
        #expect(BookOutlineViewed.pair(rows: chaptered, tops: tops) == Pair(sectionID: "s2"),
                "the heading scrolled past, the note's top still a point below the probe")
        tops["chapter-s2"] = -45
        tops["page-c"] = 6
        #expect(BookOutlineViewed.pair(rows: chaptered, tops: tops)
                == Pair(sectionID: "s2", postID: "c"),
                "the note's top is within the probe: the page is the note's")
    }

    /// The previous chapter's last note still owns the page while the next
    /// chapter's heading sits below the probe.
    @Test func thePreviousChaptersLastNoteHoldsUntilTheNextHeadingCrosses() {
        let tops: [String: CGFloat] = [
            "chapter-s1": -400, "page-a": -350, "page-b": -240, "chapter-s2": 60,
            "page-c": 110, "unfiled": 17_000, "page-d": 17_050,
        ]
        #expect(BookOutlineViewed.pair(rows: chaptered, tops: tops)
                == Pair(sectionID: "s1", postID: "b"))
    }

    /// Unfiled: a note under the unfiled heading names no chapter; the
    /// heading itself names nothing (it is not a chapter).
    @Test func unfiledNotesNameNoChapterAndTheUnfiledHeadingNamesNothing() {
        var tops: [String: CGFloat] = [
            "chapter-s1": -18_000, "page-a": -17_950, "page-b": -17_840,
            "chapter-s2": -17_730, "page-c": -17_680, "unfiled": -60, "page-d": -10,
        ]
        #expect(BookOutlineViewed.pair(rows: chaptered, tops: tops) == Pair(postID: "d"))
        tops["unfiled"] = 0
        tops["page-d"] = 50
        #expect(BookOutlineViewed.pair(rows: chaptered, tops: tops) == .nothingViewed,
                "the unfiled heading at the top: no chapter, no note")
    }

    /// A book with no notes has no rows, and nothing is viewed.
    @Test func anEmptyBookViewsNothing() {
        #expect(BookOutlineViewed.pair(rows: [], tops: [:]) == .nothingViewed)
        #expect(BookOutlineViewed.pair(rows: [], tops: ["page-x": -100]) == .nothingViewed,
                "a stale top for a row the column no longer has is never read")
        #expect(BookOutlineViewed.viewedIndex(tops: []) == nil)
    }

    /// A flat book (tag-path headings): notes name no chapter; the heading
    /// names nothing.
    @Test func aFlatBookNamesNotesAndNoChapters() {
        let rows = BookOutlineRows.rows(flat: [
            entry("a", path: "life"), entry("b", path: "life"), entry("c", path: "work"),
        ])
        #expect(rows.map(\.id) == ["path-0", "page-a", "page-b", "path-2", "page-c"])
        let tops: [String: CGFloat] = [
            "path-0": -500, "page-a": -450, "page-b": -200, "path-2": 300, "page-c": 350,
        ]
        #expect(BookOutlineViewed.pair(rows: rows, tops: tops) == Pair(postID: "b"))
    }

    /// The probe's ε edge, both sides — and the two facts that make the gap
    /// the honest ε: a landed row (within the landing's tolerance of the
    /// top) is always the viewed one, and the probe IS the column's gap.
    @MainActor
    @Test func theProbeIsTheColumnsGapAndALandedRowIsAlwaysViewed() {
        #expect(BookOutlineViewed.probe == BookOutlineHeights.rowSpacing,
                "the probe is the column's own row gap")
        #expect(BookOutlineViewed.probe >= BookView.landingTolerance,
                "a row a landing calls home is within the probe")
        let rows = BookOutlineRows.rows(flat: [entry("a"), entry("b")])
        let at: (CGFloat) -> Pair = { bTop in
            BookOutlineViewed.pair(rows: rows, tops: ["page-a": -300, "page-b": bTop])
        }
        #expect(at(BookOutlineViewed.probe) == Pair(postID: "b"), "exactly at the probe: viewed")
        #expect(at(BookOutlineViewed.probe + 0.5) == Pair(postID: "a"), "half a point below it: not yet")
        #expect(at(BookView.landingTolerance) == Pair(postID: "b"), "a landing's worst 'home' (+2)")
        #expect(at(-BookView.landingTolerance) == Pair(postID: "b"), "and its other side (−2)")
    }

    /// A row the caller's map does not hold is skipped, never guessed.
    @Test func aRowWithNoReportedTopIsSkipped() {
        let rows = BookOutlineRows.rows(flat: [entry("a"), entry("b"), entry("c")])
        #expect(BookOutlineViewed.pair(rows: rows, tops: ["page-a": -300, "page-c": 400])
                == Pair(postID: "a"))
        #expect(BookOutlineViewed.viewedIndex(tops: [-300, nil, 400]) == 0)
        #expect(BookOutlineViewed.viewedIndex(tops: [nil, nil]) == nil)
    }

    /// Monotonic: as the probe moves down the page, the viewed row never
    /// moves up the column.
    @Test func theRuleIsMonotonicInTheProbe() {
        let tops: [CGFloat?] = [-900, -400, nil, -10, 3, 250, 251, 4_000]
        var previous = -1
        for probe in stride(from: CGFloat(-1_000), through: 5_000, by: 7) {
            let index = BookOutlineViewed.viewedIndex(tops: tops, probe: probe) ?? -1
            #expect(index >= previous, "probe \(probe): \(index) moved up from \(previous)")
            previous = index
        }
        #expect(BookOutlineViewed.viewedIndex(tops: tops, probe: 10) == 4)
    }

    // MARK: - R-562-A — the follower adopts a landing's target

    /// The pair a landing's target names is the rule's own answer for the
    /// page with that row at its top — adopted at the click.
    @Test func aLandingsTargetNamesWhatTheRuleSaysOfItAtTheTop() {
        let adopt: (String) -> Pair? = { anchor in
            BookOutlineViewed.adoptedPair(anchor: anchor, rows: self.chaptered)
        }
        #expect(adopt("page-c") == Pair(sectionID: "s2", postID: "c"),
                "a note: itself, and the chapter heading above it on the page")
        #expect(adopt("page-a") == Pair(sectionID: "s1", postID: "a"))
        #expect(adopt("chapter-s2") == Pair(sectionID: "s2"), "a chapter heading: the chapter alone")
        #expect(adopt("page-d") == Pair(postID: "d"), "a note under the unfiled heading names no chapter")
        #expect(adopt("unfiled") == .nothingViewed,
                "the unfiled heading names nothing — what the rule says of it at the top")
        #expect(adopt("page-zz") == nil, "a row the column does not have: nothing to adopt")
        // The same answer the rule gives once the landing has put the target
        // at the top with the whole column reporting.
        let landed: [String: CGFloat] = [
            "chapter-s1": -320, "page-a": -270, "page-b": -160, "chapter-s2": -50,
            "page-c": 0, "unfiled": 8_700, "page-d": 8_750,
        ]
        #expect(adopt("page-c") == BookOutlineViewed.pair(rows: chaptered, tops: landed))
        let flat = BookOutlineRows.rows(flat: [entry("a", path: "life"), entry("b", path: "life")])
        #expect(BookOutlineViewed.adoptedPair(anchor: "path-0", rows: flat) == .nothingViewed,
                "a tag-path heading names nothing")
        #expect(BookOutlineViewed.adoptedPair(anchor: "page-b", rows: flat) == Pair(postID: "b"))
    }

    /// On the page while ANY part of the row is — the hold's geometric test.
    @Test func aRowIsOnThePageWhileAnyPartOfItIs() {
        let page: CGFloat = 700
        let cases: [(top: CGFloat?, height: CGFloat?, on: Bool, why: String)] = [
            (0, 100, true, "landed at the top"),
            (-2, 100, true, "a landing's tolerance above the edge"),
            (480, 100, true, "the F-1 place: the last screenful, below the top"),
            (-8_000, 9_000, true, "a tall story spanning the page's top edge"),
            (699, 100, true, "its top a point above the page's foot"),
            (700, 100, false, "its top at the page's foot: below the page"),
            (-150, 100, false, "scrolled wholly past, above the page"),
            (-100, 100, false, "its bottom exactly at the top edge: nothing of it shows"),
            (0, 0, true, "a zero-height row at the top"),
            (nil, 100, false, "a row that never reported is nowhere"),
            (-50, nil, false, "above the edge with no known height: it reaches nothing"),
            (40, nil, true, "its top on the page, height unknown"),
        ]
        for c in cases {
            #expect(BookOutlineViewed.isOnScreen(top: c.top, height: c.height, viewport: page) == c.on,
                    "\(c.why)")
        }
        // A page not yet measured has no bottom edge — a row is found off it
        // only above it.
        #expect(BookOutlineViewed.isOnScreen(top: 50_000, height: 100, viewport: 0))
        #expect(!BookOutlineViewed.isOnScreen(top: -150, height: 100, viewport: 0))
    }

    /// After the landing: the adoption stands while its row is on the page —
    /// wherever on the page — and the rule resumes, the adoption dropped, the
    /// moment a derivation finds it off the page or out of the column.
    @Test func theAdoptedTargetStandsWhileItIsOnThePageAndTheRuleResumesWhenItLeaves() {
        let heights: [String: CGFloat] = [
            "chapter-s1": 40, "page-a": 100, "page-b": 100, "chapter-s2": 40,
            "page-c": 100, "unfiled": 40, "page-d": 100,
        ]
        // The column, 10 pt between rows, its first row's top at `t`.
        let column: (CGFloat) -> [String: CGFloat] = { t in [
            "chapter-s1": t, "page-a": t + 50, "page-b": t + 160, "chapter-s2": t + 270,
            "page-c": t + 320, "unfiled": t + 430, "page-d": t + 480,
        ] }
        let follow: ([String: CGFloat], String?, CGFloat) -> (pair: Pair, adopted: String?) = {
            tops, adopted, viewport in
            BookOutlineViewed.follow(
                rows: self.chaptered, tops: tops, heights: heights,
                viewport: viewport, adopted: adopted)
        }

        // THE F-1 PAGE — the book's last screenful: note a owns the top; the
        // target d sits 380 pt down, as high as the page can take it.
        let lastScreen = column(-100)
        let free = follow(lastScreen, nil, 700)
        #expect(free.pair == Pair(sectionID: "s1", postID: "a") && free.adopted == nil,
                "no adoption: the rule names the row at the top")
        let held = follow(lastScreen, "page-d", 700)
        #expect(held.pair == Pair(postID: "d"),
                "the target the landing could not lift to the top STANDS — never the top row")
        #expect(held.adopted == "page-d", "and the adoption is kept")

        // Landed at the top: the target — what the rule says there too.
        let atTop = follow(column(-480), "page-d", 700)
        #expect(atTop.pair == Pair(postID: "d") && atTop.adopted == "page-d")
        #expect(atTop.pair == BookOutlineViewed.pair(rows: chaptered, tops: column(-480)))

        // Off the page ABOVE (the chapter heading scrolled wholly past): the
        // rule resumes by itself, the adoption dropped.
        let above = follow(lastScreen, "chapter-s1", 700)
        #expect(above.pair == Pair(sectionID: "s1", postID: "a") && above.adopted == nil)
        // Off the page BELOW (a short page; d's top under its foot).
        let below = follow(column(-300), "page-d", 150)
        #expect(below.pair == Pair(sectionID: "s2") && below.adopted == nil,
                "below the foot: the rule — chapter two's heading owns the top")
        // Out of the column (the note left the book): the rule, dropped.
        var gone = lastScreen
        gone["page-zz"] = 380
        let left = follow(gone, "page-zz", 700)
        #expect(left.pair == Pair(sectionID: "s1", postID: "a") && left.adopted == nil)
        // Never reported: nowhere, so the rule.
        var unreported = lastScreen
        unreported["page-d"] = nil
        let silent = follow(unreported, "page-d", 700)
        #expect(silent.pair == Pair(sectionID: "s1", postID: "a") && silent.adopted == nil)

        // A heading that names nothing, adopted (the width change re-landing
        // the row at the top) stands as nothing while it is on the page.
        let heading = follow(column(-430), "unfiled", 700)
        #expect(heading.pair == .nothingViewed && heading.adopted == "unfiled")
    }

    // MARK: - The place on the page (P-562-5)

    /// The ordinal counts notes in the COLUMN's order — here chapter two is
    /// first on the page although its note is the book's last member.
    @Test func theNotesPlaceIsItsPlaceOnThePage() {
        let rows = BookOutlineRows.rows(grouped: [
            (section("s2", "chapter two"), [entry("c")]),
            (section("s1", "chapter one"), [entry("a"), entry("b")]),
        ])
        #expect(BookOutlineViewed.noteOrdinal(of: "c", in: rows) == 1)
        #expect(BookOutlineViewed.noteOrdinal(of: "b", in: rows) == 3)
        #expect(BookOutlineViewed.noteOrdinal(of: "zz", in: rows) == nil)
    }

    // MARK: - The pinned line's position words

    @Test func thePositionWordsSayTheNotesPlaceAndItsChapter() {
        let say: (Pair, Bool, Bool, Bool) -> String = { pair, chaptered, filtered, truncated in
            BookOutlineViewed.positionLine(
                pair: pair, rows: self.chaptered, chaptered: chaptered,
                filtered: filtered, truncated: truncated)
        }
        #expect(say(Pair(sectionID: "s2", postID: "c"), true, false, false)
                == "note 3 of 4 \u{B7} chapter two")
        #expect(say(Pair(sectionID: "s2"), true, false, false) == "chapter two",
                "a chapter heading at the top: the chapter alone")
        #expect(say(Pair(postID: "d"), true, false, false) == "note 4 of 4 \u{B7} unfiled",
                "the chapterless group's one word, in a chaptered book")
        #expect(say(Pair(sectionID: "s2", postID: "c"), false, false, false) == "note 3 of 4",
                "P-562-4: no chapter words where chapters do not govern")
        #expect(say(Pair(sectionID: "s2", postID: "c"), true, true, false) == "chapter two",
                "under the in-book filter the place is unknown and omitted (W-3's rule)")
        #expect(say(Pair(sectionID: "s2", postID: "c"), true, false, true)
                == "note 3 of 4+ \u{B7} chapter two", "a windowed book's count is a floor")
        #expect(say(.nothingViewed, true, false, false) == "", "nothing viewed, nothing said")
        #expect(BookPanelCopy.unfiled == "unfiled")
    }

    /// The one wording brain's second reader (`whereLine`'s pieces): the
    /// note's place first, then the chapter.
    @Test func theViewedLineIsTheWhereLinesPiecesInThePinsOrder() {
        #expect(NoteBoxCopy.viewedLine(chapter: "chapter 2", index: 5, total: 12)
                == "note 5 of 12 \u{B7} chapter 2")
        #expect(NoteBoxCopy.viewedLine(chapter: nil, index: 5, total: 12) == "note 5 of 12")
        #expect(NoteBoxCopy.viewedLine(chapter: "   ", index: 5, total: 12) == "note 5 of 12",
                "a blank chapter is omitted, as whereLine omits it")
        #expect(NoteBoxCopy.viewedLine(chapter: "chapter 2", index: 0, total: 12) == "chapter 2",
                "an unknown place is omitted")
        #expect(NoteBoxCopy.viewedLine(chapter: nil, index: 5, total: 300, totalIsAtLeast: true)
                == "note 5 of 300+")
        #expect(NoteBoxCopy.viewedLine(chapter: nil, index: 0, total: 0) == "")
        // The same pieces, said by the box: unchanged.
        #expect(NoteBoxCopy.whereLine(chapter: "chapter 2", index: 5, total: 12, block: nil)
                == "chapter 2 \u{B7} 5 of 12 in this book")
    }

    // MARK: - The navigator's one mark table

    /// Outline marks the VIEWED note — the caret's (focused) note is ignored,
    /// her ruling. Every other mode is the shipped rule: focus, and in the
    /// spread both pages.
    @MainActor
    @Test func theNavigatorMarksTheViewedNoteInOutlineAndTheFocusedOneElsewhere() {
        let mark: (BookStructureModel.ViewMode, String) -> Bool = { mode, id in
            BookNavigatorMark.note(
                mode: mode, postID: id, focusedPostID: "typing",
                viewedPostID: "viewing", spreadPostIDs: ["left", "right"])
        }
        #expect(mark(.outline, "viewing"))
        #expect(!mark(.outline, "typing"), "Outline ignores the caret's note")
        #expect(!mark(.outline, "left"))
        #expect(mark(.spread, "typing") && mark(.spread, "left") && mark(.spread, "right"))
        #expect(!mark(.spread, "viewing"))
        #expect(mark(.read, "typing") && !mark(.read, "viewing"))
        #expect(mark(.index, "typing") && !mark(.index, "viewing"))
        #expect(!BookNavigatorMark.note(
            mode: .outline, postID: "a", focusedPostID: "a", viewedPostID: nil, spreadPostIDs: []),
                "nothing viewed: no note is marked in Outline, whatever is focused")
    }

    @MainActor
    @Test func onlyOutlineWashesTheViewedChapter() {
        #expect(BookNavigatorMark.chapter(mode: .outline, sectionID: "s2", viewedSectionID: "s2"))
        #expect(!BookNavigatorMark.chapter(mode: .outline, sectionID: "s1", viewedSectionID: "s2"))
        #expect(!BookNavigatorMark.chapter(mode: .outline, sectionID: "s1", viewedSectionID: nil))
        for mode: BookStructureModel.ViewMode in [.spread, .read, .index] {
            #expect(!BookNavigatorMark.chapter(mode: mode, sectionID: "s2", viewedSectionID: "s2"),
                    "P-562-2: the follower runs in Outline only")
        }
    }
}
