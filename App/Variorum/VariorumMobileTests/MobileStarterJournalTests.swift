//
//  MobileStarterJournalTests.swift
//  VariorumMobileTests
//
//  Mobile Round 2, batch 5 — R27b: THE STARTER JOURNAL, seeded once.
//
//  Her ruling: *"I would also make a journal book with one entry in it for
//  new users introducing users to their journal - and then if they delete
//  that journal book or archive it, it just doesn't appear at all."*
//
//  **The second clause is the whole difficulty, and it is what most of
//  these pins are about.** A discover-by-name seeder would put the book
//  back after she deleted it. Both guards are pinned independently — the
//  per-store-variant mark AND the virgin-store guard — because either one
//  alone would let the book return in a case she ruled out.
//

import Foundation
import Testing
import VariorumCore
@testable import VariorumMobile

/// The two sync facts the seed reads, as values a pin can move — the
/// stand-in for `SyncSession.isConfigured` / `status.lastSuccessAt` (and
/// for the signed-in account state that precedes a composed chain).
@MainActor
private final class FakeSync {
    var belongsToAnAccount = false
    var hasSyncedCleanly = false
    var gate: MobileStarterJournal.SyncGate {
        .init(
            belongsToAnAccount: { [self] in belongsToAnAccount },
            hasSyncedCleanly: { [self] in hasSyncedCleanly })
    }
}

/// A mark that lives in the test, never in this machine's defaults.
@MainActor
private final class Mark {
    var seeded = false
    var load: () -> Bool { { [self] in seeded } }
    var save: (Bool) -> Void { { [self] in seeded = $0 } }
}

@Suite("Starter Journal — seeded once, and never again (R27b)")
struct MobileStarterJournalTests {

    /// A new user's store gets the book, the entry, the designation and
    /// the pin — the same shape the core's own first-press creation makes.
    @Test func aNewStoreGetsAJournalWithOneEntry() async throws {
        try await withEditorWorld { session, db in
            let mark = Mark()
            let outcome = await MobileStarterJournal.seedIfNeeded(
                session: session, storeVariant: .dev,
                loadMark: mark.load, saveMark: mark.save)

            guard case .seeded(let readingID) = outcome else {
                Issue.record("expected a seed, got \(outcome)")
                return
            }
            #expect(mark.seeded, "the mark must be set only after it lands")

            let facts = try await db.read { db -> (String, String?, String?, Int, Bool) in
                let book = try #require(try Queries.reading(db, id: readingID))
                let daily = try Queries.dailyJournalBookID(db)
                let members = try Queries.assembleReading(db, readingID: readingID)
                return (book.name, book.profile, daily,
                        members.count, book.kind == .curated)
            }
            #expect(facts.0 == Operations.defaultDailyJournalBookName)
            #expect(facts.1 == "journal")
            #expect(facts.2 == readingID, "the seeded book is the daily journal")
            #expect(facts.3 == 1, "exactly ONE entry — her word")
            #expect(facts.4, "curated, like the core's own")

            let pins = try await db.read { db in try Queries.shelfPins(db) }
            #expect(pins.contains(readingID), "and pinned, like the core's own")
        }
    }

    /// **The entry carries NO `entry_date`, and that is load-bearing.** A
    /// starter note stamped with today would be the note
    /// `createOrOpenJournalEntry` hands her the first time she presses
    /// Today's Entry — so her first real entry would open onto
    /// introduction copy. Driven end to end: seed, then press Today.
    @Test func theStarterEntryIsNotTodaysEntry() async throws {
        try await withEditorWorld { session, db in
            let mark = Mark()
            let outcome = await MobileStarterJournal.seedIfNeeded(
                session: session, storeVariant: .dev,
                loadMark: mark.load, saveMark: mark.save)
            guard case .seeded(let readingID) = outcome else {
                Issue.record("expected a seed, got \(outcome)")
                return
            }

            let shelf = MobileShelfViewModel(session: session)
            let todayID = try #require(await shelf.openToday(day: "2026-08-30"))

            let members = try await db.read { db in
                try Queries.assembleReading(db, readingID: readingID)
            }
            let starter = try #require(
                members.first { $0.title == MobileStarterJournal.entryTitle })
            #expect(todayID != starter.postID,
                    "today's entry must be a NEW note, not the introduction")
            #expect(starter.entryDate == nil, "the starter note claims no day")
            #expect(members.count == 2, "the day joined the book beside it")

