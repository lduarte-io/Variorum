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
    /// pre-13x 1a: the BOUND item is PER STORE ID (`<scope>-<storeID>-bound`,
    /// hardcoded here as a pin of that contract); the two LEGACY shapes are
    /// the #82-era `<scope>-bound` (DP) and the 13p-era `<scope>` (file-based).
    private func query(scope: String, storeID: String? = nil, dataProtection: Bool) -> [String: Any] {
        let account: String
        if let storeID { account = "\(scope)-\(storeID)-bound" }
        else { account = dataProtection ? "\(scope)-bound" : scope }
        var q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: StoreKeyCustody.deviceKeychainService,
            kSecAttrAccount as String: account,
        ]
        if dataProtection { q[kSecUseDataProtectionKeychain as String] = true }
        return q
    }

    /// Plants the #82-era item: DP, `<scope>-bound`, no store id.
    private func plantLegacyBoundItem(_ key: StoreKey, scope: String) -> Bool {
        var attributes = query(scope: scope, dataProtection: true)
        attributes[kSecValueData as String] = key.data
        attributes[kSecAttrAccessible as String] =
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        return SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess
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

    private func itemExists(scope: String, storeID: String? = nil, dataProtection: Bool) -> Bool {
        var probe = query(scope: scope, storeID: storeID, dataProtection: dataProtection)
        probe[kSecReturnAttributes as String] = true
        probe[kSecMatchLimit as String] = kSecMatchLimitOne
        return SecItemCopyMatching(probe as CFDictionary, nil) == errSecSuccess
    }

    private func cleanUp(scope: String, storeIDs: [String] = []) {
        SecItemDelete(query(scope: scope, dataProtection: true) as CFDictionary)
        SecItemDelete(query(scope: scope, dataProtection: false) as CFDictionary)
        for id in storeIDs {
            SecItemDelete(query(scope: scope, storeID: id, dataProtection: true) as CFDictionary)
        }
    }

    /// THE MIGRATION ROUND TRIP, red-on-old: a planted legacy item is
    /// read, re-added into the data-protection keychain (verified through
    /// the production read path), and the file-based original — the copy
    /// that rides Migration Assistant — is DELETED. Idempotent: a second
    /// load reads the bound item straight.
    @Test func aLegacyItemMigratesIntoTheDataProtectionKeychainOnLoad() {
        let scope = "82-migrate-\(UUID().uuidString)"
        let storeID = "store-\(UUID().uuidString.lowercased())"
        defer { cleanUp(scope: scope, storeIDs: [storeID]) }
        let key = StoreKey.mint()
        #expect(plantLegacyItem(key, scope: scope), "the pre-#82 world is planted")

        let custody = StoreKeyCustody.deviceKeychain(scope: scope, storeID: storeID)
        #expect(custody.load() == key, "the key is in hand — opening never hinges on the move")
        #expect(itemExists(scope: scope, storeID: storeID, dataProtection: true),
                "the item now lives in the DP keychain, per store id — ThisDeviceOnly is IN FORCE")
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
        let storeID = "store-\(UUID().uuidString.lowercased())"
        defer { cleanUp(scope: scope, storeIDs: [storeID]) }
        let key = StoreKey.mint()
        let custody = StoreKeyCustody.deviceKeychain(scope: scope, storeID: storeID)
        #expect(custody.save(key), "the DP item lands through production's own save")
        #expect(plantLegacyItem(key, scope: scope),
                "the crash window's leavings: a legacy copy beside the bound item")

        #expect(custody.load() == key)
        #expect(!itemExists(scope: scope, dataProtection: false),
                "the read healed the half-migrated state — no file-based copy survives")
        #expect(itemExists(scope: scope, storeID: storeID, dataProtection: true))
    }

    /// Fresh saves are born bound, and the delete door takes BOTH
    /// keychains (a lingering legacy item under a demanded mode would be
    /// a silently-readable copy — R13p-14's theater).
    @Test func freshSavesAreBornBoundAndDeleteTakesBothKeychains() {
        let scope = "82-fresh-\(UUID().uuidString)"
        let storeID = "store-\(UUID().uuidString.lowercased())"
        defer { cleanUp(scope: scope, storeIDs: [storeID]) }
        let key = StoreKey.mint()
        let custody = StoreKeyCustody.deviceKeychain(scope: scope, storeID: storeID)
        #expect(custody.save(key))
        #expect(itemExists(scope: scope, storeID: storeID, dataProtection: true), "born in the DP keychain, per store id")
        #expect(!itemExists(scope: scope, dataProtection: false))

        _ = plantLegacyItem(key, scope: scope)  // a stale straggler
        _ = plantLegacyBoundItem(key, scope: scope)  // and the #82-era one
        StoreKeyCustody.deviceKeychainRemove(scope: scope, storeID: storeID)
        #expect(!itemExists(scope: scope, storeID: storeID, dataProtection: true),
                "the delete reaches the bound item")
        #expect(!itemExists(scope: scope, dataProtection: true),
                "and the #82-era legacy item")
        #expect(!itemExists(scope: scope, dataProtection: false),
                "and the file-based straggler — no silent copy survives a demanded mode")
    }

    // MARK: - pre-13x 1a: custody per STORE ID (§1.13 / §14.3)

    /// A #82-era `<scope>-bound` item (DP, no store id) migrates ONCE into
    /// `<scope>-<storeID>-bound` on the first load that knows the id —
    /// verified through the production read, the legacy released; the
    /// second load reads the per-store item straight. RED ON OLD (by
    /// behavioural revert of the account naming to scope-only): the item
    /// stays under `<scope>-bound` and the per-store probe finds nothing.
    @Test func aLegacyBoundItemMigratesOnceOntoTheStoreID() {
        let scope = "1a-migrate-\(UUID().uuidString)"
        let storeID = "store-\(UUID().uuidString.lowercased())"
        defer { cleanUp(scope: scope, storeIDs: [storeID]) }
        let key = StoreKey.mint()
        #expect(plantLegacyBoundItem(key, scope: scope), "the #82 world is planted")

        let custody = StoreKeyCustody.deviceKeychain(scope: scope, storeID: storeID)
        #expect(custody.load() == key, "the key is in hand")
        #expect(itemExists(scope: scope, storeID: storeID, dataProtection: true),
                "the item now lives under the store id")
        #expect(!itemExists(scope: scope, dataProtection: true),
                "the scope-only legacy item is RELEASED — migrated once")
        #expect(custody.load() == key, "idempotent")
    }

    /// A second store under the same scope never collides: it names a
    /// different account, so it reads NOTHING of the first store's key and
    /// its own save lands beside, not over, the first's. RED ON OLD (the
    /// scope-only naming): both stores read the same item.
    @Test func aSecondStoreUnderTheSameScopeNeverCollides() {
        let scope = "1a-collide-\(UUID().uuidString)"
        let first = "store-\(UUID().uuidString.lowercased())"
        let second = "store-\(UUID().uuidString.lowercased())"
        defer { cleanUp(scope: scope, storeIDs: [first, second]) }
        let firstKey = StoreKey.mint(), secondKey = StoreKey.mint()
        let firstCustody = StoreKeyCustody.deviceKeychain(scope: scope, storeID: first)
        let secondCustody = StoreKeyCustody.deviceKeychain(scope: scope, storeID: second)
        #expect(firstCustody.save(firstKey))
        #expect(secondCustody.load() == nil, "the second store sees none of the first's custody")
        #expect(secondCustody.save(secondKey))
        #expect(firstCustody.load() == firstKey, "the first store's key is untouched by the second's save")
        #expect(secondCustody.load() == secondKey)
        #expect(StoreKeyCustody.deviceKeychainRemove(scope: scope, storeID: second))
        #expect(firstCustody.load() == firstKey, "removing the second store's item leaves the first's")
    }

    /// The store-URL road: the mint writes the KEY FILE (store id +
    /// fingerprint, no wraps) before the Keychain add, the load reads the
    /// id back from it, and a pre-1a store — a legacy item and NO key file
    /// — gets its key file and its per-store item on the first load.
    @Test func theStoreURLRoadMintsTheKeyFileAndReScopesALegacyItem() throws {
        let scope = "1a-url-\(UUID().uuidString)"
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("variorum-1a-url-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let storeURL = dir.appendingPathComponent("variorum.sqlite")
        var storeIDs: [String] = []
        defer {
            cleanUp(scope: scope, storeIDs: storeIDs)
            try? FileManager.default.removeItem(at: dir)
        }
        let custody = StoreKeyCustody.deviceKeychain(scope: scope, storeURL: storeURL)
        #expect(custody.load() == nil, "a fresh library has no custody")
        let minted = StoreKey.mint()
        #expect(custody.save(minted))
        let envelope = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: storeURL))
        storeIDs.append(envelope.storeID)
        #expect(envelope.keyFingerprint == StoreKeyEnvelope.fingerprint(of: minted),
                "the key file names the minted key")
        #expect(envelope.passphrase == nil && envelope.recovery == nil, "no wraps yet")
        #expect(StoreKeyEnvelope.locate(besideStore: storeURL)?.lastPathComponent
                == StoreKeyEnvelope.filename(forFingerprint: StoreKeyEnvelope.fingerprint(of: minted)))
        #expect(itemExists(scope: scope, storeID: envelope.storeID, dataProtection: true))
        #expect(custody.load() == minted, "the load reads the id from the file and the key from its item")

        // The pre-1a shape: a legacy item, no key file (a second scope).
        let legacyScope = "1a-url-legacy-\(UUID().uuidString)"
        let legacyDir = dir.appendingPathComponent("legacy", isDirectory: true)
        try FileManager.default.createDirectory(at: legacyDir, withIntermediateDirectories: true)
        let legacyStore = legacyDir.appendingPathComponent("variorum.sqlite")
        let legacyKey = StoreKey.mint()
        #expect(plantLegacyBoundItem(legacyKey, scope: legacyScope))
        let legacyCustody = StoreKeyCustody.deviceKeychain(scope: legacyScope, storeURL: legacyStore)
        #expect(legacyCustody.load() == legacyKey, "the legacy item opens the library")
        let legacyEnvelope = try #require(try StoreKeyEnvelope.loadCurrent(besideStore: legacyStore))
        defer { cleanUp(scope: legacyScope, storeIDs: [legacyEnvelope.storeID]) }
        #expect(itemExists(scope: legacyScope, storeID: legacyEnvelope.storeID, dataProtection: true),
                "…and is re-scoped under the freshly written key file's id")
        #expect(!itemExists(scope: legacyScope, dataProtection: true), "the legacy item released")
    }
}
