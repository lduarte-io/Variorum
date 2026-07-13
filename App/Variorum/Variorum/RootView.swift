//
//  RootView.swift
//  Variorum
//
//  Root chrome: the sectioned sidebar (journal, library, tags — Phase 10)
//  + the selected traversal in the detail pane. Functional and unstyled by
//  design (Phase 13 owns beauty). Views render state and send actions
//  only; the view models own projections and operations; cross-feature
//  routing lives HERE, in composition.
//

import SwiftUI
import VariorumCore

struct RootView: View {
    let session: AppSession
    /// Session services (Phase 8) — nil for the first frames until the root
    /// `.task` starts them; the footer appears when ready.
    let services: AppServices?
    @State private var library: LibraryViewModel
    @State private var tags: TagsViewModel
    @State private var readings: ReadingsViewModel
    @State private var pool: PoolViewModel
    @State private var selection: SidebarSelection?

    init(session: AppSession, services: AppServices? = nil) {
        self.session = session
        self.services = services
        _library = State(initialValue: LibraryViewModel(session: session))
        _tags = State(initialValue: TagsViewModel(session: session))
        _readings = State(initialValue: ReadingsViewModel(session: session))
        _pool = State(initialValue: PoolViewModel(session: session))
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(
                session: session, model: library, tags: tags,
                readings: readings, pool: pool, selection: $selection)
                .navigationSplitViewColumnWidth(min: 200, ideal: 240)
                .safeAreaInset(edge: .bottom) {
                    if let services {
                        VStack(alignment: .leading, spacing: 0) {
                            SyncStatusRow(services: services)
                            BridgeStatusRow(bridge: services.bridge)
                        }
                    }
                }
        } detail: {
            switch selection {
            case .post(let postID):
                // Phase 11 (A3): the mode switcher — Write / Takes /
                // Compare over one post, one store.
                PostDetailView(session: session, postID: postID)
                    .id(postID) // a different post is a different editor
            case .tag(let tagID):
                FolderView(session: session, tagID: tagID) { postID in
                    // Open-in-editor only (interpretation 2, PROVISIONAL).
                    selection = .post(postID)
                }
                .id(tagID)
            case .reading(let readingID):
                BookView(session: session, readingID: readingID)
                    .id(readingID)
            case .timeline:
                TimelineView(session: session) { postID in
                    selection = .post(postID)
                }
            case .pool(let poolID):
                // A pool is a container: the ordinary editor over it IS the
                // minimal pool's capture surface (structural ops are legal
                // in pools — Phase 3 ratification).
                EditorView(session: session, postID: poolID)
                    .id(poolID)
            case .recovery:
                RecoveryView(session: session, library: library) { postID in
                    selection = .post(postID)
                }
            case nil:
                Text("Select or create a post")
                    .foregroundStyle(.secondary)
            }
        }
        .task { await library.start() }
        .task { await library.startJournal() }
        .task { await tags.start() }
        .task { await readings.start() }
        .task { await pool.start() }
    }
}
