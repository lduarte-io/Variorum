//
//  LaunchSeedTombstoneTests.swift
//  VariorumTests
//
//  18o U2 — KnownIssues row 66, RULED R-18k-5 (QUESTIONS #138(f), the 18k
//  kickoff sitting, 2026-09-25): *honour the tombstone at launch* — as the
//  tutorial door's silent ensure already does (pre-13x F3, MINOR-N3).
//
//  THE DEFECT: `SampleLibrarySeeder.perform` short-circuited on THIS device's
//  per-book mark alone. On a device that never seeded the book — it ARRIVED
//  by sync, so no mark was ever written here — a deletion made anywhere was
//  undone at that device's next launch: discovery saw no live book and the
//  seed minted it again (re-membering the surviving notes), tombstone and all.
//
//  THE FIX'S SHAPE (the U2 record's design): the ensure's rule — a tombstoned
//  reading of the book's reserved name is the reader's decision — lives ONCE
//  (`SampleLibrarySeeder.readerDeletedTheBook`), and both silent roads read
//  it. The launch reads it at every point that DECIDES: the early read and,
//  after the account gate's wait, the latch's read — a tombstone can arrive
//  during the first round, which is exactly the row's "arrived by sync" road.
//  A decline records the decision in the launch's own mark (RUN A A2's "while
//  the evidence stands"), so it outlives the purge as the ensure's does.
//
//  *Red on the old code:* every pin marked RED-ON-OLD. The GUARDS are green on
//  both sides by design: a store with nothing still seeds; a whole live copy
//  still reads present; the explicit restore doors still mint; the purged-
//  tombstone residual (#138(e)) stays the recorded gap.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
private func withLaunchWorld<T>(
    _ body: @MainActor (AppSession, AppDatabase) async throws -> T
) async throws -> T {
    let db = try AppDatabase.inMemory()
    let start = Date(timeIntervalSince1970: 1_782_950_400)
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
        $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 66))
    } operation: { @MainActor in
        let session = AppSession(database: db)
        // BOTH session mark leaves injected (RUN A A2 row 8's rule, the
        // `EncryptionBookDoorTests` precedent): the restore door reads and
        // WRITES them, and the production leaves write the test host's
        // defaults — the Debug app's own domain. Every launch call below
        // passes its own `loadMark`/`saveMark` for the same reason.
        session.seededBookMarkIsSet = { _ in false }
        session.markSeededBook = { _ in }
        return try await body(session, db)
    }
}

/// A defaults-free launch mark.
@MainActor
private final class LaunchMark {
    var value = false
    var load: () -> Bool { { [self] in value } }
    var save: (Bool) -> Void { { [self] in value = $0 } }
}

/// The first sync round, as the account gate sees it.
@MainActor
private final class FirstRound {
    var started = false
    var landed = false
}

/// The row's own store: the book ARRIVED here (the seeder's own mint with NO
/// mark written — a non-seeding device, `aPurgedBookIsNotReMintedByTheTutorial
/// Door`'s precedent) and the reader then DELETED the book, on whichever
/// device — the tombstone is what arrives. Deleting a BOOK keeps its notes
/// (alive, tagged, bookless — the seeder's F10). Returns the dead reading.
@MainActor
private func arrivedThenDeleted(_ session: AppSession, _ book: SampleLibrarySeeder.Book) async throws -> String {
    let stories = try SampleLibrarySeeder.loadStories(for: book)
    let existing = try await session.database.read { db in
        try SampleLibrarySeeder.discover(db, book: book)
    }
    let seeded = try await SampleLibrarySeeder.seed(
        session: session, book: book, stories: stories, existing: existing)
    let readingID = seeded.readingID
    try await session.runner.run { ops in try ops.deleteReading(readingID) }
    return readingID
}

/// Delete Now's end state: the purge intent through the real door, then the
/// janitor's physical removal of the book's family (the precedent's staging).
@MainActor
private func purge(_ session: AppSession, readingID: String) async throws {
    _ = try session.operations.requestPurge(
        [SyncPurgeTarget(table: "reading", rowID: readingID)])
    try await session.database.write { db in
        try db.execute(sql: "DELETE FROM reading_post WHERE reading_id = ?", arguments: [readingID])
        try db.execute(sql: "DELETE FROM reading_section WHERE reading_id = ?", arguments: [readingID])
        try db.execute(sql: "DELETE FROM reading WHERE id = ?", arguments: [readingID])
    }
}

