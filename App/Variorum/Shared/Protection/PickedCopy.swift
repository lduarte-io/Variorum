//
//  PickedCopy.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U3 — A PICKED THING ON THE NEW ROAD (`notes/plans/vx-306-castle-open-road.md` §2 U3 + its addendum; rules
//  17, 18). File ▸ Open Library… hands the new road a URL: an AirDropped pair or library folder is FILED FIRST — copied
//  whole into this Mac's `Backups/safety-copies/variorum-adopt-safety-<stamp>/` (PROVISIONAL P-VX306-U3-0 (a), the
//  orchestrator's ruling: the catalogue's `adoptionSafetyCopy` kind, this Mac's by place) — and the doors then act on
//  the catalogued copy. THE PICKED THING IS ONLY READ (13x's rule): the store and its non-empty `-wal` (never its
//  `-shm`) and the key file's bytes are COPIED, into a hidden staging folder first (the catalogue lists no hidden
//  name), then renamed into place whole — so a crash never leaves a half-filed copy the catalogue would list.
//
//  WHAT IS A PAIR (this design's names — `CatalogNames`, never restated): a store (`variorum.sqlite`, or a backup's
//  `variorum-backup-<stamp>[-<fp8>].sqlite`) with a FORMAT-3 key file beside it — the backup's own `<stem>.keys.json`,
//  or the library folder's `variorum-library-keys.json` (Send Library's pair writes exactly that). A picked folder
//  holding one such store is that pair; several are offered, never guessed.
//
//  EVERYTHING ELSE keeps today's classifier for its honest words (`LibraryClassifier`), with two new-road readings:
//    - a plain-text export or library — its landing (T-8) is VX-309's; today's adoption road would land a library the
//      new road cannot open and leave the live key file behind (rule 1 — traced in the U3 record), so the new road
//      says it isn't ready yet (PROVISIONAL P-VX306-U3-5);
//    - an encrypted copy whose key file is TODAY's format — rule 26: a copy from before this design is not handled
//      (no sentence names it), so the honest minimum: today's "couldn't be read as a library" (P-VX306-U3-6).
//

import Foundation
import VariorumCore

