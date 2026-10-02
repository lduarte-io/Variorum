//
//  MobileSeededBookRestoreTests.swift
//  VariorumMobileTests
//
//  pre-13x ladder round 1, F2 (MINOR-8): the phone's restore row for
//  *Encryption Explained* rides the SHARED `SeededBookRestore` road — on the
//  phone a signed-in-never-synced store seeds neither book (ledger 70's
//  gate), and until F2 there was no door for it at all. Headless over the
//  phone's own session world: a fresh store mints the book whole, a whole
//  book is reported, a missing chapter comes back alone.
//

import Foundation
import Testing
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("pre-13x F2 — the phone restores the encryption book (MINOR-8)")
struct MobileSeededBookRestoreTests {
    @Test func theSharedRestoreMintsTheBookWholeThenReportsItAndBringsAMissingChapterBack() async throws {
        try await withEditorWorld { session, db in
            // RUN A batch A2, row 8: the restore road now RECORDS this
            // device's per-book mark; injected here so a headless phone run
            // never writes the simulator app's own defaults.
            session.markSeededBook = { _ in }
            let titles = try SampleLibrarySeeder.loadStories(for: .encryptionExplained).map(\.title)
            let first = try await SeededBookRestore.restore(session: session, book: .encryptionExplained)
            guard case .restored(let readingID, let minted) = first else {
                Issue.record("a fresh phone store mints the book: \(first)")
                return
            }
            #expect(minted == 8, "eight chapters")
            let existing = try await db.read { db in
                try SampleLibrarySeeder.discover(db, book: .encryptionExplained)
            }
            #expect(existing.isComplete(for: titles), "the book Lesson 2 names is on the phone's shelf — whole")
            #expect(try await SeededBookRestore.restore(session: session, book: .encryptionExplained)
                    == .alreadyWhole(readingID: readingID))

            let chapterID = try await db.read { db in
                try Queries.assembleReading(db, readingID: readingID).first { $0.title == "Chapter 8 — What we can and cannot do for you" }?.postID
            }
            try session.operations.deleteContainer(try #require(chapterID))
            #expect(try await SeededBookRestore.restore(session: session, book: .encryptionExplained)
                    == .restored(readingID: readingID, minted: 1))
        }
    }

    /// pre-13x ladder round 2, F3 (NIT-N6): the phone's restore row renders
    /// the road's ONE failure brain — words, never `String(describing:)`
    /// (before F3 the row dumped the raw description on every build).
    @Test func theRestoreRowsFailuresSpeakWordsNeverARawDescription() {
        let cases: [(any Error, String)] = [
            (SampleLibrarySeeder.LoadError.resourceMissing, "resourceMissing"),
            (CancellationError(), "CancellationError"),
            (OperationError.readingNotFound(id: "a-book-id"), "readingNotFound"),
            // 18l-c U6 ladder R2-N1: the book-refuses arms, and F12's stopped
            // script history — on BOTH faces (the phone renders these lines too).
            (OperationError.lockedReading(id: "a-book-id"), "lockedReading"),
            (OperationError.readingAtCapacity(id: "a-book-id"), "readingAtCapacity"),
            (Takemania.ScriptError.displayedTakeNotInFan(blockID: "a-block-id"), "displayedTakeNotInFan"),
        ]
        for (error, name) in cases {
            let line = SeededBookRestore.failureLine(for: error)
            #expect(!line.contains(name) && line.hasSuffix("."), "\(name) → \(line)")
        }
        #expect(SeededBookRestore.failureLine(for: OperationError.duplicateBookName(name: "Encryption Explained"))
                == BookNameCopy.refusal(existing: "Encryption Explained"))
        // R2-N1: the approved platform-neutral words, exactly.
        // 13i-d U6 (KnownIssues row 106 — "both platforms"; a JUSTIFIED
        // EDIT): the shared line holds no book, so it names BOTH roads — a
        // sealed sample book's is Unseal (Reopen refuses there). Still
        // platform-neutral words.
        #expect(SeededBookRestore.failureLine(for: OperationError.lockedReading(id: "b"))
                == "The book is finished \u{2014} reopen it (or unseal it, if it\u{2019}s sealed), "
                    + "then restore again.")
        #expect(SeededBookRestore.failureLine(for: OperationError.readingAtCapacity(id: "b"))
                == "The book is at its note cap — raise the cap, then restore again.")
    }
}
