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
            let a = try ops.seedBlock(in: post.id, text: "First half. Second half.")

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
            let b = try ops.seedBlock(in: post.id, text: "left")
            let c = try ops.seedBlock(in: post.id, text: "right")

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
            let a = try ops.seedBlock(in: post.id, text: "One here. Two here.")
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
            let made = try ops.seedBlock(in: post.id, text: "original")

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
            _ = try ops.seedBlock(in: post.id, text: "keeper")
            let victim = try ops.seedBlock(in: post.id, text: "victim")

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
            let blocks = try (0..<3).map { try ops.seedBlock(in: post.id, text: "\($0)") }

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
            let made = try ops.seedBlock(in: post.id, text: "wanderer")
            _ = try ops.seedBlock(in: post.id, text: "neighbor")

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
            _ = try ops.seedBlock(in: post.id, text: "one")
            _ = try ops.seedBlock(in: post.id, text: "two")

            let copy = try ops.duplicateAsVersion(post.id)
            let copiedBlocks = try liveBlockOrder(db, in: copy.post.id)
            #expect(copiedBlocks.count == 2)

            try stack.undo(with: ops)
            #expect(try db.deletedAt("container", copy.post.id) != nil)

            // VX-372 (P-C-1 — JUSTIFIED EDIT): the label is the door's verb now.
            #expect(try stack.redo(with: ops) == "Duplicate with Tags")
            #expect(try db.deletedAt("container", copy.post.id) == nil)
            #expect(try liveBlockOrder(db, in: copy.post.id) == copiedBlocks)
        }
    }

    @Test func redoingAnAdoptPutsTheAdoptedPointersBack() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let made = try ops.seedBlock(in: post.id, text: "chosen")
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
            let a = try ops.seedBlock(in: post.id, text: "one")
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
            let a = try ops.seedBlock(in: post.id, text: "one")
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
            let a = try ops.seedBlock(in: post.id, text: "First half. Second half.")
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
            _ = try ops.seedBlock(in: post.id, text: "keeper")
            let victim = try ops.seedBlock(in: post.id, text: "victim")

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
            let a = try ops.seedBlock(in: post.id, text: "First half. Second half.")
            let b = try ops.seedBlock(in: post.id, text: "another")

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
            let a = try ops.seedBlock(in: post.id, text: "First half. Second half.")
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
            let made = try ops.seedBlock(in: post.id, text: "x")
            _ = try ops.seedBlock(in: post.id, text: "y")
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
            let a = try ops.seedBlock(in: post.id, text: "First half. Second half.")
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
        // The vehicle is a tombstone arriving BELOW the operations layer
        // (a sync apply's shape): it registers nothing and clears no redo
        // future, so the entry is still there to be found obsolete.
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            _ = try ops.seedBlock(in: post.id, text: "keeper")
            let victim = try ops.seedBlock(in: post.id, text: "x")

            try ops.deleteBlock(victim.block.id)
            try stack.undo(with: ops)
            #expect(stack.redoDepth == 1)

            // The world moves past the entry BELOW the operations layer —
            // which is what a sync apply is: a remote tombstone arrives,
            // registers no undo entry and clears no redo future. (This used
            // to be driven with `deleteContainer`, on the strength of its
            // leaving the redo future alone; 17b P6 made that a defect and
            // the door now clears the future, so the vehicle moved to the
            // one road that genuinely does neither.)
            try db.write { database in
                try database.execute(
                    sql: "UPDATE block SET deleted_at = ?, updated_at = ? WHERE id = ?",
                    arguments: ["2026-01-01T00:00:00.000Z", "2026-01-01T00:00:00.000Z",
                                victim.block.id])
            }
            #expect(stack.redoDepth == 1, "a write below the ops layer leaves the redo future alone")
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
            let a = try ops.seedBlock(in: post.id, text: "First half. Second half.")
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
            let a = try ops.seedBlock(
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

// MARK: - 17b P6 (RUN A, batch A1) — content-replacing acts clear the future too

/// **RED ON OLD — a content-replacing act that registers NOTHING used to
/// leave the redo future standing.** AppSpec §9 canonises the rule without
/// qualification (*"any new structural act clears the redo future"*), and
/// until this batch the ONLY thing that cleared it was `UndoStack.register`
/// — so the two acts that replace or remove a note's whole content while
/// deliberately registering no entry (the recovery-door class:
/// `restoreNoteVersion`, `deleteContainer`) left an abandoned timeline
/// re-appliable.
///
/// Both flavours are pinned because they fail differently:
/// **(1)** a redo whose re-apply is a bare tombstone flip SUCCEEDS, silently
/// resurrecting a block from the timeline she replaced into the restored
/// note; **(2)** a redo whose re-apply restores a buffer pre-image REFUSES
/// (`variantNotFound` — the restore's Delete Now road cascade-tombstoned the
/// take), and because redo is strictly LIFO and the entry stays on the stack
/// for retry, every entry beneath it is unreachable for the rest of the
/// session, with no user door able to resolve it.
///
/// DISCRIMINATING REVERT (verified): remove the `undoStack?.clearRedoFuture()`
/// calls from `restoreNoteVersion` and `deleteContainer` — the resurrection
/// test's block comes back and the wedge test's `redoDepth` stays 1.
@Suite("A content replacement clears the redo future (17b P6)")
struct ContentReplacementRedoTests {
    /// (1) THE SILENT RESURRECTION — merge → undo → restore a version → redo.
    @Test func restoringAVersionMakesTheAbandonedRedoUnreachable() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let note = try ops.createPost(title: "the note")
            let a = try ops.seedBlock(in: note.id, text: "Alpha.")
            let b = try ops.seedBlock(in: note.id, text: "Beta.")

            // A moment to come back to, taken BEFORE the structural act.
            let version = try ops.saveNoteVersion(note.id).post

            let merged = try ops.merge(a.block.id, b.block.id)
            try stack.undo(with: ops)
            #expect(stack.redoDepth == 1, "the merge is sitting in the abandoned future")

            let restore = try ops.restoreNoteVersion(note.id, from: version.id)
            #expect(restore.blocksRestored == 2)

            #expect(stack.redoDepth == 0,
                    "a whole-note content replacement IS a new structural act (AppSpec §9)")
            #expect(try stack.redo(with: ops) == nil, "there is nothing to re-apply")
            #expect(try db.deletedAt("block", merged.block.id) != nil,
                    "the merged block stays where the undo left it — never resurrected into the restored note")

            let order = try liveBlockOrder(db, in: note.id)
            #expect(order.count == 2, "the restored note holds exactly the version's two blocks")
            #expect(!order.contains(merged.block.id))
            let text = try db.read { try Queries.renderedText($0, containerID: note.id) }
            #expect(text == "Alpha.\n\nBeta.", "the two blocks the version held, and only those")
        }
    }

    /// (2) THE WEDGE — divide → undo → restore a version → redo. The
    /// re-apply's `restoringTexts` names a take the restore tombstoned, so
    /// the whole transaction rolls back and the entry sticks: LIFO means
    /// everything beneath it is unreachable for the session.
    @Test func restoringAVersionNeverWedgesTheSessionsRedoStack() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let note = try ops.createPost(title: "the note")
            let a = try ops.seedBlock(in: note.id, text: "First half. Second half.")

            let version = try ops.saveNoteVersion(note.id).post

            // The divide is registered FIRST and undone LAST, so its
            // re-apply is the one on TOP of the redo stack — and the
            // unrelated act beneath it is what the wedge buries (redo is
            // strictly LIFO, and a REFUSED re-apply stays for retry).
            _ = try ops.divide(a.block.id, cut: 13)
            let other = try ops.createPost(title: "another note")
            let c = try ops.seedBlock(in: other.id, text: "Elsewhere.")
            try ops.deleteBlock(c.block.id)
            try stack.undo(with: ops)  // the delete
            try stack.undo(with: ops)  // the divide, now on top of the future
            #expect(stack.redoDepth == 2)
            #expect(try db.deletedAt("block", c.block.id) == nil, "its undo really ran")

            _ = try ops.restoreNoteVersion(note.id, from: version.id)

            #expect(stack.redoDepth == 0, "the forked future is gone, not stuck")
            #expect(try stack.redo(with: ops) == nil,
                    "and no refusal can pin an unreachable entry on top of the stack")
            #expect(try db.deletedAt("block", c.block.id) == nil,
                    "the buried entry stayed undone — nothing was re-applied behind her back")
        }
    }

    /// `deleteContainer` is the same root with the milder outcome (a live
    /// unplaced block inside a tombstoned note), and it is reached by five
    /// doors — so the clearing lives in the operation, exactly as the
    /// version-ride rule does.
    @Test func deletingANoteClearsTheRedoFutureToo() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let note = try ops.createPost(title: "the note")
            let a = try ops.seedBlock(in: note.id, text: "First half. Second half.")

            let divided = try ops.divide(a.block.id, cut: 13)
            try stack.undo(with: ops)
            #expect(stack.redoDepth == 1)

            try ops.deleteContainer(note.id)

            #expect(stack.redoDepth == 0)
            #expect(try stack.redo(with: ops) == nil)
            #expect(try db.deletedAt("block", divided.block.id) != nil,
                    "the divide's minted block is not revived inside a tombstoned note")
        }
    }


    /// **THE RESIDUE, PINNED AS DOCUMENTED BEHAVIOUR — not fixed here, and
    /// said out loud rather than left to be rediscovered.** The canon rule
    /// (AppSpec §9) names the redo FUTURE, and that is what this batch
    /// closed. The UNDO side has the same shape and is deliberately left
    /// standing: an entry registered BEFORE one of these acts can still
    /// revive a block from the replaced timeline into the restored note (a
    /// bare tombstone flip), or refuse on a take the act tombstoned (the
    /// standing failed-inverse behaviour, which is visible and retryable).
    ///
    /// Why not "clear both stacks": this stack is SESSION-WIDE and holds
    /// acts on every note, so a restore of one note would silently take her
    /// undo history for all the others — a bigger loss than the one it
    /// prevents, and not something canon asks for. The real answer is
    /// note-scoped entries, which is a design (entries are opaque closures
    /// today), not a line. Owner + the author's call: the batch record.
    ///
    /// A later change that makes this right will turn this pin red, which
    /// is exactly the point of writing it down.
    @Test func anUndoEntryOlderThanARestoreCanStillReviveIntoTheRestoredNote() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let note = try ops.createPost(title: "the note")
            let x = try ops.seedBlock(in: note.id, text: "Alpha.")
            _ = try ops.seedBlock(in: note.id, text: "Beta.")
            let version = try ops.saveNoteVersion(note.id).post

            try ops.deleteBlock(x.block.id)
            _ = try ops.restoreNoteVersion(note.id, from: version.id)
            #expect(try liveBlockOrder(db, in: note.id).count == 2,
                    "the restore put the version's two blocks back, and only those")

            try stack.undo(with: ops)  // the delete, registered before the restore

            let after = try liveBlockOrder(db, in: note.id)
            #expect(after.count == 3, "DOCUMENTED: the older entry's inverse revives into the restored note")
            #expect(after.contains(x.block.id),
                    "and the revived block is the one the replaced timeline held")
        }
    }

    /// The guard: clearing the FUTURE is all it does. Her undo history is
    /// untouched — the canon rule names the redo stack and nothing else, and
    /// wiping a session-wide undo stack because one note was restored would
    /// take acts on other notes with it.
    @Test func clearingTheFutureNeverTouchesHerUndoHistory() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let other = try ops.createPost(title: "another note")
            let c = try ops.seedBlock(in: other.id, text: "Elsewhere.")
            try ops.deleteBlock(c.block.id)

            let note = try ops.createPost(title: "the note")
            _ = try ops.seedBlock(in: note.id, text: "Prose.")
            let version = try ops.saveNoteVersion(note.id).post
            let depthBefore = stack.depth
            _ = try ops.restoreNoteVersion(note.id, from: version.id)

            #expect(stack.depth == depthBefore, "not one undo entry was taken")
            try stack.undo(with: ops)  // the version save
            try stack.undo(with: ops)  // the unrelated delete, still there
            #expect(try db.deletedAt("block", c.block.id) == nil,
                    "an act on ANOTHER note is still undoable after a restore")
        }
    }
}
