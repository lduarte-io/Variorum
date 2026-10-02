//
//  ArchivedView.swift
//  Variorum
//
//  **ARCHIVE GETS ITS OWN ROOM** (the post-13l polish round, ledger row 8 —
//  her B2 direction, verbatim):
//
//    *"archived should be a different item on the left (like where library
//    is, but it says archived)… separating archive and trash more makes
//    sense - archive is available forever and maybe still valuable even if
//    you don't want it in your current library, and it would be nice to be
//    able to search it separately."*
//
//  Until now Archived was a section stacked above the Trash inside ONE
//  surface called "Archived & Deleted", which put a forever-list and a
//  30-day countdown on the same screen and asked her to hold the difference
//  herself. They are different ideas — the model's own archive/tombstone
//  distinction (OverallModel §6) — and the sidebar now says so.
//
//  ── ARCHIVED **NOTES** ONLY (her Q-answer) ───────────────────────────────
//  Archived BLOCKS stay in their note's tray; archived TAKES stay in the
//  takes strip. Each archived thing lives where its context is — a block
//  alone in a global list is the same "hard without context" problem her D1
//  ruling named for takes. This surface is whole notes she set aside.
//
//  ── AND VERSION HISTORY IS NOT AN ARCHIVED NOTE ──────────────────────────
//  Saved versions of a note are born archived (batch 5 mints them), and
//  their one home is that note's Versions listing — otherwise a note with
//  fifteen saved moments would drown the notes she actually set aside. The
//  classifier is a QUERY, not a column (`Queries.archivedPosts`'s
//  `excludingVersionHistory`), and it is built here BEFORE the versions
//  exist so the surface is right on the day they arrive.
//
//  ── SEARCH ───────────────────────────────────────────────────────────────
//  Her "search it separately" half is a NAME filter over this listing —
//  which is what the Library's catalog search does for live notes today
//  (titles, names, scrap prefixes). BODY-TEXT search is 13o's, on both
//  surfaces at once, and this surface's scope note is written into that
//  phase's inheritance rather than half-built here.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import SwiftUI
import VariorumCore

struct ArchivedView: View {
    let session: AppSession
    let library: LibraryViewModel
    var openPost: (String) -> Void
    @State private var model: RecoveryViewModel
    @State private var query = ""
    /// The Trash road out (N3: Archive → Unarchive → Library, or Delete →
    /// the Trash). One confirm host, the shared wording.
    @State private var pendingDelete: NoteDeleteConfirm?

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    init(
        session: AppSession, library: LibraryViewModel,
        openPost: @escaping (String) -> Void
    ) {
        self.session = session
        self.library = library
        self.openPost = openPost
        _model = State(initialValue: RecoveryViewModel(session: session))
    }

    /// The listing this surface shows, narrowed by the name filter. A pure
    /// read over what is already observed — the filter is hers to type and
    /// the observation never restarts for it (unlike the Trash's kind filter,
    /// which is applied IN SQL because it changes which rows the WINDOW
    /// should hold).
    static func matches(_ items: [Queries.TimelineItem], query: String) -> [Queries.TimelineItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return items }
        return items.filter {
            $0.displayTitle.localizedCaseInsensitiveContains(trimmed)
                || ($0.entryDate ?? "").localizedCaseInsensitiveContains(trimmed)
        }
    }

    private var shown: [Queries.TimelineItem] {
        Self.matches(model.archived, query: query)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().overlay(tokens.line)
            list
        }
        .background(tokens.surface)
        .task(id: session.wing.currentID) { await model.startArchived() }
        .deleteNoteConfirmDialog($pendingDelete) { confirm in
            NoteDeletion.fire(session: session, postIDs: confirm.postIDs)
        }
        .overlay(alignment: .bottom) {
            if let error = model.lastError ?? library.lastError {
                Text(error)
                    .font(tokens.small)
                    .alarmVoice()
                    .textSelection(.enabled)
                    .padding(4)
            } else if let receipt = library.receipt {
                Text(receipt)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .textSelection(.enabled)
                    .padding(4)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(tokens.path([RecoveryPath.archivedSurface]))
                    .font(tokens.heading)
                    .foregroundStyle(tokens.accent)
                Text(tokens.chromeLabel(Self.subtitle))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                Spacer()
            }
            TextField(tokens.chromeLabel(Self.searchPrompt), text: $query)
                .textFieldStyle(.roundedBorder)
                .font(tokens.small)
                .frame(maxWidth: 320)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    /// The room's own promise, said where she can read it — the `windowNote`
    /// shape one surface over, and its exact opposite in content: no clock.
    static let subtitle = "notes you set aside — kept, with no countdown"
    static let searchPrompt = "Search archived notes…"
    static let emptyLine = "Nothing archived."
    static let noMatchesLine = "No archived note matches that."

    /// Act 10 wave 2a (item 4): the hairline-row grammar retires for the
    /// W8-2 calm cards — a `List` still carries the rows (the window is
    /// 500; virtualization stays), the separators go, and each note is one
    /// card with generous doors. Every door survives byte-identical.
    private var list: some View {
        List {
            if model.archived.isEmpty {
                Text(Self.emptyLine).foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
            } else if shown.isEmpty {
                Text(Self.noMatchesLine).foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
            }
            ForEach(shown, id: \.postID) { item in
                row(item)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(
                        top: 3, leading: 12, bottom: 3, trailing: 12))
            }
            if model.archivedTruncated {
                Text("Showing the \(RecoveryViewModel.window) most recently archived — older ones aren't listed.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func row(_ item: Queries.TimelineItem) -> some View {
        CalmCard(tokens: tokens) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(item.displayTitle)
                        .font(tokens.body)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        if let date = item.entryDate {
                            Text(date).font(tokens.small).foregroundStyle(tokens.muted)
                        }
                        if let stamp = TrayRowPreview.stampText(item.stamp, verb: "archived") {
                            Text(stamp).font(tokens.small).foregroundStyle(tokens.faint)
                        }
                    }
                    .lineLimit(1)
                }
                Spacer(minLength: 8)
                Button("Open") { openPost(item.postID) }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
                Button("Unarchive") {
                    Task { await library.unarchive(postID: item.postID) }
                }
                .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary, compact: true))
                .help("Puts it back in the Library")
                // N3's last road: Delete → the Trash, 30 days, one shared
                // wording with every other note-delete door.
                Button(RecoveryCopy.deleteNoteTitle) {
                    Task { pendingDelete = await NoteDeletion.ask(
                        session: session, postIDs: [item.postID]) }
                }
                .buttonStyle(CalmButtonStyle(tokens: tokens, role: .danger, compact: true))
            }
        }
    }
}
