import Foundation
import GRDB
import Testing
@testable import VariorumCore

//
//  RecoveryOpsTests.swift
//  VariorumCoreTests
//
//  Phase 13j, batch 3 — the core half of the recovery doors:
//
//  · **`restoreVariant`** (the sitting's round-5 ruling: *"YES — the FULL
//    uniform story"*). A deleted take had NO door anywhere in the app and no
//    op to open one; this is the op, in the recovery-door class — a tombstone
//    flip with no undo entry, because the door IS the recovery.
//
//  · **`restoreBlock`'s PLACEMENT** (the architect's F2 ruling, PROVISIONAL at
//    QUESTIONS #67 F2). Batch 2 verified the shipped op minted a FRESH
//    placement at the note's end, which meant Put back and ⌥⌘Z — two doors on
//    one gesture — landed a block in two different places. It now flips the
//    row that deletion took down, and falls back to fresh-at-end only where
//    no such row exists.
//
//  · The three READ sides the faces stand on: `deletedTakes`, the per-block
//    `unplacedOrigins`, and `danglingLensPicks` (J5).
//

@Suite("Recovery doors — restoreVariant, restoreBlock's placement, the reads (13j)")
struct RecoveryOpsTests {
    // MARK: - restoreVariant: the exact-row flip

    /// **The exactness claim, as a whole-row comparison.** A recovery door
    /// that re-minted would give her back a take with a new id, a new place
    /// in the fan and no savepoints; this is a tombstone flip, so every
    /// column comes back as it was.
    @Test func restoreVariantFlipsTheTombstoneAndKeepsEveryColumn() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "the one it shows")
            let second = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.setTakeLabel(second.id, label: "bolder opening")
            _ = try ops.commit(second.id, kind: .manual, message: "saved")

            let before = try #require(try db.snapshotRow("variant", second.id))
            try ops.deleteVariant(second.id)
            #expect(try db.deletedAt("variant", second.id) != nil)

            try ops.restoreVariant(second.id)
            let after = try #require(try db.snapshotRow("variant", second.id))
            #expect(after == before, "every column back, tombstone included")

            // …and its savepoints are reachable again (commit_point never
            // carried a tombstone — AppSpec §14 item 4 — so this is a claim
            // about REACHABILITY, which is what a restore actually buys).
            let history = try db.read { try Queries.commitHistory($0, variantID: second.id) }
            #expect(history.map(\.message) == ["saved"])
        }
    }

    /// An ARCHIVED take that was then deleted comes back ARCHIVED. Exactness
    /// again, and it matters: guessing `active` would put a take she had
    /// deliberately set aside back into the fan.
    @Test func restoreVariantReturnsAnArchivedTakeArchived() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "shown")
            let second = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.archiveVariant(second.id)
            try ops.deleteVariant(second.id)

            try ops.restoreVariant(second.id)
            let status = try db.fetchString(
                "SELECT status FROM variant WHERE id = ?", [second.id])
            #expect(status == VariantStatus.archived.rawValue)
        }
    }

    /// **The default pointer is deliberately NOT re-pointed.** `deleteVariant`
    /// captured `wasDefault` at do-time so its UNDO could put the pointer
    /// back; a recovery door has no such memory, and guessing would move a
    /// pointer she has since set by hand.
    @Test func restoreVariantLeavesTheBlockDefaultWhereItNowPoints() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "first")
            let second = try ops.branchVariant(made.block.id, from: made.variant.id)
            // Re-point the slot so the default take can legally be deleted.
            try ops.chooseVariant(made.block.id, variantID: second.id)
            try ops.deleteVariant(made.variant.id)
            let reassigned = try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?", [made.block.id])
            #expect(reassigned == second.id)

            try ops.restoreVariant(made.variant.id)
            #expect(try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?", [made.block.id])
                == second.id, "the pointer stays where the delete left it")
        }
    }

    // MARK: - restoreVariant: the refusal set

    @Test func restoreVariantRefusesALiveTake() throws {
        try withOperations { ops, _ in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "alive")
            #expect(throws: OperationError.variantNotDeleted(id: made.variant.id)) {
                try ops.restoreVariant(made.variant.id)
            }
        }
    }

    /// A take under a DEAD block refuses — the road is to restore the block,
    /// which revives its stamp-matched takes for free. Restoring the take
    /// alone would strand a live variant under a tombstoned block.
    @Test func restoreVariantRefusesUnderADeadBlock() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            _ = try ops.newBlock(in: post.id, text: "keeper")
            let made = try ops.newBlock(in: post.id, text: "doomed")
            let second = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.deleteVariant(second.id)
            try ops.deleteBlock(made.block.id)

            #expect(throws: OperationError.blockNotFound(id: made.block.id)) {
                try ops.restoreVariant(second.id)
            }
            // …and the block's own door works, leaving the independently
            // deleted take exactly as dead as it was (different stamp).
            try ops.restoreBlock(made.block.id)
            #expect(try db.deletedAt("variant", second.id) != nil)
            try ops.restoreVariant(second.id)
            #expect(try db.deletedAt("variant", second.id) == nil)
        }
    }

    @Test func restoreVariantRefusesUnderASealedNote() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "shown")
            let second = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.deleteVariant(second.id)
            try ops.lockPost(post.id)

            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.restoreVariant(second.id)
            }
            #expect(try db.deletedAt("variant", second.id) != nil)
        }
    }

    /// **The recovery-door class: NO undo entry** (`restoreBlock` /
    /// `restoreSection` / `restoreBlockComment` — the door IS the recovery,
    /// and an entry whose inverse is "delete it again" would be a second way
    /// to lose exactly the thing this door exists to find).
    @Test func restoreVariantRegistersNoUndoEntry() throws {
        try withOperations { _, _ in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "shown")
            let second = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.deleteVariant(second.id)
            let depth = stack.depth

            try ops.restoreVariant(second.id)
            #expect(stack.depth == depth, "the door is the recovery")
        }
    }

    /// The flip reaches the outbox like every other write (the triggers do
    /// it; asserting it is what keeps a future refactor honest).
    @Test func restoreVariantEnqueuesTheTakeForSync() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "shown")
            let second = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.deleteVariant(second.id)
            try db.clearOutbox()

            try ops.restoreVariant(second.id)
            #expect(try db.outboxContains("variant", second.id))
        }
    }

    // MARK: - restoreBlock's placement (the F2 rider)

    /// **The ruling's whole point.** The middle block of three comes back
    /// BETWEEN its neighbours, on the SAME placement row — exact-row, like
    /// every other member of the restore family.
    @Test func restoreBlockRevivesTheExactPlacementRow() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let first = try ops.newBlock(in: post.id, text: "First.")
            let middle = try ops.newBlock(in: post.id, text: "Second.")
            let last = try ops.newBlock(in: post.id, text: "Third.")
            let placementRow = try #require(
                try db.snapshotRow("container_block", middle.placement.id))

            try ops.deleteBlock(middle.block.id)
            let landing = try ops.restoreBlock(middle.block.id)
            #expect(landing == .itsOldPlace)

            let order = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(order.map(\.blockID)
                == [first.block.id, middle.block.id, last.block.id],
                "back between its neighbours, not appended")
            #expect(order.map(\.placementID)
                == [first.placement.id, middle.placement.id, last.placement.id],
                "the SAME row, revived — no fresh placement was minted")
            #expect(try db.snapshotRow("container_block", middle.placement.id) == placementRow,
                    "position and chosen variant intact")
        }
    }

    /// **Put back and ⌥⌘Z now land in the same spot** — which is the divergence
    /// the F2 ruling closed. Two runs of one deletion, one reversed each way.
    @Test func putBackAndStructuralUndoLandTheBlockInTheSameSpot() throws {
        func orderAfter(_ reverse: (Operations, String) throws -> Void) throws -> [String] {
            try withOperations { _, db in
                let stack = UndoStack()
                let ops = Operations(undoStack: stack)
                let post = try ops.createPost()
                _ = try ops.newBlock(in: post.id, text: "First.")
                let middle = try ops.newBlock(in: post.id, text: "Second.")
                _ = try ops.newBlock(in: post.id, text: "Third.")
                try ops.deleteBlock(middle.block.id)
                try reverse(ops, middle.block.id)
                return try db.read { try Queries.renderPost($0, containerID: post.id) }
                    .map(\.text).compactMap { $0 }
            }
        }
        let viaUndo = try orderAfter { ops, _ in
            _ = try ops.undoStack?.undo(with: ops)
        }
        let viaTray = try orderAfter { ops, blockID in
            try ops.restoreBlock(blockID)
        }
        #expect(viaUndo == ["First.", "Second.", "Third."])
        #expect(viaTray == viaUndo, "one gesture, two doors, one landing")
    }

    /// **The fallback, and why it exists.** A divide-W releases A by
    /// tombstoning its placement at RELEASE time; deleting A later finds no
    /// live placement to stamp, so nothing carries the block's own tombstone
    /// and there is genuinely no row to revive. It lands at the end, and the
    /// op says so, so the receipt can too.
    @Test func restoreBlockFallsBackToTheEndWithNoRevivableRow() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "Alpha one. Beta one.")
            let second = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.autosave(second.id, text: "Alpha two. Beta two.", charDelta: 0)
            _ = try ops.divideW(made.block.id, cuts: [made.variant.id: 10, second.id: 10])
            try ops.deleteBlock(made.block.id)

            let landing = try ops.restoreBlock(made.block.id)
            #expect(landing == .endOfNote)
            let order = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(order.last?.blockID == made.block.id)
        }
    }

    /// No live home at all: the block comes back alive and unplaced rather
    /// than throwing — the shipped behaviour, now named.
    @Test func restoreBlockReturnsUnplacedWhenTheNoteIsGone() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "orphan")
            try ops.deleteBlock(made.block.id)
            try ops.deleteContainer(post.id)

            let landing = try ops.restoreBlock(made.block.id)
            #expect(landing == .unplaced)
            #expect(try db.deletedAt("block", made.block.id) == nil)
            #expect(try db.read { try Queries.unplacedBlocks($0) }.map(\.blockID)
                == [made.block.id])
        }
    }

    /// The seal refuses on the REVIVE road exactly as it did on the mint road
    /// — and the whole transaction rolls back, so the block does not come
    /// back live-but-unplaced under a sealed note.
    @Test func restoreBlockRefusesUnderASealedNoteOnTheReviveRoad() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            _ = try ops.newBlock(in: post.id, text: "keeper")
            let made = try ops.newBlock(in: post.id, text: "doomed")
            try ops.deleteBlock(made.block.id)
            try ops.lockPost(post.id)

            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.restoreBlock(made.block.id)
            }
            #expect(try db.deletedAt("block", made.block.id) != nil,
                    "the whole transaction rolled back")
        }
    }

    /// A block deleted TWICE (restored in between) revives the row the SECOND
    /// deletion took down — the stamp match, not "any tombstoned row for this
    /// pair", which would be a lottery among the block's whole history here.
    @Test func restoreBlockRevivesTheRowThisDeletionTookDown() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let first = try ops.newBlock(in: post.id, text: "First.")
            let middle = try ops.newBlock(in: post.id, text: "Second.")
            let last = try ops.newBlock(in: post.id, text: "Third.")

            try ops.deleteBlock(middle.block.id)
            #expect(try ops.restoreBlock(middle.block.id) == .itsOldPlace)
            try ops.reorder(middle.block.id, to: .end)
            try ops.deleteBlock(middle.block.id)
            #expect(try ops.restoreBlock(middle.block.id) == .itsOldPlace)

            let order = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(order.map(\.blockID)
                == [first.block.id, last.block.id, middle.block.id],
                "back where THIS deletion found it — at the end, where she moved it")
        }
    }

    // MARK: - The reads the faces stand on

    @Test func deletedTakesListsTombstonesNewestFirst() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "shown")
            let second = try ops.branchVariant(made.block.id, from: made.variant.id)
            let third = try ops.branchVariant(made.block.id, from: made.variant.id)
            let kept = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.deleteVariant(second.id)
            try ops.deleteVariant(third.id)

            let listing = try db.read { try Queries.deletedTakes($0, blockID: made.block.id) }
            #expect(listing.map(\.id) == [third.id, second.id], "newest tombstone first")
            #expect(!listing.map(\.id).contains(kept.id))
            #expect(!listing.map(\.id).contains(made.variant.id))
        }
    }

    /// The per-block origin read carries the ACT and the DATE — what the
    /// ruled door row and the History face's lineage row say.
    @Test func unplacedOriginsOfABlockCarriesTheActAndTheDate() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "Alpha one. Beta one.")
            let second = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.autosave(second.id, text: "Alpha two. Beta two.", charDelta: 0)
            let w = try ops.divideW(made.block.id, cuts: [made.variant.id: 10, second.id: 10])

            let origins = try db.read {
                try Queries.unplacedOrigins($0, ofBlock: w.second.block.id)
            }
            #expect(origins.map(\.blockID) == [made.block.id])
            #expect(origins.first?.originOp == "divide")
            #expect(DateFormatter.variorumISO8601.date(from: origins.first?.at ?? "") != nil,
                    "a canonical stamp the face can format")

            // …and the container-scoped read agrees with it, block for block.
            let byBlock = try db.read { try Queries.unplacedOrigins($0, inContainer: post.id) }
            #expect(byBlock[w.second.block.id] == origins)
        }
    }

    /// A PLAIN divide leaves A on the page, so its successor has an edge and
    /// no origin — the placement question, not the lineage one (the W10b
    /// claim, restated against the per-block read).
    @Test func aPlainDividesSuccessorHasNoUnplacedOrigin() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "Alpha one. Beta one.")
            let minted = try ops.divide(made.block.id, cut: 10)
            #expect(try db.read {
                try Queries.unplacedOrigins($0, ofBlock: minted.block.id)
            }.isEmpty)
        }
    }

    // MARK: - J5: the dangling lens pick

    @Test func danglingLensPicksNamesEachStateAndSkipsTheHealthyOnes() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let healthy = try ops.newBlock(in: post.id, text: "one")
            let archivedOn = try ops.newBlock(in: post.id, text: "two")
            let deletedOn = try ops.newBlock(in: post.id, text: "three")
            let foreignOn = try ops.newBlock(in: post.id, text: "four")

            let healthyTake = try ops.branchVariant(healthy.block.id, from: healthy.variant.id)
            let archivedTake = try ops.branchVariant(
                archivedOn.block.id, from: archivedOn.variant.id)
            let deletedTake = try ops.branchVariant(
                deletedOn.block.id, from: deletedOn.variant.id)

            let lens = try ops.createLens(post: post.id, name: "thread")
            _ = try ops.setLensChoice(lens: lens.id, block: healthy.block.id, variant: healthyTake.id)
            _ = try ops.setLensChoice(
                lens: lens.id, block: archivedOn.block.id, variant: archivedTake.id)
            _ = try ops.setLensChoice(
                lens: lens.id, block: deletedOn.block.id, variant: deletedTake.id)
            // A FOREIGN pick: another block's take. Written as a ROW rather
            // than through the door, because the operations layer refuses it
            // (`variantNotFound`) — which is the point: this state is only
            // reachable through a sync arrival, exactly the race
            // `effectiveLensSelection`'s join was written to guard against.
            try db.write { db in
                try LensChoice(
                    id: "foreign-pick", lensId: lens.id, blockId: foreignOn.block.id,
                    variantId: healthyTake.id,
                    createdAt: Date(timeIntervalSince1970: 1_782_864_000),
                    updatedAt: Date(timeIntervalSince1970: 1_782_864_000)).insert(db)
            }

            try ops.archiveVariant(archivedTake.id)
            try ops.deleteVariant(deletedTake.id)

            let dangling = try db.read { try Queries.danglingLensPicks($0, lens: lens.id) }
            #expect(dangling[healthy.block.id] == nil, "a healthy pick is not a dangle")
            #expect(dangling[archivedOn.block.id]
                == Queries.DanglingPick(variantID: archivedTake.id, state: .archived))
            #expect(dangling[deletedOn.block.id]
                == Queries.DanglingPick(variantID: deletedTake.id, state: .deleted))
            #expect(dangling[foreignOn.block.id]?.state == .foreign)

            // The two sets are exactly complementary — every stored pick is
            // either effective or explained.
            let effective = try db.read {
                try Queries.effectiveLensSelection($0, lens: lens.id)
            }
            let raw = try db.read { try Queries.lensChoices($0, lens: lens.id) }
            #expect(Set(effective.keys).union(dangling.keys) == Set(raw.keys))
            #expect(Set(effective.keys).intersection(dangling.keys).isEmpty)
        }
    }

    /// Restoring the dangling take is what makes the notice's button honest:
    /// the pick resolves again, untouched — the lens row was never rewritten.
    @Test func restoringADeletedPickMakesTheLensShowItAgain() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let made = try ops.newBlock(in: post.id, text: "one")
            let take = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.autosave(take.id, text: "the lens's take", charDelta: 0)
            let lens = try ops.createLens(post: post.id, name: "thread")
            _ = try ops.setLensChoice(lens: lens.id, block: made.block.id, variant: take.id)
            try ops.deleteVariant(take.id)

            #expect(try db.read {
                try Queries.effectiveLensSelection($0, lens: lens.id)
            }.isEmpty)
            try ops.restoreVariant(take.id)
            #expect(try db.read {
                try Queries.effectiveLensSelection($0, lens: lens.id)
            }[made.block.id] == take.id)
            #expect(try db.read {
                try Queries.danglingLensPicks($0, lens: lens.id)
            }.isEmpty)
        }
    }
}
