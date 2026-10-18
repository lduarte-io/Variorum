//
//  ProtectionFileLeavesTests.swift
//  VariorumTests — VX-306 U1a: the file leaves on temp folders (real SQLCipher files, no keychain): the live
//  key file, the plan, the library file's roads (create · stage · the swap, both shapes · a copy staged and
//  probed from a private copy · the WAL belt), the backup pairs, and the catalogue's listing.
//

import CryptoKit
import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U1a — the file leaves (temp folders)")
struct ProtectionFileLeavesTests {
    static func words() throws -> [String] { try RecoveryPhrase.generate() }

    /// A format-3 key file for `key` of `libraryID`, locked under fresh words.
    static func keyFile(_ key: StoreKey, libraryID: String) throws -> KeyFile {
        try KeyFile.building(
            libraryID: libraryID, key: key, epoch: 1, locks: NewKeyLocks(words: try WordsKey.derive(try words())))
    }

    static func record(_ key: StoreKey, libraryID: String = UUID().uuidString.lowercased()) -> ProtectionRecord {
        ProtectionRecord.minting(
            libraryID: libraryID, mode: .standard, account: nil,
            currentFingerprint: StoreKeyEnvelope.fingerprint(of: key), at: Date(timeIntervalSinceReferenceDate: 790_000_000))
    }

    // MARK: The live key file

    @Test func theLiveKeyFileReadsWritesAndRefusesWhatItCannotRead() throws {
        let slot = TempSlot()
        let leaf = FileKeyFileStoreLeaf(places: slot.places)
        #expect(try leaf.readLiveKeyFile() == nil)
        let file = try Self.keyFile(StoreKey.mint(), libraryID: UUID().uuidString.lowercased())
        try leaf.writeLiveKeyFile(file)
        #expect(try leaf.readLiveKeyFile() == file)
        try Data("{\"formatVersion\": 2}".utf8).write(to: slot.places.liveKeyFile)
        #expect(throws: FileKeyFileStoreLeaf.KeyFileStoreError.self) { try leaf.readLiveKeyFile() }
    }

    @Test func theCataloguedKeyFilesAreThisLibrarysOutsideTheLivePlace() throws {
        let slot = TempSlot(withFarFolder: true)
        let mine = UUID().uuidString.lowercased(), theirs = UUID().uuidString.lowercased()
        let live = try Self.keyFile(StoreKey.mint(), libraryID: mine)
        let backup = try Self.keyFile(StoreKey.mint(), libraryID: mine)
        let far = try Self.keyFile(StoreKey.mint(), libraryID: mine)
        let other = try Self.keyFile(StoreKey.mint(), libraryID: theirs)
        let leaf = FileKeyFileStoreLeaf(places: slot.places)
        try leaf.writeLiveKeyFile(live)
        func put(_ file: KeyFile, _ url: URL) throws {
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try file.encoded().write(to: url)
        }
        try put(backup, slot.url("Backups/\(mine.prefix(8))/aaaaaaaa/variorum-backup-2026-10-18-120000-\(backup.fingerprint.prefix(8)).keys.json"))
        try put(other, slot.url("Backups/\(theirs.prefix(8))/aaaaaaaa/variorum-backup-2026-10-18-120000-\(other.fingerprint.prefix(8)).keys.json"))
        try put(far, slot.far.appendingPathComponent("Variorum/Backups/\(mine.prefix(8))/bbbbbbbb/variorum-backup-2026-10-18-130000-\(far.fingerprint.prefix(8)).keys.json"))
        let found = try leaf.catalogedKeyFiles(ofLibrary: mine)
        #expect(Set(found.map(\.fingerprint)) == [backup.fingerprint, far.fingerprint])
    }

    // MARK: The plan

    @Test func thePlanIsWrittenExcludedFromBackupsReadAndDeleted() throws {
        let slot = TempSlot()
        let leaf = FilePlanStoreLeaf(places: slot.places)
        #expect(try leaf.readPlan() == nil)
        let key = StoreKey.mint()
        let plan = ProtectionPlan(
            libraryID: UUID().uuidString.lowercased(), deviceID: UUID().uuidString.lowercased(), sequence: 1,
            act: .deviceSettings, steps: [PlanStep(name: "settings")], createdAt: Date())
        let sealed = try plan.sealed(under: key)
        try leaf.writePlan(sealed)
        #expect(try leaf.readPlan() == sealed)
        #expect(try slot.places.plan.resourceValues(forKeys: [.isExcludedFromBackupKey]).isExcludedFromBackup == true)
        try Data("debris".utf8).write(to: slot.places.plan)
        #expect(try leaf.readPlan() == nil, "debris reads as no plan")
        try leaf.deletePlan()
        #expect(!FileManager.default.fileExists(atPath: slot.places.plan.path))
        try leaf.deletePlan()
    }

