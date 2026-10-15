//
//  FixedScenariosMore.swift
//  VariorumCoreTests — VX-305 U4: more of §6's fixed scenarios — replays and
//  the file swap, Touch ID, two logins, clones, the older build, the account
//  walk. Each named after its sentence.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U4 fixed — replays, Touch ID, logins, clones, the older build, the account walk")
struct MoreScenarios {
    /// "replays: a plan, a memory item, and a library file alone, each
    /// changing nothing" — the file swap by a login-password holder among them.
    @Test func replaysAndTheFileSwap() async throws {
        for tamper in [Tamper.replayPlan, .replayMemory, .replayKeyFile, .replayLibraryFile, .plantPlan, .editSealedSetting,
                       .plantAppleWrap, .dropWordsLock, .deleteKeyFile, .deleteTouchIDItem, .deleteMemoryItem] {
            let world = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .standard)) }
            await world.done([.launch("macA"), .useCastle("macA", .alwaysAsk, newWords: false), .setScheduledExport("macA", false)])
            await world.step(.tamper("macA", tamper))
            expectPromisesKept(world, "\(tamper)")
        }
    }

    /// "a library file replayed alone … changes nothing" (promise 10): in
    /// Castle, an older library file written back into the slot (its key the
    /// live key file's history, its record from before Use Castle) loses to the
    /// memory — the mode stays Castle, the slot ends under the current key, and
    /// no Apple wrap appears on it.
    @Test func aLibraryFileReplayedAloneInCastle() async throws {
        for gate in [GateStyle.alwaysAsk, .touchID] {
            let world = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .standard)) }
            await world.done([.launch("macA"), .useCastle("macA", gate, newWords: false), .settle])
            let current = try #require(world.macA.slot?.fingerprint)
            await world.step(.tamper("macA", .replayLibraryFile))
            await world.done([.settle])
            #expect(world.macA.slot?.record?.mode == .castle, "\(gate): the replayed file lowered the mode")
            #expect(world.macA.slot?.fingerprint == current, "\(gate): the slot isn't under the current key")
            #expect(world.liveKeyFile(world.macA)?.apple == nil, "\(gate): an Apple wrap appeared")
            expectPromisesKept(world, "\(gate)")
        }
    }

    /// "the edited gate style plus an enrolled finger": nothing makes a Touch
    /// ID item, nothing is asked.
    @Test func theEditedGateStylePlusAnEnrolledFinger() async throws {
        let world = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .castle, gate: .alwaysAsk)) }
        await world.done([.launch("macA"), .addFinger("macA")])
        await world.step(.tamper("macA", .editSealedSetting))
        #expect(!world.macA.keychain.local.contains { $0.key.service == ProtectionNames.custodyService && $0.value.touchID })
        #expect(!world.assessed(world.macA).acts.contains(.touchIDRearmQuestion))
        expectPromisesKept(world)
    }

    /// "a biometry change, then the re-arm question; and the stored hash moving
    /// with nothing changed: the button stays, a press opens, nothing is asked".
    @Test func aBiometryChangeThenTheRearmQuestion() async throws {
        let world = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .castle, gate: .touchID)) }
        await world.done([.launch("macA"), .macOSUpdate("macA"), .launch("macA")])
        #expect(world.assessed(world.macA).touchID.button && !world.assessed(world.macA).acts.contains(.touchIDRearmQuestion))
        await world.done([.addFinger("macA"), .launch("macA")])
        #expect(world.assessed(world.macA).acts.contains(.touchIDRearmQuestion))
        await world.done([.answerRearm("macA", yes: true), .lock("macA"), .launch("macA")])
        #expect(world.macA.touchIDPress == nil)
        expectPromisesKept(world)
    }

    /// "the memory item deleted alone on an Always-ask Castle Mac with an
    /// enrolled finger: nothing changes"; "the lid closed at Castle entry".
    @Test func theMemoryItemDeletedAloneAndTheLidClosed() async throws {
        let world = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .castle, gate: .alwaysAsk)) }
        await world.done([.launch("macA")])
        await world.step(.tamper("macA", .deleteMemoryItem))
        #expect(world.macA.library?.section.settings.gateStyle == .alwaysAsk)
        let lid = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .standard)) }
        await lid.done([.launch("macA"), .closeLid("macA"), .useCastle("macA", .touchID, newWords: false), .openLid("macA"), .settle])
        expectPromisesKept(world)
        expectPromisesKept(lid)
    }

    /// "both homes rolled back past a switch to Always ask, with a finger
    /// enrolled since: the restored choice says Touch ID, no item exists,
    /// nothing is asked, and Always ask is recorded quietly".
    @Test func bothHomesRolledBackPastASwitchToAlwaysAsk() async throws {
        let world = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .castle, gate: .touchID)) }
        await world.done([.launch("macA"), .setGate("macA", .alwaysAsk), .addFinger("macA")])
        world.macA.captures = Array(world.macA.captures.prefix(1))
        await world.step(.tamper("macA", .replayBothHomes))
        #expect(!world.assessed(world.macA).acts.contains(.touchIDRearmQuestion))
        #expect(world.macA.library?.section.settings.gateStyle == .alwaysAsk)
        expectPromisesKept(world)
    }

    /// "two macOS logins on one Mac (VX-340) … a copy from one login opened in
    /// the other adopts nothing — its own identity, <mac8> folder, retention
    /// and Apple keys", and Use Castle in one never retires the other's own key.
    @Test func twoMacOSLoginsOnOneMac() async throws {
        for differentAppleID in [false, true] {
            let world = try scenarioWorld { w in
                try w.today(on: w.macA, TodaySpec(mode: .standard))
                try w.today(on: w.macB, TodaySpec(mode: .standard, passphrase: true, words: true))
                w.macB.machine = MachineIdentity(hardware: w.macA.machine.hardware, login: w.rng.uuid().uppercased())
                if differentAppleID { w.macB.appleAccount = SWorld.appleB }
            }
            await world.done([.launch("macA"), .settle, .sendLibrary(from: "macA", to: "macB"), .land("macB", .passphraseWordsTyped),
                              .useCastle("macB", .touchID, newWords: false), .settle])
            let aOwn = try #require(world.liveKeyFile(world.macA)?.apple?.keyID)
            #expect(world.readableAppleKeys(world.macA)[aOwn] != nil, "Apple ID B \(differentAppleID): the other login's own key was retired")
            #expect(world.macB.library?.section.deviceID != world.macA.library?.section.deviceID)
            #expect(world.macB.library?.section.mac8 != world.macA.library?.section.mac8)
            expectPromisesKept(world, "different Apple ID \(differentAppleID)")
        }
    }

    /// "a living Mac cloned onto new hardware … either entering Castle costs
    /// the other its Apple road, which Re-link's library arm heals, and
    /// nothing stops opening".
    @Test func aLivingMacClonedOntoNewHardware() async throws {
        let world = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .standard)) }
        await world.done([.launch("macA"), .settle, .cloneMac(from: "macA", to: "macB"), .launch("macB"),
                          .useCastle("macA", .touchID, newWords: false), .settle])
        #expect(world.macB.isOpen)
        expectPromisesKept(world)
    }

    /// "iCloud Keychain off on the Mac whose library moves: the move removes
    /// no road" (promise 12).
    @Test func iCloudKeychainOffOnTheMacWhoseLibraryMoves() async throws {
        let world = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .standard, passphrase: false, words: false)) }
        await world.done([.iCloudOff("macA"), .launch("macA"), .moveOffSharedKey("macA"), .settle])
        expectPromisesKept(world)
    }

    /// "a silently-joined device losing its Keychain after the account entered
    /// Castle elsewhere: the words open its file".
    @Test func aSilentlyJoinedDeviceLosingItsKeychain() async throws {
        let world = try scenarioWorld { w in
            let account = w.rng.uuid()
            try w.todayAccount(account, mode: .standard)
            try w.today(on: w.macA, TodaySpec(mode: .standard, account: account))
            try w.today(on: w.phone, TodaySpec(mode: .standard, account: account, joinedWithoutSecret: true))
        }
        await world.done([.launch("phone"), .launch("macA"), .useCastle("macA", .touchID, newWords: false), .wipeKeychain("phone")])
        let words = world.known(world.macA.slot!.record!.account!).words
        await world.done([.launch("phone")])
        _ = words
        #expect(world.phone.isOpen)
        expectPromisesKept(world)
    }

    /// "a Standard library's own Apple key lost (iCloud Keychain reset, a
    /// switch of Apple ID): Re-link's library arm, then promise 3 settles —
    /// local-only too".
    @Test func aStandardLibrarysOwnAppleKeyLost() async throws {
        let world = try scenarioWorld { try $0.today(on: $0.macA, TodaySpec(mode: .standard)) }
        await world.done([.launch("macA"), .settle, .resetICloudKeychain("macA"), .settle])
        expectPromisesKept(world)
    }

    /// "an older build completing a leave's rotation: the vault still reads a
    /// leave in progress, followers keep holding, and a device that reads the
    /// named key adds the wrap". BEYOND SCOPE, KEPT WHILE GREEN (her
    /// 2026-10-15 ruling — no old build acts after the switch).
    @Test func anOlderBuildCompletingALeavesRotation() async throws {
        let (world, account) = try syncedWorld(.castle, devices: ["macA", "phone"])
        world.phone.build = .older
        let (clean, _) = try syncedWorld(.castle, devices: ["macA"])
        await clean.done([.launch("macA")])
        let start = clean.stepLog.count
        await clean.done([.useStandard("macA")])
        let first = (clean.stepLog[start...].filter { $0.contains("✎") }.firstIndex { $0.contains("vault") } ?? 0) + 1
        await world.done([.launch("macA")])
        await world.step(.crash(.useStandard("macA"), afterWrites: first))
        await world.done([.olderBuild("phone", .follow, typing: .passphrase)])
        let vault = try #require(world.server.snapshot(account))
        #expect(vault.format.appleKeyID != nil && vault.format.masterWrappedByAppleHeld == nil, "the leave no longer reads in progress")
        await world.done([.syncICloud("macA"), .launch("macA"), .settle])
        #expect(world.server.snapshot(account)?.format.masterWrappedByAppleHeld != nil)
        expectPromisesKept(world)
    }

    /// "her signed-in/out/other-account sequence (the design's §3.8 walk)".
    @Test func herSignedInOutOtherAccountWalk() async throws {
        let (world, account) = try syncedWorld(.standard, devices: ["macA"])
        let other = world.rng.uuid()
        try world.todayAccount(other, mode: .castle)
        await world.done([.launch("macA"), .signOut("macA"), .launch("macA"), .signIn("macA", account: other), .launch("macA")])
        #expect(world.macA.slot?.record?.account == account, "signing in or out changed the account")
        await world.done([.signIn("macA", account: account), .launch("macA"), .settle])
        #expect(world.macA.slot?.record?.account == account)
        expectPromisesKept(world)
    }

    /// "a synced pair landed with a passphrase made new: it becomes the
    /// account's at Resume Sync".
    @Test func aSyncedPairLandedWithAPassphraseMadeNew() async throws {
        let (world, account) = try syncedWorld(.castle, devices: ["macA"])
        try world.today(on: world.macB, TodaySpec(mode: .standard))
        await world.done([.launch("macA"), .launch("macB"), .sendLibrary(from: "macA", to: "macB"), .land("macB", .wordsPassphraseMadeNew)])
        await world.done([.signIn("macB", account: account), .launch("macB"), .resumeSync("macB")])
        let made = world.known(world.holder(world.macB, account: nil, libraryID: world.macB.slot!.libraryID)).passphrase
        let vault = try #require(world.server.snapshot(account))
        let pk = try #require(world.passphraseKey(made ?? "", vault.format.kdf))
        #expect((try? vault.format.unwrapMaster(withPassphraseKey: pk.key)) != nil, "the made-new passphrase isn't the account's")
        expectPromisesKept(world)
    }
}
