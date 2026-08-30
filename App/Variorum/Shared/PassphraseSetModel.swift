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

    /// Built from the running services; nil when no vault constrains.
    static func make(services: AppServices?) -> VaultTie? {
        guard let services, let client = services.keyVault else { return nil }
        switch services.encryption.state {
        case .signedOut, .noVault, .unknown:
            return nil
        case .newerFormat:
            // A vault EXISTS but this build cannot read it — one-secret
            // cannot verify, so the tie refuses rather than letting a
            // second passphrase slip in under the unreadable one.
            let refusal = VaultTie.Verify.couldNotCheck(
                "your account's vault was written by a newer Variorum — update the app")
            return VaultTie(
                hasRecoveryWrap: false,
                verifyPassphrase: { _ in refusal },
                verifyRecoveryWords: { _ in refusal })
        case .enrolled(let hasRecovery), .enrolledLocked(let hasRecovery),
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
                })
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

    private(set) var phase: Phase = .enterPassphrase
    private(set) var busy = false
    var lastError: String?

    private let controller: ProtectionController
    private let vaultTie: VaultTie?

    init(controller: ProtectionController, vaultTie: VaultTie?) {
        self.controller = controller
        self.vaultTie = vaultTie
    }

    var vaultConstrains: Bool { vaultTie != nil }

    func commit(passphrase: String, confirmation: String) async {
        guard !busy else { return }
        lastError = nil
        guard !passphrase.isEmpty else {
            lastError = "Type a passphrase first."
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
        if let refusal = await controller.landRecoveryWrap(
            words: EncryptionSession.words(from: typed)) {
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


extension PassphraseSetModel: Identifiable {}
