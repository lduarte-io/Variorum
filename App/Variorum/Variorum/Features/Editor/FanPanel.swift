//
//  FanPanel.swift
//  Variorum
//
//  The minimal fan UI (Phase 7 Step 6): variant cards, branch / blank /
//  choose / archive / delete / lock, refusals surfaced as plain status
//  messages (the operations layer enforces — the panel just renders what it
//  says). Functional, unstyled; summoned per-block, on request (calm
//  default).
//

import SwiftUI
import VariorumCore

struct FanPanel: View {
    let model: EditorViewModel
    let state: EditorViewModel.FanPanelState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Fan — block \(String(state.blockID.prefix(8)))")
                    .font(.headline)
                Spacer()
                Button("New Blank Take") { model.fanAction(.newBlank) }
                Button("Close") { model.fanPanel = nil }
            }
            if let status = model.statusMessage {
                Text(status).font(.caption).foregroundStyle(.secondary)
            }
            List(state.variants, id: \.id) { variant in
                card(variant)
            }
        }
        .padding(12)
        .frame(minWidth: 520, minHeight: 320)
    }

    @ViewBuilder
    private func card(_ variant: Variant) -> some View {
        let isChosen = variant.id == state.chosenVariantID
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                if isChosen {
                    Text("shown here").font(.caption).foregroundStyle(.blue)
                }
                if variant.status == .archived {
                    Text("archived").font(.caption).foregroundStyle(.secondary)
                }
                if variant.locked {
                    Text("locked").font(.caption).foregroundStyle(.orange)
                }
                if let label = variant.label {
                    Text(label).font(.caption)
                }
                Spacer()
            }
            Text(variant.workingText.isEmpty
                 ? "(empty take)"
                 : String(variant.workingText.prefix(160)))
                .font(.callout)
                .lineLimit(3)
                .foregroundStyle(variant.workingText.isEmpty ? .secondary : .primary)
            HStack(spacing: 8) {
                Button("Branch") { model.fanAction(.branch(from: variant.id)) }
                if variant.status == .active {
                    Button("Choose") { model.fanAction(.choose(variant.id)) }
                        .disabled(isChosen)
                    Button("Archive") { model.fanAction(.archive(variant.id)) }
                } else {
                    Button("Unarchive") { model.fanAction(.unarchive(variant.id)) }
                }
                Button(variant.locked ? "Unlock" : "Lock") {
                    model.fanAction(variant.locked ? .unlock(variant.id) : .lock(variant.id))
                }
                Button("Delete", role: .destructive) {
                    model.fanAction(.delete(variant.id))
                }
            }
            .controlSize(.small)
        }
        .padding(.vertical, 4)
    }
}
