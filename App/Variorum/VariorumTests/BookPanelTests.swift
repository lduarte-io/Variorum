//
//  BookPanelTests.swift
//  VariorumTests
//
//  13i-d U2 — THE BOOK PANEL (her round-5 design; the sitting record §15's
//  13i-d line, §20's remove doors). What is pinned: the pure brain (which
//  book shows, the table of contents, the menu twins' targets, every drop's
//  plan through the book view's own planners), the acts over the EXISTING
//  ops against a real store (the drags and their menu twins), a finished
//  book's refusal in words, the remove/release road with its receipt, the
//  click-through riding the ascent road to the book, the door table and the
//  registry declarations. How it LOOKS is the batch's screenshot walk.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - Fixtures

private let stamp = Date(timeIntervalSince1970: 1_782_864_000)

private func reading(_ id: String, _ name: String, kind: ReadingKind = .book) -> Reading {
    Reading(id: id, name: name, kind: kind, createdAt: stamp, updatedAt: stamp)
}

private func section(_ id: String, _ name: String, _ position: String) -> ReadingSection {
    ReadingSection(id: id, readingId: "b", name: name, position: position,
                   createdAt: stamp, updatedAt: stamp)
}

private func entry(_ id: String, _ title: String) -> Queries.ReadingEntry {
    Queries.ReadingEntry(postID: id, title: title, entryDate: nil, sectionPath: nil)
}

// MARK: - The pure brain

