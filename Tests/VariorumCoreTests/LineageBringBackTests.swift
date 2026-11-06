//
//  LineageBringBackTests.swift
//  VariorumCoreTests
//
//  VX-801 (VX-827 U3b — `notes/plans/fixes/vx-827-lineage.md`, U3b-P RULED) —
//  `Operations.bringBackFromLineage`: a relative's text becomes a take on the
//  block you came from. Her sitting ruling, verbatim: *"mints the node's
//  active text as a new take on the block you came from — the
//  bringBackCommitAsTake shape, cross-block; parent lineage via the existing
//  edge."* Exact state transitions over both source forms, the posture
//  (`branchVariant`'s — no touch, no churn, no undo entry), every refusal in
//  its ruled order writing nothing, and the lineage fence's arms.
//
//  A PRODUCT row: the operation did not exist, so the suite does not compile
//  on the pre-U3b tree.
//

import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("VX-801 — bring back as take, across lineage (U3b)")
struct LineageBringBackTests {
    /// A note whose fanned block was divided by the ceremony: the original A
    /// kept whole as lineage (two takes, a named commit on the first), B and C
    /// placed in its stead. B is the block "you came from".
    private struct World {
        let noteID: String
        let original: String      // A — preserved, unplaced
        let originalTake: String  // A's default take, labelled
        let originalSpare: String // A's second take
        let commit: CommitPoint   // a moment of A's first take, named
        let first: String         // B
        let second: String        // C
    }

    private func world(_ ops: Operations, commitName: String? = "  before the cut  ") throws -> World {
        let note = try ops.createPost(title: "On Rereading")
        let a = try ops.seedBlock(in: note.id, text: "Alpha one. Beta one.")
        try ops.setTakeLabel(a.variant.id, label: "plain")
        let commit = try ops.commit(a.variant.id, message: commitName)
        try ops.autosave(a.variant.id, text: "Alpha one. Beta one!", charDelta: 1)
        let spare = try ops.branchVariant(a.block.id, from: a.variant.id)
        try ops.autosave(spare.id, text: "Alpha two. Beta two.", charDelta: 0)
        let w = try ops.divideW(a.block.id, cuts: [a.variant.id: 10, spare.id: 10])
        return World(
            noteID: note.id, original: a.block.id, originalTake: a.variant.id,
            originalSpare: spare.id, commit: commit, first: w.first.block.id,
            second: w.second.block.id)
    }

    /// Every row of the tables the act must not write, as text — compared
    /// before and after (the minted variant is excluded by id).
    private func untouched(_ db: AppDatabase, except minted: String? = nil) throws -> [String] {
        try db.read { db in
            var out: [String] = []
            for table in ["block", "container", "container_block", "edge", "commit_point", "block_comment"] {
                for row in try Row.fetchAll(db, sql: "SELECT * FROM \(table) ORDER BY id") {
                    out.append("\(table) \(row)")
                }
            }
            for row in try Row.fetchAll(
                db, sql: "SELECT * FROM variant WHERE id IS NOT ? ORDER BY id", arguments: [minted]) {
                out.append("variant \(row)")
            }
            return out
        }
    }

    private func fanOrder(_ db: AppDatabase, _ blockID: String) throws -> [String] {
        try db.read { db in
            try String.fetchAll(
                db,
                sql: "SELECT id FROM variant WHERE block_id = ? AND deleted_at IS NULL ORDER BY fan_position, id",
                arguments: [blockID])
        }
    }

    private func variantCount(_ db: AppDatabase) throws -> Int {
        try db.fetchInt("SELECT COUNT(*) FROM variant") ?? 0
    }

    // MARK: - The transition

