//
//  RoadSecretCheckSheet.swift
//  Variorum
//
//  VX-510 D-B7 — VX-513, THE READ-ONLY CHECK's Mac faces (her R-510-15; the brain is `RoadSecretCheckModel` and the road
//  `ProtectionSecretCheck`, both shared):
//
//    - `RoadSecretCheckSection` (Settings ▸ Protection, after the words section — beside the key doors): one door, *Check my
//      passphrase or twelve words…*, rendered only where it can act (`RoadKeyDoorsModel.offersCheck` — the live key file of
//      the open key beside the library; no library open, no door — P-2).
//    - `RoadSecretCheckSheet` — presented through THE ONE PRESENTER: the title, one lead line, ONE concealed field (the shared
//      `PeekableSecretField` with its reveal eye — VX-463), what the check said (the first line a warning when something
//      did not open), *Close* and *Check*. Typing again clears what was said (unit C's W-10). Nothing here writes.
//

import SwiftUI
import VariorumCore

// MARK: - The door

struct RoadSecretCheckSection: View {
    @Bindable var model: RoadKeyDoorsModel

    var body: some View {
        if model.offersCheck {
            Section {
                HStack {
                    Button(ProtectionWords.checkSecretsDoor) { model.openCheck() }
                        .disabled(model.presenter.sheet != nil)
                    Spacer()
                }
            }
        }
    }
}

// MARK: - The sheet

struct RoadSecretCheckSheet: View {
    @Bindable var model: RoadSecretCheckModel

    @State private var typed = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(ProtectionWords.checkSecretsTitle)
                .font(.title3.weight(.semibold))
            Text(ProtectionWords.checkSecretsLead)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            PeekableSecretField(label: ProtectionWords.checkSecretsField, text: $typed, onSubmit: submit)
                .textFieldStyle(.roundedBorder)
                .onChange(of: typed) { model.edited() }
            if let outcome = model.outcome {
                ForEach(Array(outcome.lines.enumerated()), id: \.offset) { index, line in
                    said(line, first: index == 0, warns: outcome.warns)
                }
            }
            HStack {
                Button(ProtectionWords.checkSecretsClose) { model.close() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                if model.busy {
                    TravellingDotsIndicator(ink: .secondary)
                    Text(ProtectionWords.checkSecretsWorking).font(.caption).foregroundStyle(.secondary)
                }
                Button(ProtectionWords.checkSecretsButton) { submit() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!model.canSubmit(typed))
            }
        }
        .padding(22)
        .frame(width: 460, alignment: .leading)
    }

    /// One line of what the check said: the first in the alarm voice when something did not open, else the primary ink;
    /// the rest (the reason the account wasn't checked, VX-113's named change) secondary.
    @ViewBuilder
    private func said(_ line: String, first: Bool, warns: Bool) -> some View {
        if first && warns {
            Text(line)
                .font(.callout)
                .alarmVoice()
                .fixedSize(horizontal: false, vertical: true)
        } else {
            Text(line)
                .font(.callout)
                .foregroundStyle(first ? .primary : .secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func submit() {
        let text = typed
        Task { await model.submit(text) }
    }
}
