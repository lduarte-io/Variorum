//
//  MobileQuickNoteReadFailureTests.swift
//  VariorumMobileTests
//
//  **17b P14 (RUN A, batch A1) — a failed READ is not an empty note.**
//
//  THE MECHANISM, traced: `MobileQuickNoteModel.adopt` read the minted
//  note's blocks with `(try? await session.database.read { … }) ?? []`,
//  which folds a THROWN read into the identical empty array the guard
//  below treats as "nothing was minted". That guard's own comment argues
//  unreachability from the WRITE only ("`importPost` mints at least one
//  block or throws"), so the read road was never covered by it — and the
//  read can genuinely fail after the write has committed
//  (`AppBootstrap.lock()` closes the pool on a detached task).
//
//  All three consequences were wrong, and each is pinned below:
//   (a) she was told *"There's nothing to save yet."* about a note sitting
//       in SQLite;
//   (b) `postID` was never set, so `armMintClock`'s `postID == nil` guard
//       passed on her next keystroke and the clock minted a SECOND note
//       with the same words — repeatably;
//   (c) `variantID` stayed nil, so `record(tail:)` dropped everything she
//       typed afterwards, silently.
//
//  The fix takes the A1-19 arm's shape (the in-file precedent): own the
//  mint's identity FIRST, then, if the read fails, hold — the note keeps
//  what was minted, the box stops writing rather than guessing, and it
//  says where the editing lives.
//
//  DISCRIMINATING REVERT (verified): put `(try? …) ?? []` back and move
//  `postID = containerID` below the guard — (a), (b) and (c) all fail.
//

import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

private struct TheStoreClosed: Error {}

@MainActor
@Suite("17b P14 — the quick note's failed read never orphans the note")
struct MobileQuickNoteReadFailureTests {
    /// A box whose clocks are off and whose follow-up read THROWS — the
    /// pool closing between the committed write and the read.
    private func boxWithFailingRead(_ session: AppSession) -> MobileQuickNoteModel {
        let model = MobileQuickNoteModel(session: session)
        model.sleep = { _ in throw CancellationError() }
        model.autosaveSleep = { _ in throw CancellationError() }
        model.readMintedBlocks = { _ in throw TheStoreClosed() }
        return model
    }

    private func livePostCount(_ db: AppDatabase) async throws -> Int {
        try await db.read { db in
            try Int.fetchOne(
                db,
                sql: "SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL")
            ?? -1
        }
    }

    @Test func theNoteIsOwnedAndTheClockCannotMintItTwice() async throws {
        try await withEditorWorld { session, db in
            let box = boxWithFailingRead(session)
            box.text = "A thought worth keeping."

            let minted = await box.mintNow()

            #expect(minted != nil, "the WRITE committed — the note exists")
            var count = try await self.livePostCount(db)
            #expect(count == 1)
            #expect(box.postID == minted,
                    "the box owns the note's identity, whatever the read did")

            // (b) The clock's guard is `postID == nil`: with the identity
            // owned it can no longer mint a second copy of the same words.
            box.text = "A thought worth keeping. And more."
            let again = await box.mintNow()
            #expect(again == minted, "the same note, never a second one")
            count = try await self.livePostCount(db)
            #expect(count == 1, "one capture, one note — the double-mint is impossible")
        }
    }

    @Test func itSaysTheNoteIsSavedRatherThanThatThereIsNothingToSave() async throws {
        try await withEditorWorld { session, _ in
            let box = boxWithFailingRead(session)
            box.text = "A thought worth keeping."

            _ = await box.mintNow()

            #expect(box.lastError == nil,
                    "no refusal: nothing refused anything — the note was written")
            #expect(box.boundaryNote == MobileQuickNoteCopy.handoffHold,
                    "it says where the editing lives, which is the true thing to say")
            #expect(box.saveState == .saved, "because it IS saved")
        }
    }

    /// The guard arm: the ORDINARY road is untouched — a read that
    /// succeeds still hands the box its variant and keeps autosaving.
    @Test func anOrdinaryMintStillOwnsItsVariantAndKeepsWriting() async throws {
        try await withEditorWorld { session, db in
            let model = MobileQuickNoteModel(session: session)
            model.sleep = { _ in throw CancellationError() }
            model.autosaveSleep = { _ in throw CancellationError() }
            model.text = "A thought worth keeping."

            let minted = try #require(await model.mintNow())
            #expect(model.boundaryNote == nil)
            #expect(model.lastError == nil)

            model.text = "A thought worth keeping. And more."
            await session.flushEveryOpenPost()

            let stored = try await db.read { db in
                try Queries.renderPost(db, containerID: minted).last?.text
            }
            #expect(stored == "A thought worth keeping. And more.",
                    "the box is still writing into the note it owns")
            let count = try await self.livePostCount(db)
            #expect(count == 1)
        }
    }
}
