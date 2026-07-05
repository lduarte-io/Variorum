import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// The live block order of a container, `(position, id)`-sorted.
func liveBlockOrder(_ db: AppDatabase, in containerID: String) throws -> [String] {
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

@Suite("Rendered variant resolution (Phase 3, Step 2)")
struct RenderedVariantTests {
    @Test func chosenVariantWinsOverDefault() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "take one")
            let take2 = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.chooseVariant(a.block.id, variantID: take2.id)
            let rendered = try db.read { try ops.renderedVariant($0, blockID: a.block.id) }
            #expect(rendered.id == take2.id)
        }
    }

    @Test func archivedChosenFallsBackToDefault() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "take one")
            let take2 = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.chooseVariant(a.block.id, variantID: take2.id)
            try ops.archiveVariant(take2.id)
            let rendered = try db.read { try ops.renderedVariant($0, blockID: a.block.id) }
            #expect(rendered.id == a.variant.id)
        }
    }

    @Test func tombstonedChosenFallsBackToDefault() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "take one")
            let take2 = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.chooseVariant(a.block.id, variantID: take2.id)
            // A sync race can tombstone a chosen variant under the slot
            // (SyncSpec §7) — simulate below the operations layer.
            try db.write { db in
                try db.execute(
                    sql: "UPDATE variant SET deleted_at = '2026-07-04T12:00:00.000Z' WHERE id = ?",
                    arguments: [take2.id])
            }
            let rendered = try db.read { try ops.renderedVariant($0, blockID: a.block.id) }
            #expect(rendered.id == a.variant.id)
        }
    }

    @Test func foreignChosenFallsBackToDefault() throws {
        // Defense-in-depth: a chosen pointer at another block's variant
        // (unreachable through the ops layer; conceivable under corruption)
        // must never let a structural op rewrite that other block's text.
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "mine")
            let b = try ops.newBlock(in: post.id, text: "someone else's")
            try db.write { db in
                try db.execute(
                    sql: "UPDATE container_block SET chosen_variant_id = ? WHERE id = ?",
                    arguments: [b.variant.id, a.placement.id])
            }
            let rendered = try db.read { try ops.renderedVariant($0, blockID: a.block.id) }
            #expect(rendered.id == a.variant.id)
        }
    }

    @Test func nullChosenAndUnplacedBlocksRenderTheDefault() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "take one")
            try db.write { db in
                try db.execute(
                    sql: "UPDATE container_block SET chosen_variant_id = NULL WHERE id = ?",
                    arguments: [a.placement.id])
            }
            #expect(try db.read { try ops.renderedVariant($0, blockID: a.block.id) }.id == a.variant.id)

            // Live-but-unplaced (the lineage-leftover population): the
            // default is the pointer-free representative.
            try ops.deleteBlock(a.block.id)
            try ops.deleteContainer(post.id)
            try ops.restoreBlock(a.block.id)
            #expect(try db.read { try ops.livePlacement($0, blockID: a.block.id) } == nil)
            #expect(try db.read { try ops.renderedVariant($0, blockID: a.block.id) }.id == a.variant.id)
        }
    }
}

