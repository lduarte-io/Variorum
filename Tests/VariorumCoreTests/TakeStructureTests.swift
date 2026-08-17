import Foundation
import GRDB
import Testing
@testable import VariorumCore

// Phase 13e, batch 3 — take↔block structure (E5: her A20, *"shortcut for
// moving a take into being a new block beneath the current block"*; E6: her
// A21, *"keyboard shortcut for copying all takes together to clipboard, or
// turning all takes into their own blocks"* — the A45 repair tool).
//
// This file holds the CORE half. The clipboard suite pins `Queries.blockTakes`
// — the projection E6's clipboard door copies — against the ratified export
// shape it must never diverge from: ONE rule for "which takes count", so the
// door's confirmation and the copied text can never disagree.

// MARK: - E5 / E6b: the take↔block operations (architect ruling AR-1)

/// A post with one three-take block: V1 (default + chosen, "One."), V2
/// branched ("Two."), V3 blank at the fan's end ("Three.").
private struct FanWorld {
    let post: Container
    let a: Operations.NewBlockResult
    let v2: Variant
    let v3: Variant

    init(_ ops: Operations) throws {
        post = try ops.createPost()
        a = try ops.newBlock(in: post.id, text: "One.")
        v2 = try ops.branchVariant(a.block.id, from: a.variant.id)
        try ops.autosave(v2.id, text: "Two.", charDelta: 0)
        v3 = try ops.newBlankVariant(a.block.id)
        try ops.autosave(v3.id, text: "Three.", charDelta: 0)
    }
}

private func blockOrder(_ db: AppDatabase, _ postID: String) throws -> [String] {
    try db.read { try Queries.renderPost($0, containerID: postID).map(\.blockID) }
}

private func renderedTexts(_ db: AppDatabase, _ postID: String) throws -> [String?] {
    try db.read { try Queries.renderPost($0, containerID: postID).map(\.text) }
}

private func fanIDs(_ db: AppDatabase, _ blockID: String) throws -> [String] {
    try db.read { try Queries.blockFan($0, blockID: blockID).map(\.id) }
}

private func status(_ db: AppDatabase, _ variantID: String) throws -> String? {
    try db.fetchString("SELECT status FROM variant WHERE id = ?", [variantID])
}

