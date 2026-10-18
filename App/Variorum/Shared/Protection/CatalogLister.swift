//
//  CatalogLister.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1a — THE CATALOGUE'S LISTING (`notes/plans/vx-306-castle-open-road.md` §2 U1a; the catalogue
//  itself is core's pure `Catalog.build`, design §3.7). The facts gatherer's helper, not a leaf protocol:
//  it lists the two roots the catalogue reads —
//    - the CONTAINER (the slot's own folder): its files, `Backups/…` and `Previous Libraries/…` (the
//      safety copies live under `Backups/safety-copies/…`);
//    - the FAR folder (today's picked backup destination, resolved security-scoped): `Variorum/` and its
//      `Backups/…` —
//  as `CatalogEntry` values, every key file's bytes read (non-secret by design: wraps, salts, ids).
//  Today's flat backups and envelope files are listed like anything else and the catalogue refuses them by
//  name (rule 26 — `CatalogNames`); nothing here judges a name. The folders that are hers (`md-exports/`,
//  the hand-off folders) are not walked at all (P1: the listing's cost is the copies', never her exports).
//  A READ: nothing is written.
//

import Foundation
import VariorumCore

nonisolated struct CatalogLister: Sendable {
    let places: ProtectionPlaces

    /// The container folders walked to their depth; everything else at the root is listed, never walked.
    static let walkedContainerFolders = [CatalogNames.backupsFolderName, CatalogNames.previousLibrariesFolderName]
    static let walkedFarFolders = [CatalogNames.backupsFolderName]

    func catalog() -> Catalog { Catalog.build(entries()) }

    func entries() -> [CatalogEntry] {
        var entries = Self.list(root: places.container, place: .container, walking: Self.walkedContainerFolders)
        if let far = places.farFolder() {
            entries += far.withAccess { Self.list(root: $0, place: .farFolder, walking: Self.walkedFarFolders) }
        }
        return entries
    }

    /// The files directly under `root`, and every file below the named folders (their folder path relative
    /// to `root`). Hidden names are skipped.
    static func list(root: URL, place: CatalogPlace, walking folders: [String]) -> [CatalogEntry] {
        let manager = FileManager.default
        var entries: [CatalogEntry] = []
        let keys: [URLResourceKey] = [.isDirectoryKey, .contentModificationDateKey]
        guard let top = try? manager.contentsOfDirectory(
            at: root, includingPropertiesForKeys: keys, options: [.skipsHiddenFiles]) else { return [] }
        for url in top.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
            let values = try? url.resourceValues(forKeys: Set(keys))
            if values?.isDirectory == true {
                guard folders.contains(url.lastPathComponent) else { continue }
                entries += walk(url, under: [url.lastPathComponent], place: place)
            } else {
                entries.append(entry(url, place: place, folders: [], modifiedAt: values?.contentModificationDate))
            }
        }
        return entries
    }

    private static func walk(_ folder: URL, under path: [String], place: CatalogPlace) -> [CatalogEntry] {
        let keys: [URLResourceKey] = [.isDirectoryKey, .contentModificationDateKey]
        guard let children = try? FileManager.default.contentsOfDirectory(
            at: folder, includingPropertiesForKeys: keys, options: [.skipsHiddenFiles]) else { return [] }
        var entries: [CatalogEntry] = []
        for url in children.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
            let values = try? url.resourceValues(forKeys: Set(keys))
            if values?.isDirectory == true {
                entries += walk(url, under: path + [url.lastPathComponent], place: place)
            } else {
                entries.append(entry(url, place: place, folders: path, modifiedAt: values?.contentModificationDate))
            }
        }
        return entries
    }

    private static func entry(_ url: URL, place: CatalogPlace, folders: [String], modifiedAt: Date?) -> CatalogEntry {
        let name = url.lastPathComponent
        let isKeyFile = CatalogNames.parseFile(name)?.isKeyFile ?? false
        return CatalogEntry(
            place: place, folders: folders, name: name,
            bytes: isKeyFile ? (try? Data(contentsOf: url)) : nil, modifiedAt: modifiedAt)
    }
}
