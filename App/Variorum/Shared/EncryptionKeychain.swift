//
//  EncryptionKeychain.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 14b, batch 3 (L8's custody half) — per-device Keychain custody of
//  the unwrapped E2EE keys (rulings R-4/R-6): enrollment unwraps ONCE, the
//  material persists in the device Keychain (hardware-backed, per-device),
//  and day-to-day sync stays invisible — the enrollment-only cadence.
//  Distinct service from the auth sessions' items, exactly the 9c pattern
//  (KeychainAuthStorage), so sign-out never disturbs key custody and vice
//  versa.
//
//  pre-13x batch 1a — THE SYNC KEYS AND THE DEVICE IDENTITY LIVE IN
//  PER-STORE CUSTODY BESIDE THE LIBRARY KEY, NEVER IN THE LIBRARY FILE
//  (the postures design §1.3 / §1.13 / §3.3). ONE item family, keyed
//  `<scope>-<storeID>-sync`, carrying `SyncCustodyRecord` — the master key,
//  the corpus key (+ id), the dormant journal class key (+ id) and the
//  DEVICE IDENTITY — in the LIBRARY KEY'S OWN THREE SHAPES:
//    · Standard / Auto     ⇒ the SILENT device-only item (data-protection,
//                            `WhenUnlockedThisDeviceOnly`);
//    · Castle, Touch ID    ⇒ the BIOMETRIC item (`.biometryCurrentSet`
//                            alone; read ONCE per unlock under the SAME
//                            evaluated context as the library key — one
//                            Touch ID prompt — into the session memory);
//    · Castle, Always ask  ⇒ NO key item: an IDENTITY-ONLY bound item (so
//                            the library keeps its identity across opens)
//                            and the sync keys held in `SyncCustodySession`
//                            for the unlocked session, obtained from the
//                            vault by the typed word (batch 4); an offline
//                            unlock keeps the DERIVED wrapping key there —
//                            never the typed word — and a relock drops it
//                            (decision 10).
//  A copy of the file is writing, never a device: a machine with no
//  custody for a store id has never opened that library and gets a fresh
//  identity when it enrolls. The 14b/CF-12 fixed-account items
//  (`device-keys` / `device-keys-biometric`), the CF-12 opt-in sync gate
//  (`SyncGateOptIn`) and the once-per-launch cache (`E2EELaunchKeyCache`)
//  are GONE — custody follows the library key's posture, never a toggle;
//  `SyncCustodyMigration` (§11, behind a seam, run at batch 2) re-scopes
//  the legacy items on her two devices.
//
//  `DeviceKeyStore` is the injectable seam (the AuthTokensStore pattern):
//  tests script custody AND the session through `InMemoryKeyBacking` — no
//  test ever touches the real Keychain or LocalAuthentication; the
//  LAContext lives only inside the guard's one unlock.
//

import CryptoKit
import Foundation
import LocalAuthentication
import Security
import VariorumCore

// MARK: - The record, the shapes, the naming, the session memory

/// What the per-store sync custody item holds: the unwrapped E2EE keys
/// (nil under Always ask — they live in session memory) and THIS DEVICE'S
/// IDENTITY for this library's sync (§1.13 — the `device_id` the pull
/// carries; the purge horizon's substrate). Codable so the item is one
/// JSON blob, the `AuthTokens` custody pattern.
nonisolated struct SyncCustodyRecord: Codable, Equatable, Sendable {
    var deviceID: String
    var material: DeviceKeyMaterial?

    static func fresh(material: DeviceKeyMaterial? = nil) -> SyncCustodyRecord {
        SyncCustodyRecord(deviceID: UUID().uuidString.lowercased(), material: material)
    }
}

/// The library key's three custody shapes, applied to the sync item
/// (§3.3): custody follows posture, never a toggle.
nonisolated enum SyncCustodyShape: Equatable, Sendable {
    /// Standard / Auto: the silent bound item holds the record whole.
    case silent
    /// Castle with Touch ID / Face ID: the gated item holds the record;
    /// the bound item holds the identity alone.
    case biometric
    /// Castle, Always ask: no key item — the bound item holds the identity
    /// alone; the keys live in `SyncCustodySession` for the session.
    case sessionOnly

    init(mode: StoreAtOpenMode) {
        switch mode {
        case .auto: self = .silent
        case .biometric: self = .biometric
        case .passphrase: self = .sessionOnly
        }
    }
}

