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
        // (Phase 9b's v1_4 `bridge_state`/`bridge_day` were DROPPED by
        // v1_16 at the bridge's 2026-09-04 retirement — pinned below.)
        // Phase 11 (v1_5/v1_7, the one §12 lockstep event): canvas card
        // positions + saved lenses.
        "canvas_layout", "lens", "lens_choice",
        // Phase 13 (v1_8/v1_10, the Phase 13 §12 lockstep event): block
        // comments + reading sections (chapters).
        "block_comment", "reading_section",
        // Phase 13j (v1_14, the purge §12 lockstep event, marker 6→7):
        // the purge intent — "this is going, everywhere".
        "purge_intent",
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
        // Phase 13 (v1_8/v1_10). Deliberately NO unique indexes — neither
        // comments nor chapters have a natural key.
        "idx_block_comment_block",
        "idx_reading_section_order",
        // Phase 13j (v1_14): the intent's live-unique pair (two devices
        // asking to purge the same row dedupe as a pure duplicate,
        // SyncSpec §7) + the lookup index.
        "uq_purge_intent_live", "idx_purge_intent_row",
        // Pre-13u Act 4 (17c P20, v1_15): the version-history classifier's
        // own partial index — LOCAL only, no §12 lockstep event (the
        // mirrors carry no indexes beyond the PK by design, SyncSpec §2).
        "idx_container_note_version",
    ]

    // Tables synced to the server — all carry sync_version (AppSpec §6).
    static let syncedTables: [String] = [
        "container", "block", "variant", "commit_point", "edge",
        "container_block", "reading", "reading_post", "tag",
        "post_tag", "block_tag", "reference", "setting",
        "canvas_layout", "lens", "lens_choice",
        "block_comment", "reading_section",
        "purge_intent",
    ]

    @Test func allTablesExist() throws {
        let db = try AppDatabase.inMemory()
        let tables = try db.read { db in
            Set(try String.fetchAll(
                db, sql: "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'grdb_%' AND name NOT LIKE 'sqlite_%'"))
        }
        #expect(tables == Self.expectedTables)
    }

    /// The Fragments bridge's retirement (2026-09-04, pre-13x batch 0b): a
    /// store that ran every migration up to v1_15 still carries the bridge's
    /// two LOCAL-ONLY tables from v1_4; `v1_16_drop_bridge_tables` takes them
    /// and nothing else, contents included (per-device bookkeeping nothing
    /// reads any more). Red on the pre-retirement tree by construction: no
    /// such migration existed and `expectedTables` named both tables.
    @Test func theRetirementMigrationDropsTheBridgeTablesFromAnOlderStore() throws {
        let queue = try DatabaseQueue()
        try AppDatabase.migrator.migrate(queue, upTo: "v1_15_note_version_index")
        let (hasState, hasDay) = try queue.read { db in
            (try db.tableExists("bridge_state"), try db.tableExists("bridge_day"))
        }
        #expect(hasState, "a v1_15 store still carries the bridge's key-value table")
        #expect(hasDay, "…and its per-day table")
        try queue.write { db in
            try db.execute(
                sql: "INSERT INTO bridge_day (day_key, last_synced_hash) VALUES ('2026-08-01', 'abc')")
        }
        try AppDatabase.migrator.migrate(queue)
        let tables = try queue.read { db in
            Set(try String.fetchAll(
                db, sql: "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'grdb_%' AND name NOT LIKE 'sqlite_%'"))
        }
        #expect(!tables.contains("bridge_state") && !tables.contains("bridge_day"),
                "v1_16 drops both bridge tables")
        #expect(tables == Self.expectedTables,
                "the drop takes exactly the two bridge tables and nothing else")
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
                                   "uq_canvas_layout_live", "uq_lens_choice_live",
                                   "uq_purge_intent_live"])
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
        // 13j J11 (her cadence ruling — a CONSEQUENTIAL pin edit, annotated
        // in place per the batch-2/3/4 precedent, never quietly relaxed):
        // the backstop seeds at 2 h, not the original 24. The claim is
        // unchanged — the three settings seed, with these exact values;
        // only the ruled value moved. Existing stores are carried by
        // `v1_13_savepoint_backstop`, pinned separately.
        #expect(seeds.contains { $0 == ("idle_commit_hours", "2") })
    }

    @Test func migratorIsIdempotentAcrossReopen() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("VariorumTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let url = dir.appendingPathComponent("test.sqlite")

        // First open migrates; write a row so we can prove re-open keeps data.
        let first = try AppDatabase.onDisk(url: url, key: nil)
        try first.write { db in try Fixture.container(db, id: "c1") }

        // Second open re-runs the migrator: no error, schema intact, data intact,
        // seeds not duplicated.
        let second = try AppDatabase.onDisk(url: url, key: nil)
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
