//
//  RoadCrossingSheet.swift
//  Variorum
//
//  VX-307 U2a — THE CROSSINGS' CONFIRM, the Mac's face (`notes/plans/vx-307-castle-crossings.md` §5c; rules 9, 11,
//  12, 25; P-VX378-U2-2). One sheet over `RoadCrossingConfirmModel`: the door's title, its sentences as `assess` gave
//  them (rule 9's promise and rule 12's leave sentence are hers, verbatim; rule 25's copies named beneath their line),
//  Use Castle's gate choice (Touch ID where this Mac has the hardware and a finger — else Always ask, said why), exactly
//  the fields the door asks (both typed — the passphrase, a NEW one typed twice when the library has none, and the
//  twelve words), the refusal, and one button. While the act runs the window's library closes and reopens under it.
//
//  And THE NEW ROAD'S PROTECTION SECTION (`RoadCrossingsSection`, Settings ▸ Protection): the posture line, each door
//  `assess` opens (a refused one says why in its place; one that is not this posture's renders nothing — P-2), rule
//  11's one notice with *Turn it back on* · *OK*, and in Castle the standing gate-style row.
//

import SwiftUI
import VariorumCore

struct RoadCrossingSheet: View {
    @Bindable var model: RoadCrossingConfirmModel

    @State private var passphrase = ""
    @State private var again = ""
    @State private var words = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(model.title)
                .font(.title3.weight(.semibold))
            ForEach(Array(model.door.sentences.enumerated()), id: \.offset) { _, sentence in
                Text(sentence)
                    .font(.callout)
                    .foregroundStyle(sentence == ProtectionWords.leaveSentence ? .primary : .secondary)
                    .fixedSize(horizontal: false, vertical: true)
                if sentence == ProtectionWords.copiesUnderAKeyThisMacCantDelete {
                    ForEach(model.door.undeletableCopies, id: \.self) { copy in
                        Text("\u{2022} \(copy)")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            if let gate = model.door.gate { gateChoice(gate) }
            fields
            if let refusal = model.refusal {
                Text(refusal)
                    .font(.callout)
                    .alarmVoice()
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                Button(ProtectionWords.crossingCancel) { model.cancel() }
                    .keyboardShortcut(.cancelAction)
                    .disabled(model.busy)
                Spacer()
                if model.busy {
                    TravellingDotsIndicator(ink: .secondary)
                    Text(ProtectionWords.crossingWorking).font(.caption).foregroundStyle(.secondary)
                }
                Button(model.title) { submit() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!model.canSubmit(passphrase: passphrase, again: again, words: words))
            }
        }
        .padding(22)
        .frame(width: 460, alignment: .leading)
        .interactiveDismissDisabled(model.busy)
    }

    /// Use Castle's choice (rule 9: "Touch ID on this Mac is optional").
    private func gateChoice(_ gate: RoadGateChoice) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(ProtectionWords.gateHeading)
                .font(.callout.weight(.semibold))
            if gate.touchIDAvailable {
                Picker(ProtectionWords.gateHeading, selection: $model.gate) {
                    Text(ProtectionWords.gateTouchID).tag(GateStyle.touchID)
                    Text(ProtectionWords.gateAlwaysAsk).tag(GateStyle.alwaysAsk)
                }
                .pickerStyle(.radioGroup)
                .labelsHidden()
                .disabled(model.busy)
            } else {
                Text(ProtectionWords.gateAlwaysAsk)
                    .font(.callout)
                Text(ProtectionWords.touchIDNotSetUpOnThisMac)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(model.gate == .touchID && gate.touchIDAvailable
                 ? ProtectionWords.gateTouchIDLine : ProtectionWords.gateAlwaysAskLine)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    /// Exactly the fields the door's ask names.
    @ViewBuilder
    private var fields: some View {
        let ask = model.door.ask
        if ask.asksPassphrase || ask == .oneSecret {
            if model.asksNewPassphrase {
                Text(ProtectionWords.crossingNewPassphraseLead)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                PeekableSecretField(label: ProtectionWords.crossingNewPassphraseField, text: $passphrase)
                    .textFieldStyle(.roundedBorder)
                PeekableSecretField(label: ProtectionWords.crossingNewPassphraseAgain, text: $again)
                    .textFieldStyle(.roundedBorder)
            } else {
                PeekableSecretField(label: ProtectionWords.crossingPassphraseField, text: $passphrase)
                    .textFieldStyle(.roundedBorder)
            }
        }
        if ask.asksWords || ask == .oneSecret {
            TextField(ProtectionWords.crossingWordsField, text: $words, axis: .vertical)
                .lineLimit(2, reservesSpace: true)
                .autocorrectionDisabled()
                .privacySensitive()
                .textFieldStyle(.roundedBorder)
                .onSubmit(submit)
        }
    }

    private func submit() {
        let typedPassphrase = passphrase
        let typedAgain = again
        let typedWords = words
        Task { await model.submit(passphrase: typedPassphrase, again: typedAgain, words: typedWords) }
    }
}

/// Settings ▸ Protection on the new road: the posture, the crossings' doors, rule 11's notice, the gate-style row.
struct RoadCrossingsSection: View {
    @Bindable var model: RoadCrossingsModel

    @State private var gatePassphrase = ""

    var body: some View {
        Section(ProtectionCopy.protectionPaneTitle) {
            if let faces = model.faces {
                Text(ProtectionWords.postureLine(faces.mode))
                    .font(.callout.weight(.semibold))
                ForEach(RoadCrossingDoor.allCases) { door in
                    doorRow(door, faces.face(door))
                }
            }
            if model.exportNotice { exportNotice }
        }
        if let row = model.faces?.gateRow { gateSection(row) }
    }

    @ViewBuilder
    private func doorRow(_ door: RoadCrossingDoor, _ face: RoadDoorFace) -> some View {
        switch face {
        case .hidden:
            EmptyView()
        case .refused(let sentence):
            Text(sentence)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        case .open:
            HStack {
                Button(door.doorLabel) { model.open(door) }
                    .disabled(model.confirm != nil)
                Spacer()
            }
        }
    }

    /// Rule 11's one notice — her call to reverse.
    private var exportNotice: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(ProtectionWords.exportTurnedOffNotice)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
            HStack {
                Button(ProtectionWords.exportTurnBackOn) { Task { await model.turnExportBackOn() } }
                Button(ProtectionWords.exportNoticeOK) { model.exportNoticeOK() }
                Spacer()
            }
            if let message = model.exportNoticeMessage {
                Text(message)
                    .font(.caption)
                    .alarmVoice()
            }
        }
    }

