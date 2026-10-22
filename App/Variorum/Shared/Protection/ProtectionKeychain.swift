//
//  ProtectionKeychain.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1a — THE PROTECTION CORE'S KEYCHAIN FAMILY: ONE query builder for the four keychain leaves
//  (custody, sync keys, memory — device-only; Apple keys — synchronizable), so the family can never
//  disagree with itself (the `KeychainPartition` rule and the Apple key family's Q5 rule, applied):
//    - every query is DATA-PROTECTION resident (`KeychainPartition.dataProtection`);
//    - the device-only items are generic passwords under their `ProtectionNames` service and account,
//      `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` (today's silent item's shape), never synchronizable;
//    - the Apple items carry `kSecAttrSynchronizable` and the SHARED access group on every verb
//      (`sharedGroup` — the phone shares it), `kSecAttrAccessibleAfterFirstUnlock` (a
//      synchronizable item cannot be ThisDeviceOnly);
//    - VX-390's STAMP rides `kSecAttrLabel` — the library ID, non-secret (the key file says it in the
//      clear) — a plain, queryable attribute beside the item;
//    - a LISTING reads ATTRIBUTES ONLY (`kSecReturnAttributes`, never `kSecReturnData`) and, device-only,
//      with `kSecUseAuthenticationUISkip` — an item that would need authentication (a `.biometryCurrentSet`
//      item: the Security sources gate even an attributes-only match on its ACL, and under a non-interactive
//      context ONE such match fails the WHOLE listing with `errSecInteractionNotAllowed` — the U1a lookup,
//      recorded in the U1a record) is SILENTLY SKIPPED, so no listing ever presses a Touch ID item or fails
//      for one. Touch ID items are found by name instead (`exists` — today's measured non-prompting probe:
//      `errSecInteractionNotAllowed` means present), over the fingerprints the device knows of
//      (`KeychainCustodyLeaf.touchIDCandidates`, P-VX306-U1a-5);
//    - EVERY MUTATION asks `KeychainTestTripwire.refusesRealScopeMutation(scope, leaf:)` FIRST — a test
//      process never writes or deletes under a real scope (`Variorum`, `Variorum-dev`); a refused
//      mutation THROWS (`refusedUnderTest`), since a leaf's write lands or throws.
//

import Foundation
import LocalAuthentication
import Security
import VariorumCore