private func liveCopies(_ db: AppDatabase, _ book: SampleLibrarySeeder.Book) async throws -> Int {
    let name = book.name
    return try await db.read { db in
        try Queries.readings(db).filter { $0.name == name }.count
    }
}

private func livePosts(_ db: AppDatabase) async throws -> Int {
    try await db.read { db in
        try Int.fetchOne(
            db, sql: "SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL") ?? 0
    }
}

@MainActor
@Suite("18o U2 — row 66 (R-18k-5): the launch honours a seeded book's tombstone")
struct LaunchSeedTombstoneTests {

    // MARK: - The ruling, per seeded book

    /// **RED-ON-OLD — THE ROW.** For every book the launch loop seeds
    /// (`VariorumApp`'s `for book in Book.all`): a copy that arrived here and
    /// was deleted is NOT re-minted at launch. Nothing is minted, the notes
    /// stay where her deletion left them, and the decision is recorded.
    /// *Old code:* `.seeded` — a fresh book, the surviving notes re-membered.
    @Test(arguments: SampleLibrarySeeder.Book.all)
    func aBookDeletedWhereverIsNotReMintedAtLaunch(_ book: SampleLibrarySeeder.Book) async throws {
        try await withLaunchWorld { session, db in
            _ = try await arrivedThenDeleted(session, book)
            let postsBefore = try await livePosts(db)
            let mark = LaunchMark()

            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: book, loadMark: mark.load, saveMark: mark.save)

            #expect(outcome == .deletedByTheReader, "the tombstone is her word: \(outcome)")
            #expect(try await liveCopies(db, book) == 0, "the book stays deleted")
            #expect(try await livePosts(db) == postsBefore, "nothing minted")
            let existing = try await db.read { db in try SampleLibrarySeeder.discover(db, book: book) }
            #expect(existing.bookID == nil, "no book re-made to re-member the surviving notes into")
            #expect(mark.value, "the decision is RECORDED, so it outlives the tombstone's purge")
        }
    }

    /// **RED-ON-OLD — THE "ARRIVED BY SYNC" TIMING.** An account-owned store
    /// waits for its first clean round before judging, and the tombstone can
    /// land IN that round: the store is empty when the launch first looks,
    /// and the book and its tombstone arrive while it waits. The rule is read
    /// again at the latch's deciding read, after the wait — so a rule read
    /// only up front would red this.
    @Test func aTombstoneThatLandsDuringTheFirstRoundIsHonoured() async throws {
        try await withLaunchWorld { session, db in
            let book = SampleLibrarySeeder.Book.encryptionExplained
            let mark = LaunchMark()
            let round = FirstRound()

            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: book,
                gate: SampleLibrarySeeder.SyncGate(
                    belongsToAnAccount: { true },
                    hasSyncedCleanly: {
                        // The first ask starts "the round": the book arrives
                        // and the reader's deletion arrives with it.
                        if !round.started {
                            round.started = true
                            Task { @MainActor in
                                _ = try? await arrivedThenDeleted(session, book)
                                round.landed = true
                            }
                        }
                        return round.landed
                    }),
                firstRoundWait: .seconds(60), pollInterval: .milliseconds(5),
                loadMark: mark.load, saveMark: mark.save)

            let live = try await liveCopies(db, book)
            #expect(round.landed, "the round landed before the launch decided")
            #expect(outcome == .deletedByTheReader, "\(outcome)")
            #expect(live == 0)
            #expect(mark.value)
        }
    }

    /// **RED-ON-OLD — THE EARLY READ DECIDES TOO.** An account-owned store
    /// whose tombstone is ALREADY here (it synced before) declines at the
    /// launch's first read — it neither spends the gate's wait nor leaves the
    /// decision unrecorded because this launch's round never landed (offline).
    /// Nothing the round could bring would make a mint right: a copy restored
    /// elsewhere arrives by sync, not by seed. *Old code:*
    /// `.awaitingFirstSync`, nothing recorded — and, after a purge in that
    /// session, the next launch minted.
    @Test func aTombstoneAlreadyHereDeclinesWithoutWaitingForTheRound() async throws {
        try await withLaunchWorld { session, db in
            let book = SampleLibrarySeeder.Book.encryptionExplained
            _ = try await arrivedThenDeleted(session, book)
            let mark = LaunchMark()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: book,
                gate: SampleLibrarySeeder.SyncGate(
                    belongsToAnAccount: { true }, hasSyncedCleanly: { false }),
                firstRoundWait: .milliseconds(30), pollInterval: .milliseconds(5),
                loadMark: mark.load, saveMark: mark.save)
            #expect(outcome == .deletedByTheReader, "\(outcome)")
            #expect(mark.value, "recorded now, not at some later launch")
            #expect(try await liveCopies(db, book) == 0)
        }
    }

    /// **RED-ON-OLD — THE DECISION OUTLIVES THE PURGE** (the ensure's A2
    /// property, now the launch's too). The launch that saw the tombstone
    /// recorded it; Delete Now then removes the row itself, and the next
    /// launch declines on the mark. *Old code:* the first launch re-minted.
    @Test func theLaunchsDecisionOutlivesThePurge() async throws {
        try await withLaunchWorld { session, db in
            let book = SampleLibrarySeeder.Book.encryptionExplained
            let readingID = try await arrivedThenDeleted(session, book)
            let mark = LaunchMark()
            let first = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: book, loadMark: mark.load, saveMark: mark.save)
            #expect(first == .deletedByTheReader, "\(first)")

            try await purge(session, readingID: readingID)
            #expect(try await db.read { db in
                try SampleLibrarySeeder.readerDeletedTheBook(db, book: book)
            } == false, "the tombstone is gone — only the mark remembers")

            let again = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: book, loadMark: mark.load, saveMark: mark.save)
            #expect(again == .alreadySeeded)
            #expect(try await liveCopies(db, book) == 0)
        }
    }

    // MARK: - The guards (green on both sides)

    /// GUARD — a store holding no copy and no tombstone still seeds, every
    /// book: the rule declines only on her recorded word.
    @Test(arguments: SampleLibrarySeeder.Book.all)
    func aStoreWithNoCopyAndNoTombstoneStillSeeds(_ book: SampleLibrarySeeder.Book) async throws {
        try await withLaunchWorld { session, db in
            let mark = LaunchMark()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: book, loadMark: mark.load, saveMark: mark.save)
            guard case .seeded = outcome else {
                Issue.record("a fresh store seeds \(book.name): \(outcome)")
                return
            }
            let live = try await liveCopies(db, book)
            #expect(live == 1)
            #expect(mark.value)
        }
    }

    /// GUARD — the EXPLICIT doors are an ask, byte-unchanged: Help ▸ Restore
    /// (the Mac) and the phone's Settings row ride `SeededBookRestore.restore`,
    /// which mints a fresh copy over a tombstone for every book. And a WHOLE
    /// live copy standing beside an old tombstone reads as present at launch
    /// (the complete-copy answer comes first; nothing is declined or minted).
    @Test(arguments: SampleLibrarySeeder.Book.all)
    func theExplicitRestoreStillMintsAndAWholeCopyReadsPresent(_ book: SampleLibrarySeeder.Book) async throws {
        try await withLaunchWorld { session, db in
            let deadID = try await arrivedThenDeleted(session, book)
            let restored = try await SeededBookRestore.restore(session: session, book: book)
            guard case .restored(let newID, _) = restored else {
                Issue.record("Help ▸ Restore still mints \(book.name): \(restored)")
                return
            }
            #expect(newID != deadID)
            #expect(try await liveCopies(db, book) == 1)

            let mark = LaunchMark()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: book, loadMark: mark.load, saveMark: mark.save)
            #expect(outcome == .alreadyPresent, "\(outcome)")
            #expect(try await liveCopies(db, book) == 1)
            #expect(mark.value)
        }
    }

    /// GUARD — **THE RECORDED GAP, NOT WIDENED** (#138(e)): a device that
    /// ran NEITHER silent road between the deletion and the purge holds no
    /// evidence — the purge removes the tombstone and 13j's ledger is
    /// content-free by design (ids, never names) — so its launch mints the
    /// book. The travelling marker that would close it was #138(f)'s option
    /// (iii), NOT taken. Pinned so that closing it is a conscious act.
    @Test func aPurgedTombstoneLeavesNoEvidence_theRecordedGap() async throws {
        try await withLaunchWorld { session, db in
            let book = SampleLibrarySeeder.Book.encryptionExplained
            let readingID = try await arrivedThenDeleted(session, book)
            try await purge(session, readingID: readingID)

            let mark = LaunchMark()
            let outcome = await SampleLibrarySeeder.seedIfNeeded(
                session: session, book: book, loadMark: mark.load, saveMark: mark.save)
            guard case .seeded = outcome else {
                Issue.record("the documented residual: a purged tombstone leaves nothing to read — \(outcome)")
                return
            }
            #expect(try await liveCopies(db, book) == 1)
        }
    }
}
