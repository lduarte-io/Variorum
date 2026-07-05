import Foundation
import GRDB
import Testing
@testable import VariorumCore

@Suite("Database stack (Phase 1, Step 1)")
struct DatabaseStackTests {
    @Test func inMemoryDatabaseOpens() throws {
        _ = try AppDatabase.inMemory()
    }

    @Test func foreignKeysAreOnInsideReadsAndWrites() throws {
        let db = try AppDatabase.inMemory()
        let inWrite = try db.write { try Bool.fetchOne($0, sql: "PRAGMA foreign_keys") }
        let inRead = try db.read { try Bool.fetchOne($0, sql: "PRAGMA foreign_keys") }
        #expect(inWrite == true)
        #expect(inRead == true)
    }

    @Test func onDiskDatabaseUsesWAL() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("VariorumTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let db = try AppDatabase.onDisk(url: dir.appendingPathComponent("test.sqlite"))
        let mode = try db.read { try String.fetchOne($0, sql: "PRAGMA journal_mode") }
        #expect(mode?.lowercased() == "wal")
    }

    @Test func applyingRemoteSetsAndClearsTheFlag() throws {
        let db = try AppDatabase.inMemory()
        let during = try db.applyingRemote { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM _sync_applying")
        }
        #expect(during == 1)

        let after = try db.write { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM _sync_applying")
        }
        #expect(after == 0)
    }

    @Test func applyingRemoteClearsTheFlagWhenTheBodyThrows() throws {
        struct Boom: Error {}
        let db = try AppDatabase.inMemory()
        #expect(throws: Boom.self) {
            try db.applyingRemote { _ -> Void in throw Boom() }
        }
        let after = try db.write { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM _sync_applying")
        }
        #expect(after == 0)
    }
}
