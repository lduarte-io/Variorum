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
//  pre-13x ladder round 2, F3 (MINOR-N3): the tutorial door's ensure is
//  SILENT — not an ask — so it goes through `ensure`, which DECLINES where
//  the reader's decision is on record (this device's per-book seeded mark;
//  any tombstoned reading of the book's name), while the explicit doors
//  (Help ▸ Restore, the phone's Settings row) keep minting through
//  `restore`. Before F3 the ensure re-minted a book the reader had
//  deliberately deleted, on every tutorial open.
//

import Foundation
import VariorumCore

nonisolated enum SeededBookRestore {
    /// Why the silent ensure declined — the reader's decision, as recorded.
    enum Declined: Equatable, Sendable {
        /// This device's launch seeder marked the book seeded (the mark
        /// survives the reader deleting it — the seeder's own rule).
        case markedSeeded
        /// A reading of the book's name is tombstoned (a Delete Now included).
        case deletedByTheReader
    }

    enum EnsureOutcome: Equatable, Sendable {
        case declined(Declined)
        case ensured(Outcome)
    }

    /// THE SILENT ENSURE (the tutorial door): decline on the mark or on a
    /// tombstone; else `restore`. `markIsSet` is the caller's leaf — the
    /// production door reads `SampleLibrarySeeder.isMarkedSeeded` for the
    /// session's store variant; a headless pin never reads the test host's
    /// defaults (a domain the real app shares).
    @MainActor
    static func ensure(
        session: AppSession, book: SampleLibrarySeeder.Book, markIsSet: @MainActor () -> Bool
    ) async throws -> EnsureOutcome {
        if markIsSet() { return .declined(.markedSeeded) }
        let deleted = try await session.database.read { db in
            try Queries.readingTombstoneExists(db, name: book.name)
        }
        if deleted { return .declined(.deletedByTheReader) }
        return .ensured(try await restore(session: session, book: book))
    }
    enum Outcome: Equatable, Sendable {
        /// Every title is present and the book exists — nothing minted.
        case alreadyWhole(readingID: String)
        /// The book and/or its missing notes were minted (the count is the
        /// seeder's — stories, or chapters).
        case restored(readingID: String, minted: Int)
        // (pre-13x ladder round 2, F3 — NIT-N6: the `.refused(String)` arm
        // is GONE — `seed` answers `Seeded` by type, so there was nothing
        // for it to carry but a raw enum dump, and no face may speak one.)
    }

    /// F3 (NIT-N6): the road's failures IN WORDS — ONE brain for its three
    /// faces (the Mac's Help ▸ Restore door and tutorial ensure, the
    /// phone's Settings row), never `String(describing:)` on a production
    /// face. The raw error is the caller's to LOG, not to show. (The Mac's
    /// `OpsRefusalCopy` stays Mac-local by the recorded rule — it carries
    /// Mac chords and Mac-only copy homes a shared home must not hold — so
    /// the road words its own error classes here, on both platforms.)
    static func failureLine(for error: any Error) -> String {
        switch error {
        case SampleLibrarySeeder.LoadError.resourceMissing, SampleLibrarySeeder.LoadError.noStories:
            return "This build is missing the book's text — nothing was restored."
        case is CancellationError:
            return "It was stopped before it finished — what came back stays; try again."
        case OperationError.duplicateBookName(let existing):
            return BookNameCopy.refusal(existing: existing)
        case is OperationError:
            return "The library refused a change partway — what was already restored stays; try again in a moment."
        default:
            return "The library couldn't be written to — nothing else was touched; try again in a moment."
        }
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
        let seeded = try await SampleLibrarySeeder.seed(
            session: session, book: book, stories: stories, existing: existing)
        return .restored(readingID: seeded.readingID, minted: seeded.minted)
    }
}
