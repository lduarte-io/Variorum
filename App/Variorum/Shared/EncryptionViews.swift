//
//  EncryptionViews.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 14b, batch 3 (L9) — the E2EE settings surface, ONE shared view for
//  both form factors (PL-6; the AccountView precedent — functional and
//  unstyled). The flows: SETUP (passphrase + the ONE honest warning) ·
//  ENROLLMENT (passphrase, or the recovery phrase as the disaster road) ·
//  (RE)GENERATE RECOVERY PHRASE (first generation and regenerate are ONE
//  surface; replace is a deliberate confirm — Round 7) · CHANGE PASSPHRASE
//  (current passphrase OR recovery phrase — Round 7's scope addition).
//
//  The warning wording + the disclosure list ride the plan file's GATE
//  RATIFY block (L13) — change them there and here together.
//

import SwiftUI
import VariorumCore

struct EncryptionView: View {
    let services: AppServices
    @Environment(\.dismiss) private var dismiss

    @State private var setupPassphrase = ""
    @State private var setupConfirm = ""
    @State private var enrollPassphrase = ""
    @State private var usePhraseInstead = false
    @State private var phraseEntry = ""
    /// The freshly-generated words, shown ONCE; nothing lands until the
    /// re-entry confirms (Round 5 item 3's order).
    @State private var generatedWords: [String]?
    @State private var confirmEntry = ""
    @State private var confirmMismatch = false
    /// True while the generate flow is REPLACING an existing wrap (behind
    /// the deliberate confirm).
    @State private var replacingWrap = false
    @State private var showingReplaceConfirm = false
    @State private var showingChangePassphrase = false
    @State private var changeCurrent = ""
    @State private var changeUseRecovery = false
    @State private var changeRecoveryEntry = ""
    @State private var changeNew = ""
    @State private var changeNewConfirm = ""

    private var encryption: EncryptionSession { services.encryption }

    /// THE ONE HONEST WARNING (setup) — unrecoverable-by-design is its
    /// whole content. GATE RATIFY: the plan file's L13 block carries this
    /// wording for the author's ratify.
    static let setupWarning =
        "This passphrase is not your account password, and it is never sent anywhere. "
        + "Variorum cannot reset it and cannot read your writing without it — there is no "
        + "“forgot passphrase” email, by design. If you lose the passphrase and your 12-word "
        + "recovery phrase, everything you've synced is unreadable forever."

    static let passphraseRecommendation =
        "Use a long passphrase: four or more random words, or 16+ mixed characters — and "
        + "never a password you use anywhere else."

