//
//  FixedScenariosCorners.swift
//  VariorumCoreTests — VX-305 U4: the rest of §6's fixed scenarios — the
//  known bugs' sequences (VX-235, VX-107, VX-109) and the follows' corners.
//  Each named after its sentence; every step's promises checked by the runner,
//  then the sentence's own assertion. (VX-378 U1 cut the old shared key's
//  corners — rule 26 — and the anchor's, the stuck leave's, the open rule's and
//  Re-link's, each with its rule in the plan's U1 record.)
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U4 fixed — the known bugs, the corners of the leaves and follows")
struct CornerScenarios {
    // MARK: - The known bugs' sequences

    /// "VX-235's crash after the marker": a crash after each of an act's
    /// first writes — the plan, the new key's custody and key file — then a
    /// relaunch: the act finishes or rolls back, never stuck (prepare-then-
    /// commit), local and synced, on Touch ID and on Always ask.
    @Test func vx235sCrashAfterTheMarker() async throws {
        for synced in [false, true] {
            for gate in [GateStyle.touchID, .alwaysAsk] {
                for n in 1...6 {
                    let world: SWorld
                    if synced { world = try await syncedWorld(.standard, devices: ["macA"], gate: gate).0 } else {
                        world = try await scenarioWorld { try await $0.fresh(on: $0.macA) }
                    }
                    await world.done([.launch("macA")])
                    await world.step(.crash(.useCastle("macA", gate, newWords: false), afterWrites: n))
                    await world.done([.launch("macA"), .settle])
                    #expect(world.macA.library?.section.actInFlight == nil, "synced \(synced) \(gate) after write \(n)")
                    expectPromisesKept(world, "synced \(synced) \(gate) after write \(n)")
                }
            }
        }
    }

    /// "VX-107's double crash": a follow crashed, its resume crashed again,
    /// then a third launch — the plan carries every fact a resume needs
    /// (another device switched, the words rule), and the follow finishes.
    @Test func vx107sDoubleCrash() async throws {
        for typing in [Typing.passphrase, .words] {
            for (first, second) in [(1, 1), (2, 1), (3, 2), (5, 2), (7, 3)] {
                let (world, _) = try await syncedWorld(.standard, devices: ["macA", "phone"], gate: .alwaysAsk)
                await world.done([.launch("macA"), .launch("phone"), .useCastle("macA", .alwaysAsk, newWords: false)])
                await world.step(.crash(.follow("phone", typing), afterWrites: first))
                await world.step(.crash(.launch("phone"), afterWrites: second))
                await world.done([.launch("phone"), .settle])
                #expect(world.phone.slot?.record?.mode == .castle, "\(typing) \(first)/\(second): the follow didn't finish")
                #expect(world.phone.library?.section.actInFlight == nil)
                expectPromisesKept(world, "\(typing) \(first)/\(second)")
            }
        }
    }

    /// "VX-109's concurrent Use Standard": two devices press Use Standard on
    /// one account; the second meets the account already in Standard and
    /// follows instead — the account leaves Castle once.
    @Test func vx109sConcurrentUseStandard() async throws {
        let (world, account) = try await syncedWorld(.castle, devices: ["macA", "macB"])
        await world.done([.launch("macA"), .launch("macB"), .useStandard("macA")])
        let second = await world.step(.useStandard("macB"))
        #expect(second != .done, "the second Use Standard ran on a stale door")
        await world.done([.settle])
        let vault = try #require(world.server.snapshot(account))
        #expect(vault.mode == .standard)
        #expect(world.macB.slot?.record?.mode == .standard)
        expectPromisesKept(world)
    }

    // MARK: - Leaves and follows

    /// "an acting device lost mid-way through a Castle Replace All Keys: the
    /// account never lowered" (Replace All Keys writes no vault — rule 15).
    @Test func anActingDeviceLostMidReplaceAllKeys() async throws {
        for n in [2, 4, 6] {
            let (world, account) = try await syncedWorld(.castle, devices: ["macA", "phone"])
            await world.done([.launch("macA"), .launch("phone")])
            await world.step(.crash(.replaceAllKeys("macA", newWords: false), afterWrites: n))
            world.lock(world.macA)
            world.macA.container = FolderFS()
            world.macA.keychain.local = [:]
            await world.done([.settle])
            let vault = try #require(world.server.snapshot(account))
            #expect(vault.mode == .castle, "after write \(n)")
            #expect(world.phone.slot?.record?.mode == .castle)
            expectPromisesKept(world, "after write \(n)")
        }
    }

    /// "a follow into Standard with the follower's iCloud Keychain off: it
    /// follows on the typed secret" — promises 2, 7 and 13 hold.
    @Test func aFollowIntoStandardWithICloudKeychainOff() async throws {
        let (world, _) = try await syncedWorld(.castle, devices: ["macA", "phone"])
        await world.done([.launch("macA"), .launch("phone"), .iCloudOff("phone"), .useStandard("macA"),
                          .follow("phone", .passphrase)])
        #expect(world.phone.slot?.record?.mode == .standard)
        await world.done([.iCloudOn("phone"), .settle])
        expectPromisesKept(world)
    }

    /// Found by the generator (promise 7): a synced device whose keychain was
    /// wiped (its memory item with it); the account then leaves and re-enters
    /// Castle elsewhere — a new sync key (rule 15) — and the device must still
    /// see the follow owed and converge (the record names the key it follows).
    @Test func aWipedKeychainStillFollowsTheAccountBackIntoCastle() async throws {
        let (world, account) = try await syncedWorld(.castle, devices: ["macA", "phone"])
        await world.done([.launch("phone"), .launch("macA"), .wipeKeychain("macA"), .settle,
                          .useStandard("phone"), .settle, .useCastle("phone", .touchID, newWords: false), .settle])
        let leaf = DeviceLeaves(world: world, device: world.macA)
        let held = [ProtectionNames.CustodyClass.touchid, .silent].lazy
            .compactMap { (try? leaf.readSyncKeys(accountID: account, itemClass: $0)) ?? nil }.first ?? world.macA.sessionMemory[account]
        #expect(held?.rowKeyID == world.server.snapshot(account)?.rowKeyID, "the wiped device never followed the entry")
        expectPromisesKept(world)
    }
    /// Found by the generator (promise 7): the account enters Castle on
    /// another device; this device, freshly relaunched, changes a setting
    /// before it follows — the settings act must not hide the follow owed.
    @Test func aSettingsChangeNeverHidesAFollowOwed() async throws {
        let (world, account) = try await syncedWorld(.standard, devices: ["macA", "phone"], seed: 6000039)
        await world.done([.launch("macA"), .launch("phone"), .useCastle("phone", .touchID, newWords: false),
                          .setGate("macA", .alwaysAsk), .settle])
        let leaf = DeviceLeaves(world: world, device: world.macA)
        let held = [ProtectionNames.CustodyClass.touchid, .silent].lazy
            .compactMap { (try? leaf.readSyncKeys(accountID: account, itemClass: $0)) ?? nil }.first ?? world.macA.sessionMemory[account]
        #expect(held?.rowKeyID == world.server.snapshot(account)?.rowKeyID, "the follow owed was hidden")
        expectPromisesKept(world)
    }
}
