//
//  StoreEncryptionTests.swift
//  VariorumCoreTests
//
//  Phase 13p, Batch 1 (commit 2) — the keyed stack: StoreKey + custody,
//  the keyed configuration on every connection (pool writers AND readers),
//  the custody-resolving `openStore(at:)`, and THE BACKUP PIN in the spike
//  memo's corrected shape (Q5): on the pre-fix code the shipped
//  unkeyed-destination `backup(to:)` THROWS against a keyed store
//  ("backup is not supported with encrypted databases") — never "leaks
//  plaintext", the call throws first — and after the fix the same call
//  succeeds, the destination is ciphertext, a byte-scan finds no seeded
//  prose, and the file reopens with the key and reads the prose back. The
//  plaintext-store control keeps the green half non-vacuous.
//

import Dependencies
import Foundation
import GRDB
import Testing

@testable import VariorumCore

@Suite("Phase 13p — store key, custody, and the keyed stack")
struct StoreKeyTests {
    @Test func mintProducesDistinctRedacted256BitKeys() {
        let a = StoreKey.mint()
        let b = StoreKey.mint()
        #expect(a != b, "two mints must never collide")
        #expect(a.data.count == 32)
        #expect(a.hexEncoded.count == 64)
        #expect(StoreKey(hexEncoded: a.hexEncoded) == a, "hex round-trips")
        #expect(!String(describing: a).contains(a.hexEncoded),
                "a key must never ride into a log line via interpolation")
        #expect(!String(reflecting: a).contains(a.hexEncoded))
    }

    @Test func hexParsingRefusesTheMalformed() {
        #expect(StoreKey(hexEncoded: "abc") == nil)
        #expect(StoreKey(hexEncoded: String(repeating: "zz", count: 32)) == nil)
        #expect(StoreKey(data: Data(count: 31)) == nil)
        #expect(StoreKey(data: Data(count: 33)) == nil)
    }

    @Test func inMemoryCustodyRoundTrips() {
        let custody = StoreKeyCustody.inMemory()
        #expect(custody.load() == nil)
        let key = StoreKey.mint()
        #expect(custody.save(key))
        #expect(custody.load() == key)
    }
}

