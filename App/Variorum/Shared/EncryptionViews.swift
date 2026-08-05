//
//  EncryptionViews.swift
//  Variorum (shared: Mac + Mobile)
//
//  Phase 14b, batch 3 (L9) — the E2EE settings surface, ONE shared view for
//  both form factors (PL-6; the AccountView precedent — functional and
//  unstyled).
//
//  Phase 14b COPY/FLOW ROUND (CF-1…CF-13 + the CF-12 biometric ruling; the
//  governing principle is CF-10, her words: many users' first real
//  end-to-end encryption — the flow must make sense FOR THEM):
//  SETUP is a real stepped flow — 1 choose passphrase · 2 the warning with
//  the MANDATORY understanding checkbox (her exact sentence) · 3 create ·
//  4 the recovery phrase, MANDATORY (CF-5: generate → write down → confirm;
//  setup cannot complete without it — and because step 4 IS the
//  `enrolled(hasRecoveryWrap: false)` state, a relaunch mid-setup resumes
//  exactly there). ENROLLMENT (passphrase, or the recovery phrase as the
//  disaster road — the reveal LOOKS like a button, CF-3). REGENERATE gates
//  behind the passphrase (CF-2). CHANGE PASSPHRASE (current passphrase OR
//  recovery phrase — Round 7). The FORGET door (CF-11 — confirmed,
//  destructive). The BIOMETRIC unlock policy (CF-12's ruling — biometric
//  or the passphrase, never the device passcode; per-platform naming).
//
//  The warning wording + the disclosure copy ride the plan file's GATE
//  RATIFY + copy/flow record (L13) — change them there and here together.
//
//  Phase 14b CROSSOVER ROUND: this view is now the Account sheet's
//  ENCRYPTION TAB content (CF-14 — her ruling: the Encryption surface
//  folds UNDER the Account button; AccountView owns the sheet chrome —
//  scroll, padding, the CF-1 borderless Close — and this view renders the
//  states). CF-16: the honest REPLACED state — a device that slept
//  through a re-key explains itself and offers the ordinary unlock roads
//  instead of failing generically.
//

import SwiftUI
import VariorumCore

/// The stepped setup flow's advance rules (CF-1/5/7) — pure, pinned by
/// tests; the view holds the step @State and consults these, so the gates
/// can never quietly soften.
nonisolated enum EncryptionSetupRules {
    static func canLeavePassphraseStep(passphrase: String, confirm: String) -> Bool {
        !passphrase.isEmpty && passphrase == confirm
    }

    /// CF-7: the warning step refuses to advance without her checkbox.
    static func canLeaveWarningStep(acknowledged: Bool) -> Bool {
        acknowledged
    }
}

struct EncryptionView: View {
    let services: AppServices

    /// CF-1: the setup flow's position (steps 1–3; step 4 — the mandatory
    /// recovery phrase — is the `enrolled(hasRecoveryWrap: false)` state
    /// itself, so it can never be skipped or lost to a relaunch).
    private enum SetupStep {
        case passphrase, warning, create
    }
    @State private var setupStep: SetupStep = .passphrase
    @State private var setupPassphrase = ""
    @State private var setupConfirm = ""
    /// CF-7: the understanding checkbox's state.
    @State private var acknowledged = false

    @State private var enrollPassphrase = ""
    @State private var usePhraseInstead = false
    @State private var phraseEntry = ""

    /// The freshly-generated words, shown ONCE; nothing lands until the
    /// re-entry confirms (Round 5 item 3's order). NOT cleared on a failed
    /// land — the words she wrote down must stay the words on screen.
    @State private var generatedWords: [String]?
    @State private var confirmEntry = ""
    @State private var confirmMismatch = false
    /// True while the generate flow is REPLACING an existing wrap (reached
    /// only through the CF-2 passphrase gate).
    @State private var replacingWrap = false
    /// CF-2: the regenerate door's passphrase gate.
    @State private var showingRegenerate = false
    @State private var regeneratePassphrase = ""

