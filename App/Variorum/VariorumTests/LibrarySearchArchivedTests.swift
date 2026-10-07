//
//  LibrarySearchArchivedTests.swift
//  VariorumTests
//
//  **13o U3 — the archived facet's face, finished** (the brief's item 5; her
//  R-13o-6: archived notes, books and takes are indexed but OUT of the
//  default results behind one facet — and, the AST's own letter, under the
//  facet "rows say which they are"). U2 built the band's chip and the foot's
//  road; U3 makes every archived row SAY so: an archived note once under its
//  head, a passage archived on its own (a take, a block) with the badge, an
//  archived book in its row's detail — and the foot reaches a typed tag's
//  archived books too.
//
//  BUILD pins (a new face): pre-U3 the sheet drew an archived note, take or
//  book exactly as a living one (`wearsArchivedBadge`, `archivedBooks`,
//  `archivedNote` did not exist).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("13o U3 — the archived facet's face (rows say which they are)", .serialized)
struct LibrarySearchArchivedTests {
    private final class Clock: @unchecked Sendable {
        private let state = LockIsolated(Date(timeIntervalSince1970: 1_782_864_000))
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(7) }
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 13))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let suite = "13o-u3-archived-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defaults.removePersistentDomain(forName: suite)
            return try await body(session, LibraryCatalogModel(session: session, defaults: defaults))
        }
    }

    @Test func theBadgeRuleMarksAnArchivedPassageOnceNeverTwice() {
        #expect(LibrarySearchFace.wearsArchivedBadge(archived: true, inArchivedGroup: false))
        #expect(!LibrarySearchFace.wearsArchivedBadge(archived: true, inArchivedGroup: true),
                "an archived note says so once, under its head")
        #expect(!LibrarySearchFace.wearsArchivedBadge(archived: false, inArchivedGroup: false))
        #expect(LibrarySearchCopy.archivedBookDetail("book") == "book \u{00B7} archived")
        #expect(LibrarySearchCopy.archivedBookDetail(nil) == "archived")
    }

    @Test func underTheFacetEveryArchivedRowSaysWhichItIs() async throws {
        try await withLibrary { session, model in
            let ops = session.operations
            let stored = try ops.createPost(title: "Stored orchid")
            _ = try ops.newBlock(in: stored.id, text: "orchid in a box")
            try ops.archiveContainer(stored.id)
            let live = try ops.createPost(title: "Live")
            let kept = try ops.newBlock(in: live.id, text: "orchid on the sill")
            let shelved = try ops.newBlock(in: live.id, text: "orchid set aside")
            try ops.archiveBlock(shelved.block.id)
            let book = try ops.createReading(name: "Orchid book", kind: .book)
            try ops.archiveReading(book.id)

            model.query = "orchid "
            await model.search()
            let state = model.searchState
            #expect(state.groups.map(\.homeID) == [live.id], "control: the living corpus")
            #expect(state.groups.first?.lines.map(\.sourceID) == [kept.variant.id])
            #expect(state.books.isEmpty)
            #expect((state.counts?.archivedPlaces ?? 0) >= 2, "the foot has archived places to offer")

            model.toggleArchivedFacet()
            await model.search()
            let stretched = model.searchState
            let archivedGroup = try #require(stretched.groups.first { $0.homeID == stored.id })
            #expect(archivedGroup.isArchived, "the archived NOTE is marked once, under its head")
            let liveGroup = try #require(stretched.groups.first { $0.homeID == live.id })
            #expect(!liveGroup.isArchived)
            let badged = liveGroup.lines.filter {
                LibrarySearchFace.wearsArchivedBadge(archived: $0.isArchived, inArchivedGroup: liveGroup.isArchived)
            }
            #expect(badged.map(\.sourceID) == [shelved.variant.id],
                    "the archived BLOCK's passage wears the badge inside a living note")
            #expect(stretched.books.map(\.id) == [book.id])
            #expect(stretched.archivedBooks == [book.id], "the archived book's row says so")
        }
    }

    @Test func aTypedTagsArchivedBooksReachTheFootAndTheFacet() async throws {
        try await withLibrary { session, model in
            let ops = session.operations
            let dream = try ops.createTag(name: "dream")
            let spec = try RuleGrammar.encode(.tag(dream.id))
            let living = try ops.createReading(name: "Dream journal", kind: .book, querySpec: spec)
            let old = try ops.createReading(name: "Old dreams", kind: .book, querySpec: spec)
            try ops.archiveReading(old.id)

            model.query = "#dream"
            await model.search()
            #expect(model.bookHits.map(\.id) == [living.id])
            #expect(model.searchState.counts?.archivedPlaces == 1, "the foot offers the archived book")

            model.toggleArchivedFacet()
            await model.search()
            #expect(Set(model.bookHits.map(\.id)) == [living.id, old.id])
            #expect(model.searchState.archivedBooks == [old.id])
            #expect(model.searchState.bookReasons[old.id] == .flowsIn(path: "dream"))
        }
    }
}
