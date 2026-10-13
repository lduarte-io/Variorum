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

/// VX-99 round 2 (finding 1 — the cold review's MAJOR): WHICH act a
/// ceremony face is speaking for. The mode names it for a fresh ceremony;
/// for a RESUME it is the pending marker's act (`init(resuming:)`) — a
/// switch into Castle, a Replace All Keys, or a FOLLOW (the marker's
/// `follow` flag; into Castle or not by the marker's posture). The running
/// title, the resume's ask, the Done and the restart all read this ONE
/// value on both platforms (`ProtectionCopy.ceremonyRunningTitle` ·
/// `ceremonyResumeTitle` · `ceremonyDoneBody`; the model's flow).
nonisolated enum CeremonyAct: Equatable, Sendable {
    case enterCastle
    case replaceKeys
    case leaveCastle
    /// A follow's marker (2c / 2d.4): this device was picking up keys
    /// another device minted — into Castle or not.
    case follow(entersCastle: Bool)

    /// The act a pending marker records.
    init(resuming marker: RotationMarker) {
        if marker.isFollow {
            self = .follow(entersCastle: marker.entersCastle)
        } else {
            self = marker.entersCastle ? .enterCastle : .replaceKeys
        }
    }

    /// Whether the act, by itself, enters Castle (the road's outcome may
    /// still say otherwise — the Done reads the outcome first).
    var entersCastle: Bool {
        switch self {
        case .enterCastle: return true
        case .replaceKeys, .leaveCastle: return false
        case .follow(let entersCastle): return entersCastle
        }
    }

    var isFollow: Bool {
        if case .follow = self { return true }
        return false
    }
}

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
        /// pre-13x 3b — REPLACE ALL KEYS (copy §4; decisions 30 · 32 · 33):
        /// §4's steps 1–4 without the posture change, over the same runner
        /// road (`replaceAllKeys`); the words through the same brain; the
        /// passphrase TYPED and vault-verified at `.authorize`; the
        /// *Also choose a new passphrase* checkbox as a re-wrap on the NEW
        /// vault after the rotation.
        case replaceKeys
    }

    enum Phase: Equatable {
        /// The door check (online; decision 32).
        case checking
        /// VX-110: signed out while this library holds its sync account's
        /// keys — the two doors: Sign In… (the account-wide switch) or Use
        /// Castle on This Mac Only. A flat refusal would trap the user who
        /// lost the account (§W).
        case signedOutChoice
        /// VX-110: Sign In… was chosen — the ceremony ENDS here (no
        /// auto-resume across an async sign-in, PROVISIONAL); the faces show
        /// the sign-in surface, and Use Castle is pressed again after.
        case signInChosen
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
        /// pre-13x 3b (Replace All Keys): the passphrase typed and verified
        /// against the VAULT's copy (copy §4's authorization line).
        case authorize
        /// pre-13x 3b (Replace All Keys, the checkbox): the new passphrase
        /// (≥ 12, matched) — re-wrapped on the new vault after the rotation.
        case newPassphrase
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
    /// pre-13x 3b: the checkbox's new passphrase (Replace All Keys).
    private var newPassphraseInHand: String?
    private(set) var outcome: PostureSwitchRunner.Outcome?
    /// pre-13x 3b: *Also choose a new passphrase* (the face sets it before
    /// leaving the explain screen; a passphrase handed in from the change
    /// door already IS the new one, so the face hides the checkbox then).
    var wantsNewPassphrase = false
    /// VX-110: Use Castle on This Mac Only was chosen at the two doors —
    /// the explain screen speaks for this device alone and the act forgets
    /// the sync account's keys before it re-keys.
    private(set) var thisDeviceOnly = false

    /// `passphraseInHand` / `wordsInHand` (pre-13x 3b): the secrets a key
    /// door hands over when its checkbox opens Replace All Keys — the NEW
    /// passphrase after a change (the authorize screen is skipped), the NEW
    /// words after a regeneration (the words screens are skipped).
    init(
        mode: Mode, runner: PostureSwitchRunner, controller: ProtectionController, vaultTie: VaultTie?,
        passphraseInHand: String? = nil, wordsInHand: [String]? = nil
    ) {
        self.mode = mode
        self.runner = runner
        self.controller = controller
        self.vaultTie = vaultTie
        self.passphraseInHand = passphraseInHand
        self.wordsInHand = wordsInHand
    }

    /// The runner's progress, for the During line.
    var runnerPhase: PostureSwitchRunner.Phase { runner.phase }

    var vaultConstrains: Bool { vaultTie != nil }
    private var isResume: Bool {
        if case .resume = mode { return true }
        return false
    }

    /// VX-99 round 2 (finding 1): the act this ceremony speaks for — the
    /// mode's, or a resume's MARKER's. Every face branch and every flow
    /// branch that used to ask `mode == .replaceKeys` asks this instead.
    var act: CeremonyAct {
        switch mode {
        case .enter: return .enterCastle
        case .leave: return .leaveCastle
        case .replaceKeys: return .replaceKeys
        // The MARKER's act — before VX-99 round 2 every branch read
        // `mode == .replaceKeys`, so a resume of ANY marker was the Castle
        // ceremony: its title, its "Entering Castle didn't finish", its
        // Done ("…a new key that your Apple account never held") over a
        // Replace All Keys, and — on a restart — its flow into
        // `runner.enterCastle`.
        case .resume(let marker): return CeremonyAct(resuming: marker)
        }
    }

    /// The running screen's title, by the act (both faces render it).
    var runningTitle: String { ProtectionCopy.ceremonyRunningTitle(act) }
    /// The resume's passphrase screen title, by the act (both faces).
    var resumeAskTitle: String { ProtectionCopy.ceremonyResumeTitle(act) }
    /// The Done's body, by the act and the outcome's road (both faces).
    var doneBody: String { ProtectionCopy.ceremonyDoneBody(act: act, outcome: outcome) }
    /// VX-110: §2b Screen 1's body and bullets, by the road — the account-
    /// wide ones ("…and so does your sync", "your other devices will start
    /// asking too") are false on This Mac Only (both faces).
    var explainBody: String {
        thisDeviceOnly ? ProtectionCopy.enterCastleThisDeviceOnlyBody : ProtectionCopy.enterCastleBody
    }
    var explainBullets: [String] {
        thisDeviceOnly ? ProtectionCopy.enterCastleThisDeviceOnlyBullets : ProtectionCopy.enterCastleBullets
    }
    /// pre-13x 3b (Replace All Keys' faces): the Standard addendum renders
    /// on a Standard ACCOUNT; the checkbox hides when a door handed the new
    /// passphrase in (it IS the new one). VX-99 round 2 (finding 2): the
    /// account is the VAULT's word as the door read it — the same word the
    /// act keeps M′ under A by (round 1's door + belt) — so under a stale or
    /// indeterminate reading the screen and the act agree (decision 8 · 30).
    /// The device's posture only before the door has answered.
    var accountPostureIsStandard: Bool {
        if let vaultSaysStandard = facts?.vaultHasAppleHeldCopy { return vaultSaysStandard }
        return controller.posture == .standard
    }
    var passphraseHandedIn: Bool { passphraseInHand != nil }

    // MARK: - The door

    /// The first act: the door check. A rotation finishing elsewhere or an
    /// offline enrolled library refuses HERE, before any screen asks.
    func start() async {
        guard case .checking = phase else { return }
        busy = true
        defer { busy = false }
        // pre-13x 4b (§7 — the un-followed device; §12): a follow is owed —
        // the posture switches and Replace All Keys speak the one sentence
        // instead of acting (the pane hides these doors too; the model
        // refuses on its own). The marker's RESUME is exempt: that road IS
        // the follow when the account moved under a crashed switch.
        if controller.followPending, !isResume {
            phase = .failed(ProtectionCopy.pickUpKeysFirst)
            return
        }
        // 13x F1 (ladder R1-M1 — P-R1-1): a standing RESTORE HOLD refuses
        // the two ROTATION ceremonies at the door — their road drains the
        // outbox and pulls to head before any screen (`rotate` step 1),
        // which would breach round 3's "no round runs until Resume" and
        // QD's "the kept outbox pushes at Resume". The pick-up-keys-first
        // grammar's sibling, one sentence. Use Standard stays open
        // (traced: `leaveCastle` drives no engine) and the marker's
        // RESUME stays exempt (recovery — the guard above's own
        // exemption).
        if mode == .enter || mode == .replaceKeys,
           controller.restoreHoldStands?() == true {
            phase = .failed(ProtectionCopy.resumeSyncFirst)
            return
        }
        do {
            let facts = try await runner.checkDoor()
            self.facts = facts
            // Decision 32's still-finishing door — for every mode BUT the
            // RESUME (VX-99 round 2b, item 1): `rotationInProgress` (the
            // vault's previous key) is exactly the state this device's OWN
            // ceremony leaves when it dies mid-walk, and the resume is the
            // road that finishes it ("the acting device resumes through its
            // marker and never starts a second"). Refusing it here left the
            // marker standing — every round refused — and a one-device
            // account paused for good. The resume's runner road reads the
            // fresh vault itself (`PostureSwitchRunner.resume`).
            if facts.rotationInProgress, !isResume {
                phase = .failed(stillFinishingSentence)
                return
            }
            switch mode {
            case .enter:
                // VX-110: signed out with the sync account's keys held, the
                // local road's Castle would revert silently at the next
                // signed-in ready — the two doors decide first.
                phase = facts.signedOutHoldingSyncKeys ? .signedOutChoice : .explain
            case .leave: phase = .leaveConfirm
            case .resume: await resume(passphrase: nil)
            case .replaceKeys:
                if let refusal = replaceKeysFrontCheck(facts) {
                    phase = .failed(refusal)
                    return
                }
                phase = .explain
            }
        } catch {
            phase = .failed(wording(for: error))
        }
    }

    /// Replace All Keys' FRONT CHECK — one rule for the door and for a
    /// resume that RESTARTS a Replace All Keys (VX-99 round 2, finding 1,
    /// arm iii). §5's row: enrolled; holding the CURRENT master — the key
    /// file's recorded corpus id against the vault's (a stale one ⇒ *this
    /// account's keys don't match this library*; the follow's door is the
    /// notice bar's). pre-13x ladder round 2, F3 (MINOR-N4): MAJOR-3 (b)'s
    /// refusal AT THE DOOR — decision 32's pattern: on a Standard account
    /// the account's iCloud key must be readable here and be the vault's
    /// (decision 30: the new master is re-wrapped under the SAME A, never a
    /// minted one); before F3 this fired at step 2, after Screens 2–4, and
    /// *Generate New Ones* had then shown twelve words that opened nothing.
    /// The runner's own check stays as the belt.
    private func replaceKeysFrontCheck(_ facts: PostureSwitchRunner.DoorFacts) -> String? {
        guard facts.enrolled else { return ProtectionCopy.replaceKeysNotEnrolled }
        if let vaultID = facts.vaultCorpusKeyID, let recorded = controller.keyFileVaultCorpusKeyID,
           recorded != vaultID {
            return Self.message(for: CorpusRotationError.staleMaster(vaultKeyID: vaultID, heldKeyID: recorded))
        }
        if facts.appleKeyReadable == false { return ProtectionCopy.replaceKeysAppleKeyUnreachable }
        return nil
    }

    // MARK: - VX-110: the two doors (signed out, the sync account's keys held)

    /// Sign In… — the account-wide switch needs the session: the ceremony
    /// ends here, nothing written; the faces open the sign-in surface.
    func chooseSignIn() {
        guard case .signedOutChoice = phase else { return }
        phase = .signInChosen
    }

    /// Use Castle on This Mac Only — the screens follow as ever, under the
    /// explain screen's this-device words; the act forgets the account's
    /// keys before it re-keys.
    func chooseThisDeviceOnly() {
        guard case .signedOutChoice = phase else { return }
        thisDeviceOnly = true
        phase = .explain
    }

    // MARK: - §2b Screen 1 → 2 / 3

    func continueFromExplain() {
        guard case .explain = phase else { return }
        if act == .replaceKeys {
            // The words in hand already (a regeneration handed them in) ⇒
            // straight to the authorization; else the words screens.
            if wordsInHand != nil { advanceAfterWords() } else { advanceToWords() }
            return
        }
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
        guard passphrase.count >= ProtectionCopy.passphraseFloor else {
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
            phase = .failed(wording(for: error))
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
            if act == .replaceKeys {
                advanceAfterWords()
            } else {
                phase = .floor(needsPassphrase: passphraseInHand == nil)
            }
        }
    }

    /// pre-13x 3b (Replace All Keys): after the words — the passphrase
    /// typed at `.authorize` unless a door handed it in; then the new
    /// passphrase when the checkbox is on; then the act.
    private func advanceAfterWords() {
        if passphraseInHand == nil {
            phase = .authorize
        } else if wantsNewPassphrase, newPassphraseInHand == nil {
            phase = .newPassphrase
        } else {
            Task { await replaceKeys() }
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
            phase = .failed(wording(for: error))
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
            let outcome = try await runner.enterCastle(
                passphrase: passphrase, recoveryWords: wordsInHand, thisDeviceOnly: thisDeviceOnly)
            self.outcome = outcome
            phase = .done(insuranceOff: outcome.insuranceTurnedOff, hasOffer: !outcome.preSwitchSnapshots.isEmpty)
        } catch PostureSwitchError.signInOrThisDeviceOnly {
            // VX-110: the session lapsed during the screens while custody
            // holds the account's keys — nothing was written; the two doors
            // decide (the runner's belt behind the door's own fork).
            thisDeviceOnly = false
            phase = .signedOutChoice
        } catch {
            phase = .failed(wording(for: error))
        }
    }

    /// The passphrase, verified where the design says: the VAULT's current
    /// copy when enrolled (a retired word is refused there — §3.6), else
    /// this library's key file.
    ///
    /// RUN A batch A3 (17m): the rule itself now lives in `KeyActPassphrase`
    /// — hoisted VERBATIM so the re-link door checks the passphrase the same
    /// way rather than carrying a second copy of it (row 12's lesson). This
    /// model still words the outcome into its own `lastError`, so every
    /// caller and every pin sees exactly what it always did.
    private func verifyPassphrase(_ typed: String) async -> Bool {
        switch await KeyActPassphrase.verify(typed, against: vaultTie, orStore: controller) {
        case .verified: return true
        case .refused(let message): lastError = message; return false
        }
    }

    // MARK: - pre-13x 3b: Replace All Keys — the authorization, the new passphrase, the act

    /// Copy §4's authorization: the passphrase TYPED and verified against
    /// the VAULT's copy — a retired word (the key file's recorded descriptor
    /// no longer the vault's) is refused with copy §5's sentence.
    func authorize(passphrase typed: String) async {
        guard case .authorize = phase, !busy, act == .replaceKeys else { return }
        lastError = nil
        guard !typed.isEmpty else {
            lastError = ProtectionCopy.message(for: StoreKeyEnvelopeError.emptyPassphrase)
            return
        }
        busy = true
        defer { busy = false }
        guard await verifyPassphrase(typed) else {
            if let recorded = controller.keyFileRecordedVaultKDF, let vaultKDF = facts?.vaultKDF, recorded != vaultKDF {
                lastError = ProtectionCopy.retiredPassphraseAtDoor
            }
            return
        }
        passphraseInHand = typed
        if wantsNewPassphrase {
            phase = .newPassphrase
        } else {
            await replaceKeys()
        }
    }

    /// The checkbox's new passphrase (≥ 12, matched); then the act.
    func commitNewPassphrase(_ new: String, confirmation: String) async {
        guard case .newPassphrase = phase, !busy, act == .replaceKeys else { return }
        lastError = nil
        guard new.count >= ProtectionCopy.passphraseFloor else {
            lastError = ProtectionCopy.passphraseTooShort
            return
        }
        guard new == confirmation else {
            lastError = ProtectionCopy.passphraseMismatch
            return
        }
        newPassphraseInHand = new
        await replaceKeys()
    }

    /// The act: `runner.replaceAllKeys` (§4's steps 1–4 without the posture
    /// change — the Apple-held copy kept under Standard, decision 30), then
    /// the checkbox's re-wrap on the NEW vault under the NEW proof through
    /// the tie's change-passphrase act (the key file's copy follows under
    /// the vault's new descriptor through the session's landing).
    private func replaceKeys() async {
        guard let passphrase = passphraseInHand else {
            phase = .authorize
            return
        }
        busy = true
        defer { busy = false }
        phase = .running
        controller.switchInProgress = true
        defer { controller.switchInProgress = false }
        do {
            let outcome = try await runner.replaceAllKeys(passphrase: passphrase, recoveryWords: wordsInHand)
            self.outcome = outcome
            if let new = newPassphraseInHand {
                guard let change = vaultTie?.changePassphrase else {
                    throw KeyDoorRefusal("The new passphrase couldn't be set here — your keys were replaced; change the passphrase under Account & Encryption.")
                }
                try await change(passphrase, new)
                passphraseInHand = new
            }
            // VX-99 round 2 (finding 1, arm iv): the OUTCOME's road, never a
            // hard-coded "no notice, no offer" — when the vault's CAS refuse
            // made this road the FOLLOW into another device's Castle
            // (`runCeremony`'s re-read), the insurance went off and the
            // pre-switch pairs are listed, and the face must say both.
            phase = .done(insuranceOff: outcome.insuranceTurnedOff, hasOffer: !outcome.preSwitchSnapshots.isEmpty)
        } catch {
            phase = .failed(wording(for: error))
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
            phase = .failed(wording(for: error))
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
            // The vault write never landed: the ceremony starts over — the
            // MARKER's OWN ceremony (VX-99 round 2, finding 1, arm iii): the
            // runner cleared the marker, and `act` still names what it
            // recorded, so a Replace All Keys restarts Replace All Keys (its
            // screen, its words, `.authorize`, `runner.replaceAllKeys`),
            // never the Castle ceremony's floor and `runner.enterCastle`. A
            // restart is a fresh rotation, so it passes that ceremony's own
            // door first: the restore hold (the resume road's exemption ends
            // here — the restarted road drains and pulls) and, for Replace
            // All Keys, the front check (`facts` were read at `start()`).
            if act == .enterCastle || act == .replaceKeys, controller.restoreHoldStands?() == true {
                phase = .failed(ProtectionCopy.resumeSyncFirst)
                return
            }
            if act == .replaceKeys, let facts, let refusal = replaceKeysFrontCheck(facts) {
                phase = .failed(refusal)
                return
            }
            phase = .explain
        } catch {
            phase = .failed(wording(for: error))
        }
    }

    func close() {
        phase = .closed
    }

    // MARK: - Wording (every refusal speaks — the R94 doctrine)

    /// pre-13x ladder round 1, F2 (MINOR-4 — decision 34): copy §4's
    /// still-finishing sentence names the device that started the
    /// rotation and the vault's day, both from the door check's facts —
    /// before F2 it always said "another device", the one sentence the
    /// `updated_by_device` column was ruled for.
    private var stillFinishingSentence: String {
        ProtectionCopy.rotationStillFinishing(
            device: facts?.updatedByDevice ?? ProtectionCopy.anotherDevice,
            day: EncryptionView.displayDate(facts?.vaultUpdatedAt) ?? "an earlier day")
    }

    /// The instance wording: a rotation refused MID-RUN (the runner's own
    /// re-read at step 1) speaks the same named sentence from the facts the
    /// door read moments before; everything else is the static table.
    /// **RUN A batch A2, row 13 (17l item 7 / QUESTIONS #90 (11), MINOR-N4
    /// (2)): a failure AFTER *Generate New Ones* must say the words she
    /// just wrote down are not in use.** F3 moved MAJOR-3 (b)'s refusal to
    /// the DOOR so the words screens never run for a ceremony whose step 2
    /// would refuse — but every other post-screen failure (`outboxNotEmpty`,
    /// `pullStalled`, `wordsRequired`, a vault refusal) still lands here
    /// with twelve fresh words on paper and nothing behind them. The tail
    /// rides the instance `wording`, which is exactly the set of failures
    /// reachable after the screens; the door's own refusals are constants
    /// and never pass through here. PROVISIONAL wording, in the ruled
    /// ledger-61 sentence family; 13s re-voices (QUESTIONS #138).
    private func wording(for error: any Error) -> String {
        let sentence: String
        if case CorpusRotationError.rotationInProgress = error {
            sentence = stillFinishingSentence
        } else {
            sentence = Self.message(for: error)
        }
        guard words?.regenerated == true else { return sentence }
        return sentence + " " + ProtectionCopy.freshWordsNeverLanded
    }

    /// The switches' one offline sentence (copy row: the runner's transport
    /// wording) — named once so the refusal and the URL error share it.
    static let serverUnreachable = "Couldn't reach the server — check your connection and try again."

    static func message(for error: any Error) -> String {
        switch error {
        case CorpusRotationError.rotationInProgress:
            // The static fallback (no facts in hand — `PostureFollowModel`'s
            // road); the ceremony's instance wording names the device.
            return ProtectionCopy.rotationStillFinishing(device: ProtectionCopy.anotherDevice, day: "an earlier day")
        case CorpusRotationError.completionRefused, CorpusRotationError.walkDidNotConverge:
            // pre-13x ladder round 1, F1 (BLOCKER-1): the server would not
            // clear the previous key over a row this device could not see
            // yet — the marker stays, the resume re-walks. PROVISIONAL
            // wording (copy §11); the fact is the design's.
            return ProtectionCopy.rotationRowsStillSettling
        case CorpusRotationError.staleMaster:
            return "This account's keys changed since this \(ProtectionCopy.deviceName) joined — "
                + "pick up your new keys first (enter your passphrase under Account & Encryption)."
        case let error as SyncError:
            return error.description
        case PostureSwitchError.libraryKeyUnavailable:
            return ProtectionController.keyUnavailable
        case PostureSwitchError.syncKeysUnavailable:
            return "Pick up your new keys first — enter your passphrase."
        case PostureSwitchError.switchInProgress(_, let act?):
            // VX-99 round 2b (item 2's sibling): a road refused because THIS
            // device's marker is pending speaks the MARKER's act through
            // F1's one selector — before it, "Entering Castle didn't finish"
            // over a pending Replace All Keys at every door (the follow's
            // included: `PostureFollowModel` words through here).
            return ProtectionCopy.ceremonyResumeTitle(act)
        case PostureSwitchError.switchInProgress:
            // The busy guard: another road of this runner is in flight and
            // no marker exists to read — the shipped sentence, unchanged
            // (its own wording is a residual for 13s; the record's round 2b).
            return ProtectionCopy.resumeBody
        case PostureSwitchError.nothingToResume:
            return "Nothing is left to finish."
        case PostureSwitchError.wordsRequired:
            // pre-13x 3b (ledger 44) — a reading: the copy file has no line
            // for a road no face can reach; the sentence names the fix.
            return "Your twelve words are needed to replace your keys — type them, or generate new ones."
        case let refusal as KeyDoorRefusal:
            return refusal.description
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
        case PostureSwitchError.appleKeyUnreachable:
            // pre-13x ladder round 1, F2 (MAJOR-3 b): copy §4's PROVISIONAL line.
            return ProtectionCopy.replaceKeysAppleKeyUnreachable
        case PostureSwitchError.wrongPosture:
            return "That switch doesn't apply right now."
        case VaultEnrollmentError.wrongPassphrase:
            return ProtectionCopy.passphraseNotTheLibrarys
        case PostureSwitchError.replaceKeysNeedsSync:
            // VX-99 round 2 (finding 4 — decision 9): the switches' offline
            // line (`pre-13x-copy.md`'s row: "Replace All Keys / Use Castle /
            // Use Standard offline" speaks the transport wording), so the gap
            // and a dropped connection read alike.
            return serverUnreachable
        // VX-110 (PROVISIONAL words — the U2 copy drafts).
        case PostureSwitchError.signInOrThisDeviceOnly:
            return ProtectionCopy.signedOutChoiceBody
        case PostureSwitchError.thisDeviceOnlyWhileSignedIn:
            return ProtectionCopy.thisDeviceOnlySignedInSince
        case PostureSwitchError.syncKeysNotForgotten:
            return ProtectionCopy.thisDeviceOnlyForgetRefused
        case is URLError:
            return serverUnreachable
        default:
            return EncryptionSession.message(for: error)
        }
    }
}
