//
//  PostureFollowModel.swift
//  Variorum (shared: Mac + Mobile — THE FOLLOW's brain; each platform's
//  notice bar renders its phases)
//
//  pre-13x batch 2c — THE FOLLOW (the postures design §7): a device that
//  opens and learns, at ready, that the account changed on another device.
//  The controller's reconcile makes the verdict (`FollowNotice`); this model
//  walks the notice to the act — *Enter Passphrase…* / *Use Twelve Words…*
//  → `PostureSwitchRunner.follow` (M′ from the vault by the typed secret,
//  custody replaced, the walk finished if rows remain, the library
//  re-keyed, custody behind Touch ID / Face ID or nowhere, the fresh pair,
//  sync resumed) → Done; *Later* → the un-followed state (the persistent
//  banner; every key door says *pick up your new keys first*; sign out and
//  delete still work; the notice returns at every open). The Always-ask
//  variant (decision 10's exception) walks the same doors to the vault
//  road's pickup: the new word unwraps the vault's master, the sync keys
//  are held for the session, and the local passphrase copy is re-wrapped
//  under the vault's descriptor (2a's `reconcilePassphraseWrap`).
//
//  Held on the controller (`activeFollow`) exactly like the ceremony, so it
//  survives the re-key's reopen. Copy §5 renders verbatim.
//

