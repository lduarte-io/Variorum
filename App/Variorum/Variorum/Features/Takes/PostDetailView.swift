//
//  PostDetailView.swift
//  Variorum
//
//  Phase 11, Step A3 — the post detail's mode switcher: WRITE (the ordinary
//  Phase 7 editor), TAKES (the takes/lens board — the multi-variant editing
//  view the author elevated to core identity), COMPARE (13b 4C: "lenses
//  across posts" — editable multi-post columns over the one authority;
//  versions & outline↔draft both live here, and make-outline-post rides
//  its header — the Outline tab retired into it, S4-3), BLOCKS (the
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
    /// 13f W20(c): the window's recently-visited books, most recent first —
    /// the membership chip's chooser floats them inside their group (her
    /// round-10 shaping). Defaults empty: curated-before-smart alone orders
    /// a detail mounted without a workspace (a pin, a future embedding).
    var recentBookIDs: [String] = []

    /// The mode vocabulary moved to the Registry layer (13b 1b — the
    /// capability table declares per-mode availability); the alias keeps
    /// every call site and pin naming unchanged.
    typealias Mode = PostMode

    /// 13b 4D (S4-20, her reversal on the record): a post opens in WRITE
    /// the first time — supersedes the takes-first half of R72/R79
    /// (Sitting 9); the per-post mode MEMORY stands untouched: thereafter
    /// a post reopens in whatever mode you last used there (per-post,
    /// scroll-position class — local, never synced). 13b 4C: stored
    /// values decode through `PostMode.fromStored`, so a post left in the
    /// retired Outline tab reopens in Compare — no stored value strands.
    static func rememberedMode(postID: String, defaults: UserDefaults = .standard) -> Mode {
        defaults.string(forKey: "postMode.\(postID)").flatMap(Mode.fromStored) ?? .write
    }

    @State private var mode: Mode = .write
    /// 13b 1b: the mode-router registration's lifecycle token (composed
    /// routing — the notification channels are retired).
    @State private var routerToken: UUID?
    /// A TOC jump's landing: the Write editor re-seeds at this caret (the
    /// hybrid primitive fires in the editor — TK2 §3: no folding here).
    @State private var pendingCaret: Int?
    /// The inspector's occupant (session UI state): the reference panel
    /// (Phase 11b B3 — per-post sources beside the draft) or — 13b Stage 3,
    /// 3D (N19) — the SCRAPS panel, the drag-into-draft geometry.
    enum InspectorPanel { case references, scraps }
    @State private var inspectorPanel: InspectorPanel?
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// Batch 14 (her alignment ask, restated from batch 12): the masthead
    /// shares the ARTICLE's measure and left edge — title directly over
    /// the text, like the mockup. 13b 3F (D2/AD-6): the old margin-grid
    /// widening is DELETED with the always-on rail it compensated — the
    /// article's at-rest measure is 680 in every style now (the rail
    /// engages only while a fan is open), so the masthead is a constant
    /// and the duplicate UserDefaults-read width brain dies with it.
    private let mastheadMeasure: CGFloat = 680

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
                    MembershipChip(
                        session: session, postID: postID,
                        recentBookIDs: recentBookIDs)
                }
                Spacer()
                Button("Scraps", systemImage: "square.on.square.dashed") {
                    inspectorPanel = inspectorPanel == .scraps ? nil : .scraps
                }
                .labelStyle(.iconOnly)
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .help("Show the scraps beside the draft — drag one into the page "
                    + "(⌥ carries its whole fan)")
                Button("References", systemImage: "books.vertical") {
                    inspectorPanel = inspectorPanel == .references ? nil : .references
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
                // 13b 4C: "lenses across posts" — the merged Compare
                // (editable panes, one ring across posts, per-post reorder;
                // the retired Outline tab's make-outline-post in its header).
                CompareBoardView(session: session, postID: postID)
                    .id("compare-\(postID)")
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
        .inspector(isPresented: Binding(
            get: { inspectorPanel != nil },
            set: { if !$0 { inspectorPanel = nil } })
        ) {
            switch inspectorPanel {
            case .references:
                ReferencePanel(session: session, postID: postID)
                    .inspectorColumnWidth(min: 240, ideal: 340)
            case .scraps:
                ScrapsPanel(session: session)
                    .inspectorColumnWidth(min: 220, ideal: 300)
            case nil:
                EmptyView()
            }
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
            // Takes/Lenses have nothing to show and no way to start. (Since
            // S4-20 the first-open default is Write anyway; this guard
            // still matters for a REMEMBERED Takes/Lenses mode on a post
            // whose blocks have since gone.)
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
