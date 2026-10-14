import Foundation
import GRDB
import Testing

@testable import VariorumCore

// 13n-b U1 P3 — THE MCP DOOR's GRANTS STORE (`v1_24_mcp_grants`, A-5/A-6):
// LOCAL-ONLY by construction (no sync_version, no outbox capture, no §12
// event — the marker stays 12), arriving whole on an older store, its enums
// held by CHECK constraints, and exported EMPTY (A-5's exclusion: no client,
// grant, switch or activity row leaves in the plaintext file while the
// tables stay, so the file's schema is whole).

@Suite("13n-b U1 — the grants store's schema (v1_24, local-only)")
struct MCPGrantSchemaTests {
    private let stamp = "2026-10-09T12:00:00.000Z"

    private func seedGrantRows(_ db: Database) throws {
        try db.execute(sql: """
            INSERT INTO mcp_client (id, name, version, state, first_seen_at, last_seen_at, decided_at)
              VALUES ('cl1', 'claude-code', '2.1', 'approved', ?, ?, ?);
            INSERT INTO mcp_grant (id, client_id, rung, scope_kind, scope_id, duration, created_at)
              VALUES ('g1', 'cl1', 'read', 'book', 'r1', 'always', ?);
            INSERT INTO mcp_activity (client_name, act, target_kind, target_id, target_title, outcome, at)
              VALUES ('claude-code', 'read_note', 'note', 'n1', 'travelled', 'allowed', ?);
            INSERT INTO mcp_switch (key, value, updated_at) VALUES ('server', '1', ?);
            UPDATE mcp_client SET setup_key_hash = 'bound-hash' WHERE id = 'cl1';
            INSERT INTO mcp_setup_key (key_hash, minted_at) VALUES ('pending-hash', ?);
            """, arguments: [stamp, stamp, stamp, stamp, stamp, stamp, stamp])
        // VX-184 U3 (A JUSTIFIED EDIT, the ritual — VX-188): v1_27's
        // comment-authorship record joins the family, so the family's seed
        // carries one row of it (the export pin below counts a row per table).
        try db.execute(sql: """
            INSERT INTO mcp_comment_author (comment_id, client_name, recorded_at) VALUES ('cm1', 'claude-code', ?)
            """, arguments: [stamp])
        // VX-258 (A JUSTIFIED EDIT, the ritual — VX-246 U1): v1_28's waiting
        // re-bind joins the family, so the seed carries one row of it too.
        try db.execute(sql: """
            INSERT INTO mcp_rebind_request (id, client_id, key_hash, version, asked_at)
              VALUES ('rb1', 'cl1', 'waiting-hash', '0.1', ?)
            """, arguments: [stamp])
    }

