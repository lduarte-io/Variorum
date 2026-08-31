//
//  EscrowPostureCouplingTests.swift
//  VariorumTests
//
//  pre-13u Act 10 wave 2a — **THE ESCROW/POSTURE COUPLING, pinned**
//  (memo §4 / R-pre13u-7(b), the ninth wave's ONE behavior change; her
//  ruling: demanded modes do not offer the iCloud spare; escrow's default
//  follows the posture). Red-on-old, verified by behavioral revert: on
//  the pre-coupling code the spare key SURVIVES a switch into a demanded
//  mode (the item stays in the backing, the legs still list it), which is
//  exactly the same-machine bypass the ruling removes.
//

import Foundation
import SwiftUI
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("The escrow/posture coupling (ninth wave — memo §4)", .serialized)
struct EscrowPostureCouplingTests {
    private struct World {
        let controller: ProtectionController
        let backing: InMemoryStoreKeyGuardBacking
        let envelope: ScriptedEnvelopeBox
        let dialsBox: ScriptedDialsBox

        var escrowItem: StoreKey? {
            guard let storeID = envelope.value?.storeID else { return nil }
            return backing.escrow[storeID]
        }
    }

    private func makeWorld(dials: ProtectionDials = ProtectionDials()) -> World {
        let backing = InMemoryStoreKeyGuardBacking(
            auto: StoreKey.mint(), biometryAvailable: true, biometricSucceeds: true)
        let dialsBox = ScriptedDialsBox(dials)
        let envelope = ScriptedEnvelopeBox(nil)
        let gate = StoreLaunchGate.scripted(
            dials: dialsBox, backing: backing,
            envelope: envelope, stamps: ScriptedStampsBox())
        let controller = ProtectionController(configuration: .init(
            scope: "Variorum", storeURL: nil, gate: gate, isRealVariant: true,
            makeKDF: { PassphraseKDF.Descriptor(
                algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
                memoryKiB: 256, iterations: 1, parallelism: 1,
                salt: PassphraseKDF.randomSalt(), outputBytes: 32) }))
        return World(
            controller: controller, backing: backing,
            envelope: envelope, dialsBox: dialsBox)
    }

    /// The ONE rule, brain-level: the stored dial is an Auto-posture
    /// choice; the effective value follows the posture.
    @Test func theEffectiveValueFollowsThePosture() {
        var dials = ProtectionDials(mode: .auto, escrowOn: true)
        #expect(dials.effectiveEscrowOn)
        dials.mode = .biometric
        #expect(!dials.effectiveEscrowOn)
        dials.mode = .passphrase
        #expect(!dials.effectiveEscrowOn)
        dials.mode = .auto
        #expect(dials.effectiveEscrowOn, "the stored choice survives the stint")
    }

