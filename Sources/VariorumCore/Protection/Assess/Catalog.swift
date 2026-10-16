import Foundation

// VX-305 U2 — THE CATALOG (design §3.7, VX-302): one place that knows every
// place copies live — and, since VX-378 U1, only the folders THIS design writes
// (rule 19; rule 26 took today's flat files and folder key files):
//   - the container's backups (`Backups/<library8>/<mac8>/`),
//   - the far folder (`<picked>/Variorum/Backups/<library8>/<mac8>/`),
//   - `Previous Libraries/<stamp>/`,
//   - the adoption safety copies (`Backups/safety-copies/variorum-adopt-
//     safety-<stamp>/`),
//   - the `.stale-*` key files beside the slot —
// with ONE name parser (`CatalogNames`) and an attribution of every copy to
// its LIBRARY (from the pair's key file) and its MAC (from the subfolder).
// The restore list, Open Library, the Castle offer, retention and the route
// finder all read it.
//
// Pure: the leaf lists the two roots and reads every key file's bytes; this
// builds the catalog from that listing and touches nothing. Key-file bytes
// are non-secret by design (wraps, salts, ids), so the catalog holds them
// decoded.

/// The two roots a listing is taken under.
public enum CatalogPlace: String, Codable, Sendable, CaseIterable {
    /// The folder the slot lives in, in this Mac's own container: the slot's
    /// key files, `Backups/…` and `Previous Libraries/…`.
    case container
    /// The picked far folder's `Variorum/` (its `Backups/…` and the folder
    /// key files today's builds write beside them).
    case farFolder
}

/// One file the leaf listed: its root, the folders below the root, its
/// name, and — for every name `CatalogNames.parseFile` calls a key file —
/// its bytes (nil when it could not be read) and its modification date
/// (today's `StoreKeyEnvelope.locate` rule picks the newest of several).
public struct CatalogEntry: Equatable, Sendable {
    public var place: CatalogPlace
    public var folders: [String]
    public var name: String
    public var bytes: Data?
    public var modifiedAt: Date?

    public init(place: CatalogPlace, folders: [String] = [], name: String, bytes: Data? = nil, modifiedAt: Date? = nil) {
        self.place = place
        self.folders = folders
        self.name = name
        self.bytes = bytes
        self.modifiedAt = modifiedAt
    }

    public var id: String { Catalog.id(place: place, folders: folders, name: name) }
}

/// Which Mac a copy or key file belongs to.
public enum MacAttribution: Equatable, Hashable, Sendable {
    /// From its `Backups/<library8>/<mac8>/` subfolder.
    case mac8(String)
    /// In this Mac's own container but outside a Mac subfolder —
    /// `Previous Libraries/`, the safety copies, the slot's own key files:
    /// this Mac's by their place (the container is per Mac and per login).
    case thisMacsContainer
    /// In the far folder outside a Mac subfolder — any Mac sharing the
    /// folder could have written it (VX-302's shared iCloud Drive folder).
    case unattributed

    /// Is this `mac8`'s? A container copy outside a subfolder is this Mac's
    /// by place; an unattributed far copy is never claimed.
    public func isMac(_ mac8: String) -> Bool {
        switch self {
        case .mac8(let other): return other == mac8.lowercased()
        case .thisMacsContainer: return true
        case .unattributed: return false
        }
    }
}

public enum CopyKind: String, Codable, Sendable, CaseIterable {
    /// A snapshot pair in `Backups/<library8>/<mac8>/`.
    case backup
    /// `Previous Libraries/<stamp>/` — a library an adoption set aside.
    case previousLibrary
    /// `Backups/safety-copies/variorum-adopt-safety-<stamp>/`.
    case adoptionSafetyCopy
}

public enum KeyFileRole: String, Codable, Sendable, CaseIterable {
    /// `variorum-library-keys.json` beside the slot — the live key file.
    case live
    /// A `.stale-*` key file beside the slot (the set-aside shape).
    case setAside
    /// A snapshot's own key file (`<snapshot>.keys.json`).
    case snapshotPair
    /// A key file inside a `Previous Libraries` or safety-copy folder.
    case asideCopy
}

