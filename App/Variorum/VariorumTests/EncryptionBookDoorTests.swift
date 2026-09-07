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
            try await body(AppSession(database: db), db)
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
            #expect(session.status.current?.text.contains("could not be restored") != true, "silent on success")

            // Again: the existing tutorial opens, the book stays one.
            shell.pendingSelection = nil
            actions.openTutorial(confirm: { true })
            await poll { shell.pendingSelection != nil }
            await poll { !session.tutorialDoorInFlight }
            let again = try await encryptionBook(db)
            #expect(again.complete && again.books == 1, "never a second copy")
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
