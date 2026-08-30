//
//  Phase13pControllerTests.swift
//  VariorumTests
//
//  Phase 13p, Batch 2 (commit 4) — the ProtectionController's custody
//  choreography: mode transitions under the custody law (a demanded gate
//  NEVER leaves a silently-releasing item behind — R13p-14's theater
//  prohibition made structural), the escrow dial's acts (R13p-6), the
//  presets (R13p-7), the passphrase set + recovery landing (knot 4), THE
//  RESET DOOR'S RED PIN (R13p-9: the old wrap must stop unwrapping —
//  behavioral-revert-verified, see the run record), the one-secret
//  refusals, the reconcile's escrow consistency + foreign-sidecar
//  set-aside, and the notice state machine.
//
//  Everything runs through the scripted gate — no Keychain, no
//  LocalAuthentication, no prompts, anywhere.
//

import Foundation
import Testing

@testable import Variorum
import VariorumCore

@MainActor
@Suite("13p — the protection controller (custody choreography)")
struct Phase13pControllerTests {
    private func fastKDF() -> PassphraseKDF.Descriptor {
        PassphraseKDF.Descriptor(
            algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
            memoryKiB: 256, iterations: 1, parallelism: 1,
            salt: PassphraseKDF.randomSalt(), outputBytes: 32)
    }

    private struct World {
        let controller: ProtectionController
        let backing: InMemoryStoreKeyGuardBacking
        let dialsBox: ScriptedDialsBox
        let envelopeBox: ScriptedEnvelopeBox
        let stamps: ScriptedStampsBox
        let key: StoreKey
    }

    private func world(
        dials: ProtectionDials = ProtectionDials(),
        key: StoreKey = .mint(),
        auto: Bool = true,
        biometryAvailable: Bool = true,
        biometricSucceeds: Bool = true,
        envelope: StoreKeyEnvelope? = nil,
        isReal: Bool = true
    ) -> World {
        let backing = InMemoryStoreKeyGuardBacking(
            auto: auto ? key : nil,
            biometryAvailable: biometryAvailable,
            biometricSucceeds: biometricSucceeds)
        let dialsBox = ScriptedDialsBox(dials)
        let envelopeBox = ScriptedEnvelopeBox(envelope)
        let stamps = ScriptedStampsBox()
        let gate = StoreLaunchGate.scripted(
            dials: dialsBox, backing: backing, envelope: envelopeBox, stamps: stamps)
        let controller = ProtectionController(configuration: .init(
            scope: "Variorum", storeURL: nil, gate: gate,
            isRealVariant: isReal,
            makeKDF: { PassphraseKDF.Descriptor(
                algorithm: PassphraseKDF.algorithmArgon2id, argon2Version: 0x13,
                memoryKiB: 256, iterations: 1, parallelism: 1,
                salt: PassphraseKDF.randomSalt(), outputBytes: 32) }))
        return World(
            controller: controller, backing: backing, dialsBox: dialsBox,
            envelopeBox: envelopeBox, stamps: stamps, key: key)
    }

    // MARK: - The passphrase + phrase artifacts

    @Test func setPassphraseLandsTheWrapAndStamps() async throws {
        let w = world()
        #expect(!w.controller.hasPassphraseWrap)
        #expect(await w.controller.setPassphrase("sesame") == nil)
        #expect(w.controller.hasPassphraseWrap)
        let envelope = try #require(w.envelopeBox.value)
        #expect(try envelope.unwrapKey(passphrase: "sesame") == w.key)
        #expect(w.stamps.value[ProtectionController.passphraseSetAtStamp] != nil)
    }

    @Test func generateAndLandRecoveryPhraseShowsTwelveWordsThatUnwrap() async throws {
        let w = world()
        let words = try #require(await w.controller.generateAndLandRecoveryPhrase())
        #expect(words.count == 12)
        #expect(w.controller.hasRecoveryWrap)
        let envelope = try #require(w.envelopeBox.value)
        #expect(try envelope.unwrapKey(recoveryWords: words) == w.key)
    }

    // MARK: - The custody law (mode transitions)

    @Test func demandedModesNeedThePassphraseFirst() async {
        let w = world()
        #expect(await w.controller.setMode(.biometric) == .needsPassphrase)
        #expect(await w.controller.setMode(.passphrase) == .needsPassphrase)
        #expect(w.backing.auto != nil, "a refused transition changes nothing")
    }