@Suite("A take becomes the block below (13e E5, A20)")
struct TakeToBlockBelowTests {
    @Test func theTakeMintsTheBlockBelowAndTheOriginalIsArchivedInPlace() throws {
        try withOperations { ops, db in
            let world = try FanWorld(ops)
            let result = try ops.takeToBlockBelow(world.a.block.id, variantID: world.v2.id)

            // The mint stands IMMEDIATELY below its source.
            #expect(try blockOrder(db, world.post.id) == [world.a.block.id, result.block.id])
            #expect(result.variant.workingText == "Two.")
            // AR-1: the source take is ARCHIVED, never moved and never deleted
            // — it stays on its own block with its commits reachable.
            #expect(try status(db, world.v2.id) == "archived")
            #expect(try db.deletedAt("variant", world.v2.id) == nil)
            #expect(try fanIDs(db, world.a.block.id)
                == [world.a.variant.id, world.v2.id, world.v3.id])
            // Lineage: the new block descends from the block it came out of,
            // stamped with an EXISTING origin_op value.
            #expect(result.edge.sourceBlockId == result.block.id)
            #expect(result.edge.targetBlockId == world.a.block.id)
            #expect(result.edge.originOp == "manual")
            #expect(result.archivedVariantID == world.v2.id)
        }
    }

    @Test func theCopyCarriesTheLabelButNeitherCommitsNorTheLock() throws {
        try withOperations { ops, db in
            let world = try FanWorld(ops)
            try ops.setTakeLabel(world.v2.id, label: "bolder")
            _ = try ops.commit(world.v2.id, message: "before the move")
            try ops.lockVariant(world.v2.id)

            let result = try ops.takeToBlockBelow(world.a.block.id, variantID: world.v2.id)

            #expect(result.variant.label == "bolder")           // the name rides
            #expect(result.variant.locked == false)             // the copy doctrine
            let copiedCommits = try db.fetchInt(
                "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [result.variant.id])
            #expect(copiedCommits == 0)                         // commits are never copied
            let sourceCommits = try db.fetchInt(
                "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [world.v2.id])
            #expect(sourceCommits == 1)                         // they stay with the take
            // A LOCKED take is permitted because `archiveVariant` permits one
            // today (AR-1(b): follow that door exactly), and the archived
            // original keeps its lock.
            #expect(try db.fetchInt(
                "SELECT locked FROM variant WHERE id = ?", [world.v2.id]) == 1)
        }
    }

    @Test func movingTheSHOWNTakeLeavesTheBlockRenderingItsDefaultInstead() throws {
        try withOperations { ops, db in
            let world = try FanWorld(ops)
            // V1 is chosen AND default: moving it archives it, and the
            // read-time fallback plus the default reassignment take over —
            // exactly `archiveVariant`'s ratified behaviour.
            let result = try ops.takeToBlockBelow(
                world.a.block.id, variantID: world.a.variant.id)

            #expect(try status(db, world.a.variant.id) == "archived")
            let defaultID = try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?", [world.a.block.id])
            #expect(defaultID != world.a.variant.id)
            #expect([world.v2.id, world.v3.id].contains(defaultID ?? ""))
            // The slot's chosen pointer is deliberately untouched (AppSpec §7's
            // fallback covers it), and the note still reads two live blocks.
            #expect(try db.fetchString(
                "SELECT chosen_variant_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                [world.a.block.id]) == world.a.variant.id)
            #expect(try renderedTexts(db, world.post.id).count == 2)
            #expect(try renderedTexts(db, world.post.id).last == "One.")
            _ = result
        }
    }

    @Test func presentationIsInheritedAndCommentsAreCopiedNotMoved() throws {
        try withOperations { ops, db in
            let world = try FanWorld(ops)
            try ops.setBlockPresentation(
                world.a.block.id,
                BlockPresentation(kind: BlockPresentation.calloutKind, color: "sand"))
            _ = try ops.addBlockComment(to: world.a.block.id, text: "keep an eye on this")

            let result = try ops.takeToBlockBelow(world.a.block.id, variantID: world.v2.id)

            let sourceFrame = try db.fetchString(
                "SELECT presentation FROM block WHERE id = ?", [world.a.block.id])
            #expect(result.block.presentation == sourceFrame)
            let sourceComments = try db.fetchInt(
                "SELECT COUNT(*) FROM block_comment WHERE block_id = ? AND deleted_at IS NULL",
                [world.a.block.id])
            let copiedComments = try db.fetchInt(
                "SELECT COUNT(*) FROM block_comment WHERE block_id = ? AND deleted_at IS NULL",
                [result.block.id])
            #expect(sourceComments == 1)   // the source keeps its own
            #expect(copiedComments == 1)   // the successor gets a copy
        }
    }

    @Test func theNoteIsTouchedButNeverChurned() throws {
        try withOperations { ops, db in
            let world = try FanWorld(ops)
            let before = try db.read { db in
                try Container.fetchOne(db, key: world.post.id)
            }
            try ops.takeToBlockBelow(world.a.block.id, variantID: world.v2.id)
            let after = try db.read { db in try Container.fetchOne(db, key: world.post.id) }

            #expect(after?.lastTouchedAt != before?.lastTouchedAt)
            #expect(after?.churnAccumulator == before?.churnAccumulator)
            #expect(after?.lastMajorRevisionAt == before?.lastMajorRevisionAt)
        }
    }

    @Test func theRefusalsAreI10TheBlankTakeTheSealAndAForeignTake() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let lone = try ops.newBlock(in: post.id, text: "The only take.")
            // I10: a take moves out when there is another left behind.
            #expect(throws: OperationError.lastActiveVariant(id: lone.variant.id)) {
                try ops.takeToBlockBelow(lone.block.id, variantID: lone.variant.id)
            }
            #expect(try blockOrder(db, post.id) == [lone.block.id])

            // A blank take has nothing to become (AR-1(d)).
            let blank = try ops.newBlankVariant(lone.block.id)
            #expect(throws: OperationError.emptyTakeCannotBecomeABlock(variantID: blank.id)) {
                try ops.takeToBlockBelow(lone.block.id, variantID: blank.id)
            }

            // A take of ANOTHER block is not among this block's takes.
            let other = try ops.newBlock(in: post.id, text: "Elsewhere.")
            #expect(throws: OperationError.variantNotFound(id: other.variant.id)) {
                try ops.takeToBlockBelow(lone.block.id, variantID: other.variant.id)
            }

            // An archived take of the RIGHT block diagnoses precisely.
            try ops.autosave(blank.id, text: "Filled in.", charDelta: 0)
            try ops.archiveVariant(blank.id)
            #expect(throws: OperationError.archivedVariant(id: blank.id)) {
                try ops.takeToBlockBelow(lone.block.id, variantID: blank.id)
            }

            // The seal refuses everything under the post.
            try ops.unarchiveVariant(blank.id)
            try ops.lockPost(post.id)
            #expect(throws: OperationError.lockedPost(id: post.id)) {
                try ops.takeToBlockBelow(lone.block.id, variantID: blank.id)
            }
            #expect(try blockOrder(db, post.id) == [lone.block.id, other.block.id])
        }
    }

    @Test func undoRestoresTheFanAndRedoLandsTheExactRowsAgain() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let world = try FanWorld(ops)
            let result = try ops.takeToBlockBelow(world.a.block.id, variantID: world.v2.id)
            #expect(stack.depth == 1)
            #expect(stack.topLabel == "Move Take into a Block")

            #expect(try stack.undo(with: ops) == "Move Take into a Block")
            // The mint is gone and the take is back in the fan, ACTIVE.
            #expect(try blockOrder(db, world.post.id) == [world.a.block.id])
            #expect(try status(db, world.v2.id) == "active")
            #expect(try db.deletedAt("block", result.block.id) != nil)

            #expect(try stack.redo(with: ops) == "Move Take into a Block")
            // Exact rows: the SAME block and variant ids come back.
            #expect(try blockOrder(db, world.post.id) == [world.a.block.id, result.block.id])
            #expect(try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [result.variant.id]) == "Two.")
            #expect(try status(db, world.v2.id) == "archived")

            // …and again, from the same captured pre-images.
            #expect(try stack.undo(with: ops) == "Move Take into a Block")
            #expect(try status(db, world.v2.id) == "active")
            #expect(try blockOrder(db, world.post.id) == [world.a.block.id])
        }
    }

    @Test func undoPutsTheDefaultBackWhenTheMovedTakeHadBeenIt() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let world = try FanWorld(ops)
            try ops.takeToBlockBelow(world.a.block.id, variantID: world.a.variant.id)
            #expect(try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?",
                [world.a.block.id]) != world.a.variant.id)

            _ = try stack.undo(with: ops)
            #expect(try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?",
                [world.a.block.id]) == world.a.variant.id)
        }
    }
}