    @State private var showingChangePassphrase = false
    @State private var changeCurrent = ""
    @State private var changeUseRecovery = false
    @State private var changeRecoveryEntry = ""
    @State private var changeNew = ""
    @State private var changeNewConfirm = ""

    /// CF-11: the forget door's confirm.
    @State private var showingForgetConfirm = false

    /// Phase 14c (CF-8): the re-key door's gate.
    @State private var showingRekey = false
    @State private var rekeyAcknowledged = false
    @State private var rekeyPassphrase = ""

    private var encryption: EncryptionSession { services.encryption }

    // MARK: - The copy (GATE RATIFY / her walk — the record carries these)

    /// CF-10: the first-experience framing — what E2EE IS, before any
    /// secret is chosen.
    static let setupIntro =
        "End-to-end encryption means your writing is sealed on this device before it syncs — "
        + "the server only ever stores sealed text it cannot read. Two secrets can unseal it: "
        + "the passphrase you choose now, and a 12-word recovery phrase you'll write down in a "
        + "moment. Variorum holds neither."

    /// THE ONE HONEST WARNING (setup step 2) — unrecoverable-by-design is
    /// its core, with CF-6's clarification: the LOCAL copy survives; what's
    /// lost is the synced copy and new-device enrollment.
    static let setupWarning =
        "This passphrase is not your account password, and it is never sent anywhere. "
        + "Variorum cannot reset it and cannot read your writing without it — there is no "
        + "“forgot passphrase” email, by design. If you lose both the passphrase and your "
        + "12-word recovery phrase, the synced copy is unreadable forever and no new device "
        + "can be added — the writing already on your devices stays readable and stays yours."

    /// CF-7 — HER EXACT SENTENCE, the mandatory checkbox's label.
    static let understandingCheckbox =
        "I understand that if I lose my recovery phrase and my passphrase, "
        + "that I will not be able to recover anything from sync or add new devices"

    static let passphraseRecommendation =
        "Use a long passphrase: four or more random words, or 16+ mixed characters — and "
        + "never a password you use anywhere else."

    /// CF-9: the storage recommendation, hers near-verbatim.
    static let storageAdvice =
        "Store them like they matter: on paper or in a password manager. Keep two copies of "
        + "the passphrase and two copies of the recovery phrase, stored separately."

    /// CF-13: the whole phrase is the secret.
    static let wholePhraseIsTheSecret =
        "All 12 words together, in order, are the secret — no single word is a password. "
        + "Anyone with the whole phrase can unlock your synced writing; anyone with less "
        + "has nothing."

    /// Item 8: the disclosure list's USER-FACING copy (staged for her walk;
    /// the technical column list is the plan file's GATE RATIFY block).
    static let disclosureCopy =
        "Everything you write is sealed on your devices before it syncs: your text and "
        + "takes, titles, book and chapter names, tags, comments, commit messages, and "
        + "reference names and links. The server can never read any of it.\n\n"
        + "What the server still sees is the shape, not the words: that an entry exists on "
        + "a day, how items are ordered and connected, their sizes, when you sync, and "
        + "settings switches. Sealed words plus visible shape is what lets sync work "
        + "without trusting the server."

    /// CF-16: the replaced state's headline — the ruled copy shape,
    /// byte-pinned ("This account's encryption keys were replaced. Enter
    /// your passphrase to re-enroll.").
    static let keysReplacedExplanation =
        "This account's encryption keys were replaced. Enter your passphrase to re-enroll."

    /// CF-11: the forget door's confirm message.
    static let forgetExplanation =
        "Sync on this device stops until you unlock again with your encryption passphrase "
        + "or recovery phrase. Nothing is deleted from this device or your account."

