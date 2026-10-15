//
//  FixedScenariosAccounts.swift
//  VariorumCoreTests — VX-305 U4: the fixed scenarios about ACCOUNTS — every
//  leave re-keying, joining by the joining rules, Replace All Keys and its
//  follow, the signed-in/out/other-account walk, This Mac Only (§6's list).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// A synced account in `mode` on Mac A, built from today's formats, and its
/// other devices (each holding its own library, joined to the account).
func syncedWorld(_ mode: ProtectionMode, devices names: [String] = ["macA"], seed: UInt64 = 11,
                 gate: GateStyle = .touchID, guards: ProtectionGuards = .all) throws -> (SWorld, String) {
    var account = ""
    let world = try scenarioWorld(seed, guards: guards) { w in
        account = w.rng.uuid()
        try w.todayAccount(account, mode: mode)
        for name in names { try w.today(on: w.device(name), TodaySpec(mode: mode, gate: gate, account: account)) }
    }
    return (world, account)
}

@Suite("VX-305 U4 fixed — accounts: leaves, joins, Replace All Keys, the signed-out screens")
struct AccountScenarios {
    /// The key doors on an Always-ask device whose session holds no sync keys
    /// (unlocked offline, then back online — pre-13x §3.3's offline unlock):
    /// each derives the account's keys at its door with the secret typed
    /// there, and never leaves an act in flight it can't finish.
    /// A synced Standard library migrated from today's build enters Castle:
    /// today's per-store sync custody item — silent, holding the account's
    /// Standard-era master — goes with the crossing, so no login-password
    /// holder opens a pre-Castle copy's master wrap with it (promise 2).
    @Test func todaysSyncCustodyGoesWhenTheLibraryEntersCastle() async throws {
        let (world, _) = try syncedWorld(.standard, devices: ["macA"])
        await world.done([.launch("macA"), .backup("macA"), .useCastle("macA", .alwaysAsk, newWords: false), .settle])
        let library = try #require(world.macA.slot?.libraryID)
        #expect(world.macA.keychain.local[KName.legacySync(SWorld.scope, library, gated: false)] == nil)
        expectPromisesKept(world)
    }

    /// A device that migrates after its account moved (here: entered Castle on
    /// another Mac) owes the follow first: every synced door refuses at its
    /// door — nothing begun, nothing left in flight — and the follow is owed.
    @Test func aDeviceMigratedAfterItsAccountMovedFollowsFirst() async throws {
        let (world, _) = try syncedWorld(.standard, devices: ["macA", "phone"])
        await world.done([.useCastle("macA", .alwaysAsk, newWords: false), .launch("phone")])
        for door in [Action.replaceAllKeys("phone", newWords: false), .useCastle("phone", .touchID, newWords: false)] {
            let result = await world.step(door)
            #expect(result != .done, "\(door) ran on a device that owes the follow")
            #expect(world.phone.library?.section.actInFlight == nil, "\(door) left its act in flight")
        }
        #expect(world.owedFollow(world.phone) == .intoCastle)
        await world.done([.follow("phone", .passphrase), .settle])
        expectPromisesKept(world)
    }

    /// The key doors on a device that owes a follow (the account moved after
    /// it last followed) refuse at their door — pick up the new keys first —
    /// with nothing begun and nothing left in flight.
    @Test func theKeyDoorsRefuseWhileAFollowIsOwed() async throws {
        let (world, _) = try syncedWorld(.castle, devices: ["macA", "macB"])
        await world.done([.launch("macB"), .useStandard("macA"), .follow("macB", .passphrase), .settle,
                          .useCastle("macA", .touchID, newWords: true)])
        for door in [Action.changePassphrase("macB"), .regenerateWords("macB"), .resetPassphrase("macB", .plainConfirm)] {
            let result = await world.step(door)
            #expect(result != .done, "\(door) ran while a follow is owed")
            #expect(world.macB.library?.section.actInFlight == nil, "\(door) left its act in flight")
        }
        await world.done([.follow("macB", .words), .settle])
        expectPromisesKept(world)
    }

    @Test func theKeyDoorsOnAnAlwaysAskDeviceUnlockedOffline() async throws {
        for door in [Action.changePassphrase("macA"), .regenerateWords("macA")] {
            let (world, _) = try syncedWorld(.castle, devices: ["macA"], gate: .alwaysAsk)
            await world.done([.goOffline("macA"), .launch("macA"), .goOnline("macA"), door])
            #expect(world.macA.library?.section.actInFlight == nil, "\(door) left its act in flight")
            expectPromisesKept(world, "\(door)")
        }
    }

    /// "Replace All Keys on an account still on the old shared key, its follow,
    /// and a new device joining one (its key file under its own key)" — and,
    /// where the account's Apple key can't be read here (decision 30's road
    /// has nothing to keep the master under), the act is refused at its door,
    /// with nothing written and nothing left in flight.
    @Test func replaceAllKeysOnAnAccountStillOnTheOldSharedKey() async throws {
        let (world, _) = try syncedWorld(.standard, devices: ["macA", "phone"])
        await world.done([.launch("macA"), .launch("phone"), .replaceAllKeys("macA", newWords: false)])
        let vault = try #require(world.server.accounts.values.first?.format)
        let shared = try #require(world.oldSharedKey(world.macA))
        #expect(vault.appleKeyID != shared.id, "re-linked first: the new master under the account's own key")
        await world.done([.syncICloud("macA"), .follow("phone", .passphrase), .settle])
        // A new device joining the account: its key file under its own key.
        await world.done([.createLibrary("macB", secrets: true), .signIn("macB", account: world.server.accounts.keys.first!),
                          .turnOnSync("macB"), .settle])
        let joined = try #require(world.liveKeyFile(world.macB)?.apple?.keyID)
        #expect(world.macB.library?.section.appleKeys.contains { $0.id == joined && $0.isOwnLibraryKey } == true)
        expectPromisesKept(world)

        // The account's key unreadable here: refused before any write.
        let (other, _) = try syncedWorld(.standard, devices: ["macA"])
        await other.done([.launch("macA"), .switchAppleID("macA", to: SWorld.appleB)])
        let writes = other.macA.writeCount
        let result = await other.step(.replaceAllKeys("macA", newWords: false))
        #expect(result != .done)
        #expect(other.macA.library?.section.actInFlight == nil, "the refusal left the act in flight")
        #expect(other.macA.container.files[SPath.plan] == nil)
        #expect(other.macA.writeCount == writes, "refused after writing")
        expectPromisesKept(other)
    }
}
