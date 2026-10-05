//
//  WingBookMoveDoorTests.swift
//  VariorumTests
//
//  13i-d U5b — THE BOOK-MOVE HALF's Mac doors (R-13id-6; her R-13id-4
//  backdoor). The shared wings brain over a real session: the Bookcase row's
//  Move to Wing ▸ (its drawing rule; the confirm COUNTING the notes and the
//  archived ones, LISTING every stay-behind membership, counting the waiting
//  notes, naming a twin; a frozen stay-behind book refusing AT THE DOOR; the
//  daily Journal refusing even from a stale face; the receipt), the
//  switcher's Move Everything to Another Wing ▸ (absent on Home; the confirm's
//  counts and tag sentence; an empty wing speaking instead of asking; the act
//  emptying the wing so Delete then asks), the delete refusal's new road
//  words in the shared table, and the declarations.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withBookMoveSession<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 7))
    } operation: { @MainActor in
        try await body(AppSession(database: db), db)
    }
}

@MainActor
@Suite("13i-d U5b — the book move and the bulk move (Mac doors)", .serialized)
struct WingBookMoveDoorTests {
    private func spoken(_ session: AppSession) -> String? { session.status.spoken?.text }

    private func reading(_ db: AppDatabase, _ id: String) async throws -> Reading {
        try #require(try await db.read { try Queries.reading($0, id: id) })
    }

    /// P-2: the book door is drawn only where it can act — another wing
    /// exists, and never on the daily Journal (its marker); books AND
    /// gatherings carry it.
    @Test func theBookDoorIsDrawnOnlyWhereItCanAct() {
        let now = Date()
        let book = Reading(id: "b", name: "Alpha", kind: .book, createdAt: now, updatedAt: now)
        let gathering = Reading(id: "g", name: "G", kind: .gathering, createdAt: now, updatedAt: now)
        let journal = Reading(
            id: "j", name: "Journal", kind: .book, profile: Queries.dailyJournalBookProfile,
            createdAt: now, updatedAt: now)
        #expect(WingBookMoveDoor.drawn(reading: book, destinations: 1))
        #expect(WingBookMoveDoor.drawn(reading: gathering, destinations: 2))
        #expect(!WingBookMoveDoor.drawn(reading: book, destinations: 0), "one library — no door")
        #expect(!WingBookMoveDoor.drawn(reading: journal, destinations: 3), "the daily Journal never moves")
    }

    /// The confirm COUNTS (3 notes, 1 archived), LISTS the stay-behind
    /// membership the move severs, names the destination's twin — then the
    /// act moves the book with its notes and speaks the receipt.
    @Test func theBookMoveAsksCountingAndListingThenActs() async throws {
        try await withBookMoveSession { session, db in
            let ops = session.operations
            let wings = WingsModel(session: session)
            let wing = try ops.createWing(name: "Imports")
            await wings.load()
            _ = try ops.createReading(name: "ALPHA", kind: .book, wingId: wing.id)
            let alpha = try ops.createReading(name: "Alpha", kind: .book)
            let beta = try ops.createReading(name: "Beta", kind: .book)
            let notes = try ["one", "two", "three"].map { try ops.createPost(title: $0) }
            for note in notes { _ = try ops.addPostToReading(note.id, to: alpha.id) }
            _ = try ops.addPostToReading(notes[2].id, to: beta.id)
            try ops.archiveContainer(notes[1].id)

            let ask = try #require(await wings.bookMoveAsk(reading: alpha, to: wing.id))
            #expect(ask.wingName == "Imports")
            let message = WingCopy.bookMoveMessage(ask)
            #expect(message.contains("Its 3 notes come with it (1 archived — it stays archived), tags and all."))
            #expect(message.contains("“three” also leaves “Beta” — a book only holds notes of its own wing."))
            #expect(message.contains("“Imports” already has one called “ALPHA” — both keep their names."))
            #expect(message.contains("It arrives unshelved."))
            #expect(!message.contains("waiting at Arrivals"), "no waiter, no line")

            await wings.moveBook(ask)
            #expect(spoken(session) == WingCopy.bookMoved("Alpha", to: "Imports", notes: 3, isGathering: false))
            #expect(try await reading(db, alpha.id).wingId == wing.id)
            #expect(try await db.read { try Queries.effectiveWing($0, ofPost: notes[2].id) } == wing.id)
        }
    }