    /// The legs never list a spare the posture removed — the memo's
    /// almost-true trap, closed at the one brain both platforms read.
    @Test func theLegsNeverListTheICloudCopyUnderDemandedModes() {
        for escrow in [true, false] {
            for mode in [StoreAtOpenMode.biometric, .passphrase] {
                let legs = ProtectionCopy.lossLegs(mode, escrowOn: escrow)
                #expect(!legs.contains { $0.contains("iCloud") },
                        "a demanded mode listed the spare (\(mode), dial \(escrow))")
            }
        }
        #expect(ProtectionCopy.lossLegs(.auto, escrowOn: true)
            .contains { $0.contains("iCloud") },
            "…while Auto with the dial on still lists it")
    }

    /// **THE ACT-TIME HALF, red-on-old:** entering a demanded mode removes
    /// our own iCloud item at the transition itself — and the stored dial
    /// keeps her Auto choice.
    @Test func enteringADemandedModeRemovesTheICloudSpare() async {
        let world = makeWorld()
        _ = await world.controller.setEscrow(true)
        #expect(world.escrowItem != nil, "precondition: the spare landed under Auto")
        _ = await world.controller.setPassphrase("correct horse battery")
        #expect(await world.controller.setMode(.biometric) == .changed)

        #expect(world.escrowItem == nil,
                "the spare key must not survive into a demanded posture")
        #expect(world.controller.dials.escrowOn,
                "…but the stored Auto choice is kept, never clobbered")
        #expect(!world.controller.dials.effectiveEscrowOn)
        #expect(world.controller.escrowVerifiedLanded == false,
                "no leg may be claimed from an item the posture removed")
    }

    /// The return trip: back on Auto the stored choice re-lands, verified
    /// by read-back (never the write's own word).
    @Test func returningToAutoRestoresTheStoredChoice() async {
        let world = makeWorld()
        _ = await world.controller.setEscrow(true)
        _ = await world.controller.setPassphrase("correct horse battery")
        _ = await world.controller.setMode(.biometric)
        #expect(world.escrowItem == nil)

        #expect(await world.controller.setMode(.auto) == .changed)
        #expect(world.escrowItem != nil, "the spare returns as she left it")
        #expect(world.controller.escrowVerifiedLanded == true)
    }

    /// **THE LAUNCH HALF:** a ready launch under a demanded posture
    /// enforces the coupling too (a stale item from an older build, or a
    /// crash between the dial write and the item delete, is healed here).
    @Test func theLaunchReconcileEnforcesThePosture() async {
        let world = makeWorld()
        // Land the spare + wrap under Auto, then flip the STORED dials to
        // biometric behind the controller's back (the older-build shape:
        // dial + item disagree with the posture).
        _ = await world.controller.setEscrow(true)
        _ = await world.controller.setPassphrase("correct horse battery")
        var stored = world.dialsBox.value
        stored.mode = .biometric
        world.dialsBox.value = stored
        #expect(world.escrowItem != nil)

        // The ready launch: the store unlocked (resident adopted), then
        // the reconcile — production's exact order.
        world.controller.adoptResident(world.backing.auto!)
        await world.controller.reconcile()

        #expect(world.escrowItem == nil,
                "the launch reconcile must remove a spare the posture forbids")
        #expect(world.controller.escrowVerifiedLanded == false)
        #expect(world.controller.dials.escrowOn, "the stored choice is kept")
    }

    /// The dial door itself acts on the EFFECTIVE value: an ON write under
    /// a demanded posture stores the choice and lands nothing (presets and
    /// future callers route through here; the pane never offers it there).
    @Test func setEscrowUnderADemandedPostureStoresTheChoiceAndLandsNothing() async {
        let world = makeWorld()
        _ = await world.controller.setPassphrase("correct horse battery")
        _ = await world.controller.setMode(.biometric)
        #expect(await world.controller.setEscrow(true))
        #expect(world.controller.dials.escrowOn)
        #expect(world.escrowItem == nil, "an ON write under a demanded posture lands no item")
    }

    /// **THE FACE (P47's discipline):** under a demanded posture the pane
    /// offers no escrow dial — her why-sentence stands where it would be,
    /// and the kept-choice note rides when a stored choice exists.
    @Test func thePaneSpeaksTheWhySentenceInsteadOfOfferingTheDial() async {
        let world = makeWorld(dials: ProtectionDials(mode: .biometric, escrowOn: true))
        let pane = ProtectionPane(controller: world.controller, services: nil)
        await SurfaceComposition.host(pane, size: NSSize(width: 620, height: 800))
        let shown = SurfaceComposition.text(of: pane.body)
        #expect(SurfaceComposition.carries(
            ProtectionCopy.escrowNotOfferedUnderDemanded, in: shown),
                "the demanded pane must say WHY the spare isn't offered")
        #expect(SurfaceComposition.carries(
            ProtectionCopy.escrowChoiceKeptNote, in: shown),
                "…and that the stored Auto choice is kept")
        #expect(!shown.contains("Keep a spare key in iCloud Keychain"),
                "…and must not offer the dial itself")

        // The complement — under Auto the dial is offered and the
        // why-sentence is absent (the untaken branch is absent from the
        // composition, which is what makes this a real pin).
        let auto = makeWorld()
        let autoPane = ProtectionPane(controller: auto.controller, services: nil)
        await SurfaceComposition.host(autoPane, size: NSSize(width: 620, height: 800))
        let autoShown = SurfaceComposition.text(of: autoPane.body)
        #expect(autoShown.contains("Keep a spare key in iCloud Keychain"))
        #expect(!SurfaceComposition.carries(
            ProtectionCopy.escrowNotOfferedUnderDemanded, in: autoShown))
    }
}
