import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// The shared W stage: A placed between two neighbors, carrying a
/// three-take fan — V1 (default + chosen), V2, V3 in fan order.
struct WWorld {
    let post: Container
    let before: Operations.NewBlockResult
    let a: Operations.NewBlockResult
    let after: Operations.NewBlockResult
    let v1: String
    let v2: String
    let v3: String

    init(_ ops: Operations) throws {
        post = try ops.createPost()
        before = try ops.newBlock(in: post.id, text: "before")
        a = try ops.newBlock(in: post.id, text: "One alpha. One omega.")
        after = try ops.newBlock(in: post.id, text: "after")
        v1 = a.variant.id
        let take2 = try ops.branchVariant(a.block.id, from: v1)
        try ops.autosave(take2.id, text: "Two intact.", charDelta: 0)
        let take3 = try ops.branchVariant(a.block.id, from: take2.id)
        try ops.autosave(take3.id, text: "Three start.\nThree end.", charDelta: 0)
        v2 = take2.id
        v3 = take3.id
    }
}

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
            // The mint crossed (QUESTIONS #5 (a)): baseline 20, accumulator 0.
            let touchedAtMint = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [post.id])
            #expect(touchedAtMint != nil)

            _ = try ops.divide(a.block.id, cut: 11)
            // The seam-trimmed first half drops 11 chars (20 → 9): churn
            // accumulates 11 against the 20-char baseline (11/20 < 0.8) —
            // divide visibly feeds churn without restamping.
            #expect(try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [post.id]) != touchedAtMint)
            #expect(try db.fetchInt(
                "SELECT churn_accumulator FROM container WHERE id = ?", [post.id]) == 11)
        }
    }

    @Test func divideWWorkedExampleExactRows() throws {
        try withOperations { ops, db in
            let world = try WWorld(ops)
            let result = try ops.divideW(world.a.block.id, cuts: [
                world.v1: 11,  // "One alpha. | One omega."
                world.v3: 13,  // "Three start.\n | Three end."
            ])

            // A is preserved whole: live, unplaced, fan + default untouched.
            #expect(try db.deletedAt("block", world.a.block.id) == nil)
            #expect(try db.read { try ops.livePlacement($0, blockID: world.a.block.id) } == nil)
            #expect(try db.deletedAt("container_block", result.releasedPlacementID) != nil)
            for (variant, text) in [
                (world.v1, "One alpha. One omega."),
                (world.v2, "Two intact."),
                (world.v3, "Three start.\nThree end."),
            ] {
                #expect(try db.fetchString(
                    "SELECT working_text FROM variant WHERE id = ?", [variant]) == text)
                #expect(try db.deletedAt("variant", variant) == nil)
            }
            #expect(try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?", [world.a.block.id]) == world.v1)
            // The release stamps A's last home, so a later deleteBlock on
            // the released block still trays and restores correctly.
            #expect(try db.fetchString(
                "SELECT last_container_id FROM block WHERE id = ?", [world.a.block.id]) == world.post.id)

            // B carries the first halves, C the second, marked order preserved.
            #expect(result.markedSourceIDs == [world.v1, world.v3])
            #expect(result.first.variants.map(\.workingText) == ["One alpha.", "Three start."])
            #expect(result.second.variants.map(\.workingText) == ["One omega.", "Three end."])
            #expect(result.first.variants[0].fanPosition < result.first.variants[1].fanPosition)
            #expect(result.second.variants[0].fanPosition < result.second.variants[1].fanPosition)

            // Rendered (V1) was marked: its halves are default AND chosen.
            #expect(result.first.block.defaultVariantId == result.first.variants[0].id)
            #expect(result.second.block.defaultVariantId == result.second.variants[0].id)
            #expect(result.first.placement.chosenVariantId == result.first.variants[0].id)
            #expect(result.second.placement.chosenVariantId == result.second.variants[0].id)

            // B then C stand exactly where A stood.
            #expect(try liveBlockOrder(db, in: world.post.id) == [
                world.before.block.id, result.first.block.id,
                result.second.block.id, world.after.block.id,
            ])

            // Lineage: both successors derive from A via divide.
            for half in [result.first, result.second] {
                #expect(half.edge.sourceBlockId == half.block.id)
                #expect(half.edge.targetBlockId == world.a.block.id)
                #expect(half.edge.type == .derivedFrom)
                #expect(half.edge.originOp == "divide")
            }
        }
    }

    @Test func divideWMixAndMatch() throws {
        // The W payoff: first-half-of-attempt-1 with second-half-of-attempt-3.
        try withOperations { ops, db in
            let world = try WWorld(ops)
            let result = try ops.divideW(world.a.block.id, cuts: [world.v1: 11, world.v3: 13])

            try ops.chooseVariant(result.second.block.id, variantID: result.second.variants[1].id)

            #expect(try db.read { try ops.renderedVariant($0, blockID: result.first.block.id) }
                .workingText == "One alpha.")
            #expect(try db.read { try ops.renderedVariant($0, blockID: result.second.block.id) }
                .workingText == "Three end.")
        }
    }

    @Test func divideWWithRenderedUnmarkedUsesFirstMarkedDefaults() throws {
        try withOperations { ops, db in
            let world = try WWorld(ops)  // rendered = chosen = V1
            let result = try ops.divideW(world.a.block.id, cuts: [world.v3: 13])

            #expect(result.first.variants.map(\.workingText) == ["Three start."])
            #expect(result.first.block.defaultVariantId == result.first.variants[0].id)
            // Chosen stays NULL: the slot renders the default by fallback.
            #expect(result.first.placement.chosenVariantId == nil)
            #expect(result.second.placement.chosenVariantId == nil)
            #expect(try db.read { try ops.renderedVariant($0, blockID: result.second.block.id) }
                .workingText == "Three end.")
        }
    }

    @Test func divideWTouchesThePostWithoutReshuffling() throws {
        // Structural work counts as touching (author decision 2026-07-06) —
        // but never as a major revision: restructuring must not reshuffle
        // the library's meaningful sort.
        try withOperations { ops, db in
            let world = try WWorld(ops)
            let touchedBefore = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [world.post.id])
            let majorBefore = try db.fetchString(
                "SELECT last_major_revision_at FROM container WHERE id = ?", [world.post.id])

            _ = try ops.divideW(world.a.block.id, cuts: [world.v1: 11])

            let touchedAfter = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [world.post.id])
            #expect(touchedAfter != nil && touchedAfter != touchedBefore)
            #expect(try db.fetchString(
                "SELECT last_major_revision_at FROM container WHERE id = ?", [world.post.id])
                == majorBefore)
        }
    }

    @Test func aReleasedBlockDeletedLaterStillRestoresHome() throws {
        // The last_container_id stamped at release feeds the tray path:
        // delete the released A, restore it, and it lands back in its post.
        try withOperations { ops, db in
            let world = try WWorld(ops)
            _ = try ops.divideW(world.a.block.id, cuts: [world.v1: 11])
            try ops.deleteBlock(world.a.block.id)
            try ops.restoreBlock(world.a.block.id)
            let home = try db.read { try ops.livePlacement($0, blockID: world.a.block.id) }
            #expect(home?.containerId == world.post.id)
        }
    }

    @Test func divideWReversibleByRePointingAtA() throws {
        // The W promise made real: release the successors, placeBlock(A),
        // and the reading is back — nobody's five editors disappeared.
        try withOperations { ops, db in
            let world = try WWorld(ops)
            let result = try ops.divideW(world.a.block.id, cuts: [world.v1: 11, world.v3: 13])

            try ops.deleteBlock(result.first.block.id)
            try ops.deleteBlock(result.second.block.id)
            try ops.placeBlock(world.a.block.id, in: world.post.id, at: .before(world.after.block.id))

            #expect(try liveBlockOrder(db, in: world.post.id)
                == [world.before.block.id, world.a.block.id, world.after.block.id])
            #expect(try db.read { try ops.renderedVariant($0, blockID: world.a.block.id) }
                .workingText == "One alpha. One omega.")
        }
    }

    @Test func divideWLockedMarkedVariantCarriesThrough() throws {
        // A locked variant's buffer is copied, never edited — the guard
        // protects the original, which W leaves untouched on A.
        try withOperations { ops, db in
            let world = try WWorld(ops)
            try ops.lockVariant(world.v3)
            let result = try ops.divideW(world.a.block.id, cuts: [world.v3: 13])
            #expect(result.first.variants[0].workingText == "Three start.")
            #expect(try db.fetchInt(
                "SELECT locked FROM variant WHERE id = ?", [world.v3]) == 1)
            // The copies are not born locked.
            #expect(result.first.variants[0].locked == false)
        }
    }

    @Test func divideWRefusals() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let world = try WWorld(ops)
            let a = world.a.block.id

            #expect(throws: OperationError.noMarkedVariants(blockID: a)) {
                try ops.divideW(a, cuts: [:])
            }
            #expect(throws: OperationError.invalidCut(variantID: world.v1, cut: 0)) {
                try ops.divideW(a, cuts: [world.v1: 0])
            }
            #expect(throws: OperationError.variantNotFound(id: "stranger")) {
                try ops.divideW(a, cuts: ["stranger": 5])
            }
            // A variant of some other block is a foreign mark too.
            #expect(throws: OperationError.variantNotFound(id: world.before.variant.id)) {
                try ops.divideW(a, cuts: [world.before.variant.id: 3])
            }
            try ops.archiveVariant(world.v2)
            #expect(throws: OperationError.archivedVariant(id: world.v2)) {
                try ops.divideW(a, cuts: [world.v2: 5])
            }
            try ops.lockPost(world.post.id)
            #expect(throws: OperationError.lockedPost(id: world.post.id)) {
                try ops.divideW(a, cuts: [world.v1: 11])
            }
            try ops.unlockPost(world.post.id)

            // Nothing minted, nothing released, undo stack clean of divides.
            #expect(try db.fetchInt("SELECT COUNT(*) FROM edge") == 0)
            #expect(try db.deletedAt("container_block", world.a.placement.id) == nil)
            #expect(stack.topLabel != "Divide")
        }
    }

    @Test func divideWUndoFlipsThePlacementAndTombstonesTheSuccessors() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let world = try WWorld(ops)
            let placementBefore = try db.snapshotRow("container_block", world.a.placement.id)

            let result = try ops.divideW(world.a.block.id, cuts: [world.v1: 11, world.v3: 13])
            #expect(stack.topLabel == "Divide")

            try stack.undo(with: ops)

            // A's exact placement row is back — position and chosen intact.
            #expect(try db.snapshotRow("container_block", world.a.placement.id) == placementBefore)
            #expect(try liveBlockOrder(db, in: world.post.id)
                == [world.before.block.id, world.a.block.id, world.after.block.id])
            for half in [result.first, result.second] {
                #expect(try db.deletedAt("block", half.block.id) != nil)
                #expect(try db.deletedAt("container_block", half.placement.id) != nil)
                #expect(try db.deletedAt("edge", half.edge.id) != nil)
                for variant in half.variants {
                    #expect(try db.deletedAt("variant", variant.id) != nil)
                }
            }
            #expect(stack.depth == 0)
        }
    }

    @Test func divideWUndoLeavesARePlacedBlockAlone() throws {
        // Divergence rule: if A found a new home between do and undo, I2
        // wins — the undo still clears the successors but never dual-places A.
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let world = try WWorld(ops)
            let result = try ops.divideW(world.a.block.id, cuts: [world.v1: 11])

            let elsewhere = try ops.createPost()
            try ops.placeBlock(world.a.block.id, in: elsewhere.id)

            try stack.undo(with: ops)

            #expect(try db.deletedAt("block", result.first.block.id) != nil)
            #expect(try db.deletedAt("container_block", world.a.placement.id) != nil)  // stays released
            let home = try db.read { try ops.livePlacement($0, blockID: world.a.block.id) }
            #expect(home?.containerId == elsewhere.id)
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
