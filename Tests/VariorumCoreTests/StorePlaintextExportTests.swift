import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// pre-13x batch 3b — the plaintext `.sqlite` export (the postures design
/// decision 15; §3.3; §14.1 / §14.13): from an OPEN keyed store, a decrypted
/// copy WITHOUT the local bookkeeping tables (the registry's local-only
/// set), every synced table keeping its sync columns, no key-shaped value in
/// the file; the source untouched; an existing destination never
/// overwritten.
@Suite("pre-13x 3b — the plaintext export strips the local tables and nothing else")
struct StorePlaintextExportTests {
    private func scratchDirectory() throws -> URL {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-3b-export-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    @Test func theExportCarriesTheSyncedTablesOnlyKeepsTheirSyncColumnsAndHoldsNoKey() throws {
        let dir = try scratchDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("library/variorum.sqlite")
        let key = StoreKey.mint()
        let database = try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: key))
        let stamp = "2026-09-06T00:00:00Z"
        try database.write { db in
            try db.execute(
                sql: "INSERT INTO container (id, kind, title, created_at, updated_at, owner_id) VALUES (?, 'post', ?, ?, ?, ?)",
                arguments: ["note-export-1", "An exported note — plain words", stamp, stamp, "owner-x"])
            try db.execute(
                sql: "INSERT OR REPLACE INTO sync_state (key, value) VALUES ('last_server_seq', '42')")
        }
        // The outbox trigger enqueued the note; the local tables are populated.
        let outboxBefore = try database.read { try Int.fetchOne($0, sql: "SELECT count(*) FROM sync_outbox") ?? 0 }
        #expect(outboxBefore >= 1)

        let destination = dir.appendingPathComponent("Variorum-unencrypted.sqlite")
        try StorePlaintextExport.export(from: database, to: destination)

        // Plaintext bytes, opened by a bare SQLite connection.
        #expect(StoreFilePresence.classify(at: destination) == .plaintext)
        let plain = try DatabaseQueue(path: destination.path)
        let tables = try plain.read { db in
            Set(try String.fetchAll(db, sql: "SELECT name FROM sqlite_master WHERE type = 'table'"))
        }
        #expect(tables.isDisjoint(with: SyncSchema.localOnlyTables),
                "the local-only set is absent: \(tables.intersection(SyncSchema.localOnlyTables))")
        for synced in SyncSchema.tables.map(\.name) {
            #expect(tables.contains(synced), "every synced table travels: \(synced)")
        }
        let row = try plain.read { db in
            try Row.fetchOne(db, sql: "SELECT title, sync_version, owner_id FROM container WHERE id = ?", arguments: ["note-export-1"])
        }
        #expect(row?["title"] == "An exported note — plain words")
        #expect(row?["owner_id"] == "owner-x" && (row?["sync_version"] as Int?) != nil,
                "the sync columns ride (§14.13's reconciliation for 13x's open door)")
        try plain.close()

        // No key-shaped value: neither the raw key nor its hex in the file.
        let bytes = try Data(contentsOf: destination)
        #expect(bytes.range(of: key.data) == nil && bytes.range(of: Data(key.hexEncoded.utf8)) == nil)
        #expect(bytes.range(of: Data("An exported note".utf8)) != nil, "the words are readable — that is the export")

        // The source is untouched: still keyed, its local tables still there.
        #expect(StoreFilePresence.classify(at: storeURL) == .encryptedOrUnknown)
        let outboxAfter = try database.read { try Int.fetchOne($0, sql: "SELECT count(*) FROM sync_outbox") ?? 0 }
        let cursor = try database.read { try String.fetchOne($0, sql: "SELECT value FROM sync_state WHERE key = 'last_server_seq'") }
        #expect(outboxAfter == outboxBefore && cursor == "42")

        // An existing destination is never overwritten.
        #expect(throws: StorePlaintextExport.ExportError.self) {
            try StorePlaintextExport.export(from: database, to: destination)
        }
    }

    /// 13o §FORK RULINGS (2026-10-06), the derived-set ruling's pin: the
    /// export KEEPS the search-index family — the no-lock-in file answers a
    /// full-text query through a bare connection, and no derived table was
    /// swept out with the local-only set.
    @Test func theExportKeepsTheDerivedSearchIndexWorking() throws {
        let dir = try scratchDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("library/variorum.sqlite")
        let database = try AppDatabase.openStore(
            at: storeURL, custody: .inMemory(initial: StoreKey.mint()))
        let stamp = "2026-10-06T00:00:00Z"
        try database.write { db in
            try db.execute(
                sql: "INSERT INTO container (id, kind, title, created_at, updated_at) VALUES (?, 'post', ?, ?, ?)",
                arguments: ["note-derived-1", "The lighthouse keeper's ledger", stamp, stamp])
        }

        let destination = dir.appendingPathComponent("Variorum-unencrypted.sqlite")
        try StorePlaintextExport.export(from: database, to: destination)

        let plain = try DatabaseQueue(path: destination.path)
        defer { try? plain.close() }
        try plain.read { db in
            let tables = Set(try String.fetchAll(
                db, sql: "SELECT name FROM sqlite_master WHERE type = 'table'"))
            #expect(SyncSchema.derivedTables.isSubset(of: tables),
                    "the derived family travels whole: missing \(SyncSchema.derivedTables.subtracting(tables))")
            let hits = try Int.fetchOne(
                db,
                sql: "SELECT count(*) FROM search_fts WHERE search_fts MATCH ?",
                arguments: ["lighthouse"]) ?? 0
            #expect(hits == 1, "the exported index answers a body query by itself")
        }
    }
}
