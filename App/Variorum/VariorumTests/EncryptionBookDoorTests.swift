//
//  EncryptionBookDoorTests.swift
//  VariorumTests
//
//  13s-b U1b (R-13s-37, her words: "encryption explained not present and
//  not restorable") — *Encryption Explained*'s DOORS ARE RETIRED: the
//  launch no longer seeds it (piece 1, `aFreshLaunchSeedsTheFinalSet`),
//  the tutorial door no longer silently ensures it, and no Help ▸ Restore
//  or phone Settings row mints it. This file's pre-13x F2/F3 subjects
//  split three ways:
//
//    · the DOOR subjects (the tutorial door seeds/declines the book, the
//      purge-outlives-tombstone choreography THROUGH that door) retired
//      with the ensure — replaced here by the new contract's pin: opening
//      the tutorial leaves NO encryption book, ever;
//    · the MECHANISM subjects (the seed latch; the shared restore brain's
//      words and already-whole voice) survive on the REMAINING vehicles —
//      JUSTIFIED VEHICLE EDITS, each said at its test;
//    · the seeder-level tombstone rule ("deleted ⇒ never re-seeded") keeps
//      its own pins (18o U2's, and the phone's first-write pin, which
//      13s-b re-vehicled onto Sherlock).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("13s-b U1b — the encryption book's doors retired; the latch and restore brain live on")
struct EncryptionBookDoorTests {
    private func withWorld<T>(
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
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 21))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            // F3 (MINOR-N3): the door's mark leaf INJECTED — a headless pin
            // never reads the test host's defaults, a domain the real app
            // shares (her real store's own mark must never decide a pin).
            session.seededBookMarkIsSet = { _ in false }
            session.markSeededBook = { _ in }
            return try await body(session, db)
        }
    }

    private func poll(_ condition: @MainActor () -> Bool, turns: Int = 800) async {
        for _ in 0..<turns {
            if condition() { return }
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(5))
        }
    }

    private func encryptionBooks(_ db: AppDatabase) async throws -> Int {
        try await db.read { db in
            try Queries.readings(db)
                .filter {
                    $0.name == SampleLibrarySeeder.Book.encryptionExplained.name
                        && $0.deletedAt == nil
                }.count
        }
    }

    /// **THE NEW CONTRACT (R-13s-37) — RED ON OLD: the old tutorial door
    /// minted the book beside the guide.** Opening the tutorial on a store
    /// with no seeded books opens the guide and leaves NO *Encryption
    /// Explained* — not minted, not tombstoned, nothing spoken about it;
    /// and a second open changes nothing.
    @Test func openingTheTutorialMintsNoEncryptionBook() async throws {
        try await withWorld { session, db in
            let shell = ShellRouter()
            let actions = ShellActions(session: session, shell: shell)
            actions.openTutorial(confirm: { true })
            await poll { shell.pendingSelection != nil }
            await poll { !session.tutorialDoorInFlight }
            guard case .reading(let openedID)? = shell.pendingSelection else {
                Issue.record("the tutorial opens")
                return
            }
            let tutorialBooks = try await db.read { db in
                try Queries.readings(db)
                    .filter { $0.name == TutorialSeeder.bookName && $0.deletedAt == nil }
                    .map(\.id)
            }
            #expect(tutorialBooks == [openedID], "the door opened the tutorial, as before")
            #expect(try await encryptionBooks(db) == 0, "no Encryption Explained (R-13s-37)")
            let everExisted = try await db.read { db in
                try Queries.readingTombstoneExists(
                    db, name: SampleLibrarySeeder.Book.encryptionExplained.name)
            }
            #expect(!everExisted, "never minted at all")
            #expect(session.status.spoken?.text.contains("could not be restored") != true,
                    "and nothing is said about it")

            shell.pendingSelection = nil
            actions.openTutorial(confirm: { true })
            await poll { shell.pendingSelection != nil }
            await poll { !session.tutorialDoorInFlight }
            #expect(try await encryptionBooks(db) == 0, "a second open changes nothing")
        }
    }

    /// **"… IS ALREADY WHOLE" IS A REFUSAL** (the 18i ladder round 1, MINOR-3
    /// — J33): the minting press is a receipt (and `off` drops it); the
    /// second press changed nothing, so it speaks as a refusal whatever the
    /// setting. **JUSTIFIED VEHICLE EDIT (13s-b U1b):** the pin rode the
    /// retired Encryption Explained door and now rides Help ▸ Restore
    /// Jekyll — the same `restoreSeededBook` road, voice rule unchanged.
    @Test func theAlreadyWholeLineIsARefusalAndAlwaysShows() async throws {
        try await withWorld { session, _ in
            let actions = ShellActions(session: session, shell: ShellRouter())
            session.status.receiptStyle = .off

            actions.restoreJekyllBook()
            await poll { session.status.lastDroppedReceipt != nil }
            #expect(session.status.lastDroppedReceipt?.hasPrefix("Restored") == true,
                    "the minting press IS a receipt, and `off` drops it: \(session.status.lastDroppedReceipt ?? "nil")")

            session.status.clear()
            actions.restoreJekyllBook()
            await poll { session.status.current != nil }
            #expect(session.status.current?.text
                    == "\u{201C}\(SampleLibrarySeeder.Book.jekyllAndHyde.name)\u{201D} "
                    + "is already whole — it's on your Bookcase.")  // 13i-d U6 (a): the area's ruled name
            #expect(session.status.current?.kind == .refusal,
                    "nothing was minted — P-2 says she sees it whatever the setting")
        }
    }

    /// The latch's contract (RUN A batch A2, row 8): while one road holds a
    /// book's discover-then-mint, the other WAITS and then re-discovers —
    /// so it finds the book the first minted instead of minting a twin.
    /// **JUSTIFIED VEHICLE EDIT (13s-b U1b):** the pin rode Encryption
    /// Explained (then a launch book) and now rides SHERLOCK, the remaining
    /// launch book — the same `withSeedLatch`, per book per store.
    @Test func theSeedLatchHoldsOneDiscoverThenMintPerBookPerStore() async throws {
        try await withWorld { session, db in
            let released = LockIsolated(false)
            let launch = Task { @MainActor in
                await SampleLibrarySeeder.seedIfNeeded(
                    session: session, book: .sherlock,
                    loadMark: { false }, saveMark: { _ in },
                    pacing: {
                        while !released.value {
                            await Task.yield()
                            try? await Task.sleep(for: .milliseconds(5))
                        }
                    })
            }
            try? await Task.sleep(for: .milliseconds(100))
            let second = Task { @MainActor in
                try await SeededBookRestore.restore(session: session, book: .sherlock)
            }
            try? await Task.sleep(for: .milliseconds(100))
            released.setValue(true)
            let launchOutcome = await launch.value
            let secondOutcome = try await second.value

            let books = try await db.read { db in
                try Queries.readings(db)
                    .filter {
                        $0.name == SampleLibrarySeeder.Book.sherlock.name && $0.deletedAt == nil
                    }.count
            }
            #expect(books == 1, "\(launchOutcome) then \(secondOutcome)")
            if case .alreadyWhole = secondOutcome {} else {
                Issue.record("the waiting road re-discovers and finds the book: \(secondOutcome)")
            }
        }
    }

    /// The shared restore brain (the Mac's Help ▸ Restore doors ride it): a
    /// missing book is minted whole, a whole one is reported, and every
    /// failure speaks WORDS, never a raw enum. **JUSTIFIED VEHICLE EDIT
    /// (13s-b U1b):** the brain pin rode Encryption Explained and now rides
    /// Jekyll (a surviving door's book — front matter beside two chapters
    /// and takemania; `minted` counts the plan's three entries).
    @Test func theSharedRestoreMintsWhatIsMissingAndReportsAWholeBook() async throws {
        try await withWorld { session, db in
            let first = try await SeededBookRestore.restore(session: session, book: .jekyllAndHyde)
            guard case .restored(let readingID, let minted) = first else {
                Issue.record("a fresh store mints the book: \(first)")
                return
            }
            #expect(minted == 3, "two chapters and takemania — the plan's entries")
            let second = try await SeededBookRestore.restore(session: session, book: .jekyllAndHyde)
            #expect(second == .alreadyWhole(readingID: readingID))
            // F3 (NIT-N6): the road's failures speak words on every face —
            // never a raw enum description (the Act 10 round's dump class).
            let cases: [(any Error, String)] = [
                (SampleLibrarySeeder.LoadError.resourceMissing, "resourceMissing"),
                (CancellationError(), "CancellationError"),
                (OperationError.readingNotFound(id: "a-book-id"), "readingNotFound"),
                (OperationError.lockedReading(id: "a-book-id"), "lockedReading"),
                (OperationError.readingAtCapacity(id: "a-book-id"), "readingAtCapacity"),
                (Takemania.ScriptError.displayedTakeNotInFan(blockID: "a-block-id"), "displayedTakeNotInFan"),
            ]
            for (error, name) in cases {
                let line = SeededBookRestore.failureLine(for: error)
                #expect(!line.contains(name) && line.hasSuffix("."), "\(name) → \(line)")
            }
            #expect(SeededBookRestore.failureLine(for: OperationError.duplicateBookName(name: "Encryption Explained"))
                    == BookNameCopy.refusal(existing: "Encryption Explained"), "the one home for her duplicate-name ruling")
            // R2-N1: the approved platform-neutral words, exactly.
            #expect(SeededBookRestore.failureLine(for: OperationError.lockedReading(id: "b"))
                    == "The book is finished \u{2014} reopen it (or unseal it, if it\u{2019}s sealed), "
                        + "then restore again.")
        }
    }
}