@Suite("Extract (Phase 3, Step 2)")
struct StructuralExtractTests {
    @Test func suffixExtractExactRows() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "First sentence. Second sentence.")
            let result = try ops.extract(a.block.id, span: 16..<32)

            // Source survives: identity kept, buffer = remainder, seam trimmed.
            let sourceText = try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [a.variant.id])
            #expect(sourceText == "First sentence.")

            // B: fresh block, one variant holding the trimmed span, default
            // and chosen pointing at it, placed adjacent AFTER the source.
            #expect(result.variant.workingText == "Second sentence.")
            #expect(result.block.defaultVariantId == result.variant.id)
            #expect(result.placement.containerId == post.id)
            #expect(result.placement.chosenVariantId == result.variant.id)
            #expect(try liveBlockOrder(db, in: post.id) == [a.block.id, result.block.id])

            // Lineage: B derived_from A, minted by extract.
            #expect(result.edge.sourceBlockId == result.block.id)
            #expect(result.edge.targetBlockId == a.block.id)
            #expect(result.edge.type == .derivedFrom)
            #expect(result.edge.originOp == "extract")

            // A's fan and default are untouched.
            #expect(try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?", [a.block.id]) == a.variant.id)
        }
    }

    @Test func prefixExtractInsertsBefore() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "First sentence. Second sentence.")
            let result = try ops.extract(a.block.id, span: 0..<15)

            #expect(result.variant.workingText == "First sentence.")
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [a.variant.id]) == "Second sentence.")
            #expect(try liveBlockOrder(db, in: post.id) == [result.block.id, a.block.id])
        }
    }

    @Test func utf16SpansRespectGraphemes() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            // "Intro 👩‍👩‍👧‍👦 emoji." occupies UTF-16 offsets 0–23; the tail starts at 25.
            let a = try ops.newBlock(in: post.id, text: "Intro 👩‍👩‍👧‍👦 emoji. Tail here.")
            let result = try ops.extract(a.block.id, span: 25..<35)
            #expect(result.variant.workingText == "Tail here.")
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [a.variant.id]) == "Intro 👩‍👩‍👧‍👦 emoji.")

            // A grapheme-splitting span refuses (offset 8 is inside the emoji).
            #expect(throws: OperationError.spanNotExtractable(blockID: a.block.id)) {
                try ops.extract(a.block.id, span: 0..<8)
            }
        }
    }

    @Test func middleAndDegenerateSpansRefuseAndChangeNothing() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "First sentence. Second sentence.")

            #expect(throws: OperationError.spanNotExtractable(blockID: a.block.id)) {
                try ops.extract(a.block.id, span: 6..<15)  // middle span → that's a divide
            }
            #expect(throws: OperationError.spanNotExtractable(blockID: a.block.id)) {
                try ops.extract(a.block.id, span: 0..<32)  // the whole text
            }

            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [a.variant.id])
                == "First sentence. Second sentence.")
            #expect(try db.fetchInt("SELECT COUNT(*) FROM block") == 1)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM edge") == 0)
            // Refusals leave the undo stack untouched.
            #expect(stack.depth == 0)
        }
    }

    @Test func fannedExtractEditsOnlyTheRenderedVariant() throws {
        // Documented behavior (AppSpec review #10): the other variants keep
        // their own copy of the span, so re-choosing later shows the
        // extracted content twice. The model accepts this; the editor may hint.
        try withOperations { ops, db in
            let post = try ops.createPost()
            let full = "Shared opening. Divergent conclusion."
            let a = try ops.newBlock(in: post.id, text: full)
            let take2 = try ops.branchVariant(a.block.id, from: a.variant.id)

            let result = try ops.extract(a.block.id, span: 16..<37)  // rendered = chosen = take 1

            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [a.variant.id]) == "Shared opening.")
            #expect(result.variant.workingText == "Divergent conclusion.")
            // Take 2 never contained-the-span-as-far-as-the-model-knows: untouched.
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [take2.id]) == full)

            // The documented duplication: switch the slot to take 2 and the
            // conclusion now renders twice (in A and in B).
            try ops.chooseVariant(a.block.id, variantID: take2.id)
            let renderedA = try db.read { try ops.renderedVariant($0, blockID: a.block.id) }
            #expect(renderedA.workingText.contains("Divergent conclusion."))
            #expect(result.variant.workingText == "Divergent conclusion.")
        }
    }

    @Test func extractRefusals() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "First sentence. Second sentence.")

            // Sealed post: structure is frozen.
            try ops.lockPost(post.id)
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.extract(a.block.id, span: 16..<32)
            }
            try ops.unlockPost(post.id)

            // Locked rendered variant: its buffer would be rewritten.
            try ops.lockVariant(a.variant.id)
            #expect(throws: OperationError.lockedVariant(id: a.variant.id)) {
                try ops.extract(a.block.id, span: 16..<32)
            }
            try ops.unlockVariant(a.variant.id)

            // Unplaced block: extract needs adjacency.
            try ops.deleteBlock(a.block.id)
            try ops.deleteContainer(post.id)
            try ops.restoreBlock(a.block.id)
            #expect(throws: OperationError.blockNotPlaced(id: a.block.id)) {
                try ops.extract(a.block.id, span: 16..<32)
            }
        }
    }

    @Test func extractFeedsChurnAndTouchStamps() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "First sentence. Second sentence.")
            let before = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [post.id])

            _ = try ops.extract(a.block.id, span: 16..<32)

            let touched = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [post.id])
            #expect(touched != nil && touched != before)
            // 17 removed chars against the fresh baseline (0) crosses the
            // 0.8 threshold: major revision stamped, accumulator reset,
            // baseline = rendered length (15 + 16 across the two blocks).
            #expect(try db.fetchString(
                "SELECT last_major_revision_at FROM container WHERE id = ?", [post.id]) != nil)
            #expect(try db.fetchInt(
                "SELECT churn_accumulator FROM container WHERE id = ?", [post.id]) == 0)
            #expect(try db.fetchInt(
                "SELECT baseline_length FROM container WHERE id = ?", [post.id]) == 31)
        }
    }

    @Test func extractUndoRoundTripsToRowEquality() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "First sentence. Second sentence.")
            let sourceBefore = try db.snapshotRow("variant", a.variant.id)

            let result = try ops.extract(a.block.id, span: 16..<32)
            #expect(stack.depth == 1)
            #expect(stack.topLabel == "Extract")

            try stack.undo(with: ops)

            #expect(try db.snapshotRow("variant", a.variant.id) == sourceBefore)
            #expect(try db.deletedAt("block", result.block.id) != nil)
            #expect(try db.deletedAt("variant", result.variant.id) != nil)
            #expect(try db.deletedAt("container_block", result.placement.id) != nil)
            #expect(try db.deletedAt("edge", result.edge.id) != nil)
            #expect(try liveBlockOrder(db, in: post.id) == [a.block.id])
            #expect(stack.depth == 0)
            // An undone mint must not haunt the deleted-blocks tray.
            #expect(try db.fetchString(
                "SELECT last_container_id FROM block WHERE id = ?", [result.block.id]) == nil)
        }
    }

    @Test func extractUndoInsuresADivergedBufferBeforeRestoring() throws {
        // The inverse restores the do-time pre-image — but a buffer edited
        // AFTER the extract is about to be overwritten, so undo appends one
        // quiet auto commit first (the fourth insurance occasion, mirroring
        // lockVariant/lockPost/long-idle; Phase 3 review finding, on the
        // closeout ratify list). Nothing the author typed is unreachable.
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "First sentence. Second sentence.")
            _ = try ops.extract(a.block.id, span: 16..<32)
            try ops.autosave(a.variant.id, text: "Rewritten first.", charDelta: 0)

            try stack.undo(with: ops)

            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [a.variant.id])
                == "First sentence. Second sentence.")
            #expect(try db.fetchString(
                """
                SELECT text FROM commit_point WHERE variant_id = ? AND kind = 'auto'
                ORDER BY created_at DESC, id DESC LIMIT 1
                """, [a.variant.id]) == "Rewritten first.")
        }
    }

    @Test func extractUndoWithAnUntouchedBufferCommitsNothing() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "First sentence. Second sentence.")
            _ = try ops.extract(a.block.id, span: 16..<32)

            try stack.undo(with: ops)

            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [a.variant.id]) == 0)
        }
    }

    @Test func extractUndoRefusalKeepsTheEntryForRetry() throws {
        let stack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "First sentence. Second sentence.")
            _ = try ops.extract(a.block.id, span: 16..<32)

            try ops.lockPost(post.id)
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try stack.undo(with: ops)
            }
            #expect(stack.depth == 1)  // resolvable refusal: entry stays

            try ops.unlockPost(post.id)
            try stack.undo(with: ops)
            #expect(stack.depth == 0)
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [a.variant.id])
                == "First sentence. Second sentence.")
        }
    }
}
