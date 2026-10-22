//
//  SQLCipherLibraryLeaf.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1a — THE PRODUCTION `LibraryFileLeaf` (`Executor/Leaves.swift` is the contract) over the slot's
//  `variorum.sqlite`. Every SQLCipher statement is core's `ProtectionLibraryFiles` (beside the ONE keying
//  implementation); this leaf maps the protocol onto the slot's places and moves files. DUMB: it reads or
//  writes what it is told and decides nothing — every key it is handed verifies itself.
//
//  THE ROADS (`notes/plans/vx-306-castle-open-road.md` §2 U1a):
//    - `libraryOpens` — the read probe; `readRecord`/`writeRecord` — the thin keyed connection over
//      `protection_record` (never the migrator: the record is read before the app's open).
//    - `stageReencryption` — `sqlcipher_export` into `variorum.sqlite.staged` beside the slot; the marker
//      naming the staged key (`variorum.sqlite.staged-fingerprint`) is written LAST, so a marker means a
//      whole, verified staged file. `stageCopy` — the same from a PRIVATE byte copy of the catalogued copy
//      (13x's rule: a picked file is never written). `copyOpens` — a read probe on a private copy.
//    - `swapStaged` — refuses while a non-empty WAL sits beside the slot (it would replay into the incoming
//      file — the caller quiesces the library and the record's writes drain it); with `setAside`, the
//      outgoing library is HARD-LINKED into `Previous Libraries/<stamp>/` with its own key file before the
//      staged file replaces the slot by ONE atomic rename — so the slot is never empty at any instant, and a
//      crash leaves the old library or the new one (rule 20). THE CALLER CLOSES THE APP'S POOL ON THE SLOT
//      before a swap (the sidecars go, and an open connection must never see a file change under it) — the
//      act's door is U1b's / VX-307's; this leaf only refuses a WAL with frames in it.
//    - `slotIsOccupied` — the creation's no-clobber preflight (any file at the slot's path; VX-306 ladder r2 m3);
//      `createLibrary` — a fresh keyed file holding `protection_record` only (no clobber), then the
//      "a library lived here" marker (P-VX306-U1a-1); `exportPlaintext` — `StorePlaintextExport`.
//

import Foundation
import VariorumCore

