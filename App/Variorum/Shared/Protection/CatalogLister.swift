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
//  VX-1013 (`notes/plans/fixes/vx-1013-open-far-folder-wait.md`, D-1013-2 and D-1013-5) — THE OPEN NEVER WAITS ON A
//  FOLDER OUTSIDE THE LIBRARY. The far folder is hers to pick and is commonly iCloud-synced: a cold or evicted folder
//  blocks every small key-file read, and the launch road used to walk both roots on the order of ten times before the
//  first frame. So a listing has a SCOPE — `.everything` (today's, the default for every caller) or `.containerOnly`
//  (the far folder, when one is picked, marked UNREAD in `Catalog.unreadPlaces`, never read) — and a facts read takes
//  its catalogue from the caller as a `CatalogRead`: `.everything`, or `.thisOpen(walk)` — the container listed at the
//  read and the far folder as THIS OPEN's one walk (`FarFolderWalk`) has it. Only the launch road reads `.thisOpen`.
//

import Foundation
import VariorumCore

nonisolated struct CatalogLister: Sendable {
    let places: ProtectionPlaces

    /// The container folders walked to their depth; everything else at the root is listed, never walked.
    static let walkedContainerFolders = [CatalogNames.backupsFolderName, CatalogNames.previousLibrariesFolderName]
    static let walkedFarFolders = [CatalogNames.backupsFolderName]

    /// VX-1013 (D-1013-2) — what one listing reads.
    enum Scope: Sendable {
        /// Both roots, walked now — today's, and the default everywhere.
        case everything
        /// The container alone; the far folder, when one is picked, is marked UNREAD and never read (resolving the
        /// picked folder's bookmark reads no folder).
        case containerOnly
    }

    func catalog() -> Catalog { catalog(scope: .everything) }

    func catalog(scope: Scope) -> Catalog {
        switch scope {
        case .everything:
            return Catalog.build(entries())
        case .containerOnly:
            return Catalog.build(containerEntries(), unreadPlaces: places.farFolder() == nil ? [] : [.farFolder])
        }
    }

    /// VX-1013 (D-1013-2/-5) — the catalogue a facts read takes from its caller: both roots now, or the container now
    /// over this open's one far-folder walk.
    func catalog(_ read: CatalogRead) -> Catalog {
        switch read {
        case .everything: return catalog()
        case .thisOpen(let far): return far.catalog(over: containerEntries())
        }
    }

    func entries() -> [CatalogEntry] {
        containerEntries() + (places.farFolder().map(Self.farEntries) ?? [])
    }

    /// The container's listing alone — local disk, this Mac's own folder.
    func containerEntries() -> [CatalogEntry] {
        Self.list(root: places.container, place: .container, walking: Self.walkedContainerFolders)
    }

    /// The far folder's listing, its security scope claimed around the walk (every key file's bytes read).
    static func farEntries(_ far: ProtectionFarFolder) -> [CatalogEntry] {
        far.withAccess { list(root: $0, place: .farFolder, walking: walkedFarFolders) }
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

/// **VX-1013 (D-1013-2) — THE CATALOGUE STATE A FACTS READ TAKES FROM ITS CALLER.** `.everything` is today's and the
/// default for every caller — the copy doors, the copy counts, the backup hook and pair, the crossing and account acts,
/// Data Safety, a face's door, the relock's lobby — so all of them read byte-identically. Only the launch road's reads
/// (`ProtectionOpenRoad` over a `RoadContext` whose `far` the bootstrap's open made) take `.thisOpen`.
nonisolated enum CatalogRead: Sendable {
    /// Both roots, walked at the read.
    case everything
    /// The container walked at the read; the far folder as this open's one walk has it — landed ⇒ its entries, not yet
    /// ⇒ the place UNREAD (`Catalog.unreadPlaces`), none picked ⇒ nothing to read.
    case thisOpen(FarFolderWalk)

    /// **The custody probe's scope.** The Keychain custody leaf finds Touch ID items BY NAME, probing every fingerprint
    /// this device knows of (`ProtectionSystem.touchIDCandidates` — the catalogued key files', the memory items', the
    /// plan's, the staged key's), and every custody listing runs that probe — the gatherer's and the executor's own (a
    /// repair that lists custody, a settle's plan runner). The probe reads the catalogue under THIS value: `.everything`
    /// unless a launch-road body set it (`ProtectionOpenRoad`'s route, its presses and the far landing), so no custody
    /// listing inside an open walks the far folder before its walk lands. While the far folder is unread the probe names
    /// the container's, the memory items', the plan's and the staged fingerprints — the current key's item is always
    /// named by those (the live key file, the memory item); a far-only fingerprint's Touch ID item is listed once the
    /// walk has landed.
    @TaskLocal static var probing: CatalogRead = .everything
}

/// **VX-1013 (D-1013-5) — THIS OPEN'S ONE FAR-FOLDER WALK.** Made by the bootstrap at each open (`beginOpening`) and
/// carried by the launch road's `RoadContext`: every facts read in that open composes a fresh container listing (the
/// open's repairs change it) over this one shared far listing. The far folder is resolved at most once per open (a
/// bookmark's resolution — no folder is read) and WALKED at most once, detached at a low priority, only when something
/// asks: the lobby (`ProtectionOpenRoad.route` begins it when it draws), or a press that would otherwise refuse (it joins
/// the walk). An open that goes straight on (`.opened`, `.created`) never walks it.
nonisolated final class FarFolderWalk: @unchecked Sendable {
    private let places: ProtectionPlaces
    private let lock = NSLock()
    /// nil: not resolved yet; `.some(nil)`: no far folder picked (or out of reach) for this open.
    private var resolved: ProtectionFarFolder??
    private var walk: Task<[CatalogEntry], Never>?
    private var landedEntries: [CatalogEntry]?

    init(places: ProtectionPlaces) { self.places = places }

    /// What this open knows of the far folder now.
    enum Standing: Sendable {
        /// None picked (or out of reach): nothing to read — a container listing is a whole listing.
        case noFarFolder
        /// Picked, its entries not in hand (the walk not begun, or still running).
        case unread
        /// The one walk landed.
        case read([CatalogEntry])
    }

    var standing: Standing {
        if let entries = lock.withLock({ landedEntries }) { return .read(entries) }
        return farFolder == nil ? .noFarFolder : .unread
    }

    /// A far folder is picked and its entries are not in hand.
    var isUnread: Bool {
        if case .unread = standing { return true }
        return false
    }

    /// The walk has been begun (by the lobby or a press) — read without resolving anything.
    var hasBegun: Bool { lock.withLock { walk != nil } }

    /// The catalogue over `container`: the far folder's entries when the walk landed; the far folder UNREAD while it is
    /// picked and not yet read; the container alone when none is picked.
    func catalog(over container: [CatalogEntry]) -> Catalog {
        switch standing {
        case .read(let far): return Catalog.build(container + far)
        case .unread: return Catalog.build(container, unreadPlaces: [.farFolder])
        case .noFarFolder: return Catalog.build(container)
        }
    }

    /// Begin the walk — detached, at a low priority — when it is owed and not begun. Returns at once.
    func begin() { _ = theWalk() }

    /// JOIN the walk (beginning it when it is owed): the far folder's entries, read once for this open; nothing when none
    /// is picked.
    @discardableResult
    func read() async -> [CatalogEntry] {
        if case .read(let entries) = standing { return entries }
        guard let walk = theWalk() else { return [] }
        return await walk.value
    }

    private var farFolder: ProtectionFarFolder? {
        if let known = lock.withLock({ resolved }) { return known }
        let now = places.farFolder()
        return lock.withLock {
            if let known = resolved { return known }
            resolved = .some(now)
            return now
        }
    }

    private func theWalk() -> Task<[CatalogEntry], Never>? {
        guard let far = farFolder else { return nil }
        return lock.withLock {
            if let walk { return walk }
            ProtectionOpenRoad.log("road: the far folder's one walk for this open begins (off the launch path)")
            let begun = Date()
            let walk = Task.detached(priority: .utility) { [weak self] () -> [CatalogEntry] in
                let entries = CatalogLister.farEntries(far)
                self?.land(entries)
                let ms = Int(Date().timeIntervalSince(begun) * 1000)
                ProtectionOpenRoad.log("road: the far folder's walk landed — \(entries.count) entries in \(ms) ms")
                return entries
            }
            self.walk = walk
            return walk
        }
    }

    private func land(_ entries: [CatalogEntry]) { lock.withLock { landedEntries = entries } }
}
