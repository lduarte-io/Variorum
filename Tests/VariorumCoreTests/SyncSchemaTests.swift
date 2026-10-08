import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Sync schema registry & row payloads (Phase 5, Step 1)")
struct SyncSchemaTests {
    // MARK: - Registry vs live schema, by introspection

    /// The registry and the migrated schema must agree exactly: a table
    /// carrying `sync_version` is synced and registered; a table without it
    /// is local-only machinery and listed as such. Any schema addition that
    /// forgets the registry (or vice versa) fails here.
    @Test func registryMatchesLiveSchemaExactly() throws {
        let db = try AppDatabase.inMemory()
        try db.read { db in
            let allTables = Set(try String.fetchAll(
                db,
                sql: "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'grdb_%' AND name NOT LIKE 'sqlite_%'"))
            var synced: Set<String> = []
            for table in allTables {
                let columns = try Row.fetchAll(db, sql: "PRAGMA table_info(\(table))")
                if columns.contains(where: { $0["name"] == "sync_version" }) {
                    synced.insert(table)
                }
            }
            #expect(Set(SyncSchema.tables.map(\.name)) == synced,
                    "registry drifted from the set of sync_version-carrying tables")
            #expect(SyncSchema.localOnlyTables.union(SyncSchema.derivedTables)
                        == allTables.subtracting(synced),
                    "local-only + derived lists drifted from the schema")
            #expect(SyncSchema.localOnlyTables.isDisjoint(with: SyncSchema.derivedTables),
                    "a table cannot be both export-dropped (local-only) and export-kept (derived)")
        }
    }

    @Test func registryPrimaryKeysAndTombstonesMatchTableInfo() throws {
        let db = try AppDatabase.inMemory()
        try db.read { db in
            for table in SyncSchema.tables {
                let columns = try Row.fetchAll(db, sql: "PRAGMA table_info(\(table.name))")
                let pkColumns = columns.filter { ($0["pk"] as Int) > 0 }.map { $0["name"] as String }
                #expect(pkColumns == [table.primaryKey], "\(table.name) PK drifted")
                let hasDeletedAt = columns.contains { $0["name"] == "deleted_at" }
                #expect(hasDeletedAt == table.hasTombstone, "\(table.name) tombstone flag drifted")
                for excluded in table.excludedColumns {
                    #expect(columns.contains { $0["name"] == excluded },
                            "\(table.name) excludes a column that does not exist: \(excluded)")
                }
            }
        }
    }

    // MARK: - The E2EE classification completeness walk (Phase 14b, L3 —
    // the postmortem-#4 serializer-drift lesson applied to encryption)

    /// Columns the live schema carries that the registry has NOT classified
    /// (plain / encrypted / excluded), and phantom classifications naming
    /// columns that do not exist. Pure, so the doctored-double proof below
    /// can exercise the walk against a deliberately-broken registration.
    static func classificationProblems(
        liveColumns: Set<String>, table: SyncTable
    ) -> (unclassified: Set<String>, phantom: Set<String>, overlapping: Set<String>) {
        let classified = table.plainColumns
            .union(table.encryptedColumns)
            .union(table.excludedColumns)
        let overlapping = table.plainColumns.intersection(table.encryptedColumns)
            .union(table.plainColumns.intersection(table.excludedColumns))
            .union(table.encryptedColumns.intersection(table.excludedColumns))
        return (
            // `sync_version` is machinery riding separately (the CAS base),
            // never a classified payload column.
            unclassified: liveColumns.subtracting(classified).subtracting(["sync_version"]),
            phantom: classified.subtracting(liveColumns),
            overlapping: overlapping)
    }

    /// EVERY column of EVERY synced table is classified EXACTLY ONE of
    /// plain / encrypted / excluded. A future migration that adds a column
    /// without taking a side fails the build here — a new text column can
    /// never silently leak to the mirror in the clear, and a typo'd
    /// classification can never silently classify nothing.
    @Test func everyColumnOfEverySyncedTableIsClassifiedExactlyOnce() throws {
        let db = try AppDatabase.inMemory()
        try db.read { database in
            for table in SyncSchema.tables {
                let live = Set(
                    try Row.fetchAll(database, sql: "PRAGMA table_info(\(table.name))")
                        .map { $0["name"] as String })
                let problems = Self.classificationProblems(liveColumns: live, table: table)
                #expect(problems.unclassified.isEmpty,
                        "\(table.name): unclassified column(s) \(problems.unclassified.sorted()) — every column must take a side: plain (disclosed structure) or encrypted (user-authored text) or excluded (local-only)")
                #expect(problems.phantom.isEmpty,
                        "\(table.name): classification names column(s) that do not exist: \(problems.phantom.sorted())")
                #expect(problems.overlapping.isEmpty,
                        "\(table.name): column(s) classified more than once: \(problems.overlapping.sorted())")
                // The PK is structure by definition — it rides every AAD
                // binding in plaintext, so an encrypted PK is incoherent.
                #expect(table.plainColumns.contains(table.primaryKey),
                        "\(table.name): the primary key must be classified plain")
            }
        }
    }

    /// The walk's red-on-old proof (the SerializerCompletenessTests
    /// precedent): a doctored registration that forgets to classify a
    /// column — exactly what a future migration would produce — is flagged.
    @Test func anUnclassifiedColumnFailsTheWalk() throws {
        let real = SyncSchema.table(named: "container")!
        let doctored = SyncTable(
            "container",
            plain: real.plainColumns,
            encrypted: real.encryptedColumns.subtracting(["floating_notes"]))
        let db = try AppDatabase.inMemory()
        try db.read { database in
            let live = Set(
                try Row.fetchAll(database, sql: "PRAGMA table_info(container)")
                    .map { $0["name"] as String })
            let problems = Self.classificationProblems(liveColumns: live, table: doctored)
            #expect(problems.unclassified == ["floating_notes"],
                    "the walk failed to flag the unclassified column (got \(problems.unclassified.sorted()))")
        }
    }

    /// The classification ships THE DESIGN's disclosure list exactly —
    /// pinned as a flat set so any future adjustment is a visible,
    /// deliberate diff (batch 2 may adjust only with recorded reasons).
    @Test func theEncryptedSetMatchesTheDisclosureListExactly() {
        var shipped: Set<String> = []
        for table in SyncSchema.tables {
            shipped.formUnion(table.encryptedColumns.map { "\(table.name).\($0)" })
        }
        #expect(shipped == [
            "variant.working_text", "variant.label",
            "commit_point.text", "commit_point.message",
            "block.name", "block.presentation",
            "container.title", "container.floating_notes",
            "reading.name", "reading.query_spec",
            "reading_section.name",
            "tag.name", "tag.path",
            "block_comment.text",
            "reference.name", "reference.url", "reference.view_state",
            "lens.name",
            // 13i-a (v1_18 — the recorded reasons): wing/shelf NAMES are
            // hers exactly as reading.name is; the shelf GLYPH is her
            // chosen grapheme — content-adjacent, and a one-character
            // plain column would leak a distinctive per-shelf marker.
            "wing.name",
            "shelf.name", "shelf.glyph",
        ])
    }

    /// Apply order is FK-friendly: every FK target precedes its referencing
    /// table in registry order, except inside the deliberately-circular
    /// container⇄block⇄variant trio (deferred FKs own that case).
    @Test func applyOrderRespectsAcyclicForeignKeys() throws {
        let circular: Set<String> = ["container", "block", "variant"]
        let db = try AppDatabase.inMemory()
        try db.read { db in
            for table in SyncSchema.tables {
                let fks = try Row.fetchAll(db, sql: "PRAGMA foreign_key_list(\(table.name))")
                for fk in fks {
                    let target: String = fk["table"]
                    if target == table.name { continue }  // tag→tag self-reference
                    if circular.contains(table.name) && circular.contains(target) { continue }
                    #expect(
                        SyncSchema.applyOrderIndex(of: target) < SyncSchema.applyOrderIndex(of: table.name),
                        "\(table.name) applies before its FK target \(target)")
                }
            }
        }
    }

    // MARK: - Payload round-trips

    /// A world built through real Operations, so every table has at least one
    /// row with realistic values (fans, edges, readings, tags, references).
    private func populatedWorld() throws -> AppDatabase {
        try withOperations { ops, db in
            let post = try ops.createPost(title: "post", profile: .journal)
            let b1 = try ops.newBlock(in: post.id, text: "First para. Second sentence.", at: .end).block
            let b2 = try ops.newBlock(in: post.id, text: "Second block text.", at: .end).block
            let v1 = try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?", [b1.id])!
            try ops.autosave(v1, text: "First para, edited. Second sentence.", charDelta: 8)
            _ = try ops.commit(v1, message: "checkpoint")
            _ = try ops.branchVariant(b1.id, from: v1)
            _ = try ops.merge(b1.id, b2.id)  // mints edges + releases blocks
            let pool = try ops.createPool(title: "scraps")
            let scrap = try ops.newBlock(in: pool.id, text: "loose idea", at: .end).block
            // Phase 11 (A1): fixture rows for the lockstep event's tables.
            _ = try ops.setCanvasPosition(container: pool.id, block: scrap.id, x: 120, y: 64)
            let mergedBlock = try db.fetchString(
                "SELECT block_id FROM container_block WHERE container_id = ? AND deleted_at IS NULL LIMIT 1",
                [post.id])!
            let mergedVariant = try db.fetchString(
                "SELECT default_variant_id FROM block WHERE id = ?", [mergedBlock])!
            let lens = try ops.createLens(post: post.id, name: "thread")
            _ = try ops.setLensChoice(lens: lens.id, block: mergedBlock, variant: mergedVariant)
            // Phase 13 (A1): fixture row for the lockstep event's table.
            _ = try ops.addBlockComment(to: mergedBlock, text: "take 1 preferred")
            let reading = try ops.createReading(name: "book", kind: .book, maxPosts: nil)
            _ = try ops.addPostToReading(post.id, to: reading.id)
            // Phase 13 (A1): chapter fixture + a sectioned membership.
            let chapter = try ops.createSection(in: reading.id, name: "I / leaving")
            try ops.assignPostToSection(post.id, in: reading.id, section: chapter.id)
            let tag = try ops.createTag(parent: nil, name: "life")
            let child = try ops.createTag(parent: tag.id, name: "goals")
            _ = try ops.applyTag(child.id, toPost: post.id)
            let blockID = try db.fetchString(
                "SELECT block_id FROM container_block WHERE deleted_at IS NULL LIMIT 1")!
            _ = try ops.applyTag(tag.id, toBlock: blockID)
            _ = try ops.addReference(
                to: post.id, kind: .file, name: "notes.pdf",
                fileBookmark: Data([0xDE, 0xAD, 0xBE, 0xEF]))
            _ = try ops.addReference(to: post.id, kind: .url, url: "https://example.org")
            // Phase 13j (v1_14): a purge-intent fixture row so every walk
            // and round-trip sees the table. Direct SQL — the walk needs
            // A row, not a whole deleted-family setup.
            try db.write { database in
                try database.execute(
                    sql: """
                        INSERT INTO purge_intent
                          (id, owner_id, table_name, row_id, requested_at, created_at, updated_at)
                        VALUES (?, NULL, 'block', ?, ?, ?, ?)
                        """,
                    arguments: [
                        "0F000000-0000-4000-8000-00000000F14E", scrap.id,
                        "2026-08-19T00:00:00.000Z", "2026-08-19T00:00:00.000Z",
                        "2026-08-19T00:00:00.000Z",
                    ])
            }
            // 13i-a (v1_18): wing + shelf fixture rows so every walk and
            // round-trip sees the two new tables. Direct SQL — their ops
            // arrive at 13i-b/d; the walk needs A row each. The shelf
            // points at the minted wing (a non-Home pointer exercises the
            // column); the Welcome role exercises the seed marker.
            try db.write { database in
                try database.execute(
                    sql: """
                        INSERT INTO wing (id, owner_id, name, position, created_at, updated_at)
                        VALUES ('0W000000-0000-4000-8000-000000000W01', NULL, 'the Work',
                                'a1', '2026-09-30T00:00:00.000Z', '2026-09-30T00:00:00.000Z')
                        """)
                try database.execute(
                    sql: """
                        INSERT INTO shelf (id, owner_id, wing_id, name, glyph, role, position,
                                           created_at, updated_at)
                        VALUES ('05000000-0000-4000-8000-0000000005E1', NULL,
                                '0W000000-0000-4000-8000-000000000W01', 'Welcome', '~',
                                'welcome', 'a1',
                                '2026-09-30T00:00:00.000Z', '2026-09-30T00:00:00.000Z')
                        """)
            }
            return db
        }
    }

    /// Every synced table round-trips: row → payload → JSON → payload →
    /// apply into a second database → byte-identical rows (minus the
    /// excluded local-only column).
    @Test func payloadsRoundTripByteStableThroughJSON() throws {
        let source = try populatedWorld()
        let target = try unenforcedDatabase()
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        try target.write { db in
            // Fresh world: drop the seeded settings so apply's INSERT path
            // is exercised alongside the UPDATE path (settings re-arrive).
            try db.execute(sql: "DELETE FROM setting")
        }
        try source.read { sourceDB in
            try target.write { targetDB in
                for table in SyncSchema.tables {
                    for row in try SyncRow.fetchAll(sourceDB, table: table) {
                        let wire = try encoder.encode(row)
                        let decoded = try decoder.decode(SyncRow.self, from: wire)
                        try decoded.apply(targetDB)
                    }
                }
            }
        }

        for table in SyncSchema.tables {
            let dumpSQL = """
                SELECT * FROM \(table.name) ORDER BY \(table.primaryKey)
                """
            let sourceRows = try source.read { try Row.fetchAll($0, sql: dumpSQL) }
            let targetRows = try target.read { try Row.fetchAll($0, sql: dumpSQL) }
            #expect(sourceRows.count == targetRows.count, "\(table.name) row count drifted")
            #expect(sourceRows.count > 0, "\(table.name) has no fixture coverage")
            for (sourceRow, targetRow) in zip(sourceRows, targetRows) {
                let sourceValues = Dictionary(uniqueKeysWithValues: sourceRow.map { ($0, $1) })
                let targetValues = Dictionary(uniqueKeysWithValues: targetRow.map { ($0, $1) })
                for (column, value) in sourceValues {
                    if table.excludedColumns.contains(column) {
                        #expect(targetValues[column] == DatabaseValue.null,
                                "\(table.name).\(column) is local-only but crossed the wire")
                    } else {
                        #expect(targetValues[column] == value,
                                "\(table.name).\(column) not byte-stable")
                    }
                }
            }
        }
    }

    @Test func bookmarkIsExcludedFromPayloadAndPreservedByApply() throws {
        let db = try populatedWorld()
        let table = SyncSchema.table(named: "reference")!
        let fileRef = try db.fetchString(
            "SELECT id FROM reference WHERE kind = 'file'")!
        let payload = try db.read { try SyncRow.fetch($0, table: table, rowID: fileRef) }!
        #expect(payload.columns["file_bookmark"] == nil)
        #expect(payload.columns["name"] == .text("notes.pdf"))

        // Applying a remote version of the row must not clobber the local
        // bookmark (UPDATE path preserves unlisted columns).
        var incoming = payload
        incoming.columns["name"] = .text("renamed on the other device")
        incoming.syncVersion = 3
        try db.write { try incoming.apply($0) }
        let after = try db.read { db in
            try Row.fetchOne(
                db, sql: "SELECT name, file_bookmark, sync_version FROM reference WHERE id = ?",
                arguments: [fileRef])
        }!
        #expect(after["name"] == "renamed on the other device")
        #expect((after["file_bookmark"] as Data?) == Data([0xDE, 0xAD, 0xBE, 0xEF]))
        #expect(after["sync_version"] == 3)
    }

    @Test func settingPayloadUsesKeyPrimaryKeyAndNeverTombstones() throws {
        let db = try AppDatabase.inMemory()
        let table = SyncSchema.table(named: "setting")!
        #expect(table.primaryKey == "key")
        #expect(!table.hasTombstone)
        let payload = try db.read {
            try SyncRow.fetch($0, table: table, rowID: "default_segmentation")
        }!
        #expect(payload.rowID == "default_segmentation")
        #expect(payload.columns["deleted_at"] == nil)
        #expect(payload.columns["value"] == .text("paragraph"))

        // Upsert-only: applying a newer value updates in place.
        var incoming = payload
        incoming.columns["value"] = .text("sentence")
        incoming.syncVersion = 2
        try db.write { try incoming.apply($0) }
        #expect(try db.fetchString(
            "SELECT value FROM setting WHERE key = 'default_segmentation'") == "sentence")
        #expect(try db.fetchInt(
            "SELECT sync_version FROM setting WHERE key = 'default_segmentation'") == 2)
    }

    @Test func applyInsertsWhenMissingAndUpdatesWhenPresent() throws {
        let db = try AppDatabase.inMemory()
        let row = SyncRow(
            table: "container", rowID: "c-remote",
            columns: [
                "id": .text("c-remote"), "owner_id": .null, "kind": .text("post"),
                "title": .text("from the other device"), "profile": .null,
                "entry_date": .null, "locked": .integer(0), "locked_at": .null,
                "floating_notes": .null, "segmentation_default": .null,
                "last_touched_at": .null, "last_major_revision_at": .null,
                "churn_accumulator": .real(0), "baseline_length": .integer(0),
                "created_at": .text(Fixture.now), "updated_at": .text(Fixture.now),
                "archived_at": .null, "deleted_at": .null,
            ],
            syncVersion: 1)
        try db.write { try row.apply($0) }  // INSERT path
        #expect(try db.fetchString("SELECT title FROM container WHERE id = 'c-remote'")
                == "from the other device")

        var newer = row
        newer.columns["title"] = .text("retitled")
        newer.syncVersion = 2
        try db.write { try newer.apply($0) }  // UPDATE path
        #expect(try db.fetchString("SELECT title FROM container WHERE id = 'c-remote'") == "retitled")
        #expect(try db.fetchInt("SELECT sync_version FROM container WHERE id = 'c-remote'") == 2)
        #expect(try db.fetchInt("SELECT COUNT(*) FROM container WHERE id = 'c-remote'") == 1)
    }

    /// Column names cross the network and are interpolated into SQL — a
    /// payload naming a column the schema doesn't have must refuse, never
    /// execute (Phase 5 review MAJOR: the server→client injection surface;
    /// also the defined failure for cross-schema-version payloads).
    @Test func applyRefusesUnknownOrMaliciousColumnNames() throws {
        let db = try AppDatabase.inMemory()
        let malicious = SyncRow(
            table: "container", rowID: "c-evil",
            columns: [
                "id": .text("c-evil"), "kind": .text("post"),
                "created_at": .text(Fixture.now), "updated_at": .text(Fixture.now),
                "title = 'x', deleted_at = NULL WHERE 1=1; --": .text("payload"),
            ],
            syncVersion: 1)
        #expect(throws: SyncError.unknownColumn(
            table: "container", column: "title = 'x', deleted_at = NULL WHERE 1=1; --")) {
            try db.write { try malicious.apply($0) }
        }
        // A benign-but-unknown column (a future schema version) refuses the
        // same way rather than drifting silently.
        let futuristic = SyncRow(
            table: "container", rowID: "c-future",
            columns: [
                "id": .text("c-future"), "kind": .text("post"),
                "created_at": .text(Fixture.now), "updated_at": .text(Fixture.now),
                "mood": .text("optimistic"),
            ],
            syncVersion: 1)
        #expect(throws: SyncError.unknownColumn(table: "container", column: "mood")) {
            try db.write { try futuristic.apply($0) }
        }
        #expect(try db.fetchInt("SELECT COUNT(*) FROM container") == 0)
    }

    /// SQLite's flexible typing could smuggle a BLOB into any column; the
    /// payload layer refuses rather than inventing an encoding for a value
    /// class the schema says cannot sync.
    @Test func unexpectedBlobInARowThrows() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try Fixture.container(db, id: "c1")
            try db.execute(
                sql: "UPDATE container SET title = ? WHERE id = 'c1'",
                arguments: [Data([0x01, 0x02])])
        }
        let table = SyncSchema.table(named: "container")!
        #expect(throws: SyncError.blobInPayload) {
            try db.read { try SyncRow.fetch($0, table: table, rowID: "c1") }
        }
    }
}
