//
//  ProtectionFactsGathererTests.swift
//  VariorumTests — VX-306 U1a: the facts `assess` reads, gathered from PLANTED state (planted custody and
//  memory leaves over a real library file in a temp slot — no Keychain): rule 27's custody fact never reads
//  could-not-read as opens-nothing (the VX-378 ladder's round-2 NIT), a Touch ID item is counted and never
//  pressed, the memory's key-file copies are read as stated, an unlistable keychain throws rather than
//  reading as "no road", and the launch facts (the store, the marker, the hint).
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("VX-306 U1a — the facts gatherer, from planted state")
struct ProtectionFactsGathererTests {
    final class Rig {
        let slot = TempSlot()
        let custody = PlantedCustodyLeaf()
        let memory = PlantedMemoryLeaf()
        let system: ProtectionSystem

        init() {
            system = ProtectionSystem(
                scope: ThrowawayScope().scope, places: slot.places, deviceName: "Test Mac", floor: .relaxedForTests,
                custody: custody, syncKeys: EmptySyncKeysLeaf(), apple: InMemoryAppleKeysLeaf(), memory: memory,
                biometry: FixedBiometryLeaf(.ready))
        }

        func library(_ key: StoreKey) throws {
            try system.leaves.library.createLibrary(
                with: key,
                record: ProtectionRecord.minting(
                    libraryID: UUID().uuidString.lowercased(), mode: .standard, account: nil,
                    currentFingerprint: KeyFingerprint.of(key), at: Date()))
        }
    }

    static func fp(_ key: StoreKey) -> String { KeyFingerprint.of(key) }

    @Test func rule27sCustodyFactNeverReadsCouldNotReadAsOpensNothing() throws {
        let rig = Rig()
        let opener = StoreKey.mint(), stranger = StoreKey.mint(), unreadable = StoreKey.mint(), castle = StoreKey.mint()
        try rig.library(opener)
        rig.custody.items[CustodyItemFact(fingerprint: Self.fp(opener), itemClass: .silent)] = opener
        rig.custody.items[CustodyItemFact(fingerprint: Self.fp(stranger), itemClass: .silent)] = stranger
        rig.custody.items[CustodyItemFact(fingerprint: Self.fp(unreadable), itemClass: .silent)] = unreadable
        rig.custody.unreadable = [Self.fp(unreadable)]
        rig.custody.items[CustodyItemFact(fingerprint: Self.fp(castle), itemClass: .touchid)] = castle
        let facts = try rig.system.facts(session: .signedOut)
        #expect(facts.custodyOpensLibrary == [Self.fp(opener), Self.fp(unreadable)],
                "the opener and the unreadable item count; the stranger verifiably opens nothing")
        #expect(facts.custody.contains(CustodyItemFact(fingerprint: Self.fp(castle), itemClass: .touchid)), "the Touch ID item is counted")
        #expect(!rig.custody.reads.contains(.touchid), "and never pressed")
        #expect(facts.storeFile == .present && facts.unlocked == nil && facts.vault == nil)
    }

    @Test func theMemorysKeyFileCopiesAreReadAsStatedAndAnUnreadableOneMakesTheFactUnknown() throws {
        let rig = Rig()
        let key = StoreKey.mint(), other = StoreKey.mint()
        let libraryID = UUID().uuidString.lowercased()
        let mirror = try KeyFile.building(
            libraryID: libraryID, key: key, epoch: 1, locks: NewKeyLocks(words: try WordsKey.derive(try RecoveryPhrase.generate())))
        let memory = DeviceMemory(libraryID: libraryID, currentFingerprint: Self.fp(key), deviceID: UUID().uuidString, keyFileMirror: mirror)
        // Sealed under ANOTHER key: the fact is read as the item states it, never verified.
        rig.memory.items[libraryID] = try memory.sealed(under: other)
        var facts = try rig.system.facts(session: .signedOut)
        #expect(facts.rememberedLibraryIDs == [libraryID])
        #expect(facts.rememberedKeyFileCopies == [mirror.fingerprint])
        rig.memory.unreadable = [libraryID]
        facts = try rig.system.facts(session: .signedOut)
        #expect(facts.rememberedKeyFileCopies == nil, "not read — every remembered library then counts")
    }

    @Test func anUnlistableKeychainThrowsInsteadOfReadingAsNoRoad() throws {
        let rig = Rig()
        try rig.library(StoreKey.mint())
        rig.custody.listingFails = true
        #expect(throws: ProtectionFactsGatherer.GatherError.self) { try rig.system.facts(session: .signedOut) }
    }

    @Test func theLaunchFactsComeFromTheSlotTheMarkerAndTheLiveKeyFile() throws {
        let rig = Rig()
        var facts = try rig.system.facts(session: .signedOut)
        #expect(facts.storeFile == .absent && !facts.containerMarker)
        #expect(assess(facts).launch == .startFresh)
        let key = StoreKey.mint()
        try rig.library(key)
        let file = try KeyFile.building(
            libraryID: UUID().uuidString.lowercased(), key: key, epoch: 1,
            locks: NewKeyLocks(words: try WordsKey.derive(try RecoveryPhrase.generate())))
        try rig.system.leaves.keyFiles.writeLiveKeyFile(file)
        facts = try rig.system.facts(session: .signedOut)
        #expect(facts.storeFile == .present && facts.containerMarker)
        #expect(facts.slotFingerprintHint == file.fingerprint)
        #expect(facts.catalog.liveKeyFile?.document == file)
        #expect(assess(facts).launch == .lobby)
        // The library gone, the marker stays: the library is missing, never a fresh start.
        ProtectionLibraryFiles.removeWithSidecars(rig.slot.places.slot)
        facts = try rig.system.facts(session: .signedOut)
        #expect(assess(facts).launch == .libraryMissing)
    }
}
