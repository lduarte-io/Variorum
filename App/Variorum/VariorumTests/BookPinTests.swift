//
//  BookPinTests.swift
//  VariorumTests
//
//  VX-803 — PINNED NOTES on the book's faces (the B4 fork's ruling, A-808-12 in
//  `notes/plans/fixes/vx-808-arrivals-books.md`). The float itself is the core
//  read's (`Queries.assembleReading` — `MembershipPinOrderTests` pins it); these
//  pin what the faces do with it:
//
//  - (g) THE PIN BOUNDARY IS A GROUP EDGE for every hand-placing door — the one
//    shared drop planner (`BookStructureModel.postDropPlan`, read by the book
//    view and the Book Panel), the Book Panel's Move Up / Move Down and Manage
//    Notes' arrows (`runMove`); a cross-run drop lands at the NEAR EDGE of the
//    dragged note's own run; a drag never pins or unpins (P-808-B4-3). Red on
//    old: `aDropAcrossThePinBoundary…`'s first arm and the model walk land the
//    note inside the OTHER run's positions on the pre-B4 planner.
//  - THE STEPPER: ⌘↑ / ⌘↓ walk the floated order in every mode (her "pins hold
//    EVERYWHERE … and the ⌘↑/⌘↓ stepper alike"), through the modes' own order
//    seam (`BookNoteStepDoor.order`) over a REAL store's assembly.
//  - (h) ONE declaration, `.removeFromBook`'s shape, rendered by the three
//    renderers already in the registry walk; the door body's refusal is the
//    op's, in the book's words.
//
//  New capability: what no pre-B4 code could reach is pinned as the ruled
//  behaviour, not as red-on-old.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

private func entry(_ id: String, pinned: Bool = false) -> Queries.ReadingEntry {
    Queries.ReadingEntry(postID: id, title: id, entryDate: nil, sectionPath: nil, pinned: pinned)
}

private func section(_ id: String, _ position: String) -> ReadingSection {
    ReadingSection(id: id, readingId: "r", name: id, position: position, createdAt: Date(), updatedAt: Date())
}

// MARK: - The pure planners (A-808-12 (g))

@Suite("VX-803 — the pin boundary is a group edge for the hand-placing doors")
struct BookPinBoundaryTests {
    /// A flat manual book shown as `c e | a b d` — c and e pinned.
    private let flat = BookStructureModel.grouped(
        entries: [entry("c", pinned: true), entry("e", pinned: true), entry("a"), entry("b"), entry("d")],
        sections: [], assignments: [:])

    private func plan(
        _ site: BookStructureModel.PostDropSite, _ dragged: String,
        groups: [(section: ReadingSection?, entries: [Queries.ReadingEntry])]? = nil,
        reposition: Bool = true
    ) -> BookStructureModel.PostDropPlan? {
        BookStructureModel.postDropPlan(
            site, dragged: dragged, groups: groups ?? flat, reposition: reposition)
    }

    /// RED ON OLD (the first arm): the pre-B4 planner answered `before: "c"` —
    /// a position just before c's, which lands d wherever c's position falls
    /// among the UNPINNED positions (the B4 record's traced `Y | A X B`; on
    /// the store walk below, measured: nowhere visible at all).
    @Test func aDropAcrossThePinBoundaryLandsAtTheNearEdgeOfItsOwnRun() {
        // An unpinned note onto a pinned row: the TOP of the unpinned run.
        #expect(plan(.post("c"), "d") == .init(sectionID: nil, before: "a"))
        #expect(plan(.post("e"), "b") == .init(sectionID: nil, before: "a"))
        // …already standing there: nothing to reorder.
        #expect(plan(.post("c"), "a") == .init(sectionID: nil, before: nil))
        // A pinned note onto an unpinned row: the BOTTOM of the pinned run.
        #expect(plan(.post("b"), "c") == .init(sectionID: nil, before: nil, after: "e"))
        #expect(plan(.post("b"), "c")?.anchor == .after("e"))
        // …already its last: nothing to reorder.
        #expect(plan(.post("a"), "e") == .init(sectionID: nil, before: nil))
    }

    /// Inside its own run the shipped rule stands: right above the target.
    @Test func aDropInsideItsOwnRunLandsAboveTheTarget() {
        #expect(plan(.post("c"), "e") == .init(sectionID: nil, before: "c"))
        #expect(plan(.post("a"), "d") == .init(sectionID: nil, before: "a"))
        #expect(plan(.post("a"), "d")?.anchor == .before("a"))
    }

