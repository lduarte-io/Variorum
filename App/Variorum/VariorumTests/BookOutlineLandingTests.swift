//
//  BookOutlineLandingTests.swift
//  VariorumTests
//
//  The Act 10 correction round, batch B (the book) — the Outline's LANDING,
//  pinned where the user sees it. Ledger rows 44 (the hang + focus at the
//  last block), 9/12 (the scroll class), 47/7/23 (a navigator note-row
//  click that never revealed an off-screen note), 14 (chapters navigate).
//
//  What the oracle is: `BookOutlineGeometry.anchorTops` — where every
//  realized Outline anchor sits in the scroll's visible space, fed by the
//  SAME geometry reports the landing converges on. So "landed" here means
//  the chapter heading is at the top of the page, not that a scroll was
//  requested. A watchdog on a foreign thread ends the run if the main
//  thread stops yielding (the walk's livelock shape).
//
//  Red-on-old evidence lives in the batch record (plan file): the landing
//  pins go red under a behavioral revert of the mechanism (animated
//  scrollTo, no convergence hops, the anchor id inside the row), and the
//  caret pin goes red when the bare focus seeds no caret.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// A book with long stories (Sherlock-shaped: ~215 blocks, ~9.7k words
/// each) among short notes, so an expanded row is really tall. `chapters`
/// files the notes three to a chapter; `longAt` places the stories (row
/// 53's scenario needs several — three expanded and two collapsed).
@MainActor
private func withLandingBook<T>(
    posts: Int, longAt: Set<Int>, chapters: Bool,
    _ body: @MainActor (
        AppSession, AppDatabase, _ readingID: String,
        _ postIDs: [String], _ sectionIDs: [String]
    ) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    return try await withDependencies {
        $0.database = db
        $0.uuid = .incrementing
        $0.date = DateGenerator {
            let seconds = tick.withValue { value -> Int in
                defer { value += 1 }
                return value
            }
            return start.addingTimeInterval(Double(seconds))
        }
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 44))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        let reading = try session.operations.createReading(name: "the landing", kind: .book)
        var postIDs: [String] = []
        for p in 0..<posts {
            let post = try session.operations.createPost(title: "note \(p)")
            if longAt.contains(p) {
                for b in 0..<215 {
                    _ = try session.operations.newBlock(
                        in: post.id,
                        text: "Paragraph \(b) of the long story. We were seated at breakfast one "
                            + "morning, my wife and I, when the maid brought in a telegram. It was "
                            + "from Sherlock Holmes and ran in this way: have you a couple of days "
                            + "to spare, and will you come with me to the west of England?")
                }
            } else {
                // 13u2 UNIT A: a REALISTIC card preview. This read
                // "Prose of note \(p), short enough to card." — ONE line, which
                // no note in the shipped sample library or her own corpus
                // looks like, and the card's preview is capped at forty words.
                // The fixture's one-line cards made this suite blind to the
                // geometry the real book has (~three lines per card) and, once
                // UNIT A made a card's height honest from its first frame,
                // made it measure a card:heading ratio no book produces.
                _ = try session.operations.newBlock(
                    in: post.id,
                    text: "Prose of note \(p). It was a cold morning of the early spring, and we "
                        + "sat after breakfast on either side of a cheery fire in the old room at "
                        + "Baker Street, with a thick fog rolling down between the lines of "
                        + "dun-coloured houses opposite.")
            }
            try session.operations.addPostToReading(post.id, to: reading.id)
            postIDs.append(post.id)
        }
        var sectionIDs: [String] = []
        if chapters {
            for c in 0..<(posts / 3) {
                let section = try session.operations.createSection(
                    in: reading.id, name: "chapter \(c)")
                sectionIDs.append(section.id)
                for i in (c * 3)..<min(c * 3 + 3, posts) {
                    try session.operations.assignPostToSection(
                        postIDs[i], in: reading.id, section: section.id)
                }
            }
        }
        return try await body(session, db, reading.id, postIDs, sectionIDs)
    }
}

/// **The editor SHE IS WRITING IN — not "the first text view in the tree"
/// (13u2 UNIT A2).** These tests ask whether the focused story's editor has
/// its text and its height; the tree order is not part of that claim, and
/// relying on it made the suite depend on a race.
///
/// What was measured, so the change is not a test bent to pass: under this
/// harness — which drives SwiftUI by pumping the run loop by hand — the
/// Outline's editor representable can realize TWICE for the same post (two
/// `InlineEditorSurface.makeNSView` calls ~7 ms apart, two `EditorViewModel`s;
/// only the first receives a projection, exactly as `KnownIssuesAndTechDebt`'s
/// shadow-editor row describes). **In the REAL APP it does not:** the same
/// gesture on the dev-store Debug build against the Sherlock book logged
/// exactly ONE mount, on the pre-fix tree and on this one alike (the walk's
/// probe, recorded in the plan's UNIT A2 RECORD). So the shadow here is the
/// harness's, and "the first `EditorTextView`" is the wrong question: the
/// right one is which editor holds the note's text.
///
/// *(18k C2, 2026-09-25: the harness double itself is GONE since `f8610cb9`
/// (13u2b UNIT 1) — bisected, 2 of 2 each side; the shadow-editor row is
/// closed. The helper stays: asking for the editor that holds the note's text
/// is still the right question, whatever the mount count.)*
@MainActor
private func writingEditor(in view: NSView) -> EditorTextView? {
    var found: [EditorTextView] = []
    func walk(_ v: NSView) {
        if let editor = v as? EditorTextView { found.append(editor) }
        for sub in v.subviews { walk(sub) }
    }
    walk(view)
    // The one with text; ties (and the all-empty case) keep tree order, so a
    // single-editor tree behaves exactly as before.
    return found.max(by: { $0.string.count < $1.string.count })
}

/// The harness window the book is mounted in — named rather than repeated so
/// a premise about being BELOW THE FOLD is measured against the fold itself
/// (13u2b UNIT 1).
private let landingWindowWidth: CGFloat = 1200
private let landingWindowHeight: CGFloat = 760

/// The livelock guard: a foreign thread that ends the run when the main
/// thread stops yielding. `beat()` is called from every settle turn.
private final class MainThreadWatchdog: @unchecked Sendable {
    private let heartbeat = LockIsolated(Date())
    private let stopped = LockIsolated(false)
    let budget: TimeInterval

    init(budget: TimeInterval = 5) {
        self.budget = budget
        let thread = Thread { [heartbeat, stopped, budget] in
            while !stopped.value {
                Thread.sleep(forTimeInterval: 0.25)
                if Date().timeIntervalSince(heartbeat.value) > budget {
                    print("BookOutlineLandingTests: the main thread stopped yielding for "
                        + "\(budget)s — the walk's livelock; ending the run.")
                    exit(70)
                }
            }
        }
        thread.name = "book-outline-watchdog"
        thread.start()
    }

