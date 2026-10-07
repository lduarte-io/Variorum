//
//  NoteVersionsPane.swift
//  Variorum (Mac)
//
//  **THE POST-13L POLISH ROUND, BATCH 5 — LEDGER ROWS 16 AND 23: NOTE ▸
//  VERSIONS.** The round's headline, and the answer to the one thing her
//  holistic worry said people would conclude is missing:
//
//  > *"people are going to conclude that the one thing they really want (my
//  > whole note at this point in time) … is way too hard to get, even though
//  > we're actually offering infinitely more ways of saving your ideas."*
//
//  Her floated shape, adopted whole: *"an easy door would be to make a copy of
//  the note, archive it, and then let you look through the archived copies made
//  at points in time."* So this pane is a LISTING and four verbs, over machinery
//  that already existed — the fourth of the five places, made real.
//
//  ── THE FOUR ROW ACTS, AND WHY THEY ARE FOUR ─────────────────────────────
//    · **Read** — the moment, in place, read-tier. A version is a whole note,
//      so the disclosure shows its rendered text with an honest cap rather
//      than pretending a side panel is a document window.
//    · **Restore** — the note BECOMES this moment, keeping its identity (V4).
//      It confirms, because a note-scale content replacement is exactly the
//      SCALE clause of the confirmation-consistency principle — and the ask is
//      where "where it is now is saved first" is readable BEFORE the press.
//    · **Promote** — the moment leaves the past and becomes a note of its own,
//      forever (V1's *"work with it as a new note"* road).
//    · **Delete** — the ordinary move-to-Trash road (FOUND-ITEM 1, ratified),
//      which is why it wears the same ellipsis every deliberate deletion does.
//
//  ── READ-CHEAP TIER ONLY (P3) ────────────────────────────────────────────
//  Everything in here is a `Text`. Nothing in a past-shaped surface is ever a
//  live editor — a version is sealed at birth precisely so that it cannot be.
//
//  ── DON'T FORECLOSE 13w ──────────────────────────────────────────────────
//  `notes/plans/whole-note-history-brief.md` is the AUTOMATED rotation that
//  will later fill this same listing. The rows here render
//  `Queries.NoteVersionItem` whole, and `VersionsPath.rowMeta` is the one place
//  a cadence shows — so an automated moment renders indistinguishably except
//  for its label, which is the brief's constraint.
//

