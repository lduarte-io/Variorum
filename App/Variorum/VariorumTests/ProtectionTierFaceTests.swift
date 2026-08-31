//
//  ProtectionTierFaceTests.swift
//  VariorumTests
//
//  pre-13u Act 10 wave 2a — **R-pre13u-4's FACES + memo §6's indicator,
//  pinned at the surface** (the P47 discipline): the exposed tier's
//  hardened copy actually renders on the nudge bar; the unchosen-state
//  indicator renders only in the genuinely-unmade state, speaks tier
//  truth, and NEVER says "encryption off".
//

import AppKit
import Foundation
import SwiftUI
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("The tier faces — the exposed nudge + the unchosen indicator", .serialized)
struct ProtectionTierFaceTests {
    private func makeController(
        dials: ProtectionDials = ProtectionDials(),
        stamps: ScriptedStampsBox = ScriptedStampsBox()
    ) -> (ProtectionController, InMemoryStoreKeyGuardBacking) {
        let backing = InMemoryStoreKeyGuardBacking(
            auto: StoreKey.mint(), biometryAvailable: true, biometricSucceeds: true)
        let gate = StoreLaunchGate.scripted(
            dials: ScriptedDialsBox(dials), backing: backing,
            envelope: ScriptedEnvelopeBox(nil), stamps: stamps)
        let controller = ProtectionController(configuration: .init(
            scope: "Variorum", storeURL: nil, gate: gate, isRealVariant: true,
            makeKDF: { PassphraseKDF.Descriptor(
                algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
                memoryKiB: 256, iterations: 1, parallelism: 1,
                salt: PassphraseKDF.randomSalt(), outputBytes: 32) }))
        return (controller, backing)
    }

    /// The EXPOSED tier's nudge renders the hardened plain-truth copy —
    /// Act 9 shipped the words, this wave the face; before it, the exposed
    /// state read the same gentle sentence as everyone else.
    @Test func theExposedNudgeSpeaksTheHardenedCopy() async {
        let stamps = ScriptedStampsBox()
        stamps.value[ProtectionController.firstUseStamp] =
            Date(timeIntervalSinceNow: -3 * 24 * 60 * 60)
        let (controller, _) = makeController(stamps: stamps)
        // The exposed state: Auto, no secrets, escrow verifiably absent.
        _ = await controller.setEscrow(false)
        controller.refreshNotices()
        #expect(controller.notice == .nudge)
        #expect(controller.legs.tier == .exposed)

        let bar = ProtectionNoticeBar(controller: controller, services: nil)
        await SurfaceComposition.host(bar, size: NSSize(width: 900, height: 120))
        let shown = SurfaceComposition.text(of: bar.body)
        #expect(SurfaceComposition.carries(ProtectionCopy.exposedNudgeHeadline, in: shown),
                "the exposed tier must speak its hardened headline")
        #expect(SurfaceComposition.carries(ProtectionCopy.exposedNudgeBody, in: shown))
        #expect(!SurfaceComposition.carries(ProtectionCopy.nudgeHeadline, in: shown),
                "…never the gentle sentence beside it")
    }

    /// A COVERED nudge (a secret still to offer, but a real leg exists)
    /// keeps the gentle two-offer copy.
    @Test func aCoveredNudgeKeepsTheGentleCopy() async {
        let stamps = ScriptedStampsBox()
        stamps.value[ProtectionController.firstUseStamp] =
            Date(timeIntervalSinceNow: -3 * 24 * 60 * 60)
        let (controller, _) = makeController(stamps: stamps)
        _ = await controller.setPassphrase("correct horse battery")
        controller.refreshNotices()
        guard controller.notice == .nudge else { return }  // both artifacts short-circuit
        let bar = ProtectionNoticeBar(controller: controller, services: nil)
        let shown = SurfaceComposition.text(of: bar.body)
        #expect(SurfaceComposition.carries(ProtectionCopy.nudgeHeadline, in: shown))
        #expect(!SurfaceComposition.carries(ProtectionCopy.exposedNudgeHeadline, in: shown))
    }

    /// The indicator: rendered in the genuinely-unmade state, tier-true,
    /// and NEVER the words "encryption off" (the store is always
    /// encrypted — what is unchosen is the lock and the keys).
    @Test func theIndicatorRendersOnlyWhileTheChoiceIsUnmade() async {
        let (unchosen, _) = makeController()
        _ = await unchosen.setEscrow(false)  // exposed: no legs at all
        let row = ProtectionStatusRow(
            controller: unchosen, tokens: .fallback(for: .light))
        await SurfaceComposition.host(row, size: NSSize(width: 240, height: 80))
        let shown = SurfaceComposition.text(of: row.body)
        // The terminal voice lowercases chrome labels — match caseless.
        #expect(shown.lowercased().contains(
            ProtectionShapes.unchosenIndicatorLabel.lowercased()))
        #expect(SurfaceComposition.carries(ProtectionCopy.exposedNudgeHeadline, in: shown),
                "the exposed detail is the hardened headline")
        #expect(!shown.lowercased().contains("encryption off"),
                "the indicator must never claim the store is unencrypted")

        // A chosen state (a passphrase set) removes the row entirely.
        let (chosen, _) = makeController()
        _ = await chosen.setPassphrase("correct horse battery")
        let goneShown = SurfaceComposition.text(
            of: ProtectionStatusRow(
                controller: chosen, tokens: .fallback(for: .light)).body)
        #expect(!goneShown.lowercased().contains(
            ProtectionShapes.unchosenIndicatorLabel.lowercased()),
                "a made choice retires the indicator")
    }

    /// The label copy itself holds the memo's line: never "encryption
    /// off", always the lock-and-keys truth.
    @Test func theIndicatorCopyNamesTheLockAndKeysNeverEncryptionOff() {
        #expect(!ProtectionShapes.unchosenIndicatorLabel.lowercased().contains("encryption off"))
        #expect(ProtectionShapes.unchosenIndicatorDetail.contains("encrypted either way"))
        #expect(ProtectionShapes.unchosenIndicatorDetail.contains("lock"))
    }
}