    func beat() { heartbeat.setValue(Date()) }
    func stop() { stopped.setValue(true) }
}

/// The flat row list (pure): one lazy item per heading and note, in the
/// grouping brain's order, each carrying its landing anchor.
@Suite("Outline's flat rows (Act 10 correction round, batch B)")
struct BookOutlineRowsTests {
    private func entry(_ id: String, path: String? = nil) -> Queries.ReadingEntry {
        Queries.ReadingEntry(postID: id, title: nil, entryDate: nil, sectionPath: path)
    }
    private func section(_ id: String) -> ReadingSection {
        ReadingSection(
            id: id, readingId: "book", name: id, position: id,
            createdAt: Date(timeIntervalSince1970: 0), updatedAt: Date(timeIntervalSince1970: 0))
    }

    @Test func chapteredRowsAreHeadingThenNotesWithUnfiledTrailing() {
        let rows = BookOutlineRows.rows(grouped: [
            (section("s1"), [entry("a"), entry("b")]),
            (section("s2"), []),
            (nil, [entry("c")]),
        ])
        #expect(rows.map(\.id) == ["chapter-s1", "page-a", "page-b", "chapter-s2", "unfiled", "page-c"])
    }

    /// Row 53: the column splits at every EXPANDED note — runs of small
    /// rows keep one lazy container each; an expanded note stands alone.
    @Test func segmentsSplitAtEveryExpandedNoteAndKeepRunsWhole() {
        let rows = BookOutlineRows.rows(grouped: [
            (section("s1"), [entry("a"), entry("b"), entry("c")]),
            (section("s2"), [entry("d")]),
        ])
        let segments = BookOutlineRows.segments(rows: rows, isExpanded: { ["b", "d"].contains($0) })
        #expect(segments.map(\.id) == ["run-chapter-s1", "page-b", "run-page-c", "page-d"],
                "a run up to the first expanded note, the note alone, a run through the next, the last alone")
        if case .run(let first) = segments[0] {
            #expect(first.map(\.id) == ["chapter-s1", "page-a"])
        } else { Issue.record("the first segment is a run") }
        if case .run(let third) = segments[2] {
            #expect(third.map(\.id) == ["page-c", "chapter-s2"], "the run reaches across the chapter heading")
        } else { Issue.record("the third segment is a run") }
        let none = BookOutlineRows.segments(rows: rows, isExpanded: { _ in false })
        #expect(none.count == 1, "nothing expanded ⇒ one lazy run")
        if case .run(let all) = none[0] { #expect(all.count == rows.count) }
    }

    /// Ladder R1-13: a short SENTENCE is a preview, not a stub — the
    /// numeral rule stays exact.
    @Test func aShortSentenceIsAPreviewAndALoneNumeralIsAStub() {
        for stub in ["I.", "II", "IV.", "1.", "12", "Part 2", "Chapter 3", "# Part One"] {
            #expect(BookOutlineRows.isLoneHeadingOrNumeral(stub), "\(stub) is a stub")
        }
        for sentence in ["Dear reader.", "Chapter one.", "He ran home.", "Why?", "Go!"] {
            #expect(!BookOutlineRows.isLoneHeadingOrNumeral(sentence), "\(sentence) is a sentence")
        }
        let story = "It was a widespread field, the kind a preview reads across."
        #expect(BookOutlineRows.cardPreview(blocks: ["Dear reader.", story]).hasPrefix("Dear reader."))
        #expect(BookOutlineRows.cardPreview(blocks: ["I.", story]).hasPrefix("It was"))
    }

    /// Ladder R2-11: a WORD spelled only in Roman-numeral letters is a
    /// sentence, not a numeral — `Mild.` previews; a real numeral is
    /// uppercase and short. RED ON OLD: `Mild.` / `Dim.` / `Civic.` were
    /// skipped from the card as stubs.
    @Test func aWordSpelledInRomanLettersIsASentenceAndARealNumeralStaysAStub() {
        for word in ["Mild.", "Dim.", "Civic.", "Mimic.", "iv.", "MMMMMM."] {
            #expect(!BookOutlineRows.isLoneHeadingOrNumeral(word), "\(word) is a sentence")
        }
        for stub in ["XLII.", "MCMX", "IV.", "II", "LIV."] {
            #expect(BookOutlineRows.isLoneHeadingOrNumeral(stub), "\(stub) is a numeral stub")
        }
        let story = "It was a widespread field, the kind a preview reads across."
        #expect(BookOutlineRows.cardPreview(blocks: ["Mild.", story]).hasPrefix("Mild."))
        #expect(BookOutlineRows.cardPreview(blocks: ["XLII.", story]).hasPrefix("It was"))
    }

    @Test func flatRowsHeadAtEveryTagPathChange() {
        let rows = BookOutlineRows.rows(flat: [
            entry("a", path: "life"), entry("b", path: "life"), entry("c"), entry("d", path: "life"),
        ])
        #expect(rows.map(\.id) == ["path-0", "page-a", "page-b", "page-c", "path-3", "page-d"],
                "a heading where the path differs from the previous entry's — and distinct ids when a path recurs")
    }
}

