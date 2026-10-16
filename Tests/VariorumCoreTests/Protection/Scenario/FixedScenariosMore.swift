//
//  FixedScenariosMore.swift
//  VariorumCoreTests — VX-305 U4: more of §6's fixed scenarios — replays and
//  the file swap, Touch ID, the account walk. Each named after its sentence.
//  (VX-378 U1 cut two logins and clones — rule 23 — the older build — rule 26 —
//  the memory winning over a replayed file — rule 21 — and Re-link — rule 8.)
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-305 U4 fixed — replays, Touch ID, the account walk")
struct MoreScenarios {
    /// "replays: a plan, a memory item, and a library file alone, each
    /// changing nothing" — the file swap by a login-password holder among them.
    @Test func replaysAndTheFileSwap() async throws {
        for tamper in [Tamper.replayPlan, .replayMemory, .replayKeyFile, .replayLibraryFile, .plantPlan, .editSealedSetting,
                       .plantAppleWrap, .dropWordsLock, .deleteKeyFile, .deleteTouchIDItem, .deleteMemoryItem] {
            let world = try await scenarioWorld { try await $0.fresh(on: $0.macA) }
            await world.done([.launch("macA"), .useCastle("macA", .alwaysAsk, newWords: false), .setScheduledExport("macA", false)])
            await world.step(.tamper("macA", tamper))
            expectPromisesKept(world, "\(tamper)")
        }
    }

    /// "the edited gate style plus an enrolled finger": nothing makes a Touch
    /// ID item, nothing is asked.
    @Test func theEditedGateStylePlusAnEnrolledFinger() async throws {
        let world = try await scenarioWorld { try await $0.fresh(on: $0.macA, mode: .castle, gate: .alwaysAsk) }
        await world.done([.launch("macA"), .addFinger("macA")])
        await world.step(.tamper("macA", .editSealedSetting))
        #expect(!world.macA.keychain.local.contains { $0.key.service == ProtectionNames.custodyService && $0.value.touchID })
        #expect(!world.assessed(world.macA).acts.contains(.touchIDRearmQuestion))
        expectPromisesKept(world)
    }

    /// "a biometry change, then the re-arm question; and the stored hash moving
    /// with nothing changed: the button stays, a press opens, nothing is asked".
    @Test func aBiometryChangeThenTheRearmQuestion() async throws {
        let world = try await scenarioWorld { try await $0.fresh(on: $0.macA, mode: .castle, gate: .touchID) }
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
        let world = try await scenarioWorld { try await $0.fresh(on: $0.macA, mode: .castle, gate: .alwaysAsk) }
        await world.done([.launch("macA")])
        await world.step(.tamper("macA", .deleteMemoryItem))
        #expect(world.macA.library?.section.settings.gateStyle == .alwaysAsk)
        let lid = try await scenarioWorld { try await $0.fresh(on: $0.macA) }
        await lid.done([.launch("macA"), .closeLid("macA"), .useCastle("macA", .touchID, newWords: false), .openLid("macA"), .settle])
        expectPromisesKept(world)
        expectPromisesKept(lid)
    }

    /// "her signed-in/out/other-account sequence (the design's §3.8 walk)".
    @Test func herSignedInOutOtherAccountWalk() async throws {
        let (world, account) = try await syncedWorld(.standard, devices: ["macA"])
        let other = world.rng.uuid()
        try await world.freshAccount(other, mode: .castle, devices: [world.macB])
        await world.done([.launch("macA"), .signOut("macA"), .launch("macA"), .signIn("macA", account: other), .launch("macA")])
        #expect(world.macA.slot?.record?.account == account, "signing in or out changed the account")
        await world.done([.signIn("macA", account: account), .launch("macA"), .settle])
        #expect(world.macA.slot?.record?.account == account)
        expectPromisesKept(world)
    }
}
