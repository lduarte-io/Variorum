//
//  MobileProtectionCeremonies.swift
//  VariorumMobile
//
//  Phase 13p, Batch 4 — the phone's THREE protection ceremonies (the
//  mobile-only-user expansion's items (d) (e) (h)):
//
//  · **The passphrase-set screen** (item d), knot 4's one-moment-two-
//    artifacts in phone form: set the passphrase, and the twelve words
//    generate and display ON THAT SAME SCREEN, `privacySensitive` so the
//    app-switcher snapshot cover redacts them (the 14b SnapshotPrivacy
//    precedent, which is already wired app-wide). The choreography is the
//    SHARED `PassphraseSetModel` — hoisted out of the Mac's pane this
//    batch — so one-secret verification against the account vault, the
//    extend-the-existing-phrase road and every refusal are written once.
//  · **The reset door** (item h / R13p-9): a Face ID-confirmed re-wrap
//    under a new passphrase, no old passphrase needed.
//  · **The Standard nudge** (item e) in her ruled TWO-OFFER shape —
//    create a passphrase (the set screen, phrase alongside) AND the
//    recovery phrase either way — as a calm, dismissible banner. Never
//    modal: it is an offer, and an offer that blocks the app is a demand.
//
//  Placeholder voice, honest content; 13s re-voices.
//

import SwiftUI
import VariorumCore

// MARK: - The set screen (item d)

struct MobilePassphraseSetSheet: View {
    @Bindable var model: PassphraseSetModel
    let tokens: VoiceTokens
    var onDone: () -> Void

    @State private var passphrase = ""
    @State private var confirmation = ""
    @State private var typedWords = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                switch model.phase {
                case .enterPassphrase: enterPassphrase
                case .showPhrase(let words): showPhrase(words)
                case .extendExistingPhrase: extendPhrase
                case .done: done
                }
                if model.busy {
                    HStack(spacing: 6) {
                        ProgressView()
                        Text(tokens.chromeLabel("Working…"))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                    }
                }
                if let error = model.lastError {
                    Text(error)
                        .font(tokens.small)
                        .foregroundStyle(tokens.alarm)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(tokens.room.ignoresSafeArea())
    }

    @ViewBuilder
    private var enterPassphrase: some View {
        heading("Set your encryption passphrase")
        prose(model.vaultConstrains
              ? "Your account already has an encryption passphrase, and one "
                + "passphrase serves both — type that same one here to make it "
                + "unlock this library too."
              : "One passphrase, chosen by you, never sent anywhere. It can unlock "
                + "this library when the Keychain can't — or at every open, if you "
                + "ask for that.")
        secureField("Encryption passphrase", $passphrase)
        secureField("Type it again", $confirmation)
        HStack {
            door("Cancel") { onDone() }
            Spacer()
            door("Set Passphrase", prominent: true) {
                Task { await model.commit(
                    passphrase: passphrase, confirmation: confirmation) }
            }
            .disabled(model.busy || passphrase.isEmpty)
        }
    }

    @ViewBuilder
    private func showPhrase(_ words: [String]) -> some View {
        heading("Your recovery phrase")
        prose("Twelve words that can unlock this library if everything else is "
              + "gone. Write them down somewhere real — they are shown now, and "
              + "never again.")
        phraseGrid(words)
            .privacySensitive()
        HStack {
            Spacer()
            door("I've written them down", prominent: true) {
                model.acknowledgePhraseWritten()
                onDone()
            }
        }
    }

