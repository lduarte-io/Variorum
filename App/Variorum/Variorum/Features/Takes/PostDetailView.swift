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
    /// Row 15 (the correction round): whether the masthead's inline tag
    /// field is out — the ＃ and ⌘⇧I (routed here by the command router)
    /// open the same one.
    @State private var tagFieldOpen = false
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
    /// The icon row's measured width — the TITLE row's symmetric inset, so
    /// the centered title never runs under the icons (rows 4/19, row 55).
    @State private var mastheadIconRowWidth: CGFloat = 0
    /// The masthead's own width — the inset's floor reads it.
    @State private var mastheadWidth: CGFloat = 0
    /// The centered title never shrinks below this, whatever shares its row.
    private let mastheadLineFloor: CGFloat = 240
    /// Row 58: the least room between the path chip and the tag cluster on
    /// the masthead's second row.
    static let rowTwoGap: CGFloat = 16

    /// The title row's two insets (row 80 — `MastheadTitleInsets`, the pure
    /// rule): the trailing one ALWAYS keeps the icon row's width clear, the
    /// leading one is what the floor spends when the masthead is narrow.
    private var titleInsets: (leading: CGFloat, trailing: CGFloat) {
        MastheadTitleInsets.insets(
            mastheadWidth: mastheadWidth, iconRowWidth: mastheadIconRowWidth,
            floor: mastheadLineFloor)
    }
    /// The masthead's own coordinate space (the DEBUG oracle reads the
    /// title's midX in it against the masthead's midX).
    nonisolated static let mastheadSpace = "variorum-masthead"

    /// Row 74 (the Act 10 correction round, batch G): the note's side column
    /// — the tray, Block History, Versions, references and scraps — is a
    /// `SideColumn` of OUR OWN (the Library's batch-E precedent, hoisted to
    /// `Core/Views`): our 1-pt divider and the panel at a remembered,
    /// draggable width, both drawn in every window state. The `.inspector`
    /// it replaces drew its divider in a KEY window only, so tabbed out the
    /// boundary between the note and its tray vanished (the orchestrator's
    /// window-id probe, `orchestrator-e/r74-*`).
    static let sideColumnWidthKey = "noteSideColumnWidth"
    /// The column's presence animates from the MUTATION sites (E's burst
    /// lesson): every door that opens or closes the panel uses this.
    static let panelAnimation: Animation = .easeInOut(duration: 0.2)

    var body: some View {
        SideColumn(
            tokens: tokens, shown: inspectorPanel != nil, widthKey: Self.sideColumnWidthKey,
            onDividerFrame: { frame in
                #if DEBUG
                PostDetailOracle.sideColumnDividerFrame = frame
                #endif
            }
        ) {
        VStack(spacing: 0) {
            // Batch 9 (R101): the MASTHEAD — the round-2 canon's et/es
            // grammar instead of a toolbar. The page below is the hero.
            //
            // The Act 10 correction round, batch A (rows 4 + 19 — her words:
            // Read "doesn't have a centered title above the read"; Lenses
            // "the title is once again weirdly aligned"): the title block is
            // CENTERED ON THE MASTHEAD'S FULL WIDTH in every mode. The old
            // HStack let the trailing cluster take its natural width and
            // centered the title in the REMAINDER, so it landed a third of
            // the way across. A ZStack now: the title layer spans the whole
            // masthead and centers, padded on BOTH sides by the cluster's
            // measured width so it can never run under the icons; the
            // cluster trails on its own layer. One layout for all modes.
            // TWO ROWS. The TITLE row is a ZStack: the title centered on
            // the full width, inset on both sides by the width of what
            // shares its line — the icon row, and ONLY the icon row (row
            // 55's lesson: one inset for the whole block let the cards'
            // width squeeze the title to "thr…"; the cards never share the
            // title's line, so they never inset it). The SECOND row is ONE
            // HStack (row 58 — her walk found the centered `~/book` chip
            // drawn UNDER the tag cards and gone under the open field): the
            // path chip LEADS at the masthead's leading edge — the
            // article's left margin, where the mockup's `.where` line sits
            // — a minimum gap follows, and the tag cluster TRAILS as a
            // right-aligned wrapping row inside the width that remains.
            // The two can never intersect: the cluster's region begins
            // where the chip's ends, and the cluster wraps rather than grow
            // past it. The chip's place is the same on every note — never
            // centered on a bare note and shoved left by its third tag.
            VStack(spacing: 2) {
                ZStack(alignment: .top) {
                    // Sitting 9 (R67): the post's NAME, prominent — click
                    // to rename right here.
                    // Row 80 (the correction round, batch G — F's walk at a
                    // ~950-pt window with an inspector open: the title
                    // touched the tray icon): the two insets are ASYMMETRIC
                    // once the masthead is too narrow for the floor AND the
                    // icons. The old symmetric inset was capped by the
                    // 240-pt floor on BOTH sides, so at ~270 pt the trailing
                    // inset shrank to ~15 and the title ran under the icon
                    // row. Now the trailing inset always keeps the icons
                    // clear; the floor spends the LEADING inset instead, and
                    // below floor + icons the title yields to `…` — legal;
                    // a title under the icons is not.
                    PostTitleLabel(session: session, postID: postID, tokens: tokens)
                        .frame(maxWidth: .infinity)
                        .padding(.leading, titleInsets.leading)
                        .padding(.trailing, titleInsets.trailing)
                    HStack(alignment: .top, spacing: 0) {
                        Spacer(minLength: 0)
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            if showsModeSwitcher {
                                // The same vocabulary the sidebar rail renders, in
                                // the one chrome control that fits a masthead
                                // corner. It writes the detail's OWN mode state —
                                // the same binding `CommandRouter.requestMode`
                                // writes through, so ⌘1–⌘7 and this door can never
                                // disagree.
                                VoicedMenu(tokens: tokens, label: mode.rawValue, role: .quiet) {
                                    ForEach(Mode.allCases, id: \.self) { m in
                                        Button(m.rawValue) { mode = m }
                                    }
                                }
                                .help("This note's mode — Write · Takes · Read · "
                                    + "Lenses · Compare · Blocks · Canvas (⌘1–⌘7)")
                            }
                            // The masthead's inspector cluster, rendered FROM its
                            // door table (the `LibraryCatalogView.mastheadDoors`
                            // precedent — the table is the render source, not a
                            // comment beside one), so "the tray icon sits with
                            // scraps and references" is a claim a pin can hold.
                            ForEach(Self.inspectorDoors, id: \.panel) { door in
                                Button(door.title, systemImage: door.symbol) {
                                    toggle(door.panel)
                                }
                                .labelStyle(.iconOnly)
                                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                                .help(door.help)
                            }
                        }
                        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: {
                            mastheadIconRowWidth = $0
                        }
                        .mastheadGeometryProbe(.iconRow, in: Self.mastheadSpace)
                    }
                }
                // Row 80b (her live find): row 2 is WIDTH-AWARE —
                // `MastheadRowTwo` lays the chip and the cluster on ONE
                // line while chip + gap + the cluster's minimum line fit,
                // and on TWO lines (the chip above, ellipsizing at its
                // tail; the cluster below on a full-width line, the door on
                // the cards' line) when they do not. The old HStack let the
                // chip win its width and offered the flow LESS than its
                // minimum, which placed a card over the chip's words and
                // orphaned the ＃ (her screenshot at a ~590-pt detail).
                MastheadRowTwo(gap: Self.rowTwoGap) {
                    // Phase 13 (B3, R35): the membership indicator — the es
                    // path line ("~/orbit") + the add/diverge door. It
                    // leads, at its own width on one line; on two it may
                    // ellipsize rather than push. Row 55's opacity yield is
                    // retired with the collision it hid — the chip stays in
                    // view while a tag goes on.
                    MembershipChip(
                        session: session, postID: postID,
                        recentBookIDs: recentBookIDs)
                        .mastheadGeometryProbe(.pathChip, in: Self.mastheadSpace)
                    // Act 10 item 5 — the note's tag cards on the
                    // masthead's right edge, under the icons, across from
                    // the membership chip (her ruling's letter). Row 58: a
                    // right-aligned wrapping row in the width that remains.
                    MastheadTagCluster(
                        session: session, postID: postID, tokens: tokens,
                        fieldOpen: $tagFieldOpen,
                        geometryProbeSpace: Self.mastheadSpace)
                }
            }
            .frame(maxWidth: mastheadMeasure, alignment: .leading)
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { mastheadWidth = $0 }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(tokens.surface)
            .coordinateSpace(name: Self.mastheadSpace)
            // The inline tag field's suggestion list hangs below the
            // masthead's bottom edge; the masthead draws above the page.
            .zIndex(1)
            #if DEBUG
            .onGeometryChange(for: CGFloat.self) { $0.size.width / 2 } action: {
                MastheadGeometry.contentMidX = $0
            }
            #endif
            Divider().overlay(tokens.line)
            switch mode {
            case .write:
                EditorView(session: session, postID: postID, caretSeed: pendingCaret)
                    .id("\(postID)-caret-\(pendingCaret ?? -1)")
            case .takes:
                TakesBoardView(session: session, postID: postID)
                    .id("takes-\(postID)")
            case .read:
                // The Act 10 correction round (R-cor-5/7): ONE tab named
                // Read hosting the in-place `edit · read` switch — the
                // editable index surface (the retired Index tab's column
                // beside a pane whose clicked block goes live) and the
                // read-only page (continuous or the book's pages); a
                // `read` click flips to `edit` at that block.
                ReadModeView(session: session, postID: postID, onJump: { blockID in
                    jump(to: blockID)
                })
                .id("read-\(postID)")
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
                // Wave 2c (item 16, W8-1): "keep Blocks as the poweruser
                // center" — the workbench (facts, multi-select, the
                // context panel); the TOC's every door survives inside it.
                // Row 27: while an inspector column stands beside this
                // mode (history, the tray, versions…), the workbench's own
                // context panel yields — ONE right region at a time.
                BlocksWorkbenchView(
                    session: session, postID: postID,
                    onJump: { blockID in jump(to: blockID) },
                    inspectorOpen: inspectorPanel != nil)
                .id("blocks-\(postID)")
            case .canvas:
                // C3 (R40): canvas as a view ON the post — canvasProjection
                // works over ANY container (a post is a container).
                CanvasView(session: session, containerID: postID)
                    .id("canvas-\(postID)")
            }
        }
        } panel: {
            // The column's occupant: ONE width rule for every panel (the
            // widest ideal the old inspector gave — the tray's 420 / 280,
            // which every occupant but references and scraps already used;
            // the dragged width is remembered for all of them).
            switch inspectorPanel {
            case .references:
                ReferencePanel(session: session, postID: postID)
            case .scraps:
                ScrapsPanel(session: session)
            case .blockHistory(let request):
                // Row 17's pane, in the room her C1 ruling opened. It gets
                // the tray's own width: both are lists of things with dates
                // and verbs beside them, and the walk's P-1 squeeze was
                // exactly what happens when such a list is given less.
                BlockHistoryPane(
                    session: session, request: request,
                    onClose: { withAnimation(Self.panelAnimation) { inspectorPanel = nil } },
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
            case .versions:
                // Rows 16/23: the same room the tray and the history pane got,
                // for the same reason — a list of things with dates and verbs
                // beside them needs the width or the preview loses (the walk's
                // P-1 squeeze, one surface over).
                NoteVersionsPane(
                    session: session, postID: postID,
                    onClose: { withAnimation(Self.panelAnimation) { inspectorPanel = nil } })
                    .id("versions-\(postID)")
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
                    onClose: { withAnimation(Self.panelAnimation) { inspectorPanel = nil } })
                    // A reveal identifies its own request, so arriving at a
                    // DIFFERENT row rebuilds the panel with its mark.
                    .id("tray-\(postID)#\(revealBlockID ?? "")")
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
            let tagField = $tagFieldOpen
            routerToken = session.commandRouter.registerDetail(
                postID: postID, mode: mode,
                applyMode: { binding.wrappedValue = $0 },
                // Row 15: ⌘⇧I and the ⌘K row reach THIS masthead's tag field
                // by composition — the same seam the tray uses (P-4).
                openTagField: { tagField.wrappedValue = true },
                // Ledger row 9: the badge and any other door onto the tray
                // reach THIS inspector by composition — the same seam the
                // mode router uses, never a broadcast (P-4).
                showTray: { request in
                    withAnimation(Self.panelAnimation) {
                        panel.wrappedValue = .tray(revealBlockID: request.revealBlockID)
                    }
                },
                // Ledger row 17: the same seam for the History pane — the
                // bars' door and ⌘K reach THIS inspector by composition.
                showBlockHistory: { request in
                    withAnimation(Self.panelAnimation) {
                        panel.wrappedValue = .blockHistory(request)
                    }
                },
                // Ledger rows 16/23: the same seam again for the Versions
                // listing — the bars' door and ⌘K reach THIS inspector by
                // composition, never a broadcast (P-4).
                showVersions: {
                    withAnimation(Self.panelAnimation) { panel.wrappedValue = .versions }
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
        .onChange(of: inspectorPanel, initial: true) { _, panel in
            #if DEBUG
            PostDetailOracle.inspectorPanel = panel
            #endif
        }
        .onChange(of: mode) { _, new in
            UserDefaults.standard.set(new.rawValue, forKey: "postMode.\(postID)")
            session.commandRouter.noteMode(new)
            // 17o batch b's ladder, R1-1 (BLOCKER): the caret seed is
            // ONE-SHOT. `jump(to:)` set `pendingCaret` and nothing cleared
            // it, so every later mount of Write in the same note visit
            // re-ran `EditorView.init` → `pendingCaretSeed` on a fresh
            // model, re-landed at the jump's block START, claimed the caret
            // (so the bare arrival never read the memory) and reported
            // offset 0 into it — U-20's complaint one gesture after row
            // 20's own door, and the Act 10 "one current block" rule broken
            // with it. Cleared HERE, on LEAVING Write, and nowhere else:
            // the Write branch is out of the tree at this moment, so the
            // `.id` that carries the seed changes with nothing mounted
            // under it; clearing while IN Write (say, where the seed is
            // consumed) would change that `.id` under a mounted editor and
            // remount it mid-visit, re-running the arrival.
            if new != .write { pendingCaret = nil }
            // Row 29 (her words: "the block history tab stays open as you
            // move to other modes which looks bad and is confusing"): the
            // pane is SCOPED to the mode that asked — a mode switch CLOSES
            // it (chosen over re-targeting: the question was asked about a
            // block in that mode's surface; the next mode asks its own, and
            // its bar's door is one click away). It can therefore never
            // show block 3's history beside a mode where block 1 is live
            // (the walk's captures 45/46).
            if inspectorPanel?.isBlockHistory == true {
                withAnimation(Self.panelAnimation) { inspectorPanel = nil }
            }
        }
    }

    /// One icon, one panel: pressing the door that is already open puts it
    /// away (the shipped scraps/references idiom, now shared by three).
    /// A tray door pressed while the tray shows a REVEAL closes it too — the
    /// panel identity is the case, and the icon's case carries no reveal.
    private func toggle(_ panel: InspectorPanel) {
        // Act 10 item 10's principle — regions visibly become things or
        // visibly leave: the column animates in and out instead of popping.
        withAnimation(Self.panelAnimation) {
            if panel.isTray {
                inspectorPanel = inspectorPanel?.isTray == true ? nil : panel
                return
            }
            inspectorPanel = inspectorPanel == panel ? nil : panel
        }
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
                        .multilineTextAlignment(.center)
                        .focused($fieldFocused)
                        .frame(maxWidth: measure, alignment: .center)
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
                        #if DEBUG
                        // The oracle reads the TEXT's own frame (not its
                        // measure, which centers whatever its content does):
                        // where the words actually sit — its midX for the
                        // centering pins (rows 4/19), the whole frame for
                        // row 80's "never under the icons".
                        .onGeometryChange(for: CGRect.self) {
                            $0.frame(in: .named(PostDetailView.mastheadSpace))
                        } action: {
                            MastheadGeometry.titleMidX = $0.midX
                            MastheadGeometry.titleFrame = $0
                        }
                        #endif
                        // Rows 4/19: the title CENTERS in its measure (it used
                        // to lead), so the block reads centered over the page.
                        .frame(maxWidth: measure, alignment: .center)
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

/// What a masthead geometry probe reports (row 58) — the slot a frame
/// belongs to. Always compiled (the modifier's signature names it); the
/// oracle that stores the frames is DEBUG-only.
enum MastheadProbeSlot: Hashable {
    case pathChip
    case card(String)
    case field
    /// Row 80: the icon row (tray · scraps · references) on the title's line.
    case iconRow
    /// Row 59: the ＃ door — its frame IS its hit target.
    case door
}

/// **Row 80 (the Act 10 correction round, batch G) — the title row's two
/// insets, as a pure rule.** F's walk at a ~950-pt window with an inspector
/// open (the detail's column ~316 pt, the masthead ~270) found the title
/// TOUCHING the tray icon: the title's inset was symmetric and capped by
/// the 240-pt floor on both sides — `min(icons + 12, (width − 240) / 2)` —
/// so at ~270 pt the trailing inset shrank to ~15 while the icon row was
/// ~100 wide, and the words ran under the icons.
///
/// The rule now: the TRAILING inset always keeps the icon row clear
/// (`iconRowWidth + gap`); the LEADING inset is symmetric while the
/// masthead can hold the floor between two such insets, then shrinks
/// continuously (no jump) as the width falls — the floor is spent on the
/// leading side, the title's centre drifting left of the masthead's — and
/// reaches 0 below `floor + trailing`, where the title yields to `…`. A
/// title that truncates before the icons is legal; a title under them is
/// not. At the standing widths (680 ≥ 240 + 2 × 112) both insets equal
/// `iconRowWidth + gap` exactly as before, so rows 4/19/58's pins hold.
nonisolated enum MastheadTitleInsets {
    /// The room between the title's band and the icon row.
    static let gap: CGFloat = 12

    static func insets(
        mastheadWidth: CGFloat, iconRowWidth: CGFloat, floor: CGFloat
    ) -> (leading: CGFloat, trailing: CGFloat) {
        let wanted = iconRowWidth + gap
        // Unmeasured (the first pass): symmetric, as it always was.
        guard mastheadWidth > 0 else { return (wanted, wanted) }
        let leading = min(wanted, max(0, mastheadWidth - floor - wanted))
        return (leading, wanted)
    }
}

extension View {
    /// Row 58's DEBUG oracle write: report this view's frame, in the named
    /// coordinate space `space` (the masthead's own), under `slot`. A no-op
    /// outside DEBUG, and with no space (a standalone host).
    @ViewBuilder
    func mastheadGeometryProbe(_ slot: MastheadProbeSlot, in space: String?) -> some View {
        #if DEBUG
        if let space {
            self.onGeometryChange(for: CGRect.self) {
                $0.frame(in: .named(space))
            } action: { MastheadGeometry.record(slot, $0) }
        } else {
            self
        }
        #else
        self
        #endif
    }
}

#if DEBUG
/// The correction round's detail oracle (rows 27/29): the inspector column's
/// occupant as the detail holds it — so a pin asserts the Block History pane
/// is GONE after a mode switch by the state that decides it (the inspector's
/// AppKit container can linger in the tree, collapsed, after a close).
@MainActor
enum PostDetailOracle {
    static var inspectorPanel: PostDetailView.InspectorPanel?
    /// Row 74: OUR divider's frame in the side column's space — reported in
    /// every window state, nil while no panel stands.
    static var sideColumnDividerFrame: CGRect?
}

/// The correction round's masthead oracle (rows 4/19 — the `BookOutlineGeometry`
/// pattern): where the title block's midX sits against the masthead's own
/// midX, in the masthead's coordinate space — so a pin asserts the centering
/// she sees, per mode, not a layout the code merely intends. Row 58 adds
/// the second row's frames — the path chip, each tag card by tag id, the
/// open field — so a pin asserts "these never intersect" as rectangles.
@MainActor
enum MastheadGeometry {
    static var titleMidX: CGFloat?
    static var contentMidX: CGFloat?
    static var pathChipFrame: CGRect?
    static var cardFrames: [String: CGRect] = [:]
    static var fieldFrame: CGRect?
    /// Row 80: the title TEXT's frame and the icon row's, both in the
    /// masthead's space — "the title never runs under the icons" is a
    /// claim about two rectangles.
    static var titleFrame: CGRect?
    static var iconRowFrame: CGRect?
    /// Row 59: the ＃ door's frame — its hit target.
    static var doorFrame: CGRect?

    static func record(_ slot: MastheadProbeSlot, _ frame: CGRect) {
        switch slot {
        case .pathChip: pathChipFrame = frame
        case .card(let id): cardFrames[id] = frame
        case .field: fieldFrame = frame
        case .iconRow: iconRowFrame = frame
        case .door: doorFrame = frame
        }
    }

    /// A pin resets the second row's frames before its mount, so a stale
    /// report from an earlier mount can never satisfy it.
    static func resetRowTwo() {
        pathChipFrame = nil
        cardFrames = [:]
        fieldFrame = nil
        doorFrame = nil
    }

    /// Row 80's pin resets the title row's frames the same way.
    static func resetTitleRow() {
        titleMidX = nil
        titleFrame = nil
        iconRowFrame = nil
    }
}
#endif
