//
//  ProtectionPlaces.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1a — WHERE THE PROTECTION CORE'S FILES LIVE (`notes/plans/vx-306-castle-open-road.md` §2 U1a;
//  design §3.2's homes column; the names are core's `ProtectionNames` / `CatalogNames`, never restated).
//  One value per slot: the library file, and beside it (the CONTAINER — the slot's own folder) the live key
//  file, the plan, the staged file and its marker, "a library lived here", `Backups/<library8>/<mac8>/`
//  and `Previous Libraries/<stamp>/`; and the FAR folder — today's picked backup destination's
//  `Variorum/` (`BackupDestination`), resolved security-scoped per use. A catalogue id ("container:<path>"
//  / "farFolder:<path>", `Catalog.id`) resolves back to its file here.
//
//  Pure paths: nothing here reads or writes a file.
//

import Foundation
import VariorumCore

/// The far folder for one use — `<picked>/Variorum/`, the security scope claimed around `body`.
nonisolated struct ProtectionFarFolder: Sendable {
    /// The folder she picked (the scope is claimed on it).
    let picked: URL
    /// Whether the scope must be claimed (a security-scoped bookmark — production); tests pass false.
    let scoped: Bool

    /// `<picked>/Variorum` — the catalogue's far root.
    var variorum: URL { picked.appendingPathComponent(CatalogNames.variorumFolderName, isDirectory: true) }

    func withAccess<T>(_ body: (URL) throws -> T) rethrows -> T {
        guard scoped else { return try body(variorum) }
        let claimed = picked.startAccessingSecurityScopedResource()
        defer { if claimed { picked.stopAccessingSecurityScopedResource() } }
        return try body(variorum)
    }
}

nonisolated struct ProtectionPlaces: Sendable {
    /// The library file — `<container>/variorum.sqlite`.
    let slot: URL
    /// The far folder, resolved at each use (nil: none picked, or out of reach now).
    let farFolder: @Sendable () -> ProtectionFarFolder?
    /// Where private byte copies of catalogued files are made for a probe or a stage (never beside them).
    let scratch: URL

    init(
        slot: URL, farFolder: @escaping @Sendable () -> ProtectionFarFolder? = { nil },
        scratch: URL = FileManager.default.temporaryDirectory.appendingPathComponent("variorum-protection", isDirectory: true)
    ) {
        self.slot = slot
        self.farFolder = farFolder
        self.scratch = scratch
    }

    /// The slot's own folder — the catalogue's container root.
    var container: URL { slot.deletingLastPathComponent() }
    var liveKeyFile: URL { container.appendingPathComponent(ProtectionNames.keyFilename) }
    var plan: URL { container.appendingPathComponent(ProtectionNames.planFilename) }
    /// The export-and-swap's staged file, and the marker naming the key it is under (written last).
    var staged: URL { URL(fileURLWithPath: slot.path + ".staged") }
    var stagedMarker: URL { URL(fileURLWithPath: slot.path + ".staged-fingerprint") }
    /// "A library lived here" (design §3.2) — written when a library is created in the slot.
    var livedHereMarker: URL { container.appendingPathComponent(Self.livedHereMarkerName) }
    static let livedHereMarkerName = "variorum-library-lived-here"
    var backups: URL { container.appendingPathComponent(CatalogNames.backupsFolderName, isDirectory: true) }
    var previousLibraries: URL {
        container.appendingPathComponent(CatalogNames.previousLibrariesFolderName, isDirectory: true)
    }

    /// `Backups/<library8>/<mac8>/` in the container (this Mac's copies of a library).
    func backupFolder(libraryID: String, deviceID: String) -> URL {
        container.appendingPathComponent(
            ProtectionNames.backupsSubpath(libraryID: libraryID, deviceID: deviceID), isDirectory: true)
    }

    /// A catalogue id back to its file, with the far folder's scope claimed around `body` (nil: an id no
    /// place here names, or the far folder out of reach now).
    func withFile<T>(catalogID id: String, _ body: (URL) throws -> T) rethrows -> T? {
        let containerPrefix = CatalogPlace.container.rawValue + ":"
        let farPrefix = CatalogPlace.farFolder.rawValue + ":"
        if id.hasPrefix(containerPrefix) {
            let path = String(id.dropFirst(containerPrefix.count))
            guard Self.isRelativeInside(path) else { return nil }
            return try body(container.appendingPathComponent(path))
        }
        if id.hasPrefix(farPrefix), let far = farFolder() {
            let path = String(id.dropFirst(farPrefix.count))
            guard Self.isRelativeInside(path) else { return nil }
            return try far.withAccess { try body($0.appendingPathComponent(path)) }
        }
        return nil
    }

    /// A catalogue path never climbs out of its root.
    static func isRelativeInside(_ path: String) -> Bool {
        !path.isEmpty && !path.hasPrefix("/") && !path.split(separator: "/").contains("..")
    }
}
