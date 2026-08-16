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
//  Phase 14b COPY/FLOW ROUND (CF-12's ruling) — the R-6 door OPENS: the
//  "require biometrics to unlock sync" DEVICE-LOCAL policy. Her ruling,
//  exact: biometric OR the encryption passphrase, NEVER the device
//  passcode ("more of a 'no one can read my diary' step"). Mechanism:
//  with the policy ON, custody moves to a second Keychain item behind a
//  SecAccessControl gated `.biometryCurrentSet` ALONE — no `.devicePasscode`
//  fallback flag, so a passcode never opens it, and re-enrolling biometry
//  (a new fingerprint/face) invalidates the item BY DESIGN under this
//  threat model; the passphrase road recovers. Unlock is ONCE PER LAUNCH:
//  a successful biometric read fills a process-lifetime cache; until then
//  `load()` returns nil and the sync engine refuses its rounds visibly
//  (the known stated cost — sync waits for the first unlock). Biometric
//  failure or unavailability is never a dead end: typing the passphrase
//  re-derives and re-unwraps from the vault, and that save keeps the gate
//  on. The policy is device-local forever — never in the vault format, the
//  ciphertext, or the protocol (R-6's answered door, now walked through).
//
//  `DeviceKeyStore` is the injectable seam (the AuthTokensStore pattern):
//  tests script custody AND biometric outcomes through `InMemoryKeyBacking`
//  — no test ever touches the real Keychain or LocalAuthentication; the
//  LAContext lives only inside the `.keychain()` closures.
//

import Foundation
import LocalAuthentication
import Security
import VariorumCore

/// Persistence seam for the device's unwrapped key material (tests inject
/// in-memory; production is the Keychain) — the `AuthTokensStore` pattern.
nonisolated struct DeviceKeyStore: Sendable {
    /// Non-prompting read: the plain item — or, under the biometric gate,
    /// this launch's unlocked cache (nil until `unlockWithBiometrics` or a
    /// passphrase re-unwrap fills it). The sync key provider reads THIS,
    /// which is exactly how "sync waits" happens.
    var load: @Sendable () -> DeviceKeyMaterial?
    /// Persist under the CURRENT gate policy. A gated save also fills the
    /// launch cache — a save always comes from freshly-unwrapped material,
    /// so the device that just proved the passphrase is unlocked.
    var save: @Sendable (DeviceKeyMaterial) -> Bool
    /// The forget door's act (CF-11): custody, the launch cache, and the
    /// biometric gate all go. The account vault is untouched.
    var clear: @Sendable () -> Void
    /// CF-12: whether current-set biometry can be evaluated here (drives
    /// the toggle's enabled state).
    var biometryAvailable: @Sendable () -> Bool
    /// CF-12: whether custody sits behind the biometric gate.
    var isBiometricGateOn: @Sendable () -> Bool
    /// CF-12: re-persist the material under the given policy (ON ⇒ the
    /// `.biometryCurrentSet` item; OFF ⇒ the plain item).
    var setBiometricGate: @Sendable (Bool, DeviceKeyMaterial) -> Bool
    /// CF-12: evaluate biometrics (NEVER the device passcode — her ruling)
    /// and unlock this launch. nil = failed / cancelled / unavailable /
    /// invalidated-by-re-enrollment — the passphrase road is the fallback,
    /// spoken by the caller's surface.
    var unlockWithBiometrics: @Sendable () async -> DeviceKeyMaterial?

    static func keychain() -> DeviceKeyStore {
        DeviceKeyStore(
            load: {
                if let cached = E2EELaunchKeyCache.shared.value { return cached }
                // A gated item is unreadable without a prompt: locked until
                // an unlock fills the cache — never prompt from here (this
                // path runs at sync-round cadence).
                if E2EEKeychainStorage.gatedItemExists() { return nil }
                return E2EEKeychainStorage.load()
            },
            save: { material in
                if E2EEKeychainStorage.gatedItemExists() {
                    guard E2EEKeychainStorage.saveGated(material) else { return false }
                    E2EELaunchKeyCache.shared.value = material
                    return true
                }
                return E2EEKeychainStorage.save(material)
            },
            clear: {
                E2EEKeychainStorage.clear()
                E2EELaunchKeyCache.shared.value = nil
            },
            biometryAvailable: {
                // Biometrics ONLY — `.deviceOwnerAuthentication` (which
                // falls back to the device passcode) is deliberately never
                // consulted anywhere in this file (her ruling).
                LAContext().canEvaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics, error: nil)
            },
            isBiometricGateOn: { E2EEKeychainStorage.gatedItemExists() },
            setBiometricGate: { on, material in
                if on {
                    guard E2EEKeychainStorage.saveGated(material) else { return false }
                    E2EEKeychainStorage.deletePlainItem()
                    E2EELaunchKeyCache.shared.value = material
                    return true
                }
                guard E2EEKeychainStorage.save(material) else { return false }
                E2EEKeychainStorage.deleteGatedItem()
                E2EELaunchKeyCache.shared.value = nil
                return true
            },
            unlockWithBiometrics: {
                guard let material = await E2EEKeychainStorage.unlockGatedItem() else {
                    return nil
                }
                E2EELaunchKeyCache.shared.value = material
                return material
            })
    }

    static func inMemory(initial: DeviceKeyMaterial? = nil) -> DeviceKeyStore {
        inMemory(backing: InMemoryKeyBacking(initial: initial))
    }

    /// The scriptable form: several stores may share one backing, and the
    /// backing exposes the relaunch lever + the biometric script.
    static func inMemory(backing: InMemoryKeyBacking) -> DeviceKeyStore {
        DeviceKeyStore(
            load: { backing.load() },
            save: { backing.save($0) },
            clear: { backing.clear() },
            biometryAvailable: { backing.biometryIsAvailable() },
            isBiometricGateOn: { backing.isGated() },
            setBiometricGate: { backing.setGate($0, $1) },
            unlockWithBiometrics: { backing.unlock() })
    }
}

