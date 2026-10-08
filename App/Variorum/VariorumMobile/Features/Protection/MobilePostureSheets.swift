//
//  MobilePostureSheets.swift
//  VariorumMobile
//
//  pre-13x batch 2c — THE PHONE'S CEREMONY AND FOLLOW FACES over the SAME
//  shared brains the Mac drives (`PostureSwitchModel`, `PostureFollowModel`
//  — Shared) and the SAME words (`ProtectionCopy` + `PostureCopy`, the
//  phone's nouns riding interpolation: *this iPhone asks for Face ID*).
//  The phone is a first-class birthplace of Castle (design §9): entering,
//  leaving, finishing an interrupted switch, and following a change made
//  elsewhere all happen HERE, with nothing assuming a Mac ever existed.
//
//  The chrome follows the phone's register — text-forward rows, the voice's
//  selection grammar, no Toggle (the floor's acknowledgement is a marked
//  row). No copy-all for the twelve words (the phone's set screen made the
//  same call — the words are read and written down). Placeholder voice;
//  13s re-voices.
//

import SwiftUI
import VariorumCore

// MARK: - The ceremony (entering / leaving / resuming)

struct MobilePostureSwitchSheet: View {
    @Bindable var model: PostureSwitchModel
    let tokens: VoiceTokens
    var onDone: () -> Void