@MainActor
@Suite("Outline's landing (Act 10 correction round, batch B)", .serialized)
struct BookOutlineLandingTests {
    private func pump(_ seconds: TimeInterval = 0.05) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, watchdog: MainThreadWatchdog,
        until predicate: () -> Bool, maxTurns: Int = 60
    ) async {
        for _ in 0..<maxTurns {
            watchdog.beat()
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump(0.02)
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(20))
            watchdog.beat()
            if predicate() { return }
        }
    }

    private func loadedStructure(
        session: AppSession, db: AppDatabase, readingID: String
    ) async throws -> BookStructureModel {
        let structure = BookStructureModel(session: session, readingID: readingID)
        structure.adopt(.init(
            reading: try await db.read { [readingID] in try Queries.reading($0, id: readingID) },
            sections: try await db.read { [readingID] in
                try Queries.readingSections($0, readingID: readingID)
            },
            deletedSections: [],
            assignments: try await db.read { [readingID] in
                try Queries.sectionAssignments($0, readingID: readingID)
            }))
        return structure
    }

    private func mounted(
        session: AppSession, readingID: String,
        model: BookViewModel, structure: BookStructureModel
    ) -> (NSWindow, NSHostingView<BookView>) {
        let window = NSWindow(
            contentRect: NSRect(
                x: 60, y: 60, width: landingWindowWidth, height: landingWindowHeight),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(
            rootView: BookView(
                session: session, readingID: readingID, model: model, structure: structure))
        hosting.frame = NSRect(
            x: 0, y: 0, width: landingWindowWidth, height: landingWindowHeight)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        return (window, hosting)
    }

    private func anchorTop(_ id: String) -> CGFloat? {
        BookOutlineGeometry.anchorTops[id]
    }

    /// Diagnostics: the outline scroll view's offset + document height.
    private func scrollFacts(_ view: NSView) -> String {
        var facts: [String] = []
        func walk(_ v: NSView) {
            if let scroll = v as? NSScrollView, scroll.documentView?.frame.height ?? 0 > 2000 {
                facts.append("scroll offset=\(scroll.documentVisibleRect.origin.y) doc=\(scroll.documentView?.frame.height ?? 0) visible=\(scroll.documentVisibleRect.height)")
            }
            for s in v.subviews { walk(s) }
        }
        walk(view)
        return facts.joined(separator: " | ")
    }

    /// Row 44 / rows 9 + 12: with the 215-block story EXPANDED AND LIVE, a
    /// chapter reveal for the LAST chapter lands that chapter's heading at
    /// the top of the page — within the run loop's budget (the watchdog),
    /// and AT the heading (the oracle), never mid-story.
    @Test func aChapterRevealLandsAtTheChapterWithAStoryExpandedAndLive() async throws {
        try await withLandingBook(posts: 18, longAt: [4], chapters: true) { session, db, readingID, postIDs, sectionIDs in
            let longPostID = postIDs[4]
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            #expect(structure.chaptersActive)
            BookOutlineGeometry.forgetAnchorTops()
            BookOutlineGeometry.trace = []
            let watchdog = MainThreadWatchdog()
            defer { watchdog.stop() }
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, watchdog: watchdog, until: { false }, maxTurns: 4)

            // The walk's state: the story focused (expanded + THE live
            // editor), its projection filled, its row really tall.
            model.focus(longPostID)
            await settle(window, hosting, watchdog: watchdog, until: {
                (writingEditor(in: hosting)?.frame.height ?? 0) > 3000
            })
            let editorHeight = writingEditor(in: hosting)?.frame.height ?? 0
            #expect(editorHeight > 3000, "the story's editor is tall: \(editorHeight)")

            // The navigator's chapter click for the chapter AFTER the story
            // (a viewport of content still follows it, so "at the top" is
            // reachable — the last chapter never can be).
            let target = BookOutlineRows.Row.chapterAnchor(sectionIDs[2])
            model.requestChapterReveal(sectionIDs[2])
            await settle(window, hosting, watchdog: watchdog, until: {
                if let top = anchorTop(target) { return abs(top) <= BookView.landingTolerance }
                return false
            })
            let top = try #require(anchorTop(target), "the chapter heading realized")
            print("LANDING TRACE (chapter):", BookOutlineGeometry.trace, scrollFacts(hosting))
            #expect(abs(top) <= 4,
                    "the chapter heading sits at the top of the page, not \(top) pt away")
            #expect(model.pendingChapterReveal == nil, "the landing was consumed")
        }
    }

    /// Rows 47 / 7 / 23: with every card COLLAPSED, revealing a note whose
    /// card is off-screen (the last of eight) lands its card at the top.
    /// The old anchor lived INSIDE the unrealized row, so the page never
    /// moved ("intermittent" — it worked only for cards already realized).
    @Test func anOffScreenCollapsedNoteIsRevealedAtTheTop() async throws {
        try await withLandingBook(posts: 40, longAt: [], chapters: false) { session, db, readingID, postIDs, _ in
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            BookOutlineGeometry.forgetAnchorTops()
            BookOutlineGeometry.trace = []
            let watchdog = MainThreadWatchdog()
            defer { watchdog.stop() }
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, watchdog: watchdog, until: {
                anchorTop(BookOutlineRows.Row.noteAnchor(postIDs[0])) != nil
            })
            // The premise: the first card is on screen and the 26th is far
            // BELOW THE FOLD, so the reveal really does have to travel.
            //
            // **13u2b UNIT 1 — this line was restated, and it is this unit's
            // only test edit** (architect ruling AR-2). It used to read
            // `anchorTop(last) == nil` — "the target card starts unrealized" —
            // which expressed off-screen-ness as ABSENCE FROM THE GEOMETRY
            // ORACLE. That was an artifact of the lazy column: a `LazyVStack`
            // never built a far row, so the row reported nothing. Every row
            // exists now (a placeholder at a known height — that is the fix),
            // so the premise is stated positively instead, which is what it
            // always meant and is strictly stronger: the old form also passed
            // when a row was missing for some unrelated reason, while this one
            // says the target really is below the fold (measured: 2,922 pt).
            // The test's CLAIM — the revealed card lands at the top — is
            // untouched below and green.
            let last = BookOutlineRows.Row.noteAnchor(postIDs[25])
            #expect((anchorTop(last) ?? 0) > landingWindowHeight,
                    "the target card starts far below the fold, off-screen")

            model.requestReveal(postIDs[25])
            await settle(window, hosting, watchdog: watchdog, until: {
                if let top = anchorTop(last) { return abs(top) <= BookView.landingTolerance }
                return false
            })
            let top = try #require(anchorTop(last), "the revealed card realized")
            print("LANDING TRACE (note):", BookOutlineGeometry.trace, scrollFacts(hosting))
            #expect(abs(top) <= 4, "the revealed card sits at the top of the page, not \(top) pt away")
            #expect(model.pendingReveal == nil, "the landing was consumed")
            #expect(!model.isExpanded(postIDs[25]), "reveal is scroll-to, never an auto-expand")
        }
    }

    /// Row 44's second symptom: a bare focus (the navigator's note-row
    /// click) lands the caret at the FIRST block, not the 215th.
    @Test func aBareFocusLandsAtTheFirstBlock() async throws {
        try await withLandingBook(posts: 6, longAt: [2], chapters: true) { session, db, readingID, postIDs, _ in
            let longPostID = postIDs[2]
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            let watchdog = MainThreadWatchdog()
            defer { watchdog.stop() }
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, watchdog: watchdog, until: { false }, maxTurns: 4)

            model.focus(longPostID)
            #expect(model.caretSeed == 0, "a bare focus seeds the first block")
            await settle(window, hosting, watchdog: watchdog, until: {
                (writingEditor(in: hosting)?.string.count ?? 0) > 5000
            })
            // One more beat so the seed is applied after the first render.
            await settle(window, hosting, watchdog: watchdog, until: { false }, maxTurns: 3)
            let editor = try #require(writingEditor(in: hosting))
            #expect(editor.string.count > 5000, "the projection filled")
            #expect(editor.selectedRange().location == 0,
                    "the caret is at the first block, not at \(editor.selectedRange().location)")
        }
    }

    /// Row 53 (the orchestrator's walk of batch B — MAJOR): with THREE
    /// stories expanded, opening a COLLAPSED story far below, then one far
    /// above, lands each at ITS OWN top — and the landing HOLDS. The old
    /// convergence stopped at the first "at the top" report (or at a fixed
    /// four hops); the expanded rows around the viewport then finished
    /// loading (24/40 pt → ~20,000 pt each) and pushed the page into the
    /// wrong story. "Landed" here is read twice: when the anchor first
    /// settles, and again a second later.
    @Test func openingACollapsedStoryLandsAtItsTopWithThreeStoriesExpanded() async throws {
        try await withLandingBook(posts: 18, longAt: [1, 3, 7, 11, 15], chapters: true) { session, db, readingID, postIDs, _ in
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            BookOutlineGeometry.forgetAnchorTops()
            BookOutlineGeometry.trace = []
            let watchdog = MainThreadWatchdog()
            defer { watchdog.stop() }
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, watchdog: watchdog, until: { false }, maxTurns: 4)

            /// The navigator's note-row click (`openFromNavigator`): focus +
            /// reveal; then wait for the landing to settle AND hold.
            @MainActor func open(_ index: Int, _ what: String) async throws -> CGFloat {
                let anchor = BookOutlineRows.Row.noteAnchor(postIDs[index])
                model.focus(postIDs[index])
                model.requestReveal(postIDs[index])
                await settle(window, hosting, watchdog: watchdog, until: {
                    if let top = anchorTop(anchor) { return abs(top) <= BookView.landingTolerance }
                    return false
                }, maxTurns: 120)
                // The hold: a second later the expanded rows around the page
                // have loaded their heights — the anchor must still be there.
                await settle(window, hosting, watchdog: watchdog, until: { false }, maxTurns: 24)
                let top = try #require(anchorTop(anchor), "\(what): the opened story realized")
                print("LANDING TRACE (\(what)):", BookOutlineGeometry.trace.suffix(24), scrollFacts(hosting))
                return top
            }

            // The walk's state: three stories opened in turn (each the live
            // editor while it is the newest; the earlier two read-cheap).
            for (i, what) in [(3, "story 3"), (7, "story 7"), (11, "story 11")] {
                let top = try await open(i, what)
                #expect(abs(top) <= 4, "\(what) opens at its top, not \(top) pt away")
            }
            let editorHeight = writingEditor(in: hosting)?.frame.height ?? 0
            #expect(editorHeight > 3000, "the newest story's editor is tall: \(editorHeight)")

            // Far BELOW (three expanded stories above and between).
            let below = try await open(15, "far below")
            // **UNWRAPPED at 13u2b UNIT 1, exactly as `KnownIssuesAndTechDebt`
            // row 64 instructed it to be.** From RULING A-2 (2026-09-15) until
            // then this arm carried a hard ≤ 90 bound and the ≤ 4 aspiration
            // inside `withKnownIssue`, because the column's lazy runs answered
            // "how tall is a row I have not realized" with the AVERAGE of the
            // ones they had: arriving here de-realized the rows above, the
            // estimate for them was ~70 pt short, the content shrank and the
            // page slid off the story it had just landed on — 13 hops, 4.2 s,
            // a stable -73 pt, 3/3. The rows now stand at heights the column
            // KNOWS (`BookHeightManifest` / `OutlineRunRow`), so nothing above
            // a landed target can move: measured at 0 hops, and not one
            // content-height change during the landing.
            #expect(abs(below) <= 4,
                    "the story far below lands at its own top and stays there, not \(below) pt away")
            // Far ABOVE (four expanded stories below it now).
            let above = try await open(1, "far above")
            #expect(abs(above) <= 4,
                    "the story far above lands at its own top and stays there, not \(above) pt away")
            #expect(model.pendingReveal == nil, "the landing was consumed")
        }
    }
}

