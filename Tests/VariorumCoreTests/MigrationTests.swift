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
        // 13i-a (v1_18, the wings/shelves/books §12 event, marker 9→10):
        // in-store libraries + Bookcase shelves. The Home wing is VIRTUAL
        // (no row; '' pointers) — the table holds additional wings only.
        "wing", "shelf",
        // 13o (v1_22): the DERIVED, LOCAL-ONLY search family — the doc
        // table, the FTS5 virtual table and its four external-content
        // shadows (no `_content` — the text lives in the source rows).
        "search_doc", "search_fts",
        "search_fts_config", "search_fts_data", "search_fts_docsize", "search_fts_idx",
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
        // 18h batch 2's ladder (R1-1, v1_17): the day search's driver — the
        // savepoints written in a window, so the arm is driven by the DAY
        // and not walked per note. LOCAL only, no §12 event, marker 8.
        "idx_commit_created",
        // 13i-a (v1_18): the shelf strip's per-wing order walk.
        "idx_shelf_wing",
        // 13o (v1_22): the search doc's source key (the capture triggers'
        // lookup) + the worn-day arm's partial index over undated live
        // containers. Both LOCAL, no §12 event.
        "uq_search_doc_src", "idx_container_undated_created",
    ]

    // Tables synced to the server — all carry sync_version (AppSpec §6).
    static let syncedTables: [String] = [
        "container", "block", "variant", "commit_point", "edge",
        "container_block", "reading", "reading_post", "tag",
        "post_tag", "block_tag", "reference", "setting",
        "canvas_layout", "lens", "lens_choice",
        "block_comment", "reading_section",
        "purge_intent",
        // 13i-a (v1_18): the wings/shelves event's two tables.
        "wing", "shelf",
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

    /// **The day search's index** (18h batch 2's ladder, R1-1 — v1_17). A
    /// store that ran every migration up to v1_16 does not have it; migrating
    /// the rest of the way adds it and nothing else. Red on the pre-fix tree
    /// by construction: no such migration existed and `expectedIndexes` did
    /// not name it.
    @Test func theDaySearchIndexArrivesForAnOlderStore() throws {
        let queue = try DatabaseQueue()
        try AppDatabase.migrator.migrate(queue, upTo: "v1_16_drop_bridge_tables")
        func indexes() throws -> Set<String> {
            try queue.read { db in
                Set(try String.fetchAll(
                    db,
                    sql: "SELECT name FROM sqlite_master WHERE type = 'index' AND name NOT LIKE 'sqlite_%'"))
            }
        }
        let before = try indexes()
        #expect(!before.contains("idx_commit_created"),
                "a v1_16 store walks the savepoints per note")
        try AppDatabase.migrator.migrate(queue)
        let after = try indexes()
        // 13i-a: the full chain past v1_16 now adds v1_17's day-search
        // index AND v1_18's shelf-order index; 13o: v1_22's two.
        #expect(after.subtracting(before) == [
            "idx_commit_created", "idx_shelf_wing",
            "uq_search_doc_src", "idx_container_undated_created",
        ], "v1_17 + v1_18 + v1_22 add exactly these indexes")
        #expect(after == Self.expectedIndexes)
    }

    /// **13o — v1_22's BACKFILL** (the rebuild engine run once inside the
    /// migration): a store that already holds words when the index arrives
    /// has every live field findable the moment the migration lands — takes,
    /// a take label, a block name, a comment, a title, floating notes, a book
    /// and a chapter — while a TOMBSTONED take is not, an ARCHIVED take is
    /// indexed with its fact, and accents/case fold (R-13o-11). Red on the
    /// pre-13o tree by construction: no such migration or table existed.
    @Test func theSearchIndexBackfillsAnOlderStoreAtMigration() throws {
        let queue = try DatabaseQueue()
        try AppDatabase.migrator.migrate(queue, upTo: "v1_21_reading_archive")
        try queue.write { db in
            try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
            try db.execute(sql: """
                INSERT INTO container (id, kind, title, floating_notes, created_at, updated_at)
                  VALUES ('n1', 'post', 'Lighthouse Diary', 'margin musings', '2026-10-06T00:00:00.000Z', '2026-10-06T00:00:00.000Z');
                INSERT INTO block (id, default_variant_id, name, created_at, updated_at)
                  VALUES ('b1', 'v1', 'opening gambit', '2026-10-06T00:00:00.000Z', '2026-10-06T00:00:00.000Z');
                INSERT INTO variant (id, block_id, working_text, label, fan_position, created_at, updated_at)
                  VALUES ('v1', 'b1', 'The Café was naïve', 'gentler take', 'a0', '2026-10-06T00:00:00.000Z', '2026-10-06T00:00:00.000Z');
                INSERT INTO variant (id, block_id, working_text, status, fan_position, created_at, updated_at)
                  VALUES ('v2', 'b1', 'an archived thought', 'archived', 'a1', '2026-10-06T00:00:00.000Z', '2026-10-06T00:00:00.000Z');
                INSERT INTO variant (id, block_id, working_text, fan_position, created_at, updated_at, deleted_at)
                  VALUES ('v3', 'b1', 'a deleted thought', 'a2', '2026-10-06T00:00:00.000Z', '2026-10-06T00:00:00.000Z', '2026-10-06T00:00:00.000Z');
                INSERT INTO container_block (id, container_id, block_id, position, chosen_variant_id, created_at, updated_at)
                  VALUES ('p1', 'n1', 'b1', 'a0', 'v1', '2026-10-06T00:00:00.000Z', '2026-10-06T00:00:00.000Z');
                INSERT INTO block_comment (id, block_id, text, created_at, updated_at)
                  VALUES ('c1', 'b1', 'check the tide tables', '2026-10-06T00:00:00.000Z', '2026-10-06T00:00:00.000Z');
                INSERT INTO reading (id, name, kind, created_at, updated_at)
                  VALUES ('r1', 'Coastal Book', 'book', '2026-10-06T00:00:00.000Z', '2026-10-06T00:00:00.000Z');
                INSERT INTO reading_section (id, reading_id, name, position, created_at, updated_at)
                  VALUES ('s1', 'r1', 'Harbour Chapter', 'a0', '2026-10-06T00:00:00.000Z', '2026-10-06T00:00:00.000Z');
                """)
        }
        #expect(try queue.read { try $0.tableExists("search_doc") } == false)
        try AppDatabase.migrator.migrate(queue)
        func hits(_ match: String) throws -> [String] {
            try queue.read { db in
                try String.fetchAll(db, sql: """
                    SELECT d.kind || ':' || d.src_id FROM search_fts JOIN search_doc d ON d.id = search_fts.rowid
                    WHERE search_fts MATCH ? ORDER BY d.kind, d.src_id
                    """, arguments: [match])
            }
        }
        #expect(try hits("cafe naive") == ["take:v1"], "accents and case fold")
        #expect(try hits("gentler") == ["take_label:v1"])
        #expect(try hits("gambit") == ["block_name:b1"])
        #expect(try hits("tide") == ["comment:c1"])
        #expect(try hits("lighthouse") == ["title:n1"])
        #expect(try hits("musings") == ["note_meta:n1"])
        #expect(try hits("coastal") == ["book:r1"])
        #expect(try hits("harbour") == ["chapter:s1"])
        #expect(try hits("archived") == ["take:v2"], "archived takes stay indexed (R-13o-6)")
        #expect(try hits("deleted") == [], "a tombstoned take is never indexed")
        let archived = try queue.read { db in
            try Bool.fetchOne(db, sql: "SELECT archived FROM search_doc WHERE kind = 'take' AND src_id = 'v2'")
        }
        #expect(archived == true, "…carrying its own archived fact")
        try queue.write { db in
            try db.execute(sql: "INSERT INTO search_fts (search_fts, rank) VALUES ('integrity-check', 1)")
        }
    }

    /// **VX-72 — v1_23's BACKFILL** (the rebuild road run once over v1_23's
    /// nine kinds): a store that already holds savepoints when the ninth kind
    /// arrives has every one findable the moment the migration lands —
    /// including a savepoint of a TOMBSTONED take, because the savepoint doc
    /// mirrors its `commit_point` ROW (the §U-C RULINGS' FORK 1 = A: the
    /// take's liveness resolves at query time, under the facet) — each
    /// carrying its own parent fact; v1_22's eight kinds are re-derived
    /// beside it and the index passes FTS5's integrity check. Red on the
    /// pre-VX-72 tree by construction: no such migration or kind existed.
    @Test func theSavepointKindBackfillsAStoreThatAlreadyHoldsSavepoints() throws {
        let queue = try DatabaseQueue()
        try AppDatabase.migrator.migrate(queue, upTo: "v1_22_search_index")
        let stamp = "2026-10-06T00:00:00.000Z"
        try queue.write { db in
            try db.execute(sql: "PRAGMA defer_foreign_keys = ON")
            try db.execute(sql: """
                INSERT INTO container (id, kind, title, created_at, updated_at)
                  VALUES ('n1', 'post', 'Harbor Log', '\(stamp)', '\(stamp)');
                INSERT INTO block (id, default_variant_id, created_at, updated_at)
                  VALUES ('b1', 'v1', '\(stamp)', '\(stamp)');
                INSERT INTO variant (id, block_id, working_text, fan_position, created_at, updated_at)
                  VALUES ('v1', 'b1', 'the lighthouse today', 'a0', '\(stamp)', '\(stamp)');
                INSERT INTO variant (id, block_id, working_text, fan_position, created_at, updated_at, deleted_at)
                  VALUES ('v2', 'b1', 'a deleted take', 'a1', '\(stamp)', '\(stamp)', '\(stamp)');
                INSERT INTO container_block (id, container_id, block_id, position, chosen_variant_id, created_at, updated_at)
                  VALUES ('p1', 'n1', 'b1', 'a0', 'v1', '\(stamp)', '\(stamp)');
                INSERT INTO commit_point (id, variant_id, text, kind, created_at)
                  VALUES ('cp1', 'v1', 'the Café at the harbor', 'manual', '\(stamp)');
                INSERT INTO commit_point (id, variant_id, text, kind, created_at)
                  VALUES ('cp2', 'v2', 'a saved harbor thought', 'auto', '\(stamp)');
                """)
        }
        #expect(try queue.read { db in
            try Int.fetchOne(db, sql: "SELECT count(*) FROM search_doc WHERE kind = 'savepoint'")
        } == 0, "a v1_22 store indexes no savepoint")
        try AppDatabase.migrator.migrate(queue)
        func hits(_ match: String) throws -> [String] {
            try queue.read { db in
                try String.fetchAll(db, sql: """
                    SELECT d.kind || ':' || d.src_id FROM search_fts JOIN search_doc d ON d.id = search_fts.rowid
                    WHERE search_fts MATCH ? ORDER BY d.kind, d.src_id
                    """, arguments: [match])
            }
        }
        #expect(try hits("harbor") == ["savepoint:cp1", "savepoint:cp2", "title:n1"],
                "every savepoint ROW is indexed — a dead take's too (its liveness is the query's)")
        #expect(try hits("cafe") == ["savepoint:cp1"], "accents and case fold")
        #expect(try hits("lighthouse") == ["take:v1"], "v1_22's kinds re-derived beside it")
        let parents = try queue.read { db in
            try Row.fetchAll(db, sql: """
                SELECT src_id, variant_id, block_id, container_id FROM search_doc
                WHERE kind = 'savepoint' ORDER BY src_id
                """).map { "\($0["src_id"] as String)→\(($0["variant_id"] as String?) ?? "nil")" }
        }
        #expect(parents == ["cp1→v1", "cp2→v2"], "each carries its OWN parent fact, nothing more (F3)")
        let takeVariantFacts = try queue.read { db in
            try Int.fetchOne(db, sql: "SELECT count(*) FROM search_doc WHERE kind <> 'savepoint' AND variant_id IS NOT NULL")
        }
        #expect(takeVariantFacts == 0, "the new column is the savepoint's alone")
        try queue.write { db in
            try db.execute(sql: "INSERT INTO search_fts (search_fts, rank) VALUES ('integrity-check', 1)")
        }
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
