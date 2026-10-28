import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// **BRING A COMMIT BACK AS A TAKE** (VX-431, the VX-440 run — R-440-3; her
/// words on the ticket: *"offer 'bring back as a take' so a commit can be read
/// in the regular editor"*). The exact state transition, and the posture the
/// design binds it to: `branchVariant`'s, verified side by side here — no
/// touch, no churn, no undo entry, the seal refuses.
@Suite("Bring a commit back as a take (VX-431)")
struct BringBackCommitAsTakeTests {
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
        try db.read { db in try #require(try Container.fetchOne(db, key: id)) }
    }

    /// One block with a second take beside it, and a commit of the first take
    /// whose text differs from the buffer as it stands now.
    private struct World {
        let postID: String
        let blockID: String
        let take: String
        let sibling: String
        let commit: CommitPoint
    }

    private func world(_ ops: Operations, name: String? = "before the rewrite") throws -> World {
        let post = try ops.createPost(title: "the note", profile: .generic)
        let made = try ops.newBlock(in: post.id, text: "The words as they were.", at: .end)
        let commit = try ops.commit(made.variant.id, message: name)
        try ops.autosave(made.variant.id, text: "The words as they are now.", charDelta: 8)
        let sibling = try ops.branchVariant(made.block.id, from: made.variant.id)
        return World(
            postID: post.id, blockID: made.block.id, take: made.variant.id,
            sibling: sibling.id, commit: commit)
    }

    // MARK: - The transition

    @Test func theMomentBecomesANewTakeAtTheFansEndAndNothingElseMoves() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            let chosenBefore = try db.read { db in
                try Queries.renderPost(db, containerID: w.postID).first?.variantID
            }
            let commitsBefore = try db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM commit_point") ?? 0
            }

            let take = try ops.bringBackCommitAsTake(w.commit.id)

            #expect(take.workingText == "The words as they were.", "the moment's own words")
            #expect(take.parentVariantId == w.take, "it descends from the take it was saved from")
            #expect(take.blockId == w.blockID)
            #expect(take.status == .active)
            #expect(take.locked == false, "never born locked")
            #expect(take.label == "before the rewrite", "P-440-3: the moment's name labels it")
            #expect(try fanOrder(db, w.blockID) == [w.take, w.sibling, take.id],
                    "at the fan's END — after the branch that sits beside its source")

            // Nothing else moved: the source keeps its buffer, the chosen take
            // stays chosen, the moment stays (I5 — copied, never consumed).
            let source = try db.read { db in try #require(try Variant.fetchOne(db, key: w.take)) }
            #expect(source.workingText == "The words as they are now.")
            #expect(try db.read { db in
                try Queries.renderPost(db, containerID: w.postID).first?.variantID
            } == chosenBefore, "never chosen")
            #expect(try db.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM commit_point") ?? 0
            } == commitsBefore, "no commit is written, none consumed")
            #expect(try db.read { db in try CommitPoint.fetchOne(db, key: w.commit.id) } != nil)
            let block = try db.read { db in try #require(try Block.fetchOne(db, key: w.blockID)) }
            #expect(block.defaultVariantId == w.take, "the block's representative is unchanged")
        }
    }

    @Test func anUnnamedMomentBringsBackAnUnlabelledTake() throws {
        try withOperations { ops, _ in
            let w = try world(ops, name: nil)
            #expect(try ops.bringBackCommitAsTake(w.commit.id).label == nil)
        }
    }

    // MARK: - branchVariant's posture, side by side

    /// **No touch, no churn** — the two stamps a branch leaves alone, read
    /// after a branch and after a bring-back on the same note.
    @Test func itTouchesNothingAndChurnsNothingExactlyAsABranchDoes() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            let before = try container(db, w.postID)
            _ = try ops.branchVariant(w.blockID, from: w.take)
            let afterBranch = try container(db, w.postID)
            #expect(afterBranch.lastTouchedAt == before.lastTouchedAt, "fixture: a branch touches nothing")
            #expect(afterBranch.churnAccumulator == before.churnAccumulator)

            _ = try ops.bringBackCommitAsTake(w.commit.id)
            let after = try container(db, w.postID)
            #expect(after.lastTouchedAt == before.lastTouchedAt, "no touch stamp")
            #expect(after.lastMajorRevisionAt == before.lastMajorRevisionAt)
            #expect(after.churnAccumulator == before.churnAccumulator, "no churn")
            #expect(after.updatedAt == before.updatedAt, "the container row is not written")
        }
    }

    /// **No structural-undo entry** (PROVISIONAL P-440-4), as `branchVariant`
    /// registers none: the stack is exactly as deep after both.
    @Test func itRegistersNoUndoEntryExactlyAsABranchDoes() throws {
        try withOperations { _, _ in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            // The fixture's own mint registers ("New Block"); the depth is
            // read after it, so only the two acts under test are measured.
            let w = try world(ops)
            let depth = stack.depth
            _ = try ops.branchVariant(w.blockID, from: w.take)
            #expect(stack.depth == depth, "fixture: a branch registers nothing")
            _ = try ops.bringBackCommitAsTake(w.commit.id)
            #expect(stack.depth == depth, "nor does bringing a moment back")
        }
    }

    // MARK: - Refusals

    @Test func aSealedNoteRefuses() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            try ops.lockPost(w.postID)
            #expect(throws: OperationError.lockedPost(id: w.postID)) {
                try ops.bringBackCommitAsTake(w.commit.id)
            }
            #expect(try fanOrder(db, w.blockID).count == 2, "nothing minted")
        }
    }

    @Test func aDeletedTakesMomentRefuses() throws {
        try withOperations { ops, _ in
            let w = try world(ops)
            // A moment of the SIBLING, then the sibling deleted: Block History
            // lists only live takes' moments, and the op agrees.
            try ops.autosave(w.sibling, text: "A sibling's own words.", charDelta: 4)
            let siblings = try ops.commit(w.sibling)
            try ops.deleteVariant(w.sibling)
            #expect(throws: OperationError.variantNotFound(id: w.sibling)) {
                try ops.bringBackCommitAsTake(siblings.id)
            }
        }
    }

    @Test func aDeletedBlockRefuses() throws {
        try withOperations { ops, _ in
            let w = try world(ops)
            try ops.deleteBlock(w.blockID)
            #expect(throws: OperationError.blockNotFound(id: w.blockID)) {
                try ops.bringBackCommitAsTake(w.commit.id)
            }
        }
    }

    @Test func anUnknownCommitRefuses() throws {
        try withOperations { ops, _ in
            #expect(throws: OperationError.commitNotFound(id: "no-such-moment")) {
                try ops.bringBackCommitAsTake("no-such-moment")
            }
        }
    }

    /// The source is only READ, so a locked or archived take's moment comes
    /// back like any other — `branchVariant`'s own allowance.
    @Test func aLockedOrArchivedSourceStillBringsItsMomentBack() throws {
        try withOperations { ops, _ in
            let w = try world(ops)
            try ops.lockVariant(w.take)
            #expect(try ops.bringBackCommitAsTake(w.commit.id).workingText
                == "The words as they were.")
            try ops.unlockVariant(w.take)
            try ops.archiveVariant(w.take)
            #expect(try ops.bringBackCommitAsTake(w.commit.id).parentVariantId == w.take)
        }
    }
}
