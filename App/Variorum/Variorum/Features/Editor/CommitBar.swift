//
//  CommitBar.swift
//  Variorum
//
//  The commit shortcut's visible face (Phase 7 Step 5): commit the caret
//  block's take, toggle its history. Functional, unstyled.
//

import SwiftUI
import VariorumCore

struct CommitBar: View {
    let model: EditorViewModel

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 12) {
                Text(caretLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button("Commit (⌘S)") { model.commitCaretVariant() }
                    .disabled(model.caretVariantID == nil || model.header?.locked == true)
                Button(model.commitList == nil ? "History" : "Hide History") {
                    model.toggleCommitHistory()
                }
                .disabled(model.caretVariantID == nil && model.commitList == nil)

                Divider().frame(height: 14)

                // The gesture button bar (9d — the fourth door): dimmed by
                // the planner's verdict but ALWAYS clickable — a refused
                // click speaks its refusal instead of going silent.
                gestureButton("Divide", available: model.gestureAvailability.divide,
                              action: model.divideAtCursor)
                gestureButton("Extract", available: model.gestureAvailability.extract,
                              action: model.extractSelection)
                gestureButton("Make Block", available: model.gestureAvailability.makeBlock,
                              action: model.makeBlockFromSelection)
                gestureButton("Merge", available: model.gestureAvailability.merge,
                              action: model.mergeBlocks)
                gestureButton("Takes", available: model.gestureAvailability.takes,
                              action: model.openCaretFan)

                Spacer()
                if let words = wordCountLabel {
                    Text(words)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize()
                }
                if let status = model.statusMessage {
                    Text(status)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .padding(6)
            if model.commitList != nil {
                CommitHistoryView(model: model)
                    .frame(maxHeight: 180)
            }
        }
    }

    private func gestureButton(
        _ title: String, available: Bool, action: @escaping () -> Void
    ) -> some View {
        Button(title, action: action)
            .controlSize(.small)
            .opacity(available ? 1 : 0.45)
    }

    private var caretLabel: String {
        if model.caretBlockID != nil {
            // "block 6/23" (9d): the user-facing number is the current
            // order, derived at read time; the stable ID stays the identity.
            let ordinal = model.caretOrdinal.map { "\($0)/\(model.blockCount)" } ?? "—"
            return "block \(ordinal) · \(shortID(model.caretBlockID))"
        }
        if model.hasOpenTail { return "open tail" }
        return "—"
    }

    private var wordCountLabel: String? {
        var parts: [String] = []
        if let block = model.caretBlockWordCount { parts.append("\(block) words") }
        if let selected = model.selectionWordCount { parts.append("\(selected) selected") }
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }

    private func shortID(_ id: String?) -> String {
        String((id ?? "").prefix(8))
    }
}

/// The caret variant's append-only history, newest first, with restore —
/// and the documented pre-split warning (AppSpec §9) marked per row.
struct CommitHistoryView: View {
    let model: EditorViewModel

    var body: some View {
        List(model.commitList ?? []) { item in
            HStack(spacing: 8) {
                Text(item.commit.createdAt.formatted(date: .abbreviated, time: .standard))
                    .font(.caption)
                Text(item.commit.kind == .auto ? "auto" : "manual")
                    .font(.caption2)
                    .foregroundStyle(item.commit.kind == .auto ? .secondary : .primary)
                if let message = item.commit.message {
                    Text(message).font(.caption).lineLimit(1)
                }
                if item.predatesSplit {
                    Text("predates a split")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
                Spacer()
                Text(String(item.commit.text.prefix(60)))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Button("Restore") { model.restore(item) }
                    .controlSize(.small)
                    .disabled(model.header?.locked == true)
            }
        }
    }
}
