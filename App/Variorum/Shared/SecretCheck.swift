//
//  SecretCheck.swift
//  Variorum (shared: Mac + Mobile — rendered on the Mac this phase)
//
//  Phase 13l, Act 5 (ledger row 18) — THE SANITY CHECK.
//
//  Her ask, verbatim (2026-08-19): *"a place where people can verify that
//  they still have their passcode or passphrase right without having to
//  reset something else, like a sanity check."*
//
//  WHY IT IS NEEDED AT ALL, which is also why it must not touch anything:
//  the 14b enrollment cadence (R-6) means neither secret is ever exercised
//  day to day — the device unwraps once and the Keychain carries it from
//  then on. A secret you never type is a secret you find out you have lost
//  at the worst possible moment. This face is the rehearsal, and it is the
//  exact twin of the restore drill: the drill proves a backup restores; this
//  proves the human still holds the key.
//
//  HOW IT VERIFIES — and there is no second mechanism, deliberately. It runs
//  the REAL unwrap: fetch the account's vault, derive the wrap key
//  (Argon2id, the vault's own stored parameters), and try to unwrap master.
//  AES key wrap (RFC 3394) authenticates, so a wrong secret cannot unwrap —
//  the attempt IS the verification. There is no stored hash of the
//  passphrase to compare against anywhere in this system, and there must
//  never be one: a comparable artifact is a thing an attacker can attack
//  offline, and a "verified" answer from anything other than the real unwrap
//  would be a guess wearing a checkmark.
//
//  WHAT IT NEVER DOES: it writes nothing. No vault update, no re-key, no
//  Keychain adoption, no reset, no state change of any kind, on this device
//  or on the account. It composes `VaultEnrollment` (core, 14b) READ-ONLY —
//  the returned key material is discarded on the spot — and it deliberately
//  does NOT go through `EncryptionSession.enroll`, whose whole job is to
//  adopt custody. That distinction is the one thing to preserve if this file
//  is ever edited.
//
//  BUILT AS A REUSABLE COMPONENT (the brief's instruction): Phase 13p's
//  reminder checks are ruled to point at THIS face — "one face serves both".
//  So the model knows nothing about where it is rendered, the words are a
//  `Framing` value the host supplies, and the section below is one view any
//  host can drop in. It lives in `Shared/` so the phone's twin is a face
//  over this same model, never a second implementation.
//

import SwiftUI
import VariorumCore

/// The words a host wraps the check in. 13p supplies its own (a reminder's
/// framing differs from a sanity check's) without touching the mechanism.
nonisolated struct SecretCheckFraming: Equatable {
    var headline: String
    var blurb: String

    /// 13l's own framing — the sanity check in Settings ▸ Encryption.
    static let sanityCheck = SecretCheckFraming(
        headline: "Check that you still have your secrets",
        blurb: "Type a secret and Variorum will try to unlock this account's vault with "
            + "it, then throw the result away. Nothing is changed, reset or re-sent — "
            + "this only answers yes or no.")
}

/// The check itself. Holds no custody, writes nothing, and knows nothing
/// about its host.
@MainActor
@Observable
final class SecretCheckModel {
    nonisolated enum Secret: Equatable, Sendable {
        case passphrase
        case recoveryPhrase

        var noun: String {
            switch self {
            case .passphrase: "encryption passphrase"
            case .recoveryPhrase: "recovery phrase"
            }
        }
    }

    nonisolated enum Result: Equatable, Sendable {
        /// It unwrapped the vault. This is the only positive answer, and it
        /// means what it says.
        case correct(Secret)
        /// It did not unwrap the vault. RFC 3394 makes a wrong key and a
        /// tampered wrap indistinguishable by design; the overwhelmingly
        /// likely cause is the typo, and the wording says so without
        /// pretending to certainty it doesn't have.
        case wrong(Secret)
        /// The check could not be run at all (offline, no vault, a phrase
        /// that fails its own checksum). NEVER conflated with `wrong` — "we
        /// couldn't ask" and "that isn't it" are different answers, and
        /// telling someone their passphrase is wrong when the network was
        /// down is how a person decides to reset something they didn't need
        /// to.
        case couldNotCheck(String)
    }

