//
//  BackupDestination.swift
//  Variorum (shared: Mac + Mobile — wired on the Mac, like StoreBackup)
//
//  Phase 13l, Act 4 (ledger row 11) — the SECOND backup destination: a
//  folder SHE picks.
//
//  Her ruling at the 13l kickoff, verbatim: *"people should pick a local
//  folder - they can always pick a folder that's in icloud drive (like
//  desktop is for me)."* So there is no cloud machinery here and there never
//  will be: the picker is the whole door, and an iCloud-synced pick buys
//  off-site coverage for free.
//
//  WHY THE BOOKMARK IS DEVICE-LOCAL, AND WHY IT MUST STAY THAT WAY:
//  a path is a fact about ONE machine, and `setting.value` is fenced to
//  "enum semantics, no prose" by the 14b E2EE disclosure promise (AppSpec §7
//  — the fence is COLUMN-wide, so a path-valued setting would re-open that
//  column's classification). The `reference.file_bookmark` precedent governs
//  exactly this shape: the row syncs, the bookmark does not. Here there is
//  no row at all — `UserDefaults` on this Mac, and the phone (should it ever
//  want one) picks its own.
//
//  Sandboxing: the app has `com.apple.security.files.bookmarks.app-scope`
//  and user-selected read-write, so a picked folder survives relaunch as a
//  security-scoped bookmark. A plain bookmark is dead across relaunch in a
//  sandboxed app — so a mint that loses the scope is reported, never stored
//  silently (the 11b MAJOR-1 lesson, applied one folder up).
//

import Foundation

nonisolated enum BackupDestination {
    /// The device-local home of the picked folder's bookmark.
    static let defaultsKey = "variorum.backup.secondDestination"

    /// What the app writes INSIDE the folder she picks. One named folder, so
    /// picking Desktop leaves one tidy thing on the Desktop rather than a
    /// drift of `variorum-backup-*.sqlite` files — and so Act 5's `.md`
    /// exports have an obvious place to sit beside the snapshots.
    static let folderName = "Variorum"
    static let backupsSubfolder = "Backups"

    /// `<picked>/Variorum` — the one folder the app owns inside her pick.
    static func variorumFolder(in picked: URL) -> URL {
        picked.appendingPathComponent(folderName, isDirectory: true)
    }

    /// `<picked>/Variorum/Backups` — where the snapshots land.
    static func backupsFolder(in picked: URL) -> URL {
        variorumFolder(in: picked).appendingPathComponent(backupsSubfolder, isDirectory: true)
    }

    // MARK: - Persisting the pick

    nonisolated struct MintFailure: Error, LocalizedError {
        let reason: String
        var errorDescription: String? { reason }
    }

    /// Stores the picked folder as an app-scoped security bookmark.
    /// Throws rather than storing an unscoped bookmark: an unscoped one
    /// resolves today and is dead tomorrow, which is the silent-stop failure
    /// this whole phase exists to kill.
    ///
    /// **macOS only, and the `#if` is the honest shape rather than a
    /// portability hedge.** `.withSecurityScope` does not exist on iOS
    /// because the concept does not: there is no folder picker feeding a
    /// daily background copy on the phone, and `StoreBackup` is not wired
    /// there at all (the phone's store is re-derivable from the mirror —
    /// A1's own note). Should the phone ever want a second destination it
    /// wants a different mechanism (a document-picker URL, or Files-app
    /// scoping), which is a design, not a compile flag.
    static func remember(
        _ url: URL, in defaults: UserDefaults = .standard
    ) throws {
        #if os(macOS)
        do {
            let data = try url.bookmarkData(
                options: [.withSecurityScope], includingResourceValuesForKeys: nil,
                relativeTo: nil)
            defaults.set(data, forKey: defaultsKey)
        } catch {
            throw MintFailure(reason:
                "This folder can't be remembered across launches (\(error.localizedDescription)). "
                + "Pick a folder in your home directory or on an external volume.")
        }
        #else
        // Worded with no other platform in it: the mobile no-redirect
        // sweep is right that a phone must never be told to go and use
        // something else, and this arm has no door of its own to reach it.
        throw MintFailure(reason: "A backup folder can't be remembered on this device.")
        #endif
    }

    static func forget(in defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: defaultsKey)
    }

    static func isSet(in defaults: UserDefaults = .standard) -> Bool {
        defaults.data(forKey: defaultsKey) != nil
    }

    // MARK: - Resolving it

    nonisolated struct Resolved: Sendable, Equatable {
        /// The folder she picked (NOT the `Variorum/Backups` folder inside).
        let picked: URL
        /// The bookmark had gone stale and was re-minted on resolve.
        let wasStale: Bool
    }

    /// Resolves the stored bookmark. `nil` = nothing picked, or the pick is
    /// no longer reachable (an unplugged volume, a deleted folder) — the
    /// caller says which, honestly, rather than pretending a backup happened.
    static func resolve(in defaults: UserDefaults = .standard) -> Resolved? {
        guard let data = defaults.data(forKey: defaultsKey) else { return nil }
        var stale = false
        #if os(macOS)
        let options: URL.BookmarkResolutionOptions = [.withSecurityScope]
        #else
        let options: URL.BookmarkResolutionOptions = []
        #endif
        guard let url = try? URL(
            resolvingBookmarkData: data, options: options,
            relativeTo: nil, bookmarkDataIsStale: &stale)
        else { return nil }
        return Resolved(picked: url, wasStale: stale)
    }

    /// Runs `body` with the folder's security scope claimed, releasing it on
    /// every path. The claim is per-RUN (once a day) rather than held for the
    /// process's life: a claim that outlives its work is the accrual bug the
    /// reference panel already paid for once.
    static func withAccess<T>(to url: URL, _ body: () throws -> T) rethrows -> T {
        let claimed = url.startAccessingSecurityScopedResource()
        defer { if claimed { url.stopAccessingSecurityScopedResource() } }
        return try body()
    }

    /// A path in her words, not the sandbox's — `~/Desktop` beats
    /// `<home>/Desktop`, and a container path beats neither.
    static func displayPath(_ url: URL) -> String {
        let path = url.path(percentEncoded: false)
        let home = NSHomeDirectory()
        // The sandboxed container's home is …/Containers/<id>/Data; the
        // REAL home is what she recognises, so abbreviate against both.
        let realHome = "/Users/" + NSUserName()
        for prefix in [home, realHome] where path.hasPrefix(prefix + "/") {
            return "~" + path.dropFirst(prefix.count)
        }
        return path
    }
}
