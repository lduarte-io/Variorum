//
//  BookListModeTests.swift
//  VariorumTests
//
//  **VX-1084 (the VX-1036 run, batch 3) — the book's List mode**, her R-1036-29
//  ("List as a fifth mode") and R-1036-38 ("List is rows only; outline is the
//  cards"); the round-2 mockup's frame 9. Four suites:
//  - the List's groups (PURE — `BookListRows`): the Outline's own assembly
//    regrouped under headings, each counted;
//  - the fifth mode's arm at every mode rule (pure): the tab table, the note
//    box, the click-over's place, the stepper, the open door, the navigator's
//    act and marks, the mint's choreography, the tagging act's;
//  - the List's selection and place on the book's model (state);
//  - the List MOUNTED (hosted): a reveal selects and spends itself, the rows
//    realized stay ∝ the viewport on a 300-note book, the edited stamps are
//    the Library's, the chapter door's renderers share the one declaration.
//

import AppKit
import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The groups (pure)

@Suite("VX-1084 — the List's groups (pure)")
struct BookListRowsTests {
    private static let day = Date(timeIntervalSince1970: 1_782_864_000)

    private static func section(_ id: String, _ name: String) -> ReadingSection {
        ReadingSection(id: id, readingId: "b", name: name, position: id, createdAt: day, updatedAt: day)
    }

    private static func entry(_ id: String, path: String? = nil, pinned: Bool = false) -> Queries.ReadingEntry {
        Queries.ReadingEntry(postID: id, title: "note \(id)", entryDate: nil, sectionPath: path, pinned: pinned)
    }

    /// A chaptered book: the chapters in their order, an EMPTY chapter kept
    /// with its zero, "unfiled" last — each heading counting the notes under
    /// it, the notes in the book's own order (a pinned note leads its chapter
    /// because the entries carry it first — the List never re-sorts).
    @Test func aChapteredBookListsItsChaptersInOrderWithCountsAndUnfiledLast() {
        let plot = Self.section("s1", "getting the plot")
        let wednesday = Self.section("s2", "wednesday")
        let spring = Self.section("s3", "spring")
        let entries = [
            Self.entry("pinned-in-spring", pinned: true), Self.entry("a"), Self.entry("b"),
            Self.entry("c"), Self.entry("stray"),
        ]
        // `BookStructureModel.grouped`'s shape: every chapter in order (an
        // empty one kept), each with its members in the entries' order, the
        // unfiled last.
        let grouped: [(section: ReadingSection?, entries: [Queries.ReadingEntry])] = [
            (plot, [entries[1], entries[2]]), (wednesday, []), (spring, [entries[0], entries[3]]),
            (nil, [entries[4]]),
        ]
        let groups = BookListRows.groups(rows: BookOutlineRows.rows(grouped: grouped))
        #expect(groups.map(\.heading?.kind) == [.chapter(plot), .chapter(wednesday), .chapter(spring), .unfiled])
        #expect(groups.map(\.heading?.count) == [2, 0, 2, 1])
        #expect(groups.map { $0.entries.map(\.postID) } == [["a", "b"], [], ["pinned-in-spring", "c"], ["stray"]])
        #expect(Set(groups.map(\.id)).count == groups.count, "each group has its own anchor")
    }

    /// A gathering grouped by a tag root: a heading where the path changes.
    @Test func aGatheringsTagPathsHeadTheirRuns() {
        let entries = [
            Self.entry("1", path: "week/monday"), Self.entry("2", path: "week/monday"),
            Self.entry("3", path: "week/tuesday"),
        ]
        let groups = BookListRows.groups(rows: BookOutlineRows.rows(flat: entries))
        #expect(groups.map(\.heading?.kind) == [.tagPath("week/monday"), .tagPath("week/tuesday")])
        #expect(groups.map(\.heading?.count) == [2, 1])
    }

    /// A flat book: one headless group, every note in the book's order.
    @Test func aFlatBookIsOneHeadlessGroup() {
        let groups = BookListRows.groups(rows: BookOutlineRows.rows(flat: [Self.entry("x"), Self.entry("y")]))
        #expect(groups.count == 1)
        #expect(groups.first?.heading == nil)
        #expect(groups.first?.entries.map(\.postID) == ["x", "y"])
        #expect(BookListRows.groups(rows: []).isEmpty, "an empty book lists nothing")
    }
}

