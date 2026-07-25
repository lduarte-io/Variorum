import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Post render query (Phase 4, Step 1)")
struct PostRenderQueryTests {
    // MARK: - Order and shape

    @Test func rendersBlocksInPointerOrder() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "first")
            let c = try ops.newBlock(in: post.id, text: "third")
            let b = try ops.newBlock(in: post.id, text: "second", at: .after(a.block.id))
            let rendered = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(rendered.map(\.blockID) == [a.block.id, b.block.id, c.block.id])
            #expect(rendered.map(\.text) == ["first", "second", "third"])
            #expect(rendered.map(\.variantID) == [a.variant.id, b.variant.id, c.variant.id])
            #expect(rendered.allSatisfy { !$0.isGap })
        }
    }

    @Test func emptyContainerRendersEmpty() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let rendered = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(rendered.isEmpty)
        }
    }

    @Test func tombstonedPlacementsAreExcluded() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "stays")
            let b = try ops.newBlock(in: post.id, text: "goes")
            try ops.deleteBlock(b.block.id)
            let rendered = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(rendered.map(\.blockID) == [a.block.id])
        }
    }

    @Test func poolRendersExactlyLikeAPost() throws {
        try withOperations { ops, db in
            let pool = try ops.createPool()
            let scrap = try ops.newBlock(in: pool.id, text: "loose sentence")
            let rendered = try db.read { try Queries.renderPost($0, containerID: pool.id) }
            #expect(rendered.count == 1)
            #expect(rendered[0].blockID == scrap.block.id)
            #expect(rendered[0].text == "loose sentence")
        }
    }

    // MARK: - The fallback matrix (read-time rule, AppSpec §7)

    @Test func chosenVariantWinsOverDefault() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "take one")
            let take2 = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.autosave(take2.id, text: "take two", charDelta: 0)
            try ops.chooseVariant(a.block.id, variantID: take2.id)
            let rendered = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(rendered[0].variantID == take2.id)
            #expect(rendered[0].text == "take two")
        }
    }

    @Test func nullChosenFallsBackToDefault() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "original")
            _ = try ops.branchVariant(a.block.id, from: a.variant.id)
            // chooseVariant never called: chosen stays NULL on newer schema
            // paths only when ops set it — newBlock sets chosen, so clear it.
            try db.write { db in
                try db.execute(
                    sql: "UPDATE container_block SET chosen_variant_id = NULL WHERE block_id = ?",
                    arguments: [a.block.id])
            }
            let rendered = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(rendered[0].variantID == a.variant.id)
            #expect(rendered[0].text == "original")
        }
    }

    @Test func tombstonedChosenFallsBackToDefault() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "original")
            let take2 = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.chooseVariant(a.block.id, variantID: take2.id)
            // A sync race can tombstone a chosen variant under the slot
            // (SyncSpec §7) — simulate below the operations layer.
            try db.write { db in
                try Fixture.tombstone(db, table: "variant", id: take2.id)
            }
            let rendered = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(rendered[0].variantID == a.variant.id)
        }
    }

    @Test func archivedChosenFallsBackToDefault() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "original")
            let take2 = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.chooseVariant(a.block.id, variantID: take2.id)
            try ops.archiveVariant(take2.id)
            let rendered = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(rendered[0].variantID == a.variant.id)
        }
    }

    @Test func foreignChosenFallsBackToDefault() throws {
        // A chosen pointer at another block's variant (corruption / race
        // debris) must never render that other block's text here — same
        // guard as Operations.renderedVariant.
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "mine")
            let b = try ops.newBlock(in: post.id, text: "someone else's")
            try db.write { db in
                try db.execute(
                    sql: "UPDATE container_block SET chosen_variant_id = ? WHERE id = ?",
                    arguments: [b.variant.id, a.placement.id])
            }
            let rendered = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(rendered[0].variantID == a.variant.id)
            #expect(rendered[0].text == "mine")
        }
    }

    @Test func archivedDefaultStillRenders() throws {
        // The default fallback requires live only, not active — archive
        // hides a take from the fan, not from a slot with nothing else to
        // show (matches Operations.renderedVariant exactly).
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "original")
            let take2 = try ops.branchVariant(a.block.id, from: a.variant.id)
            // Archiving the default reassigns default to take2; put the
            // archived one back as default below the ops layer to simulate
            // the sync-race state (SyncSpec §7 repairs it; reads tolerate).
            try ops.archiveVariant(a.variant.id)
            try db.write { db in
                try db.execute(
                    sql: "UPDATE block SET default_variant_id = ? WHERE id = ?",
                    arguments: [a.variant.id, a.block.id])
                try db.execute(
                    sql: "UPDATE container_block SET chosen_variant_id = NULL WHERE block_id = ?",
                    arguments: [a.block.id])
            }
            _ = take2
            let rendered = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(rendered[0].variantID == a.variant.id)
            #expect(rendered[0].text == "original")
        }
    }

    // MARK: - Gaps (missing-row tolerance, SyncSpec §5)

    @Test func deadDefaultAndNoChosenIsAGap() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "doomed")
            // Below the ops layer (I10 forbids this locally; a sync race can
            // produce it — SyncSpec §7's resurrection repair owns fixing it;
            // the read side renders a gap meanwhile).
            try db.write { db in
                try db.execute(
                    sql: "UPDATE container_block SET chosen_variant_id = NULL WHERE block_id = ?",
                    arguments: [a.block.id])
                try Fixture.tombstone(db, table: "variant", id: a.variant.id)
            }
            let rendered = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(rendered.count == 1)
            #expect(rendered[0].isGap)
            #expect(rendered[0].blockID == a.block.id)
            #expect(rendered[0].text == nil)
            #expect(rendered[0].activeVariantCount == 0)
        }
    }

    @Test func tombstonedBlockUnderLivePlacementIsAGap() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "raced away")
            let b = try ops.newBlock(in: post.id, text: "still here")
            try db.write { db in
                // Tombstoning the block cascades to its placement; revive the
                // placement to model the cross-device race (live placement,
                // dead block).
                try Fixture.tombstone(db, table: "block", id: a.block.id)
                try db.execute(
                    sql: "UPDATE container_block SET deleted_at = NULL WHERE block_id = ?",
                    arguments: [a.block.id])
            }
            let rendered = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(rendered.count == 2)
            #expect(rendered[0].isGap)
            #expect(rendered[1].blockID == b.block.id)
            #expect(rendered[1].text == "still here")
        }
    }

    @Test func missingBlockRowIsAGapNotACrash() throws {
        // The child-before-parent sync order (SyncSpec §5): a placement
        // arrives before its block. Only constructible with FK enforcement
        // off — see `unenforcedDatabase`.
        let queue = try unenforcedDatabase()
        try queue.write { db in
            try Fixture.container(db, id: "post")
            try Fixture.containerBlock(
                db, id: "cb-ghost", containerId: "post", blockId: "not-arrived", position: "A")
            // The ghost block's variants arrived first (same sync order,
            // one row deeper): they must not badge the gap slot.
            try Fixture.variant(db, id: "ghost-v1", blockId: "not-arrived")
            try Fixture.variant(db, id: "ghost-v2", blockId: "not-arrived")
            try Fixture.placedBlock(db, container: "other", block: "b", variant: "v", cb: "cb-real")
            try db.execute(sql: "UPDATE block SET default_variant_id = 'v' WHERE id = 'b'")
            try db.execute(
                sql: "UPDATE container_block SET container_id = 'post', position = 'B' WHERE id = 'cb-real'")
        }
        let rendered = try queue.read { try Queries.renderPost($0, containerID: "post") }
        #expect(rendered.count == 2)
        #expect(rendered[0].isGap)
        #expect(rendered[0].blockID == "not-arrived")
        #expect(rendered[0].activeVariantCount == 0)  // no live block, no badge
        #expect(!rendered[0].hasFan)
        #expect(rendered[1].blockID == "b")
        #expect(!rendered[1].isGap)
    }

    @Test func deadBlockDivergenceFromChurnCounterIsDocumented() throws {
        // The documented, harmless divergence (review finding): the render
        // gaps a live placement over a tombstoned block, while Operations'
        // by-ID resolver refuses it and the churn counter's renderedLength
        // (approximate by design, SyncSpec §6 counters class) may still
        // count its text. Pin the read side of that line: gap here, typed
        // refusal there.
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "raced away")
            try db.write { db in
                try Fixture.tombstone(db, table: "block", id: a.block.id)
                try db.execute(
                    sql: "UPDATE container_block SET deleted_at = NULL WHERE block_id = ?",
                    arguments: [a.block.id])
                // The variant survives the race too — text exists, block dead.
                try db.execute(
                    sql: "UPDATE variant SET deleted_at = NULL WHERE id = ?",
                    arguments: [a.variant.id])
            }
            let rendered = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(rendered.count == 1)
            #expect(rendered[0].isGap)
            try db.read { db in
                #expect(throws: OperationError.self) {
                    _ = try ops.renderedVariant(db, blockID: a.block.id)
                }
            }
        }
    }

    @Test func chosenPointingAtNothingFallsBackThenGaps() throws {
        // Dangling chosen_variant_id with a missing variant row entirely.
        let queue = try unenforcedDatabase()
        try queue.write { db in
            try Fixture.container(db, id: "post")
            try Fixture.block(db, id: "b")
            try Fixture.variant(db, id: "v", blockId: "b")
            try db.execute(sql: "UPDATE block SET default_variant_id = 'v' WHERE id = 'b'")
            try Fixture.containerBlock(
                db, id: "cb", containerId: "post", blockId: "b",
                chosenVariantId: "never-arrived")
        }
        let rendered = try queue.read { try Queries.renderPost($0, containerID: "post") }
        #expect(rendered[0].variantID == "v")

        // And when the default is missing too: a gap.
        try queue.write { db in
            try db.execute(sql: "UPDATE block SET default_variant_id = 'also-missing' WHERE id = 'b'")
        }
        let gapped = try queue.read { try Queries.renderPost($0, containerID: "post") }
        #expect(gapped[0].isGap)
    }

    // MARK: - Fan badge and lock flags

    @Test func fanBadgeCountsLiveActiveVariantsOnly() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "one")
            let single = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(single[0].activeVariantCount == 1)
            #expect(!single[0].hasFan)

            let take2 = try ops.branchVariant(a.block.id, from: a.variant.id)
            let take3 = try ops.branchVariant(a.block.id, from: a.variant.id)
            let take4 = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.archiveVariant(take3.id)   // archived: out of the fan
            try ops.deleteVariant(take4.id)    // tombstoned: gone
            _ = take2
            let fanned = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(fanned[0].activeVariantCount == 2)
            #expect(fanned[0].hasFan)
        }
    }

    /// The fan is not the whole truth (13c Stage 1 ladder, R1-1): an
    /// ARCHIVED take is out of the fan but still prose, and a `deleteBlock`
    /// cascade takes it with the block. `liveVariantCount` is what EXISTS,
    /// so a gesture authorized on "there is no text to lose" has something
    /// honest to read; a tombstoned take is genuinely gone and counts in
    /// neither.
    @Test func liveVariantCountSeesArchivedTakesTheFanDoesNot() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "prose")
            let plain = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(plain[0].liveVariantCount == 1)
            #expect(!plain[0].hasArchivedTakes)

            let survivor = try ops.branchVariant(a.block.id, from: a.variant.id)
            let doomed = try ops.branchVariant(a.block.id, from: a.variant.id)
            try ops.archiveVariant(a.variant.id)   // the one carrying "prose"
            try ops.deleteVariant(doomed.id)
            _ = survivor

            let after = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(after[0].activeVariantCount == 1, "the fan shows only the survivor")
            #expect(after[0].liveVariantCount == 2, "…and the archived take still exists")
            #expect(after[0].hasArchivedTakes)
        }
    }

    @Test func variantLockFlagReflectsTheRenderedVariant() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            let a = try ops.newBlock(in: post.id, text: "guarded")
            try ops.lockVariant(a.variant.id)
            let rendered = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(rendered[0].variantLocked)
        }
    }

    // MARK: - Equivalence with the operations-layer resolution

    @Test func renderAgreesWithOperationsRenderedVariant() throws {
        // The one risk the plan names: two sources of rendered-variant truth.
        // Same world, both resolvers, every fallback shape — they must agree
        // block for block.
        try withOperations { ops, db in
            let post = try ops.createPost()
            let plain = try ops.newBlock(in: post.id, text: "plain")
            let chosenWins = try ops.newBlock(in: post.id, text: "default")
            let cw2 = try ops.branchVariant(chosenWins.block.id, from: chosenWins.variant.id)
            try ops.chooseVariant(chosenWins.block.id, variantID: cw2.id)
            let archivedChosen = try ops.newBlock(in: post.id, text: "default2")
            let ac2 = try ops.branchVariant(archivedChosen.block.id, from: archivedChosen.variant.id)
            try ops.chooseVariant(archivedChosen.block.id, variantID: ac2.id)
            try ops.archiveVariant(ac2.id)
            let deadChosen = try ops.newBlock(in: post.id, text: "default3")
            let dc2 = try ops.branchVariant(deadChosen.block.id, from: deadChosen.variant.id)
            try ops.chooseVariant(deadChosen.block.id, variantID: dc2.id)
            try db.write { db in try Fixture.tombstone(db, table: "variant", id: dc2.id) }

            let rendered = try db.read { try Queries.renderPost($0, containerID: post.id) }
            try db.read { db in
                for slot in rendered {
                    let opsAnswer = try ops.renderedVariant(db, blockID: slot.blockID)
                    #expect(opsAnswer.id == slot.variantID)
                    #expect(opsAnswer.workingText == slot.text)
                }
            }
        }
    }

    // MARK: - renderedText

    @Test func renderedTextJoinsBlocksWithBlankLine() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            _ = try ops.newBlock(in: post.id, text: "First paragraph.")
            _ = try ops.newBlock(in: post.id, text: "Second paragraph.")
            let text = try db.read { try Queries.renderedText($0, containerID: post.id) }
            #expect(text == "First paragraph.\n\nSecond paragraph.")
        }
    }

    @Test func renderedTextCompletesStoredSpacingInsteadOfStacking() throws {
        // Author ruling 2026-07-12 (QUESTIONS #12, the export half): a
        // block whose text ends in stored newlines (option (a)'s trailing
        // spacing) joins with ONE "\n" — the paste's k newlines export as
        // k again; unspaced blocks keep the "\n\n" join byte-identical to
        // before (the merge-join precedent's shape).
        try withOperations { ops, db in
            let post = try ops.createPost()
            _ = try ops.newBlock(in: post.id, text: "A\n")      // k=2 paste
            _ = try ops.newBlock(in: post.id, text: "B\n\n")    // k=3 paste
            _ = try ops.newBlock(in: post.id, text: "C")        // unspaced
            _ = try ops.newBlock(in: post.id, text: "D")
            let text = try db.read { try Queries.renderedText($0, containerID: post.id) }
            #expect(text == "A\n\nB\n\n\nC\n\nD")
        }
    }

    @Test func joinRenderedTextsIsTheOneJoinBrain() {
        // The pure join the bridge's per-day projection shares with
        // renderedText — pinned directly so the two can never diverge in
        // shape (the pushed body always equals the export).
        #expect(Queries.joinRenderedTexts([]) == "")
        #expect(Queries.joinRenderedTexts(["A"]) == "A")
        #expect(Queries.joinRenderedTexts(["A", "B"]) == "A\n\nB")
        #expect(Queries.joinRenderedTexts(["A\n", "B"]) == "A\n\nB")
        #expect(Queries.joinRenderedTexts(["A\n\n", "B"]) == "A\n\n\nB")
        #expect(Queries.joinRenderedTexts(["A\n", "B\n", "C"]) == "A\n\nB\n\nC")
    }

    @Test func renderedTextSkipsBlankTakes() throws {
        // Author decision 2026-07-06 (ratify item 1): a chosen-but-empty
        // variant contributes nothing to the whole-document projection —
        // never "a\n\n\n\nb" — while the editor's renderPost still shows
        // the blank slot.
        try withOperations { ops, db in
            let post = try ops.createPost()
            _ = try ops.newBlock(in: post.id, text: "a")
            let blank = try ops.newBlock(in: post.id, text: "placeholder")
            let blankTake = try ops.newBlankVariant(blank.block.id)
            try ops.chooseVariant(blank.block.id, variantID: blankTake.id)
            _ = try ops.newBlock(in: post.id, text: "b")

            let text = try db.read { try Queries.renderedText($0, containerID: post.id) }
            #expect(text == "a\n\nb")
            let rendered = try db.read { try Queries.renderPost($0, containerID: post.id) }
            #expect(rendered.count == 3)
            #expect(rendered[1].text == "")   // the editor still sees the blank slot
            #expect(!rendered[1].isGap)
        }
    }

    @Test func renderedTextSkipsGaps() throws {
        try withOperations { ops, db in
            let post = try ops.createPost()
            _ = try ops.newBlock(in: post.id, text: "before")
            let doomed = try ops.newBlock(in: post.id, text: "gap")
            _ = try ops.newBlock(in: post.id, text: "after")
            try db.write { db in
                try db.execute(
                    sql: "UPDATE container_block SET chosen_variant_id = NULL WHERE block_id = ?",
                    arguments: [doomed.block.id])
                try Fixture.tombstone(db, table: "variant", id: doomed.variant.id)
            }
            let text = try db.read { try Queries.renderedText($0, containerID: post.id) }
            #expect(text == "before\n\nafter")
        }
    }
}
