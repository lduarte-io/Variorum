//
//  SetPassphraseSheet.swift
//  Variorum
//
//  VX-306 U2 — THE SET-PASSPHRASE SHEET, the Mac's face (rule 3; §7c (7), built exactly as drafted — PROVISIONAL, hers
//  at the bundle; P-VX306-U2-0 (a): the reset door's Standard road). The title, the lead, two fields (*Passphrase* /
//  *Again*), one button *Set passphrase* — and a way out. It refuses at once when the library already has a
//  passphrase. On success the host closes it and the receipt is spoken on the status seam.
//

import SwiftUI
import VariorumCore

struct SetPassphraseSheet: View {
    @Bindable var model: SetPassphraseModel

    @State private var passphrase = ""
    @State private var again = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(ProtectionWords.setPassphraseTitle)
                .font(.title3.weight(.semibold))
            Text(ProtectionWords.setPassphraseLead)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if !model.alreadySet {
                PeekableSecretField(label: ProtectionWords.setPassphraseField, text: $passphrase)
                    .textFieldStyle(.roundedBorder)
                PassphraseHintLine(passphrase: passphrase)
                PeekableSecretField(label: ProtectionWords.setPassphraseAgain, text: $again, onSubmit: submit)
                    .textFieldStyle(.roundedBorder)
            }
            if let refusal = model.refusal {
                Text(refusal)
                    .font(.callout)
                    .alarmVoice()
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                Button(ProtectionWords.setPassphraseCancel) { model.cancel() }
                    .keyboardShortcut(.cancelAction)
                    .disabled(model.busy)
                Spacer()
                if model.busy { TravellingDotsIndicator(ink: .secondary) }
                Button(ProtectionWords.setPassphraseButton) { submit() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!model.canSubmit(passphrase: passphrase, again: again))
            }
        }
        .padding(22)
        .frame(width: 420)
    }

    private func submit() {
        let typed = passphrase
        let twice = again
        Task { await model.submit(passphrase: typed, again: twice) }
    }
}

/// VX-309 U2 — VX-211 (her "Floor + quiet hint"): the ONE calm line beneath a NEW passphrase field, as she types — the
/// estimator's advice (`NewPassphraseRule.hint`), never a block, never a meter, no colour; nothing for a long, varied phrase.
/// Every new-road field that SETS a passphrase renders it (the set sheet, the tour's last card, a crossing's and turning
/// sync on's new passphrase, the key doors' new passphrase).
struct PassphraseHintLine: View {
    let passphrase: String

    var body: some View {
        if let hint = NewPassphraseRule.hint(passphrase) {
            Text(hint)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