// MARK: - The fifth mode at every mode rule (pure)

@MainActor
@Suite("VX-1084 — the fifth mode, List, at every mode rule")
struct BookListModeRulesTests {
    /// R-1036-29: outline · list · index · book · read — List second.
    @Test func theRowReadsOutlineListIndexBookRead() {
        #expect(BookView.tabOrder == [.outline, .list, .index, .spread, .read])
        #expect(BookView.tabOrder.map(BookView.tabLabel) == ["Outline", "List", "Index", "Book", "Read"])
        #expect(BookView.tourMode(.list) == .list, "the tour sees List as its own mode")
    }

    /// BL-3: a click selects the note into the sidebar's box; List mounts no
    /// editor, so nothing is ever live there.
    @Test func theBoxShowsInListWithTheListsOwnSelectionAndNothingLive() {
        #expect(BookNoteBox.shows(mode: .list))
        #expect(BookNoteBox.selectedPost(
            mode: .list, focusedPostID: "focused", spreadPostIDs: [], indexPostID: "indexed",
            listPostID: "listed") == "listed")
        #expect(BookNoteBox.selectedPost(
            mode: .list, focusedPostID: "focused", spreadPostIDs: [], indexPostID: "indexed") == nil,
            "nothing selected in the List, nothing selected in the box")
        #expect(BookNoteBox.livePost(mode: .list, liveFocusedPostID: "x", indexLivePostID: "y") == nil)
        #expect(BookNoteBox.quietReceiptHome(
            mode: .list, pagedRead: false, modeBarShown: true, box: nil) == .pageFoot)
    }

    /// The click-over: List's place is its selection (else where she arrived),
    /// and it carries the note alone — List has no caret.
    @Test func listsPlaceIsItsSelectionAndCarriesNoBlock() {
        var place = BookAnchor.Place(focusedPostID: "f", standingPostID: "standing")
        #expect(BookAnchor.currentPost(mode: .list, readForm: .flow, place: place) == "standing")
        place.listPostID = "picked"
        place.livePostID = "picked"
        place.liveBlockID = "block"
        let landing = BookAnchor.landing(mode: .list, readForm: .flow, place: place)
        #expect(landing == LandingTarget(postID: "picked"), "the note alone — no block rides out of List")
    }

    /// The stepper's contract names Outline, Read and the spread — List is not
    /// a stepping surface (Index's posture, PROVISIONAL P-1036-B3-3); its open
    /// door is a plain open.
    @Test func listNeitherStepsNorCarriesACaretToTheOpenDoor() {
        #expect(!BookNoteStep.steps(in: .list))
        #expect(BookNoteStep.viewedNote(
            mode: .list, readForm: .flow,
            facts: .init(outlineViewed: "o", spreadLeft: "o", pagedShown: "o", flowViewed: "o"),
            order: ["o"]) == nil)
        #expect(BookOpenDoor.place(
            of: "x", mode: .list, live: .init(editorPostID: "x", editorCaret: .init(blockID: "b", offsetInBlock: 2)))
            == nil)
    }

    /// The navigator in List: a note row selects it there (List takes the
    /// reveal), and the marks follow the List's selected pair.
    @Test func theNavigatorSelectsInListAndMarksTheSelection() {
        #expect(BookOutlineRows.navigatorNoteRowAct(mode: .list, readForm: .flow) == .showInList)
        #expect(BookNavigatorMark.note(
            mode: .list, postID: "x", focusedPostID: nil, viewedPostID: "x", spreadPostIDs: []))
        #expect(!BookNavigatorMark.note(
            mode: .list, postID: "x", focusedPostID: "x", viewedPostID: nil, spreadPostIDs: []),
            "the focus is the Outline's, not the List's mark")
        #expect(BookNavigatorMark.chapter(mode: .list, sectionID: "s", viewedSectionID: "s"))
    }

    /// N-1's letter in a mode with no editor (PROVISIONAL P-1036-B3-2): a mint
    /// door in List turns to the Outline, as Read's does; the tagging chord
    /// turns to the Outline's card field too (P-1036-B2-4's road).
    ///
    /// A JUSTIFIED EDIT (the VX-1036 ladder, round 1 — R1-3): the Index turns
    /// too now (it has no block to make a newborn note live on —
    /// `BookMintLandingTests.aMintPressedInTheIndexTurnsToTheOutlineAndArrivesLive`),
    /// so it left the loop of modes that stay; the List's claim is unchanged.
    @Test func aMintAndTheTaggingActTurnListToTheOutline() {
        #expect(BookReadMint.turnsToOutline(.list))
        #expect(BookReadMint.turnsToOutline(.read))
        #expect(BookReadMint.turnsToOutline(.index), "R1-3")
        for mode in [BookStructureModel.ViewMode.outline, .spread] {
            #expect(!BookReadMint.turnsToOutline(mode), "\(mode)")
        }
        #expect(BookTagChord.act(mode: .list, position: .allTags).switchesToOutline)
    }

    /// The chapter's door is ONE act with several renderers (P-1): the page
    /// heading's "+ new note", the List's headings, the navigator row's "+".
    @Test func theChapterDoorIsDeclaredOnce() {
        #expect(BookView.surfaceCapabilities.filter { $0 == .newNoteInChapter }.count == 1)
        #expect(CapabilityRegistry.capability(.newNoteInChapter).verb == ChapterMintDoorCopy.verb)
    }
}