    private(set) var checking = false
    private(set) var result: Result?
    /// The measured Argon2id derivation, in seconds on this device — shown
    /// because the wait is deliberate and a number makes that legible rather
    /// than worrying (the 14b L12 surface's habit).
    private(set) var lastSeconds: Double?

    /// nil = the project is unconfigured (ProjectConfig keys empty) — the
    /// check stays dormant exactly like every other vault flow.
    private let client: KeyVaultClient?

    /// 13p Batch 2 — the LOCAL road's outcome vocabulary (the store-key
    /// envelope's read-only unwrap; see `storeCheck`).
    nonisolated enum LocalOutcome: Equatable, Sendable {
        case correct
        case wrong
        case couldNotCheck(String)
    }

    /// 13p Batch 2 (R13p-9 — "one face serves both"): when set, `check`
    /// runs THIS instead of the vault — the real unwrap of the STORE
    /// key's sidecar wraps, local and offline-capable, which is what the
    /// reminder checks (and a signed-out local-only user) need. The
    /// mechanism contract is identical: a real unwrap, result discarded,
    /// nothing written.
    private let storeCheck:
        (@Sendable (Secret, String) async -> LocalOutcome)?
    /// What a result sentence names as the thing the secret unlocked —
    /// the vault road's noun by default; the store road says the library.
    nonisolated let targetNoun: String

    init(
        client: KeyVaultClient?,
        storeCheck: (@Sendable (Secret, String) async -> LocalOutcome)? = nil,
        targetNoun: String = "this account's vault"
    ) {
        self.client = client
        self.storeCheck = storeCheck
        self.targetNoun = targetNoun
    }

    var isAvailable: Bool { client != nil || storeCheck != nil }

    /// Runs the real unwrap and throws the keys away.
    ///
    /// The Argon2id derivation happens inside `VaultEnrollment`'s
    /// `nonisolated async` methods — OFF the main actor by construction (its
    /// own header states the contract) — so the UI stays responsive through
    /// the deliberate wait. `checking` is what the surface renders meanwhile.
    func check(_ secret: Secret, entry: String) async {
        guard !checking else { return }
        let trimmedEntry = entry.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEntry.isEmpty else { return }
        // 13p: the local store road, when composed (the reminder face and
        // the signed-out user) — same contract, no network, no vault.
        if let storeCheck {
            checking = true
            result = nil
            defer { checking = false }
            switch await storeCheck(secret, trimmedEntry) {
            case .correct: result = .correct(secret)
            case .wrong: result = .wrong(secret)
            case .couldNotCheck(let reason): result = .couldNotCheck(reason)
            }
            return
        }
        guard let client else {
            result = .couldNotCheck("Encryption isn't configured in this build.")
            return
        }
        let trimmed = trimmedEntry
        checking = true
        result = nil
        defer { checking = false }
        let enrollment = VaultEnrollment(client: client, kdfMeasurement: { seconds in
            Task { @MainActor [weak self] in self?.lastSeconds = seconds }
        })
        do {
            switch secret {
            case .passphrase:
                // `_ =` is the whole point: the material this returns is
                // dropped here and never reaches the Keychain. Do not
                // "improve" this by routing through EncryptionSession.
                _ = try await enrollment.enroll(passphrase: trimmed)
            case .recoveryPhrase:
                _ = try await enrollment.enroll(
                    recoveryWords: EncryptionSession.words(from: trimmed))
            }
            result = .correct(secret)
        } catch VaultEnrollmentError.wrongPassphrase {
            result = .wrong(.passphrase)
        } catch VaultEnrollmentError.wrongRecoveryPhrase {
            result = .wrong(.recoveryPhrase)
        } catch KeyVaultError.recoveryWrapAbsent {
            // Unreachable from the surface below (it offers the phrase road
            // only where a wrap exists), but worded rather than left to the
            // raw-enum default: a refusal that dumps a case name is the one
            // thing the R94 doctrine forbids.
            result = .couldNotCheck(
                "This account has no recovery phrase on file yet — generate one first.")
        } catch {
            result = .couldNotCheck(EncryptionSession.message(for: error))
        }
    }

    func reset() {
        result = nil
    }

    // MARK: - The answers, as sentences (pinned; 13s owns the voice)

    nonisolated static func message(for result: Result) -> String {
        message(for: result, target: "this account's vault")
    }

