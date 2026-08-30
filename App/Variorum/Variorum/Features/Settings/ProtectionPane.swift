//
//  ProtectionPane.swift
//  Variorum
//
//  Phase 13p, Batch 2 — Settings ▸ Protection: the two presets as
//  dial-setters (R13p-7), the three at-open modes with the honesty
//  grammar and per-mode loss math (R13p-5 / knot 6), the escrow dial
//  with the ruled sentence pair (R13p-6 / knot 8), the re-lock dials +
//  Lock Now (demanded modes only), the passphrase set/reset doors
//  (knot 4; R13p-9), and the reminder check composing 13l's SecretCheck
//  face over the STORE road ("one face serves both").
//
//  The PASSPHRASE-SET SHEET is knot 4's one-moment-two-artifacts: set
//  the passphrase, and the recovery phrase generates and displays ON
//  THAT SAME SCREEN. Where a VAULT exists (signed in, 14b), one-secret
//  binds: the typed passphrase must BE the vault's (verified by the real
//  read-only unwrap; offline refuses honestly rather than letting two
//  passphrases exist), and an existing vault phrase is extended by
//  typing it, never replaced by a fresh one.
//
//  Placeholder voice, honest content — 13s re-voices.
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

// MARK: - The set sheet

struct PassphraseSetSheet: View {
    @Bindable var model: PassphraseSetModel
    var onDone: () -> Void