/// The per-store naming (the store-key family's `<scope>-<storeID>-…`
/// pattern; the scope discriminator keeps a dev build's custody apart
/// from the installed build's — the A4 fence).
nonisolated struct SyncCustodyScope: Equatable, Sendable {
    let scope: String
    let storeID: String
    var boundAccount: String { "\(scope)-\(storeID)-sync" }
    var gatedAccount: String { "\(scope)-\(storeID)-sync-biometric" }
    var probeAccount: String { "\(gatedAccount)-probe" }
}

/// THE SESSION MEMORY (replaces `E2EELaunchKeyCache`): what an unlocked
/// session holds that no item does — the record read from the gated item
/// at the lobby's one Touch ID unlock (Castle), or the record the vault
/// road handed over (Always ask), and — decision 10's exception — the
/// DERIVED wrapping key of an offline Always-ask unlock, kept so a vault
/// read after connectivity returns can fetch the master; never the typed
/// word. `drop()` at relock empties all of it (pinned). Process-global in
/// production (one store per process; the bootstrap's lock drops it) and
/// INJECTABLE — tests hold their own instances.
nonisolated final class SyncCustodySession: @unchecked Sendable {
    static let shared = SyncCustodySession()
    private let lock = NSLock()
    private var storedRecord: SyncCustodyRecord?
    private var storedDerivedKey: SymmetricKey?

    init() {}

    var record: SyncCustodyRecord? {
        lock.lock(); defer { lock.unlock() }
        return storedRecord
    }
    /// The derived wrapping key of an offline Always-ask unlock (§3.3).
    var derivedWrappingKey: SymmetricKey? {
        lock.lock(); defer { lock.unlock() }
        return storedDerivedKey
    }

    func hold(_ record: SyncCustodyRecord) {
        lock.lock(); defer { lock.unlock() }
        storedRecord = record
    }

    func holdDerivedWrappingKey(_ key: SymmetricKey) {
        lock.lock(); defer { lock.unlock() }
        storedDerivedKey = key
    }

    /// Relock: everything the session held is gone (pinned).
    func drop() {
        lock.lock(); defer { lock.unlock() }
        storedRecord = nil
        storedDerivedKey = nil
    }
}

// MARK: - The custody seam

/// 17h (13p-fix ladder R3-4): the Keychain LEAVES behind a seam, so the
/// handover WIRING — which delete plays the outgoing role and which the
/// rollback, per direction — is pinned with a recording fake. pre-13x 1a:
/// per store (`live(scope:)`); the record replaces the bare material.
nonisolated struct E2EECustodyLeaves: Sendable {
    var saveGated: @Sendable (SyncCustodyRecord) -> Bool
    var savePlain: @Sendable (SyncCustodyRecord) -> Bool
    var loadPlain: @Sendable () -> SyncCustodyRecord?
    var gatedExists: @Sendable () -> Bool
    var deletePlain: @Sendable () -> Bool
    var deleteGated: @Sendable () -> Bool

    static func live(scope: SyncCustodyScope) -> E2EECustodyLeaves {
        E2EECustodyLeaves(
            saveGated: { E2EEKeychainStorage.saveGated($0, scope: scope) },
            savePlain: { E2EEKeychainStorage.save($0, scope: scope) },
            loadPlain: { E2EEKeychainStorage.load(scope: scope) },
            gatedExists: { E2EEKeychainStorage.gatedItemExists(scope: scope) },
            deletePlain: { E2EEKeychainStorage.deletePlainItem(scope: scope) },
            deleteGated: { E2EEKeychainStorage.deleteGatedItem(scope: scope) })
    }
}

