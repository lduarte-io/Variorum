import Darwin
import Foundation

// VX-329 U4 piece 3 — THE WHOLE SET-ASIDE of a library from before this design (the plan's §6d and THE RULING under the
// U4 record: (a), and (D) with it). CastleRules rule 26 — "we don't migrate stores from before this design, and we don't
// handle them": detect and say (the fact is `AssessRules.preDesignStore`), move WHOLE at her word, never read. Her
// confirm promises "Your old library will be set aside whole in Previous Libraries — nothing is deleted."
//
// No byte of the old library is read or copied: its files are named by the slot folder's listing alone (`members`) and
// moved by the directory entries that name them —
//   1. every member HARD-LINKED (`link(2)`, the entry only) into a HIDDEN staging folder under Previous Libraries, on the
//      slot's own volume, each link verified to be the same file (device + inode); ANY link that fails refuses the act
//      whole — the staging folder removed, nothing moved;
//   2. THE COMMIT — one `rename(2)` (RENAME_EXCL: an existing `<stamp>/` is never overwritten; a fresh stamp is taken)
//      of the staging folder to `Previous Libraries/<stamp>/`: from that instant the aside is whole;
//   3. every member UNLINKED from the slot — the sidecars first (a stray WAL must never stand beside the next library),
//      then the store, then its key files and the hold — each only while the slot's entry is still the aside's file.
// Rule 20's substance without a pretended plan (a plan is sealed under a key, and this slot holds none this build can
// hold): THE DISK IS THE PLAN. A crash before (2) leaves the slot untouched and only invisible staging debris (the
// catalogue never lists a hidden name); a crash after it leaves the aside whole and the slot a remainder of hard links to
// the aside's own files. `finishInterrupted` — run at every press AND on the creation road — sweeps stale staging folders
// and finishes a committed remainder by the files' identity, never a byte: never two asides, never a split library.
// Pure mechanics, decides nothing about protection (the callers hold the fact); headless-testable in both configurations.

public enum PreDesignSetAside {
    public struct Failure: Error, Equatable, CustomStringConvertible, Sendable {
        public let reason: String
        public init(_ reason: String) { self.reason = reason }
        public var description: String { "PreDesignSetAside: \(reason)" }
    }

    /// The prefix of the hidden staging folder under Previous Libraries (hidden: the catalogue's lister skips it).
    public static let stagingPrefix = ".variorum-setting-aside-"

    /// What one pass found and did (the callers' log line).
    public struct Report: Equatable, Sendable {
        /// The aside that now holds the library (a fresh one, or the committed one a resume finished into).
        public var folder: URL?
        /// The slot entries a resume finished (unlinked — each the same file as its aside's).
        public var finished: [String] = []
        /// Stale staging folders removed (every file in them still linked from elsewhere — debris).
        public var sweptStaging = 0
        /// Stale staging folders holding a file found NOWHERE else — never deleted: committed to a stamp of their own.
        public var keptStaging: [URL] = []
    }

    // MARK: - Which files are the library's (pure — names only)

    /// The names in the slot's folder that belong to the library from before this design, in the order they LEAVE the
    /// slot: the store's sidecars, the store, every older key file and every older set-aside of one, then — when
    /// `carryingHold` — the restore hold beside it (the hold describes THAT library). Never this design's files, the
    /// container's "a library lived here" marker, the restore recipe, or anything of hers.
    public static func members(inSlotFolder names: [String], carryingHold: Bool) -> [String] {
        let present = Set(names)
        let store = CatalogNames.libraryFilename
        var ordered = ProtectionLibraryFiles.sidecarSuffixes.map { store + $0 }.filter(present.contains)
        if present.contains(store) { ordered.append(store) }
        ordered += present.filter {
            CatalogNames.isPreDesignKeyFileName($0) || CatalogNames.isPreDesignKeyFileSetAsideName($0)
        }.sorted()
        if carryingHold, present.contains(LibraryRestoreHold.filename) { ordered.append(LibraryRestoreHold.filename) }
        return ordered
    }

    // MARK: - The act

