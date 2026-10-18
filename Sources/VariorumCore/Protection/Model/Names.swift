import Foundation

// VX-305 U1 — THE NAMES (design §3.2's homes column, §3.5). Every Keychain
// item and file the new system writes is named here and nowhere else, and
// EVERY item name carries the store-variant scope (`Variorum` /
// `Variorum-dev` — the A4 dev-store fence, pre-13x corner 47), so a Debug
// build never reads or writes the real store's items.
//
// The parsers are STRICT on purpose: scopes contain hyphens (`Variorum-dev`)
// and so do the UUIDs inside names, so a loose parse under the scope
// `Variorum` would read `Variorum-dev-…` items as its own. Each parser
// requires the exact prefix `<scope>-` AND a well-formed tail (sixteen hex
// for a fingerprint, a canonical UUID for an id), which a neighbouring
// scope's tail never is. (Today's names left with the legacy readers — rule
// 26, VX-378 U1.)

public enum ProtectionNames {
    // MARK: - Custody items — one per library key, of the key's kind for life

    /// The custody family's Keychain service (design §3.2).
    public static let custodyService = "io.lduarte.Variorum.library-key"

    /// The custody item's class — the key's kind for life: `silent` for a
    /// Standard key (`WhenUnlockedThisDeviceOnly`), `touchid` for a Castle key
    /// (`.biometryCurrentSet`). A Castle key under Always ask has no item.
    public enum CustodyClass: String, Codable, Sendable, CaseIterable {
        case silent
        case touchid

        /// The one custody class a key of `kind` may ever have.
        public static func `for`(_ kind: ProtectionMode) -> CustodyClass {
            kind == .standard ? .silent : .touchid
        }
    }

    /// `<scope>-<fingerprint16>-<class>`.
    public static func custodyAccount(scope: String, fingerprint: String, class itemClass: CustodyClass) -> String {
        "\(scope)-\(fingerprint)-\(itemClass.rawValue)"
    }

    /// The fingerprint and class a custody account names under `scope`, or nil
    /// for anything else (another scope's item included).
    public static func parseCustodyAccount(
        _ account: String, scope: String
    ) -> (fingerprint: String, class: CustodyClass)? {
        guard let tail = tail(of: account, afterScope: scope),
              let dash = tail.lastIndex(of: "-") else { return nil }
        let fingerprint = String(tail[..<dash])
        guard isFingerprint16(fingerprint),
              let itemClass = CustodyClass(rawValue: String(tail[tail.index(after: dash)...]))
        else { return nil }
        return (fingerprint, itemClass)
    }

    // MARK: - Sync keys — one item per account

    public static let syncKeysService = "io.lduarte.Variorum.sync-keys"

    /// `<scope>-<accountID>-<class>`.
    public static func syncKeysAccount(scope: String, accountID: String, class itemClass: CustodyClass) -> String {
        "\(scope)-\(accountID)-\(itemClass.rawValue)"
    }

    public static func parseSyncKeysAccount(
        _ account: String, scope: String
    ) -> (accountID: String, class: CustodyClass)? {
        guard let tail = tail(of: account, afterScope: scope),
              let dash = tail.lastIndex(of: "-") else { return nil }
        let accountID = String(tail[..<dash])
        guard isUUID(accountID),
              let itemClass = CustodyClass(rawValue: String(tail[tail.index(after: dash)...]))
        else { return nil }
        return (accountID, itemClass)
    }

    // MARK: - What this Mac remembers — one non-secret item per library ID

    public static let memoryService = "io.lduarte.Variorum.memory"

    /// `<scope>-<libraryID>`.
    public static func memoryAccount(scope: String, libraryID: String) -> String {
        "\(scope)-\(libraryID)"
    }

    public static func parseMemoryAccount(_ account: String, scope: String) -> String? {
        guard let tail = tail(of: account, afterScope: scope).map(String.init), isUUID(tail) else { return nil }
        return tail
    }

    // MARK: - Apple keys — named by their own id (design §3.5)

    /// The Apple-key family's service — today's (`AppleKeyKeychain.service`,
    /// App/Variorum/Shared/AppleKeyCustody.swift), kept.
    public static let appleKeyService = "io.lduarte.Variorum.apple-key"

    /// `<scope>-apple-key-<id>` — one per library per Mac, one per account.
    public static func appleKeyAccount(scope: String, id: String) -> String {
        "\(scope)-apple-key-\(id)"
    }

    /// The id an Apple-key account names under `scope` (nil for anything
    /// else — today's old shared name `<scope>-apple-key` among them, rule 26).
    public static func parseAppleKeyAccount(_ account: String, scope: String) -> String? {
        let prefix = "\(scope)-apple-key-"
        guard account.hasPrefix(prefix) else { return nil }
        let id = String(account.dropFirst(prefix.count))
        return isUUID(id) ? id : nil
    }

    // MARK: - Files

    /// The ONE key file beside the library — a name older builds never read
    /// (design §3.2).
    public static let keyFilename = "variorum-library-keys.json"
    /// The one plan beside the library (excluded from backups).
    public static let planFilename = "variorum-plan.json"
    /// `<library8>` — the library ID's first eight characters.
    public static func library8(_ libraryID: String) -> String { String(libraryID.prefix(8)) }
    /// `<mac8>` — the device identity's first eight characters (§3.2).
    public static func mac8(_ deviceID: String) -> String { String(deviceID.prefix(8)) }

    /// `Backups/<library8>/<mac8>` — where this Mac's copies of a library,
    /// and this Mac's own key file for another library, live (design §3.2,
    /// §3.5) — in the container, and beside this Mac's copies in the far
    /// folder.
    public static func backupsSubpath(libraryID: String, deviceID: String) -> String {
        "Backups/\(library8(libraryID))/\(mac8(deviceID))"
    }

    // MARK: - The shapes

    /// Sixteen lowercase hex characters — `StoreKeyEnvelope.fingerprint(of:)`.
    public static func isFingerprint16(_ value: String) -> Bool {
        value.count == 16 && value.allSatisfy { "0123456789abcdef".contains($0) }
    }

    /// A canonical 8-4-4-4-12 hex UUID string, either case.
    public static func isUUID(_ value: String) -> Bool {
        let groups = value.split(separator: "-", omittingEmptySubsequences: false)
        guard groups.map(\.count) == [8, 4, 4, 4, 12] else { return false }
        return groups.allSatisfy { $0.allSatisfy(\.isHexDigit) }
    }

    private static func tail(of account: String, afterScope scope: String) -> Substring? {
        let prefix = "\(scope)-"
        guard !scope.isEmpty, account.hasPrefix(prefix) else { return nil }
        return account.dropFirst(prefix.count)
    }
}
