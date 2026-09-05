import CryptoKit
import Dependencies
import Foundation
#if canImport(Security)
import Security
#endif

// Phase 13p, Batch 1 — the store key and its custody (THE DESIGN's key
// architecture, first slice): one random 256-bit key per store, minted at
// migration (existing stores) or first launch (new stores), held in the
// device Keychain under the Auto at-open mode. Batch 2 adds the wrapped
// copies (passphrase / recovery phrase / escrow) and the demanded modes;
// they extend THIS seam rather than adding a second one.

/// The whole-store SQLCipher key: 32 random bytes (AES-256). Deliberately
/// NOT the sync master key (R13p-4): a local-only signed-out user has a
/// store key with no account, and sync enrollment composes beside it.
public struct StoreKey: Equatable, Sendable {
    /// Exactly 32 bytes.
    public let data: Data

    public init?(data: Data) {
        guard data.count == 32 else { return nil }
        self.data = data
    }

    public init?(hexEncoded: String) {
        guard hexEncoded.count == 64 else { return nil }
        var bytes = Data(capacity: 32)
        var index = hexEncoded.startIndex
        while index < hexEncoded.endIndex {
            let next = hexEncoded.index(index, offsetBy: 2)
            guard let byte = UInt8(hexEncoded[index..<next], radix: 16) else { return nil }
            bytes.append(byte)
            index = next
        }
        self.init(data: bytes)
    }

    /// 64 lowercase hex characters — the `x'…'` pragma literal's payload.
    public var hexEncoded: String {
        data.map { String(format: "%02x", $0) }.joined()
    }

    /// A fresh random 256-bit key (CryptoKit's CSPRNG — the same mint the
    /// 14b vault keys use).
    public static func mint() -> StoreKey {
        let symmetric = SymmetricKey(size: .bits256)
        let bytes = symmetric.withUnsafeBytes { Data($0) }
        guard let key = StoreKey(data: bytes) else {
            fatalError("SymmetricKey(.bits256) yielded a non-32-byte key")
        }
        return key
    }
}

extension StoreKey: CustomStringConvertible, CustomDebugStringConvertible {
    /// Redacted on purpose: a store key must never ride into a log line by
    /// way of an interpolation.
    public var description: String { "StoreKey(256-bit, redacted)" }
    public var debugDescription: String { description }

    /// P15 (pre-13u Act 9, 17a): exactly two statements embed this key as
    /// a literal — the raw-key `PRAGMA key` (which SQLite cannot bind a
    /// parameter into) and the migration's `ATTACH … KEY` — and GRDB's
    /// `DatabaseError.description` appends the executed SQL verbatim, so
    /// an error thrown BY either statement carried the full hex onto the
    /// store-failure screen (selectable text) and into the backup log's
    /// UserDefaults record. Both sites catch-and-sanitize through this:
    /// the error's text with every occurrence of the hex scrubbed.
    public func redactedDescription(of error: any Error) -> String {
        String(describing: error)
            .replacingOccurrences(of: hexEncoded, with: "<store key redacted>")
    }
}

/// P15: the sanitized replacement thrown where a key-bearing statement
/// failed. Its `description` AND `localizedDescription` carry the scrubbed
/// text, so every downstream channel (`String(describing:)` into
/// `StoreOpenError.reason`, `error.localizedDescription` into the backup
/// log) reads the same key-free sentence.
public struct RedactedKeyedStatementError: Error, CustomStringConvertible, LocalizedError, Sendable {
    public let description: String
    public var errorDescription: String? { description }
    public init(description: String) { self.description = description }
}

/// Persistence seam for the store key — the `DeviceKeyStore` pattern
/// (EncryptionKeychain.swift): production is the device Keychain; tests
/// inject in-memory doubles and NEVER touch the real Keychain (the default
/// test-context custody below guarantees it).
public struct StoreKeyCustody: Sendable {
    /// The held key, or nil when this device holds none (fresh install, or
    /// a lost/cleared item — the open path refuses rather than guesses).
    public var load: @Sendable () -> StoreKey?
    /// Persist the key. `false` means custody could NOT keep it — the open
    /// path must then refuse to create an encrypted store (a store whose
    /// key cannot be kept would be unopenable at the next launch).
    public var save: @Sendable (StoreKey) -> Bool

    public init(
        load: @escaping @Sendable () -> StoreKey?,
        save: @escaping @Sendable (StoreKey) -> Bool
    ) {
        self.load = load
        self.save = save
    }
}