/// The custody TRANSITION for the sync record between the silent and the
/// gated shapes, behind a seam so it can be pinned (13p-fix R2-1). Both
/// arms run the `CustodyHandover` rule: write, verify through the
/// production read path, only then delete the other half. pre-13x: the
/// library key's own mode transition (batch 2) drives this beside the
/// store-key handover, so the two families move together.
nonisolated struct E2EECustodyStorage: Sendable {
    var setGated: @Sendable (SyncCustodyRecord) -> CustodyHandover.Outcome
    var setPlain: @Sendable (SyncCustodyRecord) -> CustodyHandover.Outcome

    static func live(scope: SyncCustodyScope) -> E2EECustodyStorage {
        wired(leaves: .live(scope: scope))
    }

    static func wired(leaves: E2EECustodyLeaves) -> E2EECustodyStorage {
        E2EECustodyStorage(
            setGated: { record in
                CustodyHandover.perform(
                    write: { leaves.saveGated(record) },
                    // Presence only: reading an ACL'd item's DATA prompts, and
                    // a write must never prompt (R2-4's forced exception).
                    verify: { leaves.gatedExists() },
                    // The bound item stays as the IDENTITY-ONLY item under
                    // the biometric shape — the material leaves it.
                    deleteOutgoing: { leaves.savePlain(SyncCustodyRecord(deviceID: record.deviceID, material: nil)) },
                    rollBackIncoming: { _ = leaves.deleteGated() })
            },
            setPlain: { record in
                CustodyHandover.perform(
                    write: { leaves.savePlain(record) },
                    verify: { leaves.loadPlain() == record },
                    deleteOutgoing: { leaves.deleteGated() },
                    rollBackIncoming: { _ = leaves.deletePlain() })
            })
    }
}

