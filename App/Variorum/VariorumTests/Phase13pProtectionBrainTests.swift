//
//  Phase13pProtectionBrainTests.swift
//  VariorumTests
//
//  Phase 13p, Batch 2 (commit 2) — the protection brains: the at-open
//  modes' vocabulary, the presets as PURE dial-setters (R13p-7), the
//  device-local dials storage, the ruled escrow copy pinned VERBATIM
//  (knot 8 — direction ruled; a drift here is a drift from her ruling),
//  the reminder-check cadence (R13p-9) and the Standard nudge's
//  two-offer eligibility (knot 4's amendment), and the guard backing's
//  scripted custody world.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@Suite("13p — modes, presets & dials")
struct ProtectionDialsTests {
    @Test func demandedIsEveryModeButAuto() {
        #expect(!StoreAtOpenMode.auto.isDemanded)
        #expect(StoreAtOpenMode.biometric.isDemanded)
        #expect(StoreAtOpenMode.passphrase.isDemanded)
    }

    @Test func standardPresetSetsTheRuledDials() {
        let dials = ProtectionPreset.standard.dials(biometryAvailable: true)
        #expect(dials == ProtectionDials(
            mode: .auto, escrowOn: true,
            relockOnSleepAndScreenLock: false, relockAfterIdleMinutes: nil,
            reminderChecksOn: false))
    }

    @Test func lockedDownPresetSetsTheRuledDials() {
        let withBiometry = ProtectionPreset.lockedDown.dials(biometryAvailable: true)
        #expect(withBiometry.mode == .biometric, "biometric where the hardware offers it")
        #expect(!withBiometry.escrowOn, "escrow OFF in Locked-down (R13p-6)")
        #expect(withBiometry.relockOnSleepAndScreenLock)
        #expect(withBiometry.reminderChecksOn, "reminder checks ON in Locked-down (R13p-7)")

        let without = ProtectionPreset.lockedDown.dials(biometryAvailable: false)
        #expect(without.mode == .passphrase, "passphrase-every-open where biometry is absent")
    }

    @Test func matchingReadsHandAdjustedDialsAsNoPreset() {
        var dials = ProtectionPreset.standard.dials(biometryAvailable: true)
        #expect(ProtectionPreset.matching(dials, biometryAvailable: true) == .standard)
        dials.escrowOn = false
        #expect(ProtectionPreset.matching(dials, biometryAvailable: true) == nil,
                "hand-adjusted dials match neither preset — the pane highlights none")
    }

    @Test func defaultsRoundTripPerScope() {
        let defaults = UserDefaults(suiteName: "variorum-13p-dials-\(UUID().uuidString)")!
        // The absent-key default IS the Standard preset (escrow ON).
        let fresh = ProtectionDefaults.dials(scope: "Variorum", in: defaults)
        #expect(fresh == ProtectionPreset.standard.dials(biometryAvailable: true))

        var dials = ProtectionDials(
            mode: .passphrase, escrowOn: false,
            relockOnSleepAndScreenLock: true, relockAfterIdleMinutes: 15,
            reminderChecksOn: true)
        ProtectionDefaults.save(dials, scope: "Variorum", in: defaults)
        #expect(ProtectionDefaults.dials(scope: "Variorum", in: defaults) == dials)

        // Scoped: the dev store's dials never gate the real library.
        #expect(ProtectionDefaults.dials(scope: "Variorum-dev", in: defaults)
                == ProtectionPreset.standard.dials(biometryAvailable: true))

        dials.relockAfterIdleMinutes = nil
        ProtectionDefaults.save(dials, scope: "Variorum", in: defaults)
        #expect(ProtectionDefaults.dials(scope: "Variorum", in: defaults)
            .relockAfterIdleMinutes == nil)
    }
}

