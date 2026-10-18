//
//  RouteFinderTests.swift
//  VariorumCoreTests — VX-378 U1: rule 4's one sentence for a copy — "your
//  current passphrase or words; on this Mac, its quiet road if it still holds
//  that key". (The road graph, its witness walks, the secrets' days, the
//  anchor's roads and promise 9 left with VX-378 U1 — rules 4, 6, 12.)
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// A leave from Castle on the device that presses Use Standard, and the
/// copies from both sides of it: the new Standard key's history carries the
/// Castle key (rule 4, rule 12).
struct LeaveWorld {
    let world: KeyWorld
    let castleKey = StoreKey.mint(), standardKey = StoreKey.mint()
    let apple = AppleKeyMaterial.mint()
    let newMaster = SymmetricKey(size: .bits256)
    let castleFile: KeyFile
    let standardFile: KeyFile
    let day1 = CF.stamp(1), leaveDay = CF.stamp(2), day3 = CF.stamp(3)

    init() throws {
        world = try KeyWorld()
        castleFile = try world.castleFile(castleKey)
        let newCopy = try AES.KeyWrap.wrap(newMaster, using: world.w.key)
        standardFile = try castleFile.rekeyed(
            from: castleKey, to: standardKey, kind: .standard,
            locks: NewKeyLocks(passphrase: world.p, words: world.w, master: newMaster, masterWordsCopy: newCopy, apple: apple),
            at: leaveDay)
    }

    func entries(live: KeyFile? = nil) throws -> [CatalogEntry] {
        let folders = CF.macFolder(world.library, CF.macA)
        return [
            CatalogEntry(place: .container, name: ProtectionNames.keyFilename, bytes: try (live ?? standardFile).encoded()),
            CatalogEntry(place: .container, folders: folders, name: CF.snapshotName(day1, castleKey)),
            CatalogEntry(place: .container, folders: folders, name: CF.pairName(day1, castleKey), bytes: try castleFile.encoded()),
            CatalogEntry(place: .container, folders: folders, name: CF.snapshotName(day3, standardKey)),
            CatalogEntry(place: .container, folders: folders, name: CF.pairName(day3, standardKey), bytes: try standardFile.encoded()),
        ]
    }

    func facts(_ catalog: Catalog) throws -> RouteFacts {
        RouteFacts(
            catalog: catalog, custody: [CustodyItemFact(fingerprint: PF.fp(standardKey), itemClass: .silent)],
            readableAppleKeyIDs: [apple.id])
    }

    func copy(_ catalog: Catalog, under key: StoreKey) throws -> CatalogCopy {
        try #require(catalog.copies.first { $0.fingerprint == PF.fp(key) })
    }
}

@Suite("VX-378 U1 — rule 4's one sentence: the current secrets; this Mac's quiet road if it still holds the key")
struct RouteFinderSentenceTests {
    /// After a leave, a copy from Castle opens with the CURRENT passphrase or
    /// words — the live key file's history carries the Castle key — and no
    /// quiet road (the Castle key's Touch ID item went with its key; a quiet
    /// road never reaches through the history). A copy from after the leave:
    /// the current secrets, this Mac's silent item, the Apple road.
    @Test func afterALeaveCastleCopiesOpenWithTheCurrentSecretsOnly() throws {
        let leave = try LeaveWorld()
        let catalog = Catalog.build(try leave.entries())
        let finder = RouteFinder(try leave.facts(catalog))
        #expect(finder.opensWith(copy: try leave.copy(catalog, under: leave.castleKey))
            == OpensWith(currentSecrets: true, quietRoads: []))
        #expect(finder.opensWith(copy: try leave.copy(catalog, under: leave.standardKey))
            == OpensWith(currentSecrets: true, quietRoads: [.thisMac, .appleAccount]))
    }

    /// Rule 6: a passphrase changed after the leave re-locks the current key —
    /// the sentence still says the current secrets open the Castle copies.
    @Test func aPassphraseChangedAfterTheLeaveStillOpensTheCastleCopies() throws {
        let leave = try LeaveWorld()
        let changed = try leave.standardFile.settingPassphrase(try PF.passphraseKey("a new one"), for: leave.standardKey)
        let catalog = Catalog.build(try leave.entries(live: changed))
        let finder = RouteFinder(try leave.facts(catalog))
        #expect(finder.opensWith(copy: try leave.copy(catalog, under: leave.castleKey)).currentSecrets)
        #expect(try changed.historyKey(PF.fp(leave.castleKey),
                                       currentKey: changed.open(.passphrase("a new one"), floor: PF.floor)) == leave.castleKey)
    }

    /// A key the live key file doesn't hold — another library's copy, say —
    /// is no copy the current secrets open (it opens through Look inside with
    /// its own secrets, rule 17); a quiet road still holding it is named.
    @Test func aKeyTheLiveFileDoesNotHoldIsNotTheCurrentSecrets() throws {
        let leave = try LeaveWorld()
        let stranger = StoreKey.mint()
        var facts = try leave.facts(Catalog.build(try leave.entries()))
        facts.custody.append(CustodyItemFact(fingerprint: PF.fp(stranger), itemClass: .touchid))
        let finder = RouteFinder(facts)
        #expect(finder.opensWith(fingerprint: PF.fp(stranger)) == OpensWith(currentSecrets: false, quietRoads: [.touchID]))
    }
}