/// Persistence seam for the device's sync custody (tests inject in-memory;
/// production is the Keychain) — the `AuthTokensStore` pattern.
nonisolated struct DeviceKeyStore: Sendable {
    /// Non-prompting read of the unwrapped material: the session's record
    /// first (Castle: filled by the lobby's one gated read / the vault
    /// road), else the silent item's (Standard). nil = locked, not
    /// enrolled, or Always ask before the vault road — the sync key
    /// provider reads THIS, which is exactly how "a locked library reads
    /// as no keys" happens.
    var load: @Sendable () -> DeviceKeyMaterial?
    /// Persist under the CURRENT shape (the library key's mode): silent ⇒
    /// the bound item whole; biometric ⇒ the gated item (+ the session,
    /// since the device that just proved the passphrase is unlocked) and
    /// the identity-only bound item; session-only ⇒ the session + the
    /// identity-only bound item. A record's identity is kept across saves.
    var save: @Sendable (DeviceKeyMaterial) -> Bool
    /// The forget door's act (CF-11): the MATERIAL goes from every item and
    /// from the session; the identity stays (this machine has opened this
    /// library). The account vault is untouched.
    var clear: @Sendable () -> Void
    /// This device's identity for this library (§1.13): the record's, from
    /// the session or the bound item; MINTED into the bound item when the
    /// library has never had one on this machine (a fresh library, a copy
    /// from elsewhere, a wiped Keychain — §14.37's returner).
    var deviceID: @Sendable () -> String

    /// The production factory: per store (the id read from the key file
    /// beside `storeURL` at each call — nil ⇒ no custody), the shape read
    /// from the store's dials, the session shared with the bootstrap's
    /// lock road.
    static func keychain(
        scope: String, storeURL: URL?,
        session: SyncCustodySession = .shared,
        defaults: @escaping @Sendable () -> UserDefaults = { .standard }
    ) -> DeviceKeyStore {
        @Sendable func custodyScope() -> SyncCustodyScope? {
            guard let storeURL,
                  case .known(let id) = StoreIdentity.resolve(besideStore: storeURL)
            else { return nil }
            return SyncCustodyScope(scope: scope, storeID: id)
        }
        @Sendable func shape(_ custody: SyncCustodyScope) -> SyncCustodyShape {
            SyncCustodyShape(mode: ProtectionDefaults.dials(
                scope: scope, storeID: custody.storeID, in: defaults()).mode)
        }
        return DeviceKeyStore(
            load: {
                if let held = session.record?.material { return held }
                guard let custody = custodyScope() else { return nil }
                switch shape(custody) {
                case .silent:
                    return E2EEKeychainStorage.load(scope: custody)?.material
                case .biometric, .sessionOnly:
                    // The gated item is unreadable without a prompt, and the
                    // session-only shape holds no item: locked until the
                    // lobby's unlock fills the session — never prompt from
                    // here (this path runs at sync-round cadence).
                    return nil
                }
            },
            save: { material in
                guard let custody = custodyScope() else { return false }
                let identity = session.record?.deviceID
                    ?? E2EEKeychainStorage.load(scope: custody)?.deviceID
                    ?? UUID().uuidString.lowercased()
                let record = SyncCustodyRecord(deviceID: identity, material: material)
                let identityOnly = SyncCustodyRecord(deviceID: identity, material: nil)
                switch shape(custody) {
                case .silent:
                    guard E2EEKeychainStorage.save(record, scope: custody) else { return false }
                    _ = E2EEKeychainStorage.deleteGatedItem(scope: custody)
                    return true
                case .biometric:
                    guard E2EEKeychainStorage.saveGated(record, scope: custody) else { return false }
                    _ = E2EEKeychainStorage.save(identityOnly, scope: custody)
                    session.hold(record)
                    return true
                case .sessionOnly:
                    guard E2EEKeychainStorage.save(identityOnly, scope: custody) else { return false }
                    _ = E2EEKeychainStorage.deleteGatedItem(scope: custody)
                    session.hold(record)
                    return true
                }
            },
            clear: {
                let identity = session.record?.deviceID
                session.drop()
                guard let custody = custodyScope() else { return }
                let kept = identity ?? E2EEKeychainStorage.load(scope: custody)?.deviceID
                _ = E2EEKeychainStorage.deleteGatedItem(scope: custody)
                if let kept {
                    _ = E2EEKeychainStorage.save(SyncCustodyRecord(deviceID: kept, material: nil), scope: custody)
                } else {
                    _ = E2EEKeychainStorage.deletePlainItem(scope: custody)
                }
            },
            deviceID: {
                if let held = session.record?.deviceID { return held }
                guard let custody = custodyScope() else {
                    // No key file yet: no custody can exist — a session-only
                    // identity that cannot sync anyway (the keys refuse first).
                    return UUID().uuidString.lowercased()
                }
                if let stored = E2EEKeychainStorage.load(scope: custody)?.deviceID { return stored }
                let minted = SyncCustodyRecord.fresh()
                _ = E2EEKeychainStorage.save(minted, scope: custody)
                return minted.deviceID
            })
    }

    /// 13e batch 9 (ladder round B, B-1) — THE OFF-MAIN CUSTODY HOP.
    /// Every closure above is a synchronous `SecItem*` call, and
    /// `EncryptionSession` — a `@MainActor` type — used to run them inline:
    /// a stalled securityd would beachball the open Encryption sheet
    /// instead of making it wait. This hop moves the call off the main
    /// thread and changes nothing else about it. The queue is SERIAL and
    /// shared by every hop deliberately: custody calls keep landing in the
    /// order they were made. NOT used by `DeviceKeySyncProvider`: the
    /// engine already reads custody off-main from its own rounds, and its
    /// `SyncKeyProviding` seam is synchronous by contract.
    func offMain<T: Sendable>(
        _ body: @escaping @Sendable (DeviceKeyStore) -> T
    ) async -> T {
        let store = self
        return await withCheckedContinuation { continuation in
            DeviceKeyStore.custodyQueue.async {
                continuation.resume(returning: body(store))
            }
        }
    }

    private static let custodyQueue = DispatchQueue(
        label: "io.lduarte.Variorum.custody", qos: .userInitiated)

    static func inMemory(initial: DeviceKeyMaterial? = nil) -> DeviceKeyStore {
        inMemory(backing: InMemoryKeyBacking(initial: initial))
    }

    /// The scriptable form: several stores may share one backing, and the
    /// backing exposes the relaunch lever, the shape and the unlock.
    static func inMemory(backing: InMemoryKeyBacking) -> DeviceKeyStore {
        DeviceKeyStore(
            load: { backing.load() },
            save: { backing.save($0) },
            clear: { backing.clear() },
            deviceID: { backing.deviceID })
    }
}

