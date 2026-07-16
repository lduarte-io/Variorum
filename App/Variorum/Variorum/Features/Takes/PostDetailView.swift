//
//  PostDetailView.swift
//  Variorum
//
//  Phase 11, Step A3 — the post detail's mode switcher: WRITE (the ordinary
//  Phase 7 editor), TAKES (the takes/lens board — the multi-variant editing
//  view the author elevated to core identity), COMPARE (the two-post
//  aligned composition — versions & outline↔draft; version_of's door 2),
//  OUTLINE (outline-left/draft-right over derivedBlocks — A5), BLOCKS (the
//  collapsible block-TOC — A6; jump-to-block re-seeds the Write editor's
//  caret so the hybrid primitive lands it).
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
        case outline = "Outline"
        case blocks = "Blocks"
    }

    @State private var mode: Mode = .write
    /// A TOC jump's landing: the Write editor re-seeds at this caret (the
    /// hybrid primitive fires in the editor — TK2 §3: no folding here).
    @State private var pendingCaret: Int?
    /// Phase 11b (B3): the reference panel — per-post sources beside the
    /// draft (§7/§12; a viewing aid, session UI state).
    @State private var referencesShown = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Picker("Mode", selection: $mode) {
                    ForEach(Mode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(maxWidth: 420)
                Button("References", systemImage: "books.vertical") {
                    referencesShown.toggle()
                }
                .labelStyle(.iconOnly)
                .help("Show the post's references (sources beside the draft)")
            }
            .padding(6)
            Divider()
            switch mode {
            case .write:
                EditorView(session: session, postID: postID, caretSeed: pendingCaret)
                    .id("\(postID)-caret-\(pendingCaret ?? -1)")
            case .takes:
                TakesBoardView(session: session, postID: postID)
                    .id("takes-\(postID)")
            case .compare:
                AlignedPostsView(session: session, anchorPostID: postID)
                    .id("compare-\(postID)")
            case .outline:
                OutlineDraftView(session: session, draftPostID: postID)
                    .id("outline-\(postID)")
            case .blocks:
                BlockTOCView(session: session, postID: postID, onJump: { blockID in
                    jump(to: blockID)
                })
                .id("toc-\(postID)")
            }
        }
        .inspector(isPresented: $referencesShown) {
            ReferencePanel(session: session, postID: postID)
                .inspectorColumnWidth(min: 240, ideal: 340)
        }
    }

    private func jump(to blockID: String) {
        Task {
            let offset: Int? = try? await session.database.read { [postID] db in
                let slots = try Queries.renderPost(db, containerID: postID)
                guard let i = slots.firstIndex(where: { $0.blockID == blockID }) else {
                    return nil
                }
                return BlockRangeIndex(slots: slots, tail: nil).range(ofEntryAt: i).location
            }
            pendingCaret = offset ?? 0
            mode = .write
        }
    }
}
