import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Pool drag-copy (Phase 3, Step 6)")
struct PoolDragCopyTests {
    /// A pool block with a three-take fan: V1 (default + chosen), V2
    /// branched from V1, V3 archived. One commit on V1 (never copied).
    struct PoolWorld {
        let pool: Container
        let post: Container
        let anchor: Operations.NewBlockResult
        let p: Operations.NewBlockResult
        let v2: Variant
        let v3: Variant

        init(_ ops: Operations) throws {
            pool = try ops.createPool()
            post = try ops.createPost()
            anchor = try ops.newBlock(in: post.id, text: "anchor")
            p = try ops.newBlock(in: pool.id, text: "Take one.")
            v2 = try ops.branchVariant(p.block.id, from: p.variant.id)
            try ops.autosave(v2.id, text: "Take two.", charDelta: 0)
            v3 = try ops.newBlankVariant(p.block.id)
            try ops.autosave(v3.id, text: "Archived take.", charDelta: 0)
            try ops.archiveVariant(v3.id)
            _ = try ops.commit(p.variant.id)
        }
    }

    @Test func defaultCopyCarriesOnlyTheRenderedText() throws {
        try withOperations { ops, db in
            let world = try PoolWorld(ops)
            let result = try ops.poolDragCopy(
                world.p.block.id, to: world.post.id, at: .after(world.anchor.block.id))

            // One fresh active, unlocked variant holding the rendered text.
            #expect(result.variants.map(\.workingText) == ["Take one."])
            #expect(result.variants[0].status == .active)
            #expect(result.variants[0].locked == false)
            #expect(result.block.defaultVariantId == result.variants[0].id)
            #expect(result.placement.chosenVariantId == result.variants[0].id)
            #expect(try liveBlockOrder(db, in: world.post.id)
                == [world.anchor.block.id, result.block.id])

            // Lineage, and commits never copied.
            #expect(result.edge.sourceBlockId == result.block.id)
            #expect(result.edge.targetBlockId == world.p.block.id)
            #expect(result.edge.originOp == "pool_copy")
            #expect(try db.fetchInt(
                """
                SELECT COUNT(*) FROM commit_point
                WHERE variant_id IN (SELECT id FROM variant WHERE block_id = ?)
                """, [result.block.id]) == 0)

            // The source stays whole in its pool.
            #expect(try liveBlockOrder(db, in: world.pool.id) == [world.p.block.id])
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                [world.p.block.id]) == 3)
        }
    }

    @Test func includeFanCopiesTheWholeLiveFan() throws {
        try withOperations { ops, db in
            let world = try PoolWorld(ops)
            let result = try ops.poolDragCopy(
                world.p.block.id, to: world.post.id, includeFan: true)

            // Every live take came along, statuses and fan order preserved.
            #expect(result.variants.map(\.workingText)
                == ["Take one.", "Take two.", "Archived take."])
            #expect(result.variants.map(\.status) == [.active, .active, .archived])
            #expect(result.variants.map(\.fanPosition)
                == [world.p.variant.fanPosition, world.v2.fanPosition, world.v3.fanPosition])

            // The parent tree is remapped inside the copy, never across.
            #expect(result.variants[1].parentVariantId == result.variants[0].id)
            #expect(result.variants[0].parentVariantId == nil)

            // Default and chosen are the rendered variant's copy.
            #expect(result.block.defaultVariantId == result.variants[0].id)
            #expect(result.placement.chosenVariantId == result.variants[0].id)
        }
    }

    @Test func poolDragCopyRefusals() throws {
        try withOperations { ops, _ in
            let world = try PoolWorld(ops)

            // Source must live in a pool — a post block refuses.
            #expect(throws: OperationError.blockNotInPool(id: world.anchor.block.id)) {
                try ops.poolDragCopy(world.anchor.block.id, to: world.post.id)
            }
            // Target must be a post — pool→pool stays out of scope.
            let otherPool = try ops.createPool()
            #expect(throws: OperationError.wrongContainerKind(id: otherPool.id, expected: .post)) {
                try ops.poolDragCopy(world.p.block.id, to: otherPool.id)
            }
            // Sealed target.
            try ops.lockPost(world.post.id)
            #expect(throws: OperationError.lockedPost(id: world.post.id)) {
                try ops.poolDragCopy(world.p.block.id, to: world.post.id)
            }
        }
    }

    @Test func poolDragCopyUndoClearsTheCopyAndOnlyTheCopy() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let world = try PoolWorld(ops)
            stack.removeAll()  // drop the fixture's own registrations
            let result = try ops.poolDragCopy(
                world.p.block.id, to: world.post.id, includeFan: true)
            #expect(stack.topLabel == "Pool Copy")

            try stack.undo(with: ops)

            #expect(try db.deletedAt("block", result.block.id) != nil)
            #expect(try db.deletedAt("container_block", result.placement.id) != nil)
            #expect(try db.deletedAt("edge", result.edge.id) != nil)
            for variant in result.variants {
                #expect(try db.deletedAt("variant", variant.id) != nil)
            }
            #expect(try liveBlockOrder(db, in: world.post.id) == [world.anchor.block.id])
            // The pool source never noticed.
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                [world.p.block.id]) == 3)
            #expect(stack.depth == 0)
        }
    }
}
