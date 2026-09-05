//
//  CustodyReleaseTests.swift
//  VariorumTests
//
//  17h (13p-fix ladder R3-5) — the custody law's DELETE half. The law
//  (StoreKeyGuard's header) states what each gate's Keychain state IS —
//  "plain item present; gated item absent", "NEITHER item exists" — and
//  until this entry every delete's `OSStatus` died at the leaves, so the
//  law was enforced on writes only. The three reachable shapes, each
//  pinned red-on-old here against the `deletesSucceed` knob (the
//  `savesSucceed` pattern):
//
//  · Biometric: `deleteAuto` fails silently ⇒ a gate whose key still
//    releases silently — R13p-14's theater.
//  · Passphrase: BOTH deletes taken on no evidence at all, despite the
//    law being "NEITHER item exists".
//  · Auto: `deleteGated` fails silently ⇒ the gated item lingers.
//
//  Post-fix, a refused release backs the whole transition out: the state
//  the surface reports stays the state the Keychain holds, and the surface
//  words it (`ProtectionCopy.outgoingCustodyNotReleased`). pre-13x 2a: the
//  transition is `moveCustody(to:)` (the primitive the switches call); the
//  OPERATIVE custody item is the evidence — the derived gate never moved,
//  because no dial or posture is written by a refused move.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("17h — a refused Keychain release backs the custody move out (R3-5)")
struct CustodyReleaseTests {
    private struct World {
        let controller: ProtectionController
        let backing: InMemoryStoreKeyGuardBacking
        let key: StoreKey
    }

    /// A Standard world (the key file's Apple copy under the scripted A;
    /// the silent item holds the key).
    private func world() throws -> World {
        let key = StoreKey.mint()
        let apple = AppleKey.mint()
        var envelope = StoreKeyEnvelope()
        try envelope.appleBox(key: key, under: apple.symmetricKey, appleKeyID: apple.id)
        let backing = InMemoryStoreKeyGuardBacking(
            auto: key, biometryAvailable: true, biometricSucceeds: true)
        let gate = StoreLaunchGate.scripted(
            dials: ScriptedDialsBox(ProtectionDials()), backing: backing,
            envelope: ScriptedEnvelopeBox(envelope), stamps: ScriptedStampsBox(),
            appleKey: InMemoryAppleKeyBacking(key: apple))
        let controller = ProtectionController(configuration: .init(
            scope: "Variorum", storeURL: nil, gate: gate,
            isRealVariant: true,
            makeKDF: { PassphraseKDF.Descriptor(
                algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
                memoryKiB: 256, iterations: 1, parallelism: 1,
                salt: PassphraseKDF.randomSalt(), outputBytes: 32) },
            storeID: { [storeID = envelope.storeID] in storeID },
            syncCustodyLeaves: { _ in
                // An unenrolled library: no sync material anywhere — the
                // sync half of the move is trivially done.
                E2EECustodyLeaves(
                    saveGated: { _ in true }, savePlain: { _ in true },
                    loadPlain: { nil }, gatedExists: { false },
                    deletePlain: { true }, deleteGated: { true })
            },
            syncCustodySession: SyncCustodySession()))
        return World(controller: controller, backing: backing, key: key)
    }

    /// RED-ON-OLD (the first shape): pre-fix `deleteAuto`'s status was
    /// dropped, so this transition COMPLETED — the gated item landed and
    /// the Auto item still releasing silently, with no word said.
    @Test func aBiometricTransitionWhoseAutoReleaseFailsRefusesWhole() async throws {
        let w = try world()
        _ = await w.controller.setPassphrase("sesame")
        w.backing.deletesSucceed = false

        let outcome = await w.controller.moveCustody(to: .biometric)

        #expect(outcome == .refused(ProtectionCopy.outgoingCustodyNotReleased))
        #expect(w.controller.effectiveGate == .auto,
                "the surface must not claim a gate whose silent copy the Keychain would not release")
        #expect(w.backing.auto == w.key, "the operative custody is untouched")
    }

    /// RED-ON-OLD (the second shape): the `.passphrase` arm's law is
    /// "NEITHER item exists" and pre-fix it took both deletes on no
    /// evidence — the Auto item still there, a silently-readable copy
    /// under the strictest setting.
    @Test func aPassphraseTransitionWhoseReleasesFailRefusesWhole() async throws {
        let w = try world()
        _ = await w.controller.setPassphrase("sesame")
        w.backing.deletesSucceed = false

        let outcome = await w.controller.moveCustody(to: .passphrase)

        #expect(outcome == .refused(ProtectionCopy.outgoingCustodyNotReleased))
        #expect(w.controller.effectiveGate == .auto,
                "the state the surface reports stays the state the Keychain holds")
        #expect(w.backing.auto == w.key)
    }

    /// RED-ON-OLD (the third shape): leaving the gate for Auto, pre-fix
    /// the gated item's failed release was invisible — the gated item
    /// lingered, so "a gated item exists" stopped meaning anything.
    @Test func anAutoTransitionWhoseGatedReleaseFailsRefusesWhole() async throws {
        let w = try world()
        _ = await w.controller.setPassphrase("sesame")
        #expect(await w.controller.moveCustody(to: .biometric) == .changed)
        w.backing.deletesSucceed = false

        let outcome = await w.controller.moveCustody(to: .auto)

        #expect(outcome == .refused(ProtectionCopy.outgoingCustodyNotReleased))
        #expect(w.backing.gated == w.key,
                "the gate stands until its item can actually be released")
        // The rolled-back Auto item: the rollback is best-effort under a
        // Keychain whose deletes all fail (documented never-load-bearing
        // in CustodyHandover) — the OPERATIVE custody stays the gated item.
    }
}
