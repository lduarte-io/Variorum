//
//  MobileLibraryPagingRulesTests.swift
//  VariorumMobileTests
//
//  VM-68 (the VM-64 run, batch 5) — the Library's paging and hold RULES, on the
//  model (no view, no shared counters): the pages walk every note once in the
//  listing's own order; a hidden Library reads its note listing once and holds
//  nothing; the return re-asks; a deeper listing follows its first page; the
//  union withholds books it cannot yet place; the shell's on-screen fact. The
//  record is `notes/plans/fixes/vm-64-timing-and-lags.md` (§4 batch 5; §7).
//
//  These pins name VM-68's own API, so they are not part of the red-on-old
//  build (they could not compile against the code before it); the red-on-old
//  pins are `MobileLibraryPagingTests` and the four ASSERTED zeros in
//  `MobileHerPathsPerfTests`.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import VariorumMobile

/// Polls the main actor until `condition` holds (or a generous bound).
@MainActor
private func settle(_ condition: @MainActor () -> Bool) async {
    for _ in 0..<2_000 where !condition() {
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(1))
    }
}

@MainActor
@Suite("VM-68 — the Library's paging and hold rules")
struct MobileLibraryPagingRulesTests {
    /// Notes titled `prefix 000…`, each touched in turn (newest = the last).
    private func seed(_ session: AppSession, _ count: Int, prefix: String = "n") async throws -> [String] {
        try await session.runner.run { ops in
            try (0..<count).map { index in
                let post = try ops.createPost(title: String(format: "\(prefix) %03d", index))
                _ = try ops.newBlock(in: post.id, text: "Words \(index).", at: .end)
                return post.id
            }
        }
    }

    // MARK: - The pages

    /// **Paging walks every note once, in the listing's own order** — the
    /// first page, then `loadMore` to the end, equals `Queries.library`'s
    /// whole listing (ids and stamps), for every sort the phone offers.
    @Test(arguments: MobileLibraryViewModel.sortOptions)
    func loadingMoreWalksEveryNoteOnceInTheListingsOrder(_ sort: Queries.LibrarySort) async throws {
        try await withEditorWorld { session, db in
            _ = try await seed(session, 23)
            let model = MobileLibraryViewModel(session: session, listingLimit: 5)
            model.setSort(sort)
            await model.hold(model.hold(onScreen: false))  // the one read: page one
            #expect(model.all.count == 5)
            #expect(model.allHasMore)
            var guardLoops = 0
            while model.allHasMore, guardLoops < 20 {
                await model.loadMore(.notes)
                guardLoops += 1
            }
            let whole = try await db.read { try Queries.library($0, sort: sort, direction: .desc) }
            #expect(model.all.map(\.postID) == whole.map(\.postID), "\(sort)")
            #expect(model.all.map(\.stamp) == whole.map(\.stamp), "\(sort)")
            #expect(!model.allHasMore)
        }
    }

    /// **A hidden Library reads its note listing ONCE and holds nothing**: a
    /// note minted afterwards is not listed while it stays hidden; on screen
    /// (the return), the held page lists it.
    @Test func aHiddenLibraryHoldsNothingAndTheReturnReAsks() async throws {
        try await withEditorWorld { session, _ in
            _ = try await seed(session, 3)
            let model = MobileLibraryViewModel(session: session)
            await model.hold(model.hold(onScreen: false))  // returns: nothing held
            #expect(model.all.count == 3)
            let late = try await session.runner.run { ops in
                try ops.createPost(title: "late").id
            }
            try? await Task.sleep(for: .milliseconds(150))
            #expect(!model.all.contains { $0.postID == late }, "a hidden Library re-read on a write")

            let onScreen = Task { await model.hold(model.hold(onScreen: true)) }
            defer { onScreen.cancel() }
            await settle { model.all.contains { $0.postID == late } }
            #expect(model.all.first?.postID == late, "the return re-asks: the new note leads")
        }
    }

