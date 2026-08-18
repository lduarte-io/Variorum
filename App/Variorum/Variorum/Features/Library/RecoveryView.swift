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
//  ── 13j J6: THE "UNPLACED BLOCKS" SECTION IS GONE ────────────────────────
//  Her report, verbatim: *"what is that cursed table of lost hopes and
//  dreams? if a user ever gets there (which I'm wondering if they should at
//  all tbh) … why are we even offering to auto add deleted blocks to the
//  snippets pool? it doesn't make that much sense to me."*
//
//  The sitting's round-2 ruling removed the listing outright, and the
//  argument was that its ONE unique case — an original whose successors were
//  all later deleted — is already covered per-note, because a divide-W/merge
//  release stamps `last_container_id` exactly so a released block still
//  knows its home. Everything else is served better where she is standing:
//  the note's own tray (`TrayPanel`, "Preserved originals") and the lineage
//  door on a successor. The spec's own rationale for the global view was a
//  DEVELOPER safety net — `Queries.unplacedBlocks` survives as that, a debug
//  query rather than a room in the house.
//
//  The "Place in pool" door went with it, and so did the W10b reveal
//  plumbing that navigated here (`.variorumRevealUnplacedBlock`, RootView's
//  `revealUnplacedBlockID`): the lineage door now opens the note's tray in
//  place, which is where the block it names actually lives.
//
//  What this surface keeps is unchanged and stays that way until batch 6
//  reshapes it into the Trash: Archived · Deleted books · Recently Deleted.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

/// **The ONE place the recovery surface's user-facing path is spelled**
/// (13f W10a/W10b). Her sitting question was a FINDABILITY finding — the
/// ceremony told her a block "stays whole on the original" and never said
/// where the original goes — so copy elsewhere in the app now names this
/// door. Every name here is read by the door that renders it (the Library
/// menu item, the palette row, this view's section header) as well as by
/// the copy that points at it, so the sentence and the label cannot drift
/// apart: rename one and the other follows.
///
/// It is deliberately NOT the word "Recovery": `SidebarSelection.recovery`
/// is the internal case name, and no surface has ever shown it — copy that
/// named it would send her looking for a door that does not exist.
nonisolated enum RecoveryPath {
    /// The Library ⋯ menu's item, and the palette row.
    static let menuLabel = "Archived & Deleted"
    /// The arrow is the shipped copy's own (`\u{2192}`, as the merge
    /// ceremony and the helper already write it) — one voice, not a new one.
    static var surface: String { "Library \u{2192} \(menuLabel)" }
}

@MainActor
@Observable
final class RecoveryViewModel {
    @ObservationIgnored private let session: AppSession

    /// The bounded window (review round 1, MINOR 3); +1 probe so the
    /// truncation markers never false-positive (round 2 NIT).
    nonisolated static let window = 500

    private(set) var archived: [Queries.TimelineItem] = []
    private(set) var deleted: [Queries.TimelineItem] = []
    /// 13b 4F (N37 — S4-28.2, the author's reversal of the pre-13
    /// "readings have no restore door" boundary): deleted BOOKS, one
    /// `restoreReading` away — chapters and memberships revive by the
    /// exact-stamp rule; diverged stories stay dead.
    private(set) var deletedReadings: [Reading] = []
    private(set) var deletedReadingsTruncated = false
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

    func startDeletedReadings() async {
        do {
            for try await value in session.database.observe({ db in
                try Queries.deletedReadings(db, limit: Self.window + 1)
            }) {
                deletedReadingsTruncated = value.count > Self.window
                deletedReadings = deletedReadingsTruncated
                    ? Array(value.prefix(Self.window)) : value
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// The restore door (surface-local, the standing recovery-surface
    /// class): the book comes back whole — chapters, memberships, and
    /// chapter assignments by the exact-stamp rule; it reappears on the
    /// shelf by itself (the shelf observes).
    func restoreReading(_ readingID: String) async {
        do {
            try await session.runner.run { ops in
                try ops.restoreReading(readingID)
            }
            lastError = nil
        } catch let error as OperationError {
            lastError = OpsRefusalCopy.message(for: error)
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

    var body: some View { list }

    private var list: some View {
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
            Section("Deleted books") {
                // 13b 4F (N37 — S4-28.2): deleting a book is recoverable
                // now — the reversal of the pre-13 boundary, her ruling.
                if model.deletedReadings.isEmpty {
                    Text("No deleted books.").foregroundStyle(.secondary)
                }
                ForEach(model.deletedReadings, id: \.id) { reading in
                    HStack(spacing: 6) {
                        Text(reading.name)
                        Text(reading.kind == .smart ? "smart book" : "book")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let deletedAt = reading.deletedAt {
                            Text(deletedAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        Spacer()
                        Button("Restore") {
                            Task { await model.restoreReading(reading.id) }
                        }
                        .help("The book comes back whole — chapters and membership included; "
                            + "notes deleted separately stay in Recently Deleted below")
                    }
                }
                if model.deletedReadingsTruncated {
                    Text("Showing the \(RecoveryViewModel.window) most recently deleted books — older ones aren't listed.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
        .task { await model.startDeletedReadings() }
    }

    private func title(_ item: Queries.TimelineItem) -> some View {
        HStack(spacing: 6) {
            Text(item.displayTitle)
            if let date = item.entryDate {
                Text(date).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}
