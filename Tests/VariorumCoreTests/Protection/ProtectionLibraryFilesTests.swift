//
//  ProtectionLibraryFilesTests.swift
//  VariorumCoreTests — VX-306 U1a piece 4: the library file's mechanics the
//  production leaves stand on (`Protection/Files/ProtectionLibraryFiles.swift`),
//  on real SQLCipher files in a temp folder — headless, both configurations.
//

import Foundation
import GRDB
import Testing

@testable import VariorumCore

@Suite("VX-306 U1a — the library file's mechanics (real SQLCipher, temp folders)")
struct ProtectionLibraryFilesTests {
    final class Folder {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("vx306-files-\(UUID().uuidString)", isDirectory: true)
        init() { try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true) }
        deinit { try? FileManager.default.removeItem(at: url) }
        func file(_ name: String) -> URL { url.appendingPathComponent(name) }
    }

    static func record(_ fingerprint: String = "0123456789abcdef") -> ProtectionRecord {
        ProtectionRecord.minting(
            libraryID: UUID().uuidString.lowercased(), mode: .standard, account: nil,
            currentFingerprint: fingerprint, at: Date(timeIntervalSinceReferenceDate: 790_000_000))
    }

    @Test func aNewLibraryHoldsItsRecordOpensOnlyWithItsKeyAndMigratesAtTheOrdinaryOpen() throws {
        let folder = Folder()
        let slot = folder.file("variorum.sqlite")
        let key = StoreKey.mint()
        let record = Self.record(StoreKeyEnvelope.fingerprint(of: key))
        try ProtectionLibraryFiles.createLibrary(at: slot, key: key, record: record, date: Date())
        #expect(ProtectionLibraryFiles.opens(slot, key: key))
        #expect(!ProtectionLibraryFiles.opens(slot, key: StoreKey.mint()))
        #expect(try ProtectionLibraryFiles.readRecord(at: slot, key: key) == record)
        #expect(throws: (any Error).self) { try ProtectionLibraryFiles.readRecord(at: slot, key: StoreKey.mint()) }
        #expect(StoreFilePresence.classify(at: slot) == .encryptedOrUnknown)
        // A second creation never clobbers it.
        #expect(throws: ProtectionLibraryFiles.FileError.self) {
            try ProtectionLibraryFiles.createLibrary(at: slot, key: StoreKey.mint(), record: Self.record(), date: Date())
        }
        // The app's ordinary open runs every migration over it, and the record survives.
        let store = try AppDatabase.onDisk(url: slot, key: key)
        #expect(try store.read { try $0.tableExists("container") })
        #expect(try store.read { try ProtectionRecordSchema.read($0) } == record)
    }

    @Test func aRecordWriteReplacesTheRecordAndDrainsTheWAL() throws {
        let folder = Folder()
        let slot = folder.file("variorum.sqlite")
        let key = StoreKey.mint()
        try ProtectionLibraryFiles.createLibrary(at: slot, key: key, record: Self.record(), date: Date())
        let store = try AppDatabase.onDisk(url: slot, key: key)  // WAL mode, like the app's pool
        _ = store
        var next = Self.record()
        next.reminderDismissals = 2
        try ProtectionLibraryFiles.writeRecord(next, at: slot, key: key, date: Date())
        #expect(try ProtectionLibraryFiles.readRecord(at: slot, key: key) == next)
        #expect(ProtectionLibraryFiles.walIsDrained(at: slot))
    }

    @Test func theReencryptedCopyOpensUnderTheNewKeyAloneAndHoldsEveryRow() throws {
        let folder = Folder()
        let slot = folder.file("variorum.sqlite")
        let staged = folder.file("variorum.sqlite.staged")
        let key = StoreKey.mint(), newKey = StoreKey.mint()
        let record = Self.record()
        try ProtectionLibraryFiles.createLibrary(at: slot, key: key, record: record, date: Date())
        _ = try AppDatabase.onDisk(url: slot, key: key)  // a migrated library
        try ProtectionLibraryFiles.exportReencrypted(from: slot, key: key, to: staged, newKey: newKey)
        #expect(ProtectionLibraryFiles.opens(staged, key: newKey))
        #expect(!ProtectionLibraryFiles.opens(staged, key: key))
        #expect(ProtectionLibraryFiles.opens(slot, key: key), "the source is untouched")
        #expect(try ProtectionLibraryFiles.readRecord(at: staged, key: newKey) == record)
    }

    @Test func aSnapshotIsUnderTheSameKeyAndAPrivateCopyLeavesTheOriginalUnwritten() throws {
        let folder = Folder()
        let slot = folder.file("variorum.sqlite")
        let key = StoreKey.mint()
        try ProtectionLibraryFiles.createLibrary(at: slot, key: key, record: Self.record(), date: Date())
        let pair = folder.file("Backups/aaaaaaaa/bbbbbbbb/variorum-backup-2026-10-18-120000-01234567.sqlite")
        try ProtectionLibraryFiles.snapshot(of: slot, key: key, to: pair)
        #expect(ProtectionLibraryFiles.opens(pair, key: key))
        #expect(throws: ProtectionLibraryFiles.FileError.self) { try ProtectionLibraryFiles.snapshot(of: slot, key: key, to: pair) }
        let before = try FileManager.default.contentsOfDirectory(atPath: pair.deletingLastPathComponent().path).sorted()
        let copy = try ProtectionLibraryFiles.privateCopy(of: pair, inside: folder.file("probes"))
        #expect(ProtectionLibraryFiles.opens(copy, key: key))
        let after = try FileManager.default.contentsOfDirectory(atPath: pair.deletingLastPathComponent().path).sorted()
        #expect(before == after, "the probe wrote nothing beside the original")
    }

    @Test func aNonEmptyWALIsNotDrained() throws {
        let folder = Folder()
        let slot = folder.file("variorum.sqlite")
        #expect(ProtectionLibraryFiles.walIsDrained(at: slot), "no WAL is drained")
        try Data([1, 2, 3]).write(to: URL(fileURLWithPath: slot.path + "-wal"))
        #expect(!ProtectionLibraryFiles.walIsDrained(at: slot))
    }
}