nonisolated enum PickedCopy {
    /// A store and the format-3 key file beside it.
    struct Pair: Equatable, Sendable {
        let store: URL
        let keyFile: URL
        let document: KeyFile
    }

    enum Verdict: Equatable, Sendable {
        case pair(Pair)
        /// A folder holding several stores with key files of this design.
        case several([URL])
        case refused(String, detail: String?)
    }

    enum FilingError: Error, Equatable {
        /// The key file changed between the classification and the filing.
        case keyFileChanged
        /// The filed store did not come out the size of the picked one.
        case storeDidNotCopyWhole
        case noStampFree
    }

    // MARK: - Classify (keyless — reads only)

    static func classify(_ url: URL) -> Verdict {
        let manager = FileManager.default
        var isDirectory: ObjCBool = false
        guard manager.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            return .refused(LibraryOpenCopy.notAVariorumStoreRefusal, detail: nil)
        }
        if isDirectory.boolValue {
            let names = ((try? manager.contentsOfDirectory(atPath: url.path)) ?? []).sorted()
            var pairs: [Pair] = []
            var newer: String?
            for name in names where isStoreName(name) {
                switch keyFile(for: url.appendingPathComponent(name, isDirectory: false)) {
                case .found(let pair): pairs.append(pair)
                case .newer(let detail): newer = detail
                case .none: break
                }
            }
            if pairs.count == 1 { return .pair(pairs[0]) }
            if pairs.count > 1 { return .several(pairs.map(\.store)) }
            if let newer { return .refused(LibraryOpenCopy.newerSchemaRefusal, detail: newer) }
            return todaysWords(url)
        }
        switch keyFile(for: url) {
        case .found(let pair): return .pair(pair)
        case .newer(let detail): return .refused(LibraryOpenCopy.newerSchemaRefusal, detail: detail)
        case .none: return todaysWords(url)
        }
    }

    /// A name this design writes for a store (`variorum.sqlite`, a backup snapshot).
    static func isStoreName(_ name: String) -> Bool {
        switch CatalogNames.parseFile(name) {
        case .library?, .snapshot?: return true
        default: return false
        }
    }

    enum KeyFileLookup: Equatable {
        case found(Pair)
        /// A key file of a NEWER format — written by a newer Variorum.
        case newer(String)
        case none
    }

    /// The format-3 key file that serves `store`: its own `<stem>.keys.json` (a backup pair), else the folder's
    /// `variorum-library-keys.json` (a library folder). A file of another format is not this design's (rule 26).
    static func keyFile(for store: URL) -> KeyFileLookup {
        guard store.pathExtension == "sqlite" else { return .none }
        let folder = store.deletingLastPathComponent()
        let candidates = [
            store.deletingPathExtension().appendingPathExtension("keys.json"),
            folder.appendingPathComponent(ProtectionNames.keyFilename, isDirectory: false),
        ]
        for candidate in candidates where FileManager.default.fileExists(atPath: candidate.path) {
            guard let data = try? Data(contentsOf: candidate) else { continue }
            do {
                return .found(Pair(store: store, keyFile: candidate, document: try KeyFile.decode(data)))
            } catch KeyFileError.newerFormat(let version) {
                return .newer("key file format \(version)")
            } catch {
                continue
            }
        }
        return .none
    }

    /// Today's classifier, for the honest words of a thing that is not this design's pair.
    static func todaysWords(_ url: URL) -> Verdict {
        switch LibraryClassifier.classify(at: url) {
        case .plaintextExport, .plaintextLibrary:
            return .refused(ProtectionWords.plaintextCopyNotYet, detail: nil)
        case .encryptedLibrary, .snapshotPair, .folderHoldingPair, .folderHoldingStores:
            return .refused(ProtectionWords.pickedCopyUnreadable, detail: nil)
        case .bareStoreWithoutKeyFile:
            return .refused(LibraryOpenCopy.bareStoreRefusal, detail: nil)
        case .newerSchema(_, let unknown):
            return .refused(LibraryOpenCopy.newerSchemaRefusal, detail: unknown.isEmpty ? nil : unknown.joined(separator: " · "))
        case .notAVariorumStore:
            return .refused(LibraryOpenCopy.notAVariorumStoreRefusal, detail: nil)
        case .unreadable(_, let reason):
            return .refused(LibraryOpenCopy.unreadableRefusal, detail: reason)
        }
    }

    // MARK: - File (the picked thing only read)

    /// The pair filed into `places`' `Backups/safety-copies/variorum-adopt-safety-<stamp>/` as `variorum.sqlite` (+ its
    /// non-empty `-wal`) and `variorum-library-keys.json` — the catalogue's names — staged hidden, then renamed in
    /// whole. Returns the filed folder.
    @discardableResult
    static func file(_ pair: Pair, places: ProtectionPlaces, now: Date) throws -> URL {
        let manager = FileManager.default
        let home = places.backups.appendingPathComponent(CatalogNames.safetyCopiesFolderName, isDirectory: true)
        try manager.createDirectory(at: home, withIntermediateDirectories: true)
        let staging = home.appendingPathComponent(".filing-\(UUID().uuidString)", isDirectory: true)
        try manager.createDirectory(at: staging, withIntermediateDirectories: false)
        defer { try? manager.removeItem(at: staging) }
        let store = staging.appendingPathComponent(CatalogNames.libraryFilename, isDirectory: false)
        try manager.copyItem(at: pair.store, to: store)
        let wal = URL(fileURLWithPath: pair.store.path + "-wal")
        if let size = try? manager.attributesOfItem(atPath: wal.path)[.size] as? Int, size > 0 {
            try manager.copyItem(at: wal, to: URL(fileURLWithPath: store.path + "-wal"))
        }
        // A copy keeps the picked file's mode and flags; ours is owner read-write (and never Finder-locked).
        try? manager.setAttributes([.immutable: false, .posixPermissions: 0o600], ofItemAtPath: store.path)
        let source = (try? manager.attributesOfItem(atPath: pair.store.path)[.size] as? Int) ?? -1
        let filed = (try? manager.attributesOfItem(atPath: store.path)[.size] as? Int) ?? -2
        guard source == filed else { throw FilingError.storeDidNotCopyWhole }
        let bytes = try Data(contentsOf: pair.keyFile)
        guard (try? KeyFile.decode(bytes)) == pair.document else { throw FilingError.keyFileChanged }
        try bytes.write(
            to: staging.appendingPathComponent(ProtectionNames.keyFilename, isDirectory: false), options: .atomic)
        var date = now
        for _ in 0..<120 {
            let folder = home.appendingPathComponent(
                CatalogNames.adoptionSafetyPrefix + CatalogNames.stampString(date), isDirectory: true)
            if !manager.fileExists(atPath: folder.path) {
                try manager.moveItem(at: staging, to: folder)
                return folder
            }
            date += 1
        }
        throw FilingError.noStampFree
    }

    /// The catalogue id of the store filed in `folder` (an adoption safety copy).
    static func filedCopyID(_ folder: URL) -> String {
        CatalogEntry(
            place: .container,
            folders: [CatalogNames.backupsFolderName, CatalogNames.safetyCopiesFolderName, folder.lastPathComponent],
            name: CatalogNames.libraryFilename).id
    }
}