    /// Under a stamp order the drop never writes a position — the boundary
    /// changes nothing there (the shipped rule).
    @Test func underAStampOrderNoDropReorders() {
        #expect(plan(.post("c"), "d", reposition: false) == .init(sectionID: nil, before: nil))
        #expect(plan(.post("b"), "c", reposition: false) == .init(sectionID: nil, before: nil))
    }

    /// A chapter heading's drop files the note at the top of ITS OWN run in
    /// that chapter (the pin floats within its chapter — P-808-B4-2).
    @Test func aChapterHeadingDropFilesAtTheTopOfTheNotesOwnRun() {
        // s1: x(p) y   s2: z(p) w
        let groups = BookStructureModel.grouped(
            entries: [entry("x", pinned: true), entry("y"), entry("z", pinned: true), entry("w")],
            sections: [section("s1", "a"), section("s2", "b")],
            assignments: ["x": "s1", "y": "s1", "z": "s2", "w": "s2"])
        #expect(plan(.chapter("s1"), "w", groups: groups) == .init(sectionID: "s1", before: "y"),
                "an unpinned note joins s1 at the top of its UNPINNED run — never above the pin")
        #expect(plan(.chapter("s1"), "z", groups: groups) == .init(sectionID: "s1", before: "x"),
                "a pinned note joins s1 at the top of its pinned run")
        #expect(plan(.chapter("s1"), "y", groups: groups) == .init(sectionID: "s1", before: nil),
                "already the top of its run there")
        // Across chapters and across runs: s2's pinned z dropped onto s1's
        // unpinned y — s1's pinned run's bottom.
        #expect(plan(.post("y"), "z", groups: groups) == .init(sectionID: "s1", before: nil, after: "x"))
        // A pinned note into a chapter with no pinned run: it is that run.
        let bare = BookStructureModel.grouped(
            entries: [entry("y"), entry("z", pinned: true)],
            sections: [section("s1", "a"), section("s2", "b")],
            assignments: ["y": "s1", "z": "s2"])
        #expect(plan(.post("y"), "z", groups: bare) == .init(sectionID: "s1", before: nil))
    }

    /// The stamp-order gate speaks the Manual-order road for a cross-run
    /// re-place inside the note's own group, exactly as for any re-place.
    @Test func theStampOrderGateSpeaksForACrossRunReplace() {
        func outcome(_ site: BookStructureModel.PostDropSite, _ dragged: String)
            -> BookStructureModel.PostDropOutcome {
            BookStructureModel.postDropOutcome(
                site, dragged: dragged, groups: flat, reposition: false, frozen: false)
        }
        #expect(outcome(.post("c"), "d") == .needsManualOrder)
        #expect(outcome(.post("b"), "c") == .needsManualOrder)
        // Already at its run's edge: the plan files it where it stands.
        #expect(outcome(.post("c"), "a") == .plan(.init(sectionID: nil, before: nil)))
    }

    /// Move Up / Move Down stop at the boundary as at a chapter's edge (nil ⇒
    /// the item does not render), and walk inside the run.
    @Test func theHandMovesStopAtTheBoundary() {
        let shown = [entry("c", pinned: true), entry("e", pinned: true), entry("a"), entry("b"), entry("d")]
        #expect(BookStructureModel.runMove("e", up: false, in: shown) == nil, "the pinned run's last")
        #expect(BookStructureModel.runMove("a", up: true, in: shown) == nil, "the unpinned run's first")
        #expect(BookStructureModel.runMove("e", up: true, in: shown) == .before("c"))
        #expect(BookStructureModel.runMove("c", up: false, in: shown) == .after("e"))
        #expect(BookStructureModel.runMove("a", up: false, in: shown) == .after("b"))
        #expect(BookStructureModel.runMove("d", up: true, in: shown) == .before("b"))
        // The Book Panel's moves read the same rule, within the note's group.
        #expect(BookPanelBrain.noteMove("e", up: false, groups: flat, manualOrder: true) == nil)
        #expect(BookPanelBrain.noteMove("a", up: true, groups: flat, manualOrder: true) == nil)
        #expect(BookPanelBrain.noteMove("a", up: false, groups: flat, manualOrder: true) == .after("b"))
        // With no pins it is the shipped neighbour rule exactly.
        let plain = [entry("a"), entry("b"), entry("c")]
        #expect(BookStructureModel.runMove("b", up: true, in: plain) == .before("a"))
        #expect(BookStructureModel.runMove("a", up: true, in: plain) == nil)
        #expect(BookStructureModel.runMove("c", up: false, in: plain) == nil)
    }

    /// The Book Panel's drops ride the one planner — the near-edge `after`
    /// included.
    @Test func theBookPanelsDropsRideTheOnePlanner() {
        let plan = BookPanelBrain.dropPlan(
            .note("c"), onto: .note("b"), groups: flat, sections: [], manualOrder: true)
        #expect(plan == .file(postID: "c", sectionID: nil, before: nil, after: "e"))
        let across = BookPanelBrain.dropPlan(
            .note("d"), onto: .note("c"), groups: flat, sections: [], manualOrder: true)
        #expect(across == .file(postID: "d", sectionID: nil, before: "a"))
        #expect(BookPanelBrain.dropOutcome(
            .note("d"), onto: .note("c"), groups: flat, sections: [], manualOrder: false, frozen: false)
            == .needsManualOrder)
    }
}

