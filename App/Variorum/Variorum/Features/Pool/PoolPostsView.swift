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
            return
        }
        postTags = (try? await session.database.read { db in
            try TagChips.load(db, postIDs: ids)
        }) ?? [:]
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
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            Divider().overlay(tokens.line)
            List {
                ForEach(model.posts, id: \.postID) { item in
                    row(item)
                }
                if model.posts.isEmpty {
                    Text(tokens.chromeLabel("Every note lives in a book. The pool is empty."))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                }
            }
            .scrollContentBackground(.hidden)
        }
        .background(tokens.surface)
        .task { await model.start() }
        .deleteNoteConfirmDialog($pendingDelete) { confirm in
            NoteDeletion.fire(session: session, postIDs: confirm.postIDs)
        }
        .overlay(alignment: .bottomLeading) {
            if let error = model.lastError {
                Text(error)
                    .font(tokens.small)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
                    .padding(6)
            }
        }
    }

    private func row(_ item: Queries.TimelineItem) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(item.displayTitle)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
            // 13e E8: the note's own chip grammar (colour · leaf · ✕ off ·
            // ＋ types one on), identical to the Library's rows and the
            // context bar's cards.
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
            Spacer()
            Menu(tokens.chromeLabel("Add to Book")) {
                ForEach(readings.readings.filter { $0.kind == .curated }, id: \.id) { reading in
                    Button(reading.name) {
                        Task { await model.addToBook(item.postID, readingID: reading.id) }
                    }
                }
            }
            .font(tokens.small)
            .frame(width: 140)
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
                pendingDelete = NoteDeleteConfirm(postIDs: [item.postID])
            }
        }
    }
}