// MARK: - The List's selection and place (state)

@MainActor
@Suite("VX-1084 — the List's selection and place on the book's model", .serialized)
struct BookListSelectionTests {
    /// A List selection is the box's selected note, the List's place for the
    /// click-over and the navigator's marked pair; switching away carries it.
    @Test func theSelectionIsTheBoxsTheNavigatorsAndTheClickOversPlace() async throws {
        try await withMintLandingBook(posts: 6, chapters: 2) { session, db, readingID, postIDs, sectionIDs in
            let model = BookViewModel(session: session, readingID: readingID)
            await model.adopt(try await db.read { try Queries.assembleReading($0, readingID: readingID) })
            let picked = postIDs[4]
            model.noteListSelection(picked)
            #expect(model.listSelectedPostID == picked)
            #expect(model.anchorPlace.listPostID == picked)
            let pair = model.navigatorViewedPair(mode: .list, readForm: .flow, chapterOf: { _ in sectionIDs[1] })
            #expect(pair.postID == picked && pair.sectionID == sectionIDs[1])
            // List → Outline: the Outline is asked to land on her selection.
            model.carryPlace(from: .list, to: .outline, readForm: .flow)
            #expect(model.pendingReveal == picked)
            #expect(model.standingAnchorPostID == picked)
        }
    }

    /// "Per-book mode memory includes list": the book holds List as its mode
    /// for the mount like any other, and a later row delivery never reseeds it.
    @Test func theBookHoldsListAsItsModeAcrossItsRowsDeliveries() async throws {
        try await withMintLandingBook(posts: 2) { session, db, readingID, _, _ in
            let structure = BookStructureModel(session: session, readingID: readingID)
            let snapshot = BookStructureModel.Snapshot(
                reading: try await db.read { try Queries.reading($0, id: readingID) },
                sections: [], deletedSections: [], assignments: [:])
            structure.adopt(snapshot)
            structure.mode = .list
            structure.adopt(snapshot)
            #expect(structure.mode == .list)
        }
    }
}

// MARK: - The List, mounted

@MainActor
@Suite("VX-1084 — the List, mounted", .serialized)
struct BookListMountedTests {
    static let windowHeight: CGFloat = 700

    private func pump(_ seconds: TimeInterval = 0.02) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    private func settle(
        _ window: NSWindow, _ hosting: NSView, until predicate: () -> Bool = { false }, maxTurns: Int = 60
    ) async {
        for _ in 0..<maxTurns {
            hosting.layoutSubtreeIfNeeded()
            window.layoutIfNeeded()
            window.displayIfNeeded()
            pump()
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
            if predicate() { return }
        }
    }