// MARK: - A real store: the drops, the stepper, the door

@MainActor
@Suite("VX-803 — pinned notes over a real book", .serialized)
struct BookPinStoreTests {
    private func withBook(
        chapters: Bool = false,
        _ body: @MainActor (AppSession, AppDatabase, Reading, [String]) async throws -> Void
    ) async throws {
        let db = try AppDatabase.inMemory()
        let start = Date(timeIntervalSince1970: 1_782_864_000)
        let tick = LockIsolated(0)
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator {
                let seconds = tick.withValue { value -> Int in
                    defer { value += 1 }
                    return value
                }
                return start.addingTimeInterval(Double(seconds))
            }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 803))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let ops = session.operations
            let reading = try ops.createReading(name: "pins", kind: .book)
            var ids: [String] = []
            for title in ["a", "b", "c", "d", "e"] {
                let post = try ops.createPost(title: title)
                try ops.addPostToReading(post.id, to: reading.id)
                ids.append(post.id)
            }
            try await body(session, db, reading, ids)
        }
    }

    private func order(_ db: AppDatabase, _ reading: Reading) async throws -> [String] {
        try await db.read { [id = reading.id] in
            try Queries.assembleReading($0, readingID: id).map(\.postID)
        }
    }

    private func structure(
        _ session: AppSession, _ db: AppDatabase, _ reading: Reading
    ) async throws -> BookStructureModel {
        let structure = BookStructureModel(session: session, readingID: reading.id)
        structure.adopt(try await db.read { [id = reading.id] db in
            .init(
                reading: try Queries.reading(db, id: id),
                sections: try Queries.readingSections(db, readingID: id),
                deletedSections: [],
                assignments: try Queries.sectionAssignments(db, readingID: id))
        })
        return structure
    }

    /// The book view's drop through the one door (`filePost`) over real
    /// positions: across the boundary the note lands at its run's near edge.
    /// RED ON OLD, measured (a throwaway core run of the pre-B4 plans' writes
    /// on this fixture): `.before(c)` gave d a position between b's and c's,
    /// so it stayed the unpinned run's LAST (`c e a b d`), and `.before(b)`
    /// left c where it was (`c e a b d`) — two dead drops under a hairline
    /// that promised "lands right above".
    @Test func aDropAcrossTheBoundaryLandsAtTheRunsEdgeOverRealPositions() async throws {
        try await withBook { session, db, reading, ids in
            let (a, b, c, d, e) = (ids[0], ids[1], ids[2], ids[3], ids[4])
            try session.operations.setMembershipPinned(c, in: reading.id, pinned: true)
            try session.operations.setMembershipPinned(e, in: reading.id, pinned: true)
            #expect(try await order(db, reading) == [c, e, a, b, d])
            let structure = try await structure(session, db, reading)
            func entries() async throws -> [Queries.ReadingEntry] {
                try await db.read { [id = reading.id] in try Queries.assembleReading($0, readingID: id) }
            }
            await structure.filePost(d, onto: .post(c), entries: try await entries(), reposition: true)
            #expect(try await order(db, reading) == [c, e, d, a, b],
                    "unpinned d onto pinned c: the top of the unpinned run")
            await structure.filePost(c, onto: .post(b), entries: try await entries(), reposition: true)
            #expect(try await order(db, reading) == [e, c, d, a, b],
                    "pinned c onto unpinned b: the bottom of the pinned run")
            let pins = try await db.read { [id = reading.id] db -> [Bool] in
                try Queries.assembleReading(db, readingID: id).map(\.pinned)
            }
            #expect(pins == [true, true, false, false, false], "a drag never pins or unpins")
            #expect(structure.lastError == nil)
        }
    }

    /// ⌘↑ / ⌘↓ walk the floated order in every mode — Outline and Read ▸
    /// Scroll's grouped order (pins atop each chapter) and the spread's and
    /// Read ▸ Pages' leaves — through the modes' one order seam.
    @Test func theStepperWalksTheFloatedOrderInEveryMode() async throws {
        try await withBook { session, db, reading, ids in
            let (a, b, c, d, e) = (ids[0], ids[1], ids[2], ids[3], ids[4])
            let ops = session.operations
            let one = try ops.createSection(in: reading.id, name: "one")
            let two = try ops.createSection(in: reading.id, name: "two")
            for id in [a, b, c] { try ops.assignPostToSection(id, in: reading.id, section: one.id) }
            for id in [d, e] { try ops.assignPostToSection(id, in: reading.id, section: two.id) }
            try ops.setMembershipPinned(c, in: reading.id, pinned: true)
            try ops.setMembershipPinned(e, in: reading.id, pinned: true)
            let floated = [c, a, b, e, d]  // one: c(p) a b   two: e(p) d
            let model = BookViewModel(session: session, readingID: reading.id)
            await model.adopt(try await db.read { [id = reading.id] in
                try Queries.assembleReading($0, readingID: id)
            })
            #expect(model.entries.map(\.postID) == floated)
            let structure = try await structure(session, db, reading)
            #expect(structure.chaptersActive)
            for (mode, form) in [(BookStructureModel.ViewMode.outline, BookStructureModel.ReadForm.flow),
                                 (.read, .flow), (.read, .pages), (.spread, .flow)] {
                structure.mode = mode
                structure.readForm = form
                #expect(BookNoteStepDoor.order(structure: structure, entries: model.entries) == floated,
                        "\(mode)/\(form): the stepper's order is the floated order")
            }
            structure.mode = .outline
            #expect(BookNoteStepDoor.step(.next, model: model, structure: structure, status: session.status))
            #expect(model.pendingReveal == c, "nothing viewed: ⌘↓ lands the first note — the pinned one")
            model.consumeReveal()
            model.noteOutlineViewed(.init(postID: b))
            #expect(BookNoteStepDoor.step(.next, model: model, structure: structure, status: session.status))
            #expect(model.pendingReveal == e, "into the next chapter: its pinned note first")
        }
    }

    /// The door body: a pin lands silently (the note moves — no receipt); a
    /// finished book's refusal is the op's, in the book's words with its road.
    @Test func theDoorPinsSilentlyAndAFinishedBookRefusesInItsWords() async throws {
        try await withBook { session, db, reading, ids in
            let read = try await db.read { [id = reading.id] db -> Reading? in try Queries.reading(db, id: id) }
            let book = try #require(read)
            await PinNoteDoor.setPinned(session: session, postID: ids[3], book: book, pinned: true)
            #expect(try await order(db, reading).first == ids[3])
            #expect(session.status.spoken == nil, "no receipt — the act's result is on the page")
            try session.operations.lockReading(reading.id)
            let reread = try await db.read { [id = reading.id] db -> Reading? in try Queries.reading(db, id: id) }
            let finished = try #require(reread)
            await PinNoteDoor.setPinned(session: session, postID: ids[3], book: finished, pinned: false)
            #expect(session.status.spoken?.kind == .refusal)
            #expect(session.status.spoken?.text == "\u{201C}pins\u{201D} is finished \u{2014} reopen it first.")
            #expect(try await order(db, reading).first == ids[3], "the refusal changed nothing")
        }
    }
}

