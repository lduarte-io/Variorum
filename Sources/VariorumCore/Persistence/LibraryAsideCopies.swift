import Foundation

// VX-203 (RUN VX-201, U3) — THE STEP-ASIDE COPIES the Castle offer reaches.
//
// An adoption (13x: Open Library, Restore from Backup) leaves the outgoing
// library WHOLE in two stamp folders beside the store — the dated copy in
// `Previous Libraries/<stamp>/` and the A1-shaped safety copy in
// `Backups/safety-copies/variorum-adopt-safety-<stamp>/` — each with the key
// files that stood beside it. Made while in Standard, those key files carry
// the iCloud copy of that library's key, so the whole library opens through
// the Apple account for as long as the folder exists. The Castle offer
// ("delete the backups Variorum made before today") must reach them
// (auditor B1d).
//
// WHAT QUALIFIES — every leg, or the folder is left alone:
//   · it IS one of the adoption's stamp folders: a real directory (never a
//     symlink) whose parent is one of the two homes beside THIS store, named
//     exactly as `plan` names it (`<stamp>` in Previous Libraries,
//     `variorum-adopt-safety-<stamp>` in safety-copies — the stamp reading
//     back exactly). The A1 rail's own `variorum-backup-a1-*` folders and
//     anything else in those homes never match;
//   · it holds exactly ONE `.sqlite` store (the classifier's folder rule);
//   · the key file Variorum would OPEN that store with — `StoreKeyEnvelope
//     .locate`, the classifier's own rule for an ordinary-named store —
//     carries the iCloud copy (`apple`). Not "any key file in the folder":
//     the device that entered Castle keeps its Standard-era key file (an
//     `apple` copy of the OLD key) beside its re-keyed library, and an
//     adoption moves both aside — that Castle-era copy opens nothing through
//     the Apple account and must never be swept into this delete (VX-201
//     §A bound 1; F-U3-1). `locate` picks by modification date, which both
//     the move and the copy preserve.
//
// The remover re-runs the whole qualification before it removes anything,
// so it can only ever delete a folder this lister would list.

extension LibraryAdoption {
    /// Which of the two homes a stamp folder sits in.
    public enum AsideHome: Int, Equatable, Sendable {
        case previousLibraries
        case safetyCopies
    }

    public enum AsideCopyError: Error, Equatable, Sendable {
        /// The path is not an Apple-openable step-aside copy beside this
        /// store — refused with nothing removed.
        case notAnAppleOpenableAsideCopy(String)
    }

    /// Every Apple-openable copy an adoption set aside beside `storeURL`,
    /// both homes, oldest stamp first (the dated copy before its safety
    /// twin). `keepingFingerprint` (a short fingerprint): a copy whose key
    /// file is that key's is never listed — the offer never names a copy
    /// under the key the library now uses. Reads only; writes nothing.
    public static func appleOpenableAsideCopies(
        besideStore storeURL: URL, keepingFingerprint keep: String? = nil
    ) -> [URL] {
        var found: [(url: URL, stamp: Date, home: AsideHome)] = []
        for home in [AsideHome.previousLibraries, .safetyCopies] {
            let homeURL = self.homeURL(home, besideStore: storeURL)
            let names = (try? FileManager.default.contentsOfDirectory(atPath: homeURL.path)) ?? []
            for name in names {
                // The caller's path form (a listing may resolve `/var/…`
                // into `/private/var/…`; the outcome must compare equal to
                // the URLs the caller builds).
                let folder = homeURL.appendingPathComponent(name, isDirectory: true)
                guard let qualified = qualify(folder, besideStore: storeURL) else { continue }
                if let keep, let fingerprint = qualified.keyFingerprint,
                   StoreKeyEnvelope.shortFingerprint(fingerprint) == keep { continue }
                found.append((folder, qualified.stamp, home))
            }
        }
        return found
            .sorted { ($0.stamp, $0.home.rawValue, $0.url.lastPathComponent)
                < ($1.stamp, $1.home.rawValue, $1.url.lastPathComponent) }
            .map(\.url)
    }