@Suite("The whole fan becomes blocks (13e E6b, A21 — the A45 repair)")
struct TakesToBlocksTests {
    @Test func theShownTakeStaysAndTheAlternatesBecomeBlocksInFanOrder() throws {
        try withOperations { ops, db in
            let world = try FanWorld(ops)
            let result = try ops.takesToBlocks(world.a.block.id)

            // AR-1(c): the note reads the same first block, then the
            // alternates in fan order — the clipboard door's own order.
            #expect(result.keptVariantID == world.a.variant.id)
            #expect(result.converted.map(\.sourceVariantID) == [world.v2.id, world.v3.id])
            #expect(try blockOrder(db, world.post.id)
                == [world.a.block.id] + result.converted.map(\.block.id))
            #expect(try renderedTexts(db, world.post.id) == ["One.", "Two.", "Three."])
            // Every converted take is archived on the block it came from —
            // nothing moved, nothing died.
            #expect(try status(db, world.v2.id) == "archived")
            #expect(try status(db, world.v3.id) == "archived")
            #expect(try status(db, world.a.variant.id) == "active")
            #expect(result.skippedBlankTakes == 0)
        }
    }

    @Test func theTakeThatSTAYSIsTheONESHOWNEvenWhenItIsNotFirstInTheFan() throws {
        try withOperations { ops, db in
            let world = try FanWorld(ops)
            try ops.chooseVariant(world.a.block.id, variantID: world.v2.id)

            let result = try ops.takesToBlocks(world.a.block.id)

            #expect(result.keptVariantID == world.v2.id)
            #expect(result.converted.map(\.sourceVariantID) == [world.a.variant.id, world.v3.id])
            // What the note READS as is unchanged at the source block, and the
            // rest follow in fan order.
            #expect(try renderedTexts(db, world.post.id) == ["Two.", "One.", "Three."])
        }
    }

    @Test func blankTakesAreSkippedAndCountedAndArchivedTakesRideNowhere() throws {
        try withOperations { ops, db in
            let world = try FanWorld(ops)
            let blank = try ops.newBlankVariant(world.a.block.id)      // AR-1(d)
            let archived = try ops.branchVariant(world.a.block.id, from: world.a.variant.id)
            try ops.autosave(archived.id, text: "Set aside.", charDelta: 0)
            try ops.archiveVariant(archived.id)                        // AR-1(f)

            let result = try ops.takesToBlocks(world.a.block.id)

            #expect(result.converted.map(\.sourceVariantID) == [world.v2.id, world.v3.id])
            #expect(result.skippedBlankTakes == 1)
            // The blank take is untouched — still ACTIVE, still in the fan.
            #expect(try status(db, blank.id) == "active")
            // The archived take rides nowhere and stays where it was.
            #expect(try status(db, archived.id) == "archived")
            #expect(try blockOrder(db, world.post.id).count == 3)
        }
    }

    @Test func aBlockWithNoOtherTakesWithProseRefusesAndMintsNothing() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let lone = try ops.newBlock(in: post.id, text: "Just me.")
            #expect(throws: OperationError.noConvertibleTakes(blockID: lone.block.id)) {
                try ops.takesToBlocks(lone.block.id)
            }
            // A fan of blanks is the same answer — minting empty blocks
            // serves nobody (AR-1(d)).
            _ = try ops.newBlankVariant(lone.block.id)
            #expect(throws: OperationError.noConvertibleTakes(blockID: lone.block.id)) {
                try ops.takesToBlocks(lone.block.id)
            }
            #expect(try blockOrder(db, post.id) == [lone.block.id])
        }
    }

    @Test func aSealedNoteRefusesTheWholeConversion() throws {
        try withOperations { ops, db in
            let world = try FanWorld(ops)
            try ops.lockPost(world.post.id)
            #expect(throws: OperationError.lockedPost(id: world.post.id)) {
                try ops.takesToBlocks(world.a.block.id)
            }
            #expect(try blockOrder(db, world.post.id) == [world.a.block.id])
            #expect(try status(db, world.v2.id) == "active")
        }
    }

    @Test func oneUndoEntryReturnsTheWholeFanAndRedoRebuildsTheExactRun() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let world = try FanWorld(ops)
            let result = try ops.takesToBlocks(world.a.block.id)
            #expect(stack.depth == 1)                  // ONE entry for the run
            #expect(stack.topLabel == "Turn Takes into Blocks")

            #expect(try stack.undo(with: ops) == "Turn Takes into Blocks")
            #expect(try blockOrder(db, world.post.id) == [world.a.block.id])
            #expect(try fanIDs(db, world.a.block.id)
                == [world.a.variant.id, world.v2.id, world.v3.id])
            #expect(try status(db, world.v2.id) == "active")
            #expect(try status(db, world.v3.id) == "active")

            #expect(try stack.redo(with: ops) == "Turn Takes into Blocks")
            #expect(try blockOrder(db, world.post.id)
                == [world.a.block.id] + result.converted.map(\.block.id))
            #expect(try renderedTexts(db, world.post.id) == ["One.", "Two.", "Three."])
            #expect(try status(db, world.v3.id) == "archived")
        }
    }
}

