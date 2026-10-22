import Foundation
import GRDB
import Testing

@testable import VariorumCore

// Phase 13x U1 row 1 — THE VERDICT TABLE, pinned: one pin per verdict row
// (the plan's "exact tests per verdict"), each over a REAL fixture of its
// shape — real keyed stores, real key files, the production export — never
// a mocked byte. The refusal-guarding verdicts' red-first evidence is the
// behavioural revert quoted in the U1 RECORD.
//
// VX-329 U1 — THE RELEASE SWITCH: today's key-file readers left with today's
// road, so the classifier NAMES a key file beside an encrypted store and
// reads no byte of it (R-U1-2 in the plan's U1 record). The pins that held
// today's reading — the snapshot-pair and folder-pair verdicts, the
// which-opens-which fingerprint match, the backup-name fp8 parser — went
// with their subjects; the HONEST-REFUSAL pins (piece 5, the §6 OPEN DESIGN
// NOTE) stand in their place: a copy from before this design, its older key
// file beside it, is never called keyless.

@Suite("13x U1 — the picked-thing classifier's verdict table")
struct LibraryClassifierTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13x-classifier-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// An encrypted library at `<dir>/library/variorum.sqlite` with THIS
    /// design's key file beside it (`variorum-library-keys.json`, a real
    /// format-3 document of the store's key) — Send Library's shape.
    private func makeEncryptedLibrary(in dir: URL) throws -> (store: URL, key: StoreKey, keyFile: URL) {
        let store = dir.appendingPathComponent("library/variorum.sqlite")
        let key = StoreKey.mint()
        let database = try AppDatabase.openStore(at: store, custody: .inMemory(initial: key))
        _ = database.asRebindable().binding.lock()
        let keyFile = store.deletingLastPathComponent()
            .appendingPathComponent(ProtectionNames.keyFilename, isDirectory: false)
        try KeyFile(libraryID: UUID().uuidString.lowercased(), key: key, epoch: 1).encoded().write(to: keyFile)
        return (store, key, keyFile)
    }

    /// A key file an OLDER Variorum wrote (before this design — rule 26), by
    /// the name it gave it, with a document of that era's top-level shape.
    /// The classifier reads its NAME only, so the bytes are a fixture's.
    private func writeOlderKeyFile(named name: String, beside store: URL, key: StoreKey) throws -> URL {
        let url = store.deletingLastPathComponent().appendingPathComponent(name, isDirectory: false)
        let recovery = Data((0..<40).map { _ in UInt8.random(in: 0...255) }).base64EncodedString()
        let document = """
            {"formatVersion":2,"storeID":"\(UUID().uuidString.lowercased())",\
            "keyFingerprint":"\(KeyFingerprint.of(key))","recovery":"\(recovery)"}
            """
        try Data(document.utf8).write(to: url)
        return url
    }

    // MARK: - Row: encrypted library with a key file beside (named, never read)

    @Test func anEncryptedStoreWithThisDesignsKeyFileBesideClassifiesAsALibrary() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        #expect(LibraryClassifier.classify(at: fixture.store)
            == .encryptedLibrary(store: fixture.store, keyFile: fixture.keyFile))
    }

    /// The restatement of this design's key-file name in core's Persistence
    /// (which cannot see the Protection names without a cycle of meaning)
    /// is held equal to the one the road writes.
    @Test func theClassifiersNameForThisDesignsKeyFileIsTheRoadsOwn() {
        #expect(LibraryClassifier.thisDesignsKeyFilename == ProtectionNames.keyFilename)
    }

    @Test func aSnapshotWithItsOwnPairKeyFileBesideClassifiesAsALibraryNamingIt() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        let fp8 = KeyFingerprint.short(KeyFingerprint.of(fixture.key))
        let folder = dir.appendingPathComponent("Backups", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let snapshot = folder.appendingPathComponent("variorum-backup-2027-01-02-030405-\(fp8).sqlite")
        try FileManager.default.copyItem(at: fixture.store, to: snapshot)
        let pair = folder.appendingPathComponent("variorum-backup-2027-01-02-030405-\(fp8).keys.json")
        try FileManager.default.copyItem(at: fixture.keyFile, to: pair)
        #expect(LibraryClassifier.classify(at: snapshot) == .encryptedLibrary(store: snapshot, keyFile: pair))
    }

    // MARK: - Piece 5: a copy from before this design is never called keyless

    /// THE HONEST REFUSAL (the plan's §6 OPEN DESIGN NOTE): a library from
    /// before this design — an encrypted store with the fingerprint-named key
    /// file an older Variorum wrote beside it — is NAMED as a library with a
    /// key file (the door then says "This file couldn't be read as a
    /// library.", never the no-key-file sentence). A pin of what the built
    /// shape says (piece 5), not a fix — no red-on-old is claimed.
    @Test func aPreDesignLibraryWithItsFingerprintNamedKeyFileIsNamedNeverKeyless() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        try FileManager.default.removeItem(at: fixture.keyFile)
        let older = try writeOlderKeyFile(
            named: PF.olderKeyFilename(KeyFingerprint.of(fixture.key)), beside: fixture.store, key: fixture.key)
        #expect(LibraryClassifier.classify(at: fixture.store)
            == .encryptedLibrary(store: fixture.store, keyFile: older))
        // The picked folder reads as its one store.
        #expect(LibraryClassifier.classify(at: fixture.store.deletingLastPathComponent())
            == .encryptedLibrary(store: fixture.store, keyFile: older))
    }

    /// The oldest name (`variorum-keys.json`, the fixed legacy file).
    @Test func aPreDesignLibraryWithTheLegacyKeyFileIsNamedNeverKeyless() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        try FileManager.default.removeItem(at: fixture.keyFile)
        let legacy = try writeOlderKeyFile(named: PF.olderLegacyKeyFilename, beside: fixture.store, key: fixture.key)
        #expect(LibraryClassifier.classify(at: fixture.store)
            == .encryptedLibrary(store: fixture.store, keyFile: legacy))
    }

    /// A pre-design BACKUP (an older build's flat snapshot) in a folder
    /// holding that build's key file: named, never keyless.
    @Test func aPreDesignStampOnlySnapshotBesideAnOlderKeyFileIsNamedNeverKeyless() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        let folder = dir.appendingPathComponent("Backups", isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let snapshot = folder.appendingPathComponent("variorum-backup-2027-01-02-030405.sqlite")
        try FileManager.default.copyItem(at: fixture.store, to: snapshot)
        let older = try writeOlderKeyFile(
            named: PF.olderKeyFilename(KeyFingerprint.of(fixture.key)), beside: snapshot, key: fixture.key)
        #expect(LibraryClassifier.classify(at: snapshot) == .encryptedLibrary(store: snapshot, keyFile: older))
    }

    /// Names only: a key-file-shaped name whose bytes are not a key file at
    /// all is still NAMED (the classifier opens no key file — rule 26), and a
    /// name that is not key-file-shaped (a fingerprint of the wrong length,
    /// an uppercase one) names nothing, so the store is honestly keyless.
    @Test func theClassifierNamesByNameAloneAndOnlyTheShapesAnyBuildWrote() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        try FileManager.default.removeItem(at: fixture.keyFile)
        let folder = fixture.store.deletingLastPathComponent()
        for near in ["variorum-keys-0a1b2c3d.json", "variorum-keys-0A1B2C3D4E5F6A7B.json",
                     "variorum-keys-0a1b2c3d4e5f6a7b0.json", "variorum-keys-0a1b2c3d4e5f6a7b.json.bak"] {
            try Data("{}".utf8).write(to: folder.appendingPathComponent(near))
        }
        #expect(LibraryClassifier.classify(at: fixture.store) == .bareStoreWithoutKeyFile(store: fixture.store),
                "no key-file-shaped name beside it")
        let garbage = folder.appendingPathComponent(ProtectionNames.keyFilename)
        try Data((0..<64).map { _ in UInt8.random(in: 0...255) }).write(to: garbage)
        #expect(LibraryClassifier.classify(at: fixture.store) == .encryptedLibrary(store: fixture.store, keyFile: garbage),
                "a key-file-shaped name is named whatever its bytes")
    }

    // MARK: - Rows: the picked folder

    @Test func aFolderHoldingOneStoreClassifiesAsThatStore() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let fixture = try makeEncryptedLibrary(in: dir)
        let folder = fixture.store.deletingLastPathComponent()
        #expect(LibraryClassifier.classify(at: folder)
            == .encryptedLibrary(store: fixture.store, keyFile: fixture.keyFile))
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
}
