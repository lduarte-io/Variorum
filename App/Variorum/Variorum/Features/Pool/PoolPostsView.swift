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
    private(set) var postTags: [String: [String]] = [:]
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
}

struct PoolPostsView: View {
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
            Text(item.title?.isEmpty == false ? item.title! : (item.entryDate ?? "Untitled"))
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
            HStack(spacing: 4) {
                ForEach(model.postTags[item.postID] ?? [], id: \.self) { path in
                    Text("#\(path)")
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent.opacity(0.85))
                }
                Menu {
                    ForEach(tags.tags, id: \.id) { tag in
                        Button(tag.path) {
                            Task { await model.applyTag(tag.id, to: item.postID) }
                        }
                    }
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 10))
                        .foregroundStyle(tokens.faint)
                }
                .menuStyle(.borderlessButton)
                .frame(width: 22)
            }
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
            Button("Archive") { Task { await library.archive(postID: item.postID) } }
            Button("Delete", role: .destructive) {
                Task { await library.delete(postID: item.postID) }
            }
        }
    }
}
