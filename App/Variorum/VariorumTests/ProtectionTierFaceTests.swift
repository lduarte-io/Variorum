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
        // The exposed state (copy §5): Standard, no secrets, no Apple key
        // verifiably landed (no reconcile has run — nil counts for nothing).
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

    /// pre-13x ladder round 2, F3 (NIT-N8) — RED ON OLD: a device WAITING
    /// for the account's iCloud key under propagation lag (F2's MAJOR-3
    /// (a): no master, nothing minted) read `appleKeyVerified == false` on
    /// the pane's legs and was spoken to as EXPOSED — told to write its
    /// words down as if its key were unguarded. Copy §2d's waiting
    /// sentence renders in the hardened nudge's place, on the notice bar
    /// and the unchosen indicator; the exposed headline never.
    @Test func aWaitingDeviceHearsTheWaitingSentenceNotTheExposedNudge() async throws {
        let stamps = ScriptedStampsBox()
        stamps.value[ProtectionController.firstUseStamp] =
            Date(timeIntervalSinceNow: -3 * 24 * 60 * 60)
        let key = StoreKey.mint()
        var envelope = StoreKeyEnvelope()
        try envelope.setAppleWrappedCopy(key: key, under: AppleKey.mint().symmetricKey, appleKeyID: "a0-this-files")
        let backing = InMemoryStoreKeyGuardBacking(auto: key, biometryAvailable: true, biometricSucceeds: true)
        let appleKeys = InMemoryAppleKeyBacking(key: nil)  // the account's A₁ has not arrived here
        let gate = StoreLaunchGate.scripted(
            dials: ScriptedDialsBox(ProtectionDials()), backing: backing,
            envelope: ScriptedEnvelopeBox(envelope), stamps: stamps, appleKey: appleKeys)
        let syncLeaves = RecordingSyncLeaves(
            plain: SyncCustodyRecord(deviceID: "device-1", material: nil), gated: nil)
        let controller = ProtectionController(configuration: .init(
            scope: "Variorum", storeURL: nil, gate: gate, isRealVariant: true,
            makeKDF: { PassphraseKDF.Descriptor(
                algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
                memoryKiB: 256, iterations: 1, parallelism: 1,
                salt: PassphraseKDF.randomSalt(), outputBytes: 32) },
            storeID: { [storeID = envelope.storeID] in storeID },
            syncCustodyLeaves: { _ in syncLeaves.leaves },
            syncCustodySession: SyncCustodySession()))
        controller.adoptResident(nil)
        controller.isSignedIn = { true }
        controller.foreignOwner = { _ in false }
        controller.readVaultPosture = { VaultPostureReading(hasAppleHeldCopy: true, appleKeyID: "a1-the-accounts") }
        controller.landEnrollment = { _, _ in false }
        await controller.reconcile()
        #expect(controller.appleKeyWaiting && controller.legs.tier == .waiting, "\(controller.legs.tier)")
        controller.refreshNotices()
        #expect(controller.notice == .nudge)

        let bar = ProtectionNoticeBar(controller: controller, services: nil)
        await SurfaceComposition.host(bar, size: NSSize(width: 900, height: 120))
        let shown = SurfaceComposition.text(of: bar.body)
        #expect(SurfaceComposition.carries(ProtectionCopy.waitingTitle, in: shown), "the waiting sentence renders on the bar")
        #expect(SurfaceComposition.carries(ProtectionCopy.waitingBody, in: shown))
        #expect(!SurfaceComposition.carries(ProtectionCopy.exposedNudgeHeadline, in: shown),
                "never the exposed headline for a device merely waiting")

        let row = ProtectionStatusRow(controller: controller, tokens: .fallback(for: .light))
        await SurfaceComposition.host(row, size: NSSize(width: 240, height: 80))
        let rowShown = SurfaceComposition.text(of: row.body)
        #expect(SurfaceComposition.carries(ProtectionCopy.waitingTitle, in: rowShown), "the indicator too")
        #expect(!SurfaceComposition.carries(ProtectionCopy.exposedNudgeHeadline, in: rowShown))

        // RUN A batch A2, row 13 (17l item 7): the THIRD face NIT-N8 named —
        // the PANE's own checklist sentence — verified to still stand after
        // 13u4 S1 split Settings into nine panes and gave Protection its
        // own. The pane MOUNTS here (so the restructure's composition is
        // exercised), and what it says is read two ways, because a `Form`'s
        // reflected tree does not carry the string a computed `Text` holds:
        // the SENTENCE it renders, and the fact that the line still renders
        // the one brain rather than a re-derivation that could drift.
        let pane = ProtectionPane(controller: controller, services: nil)
        await SurfaceComposition.host(pane, size: NSSize(width: 720, height: 552))
        #expect(controller.legs.tier == .waiting, "the pane mounted on a waiting device")
        #expect(ProtectionCopy.nudgeSentence(for: controller.legs.tier)
                == ProtectionCopy.waitingTitle + " " + ProtectionCopy.waitingBody,
                "what the pane's checklist line resolves to")
        #expect(ProtectionCopy.nudgeSentence(for: controller.legs.tier)
                != ProtectionCopy.nudgeSentence(for: .exposed),
                "never the exposed nudge for a device merely waiting")
        let paneSource = try String(
            contentsOf: URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent()      // VariorumTests
                .deletingLastPathComponent()      // App/Variorum
                .appendingPathComponent("Variorum/Features/Settings/ProtectionPane.swift"),
            encoding: .utf8)
        #expect(paneSource.contains("Text(ProtectionCopy.nudgeSentence(for: controller.legs.tier))"),
                "the pane still renders the one nudge brain — the face NIT-N8 built")
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
        let (unchosen, _) = makeController()  // exposed: no legs at all
        let row = ProtectionStatusRow(
            controller: unchosen, tokens: .fallback(for: .light))
        await SurfaceComposition.host(row, size: NSSize(width: 240, height: 80))
        let shown = SurfaceComposition.text(of: row.body)
        // The terminal voice lowercases chrome labels — match caseless.
        // pre-13x 5a (design §8): the unchosen indicator reads "Standard".
        #expect(shown.lowercased().contains(
            ProtectionCopy.postureName(.standard).lowercased()))
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
            ProtectionCopy.postureName(.standard).lowercased()),
                "a made choice retires the indicator")
    }

    /// The indicator's words are the posture's own (copy §1): "Standard"
    /// and the current-state line — never "encryption off".
    @Test func theIndicatorCopyIsThePosturesOwnNeverEncryptionOff() async {
        let (unchosen, _) = makeController()
        let row = ProtectionStatusRow(controller: unchosen, tokens: .fallback(for: .light))
        await SurfaceComposition.host(row, size: NSSize(width: 240, height: 80))
        let shown = SurfaceComposition.text(of: row.body)
        #expect(!shown.lowercased().contains("encryption off"))
        #expect(!ProtectionCopy.currentStateLine(.standard).lowercased().contains("encryption off"))
        #expect(ProtectionCopy.currentStateLine(.standard) == "You're in Standard. Your Apple account holds a key.")
    }
}
