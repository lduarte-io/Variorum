import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 13b Stage 3, batch 3B — T5's core op: `setTakeLabel`, the
/// `setBlockName` precedent applied to a take (the column and its
/// renderers shipped long ago; the setter never existed). Identity-level
/// metadata: no touch/churn, no-op guard, nil/whitespace clears, sealed
/// post refuses, LOCKED take allowed (PROVISIONAL — the lock freezes the
/// buffer, not metadata), archived take allowed (the recovery listing is
/// where labels help most).
@Suite("variant.label & setTakeLabel (Phase 13b, 3B)")
struct TakeLabelTests {
    /// A post with one block and a branched second take (the label target —
    /// not chosen, not the default, so archive/delete stay legal on it).
    private func fixture(
        _ ops: Operations
    ) throws -> (postID: String, blockID: String, takeID: String) {
        let post = try ops.createPost(title: "post", profile: .generic)
        let minted = try ops.newBlock(in: post.id, text: "Some prose.", at: .end)
        let take = try ops.branchVariant(minted.block.id, from: minted.variant.id)
        return (post.id, minted.block.id, take.id)
    }

    @Test func setTakeLabelSetsClearsAndNormalizesWhitespace() throws {
        try withOperations { ops, db in
            let (_, _, takeID) = try fixture(ops)

            try ops.setTakeLabel(takeID, label: "the quiet ending")
            #expect(try db.fetchString(
                "SELECT label FROM variant WHERE id = ?", [takeID]) == "the quiet ending")

            try ops.setTakeLabel(takeID, label: "   ")
            #expect(try db.fetchString(
                "SELECT label FROM variant WHERE id = ?", [takeID]) == nil,
                "whitespace-only normalizes to clearing")

            try ops.setTakeLabel(takeID, label: "  padded  ")
            #expect(try db.fetchString(
                "SELECT label FROM variant WHERE id = ?", [takeID]) == "padded")

            try ops.setTakeLabel(takeID, label: nil)
            #expect(try db.fetchString(
                "SELECT label FROM variant WHERE id = ?", [takeID]) == nil,
                "explicit nil clears")
        }
    }

    @Test func labelingIsMetadataNeverATouchStampOrChurn() throws {
        try withOperations { ops, db in
            let (postID, _, takeID) = try fixture(ops)
            let touchedBefore = try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [postID])
            let churnBefore = try db.fetchString(
                "SELECT churn_accumulator FROM container WHERE id = ?", [postID])

            try ops.setTakeLabel(takeID, label: "a name")

            #expect(try db.fetchString(
                "SELECT last_touched_at FROM container WHERE id = ?", [postID]) == touchedBefore,
                "labeling never reshuffles the touched sort")
            #expect(try db.fetchString(
                "SELECT churn_accumulator FROM container WHERE id = ?", [postID]) == churnBefore)
        }
    }

    @Test func labelingRidesTheExistingVariantOutboxTriggers() throws {
        try withOperations { ops, db in
            let (_, _, takeID) = try fixture(ops)
            try db.clearOutbox()

            try ops.setTakeLabel(takeID, label: "handle")
            #expect(try db.outboxContains("variant", takeID),
                    "the label UPDATE is captured by the existing variant triggers (verified, not assumed)")
        }
    }

    @Test func aSealedPostRefusesTakeLabeling() throws {
        // The seal refuses everything under the post (Phase 2's ratified
        // scope) — a take is under the post via its block's placement.
        try withOperations { ops, _ in
            let (postID, _, takeID) = try fixture(ops)
            try ops.lockPost(postID)
            #expect(throws: OperationError.lockedPost(id: postID)) {
                try ops.setTakeLabel(takeID, label: "too late")
            }
        }
    }

    @Test func aLockedTakeStillTakesALabel() throws {
        // PROVISIONAL (batch 3B, recorded for the checkpoint walk): the
        // lock freezes the BUFFER; identity metadata stays editable — and
        // labeling must never mint a commit (the lock's insurance commit
        // belongs to the lock gesture, not to naming).
        try withOperations { ops, db in
            let (_, _, takeID) = try fixture(ops)
            try ops.lockVariant(takeID)
            let commitsBefore = try db.fetchInt(
                "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [takeID])

            try ops.setTakeLabel(takeID, label: "locked but named")

            #expect(try db.fetchString(
                "SELECT label FROM variant WHERE id = ?", [takeID]) == "locked but named")
            #expect(try db.fetchInt(
                "SELECT locked FROM variant WHERE id = ?", [takeID]) == 1,
                "the lock stands")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM commit_point WHERE variant_id = ?", [takeID])
                == commitsBefore,
                "labeling mints no commit")
        }
    }

    @Test func anArchivedTakeStillTakesALabel() throws {
        // 3B judgment call: the archived listing (T5's Stage 3 face) is
        // exactly where a label helps identify a take.
        try withOperations { ops, db in
            let (_, _, takeID) = try fixture(ops)
            try ops.archiveVariant(takeID)

            try ops.setTakeLabel(takeID, label: "the shelved one")
            #expect(try db.fetchString(
                "SELECT label FROM variant WHERE id = ?", [takeID]) == "the shelved one")
            #expect(try db.fetchString(
                "SELECT status FROM variant WHERE id = ?", [takeID]) == "archived",
                "labeling never resurrects")
        }
    }

    @Test func deadTakesRefuse() throws {
        try withOperations { ops, _ in
            let (_, _, takeID) = try fixture(ops)
            try ops.deleteVariant(takeID)
            #expect(throws: OperationError.variantNotFound(id: takeID)) {
                try ops.setTakeLabel(takeID, label: "gone")
            }
        }
    }

    @Test func aNoOpRelabelWritesNothing() throws {
        try withOperations { ops, db in
            let (_, _, takeID) = try fixture(ops)
            try ops.setTakeLabel(takeID, label: "same")
            let updatedBefore = try db.fetchString(
                "SELECT updated_at FROM variant WHERE id = ?", [takeID])
            try db.clearOutbox()

            try ops.setTakeLabel(takeID, label: "same")
            #expect(try db.fetchString(
                "SELECT updated_at FROM variant WHERE id = ?", [takeID]) == updatedBefore)
            #expect(!(try db.outboxContains("variant", takeID)),
                    "an identical label never dirties the row")
        }
    }

    @Test func aLabelSetThroughTheOpReachesTheAlternatesSection() throws {
        // The op feeds the SHIPPED renderers: the export "Alternates"
        // section names a labeled take `take: "<label>"` (Phase 11b's
        // ratified fan shape) — end to end through the new setter.
        try withOperations { ops, db in
            let (_, blockID, takeID) = try fixture(ops)
            try ops.autosave(takeID, text: "An alternate ending.", charDelta: 20)
            try ops.setTakeLabel(takeID, label: "quiet ending")

            let exported = try db.read { try Queries.exportBlock($0, blockID: blockID) }
            #expect(exported.contains("take: \"quiet ending\""))
        }
    }
}
