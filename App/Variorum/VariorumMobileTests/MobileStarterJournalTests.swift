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
//  per-store-variant mark AND the launch-time virgin verdict — because
//  either one alone would let the book return in a case she ruled out.
//
//  ── UPDATED AT THE PRE-13u ROUND, ACT 0 (R-pre13u-1) ──────────────────
//  The occasion moved from LAUNCH to her FIRST WRITE and the 20-second
//  bounded wait was deleted, so the gate's pins changed shape with it: the
//  three "wait for the first clean round" pins are retired (the wait they
//  drove no longer exists), and in their place sit the pins for the rule
//  that replaced them — an account-owned store is never seeded at all, and
//  the launch verdict is taken by `prime` and spent here. The occasion
//  itself is pinned in `MobileFirstWriteFurnitureTests`.
//

import Foundation
import Testing
import VariorumCore
@testable import VariorumMobile

/// The one sync fact the seed reads, as a value a pin can move — the
/// stand-in for `SyncSession.isConfigured` and for the signed-in account
/// state that precedes a composed chain.
@MainActor
private final class FakeSync {
    var belongsToAnAccount = false
    var gate: MobileStarterJournal.SyncGate {
        .init(belongsToAnAccount: { [self] in belongsToAnAccount })
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
                storeWasEmptyAtLaunch: true,
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

    /// **THE BOOK IS THE SHARED DOOR'S, NOT A FOURTH MINT (the pre-13u
    /// ladder's F9 — #37(iii)'s "all doors share one rule").** The seeded
    /// book must wear exactly the daily mint's signature — the Journal-keeper
    /// repair's predicate — and the ensure's dated-notebook shape, because
    /// the same code minted it. A second writer of the shape could drift
    /// from the predicate silently; this pin is the drift guard on the
    /// phone's side (its core twin is `theDailyMintWearsTheKeeperSignature…`).
    @Test func theSeededBookIsTheSharedDoorsOwnMint() async throws {
        try await withEditorWorld { session, db in
            let mark = Mark()
            let outcome = await MobileStarterJournal.seedIfNeeded(
                session: session, storeVariant: .dev,
                storeWasEmptyAtLaunch: true,
                loadMark: mark.load, saveMark: mark.save)
            guard case .seeded(let readingID) = outcome else {
                Issue.record("expected a seed, got \(outcome)")
                return
            }
            let facts = try await db.read { db -> (Reading, [String]) in
                let book = try #require(try Queries.reading(db, id: readingID))
                return (book, try Queries.dailyJournalBookCandidates(db))
            }
            #expect(Queries.isDailyJournalMintShape(facts.0),
                    "the seeded book must BE the daily mint's shape — the repair's predicate")
            #expect(facts.1 == [readingID], "…and the one keeper candidate in the store")
            #expect(facts.0.sortField == .entryDate)
            #expect(facts.0.sortDir == .asc, "the ensure's dated-notebook order")
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
                storeWasEmptyAtLaunch: true,
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
            // past day so it sorts first — would make it a DAY: a journal
            // entry for a day she never wrote (and, until 2026-09-04, one the
            // retired bridge would have pushed to her other app).
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
                storeWasEmptyAtLaunch: true,
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
                storeWasEmptyAtLaunch: true,
                loadMark: mark.load, saveMark: mark.save)
            #expect(second == .alreadySeeded)

            let live = try await db.read { db in try Queries.readings(db) }
            #expect(live.isEmpty, "the shelf stays as she left it")
        }
    }

    /// The mark alone is not the whole guard. Even with a CLEARED mark —
    /// a reinstall, a second device — a store that already holds her
    /// writing is not a new user's, and gets no furniture. Driven through
    /// the SAME read `prime()` takes, so this pins the whole chain rather
    /// than a hand-set boolean.
    @Test func aStoreWithContentIsNeverSeeded() async throws {
        try await withEditorWorld { session, db in
            _ = try await session.runner.run { ops in
                try ops.createPost(title: "Something of mine")
            }
            let wasEmpty = try await MobileStarterJournal.storeIsNew(session)
            #expect(!wasEmpty, "the launch verdict must see her writing")

            let mark = Mark()   // never seeded on this device
            let outcome = await MobileStarterJournal.seedIfNeeded(
                session: session, storeVariant: .dev,
                storeWasEmptyAtLaunch: wasEmpty,
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
            let wasEmpty = try await MobileStarterJournal.storeIsNew(session)
            let mark = Mark()
            let outcome = await MobileStarterJournal.seedIfNeeded(
                session: session, storeVariant: .dev,
                storeWasEmptyAtLaunch: wasEmpty,
                loadMark: mark.load, saveMark: mark.save)
            #expect(outcome == .storeNotNew)
        }
    }

    /// Two writes in a row — the ordinary case — seed exactly one book.
    @Test func seedingIsIdempotentAcrossWrites() async throws {
        try await withEditorWorld { session, db in
            let mark = Mark()
            for _ in 0..<3 {
                _ = await MobileStarterJournal.seedIfNeeded(
                    session: session, storeVariant: .dev,
                    storeWasEmptyAtLaunch: true,
                    loadMark: mark.load, saveMark: mark.save)
            }
            let books = try await db.read { db in try Queries.readings(db) }
            #expect(books.count == 1)
        }
    }

    // MARK: The account gate (R-pre13u-1 — what replaced the sync wait)

    /// **AN ACCOUNT-OWNED STORE IS NEVER SEEDED.** The batch-5 gate asked
    /// *"has the account's content arrived yet?"* and waited up to twenty
    /// seconds for an answer it could not always get. Asked at the WRITE
    /// instead, the question is simply *"does this store belong to an
    /// account?"* — and if it does, her real Journal is the account's to
    /// deliver, so nothing is minted and nothing is waited on.
    ///
    /// **Her accepted corner, ruled in the same breath:** an account whose
    /// sync never lands (long offline, unreachable server, a §12 lockstep
    /// refusal) gets its Journal when sync first lands, and nothing before.
    @Test func anAccountOwnedStoreIsNeverSeeded() async throws {
        try await withEditorWorld { session, db in
            let mark = Mark()
            let sync = FakeSync()
            sync.belongsToAnAccount = true   // a composed chain, or a session

            let outcome = await MobileStarterJournal.seedIfNeeded(
                session: session, storeVariant: .dev, gate: sync.gate,
                storeWasEmptyAtLaunch: true,
                loadMark: mark.load, saveMark: mark.save)

            #expect(outcome == .accountOwned)
            #expect(!mark.seeded, "declining must not consume the one seed")
            let books = try await db.read { db in try Queries.readings(db) }
            #expect(books.isEmpty, "nothing was minted into her account's store")
        }
    }

    /// **THE FINDING THE OLD GATE COULD NOT CLOSE, CLOSED.** The residual
    /// was: fresh install, nobody signed in, seed lands — then she signs in
    /// from Settings and her own Journal arrives beside the starter one.
    /// The sign-in door lives inside the shell the seed launched with, so
    /// no launch-time ordering could avoid it.
    ///
    /// Under seed-on-first-write there IS an ordering, and this is it: sign
    /// in, then write. The account is a fact by then, so nothing is minted.
    @Test func signingInBeforeTypingLeavesNoStarterFurniture() async throws {
        try await withEditorWorld { session, db in
            let mark = Mark()
            let sync = FakeSync()

            // Launch: nobody signed in, store empty. The verdict is taken…
            let wasEmpty = try await MobileStarterJournal.storeIsNew(session)
            #expect(wasEmpty)

            // …she signs in from Settings…
            sync.belongsToAnAccount = true

            // …and only THEN writes.
            let outcome = await MobileStarterJournal.seedIfNeeded(
                session: session, storeVariant: .dev, gate: sync.gate,
                storeWasEmptyAtLaunch: wasEmpty,
                loadMark: mark.load, saveMark: mark.save)

            #expect(outcome == .accountOwned)
            let books = try await db.read { db in try Queries.readings(db) }
            #expect(books.isEmpty, "her Journal arrives by sync, alone")
        }
    }

    /// **The declining is FREE, and that is what makes it safe.** Nothing
    /// is marked, so signing out and starting fresh asks again.
    @Test func decliningForAnAccountDoesNotSpendTheSeed() async throws {
        try await withEditorWorld { session, db in
            let mark = Mark()
            let sync = FakeSync()
            sync.belongsToAnAccount = true
            _ = await MobileStarterJournal.seedIfNeeded(
                session: session, storeVariant: .dev, gate: sync.gate,
                storeWasEmptyAtLaunch: true,
                loadMark: mark.load, saveMark: mark.save)

            sync.belongsToAnAccount = false   // she signed out
            let outcome = await MobileStarterJournal.seedIfNeeded(
                session: session, storeVariant: .dev, gate: sync.gate,
                storeWasEmptyAtLaunch: true,
                loadMark: mark.load, saveMark: mark.save)
            guard case .seeded = outcome else {
                Issue.record("expected a seed, got \(outcome)")
                return
            }
            let books = try await db.read { db in try Queries.readings(db) }
            #expect(books.count == 1)
        }
    }

    // MARK: The live guard, read inside the mint's own turn

    /// **TODAY'S ENTRY CAN BEAT THE FURNITURE TO THE JOURNAL BOOK.**
    /// `shelveInDailyJournalBook` creates and pins the daily book itself
    /// (AppSpec §9), so her very first act can mint exactly the book this
    /// seeder would — after the launch verdict was taken, and while the
    /// occasion is in flight. The verdict cannot see that; the guard inside
    /// the mint's own runner turn can, and does.
    @Test func aJournalBookArrivingFirstStopsTheMint() async throws {
        try await withEditorWorld { session, db in
            // The launch verdict: genuinely empty.
            let wasEmpty = try await MobileStarterJournal.storeIsNew(session)
            #expect(wasEmpty)

            // Her first act is Today's Entry, which makes the book.
            _ = try await MobileTodayDoor.open(session: session, day: "2026-08-30")

            let mark = Mark()
            let outcome = await MobileStarterJournal.seedIfNeeded(
                session: session, storeVariant: .dev,
                storeWasEmptyAtLaunch: wasEmpty,
                loadMark: mark.load, saveMark: mark.save)

            #expect(outcome == .storeNotNew)
            #expect(!mark.seeded)
            let books = try await db.read { db in try Queries.readings(db) }
            #expect(books.count == 1, "exactly ONE Journal, whichever door won")
        }
    }

    /// The same guard, other door: a book she NAMED "Journal" herself is
    /// hers, and nothing mints a second one beside it (the name half —
    /// `assertBookNameIsFree`, the core's own five-door rule).
    @Test func aBookAlreadyWearingTheNameStopsTheMint() async throws {
        try await withEditorWorld { session, db in
            let wasEmpty = try await MobileStarterJournal.storeIsNew(session)
            _ = try await session.runner.run { ops in
                try ops.createReading(
                    name: MobileStarterJournal.bookName, kind: .curated)
            }
            let mark = Mark()
            let outcome = await MobileStarterJournal.seedIfNeeded(
                session: session, storeVariant: .dev,
                storeWasEmptyAtLaunch: wasEmpty,
                loadMark: mark.load, saveMark: mark.save)
            #expect(outcome == .storeNotNew)
            let books = try await db.read { db in try Queries.readings(db) }
            #expect(books.count == 1)
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

    /// The seed leaves NO structural-undo entry: a first write must not
    /// put furniture she never placed on top of her undo stack. (The quiet
    /// facade — `Operations(undoStack: nil)`, the tutorial seeder's shape.)
    @Test func theSeedIsQuiet() async throws {
        try await withEditorWorld { session, _ in
            let mark = Mark()
            _ = await MobileStarterJournal.seedIfNeeded(
                session: session, storeVariant: .dev,
                storeWasEmptyAtLaunch: true,
                loadMark: mark.load, saveMark: mark.save)
            #expect(session.undoStack.depth == 0,
                    "the starter journal is not an act she can undo")
        }
    }
}
