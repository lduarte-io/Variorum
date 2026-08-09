//
//  MobileNoteTags.swift
//  VariorumMobile
//
//  Parity round Stage C, batch C3 — TAGS ON A NOTE (the LK5 expansion's
//  "tag posts — again, full app functionality"; the leaf-chip grammar,
//  13k K3, binds the display). The masthead's identity area wears the
//  note's tag chips; tapping them opens this sheet:
//
//  · SEE the applied tags — chips show the LEAF only (K3's letter:
//    "chips should show leaf only"); the full path stays visible on the
//    sheet's own rows, where hierarchy is surfaced (R45).
//  · APPLY by typing — the Mac N24 road mirrored ("freely type tags in
//    …, not just select from already created tags"): a typed path walks
//    the live taxonomy for its deepest existing prefix, CREATES the
//    missing remainder through the standing ops (child tags included —
//    her ruling 2's letter), and applies the leaf. Suggestions filter
//    the taxonomy as you type; tapping one applies it.
//  · REMOVE with the chip's ✕ — one `removeTag` per tap.
//
//  Every act routes through the existing core operations (`createTag`,
//  `applyTag`, `removeTag`); refusals speak in phone words through the
//  manager's one copy brain.
//

import Foundation
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class MobileNoteTagsModel {
    @ObservationIgnored private let session: AppSession
    @ObservationIgnored let postID: String

    private(set) var applied: [Tag] = []
    private(set) var allTags: [Tag] = []
    private(set) var status: String?

    init(session: AppSession, postID: String) {
        self.session = session
        self.postID = postID
    }

    // MARK: - Pure brains (pinned)

    /// The masthead chip line — LEAF-ONLY per K3 ("#goals #sea"); nil
    /// when the note wears nothing (the chip renders its door word).
    nonisolated static func chipLine(paths: [String]) -> String? {
        guard !paths.isEmpty else { return nil }
        return paths.map { "#\(MobileShelfFaces.leaf($0))" }.joined(separator: " ")
    }

    /// The suggestion rule — the Mac `TagChipAdder.suggestions` mirrored:
    /// case-insensitive substring over paths, already-applied dropped,
    /// capped so the list never becomes a taxonomy scroll.
    nonisolated static func suggestions(
        _ all: [Tag], typed: String, applied: Set<String>, limit: Int = 8
    ) -> [Tag] {
        let needle = typed.trimmingCharacters(in: .whitespaces).lowercased()
        return all
            .filter { !applied.contains($0.path) }
            .filter { needle.isEmpty || $0.path.lowercased().contains(needle) }
            .prefix(limit)
            .map { $0 }
    }

    // MARK: - Reads

    func refresh() async {
        do {
            let postID = postID
            let (mine, all) = try await session.database.read { db in
                (try Queries.postTags(db, postID: postID), try Queries.allTags(db))
            }
            applied = mine
            allTags = all
        } catch {
            status = String(describing: error)
        }
    }

    var chipLine: String? {
        Self.chipLine(paths: applied.map(\.path))
    }

    // MARK: - Acts (every one an existing core operation)

    /// The typed-path road (the Mac `TagAssignmentViewModel.applyTypedPath`
    /// brain mirrored): resolve the deepest existing live prefix from a
    /// read; create the missing segments + apply the leaf in ONE
    /// serialized runner turn (a racing duplicate refuses through the
    /// op's own guard). Slash noise collapses forgivingly ("/a//b/" is
    /// a/b); an already-applied leaf no-ops politely. Returns the leaf's
    /// path on success (the field clears on it).
    ///
    /// Since FIX-C3a the segments/resolution/create walk is
    /// `MobileTagsModel`'s ONE typed-path brain — the manager's
    /// "+ new tag" door walks the same rule, so the two typing surfaces
    /// cannot drift (this road keeps its apply half and its one-turn
    /// composition byte-identical).
    @discardableResult
    func applyTypedPath(_ raw: String) async -> String? {
        let segments = MobileTagsModel.typedSegments(raw)
        guard !segments.isEmpty else {
            status = MobileTagsModel.emptyTypedPathMessage
            return nil
        }
        do {
            let post = postID
            let live = try await session.database.read { try Queries.allTags($0) }
            guard let plan = MobileTagsModel.typedPathPlan(segments: segments, live: live)
            else { return nil }
            try await session.runner.run { [plan] ops in
                guard let leafID = try MobileTagsModel.createMissing(plan, ops: ops)
                else { return }
                do {
                    _ = try ops.applyTag(leafID, toPost: post)
                } catch OperationError.alreadyTagged {
                    // Already wearing it — typing it again is a no-op,
                    // never an error.
                }
            }
            await refresh()
            status = nil
            return plan.leafPath
        } catch {
            status = MobileTagsModel.refusal(error)
            return nil
        }
    }

    /// The chip's ✕ — takes the tag off THIS note; the tag itself lives.
    func remove(_ tag: Tag) async {
        do {
            try await session.runner.run { [postID] ops in
                try ops.removeTag(tag.id, fromPost: postID)
            }
            status = nil
        } catch {
            status = MobileTagsModel.refusal(error)
        }
        await refresh()
    }
}