@Suite("Book Panel — the pure brain (13i-d U2)")
struct BookPanelBrainTests {
    /// WHICH book shows: her switcher choice while it is still one of the
    /// note's books; else the chooser's first (the session's most recent
    /// book — the one she came from). A gathering is never a switcher row.
    @Test func theShownBookIsTheChoiceElseTheRecentBook() {
        let a = reading("a", "Alpha"), b = reading("b", "Beta"), c = reading("c", "Gamma")
        let g = reading("g", "Gathered", kind: .gathering)
        let all = [a, b, c, g]
        #expect(BookPanelBrain.switcherBooks(all, recentlyVisited: []).map(\.id) == ["a", "b", "c"],
                "books only, by name")
        #expect(BookPanelBrain.switcherBooks(all, recentlyVisited: ["c"]).map(\.id) == ["c", "a", "b"],
                "the book she came from leads")
        #expect(BookPanelBrain.shownBook(all, chosen: nil, recentlyVisited: ["b"])?.id == "b")
        #expect(BookPanelBrain.shownBook(all, chosen: "c", recentlyVisited: ["b"])?.id == "c",
                "her choice wins while it stands")
        #expect(BookPanelBrain.shownBook(all, chosen: "gone", recentlyVisited: [])?.id == "a",
                "a choice the note left falls back")
        #expect(BookPanelBrain.shownBook(all, chosen: "g", recentlyVisited: [])?.id == "a",
                "a gathering is never shown as the book")
        #expect(BookPanelBrain.shownBook([g], chosen: nil, recentlyVisited: []) == nil,
                "in no book ⇒ no book")
    }

    /// The navigator's grouping exactly: chapters in order with their notes
    /// nested, the row-8 collapse (a chapter whose one note says its name is
    /// ONE line), and the stragglers under "unfiled" — which only a chaptered
    /// book draws.
    @Test func theTableOfContentsIsTheNavigatorsGrouping() {
        let one = section("s1", "Beginnings", "a")
        let two = section("s2", "The Storm", "b")
        let e1 = entry("p1", "first"), e2 = entry("p2", "second")
        let e3 = entry("p3", "The Storm"), e4 = entry("p4", "loose")
        let groups = BookStructureModel.grouped(
            entries: [e1, e2, e3, e4], sections: [one, two],
            assignments: ["p1": "s1", "p2": "s1", "p3": "s2"])
        #expect(BookPanelBrain.lines(groups) == [
            .chapter(one, collapsed: nil), .note(e1, indented: true), .note(e2, indented: true),
            .chapter(two, collapsed: e3),
            .unfiled, .note(e4, indented: false),
        ])
        // A chapterless book: notes only, no "unfiled" heading.
        let flat = BookStructureModel.grouped(entries: [e1, e2], sections: [], assignments: [:])
        #expect(BookPanelBrain.lines(flat) == [.note(e1, indented: false), .note(e2, indented: false)])
    }

    /// Move Up / Move Down (the twin of a neighbour drop): within the note's
    /// own group, and only where the book's MANUAL order is what she sees.
    @Test func noteMovesStayInsideTheGroupAndOnlyInManualOrder() {
        let one = section("s1", "one", "a"), two = section("s2", "two", "b")
        let groups = BookStructureModel.grouped(
            entries: [entry("p1", "a"), entry("p2", "b"), entry("p3", "c")],
            sections: [one, two], assignments: ["p1": "s1", "p2": "s1", "p3": "s2"])
        #expect(BookPanelBrain.noteMove("p1", up: true, groups: groups, manualOrder: true) == nil)
        #expect(BookPanelBrain.noteMove("p1", up: false, groups: groups, manualOrder: true)
                == .after("p2"))
        #expect(BookPanelBrain.noteMove("p2", up: true, groups: groups, manualOrder: true)
                == .before("p1"))
        #expect(BookPanelBrain.noteMove("p2", up: false, groups: groups, manualOrder: true) == nil,
                "never across a chapter boundary — that is Move to Chapter")
        #expect(BookPanelBrain.noteMove("p1", up: false, groups: groups, manualOrder: false) == nil,
                "a stamp order shows no hand position (P-2)")
    }

    @Test func chapterMovesMirrorTheBookViewsRule() {
        let sections = [section("s1", "one", "a"), section("s2", "two", "b"), section("s3", "three", "c")]
        #expect(BookPanelBrain.chapterMove("s1", up: true, sections: sections) == nil)
        #expect(BookPanelBrain.chapterMove("s2", up: true, sections: sections) == .before("s1"))
        #expect(BookPanelBrain.chapterMove("s2", up: false, sections: sections) == .after("s3"))
        #expect(BookPanelBrain.chapterMove("s3", up: false, sections: sections) == nil)
    }

    /// Every drop resolves through the book view's OWN planners onto the
    /// existing ops — and the no-op drops do nothing.
    @Test func everyDropResolvesThroughTheBookViewsPlanners() {
        let sections = [section("s1", "one", "a"), section("s2", "two", "b"), section("s3", "three", "c")]
        let groups = BookStructureModel.grouped(
            entries: [entry("p1", "a"), entry("p2", "b"), entry("p3", "c"), entry("p4", "d")],
            sections: sections, assignments: ["p1": "s1", "p2": "s1", "p3": "s2"])
        func plan(_ drag: BookPanelDrag, _ site: BookPanelBrain.DropSite, manual: Bool = true)
            -> BookPanelBrain.DropPlan? {
            BookPanelBrain.dropPlan(drag, onto: site, groups: groups, sections: sections,
                                    manualOrder: manual)
        }
        // A note onto a note: that note's chapter, right above it.
        #expect(plan(.note("p3"), .note("p1")) == .file(postID: "p3", sectionID: "s1", before: "p1"))
        #expect(plan(.note("p3"), .note("p1"), manual: false)
                == .file(postID: "p3", sectionID: "s1", before: nil),
                "a stamp order files the chapter and leaves the order alone")
        #expect(plan(.note("p1"), .note("p1")) == nil, "onto itself: nothing")
        // A note onto a chapter heading: that chapter, at its top.
        #expect(plan(.note("p4"), .chapter("s2")) == .file(postID: "p4", sectionID: "s2", before: "p3"))
        // A note onto "unfiled": out of every chapter.
        #expect(plan(.note("p1"), .unfiled) == .file(postID: "p1", sectionID: nil, before: nil))
        // A chapter onto a chapter: before it.
        #expect(plan(.chapter("s3"), .chapter("s1")) == .moveChapter(sectionID: "s3", to: .before("s1")))
        #expect(plan(.chapter("s1"), .chapter("s2")) == nil, "onto the boundary it sits at")
        #expect(plan(.chapter("s2"), .chapter("s2")) == nil, "onto itself")
        // A chapter onto "unfiled": the end — unless it is already last.
        #expect(plan(.chapter("s1"), .unfiled) == .moveChapter(sectionID: "s1", to: .end))
        #expect(plan(.chapter("s3"), .unfiled) == nil)
        // A chapter onto a note row: the nearest boundary (the navigator's rule).
        #expect(plan(.chapter("s3"), .note("p1")) == .moveChapter(sectionID: "s3", to: .before("s1")))
    }

    @Test func theWordsAreSaidOnceAndTheGatheringsLineIsInvisibleAtZero() {
        #expect(BookPanelCopy.gatheringsLine(count: 0) == nil)
        #expect(BookPanelCopy.gatheringsLine(count: 1) == "appears in 1 gathering")
        #expect(BookPanelCopy.gatheringsLine(count: 3) == "appears in 3 gatherings")
        var book = reading("b", "Book")
        #expect(BookPanelCopy.stateWords(book) == nil)
        book.owned = true
        book.locked = true
        #expect(BookPanelCopy.stateWords(book) == "owned \u{B7} finished")
        book.sealedAt = stamp
        #expect(BookPanelCopy.stateWords(book) == "owned \u{B7} sealed")
    }

    /// The private token round-trips, and no foreign kind decodes.
    @Test func theDragTokenIsPrivateAndRoundTrips() {
        #expect(BookPanelDragToken(.note("p1")).drag == .note("p1"))
        #expect(BookPanelDragToken(.chapter("s1")).drag == .chapter("s1"))
        #expect(BookcaseDragToken(.book("b")).drag != nil, "the Bookcase's own token is a different type")
    }
}

