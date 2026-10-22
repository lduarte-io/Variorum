//
//  ProtectionKeychainFamilyTests.swift
//  VariorumTests — VX-306 U1a: the protection keychain family's ONE builder, pinned STRUCTURALLY (the
//  `KeychainPartitionTests` idiom — no Keychain traffic): every query is data-protection resident; a
//  listing reads ATTRIBUTES ONLY and, device-only, SKIPS an item that would need authentication — so no
//  listing ever presses a Touch ID item, and the memory enumeration reads no payload; the synchronizable
//  family carries its flag and the shared access group on every verb.
//

import Foundation
import Security
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U1a — the protection keychain family's one builder")
struct ProtectionKeychainFamilyTests {
    static func flag(_ query: [String: Any], _ key: CFString) -> Bool { (query[key as String] as? Bool) == true }

    @Test func aDeviceOnlyListingReadsAttributesOnlyAndSkipsWhatWouldPrompt() {
        for service in [ProtectionNames.custodyService, ProtectionNames.syncKeysService, ProtectionNames.memoryService] {
            let query = ProtectionKeychain.listingQuery(service: service, residence: .deviceOnly)
            #expect(Self.flag(query, kSecReturnAttributes))
            #expect(query[kSecReturnData as String] == nil, "a listing never reads a payload — no Touch ID press, no memory read")
            #expect((query[kSecUseAuthenticationUI as String] as? String) == (kSecUseAuthenticationUISkip as String))
            #expect((query[kSecMatchLimit as String] as? String) == (kSecMatchLimitAll as String))
            #expect(Self.flag(query, kSecUseDataProtectionKeychain))
            #expect(query[kSecAttrSynchronizable as String] == nil, "device-only items are never synchronizable")
            #expect(query[kSecAttrAccessGroup as String] == nil)
        }
    }

    @Test func theSynchronizableFamilyCarriesItsFlagAndTheSharedGroupOnEveryVerb() {
        let base = ProtectionKeychain.base(service: ProtectionNames.appleKeyService, account: "a", residence: .synchronizable)
        #expect(Self.flag(base, kSecAttrSynchronizable))
        #expect((base[kSecAttrAccessGroup as String] as? String) == ProtectionKeychain.sharedGroup)
        #expect(Self.flag(base, kSecUseDataProtectionKeychain))
        let listing = ProtectionKeychain.listingQuery(service: ProtectionNames.appleKeyService, residence: .synchronizable)
        #expect((listing[kSecAttrSynchronizable as String] as? String) == (kSecAttrSynchronizableAny as String))
        #expect((listing[kSecAttrAccessGroup as String] as? String) == ProtectionKeychain.sharedGroup)
        #expect(listing[kSecReturnData as String] == nil)
        // VX-329 U1: the shared group moved here from today's `AppleKeyKeychain` (deleted); its value's pin moved with it.
        #expect(ProtectionKeychain.sharedGroup.hasSuffix(".io.lduarte.Variorum.shared"))
    }

    @Test func theTouchIDControlIsBiometryCurrentSetAlone() {
        #expect(ProtectionKeychain.touchIDControl() != nil)
    }

    @Test func theRealScopesAreTheTripwiresAndAThrowawayScopeIsNot() {
        #expect(KeychainTestTripwire.realScopes.contains(AppDatabase.StoreVariant.real.rawValue))
        #expect(KeychainTestTripwire.realScopes.contains(AppDatabase.StoreVariant.dev.rawValue))
        #expect(throws: Never.self) { try ProtectionKeychain.refuseUnderTest(ThrowawayScope().scope, "probe") }
    }
}

/// THE TRIPWIRE, PER LEAF — inside the tripwire's own `.serialized` suite, so its exact trip-count delta
/// never interleaves with the suite's others: every mutating protection leaf refuses a REAL scope in a test
/// process BEFORE any SecItem call (throwing `refusedUnderTest`).
extension KeychainTripwireTests {
    @Test func theProtectionLeavesRefuseEveryRealScopeMutation() throws {
        let scope = AppDatabase.StoreVariant.dev.rawValue
        let key = StoreKey.mint()
        let fingerprint = KeyFingerprint.of(key)
        let libraryID = UUID().uuidString.lowercased()
        let custody = KeychainCustodyLeaf(scope: scope)
        let memory = KeychainMemoryLeaf(scope: scope)
        let sync = KeychainSyncKeysLeaf(scope: scope)
        let apple = ICloudAppleKeysLeaf(scope: scope)
        let sealed = try DeviceMemory(libraryID: libraryID, currentFingerprint: fingerprint, deviceID: UUID().uuidString)
            .sealed(under: key)
        let keys = AccountKeys(master: Data(repeating: 1, count: 32), rowKeyID: "r", rowKey: Data(repeating: 2, count: 32))
        let before = KeychainTestTripwire.tripCount
        let attempts: [() throws -> Void] = [
            { try custody.writeCustody(key, itemClass: .silent, libraryID: libraryID) },
            { try custody.deleteCustody(fingerprint: fingerprint, itemClass: .silent) },
            { try memory.writeMemory(sealed, libraryID: libraryID) },
            { try memory.deleteMemory(libraryID: libraryID) },
            { try sync.writeSyncKeys(keys, accountID: libraryID, itemClass: .silent) },
            { try sync.deleteSyncKeys(accountID: libraryID, itemClass: .silent) },
            { try apple.addAppleKey(AppleKeyMaterial.mint(), libraryID: libraryID) },
            { try apple.deleteAppleKey(id: UUID().uuidString.lowercased()) },
        ]
        for attempt in attempts {
            #expect {
                try attempt()
            } throws: { error in
                if case ProtectionKeychain.KeychainError.refusedUnderTest = error { return true }
                return false
            }
        }
        #expect(KeychainTestTripwire.tripCount == before + attempts.count)
        let names = KeychainTestTripwire.refusedLeafNames.suffix(attempts.count)
        #expect(Array(names) == [
            "custody.write", "custody.delete", "memory.write", "memory.delete",
            "syncKeys.write", "syncKeys.delete", "apple.add", "apple.delete",
        ])
    }
}
