import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Divide, single-variant (Phase 3, Step 3)")
struct StructuralDivideTests {
    @Test func divideExactRows() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let before = try ops.newBlock(in: post.id, text: "before")
            let a = try ops.newBlock(in: post.id, text: "Para one.\n\nPara two.")
            let after = try ops.newBlock(in: post.id, text: "after")

            let result = try ops.divide(a.block.id, cut: 11)

            // A keeps identity as the seam-trimmed first half.
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [a.variant.id]) == "Para one.")
            #expect(try db.deletedAt("block", a.block.id) == nil)
            #expect(try db.deletedAt("container_block", a.placement.id) == nil)

            // C: the second half, immediately after A, default + chosen set.
            #expect(result.variant.workingText == "Para two.")
            #expect(result.block.defaultVariantId == result.variant.id)
            #expect(result.placement.chosenVariantId == result.variant.id)
            #expect(try liveBlockOrder(db, in: post.id)
                == [before.block.id, a.block.id, result.block.id, after.block.id])

            // Lineage: C derived_from A, minted by divide.
            #expect(result.edge.sourceBlockId == result.block.id)
            #expect(result.edge.targetBlockId == a.block.id)
            #expect(result.edge.type == .derivedFrom)
            #expect(result.edge.originOp == "divide")
        }
    }

    @Test func commitsStayOnTheSourceAndRestorePreSplitText() throws {
        // The documented restoreCommit-predates-split behavior (AppSpec §9):
        // A's old commits still hold the full pre-split text; restoring one
        // resurrects both halves into A's buffer while C sits next door.
        // Coherent under "coarse, not forensic" — the editor warns (Phase 7).
        try withOperations { ops, db in
            let post = try ops.createPost()
            let full = "Para one.\n\nPara two."
            let a = try ops.newBlock(in: post.id, text: full)
            let savepoint = try ops.commit(a.variant.id)

            let result = try ops.divide(a.block.id, cut: 11)

            // A's commit history is untouched by the cut.
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [a.variant.id]) == 1)
            #expect(try db.fetchString(
                "SELECT text FROM commit_point WHERE id = ?", [savepoint.id]) == full)

            try ops.restoreCommit(a.variant.id, commitID: savepoint.id)

            // Both halves back in A's buffer; C still holds the second half.
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [a.variant.id]) == full)
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [result.variant.id]) == "Para two.")
            #expect(try liveBlockOrder(db, in: post.id) == [a.block.id, result.block.id])
        }
    }

    @Test func utf16CutsRespectGraphemes() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            // Emoji occupies UTF-16 offsets 3–13; the sentence boundary is 16.
            let a = try ops.newBlock(in: post.id, text: "Hi 👩‍👩‍👧‍👦. Done.")

            #expect(throws: OperationError.invalidCut(variantID: a.variant.id, cut: 5)) {
                try ops.divide(a.block.id, cut: 5)
            }

            let result = try ops.divide(a.block.id, cut: 16)
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [a.variant.id]) == "Hi 👩‍👩‍👧‍👦.")
            #expect(result.variant.workingText == "Done.")
        }
    }

    @Test func divideRefusals() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "Para one.\n\nPara two.")

            // Edge cuts and cuts that trim to an empty half.
            for cut in [0, 20, 99, -1] {
                #expect(throws: OperationError.invalidCut(variantID: a.variant.id, cut: cut)) {
                    try ops.divide(a.block.id, cut: cut)
                }
            }
            // Cut inside the separator run still yields two halves — but one
            // inside leading text whitespace would not; covered by Domain
            // tests, asserted at the op layer via the whitespace-only text.
            let padded = try ops.newBlock(in: post.id, text: "   Hello there")
            #expect(throws: OperationError.invalidCut(variantID: padded.variant.id, cut: 2)) {
                try ops.divide(padded.block.id, cut: 2)
            }

            // A fanned block refuses toward the W ceremony.
            let take2 = try ops.branchVariant(a.block.id, from: a.variant.id)
            #expect(throws: OperationError.fannedBlock(id: a.block.id)) {
                try ops.divide(a.block.id, cut: 11)
            }
            try ops.deleteVariant(take2.id)

            // Sealed post, locked variant, unplaced block.
            try ops.lockPost(post.id)
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.divide(a.block.id, cut: 11)
            }
            try ops.unlockPost(post.id)
            try ops.lockVariant(a.variant.id)
            #expect(throws: OperationError.lockedVariant(id: a.variant.id)) {
                try ops.divide(a.block.id, cut: 11)
            }
            try ops.unlockVariant(a.variant.id)
            try ops.deleteBlock(a.block.id)
            try ops.deleteContainer(post.id)
            try ops.restoreBlock(a.block.id)
            #expect(throws: OperationError.blockNotPlaced(id: a.block.id)) {
                try ops.divide(a.block.id, cut: 11)
            }

            // No refusal grew the world or touched the undo stack (the
            // delete/restore gestures above registered their own entries).
            #expect(try db.fetchInt("SELECT COUNT(*) FROM edge") == 0)
            #expect(stack.topLabel != "Divide")
        }
    }

    @Test func divideFeedsChurn() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "Para one.\n\nPara two.")
            _ = try ops.divide(a.block.id, cut: 11)
            #expect(try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [post.id]) != nil)
            #expect(try db.fetchString(
                "SELECT last_major_revision_at FROM container WHERE id = ?", [post.id]) != nil)
        }
    }

    @Test func divideUndoRoundTripsToRowEquality() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "Para one.\n\nPara two.")
            let sourceBefore = try db.snapshotRow("variant", a.variant.id)

            let result = try ops.divide(a.block.id, cut: 11)
            #expect(stack.topLabel == "Divide")

            try stack.undo(with: ops)

            #expect(try db.snapshotRow("variant", a.variant.id) == sourceBefore)
            #expect(try db.deletedAt("block", result.block.id) != nil)
            #expect(try db.deletedAt("variant", result.variant.id) != nil)
            #expect(try db.deletedAt("container_block", result.placement.id) != nil)
            #expect(try db.deletedAt("edge", result.edge.id) != nil)
            #expect(try liveBlockOrder(db, in: post.id) == [a.block.id])
            #expect(stack.depth == 0)
        }
    }
}
