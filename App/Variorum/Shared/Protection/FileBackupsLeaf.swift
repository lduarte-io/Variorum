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
//  VX-309 U1a — THE FAR PAIR (P-VX306-U1a-4's deferral comes due): `landFarPair` copies a container pair
//  this leaf just wrote, both files under their own names, into the picked folder's `Variorum/Backups/
//  <library8>/<mac8>/` — one backup in two places, the files' mechanics only (whether the far folder is DUE is
//  the pair road's decision, `ProtectionBackupHook.takePair`; today's second leg still copies its own flat
//  files there, untouched). `pauseCopies` / `resumeCopies` are an in-process flag (§3.7: copies pause from an
//  act's prepare to its swap) that the U1b hook on `StoreBackup.onRun` honours. Send Library's pair (VX-309's
//  door) is minimal: the snapshot and the live key file into the folder she picked.
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
        /// VX-309 U1a: the picked folder is not there now (deleted, a drive's mount point gone) — never re-made.
        case pickedFolderGone
        /// A pair of that name is already in the far folder — a pair is written once, never rewritten.
        case farPairExists
        /// The far copy did not read back as the pair it copies.
        case farPairDidNotVerify
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
        _ = try writeContainerPair(with: key, keyFile: keyFile, deviceID: deviceID)
    }

    /// The container pair — `takeBackupPair`'s body, unchanged, now returning the snapshot it wrote (VX-309 U1a: the pair
    /// road hands THIS pair to the far leg, never one re-discovered by listing — 18k C7's rule).
    func writeContainerPair(with key: StoreKey, keyFile: KeyFile, deviceID: String) throws -> URL {
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
        return snapshot
    }

    /// **VX-309 U1a — THE FAR PAIR**: the container pair at `snapshot` (this leaf's own, just written) copied, both files
    /// under their own names, into the picked folder's `Variorum/Backups/<library8>/<mac8>/` with its security scope
    /// claimed — written once (a name already there is refused, never overwritten) and verified (the key file reads back
    /// as `keyFile`; the snapshot opens with `key`); a copy that fails part-way is removed, so no orphan snapshot is left
    /// outside every count and every prune. Returns the far snapshot's catalogue id; nil when no far folder is picked or
    /// its bookmark does not resolve now. Throws: copies paused, another key's file, the picked folder gone (never
    /// re-made), a pair of that name there, a copy that does not verify.
    func landFarPair(copying snapshot: URL, key: StoreKey, keyFile: KeyFile, deviceID: String) throws -> String? {
        guard !copiesArePaused else { throw BackupsLeafError.paused }
        guard keyFile.fingerprint == StoreKeyEnvelope.fingerprint(of: key) else { throw BackupsLeafError.keyFileIsAnotherKeys }
        guard let far = places.farFolder() else { return nil }
        let subpath = ProtectionNames.backupsSubpath(libraryID: keyFile.libraryID, deviceID: deviceID)
        return try far.withAccess { root in
            let manager = FileManager.default
            var isFolder: ObjCBool = false
            guard manager.fileExists(atPath: far.picked.path, isDirectory: &isFolder), isFolder.boolValue else {
                throw BackupsLeafError.pickedFolderGone
            }
            let folder = root.appendingPathComponent(subpath, isDirectory: true)
            try manager.createDirectory(at: folder, withIntermediateDirectories: true)
            let destination = folder.appendingPathComponent(snapshot.lastPathComponent)
            let pair = Self.pairURL(of: destination)
            guard !manager.fileExists(atPath: destination.path), !manager.fileExists(atPath: pair.path) else {
                throw BackupsLeafError.farPairExists
            }
            do {
                try manager.copyItem(at: snapshot, to: destination)
                try manager.copyItem(at: Self.pairURL(of: snapshot), to: pair)
                guard (try? KeyFile.decode(Data(contentsOf: pair))) == keyFile,
                      ProtectionLibraryFiles.opens(destination, key: key) else {
                    throw BackupsLeafError.farPairDidNotVerify
                }
            } catch {
                ProtectionLibraryFiles.removeWithSidecars(destination)
                try? manager.removeItem(at: pair)
                throw error
            }
            return CatalogEntry(
                place: .farFolder, folders: subpath.split(separator: "/").map(String.init),
                name: destination.lastPathComponent
            ).id
        }
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
