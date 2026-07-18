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
            #expect(SyncSchema.localOnlyTables == allTables.subtracting(synced),
                    "local-only list drifted from the schema")
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
            let reading = try ops.createReading(name: "book", kind: .curated, maxPosts: nil)
            _ = try ops.addPostToReading(post.id, to: reading.id)
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