    /// 13p Batch 2: the noun parameterizes so the local store road says
    /// what it actually unlocked; the vault default keeps the 13l pins.
    nonisolated static func message(for result: Result, target: String) -> String {
        switch result {
        case .correct(let secret):
            return "That is the right \(secret.noun) — it unlocked \(target). "
                + "Nothing was changed."
        case .wrong(let secret):
            return "That did not unlock \(target). Check the \(secret.noun) "
                + "and try again — nothing was changed, and nothing is locked out by "
                + "getting it wrong here."
        case .couldNotCheck(let reason):
            return "Couldn't check: \(reason)"
        }
    }

    /// The instance form the section renders — this model's own noun.
    nonisolated func message(for result: Result) -> String {
        Self.message(for: result, target: targetNoun)
    }

    /// Why the wait is there, said before it starts rather than after.
    nonisolated static let slowOnPurpose =
        "This takes a few seconds on purpose: turning a passphrase into a key is "
        + "deliberately slow, which is what makes guessing it expensive."
}

// MARK: - The section (one view; any host drops it in)

/// The check's face. Hosts supply the framing and say whether the recovery
/// phrase road is offerable here; everything else is this view's.
struct SecretCheckSection: View {
    let framing: SecretCheckFraming
    /// False when the account carries no recovery wrap — the road is not
    /// rendered at all rather than rendered and refused (P-2).
    let offersRecoveryPhrase: Bool
    @Bindable var model: SecretCheckModel
    /// D1: the phone's styling seam (nil on the Mac ALWAYS).
    @Environment(\.sharedPageStyle) private var pageStyle

    @State private var secret: SecretCheckModel.Secret = .passphrase
    @State private var entry = ""

    var body: some View {
        PageHeading(framing.headline, style: pageStyle)
        Text(framing.blurb)
            .pageCaption(pageStyle)
            .fixedSize(horizontal: false, vertical: true)
        if offersRecoveryPhrase {
            Picker("What to check", selection: $secret) {
                Text("Encryption passphrase").tag(SecretCheckModel.Secret.passphrase)
                Text("Recovery phrase").tag(SecretCheckModel.Secret.recoveryPhrase)
            }
            .pickerStyle(.segmented)
            .onChange(of: secret) {
                entry = ""
                model.reset()
            }
        }
        entryField
        PageDoor("Check", style: pageStyle) {
            let typed = entry
            entry = ""
            Task { await model.check(secret, entry: typed) }
        }
        .disabled(model.checking || entry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        if model.checking {
            HStack(spacing: 6) {
                ProgressView().controlSize(.small)
                Text("Checking…").pageCaption(pageStyle)
            }
        }
        Text(SecretCheckModel.slowOnPurpose)
            .pageCaption(pageStyle)
            .fixedSize(horizontal: false, vertical: true)
        if let result = model.result {
            resultLine(result)
        }
    }

    @ViewBuilder
    private var entryField: some View {
        switch secret {
        case .passphrase:
            PeekableSecretField(label: "Encryption passphrase", text: $entry)
                .pageFieldChrome(pageStyle)
        case .recoveryPhrase:
            // The `EncryptionView.phraseEntryField` shape: autocorrect off,
            // and on the phone auto-capitals off too — the words are
            // lowercase, validation folds case, but a capitalized first word
            // READS as a wrong entry.
            phraseField
        }
    }

    private var phraseField: some View {
        let field = TextField(
            "The 12 recovery words, separated by spaces", text: $entry, axis: .vertical)
            .lineLimit(3, reservesSpace: true)
            .autocorrectionDisabled()
            .privacySensitive()
        #if os(iOS)
        return field
            .textInputAutocapitalization(.never)
            .pageFieldChrome(pageStyle)
        #else
        return field
        #endif
    }

    @ViewBuilder
    private func resultLine(_ result: SecretCheckModel.Result) -> some View {
        let text = Text(model.message(for: result))
            .fixedSize(horizontal: false, vertical: true)
        switch result {
        case .correct:
            text.pageCaption(pageStyle)
            if let seconds = model.lastSeconds {
                Text(String(format: "The key derivation took %.2f s on this device.", seconds))
                    .pageCaption(pageStyle)
            }
        case .wrong:
            text.pageCaptionWarning(pageStyle)
        case .couldNotCheck:
            text.pageCaptionWarning(pageStyle)
        }
    }
}
