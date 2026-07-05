import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Tombstone cascades & outbox capture (Phase 1, Step 4)")
struct TriggerTests {
    let stamp = "2026-07-04T12:00:00.000Z"

    func deletedAt(_ db: AppDatabase, _ table: String, _ id: String) throws -> String? {
        try db.read { db in
            try String.fetchOne(db, sql: "SELECT deleted_at FROM \(table) WHERE id = ?", arguments: [id])
        }
    }

    // MARK: Cascades, one per parent

    @Test func blockTombstoneCascadesToVariantsPlacementEdgesAndBlockTags() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try Fixture.placedBlock(db, container: "c1", block: "b1", variant: "v1", cb: "cb1")
            try Fixture.variant(db, id: "v2", blockId: "b1", fanPosition: "W")
            try Fixture.block(db, id: "b2")
            try Fixture.edge(db, id: "eOut", source: "b1", target: "b2")
            try Fixture.edge(db, id: "eIn", source: "b2", target: "b1", type: "version_of")
            try Fixture.tag(db, id: "t1", name: "x", path: "x")
            try Fixture.blockTag(db, id: "bt1", tagId: "t1", blockId: "b1")
        }
        try db.write { db in try Fixture.tombstone(db, table: "block", id: "b1", at: stamp) }

        // Every live child is stamped with the block's exact deleted_at
        // (restoreBlock identifies cascade victims by this equality).
        for (table, id) in [("variant", "v1"), ("variant", "v2"), ("container_block", "cb1"),
                            ("edge", "eOut"), ("edge", "eIn"), ("block_tag", "bt1")] {
            #expect(try deletedAt(db, table, id) == stamp, "\(table) \(id) not cascade-tombstoned")
        }
        // Bystanders untouched.
        #expect(try deletedAt(db, "block", "b2") == nil)
        #expect(try deletedAt(db, "tag", "t1") == nil)
    }

    @Test func containerTombstoneCascadesThroughTheWholeChainInOneTransaction() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            // A post with two placed blocks, variants, an edge between them,
            // a block tag, a reading membership, a post tag, and a reference.
            try Fixture.container(db, id: "c1")
            for (block, variant, cb) in [("b1", "v1", "cb1"), ("b2", "v2", "cb2")] {
                try Fixture.block(db, id: block)
                try Fixture.variant(db, id: variant, blockId: block)
                try Fixture.containerBlock(db, id: cb, containerId: "c1", blockId: block, position: block)
            }
            try Fixture.edge(db, id: "e1", source: "b2", target: "b1")
            try Fixture.tag(db, id: "t1", name: "x", path: "x")
            try Fixture.blockTag(db, id: "bt1", tagId: "t1", blockId: "b1")
            try Fixture.postTag(db, id: "pt1", tagId: "t1", postId: "c1")
            try Fixture.reading(db, id: "r1")
            try Fixture.readingPost(db, id: "rp1", readingId: "r1", postId: "c1")
            try Fixture.reference(db, id: "ref1", containerId: "c1")
        }
        try db.write { db in try Fixture.tombstone(db, table: "container", id: "c1", at: stamp) }

        for (table, id) in [
            ("container_block", "cb1"), ("container_block", "cb2"),
            ("block", "b1"), ("block", "b2"),
            ("variant", "v1"), ("variant", "v2"),
            ("edge", "e1"), ("block_tag", "bt1"),
            ("reading_post", "rp1"), ("post_tag", "pt1"), ("reference", "ref1"),
        ] {
            #expect(try deletedAt(db, table, id) == stamp, "\(table) \(id) not reached by the chain")
        }
        // The reading and tag themselves survive.
        #expect(try deletedAt(db, "reading", "r1") == nil)
        #expect(try deletedAt(db, "tag", "t1") == nil)
    }

    @Test func readingTombstoneCascadesToItsMemberships() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try Fixture.reading(db, id: "r1")
            try Fixture.container(db, id: "c1")
            try Fixture.readingPost(db, id: "rp1", readingId: "r1", postId: "c1")
        }
        try db.write { db in try Fixture.tombstone(db, table: "reading", id: "r1", at: stamp) }
        #expect(try deletedAt(db, "reading_post", "rp1") == stamp)
        // The post itself is untouched — readings never own posts.
        #expect(try deletedAt(db, "container", "c1") == nil)
    }

    @Test func tagTombstoneCascadesToItsApplicationsButNotItsSubtree() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try Fixture.tag(db, id: "t1", name: "life", path: "life")
            try Fixture.tag(db, id: "t2", name: "goals", path: "life/goals", parentId: "t1")
            try Fixture.container(db, id: "c1")
            try Fixture.block(db, id: "b1")
            try Fixture.postTag(db, id: "pt1", tagId: "t1", postId: "c1")
            try Fixture.blockTag(db, id: "bt1", tagId: "t1", blockId: "b1")
        }
        try db.write { db in try Fixture.tombstone(db, table: "tag", id: "t1", at: stamp) }
        #expect(try deletedAt(db, "post_tag", "pt1") == stamp)
        #expect(try deletedAt(db, "block_tag", "bt1") == stamp)
        // Subtree deletion is an operations-layer loop (Phase 2), NOT a trigger.
        #expect(try deletedAt(db, "tag", "t2") == nil)
    }

    @Test func alreadyTombstonedRowsKeepTheirOriginalDeletedAt() throws {
        let earlier = "2026-07-01T00:00:00.000Z"
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try Fixture.placedBlock(db, container: "c1", block: "b1", variant: "v1", cb: "cb1")
            try Fixture.variant(db, id: "v2", blockId: "b1", fanPosition: "W")
            try Fixture.tombstone(db, table: "variant", id: "v2", at: earlier)
        }
        try db.write { db in try Fixture.tombstone(db, table: "block", id: "b1", at: stamp) }
        #expect(try deletedAt(db, "variant", "v1") == stamp)
        #expect(try deletedAt(db, "variant", "v2") == earlier, "cascade overwrote an independent tombstone")
    }

    /// The container cascade's `id IN (SELECT block_id FROM container_block …)`
    /// scans rows that the block trigger (fired mid-statement) is itself
    /// tombstoning. Guards the subquery against a "simplification" that would
    /// expose it to update-while-scanning effects.
    @Test func containerCascadeReachesManyBlocks() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try Fixture.container(db, id: "c1")
            for i in 1...8 {
                try Fixture.block(db, id: "b\(i)")
                try Fixture.variant(db, id: "v\(i)", blockId: "b\(i)")
                try Fixture.containerBlock(db, id: "cb\(i)", containerId: "c1", blockId: "b\(i)", position: String(format: "%02d", i))
            }
            try Fixture.tombstone(db, table: "container", id: "c1", at: stamp)
        }
        let (liveBlocks, liveVariants, liveCBs) = try db.read { db in
            (try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM block WHERE deleted_at IS NULL")!,
             try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM variant WHERE deleted_at IS NULL")!,
             try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container_block WHERE deleted_at IS NULL")!)
        }
        #expect(liveBlocks == 0)
        #expect(liveVariants == 0)
        #expect(liveCBs == 0)
    }

    /// Re-tombstoning an already-dead block (deleted_at value→value — the
    /// `UPDATE OF deleted_at` clause DOES fire) must not re-cascade onto a
    /// child revived in the meantime: only the NULL→value transition cascades.
    /// This is exactly the world a partial `restoreBlock` (Phase 2) creates.
    @Test func reTombstoningADeadBlockDoesNotReCascade() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try Fixture.placedBlock(db, container: "c1", block: "b1", variant: "v1", cb: "cb1")
            try Fixture.tombstone(db, table: "block", id: "b1", at: "2026-07-01T00:00:00.000Z")
            try db.execute(sql: "UPDATE variant SET deleted_at = NULL WHERE id = 'v1'")
            try db.execute(sql: "UPDATE block SET deleted_at = '2026-07-02T00:00:00.000Z' WHERE id = 'b1'")
        }
        #expect(try deletedAt(db, "variant", "v1") == nil, "value→value tombstone re-fired the cascade")
    }

    @Test func cascadeIsTransitionGuardedNotRetriggeredByOtherUpdates() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try Fixture.placedBlock(db, container: "c1", block: "b1", variant: "v1", cb: "cb1")
            try Fixture.tombstone(db, table: "block", id: "b1", at: stamp)
            // Un-tombstone the variant by hand (what restoreBlock will do),
            // then touch the still-dead block with a non-transition update.
            try db.execute(sql: "UPDATE variant SET deleted_at = NULL WHERE id = 'v1'")
            try db.execute(sql: "UPDATE block SET updated_at = '2026-07-05T00:00:00.000Z' WHERE id = 'b1'")
        }
        // NULL→value never re-fired (the block was already dead): v1 stays live.
        #expect(try deletedAt(db, "variant", "v1") == nil)
    }

    // MARK: Outbox capture

    /// Outbox contents as "table:row_id" strings, sorted.
    func outboxRows(_ db: AppDatabase) throws -> [String] {
        try db.read { db in
            try Row.fetchAll(db, sql: "SELECT table_name, row_id FROM sync_outbox ORDER BY table_name, row_id")
                .map { "\($0["table_name"] as String):\($0["row_id"] as String)" }
        }
    }

    func clearOutbox(_ db: AppDatabase) throws {
        try db.write { db in try db.execute(sql: "DELETE FROM sync_outbox") }
    }

    @Test func outboxCapturesDirectInsertsAndUpdates() throws {
        let db = try AppDatabase.inMemory()
        try clearOutbox(db)  // drop the seed rows' entries
        try db.write { db in try Fixture.container(db, id: "c1") }
        #expect(try outboxRows(db) == ["container:c1"])

        // queued_at is trigger-written with SQLite's clock: local-only
        // bookkeeping, but it should stay in the canonical timestamp shape.
        let queuedAt = try db.read { db in
            try String.fetchOne(db, sql: "SELECT queued_at FROM sync_outbox")!
        }
        #expect(queuedAt.wholeMatch(of: /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z/) != nil,
                "queued_at drifted from the canonical format: \(queuedAt)")

        try db.write { db in
            try db.execute(sql: "UPDATE container SET title = 'hello' WHERE id = 'c1'")
        }
        // INSERT OR REPLACE coalesced: still exactly one row.
        #expect(try outboxRows(db) == ["container:c1"])
    }

    @Test func settingWritesEnqueueByKey() throws {
        let db = try AppDatabase.inMemory()
        // The migration seeds are themselves captured — settings are synced.
        let seeded = try outboxRows(db).filter { $0.hasPrefix("setting:") }.sorted()
        #expect(seeded == ["setting:default_segmentation", "setting:idle_commit_hours", "setting:major_revision_threshold"])
    }

    @Test func outboxCapturesCascadeProducedWrites() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try Fixture.placedBlock(db, container: "c1", block: "b1", variant: "v1", cb: "cb1")
        }
        try clearOutbox(db)

        try db.write { db in try Fixture.tombstone(db, table: "block", id: "b1") }
        let rows = try outboxRows(db)
        // The direct write AND every cascade-produced write are enqueued —
        // the originating device ships everything (SyncSpec §3).
        #expect(rows.contains("block:b1"))
        #expect(rows.contains("variant:v1"))
        #expect(rows.contains("container_block:cb1"))
    }

    @Test func repeatedUpdatesCoalesceToOneOutboxRow() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try Fixture.placedBlock(db, container: "c1", block: "b1", variant: "v1", cb: "cb1")
        }
        try clearOutbox(db)
        // Keystroke-rate autosaves: many UPDATEs to one row.
        for i in 1...5 {
            try db.write { db in
                try db.execute(sql: "UPDATE variant SET working_text = ? WHERE id = 'v1'", arguments: ["draft \(i)"])
            }
        }
        #expect(try outboxRows(db) == ["variant:v1"])
    }

    @Test func applyingRemoteSuppressesOutboxWhileCascadesStillFire() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try Fixture.placedBlock(db, container: "c1", block: "b1", variant: "v1", cb: "cb1")
        }
        try clearOutbox(db)

        try db.applyingRemote { db in
            try Fixture.container(db, id: "c2")                       // direct insert
            try Fixture.tombstone(db, table: "block", id: "b1")       // fires the cascade
        }
        // Echo suppression: zero outbox rows from anything inside apply —
        // including the cascade-produced writes.
        #expect(try outboxRows(db).isEmpty)
        // But the cascades themselves DID fire (SyncSpec §3: they stay active).
        #expect(try deletedAt(db, "variant", "v1") != nil)
        #expect(try deletedAt(db, "container_block", "cb1") != nil)

        // And capture resumes on the next ordinary write.
        try db.write { db in
            try db.execute(sql: "UPDATE container SET title = 'back' WHERE id = 'c2'")
        }
        #expect(try outboxRows(db) == ["container:c2"])
    }

    /// The Phase 5 trap (SyncSpec §4): after a successful push, the engine
    /// records the new `sync_version` locally. Done as a bare UPDATE, that
    /// write re-enqueues the row it just pushed — an infinite push loop. The
    /// bump must run in apply mode. This test documents both halves so the
    /// engine phase inherits the fact, not the outage.
    @Test func syncVersionBumpMustRunSuppressedOrItReEnqueues() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in try Fixture.container(db, id: "c1") }
        try clearOutbox(db)

        // The naive engine write: re-enqueues (the trap exists).
        try db.write { db in
            try db.execute(sql: "UPDATE container SET sync_version = 7 WHERE id = 'c1'")
        }
        #expect(try outboxRows(db) == ["container:c1"])

        // The correct engine write: suppressed, outbox stays empty.
        try clearOutbox(db)
        try db.applyingRemote { db in
            try db.execute(sql: "UPDATE container SET sync_version = 8 WHERE id = 'c1'")
        }
        #expect(try outboxRows(db).isEmpty)
    }
}
