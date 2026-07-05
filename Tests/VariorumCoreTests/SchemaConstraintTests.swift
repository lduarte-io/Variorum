import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Schema constraint behavior (Phase 1, Step 3)")
struct SchemaConstraintTests {
    // MARK: I2 — single ownership

    @Test func i2SecondLivePlacementForSameBlockFails() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try Fixture.placedBlock(db, container: "c1", block: "b1", variant: "v1", cb: "cb1")
            try Fixture.container(db, id: "c2")
        }
        #expect(expectConstraintViolation {
            try db.write { db in
                try Fixture.containerBlock(db, id: "cb2", containerId: "c2", blockId: "b1")
            }
        })
        // Tombstone the first placement → the same block can be placed again.
        try db.write { db in
            try Fixture.tombstone(db, table: "container_block", id: "cb1")
            try Fixture.containerBlock(db, id: "cb2", containerId: "c2", blockId: "b1")
        }
    }

    // MARK: I3 backstop — chosen_variant_id ON DELETE RESTRICT

    /// Precision (AppSpec §9, review #3): under soft-delete-everywhere,
    /// tombstones are UPDATEs and this RESTRICT never fires — it guards ONLY
    /// the future physical-purge/GC path. The *live* guard against deleting a
    /// shown variant is the operations-layer check; Phase 2's tests own it.
    @Test func restrictGuardsPhysicalDeleteOfChosenVariantOnly() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try Fixture.placedBlock(db, container: "c1", block: "b1", variant: "v1", cb: "cb1", chosen: true)
        }
        // Physical DELETE of a chosen variant → FK RESTRICT error.
        #expect(expectConstraintViolation {
            try db.write { db in
                try db.execute(sql: "DELETE FROM variant WHERE id = 'v1'")
            }
        })
        // Tombstoning the same variant is an UPDATE: RESTRICT does not fire.
        try db.write { db in
            try Fixture.tombstone(db, table: "variant", id: "v1")
        }
    }

    // MARK: Tombstone-then-recreate under every live-unique index

    @Test func tagPathCanBeRecreatedAfterTombstone() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in try Fixture.tag(db, id: "t1", name: "goals", path: "life/goals") }
        #expect(expectConstraintViolation {
            try db.write { db in try Fixture.tag(db, id: "t2", name: "goals", path: "life/goals") }
        })
        try db.write { db in
            try Fixture.tombstone(db, table: "tag", id: "t1")
            try Fixture.tag(db, id: "t2", name: "goals", path: "life/goals")
        }
    }

    @Test func edgeTripleCanBeRecreatedAfterTombstone() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try Fixture.block(db, id: "b1")
            try Fixture.block(db, id: "b2")
            try Fixture.edge(db, id: "e1", source: "b1", target: "b2")
        }
        #expect(expectConstraintViolation {
            try db.write { db in try Fixture.edge(db, id: "e2", source: "b1", target: "b2") }
        })
        try db.write { db in
            try Fixture.tombstone(db, table: "edge", id: "e1")
            try Fixture.edge(db, id: "e2", source: "b1", target: "b2")
        }
    }

    @Test func readingPostPairCanBeRecreatedAfterTombstone() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try Fixture.reading(db, id: "r1")
            try Fixture.container(db, id: "c1")
            try Fixture.readingPost(db, id: "rp1", readingId: "r1", postId: "c1")
        }
        #expect(expectConstraintViolation {
            try db.write { db in try Fixture.readingPost(db, id: "rp2", readingId: "r1", postId: "c1") }
        })
        try db.write { db in
            try Fixture.tombstone(db, table: "reading_post", id: "rp1")
            try Fixture.readingPost(db, id: "rp2", readingId: "r1", postId: "c1")
        }
    }

    @Test func postTagAndBlockTagPairsCanBeRecreatedAfterTombstone() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try Fixture.tag(db, id: "t1", name: "x", path: "x")
            try Fixture.container(db, id: "c1")
            try Fixture.block(db, id: "b1")
            try Fixture.postTag(db, id: "pt1", tagId: "t1", postId: "c1")
            try Fixture.blockTag(db, id: "bt1", tagId: "t1", blockId: "b1")
        }
        #expect(expectConstraintViolation {
            try db.write { db in try Fixture.postTag(db, id: "pt2", tagId: "t1", postId: "c1") }
        })
        #expect(expectConstraintViolation {
            try db.write { db in try Fixture.blockTag(db, id: "bt2", tagId: "t1", blockId: "b1") }
        })
        try db.write { db in
            try Fixture.tombstone(db, table: "post_tag", id: "pt1")
            try Fixture.tombstone(db, table: "block_tag", id: "bt1")
            try Fixture.postTag(db, id: "pt2", tagId: "t1", postId: "c1")
            try Fixture.blockTag(db, id: "bt2", tagId: "t1", blockId: "b1")
        }
    }

    // MARK: CHECK constraints

    @Test func checkConstraintsRejectBadEnumValues() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try Fixture.container(db, id: "c1")
            try Fixture.block(db, id: "b1")
            try Fixture.block(db, id: "b2")
            try Fixture.variant(db, id: "v1", blockId: "b1")
        }
        let now = Fixture.now
        let badInserts: [(String, String, StatementArguments)] = [
            ("container.kind", "INSERT INTO container (id, kind, created_at, updated_at) VALUES ('x1', 'folder', ?, ?)", [now, now]),
            ("container.profile", "INSERT INTO container (id, kind, profile, created_at, updated_at) VALUES ('x2', 'post', 'novel', ?, ?)", [now, now]),
            ("container.segmentation_default", "INSERT INTO container (id, kind, segmentation_default, created_at, updated_at) VALUES ('x3', 'post', 'word', ?, ?)", [now, now]),
            ("variant.status", "INSERT INTO variant (id, block_id, status, fan_position, created_at, updated_at) VALUES ('x4', 'b1', 'draft', 'V', ?, ?)", [now, now]),
            ("commit_point.kind", "INSERT INTO commit_point (id, variant_id, text, kind, created_at) VALUES ('x5', 'v1', 't', 'scheduled', ?)", [now]),
            ("edge.type", "INSERT INTO edge (id, source_block_id, target_block_id, type, created_at) VALUES ('x6', 'b1', 'b2', 'linked_to', ?)", [now]),
            ("reading.kind", "INSERT INTO reading (id, name, kind, created_at, updated_at) VALUES ('x7', 'r', 'dynamic', ?, ?)", [now, now]),
            ("reading.sort_field", "INSERT INTO reading (id, name, kind, sort_field, created_at, updated_at) VALUES ('x8', 'r', 'curated', 'title', ?, ?)", [now, now]),
            ("reading.sort_dir", "INSERT INTO reading (id, name, kind, sort_dir, created_at, updated_at) VALUES ('x9', 'r', 'curated', 'up', ?, ?)", [now, now]),
            ("reference.kind", "INSERT INTO reference (id, container_id, kind, position, created_at, updated_at) VALUES ('x10', 'c1', 'epub', 'V', ?, ?)", [now, now]),
        ]
        for (label, sql, arguments) in badInserts {
            #expect(expectConstraintViolation {
                try db.write { db in try db.execute(sql: sql, arguments: arguments) }
            }, "CHECK on \(label) did not reject a bad value")
        }
    }

    // MARK: FK enforcement on every child table

    @Test func foreignKeysRejectDanglingReferencesOnEveryChildTable() throws {
        let db = try AppDatabase.inMemory()
        // One valid parent of each type, so each probe dangles on exactly one FK.
        try db.write { db in
            try Fixture.container(db, id: "c1")
            try Fixture.block(db, id: "b1")
            try Fixture.variant(db, id: "v1", blockId: "b1")
            try Fixture.reading(db, id: "r1")
            try Fixture.tag(db, id: "t1", name: "x", path: "x")
        }
        let now = Fixture.now
        let danglingInserts: [(String, String, StatementArguments)] = [
            ("variant.block_id", "INSERT INTO variant (id, block_id, fan_position, created_at, updated_at) VALUES ('d1', 'ghost', 'V', ?, ?)", [now, now]),
            ("variant.parent_variant_id", "INSERT INTO variant (id, block_id, parent_variant_id, fan_position, created_at, updated_at) VALUES ('d2', 'b1', 'ghost', 'V', ?, ?)", [now, now]),
            ("commit_point.variant_id", "INSERT INTO commit_point (id, variant_id, text, created_at) VALUES ('d3', 'ghost', 't', ?)", [now]),
            ("edge.source_block_id", "INSERT INTO edge (id, source_block_id, target_block_id, type, created_at) VALUES ('d4', 'ghost', 'b1', 'derived_from', ?)", [now]),
            ("edge.target_block_id", "INSERT INTO edge (id, source_block_id, target_block_id, type, created_at) VALUES ('d5', 'b1', 'ghost', 'derived_from', ?)", [now]),
            ("container_block.container_id", "INSERT INTO container_block (id, container_id, block_id, position, created_at, updated_at) VALUES ('d6', 'ghost', 'b1', 'V', ?, ?)", [now, now]),
            ("container_block.block_id", "INSERT INTO container_block (id, container_id, block_id, position, created_at, updated_at) VALUES ('d7', 'c1', 'ghost', 'V', ?, ?)", [now, now]),
            ("container_block.chosen_variant_id", "INSERT INTO container_block (id, container_id, block_id, position, chosen_variant_id, created_at, updated_at) VALUES ('d8', 'c1', 'b1', 'V', 'ghost', ?, ?)", [now, now]),
            ("reading.grouping_tag_id", "INSERT INTO reading (id, name, kind, grouping_tag_id, created_at, updated_at) VALUES ('d9', 'r', 'curated', 'ghost', ?, ?)", [now, now]),
            ("reading_post.reading_id", "INSERT INTO reading_post (id, reading_id, post_id, position, created_at) VALUES ('d10', 'ghost', 'c1', 'V', ?)", [now]),
            ("reading_post.post_id", "INSERT INTO reading_post (id, reading_id, post_id, position, created_at) VALUES ('d11', 'r1', 'ghost', 'V', ?)", [now]),
            ("tag.parent_id", "INSERT INTO tag (id, parent_id, name, path, created_at, updated_at) VALUES ('d12', 'ghost', 'y', 'y', ?, ?)", [now, now]),
            ("post_tag.tag_id", "INSERT INTO post_tag (id, tag_id, post_id, created_at) VALUES ('d13', 'ghost', 'c1', ?)", [now]),
            ("post_tag.post_id", "INSERT INTO post_tag (id, tag_id, post_id, created_at) VALUES ('d14', 't1', 'ghost', ?)", [now]),
            ("block_tag.tag_id", "INSERT INTO block_tag (id, tag_id, block_id, created_at) VALUES ('d15', 'ghost', 'b1', ?)", [now]),
            ("block_tag.block_id", "INSERT INTO block_tag (id, tag_id, block_id, created_at) VALUES ('d16', 't1', 'ghost', ?)", [now]),
            ("reference.container_id", "INSERT INTO reference (id, container_id, kind, position, created_at, updated_at) VALUES ('d17', 'ghost', 'url', 'V', ?, ?)", [now, now]),
            ("block.default_variant_id", "INSERT INTO block (id, default_variant_id, created_at, updated_at) VALUES ('d18', 'ghost', ?, ?)", [now, now]),
            ("block.last_container_id", "INSERT INTO block (id, last_container_id, created_at, updated_at) VALUES ('d19', 'ghost', ?, ?)", [now, now]),
        ]
        for (label, sql, arguments) in danglingInserts {
            #expect(expectConstraintViolation {
                try db.write { db in try db.execute(sql: sql, arguments: arguments) }
            }, "FK \(label) accepted a dangling reference")
        }
    }

    // MARK: Fractional-index position ordering

    /// The schema only stores and orders the strings (FractionalIndex.between
    /// is Phase 2 Domain work). TEXT comparison must be plain lexicographic,
    /// and the sort key is always (position, id) — a residual tie is stable,
    /// never an error (SyncSpec §8).
    @Test func positionsOrderLexicographicallyWithIdTiebreak() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try Fixture.container(db, id: "c1")
            for (block, cb, position) in [
                ("b1", "cb1", "B"), ("b2", "cb2", "AV"), ("b3", "cb3", "A"),
                ("b4", "cb4", "BM"),
                // Deliberate position tie → id breaks it, stably.
                ("b5", "cb6", "C"), ("b6", "cb5", "C"),
            ] {
                try Fixture.block(db, id: block)
                try Fixture.containerBlock(db, id: cb, containerId: "c1", blockId: block, position: position)
            }
        }
        let ordered = try db.read { db in
            try String.fetchAll(db, sql: "SELECT id FROM container_block WHERE container_id = 'c1' ORDER BY position, id")
        }
        #expect(ordered == ["cb3", "cb2", "cb1", "cb4", "cb5", "cb6"])
    }
}