    @State private var passphrase = ""
    @State private var confirmation = ""
    @State private var typedWords = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            switch model.phase {
            case .enterPassphrase:
                Text("Set your encryption passphrase")
                    .font(.title3.weight(.semibold))
                Text(model.vaultConstrains
                     ? "Your account already has an encryption passphrase, and one "
                       + "passphrase serves both — type that same one here to make it "
                       + "unlock this library too."
                     : "One passphrase, chosen by you, never sent anywhere. It can "
                       + "unlock this library when the Keychain can't — or at every "
                       + "open, if you ask for that.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                SecureField("Encryption passphrase", text: $passphrase)
                    .textFieldStyle(.roundedBorder)
                SecureField("Type it again", text: $confirmation)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button("Cancel") { onDone() }
                    Spacer()
                    Button("Set Passphrase") {
                        Task { await model.commit(
                            passphrase: passphrase, confirmation: confirmation) }
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(model.busy || passphrase.isEmpty)
                }
            case .showPhrase(let words):
                Text("Your recovery phrase")
                    .font(.title3.weight(.semibold))
                Text("Twelve words that can unlock this library if everything else "
                     + "is gone. Write them down somewhere real — they are shown "
                     + "now, and never again.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                phraseGrid(words)
                    .privacySensitive()
                HStack {
                    Spacer()
                    Button("I've written them down") {
                        model.acknowledgePhraseWritten()
                        onDone()
                    }
                    .keyboardShortcut(.defaultAction)
                }
            case .extendExistingPhrase:
                Text("Your account already has a recovery phrase")
                    .font(.title3.weight(.semibold))
                Text("Type those same twelve words to make them unlock this "
                     + "library too — one phrase serves both. You can skip this; "
                     + "the passphrase is set either way.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                TextField("The 12 words, separated by spaces", text: $typedWords, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
                    .autocorrectionDisabled()
                    .privacySensitive()
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button("Skip") {
                        model.skipPhrase()
                        onDone()
                    }
                    Spacer()
                    Button("Extend It to This Library") {
                        Task {
                            await model.extendPhrase(typed: typedWords)
                            if model.phase == .done { onDone() }
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(model.busy || typedWords.trimmingCharacters(
                        in: .whitespacesAndNewlines).isEmpty)
                }
            case .done:
                Text("Done").font(.title3.weight(.semibold))
                Text("The passphrase is set.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                HStack { Spacer(); Button("Close") { onDone() }.keyboardShortcut(.defaultAction) }
            }
            if model.busy {
                HStack(spacing: 6) {
                    ProgressView().controlSize(.small)
                    Text("Working…").font(.caption).foregroundStyle(.secondary)
                }
            }
            if let error = model.lastError {
                Text(error)
                    .font(.callout)
                    .alarmVoice()
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(24)
        .frame(width: 440)
    }

    private func phraseGrid(_ words: [String]) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                  alignment: .leading, spacing: 6) {
            ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                Text("\(index + 1). \(word)")
                    .font(.body.monospaced())
                    .textSelection(.enabled)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary.opacity(0.5)))
    }
}

// MARK: - The pane

struct ProtectionPane: View {
    @Bindable var controller: ProtectionController
    let services: AppServices?

    @State private var setSheetModel: PassphraseSetModel?
    /// A demanded pick waiting on the passphrase-set sheet — retried the
    /// moment the sheet lands its wrap.
    @State private var pendingAfterSet: PendingAct?
    @State private var resetSheetShown = false
    @State private var reminderCheck: SecretCheckModel?

    enum PendingAct: Equatable {
        case mode(StoreAtOpenMode)
        case preset(ProtectionPreset)
    }

    var body: some View {
        Form {
            presetSection
            modeSection
            escrowSection
            if controller.dials.mode.isDemanded {
                relockSection
            }
            passphraseSection
            reminderSection
        }
        .formStyle(.grouped)
        .task { await services?.encryption.refresh() }
        .sheet(item: $setSheetModel) { model in
            PassphraseSetSheet(model: model) {
                setSheetModel = nil
                Task { await retryPendingAct() }
            }
        }
        .sheet(isPresented: $resetSheetShown) {
            PassphraseResetSheet(controller: controller) { resetSheetShown = false }
        }
    }

    // MARK: Presets (R13p-7)

    private var presetSection: some View {
        Section("Protection") {
            HStack(spacing: 12) {
                presetButton(.standard, title: "Standard",
                             blurb: "Opens silently. The disk is protected; recovery is easy.")
                presetButton(.lockedDown, title: "Locked-down",
                             blurb: "Asks every time it opens. No silent copies anywhere.")
            }
            if controller.matchingPreset == nil {
                Text("Your dials are hand-adjusted — they match neither preset, "
                     + "which is fine: presets set the dials, the dials rule.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func presetButton(_ preset: ProtectionPreset, title: String, blurb: String) -> some View {
        Button {
            Task { await apply(.preset(preset)) }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title).font(.callout.weight(.semibold))
                    if controller.matchingPreset == preset {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                Text(blurb)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary.opacity(0.4)))
        }
        .buttonStyle(.plain)
    }

    // MARK: The at-open mode (R13p-5)

    private var modeSection: some View {
        Section("Opening Variorum") {
            Picker("At open", selection: Binding(
                get: { controller.dials.mode },
                set: { picked in Task { await apply(.mode(picked)) } })
            ) {
                Text("Open silently (Keychain)").tag(StoreAtOpenMode.auto)
                Text("Ask for Touch ID").tag(StoreAtOpenMode.biometric)
                    .selectionDisabled(!controller.biometryAvailable)
                Text("Ask for the passphrase").tag(StoreAtOpenMode.passphrase)
            }
            .pickerStyle(.radioGroup)
            Text(ProtectionCopy.modeSentence(controller.dials.mode))
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text(ProtectionCopy.lossMath(
                controller.dials.mode, escrowOn: controller.dials.escrowOn))
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if let error = controller.lastError {
                Text(error).font(.caption).alarmVoice()
            }
        }
    }

    // MARK: Escrow (R13p-6, knot 8's ruled pair)

    private var escrowSection: some View {
        Section("iCloud Keychain copy") {
            Toggle("Keep a copy of the key in iCloud Keychain", isOn: Binding(
                get: { controller.dials.escrowOn },
                set: { on in Task { _ = await controller.setEscrow(on) } }))
            Text(controller.dials.escrowOn
                 ? ProtectionCopy.escrowOn : ProtectionCopy.escrowOff)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if controller.dials.escrowOn {
                Text(ProtectionCopy.escrowNeedsICloudKeychain)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                if controller.dials.mode.isDemanded {
                    Text(ProtectionCopy.escrowUnderDemandedMode)
                        .font(.caption)
                        .alarmVoice()
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    // MARK: Re-lock (demanded modes only)

    private var relockSection: some View {
        Section("Locking while you're away") {
            Toggle("Lock when the Mac sleeps or the screen locks", isOn: Binding(
                get: { controller.dials.relockOnSleepAndScreenLock },
                set: { controller.setRelockOnSleep($0) }))
            Picker("Lock after idle", selection: Binding(
                get: { controller.dials.relockAfterIdleMinutes ?? 0 },
                set: { controller.setRelockIdleMinutes($0 == 0 ? nil : $0) })
            ) {
                Text("Never").tag(0)
                Text("After 5 minutes").tag(5)
                Text("After 15 minutes").tag(15)
                Text("After an hour").tag(60)
            }
            Button("Lock Library Now") {
                Task { await controller.performLock?() }
            }
            Text("Locking closes the library and forgets its key until you "
                 + "unlock it again. ⌃⌘L does the same from anywhere.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: The passphrase + phrase

    private var passphraseSection: some View {
        Section("Passphrase & recovery phrase") {
            LabeledContent("Encryption passphrase",
                           value: controller.hasPassphraseWrap ? "Set" : "Not set")
            LabeledContent("Recovery phrase",
                           value: controller.hasRecoveryWrap ? "On file" : "Not saved")
            HStack {
                Button(controller.hasPassphraseWrap
                       ? "Change Passphrase…" : "Set a Passphrase…") {
                    openSetSheet()
                }
                if controller.hasPassphraseWrap {
                    Button("Forgot It? Reset…") { resetSheetShown = true }
                }
                Spacer()
            }
            Text("The passphrase and the twelve words are the ways back into "
                 + "this library when this Mac's Keychain can't help. Nothing "
                 + "is sent anywhere; both work offline.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: The reminder (R13p-9 — one face: SecretCheck over the store road)

    @ViewBuilder
    private var reminderSection: some View {
        Section("Remembering your secrets") {
            Toggle("Check in on the passphrase now and then", isOn: Binding(
                get: { controller.dials.reminderChecksOn },
                set: { controller.setReminderChecks($0) }))
            Text("A secret you never type is a secret that slips away. When this "
                 + "is on, Variorum occasionally asks whether you still remember "
                 + "it — a rehearsal, never a reset.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if controller.hasPassphraseWrap || controller.hasRecoveryWrap {
                checkSection
            }
        }
    }

    @ViewBuilder
    private var checkSection: some View {
        let model = reminderCheck ?? {
            let fresh = SecretCheckModel(
                client: nil,
                storeCheck: controller.makeStoreSecretCheck(),
                targetNoun: "this library's key")
            Task { @MainActor in reminderCheck = fresh }
            return fresh
        }()
        SecretCheckSection(
            framing: SecretCheckFraming(
                headline: ProtectionCopy.reminderHeadline,
                blurb: ProtectionCopy.reminderBody),
            offersRecoveryPhrase: controller.hasRecoveryWrap,
            model: model)
        .onChange(of: model.result) { _, result in
            if case .correct = result {
                controller.recordReminderConfirmed()
            }
        }
    }

    // MARK: Acts

    private func openSetSheet() {
        setSheetModel = PassphraseSetModel(
            controller: controller,
            vaultTie: VaultTie.make(services: services))
    }

    private func apply(_ act: PendingAct) async {
        let outcome: ProtectionController.ModeChangeOutcome
        switch act {
        case .mode(let mode): outcome = await controller.setMode(mode)
        case .preset(let preset): outcome = await controller.applyPreset(preset)
        }
        switch outcome {
        case .changed:
            controller.lastError = nil
        case .needsPassphrase:
            pendingAfterSet = act
            openSetSheet()
        case .refused(let message):
            controller.lastError = message
        }
    }

    private func retryPendingAct() async {
        guard let act = pendingAfterSet else { return }
        pendingAfterSet = nil
        guard controller.hasPassphraseWrap else { return }  // the sheet was cancelled
        await apply(act)
    }
}

extension PassphraseSetModel: Identifiable {}

// MARK: - The reset sheet (R13p-9's door)

struct PassphraseResetSheet: View {
    let controller: ProtectionController
    var onDone: () -> Void

    @State private var newPassphrase = ""
    @State private var confirmation = ""
    @State private var busy = false
    @State private var error: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Reset your encryption passphrase")
                .font(.title3.weight(.semibold))
            Text("You don't need the old one — this Mac still holds the key, and "
                 + "Touch ID confirms it's you. The old passphrase stops working "
                 + "the moment the new one is set.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            SecureField("New encryption passphrase", text: $newPassphrase)
                .textFieldStyle(.roundedBorder)
            SecureField("Type it again", text: $confirmation)
                .textFieldStyle(.roundedBorder)
            if let error {
                Text(error).font(.callout).alarmVoice()
                    .fixedSize(horizontal: false, vertical: true)
            }
            if busy {
                HStack(spacing: 6) {
                    ProgressView().controlSize(.small)
                    Text("Confirming…").font(.caption).foregroundStyle(.secondary)
                }
            }
            HStack {
                Button("Cancel") { onDone() }
                Spacer()
                Button("Reset with Touch ID") {
                    Task { await reset() }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(busy || newPassphrase.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 440)
    }

    private func reset() async {
        error = nil
        guard newPassphrase == confirmation else {
            error = "The two entries don't match."
            return
        }
        busy = true
        defer { busy = false }
        if let refusal = await controller.resetPassphrase(to: newPassphrase) {
            error = refusal
            return
        }
        onDone()
    }
}

// MARK: - The notice bar (the nudge + the reminder, calm and dismissible)

struct ProtectionNoticeBar: View {
    @Bindable var controller: ProtectionController
    let services: AppServices?

    @State private var setSheetModel: PassphraseSetModel?
    @State private var phraseWords: [String]?
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        Group {
            switch controller.notice {
            case .nudge: nudgeBar
            case .reminderDue: reminderBar
            case nil: EmptyView()
            }
        }
        .sheet(item: $setSheetModel) { model in
            PassphraseSetSheet(model: model) { setSheetModel = nil }
        }
        .sheet(isPresented: Binding(
            get: { phraseWords != nil }, set: { if !$0 { phraseWords = nil } })
        ) {
            if let words = phraseWords {
                PhraseOnlySheet(words: words) { phraseWords = nil }
            }
        }
    }

    /// Knot 4's ruled two-offer shape, her amendment verbatim in the run
    /// record: create a passphrase (the set screen, phrase alongside) AND
    /// the recovery phrase either way.
    private var nudgeBar: some View {
        bar {
            VStack(alignment: .leading, spacing: 2) {
                Text(ProtectionCopy.nudgeHeadline).font(.callout.weight(.semibold))
                Text(ProtectionCopy.nudgeBody)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Button(ProtectionCopy.nudgeOfferPassphrase) {
                setSheetModel = PassphraseSetModel(
                    controller: controller,
                    vaultTie: VaultTie.make(services: services))
            }
            if !controller.hasRecoveryWrap {
                Button(ProtectionCopy.nudgeOfferPhrase) {
                    Task {
                        if let words = await controller.generateAndLandRecoveryPhrase() {
                            phraseWords = words
                        }
                    }
                }
            }
            Button(ProtectionCopy.nudgeLater) { controller.snoozeNudge() }
            Button {
                controller.dismissNudgeForever()
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(.plain)
            .help("Don't offer again")
        }
    }

    private var reminderBar: some View {
        bar {
            VStack(alignment: .leading, spacing: 2) {
                Text(ProtectionCopy.reminderHeadline).font(.callout.weight(.semibold))
                Text("Check it in Settings ▸ Protection — nothing changes, it only "
                     + "answers yes or no.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Check It…") {
                openSettings()
                controller.dismissReminder()
            }
            Button("Later") { controller.dismissReminder() }
        }
    }

    private func bar<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        HStack(spacing: 10) { content() }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.bar)
            .overlay(alignment: .top) { Divider() }
    }
}

/// The nudge's phrase-only road: the twelve words, shown once.
private struct PhraseOnlySheet: View {
    let words: [String]
    var onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Your recovery phrase")
                .font(.title3.weight(.semibold))
            Text("Twelve words that can unlock this library if this Mac is lost. "
                 + "Write them down somewhere real — they are shown now, and "
                 + "never again.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                      alignment: .leading, spacing: 6) {
                ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                    Text("\(index + 1). \(word)")
                        .font(.body.monospaced())
                        .textSelection(.enabled)
                }
            }
            .privacySensitive()
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary.opacity(0.5)))
            HStack {
                Spacer()
                Button("I've written them down") { onDone() }
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 440)
    }
}
