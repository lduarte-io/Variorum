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
nonisolated enum StoreKeyKeychain {
    static let service = "io.lduarte.Variorum.store-key"

    static func load(scope: String) -> StoreKey? {
        var query = baseQuery(scope: scope)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return StoreKey(data: data)
    }

    @discardableResult
    static func save(_ key: StoreKey, scope: String) -> Bool {
        var attributes = baseQuery(scope: scope)
        attributes[kSecValueData as String] = key.data
        attributes[kSecAttrAccessible as String] =
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let update: [String: Any] = [kSecValueData as String: key.data]
            return SecItemUpdate(
                baseQuery(scope: scope) as CFDictionary, update as CFDictionary)
                == errSecSuccess
        }
        return status == errSecSuccess
    }

    private static func baseQuery(scope: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: scope,
        ]
    }
}
#else
nonisolated enum StoreKeyKeychain {
    static func load(scope: String) -> StoreKey? { nil }
    @discardableResult
    static func save(_ key: StoreKey, scope: String) -> Bool { false }
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
    /// Real bytes that are not the plaintext magic: an encrypted store (or
    /// something that is not a database at all — the keyed open decides,
    /// loudly).
    case encryptedOrUnknown

    /// `SQLite format 3\0` — public so drills and verification tooling can
    /// assert against the same sixteen bytes this classifier reads.
    public static let plaintextMagic = Data([
        0x53, 0x51, 0x4C, 0x69, 0x74, 0x65, 0x20, 0x66,
        0x6F, 0x72, 0x6D, 0x61, 0x74, 0x20, 0x33, 0x00,
    ])

    public static func classify(at url: URL) -> StoreFilePresence {
        guard let handle = try? FileHandle(forReadingFrom: url) else { return .absent }
        defer { try? handle.close() }
        guard let head = try? handle.read(upToCount: 16) else { return .absent }
        if head.isEmpty { return .absent }
        return head == plaintextMagic ? .plaintext : .encryptedOrUnknown
    }
}
