import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// 13u3 UNIT D — **named commits** (master plan item 14; her ruling
/// R-13u3-1, *"Editable"*): the one normalisation rule, and
/// `renameCommitPoint`'s exact state transitions.
///
/// `commit_point.message` has existed since v1 and no face ever wrote it, so
/// these are a NEW CAPABILITY's pins, not a defect's — the unit record says
/// so in its own words. What they hold is the boundary the op draws: the
/// snapshot TEXT is immutable (I5), the NAME is metadata, and the metadata
/// conventions (`setTakeLabel`'s, one grain over) are honoured to the letter.
@Suite("Savepoint names & renameCommitPoint (13u3 UNIT D, item 14)")
struct SavepointNameTests {
    /// A post with one block, one take, and one deliberate savepoint.
    private func fixture(
        _ ops: Operations
    ) throws -> (postID: String, variantID: String, commitID: String) {
        let post = try ops.createPost(title: "post", profile: .generic)
        let minted = try ops.newBlock(in: post.id, text: "Some prose.", at: .end)
        let saved = try ops.commit(minted.variant.id)
        return (post.id, minted.variant.id, saved.id)
    }

    // MARK: - The one rule

    @Test func theNameRuleTrimsTheEndsAndKeepsTheInsideWhole() {
        #expect(SavepointName.normalized("before the AI edit") == "before the AI edit")
        #expect(SavepointName.normalized("  padded  ") == "padded")
        #expect(SavepointName.normalized("") == nil)
        #expect(SavepointName.normalized("   ") == nil, "whitespace-only is no name")
        #expect(SavepointName.normalized("\n\t ") == nil)
        #expect(SavepointName.normalized(nil) == nil)
        // Inside is hers: a name with a newline in it keeps the newline.
        #expect(SavepointName.normalized("  two\nlines  ") == "two\nlines")
    }

    // MARK: - The op's transitions

    @Test func renamingSetsClearsAndNormalizes() throws {
        try withOperations { ops, db in
            let (_, _, commitID) = try fixture(ops)
            #expect(try db.fetchString(
                "SELECT message FROM commit_point WHERE id = ?", [commitID]) == nil,
                "a savepoint is born unnamed unless the door names it")

