//
//  BookRowMenuTests.swift
//  VariorumTests
//
//  17y B3 item (l) — BOOK-ROW CONTEXT MENUS BEYOND THE BOOKCASE (her walk
//  close: "…don't get a book's options (maybe not all of them, like the move
//  up and down, and the move to shelf, but at least the basic ones like
//  star)"). The surfaces (enumerated in the B3 RECORD): the Library's List
//  mode Books section · the sidebar's Starred section (book rows) · the
//  Archived surface's BOOKS group. One door table (`BookRowMenuTable`), one
//  renderer (`BookRowMenu`) — P-1, no per-view ifs.
//
//  A ruled BUILD (no red-on-old owed): the pins fix the table, its reach and
//  the brain's acts; the walk captures the menu on each surface.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("17y (l) — the book row menu beyond the Bookcase")
struct BookRowMenuTests {
    private func reading(
        _ id: String, kind: ReadingKind = .book, profile: String? = nil,
        archived: Bool = false, owned: Bool = false
    ) -> Reading {
        let now = Date(timeIntervalSince1970: 1_782_864_000)
        return Reading(
            id: id, name: id, kind: kind, profile: profile, owned: owned,
            archivedAt: archived ? now : nil, createdAt: now, updatedAt: now)
    }

    /// The table, in order. A JUSTIFIED EDIT at VX-829 (the VX-878 run, her
    /// 2026-11-04 ask — "the options that are available in bookcase on a book
    /// should be available on library (within reason, like the shelf options
    /// don't need to be there)"): 17y's trimmed "basics" (Open · Star ·
    /// Settings · the exports · Archive · Delete — PROVISIONAL P-17y-B3-l1)
    /// is superseded by the Bookcase row's whole set minus shelf placement,
    /// Open leading, in the Bookcase's order (the derivation itself is
    /// `BookDoorsEverywhereTests`'). The subject — the table says exactly what
    /// a plain book's row draws beyond the Bookcase — is unchanged.
    @Test func theTableIsTheBookcaseRowsDoorsMinusShelfPlacement() {
        #expect(BookRowMenuTable.doors(for: reading("b")) == [
            .open, .star,
            .rename, .settings, .duplicate, .editRule, .manageNotes, .extent,
            .state(.finishBook), .state(.sealBook), .state(.ownBook),
            .exportMarkdown, .exportPDF,
            .state(.archiveBook), .state(.deleteBook),
        ])
        #expect(BookRowMenuTable.doors(for: reading("g", kind: .gathering)).contains(.state(.deleteBook)))
        #expect(BookRowMenuTable.doors(for: reading("a", archived: true))
                .contains(.state(.unarchiveBook)),
                "an archived book (the Archived group, a starred archived book) offers Unarchive")
        #expect(!BookRowMenuTable.doors(for: reading("a", archived: true))
                .contains(.state(.archiveBook)))
    }

    /// The daily Journal's row offers Archive AND Delete, like any book. (A
    /// JUSTIFIED EDIT at the VX-805/VX-809 merge-in: this pin was born
    /// "theDailyJournalOffersArchiveNeverDelete" — "the op refuses it, P-2" —
    /// and VX-435/436, the VX-805 run, superseded that contract: the daily
    /// Journal is deletable with the ordinary book confirm (QUESTIONS #261 B8),
    /// so `BookArchiveDoorSet.rendered` draws Delete for every book.)
    @Test func theDailyJournalOffersArchiveAndDeleteSinceVX435() {
        let daily = reading("j", profile: "daily")
        #expect(Queries.isDailyJournalMintShape(daily), "the fixture IS the daily Journal's shape")
        let doors = BookRowMenuTable.doors(for: daily)
        #expect(doors.contains(.state(.archiveBook)))
        #expect(doors.contains(.state(.deleteBook)), "deletable like any book since VX-435/436")
    }

    /// Before the row's facts are read, no state door is drawn (its truth is
    /// unknown) — and, since the ladder's round-1 NIT-2 (a justified edit,
    /// the subject strengthened), no export either: `ReadingExport` takes
    /// the Reading row, so the table says exactly what the renderer draws
    /// on a facts-less row.
    @Test func unknownFactsDrawNoStateDoor() {
        #expect(BookRowMenuTable.doors(for: nil) == [.open, .star, .settings])
    }

    /// Her carve-out: position means nothing off the Bookcase — none of its
    /// shelf-placement doors is rendered here, and every act the menu does
    /// render is declared with a context door. (A JUSTIFIED EDIT at VX-829:
    /// the board-local ceremonies — Move to Wing ▸, Duplicate Book…, Edit
    /// Rule…, Bind / Make a Book — left 17y's Bookcase-only list for her
    /// ask; only the shelf-placement family stays the board's.)
    @Test func thePositionalDoorsStayOnTheBookcase() {
        let rendered = Set(BookRowMenu.contextMenuCapabilities)
        #expect(BookRowMenuTable.shelfPlacementCapabilities
                == [.moveBookToShelf, .sendBookToTop, .sendBookToBottom])
        for act in BookRowMenuTable.shelfPlacementCapabilities {
            #expect(!rendered.contains(act), "\(act)")
            #expect(ShelfView.contextMenuCapabilities.contains(act), "\(act) stays the board's")
        }
        #expect(rendered.contains(.toggleStar), "STAR at minimum (her words)")
        for act in rendered {
            #expect(CapabilityRegistry.capability(act).doors.contains(.contextMenu), "\(act)")
        }
    }

    /// The three enumerated surfaces render THIS menu (a grep-form pin — a
    /// context menu's content is not evaluated by the test host).
    @Test func theThreeSurfacesRenderTheOneMenu() throws {
        let appRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
        for file in [
            "Variorum/Features/Library/LibraryCatalogView.swift",
            "Variorum/Features/Library/SidebarView.swift",
            "Variorum/Features/Library/ArchivedView.swift",
        ] {
            let text = try String(contentsOf: appRoot.appending(path: file), encoding: .utf8)
            #expect(text.contains("BookRowMenu("), "\(file) renders the book row menu")
        }
    }

    /// The brain: the listed books' facts are read; a state door acts
    /// through the surface's one state-door road (a plain book archives at
    /// once — P-13ie-U2-1).
    @Test func theBrainReadsTheFactsAndActsThroughTheStateDoors() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 3))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let book = try session.operations.createReading(name: "essays", kind: .book)
            let doors = BookRowDoors(session: session)
            await doors.load([book.id, "not-a-reading"])
            #expect(doors.facts.keys.sorted() == [book.id], "the live rows only")

            await doors.open(.archiveBook, readingID: book.id)
            let archived = try await db.read { try Queries.reading($0, id: book.id)?.archivedAt }
            #expect(archived != nil, "a plain book archives at once")

            await doors.openSettings(book.id)
            #expect(doors.settingsTarget?.readingID == book.id, "the settings sheet's item")
        }
    }

    /// The walk's W-2 (a bug-class row — red-on-old by a synthetic revert of
    /// the wiring, recorded in the B3 RECORD): the Library's listing is a
    /// ONE-SHOT read, so a book archived from ITS row menu must leave the list
    /// without anything else asking — the catalog's own row doors re-ask.
    @Test func aBookArchivedFromTheLibraryRowLeavesTheListing() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 5))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let book = try session.operations.createReading(name: "essays", kind: .book)
            let catalog = LibraryCatalogModel(session: session)
            await catalog.search()
            #expect(catalog.listedBookIDs.contains(book.id), "listed before the act")

            await catalog.bookRowDoors.open(.archiveBook, readingID: book.id)
            for _ in 0..<200 where catalog.listedBookIDs.contains(book.id) {
                try? await Task.sleep(for: .milliseconds(5))
            }
            #expect(!catalog.listedBookIDs.contains(book.id),
                    "the listing re-asked on its own — the archived book left it")
        }
    }

    /// The brain's half: a state door that ran tells the surface.
    @Test func aStateDoorThatRanTellsTheSurface() async throws {
        let db = try AppDatabase.inMemory()
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = .constant(Date(timeIntervalSince1970: 1_782_864_000))
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 4))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let book = try session.operations.createReading(name: "essays", kind: .book)
            let doors = BookRowDoors(session: session)
            var landed = 0
            doors.onLanded = { landed += 1 }
            await doors.open(.archiveBook, readingID: book.id)
            #expect(landed == 1, "the surface heard the act")
        }
    }
}