@Suite("Phase 13p — the keyed store")
struct KeyedStoreTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13p-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private static let canary = "MARMALADE-CANARY-13P the variorum preserves its variant readings"

    /// Seeds one container row whose title is the canary sentence — raw SQL
    /// on purpose (this is a byte-level test about the FILE, not an
    /// operations test).
    private func seedCanary(_ db: AppDatabase) throws {
        try db.write { db in
            try db.execute(sql: """
                INSERT INTO container (id, kind, title, created_at, updated_at)
                VALUES ('c-canary', 'post', ?, '2026-08-30T00:00:00.000Z',
                        '2026-08-30T00:00:00.000Z')
                """, arguments: [Self.canary])
        }
    }

    private func fileContainsCanary(_ url: URL) throws -> Bool {
        let data = try Data(contentsOf: url)
        return data.range(of: Data(Self.canary.utf8)) != nil
    }

    private func fileHasPlaintextHeader(_ url: URL) throws -> Bool {
        try Data(contentsOf: url).prefix(16) == StoreFilePresence.plaintextMagic
    }

    @Test func keyedStoreIsCiphertextOnDiskAndReopensWithTheKey() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let url = dir.appendingPathComponent("keyed.sqlite")
        let key = StoreKey.mint()

        let store = try AppDatabase.onDisk(url: url, key: key)
        try seedCanary(store)

        // The file (and its WAL — WAL pages encrypt under the same key) is
        // ciphertext: no plaintext magic, no readable prose.
        #expect(try !fileHasPlaintextHeader(url))
        #expect(try !fileContainsCanary(url))
        let wal = URL(fileURLWithPath: url.path + "-wal")
        if FileManager.default.fileExists(atPath: wal.path) {
            #expect(try !fileContainsCanary(wal), "WAL pages encrypt too")
        }

        // Reopening WITH the key reads the prose back (pool readers key via
        // the same prepareDatabase road).
        let reopened = try AppDatabase.onDisk(url: url, key: key)
        let title = try reopened.read { db in
            try String.fetchOne(db, sql: "SELECT title FROM container WHERE id = 'c-canary'")
        }
        #expect(title == Self.canary)

        // An UNKEYED open is refused — loudly, never a silent fallback.
        #expect(throws: (any Error).self) {
            _ = try AppDatabase.onDisk(url: url, key: nil)
        }
        // And a WRONG key is refused the same way.
        #expect(throws: (any Error).self) {
            _ = try AppDatabase.onDisk(url: url, key: StoreKey.mint())
        }
    }

    @Test func openStoreMintsIntoEmptyCustodyExactlyOnce() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let url = dir.appendingPathComponent("fresh.sqlite")
        let custody = StoreKeyCustody.inMemory()

        let store = try AppDatabase.openStore(at: url, custody: custody)
        let minted = try #require(custody.load(), "a fresh open mints into custody")
        try seedCanary(store)
        #expect(try !fileHasPlaintextHeader(url), "a fresh store is born encrypted")

        // A second open through the same custody REUSES the key — nothing
        // re-mints, and the store opens.
        let again = try AppDatabase.openStore(at: url, custody: custody)
        #expect(custody.load() == minted, "the held key is stable across opens")
        let title = try again.read { db in
            try String.fetchOne(db, sql: "SELECT title FROM container WHERE id = 'c-canary'")
        }
        #expect(title == Self.canary)
    }

    @Test func openStoreRefusesAnEncryptedStoreWhoseKeyIsGone() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let url = dir.appendingPathComponent("orphaned.sqlite")
        let keeper = StoreKeyCustody.inMemory()
        _ = try AppDatabase.openStore(at: url, custody: keeper)

        // The device "loses" its item: a different, empty custody.
        let empty = StoreKeyCustody.inMemory()
        #expect(throws: AppDatabase.StoreOpenError.self) {
            _ = try AppDatabase.openStore(at: url, custody: empty)
        }
        // And the refusal did NOT mint a useless key over the emptiness —
        // Batch 2's recovery roads are what re-derive one.
        #expect(empty.load() == nil)
    }

    @Test func openStoreRefusesWhenCustodyCannotKeepTheKey() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let url = dir.appendingPathComponent("unkeepable.sqlite")
        let broken = StoreKeyCustody(load: { nil }, save: { _ in false })
        #expect(throws: AppDatabase.StoreOpenError.self) {
            _ = try AppDatabase.openStore(at: url, custody: broken)
        }
        #expect(!FileManager.default.fileExists(atPath: url.path),
                "no store may be created whose key custody could not keep")
    }

    // MARK: - The unreadable-store conflation (pre-13u Act 9 — 17a P12/P13)

    /// P12/P13, RED ON OLD: a PRESENT store that cannot be opened for
    /// reading (EACCES is the plausible instance — an oddly-permissioned
    /// restore) used to classify `.absent`, indistinguishable from "no
    /// store here". Present-but-unreadable is UNKNOWN, never absence; a
    /// present-but-EMPTY file stays `.absent` (that half of the enum's
    /// doc is deliberate, pinned here so it cannot drift).
    @Test func aPresentButUnreadableStoreClassifiesAsUnknownNeverAbsent() throws {
        let dir = try temporaryDirectory()
        let url = dir.appendingPathComponent("unreadable.sqlite")
        try Data((0..<64).map { _ in UInt8.random(in: 0...255) }).write(to: url)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o000], ofItemAtPath: url.path)
        defer {
            try? FileManager.default.setAttributes(
                [.posixPermissions: 0o644], ofItemAtPath: url.path)
            try? FileManager.default.removeItem(at: dir)
        }
        #expect(StoreFilePresence.classify(at: url) == .encryptedOrUnknown,
                "present-but-unreadable is UNKNOWN — .absent authorized a persisted mode downgrade and a bogus key mint")

        let empty = dir.appendingPathComponent("empty.sqlite")
        FileManager.default.createFile(atPath: empty.path, contents: Data())
        #expect(StoreFilePresence.classify(at: empty) == .absent,
                "the empty-file-as-absent half is deliberate and unchanged")
    }

    /// P12/P13's sharp edge, RED ON OLD: the never-mint-over-ciphertext
    /// refusal must fire for an unreadable store too. The old road minted
    /// a fresh key, PERSISTED it into custody, and then failed the open
    /// with an untyped error — so `failedOutcome` could never build the
    /// sidecar recovery road, and every later launch repeated the doorless
    /// failure even after the I/O condition cleared (custody now held the
    /// bogus key).
    @Test func openStoreNeverMintsOverAPresentButUnreadableStore() throws {
        let dir = try temporaryDirectory()
        let url = dir.appendingPathComponent("unreadable.sqlite")
        try Data((0..<64).map { _ in UInt8.random(in: 0...255) }).write(to: url)
        try FileManager.default.setAttributes(
            [.posixPermissions: 0o000], ofItemAtPath: url.path)
        defer {
            try? FileManager.default.setAttributes(
                [.posixPermissions: 0o644], ofItemAtPath: url.path)
            try? FileManager.default.removeItem(at: dir)
        }
        let custody = StoreKeyCustody.inMemory()
        do {
            _ = try AppDatabase.openStore(at: url, custody: custody)
            Issue.record("an unreadable store must refuse the open")
        } catch let error as AppDatabase.StoreOpenError {
            #expect(error.keyUnavailable,
                    "the refusal is TYPED — the recovery road keys off exactly this")
        }
        #expect(custody.load() == nil,
                "and NOTHING was minted into custody — a persisted bogus key made the dead end permanent")
    }

    // MARK: - VX-80: the wrong-key class is TYPED (the Castle-follow crash window)

    /// VX-80 (the record: notes/plans/fixes/vx-80-castle-follow-recovery-
    /// door.md): an encrypted store whose custody-held key does not open it
    /// — the stranded state a death between the follow's verified swap and
    /// its custody move leaves behind — throws the TYPED `keyRejected`
    /// refusal, so the failure surface keys its recovery lobby on the fact,
    /// never on the reason's prose (R1-M3's own precedent). The class
    /// separation from `keyUnavailable` is pinned on both sides, and the
    /// classification never touches the file: the right key still opens it.
    @Test func openStoreTypesAWrongKeyOpenAsKeyRejected() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let url = dir.appendingPathComponent("stranded.sqlite")
        let keyB = StoreKey.mint()  // the file is under it — the re-key completed
        do {
            let seeded = try AppDatabase.onDisk(url: url, key: keyB)
            try seedCanary(seeded)
        }
        // Custody still holds the OLD key A — the crash fell before step 5
        // (the custody move).
        let keyA = StoreKey.mint()
        do {
            _ = try AppDatabase.openStore(at: url, custody: .inMemory(initial: keyA))
            Issue.record("a wrong-key open must refuse")
        } catch let error as AppDatabase.StoreOpenError {
            #expect(error.keyRejected, "the wrong-key class is TYPED (VX-80)")
            #expect(!error.keyUnavailable, "…and is NOT R1-M3's empty-custody class")
            #expect(!error.reason.contains(keyA.hexEncoded)
                    && !error.reason.contains(keyB.hexEncoded),
                    "no key material rides the reason (the P15 rule holds)")
        }
        // The right key opens the same file whole.
        let reopened = try AppDatabase.openStore(at: url, custody: .inMemory(initial: keyB))
        let title = try reopened.read { db in
            try String.fetchOne(db, sql: "SELECT title FROM container WHERE id = 'c-canary'")
        }
        #expect(title == Self.canary)
    }

    /// VX-80's class separation, the other side: the empty-custody refusal
    /// keeps its exact 13p shape — `keyUnavailable` true, `keyRejected`
    /// false. The two typed facts never conflate (each keys the same
    /// recovery lobby, but the distinction is load-bearing for the words
    /// each surface speaks and for every future consumer).
    @Test func theEmptyCustodyRefusalIsNotTheWrongKeyClass() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let url = dir.appendingPathComponent("orphaned.sqlite")
        _ = try AppDatabase.openStore(at: url, custody: .inMemory())  // mints + creates
        do {
            _ = try AppDatabase.openStore(at: url, custody: .inMemory())  // empty custody
            Issue.record("an encrypted store with empty custody must refuse")
        } catch let error as AppDatabase.StoreOpenError {
            #expect(error.keyUnavailable)
            #expect(!error.keyRejected, "the two typed classes never conflate")
        }
    }
}

