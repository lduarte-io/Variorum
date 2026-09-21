//
//  PassphraseSetModel.swift
//  Variorum (shared: Mac + Mobile — the set-screen's BRAIN)
//
//  Phase 13p, Batch 4 — HOISTED out of the Mac's `ProtectionPane.swift`
//  (MobileSoul §3: brains in core or `Shared/`, faces per platform; a
//  capability built Mac-side with its brain in app-local code is a parity
//  defect at birth). Batch 2 built the model and the Mac's sheet in one
//  file because only one face existed; the phone's set-screen composes
//  THIS model rather than a copy of it, so knot 4's one-moment-two-
//  artifacts choreography and R13p-4's one-secret verification are
//  written once and can never diverge between the two apps.
//
//  Nothing about the model changed in the hoist — the Mac's suite rides
//  unmodified, which is the hoist's own proof (the 3C parity pattern).
//
//  THE CHOREOGRAPHY (knot 4): set the passphrase, and the recovery phrase
//  generates and displays ON THAT SAME SCREEN. Where a VAULT exists
//  (signed in, 14b), one-secret binds: the typed passphrase must BE the
//  vault's (verified by the real read-only unwrap; offline refuses
//  honestly rather than letting two passphrases exist), and an existing
//  vault phrase is EXTENDED by typing it, never replaced by a fresh one.
//

import SwiftUI
import VariorumCore

// MARK: - The vault tie (one secret, R13p-4)

/// What the set-sheet needs to know about the account's vault. nil = no
/// vault in play (signed out / unconfigured / no vault row) — the store
/// mints its own artifacts freely.
@MainActor
struct VaultTie {
    enum Verify: Equatable {
        case match
        case mismatch(String)
        case couldNotCheck(String)
    }

    let hasRecoveryWrap: Bool
    let verifyPassphrase: (String) async -> Verify
    let verifyRecoveryWords: (String) async -> Verify
    /// pre-13x 3b: the CHANGE-PASSPHRASE act over the account's vault — the
    /// Replace All Keys ceremony's *Also choose a new passphrase* runs it on
    /// the NEW vault after the rotation (the current passphrase authorizes;
    /// the key file's copy follows under the vault's new descriptor through
    /// the session's landing). nil = no act wired (a scripted tie).
    var changePassphrase: ((_ current: String, _ new: String) async throws -> Void)? = nil
    /// pre-13x 4a (ledger 53): the vault's CURRENT recovery-wrap digest (one
    /// authenticated read; nil = unreadable / no wrap) — the phrase step
    /// records it beside the W copy it lands, so a device that typed the
    /// account's words never owes itself the words-regenerated notice.
    var readRecoveryWrapDigest: (() async -> String?)? = nil
    /// **RUN A batch A2, row 15 (KnownIssues 32): nil = the vault can be
    /// consulted.** A reason here means a vault EXISTS that this build
    /// cannot READ (`.newerFormat`) — the one world left in which
    /// `hasRecoveryWrap` reads false while a vault stands, since after
    /// pre-13x 3a every production road births the wrap with the vault.
    /// Defaulted so every existing construction site rides unmodified.
    var unreadableReason: String? = nil

    /// Built from the running services; nil when no vault constrains.
    static func make(services: AppServices?) -> VaultTie? {
        guard let services, let client = services.keyVault else { return nil }
        let encryption = services.encryption
        let change: (String, String) async throws -> Void = { current, new in
            await encryption.changePassphrase(authorization: .passphrase(current), newPassphrase: new)
            if let refusal = encryption.lastError { throw KeyDoorRefusal(refusal) }
        }
        switch services.encryption.state {
        case .signedOut, .noVault, .unknown:
            return nil
        case .newerFormat:
            // A vault EXISTS but this build cannot read it — one-secret
            // cannot verify, so the tie refuses rather than letting a
            // second passphrase slip in under the unreadable one.
            let reason = "your account's vault was written by a newer Variorum — update the app"
            let refusal = VaultTie.Verify.couldNotCheck(reason)
            return VaultTie(
                hasRecoveryWrap: false,
                verifyPassphrase: { _ in refusal },
                verifyRecoveryWords: { _ in refusal },
                // Row 15: `hasRecoveryWrap: false` here does NOT mean the
                // account has no words — it means this build cannot tell.
                unreadableReason: reason)
        case .enrolled(let hasRecovery),
             .notEnrolled(let hasRecovery), .keysReplaced(let hasRecovery):
            return VaultTie(
                hasRecoveryWrap: hasRecovery,
                verifyPassphrase: { passphrase in
                    let enrollment = VaultEnrollment(client: client)
                    do {
                        // Read-only: the material is discarded on the spot
                        // (the SecretCheck contract).
                        _ = try await enrollment.enroll(passphrase: passphrase)
                        return .match
                    } catch VaultEnrollmentError.wrongPassphrase {
                        return .mismatch(
                            "That isn't your account's encryption passphrase — and one "
                            + "passphrase serves both your account and this library.")
                    } catch {
                        return .couldNotCheck(EncryptionSession.message(for: error))
                    }
                },
                verifyRecoveryWords: { text in
                    let enrollment = VaultEnrollment(client: client)
                    do {
                        _ = try await enrollment.enroll(
                            recoveryWords: EncryptionSession.words(from: text))
                        return .match
                    } catch VaultEnrollmentError.wrongRecoveryPhrase {
                        return .mismatch("Those aren't your account's twelve words.")
                    } catch {
                        return .couldNotCheck(EncryptionSession.message(for: error))
                    }
                },
                changePassphrase: change,
                readRecoveryWrapDigest: { (try? await client.fetchVault())?.format.recoveryWrapDigest })
        }
    }
}

