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
            // Item 3's CENTERPIECE (her sixth-wave escalation): the LIVE
            // ways-back-in checklist leads the pane — the actual legs this
            // device/account has right now, truthfully, before any dial.
            checklistSection
            presetSection
            modeSection
            escrowSection
            if controller.dials.mode.isDemanded {
                relockSection
            }
            passphraseSection
            reminderSection
            explainerPointerSection
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

    // MARK: The live checklist (item 3's centerpiece)

    /// The actual legs this device/account has RIGHT NOW — present/absent/
    /// unknown, truthfully (ONE brain: `ProtectionShapes.checklistRows`,
    /// which both platforms compose). Under an unreadable sidecar the wrap
    /// rows are withheld and T2's unknown sentence stands in — "can't
    /// tell" is never dressed as either comfort or alarm.
    private var checklistSection: some View {
        Section("Ways back in — right now") {
            ForEach(
                ProtectionShapes.checklistRows(
                    controller.legs, mode: controller.dials.mode),
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
            // The current mode's "what YOU need" (memo §5) — yours, not
            // the whole matrix (the explainer tab carries all four).
            let need = ProtectionShapes.currentNeedState(
                mode: controller.dials.mode,
                hasAnySecret: controller.hasPassphraseWrap || controller.hasRecoveryWrap,
                syncOn: services?.sync.isConfigured ?? false)
            Text("Day to day: \(need.daily) If this "
                 + "\(ProtectionCopy.deviceName) dies: \(need.computerDies)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text(need.floor)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func mark(for present: Bool?) -> String {
        switch present {
        case true: return "checkmark.circle.fill"
        case false: return "circle"
        case nil: return "questionmark.circle"
        }
    }

    // MARK: Presets (R13p-7)

    private var presetSection: some View {
        Section("Protection") {
            HStack(spacing: 12) {
                // 13p Batch 4's copy sweep: preset words come from the ONE
                // vocabulary now (`ProtectionCopy`), so the phone's face
                // and this pane cannot drift apart. Byte-identical here.
                presetButton(.standard, title: ProtectionCopy.presetTitle(.standard),
                             blurb: ProtectionCopy.presetBlurb(.standard))
                presetButton(.lockedDown, title: ProtectionCopy.presetTitle(.lockedDown),
                             blurb: ProtectionCopy.presetBlurb(.lockedDown))
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
                Text(ProtectionCopy.modeLabel(.auto)).tag(StoreAtOpenMode.auto)
                Text(ProtectionCopy.modeLabel(.biometric)).tag(StoreAtOpenMode.biometric)
                    .selectionDisabled(!controller.biometryAvailable)
                Text(ProtectionCopy.modeLabel(.passphrase)).tag(StoreAtOpenMode.passphrase)
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
            // Item 3's ?-disclosure (her amended copy doctrine): the mode's
            // longer honesty paragraphs collapse behind one door — nothing
            // lost, nothing stacked. The content is a NAMED view so the
            // P47 pin hosts it directly (the re-anchor's mechanism).
            DisclosureGroup("More about what this protects") {
                ModeHonestyDisclosure(mode: controller.dials.mode)
                    .padding(.top, 4)
            }
            .font(.caption)
            if let error = controller.lastError {
                Text(error).font(.caption).alarmVoice()
            }
        }
    }

    // MARK: Escrow (R13p-6, knot 8's ruled pair)

    /// THE ESCROW/POSTURE COUPLING (ninth wave — memo §4): demanded modes
    /// do not OFFER the iCloud spare — her why-sentence stands where the
    /// dial would, and the stored Auto choice is named as kept. The old
    /// `escrowUnderDemandedMode` caveat described a state (spare beside a
    /// demanded gate) that can no longer exist and is superseded.
    @ViewBuilder
    private var escrowSection: some View {
        Section("iCloud spare key") {
            if controller.dials.mode.isDemanded {
                Text(ProtectionCopy.escrowNotOfferedUnderDemanded)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                if controller.dials.escrowOn {
                    Text(ProtectionCopy.escrowChoiceKeptNote)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                Toggle("Keep a spare key in iCloud Keychain", isOn: Binding(
                    get: { controller.dials.escrowOn },
                    set: { on in Task { _ = await controller.setEscrow(on) } }))
                Text(controller.dials.escrowOn
                     ? ProtectionCopy.escrowOn : ProtectionCopy.escrowOff)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                if controller.dials.escrowOn && controller.escrowLandingFailed {
                    Text("The copy could not actually be saved — this Mac's Keychain "
                         + "refused it (the app's current signing can't reach the "
                         + "iCloud-synced keychain). The dial is on, but no copy "
                         + "exists yet; your other legs stand.")
                        .font(.caption)
                        .alarmVoice()
                        .fixedSize(horizontal: false, vertical: true)
                }
                if controller.dials.escrowOn {
                    Text(ProtectionCopy.escrowNeedsICloudKeychain)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    // The compound warning (memo §3, ships in copy): iCloud
                    // holding both the copies and the key means one account
                    // is everything — a read sentence, not a refusal.
                    Text(ProtectionShapes.compoundWarning)
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
            Button(ProtectionCopy.lockNowLabel) {
                Task { await controller.performLock?() }
            }
            Text(ProtectionCopy.lockNowSentence + " ⌃⌘L does the same from anywhere.")
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

    // MARK: The explainer pointer (seventh wave (iii): settings explains
    // AND points; the deep teaching lives in the tutorial)

    private var explainerPointerSection: some View {
        Section("How protection works") {
            Text("The full picture — the recipes for opening your writing, the "
                 + "two shapes, and what you'd need on a bad day — is the "
                 + "“How Protection Works” tab above. The field guide teaches "
                 + "it in place: the “keeping it private” chapter.")
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

// MARK: - The mode-honesty disclosure (item 3's ?-depth, extracted)

/// The mode section's longer honesty paragraphs — one-device, the named
/// non-goal, and (under a demanded mode) the lobby-fallback truth. A NAMED
/// view precisely so the P47 render pin can host it directly: collapsed
/// disclosure content is absent from a composition dump, and a pin that
/// cannot see the sentences cannot police them.
struct ModeHonestyDisclosure: View {
    let mode: StoreAtOpenMode

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 13p Batch 4 (item (h)): a list of same-device legs can let a
            // reader assume a second machine holds a copy. It doesn't,
            // unless sync is on.
            Text(ProtectionCopy.oneDeviceNote)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            // The NAMED NON-GOAL (13p Batch 4's honest-copy sweep).
            Text(ProtectionCopy.openAppIsReadable)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if mode.isDemanded {
                // Seventh wave (ii): the demanded-mode fallback, stated
                // truthfully where the mode is chosen.
                Text(ProtectionShapes.demandedFallbackTruth)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

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