// MARK: - The Act 10 correction round, batch G — row 73

extension BookOutlineLandingTests {
    /// **Ladder R1-10, RESTATED AT 13u2 UNIT A2 — and the claim got
    /// stronger.** R1-10's fact was *"an expanded row performs no whole-note
    /// `renderPost`"*, which was true because the per-row read had been
    /// narrowed to collapsed rows after "expand all" on Sherlock was measured
    /// reading twelve full stories for nothing rendered.
    ///
    /// The per-row read is GONE (item 18: a card whose words arrive late is a
    /// card whose HEIGHT arrives late). The book primes every entry's opening
    /// in ONE bounded read as the entries arrive, so the fact to pin now is:
    /// **no row reads anything, ever — the book read each note's opening
    /// once, before the rows existed, and mounting, expanding and collapsing
    /// them all costs nothing more.** That covers R1-10's case and the one it
    /// could not state (a card scrolled away and back used to re-read the
    /// whole note every time).
    @Test func theBookPrimesEachNoteOnceAndNoRowEverReadsAgain() async throws {
        try await withLandingBook(posts: 5, longAt: [], chapters: false) { session, db, readingID, postIDs, _ in
            let model = BookViewModel(session: session, readingID: readingID)
            BookCardPreviewReads.reset()
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID, limit: 300)
            })
            // The prime: ONE read, five notes — before any row exists.
            #expect(BookCardPreviewReads.reads == 1, "one bounded read for the book")
            #expect(BookCardPreviewReads.notes == 5, "five notes in it")
            for id in postIDs {
                #expect(!model.cardPreview(id).isEmpty,
                        "every entry's words are in hand before its first frame")
            }

            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            model.expandAll()
            let watchdog = MainThreadWatchdog()
            defer { watchdog.stop() }
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, watchdog: watchdog, until: { false }, maxTurns: 12)
            #expect(BookCardPreviewReads.reads == 1, "mounting five expanded stories reads nothing")

            // Collapsing DOES re-read the notes that were open — deliberately:
            // a note edited while open must not show its old opening words.
            // The cards keep the words they have while it runs, so no card is
            // ever empty and no height arrives late.
            model.collapseAll()
            await settle(window, hosting, watchdog: watchdog, until: {
                BookCardPreviewReads.reads > 1
            }, maxTurns: 40)
            #expect(BookCardPreviewReads.reads == 2, "one refresh read for the notes that closed")
            #expect(BookCardPreviewReads.notes == 10, "five primed, five refreshed")
            await settle(window, hosting, watchdog: watchdog, until: { false }, maxTurns: 10)
            #expect(BookCardPreviewReads.reads == 2, "and nothing reads again once they settle")
        }
    }

    /// **Row 73 (E's trace): an ascent INTO a not-yet-mounted book lands at
    /// the note, not at the top.** The Library panel's outline row and the
    /// membership chip's link both request a reveal BEFORE the book's
    /// entries have arrived; `landOutlineReveal` consumed the request at
    /// Outline's `onAppear` and only THEN found the note absent — dropped,
    /// the book opened at the top (reproduced twice in E's walk). Now a
    /// request whose note the entries have not delivered stays parked, and
    /// the entries' arrival lands it. RED ON OLD: the card never sits at the
    /// top (the settle times out, the anchor unreported).
    @Test func aRevealRequestedBeforeTheEntriesArriveLandsWhenTheyDo() async throws {
        try await withLandingBook(posts: 40, longAt: [], chapters: false) { session, db, readingID, postIDs, _ in
            // The model is EMPTY — no `adopt` — exactly the state an ascent
            // meets: the view's own observation delivers the entries after
            // the mount.
            let model = BookViewModel(session: session, readingID: readingID)
            #expect(model.entries.isEmpty, "the premise: the entries have not arrived")
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            BookOutlineGeometry.forgetAnchorTops()
            BookOutlineGeometry.trace = []
            let watchdog = MainThreadWatchdog()
            defer { watchdog.stop() }
            // The ascent's request, BEFORE the mount.
            model.requestReveal(postIDs[25])
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            let last = BookOutlineRows.Row.noteAnchor(postIDs[25])
            await settle(window, hosting, watchdog: watchdog, until: {
                if let top = anchorTop(last) { return abs(top) <= BookView.landingTolerance }
                return false
            }, maxTurns: 160)
            let top = try #require(anchorTop(last), "the revealed card realized once the entries arrived")
            print("LANDING TRACE (parked reveal):", BookOutlineGeometry.trace, scrollFacts(hosting))
            #expect(abs(top) <= 4, "the ascent's note sits at the top of the page, not \(top) pt away")
            #expect(model.pendingReveal == nil, "the landing was consumed — after the entries arrived")
        }
    }
}