    @Test func theFamilyIsLocalOnlyByConstruction() throws {
        let db = try AppDatabase.inMemory()
        try db.read { (db: Database) throws in
            for table in MCPGrantSchema.tables {
                #expect(try db.tableExists(table), "\(table) is missing")
                let columns = try Row.fetchAll(db, sql: "PRAGMA table_info(\(table))")
                #expect(!columns.contains { $0["name"] == "sync_version" },
                        "\(table) must not carry sync_version — the grants store never syncs")
                #expect(SyncSchema.table(named: table) == nil, "\(table) must not be in the sync registry")
            }
            // VX-184 U3 (A JUSTIFIED EDIT, the ritual): v1_27's table joins
            // the trigger-free family.
            let triggers = try String.fetchAll(db, sql: """
                SELECT name FROM sqlite_master WHERE type = 'trigger'
                  AND tbl_name IN ('mcp_client', 'mcp_grant', 'mcp_activity', 'mcp_switch', 'mcp_setup_key',
                                   'mcp_comment_author', 'mcp_rebind_request')
                """)
            #expect(triggers.isEmpty, "no trigger — no outbox capture, no index capture — reads the grants store")
        }
    }

    // MARK: - VX-168: the per-setup key (v1_26, local-only — the v1_24 road)

    /// `v1_26_mcp_setup_keys` joins the family LOCAL-ONLY exactly as v1_24
    /// did: registered in `MCPGrantSchema.tables` (so the completeness walk
    /// and the export know it), no `sync_version`, outside the sync registry,
    /// no trigger, never the outbox — and NOT a lockstep event (the marker
    /// stays 13; nothing on the mirror changes).
    @Test func theSetupKeyStoreIsRegisteredLocalOnlyLikeTheGrantsFamily() throws {
        #expect(MCPGrantSchema.tables.contains("mcp_setup_key"))
        #expect(SyncSchema.lockstepVersion == 13, "a local-only migration never moves the marker")
        let db = try AppDatabase.inMemory()
        try db.read { (db: Database) throws in
            #expect(SyncSchema.table(named: "mcp_setup_key") == nil)
            #expect(SyncSchema.table(named: "mcp_client") == nil)
            #expect(!SyncSchema.localOnlyTables.contains("mcp_setup_key")
                    && !SyncSchema.derivedTables.contains("mcp_setup_key"),
                    "its own family's registration, never sync machinery or a derived index")
            let keyColumns = try Row.fetchAll(db, sql: "PRAGMA table_info(mcp_setup_key)").map { $0["name"] as String }
            #expect(keyColumns == ["key_hash", "minted_at"], "a hash and a stamp — never the key itself")
            let clientColumns = try Row.fetchAll(db, sql: "PRAGMA table_info(mcp_client)").map { $0["name"] as String }
            #expect(clientColumns.contains("setup_key_hash"))
            #expect(!clientColumns.contains("sync_version"))
        }
        try db.write { db in
            let before = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? -1
            try seedGrantRows(db)
            try db.execute(sql: "DELETE FROM mcp_setup_key")
            try db.execute(sql: "UPDATE mcp_client SET setup_key_hash = NULL")
            #expect(try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") == before,
                    "a setup-key write never reaches the outbox")
        }
    }

    // MARK: - VX-188: who wrote a comment (v1_27, local-only — the v1_24 road)

    /// `v1_27_mcp_comment_authors` joins the family LOCAL-ONLY exactly as
    /// v1_24 and v1_26 did — registered in `MCPGrantSchema.tables` (the
    /// completeness walk and the export know it), no `sync_version`, outside
    /// the sync registry, no trigger, never the outbox — and NOT a lockstep
    /// event (the marker stays 13). One author per comment; no foreign key to
    /// the synced comment row (a record may outlive a purged comment).
    @Test func theCommentAuthorRecordIsRegisteredLocalOnlyLikeTheGrantsFamily() throws {
        #expect(MCPGrantSchema.tables.contains("mcp_comment_author"))
        #expect(MCPGrantSchema.childFirstOrder.contains("mcp_comment_author"))
        #expect(SyncSchema.lockstepVersion == 13, "a local-only migration never moves the marker")
        let db = try AppDatabase.inMemory()
        try db.read { (db: Database) throws in
            #expect(SyncSchema.table(named: "mcp_comment_author") == nil)
            #expect(!SyncSchema.localOnlyTables.contains("mcp_comment_author")
                    && !SyncSchema.derivedTables.contains("mcp_comment_author"),
                    "its own family's registration, never sync machinery or a derived index")
            let columns = try Row.fetchAll(db, sql: "PRAGMA table_info(mcp_comment_author)").map { $0["name"] as String }
            // P-VX260-1 (b) (A JUSTIFIED EDIT, the ritual — VX-246 U1b): v1_29
            // adds the digest of the words the client wrote (local-only).
            #expect(columns == ["comment_id", "client_name", "recorded_at", "text_digest"],
                    "an id, a name, a stamp, the words' digest — nothing else")
            #expect(try Row.fetchAll(db, sql: "PRAGMA foreign_key_list(mcp_comment_author)").isEmpty,
                    "no foreign key to the synced comment row")
            #expect(try String.fetchAll(db, sql: """
                SELECT name FROM sqlite_master WHERE type = 'trigger' AND tbl_name = 'mcp_comment_author'
                """).isEmpty)
        }
        try db.write { db in
            let before = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? -1
            try db.execute(sql: """
                INSERT INTO mcp_comment_author (comment_id, client_name, recorded_at)
                  VALUES ('no-such-comment', 'claude-code', ?)
                """, arguments: [stamp])
            #expect(try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") == before,
                    "a record write never reaches the outbox")
        }
        #expect(throws: (any Error).self, "one author per comment") {
            try db.write { db in
                try db.execute(sql: """
                    INSERT INTO mcp_comment_author (comment_id, client_name, recorded_at)
                      VALUES ('no-such-comment', 'codex', ?)
                    """, arguments: [stamp])
            }
        }
    }

    // MARK: - VX-258: a setup waiting for her OK (v1_28, local-only — the v1_24 road)

    /// `v1_28_mcp_rebind_requests` joins the family LOCAL-ONLY exactly as its
    /// siblings did — registered in `MCPGrantSchema.tables` and the strip
    /// order (before `mcp_client`, which it names), no `sync_version`, outside
    /// the sync registry, no trigger, never the outbox, the marker 13. One
    /// waiting setup per client, one row per key, a real client named.
    @Test func theWaitingRebindIsRegisteredLocalOnlyLikeTheGrantsFamily() throws {
        #expect(MCPGrantSchema.tables.contains("mcp_rebind_request"))
        let order = MCPGrantSchema.childFirstOrder
        #expect(try #require(order.firstIndex(of: "mcp_rebind_request")) < #require(order.firstIndex(of: "mcp_client")),
                "stripped before the client rows it names")
        #expect(SyncSchema.lockstepVersion == 13, "a local-only migration never moves the marker")
        let db = try AppDatabase.inMemory()
        try db.read { (db: Database) throws in
            #expect(SyncSchema.table(named: "mcp_rebind_request") == nil)
            #expect(!SyncSchema.localOnlyTables.contains("mcp_rebind_request")
                    && !SyncSchema.derivedTables.contains("mcp_rebind_request"),
                    "its own family's registration, never sync machinery or a derived index")
            let columns = try Row.fetchAll(db, sql: "PRAGMA table_info(mcp_rebind_request)").map { $0["name"] as String }
            #expect(columns == ["id", "client_id", "key_hash", "version", "asked_at"], "a hash, never the key")
            #expect(try String.fetchAll(db, sql: """
                SELECT name FROM sqlite_master WHERE type = 'trigger' AND tbl_name = 'mcp_rebind_request'
                """).isEmpty)
        }
        try db.write { db in
            let before = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? -1
            try seedGrantRows(db)
            #expect(try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") == before,
                    "a waiting re-bind never reaches the outbox")
            try db.execute(sql: """
                INSERT INTO mcp_client (id, name, state, first_seen_at, last_seen_at) VALUES ('cl2', 'codex', 'approved', ?, ?)
                """, arguments: [stamp, stamp])
        }
        for (sql, why) in [
            ("INSERT INTO mcp_rebind_request (id, client_id, key_hash, asked_at) VALUES ('rb2', 'cl1', 'another-hash', '\(stamp)')",
             "one waiting setup per client"),
            ("INSERT INTO mcp_rebind_request (id, client_id, key_hash, asked_at) VALUES ('rb2', 'cl2', 'waiting-hash', '\(stamp)')",
             "one row per key"),
            ("INSERT INTO mcp_rebind_request (id, client_id, key_hash, asked_at) VALUES ('rb2', 'nobody', 'other', '\(stamp)')",
             "a real client named"),
        ] {
            #expect(throws: (any Error).self, "\(why)") { try db.write { db in try db.execute(sql: sql) } }
        }
    }

    /// A store at v1_27 gains the waiting table EMPTY and keeps its rows.
    @Test func aStoreBeforeTheWaitGainsItEmptyAndKeepsItsRows() throws {
        let queue = try DatabaseQueue()
        try AppDatabase.migrator.migrate(queue, upTo: "v1_27_mcp_comment_authors")
        try queue.write { db in
            #expect(try db.tableExists("mcp_rebind_request") == false)
            try db.execute(sql: """
                INSERT INTO mcp_client (id, name, version, state, first_seen_at, last_seen_at, decided_at)
                  VALUES ('cl1', 'claude-code', '2.1', 'approved', ?, ?, ?);
                """, arguments: [stamp, stamp, stamp])
        }
        try AppDatabase.migrator.migrate(queue)
        try queue.read { (db: Database) throws in
            #expect(try db.tableExists("mcp_rebind_request"))
            #expect(try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM mcp_rebind_request") == 0)
            #expect(try String.fetchOne(db, sql: "SELECT state FROM mcp_client WHERE id = 'cl1'") == "approved")
        }
    }

    // MARK: - P-VX260-1 (b): the words a client wrote (v1_29, local-only — the v1_24 road)

    /// `v1_29_mcp_comment_words` adds ONE nullable column on the family's road:
    /// no `sync_version` (the table stays outside the sync registry), no
    /// trigger, never the outbox, the marker 13 — and a record write carrying
    /// a digest never reaches the outbox either.
    @Test func theWordsDigestIsLocalOnlyLikeItsTable() throws {
        #expect(SyncSchema.lockstepVersion == 13, "a local-only migration never moves the marker")
        let db = try AppDatabase.inMemory()
        try db.read { (db: Database) throws in
            let columns = try Row.fetchAll(db, sql: "PRAGMA table_info(mcp_comment_author)")
            let digest = try #require(columns.first { $0["name"] == "text_digest" }, "the digest column")
            #expect((digest["notnull"] as Int) == 0, "nullable — NULL reads as unproven")
            #expect(SyncSchema.table(named: "mcp_comment_author") == nil)
            #expect(try String.fetchAll(db, sql: """
                SELECT name FROM sqlite_master WHERE type = 'trigger' AND tbl_name = 'mcp_comment_author'
                """).isEmpty)
        }
        try db.write { db in
            let before = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? -1
            try db.execute(sql: """
                INSERT INTO mcp_comment_author (comment_id, client_name, recorded_at, text_digest)
                  VALUES ('cm9', 'claude-code', ?, 'abc')
                """, arguments: [stamp])
            #expect(try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") == before,
                    "a digest write never reaches the outbox")
        }
    }

    /// A store at v1_28 keeps every authorship record, each with NO digest —
    /// NULL, unproven (no backfill: the record cannot say whether its comment
    /// was rewritten since, on another device).
    @Test func aStoreBeforeTheDigestKeepsItsRecordsUnproven() throws {
        let queue = try DatabaseQueue()
        try AppDatabase.migrator.migrate(queue, upTo: "v1_28_mcp_rebind_requests")
        try queue.write { db in
            try db.execute(sql: """
                INSERT INTO mcp_comment_author (comment_id, client_name, recorded_at) VALUES ('cm1', 'claude-code', ?)
                """, arguments: [stamp])
        }
        try AppDatabase.migrator.migrate(queue)
        try queue.read { (db: Database) throws in
            let row = try #require(try Row.fetchOne(db, sql: "SELECT * FROM mcp_comment_author WHERE comment_id = 'cm1'"))
            #expect(row["client_name"] as String == "claude-code", "the record is kept")
            #expect((row["text_digest"] as String?) == nil, "and arrives unproven")
        }
    }

    /// A store at v1_26 gains the record EMPTY — no comment that exists before
    /// it has an author on file (R-VX188-2: such a comment is never a client's
    /// own) — and keeps every row it had.
    @Test func aStoreBeforeTheRecordGainsItEmptyAndKeepsItsRows() throws {
        let queue = try DatabaseQueue()
        try AppDatabase.migrator.migrate(queue, upTo: "v1_26_mcp_setup_keys")
        try queue.write { db in
            #expect(try db.tableExists("mcp_comment_author") == false)
            try db.execute(sql: """
                INSERT INTO mcp_client (id, name, version, state, first_seen_at, last_seen_at, decided_at)
                  VALUES ('cl1', 'claude-code', '2.1', 'approved', ?, ?, ?);
                """, arguments: [stamp, stamp, stamp])
        }
        try AppDatabase.migrator.migrate(queue)
        try queue.read { (db: Database) throws in
            #expect(try db.tableExists("mcp_comment_author"))
            #expect(try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM mcp_comment_author") == 0)
            #expect(try String.fetchOne(db, sql: "SELECT state FROM mcp_client WHERE id = 'cl1'") == "approved")
        }
    }

    /// A store at v1_25 with an approved client gains the column NULL — the
    /// client arrives UNBOUND (her R-VX168-1: no grandfathering; the name
    /// binds the first fresh setup presented under it) — and an empty key
    /// table; its rows are kept.
    @Test func aStoreBeforeTheKeyGainsItsClientsUnboundAndKeepsThem() throws {
        let queue = try DatabaseQueue()
        try AppDatabase.migrator.migrate(queue, upTo: "v1_25_private_mark")
        try queue.write { db in
            #expect(try db.tableExists("mcp_setup_key") == false)
            try db.execute(sql: """
                INSERT INTO mcp_client (id, name, version, state, first_seen_at, last_seen_at, decided_at)
                  VALUES ('cl1', 'claude-code', '2.1', 'approved', ?, ?, ?);
                INSERT INTO mcp_grant (id, client_id, rung, scope_kind, scope_id, duration, created_at)
                  VALUES ('g1', 'cl1', 'read', 'wing', '', 'always', ?);
                """, arguments: [stamp, stamp, stamp, stamp])
        }
        try AppDatabase.migrator.migrate(queue)
        try queue.read { (db: Database) throws in
            let row = try #require(try Row.fetchOne(db, sql: "SELECT * FROM mcp_client WHERE id = 'cl1'"))
            #expect(row["state"] as String == "approved", "her approval is kept")
            #expect((row["setup_key_hash"] as String?) == nil, "and arrives unbound")
            #expect(try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM mcp_grant WHERE id = 'g1' AND revoked_at IS NULL") == 1,
                    "her grants are kept")
            #expect(try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM mcp_setup_key") == 0)
        }
    }

    /// A key ties to ONE name, ever: the bound hash is unique across clients
    /// (NULL — unbound — is legal on any number of them); a pending key is
    /// one row per hash.
    @Test func aKeyBindsOneNameAndPendsOnce() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            try seedGrantRows(db)
            try db.execute(sql: """
                INSERT INTO mcp_client (id, name, state, first_seen_at, last_seen_at) VALUES ('cl2', 'codex', 'pending', ?, ?);
                INSERT INTO mcp_client (id, name, state, first_seen_at, last_seen_at) VALUES ('cl3', 'cursor', 'pending', ?, ?);
                """, arguments: [stamp, stamp, stamp, stamp])
        }
        #expect(throws: (any Error).self, "a hash bound to two names") {
            try db.write { db in
                try db.execute(sql: "UPDATE mcp_client SET setup_key_hash = 'bound-hash' WHERE id = 'cl2'")
            }
        }
        #expect(throws: (any Error).self, "one pending row per hash") {
            try db.write { db in
                try db.execute(sql: "INSERT INTO mcp_setup_key (key_hash, minted_at) VALUES ('pending-hash', ?)",
                               arguments: [stamp])
            }
        }
        try db.read { (db: Database) throws in
            #expect(try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM mcp_client WHERE setup_key_hash IS NULL") == 2,
                    "unbound is legal on any number of names")
        }
    }

    @Test func grantsStoreWritesEnqueueNothing() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in
            let before = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? -1
            try seedGrantRows(db)
            try db.execute(sql: "UPDATE mcp_grant SET revoked_at = ? WHERE id = 'g1'", arguments: [stamp])
            let after = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? -1
            #expect(after == before, "a grants-store write must never reach the outbox")
        }
    }

    @Test func anOlderStoreGainsTheFamilyEmptyAndKeepsItsRows() throws {
        let queue = try DatabaseQueue()
        try AppDatabase.migrator.migrate(queue, upTo: "v1_23_savepoint_search")
        try queue.write { db in
            #expect(try db.tableExists("mcp_client") == false)
            try db.execute(sql: """
                INSERT INTO container (id, kind, title, created_at, updated_at)
                  VALUES ('n1', 'post', 'kept', ?, ?)
                """, arguments: [stamp, stamp])
        }
        try AppDatabase.migrator.migrate(queue)
        try queue.read { (db: Database) throws in
            for table in MCPGrantSchema.tables {
                #expect(try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM \(table)") == 0,
                        "\(table) arrives empty — no clients, no grants, the server OFF")
            }
            #expect(try String.fetchOne(db, sql: "SELECT title FROM container WHERE id = 'n1'") == "kept")
        }
    }

    @Test func theEnumsAreHeldByTheSchema() throws {
        let db = try AppDatabase.inMemory()
        try db.write { db in try seedGrantRows(db) }
        let bad: [String] = [
            "INSERT INTO mcp_client (id, name, state, first_seen_at, last_seen_at) VALUES ('x', 'y', 'trusted', '\(stamp)', '\(stamp)')",
            "INSERT INTO mcp_grant (id, client_id, rung, scope_kind, scope_id, duration, created_at) VALUES ('x', 'cl1', 'admin', 'book', 'r', 'always', '\(stamp)')",
            "INSERT INTO mcp_grant (id, client_id, rung, scope_kind, scope_id, duration, created_at) VALUES ('x', 'cl1', 'read', 'tag', 'r', 'always', '\(stamp)')",
            "INSERT INTO mcp_grant (id, client_id, rung, scope_kind, scope_id, duration, created_at) VALUES ('x', 'cl1', 'read', 'book', 'r', 'forever', '\(stamp)')",
            "INSERT INTO mcp_grant (id, client_id, rung, scope_kind, scope_id, duration, created_at) VALUES ('x', 'nobody', 'read', 'book', 'r', 'always', '\(stamp)')",
            "INSERT INTO mcp_activity (client_name, act, outcome, at) VALUES ('c', 'read_note', 'maybe', '\(stamp)')",
            // The self-declared name IS the identity: one row per name.
            "INSERT INTO mcp_client (id, name, first_seen_at, last_seen_at) VALUES ('cl2', 'claude-code', '\(stamp)', '\(stamp)')",
        ]
        for sql in bad {
            #expect(throws: (any Error).self, "\(sql)") {
                try db.write { db in try db.execute(sql: sql) }
            }
        }
    }

    @Test func thePlaintextExportCarriesTheTablesEmpty() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13nb-grants-export-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let store = dir.appendingPathComponent("library/variorum.sqlite")
        let database = try AppDatabase.openStore(at: store, custody: .inMemory(initial: StoreKey.mint()))
        try database.write { db in try seedGrantRows(db) }
        let destination = dir.appendingPathComponent("Variorum-unencrypted.sqlite")
        try StorePlaintextExport.export(from: database, to: destination)

        // The source keeps every row.
        try database.read { (db: Database) throws in
            for table in MCPGrantSchema.tables {
                #expect(try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM \(table)") == 1,
                        "the export must never touch the source's \(table)")
            }
        }
        _ = database.asRebindable().binding.lock()

        let exported = try DatabaseQueue(path: destination.path, configuration: AppDatabase.configuration())
        defer { try? exported.close() }
        try exported.read { (db: Database) throws in
            for table in MCPGrantSchema.tables {
                #expect(try db.tableExists(table), "\(table) stays — the file's schema is whole")
                #expect(try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM \(table)") == 0,
                        "no \(table) row leaves in the plaintext export (A-5)")
            }
        }
        #expect(StorePlaintextExport.strippedTables == MCPGrantSchema.tables)
        #expect(StorePlaintextExport.strippedTables.isDisjoint(with: StorePlaintextExport.localOnlyTables))
        #expect(Set(MCPGrantSchema.childFirstOrder) == MCPGrantSchema.tables
                    && MCPGrantSchema.childFirstOrder.count == MCPGrantSchema.tables.count,
                "the strip order covers the family exactly, once each")
    }
}