// MARK: - The door and the declarations (P-1)

@MainActor
@Suite("Book Panel — the door and its declarations (13i-d U2)")
struct BookPanelDeclarationTests {
    /// The book door is drawn only while the note has a book, and FIRST —
    /// the cluster trails right, so the three standing doors never move.
    @Test func theBookDoorLeadsTheClusterOnlyWhileMembered() {
        #expect(PostDetailView.shownInspectorDoors(membered: true).map(\.panel)
                == [.book, .tray(revealBlockID: nil), .scraps, .references])
        #expect(PostDetailView.shownInspectorDoors(membered: false).map(\.panel)
                == [.tray(revealBlockID: nil), .scraps, .references])
        #expect(PostDetailView.bookPanelDoor.title == BookPanelCopy.doorTitle)
        #expect(!PostDetailView.bookPanelDoor.help.isEmpty)
    }

    @Test func everyPanelDoorIsDeclaredWhereItIsRendered() {
        #expect(CapabilityRegistry.capability(.showBookPanel).doors == [.surface])
        #expect(PostDetailView.surfaceCapabilities.contains(.showBookPanel))
        for id: CapabilityID in [
            .fileNoteInChapter, .moveNoteUpInBook, .moveNoteDownInBook,
            .moveChapterUpInBook, .moveChapterDownInBook,
        ] {
            // 13i-d U3 (A JUSTIFIED EDIT — F-U2-3, the adjudication after U2:
            // the book view's own chapter/move doors join the registry as these
            // acts): "Move to Chapter ▸" gained the book Index row's ⋯ menu as a
            // second renderer, whose doors are `.surface` (the remove door's
            // precedent there) — so that one act carries both families.
            let expected: Set<Capability.Door> = id == .fileNoteInChapter
                ? [.contextMenu, .surface] : [.contextMenu]
            #expect(CapabilityRegistry.capability(id).doors == expected, "\(id)")
            #expect(CapabilityRegistry.capability(id).scope == .book, "\(id)")
            #expect(BookPanelView.contextMenuCapabilities.contains(id), "\(id)")
        }
        #expect(BookPanelView.contextMenuCapabilities.contains(.removeFromBook))
        // 13n-c U4 (A JUSTIFIED EDIT — a new act on the same renderer): a
        // note row's pending-ask glyph (`.mcpOpenAsk`, arrival X).
        // VX-268 (A JUSTIFIED EDIT, the same class — VX-281 U2, her kickoff
        // call "the Book Panel's rows … IN"): a note row's ONE shared icon
        // (`.mcpShowSharing`) and its popover's Change… / Revoke.
        #expect(BookPanelView.surfaceCapabilities == [
            .openBookAtNote, .removeRuleTag, .mcpOpenAsk,
            .mcpShowSharing, .mcpChangeGrant, .mcpRevokeGrant,
        ])
        #expect(CapabilityRegistry.capability(.moveNoteUpInBook).verb == BookPanelCopy.moveNoteUpVerb)
    }
}

