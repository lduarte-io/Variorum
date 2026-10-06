//
//  BookcaseBoardTests.swift
//  VariorumTests
//
//  13i-d U1 — THE BOOKCASE BOARD (the sitting record §7, §19–§24; the plan's
//  U1 RECORD, evidence E3/E4). Two layers: the pure board brain
//  (`BookcaseBoard` + the row meta's words), and the view model over a real
//  session — the context mint, the drops, my order's doors, the default
//  shelf, the local memory, and the one status seam.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withBookcaseSession<T>(
    _ body: @MainActor (AppSession, AppDatabase, UserDefaults) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_864_000)
    let tick = LockIsolated(0)
    // R1-7's lesson: never the Debug app's `.standard` — a scratch suite.
    let suite = "bookcase-tests-\(UUID().uuidString)"
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 11))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db, defaults)
    }
}

private func book(
    _ id: String, _ name: String, kind: ReadingKind = .book, shelf: String? = nil,
    position: String? = nil, starred: Bool = false, locked: Bool = false,
    owned: Bool = false, sealed: Bool = false, rule: String? = nil,
    created: Date = Date(timeIntervalSince1970: 1_782_864_000), arrivals: Int = 0,
    posts: Int = 0, sections: Int = 0
) -> Queries.ShelfBook {
    Queries.ShelfBook(
        reading: Reading(
            id: id, name: name, kind: kind, querySpec: rule, locked: locked || sealed,
            shelfId: shelf, shelfPosition: position, starred: starred, owned: owned,
            sealedAt: sealed ? created : nil, createdAt: created, updatedAt: created),
        postCount: posts, sectionCount: sections, arrivalCount: arrivals)
}

private func shelf(_ id: String, _ name: String, _ position: String) -> Shelf {
    Shelf(id: id, name: name, position: position,
          createdAt: Date(timeIntervalSince1970: 0), updatedAt: Date(timeIntervalSince1970: 0))
}

// MARK: - The pure brain (E3)