@Suite("13p — the ruled copy (knot 8 verbatim; the honesty grammar)")
struct ProtectionCopyTests {
    /// Knot 8's ruling, byte-for-byte. 13s may re-voice — by editing this
    /// pin alongside, never by drifting silently.
    @Test func escrowPairIsHerRuledPair() {
        #expect(ProtectionCopy.escrowOn ==
            "A copy of your key is kept in your iCloud Keychain — if you lose this "
            + "Mac and forget your passphrase, signing into iCloud on a new device "
            + "can still unlock your library.")
        #expect(ProtectionCopy.escrowOff ==
            "Your key stays only on your enrolled devices. Lose them, your "
            + "passphrase, and your recovery phrase, and your writing is "
            + "unrecoverable — by anyone.")
    }

    @Test func theNoICloudConsequenceIsStated() {
        // The 2026-08-30 pre-sleep record: without iCloud Keychain the
        // dial has nothing to ride — the copy says so, never pretends.
        #expect(ProtectionCopy.escrowNeedsICloudKeychain.contains("nothing for it to ride"))
    }

    @Test func everyModeSaysWhatItDoesNotProtect() {
        #expect(ProtectionCopy.modeSentence(.auto).contains("anyone who can use this Mac"))
        #expect(ProtectionCopy.modeSentence(.biometric).contains("login password can NOT"))
        #expect(ProtectionCopy.modeSentence(.passphrase).contains("Nothing opens it silently"))
    }

    /// Knot 6's letter: the demanded-mode short chain is stated — her own
    /// example ("forgetting the passphrase without the phrase written
    /// down IS enough") lands in passphrase-mode-with-escrow-off.
    @Test func lossMathShortensHonestlyWithTheMode() {
        let standard = ProtectionCopy.lossMath(.auto, escrowOn: true)
        #expect(standard.contains("ALL of these have to go wrong at once"))
        #expect(standard.contains("iCloud"))

        let strictest = ProtectionCopy.lossMath(.passphrase, escrowOn: false)
        #expect(strictest.contains("IS enough"))
        #expect(!ProtectionCopy.lossMath(.auto, escrowOn: false).contains("iCloud"),
                "escrow off ⇒ no iCloud leg is claimed")
    }

    @Test func envelopeRefusalsSpeakInWords() {
        #expect(ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongPassphrase)
            == "That passphrase doesn't unlock this library.")
        #expect(ProtectionCopy.message(for: RecoveryPhraseError.invalidWordCount(9))
            .contains("exactly 12 words"))
        #expect(ProtectionCopy.message(for: RecoveryPhraseError.unknownWord("varirum"))
            .contains("varirum"))
    }
}

@Suite("13p — reminder & nudge cadence (pure)")
struct ProtectionCadenceTests {
    private let day: TimeInterval = 24 * 60 * 60

    @Test func reminderNeedsAPassphraseAndTheDial() {
        let now = Date()
        #expect(!ReminderCheckPolicy.isDue(
            now: now, enabled: true, passphraseSetAt: nil,
            lastConfirmedAt: nil, lastDismissedAt: nil),
            "no reminder exists before a passphrase does")
        #expect(!ReminderCheckPolicy.isDue(
            now: now, enabled: false, passphraseSetAt: now.addingTimeInterval(-90 * day),
            lastConfirmedAt: nil, lastDismissedAt: nil),
            "the dial gates it")
    }

    @Test func reminderAnchorsOnTheNewestOfSetConfirmDismiss() {
        let now = Date()
        let old = now.addingTimeInterval(-90 * day)
        #expect(ReminderCheckPolicy.isDue(
            now: now, enabled: true, passphraseSetAt: old,
            lastConfirmedAt: nil, lastDismissedAt: nil))
        #expect(!ReminderCheckPolicy.isDue(
            now: now, enabled: true, passphraseSetAt: old,
            lastConfirmedAt: now.addingTimeInterval(-day), lastDismissedAt: nil),
            "a fresh confirmation resets the clock")
        #expect(!ReminderCheckPolicy.isDue(
            now: now, enabled: true, passphraseSetAt: old,
            lastConfirmedAt: old, lastDismissedAt: now.addingTimeInterval(-day)),
            "a dismissal snoozes a full cadence — it never re-nags tomorrow")
    }

    @Test func nudgeWaitsForRealUseAndStopsWhenBothArtifactsExist() {
        let now = Date()
        let yesterday = now.addingTimeInterval(-2 * day)
        #expect(StandardNudgePolicy.isEligible(
            now: now, firstUseAt: yesterday, dismissedForever: false,
            snoozedUntil: nil, hasPassphraseWrap: false, hasRecoveryWrap: false))
        #expect(!StandardNudgePolicy.isEligible(
            now: now, firstUseAt: now, dismissedForever: false,
            snoozedUntil: nil, hasPassphraseWrap: false, hasRecoveryWrap: false),
            "never at first launch — knot 4's letter")
        #expect(!StandardNudgePolicy.isEligible(
            now: now, firstUseAt: yesterday, dismissedForever: false,
            snoozedUntil: nil, hasPassphraseWrap: true, hasRecoveryWrap: true),
            "both artifacts in hand ⇒ nothing to offer")
        #expect(StandardNudgePolicy.isEligible(
            now: now, firstUseAt: yesterday, dismissedForever: false,
            snoozedUntil: nil, hasPassphraseWrap: true, hasRecoveryWrap: false),
            "one missing artifact keeps the offer alive (her two-offer amendment)")
        #expect(!StandardNudgePolicy.isEligible(
            now: now, firstUseAt: yesterday, dismissedForever: true,
            snoozedUntil: nil, hasPassphraseWrap: false, hasRecoveryWrap: false))
        #expect(!StandardNudgePolicy.isEligible(
            now: now, firstUseAt: yesterday, dismissedForever: false,
            snoozedUntil: now.addingTimeInterval(day),
            hasPassphraseWrap: false, hasRecoveryWrap: false))
    }
}