/// The tests' custody world: mirrors the Keychain factory's SHAPE semantics
/// — a persisted record, the session memory, the three shapes — so the
/// pins exercise silent / biometric / session-only custody and the relock
/// without any real Keychain or LocalAuthentication.
nonisolated final class InMemoryKeyBacking: @unchecked Sendable {
    private let lock = NSLock()
    private var material: DeviceKeyMaterial?
    private var shape: SyncCustodyShape
    private var session: DeviceKeyMaterial?
    let deviceID: String

    init(
        initial: DeviceKeyMaterial? = nil,
        shape: SyncCustodyShape = .silent,
        deviceID: String = UUID().uuidString.lowercased()
    ) {
        material = initial
        self.shape = shape
        self.deviceID = deviceID
        // A save under the gated / session-only shapes leaves the device
        // unlocked for the rest of the launch, as production does.
        session = shape == .silent ? nil : initial
    }

    /// The relock / a new process: the session memory is gone (a gated or
    /// session-only device reads no keys until its next unlock).
    func simulateRelaunch() {
        with { session = nil }
    }

    /// The lobby's one gated read (biometric) or the vault road (session
    /// only): the session fills from the held record.
    func simulateUnlock() {
        with { session = material }
    }

    /// The library key's mode moved (batch 2's transition): custody follows.
    func setShape(_ new: SyncCustodyShape) {
        with {
            shape = new
            if new == .silent { session = nil }
        }
    }

    var currentShape: SyncCustodyShape { with { shape } }
    /// The persisted record's material (whatever the shape) — what a
    /// backing HOLDS, as opposed to what `load` releases.
    var storedMaterial: DeviceKeyMaterial? { with { material } }

    fileprivate func load() -> DeviceKeyMaterial? {
        with { shape == .silent ? material : session }
    }

    fileprivate func save(_ new: DeviceKeyMaterial) -> Bool {
        with {
            material = new
            if shape != .silent { session = new }
            return true
        }
    }

    fileprivate func clear() {
        with {
            material = nil
            session = nil
        }
    }

    private func with<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }
}

// MARK: - The Keychain half

