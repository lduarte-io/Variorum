//
//  U2PinsRule8Scenarios.swift
//  VariorumCoreTests — VX-378 U2 piece G: RULE 8 (`notes/CastleRules.md`: "If
//  it stops working — a changed Apple ID, a keychain reset — the next open uses
//  whatever quiet road still works and quietly makes a fresh Apple road; it asks
//  for your passphrase or words only when no quiet road remains") and the entry's
//  half of rule 11 piece E found ("the Apple … keychain items deleted" — even
//  after a lost memory item took the device ID that listed them). On the
//  scenario world, whose launch runs `assess`'s repairs; written against the
//  actions both trees share, so the red-on-old run is honest.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-378 U2 — rule 8: the quiet roads re-made at the next open")
struct U2PinsRule8Scenarios {
    /// Stage 5 of the lifecycle: a changed Apple ID — the on-device road opens
    /// the library and a fresh Apple road is made, quietly.
    @Test func aChangedAppleIDIsReMadeQuietlyAtTheNextOpen() async throws {
        let world = try await scenarioWorld { w in try await w.fresh(on: w.macA) }
        await world.done([.launch("macA"), .lock("macA"), .switchAppleID("macA", to: SWorld.appleB), .launch("macA")])
        let wrap = try #require(world.liveKeyFile(world.macA)?.apple)
        #expect(world.readableAppleKeys(world.macA)[wrap.keyID] != nil, "the Apple road was not re-made")
        expectPromisesKept(world)
    }

    /// Both quiet roads gone (a keychain reset under a changed Apple ID): the
    /// open types a secret, then both roads are made again.
    @Test func bothQuietRoadsAreReMadeAfterTheOneTypedOpen() async throws {
        let world = try await scenarioWorld { w in try await w.fresh(on: w.macA) }
        await world.done([.launch("macA"), .lock("macA"), .wipeKeychain("macA"),
                          .switchAppleID("macA", to: SWorld.appleB), .launch("macA")])
        let key = try #require(world.macA.library?.key)
        let silent = KName.custody(SWorld.scope, PF.fp(key), .silent)
        #expect(world.macA.keychain.local[silent] != nil, "the on-device road was not re-made")
        let wrap = try #require(world.liveKeyFile(world.macA)?.apple)
        #expect(world.readableAppleKeys(world.macA)[wrap.keyID] != nil, "the Apple road was not re-made")
        expectPromisesKept(world)
    }

    /// Rule 11, found in piece E: a device whose keychain was wiped (a NEW device
    /// ID, a section listing none of its old Apple keys) then follows the account
    /// into Castle — the Apple key its live key file names is deleted with the
    /// rest, so its Standard-era backup's quiet lock dies (promise 2).
    @Test func anEntryRetiresTheAppleKeyTheLiveKeyFileNamesAfterAWipe() async throws {
        let (world, _) = try await syncedWorld(.standard, devices: ["macA", "phone"])
        await world.done([.launch("phone"), .launch("macA"), .backup("macA"), .wipeKeychain("macA"), .settle,
                          .useCastle("phone", .touchID, newWords: false), .settle])
        #expect(world.macA.slot?.record?.mode == .castle)
        expectPromisesKept(world)
    }
}

@Suite("VX-378 U2 — rule 8 in assess: the re-make repairs, and the lobby asking only when no quiet road remains")
struct U2Rule8AssessTests {
    @Test func aLostAppleRoadOwesAFreshOneAndALostOnDeviceItemIsReMade() throws {
        var world = try AWorld(.standard)
        world.appleKeys.readable = []
        world.custody = []
        let assessed = try world.assessed()
        #expect(assessed.repairs.contains(.remakeAppleRoad) && assessed.repairs.contains(.remakeOnDeviceItem))
        #expect(assessed.faults.contains(.appleRoadLost(keyFileID: AWorld.liveKeyFileID)))
    }

    /// Decision 35 holds for the re-make: synced, no Apple road is made without
    /// a fresh read of the account's vault.
    @Test func noAppleRoadIsMadeForASyncedLibraryWithoutAFreshVaultRead() throws {
        let x = PF.id()
        var world = try AWorld(.standard, account: x)
        world.session = .signedIn(accountID: x, email: nil)
        world.appleKeys.readable = []
        #expect(!(try world.assessed().repairs.contains(.remakeAppleRoad)))
        world.vault = AWorld.vault(x, .standard)
        #expect(try world.assessed().repairs.contains(.remakeAppleRoad))
    }

    @Test func theLobbyAsksASecretAtOnceOnlyWhenNoQuietRoadRemains() throws {
        var world = try AWorld(.standard)
        world.unlocked = false
        #expect(!(try world.assessed().lobby.asksASecretAtOnce))
        world.custody = []
        #expect(!(try world.assessed().lobby.asksASecretAtOnce), "the Apple road still works")
        world.appleKeys.readable = []
        #expect(try world.assessed().lobby.asksASecretAtOnce)
    }

    /// In Castle nothing is re-made (rule 9: no quiet road through Apple; a
    /// Touch ID item only at a press).
    @Test func nothingIsReMadeInCastle() throws {
        var world = try AWorld(.castle)
        world.custody = []
        let repairs = try world.assessed().repairs
        #expect(!repairs.contains(.remakeAppleRoad) && !repairs.contains(.remakeOnDeviceItem))
    }
}