    var body: some View {
        ScrollView {
        VStack(alignment: .leading, spacing: 14) {
            Text("Encryption").font(.headline)

            switch encryption.state {
            case .unknown:
                ProgressView().controlSize(.small)
                Text("Checking this account's encryption state…")
                    .foregroundStyle(.secondary)
            case .signedOut:
                Text("Sign in first — your encryption vault lives on your account.")
                    .foregroundStyle(.secondary)
            case .newerFormat:
                Text("This account's encryption was set up by a newer version of Variorum. Update the app to unlock sync.")
                    .foregroundStyle(.orange)
            case .noVault:
                setupSection
            case .notEnrolled:
                enrollmentSection
            case .enrolled(let hasRecoveryWrap):
                enrolledSection(hasRecoveryWrap: hasRecoveryWrap)
            }

            if encryption.busy {
                ProgressView().controlSize(.small)
            }
            if let error = encryption.lastError {
                Text(error).font(.caption).foregroundStyle(.red)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(6)
            }

            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(20)
        }
        #if os(macOS)
        .frame(minWidth: 460, minHeight: 320)
        #endif
        .task { await encryption.refresh() }
    }

    // MARK: - Setup (first device)

    @ViewBuilder
    private var setupSection: some View {
        Text("Set up end-to-end encryption")
        Text("Choose an encryption passphrase. Everything you sync is encrypted with keys only your devices hold.")
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        SecureField("Encryption passphrase", text: $setupPassphrase)
        SecureField("Repeat the passphrase", text: $setupConfirm)
        if !setupPassphrase.isEmpty, setupPassphrase.count < 12 {
            Text("Short passphrase — under 12 characters is easier to brute-force.")
                .font(.caption)
                .foregroundStyle(.orange)
        }
        Text(Self.passphraseRecommendation)
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        Text(Self.setupWarning)
            .font(.caption)
            .foregroundStyle(.orange)
            .fixedSize(horizontal: false, vertical: true)
        Button("Create Encrypted Vault") {
            let passphrase = setupPassphrase
            setupPassphrase = ""
            setupConfirm = ""
            Task { await encryption.setUp(passphrase: passphrase) }
        }
        .disabled(encryption.busy || setupPassphrase.isEmpty
                  || setupPassphrase != setupConfirm)
        if !setupConfirm.isEmpty, setupPassphrase != setupConfirm {
            Text("The two entries don't match yet.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Enrollment (new device)

    @ViewBuilder
    private var enrollmentSection: some View {
        Text("Unlock sync on this device")
        Text("Enter your encryption passphrase to unwrap this account's keys.")
            .font(.caption)
            .foregroundStyle(.secondary)
        if !usePhraseInstead {
            SecureField("Encryption passphrase", text: $enrollPassphrase)
                .onSubmit { enrollNow() }
            Button("Unlock") { enrollNow() }
                .disabled(encryption.busy || enrollPassphrase.isEmpty)
            Button("Use my recovery phrase instead") { usePhraseInstead = true }
                .buttonStyle(.borderless)
                .font(.caption)
        } else {
            TextField("The 12 recovery words, separated by spaces", text: $phraseEntry, axis: .vertical)
                .lineLimit(3, reservesSpace: true)
                .autocorrectionDisabled()
            Button("Unlock with Recovery Phrase") {
                let entry = phraseEntry
                phraseEntry = ""
                Task { await encryption.enroll(recoveryWordsText: entry) }
            }
            .disabled(encryption.busy || phraseEntry.isEmpty)
            Button("Back to passphrase entry") { usePhraseInstead = false }
                .buttonStyle(.borderless)
                .font(.caption)
        }
    }

    private func enrollNow() {
        guard !enrollPassphrase.isEmpty, !encryption.busy else { return }
        let passphrase = enrollPassphrase
        enrollPassphrase = ""
        Task { await encryption.enroll(passphrase: passphrase) }
    }

    // MARK: - Enrolled (custody + the doors)

    @ViewBuilder
    private func enrolledSection(hasRecoveryWrap: Bool) -> some View {
        Text("This device holds your encryption keys.")
        if let seconds = encryption.lastKDFSeconds {
            // L12: the on-device KDF number, readable straight off the flow.
            Text(String(format: "Passphrase key derivation took %.2f s on this device.", seconds))
                .font(.caption)
                .foregroundStyle(.secondary)
        }

        Divider()

        if let words = generatedWords {
            phraseConfirmSection(words: words)
        } else if !hasRecoveryWrap {
            Text("No recovery phrase exists yet. If you forget your passphrase, the recovery phrase is the only other way in — generate it now and write it down.")
                .font(.caption)
                .foregroundStyle(.orange)
                .fixedSize(horizontal: false, vertical: true)
            Button("Generate Recovery Phrase") {
                replacingWrap = false
                generatedWords = encryption.generatePhrase()
            }
            .disabled(encryption.busy)
        } else {
            Text("A recovery phrase is on file for this account.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Button("Regenerate Recovery Phrase…") { showingReplaceConfirm = true }
                .disabled(encryption.busy)
                .confirmationDialog(
                    "Replace the existing recovery phrase?",
                    isPresented: $showingReplaceConfirm
                ) {
                    Button("Generate a new phrase (the old one stops working)", role: .destructive) {
                        replacingWrap = true
                        generatedWords = encryption.generatePhrase()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("The written-down phrase you have now will stop unlocking this account the moment the new one is confirmed.")
                }
        }

        Divider()

        if showingChangePassphrase {
            changePassphraseSection
        } else {
            Button("Change Encryption Passphrase…") { showingChangePassphrase = true }
                .disabled(encryption.busy)
        }
    }

    // MARK: - The phrase display + confirm-by-re-entry (Round 5 item 3)

    @ViewBuilder
    private func phraseConfirmSection(words: [String]) -> some View {
        Text("Your recovery phrase — shown once. Write it down somewhere real:")
            .font(.caption)
            .foregroundStyle(.orange)
        Text(words.enumerated().map { "\($0.offset + 1). \($0.element)" }
            .joined(separator: "   "))
            .font(.body.monospaced())
            .textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
        TextField("Type the 12 words back to confirm", text: $confirmEntry, axis: .vertical)
            .lineLimit(3, reservesSpace: true)
            .autocorrectionDisabled()
        if confirmMismatch {
            Text("That doesn't match the phrase above — check what you wrote down.")
                .font(.caption)
                .foregroundStyle(.red)
        }
        HStack {
            Button("Confirm — I Wrote It Down") {
                let entered = EncryptionSession.words(from: confirmEntry)
                    .map { $0.lowercased() }
                guard entered == words else {
                    confirmMismatch = true
                    return
                }
                confirmMismatch = false
                confirmEntry = ""
                generatedWords = nil
                let replace = replacingWrap
                Task {
                    await encryption.landRecoveryWrap(
                        confirmedWords: words, allowReplace: replace)
                }
            }
            .disabled(encryption.busy || confirmEntry.isEmpty)
            Button("Cancel") {
                generatedWords = nil
                confirmEntry = ""
                confirmMismatch = false
            }
        }
    }

    // MARK: - Change passphrase (Round 7)

    @ViewBuilder
    private var changePassphraseSection: some View {
        Text("Change encryption passphrase")
        if !changeUseRecovery {
            SecureField("Current passphrase", text: $changeCurrent)
            Button("Forgot it? Authorize with the recovery phrase") {
                changeUseRecovery = true
            }
            .buttonStyle(.borderless)
            .font(.caption)
        } else {
            TextField("The 12 recovery words, separated by spaces",
                      text: $changeRecoveryEntry, axis: .vertical)
                .lineLimit(3, reservesSpace: true)
                .autocorrectionDisabled()
            Button("Back to current-passphrase entry") { changeUseRecovery = false }
                .buttonStyle(.borderless)
                .font(.caption)
        }
        SecureField("New passphrase", text: $changeNew)
        SecureField("Repeat the new passphrase", text: $changeNewConfirm)
        if !changeNew.isEmpty, changeNew.count < 12 {
            Text("Short passphrase — under 12 characters is easier to brute-force.")
                .font(.caption)
                .foregroundStyle(.orange)
        }
        Text("Your recovery phrase keeps working unchanged — the two are independent.")
            .font(.caption)
            .foregroundStyle(.secondary)
        HStack {
            Button("Change Passphrase") {
                let authorization: VaultAuthorization = changeUseRecovery
                    ? .recoveryPhrase(EncryptionSession.words(from: changeRecoveryEntry))
                    : .passphrase(changeCurrent)
                let newPassphrase = changeNew
                changeCurrent = ""
                changeRecoveryEntry = ""
                changeNew = ""
                changeNewConfirm = ""
                showingChangePassphrase = false
                Task {
                    await encryption.changePassphrase(
                        authorization: authorization, newPassphrase: newPassphrase)
                }
            }
            .disabled(encryption.busy || changeNew.isEmpty
                      || changeNew != changeNewConfirm
                      || (changeUseRecovery ? changeRecoveryEntry.isEmpty : changeCurrent.isEmpty))
            Button("Cancel") {
                showingChangePassphrase = false
                changeCurrent = ""
                changeRecoveryEntry = ""
                changeNew = ""
                changeNewConfirm = ""
            }
        }
    }
}
