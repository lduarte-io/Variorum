import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13c, batch 1B — STRUCTURAL REDO (author item A10, verbatim:
/// "i desperately need a 'redo' command to be able to undo my structural
/// undos for when that was an accident").
///
/// Red-on-old is STRUCTURAL for this suite: `UndoStack.redo` did not exist
/// before this batch (verified by the architect: no `redo`/`redoStack`/
/// `canRedo` anywhere in core or the app), so every test here fails to
/// compile against the pre-fix tree. What the suite pins is the CONTRACT:
///
/// - do → undo → redo returns the store to the post-do rows EXACTLY (IDs
///   included) — the re-applies are exact-row like the inverses, never a
///   re-run of the forward operation;
/// - undo↔redo ping-pongs without drift;
/// - any new structural act clears the redo future;
/// - redo emits ordinary operations (outbox rows), so sync never learns it
///   exists — the same reason undo is invisible to sync;
/// - a refused redo stays on the redo stack for retry, and an obsolete one
///   pops quietly instead of wedging.
@Suite("Structural redo (13c 1B — A10)")
struct RedoStackTests {
    // MARK: - do → undo → redo is exact

    @Test func redoingADivideRestoresTheMintedBlockItselfNotACopy() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "First half. Second half.")

            let divided = try ops.divide(a.block.id, cut: 13)
            let watched: [(String, String)] = [
                ("block", divided.block.id), ("variant", divided.variant.id),
                ("container_block", divided.placement.id), ("edge", divided.edge.id),
                ("variant", a.variant.id),
            ]
            let afterDo = try snapshot(db, rows: watched)

            #expect(try stack.undo(with: ops) == "Divide")
            #expect(stack.depth == 0)
            #expect(stack.redoDepth == 1)
            #expect(stack.topRedoLabel == "Divide")
            #expect(try liveBlockOrder(db, in: post.id) == [a.block.id])

            #expect(try stack.redo(with: ops) == "Divide")
            // The SAME block came back — a re-run of `divide` would have
            // minted a fresh UUID and stranded the inverse's pre-images.
            #expect(try liveBlockOrder(db, in: post.id) == [a.block.id, divided.block.id])
            #expect(try snapshot(db, rows: watched) == afterDo)
            // And the entry moved back: undo is available again, redo isn't.
            #expect(stack.depth == 1)
            #expect(stack.topLabel == "Divide")
            #expect(stack.redoDepth == 0)
        }
    }

    @Test func redoingAMergeReleasesTheSourcesAgainAndRevivesTheSameMergedBlock() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let b = try ops.newBlock(in: post.id, text: "left")
            let c = try ops.newBlock(in: post.id, text: "right")

            let merged = try ops.merge(b.block.id, c.block.id)
            let live: [(String, String)] = [
                ("block", merged.block.id), ("variant", merged.variant.id),
                ("container_block", merged.placement.id),
            ]
            let released: [(String, String)] = [
                ("container_block", b.placement.id), ("container_block", c.placement.id),
            ]
            let afterDo = try snapshot(db, rows: live)
            // The released rows compare minus `deleted_at`: re-releasing
            // writes a FRESH stamp, and that is correct — nothing keys off a
            // released placement's stamp (the revive is by row id; the
            // restoreBlock/restoreContainer cascade lookups key off the
            // BLOCK's and CONTAINER's stamps, which a released placement
            // never carried). Everything else must be byte-identical.
            let releasedAfterDo = try snapshot(db, rows: released, excluding: ["updated_at", "deleted_at"])

            try stack.undo(with: ops)
            #expect(try liveBlockOrder(db, in: post.id) == [b.block.id, c.block.id])

            #expect(try stack.redo(with: ops) == "Merge")
            #expect(try liveBlockOrder(db, in: post.id) == [merged.block.id])
            #expect(try snapshot(db, rows: live) == afterDo)
            #expect(try snapshot(db, rows: released, excluding: ["updated_at", "deleted_at"])
                == releasedAfterDo)
            #expect(try db.deletedAt("container_block", b.placement.id) != nil)
            #expect(try db.deletedAt("container_block", c.placement.id) != nil)
            // The sources stay ALIVE in lineage, exactly as the merge left
            // them — released, never destroyed.
            #expect(try db.deletedAt("block", b.block.id) == nil)
            #expect(try db.deletedAt("block", c.block.id) == nil)
        }
    }

    @Test func redoingAWDivideRestoresBothHalvesAndReleasesTheSourceAgain() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "One here. Two here.")
            let second = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.autosave(second.id, text: "Alt one. Alt two.", charDelta: 4)

            let w = try ops.divideW(
                a.block.id,
                cuts: [a.variant.id: 9, second.id: 8])
            let expected = try liveBlockOrder(db, in: post.id)
            #expect(expected == [w.first.block.id, w.second.block.id])

            try stack.undo(with: ops)
            #expect(try liveBlockOrder(db, in: post.id) == [a.block.id])

            #expect(try stack.redo(with: ops) == "Divide choosing takes")
            #expect(try liveBlockOrder(db, in: post.id) == expected)
            // The whole fan came back with the block — the cascade victims
            // carry the stamp the inverse wrote, so the flip finds them.
            for variant in w.first.variants + w.second.variants {
                #expect(try db.deletedAt("variant", variant.id) == nil)
            }
            // A is released to lineage again (live block, no placement).
            #expect(try db.deletedAt("block", a.block.id) == nil)
            #expect(try db.deletedAt("container_block", a.placement.id) != nil)
        }
    }

    @Test func redoingATextEditPutsThePostEditTextBack() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "original")

            _ = try ops.editTakesAtomically(
                [.init(variantID: made.variant.id, newText: "edited", charDelta: 8)],
                undoLabel: "Delete in Every Take")

            try stack.undo(with: ops)
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [made.variant.id]) == "original")

            #expect(try stack.redo(with: ops) == "Delete in Every Take")
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [made.variant.id]) == "edited")
        }
    }

    @Test func redoingADeleteBlockTombstonesTheSameRowsAgain() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            _ = try ops.newBlock(in: post.id, text: "keeper")
            let victim = try ops.newBlock(in: post.id, text: "victim")

            try ops.deleteBlock(victim.block.id)
            try stack.undo(with: ops)
            #expect(try db.deletedAt("block", victim.block.id) == nil)

            #expect(try stack.redo(with: ops) == "Delete Block")
            #expect(try db.deletedAt("block", victim.block.id) != nil)
            // The cascade re-ran, so the block is tray-recoverable again.
            #expect(try db.deletedAt("variant", victim.variant.id) != nil)
            #expect(try db.fetchString(
                "SELECT last_container_id FROM block WHERE id = ?", [victim.block.id]) == post.id)
            #expect(try liveBlockOrder(db, in: post.id).count == 1)
        }
    }

    @Test func redoingAReorderRestoresTheExactLandedPositionString() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let blocks = try (0..<3).map { try ops.newBlock(in: post.id, text: "\($0)") }

            try ops.reorder(blocks[2].block.id, to: .start)
            let afterDo = try db.snapshotRow("container_block", blocks[2].placement.id)

            try stack.undo(with: ops)
            #expect(try stack.redo(with: ops) == "Reorder")
            // The exact landed key, not a fresh jittered derivation — a
            // re-derived position would drift on every ping-pong.
            #expect(try db.snapshotRow("container_block", blocks[2].placement.id) == afterDo)
            #expect(try liveBlockOrder(db, in: post.id).first == blocks[2].block.id)
        }
    }

    @Test func redoingAMoveBlockPutsItBackInTheTargetContainer() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let pool = try ops.createPool()
            let made = try ops.newBlock(in: post.id, text: "wanderer")
            _ = try ops.newBlock(in: post.id, text: "neighbor")

            try ops.moveBlock(made.block.id, to: pool.id)
            let afterDo = try db.snapshotRow("container_block", made.placement.id)

            try stack.undo(with: ops)
            #expect(try liveBlockOrder(db, in: pool.id).isEmpty)

            #expect(try stack.redo(with: ops) == "Move Block")
            #expect(try db.snapshotRow("container_block", made.placement.id) == afterDo)
            #expect(try liveBlockOrder(db, in: pool.id) == [made.block.id])
        }
    }

    @Test func redoingAPostMintBringsTheWholeCopyBack() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost(title: "source")
            _ = try ops.newBlock(in: post.id, text: "one")
            _ = try ops.newBlock(in: post.id, text: "two")

            let copy = try ops.duplicateAsVersion(post.id)
            let copiedBlocks = try liveBlockOrder(db, in: copy.post.id)
            #expect(copiedBlocks.count == 2)

            try stack.undo(with: ops)
            #expect(try db.deletedAt("container", copy.post.id) != nil)

            #expect(try stack.redo(with: ops) == "Duplicate as Version")
            #expect(try db.deletedAt("container", copy.post.id) == nil)
            #expect(try liveBlockOrder(db, in: copy.post.id) == copiedBlocks)
        }
    }

    @Test func redoingAnAdoptPutsTheAdoptedPointersBack() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "chosen")
            let other = try ops.branchVariant(made.block.id, from: made.variant.id)
            let lens = try ops.createLens(post: post.id, name: "alt")
            try ops.setLensChoice(lens: lens.id, block: made.block.id, variant: other.id)

            try ops.adoptLens(lens.id)
            #expect(try db.fetchString(
                "SELECT chosen_variant_id FROM container_block WHERE id = ?",
                [made.placement.id]) == other.id)

            try stack.undo(with: ops)
            #expect(try db.fetchString(
                "SELECT chosen_variant_id FROM container_block WHERE id = ?",
                [made.placement.id]) == made.variant.id)

            #expect(try stack.redo(with: ops) == "Adopt Lens")
            #expect(try db.fetchString(
                "SELECT chosen_variant_id FROM container_block WHERE id = ?",
                [made.placement.id]) == other.id)
        }
    }

    // MARK: - The variant-lifecycle re-applies (13c Stage 1 ladder, R1-7)

    /// `deleteVariant` and `archiveVariant` are the two re-applies with
    /// **bodies of their own** — `performDeleteVariant` /
    /// `performArchiveVariant` carry the I10 `ensureNotLastActive` guard,
    /// the locked-variant and chosen-variant guards, and
    /// `reassignDefaultIfNeeded`. Every other re-apply reuses a body an
    /// undo pin already exercises; these two were reachable by no redo test
    /// at all, so their guards ran only on the forward path.
    ///
    /// The sharp end of `deleteVariant`: delete the block's DEFAULT variant
    /// out of a three-take fan, so the re-apply must re-run
    /// `reassignDefaultIfNeeded` rather than merely re-stamp `deleted_at` —
    /// a default pointer left at a tombstoned row is the dangling-default
    /// state SyncSpec §7 has a repair for.
    @Test func redoingADeleteVariantReRunsItsGuardsAndTheDefaultReassignment() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "one")
            let second = try ops.branchVariant(a.block.id, from: a.variant.id)
            let third = try ops.branchVariant(a.block.id, from: a.variant.id)
            // The slot must not be pointing at the doomed take (the ops
            // layer's live chosen guard), so choose another first.
            try ops.chooseVariant(a.block.id, variantID: second.id)
            #expect(try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?", [a.block.id])
                == a.variant.id)

            try ops.deleteVariant(a.variant.id)
            let defaultAfterDo = try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?", [a.block.id])
            #expect(defaultAfterDo != a.variant.id, "the default moved off the tombstone")
            let afterDo = try snapshot(db, rows: [
                ("variant", a.variant.id), ("variant", second.id), ("variant", third.id),
                ("block", a.block.id),
            ])

            #expect(try stack.undo(with: ops) == "Delete Variant")
            #expect(try db.deletedAt("variant", a.variant.id) == nil)
            #expect(try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?", [a.block.id])
                == a.variant.id, "the pre-image default came back")

            #expect(try stack.redo(with: ops) == "Delete Variant")
            #expect(try db.deletedAt("variant", a.variant.id) != nil)
            #expect(try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?", [a.block.id])
                == defaultAfterDo, "…and the re-apply reassigned the default again")
            #expect(try snapshot(db, rows: [
                ("variant", a.variant.id), ("variant", second.id), ("variant", third.id),
                ("block", a.block.id),
            ], excluding: ["updated_at", "deleted_at"])
                == snapshotExcludingDeletedAt(afterDo),
                "every other column round-trips (a re-tombstone writes a fresh stamp)")
            #expect(stack.depth == 1 && stack.redoDepth == 0)
        }
    }

    /// `archiveVariant`'s twin, plus its own divergence rule: the re-apply
    /// is `quietWhenGone`, so an archive that is already true again pops
    /// quietly rather than wedging the entry beneath it.
    @Test func redoingAnArchiveVariantRestoresTheArchivedStateAndTheDefault() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "one")
            let second = try ops.branchVariant(a.block.id, from: a.variant.id)

            // Archiving the block's DEFAULT (and chosen — legal, unlike
            // delete: the read-time fallback covers it).
            try ops.archiveVariant(a.variant.id)
            let afterDo = try snapshot(db, rows: [
                ("variant", a.variant.id), ("variant", second.id), ("block", a.block.id),
            ])
            #expect(try db.fetchString(
                "SELECT status FROM variant WHERE id = ?", [a.variant.id]) == "archived")
            #expect(try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?", [a.block.id])
                == second.id)

            #expect(try stack.undo(with: ops) == "Archive Variant")
            #expect(try db.fetchString(
                "SELECT status FROM variant WHERE id = ?", [a.variant.id]) == "active")
            #expect(try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?", [a.block.id])
                == a.variant.id)

            #expect(try stack.redo(with: ops) == "Archive Variant")
            #expect(try snapshot(db, rows: [
                ("variant", a.variant.id), ("variant", second.id), ("block", a.block.id),
            ]) == afterDo, "exact-row: status, default pointer and all")

            // I10 stands on the redo path too: the archive's guard is inside
            // the shared body, so the LAST active variant can never be
            // archived by a re-apply either.
            try stack.undo(with: ops)
            try ops.archiveVariant(second.id)   // now a.variant is the last active
            #expect(throws: OperationError.lastActiveVariant(id: a.variant.id)) {
                try ops.archiveVariant(a.variant.id)
            }
        }
    }

    // MARK: - Stack semantics

    @Test func undoAndRedoPingPongWithoutDrift() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "First half. Second half.")
            let divided = try ops.divide(a.block.id, cut: 13)

            let watched: [(String, String)] = [
                ("block", divided.block.id), ("variant", divided.variant.id),
                ("container_block", divided.placement.id), ("variant", a.variant.id),
            ]
            let doneState = try snapshot(db, rows: watched)
            try stack.undo(with: ops)
            // The undone state compares minus `deleted_at`: each tombstone
            // carries the moment it was written, and that moves by design
            // (the pre-13c undo already re-stamps on every re-run). What
            // must NOT move is the tombstone's internal CONSISTENCY —
            // asserted below, because it is what keeps the block
            // tray-recoverable.
            let undoneState = try snapshot(db, rows: watched, excluding: ["updated_at", "deleted_at"])

            for round in 0..<3 {
                try stack.redo(with: ops)
                #expect(try snapshot(db, rows: watched) == doneState, "redo round \(round) drifted")
                try stack.undo(with: ops)
                #expect(try snapshot(db, rows: watched, excluding: ["updated_at", "deleted_at"])
                    == undoneState, "undo round \(round) drifted")
                // The cascade stamp contract, re-checked every round: the
                // block's tombstone and its cascade victims' share ONE
                // value, which is what `restoreBlock` and `revertDeleteBlock`
                // identify cascade victims by. A re-apply that flipped
                // children with a fresh stamp instead of the block's own
                // would break this on the FIRST redo→undo cycle.
                let stamp = try db.deletedAt("block", divided.block.id)
                #expect(stamp != nil)
                #expect(try db.deletedAt("variant", divided.variant.id) == stamp)
                #expect(try db.deletedAt("container_block", divided.placement.id) == stamp)
            }
        }
    }

    @Test func aRedoneThenUndoneBlockIsStillTrayRecoverable() throws {
        // The consequence of the stamp contract above, end to end: after a
        // redo→undo cycle the tray door still works, so redo can never
        // strand a block outside every recovery surface.
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            _ = try ops.newBlock(in: post.id, text: "keeper")
            let victim = try ops.newBlock(in: post.id, text: "victim")

            try ops.deleteBlock(victim.block.id)
            try stack.undo(with: ops)
            try stack.redo(with: ops)

            let tray = try db.read { db in try Queries.trayBlocks(db, postID: post.id, now: harnessNow) }
            #expect(tray.map(\.blockID) == [victim.block.id])
            #expect(tray.first?.text == "victim", "the preview reads through the re-stamped cascade")
            try ops.restoreBlock(victim.block.id)
            #expect(try db.deletedAt("variant", victim.variant.id) == nil)
            #expect(try liveBlockOrder(db, in: post.id).contains(victim.block.id))
        }
    }

    @Test func anyNewStructuralActClearsTheRedoFuture() throws {
        try withOperations { _, _ in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "First half. Second half.")
            let b = try ops.newBlock(in: post.id, text: "another")

            _ = try ops.divide(a.block.id, cut: 13)
            try stack.undo(with: ops)
            #expect(stack.redoDepth == 1)

            // The timeline forks: the abandoned future is gone.
            try ops.deleteBlock(b.block.id)
            #expect(stack.redoDepth == 0)
            #expect(try stack.redo(with: ops) == nil)
        }
    }

    @Test func neitherUndoNorRedoRegistersAnythingOfItsOwn() throws {
        // The re-applies and inverses are internal and never register — if
        // one ever did, it would clear the redo stack from under redo (and
        // double-count the undo stack). This is the arithmetic that proves
        // it: one entry, moving between two stacks, forever.
        try withOperations { _, _ in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "First half. Second half.")
            _ = try ops.divide(a.block.id, cut: 13)

            #expect(stack.depth == 1 && stack.redoDepth == 0)
            try stack.undo(with: ops)
            #expect(stack.depth == 0 && stack.redoDepth == 1)
            try stack.redo(with: ops)
            #expect(stack.depth == 1 && stack.redoDepth == 0)
            try stack.undo(with: ops)
            #expect(stack.depth == 0 && stack.redoDepth == 1)
        }
    }

    @Test func redoEmitsOutboxRowsLikeAnyOperation() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "x")
            _ = try ops.newBlock(in: post.id, text: "y")
            try ops.deleteBlock(made.block.id)
            try stack.undo(with: ops)
            try db.clearOutbox()

            try stack.redo(with: ops)

            // Sync sees ordinary writes — it never learns redo exists.
            for (table, id) in [
                ("block", made.block.id), ("variant", made.variant.id),
                ("container_block", made.placement.id),
            ] {
                #expect(try db.outboxContains(table, id), "\(table) \(id) missing from outbox")
            }
        }
    }

    @Test func aRefusedRedoStaysOnTheRedoStackForRetry() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "First half. Second half.")
            let divided = try ops.divide(a.block.id, cut: 13)
            try stack.undo(with: ops)

            // The post got sealed after the undo: the seal refuses
            // everything under it, redo included.
            try ops.lockPost(post.id)
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try stack.redo(with: ops)
            }
            #expect(stack.redoDepth == 1, "the entry survives for retry")
            #expect(try db.deletedAt("block", divided.block.id) != nil)

            try ops.unlockPost(post.id)
            #expect(try stack.redo(with: ops) == "Divide")
            #expect(stack.redoDepth == 0)
        }
    }

    @Test func anObsoleteRedoPopsQuietlyInsteadOfWedgingTheStack() throws {
        // The mirror of the stale-UNDO rule (`UndoStackTests`): the world
        // moved past the entry, so redo pops instead of throwing forever.
        // The door used here is `deleteContainer`, which is deliberately
        // NOT undo-registered (so it never clears the redo future) and
        // whose cascade takes the block down another way.
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            _ = try ops.newBlock(in: post.id, text: "keeper")
            let victim = try ops.newBlock(in: post.id, text: "x")

            try ops.deleteBlock(victim.block.id)
            try stack.undo(with: ops)
            #expect(stack.redoDepth == 1)

            try ops.deleteContainer(post.id)              // cascade kills the block
            #expect(stack.redoDepth == 1, "an unregistered op leaves the redo future alone")
            #expect(try db.deletedAt("block", victim.block.id) != nil)

            // Obsolete: the transition it wants is already true. It pops
            // quietly rather than throwing and wedging every entry beneath.
            #expect(try stack.redo(with: ops) == "Delete Block")
            #expect(stack.redoDepth == 0)
            #expect(try db.deletedAt("block", victim.block.id) != nil)
        }
    }

    @Test func removeAllClearsBothStacks() throws {
        try withOperations { _, _ in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "First half. Second half.")
            _ = try ops.divide(a.block.id, cut: 13)
            try stack.undo(with: ops)
            #expect(stack.redoDepth == 1)

            stack.removeAll()
            #expect(stack.depth == 0 && stack.redoDepth == 0)
            #expect(try stack.redo(with: ops) == nil)
        }
    }

    @Test func redoOnAnEmptyStackIsNil() throws {
        try withOperations { ops, _ in
            let stack = UndoStack()
            let redone = try stack.redo(with: ops)
            #expect(redone == nil)
            #expect(stack.topRedoLabel == nil)
        }
    }

    // MARK: - Compounds

    @Test func aCompoundRedoesAsOneEntryAndReAppliesEveryLeg() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.newBlock(
                in: post.id, text: "Intro clause. Middle stays here. Tail sentence.")

            let minted: (middle: String, suffix: String) = try stack.withCompound(
                label: "Make Block", operations: ops
            ) {
                let first = try ops.divide(a.block.id, cut: 14)
                let second = try ops.divide(first.block.id, cut: 19)
                return (first.block.id, second.block.id)
            }
            let afterDo = try liveBlockOrder(db, in: post.id)

            try stack.undo(with: ops)
            #expect(try liveBlockOrder(db, in: post.id) == [a.block.id])

            #expect(try stack.redo(with: ops) == "Make Block")
            #expect(stack.depth == 1 && stack.redoDepth == 0, "still ONE entry")
            #expect(try liveBlockOrder(db, in: post.id) == afterDo)
            #expect(try liveBlockOrder(db, in: post.id)
                == [a.block.id, minted.middle, minted.suffix])
        }
    }

    // MARK: - Helpers

    private func snapshot(
        _ db: AppDatabase, rows: [(String, String)],
        excluding: Set<String> = ["updated_at"]
    ) throws -> [String: [String: DatabaseValue]?] {
        var out: [String: [String: DatabaseValue]?] = [:]
        for (table, id) in rows {
            out["\(table)/\(id)"] = try db.snapshotRow(table, id, excluding: excluding)
        }
        return out
    }

    /// The same snapshot with `deleted_at` dropped, so a post-do image can
    /// be compared against a post-redo one: a row that dies AGAIN gets a
    /// fresh stamp, which is pre-existing undo behaviour and benign (nothing
    /// keys off a re-tombstoned variant's stamp — the merge pin's rationale).
    private func snapshotExcludingDeletedAt(
        _ snapshot: [String: [String: DatabaseValue]?]
    ) -> [String: [String: DatabaseValue]?] {
        snapshot.mapValues { row in
            row.map { columns in columns.filter { $0.key != "deleted_at" } }
        }
    }
}