// MARK: - The set-sheet's model (knot 4: one moment, two artifacts)

@MainActor
@Observable
final class PassphraseSetModel {
    enum Phase: Equatable {
        /// Type + confirm the passphrase.
        case enterPassphrase
        /// The fresh twelve words are ON SCREEN — the one moment they
        /// exist outside the user's own writing-down.
        case showPhrase([String])
        /// A vault phrase already exists (one secret: never a second
        /// one) — offer typing it to extend it over this library;
        /// skippable.
        case extendExistingPhrase
        case done
    }

    private(set) var phase: Phase
    private(set) var busy = false
    var lastError: String?

    private let controller: ProtectionController
    private let vaultTie: VaultTie?

    /// `startingAt` (ladder R2-m1): the nudge's direct phrase offer opens
    /// the sheet straight at `.extendExistingPhrase` when the vault
    /// already carries the twelve words — see `PhraseOffer`. Defaulted so
    /// every existing call site (and the Mac suite's pins) rides
    /// unmodified.
    init(
        controller: ProtectionController, vaultTie: VaultTie?,
        startingAt phase: Phase = .enterPassphrase
    ) {
        self.controller = controller
        self.vaultTie = vaultTie
        self.phase = phase
    }

    var vaultConstrains: Bool { vaultTie != nil }

    func commit(passphrase: String, confirmation: String) async {
        guard !busy else { return }
        lastError = nil
        guard !passphrase.isEmpty else {
            lastError = "Type a passphrase first."
            return
        }
        // RUN A batch A2, row 14 (17n): THE FLOOR. This sheet is the
        // Settings ▸ Protection set door on the Mac AND the phone's two
        // (the nudge's offer and the Protection sheet) — four door sites,
        // one model — and it was the one SETTING road with no length rule
        // at all, so a five-character passphrase could become the secret an
        // offline attacker guesses against at the shipped KDF floor.
        guard passphrase.count >= ProtectionCopy.passphraseFloor else {
            lastError = ProtectionCopy.passphraseTooShort
            return
        }
        guard passphrase == confirmation else {
            lastError = "The two entries don't match."
            return
        }
        busy = true
        defer { busy = false }
        // ONE SECRET: where a vault exists, the typed passphrase must BE
        // its passphrase — verified by the real unwrap; an unreachable
        // vault refuses rather than letting a second passphrase exist.
        if let vaultTie {
            switch await vaultTie.verifyPassphrase(passphrase) {
            case .match:
                break
            case .mismatch(let message):
                lastError = message
                return
            case .couldNotCheck(let reason):
                lastError = "Couldn't verify against your account's vault (\(reason)) — "
                    + "one passphrase serves both, so setting it waits until it can check."
                return
            }
        }
        if let refusal = await controller.setPassphrase(passphrase) {
            lastError = refusal
            return
        }
        advanceToPhraseHalf()
    }

    private func advanceToPhraseHalf() {
        if controller.hasRecoveryWrap {
            phase = .done  // both artifacts already in hand
            return
        }
        if let vaultTie, vaultTie.hasRecoveryWrap {
            // The twelve words already exist on the account — extend
            // THEM; never mint a second phrase (one secret).
            phase = .extendExistingPhrase
            return
        }
        Task { [weak self] in
            guard let self else { return }
            busy = true
            defer { busy = false }
            if let words = await controller.generateAndLandRecoveryPhrase() {
                phase = .showPhrase(words)
            } else {
                lastError = controller.lastError
                phase = .done
            }
        }
    }

