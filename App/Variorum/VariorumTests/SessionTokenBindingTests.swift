//
//  SessionTokenBindingTests.swift
//  VariorumTests
//
//  pre-13x batch 1a (the postures design §1.13 / §3.1) — the session
//  tokens are DEVICE-BOUND: `KeychainAuthStorage` lives in the
//  data-protection keychain under a bound account with
//  `WhenUnlockedThisDeviceOnly` in force, and the 9c-era file-based item
//  under `session` migrates by the TN3137 road (read → re-add → verify →
//  delete legacy). A cloned Mac signs in again — recorded, not a bug.
//
//  pre-13x batch 2c — THE iOS KEYCHAIN FENCE (corner 47): the bound
//  account carries the STORE-VARIANT SCOPE (`<scope>-session-bound`). The
//  REAL scope inherits the unscoped 1a item (`session-bound`) and the 9c
//  item (`session`) ONCE, migrating each; a DEV scope never reads, saves
//  over or deletes either — it starts signed out. Q3's early run watched
//  the phone's dev build adopt her real session through the scope-less
//  item; this is the pin that ends it.
//
//  These pins run in the SIGNED host (the StoreKeyBindingTests precedent):
//  DP writes need the keychain identity. Every item is under a THROWAWAY
//  SERVICE, never `io.lduarte.Variorum.auth` — the author's live session
//  is never read or written here.
//
//  RED ON OLD: the 1a code read the unscoped `session-bound` item for ANY
//  caller — a dev scope adopted the real session (corner 47).
//

import Foundation
import Security
import Testing

@testable import Variorum

@Suite("pre-13x 1a/2c — the session tokens are device-bound and scoped per store variant")
struct SessionTokenBindingTests {
    private let realScope = "Variorum"
    private let devScope = "Variorum-dev"

    private func tokens(_ tag: String) -> AuthTokens {
        AuthTokens(
            accessToken: "access-\(tag)", refreshToken: "refresh-\(tag)",
            expiresAt: Date(timeIntervalSince1970: 1_800_000_000),
            userID: "user-\(tag)", email: "\(tag)@example.com")
    }

    private func query(service: String, account: String, dataProtection: Bool) -> [String: Any] {
        var q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        if dataProtection { q[kSecUseDataProtectionKeychain as String] = true }
        return q
    }

    /// The 9c world's item: file-based, `AfterFirstUnlock`, account `session`.
    private func plantLegacyItem(_ tokens: AuthTokens, service: String) -> Bool {
        var attributes = query(service: service, account: "session", dataProtection: false)
        attributes[kSecValueData as String] = try! JSONEncoder().encode(tokens)
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        return SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess
    }

    /// The 1a world's item: DP, `WhenUnlockedThisDeviceOnly`, the UNSCOPED
    /// `session-bound` account — the corner-47 item.
    private func plantUnscopedBoundItem(_ tokens: AuthTokens, service: String) -> Bool {
        var attributes = query(service: service, account: "session-bound", dataProtection: true)
        attributes[kSecValueData as String] = try! JSONEncoder().encode(tokens)
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        return SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess
    }

    private func itemExists(service: String, account: String, dataProtection: Bool) -> Bool {
        var probe = query(service: service, account: account, dataProtection: dataProtection)
        probe[kSecReturnAttributes as String] = true
        probe[kSecMatchLimit as String] = kSecMatchLimitOne
        return SecItemCopyMatching(probe as CFDictionary, nil) == errSecSuccess
    }

    private func cleanUp(service: String) {
        for scope in [realScope, devScope] {
            SecItemDelete(query(service: service, account: "\(scope)-session-bound", dataProtection: true) as CFDictionary)
        }
        SecItemDelete(query(service: service, account: "session-bound", dataProtection: true) as CFDictionary)
        SecItemDelete(query(service: service, account: "session", dataProtection: false) as CFDictionary)
    }