extension StoreKeyCustody {
    /// The device-Keychain SERVICE the store-key custody family lives
    /// under — public so the app layer's gated item (Phase 13p Batch 2)
    /// joins the same family by account rather than re-declaring the
    /// string and drifting.
    public static let deviceKeychainService = "io.lduarte.Variorum.store-key"

    /// The real device custody (pre-13x 1a: PER STORE ID — the postures
    /// design §1.13 / §14.3): one Keychain item per (scope, store id). The
    /// scope is the store-variant raw value — `Variorum` vs `Variorum-dev`,
    /// so dev-build activity never shares key custody with her real library
    /// (the A4 dev-store fence extended to keys) — and the store id is the
    /// LIBRARY's identity, read from the key file beside `storeURL` without
    /// the key (`StoreIdentity`); a machine with no item for a store id has
    /// never opened that library, so a copied library gets a fresh key mint
    /// ONLY where the design allows one (never over ciphertext). This is
    /// R13p-5's AUTO / the design's Standard silent item: WhenUnlocked-class
    /// accessibility, no user presence, ThisDeviceOnly, data-protection
    /// resident. The mint road WRITES THE KEY FILE (store id + fingerprint,
    /// no wraps) before the Keychain add, so the item's name exists on disk
    /// before the item does.
    public static func deviceKeychain(scope: String, storeURL: URL) -> StoreKeyCustody {
        StoreKeyCustody(
            load: { StoreKeyKeychain.load(scope: scope, storeURL: storeURL) },
            save: { StoreKeyKeychain.save($0, scope: scope, storeURL: storeURL) })
    }

    /// The same custody with the store id KNOWN (the app's gated family
    /// resolves it per act; tests use throwaway scopes + ids).
    public static func deviceKeychain(scope: String, storeID: String) -> StoreKeyCustody {
        StoreKeyCustody(
            load: { StoreKeyKeychain.load(scope: scope, storeID: storeID) },
            save: { StoreKeyKeychain.save($0, scope: scope, storeID: storeID) })
    }

    /// Remove the device-Keychain item for (scope, store id) (Phase 13p
    /// Batch 2 — the at-open mode transitions: entering Biometric or
    /// Passphrase-every-open DELETES the silently-releasing Auto item,
    /// because a gate whose key still releases silently is theater,
    /// R13p-14's exact prohibition). The one deletion door; the guard's
    /// custody choreography orders it AFTER the replacement custody lands.
    /// 17h (13p-fix ladder R3-5): answers whether the item is RELEASED —
    /// gone from BOTH keychains and the legacy accounts, or never there. A
    /// dropped delete status enforced the custody law in one direction only.
    @discardableResult
    public static func deviceKeychainRemove(scope: String, storeID: String) -> Bool {
        StoreKeyKeychain.delete(scope: scope, storeID: storeID)
    }

    /// The store-URL form of the delete: the id read from the key file; with
    /// no key file only the legacy shapes can exist, and they are released.
    @discardableResult
    public static func deviceKeychainRemove(scope: String, storeURL: URL) -> Bool {
        if case .known(let storeID) = StoreIdentity.resolve(besideStore: storeURL) {
            return StoreKeyKeychain.delete(scope: scope, storeID: storeID)
        }
        return StoreKeyKeychain.deleteLegacy(scope: scope)
    }

    /// A scriptable in-memory custody for tests and drills.
    public static func inMemory(initial: StoreKey? = nil) -> StoreKeyCustody {
        let box = InMemoryStoreKeyBox(initial: initial)
        return StoreKeyCustody(
            load: { box.value },
            save: { box.value = $0; return true })
    }

    /// The test-context default (`testValue`): ONE stable random key per
    /// process, never the Keychain. Stable-per-process on purpose — tests
    /// open, back up, copy, and REOPEN scratch stores, often concurrently,
    /// and a per-call key would make one test's store unopenable the moment
    /// another test's open ran; the Keychain is exactly what unsigned CLI
    /// test runners cannot (and must never) touch. `save` accepts and
    /// discards: `load` never returns nil here, so the mint road never runs
    /// under the default test custody — a test exercising mint/save
    /// semantics injects `.inMemory()` explicitly.
    static let processEphemeral: StoreKeyCustody = {
        let key = StoreKey.mint()
        return StoreKeyCustody(load: { key }, save: { _ in true })
    }()
}

nonisolated private final class InMemoryStoreKeyBox: @unchecked Sendable {
    private let lock = NSLock()
    private var stored: StoreKey?
    init(initial: StoreKey?) { stored = initial }
    var value: StoreKey? {
        get { lock.lock(); defer { lock.unlock() }; return stored }
        set { lock.lock(); defer { lock.unlock() }; stored = newValue }
    }
}