    /// The extend road: the account's existing words, typed, verified
    /// against the vault, then landed on the store envelope too.
    func extendPhrase(typed: String) async {
        guard !busy else { return }
        lastError = nil
        busy = true
        defer { busy = false }
        if let vaultTie {
            switch await vaultTie.verifyRecoveryWords(typed) {
            case .match: break
            case .mismatch(let message):
                lastError = message
                return
            case .couldNotCheck(let reason):
                lastError = "Couldn't check the words against your account (\(reason))."
                return
            }
        }
        // pre-13x 4a (ledger 53): the words were verified against the vault
        // above — record the vault's wrap digest beside the copy.
        let digest = await vaultTie?.readRecoveryWrapDigest?()
        if let refusal = await controller.landRecoveryWrap(
            words: EncryptionSession.words(from: typed), recoveryWrapDigest: digest) {
            lastError = refusal
            return
        }
        phase = .done
    }

    func skipPhrase() {
        phase = .done
    }

    func acknowledgePhraseWritten() {
        phase = .done
    }
}

// MARK: - The nudge's direct phrase offer (ladder R2-m1 — one flow, both platforms)

/// **THE NUDGE'S "take the recovery phrase" OFFER, routed (ladder
/// R2-m1).** Until this fix both notice bars called
/// `generateAndLandRecoveryPhrase()` directly, gated only on the STORE's
/// own wrap — so a vault-enrolled user whose account already carried the
/// twelve words got a SECOND, different phrase fresh-minted over them,
/// exactly the divergence the set-screen's own `.extendExistingPhrase`
/// routing exists to prevent (one secret, R13p-4: never a second phrase).
///
/// The rule, written once for both platforms: the offer consults the
/// vault tie FIRST — a vault that carries a recovery wrap routes to the
/// EXTEND flow (the set-sheet opened straight at
/// `.extendExistingPhrase`); only a vault-free (or wrap-free) world
/// fresh-mints and hands the words back for display.
@MainActor
enum PhraseOffer {
    enum Outcome {
        /// The account's twelve words already exist — extend THEM over
        /// this library (the sheet renders the extend flow); never a
        /// second phrase.
        case extend(PassphraseSetModel)
        /// No vault phrase constrains — fresh words, landed on the store
        /// envelope, handed back for the one display.
        case minted([String])
        /// Refused (worded in the controller's `lastError`, exactly as
        /// the direct call always was).
        case refused
    }

    static func take(
        controller: ProtectionController, vaultTie: VaultTie?
    ) async -> Outcome {
        if let vaultTie, vaultTie.hasRecoveryWrap {
            return .extend(PassphraseSetModel(
                controller: controller, vaultTie: vaultTie,
                startingAt: .extendExistingPhrase))
        }
        // RUN A batch A2, row 15 (KnownIssues 32 — the phrase-transit
        // corner's ONE surviving world). After pre-13x 3a every production
        // road births the vault WITH its recovery wrap, so a vault that
        // reports none is a vault this build cannot READ — and minting
        // twelve store-only words under it is the transit the row names:
        // the account's own generation later overwrites the store's
        // recovery leg and the first phrase she wrote down stops opening
        // the library with nothing said. The tie's own doctrine for the
        // passphrase ("refuses rather than letting a second passphrase slip
        // in under the unreadable one") is the doctrine for the words too.
        //
        // The passphrase door cannot reach this — `commit` refuses on
        // `.couldNotCheck` before `advanceToPhraseHalf`, which is private to
        // it. This offer is the one door that starts at the phrase half.
        if let vaultTie, let reason = vaultTie.unreadableReason {
            controller.lastError = refusalUnderAnUnreadableVault(reason)
            return .refused
        }
        if let words = await controller.generateAndLandRecoveryPhrase() {
            return .minted(words)
        }
        return .refused
    }

    /// Row 15's sentence — the twin of `commit`'s own couldNotCheck line,
    /// in the words' nouns. PROVISIONAL; 13s re-voices (QUESTIONS #138).
    static func refusalUnderAnUnreadableVault(_ reason: String) -> String {
        "Couldn't check your account for recovery words (\(reason)) — one set of words "
        + "serves both, so making them waits until it can check."
    }
}


extension PassphraseSetModel: Identifiable {}

/// pre-13x 3b: a key door's worded refusal carried as an error (the
/// session speaks refusals into `lastError`; a ceremony's act needs a throw).
nonisolated struct KeyDoorRefusal: Error, CustomStringConvertible, Equatable {
    let description: String
    init(_ description: String) { self.description = description }
}
