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
    /// "VX-209's way back (local and synced)": a Standard-era copy opened
    /// into a Castle library takes the Castle mode — opening never lowers it.
    @Test func vx209sWayBack() async throws {
        for synced in [false, true] {
            let world: SWorld
            if synced { world = try syncedWorld(.standard, devices: ["macA"]).0 } else {
                world = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .standard)) }
            }
            await world.done([.launch("macA"), .backup("macA"), .useCastle("macA", .touchID, newWords: false), .restoreBackup("macA", newest: 2)])
            #expect(world.macA.slot?.record?.mode == .castle, "synced \(synced): the copy lowered the mode")
            expectPromisesKept(world, "synced \(synced)")
        }
    }

    /// "W-1 / VX-263", re-pointed by her ruling of 2026-10-14 (the legacy cut):
    /// every NEW-system pair keeps opening with its day's secrets across
    /// re-keys — entering Castle takes everything, Replace All Keys grows the
    /// history (every pair here is made by this build, after the migration;
    /// promise 5 walks each).
    @Test func w1VX263() async throws {
        let (world, _) = try syncedWorld(.standard, devices: ["macA"])
        await world.done([.launch("macA"), .backup("macA"), .useCastle("macA", .touchID, newWords: false), .backup("macA"),
                          .replaceAllKeys("macA", newWords: true), .backup("macA"), .settle])
        expectPromisesKept(world)
    }

    /// "an act in flight when a backup is taken: the copy carries no act, and
    /// opening it elsewhere runs nothing of it".
    @Test func anActInFlightWhenABackupIsTaken() async throws {
        let world = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .castle, gate: .touchID)) }
        await world.done([.launch("macA"), .useStandard("macA"), .restoreBackup("macA", newest: 0)])
        #expect(world.macA.library?.section.actInFlight == nil)
        expectPromisesKept(world)
    }

    /// "Send Library after this change: a Castle pair landing with its
    /// passphrase alone and with its words alone (the other typed, and made
    /// new); a Standard pair through a readable Apple key with nothing typed;
    /// a new key and an empty history on the receiver; the receiver leaving
    /// Castle later exposing nothing of the sender's".
    @Test func sendLibraryAfterThisChange() async throws {
        for typing in LandTyping.allCases {
            let mode: ProtectionMode = typing == .nothing ? .standard : .castle
            let world = try scenarioWorld { w in
                try w.today(on: w.macA, TodaySpec(mode: mode, gate: .touchID))
                try w.today(on: w.macB, TodaySpec(mode: .standard))
            }
            await world.done([.launch("macA"), .launch("macB"), .settle, .sendLibrary(from: "macA", to: "macB"), .land("macB", typing)])
            let sender = try #require(world.macA.slot), receiver = try #require(world.macB.slot)
            #expect(receiver.libraryID == sender.libraryID && receiver.fingerprint != sender.fingerprint, "\(typing): no fresh key")
            #expect(world.liveKeyFile(world.macB)?.history.isEmpty == true && world.macB.slot?.record?.mode == mode, "\(typing)")
            if mode == .castle { await world.done([.useStandard("macB"), .settle]) }
            expectPromisesKept(world, "\(typing)")
        }
    }

    /// "leaving Castle, local and synced, with followers typing the passphrase
    /// and typing the words: the anchor written first; every copy from before
    /// the leave opening with the passphrase or the words and through nothing
    /// Apple-reachable" — and "a crash at every step … past the rotation's
    /// first write, a resume, never a roll-back".
    @Test func leavingCastleLocalAndSynced() async throws {
        let (world, _) = try syncedWorld(.castle, devices: ["macA", "macB", "phone"])
        await world.done([.launch("macA"), .launch("macB"), .launch("phone"), .backup("macA"), .backup("macB"),
                          .useStandard("macA"), .follow("macB", .passphrase), .follow("phone", .words), .settle])
        for device in world.devices { #expect(device.slot?.record?.mode == .standard, "\(device.name) didn't follow") }
        expectPromisesKept(world)
        for n in [3, 6, 9, 12, 15, 20] {
            let (crashing, _) = try syncedWorld(.castle, devices: ["macA"], gate: n % 2 == 0 ? .touchID : .alwaysAsk)
            await crashing.done([.launch("macA"), .backup("macA")])
            await crashing.step(.crash(.useStandard("macA"), afterWrites: n))
            await crashing.done([.launch("macA"), .settle])
            expectPromisesKept(crashing, "crash after write \(n)")
        }
    }

    /// "Castle → Standard → Castle: the anchor folds back, and every older
    /// copy opens with nothing more typed".
    @Test func castleStandardCastle() async throws {
        let world = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .castle, gate: .touchID)) }
        await world.done([.launch("macA"), .backup("macA"), .useStandard("macA"), .backup("macA"),
                          .useCastle("macA", .touchID, newWords: false), .settle])
        let live = try #require(world.liveKeyFile(world.macA))
        #expect(live.anchor == nil && live.keptAnchors.isEmpty, "the anchor didn't fold back")
        expectPromisesKept(world)
    }

    /// "after a leave, a changed passphrase, new words and a reset forgotten
    /// passphrase — on this device and on another device of the account".
    @Test func afterALeaveTheKeyDoors() async throws {
        let (world, _) = try syncedWorld(.castle, devices: ["macA", "macB"])
        await world.done([.launch("macA"), .launch("macB"), .backup("macA"), .useStandard("macA"), .follow("macB", .passphrase),
                          .changePassphrase("macA"), .regenerateWords("macB"), .resetPassphrase("macA", .plainConfirm), .settle])
        let done = world.macA.lastOutcome?.done ?? []
        #expect(done.contains { if case .anchor = $0 { return true } else { return false } }, "the reset didn't say its sentence")
        expectPromisesKept(world)
    }

    /// "a Standard library that leaves its account, is backed up, then enters
    /// Castle: no copy from before the leave opens through anything
    /// Apple-reachable, every own key retired".
    @Test func aStandardLibraryLeavesItsAccountThenEntersCastle() async throws {
        let (world, _) = try syncedWorld(.standard, devices: ["macA"])
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
                let (world, _) = try syncedWorld(mode, devices: ["macA"])
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
        let (world, account) = try syncedWorld(.standard, devices: ["macA", "phone"])
        await world.done([.launch("macA"), .launch("phone"), .signOut("macA"), .thisMacOnly("macA", .castle), .settle])
        let vault = try #require(world.server.snapshot(account))
        #expect(world.macA.slot?.record?.mode == .castle && vault.mode.settled == .standard)
        #expect(vault.format.appleKeyID.map { world.readableAppleKeys(world.phone)[$0] != nil || world.oldSharedKey(world.phone)?.id == $0 } == true)
        expectPromisesKept(world)
    }

    /// "a 13p escrow item: folded, then removed in Castle".
    @Test func a13pEscrowItem() async throws {
        let world = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .castle, gate: .touchID, escrow: true)) }
        await world.done([.launch("macA"), .settle])
        #expect(world.macA.keychain.names(service: LegacyItems.escrowService).isEmpty)
        expectPromisesKept(world)
    }

    // "a copy made before this change, of another library, Standard with no
    // passphrase: it lands in Standard, never Castle" — SUPERSEDED by her ruling
    // of 2026-10-14 (the legacy cut, the plan's §8): a pre-rebuild copy opening
    // is no longer a guarantee. (The raise — "a Castle copy from another Mac
    // into a Standard library" — is CornerScenarios.aCastleCopyFromAnotherMacRaises,
    // on new-system pairs.)

    /// "today's Standard library with an old marker — an old build's crashed
    /// act, migrated after today's finish runner is gone: never happened, so
    /// cleared … migrated from disk".
    @Test func anOldBuildsCrashedActMigrated() async throws {
        let world = try scenarioWorld { w in
            try w.today(on: w.macA, TodaySpec(mode: .standard, marker: LegacyRotationMarker(
                step: .rekeyLibrary, entersCastle: true, oldKeyFingerprint: nil, newKeyFingerprint: nil, newCorpusKeyID: nil,
                startedAt: "2026-09-01T00:00:00Z", follow: nil)))
        }
        await world.done([.launch("macA"), .settle])
        #expect(world.macA.slot?.legacyMarker == nil)
        expectPromisesKept(world)
    }
}
