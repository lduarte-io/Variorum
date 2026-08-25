//
//  MobileTagManager.swift
//  VariorumMobile
//
//  Parity round Stage C, batch C3 — TAG MANAGEMENT on the phone (her
//  mid-chain sitting ruling 2, verbatim grounds: "I know some people
//  won't use the mac app at all, so I'm inclined to say cross fully").
//  The Mac's home is Settings (R52 — "tag management's real home"), and
//  the phone mirrors that placement: a "Manage Tags" door in Settings
//  opens this sheet.
//
//  What the manager carries — the Mac TagManagerPane's own vocabulary,
//  phone-grammared (long-press where the Mac right-clicks):
//
//  · BROWSE the hierarchy — indented rows in path order (parents before
//    children by the materialized path's construction; the tree IS the
//    hierarchy surfaced, R45).
//  · CREATE — "+ new tag" at the list's end (root), "New Child Tag…" on
//    a row's long-press (her ruling's letter: phone tag-create supports
//    child tags).
//  · RENAME — the op rewrites the whole subtree's paths in one
//    transaction (`renameTag`, AppSpec §9).
//  · DELETE — with subtree, behind a confirm that NAMES THE CONSEQUENCE
//    (the C3 brief's letter: the consequence, never a platform): how
//    many sub-tags go with it, and that notes lose those tags.
//
//  Every act routes through the existing core operations (`createTag`,
//  `renameTag`, `deleteTag`); refusals speak in phone words. Block tags
//  stay Mac-side (her ruling 3) — nothing here touches them.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class MobileTagsModel {
    @ObservationIgnored private let session: AppSession

    private(set) var tags: [Tag] = []
    private(set) var lastError: String?

    init(session: AppSession) {
        self.session = session
    }

    /// The live taxonomy (author-scale metadata — the Mac TagsViewModel's
    /// own unbounded observation; cost ∝ tag count, never corpus).
    func start() async {
        do {
            for try await value in session.database.observeTags() {
                tags = value
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// One-shot for headless determinism (tests and the sheet's first
    /// paint drive this; the observation echoes it in production).
    func refresh() async {
        do {
            tags = try await session.database.read { try Queries.allTags($0) }
        } catch {
            lastError = String(describing: error)
        }
    }

    // MARK: - Pure brains (pinned)

    /// Indent depth for the tree presentation (path components below
    /// root — the Mac `TagsViewModel.depth`'s exact rule).
    nonisolated static func depth(of tag: Tag) -> Int {
        tag.path.reduce(0) { $0 + ($1 == "/" ? 1 : 0) }
    }

    /// How many live tags sit UNDER this one (the subtree the delete
    /// takes along) — pure over the listed taxonomy, the same prefix
    /// rule the op's own SQL applies.
    nonisolated static func subtreeCount(of tag: Tag, in all: [Tag]) -> Int {
        let prefix = tag.path + "/"
        return all.count { $0.path.hasPrefix(prefix) }
    }

    /// The delete confirm's message — the CONSEQUENCE named, never a
    /// platform (the C3 brief's letter). Two arms: a leaf tag, and a
    /// tag carrying a subtree.
    nonisolated static func deleteConsequence(name: String, subtreeCount: Int) -> String {
        if subtreeCount == 0 {
            return "Deleting “\(name)” takes it off every note that wears it. "
                + "There is no undo for this."
        }
        let word = subtreeCount == 1 ? "sub-tag" : "sub-tags"
        return "Deleting “\(name)” also deletes its \(subtreeCount) \(word) — "
            + "every note wearing any of them loses those tags. There is no undo for this."
    }

    // MARK: - The typed-path create brain (FIX-C3a — ONE create rule)

    /// The typed-path CREATE walk, shared: the note-tags sheet's typing
    /// field and the manager's "+ new tag" door both resolve a typed
    /// "life/goals" through THESE brains — one rule everywhere, reused
    /// and never copied (the six-copied-brains KnownIssues row is the
    /// anti-pattern; a third copy inside one target would be its worst
    /// form).

    /// Slash noise collapses forgivingly ("/a//b/" is a/b) — pure.
    nonisolated static func typedSegments(_ raw: String) -> [String] {
        raw.split(separator: "/")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    /// The empty-type hint — ONE sentence for both typing surfaces.
    static let emptyTypedPathMessage =
        "Type a tag name — “/” makes a hierarchy (life/goals)."

    /// A typed path resolved against the live taxonomy: the deepest
    /// existing live prefix anchors creation; the missing remainder
    /// creates on the way.
    struct TypedPathPlan: Equatable, Sendable {
        /// The deepest existing prefix's id — the create anchor (nil ⇒
        /// creation starts at the root).
        var parentID: String?
        /// The segments still to create, in order.
        var missing: [String]
        /// Non-nil when the WHOLE path already exists (nothing to create).
        var existingLeafID: String?
        /// The full path the walk lands on.
        var leafPath: String
    }

    /// The resolution half — pure over a taxonomy read (nil on empty
    /// segments; the caller speaks `emptyTypedPathMessage`).
    nonisolated static func typedPathPlan(
        segments: [String], live: [Tag]
    ) -> TypedPathPlan? {
        guard !segments.isEmpty else { return nil }
        var parentID: String?
        var missing: [String] = []
        var existingLeafID: String?
        var path = ""
        for (i, segment) in segments.enumerated() {
            path = path.isEmpty ? segment : "\(path)/\(segment)"
            if missing.isEmpty, let existing = live.first(where: { $0.path == path }) {
                parentID = existing.id
                if i == segments.count - 1 { existingLeafID = existing.id }
            } else {
                missing.append(segment)
            }
        }
        return TypedPathPlan(
            parentID: parentID, missing: missing,
            existingLeafID: existingLeafID, leafPath: path)
    }

    /// The create half, run INSIDE one serialized runner turn (a racing
    /// duplicate refuses through the op's own guard): creates the plan's
    /// missing segments through the standing ops and returns the LEAF's
    /// id.
    nonisolated static func createMissing(
        _ plan: TypedPathPlan, ops: Operations
    ) throws -> String? {
        var parent = plan.parentID
        for segment in plan.missing {
            parent = try ops.createTag(parent: parent, name: segment).id
        }
        return plan.existingLeafID ?? parent
    }

    /// Refusal copy in phone words (no platform names) — the Mac
    /// `TagsViewModel.message` semantics mirrored.
    nonisolated static func refusal(_ error: Error) -> String {
        guard let op = error as? OperationError else {
            return String(describing: error)
        }
        switch op {
        case .invalidTagName:
            return "Tag names can't be empty or contain “/”."
        case .duplicateTagPath(let path):
            return "A tag named “\(path)” already exists."
        case .tagNotFound:
            return "That tag no longer exists."
        default:
            return "Refused: \(op)"
        }
    }

    // MARK: - Acts (every one an existing core operation)

    func create(parentID: String?, name: String) async {
        await run { ops in _ = try ops.createTag(parent: parentID, name: name) }
    }

    /// The "+ new tag" door — the typed-path road (FIX-C3a): a typed
    /// "life/goals" resolves its deepest existing live prefix and
    /// CREATES the missing remainder, the SAME rule the note-tags
    /// sheet's typing field walks — so the empty state's "“/” nests"
    /// hint teaches a road this door actually walks. A fully-existing
    /// path refuses as the duplicate it is (the single-segment door's
    /// own standing refusal — one rule, one sentence); the empty type
    /// gets the shared hint.
    func createTypedPath(_ raw: String) async {
        let segments = Self.typedSegments(raw)
        guard !segments.isEmpty else {
            lastError = Self.emptyTypedPathMessage
            return
        }
        do {
            let live = try await session.database.read { try Queries.allTags($0) }
            guard let plan = Self.typedPathPlan(segments: segments, live: live) else {
                return
            }
            if plan.existingLeafID != nil {
                lastError = Self.refusal(
                    OperationError.duplicateTagPath(path: plan.leafPath))
                await refresh()
                return
            }
            try await session.runner.run { [plan] ops in
                _ = try MobileTagsModel.createMissing(plan, ops: ops)
            }
            lastError = nil
        } catch {
            lastError = Self.refusal(error)
        }
        await refresh()
    }

    func rename(_ id: String, to newName: String) async {
        await run { ops in try ops.renameTag(id, newName: newName) }
    }

    /// Deletes the tag AND its subtree (the op's contract; the per-tag
    /// trigger tombstones applications). The confirm upstream named the
    /// consequence — this just does it.
    func delete(_ id: String) async {
        await run { ops in try ops.deleteTag(id) }
    }

    private func run(_ body: @escaping @Sendable (Operations) throws -> Void) async {
        do {
            try await session.runner.run(body)
            lastError = nil
        } catch {
            lastError = Self.refusal(error)
        }
        await refresh()
    }
}

/// The manager sheet (LK4's sheet grammar — the taxonomy is summoned
/// depth, opened from Settings, its R52 home).
struct MobileTagManagerSheet: View {
    /// The Settings door's word (voice-cased at render, pinned).
    static let doorTitle = "Manage Tags"

    /// The empty state's hint — a promise the + new tag door itself
    /// keeps (FIX-C3a: the door walks the typed-path road, so "“/”
    /// nests" names a road its own door walks; pinned WITH the door's
    /// typed-path pin so the promise and the behavior can never drift
    /// apart again).
    static let emptyStateHint =
        "No tags yet — + new tag starts the taxonomy; “/” nests (life/goals)."

    @State private var model: MobileTagsModel
    let tokens: VoiceTokens
    @Environment(\.dismiss) private var dismiss

    /// The alerts' shared name field + their targets.
    @State private var nameField = ""
    @State private var createParent: Tag?
    @State private var createPresented = false
    @State private var renameTarget: Tag?
    @State private var deleteTarget: Tag?

    init(session: AppSession, tokens: VoiceTokens) {
        _model = State(initialValue: MobileTagsModel(session: session))
        self.tokens = tokens
    }

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
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(model.tags, id: \.id) { tag in
                        tagRow(tag)
                    }
                    if model.tags.isEmpty {
                        Text(tokens.chromeLabel(Self.emptyStateHint))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .padding(.vertical, 20)
                    }
                    newTagRow
                }
            }
            if let error = model.lastError {
                Text(error)
                    .font(tokens.small)
                    .foregroundStyle(tokens.alarm)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(20)
        .background(tokens.room.ignoresSafeArea())
        .task { await model.refresh() }
        .task { await model.start() }
        .alert(
            createParent == nil ? "New Tag" : "New Child Tag",
            isPresented: $createPresented
        ) {
            TextField("Name", text: $nameField)
            Button("Create") {
                let name = nameField
                let parent = createParent?.id
                let model = model
                Task {
                    if let parent {
                        await model.create(parentID: parent, name: name)
                    } else {
                        // The typed-path road (FIX-C3a) — the note-tags
                        // sheet's own create rule: "life/goals" creates
                        // the hierarchy on the way.
                        await model.createTypedPath(name)
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            if let parent = createParent {
                Text("A child of “\(parent.path)”.")
            } else {
                Text("“/” nests (life/goals) — missing parents are created on the way.")
            }
        }
        .alert(
            "Rename Tag",
            isPresented: Binding(
                get: { renameTarget != nil },
                set: { if !$0 { renameTarget = nil } }),
            presenting: renameTarget
        ) { tag in
            TextField("Name", text: $nameField)
            Button("Rename") {
                let name = nameField
                let model = model
                Task { await model.rename(tag.id, to: name) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { tag in
            Text("Renaming “\(tag.name)” renames everything nested under it too.")
        }
        .alert(
            "Delete Tag?",
            isPresented: Binding(
                get: { deleteTarget != nil },
                set: { if !$0 { deleteTarget = nil } }),
            presenting: deleteTarget
        ) { tag in
            Button("Delete", role: .destructive) {
                let model = model
                Task { await model.delete(tag.id) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { tag in
            // The consequence, named (the C3 brief's letter) — never a
            // platform.
            Text(MobileTagsModel.deleteConsequence(
                name: tag.name,
                subtreeCount: MobileTagsModel.subtreeCount(of: tag, in: model.tags)))
        }
    }

    /// One tag's row: indented by depth (the tree reads as the
    /// hierarchy), the leaf name leading, the full path faint beside it
    /// on nested rows (hierarchy stays surfaced — R45). Long-press holds
    /// the acts (the phone's context grammar — the pin door's own).
    private func tagRow(_ tag: Tag) -> some View {
        let depth = MobileTagsModel.depth(of: tag)
        return HStack(spacing: 8) {
            Text("#\(tag.name)")
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
                .padding(.leading, CGFloat(depth) * 18)
            if depth > 0 {
                Text(tag.path)
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.vertical, 9)
        .contentShape(Rectangle())
        .contextMenu {
            Button(tokens.chromeLabel("New Child Tag…")) {
                nameField = ""
                createParent = tag
                createPresented = true
            }
            Button(tokens.chromeLabel("Rename…")) {
                nameField = tag.name
                renameTarget = tag
            }
            Divider()
            Button(tokens.chromeLabel("Delete…"), role: .destructive) {
                deleteTarget = tag
            }
        }
    }

    private var newTagRow: some View {
        Button {
            nameField = ""
            createParent = nil
            createPresented = true
        } label: {
            HStack {
                Text(tokens.chromeLabel("+ new tag"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                Spacer()
            }
            .padding(.vertical, 11)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("New Tag")
    }
}
