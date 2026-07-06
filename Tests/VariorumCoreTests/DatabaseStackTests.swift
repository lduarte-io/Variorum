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

    // MARK: - The recoverable-open path (Phase 7: the shell's failure UX)

    @Test func openStoreOpensAFreshStoreCreatingIntermediateFolders() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("VariorumTests-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        // Two levels that do not exist yet, like Application Support/Variorum.
        let url = dir.appendingPathComponent("Variorum", isDirectory: true)
            .appendingPathComponent("variorum.sqlite")
        let db = try AppDatabase.openStore(at: url)
        let mode = try db.read { try String.fetchOne($0, sql: "PRAGMA journal_mode") }
        #expect(mode?.lowercased() == "wal")
    }

    @Test func openStoreMapsACorruptedFileIntoTheTypedFailure() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("VariorumTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        // Not a SQLite file: garbage bytes where the store should be.
        let url = dir.appendingPathComponent("variorum.sqlite")
        try Data(repeating: 0xAB, count: 1024).write(to: url)

        #expect {
            _ = try AppDatabase.openStore(at: url)
        } throws: { error in
            guard let open = error as? AppDatabase.StoreOpenError else { return false }
            // The alert's two load-bearing fields: where, and why.
            return open.storePath == url.path && !open.reason.isEmpty
        }
    }
}
