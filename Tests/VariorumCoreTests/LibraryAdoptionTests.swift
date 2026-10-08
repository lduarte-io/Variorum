import Foundation
import GRDB
import Testing

@testable import VariorumCore

// Phase 13x U1 row 3 — the adopt-by-copy move-aside brain's pins: the
// ruled order (safety copy → move aside → land), the refusals that change
// NOTHING, the source-never-touched law, and the key-file normalization
// (a snapshot-pair-named key file lands under its canonical name so
// `StoreKeyEnvelope.locate` serves the adopted library).

@Suite("13x U1 — adopt-by-copy: the move-aside brain")
struct LibraryAdoptionTests {
    private func temporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-13x-adopt-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    /// A closed encrypted library with a wrapped key file beside it.
    private func makeLibrary(
        at storeURL: URL, passphrase: String, marker: String
    ) throws -> StoreKey {
        let key = StoreKey.mint()
        let database = try AppDatabase.openStore(at: storeURL, custody: .inMemory(initial: key))
        try database.write { db in
            try db.execute(
                sql: """
                    INSERT INTO container (id, kind, title, created_at, updated_at)
                    VALUES (?, 'post', ?, '2027-01-01T00:00:00Z', '2027-01-01T00:00:00Z')
                    """,
                arguments: [marker, marker])
        }
        _ = database.asRebindable().binding.lock()
        var envelope = StoreKeyEnvelope()
        try envelope.setPassphraseWrap(key: key, passphrase: passphrase, kdf: fastKDF())
        try envelope.write(at: envelope.preferredURL(besideStore: storeURL))
        return key
    }

    @Test func anAdoptionStepsTheOldLibraryAsideAndLandsTheCopyWithTheSourceUntouched() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        // The standing library.
        let storeURL = dir.appendingPathComponent("home/variorum.sqlite")
        let oldKey = try makeLibrary(at: storeURL, passphrase: "old word", marker: "the-old-library")
        let oldKeyFile = try #require(StoreKeyEnvelope.locate(besideStore: storeURL))
        // The arriving copy (its own key, its own key file — a hand-off pair).
        let sourceStore = dir.appendingPathComponent("arrival/variorum.sqlite")
        let sourceKey = try makeLibrary(
            at: sourceStore, passphrase: "new word", marker: "the-arriving-copy")
        let sourceKeyFile = try #require(StoreKeyEnvelope.locate(besideStore: sourceStore))
        let sourceStoreBytes = try Data(contentsOf: sourceStore)
        let sourceKeyFileBytes = try Data(contentsOf: sourceKeyFile)

        let plan = LibraryAdoption.plan(
            adopting: sourceStore, keyFile: sourceKeyFile,
            intoStoreAt: storeURL, now: Date(timeIntervalSince1970: 1_800_000_000))
        let receipt = try LibraryAdoption.execute(plan)

