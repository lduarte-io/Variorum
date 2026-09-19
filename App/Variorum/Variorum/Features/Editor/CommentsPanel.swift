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

    /// **THE PANEL'S ONE MESSAGE SLOT — receipt or refusal** (13u3 UNIT A2).
    /// The class is decided AT THE DOOR that produced it (18i's R-Q5, the
    /// status seam's law), never guessed by the view from the words. This is
    /// `Shared/RecoveryStatus`, the same type the tray's panel uses, for the
    /// reason that type's own doc gives: a receipt/refusal split written
    /// twice is the drift the split exists to prevent.
    ///
    /// **Why a LOCAL slot and not `StatusCenter`:** the panel is a sheet or a
    /// popover over the shell, so the shell's toast sits BEHIND it — a
    /// refusal delivered there is a refusal she cannot read. The tray panel
    /// made the same call for the same geometry. Everything the panel says is
    /// classed here and rendered in the voice's own registers (alarm for a
    /// refusal, muted for a receipt).
    private(set) var status: RecoveryStatus?

    /// The pre-existing read, kept as a forwarder so every shipped pin over
    /// the panel rides unmodified (the `TrayViewModel` parity pattern).
    var statusMessage: String? { status?.text }

    /// **THE DRAFTS.** Edit-in-place means the panel holds unsaved prose, and
    /// it holds it HERE rather than in per-row view state for one concrete
    /// reason: the rows are lazy, so a row scrolled out of sight is torn
    /// down, and a draft living in its `@State` would go with it. An entry
    /// exists only for a comment she has actually typed into.
    private(set) var drafts: [String: String] = [:]

    /// The add area's draft. Settable — the add editor binds straight to it.
    var addDraft: String = ""

    /// Ids whose save has LANDED and whose echo has not arrived yet. Without
    /// this the row wears its "unsaved" mark for the milliseconds between the
    /// write committing and the observation delivering — a mark that says the
    /// opposite of what just happened.
    private var justSaved: Set<String> = []

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
            status = .refusal("Comments observation failed: \(error)")
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
        let stored = Dictionary(
            snapshot.live.map { ($0.id, $0.text) }, uniquingKeysWith: { _, last in last })
        drafts = CommentComposition.survivingDrafts(drafts, stored: stored)
        justSaved = justSaved.filter { drafts[$0] != nil }
    }

    // MARK: - The drafts (13u3 UNIT A2 — edit in place)

    /// What the row shows: her draft if she has typed into it, else what is
    /// stored. A clean row renders the store directly — no copy to drift.
    func draft(for id: String) -> String {
        drafts[id] ?? stored(id) ?? ""
    }

    func setDraft(_ text: String, for id: String) {
        drafts[id] = text
        justSaved.remove(id)
    }

    /// Has this row unsaved changes — meaning exactly "committing would do
    /// something"? (`CommentComposition.isDirty`'s rule, plus the landed-but-
    /// not-yet-echoed window.)
    func isDirty(_ id: String) -> Bool {
        guard !justSaved.contains(id),
              let draft = drafts[id], let stored = stored(id) else { return false }
        return CommentComposition.isDirty(draft: draft, stored: stored)
    }

    var isAddDraftFilable: Bool { CommentComposition.filing(addDraft) != .nothing }

    private func stored(_ id: String) -> String? {
        comments.first { $0.id == id }?.text
    }

    // MARK: - The doors

    /// ⌘⏎ (or the Add button) in the add area.
    func fileAddDraft() async {
        switch CommentComposition.filing(addDraft) {
        case .nothing:
            // Silent. Nothing was typed, so nothing is refused — a scold
            // here would be the app talking to itself.
            return
        case .file(let text):
            if await perform({ [blockID] ops in
                _ = try ops.addBlockComment(to: blockID, text: text)
            }) {
                addDraft = ""
            }
        }
    }

    func clearAddDraft() {
        addDraft = ""
    }

    /// ⌘⏎ in a comment, and what moving focus away from a dirty one does.
    func commitEdit(_ id: String) async {
        guard let stored = stored(id) else { return }
        switch CommentComposition.commit(draft: draft(for: id), stored: stored) {
        case .unchanged:
            drafts[id] = nil
        case .emptied:
            drafts[id] = nil
            status = .refusal(CommentsPanelCopy.emptied)
        case .save(let text):
            if await perform({ ops in try ops.editBlockComment(id, text: text) }) {
                drafts[id] = text
                justSaved.insert(id)
            }
        }
    }

    /// ⎋ in a comment: back to what is stored.
    func revertEdit(_ id: String) {
        drafts[id] = nil
        justSaved.remove(id)
    }

    func add(_ text: String) async {
        _ = await perform { [blockID] ops in
            _ = try ops.addBlockComment(to: blockID, text: text)
        }
    }

    func edit(_ id: String, text: String) async {
        // The ONE trim rule, so this door and `commitEdit` cannot store
        // different text for the same keystrokes.
        let text = CommentComposition.trimmed(text)
        _ = await perform { ops in try ops.editBlockComment(id, text: text) }
    }

    func delete(_ id: String) async {
        if await perform({ ops in try ops.deleteBlockComment(id) }) {
            status = .receipt(CommentsPanelCopy.deleted)
        }
    }

    func restore(_ id: String) async {
        if await perform({ ops in try ops.restoreBlockComment(id) }) {
            status = .receipt(CommentsPanelCopy.restored)
        }
    }

    /// Runs one operation and CLASSES what came back. Returns whether it
    /// landed, so the caller can speak its own receipt (a receipt says what
    /// happened, which only the door knows).
    private func perform(
        _ body: @escaping @Sendable (Operations) throws -> Void
    ) async -> Bool {
        status = nil
        do {
            try await session.runner.run(body)
            return true
        } catch let error as OperationError {
            switch error {
            case .lockedPost:
                status = .refusal(CommentsPanelCopy.sealed)
            case .invalidCommentText:
                status = .refusal(CommentsPanelCopy.needsText)
            default:
                status = .refusal("Refused: \(error)")
            }
            return false
        } catch {
            status = .refusal(String(describing: error))
            return false
        }
    }
}

/// The panel's words, in one place — the wordings a pin reads and the walk
/// sees.
enum CommentsPanelCopy {
    static let sealed = "This note is sealed — unseal it to change comments."
    static let needsText = "A comment needs some text."
    /// Emptying a comment is not how you remove one: the door that removes
    /// it is named, and it is one click away on the same row.
    static let emptied = "A comment needs some text — Delete removes it."
    static let deleted = "Comment deleted — it is under \"deleted\" below, restorable."
    static let restored = "Comment restored."
    static let addPlaceholder = "Write a comment…"
    static let unsavedMark = "unsaved · ⌘⏎"
    static let fileHint = "⌘⏎ files it · ⎋ clears"
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