    /// The standing gate-style row (Castle): Touch ID on only with the passphrase; Always ask deletes the item.
    private func gateSection(_ row: RoadGateRow) -> some View {
        Section(ProtectionWords.gateHeading) {
            Text(row.current == .touchID ? ProtectionWords.gateRowTouchID : ProtectionWords.gateRowAlwaysAsk)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
            if row.current == .touchID {
                HStack {
                    Button(ProtectionWords.gateRowUseAlwaysAsk) { Task { await model.useAlwaysAsk() } }
                        .disabled(model.gateBusy)
                    Spacer()
                }
            } else if row.touchIDAvailable {
                if model.gateAsksPassphrase {
                    PeekableSecretField(
                        label: ProtectionWords.crossingPassphraseField, text: $gatePassphrase, onSubmit: useTouchID)
                        .textFieldStyle(.roundedBorder)
                    HStack {
                        Button(ProtectionWords.crossingCancel) {
                            gatePassphrase = ""
                            model.cancelTouchID()
                        }
                        .disabled(model.gateBusy)
                        Spacer()
                        if model.gateBusy { TravellingDotsIndicator(ink: .secondary) }
                        Button(ProtectionWords.gateRowTouchIDButton) { useTouchID() }
                            .disabled(gatePassphrase.isEmpty || model.gateBusy)
                    }
                } else {
                    HStack {
                        Button(ProtectionWords.gateRowUseTouchID) { model.beginTouchID() }
                        Spacer()
                    }
                }
            } else {
                Text(ProtectionWords.touchIDNotSetUpOnThisMac)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let refusal = model.gateRefusal {
                Text(refusal)
                    .font(.caption)
                    .alarmVoice()
            }
        }
    }

    private func useTouchID() {
        let typed = gatePassphrase
        gatePassphrase = ""
        Task { await model.useTouchID(passphrase: typed) }
    }
}
