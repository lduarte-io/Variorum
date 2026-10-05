// BRANCH-ONLY tests (`tools/strings-workbook`; never merges). Scratch stores in
// a temp folder only; custody in memory only — never the Keychain.

import Foundation
import GRDB
import Testing
@testable import StringsWorkbook
import VariorumCore

@Suite("StringsWorkbook — the headless unlock road (the lobby's typed-secret road)", .serialized)
struct StoreUnlockTests {
    static let passphrase = "correct horse battery staple — scratch only"

    @Test func aMissingPathRefusesAndCreatesNothing() throws {
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("strings-workbook-missing-\(UUID().uuidString)")
        let url = folder.appendingPathComponent("variorum.sqlite")
        #expect(throws: StoreUnlock.UnlockError.storeMissing(url.path)) {
            try StoreUnlock.requireExistingEncryptedStore(at: url)
        }
        #expect(throws: StoreUnlock.UnlockError.storeMissing(url.path)) {
            _ = try StoreUnlock.probe(storeAt: url, key: StoreKey.mint())
        }
        #expect(throws: StoreUnlock.UnlockError.storeMissing(url.path)) {
            _ = try StoreUnlock.open(storeAt: url, key: StoreKey.mint())
        }
        #expect(!FileManager.default.fileExists(atPath: folder.path))
    }

    @Test func aPlaintextStoreRefuses() throws {
        let folder = FileManager.default.temporaryDirectory
            .appendingPathComponent("strings-workbook-plain-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let url = folder.appendingPathComponent("variorum.sqlite")
        try DatabaseQueue(path: url.path).write { try $0.execute(sql: "CREATE TABLE t (x)") }
        #expect(throws: StoreUnlock.UnlockError.notEncrypted(url.path)) {
            try StoreUnlock.requireExistingEncryptedStore(at: url)
        }
    }

    @Test func theRoadsAreReadWithoutASecret() throws {
        let bare = try ScratchLibrary.make()
        defer { bare.remove() }
        let none = try StoreUnlock.localRoads(besideStore: bare.storeURL)
        #expect(!none.passphrase && !none.recoveryWords)
        #expect(throws: StoreUnlock.UnlockError.noPassphraseRoad) {
            _ = try StoreUnlock.key(besideStore: bare.storeURL, passphrase: "anything")
        }

        let words = try RecoveryPhrase.generate()
        let both = try ScratchLibrary.make(passphrase: Self.passphrase, words: words)
        defer { both.remove() }
        let roads = try StoreUnlock.localRoads(besideStore: both.storeURL)
        #expect(roads.passphrase && roads.recoveryWords)
        #expect(roads.keyFile.lastPathComponent.hasPrefix("variorum-keys-"))

        // A store with no key file beside it at all.
        try FileManager.default.removeItem(at: roads.keyFile)
        #expect(throws: StoreUnlock.UnlockError.self) {
            _ = try StoreUnlock.localRoads(besideStore: both.storeURL)
        }
    }

    @Test func thePassphraseAndTheWordsUnwrapTheStoreKeyAndAWrongSecretRefuses() throws {
        let words = try RecoveryPhrase.generate()
        let library = try ScratchLibrary.make(passphrase: Self.passphrase, words: words)
        defer { library.remove() }
        #expect(try StoreUnlock.key(besideStore: library.storeURL, passphrase: Self.passphrase) == library.key)
        #expect(try StoreUnlock.key(
            besideStore: library.storeURL, recoveryText: "  " + words.joined(separator: "\n ").uppercased())
                == library.key)
        #expect(throws: StoreUnlock.UnlockError.wrongPassphrase) {
            _ = try StoreUnlock.key(besideStore: library.storeURL, passphrase: Self.passphrase + "!")
        }
        let otherWords = try RecoveryPhrase.generate()
        #expect(throws: StoreUnlock.UnlockError.self) {
            _ = try StoreUnlock.key(besideStore: library.storeURL, recoveryText: otherWords.joined(separator: " "))
        }
    }

    @Test func theProbeReadsSchemaAndGuardWithoutWritingAndAWrongKeyFailsThere() throws {
        let library = try ScratchLibrary.make(passphrase: Self.passphrase) { ops in
            _ = try ops.createReading(name: "Existing book", kind: .book)
            _ = try ops.createPost(title: "a note")
        }
        defer { library.remove() }
        let probe = try StoreUnlock.probe(storeAt: library.storeURL, key: library.key)
        #expect(probe.migrations.contains("v1_21_reading_archive"))
        #expect(probe.existingWorkbook == nil)
        #expect(probe.books == 1)
        #expect(probe.notes == 1)

        // A wrong key cannot read the store — refused at the probe, before
        // any connection that could write exists.
        #expect(throws: (any Error).self) {
            _ = try StoreUnlock.probe(storeAt: library.storeURL, key: StoreKey.mint())
        }
    }

    @Test func theProbeRefusesAStoreWhoseSchemaIsNotThisBuilds() throws {
        let library = try ScratchLibrary.make()
        defer { library.remove() }
        // Simulate a store written by a NEWER build: one migration this
        // build does not know (a raw write — to a scratch store, in a test).
        let (database, binding) = try StoreUnlock.open(storeAt: library.storeURL, key: library.key)
        try database.write { try $0.execute(sql: "INSERT INTO grdb_migrations (identifier) VALUES ('v9_future')") }
        _ = binding.lock()
        #expect(throws: StoreUnlock.UnlockError.schemaDiffers(missingInStore: [], unknownToTool: ["v9_future"])) {
            _ = try StoreUnlock.probe(storeAt: library.storeURL, key: library.key)
        }
    }

    @Test func theWholeRoadOnAnOnDiskEncryptedStoreMintsVerifiesClosesAndReopens() throws {
        let library = try ScratchLibrary.make(passphrase: Self.passphrase) { ops in
            _ = try ops.createReading(name: "Her novel", kind: .book)
        }
        defer { library.remove() }

        // The CLI's order: roads → unwrap → probe → open → mint → verify → close.
        let key = try StoreUnlock.key(besideStore: library.storeURL, passphrase: Self.passphrase)
        let before = try StoreUnlock.probe(storeAt: library.storeURL, key: key)
        #expect(before.existingWorkbook == nil)
        let (database, binding) = try StoreUnlock.open(storeAt: library.storeURL, key: key)
        let report = try WorkbookMint.mint(RealDocs.plan, into: database)
        try WorkbookMint.verify(RealDocs.plan, readingID: report.readingID, in: database)
        let close = binding.lock()
        #expect(close.closedCleanly)

        // Still encrypted on disk; reopens under the same key and reads back.
        #expect(StoreFilePresence.classify(at: library.storeURL) == .encryptedOrUnknown)
        let after = try StoreUnlock.probe(storeAt: library.storeURL, key: key)
        #expect(after.existingWorkbook == "App Strings")
        #expect(after.books == 2)
        #expect(after.notes == 37)
        let (reopened, rebinding) = try StoreUnlock.open(storeAt: library.storeURL, key: key)
        defer { _ = rebinding.lock() }
        try WorkbookMint.verify(RealDocs.plan, readingID: report.readingID, in: reopened)
        // Her existing book is untouched.
        #expect(try reopened.read {
            try String.fetchAll($0, sql: "SELECT name FROM reading WHERE deleted_at IS NULL ORDER BY name")
        } == ["App Strings", "Her novel"])
    }
}
