//
//  ProtectionPane.swift
//  Variorum
//
//  Phase 13p, Batch 2 — Settings ▸ Protection. pre-13x batch 2a — THE
//  POSTURE PANE (the postures design §8; copy §1, rendered verbatim): the
//  current-state line, the two posture CARDS (Standard · Castle), Castle's
//  two switches (Always ask · Lock after time away) + Lock Library Now —
//  shown only in Castle — and keystone 4 at the bottom. The presets, the
//  at-open picker, the escrow dial and the reminder dial are GONE (§13);
//  the passphrase set/reset doors stay until batch 3/5 re-shape them. The
//  CHOOSE doors (Use Standard · Use Castle…) are batch 2b's — the two
//  switches' ceremony — and per P-2 a door that cannot act is not rendered
//  here; the cards say what each posture is meanwhile.
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

// MARK: - The set sheet

struct PassphraseSetSheet: View {
    @Bindable var model: PassphraseSetModel
    /// Memo §6 — THE LOCK MOMENT: true only when this sheet was summoned
    /// by a demanded-mode pick (the choice arrives when you reach for the
    /// lock); the nudge's and the plain set door's summons stay unframed.
    var lockMoment: Bool = false
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
                if lockMoment {
                    // The lock-moment ceremony (memo §6): what asking-at-
                    // open MEANS, said where the lock is being reached for.
                    Text(ProtectionShapes.lockMomentFraming)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
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
                PeekableSecretField(label: "Encryption passphrase", text: $passphrase)
                    .textFieldStyle(.roundedBorder)
                PeekableSecretField(label: "Type it again", text: $confirmation)
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
    @State private var resetSheetShown = false
    @State private var reminderCheck: SecretCheckModel?

    var body: some View {
        Form {
            leadSection
            checklistSection
            postureSection
            if controller.posture == .castle {
                castleSwitchesSection
            }
            passphraseSection
            if controller.posture == .castle,
               controller.hasPassphraseWrap || controller.hasRecoveryWrap {
                reminderSection
            }
            keystoneSection
        }
        .formStyle(.grouped)
        .task { await services?.encryption.refresh() }
        .sheet(item: $setSheetModel) { model in
            PassphraseSetSheet(model: model) { setSheetModel = nil }
        }
        .sheet(isPresented: $resetSheetShown) {
            PassphraseResetSheet(controller: controller) { resetSheetShown = false }
        }
    }

    // MARK: The lead (keystone 1) + the current-state line

    private var leadSection: some View {
        Section(ProtectionCopy.protectionPaneTitle) {
            Text(ProtectionCopy.keystoneOneMode)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text(ProtectionCopy.currentStateLine(controller.posture))
                .font(.callout.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: The live checklist (item 3's centerpiece, re-based on A)

    /// The actual legs this device/account has RIGHT NOW — present/absent/
    /// unknown, truthfully (ONE brain: `ProtectionShapes.checklistRows`,
    /// which both platforms compose). Under an unreadable sidecar the wrap
    /// rows are withheld and T2's unknown sentence stands in.
    private var checklistSection: some View {
        Section("Ways back in — right now") {
            ForEach(
                ProtectionShapes.checklistRows(
                    controller.legs, mode: controller.effectiveGate),
                id: \.name
            ) { row in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Image(systemName: mark(for: row.present))
                        .foregroundStyle(row.present == true
                            ? AnyShapeStyle(.green) : AnyShapeStyle(.secondary))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(row.name).font(.callout)
                        Text(row.note)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            Text(ProtectionShapes.tierSentence(controller.legs.tier))
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if controller.appleKeyLandingFailed {
                Text("Your Apple account hasn't been able to take a key yet — this "
                     + "Mac's Keychain refused to keep the iCloud key, so no copy "
                     + "exists beyond this Mac; your other ways back in stand.")
                    .font(.caption)
                    .alarmVoice()
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func mark(for present: Bool?) -> String {
        switch present {
        case true: return "checkmark.circle.fill"
        case false: return "circle"
        case nil: return "questionmark.circle"
        }
    }

    // MARK: The two posture cards (copy §1)

    private var postureSection: some View {
        Section("Standard or Castle") {
            HStack(alignment: .top, spacing: 12) {
                postureCard(.standard)
                postureCard(.castle)
            }
            // The choose doors are batch 2b's (the switches' ceremony);
            // per P-2 nothing that cannot act renders here.
        }
    }

    private func postureCard(_ posture: Posture) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(ProtectionCopy.postureName(posture)).font(.callout.weight(.semibold))
                Text(ProtectionCopy.postureTag(posture))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if controller.posture == posture {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("current")
                }
            }
            Text(ProtectionCopy.postureOneLine(posture))
                .font(.caption.weight(.medium))
                .fixedSize(horizontal: false, vertical: true)
            ForEach(ProtectionCopy.postureCard(posture), id: \.label) { row in
                VStack(alignment: .leading, spacing: 1) {
                    Text(row.label).font(.caption.weight(.semibold))
                    Text(row.text)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(.quaternary.opacity(0.4)))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(ProtectionCopy.postureName(posture))
    }

    // MARK: Castle's switches (shown only in Castle — copy §1)

    private var castleSwitchesSection: some View {
        Section("Castle") {
            Toggle(ProtectionCopy.alwaysAskLabel, isOn: Binding(
                get: { controller.dials.alwaysAsk },
                set: { on in
                    Task {
                        if case .refused(let message) = await controller.setAlwaysAsk(on) {
                            controller.lastError = message
                        } else {
                            controller.lastError = nil
                        }
                    }
                }))
            Text(ProtectionCopy.alwaysAskSentence)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text(ProtectionCopy.enrolledFingerLine)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text(ProtectionCopy.alwaysAskNoCopyLine)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Picker(ProtectionCopy.idleLabel, selection: Binding(
                get: { controller.dials.relockAfterIdleMinutes ?? 0 },
                set: { controller.setRelockIdleMinutes($0 == 0 ? nil : $0) })
            ) {
                ForEach(ProtectionDials.idleChoices, id: \.self) { minutes in
                    Text(ProtectionCopy.idleChoiceLabel(minutes)).tag(minutes ?? 0)
                }
            }
            Text(ProtectionCopy.idleSentence + " " + ProtectionCopy.idleSubline)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Button(ProtectionCopy.lockNowLabel) {
                Task { await controller.performLock?() }
            }
            Text(ProtectionCopy.lockNowSentence + " ⌃⌘L does the same from anywhere.")
                .font(.caption)
                .foregroundStyle(.secondary)
            if let error = controller.lastError {
                Text(error).font(.caption).alarmVoice()
            }
        }
    }

    // MARK: The passphrase + phrase

    private var passphraseSection: some View {
        Section("Passphrase & twelve words") {
            LabeledContent("Encryption passphrase",
                           value: controller.hasPassphraseWrap ? "Set" : "Not set")
            LabeledContent("Twelve words",
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

    // MARK: The reminder (Castle — always on; one face: SecretCheck over the store road)

    @ViewBuilder
    private var reminderSection: some View {
        Section("Remembering your secrets") {
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
    }

    // MARK: Keystone 4 (the one line every posture shows)

    private var keystoneSection: some View {
        Section {
            Text(ProtectionCopy.keystoneOpenMeansReadable)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: Acts

    private func openSetSheet() {
        setSheetModel = PassphraseSetModel(
            controller: controller,
            vaultTie: VaultTie.make(services: services))
    }
}

// MARK: - The reset sheet (R13p-9's door — merged into change-passphrase at batch 5)

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
                 + "\(ProtectionCopy.biometryName) confirms it's you. The old "
                 + "passphrase stops working the moment the new one is set.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            PeekableSecretField(label: "New encryption passphrase", text: $newPassphrase)
                .textFieldStyle(.roundedBorder)
            PeekableSecretField(label: "Type it again", text: $confirmation)
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
                Button("Reset with \(ProtectionCopy.biometryName)") {
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
    @State private var migrationConfirm: MigrationConfirmModel?
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        Group {
            switch controller.notice {
            case .nudge: nudgeBar
            case .reminderDue: reminderBar
            case .migrationConfirm: migrationBar
            case nil: EmptyView()
            }
        }
        .sheet(item: $setSheetModel) { model in
            PassphraseSetSheet(model: model) { setSheetModel = nil }
        }
        .sheet(item: $migrationConfirm) { model in
            MigrationConfirmSheet(model: model) { migrationConfirm = nil }
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
    /// the recovery phrase either way. pre-13x 2a: the EXPOSED tier
    /// renders copy §5's nudge (Standard, no Apple key landed, no secrets).
    private var nudgeBar: some View {
        let exposed = controller.legs.tier == .exposed
        return bar {
            VStack(alignment: .leading, spacing: 2) {
                Text(exposed ? ProtectionCopy.exposedNudgeHeadline
                             : ProtectionCopy.nudgeHeadline)
                    .font(.callout.weight(.semibold))
                Text(exposed ? ProtectionCopy.exposedNudgeBody
                             : ProtectionCopy.nudgeBody)
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
                    // Ladder R2-m1: the offer consults the vault tie —
                    // an account that already carries the twelve words
                    // gets the EXTEND flow, never a second fresh phrase.
                    Task {
                        switch await PhraseOffer.take(
                            controller: controller,
                            vaultTie: VaultTie.make(services: services)) {
                        case .extend(let model): setSheetModel = model
                        case .minted(let words): phraseWords = words
                        case .refused: break
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

    /// pre-13x 2a (§11) — HER MIGRATION'S ONE-TIME MESSAGE (copy §9,
    /// verbatim): Confirm… opens the passphrase sheet; Later hides the
    /// face for this launch (the mark stays — the next ready asks again).
    private var migrationBar: some View {
        bar {
            Text(ProtectionCopy.migrationConfirmBody)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Button(ProtectionCopy.migrationConfirmDoor) {
                migrationConfirm = MigrationConfirmModel.make(
                    keyVault: services?.keyVault, controller: controller)
            }
            .disabled(services?.keyVault == nil)
            Button(ProtectionCopy.migrationLaterDoor) { controller.deferMigrationConfirm() }
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

/// pre-13x 2a (§11) — the confirm sheet: one passphrase field; the word is
/// verified against the vault and the local copy re-wrapped under the
/// vault's descriptor; then copy §9's done line.
struct MigrationConfirmSheet: View {
    @Bindable var model: MigrationConfirmModel
    var onDone: () -> Void

    @State private var passphrase = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            if model.done {
                Text(ProtectionCopy.migrationDoneBody)
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
                HStack { Spacer(); Button("Done") { onDone() }.keyboardShortcut(.defaultAction) }
            } else {
                Text(ProtectionCopy.migrationConfirmBody)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                PeekableSecretField(label: "Encryption passphrase", text: $passphrase)
                    .textFieldStyle(.roundedBorder)
                if let error = model.lastError {
                    Text(error).font(.callout).alarmVoice()
                        .fixedSize(horizontal: false, vertical: true)
                }
                if model.busy {
                    HStack(spacing: 6) {
                        ProgressView().controlSize(.small)
                        Text("Confirming…").font(.caption).foregroundStyle(.secondary)
                    }
                }
                HStack {
                    Button(ProtectionCopy.migrationLaterDoor) { onDone() }
                    Spacer()
                    Button("Confirm") {
                        Task { await model.confirm(passphrase: passphrase) }
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(model.busy || passphrase.isEmpty)
                }
            }
        }
        .padding(24)
        .frame(width: 440)
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
