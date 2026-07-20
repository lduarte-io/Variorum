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

import GRDB
import SwiftUI
import VariorumCore

struct PostDetailView: View {
    let session: AppSession
    let postID: String
    /// Stage C: a caret-precise landing (palette/Library block hits) —
    /// the Write editor opens with its caret seeded at this block.
    var initialBlockID: String? = nil

    /// The mode vocabulary moved to the Registry layer (13b 1b — the
    /// capability table declares per-mode availability); the alias keeps
    /// every call site and pin naming unchanged.
    typealias Mode = PostMode

    /// R79 (Sitting 9): a post opens in TAKES the first time; thereafter it
    /// reopens in whatever mode you last used there (per-post memory,
    /// scroll-position class — local, never synced).
    static func rememberedMode(postID: String, defaults: UserDefaults = .standard) -> Mode {
        defaults.string(forKey: "postMode.\(postID)").flatMap(Mode.init(rawValue:)) ?? .takes
    }

    @State private var mode: Mode = .takes
    /// 13b 1b: the mode-router registration's lifecycle token (composed
    /// routing — the notification channels are retired).
    @State private var routerToken: UUID?
    /// A TOC jump's landing: the Write editor re-seeds at this caret (the
    /// hybrid primitive fires in the editor — TK2 §3: no folding here).
    @State private var pendingCaret: Int?
    /// Phase 11b (B3): the reference panel — per-post sources beside the
    /// draft (§7/§12; a viewing aid, session UI state).
    @State private var referencesShown = false
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// Batch 14 (her alignment ask, restated from batch 12): the masthead
    /// shares the ARTICLE's measure and left edge — title directly over
    /// the text, like the mockup. Margin-grid widens the takes article by
    /// its reserved rail; the masthead follows.
    private var mastheadMeasure: CGFloat {
        guard mode == .takes, themeStore?.settings.fanStyle == .marginGrid else { return 680 }
        let stored = UserDefaults.standard.integer(forKey: "takesGridCols")
        let cols = stored == 0 ? 1 : max(1, min(2, stored))
        return 680 + 16 + CGFloat(cols) * 220 + CGFloat(max(cols - 1, 0)) * 6
    }

    var body: some View {
        VStack(spacing: 0) {
            // Batch 9 (R101): the MASTHEAD — the round-2 canon's et/es
            // grammar instead of a toolbar. Title over its path line on
            // the left; the mode tabs as quiet voiced words on the right;
            // the page below is the hero.
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                VStack(alignment: .leading, spacing: 1) {
                    // Sitting 9 (R67): the post's NAME, prominent — click
                    // to rename right here.
                    PostTitleLabel(session: session, postID: postID, tokens: tokens)
                    // Phase 13 (B3, R35): the membership indicator — now
                    // the es path line ("~/orbit") + the add/diverge door.
                    MembershipChip(session: session, postID: postID)
                }
                Spacer()
                Button("References", systemImage: "books.vertical") {
                    referencesShown.toggle()
                }
                .labelStyle(.iconOnly)
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .help("Show the post's references (sources beside the draft)")
            }
            .frame(maxWidth: mastheadMeasure, alignment: .leading)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(tokens.surface)
            Divider().overlay(tokens.line)
            switch mode {
            case .write:
                EditorView(session: session, postID: postID, caretSeed: pendingCaret)
                    .id("\(postID)-caret-\(pendingCaret ?? -1)")
            case .takes:
                TakesBoardView(session: session, postID: postID)
                    .id("takes-\(postID)")
            case .lenses:
                // Sitting 9 (R65/R86): the multi-column editor + lens
                // machinery's one home — columns never share a surface
                // with fan styles again.
                LensesBoardView(session: session, postID: postID)
                    .id("lenses-\(postID)")
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
        // 13b 1b (P-4): the mode shell registers with the CommandRouter —
        // mode truth stays this view's @State; requests reach it by
        // composition and the sidebar rail reads the router's observable
        // mirror (both notification channels are retired; a request with
        // no detail mounted SPEAKS instead of vanishing).
        .onAppear {
            mode = Self.rememberedMode(postID: postID)
            if let initialBlockID { jump(to: initialBlockID) }
            let binding = $mode
            routerToken = session.commandRouter.registerDetail(
                postID: postID, mode: mode
            ) { binding.wrappedValue = $0 }
        }
        .onDisappear {
            if let routerToken {
                session.commandRouter.unregisterDetail(routerToken)
            }
        }
        .task(id: postID) {
            // Sitting 9 batch 6: a BLOCKLESS post opens in WRITE no matter
            // what — blocks are born by typing there (crystallization);
            // Takes/Lenses have nothing to show and no way to start. The
            // Takes-first default (R79) applies once the post has blocks.
            let blocks = (try? await session.database.read { [postID] db in
                try Int.fetchOne(
                    db,
                    sql: """
                        SELECT COUNT(*) FROM container_block
                        WHERE container_id = ? AND deleted_at IS NULL
                        """,
                    arguments: [postID])
            }) ?? 0
            if blocks == 0 { mode = .write }
        }
        .onChange(of: mode) { _, new in
            UserDefaults.standard.set(new.rawValue, forKey: "postMode.\(postID)")
            session.commandRouter.noteMode(new)
        }
    }

    /// R67 — the post's identity, always visible and renameable in place.
    private struct PostTitleLabel: View {
        let session: AppSession
        let postID: String
        let tokens: VoiceTokens
        @State private var title: String = ""
        @State private var editing = false
        @State private var draft = ""

        var body: some View {
            Button {
                draft = title
                editing = true
            } label: {
                Text(title.isEmpty ? "Untitled" : title)
                    .font(tokens.title)
                    .foregroundStyle(title.isEmpty ? tokens.muted : tokens.ink)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 380, alignment: .leading)
            }
            .buttonStyle(.plain)
            .help("The post's name — click to rename")
            .popover(isPresented: $editing, arrowEdge: .bottom) {
                HStack {
                    TextField("Post name", text: $draft)
                        .frame(width: 240)
                        .onSubmit { rename() }
                    Button("Rename") { rename() }
                        .keyboardShortcut(.defaultAction)
                }
                .padding(10)
            }
            .task(id: postID) { await refresh() }
        }

        private func refresh() async {
            title = (try? await session.database.read { [postID] db in
                try String.fetchOne(
                    db, sql: "SELECT title FROM container WHERE id = ?", arguments: [postID])
            }) ?? ""
        }

        private func rename() {
            editing = false
            let name = draft.trimmingCharacters(in: .whitespaces)
            Task {
                try? await session.runner.run { [postID] ops in
                    try ops.renameContainer(postID, title: name.isEmpty ? nil : name)
                }
                await refresh()
            }
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
