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
    var isAlwaysAskVariant: Bool { notice.kind == .alwaysAskRetiredWord }
    /// pre-13x 3a: the Connect variant (copy §3) — the adopt road, never a
    /// follow; its third door is Cancel.
    var isConnectVariant: Bool { notice.kind == .connectLibrary }

    // MARK: - The doors

    func choosePassphrase() {
        guard case .notice = phase else { return }
        phase = .askPassphrase
    }

    func chooseWords() {
        guard case .notice = phase else { return }
        phase = .askWords
    }

    /// *Later*: the library opens, reads and edits; sync does not run; the
    /// persistent banner speaks; the notice returns at every open.
    func later() {
        // A Connect owes nothing: Cancel closes without deferring.
        if !isConnectVariant { controller.deferFollow() }
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
            if isAlwaysAskVariant {
                // The vault road's pickup: the new word opens the vault, the
                // keys are held for the session, the local copy re-wrapped.
                let picked = try await runner.pickUpKeys(passphrase: passphrase, recoveryWords: words)
                if let passphrase {
                    if let refusal = await controller.reconcilePassphraseWrap(
                        passphrase: passphrase, vaultKDF: picked.kdf, corpusKeyID: picked.material.corpusKeyID) {
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
            phase = .done(insuranceOff: outcome.insuranceTurnedOff, hasOffer: !outcome.preSwitchSnapshots.isEmpty)
        } catch VaultEnrollmentError.wrongPassphrase {
            // A Connect's word is the ACCOUNT's, not this library's.
            lastError = isConnectVariant
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
