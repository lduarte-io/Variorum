//
//  PoolPostsView.swift
//  Variorum
//
//  Phase 13, B2 — THE POOL (R29/R44): "an area for posts that do not
//  belong to any book", top-level by her ruling ("when you make a random
//  post, that's where it goes, and it's still easier to find and see").
//  Its PURPOSE is drainage: every row offers Add-to-Book and the addable
//  tags surface (R46) so floating posts move down into books. The listing
//  is a QUERY over membership — nothing maintains a pool state.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class PoolPostsModel {
    @ObservationIgnored let session: AppSession
    private(set) var posts: [Queries.TimelineItem] = []
    /// 13e E8: whole tags, like the Library's — the chips need the id to
    /// take one off (`TagChips` carries the reasoning).
    private(set) var postTags: [String: [Tag]] = [:]
    /// Row 87 (the Act 10 correction round, batch G — R-cor-11(2)): the
    /// listed notes' first words, from the note picker's OWN road
    /// (`Queries.notePickerNotes(ids:)` — one brain, no second rule),
    /// keyed by note. Shown under a TITLELESS card's day (the rule is
    /// `PoolCardFace.preview`); 13u2 item 4 still designs the one-brain
    /// card family later.
    private(set) var snippets: [String: String] = [:]
    private(set) var lastError: String?

    /// Bounded like every held listing (the observeLibrary discipline).
    nonisolated static let window = 200

    init(session: AppSession) {
        self.session = session
    }

    func start() async {
        do {
            for try await value in session.database.observe({ db in
                try Queries.poolPosts(db, limit: Self.window)
            }) {
                posts = value
                await loadTags()
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    private func loadTags() async {
        let ids = posts.map(\.postID)
        guard !ids.isEmpty else {
            postTags = [:]
            snippets = [:]
            return
        }
        let read = try? await session.database.read { db in
            (tags: try TagChips.load(db, postIDs: ids),
             // Row 87: the picker's preview road, for the listed ids — bounded
             // by the Pool's own window, one statement.
             snippets: try Queries.notePickerNotes(db, ids: ids))
        }
        postTags = read?.tags ?? [:]
        snippets = Dictionary(
            uniqueKeysWithValues: (read?.snippets ?? []).compactMap { hit in
                hit.snippet.map { (hit.id, $0) }
            })
    }

    /// The drainage gesture: into a book (the pool row's whole point).
    func addToBook(_ postID: String, readingID: String) async {
        do {
            try await session.runner.run { ops in
                _ = try ops.addPostToReading(postID, to: readingID)
            }
            lastError = nil
        } catch let error as OperationError {
            if case .alreadyInReading = error { return }
            lastError = ReadingsViewModel.message(error)
        } catch {
            lastError = String(describing: error)
        }
    }

    func applyTag(_ tagID: String, to postID: String) async {
        do {
            try await session.runner.run { ops in
                do {
                    try ops.applyTag(tagID, toPost: postID)
                } catch OperationError.alreadyTagged {}
            }
            await loadTags()
        } catch {
            lastError = TagsViewModel.message(error)
        }
    }

    /// 13e E8 — the Library's two doors, on the pool's rows. Same reasoning,
    /// same one implementation: adding rides the shipped type-to-create door
    /// (13b 3D's N24, the context bar's `＋`), removing is the ops call with
    /// batch semantics. The pool listing is the OTHER half of the R46
    /// surface her round-11 ask named, so a different grammar here would be
    /// exactly the second tag mechanism this work exists to avoid.
    func applyTypedPath(_ raw: String, to postID: String) async {
        let door = TagAssignmentViewModel(session: session, postID: postID)
        if await door.applyTypedPath(raw) == nil {
            lastError = door.lastError
        } else {
            lastError = nil
        }
        await loadTags()
    }

    func removeTag(_ tagID: String, from postID: String) async {
        do {
            try await session.runner.run { ops in
                do {
                    try ops.removeTag(tagID, fromPost: postID)
                } catch OperationError.tagNotApplied {}
            }
            await loadTags()
        } catch {
            lastError = TagsViewModel.message(error)
        }
    }
}

struct PoolPostsView: View {
    /// 13e E8: the pool rows' tag doors — the THIRD renderer of the one
    /// `.tagNote` act (the context bar's cards and the Library's rows are
    /// the others), declared so the `.surface` walk covers them.
    static let surfaceCapabilities: [CapabilityID] = [.tagNote]

    let session: AppSession
    let model: PoolPostsModel
    let library: LibraryViewModel
    let readings: ReadingsViewModel
    let tags: TagsViewModel
    let onOpen: (SidebarSelection) -> Void
    /// 13f batch 4 (W1/A25): the split's row door.
    var onOpenBeside: ((String) -> Void)? = nil
    /// 13f batch 5b (W2/A26): the note-only window's row door.
    var onOpenInNewWindow: ((String) -> Void)? = nil
    /// 13f batch 6 (W4): the star door, from the one note-row grammar.
    var starDoor: StarDoor? = nil

    // Optional: test hosts (and future embeddings) may lack the
    // environment — fall back to the leading voice's tokens.
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    /// 13l Act 2 (item 3): the pending delete ask, in the one shared host.
    @State private var pendingDelete: NoteDeleteConfirm?

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// pre-13u Act 10 wave 2b (item 2): which note the Add-to-Book picker
    /// was opened FOR — a value the sheet presents.
    struct BookPickTarget: Identifiable, Equatable {
        let postID: String
        var id: String { postID }
    }

    @State private var bookPickTarget: BookPickTarget?

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(tokens.path(["Pool"]))
                    .font(tokens.heading)
                    .foregroundStyle(tokens.accent)
                Text(tokens.chromeLabel(
                    "\(model.posts.count) notes in no book — most things belong in one"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            Divider().overlay(tokens.line)
            // Item 2 + the W8-2 restyle: the hairline List retires for calm
            // cards — the mockup's card/metadata-chip grammar (her granted
            // latitude: chips on the metadata line, not a tag column; the
            // column judged in place and not missed — the chips ARE doors,
            // which a column of text could not be).
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    ForEach(model.posts, id: \.postID) { item in
                        row(item)
                    }
                    if model.posts.isEmpty {
                        Text(tokens.chromeLabel("Every note lives in a book. The pool is empty."))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .padding(.vertical, 18)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        }
        .background(tokens.surface)
        .task { await model.start() }
        .deleteNoteConfirmDialog($pendingDelete) { confirm in
            NoteDeletion.fire(session: session, postIDs: confirm.postIDs)
        }
        // Item 2's ruled door: the every-row "Add to Book ▾" dropdown
        // retires for the ONE searchable picker (item 14's component); the
        // CAPABILITY is byte-identical — the pick fires the same
        // `model.addToBook`, and the standing gate's refusals still speak.
        .sheet(item: $bookPickTarget) { target in
            NotePickerSheet(
                tokens: tokens,
                title: "Add to Book",
                prompt: "search books",
                emptyState: "No books match.",
                source: .curatedBooks(readings.readings)
            ) { row in
                Task { await model.addToBook(target.postID, readingID: row.id) }
            }
        }
        .overlay(alignment: .bottomLeading) {
            if let error = model.lastError {
                Text(error)
                    .font(tokens.small)
                    .alarmVoice()
                    .textSelection(.enabled)
                    .padding(6)
            }
        }
    }

    private func row(_ item: Queries.TimelineItem) -> some View {
        CalmCard(tokens: tokens) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(item.displayTitle)
                            .font(tokens.body)
                            .foregroundStyle(tokens.ink)
                            .lineLimit(1)
                        // The quiet day — suppressed when the title already
                        // IS the day (the picker's one detail rule).
                        if let day = NotePickerRanking.detail(
                            title: item.displayTitle,
                            day: DisplayTitle.day(fromStamp: item.stamp))
                        {
                            Text(tokens.chromeLabel(day))
                                .font(tokens.small)
                                .foregroundStyle(tokens.faint)
                                .lineLimit(1)
                        }
                    }
                    // Row 87: a titleless card is a wall of bare dates
                    // without this — its first words, under the day, the
                    // picker's own two-line preview.
                    if let preview = PoolCardFace.preview(
                        title: item.title, snippet: model.snippets[item.postID])
                    {
                        Text(preview)
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    // 13e E8: the note's own chip grammar (colour · leaf ·
                    // ✕ off · ＋ types one on) — the ruled metadata-line
                    // chips, identical to the Library's rows.
                    NoteTagsRow(
                        tokens: tokens,
                        tags: model.postTags[item.postID] ?? [],
                        allTags: tags.tags,
                        onApply: { path in
                            Task { await model.applyTypedPath(path, to: item.postID) }
                        },
                        onRemove: { tag in
                            Task { await model.removeTag(tag.id, from: item.postID) }
                        })
                }
                Spacer(minLength: 8)
                Button(tokens.chromeLabel("add to book")) {
                    bookPickTarget = BookPickTarget(postID: item.postID)
                }
                .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
                .help("Into a book — the pool's whole point. Search opens; finished books say so.")
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { onOpen(.post(item.postID)) }
        .draggable(item.postID)
        .contextMenu {
            Button("Open") { onOpen(.post(item.postID)) }
            if let onOpenBeside {
                Button(WorkspaceNaming.openBesideVerb) { onOpenBeside(item.postID) }
            }
            if let starDoor {
                Button(starDoor.title(for: .post(item.postID))) {
                    starDoor.toggle(.post(item.postID))
                }
            }
            if let onOpenInNewWindow {
                Button(CapabilityRegistry.capability(.openInNewWindow).verb) {
                    onOpenInNewWindow(item.postID)
                }
            }
            Button("Duplicate as Version") {
                Task { await library.duplicateAsVersion(postID: item.postID) }
            }
            Divider()
            // Ledger row 25: the same declaration the Library's row renders
            // (`SidebarView.contextMenuCapabilities`), so both say one word.
            Button(CapabilityRegistry.capability(.archiveNote).verb) {
                Task { await library.archive(postID: item.postID) }
            }
            // 13l Act 2 (item 3): the note-row grammar's delete door, with
            // the confirmation her ruling gave the Library's — this row
            // renders the SAME declaration (`SidebarView.contextMenuCapabilities`)
            // and must therefore ask the same question in the same words.
            Button(RecoveryCopy.deleteNoteTitle, role: .destructive) {
                Task { pendingDelete = await NoteDeletion.ask(
                    session: session, postIDs: [item.postID]) }
            }
        }
    }
}

/// **Row 87's rule, pure (pinned):** a Pool card shows the note's first
/// words ONLY when it has no stored title — a titled card already says what
/// it is (her ruling R-cor-11(2): "a derived line under a titleless card's
/// date"); the words are the note picker's own snippet, never a second
/// derivation.
nonisolated enum PoolCardFace {
    static func preview(title: String?, snippet: String?) -> String? {
        guard title?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true else {
            return nil
        }
        guard let snippet = snippet?.trimmingCharacters(in: .whitespacesAndNewlines),
              !snippet.isEmpty
        else { return nil }
        return snippet
    }
}
