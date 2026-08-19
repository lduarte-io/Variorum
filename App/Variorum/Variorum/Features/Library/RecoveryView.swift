//
//  RecoveryView.swift
//  Variorum
//
//  The recovery surfaces (Phase 10 Step 8 — brief item 4): archived posts
//  (kept-out-of-view, one click back — the face the Phase 4 closeout
//  promised `unarchiveContainer`) and deleted posts (tombstones, one
//  `restoreContainer` away — the 2026-07-05 author decision's read side).
//
//  ── 13j J6: THE "UNPLACED BLOCKS" SECTION IS GONE ────────────────────────
//  Her report, verbatim: *"what is that cursed table of lost hopes and
//  dreams? if a user ever gets there (which I'm wondering if they should at
//  all tbh) … why are we even offering to auto add deleted blocks to the
//  snippets pool? it doesn't make that much sense to me."*
//
//  The sitting's round-2 ruling removed the listing outright. Released
//  originals surface where she is standing instead: the note's own tray
//  (`TrayPanel`, "Preserved originals") and the lineage door on a successor.
//  `Queries.unplacedBlocks` survives as a debug query, not a room.
//
//  ── 13j J1: AND NOW THE TRASH ────────────────────────────────────────────
//  Her words (2026-08-01): *"some kind of 'true delete' should be added for
//  posts (going to a Trash for 30 days before really deleting), because I
//  already have posts in my library i don't want to have."* The sitting's
//  round-3 rulings shaped it:
//
//  · **Everything deleted rides ONE uniform story** — notes, blocks, takes
//    and books in ONE listing, filterable by kind and sortable by date,
//    because per-row Delete Now is only a real option if she can FIND the
//    row ("maybe you can sort the trash by blocks or note or whatever would
//    be important for that to be a real option").
//  · **Archived stays its own calm section**, with no clock at all: archive
//    is kept-forever, and the two ideas must not blur.
//  · **The window is fixed at 30 days** — no setting; Delete Now is the
//    impatience door.
//
//  **What is deliberately NOT here yet: Delete Now and Empty Trash.** They
//  are ruled, and their backing is a sync-visible purge intent — schema- and
//  server-shaped, and therefore hers to authorize (the purge design memo,
//  `notes/plans/phase-13j-purge-memo.md`). A door that cannot act is not
//  rendered (P-2), so this batch renders none: no greyed buttons promising a
//  thing that does not exist. What the 30-day clock DOES today is honest on
//  its own terms — a deleted thing leaves every surface at the boundary, and
//  the bytes follow when the purge lands.
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
    /// The Library ⋯ menu's item, and the palette row. It names BOTH halves
    /// of the surface, which is what it holds: the calm Archived section and
    /// the Trash's countdown (13j J1 — her ruled name for the deleted half
    /// is `trashSection` below).
    static let menuLabel = "Archived & Deleted"
    /// The arrow is the shipped copy's own (`\u{2192}`, as the merge
    /// ceremony and the helper already write it) — one voice, not a new one.
    static var surface: String { "Library \u{2192} \(menuLabel)" }

    /// **The Trash** (13j J1, her word). One listing over every deleted
    /// thing, on the 30-day clock.
    static let trashSection = "Trash"
    /// The other half: kept forever, no clock, deliberately calm.
    static let archivedSection = "Archived"
    /// The one verb in the Trash, whatever kind the row is.
    static let putBackVerb = "Put back"

    /// How the Trash explains itself in one line — the promise stated where
    /// she can read it, because a countdown with no sentence is a threat.
    static let windowNote =
        "Deleted things wait here for \(TrashWindow.days) days, then they're gone."

    /// The kind filter's words.
    static func kindLabel(_ kind: Queries.TrashItem.Kind) -> String {
        switch kind {
        case .note: return "Notes"
        case .book: return "Books"
        case .block: return "Blocks"
        case .take: return "Takes"
        case .preservedOriginal: return "Originals"
        }
    }

    /// What ONE row calls itself, in the singular.
    static func rowKind(_ kind: Queries.TrashItem.Kind) -> String {
        switch kind {
        case .note: return "note"
        case .book: return "book"
        case .block: return "block"
        case .take: return "take"
        case .preservedOriginal: return "preserved original"
        }
    }

    /// The stranded original's own line (her round-8b ruling — the same
    /// sentence the note's tray shows, from the tray's one home).
    static var goesWithItsFamily: String { TrayPath.goesWithItsFamily }
}

@MainActor
@Observable
final class RecoveryViewModel {
    @ObservationIgnored private let session: AppSession

    /// The bounded window (review round 1, MINOR 3); +1 probe so the
    /// truncation markers never false-positive (round 2 NIT).
    nonisolated static let window = 500

    private(set) var archived: [Queries.TimelineItem] = []
    private(set) var archivedTruncated = false
    /// 13j J1: ONE listing over every deleted thing (notes · blocks · takes ·
    /// books · stranded originals), replacing the separate "Recently Deleted"
    /// and "Deleted books" sections.
    private(set) var trash: [Queries.TrashItem] = []
    private(set) var trashTruncated = false
    private(set) var lastError: String?
    /// A successful Put back's own words (the tray's receipts, from their one
    /// home) — kept apart from `lastError` so a success is never rendered in
    /// the red slot.
    private(set) var receipt: String?

    /// The filter and the sort — her round-3 ruling's two controls. Changing
    /// either restarts the observation, because both are applied IN SQL
    /// (a window applied before a filter would filter the first N of the
    /// wrong set — `observeReading`'s own lesson).
    var kindFilter: Queries.TrashItem.Kind? {
        didSet { if kindFilter != oldValue { restartToken &+= 1 } }
    }
    var oldestFirst = false {
        didSet { if oldestFirst != oldValue { restartToken &+= 1 } }
    }
    /// Bumped whenever the query's shape changes; the view's `.task(id:)`
    /// restarts on it.
    private(set) var restartToken: UInt64 = 0

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

