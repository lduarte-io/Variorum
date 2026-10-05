//
//  BookcaseStarredShelfTests.swift
//  VariorumTests
//
//  17y B3 item (s) — THE STARRED SHELF (R-17y-9 — her words: "let's do the
//  starred shelf - it is the books only… in library, have an automatic
//  'starred' shelf that isn't deletable… i do think build now tbh"; the
//  rulings file carries both addenda: SHOWN ALWAYS, and the strip row is the
//  bare word — the empty one-liner lives only in the solo'd board).
//
//  VIRTUAL by construction (the Home-wing precedent, R-13ia-2): a SCOPE, no
//  stored shelf row — so "isn't deletable" holds structurally, with zero
//  schema and zero sync. It solos like a shelf; a book shown there still
//  lives on its real shelf (a filter, never a container); a BOOK dropped on
//  its strip word is STARRED through the union star's one road, the cap's
//  refusal spoken as at every star door.
//
//  A ruled BUILD (not a bug-class row): no red-on-old is owed; the pins fix
//  the behaviour and the walk captures the face.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withStarredSession<T>(
    _ body: @MainActor (AppSession, AppDatabase, UserDefaults) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    let suite = "bookcase-starred-\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suite))
    defer { defaults.removePersistentDomain(forName: suite) }
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 13))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db, defaults)
    }
}

private func row(
    _ id: String, _ name: String, kind: ReadingKind = .book, shelf: String? = nil,
    starred: Bool = false, position: String? = nil
) -> Queries.ShelfBook {
    let created = Date(timeIntervalSince1970: 1_782_864_000)
    return Queries.ShelfBook(
        reading: Reading(
            id: id, name: name, kind: kind, shelfId: shelf, shelfPosition: position,
            starred: starred, createdAt: created, updatedAt: created),
        postCount: 0, sectionCount: 0, arrivalCount: 0)
}

private func shelf(_ id: String, _ name: String, _ position: String) -> Shelf {
    Shelf(id: id, name: name, position: position,
          createdAt: Date(timeIntervalSince1970: 0), updatedAt: Date(timeIntervalSince1970: 0))
}

@Suite("17y (s) — the starred shelf: the pure board")
struct BookcaseStarredShelfBrainTests {
    private let shelves = [shelf("w", "Work", "a"), shelf("i", "Ideas", "b")]
    private var books: [Queries.ShelfBook] {
        [
            row("j", "journal", starred: true),                      // unshelved, starred
            row("s", "sherlock", shelf: "w", starred: true),         // on Work, starred
            row("q", "quicknotes", kind: .gathering, starred: true), // a gathering, starred
            row("p", "plain", shelf: "w"),                            // on Work, not starred
            row("x", "idea", shelf: "i"),                             // on Ideas, not starred
        ]
    }

    /// One section, every starred reading from ANY shelf and the unshelved
    /// run (books AND gatherings — the Bookcase's things, never notes), in
    /// the chosen order.
    @Test func itShowsEveryStarredBookFromEveryShelf() {
        let sections = BookcaseBoard.sections(
            books: books, shelves: shelves, scope: .starred, solo: nil,
            mode: .alphabetical, lastEdited: [:])
        #expect(sections.count == 1)
        #expect(sections.first?.kind == .starred)
        #expect(sections.first?.id == BookcaseBoard.starredSectionID)
        #expect(sections.first?.books.map(\.reading.id) == ["j", "q", "s"], "A–Z")
    }

    /// A FILTER, never a container: the starred books keep their shelves —
    /// All still files them exactly where they live.
    @Test func aBookShownThereStillLivesOnItsRealShelf() {
        let all = BookcaseBoard.sections(
            books: books, shelves: shelves, scope: .all, solo: nil,
            mode: .alphabetical, lastEdited: [:])
        let work = all.first { $0.shelfID == "w" }?.books.map(\.reading.id)
        #expect(work == ["s", "p"], "sherlock floats first on Work, and is still ON Work")
        #expect(BookcaseBoard.resolvedShelves(books, shelves: shelves)["s"] == "w")
    }

    /// The census counts what the starred shelf shows; a solo narrows it.
    @Test func theCensusAndTheSolosReadTheStarredScope() {
        let inScope = BookcaseBoard.booksInScope(books, shelves: shelves, scope: .starred)
        #expect(Set(inScope.map(\.reading.id)) == ["j", "s", "q"])
        let census = BookcaseBoard.census(inScope)
        #expect(census[.books] == 2)
        #expect(census[.gatherings] == 1)
        let soloed = BookcaseBoard.sections(
            books: books, shelves: shelves, scope: .starred, solo: .gatherings,
            mode: .alphabetical, lastEdited: [:])
        #expect(soloed.first?.books.map(\.reading.id) == ["q"])
    }

