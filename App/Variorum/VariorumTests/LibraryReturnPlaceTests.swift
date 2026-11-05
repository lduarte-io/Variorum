//
//  LibraryReturnPlaceTests.swift
//  VariorumTests
//
//  **VX-823 (the VX-828 run, batch C) — the MODEL's half of "the Library
//  remembers where you were"**, built to the orchestrator's ruling on the fork
//  (P-828-11…14, Q5). State-transition pins over the catalog model and a real
//  in-memory store, no view: the pane's scroll is STAGED through the model's
//  own doors (`placeMemory.noteWindow` / `noteFrame` — exactly what the
//  mounted scroll reports; the 18l-c U8 lesson: stage "her scroll" through its
//  owning door), the place noted through `notePlace` / `rowOpened`, and the
//  return played through the mount's own read, `listingAppeared`.
//
//  RED ON OLD (behavioural — the self-assessment's revert R-C2): the pre-fix
//  mount re-asked a NEW question from the top (`search()`), so the listing
//  came back at its FIRST page (80), the place died with it and nothing
//  landed. Compile-red on the pre-fix tree besides (no place API).
//

import CoreGraphics
import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-823 — the Library's place survives the trip (model)", .serialized)
struct LibraryReturnPlaceTests {
    private final class Clock: @unchecked Sendable {
        private let state: LockIsolated<Date>
        init(start: Date) { state = LockIsolated(start) }
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(37) }
                return value
            }
        }
    }

    /// 09:00 local on a fixed day — every note of a fixture lands on ONE day
    /// of her calendar (the day pin's precondition).
    private static let start: Date = {
        LibraryDayFace.calendar.date(from: DateComponents(year: 2026, month: 7, day: 1, hour: 9))!
    }()

    private func withLibrary<T>(
        _ body: @MainActor (AppSession) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let clock = Clock(start: Self.start)
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 823))
        } operation: { @MainActor in
            try await body(AppSession(database: db))
        }
    }

    private func scrubbed(_ name: String) throws -> UserDefaults {
        let suite = "vx823-place-\(name)-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    /// `count` notes, oldest first, each one block — its variant kept so a pin
    /// can type into it.
    private func notes(_ session: AppSession, _ count: Int) throws -> [(note: String, variant: String)] {
        try (0..<count).map { index in
            let note = try session.operations.createPost(title: String(format: "note %03d", index))
            let block = try session.operations.newBlock(in: note.id, text: "words of \(index)")
            return (note.id, block.variant.id)
        }
    }

    private static let pitch: CGFloat = 30
    private static let lead: CGFloat = 40

    /// What the mounted column reports: the rows `realized` (a lazy column's
    /// superset of the screen) at `lead + position × pitch` in its content's
    /// space, and the window with the viewport's top `into` row `top`'s.
    private func stage(
        _ model: LibraryCatalogModel, key: String, ids: [String], realized: ClosedRange<Int>,
        top: Int, offsetIntoTop: CGFloat = 10, viewport: CGFloat = 180,
        surface: LibraryPlace.Surface = .list(includesBooks: false)
    ) {
        for position in realized where ids.indices.contains(position) {
            model.placeMemory.noteFrame(
                CGRect(x: 0, y: Self.lead + CGFloat(position) * Self.pitch, width: 600, height: Self.pitch),
                id: ids[position], key: key)
        }
        model.placeMemory.noteWindow(
            .init(offset: Self.lead + CGFloat(top) * Self.pitch + offsetIntoTop, viewport: viewport,
                  content: Self.lead + CGFloat(ids.count) * Self.pitch + 10),
            surface: surface, key: key)
    }

    private func pageThroughEverything(_ model: LibraryCatalogModel) async {
        var last = -1
        while model.noteHits.count != last {
            last = model.noteHits.count
            await model.loadMoreNotes()
        }
    }

    // MARK: - The return re-asks IN PLACE, to the place's depth (Q5)

    /// **She scrolled to row 150 of 300 and left; she comes back.** The mount
    /// re-asks the same question IN PLACE to the place's depth — the deepest
    /// remembered row (the neighbourhood's last, 168) plus one page — so the
    /// rows she was reading are listed again, and the landing is the top
    /// on-screen row at the very place it sat. RED ON OLD: the mount asked a
    /// new question — 80 rows, no place, no landing.
    @Test func aReturnReasksInPlaceToThePlacesDepthAndLandsWhereSheWas() async throws {
        try await withLibrary { session in
            _ = try notes(session, 300)
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("depth"))
            await model.search()
            await pageThroughEverything(model)
            try #require(model.noteHits.count == 300)
            let ids = model.noteHits.map(\.id)
            stage(model, key: "p", ids: ids, realized: 140...175, top: 150)
            model.notePlace(placeKey: "p")
            let place = try #require(model.placeMemory.place("p"))
            #expect(place.place.rows.map(\.id) == Array(ids[150...156]))
            #expect(place.noteReach == 168)

            // The trip: the view died; the mount's read.
            await model.listingAppeared(placeKey: "p")
            #expect(model.noteHits.count == LibraryPlace.depth(reach: 168, page: LibraryCatalogModel.pageSize))
            #expect(model.noteHits.count == 249, "∝ the place's depth — never the corpus")
            #expect(model.placeLanding(placeKey: "p")
                == LibraryPlace.Landing(id: ids[150], into: -10, height: Self.pitch))
            #expect(model.placeMemory.relistedToken("p") == 1, "the pane's scroll hears the re-ask land")
            #expect(!model.placeMemory.isRestoring("p"))
        }
    }

    /// **The edited sort's own move (P-828-11's reason).** She opened the TOP
    /// on-screen row and typed in it: under `edited · newest first` it is now
    /// the Library's first row. The place holds — the next on-screen row lands
    /// where it sat — and the row she left from carries the return MARK
    /// (P-828-12), findable at the top. RED under revert R-C1 (the opened row
    /// allowed as the anchor): the landing names the moved row, now at the
    /// very top.
    @Test func theOpenedRowsOwnMoveDoesNotMoveThePlace() async throws {
        try await withLibrary { session in
            let made = try notes(session, 200)
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("moved"))
            await model.search()
            await pageThroughEverything(model)
            let ids = model.noteHits.map(\.id)
            stage(model, key: "p", ids: ids, realized: 90...130, top: 100)
            let opened = ids[100]
            model.rowOpened(opened, placeKey: "p")
            #expect(model.placeMemory.mark(in: "p") == opened)

            // A keystroke inside the note.
            let variant = try #require(made.first { $0.note == opened }?.variant)
            try session.operations.autosave(variant, text: "words of it, and more", charDelta: 13)

            await model.listingAppeared(placeKey: "p")
            #expect(model.noteHits.first?.id == opened, "the edited note leads the edited sort")
            #expect(model.placeLanding(placeKey: "p")
                == LibraryPlace.Landing(id: ids[101], into: 20, height: Self.pitch))
            #expect(model.placeMemory.mark(in: "p") == opened, "the mark survives the trip")
        }
    }

    /// **A row deleted since** — the next surviving on-screen row lands at its
    /// own place; never a throw, never the corpus.
    @Test func aDeletedOnScreenRowFallsToTheNextSurvivor() async throws {
        try await withLibrary { session in
            _ = try notes(session, 200)
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("gone"))
            await model.search()
            await pageThroughEverything(model)
            let ids = model.noteHits.map(\.id)
            stage(model, key: "p", ids: ids, realized: 90...130, top: 100)
            model.notePlace(placeKey: "p")
            try session.operations.deleteContainer(ids[100])
            try session.operations.deleteContainer(ids[101])

            await model.listingAppeared(placeKey: "p")
            #expect(!model.noteHits.contains { $0.id == ids[100] })
            #expect(model.placeLanding(placeKey: "p")
                == LibraryPlace.Landing(id: ids[102], into: 50, height: Self.pitch))
        }
    }

    // MARK: - A new question starts at the top (today's behaviour, kept)

    @Test func aNewQuestionDropsThePlaceAndTheMark() async throws {
        try await withLibrary { session in
            _ = try notes(session, 200)
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("question"))
            await model.search()
            await pageThroughEverything(model)
            let ids = model.noteHits.map(\.id)
            stage(model, key: "p", ids: ids, realized: 90...130, top: 100)
            model.rowOpened(ids[105], placeKey: "p")
            #expect(model.placeMemory.place("p") != nil)

            // Her sort pick — the door's two steps.
            model.setSort(.title)
            await model.search()
            #expect(model.placeMemory.place("p") == nil)
            #expect(model.placeMemory.mark(in: "p") == nil)

            await model.listingAppeared(placeKey: "p")
            #expect(model.noteHits.count == LibraryCatalogModel.pageSize, "the first page, at the top")
            #expect(model.placeLanding(placeKey: "p") == nil)
        }
    }

    @Test func aWingSwitchDropsThePlace() async throws {
        try await withLibrary { session in
            _ = try notes(session, 200)
            let other = try session.operations.createWing(name: "elsewhere")
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("wing"))
            await model.search()
            await pageThroughEverything(model)
            let ids = model.noteHits.map(\.id)
            stage(model, key: "p", ids: ids, realized: 90...130, top: 100)
            model.rowOpened(ids[100], placeKey: "p")

            session.wing.switchTo(other.id)
            await model.listingAppeared(placeKey: "p")
            #expect(model.placeMemory.place("p") == nil)
            #expect(model.placeMemory.mark(in: "p") == nil)
            #expect(model.noteHits.isEmpty, "the other wing's (empty) Library")
            #expect(model.placeLanding(placeKey: "p") == nil)
        }
    }

    // MARK: - The search and the day ride along

    /// **A search live** — the answer sheet's place is its GROUPS: the same
    /// question re-asked in place to the place's group depth, the field's
    /// words untouched, the landing a group.
    @Test func theSearchRidesAlongAndTheSheetComesBackWhereSheWas() async throws {
        try await withLibrary { session in
            _ = try notes(session, 120)
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("sheet"))
            model.query = "words"
            await model.search()
            #expect(model.isSearching)
            await model.loadMoreSearchGroups()
            try #require(model.searchState.groups.count == 2 * LibrarySearchModel.groupPageSize)
            let groups = model.searchState.groups.map(\.homeID)
            stage(model, key: "p", ids: groups, realized: 25...45, top: 30, surface: .sheet)
            model.notePlace(placeKey: "p")
            let place = try #require(model.placeMemory.place("p"))
            #expect(place.groupReach == 48)

            await model.listingAppeared(placeKey: "p")
            #expect(model.query == "words")
            #expect(model.isSearching)
            #expect(model.searchState.groups.count
                == LibraryPlace.depth(reach: 48, page: LibrarySearchModel.groupPageSize))
            #expect(model.placeLanding(placeKey: "p")
                == LibraryPlace.Landing(id: groups[30], into: -10, height: Self.pitch))
        }
    }

    /// **The day filter armed** — the day's answer is a whole set (never
    /// paged); the day stays armed across the trip and the place lands.
    @Test func theDayRidesAlongAndItsAnswerComesBackWhereSheWas() async throws {
        try await withLibrary { session in
            _ = try notes(session, 120)
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("day"))
            let day = JournalDay.dayString(from: Self.start, calendar: LibraryDayFace.calendar)
            model.setEditedOn(day)
            await model.search()
            try #require(model.noteHits.count == 120, "the day's answer, whole")
            let ids = model.noteHits.map(\.id)
            stage(model, key: "p", ids: ids, realized: 50...80, top: 60)
            model.notePlace(placeKey: "p")

            await model.listingAppeared(placeKey: "p")
            #expect(model.editedOn == day)
            #expect(model.noteHits.count == 120)
            #expect(model.placeLanding(placeKey: "p")
                == LibraryPlace.Landing(id: ids[60], into: -10, height: Self.pitch))
        }
    }

    // MARK: - The mark (P-828-12 / -14)

    @Test func theMarkGoesWithHerNextClickOrAModeSwitchAndTheCardsMakeNone() async throws {
        try await withLibrary { session in
            _ = try notes(session, 100)
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("mark"))
            await model.search()
            let ids = model.noteHits.map(\.id)
            stage(model, key: "p", ids: ids, realized: 0...30, top: 5)

            model.rowOpened(ids[6], placeKey: "p")
            #expect(model.placeMemory.mark(in: "p") == ids[6])
            model.clickNoteRow(ids[2], modifiers: .none)
            #expect(model.placeMemory.mark(in: "p") == nil, "her next row click")

            model.rowOpened(ids[6], placeKey: "p")
            #expect(model.placeMemory.mark(in: "p") == ids[6])
            _ = model.modeChanged()
            #expect(model.placeMemory.mark(in: "p") == nil, "a mode switch")

            model.rowOpened(ids[7], placeKey: "p", marks: false)
            #expect(model.placeMemory.mark(in: "p") == nil, "a row that wears no selection face")

            // The Cards: the place, never a mark.
            stage(model, key: "p", ids: ids, realized: 0...30, top: 5, surface: .cards)
            model.rowOpened(ids[8], placeKey: "p")
            #expect(model.placeMemory.mark(in: "p") == nil)
            #expect(model.placeMemory.place("p")?.place.openedID == ids[8])
        }
    }

    // MARK: - Per pane (the ruling's amendment)

    /// **Two Library panes, two places** — and a pane mounting with NO place
    /// re-reads the first page without dropping the other pane's (it asks the
    /// same question, not a new one).
    @Test func eachPaneKeepsItsOwnPlace() async throws {
        try await withLibrary { session in
            _ = try notes(session, 200)
            let model = LibraryCatalogModel(session: session, defaults: try scrubbed("panes"))
            await model.search()
            await pageThroughEverything(model)
            let ids = model.noteHits.map(\.id)
            stage(model, key: "left", ids: ids, realized: 140...175, top: 150)
            model.notePlace(placeKey: "left")
            stage(model, key: "right", ids: ids, realized: 10...40, top: 20, offsetIntoTop: 0)
            model.notePlace(placeKey: "right")

            await model.listingAppeared(placeKey: "third")
            #expect(model.placeMemory.place("left") != nil)
            #expect(model.placeMemory.place("right") != nil)

            await model.listingAppeared(placeKey: "left")
            #expect(model.placeLanding(placeKey: "left")
                == LibraryPlace.Landing(id: ids[150], into: -10, height: Self.pitch))
            #expect(model.placeLanding(placeKey: "right")
                == LibraryPlace.Landing(id: ids[20], into: 0, height: Self.pitch))
        }
    }
}