    @ViewBuilder
    private var extendPhrase: some View {
        heading("Your account already has a recovery phrase")
        prose("Type those same twelve words to make them unlock this library too — "
              + "one phrase serves both. You can skip this; the passphrase is set "
              + "either way.")
        TextField("The 12 words, separated by spaces", text: $typedWords, axis: .vertical)
            .lineLimit(3, reservesSpace: true)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .privacySensitive()
            .font(tokens.body)
            .foregroundStyle(tokens.ink)
            .padding(EdgeInsets(top: 11, leading: 12, bottom: 11, trailing: 12))
            .background(fieldChrome)
        HStack {
            door("Skip") {
                model.skipPhrase()
                onDone()
            }
            Spacer()
            door("Extend It to This Library", prominent: true) {
                Task {
                    await model.extendPhrase(typed: typedWords)
                    if model.phase == .done { onDone() }
                }
            }
            .disabled(model.busy || typedWords.trimmingCharacters(
                in: .whitespacesAndNewlines).isEmpty)
        }
    }

    @ViewBuilder
    private var done: some View {
        heading("Done")
        prose("The passphrase is set.")
        HStack { Spacer(); door("Close", prominent: true) { onDone() } }
    }

    // MARK: chrome

    private func heading(_ text: String) -> some View {
        Text(tokens.chromeLabel(text))
            .font(tokens.title)
            .foregroundStyle(tokens.ink)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func prose(_ text: String) -> some View {
        Text(text)
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var fieldChrome: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(tokens.card)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1))
    }

    private func secureField(_ prompt: String, _ text: Binding<String>) -> some View {
        // The ONE eye/peek control (Act 10 item 3) — chrome stays this
        // surface's own.
        PeekableSecretField(label: prompt, text: text)
            .font(tokens.body)
            .foregroundStyle(tokens.ink)
            .padding(EdgeInsets(top: 11, leading: 12, bottom: 11, trailing: 12))
            .background(fieldChrome)
    }

    private func door(
        _ label: String, prominent: Bool = false, act: @escaping () -> Void
    ) -> some View {
        Button(action: act) {
            Text(tokens.chromeLabel(label))
                .font(tokens.body)
                .foregroundStyle(prominent ? tokens.accent : tokens.muted)
                .padding(.vertical, 9)
                .padding(.horizontal, prominent ? 14 : 0)
                .background {
                    if prominent {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(tokens.surface)
                            .overlay(RoundedRectangle(cornerRadius: 8)
                                .stroke(tokens.line, lineWidth: 1))
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func phraseGrid(_ words: [String]) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                  alignment: .leading, spacing: 6) {
            ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                Text("\(index + 1). \(word)")
                    .font(tokens.mono)
                    .foregroundStyle(tokens.ink)
                    .textSelection(.enabled)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(fieldChrome)
    }
}

// MARK: - The reset door (item h / R13p-9)

struct MobilePassphraseResetSheet: View {
    let controller: ProtectionController
    let tokens: VoiceTokens
    var onDone: () -> Void

    @State private var newPassphrase = ""
    @State private var confirmation = ""
    @State private var busy = false
    @State private var error: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(tokens.chromeLabel("Reset your encryption passphrase"))
                    .font(tokens.title)
                    .foregroundStyle(tokens.ink)
                Text("You don't need the old one — this iPhone still holds the key, "
                     + "and \(ProtectionCopy.biometryName) confirms it's you. The old "
                     + "passphrase stops working the moment the new one is set.")
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
                field("New encryption passphrase", $newPassphrase)
                field("Type it again", $confirmation)
                if let error {
                    Text(error)
                        .font(tokens.small)
                        .foregroundStyle(tokens.alarm)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if busy {
                    HStack(spacing: 6) {
                        ProgressView()
                        Text(tokens.chromeLabel("Confirming…"))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                    }
                }
                HStack {
                    Button(tokens.chromeLabel("Cancel")) { onDone() }
                        .font(tokens.body)
                        .foregroundStyle(tokens.muted)
                        .buttonStyle(.plain)
                    Spacer()
                    Button(tokens.chromeLabel(
                        "Reset with \(ProtectionCopy.biometryName)")) {
                        Task { await reset() }
                    }
                    .font(tokens.body)
                    .foregroundStyle(tokens.accent)
                    .buttonStyle(.plain)
                    .disabled(busy || newPassphrase.isEmpty)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(tokens.room.ignoresSafeArea())
    }

    private func field(_ prompt: String, _ text: Binding<String>) -> some View {
        // The ONE eye/peek control (Act 10 item 3).
        PeekableSecretField(label: prompt, text: text)
            .font(tokens.body)
            .foregroundStyle(tokens.ink)
            .padding(EdgeInsets(top: 11, leading: 12, bottom: 11, trailing: 12))
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(tokens.card)
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(tokens.line, lineWidth: 1)))
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

// MARK: - The nudge (item e — her ruled two-offer shape, calm and dismissible)

struct MobileProtectionNoticeBar: View {
    @Bindable var controller: ProtectionController
    let services: AppServices?
    let tokens: VoiceTokens

    @State private var setSheetModel: PassphraseSetModel?
    @State private var phraseWords: [String]?
    @State private var migrationConfirm: MigrationConfirmModel?
    /// The protection screen's door from the reminder notice — the shell
    /// wires it (Settings is a sheet, so the bar cannot present it itself
    /// without stacking two sheets on one presenter).
    var openProtection: (() -> Void)?

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
            MobilePassphraseSetSheet(model: model, tokens: tokens) { setSheetModel = nil }
        }
        .sheet(item: $migrationConfirm) { model in
            MobileMigrationConfirmSheet(model: model, tokens: tokens) { migrationConfirm = nil }
        }
        .sheet(isPresented: Binding(
            get: { phraseWords != nil }, set: { if !$0 { phraseWords = nil } })
        ) {
            if let words = phraseWords {
                MobilePhraseOnlySheet(words: words, tokens: tokens) { phraseWords = nil }
            }
        }
    }

    /// Knot 4's ruled two-offer shape: create a passphrase (the set
    /// screen, phrase alongside) AND the recovery phrase either way.
    private var nudgeBar: some View {
        bar {
            Text(ProtectionCopy.nudgeHeadline)
                .font(tokens.small)
                .foregroundStyle(tokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            Text(ProtectionCopy.nudgeBody)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 16) {
                offer(ProtectionCopy.nudgeOfferPassphrase) {
                    setSheetModel = PassphraseSetModel(
                        controller: controller,
                        vaultTie: VaultTie.make(services: services))
                }
                if !controller.hasRecoveryWrap {
                    offer(ProtectionCopy.nudgeOfferPhrase) {
                        // Ladder R2-m1: the offer consults the vault tie —
                        // an account that already carries the twelve words
                        // gets the EXTEND flow, never a second fresh
                        // phrase (the shared `PhraseOffer` rule; one flow,
                        // both platforms).
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
                Spacer()
                offer(ProtectionCopy.nudgeLater, quiet: true) { controller.snoozeNudge() }
                Button {
                    controller.dismissNudgeForever()
                } label: {
                    Image(systemName: "xmark")
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Don't offer again")
            }
        }
    }

    private var reminderBar: some View {
        bar {
            Text(ProtectionCopy.reminderHeadline)
                .font(tokens.small)
                .foregroundStyle(tokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 16) {
                offer("Check It…") {
                    controller.dismissReminder()
                    openProtection?()
                }
                Spacer()
                offer("Later", quiet: true) { controller.dismissReminder() }
            }
        }
    }

    /// pre-13x 2a (§11) — HER MIGRATION'S ONE-TIME MESSAGE on the phone
    /// (copy §9, verbatim; the phone's nouns ride the interpolation).
    private var migrationBar: some View {
        bar {
            Text(ProtectionCopy.migrationConfirmBody)
                .font(tokens.small)
                .foregroundStyle(tokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 16) {
                offer(ProtectionCopy.migrationConfirmDoor) {
                    migrationConfirm = MigrationConfirmModel.make(
                        keyVault: services?.keyVault, controller: controller)
                }
                Spacer()
                offer(ProtectionCopy.migrationLaterDoor, quiet: true) {
                    controller.deferMigrationConfirm()
                }
            }
        }
    }

    private func offer(
        _ label: String, quiet: Bool = false, act: @escaping () -> Void
    ) -> some View {
        Button(action: act) {
            Text(tokens.chromeLabel(label))
                .font(tokens.small)
                .foregroundStyle(quiet ? tokens.muted : tokens.accent)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func bar<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) { content() }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tokens.surface)
            .overlay(alignment: .bottom) {
                Rectangle().fill(tokens.line).frame(height: 1)
            }
    }
}

/// pre-13x 2a (§11) — the phone's confirm sheet: one passphrase field; the
/// word is verified against the vault and the local copy re-wrapped under
/// the vault's descriptor; then copy §9's done line.
struct MobileMigrationConfirmSheet: View {
    @Bindable var model: MigrationConfirmModel
    let tokens: VoiceTokens
    var onDone: () -> Void

    @State private var passphrase = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if model.done {
                    Text(ProtectionCopy.migrationDoneBody)
                        .font(tokens.body)
                        .foregroundStyle(tokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Button(tokens.chromeLabel("Done")) { onDone() }
                        .font(tokens.body)
                        .foregroundStyle(tokens.accent)
                        .buttonStyle(.plain)
                } else {
                    Text(ProtectionCopy.migrationConfirmBody)
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .fixedSize(horizontal: false, vertical: true)
                    PeekableSecretField(
                        label: "Encryption passphrase", text: $passphrase,
                        onSubmit: { Task { await model.confirm(passphrase: passphrase) } })
                        .font(tokens.body)
                        .foregroundStyle(tokens.ink)
                        .padding(EdgeInsets(top: 11, leading: 12, bottom: 11, trailing: 12))
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(tokens.card)
                                .overlay(RoundedRectangle(cornerRadius: 8)
                                    .stroke(tokens.line, lineWidth: 1)))
                    if let error = model.lastError {
                        Text(error)
                            .font(tokens.small)
                            .foregroundStyle(tokens.alarm)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    HStack(spacing: 16) {
                        Button(tokens.chromeLabel("Confirm")) {
                            Task { await model.confirm(passphrase: passphrase) }
                        }
                        .font(tokens.body)
                        .foregroundStyle(tokens.accent)
                        .buttonStyle(.plain)
                        .disabled(model.busy || passphrase.isEmpty)
                        Spacer()
                        Button(tokens.chromeLabel(ProtectionCopy.migrationLaterDoor)) { onDone() }
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .buttonStyle(.plain)
                    }
                }
            }
            .padding(24)
        }
        .background(tokens.room.ignoresSafeArea())
    }
}

/// The nudge's phrase-only road: the twelve words, shown once.
struct MobilePhraseOnlySheet: View {
    let words: [String]
    let tokens: VoiceTokens
    var onDone: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(tokens.chromeLabel("Your recovery phrase"))
                    .font(tokens.title)
                    .foregroundStyle(tokens.ink)
                Text("Twelve words that can unlock this library if this iPhone is "
                     + "lost. Write them down somewhere real — they are shown now, "
                     + "and never again.")
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                          alignment: .leading, spacing: 6) {
                    ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                        Text("\(index + 1). \(word)")
                            .font(tokens.mono)
                            .foregroundStyle(tokens.ink)
                            .textSelection(.enabled)
                    }
                }
                .privacySensitive()
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(tokens.card)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(tokens.line, lineWidth: 1)))
                HStack {
                    Spacer()
                    Button(tokens.chromeLabel("I've written them down")) { onDone() }
                        .font(tokens.body)
                        .foregroundStyle(tokens.accent)
                        .buttonStyle(.plain)
                }
            }
            .padding(24)
        }
        .background(tokens.room.ignoresSafeArea())
    }
}