// MARK: - 13u2b UNIT 1 — THE CLOSED ROAD'S GUARD (architect ruling AR-1, rider 1)

extension BookOutlineLandingTests {
    /// **The measurement `KnownIssuesAndTechDebt` row 64 asks a successor to
    /// make, made — because this unit builds BESIDE the road that row closed,
    /// and building beside a closed road means retiring its ambiguity rather
    /// than inheriting it.**
    ///
    /// The history in one paragraph: 13u2 UNIT A tried to stabilise the
    /// Outline by splitting the lazy runs BY SCALE, and closed that road on
    /// the evidence *"`editorHeight == 24` after 200 settle turns"* — a live
    /// editor that mounted empty and stayed empty. UNIT A2 then traced that
    /// symptom to a HARNESS artifact (the representable realizes twice under a
    /// pumped run loop, and "the first `EditorTextView` in the tree" returned
    /// the shadow), so the evidence was downgraded and row 64 wrote the
    /// successor's exact instruction: **measure with `textView.window != nil`
    /// and `index.entries.count`, never "the first editor"**.
    ///
    /// This unit did NOT rebuild that split — it leaves the expanded notes and
    /// the ONE live editor exactly where they were, as direct children of the
    /// column, and changes only the runs of headings and cards. So this pin is
    /// the guard on that claim, in row 64's own terms: with a 215-block story
    /// expanded and focused in the Outline, the editor she is writing in is ON
    /// SCREEN, it holds the note's blocks, and it is really laid out.
    @Test func theLiveEditorStillReachesTheScreenWithEveryBlockUnderTheNewRuns() async throws {
        try await withLandingBook(posts: 18, longAt: [4], chapters: true) { session, db, readingID, postIDs, _ in
            let longPostID = postIDs[4]
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            let watchdog = MainThreadWatchdog()
            defer { watchdog.stop() }
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, watchdog: watchdog, until: { false }, maxTurns: 4)

            model.focus(longPostID)
            await settle(window, hosting, watchdog: watchdog, until: {
                (writingEditor(in: hosting)?.frame.height ?? 0) > 3000
            }, maxTurns: 120)

            let editor = try #require(writingEditor(in: hosting), "the story's editor mounted")
            // Row 64's first term: the view REACHES A WINDOW. (It is also what
            // `EditorRouter.active` has meant since 13u2 UNIT B — the view that
            // reaches the screen claims it — so the two say the same thing here
            // and the pin says both out loud.)
            #expect(editor.window != nil, "the live editor is on screen, not an orphan off it")
            #expect(session.editorRouter.active != nil, "the router names an editor")
            // Row 64's second term: it holds the note's BLOCKS.
            let entries = session.editorRouter.active?.index.entries.count ?? 0
            #expect(entries == 215,
                    "the on-screen editor holds the story's 215 blocks, not \(entries)")
            // And it is laid out — the symptom the closed road was closed on.
            #expect(editor.frame.height > 3000,
                    "the editor is really laid out, not standing at a placeholder: \(editor.frame.height) pt")
            print("MOUNT GUARD (13u2b rider 1): window=\(editor.window != nil ? "Y" : "N") "
                + "entries=\(entries) height=\(editor.frame.height)")
        }
    }
}

// MARK: - 13u2b UNIT 1 — a landing on the row the page is ALREADY at

