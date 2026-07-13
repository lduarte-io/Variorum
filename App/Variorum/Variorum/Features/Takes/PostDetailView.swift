//
//  PostDetailView.swift
//  Variorum
//
//  Phase 11, Step A3 — the post detail's mode switcher: WRITE (the ordinary
//  Phase 7 editor), TAKES (the takes/lens board — the multi-variant editing
//  view the author elevated to core identity), COMPARE (the two-post
//  aligned composition — versions & outline↔draft; version_of's door 2).
//  Mode is session UI state; every mode reads the same store.
//

import SwiftUI
import VariorumCore

struct PostDetailView: View {
    let session: AppSession
    let postID: String

    enum Mode: String, CaseIterable {
        case write = "Write"
        case takes = "Takes"
        case compare = "Compare"
    }

    @State private var mode: Mode = .write

    var body: some View {
        VStack(spacing: 0) {
            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .frame(maxWidth: 320)
            .padding(6)
            Divider()
            switch mode {
            case .write:
                EditorView(session: session, postID: postID)
                    .id(postID)
            case .takes:
                TakesBoardView(session: session, postID: postID)
                    .id("takes-\(postID)")
            case .compare:
                AlignedPostsView(session: session, anchorPostID: postID)
                    .id("compare-\(postID)")
            }
        }
    }
}
