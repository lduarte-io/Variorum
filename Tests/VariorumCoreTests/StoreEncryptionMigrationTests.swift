//
//  StoreEncryptionMigrationTests.swift
//  VariorumCoreTests
//
//  Phase 13p, Batch 1 (commit 3) — the one-time plaintext→encrypted
//  migration: the export/verify/atomic-swap road, its idempotence, its
//  refusal roads, and the CRASH-SAFETY MATRIX — a simulated death at every
//  step boundary, after which the next launch must land in either the old
//  plaintext store or the verified new one, never neither (the 14c
//  re-run-guard discipline). The REAL kill-mid-road drills (SIGKILL, a
//  copy of the author's real store) run in the scratch harness outside the
//  repo; these tests pin the same boundaries with a thrown abort, which is
//  the gentler sibling (an unwound throw still closes connections; the
//  harness's SIGKILL does not — both are recorded in the batch record).
//

import Foundation
import GRDB
import Testing

@testable import VariorumCore

@Suite("Phase 13p — the one-time store encryption migration")
struct StoreEncryptionMigrationTests {
    private static let canary = "MARMALADE-CANARY-13P the variorum preserves its variant readings"

    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13p-mig-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// A real plaintext store (full schema via the migrator) carrying the
    /// canary sentence in a container title and a variant body — prose in
    /// two different tables, so the byte-scan is not about one lucky page.
    private func makePlaintextStore(at url: URL) throws {
        let store = try AppDatabase.onDisk(url: url, key: nil)
        try store.write { db in
            try db.execute(sql: """
                INSERT INTO container (id, kind, title, created_at, updated_at)
                VALUES ('c-canary', 'post', ?, '2026-08-30T00:00:00.000Z',
                        '2026-08-30T00:00:00.000Z')
                """, arguments: [Self.canary])
            try db.execute(sql: """
                INSERT INTO block (id, created_at, updated_at)
                VALUES ('b-canary', '2026-08-30T00:00:00.000Z', '2026-08-30T00:00:00.000Z')
                """)
            try db.execute(sql: """
                INSERT INTO variant (id, block_id, working_text, fan_position,
                                     created_at, updated_at)
                VALUES ('v-canary', 'b-canary', ?, 'a0',
                        '2026-08-30T00:00:00.000Z', '2026-08-30T00:00:00.000Z')
                """, arguments: ["prose body: " + Self.canary])
        }
        // (The store closes when `store` deinits at scope exit; the file may
        // keep a live WAL — exactly the shape a real pre-13p store has.)
    }

    private func scanIsClean(_ url: URL) throws -> Bool {
        let data = try Data(contentsOf: url)
        return data.prefix(16) != StoreFilePresence.plaintextMagic
            && data.range(of: Data(Self.canary.utf8)) == nil
            && data.range(of: Data("CREATE TABLE".utf8)) == nil
    }

    private func readBack(_ url: URL, key: StoreKey) throws -> (title: String?, body: String?) {
        let store = try AppDatabase.onDisk(url: url, key: key)
        return try store.read { db in
            (try String.fetchOne(db, sql: "SELECT title FROM container WHERE id = 'c-canary'"),
             try String.fetchOne(db, sql: "SELECT working_text FROM variant WHERE id = 'v-canary'"))
        }
    }

    // MARK: - The road itself

    @Test func migrationEncryptsInPlaceAndTheContentSurvivesWhole() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let url = dir.appendingPathComponent("store.sqlite")
        try makePlaintextStore(at: url)
        let key = StoreKey.mint()

        let migrated = try StoreEncryptionMigration.migrateIfNeeded(at: url, key: key)
        #expect(migrated, "a plaintext store migrates")

        // THE BATCH'S ACCEPTANCE PIN: a zero-plaintext byte-scan of the
        // migrated store file — no SQLite magic, no prose, not even the
        // schema's own DDL text.
        #expect(try scanIsClean(url), "the migrated file is ciphertext end to end")
        // The old sidecars are gone (a stale plaintext -wal beside a
        // ciphertext store is the one replay hazard).
        #expect(!FileManager.default.fileExists(atPath: url.path + "-wal"))
        #expect(!FileManager.default.fileExists(atPath: url.path + "-shm"))
        // No temp leavings.
        #expect(!FileManager.default.fileExists(atPath: url.path + ".encrypting"))

