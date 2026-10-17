//
//  MutationPins.swift
//  VariorumCoreTests — VX-305 U4: THE MUTATION PINS (the phase plan §6: "Each
//  fixed scenario that guards against a known bug runs once more with its
//  guard switched off (`ProtectionGuards`, DEBUG only) and must fail. That is
//  the red-on-old for new code."). Each pin runs its scenario twice on the
//  world: guarded, it keeps every promise and its own sentence; with the guard
//  off, it must fail — a promise broken or its sentence false. The failing
//  assertion each pin records is its `sentence`.
//

import CryptoKit
import Foundation
import Testing

@testable import VariorumCore

#if DEBUG
/// Run `scenario` guarded and unguarded. It returns whether its own sentence
/// held; the world's violations count against it too.
func mutationPin(
    _ sentence: String, off: (inout ProtectionGuards) -> Void,
    sourceLocation: SourceLocation = #_sourceLocation,
    _ scenario: (ProtectionGuards) async throws -> (SWorld, Bool)
) async throws {
    let (guarded, holds) = try await scenario(.all)
    #expect(holds, "guarded: \(sentence) — false\n\(guarded.log)", sourceLocation: sourceLocation)
    expectPromisesKept(guarded, "guarded: \(sentence)", sourceLocation: sourceLocation)
    var guards = ProtectionGuards.all
    off(&guards)
    let (bare, bareHolds) = try await scenario(guards)
    let failed = !bareHolds || !bare.violations.isEmpty
    #expect(failed, "with the guard off, the scenario still passed: \(sentence)", sourceLocation: sourceLocation)
}

@Suite("VX-305 U4 — the mutation pins: each scenario fails with its guard off (DEBUG)")
struct ScenarioMutationPins {
    /// A planted plan, replayed from an earlier act: nothing named by this
    /// Mac's section resumes (VX-313).
    @Test func thePlantedPlan() async throws {
        try await mutationPin("a plan the record doesn't name changes nothing", off: { $0.planNamedBySection = false }) { guards in
            let world = try await scenarioWorld(guards: guards) { try await $0.fresh(on: $0.macA, mode: .castle, gate: .alwaysAsk) }
            await world.done([.launch("macA")])
            await world.step(.tamper("macA", .plantPlan))
            // A GENUINE plan of an earlier act (captured mid-act), written back:
            // it would turn the scheduled export on.
            let library = try #require(world.macA.library)
            let replay = ProtectionPlan(
                libraryID: library.record!.libraryID, deviceID: library.section.deviceID, sequence: 1, act: .deviceSettings,
                steps: [PlanStep(name: "settings")], createdAt: world.clock,
                parameters: ActParameters(settings: DeviceSettings(gateStyle: .alwaysAsk, scheduledExport: true)))
            world.macA.container.files[SPath.plan] = .plan(try replay.sealed(under: library.key))
            world.lock(world.macA)
            await world.step(.launch("macA"))
            return (world, world.macA.library?.section.settings.scheduledExport == false)
        }
    }

    /// No repair ever makes a Touch ID item: a Touch ID choice with no item
    /// behind it records Always ask quietly (§3.10).
    @Test func noRepairMakesATouchIDItem() async throws {
        try await mutationPin("no repair makes a Touch ID item", off: { $0.noRepairMakesTouchID = false; $0.repairNeverMakesTouchIDItem = false }) { guards in
            let world = try await scenarioWorld(guards: guards) { try await $0.fresh(on: $0.macA, mode: .castle, gate: .touchID) }
            await world.done([.launch("macA")])
            await world.step(.tamper("macA", .deleteTouchIDItem))
            let touchItems = world.macA.keychain.local.filter { $0.key.service == ProtectionNames.custodyService && $0.value.touchID }.count
            return (world, touchItems == 0 && world.macA.library?.section.settings.gateStyle == .alwaysAsk)
        }
    }

    /// No re-arm question without an existing item (§3.10).
    @Test func noRearmQuestionWithoutAnItem() async throws {
        try await mutationPin("no re-arm question without an item", off: { $0.noRearmWithoutItem = false }) { guards in
            let world = try await scenarioWorld(guards: guards) { try await $0.fresh(on: $0.macA, mode: .castle, gate: .touchID) }
            await world.done([.launch("macA")])
            world.macA.keychain.local = world.macA.keychain.local.filter { !$0.value.touchID }
            return (world, !world.assessed(world.macA).acts.contains(.touchIDRearmQuestion))
        }
    }

    /// The export-off step: entering Castle turns the scheduled export off
    /// here and on every device that follows.
    @Test func enteringCastleWithTheScheduledExportOn() async throws {
        try await mutationPin("the export turns off at Castle, and at the follow", off: { $0.exportOffAtCastle = false }) { guards in
            let (world, _) = try await syncedWorld(.standard, devices: ["macA", "macB"], guards: guards)
            await world.done([.launch("macA"), .launch("macB"), .setScheduledExport("macA", true), .setScheduledExport("macB", true),
                              .useCastle("macA", .touchID, newWords: false), .settle])
            let off = [world.macA, world.macB].allSatisfy { $0.library?.section.settings.scheduledExport == false }
            return (world, off)
        }
    }

    /// The cross-Mac prune (VX-302): retention never touches another Mac's
    /// copies in a shared iCloud Drive folder (promise 11).
    @Test func theCrossMacPrune() async throws {
        try await mutationPin("retention prunes only this Mac's copies", off: { $0.pruneOwnCopiesOnly = false }) { guards in
            let world = try await scenarioWorld(guards: guards) { w in
                try await w.fresh(on: w.macA)
                try await w.fresh(on: w.macB)
                w.macA.farFolderAccount = SWorld.appleA
                w.macB.farFolderAccount = SWorld.appleA
            }
            await world.done([.launch("macB"), .backup("macB"), .launch("macA")])
            for _ in 0..<20 {
                world.advance(hours: 24)
                await world.done([.backup("macA")])
            }
            let macBsCopies = world.farFolders[SWorld.appleA]!.files.keys.filter { $0.hasSuffix(".sqlite") && !$0.contains("/\(world.macA.library!.section.mac8)/") }
            return (world, !macBsCopies.isEmpty)
        }
    }
    /// "delete on sight, by recorded id only": a Mac in Castle never deletes
    /// another Mac's own Apple key it can see (that Mac's library is in
    /// Standard under a key of its own). The key checked is the one Mac B had
    /// BEFORE — rule 8 re-makes a lost Apple road at Mac B's next open (VX-378
    /// U2), which would otherwise hide the delete.
    @Test func deleteOnSightByRecordedIDOnly() async throws {
        try await mutationPin("another Mac's own Apple key survives", off: { $0.deleteOnSightByIDOnly = false }) { guards in
            let world = try await scenarioWorld(guards: guards) { w in
                try await w.fresh(on: w.macA)
                try await w.fresh(on: w.macB)
            }
            await world.done([.launch("macB"), .settle])
            let macBsKey = world.liveKeyFile(world.macB)?.apple?.keyID
            await world.done([.useCastle("macA", .touchID, newWords: false), .settle, .launch("macA"),
                              .syncICloud("macA"), .syncICloud("macB")])
            return (world, macBsKey.map { world.readableAppleKeys(world.macB)[$0] != nil } == true)
        }
    }
}
#endif
