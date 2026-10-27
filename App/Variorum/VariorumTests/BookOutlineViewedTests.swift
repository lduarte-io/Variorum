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
//  Ladder round 1 (the record's §LIVE STATUS "r1 fixes"): the heading names
//  the note it introduces (P-562-7); at the bottom of the book the viewed
//  pair clamps to the last note (R-562-D, the r3 fix — superseding R-562-B's
//  probe that slid to the page's foot); the follower's adopt/release
//  decision is one value, driven here in every order SwiftUI might deliver
//  (finding 6, R-562-C, finding 4's guard); one note total for both halves
//  of the pinned line (finding 3); the viewed chapter's mark by token maths
//  (finding 8). The bug-class ones carry their red-on-old shape in the doc.
//
//  The geometry the tables stand in for is `BookView.outlineSpace`: a row's
//  top in the scroll's VISIBLE space, `0` the viewport's top edge, negative
//  above it.
//

import AppKit
import CoreGraphics
import Foundation
import SwiftUI
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

    /// **P-562-7 (ladder round 1, walk finding 11): a chapter heading at the
    /// top names the note it INTRODUCES** — steady across the heading, so the
    /// pin's "note N of M" never blinks out between chapters, and the
    /// chapter and the note never contradict. Red on the batch's rule, which
    /// named the chapter alone until the note's own top crossed the probe.
    @Test func aChapterHeadingAtTheTopNamesTheNoteItIntroduces() {
        var tops: [String: CGFloat] = [
            "chapter-s1": -600, "page-a": -550, "page-b": -440, "chapter-s2": 0,
            "page-c": 50, "unfiled": 17_000, "page-d": 17_050,
        ]
        let c = Pair(sectionID: "s2", postID: "c")
        #expect(BookOutlineViewed.pair(rows: chaptered, tops: tops) == c,
                "the heading landed at the top: its chapter, and the note it introduces")
        tops["chapter-s2"] = -40
        tops["page-c"] = 11
        #expect(BookOutlineViewed.pair(rows: chaptered, tops: tops) == c,
                "the heading scrolled past, the note's top still a point below the probe: the same pair")
        tops["chapter-s2"] = -45
        tops["page-c"] = 6
        #expect(BookOutlineViewed.pair(rows: chaptered, tops: tops) == c,
                "the note's own top within the probe: still the same pair — nothing blinked")
    }

    /// P-562-7's edges: an EMPTY chapter's heading introduces no note, so it
    /// names its chapter alone; the unfiled heading and a tag-path heading
    /// introduce their first notes (no chapter).
    @Test func aHeadingWithNoNoteUnderItNamesItsChapterAlone() {
        let rows = BookOutlineRows.rows(grouped: [
            (section("s1", "chapter one"), [entry("a")]),
            (section("s2", "chapter two"), []),
            (section("s3", "chapter three"), [entry("b")]),
        ])
        #expect(rows.map(\.id) == ["chapter-s1", "page-a", "chapter-s2", "chapter-s3", "page-b"])
        #expect(BookOutlineViewed.named(at: 2, in: rows) == Pair(sectionID: "s2"),
                "the empty chapter: its chapter alone")
        #expect(BookOutlineViewed.named(at: 3, in: rows) == Pair(sectionID: "s3", postID: "b"))
        #expect(BookOutlineViewed.named(at: 0, in: rows) == Pair(sectionID: "s1", postID: "a"))
        #expect(BookOutlineViewed.named(at: 1, in: rows) == Pair(sectionID: "s1", postID: "a"))
        #expect(BookOutlineViewed.named(at: 9, in: rows) == .nothingViewed, "no such row")
        let flat = BookOutlineRows.rows(flat: [entry("x", path: "life"), entry("y", path: "work")])
        #expect(BookOutlineViewed.named(at: 0, in: flat) == Pair(postID: "x"),
                "a tag-path heading introduces its first note, naming no chapter")
        #expect(BookOutlineViewed.named(at: 2, in: flat) == Pair(postID: "y"))
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

    /// Unfiled: a note under the unfiled heading names no chapter, and the
    /// heading itself introduces its first note (P-562-7) — the chapterless
    /// group is never a blink between notes.
    @Test func unfiledNotesNameNoChapterAndTheUnfiledHeadingNamesItsFirstNote() {
        var tops: [String: CGFloat] = [
            "chapter-s1": -18_000, "page-a": -17_950, "page-b": -17_840,
            "chapter-s2": -17_730, "page-c": -17_680, "unfiled": -60, "page-d": -10,
        ]
        #expect(BookOutlineViewed.pair(rows: chaptered, tops: tops) == Pair(postID: "d"))
        tops["unfiled"] = 0
        tops["page-d"] = 50
        #expect(BookOutlineViewed.pair(rows: chaptered, tops: tops) == Pair(postID: "d"),
                "the unfiled heading at the top: no chapter, the note it introduces")
    }

    /// A book with no notes has no rows, and nothing is viewed.
    @Test func anEmptyBookViewsNothing() {
        #expect(BookOutlineViewed.pair(rows: [], tops: [:]) == .nothingViewed)
        #expect(BookOutlineViewed.pair(rows: [], tops: ["page-x": -100]) == .nothingViewed,
                "a stale top for a row the column no longer has is never read")
        #expect(BookOutlineViewed.pair(rows: [], tops: [:], probe: 5_000) == .nothingViewed,
                "whatever the probe")
    }

    /// A flat book (tag-path headings): notes name no chapter; a heading
    /// introduces its first note.
    @Test func aFlatBookNamesNotesAndNoChapters() {
        let rows = BookOutlineRows.rows(flat: [
            entry("a", path: "life"), entry("b", path: "life"), entry("c", path: "work"),
        ])
        #expect(rows.map(\.id) == ["path-0", "page-a", "page-b", "path-2", "page-c"])
        var tops: [String: CGFloat] = [
            "path-0": -500, "page-a": -450, "page-b": -200, "path-2": 300, "page-c": 350,
        ]
        #expect(BookOutlineViewed.pair(rows: rows, tops: tops) == Pair(postID: "b"))
        tops["path-2"] = 0
        tops["page-c"] = 50
        #expect(BookOutlineViewed.pair(rows: rows, tops: tops) == Pair(postID: "c"),
                "the work heading at the top introduces its note")
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
        #expect(BookOutlineViewed.pair(rows: rows, tops: ["page-b": -300]) == Pair(postID: "b"),
                "only b reported, at the top: b")
        #expect(BookOutlineViewed.pair(rows: rows, tops: [:]) == .nothingViewed,
                "nothing reported: nothing viewed")
    }

    /// **Monotonic, over THE SHIPPED RULE** (ladder round 1, finding 5: the
    /// batch's twin `viewedIndex` — never called by production — carried
    /// this pin, so an edit to `pair`'s comparison could not fail it; the
    /// twin is deleted and the table runs `pair` itself): as the probe moves
    /// down the page, the viewed note never moves up the column. A row with
    /// no reported top is skipped at every probe.
    @Test func theRuleIsMonotonicInTheProbe() {
        let rows = BookOutlineRows.rows(flat: (0..<8).map { entry("n\($0)") })
        let tops: [String: CGFloat] = [
            "page-n0": -900, "page-n1": -400, "page-n3": -10, "page-n4": 3,
            "page-n5": 250, "page-n6": 251, "page-n7": 4_000,
        ]
        let place: (CGFloat) -> Int = { probe in
            BookOutlineViewed.pair(rows: rows, tops: tops, probe: probe).postID
                .flatMap { BookOutlineViewed.noteOrdinal(of: $0, in: rows) } ?? 0
        }
        var previous = 0
        for probe in stride(from: CGFloat(-1_000), through: 5_000, by: 7) {
            let now = place(probe)
            #expect(now >= previous, "probe \(probe): note \(now) moved up from \(previous)")
            previous = now
        }
        #expect(place(BookOutlineViewed.probe) == 5, "at the edge probe: n4 (its top 3 pt down)")
        #expect(place(5_000) == 8, "a probe past every row: the last")
        #expect(place(-1_000) == 0, "a probe above every row: nothing")
        #expect(place(-400) == 2 && place(-401) == 1, "exactly at a row's top: that row (≤)")
    }

    // MARK: - R-562-D — at the bottom the viewed pair clamps to the last note

    /// **The end band's table** (R-562-D): the page is AT THE BOTTOM while
    /// its offset sits within 8 pt of its maximum — R-562-C's release
    /// threshold, the named constant reused, inclusive as the release is —
    /// and an overscroll past the bottom is at it. A page that cannot scroll
    /// further than the band never is (PROVISIONAL: it sits at its maximum at
    /// rest, and at rest nothing is viewed), nor is one whose scroll has not
    /// reported.
    @Test func theBottomOfTheBookIsTheLastEightPointsOfItsScroll() {
        typealias Scroll = BookOutlineViewed.Scroll
        #expect(BookOutlineFollower.offsetRelease == 8, "the band is the release's named threshold, reused")
        let bottom: (CGFloat, CGFloat) -> Bool = { offset, travel in
            BookOutlineViewed.isAtTheBottom(Scroll(viewport: 600, offset: offset, travel: travel))
        }
        #expect(!bottom(0, 3_000), "at rest")
        #expect(!bottom(2_000, 3_000), "a page and more to go")
        #expect(!bottom(2_991, 3_000), "nine points up: one point out of the band")
        #expect(bottom(2_992, 3_000), "eight points up: the band's edge, inside it")
        #expect(bottom(2_999.5, 3_000))
        #expect(bottom(3_000, 3_000), "at the bottom")
        #expect(bottom(3_050, 3_000), "an overscroll past the bottom")
        #expect(!bottom(-40, 3_000), "an overscroll at the top")
        #expect(!BookOutlineViewed.isAtTheBottom(Scroll()), "a page whose scroll has not reported")
        #expect(!bottom(0, 0), "a column that fits its page: never — at rest nothing is viewed")
        #expect(!bottom(0, 8) && !bottom(8, 8), "a column that moves no further than the band: never")
        #expect(!bottom(0, 9), "nine points of scroll, at rest: out of the band")
        #expect(bottom(1, 9), "one point down: within eight of its nine")
    }

    /// A chaptered book's column for the bottom's table: four chapters of
    /// three 100-pt notes (n0…n11), each chapter under a 40-pt heading, 10 pt
    /// between rows, under a 120-pt title block, with a 120-pt foot after the
    /// last note — on a 600-pt page (content 1 750, travel 1 150). `tops`
    /// gives every row's top in the page's visible space at an offset.
    private var bottomBook: (
        rows: [BookOutlineRows.Row], tops: (CGFloat) -> [String: CGFloat], travel: CGFloat
    ) {
        let names = ["chapter one", "chapter two", "chapter three", "chapter four"]
        let groups: [(section: ReadingSection?, entries: [Queries.ReadingEntry])] = (0..<4).map { c in
            (section: section("s\(c + 1)", names[c]),
             entries: (0..<3).map { entry("n\(c * 3 + $0)") })
        }
        let rows = BookOutlineRows.rows(grouped: groups)
        var position: [String: CGFloat] = [:]
        var y: CGFloat = 120
        for row in rows {
            position[row.id] = y
            if case .note = row { y += 110 } else { y += 50 }
        }
        let content = y - 10 + 120   // the last row's bottom, then the foot
        let positions = position
        return (rows, { offset in positions.mapValues { $0 - offset } }, content - 600)
    }

    /// **R-562-D, over a chaptered column — the clamp's contract** (ladder
    /// round 1's finding 1, MAJOR; round 2's N1; walk 3's reading-speed
    /// verdict on the slide): scrolling down a book the viewed note is the
    /// TOP-EDGE rule's — the row that owns the page's top, never a note ahead
    /// of it — and never moves up; AT THE BOTTOM (within the 8-pt end band of
    /// the maximum offset) it is the LAST note and its chapter, and the
    /// pinned line says so; nine points up, one point out of the band, the
    /// top-edge answer again.
    ///
    /// RED ON OLD, both ways (the record's recipe H): on the SLIDE tree
    /// (R-562-B, `052d39c11`; recipe H restores it inside `rule`) nine points
    /// up names a note near the page's foot, not the top row — the ruling's
    /// own differentiator — and so does every offset over the last viewport;
    /// with the clamp OFF (H′ — the batch's edge rule everywhere, finding 1's
    /// MAJOR) the bottom names the top row, as the premise line says of the
    /// edge rule. The ruling's stated cost is documented too: the last
    /// screenful's MIDDLE notes are never viewed by pure scrolling (a click
    /// reaches them — R-562-A's adoption); the slide viewed them, so that
    /// line is red on the slide tree as well.
    @Test func atTheBottomTheLastNoteIsViewedAndNinePointsUpTheTopEdgeAnswers() {
        typealias Scroll = BookOutlineViewed.Scroll
        let book = bottomBook
        let rows = book.rows, travel = book.travel
        // What the follower shows with no landing's target standing.
        let viewed: (CGFloat) -> Pair = { offset in
            BookOutlineViewed.follow(
                rows: rows,
                page: BookOutlineViewed.Page(
                    tops: book.tops(offset),
                    scroll: Scroll(viewport: 600, offset: offset, travel: travel)),
                adopted: nil
            ).pair
        }
        let edge: (CGFloat) -> Pair = { BookOutlineViewed.pair(rows: rows, tops: book.tops($0)) }
        let place: (Pair) -> Int = { pair in
            pair.postID.flatMap { BookOutlineViewed.noteOrdinal(of: $0, in: rows) } ?? 0
        }
        let pin: (Pair) -> String = { pair in
            BookOutlineViewed.pinLine(
                gathering: false, chapters: 4, archived: 0,
                total: BookOutlineViewed.NoteTotal(count: 12), pair: pair, rows: rows,
                chaptered: true, filtered: false)
        }
        let last = Pair(sectionID: "s4", postID: "n11")
        let topRow = Pair(sectionID: "s3", postID: "n8")

        // The premises: a last screenful of notes whose tops never reach the
        // probe — so the edge rule at the bottom names the row at the top
        // (finding 1's MAJOR, the batch tree's answer there).
        #expect(travel == 1_150, "the column's arithmetic")
        let lastScreenful: [Int] = rows.compactMap { row in
            guard case .note(let entry) = row, let top = book.tops(travel)[row.id],
                  top > BookOutlineViewed.probe else { return nil }
            return BookOutlineViewed.noteOrdinal(of: entry.postID, in: rows)
        }
        #expect(lastScreenful == [10, 11, 12], "the premise: the last screenful (\(lastScreenful))")
        #expect(edge(travel) == topRow, "the premise: the edge rule at the bottom names the top row")

        // AT THE BOTTOM: the last note and its chapter, and the pin's words.
        #expect(viewed(travel) == last, "at the bottom: the LAST note — \(viewed(travel))")
        #expect(viewed(travel - 8) == last, "eight points up: still in the band — the last note")
        #expect(viewed(travel + 30) == last, "an overscroll past the bottom: the last note")
        #expect(pin(viewed(travel))
                == "book \u{B7} 4 chapters \u{B7} 12 notes \u{B7} note 12 of 12 \u{B7} chapter four",
                "the pin says the last note and its chapter")

        // NINE POINTS UP — one point out of the band: the top edge answers.
        #expect(viewed(travel - 9) == edge(travel - 9),
                "nine points up: the top-edge answer — \(viewed(travel - 9))")
        #expect(viewed(travel - 9) == topRow, "n8, its top 9 pt down the page — never a note ahead of it")
        #expect(pin(viewed(travel - 9))
                == "book \u{B7} 4 chapters \u{B7} 12 notes \u{B7} note 9 of 12 \u{B7} chapter three")
        // Everywhere above the band: exactly the top-edge rule — the pace
        // never changes and nothing leads the page.
        for offset in stride(from: CGFloat(0), to: travel - 8, by: 5) {
            #expect(viewed(offset) == edge(offset), "offset \(offset): the top-edge rule")
        }

        // Never backwards on the way down; at rest nothing is viewed.
        var previous = 0
        var seen = Set<Int>()
        for offset in stride(from: CGFloat(0), through: travel, by: 5) {
            let now = place(viewed(offset))
            #expect(now >= previous, "offset \(offset): note \(now) moved up from \(previous)")
            previous = now
            seen.insert(now)
        }
        #expect(place(viewed(0)) == 0, "at rest: the title block holds the page")
        #expect(seen.contains(12), "the last note, at the bottom")
        // The stated cost (PROVISIONAL, bundled): the last screenful's middle
        // notes are not viewed by pure scrolling — a click reaches them.
        #expect(!seen.contains(10) && !seen.contains(11),
                "the middle of the last screenful is a click's, not a scroll's: \(seen.sorted())")

        // The clamp's own edges: the last note's row not yet reported — the
        // edge rule (never guessed); a column with no note — the edge rule.
        let atBottom = Scroll(viewport: 600, offset: travel, travel: travel)
        var unreported = book.tops(travel)
        unreported["page-n11"] = nil
        #expect(BookOutlineViewed.rule(rows: rows, tops: unreported, scroll: atBottom) == topRow,
                "the last note never reported: the edge rule")
        let noNotes = BookOutlineRows.rows(grouped: [(section: section("s1"), entries: [])])
        #expect(BookOutlineViewed.rule(rows: noNotes, tops: ["chapter-s1": -20], scroll: atBottom)
                == Pair(sectionID: "s1"), "no note to clamp to: the edge rule")
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
        #expect(adopt("chapter-s2") == Pair(sectionID: "s2", postID: "c"),
                "a chapter heading: its chapter and the note it introduces (P-562-7)")
        #expect(adopt("page-d") == Pair(postID: "d"), "a note under the unfiled heading names no chapter")
        #expect(adopt("unfiled") == Pair(postID: "d"),
                "the unfiled heading introduces its first note — what the rule says of it at the top")
        #expect(adopt("page-zz") == nil, "a row the column does not have: nothing to adopt")
        // The same answer the rule gives once the landing has put the target
        // at the top with the whole column reporting.
        let landed: [String: CGFloat] = [
            "chapter-s1": -320, "page-a": -270, "page-b": -160, "chapter-s2": -50,
            "page-c": 0, "unfiled": 8_700, "page-d": 8_750,
        ]
        #expect(adopt("page-c") == BookOutlineViewed.pair(rows: chaptered, tops: landed))
        let flat = BookOutlineRows.rows(flat: [entry("a", path: "life"), entry("b", path: "life")])
        #expect(BookOutlineViewed.adoptedPair(anchor: "path-0", rows: flat) == Pair(postID: "a"),
                "a tag-path heading introduces its first note")
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
    /// moment a derivation finds it off the page or out of the column. (The
    /// pages here carry no scroll — the top-edge rule, never the clamp; the
    /// clamp at the end of the book has its own tables above.)
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
                rows: self.chaptered,
                page: BookOutlineViewed.Page(
                    tops: tops, heights: heights,
                    scroll: BookOutlineViewed.Scroll(viewport: viewport)),
                adopted: adopted)
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
        #expect(below.pair == Pair(sectionID: "s2", postID: "c") && below.adopted == nil,
                "below the foot: the rule — chapter two's heading owns the top, naming its note")
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

        // A heading adopted (the width change re-landing the row at the top)
        // stands as what it names — the note it introduces — while it is on
        // the page.
        let heading = follow(column(-430), "unfiled", 700)
        #expect(heading.pair == Pair(postID: "d") && heading.adopted == "unfiled")
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
                pair: pair, rows: self.chaptered, chaptered: chaptered, filtered: filtered,
                total: BookOutlineViewed.NoteTotal(count: 4, isAtLeast: truncated))
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

    // MARK: - Finding 3 — one honest total for the whole pinned line

    /// **Past the book's window the two halves of the pinned line say ONE
    /// total** (ladder round 1, finding 3): a book over 300 notes is read
    /// through a 300-note window (`BookViewModel.entryWindow`; "show more ›"
    /// widens it), so the count is a floor — "300+ notes" — and "note 3 of
    /// 300+" beside it. RED on the batch's composition, which handed the
    /// count line the window's bare count ("300 notes") beside the
    /// position's floor ("of 300+"). Red-on-old by behavioral revert: make
    /// `pinLine` hand `metaLine` `notesAreAtLeast: false`.
    @Test func thePinnedLineSaysOneTotalForBothHalves() {
        let line: (BookOutlineViewed.NoteTotal, Pair) -> String = { total, pair in
            BookOutlineViewed.pinLine(
                gathering: false, chapters: 2, archived: 0, total: total,
                pair: pair, rows: self.chaptered, chaptered: true, filtered: false)
        }
        let windowed = BookOutlineViewed.NoteTotal(count: 300, isAtLeast: true)
        let c = Pair(sectionID: "s2", postID: "c")
        #expect(line(windowed, c)
                == "book \u{B7} 2 chapters \u{B7} 300+ notes \u{B7} note 3 of 300+ \u{B7} chapter two",
                "the count line and the position say the same floor")
        #expect(line(windowed, .nothingViewed) == "book \u{B7} 2 chapters \u{B7} 300+ notes",
                "at rest: the counts alone, the floor said")
        #expect(line(BookOutlineViewed.NoteTotal(count: 4), c)
                == "book \u{B7} 2 chapters \u{B7} 4 notes \u{B7} note 3 of 4 \u{B7} chapter two",
                "a book inside its window: the exact count, twice")
        // The count line's own words (its other callers pass no floor and
        // read exactly as before — `VocabularySweepTests`).
        #expect(BookViewCopy.metaLine(
            gathering: false, chapters: 0, notes: 600, notesAreAtLeast: true, archived: 2)
                == "book \u{B7} 600+ notes \u{B7} " + ArchivedLineCopy.line(count: 2))
        #expect(BookViewCopy.metaLine(gathering: false, chapters: 0, notes: 1, archived: 0)
                == "book \u{B7} 1 note")
    }

    // MARK: - Finding 6 (partial) — the follower's adopt/release, one value

    /// A column of six 100-pt notes mid-scroll (the page 600 pt tall, far
    /// from the book's end): note `i`'s top is `t + 110·i`.
    private var followerRows: [BookOutlineRows.Row] {
        BookOutlineRows.rows(flat: (0..<6).map { entry("f\($0)") })
    }

    private func followerPage(top t: CGFloat, offset: CGFloat) -> BookOutlineViewed.Page {
        var tops: [String: CGFloat] = [:]
        var heights: [String: CGFloat] = [:]
        for i in 0..<6 {
            tops["page-f\(i)"] = t + 110 * CGFloat(i)
            heights["page-f\(i)"] = 100
        }
        return BookOutlineViewed.Page(
            tops: tops, heights: heights,
            scroll: BookOutlineViewed.Scroll(viewport: 600, offset: offset, travel: 10_000))
    }

    /// **The navigator's click in either order SwiftUI may deliver it**
    /// (finding 4's mechanism, headless): the click is `focus` — which
    /// unfolds the note, an EXPANSION-axis change — and `requestReveal` in
    /// one act. Whichever change arrives first, the clicked target is what
    /// the follower says at the landing's end. RED under the behavioral
    /// revert of `axisChanged`'s pending guard (order A lets the click's own
    /// expansion release its travelling adoption, and the end says the rule).
    @Test func theClicksOwnExpansionNeverReleasesItsTargetInEitherOrder() {
        let target = "page-f3"
        let targetPair = Pair(postID: "f3")
        // The landing has ended with f3 on the page at 320 pt (the rule would
        // name f0, at the top).
        let landed = followerPage(top: -10, offset: 2_000)
        #expect(BookOutlineViewed.pair(rows: followerRows, tops: landed.tops) == Pair(postID: "f0"),
                "the premise: the rule names another row")

        // Order A: the reveal's landing starts first, then the expansion.
        var a = BookOutlineFollower()
        #expect(a.landingStarted(anchor: target, rows: followerRows) == targetPair, "the click says f3")
        a.axisChanged(landingPending: true)
        #expect(a.look(rows: followerRows, page: landed, landingPending: true) == nil,
                "frozen while the landing travels")
        #expect(a.look(rows: followerRows, page: landed, landingPending: false) == targetPair,
                "the landing's end: the target — the click's own expansion did not release it")

        // Order B: the expansion first (no landing pending yet), then the reveal.
        var b = BookOutlineFollower()
        b.axisChanged(landingPending: false)
        #expect(b.landingStarted(anchor: target, rows: followerRows) == targetPair)
        #expect(b.look(rows: followerRows, page: landed, landingPending: false) == targetPair)

        // A STANDING adoption does let go on an axis change (R-562-A).
        var c = BookOutlineFollower()
        _ = c.landingStarted(anchor: target, rows: followerRows)
        _ = c.look(rows: followerRows, page: landed, landingPending: false)
        c.axisChanged(landingPending: false)
        #expect(c.adopted == nil)
        #expect(c.look(rows: followerRows, page: landed, landingPending: false) == Pair(postID: "f0"),
                "after the landing, an expansion returns the follower to the rule")
    }

    /// Her hand on the page lets go FIRST — so a landing her scroll ends
    /// delivers the rule's pair, not the target's — and the Outline leaving
    /// lets go too.
    @Test func herScrollPhaseAndTheOutlineLeavingLetTheTargetGo() {
        let landed = followerPage(top: -10, offset: 2_000)
        var f = BookOutlineFollower()
        _ = f.landingStarted(anchor: "page-f3", rows: followerRows)
        f.userScrolled()   // her phase, mid-landing: cleared before `userTookOver`
        #expect(f.look(rows: followerRows, page: landed, landingPending: false) == Pair(postID: "f0"),
                "the landing she ended delivers the rule")
        var g = BookOutlineFollower()
        _ = g.landingStarted(anchor: "page-f3", rows: followerRows)
        _ = g.look(rows: followerRows, page: landed, landingPending: false)
        g.forget()
        #expect(g.adopted == nil && g.settledOffset == nil)
        var h = BookOutlineFollower()
        #expect(h.landingStarted(anchor: "page-zz", rows: followerRows) == nil,
                "a target the column has no row for: nothing adopted")
        #expect(h.adopted == nil)
    }

    /// **R-562-C — the page's own offset releases the hold** (ladder round 1,
    /// finding 2): the key is where the page stood at the first look after
    /// the landing (never mid-travel); settle wobble up to 8 pt keeps the
    /// target, and anything more lets it go — whatever the input (a
    /// phase-less wheel, keyboard paging, a scroller drag, a programmatic
    /// scroll), with the target still on the page. RED under the behavioral
    /// revert (`offsetRelease` = `.infinity`): the target stood while on
    /// the page, so a scroll that kept it there kept the stale pair.
    @Test func thePageMovingMoreThanEightPointsLetsTheTargetGo() {
        #expect(BookOutlineFollower.offsetRelease == 8, "the named threshold")
        let target = Pair(postID: "f3")
        var f = BookOutlineFollower()
        _ = f.landingStarted(anchor: "page-f3", rows: followerRows)
        // Mid-travel looks are frozen and take no key.
        #expect(f.look(rows: followerRows, page: followerPage(top: 500, offset: 400),
                       landingPending: true) == nil)
        #expect(f.settledOffset == nil, "no key while the landing travels")
        // The landing's end: the key.
        #expect(f.look(rows: followerRows, page: followerPage(top: -10, offset: 2_000),
                       landingPending: false) == target)
        #expect(f.settledOffset == 2_000)
        // Wobble within 8 pt either way: still the target.
        for (top, offset) in [(-14.0, 2_004.0), (-2.0, 1_992.0), (-18.0, 2_008.0)] as [(CGFloat, CGFloat)] {
            #expect(f.look(rows: followerRows, page: followerPage(top: top, offset: offset),
                           landingPending: false) == target,
                    "offset \(offset): within the release — the target stands")
        }
        // 8.5 pt up: let go — the rule, with f3 still on the page.
        let moved = followerPage(top: -1.5, offset: 1_991.5)
        #expect(BookOutlineViewed.isOnScreen(
            top: moved.tops["page-f3"], height: 100, viewport: 600), "the premise: f3 is on the page")
        #expect(f.look(rows: followerRows, page: moved, landingPending: false) == Pair(postID: "f0"),
                "past the release: the rule")
        #expect(f.adopted == nil && f.settledOffset == nil)
        // Back where the landing left it: the adoption does not come back.
        #expect(f.look(rows: followerRows, page: followerPage(top: -10, offset: 2_000),
                       landingPending: false) == Pair(postID: "f0"))
        // A NEW landing re-adopts and takes a fresh key at its own end.
        _ = f.landingStarted(anchor: "page-f5", rows: followerRows)
        #expect(f.settledOffset == nil)
        #expect(f.look(rows: followerRows, page: followerPage(top: -230, offset: 3_000),
                       landingPending: false) == Pair(postID: "f5"))
        #expect(f.settledOffset == 3_000)
    }

    // MARK: - Finding 8 — the viewed chapter's mark reads, by token maths

    /// The colour's sRGB components (the token layer's colours are static
    /// sRGB; opacity rides in alpha).
    @MainActor
    private func components(_ colour: Color) -> (r: Double, g: Double, b: Double, a: Double) {
        let ns = NSColor(colour).usingColorSpace(.sRGB) ?? .black
        return (ns.redComponent, ns.greenComponent, ns.blueComponent, ns.alphaComponent)
    }

    /// `colour` composited over an opaque `backdrop`, as one opaque hex value
    /// for `PaletteDerivation.contrast` (the SAME maths the palette layer
    /// pins its own floors with).
    @MainActor
    private func composite(_ colour: Color, over backdrop: Color) -> UInt32 {
        let f = components(colour), b = components(backdrop)
        func byte(_ fg: Double, _ bg: Double) -> UInt32 {
            UInt32((min(max(f.a * fg + (1 - f.a) * bg, 0), 1) * 255).rounded())
        }
        return (byte(f.r, b.r) << 16) | (byte(f.g, b.g) << 8) | byte(f.b, b.b)
    }

    /// **Ladder round 1, finding 8 (walk 2): the viewed chapter's mark must
    /// READ at normal viewing in both voices and both appearances.** The
    /// fill (the accent at `viewedChapterFillStrength`) against the
    /// navigator's room: at least 1.3:1 in Terminal and Study, light and
    /// dark — and at most 1.6:1, a quiet tile, never a band — with the name
    /// in ink at least 4.5:1 on it (the palette layer's own selected-row
    /// floor). Under every palette, at least 1.25:1 and the same ink floor.
    ///
    /// RED on the batch's mark (the wash at 0.55): Study dark 1.07:1 — the
    /// walk's measured RGB (10,12,14) on black, *"does not read as a
    /// highlight"* — and Terminal light 1.03:1; the last lines say so.
    @MainActor
    @Test func theViewedChaptersMarkReadsInBothVoicesAndBothAppearances() {
        for voice in [ThemeVoice.terminal, .study] {
            for dark in [false, true] {
                let tokens = VoiceTokens.resolve(voice: voice, dark: dark)
                let fill = BookNavigatorLayout.viewedChapterFill(tokens)
                #expect(abs(components(fill).a - BookNavigatorLayout.viewedChapterFillStrength) < 0.01,
                        "\(voice) dark=\(dark): the fill is the accent at its named strength")
                let room = composite(tokens.room, over: tokens.room)
                let tile = composite(fill, over: tokens.room)
                let reads = PaletteDerivation.contrast(tile, room)
                #expect(reads >= 1.3, "\(voice) dark=\(dark): the fill reads against the room (\(reads))")
                #expect(reads <= 1.6, "\(voice) dark=\(dark): and stays a quiet tile (\(reads))")
                let ink = composite(BookNavigatorLayout.chapterNameInk(tokens, viewed: true), over: tokens.room)
                let legible = PaletteDerivation.contrast(ink, tile)
                #expect(legible >= 4.5, "\(voice) dark=\(dark): the name in ink on the fill (\(legible))")
                #expect(BookNavigatorLayout.chapterNameInk(tokens, viewed: false) == tokens.accent,
                        "an unviewed chapter's name keeps the accent")
            }
        }
        for palette in ThemePalette.allCases where palette != .default && palette != .custom {
            for voice in [ThemeVoice.terminal, .study] {
                for dark in [false, true] {
                    let tokens = VoiceTokens.resolve(voice: voice, palette: palette, tint: PaletteTint.none, dark: dark)
                    let room = composite(tokens.room, over: tokens.room)
                    let tile = composite(BookNavigatorLayout.viewedChapterFill(tokens), over: tokens.room)
                    let reads = PaletteDerivation.contrast(tile, room)
                    #expect(reads >= 1.25, "\(palette) \(voice) dark=\(dark): the fill reads (\(reads))")
                    let ink = composite(BookNavigatorLayout.chapterNameInk(tokens, viewed: true), over: tokens.room)
                    #expect(PaletteDerivation.contrast(ink, tile) >= 4.5,
                            "\(palette) \(voice) dark=\(dark): the name in ink on the fill")
                }
            }
        }
        // The batch's mark, for the record: the wash at 0.55 did not read.
        let studyDark = VoiceTokens.resolve(voice: .study, dark: true)
        let oldTile = composite(QuietFill.rest(studyDark), over: studyDark.room)
        #expect(PaletteDerivation.contrast(oldTile, composite(studyDark.room, over: studyDark.room)) < 1.1,
                "the retired mark in Study dark: under 1.1:1 — the walk's invisible tile")
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
    @Test func onlyOutlineMarksTheViewedChapter() {
        #expect(BookNavigatorMark.chapter(mode: .outline, sectionID: "s2", viewedSectionID: "s2"))
        #expect(!BookNavigatorMark.chapter(mode: .outline, sectionID: "s1", viewedSectionID: "s2"))
        #expect(!BookNavigatorMark.chapter(mode: .outline, sectionID: "s1", viewedSectionID: nil))
        for mode: BookStructureModel.ViewMode in [.spread, .read, .index] {
            #expect(!BookNavigatorMark.chapter(mode: mode, sectionID: "s2", viewedSectionID: "s2"),
                    "P-562-2: the follower runs in Outline only")
        }
    }
}