    /// Ladder R1-1: the persisted-marker banner's prompt — a re-key
    /// started on this device and never completed (a crash or a mid-run
    /// failure), so sync is paused on the engine's own refusal and the
    /// rerun road is spoken HERE, with the door right beside it
    /// (fire-and-DO). The brain's rerun heals every window state,
    /// whichever section renders below.
    static let rekeyIncompletePrompt =
        "Key replacement didn't finish on this device — sync is paused until it completes. "
        + "Run Replace Encryption Keys again; nothing is lost, and your writing is untouched."

    /// Phase 14c (CF-8): the re-key door's explanation — the honest
    /// warning names what a re-key does to OTHER devices (they land in
    /// the keys-were-replaced state and re-enroll), what happens to the
    /// recovery phrase, and that the local copy is untouched.
    static let rekeyExplanation =
        "Replacing your keys mints a fresh set, deletes the synced copy from the server, "
        + "and re-uploads everything from this device sealed under the new keys. Your "
        + "writing on this device is untouched. Every OTHER device will pause syncing and "
        + "say its keys were replaced — re-enroll each one with your passphrase. Your "
        + "current recovery phrase stops working; you'll write down a new one right after."

    /// CF-8's understanding checkbox (the CF-7 grammar applied to this
    /// door — friction per the 14b precedent).
    static let rekeyUnderstandingCheckbox =
        "I understand that my other devices pause syncing until I re-enroll them, "
        + "and that my current recovery phrase stops working"

    /// CF-12: per-platform biometric naming — never the WebAuthn credential
    /// word (her terminology ruling; the TerminologyPinTests walk enforces
    /// it over every shipped source, comments included).
    static var biometricName: String {
        #if os(macOS)
        "Touch ID"
        #else
        "Face ID or Touch ID"
        #endif
    }

    /// CF-12: the toggle's own copy — the sync-waits cost, the
    /// never-the-passcode rule, and the re-enrollment note, all stated.
    static let biometricToggleCopy: String = {
        #if os(macOS)
        "While this is on, sync waits each launch until you unlock — with Touch ID, "
        + "or by typing your encryption passphrase. Your device passcode never unlocks "
        + "it. If Touch ID is re-enrolled, the stored keys are invalidated by design — "
        + "the passphrase still gets you in."
        #else
        "While this is on, sync waits each launch until you unlock — with Face ID or "
        + "Touch ID, or by typing your encryption passphrase. Your device passcode "
        + "never unlocks it. If biometrics are re-enrolled, the stored keys are "
        + "invalidated by design — the passphrase still gets you in."
        #endif
    }()

    var body: some View {
        // CF-14: no chrome of its own — the tabbed Account sheet carries
        // the scroll, the padding, and the CF-1 borderless Close; this view
        // is the Encryption tab's content.
        VStack(alignment: .leading, spacing: 14) {
            // Ladder R1-1: the unfinished-re-key banner rides ABOVE the
            // state switch — every arm below (enrolled, mandatory-phrase,
            // keysReplaced, …) is a state a mid-re-key crash can land in,
            // and the completing door must be one act away in all of them.
            if encryption.rekeyIncomplete {
                rekeyIncompleteBanner
                Divider()
            }
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
            case .notEnrolled(let hasRecoveryWrap):
                enrollmentSection(hasRecoveryWrap: hasRecoveryWrap)
            case .enrolledLocked(let hasRecoveryWrap):
                lockedSection(hasRecoveryWrap: hasRecoveryWrap)
            case .keysReplaced(let hasRecoveryWrap):
                keysReplacedSection(hasRecoveryWrap: hasRecoveryWrap)
            case .enrolled(let hasRecoveryWrap):
                if hasRecoveryWrap {
                    enrolledSection
                } else {
                    // Step 4 of 4 — mandatory (CF-5): the flow's own last
                    // step, and the resume point after any interruption.
                    mandatoryPhraseSection
                }
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
        }
        .task { await encryption.refresh() }
    }

    // MARK: - Setup (first device) — the stepped flow (CF-1/5/6/7/9/10/13)

