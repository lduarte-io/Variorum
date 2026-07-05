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
            let before = try ops.newBlock(in: post.id, text: "before")
            let target = try ops.newBlock(in: post.id, text: "the victim")
            let after = try ops.newBlock(in: post.id, text: "after")
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
            let made = try ops.newBlock(in: post.id, text: "take one")
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
            let made = try ops.newBlock(in: post.id, text: "take one")
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
            let made = try ops.newBlock(in: post.id, text: "wanderer")
            _ = try ops.newBlock(in: post.id, text: "neighbor")

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
            let blocks = try (0..<3).map { try ops.newBlock(in: post.id, text: "\($0)") }
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
            let made = try ops.newBlock(in: post.id, text: "x")
            _ = try ops.newBlock(in: post.id, text: "y")

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
            let made = try ops.newBlock(in: post.id, text: "text")
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
            let made = try ops.newBlock(in: post.id, text: "x")
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

    @Test func aFailedUndoStaysOnTheStackForRetry() throws {
        try withOperations { _, _ in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)

            let post = try ops.createPost()
            let pool = try ops.createPool()
            let made = try ops.newBlock(in: post.id, text: "x")
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
}