    /// Virtual by construction: it never dangles, never names a shelf to
    /// mint on, and never places by hand (a hand position belongs to a real
    /// shelf — P-17y-B3-s3).
    @Test func itIsVirtualNoMintTargetNoHandPlacing() {
        #expect(BookcaseBoard.effectiveScope(.starred, shelves: []) == .starred,
                "no stored row to die — the scope always draws")
        #expect(BookcaseBoard.mintShelf(for: .starred, shelves: shelves) == nil,
                "a mint while looking at starred lands unshelved (P-17y-B3-s4)")
        #expect(BookcaseBoard.placesByHand(.mine, in: .starred) == false)
        #expect(BookcaseBoard.placesByHand(.mine, in: .all) == true)
        #expect(BookcaseBoard.placesByHand(.mine, in: .shelf("w")) == true)
        #expect(BookcaseBoard.placesByHand(.alphabetical, in: .all) == false)
    }

    /// Shown always, an empty starred set draws one empty section — the
    /// solo'd board's one-liner is the face's; the strip word never counts.
    @Test func anEmptyStarredSetIsOneEmptySection() {
        let sections = BookcaseBoard.sections(
            books: [row("p", "plain")], shelves: [], scope: .starred, solo: nil,
            mode: .alphabetical, lastEdited: [:])
        #expect(sections.count == 1)
        #expect(sections.first?.books.isEmpty == true)
        #expect(!BookcaseCopy.starredShelfName.isEmpty)
        #expect(BookcaseCopy.starredShelfName == "starred", "lowercase, the strip's idiom")
        let help = BookcaseCopy.starredShelfHelp
        let countless = !help.contains { $0.isNumber }
        #expect(countless, "the strip row carries no count (her second addendum)")
    }
}

@MainActor
@Suite("17y (s) — the starred shelf: drop to star", .serialized)
struct BookcaseStarredShelfDropTests {
    private func settle(_ model: ShelfViewModel, until: () -> Bool) async {
        for _ in 0..<200 where !until() { try? await Task.sleep(for: .milliseconds(10)) }
    }

    /// A book dropped on the strip's ★ word is STARRED — both stores (the
    /// union star's one road) — and the starred shelf shows it; it still
    /// lives on its shelf. Dropping a starred book asks for nothing.
    @Test func aBookDroppedOnStarredIsStarred() async throws {
        try await withStarredSession { session, db, defaults in
            let model = ShelfViewModel(session: session, defaults: defaults)
            let observe = Task { await model.start() }
            defer { observe.cancel() }
            let ops = session.operations
            let work = try ops.createShelf(name: "Work")
            let book = try ops.createReading(name: "essays", kind: .book, shelfId: work.id)
            await settle(model) { model.books.count == 1 }

            await model.starBook(book.id)
            let starredIDs = try await db.read { try Queries.starredReadingIDs($0) }
            #expect(starredIDs.contains(book.id), "the union star")
            await settle(model) { model.books.first?.starred == true }
            model.scope = .starred
            #expect(model.sections.first?.books.map(\.reading.id) == [book.id])
            #expect(model.shelfKey(of: book.id) == work.id, "a filter — it stays on Work")
            #expect(session.status.current == nil, "silent on success, like every star door")

            // Already starred: nothing asked, nothing written.
            await model.starBook(book.id)
            #expect(session.status.current == nil)
        }
    }

    /// The cap's refusal speaks exactly as at every star door.
    @Test func atTheCapTheDropRefusesInTheStarDoorsWords() async throws {
        try await withStarredSession { session, _, defaults in
            let model = ShelfViewModel(session: session, defaults: defaults)
            let observe = Task { await model.start() }
            defer { observe.cancel() }
            let ops = session.operations
            for i in 0..<Operations.starLimit {
                let note = try ops.createPost(title: "n\(i)")
                try ops.setStarred(.post(note.id), starred: true)
            }
            let book = try ops.createReading(name: "one more", kind: .book)
            await settle(model) { model.books.contains { $0.reading.id == book.id } }

            await model.starBook(book.id)
            #expect(session.status.current?.kind == .refusal)
            #expect(session.status.current?.text == OpsRefusalCopy.message(
                for: OperationError.starLimitReached(limit: Operations.starLimit)))
            #expect(model.books.first { $0.reading.id == book.id }?.starred == false)
        }
    }
}
