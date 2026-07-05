import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Merge (Phase 3, Step 5)")
struct StructuralMergeTests {
    @Test func mergeExactRows() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let before = try ops.newBlock(in: post.id, text: "before")
            let b = try ops.newBlock(in: post.id, text: "First half.")
            let c = try ops.newBlock(in: post.id, text: "Second half.")
            let after = try ops.newBlock(in: post.id, text: "after")
            let savepoint = try ops.commit(b.variant.id)

            let result = try ops.merge(b.block.id, c.block.id)

            // A': one variant, the exact concatenation — no separator
            // invented (documented; the author sees the raw join and adjusts).
            #expect(result.variant.workingText == "First half.Second half.")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE block_id = ?", [result.block.id]) == 1)
            #expect(result.block.defaultVariantId == result.variant.id)
            #expect(result.placement.chosenVariantId == result.variant.id)

            // A' stands where the pair stood.
            #expect(try liveBlockOrder(db, in: post.id)
                == [before.block.id, result.block.id, after.block.id])

            // B and C: released to lineage — live, unplaced, fans and
            // commits untouched.
            for source in [b, c] {
                #expect(try db.deletedAt("block", source.block.id) == nil)
                #expect(try db.read { try ops.livePlacement($0, blockID: source.block.id) } == nil)
                #expect(try db.deletedAt("variant", source.variant.id) == nil)
            }
            #expect(try db.fetchString(
                "SELECT text FROM commit_point WHERE id = ?", [savepoint.id]) == "First half.")

            // The edge pair: A' derived_from each source, minted by merge.
            #expect(result.firstEdge.sourceBlockId == result.block.id)
            #expect(result.firstEdge.targetBlockId == b.block.id)
            #expect(result.secondEdge.targetBlockId == c.block.id)
            #expect(result.firstEdge.originOp == "merge")
            #expect(result.secondEdge.originOp == "merge")
            #expect(result.firstEdge.type == .derivedFrom)
        }
    }

    @Test func mergeConcatenatesTheRenderedVariants() throws {
        // Fans are not cartesian-producted: the chosen take of each side is
        // what joins; both fans stay whole on the released sources.
        try withOperations { ops, db in
            let post = try ops.createPost()
            let b = try ops.newBlock(in: post.id, text: "Original first.")
            let c = try ops.newBlock(in: post.id, text: "Second half.")
            let alt = try ops.branchVariant(b.block.id, from: b.variant.id)
            try ops.autosave(alt.id, text: "Alt first.", charDelta: 0)
            try ops.chooseVariant(b.block.id, variantID: alt.id)

            let result = try ops.merge(b.block.id, c.block.id)

            #expect(result.variant.workingText == "Alt first.Second half.")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                [b.block.id]) == 2)
        }
    }

    @Test func mergeRefusesNonAdjacentPairs() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost()
            let b = try ops.newBlock(in: post.id, text: "b")
            let x = try ops.newBlock(in: post.id, text: "x")
            let c = try ops.newBlock(in: post.id, text: "c")
            let otherPost = try ops.createPost()
            let elsewhere = try ops.newBlock(in: otherPost.id, text: "far")

            // A block between them, reversed order, self, cross-container.
            #expect(throws: OperationError.blocksNotAdjacent(first: b.block.id, second: c.block.id)) {
                try ops.merge(b.block.id, c.block.id)
            }
            #expect(throws: OperationError.blocksNotAdjacent(first: x.block.id, second: b.block.id)) {
                try ops.merge(x.block.id, b.block.id)
            }
            #expect(throws: OperationError.blocksNotAdjacent(first: b.block.id, second: b.block.id)) {
                try ops.merge(b.block.id, b.block.id)
            }
            #expect(throws: OperationError.blocksNotAdjacent(first: c.block.id, second: elsewhere.block.id)) {
                try ops.merge(c.block.id, elsewhere.block.id)
            }
        }
    }

    @Test func mergeRefusesUnderASealedPost() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let b = try ops.newBlock(in: post.id, text: "b")
            let c = try ops.newBlock(in: post.id, text: "c")
            try ops.lockPost(post.id)
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.merge(b.block.id, c.block.id)
            }
            #expect(try db.fetchInt("SELECT COUNT(*) FROM edge") == 0)
            #expect(try db.deletedAt("container_block", b.placement.id) == nil)
        }
    }

    @Test func mergeReversibleByRePointingAtTheSources() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let before = try ops.newBlock(in: post.id, text: "before")
            let b = try ops.newBlock(in: post.id, text: "First half.")
            let c = try ops.newBlock(in: post.id, text: "Second half.")
            let after = try ops.newBlock(in: post.id, text: "after")

            let result = try ops.merge(b.block.id, c.block.id)
            try ops.deleteBlock(result.block.id)
            try ops.placeBlock(b.block.id, in: post.id, at: .before(after.block.id))
            try ops.placeBlock(c.block.id, in: post.id, at: .before(after.block.id))

            #expect(try liveBlockOrder(db, in: post.id)
                == [before.block.id, b.block.id, c.block.id, after.block.id])
        }
    }

    @Test func mergeUndoFlipsBothPlacementsAndTombstonesThePair() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let before = try ops.newBlock(in: post.id, text: "before")
            let b = try ops.newBlock(in: post.id, text: "First half.")
            let c = try ops.newBlock(in: post.id, text: "Second half.")
            let after = try ops.newBlock(in: post.id, text: "after")
            let bPlacementBefore = try db.snapshotRow("container_block", b.placement.id)
            let cPlacementBefore = try db.snapshotRow("container_block", c.placement.id)

            let result = try ops.merge(b.block.id, c.block.id)
            #expect(stack.topLabel == "Merge")

            try stack.undo(with: ops)

            #expect(try db.snapshotRow("container_block", b.placement.id) == bPlacementBefore)
            #expect(try db.snapshotRow("container_block", c.placement.id) == cPlacementBefore)
            #expect(try liveBlockOrder(db, in: post.id)
                == [before.block.id, b.block.id, c.block.id, after.block.id])
            #expect(try db.deletedAt("block", result.block.id) != nil)
            #expect(try db.deletedAt("variant", result.variant.id) != nil)
            #expect(try db.deletedAt("container_block", result.placement.id) != nil)
            #expect(try db.deletedAt("edge", result.firstEdge.id) != nil)
            #expect(try db.deletedAt("edge", result.secondEdge.id) != nil)
            #expect(stack.depth == 0)
        }
    }
}
