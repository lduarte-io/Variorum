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
                Spacer()
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

    private var caretLabel: String {
        if model.caretBlockID != nil { return "block \(shortID(model.caretBlockID))" }
        if model.hasOpenTail { return "open tail" }
        return "—"
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
