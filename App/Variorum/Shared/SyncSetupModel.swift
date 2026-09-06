//
//  SyncSetupModel.swift
//  Variorum (shared: Mac + Mobile — SYNC SETUP's brain; the Encryption tab's
//  `.noVault` arm renders it on both platforms through `SyncSetupView`)
//
//  pre-13x batch 3a — TURNING ON SYNC (copy §2a, verbatim through
//  `ProtectionCopy`; the postures design decision 5, §5's Set-up-sync row,
//  corners 26/27, ledger 27). The phases in the copy's order: the pre-Screen-1
//  confirm when this library last synced under ANOTHER account (*Move It to
//  This Account* — the adopt road runs right after the create) → Screen 1
//  (what sync needs + the posture addendum, from the LIBRARY's OWN posture —
//  the first device gives the vault its shape) → Screen 2 the passphrase (ONE
//  secret: a library with a passphrase makes the user TYPE it, verified
//  against the key file; else set it, ≥ 12 and matched) → Screen 3 the words
//  through the shared `WordsCeremony` (existing: typed and verified against
//  the key file, or generated anew — the file's copy replaced; none:
//  generated, written down, confirmed by exact re-entry) → the create — ONE
//  core road, the vault born with P, W and (Standard) the Apple-held copy —
//  → Screen 4 done. A vault is never born without its recovery wrap.
//

import Foundation
import Observation
import VariorumCore

@MainActor
@Observable
final class SyncSetupModel: Identifiable {
    enum Phase: Equatable {
        /// Reading the store's facts and the owner verdict.
        case checking
        /// Copy §2a's pre-Screen-1 confirm (a foreign owner's rows).
        case confirmMove
        /// Screen 1.
        case explain
        /// Screen 2: `existing` ⇒ TYPE the library's passphrase; else set it.
        case passphrase(existing: Bool)
        /// Screen 3 / 3b (mirrored from the shared `WordsCeremony`).
        case wordsExisting
        case wordsType
        case wordsShow([String])
        case wordsConfirm([String])
        /// The create.
        case creating
        /// Screen 4: the posture's sentence.
        case done(Posture)
        case failed(String)
        case closed
    }

    /// What the store says before Screen 1.
    struct Facts: Equatable {
        var libraryPosture: Posture
        var hasPassphrase: Bool
        var hasRecoveryWords: Bool
        var foreignOwner: Bool
    }

    let id = UUID()
    private(set) var phase: Phase = .checking
    private(set) var busy = false
    var lastError: String?
    private(set) var facts: Facts?
    private(set) var copiedWords = false

    private let encryption: EncryptionSession
    private let tie: StoreTie
    private let foreignOwner: @MainActor () async -> Bool
    private let adopt: @MainActor () async throws -> Void
    private var passphraseInHand: String?
    private var words: WordsCeremony?
    private var adoptAfterCreate = false

    init(
        encryption: EncryptionSession, tie: StoreTie,
        foreignOwner: @escaping @MainActor () async -> Bool,
        adopt: @escaping @MainActor () async throws -> Void
    ) {
        self.encryption = encryption
        self.tie = tie
        self.foreignOwner = foreignOwner
        self.adopt = adopt
    }

    /// The production composition: the session's store tie (wired by
    /// `wireOneSecretHooks`), the services' owner verdict and adopt road.
    /// nil while no store tie is wired (an unconfigured composition).
    static func make(services: AppServices) -> SyncSetupModel? {
        guard let tie = services.encryption.storeTie else { return nil }
        return SyncSetupModel(
            encryption: services.encryption, tie: tie,
            foreignOwner: { await services.libraryOwnerIsForeign() },
            adopt: { try await services.adoptLibraryAfterSetup() })
    }

    /// The words on screen, for the faces (Screen 3).
    var wordsRegenerated: Bool { words?.regenerated ?? false }

    // MARK: - The door

    func start() async {
        guard case .checking = phase else { return }
        busy = true
        defer { busy = false }
        let read = Facts(
            libraryPosture: tie.libraryPosture(),
            hasPassphrase: tie.hasPassphrase(),
            hasRecoveryWords: tie.hasRecoveryWords(),
            foreignOwner: await foreignOwner())
        facts = read
        phase = read.foreignOwner ? .confirmMove : .explain
    }

