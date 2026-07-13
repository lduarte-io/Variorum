//
//  AlignedPostsView.swift
//  Variorum
//
//  Phase 11, Step A3 — the two-post aligned composition (spike record item
//  6): rows keyed by BLOCK-LEVEL lineage (`derived_from` closure), never by
//  order — divides/merges/adds/deletes align via spans and blanks; a
//  cross-version REORDER anchors the opened post's order and MARKS moved
//  kin (honest degradation, never guessing). Cells bloom in-cell in the
//  set fan style; QUIET vs TINTED compares displayed bytes; the stable
//  lineage color marks same-origin. Take-to-take kinship across posts is
//  deliberately NOT tracked (coarse, not forensic).
//
//  This is also `version_of`'s DOOR 2 (brief item 2): opened on two
//  unlinked posts, the view offers "Mark as Versions" — the SAME operation
//  the library door emits. And it is the outline↔draft side-by-side: an
//  outline post beside its draft aligns through the same derived_from
//  closure for free (the spike's round-1 observation).
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

/// The aligned composition's one observed value (top-level so its
/// conformances stay nonisolated — the observation hops executors).
nonisolated struct AlignedProjection: Equatable, Sendable {
    var anchorSlots: [Queries.RenderedBlock] = []
    var otherSlots: [Queries.RenderedBlock] = []
    var kinship: [String: String] = [:]
    var isVersionPeer = false
    var fans: [String: [Variant]] = [:]
    var fanStyle: FanStyle = .stack
    var anchorTitle: String?
    var otherTitle: String?
}

/// The peer picker's observed value.
nonisolated struct AlignedPeerListing: Equatable, Sendable {
    var peers: [String] = []
    var candidates: [Queries.TimelineItem] = []
}

@MainActor
@Observable
final class AlignedPostsViewModel {
    @ObservationIgnored let session: AppSession
    let anchorPostID: String

    init(session: AppSession, anchorPostID: String) {
        self.session = session
        self.anchorPostID = anchorPostID
    }

    private(set) var projection = AlignedProjection()
    /// The peer picker's candidates: version peers first, then the recent
    /// library (bounded — the observeLibrary discipline).
    private(set) var peerCandidates: [Queries.TimelineItem] = []
    private(set) var versionPeerIDs: [String] = []
    var otherPostID: String? {
        didSet { restartObservation() }
    }
    private(set) var statusMessage: String?
    /// In-cell fan blooms — session-only, like the board's.
    private(set) var expandedBlocks: Set<String> = []

    @ObservationIgnored private var observation: Task<Void, Never>?

    func start() async {
        restartObservation()
        do {
            let anchorID = anchorPostID
            for try await value in session.database.observe({ db in
                AlignedPeerListing(
                    peers: try Queries.versionPeerPosts(db, of: anchorID),
                    candidates: try Queries.library(
                        db, sort: .lastTouched, direction: .desc, limit: 100))
            }) {
                versionPeerIDs = value.peers
                peerCandidates = value.candidates.filter { $0.postID != anchorID }
                if otherPostID == nil, let first = value.peers.first {
                    otherPostID = first  // a linked peer is the natural default
                }
            }
        } catch is CancellationError {
        } catch {
            statusMessage = "Aligned observation failed: \(error)"
        }
    }

    private func restartObservation() {
        observation?.cancel()
        guard let otherID = otherPostID else {
            projection = AlignedProjection()
            return
        }
        let anchorID = anchorPostID
        observation = Task { [session] in
            do {
                for try await value in session.database.observe({ db -> AlignedProjection in
                    let anchorSlots = try Queries.renderPost(db, containerID: anchorID)
                    let otherSlots = try Queries.renderPost(db, containerID: otherID)
                    var fans: [String: [Variant]] = [:]
                    for slot in anchorSlots + otherSlots where !slot.isGap {
                        fans[slot.blockID] = try Variant
                            .filter(Column("block_id") == slot.blockID
                                    && Column("deleted_at") == nil
                                    && Column("status") == VariantStatus.active.rawValue)
                            .order(Column("fan_position"), Column("id"))
                            .fetchAll(db)
                    }
                    func title(_ id: String) throws -> String? {
                        try String.fetchOne(
                            db, sql: "SELECT title FROM container WHERE id = ?", arguments: [id])
                    }
                    return AlignedProjection(
                        anchorSlots: anchorSlots,
                        otherSlots: otherSlots,
                        kinship: try Queries.blockKinship(db, anchor: anchorID, other: otherID),
                        isVersionPeer: try Queries.versionPeerPosts(db, of: anchorID)
                            .contains(otherID),
                        fans: fans,
                        fanStyle: try Queries.fanStyle(db),
                        anchorTitle: try title(anchorID),
                        otherTitle: try title(otherID))
                }) {
                    self.projection = value
                }
            } catch is CancellationError {
            } catch {
                self.statusMessage = "Aligned observation failed: \(error)"
            }
        }
    }