    func startTrash() async {
        let kinds: Set<Queries.TrashItem.Kind> = kindFilter.map { [$0] }
            ?? Set(Queries.TrashItem.Kind.allCases)
        do {
            for try await value in session.database.observeTrash(
                now: session.now, kinds: kinds, oldestFirst: oldestFirst,
                limit: Self.window + 1
            ) {
                trashTruncated = value.count > Self.window
                trash = trashTruncated ? Array(value.prefix(Self.window)) : value
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// Internal so tests drive listings deterministically.
    func adopt(archived: [Queries.TimelineItem], trash: [Queries.TrashItem]) {
        self.archived = archived
        self.trash = trash
    }

    /// **"N days left"** for a row, read against the session's clock.
    func daysLeft(_ item: Queries.TrashItem) -> Int? {
        TrashWindow.daysLeft(item.deletedAt, now: session.now)
    }

    /// **Put back — one verb, each kind's own road** (13j J1). Every road
    /// already existed; what was missing was a place to stand where all four
    /// are offered together.
    func putBack(_ item: Queries.TrashItem) async {
        lastError = nil
        receipt = nil
        do {
            // A preserved original was never deleted — putting it back means
            // PLACING it, which is the tray's own composition (it re-reads
            // its landing at act time, because a listing is a projection).
            if item.kind == .preservedOriginal {
                guard let noteID = item.noteID else {
                    lastError = TrayPath.putBackUnplaced
                    return
                }
                receipt = try await PreservedOriginPutBack.run(
                    session: session, postID: noteID, blockID: item.id)
                return
            }
            try await session.runner.run { ops in
                switch item.kind {
                case .note: try ops.restoreContainer(item.id)
                case .book: try ops.restoreReading(item.id)
                case .block: _ = try ops.restoreBlock(item.id)
                case .take: _ = try ops.restoreVariant(item.id)
                case .preservedOriginal: break  // handled above
                }
            }
        } catch let error as OperationError {
            lastError = TrayRefusalCopy.message(for: error)
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
            Section(RecoveryPath.archivedSection) {
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
            Section(RecoveryPath.trashSection) {
                Text(RecoveryPath.windowNote)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                controls
                if model.trash.isEmpty {
                    Text("The Trash is empty.").foregroundStyle(.secondary)
                }
                ForEach(model.trash) { item in
                    trashRow(item)
                }
                if model.trashTruncated {
                    Text("Showing the \(RecoveryViewModel.window) most recent — older ones aren't listed.")
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
            } else if let receipt = model.receipt {
                Text(receipt)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textSelection(.enabled)
                    .padding(4)
            }
        }
        .task { await model.startArchived() }
        // Restarts when the filter or the sort changes — both are applied in
        // SQL, so the observation itself is what moves.
        .task(id: model.restartToken) { await model.startTrash() }
    }

    /// Her round-3 ruling's two controls: filter by kind, sort by date.
    private var controls: some View {
        HStack(spacing: 12) {
            Picker("Show", selection: Binding(
                get: { model.kindFilter },
                set: { model.kindFilter = $0 })) {
                Text("Everything").tag(Queries.TrashItem.Kind?.none)
                ForEach(Queries.TrashItem.Kind.allCases, id: \.self) { kind in
                    Text(RecoveryPath.kindLabel(kind)).tag(Queries.TrashItem.Kind?.some(kind))
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: 220)
            Toggle("Oldest first", isOn: Binding(
                get: { model.oldestFirst },
                set: { model.oldestFirst = $0 }))
                .toggleStyle(.checkbox)
            Spacer()
        }
        .font(.caption)
    }

    @ViewBuilder
    private func trashRow(_ item: Queries.TrashItem) -> some View {
        HStack(spacing: 6) {
            Text(item.title ?? TrayRowPreview.line(item.text))
                .lineLimit(1)
            Text(RecoveryPath.rowKind(item.kind))
                .font(.caption)
                .foregroundStyle(.secondary)
            if item.kind == .preservedOriginal {
                Text(RecoveryPath.goesWithItsFamily)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            // "from ‹note›" — the context her round-5 statement asked for,
            // with the honest addition when that note is in the Trash too.
            if let noteTitle = item.noteTitle {
                Text(item.noteIsDeleted
                     ? "from \(noteTitle) (also in the Trash)"
                     : "from \(noteTitle)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
            if let display = TrayRowPreview.stampText(item.deletedAt, verb: "deleted") {
                Text(display)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            if let days = model.daysLeft(item) {
                Text(TrayPath.daysLeftLabel(days))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer()
            // The open-there door, only where the note is live (P-2: a door
            // that cannot act is not rendered).
            if let noteID = item.noteID, !item.noteIsDeleted,
               item.kind != .note, item.kind != .book {
                Button("Open note") { openPost(noteID) }
                    .controlSize(.small)
            }
            Button(RecoveryPath.putBackVerb) {
                Task { await model.putBack(item) }
            }
            .controlSize(.small)
            .help(putBackHelp(item))
        }
    }

    private func putBackHelp(_ item: Queries.TrashItem) -> String {
        switch item.kind {
        case .note: return "The note comes back with its blocks, its tags and its books"
        case .book: return "The book comes back whole — chapters and membership included"
        case .block: return "The block goes back where it was in its note"
        case .take: return "The take comes back in its block, exactly as it was"
        case .preservedOriginal:
            return "Places the original back into its note — it stops counting down"
        }
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
