import Dependencies
import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// SyncSpec §7: every live-unique index (and both invariant-shaped races)
/// gets its deterministic apply-time repair. Each test asserts the trio the
/// spec demands: (a) the deterministic outcome, (b) both devices converge
/// on the same choice, (c) **the repair's outbox row exists** — a repair
/// that never pushes is silent divergence.
@Suite("Apply-time repairs (Phase 5, Step 6)")
struct SyncRepairTests {
    /// A + B sharing one fake server, with a synced starting world built by
    /// `seed` on A and pulled to B.
    private func twoDevices(
        seed: (Operations, AppDatabase) throws -> Void
    ) async throws -> (a: SyncClient, b: SyncClient, server: FakeSyncServer) {
        let server = FakeSyncServer()
        let a = try SyncClient(name: "A", prefix: "AA", transport: server)
        let b = try SyncClient(name: "B", prefix: "BB", transport: server, clockOffset: 1000, seed: 2)
        try a.with { ops, db in try seed(ops, db) }
        try await a.push()
        try await b.pull()
        try await b.push()  // settings seeds converge
        try await a.pull()
        return (a, b, server)
    }

    private func assertConverged(
        _ a: SyncClient, _ b: SyncClient, _ server: FakeSyncServer
    ) async throws {
        try await syncToQuiescence(a, b, server: server)
        #expect(try a.syncedDump() == b.syncedDump(), "converged devices must be byte-identical")
    }

    // MARK: - I2: move/move (place/place) race

    @Test func placementRaceConvergesToTheHigherSeq() async throws {
        let (a, b, server) = try await twoDevices { ops, _ in
            let post = try ops.createPost(title: "post", profile: nil)
            let b1 = try ops.newBlock(in: post.id, text: "one.", at: .end).block
            let b2 = try ops.newBlock(in: post.id, text: "two.", at: .end).block
            _ = try ops.merge(b1.id, b2.id)  // releases b1, b2: live, unplaced
        }
        let released = try a.db.fetchString(
            """
            SELECT b.id FROM block b WHERE b.deleted_at IS NULL AND NOT EXISTS
              (SELECT 1 FROM container_block cb WHERE cb.block_id = b.id AND cb.deleted_at IS NULL)
            ORDER BY b.id LIMIT 1
            """)!

        // Both devices re-place the same released block, offline.
        let placementA: String = try a.with { ops, _ in
            let home = try ops.createPost(title: "A's home", profile: nil)
            return try ops.placeBlock(released, in: home.id, at: .end).id
        }
        let placementB: String = try b.with { ops, _ in
            let home = try ops.createPost(title: "B's home", profile: nil)
            return try ops.placeBlock(released, in: home.id, at: .end).id
        }
        try await a.push()  // A's placement gets the LOWER seq
        try await b.push()  // B's the higher: later intent

        try await a.pull()
        // Deterministic outcome on A: B's placement (higher seq) won; A's
        // own placement was tombstoned by the repair — and the repair write
        // reached the outbox explicitly.
        #expect(try a.db.deletedAt("container_block", placementA) != nil)
        #expect(try a.db.deletedAt("container_block", placementB) == nil)
        #expect(try a.outboxContains("container_block", placementA),
                "the I2 repair must push or the devices silently diverge")

        try await b.pull()
        // Same choice on B: the incoming (lower-seq) rival lands tombstoned.
        #expect(try b.db.deletedAt("container_block", placementA) != nil)
        #expect(try b.db.deletedAt("container_block", placementB) == nil)
        #expect(try b.outboxContains("container_block", placementA))

