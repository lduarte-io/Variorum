import Foundation
import GRDB

// VX-306 U1a, piece 4 — THE LIBRARY FILE'S MECHANICS (`notes/plans/vx-306-castle-open-road.md` §2 U1a, the
// `SQLCipherLibraryLeaf` row). The production `LibraryFileLeaf` and `BackupsLeaf` live in the app
// (`App/Variorum/Shared/Protection/`), but every SQLCipher statement they need lives HERE, beside the ONE
// keying implementation (`AppDatabase.configuration(key:)` — the raw-key pragma, P15's redaction), so no
// second keying road exists and every road is testable headless under `swift test` in both configurations.
//
// DUMB, like the leaves (`Executor/Leaves.swift`'s header): each function does exactly what it says to the
// file it is handed, verifies its own write, and decides nothing about protection. NEVER THE MIGRATOR —
// the record is read before the app's open (a library from before this design has no record and is not
// handled — rule 26), and a staged or copied file is never migrated here.
//
// THE ROADS:
//   - `opens` — the read probe (`StoreEncryptionMigration.opens`, reused).
//   - `readRecord` / `writeRecord` — a thin keyed connection over `protection_record` (one row per file —
//     `ProtectionRecordSchema`); a write drains the file's WAL (TRUNCATE) after it, so a quiesced library
//     carries no WAL into a swap.
//   - `exportReencrypted` — `sqlcipher_export` from a keyed source into a fresh file under a new key
//     (`StoreEncryptionMigration.rekey`'s measured road, its verification kept: the copy opens under the
//     new key and holds exactly the source's rows), the source's WAL drained after.
//   - `createLibrary` — a fresh keyed file holding `protection_record` only, landed by a no-clobber link
//     (a library already in the slot is never overwritten); the app's ordinary open then runs every
//     migration over it.
//   - `snapshot` — one consistent copy under the SAME key through SQLite's backup API (`AppDatabase
//     .backup(to:)`'s mechanism — SQLCipher refuses a backup between mismatched keys).
//   - `privateCopy` — a byte copy of a file and its WAL into a fresh private folder: a picked or catalogued
//     copy is NEVER written (13x's rule — even a read-only open can write sidecars beside it), so every
//     probe and every stage of a copy reads the private copy.
//   - `walIsDrained` — the swap's belt: a non-empty WAL beside the outgoing file would replay into the
//     incoming one (the 13p migration's replay window), so the swap refuses while one is there.

public enum ProtectionLibraryFiles {
    public struct FileError: Error, Equatable, CustomStringConvertible, Sendable {
        public let reason: String
        public init(_ reason: String) { self.reason = reason }
        public var description: String { "ProtectionLibraryFiles: \(reason)" }
    }

    public static let sidecarSuffixes = ["-wal", "-shm", "-journal"]

    // MARK: - The probe

    /// Does `key` open the library file at `url`? A read — nothing written.
    public static func opens(_ url: URL, key: StoreKey) -> Bool {
        guard FileManager.default.fileExists(atPath: url.path) else { return false }
        return StoreEncryptionMigration.opens(url, key: key)
    }

    // MARK: - The record

    /// The record inside the file at `url`, opened with `key` (nil: none — rule 26). Throws when `key` does
    /// not open the file, or the file holds more than one record.
    public static func readRecord(at url: URL, key: StoreKey) throws -> ProtectionRecord? {
        let queue = try keyedQueue(at: url, key: key, mustExist: true)
        defer { try? queue.close() }
        return try queue.read { try ProtectionRecordSchema.read($0) }
    }

    /// The file's ONE record, replacing whatever it held; read back and compared before returning; the WAL
    /// drained after.
    public static func writeRecord(_ record: ProtectionRecord, at url: URL, key: StoreKey, date: Date) throws {
        let queue = try keyedQueue(at: url, key: key, mustExist: true)
        defer { try? queue.close() }
        try queue.write { try ProtectionRecordSchema.write(record, at: date, $0) }
        let back = try queue.read { try ProtectionRecordSchema.read($0) }
        guard back == record else { throw FileError("the record written did not read back") }
        try drainWAL(queue)
    }

    // MARK: - Export-and-swap's first half

    /// The library at `source` (under `key`) re-encrypted into a FRESH file at `destination` under `newKey`
    /// — the source untouched but for its WAL drained after the export. Verified: the copy opens under
    /// `newKey` and holds exactly the source's rows.
    public static func exportReencrypted(from source: URL, key: StoreKey, to destination: URL, newKey: StoreKey) throws {
        removeWithSidecars(destination)
        var counts: [String: Int] = [:]
        do {
            let queue = try keyedQueue(at: source, key: key, mustExist: true)
            defer { try? queue.close() }
            try queue.writeWithoutTransaction { db in
                do {
                    try db.execute(
                        sql: "ATTACH DATABASE ? AS staged KEY \"x'\(newKey.hexEncoded)'\"",
                        arguments: [destination.path])
                } catch {
                    // P15: no key ever rides an error channel.
                    let scrubbed = newKey.redactedDescription(of: error)
                        .replacingOccurrences(of: key.hexEncoded, with: "<store key redacted>")
                    throw FileError("the staged file could not be attached (\(scrubbed))")
                }
                try db.execute(sql: "SELECT sqlcipher_export('staged')")
                try db.execute(sql: "DETACH DATABASE staged")
                counts = try StoreEncryptionMigration.tableCounts(db)
            }
            try drainWAL(queue)
        }
        do {
            let verify = try keyedQueue(at: destination, key: newKey, mustExist: true)
            defer { try? verify.close() }
            let found = try verify.read { try StoreEncryptionMigration.tableCounts($0) }
            guard found == counts else {
                throw FileError("the re-encrypted copy failed row-count verification (\(found.count) tables vs \(counts.count))")
            }
        } catch {
            removeWithSidecars(destination)
            throw error
        }
        guard StoreFilePresence.classify(at: destination) == .encryptedOrUnknown else {
            removeWithSidecars(destination)
            throw FileError("the re-encrypted copy is not ciphertext")
        }
    }