    func teardown() {
        observation?.cancel()
    }

    var rows: [AlignmentRow] {
        PostAlignment.rows(
            anchorBlocks: projection.anchorSlots.filter { !$0.isGap }.map(\.blockID),
            otherBlocks: projection.otherSlots.filter { !$0.isGap }.map(\.blockID),
            kinship: projection.kinship)
    }

    func slot(for blockID: String) -> Queries.RenderedBlock? {
        projection.anchorSlots.first { $0.blockID == blockID }
            ?? projection.otherSlots.first { $0.blockID == blockID }
    }

    func toggleExpanded(_ blockID: String) {
        if expandedBlocks.contains(blockID) {
            expandedBlocks.remove(blockID)
        } else {
            expandedBlocks.insert(blockID)
        }
    }

    /// DOOR 2 — the same op the library door emits.
    func markAsVersions() {
        guard let otherID = otherPostID else { return }
        statusMessage = nil
        Task { [runner = session.runner, anchorPostID] in
            do {
                try await runner.run { ops in
                    _ = try ops.markPostsAsVersions(anchorPostID, otherID)
                }
            } catch {
                statusMessage = TakesViewModel.message(for: error)
            }
        }
    }

    func choose(blockID: String, variantID: String) {
        statusMessage = nil
        Task { [runner = session.runner] in
            do {
                try await runner.run { ops in
                    try ops.chooseVariant(blockID, variantID: variantID)
                }
            } catch {
                statusMessage = TakesViewModel.message(for: error)
            }
        }
    }
}

struct AlignedPostsView: View {
    let session: AppSession
    let anchorPostID: String
    @State private var model: AlignedPostsViewModel
    @State private var showingDiff = false

    init(session: AppSession, anchorPostID: String, model: AlignedPostsViewModel? = nil) {
        self.session = session
        self.anchorPostID = anchorPostID
        _model = State(initialValue: model
            ?? AlignedPostsViewModel(session: session, anchorPostID: anchorPostID))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            if let status = model.statusMessage {
                Text(status).font(.caption).foregroundStyle(.red).padding(.horizontal, 12)
            }
            if model.otherPostID == nil {
                Spacer()
                Text("Pick a post to compare against — version peers appear first.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                alignedRows
            }
        }
        .task { await model.start() }
        .onDisappear { model.teardown() }
        .sheet(isPresented: $showingDiff) {
            // The one join brain: the diffed texts are exactly what export
            // and the bridge would emit (joinRenderedTexts semantics).
            DiffView(
                leftTitle: model.projection.anchorTitle ?? "this post",
                rightTitle: model.projection.otherTitle ?? "other post",
                leftText: Queries.joinRenderedTexts(
                    model.projection.anchorSlots.compactMap(\.text).filter { !$0.isEmpty }),
                rightText: Queries.joinRenderedTexts(
                    model.projection.otherSlots.compactMap(\.text).filter { !$0.isEmpty }))
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Text(model.projection.anchorTitle ?? "This post")
                .font(.caption.weight(.semibold))
            Text("⟷").foregroundStyle(.secondary)
            Picker("Compare with", selection: $model.otherPostID) {
                Text("Choose a post…").tag(String?.none)
                if !model.versionPeerIDs.isEmpty {
                    Section("Versions of this post") {
                        ForEach(model.versionPeerIDs, id: \.self) { id in
                            Text(peerTitle(id)).tag(String?.some(id))
                        }
                    }
                }
                Section("Recent posts") {
                    ForEach(model.peerCandidates, id: \.postID) { item in
                        Text(item.title?.isEmpty == false ? item.title! : "Untitled")
                            .tag(String?.some(item.postID))
                    }
                }
            }
            .fixedSize()
            if model.otherPostID != nil, !model.projection.isVersionPeer {
                // DOOR 2: the side-by-side view offers the link on
                // unlinked posts — the same op as the library door.
                Button("Mark as Versions") { model.markAsVersions() }
            }
            if model.projection.isVersionPeer {
                Text("versions").font(.caption).foregroundStyle(.blue)
            }
            if model.otherPostID != nil {
                Button("Diff") { showingDiff = true }
            }
            Spacer()
        }
        .controlSize(.small)
        .padding(8)
    }

