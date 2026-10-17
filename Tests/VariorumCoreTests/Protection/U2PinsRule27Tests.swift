//
//  U2PinsRule27Tests.swift
//  VariorumCoreTests — VX-378 U2 piece I: RULE 27 (`notes/CastleRules.md`: "A
//  library whose every key-file copy and every backup are gone is gone. Synced
//  libraries are the exception: the twelve words recover them from the
//  account."). The honest refusal, naming the roads that would have worked —
//  and only when nothing might still open the library. Facts built directly,
//  the refusal read through its printed form, so the red-on-old run is honest.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-378 U2 — rule 27: nothing left anywhere is said honestly, never rebuilt")
struct U2PinsRule27Tests {
    static func lobby(custody: [CustodyItemFact] = [], session: SessionFact = .signedOut,
                      entries: [CatalogEntry] = []) -> String {
        let facts = ProtectionFacts(
            scope: AWorld.scope, storeFile: .present, unlocked: nil, custody: custody, session: session,
            catalog: Catalog.build(entries), now: AWorld.now)
        return "\(assess(facts).lobby)"
    }

    @Test func aLibraryWithNoRoadAtAllIsTheHonestRefusal() {
        let signedOut = Self.lobby()
        #expect(signedOut.contains("NoKeyFileAnywhere(") && signedOut.contains("accountRoad: false"), "\(signedOut)")
        let signedIn = Self.lobby(session: .signedIn(accountID: PF.id(), email: nil))
        #expect(signedIn.contains("NoKeyFileAnywhere(") && signedIn.contains("accountRoad: true"), "\(signedIn)")
    }

    /// Anything that might still open it — a custody item holding a key, a
    /// copy's key file — says nothing.
    @Test func anythingThatMightStillOpenItSaysNothing() throws {
        #expect(!Self.lobby(custody: [CustodyItemFact(fingerprint: PF.fp(StoreKey.mint()), itemClass: .silent)])
            .contains("NoKeyFileAnywhere("))
        let world = try KeyWorld()
        let key = StoreKey.mint()
        let file = try world.castleFile(key)
        let folders = CF.macFolder(world.library, CF.macA)
        let backup = [
            CatalogEntry(place: .container, folders: folders, name: CF.snapshotName(CF.stamp(1), key)),
            CatalogEntry(place: .container, folders: folders, name: CF.pairName(CF.stamp(1), key), bytes: try file.encoded()),
        ]
        #expect(!Self.lobby(entries: backup).contains("NoKeyFileAnywhere("))
    }

    /// Opened by a quiet road with no key file anywhere — no live file, no
    /// sealed mirror to write back: said (the account road named for a synced
    /// library), nothing rebuilt.
    @Test func openedByAQuietRoadWithNoKeyFileAnywhereIsSaid() throws {
        let key = StoreKey.mint()
        let account = PF.id()
        let record = ProtectionRecord.minting(
            libraryID: PF.id(), mode: .standard, account: account, currentFingerprint: PF.fp(key), at: PF.t0)
        let section = DeviceSection(deviceID: CF.macA, settings: .noChoiceYet)
        let memory = DeviceMemory(libraryID: record.libraryID, currentFingerprint: PF.fp(key), deviceID: CF.macA)
        let facts = ProtectionFacts(
            scope: AWorld.scope, unlocked: UnlockedFacts(record: record, thisMac: section, memory: memory, currentFingerprint: PF.fp(key)),
            custody: [CustodyItemFact(fingerprint: PF.fp(key), itemClass: .silent)], now: AWorld.now)
        let assessed = assess(facts)
        let faults = "\(assessed.faults)"
        #expect(faults.contains("noKeyFileAnywhere") && faults.contains("accountRoad: true"), "\(faults)")
        #expect(!"\(assessed.repairs)".contains("restoreKeyFile"), "a key file rebuilt from nothing")
    }
}