    private func mountList(
        _ session: AppSession, _ db: AppDatabase, _ readingID: String,
        _ body: @MainActor (BookViewModel, BookStructureModel, NSWindow, NSView) async throws -> Void
    ) async throws {
        let model = BookViewModel(session: session, readingID: readingID)
        await model.adopt(try await db.read { try Queries.assembleReading($0, readingID: readingID) })
        let structure = BookStructureModel(session: session, readingID: readingID)
        structure.adopt(try await db.read { db in
            .init(
                reading: try Queries.reading(db, id: readingID),
                sections: try Queries.readingSections(db, readingID: readingID),
                deletedSections: [],
                assignments: try Queries.sectionAssignments(db, readingID: readingID))
        })
        structure.mode = .list
        let window = NSWindow(
            contentRect: NSRect(x: 60, y: 60, width: 1100, height: Self.windowHeight),
            styleMask: [.titled], backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.appearance = NSAppearance(named: .aqua)
        defer {
            window.orderOut(nil)
            window.contentView = nil
            window.close()
        }
        let hosting = NSHostingView(
            rootView: BookView(session: session, readingID: readingID, model: model, structure: structure)
                .environment(ThemeStore(session: session)))
        hosting.frame = NSRect(x: 0, y: 0, width: 1100, height: Self.windowHeight)
        window.contentView = hosting
        window.makeKeyAndOrderFront(nil)
        await settle(window, hosting, until: { !BookListProbe.appeared.isEmpty })
        try await body(model, structure, window, hosting)
    }

    /// **P1/P3 — the rows realized are the viewport's, never the book's**: a
    /// 300-note book in a 700-pt window realizes a screenful of rows (the
    /// Library's lazy-column engine), not three hundred.
    @Test func a300NoteBookRealizesAViewportOfRows() async throws {
        try await withMintLandingBook(posts: 300, chapters: 6) { session, db, readingID, _, _ in
            #if DEBUG
            BookListProbe.reset()
            try await mountList(session, db, readingID) { model, _, window, hosting in
                await settle(window, hosting)
                #expect(model.entries.count == 300, "non-vacuity: the window holds the whole book")
                let realized = BookListProbe.appeared.count
                #expect(realized > 5, "non-vacuity: the List drew its rows (\(realized))")
                #expect(realized < 80, "rows realized ∝ the viewport, not the book: \(realized) of 300")
                #expect(BookListProbe.rowBodies < 300, "row bodies evaluated: \(BookListProbe.rowBodies)")
            }
            #endif
        }
    }

    /// A reveal (a click-over carried here, a navigator note row) SELECTS the
    /// note in the List and is spent; the box's selected note follows.
    @Test func aRevealSelectsTheNoteAndIsSpent() async throws {
        try await withMintLandingBook(posts: 60, chapters: 3) { session, db, readingID, postIDs, _ in
            #if DEBUG
            BookListProbe.reset()
            try await mountList(session, db, readingID) { model, _, window, hosting in
                let far = postIDs[55]
                model.requestReveal(far)
                await settle(window, hosting, until: { model.listSelectedPostID == far })
                #expect(model.listSelectedPostID == far, "the List selected the revealed note")
                #expect(model.pendingReveal == nil, "the reveal is spent")
                await settle(window, hosting, until: { BookListProbe.appeared.contains(far) })
                #expect(BookListProbe.appeared.contains(far), "…and brought its row into view")
            }
            #endif
        }
    }

    /// The rows' edited stamps are the Library's own (`COALESCE(last_touched_at,
    /// created_at)`), read once for the window — and an edit moves its stamp.
    @Test func theRowsStampsAreTheLibrarysAndFollowAnEdit() async throws {
        try await withMintLandingBook(posts: 3) { session, db, readingID, postIDs, _ in
            let list = BookListModel()
            let reading = Task { await list.track(session: session, postIDs: postIDs) }
            defer { reading.cancel() }
            for _ in 0..<100 where list.edited.count < 3 { try await Task.sleep(for: .milliseconds(10)) }
            let library = try await db.read { try Queries.noteEditedStamps($0, noteIDs: postIDs) }
            #expect(list.edited == library, "the List's stamps are the one read's")
            let before = list.edited[postIDs[0]]
            let take: (id: String, text: String)? = try await db.read { db in
                try Row.fetchOne(db, sql: """
                    SELECT v.id AS id, v.working_text AS text FROM variant v
                    JOIN container_block cb ON cb.block_id = v.block_id AND cb.deleted_at IS NULL
                    WHERE cb.container_id = ? AND v.deleted_at IS NULL
                    """, arguments: [postIDs[0]]).map { ($0["id"], $0["text"]) }
            }
            let found = try #require(take, "the note's take")
            try session.operations.autosave(found.id, text: found.text + " more", charDelta: 5)
            for _ in 0..<100 where list.edited[postIDs[0]] == before { try await Task.sleep(for: .milliseconds(10)) }
            #expect(list.edited[postIDs[0]] != before, "an edit moved the row's stamp")
        }
    }
}

// MARK: - The VX-1036 ladder, round 1 — R1-4: the title's click selects

/// **R1-4 (MINOR; RED ON OLD).** BL-3: "a row's click selects the note … a
/// double-click or ⏎ opens it" — and the row's own hover says "Click to select
/// this note". In the book's List one click on a row's TITLE opened the note:
/// the shared line's title carries its own tap (`CatalogNoteLine.onTitleTap` —
/// the Library's title opens at once, its own model), the List handed it its
/// OPEN act, and a child's tap beats the row's (`rowClick` on the shell never
/// heard a click on the title). The pin mounts ONE row alone in a real window
/// (the `CatalogNoteRowShell` pin's shape — `LibraryRowClickTests`; the whole
/// List under the rig's event pump is the catalog's hang class), wired exactly
/// as `BookListView.row` wires it, and clicks the title for real.
///
/// RED ON OLD: the single click on the title OPENED the note (the landing into
/// Write was asked) instead of selecting it.
@MainActor
@Suite("VX-1036 ladder R1-4 — a List row's title click selects", .serialized)
struct BookListTitleClickTests {
    @MainActor
    final class Opened {
        var ids: [String] = []
    }

