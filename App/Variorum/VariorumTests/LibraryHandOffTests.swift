//
//  LibraryHandOffTests.swift
//  VariorumTests
//
//  Phase 13x U1 row 2 — the hand-off producer's pins: the THROWAWAY
//  round-trip (produce → classify back → the pair's key file unwraps to
//  the same key → the snapshot opens under it and reads a pre-snapshot
//  row), the refusals, the same-day collision rule, and THE DEV-STORE
//  DRILL (the U1 evidence line: the folder produced on the real dev
//  store and opened back by the classifier — reads only, in-memory
//  custody, the stage held around the run).
//

import Foundation
import GRDB
import Testing

@testable import Variorum
import VariorumCore

@Suite("13x U1 — the hand-off folder pair")
struct LibraryHandOffTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13x-handoff-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    /// THE ROUND TRIP (the row's pin): a keyed throwaway with a marked row
    /// → the folder pair → the classifier reads it back → the key file
    /// opens the snapshot and the marked row is inside.
    @Test func theHandOffFolderRoundTripsThroughTheClassifierAndItsOwnKeyFile() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("library/variorum.sqlite")
        let key = StoreKey.mint()
        let database = try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: key))
        defer { _ = database.asRebindable().binding.lock() }
        // A row the snapshot must carry.
        try await database.write { db in
            try db.execute(
                sql: """
                    INSERT INTO container (id, kind, title, created_at, updated_at)
                    VALUES ('13x-handoff-marker', 'post', 'the travelling row', '2027-01-01T00:00:00Z', '2027-01-01T00:00:00Z')
                    """)
        }
        // The live key file, passphrase-wrapped.
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "the airdrop word", kdf: fastKDF())
        try envelope.write(at: envelope.preferredURL(besideStore: storeURL))

        let parent = dir.appendingPathComponent("Desktop", isDirectory: true)
        try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let product = try await Task.detached {
            try LibraryHandOff.produce(
                from: database, storeURL: storeURL, into: parent, now: now)
        }.value

        // The folder: the ruled name, exactly the pair inside, sealed.
        #expect(product.folder.lastPathComponent == LibraryHandOff.folderName(on: now))
        #expect(product.integrity == "ok")
        let contents = try FileManager.default.contentsOfDirectory(
            at: product.folder, includingPropertiesForKeys: nil)
            .map(\.lastPathComponent).sorted()
        #expect(contents == [
            product.keyFile.lastPathComponent, "variorum.sqlite",
        ].sorted(), "exactly the pair — no sidecars, nothing else")
        #expect(product.keyFile.lastPathComponent
            == StoreKeyEnvelope.filename(forFingerprint: StoreKeyEnvelope.fingerprint(of: key)))

        // The classifier reads it back: the folder, and the bare file.
        #expect(LibraryClassifier.classify(at: product.folder)
            == .folderHoldingPair(store: product.snapshot, keyFile: product.keyFile))
        #expect(LibraryClassifier.classify(at: product.snapshot)
            == .encryptedLibrary(store: product.snapshot, keyFile: product.keyFile))

        // The pair's own key file opens the snapshot — corner 33 made true.
        let travelled = try #require(try StoreKeyEnvelope.load(at: product.keyFile))
        let unwrapped = try travelled.unwrapKey(passphrase: "the airdrop word")
        #expect(unwrapped == key)
        let reopened = try AppDatabase.onDisk(url: product.snapshot, key: unwrapped)
        defer { _ = reopened.asRebindable().binding.lock() }
        let title = try await reopened.read { db in
            try String.fetchOne(
                db, sql: "SELECT title FROM container WHERE id = '13x-handoff-marker'")
        }
        #expect(title == "the travelling row")

        // The SOURCE pair was only ever read: the live library still opens.
        let stillThere = try await database.read { db in
            try String.fetchOne(
                db, sql: "SELECT title FROM container WHERE id = '13x-handoff-marker'")
        }
        #expect(stillThere == "the travelling row")
    }

    /// REFUSAL: no key file beside the library ⇒ no folder is produced at
    /// all (a pair without its key file opens nothing — the act must not
    /// mint a dead hand-off).
    @Test func aLibraryWithoutItsKeyFileRefusesAndLeavesNothingBehind() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("library/variorum.sqlite")
        let key = StoreKey.mint()
        let database = try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: key))
        defer { _ = database.asRebindable().binding.lock() }
        let parent = dir.appendingPathComponent("Desktop", isDirectory: true)
        try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)
        await #expect(throws: LibraryHandOff.HandOffError.noKeyFile(
            storeFolder: storeURL.deletingLastPathComponent().path)) {
            _ = try await Task.detached {
                try LibraryHandOff.produce(
                    from: database, storeURL: storeURL, into: parent, now: Date())
            }.value
        }
        #expect(try FileManager.default.contentsOfDirectory(
            at: parent, includingPropertiesForKeys: nil).isEmpty,
            "nothing half-made is left behind")
    }

    /// Same-day repeats step aside: " (2)", " (3)" (PROVISIONAL P-U1-4).
    @Test func sameDayHandOffsNeverOverwriteEachOther() async throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("library/variorum.sqlite")
        let key = StoreKey.mint()
        let database = try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: key))
        defer { _ = database.asRebindable().binding.lock() }
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: "the airdrop word", kdf: fastKDF())
        try envelope.write(at: envelope.preferredURL(besideStore: storeURL))
        let parent = dir.appendingPathComponent("Desktop", isDirectory: true)
        try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        let first = try await Task.detached {
            try LibraryHandOff.produce(from: database, storeURL: storeURL, into: parent, now: now)
        }.value
        let second = try await Task.detached {
            try LibraryHandOff.produce(from: database, storeURL: storeURL, into: parent, now: now)
        }.value
        #expect(first.folder.lastPathComponent == LibraryHandOff.folderName(on: now))
        #expect(second.folder.lastPathComponent == LibraryHandOff.folderName(on: now) + " (2)")
        #expect(FileManager.default.fileExists(atPath: first.snapshot.path))
        #expect(FileManager.default.fileExists(atPath: second.snapshot.path))
    }

    // MARK: - THE DEV-STORE DRILL (the U1 evidence line; the stage held
    // around the suite run)

    /// Produce the hand-off folder FROM THE REAL DEV STORE and open it
    /// back with the classifier. READS ONLY: the dev key is read from this
    /// host's own custody item (the test host IS the dev-store app), the
    /// open rides in-memory custody, the snapshot is the backup API's
    /// read, and the produced folder lives in a temp dir, removed at the
    /// end. The dev store itself is never written.
    @Test(.enabled(if: devStoreExists))
    func theHandOffFolderRoundTripsOnTheDevStore() async throws {
        let devURL = try AppDatabase.defaultStoreURL(variant: .dev)
        let scope = AppDatabase.StoreVariant.dev.rawValue
        let custody = StoreKeyCustody.deviceKeychain(scope: scope, storeURL: devURL)
        let key = try #require(
            custody.load(),
            "this host holds no dev-store key — the drill needs the dev-store app's own custody")
        let database = try AppDatabase.openStore(
            at: devURL, custody: .inMemory(initial: key))
        defer { _ = database.asRebindable().binding.lock() }

        let parent = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: parent) }
        let product = try await Task.detached {
            try LibraryHandOff.produce(
                from: database, storeURL: devURL, into: parent, now: Date())
        }.value
        #expect(product.integrity == "ok")
        #expect(LibraryClassifier.classify(at: product.folder)
            == .folderHoldingPair(store: product.snapshot, keyFile: product.keyFile))
        // The travelling key file is the DEV library's own.
        let travelled = try #require(try StoreKeyEnvelope.load(at: product.keyFile))
        #expect(travelled.keyFingerprint == StoreKeyEnvelope.fingerprint(of: key))
    }

    private static var devStoreExists: Bool {
        guard let url = try? AppDatabase.defaultStoreURL(variant: .dev) else { return false }
        return StoreFilePresence.classify(at: url) == .encryptedOrUnknown
    }
}
