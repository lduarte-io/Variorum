import Foundation

// VX-305 U2 — THE CATALOG'S ONE NAME PARSER (design §3.7: "It has one name
// parser and attributes each copy to its library … and its Mac"). Every file
// and folder name today's builds have written in the places copies live, and
// the names this build adds, parsed in ONE place — so the restore list, Open
// Library, the Castle offer and retention can never disagree about what a
// name is.
//
// THE UNION OF TODAY'S THREE PARSERS (the plan's §4: "read the three existing
// parsers and keep their union"):
//   1. the BACKUP-NAME parser — `StoreBackup.date(fromBackupURL:)`
//      (App/Variorum/Shared/StoreBackup.swift), restated in core as
//      `BackupRestoreCandidates.backupDate`: `variorum-backup-<stamp>` or
//      `variorum-backup-<stamp>-<fp8>`, `.sqlite`, the stamp reading back
//      exactly as the writer formats it (UTC `yyyy-MM-dd-HHmmss`), the tail
//      empty or `-` + eight LOWERCASE hex — and ONLY those (18k C7: a foreign
//      name that merely starts with a stamp, the A1 rail's `variorum-backup-
//      a1-…`, is not the app's and is never a candidate or pruned);
//   2. the PAIR rules — `LibraryClassifier` (Persistence/LibraryClassifier
//      .swift) and `StoreKeyEnvelope`'s names: the snapshot's own pair
//      `<snapshot>.keys.json` (pre-13x row 42), the fingerprint-named key
//      file `variorum-keys-<fp16>.json` (sixteen hex, `isHexDigit` as today),
//      the legacy `variorum-keys.json`, and the set-aside `.stale-<epoch>
//      .json` shape both set-aside writers spell (`StoreIdentity.setAside`,
//      `StoreLaunchGate.live.setAsideEnvelope`);
//   3. the STAMP-FOLDER qualifier — `LibraryAdoption.adoptionStamp` and
//      `LibraryAsideCopies.qualify`: `Previous Libraries/<stamp>/` and
//      `Backups/safety-copies/variorum-adopt-safety-<stamp>/`, the stamp
//      reading back exactly.
// The classifier's looser `isBackupNamed` (any `variorum-backup-` prefix) is
// a routing hint for a file the user PICKED, never an acceptance of the name
// as the app's — the strict stamp rule above decides here (18k C7).
//
// Beside them, the names today's builds write in the same places (the slot's
// `variorum.sqlite` and its sidecars, `RESTORE.md`, `md-exports/`, the
// hand-off folder `Variorum Library — <day>`) and this build's own
// (`variorum-library-keys.json`, `variorum-plan.json`, `Backups/<library8>/
// <mac8>/`). Pure: names in, values out — nothing here reads a disk.

public enum CatalogNames {
    // MARK: - The stamp (`yyyy-MM-dd-HHmmss`, UTC — every stamp today's builds write)

    /// `yyyy-MM-dd-HHmmss` is 17 characters.
    public static let stampLength = 17

