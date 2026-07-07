import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Block & variant lifecycle (Phase 2, Step 5)")
struct BlockVariantOperationsTests {
    /// Live block IDs of a container in render order.
    private func blockOrder(_ db: AppDatabase, _ containerID: String) throws -> [String] {
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

    /// Live variant IDs of a block in fan order.
    private func fanOrder(_ db: AppDatabase, _ blockID: String) throws -> [String] {
        try db.read { db in
            try String.fetchAll(
                db,
                sql: """
                    SELECT id FROM variant
                    WHERE block_id = ? AND deleted_at IS NULL
                    ORDER BY fan_position, id
                    """,
                arguments: [blockID])
        }
    }

    private func container(_ db: AppDatabase, _ id: String) throws -> Container {
        try db.read { db in try Container.fetchOne(db, key: id)! }
    }

    // MARK: newBlock

    @Test func newBlockMintsBlockVariantAndPlacementExactly() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let result = try ops.newBlock(in: post.id, text: "A paragraph.")

            let block = try db.read { db in try Block.fetchOne(db, key: result.block.id) }
            #expect(block?.defaultVariantId == result.variant.id)
            #expect(block?.deletedAt == nil)

            let variant = try db.read { db in try Variant.fetchOne(db, key: result.variant.id) }
            #expect(variant?.workingText == "A paragraph.")
            #expect(variant?.blockId == result.block.id)
            #expect(variant?.status == .active)
            #expect(variant?.parentVariantId == nil)

            let placement = try db.read { db in try ContainerBlock.fetchOne(db, key: result.placement.id) }
            #expect(placement?.containerId == post.id)
            #expect(placement?.blockId == result.block.id)
            #expect(placement?.chosenVariantId == result.variant.id)

            for (table, id) in [
                ("block", result.block.id), ("variant", result.variant.id),
                ("container_block", result.placement.id),
            ] {
                #expect(try db.outboxContains(table, id), "\(table) missing from outbox")
            }
        }
    }

    @Test func newBlockInsertsAtTheRequestedSpot() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let first = try ops.newBlock(in: post.id, text: "1")
            let second = try ops.newBlock(in: post.id, text: "2")
            let atStart = try ops.newBlock(in: post.id, text: "0", at: .start)
            let between = try ops.newBlock(in: post.id, text: "1.5", at: .after(first.block.id))

            #expect(try blockOrder(db, post.id) == [
                atStart.block.id, first.block.id, between.block.id, second.block.id,
            ])
        }
    }

    /// Author decision 2026-07-07 (QUESTIONS #5 option (a), Phase 8
    /// checkpoint; implementation owned by Phase 9): minting text IS working
    /// on the post — `newBlock` stamps `last_touched_at` and feeds churn
    /// with the minted text's length, exactly like the text-changing ops
    /// (AppSpec §10 a fortiori). Red-on-old: the pre-Phase-9 `newBlock`
    /// wrote no stamp and no churn.
    @Test func newBlockStampsTouchAndFeedsChurn() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            _ = try ops.newBlock(in: post.id, text: "A fresh paragraph.")

            let after = try container(db, post.id)
            #expect(after.lastTouchedAt != nil, "the mint stamps the touch")
            // 18 minted chars against the fresh baseline (0) cross the 0.8
            // threshold: major revision stamped, accumulator reset,
            // baseline = the post's rendered length.
            #expect(after.lastMajorRevisionAt != nil)
            #expect(after.churnAccumulator == 0)
            #expect(after.baselineLength == 18)

            // A second mint against the now-real baseline accumulates
            // without restamping (6 / 18 < 0.8).
            let majorBefore = after.lastMajorRevisionAt
            _ = try ops.newBlock(in: post.id, text: "Short.")
            let second = try container(db, post.id)
            #expect(second.lastMajorRevisionAt == majorBefore)
            #expect(second.churnAccumulator == 6)
            #expect(second.lastTouchedAt != after.lastTouchedAt, "each mint touches")
        }
    }

    @Test func newBlockRefusedOnLockedOrMissingContainer() throws {
        try withOperations { ops, db in
            #expect(throws: OperationError.containerNotFound(id: "ghost")) {
                try ops.newBlock(in: "ghost", text: "x")
            }
            let post = try ops.createPost()
            try db.write { db in
                try db.execute(sql: "UPDATE container SET locked = 1 WHERE id = ?", arguments: [post.id])
            }
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.newBlock(in: post.id, text: "x")
            }
        }
    }

    // MARK: autosave & churn

    @Test func autosaveUpdatesBufferAndTouchesTheContainer() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "draft")

            try ops.autosave(made.variant.id, text: "draft!", charDelta: 1)

            let variant = try db.read { db in try Variant.fetchOne(db, key: made.variant.id) }
            #expect(variant?.workingText == "draft!")
            #expect(variant!.updatedAt > made.variant.updatedAt)
            #expect(try container(db, post.id).lastTouchedAt != nil)
        }
    }

    @Test func typoNeverStampsAMajorRevisionButARewriteDoes() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let text = String(repeating: "x", count: 500)
            // The mint itself crosses (500 against the fresh baseline 0 —
            // QUESTIONS #5 (a)): stamped, reset, rebaselined to 500.
            let made = try ops.newBlock(in: post.id, text: text)
            let afterMint = try container(db, post.id)
            let firstStamp = afterMint.lastMajorRevisionAt
            #expect(firstStamp != nil)
            #expect(afterMint.baselineLength == 500)
            #expect(afterMint.churnAccumulator == 0)

            // A typo against a 500-char baseline: touched, not restamped.
            try ops.autosave(made.variant.id, text: text + "z", charDelta: 2)
            let afterTypo = try container(db, post.id)
            #expect(afterTypo.lastMajorRevisionAt == firstStamp)
            #expect(afterTypo.churnAccumulator == 2)
            #expect(afterTypo.lastTouchedAt != nil)

            // A rewrite (≥ 80% of baseline) stamps, resets, rebaselines.
            let rewritten = String(repeating: "y", count: 300)
            try ops.autosave(made.variant.id, text: rewritten, charDelta: 500)
            let afterRewrite = try container(db, post.id)
            #expect(afterRewrite.lastMajorRevisionAt! > firstStamp!)
            #expect(afterRewrite.churnAccumulator == 0)
            #expect(afterRewrite.baselineLength == 300)
        }
    }

    @Test func autosaveOnAPoolBlockUpdatesThePoolStamps() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool()
            let made = try ops.newBlock(in: pool.id, text: "scrap")
            try ops.autosave(made.variant.id, text: "scrap+", charDelta: 1)
            #expect(try container(db, pool.id).lastTouchedAt != nil)
        }
    }

    @Test func autosaveOnAnUnplacedBlockSkipsContainerStampsQuietly() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "loose")
            let stampAtMint = try container(db, post.id).lastTouchedAt
            #expect(stampAtMint != nil)  // the mint stamped (QUESTIONS #5 (a))
            // Release the placement (divide-W leftovers look like this).
            try db.write { db in
                try Fixture.tombstone(db, table: "container_block", id: made.placement.id)
            }
            try ops.autosave(made.variant.id, text: "loose+", charDelta: 1)
            let variant = try db.read { db in try Variant.fetchOne(db, key: made.variant.id) }
            #expect(variant?.workingText == "loose+")
            // No live placement ⇒ no container to stamp: unchanged since the mint.
            #expect(try container(db, post.id).lastTouchedAt == stampAtMint)
        }
    }

    @Test func autosaveRefusalPaths() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "t")

            try db.write { db in
                try db.execute(sql: "UPDATE variant SET locked = 1 WHERE id = ?", arguments: [made.variant.id])
            }
            #expect(throws: OperationError.lockedVariant(id: made.variant.id)) {
                try ops.autosave(made.variant.id, text: "x", charDelta: 1)
            }
            try db.write { db in
                try db.execute(
                    sql: "UPDATE variant SET locked = 0, status = 'archived' WHERE id = ?",
                    arguments: [made.variant.id])
            }
            #expect(throws: OperationError.archivedVariant(id: made.variant.id)) {
                try ops.autosave(made.variant.id, text: "x", charDelta: 1)
            }
            try db.write { db in
                try db.execute(sql: "UPDATE variant SET status = 'active' WHERE id = ?", arguments: [made.variant.id])
                try db.execute(sql: "UPDATE container SET locked = 1 WHERE id = ?", arguments: [post.id])
            }
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.autosave(made.variant.id, text: "x", charDelta: 1)
            }

            #expect(throws: OperationError.variantNotFound(id: "ghost")) {
                try ops.autosave("ghost", text: "x", charDelta: 1)
            }
        }
    }

    // MARK: commit / restoreCommit

    @Test func commitsAppendAndOrderByCreatedAtThenId() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "v1")
            let first = try ops.commit(made.variant.id, message: "first")
            try ops.autosave(made.variant.id, text: "v2", charDelta: 2)
            let second = try ops.commit(made.variant.id)

            let ordered = try db.read { db in
                try String.fetchAll(
                    db,
                    sql: """
                        SELECT text FROM commit_point WHERE variant_id = ?
                        ORDER BY created_at, id
                        """,
                    arguments: [made.variant.id])
            }
            #expect(ordered == ["v1", "v2"])
            #expect(first.kind == .manual)
            #expect(first.message == "first")
            #expect(second.createdAt > first.createdAt)
        }
    }

    @Test func manualCommitStampsAMajorRevisionAutoDoesNot() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "text")
            // The mint crossed the fresh-baseline threshold (QUESTIONS #5
            // (a)); the point under test is what the COMMITS do to it.
            let stampAtMint = try container(db, post.id).lastMajorRevisionAt
            #expect(stampAtMint != nil)

            try ops.commit(made.variant.id, kind: .auto)
            #expect(try container(db, post.id).lastMajorRevisionAt == stampAtMint,
                    "auto commits are quiet insurance — never a major revision")

            try ops.commit(made.variant.id)
            let after = try container(db, post.id)
            #expect(after.lastMajorRevisionAt! > stampAtMint!,
                    "a manual commit stamps")
            #expect(after.churnAccumulator == 0)
            #expect(after.baselineLength == 4)
        }
    }

    @Test func commitRefusedOnLockedVariantOrLockedPost() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "t")

            try db.write { db in
                try db.execute(sql: "UPDATE variant SET locked = 1 WHERE id = ?", arguments: [made.variant.id])
            }
            #expect(throws: OperationError.lockedVariant(id: made.variant.id)) {
                try ops.commit(made.variant.id)
            }

            try db.write { db in
                try db.execute(sql: "UPDATE variant SET locked = 0 WHERE id = ?", arguments: [made.variant.id])
                try db.execute(sql: "UPDATE container SET locked = 1 WHERE id = ?", arguments: [post.id])
            }
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.commit(made.variant.id)
            }
        }
    }

    @Test func restoreCommitLoadsTextWithoutTouchingHistory() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "original")
            let saved = try ops.commit(made.variant.id)
            try ops.autosave(made.variant.id, text: "heavily rewritten", charDelta: 17)

            try ops.restoreCommit(made.variant.id, commitID: saved.id)

            let variant = try db.read { db in try Variant.fetchOne(db, key: made.variant.id) }
            #expect(variant?.workingText == "original")
            // I5: the restore appended nothing and removed nothing.
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [made.variant.id]) == 1)
        }
    }

    @Test func restoreCommitRejectsACommitOfAnotherVariant() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "a")
            let b = try ops.newBlock(in: post.id, text: "b")
            let commitB = try ops.commit(b.variant.id)
            #expect(throws: OperationError.commitNotFound(id: commitB.id)) {
                try ops.restoreCommit(a.variant.id, commitID: commitB.id)
            }
        }
    }

    // MARK: idleAutoCommit

    @Test func idleAutoCommitInsuresDirtyVariantsOnlyAndIsIdempotent() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let dirty = try ops.newBlock(in: post.id, text: "never committed")
            let clean = try ops.newBlock(in: post.id, text: "committed")
            try ops.commit(clean.variant.id)
            let empty = try ops.newBlock(in: post.id, text: "")

            let committed = try ops.idleAutoCommit(post.id)
            #expect(committed.count == 1)
            #expect(committed.first?.variantId == dirty.variant.id)
            #expect(committed.first?.kind == .auto)

            // Second call: nothing is dirty anymore.
            #expect(try ops.idleAutoCommit(post.id).isEmpty)

            // The empty, never-committed variant was never dirty.
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [empty.variant.id]) == 0)
        }
    }

    @Test func idleAutoCommitSkipsLockedVariantsAndRefusesLockedPosts() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "dirty but locked")
            try db.write { db in
                try db.execute(sql: "UPDATE variant SET locked = 1 WHERE id = ?", arguments: [made.variant.id])
            }
            #expect(try ops.idleAutoCommit(post.id).isEmpty)

            try db.write { db in
                try db.execute(sql: "UPDATE container SET locked = 1 WHERE id = ?", arguments: [post.id])
            }
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.idleAutoCommit(post.id)
            }
        }
    }

    // MARK: branch / blank take

    @Test func branchInheritsTextAndParentAndSitsAfterItsSource() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "the paragraph")

            let branch = try ops.branchVariant(made.block.id, from: made.variant.id)
            #expect(branch.workingText == "the paragraph")
            #expect(branch.parentVariantId == made.variant.id)
            #expect(try fanOrder(db, made.block.id) == [made.variant.id, branch.id])

            // Branching from the source again lands between source and the
            // earlier branch — beside its source, not at the fan's end.
            let second = try ops.branchVariant(made.block.id, from: made.variant.id)
            #expect(try fanOrder(db, made.block.id) == [made.variant.id, second.id, branch.id])
        }
    }

    @Test func blankVariantIsEmptyParentlessAndLandsAtTheFanEnd() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "take one")
            let branch = try ops.branchVariant(made.block.id, from: made.variant.id)

            let blank = try ops.newBlankVariant(made.block.id)
            #expect(blank.workingText == "")
            #expect(blank.parentVariantId == nil)
            #expect(try fanOrder(db, made.block.id) == [made.variant.id, branch.id, blank.id])
        }
    }

    @Test func branchRefusesAVariantOfADifferentBlock() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "a")
            let b = try ops.newBlock(in: post.id, text: "b")
            #expect(throws: OperationError.variantNotFound(id: b.variant.id)) {
                try ops.branchVariant(a.block.id, from: b.variant.id)
            }
        }
    }

    @Test func fanGrowthRefusedUnderALockedPost() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "sealed")
            try db.write { db in
                try db.execute(sql: "UPDATE container SET locked = 1 WHERE id = ?", arguments: [post.id])
            }
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.branchVariant(made.block.id, from: made.variant.id)
            }
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.newBlankVariant(made.block.id)
            }
        }
    }
}
