//
//  SeededBookRestore.swift
//  Shared (Variorum + VariorumMobile)
//
//  pre-13x ladder round 1, F2 (MINOR-8) — ONE road to RESTORE a seeded book
//  (Sherlock, *Encryption Explained*, and since 18l-c U6 *The Strange Case of
//  Dr Jekyll and Mr Hyde* — takemania's book): mint what is MISSING through the
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
//  RUN A batch A2, row 8 (17l item 1 / KnownIssues 38) — TWO THINGS:
//
//    · **The latch.** Discover-then-mint is one act per book per store
//      (`SampleLibrarySeeder.withSeedLatch`): the launch seed and this road
//      both read the store and then mint what is missing, with awaits in
//      between, so a tutorial open inside the launch seed's window used to
//      leave TWO copies of the book on the shelf (and two Restore presses
//      did the same).
//    · **The decision outlives the tombstone.** F3's ensure declines on a
//      tombstoned reading of the book's name — but Delete Now / Empty Trash
//      write a purge intent and the janitor then physically REMOVES the row,
//      and 13j's purged-ids ledger is content-free BY DESIGN (a table name
//      and a row id; never a book's name, on the client's `purge_intent` or
//      on the server's `purged_row`). So nothing that survives a purge can
//      be asked "was a book called this deleted?" — the honest answer is to
//      record the reader's decision on this device WHILE the evidence
//      stands, in the one place the seeder already keeps it (its per-book
//      mark; `AppSession.markSeededBook`). The explicit doors are an ask and
//      still mint; they mark too, because a device that HAS the book must
//      treat its later removal as the reader's word.
//      *The recorded residual:* a device that ran none of the roads that
//      record — this ensure, the explicit doors, and (since 18o U2) the
//      launch seed — between the deletion and the purge holds no evidence,
//      and re-mints. The mark
//      is `UserDefaults` — the seeder's header records the same limit for
//      "deletion is final" itself, and closing it wants a marker that
//      travels with the STORE (that file's own note).
//

import Foundation
import VariorumCore

nonisolated enum SeededBookRestore {
    // (The SILENT ENSURE — pre-13x F2/F3's tutorial-door road — RETIRED at
    // 13s-b U1b with its one caller, R-13s-37: the tutorial door no longer
    // ensures *Encryption Explained*, and nothing else was silent. The
    // explicit doors below keep minting through `restore`; the tombstone
    // rule they and the launch share lives in
    // `SampleLibrarySeeder.readerDeletedTheBook`, exactly as before.)
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
        // 18l-c U6 ladder F1: the book REFUSES new notes — "try again" can
        // never succeed there, so the line names what to change. Nothing was
        // minted (the scripted note mints through `newPostInReading`, the
        // imported road asks `assertReadingAcceptsPosts` first — R2-M2).
        // PLATFORM-NEUTRAL words (R2-N1): this is the shared home, and the
        // phone's restore row speaks these lines too — no Mac-only control.
        // 13i-d U6 (KnownIssues row 106 — reachable: seal a sample book,
        // trash one of its notes, restore): a SEALED book's road is Unseal
        // (Reopen refuses there); the line holds no book, so it names both.
        case OperationError.lockedReading:
            return "The book is finished \u{2014} reopen it (or unseal it, if it\u{2019}s sealed), "
                + "then restore again."
        case OperationError.readingAtCapacity:
            return "The book is at its note cap — raise the cap, then restore again."
        // 18l-c U6 ladder F12: a scripted history stopped partway (a script
        // bug the pins catch first): a half-built note may stand — the next
        // restore trashes it and mints a whole one.
        case is Takemania.ScriptError:
            return "It stopped partway through the note's history — the unfinished note goes when you restore again."
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
        // RUN A batch A2, row 8: the discover-then-mint runs under the
        // seeder's latch — one at a time per book per store, so this road
        // and the launch seed (and two Restore presses) can never each mint
        // a copy of the same book. The discovery is INSIDE, deliberately: a
        // road that waited and then minted from what it read BEFORE waiting
        // is the same twin by a slower route.
        return try await SampleLibrarySeeder.withSeedLatch(session: session, book: book) {
            let existing = try await session.database.read { db in
                try SampleLibrarySeeder.discover(db, book: book)
            }
            // 18l-c U6: the scripted note's title counts toward "whole".
            let titles = SampleLibrarySeeder.expectedTitles(for: book, stories: stories)
            if existing.isComplete(for: titles), let bookID = existing.bookID {
                // This device has the book — its later removal is the
                // reader's word, and the mark is where that word survives
                // the tombstone's own purge (the header's note).
                session.markSeededBook(book)
                return .alreadyWhole(readingID: bookID)
            }
            let seeded = try await SampleLibrarySeeder.seed(
                session: session, book: book, stories: stories, existing: existing)
            session.markSeededBook(book)
            return .restored(readingID: seeded.readingID, minted: seeded.minted)
        }
    }
}