        // The old library stepped aside WHOLE — store + key file, recoverable.
        let asideStore = plan.asideFolder.appendingPathComponent("variorum.sqlite")
        let asideKeyFile = plan.asideFolder.appendingPathComponent(oldKeyFile.lastPathComponent)
        #expect(FileManager.default.fileExists(atPath: asideStore.path))
        #expect(FileManager.default.fileExists(atPath: asideKeyFile.path))
        #expect(receipt.movedAside.map(\.lastPathComponent).sorted()
            == ["variorum.sqlite", oldKeyFile.lastPathComponent].sorted())
        // …and still opens by its own key (nothing destroyed).
        let reopenedOld = try AppDatabase.onDisk(url: asideStore, key: oldKey)
        let oldTitle = try reopenedOld.read {
            try String.fetchOne($0, sql: "SELECT title FROM container WHERE id = 'the-old-library'")
        }
        _ = reopenedOld.asRebindable().binding.lock()
        #expect(oldTitle == "the-old-library")

        // The safety copy exists — the A1 shape, same files.
        #expect(receipt.safetyCopied.map(\.lastPathComponent).sorted()
            == ["variorum.sqlite", oldKeyFile.lastPathComponent].sorted())
        #expect(receipt.safetyCopied.allSatisfy {
            FileManager.default.fileExists(atPath: $0.path)
        })
        #expect(plan.safetyCopyFolder.path.contains("Backups/safety-copies/variorum-adopt-safety-"))

        // The copy LANDED: byte-identical store, the key file under its
        // canonical name, served by `locate`, read by the classifier.
        #expect(try Data(contentsOf: storeURL) == sourceStoreBytes)
        let landedKeyFile = try #require(plan.landedKeyFile)
        #expect(landedKeyFile.lastPathComponent
            == StoreKeyEnvelope.filename(
                forFingerprint: StoreKeyEnvelope.fingerprint(of: sourceKey)))
        #expect(StoreKeyEnvelope.locate(besideStore: storeURL)?.resolvingSymlinksInPath()
            == landedKeyFile.resolvingSymlinksInPath())
        #expect(LibraryClassifier.classify(at: storeURL)
            == .encryptedLibrary(store: storeURL, keyFile: landedKeyFile))
        let reopenedNew = try AppDatabase.onDisk(url: storeURL, key: sourceKey)
        let newTitle = try reopenedNew.read {
            try String.fetchOne($0, sql: "SELECT title FROM container WHERE id = 'the-arriving-copy'")
        }
        _ = reopenedNew.asRebindable().binding.lock()
        #expect(newTitle == "the-arriving-copy")

        // THE SOURCE PAIR WAS NEVER TOUCHED — present, byte-identical.
        #expect(try Data(contentsOf: sourceStore) == sourceStoreBytes)
        #expect(try Data(contentsOf: sourceKeyFile) == sourceKeyFileBytes)
    }

    /// A snapshot-pair-named key file (`…keys.json`) lands under its
    /// CANONICAL fingerprint name beside the adopted store.
    @Test func aPairNamedKeyFileIsNormalizedAtTheLanding() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let sourceStore = dir.appendingPathComponent("backups/variorum-backup-2027-01-02-030405-aabbccdd.sqlite")
        let key = try makeLibrary(at: sourceStore, passphrase: "w", marker: "m")
        // Rename the key file into the snapshot-pair shape.
        let canonical = try #require(StoreKeyEnvelope.locate(besideStore: sourceStore))
        let pairNamed = sourceStore.deletingPathExtension().appendingPathExtension("keys.json")
        try FileManager.default.moveItem(at: canonical, to: pairNamed)

        let storeURL = dir.appendingPathComponent("home/variorum.sqlite")
        let plan = LibraryAdoption.plan(
            adopting: sourceStore, keyFile: pairNamed,
            intoStoreAt: storeURL, now: Date(timeIntervalSince1970: 1_800_000_000))
        try LibraryAdoption.execute(plan)
        let landedKeyFile = try #require(plan.landedKeyFile)
        #expect(landedKeyFile.lastPathComponent
            == StoreKeyEnvelope.filename(forFingerprint: StoreKeyEnvelope.fingerprint(of: key)))
        #expect(FileManager.default.fileExists(atPath: landedKeyFile.path))
        #expect(StoreKeyEnvelope.locate(besideStore: storeURL)?.resolvingSymlinksInPath()
            == landedKeyFile.resolvingSymlinksInPath())
    }

    /// 13x U2 row 8 — THE PLAINTEXT ROAD (ledger 5's "plaintext → fresh
    /// key + identity"): no pair travels; the landing is the store alone,
    /// the old family still steps aside whole, and NO key file lands (the
    /// door mints a fresh key + identity after this).
    @Test func aPlaintextAdoptionLandsTheStoreAloneAndStillStepsTheOldFamilyAside() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("home/variorum.sqlite")
        _ = try makeLibrary(at: storeURL, passphrase: "old word", marker: "the-old-library")
        let oldKeyFile = try #require(StoreKeyEnvelope.locate(besideStore: storeURL))
        // The arriving plaintext copy — a real production export.
        let exportSource = dir.appendingPathComponent("arrival/variorum.sqlite")
        let plain = dir.appendingPathComponent("arrival/Variorum-unencrypted.sqlite")
        do {
            let key = StoreKey.mint()
            let database = try AppDatabase.openStore(at: exportSource, custody: .inMemory(initial: key))
            try StorePlaintextExport.export(from: database, to: plain)
            _ = database.asRebindable().binding.lock()
        }
        let plainBytes = try Data(contentsOf: plain)

        let plan = LibraryAdoption.plan(
            adopting: plain, keyFile: nil,
            intoStoreAt: storeURL, now: Date(timeIntervalSince1970: 1_800_000_000))
        #expect(plan.landedKeyFile == nil)
        let receipt = try LibraryAdoption.execute(plan)
        // The old family aside whole (store + its key file).
        #expect(receipt.movedAside.map(\.lastPathComponent).sorted()
            == ["variorum.sqlite", oldKeyFile.lastPathComponent].sorted())
        // The landed store is the export, byte-identical; NO key file
        // beside it (the fresh mint is the door's next step).
        #expect(try Data(contentsOf: storeURL) == plainBytes)
        #expect(StoreKeyEnvelope.locate(besideStore: storeURL) == nil)
        // The source untouched.
        #expect(try Data(contentsOf: plain) == plainBytes)
    }

    /// No standing library (the library-missing state): nothing steps
    /// aside, nothing is safety-copied, the copy just lands.
    @Test func adoptingOntoAnEmptySlotLandsWithNothingToMoveAside() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let sourceStore = dir.appendingPathComponent("arrival/variorum.sqlite")
        _ = try makeLibrary(at: sourceStore, passphrase: "w", marker: "m")
        let sourceKeyFile = try #require(StoreKeyEnvelope.locate(besideStore: sourceStore))
        let storeURL = dir.appendingPathComponent("home/variorum.sqlite")
        let plan = LibraryAdoption.plan(
            adopting: sourceStore, keyFile: sourceKeyFile,
            intoStoreAt: storeURL, now: Date(timeIntervalSince1970: 1_800_000_000))
        let receipt = try LibraryAdoption.execute(plan)
        #expect(receipt.movedAside.isEmpty)
        #expect(receipt.safetyCopied.isEmpty)
        #expect(!FileManager.default.fileExists(atPath: plan.asideFolder.path))
        #expect(!FileManager.default.fileExists(atPath: plan.safetyCopyFolder.path))
        #expect(FileManager.default.fileExists(atPath: storeURL.path))
    }

    /// REFUSALS that change NOTHING on disk.
    /// 13x F1 (ladder R1-M2): the RESTORE HOLD rides INSIDE the adoption —
    /// written between the safety copy and the move — so (a) a successful
    /// adoption lands ALREADY held, (b) a failed hold write REFUSES with
    /// nothing moved (`holdWriteFailed`; before this fix the doors'
    /// `try? LibraryRestoreHold.set` at completion swallowed the failure
    /// and the landed copy caught up silently at the next trigger — the
    /// exact silent catch-up round 3 exists to prevent), and (c) the
    /// ordinary refusal arms never leave a stray marker. The failure seam
    /// is seeded by occupying the marker's path with a non-empty
    /// directory. RED ON OLD: the step-3½ block removed ⇒ the
    /// blocked-marker adoption SUCCEEDS, un-held.
    @Test func theHoldRidesInsideTheAdoptionAndAFailedWriteRefusesWithNothingMoved() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("home/variorum.sqlite")
        let oldKey = try makeLibrary(at: storeURL, passphrase: "old word", marker: "the-old-library")
        _ = oldKey
        let oldKeyFile = try #require(StoreKeyEnvelope.locate(besideStore: storeURL))
        let oldStoreBytes = try Data(contentsOf: storeURL)
        let sourceStore = dir.appendingPathComponent("arrival/variorum.sqlite")
        _ = try makeLibrary(at: sourceStore, passphrase: "new word", marker: "the-arriving-copy")
        let sourceKeyFile = try #require(StoreKeyEnvelope.locate(besideStore: sourceStore))

        // (c) An ordinary refusal with a hold REQUESTED leaves no stray
        // marker — the refusal arms run before step 3½.
        let refusing = LibraryAdoption.plan(
            adopting: dir.appendingPathComponent("nowhere/variorum.sqlite"),
            keyFile: sourceKeyFile, intoStoreAt: storeURL,
            now: Date(timeIntervalSince1970: 1_800_000_050))
        #expect {
            try LibraryAdoption.execute(refusing, holding: .init(asOf: nil, now: Date()))
        } throws: { error in
            if case LibraryAdoption.AdoptionError.sourceMissing = error { return true }
            return false
        }
        #expect(!LibraryRestoreHold.isHeld(besideStore: storeURL),
                "a refused adoption writes no marker")

        // (b) The marker's path occupied by a NON-EMPTY DIRECTORY: the
        // hold write fails ⇒ the adoption refuses with NOTHING moved.
        let markerURL = LibraryRestoreHold.markerURL(besideStore: storeURL)
        try FileManager.default.createDirectory(at: markerURL, withIntermediateDirectories: true)
        try Data("occupant".utf8).write(
            to: markerURL.appendingPathComponent("occupant", isDirectory: false))
        let blocked = LibraryAdoption.plan(
            adopting: sourceStore, keyFile: sourceKeyFile,
            intoStoreAt: storeURL, now: Date(timeIntervalSince1970: 1_800_000_100))
        #expect {
            try LibraryAdoption.execute(blocked, holding: .init(asOf: nil, now: Date()))
        } throws: { error in
            if case LibraryAdoption.AdoptionError.holdWriteFailed = error { return true }
            return false
        }
        #expect(try Data(contentsOf: storeURL) == oldStoreBytes,
                "the old library stands byte-identical — nothing moved")
        #expect(!FileManager.default.fileExists(atPath: blocked.asideFolder.path),
                "no move-aside began")
        #expect(StoreKeyEnvelope.locate(besideStore: storeURL)?.lastPathComponent
                == oldKeyFile.lastPathComponent, "the old key file still serves the path")

        // (a) The obstruction removed: the adoption lands — ALREADY held,
        // with the as-of day riding the marker.
        try FileManager.default.removeItem(at: markerURL)
        let asOf = Date(timeIntervalSince1970: 1_780_000_000)
        let good = LibraryAdoption.plan(
            adopting: sourceStore, keyFile: sourceKeyFile,
            intoStoreAt: storeURL, now: Date(timeIntervalSince1970: 1_800_000_200))
        try LibraryAdoption.execute(good, holding: .init(asOf: asOf, now: Date()))
        let hold = try #require(LibraryRestoreHold.read(besideStore: storeURL))
        #expect(hold.asOf == asOf, "the landed copy is held, carrying its own day")
    }

    @Test func aHotWalRefusesBeforeAnythingMoves() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("home/variorum.sqlite")
        _ = try makeLibrary(at: storeURL, passphrase: "old", marker: "o")
        let before = try snapshotOfFolder(storeURL.deletingLastPathComponent())
        // A non-empty -wal: the pool is "open".
        try Data("frames".utf8).write(to: URL(fileURLWithPath: storeURL.path + "-wal"))
        let sourceStore = dir.appendingPathComponent("arrival/variorum.sqlite")
        _ = try makeLibrary(at: sourceStore, passphrase: "new", marker: "n")
        let sourceKeyFile = try #require(StoreKeyEnvelope.locate(besideStore: sourceStore))
        let plan = LibraryAdoption.plan(
            adopting: sourceStore, keyFile: sourceKeyFile,
            intoStoreAt: storeURL, now: Date())
        #expect(throws: LibraryAdoption.AdoptionError.libraryLooksOpen(storeURL.path + "-wal")) {
            try LibraryAdoption.execute(plan)
        }
        try FileManager.default.removeItem(at: URL(fileURLWithPath: storeURL.path + "-wal"))
        let after = try snapshotOfFolder(storeURL.deletingLastPathComponent())
        #expect(before == after, "a refusal changes nothing")
    }

    @Test func aMissingSourceOrKeyFileRefusesWithNothingChanged() throws {
        let dir = try temporaryDirectory()
        defer { try? FileManager.default.removeItem(at: dir) }
        let storeURL = dir.appendingPathComponent("home/variorum.sqlite")
        _ = try makeLibrary(at: storeURL, passphrase: "old", marker: "o")
        let before = try snapshotOfFolder(storeURL.deletingLastPathComponent())
        let ghostStore = dir.appendingPathComponent("nowhere/variorum.sqlite")
        let ghostKeys = dir.appendingPathComponent("nowhere/variorum-keys-aabbccddeeff0011.json")
        #expect(throws: LibraryAdoption.AdoptionError.sourceMissing(ghostStore.path)) {
            try LibraryAdoption.execute(LibraryAdoption.plan(
                adopting: ghostStore, keyFile: ghostKeys, intoStoreAt: storeURL, now: Date()))
        }
        // A real store whose named key file is gone.
        let sourceStore = dir.appendingPathComponent("arrival/variorum.sqlite")
        _ = try makeLibrary(at: sourceStore, passphrase: "new", marker: "n")
        #expect(throws: LibraryAdoption.AdoptionError.sourceKeyFileMissing(ghostKeys.path)) {
            try LibraryAdoption.execute(LibraryAdoption.plan(
                adopting: sourceStore, keyFile: ghostKeys, intoStoreAt: storeURL, now: Date()))
        }
        let after = try snapshotOfFolder(storeURL.deletingLastPathComponent())
        #expect(before == after)
    }

    private func snapshotOfFolder(_ folder: URL) throws -> [String: Int] {
        var out: [String: Int] = [:]
        let fm = FileManager.default
        for name in try fm.subpathsOfDirectory(atPath: folder.path) {
            let path = folder.appendingPathComponent(name).path
            var isDirectory: ObjCBool = false
            _ = fm.fileExists(atPath: path, isDirectory: &isDirectory)
            if !isDirectory.boolValue {
                out[name] = (try? fm.attributesOfItem(atPath: path)[.size] as? Int) ?? -1
            }
        }
        return out
    }
}
