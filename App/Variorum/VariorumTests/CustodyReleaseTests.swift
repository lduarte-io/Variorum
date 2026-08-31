//
//  CustodyReleaseTests.swift
//  VariorumTests
//
//  17h (13p-fix ladder R3-5) — the custody law's DELETE half. The law
//  (StoreKeyGuard's header) states what each at-open mode's Keychain
//  state IS — "plain item present; gated item absent", "NEITHER item
//  exists" — and until this entry every delete's `OSStatus` died at the
//  leaves, so the law was enforced on writes only. The three reachable
//  shapes, each pinned red-on-old here against the `deletesSucceed` knob
//  (the `savesSucceed` pattern):
//
//  · Biometric: `deleteAuto` fails silently ⇒ the dial reads Biometric
//    while the key still releases silently — R13p-14's theater.
//  · Passphrase: BOTH deletes taken on no evidence at all, despite the
//    law being "NEITHER item exists".
//  · Auto: `deleteGated` fails silently ⇒ the gated item lingers behind
//    an Auto dial.
//
//  Post-fix, a refused release backs the whole transition out: the state
//  the dial reports stays the state the Keychain holds, and the surface
//  words it (`ProtectionCopy.outgoingCustodyNotReleased`).
//
//  RED-ON-OLD (behavioral revert, the R3-1 rule — revert the outcome
//  check, never the seam): with `CustodyHandover.perform` ignoring
//  `deleteOutgoing`'s Bool and `setMode`'s `.passphrase` guards reverted
//  to bare calls, every pin below reds — the transitions COMPLETE with
//  the refused item still in place, which is the traced end state.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("17h — a refused Keychain release backs the mode transition out (R3-5)")
struct CustodyReleaseTests {
    private struct World {
        let controller: ProtectionController
        let backing: InMemoryStoreKeyGuardBacking
        let dialsBox: ScriptedDialsBox
        let key: StoreKey
    }

    private func world() -> World {
        let key = StoreKey.mint()
        let backing = InMemoryStoreKeyGuardBacking(
            auto: key, biometryAvailable: true, biometricSucceeds: true)
        let dialsBox = ScriptedDialsBox(ProtectionDials())
        let envelopeBox = ScriptedEnvelopeBox(nil)
        let stamps = ScriptedStampsBox()
        let gate = StoreLaunchGate.scripted(
            dials: dialsBox, backing: backing, envelope: envelopeBox, stamps: stamps)
        let controller = ProtectionController(configuration: .init(
            scope: "Variorum", storeURL: nil, gate: gate,
            isRealVariant: true,
            makeKDF: { PassphraseKDF.Descriptor(
                algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
                memoryKiB: 256, iterations: 1, parallelism: 1,
                salt: PassphraseKDF.randomSalt(), outputBytes: 32) }))
        return World(controller: controller, backing: backing, dialsBox: dialsBox, key: key)
    }

    /// RED-ON-OLD (the first shape): pre-fix `deleteAuto`'s status was
    /// dropped, so this transition COMPLETED — dial Biometric, gated item
    /// landed, and the Auto item still releasing silently, with no word
    /// said.
    @Test func aBiometricTransitionWhoseAutoReleaseFailsRefusesWhole() async {
        let w = world()
        _ = await w.controller.setPassphrase("sesame")
        w.backing.deletesSucceed = false

        let outcome = await w.controller.setMode(.biometric)

        #expect(outcome == .refused(ProtectionCopy.outgoingCustodyNotReleased))
        #expect(w.dialsBox.value.mode == .auto,
                "the dial must not claim a gate whose silent copy the Keychain would not release")
        #expect(w.backing.auto == w.key, "the operative custody is untouched")
    }

    /// RED-ON-OLD (the second shape): the `.passphrase` arm's law is
    /// "NEITHER item exists" and pre-fix it took both deletes on no
    /// evidence — mode landed Passphrase with the Auto item still there,
    /// a silently-readable copy under the strictest setting.
    @Test func aPassphraseTransitionWhoseReleasesFailRefusesWhole() async {
        let w = world()
        _ = await w.controller.setPassphrase("sesame")
        w.backing.deletesSucceed = false

        let outcome = await w.controller.setMode(.passphrase)

        #expect(outcome == .refused(ProtectionCopy.outgoingCustodyNotReleased))
        #expect(w.dialsBox.value.mode == .auto,
                "the state the dial reports stays the state the Keychain holds")
        #expect(w.backing.auto == w.key)
    }

    /// RED-ON-OLD (the third shape): leaving Biometric for Auto, pre-fix
    /// the gated item's failed release was invisible — the mode read Auto
    /// while the gated item lingered, so "a gated item exists" (the
    /// policy-of-record probe) stopped meaning anything.
    @Test func anAutoTransitionWhoseGatedReleaseFailsRefusesWhole() async {
        let w = world()
        _ = await w.controller.setPassphrase("sesame")
        #expect(await w.controller.setMode(.biometric) == .changed)
        w.controller.adoptResident(w.key)
        w.backing.deletesSucceed = false

        let outcome = await w.controller.setMode(.auto)

        #expect(outcome == .refused(ProtectionCopy.outgoingCustodyNotReleased))
        #expect(w.dialsBox.value.mode == .biometric,
                "the gate stands until its item can actually be released")
        #expect(w.backing.gated == w.key)
        // The rolled-back Auto item: the rollback is best-effort under a
        // Keychain whose deletes all fail (documented never-load-bearing
        // in CustodyHandover) — the OPERATIVE custody stays the gated
        // item, and the dial stays honest about it.
    }
}