/// The note-tags sheet (LK4's grammar — the membership sheet's exact
/// shape, tags-flavored).
struct MobileNoteTagsSheet: View {
    @Bindable var model: MobileNoteTagsModel
    let tokens: VoiceTokens
    @Environment(\.dismiss) private var dismiss

    @State private var typed = ""
    @FocusState private var typedFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(tokens.chromeLabel("Tags"))
                    .font(tokens.title)
                    .foregroundStyle(tokens.ink)
                Spacer()
                Button(tokens.chromeLabel("Done")) { dismiss() }
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .buttonStyle(.plain)
            }
            typeField
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    appliedSection
                    suggestionSection
                    if let status = model.status {
                        Text(status)
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(20)
        .background(tokens.room.ignoresSafeArea())
        .task { await model.refresh() }
    }

    private var typeField: some View {
        TextField(
            tokens.chromeLabel("type a tag — ⏎ applies it (“/” nests: life/goals)"),
            text: $typed
        )
        .textFieldStyle(.plain)
        .font(tokens.small)
        .foregroundStyle(tokens.ink)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(tokens.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(tokens.line, lineWidth: 1)))
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .focused($typedFocused)
        .onSubmit {
            let raw = typed
            let model = model
            Task {
                if await model.applyTypedPath(raw) != nil {
                    typed = ""
                }
                typedFocused = true
            }
        }
    }

    @ViewBuilder
    private var appliedSection: some View {
        if model.applied.isEmpty {
            Text(tokens.chromeLabel(
                "This note wears no tags yet — type one above, or tap a suggestion."))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            ForEach(model.applied, id: \.id) { tag in
                HStack(spacing: 10) {
                    // The chip says the LEAF (K3); the row beside it says
                    // the whole path (hierarchy stays surfaced, R45).
                    Text("#\(MobileShelfFaces.leaf(tag.path))")
                        .font(tokens.body)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(1)
                    if tag.path.contains("/") {
                        Text(tag.path)
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .lineLimit(1)
                    }
                    Spacer()
                    Button(tokens.chromeLabel("✕ remove")) {
                        let model = model
                        Task { await model.remove(tag) }
                    }
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove tag \(tag.path)")
                }
                .padding(.vertical, 4)
            }
        }
    }

    @ViewBuilder
    private var suggestionSection: some View {
        let suggestions = MobileNoteTagsModel.suggestions(
            model.allTags, typed: typed, applied: Set(model.applied.map(\.path)))
        if !suggestions.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                Text(tokens.chromeLabel("Apply a tag"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .padding(.top, 6)
                ForEach(suggestions, id: \.id) { tag in
                    Button {
                        let model = model
                        let path = tag.path
                        Task {
                            _ = await model.applyTypedPath(path)
                            typed = ""
                        }
                    } label: {
                        HStack {
                            Text(tokens.chromeLabel("+ #\(tag.path)"))
                                .font(tokens.body)
                                .foregroundStyle(tokens.accent)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
