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
            """, arguments: [stamp, stamp, stamp, stamp, stamp, stamp])
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
            let triggers = try String.fetchAll(db, sql: """
                SELECT name FROM sqlite_master WHERE type = 'trigger'
                  AND tbl_name IN ('mcp_client', 'mcp_grant', 'mcp_activity', 'mcp_switch')
                """)
            #expect(triggers.isEmpty, "no trigger — no outbox capture, no index capture — reads the grants store")
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
