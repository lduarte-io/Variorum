//
//  RootView.swift
//  Variorum
//
//  Root chrome: library sidebar + the focused post's editor. Functional and
//  unstyled by design (Phase 13 owns beauty). Views render state and send
//  actions only; the view models own projections and operations.
//

import SwiftUI
import VariorumCore

struct RootView: View {
    let session: AppSession
    /// Session services (Phase 8) — nil for the first frames until the root
    /// `.task` starts them; the footer appears when ready.
    let services: AppServices?
    @State private var library: LibraryViewModel
    @State private var selectedPostID: String?

    init(session: AppSession, services: AppServices? = nil) {
        self.session = session
        self.services = services
        _library = State(initialValue: LibraryViewModel(session: session))
    }

    var body: some View {
        NavigationSplitView {
            LibraryView(model: library, selection: $selectedPostID)
                .navigationSplitViewColumnWidth(min: 180, ideal: 220)
                .safeAreaInset(edge: .bottom) {
                    if let services {
                        SyncStatusRow(sync: services.sync)
                    }
                }
        } detail: {
            if let postID = selectedPostID {
                EditorView(session: session, postID: postID)
                    .id(postID) // a different post is a different editor
            } else {
                Text("Select or create a post")
                    .foregroundStyle(.secondary)
            }
        }
        .task { await library.start() }
    }
}