@Suite("Bookcase board — the pure brain (13i-d U1)")
struct BookcaseBoardBrainTests {
    /// §24: A–Z (default) · last edited · my order — and STARRED floats
    /// first under every one of them.
    @Test func theThreeOrdersAndTheStarredFloat() {
        let books = [
            book("c", "cello", position: "V"),
            book("a", "Apple"),
            book("b", "banjo", position: "U", starred: true),
            book("d", "drum", starred: true),
        ]
        let edited = ["a": "2026-07-03T00:00:00.000Z", "c": "2026-07-05T00:00:00.000Z",
                      "b": "2026-07-01T00:00:00.000Z", "d": "2026-07-02T00:00:00.000Z"]
        #expect(BookcaseBoard.ordered(books, mode: .alphabetical, lastEdited: edited)
            .map(\.reading.id) == ["b", "d", "a", "c"], "A–Z, the starred pair first")
        #expect(BookcaseBoard.ordered(books, mode: .lastEdited, lastEdited: edited)
            .map(\.reading.id) == ["d", "b", "c", "a"], "newest first inside each half")
        #expect(BookcaseBoard.ordered(books, mode: .mine, lastEdited: edited)
            .map(\.reading.id) == ["b", "d", "c", "a"],
            "placed by position, never-placed A–Z after — inside each half")
    }

    /// 13i-d U2 ACT 0 (F-U1-2 (A), ruled): the float reads the UNION
    /// (`ShelfBook.starred`), never the column alone — a book starred only in
    /// the 13f list (a pre-ACT-0 ★) floats exactly like a pinned one. RED by
    /// behavioural revert: filtering on `reading.starred` sinks it.
    @Test func theFloatReadsTheUnionNotTheColumn() {
        let plain = book("a", "Apple")
        let listOnly = Queries.ShelfBook(
            reading: book("z", "zither").reading, postCount: 0, sectionCount: 0,
            starred: true)
        #expect(listOnly.reading.starred == false, "the column is unset")
        #expect(BookcaseBoard.ordered([plain, listOnly], mode: .alphabetical, lastEdited: [:])
            .map(\.reading.id) == ["z", "a"], "the list-only star floats first")
    }

    @Test func lastEditedFallsBackToTheBooksBirthWhileAggregatesLoad() {
        let older = book("o", "older", created: Date(timeIntervalSince1970: 1_000))
        let newer = book("n", "newer", created: Date(timeIntervalSince1970: 9_000))
        #expect(BookcaseBoard.ordered([older, newer], mode: .lastEdited, lastEdited: [:])
            .map(\.reading.id) == ["n", "o"])
    }

    /// §23's six solos, and LIVING as the sitting defined it (§1): a live,
    /// unfinished BOOK whose rule reads.
    @Test func theCensusCountsAndItsSolos() throws {
        let rule = try RuleGrammar.encode(.star)
        let books = [
            book("1", "plain"),
            book("2", "living", rule: rule, arrivals: 2),
            book("3", "finished living", locked: true, rule: rule),
            book("4", "owned", owned: true),
            book("5", "sealed", sealed: true),
            book("6", "gathering", kind: .gathering, rule: rule),
        ]
        let census = BookcaseBoard.census(books)
        #expect(census[.books] == 5)
        #expect(census[.gatherings] == 1)
        #expect(census[.finished] == 2, "sealed is finished too (§5)")
        #expect(census[.owned] == 1)
        #expect(census[.living] == 1, "a finished book's intake is paused; a gathering never lives")
        #expect(census[.arrivals] == 1)
        #expect(BookcaseSolo.arrivals.label(count: 1) == "1 with arrivals")
        #expect(BookcaseSolo.books.label(count: 1) == "1 book")
    }

    /// §24: UNSHELVED at the TOP of All; shelves in STRIP order; a dangling
    /// pointer reads as unshelved (§19); an empty shelf still shows its
    /// header — unless a solo is in force, when it folds away (§22).
    @Test func allStacksUnshelvedFirstThenShelvesInStripOrder() {
        let shelves = [shelf("s2", "Work", "U"), shelf("s1", "Welcome", "V"), shelf("s3", "Empty", "W")]
        let books = [
            book("a", "a", shelf: "s1"),
            book("b", "b", kind: .gathering, shelf: "s2"),
            book("c", "c"),
            book("d", "d", shelf: "gone"),  // a deleted shelf's pointer
        ]
        let all = BookcaseBoard.sections(
            books: books, shelves: shelves, scope: .all, solo: nil,
            mode: .alphabetical, lastEdited: [:])
        #expect(all.map(\.id) == ["unshelved", "s2", "s1", "s3"])
        #expect(all[0].books.map(\.reading.id) == ["c", "d"], "the dangling pointer is unshelved")
        #expect(all[3].books.isEmpty, "an empty shelf still draws (a new shelf is visible)")

        let soloed = BookcaseBoard.sections(
            books: books, shelves: shelves, scope: .all, solo: .gatherings,
            mode: .alphabetical, lastEdited: [:])
        #expect(soloed.map(\.id) == ["s2"], "under a solo, a shelf with no matches folds away")

        let onWelcome = BookcaseBoard.sections(
            books: books, shelves: shelves, scope: .shelf("s1"), solo: nil,
            mode: .alphabetical, lastEdited: [:])
        #expect(onWelcome.map(\.id) == ["s1"])
        #expect(onWelcome[0].books.map(\.reading.id) == ["a"], "unshelved books show in no solo")

        let deadSolo = BookcaseBoard.sections(
            books: books, shelves: shelves, scope: .shelf("gone"), solo: nil,
            mode: .alphabetical, lastEdited: [:])
        #expect(deadSolo.map(\.id) == all.map(\.id), "a dead solo'd shelf reads as All")
    }

    /// §19.1/§24 — the CONTEXT MINT's target.
    @Test func theContextMintLandsOnTheSoloedShelfElseUnshelved() {
        let shelves = [shelf("s1", "Work", "U")]
        #expect(BookcaseBoard.mintShelf(for: .shelf("s1"), shelves: shelves) == "s1")
        #expect(BookcaseBoard.mintShelf(for: .all, shelves: shelves) == nil)
        #expect(BookcaseBoard.mintShelf(for: .shelf("gone"), shelves: shelves) == nil)
    }

    /// The census counts what is in SCOPE — a solo'd shelf's census never
    /// promises books the solo could not show.
    @Test func theCensusCountsTheScope() {
        let shelves = [shelf("s1", "Work", "U")]
        let books = [book("a", "a", shelf: "s1"), book("b", "b"), book("c", "c")]
        #expect(BookcaseBoard.booksInScope(books, shelves: shelves, scope: .shelf("s1"))
            .map(\.reading.id) == ["a"])
        #expect(BookcaseBoard.booksInScope(books, shelves: shelves, scope: .all).count == 3)
        #expect(BookcaseBoard.shelfCounts(books, shelves: shelves) == ["s1": 1, "": 2])
    }

    /// The row meta's words (mockup v5's right column) in the ruled
    /// vocabulary — and the accent arrival count kept apart.
    @Test func theRowMetaSaysTheRuledWords() throws {
        let rule = try RuleGrammar.encode(.star)
        let living = book("l", "l", rule: rule, arrivals: 2, posts: 9, sections: 9)
        #expect(BookcaseRowMeta.arrivals(living) == "2 arrivals")
        #expect(BookcaseRowMeta.facts(living, words: 3_104, progress: nil, gatheringCount: nil)
            == "9 notes \u{00B7} 9 ch \u{00B7} 3,104w \u{00B7} living")
        let owned = book("o", "o", owned: true, sealed: true, posts: 1)
        #expect(BookcaseRowMeta.arrivals(owned) == nil)
        #expect(BookcaseRowMeta.facts(owned, words: 0, progress: nil, gatheringCount: nil)
            == "1 note \u{00B7} sealed \u{00B7} owned", "sealed says sealed, not finished")
        let gathering = book("g", "g", kind: .gathering, rule: rule)
        #expect(BookcaseRowMeta.facts(gathering, words: 40, progress: nil, gatheringCount: 23)
            == "23 notes \u{00B7} 40w \u{00B7} gathering")
        let target = book("t", "t", posts: 2)
        #expect(BookcaseRowMeta.facts(target, words: 6_200, progress: (62, 10_000), gatheringCount: nil)
            == "2 notes \u{00B7} 62% of 10,000w")
    }
}