import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class PostureFollowModel: Identifiable {
    enum Phase: Equatable {
        /// The notice (copy §5) with its doors.
        case notice
        case askPassphrase
        case askWords
        case running
        /// Done — the insurance notice when it went off; the offer follows
        /// when pre-switch pairs were listed.
        case done(insuranceOff: Bool, hasOffer: Bool)
        case offer
        case failed(String)
        case closed
    }

    let id = UUID()
    let notice: FollowNotice
    private(set) var phase: Phase = .notice
    private(set) var busy = false
    var lastError: String?
    private(set) var outcome: PostureSwitchRunner.Outcome?

    let runner: PostureSwitchRunner
    private let controller: ProtectionController

    init(notice: FollowNotice, runner: PostureSwitchRunner, controller: ProtectionController) {
        self.notice = notice
        self.runner = runner
        self.controller = controller
    }

    var runnerPhase: PostureSwitchRunner.Phase { runner.phase }
    /// VX-208: the plain-text exports line under the Done — a follow that
    /// entered Castle (both faces; a Connect or a change notice has no outcome).
    var plaintextExportsLine: String? { ProtectionCopy.plaintextExportsLine(for: outcome) }
    /// VX-203: the offer's body with its honest counts (both faces).
    var offerBody: String { ProtectionCopy.deleteOldBackupsBody(for: outcome) }
    var isAlwaysAskVariant: Bool { notice.kind == .alwaysAskRetiredWord }
    /// pre-13x 3a: the Connect variant (copy §3) — the adopt road, never a
    /// follow; its third door is Cancel.
    var isConnectVariant: Bool { notice.kind == .connectLibrary }
    /// pre-13x 4a: the change notices — the new word verified at the vault
    /// and its local copy landed; nothing re-keyed, sync never paused.
    var isChangeNoticeVariant: Bool { notice.isChangeNotice }
    /// pre-13x 4a (ledger 54): a follow can run from the word just typed at
    /// the lobby — the session holds a derived key under the VAULT's
    /// descriptor — so *Enter Passphrase…* asks nothing.
    /// RUN A batch A2, row 10: the predicate moved to the controller so the
    /// doors that render a label BEFORE a model exists ask the same
    /// question — ONE brain, never two readings of "will it ask".
    var canFollowFromHeldKey: Bool { controller.followAsksNothing(for: notice) }

    // MARK: - The doors

    func choosePassphrase() {
        guard case .notice = phase else { return }
        // pre-13x 4a (ledger 54): the word just typed at the lobby is reused
        // — the follow runs with no field when the held derived key is under
        // the vault's descriptor; else the field asks as before.
        if canFollowFromHeldKey {
            Task { await followFromHeldKey() }
            return
        }
        phase = .askPassphrase
    }

    /// THE FOLLOW FROM THE HELD KEY (ledger 54): M′ by the derived key at the
    /// vault, the same road as the typed follow; a descriptor that differs
    /// at the vault (the word was changed elsewhere too) or a key that no
    /// longer opens it falls to the field (`passphraseRequired`).
    func followFromHeldKey() async {
        guard phase == .notice || phase == .askPassphrase, !busy else { return }
        guard let kdf = notice.vaultKDF, let key = controller.heldDerivedWrappingKey(under: kdf) else {
            phase = .askPassphrase
            return
        }
        lastError = nil
        busy = true
        defer { busy = false }
        phase = .running
        controller.switchInProgress = true
        defer { controller.switchInProgress = false }
        do {
            let outcome = try await runner.follow(derivedPassphraseKey: key, kdf: kdf)
            self.outcome = outcome
            controller.followLanded()
            phase = .done(insuranceOff: outcome.insuranceTurnedOff, hasOffer: outcome.hasOffer)
        } catch PostureSwitchError.passphraseRequired {
            phase = .askPassphrase
        } catch {
            phase = .failed(PostureSwitchModel.message(for: error))
        }
    }

    func chooseWords() {
        guard case .notice = phase else { return }
        phase = .askWords
    }

    /// *Later*: the library opens, reads and edits; sync does not run; the
    /// persistent banner speaks; the notice returns at every open.
    func later() {
        // A Connect owes nothing: Cancel closes without deferring; a change
        // notice's dismiss is per open.
        if isChangeNoticeVariant {
            controller.dismissChangeNotice()
        } else if !isConnectVariant {
            controller.deferFollow()
        }
        phase = .closed
    }

    func enter(passphrase: String) async {
        guard phase == .askPassphrase || phase == .notice, !busy else { return }
        guard !passphrase.isEmpty else {
            lastError = ProtectionCopy.message(for: StoreKeyEnvelopeError.emptyPassphrase)
            return
        }
        await run(passphrase: passphrase, words: nil)
    }

    func enter(wordsText: String) async {
        guard phase == .askWords || phase == .notice, !busy else { return }
        let words = EncryptionSession.words(from: wordsText)
        do {
            _ = try RecoveryPhrase.recoveryWrapKey(words: words)
        } catch {
            lastError = EncryptionSession.message(for: error)
            return
        }
        await run(passphrase: nil, words: words)
    }

    private func run(passphrase: String?, words: [String]?) async {
        lastError = nil
        busy = true
        defer { busy = false }
        phase = .running
        controller.switchInProgress = true
        defer { controller.switchInProgress = false }
        do {
            if isConnectVariant {
                // THE ADOPT ROAD (decision 17): the typed secret unwraps THIS
                // account's master; every row re-stamped, sync re-initialized,
                // custody + the key file landed; the whole library uploads.
                guard let act = controller.connectAct else { throw PostureSwitchError.syncKeysUnavailable }
                try await act(passphrase, words)
                controller.connectLanded()
                await controller.reconcile()
                phase = .done(insuranceOff: false, hasOffer: false)
                return
            }
            if isChangeNoticeVariant {
                // pre-13x 4a — THE CHANGE NOTICE's DOOR: the NEW word verified
                // at the vault (`pickUpKeys` — the same material re-saved under
                // the current shape; a wrong word refuses in place), then the
                // local copy landed under the vault's descriptor / the new
                // words' copy with the vault's digest; the notice clears.
                let picked = try await runner.pickUpKeys(passphrase: passphrase, recoveryWords: words)
                if let passphrase {
                    if let refusal = await controller.reconcilePassphraseWrap(
                        passphrase: passphrase, vaultKDF: picked.kdf, corpusKeyID: picked.material.corpusKeyID,
                        recoveryWrapDigest: picked.recoveryWrapDigest) {
                        lastError = refusal
                        phase = .askPassphrase
                        return
                    }
                } else if let words {
                    if let refusal = await controller.landRecoveryWrap(words: words, recoveryWrapDigest: picked.recoveryWrapDigest) {
                        lastError = refusal
                        phase = .askWords
                        return
                    }
                }
                controller.changeNoticeLanded()
                phase = .closed
                return
            }
            if isAlwaysAskVariant {
                // The vault road's pickup: the new word opens the vault, the
                // keys are held for the session, the local copy re-wrapped.
                let picked = try await runner.pickUpKeys(passphrase: passphrase, recoveryWords: words)
                if let passphrase {
                    if let refusal = await controller.reconcilePassphraseWrap(
                        passphrase: passphrase, vaultKDF: picked.kdf, corpusKeyID: picked.material.corpusKeyID,
                        recoveryWrapDigest: picked.recoveryWrapDigest) {
                        lastError = refusal
                    }
                }
                controller.followLanded()
                phase = .done(insuranceOff: false, hasOffer: false)
                return
            }
            let outcome = try await runner.follow(passphrase: passphrase, recoveryWords: words)
            self.outcome = outcome
            controller.followLanded()
            phase = .done(insuranceOff: outcome.insuranceTurnedOff, hasOffer: outcome.hasOffer)
        } catch VaultEnrollmentError.wrongPassphrase {
            // A Connect's — and a change notice's — word is the ACCOUNT's,
            // not this library's.
            lastError = (isConnectVariant || isChangeNoticeVariant)
                ? EncryptionSession.message(for: VaultEnrollmentError.wrongPassphrase)
                : ProtectionCopy.passphraseNotTheLibrarys
            phase = passphrase != nil ? .askPassphrase : .askWords
        } catch VaultEnrollmentError.wrongRecoveryPhrase {
            lastError = "Those aren't your account's twelve words."
            phase = .askWords
        } catch {
            phase = .failed(PostureSwitchModel.message(for: error))
        }
    }

    // MARK: - Done → the offer

    func continueFromDone() {
        guard case .done(_, let hasOffer) = phase else { return }
        phase = hasOffer ? .offer : .closed
    }

    func deleteOldBackups() {
        guard case .offer = phase, let outcome else { return }
        _ = runner.deletePreSwitchSnapshots(outcome)
        phase = .closed
    }

    func keepOldBackups() {
        guard case .offer = phase else { return }
        phase = .closed
    }

    func close() {
        phase = .closed
    }
}