    @State private var passphrase = ""
    @State private var confirmation = ""
    @State private var typedWords = ""
    @State private var acknowledged = false
    @State private var newPassphrase = ""
    @State private var newConfirmation = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                switch model.phase {
                case .checking:
                    title("Checking…")
                case .explain where model.act == .replaceKeys:
                    // pre-13x 3b — copy §4's Replace All Keys screen, the
                    // phone's register (the checkbox as a marked row). VX-99
                    // round 2 (finding 1): by the ACT, as on the Mac.
                    title(ProtectionCopy.replaceKeysTitle)
                    prose(ProtectionCopy.replaceKeysBody)
                    if model.accountPostureIsStandard { prose(ProtectionCopy.replaceKeysStandardAddendum) }
                    if !model.passphraseHandedIn {
                        Button { model.wantsNewPassphrase.toggle() } label: {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text(model.wantsNewPassphrase ? "●" : "○")
                                    .font(tokens.body)
                                    .foregroundStyle(tokens.accent)
                                Text(ProtectionCopy.alsoNewPassphraseCheckbox)
                                    .font(tokens.small)
                                    .foregroundStyle(tokens.ink)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(ProtectionCopy.alsoNewPassphraseCheckbox)
                        .accessibilityAddTraits(model.wantsNewPassphrase ? .isSelected : [])
                    }
                    doors(primary: ProtectionCopy.enterCastleContinue, { model.continueFromExplain() },
                          quiet: "Cancel", { onDone() })
                case .authorize:
                    title(ProtectionCopy.replaceKeysTitle)
                    prose(ProtectionCopy.replaceKeysAuthorization)
                    secretField(ProtectionCopy.passphraseFieldLabel, text: $passphrase)
                    doors(primary: model.wantsNewPassphrase ? ProtectionCopy.enterCastleContinue : ProtectionCopy.replaceKeysDoor, {
                        Task { await model.authorize(passphrase: passphrase) }
                    }, primaryEnabled: !model.busy && !passphrase.isEmpty,
                          quiet: "Cancel", { onDone() })
                case .newPassphrase:
                    title(ProtectionCopy.setupPassphraseTitle)
                    prose(ProtectionCopy.passphraseSubline)
                    secretField(ProtectionCopy.newPassphraseLabel, text: $newPassphrase)
                    secretField(ProtectionCopy.confirmNewPassphraseLabel, text: $newConfirmation)
                    doors(primary: ProtectionCopy.replaceKeysDoor, {
                        Task { await model.commitNewPassphrase(newPassphrase, confirmation: newConfirmation) }
                    }, primaryEnabled: !model.busy && !newPassphrase.isEmpty,
                          quiet: "Cancel", { onDone() })
                case .explain:
                    title(ProtectionCopy.enterCastleTitle)
                    prose(ProtectionCopy.enterCastleBody)
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(ProtectionCopy.enterCastleBullets, id: \.self) { line in
                            Text("• \(line)")
                                .font(tokens.small)
                                .foregroundStyle(tokens.ink)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    doors(primary: ProtectionCopy.enterCastleContinue, { model.continueFromExplain() },
                          quiet: "Cancel", { onDone() })
                case .setPassphrase:
                    title(ProtectionCopy.castleNeedsPassphraseTitle)
                    prose(model.vaultConstrains
                          ? ProtectionCopy.passphraseAlreadyOnAccount
                          : ProtectionCopy.passphraseSubline)
                    secretField(ProtectionCopy.passphraseFieldLabel, text: $passphrase)
                    secretField(ProtectionCopy.passphraseConfirmLabel, text: $confirmation)
                    doors(primary: ProtectionCopy.enterCastleContinue, {
                        Task { await model.commitPassphrase(passphrase, confirmation: confirmation) }
                    }, primaryEnabled: !model.busy && !passphrase.isEmpty,
                          quiet: "Cancel", { onDone() })
                case .wordsExisting:
                    title(ProtectionCopy.wordsExistTitle)
                    prose(ProtectionCopy.wordsExistBody)
                    HStack(spacing: 16) {
                        offer(ProtectionCopy.wordsTypeMineDoor) { model.chooseTypeWords() }
                        offer(ProtectionCopy.wordsGenerateNewDoor) { model.chooseGenerateNewWords() }
                        Spacer()
                        offer("Cancel", quiet: true) { onDone() }
                    }
                case .wordsType:
                    title(ProtectionCopy.wordsConfirmTitle)
                    wordsField
                    doors(primary: ProtectionCopy.wordsConfirmDoor, {
                        Task { await model.submitExistingWords(typedWords) }
                    }, primaryEnabled: !model.busy && !typedWords.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                          quiet: "Cancel", { onDone() })
                case .wordsShow(let words):
                    title(ProtectionCopy.wordsWriteDownTitle)
                    prose(ProtectionCopy.wordsWriteDownBody)
                    wordsGrid(words).privacySensitive()
                    doors(primary: ProtectionCopy.wordsWrittenDoor, { model.acknowledgeWordsWritten() },
                          quiet: "Cancel", { onDone() })
                case .wordsConfirm:
                    title(ProtectionCopy.wordsConfirmTitle)
                    prose(ProtectionCopy.wordsConfirmBody)
                    wordsField
                    doors(primary: ProtectionCopy.wordsConfirmDoor, { model.confirmWords(typedWords) },
                          primaryEnabled: !typedWords.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                          quiet: "Cancel", { onDone() })
                case .floor(let needsPassphrase):
                    title(ProtectionCopy.floorTitle)
                    prose(ProtectionCopy.floorBody)
                    Button { acknowledged.toggle() } label: {
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text(acknowledged ? "●" : "○")
                                .font(tokens.body)
                                .foregroundStyle(tokens.accent)
                            Text(ProtectionCopy.floorCheckbox)
                                .font(tokens.small)
                                .foregroundStyle(tokens.ink)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(ProtectionCopy.floorCheckbox)
                    .accessibilityAddTraits(acknowledged ? .isSelected : [])
                    if needsPassphrase {
                        secretField(ProtectionCopy.passphraseFieldLabel, text: $passphrase)
                    }
                    doors(primary: ProtectionCopy.enterCastleDoor, {
                        Task { await model.enterCastle(
                            passphrase: needsPassphrase ? passphrase : nil, acknowledged: acknowledged) }
                    }, primaryEnabled: !model.busy && acknowledged && !(needsPassphrase && passphrase.isEmpty),
                          quiet: "Cancel", { onDone() })
                case .running:
                    // VX-99 round 2 (finding 1): the act's title — the one selector.
                    title(model.runningTitle)
                    running(runningLine)
                    prose("Keep Variorum open. If it quits, the switch picks up where it stopped.")
                case .done(let insuranceOff, _):
                    title("Done")
                    // pre-13x 5a (ledger 61) → VX-99 round 2 (finding 1): the one
                    // selector over the act and the outcome's road, as on the Mac.
                    prose(model.doneBody)
                    if insuranceOff { alarm(ProtectionCopy.insuranceTurnedOffNotice) }
                    doors(primary: "Continue", {
                        model.continueFromDone()
                        if model.phase == .closed { onDone() }
                    })
                case .offer:
                    title(ProtectionCopy.deleteOldBackupsTitle)
                    prose(ProtectionCopy.deleteOldBackupsBody)
                    HStack(spacing: 16) {
                        offer(ProtectionCopy.deleteOldBackupsDoor, alarm: true) {
                            model.deleteOldBackups()
                            onDone()
                        }
                        Spacer()
                        offer(ProtectionCopy.keepOldBackupsDoor, quiet: true) { model.keepOldBackups(); onDone() }
                    }
                case .leaveConfirm:
                    title(ProtectionCopy.leaveCastleTitle)
                    prose(ProtectionCopy.leaveCastleBody)
                    secretField(ProtectionCopy.passphraseFieldLabel, text: $passphrase)
                    HStack(spacing: 16) {
                        offer(ProtectionCopy.leaveCastleDoor, enabled: !model.busy && !passphrase.isEmpty) {
                            Task { await model.leave(passphrase: passphrase) }
                        }
                        offer("Confirm with \(ProtectionCopy.biometryName)", enabled: !model.busy) {
                            Task { await model.leaveWithBiometrics() }
                        }
                        Spacer()
                        offer("Cancel", quiet: true) { onDone() }
                    }
                case .leftCastle:
                    title("You're in Standard.")
                    prose("Your Apple account holds a key again. Nothing else changed.")
                    doors(primary: "Close", { onDone() })
                case .resumeAsk:
                    title(model.resumeAskTitle)
                    prose(ProtectionCopy.resumeNeedsPassphrase)
                    secretField(ProtectionCopy.passphraseFieldLabel, text: $passphrase)
                    doors(primary: "Finish", { Task { await model.resume(passphrase: passphrase) } },
                          primaryEnabled: !model.busy && !passphrase.isEmpty,
                          quiet: "Later", { onDone() })
                case .failed(let sentence):
                    title("Nothing was changed.")
                    alarm(sentence)
                    doors(primary: "Close", { onDone() })
                case .closed:
                    EmptyView()
                }
                if model.busy, model.phase != .running { running("Working…") }
                if let error = model.lastError { alarm(error) }
            }
            .padding(24)
        }
        .background(tokens.room.ignoresSafeArea())
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
            .textInputAutocapitalization(.never)
            .privacySensitive()
            .font(tokens.body)
            .foregroundStyle(tokens.ink)
            .padding(EdgeInsets(top: 11, leading: 12, bottom: 11, trailing: 12))
            .background(fieldChrome)
    }

