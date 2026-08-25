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
    /// 13g batch 6 (R5-12), her ruling: *"i also think there should be a
    /// small 'modes' thing in the upper right of a new window, so you can
    /// still switch to write / takes / etc."* The main window's mode row
    /// lives in the SIDEBAR (batch 14's ruling), and a note-only window has
    /// no sidebar — so exactly the windows that lack the rail carry this,
    /// and no window carries the modes twice.
    var showsModeSwitcher = false

    /// The mode vocabulary moved to the Registry layer (13b 1b — the
    /// capability table declares per-mode availability); the alias keeps
    /// every call site and pin naming unchanged.
    typealias Mode = PostMode

    /// **The masthead's inspector cluster, as a table** (the post-13l polish
    /// round, ledger row 9). Her ruling put the tray *"next to the scraps and
    /// reference icon"*, so the three are one row and the row is one value.
    struct InspectorDoor: Hashable {
        let panel: InspectorPanel
        let title: String
        let symbol: String
        let help: String
    }

    static let inspectorDoors: [InspectorDoor] = [
        InspectorDoor(
            panel: .tray(revealBlockID: nil), title: TrayPath.menuLabel,
            symbol: "tray",
            help: "What this note has set aside: blocks it archived, "
                + "everything of its own that is on the \(TrashWindow.days)-day "
                + "clock, and the originals a divide or a merge kept whole"),
        InspectorDoor(
            panel: .scraps, title: "Scraps", symbol: "square.on.square.dashed",
            help: "Show the scraps beside the draft — drag one into the page "
                + "(⌥ carries its whole fan)"),
        InspectorDoor(
            panel: .references, title: "References", symbol: "books.vertical",
            help: "Show the note's references (sources beside the draft)"),
    ]

    /// The `.surface` act this view renders (P-1's declared ⇔ rendered walk).
    /// `.showNoteTray`'s NAMED door is the masthead icon since her C1 ruling —
    /// the `note ▾` menu item moved with the panel, and the context bar's ⌫
    /// badge is the second renderer of the same act, as it always was.
    static let surfaceCapabilities: [CapabilityID] = [.showNoteTray]

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
    /// (Phase 11b B3 — per-post sources beside the draft), the SCRAPS panel
    /// (13b Stage 3, 3D — N19: the drag-into-draft geometry), or — the
    /// post-13l polish round, ledger row 9 — **THIS NOTE'S TRAY**.
    ///
    /// Her C1 ruling, verbatim: *"the note tray should move to being an icon
    /// next to the scraps and reference icon and open in the side bar, with
    /// preserved originals separated from deleted… if it opened in a pane to
    /// the right, it would have the space to let you scroll through them at a
    /// more reasonable size and would keep the top bar from being crowded."*
    ///
    /// `revealBlockID` rides the case because the lineage door's landing
    /// marks a row (`TrayRequest.revealBlockID`), and a panel identity that
    /// forgot it would land the door somewhere true and say nothing about
    /// which row it meant.
    /// **…and — the post-13l polish round, ledger row 17 — THE BLOCK HISTORY
    /// PANE.** Her second-sitting ruling put its door in the bottom chrome
    /// beside Commit; what it opens is the fourth occupant of this column,
    /// because a block's whole time is exactly the kind of thing her C1 note
    /// said the side panel exists for — room to read a list at a reasonable
    /// size without crowding the page.
    ///
    /// The request rides the case (like the tray's reveal) because the pane is
    /// scoped to the block she is standing in and sections every take with the
    /// one she is IN expanded — a panel identity that forgot either fact would
    /// have to guess.
    /// **…and — the post-13l polish round, ledger rows 16/23 — NOTE ▸
    /// VERSIONS**, the round's headline. It carries no payload: the listing is
    /// the note's, and this view already knows which note it is showing.
    enum InspectorPanel: Hashable {
        case references
        case scraps
        case tray(revealBlockID: String?)
        case blockHistory(BlockHistoryRequest)
        case versions

        var isTray: Bool {
            if case .tray = self { return true }
            return false
        }

        var isBlockHistory: Bool {
            if case .blockHistory = self { return true }
            return false
        }
    }
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
                if showsModeSwitcher {
                    // The same vocabulary the sidebar rail renders, in the
                    // one chrome control that fits a masthead corner. It
                    // writes the detail's OWN mode state — the same binding
                    // `CommandRouter.requestMode` writes through, so ⌘1–⌘6
                    // and this door can never disagree.
                    VoicedMenu(tokens: tokens, label: mode.rawValue, role: .quiet) {
                        ForEach(Mode.allCases, id: \.self) { m in
                            Button(m.rawValue) { mode = m }
                        }
                    }
                    .help("This note's mode — Write · Takes · Lenses · Compare · "
                        + "Blocks · Canvas (⌘1–⌘6)")
                }
                // The masthead's inspector cluster, rendered FROM its door
                // table (the `LibraryCatalogView.mastheadDoors` precedent —
                // the table is the render source, not a comment beside one),
                // so "the tray icon sits with scraps and references" is a
                // claim a pin can hold.
                ForEach(Self.inspectorDoors, id: \.panel) { door in
                    Button(door.title, systemImage: door.symbol) {
                        toggle(door.panel)
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .help(door.help)
                }
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
            case .blockHistory(let request):
                // Row 17's pane, in the room her C1 ruling opened. It gets
                // the tray's own width: both are lists of things with dates
                // and verbs beside them, and the walk's P-1 squeeze was
                // exactly what happens when such a list is given less.
                BlockHistoryPane(
                    session: session, request: request,
                    onClose: { inspectorPanel = nil },
                    // The came-from region's second door swaps the COLUMN's
                    // occupant rather than stacking a sheet over a sheet —
                    // which is how the peek's nested tray dissolves (the
                    // architect's adjudication 3) instead of moving house.
                    onOpenTray: { blockID in
                        inspectorPanel = .tray(revealBlockID: blockID)
                    },
                    // Ledger row 33: the jump re-points THIS column's
                    // occupant — the same case, a new request — so the
                    // `.id` below rebuilds the pane on the block she is in
                    // without her closing and reopening anything.
                    onJump: { request in
                        inspectorPanel = .blockHistory(request)
                    })
                    .id("history-\(request.id)")
                    .inspectorColumnWidth(min: 280, ideal: 420)
            case .versions:
                // Rows 16/23: the same room the tray and the history pane got,
                // for the same reason — a list of things with dates and verbs
                // beside them needs the width or the preview loses (the walk's
                // P-1 squeeze, one surface over).
                NoteVersionsPane(
                    session: session, postID: postID,
                    onClose: { inspectorPanel = nil })
                    .id("versions-\(postID)")
                    .inspectorColumnWidth(min: 280, ideal: 420)
            case .tray(let revealBlockID):
                // Her C1 ruling's whole point is the ROOM: the tray was a
                // sheet whose rows squeezed their previews to ten characters
                // (the walk's P-1). It gets the widest ideal of the three
                // panels, and the panel closes through the host — an
                // inspector column is not a sheet, so `dismiss` is not the
                // way out of it.
                TrayPanel(
                    session: session, postID: postID,
                    revealBlockID: revealBlockID,
                    onClose: { inspectorPanel = nil })
                    // A reveal identifies its own request, so arriving at a
                    // DIFFERENT row rebuilds the panel with its mark.
                    .id("tray-\(postID)#\(revealBlockID ?? "")")
                    .inspectorColumnWidth(min: 280, ideal: 420)
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
            let panel = $inspectorPanel
            routerToken = session.commandRouter.registerDetail(
                postID: postID, mode: mode,
                applyMode: { binding.wrappedValue = $0 },
                // Ledger row 9: the badge and any other door onto the tray
                // reach THIS inspector by composition — the same seam the
                // mode router uses, never a broadcast (P-4).
                showTray: { request in
                    panel.wrappedValue = .tray(revealBlockID: request.revealBlockID)
                },
                // Ledger row 17: the same seam for the History pane — the
                // bars' door and ⌘K reach THIS inspector by composition.
                showBlockHistory: { request in
                    panel.wrappedValue = .blockHistory(request)
                },
                // Ledger rows 16/23: the same seam again for the Versions
                // listing — the bars' door and ⌘K reach THIS inspector by
                // composition, never a broadcast (P-4).
                showVersions: {
                    panel.wrappedValue = .versions
                })
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

    /// One icon, one panel: pressing the door that is already open puts it
    /// away (the shipped scraps/references idiom, now shared by three).
    /// A tray door pressed while the tray shows a REVEAL closes it too — the
    /// panel identity is the case, and the icon's case carries no reveal.
    private func toggle(_ panel: InspectorPanel) {
        if panel.isTray {
            inspectorPanel = inspectorPanel?.isTray == true ? nil : panel
            return
        }
        inspectorPanel = inspectorPanel == panel ? nil : panel
    }

    /// R67 — the post's identity, always visible and renameable in place.
    ///
    /// 13g batch 6 (R5-7), her ruling verbatim: *"i also think that if you
    /// click on 'Untitled' it lets you edit the text field there and then
    /// rather than bringing up a smaller little window to edit."* The
    /// popover is retired FROM THIS DOOR; the title becomes a text field in
    /// its own place, in its own type, at the same measure — so the line
    /// does not jump when it goes editable. Every OTHER rename door (the
    /// sidebar row's, the shelf's) is untouched.
    ///
    /// ⏎ and losing focus both commit (an inline field with a hidden commit
    /// key would lose typing); ⎋ restores the stored name. The write is the
    /// same one operation it always was.
    private struct PostTitleLabel: View {
        let session: AppSession
        let postID: String
        let tokens: VoiceTokens
        /// The STORED title — "" where the note has none. It is what the
        /// rename field edits and what a no-op rename compares against.
        @State private var title: String = ""
        /// 13g batch 7 (R6-3): what the masthead SHOWS — the stored title,
        /// else the note's date, from core's one display brain. Held beside
        /// `title` rather than derived here, because the date it may carry
        /// belongs to the store's row and never to this view. Empty only
        /// while the first read is in flight.
        @State private var displayed: String = DisplayTitle.placeholder
        @State private var editing = false
        @State private var draft = ""
        @FocusState private var fieldFocused: Bool

        /// One measure for both faces — the field must not resize the
        /// masthead when it appears.
        private let measure: CGFloat = 380

        var body: some View {
            Group {
                if editing {
                    TextField(displayed, text: $draft)
                        .textFieldStyle(.plain)
                        .font(tokens.title)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(1)
                        .focused($fieldFocused)
                        .frame(maxWidth: measure, alignment: .leading)
                        .onSubmit { rename() }
                        .onExitCommand { cancel() }
                        .onChange(of: fieldFocused) { _, focused in
                            // Clicking away commits what she typed rather
                            // than dropping it (the standing "nothing typed
                            // is lost" posture, at chrome scale).
                            if !focused, editing { rename() }
                        }
                        .task { fieldFocused = true }
                } else {
                    Text(displayed)
                        .font(tokens.title)
                        .foregroundStyle(title.isEmpty ? tokens.muted : tokens.ink)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: measure, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture { beginEditing() }
                        .help("The note's name — click to rename it right here")
                }
            }
            .task(id: postID) { await refresh() }
        }

        private func beginEditing() {
            // The DRAFT is the stored name, never the shown date: clicking a
            // date and typing must name the note, not rename it after
            // itself (13g batch 7, R6-3). The date rides as the field's
            // prompt so the line still reads as it did.
            draft = title
            editing = true
        }

        private func cancel() {
            editing = false
            draft = title
        }

        private func refresh() async {
            let read = try? await session.database.read { [postID] db in
                (stored: try Queries.containerTitle(db, id: postID),
                 shown: try Queries.noteDisplayTitle(db, id: postID))
            }
            title = read?.stored ?? ""
            // A note that is gone keeps the placeholder rather than going
            // blank — the chrome's own fallback, as everywhere else.
            displayed = read?.shown ?? DisplayTitle.placeholder
        }

        private func rename() {
            guard editing else { return }
            editing = false
            let name = draft.trimmingCharacters(in: .whitespaces)
            guard name != title else { return }
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
