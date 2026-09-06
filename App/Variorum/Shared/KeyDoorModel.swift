//
//  KeyDoorModel.swift
//  Variorum (shared: Mac + Mobile — the two RE-WRAP doors' ONE brain)
//
//  pre-13x batch 3b — CHANGE PASSPHRASE and REGENERATE TWELVE WORDS (copy
//  §4, verbatim through `ProtectionCopy`; the postures design decisions 9 ·
//  10 · 25; §5's two rows; §3.6's derive-once; §13 — the 13p reset door
//  MERGED into change passphrase's forgot road). Both are CONVENIENCE acts —
//  a re-wrap of the SAME keys under a new word; other devices keep syncing
//  and take the new word at once online (the vault road, batch 4's lobby
//  half); the security act is Replace All Keys, one checkbox away.
//
//  THE ORDER (both kinds): the OFFLINE check first for an enrolled library
//  (a vault fetch before any field — every key door is an online act for
//  an enrolled library, decision 9; a local-only library changes its
//  passphrase offline) → the authorization — the current passphrase
//  verified against the VAULT's copy by the core act itself (a retired word
//  is refused with copy §5's sentence when the key file's recorded
//  descriptor is no longer the vault's), with the forgot road by posture:
//  Standard — the plain confirm (this device holds the keys); Castle + Touch
//  ID / Face ID — the presence confirm; Castle + Always ask — the twelve
//  words (you typed the passphrase to get in) → the act → the landing: the
//  key file's copy under the SAME descriptor the vault's new wrap uses
//  (`EncryptionSession.changePassphrase` / `rewrapPassphrase` → the landing
//  hook → `reconcilePassphraseWrap(vaultKDF:)`) → the checkbox *Also
//  replace my keys* hands the NEW secret to Replace All Keys.
//

import Foundation
import Observation
import VariorumCore

/// What the doors need from the library's controller, as closures (the
/// `StoreTie` pattern): the posture and gate the forgot road reads, the
/// presence confirm, the local-only roads, the key file's recorded
/// descriptor. Wired once by `wireOneSecretHooks`.
nonisolated struct KeyDoorFacts: Sendable {
    var posture: @MainActor () -> Posture
    var gate: @MainActor () -> StoreAtOpenMode
    var biometryAvailable: @MainActor () -> Bool
    /// The key file's recorded vault descriptor (nil = never reconciled).
    var keyFileVaultKDF: @MainActor () -> PassphraseKDF.Descriptor?
    /// Touch ID / Face ID — PROMPTS in production; scripted in tests.
    var confirmPresence: @MainActor (String) async -> Bool
    /// The LOCAL-ONLY roads (no vault): the key file's own wraps.
    var verifyLocalPassphrase: @MainActor (String) async -> Bool?
    var verifyLocalWords: @MainActor (String) async -> Bool?
    /// Returns the worded refusal, nil = landed.
    var setLocalPassphrase: @MainActor (String) async -> String?
}

@MainActor
@Observable
final class KeyDoorModel: Identifiable {
    enum Kind: Equatable, Sendable {
        case changePassphrase
        case regenerateWords
    }

    enum Phase: Equatable {
        /// The offline check (enrolled: a vault fetch before any field).
        case checking
        /// Change: current · new · confirm (+ the forgot link). Regenerate:
        /// the current passphrase (+ the forgot link).
        case authorize
        /// Standard's forgot road — the plain confirm; then new · confirm.
        case forgotStandard
        /// Castle + Touch ID / Face ID — the presence confirm; then new · confirm.
        case forgotBiometric
        /// Castle + Always ask (or no biometry) — the twelve words authorize.
        case forgotWords
        /// Regenerate: the fresh words shown ONCE, then confirmed by re-entry.
        case wordsShow([String])
        case wordsConfirm([String])
        case done
        case failed(String)
        case closed
    }

    let id = UUID()
    let kind: Kind
    private(set) var phase: Phase = .checking
    private(set) var busy = false
    var lastError: String?
    /// Copy §4's checkbox — *Also replace my keys*: the NEW secret is
    /// handed to Replace All Keys after this door's act lands.
    var alsoReplaceKeys = false
    private(set) var copiedWords = false

