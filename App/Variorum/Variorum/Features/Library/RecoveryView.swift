//
//  RecoveryView.swift
//  Variorum
//
//  The recovery surfaces (Phase 10 Step 8 — brief item 4): archived posts
//  (kept-out-of-view, one click back — the face the Phase 4 closeout
//  promised `unarchiveContainer`) and deleted posts (tombstones, one
//  `restoreContainer` away — the 2026-07-05 author decision's read side).
//  Functional, unstyled.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

/// The unplaced-blocks observation's value (nonisolated — it hops executors).
nonisolated struct UnplacedListing: Equatable, Sendable {
    var blocks: [Queries.UnplacedBlock]
    var pools: [Container]
}

@MainActor
@Observable
final class RecoveryViewModel {
    @ObservationIgnored private let session: AppSession

    /// The bounded window (review round 1, MINOR 3); +1 probe so the
    /// truncation markers never false-positive (round 2 NIT).
    static let window = 500

    private(set) var archived: [Queries.TimelineItem] = []
    private(set) var deleted: [Queries.TimelineItem] = []
    /// Phase 11 (A3 family; §12's low-priority safety net): live blocks
    /// with NO live placement — divide-W/merge lineage leftovers. Listed
    /// plainly; the door back is placeBlock into a pool.
    private(set) var unplaced: [Queries.UnplacedBlock] = []
    private(set) var pools: [Container] = []
    private(set) var archivedTruncated = false
    private(set) var deletedTruncated = false
    private(set) var lastError: String?

    init(session: AppSession) {
        self.session = session
    }

    func startArchived() async {
        do {
            for try await value in session.database.observeArchivedPosts(
                limit: Self.window + 1
            ) {
                archivedTruncated = value.count > Self.window
                archived = archivedTruncated ? Array(value.prefix(Self.window)) : value
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    func startDeleted() async {
        do {
            for try await value in session.database.observeDeletedPosts(
                limit: Self.window + 1
            ) {
                deletedTruncated = value.count > Self.window
                deleted = deletedTruncated ? Array(value.prefix(Self.window)) : value
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// Internal so tests drive listings deterministically.
    func adopt(archived: [Queries.TimelineItem], deleted: [Queries.TimelineItem]) {
        self.archived = archived
        self.deleted = deleted
    }

    func startUnplaced() async {
        do {
            for try await value in session.database.observe({ db in
                UnplacedListing(
                    blocks: try Queries.unplacedBlocks(db),
                    pools: try Queries.pools(db))
            }) {
                unplaced = value.blocks
                pools = value.pools
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// The safety net's one door: re-place the lineage leftover somewhere
    /// visible (`placeBlock` — the W-reversibility primitive's face).
    func place(blockID: String, into containerID: String) async {
        do {
            try await session.runner.run { ops in
                _ = try ops.placeBlock(blockID, in: containerID, at: .end)
            }
            lastError = nil
        } catch {
            lastError = String(describing: error)
        }
    }
}

struct RecoveryView: View {
    let session: AppSession
    let library: LibraryViewModel
    var openPost: (String) -> Void
    @State private var model: RecoveryViewModel

    init(
        session: AppSession, library: LibraryViewModel,
        openPost: @escaping (String) -> Void
    ) {
        self.session = session
        self.library = library
        self.openPost = openPost
        _model = State(initialValue: RecoveryViewModel(session: session))
    }

    var body: some View {
        List {
            Section("Archived") {
                if model.archived.isEmpty {
                    Text("Nothing archived.").foregroundStyle(.secondary)
                }
                ForEach(model.archived, id: \.postID) { item in
                    HStack {
                        title(item)
                        Spacer()
                        Button("Open") { openPost(item.postID) }
                        Button("Unarchive") {
                            Task { await library.unarchive(postID: item.postID) }
                        }
                    }
                }
                if model.archivedTruncated {
                    Text("Showing the \(RecoveryViewModel.window) most recently archived — older ones aren't listed.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Section("Unplaced blocks") {
                // §12's utility view: live blocks no container points at
                // (released to lineage by divide-W/merge, or a restore that
                // lost its home). A cheap query worth having as a safety
                // net (the spec's words) — listed plainly.
                if model.unplaced.isEmpty {
                    Text("No unplaced blocks.").foregroundStyle(.secondary)
                }
                ForEach(model.unplaced, id: \.blockID) { item in
                    HStack {
                        Text((item.text?.isEmpty == false) ? String(item.text!.prefix(80)) : "(empty block)")
                            .lineLimit(1)
                        Spacer()
                        Menu("Place in pool") {
                            ForEach(model.pools, id: \.id) { pool in
                                Button(pool.title ?? "Untitled pool") {
                                    Task { await model.place(blockID: item.blockID, into: pool.id) }
                                }
                            }
                        }
                        .fixedSize()
                    }
                }
            }
            Section("Recently Deleted") {
                if model.deleted.isEmpty {
                    Text("Nothing deleted.").foregroundStyle(.secondary)
                }
                ForEach(model.deleted, id: \.postID) { item in
                    HStack {
                        title(item)
                        Text(item.stamp)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        Spacer()
                        Button("Restore") {
                            Task { await library.restore(postID: item.postID) }
                        }
                    }
                }
                if model.deletedTruncated {
                    Text("Showing the \(RecoveryViewModel.window) most recently deleted — older ones aren't listed.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .overlay(alignment: .bottom) {
            if let error = model.lastError ?? library.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
                    .padding(4)
            }
        }
        .task { await model.startArchived() }
        .task { await model.startDeleted() }
        .task { await model.startUnplaced() }
    }

    private func title(_ item: Queries.TimelineItem) -> some View {
        HStack(spacing: 6) {
            Text(item.title?.isEmpty == false ? item.title! : "Untitled")
            if let date = item.entryDate {
                Text(date).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
