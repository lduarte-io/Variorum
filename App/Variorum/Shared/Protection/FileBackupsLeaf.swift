//
//  FileBackupsLeaf.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1a — THE PRODUCTION `BackupsLeaf` (`Executor/Leaves.swift`): backup PAIRS — a consistent
//  snapshot under the library's own key (SQLite's backup API — the mechanism today's `StoreBackup` uses,
//  through core's `ProtectionLibraryFiles.snapshot`; `StoreBackup.swift` itself is untouched, VX-348's this
//  window) and its FROZEN key file beside it, written with it and never rewritten — in this Mac's
//  `Backups/<library8>/<mac8>/variorum-backup-<stamp>-<fp8>.sqlite` (+ `.keys.json`) in the container.
//  Today's flat `Backups/variorum-backup-<stamp>.sqlite` writer keeps running beside it (Release parity).
//
//  The far folder is not written here (P-VX306-U1a-4: the container pair is the catalogue's and the
//  doors' road this phase; today's second leg still copies its own flat files there). `pauseCopies` /
//  `resumeCopies` are an in-process flag (§3.7: copies pause from an act's prepare to its swap) that the
//  U1b hook on `StoreBackup.onRun` honours. Send Library's pair (VX-309's door) is minimal: the snapshot
//  and the live key file into the folder she picked.
//

import Foundation
import VariorumCore

nonisolated final class FileBackupsLeaf: BackupsLeaf, @unchecked Sendable {
    enum BackupsLeafError: Error, Equatable {
        /// Copies are paused (an act is between its prepare and its swap).
        case paused
        /// The key file is not the key's.
        case keyFileIsAnotherKeys
        case pairDidNotReadBack
        case noStampFree
    }

    let places: ProtectionPlaces
    private let lock = NSLock()
    private var paused = false

    init(places: ProtectionPlaces) { self.places = places }

    /// Whether copies are paused now (the U1b `StoreBackup.onRun` hook reads it).
    var copiesArePaused: Bool {
        lock.lock()
        defer { lock.unlock() }
        return paused
    }

    func pauseCopies() {
        lock.lock()
        paused = true
        lock.unlock()
    }

    func resumeCopies() {
        lock.lock()
        paused = false
        lock.unlock()
    }

    func takeBackupPair(with key: StoreKey, keyFile: KeyFile, deviceID: String) throws {
        guard !copiesArePaused else { throw BackupsLeafError.paused }
        let fingerprint = StoreKeyEnvelope.fingerprint(of: key)
        guard keyFile.fingerprint == fingerprint else { throw BackupsLeafError.keyFileIsAnotherKeys }
        let folder = places.backupFolder(libraryID: keyFile.libraryID, deviceID: deviceID)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let snapshot = try freeSnapshotName(in: folder, fingerprint: fingerprint)
        try ProtectionLibraryFiles.snapshot(of: places.slot, key: key, to: snapshot)
        let pair = Self.pairURL(of: snapshot)
        let bytes = try keyFile.encoded()
        try bytes.write(to: pair, options: .atomic)
        guard (try? KeyFile.decode(Data(contentsOf: pair))) == keyFile else { throw BackupsLeafError.pairDidNotReadBack }
    }

    func writeSendPair(with key: StoreKey, keyFile: KeyFile, to destination: String) throws {
        guard !copiesArePaused else { throw BackupsLeafError.paused }
        let folder = URL(fileURLWithPath: destination, isDirectory: true)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        try ProtectionLibraryFiles.snapshot(
            of: places.slot, key: key, to: folder.appendingPathComponent(CatalogNames.libraryFilename))
        try keyFile.encoded().write(to: folder.appendingPathComponent(ProtectionNames.keyFilename), options: .atomic)
    }

    func deleteCopies(ids: [String]) throws {
        for id in ids {
            _ = try places.withFile(catalogID: id) { url in
                let manager = FileManager.default
                if manager.fileExists(atPath: url.path) { try manager.removeItem(at: url) }
                for suffix in ProtectionLibraryFiles.sidecarSuffixes { try? manager.removeItem(atPath: url.path + suffix) }
                if case .snapshot? = CatalogNames.parseFile(url.lastPathComponent) {
                    let pair = Self.pairURL(of: url)
                    if manager.fileExists(atPath: pair.path) { try manager.removeItem(at: pair) }
                }
            }
        }
    }

    /// `<snapshot stem>.keys.json`.
    static func pairURL(of snapshot: URL) -> URL {
        snapshot.deletingPathExtension().appendingPathExtension("keys.json")
    }

    /// `variorum-backup-<stamp>-<fp8>.sqlite`, the first stamp from now no file in `folder` has.
    private func freeSnapshotName(in folder: URL, fingerprint: String) throws -> URL {
        var date = Date()
        for _ in 0..<120 {
            let name = CatalogNames.backupPrefix + CatalogNames.stampString(date) + "-"
                + StoreKeyEnvelope.shortFingerprint(fingerprint) + ".sqlite"
            let url = folder.appendingPathComponent(name)
            if !FileManager.default.fileExists(atPath: url.path) { return url }
            date += 1
        }
        throw BackupsLeafError.noStampFree
    }
}