    private let encryption: EncryptionSession
    private let facts: KeyDoorFacts
    /// The vault-verified READ-ONLY check (regenerate's authorization —
    /// `VaultTie.make`'s closure); nil = no vault constrains.
    private let verifyVaultPassphrase: ((String) async -> VaultTie.Verify)?
    private let verifyVaultWords: ((String) async -> VaultTie.Verify)?
    /// Replace All Keys' door with the new secret in hand (`EncryptionSession
    /// .replaceKeysDoor`); nil = the checkbox is not offered (P-2).
    private let openReplaceKeys: ((_ passphrase: String?, _ words: [String]?) -> Void)?
    /// The vault's descriptor and wrap as fetched at the door (enrolled).
    private var vaultKDF: PassphraseKDF.Descriptor?
    private var words: WordsCeremony?
    /// Regenerate: the authorization already given (the current word, the
    /// presence confirm, or the words) — the land needs no second one.
    private var authorized = false

    init(
        kind: Kind, encryption: EncryptionSession, facts: KeyDoorFacts,
        verifyVaultPassphrase: ((String) async -> VaultTie.Verify)? = nil,
        verifyVaultWords: ((String) async -> VaultTie.Verify)? = nil,
        openReplaceKeys: ((String?, [String]?) -> Void)? = nil
    ) {
        self.kind = kind
        self.encryption = encryption
        self.facts = facts
        self.verifyVaultPassphrase = verifyVaultPassphrase
        self.verifyVaultWords = verifyVaultWords
        self.openReplaceKeys = openReplaceKeys
    }

    /// The production composition: the session's facts (wired by
    /// `wireOneSecretHooks`), the vault tie's read-only checks, the root's
    /// Replace All Keys door. nil while no facts are wired.
    static func make(kind: Kind, services: AppServices) -> KeyDoorModel? {
        guard let facts = services.encryption.keyDoorFacts else { return nil }
        let tie = VaultTie.make(services: services)
        return KeyDoorModel(
            kind: kind, encryption: services.encryption, facts: facts,
            verifyVaultPassphrase: tie?.verifyPassphrase,
            verifyVaultWords: tie?.verifyRecoveryWords,
            openReplaceKeys: services.encryption.replaceKeysDoor)
    }

    /// Whether the account's vault constrains this door (an enrolled library).
    var enrolled: Bool {
        if case .enrolled = encryption.state { return true }
        return false
    }
    var offersReplaceKeys: Bool { enrolled && openReplaceKeys != nil }
    /// Whether the door speaks its offline sentence (enrolled) — for the faces.
    var isEnrolledDoor: Bool { enrolled }
    /// The forgot road this posture offers: Standard's plain confirm, Castle's
    /// Touch ID / Face ID confirm, or the words (Always ask / no biometry).
    var forgotRoad: Phase {
        if facts.posture() == .standard { return .forgotStandard }
        if facts.gate() == .biometric, facts.biometryAvailable() { return .forgotBiometric }
        return .forgotWords
    }
    /// Copy §4: under Always ask there is no link — the words are offered directly.
    var offersForgotLink: Bool { forgotRoad != .forgotWords }

    // MARK: - The door: the offline check first (decision 9)

    func start() async {
        guard case .checking = phase else { return }
        busy = true
        defer { busy = false }
        if enrolled {
            do {
                guard let fetched = try await encryption.fetchVaultFacts() else {
                    phase = .failed(EncryptionSession.message(for: KeyVaultClientError.vaultAbsent))
                    return
                }
                vaultKDF = fetched.kdf
            } catch {
                phase = .failed(error is URLError
                    ? ProtectionCopy.changePassphraseOffline
                    : EncryptionSession.message(for: error))
                return
            }
        }
        phase = .authorize
    }

    // MARK: - Change passphrase: the authorization + the act