    /// **Set the library in the slot's folder aside WHOLE** into `Previous Libraries/<stamp>/` (the resume first). The
    /// report's `folder` holds it after; nil when no store stood in the slot (nothing to set aside — a stray older name
    /// beside an empty slot is left as it is unless a resume finishes it). Throws `Failure` when nothing could be moved,
    /// or — past the commit — when the slot's remainder could not leave yet (the aside is whole; the next press or the
    /// creation road finishes it).
    @discardableResult
    public static func setAsideWhole(slotFolder: URL, carryingHold: Bool, now: Date = Date()) throws -> Report {
        try setAsideWhole(slotFolder: slotFolder, carryingHold: carryingHold, now: now, seam: nil)
    }

    /// TEST SEAMS (a crash pin's): a seam that throws `Interruption` stops the act THERE as a crash would — no cleanup runs.
    enum Seam: Equatable, Sendable {
        case linked(String)
        case staged
        case committed
        case unlinked(String)
    }

    /// A crash, simulated at a seam (never thrown by the act itself).
    struct Interruption: Error, Equatable {}

    static func setAsideWhole(
        slotFolder: URL, carryingHold: Bool, now: Date, seam: ((Seam) throws -> Void)?
    ) throws -> Report {
        var report = try finishInterrupted(slotFolder: slotFolder)
        let members = members(inSlotFolder: try listing(slotFolder), carryingHold: carryingHold)
        let store = slotFolder.appendingPathComponent(CatalogNames.libraryFilename)
        guard members.contains(CatalogNames.libraryFilename) else { return report }
        let manager = FileManager.default
        let previous = previousLibraries(slotFolder)
        let madePrevious = !manager.fileExists(atPath: previous.path)
        try manager.createDirectory(at: previous, withIntermediateDirectories: true)
        let staging = previous.appendingPathComponent(stagingPrefix + UUID().uuidString, isDirectory: true)
        // (1) STAGE — every link, or nothing.
        do {
            try manager.createDirectory(at: staging, withIntermediateDirectories: false)
            guard let volume = identity(staging)?.device, volume == identity(store)?.device else {
                throw Failure("Previous Libraries is not on the library's own volume")
            }
            for name in members {
                let source = slotFolder.appendingPathComponent(name), target = staging.appendingPathComponent(name)
                guard linkat(AT_FDCWD, source.path, AT_FDCWD, target.path, 0) == 0 else {
                    throw Failure("\(name) could not be linked aside (errno \(errno))")
                }
                guard sameFile(source, target) else { throw Failure("\(name)'s link is not the same file") }
                try seam?(.linked(name))
            }
            try seam?(.staged)
        } catch let crash as Interruption {
            throw crash
        } catch {
            removeStaging(staging)
            if madePrevious { rmdir(previous.path) }
            throw error
        }
        // (2) THE COMMIT — one rename; an existing `<stamp>/` is never overwritten.
        var date = now
        var committed: URL?
        for _ in 0..<120 {
            let folder = previous.appendingPathComponent(CatalogNames.stampString(date), isDirectory: true)
            if renamex_np(staging.path, folder.path, UInt32(RENAME_EXCL)) == 0 {
                committed = folder
                break
            }
            let code = errno
            guard code == EEXIST || code == ENOTEMPTY else {
                removeStaging(staging)
                throw Failure("the set-aside could not be committed (errno \(code))")
            }
            date += 1
        }
        guard let folder = committed else {
            removeStaging(staging)
            throw Failure("no free stamp under Previous Libraries")
        }
        report.folder = folder
        try seam?(.committed)
        // (3) THE SLOT EMPTIED — each entry only while it is still the aside's file.
        for name in members {
            let source = slotFolder.appendingPathComponent(name)
            guard sameFile(source, folder.appendingPathComponent(name)) else {
                throw Failure("\(name) changed in the slot during the set-aside — left there")
            }
            guard unlink(source.path) == 0 else { throw Failure("\(name) could not leave the slot (errno \(errno))") }
            try seam?(.unlinked(name))
        }
        return report
    }

    // MARK: - The resume (at every press, and on the creation road)