@Suite("Phase 13p — the backup pin (spike Q5's corrected shape)")
struct KeyedBackupTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13p-bk-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private static let canary = "MARMALADE-CANARY-13P the variorum preserves its variant readings"

    private func seedCanary(_ db: AppDatabase) throws {
        try db.write { db in
            try db.execute(sql: """
                INSERT INTO container (id, kind, title, created_at, updated_at)
                VALUES ('c-canary', 'post', ?, '2026-08-30T00:00:00.000Z',
                        '2026-08-30T00:00:00.000Z')
                """, arguments: [Self.canary])
        }
    }

    /// THE PIN. RED on pre-fix code: the shipped unkeyed-destination path
    /// throws `SQLite error 1: backup is not supported with encrypted
    /// databases` the moment the source is keyed — so 13l's scheduled
    /// backups, second destination, freshness face, and restore drill all
    /// break at the first post-migration run. GREEN after: the destination
    /// is opened with the SAME key, the call succeeds, and the artifact is
    /// ciphertext that ROUND-TRIPS.
    @Test func backupOfAKeyedStoreSucceedsAsCiphertextAndRoundTrips() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let url = dir.appendingPathComponent("keyed.sqlite")
        let key = StoreKey.mint()
        let store = try AppDatabase.onDisk(url: url, key: key)
        try seedCanary(store)

        let destination = dir.appendingPathComponent("backup.sqlite")
        try store.backup(to: destination)  // pre-fix: THROWS here

        let bytes = try Data(contentsOf: destination)
        #expect(bytes.prefix(16) != StoreFilePresence.plaintextMagic,
                "a keyed store's backup is ciphertext")
        #expect(bytes.range(of: Data(Self.canary.utf8)) == nil,
                "no seeded prose is readable in the backup file")

        // Ciphertext that cannot be reopened is worthless: the artifact
        // reopens with the store's own key and reads the prose back.
        let reopened = try DatabaseQueue(
            path: destination.path, configuration: store.artifactConfiguration())
        let title = try reopened.read { db in
            try String.fetchOne(db, sql: "SELECT title FROM container WHERE id = 'c-canary'")
        }
        #expect(title == Self.canary)
    }

    /// The CONTROL that keeps the green half non-vacuous: a PLAINTEXT
    /// store's backup does contain readable prose — so the no-canary
    /// assertion above cannot pass on an empty or broken artifact.
    @Test func backupOfAPlaintextStoreStillContainsReadableProse() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let url = dir.appendingPathComponent("plain.sqlite")
        let store = try AppDatabase.onDisk(url: url, key: nil)
        try seedCanary(store)

        let destination = dir.appendingPathComponent("backup.sqlite")
        try store.backup(to: destination)

        let bytes = try Data(contentsOf: destination)
        #expect(bytes.prefix(16) == StoreFilePresence.plaintextMagic)
        #expect(bytes.range(of: Data(Self.canary.utf8)) != nil,
                "the plaintext control: prose IS readable in a plaintext backup")
    }
}