/// The tests' custody world (CF-12): mirrors the Keychain factory's gate
/// semantics — persisted item, gate flag, once-per-launch cache — with the
/// biometric outcome SCRIPTED, so the pins exercise the gated/ungated arms
/// and the fallback without any real Keychain or LocalAuthentication.
nonisolated final class InMemoryKeyBacking: @unchecked Sendable {
    private let lock = NSLock()
    private var material: DeviceKeyMaterial?
    private var gated = false
    private var launchCache: DeviceKeyMaterial?
    private var available: Bool
    private var unlockSucceeds: Bool

    init(
        initial: DeviceKeyMaterial? = nil,
        biometryAvailable: Bool = false,
        biometricUnlockSucceeds: Bool = false
    ) {
        material = initial
        available = biometryAvailable
        unlockSucceeds = biometricUnlockSucceeds
    }

    /// The once-per-launch boundary, simulated: a new process holds no
    /// unlocked cache.
    func simulateRelaunch() {
        with { launchCache = nil }
    }

    func setBiometricUnlockSucceeds(_ succeeds: Bool) {
        with { unlockSucceeds = succeeds }
    }

    fileprivate func load() -> DeviceKeyMaterial? {
        with { gated ? launchCache : material }
    }

    fileprivate func save(_ new: DeviceKeyMaterial) -> Bool {
        with {
            material = new
            if gated { launchCache = new }
            return true
        }
    }

    fileprivate func clear() {
        with {
            material = nil
            gated = false
            launchCache = nil
        }
    }

    fileprivate func isGated() -> Bool { with { gated } }

    fileprivate func setGate(_ on: Bool, _ current: DeviceKeyMaterial) -> Bool {
        with {
            material = current
            gated = on
            launchCache = on ? current : nil
            return true
        }
    }

    fileprivate func unlock() -> DeviceKeyMaterial? {
        with {
            guard gated, unlockSucceeds, let material else { return nil }
            launchCache = material
            return material
        }
    }

    fileprivate func biometryIsAvailable() -> Bool { with { available } }

    private func with<T>(_ body: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return body()
    }
}

/// The once-per-launch unlocked material (CF-12): process-lifetime, shared
/// by every `.keychain()` store in the process (the session's and the sync
/// provider's are the same custody by construction). Dies with the process
/// — which is exactly what "unlock once per launch" means.
nonisolated private final class E2EELaunchKeyCache: @unchecked Sendable {
    static let shared = E2EELaunchKeyCache()
    private let lock = NSLock()
    private var stored: DeviceKeyMaterial?
    var value: DeviceKeyMaterial? {
        get { lock.lock(); defer { lock.unlock() }; return stored }
        set { lock.lock(); defer { lock.unlock() }; stored = newValue }
    }
}

