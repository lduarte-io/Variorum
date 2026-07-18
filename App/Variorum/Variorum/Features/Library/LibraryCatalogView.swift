//
//  LibraryCatalogView.swift
//  Variorum
//
//  Phase 13, B2 — LIBRARY = EVERYTHING (R32: "all books, posts, and
//  blocks. like literally everything, sortable and searchable") with the
//  timeline folded in as a VIEW MODE (sitting 1/R5) and the tags column as
//  an ADDABLE batch-tagging surface (R46). The old sidebar post pile and
//  its context menu live here now; recovery + tutorial stay reachable from
//  the toolbar (and ⌘K).
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import VariorumCore

@MainActor
@Observable
final class LibraryCatalogModel {
    enum Scope: String, CaseIterable { case all, books, posts, blocks }
    enum Mode: String, CaseIterable { case list, timeline }

    @ObservationIgnored let session: AppSession
    var scope: Scope = .all
    var mode: Mode = .list
    var query = "" {
        didSet { Task { await search() } }
    }
    private(set) var hits: [Queries.CatalogHit] = []
    private(set) var postTags: [String: [String]] = [:]
    private(set) var lastError: String?

    init(session: AppSession) {
        self.session = session
    }

    /// One-shot per typed query / scope change (the core query's contract);
    /// the resting state is books + recent posts.
    func search() async {
        do {
            let query = query
            let all = try await session.database.read { db in
                try Queries.searchCatalog(db, query: query, limitPerKind: 40)
            }
            hits = filtered(all)
            await loadTagChips(for: hits.filter { $0.kind == .post }.map(\.id))
            lastError = nil
        } catch {
            lastError = String(describing: error)
        }
    }

    func filtered(_ all: [Queries.CatalogHit]) -> [Queries.CatalogHit] {
        switch scope {
        case .all: return all
        case .books: return all.filter { $0.kind == .book }
        case .posts: return all.filter { $0.kind == .post }
        case .blocks: return all.filter { $0.kind == .block }
        }
    }

    /// The tags column's chips (bounded to the visible hits).
    private func loadTagChips(for postIDs: [String]) async {
        guard !postIDs.isEmpty else {
            postTags = [:]
            return
        }
        do {
            postTags = try await session.database.read { db in
                var result: [String: [String]] = [:]
                for postID in postIDs {
                    let paths = try String.fetchAll(
                        db,
                        sql: """
                            SELECT t.path FROM post_tag pt
                            JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                            WHERE pt.post_id = ? AND pt.deleted_at IS NULL
                            ORDER BY t.path
                            """,
                        arguments: [postID])
                    if !paths.isEmpty { result[postID] = paths }
                }
                return result
            }
        } catch {
            lastError = String(describing: error)
        }
    }

    /// R46: the addable tags surface — apply one tag to MANY posts inline.
    func applyTag(_ tagID: String, to postIDs: [String]) async {
        do {
            try await session.runner.run { ops in
                for postID in postIDs {
                    do {
                        try ops.applyTag(tagID, toPost: postID)
                    } catch OperationError.alreadyTagged {
                        // Batch semantics: already-tagged is a no-op.
                    }
                }
            }
            await search()
        } catch {
            lastError = TagsViewModel.message(error)
        }
    }
}

struct LibraryCatalogView: View {
    let session: AppSession
    let model: LibraryCatalogModel
    let library: LibraryViewModel
    let tags: TagsViewModel
    let onOpen: (SidebarSelection) -> Void

    @Environment(ThemeStore.self) private var theme
    @Environment(\.colorScheme) private var scheme
    @State private var selectedPosts: Set<String> = []
    @State private var tagSheetTarget: SidebarView.TagSheetTarget?
    @State private var renameTarget: String?
    @State private var renameTitle = ""

