//
//  ProtectionFacesSupport.swift
//  VariorumTests — VX-306 U2: planting helpers for THE HONEST FACES' suites (the new road over planted keychain leaves
//  and a temp slot with the real file leaves — `PlantedRoad`; no keychain, so the suites also run headless in the
//  implementer's SwiftPM harness): the container's bytes for a write-nothing comparison, a format-3 key file, a stray
//  beside the library, the library moved away and back.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

/// Planting helpers over `PlantedRoad`.
@MainActor
enum Plant {
    /// Every file this slot holds now (the container's top level), for a write-nothing comparison.
    static func containerBytes(_ road: PlantedRoad) throws -> [String: Data] {
        let container = road.slot.places.container
        var bytes: [String: Data] = [:]
        for name in try FileManager.default.contentsOfDirectory(atPath: container.path) {
            var isDirectory: ObjCBool = false
            let url = container.appendingPathComponent(name)
            guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory), !isDirectory.boolValue else { continue }
            bytes[name] = try Data(contentsOf: url)
        }
        return bytes
    }

    /// A format-3 key file for `key` of `libraryID`, locked under fresh words.
    static func keyFile(_ key: StoreKey, libraryID: String) throws -> KeyFile {
        try KeyFile.building(
            libraryID: libraryID, key: key, epoch: 1,
            locks: NewKeyLocks(words: try WordsKey.derive(try RecoveryPhrase.generate())))
    }

    /// The live key file replaced by a stray: another library's format-3 file.
    static func strayBeside(_ road: PlantedRoad) throws {
        let stray = try keyFile(StoreKey.mint(), libraryID: "another-library")
        try road.system().leaves.keyFiles.writeLiveKeyFile(stray)
    }

    /// The slot's library and its key file moved into `folder` (outside the container — out of the catalogue).
    static func moveLibraryAway(_ road: PlantedRoad, to folder: URL) throws {
        let manager = FileManager.default
        try manager.createDirectory(at: folder, withIntermediateDirectories: true)
        let places = road.slot.places
        try manager.moveItem(at: places.slot, to: folder.appendingPathComponent(CatalogNames.libraryFilename))
        if manager.fileExists(atPath: places.liveKeyFile.path) {
            try manager.moveItem(at: places.liveKeyFile, to: folder.appendingPathComponent(ProtectionNames.keyFilename))
        }
    }

    /// The library in `folder` moved back into the (empty) slot.
    static func moveLibraryBack(_ road: PlantedRoad, from folder: URL) throws {
        let manager = FileManager.default
        let places = road.slot.places
        try manager.moveItem(at: folder.appendingPathComponent(CatalogNames.libraryFilename), to: places.slot)
        let file = folder.appendingPathComponent(ProtectionNames.keyFilename)
        if manager.fileExists(atPath: file.path) { try manager.moveItem(at: file, to: places.liveKeyFile) }
    }
}