    /// WALK W-1 (2026-10-02, Terminal·light `tl-11-W1-before…`): untitled
    /// notes are named by their DAY, so three different members can all read
    /// "2026-10-01"; the confirm grouped the severed list by that NAME and
    /// said "“2026-10-01” also leaves “Other”, “Other” and “Other”". It
    /// groups by the note's IDENTITY now, and identical clauses merge with a
    /// count — RED on the title-grouping face.
    @Test func sameNamedNotesAreCountedNotCollapsed() async throws {
        try await withBookMoveSession { session, _ in
            let ops = session.operations
            let wings = WingsModel(session: session)
            let wing = try ops.createWing(name: "Imports")
            await wings.load()
            let mover = try ops.createReading(name: "Mover", kind: .book)
            let other = try ops.createReading(name: "Other", kind: .book)
            let lone = try ops.createReading(name: "Lone", kind: .book)
            for _ in 0..<3 {
                let twin = try ops.createPost(title: "same")
                _ = try ops.addPostToReading(twin.id, to: mover.id)
                _ = try ops.addPostToReading(twin.id, to: other.id)
            }
            let solo = try ops.createPost(title: "solo")
            _ = try ops.addPostToReading(solo.id, to: mover.id)
            _ = try ops.addPostToReading(solo.id, to: other.id)
            _ = try ops.addPostToReading(solo.id, to: lone.id)
            let ask = try #require(await wings.bookMoveAsk(reading: mover, to: wing.id))
            let message = WingCopy.bookMoveMessage(ask)
            #expect(message.contains("3 notes called “same” also leave “Other”; "
                                     + "“solo” also leaves “Other” and “Lone” — a book only holds "
                                     + "notes of its own wing."))
            #expect(!message.contains("“Other”, “Other”"), "a book is never listed twice for one clause")
        }
    }

    /// Item 5(a)'s line: a living book's waiting notes are counted — the
    /// finish's sentence, the dismissal's own set.
    @Test func theConfirmCountsTheWaitingNotesItDismisses() async throws {
        try await withBookMoveSession { session, _ in
            let ops = session.operations
            let wings = WingsModel(session: session)
            let wing = try ops.createWing(name: "Imports")
            await wings.load()
            let tag = try ops.createTag(name: "classics")
            let tagRule = try #require(try RuleGrammar.encode(.tag(tag.id)))
            let living = try ops.createReading(
                name: "Living", kind: .book,
                querySpec: tagRule,
                intakeSeating: .arrivals)
            for title in ["a", "b"] {
                let note = try ops.createPost(title: title)
                try ops.applyTag(tag.id, toPost: note.id)
            }
            let ask = try #require(await wings.bookMoveAsk(reading: living, to: wing.id))
            #expect(WingCopy.bookMoveMessage(ask).contains("2 waiting at Arrivals will be dismissed."))
        }
    }

    /// Item 3(a)'s clause at the DOOR (P-2): a member also living in a
    /// FINISHED book that stays behind — the door refuses naming it, nothing
    /// moves. The daily Journal refuses too, even from a stale face.
    @Test func aFrozenStayBehindBookAndTheDailyJournalRefuseAtTheDoor() async throws {
        try await withBookMoveSession { session, db in
            let ops = session.operations
            let wings = WingsModel(session: session)
            let wing = try ops.createWing(name: "Imports")
            await wings.load()
            let alpha = try ops.createReading(name: "Alpha", kind: .book)
            let beta = try ops.createReading(name: "Beta", kind: .book)
            let three = try ops.createPost(title: "three")
            _ = try ops.addPostToReading(three.id, to: alpha.id)
            _ = try ops.addPostToReading(three.id, to: beta.id)
            try ops.lockReading(beta.id)
            #expect(await wings.bookMoveAsk(reading: alpha, to: wing.id) == nil)
            #expect(spoken(session)
                    == WingCopy.bookFrozen(
                        "Alpha", because: .init(noteID: three.id, note: "three", book: "Beta")))
            #expect(try await reading(db, alpha.id).wingId == "")

            let entry = try ops.createOrOpenJournalEntry(entryDate: "2026-10-02").container
            _ = ops.shelveInDailyJournalBook(entry.id)
            let journal = try await reading(db, try #require(try ops.dailyJournalBookID()))
            #expect(await wings.bookMoveAsk(reading: journal, to: wing.id) == nil)
            #expect(spoken(session) == OpsRefusalCopy.message(
                for: OperationError.dailyJournalIsHomeOnly(id: journal.id)))
        }
    }

    /// The bulk door: ABSENT on Home (data — `currentWingActs`); on an
    /// additional wing the confirm counts what moves and says what becomes of
    /// its tags (the let-go ones named); the act empties the wing, so Delete
    /// then ASKS; an empty wing's door speaks instead of asking.
    @Test func theBulkDoorAsksCountsAndEmptiesTheWing() async throws {
        try await withBookMoveSession { session, db in
            let ops = session.operations
            #expect(WingSwitcherMenu.currentWingActs("").isEmpty,
                    "Home: never renamed, deleted or bulk-moved")
            #expect(WingSwitcherMenu.currentWingActs("w")
                    == [.renameWing, .moveWingContents, .deleteWing])

            let wings = WingsModel(session: session)
            let wing = try ops.createWing(name: "Imports")
            await wings.load()
            wings.switchTo(wing.id)
            #expect(await wings.contentsMoveAsk(to: "") == nil, "empty — nothing to move")
            #expect(spoken(session) == WingCopy.nothingToMove("Imports"))

            let worn = try ops.createTag(name: "worn", wingID: wing.id)
            _ = try ops.createTag(name: "orphan", wingID: wing.id)
            _ = try ops.createTag(name: "worn")  // Home already has it — it joins
            let book = try ops.createReading(name: "Kept", kind: .book, wingId: wing.id)
            let note = try ops.createPost(title: "n", wingId: wing.id)
            _ = try ops.createPost(title: "loose", wingId: wing.id)
            _ = try ops.addPostToReading(note.id, to: book.id)
            try ops.applyTag(worn.id, toPost: note.id)

            let ask = try #require(await wings.contentsMoveAsk(to: ""))
            #expect(ask.sourceName == "Imports" && ask.wingName == "Home")
            #expect(WingCopy.everythingTitle(from: ask.sourceName, to: ask.wingName)
                    == "Move everything in “Imports” to “Home”?")
            let message = WingCopy.everythingMessage(ask)
            #expect(message.hasPrefix("1 book, 2 notes and 2 tags move."))
            #expect(message.contains("Tags travel by name: 1 joins a tag “Home” already has and "
                                     + "1 nothing uses is let go — “#orphan”."))
            #expect(message.hasSuffix("“Imports” keeps none of its tags, so it ends empty "
                                      + "— then Delete Wing… can take it."))

            await wings.moveContents(ask)
            #expect(spoken(session) == WingCopy.everythingMoved(from: "Imports", to: "Home"))
            #expect(try await db.read { try Queries.wingContents($0, wingID: wing.id) }.isEmpty)
            #expect(await wings.deleteAsk(wing.id), "the emptied wing now asks to be deleted")
        }
    }

    /// WALK W-2 (2026-10-02, Terminal·dark `td-07-W2-before…`): a wing holding
    /// only a GATHERING read "1 gathering move. Books keep their notes …
    /// “Annex” keeps none of its tags…" — wrong agreement, a books sentence
    /// with no books, a tags clause with no tags; and the gathering's own
    /// confirm promised "its rule's tags travel" for a star-only rule. The
    /// sentences now say only what is true of what moves — RED on the old words.
    @Test func theConfirmsSayOnlyWhatIsTrueOfWhatMoves() async throws {
        try await withBookMoveSession { session, _ in
            let ops = session.operations
            let wings = WingsModel(session: session)
            let wing = try ops.createWing(name: "Imports")
            await wings.load()
            let starRule = try #require(try RuleGrammar.encode(.star))
            let starred = try ops.createReading(
                name: "Starred", kind: .gathering,
                querySpec: starRule)
            let single = try #require(await wings.bookMoveAsk(reading: starred, to: wing.id))
            #expect(WingCopy.bookMoveMessage(single)
                    == "A gathering holds no notes — in “Imports” it shows the notes there that "
                        + "match its rule. Any tags its rule names travel by name. It arrives unshelved.")
            await wings.moveBook(single)
            wings.switchTo(wing.id)
            let ask = try #require(await wings.contentsMoveAsk(to: ""))
            #expect(WingCopy.everythingMessage(ask)
                    == "1 gathering moves. The gathering arrives unshelved. "
                        + "“Imports” ends empty — then Delete Wing… can take it.")
        }
    }

    /// The delete refusal's words gain the road everywhere they are said —
    /// the shared table's arm too (RED on the old words by construction).
    @Test func theDeleteRefusalNamesTheBulkRoad() {
        let contents = Queries.WingContents(notes: 2, books: 1, gatherings: 0, tags: 0)
        #expect(OpsRefusalCopy.message(for: OperationError.wingNotEmpty(id: "w", contents: contents))
                == "That wing still holds 1 book and 2 notes — move or delete them first, "
                    + "then the empty wing can go — or move everything to another wing.")
        #expect(OpsRefusalCopy.message(for: OperationError.readingAlreadyInWing(readingID: "b", wingID: "w"))
                == "That book is already in that wing — nothing changed.")
    }

    /// P-1: both acts declared, rendered by their surfaces (the registry
    /// walk's existing lines carry them — no new renderer).
    @Test func theBookMoveActsAreDeclaredAndRendered() {
        #expect(ShelfView.contextMenuCapabilities.contains(.moveBookToWing))
        #expect(WingSwitcherMenu.surfaceCapabilities.contains(.moveWingContents))
        #expect(CapabilityRegistry.capability(.moveBookToWing).doors == [.contextMenu])
        #expect(CapabilityRegistry.capability(.moveWingContents).doors == [.surface])
        #expect(CapabilityRegistry.capability(.moveBookToWing).verb == "Move to Wing")
        #expect(CapabilityRegistry.capability(.moveWingContents).verb == "Move Everything to Another Wing")
    }
}