// MARK: - The view model over a real session (E4)

/// Ladder A round 1, NIT 3 (P-2 — red by BEHAVIOURAL REVERT: the gate
/// flipped to `true` turns the first case red; a new pure value has no
/// pre-fix shape to run against): the book row's "Move to Shelf ▸" submenu
/// is drawn only where it can act — a shelf-less wing's unshelved book has
/// no destination (the empty submenu the walk's class bans). A pure value
/// over the nonisolated `BookcaseBoard` — no actor isolation needed.
@Suite("The Move to Shelf gate (ladder A round 1, NIT 3)")
struct MoveToShelfGateTests {
    @Test func theSubmenuDrawsOnlyWhereItCanAct() {
        #expect(!BookcaseBoard.moveToShelfCanAct(
            shelfCount: 0, here: BookcaseBoard.unshelvedKey),
            "no shelves + unshelved = nowhere to move — not drawn")
        #expect(BookcaseBoard.moveToShelfCanAct(shelfCount: 1, here: BookcaseBoard.unshelvedKey),
                "a shelf exists — it can move there")
        #expect(BookcaseBoard.moveToShelfCanAct(shelfCount: 0, here: "s1"),
                "on a (dying) shelf — Unshelved is a destination")
        #expect(BookcaseBoard.moveToShelfCanAct(shelfCount: 3, here: "s1"))
    }
}

@MainActor
@Suite("Bookcase view model (13i-d U1)", .serialized)
struct BookcaseViewModelTests {
    private func settle(_ model: ShelfViewModel, until: () -> Bool) async {
        for _ in 0..<200 where !until() { try? await Task.sleep(for: .milliseconds(10)) }
    }