    // MARK: - A new library

    /// A NEW library at `url`, under `key`, holding `protection_record` only (the record inside). Refuses
    /// when anything is already at `url`; lands by a no-clobber link, so a crash leaves the slot empty or
    /// whole.
    public static func createLibrary(at url: URL, key: StoreKey, record: ProtectionRecord, date: Date) throws {
        let manager = FileManager.default
        guard !manager.fileExists(atPath: url.path) else { throw FileError("a library is already in the slot") }
        try manager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let temp = URL(fileURLWithPath: url.path + ".creating")
        removeWithSidecars(temp)
        do {
            let queue = try keyedQueue(at: temp, key: key, mustExist: false)
            defer { try? queue.close() }
            try queue.write { try ProtectionRecordSchema.write(record, at: date, $0) }
        }
        guard opens(temp, key: key), try readRecord(at: temp, key: key) == record else {
            removeWithSidecars(temp)
            throw FileError("the new library did not open with its key")
        }
        for suffix in sidecarSuffixes { try? manager.removeItem(atPath: temp.path + suffix) }
        guard link(temp.path, url.path) == 0 else {
            let code = errno
            removeWithSidecars(temp)
            throw FileError("the new library could not be landed (errno \(code))")
        }
        try? manager.removeItem(at: temp)
    }

    // MARK: - Copies

    /// One consistent copy of the library at `source` under its OWN key at `destination` (SQLite's backup
    /// API — safe against a library in use). Refuses an existing destination.
    public static func snapshot(of source: URL, key: StoreKey, to destination: URL) throws {
        let manager = FileManager.default
        guard !manager.fileExists(atPath: destination.path) else { throw FileError("a file is already at \(destination.lastPathComponent)") }
        try manager.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
        let from = try keyedQueue(at: source, key: key, mustExist: true)
        defer { try? from.close() }
        do {
            let to = try DatabaseQueue(path: destination.path, configuration: AppDatabase.configuration(key: key))
            defer { try? to.close() }
            try from.backup(to: to)
        } catch {
            removeWithSidecars(destination)
            throw error
        }
        for suffix in sidecarSuffixes { try? manager.removeItem(atPath: destination.path + suffix) }
        guard opens(destination, key: key) else {
            removeWithSidecars(destination)
            throw FileError("the copy did not open with its key")
        }
    }

    /// A byte copy of the file at `url` (and its WAL, when one is beside it) inside a FRESH private folder
    /// under `directory`; the caller removes the folder. The original is only read.
    public static func privateCopy(of url: URL, inside directory: URL) throws -> URL {
        let manager = FileManager.default
        let folder = directory.appendingPathComponent("vx306-probe-\(UUID().uuidString)", isDirectory: true)
        try manager.createDirectory(at: folder, withIntermediateDirectories: true)
        let copy = folder.appendingPathComponent(url.lastPathComponent)
        do {
            try manager.copyItem(at: url, to: copy)
            let wal = URL(fileURLWithPath: url.path + "-wal")
            if manager.fileExists(atPath: wal.path) {
                try manager.copyItem(at: wal, to: URL(fileURLWithPath: copy.path + "-wal"))
            }
        } catch {
            try? manager.removeItem(at: folder)
            throw error
        }
        return copy
    }

    // MARK: - The swap's belt

    /// No WAL beside `url`, or an empty one.
    public static func walIsDrained(at url: URL) -> Bool {
        let path = url.path + "-wal"
        guard let size = (try? FileManager.default.attributesOfItem(atPath: path))?[.size] as? Int else { return true }
        return size == 0
    }

    /// The file and its sidecars removed (absent is fine).
    public static func removeWithSidecars(_ url: URL) {
        try? FileManager.default.removeItem(at: url)
        for suffix in sidecarSuffixes { try? FileManager.default.removeItem(atPath: url.path + suffix) }
    }

    // MARK: - Connections

    static func keyedQueue(at url: URL, key: StoreKey, mustExist: Bool) throws -> DatabaseQueue {
        if mustExist, !FileManager.default.fileExists(atPath: url.path) {
            throw FileError("no file at \(url.lastPathComponent)")
        }
        return try DatabaseQueue(path: url.path, configuration: AppDatabase.configuration(key: key))
    }

    static func drainWAL(_ queue: DatabaseQueue) throws {
        try queue.writeWithoutTransaction { db in
            _ = try Row.fetchOne(db, sql: "PRAGMA wal_checkpoint(TRUNCATE)")
        }
    }
}
