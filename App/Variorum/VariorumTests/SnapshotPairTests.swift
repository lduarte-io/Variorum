//
//  SnapshotPairTests.swift
//  VariorumTests
//
//  pre-13x batch 2a — ledger row 42 (decision 11 as ruled: EVERY SNAPSHOT
//  has its own key file, written with it and NEVER rewritten) and row 7
//  (the keyless byte-copy of the closed library at lock time when a backup
//  is due, checked at the next unlock). Real files, a real keyed store — the
//  Phase 8 / 13p backup pins' pattern. No Keychain anywhere.
//

import Foundation
import GRDB
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("pre-13x 2a — one key file per snapshot (row 42) and the lock-time copy (row 7)")
struct SnapshotPairTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-2a-pairs-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    private func folderBytes(_ folder: URL) throws -> [String: Data] {
        var out: [String: Data] = [:]
        for url in try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil) {
            out[url.lastPathComponent] = try Data(contentsOf: url)
        }
        return out
    }

    private func fileContains(_ needle: String, at url: URL) throws -> Bool {
        let bytes = try Data(contentsOf: url)
        return bytes.range(of: Data(needle.utf8)) != nil
    }

    /// THE TWO §12 PINS: a passphrase change between two snapshots leaves
    /// the earlier pair byte-identical and the later pair under the new
    /// word — and NO file in the folder is rewritten by the second run.
    /// RED ON OLD (behavioural revert: `writeSnapshotKeyFile` a no-op): no
    /// pair exists beside either snapshot.
    @Test func eachSnapshotsKeyFileIsWrittenWithItAndNeverRewritten() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("library/variorum.sqlite")
        let backups = dir.appendingPathComponent("library/Backups", isDirectory: true)
        let key = StoreKey.mint()
        let database = try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: key))
        defer { database.asRebindable().binding.lock() }

        // The live key file under the FIRST passphrase.
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "first word", kdf: fastKDF())
        try envelope.write(at: envelope.preferredURL(besideStore: storeURL))
        let configuration = StoreBackup.Configuration(keyEnvelopeStoreURL: storeURL)

        let firstWritten = try await Task.detached {
            try StoreBackup.performBackupIfDue(
                database: database, directory: backups, configuration: configuration,
                now: Date(timeIntervalSince1970: 1_800_000_000), force: true)
        }.value
        let first = try #require(firstWritten)
        let firstPair = StoreBackup.pairedKeyFile(for: first)
        #expect(firstPair.lastPathComponent.hasSuffix(".keys.json"))
        #expect(FileManager.default.fileExists(atPath: firstPair.path),
                "the snapshot's OWN key file rides beside it")
        let firstPairEnvelope = try #require(try StoreKeyEnvelope.load(at: firstPair))
        #expect(try firstPairEnvelope.unwrapKey(passphrase: "first word") == key)
        let folderAfterFirst = try folderBytes(backups)

        // A PASSPHRASE CHANGE (the re-wrap, as the door lands it).
        try envelope.setPassphraseWrap(key: key, passphrase: "second word", kdf: fastKDF())
        try envelope.write(at: envelope.preferredURL(besideStore: storeURL))

        let secondWritten = try await Task.detached {
            try StoreBackup.performBackupIfDue(
                database: database, directory: backups, configuration: configuration,
                now: Date(timeIntervalSince1970: 1_800_100_000), force: true)
        }.value
        let second = try #require(secondWritten)
        let secondPair = StoreBackup.pairedKeyFile(for: second)
        let folderAfterSecond = try folderBytes(backups)

        // The earlier pair is BYTE-IDENTICAL — nothing in the folder that
        // existed before was rewritten.
        for (name, bytes) in folderAfterFirst {
            #expect(folderAfterSecond[name] == bytes, "\(name) was rewritten by the second run")
        }
        // The later pair is under the NEW word; the earlier under the old.
        let secondPairEnvelope = try #require(try StoreKeyEnvelope.load(at: secondPair))
        #expect(try secondPairEnvelope.unwrapKey(passphrase: "second word") == key)
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) {
            try secondPairEnvelope.unwrapKey(passphrase: "first word")
        }
        #expect(try firstPairEnvelope.unwrapKey(passphrase: "first word") == key,
                "the earlier snapshot still opens with the passphrase of ITS day")
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) {
            try firstPairEnvelope.unwrapKey(passphrase: "second word")
        }
        // The pair carries the snapshot's fingerprint name. (The
        // fingerprint-named FOLDER file is `performRun`'s `copyKeyEnvelope`
        // — pinned in `Phase13pBackupEnvelopeTests`, untouched here.)
        #expect(StoreBackup.shortFingerprint(fromBackupURL: second)
                == StoreKeyEnvelope.shortFingerprint(StoreKeyEnvelope.fingerprint(of: key)))
    }

    /// Pruning takes the PAIR with the snapshot (a 1a-era snapshot without
    /// a pair prunes as before).
    @Test func pruningRemovesTheSnapshotAndItsPair() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("library/variorum.sqlite")
        let backups = dir.appendingPathComponent("library/Backups", isDirectory: true)
        let key = StoreKey.mint()
        let database = try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: key))
        defer { database.asRebindable().binding.lock() }
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "word", kdf: fastKDF())
        try envelope.write(at: envelope.preferredURL(besideStore: storeURL))
        let configuration: StoreBackup.Configuration = {
            var c = StoreBackup.Configuration(keyEnvelopeStoreURL: storeURL)
            c.keep = 2
            return c
        }()
        var urls: [URL] = []
        for step in 0..<3 {
            let stamp = Date(timeIntervalSince1970: 1_800_000_000 + Double(step) * 100_000)
            let written = try await Task.detached {
                try StoreBackup.performBackupIfDue(
                    database: database, directory: backups, configuration: configuration,
                    now: stamp, force: true)
            }.value
            urls.append(try #require(written))
        }
        #expect(!FileManager.default.fileExists(atPath: urls[0].path), "the oldest snapshot pruned")
        #expect(!FileManager.default.fileExists(atPath: StoreBackup.pairedKeyFile(for: urls[0]).path),
                "…and its pair went with it")
        #expect(FileManager.default.fileExists(atPath: StoreBackup.pairedKeyFile(for: urls[2]).path))
        #expect(try StoreBackup.existingBackups(in: backups).count == 2)
    }

    /// ROW 7 — the keyless byte-copy at lock time: made AFTER the pool
    /// closed with no key in hand, it is ciphertext with no key-shaped
    /// value and no prose; its pair rides beside it; it is CHECKED at the
    /// next run with the key (copy §6's "checked the next time you
    /// unlock"); not due ⇒ nothing; a live WAL ⇒ nothing. RED ON OLD
    /// (behavioural revert: `performLockTimeCopyIfDue` returns nil): no copy.
    @Test func theLockTimeCopyIsKeylessCiphertextPairedAndCheckedAtTheNextRun() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("library/variorum.sqlite")
        let backups = dir.appendingPathComponent("library/Backups", isDirectory: true)
        let defaults = UserDefaults(suiteName: "variorum-2a-locktime-\(UUID().uuidString)")!
        let key = StoreKey.mint()
        let prose = "the variorum preserves its variant readings, keyless at lock"
        let database = try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: key))
        try await database.write { db in
            try db.execute(
                sql: "INSERT OR REPLACE INTO setting (key, value) VALUES (?, ?)",
                arguments: ["lock_probe", prose])
        }
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "word", kdf: fastKDF())
        try envelope.write(at: envelope.preferredURL(besideStore: storeURL))
        let artifactConfiguration = database.artifactConfiguration()

        // A LIVE WAL (the pool still open, frames unflushed): no copy.
        #expect(StoreBackup.performLockTimeCopyIfDue(
            storeURL: storeURL, directory: backups, interval: 60,
            defaults: defaults, now: Date()) == nil
            || (try? FileManager.default.attributesOfItem(
                atPath: storeURL.path + "-wal")[.size] as? Int) == 0,
            "a half-checkpointed library is never byte-copied")

        // THE LOCK: the pool closes, the key drops — then the copy.
        database.asRebindable().binding.lock()
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let copy = try #require(StoreBackup.performLockTimeCopyIfDue(
            storeURL: storeURL, directory: backups, interval: 60, defaults: defaults, now: now),
            "a backup is due (none exists) ⇒ the keyless copy is made")
        #expect(StoreFilePresence.classify(at: copy) == .encryptedOrUnknown, "ciphertext")
        #expect(try !fileContains(prose, at: copy), "no prose in the clear")
        #expect(try !fileContains(key.hexEncoded, at: copy), "no key-shaped value (hex)")
        #expect(try !fileContains(key.data.base64EncodedString(), at: copy), "no key-shaped value (base64)")
        #expect(try Data(contentsOf: copy).range(of: key.data) == nil, "no raw key bytes")
        #expect(FileManager.default.fileExists(atPath: StoreBackup.pairedKeyFile(for: copy).path),
                "the copy's pair rides beside it (row 42)")
        #expect(defaults.stringArray(forKey: StoreBackup.pendingLockTimeChecksKey) == [copy.lastPathComponent],
                "the copy awaits its check")

        // NOT DUE: a second lock a minute later copies nothing.
        #expect(StoreBackup.performLockTimeCopyIfDue(
            storeURL: storeURL, directory: backups, interval: 60 * 60,
            defaults: defaults, now: now.addingTimeInterval(60)) == nil)

        // THE NEXT UNLOCK: the copy is checked with the key in hand, and it
        // opens whole.
        let lines = StoreBackup.checkPendingLockTimeCopies(
            in: backups, defaults: defaults, using: artifactConfiguration)
        #expect(lines == ["lock-time copy \(copy.lastPathComponent): ok"], "\(lines)")
        #expect(defaults.stringArray(forKey: StoreBackup.pendingLockTimeChecksKey) == nil,
                "checked once — the pending list clears")
        let reopened = try DatabaseQueue(path: copy.path, configuration: artifactConfiguration)
        let read = try reopened.inDatabase { db in
            try String.fetchOne(db, sql: "SELECT value FROM setting WHERE key = 'lock_probe'")
        }
        #expect(read == prose, "the keyless copy is a whole, openable snapshot")
    }
}