extension BookOutlineLandingTests {
    /// **Found on the unit's own dev-store walk, and it is a defect this unit
    /// introduced:** `gave up at top=unrealized after 15 hops, 4200 ms`,
    /// three times, on a click whose target was the row the page was already
    /// showing.
    ///
    /// The mechanism: a landing learns where its target is from geometry
    /// reports, and `onGeometryChange` reports a CHANGE. When the scroll moves
    /// nothing — because the page is already there — no report arrives, the
    /// landing's `lastTop` stays nil, and the loop reads that as "the target
    /// never realized" and hops until the watchdog stops it. Nothing moves on
    /// screen, so there is no visible stutter; there is a landing spinning for
    /// four seconds, and her own scroll would have been fighting its hops.
    ///
    /// It could not happen before this unit: a far row did not exist in a lazy
    /// container, so a landing's target always realized DURING the landing and
    /// always sent a first report. Now every row exists, and a row that has
    /// not moved has nothing to say.
    ///
    /// RED ON OLD: without the seed the landing ends `gave up … unrealized`.
    @Test func landingAgainOnTheRowThePageIsAlreadyAtSettlesInsteadOfSpinning() async throws {
        try await withLandingBook(posts: 40, longAt: [], chapters: false) { session, db, readingID, postIDs, _ in
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            BookOutlineGeometry.forgetAnchorTops()
            BookOutlineGeometry.trace = []
            let watchdog = MainThreadWatchdog()
            defer { watchdog.stop() }
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            let target = BookOutlineRows.Row.noteAnchor(postIDs[25])
            await settle(window, hosting, watchdog: watchdog, until: {
                anchorTop(BookOutlineRows.Row.noteAnchor(postIDs[0])) != nil
            })

            // Land there once, the ordinary way.
            model.requestReveal(postIDs[25])
            await settle(window, hosting, watchdog: watchdog, until: {
                if let top = anchorTop(target) { return abs(top) <= BookView.landingTolerance }
                return false
            }, maxTurns: 120)
            #expect(abs(try #require(anchorTop(target))) <= 4, "the first landing arrived")

            // Now ask for the SAME row again: the page is already there, so
            // the scroll moves nothing and no row reports.
            BookOutlineGeometry.trace = []
            model.requestReveal(postIDs[25])
            await settle(window, hosting, watchdog: watchdog, until: {
                BookOutlineGeometry.trace.contains { $0.contains("DONE:") }
            }, maxTurns: 160)
            let story = BookOutlineGeometry.trace.joined(separator: " | ")
            print("LANDING TRACE (already there):", story)
            #expect(story.contains("DONE:"), "the second landing finished at all: \(story)")
            #expect(!story.contains("unrealized"),
                    "the landing knew where its target was: \(story)")
            #expect(!story.contains("gave up"),
                    "the landing settled rather than spending its whole budget: \(story)")
            #expect(abs(try #require(anchorTop(target))) <= 4, "and the page is still there")
        }
    }
}

// MARK: - VX-75 — the first click into editing holds the column steady

extension BookOutlineLandingTests {
    /// **VX-75 (her 2026-10-06 report):** *"when I click in to edit there's a
    /// dreadful flash of the whole screen and slight shake."* The road: a note
    /// EXPANDED and read-cheap, then a prose click — `focus(_:caret:)` — which
    /// swaps the row's read surface for the live inline editor. The contract
    /// this pins: the swap is INVISIBLE to the rest of the column. Every other
    /// realized anchor holds its top (the read↔live inset drift is ≤ ~48 pt;
    /// the tolerance is 150 so only the bug class — a dropped reservation, a
    /// placeholder collapse, a run remount — can cross it), the focused row's
    /// height never dips toward the editor's 24-pt birth height, and no
    /// watched anchor stops reporting mid-swap (a de-realized run row is her
    /// "text disappears for a split second"). Sampled EVERY settle turn —
    /// the flash is transient, and an end-state read would stay green through
    /// it.
    @Test func theFirstClickIntoEditingHoldsTheColumnSteady() async throws {
        try await withLandingBook(posts: 9, longAt: [1, 4], chapters: true) { session, db, readingID, postIDs, _ in
            let storyID = postIDs[1]
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            BookOutlineGeometry.forgetAnchorTops()
            BookOutlineGeometry.trace = []
            let watchdog = MainThreadWatchdog()
            defer { watchdog.stop() }
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, watchdog: watchdog, until: { false }, maxTurns: 4)

            // Her state before the click: the story unfolded READ-CHEAP (the
            // ▸, not a focus), its surface realized and remembered-size
            // settled — she "scrolled through everything fine".
            model.expand(storyID)
            let storyAnchor = BookOutlineRows.Row.noteAnchor(storyID)
            await settle(window, hosting, watchdog: watchdog, until: {
                (BookOutlineGeometry.rowHeights[storyAnchor] ?? 0) > 3000
            }, maxTurns: 120)
            let preHeight = try #require(BookOutlineGeometry.rowHeights[storyAnchor])
            #expect(preHeight > 3000, "the read surface realized tall: \(preHeight)")
            // One quiet beat so geometry is settled before the click.
            await settle(window, hosting, watchdog: watchdog, until: { false }, maxTurns: 8)

            // The witnesses: every anchor realized right now, where it sits.
            let before = BookOutlineGeometry.anchorTops
            #expect(before.count >= 4, "several rows are realized around the story: \(before.count)")

            // THE CLICK: the read tier's plain click reports an offset and
            // the container focuses — `ReadPostView.onFocusRequest`'s exact
            // call, mid-first-block.
            model.focus(storyID, caret: 120)

            // Sample EVERY turn while the swap settles: max top deviation per
            // witness, the focused row's height floor, any witness that stops
            // reporting.
            var maxShift: CGFloat = 0
            var shiftStory: [String] = []
            var heightFloor = preHeight
            var vanished: Set<String> = []
            for turn in 0..<60 {
                watchdog.beat()
                hosting.layoutSubtreeIfNeeded()
                window.layoutIfNeeded()
                window.displayIfNeeded()
                pump(0.02)
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(20))
                watchdog.beat()
                let now = BookOutlineGeometry.anchorTops
                for (id, top) in before {
                    guard let current = now[id] else {
                        vanished.insert(id)
                        continue
                    }
                    let shift = abs(current - top)
                    if shift > maxShift {
                        maxShift = shift
                        shiftStory.append("turn \(turn): \(id) \(Int(top)) → \(Int(current))")
                    }
                }
                if let h = BookOutlineGeometry.rowHeights[storyAnchor], h < heightFloor {
                    heightFloor = h
                }
                // Stop once the live editor holds the story and a few quiet
                // turns have passed after it.
                if (writingEditor(in: hosting)?.string.count ?? 0) > 5000, turn > 20 { break }
            }

            // The swap really happened (the pin is not vacuously green).
            let editor = try #require(writingEditor(in: hosting))
            #expect(editor.string.count > 5000, "the live editor holds the story")

            print("VX-75 PIN: maxShift=\(Int(maxShift)) heightFloor=\(Int(heightFloor)) "
                + "of \(Int(preHeight)) vanished=\(vanished.sorted()) shifts=\(shiftStory.suffix(6))")
            #expect(maxShift <= 150,
                    "no neighbour moves under the swap — max shift \(Int(maxShift)) pt (\(shiftStory.suffix(4)))")
            #expect(heightFloor > preHeight - 200,
                    "the focused row never dips toward the editor's birth height: floor \(Int(heightFloor)) of \(Int(preHeight))")
            #expect(vanished.isEmpty,
                    "no realized row de-materializes under the swap: \(vanished.sorted())")
        }
    }
}