    /// Change passphrase's screen: the current passphrase (verified against
    /// the VAULT's copy by the core act — a retired word worded as such),
    /// the new one (≥ 12, matched).
    func changePassphrase(current: String, new: String, confirmation: String) async {
        guard kind == .changePassphrase, case .authorize = phase, !busy else { return }
        lastError = nil
        guard !current.isEmpty else {
            lastError = ProtectionCopy.message(for: StoreKeyEnvelopeError.emptyPassphrase)
            return
        }
        guard let new = validated(new, confirmation: confirmation) else { return }
        busy = true
        defer { busy = false }
        if enrolled {
            await encryption.changePassphrase(authorization: .passphrase(current), newPassphrase: new)
            if let refusal = encryption.lastError {
                lastError = wordRetiredIfStale(refusal)
                return
            }
        } else {
            switch await facts.verifyLocalPassphrase(current) {
            case false?:
                lastError = ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongPassphrase)
                return
            case nil, true?:
                break
            }
            if let refusal = await facts.setLocalPassphrase(new) {
                lastError = refusal
                return
            }
        }
        finish(passphrase: new, words: nil)
    }

    /// The forgot link: the road this posture offers.
    func forgot() {
        guard case .authorize = phase else { return }
        lastError = nil
        phase = forgotRoad
    }

    /// Standard's forgot road (this device holds the keys): set the new
    /// passphrase — the vault's master re-wrapped from the HELD material
    /// (enrolled) or the key file's own wrap replaced (local-only).
    func resetPassphrase(new: String, confirmation: String) async {
        guard case .forgotStandard = phase, !busy else { return }
        lastError = nil
        guard let new = validated(new, confirmation: confirmation) else { return }
        busy = true
        defer { busy = false }
        await rewrap(new)
    }

    /// Castle + Touch ID / Face ID: the presence confirm, then the same.
    func resetPassphraseWithBiometrics(new: String, confirmation: String) async {
        guard case .forgotBiometric = phase, !busy else { return }
        lastError = nil
        guard let new = validated(new, confirmation: confirmation) else { return }
        busy = true
        defer { busy = false }
        guard await facts.confirmPresence("Confirm it's you to set a new passphrase") else {
            lastError = "Not confirmed — nothing was changed."
            return
        }
        await rewrap(new)
    }

    /// The twelve words authorize (Always ask; no biometry; the disaster road).
    func resetPassphraseWithWords(_ typed: String, new: String, confirmation: String) async {
        guard case .forgotWords = phase, kind == .changePassphrase, !busy else { return }
        lastError = nil
        let words = EncryptionSession.words(from: typed)
        do { _ = try RecoveryPhrase.recoveryWrapKey(words: words) } catch {
            lastError = EncryptionSession.message(for: error)
            return
        }
        guard let new = validated(new, confirmation: confirmation) else { return }
        busy = true
        defer { busy = false }
        if enrolled {
            await encryption.changePassphrase(authorization: .recoveryPhrase(words), newPassphrase: new)
            if let refusal = encryption.lastError { lastError = refusal; return }
        } else {
            guard await facts.verifyLocalWords(typed) != false else {
                lastError = ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongRecoveryPhrase)
                return
            }
            if let refusal = await facts.setLocalPassphrase(new) { lastError = refusal; return }
        }
        finish(passphrase: new, words: nil)
    }

    private func rewrap(_ new: String) async {
        if enrolled {
            if let refusal = await encryption.rewrapPassphrase(newPassphrase: new) {
                lastError = refusal
                return
            }
        } else if let refusal = await facts.setLocalPassphrase(new) {
            lastError = refusal
            return
        }
        finish(passphrase: new, words: nil)
    }

    // MARK: - Regenerate twelve words: the same authorization, then the words

    /// Regenerate's screen: the current passphrase, checked against the
    /// VAULT (read-only — the land itself needs no word, the device holds
    /// the keys); a retired word worded as such.
    func authorizeRegenerate(current: String) async {
        guard kind == .regenerateWords, case .authorize = phase, !busy else { return }
        lastError = nil
        guard !current.isEmpty else {
            lastError = ProtectionCopy.message(for: StoreKeyEnvelopeError.emptyPassphrase)
            return
        }
        busy = true
        defer { busy = false }
        guard let verify = verifyVaultPassphrase else {
            lastError = EncryptionSession.message(for: KeyVaultClientError.vaultAbsent)
            return
        }
        switch await verify(current) {
        case .match:
            authorized = true
            showFreshWords()
        case .mismatch:
            lastError = wordRetiredIfStale(EncryptionSession.message(for: VaultEnrollmentError.wrongPassphrase))
        case .couldNotCheck(let reason):
            lastError = "Couldn't verify against your account (\(reason))."
        }
    }

    /// Regenerate's forgot roads: Standard's plain confirm / Castle's
    /// presence confirm (the device holds the keys — the land needs none).
    func authorizeRegenerateByDevice() async {
        guard kind == .regenerateWords, !busy else { return }
        lastError = nil
        switch phase {
        case .forgotStandard:
            break
        case .forgotBiometric:
            busy = true
            defer { busy = false }
            guard await facts.confirmPresence("Confirm it's you to regenerate your twelve words") else {
                lastError = "Not confirmed — nothing was changed."
                return
            }
        default:
            return
        }
        authorized = true
        showFreshWords()
    }

    /// Regenerate under Always ask: the OLD words authorize the new ones.
    func authorizeRegenerateWithWords(_ typed: String) async {
        guard kind == .regenerateWords, case .forgotWords = phase, !busy else { return }
        lastError = nil
        busy = true
        defer { busy = false }
        guard let verify = verifyVaultWords else {
            lastError = EncryptionSession.message(for: KeyVaultClientError.vaultAbsent)
            return
        }
        switch await verify(typed) {
        case .match:
            authorized = true
            showFreshWords()
        case .mismatch(let message):
            lastError = message
        case .couldNotCheck(let reason):
            lastError = "Couldn't verify against your account (\(reason))."
        }
    }

    private func showFreshWords() {
        do {
            words = try WordsCeremony(wordsExist: false)
            mirrorWords()
        } catch {
            phase = .failed(EncryptionSession.message(for: error))
        }
    }

    private func mirrorWords() {
        guard let words else { return }
        switch words.step {
        case .show(let shown): phase = .wordsShow(shown)
        case .confirm(let shown): phase = .wordsConfirm(shown)
        case .done: Task { await landWords() }
        case .existing, .typeExisting: break
        }
    }

    func markWordsCopied() { copiedWords = true }

    func acknowledgeWordsWritten() {
        guard case .wordsShow = phase else { return }
        words?.acknowledgeWritten()
        mirrorWords()
    }

    /// Screen 3b: the exact re-entry.
    func confirmWords(_ typed: String) {
        guard case .wordsConfirm = phase, let words else { return }
        lastError = nil
        guard words.confirm(typed) else { lastError = words.lastError; return }
        mirrorWords()
    }

    /// The land: the vault's recovery wrap REPLACED (`allowReplace` — the
    /// deliberate step, authorized above) and the store's copy following.
    private func landWords() async {
        guard authorized, let inHand = words?.wordsInHand else {
            phase = .failed(EncryptionSession.message(for: RecoveryPhraseError.invalidWordCount(0)))
            return
        }
        guard !busy else { return }
        busy = true
        defer { busy = false }
        await encryption.landRecoveryWrap(confirmedWords: inHand, allowReplace: true)
        if let refusal = encryption.lastError {
            phase = .failed(refusal)
            return
        }
        finish(passphrase: nil, words: inHand)
    }

    // MARK: - The end: Done, or the checkbox's hand-off to Replace All Keys

    private func finish(passphrase: String?, words: [String]?) {
        if alsoReplaceKeys, let openReplaceKeys, enrolled {
            phase = .closed
            openReplaceKeys(passphrase, words)
        } else {
            phase = .done
        }
    }

    func close() { phase = .closed }

    // MARK: - Helpers

    private func validated(_ new: String, confirmation: String) -> String? {
        guard new.count >= 12 else {
            lastError = ProtectionCopy.passphraseTooShort
            return nil
        }
        guard new == confirmation else {
            lastError = ProtectionCopy.passphraseMismatch
            return nil
        }
        return new
    }

    /// A wrong current passphrase under an enrolled library: RETIRED (copy
    /// §5) when the key file's recorded descriptor is no longer the vault's
    /// — the word was changed elsewhere and this copy is stale; else the
    /// plain wrong-passphrase line.
    private func wordRetiredIfStale(_ refusal: String) -> String {
        guard refusal == EncryptionSession.message(for: VaultEnrollmentError.wrongPassphrase) else { return refusal }
        if let recorded = facts.keyFileVaultKDF(), let vaultKDF, recorded != vaultKDF {
            return ProtectionCopy.retiredPassphraseAtDoor
        }
        return refusal
    }
}
