//
//  NamesAndSealTests.swift
//  VariorumCoreTests — VX-305 U1 (the model): the names with the scope in every
//  one, the strict parsers, and the seal (design §3.6).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U1 — the names: the scope in every name, strict parsers")
struct ProtectionNamesTests {
    static let fp = "0123456789abcdef"
    static let uuid = "6f1c2a8e-3b4d-4e5f-8a9b-0c1d2e3f4a5b"

    @Test func everyItemNameCarriesTheScope() {
        for scope in ["Variorum", "Variorum-dev"] {
            #expect(ProtectionNames.custodyAccount(scope: scope, fingerprint: Self.fp, class: .silent)
                .hasPrefix("\(scope)-"))
            #expect(ProtectionNames.syncKeysAccount(scope: scope, accountID: Self.uuid, class: .touchid)
                .hasPrefix("\(scope)-"))
            #expect(ProtectionNames.memoryAccount(scope: scope, libraryID: Self.uuid).hasPrefix("\(scope)-"))
            #expect(ProtectionNames.appleKeyAccount(scope: scope, id: Self.uuid).hasPrefix("\(scope)-"))
        }
        #expect(ProtectionNames.custodyAccount(scope: "Variorum", fingerprint: Self.fp, class: .touchid)
            == "Variorum-0123456789abcdef-touchid")
        #expect(ProtectionNames.appleKeyAccount(scope: "Variorum-dev", id: Self.uuid)
            == "Variorum-dev-apple-key-\(Self.uuid)")
    }

    @Test func theParsersRoundTrip() {
        let custody = ProtectionNames.custodyAccount(scope: "Variorum-dev", fingerprint: Self.fp, class: .touchid)
        #expect(ProtectionNames.parseCustodyAccount(custody, scope: "Variorum-dev")?.fingerprint == Self.fp)
        #expect(ProtectionNames.parseCustodyAccount(custody, scope: "Variorum-dev")?.class == .touchid)
        let sync = ProtectionNames.syncKeysAccount(scope: "Variorum", accountID: Self.uuid, class: .silent)
        #expect(ProtectionNames.parseSyncKeysAccount(sync, scope: "Variorum")?.accountID == Self.uuid)
        #expect(ProtectionNames.parseMemoryAccount(
            ProtectionNames.memoryAccount(scope: "Variorum", libraryID: Self.uuid), scope: "Variorum") == Self.uuid)
        #expect(ProtectionNames.parseAppleKeyAccount(
            ProtectionNames.appleKeyAccount(scope: "Variorum", id: Self.uuid), scope: "Variorum") == Self.uuid)
        #expect(ProtectionNames.parseAppleKeyAccount("Variorum-apple-key", scope: "Variorum") == nil,
                "today's old shared name is not this design's (rule 26)")
    }

    /// The fence: under the scope `Variorum`, nothing of `Variorum-dev`'s
    /// parses — even though every dev name starts with `Variorum-`.
    @Test func aNeighbouringScopeNeverParsesAsOurs() {
        let dev = "Variorum-dev"
        #expect(ProtectionNames.parseCustodyAccount(
            ProtectionNames.custodyAccount(scope: dev, fingerprint: Self.fp, class: .silent), scope: "Variorum") == nil)
        #expect(ProtectionNames.parseSyncKeysAccount(
            ProtectionNames.syncKeysAccount(scope: dev, accountID: Self.uuid, class: .silent), scope: "Variorum") == nil)
        #expect(ProtectionNames.parseMemoryAccount(
            ProtectionNames.memoryAccount(scope: dev, libraryID: Self.uuid), scope: "Variorum") == nil)
        #expect(ProtectionNames.parseAppleKeyAccount(
            ProtectionNames.appleKeyAccount(scope: dev, id: Self.uuid), scope: "Variorum") == nil)
        #expect(ProtectionNames.parseAppleKeyAccount("Variorum-dev-apple-key", scope: "Variorum") == nil)
        // Malformed tails.
        #expect(ProtectionNames.parseCustodyAccount("Variorum-0123-silent", scope: "Variorum") == nil)
        #expect(ProtectionNames.parseCustodyAccount("Variorum-\(Self.fp)-bound", scope: "Variorum") == nil)
        #expect(ProtectionNames.parseAppleKeyAccount("Variorum-apple-key-not-a-uuid", scope: "Variorum") == nil)
    }

    @Test func theCustodyClassFollowsTheKeysKindForLife() {
        #expect(ProtectionNames.CustodyClass.for(.standard) == .silent)
        #expect(ProtectionNames.CustodyClass.for(.castle) == .touchid)
    }

    @Test func theFoldersAreNamedByLibraryAndMac() {
        #expect(ProtectionNames.backupsSubpath(libraryID: Self.uuid, deviceID: "a1b2c3d4-0000-4000-8000-000000000000")
            == "Backups/6f1c2a8e/a1b2c3d4")
        #expect(ProtectionNames.keyFilename == "variorum-library-keys.json")
        #expect(ProtectionNames.keyFilename != StoreKeyEnvelope.legacyFilename)
    }
}

