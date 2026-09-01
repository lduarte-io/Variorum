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
        let reading = try session.operations.createReading(name: "the landing", kind: .curated)
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
                _ = try session.operations.newBlock(
                    in: post.id, text: "Prose of note \(p), short enough to card.")
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

@MainActor
private func firstEditor(in view: NSView) -> EditorTextView? {
    if let editor = view as? EditorTextView { return editor }
    for sub in view.subviews {
        if let found = firstEditor(in: sub) { return found }
    }
    return nil
}

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
            contentRect: NSRect(x: 60, y: 60, width: 1200, height: 760),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        let hosting = NSHostingView(
            rootView: BookView(
                session: session, readingID: readingID, model: model, structure: structure))
        hosting.frame = NSRect(x: 0, y: 0, width: 1200, height: 760)
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
            model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            #expect(structure.chaptersActive)
            BookOutlineGeometry.anchorTops = [:]
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
                (firstEditor(in: hosting)?.frame.height ?? 0) > 3000
            })
            let editorHeight = firstEditor(in: hosting)?.frame.height ?? 0
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
            model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            BookOutlineGeometry.anchorTops = [:]
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
            // The premise: the first card is on screen; the 26th is not
            // realized at all (a 40-card book realizes a viewport + slack).
            let last = BookOutlineRows.Row.noteAnchor(postIDs[25])
            #expect(anchorTop(last) == nil, "the target card starts unrealized, off-screen")

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
            model.adopt(try await db.read { [readingID] in
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
                (firstEditor(in: hosting)?.string.count ?? 0) > 5000
            })
            // One more beat so the seed is applied after the first render.
            await settle(window, hosting, watchdog: watchdog, until: { false }, maxTurns: 3)
            let editor = try #require(firstEditor(in: hosting))
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
            model.adopt(try await db.read { [readingID] in
                try Queries.assembleReading($0, readingID: readingID)
            })
            let structure = try await loadedStructure(session: session, db: db, readingID: readingID)
            BookOutlineGeometry.anchorTops = [:]
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
            let editorHeight = firstEditor(in: hosting)?.frame.height ?? 0
            #expect(editorHeight > 3000, "the newest story's editor is tall: \(editorHeight)")

            // Far BELOW (three expanded stories above and between).
            let below = try await open(15, "far below")
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