/// The Keychain leaves — the same Sec* pattern as the store-key family,
/// its own service so neither surface's clear touches the other. Every
/// item is DATA-PROTECTION resident (the marker on every query — the
/// `KeychainPartition` rule); the bound item `WhenUnlockedThisDeviceOnly`
/// (a background round after reboot-then-lock is a refused round — the
/// design's own "a locked device never syncs"); the gated item carries a
/// SecAccessControl — `.biometryCurrentSet` alone, never a passcode
/// fallback, never an `.or` escape (her ruling, kept). The legacy
/// fixed-account items are reachable ONLY through `SyncCustodyMigration`.
nonisolated enum E2EEKeychainStorage {
    static let service = "io.lduarte.Variorum.e2ee-keys"
    /// The 14b / CF-12 LEGACY fixed accounts — read by the migration only.
    static let legacyPlainAccount = "device-keys"
    static let legacyGatedAccount = "device-keys-biometric"

    // MARK: The bound (silent / identity) item

    static func load(scope: SyncCustodyScope) -> SyncCustodyRecord? {
        read(boundQuery(scope: scope))
    }

    @discardableResult
    static func save(_ record: SyncCustodyRecord, scope: SyncCustodyScope) -> Bool {
        guard !KeychainTestTripwire.refusesRealScopeMutation(scope.scope, leaf: "save") else { return false }
        guard let data = try? JSONEncoder().encode(record) else { return false }
        var attributes = boundQuery(scope: scope)
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let update: [String: Any] = [kSecValueData as String: data]
            return SecItemUpdate(boundQuery(scope: scope) as CFDictionary, update as CFDictionary)
                == errSecSuccess
        }
        return status == errSecSuccess
    }

    /// 17h (R3-5): a delete answers whether the item is RELEASED — gone, or
    /// never there. A tripwire refusal answers false.
    @discardableResult
    static func deletePlainItem(scope: SyncCustodyScope) -> Bool {
        guard !KeychainTestTripwire.refusesRealScopeMutation(scope.scope, leaf: "deletePlainItem") else { return false }
        let status = SecItemDelete(boundQuery(scope: scope) as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    // MARK: The gated item

    /// Whether the gated item exists — WITHOUT any prompt (attributes of
    /// an ACL'd item read without user auth; the non-interactive context is
    /// the belt).
    static func gatedItemExists(scope: SyncCustodyScope) -> Bool {
        var query = gatedQuery(scope: scope)
        query[kSecReturnAttributes as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        let probe = LAContext()
        probe.interactionNotAllowed = true
        query[kSecUseAuthenticationContext as String] = probe
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        return status == errSecSuccess || status == errSecInteractionNotAllowed
    }

    /// Persist the record behind the biometric gate. Delete-then-add
    /// (updating an ACL item would demand interactive auth, and WRITING
    /// must never prompt — the prompt belongs to the lobby's unlock alone);
    /// the forced order's window narrowed to probe width via
    /// `GatedSaveChoreography`.
    @discardableResult
    static func saveGated(_ record: SyncCustodyRecord, scope: SyncCustodyScope) -> Bool {
        guard !KeychainTestTripwire.refusesRealScopeMutation(scope.scope, leaf: "saveGated") else { return false }
        guard let data = try? JSONEncoder().encode(record) else { return false }
        var error: Unmanaged<CFError>?
        guard let control = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .biometryCurrentSet,
            &error)
        else { return false }
        return GatedSaveChoreography.run(
            sweepProbe: { SecItemDelete(probeQuery(scope: scope) as CFDictionary) },
            addProbe: {
                var attributes = probeQuery(scope: scope)
                attributes[kSecValueData as String] = Data("probe".utf8)
                attributes[kSecAttrAccessControl as String] = control
                return SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess
            },
            releaseExisting: { deleteGatedItem(scope: scope) },
            addIncoming: {
                var attributes = gatedQuery(scope: scope)
                attributes[kSecValueData as String] = data
                attributes[kSecAttrAccessControl as String] = control
                return SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess
            })
    }

    @discardableResult
    static func deleteGatedItem(scope: SyncCustodyScope) -> Bool {
        guard !KeychainTestTripwire.refusesRealScopeMutation(scope.scope, leaf: "deleteGatedItem") else { return false }
        let status = SecItemDelete(gatedQuery(scope: scope) as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }

    /// THE ONE GATED READ PER UNLOCK (§14.41): the store-key guard
    /// evaluates the biometric context ONCE for the library key and reads
    /// the sync record under the SAME context — one Touch ID prompt for L,
    /// M, C, J and the identity. Production only (the guard's unlock road).
    static func readGated(scope: SyncCustodyScope, context: LAContext) -> SyncCustodyRecord? {
        var query = gatedQuery(scope: scope)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecUseAuthenticationContext as String] = context
        return read(query)
    }

    // MARK: The legacy fixed-account items (the migration's only door)

    static func legacyLoadPlain() -> SyncCustodyRecord? {
        read(legacyQuery(account: legacyPlainAccount)).map { $0 }
            ?? legacyMaterial(legacyQuery(account: legacyPlainAccount)).map {
                SyncCustodyRecord(deviceID: "", material: $0)
            }
    }

    static func legacyGatedItemExists() -> Bool {
        var query = legacyQuery(account: legacyGatedAccount)
            .merging(KeychainPartition.dataProtection) { a, _ in a }
        query[kSecReturnAttributes as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        let probe = LAContext()
        probe.interactionNotAllowed = true
        query[kSecUseAuthenticationContext as String] = probe
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        return status == errSecSuccess || status == errSecInteractionNotAllowed
    }

    /// The legacy gated item's material under an evaluated context.
    static func legacyReadGated(context: LAContext) -> DeviceKeyMaterial? {
        var query = legacyQuery(account: legacyGatedAccount)
            .merging(KeychainPartition.dataProtection) { a, _ in a }
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecUseAuthenticationContext as String] = context
        return legacyMaterial(query)
    }

    /// Both legacy items released (the migration's last step).
    @discardableResult
    static func legacyDelete() -> Bool {
        guard !KeychainTestTripwire.refusesRealScopeMutation("legacy", leaf: "legacyDelete") else { return false }
        let plain = SecItemDelete(legacyQuery(account: legacyPlainAccount) as CFDictionary)
        let gated = SecItemDelete(
            legacyQuery(account: legacyGatedAccount)
                .merging(KeychainPartition.dataProtection) { a, _ in a } as CFDictionary)
        return (plain == errSecSuccess || plain == errSecItemNotFound)
            && (gated == errSecSuccess || gated == errSecItemNotFound)
    }

    // MARK: Queries

    private static func read(_ base: [String: Any]) -> SyncCustodyRecord? {
        var query = base
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return try? JSONDecoder().decode(SyncCustodyRecord.self, from: data)
    }

    /// The 14b blob was the bare `DeviceKeyMaterial`.
    private static func legacyMaterial(_ base: [String: Any]) -> DeviceKeyMaterial? {
        var query = base
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return try? JSONDecoder().decode(DeviceKeyMaterial.self, from: data)
    }

    /// Internal, not private, so `KeychainPartitionTests` can assert the
    /// partition marker rides every family.
    static func boundQuery(scope: SyncCustodyScope) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: scope.boundAccount,
        ].merging(KeychainPartition.dataProtection) { a, _ in a }
    }

    static func gatedQuery(scope: SyncCustodyScope) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: scope.gatedAccount,
        ].merging(KeychainPartition.dataProtection) { a, _ in a }
    }

    private static func probeQuery(scope: SyncCustodyScope) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: scope.probeAccount,
        ].merging(KeychainPartition.dataProtection) { a, _ in a }
    }

    /// The 14b plain item was FILE-BASED (no DP marker); the gated one
    /// DP-resident — callers merge the marker for the gated account.
    private static func legacyQuery(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }
}

