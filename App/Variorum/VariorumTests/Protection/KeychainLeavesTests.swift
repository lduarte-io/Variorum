//
//  KeychainLeavesTests.swift
//  VariorumTests — VX-306 U1a: the device-only keychain leaves against the REAL Keychain in the signed test
//  host, under a THROWAWAY scope (`vx306-<uuid>`), every item purged in `defer` — custody (the stamp, the
//  read-back, the scope fence; a Touch ID item listed by name and never pressed), what this Mac remembers
//  (enumerated by name, no payload read), the sync keys and the session hold.
//

import CryptoKit
import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U1a — the device-only keychain leaves (throwaway scopes)", .serialized)
struct KeychainLeavesTests {
    // MARK: Custody

    @Test func aSilentItemIsWrittenStampedReadBackRestampedAndDeleted() throws {
        let throwaway = ThrowawayScope()
        defer { throwaway.purge() }
        let leaf = KeychainCustodyLeaf(scope: throwaway.scope)
        let key = StoreKey.mint()
        let fingerprint = KeyFingerprint.of(key)
        let first = UUID().uuidString.lowercased(), second = UUID().uuidString.lowercased()
        #expect(try leaf.custodyItems().isEmpty)
        try leaf.writeCustody(key, itemClass: .silent, libraryID: first)
        let listed = try leaf.custodyItems()
        #expect(listed == [CustodyItemFact(fingerprint: fingerprint, itemClass: .silent)])
        #expect(listed.first?.libraryID == first, "the stamp rides the item")
        #expect(try leaf.readCustody(fingerprint: fingerprint, itemClass: .silent) == key)
        try leaf.writeCustody(key, itemClass: .silent, libraryID: second)
        #expect(try leaf.custodyItems().first?.libraryID == second, "a rewrite carries the new stamp")
        #expect(throwaway.accounts(ProtectionNames.custodyService) == [
            ProtectionNames.custodyAccount(scope: throwaway.scope, fingerprint: fingerprint, class: .silent),
        ])
        try leaf.deleteCustody(fingerprint: fingerprint, itemClass: .silent)
        #expect(try leaf.custodyItems().isEmpty)
        #expect(try leaf.readCustody(fingerprint: fingerprint, itemClass: .silent) == nil)
        try leaf.deleteCustody(fingerprint: fingerprint, itemClass: .silent)  // released twice is fine
    }

    @Test func aScopeListsOnlyItsOwnItems() throws {
        let a = ThrowawayScope(), b = ThrowawayScope()
        defer { a.purge(); b.purge() }
        let keyA = StoreKey.mint(), keyB = StoreKey.mint()
        try KeychainCustodyLeaf(scope: a.scope).writeCustody(keyA, itemClass: .silent, libraryID: "a")
        try KeychainCustodyLeaf(scope: b.scope).writeCustody(keyB, itemClass: .silent, libraryID: "b")
        #expect(try KeychainCustodyLeaf(scope: a.scope).custodyItems().map(\.fingerprint) == [KeyFingerprint.of(keyA)])
        #expect(try KeychainCustodyLeaf(scope: b.scope).custodyItems().map(\.fingerprint) == [KeyFingerprint.of(keyB)])
    }

    /// A Touch ID item: made, listed BY NAME over the candidates, never pressed, deleted without a prompt.
    /// Enabled where a finger is enrolled (the Apple facts §4: a `.biometryCurrentSet` item needs one).
    @Test(.enabled(if: LAEnvironmentBiometryLeaf().biometry().enrolled, "needs a Touch ID finger enrolled on this Mac"))
    func aTouchIDItemIsListedByNameAndNeverPressed() throws {
        let throwaway = ThrowawayScope()
        defer { throwaway.purge() }
        let key = StoreKey.mint()
        let fingerprint = KeyFingerprint.of(key)
        let leaf = KeychainCustodyLeaf(scope: throwaway.scope, touchIDCandidates: { [fingerprint] })
        try leaf.writeCustody(key, itemClass: .touchid, libraryID: UUID().uuidString.lowercased())
        #expect(try leaf.custodyItems().contains(CustodyItemFact(fingerprint: fingerprint, itemClass: .touchid)))
        // No candidate names it: the skipping listing cannot see it (it is no quiet road — rule 9).
        let blind = KeychainCustodyLeaf(scope: throwaway.scope)
        #expect(!(try blind.custodyItems().contains(CustodyItemFact(fingerprint: fingerprint, itemClass: .touchid))))
        // A second write of the same key keeps the item (never an in-place update — that would prompt).
        try leaf.writeCustody(key, itemClass: .touchid, libraryID: UUID().uuidString.lowercased())
        try leaf.deleteCustody(fingerprint: fingerprint, itemClass: .touchid)
        #expect(!(try leaf.custodyItems().contains(CustodyItemFact(fingerprint: fingerprint, itemClass: .touchid))))
    }

    // MARK: What this Mac remembers

    @Test func theMemoryIsRememberedByNameAndReadBackSealed() throws {
        let throwaway = ThrowawayScope()
        defer { throwaway.purge() }
        let leaf = KeychainMemoryLeaf(scope: throwaway.scope)
        let key = StoreKey.mint()
        let libraryID = UUID().uuidString.lowercased()
        let memory = DeviceMemory(
            libraryID: libraryID, currentFingerprint: KeyFingerprint.of(key),
            deviceID: UUID().uuidString.lowercased())
        let sealed = try memory.sealed(under: key)
        try leaf.writeMemory(sealed, libraryID: libraryID)
        #expect(try leaf.rememberedLibraryIDs() == [libraryID])
        #expect(try leaf.readMemory(libraryID: libraryID) == sealed)
        #expect(try leaf.readMemory(libraryID: libraryID).flatMap { DeviceMemory.opening($0, libraryID: libraryID) { _ in key } } == memory)
        // Bytes that are not a sealed memory: read as none, still REMEMBERED BY NAME (no payload read).
        try ProtectionKeychain.upsert(
            service: ProtectionNames.memoryService, account: leaf.account(libraryID), residence: .deviceOnly,
            data: Data("not a memory".utf8), label: nil, accessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
        #expect(try leaf.readMemory(libraryID: libraryID) == nil)
        #expect(try leaf.rememberedLibraryIDs() == [libraryID])
        try leaf.deleteMemory(libraryID: libraryID)
        #expect(try leaf.rememberedLibraryIDs().isEmpty)
    }

    // MARK: Sync keys

    @Test func theSyncKeysRoundTripSilentlyAndTheSessionHoldIsMemoryOnly() throws {
        let throwaway = ThrowawayScope()
        defer { throwaway.purge() }
        let leaf = KeychainSyncKeysLeaf(scope: throwaway.scope)
        let account = UUID().uuidString.lowercased()
        let keys = AccountKeys(
            master: Data(repeating: 7, count: 32), rowKeyID: UUID().uuidString.lowercased(),
            rowKey: Data(repeating: 8, count: 32), earlierRowKeys: ["old": Data(repeating: 9, count: 32)])
        try leaf.writeSyncKeys(keys, accountID: account, itemClass: .silent)
        #expect(try leaf.syncKeyItems() == [SyncKeysItemFact(accountID: account, itemClass: .silent)])
        #expect(try leaf.readSyncKeys(accountID: account, itemClass: .silent) == keys)
        try leaf.deleteSyncKeys(accountID: account, itemClass: .silent)
        #expect(try leaf.syncKeyItems().isEmpty)
        leaf.holdInSession(keys, accountID: account)
        #expect(leaf.sessionSyncKeys(accountID: account) == keys)
        #expect(KeychainSyncKeysLeaf(scope: throwaway.scope).sessionSyncKeys(accountID: account) == nil, "memory only")
        leaf.holdInSession(nil, accountID: account)
        #expect(leaf.sessionSyncKeys(accountID: account) == nil)
        #expect(throwaway.accounts(ProtectionNames.syncKeysService).isEmpty, "nothing written for the session")
    }
}
