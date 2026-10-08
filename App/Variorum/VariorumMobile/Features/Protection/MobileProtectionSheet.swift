//
//  MobileProtectionSheet.swift
//  VariorumMobile
//
//  Phase 13p, Batch 4 — THE PHONE'S PROTECTION SCREEN (PL-15). pre-13x
//  batch 2a — THE POSTURE SCREEN: the Mac's Settings ▸ Protection pane,
//  re-faced for the phone over the SAME brain (`ProtectionController`,
//  Shared) and the SAME words (`ProtectionCopy` + `PostureCopy`, Shared —
//  copy §1 verbatim, the platform nouns riding interpolation): the
//  current-state line, the two posture cards, Castle's two switches +
//  Lock Now (shown only in Castle), keystone 4. The presets, the at-open
//  picker, the escrow dial and the reminder dial are GONE (§13); the
//  choose doors are batch 2b's (P-2: unrendered until they act).
//
//  THE PHONE IS A FIRST-CLASS BIRTHPLACE OF STORES (her rider at the
//  Batch-1 GO: *"some people will be mobile only users"*) and of Castle
//  (design §9), so nothing here assumes a Mac ever existed.
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
    /// reading `bootstrap.canLock` in the body tracks the observable
    /// projection, so a gate change re-renders the door).
    let bootstrap: AppBootstrap?
    let tokens: VoiceTokens

    private var canLock: Bool { bootstrap?.canLock ?? false }

    @Environment(\.dismiss) private var dismiss

    @State private var setSheetModel: PassphraseSetModel?
    @State private var reminderCheck: SecretCheckModel?
    /// pre-13x 2c: a switch left unfinished (the persisted marker) — the
    /// chooser's door becomes *Finish…* (read per open, like the Mac).
    @State private var pendingSwitch: RotationMarker?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    leadSection
                    divider
                    postureSection
                    if controller.posture == .castle {
                        divider
                        castleSwitchesSection
                    }
                    divider
                    passphraseSection
                    if controller.posture == .castle,
                       controller.hasPassphraseWrap || controller.hasRecoveryWrap {
                        divider
                        reminderSection
                    }
                    divider
                    prose(ProtectionCopy.keystoneOpenMeansReadable)
                }
                .padding(.bottom, 32)
            }
        }
        .background(tokens.room.ignoresSafeArea())
        .sheet(item: $setSheetModel) { model in
            MobilePassphraseSetSheet(model: model, tokens: tokens) {
                setSheetModel = nil
            }
        }
        // pre-13x 2c: the ceremony and the follow, held on the controller
        // (they survive the re-key's reopen), faced for the phone.
        .sheet(item: Binding(
            get: { controller.activeSwitch },
            set: { if $0 == nil { controller.closeSwitch() } })
        ) { model in
            MobilePostureSwitchSheet(model: model, tokens: tokens) { controller.closeSwitch() }
        }
        .sheet(item: Binding(
            get: { controller.activeFollow },
            set: { if $0 == nil { controller.closeFollow() } })
        ) { model in
            MobileFollowSheet(model: model, tokens: tokens) { controller.closeFollow() }
        }
        .task { await services?.encryption.refresh() }
        .task(id: controller.activeSwitch?.id) {
            pendingSwitch = await controller.switchRunner?.pendingMarker()
        }
    }

    // MARK: - Chrome

    private var header: some View {
        HStack {
            Text(tokens.path([ProtectionCopy.protectionPaneTitle]))
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

    // MARK: - The lead: keystone 1 + the current-state line + the legs

    private var leadSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            prose(ProtectionCopy.keystoneOneMode)
            Text(ProtectionCopy.currentStateLine(controller.posture))
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
                .padding(.top, 10)
            // R-pre13u-4's standing ways-back-in line — the SAME brain as
            // the Mac's checklist, so the two can never disagree.
            prose(ProtectionCopy.waysBackInLine(controller.legs))
            prose(ProtectionCopy.nudgeSentence(for: controller.legs.tier))
            // Item (h): a phone-only library has ONE enrolled device, so
            // the chain above is shorter than a reader may assume — say so.
            prose(ProtectionCopy.oneDeviceNote)
            if controller.appleKeyLandingFailed {
                alarm("Your Apple account hasn't been able to take a key yet — this "
                      + "iPhone's Keychain refused to keep the iCloud key, so no copy "
                      + "exists beyond this iPhone; your other ways back in stand.")
            }
        }
    }

    // MARK: - The two posture cards (copy §1)

    private var postureSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Standard or Castle")
            ForEach([Posture.standard, Posture.castle], id: \.self) { posture in
                postureCard(posture)
            }
            // pre-13x 2c: THE CHOOSE DOORS (copy §1's Use Castle… / Use
            // Standard; a switch left unfinished shows Finish…) — rendered
            // only when the runner is wired (P-2: a door that acts), and
            // replaced by the one sentence while a follow is owed.
            if controller.followPending {
                alarm(ProtectionCopy.pickUpKeysFirst)
            } else if controller.switchRunner != nil {
                if let pending = pendingSwitch {
                    door(pending.entersCastle
                         ? ProtectionCopy.finishEnteringCastleDoor
                         : ProtectionCopy.finishReplacingKeysDoor) {
                        controller.openSwitch(.resume(pending), vaultTie: VaultTie.make(services: services))
                    }
                    // VX-99 round 2b: by the marker's act (F1's selector).
                    alarm(ProtectionCopy.ceremonyResumeTitle(CeremonyAct(resuming: pending)))
                } else if controller.posture == .standard {
                    door(ProtectionCopy.useCastleDoor) {
                        controller.openSwitch(.enter, vaultTie: VaultTie.make(services: services))
                    }
                } else {
                    door(ProtectionCopy.useStandardDoor) {
                        controller.openSwitch(.leave, vaultTie: VaultTie.make(services: services))
                    }
                }
            }
        }
    }

    private func postureCard(_ posture: Posture) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(tokens.chromeLabel(ProtectionCopy.postureName(posture)))
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                Text(tokens.chromeLabel(ProtectionCopy.postureTag(posture)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                if controller.posture == posture {
                    Text(tokens.chromeLabel("current"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
            }
            Text(ProtectionCopy.postureOneLine(posture))
                .font(tokens.small)
                .foregroundStyle(tokens.ink)
                .fixedSize(horizontal: false, vertical: true)
            ForEach(ProtectionCopy.postureCard(posture), id: \.label) { row in
                Text(row.label + " — " + row.text)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(ProtectionCopy.postureName(posture))
    }

    // MARK: - Castle's switches (shown only in Castle — copy §1)

    private var castleSwitchesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader(ProtectionCopy.postureName(.castle))
            dialRow(ProtectionCopy.alwaysAskLabel, on: controller.dials.alwaysAsk) {
                let next = !controller.dials.alwaysAsk
                Task {
                    if case .refused(let message) = await controller.setAlwaysAsk(next) {
                        controller.lastError = message
                    } else {
                        controller.lastError = nil
                    }
                }
            }
            prose(ProtectionCopy.alwaysAskSentence)
            prose(ProtectionCopy.enrolledFingerLine)
            prose(ProtectionCopy.alwaysAskNoCopyLine)
            sectionHeader(ProtectionCopy.idleLabel)
                .padding(.top, 10)
            prose(ProtectionCopy.idleSentence)
            ForEach(MobileRelockPolicy.awayChoices, id: \.self) { minutes in
                choiceRow(
                    MobileRelockPolicy.awayLabel(minutes),
                    selected: controller.dials.relockAfterIdleMinutes == minutes
                ) {
                    controller.setRelockIdleMinutes(minutes)
                }
            }
            prose(ProtectionCopy.idleSubline)
            if canLock {
                door(ProtectionCopy.lockNowLabel) {
                    Task { await controller.performLock?() }
                }
                prose(ProtectionCopy.lockNowSentence)
            }
            if let error = controller.lastError {
                alarm(error)
            }
        }
    }

    // MARK: - The passphrase + phrase (knot 4; R13p-9's reset door)

    private var passphraseSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Passphrase & twelve words")
            statusRow("Encryption passphrase",
                      controller.hasPassphraseWrap ? "Set" : "Not set")
            statusRow("Twelve words",
                      controller.hasRecoveryWrap ? "On file" : "Not saved")
            // pre-13x 3b (§13): the reset door RETIRED — merged into the
            // Encryption tab's change-passphrase forgot road; an ENROLLED
            // library changes its passphrase there (copy §4's home).
            if controller.enrolled, controller.hasPassphraseWrap {
                prose("Change your passphrase or your twelve words under Account & Encryption.")
            } else {
                door(controller.hasPassphraseWrap ? "Change Passphrase…" : "Set a Passphrase…") {
                    openSetSheet()
                }
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

    // MARK: - The reminder (Castle — always on; one face: SecretCheck over the store road)

    @ViewBuilder
    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Remembering your secrets")
            checkSection
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .environment(\.sharedPageStyle, SharedPageStyle(tokens: tokens))
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

    // MARK: - Acts

    private func openSetSheet() {
        setSheetModel = PassphraseSetModel(
            controller: controller,
            vaultTie: VaultTie.make(services: services))
    }
}