// MARK: - The migration hook (§11 — behind a seam; batch 2 runs it)

/// Her two devices' one-shot re-scoping (the postures design §11): the
/// 14b/CF-12 fixed-account items become the per-store record in the
/// library key's shape, the device identity read from the store's old
/// `sync_state.device_id` (the caller reads and then deletes the row),
/// the CF-12 opt-in default retired. Written at batch 1a, UNRUN — batch 2
/// wires it at the first unlock after the install. Testable over the
/// leaves seam with recording fakes; never touches the Keychain here.
nonisolated enum SyncCustodyMigration {
    static let legacyOptInDefaultsKey = "variorum.e2ee.syncGateOptIn"

    struct Legacy: Sendable {
        /// The material in hand (the plain item's, or the gated item's read
        /// under the unlock's context) — nil = nothing to migrate.
        var material: DeviceKeyMaterial?
        /// The store's old `sync_state.device_id`, when the row exists.
        var deviceID: String?
        var deleteLegacyItems: @Sendable () -> Bool
        var retireOptIn: @Sendable () -> Void
    }

    /// Returns `.done` when the per-store record landed (verified) and the
    /// legacy items were released; a refusal leaves the legacy items in
    /// place — the next unlock retries.
    static func migrateSyncCustodyToStoreScope(
        legacy: Legacy, shape: SyncCustodyShape,
        leaves: E2EECustodyLeaves, session: SyncCustodySession
    ) -> CustodyHandover.Outcome {
        guard let material = legacy.material else { return .writeRefused }
        let record = SyncCustodyRecord(
            deviceID: legacy.deviceID ?? UUID().uuidString.lowercased(),
            material: material)
        let identityOnly = SyncCustodyRecord(deviceID: record.deviceID, material: nil)
        let outcome: CustodyHandover.Outcome
        switch shape {
        case .silent:
            outcome = CustodyHandover.perform(
                write: { leaves.savePlain(record) },
                verify: { leaves.loadPlain() == record },
                deleteOutgoing: { legacy.deleteLegacyItems() },
                rollBackIncoming: { _ = leaves.deletePlain() })
        case .biometric:
            outcome = CustodyHandover.perform(
                write: { leaves.saveGated(record) && leaves.savePlain(identityOnly) },
                verify: { leaves.gatedExists() && leaves.loadPlain() == identityOnly },
                deleteOutgoing: { legacy.deleteLegacyItems() },
                rollBackIncoming: { _ = leaves.deleteGated(); _ = leaves.deletePlain() })
            if outcome == .done { session.hold(record) }
        case .sessionOnly:
            outcome = CustodyHandover.perform(
                write: { leaves.savePlain(identityOnly) },
                verify: { leaves.loadPlain() == identityOnly },
                deleteOutgoing: { legacy.deleteLegacyItems() },
                rollBackIncoming: { _ = leaves.deletePlain() })
            if outcome == .done { session.hold(record) }
        }
        if outcome == .done { legacy.retireOptIn() }
        return outcome
    }
}

// MARK: - The sync key provider

/// The REAL sync key provider: reads the device's custody per round —
/// post-enrollment rounds find keys with no re-composition, and an
/// unenrolled / locked / copied device refuses in the engine's own visible
/// grammar (`SyncError.encryptionKeysUnavailable`). The identity rides the
/// same custody (§1.13).
nonisolated struct DeviceKeySyncProvider: SyncKeyProviding {
    var store: DeviceKeyStore

    init(store: DeviceKeyStore) {
        self.store = store
    }

    func currentKeys() throws -> SyncEncryptionKeys {
        guard let material = store.load() else {
            throw SyncKeyProviderError.notEnrolled
        }
        return SyncEncryptionKeys(
            corpusKey: material.corpusSymmetricKey,
            corpusKeyID: material.corpusKeyID)
    }

    func deviceIdentity() throws -> String {
        store.deviceID()
    }
}
