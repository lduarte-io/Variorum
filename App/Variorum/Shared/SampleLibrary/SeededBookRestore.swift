//
//  SeededBookRestore.swift
//  Shared (Variorum + VariorumMobile)
//
//  pre-13x ladder round 1, F2 (MINOR-8) — ONE road to RESTORE a seeded book
//  (Sherlock, *Encryption Explained*): mint what is MISSING through the
//  seeder's own resumable seed, never touching a copy the reader has —
//  the Mac's Help ▸ Restore door's brain (5a's `ShellActions.restoreSeeded
//  Book`, hoisted here at this touch per the shared-home rule) and, since
//  F2, the phone's restore row and the Mac tutorial door's silent ensure:
//  Lesson 2's last paragraph points at *Encryption Explained* "on this
//  shelf", and a store that belongs to an account but has never synced
//  cleanly seeds neither book (ledger 70's arrive-by-sync gate, which
//  stays) — so the door that opens the tutorial makes the sentence true
//  by this road. Every face composes its own receipt.
//

import Foundation
import VariorumCore

nonisolated enum SeededBookRestore {
    enum Outcome: Equatable, Sendable {
        /// Every title is present and the book exists — nothing minted.
        case alreadyWhole(readingID: String)
        /// The book and/or its missing notes were minted (the count is the
        /// seeder's — stories, or chapters).
        case restored(readingID: String, minted: Int)
        /// The seed reported something other than a mint (recorded, spoken).
        case refused(String)
    }

    /// Discover, then mint what is missing. Throws the seeder's own errors
    /// (a missing resource, a refused write) for the face to word.
    @MainActor
    static func restore(session: AppSession, book: SampleLibrarySeeder.Book) async throws -> Outcome {
        let stories = try await Task.detached(priority: .utility) {
            try SampleLibrarySeeder.loadStories(for: book)
        }.value
        let existing = try await session.database.read { db in
            try SampleLibrarySeeder.discover(db, book: book)
        }
        if existing.isComplete(for: stories.map(\.title)), let bookID = existing.bookID {
            return .alreadyWhole(readingID: bookID)
        }
        let outcome = try await SampleLibrarySeeder.seed(
            session: session, book: book, stories: stories, existing: existing)
        if case .seeded(let readingID, let minted) = outcome {
            return .restored(readingID: readingID, minted: minted)
        }
        return .refused(String(describing: outcome))
    }
}
