//
//  LibraryPagingModelTests.swift
//  VariorumTests
//
//  **17y B1 item (k) — the Library model's paging brain** (the mounted
//  use-shaped half is `LibraryInfiniteScrollTests`, red on the pre-fix tree;
//  these pin the brain's P1 discipline, which the pre-fix tree had no form of
//  — BUILD pins for the new road, said honestly):
//
//  - a scroll near the end asks for the NEXT page — and nothing listed is
//    read again (the rows that stand are the same rows, in the same order);
//  - the extras (chips, card words) and the HELD ownership observation cover
//    the NEAR WINDOW only — a few pages, however deep she scrolls — and the
//    held region is blind to a keystroke (the U1 P1-pin pattern);
//  - an act on a row re-reads IN PLACE at the depth she has scrolled to; a
//    new question starts over, and a page it superseded never lands;
//  - the window and the books-region rules, pure.
//

import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("17y B1 (k) — the Library model pages, windows and re-reads in place", .serialized)
struct LibraryPagingModelTests {
    private final class Clock: @unchecked Sendable {
        private let state = LockIsolated(Date(timeIntervalSince1970: 1_782_864_000))
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(41) }
                return value
            }
        }
    }

    private func withNotes<T>(
        _ count: Int,
        _ body: @MainActor (AppSession, LibraryCatalogModel, [String]) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let clock = Clock()
        return try await withDependencies {
            $0.database = db
            $0.uuid = UUIDGenerator { UUID() }
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 43))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            // Newest LAST in creation order, so the listing (edited, newest
            // first) is `ids.reversed()`.
            let ids = try (0..<count).map { index in
                let note = try session.operations.createPost(title: "note \(index)")
                _ = try session.operations.newBlock(in: note.id, text: "words \(index)")
                return note.id
            }
            let suite = "17y-b1-k-model-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defaults.removePersistentDomain(forName: suite)
            let model = LibraryCatalogModel(session: session, defaults: defaults)
            return try await body(session, model, ids)
        }
    }

    private var page: Int { LibraryCatalogModel.pageSize }

    @Test func aScrollNearTheEndAsksForTheNextPageAndKeepsWhatStands() async throws {
        try await withNotes(page * 2 + 17) { _, model, ids in
            await model.search()
            #expect(model.noteHits.count == page)
            #expect(model.notesHaveMore)
            let firstPage = model.noteHits
            let generation = model.searchGeneration

            // A row well before the end: nothing is asked for.
            await model.appear(firstPage[10].id)
            #expect(model.noteHits.count == page, "row 10 is not near the end")

            // A row within the margin: the next page.
            await model.appear(firstPage[page - 5].id)
            #expect(model.noteHits.count == page * 2)
            #expect(Array(model.noteHits.prefix(page)) == firstPage,
                    "what stood is what stands — the same rows, the same order")
            #expect(model.searchGeneration == generation, "no new question was asked")

            // …and to the end.
            await model.appear(model.noteHits[page * 2 - 3].id)
            #expect(model.noteHits.map(\.id) == ids.reversed(), "every note, in the listing's order")
            #expect(!model.notesHaveMore)
        }
    }

    @Test func theNearWindowBoundsTheExtrasAndTheHeldFacts() async throws {
        try await withNotes(page * 4) { session, model, _ in
            let tag = try session.operations.createTag(parent: nil, name: "everywhere")
            let all = try await session.database.read {
                try String.fetchAll($0, sql: "SELECT id FROM container WHERE kind = 'post'")
            }
            let tagID = tag.id
            try await session.runner.run { ops in
                for id in all { _ = try ops.applyTag(tagID, toPost: id) }
            }
            await model.search()
            for _ in 0..<3 {
                await model.appear(model.noteHits[model.noteHits.count - 2].id)
            }
            #expect(model.noteHits.count == page * 4)
            // She is looking at page 3 (rows 3×page …).
            for position in (page * 3)..<(page * 3 + 20) {
                model.noteRowAppeared(model.noteHits[position].id, spawning: false)
            }
            for position in 0..<(page * 3) {
                model.noteRowDisappeared(model.noteHits[position].id, spawning: false)
            }
            await model.settleExtras()
            #expect(model.nearPages == 2...3, "the visible page and its neighbours")
            let near = Set(model.nearNoteIDs)
            #expect(near.count <= page * 3, "the held region is a few pages, not the listing")
            #expect(!near.contains(model.noteHits[0].id), "page 0 is not held while she reads page 3")
            #expect(Set(model.postTags.keys).isSuperset(of: near), "the near rows wear their chips")
        }
    }

    // (The held facts' REGION — blind to a keystroke — is pinned in core,
    // `LibraryPagingTests.theHeldOwnershipFactsAreBlindToAKeystroke`, where
    // the observation can be built over a bare queue; the window test above
    // pins that what is held is the near window's ids.)

    @Test func anActReReadsInPlaceAtTheDepthSheScrolledTo() async throws {
        try await withNotes(page * 3) { session, model, _ in
            await model.search()
            await model.appear(model.noteHits[page - 3].id)
            #expect(model.noteHits.count == page * 2)
            let target = model.noteHits[page + 7].id
            let tag = try session.operations.createTag(parent: nil, name: "deep")
            await model.applyTag(tag.id, to: [target])
            #expect(model.noteHits.count == page * 2, "the act kept her depth — no snap to page one")
            #expect(model.noteHits.contains { $0.id == target })
        }
    }

    @Test func aNewQuestionStartsOverAndASupersededPageNeverLands() async throws {
        try await withNotes(page * 3) { _, model, _ in
            await model.search()
            await model.appear(model.noteHits[page - 3].id)
            #expect(model.noteHits.count == page * 2)
            model.setSort(.title)
            await model.search()
            #expect(model.noteHits.count == page, "a new question is a first page")
            // A page read begun under the OLD question, landing after the new
            // one was asked, is dropped.
            let stale = Task { await model.loadMoreNotes() }
            model.query = "note 1"
            await model.search()
            await stale.value
            #expect(model.noteHits.allSatisfy { $0.title.contains("note 1") },
                    "nothing of the superseded page landed")
        }
    }

    /// The listing GROWS by what it already lists (measured: a landing's
    /// stall barely moves with the page's size, so fewer, larger landings),
    /// each page still ONE bounded read, capped at `maxPageSize`.
    @Test func theNextPageGrowsWithTheListing() async throws {
        try await withNotes(page * 7 + 9) { _, model, ids in
            await model.search()
            var counts = [model.noteHits.count]
            while model.notesHaveMore {
                await model.appear(model.noteHits[model.noteHits.count - 2].id)
                counts.append(model.noteHits.count)
            }
            #expect(counts == [page, page * 2, page * 4, page * 7 + 9])
            #expect(model.noteHits.map(\.id) == ids.reversed())
            #expect(LibraryCatalogModel.maxPageSize >= page)
        }
    }

    /// A page read while the rows are MOVING waits for them to rest — the
    /// landing's stall falls in a pause, never under her moving hand —
    /// unless she is within `landNowMargin` rows of the end, where it lands
    /// at once (she never reaches an end that is not the Library's).
    @Test func aPageReadMidScrollLandsWhenTheRowsRest() async throws {
        try await withNotes(page * 3) { _, model, _ in
            await model.search()
            let firstPage = model.noteHits
            // Mid-scroll, far from the end: the page waits.
            model.noteRowAppeared(firstPage[10].id, spawning: false)
            model.listMoving = true
            await model.loadMoreNotes()
            #expect(model.noteHits == firstPage, "nothing landed under her moving hand")
            #expect(model.pendingLanding != nil)
            #expect(model.loadingMoreNotes, "the page is in hand, not yet listed")
            model.rowsRested()
            #expect(model.noteHits.count == page * 2, "it landed when the rows rested")
            #expect(Array(model.noteHits.prefix(page)) == firstPage)

            // Mid-scroll AT the margin: it lands at once.
            model.listMoving = true
            model.noteRowAppeared(model.noteHits[page * 2 - 3].id, spawning: false)
            await model.loadMoreNotes()
            #expect(model.noteHits.count == page * 3, "within the margin the page lands at once")
            #expect(model.pendingLanding == nil)
        }
    }

    /// While a NEW question is being read, no page is asked for — the old
    /// listing's cursor under the new query and sort could land after the
    /// new listing (rows out of order or skipped). A hole in this batch's own
    /// new road, closed at self-review; a build pin of the guard.
    @Test func noPageIsAskedForWhileANewQuestionIsRead() async throws {
        try await withNotes(page * 3) { _, model, _ in
            await model.search()
            let generation = model.searchGeneration
            model.setSort(.title)
            let fresh = Task { await model.search() }
            await Task.yield()
            #expect(model.searchGeneration == generation + 1, "the new question is in flight")
            #expect(!model.noteRowAppeared(model.noteHits[page - 2].id, spawning: false),
                    "a row near the old listing's end asks for nothing")
            await model.loadMoreNotes()
            #expect(!model.loadingMoreNotes && model.pendingLanding == nil)
            await fresh.value
            #expect(model.noteHits.count == page, "the new question's first page, and only it")
            // …and once it is listed, paging resumes on ITS cursor.
            await model.appear(model.noteHits[page - 2].id)
            #expect(model.noteHits.count == page * 2)
        }
    }

    @Test func theNearWindowIsThePagesAroundWhatIsOnScreen() {
        let p = LibraryCatalogModel.pageSize
        #expect(LibraryCatalogModel.window(visible: [], count: 0) == 0...0)
        #expect(LibraryCatalogModel.window(visible: [], count: p * 5) == 0...1)
        #expect(LibraryCatalogModel.window(visible: [3, 20], count: p * 5) == 0...1)
        #expect(LibraryCatalogModel.window(visible: [p * 2 + 3], count: p * 5) == 1...3)
        #expect(LibraryCatalogModel.window(visible: [p * 4 + 1], count: p * 4 + 10) == 3...4)
    }

    @Test func theBooksSplitOffOnlyPastHalfUnderAll() {
        let h: CGFloat = 600
        #expect(!LibraryBooksRegion.capsBooks(
            scope: .all, books: 5, showsMore: true, pitch: 25, lead: 30, height: h))
        #expect(LibraryBooksRegion.capsBooks(
            scope: .all, books: 12, showsMore: true, pitch: 25, lead: 30, height: h),
                "30 + 12 × 25 = 330 > 300")
        #expect(!LibraryBooksRegion.capsBooks(
            scope: .books, books: 400, showsMore: true, pitch: 25, lead: 30, height: h),
                "the Books scope is all books — nothing to make room for")
        #expect(!LibraryBooksRegion.capsBooks(
            scope: .all, books: 400, showsMore: false, pitch: 25, lead: 30, height: h),
                "nothing below the books — they keep the whole listing")
        #expect(LibraryBooksRegion.cappedHeight(601) == 301)
    }
}

extension LibraryCatalogModel {
    /// The pins' synchronous form of "a row came on screen": the appearance
    /// (without its spawned tasks), then the page read IF it asked, then the
    /// near extras.
    func appear(_ id: String) async {
        if noteRowAppeared(id, spawning: false) { await loadMoreNotes() }
        await settleExtras()
    }

    /// Run the near window's extras load to completion (the views spawn it).
    func settleExtras() async {
        await loadNearExtras(generation: searchGeneration, replacing: false)
    }
}