        try await assertConverged(a, b, server)
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM container_block WHERE block_id = ? AND deleted_at IS NULL",
            [released]) == 1, "exactly one live placement survives (I2)")
    }

    // MARK: - tag.path duplicate

    @Test func duplicateTagPathsKeepTheLexicallySmallerID() async throws {
        let (a, b, server) = try await twoDevices { ops, _ in
            _ = try ops.createPost(title: "post", profile: nil)
        }
        let postID = try a.db.fetchString("SELECT id FROM container WHERE kind = 'post'")!

        // Both devices independently create "ideas" and apply it to the
        // same post. A's UUIDs (AA…) sort below B's (BB…), so A's tag is
        // the deterministic keeper everywhere.
        let tagA: String = try a.with { ops, _ in
            let tag = try ops.createTag(parent: nil, name: "ideas")
            _ = try ops.applyTag(tag.id, toPost: postID)
            return tag.id
        }
        let tagB: String = try b.with { ops, _ in
            let tag = try ops.createTag(parent: nil, name: "ideas")
            _ = try ops.applyTag(tag.id, toPost: postID)
            return tag.id
        }
        try await a.push()
        try await b.push()
        try await b.pull()

        // On B: the incoming (smaller-id) tag keeps; B's duplicate is
        // tombstoned, its application deduped against the keeper's, and
        // every repair write is enqueued.
        #expect(try b.db.deletedAt("tag", tagB) != nil)
        #expect(try b.db.deletedAt("tag", tagA) == nil)
        #expect(try b.outboxContains("tag", tagB))

        try await assertConverged(a, b, server)
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM tag WHERE path = 'ideas' AND deleted_at IS NULL") == 1)
        #expect(try a.db.fetchInt(
            """
            SELECT COUNT(*) FROM post_tag WHERE post_id = ? AND deleted_at IS NULL
            """, [postID]) == 1, "one live application survives, pointing at the keeper")
        #expect(try a.db.fetchString(
            "SELECT tag_id FROM post_tag WHERE post_id = ? AND deleted_at IS NULL", [postID]) == tagA)
    }

    // MARK: - Pure duplicates: edge (incl. reversed version_of), reading_post, post_tag

    @Test func reversedVersionOfEdgesAreDuplicatesKeepingTheSmallerID() async throws {
        let (a, b, server) = try await twoDevices { ops, _ in
            let post = try ops.createPost(title: "post", profile: nil)
            _ = try ops.newBlock(in: post.id, text: "one.", at: .end)
            _ = try ops.newBlock(in: post.id, text: "two.", at: .end)
        }
        let blocks = try await a.db.read { db in
            try String.fetchAll(db, sql: "SELECT id FROM block ORDER BY id")
        }
        // No operation mints version_of yet (KnownIssues, Phase 11); the
        // repair must still hold for hand-made rows — including a REVERSED
        // pair, which the canonical (min,max) storage rule makes the same
        // relationship (SyncSpec §7, review #8).
        try a.with { _, db in
            try db.write { db in
                try Fixture.edge(db, id: "AA-edge", source: blocks[0], target: blocks[1], type: "version_of")
            }
        }
        try b.with { _, db in
            try db.write { db in
                try Fixture.edge(db, id: "BB-edge", source: blocks[1], target: blocks[0], type: "version_of")
            }
        }
        try await a.push()
        try await b.push()
        try await b.pull()

        #expect(try b.db.deletedAt("edge", "BB-edge") != nil)
        #expect(try b.db.deletedAt("edge", "AA-edge") == nil)
        #expect(try b.outboxContains("edge", "BB-edge"))

        try await assertConverged(a, b, server)
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM edge WHERE type = 'version_of' AND deleted_at IS NULL") == 1)
    }

    @Test func duplicateReadingMembershipsKeepTheSmallerID() async throws {
        let (a, b, server) = try await twoDevices { ops, _ in
            let post = try ops.createPost(title: "post", profile: nil)
            _ = try ops.createReading(name: "book", kind: .curated, maxPosts: nil)
            _ = post
        }
        let postID = try a.db.fetchString("SELECT id FROM container WHERE kind = 'post'")!
        let readingID = try a.db.fetchString("SELECT id FROM reading")!
        let membershipA: String = try a.with { ops, _ in
            try ops.addPostToReading(postID, to: readingID).id
        }
        let membershipB: String = try b.with { ops, _ in
            try ops.addPostToReading(postID, to: readingID).id
        }
        try await a.push()
        try await b.push()
        try await b.pull()

        let (keeper, loser) = membershipA < membershipB
            ? (membershipA, membershipB) : (membershipB, membershipA)
        #expect(try b.db.deletedAt("reading_post", loser) != nil)
        #expect(try b.db.deletedAt("reading_post", keeper) == nil)
        #expect(try b.outboxContains("reading_post", loser))

        try await assertConverged(a, b, server)
        #expect(try a.db.fetchInt(
            "SELECT COUNT(*) FROM reading_post WHERE deleted_at IS NULL") == 1)
    }

    // MARK: - I10: double-tombstone resurrection

    @Test func doubleTombstoneResurrectsTheHighestSeqVariantAsRescued() async throws {
        let (a, b, server) = try await twoDevices { ops, db in
            let post = try ops.createPost(title: "post", profile: nil)
            let made = try ops.newBlock(in: post.id, text: "the original", at: .end)
            _ = try ops.branchVariant(made.block.id, from: made.variant.id)
            // The slot renders the default (no chosen pointer), so either
            // variant is individually deletable.
            try db.write { db in
                try db.execute(sql: "UPDATE container_block SET chosen_variant_id = NULL")
            }
        }
        let blockID = try a.db.fetchString("SELECT id FROM block")!
        let fan = try await a.db.read { db in
            try String.fetchAll(
                db, sql: "SELECT id FROM variant WHERE block_id = ? ORDER BY fan_position", arguments: [blockID])
        }
        let (v1, v2) = (fan[0], fan[1])

        // A deletes v1 (v2 survives); B deletes v2 (v1 survives). Both legal
        // locally; tombstones-win would leave a live block with no live
        // variant — I10 violated with neither device breaking a rule.
        try a.with { ops, _ in try ops.deleteVariant(v1) }
        try b.with { ops, _ in try ops.deleteVariant(v2) }
        try await a.push()  // v1's tombstone: lower seq
        try await b.push()  // v2's tombstone: HIGHER seq

        try await a.pull()
        // Deterministic choice: resurrect the tombstoned variant with the
        // highest server_seq — v2 — status active, label 'rescued'.
        #expect(try a.db.deletedAt("variant", v2) == nil)
        #expect(try a.db.fetchString("SELECT label FROM variant WHERE id = ?", [v2]) == "rescued")
        #expect(try a.db.fetchString("SELECT status FROM variant WHERE id = ?", [v2]) == "active")
        #expect(try a.db.deletedAt("variant", v1) != nil, "the lower-seq tombstone stands")
        #expect(try a.outboxContains("variant", v2), "the resurrection must push")

        try await b.pull()
        #expect(try b.db.deletedAt("variant", v2) == nil, "B makes the SAME choice")
        #expect(try b.db.fetchString("SELECT label FROM variant WHERE id = ?", [v2]) == "rescued")

        try await assertConverged(a, b, server)
        // I10 + the default lifecycle hold in the converged world.
        #expect(try a.db.fetchInt(
            """
            SELECT COUNT(*) FROM block b WHERE b.deleted_at IS NULL AND NOT EXISTS (
              SELECT 1 FROM variant v WHERE v.block_id = b.id
                AND v.deleted_at IS NULL AND v.status = 'active')
            """) == 0)
        #expect(try a.db.fetchString(
            "SELECT default_variant_id FROM block WHERE id = ?", [blockID]) == v2,
            "the default re-points at the one live active variant")
    }

    /// PROVISIONAL (logged in QUESTIONS): the archive/archive race is the
    /// same I10 hole by a different door — SyncSpec §7 defines only the
    /// tombstone case, so the same doctrine is applied: deterministic
    /// rescue, never a block with no active take.
    @Test func archiveArchiveRaceRescuesByUnarchivingTheHighestSeq() async throws {
        let (a, b, server) = try await twoDevices { ops, _ in
            let post = try ops.createPost(title: "post", profile: nil)
            let made = try ops.newBlock(in: post.id, text: "the original", at: .end)
            _ = try ops.branchVariant(made.block.id, from: made.variant.id)
        }
        let fan = try await a.db.read { db in
            try String.fetchAll(db, sql: "SELECT id FROM variant ORDER BY fan_position")
        }
        try a.with { ops, _ in try ops.archiveVariant(fan[0]) }
        try b.with { ops, _ in try ops.archiveVariant(fan[1]) }
        try await a.push()
        try await b.push()
        try await a.pull()

        #expect(try a.db.fetchString("SELECT status FROM variant WHERE id = ?", [fan[1]]) == "active",
                "the higher-seq archived take is rescued back to active")
        #expect(try a.db.fetchString("SELECT label FROM variant WHERE id = ?", [fan[1]]) == "rescued")
        #expect(try a.db.fetchString("SELECT status FROM variant WHERE id = ?", [fan[0]]) == "archived")
        #expect(try a.outboxContains("variant", fan[1]))

        try await b.pull()
        #expect(try b.db.fetchString("SELECT status FROM variant WHERE id = ?", [fan[1]]) == "active")

        try await assertConverged(a, b, server)
    }

    // MARK: - Dangling pointers

    @Test func danglingChosenVariantIsNulledOnBothDevices() async throws {
        let (a, b, server) = try await twoDevices { ops, db in
            let post = try ops.createPost(title: "post", profile: nil)
            let made = try ops.newBlock(in: post.id, text: "the original", at: .end)
            _ = try ops.branchVariant(made.block.id, from: made.variant.id)
            try db.write { db in
                try db.execute(sql: "UPDATE container_block SET chosen_variant_id = NULL")
            }
        }
        let blockID = try a.db.fetchString("SELECT id FROM block")!
        let placementID = try a.db.fetchString("SELECT id FROM container_block")!
        let fan = try await a.db.read { db in
            try String.fetchAll(db, sql: "SELECT id FROM variant ORDER BY fan_position")
        }
        let v1 = fan[0]

        // B points the slot at v1 while A deletes v1 (fine on A, where the
        // slot shows the default). Different rows, both CAS-accepted;
        // RESTRICT never fires under soft delete (AppSpec §9 review #3).
        try b.with { ops, _ in try ops.chooseVariant(blockID, variantID: v1) }
        try a.with { ops, _ in try ops.deleteVariant(v1) }
        try await a.push()
        try await b.push()

        // A pulls B's chosen=v1 over a variant A knows is dead: the pointer
        // lands (FKs only need row existence), then the post-batch repair
        // NULLs it explicitly — and pushes.
        try await a.pull()
        #expect(try a.db.fetchString(
            "SELECT chosen_variant_id FROM container_block WHERE id = ?", [placementID]) == nil)
        #expect(try a.outboxContains("container_block", placementID),
                "the NULL repair must push")

        try await b.pull()
        // B received v1's tombstone: its own chosen pointer dangles → NULL.
        #expect(try b.db.fetchString(
            "SELECT chosen_variant_id FROM container_block WHERE id = ?", [placementID]) == nil)

        try await assertConverged(a, b, server)
        // The read layer renders the block through the default fallback.
        let postID = try a.db.fetchString("SELECT id FROM container WHERE kind = 'post'")!
        let rendered = try await a.db.read { db in
            try Queries.renderPost(db, containerID: postID)
        }
        #expect(rendered.first?.text == "the original")
    }

    @Test func defaultVariantArrivingDeadIsReassigned() async throws {
        let (a, b, server) = try await twoDevices { ops, db in
            let post = try ops.createPost(title: "post", profile: nil)
            let made = try ops.newBlock(in: post.id, text: "take one", at: .end)
            let v2 = try ops.branchVariant(made.block.id, from: made.variant.id)
            try ops.autosave(v2.id, text: "take two", charDelta: 4)
            try db.write { db in
                try db.execute(sql: "UPDATE container_block SET chosen_variant_id = NULL")
            }
        }
        let blockID = try a.db.fetchString("SELECT id FROM block")!
        let defaultID = try a.db.fetchString(
            "SELECT default_variant_id FROM block WHERE id = ?", [blockID])!

        // A deletes the default; A's own device reassigns locally and pushes
        // the fixed block row. To exercise the RECEIVING side's repair, a
        // "third device" then CAS-writes the block row back to the dead
        // default on the server (the §7 review-#2 shape: a block row naming
        // a variant that arrives tombstoned).
        try a.with { ops, _ in
            try ops.deleteVariant(defaultID)
        }
        try await a.push()
        var staleBlock = await server.currentRow(table: "block", rowID: blockID)!
        staleBlock.columns["default_variant_id"] = .text(defaultID)
        _ = try await server.push([staleBlock], activeKeyID: SyncTestKeys.corpusKeyID)

        try await b.pull()
        let bDefault = try b.db.fetchString(
            "SELECT default_variant_id FROM block WHERE id = ?", [blockID])
        #expect(bDefault != nil)
        #expect(bDefault != defaultID, "the dead-arriving default was reassigned")
        #expect(try b.db.fetchString(
            "SELECT status FROM variant WHERE id = ?", [bDefault ?? ""]) == "active")
        #expect(try b.outboxContains("block", blockID), "the reassignment must push")

        try await assertConverged(a, b, server)
        #expect(try a.db.fetchString(
            "SELECT default_variant_id FROM block WHERE id = ?", [blockID]) == bDefault)
    }
}