    /// **On screen, a deeper listing FOLLOWS its first page** (the Mac's
    /// `followListingMove`): with two pages listed, a note that moves to the
    /// top re-asks the listed depth in place — the listing stays two pages
    /// deep, in order, with the moved note first and listed once.
    @Test func aDeeperListingFollowsItsFirstPage() async throws {
        try await withEditorWorld { session, db in
            let ids = try await seed(session, 12)
            let model = MobileLibraryViewModel(session: session, listingLimit: 4)
            let held = Task { await model.hold(model.hold(onScreen: true)) }
            defer { held.cancel() }
            await settle { model.all.count == 4 }
            await model.loadMore(.notes)
            #expect(model.all.count == 8)
            // The oldest note is touched again (a sync apply's shape: its
            // stamp moves) — it moves to the top of the edited sort.
            let oldest = ids[0]
            try await db.write { db in
                try db.execute(
                    sql: "UPDATE container SET last_touched_at = '2099-01-01T00:00:00.000Z' WHERE id = ?",
                    arguments: [oldest])
            }
            await settle { model.all.first?.postID == oldest }
            #expect(model.all.first?.postID == oldest, "the moved note leads")
            #expect(model.all.count == 8, "the listed depth is kept")
            #expect(Set(model.all.map(\.postID)).count == 8, "no note twice")
            let expected = try await db.read {
                try Queries.library($0, sort: .lastTouched, direction: .desc, limit: 8)
            }
            #expect(model.all.map(\.postID) == expected.map(\.postID))
        }
    }

    /// **A new question starts over**: flipping the sort while two pages are
    /// listed lands the new sort's FIRST page, not the old depth.
    @Test func aNewQuestionStartsAtItsFirstPage() async throws {
        try await withEditorWorld { session, _ in
            _ = try await seed(session, 10)
            let model = MobileLibraryViewModel(session: session, listingLimit: 3)
            await model.hold(model.hold(onScreen: false))
            await model.loadMore(.notes)
            #expect(model.all.count == 6)
            model.setSort(.createdAt)
            await model.hold(model.hold(onScreen: false))
            #expect(model.all.count == 3, "a new question is its first page")
        }
    }

    /// **The Bookless door says nothing until its first answer**, then the
    /// truth: the trio over an empty wing, its own line over booked notes.
    @Test func theBooklessDoorSpeaksOnlyOnceItHasAnswered() async throws {
        try await withEditorWorld { session, _ in
            let model = MobileLibraryViewModel(session: session)
            model.filter = .bookless
            #expect(model.emptyListing(booksShown: 0) == nil, "no line before the first answer")
            let held = Task { await model.hold(model.hold(onScreen: true)) }
            await settle { model.booklessLoaded }
            #expect(model.emptyListing(booksShown: 0) == .storeEmpty)
            held.cancel()
            await held.value

            try await session.runner.run { ops in
                let book = try ops.createReading(name: "b", kind: .book)
                let note = try ops.createPost(title: "booked")
                _ = try ops.addPostToReading(note.id, to: book.id)
            }
            let again = Task { await model.hold(model.hold(onScreen: true)) }
            defer { again.cancel() }
            await settle { model.emptyListing(booksShown: 0) == .noBookless }
            #expect(model.emptyListing(booksShown: 0) == .noBookless)
        }
    }

    /// The hold key: a note listing per filter (none for Books and Scraps),
    /// the sort for the note listing only, and the screen.
    @Test func theHoldKeyNamesTheShownListing() async throws {
        try await withEditorWorld { session, _ in
            let model = MobileLibraryViewModel(session: session)
            #expect(model.hold(onScreen: true).question?.listing == .notes)
            model.filter = .bookless
            #expect(model.hold(onScreen: true).question?.listing == .bookless)
            #expect(model.hold(onScreen: true).question?.sort == .lastTouched)
            for door in [MobileListingFilter.books, .scraps] {
                model.filter = door
                #expect(model.hold(onScreen: true).question == nil)
            }
            model.filter = .all
            let before = model.hold(onScreen: true)
            model.setSort(.createdAt)
            #expect(model.hold(onScreen: true) != before, "a sort flip restarts the hold")
            #expect(model.hold(onScreen: false) != model.hold(onScreen: true))
        }
    }

    // MARK: - Pure

