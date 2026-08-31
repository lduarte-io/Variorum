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

    /// The real device custody: one Keychain item per store scope (the
    /// store-variant raw value — `Variorum` vs `Variorum-dev` — so dev-build
    /// activity never shares key custody with her real library; the A4
    /// dev-store fence extended to keys). This is R13p-5's AUTO mode item:
    /// WhenUnlocked-class accessibility, no user presence, ThisDeviceOnly —
    /// the escrow item (a SEPARATE synchronizable item, R13p-6) and the
    /// biometric-gated item are Batch 2's.
    public static func deviceKeychain(scope: String) -> StoreKeyCustody {
        StoreKeyCustody(
            load: { StoreKeyKeychain.load(scope: scope) },
            save: { StoreKeyKeychain.save($0, scope: scope) })
    }

    /// Remove the device-Keychain item for `scope` (Phase 13p Batch 2 —
    /// the at-open mode transitions: entering Biometric or
    /// Passphrase-every-open DELETES the silently-releasing Auto item,
    /// because a gate whose key still releases silently is theater,
    /// R13p-14's exact prohibition). The one deletion door; the guard's
    /// custody choreography orders it AFTER the replacement custody lands.
    /// 17h (13p-fix ladder R3-5): answers whether the item is RELEASED —
    /// gone from BOTH keychains, or never there. A dropped delete status
    /// enforced the custody law in one direction only.
    @discardableResult
    public static func deviceKeychainRemove(scope: String) -> Bool {
        StoreKeyKeychain.delete(scope: scope)
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
    public static let liveValue = StoreKeyCustody.deviceKeychain(
        scope: AppDatabase.StoreVariant.real.rawValue)
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
/// releases silently; the demanded modes' gated item is Batch 2's).
///
/// **#82 (R-pre13u-3, pre-13u Act 9) — THE STORE KEY IS DEVICE-BOUND
/// NOW.** The 13p-fix R1-2 finding: `kSecAttrAccessible` is inert on
/// macOS without `kSecUseDataProtectionKeychain` (or synchronizable), so
/// this family's `…ThisDeviceOnly` class was NOT in force — the only key
/// to the encrypted library sat in `login.keychain-db`, which Migration
/// Assistant and Time Machine carry to OTHER HARDWARE, so a library
/// backup plus the account password opened it elsewhere. Her ruling:
/// *"binding the store key only — it closes the last gap where only a
/// computer password is enough to get your text."* Every query in this
/// family now merges the DP flag (see `KeychainPartition`'s app-layer
/// twin), and `load` runs the TN3137 read→re-add-with-flag→delete-old
/// migration for the pre-#82 file-based item: idempotent (the DP hit
/// short-circuits), crash-tolerant (a half-migrated state re-heals — a
/// lingering legacy copy is swept at the next DP hit, once per scope per
/// process), and the key is returned even when the migration itself is
/// refused (opening her store never hinges on the move; the next launch
/// retries). The write-verify-then-delete order is the app layer's
/// `CustodyHandover` discipline, restated here because core cannot see
/// that type — a write's success is never proof the item reads back.
///
/// SCOPE OF THE RULING: this family ONLY. The E2EE custody item and the
/// auth tokens stay file-based (their move is not ruled); the escrow item
/// is synchronizable BY DESIGN (the ruled recovery net, verified this
/// round); the gated items were always DP-resident.
///
/// Recorded consequence (the access group is part of a DP item's
/// identity): the migrated item belongs to the build configuration that
/// migrated it — `…io.lduarte.Variorum` for Release, `….debug` for
/// Debug — exactly as the gated family already does (the KnownIssues
/// Developer-ID row). The rare debug-build-with-real-store opt-in road
/// therefore reads no silent key post-migration and lands on the
/// sidecar-unlock recovery surface rather than opening silently; the
/// A4 fence keeps the two stores' scopes apart as always.
nonisolated enum StoreKeyKeychain {
    static let service = StoreKeyCustody.deviceKeychainService

    /// The BOUND item's account — distinct from the legacy account on
    /// purpose (the gated family's "the account carries the policy"
    /// pattern, `-biometric`'s sibling). MEASURED at this round's own
    /// pins: a PLAIN (no-ACL) data-protection item under the same
    /// service/account IS matched by a no-flag SecItemDelete — unlike the
    /// ACL'd items 13p-fix measured — so a shared account would let the
    /// legacy sweep destroy the bound item it had just verified. Distinct
    /// accounts make the two families structurally unable to touch each
    /// other, whatever a point release decides about cross-visibility.
    static func boundAccount(scope: String) -> String { "\(scope)-bound" }

    static func load(scope: String) -> StoreKey? {
        if let bound = read(scope: scope, dataProtection: true) {
            // Idempotent steady state — and the crash-window heal: a
            // legacy copy left by a crash between the DP add and the
            // legacy delete is swept here (once per scope per process;
            // leaving it would keep the Migration-Assistant gap open).
            sweepLegacyOnce(scope: scope)
            return bound
        }
        // The TN3137 migration road: the pre-#82 item lives file-based.
        guard let legacy = read(scope: scope, dataProtection: false) else { return nil }
        migrateLegacyItem(legacy, scope: scope)
        return legacy
    }

    @discardableResult
    static func save(_ key: StoreKey, scope: String) -> Bool {
        guard add(key, scope: scope) else { return false }
        // A fresh save supersedes any legacy copy outright (same
        // Migration-Assistant reasoning as the load-road sweep).
        deleteItem(scope: scope, dataProtection: false)
        return true
    }

    @discardableResult
    static func delete(scope: String) -> Bool {
        // BOTH keychains: a lingering legacy item under a demanded mode
        // would be a silently-readable copy — the theater R13p-14 forbids.
        // 17h R3-5: released = success or not-found, on BOTH legs — a
        // refusal on either leaves a copy the caller believes gone.
        let bound = deleteItem(scope: scope, dataProtection: true)
        let legacy = deleteItem(scope: scope, dataProtection: false)
        return bound && legacy
    }

    // MARK: - The #82 migration (write → VERIFY → delete old)

    private static func migrateLegacyItem(_ key: StoreKey, scope: String) {
        guard add(key, scope: scope) else { return }
        guard read(scope: scope, dataProtection: true) == key else {
            // The CustodyHandover rule's middle step: an unreadable write
            // releases nothing — roll the DP copy back best-effort and
            // leave the legacy item as the working custody; the next
            // launch retries.
            deleteItem(scope: scope, dataProtection: true)
            return
        }
        deleteItem(scope: scope, dataProtection: false)
    }

    private static func add(_ key: StoreKey, scope: String) -> Bool {
        var attributes = baseQuery(scope: scope, dataProtection: true)
        attributes[kSecValueData as String] = key.data
        // IN FORCE now that the DP flag rides the query (#82's point).
        attributes[kSecAttrAccessible as String] =
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let update: [String: Any] = [kSecValueData as String: key.data]
            return SecItemUpdate(
                baseQuery(scope: scope, dataProtection: true) as CFDictionary,
                update as CFDictionary) == errSecSuccess
        }
        return status == errSecSuccess
    }

    private static func read(scope: String, dataProtection: Bool) -> StoreKey? {
        var query = baseQuery(scope: scope, dataProtection: dataProtection)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return StoreKey(data: data)
    }

    @discardableResult
    private static func deleteItem(scope: String, dataProtection: Bool) -> Bool {
        let status = SecItemDelete(
            baseQuery(scope: scope, dataProtection: dataProtection) as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    private static func baseQuery(scope: String, dataProtection: Bool) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String:
                dataProtection ? boundAccount(scope: scope) : scope,
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
    nonisolated(unsafe) private static var sweptScopes: Set<String> = []

    private static func sweepLegacyOnce(scope: String) {
        sweepLock.lock()
        let alreadySwept = !sweptScopes.insert(scope).inserted
        sweepLock.unlock()
        guard !alreadySwept else { return }
        deleteItem(scope: scope, dataProtection: false)
    }
    // (No test-reset hook: pins use a FRESH throwaway scope per run, so
    // the per-scope sweep is always unconsumed where a pin needs it.)
}
#else
nonisolated enum StoreKeyKeychain {
    static func load(scope: String) -> StoreKey? { nil }
    @discardableResult
    static func save(_ key: StoreKey, scope: String) -> Bool { false }
    // No keychain ⇒ no item ⇒ trivially released (17h R3-5).
    @discardableResult
    static func delete(scope: String) -> Bool { true }
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