    @Test func biometricModeMovesCustodyBehindTheGate() async {
        let w = world()
        _ = await w.controller.setPassphrase("sesame")
        #expect(await w.controller.setMode(.biometric) == .changed)
        #expect(w.backing.gated == w.key, "the gated item carries the key")
        #expect(w.backing.auto == nil,
                "the silent item is GONE — a gate whose key still releases silently is theater (R13p-14)")
        #expect(w.dialsBox.value.mode == .biometric, "the dial persisted")
    }

    /// 13p-fix R1-1, THE RED-ON-OLD PIN. On 2026-08-30 a gated write
    /// SUCCEEDED into the data-protection keychain while every read
    /// searched the file-based one, so `saveGated` returned true, the
    /// silent item was deleted on the strength of that alone, and no
    /// Keychain road opened the author's library. The asymmetry is fixed,
    /// but the SHAPE recurs on any identity regression — the access group
    /// is part of an item's identity, so a bundle-id change or a
    /// distribution profile missing the group reproduces it exactly.
    /// The transition must therefore prove the incoming custody READS
    /// BACK before releasing the outgoing one.
    @Test func aGatedWriteThatCannotBeReadBackRefusesInsteadOfDestroyingTheSilentItem() async {
        let w = world()
        _ = await w.controller.setPassphrase("sesame")
        w.backing.gatedWritesAreInvisible = true

        #expect(await w.controller.setMode(.biometric) != .changed,
                "a gated item nothing can find is not a landed gate")
        #expect(w.backing.auto == w.key,
                "the ONLY reachable copy of the key survives the refusal")
        #expect(w.dialsBox.value.mode != .biometric,
                "and the dial never moved — the app cannot claim a gate it does not have")
    }

    @Test func passphraseModeLeavesNoSilentCustodyAtAll() async {
        let w = world()
        _ = await w.controller.setPassphrase("sesame")
        #expect(await w.controller.setMode(.passphrase) == .changed)
        #expect(w.backing.auto == nil)
        #expect(w.backing.gated == nil)
    }

    @Test func backToAutoRestoresTheSilentItemAndDropsTheGate() async {
        let w = world()
        _ = await w.controller.setPassphrase("sesame")
        _ = await w.controller.setMode(.biometric)
        // The demanded era: the resident key stands in for the deleted
        // silent item (as the bootstrap adopts it at unlock).
        w.controller.adoptResident(w.key)
        #expect(await w.controller.setMode(.auto) == .changed)
        #expect(w.backing.auto == w.key)
        #expect(w.backing.gated == nil)
    }

    @Test func biometricModeRefusesWhereTheHardwareIsAbsent() async {
        let w = world(biometryAvailable: false)
        _ = await w.controller.setPassphrase("sesame")
        guard case .refused(let message) = await w.controller.setMode(.biometric) else {
            Issue.record("expected a refusal")
            return
        }
        #expect(message.contains("no Touch ID"))
    }

    // MARK: - The escrow dial (R13p-6)

    @Test func escrowOnWritesTheItemUnderTheStoreID() async throws {
        let w = world()
        #expect(await w.controller.setEscrow(true))
        let storeID = try #require(w.envelopeBox.value?.storeID)
        #expect(w.backing.escrow[storeID] == w.key)
        #expect(await w.controller.setEscrow(false))
        #expect(w.backing.escrow[storeID] == nil)
        #expect(!w.dialsBox.value.escrowOn)
    }

    /// **Ladder R1-m1 — escrow deletion is guarded on OWNERSHIP.** The
    /// escrow-OFF arms (`setEscrow(false)` and the reconcile's
    /// housekeeping) used to call `deleteEscrow` on whatever envelope was
    /// present — so a FOREIGN sidecar (copied from another library; its
    /// fingerprint contradicts our key) had ITS storeID's iCloud item
    /// deleted: somebody's recovery leg, against the same
    /// never-delete-foreign rule that makes `setAsideEnvelope` a move.
    ///
    /// RED ON OLD (behavioral revert executed): with the `belongs(to:)`
    /// guard removed, both survival assertions go red — the foreign item
    /// is taken by the unguarded delete.
    @Test func escrowOffLeavesAForeignSidecarsItemAlone() async throws {
        // A FOREIGN sidecar: wraps minted for ANOTHER library's key.
        let foreignKey = StoreKey.mint()
        var foreign = StoreKeyEnvelope()
        try foreign.setPassphraseWrap(
            key: foreignKey, passphrase: "other", kdf: fastKDF())
        let w = world(envelope: foreign)
        // The other library's escrow item, as iCloud Keychain would hold it.
        w.backing.escrow[foreign.storeID] = foreignKey

        // The dial flips OFF — the foreign item must SURVIVE.
        #expect(await w.controller.setEscrow(false))
        #expect(w.backing.escrow[foreign.storeID] == foreignKey,
                "a foreign sidecar's escrow item survives escrow-off")
        #expect(!w.dialsBox.value.escrowOn, "the dial itself still flips")

        // The reconcile's escrow-OFF housekeeping obeys the same rule.
        await w.controller.reconcile()
        #expect(w.backing.escrow[foreign.storeID] == foreignKey,
                "the launch reconcile never takes a foreign item either")
    }

    // MARK: - Presets (R13p-7)

    @Test func lockedDownPresetNeedsThePassphraseThenSetsEverything() async {
        let w = world()
        #expect(await w.controller.applyPreset(.lockedDown) == .needsPassphrase)
        _ = await w.controller.setPassphrase("sesame")
        _ = await w.controller.setEscrow(true)  // Standard's default, on
        #expect(await w.controller.applyPreset(.lockedDown) == .changed)
        #expect(w.dialsBox.value.mode == .biometric)
        #expect(!w.dialsBox.value.escrowOn)
        #expect(w.backing.escrow.isEmpty, "Locked-down deletes the iCloud copy")
        #expect(w.dialsBox.value.relockOnSleepAndScreenLock)
        #expect(w.dialsBox.value.reminderChecksOn)
        #expect(w.backing.auto == nil, "no silent custody under the gate")
    }

    @Test func standardPresetComesBackWhole() async {
        let w = world()
        _ = await w.controller.setPassphrase("sesame")
        _ = await w.controller.applyPreset(.lockedDown)
        w.controller.adoptResident(w.key)
        #expect(await w.controller.applyPreset(.standard) == .changed)
        #expect(w.dialsBox.value == ProtectionPreset.standard.dials(biometryAvailable: true))
        #expect(w.backing.auto == w.key)
        #expect(w.backing.gated == nil)
    }

    // MARK: - THE RESET DOOR (R13p-9)

    /// THE RED PIN: after a biometric-confirmed reset, the OLD passphrase
    /// must stop unwrapping. Behavioral revert (run record): a reset that
    /// skips the envelope replace leaves this test red on its final two
    /// expectations.
    @Test func resetRewrapsAndTheOldPassphraseStopsUnwrapping() async throws {
        let w = world()
        _ = await w.controller.setPassphrase("the old one")
        #expect(await w.controller.resetPassphrase(to: "the new one") == nil)
        let envelope = try #require(w.envelopeBox.value)
        #expect(try envelope.unwrapKey(passphrase: "the new one") == w.key)
        #expect(throws: StoreKeyEnvelopeError.wrongPassphrase) {
            try envelope.unwrapKey(passphrase: "the old one")
        }
    }

    @Test func resetRefusesWithoutBiometricConfirmation() async throws {
        let w = world(biometricSucceeds: false)
        _ = await w.controller.setPassphrase("the old one")
        let before = w.envelopeBox.value
        let refusal = await w.controller.resetPassphrase(to: "the new one")
        #expect(refusal == "Not confirmed — nothing was changed.")
        #expect(w.envelopeBox.value == before, "a refused reset changes nothing")
    }

    @Test func resetWithoutBiometryNamesTheRecoveryRoad() async {
        let w = world(biometryAvailable: false)
        _ = await w.controller.setPassphrase("the old one")
        let refusal = await w.controller.resetPassphrase(to: "x")
        #expect(refusal?.contains("recovery phrase") == true,
                "no dead ends — the road without Touch ID is named")
    }

    /// ONE SECRET: where a vault is wired, its half runs FIRST and a
    /// vault that cannot re-wrap refuses the WHOLE reset — the store and
    /// the account never diverge.
    @Test func resetRefusesWholeWhenTheVaultHalfFails() async throws {
        let w = world()
        _ = await w.controller.setPassphrase("the old one")
        struct VaultDown: Error {}
        w.controller.rewrapVaultPassphrase = { _ in throw VaultDown() }
        let refusal = await w.controller.resetPassphrase(to: "the new one")
        #expect(refusal?.contains("one passphrase serves both") == true)
        let envelope = try #require(w.envelopeBox.value)
        #expect(try envelope.unwrapKey(passphrase: "the old one") == w.key,
                "the old wrap STANDS when the reset refuses")
    }

    // MARK: - One secret, both directions

    @Test func verifyAgainstStoreAnswersOnlyWhereAWrapExists() async {
        let w = world()
        #expect(await w.controller.verifyPassphraseAgainstStore("anything") == nil)
        _ = await w.controller.setPassphrase("sesame")
        #expect(await w.controller.verifyPassphraseAgainstStore("sesame") == true)
        #expect(await w.controller.verifyPassphraseAgainstStore("wrong") == false)
    }

    @Test func followVaultPassphraseLandsTheStoreWrap() async throws {
        let w = world()
        await w.controller.followVaultPassphrase("suite passphrase")
        let envelope = try #require(w.envelopeBox.value)
        #expect(try envelope.unwrapKey(passphrase: "suite passphrase") == w.key)
    }

    // MARK: - The reconcile

    @Test func reconcileKeepsEscrowConsistentWithTheDial() async throws {
        let w = world(dials: ProtectionDials(mode: .auto, escrowOn: true))
        await w.controller.reconcile()
        let storeID = try #require(w.envelopeBox.value?.storeID)
        #expect(w.backing.escrow[storeID] == w.key, "Standard's default writes the copy")
        #expect(w.stamps.value[ProtectionController.firstUseStamp] != nil)

        // Flip the dial off out-of-band (a crashed flip's leftover item).
        w.dialsBox.value.escrowOn = false
        let again = world(
            dials: w.dialsBox.value, key: w.key,
            envelope: w.envelopeBox.value)
        again.backing.escrow[storeID] = w.key
        await again.controller.reconcile()
        #expect(again.backing.escrow[storeID] == nil, "the leftover item goes")
    }

    @Test func reconcileOnTheDevVariantNeverWritesEscrow() async {
        let w = world(dials: ProtectionDials(mode: .auto, escrowOn: true), isReal: false)
        await w.controller.reconcile()
        #expect(w.backing.escrow.isEmpty,
                "PROVISIONAL: hosted test hosts run the dev store — no automatic iCloud writes")
    }

    @Test func aForeignSidecarIsSetAsideNeverOverwrittenInPlace() async throws {
        // An envelope wrapped for a DIFFERENT library's key sits beside
        // the store (a copied folder). Landing a wrap for THIS key must
        // set it aside (its wraps are someone's recovery legs), never
        // overwrite it silently.
        let foreignKey = StoreKey.mint()
        var foreign = StoreKeyEnvelope()
        try foreign.setPassphraseWrap(key: foreignKey, passphrase: "theirs", kdf: fastKDF())
        let w = world(envelope: foreign)
        #expect(await w.controller.setPassphrase("mine") == nil)
        #expect(w.envelopeBox.setAsideCount == 1, "the foreign sidecar was moved aside")
        let fresh = try #require(w.envelopeBox.value)
        #expect(fresh.storeID != foreign.storeID, "a fresh envelope, fresh identity")
        #expect(try fresh.unwrapKey(passphrase: "mine") == w.key)
    }

    // MARK: - Notices

    @Test func noticesFollowThePolicies() async {
        let w = world()
        let now = Date()
        // Fresh install: first use just stamped ⇒ no nudge yet.
        await w.controller.reconcile(now: now)
        #expect(w.controller.notice == nil)
        // A day later: the nudge (no artifacts yet).
        w.controller.refreshNotices(now: now.addingTimeInterval(2 * 24 * 3600))
        #expect(w.controller.notice == .nudge)
        // Snooze holds it.
        w.controller.snoozeNudge(now: now.addingTimeInterval(2 * 24 * 3600))
        #expect(w.controller.notice == nil)
        // Both artifacts land ⇒ the nudge never returns.
        _ = await w.controller.setPassphrase("sesame")
        _ = await w.controller.generateAndLandRecoveryPhrase()
        w.controller.refreshNotices(now: now.addingTimeInterval(90 * 24 * 3600))
        #expect(w.controller.notice != .nudge)

        // The reminder: dial on + a stale passphrase stamp ⇒ due.
        w.controller.setReminderChecks(true)
        w.controller.refreshNotices(now: now.addingTimeInterval(90 * 24 * 3600))
        #expect(w.controller.notice == .reminderDue)
        w.controller.recordReminderConfirmed(now: now.addingTimeInterval(90 * 24 * 3600))
        #expect(w.controller.notice == nil)
    }

    // MARK: - The reminder's local check (one face — SecretCheck's road)

    @Test func theStoreSecretCheckRunsTheRealUnwrapAndDiscards() async throws {
        let w = world()
        _ = await w.controller.setPassphrase("sesame")
        let words = try #require(await w.controller.generateAndLandRecoveryPhrase())
        let check = w.controller.makeStoreSecretCheck()
        #expect(await check(.passphrase, "sesame") == .correct)
        #expect(await check(.passphrase, "wrong") == .wrong)
        #expect(await check(.recoveryPhrase, words.joined(separator: " ")) == .correct)
        guard case .couldNotCheck = await check(.recoveryPhrase, "only three words") else {
            Issue.record("a malformed phrase is couldNotCheck, never wrong")
            return
        }
        // And through the ONE face: the model runs the local road.
        let model = SecretCheckModel(
            client: nil, storeCheck: check, targetNoun: "this library's key")
        #expect(model.isAvailable)
        await model.check(.passphrase, entry: "sesame")
        #expect(model.result == .correct(.passphrase))
        #expect(model.message(for: .correct(.passphrase)).contains("this library's key"))
    }

    // MARK: - The nudge's direct phrase offer (ladder R2-m1)

    /// **Ladder R2-m1 — the offer consults the vault tie.** Until this
    /// fix both notice bars fresh-minted through
    /// `generateAndLandRecoveryPhrase()` gated only on the STORE's wrap —
    /// so a vault whose twelve words already existed got a SECOND phrase
    /// minted over them (the exact divergence the set-screen's own
    /// `.extendExistingPhrase` routing prevents). Now the shared
    /// `PhraseOffer` rule serves both platforms: vault-with-wrap ⇒ the
    /// EXTEND flow and NO mint; no constraining vault ⇒ the fresh mint,
    /// exactly as before.
    ///
    /// RED ON OLD (behavioral revert executed): with `PhraseOffer.take`
    /// minting unconditionally — the pre-fix faces' behavior — the
    /// vault-with-wrap arm returns `.minted` and the no-mint assertions
    /// go red.
    @Test func thePhraseOfferExtendsAnExistingVaultPhraseInsteadOfMintingASecond() async throws {
        let w = world()
        _ = await w.controller.setPassphrase("sesame")
        #expect(!w.controller.hasRecoveryWrap, "the offer's own render gate")

        // A vault that already carries the twelve words (the tie as
        // `VaultTie.make` would project it for an enrolled account).
        let vaultTie = VaultTie(
            hasRecoveryWrap: true,
            verifyPassphrase: { _ in .match },
            verifyRecoveryWords: { _ in .match })
        let outcome = await PhraseOffer.take(
            controller: w.controller, vaultTie: vaultTie)
        guard case .extend(let model) = outcome else {
            Issue.record("a vault with the twelve words must route to the extend flow")
            return
        }
        #expect(model.phase == .extendExistingPhrase,
                "the sheet opens straight at the extend step")
        #expect(!w.controller.hasRecoveryWrap,
                "NO second phrase was minted over the account's — one secret")
        #expect(w.envelopeBox.value?.recovery == nil,
                "the store envelope carries no fresh wrap either")

        // The extend flow lands the ACCOUNT's words on the store — the
        // set-screen's own routing, reused by the offer.
        let words = try RecoveryPhrase.generate()
        await model.extendPhrase(typed: words.joined(separator: " "))
        #expect(model.lastError == nil)
        let envelope = try #require(w.envelopeBox.value)
        #expect(try envelope.unwrapKey(recoveryWords: words) == w.key)

        // The control: with NO constraining vault, the offer fresh-mints
        // exactly as it always did.
        let free = world()
        _ = await free.controller.setPassphrase("sesame")
        let minted = await PhraseOffer.take(controller: free.controller, vaultTie: nil)
        guard case .minted(let fresh) = minted else {
            Issue.record("no vault ⇒ the fresh mint, unchanged")
            return
        }
        #expect(fresh.count == 12)
        #expect(free.controller.hasRecoveryWrap)
    }
}
