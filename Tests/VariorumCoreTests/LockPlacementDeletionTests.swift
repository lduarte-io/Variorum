import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Locks, archive/delete, placement (Phase 2, Step 6)")
struct LockPlacementDeletionTests {
    private func blockOrder(_ db: AppDatabase, _ containerID: String) throws -> [String] {
        try db.read { db in
            try String.fetchAll(
                db,
                sql: """
                    SELECT block_id FROM container_block
                    WHERE container_id = ? AND deleted_at IS NULL
                    ORDER BY position, id
                    """,
                arguments: [containerID])
        }
    }

    // MARK: Locks

    @Test func lockPostAutoCommitsDirtyBuffersThenSeals() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "uncommitted work")

            try ops.lockPost(post.id)

            let sealed = try db.read { db in try Container.fetchOne(db, key: post.id) }
            #expect(sealed?.locked == true)
            #expect(sealed?.lockedAt != nil)
            // The dirty buffer was insured with a quiet auto commit first.
            let kinds = try db.read { db in
                try String.fetchAll(
                    db, sql: "SELECT kind FROM commit_point WHERE variant_id = ?",
                    arguments: [made.variant.id])
            }
            #expect(kinds == ["auto"])

            // Reversible, zero further commits.
            try ops.unlockPost(post.id)
            let unsealed = try db.read { db in try Container.fetchOne(db, key: post.id) }
            #expect(unsealed?.locked == false)
            #expect(unsealed?.lockedAt == nil)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [made.variant.id]) == 1)
            try ops.autosave(made.variant.id, text: "editable again", charDelta: 2)
        }
    }

    @Test func lockPostRefusedOnAPool() throws {
        try withOperations { ops, _ in
            let pool = try ops.createPool()
            #expect(throws: OperationError.wrongContainerKind(id: pool.id, expected: .post)) {
                try ops.lockPost(pool.id)
            }
        }
    }

    @Test func lockedVariantFreezesItsBufferButBranchingStaysOpen() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "guarded")
            try ops.lockVariant(made.variant.id)

            #expect(throws: OperationError.lockedVariant(id: made.variant.id)) {
                try ops.autosave(made.variant.id, text: "x", charDelta: 1)
            }
            // "To edit, branch or unlock" — both escape hatches work.
            let branch = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.autosave(branch.id, text: "edited on the branch", charDelta: 5)

            try ops.unlockVariant(made.variant.id)
            try ops.autosave(made.variant.id, text: "unlocked again", charDelta: 5)
            _ = db
        }
    }

    @Test func lockVariantInsuresADirtyBufferWithOneQuietAutoCommit() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "protect this")

            // Dirty (never committed, non-empty) → locking commits it first.
            try ops.lockVariant(made.variant.id)
            let kinds = try db.read { db in
                try String.fetchAll(
                    db, sql: "SELECT kind FROM commit_point WHERE variant_id = ?",
                    arguments: [made.variant.id])
            }
            #expect(kinds == ["auto"])

            // Re-locking is a no-op; unlock+lock of a clean buffer adds none.
            try ops.lockVariant(made.variant.id)
            try ops.unlockVariant(made.variant.id)
            try ops.lockVariant(made.variant.id)
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [made.variant.id]) == 1)
        }
    }

    @Test func variantLockTogglesRefusedUnderASealedPost() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost()
            let unlocked = try ops.newBlock(in: post.id, text: "sealed in")
            let locked = try ops.newBlock(in: post.id, text: "sealed locked")
            try ops.lockVariant(locked.variant.id)
            try ops.lockPost(post.id)

            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.lockVariant(unlocked.variant.id)
            }
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.unlockVariant(locked.variant.id)
            }
            // No-op toggles stay quiet no-ops even under the seal.
            try ops.unlockVariant(unlocked.variant.id)
        }
    }

    // MARK: Archive / delete variant

    @Test func archiveRemovesFromFanAndReassignsTheDefault() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "take one")
            let branch = try ops.branchVariant(made.block.id, from: made.variant.id)

            try ops.archiveVariant(made.variant.id)

            let archived = try db.read { db in try Variant.fetchOne(db, key: made.variant.id) }
            #expect(archived?.status == .archived)
            #expect(archived?.deletedAt == nil)
            // default_variant_id reassigned to the surviving active variant.
            let block = try db.read { db in try Block.fetchOne(db, key: made.block.id) }
            #expect(block?.defaultVariantId == branch.id)

            try ops.unarchiveVariant(made.variant.id)
            let back = try db.read { db in try Variant.fetchOne(db, key: made.variant.id) }
            #expect(back?.status == .active)
        }
    }

    @Test func lastActiveVariantRefusesArchiveAndDelete() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "only take")

            // I10: removing the last active variant is deleting the block.
            #expect(throws: OperationError.lastActiveVariant(id: made.variant.id)) {
                try ops.archiveVariant(made.variant.id)
            }
            // An archived spare doesn't help — the guard counts ACTIVE ones.
            // Re-point the slot at the spare first (then archive it; an
            // archived chosen variant legally falls back at read time), so
            // the refusal below is the I10 guard, not the chosen guard.
            let blank = try ops.newBlankVariant(made.block.id)
            try ops.chooseVariant(made.block.id, variantID: blank.id)
            try ops.archiveVariant(blank.id)
            #expect(throws: OperationError.lastActiveVariant(id: made.variant.id)) {
                try ops.deleteVariant(made.variant.id)
            }
        }
    }

    @Test func deleteVariantDemandsRePointingFirstThenTombstones() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "shown")
            let branch = try ops.branchVariant(made.block.id, from: made.variant.id)

            // The slot still shows it: the ops-layer guard is the live
            // enforcement (RESTRICT only guards physical purge).
            #expect(throws: OperationError.variantIsChosen(id: made.variant.id)) {
                try ops.deleteVariant(made.variant.id)
            }

            try ops.chooseVariant(made.block.id, variantID: branch.id)
            try ops.deleteVariant(made.variant.id)

            #expect(try db.deletedAt("variant", made.variant.id) != nil)
            let block = try db.read { db in try Block.fetchOne(db, key: made.block.id) }
            #expect(block?.defaultVariantId == branch.id)
            #expect(try db.outboxContains("variant", made.variant.id))
        }
    }

    @Test func deleteVariantRefusesALockedVariant() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "t")
            _ = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.lockVariant(made.variant.id)
            #expect(throws: OperationError.lockedVariant(id: made.variant.id)) {
                try ops.deleteVariant(made.variant.id)
            }
        }
    }

    // MARK: deleteBlock / restoreBlock

    @Test func deleteBlockRecordsTheTrayPointerAndTheChainCascades() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "doomed")
            let branch = try ops.branchVariant(made.block.id, from: made.variant.id)
            try db.clearOutbox()

            try ops.deleteBlock(made.block.id)

            let block = try db.read { db in try Block.fetchOne(db, key: made.block.id) }
            #expect(block?.lastContainerId == post.id)
            let stamp = try db.deletedAt("block", made.block.id)
            #expect(stamp != nil)
            // Trigger cascade, not op writes: children share the exact stamp.
            for (table, id) in [
                ("variant", made.variant.id), ("variant", branch.id),
                ("container_block", made.placement.id),
            ] {
                #expect(try db.deletedAt(table, id) == stamp, "\(table) \(id)")
                #expect(try db.outboxContains(table, id), "\(table) \(id) missing from outbox")
            }
        }
    }

    // MARK: deleteBlock's transactional precondition (13c Stage 1 ladder, R3-1)
    //
    // The A7 seam-backspace carve is authorized ONLY on "there is no text to
    // lose". Three ladder rounds found three ways that could stop being true
    // while the gesture still fired — an archived take (R1-1), a block
    // comment (R2-1), and then the one that ended the pattern: the guards
    // were reading the editor's PROJECTION, which is deliberately frozen
    // while the buffer is dirty (R3-1). A guard list read from a frozen array
    // is exactly as stale as the array, so the authorization moved HERE,
    // inside the same transaction as the tombstone, where it cannot be a
    // snapshot. These pins are that precondition's own.

    @Test func theEmptyBlockPreconditionDeletesACleanEmptyBlock() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            _ = try ops.newBlock(in: post.id, text: "keeper")
            let made = try ops.newBlock(in: post.id, text: "")

            try ops.deleteBlock(
                made.block.id, requiring: .emptyWithNothingUnshown(variantID: made.variant.id))

            #expect(try db.deletedAt("block", made.block.id) != nil)
        }
    }

    @Test func theEmptyBlockPreconditionRefusesALiveCOMMENT() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "")
            _ = try ops.addBlockComment(to: made.block.id, text: "I'll rewrite this")

            #expect(throws: OperationError.blockCarriesUnshownText(id: made.block.id)) {
                try ops.deleteBlock(
                    made.block.id, requiring: .emptyWithNothingUnshown(variantID: made.variant.id))
            }
            #expect(try db.deletedAt("block", made.block.id) == nil, "nothing was tombstoned")
        }
    }

    @Test func theEmptyBlockPreconditionRefusesAnARCHIVEDTakeAndAFan() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "prose")
            let branch = try ops.branchVariant(made.block.id, from: made.variant.id)
            // A FAN, first: two live active takes.
            try ops.autosave(branch.id, text: "", charDelta: -5)
            #expect(throws: OperationError.blockCarriesUnshownText(id: made.block.id)) {
                try ops.deleteBlock(
                    made.block.id, requiring: .emptyWithNothingUnshown(variantID: branch.id))
            }
            // …and archiving the one holding the prose does NOT make it safe:
            // archive is out of the fan, not gone, and the cascade takes it.
            try ops.archiveVariant(made.variant.id)
            #expect(throws: OperationError.blockCarriesUnshownText(id: made.block.id)) {
                try ops.deleteBlock(
                    made.block.id, requiring: .emptyWithNothingUnshown(variantID: branch.id))
            }
            #expect(try db.deletedAt("block", made.block.id) == nil)
        }
    }

    @Test func theEmptyBlockPreconditionRefusesTextThatArrivedSinceTheGesture() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "")
            // The sync-apply shape: text lands between the keystroke and the
            // write. This is the compare-and-set the carve was always
            // documented to make — and now genuinely makes, in ONE
            // transaction with the tombstone (R3-3).
            try ops.autosave(made.variant.id, text: "landed from another device", charDelta: 26)

            #expect(throws: OperationError.bufferChangedSinceGesture(variantID: made.variant.id)) {
                try ops.deleteBlock(
                    made.block.id, requiring: .emptyWithNothingUnshown(variantID: made.variant.id))
            }
            #expect(try db.deletedAt("block", made.block.id) == nil)
        }
    }

    @Test func theOrdinaryDeleteDoorIsUnaffectedByThePrecondition() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "words, takes and notes")
            _ = try ops.branchVariant(made.block.id, from: made.variant.id)
            _ = try ops.addBlockComment(to: made.block.id, text: "a note")

            // `.none` is the default and the general door's contract: the
            // author asked for an unrestricted delete (QUESTIONS #33(a)),
            // and the block is undoable, redoable and tray-recoverable.
            try ops.deleteBlock(made.block.id)
            #expect(try db.deletedAt("block", made.block.id) != nil)
        }
    }

    /// The REDO half of the same authorization, and it is a real window: a
    /// comment written between the undo and the redo is not a structural
    /// act, so it never cleared the redo future — and a redo lands a
    /// tombstone exactly as the first delete did.
    @Test func aRedoneEmptyBlockDeletionReChecksThePreconditionToo() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            _ = try ops.newBlock(in: post.id, text: "keeper")
            let made = try ops.newBlock(in: post.id, text: "")

            try ops.deleteBlock(
                made.block.id, requiring: .emptyWithNothingUnshown(variantID: made.variant.id))
            _ = try stack.undo(with: ops)
            #expect(try db.deletedAt("block", made.block.id) == nil)

            // She writes a note on the restored block, then redoes.
            _ = try ops.addBlockComment(to: made.block.id, text: "second thoughts")
            #expect(throws: OperationError.blockCarriesUnshownText(id: made.block.id)) {
                _ = try stack.redo(with: ops)
            }
            #expect(try db.deletedAt("block", made.block.id) == nil,
                    "the redo refused rather than cascading the note away")
            #expect(stack.redoDepth == 1, "…and a resolvable refusal keeps its entry for retry")
        }
    }

    @Test func deleteBlockRefusedUnderALockedPost() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "sealed in")
            try ops.lockPost(post.id)
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.deleteBlock(made.block.id)
            }
        }
    }

    @Test func restoreBlockResurrectsCascadeVictimsButNotIndependentDeletes() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "phoenix")
            let branch = try ops.branchVariant(made.block.id, from: made.variant.id)
            let spare = try ops.branchVariant(made.block.id, from: made.variant.id)
            let other = try ops.newBlock(in: post.id, text: "witness")
            try db.write { db in
                try Fixture.edge(db, id: "e1", source: made.block.id, target: other.block.id)
            }

            // Independently deleted BEFORE the block: its own, earlier stamp.
            try ops.deleteVariant(spare.id)
            let spareStamp = try db.deletedAt("variant", spare.id)

            try ops.deleteBlock(made.block.id)
            try ops.restoreBlock(made.block.id)

            // Block and cascade victims live again…
            #expect(try db.deletedAt("block", made.block.id) == nil)
            #expect(try db.deletedAt("variant", made.variant.id) == nil)
            #expect(try db.deletedAt("variant", branch.id) == nil)
            #expect(try db.deletedAt("edge", "e1") == nil)
            // …the independently-deleted variant stays dead, stamp intact…
            #expect(try db.deletedAt("variant", spare.id) == spareStamp)
            // …and the OLD placement row comes back live.
            //
            // **A RULED CHANGE, not a bug fix (13j batch 3 — the architect's
            // F2 ruling; PROVISIONAL, her ratify at QUESTIONS #67 F2).** This
            // arm used to assert the opposite — the row stayed tombstoned and
            // a FRESH placement landed at the end — which meant Put back and
            // ⌥⌘Z, the two doors onto one gesture, put a block in two
            // different places. The op now flips the row this deletion took
            // down, exactly as `revertDeleteBlock` and the rest of the restore
            // family do; the fresh-at-end road survives as the fallback and is
            // pinned in `RecoveryOpsTests`.
            #expect(try db.deletedAt("container_block", made.placement.id) == nil)
            #expect(try blockOrder(db, post.id) == [made.block.id, other.block.id],
                    "back in its own place, ahead of the witness")
            let placement = try db.read { db in
                try ContainerBlock
                    .filter(Column("block_id") == made.block.id && Column("deleted_at") == nil)
                    .fetchOne(db)
            }
            #expect(placement?.id == made.placement.id, "the SAME row, revived")
            #expect(placement?.chosenVariantId == made.variant.id,
                    "the chosen variant rides the row back with it")
        }
    }

    @Test func restoreBlockLeavesTheBlockUnplacedWhenItsContainerDied() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "orphan")
            try ops.deleteBlock(made.block.id)
            try ops.deleteContainer(post.id)

            try ops.restoreBlock(made.block.id)

            #expect(try db.deletedAt("block", made.block.id) == nil)
            #expect(try db.fetchInt(
                """
                SELECT COUNT(*) FROM container_block
                WHERE block_id = ? AND deleted_at IS NULL
                """, [made.block.id]) == 0)
        }
    }

    @Test func restoreBlockLeavesTagApplicationsOfDeadTagsDead() throws {
        // Review finding 2026-07-05 (same class as the undo bugs): a tag
        // deleted AFTER the block leaves the application carrying the
        // block's stamp; a stamp-only flip would resurrect it under a dead
        // tag.
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "b")
            let tag = try ops.createTag(name: "t")
            let application = try ops.applyTag(tag.id, toBlock: made.block.id)
            try ops.deleteBlock(made.block.id)
            try ops.deleteTag(tag.id)

            try ops.restoreBlock(made.block.id)

            #expect(try db.deletedAt("block", made.block.id) == nil)
            #expect(try db.deletedAt("block_tag", application.id) != nil)
        }
    }

    @Test func restoreBlockGuards() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "alive")
            #expect(throws: OperationError.blockNotDeleted(id: made.block.id)) {
                try ops.restoreBlock(made.block.id)
            }
            #expect(throws: OperationError.blockNotFound(id: "ghost")) {
                try ops.restoreBlock("ghost")
            }
        }
    }

    // MARK: chooseVariant

    @Test func chooseVariantGuards() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "a")
            let otherBlock = try ops.newBlock(in: post.id, text: "b")

            // A variant of a different block never qualifies.
            #expect(throws: OperationError.variantNotFound(id: otherBlock.variant.id)) {
                try ops.chooseVariant(made.block.id, variantID: otherBlock.variant.id)
            }
            // An archived variant is not in the fan.
            let branch = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.archiveVariant(branch.id)
            #expect(throws: OperationError.archivedVariant(id: branch.id)) {
                try ops.chooseVariant(made.block.id, variantID: branch.id)
            }
            // Chosen variants are frozen under a locked post.
            try ops.unarchiveVariant(branch.id)
            try ops.lockPost(post.id)
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.chooseVariant(made.block.id, variantID: branch.id)
            }
        }
    }

    // MARK: placeBlock / moveBlock / reorder

    @Test func placeBlockPlacesOnlyUnplacedBlocks() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "released")
            #expect(throws: OperationError.blockAlreadyPlaced(id: made.block.id)) {
                try ops.placeBlock(made.block.id, in: post.id)
            }

            // Release the placement (as divide-W will), then re-place.
            try db.write { db in
                try Fixture.tombstone(db, table: "container_block", id: made.placement.id)
            }
            let placement = try ops.placeBlock(made.block.id, in: post.id)
            #expect(placement.chosenVariantId == nil)
            #expect(try blockOrder(db, post.id) == [made.block.id])
        }
    }

    @Test func moveBlockKeepsSingleOwnershipAcrossContainers() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let pool = try ops.createPool()
            let made = try ops.newBlock(in: post.id, text: "wandering")
            let poolResident = try ops.newBlock(in: pool.id, text: "resident")

            try ops.moveBlock(made.block.id, to: pool.id, at: .before(poolResident.block.id))

            #expect(try blockOrder(db, post.id) == [])
            #expect(try blockOrder(db, pool.id) == [made.block.id, poolResident.block.id])
            // I2: exactly one live placement, ever.
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                [made.block.id]) == 1)
        }
    }

    @Test func moveBlockRefusals() throws {
        try withOperations { ops, db in
            let source = try ops.createPost()
            let target = try ops.createPost()
            let made = try ops.newBlock(in: source.id, text: "stuck")

            try ops.lockPost(source.id)
            #expect(throws: OperationError.lockedPost(id: source.id)) {
                try ops.moveBlock(made.block.id, to: target.id)
            }
            try ops.unlockPost(source.id)
            try ops.lockPost(target.id)
            #expect(throws: OperationError.lockedPost(id: target.id)) {
                try ops.moveBlock(made.block.id, to: target.id)
            }

            // An unplaced block moves nowhere — placeBlock is the op for it.
            try ops.unlockPost(target.id)
            try db.write { db in
                try Fixture.tombstone(db, table: "container_block", id: made.placement.id)
            }
            #expect(throws: OperationError.blockNotPlaced(id: made.block.id)) {
                try ops.moveBlock(made.block.id, to: target.id)
            }
        }
    }

    @Test func reorderMovesWithinTheContainerAndOrderStaysSane() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let blocks = try (0..<4).map { try ops.newBlock(in: post.id, text: "\($0)") }
            let ids = blocks.map(\.block.id)

            try ops.reorder(ids[3], to: .start)
            #expect(try blockOrder(db, post.id) == [ids[3], ids[0], ids[1], ids[2]])

            try ops.reorder(ids[0], to: .after(ids[1]))
            #expect(try blockOrder(db, post.id) == [ids[3], ids[1], ids[0], ids[2]])

            try ops.reorder(ids[3], to: .before(ids[2]))
            #expect(try blockOrder(db, post.id) == [ids[1], ids[0], ids[3], ids[2]])

            try ops.lockPost(post.id)
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.reorder(ids[0], to: .end)
            }
        }
    }
}
