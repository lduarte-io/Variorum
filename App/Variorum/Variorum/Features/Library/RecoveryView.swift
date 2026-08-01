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
    /// The section within it that lists divide-W/merge leftovers.
    static let unplacedSection = "Unplaced blocks"
    /// The arrow is the shipped copy's own (`\u{2192}`, as the merge
    /// ceremony and the helper already write it) — one voice, not a new one.
    static var surface: String { "Library \u{2192} \(menuLabel)" }
    static var unplacedBlocks: String { "\(surface) \u{2192} \(unplacedSection)" }
}

extension Notification.Name {
    /// 13f W10b: "show me the released original" — a SIGNAL (which block),
    /// never a decision (where it lands). `RootView` composes the navigation,
    /// exactly as it does for `.variorumOpenPost` (P-4).
    static let variorumRevealUnplacedBlock =
        Notification.Name("variorumRevealUnplacedBlock")
}

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
    nonisolated static let window = 500

    private(set) var archived: [Queries.TimelineItem] = []
    private(set) var deleted: [Queries.TimelineItem] = []
    /// Phase 11 (A3 family; §12's low-priority safety net): live blocks
    /// with NO live placement — divide-W/merge lineage leftovers. Listed
    /// plainly; the door back is placeBlock into a pool.
    private(set) var unplaced: [Queries.UnplacedBlock] = []
    private(set) var unplacedTruncated = false
    private(set) var pools: [Container] = []
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

    func startUnplaced() async {
        do {
            // Bounded + the probe row (review round 1, MINOR 3 — the same
            // window+1 discipline as the two sections above it).
            for try await value in session.database.observe({ db in
                UnplacedListing(
                    blocks: try Queries.unplacedBlocks(db, limit: Self.window + 1),
                    pools: try Queries.pools(db))
            }) {
                unplacedTruncated = value.blocks.count > Self.window
                unplaced = unplacedTruncated
                    ? Array(value.blocks.prefix(Self.window)) : value.blocks
                pools = value.pools
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
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
    /// 13f W10b: the block the "Show Original Block" door asked to see —
    /// scrolled to and marked on arrival, then consumed (the
    /// `router.pendingSelection` one-shot pattern).
    var revealBlockID: String?
    var onRevealConsumed: () -> Void = {}
    @State private var model: RecoveryViewModel
    @State private var revealed: String?

    init(
        session: AppSession, library: LibraryViewModel,
        openPost: @escaping (String) -> Void,
        revealBlockID: String? = nil,
        onRevealConsumed: @escaping () -> Void = {}
    ) {
        self.session = session
        self.library = library
        self.openPost = openPost
        self.revealBlockID = revealBlockID
        self.onRevealConsumed = onRevealConsumed
        _model = State(initialValue: RecoveryViewModel(session: session))
    }

    var body: some View {
        ScrollViewReader { proxy in
            list
                // The reveal waits for the row to EXIST: the unplaced
                // observation starts with this view, so a reveal requested
                // during navigation would otherwise scroll to nothing. Keyed
                // on both the request and the listing, so whichever lands
                // second still performs it.
                .onChange(of: revealTrigger, initial: true) { _, _ in
                    guard let revealBlockID,
                          model.unplaced.contains(where: { $0.blockID == revealBlockID })
                    else { return }
                    revealed = revealBlockID
                    withAnimation { proxy.scrollTo(revealBlockID, anchor: .center) }
                    onRevealConsumed()
                }
        }
    }

    /// The request + the listing's identity: either arriving completes the
    /// reveal (pure, so the ordering rule is readable and testable).
    private var revealTrigger: String {
        "\(revealBlockID ?? "-")#\(model.unplaced.count)"
    }

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
            Section(RecoveryPath.unplacedSection) {
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
                    // 13f W10b: the block the lineage door sent her to is
                    // MARKED, so a long list still answers "which one".
                    .listRowBackground(
                        revealed == item.blockID
                            ? Color.accentColor.opacity(0.18) : Color.clear)
                }
                if model.unplacedTruncated {
                    Text("Showing the \(RecoveryViewModel.window) most recently touched unplaced blocks — older ones aren't listed.")
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
        .task { await model.startUnplaced() }
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
