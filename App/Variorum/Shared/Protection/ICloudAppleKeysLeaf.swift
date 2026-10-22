//
//  ICloudAppleKeysLeaf.swift
//  Variorum (shared: Mac + Mobile)
//
//  VX-306 U1a — THE PRODUCTION `AppleKeysLeaf` (`Executor/Leaves.swift`): Apple keys in iCloud Keychain —
//  synchronizable generic passwords, service `ProtectionNames.appleKeyService` (today's), account
//  `<scope>-apple-key-<id>` (NAMED BY THEIR OWN ID — the old shared `<scope>-apple-key` is never read: the
//  parser refuses it, rule 26), the SHARED access group today's `AppleKeyKeychain` uses (team prefix +
//  shared suffix — the phone shares it), `kSecAttrAccessibleAfterFirstUnlock`, NO access control (Apple does
//  not sync an ACL'd item — the Apple facts §10). The value is today's `AppleKey` JSON `{id, key}`.
//    - `readableAppleKeyIDs` — the own-named items present AND readable here (each read, its id checked);
//    - `addAppleKey` — a fresh key under its own name, STAMPED (`kSecAttrLabel` = the library ID, VX-390);
//      an item already under that name is never overwritten (a key is never replaced in place) — the same
//      bytes are a landed re-run, other bytes refuse; verified by a read-back;
//    - `deleteAppleKey` — by id, matching either flag (`kSecAttrSynchronizableAny`): a synchronizable delete
//      reaches every device on the Apple account (rule 11);
//    - `appleKeyIDs(ofLibrary:)` — every own-named item stamped with the library that this device can SEE,
//      readable or not (attributes only).
//  Every mutation asks the test tripwire first.
//

import CryptoKit
import Foundation
import Security
import VariorumCore

nonisolated final class ICloudAppleKeysLeaf: AppleKeysLeaf, @unchecked Sendable {
    static let service = ProtectionNames.appleKeyService

    let scope: String

    init(scope: String) { self.scope = scope }

    func account(_ id: String) -> String { ProtectionNames.appleKeyAccount(scope: scope, id: id) }

    /// The own-named items listed here, with their stamps (attributes only).
    func listed() throws -> [(id: String, libraryID: String?)] {
        try ProtectionKeychain.list(service: Self.service, residence: .synchronizable).compactMap { attributes in
            guard let account = ProtectionKeychain.account(of: attributes),
                  let id = ProtectionNames.parseAppleKeyAccount(account, scope: scope) else { return nil }
            return (id, ProtectionKeychain.label(of: attributes))
        }
    }

    func readableAppleKeyIDs() throws -> Set<String> {
        Set(try listed().compactMap { entry in (try? readAppleKey(id: entry.id)) != nil ? entry.id : nil })
    }

    func readAppleKey(id: String) throws -> AppleKeyMaterial? {
        guard let data = try ProtectionKeychain.readData(service: Self.service, account: account(id), residence: .synchronizable),
              let value = try? JSONDecoder().decode(StoredAppleKey.self, from: data), value.id == id, value.key.count == 32
        else { return nil }
        return AppleKeyMaterial(id: id, key: SymmetricKey(data: value.key))
    }

    func addAppleKey(_ key: AppleKeyMaterial, libraryID: String) throws {
        try ProtectionKeychain.refuseUnderTest(scope, "apple.add")
        let bytes = key.key.withUnsafeBytes { Data($0) }
        let data = try JSONEncoder().encode(StoredAppleKey(id: key.id, key: bytes))
        var attributes = ProtectionKeychain.base(service: Self.service, account: account(key.id), residence: .synchronizable)
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        attributes[kSecAttrLabel as String] = libraryID
        let status = SecItemAdd(attributes as CFDictionary, nil)
        guard status == errSecSuccess || status == errSecDuplicateItem else {
            throw ProtectionKeychain.KeychainError.status(status, "apple.add")
        }
        guard let back = try readAppleKey(id: key.id), back.key.withUnsafeBytes({ Data($0) }) == bytes else {
            throw ProtectionKeychain.KeychainError.writeDidNotReadBack("apple.add")
        }
    }

    func deleteAppleKey(id: String) throws {
        try ProtectionKeychain.refuseUnderTest(scope, "apple.delete")
        try ProtectionKeychain.delete(service: Self.service, account: account(id), residence: .synchronizable)
    }

    func appleKeyIDs(ofLibrary libraryID: String) throws -> Set<String> {
        Set(try listed().filter { $0.libraryID == libraryID }.map(\.id))
    }

    /// The item's value: the Apple key's id and its 32 bytes, as JSON — the coding shape today's `AppleKey` gave the
    /// family (`{"id","key"}`), kept byte-for-byte when that type left with today's road (VX-329 U1), so every item
    /// this leaf wrote still reads.
    private struct StoredAppleKey: Codable {
        var id: String
        var key: Data
    }
}