    @ViewBuilder
    private var setupSection: some View {
        switch setupStep {
        case .passphrase:
            Text("Step 1 of 4 — Choose your encryption passphrase")
                .fontWeight(.semibold)
            Text(Self.setupIntro)
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
            if !setupConfirm.isEmpty, setupPassphrase != setupConfirm {
                Text("The two entries don't match yet.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Button("Continue") { setupStep = .warning }
                .disabled(!EncryptionSetupRules.canLeavePassphraseStep(
                    passphrase: setupPassphrase, confirm: setupConfirm))
        case .warning:
            Text("Step 2 of 4 — What the secrets mean")
                .fontWeight(.semibold)
            Text(Self.setupWarning)
                .font(.caption)
                .foregroundStyle(.orange)
                .fixedSize(horizontal: false, vertical: true)
            Text(Self.storageAdvice)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Toggle(isOn: $acknowledged) {
                Text(Self.understandingCheckbox)
                    .font(.caption)
                    .fixedSize(horizontal: false, vertical: true)
            }
            #if os(macOS)
            .toggleStyle(.checkbox)
            #endif
            HStack {
                Button("Back") { setupStep = .passphrase }
                Button("Continue") { setupStep = .create }
                    .disabled(!EncryptionSetupRules.canLeaveWarningStep(
                        acknowledged: acknowledged))
            }
        case .create:
            Text("Step 3 of 4 — Create your encrypted vault")
                .fontWeight(.semibold)
            Text("Your vault is created on your account, and this device holds its keys. The last step — your recovery phrase — comes right after.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Button("Back") { setupStep = .warning }
                Button("Create Encrypted Vault") {
                    let passphrase = setupPassphrase
                    Task {
                        await encryption.setUp(passphrase: passphrase)
                        if encryption.lastError == nil {
                            setupPassphrase = ""
                            setupConfirm = ""
                        }
                    }
                }
                .disabled(encryption.busy || setupPassphrase.isEmpty)
            }
        }
    }

    // MARK: - Step 4 of 4 — the MANDATORY recovery phrase (CF-4/5/13)

    private var mandatoryPhraseSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Step 4 of 4 — Your recovery phrase (required)")
                .fontWeight(.semibold)
            Text("If you ever forget the passphrase, these 12 words are the only other way into your synced writing. Setup isn't finished until you've written them down and confirmed them — closing now just leaves this step waiting.")
                .font(.caption)
                .foregroundStyle(.orange)
                .fixedSize(horizontal: false, vertical: true)
            if let words = generatedWords {
                phraseConfirmSection(words: words, cancellable: false)
            }
        }
        .onAppear {
            // Generation is automatic — the step IS the phrase; there is no
            // optional-looking offer to decline (CF-5).
            if generatedWords == nil {
                replacingWrap = false
                generatedWords = encryption.generatePhrase()
            }
        }
    }

    // MARK: - The 12-words entry field (one shape, three arms)

    /// The phrase entry field shared by the confirm, enrollment, and
    /// change-passphrase arms: autocorrect off, and on the phone
    /// auto-capitals off too — BIP-39 words are lowercase; validation
    /// folds case, but a capitalized first word READS as a wrong entry
    /// (the AuthViews emailField precedent). privacySensitive: typed
    /// words are the same secret as the displayed phrase, so the mobile
    /// shell's snapshot cover redacts them alike.
    private func phraseEntryField(_ label: String, text: Binding<String>) -> some View {
        let field = TextField(label, text: text, axis: .vertical)
            .lineLimit(3, reservesSpace: true)
            .autocorrectionDisabled()
            .privacySensitive()
        #if os(iOS)
        return field.textInputAutocapitalization(.never)
        #else
        return field
        #endif
    }

    // MARK: - The phrase display + confirm-by-re-entry (Round 5 item 3; CF-4)

