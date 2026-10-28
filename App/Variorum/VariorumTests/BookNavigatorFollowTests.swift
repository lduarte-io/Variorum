//
//  BookNavigatorFollowTests.swift
//  VariorumTests
//
//  VX-645 / VX-646 (the VX-648 run, batch 4) — the book navigator beyond
//  Outline, as pure rules and one model accessor:
//
//    · VX-646 — WHICH row the navigator keeps in view (the viewed note's own
//      row, else its collapsed one-note chapter row, else the viewed chapter's
//      row), the MINIMAL reveal from that row's own frame, and the follow
//      state — the Open list's `SectionFollow`, reused: a new highlighted row
//      is the act, a hand scroll pauses until the next, a resize while paused
//      never pulls the list back.
//    · VX-645 (A-648-8) — the pair the navigator marks, mode by mode: Outline's
//      and Read ▸ Scroll's followers, Read ▸ Pages' shown note, the spread's
//      LEFT page, nothing in Index.
//
//  New capabilities — red on old by construction (none of these symbols
//  existed; P-562-1's "no auto-scroll" was encoded by no pin, so nothing
//  flips). The mounted halves are `BookOutlineLandingTests`' VX-645/646
//  extension.
//

import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@Suite("VX-646 — the navigator follows its highlighted row (the Open list's idiom)")
struct BookNavigatorFollowTests {
    typealias Pair = BookOutlineViewed.Pair

    /// The highlighted row: the viewed note's own row; a one-note chapter
    /// collapsed into its heading (row 8) is that note's row; with no note
    /// viewed, the viewed chapter's row (an empty chapter's heading at the
    /// top); in the spread the LEFT page (the viewed pair), never its other
    /// page.
    @Test func theHighlightedRowIsTheViewedNotesOwnRowElseItsChapter() {
        let viewed = Pair(sectionID: "s1", postID: "p2")
        #expect(BookNavigatorFollow.followsNoteRow("p2", viewed: viewed))
        #expect(!BookNavigatorFollow.followsNoteRow("p3", viewed: viewed), "the spread's other page")
        #expect(!BookNavigatorFollow.followsChapterRow("s1", collapsedNote: nil, viewed: viewed),
                "a multi-note chapter's heading is not the row — its note's is")
        #expect(BookNavigatorFollow.followsChapterRow("s1", collapsedNote: "p2", viewed: viewed),
                "a one-note chapter's collapsed row IS the note's row")
        let emptyChapter = Pair(sectionID: "s4")
        #expect(BookNavigatorFollow.followsChapterRow("s4", collapsedNote: nil, viewed: emptyChapter))
        #expect(!BookNavigatorFollow.followsChapterRow("s3", collapsedNote: nil, viewed: emptyChapter))
        #expect(!BookNavigatorFollow.followsNoteRow("p1", viewed: .nothingViewed))
        #expect(!BookNavigatorFollow.followsChapterRow("s1", collapsedNote: "p1", viewed: .nothingViewed),
                "nothing viewed: no row is followed")
        #expect(BookNavigatorFollow.noteRowID("x") != BookNavigatorFollow.chapterRowID("x"),
                "a note and a chapter never share a scroll identity")
    }

    /// The reveal is MINIMAL and a fixed point: nothing for a row wholly in
    /// view (half-point tolerance); the top for a row above; the foot for a
    /// row below; a row taller than the list shows its top and then asks
    /// nothing; an unmeasured list asks nothing.
    @Test func theRevealIsMinimalAndAFixedPoint() {
        let viewport: CGFloat = 400
        #expect(BookNavigatorFollow.reveal(top: 0, height: 24, viewport: viewport) == nil)
        #expect(BookNavigatorFollow.reveal(top: 376, height: 24, viewport: viewport) == nil, "flush at the foot")
        #expect(BookNavigatorFollow.reveal(top: -0.4, height: 24, viewport: viewport) == nil, "layout noise")
        #expect(BookNavigatorFollow.reveal(top: -12, height: 24, viewport: viewport) == .top)
        #expect(BookNavigatorFollow.reveal(top: -900, height: 24, viewport: viewport) == .top)
        #expect(BookNavigatorFollow.reveal(top: 390, height: 24, viewport: viewport) == .bottom)
        #expect(BookNavigatorFollow.reveal(top: 2_000, height: 30, viewport: viewport) == .bottom)
        #expect(BookNavigatorFollow.reveal(top: 120, height: 500, viewport: viewport) == .top,
                "a row taller than the list: its top")
        #expect(BookNavigatorFollow.reveal(top: 0, height: 500, viewport: viewport) == nil,
                "…and from there, nothing more")
        #expect(BookNavigatorFollow.reveal(top: -50, height: 24, viewport: 0) == nil, "unmeasured")
        // Where `.top` lands it (top 0) and `.bottom` lands it (bottom at the
        // foot), the rule asks nothing more.
        #expect(BookNavigatorFollow.reveal(top: 0, height: 30, viewport: viewport) == nil)
        #expect(BookNavigatorFollow.reveal(top: viewport - 30, height: 30, viewport: viewport) == nil)
    }

    #if DEBUG
    /// **The follow is the Open list's own** (`SidebarLayout.SectionFollow`):
    /// following from the first highlighted row; a hand scroll (interacting,
    /// decelerating) pauses it — a resize and the same row moving then change
    /// nothing; the app's own phases never pause it; a NEW highlighted row is
    /// the act that follows again.
    @MainActor
    @Test func theFollowIsTheOpenListsOwnAct() {
        let memory = BookNavigatorFollowMemory()
        var states: [BookNavigatorFollowState] = []
        memory.report = { states.append($0) }
        memory.listResized(400)
        memory.highlightedRowMoved("nav-note-a", top: 900, height: 24)
        #expect(states.last?.following == true, "a list follows from its first highlighted row")
        #expect(states.last?.rowID == "nav-note-a")
        #expect(states.last?.rowIsInView == false, "the premise: the row is below the list's foot")

        memory.phase(.animating)
        #expect(states.last?.following == true, "the app's own animated scroll is not her hand")
        memory.phase(.interacting)
        #expect(states.last?.following == false, "her hand on the list pauses the follow")
        memory.phase(.idle)
        #expect(states.last?.following == false, "her scroll's END does not resume it")
        memory.listResized(300)
        memory.highlightedRowMoved("nav-note-a", top: 950, height: 24)
        #expect(states.last?.following == false,
                "a resize and the same row moving never pull it back")

        memory.highlightedRowMoved("nav-note-b", top: 40, height: 24)
        #expect(states.last?.following == true, "a new highlighted row is the act: follow again")
        #expect(states.last?.rowID == "nav-note-b")
        memory.phase(.decelerating)
        #expect(states.last?.following == false, "momentum is her hand too")
    }
    #endif
}