import Foundation
import GRDB  // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class NoteVersionsModel {
    @ObservationIgnored private let session: AppSession
    let postID: String

    private(set) var versions: [Queries.NoteVersionItem] = []
    private(set) var loaded = false

    /// **A receipt is not a refusal** — the tray's split (ledger row 6),
    /// classed where the message is produced, never guessed from its text.
    private(set) var status: TrayViewModel.Status?

    /// **The restore's ask, with what the road would take** (13u3 UNIT E,
    /// item 15(a)): the moment she pressed, and the note's cost READ AT ASK
    /// TIME — so the confirm's numbers are the note's as it stands, never a
    /// listing's memory of it.
    struct PendingRestore: Equatable, Identifiable {
        let item: Queries.NoteVersionItem
        let cost: Queries.RestoreCost
        var id: String { item.postID }
    }

    /// The restore's ask. A VALUE the dialog PRESENTS, never a flag it reads
    /// back (13l Act 2's rule, stated at `NoteDeleteConfirm`).
    var pendingRestore: PendingRestore?
    /// …and the delete's, for the same reason.
    var pendingDelete: Queries.NoteVersionItem?

    /// The window bounds the held observation like every other listing's
    /// (Phase 10's discipline). A note's moments are hers to accumulate, and
    /// the truncation is visible rather than silent.
    static let window = 200
    private(set) var truncated = false

    /// How much of a moment the inline read shows before it says so. A version
    /// is a whole note, and a side panel is not a document window.
    static let readCap = 4000

    init(session: AppSession, postID: String) {
        self.session = session
        self.postID = postID
    }

    func start() async {
        do {
            for try await value in session.database.observeNoteVersions(
                postID, limit: Self.window + 1
            ) {
                adopt(value)
            }
        } catch is CancellationError {
        } catch {
            status = .refusal(DeletionRefusal.fallback(error))
        }
    }

    /// Internal so pins drive the pane deterministically (the `TrayViewModel`
    /// seam, and its reason: a held observation is not a test seam).
    func adopt(_ value: [Queries.NoteVersionItem]) {
        let windowed = TrashListing.windowed(value, window: Self.window)
        versions = windowed.rows
        truncated = windowed.truncated
        loaded = true
    }

    // MARK: - The acts

    func save() async {
        await run { try await VersionActs.save(session: $0, postID: $1) }
    }

    /// **The ask** — one bounded read, then the dialog. The cost is the
    /// NOTE's, so pressing Restore on any row asks the same question of the
    /// store (`VersionActs.restoreCost`).
    func askRestore(_ item: Queries.NoteVersionItem) async {
        pendingRestore = PendingRestore(
            item: item,
            cost: await VersionActs.restoreCost(session: session, postID: postID))
    }

    func restore(_ item: Queries.NoteVersionItem) async {
        pendingRestore = nil
        await run { session, postID in
            try await VersionActs.restore(
                session: session, postID: postID, versionID: item.postID)
        }
    }

    func promote(_ item: Queries.NoteVersionItem) async {
        await run { session, postID in
            try await VersionActs.promote(
                session: session, postID: postID, versionID: item.postID)
        }
    }

    func delete(_ item: Queries.NoteVersionItem) async {
        pendingDelete = nil
        await run { session, _ in
            try await VersionActs.delete(session: session, versionID: item.postID)
        }
    }

    /// The read the inline **Read** disclosure shows — one shot, never held:
    /// a moment does not change, so nothing here needs an observation.
    func text(of item: Queries.NoteVersionItem) async -> String {
        let text = (try? await session.database.read { [id = item.postID] db in
            try Queries.renderedText(db, containerID: id)
        }) ?? nil
        guard let text else { return "" }
        guard text.count > Self.readCap else { return text }
        return String(text.prefix(Self.readCap)) + "\n\n\u{2026}"
    }

    private func run(
        _ body: @escaping (AppSession, String) async throws -> String
    ) async {
        status = nil
        do {
            status = .receipt(try await body(session, postID))
        } catch {
            status = .refusal(VersionActs.words(error, seal: .mac))
        }
    }
}

/// **NOTE ▸ VERSIONS.** One occupant of the post detail's inspector column
/// (the seam batch 3 opened), and the same view the bars present as a sheet
/// where no inspector exists — one component, so the two hosts cannot tell
/// different stories about one note's past.
struct NoteVersionsPane: View {
    /// The registry ids this pane renders INLINE (P-1's `.surface` door; the
    /// walk unions every renderer). The row acts are pointed at directly on
    /// their own rows and are the listing's own vocabulary, not app-scope
    /// capabilities — what IS declared is the two doors that reach the pane.
    static let surfaceCapabilities: [CapabilityID] = []