    /// §19.1/§24: + New Book while a shelf is solo'd lands ON it; from All
    /// it lands UNSHELVED — through the very road the prompt takes
    /// (`ReadingsViewModel.create(shelfId: model.mintShelfID)`).
    @Test func theContextMintFollowsTheStrip() async throws {
        try await withBookcaseSession { session, db, defaults in
            let model = ShelfViewModel(session: session, defaults: defaults)
            let readings = ReadingsViewModel(session: session)
            let observe = Task { await model.start() }
            defer { observe.cancel() }
            let work = try #require(await model.createShelf(named: "Work"))
            await settle(model) { model.shelves.count == 1 }

            model.scope = .shelf(work)
            let filed = try #require(await readings.create(
                name: "filed", kind: .book, shelfId: model.mintShelfID))
            model.scope = .all
            let loose = try #require(await readings.create(
                name: "loose", kind: .book, shelfId: model.mintShelfID))
            let shelves = try await db.read { db in
                (try Queries.reading(db, id: filed)?.shelfId, try Queries.reading(db, id: loose)?.shelfId)
            }
            #expect(shelves.0 == work, "minted while Work was solo'd — it lands on Work")
            #expect(shelves.1 == nil, "minted from All — unshelved (§19)")
        }
    }

    /// A drop onto a shelf's name re-shelves and SPEAKS a receipt on the one
    /// status seam (18i — the quiet slot under her default), never an
    /// overlay; a refusal toasts.
    @Test func reShelvingSpeaksOnTheStatusSeam() async throws {
        try await withBookcaseSession { session, db, defaults in
            let model = ShelfViewModel(session: session, defaults: defaults)
            let observe = Task { await model.start() }
            defer { observe.cancel() }
            let work = try #require(await model.createShelf(named: "Work"))
            let bookID = try session.operations.createReading(name: "draft", kind: .book).id
            await settle(model) { model.books.count == 1 && model.shelves.count == 1 }

            await model.reshelve(bookID, to: work)
            #expect(try await db.read { try Queries.reading($0, id: bookID)?.shelfId } == work)
            #expect(model.lastReport == "Moved \u{201C}draft\u{201D} to Work.")
            #expect(session.status.quietLine?.text == model.lastReport, "the quiet slot, not a toast")

            await model.renameShelf(work, to: "  ")
            #expect(session.status.current?.kind == .refusal)
            #expect(session.status.current?.text == "A shelf needs a name.")
        }
    }

    /// My order (§20/§24): Send to Top / Bottom, and a book dropped onto a
    /// row of ANOTHER shelf lands exactly above it there.
    @Test func myOrdersDoorsAndTheCrossShelfDrop() async throws {
        try await withBookcaseSession { session, db, defaults in
            let model = ShelfViewModel(session: session, defaults: defaults)
            // JUSTIFIED EDIT (librarywalkpolish VR-118): my order steps back
            // for 0.9.2 — the MACHINERY stays pinned for its return (VR-120),
            // turned on per model by the one value its return flips.
            model.handPlacingOffered = true
            model.orderMode = .mine
            let observe = Task { await model.start() }
            defer { observe.cancel() }
            let ops = session.operations
            let work = try ops.createShelf(name: "Work")
            let ideas = try ops.createShelf(name: "Ideas")
            let a = try ops.createReading(name: "a", kind: .book, shelfId: work.id)
            let b = try ops.createReading(name: "b", kind: .book, shelfId: work.id)
            let x = try ops.createReading(name: "x", kind: .book, shelfId: ideas.id)
            let y = try ops.createReading(name: "y", kind: .book, shelfId: ideas.id)
            await settle(model) { model.books.count == 4 }

            await model.place(b.id, at: .top)
            await settle(model) { model.sections.first { $0.id == work.id }?.books.first?.reading.id == b.id }
            #expect(model.sections.first { $0.id == work.id }?.books.map(\.reading.id) == [b.id, a.id])

            await model.dropBook(x.id, before: a.id)
            await settle(model) { model.shelfKey(of: x.id) == work.id }
            await settle(model) {
                model.sections.first { $0.id == work.id }?.books.map(\.reading.id) == [b.id, x.id, a.id]
            }
            #expect(model.sections.first { $0.id == work.id }?.books.map(\.reading.id) == [b.id, x.id, a.id],
                    "re-shelved AND placed right above the row it was dropped on")
            #expect(model.sections.first { $0.id == ideas.id }?.books.map(\.reading.id) == [y.id])
            _ = db
        }
    }

    /// The DEFAULT shelf (§7, Make Default) opens the board; deleting it
    /// falls back to All (P-13id-U1-1). Local, remembered per wing.
    @Test func theDefaultShelfOpensTheBoardAndDiesGracefully() async throws {
        try await withBookcaseSession { session, _, defaults in
            let first = ShelfViewModel(session: session, defaults: defaults)
            #expect(first.scope == .all, "no default chosen: the Bookcase opens on All")
            let observe = Task { await first.start() }
            defer { observe.cancel() }
            let work = try #require(await first.createShelf(named: "Work"))
            first.makeDefault(work)

            let reopened = ShelfViewModel(session: session, defaults: defaults)
            #expect(reopened.scope == .shelf(work), "it opens SOLO on the default shelf")
            #expect(reopened.defaultShelfID == work)

            await settle(first) { first.shelves.count == 1 }
            first.scope = .shelf(work)
            await first.deleteShelf(work)
            #expect(first.scope == .all)
            #expect(first.defaultShelfID == nil)
            #expect(ShelfViewModel(session: session, defaults: defaults).scope == .all)
        }
    }

    /// The local memory (§19(c), §21, §23, §24): order, details, the №
    /// panel and the collapsed headers survive a new model; the solo is
    /// session-scoped (P-13id-U1-6).
    @Test func theViewPreferencesAreRememberedLocally() async throws {
        try await withBookcaseSession { session, _, defaults in
            let first = ShelfViewModel(session: session, defaults: defaults)
            #expect(first.orderMode == .alphabetical, "A–Z is the default (§24)")
            #expect(first.detailsShown)
            #expect(!first.censusOpen, "the № is collapsed by default (§23)")
            first.orderMode = .mine
            first.detailsShown = false
            first.censusOpen = true
            first.toggleCollapsed("unshelved")
            first.toggleSolo(.owned)

            let second = ShelfViewModel(session: session, defaults: defaults)
            #expect(second.orderMode == .mine)
            #expect(!second.detailsShown)
            #expect(second.censusOpen)
            #expect(second.isCollapsed("unshelved"))
            #expect(second.solo == nil, "a solo is a look, not a preference")
            first.toggleSolo(.owned)
            #expect(first.solo == nil, "clicking the active solo clears it")
        }
    }
}