extension StoreKeyCustody: DependencyKey {
    /// The real store's Keychain custody. The app shell overrides the SCOPE
    /// explicitly per resolved store variant (AppBootstrap); this default
    /// serves the package's own `liveValue` open, which targets the real
    /// store by construction.
    public static let liveValue: StoreKeyCustody = {
        let scope = AppDatabase.StoreVariant.real.rawValue
        guard let url = try? AppDatabase.defaultStoreURL(variant: .real) else {
            // No resolvable store home ⇒ no custody (the open refuses typed).
            return StoreKeyCustody(load: { nil }, save: { _ in false })
        }
        return StoreKeyCustody.deviceKeychain(scope: scope, storeURL: url)
    }()
    /// See `processEphemeral` — never the Keychain in a test process.
    public static let testValue = StoreKeyCustody.processEphemeral
}

extension DependencyValues {
    public var storeKeyCustody: StoreKeyCustody {
        get { self[StoreKeyCustody.self] }
        set { self[StoreKeyCustody.self] = newValue }
    }
}

#if canImport(Security)
/// The Keychain half — the `E2EEKeychainStorage` pattern, its own service
/// so neither surface's clear can touch the other. The item class per the
/// batch brief: `WhenUnlockedThisDeviceOnly`, no access control (Auto mode
/// releases silently; the demanded modes' gated item is the app layer's).
///
/// **#82 (R-pre13u-3, pre-13u Act 9) — THE STORE KEY IS DEVICE-BOUND.**
/// The 13p-fix R1-2 finding: `kSecAttrAccessible` is inert on macOS
/// without `kSecUseDataProtectionKeychain` (or synchronizable), so this
/// family's `…ThisDeviceOnly` class was NOT in force — the only key to the
/// encrypted library sat in `login.keychain-db`, which Migration Assistant
/// and Time Machine carry to OTHER HARDWARE. Every query in this family
/// merges the DP flag, and `load` runs the TN3137 read→re-add-with-flag→
/// delete-old migration: idempotent (the hit short-circuits),
/// crash-tolerant (a half-migrated state re-heals — a lingering legacy copy
/// is swept at the next hit, once per account per process), and the key is
/// returned even when the migration itself is refused (opening never
/// hinges on the move; the next launch retries). The write-verify-then-
/// delete order is the app layer's `CustodyHandover` discipline, restated
/// here because core cannot see that type.
///
/// **pre-13x 1a — PER STORE ID (§1.13 / §14.3).** The bound item's
/// account is `<scope>-<storeID>-bound`; the two LEGACY shapes — the
/// #82-era `<scope>-bound` (DP) and the 13p-era `<scope>` (file-based) —
/// migrate onto it by the SAME road the moment a store id is in hand:
/// read legacy → re-add under the store id → verify through the
/// production read → delete the legacy copy. A second store under the
/// same scope names a different account, so it can never read the
/// first's key (the collision pin); the legacy item, once migrated, is
/// gone, so a second store's first load finds nothing and mints.
///
/// Recorded consequence (the access group is part of a DP item's
/// identity): the item belongs to the build configuration that wrote it —
/// `…io.lduarte.Variorum` for Release, `….debug` for Debug — exactly as
/// the gated family already does (the KnownIssues Developer-ID row).
nonisolated enum StoreKeyKeychain {
    static let service = StoreKeyCustody.deviceKeychainService

    /// The per-store BOUND item's account (pre-13x 1a).
    static func boundAccount(scope: String, storeID: String) -> String {
        "\(scope)-\(storeID)-bound"
    }
    /// The #82-era legacy bound account (DP; no store id).
    static func legacyBoundAccount(scope: String) -> String { "\(scope)-bound" }

    // MARK: - The store-URL road (the app's open; the store id from the key file)

    static func load(scope: String, storeURL: URL) -> StoreKey? {
        switch StoreIdentity.resolve(besideStore: storeURL) {
        case .known(let storeID):
            return load(scope: scope, storeID: storeID)
        case .none:
            // No key file yet: only a legacy item could hold this
            // library's key (a pre-1a store that never landed a wrap).
            // Hand the key back WITHOUT migrating — the id is minted by
            // `save`'s road, and `establish` below re-scopes the item the
            // moment the key file exists.
            guard let legacy = readLegacy(scope: scope) else { return nil }
            guard let storeID = try? StoreIdentity.establish(besideStore: storeURL, key: legacy)
            else { return legacy }
            migrateLegacyItems(legacy, scope: scope, storeID: storeID)
            return legacy
        case .unreadable:
            // P1/P11: an unreadable key file is a REFUSAL to write anything
            // beside it — the id cannot be known, so no re-scoping happens;
            // a legacy item still opens the library.
            return readLegacy(scope: scope)
        }
    }

    @discardableResult
    static func save(_ key: StoreKey, scope: String, storeURL: URL) -> Bool {
        // The key file FIRST (store id + fingerprint, no wraps): the item's
        // name must exist on disk before the item does, or the next launch
        // could not find it.
        guard let storeID = try? StoreIdentity.establish(besideStore: storeURL, key: key)
        else { return false }
        return save(key, scope: scope, storeID: storeID)
    }

    // MARK: - The store-id road

    static func load(scope: String, storeID: String) -> StoreKey? {
        if let bound = read(account: boundAccount(scope: scope, storeID: storeID), dataProtection: true) {
            // Idempotent steady state — and the crash-window heal: a
            // legacy copy left by a crash between the add and the legacy
            // delete is swept here (once per account per process).
            sweepLegacyOnce(scope: scope, storeID: storeID)
            return bound
        }
        guard let legacy = readLegacy(scope: scope) else { return nil }
        migrateLegacyItems(legacy, scope: scope, storeID: storeID)
        return legacy
    }

    @discardableResult
    static func save(_ key: StoreKey, scope: String, storeID: String) -> Bool {
        guard add(key, account: boundAccount(scope: scope, storeID: storeID)) else { return false }
        // A fresh save supersedes any legacy copy outright (same
        // Migration-Assistant reasoning as the load-road sweep).
        deleteLegacyItems(scope: scope)
        return true
    }

    @discardableResult
    static func delete(scope: String, storeID: String) -> Bool {
        // The bound item AND both legacy shapes: a lingering legacy item
        // under a demanded mode would be a silently-readable copy — the
        // theater R13p-14 forbids. 17h R3-5: released = success or
        // not-found, on EVERY leg — a refusal on any leaves a copy the
        // caller believes gone.
        let bound = deleteItem(account: boundAccount(scope: scope, storeID: storeID), dataProtection: true)
        return deleteLegacyItems(scope: scope) && bound
    }

    // MARK: - The legacy shapes (read; migrate; delete)

    /// The #82-era DP item, else the 13p-era file-based item.
    private static func readLegacy(scope: String) -> StoreKey? {
        read(account: legacyBoundAccount(scope: scope), dataProtection: true)
            ?? read(account: scope, dataProtection: false)
    }

    /// TN3137: write → VERIFY → delete old. An unreadable write releases
    /// nothing — roll the new copy back best-effort and leave the legacy
    /// item as the working custody; the next launch retries.
    private static func migrateLegacyItems(_ key: StoreKey, scope: String, storeID: String) {
        let account = boundAccount(scope: scope, storeID: storeID)
        guard add(key, account: account) else { return }
        guard read(account: account, dataProtection: true) == key else {
            deleteItem(account: account, dataProtection: true)
            return
        }
        deleteLegacyItems(scope: scope)
    }

    /// The legacy shapes alone (a store with no key file can hold nothing
    /// else).
    @discardableResult
    static func deleteLegacy(scope: String) -> Bool { deleteLegacyItems(scope: scope) }

    @discardableResult
    private static func deleteLegacyItems(scope: String) -> Bool {
        let bound = deleteItem(account: legacyBoundAccount(scope: scope), dataProtection: true)
        let file = deleteItem(account: scope, dataProtection: false)
        return bound && file
    }

    // MARK: - The Sec* leaves

    private static func add(_ key: StoreKey, account: String) -> Bool {
        var attributes = baseQuery(account: account, dataProtection: true)
        attributes[kSecValueData as String] = key.data
        // IN FORCE now that the DP flag rides the query (#82's point).
        attributes[kSecAttrAccessible as String] =
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let update: [String: Any] = [kSecValueData as String: key.data]
            return SecItemUpdate(
                baseQuery(account: account, dataProtection: true) as CFDictionary,
                update as CFDictionary) == errSecSuccess
        }
        return status == errSecSuccess
    }

    private static func read(account: String, dataProtection: Bool) -> StoreKey? {
        var query = baseQuery(account: account, dataProtection: dataProtection)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return StoreKey(data: data)
    }

    @discardableResult
    private static func deleteItem(account: String, dataProtection: Bool) -> Bool {
        let status = SecItemDelete(
            baseQuery(account: account, dataProtection: dataProtection) as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    private static func baseQuery(account: String, dataProtection: Bool) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        // The one rule the whole 13p-fix incident taught: a DP-resident
        // family merges the flag on EVERY query, or reads and writes
        // disagree about which keychain they mean. (The app layer's
        // `KeychainPartition` states it; core restates it here.)
        if dataProtection {
            query[kSecUseDataProtectionKeychain as String] = true
        }
        return query
    }

    // MARK: - The once-per-process legacy sweep

    private static let sweepLock = NSLock()
    nonisolated(unsafe) private static var sweptAccounts: Set<String> = []

    private static func sweepLegacyOnce(scope: String, storeID: String) {
        sweepLock.lock()
        let alreadySwept = !sweptAccounts.insert(boundAccount(scope: scope, storeID: storeID)).inserted
        sweepLock.unlock()
        guard !alreadySwept else { return }
        deleteLegacyItems(scope: scope)
    }
    // (No test-reset hook: pins use a FRESH throwaway scope per run, so
    // the per-account sweep is always unconsumed where a pin needs it.)
}
#else
nonisolated enum StoreKeyKeychain {
    static func load(scope: String, storeURL: URL) -> StoreKey? { nil }
    static func load(scope: String, storeID: String) -> StoreKey? { nil }
    @discardableResult
    static func save(_ key: StoreKey, scope: String, storeURL: URL) -> Bool { false }
    @discardableResult
    static func save(_ key: StoreKey, scope: String, storeID: String) -> Bool { false }
    // No keychain ⇒ no item ⇒ trivially released (17h R3-5).
    @discardableResult
    static func delete(scope: String, storeID: String) -> Bool { true }
    @discardableResult
    static func deleteLegacy(scope: String) -> Bool { true }
}
#endif

