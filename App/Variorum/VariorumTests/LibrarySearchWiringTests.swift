//
//  LibrarySearchWiringTests.swift
//  VariorumTests
//
//  **13o U2 — the search state's WIRING TRUTHS** (the U2 brief's item 6), at
//  the face level, through the Library model she drives:
//
//  - R-13o-10 — *"owned book notes should show in the library with search,
//    by default. hide owned is a non library thing"*: an owned book's note
//    lists while the global default HIDES, and its row would wear the
//    owned-by badge (the 13i-c family, unchanged);
//  - the ruled posture — saved VERSIONS never list, the archived facet on or
//    off (the composer's fence, held at the face);
//  - R-13o-6 — *"the derived display name would be good to do"*: typing
//    "september 14" finds the NAMELESS note wearing that day, end to end;
//  - wings: search scopes by wing, period (the 13i sitting record §12) —
//    and P-13o-U1-5, RATIFIED (her word, 2026-10-06): scraps are the shared
//    room, listed from every wing.
//
//  (The archived word — out by default, one quiet facet — is pinned by
//  `LibrarySearchStateTests.theArchivedFacetIsOneQuietToggle…`.)
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("13o U2 — the search state's wiring truths", .serialized)
struct LibrarySearchWiringTests {
    private final class Clock: @unchecked Sendable {
        private let state = LockIsolated(Date(timeIntervalSince1970: 1_782_864_000))
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(11) }
                return value
            }
        }
    }

    private func withLibrary<T>(
        _ body: @MainActor (AppSession, LibraryCatalogModel) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let clock = Clock()
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 17))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let suite = "13o-u2-wiring-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defaults.removePersistentDomain(forName: suite)
            return try await body(session, LibraryCatalogModel(session: session, defaults: defaults))
        }
    }

    @Test func anOwnedBooksNoteListsBadgedEvenWhileTheDefaultHides() async throws {
        try await withLibrary { session, model in
            let ops = session.operations
            try ops.setHideOwnedDefault(true)
            let book = try ops.createReading(name: "Keeper's Log", kind: .book)
            _ = try ops.setReadingOwned(book.id, owned: true)
            let note = try ops.createPost(title: "Watch")
            _ = try ops.newBlock(in: note.id, text: "the lighthouse turned all night")
            _ = try ops.addPostToReading(note.id, to: book.id)

            model.query = "lighthouse "
            await model.search()
            #expect(model.searchState.groups.map(\.homeID) == [note.id],
                    "R-13o-10: the Library — searching included — is EXEMPT from hide-owned")
            #expect(model.noteHits.map(\.id) == [note.id], "its row is the List's own")
            let facts = try await session.database.read {
                try Queries.ownershipFacts($0, postIDs: [note.id], inBook: nil)
            }
            #expect(OwnershipBadgeFace.badge(facts[note.id], placement: .outside, badgesOn: true) != nil,
                    "…and it wears the owned-by badge (the row reads exactly these facts)")
        }
    }

    @Test func aSavedVersionNeverListsFacetOnOrOff() async throws {
        try await withLibrary { session, model in
            let note = try session.operations.createPost(title: "Orchard")
            _ = try session.operations.newBlock(in: note.id, text: "orchard rows in the fog")
            _ = try session.operations.saveNoteVersion(note.id)

            model.query = "orchard "
            await model.search()
            #expect(model.searchState.groups.map(\.homeID) == [note.id], "the living note alone")
            model.toggleArchivedFacet()
            await model.search()
            #expect(model.searchState.groups.map(\.homeID) == [note.id],
                    "a version is archived by construction — and still never listed (the ruled posture)")
            #expect(model.searchState.counts?.all.notes == 1 && model.searchState.counts?.archivedPlaces == 0,
                    "nor counted")
        }
    }

    @Test func septemberFourteenFindsTheNamelessNoteWearingIt() async throws {
        try await withLibrary { session, model in
            let ops = session.operations
            let dated = try ops.createPost(entryDate: "2026-09-14")
            _ = try ops.newBlock(in: dated.id, text: "grey morning, nothing to report")
            let other = try ops.createPost(title: "Plans")
            _ = try ops.newBlock(in: other.id, text: "buy flour")

            model.query = "september 14"
            await model.search()
            let first = try #require(model.searchState.groups.first)
            #expect(first.homeID == dated.id && first.titleMatched,
                    "the nameless note wears its day — and the day she typed finds it")
            #expect(first.note?.title == DisplayTitle.note(
                title: nil, entryDate: "2026-09-14", createdAt: nil),
                "its head is the name every surface shows it by")
            #expect(!model.searchState.groups.contains { $0.homeID == other.id })
            #expect((model.searchState.counts?.living.notes ?? 0) >= 1, "and the band counts it")
        }
    }

    @Test func searchStaysInItsWingWhileScrapsAreTheSharedRoom() async throws {
        try await withLibrary { session, model in
            let ops = session.operations
            let away = try ops.createWing(name: "Away")
            let home = try ops.createPost(title: "Home kestrel")
            _ = try ops.newBlock(in: home.id, text: "a kestrel over the field")
            let there = try ops.createPost(title: "Away kestrel", wingId: away.id)
            _ = try ops.newBlock(in: there.id, text: "a kestrel over the sea")
            let pool = try ops.createPool(title: "Heap")
            _ = try ops.newBlock(in: pool.id, text: "kestrel scrap")

            model.query = "kestrel "
            await model.search()
            #expect(Set(model.searchState.groups.map(\.homeID)) == [home.id, pool.id],
                    "Home's notes and the shared scraps — never another wing's note")

            session.wing.switchTo(away.id)
            await model.search()
            #expect(Set(model.searchState.groups.map(\.homeID)) == [there.id, pool.id],
                    "the wing is part of the question; the scraps follow her (P-13o-U1-5, ratified)")
        }
    }
}
