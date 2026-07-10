import Foundation
import GRDB
import Testing
@testable import VariorumCore

/// Phase 9b, Step 2 — the bridge's LOCAL-ONLY state tables (`bridge_state`
/// key-value + `bridge_day` per-day agreed-hash), provably outside the sync
/// world: never in the registry, never in a mirror, never enqueued.
@Suite("Bridge state is local-only (Phase 9b, Step 2)")
struct BridgeStateTests {
    @Test func migrationCreatesTheBridgeTables() throws {
        let db = try AppDatabase.inMemory()
        try db.read { db in
            for table in ["bridge_state", "bridge_day"] {
                #expect(try db.tableExists(table), "\(table) missing after migration")
            }
            let dayColumns = try Row.fetchAll(db, sql: "PRAGMA table_info(bridge_day)")
                .map { $0["name"] as String }
            #expect(Set(dayColumns)
                    == ["day_key", "last_synced_hash", "last_remote_stamp", "remote_created_at"])
            // Local-only by construction: no sync_version column (the
            // registry test derives "synced" from exactly that marker).
            #expect(!dayColumns.contains("sync_version"))
        }
    }

    @Test func bridgeTablesAreOutsideTheSyncRegistry() throws {
        for table in ["bridge_state", "bridge_day"] {
            #expect(SyncSchema.table(named: table) == nil,
                    "\(table) must never be a synced table")
            #expect(SyncSchema.localOnlyTables.contains(table),
                    "\(table) must be declared local-only, so the walks know it is deliberate")
        }
        // The full-schema identity (registry == sync_version-carrying tables;
        // local-only == the rest) is pinned by
        // `SyncSchemaTests.registryMatchesLiveSchemaExactly`, which now runs
        // over a schema containing the bridge tables.
    }

    /// Writes to bridge state must never enqueue — there are no outbox
    /// triggers on local-only tables, and the engine's bookkeeping writes
    /// (cursor advances, day-state records at pull cadence) must not turn
    /// into phantom pushes.
    @Test func bridgeStateWritesNeverTouchTheOutbox() throws {
        let db = try AppDatabase.inMemory()
        // A fresh store's seeded settings enqueue at migration time (their
        // outbox triggers are live) — clear so the assertion isolates the
        // bridge writes.
        try db.clearOutbox()
        try db.write { db in
            try db.execute(sql: """
                INSERT INTO bridge_state (key, value) VALUES ('cursor_server_updated_at', '42');
                INSERT INTO bridge_day (day_key, last_synced_hash) VALUES ('2026-07-09', 'abc');
                UPDATE bridge_day SET last_synced_hash = 'def' WHERE day_key = '2026-07-09';
                """)
        }
        #expect(try db.fetchInt("SELECT COUNT(*) FROM sync_outbox") == 0)
    }

    /// The Step 2 red-on-old-style proof the plan requires: a bridge table
    /// WRONGLY registered as synced would fail the standing walks. The walks
    /// judge two ways — the registry⇄schema identity (a registered table
    /// must carry `sync_version`) and the mirror-DDL coverage (a registered
    /// table must have a mirror home). This test runs both predicates
    /// against a doctored registration and asserts each one detects it,
    /// without weakening the real registry.
    @Test func aWronglyRegisteredBridgeTableWouldFailTheWalks() throws {
        let db = try AppDatabase.inMemory()
        let doctoredRegistry = SyncSchema.tables.map(\.name) + ["bridge_day"]

        // Walk predicate 1 (SyncSchemaTests.registryMatchesLiveSchemaExactly):
        // synced == the sync_version-carrying tables, by introspection.
        try db.read { db in
            let allTables = Set(try String.fetchAll(
                db,
                sql: "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'grdb_%' AND name NOT LIKE 'sqlite_%'"))
            var syncMarked: Set<String> = []
            for table in allTables {
                let columns = try Row.fetchAll(db, sql: "PRAGMA table_info(\(table))")
                if columns.contains(where: { $0["name"] == "sync_version" }) {
                    syncMarked.insert(table)
                }
            }
            #expect(Set(doctoredRegistry) != syncMarked,
                    "the registry walk must flag a registered table with no sync_version")
            #expect(Set(SyncSchema.tables.map(\.name)) == syncMarked,
                    "the REAL registry stays exactly the sync_version set")
        }

        // Walk predicate 2 (SerializerCompletenessTests.mirrorDDLCoversEverySyncedColumn):
        // every registered table needs a mirror-DDL home; bridge_day has none.
        let serverDir = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Server/supabase", isDirectory: true)
        let ddl = try FileManager.default
            .contentsOfDirectory(at: serverDir, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "sql" }
            .map { try String(contentsOf: $0, encoding: .utf8).lowercased() }
            .joined(separator: "\n")
        #expect(!ddl.contains("create table bridge_day"),
                "the mirror must have no home for a local-only table")
        #expect(!ddl.contains("create table bridge_state"),
                "the mirror must have no home for a local-only table")
    }
}
