import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// **WHAT A RESTORE TAKES THAT NO VERSION HOLDS** (13u3 UNIT E — item 15(a),
/// her #80(e) ratification: *"keep as built — defensible, and the confirm can
/// name it"*).
///
/// These pins exist because the confirm's sentence is only as honest as the
/// read under it, and because the ratified analysis this unit was sent to face
/// turned out to describe a mechanism the operation no longer has. Both facts
/// are pinned here — what the road really takes, and why the ancestors it was
/// said to take survive — so a future change to either says so out loud.
@Suite("What a restore takes (13u3 UNIT E, item 15(a))")
struct RestoreCostTests {
    /// The janitor's own expansion over every standing intent — the technique
    /// `NoteVersionsTests` uses, for the same reason: the consequence driven
    /// rather than argued.
    private func standingFamily(_ db: AppDatabase) throws -> PurgeFamily.Expansion {
        try db.read { db in
            let roots = try Row.fetchAll(
                db,
                sql: """
                    SELECT table_name, row_id FROM purge_intent
                    WHERE deleted_at IS NULL ORDER BY id
                    """
            ).map { SyncPurgeTarget(table: $0["table_name"], rowID: $0["row_id"]) }
            return try PurgeFamily.expand(db, roots: roots)
        }
    }

    private func sweepStandingIntents(_ db: AppDatabase) throws {
        try db.write { db in
            try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
            let roots = try Row.fetchAll(
                db,
                sql: """
                    SELECT table_name, row_id FROM purge_intent
                    WHERE deleted_at IS NULL ORDER BY id
                    """
            ).map { SyncPurgeTarget(table: $0["table_name"], rowID: $0["row_id"]) }
            guard !roots.isEmpty else { return }
            let family = try PurgeFamily.expand(db, roots: roots)
            try PurgeFamily.deleteLocal(
                db, family: family, stamp: "2026-09-19T00:00:00.000Z")
        }
    }

    // MARK: - The counts the confirm speaks

    /// **THE HISTORY GOES, AND THE WORDS DO NOT.** The measured heart of
    /// item 15(a): a note worked in since its moment carries savepoints, a
    /// deleted take and a deleted comment, and the Delete Now road takes all
    /// three — while the version of NOW carries the words of every take.
    @Test func theCostNamesTheHistoryTheRoadTakesAndTheVersionDoesNotHold() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note", profile: .generic)
            let block = try ops.newBlock(in: note.id, text: "A paragraph.", at: .end)
            let moment = try ops.saveNoteVersion(note.id).post

            // …and then she works in it.
            try ops.autosave(block.variant.id, text: "A paragraph, rewritten.", charDelta: 11)
            _ = try ops.commit(block.variant.id, message: "the good wording")
            try ops.autosave(block.variant.id, text: "Rewritten twice.", charDelta: 7)
            _ = try ops.commit(block.variant.id, message: "the better wording")
            let spare = try ops.branchVariant(block.block.id, from: block.variant.id)
            try ops.autosave(spare.id, text: "A different angle.", charDelta: 18)
            _ = try ops.commit(spare.id, message: "the angle")
            let doomedTake = try ops.branchVariant(block.block.id, from: block.variant.id)
            try ops.autosave(doomedTake.id, text: "A take I deleted.", charDelta: 17)
            try ops.deleteVariant(doomedTake.id)
            let comment = try ops.addBlockComment(to: block.block.id, text: "a note to self")
            try ops.deleteBlockComment(comment.id)

            let cost = try db.read { try Queries.restoreCost($0, of: note.id) }
            #expect(cost.outgoingBlocks == 1)
            #expect(cost.savedMoments == 3, "three savepoints she pressed for")
            #expect(cost.deletedTakes == 1, "…and one take waiting in this block's History")
            #expect(cost.deletedComments == 1)
            #expect(!cost.isEmpty, "so the confirm has something to say")

            // The road, driven.
            _ = try ops.restoreNoteVersion(note.id, from: moment.id)
            try sweepStandingIntents(db)