// MARK: - The registry (P-1 — A-808-12 (h))

@MainActor
@Suite("VX-803 — Pin to Top is declared once and rendered by the book's rows")
struct BookPinRegistryTests {
    @Test func theActIsDeclaredOnceInRemoveFromBooksShape() {
        let cap = CapabilityRegistry.capability(.pinNoteInBook)
        #expect(cap.verb == "Pin to Top")
        #expect(cap.scope == .book)
        #expect(cap.doors == [.contextMenu, .surface])
        #expect(cap.shortcutLabel == nil)
        #expect(PinNoteCopy.verb(pinned: false) == "Pin to Top")
        #expect(PinNoteCopy.verb(pinned: true) == "Unpin")
        #expect(CapabilityRegistry.all.filter { $0.id == .pinNoteInBook }.count == 1)
        #expect(CapabilityRegistry.isEnabled(.pinNoteInBook, in: CapabilityContext(focusedPaneShowsBook: true)))
    }

    @Test func theThreeRenderersDeclareIt() {
        #expect(BookView.contextMenuCapabilities.contains(.pinNoteInBook),
                "the navigator's and Outline's note-row menus")
        #expect(BookPanelView.contextMenuCapabilities.contains(.pinNoteInBook), "the Book Panel's note menu")
        #expect(BookIndexColumn.surfaceCapabilities.contains(.pinNoteInBook), "the Index row's ⋯ menu")
    }
}