    @Test func aLegacySessionMigratesIntoTheScopedBoundItemOnLoad() {
        let service = "io.lduarte.Variorum.auth-1a-test-\(UUID().uuidString)"
        defer { cleanUp(service: service) }
        let session = tokens("legacy")
        #expect(plantLegacyItem(session, service: service), "the 9c world is planted")

        #expect(KeychainAuthStorage.load(service: service, scope: realScope) == session,
                "the session is in hand — signing in never hinges on the move")
        #expect(itemExists(service: service, account: "Variorum-session-bound", dataProtection: true),
                "the SCOPED bound DP item exists — ThisDeviceOnly is IN FORCE")
        #expect(!itemExists(service: service, account: "session", dataProtection: false),
                "the file-based copy — the one Migration Assistant carries — is GONE")
        #expect(KeychainAuthStorage.load(service: service, scope: realScope) == session, "idempotent")
    }

    @Test func freshSavesAreBornBoundAndClearTakesEveryShapeTheScopeOwns() {
        let service = "io.lduarte.Variorum.auth-1a-test-\(UUID().uuidString)"
        defer { cleanUp(service: service) }
        let session = tokens("fresh")
        #expect(KeychainAuthStorage.save(session, service: service, scope: realScope))
        #expect(itemExists(service: service, account: "Variorum-session-bound", dataProtection: true), "born bound, scoped")
        #expect(!itemExists(service: service, account: "session", dataProtection: false))
        #expect(KeychainAuthStorage.load(service: service, scope: realScope) == session)

        _ = plantLegacyItem(tokens("straggler"), service: service)
        _ = plantUnscopedBoundItem(tokens("straggler-1a"), service: service)
        #expect(KeychainAuthStorage.clear(service: service, scope: realScope))
        #expect(!itemExists(service: service, account: "Variorum-session-bound", dataProtection: true), "clear reaches the scoped item")
        #expect(!itemExists(service: service, account: "session-bound", dataProtection: true), "and the unscoped 1a straggler")
        #expect(!itemExists(service: service, account: "session", dataProtection: false), "and the file-based straggler")
        #expect(KeychainAuthStorage.load(service: service, scope: realScope) == nil)
    }

    /// **CORNER 47 — THE FENCE (2c).** Beside a REAL session in both
    /// unscoped shapes (the 1a DP item and the 9c file-based item), a
    /// DEV-scope load reads NOTHING and leaves both untouched; a dev-scope
    /// save lands only under its own account; a dev-scope clear takes only
    /// its own. The REAL scope then inherits the unscoped 1a item once —
    /// migrated, the unscoped copies released. RED ON OLD: `load` read the
    /// unscoped `session-bound` item for any scope — the dev store came up
    /// signed in as the author (Q3's early run).
    @Test func aDevScopeNeverReadsTheUnscopedSessionAndStartsSignedOut() {
        let service = "io.lduarte.Variorum.auth-2c-test-\(UUID().uuidString)"
        defer { cleanUp(service: service) }
        let real = tokens("real")
        #expect(plantUnscopedBoundItem(real, service: service), "the 1a world: the unscoped bound item")
        #expect(plantLegacyItem(tokens("real-9c"), service: service), "the 9c world: the file-based item")

        #expect(KeychainAuthStorage.load(service: service, scope: devScope) == nil,
                "a dev scope starts SIGNED OUT — it never reads the unscoped items")
        #expect(itemExists(service: service, account: "session-bound", dataProtection: true),
                "the unscoped 1a item is untouched")
        #expect(itemExists(service: service, account: "session", dataProtection: false),
                "the 9c item is untouched")
        #expect(!itemExists(service: service, account: "Variorum-dev-session-bound", dataProtection: true),
                "nothing was migrated into the dev scope")

        let dev = tokens("dev")
        #expect(KeychainAuthStorage.save(dev, service: service, scope: devScope))
        #expect(KeychainAuthStorage.load(service: service, scope: devScope) == dev)
        #expect(itemExists(service: service, account: "session-bound", dataProtection: true)
                    && itemExists(service: service, account: "session", dataProtection: false),
                "a dev save never supersedes the unscoped items")
        #expect(KeychainAuthStorage.clear(service: service, scope: devScope))
        #expect(itemExists(service: service, account: "session-bound", dataProtection: true)
                    && itemExists(service: service, account: "session", dataProtection: false),
                "a dev clear takes only its own item")

        // The real scope inherits the unscoped 1a item ONCE: migrated to the
        // scoped account, the unscoped copies released, the 9c item swept.
        #expect(KeychainAuthStorage.load(service: service, scope: realScope) == real)
        #expect(itemExists(service: service, account: "Variorum-session-bound", dataProtection: true))
        #expect(!itemExists(service: service, account: "session-bound", dataProtection: true),
                "the unscoped 1a item is released after the move")
        #expect(KeychainAuthStorage.load(service: service, scope: realScope) == real, "idempotent")
        #expect(!itemExists(service: service, account: "session", dataProtection: false),
                "the 9c item is swept once the scoped item stands")
        #expect(KeychainAuthStorage.inheritsUnscopedItems(scope: realScope)
                    && !KeychainAuthStorage.inheritsUnscopedItems(scope: devScope))
    }

    // (Corner 47's legacy-legs pin — `LegacyLegs`, the §11 migration's 14b/13p legs — was deleted with its subject,
    // `ProtectionMigration`, at VX-329 U1.)
}