public struct CatalogKeyFile: Equatable, Sendable, Identifiable {
    public var id: String
    public var place: CatalogPlace
    public var folders: [String]
    public var name: String
    public var role: KeyFileRole
    /// The decoded file; nil when it could not be read or decoded (a format
    /// other than 3 included — rule 26).
    public var document: KeyFile?
    public var mac: MacAttribution

    /// The library it belongs to (its `libraryID`).
    public var library: String? { document?.libraryID }
    /// Its current key's fingerprint.
    public var fingerprint: String? { document?.fingerprint }
    /// Every fingerprint it leads to without a secret — current and history.
    public var heldFingerprints: [String] { document?.heldFingerprints ?? [] }
    /// The day the file was frozen, when its place says (a snapshot pair's
    /// stamp; a set-aside file's epoch; an aside folder's stamp).
    public var frozenAt: Date?
    /// Its modification date, as listed.
    public var modifiedAt: Date?
}

public struct CatalogCopy: Equatable, Sendable, Identifiable {
    public var id: String
    public var place: CatalogPlace
    public var folders: [String]
    public var name: String
    public var kind: CopyKind
    /// The stamp its name or folder carries.
    public var stamp: Date?
    /// The fp8 a snapshot's name carries.
    public var nameFingerprint8: String?
    /// The key files that serve it, best first (ids into `Catalog.keyFiles`)
    /// — today's pair rules, restated.
    public var servingKeyFiles: [String]
    /// The key it is under, when the catalog can tell keylessly: its own
    /// pair's (or its folder's only) key file's current key.
    public var fingerprint: String?
    /// When it can't (several key files beside an aside copy), every key it
    /// could be under.
    public var candidateFingerprints: [String]
    /// The library it belongs to, from the serving key files (nil when none
    /// reads, or they name different libraries).
    public var library: String?
    public var mac: MacAttribution
}

/// A name in a copy's place that no build writes — listed, never touched.
public struct CatalogForeignEntry: Equatable, Sendable {
    public var place: CatalogPlace
    public var folders: [String]
    public var name: String
}

public struct Catalog: Equatable, Sendable {
    public var copies: [CatalogCopy]
    public var keyFiles: [CatalogKeyFile]
    public var foreign: [CatalogForeignEntry]

    public init(copies: [CatalogCopy] = [], keyFiles: [CatalogKeyFile] = [], foreign: [CatalogForeignEntry] = []) {
        self.copies = copies
        self.keyFiles = keyFiles
        self.foreign = foreign
    }

    static func id(place: CatalogPlace, folders: [String], name: String) -> String {
        "\(place.rawValue):" + (folders + [name]).joined(separator: "/")
    }

    // MARK: - Reading

    public func keyFile(id: String) -> CatalogKeyFile? { keyFiles.first { $0.id == id } }

    public func servingKeyFiles(of copy: CatalogCopy) -> [CatalogKeyFile] {
        copy.servingKeyFiles.compactMap { keyFile(id: $0) }
    }

    /// The live key file beside the slot, if one is listed.
    public var liveKeyFile: CatalogKeyFile? { keyFiles.first { $0.role == .live } }

    /// Every key file that leads to `fingerprint` (current or history) —
    /// "any key file the catalog knows that holds K" (§3.7).
    public func keyFiles(holding fingerprint: String) -> [CatalogKeyFile] {
        keyFiles.filter { $0.heldFingerprints.contains(fingerprint) }
    }

    public func copies(ofLibrary libraryID: String) -> [CatalogCopy] {
        copies.filter { $0.library == libraryID }
    }

    // MARK: - Building

    /// Where an entry sits, from its parsed folders.
    enum Location: Equatable {
        case besideLibrary
        case macFolder(library8: String, mac8: String)
        case adoptionSafety(stamp: Date)
        case previousLibrary(stamp: Date)
        /// A home of copies that holds none of the app's own files directly
        /// (`Variorum/` and `Backups/` themselves, `Backups/<library8>/`,
        /// `Backups/safety-copies/` — where the A1 rail keeps its copies):
        /// every file there is foreign (rule 26 took today's flat files).
        case copyHome
        /// Hers, not a copy's place (`md-exports/`, a hand-off folder).
        case notACopyPlace
    }