@Suite("13p — the guard's scripted custody world")
struct StoreKeyGuardBackingTests {
    @Test func theCustodyLawOfTheModesIsExpressible() {
        let key = StoreKey.mint()
        let backing = InMemoryStoreKeyGuardBacking(auto: key)
        let guardSeam = StoreKeyGuard.inMemory(backing: backing)

        // Auto: plain present, gated absent.
        #expect(guardSeam.loadAuto() == key)
        #expect(!guardSeam.gatedItemExists())

        // → Biometric: gated lands, plain DELETED (no silent release).
        #expect(guardSeam.saveGated(key))
        guardSeam.deleteAuto()
        #expect(guardSeam.gatedItemExists())
        #expect(guardSeam.loadAuto() == nil, "a gate whose key still releases silently is theater")

        // → Passphrase-every-open: neither item.
        guardSeam.deleteGated()
        #expect(!guardSeam.gatedItemExists())
        #expect(guardSeam.loadAuto() == nil)
    }

    @Test func biometricOutcomesAreScriptedNeverPrompted() async {
        let key = StoreKey.mint()
        let backing = InMemoryStoreKeyGuardBacking(
            gated: key, biometryAvailable: true, biometricSucceeds: false)
        let guardSeam = StoreKeyGuard.inMemory(backing: backing)
        #expect(await guardSeam.unlockGated() == nil, "a failed evaluation yields nil")
        backing.biometricSucceeds = true
        #expect(await guardSeam.unlockGated() == key)
        #expect(await guardSeam.confirmPresence("reset") == true)
    }

    @Test func escrowItemsAreNamedByStoreID() {
        let backing = InMemoryStoreKeyGuardBacking()
        let guardSeam = StoreKeyGuard.inMemory(backing: backing)
        let a = StoreKey.mint()
        let b = StoreKey.mint()
        #expect(guardSeam.saveEscrow(a, "store-a"))
        #expect(guardSeam.saveEscrow(b, "store-b"))
        #expect(guardSeam.loadEscrow("store-a") == a)
        #expect(guardSeam.loadEscrow("store-b") == b)
        guardSeam.deleteEscrow("store-a")
        #expect(guardSeam.loadEscrow("store-a") == nil)
        #expect(guardSeam.loadEscrow("store-b") == b, "per-store items never cross")
    }
}

/// pre-13x 1a — the dials are PER STORE ID with a legacy read-through
/// (the postures design §3.1; pulled in by the absent-store route so a new
/// library is not born gated and a restored old one is not born silent).
/// RED ON OLD: `ProtectionDefaults` had no store-id form (compile).
@Suite("pre-13x 1a — the dials per store id, with the legacy read-through")
struct ProtectionDialsPerStoreTests {
    @Test func aStoreWithNoKeysOfItsOwnReadsTheLegacyScopeDials() {
        let defaults = UserDefaults(suiteName: "variorum-1a-dials-\(UUID().uuidString)")!
        let scope = "probe"
        ProtectionDefaults.save(ProtectionDials(mode: .biometric, relockOnSleepAndScreenLock: true), scope: scope, in: defaults)
        let read = ProtectionDefaults.dials(scope: scope, storeID: "store-a", in: defaults)
        #expect(read.mode == .biometric, "her existing library keeps reading exactly the dials it had")
        #expect(read.relockOnSleepAndScreenLock)
    }

    @Test func aStoresOwnSaveEndsTheReadThroughForThatStoreOnly() {
        let defaults = UserDefaults(suiteName: "variorum-1a-dials-\(UUID().uuidString)")!
        let scope = "probe"
        ProtectionDefaults.save(ProtectionDials(mode: .biometric), scope: scope, in: defaults)
        ProtectionDefaults.save(ProtectionDials(mode: .auto), scope: scope, storeID: "store-new", in: defaults)
        #expect(ProtectionDefaults.dials(scope: scope, storeID: "store-new", in: defaults).mode == .auto,
                "the new library reads its own dials")
        #expect(ProtectionDefaults.dials(scope: scope, storeID: "store-old", in: defaults).mode == .biometric,
                "another store id still reads through to the legacy dials")
        #expect(ProtectionDefaults.dials(scope: scope, in: defaults).mode == .biometric,
                "the legacy keys are never written by a per-store save")
    }
}
