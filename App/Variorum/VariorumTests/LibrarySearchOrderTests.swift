//
//  LibrarySearchOrderTests.swift
//  VariorumTests
//
//  **VX-820 (the VX-819 run, batch 2) — the answer sheet's order door.**
//  Her R-819-2, *"Full vocabulary"*: while a search is live the sort door
//  offers relevance (leading, the default per search) · edited · created ·
//  date · title, with direction, exactly like the Library's own `sort ▾`.
//
//  An Improvement — BUILD pins, driven through the model's OWN doors (the
//  `LibrarySortMenuTests` discipline: the door's pick, then the model's own
//  `search()`, reading what landed):
//  - the door's vocabulary and words;
//  - the lifecycle (PROVISIONAL, the brief): a new search starts at
//    relevance, refining keeps the pick, a cleared field discards it, and
//    the Library's own sort is never touched;
//  - the sheet's groups in the picked order, the next page continuing it,
//    relevance back to best-first;
//  - a note row's stamp speaks the order it is listed in.
//  The core order itself is pinned headless (`SearchOrderTests`).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-820 — the answer sheet's order door", .serialized)
struct LibrarySearchOrderTests {
    private func withLibrary<T>(
        notes count: Int,
        _ body: @MainActor (AppSession, LibraryCatalogModel, UserDefaults, [String]) async throws -> T
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 820))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            // Born in order; each one's lantern count differs, so relevance
            // (bm25) and the stamps disagree.
            var ids: [String] = []
            for index in 0..<count {
                let note = try session.operations.createPost(title: "note \(index)")
                let words = Array(repeating: "lantern", count: 1 + (index * 7) % 5).joined(separator: " ")
                _ = try session.operations.newBlock(in: note.id, text: "\(words) and other words \(index)")
                ids.append(note.id)
            }
            let suite = "vx-820-order-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defaults.removePersistentDomain(forName: suite)
            let model = LibraryCatalogModel(session: session, defaults: defaults)
            return try await body(session, model, defaults, ids)
        }
    }

    private func ask(_ model: LibraryCatalogModel, _ text: String) async {
        model.query = text
        await model.search()
    }

    @Test func theDoorOffersHerFiveRelevanceFirstInTheLibrarysOwnWords() {
        #expect(LibrarySearchOrderFace.offered.map(LibrarySearchOrderFace.label)
                == ["relevance", "edited", "created", "date", "title"])
        #expect(LibrarySearchOrderFace.doorLabel(.relevance) == LibrarySearchCopy.relevance)
        #expect(LibrarySearchOrderFace.doorLabel(.home(.createdAt, .asc)) == "created \u{B7} oldest first")
        #expect(LibrarySearchOrderFace.doorLabel(.home(.title, .asc)) == "title \u{B7} A\u{2013}Z")
        #expect(LibrarySearchOrderFace.picked(.relevance) == nil)
        #expect(LibrarySearchOrderFace.picked(.home(.entryDate, .desc)) == .entryDate)
    }

    /// The lifecycle (PROVISIONAL — the brief's reset shape): a NEW search
    /// starts at relevance; refining a live question keeps her pick; ending
    /// the search (the field cleared) discards it; the Library's own sort
    /// preference never moves.
    @Test func aNewSearchStartsAtRelevanceRefiningKeepsThePickAndClearingDiscardsIt() async throws {
        try await withLibrary(notes: 4) { _, model, defaults, _ in
            let librarySort = (model.sort, model.direction)
            await ask(model, "lantern")
            #expect(model.isSearching)
            #expect(model.searchState.order == .relevance, "a new search starts at relevance")

            model.pickSearchOrder(.createdAt)
            await model.search()
            #expect(model.searchState.order == .home(.createdAt, .desc), "a stamp takes newest first")
            model.pickSearchOrderDirection(.asc)
            await model.search()
            #expect(model.searchState.order == .home(.createdAt, .asc))

            await ask(model, "lantern and")
            #expect(model.searchState.order == .home(.createdAt, .asc), "refining keeps her pick")

            await ask(model, "")
            #expect(!model.isSearching)
            #expect(model.searchState.order == .relevance, "a cleared field discards it")
            await ask(model, "lantern")
            #expect(model.searchState.order == .relevance, "the next search starts at relevance again")

            #expect(model.sort == librarySort.0 && model.direction == librarySort.1,
                    "the Library's own sort is untouched")
            #expect(defaults.string(forKey: LibraryCatalogModel.sortKey) == nil,
                    "and nothing of the order was remembered as the Library's")

            // Relevance has no direction arm.
            model.pickSearchOrder(nil)
            model.pickSearchOrderDirection(.asc)
            #expect(model.searchState.order == .relevance)
        }
    }

    /// The sheet lists its groups in the picked order — the next page
    /// CONTINUING it (more groups than a page) — and back to best first at
    /// relevance. The oracle for each home order is the Library's own
    /// listing of the same notes under the same sort (every note matches).
    @Test func theSheetsGroupsFollowThePickedOrderAcrossItsPages() async throws {
        try await withLibrary(notes: LibrarySearchModel.groupPageSize + 7) { session, model, _, ids in
            await ask(model, "lantern")
            @MainActor func allGroups() async -> [String] {
                while model.canAskForMoreGroups { await model.loadMoreSearchGroups() }
                return model.searchState.groups.map(\.homeID)
            }
            let relevance = await allGroups()
            #expect(Set(relevance) == Set(ids))
            let scores = model.searchState.groups.compactMap(\.bestScore)
            #expect(scores == scores.sorted(), "relevance: best first")

            for sort in LibrarySortFace.offered {
                for direction in [SortDirection.desc, .asc] {
                    model.pickSearchOrder(sort)
                    model.pickSearchOrderDirection(direction)
                    await model.search()
                    #expect(model.searchState.groups.count == LibrarySearchModel.groupPageSize,
                            "\(sort) \(direction): a first page")
                    let listed = await allGroups()
                    let expected = try await session.database.read { db in
                        try Queries.catalogNotesPage(db, query: "", sort: sort, direction: direction, limit: 500)
                            .hits.map(\.id)
                    }
                    #expect(listed == expected, "\(sort) \(direction): the sheet in the Library's own order")
                    #expect(model.noteHits.map(\.id) == listed, "the note heads land in the same order")
                }
            }

            model.pickSearchOrder(nil)
            await model.search()
            #expect(await allGroups() == relevance, "relevance: best first again")
        }
    }

    /// A note row's trailing stamp is the ORDER's own (the 18h rule — the
    /// stamp on screen explains the order): a home order speaks its sort;
    /// relevance, and the Library outside a search, speak the Library's.
    @Test func aNoteRowsStampSpeaksTheOrderItIsListedIn() async throws {
        try await withLibrary(notes: 3) { _, model, _, _ in
            await model.search()
            #expect(model.rowStampSort == model.sort, "the Library: its own sort")
            await ask(model, "lantern")
            #expect(model.rowStampSort == model.sort, "relevance: the Library's sort, as before")
            model.pickSearchOrder(.createdAt)
            await model.search()
            #expect(model.rowStampSort == .createdAt, "a home order: its own stamp")
            let hit = try #require(model.noteHits.first)
            #expect(LibrarySortFace.rowStamps(model.rowStampSort, for: hit).sorted.subject == .created)
            await ask(model, "")
            #expect(model.rowStampSort == model.sort, "the search ended: the Library's own again")
        }
    }

    /// **The Books section keeps its own order under every pick** (A-819-B2,
    /// F1 → (a), PROVISIONAL): the door orders the note and scraps groups
    /// only — books carry no stamp in the Library's semantics (its catalog
    /// lists them by name under every sort) and the associated books'
    /// "top-ranked with the reason said" stays whole, so no book stamp is
    /// invented. The groups DO move (the pick took effect); the books do not.
    @Test func theBooksSectionKeepsItsOwnOrderUnderEveryPick() async throws {
        try await withLibrary(notes: 4) { session, model, _, _ in
            // Born in this order; their names' A–Z and their hit strengths
            // disagree with it.
            for name in ["Zed lantern", "Alpha lantern lantern", "Mid lantern lantern lantern"] {
                _ = try session.operations.createReading(name: name, kind: .book)
            }
            await ask(model, "lantern")
            let books = model.searchState.books.map(\.id)
            let groups = model.searchState.groups.map(\.homeID)
            #expect(books.count == 3, "premise: the Books section lists the three")
            var movedGroups = false
            for sort in LibrarySortFace.offered {
                for direction in [SortDirection.desc, .asc] {
                    model.pickSearchOrder(sort)
                    model.pickSearchOrderDirection(direction)
                    await model.search()
                    #expect(model.searchState.books.map(\.id) == books,
                            "\(sort) \(direction): the Books section in its own order")
                    if model.searchState.groups.map(\.homeID) != groups { movedGroups = true }
                }
            }
            #expect(movedGroups, "premise: the picks re-ordered the groups")
        }
    }
}
