//
//  FileKeyFileStoreLeaf.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1a — THE PRODUCTION `KeyFileStoreLeaf` (`Executor/Leaves.swift` is the contract): THE live key
//  file beside the slot (`ProtectionNames.keyFilename`, format 3 only — rule 26), written atomically and
//  verified by a read-back; and `catalogedKeyFiles(ofLibrary:)` — every catalogued key file OUTSIDE the
//  live place whose own `libraryID` is this library's (the backups', this Mac's folders and the shared
//  ones, Previous Libraries' — Castle entry's belt, the gate's seed 3).
//
//  DUMB: reads or writes what it is told. A file in the live place that is not a format-3 key file THROWS
//  (`unreadableLiveKeyFile`) — never reported as absence, so no repair can write over what sits there
//  (rule 21: the mirror lands only in an EMPTY live place) — PROVISIONAL P-VX306-U1a-2.
//

import Foundation
import VariorumCore

nonisolated final class FileKeyFileStoreLeaf: KeyFileStoreLeaf, @unchecked Sendable {
    enum KeyFileStoreError: Error, Equatable {
        /// Something sits in the live place that this build does not read as a format-3 key file.
        case unreadableLiveKeyFile(String)
        /// The written file did not read back as written.
        case writeDidNotReadBack
    }

    let places: ProtectionPlaces
    let lister: CatalogLister

    init(places: ProtectionPlaces) {
        self.places = places
        lister = CatalogLister(places: places)
    }

    func readLiveKeyFile() throws -> KeyFile? {
        let url = places.liveKeyFile
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        let data = try Data(contentsOf: url)
        do {
            return try KeyFile.decode(data)
        } catch {
            throw KeyFileStoreError.unreadableLiveKeyFile(String(describing: error))
        }
    }

    func writeLiveKeyFile(_ file: KeyFile) throws {
        let url = places.liveKeyFile
        try FileManager.default.createDirectory(at: places.container, withIntermediateDirectories: true)
        try file.encoded().write(to: url, options: .atomic)
        guard (try? KeyFile.decode(Data(contentsOf: url))) == file else { throw KeyFileStoreError.writeDidNotReadBack }
    }

    func catalogedKeyFiles(ofLibrary libraryID: String) throws -> [KeyFile] {
        lister.catalog().keyFiles
            .filter { $0.role != .live }
            .compactMap(\.document)
            .filter { $0.libraryID == libraryID }
    }
}