extension BookOutlineLandingTests {
    /// Every text view in the tree that is in a window and SHOWS real prose:
    /// a read surface holding it, or a live editor holding it at its real
    /// height (an editor at its 24-pt birth frame shows one line of it, and
    /// the host keeps it invisible until its height is in).
    @MainActor
    private func proseSurfaces(in view: NSView) -> [NSTextView] {
        var found: [NSTextView] = []
        func walk(_ v: NSView) {
            if let text = v as? NSTextView, text.window != nil, !text.isHiddenOrHasHiddenAncestor,
               text.string.count > 1000,
               !(text is EditorTextView) || text.frame.height > 1000 {
                found.append(text)
            }
            for sub in v.subviews { walk(sub) }
        }
        walk(view)
        return found
    }

    /// **VX-75 — THE MECHANISM, as she saw it** (the walk's frames: the
    /// column blank for ~9 frames, ~0.6 s, then the same text back at the
    /// same place). A plain click on a read-cheap story swaps the row's read
    /// surface for the live editor; the read surface is dismantled at once
    /// while the editor is born EMPTY and fills only when its first projection
    /// arrives from the store. Every displayed turn between those two moments
    /// shows no prose where the story was. The contract: from the click until
    /// the editor holds the story, some surface is always showing it.
    @Test func theFirstClickIntoEditingNeverShowsAnEmptyNote() async throws {
        try await withLandingBook(posts: 6, longAt: [1], chapters: true) { session, db, readingID, postIDs, _ in
            let storyID = postIDs[1]
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            let watchdog = MainThreadWatchdog()
            defer { watchdog.stop() }
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, watchdog: watchdog, until: { false }, maxTurns: 4)
            model.expand(storyID)
            await settle(window, hosting, watchdog: watchdog, until: {
                !proseSurfaces(in: hosting).isEmpty
            }, maxTurns: 120)
            await settle(window, hosting, watchdog: watchdog, until: { false }, maxTurns: 8)
            #expect(!proseSurfaces(in: hosting).isEmpty, "the story reads before the click")

            model.focus(storyID, caret: 120)

            var emptyTurns: [Int] = []
            var editorFilledAt: Int?
            for turn in 0..<80 {
                watchdog.beat()
                hosting.layoutSubtreeIfNeeded()
                window.layoutIfNeeded()
                window.displayIfNeeded()
                if proseSurfaces(in: hosting).isEmpty { emptyTurns.append(turn) }
                if (writingEditor(in: hosting)?.string.count ?? 0) > 1000 {
                    editorFilledAt = editorFilledAt ?? turn
                    if turn > (editorFilledAt ?? 0) + 3 { break }
                }
                pump(0.02)
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(20))
            }
            print("VX-75 EMPTY: emptyTurns=\(emptyTurns) editorFilledAt=\(String(describing: editorFilledAt))")
            #expect(editorFilledAt != nil, "the live editor came to hold the story")
            #expect(emptyTurns.isEmpty,
                    "no displayed turn shows the story with no prose — empty at turns \(emptyTurns)")
        }
    }

    /// A surface SHOWING the story: in a window, not hidden, holding the
    /// story's text AT a real height. Tightened on BOTH kinds (the forward
    /// pin tightens only the editor): the inverse swap's failure is a fresh
    /// read surface whose storage fills a beat before its 40-pt frame grows,
    /// and a 40-pt sliver of a 9.7k-word story is not the story showing.
    @MainActor
    private func storySurfaces(in view: NSView) -> [NSTextView] {
        var found: [NSTextView] = []
        func walk(_ v: NSView) {
            if let text = v as? NSTextView, text.window != nil, !text.isHiddenOrHasHiddenAncestor,
               text.string.count > 1000, text.frame.height > 1000 {
                found.append(text)
            }
            for sub in v.subviews { walk(sub) }
        }
        walk(view)
        return found
    }

    /// **VX-82 — THE INVERSE SWAP** (found at VX-75's ladder, R1-4; her
    /// confirmation in the VX-75 build: "that pause is noticable"). Leaving
    /// edit mode — the click-out margin's `focus(nil)`, a click into another
    /// note — unmounted the live editor at once while a FRESH read surface
    /// mounted empty and filled only when its first projection arrived, so
    /// the row showed a reserved-height blank beat ∝ the story. The
    /// contract, the forward pin's mirror: from the leave until the read
    /// surface holds the story at its real height, SOME surface is always
    /// showing it — and the handover COMPLETES (the read surface back, the
    /// lingering editor gone; a beat, never a resident double).
    @Test func leavingEditModeNeverShowsAnEmptyNote() async throws {
        try await withLandingBook(posts: 6, longAt: [1], chapters: true) { session, db, readingID, postIDs, _ in
            let storyID = postIDs[1]
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            let watchdog = MainThreadWatchdog()
            defer { watchdog.stop() }
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, watchdog: watchdog, until: { false }, maxTurns: 4)
            model.expand(storyID)
            await settle(window, hosting, watchdog: watchdog, until: {
                !storySurfaces(in: hosting).isEmpty
            }, maxTurns: 120)

            /// Into editing, handover complete: the editor holds the story at
            /// a real height and the read surface has been released.
            @MainActor func enterEditing() async {
                model.focus(storyID, caret: 120)
                await settle(window, hosting, watchdog: watchdog, until: {
                    let showing = storySurfaces(in: hosting)
                    return !showing.isEmpty && showing.allSatisfy { $0 is EditorTextView }
                }, maxTurns: 160)
                await settle(window, hosting, watchdog: watchdog, until: { false }, maxTurns: 6)
            }

            /// Sample every displayed turn after a leave: turns with no
            /// surface showing the story, and when the read tier is back.
            @MainActor func sampleLeave(_ what: String) async -> (empty: [Int], readBackAt: Int?) {
                var emptyTurns: [Int] = []
                var readBackAt: Int?
                for turn in 0..<80 {
                    watchdog.beat()
                    hosting.layoutSubtreeIfNeeded()
                    window.layoutIfNeeded()
                    window.displayIfNeeded()
                    let showing = storySurfaces(in: hosting)
                    if showing.isEmpty { emptyTurns.append(turn) }
                    if showing.contains(where: { !($0 is EditorTextView) }) {
                        readBackAt = readBackAt ?? turn
                        if turn > (readBackAt ?? 0) + 3 { break }
                    }
                    pump(0.02)
                    await Task.yield()
                    try? await Task.sleep(for: .milliseconds(20))
                    watchdog.beat()
                }
                print("VX-82 LEAVE (\(what)): emptyTurns=\(emptyTurns) "
                    + "readBackAt=\(String(describing: readBackAt))")
                return (emptyTurns, readBackAt)
            }

            // LEG 1 — the click-out road (`focus(nil)`; the row stays
            // expanded).
            await enterEditing()
            let editor = try #require(writingEditor(in: hosting))
            #expect(editor.string.count > 5000, "the live editor holds the story")
            model.focus(nil)
            let leg1 = await sampleLeave("focus(nil)")

            // The handover completes: the story's lingering editor leaves.
            await settle(window, hosting, watchdog: watchdog, until: {
                (writingEditor(in: hosting)?.string.count ?? 0) < 5000
            }, maxTurns: 120)
            #expect((writingEditor(in: hosting)?.string.count ?? 0) < 5000,
                    "the outgoing editor unmounts once the read surface shows — the linger is a beat, not a resident double")

            // LEG 2 — her clicking-around road: leave by focusing ANOTHER
            // note (short, so its own editor never passes the story filter).
            await enterEditing()
            model.focus(postIDs[2], caret: 0)
            let leg2 = await sampleLeave("focus(other)")

            #expect(leg1.readBackAt != nil, "the read surface came back after the click-out")
            #expect(leg2.readBackAt != nil, "the read surface came back after focusing another note")
            #expect(leg1.empty.isEmpty,
                    "no displayed turn after the click-out shows the story's row empty — empty at \(leg1.empty)")
            #expect(leg2.empty.isEmpty,
                    "no displayed turn after focusing elsewhere shows the story's row empty — empty at \(leg2.empty)")
        }
    }

    /// **VX-91 — THE STRESS PROBE, built as the CONFIRM** (her report:
    /// rapid clicking across the expanded Sherlock outline sometimes
    /// jitters, worst case "the title that you clicked on will appear alone
    /// in the middle of the page, with no other text on the screen"; not
    /// reliably reproducible, seen on both Macs, pre-dates VX-75's fix. Her
    /// rule: no fix without a clear diagnosis and a pin — so this probe IS
    /// the diagnosis attempt. RED confirms a mechanism class and the hunt
    /// narrows from its story; GREEN acquits the harness-reachable classes
    /// and VX-91 records the findings).
    ///
    /// The storm is her gesture at her pace: everything expanded, then a
    /// focus+reveal (the navigator's click) on a different story every
    /// ~100 ms, twelve times, never waiting for a landing to finish. The
    /// asserts are about the AFTERMATH — a brief blank on a long jump is
    /// virtualization's normal beat; what must never happen is the state
    /// STICKING: anchors gone, a story row collapsed, a viewport of
    /// placeholders with no prose, a landing still spinning.
    @Test func rapidClickingAcrossExpandedStoriesSettlesWithProseOnScreen() async throws {
        try await withLandingBook(posts: 9, longAt: [1, 4, 7], chapters: true) { session, db, readingID, postIDs, _ in
            let stories = [postIDs[1], postIDs[4], postIDs[7]]
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            BookOutlineGeometry.forgetAnchorTops()
            BookOutlineGeometry.trace = []
            let watchdog = MainThreadWatchdog(budget: 8)
            defer { watchdog.stop() }
            let (window, hosting) = mounted(
                session: session, readingID: readingID, model: model, structure: structure)
            defer {
                window.orderOut(nil)
                window.close()
            }
            await settle(window, hosting, watchdog: watchdog, until: { false }, maxTurns: 4)

            // Her setup: ALL text expanded, the first story's surface real.
            model.expandAll()
            await settle(window, hosting, watchdog: watchdog, until: {
                !storySurfaces(in: hosting).isEmpty
            }, maxTurns: 160)
            await settle(window, hosting, watchdog: watchdog, until: { false }, maxTurns: 10)
            let anchors = stories.map { BookOutlineRows.Row.noteAnchor($0) }
            let before = BookOutlineGeometry.anchorTops
            #expect(before.count >= 6, "the expanded column is realized around the fold: \(before.count)")

            // THE STORM: twelve focus+reveal clicks across the three
            // stories, one every ~3 displayed turns (~100 ms), plus a
            // click-out mid-storm (she doesn't only click IN). Diagnostics
            // recorded per turn; no asserts in here.
            var stormBlankTurns = 0
            var turnsSinceClick = 0
            var clicks = 0
            var cycle = 0
            for _ in 0..<44 {
                watchdog.beat()
                if turnsSinceClick >= 3, clicks < 12 {
                    turnsSinceClick = 0
                    clicks += 1
                    if clicks == 7 {
                        model.focus(nil)  // the mid-storm click-out
                    } else {
                        let story = stories[cycle % stories.count]
                        cycle += 1
                        model.focus(story, caret: 120)
                        model.requestReveal(story)
                    }
                } else {
                    turnsSinceClick += 1
                }
                hosting.layoutSubtreeIfNeeded()
                window.layoutIfNeeded()
                window.displayIfNeeded()
                if storySurfaces(in: hosting).isEmpty { stormBlankTurns += 1 }
                pump(0.02)
                await Task.yield()
                try? await Task.sleep(for: .milliseconds(15))
                watchdog.beat()
            }

            // THE AFTERMATH: the storm is over; the state must settle.
            let target = stories[(cycle - 1) % stories.count]
            let targetAnchor = BookOutlineRows.Row.noteAnchor(target)
            await settle(window, hosting, watchdog: watchdog, until: {
                model.pendingReveal == nil && !storySurfaces(in: hosting).isEmpty
            }, maxTurns: 100)
            await settle(window, hosting, watchdog: watchdog, until: { false }, maxTurns: 20)

            let now = BookOutlineGeometry.anchorTops
            let vanished = before.keys.filter { now[$0] == nil }.sorted()
            let storyHeights = anchors.map { Int(BookOutlineGeometry.rowHeights[$0] ?? 0) }
            print("VX-91 PROBE: clicks=\(clicks) stormBlankTurns=\(stormBlankTurns) "
                + "vanished=\(vanished) storyHeights=\(storyHeights) "
                + "targetTop=\(String(describing: now[targetAnchor].map(Int.init))) "
                + "trace=\(BookOutlineGeometry.trace.suffix(18))")

            #expect(vanished.isEmpty,
                    "every anchor realized before the storm still reports after it: \(vanished)")
            #expect(model.pendingReveal == nil, "no landing is left spinning after the storm")
            #expect(!storySurfaces(in: hosting).isEmpty,
                    "prose is on screen after the storm — never a page of placeholders under the clicked title")
            for (anchor, height) in zip(anchors, storyHeights) {
                #expect(height > 1500,
                        "no expanded story's row collapsed under the storm: \(anchor) at \(height) pt")
            }
        }
    }
}
