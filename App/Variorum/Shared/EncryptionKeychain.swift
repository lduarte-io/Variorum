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
//  THE FUTURE-BIOMETRICS DOOR (R-6, her question ANSWERED at the sitting —
//  the answer binds the design): unlock cadence is DEVICE-LOCAL POLICY,
//  never part of the vault format, the ciphertext, or the protocol. A
//  future "require Face ID / Touch ID at launch" setting is added by
//  attaching a SecAccessControl (e.g. `.biometryCurrentSet`) to THIS ONE
//  Keychain item — an access-control policy on the item, zero format
//  impact, zero migration — with the one inherent cost stated in-sitting:
//  sync then waits for the first unlock each launch. Nothing in this file
//  precludes that; this comment is the door's marker.
//

import Foundation
import Security
import VariorumCore

/// Persistence seam for the device's unwrapped key material (tests inject
/// in-memory; production is the Keychain) — the `AuthTokensStore` pattern.
nonisolated struct DeviceKeyStore: Sendable {
    var load: @Sendable () -> DeviceKeyMaterial?
    var save: @Sendable (DeviceKeyMaterial) -> Bool
    var clear: @Sendable () -> Void

    static func keychain() -> DeviceKeyStore {
        DeviceKeyStore(
            load: { E2EEKeychainStorage.load() },
            save: { E2EEKeychainStorage.save($0) },
            clear: { E2EEKeychainStorage.clear() })
    }

    static func inMemory(initial: DeviceKeyMaterial? = nil) -> DeviceKeyStore {
        let box = LockedBox(initial)
        return DeviceKeyStore(
            load: { box.value },
            save: { box.value = $0; return true },
            clear: { box.value = nil })
    }

    nonisolated private final class LockedBox: @unchecked Sendable {
        private let lock = NSLock()
        private var stored: DeviceKeyMaterial?
        init(_ initial: DeviceKeyMaterial?) { stored = initial }
        var value: DeviceKeyMaterial? {
            get { lock.lock(); defer { lock.unlock() }; return stored }
            set { lock.lock(); defer { lock.unlock() }; stored = newValue }
        }
    }
}

/// The Keychain half — the same Sec* pattern as the 9c auth storage, its
/// own service so neither surface's clear touches the other.
/// `AfterFirstUnlock` for the same background-round reason (a background
/// sync round after reboot-then-unlock must find its keys).
nonisolated enum E2EEKeychainStorage {
    static let service = "io.lduarte.Variorum.e2ee-keys"
    private static let account = "device-keys"

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

    @discardableResult
    static func clear() -> Bool {
        SecItemDelete(baseQuery() as CFDictionary) == errSecSuccess
    }

    private static func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }
}

/// The REAL sync key provider (batch 2's PROVISIONAL 2, resolved here):
/// reads the device's custody per round — post-enrollment rounds find keys
/// with no re-composition, and an unenrolled/cleared device refuses in the
/// engine's own visible grammar (`SyncError.encryptionKeysUnavailable`).
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
