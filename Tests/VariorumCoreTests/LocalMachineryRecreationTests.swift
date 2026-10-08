import Foundation
import GRDB
import Testing

@testable import VariorumCore

// Phase 13x U2 row 8 — the four local-only tables recreated inside a
// re-opened plaintext export (§14.13 + pre-13x ledger 22), pinned over
// the PRODUCTION export: the write-refusal the recorded consequence
// promises (red — the state without recreation), the write landing WITH
// an outbox row after recreation (green — the triggers work again), the
// §14.13 state (empty outbox, no cursor, no seqs), and the structural
// schema-equality pin that keeps the restated DDL from drifting from the
// migration's.

@Suite("13x U2 — the local machinery's recreation (re-opened exports)")
struct LocalMachineryRecreationTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13x-recreate-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// A real library with one row, exported through the production road.
    private func makeExport(in dir: URL) throws -> URL {
        let store = dir.appendingPathComponent("library/variorum.sqlite")
        let key = StoreKey.mint()
        let database = try AppDatabase.openStore(at: store, custody: .inMemory(initial: key))
        try database.write { db in
            try db.execute(
                sql: """
                    INSERT INTO container (id, kind, title, created_at, updated_at)
                    VALUES ('c-export-1', 'post', 'travelled', '2027-01-01T00:00:00Z',
                            '2027-01-01T00:00:00Z')
                    """)
        }
        let destination = dir.appendingPathComponent("Variorum-unencrypted.sqlite")
        try StorePlaintextExport.export(from: database, to: destination)
        _ = database.asRebindable().binding.lock()
        return destination
    }

    @Test func aReopenedExportRefusesWritesUntilRecreationAndTakesThemAfter() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let export = try makeExport(in: dir)

        // RED — the recorded consequence, demonstrated: the copied outbox
        // triggers name the dropped tables, so a synced-table write
        // refuses whole.
        let queue = try DatabaseQueue(
            path: export.path, configuration: AppDatabase.configuration())
        #expect(throws: (any Error).self) {
            try queue.write { db in
                try db.execute(sql: """
                    INSERT INTO container (id, kind, title, created_at, updated_at)
                    VALUES ('c-refused', 'post', 'refused', '2027-01-02T00:00:00Z',
                            '2027-01-02T00:00:00Z')
                    """)
            }
        }
        try queue.close()

        // The recreation, before any open.
        let created = try LocalMachineryRecreation.recreateIfMissing(inPlaintextStoreAt: export)
        #expect(created == SyncSchema.localOnlyTables.sorted())

        // GREEN — the same write lands, and the trigger enqueues it.
        let reopened = try DatabaseQueue(
            path: export.path, configuration: AppDatabase.configuration())
        defer { try? reopened.close() }
        try reopened.write { db in
            try db.execute(sql: """
                INSERT INTO container (id, kind, title, created_at, updated_at)
                VALUES ('c-landed', 'post', 'landed', '2027-01-02T00:00:00Z',
                        '2027-01-02T00:00:00Z')
                """)
        }
        let facts = try reopened.read { db -> (outbox: Int, pending: String?, state: Int, seqs: Int) in
            (try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_outbox") ?? -1,
             try String.fetchOne(db, sql: "SELECT row_id FROM sync_outbox LIMIT 1"),
             try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_state") ?? -1,
             try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM sync_row_seq") ?? -1)
        }
        #expect(facts.outbox == 1)
        #expect(facts.pending == "c-landed")
        // §14.13's state before that write: no cursor, no seqs — a pull
        // from 0 with nothing of the export's own enqueued (the one row
        // above is this test's write, not the export's past).
        #expect(facts.state == 0)
        #expect(facts.seqs == 0)
        // A second run is a no-op.
        #expect(try LocalMachineryRecreation.recreateIfMissing(inPlaintextStoreAt: export) == [])
    }

    @Test func theRestatedDDLMatchesTheMigrationsStructurally() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let export = try makeExport(in: dir)
        try LocalMachineryRecreation.recreateIfMissing(inPlaintextStoreAt: export)

        // A freshly MIGRATED plaintext store is the reference shape.
        let reference = try DatabaseQueue()
        try AppDatabase.migrator.migrate(reference)

        let recreated = try DatabaseQueue(
            path: export.path, configuration: AppDatabase.configuration())
        defer { try? recreated.close() }

        func structure(_ db: Database, _ table: String) throws -> [[String]] {
            try Row.fetchAll(db, sql: "PRAGMA table_info(\(table))").map { row in
                ["\(row["name"] ?? "")", "\(row["type"] ?? "")", "\(row["notnull"] ?? "")",
                 "\(row["dflt_value"] ?? "")", "\(row["pk"] ?? "")"]
            }
        }
        for table in SyncSchema.localOnlyTables.sorted() {
            let expected = try reference.read { try structure($0, table) }
            let actual = try recreated.read { try structure($0, table) }
            #expect(actual == expected, "structure drift in \(table)")
            #expect(!expected.isEmpty, "\(table) missing from the reference store")
        }
    }

    @Test func theRegistryAndTheDDLMapCoverEachOtherExactly() {
        #expect(Set(LocalMachineryRecreation.ddl.keys) == SyncSchema.localOnlyTables)
    }
}