    nonisolated(unsafe) private static let stampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd-HHmmss"
        return formatter
    }()

    private static let formatterLock = NSLock()

    /// The stamp a name carries, or nil — it must read back EXACTLY as the
    /// writers format it (a foreign string that merely parses is not one).
    public static func stamp(_ text: String) -> Date? {
        guard text.count == stampLength else { return nil }
        formatterLock.lock()
        defer { formatterLock.unlock() }
        guard let date = stampFormatter.date(from: text),
              stampFormatter.string(from: date) == text else { return nil }
        return date
    }

    /// The writers' own spelling of a stamp.
    public static func stampString(_ date: Date) -> String {
        formatterLock.lock()
        defer { formatterLock.unlock() }
        return stampFormatter.string(from: date)
    }

    // MARK: - File names

    public static let backupPrefix = "variorum-backup-"
    public static let libraryFilename = "variorum.sqlite"
    public static let legacyKeyFilename = "variorum-keys.json"
    public static let fingerprintKeyFilePrefix = "variorum-keys-"
    public static let restoreRecipeFilename = "RESTORE.md"

    public enum FileName: Equatable, Sendable {
        /// `variorum-backup-<stamp>[-<fp8>].sqlite` — a snapshot (a backup,
        /// a lock-time copy: the two share today's shape).
        case snapshot(stamp: Date, fingerprint8: String?)
        /// `variorum-backup-<stamp>[-<fp8>].keys.json` — the snapshot's own
        /// key file, written with it and never rewritten.
        case snapshotKeyFile(stamp: Date, fingerprint8: String?)
        /// `variorum-library-keys.json` — format 3 (this build's).
        case keyFile
        /// `variorum-keys-<fp16>.json` — format 2's name.
        case fingerprintKeyFile(fingerprint: String)
        /// `variorum-keys.json` — format 1's fixed name.
        case legacyKeyFile
        /// A key file moved aside: `variorum-keys[-<fp16>].stale-<epoch>.json`.
        case setAsideKeyFile(fingerprint: String?, setAsideAt: Date)
        /// `variorum.sqlite` — the slot's name; the store inside an aside or
        /// safety-copy folder; the hand-off folder's snapshot.
        case library
        /// A SQLite sidecar of a name above (`-wal`, `-shm`, `-journal`).
        indirect case sidecar(of: FileName, suffix: String)
        /// `variorum-plan.json` (this build's; excluded from backups).
        case plan
        /// `RESTORE.md`, the restore recipe beside the copies.
        case restoreRecipe

        /// A key file of any format (the names the route finder reads).
        public var isKeyFile: Bool {
            switch self {
            case .snapshotKeyFile, .keyFile, .fingerprintKeyFile, .legacyKeyFile, .setAsideKeyFile: return true
            default: return false
            }
        }
    }

    /// What a file name is — nil for a name no build of Variorum writes (the
    /// A1 rail's copies, a drill's files, anything of hers).
    public static func parseFile(_ name: String) -> FileName? {
        for suffix in ["-wal", "-shm", "-journal"] where name.hasSuffix(suffix) {
            guard let base = parseFile(String(name.dropLast(suffix.count))),
                  base.acceptsSidecars else { return nil }
            return .sidecar(of: base, suffix: suffix)
        }
        switch name {
        case libraryFilename: return .library
        case ProtectionNames.keyFilename: return .keyFile
        case legacyKeyFilename: return .legacyKeyFile
        case ProtectionNames.planFilename: return .plan
        case restoreRecipeFilename: return .restoreRecipe
        default: break
        }
        if name.hasPrefix(backupPrefix) {
            if name.hasSuffix(".keys.json") {
                return backupStem(String(name.dropLast(".keys.json".count)))
                    .map { .snapshotKeyFile(stamp: $0.stamp, fingerprint8: $0.fingerprint8) }
            }
            if name.hasSuffix(".sqlite") {
                return backupStem(String(name.dropLast(".sqlite".count)))
                    .map { .snapshot(stamp: $0.stamp, fingerprint8: $0.fingerprint8) }
            }
            return nil
        }
        if name.hasPrefix(fingerprintKeyFilePrefix) || name.hasPrefix("variorum-keys.") {
            return keyFileName(name)
        }
        return nil
    }

    /// The backup stem `variorum-backup-<stamp>[-<fp8>]` (StoreBackup's
    /// writer, restated): the stamp exact, the tail empty or `-` + 8
    /// lowercase hex.
    private static func backupStem(_ stem: String) -> (stamp: Date, fingerprint8: String?)? {
        guard stem.hasPrefix(backupPrefix) else { return nil }
        let rest = stem.dropFirst(backupPrefix.count)
        guard rest.count >= stampLength, let stamp = stamp(String(rest.prefix(stampLength))) else { return nil }
        let tail = rest.dropFirst(stampLength)
        if tail.isEmpty { return (stamp, nil) }
        guard tail.count == 9, tail.first == "-",
              tail.dropFirst().allSatisfy({ "0123456789abcdef".contains($0) }) else { return nil }
        return (stamp, String(tail.dropFirst()))
    }

    /// `variorum-keys-<fp16>.json`, `variorum-keys.json` (above) and the
    /// set-aside shape `<either name minus .json>.stale-<epoch>.json`.
    private static func keyFileName(_ name: String) -> FileName? {
        if let fingerprint = StoreKeyEnvelope.fingerprint(fromFilename: name) {
            return .fingerprintKeyFile(fingerprint: fingerprint)
        }
        // The set-aside shape: `url.deletingPathExtension()
        // .appendingPathExtension("stale-<Int(epoch)>.json")`.
        guard name.hasSuffix(".json"), let marker = name.range(of: ".stale-", options: .backwards) else { return nil }
        let base = String(name[..<marker.lowerBound])
        let epochText = name[marker.upperBound...].dropLast(".json".count)
        guard !epochText.isEmpty, epochText.allSatisfy({ "0123456789".contains($0) }),
              let epoch = Int(epochText) else { return nil }
        let setAsideAt = Date(timeIntervalSince1970: TimeInterval(epoch))
        if base == "variorum-keys" { return .setAsideKeyFile(fingerprint: nil, setAsideAt: setAsideAt) }
        guard let fingerprint = StoreKeyEnvelope.fingerprint(fromFilename: base + ".json") else { return nil }
        return .setAsideKeyFile(fingerprint: fingerprint, setAsideAt: setAsideAt)
    }

    // MARK: - Folder names

    public static let backupsFolderName = "Backups"
    public static let safetyCopiesFolderName = "safety-copies"
    public static let adoptionSafetyPrefix = "variorum-adopt-safety-"
    public static let previousLibrariesFolderName = "Previous Libraries"
    public static let markdownExportsFolderName = "md-exports"
    /// The far folder's own (`BackupDestination.folderName`).
    public static let variorumFolderName = "Variorum"
    /// The hand-off folder's prefix (`LibraryHandOff.folderPrefix`).
    public static let handOffPrefix = "Variorum Library — "

    public enum FolderName: Equatable, Sendable {
        case backups
        /// `Backups/<library8>` — this build's.
        case libraryFolder(library8: String)
        /// `Backups/<library8>/<mac8>` — this build's.
        case macFolder(mac8: String)
        case safetyCopies
        /// `Backups/safety-copies/variorum-adopt-safety-<stamp>`.
        case adoptionSafetyCopy(stamp: Date)
        case previousLibraries
        /// `Previous Libraries/<stamp>`.
        case previousLibrary(stamp: Date)
        case markdownExports
        case variorum
        /// `Variorum Library — <yyyy-MM-dd>[ (n)]` — Send Library's folder.
        case handOff(day: String)
    }

    /// What a folder name is, given the folder it sits in (nil = the place's
    /// root). Nil for a folder no build writes (the A1 rail's
    /// `variorum-backup-a1-*` folders among them).
    public static func parseFolder(_ name: String, under parent: FolderName?) -> FolderName? {
        switch parent {
        case nil:
            switch name {
            case backupsFolderName: return .backups
            case previousLibrariesFolderName: return .previousLibraries
            case markdownExportsFolderName: return .markdownExports
            case variorumFolderName: return .variorum
            default: return handOffDay(name).map { .handOff(day: $0) }
            }
        case .variorum?:
            switch name {
            case backupsFolderName: return .backups
            case markdownExportsFolderName: return .markdownExports
            default: return nil
            }
        case .backups?:
            if name == safetyCopiesFolderName { return .safetyCopies }
            return isEightHex(name) ? .libraryFolder(library8: name.lowercased()) : nil
        case .libraryFolder?:
            return isEightHex(name) ? .macFolder(mac8: name.lowercased()) : nil
        case .safetyCopies?:
            guard name.hasPrefix(adoptionSafetyPrefix),
                  let stamp = stamp(String(name.dropFirst(adoptionSafetyPrefix.count))) else { return nil }
            return .adoptionSafetyCopy(stamp: stamp)
        case .previousLibraries?:
            return stamp(name).map { .previousLibrary(stamp: $0) }
        case .markdownExports?:
            // `md-exports/<dated folder>/…` — the plain-text exports, hers
            // to keep; everything below stays in the exports subtree.
            return .markdownExports
        default:
            return nil
        }
    }

    /// `<library8>` / `<mac8>`: the first eight characters of a lowercase
    /// UUID — eight hex (either case read; compared lowercased).
    static func isEightHex(_ name: String) -> Bool {
        name.count == 8 && name.allSatisfy { "0123456789abcdefABCDEF".contains($0) }
    }

    /// `Variorum Library — yyyy-MM-dd` or `… (n)`, n ≥ 2.
    private static func handOffDay(_ name: String) -> String? {
        guard name.hasPrefix(handOffPrefix) else { return nil }
        var rest = Substring(name.dropFirst(handOffPrefix.count))
        if let open = rest.range(of: " (") {
            let counter = rest[open.upperBound...]
            guard counter.hasSuffix(")"), let n = Int(counter.dropLast()), n >= 2 else { return nil }
            rest = rest[..<open.lowerBound]
        }
        let parts = rest.split(separator: "-", omittingEmptySubsequences: false)
        guard parts.map(\.count) == [4, 2, 2],
              parts.allSatisfy({ $0.allSatisfy { "0123456789".contains($0) } }) else { return nil }
        return String(rest)
    }
}

extension CatalogNames.FileName {
    /// The names a SQLite sidecar can follow.
    var acceptsSidecars: Bool {
        switch self {
        case .snapshot, .library: return true
        default: return false
        }
    }
}
