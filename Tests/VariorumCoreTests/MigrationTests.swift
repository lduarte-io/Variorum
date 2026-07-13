import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Migration v1_core (Phase 1, Step 2)")
struct MigrationTests {
    static let expectedTables: Set<String> = [
        "container", "block", "variant", "commit_point", "edge",
        "container_block", "reading", "reading_post", "tag",
        "post_tag", "block_tag", "reference", "setting",
        "sync_outbox", "sync_state", "sync_row_seq", "_sync_applying",
        // Phase 9b (v1_4): the Fragments bridge's local-only state.
        "bridge_state", "bridge_day",
        // Phase 11 (v1_5/v1_7, the one §12 lockstep event): canvas card
        // positions + saved lenses.
        "canvas_layout", "lens", "lens_choice",
    ]

    static let expectedIndexes: Set<String> = [
        "idx_block_last_container",
        "idx_variant_block", "idx_variant_parent",
        "idx_commit_variant",
        "uq_edge_live", "idx_edge_source", "idx_edge_target",
        "idx_container_kind", "idx_container_entry_date", "idx_container_major_rev", "idx_container_touched",
        "uq_cblock_ownership", "idx_cblock_order",
        "uq_reading_post_live", "idx_reading_post_order", "idx_reading_post_post",
        "uq_tag_path_live", "idx_tag_parent",
        "uq_post_tag_live", "idx_post_tag_tag", "idx_post_tag_post",
        "uq_block_tag_live", "idx_block_tag_tag", "idx_block_tag_block",
        "idx_reference_container",
        // Phase 11 (v1_5/v1_7).
        "uq_canvas_layout_live", "idx_canvas_layout_block",
        "idx_lens_container",
        "uq_lens_choice_live", "idx_lens_choice_block",
    ]

    // Tables synced to the server — all carry sync_version (AppSpec §6).
    static let syncedTables: [String] = [
        "container", "block", "variant", "commit_point", "edge",
        "container_block", "reading", "reading_post", "tag",
        "post_tag", "block_tag", "reference", "setting",
        "canvas_layout", "lens", "lens_choice",
    ]

    @Test func allTablesExist() throws {
        let db = try AppDatabase.inMemory()
        let tables = try db.read { db in
            Set(try String.fetchAll(
                db, sql: "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'grdb_%' AND name NOT LIKE 'sqlite_%'"))
        }
        #expect(tables == Self.expectedTables)
    }

    @Test func allIndexesExist() throws {
        let db = try AppDatabase.inMemory()
        let indexes = try db.read { db in
            Set(try String.fetchAll(
                db, sql: "SELECT name FROM sqlite_master WHERE type = 'index' AND name NOT LIKE 'sqlite_%'"))
        }
        #expect(indexes == Self.expectedIndexes)
    }

    @Test func stampIndexesAreCompositeLiveRow() throws {
        // v1_2 (author decision 2026-07-06): the keyset sort key is
        // `(stamp, id)` over live rows — the indexes must match it exactly.
        let db = try AppDatabase.inMemory()
        let expected: [(name: String, column: String)] = [
            ("idx_container_entry_date", "entry_date"),
            ("idx_container_major_rev", "last_major_revision_at"),
            ("idx_container_touched", "last_touched_at"),
        ]
        try db.read { db in
            for (name, column) in expected {
                let sql = try String.fetchOne(
                    db,
                    sql: "SELECT sql FROM sqlite_master WHERE type = 'index' AND name = ?",
                    arguments: [name]) ?? ""
                #expect(sql.contains("(\(column), id)"), "\(name) is not composite on (\(column), id)")
                #expect(sql.contains("WHERE deleted_at IS NULL"), "\(name) is not live-row partial")
            }
        }
    }

    @Test func liveUniqueIndexesArePartial() throws {
        let db = try AppDatabase.inMemory()
        let partialUniques = try db.read { db in
            Set(try String.fetchAll(db, sql: """
                SELECT name FROM sqlite_master
                WHERE type = 'index' AND sql LIKE 'CREATE UNIQUE INDEX%' AND sql LIKE '%WHERE deleted_at IS NULL%'
                """))
        }
        #expect(partialUniques == ["uq_edge_live", "uq_cblock_ownership", "uq_reading_post_live",
                                   "uq_tag_path_live", "uq_post_tag_live", "uq_block_tag_live",
                                   "uq_canvas_layout_live", "uq_lens_choice_live"])
    }

    @Test func everySyncedTableCarriesSyncVersionDefaultZero() throws {
        let db = try AppDatabase.inMemory()
        try db.read { db in
            for table in Self.syncedTables {
                let columns = try Row.fetchAll(db, sql: "PRAGMA table_info(\(table))")
                let syncVersion = columns.first { $0["name"] == "sync_version" }
                #expect(syncVersion != nil, "\(table) is missing sync_version")
                #expect(syncVersion?["dflt_value"] == "0", "\(table).sync_version default is not 0")
                #expect(syncVersion?["notnull"] == 1, "\(table).sync_version is nullable")
            }
            // The local-only tables must NOT carry it.
            for table in ["sync_outbox", "sync_state", "sync_row_seq", "_sync_applying"] {
                let columns = try Row.fetchAll(db, sql: "PRAGMA table_info(\(table))")
                #expect(!columns.contains { $0["name"] == "sync_version" }, "\(table) must not carry sync_version")
            }
        }
    }

    @Test func settingsAreSeeded() throws {
        let db = try AppDatabase.inMemory()
        let seeds = try db.read { db in
            try Row.fetchAll(db, sql: "SELECT key, value FROM setting ORDER BY key")
                .map { ($0["key"] as String, $0["value"] as String) }
        }
        #expect(seeds.count == 3)
        #expect(seeds.contains { $0 == ("default_segmentation", "paragraph") })
        #expect(seeds.contains { $0 == ("major_revision_threshold", "0.8") })
        #expect(seeds.contains { $0 == ("idle_commit_hours", "24") })
    }

    @Test func migratorIsIdempotentAcrossReopen() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("VariorumTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let url = dir.appendingPathComponent("test.sqlite")

        // First open migrates; write a row so we can prove re-open keeps data.
        let first = try AppDatabase.onDisk(url: url)
        try first.write { db in try Fixture.container(db, id: "c1") }

        // Second open re-runs the migrator: no error, schema intact, data intact,
        // seeds not duplicated.
        let second = try AppDatabase.onDisk(url: url)
        let (containers, settings) = try second.read { db in
            (try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM container")!,
             try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM setting")!)
        }
        #expect(containers == 1)
        #expect(settings == 3)
    }

    /// The circular FK pair (block→variant via default_variant_id, variant→block
    /// via block_id; block→container via last_container_id) resolves in write
    /// order: insert with NULL forward pointers, then point back.
    @Test func circularBlockVariantContainerInsertWorksInWriteOrder() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try Fixture.container(db, id: "c1")
            try Fixture.block(db, id: "b1")
            try Fixture.variant(db, id: "v1", blockId: "b1")
            try db.execute(sql: "UPDATE block SET default_variant_id = 'v1', last_container_id = 'c1' WHERE id = 'b1'")
        }
        let row = try db.read { db in
            try Row.fetchOne(db, sql: "SELECT default_variant_id, last_container_id FROM block WHERE id = 'b1'")
        }
        #expect(row?["default_variant_id"] == "v1")
        #expect(row?["last_container_id"] == "c1")
    }
}