    /// **Finish what an interrupted set-aside left** (rule 20's substance): stale staging folders are swept (removed when
    /// every file in them is still linked elsewhere; COMMITTED to a stamp of their own when one is not — never deleted),
    /// and every slot entry that is the SAME FILE (device + inode — never a byte) as a same-named file in a committed aside
    /// leaves the slot, in the members' order. A store is finished only when every sidecar beside it is its aside's too (a
    /// stray WAL never stands beside the next library) — otherwise this throws and the slot stays as it is.
    @discardableResult
    public static func finishInterrupted(slotFolder: URL) throws -> Report {
        var report = Report()
        let previous = previousLibraries(slotFolder)
        let manager = FileManager.default
        guard manager.fileExists(atPath: previous.path) else { return report }
        let entries = (try? manager.contentsOfDirectory(atPath: previous.path)) ?? []
        for name in entries.sorted() where name.hasPrefix(stagingPrefix) {
            let staging = previous.appendingPathComponent(name, isDirectory: true)
            let files = (try? manager.contentsOfDirectory(atPath: staging.path)) ?? []
            if files.allSatisfy({ (identity(staging.appendingPathComponent($0))?.links ?? 0) >= 2 }) {
                removeStaging(staging)
                report.sweptStaging += 1
            } else if let kept = commitKept(staging, under: previous) {
                report.keptStaging.append(kept)
            }
        }
        let all = members(inSlotFolder: try listing(slotFolder), carryingHold: true)
        guard !all.isEmpty else { return report }
        let store = CatalogNames.libraryFilename
        let sidecars = Set(ProtectionLibraryFiles.sidecarSuffixes.map { store + $0 })
        let committed = ((try? manager.contentsOfDirectory(atPath: previous.path)) ?? [])
            .filter { CatalogNames.stamp($0) != nil }.sorted()
        for stamp in committed {
            let folder = previous.appendingPathComponent(stamp, isDirectory: true)
            let matched = all.filter {
                sameFile(slotFolder.appendingPathComponent($0), folder.appendingPathComponent($0))
            }
            guard !matched.isEmpty else { continue }
            if matched.contains(store), !all.filter(sidecars.contains).allSatisfy(matched.contains) {
                throw Failure("a sidecar beside the library is not its set-aside's — the slot is left as it is")
            }
            for name in matched {
                guard unlink(slotFolder.appendingPathComponent(name).path) == 0 else {
                    throw Failure("\(name) could not leave the slot (errno \(errno))")
                }
                report.finished.append(name)
            }
            if matched.contains(store) || report.folder == nil { report.folder = folder }
        }
        return report
    }

    // MARK: - Helpers

    static func previousLibraries(_ slotFolder: URL) -> URL {
        slotFolder.appendingPathComponent(CatalogNames.previousLibrariesFolderName, isDirectory: true)
    }

    static func listing(_ folder: URL) throws -> [String] {
        try FileManager.default.contentsOfDirectory(atPath: folder.path)
    }

    struct Identity: Equatable {
        let device: dev_t
        let inode: ino_t
        let links: nlink_t
    }

    /// The entry's file identity — `lstat`, metadata only (never the file's bytes; a link is the link itself).
    static func identity(_ url: URL) -> Identity? {
        var info = stat()
        guard lstat(url.path, &info) == 0 else { return nil }
        return Identity(device: info.st_dev, inode: info.st_ino, links: info.st_nlink)
    }

    /// Both entries exist and name the same file.
    static func sameFile(_ a: URL, _ b: URL) -> Bool {
        guard let left = identity(a), let right = identity(b) else { return false }
        return left.device == right.device && left.inode == right.inode
    }

    /// A staging folder's entries unlinked and the folder removed (best effort — debris only ever holds hard links).
    static func removeStaging(_ staging: URL) {
        for name in (try? FileManager.default.contentsOfDirectory(atPath: staging.path)) ?? [] {
            unlink(staging.appendingPathComponent(name).path)
        }
        rmdir(staging.path)
    }

    /// A stale staging folder holding a file found nowhere else, made visible under a fresh stamp (never deleted).
    static func commitKept(_ staging: URL, under previous: URL) -> URL? {
        var date = Date()
        for _ in 0..<120 {
            let folder = previous.appendingPathComponent(CatalogNames.stampString(date), isDirectory: true)
            if renamex_np(staging.path, folder.path, UInt32(RENAME_EXCL)) == 0 { return folder }
            date += 1
        }
        return nil
    }
}