    @Test func aClickOnTheTitleSelectsAndADoubleClickOnItOpens() async throws {
        try await withMintLandingBook(posts: 2) { session, db, readingID, postIDs, _ in
            let model = BookViewModel(session: session, readingID: readingID)
            let entries = try await db.read { try Queries.assembleReading($0, readingID: readingID) }
            await model.adopt(entries)
            let structure = BookStructureModel(session: session, readingID: readingID)
            let entry = try #require(entries.first { $0.postID == postIDs[0] })
            let opened = Opened()
            let suite = "BookListTitleClickTests.\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defer { defaults.removePersistentDomain(forName: suite) }
            let tokens = VoiceTokens.fallback(for: .light)
            let rig = BlocksWorkbenchFaceTests.Rig(
                VStack(spacing: 0) {
                    BookListNoteRow(
                        session: session, entry: entry, tokens: tokens,
                        tags: BookCardTagsModel(readingID: readingID, defaults: defaults),
                        list: BookListModel(), selected: false, badge: nil, structure: structure,
                        noteDoors: BookNoteTitleDoors(), noteRoads: BookNoteRoads(),
                        // `BookListView.row`'s own wiring: a select is the
                        // box's selected note; an open selects and takes the
                        // book's one open door (the landing into Write).
                        onSelect: { model.noteListSelection(entry.postID) },
                        onOpen: {
                            model.noteListSelection(entry.postID)
                            opened.ids.append(entry.postID)
                        })
                    Spacer()
                }
                .padding(20))
            defer { rig.close() }
            await rig.poll(timeout: 2) { false }  // let it lay out
            #expect(model.listSelectedPostID == nil, "the premise: nothing selected")

            // On the TITLE's words ("note 0"): the row's leading inset, a few
            // points into the text, on its line.
            let point = rig.windowPoint(CGPoint(
                x: 20 + LibraryListFace.rowInsets.leading + 12,
                y: 20 + LibraryListFace.rowInsets.top + 8))
            rig.send(.leftMouseDown, at: point)
            rig.pump(0.005)
            rig.send(.leftMouseUp, at: point)
            let acted = await rig.poll(timeout: 2) { model.listSelectedPostID != nil || !opened.ids.isEmpty }
            #expect(acted, "the click on the title acted at all")
            #expect(opened.ids.isEmpty, "a single click on the title never opens — no landing asked")
            #expect(model.listSelectedPostID == entry.postID, "…it selects the note")

            // A DOUBLE click on the title — the row's one click brain hears it
            // too — opens the note, once.
            rig.send(.leftMouseDown, at: point, clickCount: 2)
            rig.pump(0.005)
            rig.send(.leftMouseUp, at: point, clickCount: 2)
            #expect(await rig.poll(timeout: 2) { !opened.ids.isEmpty }, "the double opens")
            #expect(opened.ids == [entry.postID], "…the clicked note, once")
        }
    }
}
