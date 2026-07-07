//
//  SyncCredentialsStore.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 8, Step 6 — the device credential mechanism (PROVISIONAL, ratify
//  at checkpoint): a paste-in field on first launch stores the Supabase URL
//  + keys in the Keychain. Nothing is ever bundled into the app or
//  committed; the author's key rotations are handled by re-pasting.
//  `AfterFirstUnlock` so a background-transition sync round after the phone
//  locks can still read them (the STORE's file protection is the riskier
//  half — the engine treats a protection error as offline, plan risk note).
//

import Foundation
import Security
import VariorumCore

struct SyncCredentials: Equatable, Codable, Sendable {
    var projectURL: URL
    var apiKey: String
    /// Bearer token. The single-user phase commonly reuses the API key —
    /// UI passes the key here when the author leaves the token field blank.
    var authToken: String

    var transportConfiguration: SupabaseTransport.Configuration {
        .init(projectURL: projectURL, apiKey: apiKey, authToken: authToken)
    }
}

enum SyncCredentialsStore {
    private static let service = "io.lduarte.Variorum.sync"
    private static let account = "supabase"

    static func load() -> SyncCredentials? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return try? JSONDecoder().decode(SyncCredentials.self, from: data)
    }

    @discardableResult
    static func save(_ credentials: SyncCredentials) -> Bool {
        guard let data = try? JSONEncoder().encode(credentials) else { return false }
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