@Suite("The clipboard projection (13e E6, A21's clipboard half)")
struct BlockTakesProjectionTests {
    @Test func aLoneTakeIsOneTakeAndTheTextIsJustItsProse() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let block = try ops.newBlock(in: post.id, text: "Only take.")
            let copy = try db.read { try Queries.blockTakes($0, blockID: block.block.id) }
            #expect(copy.markdown == "Only take.")
            #expect(copy.takeCount == 1)
        }
    }

    @Test func theProjectionIsExportBlocksOwnBytes() throws {
        // The one-rule claim, as an equality: `exportBlock` DELEGATES here, so
        // a future change to either cannot silently give the clipboard a
        // different shape than the export she already knows.
        try withOperations { ops, db in
            let post = try ops.createPost()
            let block = try ops.newBlock(in: post.id, text: "Shown take.")
            let second = try ops.branchVariant(block.block.id, from: block.variant.id)
            try ops.autosave(second.id, text: "Second take.", charDelta: 0)
            try ops.setTakeLabel(second.id, label: "bolder")

            let (markdown, count) = try db.read {
                try Queries.blockTakes($0, blockID: block.block.id)
            }
            let exported = try db.read { try Queries.exportBlock($0, blockID: block.block.id) }
            #expect(markdown == exported)
            #expect(count == 2)
            // The ratified fan shape: the shown take, then the labeled
            // alternates section (`take: "<label>"`).
            #expect(markdown.contains("--- Alternates for this block ---"))
            #expect(markdown.contains("take: \"bolder\""))
            #expect(markdown.contains("Second take."))
        }
    }

    @Test func blankAndArchivedTakesAreOutOfTheCountAsTheyAreOutOfTheExport() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let block = try ops.newBlock(in: post.id, text: "Shown take.")
            let blank = try ops.newBlankVariant(block.block.id)          // no text
            let archived = try ops.branchVariant(block.block.id, from: block.variant.id)
            try ops.autosave(archived.id, text: "Was a contender.", charDelta: 0)
            try ops.archiveVariant(archived.id)
            let alive = try ops.branchVariant(block.block.id, from: block.variant.id)
            try ops.autosave(alive.id, text: "Still in the fan.", charDelta: 0)

            let copy = try db.read { try Queries.blockTakes($0, blockID: block.block.id) }
            // Shown + the one live active non-blank alternate: the export's
            // ratified rule, stated as a number.
            #expect(copy.takeCount == 2)
            #expect(copy.markdown.contains("Still in the fan."))
            #expect(copy.markdown.contains("Was a contender.") == false)
            _ = blank
        }
    }

    @Test func anEmptyShownTakeCountsNothingAndADeadBlockProjectsNothing() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let empty = try ops.newBlock(in: post.id, text: "")
            let emptyCopy = try db.read { try Queries.blockTakes($0, blockID: empty.block.id) }
            #expect(emptyCopy.markdown.isEmpty)
            #expect(emptyCopy.takeCount == 0)

            let block = try ops.newBlock(in: post.id, text: "Doomed.")
            try ops.deleteBlock(block.block.id)
            let deadCopy = try db.read { try Queries.blockTakes($0, blockID: block.block.id) }
            #expect(deadCopy.markdown.isEmpty)
            #expect(deadCopy.takeCount == 0)
        }
    }

    @Test func aSealedNotesTakesStillCopy() throws {
        // Reading is never authoring: the clipboard door writes no row, so the
        // seal has nothing to refuse (the export precedent — a sealed post
        // exports fine).
        try withOperations { ops, db in
            let post = try ops.createPost()
            let block = try ops.newBlock(in: post.id, text: "Sealed prose.")
            try ops.lockPost(post.id)
            let copy = try db.read { try Queries.blockTakes($0, blockID: block.block.id) }
            #expect(copy.markdown == "Sealed prose.")
            #expect(copy.takeCount == 1)
        }
    }
}
