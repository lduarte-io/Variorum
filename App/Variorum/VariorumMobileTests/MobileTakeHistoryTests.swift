//
//  MobileTakeHistoryTests.swift
//  VariorumMobileTests
//
//  Parity round Stage C, batch C4a — the commit door + the take-history
//  face: AppSpec §9's deliberate-savepoint pillar on the phone. Both
//  doors ride the block ⋯ and act on the DISPLAYED take (the Mac's
//  caret-variant semantics); history rows flag pre-split commits through
//  the ONE core predicate, and the pre-split restore gates on a confirm
//  (the §9 documented warning: the old commit resurrects pre-split text).
//

import Dependencies
import Foundation
import GRDB
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

// MARK: - Harness

@MainActor
private func seedPost(
    _ session: AppSession
) async throws -> (postID: String, blockID: String, variantID: String) {
    try await session.runner.run { ops in
        let post = try ops.createPost(title: "history", profile: .blog)
        let a = try ops.newBlock(
            in: post.id, text: "First sentence stays. Second sentence leaves.", at: .end)
        return (post.id, a.block.id, a.variant.id)
    }
}

@MainActor
private func storedTakeText(_ db: AppDatabase, variantID: String) async throws -> String? {
    try await db.read { db in
        try String.fetchOne(
            db,
            sql: "SELECT working_text FROM variant WHERE id = ? AND deleted_at IS NULL",
            arguments: [variantID])
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
@Suite("Mobile take history — commit · list · restore (parity C4a)")
struct MobileTakeHistoryTests {
    /// The commit door is FLUSH-FIRST: the savepoint holds exactly the
    /// bytes she sees (pending surface text included), kind manual, with
    /// the success spoken.
    @Test func commitKeepsASavepointOfTheDisplayedTakeFlushFirst() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            // Pending, unflushed bytes on the displayed take (the one
            // ledger + coordinator the page and the sheet share).
            let typed = "First sentence stays. Second sentence leaves. Typed."
            model.recordTakeEdit(variantID: seed.variantID, text: typed, charDelta: 7)
            #expect(model.autosave.isDirty)

            await model.takeHistory.commitNow(blockID: seed.blockID)

            #expect(model.statusMessage == MobileTakeHistoryController.committedStatus)
            let commits = try await commitRows(db, variantID: seed.variantID)
            #expect(commits.map(\.kind) == ["manual"])
            #expect(commits.first?.text == typed,
                    "the savepoint holds the TYPED bytes — the flush rode in front")
            #expect(!model.autosave.isDirty)
        }
    }

    /// The seal and the take lock both refuse in phone words (the ops'
    /// own guards — commit is forbidden under both).
    @Test func commitUnderSealAndOnALockedTakeRefuseInPhoneWords() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedPost(session)
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            try await session.runner.run { ops in try ops.lockVariant(seed.variantID) }
            await model.refreshTakesFromStore()
            await model.takeHistory.commitNow(blockID: seed.blockID)
            #expect(model.statusMessage == MobileEditorViewModel.lockedTakeRefusal)

            try await session.runner.run { ops in try ops.unlockVariant(seed.variantID) }
            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            await model.refreshTakesFromStore()
            await model.takeHistory.commitNow(blockID: seed.blockID)
            #expect(model.statusMessage == "This note is locked — unlock it to commit this take.")
            // The one row is the SEAL's own auto-commit insurance
            // (lockPost insures dirty buffers — its designed behavior);
            // the refused door added no manual savepoint.
            #expect(try await commitRows(db, variantID: seed.variantID).map(\.kind) == ["auto"])
        }
    }

    /// The list is newest-first with kinds marked, and commits older
    /// than the newest divide/extract wear the pre-split flag — through
    /// the ONE core predicate (`Queries.commitPredatesSplit`).
    @Test func theHistoryListsNewestFirstWithKindsAndThePreSplitFlag() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedPost(session)
            // Two pre-split savepoints (manual, then auto), then the
            // divide, then a post-split savepoint.
            try await session.runner.run { ops in
                _ = try ops.commit(seed.variantID, kind: .manual)
                try ops.autosave(
                    seed.variantID,
                    text: "First sentence stays! Second sentence leaves.", charDelta: 1)
                _ = try ops.commit(seed.variantID, kind: .auto)
                _ = try ops.divide(seed.blockID, cut: 22)
                _ = try ops.commit(seed.variantID, kind: .manual)
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()

            model.takeHistory.open(blockID: seed.blockID)
            await model.takeHistory.refresh()
            #expect(model.takeHistory.variantID == seed.variantID,
                    "the sheet lists the DISPLAYED take's history")

            let items = model.takeHistory.items
            #expect(items.count == 3)
            #expect(items.map(\.commit.kind) == [.manual, .auto, .manual],
                    "newest first")
            #expect(items.map(\.predatesSplit) == [false, true, true],
                    "commits older than the newest split wear the flag; the post-split one doesn't")
        }
    }

    /// Restore loads the savepoint back into the buffer and the surface
    /// heals; a PRE-SPLIT row gates on the confirm first, and confirming
    /// resurrects the full pre-split text (AppSpec §9's documented
    /// behavior, warned exactly as the spec asks).
    @Test func restoreLoadsTheSavepointAndThePreSplitRoadGatesOnConfirm() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedPost(session)
            let full = "First sentence stays. Second sentence leaves."
            try await session.runner.run { ops in
                _ = try ops.commit(seed.variantID, kind: .manual)   // pre-split: the full text
                _ = try ops.divide(seed.blockID, cut: 22)
                _ = try ops.commit(seed.variantID, kind: .manual)   // post-split: the first half
                try ops.autosave(seed.variantID, text: "First sentence, reworked.", charDelta: 8)
            }
            let (model, storage) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takeHistory.open(blockID: seed.blockID)
            await model.takeHistory.refresh()
            let items = model.takeHistory.items
            let postSplit = try #require(items.first { !$0.predatesSplit })
            let preSplit = try #require(items.first { $0.predatesSplit })

            // The clean restore: buffer + surface read as the savepoint.
            await model.takeHistory.restore(postSplit)
            #expect(model.statusMessage == MobileTakeHistoryController.restoredStatus)
            #expect(try await storedTakeText(db, variantID: seed.variantID) == postSplit.commit.text)
            #expect(storage.string.contains(postSplit.commit.text))

            // The pre-split road GATES: nothing moves until the confirm.
            await model.takeHistory.restore(preSplit)
            #expect(model.takeHistory.pendingRestore == preSplit)
            #expect(try await storedTakeText(db, variantID: seed.variantID) == postSplit.commit.text,
                    "unconfirmed — the buffer is untouched")

            // Cancel clears the gate; nothing happened.
            model.takeHistory.cancelPendingRestore()
            #expect(model.takeHistory.pendingRestore == nil)

            // Confirmed: the full pre-split text resurrects into THIS
            // buffer (the successor block still sits next door — the
            // documented, warned outcome).
            await model.takeHistory.restore(preSplit, confirmed: true)
            #expect(model.statusMessage == MobileTakeHistoryController.restoredStatus)
            #expect(try await storedTakeText(db, variantID: seed.variantID) == full)
            #expect(storage.string.contains(full))
        }
    }

    /// Restore refuses under the seal, in phone words; the buffer stays.
    @Test func restoreUnderASealedNoteRefusesInPhoneWords() async throws {
        try await withEditorWorld { session, db in
            let seed = try await seedPost(session)
            try await session.runner.run { ops in
                _ = try ops.commit(seed.variantID, kind: .manual)
                try ops.autosave(seed.variantID, text: "Edited past the savepoint.", charDelta: 5)
            }
            let (model, _) = makeEditor(session, postID: seed.postID)
            await model.loadOnce()
            model.takeHistory.open(blockID: seed.blockID)
            await model.takeHistory.refresh()
            let item = try #require(model.takeHistory.items.first)

            try await session.runner.run { [postID = seed.postID] ops in
                try ops.lockPost(postID)
            }
            await model.takeHistory.restore(item)
            #expect(model.statusMessage
                    == "This note is locked — unlock it to restore this savepoint.")
            #expect(try await storedTakeText(db, variantID: seed.variantID)
                    == "Edited past the savepoint.")
        }
    }

    /// The copy statics — the promises the sheet and the ⋯ make, pinned;
    /// no platform name anywhere in the family.
    @Test func theHistoryCopyIsPinnedAndPlatformFree() async throws {
        #expect(MobileTakeHistoryController.committedStatus
                == "Committed — a savepoint of this take is kept.")
        #expect(MobileTakeHistoryController.restoredStatus
                == "Restored — the take now reads as that savepoint.")
        #expect(MobileTakeHistoryController.predatesSplitRowFlag == "predates a split")
        #expect(MobileTakeHistoryController.predatesSplitWarning
                == "This commit predates a split of this block — restoring it brings back text from before the split.")
        #expect(MobileBlockMenuController.commitTitle == "Commit Take")
        #expect(MobileBlockMenuController.historyTitle == "Take History…")
        for copy in [
            MobileTakeHistoryController.committedStatus,
            MobileTakeHistoryController.restoredStatus,
            MobileTakeHistoryController.predatesSplitWarning,
        ] {
            #expect(!copy.contains("Mac"))
        }
    }
}
