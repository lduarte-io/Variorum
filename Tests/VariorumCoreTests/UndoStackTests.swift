import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Structural undo core (Phase 2, Step 8)")
struct UndoStackTests {
    // MARK: Round trips (do → undo → exact rows, modulo updated_at/outbox)

    @Test func deleteBlockUndoRestoresEveryRowExactly() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)

            let post = try ops.createPost()
            let before = try ops.seedBlock(in: post.id, text: "before")
            let target = try ops.seedBlock(in: post.id, text: "the victim")
            let after = try ops.seedBlock(in: post.id, text: "after")
            let branch = try ops.branchVariant(target.block.id, from: target.variant.id)
            try ops.chooseVariant(target.block.id, variantID: branch.id)
            let tag = try ops.createTag(name: "kept")
            let blockTag = try ops.applyTag(tag.id, toBlock: target.block.id)
            try db.write { db in
                try Fixture.edge(db, id: "e1", source: target.block.id, target: before.block.id)
            }

            let watched: [(String, String)] = [
                ("block", target.block.id),
                ("variant", target.variant.id), ("variant", branch.id),
                ("container_block", target.placement.id),
                ("edge", "e1"), ("block_tag", blockTag.id),
            ]
            // last_container_id is a deleteBlock side-effect undo keeps.
            var snapshots: [String: [String: DatabaseValue]?] = [:]
            for (table, id) in watched {
                snapshots["\(table)/\(id)"] = try db.snapshotRow(
                    table, id, excluding: ["updated_at", "last_container_id"])
            }

            try ops.deleteBlock(target.block.id)
            #expect(stack.depth == 1)
            #expect(stack.topLabel == "Delete Block")

            try stack.undo(with: ops)

            for (table, id) in watched {
                let restored = try db.snapshotRow(
                    table, id, excluding: ["updated_at", "last_container_id"])
                #expect(restored == snapshots["\(table)/\(id)"], "\(table) \(id) not row-identical")
            }
            // The exact placement row came back — order and chosen intact.
            let order = try db.read { db in
                try String.fetchAll(
                    db,
                    sql: """
                        SELECT block_id FROM container_block
                        WHERE container_id = ? AND deleted_at IS NULL
                        ORDER BY position, id
                        """,
                    arguments: [post.id])
            }
            #expect(order == [before.block.id, target.block.id, after.block.id])
            #expect(stack.depth == 0)
        }
    }

    @Test func deleteVariantUndoRestoresTheDefaultPointer() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)

            let post = try ops.createPost()
            let made = try ops.seedBlock(in: post.id, text: "take one")
            let branch = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.chooseVariant(made.block.id, variantID: branch.id)

            let variantBefore = try db.snapshotRow("variant", made.variant.id)
            let blockBefore = try db.snapshotRow("block", made.block.id)

            try ops.deleteVariant(made.variant.id)
            // Default moved off the deleted variant…
            #expect(try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?", [made.block.id]) == branch.id)

            try stack.undo(with: ops)

            // …and undo put both the row and the pointer back.
            #expect(try db.snapshotRow("variant", made.variant.id) == variantBefore)
            #expect(try db.snapshotRow("block", made.block.id) == blockBefore)
        }
    }

    @Test func archiveVariantUndoRoundTrips() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)

            let post = try ops.createPost()
            let made = try ops.seedBlock(in: post.id, text: "take one")
            _ = try ops.branchVariant(made.block.id, from: made.variant.id)

            let variantBefore = try db.snapshotRow("variant", made.variant.id)
            let blockBefore = try db.snapshotRow("block", made.block.id)

            try ops.archiveVariant(made.variant.id)
            #expect(stack.topLabel == "Archive Variant")
            try stack.undo(with: ops)

            #expect(try db.snapshotRow("variant", made.variant.id) == variantBefore)
            #expect(try db.snapshotRow("block", made.block.id) == blockBefore)
        }
    }

    @Test func moveBlockUndoRestoresTheExactPriorLocation() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)

            let post = try ops.createPost()
            let pool = try ops.createPool()
            let made = try ops.seedBlock(in: post.id, text: "wanderer")
            _ = try ops.seedBlock(in: post.id, text: "neighbor")

            let placementBefore = try db.snapshotRow("container_block", made.placement.id)

            try ops.moveBlock(made.block.id, to: pool.id)
            try stack.undo(with: ops)

            #expect(try db.snapshotRow("container_block", made.placement.id) == placementBefore)
        }
    }

    @Test func reorderUndoRestoresTheExactPositionString() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)

            let post = try ops.createPost()
            let blocks = try (0..<3).map { try ops.seedBlock(in: post.id, text: "\($0)") }
            let placementBefore = try db.snapshotRow("container_block", blocks[2].placement.id)

            try ops.reorder(blocks[2].block.id, to: .start)
            try stack.undo(with: ops)

            #expect(try db.snapshotRow("container_block", blocks[2].placement.id) == placementBefore)
        }
    }

    // MARK: Stack semantics

    @Test func stackIsLIFO() throws {
        try withOperations { _, _ in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)

            let post = try ops.createPost()
            let pool = try ops.createPool()
            let made = try ops.seedBlock(in: post.id, text: "x")
            _ = try ops.seedBlock(in: post.id, text: "y")

            try ops.reorder(made.block.id, to: .end)
            try ops.moveBlock(made.block.id, to: pool.id)
            #expect(stack.depth == 2)

            #expect(try stack.undo(with: ops) == "Move Block")
            #expect(try stack.undo(with: ops) == "Reorder")
            #expect(try stack.undo(with: ops) == nil)
        }
    }

    @Test func unregisteredOperationsNeverTouchTheStack() throws {
        try withOperations { _, _ in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)

            // Text editing, commits, locks, tags, containers, readings — all
            // excluded from structural undo by design.
            let post = try ops.createPost(title: "t")
            let made = try ops.seedBlock(in: post.id, text: "text")
            try ops.autosave(made.variant.id, text: "text2", charDelta: 1)
            try ops.commit(made.variant.id)
            try ops.lockVariant(made.variant.id)
            try ops.unlockVariant(made.variant.id)
            let tag = try ops.createTag(name: "t")
            try ops.applyTag(tag.id, toPost: post.id)
            try ops.removeTag(tag.id, fromPost: post.id)
            let reading = try ops.createReading(name: "r", kind: .curated)
            try ops.addPostToReading(post.id, to: reading.id)
            try ops.renameContainer(post.id, title: "t2")

            #expect(stack.depth == 0)
        }
    }

    @Test func undoEmitsOutboxRowsLikeAnyOperation() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)

            let post = try ops.createPost()
            let made = try ops.seedBlock(in: post.id, text: "x")
            try ops.deleteBlock(made.block.id)
            try db.clearOutbox()

            try stack.undo(with: ops)

            // Sync sees ordinary writes: the flipped rows are all enqueued.
            for (table, id) in [
                ("block", made.block.id), ("variant", made.variant.id),
                ("container_block", made.placement.id),
            ] {
                #expect(try db.outboxContains(table, id), "\(table) \(id) missing from outbox")
            }
        }
    }

    @Test func aStaleDeleteBlockEntryPopsAsAQuietNoOpInsteadOfWedgingTheStack() throws {
        // Self-review finding 2026-07-05: deleteBlock → restoreBlock (tray)
        // makes the undo entry obsolete. It must pop cleanly — an
        // unresolvable refusal would block every undo beneath it forever.
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let earlier = try ops.seedBlock(in: post.id, text: "reachable again")
            try ops.reorder(earlier.block.id, to: .end) // an older entry beneath
            let made = try ops.seedBlock(in: post.id, text: "x")
            try ops.deleteBlock(made.block.id)
            try ops.restoreBlock(made.block.id)

            let snapshot = try db.snapshotRow("block", made.block.id)
            #expect(try stack.undo(with: ops) == "Delete Block")
            #expect(try db.snapshotRow("block", made.block.id) == snapshot)
            // The stack is not wedged: the older entry beneath still runs.
            #expect(try stack.undo(with: ops) == "Reorder")
        }
    }

    @Test func undoDeleteVariantRefusesWhenTheBlockHasSinceDied() throws {
        // Review finding 2026-07-05 (bug 1): deleteContainer is not undo-
        // registered, so LIFO can't order-protect this — the inverse itself
        // must check block liveness or it strands a live variant under a
        // dead block.
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let made = try ops.seedBlock(in: post.id, text: "v1")
            _ = try ops.branchVariant(made.block.id, from: made.variant.id)
            let spare = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.deleteVariant(spare.id)
            try ops.deleteContainer(post.id)

            #expect(throws: OperationError.blockNotFound(id: made.block.id)) {
                try stack.undo(with: ops)
            }
            #expect(stack.depth == 1)
            #expect(try db.fetchInt(
                """
                SELECT COUNT(*) FROM variant v JOIN block b ON b.id = v.block_id
                WHERE v.deleted_at IS NULL AND b.deleted_at IS NOT NULL
                """) == 0)

            // Restoring the post unblocks the retry.
            try ops.restoreContainer(post.id)
            #expect(try stack.undo(with: ops) == "Delete Variant")
        }
    }

    @Test func variantUndoInversesRespectThePostSeal() throws {
        // Review finding 2026-07-05 (bug 2): the seal refuses everything
        // under the post — including undo's revert operations.
        try withOperations { _, _ in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let made = try ops.seedBlock(in: post.id, text: "v1")
            let deleted = try ops.branchVariant(made.block.id, from: made.variant.id)
            let archived = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.deleteVariant(deleted.id)
            try ops.archiveVariant(archived.id)
            try ops.lockPost(post.id)

            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try stack.undo(with: ops) // archiveVariant's inverse
            }
            #expect(stack.depth == 2)

            try ops.unlockPost(post.id)
            #expect(try stack.undo(with: ops) == "Archive Variant")
            #expect(try stack.undo(with: ops) == "Delete Variant")
        }
    }

    @Test func aFailedUndoStaysOnTheStackForRetry() throws {
        try withOperations { _, _ in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)

            let post = try ops.createPost()
            let pool = try ops.createPool()
            let made = try ops.seedBlock(in: post.id, text: "x")
            try ops.moveBlock(made.block.id, to: pool.id)

            // The undo target (the source post) got sealed after the move.
            try ops.lockPost(post.id)
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try stack.undo(with: ops)
            }
            #expect(stack.depth == 1)

            // Resolve and retry.
            try ops.unlockPost(post.id)
            #expect(try stack.undo(with: ops) == "Move Block")
            #expect(stack.depth == 0)
        }
    }

    // MARK: Compound entries (Phase 9 — the composed Make Block gesture)

    @Test func compoundEntryRoundTripsAsOneUndo() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.seedBlock(in: post.id, text: "Intro clause. Middle stays here. Tail sentence.")
            let sourceBefore = try db.snapshotRow("variant", a.variant.id)

            // Two divides as ONE undoable action (the ratified contract).
            let minted: (middle: String, suffix: String) = try stack.withCompound(
                label: "Make Block", operations: ops
            ) {
                let first = try ops.divide(a.block.id, cut: 14)
                let second = try ops.divide(first.block.id, cut: 19)
                return (first.block.id, second.block.id)
            }

            #expect(stack.depth == 1, "two registrations folded into ONE entry")
            #expect(stack.topLabel == "Make Block")
            #expect(try liveBlockOrder(db, in: post.id)
                == [a.block.id, minted.middle, minted.suffix])

            // ONE undo un-applies both divides, newest first.
            #expect(try stack.undo(with: ops) == "Make Block")
            #expect(stack.depth == 0)
            #expect(try db.snapshotRow("variant", a.variant.id) == sourceBefore)
            #expect(try db.deletedAt("block", minted.middle) != nil)
            #expect(try db.deletedAt("block", minted.suffix) != nil)
            #expect(try liveBlockOrder(db, in: post.id) == [a.block.id])
        }
    }

    @Test func compoundPartialFailureRollsBackAtomically() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.seedBlock(in: post.id, text: "Intro clause. Middle stays here. Tail sentence.")
            let sourceBefore = try db.snapshotRow("variant", a.variant.id)

            // The second divide fails (cut 0 is invalid): the compound is
            // atomic — the first divide un-applies, the error rethrows.
            #expect(throws: (any Error).self) {
                try stack.withCompound(label: "Make Block", operations: ops) {
                    let first = try ops.divide(a.block.id, cut: 14)
                    _ = try ops.divide(first.block.id, cut: 0)
                }
            }

            #expect(stack.depth == 0, "nothing to undo — the action never happened")
            #expect(try db.snapshotRow("variant", a.variant.id) == sourceBefore)
            #expect(try liveBlockOrder(db, in: post.id) == [a.block.id])
        }
    }

    @Test func compoundRegistrationNotifiesTheObserverExactlyOnce() throws {
        try withOperations { _, _ in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.seedBlock(in: post.id, text: "Intro clause. Middle stays here. Tail sentence.")

            let fired = LockIsolated(0)
            stack.setChangeObserver { fired.withValue { $0 += 1 } }

            _ = try stack.withCompound(label: "Make Block", operations: ops) {
                let first = try ops.divide(a.block.id, cut: 14)
                _ = try ops.divide(first.block.id, cut: 19)
            }
            #expect(fired.value == 1, "sub-registrations are silent; the fold notifies once")
            #expect(stack.depth == 1)
        }
    }

    // MARK: Change observer (Phase 9 — per-op undo menu labels)

    @Test func theChangeObserverFiresOnEveryStackMutation() throws {
        try withOperations { _, _ in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let seen = LockIsolated<[String?]>([])
            // Strong capture: a deliberate test-lifetime cycle (the app
            // wires this observer at composition with the same lifetime).
            stack.setChangeObserver {
                seen.withValue { $0.append(stack.topLabel) }
            }

            let post = try ops.createPost()
            let made = try ops.seedBlock(in: post.id, text: "x")
            try ops.deleteBlock(made.block.id)          // register → fires
            #expect(seen.value.last == "Delete Block")

            try stack.undo(with: ops)                    // completed undo → fires
            #expect(seen.value.last == nil as String?)
            #expect(seen.value.count == 2)

            try ops.deleteBlock(made.block.id)
            stack.removeAll()                            // removeAll → fires
            #expect(seen.value.count == 4)
            #expect(seen.value.last == nil as String?)

            // A FAILED undo mutates nothing and fires nothing.
            try ops.restoreBlock(made.block.id)
            try ops.deleteBlock(made.block.id)
            let countBefore = seen.value.count
            try ops.lockPost(post.id)
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try stack.undo(with: ops)
            }
            #expect(seen.value.count == countBefore)
            #expect(stack.depth == 1)
        }
    }

    // MARK: A12 — the destructive-undo warning's INPUT (13d batch 5)
    //
    // The author's ruling, 2026-07-28: warn ONLY when the undo would discard
    // text edited since the operation — the fourth quiet auto-commit
    // occasion's own class — and stay silent for every other structural
    // undo. These pins hold both halves of that "only".

    @Test func theWarningFiresExactlyOnTheInsuranceClass() throws {
        try withOperations { _, _ in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.seedBlock(in: post.id, text: "First half. Second half.")

            try ops.divide(a.block.id, cut: 12)
            // Nothing edited since: the undo would restore a buffer that is
            // still exactly the op's own output. Silent.
            #expect(stack.pendingUndoWarning(with: ops) == nil)

            // She edits the first half — NOW the undo would set that writing
            // aside, and the door must ask.
            try ops.autosave(a.variant.id, text: "First half, rewritten.", charDelta: 6)
            #expect(stack.pendingUndoWarning(with: ops)
                == UndoStack.PendingUndoWarning(label: "Divide", bufferCount: 1))

            // Committing it takes it OUT of the class: nothing would be
            // discarded that history does not already hold.
            try ops.commit(a.variant.id)
            #expect(stack.pendingUndoWarning(with: ops) == nil)

            // Typing again puts it back — the question is asked against the
            // store as it is now, never cached at registration.
            try ops.autosave(a.variant.id, text: "First half, rewritten twice.", charDelta: 6)
            #expect(stack.pendingUndoWarning(with: ops)?.bufferCount == 1)

            // And editing back to the pre-image is not the class either:
            // there is nothing to set aside.
            try ops.autosave(a.variant.id, text: "First half. Second half.", charDelta: 4)
            #expect(stack.pendingUndoWarning(with: ops) == nil)
        }
    }

    @Test func everyOtherStructuralUndoIsSilent() throws {
        try withOperations { _, _ in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.seedBlock(in: post.id, text: "alpha")
            let b = try ops.seedBlock(in: post.id, text: "beta")

            // A merge RESTORES no buffer (its sources are released whole),
            // so it can discard nothing — silent by construction, even with
            // both sources edited to the hilt beforehand.
            try ops.merge(a.block.id, b.block.id)
            #expect(stack.pendingUndoWarning(with: ops) == nil)

            // The same for the delete/move/reorder family.
            let c = try ops.seedBlock(in: post.id, text: "gamma")
            try ops.deleteBlock(c.block.id)
            #expect(stack.pendingUndoWarning(with: ops) == nil)

            // An empty stack asks nothing.
            stack.removeAll()
            #expect(stack.pendingUndoWarning(with: ops) == nil)
        }
    }

    /// The warning speaks for the WHOLE compound (Make Block from Selection
    /// is two divides and one entry), and the count is the buffers, not the
    /// legs.
    @Test func aCompoundWarnsForEveryLegItWouldRestore() throws {
        try withOperations { _, _ in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.seedBlock(in: post.id, text: "one. two. three.")

            // The SECOND leg's restore target is the block the FIRST leg
            // minted (it is the one whose buffer that divide truncated) —
            // not the block the second leg mints, which is a fresh row undo
            // tombstones rather than restores. My first draft of this pin
            // edited the wrong variant and read 1 where 2 was right; the
            // pin was wrong, the code was not.
            let middle = try stack.withCompound(label: "Make Block", operations: ops) {
                let first = try ops.divide(a.block.id, cut: 5)     // "one." | "two. three."
                _ = try ops.divide(first.block.id, cut: 5)         // "two." | "three."
                return first
            }
            #expect(stack.depth == 1)
            #expect(stack.pendingUndoWarning(with: ops) == nil)

            try ops.autosave(a.variant.id, text: "one, rewritten.", charDelta: 5)
            #expect(stack.pendingUndoWarning(with: ops)
                == UndoStack.PendingUndoWarning(label: "Make Block", bufferCount: 1))

            // Both legs' buffers count — the compound is ONE act to her.
            try ops.autosave(middle.variant.id, text: "two, rewritten.", charDelta: 6)
            #expect(stack.pendingUndoWarning(with: ops)?.bufferCount == 2)
        }
    }

    /// The warning is a QUESTION, never a gate: the undo itself is unchanged
    /// and still insures what it overwrites (the fourth occasion), so a
    /// door that skipped the ask can lose nothing.
    @Test func theWarningNeverChangesWhatTheUndoDoes() throws {
        try withOperations { ops, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.seedBlock(in: post.id, text: "First half. Second half.")
            try ops.divide(a.block.id, cut: 12)
            try ops.autosave(a.variant.id, text: "First half, rewritten.", charDelta: 6)

            _ = stack.pendingUndoWarning(with: ops)   // asked
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [a.variant.id]) == 0)

            try stack.undo(with: ops)
            // The insurance commit rides the undo's own transaction, not the
            // question: the set-aside text is one restore away.
            #expect(try db.fetchString(
                "SELECT text FROM commit_point WHERE variant_id = ?", [a.variant.id])
                == "First half, rewritten.")
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [a.variant.id])
                == "First half. Second half.")
        }
    }
}