            try ops.renameCommitPoint(commitID, message: "before the AI edit")
            #expect(try db.fetchString(
                "SELECT message FROM commit_point WHERE id = ?", [commitID])
                == "before the AI edit")

            try ops.renameCommitPoint(commitID, message: "  after a rethink  ")
            #expect(try db.fetchString(
                "SELECT message FROM commit_point WHERE id = ?", [commitID])
                == "after a rethink", "the ends are trimmed on the way in")

            try ops.renameCommitPoint(commitID, message: "   ")
            #expect(try db.fetchString(
                "SELECT message FROM commit_point WHERE id = ?", [commitID]) == nil,
                "clearing the field clears the name")

            try ops.renameCommitPoint(commitID, message: "named again")
            try ops.renameCommitPoint(commitID, message: nil)
            #expect(try db.fetchString(
                "SELECT message FROM commit_point WHERE id = ?", [commitID]) == nil,
                "explicit nil clears")
        }
    }

    @Test func renamingNeverTouchesTheSnapshotOrItsKind() throws {
        // **I5, as a pin:** the TEXT is the snapshot and nothing in this
        // family may reach it — and a renamed QUIET savepoint stays quiet,
        // which is what keeps its occasion visible where a face tells the
        // two kinds apart (her ruling's own note).
        try withOperations { ops, db in
            let post = try ops.createPost(title: "post", profile: .generic)
            let minted = try ops.newBlock(in: post.id, text: "The first words.", at: .end)
            try ops.autosave(minted.variant.id, text: "The first words, edited.", charDelta: 8)
            let quiet = try #require(try ops.idleAutoCommit(post.id).first)
            #expect(quiet.kind == .auto)

            try ops.renameCommitPoint(quiet.id, message: "the one before I left")

            #expect(try db.fetchString(
                "SELECT text FROM commit_point WHERE id = ?", [quiet.id])
                == "The first words, edited.", "the snapshot is untouched (I5)")
            #expect(try db.fetchString(
                "SELECT kind FROM commit_point WHERE id = ?", [quiet.id]) == "auto",
                "a renamed quiet savepoint is still quiet")
            #expect(try db.fetchString(
                "SELECT message FROM commit_point WHERE id = ?", [quiet.id])
                == "the one before I left")
        }
    }

    @Test func namingIsMetadataNeverATouchStampOrChurn() throws {
        try withOperations { ops, db in
            let (postID, _, commitID) = try fixture(ops)
            let touchedBefore = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [postID])
            let majorBefore = try db.fetchString(
                "SELECT last_major_revision_at FROM container WHERE id = ?", [postID])
            let churnBefore = try db.fetchString(
                "SELECT churn_accumulator FROM container WHERE id = ?", [postID])

            try ops.renameCommitPoint(commitID, message: "a name")

            #expect(try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [postID]) == touchedBefore,
                "naming a moment never reshuffles the touched sort")
            #expect(try db.fetchString(
                "SELECT last_major_revision_at FROM container WHERE id = ?", [postID])
                == majorBefore,
                "and never counts as a major revision (the COMMIT did that already)")
            #expect(try db.fetchString(
                "SELECT churn_accumulator FROM container WHERE id = ?", [postID]) == churnBefore)
        }
    }

    @Test func aNoOpRenameWritesNothingAtAll() throws {
        try withOperations { ops, db in
            let (_, _, commitID) = try fixture(ops)
            try ops.renameCommitPoint(commitID, message: "settled")
            try db.clearOutbox()

            try ops.renameCommitPoint(commitID, message: "settled")
            #expect(!(try db.outboxContains("commit_point", commitID)),
                    "the same name again writes no row and pushes nothing")
            // And the same for a clear on a savepoint that has no name.
            let variantID = try #require(try db.fetchString(
                "SELECT variant_id FROM commit_point WHERE id = ?", [commitID]))
            try ops.autosave(variantID, text: "Some prose, moved on.", charDelta: 10)
            let second = try ops.commit(variantID)
            try db.clearOutbox()
            try ops.renameCommitPoint(second.id, message: "   ")
            #expect(!(try db.outboxContains("commit_point", second.id)),
                    "clearing a name that was never set is a no-op too")
        }
    }

    @Test func renamingRidesTheExistingCommitPointOutboxTriggers() throws {
        try withOperations { ops, db in
            let (_, _, commitID) = try fixture(ops)
            try db.clearOutbox()

            try ops.renameCommitPoint(commitID, message: "handle")
            #expect(try db.outboxContains("commit_point", commitID),
                    "the message UPDATE is captured by the shipped commit_point triggers — verified, not assumed (the brief's sync fact, pinned)")
        }
    }

    @Test func aSealedPostRefusesRenaming() throws {
        // The seal refuses everything under the post (Phase 2's ratified
        // scope) — PROVISIONAL, QUESTIONS #121.
        try withOperations { ops, db in
            let (postID, _, commitID) = try fixture(ops)
            try ops.lockPost(postID)
            #expect(throws: OperationError.lockedPost(id: postID)) {
                try ops.renameCommitPoint(commitID, message: "too late")
            }
            #expect(try db.fetchString(
                "SELECT message FROM commit_point WHERE id = ?", [commitID]) == nil)
        }
    }

    @Test func aLockedTakeStillTakesASavepointName() throws {
        // PROVISIONAL (#121): the lock freezes the BUFFER, and a savepoint's
        // text is immutable anyway — naming one cannot reach what the lock
        // guards. `setTakeLabel`'s ratified precedent, one grain over.
        try withOperations { ops, db in
            let (_, variantID, commitID) = try fixture(ops)
            try ops.lockVariant(variantID)
            let commitsBefore = try db.fetchInt(
                "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [variantID])

            try ops.renameCommitPoint(commitID, message: "locked but named")

            #expect(try db.fetchString(
                "SELECT message FROM commit_point WHERE id = ?", [commitID])
                == "locked but named")
            #expect(try db.fetchInt(
                "SELECT locked FROM variant WHERE id = ?", [variantID]) == 1, "the lock stands")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [variantID])
                == commitsBefore, "naming mints no savepoint of its own")
        }
    }

    @Test func anArchivedTakesSavepointStillTakesAName() throws {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "post", profile: .generic)
            let minted = try ops.newBlock(in: post.id, text: "Some prose.", at: .end)
            let spare = try ops.branchVariant(minted.block.id, from: minted.variant.id)
            let saved = try ops.commit(spare.id)
            try ops.archiveVariant(spare.id)

            try ops.renameCommitPoint(saved.id, message: "from the shelved take")
            #expect(try db.fetchString(
                "SELECT message FROM commit_point WHERE id = ?", [saved.id])
                == "from the shelved take")
            #expect(try db.fetchString(
                "SELECT status FROM variant WHERE id = ?", [spare.id]) == "archived",
                "naming never resurrects")
        }
    }

    @Test func aMissingSavepointAndADeadTakeBothRefuse() throws {
        try withOperations { ops, _ in
            _ = try fixture(ops)
            #expect(throws: OperationError.commitNotFound(id: "nope")) {
                try ops.renameCommitPoint("nope", message: "x")
            }
            // A savepoint of a tombstoned take: no face offers one (Block
            // History lists LIVE takes' savepoints), so the throw is the
            // honest answer to a caller bug.
            let post = try ops.createPost(title: "second", profile: .generic)
            let minted = try ops.newBlock(in: post.id, text: "Some prose.", at: .end)
            let spare = try ops.branchVariant(minted.block.id, from: minted.variant.id)
            let spareCommit = try ops.commit(spare.id)
            try ops.deleteVariant(spare.id)
            #expect(throws: OperationError.variantNotFound(id: spare.id)) {
                try ops.renameCommitPoint(spareCommit.id, message: "gone")
            }
        }
    }

    // MARK: - The commit door's own parameter

    @Test func aSavepointCanBeBornNamedAndTheNameIsNormalizedThere() throws {
        // The field files through `commit(message:)`'s shipped parameter —
        // the op itself is untouched — and the ONE rule runs on that road
        // too, so "  " typed at the door is no name rather than a name made
        // of spaces.
        try withOperations { ops, db in
            let post = try ops.createPost(title: "post", profile: .generic)
            let minted = try ops.newBlock(in: post.id, text: "Some prose.", at: .end)

            let named = try ops.commit(minted.variant.id, message: "  before the AI edit  ")
            #expect(try db.fetchString(
                "SELECT message FROM commit_point WHERE id = ?", [named.id])
                == "before the AI edit")

            let skipped = try ops.commit(minted.variant.id, message: "   ")
            #expect(try db.fetchString(
                "SELECT message FROM commit_point WHERE id = ?", [skipped.id]) == nil,
                "⏎ on an empty field files the savepoint unnamed")
            #expect(try db.fetchString(
                "SELECT kind FROM commit_point WHERE id = ?", [skipped.id]) == "manual")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [minted.variant.id])
                == 2, "one savepoint per press, named or not")
        }
    }
}
