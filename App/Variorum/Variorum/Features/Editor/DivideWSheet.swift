//
//  DivideWSheet.swift
//  Variorum
//
//  The W ceremony as ONE sheet (Phase 9 Step 6 — the ratified contract,
//  item 3): a fan checklist with the active take pre-marked, each marked
//  take's full text with a click-to-place cut marker (pre-seeded by
//  string-context matching; unseeded when no unique match), Confirm enabled
//  only when every marked take has a legal cut, Cancel touching nothing.
//  Functional and unstyled (zero polish until Phase 13); the live editor is
//  untouched for the ceremony's whole duration.
//

import SwiftUI
import VariorumCore

struct DivideWSheet: View {
    let model: EditorViewModel
    /// The presentation snapshot (`.sheet(item:)` captures the value once);
    /// rendering always prefers the LIVE ceremony state on the observable
    /// model, so marks and cut placements re-render.
    let presented: EditorViewModel.DivideWCeremonyState

    private var state: EditorViewModel.DivideWCeremonyState {
        model.divideWCeremony ?? presented
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Divide into takes").font(.headline)
            Text("Marked takes carry the cut through — the first halves become one block's fan, the second halves another's. Unmarked takes stay on the original block as lineage; the divide is reversible.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            List(state.takes) { take in
                takeRow(take)
            }
            .frame(minHeight: 240)

            HStack {
                Button("Cancel") { model.cancelDivideW() }
                    .keyboardShortcut(.cancelAction)
                Spacer()
                Button("Divide") { model.confirmDivideW() }
                    .keyboardShortcut(.defaultAction)
                    .disabled(!state.canConfirm)
            }
        }
        .padding(12)
        .frame(minWidth: 520)
    }

    @ViewBuilder
    private func takeRow(_ take: EditorViewModel.WTake) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle(isOn: Binding(
                get: { take.marked },
                set: { _ in model.toggleWTake(take.id) })
            ) {
                HStack(spacing: 6) {
                    Text(take.variant.label ?? "take")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if take.id == state.activeVariantID {
                        Text("shown here").font(.caption2).foregroundStyle(.tertiary)
                    }
                    if take.variant.locked {
                        Text("locked").font(.caption2).foregroundStyle(.tertiary)
                    }
                }
            }

            if take.marked {
                // The full text with the cut marker in place.
                markedText(take)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                if take.boundaries.isEmpty {
                    Text("This take has no legal cut — unmark it or edit it first.")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                } else {
                    // Click-to-place: one button per legal cut position.
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            Text("cut at:").font(.caption2).foregroundStyle(.secondary)
                            ForEach(take.boundaries, id: \.self) { boundary in
                                Button {
                                    model.placeWCut(takeID: take.id, cut: boundary)
                                } label: {
                                    Text(snippet(around: boundary, in: take.variant.workingText))
                                        .font(.caption2)
                                        .fontWeight(take.cut == boundary ? .bold : .regular)
                                }
                            }
                        }
                    }
                }
            } else {
                Text(take.variant.workingText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 2)
    }

    private func markedText(_ take: EditorViewModel.WTake) -> Text {
        let text = take.variant.workingText
        guard let cut = take.cut,
              let index = BoundarySnapping.graphemeIndex(atUTF16: cut, in: text)
        else {
            return Text(text) + Text("  (place the cut below)")
                .foregroundStyle(.orange)
        }
        return Text(String(text[..<index]))
            + Text(" ✂ ").foregroundStyle(.red)
            + Text(String(text[index...]))
    }

    /// A short context label for a cut position ("…ence. ⟂ Second…").
    private func snippet(around boundary: Int, in text: String) -> String {
        guard let index = BoundarySnapping.graphemeIndex(atUTF16: boundary, in: text) else {
            return "\(boundary)"
        }
        let before = String(text[..<index].suffix(8))
        let after = String(text[index...].prefix(8))
        return "…\(before)⟂\(after)…"
    }
}