    private func secretField(_ label: String, text: Binding<String>) -> some View {
        PeekableSecretField(label: label, text: text)
            .font(tokens.body)
            .foregroundStyle(tokens.ink)
            .padding(EdgeInsets(top: 11, leading: 12, bottom: 11, trailing: 12))
            .background(fieldChrome)
    }

    private var fieldChrome: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(tokens.card)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1))
    }

    private func wordsGrid(_ words: [String]) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                  alignment: .leading, spacing: 6) {
            ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                Text("\(index + 1). \(word)")
                    .font(tokens.mono)
                    .foregroundStyle(tokens.ink)
            }
        }
        .padding(12)
        .background(fieldChrome)
    }

    private func title(_ text: String) -> some View {
        Text(text)
            .font(tokens.body.weight(.semibold))
            .foregroundStyle(tokens.ink)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func prose(_ text: String) -> some View {
        Text(text)
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func alarm(_ text: String) -> some View {
        Text(text)
            .font(tokens.small)
            .foregroundStyle(tokens.alarm)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func running(_ line: String) -> some View {
        HStack(spacing: 8) {
            TravellingDotsIndicator(ink: tokens.muted)
            Text(line).font(tokens.small).foregroundStyle(tokens.muted)
        }
    }

    private func offer(
        _ label: String, quiet: Bool = false, alarm: Bool = false, enabled: Bool = true,
        act: @escaping () -> Void
    ) -> some View {
        Button(action: act) {
            Text(tokens.chromeLabel(label))
                .font(quiet ? tokens.small : tokens.body)
                .foregroundStyle(!enabled ? tokens.faint : alarm ? tokens.alarm : quiet ? tokens.muted : tokens.accent)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .accessibilityLabel(label)
    }

    /// The row's grammar: the primary door leads, the quiet one trails.
    private func doors(
        primary: String, _ act: @escaping () -> Void, primaryEnabled: Bool = true,
        quiet: String? = nil, _ quietAct: @escaping () -> Void = {}
    ) -> some View {
        HStack(spacing: 16) {
            offer(primary, enabled: primaryEnabled, act: act)
            Spacer()
            if let quiet { offer(quiet, quiet: true, act: quietAct) }
        }
    }
}

// MARK: - The follow (§7)

struct MobileFollowSheet: View {
    @Bindable var model: PostureFollowModel
    let tokens: VoiceTokens
    var onDone: () -> Void

    @State private var passphrase = ""
    @State private var typedWords = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                switch model.phase {
                case .notice:
                    prose(model.notice.body, ink: true)
                    HStack(spacing: 16) {
                        offer(ProtectionCopy.followEnterDoorLabel(
                            asksNothing: model.canFollowFromHeldKey)) { model.choosePassphrase() }
                        offer(ProtectionCopy.followWordsDoor) { model.chooseWords() }
                        Spacer()
                        offer(model.notice.dismissDoor, quiet: true) { model.later(); onDone() }
                    }
                case .askPassphrase:
                    prose(model.notice.body)
                    secretField(ProtectionCopy.passphraseFieldLabel, text: $passphrase)
                    HStack(spacing: 16) {
                        offer("Enter", enabled: !model.busy && !passphrase.isEmpty) {
                            Task { await model.enter(passphrase: passphrase) }
                        }
                        offer(ProtectionCopy.followWordsDoor) { model.chooseWords() }
                        Spacer()
                        offer(model.notice.dismissDoor, quiet: true) { model.later(); onDone() }
                    }
                case .askWords:
                    prose(model.notice.body)
                    TextField("The 12 words, separated by spaces", text: $typedWords, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .privacySensitive()
                        .font(tokens.body)
                        .foregroundStyle(tokens.ink)
                        .padding(EdgeInsets(top: 11, leading: 12, bottom: 11, trailing: 12))
                        .background(fieldChrome)
                    HStack(spacing: 16) {
                        offer("Enter", enabled: !model.busy
                              && !typedWords.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                            Task { await model.enter(wordsText: typedWords) }
                        }
                        offer(ProtectionCopy.followEnterDoorLabel(
                            asksNothing: model.canFollowFromHeldKey)) { model.choosePassphrase() }
                        Spacer()
                        offer(model.notice.dismissDoor, quiet: true) { model.later(); onDone() }
                    }
                case .running:
                    HStack(spacing: 8) {
                        TravellingDotsIndicator(ink: tokens.muted)
                        Text(runningLine).font(tokens.small).foregroundStyle(tokens.muted)
                    }
                    prose("Keep Variorum open. If it quits, the follow picks up where it stopped.")
                case .done(let insuranceOff, _):
                    // pre-13x 4a: Connect's own done line (copy §3).
                    prose(model.isConnectVariant ? ProtectionCopy.connectDoneBody : ProtectionCopy.followDoneBody, ink: true)
                    if insuranceOff { alarm(ProtectionCopy.insuranceTurnedOffNotice) }
                    HStack { offer("Continue") {
                        model.continueFromDone()
                        if model.phase == .closed { onDone() }
                    }; Spacer() }
                case .offer:
                    Text(ProtectionCopy.deleteOldBackupsTitle)
                        .font(tokens.body.weight(.semibold))
                        .foregroundStyle(tokens.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    prose(ProtectionCopy.deleteOldBackupsBody)
                    HStack(spacing: 16) {
                        offer(ProtectionCopy.deleteOldBackupsDoor, alarm: true) {
                            model.deleteOldBackups()
                            onDone()
                        }
                        Spacer()
                        offer(ProtectionCopy.keepOldBackupsDoor, quiet: true) { model.keepOldBackups(); onDone() }
                    }
                case .failed(let sentence):
                    Text("Nothing was changed.")
                        .font(tokens.body.weight(.semibold))
                        .foregroundStyle(tokens.ink)
                    alarm(sentence)
                    HStack { offer("Close") { onDone() }; Spacer() }
                case .closed:
                    EmptyView()
                }
                if model.busy, model.phase != .running {
                    HStack(spacing: 8) {
                        TravellingDotsIndicator(ink: tokens.muted)
                        Text("Working…").font(tokens.small).foregroundStyle(tokens.muted)
                    }
                }
                if let error = model.lastError { alarm(error) }
            }
            .padding(24)
        }
        .background(tokens.room.ignoresSafeArea())
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

    private var fieldChrome: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(tokens.card)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1))
    }

    private func secretField(_ label: String, text: Binding<String>) -> some View {
        PeekableSecretField(label: label, text: text)
            .font(tokens.body)
            .foregroundStyle(tokens.ink)
            .padding(EdgeInsets(top: 11, leading: 12, bottom: 11, trailing: 12))
            .background(fieldChrome)
    }

    private func prose(_ text: String, ink: Bool = false) -> some View {
        Text(text)
            .font(tokens.small)
            .foregroundStyle(ink ? tokens.ink : tokens.muted)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func alarm(_ text: String) -> some View {
        Text(text)
            .font(tokens.small)
            .foregroundStyle(tokens.alarm)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func offer(
        _ label: String, quiet: Bool = false, alarm: Bool = false, enabled: Bool = true,
        act: @escaping () -> Void
    ) -> some View {
        Button(action: act) {
            Text(tokens.chromeLabel(label))
                .font(quiet ? tokens.small : tokens.body)
                .foregroundStyle(!enabled ? tokens.faint : alarm ? tokens.alarm : quiet ? tokens.muted : tokens.accent)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
        .accessibilityLabel(label)
    }
}
