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
    /// **VM-60 — the wing `tags` IS, named** (the Mac `TagsViewModel`'s
    /// `shownWing`, R-828-2): read in the SAME read as the list, so the
    /// header ("Tags — in ‹wing›") can never name a wing other than the one
    /// listed, and a rename of that wing re-titles it live.
    private(set) var shownWingName = WingWords.home
    /// VM-61: every value this slot holds is a refusal, so it speaks on the
    /// phone's one line as it is set (nil says nothing); no screen draws it.
    private(set) var lastError: String? {
        didSet { MobileLine.refuse(lastError, session: session) }
    }

    init(session: AppSession) {
        self.session = session
    }

    /// One read's answer: the wing's vocabulary and the wing's name.
    nonisolated struct Listing: Equatable, Sendable {
        let tags: [Tag]
        let wingName: String
    }

    /// The wing's taxonomy and its name, one read (`TagsViewModel.start`'s).
    nonisolated static func listing(_ db: Database, wingID: String) throws -> Listing {
        Listing(
            tags: try Queries.allTags(db, wingID: wingID),
            wingName: try Queries.wingName(db, id: wingID, home: WingWords.home)
                ?? WingWords.home)
    }

    /// The live taxonomy (author-scale metadata — the Mac TagsViewModel's
    /// own unbounded observation; cost ∝ tag count, never corpus).
    ///
    /// VM-60: the CURRENT WING's vocabulary (R-13ia-1 — tags are per wing),
    /// re-read for each wing the phone stands in.
    func start() async {
        await MobileWingScope.follow(session.wing) { [self] wing in
            do {
                for try await value in session.database.observe({ db in
                    try Self.listing(db, wingID: wing)
                }) {
                    adopt(value)
                }
            } catch is CancellationError {
            } catch {
                lastError = OpsRefusalCopy.sentence(for: error, roads: .phone)
            }
        }
    }

    /// One-shot for headless determinism (tests and the sheet's first
    /// paint drive this; the observation echoes it in production).
    func refresh() async {
        do {
            let wing = session.wing.currentID
            adopt(try await session.database.read { try Self.listing($0, wingID: wing) })
        } catch {
            lastError = OpsRefusalCopy.sentence(for: error, roads: .phone)
        }
    }

    private func adopt(_ listing: Listing) {
        tags = listing.tags
        shownWingName = listing.wingName
    }

    /// The header — the Mac's own words (`WingWords.tagsTitle`).
    var title: String {
        WingWords.tagsTitle(wingName: shownWingName)
    }

    // MARK: - Pure brains (pinned)

    /// Indent depth for the tree presentation (path components below
    /// root — the Mac `TagsViewModel.depth`'s exact rule).
    nonisolated static func depth(of tag: Tag) -> Int {
        tag.path.reduce(0) { $0 + ($1 == "/" ? 1 : 0) }
    }

    /// How many live tags sit UNDER this one (the subtree the delete
    /// takes along). **HOISTED at VX-221 — the rule lives in
    /// `Shared/TagDeletionCopy.swift`**, once, for both apps (the Mac's
    /// tag manager confirms with the same words now); this name forwards.
    nonisolated static func subtreeCount(of tag: Tag, in all: [Tag]) -> Int {
        TagDeletion.subtreeCount(of: tag, in: all)
    }

    /// The delete confirm's message — the CONSEQUENCE named, never a
    /// platform (the C3 brief's letter). Hoisted at VX-221 with
    /// `subtreeCount`; this name forwards.
    nonisolated static func deleteConsequence(name: String, subtreeCount: Int) -> String {
        TagDeletion.consequence(name: name, subtreeCount: subtreeCount)
    }

    // MARK: - The typed-path create brain (FIX-C3a — ONE create rule)

    /// The typed-path CREATE walk: the note-tags sheet's typing field and
    /// the manager's "+ new tag" door both resolve a typed "life/goals"
    /// through THESE brains — one rule everywhere, reused and never copied
    /// (the six-copied-brains KnownIssues row is the anti-pattern; a third
    /// copy inside one target would be its worst form).
    ///
    /// **HOISTED 13u4 UNIT C1 — the rule now lives in
    /// `Shared/TypedTagPath.swift`**, once, for both apps. It was born on
    /// the Mac (`TagAssignmentViewModel.applyTypedPath`, 13b 3D's N24) and
    /// MIRRORED here at C3, which is exactly the forked-brains row's drift
    /// class; the Mac phase that touched it hoisted it, per that row's own
    /// rule. **Every pre-move name below is kept as a forwarder** so not one
    /// pin on either platform had to move (the 3C parity pattern — the
    /// zero-test-edit run is the proof the hoist moved an address and not a
    /// behaviour).
    nonisolated static func typedSegments(_ raw: String) -> [String] {
        TypedTagPath.segments(raw)
    }

    /// The empty-type hint — ONE sentence for both typing surfaces, and
    /// since the hoist, for both apps.
    static let emptyTypedPathMessage = TypedTagPath.emptyMessage

    /// A typed path resolved against the live taxonomy.
    typealias TypedPathPlan = TypedTagPath.Plan

    /// The resolution half — pure over a taxonomy read (nil on empty
    /// segments; the caller speaks `emptyTypedPathMessage`).
    nonisolated static func typedPathPlan(
        segments: [String], live: [Tag]
    ) -> TypedPathPlan? {
        TypedTagPath.plan(segments: segments, live: live)
    }

    /// The create half, run INSIDE one serialized runner turn (a racing
    /// duplicate refuses through the op's own guard): creates the plan's
    /// missing segments through the standing ops and returns the LEAF's
    /// id.
    ///
    /// VM-60: `wingID` — the wing a ROOT segment is born in ('' = Home, the
    /// forwarder's old reach); a child is born in its parent's.
    nonisolated static func createMissing(
        _ plan: TypedPathPlan, ops: Operations, wingID: String = ""
    ) throws -> String? {
        try TypedTagPath.createMissing(plan, ops: ops, wingID: wingID)
    }

    /// Refusal copy in phone words (no platform names) — the Mac
    /// `TagsViewModel.message` semantics mirrored.
    nonisolated static func refusal(_ error: Error) -> String {
        guard let op = error as? OperationError else {
            return OpsRefusalCopy.sentence(for: error, roads: .phone)
        }
        switch op {
        case .invalidTagName:
            return "Tag names can't be empty or contain “/”."
        case .duplicateTagPath(let path):
            return "A tag named “\(path)” already exists."
        case .tagNotFound:
            return "That tag no longer exists."
        default:
            // VM-62: the shared table's words, else the one plain fallback.
            return OpsRefusalCopy.sentence(for: op, roads: .phone)
        }
    }

    // MARK: - Acts (every one an existing core operation)

    /// VM-60: a ROOT tag is born in the wing the phone stands in (the Mac's
    /// `TagsViewModel.createTag`); a child in its parent's (the op's rule).
    func create(parentID: String?, name: String) async {
        let wing = parentID == nil ? session.wing.currentID : nil
        await run { ops in _ = try ops.createTag(parent: parentID, name: name, wingID: wing) }
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
            // VM-60: the current wing's vocabulary — a typed path resolves
            // (and mints its missing root) there, never in another library.
            let wing = session.wing.currentID
            let live = try await session.database.read { try Queries.allTags($0, wingID: wing) }
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
                _ = try MobileTagsModel.createMissing(plan, ops: ops, wingID: wing)
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
            // VM-60: the list names its wing — the Mac's Settings ▸ Tags
            // words (R-828-2) — on the shared sheet header (VM-50).
            PhoneSheetHeader(tokens.chromeLabel(model.title), tokens: tokens) { dismiss() }
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(model.tags, id: \.id) { tag in
                        tagRow(tag)
                    }
                    if model.tags.isEmpty {
                        Text(tokens.chromeLabel(Self.emptyStateHint))
                            .phoneType(.meta, tokens)
                            .foregroundStyle(tokens.phone.muted)
                            .padding(.vertical, 20)
                    }
                    newTagRow
                }
            }
            // VM-61: a refusal here speaks on the shell's one line, which
            // draws above this sheet.
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
                .phoneType(.rowTitle, tokens)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
                .padding(.leading, CGFloat(depth) * 18)
            if depth > 0 {
                Text(tag.path)
                    .phoneType(.meta, tokens)
                    .foregroundStyle(tokens.phone.muted)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.vertical, 9)
        .phoneHitArea(alignment: .leading)
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
                    .phoneType(.control, tokens)
                    .foregroundStyle(tokens.accent)
                Spacer()
            }
            .padding(.vertical, 11)
            .phoneHitArea(alignment: .leading)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("New Tag")
    }
}