    /// **The union of a paged listing withholds what it cannot yet place**:
    /// while notes remain, a book older than the last listed note waits; when
    /// every note is listed, every book shows.
    @Test func theUnionWithholdsBooksOlderThanTheLastListedNote() {
        func note(_ id: String, _ stamp: String) -> Queries.TimelineItem {
            Queries.TimelineItem(postID: id, title: id, entryDate: nil, stamp: stamp)
        }
        func book(_ id: String, _ seconds: TimeInterval) -> Queries.ShelfBook {
            let date = Date(timeIntervalSince1970: seconds)
            return Queries.ShelfBook(
                reading: Reading(
                    id: id, name: id, kind: .book, createdAt: date, updatedAt: date),
                postCount: 0, sectionCount: 0)
        }
        let notes = [
            note("n3", DateFormatter.variorumISO8601.string(from: Date(timeIntervalSince1970: 3_000))),
            note("n2", DateFormatter.variorumISO8601.string(from: Date(timeIntervalSince1970: 2_000))),
        ]
        let books = [book("new", 2_500), book("old", 1_000)]
        let paged = MobileLibraryViewModel.union(
            notes: notes, books: books, sort: .lastTouched, notesComplete: false)
        #expect(paged.map(\.id) == ["note:n3", "book:new", "note:n2"],
                "the older book waits for the notes not yet read")
        let whole = MobileLibraryViewModel.union(
            notes: notes, books: books, sort: .lastTouched, notesComplete: true)
        #expect(whole.map(\.id) == ["note:n3", "book:new", "note:n2", "book:old"])
        #expect(MobileLibraryViewModel.union(notes: notes, books: books, sort: .lastTouched).map(\.id)
                == whole.map(\.id), "the default is the whole listing (every existing caller)")
    }

    /// **A page's hits become the listing's rows**: the stored title (nil when
    /// absent), the stated day, the birth stamp, the profile, and the row's
    /// sort key as its stamp.
    @Test func aPagesHitsBecomeTheListingsRows() {
        let page = Queries.CatalogNotesPage(
            hits: [
                Queries.CatalogHit(
                    kind: .post, id: "a", title: "Alpha", detail: "2026-05-01",
                    storedTitle: "Alpha", createdAt: "2026-04-01T00:00:00.000Z",
                    lastTouchedAt: "2026-05-02T00:00:00.000Z", profile: "journal"),
                Queries.CatalogHit(
                    kind: .post, id: "b", title: "2026-04-03", detail: nil,
                    storedTitle: nil, createdAt: "2026-04-03T00:00:00.000Z"),
            ],
            next: nil, keys: ["K-a", "K-b"])
        let rows = MobileLibraryViewModel.timelineItems(page)
        #expect(rows == [
            Queries.TimelineItem(
                postID: "a", title: "Alpha", entryDate: "2026-05-01",
                createdAt: "2026-04-01T00:00:00.000Z", stamp: "K-a", profile: "journal"),
            Queries.TimelineItem(
                postID: "b", title: nil, entryDate: nil,
                createdAt: "2026-04-03T00:00:00.000Z", stamp: "K-b", profile: nil),
        ])
    }

    /// **The shell's on-screen fact** (`MobileShellBand.isDrawn`): the current
    /// page is drawn; a neighbour only while a drag pulls it into view; a page
    /// two away never; a zero-width pass draws only the current page.
    @Test func aPageIsDrawnOnlyWhileAnyOfItShows() {
        let width: CGFloat = 393
        #expect(MobileShellBand.isDrawn(.library, current: .library, drag: 0, width: width))
        #expect(!MobileShellBand.isDrawn(.library, current: .shelf, drag: 0, width: width))
        #expect(MobileShellBand.isDrawn(.library, current: .shelf, drag: -1, width: width),
                "a drag toward the Library reveals it")
        #expect(!MobileShellBand.isDrawn(.library, current: .shelf, drag: 40, width: width),
                "a drag the other way does not")
        #expect(!MobileShellBand.isDrawn(.library, current: .starred, drag: -width, width: width),
                "two pages away is never drawn")
        #expect(MobileShellBand.isDrawn(.shelf, current: .library, drag: 10, width: width))
        #expect(MobileShellBand.isDrawn(.shelf, current: .shelf, drag: 0, width: 0))
        #expect(!MobileShellBand.isDrawn(.library, current: .shelf, drag: -10, width: 0))
    }
}
