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
//  caret so the hybrid primitive lands it), and — Phase 13 C3 (R40) —
//  CANVAS (spatial block arrangement as a VIEW on the post, the minimal
//  takes switcher only; the sidebar door is gone by ruling).
//  Mode is session UI state; every mode reads the same store.
//

import SwiftUI
import VariorumCore

struct PostDetailView: View {
    let session: AppSession
    let postID: String
    /// Stage C: a caret-precise landing (palette/Library block hits) —
    /// the Write editor opens with its caret seeded at this block.
    var initialBlockID: String? = nil

    enum Mode: String, CaseIterable {
        case write = "Write"
        case takes = "Takes"
        case compare = "Compare"
        case outline = "Outline"
        case blocks = "Blocks"
        case canvas = "Canvas"
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
                .frame(maxWidth: 500)
                // Phase 13 (B3, R35): the membership indicator — "this
                // post also appears in N books" + the divergence door.
                MembershipChip(session: session, postID: postID)
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
            case .canvas:
                // C3 (R40): canvas as a view ON the post — canvasProjection
                // works over ANY container (a post is a container).
                CanvasView(session: session, containerID: postID)
                    .id("canvas-\(postID)")
            }
        }
        .inspector(isPresented: $referencesShown) {
            ReferencePanel(session: session, postID: postID)
                .inspectorColumnWidth(min: 240, ideal: 340)
        }
        .onAppear {
            if let initialBlockID { jump(to: initialBlockID) }
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
