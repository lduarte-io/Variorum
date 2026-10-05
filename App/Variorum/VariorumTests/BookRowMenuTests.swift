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

    /// The table: the basics, in order; the archive table's state doors.
    @Test func theTableIsTheBasics() {
        #expect(BookRowMenuTable.doors(for: reading("b")) == [
            .open, .star, .settings, .exportMarkdown, .exportPDF,
            .state(.archiveBook), .state(.deleteBook),
        ])
        #expect(BookRowMenuTable.doors(for: reading("g", kind: .gathering)).contains(.state(.deleteBook)))
        #expect(BookRowMenuTable.doors(for: reading("a", archived: true))
                .contains(.state(.unarchiveBook)),
                "an archived book (the Archived group, a starred archived book) offers Unarchive")
        #expect(!BookRowMenuTable.doors(for: reading("a", archived: true))
                .contains(.state(.archiveBook)))
    }

    /// The daily Journal never offers Delete (the op refuses it — P-2).
    @Test func theDailyJournalOffersArchiveNeverDelete() {
        let daily = reading("j", profile: "daily")
        #expect(Queries.isDailyJournalMintShape(daily), "the fixture IS the daily Journal's shape")
        let doors = BookRowMenuTable.doors(for: daily)
        #expect(doors.contains(.state(.archiveBook)))
        #expect(!doors.contains(.state(.deleteBook)))
    }

    /// Before the row's facts are read, no state door is drawn (its truth is
    /// unknown) — the rest are.
    @Test func unknownFactsDrawNoStateDoor() {
        #expect(BookRowMenuTable.doors(for: nil)
                == [.open, .star, .settings, .exportMarkdown, .exportPDF])
    }

    /// Her carve-out: position means nothing off the Bookcase — none of its
    /// positional doors (nor its board-local ceremonies) is rendered here,
    /// and every act the menu does render is declared with a context door.
    @Test func thePositionalDoorsStayOnTheBookcase() {
        let rendered = Set(BookRowMenu.contextMenuCapabilities)
        for act in BookRowMenuTable.bookcaseOnly {
            #expect(!rendered.contains(act), "\(act)")
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
}
