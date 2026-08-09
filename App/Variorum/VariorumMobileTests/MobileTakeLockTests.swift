//
//  MobileTakeLockTests.swift
//  VariorumMobileTests
//
//  Parity round Stage C, batch C4a — take lock/unlock: the note seal's
//  sibling, through the core's own `lockVariant`/`unlockVariant` (the
//  lock-insures-first behavior is the OP's; the door adds the phone's
//  flush-first guard — the A1 `lockNote` trace, the take's edition).
//  The six locked-take "on the Mac" redirects dissolve WITH this door;
//  the copy pins below hold the phone-road wording on every home.
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - Harness (the browser suite's fixture shape, re-declared file-locally)

@MainActor
private func seedFannedPost(
    _ session: AppSession
) async throws -> (postID: String, blockA: String, a1: String, a2: String) {
    try await session.runner.run { ops in
        let post = try ops.createPost(title: "locks", profile: .blog)
        let a = try ops.newBlock(in: post.id, text: "First block, as chosen.", at: .end)
        _ = try ops.newBlock(in: post.id, text: "Second block, fanless.", at: .end)
        let take = try ops.branchVariant(a.block.id, from: a.variant.id)
        try ops.autosave(take.id, text: "First block, the other way.", charDelta: 9)
        return (post.id, a.block.id, a.variant.id, take.id)
    }
}

@MainActor
private func variantRow(
    _ db: AppDatabase, variantID: String
) async throws -> (text: String, locked: Bool)? {
    try await db.read { db in
        try Row.fetchOne(
            db,
            sql: "SELECT working_text, locked FROM variant WHERE id = ? AND deleted_at IS NULL",
            arguments: [variantID]
        ).map { ($0["working_text"], $0["locked"]) }
    }
}

@MainActor
private func commitRows(
    _ db: AppDatabase, variantID: String
) async throws -> [(kind: String, text: String)] {
    try await db.read { db in
        try Row.fetchAll(
            db,
            sql: """
                SELECT kind, text FROM commit_point WHERE variant_id = ?
                ORDER BY created_at, id
                """,
            arguments: [variantID]
        ).map { ($0["kind"], $0["text"]) }
    }
}

// MARK: - The suite

@MainActor
@Suite("Mobile take lock/unlock (parity C4a — the seal's sibling)")
struct MobileTakeLockTests {
    /// The reversible guard, state-mirrored: lock flips the row, unlock
    /// restores it, and a CLEAN (committed) buffer takes ZERO insurance
    /// commits either way — I6's lock-⊥-commit, proven through the door.
    @Test func theCardDoorLocksAndUnlocksTheTake() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            // A committed-clean buffer: the lock's insurance has nothing
            // to insure (isDirty reads buffer-vs-last-commit).
            try await session.runner.run { ops in _ = try ops.commit(seed.a2) }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takesBrowser.open(blockID: seed.blockA)

            await model.takesBrowser.setLocked(variantID: seed.a2, locked: true)
            #expect(model.statusMessage == nil)
            #expect(try await variantRow(db, variantID: seed.a2)?.locked == true)
            #expect(model.takesBrowser.cards().first { $0.variantID == seed.a2 }?.isLocked == true)
            #expect(try await commitRows(db, variantID: seed.a2).count == 1,
                    "a clean buffer takes no insurance commit (I6)")

            await model.takesBrowser.setLocked(variantID: seed.a2, locked: false)
            #expect(try await variantRow(db, variantID: seed.a2)?.locked == false)
            #expect(model.takesBrowser.cards().first { $0.variantID == seed.a2 }?.isLocked == false)
            #expect(try await commitRows(db, variantID: seed.a2).count == 1,
                    "unlock is reversible with zero commits (I6)")
        }
    }

    /// THE FLUSH-FIRST GUARD (the A1 `lockNote` trace, the take's
    /// edition — defect-class, mutation-checked by behavioral revert):
    /// pending SURFACE bytes land BEFORE the lock, so the op's own
    /// insurance commits the TYPED text and nothing is ever stranded
    /// pending behind a `.lockedVariant` refusal. On the blind path the
    /// store would hold the stale bytes, the insurance would commit
    /// them, and the typed text could never land — the text-loss class.
    @Test func lockingWithAPendingCardEditFlushesFirstAndInsuresTheTypedBytes() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takesBrowser.open(blockID: seed.blockA)

            // A pending, unflushed card edit on a2 (the debounce is held
            // open by the injected sleep).
            model.takesBrowser.beginEditing(variantID: seed.a2)
            let typed = "First block, the other way. Typed."
            #expect(model.takesBrowser.cardGateAllows(
                range: NSRange(location: 27, length: 0), replacement: " Typed."))
            model.takesBrowser.cardTextDidChange(typed)
            #expect(model.autosave.isDirty)

            await model.takesBrowser.setLocked(variantID: seed.a2, locked: true)

            let row = try await variantRow(db, variantID: seed.a2)
            #expect(row?.text == typed, "the typed bytes landed BEFORE the lock")
            #expect(row?.locked == true)
            let commits = try await commitRows(db, variantID: seed.a2)
            #expect(commits.map(\.kind) == ["auto"],
                    "one quiet insurance commit — of the typed bytes, not the stale store")
            #expect(commits.first?.text == typed)
            #expect(!model.autosave.isDirty, "nothing stranded pending behind the lock")
            #expect(model.takesBrowser.editingVariantID == nil,
                    "the locked take's live card ended")
        }
    }

    /// The seal outranks the take's own guard, in phone words — both
    /// directions of the door.
    @Test func lockAndUnlockUnderASealedNoteRefuseInPhoneWords() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedFannedPost(session)
            // A locked take under a later seal (the unlock arm's fixture).
            try await session.runner.run { ops in try ops.lockVariant(seed.a2) }
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takesBrowser.open(blockID: seed.blockA)

            await model.takesBrowser.setLocked(variantID: seed.a1, locked: true)
            #expect(model.statusMessage == "This note is locked — unlock it to lock a take.")
            #expect(try await variantRow(db, variantID: seed.a1)?.locked == false)

            await model.takesBrowser.setLocked(variantID: seed.a2, locked: false)
            #expect(model.statusMessage == "This note is locked — unlock it to unlock a take.")
            #expect(try await variantRow(db, variantID: seed.a2)?.locked == true)
        }
    }

    /// The dissolved redirects' copy, pinned at every home (parity C4a —
    /// the six locked-take strings lose "on the Mac" WITH the door): the
    /// statics say the phone road, the refusal mappers route through
    /// them, and no home carries a platform name.
    @Test func theLockedTakeRefusalsNameThePhoneRoadNotTheMac() async throws {
        #expect(MobileEditorViewModel.lockedTakeRefusal
                == "This take is locked — branch it, or unlock it from its card in the takes sheet (⑂).")
        #expect(MobileTakesBrowserController.lockedTakeCardRefusal
                == "This take is locked — unlock it from its card's ⋯, or branch it.")
        #expect(MobileTakesBrowserController.lockedTakeVerbRefusal
                == "That take is locked — unlock it from its card's ⋯ first.")
        #expect(MobileStructuralController.refusalMessage(
                    OperationError.lockedVariant(id: "x"), act: "divide the block")
                == MobileEditorViewModel.lockedTakeRefusal)
        #expect(MobileTakesBrowserController.refusalMessage(
                    OperationError.lockedVariant(id: "x"), verb: .delete)
                == MobileTakesBrowserController.lockedTakeVerbRefusal)
        for copy in [
            MobileEditorViewModel.lockedTakeRefusal,
            MobileTakesBrowserController.lockedTakeCardRefusal,
            MobileTakesBrowserController.lockedTakeVerbRefusal,
        ] {
            #expect(!copy.contains("Mac"), "no locked-take refusal names a platform")
        }
    }
}
