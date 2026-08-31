//
//  StoreKeyBindingTests.swift
//  VariorumTests
//
//  Pre-13u Act 9 (#82, R-pre13u-3) — the store key's device binding. Her
//  ruling: *"binding the store key only — it closes the last gap where
//  only a computer password is enough to get your text."* The plain
//  store-key item's `…ThisDeviceOnly` class was inert on macOS (13p-fix
//  R1-2: no `kSecUseDataProtectionKeychain`), so the key to the encrypted
//  library rode Migration Assistant and Time Machine to other hardware.
//  `StoreKeyKeychain` now merges the DP flag on every query and `load`
//  runs the TN3137 read→re-add-with-flag→delete-old migration for the
//  pre-#82 file-based item, under the CustodyHandover write-VERIFY-delete
//  discipline.
//
//  These pins run in the SIGNED host (the fact-suite precedent): DP
//  writes need the keychain identity, which `swift test`'s unsigned CLI
//  lacks. Every item is a THROWAWAY scope under the real store-key
//  service, ThisDeviceOnly, never synchronizable — the 13p suite rules.
//
//  RED ON OLD: on the pre-#82 code, `load` returns the planted legacy key
//  but mints no DP item and sweeps nothing — the DP probe and the
//  legacy-gone probes below go red.
//

import Foundation
import Security
import Testing

@testable import Variorum
import VariorumCore

@Suite("pre-13u — the store key's device binding (#82)")
struct StoreKeyBindingTests {
    /// Mirrors the production family's query contract — the BOUND item
    /// lives under its own account (`<scope>-bound`, hardcoded here as a
    /// pin of that contract) in the DP keychain; the legacy item under
    /// the bare scope, file-based. (The distinct account is load-bearing:
    /// this round MEASURED that a plain DP item under a SHARED account is
    /// matched by a no-flag SecItemDelete, so the legacy sweep would have
    /// destroyed the bound item it had just verified.)
    private func query(scope: String, dataProtection: Bool) -> [String: Any] {
        var q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: StoreKeyCustody.deviceKeychainService,
            kSecAttrAccount as String: dataProtection ? "\(scope)-bound" : scope,
        ]
        if dataProtection { q[kSecUseDataProtectionKeychain as String] = true }
        return q
    }

    /// Plants the PRE-#82 world's item: file-based, no DP flag — exactly
    /// what every launch before this round wrote.
    private func plantLegacyItem(_ key: StoreKey, scope: String) -> Bool {
        var attributes = query(scope: scope, dataProtection: false)
        attributes[kSecValueData as String] = key.data
        attributes[kSecAttrAccessible as String] =
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        return SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess
    }

    private func itemExists(scope: String, dataProtection: Bool) -> Bool {
        var probe = query(scope: scope, dataProtection: dataProtection)
        probe[kSecReturnAttributes as String] = true
        probe[kSecMatchLimit as String] = kSecMatchLimitOne
        return SecItemCopyMatching(probe as CFDictionary, nil) == errSecSuccess
    }

    private func cleanUp(scope: String) {
        SecItemDelete(query(scope: scope, dataProtection: true) as CFDictionary)
        SecItemDelete(query(scope: scope, dataProtection: false) as CFDictionary)
    }

    /// THE MIGRATION ROUND TRIP, red-on-old: a planted legacy item is
    /// read, re-added into the data-protection keychain (verified through
    /// the production read path), and the file-based original — the copy
    /// that rides Migration Assistant — is DELETED. Idempotent: a second
    /// load reads the bound item straight.
    @Test func aLegacyItemMigratesIntoTheDataProtectionKeychainOnLoad() {
        let scope = "82-migrate-\(UUID().uuidString)"
        defer { cleanUp(scope: scope) }
        let key = StoreKey.mint()
        #expect(plantLegacyItem(key, scope: scope), "the pre-#82 world is planted")

        let custody = StoreKeyCustody.deviceKeychain(scope: scope)
        #expect(custody.load() == key, "the key is in hand — opening never hinges on the move")
        #expect(itemExists(scope: scope, dataProtection: true),
                "the item now lives in the DP keychain — ThisDeviceOnly is IN FORCE")
        #expect(!itemExists(scope: scope, dataProtection: false),
                "the file-based copy — the one Migration Assistant carries — is GONE")
        #expect(custody.load() == key, "idempotent: the bound item reads straight")
    }

    /// The crash-window heal: DP item landed, legacy delete never ran
    /// (both present). The next DP hit sweeps the lingering legacy copy —
    /// without the sweep, the Migration-Assistant gap would quietly stay
    /// open behind a "migrated" reading.
    @Test func aLingeringLegacyCopyIsSweptAtTheNextRead() {
        let scope = "82-heal-\(UUID().uuidString)"
        defer { cleanUp(scope: scope) }
        let key = StoreKey.mint()
        let custody = StoreKeyCustody.deviceKeychain(scope: scope)
        #expect(custody.save(key), "the DP item lands through production's own save")
        #expect(plantLegacyItem(key, scope: scope),
                "the crash window's leavings: a legacy copy beside the bound item")

        #expect(custody.load() == key)
        #expect(!itemExists(scope: scope, dataProtection: false),
                "the read healed the half-migrated state — no file-based copy survives")
        #expect(itemExists(scope: scope, dataProtection: true))
    }

    /// Fresh saves are born bound, and the delete door takes BOTH
    /// keychains (a lingering legacy item under a demanded mode would be
    /// a silently-readable copy — R13p-14's theater).
    @Test func freshSavesAreBornBoundAndDeleteTakesBothKeychains() {
        let scope = "82-fresh-\(UUID().uuidString)"
        defer { cleanUp(scope: scope) }
        let key = StoreKey.mint()
        let custody = StoreKeyCustody.deviceKeychain(scope: scope)
        #expect(custody.save(key))
        #expect(itemExists(scope: scope, dataProtection: true), "born in the DP keychain")
        #expect(!itemExists(scope: scope, dataProtection: false))

        _ = plantLegacyItem(key, scope: scope)  // a stale straggler
        StoreKeyCustody.deviceKeychainRemove(scope: scope)
        #expect(!itemExists(scope: scope, dataProtection: true),
                "the delete reaches the bound item")
        #expect(!itemExists(scope: scope, dataProtection: false),
                "and the file-based straggler — no silent copy survives a demanded mode")
    }
}