    static func location(of entry: CatalogEntry) -> Location? {
        var parent: CatalogNames.FolderName? = entry.place == .farFolder ? .variorum : nil
        var library8: String?
        for folder in entry.folders {
            guard let parsed = CatalogNames.parseFolder(folder, under: parent) else { return nil }
            if case .libraryFolder(let l8) = parsed { library8 = l8 }
            parent = parsed
        }
        switch parent {
        case nil: return .besideLibrary
        case .macFolder(let mac8)?: return library8.map { .macFolder(library8: $0, mac8: mac8) }
        case .adoptionSafetyCopy(let stamp)?: return .adoptionSafety(stamp: stamp)
        case .previousLibrary(let stamp)?: return .previousLibrary(stamp: stamp)
        case .variorum?, .backups?, .libraryFolder?, .safetyCopies?, .previousLibraries?:
            return .copyHome
        case .markdownExports?, .handOff?:
            return .notACopyPlace
        }
    }

    /// **Build the catalog from a listing.** Every entry whose folders or name
    /// no build writes is FOREIGN — listed, never a candidate, never pruned.
    public static func build(_ entries: [CatalogEntry]) -> Catalog {
        var keyFiles: [CatalogKeyFile] = []
        var foreign: [CatalogForeignEntry] = []
        var placed: [(entry: CatalogEntry, location: Location, name: CatalogNames.FileName)] = []
        for entry in entries.sorted(by: { $0.id < $1.id }) {
            guard let location = location(of: entry) else {
                foreign.append(CatalogForeignEntry(place: entry.place, folders: entry.folders, name: entry.name))
                continue
            }
            guard let name = CatalogNames.parseFile(entry.name) else {
                // A name in an export or hand-off folder is hers, not foreign
                // to a copy's place; everywhere else it is listed as foreign.
                if location != .notACopyPlace {
                    foreign.append(CatalogForeignEntry(place: entry.place, folders: entry.folders, name: entry.name))
                }
                continue
            }
            if location == .notACopyPlace { continue }
            if location == .copyHome {
                foreign.append(CatalogForeignEntry(place: entry.place, folders: entry.folders, name: entry.name))
                continue
            }
            placed.append((entry, location, name))
            guard name.isKeyFile, let role = keyFileRole(name, location) else { continue }
            keyFiles.append(CatalogKeyFile(
                id: entry.id, place: entry.place, folders: entry.folders, name: entry.name, role: role,
                document: entry.bytes.flatMap { try? KeyFile.decode($0) },
                mac: mac(entry.place, location), frozenAt: frozenAt(name, location), modifiedAt: entry.modifiedAt))
        }
        var copies: [CatalogCopy] = []
        for (entry, location, name) in placed {
            switch (name, location) {
            case (.snapshot(let stamp, let fp8), .macFolder):
                copies.append(copy(
                    entry, kind: .backup, stamp: stamp, fp8: fp8, location: location,
                    serving: snapshotServing(entry, fp8: fp8, keyFiles: keyFiles)))
            case (.library, .previousLibrary(let stamp)), (.library, .adoptionSafety(let stamp)):
                let kind: CopyKind
                if case .previousLibrary = location { kind = .previousLibrary } else { kind = .adoptionSafetyCopy }
                let serving = keyFiles.filter { $0.place == entry.place && $0.folders == entry.folders }
                    .sorted { servingOrder($0) < servingOrder($1) }
                copies.append(copy(entry, kind: kind, stamp: stamp, fp8: nil, location: location, serving: serving))
            default:
                continue
            }
        }
        return Catalog(copies: copies, keyFiles: keyFiles, foreign: foreign)
    }

    private static func keyFileRole(_ name: CatalogNames.FileName, _ location: Location) -> KeyFileRole? {
        switch (location, name) {
        case (.besideLibrary, .keyFile): return .live
        case (.besideLibrary, .setAsideKeyFile): return .setAside
        case (_, .snapshotKeyFile): return .snapshotPair
        case (.previousLibrary, _), (.adoptionSafety, _): return .asideCopy
        case (.besideLibrary, _), (.macFolder, _), (.notACopyPlace, _), (.copyHome, _): return nil
        }
    }

