//
//  MobileProtectionSheet.swift
//  VariorumMobile
//
//  Phase 13p, Batch 4 — THE PHONE'S PROTECTION SCREEN (the mobile-only-
//  user expansion's items (c) (f) (g) (h); PL-15). The Mac's Settings ▸
//  Protection pane, re-faced for the phone over the SAME brain
//  (`ProtectionController`, Shared) and the SAME words
//  (`ProtectionCopy`, Shared) — so a dial, a refusal or a consequence
//  sentence exists once and reads the same on both devices, with only the
//  platform nouns ("iPhone", "Face ID") riding interpolation.
//
//  THE PHONE IS A FIRST-CLASS BIRTHPLACE OF STORES (her rider at the
//  Batch-1 GO: *"some people will be mobile only users"*), so nothing
//  here assumes a Mac ever existed: the key was minted on this device at
//  its own first launch, the passphrase and the twelve words are set
//  HERE, and the loss math is stated for a library whose only home is
//  this phone (`ProtectionCopy.oneDeviceNote`).
//
//  The chrome follows the phone's own register — text-forward rows with
//  the voice's selection grammar, never a foreign control set (this app
//  ships no Toggle or Picker anywhere, deliberately). Placeholder voice,
//  honest content; 13s re-voices.
//

import SwiftUI
import VariorumCore

struct MobileProtectionSheet: View {
    /// The Settings door's word (voice-cased at render, pinned).
    static let doorTitle = "Protection & Encryption"

    @Bindable var controller: ProtectionController
    let services: AppServices?
    /// The bootstrap itself, NOT a captured `canLock` Bool (ladder R1-m2 —
    /// the exact staleness Batch 4's PROVISIONAL 5 warned about, one view
    /// lower: a Bool snapshot frozen at sheet construction kept the Lock
    /// Now door stale while the user flipped the mode INSIDE this very
    /// sheet). Reading `bootstrap.canLock` in the body tracks the
    /// observable dials projection, so a mode flip re-renders the door.
    let bootstrap: AppBootstrap?
    let tokens: VoiceTokens

    private var canLock: Bool { bootstrap?.canLock ?? false }

    @Environment(\.dismiss) private var dismiss

    @State private var setSheetModel: PassphraseSetModel?
    /// A demanded pick waiting on the passphrase-set screen — retried the
    /// moment it lands its wrap (the Mac pane's own choreography).
    @State private var pendingAfterSet: PendingAct?
    @State private var resetPresented = false
    @State private var reminderCheck: SecretCheckModel?

