//
//  MintGatheringSheet.swift
//  Variorum
//
//  13i-c U3 — THE MINT DOOR REQUIRES A RULE (her post-close ruling 1 and
//  kickoff ruling R-13ic-4: "I just don't think that a rule-less gathering
//  makes sense"; F-U1-2). The shelf's "Create Smart Book" door opens THIS
//  sheet: the name and the rule, drafted inline with the rule editor's own
//  tree (`RuleTreeEditor` — one face for one grammar), and Create disabled
//  until the rule has a term. It mints through the shelf's creation road
//  (`ReadingsViewModel.create(querySpec:)` — the duplicate-name guard inside
//  its runner closure), and the operation's `gatheringRequiresRule` guard
//  stands behind the disabled button.
//
//  Its "smart book" wording stays until 13i-d's vocabulary sweep (the plan's
//  U3 brief allows it; the U3 RECORD says so).
//

import SwiftUI
import VariorumCore

struct MintGatheringSheet: View {
    /// The editor in MINT mode (`RuleEditorModel(session:mintingIn:)`) — the
    /// sheet's item, carrying the draft AND the name.
    let model: RuleEditorModel
    let readings: ReadingsViewModel

    @State private var refusal: String?
    @State private var minting = false
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @Environment(\.dismiss) private var dismiss

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// The Create gate (R-13ic-4): a term must exist.
    private var canCreate: Bool { model.mintSpec != nil && !minting }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(RuleEditorCopy.mintTitle)
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
            TextField("Name", text: Bindable(model).mintName)
            Text(tokens.chromeLabel(RuleEditorCopy.gatheringLead))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
            RuleTreeEditor(model: model, tokens: tokens, emptyNotice: RuleEditorCopy.mintEmpty)
            if let refusal {
                Text(refusal)
                    .font(tokens.small)
                    .alarmVoice()
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                Spacer()
                Button(tokens.chromeLabel("Cancel")) { dismiss() }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .keyboardShortcut(.cancelAction)
                Button(tokens.chromeLabel(RuleEditorCopy.mintCreate)) {
                    Task {
                        minting = true
                        defer { minting = false }
                        if await model.mint(through: readings) != nil {
                            dismiss()
                        } else {
                            // Refuse and KEEP: the sheet stays with her draft.
                            refusal = readings.lastError
                        }
                    }
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                .keyboardShortcut(.defaultAction)
                .disabled(!canCreate)
            }
        }
        .padding(16)
        .frame(minWidth: 480, alignment: .leading)
        .background(tokens.surface)
        .task { await model.load() }
        #if DEBUG
        .onAppear { record() }
        .onChange(of: model.mintSpec) { _, _ in record() }
        .onChange(of: refusal) { _, _ in record() }
        #endif
    }

    #if DEBUG
    private func record() {
        MintGatheringProbe.drawn = .init(
            title: RuleEditorCopy.mintTitle, createEnabled: canCreate,
            emptyNotice: model.rows.isEmpty ? RuleEditorCopy.mintEmpty : nil,
            refusal: refusal)
    }
    #endif
}

#if DEBUG
/// **WHAT THE MOUNTED MINT SHEET DREW** (the `RuleEditorProbe` pattern).
@MainActor
enum MintGatheringProbe {
    struct Drawn: Equatable {
        var title: String
        var createEnabled: Bool
        var emptyNotice: String?
        var refusal: String?
    }

    static var drawn: Drawn?
}
#endif