    private static func mac(_ place: CatalogPlace, _ location: Location) -> MacAttribution {
        if case .macFolder(_, let mac8) = location { return .mac8(mac8) }
        return place == .container ? .thisMacsContainer : .unattributed
    }

    /// The day a key file was frozen: a snapshot pair's stamp, a set-aside
    /// file's epoch, an aside folder's stamp (its files moved there whole on
    /// that day). Nil where its place doesn't say (the live file, a folder
    /// key file written once when absent).
    private static func frozenAt(_ name: CatalogNames.FileName, _ location: Location) -> Date? {
        switch name {
        case .snapshotKeyFile(let stamp, _): return stamp
        case .setAsideKeyFile(_, let at): return at
        default: break
        }
        switch location {
        case .previousLibrary(let stamp), .adoptionSafety(let stamp): return stamp
        default: return nil
        }
    }

    /// An aside folder's key files, best first: the format-3 live name first.
    private static func servingOrder(_ file: CatalogKeyFile) -> String {
        CatalogNames.parseFile(file.name) == .keyFile ? "0" + file.name : "1" + file.name
    }

    /// The pair rules for a snapshot: (1) its own pair, when it agrees with
    /// the name's fp8; (2) otherwise the Mac folder's own key files holding a
    /// key of that fp8 (a stamp-only name: every one the folder holds).
    private static func snapshotServing(
        _ entry: CatalogEntry, fp8: String?, keyFiles: [CatalogKeyFile]
    ) -> [CatalogKeyFile] {
        let pairName = String(entry.name.dropLast(".sqlite".count)) + ".keys.json"
        let pair = keyFiles.first { $0.place == entry.place && $0.folders == entry.folders && $0.name == pairName }
        if let pair, let fp8, let fingerprint = pair.fingerprint,
           StoreKeyEnvelope.shortFingerprint(fingerprint) != fp8 {
            // A mismatched pair does not open this snapshot — never offered as
            // if it did (today's rule).
        } else if let pair, pair.document != nil {
            return [pair]
        }
        let folderFiles = keyFiles.filter {
            $0.place == entry.place && $0.folders == entry.folders && $0.role != .snapshotPair
        }
        guard let fp8 else { return folderFiles.sorted { servingOrder($0) < servingOrder($1) } }
        return folderFiles.filter { file in
            file.heldFingerprints.contains { StoreKeyEnvelope.shortFingerprint($0) == fp8 }
        }.sorted { servingOrder($0) < servingOrder($1) }
    }

    private static func copy(
        _ entry: CatalogEntry, kind: CopyKind, stamp: Date?, fp8: String?, location: Location,
        serving: [CatalogKeyFile]
    ) -> CatalogCopy {
        let readable = serving.filter { $0.document != nil }
        // The key it is under: the serving file whose current key the name
        // (or the folder's only file) pins.
        var fingerprint: String?
        if let fp8 {
            fingerprint = readable.lazy.compactMap(\.fingerprint)
                .first { StoreKeyEnvelope.shortFingerprint($0) == fp8 }
                ?? readable.lazy.flatMap(\.heldFingerprints).first { StoreKeyEnvelope.shortFingerprint($0) == fp8 }
        } else if readable.count == 1 || (readable.first.map { CatalogNames.parseFile($0.name) == .keyFile } ?? false) {
            fingerprint = readable.first?.fingerprint
        }
        let candidates = fingerprint.map { [$0] } ?? Array(Set(readable.compactMap(\.fingerprint))).sorted()
        let libraries = Set(readable.compactMap(\.library))
        return CatalogCopy(
            id: entry.id, place: entry.place, folders: entry.folders, name: entry.name, kind: kind,
            stamp: stamp, nameFingerprint8: fp8, servingKeyFiles: serving.map(\.id),
            fingerprint: fingerprint, candidateFingerprints: candidates,
            library: libraries.count == 1 ? libraries.first : nil, mac: mac(entry.place, location))
    }
}