// MARK: - VX-645 (A-648-8) — the pair the navigator marks, mode by mode

@MainActor
@Suite("VX-645 — the navigator's viewed pair in every mode (A-648-8)")
struct BookNavigatorViewedPairTests {
    /// Four notes, two chapters (X: a, c · Y: b · d unfiled).
    private func withBook(
        _ body: @MainActor (BookViewModel, BookStructureModel, [String], [String]) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator { Date(timeIntervalSince1970: 1_782_864_000) }
            // w2a's red (the fixture's, never the code's): `createSection`
            // mints its fractional position with the jitter
            // `FractionalIndex` draws from this dependency, and a test
            // context refuses the live default — seeded, as every sibling
            // fixture does (`BookNoteStepTests`' 563).
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 645))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            let reading = try ops.createReading(name: "viewed", kind: .book)
            var ids: [String] = []
            for title in ["a", "b", "c", "d"] {
                let post = try ops.createPost(title: title)
                try ops.addPostToReading(post.id, to: reading.id)
                ids.append(post.id)
            }
            let x = try ops.createSection(in: reading.id, name: "X")
            let y = try ops.createSection(in: reading.id, name: "Y")
            let model = BookViewModel(session: session, readingID: reading.id)
            await model.adopt(try await db.read { [id = reading.id] in
                try Queries.assembleReading($0, readingID: id)
            })
            let structure = BookStructureModel(session: session, readingID: reading.id)
            structure.adopt(.init(
                reading: try await db.read { try Queries.reading($0, id: reading.id) },
                sections: [x, y], deletedSections: [],
                assignments: [ids[0]: x.id, ids[2]: x.id, ids[1]: y.id]))
            try await body(model, structure, ids, [x.id, y.id])
        }
    }

    @Test func eachModeNamesItsOwnViewedNoteAndItsChapter() async throws {
        try await withBook { model, structure, ids, sections in
            let (a, b, c, d) = (ids[0], ids[1], ids[2], ids[3])
            let chapterOf: (String) -> String? = { structure.chapterID(of: $0) }
            #expect(structure.chapterID(of: a) == sections[0] && structure.chapterID(of: b) == sections[1])
            #expect(structure.chapterID(of: d) == nil, "unfiled: no chapter")
            @MainActor func pair(_ mode: BookStructureModel.ViewMode,
                      _ form: BookStructureModel.ReadForm = .flow) -> BookOutlineViewed.Pair {
                model.navigatorViewedPair(mode: mode, readForm: form, chapterOf: chapterOf)
            }

            // Outline and Read ▸ Scroll: each its own follower's slot.
            model.noteOutlineViewed(.init(sectionID: sections[0], postID: c))
            model.noteFlowViewed(.init(sectionID: sections[1], postID: b))
            #expect(pair(.outline) == .init(sectionID: sections[0], postID: c))
            #expect(pair(.read, .flow) == .init(sectionID: sections[1], postID: b),
                    "Read ▸ Scroll: the flow's follower, never the Outline's slot")

            // Read ▸ Pages: the note the reader shows, and its chapter.
            model.focus(a)
            model.notePagedAnchor(c)
            #expect(pair(.read, .pages) == .init(sectionID: sections[0], postID: c),
                    "Pages: the shown note — never the focused one (a)")
            model.notePagedAnchor(d)
            #expect(pair(.read, .pages) == .init(sectionID: nil, postID: d), "an unfiled page")

            // The spread: its LEFT page, and its chapter.
            model.openSpread(leftIndex: 1)
            #expect(model.leftPage?.postID == b)
            #expect(pair(.spread) == .init(sectionID: sections[1], postID: b))

            // Index: nothing (its navigator is hidden).
            #expect(pair(.index) == .nothingViewed)

            // The slots are their own: the Outline leaving clears its slot,
            // never the flow's.
            model.noteOutlineViewed(.nothingViewed)
            #expect(pair(.read, .flow).postID == b)
        }
    }
}