    // MARK: The library file

    @Test func aCreatedLibraryOpensWithItsKeyAndMarksThatALibraryLivedHere() throws {
        let slot = TempSlot()
        let leaf = SQLCipherLibraryLeaf(places: slot.places)
        let key = StoreKey.mint()
        let record = Self.record(key)
        #expect(!FileManager.default.fileExists(atPath: slot.places.livedHereMarker.path))
        try leaf.createLibrary(with: key, record: record)
        #expect(try leaf.libraryOpens(with: key))
        #expect(!(try leaf.libraryOpens(with: StoreKey.mint())))
        #expect(try leaf.readRecord(with: key) == record)
        #expect(FileManager.default.fileExists(atPath: slot.places.livedHereMarker.path))
        var next = record
        next.reminderDismissals = 1
        try leaf.writeRecord(next, with: key)
        #expect(try leaf.readRecord(with: key) == next)
        #expect(throws: (any Error).self) { try leaf.createLibrary(with: StoreKey.mint(), record: Self.record(StoreKey.mint())) }
    }

    @Test func theStagedFileSwapsInByOneRenameAndTheOutgoingStepsAsideWhole() throws {
        let slot = TempSlot()
        let leaf = SQLCipherLibraryLeaf(places: slot.places)
        let k0 = StoreKey.mint(), k1 = StoreKey.mint(), k2 = StoreKey.mint()
        try leaf.createLibrary(with: k0, record: Self.record(k0))
        _ = try AppDatabase.onDisk(url: slot.places.slot, key: k0)  // a migrated library in WAL mode
        #expect(try leaf.stagedFingerprint() == nil)
        // A re-key: staged, its record, the swap in place.
        try leaf.stageReencryption(from: k0, to: k1)
        #expect(try leaf.stagedFingerprint() == StoreKeyEnvelope.fingerprint(of: k1))
        #expect(throws: SQLCipherLibraryLeaf.LibraryLeafError.stagedUnderAnotherKey) {
            try leaf.writeStagedRecord(Self.record(k2), with: k2)
        }
        let r1 = Self.record(k1)
        try leaf.writeStagedRecord(r1, with: k1)
        try leaf.swapStaged(setAside: false, asideKeyFile: nil)
        #expect(try leaf.libraryOpens(with: k1))
        #expect(!(try leaf.libraryOpens(with: k0)))
        #expect(try leaf.readRecord(with: k1) == r1)
        #expect(try leaf.stagedFingerprint() == nil)
        #expect(!FileManager.default.fileExists(atPath: slot.places.previousLibraries.path), "a re-key sets nothing aside")
        // With set-aside: the outgoing library and ITS key file into Previous Libraries/<stamp>/.
        try leaf.stageReencryption(from: k1, to: k2)
        try leaf.writeStagedRecord(Self.record(k2), with: k2)
        let outgoingFile = try Self.keyFile(k1, libraryID: r1.libraryID)
        try leaf.swapStaged(setAside: true, asideKeyFile: outgoingFile)
        #expect(try leaf.libraryOpens(with: k2))
        let stamps = try FileManager.default.contentsOfDirectory(atPath: slot.places.previousLibraries.path)
        #expect(stamps.count == 1 && stamps.allSatisfy { CatalogNames.stamp($0) != nil })
        let aside = slot.places.previousLibraries.appendingPathComponent(stamps[0])
        #expect(ProtectionLibraryFiles.opens(aside.appendingPathComponent(CatalogNames.libraryFilename), key: k1))
        #expect(try KeyFile.decode(Data(contentsOf: aside.appendingPathComponent(ProtectionNames.keyFilename))) == outgoingFile)
        let catalog = CatalogLister(places: slot.places).catalog()
        #expect(catalog.copies.contains { $0.kind == .previousLibrary && $0.fingerprint == outgoingFile.fingerprint })
    }

    @Test func aWALWithFramesBesideTheSlotRefusesTheSwapAndMovesNothing() throws {
        let slot = TempSlot()
        let leaf = SQLCipherLibraryLeaf(places: slot.places)
        let k0 = StoreKey.mint(), k1 = StoreKey.mint()
        try leaf.createLibrary(with: k0, record: Self.record(k0))
        try leaf.stageReencryption(from: k0, to: k1)
        try Data(repeating: 1, count: 64).write(to: URL(fileURLWithPath: slot.places.slot.path + "-wal"))
        #expect(throws: SQLCipherLibraryLeaf.LibraryLeafError.walNotDrained) {
            try leaf.swapStaged(setAside: true, asideKeyFile: nil)
        }
        #expect(try leaf.stagedFingerprint() == StoreKeyEnvelope.fingerprint(of: k1), "the staged file is still there")
        #expect(!FileManager.default.fileExists(atPath: slot.places.previousLibraries.path))
        try leaf.discardStaged()
        #expect(try leaf.stagedFingerprint() == nil)
    }

    @Test func aCataloguedCopyIsProbedAndStagedFromAPrivateCopyAndNeverWritten() throws {
        let slot = TempSlot(withFarFolder: true)
        let leaf = SQLCipherLibraryLeaf(places: slot.places)
        let backups = FileBackupsLeaf(places: slot.places)
        let k0 = StoreKey.mint(), k1 = StoreKey.mint()
        let libraryID = UUID().uuidString.lowercased()
        try leaf.createLibrary(with: k0, record: Self.record(k0, libraryID: libraryID))
        let file = try Self.keyFile(k0, libraryID: libraryID)
        try backups.takeBackupPair(with: k0, keyFile: file, deviceID: UUID().uuidString.lowercased())
        // The pair, copied into the far folder too (another Mac's shared folder).
        let local = try #require(CatalogLister(places: slot.places).catalog().copies.first { $0.kind == .backup })
        let farFolder = slot.far.appendingPathComponent("Variorum/Backups/\(libraryID.prefix(8))/cccccccc", isDirectory: true)
        try FileManager.default.createDirectory(at: farFolder, withIntermediateDirectories: true)
        let localURL = slot.url(local.folders.joined(separator: "/") + "/" + local.name)
        try FileManager.default.copyItem(at: localURL, to: farFolder.appendingPathComponent(local.name))
        let far = try #require(CatalogLister(places: slot.places).catalog().copies.first { $0.place == .farFolder })
        let before = try FileManager.default.contentsOfDirectory(atPath: farFolder.path).sorted()
        #expect(try leaf.copyOpens(copyID: far.id, with: k0))
        #expect(!(try leaf.copyOpens(copyID: far.id, with: k1)))
        try leaf.stageCopy(copyID: far.id, opener: k0, to: k1)
        #expect(try leaf.stagedFingerprint() == StoreKeyEnvelope.fingerprint(of: k1))
        #expect(try FileManager.default.contentsOfDirectory(atPath: farFolder.path).sorted() == before, "the copy's folder is unwritten")
        #expect(!(try leaf.copyOpens(copyID: "farFolder:../../etc/passwd", with: k0)), "a path never climbs out")
        try leaf.discardStaged()
    }

    // MARK: Backups

    @Test func aBackupPairLandsInThisMacsFolderUnderItsKeyWithItsFrozenKeyFile() throws {
        let slot = TempSlot()
        let leaf = SQLCipherLibraryLeaf(places: slot.places)
        let backups = FileBackupsLeaf(places: slot.places)
        let k0 = StoreKey.mint()
        let libraryID = UUID().uuidString.lowercased(), deviceID = UUID().uuidString.lowercased()
        try leaf.createLibrary(with: k0, record: Self.record(k0, libraryID: libraryID))
        let file = try Self.keyFile(k0, libraryID: libraryID)
        #expect(throws: FileBackupsLeaf.BackupsLeafError.keyFileIsAnotherKeys) {
            try backups.takeBackupPair(with: k0, keyFile: try Self.keyFile(StoreKey.mint(), libraryID: libraryID), deviceID: deviceID)
        }
        backups.pauseCopies()
        #expect(throws: FileBackupsLeaf.BackupsLeafError.paused) { try backups.takeBackupPair(with: k0, keyFile: file, deviceID: deviceID) }
        backups.resumeCopies()
        try backups.takeBackupPair(with: k0, keyFile: file, deviceID: deviceID)
        let catalog = CatalogLister(places: slot.places).catalog()
        let copy = try #require(catalog.copies.first { $0.kind == .backup })
        #expect(copy.library == libraryID)
        #expect(copy.fingerprint == file.fingerprint)
        #expect(copy.folders == ["Backups", String(libraryID.prefix(8)), String(deviceID.prefix(8))])
        #expect(catalog.servingKeyFiles(of: copy).first?.document == file)
        let url = slot.url(copy.folders.joined(separator: "/") + "/" + copy.name)
        #expect(ProtectionLibraryFiles.opens(url, key: k0))
        try backups.deleteCopies(ids: [copy.id])
        #expect(CatalogLister(places: slot.places).catalog().copies.isEmpty)
        #expect(CatalogLister(places: slot.places).catalog().keyFiles.allSatisfy { $0.role == .live || $0.name != FileBackupsLeaf.pairURL(of: url).lastPathComponent })
    }

    /// VX-306 U2 — W-2 (the U1b walk's MINOR, red-on-old): a pair is the snapshot + its key file and NOTHING else.
    /// From a live library held open in WAL mode (the app's pool), the pair's folder holds exactly two files, and the
    /// snapshot carried away by itself opens with its key alone.
    @Test func aBackupPairOfALiveWALLibraryIsExactlyTwoFilesAndTheSnapshotOpensAlone() throws {
        let slot = TempSlot()
        let leaf = SQLCipherLibraryLeaf(places: slot.places)
        let backups = FileBackupsLeaf(places: slot.places)
        let k0 = StoreKey.mint()
        let libraryID = UUID().uuidString.lowercased(), deviceID = UUID().uuidString.lowercased()
        let record = Self.record(k0, libraryID: libraryID)
        try leaf.createLibrary(with: k0, record: record)
        // WAL mode, held open — the app's pool (its migrations write, so frames stand in the WAL).
        let live = try AppDatabase.onDisk(url: slot.places.slot, key: k0)
        let file = try Self.keyFile(k0, libraryID: libraryID)
        try backups.takeBackupPair(with: k0, keyFile: file, deviceID: deviceID)
        let folder = slot.places.backupFolder(libraryID: libraryID, deviceID: deviceID)
        let names = try FileManager.default.contentsOfDirectory(atPath: folder.path).sorted()
        #expect(names.count == 2, "the snapshot and its key file — nothing else: \(names)")
        let snapshot = try #require(names.first { $0.hasSuffix(".sqlite") })
        #expect(names.contains(FileBackupsLeaf.pairURL(of: folder.appendingPathComponent(snapshot)).lastPathComponent))
        // The snapshot carried away by itself: it opens with its key alone and holds the library's record.
        let carried = slot.root.appendingPathComponent("carried/\(CatalogNames.libraryFilename)")
        try FileManager.default.createDirectory(at: carried.deletingLastPathComponent(), withIntermediateDirectories: true)
        try FileManager.default.copyItem(at: folder.appendingPathComponent(snapshot), to: carried)
        #expect(ProtectionLibraryFiles.opens(carried, key: k0))
        #expect(try ProtectionLibraryFiles.readRecord(at: carried, key: k0) == record)
        _ = live
    }

    // MARK: The catalogue's listing

    @Test func theListerWalksTheCopiesPlacesAndNeverHerExports() throws {
        let slot = TempSlot(withFarFolder: true)
        let file = try Self.keyFile(StoreKey.mint(), libraryID: UUID().uuidString.lowercased())
        try FileKeyFileStoreLeaf(places: slot.places).writeLiveKeyFile(file)
        let exports = slot.url("md-exports/2026-10-18")
        try FileManager.default.createDirectory(at: exports, withIntermediateDirectories: true)
        try file.encoded().write(to: exports.appendingPathComponent(ProtectionNames.keyFilename))
        let entries = CatalogLister(places: slot.places).entries()
        #expect(entries.contains { $0.place == .container && $0.folders.isEmpty && $0.name == ProtectionNames.keyFilename && $0.bytes != nil })
        #expect(!entries.contains { $0.folders.first == "md-exports" }, "her exports are not walked")
        #expect(CatalogLister(places: slot.places).catalog().liveKeyFile?.document == file)
    }
}
