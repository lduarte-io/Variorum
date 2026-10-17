//
//  U4CensusPins.swift
//  VariorumCoreTests — VX-378 U4 resumption, piece 4: THE CENSUS CLASSES' MODEL
//  FIXES, each pinned red-first (the stopped U4's census, re-read under her
//  rulings at the U4 stop — the plan's §8 U4 RESUMPTION RECORD, piece 4).
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-378 U4 — the census classes' model fixes (red on the tree before each)")
struct U4CensusPins {
    /// CLASS (G) — rule 20: a crashed Make this my library on a SYNCED Standard
    /// library never stays in flight. Before the swap a resume holds no copy key
    /// and rolls back; the resume used to run the steps before the stage first
    /// and stop at the own Apple key's fresh-vault check (decision 35 — the act
    /// isn't marked synced, so the resume reads no vault), leaving the act in
    /// flight (census seed 21 sequence 471).
    @Test func aCrashedMakeThisMyLibraryOnASyncedLibraryNeverStaysInFlight() async throws {
        for crashAt in 1...12 {
            let (world, _) = try await syncedWorld(.standard, devices: ["macA", "macB"])
            await world.done([.launch("macA"), .backup("macA"), .lock("macA")])
            await world.step(.crash(.makeMine("macA", pick: 0, typing: .current), afterWrites: crashAt))
            await world.step(.launch("macA"))
            #expect(world.macA.library?.section.actInFlight == nil, "crash after write \(crashAt): an act is still in flight")
            expectPromisesKept(world, "crash after write \(crashAt)")
        }
    }