    enum PendingAct: Equatable {
        case mode(StoreAtOpenMode)
        case preset(ProtectionPreset)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    presetSection
                    divider
                    modeSection
                    divider
                    escrowSection
                    if controller.dials.mode.isDemanded {
                        divider
                        relockSection
                    }
                    divider
                    passphraseSection
                    divider
                    reminderSection
                }
                .padding(.bottom, 32)
            }
        }
        .background(tokens.room.ignoresSafeArea())
        .sheet(item: $setSheetModel) { model in
            MobilePassphraseSetSheet(model: model, tokens: tokens) {
                setSheetModel = nil
                Task { await retryPendingAct() }
            }
        }
        .sheet(isPresented: $resetPresented) {
            MobilePassphraseResetSheet(controller: controller, tokens: tokens) {
                resetPresented = false
            }
        }
        .task { await services?.encryption.refresh() }
    }

    // MARK: - Chrome

    private var header: some View {
        HStack {
            Text(tokens.path(["Protection"]))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            Spacer()
            Button {
                dismiss()
            } label: {
                Text(tokens.chromeLabel("Done"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 14)
    }

    private var divider: some View {
        Divider()
            .overlay(tokens.line)
            .padding(.vertical, 14)
    }

    private func sectionHeader(_ text: String) -> some View {
        Text(tokens.chromeLabel(text))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .padding(.horizontal, 20)
            .padding(.bottom, 6)
    }

    private func prose(_ text: String) -> some View {
        Text(text)
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 20)
            .padding(.top, 6)
    }

    private func alarm(_ text: String) -> some View {
        Text(text)
            .font(tokens.small)
            .foregroundStyle(tokens.alarm)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 20)
            .padding(.top, 6)
    }

    /// One selectable row in the phone's grammar (`MobileSettingsView`'s
    /// voice rows): the terminal `›` marker carries the selection, study
    /// renders a ✓.
    private func choiceRow(
        _ label: String, selected: Bool, enabled: Bool = true, act: @escaping () -> Void
    ) -> some View {
        Button(action: act) {
            HStack(spacing: 4) {
                if !tokens.selectionMarker.isEmpty {
                    Text(tokens.selectionMarker)
                        .font(tokens.body)
                        .foregroundStyle(tokens.accent)
                        .opacity(selected ? 1 : 0)
                }
                Text(tokens.chromeLabel(label))
                    .font(tokens.body)
                    .foregroundStyle(enabled ? (selected ? tokens.ink : tokens.muted)
                                             : tokens.faint)
                if selected, tokens.selectionMarker.isEmpty {
                    Text("✓").font(tokens.small).foregroundStyle(tokens.accent)
                }
                Spacer()
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 20)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .accessibilityLabel(label)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    /// A dial row: the phone's toggle, in the phone's own register.
    private func dialRow(_ label: String, on: Bool, act: @escaping () -> Void) -> some View {
        Button(action: act) {
            HStack {
                Text(tokens.chromeLabel(label))
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .multilineTextAlignment(.leading)
                Spacer()
                Text(tokens.chromeLabel(on ? "on" : "off"))
                    .font(tokens.small)
                    .foregroundStyle(on ? tokens.accent : tokens.faint)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 20)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityValue(on ? "on" : "off")
    }

    private func door(_ label: String, act: @escaping () -> Void) -> some View {
        Button(action: act) {
            Text(tokens.chromeLabel(label))
                .font(tokens.body)
                .foregroundStyle(tokens.accent)
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    // MARK: - Presets (R13p-7)

    private var presetSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Protection")
            ForEach(ProtectionPreset.allCases, id: \.self) { preset in
                choiceRow(
                    ProtectionCopy.presetTitle(preset),
                    selected: controller.matchingPreset == preset
                ) {
                    Task { await apply(.preset(preset)) }
                }
                prose(ProtectionCopy.presetBlurb(preset))
            }
            if controller.matchingPreset == nil {
                prose("Your dials are hand-adjusted — they match neither preset, "
                      + "which is fine: presets set the dials, the dials rule.")
            }
        }
    }

    // MARK: - The at-open mode (R13p-5)

    private var modeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Opening Variorum")
            ForEach(StoreAtOpenMode.allCases, id: \.self) { mode in
                let available = mode != .biometric || controller.biometryAvailable
                choiceRow(
                    ProtectionCopy.modeLabel(mode),
                    selected: controller.dials.mode == mode,
                    enabled: available
                ) {
                    Task { await apply(.mode(mode)) }
                }
            }
            prose(ProtectionCopy.modeSentence(controller.dials.mode))
            prose(ProtectionCopy.lossMath(
                controller.dials.mode, escrowOn: controller.dials.escrowOn))
            // Item (h): a phone-only library has ONE enrolled device, so
            // the chain above is shorter than a reader may assume — say so.
            prose(ProtectionCopy.oneDeviceNote)
            // The named non-goal, said where the reader is choosing.
            prose(ProtectionCopy.openAppIsReadable)
            if let error = controller.lastError {
                alarm(error)
            }
        }
    }

    // MARK: - Escrow (R13p-6, knot 8's ruled pair)

    /// THE ESCROW/POSTURE COUPLING (ninth wave — memo §4; ONE posture per
    /// account, the R-pre13u-8(f) parity rule): demanded modes do not OFFER
    /// the spare — the same brain and the same sentences as the Mac's pane.
    private var escrowSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("iCloud spare key")
            if controller.dials.mode.isDemanded {
                prose(ProtectionCopy.escrowNotOfferedUnderDemanded)
                if controller.dials.escrowOn {
                    prose(ProtectionCopy.escrowChoiceKeptNote)
                }
            } else {
                dialRow("Keep a spare key in iCloud Keychain",
                        on: controller.dials.escrowOn) {
                    let next = !controller.dials.escrowOn
                    Task { _ = await controller.setEscrow(next) }
                }
                prose(controller.dials.escrowOn
                      ? ProtectionCopy.escrowOn : ProtectionCopy.escrowOff)
                if controller.dials.escrowOn {
                    if controller.escrowLandingFailed {
                        alarm("The copy could not actually be saved — the Keychain refused "
                              + "it. The dial is on, but no copy exists yet; your other "
                              + "legs stand.")
                    }
                    prose(ProtectionCopy.escrowNeedsICloudKeychain)
                    // The compound warning (memo §3) rides the ON state here
                    // exactly as on the Mac.
                    prose(ProtectionShapes.compoundWarning)
                }
            }
        }
    }

    // MARK: - Re-lock (demanded modes only) — item (g)

    private var relockSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Locking while you're away")
            dialRow(ProtectionCopy.relockOnBackgroundLabel,
                    on: controller.dials.relockOnSleepAndScreenLock) {
                controller.setRelockOnSleep(!controller.dials.relockOnSleepAndScreenLock)
            }
            prose(ProtectionCopy.relockOnBackgroundSentence)
            sectionHeader(ProtectionCopy.relockAfterAwayLabel)
                .padding(.top, 10)
            ForEach(MobileRelockPolicy.awayChoices, id: \.self) { minutes in
                choiceRow(
                    MobileRelockPolicy.awayLabel(minutes),
                    selected: (controller.dials.relockAfterIdleMinutes ?? 0) == minutes
                ) {
                    controller.setRelockIdleMinutes(minutes == 0 ? nil : minutes)
                }
            }
            if canLock {
                door(ProtectionCopy.lockNowLabel) {
                    Task { await controller.performLock?() }
                }
                prose(ProtectionCopy.lockNowSentence)
            }
        }
    }

    // MARK: - The passphrase + phrase (knot 4; R13p-9's reset door)

    private var passphraseSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Passphrase & recovery phrase")
            statusRow("Encryption passphrase",
                      controller.hasPassphraseWrap ? "Set" : "Not set")
            statusRow("Recovery phrase",
                      controller.hasRecoveryWrap ? "On file" : "Not saved")
            door(controller.hasPassphraseWrap ? "Change Passphrase…" : "Set a Passphrase…") {
                openSetSheet()
            }
            if controller.hasPassphraseWrap {
                door("Forgot It? Reset…") { resetPresented = true }
            }
            prose("The passphrase and the twelve words are the ways back into this "
                  + "library when this iPhone's Keychain can't help. Nothing is sent "
                  + "anywhere; both work offline.")
        }
    }

    private func statusRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(tokens.chromeLabel(label))
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
            Spacer()
            Text(tokens.chromeLabel(value))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
        .accessibilityElement(children: .combine)
    }

    // MARK: - The reminder (R13p-9 — one face: SecretCheck over the store road)

    @ViewBuilder
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Remembering your secrets")
            dialRow("Check in on the passphrase now and then",
                    on: controller.dials.reminderChecksOn) {
                controller.setReminderChecks(!controller.dials.reminderChecksOn)
            }
            prose("A secret you never type is a secret that slips away. When this is "
                  + "on, Variorum occasionally asks whether you still remember it — "
                  + "a rehearsal, never a reset.")
            if controller.hasPassphraseWrap || controller.hasRecoveryWrap {
                checkSection
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .environment(\.sharedPageStyle, SharedPageStyle(tokens: tokens))
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

    // MARK: - Acts (the Mac pane's choreography, unchanged)

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
        guard controller.hasPassphraseWrap else { return }  // the screen was cancelled
        await apply(act)
    }
}
