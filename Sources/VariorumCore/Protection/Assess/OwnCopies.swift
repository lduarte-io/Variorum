import Foundation

// VX-309 U1a — THIS MAC'S COPIES OF THIS LIBRARY, PER PLACE (design §3.7, VX-302: "copies belong to a library and a
// Mac"; VX-397: every new-road read of the copies — the far folder's due-check, Data Safety's counts — is per library
// per Mac). ONE predicate, the one retention has always used (`Retention.plan` reads it from here): a backup pair whose
// key file names the library, filed under that library's `<library8>` and this Mac's `<mac8>` subfolder. Another Mac's
// copy in a shared folder, another library's, a copy whose key file doesn't read, today's flat files (foreign since rule
// 26), `Previous Libraries/` and the safety copies are never this Mac's copies of this library.
//
// Pure: the catalog in, values out — nothing here reads a disk.

public enum OwnCopies {
    /// **The one predicate**: a BACKUP pair of `libraryID` by THIS Mac (`deviceID`'s `<mac8>`), filed under the library's
    /// own `<library8>` folder (a pair whose key file names this library, filed under another's folder, is not filed as
    /// this library's copy).
    public static func isThisMacsCopyOfThisLibrary(_ copy: CatalogCopy, libraryID: String, thisMac deviceID: String) -> Bool {
        let mine = ProtectionNames.mac8(deviceID).lowercased()
        let library8 = ProtectionNames.library8(libraryID).lowercased()
        guard copy.kind == .backup, copy.mac == .mac8(mine), copy.library == libraryID else { return false }
        return copy.folders.count >= 2 && copy.folders[1].lowercased() == library8
    }

    /// This Mac's pairs of `libraryID` in `place`, as the catalog lists them.
    public static func of(
        _ catalog: Catalog, libraryID: String, thisMac deviceID: String, in place: CatalogPlace
    ) -> [CatalogCopy] {
        catalog.copies.filter { $0.place == place && isThisMacsCopyOfThisLibrary($0, libraryID: libraryID, thisMac: deviceID) }
    }

    /// **A stamp later than now is not evidence of freshness** — `StoreBackup.stampIsTrusted` (18o U1, KnownIssues row
    /// 84), restated byte-equal so the core owns the rule its own reads use (a Mac pin holds the two equal).
    public static func stampIsTrusted(_ stamp: Date, now: Date) -> Bool {
        stamp <= now
    }

    /// What a place holds of this Mac's copies of a library: how many (every pair, as today's face counts every dated
    /// file), and the newest and oldest TRUSTED stamps (a future stamp is counted, never shown as the newest).
    public struct Summary: Equatable, Sendable {
        public var count: Int
        public var newest: Date?
        public var oldest: Date?

        public init(count: Int = 0, newest: Date? = nil, oldest: Date? = nil) {
            self.count = count
            self.newest = newest
            self.oldest = oldest
        }

        public static let none = Summary()
    }

    public static func summary(
        _ catalog: Catalog, libraryID: String, thisMac deviceID: String, in place: CatalogPlace, now: Date
    ) -> Summary {
        let own = of(catalog, libraryID: libraryID, thisMac: deviceID, in: place)
        let trusted = own.compactMap(\.stamp).filter { stampIsTrusted($0, now: now) }
        return Summary(count: own.count, newest: trusted.max(), oldest: trusted.min())
    }

    // MARK: - VX-309 U1c — VX-265: this Mac's copies of ANOTHER library (rule 19's delete)

    /// **Whether `copy` is THIS Mac's** — rule 19's delete ("Copies of other libraries are listed and can be deleted"), and
    /// never another Mac's. A library's device ID is its own on each Mac (rule 23): Make this my library mints a fresh one,
    /// so the `<mac8>` the OPEN library's section names says nothing about another library's copies — the library that
    /// stepped aside filed its backups under ITS device ID's `<mac8>`. What does say it is the place: every copy in this
    /// Mac's own CONTAINER is this Mac's (the container is per Mac and per login — `MacAttribution.thisMacsContainer`'s own
    /// reason), whatever subfolder it sits in; a FAR copy is this Mac's only when this Mac's container files the SAME
    /// library's copies under the same `Backups/<library8>/<mac8>` subfolder (the pair road copies the container pair there
    /// under its own subfolder — VX-309 U1a, R-U1a-1). A far copy under any other `<mac8>` (another Mac sharing the folder)
    /// or under none (`unattributed`), and a copy no key file attributes to a library, are never claimed.
    public static func isThisMacsCopy(_ copy: CatalogCopy, in catalog: Catalog) -> Bool {
        guard let library = copy.library else { return false }
        switch copy.place {
        case .container:
            return true
        case .farFolder:
            guard case .mac8 = copy.mac, let subfolder = backupSubfolder(copy) else { return false }
            return catalog.copies.contains {
                $0.place == .container && $0.library == library && backupSubfolder($0) == subfolder
            }
        }
    }

    /// This Mac's copies of `libraryID` — what rule 19's delete counts, and only that.
    public static func thisMacsCopies(ofLibrary libraryID: String, in catalog: Catalog) -> [CatalogCopy] {
        catalog.copies.filter { $0.library == libraryID && isThisMacsCopy($0, in: catalog) }
    }

    /// A backup pair's `Backups/<library8>/<mac8>` subfolder, lowercased (nil for a copy filed anywhere else).
    private static func backupSubfolder(_ copy: CatalogCopy) -> [String]? {
        guard copy.kind == .backup, copy.folders.count >= 3 else { return nil }
        return copy.folders.prefix(3).map { $0.lowercased() }
    }

    /// **The far folder's own due-ness (P-VX306-U1a-4's deferral, VX-309 U1a piece 1)**: due when the catalog holds NO
    /// pair of this library by this Mac in the far folder whose stamp is trusted and younger than `interval` — the
    /// question today's flat far leg asks of the folder's newest file (`StoreBackup.performSecondLeg`), asked of this
    /// Mac's own pairs of this library instead (VX-397: another Mac's fresh copy never satisfies it).
    public static func farPairIsDue(
        _ catalog: Catalog, libraryID: String, thisMac deviceID: String, now: Date, interval: TimeInterval
    ) -> Bool {
        !of(catalog, libraryID: libraryID, thisMac: deviceID, in: .farFolder).contains { copy in
            guard let stamp = copy.stamp, stampIsTrusted(stamp, now: now) else { return false }
            return now.timeIntervalSince(stamp) < interval
        }
    }
}
