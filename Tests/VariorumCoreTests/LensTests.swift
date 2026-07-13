import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 11, Step A1 — migration v1_7 (`lens` + `lens_choice`), the lens
/// CRUD operations, and the read-side overlay. The load-bearing pins:
/// lenses are NEVER rendering truth (nothing here writes
/// `chosen_variant_id` — I3), overrides are SPARSE, and a dangling pick
/// falls through to chosen at read time.
@Suite("Lenses: schema, operations, read overlay (Phase 11, A1)")
struct LensTests {
    private struct World {
        let postID: String
        let blockID: String
        let chosenVariantID: String
        let altVariantID: String
    }

    private func makeWorld(_ ops: Operations, _ db: AppDatabase) throws -> World {
        let post = try ops.createPost(title: "post", profile: .generic)
        let minted = try ops.newBlock(in: post.id, text: "Chosen text.", at: .end)
        let alt = try ops.branchVariant(minted.block.id, from: minted.variant.id)
        try ops.autosave(alt.id, text: "Alternate take.", charDelta: 4)
        return World(
            postID: post.id, blockID: minted.block.id,
            chosenVariantID: minted.variant.id, altVariantID: alt.id)
    }

    // MARK: - Schema

    @Test func cascadesRunContainerToLensToChoiceWithOneStamp() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops, db)
            let lens = try ops.createLens(post: w.postID, name: "thread")
            let choice = try ops.setLensChoice(
                lens: lens.id, block: w.blockID, variant: w.altVariantID)

            try ops.deleteContainer(w.postID)

            let stamp = try db.deletedAt("container", w.postID)
            #expect(stamp != nil)
            #expect(try db.deletedAt("lens", lens.id) == stamp,
                    "container → lens cascade carries the exact stamp")
            #expect(try db.deletedAt("lens_choice", choice.id) == stamp,
                    "lens → lens_choice chains with the same stamp")
        }
    }

    @Test func aBlockTombstoneCascadesToItsOverridesOnly() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops, db)
            let other = try ops.newBlock(in: w.postID, text: "Another block.", at: .end)
            let lens = try ops.createLens(post: w.postID, name: "thread")
            let doomed = try ops.setLensChoice(
                lens: lens.id, block: w.blockID, variant: w.altVariantID)
            let otherAlt = try ops.branchVariant(other.block.id, from: other.variant.id)
            let survivor = try ops.setLensChoice(
                lens: lens.id, block: other.block.id, variant: otherAlt.id)

            try ops.deleteBlock(w.blockID)

            #expect(try db.deletedAt("lens_choice", doomed.id) != nil)
            #expect(try db.deletedAt("lens_choice", survivor.id) == nil)
            #expect(try db.deletedAt("lens", lens.id) == nil,
                    "the lens itself survives a block deletion")
        }
    }

    @Test func outboxCaptureAndTombstoneRecreateHoldForBothTables() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops, db)
            try db.clearOutbox()
            let lens = try ops.createLens(post: w.postID, name: "thread")
            let choice = try ops.setLensChoice(
                lens: lens.id, block: w.blockID, variant: w.altVariantID)
            #expect(try db.outboxContains("lens", lens.id))
            #expect(try db.outboxContains("lens_choice", choice.id))

            // Tombstone-then-recreate under the live-unique (lens, block).
            try ops.clearLensChoice(lens: lens.id, block: w.blockID)
            let recreated = try ops.setLensChoice(
                lens: lens.id, block: w.blockID, variant: w.chosenVariantID)
            #expect(recreated.id != choice.id, "re-creation is a fresh row")

            try db.clearOutbox()
            try db.applyingRemote { database in
                try database.execute(
                    sql: "UPDATE lens SET name = 'echoed' WHERE id = ?", arguments: [lens.id])
            }
            #expect(!(try db.outboxContains("lens", lens.id)),
                    "apply-mode writes are echo-suppressed")
        }
    }

    // MARK: - Operations

    @Test func lensCRUDStateTransitions() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops, db)
            let lens = try ops.createLens(post: w.postID, name: "  thread one  ")
            #expect(lens.name == "thread one", "names trim")

            try ops.renameLens(lens.id, newName: "draft B")
            #expect(try db.fetchString("SELECT name FROM lens WHERE id = ?", [lens.id]) == "draft B")

            #expect(throws: OperationError.invalidLensName(name: "   ")) {
                try ops.renameLens(lens.id, newName: "   ")
            }

            _ = try ops.setLensChoice(lens: lens.id, block: w.blockID, variant: w.altVariantID)
            let copy = try ops.duplicateLens(lens.id)
            #expect(copy.name == "draft B copy")
            #expect(copy.containerId == w.postID)
            let copiedPicks = try db.read { try Queries.lensChoices($0, lens: copy.id) }
            #expect(copiedPicks == [w.blockID: w.altVariantID],
                    "duplicate carries the live choices as fresh rows")

            try ops.deleteLens(lens.id)
            #expect(try db.deletedAt("lens", lens.id) != nil)
            // The copy and the post are untouched.
            #expect(try db.deletedAt("lens", copy.id) == nil)
            #expect(try db.deletedAt("container", w.postID) == nil)
        }
    }

    @Test func setLensChoiceUpsertsOnTheLiveRowAndGuardsLikeChooseVariant() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops, db)
            let lens = try ops.createLens(post: w.postID, name: "thread")

            let first = try ops.setLensChoice(
                lens: lens.id, block: w.blockID, variant: w.altVariantID)
            let second = try ops.setLensChoice(
                lens: lens.id, block: w.blockID, variant: w.chosenVariantID)
            #expect(second.id == first.id, "re-picking is metadata CAS on the SAME row")
            #expect(try db.fetchInt("SELECT COUNT(*) FROM lens_choice") == 1)

            // A foreign block's variant refuses (chooseVariant's exact guard).
            let other = try ops.newBlock(in: w.postID, text: "Another.", at: .end)
            #expect(throws: OperationError.variantNotFound(id: w.altVariantID)) {
                try ops.setLensChoice(lens: lens.id, block: other.block.id, variant: w.altVariantID)
            }

            // An archived take refuses.
            _ = try ops.branchVariant(w.blockID, from: w.chosenVariantID)
            try ops.archiveVariant(w.altVariantID)
            #expect(throws: OperationError.archivedVariant(id: w.altVariantID)) {
                try ops.setLensChoice(lens: lens.id, block: w.blockID, variant: w.altVariantID)
            }

            // A block outside the lens's post refuses.
            let elsewhere = try ops.createPost(title: "other post", profile: .generic)
            let foreign = try ops.newBlock(in: elsewhere.id, text: "Foreign.", at: .end)
            #expect(throws: OperationError.blockNotInContainer(
                blockID: foreign.block.id, containerID: w.postID)) {
                try ops.setLensChoice(
                    lens: lens.id, block: foreign.block.id, variant: foreign.variant.id)
            }
        }
    }

    @Test func lensOpsAreAllowedUnderASealedPostButNeverTouchChosen() throws {
        // PROVISIONAL posture (QUESTIONS bundle): a lens is a saved way of
        // LOOKING — the 9d viewing-isn't-authoring doctrine. The pin also
        // covers the I3 half: nothing here writes chosen_variant_id.
        try withOperations { ops, db in
            let w = try makeWorld(ops, db)
            try ops.lockPost(w.postID)

            let lens = try ops.createLens(post: w.postID, name: "sealed viewing")
            _ = try ops.setLensChoice(lens: lens.id, block: w.blockID, variant: w.altVariantID)
            try ops.renameLens(lens.id, newName: "still viewing")
            try ops.clearLensChoice(lens: lens.id, block: w.blockID)
            try ops.deleteLens(lens.id)

            let chosen = try db.fetchString(
                "SELECT chosen_variant_id FROM container_block WHERE block_id = ?", [w.blockID])
            #expect(chosen == w.chosenVariantID,
                    "no lens operation ever moved the chosen pointer (I3)")
        }
    }

    // MARK: - Read overlay

    @Test func renderThroughLensOverlaysSparseOverridesOnly() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops, db)
            let other = try ops.newBlock(in: w.postID, text: "Untouched slot.", at: .end)
            let lens = try ops.createLens(post: w.postID, name: "thread")
            _ = try ops.setLensChoice(lens: lens.id, block: w.blockID, variant: w.altVariantID)

            try db.read { database in
                let plain = try Queries.renderPost(database, containerID: w.postID)
                #expect(plain.map(\.text) == ["Chosen text.", "Untouched slot."],
                        "the plain traversal never sees the lens (a lens is not rendering truth)")

                let overlaid = try Queries.renderPost(
                    database, containerID: w.postID, throughLens: lens.id)
                #expect(overlaid.map(\.text) == ["Alternate take.", "Untouched slot."])
                #expect(overlaid[0].variantID == w.altVariantID)
                #expect(overlaid[1].variantID == other.variant.id,
                        "un-overridden slots follow the post's ordinary resolution")

                let transparent = try Queries.renderPost(
                    database, containerID: w.postID, throughLens: nil)
                #expect(transparent.map(\.text) == plain.map(\.text),
                        "the nil lens is the transparent overlay")
            }
        }
    }

    @Test func aDanglingLensPickFallsThroughToChosen() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops, db)
            let lens = try ops.createLens(post: w.postID, name: "thread")
            _ = try ops.setLensChoice(lens: lens.id, block: w.blockID, variant: w.altVariantID)

            // The picked take dies AFTER the pick was recorded (the sync/
            // lifecycle race the fallback class exists for).
            try ops.deleteVariant(w.altVariantID)

            try db.read { database in
                let overlaid = try Queries.renderPost(
                    database, containerID: w.postID, throughLens: lens.id)
                #expect(overlaid.map(\.text) == ["Chosen text."],
                        "a dangling pick falls through to the slot's chosen resolution")
                #expect(try Queries.effectiveLensSelection(database, lens: lens.id).isEmpty,
                        "the effective selection drops the dangling pick")
            }

            // exports stay on rendering truth throughout
            #expect(try db.read { try Queries.renderedText($0, containerID: w.postID) }
                    == "Chosen text.")
        }
    }

    @Test func theEmptyLensIsLegalAndTransparent() throws {
        try withOperations { ops, db in
            let w = try makeWorld(ops, db)
            let lens = try ops.createLens(post: w.postID, name: "new thread")
            try db.read { database in
                let overlaid = try Queries.renderPost(
                    database, containerID: w.postID, throughLens: lens.id)
                let plain = try Queries.renderPost(database, containerID: w.postID)
                #expect(overlaid == plain, "the empty lens shows through everywhere")
            }
        }
    }
}

