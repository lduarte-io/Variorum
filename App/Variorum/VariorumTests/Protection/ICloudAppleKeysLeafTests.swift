//
//  ICloudAppleKeysLeafTests.swift
//  VariorumTests — VX-306 U1a: the Apple-keys leaf against the REAL iCloud Keychain family (synchronizable,
//  the shared group), under a throwaway scope.
//
//  DISABLED BY DEFAULT — the `AppleKeyRoundTripTests` opt-in pattern: a synchronizable item rides into the
//  author's iCloud Keychain for the moments between add and delete (its tombstone follows), so the suite runs
//  only when asked:
//
//      TEST_RUNNER_VARIORUM_APPLE_KEY_ROUND_TRIP=1 xcodebuild test … \
//        -only-testing:VariorumTests/ICloudAppleKeysLeafTests
//
//  The real scopes' items are never read, written or deleted here.
//

import CryptoKit
import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite(
    "VX-306 U1a — the Apple-keys leaf round-trips on this Mac (opt-in; DISABLED unless VARIORUM_APPLE_KEY_ROUND_TRIP=1)",
    .serialized,
    .enabled(if: AppleKeyRoundTrip.requested, "writes synchronizable throwaway items — run with TEST_RUNNER_VARIORUM_APPLE_KEY_ROUND_TRIP=1"))
struct ICloudAppleKeysLeafTests {
    @Test func aKeyIsAddedStampedReadBackListedByItsLibraryAndDeleted() throws {
        let throwaway = ThrowawayScope()
        let leaf = ICloudAppleKeysLeaf(scope: throwaway.scope)
        let key = AppleKeyMaterial.mint()
        let libraryID = UUID().uuidString.lowercased()
        defer { try? leaf.deleteAppleKey(id: key.id) }
        try leaf.addAppleKey(key, libraryID: libraryID)
        #expect(try leaf.readAppleKey(id: key.id).map { $0.key.withUnsafeBytes { Data($0) } } == key.key.withUnsafeBytes { Data($0) })
        #expect(try leaf.readableAppleKeyIDs() == [key.id])
        #expect(try leaf.appleKeyIDs(ofLibrary: libraryID) == [key.id])
        #expect(try leaf.appleKeyIDs(ofLibrary: UUID().uuidString.lowercased()).isEmpty)
        // A key is never replaced in place: other bytes under the same id refuse.
        #expect(throws: (any Error).self) {
            try leaf.addAppleKey(AppleKeyMaterial(id: key.id, key: SymmetricKey(size: .bits256)), libraryID: libraryID)
        }
        try leaf.deleteAppleKey(id: key.id)
        #expect(try leaf.readAppleKey(id: key.id) == nil)
        #expect(try leaf.readableAppleKeyIDs().isEmpty)
    }
}