    /// Whether `folder` is an Apple-openable step-aside copy beside
    /// `storeURL` (the file header's every leg).
    public static func isAppleOpenableAsideCopy(_ folder: URL, besideStore storeURL: URL) -> Bool {
        qualify(folder, besideStore: storeURL) != nil
    }

    /// Remove ONE step-aside copy — the whole stamp folder — after
    /// re-checking every leg of the qualification. Anything else refuses
    /// with nothing removed: a path outside the two homes, a foreign folder
    /// inside them, a Castle-era copy, a symlink.
    public static func removeAsideCopy(_ folder: URL, besideStore storeURL: URL) throws {
        guard qualify(folder, besideStore: storeURL) != nil else {
            throw AsideCopyError.notAnAppleOpenableAsideCopy(folder.path)
        }
        try FileManager.default.removeItem(at: folder)
    }

    // MARK: - The qualification

    private struct Qualified {
        var stamp: Date
        var keyFingerprint: String?
    }

    private static func homeURL(_ home: AsideHome, besideStore storeURL: URL) -> URL {
        switch home {
        case .previousLibraries: return previousLibrariesHome(besideStore: storeURL)
        case .safetyCopies: return safetyCopiesHome(besideStore: storeURL)
        }
    }

    /// A path compared by what it IS on disk (`..` folded, `/var` and
    /// `/private/var` one folder).
    private static func canonicalPath(_ url: URL) -> String {
        url.standardizedFileURL.resolvingSymlinksInPath().path
    }

    /// A real directory at `url` — never a symlink (`attributesOfItem` reads
    /// the link itself, not its target).
    private static func isRealDirectory(_ url: URL) -> Bool {
        let type = (try? FileManager.default.attributesOfItem(atPath: url.path))?[.type] as? FileAttributeType
        return type == .typeDirectory
    }

    private static func qualify(_ folder: URL, besideStore storeURL: URL) -> Qualified? {
        let fm = FileManager.default
        // A real directory — a symlink is never followed into, never removed.
        guard isRealDirectory(folder) else { return nil }
        // The parent IS one of the two homes beside THIS store, and the name
        // is the adoption's own for that home. Every folder the homes' names
        // spell is itself real, so a link planted there can never point the
        // homes somewhere else.
        let name = folder.standardizedFileURL.lastPathComponent
        let parent = canonicalPath(folder.standardizedFileURL.deletingLastPathComponent())
        let previous = previousLibrariesHome(besideStore: storeURL)
        let safety = safetyCopiesHome(besideStore: storeURL)
        let stamp: Date?
        if parent == canonicalPath(previous), isRealDirectory(previous) {
            stamp = adoptionStamp(name)
        } else if parent == canonicalPath(safety), name.hasPrefix(safetyCopyPrefix),
                  isRealDirectory(safety), isRealDirectory(safety.deletingLastPathComponent()) {
            stamp = adoptionStamp(String(name.dropFirst(safetyCopyPrefix.count)))
        } else {
            stamp = nil
        }
        guard let stamp else { return nil }
        // Exactly one store inside (the classifier's folder rule).
        let stores = ((try? fm.contentsOfDirectory(atPath: folder.path)) ?? [])
            .filter { ($0 as NSString).pathExtension == "sqlite" }
        guard stores.count == 1 else { return nil }
        let store = folder.appendingPathComponent(stores[0], isDirectory: false)
        // The key file Variorum would open that store with carries the
        // iCloud copy (an unreadable key file opens nothing — not listed).
        guard let keyFile = StoreKeyEnvelope.locate(besideStore: store),
              let envelope = try? StoreKeyEnvelope.load(at: keyFile),
              envelope.apple != nil else { return nil }
        return Qualified(stamp: stamp, keyFingerprint: envelope.keyFingerprint)
    }
}
