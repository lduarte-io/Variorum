import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Merge (Phase 3, Step 5)")
struct StructuralMergeTests {
    @Test func mergeExactRows() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let before = try ops.seedBlock(in: post.id, text: "before")
            let b = try ops.seedBlock(in: post.id, text: "First half.")
            let c = try ops.seedBlock(in: post.id, text: "Second half.")
            let after = try ops.seedBlock(in: post.id, text: "after")
            let savepoint = try ops.commit(b.variant.id)

            let result = try ops.merge(b.block.id, c.block.id)

            // A': one variant, joined with the RENDERING join — exactly one
            // newline (author ruling R-13u4-3, 2026-09-20; this pin read
            // "First half. Second half." until 13u4 UNIT E3 rewrote it to
            // the ruling, which supersedes the 2026-07-06 single space).
            #expect(result.variant.workingText == "First half.\nSecond half.")
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
                // Release stamps the last home (tray/restore semantics).
                #expect(try db.fetchString(
                    "SELECT last_container_id FROM block WHERE id = ?", [source.block.id]) == post.id)
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
            let b = try ops.seedBlock(in: post.id, text: "Original first.")
            let c = try ops.seedBlock(in: post.id, text: "Second half.")
            let alt = try ops.branchVariant(b.block.id, from: b.variant.id)
            try ops.autosave(alt.id, text: "Alt first.", charDelta: 0)
            try ops.chooseVariant(b.block.id, variantID: alt.id)

            let result = try ops.merge(b.block.id, c.block.id)

            #expect(result.variant.workingText == "Alt first.\nSecond half.")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                [b.block.id]) == 2)
        }
    }

    @Test func aDoorMergeJoinsWithoutTrimmingOrCondition() throws {
        // **R-13u4-3 (2026-09-20) — the ruled behaviour, replacing this
        // test's own former subject.** It used to be
        // `mergeNeverDoublesExistingEdgeWhitespace`: the space appeared only
        // when neither edge already carried whitespace, and a MID-SENTENCE
        // divide→merge round trip restored the sentence exactly. The door
        // rule has no conditionals left, so what it asserts now is the pair
        // her ruling names — the trade she accepted, and the gain.
        try withOperations { ops, db in
            let post = try ops.createPost()

            // THE TRADE (stated at the sitting, accepted): a mid-sentence
            // cut comes back with a newline, not the space it was cut at.
            let a = try ops.seedBlock(in: post.id, text: "One alpha. One omega.")
            let divided = try ops.divide(a.block.id, cut: 11)
            let restored = try ops.merge(a.block.id, divided.block.id)
            #expect(restored.variant.workingText == "One alpha.\nOne omega.")

            // NOTHING IS TRIMMED: an edge that already carries whitespace
            // keeps it AND gets the newline — "byte-exact, no trimming, no
            // conditionals" (this line asserted "Trailing space already
            // separated" before the ruling).
            let b = try ops.seedBlock(in: post.id, text: "Trailing space ")
            let c = try ops.seedBlock(in: post.id, text: "already separated")
            let joined = try ops.merge(b.block.id, c.block.id)
            #expect(joined.variant.workingText == "Trailing space \nalready separated")
        }
    }

    @Test func aParagraphCutNowRoundTripsByteExactly() throws {
        // **THE GAIN her ruling buys** (her words: *"Merging should not
        // remove a newlines in the middle of the merge selected area, it
        // should just make all newlines within the selected portion part of
        // a single block"*): what the page showed as two paragraphs comes
        // back as the same bytes it started as — impossible under the space
        // join, which is the whole reason the rule changed.
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.seedBlock(in: post.id, text: "Paragraph one.")
            let b = try ops.seedBlock(in: post.id, text: "Paragraph two.")
            let c = try ops.seedBlock(in: post.id, text: "Paragraph three.")

            // The page (the editor surface joins blocks with one "\n").
            let page = "Paragraph one.\nParagraph two.\nParagraph three."

            let first = try ops.merge(a.block.id, b.block.id)
            let whole = try ops.merge(first.block.id, c.block.id)
            #expect(whole.variant.workingText == page,
                    "a run merged block by block reads byte-identical to the page")
        }
    }

    @Test func aDeleteKeystrokesMergeKeepsTheShippedJoin() throws {
        // **The DELETES half of R-13u4-3's classification, at the operation
        // itself.** The seam carve and the cross-block compound pass
        // `.deleteKeystroke`, and they must keep the pre-ruling join byte
        // for byte — a delete that produced the newline it had just removed
        // would visibly do nothing. This pin is a GUARD, green on both sides
        // of the ruling by design.
        try withOperations { ops, db in
            let post = try ops.createPost()
            let b = try ops.seedBlock(in: post.id, text: "First half.")
            let c = try ops.seedBlock(in: post.id, text: "Second half.")
            let joined = try ops.merge(b.block.id, c.block.id, joining: .deleteKeystroke)
            #expect(joined.variant.workingText == "First half. Second half.")

            // …including its one conditional, which the door rule dropped.
            let d = try ops.seedBlock(in: post.id, text: "Trailing space ")
            let e = try ops.seedBlock(in: post.id, text: "already separated")
            let bare = try ops.merge(d.block.id, e.block.id, joining: .deleteKeystroke)
            #expect(bare.variant.workingText == "Trailing space already separated")
        }
    }

    @Test func mergeTouchesThePostWithoutReshuffling() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let b = try ops.seedBlock(in: post.id, text: "b")
            let c = try ops.seedBlock(in: post.id, text: "c")
            // The mints stamped both (QUESTIONS #5 (a)); the point under
            // test is that the MERGE touches without reshuffling.
            let touchedBefore = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [post.id])
            let majorBefore = try db.fetchString(
                "SELECT last_major_revision_at FROM container WHERE id = ?", [post.id])

            _ = try ops.merge(b.block.id, c.block.id)

            #expect(try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [post.id]) != touchedBefore)
            #expect(try db.fetchString(
                "SELECT last_major_revision_at FROM container WHERE id = ?", [post.id]) == majorBefore)
        }
    }

    @Test func mergeRefusesNonAdjacentPairs() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost()
            let b = try ops.seedBlock(in: post.id, text: "b")
            let x = try ops.seedBlock(in: post.id, text: "x")
            let c = try ops.seedBlock(in: post.id, text: "c")
            let otherPost = try ops.createPost()
            let elsewhere = try ops.seedBlock(in: otherPost.id, text: "far")

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
            let b = try ops.seedBlock(in: post.id, text: "b")
            let c = try ops.seedBlock(in: post.id, text: "c")
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
            let before = try ops.seedBlock(in: post.id, text: "before")
            let b = try ops.seedBlock(in: post.id, text: "First half.")
            let c = try ops.seedBlock(in: post.id, text: "Second half.")
            let after = try ops.seedBlock(in: post.id, text: "after")

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
            let before = try ops.seedBlock(in: post.id, text: "before")
            let b = try ops.seedBlock(in: post.id, text: "First half.")
            let c = try ops.seedBlock(in: post.id, text: "Second half.")
            let after = try ops.seedBlock(in: post.id, text: "after")
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
