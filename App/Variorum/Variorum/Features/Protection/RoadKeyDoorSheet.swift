//
//  RoadKeyDoorSheet.swift
//  Variorum
//
//  VX-308 U3 — THE KEY DOORS' MAC FACES on the new road (`notes/plans/vx-308-accounts-key-doors.md` §5c; rules 3, 6, 7):
//
//    - `RoadKeyDoorsSection` (Settings ▸ Protection, the passphrase's section): *Change passphrase…* and *Reset forgotten
//      passphrase…* as `assess` says them over the pane's one read (a refused door says why in its place; one with no
//      subject renders nothing — P-2: with no passphrase, VX-306's *Set a passphrase…* row stands in their place).
//    - `RoadKeyDoorSheet` — a passphrase door's confirm, presented through THE ONE PRESENTER (`ProtectionSheetsHost`): its
//      sentences (VX-263's one line first; synced, the account's passphrase changing with it; the forgot road's lead),
//      exactly the fields the door names (Change: the current passphrase; both: a new one typed twice; Castle's forgot
//      road: the twelve words, or *Reset with Touch ID* where this Mac has its item), the refusal, one button.
//  New Words is the words section's own door (`WordsLookSection` — U2b's look, now reading `.newWords`).
//

import SwiftUI
import VariorumCore

// MARK: - The passphrase's section

struct RoadKeyDoorsSection: View {
    @Bindable var model: RoadKeyDoorsModel

    private var rendered: Bool {
        guard let faces = model.faces else { return false }
        return faces.changePassphrase != .hidden || faces.resetForgottenPassphrase != .hidden
    }

    var body: some View {
        if rendered, let faces = model.faces {
            Section(ProtectionWords.passphraseSectionTitle) {
                doorRow(.changePassphrase, faces.changePassphrase)
                doorRow(.resetForgottenPassphrase, faces.resetForgottenPassphrase)
            }
        }
    }

    @ViewBuilder
    private func doorRow(_ door: RoadKeyDoor, _ face: RoadKeyDoorFace) -> some View {
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
                    .disabled(model.presenter.sheet != nil)
                Spacer()
            }
        }
    }
}

// MARK: - A passphrase door's confirm

struct RoadKeyDoorSheet: View {
    @Bindable var model: RoadKeyDoorConfirmModel

    @State private var current = ""
    @State private var new = ""
    @State private var again = ""
    @State private var words = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(model.title)
                .font(.title3.weight(.semibold))
            ForEach(Array(model.door.sentences.enumerated()), id: \.offset) { index, sentence in
                Text(sentence)
                    .font(.callout)
                    // VX-263's one line — the door's own sentence — in the primary ink; the rest secondary.
                    .foregroundStyle(index == 0 ? .primary : .secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            fields
            if let refusal = model.refusal {
                Text(refusal)
                    .font(.callout)
                    .alarmVoice()
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                Button(ProtectionWords.keyDoorCancel) { model.cancel() }
                    .keyboardShortcut(.cancelAction)
                    .disabled(model.busy)
                Spacer()
                if model.busy {
                    TravellingDotsIndicator(ink: .secondary)
                    Text(ProtectionWords.keyDoorWorking).font(.caption).foregroundStyle(.secondary)
                }
                if model.offersTouchID {
                    Button(ProtectionWords.resetPassphraseWithTouchID) { submitWithTouchID() }
                        .disabled(!model.canSubmitWithTouchID(new: new, again: again))
                }
                Button(model.door.door == .changePassphrase
                       ? ProtectionWords.changePassphraseButton : ProtectionWords.resetPassphraseButton) { submit() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!model.canSubmit(current: current, new: new, again: again, words: words))
            }
        }
        .padding(22)
        .frame(width: 460, alignment: .leading)
        .interactiveDismissDisabled(model.busy)
    }

    /// Exactly the fields the door names.
    @ViewBuilder
    private var fields: some View {
        if model.asksCurrent {
            PeekableSecretField(label: ProtectionWords.changePassphraseCurrentField, text: $current)
                .textFieldStyle(.roundedBorder)
        }
        if model.asksWords {
            TextField(ProtectionWords.resetPassphraseWordsField, text: $words, axis: .vertical)
                .lineLimit(2, reservesSpace: true)
                .autocorrectionDisabled()
                .privacySensitive()
                .textFieldStyle(.roundedBorder)
        }
        PeekableSecretField(label: ProtectionWords.keyDoorNewPassphraseField, text: $new)
            .textFieldStyle(.roundedBorder)
        PeekableSecretField(label: ProtectionWords.keyDoorNewPassphraseAgain, text: $again, onSubmit: submit)
            .textFieldStyle(.roundedBorder)
    }

    private func submit() {
        let typed = (current, new, again, words)
        Task { await model.submit(current: typed.0, new: typed.1, again: typed.2, words: typed.3) }
    }

    private func submitWithTouchID() {
        let typed = (new, again)
        Task { await model.submitWithTouchID(new: typed.0, again: typed.1) }
    }
}