            #expect(try db.read {
                try Int.fetchOne(
                    $0, sql: "SELECT COUNT(*) FROM commit_point WHERE message = ?",
                    arguments: ["the good wording"])
            } == 0, "her savepoints are gone — nothing puts them back")
            #expect(try db.read {
                try Int.fetchOne(
                    $0, sql: "SELECT COUNT(*) FROM variant WHERE id = ?",
                    arguments: [doomedTake.id])
            } == 0, "…and so is the deleted take that was waiting")

            // What the version DID keep: the words of every take, and one
            // fresh insurance savepoint each (the seal's own occasion), never
            // her run of moments.
            let saved = try db.read { try Queries.noteVersions($0, of: note.id) }
            #expect(saved.count == 2, "the moment she restored, and the one of NOW")
            let nowMoment = try #require(saved.first { $0.postID != moment.id })
            let carried = try db.read { db -> (takes: Int, savepoints: Int) in
                let takes = try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM variant v
                        JOIN container_block cb ON cb.block_id = v.block_id
                        WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                          AND v.deleted_at IS NULL
                        """,
                    arguments: [nowMoment.postID]) ?? 0
                let savepoints = try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM commit_point c
                        JOIN variant v ON v.id = c.variant_id
                        JOIN container_block cb ON cb.block_id = v.block_id
                        WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                        """,
                    arguments: [nowMoment.postID]) ?? 0
                return (takes, savepoints)
            }
            #expect(carried.takes == 2, "both live takes' words rode into the moment")
            #expect(carried.savepoints == 2,
                    """
                    one insurance savepoint per copied take (the seal's occasion) \
                    — never the three she wrote
                    """)
        }
    }

    /// **A NOTE NOBODY HAS WORKED IN COSTS NOTHING**, and the confirm stays
    /// exactly the sentence it has always been.
    @Test func anUntouchedNoteTakesNothingAVersionDoesNotAlreadyHold() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note", profile: .generic)
            _ = try ops.newBlock(in: note.id, text: "A paragraph.", at: .end)
            _ = try ops.saveNoteVersion(note.id)

            let cost = try db.read { try Queries.restoreCost($0, of: note.id) }
            #expect(cost.outgoingBlocks == 1)
            #expect(cost.isEmpty, "nothing here is held anywhere but the words")
            #expect(cost.savedMoments == 0 && cost.deletedTakes == 0
                && cost.deletedComments == 0 && cost.setAsideOriginals.isEmpty)
        }
    }

    /// **THE READ IS THE NOTE'S, NOT THE CORPUS'S (P1).** Every number is
    /// scoped to this note's own live placements — a library full of other
    /// notes' history cannot move it by one.
    @Test func theCostIsScopedToItsNoteAndNeverToTheCorpus() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note", profile: .generic)
            let block = try ops.newBlock(in: note.id, text: "A paragraph.", at: .end)
            _ = try ops.commit(block.variant.id, message: "mine")
            let before = try db.read { try Queries.restoreCost($0, of: note.id) }

            for index in 0..<8 {
                let other = try ops.createPost(title: "other \(index)", profile: .generic)
                let theirs = try ops.newBlock(in: other.id, text: "Their prose.", at: .end)
                for round in 0..<3 {
                    _ = try ops.commit(theirs.variant.id, message: "theirs \(round)")
                }
                let spare = try ops.branchVariant(theirs.block.id, from: theirs.variant.id)
                try ops.deleteVariant(spare.id)
            }

            let after = try db.read { try Queries.restoreCost($0, of: note.id) }
            #expect(after == before, "24 savepoints and 8 deleted takes elsewhere: no change")
            #expect(after.savedMoments == 1)
        }
    }

    /// **RED-ON-OLD (VX-179 — the fence, applied to population 3).** A
    /// comment she already deleted forever ("Delete forever…" in the panel's
    /// deleted fold) is no longer "still restorable": no door brings it back,
    /// so the restore's confirm must not count it as something the road
    /// would take from her. Without the `NOT EXISTS` arm the count stays 2.
    @Test func aCommentDeletedForeverIsNotCountedAsStillRestorable() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note", profile: .generic)
            let block = try ops.newBlock(in: note.id, text: "A paragraph.", at: .end)
            let gone = try ops.addBlockComment(to: block.block.id, text: "deleted forever")
            let waiting = try ops.addBlockComment(to: block.block.id, text: "still restorable")
            try ops.deleteBlockComment(gone.id)
            try ops.deleteBlockComment(waiting.id)
            #expect(try db.read { try Queries.restoreCost($0, of: note.id) }.deletedComments == 2)

            _ = try ops.requestPurge([SyncPurgeTarget(table: "block_comment", rowID: gone.id)])

            let cost = try db.read { try Queries.restoreCost($0, of: note.id) }
            #expect(cost.deletedComments == 1,
                    "the confirm counts only what the panel can still restore")
        }
    }

    // MARK: - The set-aside originals (population 4)

    /// **THE MIRROR'S DRIFT GUARD.** `Queries.setAsideOriginals` writes
    /// `PurgeFamily.joinStrandedOriginals`' predicate a second time (the Sync
    /// fence — see `RestoreCost.swift`'s header), so the two are asserted
    /// EQUAL on the shapes where the population is real: a divide-W's
    /// preserved original when its whole family goes, and the FIXPOINT case
    /// where an original joining strands its own original in turn.
    @Test func theSetAsideReadAgreesWithThePurgeFamilyItMirrors() throws {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note", profile: .generic)
            let made = try ops.newBlock(
                in: note.id, text: "First sentence. Second sentence.", at: .end)
            _ = try ops.branchVariant(made.block.id, from: made.variant.id)
            let first = try ops.divideW(made.block.id, cuts: [made.variant.id: 16])

            // A second divide-W on the first successor: now TWO originals sit
            // behind the live blocks, one behind the other.
            let middle = first.first.block.id
            let middleTake = try #require(first.first.variants.first).id
            _ = try ops.branchVariant(middle, from: middleTake)
            let second = try ops.divideW(middle, cuts: [middleTake: 6])

            let live = [second.first.block.id, second.second.block.id,
                        first.second.block.id]
            for block in live { try ops.deleteBlock(block) }

            let mine = try db.read { try Queries.setAsideOriginals($0, family: Set(live)) }
            let theirs = try db.read { db in
                try PurgeFamily.expand(
                    db, roots: live.map { SyncPurgeTarget(table: "block", rowID: $0) })
            }
            #expect(Set(mine) == theirs.strandedOriginals,
                    "the mirrored predicate and the purge's own answer, on one store")
            #expect(mine.count == 2, "the fixpoint: an original behind an original")
            #expect(Set(mine) == Set([made.block.id, middle]))
        }
    }

    /// **AND THE ONE THE RATIFICATION EXPECTED IS EMPTY, FOR A REASON WORTH
    /// PINNING.** #80(e) reads that a restore's Delete Now road takes the
    /// note's set-aside originals with it. It does not, and cannot while step
    /// 1 exists: the version of NOW copies EVERY outgoing block and each copy
    /// mints a `derived_from` edge back to it, so every outgoing block ends
    /// the transaction with a live descendant OUTSIDE the purge family —
    /// which is the exact condition `joinStrandedOriginals` requires to be
    /// absent. The original stays live, keeps listing in the note's tray, and
    /// survives a full physical sweep.
    ///
    /// Pinned rather than argued, and pinned at BOTH ends (the ancestor's
    /// survival and the mechanism that saves it), because the confirm's words
    /// were built on this measurement.
    @Test func aRestoreStrandsNoAncestorBecauseTheVersionOfNowIsTheirSurvivingDescendant()
        throws
    {
        try withOperations { ops, db in
            let note = try ops.createPost(title: "the note", profile: .generic)
            let made = try ops.newBlock(
                in: note.id, text: "First sentence. Second sentence.", at: .end)
            let spare = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.autosave(spare.id, text: "A take nothing else ever showed.", charDelta: 32)
            // The moment predates the divide, so the divide's successors are
            // exactly what the restore takes out.
            let moment = try ops.saveNoteVersion(note.id).post
            let divided = try ops.divideW(made.block.id, cuts: [made.variant.id: 16])

            let cost = try db.read { try Queries.restoreCost($0, of: note.id) }
            #expect(cost.setAsideOriginals.isEmpty,
                    "nothing is stranded, so the confirm must not say anything is")

            let outcome = try ops.restoreNoteVersion(note.id, from: moment.id)
            #expect(outcome.blocksRemoved == 2)

            let family = try standingFamily(db)
            #expect(family.strandedOriginals.isEmpty,
                    "the purge agrees: no ancestor joins this family")

            // THE MECHANISM: each outgoing block's surviving descendant is the
            // version of NOW's own copy of it.
            for outgoing in [divided.first.block.id, divided.second.block.id] {
                let descendants = try db.read {
                    try String.fetchAll(
                        $0,
                        sql: """
                            SELECT source_block_id FROM edge
                            WHERE target_block_id = ? AND type = 'derived_from'
                            """,
                        arguments: [outgoing])
                }
                #expect(descendants.count == 1)
                let home = try db.read {
                    try String.fetchOne(
                        $0,
                        sql: """
                            SELECT container_id FROM container_block
                            WHERE block_id = ? AND deleted_at IS NULL
                            """,
                        arguments: [descendants[0]])
                }
                #expect(home != nil && home != note.id,
                        "the descendant lives in the version of NOW, not in the note")
            }

            try sweepStandingIntents(db)
            #expect(try db.read {
                try Int.fetchOne(
                    $0, sql: "SELECT COUNT(*) FROM block WHERE id = ? AND deleted_at IS NULL",
                    arguments: [made.block.id])
            } == 1, "the preserved original survives the physical sweep")
            #expect(try db.read {
                try Queries.preservedOriginals($0, postID: note.id).map(\.blockID)
            } == [made.block.id], "…and still lists in the note's tray, takes and all")
        }
    }
}
