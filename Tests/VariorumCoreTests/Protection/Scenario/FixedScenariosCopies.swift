//
//  FixedScenariosCopies.swift
//  VariorumCoreTests — VX-305 U4: §6's fixed scenarios about COPIES and the
//  CASTLE crossings — each named after its sentence; every step's promises
//  checked by the runner, then the sentence's own assertion.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U4 fixed — copies, Send Library, the crossings")
struct CopyAndCrossingScenarios {
    /// "W-1 / VX-263", re-pointed by her ruling of 2026-10-14 (the legacy cut):
    /// every NEW-system pair keeps opening with its day's secrets across
    /// re-keys — entering Castle takes everything, Replace All Keys grows the
    /// history (every pair here is made by this build, after the migration;
    /// promise 5 walks each).
    @Test func w1VX263() async throws {
        let (world, _) = try await syncedWorld(.standard, devices: ["macA"])
        await world.done([.launch("macA"), .backup("macA"), .useCastle("macA", .touchID, newWords: false), .backup("macA"),
                          .replaceAllKeys("macA", newWords: true), .backup("macA"), .settle])
        expectPromisesKept(world)
    }

    /// "leaving Castle, local and synced, with followers typing the passphrase
    /// and typing the words: every copy from before the leave opening with the
    /// current passphrase or words through the history (rule 4, rule 12)" —
    /// and "a crash at every step … past the rotation's first write, a
    /// resume, never a roll-back". (The anchor and promise 13's pre-leave
    /// reading left with VX-378 U1.)
    @Test func leavingCastleLocalAndSynced() async throws {
        let (world, _) = try await syncedWorld(.castle, devices: ["macA", "macB", "phone"])
        await world.done([.launch("macA"), .launch("macB"), .launch("phone"), .backup("macA"), .backup("macB")])
        let castleKeys = Dictionary(uniqueKeysWithValues: world.devices.map { ($0.name, $0.slot?.fingerprint) })
        await world.done([.useStandard("macA"), .follow("macB", .passphrase), .follow("phone", .words), .settle])
        for device in world.devices {
            #expect(device.slot?.record?.mode == .standard, "\(device.name) didn't follow")
            // Rule 4: the current key's history carries the Castle key.
            let castleKey = try #require(castleKeys[device.name] ?? nil)
            #expect(world.liveKeyFile(device)?.heldFingerprints.contains(castleKey) == true,
                    "\(device.name)'s history dropped its Castle key")
        }
        expectPromisesKept(world)
        for n in [3, 6, 9, 12, 15, 20] {
            let (crashing, _) = try await syncedWorld(.castle, devices: ["macA"], gate: n % 2 == 0 ? .touchID : .alwaysAsk)
            await crashing.done([.launch("macA"), .backup("macA")])
            await crashing.step(.crash(.useStandard("macA"), afterWrites: n))
            await crashing.done([.launch("macA"), .settle])
            expectPromisesKept(crashing, "crash after write \(n)")
        }
    }

    /// "Castle → Standard → Castle: every older key rides the history, and
    /// every older copy opens with nothing more typed".
    @Test func castleStandardCastle() async throws {
        let world = try await scenarioWorld { try await $0.fresh(on: $0.macA, mode: .castle, gate: .touchID) }
        await world.done([.launch("macA"), .backup("macA")])
        let castleKey = try #require(world.macA.slot?.fingerprint)
        await world.done([.useStandard("macA"), .backup("macA")])
        let standardKey = try #require(world.macA.slot?.fingerprint)
        await world.done([.useCastle("macA", .touchID, newWords: false), .settle])
        let live = try #require(world.liveKeyFile(world.macA))
        #expect(live.heldFingerprints.contains(castleKey) && live.heldFingerprints.contains(standardKey),
                "the history dropped a key")
        expectPromisesKept(world)
    }

    /// "after a leave, a changed passphrase, new words and a reset forgotten
    /// passphrase — on this device and on another device of the account".
    @Test func afterALeaveTheKeyDoors() async throws {
        let (world, _) = try await syncedWorld(.castle, devices: ["macA", "macB"])
        await world.done([.launch("macA"), .launch("macB"), .backup("macA"), .useStandard("macA"), .follow("macB", .passphrase),
                          .changePassphrase("macA"), .regenerateWords("macB"), .resetPassphrase("macA", .plainConfirm), .settle])
        // Rule 6: the doors re-lock; the Done says nothing about an anchor.
        #expect(world.macA.lastOutcome?.done == [])
        expectPromisesKept(world)
    }

    /// "a Standard library that leaves its account, is backed up, then enters
    /// Castle: no copy from before the leave opens through anything
    /// Apple-reachable, every own key retired".
    @Test func aStandardLibraryLeavesItsAccountThenEntersCastle() async throws {
        let (world, _) = try await syncedWorld(.standard, devices: ["macA"])
        // Signed out: the account it left keeps its vault on the old shared key
        // (§3.5 point 4 would stop Use Castle at its door while she reads it).
        await world.done([.launch("macA"), .backup("macA"), .stopSyncingHere("macA", forgotPassphrase: true), .backup("macA"),
                          .signOut("macA"), .useCastle("macA", .touchID, newWords: false), .settle])
        let section = try #require(world.macA.library?.section)
        #expect(section.ownLibraryAppleKeyIDsToRetire.isEmpty)
        expectPromisesKept(world)
    }

    /// "a library leaving its account by each of the four acts, in Castle and
    /// in Standard … it re-keys, and nothing written after opens through the
    /// account".
    @Test func aLibraryLeavingItsAccountByEachAct() async throws {
        for mode in ProtectionMode.allCases {
            for leave in [Action.thisMacOnly("macA", nil), .stopSyncingHere("macA", forgotPassphrase: mode == .standard),
                          .deleteAccountHere("macA")] {
                let (world, _) = try await syncedWorld(mode, devices: ["macA"])
                await world.done([.launch("macA")])
                let before = try #require(world.macA.slot?.fingerprint)
                await world.done([leave, .settle])
                #expect(world.macA.slot?.fingerprint != before && world.macA.slot?.record?.account == nil, "\(mode) \(leave)")
                expectPromisesKept(world, "\(mode) \(leave)")
            }
        }
    }

    /// "This-Mac-Only Castle from an account in Standard: the account's key
    /// untouched".
    @Test func thisMacOnlyCastleFromAStandardAccount() async throws {
        let (world, account) = try await syncedWorld(.standard, devices: ["macA", "phone"])
        await world.done([.launch("macA"), .launch("phone"), .signOut("macA"), .thisMacOnly("macA", .castle), .settle])
        let vault = try #require(world.server.snapshot(account))
        #expect(world.macA.slot?.record?.mode == .castle && vault.mode.settled == .standard)
        #expect(vault.format.appleKeyID.map { world.readableAppleKeys(world.phone)[$0] != nil } == true)
        expectPromisesKept(world)
    }
}
