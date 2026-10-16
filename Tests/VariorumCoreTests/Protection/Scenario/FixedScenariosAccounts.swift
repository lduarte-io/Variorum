//
//  FixedScenariosAccounts.swift
//  VariorumCoreTests — VX-305 U4: the fixed scenarios about ACCOUNTS — the
//  follow owed before any synced door, the key doors (§6's list; VX-378 U1 kept
//  the ones whose subject the rules keep, on the app's own starting states).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

/// A synced account in `mode`, its first device setting it up and the others
/// joining — each holding its own library — made by the app's own doors.
func syncedWorld(_ mode: ProtectionMode, devices names: [String] = ["macA"], seed: UInt64 = 11,
                 gate: GateStyle = .touchID, guards: ProtectionGuards = .all) async throws -> (SWorld, String) {
    var account = ""
    let world = try await scenarioWorld(seed, guards: guards) { w in
        account = w.rng.uuid()
        try await w.freshAccount(account, mode: mode, devices: names.map(w.device), gate: gate)
    }
    return (world, account)
}

@Suite("VX-305 U4 fixed — accounts: the follow owed first, the key doors")
struct AccountScenarios {
    /// A device whose account moved since it last opened (here: entered Castle
    /// on another Mac) owes the follow first: every synced door refuses at its
    /// door — nothing begun, nothing left in flight — and the follow is owed.
    @Test func aDeviceBehindItsAccountFollowsFirst() async throws {
        let (world, _) = try await syncedWorld(.standard, devices: ["macA", "phone"])
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
        let (world, _) = try await syncedWorld(.castle, devices: ["macA", "macB"])
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

    /// The key doors on an Always-ask device whose session holds no sync keys
    /// (unlocked offline, then back online — pre-13x §3.3's offline unlock):
    /// each derives the account's keys at its door with the secret typed
    /// there, and never leaves an act in flight it can't finish.
    @Test func theKeyDoorsOnAnAlwaysAskDeviceUnlockedOffline() async throws {
        for door in [Action.changePassphrase("macA"), .regenerateWords("macA")] {
            let (world, _) = try await syncedWorld(.castle, devices: ["macA"], gate: .alwaysAsk)
            await world.done([.goOffline("macA"), .launch("macA"), .goOnline("macA"), door])
            #expect(world.macA.library?.section.actInFlight == nil, "\(door) left its act in flight")
            expectPromisesKept(world, "\(door)")
        }
    }
}