// MARK: - The acts, against a real store

@MainActor
@Suite("Book Panel — the acts over the existing ops (13i-d U2)", .serialized)
struct BookPanelActingTests {
    /// A world: a book with two chapters — n1, n2 in "one", n3 in "two" —
    /// and a held panel model on n1's side.
    private struct World {
        let session: AppSession
        let db: AppDatabase
        let book: Reading
        let one: ReadingSection
        let two: ReadingSection
        let n1: String, n2: String, n3: String
    }

    private func withWorld(_ body: @MainActor (World) async throws -> Void) async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(stamp)
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            let book = try ops.createReading(name: "Orbit", kind: .book)
            let one = try ops.createSection(in: book.id, name: "one")
            let two = try ops.createSection(in: book.id, name: "two")
            var ids: [String] = []
            for title in ["n1", "n2", "n3"] {
                let note = try ops.createPost(title: title)
                try ops.addPostToReading(note.id, to: book.id)
                ids.append(note.id)
            }
            try ops.assignPostToSection(ids[0], in: book.id, section: one.id)
            try ops.assignPostToSection(ids[1], in: book.id, section: one.id)
            try ops.assignPostToSection(ids[2], in: book.id, section: two.id)
            try await body(World(session: session, db: db, book: book, one: one, two: two,
                                 n1: ids[0], n2: ids[1], n3: ids[2]))
        }
    }

    private func order(_ world: World) async throws -> [String] {
        try await world.db.read { try Queries.assembleReading($0, readingID: world.book.id) }
            .map(\.postID)
    }

    private func chapterOf(_ world: World, _ postID: String) async throws -> String? {
        try await world.db.read { try Queries.sectionAssignments($0, readingID: world.book.id) }[postID]
    }

    /// The MENU TWINS — Move Up, Move to Chapter, Move Chapter Up — each
    /// lands through the existing op, and the held contents follow.
    @Test func theMenuTwinsMoveTheBookThroughTheExistingOps() async throws {
        try await withWorld { world in
            let model = BookPanelModel(session: world.session, postID: world.n1)
            let task = Task { await model.observe(bookID: world.book.id) }
            defer { task.cancel() }
            try await settle { model.snapshot(for: world.book.id)?.entries.count == 3 }

            await model.move(world.n2, in: world.book, up: true)
            try await settle { try await self.order(world).prefix(2) == [world.n2, world.n1] }

            await model.file(world.n1, in: world.book, chapter: world.two.id)
            #expect(try await chapterOf(world, world.n1) == world.two.id)

            await model.moveChapter(world.two.id, in: world.book, up: true)
            #expect(try await world.db.read {
                try Queries.readingSections($0, readingID: world.book.id)
            }.map(\.id) == [world.two.id, world.one.id])
            try await settle {
                model.snapshot(for: world.book.id)?.sections.map(\.id) == [world.two.id, world.one.id]
            }
            #expect(world.session.status.current == nil, "structure moves are silent")
        }
    }

    /// The DRAGS — a note onto another chapter's note, a chapter onto a
    /// chapter — resolve to the same ops their twins call.
    @Test func panelDropsFileAndReorderThroughTheSameOps() async throws {
        try await withWorld { world in
            let model = BookPanelModel(session: world.session, postID: world.n1)
            let task = Task { await model.observe(bookID: world.book.id) }
            defer { task.cancel() }
            try await settle { model.snapshot(for: world.book.id)?.entries.count == 3 }

            #expect(await model.drop(.note(world.n3), onto: .note(world.n1), in: world.book))
            #expect(try await chapterOf(world, world.n3) == world.one.id, "filed into n1's chapter")
            #expect(try await order(world).first == world.n3, "…right above n1")

            try await settle { model.snapshot(for: world.book.id)?.assignments[world.n3] == world.one.id }
            #expect(await model.drop(.chapter(world.two.id), onto: .chapter(world.one.id), in: world.book))
            #expect(try await world.db.read {
                try Queries.readingSections($0, readingID: world.book.id)
            }.map(\.id) == [world.two.id, world.one.id])

            #expect(await model.drop(.note(world.n1), onto: .note(world.n1), in: world.book) == false,
                    "a note dropped on itself does nothing")
        }
    }

    /// A FINISHED book: the op refuses, and the door SAYS so with the road
    /// (#25(b)'s precedent — the book view's own); nothing moves.
    @Test func aFinishedBookRefusesInWordsAndNothingMoves() async throws {
        try await withWorld { world in
            try world.session.operations.lockReading(world.book.id)
            let finished = try #require(try await world.db.read {
                try Queries.reading($0, id: world.book.id)
            })
            let model = BookPanelModel(session: world.session, postID: world.n1)
            let task = Task { await model.observe(bookID: world.book.id) }
            defer { task.cancel() }
            try await settle { model.snapshot(for: world.book.id)?.entries.count == 3 }
            let before = try await order(world)

            await model.file(world.n3, in: finished, chapter: world.one.id)
            let refusal = try #require(world.session.status.current?.text)
            #expect(refusal.contains("Orbit") && refusal.contains("reopen"), "\(refusal)")
            #expect(try await chapterOf(world, world.n3) == world.two.id)
            #expect(try await order(world) == before)
        }
    }

    /// The remove door (§20): one road, the book's word, a receipt spoken.
    @Test func removeFromTheRowMenuIsTheOneRoadWithItsReceipt() async throws {
        try await withWorld { world in
            let model = BookPanelModel(session: world.session, postID: world.n1)
            await model.remove(world.n2, from: world.book)
            let remaining = try await order(world)
            #expect(remaining == [world.n1, world.n3])
            #expect(world.session.status.spoken?.text
                    == RemoveFromBookCopy.receipt(book: "Orbit", owned: false, bookless: true))
        }
    }

    /// THE CLICK-THROUGH: a row's click is the ascent — the same broadcast
    /// the chip's link makes, which the shell turns into "open the book,
    /// land on the note" (`RootView.openBook` → the parked `BookAscent` the
    /// book view consumes). Never a second landing mechanism.
    @Test func theClickThroughRidesTheAscentRoad() async throws {
        try await withWorld { world in
            let received = LockIsolated<[[String: String]]>([])
            let token = NotificationCenter.default.addObserver(
                forName: .variorumOpenBookAtPost, object: nil, queue: nil
            ) { note in
                guard let book = note.userInfo?["bookID"] as? String,
                      let post = note.userInfo?["postID"] as? String else { return }
                received.withValue { $0.append(["bookID": book, "postID": post]) }
            }
            defer { NotificationCenter.default.removeObserver(token) }

            let model = BookPanelModel(session: world.session, postID: world.n1)
            model.open(book: world.book, at: world.n3)
            #expect(received.value == [["bookID": world.book.id, "postID": world.n3]])
        }
    }

    /// …and END TO END: the shell takes the panel's click to the BOOK,
    /// through the one adoption door (⌘[ returns to the note).
    @Test func theClickThroughLandsTheBookInThePane() async throws {
        try await withWorld { world in
            let router = ShellRouter()
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 1100, height: 700),
                styleMask: [.titled], backing: .buffered, defer: true)
            window.contentView = NSHostingView(rootView: RootView(session: world.session, router: router))
            window.orderFront(nil)
            defer { window.orderOut(nil) }
            for _ in 0..<8 { try? await Task.sleep(for: .milliseconds(25)) }

            router.workspace.select(.post(world.n1))
            BookPanelModel(session: world.session, postID: world.n1)
                .open(book: world.book, at: world.n3)
            for _ in 0..<40 {
                try? await Task.sleep(for: .milliseconds(25))
                if router.workspace.selections[router.workspace.focusedPane]
                    == .reading(world.book.id) { break }
            }
            #expect(router.workspace.selections[router.workspace.focusedPane]
                    == .reading(world.book.id), "the pane went to the book")
            #expect(router.workspace.history().origin == .post(world.n1),
                    "…through the one adoption door, so ⌘[ comes back to the note")
        }
    }
}

/// Poll until a condition holds (never a sync RunLoop pump — the standing
/// harness rule for settle hops through an observation).
@MainActor
private func settle(
    within seconds: Double = 3, _ condition: () async throws -> Bool
) async throws {
    let deadline = Date().addingTimeInterval(seconds)
    while Date() < deadline {
        if try await condition() { return }
        try await Task.sleep(nanoseconds: 10_000_000)
    }
    #expect(try await condition(), "condition never settled")
}
