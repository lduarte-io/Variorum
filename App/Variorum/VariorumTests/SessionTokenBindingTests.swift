//
//  SessionTokenBindingTests.swift
//  VariorumTests
//
//  pre-13x batch 1a (the postures design §1.13 / §3.1) — the session
//  tokens are DEVICE-BOUND: `KeychainAuthStorage` lives in the
//  data-protection keychain under `session-bound` with
//  `WhenUnlockedThisDeviceOnly` in force, and the 9c-era file-based item
//  under `session` migrates by the TN3137 road (read → re-add → verify →
//  delete legacy). A cloned Mac signs in again — recorded, not a bug.
//
//  These pins run in the SIGNED host (the StoreKeyBindingTests precedent):
//  DP writes need the keychain identity. Every item is under a THROWAWAY
//  SERVICE, never `io.lduarte.Variorum.auth` — the author's live session
//  is never read or written here.
//
//  RED ON OLD: the 9c code reads and writes the file-based `session` item
//  only — no bound item is ever minted, the legacy copy never released.
//

import Foundation
import Security
import Testing

@testable import Variorum

@Suite("pre-13x 1a — the session tokens are device-bound")
struct SessionTokenBindingTests {
    private func tokens(_ tag: String) -> AuthTokens {
        AuthTokens(
            accessToken: "access-\(tag)", refreshToken: "refresh-\(tag)",
            expiresAt: Date(timeIntervalSince1970: 1_800_000_000),
            userID: "user-\(tag)", email: "\(tag)@example.com")
    }

    private func query(service: String, bound: Bool) -> [String: Any] {
        var q: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: bound ? "session-bound" : "session",
        ]
        if bound { q[kSecUseDataProtectionKeychain as String] = true }
        return q
    }

    /// The 9c world's item: file-based, `AfterFirstUnlock`, account `session`.
    private func plantLegacyItem(_ tokens: AuthTokens, service: String) -> Bool {
        var attributes = query(service: service, bound: false)
        attributes[kSecValueData as String] = try! JSONEncoder().encode(tokens)
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        return SecItemAdd(attributes as CFDictionary, nil) == errSecSuccess
    }

    private func itemExists(service: String, bound: Bool) -> Bool {
        var probe = query(service: service, bound: bound)
        probe[kSecReturnAttributes as String] = true
        probe[kSecMatchLimit as String] = kSecMatchLimitOne
        return SecItemCopyMatching(probe as CFDictionary, nil) == errSecSuccess
    }

    private func cleanUp(service: String) {
        SecItemDelete(query(service: service, bound: true) as CFDictionary)
        SecItemDelete(query(service: service, bound: false) as CFDictionary)
    }

    @Test func aLegacySessionMigratesIntoTheBoundItemOnLoad() {
        let service = "io.lduarte.Variorum.auth-1a-test-\(UUID().uuidString)"
        defer { cleanUp(service: service) }
        let session = tokens("legacy")
        #expect(plantLegacyItem(session, service: service), "the 9c world is planted")

        #expect(KeychainAuthStorage.load(service: service) == session,
                "the session is in hand — signing in never hinges on the move")
        #expect(itemExists(service: service, bound: true),
                "the bound DP item exists — ThisDeviceOnly is IN FORCE")
        #expect(!itemExists(service: service, bound: false),
                "the file-based copy — the one Migration Assistant carries — is GONE")
        #expect(KeychainAuthStorage.load(service: service) == session, "idempotent")
    }

    @Test func freshSavesAreBornBoundAndClearTakesBothShapes() {
        let service = "io.lduarte.Variorum.auth-1a-test-\(UUID().uuidString)"
        defer { cleanUp(service: service) }
        let session = tokens("fresh")
        #expect(KeychainAuthStorage.save(session, service: service))
        #expect(itemExists(service: service, bound: true), "born bound")
        #expect(!itemExists(service: service, bound: false))
        #expect(KeychainAuthStorage.load(service: service) == session)

        _ = plantLegacyItem(tokens("straggler"), service: service)
        #expect(KeychainAuthStorage.clear(service: service))
        #expect(!itemExists(service: service, bound: true), "clear reaches the bound item")
        #expect(!itemExists(service: service, bound: false), "and the file-based straggler")
        #expect(KeychainAuthStorage.load(service: service) == nil)
    }
}
