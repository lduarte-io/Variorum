//
//  EncryptionBookDoorTests.swift
//  VariorumTests
//
//  pre-13x ladder round 1, F2 (MINOR-8): the tutorial door seeds *Encryption
//  Explained* when it is absent — Lesson 2's last paragraph points at the
//  book "on this shelf", and a signed-in-never-synced store seeds neither
//  book (ledger 70's arrive-by-sync gate). RED ON OLD: the door opened the
//  tutorial and left the sentence pointing at nothing.
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("pre-13x F2 — the tutorial door seeds the encryption book (MINOR-8)")
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

    private func encryptionBook(_ db: AppDatabase) async throws -> (complete: Bool, books: Int) {
        let titles = try SampleLibrarySeeder.loadStories(for: .encryptionExplained).map(\.title)
        let (existing, books) = try await db.read { db in
            (try SampleLibrarySeeder.discover(db, book: .encryptionExplained),
             try Queries.readings(db)
                .filter { $0.name == SampleLibrarySeeder.Book.encryptionExplained.name && $0.deletedAt == nil }.count)
        }
        return (existing.isComplete(for: titles), books)
    }

    /// The door on a store with NO seeded books (the gate never opened):
    /// the tutorial opens AND *Encryption Explained* is minted whole beside
    /// it — once; a second open re-seeds nothing.
    @Test func openingTheTutorialSeedsTheEncryptionBookWhenItIsAbsentAndNeverTwice() async throws {
        try await withWorld { session, db in
            let before = try await encryptionBook(db)
            #expect(!before.complete && before.books == 0, "the gate never opened — no book")

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
                try Queries.readings(db).filter { $0.name == TutorialSeeder.bookName && $0.deletedAt == nil }.map(\.id)
            }
            #expect(tutorialBooks == [openedID], "the door opened the tutorial, as before")
            let after = try await encryptionBook(db)
            #expect(after.complete && after.books == 1, "the book Lesson 2 names is on the shelf — whole")
            #expect(session.status.spoken?.text.contains("could not be restored") != true, "silent on success")

            // Again: the existing tutorial opens, the book stays one.
            shell.pendingSelection = nil
            actions.openTutorial(confirm: { true })
            await poll { shell.pendingSelection != nil }
            await poll { !session.tutorialDoorInFlight }
            let again = try await encryptionBook(db)
            #expect(again.complete && again.books == 1, "never a second copy")
        }
    }

    /// pre-13x ladder round 2, F3 (MINOR-N3) — RED ON OLD: the silent
    /// ensure re-minted a book the reader DELIBERATELY DELETED, on every
    /// tutorial open (the seeder's own "deleted ⇒ never re-seeded" rule
    /// bypassed). The tombstone is the reader's word: the tutorial opens,
    /// the book stays gone; the EXPLICIT restore door — an ask — still
    /// brings it back, afresh.
    @Test func theTutorialDoorDoesNotReMintABookTheReaderDeleted() async throws {
        try await withWorld { session, db in
            let first = try await SeededBookRestore.restore(session: session, book: .encryptionExplained)
            guard case .restored(let readingID, _) = first else {
                Issue.record("a fresh store mints the book: \(first)")
                return
            }
            try session.operations.deleteReading(readingID)
            #expect(try await encryptionBook(db).books == 0, "the reader deleted the book")

            let shell = ShellRouter()
            let actions = ShellActions(session: session, shell: shell)
            actions.openTutorial(confirm: { true })
            await poll { shell.pendingSelection != nil }
            await poll { !session.tutorialDoorInFlight }
            guard case .reading? = shell.pendingSelection else {
                Issue.record("the tutorial opens")
                return
            }
            let after = try await encryptionBook(db)
            #expect(after.books == 0, "the reader's deletion STANDS — the silent ensure declines on the tombstone")
            #expect(session.status.spoken?.text.contains("could not be restored") != true, "a decline is not a failure — nothing spoken")

            // The explicit door is an ask: it mints afresh (a new reading).
            let again = try await SeededBookRestore.restore(session: session, book: .encryptionExplained)
            guard case .restored(let newID, _) = again else {
                Issue.record("Help ▸ Restore still mints: \(again)")
                return
            }
            #expect(newID != readingID)
            #expect(try await encryptionBook(db).books == 1)
        }
    }

    /// F3 (MINOR-N3): the OTHER evidence — this device's per-book seeded
    /// mark (the launch seeder's rule) — read through the ensure's injected
    /// leaf: marked ⇒ declined, nothing minted; unmarked ⇒ the book.
    @Test func theSilentEnsureDeclinesOnTheSeededMarkAndMintsWithoutIt() async throws {
        try await withWorld { session, db in
            let marked = try await SeededBookRestore.ensure(
                session: session, book: .encryptionExplained, markIsSet: { true })
            #expect(marked == .declined(.markedSeeded))
            #expect(try await encryptionBook(db).books == 0, "nothing minted under the mark")
            let unmarked = try await SeededBookRestore.ensure(
                session: session, book: .encryptionExplained, markIsSet: { false })
            guard case .ensured(.restored(_, let minted)) = unmarked else {
                Issue.record("unmarked, the ensure mints: \(unmarked)")
                return
            }
            #expect(minted == 8)
            // The door reads the SESSION's leaf: marked there, the door declines too.
            session.seededBookMarkIsSet = { _ in true }
            let shell = ShellRouter()
            let actions = ShellActions(session: session, shell: shell)
            // `Existing` is MainActor-isolated: read it whole, ask it on the actor.
            let existing = try await db.read { db in try SampleLibrarySeeder.discover(db, book: .encryptionExplained) }
            try session.operations.deleteReading(try #require(existing.bookID))
            actions.openTutorial(confirm: { true })
            await poll { shell.pendingSelection != nil }
            await poll { !session.tutorialDoorInFlight }
            #expect(try await encryptionBook(db).books == 0, "the mark declines the door's ensure")
        }
    }

    /// The shared restore brain (the Mac's Help ▸ Restore and the phone's
    /// row ride it): a partial book is completed, a whole one is reported.
    @Test func theSharedRestoreMintsWhatIsMissingAndReportsAWholeBook() async throws {
        try await withWorld { session, db in
            let first = try await SeededBookRestore.restore(session: session, book: .encryptionExplained)
            guard case .restored(let readingID, let minted) = first else {
                Issue.record("a fresh store mints the book: \(first)")
                return
            }
            #expect(minted == 8, "eight chapters")
            let second = try await SeededBookRestore.restore(session: session, book: .encryptionExplained)
            #expect(second == .alreadyWhole(readingID: readingID))
            // F3 (NIT-N6): the road's failures speak words on every face —
            // never a raw enum description (the Act 10 round's dump class).
            let cases: [(any Error, String)] = [
                (SampleLibrarySeeder.LoadError.resourceMissing, "resourceMissing"),
                (CancellationError(), "CancellationError"),
                (OperationError.readingNotFound(id: "a-book-id"), "readingNotFound"),
            ]
            for (error, name) in cases {
                let line = SeededBookRestore.failureLine(for: error)
                #expect(!line.contains(name) && line.hasSuffix("."), "\(name) → \(line)")
            }
            #expect(SeededBookRestore.failureLine(for: OperationError.duplicateBookName(name: "Encryption Explained"))
                    == BookNameCopy.refusal(existing: "Encryption Explained"), "the one home for her duplicate-name ruling")
            // Delete one chapter: the restore brings that one back.
            let chapterID = try await db.read { db in
                try Queries.assembleReading(db, readingID: readingID).first { $0.title == "Chapter 5 — Backups, and why an old one behaves the way it does" }?.postID
            }
            let victim = try #require(chapterID)
            try session.operations.deleteContainer(victim)
            let third = try await SeededBookRestore.restore(session: session, book: .encryptionExplained)
            #expect(third == .restored(readingID: readingID, minted: 1), "\(third)")
        }
    }
}