nonisolated final class SQLCipherLibraryLeaf: LibraryFileLeaf, @unchecked Sendable {
    enum LibraryLeafError: Error, Equatable {
        case noStagedFile
        case stagedUnderAnotherKey
        /// A WAL with frames sits beside the outgoing library — the swap would replay it into the incoming
        /// one. Nothing was moved.
        case walNotDrained
        case copyNotFound(String)
        case asideFolderUnavailable
    }

    let places: ProtectionPlaces

    init(places: ProtectionPlaces) { self.places = places }

    static func fp(_ key: StoreKey) -> String { KeyFingerprint.of(key) }

    // MARK: - The live file

    func libraryOpens(with key: StoreKey) throws -> Bool { ProtectionLibraryFiles.opens(places.slot, key: key) }

    func readRecord(with key: StoreKey) throws -> ProtectionRecord? {
        try ProtectionLibraryFiles.readRecord(at: places.slot, key: key)
    }

    func writeRecord(_ record: ProtectionRecord, with key: StoreKey) throws {
        try ProtectionLibraryFiles.writeRecord(record, at: places.slot, key: key, date: Date())
    }

    // MARK: - Staging

    func stageReencryption(from key: StoreKey, to newKey: StoreKey) throws {
        try discardStaged()
        try ProtectionLibraryFiles.exportReencrypted(from: places.slot, key: key, to: places.staged, newKey: newKey)
        try writeStagedMarker(Self.fp(newKey))
    }

    func stageCopy(copyID: String, opener: StoreKey, to newKey: StoreKey) throws {
        try discardStaged()
        let staged = places.staged
        let scratch = places.scratch
        let done: Bool? = try places.withFile(catalogID: copyID) { url in
            guard FileManager.default.fileExists(atPath: url.path) else { return false }
            let copy = try ProtectionLibraryFiles.privateCopy(of: url, inside: scratch)
            defer { try? FileManager.default.removeItem(at: copy.deletingLastPathComponent()) }
            try ProtectionLibraryFiles.exportReencrypted(from: copy, key: opener, to: staged, newKey: newKey)
            return true
        }
        guard done == true else { throw LibraryLeafError.copyNotFound(copyID) }
        try writeStagedMarker(Self.fp(newKey))
    }

    func copyOpens(copyID: String, with key: StoreKey) throws -> Bool {
        let scratch = places.scratch
        let opens: Bool? = try places.withFile(catalogID: copyID) { url in
            guard FileManager.default.fileExists(atPath: url.path) else { return false }
            let copy = try ProtectionLibraryFiles.privateCopy(of: url, inside: scratch)
            defer { try? FileManager.default.removeItem(at: copy.deletingLastPathComponent()) }
            return ProtectionLibraryFiles.opens(copy, key: key)
        }
        return opens ?? false
    }

    func stagedFingerprint() throws -> String? {
        guard FileManager.default.fileExists(atPath: places.staged.path),
              let data = try? Data(contentsOf: places.stagedMarker),
              let text = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
              ProtectionNames.isFingerprint16(text)
        else { return nil }
        return text
    }

    func writeStagedRecord(_ record: ProtectionRecord, with newKey: StoreKey) throws {
        guard let staged = try stagedFingerprint() else { throw LibraryLeafError.noStagedFile }
        guard staged == Self.fp(newKey) else { throw LibraryLeafError.stagedUnderAnotherKey }
        try ProtectionLibraryFiles.writeRecord(record, at: places.staged, key: newKey, date: Date())
    }

    // MARK: - The swap

    func swapStaged(setAside: Bool, asideKeyFile: KeyFile?) throws {
        guard try stagedFingerprint() != nil else { throw LibraryLeafError.noStagedFile }
        let manager = FileManager.default
        let slot = places.slot
        guard ProtectionLibraryFiles.walIsDrained(at: slot) else { throw LibraryLeafError.walNotDrained }
        if setAside, manager.fileExists(atPath: slot.path) {
            let folder = try newAsideFolder()
            let aside = folder.appendingPathComponent(CatalogNames.libraryFilename)
            if link(slot.path, aside.path) != 0 { try manager.copyItem(at: slot, to: aside) }
            if let asideKeyFile {
                try asideKeyFile.encoded()
                    .write(to: folder.appendingPathComponent(ProtectionNames.keyFilename), options: .atomic)
            }
        }
        // The drained sidecars never sit beside the incoming file.
        for suffix in ProtectionLibraryFiles.sidecarSuffixes { try? manager.removeItem(atPath: slot.path + suffix) }
        for suffix in ProtectionLibraryFiles.sidecarSuffixes { try? manager.removeItem(atPath: places.staged.path + suffix) }
        guard rename(places.staged.path, slot.path) == 0 else {
            throw ProtectionLibraryFiles.FileError("the staged file could not replace the slot (errno \(errno))")
        }
        try? manager.removeItem(at: places.stagedMarker)
    }

    func discardStaged() throws {
        ProtectionLibraryFiles.removeWithSidecars(places.staged)
        try? FileManager.default.removeItem(at: places.stagedMarker)
    }

    // MARK: - Creating, exporting

    /// The creation's no-clobber preflight (VX-306 ladder round 2, m3) — the same fact the belt below checks
    /// (`ProtectionLibraryFiles.createLibrary`: any file at the slot's path), read before the act writes anything.
    func slotIsOccupied() throws -> Bool { FileManager.default.fileExists(atPath: places.slot.path) }

    func createLibrary(with key: StoreKey, record: ProtectionRecord) throws {
        try ProtectionLibraryFiles.createLibrary(at: places.slot, key: key, record: record, date: Date())
        try Data("A Variorum library lived here.\n".utf8).write(to: places.livedHereMarker, options: .atomic)
    }

    func exportPlaintext(with key: StoreKey, to destination: String) throws {
        let store = try AppDatabase.onDisk(url: places.slot, key: key)
        try StorePlaintextExport.export(from: store, to: URL(fileURLWithPath: destination))
    }

    // MARK: - Helpers

    private func writeStagedMarker(_ fingerprint: String) throws {
        try Data(fingerprint.utf8).write(to: places.stagedMarker, options: .atomic)
    }

    /// `Previous Libraries/<stamp>/`, a stamp no folder there has yet (the catalogue reads the stamp back
    /// exactly — `CatalogNames.stampString`).
    private func newAsideFolder() throws -> URL {
        let manager = FileManager.default
        var date = Date()
        for _ in 0..<120 {
            let folder = places.previousLibraries.appendingPathComponent(CatalogNames.stampString(date), isDirectory: true)
            if !manager.fileExists(atPath: folder.path) {
                try manager.createDirectory(at: folder, withIntermediateDirectories: true)
                return folder
            }
            date += 1
        }
        throw LibraryLeafError.asideFolderUnavailable
    }
}
