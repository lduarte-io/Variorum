//
//  CommentsPanel.swift
//  Variorum
//
//  Phase 13, C1 — the block's comments panel (R7 + the §14 items 6/9
//  letter): every comment face (margin card, inline strip, count badge,
//  Block menu) opens here. Working notes on a BLOCK, never per-take; CRUD
//  through the Stage A operations; and the DELETED section — visible and
//  resurrectable ("the feature shouldn't be excessively skimpy"). Refusals
//  surface as plain status text (the operations layer enforces; the panel
//  renders what it says).
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class CommentsPanelModel {
    @ObservationIgnored let session: AppSession
    let blockID: String

    init(session: AppSession, blockID: String) {
        self.session = session
        self.blockID = blockID
    }

    private(set) var comments: [BlockComment] = []
    private(set) var deleted: [BlockComment] = []
    private(set) var statusMessage: String?

    /// Live for the panel's lifetime — one block's notes, both lists.
    func start() async {
        do {
            for try await value in session.database.observe({ [blockID] db in
                Snapshot(
                    live: try Queries.blockComments(db, blockID: blockID),
                    deleted: try Queries.deletedBlockComments(db, blockID: blockID))
            }) {
                adopt(value)
            }
        } catch is CancellationError {
        } catch {
            statusMessage = "Comments observation failed: \(error)"
        }
    }

    nonisolated struct Snapshot: Equatable, Sendable {
        var live: [BlockComment] = []
        var deleted: [BlockComment] = []
    }

    /// Internal so tests drive the panel without the observation.
    func adopt(_ snapshot: Snapshot) {
        comments = snapshot.live
        deleted = snapshot.deleted
    }

    func add(_ text: String) async {
        await run { [blockID] ops in
            _ = try ops.addBlockComment(to: blockID, text: text)
        }
    }

    func edit(_ id: String, text: String) async {
        await run { ops in try ops.editBlockComment(id, text: text) }
    }

    func delete(_ id: String) async {
        await run { ops in try ops.deleteBlockComment(id) }
    }

    func restore(_ id: String) async {
        await run { ops in try ops.restoreBlockComment(id) }
    }

    private func run(_ body: @escaping @Sendable (Operations) throws -> Void) async {
        statusMessage = nil
        do {
            try await session.runner.run(body)
        } catch let error as OperationError {
            switch error {
            case .lockedPost:
                statusMessage = "This note is sealed — unseal it to change comments."
            case .invalidCommentText:
                statusMessage = "A comment needs some text."
            default:
                statusMessage = "Refused: \(error)"
            }
        } catch {
            statusMessage = String(describing: error)
        }
    }
}

struct CommentsPanel: View {
    let session: AppSession
    let blockID: String
    @State private var model: CommentsPanelModel
    @State private var draft = ""
    @State private var editingID: String?
    @State private var editDraft = ""
    @State private var deletedShown = false
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    init(session: AppSession, blockID: String, model: CommentsPanelModel? = nil) {
        self.session = session
        self.blockID = blockID
        _model = State(initialValue: model
            ?? CommentsPanelModel(session: session, blockID: blockID))
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(tokens.chromeLabel("Comments — block \(String(blockID.prefix(8)))"))
                    .font(tokens.heading)
                    .foregroundStyle(tokens.ink)
                Spacer()
                Button("Close") { dismiss() }
            }
            if let status = model.statusMessage {
                Text(status)
                    .font(tokens.small)
                    .alarmVoice()
                    .textSelection(.enabled)
            }
            List {
                ForEach(model.comments, id: \.id) { comment in
                    row(comment)
                }
                if model.comments.isEmpty {
                    Text(tokens.chromeLabel("No comments on this block yet."))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                }
                if !model.deleted.isEmpty {
                    Section {
                        if deletedShown {
                            ForEach(model.deleted, id: \.id) { comment in
                                deletedRow(comment)
                            }
                        }
                    } header: {
                        Button {
                            deletedShown.toggle()
                        } label: {
                            Text(tokens.chromeLabel(
                                "\(deletedShown ? "▾" : "▸") deleted (\(model.deleted.count))"))
                                .font(tokens.small)
                                .foregroundStyle(tokens.muted)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            HStack(spacing: 8) {
                TextField(
                    tokens.chromeLabel("Add a comment…"), text: $draft, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                    .onSubmit(addDraft)
                Button("Add") { addDraft() }
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(12)
        .frame(minWidth: 440, minHeight: 320)
        .background(tokens.surface)
        .task { await model.start() }
    }

    private func addDraft() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        draft = ""
        Task { await model.add(text) }
    }

    @ViewBuilder
    private func row(_ comment: BlockComment) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            if editingID == comment.id {
                TextField("Comment", text: $editDraft, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...6)
                HStack {
                    Button("Save") {
                        let text = editDraft
                        editingID = nil
                        Task { await model.edit(comment.id, text: text) }
                    }
                    .disabled(editDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    Button("Cancel") { editingID = nil }
                }
                .controlSize(.small)
            } else {
                Text(tokens.commentPrefix + comment.text)
                    .font(tokens.body)
                    .foregroundStyle(tokens.commentInk)
                    .textSelection(.enabled)
                HStack(spacing: 8) {
                    Text(comment.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                    Button("Edit") {
                        editDraft = comment.text
                        editingID = comment.id
                    }
                    Button("Delete", role: .destructive) {
                        Task { await model.delete(comment.id) }
                    }
                }
                .controlSize(.small)
                .buttonStyle(.borderless)
            }
        }
        .padding(.vertical, 3)
    }

    private func deletedRow(_ comment: BlockComment) -> some View {
        HStack(spacing: 8) {
            Text(comment.text)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .strikethrough()
                .lineLimit(2)
            Spacer()
            Button(tokens.chromeLabel("Restore")) {
                Task { await model.restore(comment.id) }
            }
            .controlSize(.small)
        }
        .padding(.vertical, 2)
    }
}