    private var tokens: VoiceTokens { theme.tokens(for: scheme) }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().overlay(tokens.line)
            switch model.mode {
            case .list: listBody
            case .timeline:
                TimelineView(session: session) { postID in
                    onOpen(.post(postID))
                }
            }
        }
        .background(tokens.surface)
        .task { await model.search() }
        .sheet(item: $tagSheetTarget) { target in
            TagAssignmentSheet(session: session, postID: target.id, postTitle: target.title)
        }
        .alert(
            "Rename Post",
            isPresented: Binding(
                get: { renameTarget != nil },
                set: { if !$0 { renameTarget = nil } }),
            presenting: renameTarget
        ) { postID in
            TextField("Title", text: $renameTitle)
            Button("Rename") {
                let title = renameTitle
                Task {
                    await library.rename(postID: postID, title: title)
                    await model.search()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .overlay(alignment: .bottomLeading) {
            if let error = model.lastError ?? library.lastError {
                Text(error)
                    .font(tokens.small)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
                    .padding(6)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(tokens.path(["Library"]))
                    .font(tokens.heading)
                    .foregroundStyle(tokens.accent)
                Text(tokens.chromeLabel("everything — sortable, searchable"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                Spacer()
                Menu {
                    Button("Archived & Deleted") { onOpen(.recovery) }
                    Button("Modes Tutorial") { onOpen(.tutorial) }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .menuStyle(.borderlessButton)
                .frame(width: 28)
            }
            HStack(spacing: 10) {
                TextField(tokens.chromeLabel("Search books, posts, blocks…"),
                          text: Binding(get: { model.query }, set: { model.query = $0 }))
                    .textFieldStyle(.roundedBorder)
                    .font(tokens.small)
                    .frame(maxWidth: 320)
                Picker("", selection: Binding(get: { model.scope }, set: { model.scope = $0; Task { await model.search() } })) {
                    ForEach(LibraryCatalogModel.Scope.allCases, id: \.self) { scope in
                        Text(tokens.chromeLabel(scope.rawValue.capitalized)).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 280)
                Picker("", selection: Binding(get: { model.mode }, set: { model.mode = $0 })) {
                    Text(tokens.chromeLabel("List")).tag(LibraryCatalogModel.Mode.list)
                    Text(tokens.chromeLabel("Timeline")).tag(LibraryCatalogModel.Mode.timeline)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 160)
                if selectedPosts.count > 1 {
                    Menu(tokens.chromeLabel("Tag \(selectedPosts.count) posts")) {
                        ForEach(tags.tags, id: \.id) { tag in
                            Button(tag.path) {
                                let ids = Array(selectedPosts)
                                Task { await model.applyTag(tag.id, to: ids) }
                            }
                        }
                    }
                    .font(tokens.small)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
    }

    private var listBody: some View {
        List(selection: $selectedPosts) {
            let grouped = Dictionary(grouping: model.hits, by: \.kind)
            if let books = grouped[.book], !books.isEmpty {
                Section(tokens.chromeLabel("Books")) {
                    ForEach(books, id: \.id) { hit in
                        HStack {
                            Image(systemName: "book").foregroundStyle(tokens.muted)
                            Text(hit.title).font(tokens.body)
                            if let detail = hit.detail {
                                Text(tokens.chromeLabel(detail))
                                    .font(tokens.small)
                                    .foregroundStyle(tokens.muted)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { onOpen(.reading(hit.id)) }
                    }
                }
            }
            if let posts = grouped[.post], !posts.isEmpty {
                Section(tokens.chromeLabel("Posts")) {
                    ForEach(posts, id: \.id) { hit in
                        postRow(hit)
                            .tag(hit.id)
                    }
                }
            }
            if let blocks = grouped[.block], !blocks.isEmpty {
                Section(tokens.chromeLabel("Blocks")) {
                    ForEach(blocks, id: \.id) { hit in
                        HStack {
                            Image(systemName: "square.on.square").foregroundStyle(tokens.muted)
                            Text(hit.title).font(tokens.small).lineLimit(1)
                            if let home = hit.detail {
                                Text(tokens.chromeLabel("in \(home)"))
                                    .font(tokens.small)
                                    .foregroundStyle(tokens.faint)
                            }
                        }
                    }
                }
            }
            if model.hits.isEmpty {
                Text(tokens.chromeLabel("Nothing matches."))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
            }
        }
        .scrollContentBackground(.hidden)
        .background(tokens.surface)
    }

    private func postRow(_ hit: Queries.CatalogHit) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(hit.title)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
            if let date = hit.detail {
                Text(date).font(tokens.small).foregroundStyle(tokens.muted)
            }
            // The tags column (R46): chips + the addable "+".
            HStack(spacing: 4) {
                ForEach(model.postTags[hit.id] ?? [], id: \.self) { path in
                    Text("#\(path)")
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent.opacity(0.85))
                }
                Menu {
                    ForEach(tags.tags, id: \.id) { tag in
                        Button(tag.path) {
                            Task { await model.applyTag(tag.id, to: [hit.id]) }
                        }
                    }
                    Divider()
                    Button("Tags…") {
                        tagSheetTarget = .init(id: hit.id, title: hit.title)
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
        }
        .contentShape(Rectangle())
        .onTapGesture { onOpen(.post(hit.id)) }
        .draggable(hit.id)
        .contextMenu {
            Button("Open") { onOpen(.post(hit.id)) }
            Button("Rename…") {
                renameTitle = hit.title == "Untitled" ? "" : hit.title
                renameTarget = hit.id
            }
            Button("Tags…") {
                tagSheetTarget = .init(id: hit.id, title: hit.title)
            }
            Button("Duplicate as Version") {
                Task { await library.duplicateAsVersion(postID: hit.id) }
            }
            Divider()
            Button("Archive") {
                Task {
                    await library.archive(postID: hit.id)
                    await model.search()
                }
            }
            Button("Delete", role: .destructive) {
                Task {
                    await library.delete(postID: hit.id)
                    await model.search()
                }
            }
        }
    }
}