/// What sits at a store URL, read from the file's first bytes — the
/// migration trigger and the open path's routing fact.
public enum StoreFilePresence: Equatable, Sendable {
    /// No file (or an empty one): a fresh store will be created here.
    case absent
    /// The bytes lead with SQLite's plaintext magic — a pre-13p store, the
    /// one-time migration's subject.
    case plaintext
    /// Real bytes that are not the plaintext magic — an encrypted store,
    /// something that is not a database at all, OR a present file that
    /// refused to open/read (pre-13u Act 9, 17a P12/P13): the keyed open
    /// decides, loudly.
    case encryptedOrUnknown

    /// `SQLite format 3\0` — public so drills and verification tooling can
    /// assert against the same sixteen bytes this classifier reads.
    public static let plaintextMagic = Data([
        0x53, 0x51, 0x4C, 0x69, 0x74, 0x65, 0x20, 0x66,
        0x6F, 0x72, 0x6D, 0x61, 0x74, 0x20, 0x33, 0x00,
    ])

    /// Pre-13u Act 9 (17a P12/P13): a PRESENT file whose open or read
    /// fails (EACCES after an oddly-permissioned restore, fd exhaustion,
    /// EIO, an unsatisfied iOS protection class) used to answer `.absent`
    /// — indistinguishable from "no store here". Two irreversible things
    /// keyed off that answer: the launch route PERSISTED a mode downgrade
    /// to Auto (silently turning off the R13p-5 gate), and `resolveStoreKey`
    /// skipped its never-mint-over-ciphertext refusal, minting and SAVING
    /// a bogus key whose later failures were untyped — a doorless dead
    /// end that survived the I/O condition clearing. Present-but-unreadable
    /// now answers `.encryptedOrUnknown`: the route stays demanded, the
    /// open refuses typed (`keyUnavailable`), and the sidecar recovery
    /// road can render. A present-but-EMPTY file stays `.absent` — that
    /// half of the doc is deliberate and unchanged.
    public static func classify(at url: URL) -> StoreFilePresence {
        let present = FileManager.default.fileExists(atPath: url.path)
        guard let handle = try? FileHandle(forReadingFrom: url) else {
            return present ? .encryptedOrUnknown : .absent
        }
        defer { try? handle.close() }
        do {
            // nil WITHOUT a throw is EOF — an empty file, which is the
            // deliberate `.absent` half; only a THROWING read is the
            // unreadable case.
            guard let head = try handle.read(upToCount: 16), !head.isEmpty else {
                return .absent
            }
            return head == plaintextMagic ? .plaintext : .encryptedOrUnknown
        } catch {
            return .encryptedOrUnknown
        }
    }
}