        // And the content is WHOLE.
        let read = try readBack(url, key: key)
        #expect(read.title == Self.canary)
        #expect(read.body == "prose body: " + Self.canary)
    }

    @Test func migrationIsIdempotentAndLeavesFreshOrEncryptedStoresAlone() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let url = dir.appendingPathComponent("store.sqlite")
        let key = StoreKey.mint()

        // Absent file: nothing to do.
        #expect(try StoreEncryptionMigration.migrateIfNeeded(at: url, key: key) == false)

        try makePlaintextStore(at: url)
        #expect(try StoreEncryptionMigration.migrateIfNeeded(at: url, key: key))
        // Already encrypted: the second run is a no-op, not a re-encrypt.
        let before = try Data(contentsOf: url)
        #expect(try StoreEncryptionMigration.migrateIfNeeded(at: url, key: key) == false)
        #expect(try Data(contentsOf: url) == before, "a no-op run rewrites nothing")
    }

    @Test func aFailedVerificationLeavesTheOriginalUntouchedAndRerunnable() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let url = dir.appendingPathComponent("store.sqlite")
        try makePlaintextStore(at: url)
        let key = StoreKey.mint()
        let temp = URL(fileURLWithPath: url.path + ".encrypting")

        // Corrupt the exported temp at the .exported boundary — the
        // verification must refuse the swap and the original must survive.
        #expect(throws: StoreEncryptionMigration.MigrationError.self) {
            try StoreEncryptionMigration.migrateIfNeeded(at: url, key: key) { step in
                if step == .exported {
                    try Data("garbage".utf8).write(to: temp)
                }
            }
        }
        #expect(StoreFilePresence.classify(at: url) == .plaintext,
                "the original is untouched by a failed verification")

        // The re-run starts clean and completes.
        #expect(try StoreEncryptionMigration.migrateIfNeeded(at: url, key: key))
        let read = try readBack(url, key: key)
        #expect(read.title == Self.canary)
    }

    // MARK: - The crash matrix (a death at every boundary, then relaunch)

    @Test(arguments: StoreEncryptionMigration.Step.allCases)
    func aCrashAtEveryBoundaryRelaunchesIntoAWholeStore(
        step: StoreEncryptionMigration.Step
    ) throws {
        struct SimulatedCrash: Error {}
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let url = dir.appendingPathComponent("store.sqlite")
        try makePlaintextStore(at: url)
        let key = StoreKey.mint()

        // The crash.
        #expect(throws: SimulatedCrash.self) {
            try StoreEncryptionMigration.migrateIfNeeded(at: url, key: key) { reached in
                if reached == step { throw SimulatedCrash() }
            }
        }

        // The 14c discipline's invariant: the store path holds either the
        // old plaintext file (re-migratable) or the verified new one —
        // never neither, never garbage.
        let presence = StoreFilePresence.classify(at: url)
        #expect(presence != .absent, "the store path never holds nothing")

        // The relaunch: the same custody-resolved road the app takes.
        let custody = StoreKeyCustody.inMemory(initial: key)
        let reopened = try AppDatabase.openStore(at: url, custody: custody)
        let title = try reopened.read { db in
            try String.fetchOne(db, sql: "SELECT title FROM container WHERE id = 'c-canary'")
        }
        #expect(title == Self.canary, "content survives a crash at \(step.rawValue)")
        // And the relaunch finished the job: the store is encrypted now.
        #expect(try scanIsClean(url), "post-relaunch the file is ciphertext")
    }

    // MARK: - The open path composes the migration

    @Test func openStoreMigratesAnExistingPlaintextStoreAutomatically() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let url = dir.appendingPathComponent("store.sqlite")
        try makePlaintextStore(at: url)

        let custody = StoreKeyCustody.inMemory()
        let store = try AppDatabase.openStore(at: url, custody: custody)
        #expect(custody.load() != nil, "the migration minted this store's key")
        #expect(try scanIsClean(url), "openStore leaves no plaintext store behind")
        let title = try store.read { db in
            try String.fetchOne(db, sql: "SELECT title FROM container WHERE id = 'c-canary'")
        }
        #expect(title == Self.canary)
    }
}
