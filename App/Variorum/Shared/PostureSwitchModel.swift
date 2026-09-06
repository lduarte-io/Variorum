//
//  PostureSwitchModel.swift
//  Variorum (shared: Mac + Mobile — the ceremony's BRAIN; the Mac's sheet
//  renders it this batch, the phone's face at 2c)
//
//  pre-13x batch 2b — THE CASTLE CEREMONY (copy §2b, verbatim through
//  `ProtectionCopy`), the LEAVE confirm (§2c) and the RESUME road, over the
//  `PostureSwitchRunner`. Phases in the copy's order: what changes → the
//  passphrase (only if none) → the twelve words (generated + confirmed if
//  none; TYPED or REGENERATED when they exist — the batch record's question
//  1, option (A): the new keys are wrapped under the words in hand) → the
//  floor, read once, with the passphrase as the confirmation (typed unless
//  it was just set; verified against the VAULT's copy when enrolled — a
//  retired word is refused there — else against the key file) → During →
//  Done (+ the insurance notice) → the offer.
//
//  THE DOOR REFUSES BEFORE ASKING (decision 32, decision 9): the runner's
//  door check runs first — a rotation still finishing elsewhere and an
//  offline enrolled library both stop the ceremony at its first screen
//  with one sentence.
//

import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class PostureSwitchModel: Identifiable {
    enum Mode: Equatable, Sendable {
        /// Standard → Castle (§4 whole).
        case enter
        /// Castle → Standard (§4's second act).
        case leave
        /// A switch that did not finish on this device (the marker).
        case resume(RotationMarker)
    }

    enum Phase: Equatable {
        /// The door check (online; decision 32).
        case checking
        /// §2b Screen 1.
        case explain
        /// §2b Screen 2 (only if no passphrase is set).
        case setPassphrase
        /// §2b Screen 3 when words exist: type them, or generate new ones.
        case wordsExisting
        case wordsType
        /// §2b Screen 3 / 3b: the fresh words, then confirm by re-entry.
        case wordsShow([String])
        case wordsConfirm([String])
        /// §2b Screen 4: the floor; the passphrase field when it was not
        /// just set.
        case floor(needsPassphrase: Bool)
        /// During (the runner's phase renders as text).
        case running
        /// Done — the notice when the insurance went off; the offer follows
        /// when pre-switch pairs exist.
        case done(insuranceOff: Bool, hasOffer: Bool)
        /// §2b's once-only offer.
        case offer
        /// §2c.
        case leaveConfirm
        case leftCastle
        /// The resume: the passphrase when a step needs it.
        case resumeAsk(needsPassphrase: Bool)
        /// A refusal at the door or a failure mid-road (the sentence).
        case failed(String)
        case closed
    }

    let id = UUID()
    let mode: Mode
    private(set) var phase: Phase = .checking
    private(set) var busy = false
    var lastError: String?
    /// The words on the clipboard timer (copy: "clears in 60 seconds").
    private(set) var copiedWords = false

    let runner: PostureSwitchRunner
    private let controller: ProtectionController
    private let vaultTie: VaultTie?
    private var facts: PostureSwitchRunner.DoorFacts?
    private var passphraseInHand: String?
    private var wordsInHand: [String]?
    private(set) var outcome: PostureSwitchRunner.Outcome?

    init(mode: Mode, runner: PostureSwitchRunner, controller: ProtectionController, vaultTie: VaultTie?) {
        self.mode = mode
        self.runner = runner
        self.controller = controller
        self.vaultTie = vaultTie
    }

    /// The runner's progress, for the During line.
    var runnerPhase: PostureSwitchRunner.Phase { runner.phase }

    var vaultConstrains: Bool { vaultTie != nil }

    // MARK: - The door

    /// The first act: the door check. A rotation finishing elsewhere or an
    /// offline enrolled library refuses HERE, before any screen asks.
    func start() async {
        guard case .checking = phase else { return }
        busy = true
        defer { busy = false }
        do {
            let facts = try await runner.checkDoor()
            self.facts = facts
            if facts.rotationInProgress {
                phase = .failed(ProtectionCopy.rotationStillFinishing(
                    device: "another device",
                    day: EncryptionView.displayDate(facts.vaultUpdatedAt) ?? "an earlier day"))
                return
            }
            switch mode {
            case .enter: phase = .explain
            case .leave: phase = .leaveConfirm
            case .resume: await resume(passphrase: nil)
            }
        } catch {
            phase = .failed(Self.message(for: error))
        }
    }

    // MARK: - §2b Screen 1 → 2 / 3

    func continueFromExplain() {
        guard case .explain = phase else { return }
        if controller.hasPassphraseWrap {
            advanceToWords()
        } else {
            phase = .setPassphrase
        }
    }

    // MARK: - §2b Screen 2: the passphrase (set if none)

    func commitPassphrase(_ passphrase: String, confirmation: String) async {
        guard case .setPassphrase = phase, !busy else { return }
        lastError = nil
        guard passphrase.count >= 12 else {
            lastError = ProtectionCopy.passphraseTooShort
            return
        }
        guard passphrase == confirmation else {
            lastError = ProtectionCopy.passphraseMismatch
            return
        }
        busy = true
        defer { busy = false }
        // ONE SECRET: an enrolled account's passphrase IS the library's.
        if let vaultTie {
            switch await vaultTie.verifyPassphrase(passphrase) {
            case .match: break
            case .mismatch: lastError = ProtectionCopy.passphraseNotTheLibrarys; return
            case .couldNotCheck(let reason):
                lastError = "Couldn't verify against your account (\(reason))."
                return
            }
        }
        if let refusal = await controller.setPassphrase(passphrase) {
            lastError = refusal
            return
        }
        passphraseInHand = passphrase
        advanceToWords()
    }

    // MARK: - §2b Screen 3: the twelve words (the shared brain — pre-13x 3a)

    private var wordsExist: Bool {
        controller.hasRecoveryWrap || (vaultTie?.hasRecoveryWrap ?? false)
            || (facts?.vaultHasRecoveryWrap ?? false)
    }

    /// The ONE words brain both ceremonies compose (`WordsCeremony`); this
    /// model mirrors its step into its own phases.
    private var words: WordsCeremony?

    private func advanceToWords() {
        do {
            words = try WordsCeremony(wordsExist: wordsExist)
            mirrorWords()
        } catch {
            phase = .failed(Self.message(for: error))
        }
    }

    private func mirrorWords() {
        guard let words else { return }
        switch words.step {
        case .existing: phase = .wordsExisting
        case .typeExisting: phase = .wordsType
        case .show(let shown): phase = .wordsShow(shown)
        case .confirm(let shown): phase = .wordsConfirm(shown)
        case .done:
            wordsInHand = words.wordsInHand
            phase = .floor(needsPassphrase: passphraseInHand == nil)
        }
    }

    func chooseTypeWords() {
        guard case .wordsExisting = phase else { return }
        words?.chooseTypeMine()
        mirrorWords()
    }

    func chooseGenerateNewWords() {
        guard case .wordsExisting = phase else { return }
        do {
            try words?.chooseGenerateNew()
            mirrorWords()
        } catch {
            phase = .failed(Self.message(for: error))
        }
    }

    /// The existing words, typed — verified against the VAULT when
    /// enrolled, else against this library's key file.
    func submitExistingWords(_ typed: String) async {
        guard case .wordsType = phase, !busy, let words else { return }
        lastError = nil
        busy = true
        defer { busy = false }
        let ok = await words.submitExisting(typed) { text in
            if let vaultTie, vaultTie.hasRecoveryWrap {
                return await vaultTie.verifyRecoveryWords(text)
            }
            switch await controller.verifyRecoveryWordsAgainstStore(text) {
            case true?: return .match
            case false?: return .mismatch(ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongRecoveryPhrase))
            case nil: return .match
            }
        }
        guard ok else { lastError = words.lastError; return }
        mirrorWords()
    }

    func markWordsCopied() {
        copiedWords = true
    }

    func acknowledgeWordsWritten() {
        guard case .wordsShow = phase else { return }
        words?.acknowledgeWritten()
        mirrorWords()
    }

    /// Screen 3b: the re-entry must be the shown words, exactly.
    func confirmWords(_ typed: String) {
        guard case .wordsConfirm = phase, let words else { return }
        lastError = nil
        guard words.confirm(typed) else { lastError = words.lastError; return }
        mirrorWords()
    }

    // MARK: - §2b Screen 4: the floor, and the act

    func enterCastle(passphrase typed: String?, acknowledged: Bool) async {
        guard case .floor(let needsPassphrase) = phase, !busy else { return }
        lastError = nil
        guard acknowledged else {
            lastError = ProtectionCopy.floorCheckbox
            return
        }
        busy = true
        defer { busy = false }
        if needsPassphrase {
            guard let typed, !typed.isEmpty else {
                lastError = ProtectionCopy.message(for: StoreKeyEnvelopeError.emptyPassphrase)
                return
            }
            guard await verifyPassphrase(typed) else { return }
            passphraseInHand = typed
        }
        guard let passphrase = passphraseInHand else { return }
        phase = .running
        controller.switchInProgress = true
        defer { controller.switchInProgress = false }
        do {
            let outcome = try await runner.enterCastle(passphrase: passphrase, recoveryWords: wordsInHand)
            self.outcome = outcome
            phase = .done(insuranceOff: outcome.insuranceTurnedOff, hasOffer: !outcome.preSwitchSnapshots.isEmpty)
        } catch {
            phase = .failed(Self.message(for: error))
        }
    }

    /// The passphrase, verified where the design says: the VAULT's current
    /// copy when enrolled (a retired word is refused there — §3.6), else
    /// this library's key file.
    private func verifyPassphrase(_ typed: String) async -> Bool {
        if let vaultTie {
            switch await vaultTie.verifyPassphrase(typed) {
            case .match: return true
            case .mismatch: lastError = ProtectionCopy.passphraseNotTheLibrarys; return false
            case .couldNotCheck(let reason):
                lastError = "Couldn't verify against your account (\(reason))."
                return false
            }
        }
        switch await controller.verifyPassphraseAgainstStore(typed) {
        case true?: return true
        case false?: lastError = ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongPassphrase); return false
        case nil: return true  // no wrap to check against — the passphrase is being set
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

    // MARK: - §2c Leaving Castle

    func leaveWithBiometrics() async {
        guard case .leaveConfirm = phase, !busy else { return }
        busy = true
        defer { busy = false }
        guard await controller.confirmPresence("Confirm it's you to leave Castle") else {
            lastError = "Not confirmed — nothing was changed."
            return
        }
        await leaveNow()
    }

    func leave(passphrase typed: String) async {
        guard case .leaveConfirm = phase, !busy else { return }
        lastError = nil
        busy = true
        defer { busy = false }
        guard await verifyPassphrase(typed) else { return }
        await leaveNow()
    }

    private func leaveNow() async {
        phase = .running
        do {
            try await runner.leaveCastle()
            phase = .leftCastle
        } catch {
            phase = .failed(Self.message(for: error))
        }
    }

    // MARK: - The resume

    func resume(passphrase: String?) async {
        busy = true
        defer { busy = false }
        phase = .running
        controller.switchInProgress = true
        defer { controller.switchInProgress = false }
        do {
            let outcome = try await runner.resume(passphrase: passphrase, recoveryWords: nil)
            self.outcome = outcome
            phase = .done(insuranceOff: outcome.insuranceTurnedOff, hasOffer: !outcome.preSwitchSnapshots.isEmpty)
        } catch PostureSwitchError.passphraseRequired {
            phase = .resumeAsk(needsPassphrase: true)
        } catch PostureSwitchError.restartRequired {
            // The vault write never landed: the ceremony starts over.
            phase = .explain
        } catch {
            phase = .failed(Self.message(for: error))
        }
    }

    func close() {
        phase = .closed
    }

    // MARK: - Wording (every refusal speaks — the R94 doctrine)

    static func message(for error: any Error) -> String {
        switch error {
        case CorpusRotationError.rotationInProgress:
            return ProtectionCopy.rotationStillFinishing(device: "another device", day: "an earlier day")
        case CorpusRotationError.staleMaster:
            return "This account's keys changed since this \(ProtectionCopy.deviceName) joined — "
                + "pick up your new keys first (enter your passphrase under Account & Encryption)."
        case let error as SyncError:
            return error.description
        case PostureSwitchError.libraryKeyUnavailable:
            return ProtectionController.keyUnavailable
        case PostureSwitchError.syncKeysUnavailable:
            return "Pick up your new keys first — enter your passphrase."
        case PostureSwitchError.switchInProgress:
            return ProtectionCopy.resumeBody
        case PostureSwitchError.nothingToResume:
            return "Nothing is left to finish."
        case PostureSwitchError.passphraseRequired:
            return ProtectionCopy.resumeNeedsPassphrase
        case PostureSwitchError.restartRequired:
            return "The earlier attempt never reached the server — start again."
        case PostureSwitchError.vaultRefused(let text), PostureSwitchError.custodyRefused(let text),
             PostureSwitchError.rekeyFailed(let text):
            return text
        case PostureSwitchError.appleKeyUnavailable:
            return "iCloud Keychain wouldn't hold the key on this \(ProtectionCopy.deviceName) — "
                + "nothing was changed."
        case PostureSwitchError.wrongPosture:
            return "That switch doesn't apply right now."
        case VaultEnrollmentError.wrongPassphrase:
            return ProtectionCopy.passphraseNotTheLibrarys
        case is URLError:
            return "Couldn't reach the server — check your connection and try again."
        default:
            return EncryptionSession.message(for: error)
        }
    }
}