    private var alignedRows: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Color.clear.frame(width: 4, height: 1)
                    Text(model.projection.anchorTitle ?? "This post")
                        .font(.caption.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(model.projection.otherTitle ?? "Other post")
                        .font(.caption.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                ForEach(model.rows) { row in
                    alignedRow(row)
                }
            }
            .padding(12)
        }
    }

    @ViewBuilder
    private func alignedRow(_ row: AlignmentRow) -> some View {
        let texts = rowTexts(row)
        let tints = Sameness.tints(texts)
        HStack(alignment: .top, spacing: 8) {
            lineageStripe(row.anchorBlockID ?? row.otherBlockIDs.first ?? "")
            VStack(alignment: .leading, spacing: 4) {
                if let anchorID = row.anchorBlockID {
                    blockCell(anchorID, tinted: tints.first == true)
                } else {
                    blank
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            VStack(alignment: .leading, spacing: 4) {
                if row.otherBlockIDs.isEmpty {
                    blank
                } else {
                    if row.moved {
                        Text("moved (order differs in this version)")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                    ForEach(Array(row.otherBlockIDs.enumerated()), id: \.element) { i, blockID in
                        blockCell(blockID, tinted: tints.dropFirst(1 + i).first == true)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
    }

    private func rowTexts(_ row: AlignmentRow) -> [String?] {
        var texts: [String?] = []
        texts.append(row.anchorBlockID.flatMap { model.slot(for: $0)?.text })
        for other in row.otherBlockIDs {
            texts.append(model.slot(for: other)?.text)
        }
        return texts
    }

    @ViewBuilder
    private func blockCell(_ blockID: String, tinted: Bool) -> some View {
        if let slot = model.slot(for: blockID) {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    if slot.hasFan {
                        Button("⑂\(slot.activeVariantCount)") { model.toggleExpanded(blockID) }
                            .controlSize(.mini)
                    }
                    Spacer()
                }
                Text(slot.text ?? "· · ·")
                    .textSelection(.enabled)
                    .font(Font(EditorDocument.baseFont))
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(6)
                    .background(tinted ? Color.yellow.opacity(0.15) : Color.gray.opacity(0.04))
                if model.expandedBlocks.contains(blockID) {
                    // In-cell fan bloom: the takes, ✓ the explicit door.
                    ForEach(model.projection.fans[blockID] ?? [], id: \.id) { take in
                        HStack(alignment: .top, spacing: 4) {
                            Button("✓") { model.choose(blockID: blockID, variantID: take.id) }
                                .controlSize(.mini)
                                .disabled(take.id == slot.variantID)
                            Text(take.workingText.isEmpty ? "(empty take)" : take.workingText)
                                .font(.callout)
                                .textSelection(.enabled)
                                .foregroundStyle(take.id == slot.variantID ? .primary : .secondary)
                        }
                        .padding(.leading, 12)
                    }
                }
            }
        } else {
            blank
        }
    }

    private var blank: some View {
        Text("—")
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(8)
    }

    private func lineageStripe(_ blockID: String) -> some View {
        let hue = Double(BlockTint.stableHash(blockID) % 360) / 360.0
        return Color(hue: hue, saturation: 0.5, brightness: 0.85)
            .frame(width: 4)
            .clipShape(RoundedRectangle(cornerRadius: 2))
    }

    private func peerTitle(_ id: String) -> String {
        model.peerCandidates.first { $0.postID == id }?.title ?? "Version"
    }
}
