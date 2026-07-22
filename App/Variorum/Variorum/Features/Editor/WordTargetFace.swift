//
//  WordTargetFace.swift
//  Variorum
//
//  13b Stage 4, Batch 4F (S4-28.1, ledger N36) — the per-post word
//  target's ONE face, riding the word-count label BOTH bars already carry
//  (Write's CommitBar and the Takes/Lenses bar — R118 parity of
//  prominence, zero new bar width on the crowded-bar surfaces N15/N35
//  fought over). The label shows progress when a target is set ("… ·
//  26% of 5,000w target"); clicking it opens the setter popover
//  (ExtentInput — the shelf's one parse rule; unparseable input refuses
//  and keeps, the standing extent-sheet discipline). Display/progress
//  ONLY — the ratified word_target semantics, mirrored per post.
//

import SwiftUI
import VariorumCore

struct WordTargetFace: View {
    let tokens: VoiceTokens
    /// The bar's word-count line ("12w block · 1,240w in post").
    let baseLabel: String
    /// The post's total words (the progress numerator; nil = unknown yet).
    let words: Int?
    /// The stored target (nil = none).
    let target: Int?
    /// Runs the op (`setPostWordTarget`) — refusals speak via the caller's
    /// standing error door.
    let onSet: (Int?) async -> Void

    @State private var shown = false
    @State private var field = ""
    @State private var parseError: String?

    var body: some View {
        Button {
            field = target.map(String.init) ?? ""
            parseError = nil
            shown = true
        } label: {
            // R11's register preserved: the counts stay the prominent
            // accent-colored part of the surface; the face adds only the
            // progress segment.
            Text(tokens.chromeLabel(label))
                .font(tokens.small.weight(.semibold))
                .foregroundStyle(tokens.accent)
                .lineLimit(1)
        }
        .buttonStyle(.plain)
        .help(WordTargetFaceCopy.help)
        .popover(isPresented: $shown, arrowEdge: .bottom) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Word target — this post").font(.headline)
                TextField(WordTargetFaceCopy.fieldPrompt, text: $field)
                    .frame(width: 220)
                    .onSubmit { save() }
                Text("A target shows progress beside the word counts. "
                    + "It is a measure, never a wall — nothing refuses at the boundary.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 220, alignment: .leading)
                if let parseError {
                    Text(parseError).font(.caption).foregroundStyle(.red)
                }
                HStack {
                    Button("Clear") {
                        shown = false
                        Task { await onSet(nil) }
                    }
                    Spacer()
                    Button("Set") { save() }
                        .keyboardShortcut(.defaultAction)
                }
            }
            .padding(12)
        }
    }

    private var label: String {
        guard let target, target > 0 else { return baseLabel }
        let segment = WordTargetFaceCopy.progressSegment(words: words ?? 0, target: target)
        return baseLabel.isEmpty ? segment : "\(baseLabel) · \(segment)"
    }

    private func save() {
        guard let parsed = ExtentInput.parse(field) else {
            parseError = WordTargetFaceCopy.parseError
            return
        }
        shown = false
        Task { await onSet(parsed.intValue) }
    }
}