nonisolated enum ProtectionKeychain {
    enum KeychainError: Error, Equatable, CustomStringConvertible {
        /// The Keychain answered `status` to `operation`.
        case status(OSStatus, String)
        /// A test process reached a real scope's mutation — refused before any SecItem call.
        case refusedUnderTest(String)
        /// A write landed but did not read back as written.
        case writeDidNotReadBack(String)

        var description: String {
            switch self {
            case .status(let status, let operation):
                let words = (SecCopyErrorMessageString(status, nil) as String?) ?? "?"
                return "ProtectionKeychain: \(operation) → \(status) (\(words))"
            case .refusedUnderTest(let leaf): return "ProtectionKeychain: \(leaf) refused under a real scope in a test process"
            case .writeDidNotReadBack(let leaf): return "ProtectionKeychain: \(leaf) did not read back"
            }
        }
    }

    /// The two kinds of family.
    enum Residence {
        /// This device only, the app's default access group.
        case deviceOnly
        /// iCloud Keychain — synchronizable, the shared access group.
        case synchronizable
    }

    // MARK: - The shared access group (moved here from today's `AppleKeyKeychain` at VX-329 U1, byte-for-byte)

    /// The team identifier prefix (the provisioning profile's; every signed entitlement dump carries it).
    static let teamPrefix = "384925MZJ6."
    static let sharedGroupSuffix = "io.lduarte.Variorum.shared"
    /// THE SHARED ACCESS GROUP — the second entry of both targets' `keychain-access-groups`; `EntitlementsTests` pins
    /// the order. The Apple keys' synchronizable items ride it on every verb (the phone shares it).
    static var sharedGroup: String { teamPrefix + sharedGroupSuffix }

    // MARK: - The one builder

    static func base(service: String, account: String? = nil, residence: Residence) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
        ]
        if let account { query[kSecAttrAccount as String] = account }
        if residence == .synchronizable {
            query[kSecAttrSynchronizable as String] = true
            query[kSecAttrAccessGroup as String] = sharedGroup
        }
        return query.merging(KeychainPartition.dataProtection) { a, _ in a }
    }

    /// Every item of `service` — ATTRIBUTES ONLY; device-only, an item that would need authentication is
    /// silently skipped (no prompt, ever; a synchronizable item can carry no ACL — the Apple facts §10).
    static func listingQuery(service: String, residence: Residence, label: String? = nil) -> [String: Any] {
        var query = base(service: service, residence: residence)
        switch residence {
        case .deviceOnly: query[kSecUseAuthenticationUI as String] = kSecUseAuthenticationUISkip
        case .synchronizable: query[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny
        }
        if let label { query[kSecAttrLabel as String] = label }
        query[kSecReturnAttributes as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        return query
    }

    /// The listing's attribute dictionaries (an empty family lists nothing).
    static func list(service: String, residence: Residence, label: String? = nil) throws -> [[String: Any]] {
        var result: AnyObject?
        let status = SecItemCopyMatching(
            listingQuery(service: service, residence: residence, label: label) as CFDictionary, &result)
        switch status {
        case errSecSuccess: return (result as? [[String: Any]]) ?? []
        case errSecItemNotFound: return []
        default: throw KeychainError.status(status, "list \(service)")
        }
    }

    /// The account and the stamp of a listed item.
    static func account(of attributes: [String: Any]) -> String? { attributes[kSecAttrAccount as String] as? String }
    static func label(of attributes: [String: Any]) -> String? { attributes[kSecAttrLabel as String] as? String }

    /// One item's DATA. nil: no such item. `context`: an `LAContext` for a Touch ID item's read — the press
    /// (the system shows the prompt); nil for a silent item. Throws on any other status — a read that could
    /// not happen is never reported as absence.
    static func readData(service: String, account: String, residence: Residence, context: LAContext? = nil) throws -> Data? {
        var query = base(service: service, account: account, residence: residence)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        if let context { query[kSecUseAuthenticationContext as String] = context }
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        switch status {
        case errSecSuccess: return result as? Data
        case errSecItemNotFound: return nil
        default: throw KeychainError.status(status, "read \(service)")
        }
    }

    /// Whether an item exists — attributes only, never a prompt (an ACL'd item's presence included).
    static func exists(service: String, account: String, residence: Residence) throws -> Bool {
        var query = base(service: service, account: account, residence: residence)
        query[kSecReturnAttributes as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        let context = LAContext()
        context.interactionNotAllowed = true
        query[kSecUseAuthenticationContext as String] = context
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        switch status {
        case errSecSuccess, errSecInteractionNotAllowed: return true
        case errSecItemNotFound: return false
        default: throw KeychainError.status(status, "probe \(service)")
        }
    }

    // MARK: - Mutations (each asks the tripwire first)

    static func refuseUnderTest(_ scope: String, _ leaf: String) throws {
        if KeychainTestTripwire.refusesRealScopeMutation(scope, leaf: leaf) { throw KeychainError.refusedUnderTest(leaf) }
    }

    /// A plain (no ACL) item written, or its data and stamp replaced.
    static func upsert(
        service: String, account: String, residence: Residence, data: Data, label: String?, accessible: CFString
    ) throws {
        var attributes = base(service: service, account: account, residence: residence)
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = accessible
        if let label { attributes[kSecAttrLabel as String] = label }
        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status == errSecDuplicateItem {
            var update: [String: Any] = [kSecValueData as String: data]
            if let label { update[kSecAttrLabel as String] = label }
            let updated = SecItemUpdate(
                base(service: service, account: account, residence: residence) as CFDictionary, update as CFDictionary)
            guard updated == errSecSuccess else { throw KeychainError.status(updated, "update \(service)") }
            return
        }
        guard status == errSecSuccess else { throw KeychainError.status(status, "add \(service)") }
    }

    /// An item carrying a `SecAccessControl` added (never updated — an ACL'd item's update would demand
    /// interactive auth, and a write never prompts). A duplicate answers `errSecDuplicateItem` to the caller.
    static func addGated(
        service: String, account: String, data: Data, label: String?, control: SecAccessControl
    ) -> OSStatus {
        var attributes = base(service: service, account: account, residence: .deviceOnly)
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessControl as String] = control
        if let label { attributes[kSecAttrLabel as String] = label }
        return SecItemAdd(attributes as CFDictionary, nil)
    }

    /// Released = deleted, or never there (17h R3-5's rule). A synchronizable delete matches either flag.
    static func delete(service: String, account: String, residence: Residence) throws {
        var query = base(service: service, account: account, residence: residence)
        if residence == .synchronizable { query[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny }
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.status(status, "delete \(service)")
        }
    }

    /// `.biometryCurrentSet` ALONE — never a passcode fallback, never an `.or` escape (her ruling, kept —
    /// the Apple facts §4/§10: a device-only class, never synchronizable).
    static func touchIDControl() -> SecAccessControl? {
        var error: Unmanaged<CFError>?
        return SecAccessControlCreateWithFlags(
            kCFAllocatorDefault, kSecAttrAccessibleWhenUnlockedThisDeviceOnly, .biometryCurrentSet, &error)
    }
}