    /// The NODE'S ACTIVE TEXT (`.take` — the ancestor's shown take): one
    /// variant on the block you came from — its text as it stands, NO parent,
    /// the take's label, at the fan's END past an archived take, never chosen,
    /// never the default, never locked — and every other row unchanged.
    @Test func aTakeSourceMintsOneTakeAtTheFansEndAndNothingElseMoves() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            // B grows a take and archives it, so "the fan's end" is read past
            // an archived take.
            let bTakes = try fanOrder(db, w.first)
            let bSpare = try ops.newBlankVariant(w.first)
            try ops.archiveVariant(bSpare.id)
            let before = try untouched(db)
            let chosenBefore = try db.fetchString(
                "SELECT chosen_variant_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                [w.first])

            let take = try ops.bringBackFromLineage(.take(w.originalTake), onto: w.first)

            #expect(take.blockId == w.first)
            #expect(take.workingText == "Alpha one. Beta one!", "the take's text as it stands")
            #expect(take.parentVariantId == nil, "no cross-block parent — the edge carries the lineage")
            #expect(take.label == "plain", "the source's name labels it")
            #expect(take.status == .active)
            #expect(take.locked == false)
            #expect(take.deletedAt == nil)
            #expect(try fanOrder(db, w.first) == bTakes + [bSpare.id, take.id],
                    "at the fan's END, past the archived take")
            #expect(try untouched(db, except: take.id) == before,
                    "blocks, placements (chosen kept), edges, commits, the note — byte-unchanged")
            #expect(try db.fetchString(
                "SELECT chosen_variant_id FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
                [w.first]) == chosenBefore)
            #expect(try db.fetchString("SELECT default_variant_id FROM block WHERE id = ?", [w.first])
                    != take.id, "never the block's default")
            #expect(try db.outboxContains("variant", take.id), "a plain synced insert")
        }
    }

    /// A RELATIVE'S COMMIT (`.commit`): the moment's immutable text, its name
    /// (normalised — trimmed) as the label, NO parent.
    @Test func aCommitSourceMintsTheMomentsWordsUnderItsName() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            let before = try untouched(db)
            let take = try ops.bringBackFromLineage(.commit(w.commit.id), onto: w.second)
            #expect(take.blockId == w.second)
            #expect(take.workingText == "Alpha one. Beta one.", "the moment, not the buffer")
            #expect(take.label == "before the cut", "the commit's name, normalised")
            #expect(take.parentVariantId == nil)
            #expect(try fanOrder(db, w.second).last == take.id)
            #expect(try untouched(db, except: take.id) == before, "no commit copied or consumed")
        }
    }

    /// An unnamed source brings back an unlabelled take, in both forms.
    @Test func anUnnamedSourceBringsBackAnUnlabelledTake() throws {
        try withOperations { ops, _ in
            let w = try world(ops, commitName: nil)
            #expect(try ops.bringBackFromLineage(.commit(w.commit.id), onto: w.first).label == nil)
            #expect(try ops.bringBackFromLineage(.take(w.originalSpare), onto: w.first).label == nil)
        }
    }

    /// The source is only READ: an archived or a locked take comes back.
    @Test func anArchivedOrLockedSourceIsAllowed() throws {
        try withOperations { ops, _ in
            let w = try world(ops)
            try ops.lockVariant(w.originalSpare)
            #expect(try ops.bringBackFromLineage(.take(w.originalSpare), onto: w.first).workingText
                    == "Alpha two. Beta two.")
            try ops.unlockVariant(w.originalSpare)
            try ops.archiveVariant(w.originalSpare)
            #expect(try ops.bringBackFromLineage(.take(w.originalSpare), onto: w.first).locked == false)
        }
    }

    // MARK: - The posture (`branchVariant`'s)

    @Test func itTouchesNothingChurnsNothingAndRegistersNoUndoEntry() throws {
        try withOperations { _, db in
            let stack = UndoStack()
            let ops = Operations(undoStack: stack)
            let w = try world(ops)
            let note = try db.read { db in try #require(try Container.fetchOne(db, key: w.noteID)) }
            let depth = stack.depth
            _ = try ops.bringBackFromLineage(.take(w.originalTake), onto: w.first)
            _ = try ops.bringBackFromLineage(.commit(w.commit.id), onto: w.first)
            let after = try db.read { db in try #require(try Container.fetchOne(db, key: w.noteID)) }
            #expect(after.lastTouchedAt == note.lastTouchedAt, "no touch")
            #expect(after.lastMajorRevisionAt == note.lastMajorRevisionAt)
            #expect(after.churnAccumulator == note.churnAccumulator, "no churn")
            #expect(after.updatedAt == note.updatedAt, "the note's row is not written")
            #expect(stack.depth == depth, "no structural-undo entry")
        }
    }

    // MARK: - Refusals, in the ruled order, each writing nothing

    @Test func aDeadTargetRefusesFirst() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            try ops.deleteBlock(w.first)
            let count = try variantCount(db)
            // Even with an unknown commit: the target is checked first.
            #expect(throws: OperationError.blockNotFound(id: w.first)) {
                try ops.bringBackFromLineage(.commit("no-such-moment"), onto: w.first)
            }
            #expect(throws: OperationError.blockNotFound(id: "no-such-block")) {
                try ops.bringBackFromLineage(.take(w.originalTake), onto: "no-such-block")
            }
            #expect(try variantCount(db) == count)
        }
    }

    @Test func aSealedNoteRefusesBeforeTheSource() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            try ops.lockPost(w.noteID)
            let count = try variantCount(db)
            #expect(throws: OperationError.lockedPost(id: w.noteID)) {
                try ops.bringBackFromLineage(.commit("no-such-moment"), onto: w.first)
            }
            #expect(try variantCount(db) == count)
        }
    }

    @Test func anUnknownCommitOrADeadSourceTakeRefuses() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            let count = try variantCount(db)
            #expect(throws: OperationError.commitNotFound(id: "no-such-moment")) {
                try ops.bringBackFromLineage(.commit("no-such-moment"), onto: w.first)
            }
            #expect(throws: OperationError.variantNotFound(id: "no-such-take")) {
                try ops.bringBackFromLineage(.take("no-such-take"), onto: w.first)
            }
            // A moment of a take since deleted: its take is the source.
            try ops.autosave(w.originalSpare, text: "Spare words.", charDelta: 1)
            let spareMoment = try ops.commit(w.originalSpare)
            try ops.deleteVariant(w.originalSpare)
            #expect(throws: OperationError.variantNotFound(id: w.originalSpare)) {
                try ops.bringBackFromLineage(.commit(spareMoment.id), onto: w.first)
            }
            #expect(throws: OperationError.variantNotFound(id: w.originalSpare)) {
                try ops.bringBackFromLineage(.take(w.originalSpare), onto: w.first)
            }
            #expect(try variantCount(db) == count)
        }
    }

    /// A source block in the Trash with a take left live (the sync-debris
    /// shape — a delete door tombstones the takes with it on the cascade's
    /// stamp, which the take check above already refuses, so the fixture
    /// revives the one take by hand): the block's own refusal.
    @Test func aDeadSourceBlockRefuses() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            try db.write { db in
                try db.execute(
                    sql: "UPDATE block SET deleted_at = '2026-07-01T05:00:00.000Z' WHERE id = ?",
                    arguments: [w.original])
                try db.execute(
                    sql: "UPDATE variant SET deleted_at = NULL WHERE id = ?",
                    arguments: [w.originalTake])
            }
            let count = try variantCount(db)
            #expect(throws: OperationError.blockNotFound(id: w.original)) {
                try ops.bringBackFromLineage(.take(w.originalTake), onto: w.first)
            }
            #expect(try variantCount(db) == count)
        }
    }

    // MARK: - The lineage fence

    /// Outside the tree, the block itself, an edge taken apart, another wing:
    /// `notInLineage`, nothing written.
    @Test func theFenceRefusesWhatTheTreeDoesNotHold() throws {
        try withOperations { ops, db in
            let w = try world(ops)
            let stranger = try ops.seedBlock(in: w.noteID, text: "Unrelated.")
            let count = try variantCount(db)
            #expect(throws: OperationError.notInLineage(sourceBlockID: stranger.block.id, targetBlockID: w.first)) {
                try ops.bringBackFromLineage(.take(stranger.variant.id), onto: w.first)
            }
            let own = try #require(try fanOrder(db, w.first).first)
            #expect(throws: OperationError.notInLineage(sourceBlockID: w.first, targetBlockID: w.first),
                    "the block itself is not its own lineage — same-block keeps its own doors") {
                try ops.bringBackFromLineage(.take(own), onto: w.first)
            }
            // An edge taken apart on its own (a stamp no endpoint shares).
            let p = try ops.seedBlock(in: w.noteID, text: "Paragraph seam has words. And more.")
            let q = try ops.divide(p.block.id, cut: 26)
            try db.write { db in
                try db.execute(
                    sql: """
                        UPDATE edge SET deleted_at = '2026-07-01T05:00:00.000Z'
                        WHERE source_block_id = ? AND target_block_id = ? AND type = 'derived_from'
                        """,
                    arguments: [q.block.id, p.block.id])
            }
            #expect(throws: OperationError.notInLineage(sourceBlockID: p.block.id, targetBlockID: q.block.id)) {
                try ops.bringBackFromLineage(.take(p.variant.id), onto: q.block.id)
            }
            #expect(try variantCount(db) == count + 2, "only the fixture's seed and divide minted")
        }
    }

    /// Wings isolate: a relative living in a note of ANOTHER wing is fenced
    /// both ways; the scraps are the one shared room, so a pool home crosses
    /// nothing.
    @Test func anotherWingIsFencedAndTheScrapsCrossNothing() throws {
        try withOperations { ops, db in
            let studio = try ops.createWing(name: "Studio")
            let home = try ops.createPost(title: "N")
            let away = try ops.createPost(title: "R", wingId: studio.id)
            let e = try ops.seedBlock(in: home.id, text: "Kept part. Extracted part.")
            let extracted = try ops.extract(e.block.id, span: 11..<26)
            try ops.moveBlock(extracted.block.id, to: away.id)
            #expect(throws: OperationError.notInLineage(sourceBlockID: extracted.block.id, targetBlockID: e.block.id)) {
                try ops.bringBackFromLineage(.take(extracted.variant.id), onto: e.block.id)
            }
            #expect(throws: OperationError.notInLineage(sourceBlockID: e.block.id, targetBlockID: extracted.block.id)) {
                try ops.bringBackFromLineage(.take(e.variant.id), onto: extracted.block.id)
            }

            let pool = try ops.createPool(title: "scraps")
            let scrap = try ops.seedBlock(in: pool.id, text: "A scrap.")
            let copy = try ops.poolDragCopy(scrap.block.id, to: away.id)
            let fromScraps = try ops.bringBackFromLineage(.take(scrap.variant.id), onto: copy.block.id)
            #expect(fromScraps.workingText == "A scrap." && fromScraps.blockId == copy.block.id,
                    "the scraps are the one shared room")
            let toScraps = try ops.bringBackFromLineage(.take(try #require(copy.variants.first).id), onto: scrap.block.id)
            #expect(toScraps.blockId == scrap.block.id)
            #expect(Operations.lineageCrossesWing(nil, nil) == false)
            _ = db
        }
    }

    /// The tree's whole reach is the fence's: a grandparent, a placed
    /// descendant in ANOTHER note of the same wing, and a duplicate's block
    /// (a descendant and a version sibling) all come back.
    @Test func theWholeTreeInTheWingIsInside() throws {
        try withOperations { ops, db in
            let n = try ops.createPost(title: "N")
            let other = try ops.createPost(title: "Other")
            let a = try ops.seedBlock(in: n.id, text: "Paragraph seam has words. And a second sentence follows here.")
            let c = try ops.divide(a.block.id, cut: 26)
            let d = try ops.divide(c.block.id, cut: 4)
            try ops.moveBlock(d.block.id, to: other.id)
            // A grandparent onto its grandchild (two edges away).
            let fromGrand = try ops.bringBackFromLineage(.take(a.variant.id), onto: d.block.id)
            #expect(fromGrand.blockId == d.block.id)
            #expect(fromGrand.workingText == (try db.fetchString(
                "SELECT working_text FROM variant WHERE id = ?", [a.variant.id])))
            // A placed descendant in another note, back onto its ancestor.
            #expect(try ops.bringBackFromLineage(.take(d.variant.id), onto: a.block.id).blockId == a.block.id)
            // A duplicate's block.
            let dup = try ops.duplicateAsVersion(n.id)
            let copied = try #require(dup.blockCopies.first { $0.source == a.block.id }?.copy)
            let copiedTake = try #require(try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?", [copied]))
            #expect(try ops.bringBackFromLineage(.take(copiedTake), onto: a.block.id).blockId == a.block.id)
        }
    }
}
