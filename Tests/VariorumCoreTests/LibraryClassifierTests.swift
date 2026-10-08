import Foundation
import GRDB
import Testing

@testable import VariorumCore

// Phase 13x U1 row 1 — THE VERDICT TABLE, pinned: one pin per verdict row
// (the plan's "exact tests per verdict"), each over a REAL fixture of its
// shape — real keyed stores, real key files, the production export — never
// a mocked byte. The refusal-guarding verdicts' red-first evidence is the
// behavioural revert quoted in the U1 RECORD.

@Suite("13x U1 — the picked-thing classifier's verdict table")
struct LibraryClassifierTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13x-classifier-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    /// An encrypted library at `<dir>/library/variorum.sqlite` with a
    /// passphrase-wrapped key file beside it — the hand-off shape.
    private func makeEncryptedLibrary(
        in dir: URL, passphrase: String = "the drill word"
    ) throws -> (store: URL, key: StoreKey, keyFile: URL) {
        let store = dir.appendingPathComponent("library/variorum.sqlite")
        let key = StoreKey.mint()
        let database = try AppDatabase.openStore(at: store, custody: .inMemory(initial: key))
        _ = database.asRebindable().binding.lock()
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: passphrase, kdf: fastKDF())
        let keyFile = envelope.preferredURL(besideStore: store)
        try envelope.write(at: keyFile)
        return (store, key, keyFile)
    }

    // MARK: - Row: encrypted library with key file beside

    @Test func anEncryptedStoreWithItsKeyFileBesideClassifiesAsALibrary() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        #expect(LibraryClassifier.classify(at: fixture.store)
            == .encryptedLibrary(store: fixture.store, keyFile: fixture.keyFile))
    }

    // MARK: - Row: snapshot pairs (backup-named; the three key-file roads)

    @Test func aSnapshotWithItsOwnPairKeyFileClassifiesAsAPair() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        let fp8 = StoreKeyEnvelope.shortFingerprint(
            StoreKeyEnvelope.fingerprint(of: fixture.key))
        let folder = dir.appendingPathComponent("Backups", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let snapshot = folder.appendingPathComponent(
            "variorum-backup-2027-01-02-030405-\(fp8).sqlite")
        try FileManager.default.copyItem(at: fixture.store, to: snapshot)
        let pair = LibraryClassifier.pairedKeyFile(for: snapshot)
        try FileManager.default.copyItem(at: fixture.keyFile, to: pair)
        #expect(pair.lastPathComponent == "variorum-backup-2027-01-02-030405-\(fp8).keys.json")
        #expect(LibraryClassifier.classify(at: snapshot)
            == .snapshotPair(store: snapshot, keyFile: pair))
    }

    @Test func aPairlessSnapshotIsServedByTheFoldersMatchingFingerprintFile() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        let fingerprint = StoreKeyEnvelope.fingerprint(of: fixture.key)
        let fp8 = StoreKeyEnvelope.shortFingerprint(fingerprint)
        let folder = dir.appendingPathComponent("Backups", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let snapshot = folder.appendingPathComponent(
            "variorum-backup-2027-01-02-030405-\(fp8).sqlite")
        try FileManager.default.copyItem(at: fixture.store, to: snapshot)
        // The 1a-era folder file, under the key's own fingerprint name.
        let folderFile = StoreKeyEnvelope.url(besideStore: snapshot, fingerprint: fingerprint)
        try FileManager.default.copyItem(at: fixture.keyFile, to: folderFile)
        #expect(LibraryClassifier.classify(at: snapshot)
            == .snapshotPair(store: snapshot, keyFile: folderFile))
    }

    @Test func aLegacyStampOnlySnapshotIsServedByTheLegacyFolderFile() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        let folder = dir.appendingPathComponent("Backups", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let snapshot = folder.appendingPathComponent("variorum-backup-2027-01-02-030405.sqlite")
        try FileManager.default.copyItem(at: fixture.store, to: snapshot)
        let legacy = StoreKeyEnvelope.legacyURL(besideStore: snapshot)
        try FileManager.default.copyItem(at: fixture.keyFile, to: legacy)
        #expect(LibraryClassifier.classify(at: snapshot)
            == .snapshotPair(store: snapshot, keyFile: legacy))
    }

    /// REFUSAL: a key file of a DIFFERENT key never serves a snapshot
    /// whose name says which key it needs (the which-opens-which honesty).
    @Test func aSnapshotWhoseNamedKeyIsNowhereRefusesAsBare() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        let folder = dir.appendingPathComponent("Backups", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        // A name claiming a key no file in the folder carries.
        let snapshot = folder.appendingPathComponent(
            "variorum-backup-2027-01-02-030405-0000ffff.sqlite")
        try FileManager.default.copyItem(at: fixture.store, to: snapshot)
        let foreign = StoreKeyEnvelope.url(
            besideStore: snapshot,
            fingerprint: StoreKeyEnvelope.fingerprint(of: fixture.key))
        try FileManager.default.copyItem(at: fixture.keyFile, to: foreign)
        #expect(LibraryClassifier.classify(at: snapshot)
            == .bareStoreWithoutKeyFile(store: snapshot))
    }

    // MARK: - Rows: the picked folder

    @Test func aFolderHoldingOnePairClassifiesAsTheFolderVerdict() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        let folder = fixture.store.deletingLastPathComponent()
        #expect(LibraryClassifier.classify(at: folder)
            == .folderHoldingPair(store: fixture.store, keyFile: fixture.keyFile))
    }

    @Test func aFolderHoldingSeveralStoresReportsThemAndNeverGuesses() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        let folder = fixture.store.deletingLastPathComponent()
        let second = folder.appendingPathComponent("another.sqlite")
        try FileManager.default.copyItem(at: fixture.store, to: second)
        #expect(LibraryClassifier.classify(at: folder)
            == .folderHoldingStores([second, fixture.store]))
    }

    @Test func aFolderHoldingNoStoreIsNotALibrary() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        #expect(LibraryClassifier.classify(at: dir) == .notAVariorumStore(dir))
    }

    // MARK: - Row: the plaintext export (§14.13's subject)

    @Test func theProductionPlaintextExportClassifiesAsAnExport() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        let key = fixture.key
        let database = try AppDatabase.openStore(
            at: fixture.store, custody: .inMemory(initial: key))
        defer { _ = database.asRebindable().binding.lock() }
        let export = dir.appendingPathComponent("export/decrypted.sqlite")
        try StorePlaintextExport.export(from: database, to: export)
        #expect(LibraryClassifier.classify(at: export) == .plaintextExport(store: export))
    }

    // MARK: - Row (PROVISIONAL P-U1-1): a plaintext FULL library

    @Test func aPlaintextStoreCarryingLocalTablesIsAFullLibraryNeverAnExport() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let store = dir.appendingPathComponent("old/variorum.sqlite")
        try FileManager.default.createDirectory(
            at: store.deletingLastPathComponent(), withIntermediateDirectories: true)
        let database = try AppDatabase.onDisk(url: store, key: nil)
        _ = database.asRebindable().binding.lock()
        #expect(LibraryClassifier.classify(at: store) == .plaintextLibrary(store: store))
    }

    // MARK: - Row: bare store, no key file (corner 33's refusal)

    @Test func anEncryptedStoreWithNoKeyFileAnywhereRefusesAsBare() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        try FileManager.default.removeItem(at: fixture.keyFile)
        #expect(LibraryClassifier.classify(at: fixture.store)
            == .bareStoreWithoutKeyFile(store: fixture.store))
    }

    @Test func anOpaqueNonDatabaseFileWithNoKeyFileRefusesAsBare() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let file = dir.appendingPathComponent("holiday.sqlite")
        try Data((0..<512).map { _ in UInt8.random(in: 0...255) }).write(to: file)
        // Ciphertext and not-a-database are indistinguishable without a
        // key — the SAME honest refusal serves both (recorded in the U1
        // design notes).
        #expect(LibraryClassifier.classify(at: file)
            == .bareStoreWithoutKeyFile(store: file))
    }

    // MARK: - Row: newer schema (the migrator's superseded check)

    @Test func aPlaintextStoreFromANewerBuildRefusesWithItsUnknownMigrations() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let store = dir.appendingPathComponent("new/variorum.sqlite")
        try FileManager.default.createDirectory(
            at: store.deletingLastPathComponent(), withIntermediateDirectories: true)
        let database = try AppDatabase.onDisk(url: store, key: nil)
        try database.write { db in
            try db.execute(
                sql: "INSERT INTO grdb_migrations (identifier) VALUES (?)",
                arguments: ["v99_from_the_future"])
        }
        _ = database.asRebindable().binding.lock()
        #expect(LibraryClassifier.classify(at: store)
            == .newerSchema(store: store, unknownMigrations: ["v99_from_the_future"]))
    }

    // MARK: - Row: not a Variorum store

    @Test func aReadableSQLiteFileWithoutTheVariorumShapeIsNotALibrary() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let file = dir.appendingPathComponent("somebody-elses.sqlite")
        let queue = try DatabaseQueue(path: file.path)
        try queue.write { db in
            try db.execute(sql: "CREATE TABLE recipe (id INTEGER PRIMARY KEY, name TEXT)")
        }
        try queue.close()
        #expect(LibraryClassifier.classify(at: file) == .notAVariorumStore(file))
    }

    @Test func anEmptyFileIsNotALibrary() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let file = dir.appendingPathComponent("empty.sqlite")
        try Data().write(to: file)
        #expect(LibraryClassifier.classify(at: file) == .notAVariorumStore(file))
    }

    // MARK: - Row (PROVISIONAL P-U1-2): present but unreadable

    @Test func aTornPlaintextMagicFileReadsAsUnreadableNeverGuessed() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let file = dir.appendingPathComponent("torn.sqlite")
        // The sixteen magic bytes followed by an impossible header — SQLite
        // opens it as "present" and errors on the first real read.
        try (StoreFilePresence.plaintextMagic + Data(repeating: 0x00, count: 84))
            .write(to: file)
        guard case .unreadable(let url, _) = LibraryClassifier.classify(at: file) else {
            Issue.record("a torn plaintext file must classify unreadable")
            return
        }
        #expect(url == file)
    }

    // MARK: - Stage 2: the post-unlock schema consult

    @Test func theSchemaVerdictReadsCurrentOnAStoreThisBuildWrote() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        #expect(LibraryClassifier.schemaVerdict(at: fixture.store, key: fixture.key)
            == .current)
    }

    @Test func theSchemaVerdictRefusesANewerEncryptedCopyWithItsUnknowns() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        let database = try AppDatabase.openStore(
            at: fixture.store, custody: .inMemory(initial: fixture.key))
        try database.write { db in
            try db.execute(
                sql: "INSERT INTO grdb_migrations (identifier) VALUES (?)",
                arguments: ["v99_from_the_future"])
        }
        _ = database.asRebindable().binding.lock()
        #expect(LibraryClassifier.schemaVerdict(at: fixture.store, key: fixture.key)
            == .newer(unknownMigrations: ["v99_from_the_future"]))
    }

    /// 13x F3 (ladder R3-1, constraint 3 — the premise updated by the
    /// RULED split): a wrong key is the `.keyRejected` class, never a
    /// guess into a readable verdict. (Before the split this pin read
    /// `.unreadable`, the one class a torn copy shared with it.)
    @Test func theSchemaVerdictUnderAWrongKeyIsKeyRejectedNeverAGuess() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        #expect(LibraryClassifier.schemaVerdict(at: fixture.store, key: StoreKey.mint())
            == .keyRejected, "a wrong key reads as the wrong-key class")
    }

    // MARK: - The name parser (the pair rules' smallest brain)

    @Test func theBackupNameParserReadsTheAppsShapesAndOnlyThose() {
        let fp = LibraryClassifier.backupNameFingerprint(
            URL(fileURLWithPath: "/b/variorum-backup-2027-01-02-030405-0a1b2c3d.sqlite"))
        #expect(fp.isBackupNamed && fp.fp8 == "0a1b2c3d")
        let stampOnly = LibraryClassifier.backupNameFingerprint(
            URL(fileURLWithPath: "/b/variorum-backup-2027-01-02-030405.sqlite"))
        #expect(stampOnly.isBackupNamed && stampOnly.fp8 == nil)
        let foreign = LibraryClassifier.backupNameFingerprint(
            URL(fileURLWithPath: "/b/variorum-backup-2026-09-05-a1-window.sqlite"))
        #expect(foreign.isBackupNamed && foreign.fp8 == nil)
        let notOurs = LibraryClassifier.backupNameFingerprint(
            URL(fileURLWithPath: "/b/library.sqlite"))
        #expect(!notOurs.isBackupNamed && notOurs.fp8 == nil)
    }
}