            // **The consequence of carrying no day, pinned as BEHAVIOUR
            // rather than discovered later.** A journal book sorts by
            // `entry_date` and `stampOrder` puts NULLs LAST, so the
            // introduction settles at the END of the book once real days
            // arrive. Deliberate: the alternative — giving it a fabricated
            // past day so it sorts first — would make it a DAY, which the
            // Fragments bridge pushes by `entry_date`, inventing a journal
            // entry in her other app for a day she never wrote.
            #expect(members.last?.postID == starter.postID,
                    "the introduction sorts after the dated days")
        }
    }

    /// **Her second clause.** Delete the book, ask again — and it stays
    /// gone. (This is the pin a discover-by-name seeder fails.)
    @Test func aDeletedStarterJournalNeverComesBack() async throws {
        try await withEditorWorld { session, db in
            let mark = Mark()
            let first = await MobileStarterJournal.seedIfNeeded(
                session: session, storeVariant: .dev,
                loadMark: mark.load, saveMark: mark.save)
            guard case .seeded(let readingID) = first else {
                Issue.record("expected a seed, got \(first)")
                return
            }

            try await session.runner.run { ops in
                try ops.deleteReading(readingID)
            }

            let second = await MobileStarterJournal.seedIfNeeded(
                session: session, storeVariant: .dev,
                loadMark: mark.load, saveMark: mark.save)
            #expect(second == .alreadySeeded)

            let live = try await db.read { db in try Queries.readings(db) }
            #expect(live.isEmpty, "the shelf stays as she left it")
        }
    }

    /// The mark alone is not the whole guard. Even with a CLEARED mark —
    /// a reinstall, a second device — a store that already holds her
    /// writing is not a new user's, and gets no furniture.
    @Test func aStoreWithContentIsNeverSeeded() async throws {
        try await withEditorWorld { session, db in
            _ = try await session.runner.run { ops in
                try ops.createPost(title: "Something of mine")
            }
            let mark = Mark()   // never seeded on this device
            let outcome = await MobileStarterJournal.seedIfNeeded(
                session: session, storeVariant: .dev,
                loadMark: mark.load, saveMark: mark.save)
            #expect(outcome == .storeNotNew)
            #expect(mark.seeded == false, "a refusal must not claim a seed")

            let books = try await db.read { db in try Queries.readings(db) }
            #expect(books.isEmpty)
        }
    }

    /// The same guard the other way: a store carrying only BOOKS (an
    /// account synced down before its notes arrive) is not new either.
    @Test func aStoreWithOnlyBooksIsNeverSeeded() async throws {
        try await withEditorWorld { session, _ in
            _ = try await session.runner.run { ops in
                try ops.createReading(name: "Essays", kind: .curated)
            }
            let mark = Mark()
            let outcome = await MobileStarterJournal.seedIfNeeded(
                session: session, storeVariant: .dev,
                loadMark: mark.load, saveMark: mark.save)
            #expect(outcome == .storeNotNew)
        }
    }

    /// Two launches in a row — the ordinary case — seed exactly one book.
    @Test func seedingIsIdempotentAcrossLaunches() async throws {
        try await withEditorWorld { session, db in
            let mark = Mark()
            for _ in 0..<3 {
                _ = await MobileStarterJournal.seedIfNeeded(
                    session: session, storeVariant: .dev,
                    loadMark: mark.load, saveMark: mark.save)
            }
            let books = try await db.read { db in try Queries.readings(db) }
            #expect(books.count == 1)
        }
    }

    // MARK: The sync gate (the batch-5 cold review's MAJOR)

    /// **A SIGNED-IN DEVICE DOES NOT DECIDE ITS STORE IS NEW BEFORE SYNC
    /// HAS ANSWERED.** The virgin-store guard is a LOCAL read of a store
    /// whose contents are about to arrive over the network; asking it at
    /// launch answers a question nobody has the facts for yet. Declining is
    /// free — nothing is marked, so the next launch asks again.
    @Test func aSignedInDeviceDeclinesUntilItsFirstCleanRound() async throws {
        try await withEditorWorld { session, db in
            let mark = Mark()
            let sync = FakeSync()
            sync.belongsToAnAccount = true   // a composed chain, or a session

            let outcome = await MobileStarterJournal.seedIfNeeded(
                session: session, storeVariant: .dev, gate: sync.gate,
                firstRoundWait: .milliseconds(150),
                pollInterval: .milliseconds(10),
                loadMark: mark.load, saveMark: mark.save)

            #expect(outcome == .awaitingFirstSync)
            #expect(!mark.seeded, "declining must not consume the one seed")
            let books = try await db.read { db in try Queries.readings(db) }
            #expect(books.isEmpty, "nothing was minted into her account's store")
        }
    }

    /// **THE FINDING'S OWN SCRIPT, END TO END.** A phone joins an account
    /// that already has a `Journal`. The first pull lands it DURING the
    /// wait; the seed re-asks the virgin-store question and finds the
    /// answer it could not have had at launch.
    ///
    /// On the pre-fix door this minted a second `Journal`, designated it,
    /// pinned it to the shelf and minted a note — and `reading` is a synced
    /// table with a trigger-fed outbox (SyncSpec §3), so all of it
    /// propagated to every device on the account. Nothing in the merge
    /// matrix converges a duplicate book away, and by design nothing should.
    @Test func herCorpusArrivingDuringTheWaitCancelsTheSeed() async throws {
        try await withEditorWorld { session, db in
            let mark = Mark()
            let sync = FakeSync()
            sync.belongsToAnAccount = true

            let seeding = Task {
                await MobileStarterJournal.seedIfNeeded(
                    session: session, storeVariant: .dev, gate: sync.gate,
                    firstRoundWait: .seconds(5),
                    pollInterval: .milliseconds(5),
                    loadMark: mark.load, saveMark: mark.save)
            }

            // The first pull: HER Journal arrives.
            try await session.runner.run { ops in
                _ = try ops.createReading(
                    name: MobileStarterJournal.bookName, kind: .curated,
                    profile: "journal", sortField: .entryDate, sortDir: .asc)
            }
            sync.hasSyncedCleanly = true

            #expect(await seeding.value == .storeNotNew)
            #expect(!mark.seeded)
            let books = try await db.read { db in try Queries.readings(db) }
            #expect(books.count == 1, "HER Journal, alone — no duplicate beside it")
        }
    }

    /// And the account that really IS empty still gets its book: the gate
    /// defers the question, it does not answer it in the negative.
    @Test func anEmptyAccountStillGetsTheBookOnceSyncHasSpoken() async throws {
        try await withEditorWorld { session, db in
            let mark = Mark()
            let sync = FakeSync()
            sync.belongsToAnAccount = true
            sync.hasSyncedCleanly = true

            let outcome = await MobileStarterJournal.seedIfNeeded(
                session: session, storeVariant: .dev, gate: sync.gate,
                firstRoundWait: .milliseconds(150),
                pollInterval: .milliseconds(10),
                loadMark: mark.load, saveMark: mark.save)

            guard case .seeded = outcome else {
                Issue.record("expected a seed, got \(outcome)")
                return
            }
            #expect(mark.seeded)
            let books = try await db.read { db in try Queries.readings(db) }
            #expect(books.count == 1)
        }
    }

    /// A device with no account anywhere seeds at once, exactly as before —
    /// the store genuinely IS this device's, and the gate must not make a
    /// first launch wait on a network nobody is using.
    @Test func aDeviceWithNoAccountSeedsWithoutWaiting() async throws {
        try await withEditorWorld { session, _ in
            let mark = Mark()
            let sync = FakeSync()   // belongsToAnAccount stays false

            let outcome = await MobileStarterJournal.seedIfNeeded(
                session: session, storeVariant: .dev, gate: sync.gate,
                firstRoundWait: .seconds(30),   // never spent
                pollInterval: .milliseconds(10),
                loadMark: mark.load, saveMark: mark.save)

            guard case .seeded = outcome else {
                Issue.record("expected a seed, got \(outcome)")
                return
            }
        }
    }

    /// The mark is scoped per store variant — debug and release share one
    /// defaults domain, so an unscoped key would let a dev-store seed
    /// suppress her real store's (the `IdleCommitScheduler` precedent).
    @Test func theMarkIsScopedByStoreVariant() {
        #expect(MobileStarterJournal.seededDefaultsKey(for: .real)
                != MobileStarterJournal.seededDefaultsKey(for: .dev))
        #expect(MobileStarterJournal.seededDefaultsKey(for: .real)
                .hasSuffix(AppDatabase.StoreVariant.real.rawValue))
    }

    /// The seed leaves NO structural-undo entry: a first launch must not
    /// put furniture she never placed on top of her undo stack. (The quiet
    /// facade — `Operations(undoStack: nil)`, the tutorial seeder's shape.)
    @Test func theSeedIsQuiet() async throws {
        try await withEditorWorld { session, _ in
            let mark = Mark()
            _ = await MobileStarterJournal.seedIfNeeded(
                session: session, storeVariant: .dev,
                loadMark: mark.load, saveMark: mark.save)
            #expect(session.undoStack.depth == 0,
                    "the starter journal is not an act she can undo")
        }
    }
}