    /// *Move It to This Account* — the adopt road runs after the create.
    func confirmMove() {
        guard case .confirmMove = phase else { return }
        adoptAfterCreate = true
        phase = .explain
    }

    // MARK: - Screen 1 → 2

    func continueFromExplain() {
        guard case .explain = phase else { return }
        phase = .passphrase(existing: facts?.hasPassphrase ?? tie.hasPassphrase())
    }

    // MARK: - Screen 2: the passphrase (one secret)

    /// `existing`: the library's passphrase TYPED, verified against the key
    /// file (wrong ⇒ copy §2a's sentence); else SET: ≥ 12 characters, the
    /// two entries matched, landed on the key file.
    func submitPassphrase(_ typed: String, confirmation: String?) async {
        guard case .passphrase(let existing) = phase, !busy else { return }
        lastError = nil
        busy = true
        defer { busy = false }
        if existing {
            guard !typed.isEmpty else {
                lastError = ProtectionCopy.message(for: StoreKeyEnvelopeError.emptyPassphrase)
                return
            }
            switch await tie.verifyPassphrase(typed) {
            case true?: break
            case false?:
                lastError = ProtectionCopy.passphraseNotTheLibrarys
                return
            case nil:
                // No wrap after all (the facts moved under us): set it.
                if let refusal = await tie.setPassphrase(typed) { lastError = refusal; return }
            }
        } else {
            guard typed.count >= 12 else {
                lastError = ProtectionCopy.passphraseTooShort
                return
            }
            guard typed == (confirmation ?? "") else {
                lastError = ProtectionCopy.passphraseMismatch
                return
            }
            if let refusal = await tie.setPassphrase(typed) {
                lastError = refusal
                return
            }
        }
        passphraseInHand = typed
        advanceToWords()
    }

    // MARK: - Screen 3: the twelve words (the shared brain)

    private func advanceToWords() {
        do {
            words = try WordsCeremony(wordsExist: facts?.hasRecoveryWords ?? tie.hasRecoveryWords())
            mirrorWords()
        } catch {
            phase = .failed(EncryptionSession.message(for: error))
        }
    }

    private func mirrorWords() {
        guard let words else { return }
        switch words.step {
        case .existing: phase = .wordsExisting
        case .typeExisting: phase = .wordsType
        case .show(let shown): phase = .wordsShow(shown)
        case .confirm(let shown): phase = .wordsConfirm(shown)
        case .done: Task { await create() }
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
            phase = .failed(EncryptionSession.message(for: error))
        }
    }

    /// The library's existing words, typed — verified against the key file.
    func submitExistingWords(_ typed: String) async {
        guard case .wordsType = phase, !busy, let words else { return }
        lastError = nil
        busy = true
        defer { busy = false }
        let ok = await words.submitExisting(typed) { text in
            switch await tie.verifyRecoveryWords(text) {
            case true?: return .match
            case false?: return .mismatch(ProtectionCopy.message(for: StoreKeyEnvelopeError.wrongRecoveryPhrase))
            case nil: return .match  // no copy to check against — the words become the library's at the land
            }
        }
        guard ok else { lastError = words.lastError; return }
        mirrorWords()
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

    // MARK: - The create (ONE core road) → Screen 4

    private func create() async {
        guard let passphrase = passphraseInHand, let inHand = words?.wordsInHand else {
            phase = .failed(ProtectionCopy.message(for: StoreKeyEnvelopeError.emptyPassphrase))
            return
        }
        guard !busy else { return }
        busy = true
        defer { busy = false }
        phase = .creating
        await encryption.setUp(passphrase: passphrase, recoveryWords: inHand)
        if let refusal = encryption.lastError {
            phase = .failed(refusal)
            return
        }
        if adoptAfterCreate {
            do {
                try await adopt()
            } catch {
                phase = .failed(EncryptionSession.message(for: error))
                return
            }
        }
        phase = .done(facts?.libraryPosture ?? tie.libraryPosture())
    }

    func close() {
        phase = .closed
    }
}