// MARK: - Review round 1, MAJOR: the restore/undo doors revive the new
// cascade children (AppSpec §9's letter: "every cascade victim carrying
// its exact stamp"). Red-on-old pins: on the pre-fix code the lens/choice
// rows stayed tombstoned through every restore door.

@Suite("Restore doors revive lens rows (Phase 11, review round 1 MAJOR)")
struct LensRestoreTests {
    @Test func restoreBlockRevivesItsLensPick() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let m = try ops.newBlock(in: post.id, text: "Chosen.", at: .end)
            _ = try ops.newBlock(in: post.id, text: "Keeps the post alive.", at: .end)
            let alt = try ops.branchVariant(m.block.id, from: m.variant.id)
            let lens = try ops.createLens(post: post.id, name: "thread")
            let choice = try ops.setLensChoice(lens: lens.id, block: m.block.id, variant: alt.id)

            try ops.deleteBlock(m.block.id)
            #expect(try db.deletedAt("lens_choice", choice.id) != nil, "the cascade took the pick")

            try ops.restoreBlock(m.block.id)
            #expect(try db.deletedAt("lens_choice", choice.id) == nil,
                    "the exact-stamp cascade victim revives with its block (AppSpec §9)")
            #expect(try db.read { try Queries.effectiveLensSelection($0, lens: lens.id) }
                    == [m.block.id: alt.id], "the lens sees its pick again")
        }
    }

    @Test func undoOfDeleteBlockRevivesTheLensPickToo() throws {
        let undoStack = UndoStack()
        try withOperations { _, db in
            let ops = Operations(undoStack: undoStack)
            let post = try ops.createPost(title: "p", profile: .generic)
            let m = try ops.newBlock(in: post.id, text: "Chosen.", at: .end)
            _ = try ops.newBlock(in: post.id, text: "Keeps the post alive.", at: .end)
            let alt = try ops.branchVariant(m.block.id, from: m.variant.id)
            let lens = try ops.createLens(post: post.id, name: "thread")
            let choice = try ops.setLensChoice(lens: lens.id, block: m.block.id, variant: alt.id)

            try ops.deleteBlock(m.block.id)
            try undoStack.undo(with: ops)

            #expect(try db.deletedAt("lens_choice", choice.id) == nil,
                    "structural undo's exact-pre-image contract covers the pick")
        }
    }

    @Test func restoreContainerRevivesLensesAndTheirChoices() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "days of work", profile: .generic)
            let m = try ops.newBlock(in: post.id, text: "Chosen.", at: .end)
            let alt = try ops.branchVariant(m.block.id, from: m.variant.id)
            let lens = try ops.createLens(post: post.id, name: "the days-long thread")
            let choice = try ops.setLensChoice(lens: lens.id, block: m.block.id, variant: alt.id)

            try ops.deleteContainer(post.id)
            #expect(try db.deletedAt("lens", lens.id) != nil)

            try ops.restoreContainer(post.id)
            #expect(try db.deletedAt("lens", lens.id) == nil,
                    "a lens is days-long work — the recoverable-post door brings it back")
            #expect(try db.deletedAt("lens_choice", choice.id) == nil)
            #expect(try db.read { try Queries.effectiveLensSelection($0, lens: lens.id) }
                    == [m.block.id: alt.id])
        }
    }

    @Test func aPickWhoseLensDiedIndependentlyStaysDead() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "p", profile: .generic)
            let m = try ops.newBlock(in: post.id, text: "Chosen.", at: .end)
            _ = try ops.newBlock(in: post.id, text: "Keeps the post alive.", at: .end)
            let alt = try ops.branchVariant(m.block.id, from: m.variant.id)
            let lens = try ops.createLens(post: post.id, name: "thread")
            let choice = try ops.setLensChoice(lens: lens.id, block: m.block.id, variant: alt.id)

            // The lens dies FIRST (its own cascade stamps the choice with
            // the LENS's stamp); the block dies after.
            try ops.deleteLens(lens.id)
            try ops.deleteBlock(m.block.id)
            try ops.restoreBlock(m.block.id)

            #expect(try db.deletedAt("lens_choice", choice.id) != nil,
                    "a pick under a dead lens stays dead — the tag-application guard's twin")
        }
    }
}