/// The Keychain half — the same Sec* pattern as the 9c auth storage, its
/// own service so neither surface's clear touches the other.
/// `AfterFirstUnlock` on the PLAIN item for the same background-round
/// reason (a background sync round after reboot-then-unlock must find its
/// keys). The GATED item (CF-12) instead carries a SecAccessControl —
/// `.biometryCurrentSet` alone — under `WhenUnlockedThisDeviceOnly`:
/// background-before-unlock refusal is that mode's designed cost.
nonisolated enum E2EEKeychainStorage {
    static let service = "io.lduarte.Variorum.e2ee-keys"
    private static let account = "device-keys"
    /// CF-12: the biometric-gated custody item's account. Which account
    /// holds the item IS the policy of record — no side flag to drift.
    private static let gatedAccount = "device-keys-biometric"

    static func load() -> DeviceKeyMaterial? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return try? JSONDecoder().decode(DeviceKeyMaterial.self, from: data)
    }

    @discardableResult
    static func save(_ material: DeviceKeyMaterial) -> Bool {
        guard let data = try? JSONEncoder().encode(material) else { return false }
        var attributes = baseQuery()
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status == errSecDuplicateItem {
            let update: [String: Any] = [kSecValueData as String: data]
            return SecItemUpdate(baseQuery() as CFDictionary, update as CFDictionary)
                == errSecSuccess
        }
        return status == errSecSuccess
    }

    /// Clears BOTH custody items (plain + gated) — the forget door and
    /// gate flips route through here and the per-item deletes.
    @discardableResult
    static func clear() -> Bool {
        let plainGone = SecItemDelete(baseQuery() as CFDictionary) == errSecSuccess
        let gatedGone = SecItemDelete(gatedBaseQuery() as CFDictionary) == errSecSuccess
        return plainGone || gatedGone
    }

    static func deletePlainItem() {
        SecItemDelete(baseQuery() as CFDictionary)
    }

    static func deleteGatedItem() {
        SecItemDelete(gatedBaseQuery() as CFDictionary)
    }

    /// CF-12: whether the gated custody item exists — WITHOUT any prompt.
    /// Attributes of an ACL-gated generic-password item read without user
    /// auth (only the data is protected); the non-interactive context is
    /// the belt so no OS version ever prompts from this probe.
    static func gatedItemExists() -> Bool {
        var query = gatedBaseQuery()
        query[kSecReturnAttributes as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        let probe = LAContext()
        probe.interactionNotAllowed = true
        query[kSecUseAuthenticationContext as String] = probe
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        return status == errSecSuccess || status == errSecInteractionNotAllowed
    }

    /// CF-12: persist custody behind the biometric gate. Delete-then-add:
    /// updating an ACL item would demand interactive auth, and WRITING must
    /// never prompt (the prompt belongs to the unlock alone).
    @discardableResult
    static func saveGated(_ material: DeviceKeyMaterial) -> Bool {
        guard let data = try? JSONEncoder().encode(material) else { return false }
        var error: Unmanaged<CFError>?
        // Her ruling, in flags: `.biometryCurrentSet` ALONE — never
        // `.devicePasscode`, never an `.or` escape. Re-enrolling biometry
        // invalidates this item (a newly added fingerprint or face grants
        // nothing); the passphrase road recovers, by design.
        guard let control = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            .biometryCurrentSet,
            &error)
        else { return false }
        deleteGatedItem()
        var attributes = gatedBaseQuery()
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessControl as String] = control
        return SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess
    }

    /// CF-12: the once-per-launch unlock — evaluate biometrics (ONLY), then
    /// read the gated item under the evaluated context so the system never
    /// double-prompts. nil on failure/cancel/unavailable/invalidated.
    static func unlockGatedItem() async -> DeviceKeyMaterial? {
        let context = LAContext()
        // The system prompt's fallback button is suppressed: falling back
        // is OUR passphrase road, never a system credential.
        context.localizedFallbackTitle = ""
        guard (try? await context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Unlock Variorum's encryption keys"))
            == true
        else { return nil }
        var query = gatedBaseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecUseAuthenticationContext as String] = context
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return try? JSONDecoder().decode(DeviceKeyMaterial.self, from: data)
    }

    private static func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }

    private static func gatedBaseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: gatedAccount,
        ]
    }
}

/// The REAL sync key provider (batch 2's PROVISIONAL 2, resolved here):
/// reads the device's custody per round — post-enrollment rounds find keys
/// with no re-composition, and an unenrolled/cleared device refuses in the
/// engine's own visible grammar (`SyncError.encryptionKeysUnavailable`).
/// Under the biometric gate (CF-12), a locked launch reads as no keys
/// through the same seam — sync waits, visibly, until the first unlock.
nonisolated struct DeviceKeySyncProvider: SyncKeyProviding {
    var store: DeviceKeyStore = .keychain()

    func currentKeys() throws -> SyncEncryptionKeys {
        guard let material = store.load() else {
            throw SyncKeyProviderError.notEnrolled
        }
        return SyncEncryptionKeys(
            corpusKey: material.corpusSymmetricKey,
            corpusKeyID: material.corpusKeyID)
    }
}

/// Phase 14c batch 2 — built as THE 14D PREP (her Round-6 ruling): the
/// LIVE journal-bridge key provider, the real Keychain-custody road
/// through the 14b seam — `DeviceKeySyncProvider`'s exact twin for the
/// bridge's class (R-8: the bridge only ever touches the journal-bridge
/// key; custody already holds it from enrollment, id included, so 14d
/// added no new key machinery). **WIRED LIVE AT 14D (2026-08-16):** the
/// Mac's production composition passes this provider at AppServices'
/// `makeBridgeKeyProvider` seam — the 14b structural pause is over, and
/// the liveness pin (`Phase9cAuthWiringTests`) guards the wiring. The
/// readiness half stays pinned in core (`BridgeRestageTests`) and the
/// provider's own custody arms below. Under the biometric gate (CF-12) a
/// locked launch reads as no keys — the bridge waits exactly as sync
/// does.
nonisolated struct DeviceBridgeKeyProvider: BridgeKeyProviding {
    var store: DeviceKeyStore = .keychain()

    func currentKeys() throws -> BridgeEncryptionKeys {
        guard let material = store.load() else {
            throw BridgeEncryptionError.keysUnavailable
        }
        return BridgeEncryptionKeys(
            journalKey: material.journalBridgeSymmetricKey,
            journalKeyID: material.journalBridgeKeyID)
    }
}
