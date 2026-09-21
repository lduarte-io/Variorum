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
                    TravellingDotsIndicator(ink: .secondary)
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
    @State private var reminderCheck: SecretCheckModel?
    /// pre-13x 2b: a switch that did not finish on this device (the marker).
    @State private var pendingSwitch: RotationMarker?

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
        // RUN A batch A2, row 11: this pane is ONE of the ceremony's two
        // presenters now, so it says when it is on screen — the host is
        // decided at `openSwitch` from this count.
        .onAppear { controller.protectionPaneAppeared() }
        .onDisappear { controller.protectionPaneDisappeared() }
        .sheet(item: $setSheetModel) { model in
            PassphraseSetSheet(model: model) { setSheetModel = nil }
        }
        // pre-13x 2b: THE CEREMONY, held on the controller (it survives the
        // re-key's reopen — this pane does not). Row 11: presented here only
        // when this pane is its host; the main window's notice bar presents
        // the rest, and the two can never both fire.
        .sheet(item: Binding(
            get: { controller.ceremony(for: .pane) },
            set: { if $0 == nil { controller.closeSwitch() } })
        ) { model in
            PostureSwitchSheet(model: model) { controller.closeSwitch() }
        }
        // pre-13x 2c: the follow, opened from the pane's notice bar or the
        // Encryption tab, held on the controller like the ceremony.
        .sheet(item: Binding(
            get: { controller.activeFollow },
            set: { if $0 == nil { controller.closeFollow() } })
        ) { model in
            FollowSheet(model: model) { controller.closeFollow() }
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
    /// unknown, truthfully (ONE brain: `ProtectionCopy.checklistRows`,
    /// which both platforms compose). Under an unreadable sidecar the wrap
    /// rows are withheld and T2's unknown sentence stands in.
    private var checklistSection: some View {
        Section("Ways back in — right now") {
            ForEach(
                ProtectionCopy.checklistRows(
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
            Text(ProtectionCopy.nudgeSentence(for: controller.legs.tier))
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
            // pre-13x 2b: THE CHOOSE DOORS (copy §1 — the ellipsis: a
            // ceremony follows). Rendered only when a runner is wired
            // (P-2); a switch that crashed mid-road offers its resume
            // instead of a second start.
            if controller.followPending {
                // pre-13x 2c (§7): a follow is owed — every key door speaks
                // the one sentence instead of acting; the follow's door
                // lives in the notice bar and the Encryption tab.
                Text(ProtectionCopy.pickUpKeysFirst)
                    .font(.caption)
                    .alarmVoice()
                    .fixedSize(horizontal: false, vertical: true)
            } else if controller.switchRunner != nil {
                HStack {
                    if let pending = pendingSwitch {
                        Button(pending.entersCastle
                               ? ProtectionCopy.finishEnteringCastleDoor
                               : ProtectionCopy.finishReplacingKeysDoor) {
                            controller.openSwitch(.resume(pending), vaultTie: VaultTie.make(services: services))
                        }
                        Text(ProtectionCopy.resumeBody)
                            .font(.caption)
                            .alarmVoice()
                            .fixedSize(horizontal: false, vertical: true)
                    } else if controller.posture == .standard {
                        Button(ProtectionCopy.useCastleDoor) {
                            controller.openSwitch(.enter, vaultTie: VaultTie.make(services: services))
                        }
                    } else {
                        Button(ProtectionCopy.useStandardDoor) {
                            controller.openSwitch(.leave, vaultTie: VaultTie.make(services: services))
                        }
                    }
                    Spacer()
                }
                .disabled(controller.activeSwitch != nil)
            }
        }
        .task(id: controller.activeSwitch?.id) {
            pendingSwitch = await controller.switchRunner?.pendingMarker()
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
            // pre-13x 3b (§13): the reset door RETIRED — merged into the
            // Encryption tab's change-passphrase forgot road; an ENROLLED
            // library changes its passphrase there (copy §4's home), a
            // local-only library sets/changes it here.
            if controller.enrolled, controller.hasPassphraseWrap {
                Text("Change your passphrase or your twelve words under Account & Encryption.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                HStack {
                    Button(controller.hasPassphraseWrap
                           ? "Change Passphrase…" : "Set a Passphrase…") {
                        openSetSheet()
                    }
                    Spacer()
                }
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

// MARK: - The notice bar (the nudge + the reminder, calm and dismissible)

struct ProtectionNoticeBar: View {
    @Bindable var controller: ProtectionController
    let services: AppServices?

    @State private var setSheetModel: PassphraseSetModel?
    @State private var phraseWords: [String]?
    @State private var migrationConfirm: MigrationConfirmModel?
    @Environment(\.openSettings) private var openSettings

    /// pre-13x 2c: the Account sheet, opened from the different-owner
    /// notice (Sign out acts inline; Delete lives on the Account tab).
    @State private var accountSheetTab: AccountTab?

    var body: some View {
        Group {
            switch controller.notice {
            case .nudge: nudgeBar
            case .reminderDue: reminderBar
            case .migrationConfirm: migrationBar
            case .follow(let follow): followBar(follow)
            case .followWaiting(let follow): followWaitingBar(follow)
            case .movedToStandard(let moved): movedToStandardBar(moved)
            case .alwaysAskRetiredWord(let retired): alwaysAskRetiredBar(retired)
            case .differentOwner: differentOwnerBar
            case .changedElsewhere(let change): changedElsewhereBar(change)
            case nil: EmptyView()
            }
        }
        .sheet(item: $setSheetModel) { model in
            PassphraseSetSheet(model: model) { setSheetModel = nil }
        }
        .sheet(item: $migrationConfirm) { model in
            MigrationConfirmSheet(model: model) { migrationConfirm = nil }
        }
        .sheet(item: Binding(
            get: { controller.activeFollow },
            set: { if $0 == nil { controller.closeFollow() } })
        ) { model in
            FollowSheet(model: model) { controller.closeFollow() }
        }
        // RUN A batch A2, row 11 (17l item 4 / KnownIssues 40): THE
        // CEREMONY'S ROOT PRESENTER. This bar is the main window's — the one
        // view mounted for the whole of a ready session — and it has always
        // presented the FOLLOW from here; the ceremony had no presenter
        // outside Settings at all, so the Account sheet's *Replace All Keys*
        // set a model nothing ever showed. It renders only what it owns
        // (`ceremonyHost`), so this and the pane's sheet can never both fire.
        .sheet(item: Binding(
            get: { controller.ceremony(for: .root) },
            set: { if $0 == nil { controller.closeSwitch() } })
        ) { model in
            PostureSwitchSheet(model: model) { controller.closeSwitch() }
        }
        .sheet(item: $accountSheetTab) { tab in
            if let services { AccountView(services: services, initialTab: tab) }
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
        let tier = controller.legs.tier
        // F3 (NIT-N8): a device WAITING for the account's iCloud key is not
        // exposed — copy §2d's waiting title + body render in the hardened
        // nudge's place (the two offers stand: the passphrase and the
        // words are the doors that continue now).
        let headline = switch tier {
        case .exposed: ProtectionCopy.exposedNudgeHeadline
        case .waiting: ProtectionCopy.waitingTitle
        case .covered, .unknown: ProtectionCopy.nudgeHeadline
        }
        let body = switch tier {
        case .exposed: ProtectionCopy.exposedNudgeBody
        case .waiting: ProtectionCopy.waitingBody
        case .covered, .unknown: ProtectionCopy.nudgeBody
        }
        return bar {
            VStack(alignment: .leading, spacing: 2) {
                Text(headline)
                    .font(.callout.weight(.semibold))
                Text(body)
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

    // MARK: pre-13x 2c — THE FOLLOW's notices (copy §5, verbatim)

    /// Account moved to Castle / Keys replaced elsewhere — the notice with
    /// its three doors; *Later* takes the un-followed state.
    private func followBar(_ follow: FollowNotice) -> some View {
        bar {
            VStack(alignment: .leading, spacing: 2) {
                Text(follow.body)
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
                Text(follow.laterSubline)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            // Row 10 (ledger 54): the label says what the door will DO.
            Button(ProtectionCopy.followEnterDoorLabel(
                asksNothing: controller.pendingFollowAsksNothing)) {
                controller.openFollow()
                controller.activeFollow?.choosePassphrase()
            }
            Button(ProtectionCopy.followWordsDoor) {
                controller.openFollow()
                controller.activeFollow?.chooseWords()
            }
            Button(ProtectionCopy.followLaterDoor) { controller.deferFollow() }
        }
    }

    /// Waiting for your passphrase — the PERSISTENT banner after *Later*.
    private func followWaitingBar(_ follow: FollowNotice) -> some View {
        bar {
            Text(follow.waitingBody)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Button(ProtectionCopy.followWaitingDoor) {
                controller.openFollow()
                controller.activeFollow?.choosePassphrase()
            }
        }
    }

    private func movedToStandardBar(_ moved: FollowNotice) -> some View {
        bar {
            Text(moved.body)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Button(ProtectionCopy.followMovedToStandardDoor) { controller.dismissMovedToStandard() }
        }
    }

    private func alwaysAskRetiredBar(_ retired: FollowNotice) -> some View {
        bar {
            Text(retired.body)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Button(ProtectionCopy.enterItNowDoor) {
                controller.openFollow()
                controller.activeFollow?.choosePassphrase()
            }
        }
    }

    /// pre-13x 4a (copy §5's first two lines): the passphrase was changed /
    /// the words were regenerated elsewhere — *Enter It Now…* (the field by
    /// kind) and a dismiss for this open.
    private func changedElsewhereBar(_ change: FollowNotice) -> some View {
        bar {
            Text(change.body)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Button(ProtectionCopy.enterItNowDoor) {
                controller.openChangeNotice()
                if change.kind == .wordsRegeneratedElsewhere {
                    controller.activeFollow?.chooseWords()
                } else {
                    controller.activeFollow?.choosePassphrase()
                }
            }
            Button {
                controller.dismissChangeNotice()
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(.plain)
            .help(ProtectionCopy.changeDismissDoor)
            .accessibilityLabel(ProtectionCopy.changeDismissDoor)
        }
    }

    /// Copy §3's keys-don't-match sentence with its doors: *Connect…* (pre-13x
    /// 3a — the adopt road, rendered now that it acts), Sign out, and the
    /// Account sheet (Delete lives there).
    private var differentOwnerBar: some View {
        bar {
            Text(ProtectionCopy.keysDontMatchThisLibrary)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Button("Sign Out") { Task { await services?.signOutVariorum() } }
                .disabled(services == nil)
            Button("Account…") { accountSheetTab = .account }
                .disabled(services == nil)
            if controller.connectAct != nil {
                Button(ProtectionCopy.connectDoor) {
                    controller.openConnect()
                    controller.activeFollow?.choosePassphrase()
                }
                .keyboardShortcut(.defaultAction)
            }
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

// MARK: - pre-13x 2c: THE FOLLOW's Mac face (copy §5 → the act → Done)

struct FollowSheet: View {
    @Bindable var model: PostureFollowModel
    var onDone: () -> Void

    @State private var passphrase = ""
    @State private var typedWords = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            switch model.phase {
            case .notice:
                Text(model.notice.body)
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Button(model.notice.dismissDoor) { model.later(); onDone() }
                    Spacer()
                    Button(ProtectionCopy.followWordsDoor) { model.chooseWords() }
                    Button(ProtectionCopy.followEnterDoorLabel(
                        asksNothing: model.canFollowFromHeldKey)) { model.choosePassphrase() }
                        .keyboardShortcut(.defaultAction)
                }
            case .askPassphrase:
                Text(model.notice.body)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                PeekableSecretField(label: ProtectionCopy.passphraseFieldLabel, text: $passphrase)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button(model.notice.dismissDoor) { model.later(); onDone() }
                    Spacer()
                    Button(ProtectionCopy.followWordsDoor) { model.chooseWords() }
                    Button("Enter") { Task { await model.enter(passphrase: passphrase) } }
                        .keyboardShortcut(.defaultAction)
                        .disabled(model.busy || passphrase.isEmpty)
                }
            case .askWords:
                Text(model.notice.body)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                TextField("The 12 words, separated by spaces", text: $typedWords, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)
                    .autocorrectionDisabled()
                    .privacySensitive()
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button(model.notice.dismissDoor) { model.later(); onDone() }
                    Spacer()
                    Button(ProtectionCopy.followEnterDoorLabel(
                        asksNothing: model.canFollowFromHeldKey)) { model.choosePassphrase() }
                    Button("Enter") { Task { await model.enter(wordsText: typedWords) } }
                        .keyboardShortcut(.defaultAction)
                        .disabled(model.busy || typedWords.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            case .running:
                HStack(spacing: 8) {
                    TravellingDotsIndicator(ink: .secondary)
                    Text(runningLine).font(.callout).foregroundStyle(.secondary)
                }
                Text("Keep Variorum open. If it quits, the follow picks up where it stopped.")
                    .font(.caption).foregroundStyle(.secondary)
            case .done(let insuranceOff, _):
                // pre-13x 4a: Connect's own done line (copy §3).
                Text(model.isConnectVariant ? ProtectionCopy.connectDoneBody : ProtectionCopy.followDoneBody)
                    .font(.callout)
                    .fixedSize(horizontal: false, vertical: true)
                if insuranceOff {
                    Text(ProtectionCopy.insuranceTurnedOffNotice)
                        .font(.callout)
                        .alarmVoice()
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack {
                    Spacer()
                    Button("Continue") {
                        model.continueFromDone()
                        if model.phase == .closed { onDone() }
                    }
                    .keyboardShortcut(.defaultAction)
                }
            case .offer:
                Text(ProtectionCopy.deleteOldBackupsTitle).font(.title3.weight(.semibold))
                Text(ProtectionCopy.deleteOldBackupsBody)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Button(ProtectionCopy.keepOldBackupsDoor) { model.keepOldBackups(); onDone() }
                        .keyboardShortcut(.cancelAction)
                    Spacer()
                    Button(ProtectionCopy.deleteOldBackupsDoor, role: .destructive) {
                        model.deleteOldBackups()
                        onDone()
                    }
                }
            case .failed(let sentence):
                Text("Nothing was changed.").font(.title3.weight(.semibold))
                Text(sentence)
                    .font(.callout)
                    .alarmVoice()
                    .fixedSize(horizontal: false, vertical: true)
                HStack { Spacer(); Button("Close") { onDone() }.keyboardShortcut(.defaultAction) }
            case .closed:
                EmptyView()
            }
            if model.busy, model.phase != .running {
                HStack(spacing: 6) {
                    TravellingDotsIndicator(ink: .secondary)
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
        .frame(width: 460)
        .interactiveDismissDisabled(model.phase == .running)
        // pre-13x 4a: a door that closes the model itself (the change notice's
        // landing) dismisses the sheet.
        .onChange(of: model.phase) { _, phase in
            if phase == .closed { onDone() }
        }
    }

    private var runningLine: String {
        // Row 12: the ONE brain (`ProtectionCopy.runningLine`) — a FOLLOW
        // picks up keys another device minted.
        ProtectionCopy.runningLine(for: model.runnerPhase, minting: false)
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
                        TravellingDotsIndicator(ink: .secondary)
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

// MARK: - pre-13x 2b: the Castle ceremony (copy §2b / §2c / §4's resume)

/// The ceremony's Mac face over `PostureSwitchModel` — one sheet, one
/// screen per phase in the copy's order. The words render ONLY here, once
/// (`.privacySensitive()`); the During line reads the runner's phase.
struct PostureSwitchSheet: View {
    @Bindable var model: PostureSwitchModel
    var onDone: () -> Void

    @State private var passphrase = ""
    @State private var confirmation = ""
    @State private var typedWords = ""
    @State private var acknowledged = false
    @State private var newPassphrase = ""
    @State private var newConfirmation = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            switch model.phase {
            case .checking:
                title("Checking…")
            case .explain where model.mode == .replaceKeys:
                // pre-13x 3b — copy §4's Replace All Keys screen.
                title(ProtectionCopy.replaceKeysTitle)
                body(ProtectionCopy.replaceKeysBody)
                if model.accountPostureIsStandard {
                    body(ProtectionCopy.replaceKeysStandardAddendum)
                }
                if !model.passphraseHandedIn {
                    Toggle(ProtectionCopy.alsoNewPassphraseCheckbox, isOn: $model.wantsNewPassphrase)
                        .toggleStyle(.checkbox)
                }
                HStack {
                    Button("Cancel") { onDone() }
                    Spacer()
                    Button(ProtectionCopy.enterCastleContinue) { model.continueFromExplain() }
                        .keyboardShortcut(.defaultAction)
                }
            case .explain:
                title(ProtectionCopy.enterCastleTitle)
                body(ProtectionCopy.enterCastleBody)
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(ProtectionCopy.enterCastleBullets, id: \.self) { line in
                        Text("• \(line)")
                            .font(.callout)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                HStack {
                    Button("Cancel") { onDone() }
                    Spacer()
                    Button(ProtectionCopy.enterCastleContinue) { model.continueFromExplain() }
                        .keyboardShortcut(.defaultAction)
                }
            case .authorize:
                // pre-13x 3b — the passphrase typed and checked against the
                // account's copy (copy §4's authorization line; decision 33).
                title(ProtectionCopy.replaceKeysTitle)
                body(ProtectionCopy.replaceKeysAuthorization)
                PeekableSecretField(label: ProtectionCopy.passphraseFieldLabel, text: $passphrase)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button("Cancel") { onDone() }
                    Spacer()
                    Button(model.wantsNewPassphrase ? ProtectionCopy.enterCastleContinue : ProtectionCopy.replaceKeysDoor) {
                        Task { await model.authorize(passphrase: passphrase) }
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(model.busy || passphrase.isEmpty)
                }
            case .newPassphrase:
                title(ProtectionCopy.setupPassphraseTitle)
                body(ProtectionCopy.passphraseSubline)
                PeekableSecretField(label: ProtectionCopy.newPassphraseLabel, text: $newPassphrase)
                    .textFieldStyle(.roundedBorder)
                PeekableSecretField(label: ProtectionCopy.confirmNewPassphraseLabel, text: $newConfirmation)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button("Cancel") { onDone() }
                    Spacer()
                    Button(ProtectionCopy.replaceKeysDoor) {
                        Task { await model.commitNewPassphrase(newPassphrase, confirmation: newConfirmation) }
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(model.busy || newPassphrase.isEmpty)
                }
            case .setPassphrase:
                title(ProtectionCopy.castleNeedsPassphraseTitle)
                body(model.vaultConstrains
                     ? ProtectionCopy.passphraseAlreadyOnAccount
                     : ProtectionCopy.passphraseSubline)
                PeekableSecretField(label: ProtectionCopy.passphraseFieldLabel, text: $passphrase)
                    .textFieldStyle(.roundedBorder)
                PeekableSecretField(label: ProtectionCopy.passphraseConfirmLabel, text: $confirmation)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button("Cancel") { onDone() }
                    Spacer()
                    Button(ProtectionCopy.enterCastleContinue) {
                        Task { await model.commitPassphrase(passphrase, confirmation: confirmation) }
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(model.busy || passphrase.isEmpty)
                }
            case .wordsExisting:
                title(ProtectionCopy.wordsExistTitle)
                body(ProtectionCopy.wordsExistBody)
                HStack {
                    Button("Cancel") { onDone() }
                    Spacer()
                    Button(ProtectionCopy.wordsGenerateNewDoor) { model.chooseGenerateNewWords() }
                    Button(ProtectionCopy.wordsTypeMineDoor) { model.chooseTypeWords() }
                        .keyboardShortcut(.defaultAction)
                }
            case .wordsType:
                title(ProtectionCopy.wordsConfirmTitle)
                wordsField
                HStack {
                    Button("Cancel") { onDone() }
                    Spacer()
                    Button(ProtectionCopy.wordsConfirmDoor) {
                        Task { await model.submitExistingWords(typedWords) }
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(model.busy || typedWords.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            case .wordsShow(let words):
                title(ProtectionCopy.wordsWriteDownTitle)
                body(ProtectionCopy.wordsWriteDownBody)
                wordsGrid(words).privacySensitive()
                HStack {
                    Button(ProtectionCopy.wordsCopyAll) {
                        let pasteboard = NSPasteboard.general
                        pasteboard.clearContents()
                        pasteboard.setString(words.joined(separator: " "), forType: .string)
                        let count = pasteboard.changeCount
                        model.markWordsCopied()
                        Task {
                            try? await Task.sleep(for: .seconds(60))
                            if NSPasteboard.general.changeCount == count {
                                NSPasteboard.general.clearContents()
                            }
                        }
                    }
                    if model.copiedWords {
                        Text(ProtectionCopy.wordsCopied).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(ProtectionCopy.wordsWrittenDoor) { model.acknowledgeWordsWritten() }
                        .keyboardShortcut(.defaultAction)
                }
            case .wordsConfirm:
                title(ProtectionCopy.wordsConfirmTitle)
                body(ProtectionCopy.wordsConfirmBody)
                wordsField
                HStack {
                    Button("Cancel") { onDone() }
                    Spacer()
                    Button(ProtectionCopy.wordsConfirmDoor) { model.confirmWords(typedWords) }
                        .keyboardShortcut(.defaultAction)
                        .disabled(typedWords.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            case .floor(let needsPassphrase):
                title(ProtectionCopy.floorTitle)
                body(ProtectionCopy.floorBody)
                Toggle(ProtectionCopy.floorCheckbox, isOn: $acknowledged)
                    .toggleStyle(.checkbox)
                if needsPassphrase {
                    PeekableSecretField(label: ProtectionCopy.passphraseFieldLabel, text: $passphrase)
                        .textFieldStyle(.roundedBorder)
                }
                HStack {
                    Button("Cancel") { onDone() }
                    Spacer()
                    Button(ProtectionCopy.enterCastleDoor) {
                        Task { await model.enterCastle(
                            passphrase: needsPassphrase ? passphrase : nil, acknowledged: acknowledged) }
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(model.busy || !acknowledged || (needsPassphrase && passphrase.isEmpty))
                }
            case .running:
                title(model.mode == .leave ? ProtectionCopy.leaveCastleTitle
                      : model.mode == .replaceKeys ? ProtectionCopy.replaceKeysTitle
                      : ProtectionCopy.enterCastleTitle)
                HStack(spacing: 8) {
                    TravellingDotsIndicator(ink: .secondary)
                    Text(runningLine).font(.callout).foregroundStyle(.secondary)
                }
                Text("Keep Variorum open. If it quits, the switch picks up where it stopped.")
                    .font(.caption).foregroundStyle(.secondary)
            case .done(let insuranceOff, _):
                title("Done")
                // pre-13x 5a (ledger 61): the conflict-follow's own Done when the
                // ceremony became the follow (copy §2b), else the ordinary one.
                body(model.mode == .replaceKeys ? ProtectionCopy.replaceKeysDone : ProtectionCopy.castleDoneBody(model.outcome))
                if insuranceOff {
                    Text(ProtectionCopy.insuranceTurnedOffNotice)
                        .font(.callout)
                        .alarmVoice()
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack {
                    Spacer()
                    Button("Continue") {
                        model.continueFromDone()
                        if model.phase == .closed { onDone() }
                    }
                    .keyboardShortcut(.defaultAction)
                }
            case .offer:
                title(ProtectionCopy.deleteOldBackupsTitle)
                body(ProtectionCopy.deleteOldBackupsBody)
                HStack {
                    Button(ProtectionCopy.keepOldBackupsDoor) { model.keepOldBackups(); onDone() }
                        .keyboardShortcut(.cancelAction)
                    Spacer()
                    Button(ProtectionCopy.deleteOldBackupsDoor, role: .destructive) {
                        model.deleteOldBackups()
                        onDone()
                    }
                }
            case .leaveConfirm:
                title(ProtectionCopy.leaveCastleTitle)
                body(ProtectionCopy.leaveCastleBody)
                PeekableSecretField(label: ProtectionCopy.passphraseFieldLabel, text: $passphrase)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button("Cancel") { onDone() }
                    Spacer()
                    Button("Confirm with Touch ID") { Task { await model.leaveWithBiometrics() } }
                        .disabled(model.busy)
                    Button(ProtectionCopy.leaveCastleDoor) { Task { await model.leave(passphrase: passphrase) } }
                        .keyboardShortcut(.defaultAction)
                        .disabled(model.busy || passphrase.isEmpty)
                }
            case .leftCastle:
                title("You're in Standard.")
                body("Your Apple account holds a key again. Nothing else changed.")
                HStack { Spacer(); Button("Close") { onDone() }.keyboardShortcut(.defaultAction) }
            case .resumeAsk:
                title(ProtectionCopy.resumeBody)
                body(ProtectionCopy.resumeNeedsPassphrase)
                PeekableSecretField(label: ProtectionCopy.passphraseFieldLabel, text: $passphrase)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Button("Later") { onDone() }
                    Spacer()
                    Button("Finish") { Task { await model.resume(passphrase: passphrase) } }
                        .keyboardShortcut(.defaultAction)
                        .disabled(model.busy || passphrase.isEmpty)
                }
            case .failed(let sentence):
                title("Nothing was changed.")
                Text(sentence)
                    .font(.callout)
                    .alarmVoice()
                    .fixedSize(horizontal: false, vertical: true)
                HStack { Spacer(); Button("Close") { onDone() }.keyboardShortcut(.defaultAction) }
            case .closed:
                EmptyView()
            }
            if model.busy, model.phase != .running {
                HStack(spacing: 6) {
                    TravellingDotsIndicator(ink: .secondary)
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
        .frame(width: 460)
        .task { await model.start() }
        .interactiveDismissDisabled(model.phase == .running)
    }

    private var runningLine: String {
        // Row 12: the ONE brain (`ProtectionCopy.runningLine`) — the
        // ceremony MINTS its new keys.
        ProtectionCopy.runningLine(for: model.runnerPhase, minting: true)
    }

    private var wordsField: some View {
        TextField("The 12 words, separated by spaces", text: $typedWords, axis: .vertical)
            .lineLimit(3, reservesSpace: true)
            .autocorrectionDisabled()
            .privacySensitive()
            .textFieldStyle(.roundedBorder)
    }

    private func title(_ text: String) -> some View {
        Text(text)
            .font(.title3.weight(.semibold))
            .fixedSize(horizontal: false, vertical: true)
    }

    private func body(_ text: String) -> some View {
        Text(text)
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func wordsGrid(_ words: [String]) -> some View {
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