    @ViewBuilder
    private func phraseConfirmSection(words: [String], cancellable: Bool) -> some View {
        Text(Self.wholePhraseIsTheSecret)
            .font(.caption)
            .foregroundStyle(.orange)
            .fixedSize(horizontal: false, vertical: true)
        Text(words.enumerated().map { "\($0.offset + 1). \($0.element)" }
            .joined(separator: "   "))
            .font(.body.monospaced())
            .textSelection(.enabled)
            .fixedSize(horizontal: false, vertical: true)
            // The one place the 12 words render. privacySensitive is inert
            // until a shell applies a .privacy redaction — the mobile
            // shell does, for the app-switcher snapshot (SnapshotPrivacy);
            // the Mac applies none and is byte-identical in behavior.
            .privacySensitive()
        Text("1. Write the 12 words down — on paper, or in a password manager.")
            .font(.caption)
            .foregroundStyle(.secondary)
        Text("2. Type them back, in order, to confirm:")
            .font(.caption)
            .foregroundStyle(.secondary)
        phraseEntryField("The 12 words, separated by spaces", text: $confirmEntry)
        if confirmMismatch {
            Text("That doesn't match the phrase above — check what you wrote down.")
                .font(.caption)
                .foregroundStyle(.red)
        }
        if replacingWrap {
            Text("The phrase you have now keeps working until this confirm lands — then it stops, everywhere.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
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
                let replace = replacingWrap
                Task {
                    await encryption.landRecoveryWrap(
                        confirmedWords: words, allowReplace: replace)
                    if encryption.lastError == nil {
                        generatedWords = nil
                        confirmEntry = ""
                        replacingWrap = false
                        showingRegenerate = false
                    }
                }
            }
            .disabled(encryption.busy || confirmEntry.isEmpty)
            if cancellable {
                Button("Cancel") {
                    generatedWords = nil
                    confirmEntry = ""
                    confirmMismatch = false
                    replacingWrap = false
                }
            }
        }
    }

    // MARK: - Enrollment (new device) + the shared unlock roads (CF-3)

    @ViewBuilder
    private func enrollmentSection(hasRecoveryWrap: Bool) -> some View {
        Text("Unlock sync on this device")
        Text("Enter your encryption passphrase to unwrap this account's keys.")
            .font(.caption)
            .foregroundStyle(.secondary)
        unlockRoads(offerPhraseRoad: hasRecoveryWrap)
    }

    /// CF-12: custody exists here but this launch hasn't unlocked — the
    /// biometric door first, the passphrase (and phrase) roads beside it.
    @ViewBuilder
    private func lockedSection(hasRecoveryWrap: Bool) -> some View {
        Text("Sync is locked on this device.")
        Text("\(Self.biometricName) — or your encryption passphrase — unlocks it. Your device passcode never does.")
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        Button("Unlock with \(Self.biometricName)") {
            Task { await encryption.unlockWithBiometrics() }
        }
        .disabled(encryption.busy)
        Divider()
        unlockRoads(offerPhraseRoad: hasRecoveryWrap)
    }

    /// CF-16: the honest replaced state — custody exists, but the account
    /// was re-keyed after this device enrolled. The headline is the ruled
    /// copy; the roads are the ORDINARY unlock roads (passphrase, plus the
    /// phrase reveal when the new vault carries a wrap) — the enroll save
    /// overwrites the stale custody wholesale (the step-0 proven class).
    @ViewBuilder
    private func keysReplacedSection(hasRecoveryWrap: Bool) -> some View {
        Text(Self.keysReplacedExplanation)
            .foregroundStyle(.orange)
            .fixedSize(horizontal: false, vertical: true)
        Text("The keys this device holds were replaced after it enrolled — sync stays paused until you re-enroll; nothing is lost while paused.")
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        unlockRoads(offerPhraseRoad: hasRecoveryWrap)
    }

