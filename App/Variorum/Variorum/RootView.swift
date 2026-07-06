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
    @State private var library: LibraryViewModel
    @State private var selectedPostID: String?

    init(session: AppSession) {
        self.session = session
        _library = State(initialValue: LibraryViewModel(session: session))
    }

    var body: some View {
        NavigationSplitView {
            LibraryView(model: library, selection: $selectedPostID)
                .navigationSplitViewColumnWidth(min: 180, ideal: 220)
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