    let session: AppSession
    /// How this pane closes. In a sheet the environment's `dismiss` answers;
    /// in the inspector the host hands the closing act down (the `TrayPanel`
    /// precedent, same reason).
    var onClose: (() -> Void)?
    @State private var model: NoteVersionsModel
    /// Which moments are open for reading. Session UI state, like every other
    /// expansion in the app.
    @State private var expanded: Set<String> = []
    @State private var texts: [String: String] = [:]
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    init(
        session: AppSession, postID: String, onClose: (() -> Void)? = nil,
        model: NoteVersionsModel? = nil
    ) {
        self.session = session
        self.onClose = onClose
        _model = State(initialValue: model
            ?? NoteVersionsModel(session: session, postID: postID))
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(tokens.chromeLabel(VersionsPath.name))
                    .font(tokens.heading)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                Spacer()
                Button(VersionsPath.saveVerb) { Task { await model.save() } }
                    .controlSize(.small)
                    .help("Saves the whole note as it is right now (\u{2318}\u{21E7}S)")
                Button("Close") { close() }
            }
            Text(tokens.chromeLabel(VersionsPath.explainer))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
            if let status = model.status {
                Text(status.text)
                    .font(tokens.small)
                    .foregroundStyle(status.isRefusal ? tokens.alarm : tokens.muted)
                    .textSelection(.enabled)
                    .lineLimit(3)
            }
            List {
                if model.loaded, model.versions.isEmpty {
                    quiet(VersionsPath.empty)
                }
                ForEach(model.versions) { item in
                    row(item)
                }
                if model.truncated {
                    quiet("Showing the \(NoteVersionsModel.window) most recent moments.")
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .padding(12)
        .frame(minWidth: 300, minHeight: 260)
        .background(tokens.surface)
        .task { await model.start() }
        .alert(
            VersionsPath.restoreConfirmTitle,
            isPresented: Binding(
                get: { model.pendingRestore != nil },
                set: { if !$0 { model.pendingRestore = nil } }),
            presenting: model.pendingRestore
        ) { pending in
            Button(VersionsPath.restoreVerb, role: .destructive) {
                Task { await model.restore(pending.item) }
            }
            Button("Cancel", role: .cancel) { model.pendingRestore = nil }
        } message: { pending in
            Text(VersionsPath.restoreConfirmDetail(pending.cost))
        }
        .confirmationDialog(
            RecoveryCopy.deleteNoteConfirmTitle,
            isPresented: Binding(
                get: { model.pendingDelete != nil },
                set: { if !$0 { model.pendingDelete = nil } }),
            titleVisibility: .visible,
            presenting: model.pendingDelete
        ) { pending in
            Button("Delete", role: .destructive) {
                Task { await model.delete(pending) }
            }
            Button("Cancel", role: .cancel) { model.pendingDelete = nil }
        } message: { _ in
            Text(RecoveryCopy.moveToTrashDetail(.note))
        }
    }

    private func close() {
        if let onClose { onClose() } else { dismiss() }
    }

    @ViewBuilder private func row(_ item: Queries.NoteVersionItem) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(VersionsPath.rowTitle(item))
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
            Text(tokens.chromeLabel(
                VersionsPath.rowMeta(item).joined(separator: " \u{B7} ")))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .lineLimit(1)
            if let preview = item.preview, !preview.isEmpty {
                Text(TrayRowPreview.line(preview))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(2)
            }
            HStack(spacing: 8) {
                Button(readLabel(item)) { toggleRead(item) }
                    .controlSize(.small)
                    .help("Reads this moment here, without changing the note")
                Spacer(minLength: 8)
                Button(VersionsPath.restoreVerb) {
                    Task { await model.askRestore(item) }
                }
                .controlSize(.small)
                .help(VersionsPath.restoreHelp)
                Button(VersionsPath.promoteVerb) { Task { await model.promote(item) } }
                    .controlSize(.small)
                    .help(VersionsPath.promoteHelp)
                Button(VersionsPath.deleteVerb, role: .destructive) {
                    model.pendingDelete = item
                }
                .controlSize(.small)
                .help(VersionsPath.deleteHelp)
            }
            if expanded.contains(item.postID) {
                Text(texts[item.postID] ?? "\u{2026}")
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
            }
        }
        .padding(.vertical, 3)
    }

    private func readLabel(_ item: Queries.NoteVersionItem) -> String {
        expanded.contains(item.postID) ? "Hide" : VersionsPath.openVerb
    }

    private func toggleRead(_ item: Queries.NoteVersionItem) {
        if expanded.contains(item.postID) {
            expanded.remove(item.postID)
            return
        }
        expanded.insert(item.postID)
        guard texts[item.postID] == nil else { return }
        Task { texts[item.postID] = await model.text(of: item) }
    }

    private func quiet(_ line: String) -> some View {
        Text(tokens.chromeLabel(line))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .lineLimit(4)
            .fixedSize(horizontal: false, vertical: true)
    }
}