    @ViewBuilder
    private func unlockRoads(offerPhraseRoad: Bool) -> some View {
        if !usePhraseInstead {
            SecureField("Encryption passphrase", text: $enrollPassphrase)
                .onSubmit { enrollNow() }
            Button("Unlock") { enrollNow() }
                .disabled(encryption.busy || enrollPassphrase.isEmpty)
            if offerPhraseRoad {
                // CF-3: the reveal is a real, visibly-bordered button —
                // never something that reads as static hint text.
                Button("Use my recovery phrase instead") { usePhraseInstead = true }
                    .buttonStyle(.bordered)
            }
        } else {
            phraseEntryField("The 12 recovery words, separated by spaces", text: $phraseEntry)
            Button("Unlock with Recovery Phrase") {
                let entry = phraseEntry
                phraseEntry = ""
                Task { await encryption.enroll(recoveryWordsText: entry) }
            }
            .disabled(encryption.busy || phraseEntry.isEmpty)
            Button("Back to passphrase entry") { usePhraseInstead = false }
                .buttonStyle(.bordered)
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
    private var enrolledSection: some View {
        Text("This device holds your encryption keys.")
        if let seconds = encryption.lastKDFSeconds {
            // L12: the on-device KDF number, readable straight off the flow.
            Text(String(format: "Passphrase key derivation took %.2f s on this device.", seconds))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        Text("A recovery phrase is on file for this account.")
            .font(.caption)
            .foregroundStyle(.secondary)

        Divider()

        if let words = generatedWords {
            Text("Your new recovery phrase — shown once:")
                .fontWeight(.semibold)
            phraseConfirmSection(words: words, cancellable: true)
        } else if showingRegenerate {
            regenerateGateSection
        } else {
            Button("Regenerate Recovery Phrase…") { showingRegenerate = true }
                .disabled(encryption.busy)
        }

        Divider()

        if showingChangePassphrase {
            changePassphraseSection
        } else {
            Button("Change Encryption Passphrase…") { showingChangePassphrase = true }
                .disabled(encryption.busy)
        }

        Divider()

        biometricToggleSection

        Divider()

        // Ladder R1-1: while a re-key is owed, the banner at the top
        // carries this door (and the open flow) — rendering a second
        // copy here would double the shared showingRekey flow.
        if !encryption.rekeyIncomplete {
            if showingRekey {
                rekeySection
            } else {
                Button("Replace Encryption Keys…") { showingRekey = true }
                    .disabled(encryption.busy)
            }

            Divider()
        }

        DisclosureGroup("What the server can and can't see") {
            Text(Self.disclosureCopy)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 4)
        }
        .font(.caption)

        Divider()

        forgetSection
    }

    // MARK: - The unfinished-re-key banner (ladder R1-1)

    /// The persisted marker's surface voice: the prompt plus the
    /// completing door RIGHT HERE — reachable from every state arm, so
    /// the rerun is one act away whichever window the crash left.
    @ViewBuilder
    private var rekeyIncompleteBanner: some View {
        Text(Self.rekeyIncompletePrompt)
            .font(.caption)
            .foregroundStyle(.orange)
            .fixedSize(horizontal: false, vertical: true)
        if showingRekey {
            rekeySection
        } else {
            Button("Replace Encryption Keys…") { showingRekey = true }
                .disabled(encryption.busy)
        }
    }

    // MARK: - The re-key door (Phase 14c, CF-8 — THE DESIGN 3)

    /// The user-facing re-key: in-app, no terminal — her CF-8 deferral
    /// made real. Friction per the 14b grammar: the honest warning, the
    /// understanding CHECKBOX (the CF-7 precedent), and the passphrase as
    /// authorization. On success the state lands in the MANDATORY new
    /// recovery phrase step (CF-5) — the old phrase died with the old
    /// keys, and setup's own machinery mints the new one.
    @ViewBuilder
    private var rekeySection: some View {
        Text("Replace encryption keys")
            .fontWeight(.semibold)
        Text(Self.rekeyExplanation)
            .font(.caption)
            .foregroundStyle(.orange)
            .fixedSize(horizontal: false, vertical: true)
        Toggle(isOn: $rekeyAcknowledged) {
            Text(Self.rekeyUnderstandingCheckbox)
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)
        }
        #if os(macOS)
        .toggleStyle(.checkbox)
        #endif
        SecureField("Encryption passphrase", text: $rekeyPassphrase)
        HStack {
            Button("Replace Keys and Re-upload", role: .destructive) {
                let passphrase = rekeyPassphrase
                rekeyPassphrase = ""
                Task {
                    await encryption.rekeyAccount(passphrase: passphrase)
                    if encryption.lastError == nil {
                        showingRekey = false
                        rekeyAcknowledged = false
                    }
                }
            }
            .disabled(encryption.busy || rekeyPassphrase.isEmpty || !rekeyAcknowledged)
            Button("Cancel") {
                showingRekey = false
                rekeyAcknowledged = false
                rekeyPassphrase = ""
            }
        }
    }

    // MARK: - Regenerate, behind the passphrase (CF-2)

    @ViewBuilder
    private var regenerateGateSection: some View {
        Text("Replace the recovery phrase")
            .fontWeight(.semibold)
        Text("Your encryption passphrase authorizes a new phrase — the same proof as changing it. The phrase you have now keeps working until the new one is confirmed.")
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        SecureField("Encryption passphrase", text: $regeneratePassphrase)
            .onSubmit { regenerateNow() }
        HStack {
            Button("Verify and Generate New Phrase") { regenerateNow() }
                .disabled(encryption.busy || regeneratePassphrase.isEmpty)
            Button("Cancel") {
                showingRegenerate = false
                regeneratePassphrase = ""
            }
        }
    }

    private func regenerateNow() {
        guard !regeneratePassphrase.isEmpty, !encryption.busy else { return }
        let passphrase = regeneratePassphrase
        regeneratePassphrase = ""
        Task {
            if let words = await encryption.generatePhraseAuthorized(passphrase: passphrase) {
                replacingWrap = true
                generatedWords = words
            }
        }
    }

    // MARK: - The biometric unlock policy (CF-12's ruling)

    @ViewBuilder
    private var biometricToggleSection: some View {
        Toggle(isOn: Binding(
            get: { encryption.biometricRequired },
            set: { encryption.setBiometricRequirement($0) })
        ) {
            Text("Require \(Self.biometricName) to unlock sync")
        }
        #if os(macOS)
        .toggleStyle(.checkbox)
        #endif
        .disabled(encryption.busy
                  || (!encryption.biometricRequired && !encryption.biometryAvailable))
        if !encryption.biometryAvailable {
            Text("No \(Self.biometricName) is set up on this device.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        Text(Self.biometricToggleCopy)
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - The forget door (CF-11)

    @ViewBuilder
    private var forgetSection: some View {
        Button("Forget Encryption Keys on This Device…", role: .destructive) {
            showingForgetConfirm = true
        }
        .disabled(encryption.busy)
        .confirmationDialog(
            "Forget the encryption keys on this device?",
            isPresented: $showingForgetConfirm
        ) {
            Button("Forget Keys", role: .destructive) {
                Task { await encryption.forgetDeviceKeys() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(Self.forgetExplanation)
        }
        Text("For handing a device off, or testing your recovery phrase. Your writing on this device and the account vault are untouched.")
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Change passphrase (Round 7; CF-3)

    @ViewBuilder
    private var changePassphraseSection: some View {
        Text("Change encryption passphrase")
        if !changeUseRecovery {
            SecureField("Current passphrase", text: $changeCurrent)
            // CF-3: her live find, verbatim — "it really is very unclear
            // that it's a button". A real bordered button now.
            Button("Forgot it? Authorize with the recovery phrase") {
                changeUseRecovery = true
            }
            .buttonStyle(.bordered)
        } else {
            phraseEntryField("The 12 recovery words, separated by spaces", text: $changeRecoveryEntry)
            Button("Back to current-passphrase entry") { changeUseRecovery = false }
                .buttonStyle(.bordered)
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