@Suite("VX-305 U1 — the seal: HKDF + HMAC over the canonical bytes")
struct ProtectionSealTests {
    struct Sample: Codable, Equatable, Sendable {
        var name: String
        var count: Int
        var when: Date
        var blob: Data
    }

    static let libraryID = "6f1c2a8e-3b4d-4e5f-8a9b-0c1d2e3f4a5b"

    private func sample() -> Sample {
        Sample(name: "a / b", count: 7, when: Date(timeIntervalSinceReferenceDate: 781_234_567.123_456_7),
               blob: Data([0, 1, 2, 250]))
    }

    /// The design's formula, recomputed here from first principles.
    @Test func theSealIsTheDesignsFormula() throws {
        let key = StoreKey.mint()
        let sealed = try Sealed.sealing(sample(), purpose: .memory, libraryID: Self.libraryID, key: key)
        let derived = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: key.data), salt: Data(Self.libraryID.utf8),
            info: Data("variorum.seal.v1:memory".utf8), outputByteCount: 32)
        let expected = Data(HMAC<SHA256>.authenticationCode(for: sealed.payload, using: derived))
        #expect(sealed.seal.mac == expected)
        #expect(sealed.seal.keyFingerprint == StoreKeyEnvelope.fingerprint(of: key))
        #expect(sealed.payload == (try ProtectionCoding.canonical(sample())))
    }

    @Test func aSealedValueRoundTripsBitExact() throws {
        let key = StoreKey.mint()
        let sealed = try Sealed.sealing(sample(), purpose: .plan, libraryID: Self.libraryID, key: key)
        let stored = try ProtectionCoding.canonical(sealed)
        let reread = try ProtectionCoding.decoder().decode(Sealed<Sample>.self, from: stored)
        #expect(reread == sealed)
        #expect(try reread.open(purpose: .plan, libraryID: Self.libraryID, key: key) == sample())
    }

    /// A tampered sealed field fails verification — and so does the right
    /// value under the wrong purpose, library or key.
    @Test func aTamperedOrMisdirectedSealFails() throws {
        let key = StoreKey.mint()
        let sealed = try Sealed.sealing(sample(), purpose: .memory, libraryID: Self.libraryID, key: key)
        // Edit one field inside the payload.
        var edited = sample()
        edited.count = 8
        let forged = Sealed<Sample>(payload: try ProtectionCoding.canonical(edited), seal: sealed.seal)
        #expect(throws: SealError.doesNotVerify) {
            _ = try forged.open(purpose: .memory, libraryID: Self.libraryID, key: key)
        }
        // Flip one byte of the payload.
        var flipped = sealed.payload
        flipped[flipped.startIndex + 3] ^= 0x01
        #expect(throws: SealError.self) {
            _ = try Sealed<Sample>(payload: flipped, seal: sealed.seal)
                .open(purpose: .memory, libraryID: Self.libraryID, key: key)
        }
        #expect(throws: SealError.doesNotVerify) {
            _ = try sealed.open(purpose: .plan, libraryID: Self.libraryID, key: key)
        }
        #expect(throws: SealError.doesNotVerify) {
            _ = try sealed.open(purpose: .memory, libraryID: UUID().uuidString.lowercased(), key: key)
        }
        #expect(throws: SealError.sealedUnderAnotherKey(sealed.sealedUnder)) {
            _ = try sealed.open(purpose: .memory, libraryID: Self.libraryID, key: StoreKey.mint())
        }
    }

    @Test func anOlderSealOpensThroughTheReach() throws {
        let old = StoreKey.mint()
        let current = StoreKey.mint()
        let sealed = try Sealed.sealing(sample(), purpose: .plan, libraryID: Self.libraryID, key: old)
        let keys = [StoreKeyEnvelope.fingerprint(of: old): old, StoreKeyEnvelope.fingerprint(of: current): current]
        #expect(try sealed.open(purpose: .plan, libraryID: Self.libraryID, reach: { keys[$0] }) == sample())
        #expect(throws: SealError.self) {
            _ = try sealed.open(purpose: .plan, libraryID: Self.libraryID, reach: { _ in current })
        }
    }
}