    /// CLASS (E) — rule 11 ("the Apple and on-device keychain items deleted …
    /// so your Standard-era backups' quiet locks die with it"): after a keychain
    /// wipe (this Mac remembers nothing, so it takes a fresh device ID — and a
    /// fresh section listing none of the Apple keys it made before), entering
    /// Castle still retires the Apple key the earlier section lists — the one
    /// an older backup's key file is locked under (census seed 21 sequence 756).
    @Test func enteringCastleAfterAKeychainWipeRetiresTheAppleKeysMadeBeforeIt() async throws {
        let world = try await scenarioWorld { try await $0.fresh(on: $0.macA) }
        await world.done([.createLibrary("macB", passphrase: true), .settle, .backup("macB")])
        let before = try #require(world.liveKeyFile(world.macB)?.apple?.keyID)
        await world.step(.iCloudOff("macB"))
        await world.step(.wipeKeychain("macB"))
        await world.step(.crash(.useCastle("macB", .touchID, newWords: false), afterWrites: 8))
        await world.step(.sendLibrary(from: "macB", to: "macA"))
        await world.step(.launch("macB"))
        #expect(world.macB.library?.section.retiredAppleKeyIDs.contains(before) == true,
                "the Apple key made before the wipe wasn't retired at Use Castle")
        expectPromisesKept(world)
    }

    /// CLASS (D) — rule 27 ("A library whose every key-file copy and every
    /// backup are gone is gone"): a memory item that carries NO copy of the key
    /// file can't open anything, so it no longer silences the lobby's honest
    /// refusal (census seed 21 sequence 789: every key file and the memory item
    /// gone, the next open re-writes a memory item with no copy in it, and a
    /// new Mac carries that item along).
    @Test func aMemoryItemWithNoKeyFileCopyDoesntSilenceRule27() async throws {
        let world = try await scenarioWorld { try await $0.fresh(on: $0.macA, passphrase: false) }
        await world.step(.tamperSequence("macA", [.dropWordsLock, .replayMemory, .deleteKeyFileAndMemory]))
        await world.step(.replaceMac("macA", carriesMemory: true))
        expectPromisesKept(world)
    }

    /// NEW CLASS (J) — rule 20 ("a crash at any point leaves either the old state
    /// or the new one"): a join that crosses postures (a re-key) picks up the
    /// account's sync keys at its first step; rolled back before its swap, it
    /// used to leave them behind — a silent sync-keys item for an account the
    /// library isn't bound to, a third state (here a quiet road to the master on
    /// a Castle library — census seed 22 sequence 460).
    @Test func aRolledBackJoinLeavesNoSyncKeysBehind() async throws {
        let world = SWorld(seed: 22 &* 1_000_003 &+ 460)
        try await StartingState.all[9].build(world)
        for action in [Action.thisMacOnly("macA"), .follow("phone", .words), .useStandard("phone"),
                       .crash(.turnOnSync("macA"), afterWrites: 13), .signOut("macA"), .settle] {
            await world.step(action)
        }
        #expect(world.macA.slot?.record?.account == nil)
        #expect(!world.macA.keychain.local.keys.contains { $0.service == ProtectionNames.syncKeysService },
                "a sync-keys item survived the rolled-back join")
        expectPromisesKept(world)
    }

    /// CLASS (D), its second road — rule 27: before the open, a key file of
    /// ANOTHER library (the other Mac's backups in a shared iCloud Drive folder)
    /// can't open the library this Mac remembers, so it no longer silences the
    /// lobby's honest refusal (census seed 22 sequence 998).
    @Test func anotherLibrarysKeyFilesDontSilenceRule27() async throws {
        let world = SWorld(seed: 22 &* 1_000_003 &+ 998)
        try await StartingState.all[10].build(world)
        await world.step(.tamperSequence("macA", [.deleteKeyFileAndMemory, .plantPlan]))
        await world.step(.backup("macB"))
        await world.step(.replaceMac("macA", carriesMemory: true))
        expectPromisesKept(world)
    }

    /// NEW CLASS (K) — rule 1 ("a sealed copy in this Mac's keychain") and rule
    /// 21's four things: what this Mac remembers carries the CURRENT key's file.
    /// A memory item re-made with no copy in it (its key file was gone at that
    /// open) never took the copy back once the key file returned (a Time Machine
    /// restore): the refresh wasn't owed (census seed 23 sequence 974).
    @Test func theMemorysCopyFollowsTheKeyFileOnceItIsBack() async throws {
        let world = SWorld(seed: 23 &* 1_000_003 &+ 974)
        try await StartingState.all[0].build(world)
        for action in [Action.createLibrary("phone", passphrase: true), .timeMachineSnapshot("phone"),
                       .tamper("phone", .deleteKeyFileAndMemory), .timeMachineRollback("phone"), .settle] {
            await world.step(action)
        }
        let phone = world.device("phone")
        #expect(phone.library?.memory?.keyFileMirror == world.liveKeyFile(phone), "the sealed copy isn't the current key's file")
        expectPromisesKept(world)
    }

    /// NEW CLASS (L) — rule 11 ("Entering Castle … the Apple and on-device
    /// keychain items deleted"): a silent sync-keys item for an account the
    /// library no longer names (a join a Time Machine restore took back — the
    /// keychain isn't restored) holds that account's master, a quiet road to
    /// every key file wrapped under it — a backup's among them; entering Castle
    /// now deletes it (census seed 31 sequence 572).
    @Test func enteringCastleDeletesASilentSyncKeysItemForAnAccountTheLibraryDoesntName() async throws {
        let world = SWorld(seed: 31 &* 1_000_003 &+ 572)
        try await StartingState.all[6].build(world)
        for action in [Action.useStandard("macA"), .settle, .thisMacOnly("phone"), .timeMachineSnapshot("phone"),
                       .turnOnSync("phone"), .timeMachineRollback("phone"), .useCastle("phone", .touchID, newWords: false)] {
            await world.step(action)
        }
        let phone = world.device("phone")
        #expect(phone.slot?.record?.mode == .castle && phone.slot?.record?.account == nil)
        #expect(!phone.keychain.local.contains { $0.key.service == ProtectionNames.syncKeysService && !$0.value.touchID },
                "a silent sync-keys item survived the entry into Castle")
        expectPromisesKept(world)
    }

    /// NEW CLASS (M) — one posture per account, rule 20: a follow OUT of Castle
    /// that crashed, resumed after the account went BACK into Castle elsewhere,
    /// used to finish the follow out — the library Standard under a Castle
    /// account, holding the key Castle rows are written under. A resumed follow
    /// whose account is no longer in the posture it follows into rolls back
    /// before its swap (and the follow now owed runs instead) — census seed 33
    /// sequence 230.
    @Test func aResumedFollowOutRollsBackWhenTheAccountWentBackIntoCastle() async throws {
        let world = SWorld(seed: 33 &* 1_000_003 &+ 230)
        try await StartingState.all[6].build(world)
        for action in [Action.crash(.useStandard("macA"), afterWrites: 18), .crash(.follow("macB", .words), afterWrites: 3),
                       .follow("phone", .words), .crash(.useCastle("phone", .touchID, newWords: false), afterWrites: 11),
                       .launch("macB")] {
            await world.step(action)
        }
        let account = try #require(world.server.accounts.keys.first)
        #expect(world.server.snapshot(account)?.mode == .castle)
        #expect(world.macB.slot?.record?.mode == .castle, "the resumed follow took the library out of Castle under a Castle account")
        expectPromisesKept(world)
    }
}
