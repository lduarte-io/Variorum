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
    /// VX-303: where INSIDE that block the caret lands (UTF-16) — a book's
    /// open door carries her caret. nil = the block's start, as before.
    var initialOffsetInBlock: Int? = nil
    /// 13o U2 (D6 — land-at-match): a search passage's matched words, riding
    /// the block landing — the arriving Write editor selects the match and
    /// arms the find bar (`EditorFindSeed`). nil for every other landing.
    var initialFind: EditorFindSeed? = nil
    /// VX-303 (R-U1a-2): the mode a door NAMED for this arrival — a book's
    /// open door names WRITE, her ruling (*"more consistent and useful than
    /// the note's last used mode"*), whether or not a block rides it. nil —
    /// every other door — is the note's remembered mode, as before.
    var initialMode: PostMode? = nil
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

    /// **The scraps door's word, named rather than typed** (13u4 UNIT S3 —
    /// KnownIssues row 68's H pattern: prose that names a door quotes the
    /// door). The tutorial's "pool & snippets" lesson sends her to this
    /// button, and a lesson that types the word instead of asking for it is
    /// exactly how that lesson came to name a "pool menu" no surface had.
    ///
    /// **It still says "Scraps", and that is recorded rather than swept
    /// here:** the pre-13u vocabulary ruling (W8-1) says the scrap area
    /// speaks as SNIPPETS in every UI string, and this door does not — but
    /// renaming a door she uses is a vocabulary fix of its own, not row 68's,
    /// and it would move this door's help, its pins and the phone's twin with
    /// it. It is in UNIT S3's conformance remainder list. What the constant
    /// buys meanwhile: the lesson is TRUE today and follows the door the day
    /// someone sweeps it.
    static let scrapsDoorTitle = "Scraps"

    ///
    /// **VX-426 (the VX-439 run, A-439-17) — each icon's tooltip LEADS with
    /// its name.** A beta tester: hovering these icons should say what they
    /// are ("Snippets", "Tray"); "every time I see the 'Snippets' button my
    /// brain thinks it's a copy/paste tool and becomes fearful to press it".
    /// So every help here opens with a one-word descriptor and an em dash,
    /// then says what it opens, as it did. The scraps door's descriptor is
    /// SNIPPETS — the area's name everywhere she reads it (W8-1); its title
    /// (and so the tour's and the guide's words) stays "Scraps" (the
    /// conformance remainder above — the morning bundle carries it).
    static let inspectorDoors: [InspectorDoor] = [
        InspectorDoor(
            panel: .tray(revealBlockID: nil), title: TrayPath.menuLabel,
            symbol: "tray",
            help: "Tray \u{2014} what this note has set aside: blocks it archived, "
                + "everything of its own that is on the \(TrashWindow.days)-day "
                + "clock, and the originals a divide or a merge kept whole"),
        InspectorDoor(
            panel: .scraps, title: Self.scrapsDoorTitle,
            symbol: "square.on.square.dashed",
            help: "Snippets \u{2014} show them beside the draft; drag one into the page "
                + "(⌥ carries its whole fan)"),
        InspectorDoor(
            panel: .references, title: "References", symbol: "books.vertical",
            help: "References \u{2014} the note's sources, shown beside the draft"),
    ]

    /// **13i-d U2 — THE BOOK PANEL's door** (her round-5 design: the panel
    /// joins *"scraps / reference / tray as a panel icon"*). Drawn ONLY while
    /// the note is a member of a BOOK (P-2 — a door that could only show "in
    /// no book" is not drawn; a gathering holds no membership), and drawn
    /// FIRST: the cluster trails right, so a door that comes and goes on the
    /// leading side never moves the three that are always there.
    static let bookPanelDoor = InspectorDoor(
        panel: .book, title: BookPanelCopy.doorTitle,
        symbol: BookPanelCopy.doorSymbol, help: BookPanelCopy.doorHelp)

    /// The cluster as drawn: the book door while the note has a book, then
    /// the standing three (pure, pinned).
    static func shownInspectorDoors(membered: Bool) -> [InspectorDoor] {
        (membered ? [bookPanelDoor] : []) + inspectorDoors
    }

    /// The `.surface` act this view renders (P-1's declared ⇔ rendered walk).
    /// `.showNoteTray`'s NAMED door is the masthead icon since her C1 ruling —
    /// the `note ▾` menu item moved with the panel, and the context bar's ⌫
    /// badge is the second renderer of the same act, as it always was.
    /// 13i-d U2: `.showBookPanel` — the book icon above.
    static let surfaceCapabilities: [CapabilityID] = [.showNoteTray, .showBookPanel]

    /// 13b 4D (S4-20, her reversal on the record): a post opens in WRITE
    /// the first time — supersedes the takes-first half of R72/R79
    /// (Sitting 9); the per-post mode MEMORY stands untouched: thereafter
    /// a post reopens in whatever mode you last used there (per-post,
    /// scroll-position class — local, never synced). 13b 4C: stored
    /// values decode through `PostMode.fromStored`, so a post left in the
    /// retired Outline tab reopens in Compare — no stored value strands.
    static func rememberedMode(postID: String, defaults: UserDefaults = .standard) -> Mode {
        defaults.string(forKey: "postMode.\(postID)").flatMap { Mode.fromStored($0) } ?? .write
    }

    @State private var mode: Mode = .write
    /// 13b 1b: the mode-router registration's lifecycle token (composed
    /// routing — the notification channels are retired).
    @State private var routerToken: UUID?
    /// A TOC jump's landing: the Write editor re-seeds at this caret (the
    /// hybrid primitive fires in the editor — TK2 §3: no folding here).
    @State private var pendingCaret: Int?
    /// 13o U2 (D6): the landing's find seed, one-shot exactly as the caret
    /// seed is (set beside it by `jump`, cleared beside it on leaving Write).
    @State private var pendingFind: EditorFindSeed?
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
    /// **…and — 13i-d U2 — THE BOOK PANEL** (her round-5 design): the
    /// note's book as a table of contents, the open note marked.
    enum InspectorPanel: Hashable {
        case references
        case scraps
        case tray(revealBlockID: String?)
        case blockHistory(BlockHistoryRequest)
        case versions
        case book

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
    /// 13i-d U2 (KnownIssues row 104): the note's membership — ONE held
    /// observation for the visit, handed to the membership chip and the Book
    /// Panel's door (the shared `NoteMembershipModel`), so an intake seat
    /// while the note is open shows at once and the note is read once.
    @State private var membership = NoteMembershipModel()
    #if DEBUG
    /// **This detail's own name in the DEBUG oracle** (18k UNIT C4 — the
    /// `MastheadStamp.oracleOwner` shape): it owns the detail's panel and
    /// divider rows, and the detail takes exactly those with it when it
    /// leaves. DEBUG-only.
    @State private var oracleOwner = UUID()
    #endif
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
    /// Row 58: the least room between the path chip and the tag cluster on
    /// the masthead's second row.
    static let rowTwoGap: CGFloat = 16

    /// The title row's trailing inset (row 80's rule, kept under U-8): it
    /// ALWAYS keeps the icon row's width clear. There is no leading inset —
    /// the title leads (row 11).
    private var titleTrailingInset: CGFloat {
        MastheadTitleInsets.trailingInset(iconRowWidth: mastheadIconRowWidth)
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
            tokens: tokens, shown: inspectorPanel != nil,
            widthKey: Self.sideColumnWidthKey, subjectKey: postID,
            onDividerFrame: { frame in
                #if DEBUG
                PostDetailOracle.recordSideColumnDivider(frame, owner: oracleOwner)
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
                    // Row 11 (her U-8, 17o batch d): the title LEADS — no
                    // leading inset at all, so its band starts exactly where
                    // row two's path chip does ("where 'in no book' is"), and
                    // it runs right until the icons' gap, further than the
                    // old 380-pt centered measure could reach.
                    // Row 80 (the correction round, batch G) SURVIVES its
                    // parent: the trailing inset always keeps the icon row
                    // clear — F's walk found the centered title touching the
                    // tray icon at a ~270-pt masthead, and a title under the
                    // icons is a defect under either rule. Below the icons'
                    // width the title yields to `…`, which is what row 80
                    // already ruled legal.
                    PostTitleLabel(session: session, postID: postID, tokens: tokens)
                        .frame(maxWidth: .infinity)
                        .padding(.trailing, titleTrailingInset)
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
                                        // 13u2b UNIT 3: the carry is captured
                                        // by the SWITCH, never inferred from a
                                        // mount — `switchMode` is the one door
                                        // this and `applyMode` share.
                                        Button(m.rawValue) { switchMode(to: m) }
                                    }
                                }
                                // 17y B2 (p): the BUILD's row and span.
                                .help("This note's mode — \(PostMode.modeList()) "
                                    + "(\(PostMode.keySpan()))")
                            }
                            // The masthead's inspector cluster, rendered FROM its
                            // door table (the `LibraryCatalogView.mastheadDoors`
                            // precedent — the table is the render source, not a
                            // comment beside one), so "the tray icon sits with
                            // scraps and references" is a claim a pin can hold.
                            ForEach(Self.shownInspectorDoors(
                                membered: !membership.books(for: postID).isEmpty),
                                    id: \.panel) { door in
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
                        recentBookIDs: recentBookIDs, membership: membership)
                        .mastheadGeometryProbe(.pathChip, in: Self.mastheadSpace)
                    // Act 10 item 5 — the note's tag cards on the
                    // masthead's right edge, under the icons, across from
                    // the membership chip (her ruling's letter). Row 58: a
                    // right-aligned wrapping row in the width that remains.
                    MastheadTagCluster(
                        session: session, postID: postID, tokens: tokens,
                        fieldOpen: $tagFieldOpen,
                        geometryProbeSpace: Self.mastheadSpace)
                    // 18h batch 1 (her R-Q7): the note's own time, quiet, at
                    // the row's trailing end — *edited today 1:33 AM*, a
                    // click flipping it to *created …*. Row two's THIRD
                    // subview, not a second layout: the width-aware rule
                    // already knows how to give three things one line or
                    // two.
                    MastheadStamp(session: session, postID: postID, tokens: tokens)
                }
            }
            .frame(maxWidth: mastheadMeasure, alignment: .leading)
            // 17o c/d/e ladder round 1, MINOR-3: the masthead's own measured
            // width USED to live here as `@State`, read only by
            // `titleInsets`' 240-pt line floor. Row 11 retired that floor
            // with the centering it existed for, leaving the state
            // write-only — every width change invalidating this body for a
            // value nothing consumed, and row 9's newly reachable seam grip
            // makes a resize drag run that continuously. The DEBUG oracle's
            // reach check reads the masthead's own half-width below
            // (`contentMidX`) and the title BAND's frame in `PostTitleLabel`;
            // row two computes from its own layout. Nothing read it.
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 24)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(tokens.surface)
            // 13s-b U2 (A2): the tour's cards never cover the masthead.
            .tourKeepClear()
            .coordinateSpace(name: Self.mastheadSpace)
            // Row 50: every masthead probe under here — the chip, the tag
            // cards, the open field, the ＃ door, the stamp — reports into
            // THIS session's scope, so a concurrent suite's masthead cannot
            // answer a pin's question.
            .debugProbeScope(session)
            // The inline tag field's suggestion list hangs below the
            // masthead's bottom edge; the masthead draws above the page.
            .zIndex(1)
            #if DEBUG
            .onGeometryChange(for: CGFloat.self) { $0.size.width / 2 } action: {
                MastheadGeometry.recordContentMidX($0, in: session.debugProbeScope)
            }
            #endif
            Divider().overlay(tokens.line)
            switch mode {
            case .write:
                EditorView(
                    session: session, postID: postID, caretSeed: pendingCaret,
                    findSeed: pendingFind)
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
            case .book:
                // 13i-d U2 — the Book Panel, in the same room (one width rule,
                // remembered): the note's book, its chapters and notes. It
                // reads the membership THIS detail observes (row 104's model).
                BookPanelView(
                    session: session, postID: postID, membership: membership,
                    recentBookIDs: recentBookIDs,
                    onClose: { withAnimation(Self.panelAnimation) { inspectorPanel = nil } })
                    .id("book-\(postID)")
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
            let remembered = Self.rememberedMode(postID: postID)
            mode = initialMode ?? remembered
            // VX-303 (R-U1a-2): a named mode is where she now IS in this note,
            // so its memory says so — the write a switch makes through
            // `onChange(of: mode)`, which a mount's first assignment never
            // fires (the `@State` starts at `.write`). Without it a door
            // into Write over a note left in Lenses would leave "Lenses" as
            // the note's last used mode after she had worked in Write.
            if let initialMode, initialMode != remembered {
                UserDefaults.standard.set(initialMode.rawValue, forKey: "postMode.\(postID)")
            }
            if let initialBlockID {
                jump(to: initialBlockID, offsetInBlock: initialOffsetInBlock, find: initialFind)
            }
            let binding = $mode
            let panel = $inspectorPanel
            let tagField = $tagFieldOpen
            let router = session.commandRouter
            routerToken = session.commandRouter.registerDetail(
                postID: postID, mode: mode,
                // 13u2b UNIT 3: every routed mode switch (⌘1–⌘7, the sidebar
                // rail, ⌘K, the bars' "write" doors) comes through here, so
                // the carry is captured HERE — before the mode changes, while
                // the outgoing surface is still mounted and still knows where
                // the carried block sits. A request for the mode already
                // showing captures nothing: it is not a switch.
                // (`[weak router]`: the router STORES this closure, so a strong
                // capture would be a cycle for as long as the detail is
                // registered — broken at `unregisterDetail`, but a cycle a
                // reader has to reason about is one worth not making.)
                applyMode: { [weak router] m in
                    if binding.wrappedValue != m { router?.carryPlaceAcrossModeSwitch() }
                    binding.wrappedValue = m
                },
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
            #if DEBUG
            // 18k C4: THIS detail's panel and divider, and no other window's.
            PostDetailOracle.release(owner: oracleOwner)
            #endif
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
        // 13i-d U2 (row 104): the membership observation, for this note's
        // visit — a new note cancels it and starts its own.
        .task(id: postID) {
            await membership.track(session: session, postID: postID)
        }
        .onChange(of: inspectorPanel, initial: true) { _, panel in
            #if DEBUG
            PostDetailOracle.recordInspectorPanel(panel, owner: oracleOwner)
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
            if new != .write {
                pendingCaret = nil
                pendingFind = nil  // 13o U2: the find seed is the caret's twin
            }
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
        /// VX-569: what the open field OFFERS an untitled note — its first
        /// words, else its date (`TitleQuickfill`); Tab takes it. Read when
        /// the field opens; nil on a titled note.
        @State private var offer: String?
        @FocusState private var fieldFocused: Bool
        #if DEBUG
        /// This title's own name in the DEBUG oracle (18k UNIT C4): it owns
        /// the title door and the shown words, and takes them with it.
        @State private var oracleOwner = UUID()
        #endif

        var body: some View {
            // **ONE BOX for both faces** (17o batch d, rows 11 + 12).
            //
            // Row 11 (her U-8): the title LEADS. The box takes the whole
            // title band — which now starts at the masthead's leading edge,
            // exactly where row two's path chip starts, because the leading
            // inset is zero — and runs right until the icon row's gap. The
            // old 380-pt `measure` centered in that band is retired with the
            // centering it served: *"it should be able to extend at least as
            // far as the middle centered title can extend right now."*
            //
            // Row 12: the placeholder used to shift when she clicked. The
            // two faces shared a max WIDTH and nothing else, so the field's
            // own intrinsic height changed the row the moment the title went
            // editable. Now a HIDDEN copy of the label, at the title's own
            // font, defines the box — and the live face is drawn inside it
            // as an overlay, which by construction cannot resize its parent
            // and is handed exactly that box to fill. Sizing this way rather
            // than from a constant is deliberate: the title font differs per
            // voice (19-pt monospaced in Terminal, 21-pt Iowan in Study) and
            // SwiftUI's `Font` will not tell anyone its line height.
            Text(displayed.isEmpty ? DisplayTitle.placeholder : displayed)
                .font(tokens.title)
                .lineLimit(1)
                .hidden()
                .accessibilityHidden(true)
                .frame(maxWidth: .infinity, alignment: .leading)
                #if DEBUG
                // The oracle reads the BAND now, not the words: under U-8
                // "where the title starts" and "how far it can reach" are
                // both questions about the box the words are given.
                .onGeometryChange(for: CGRect.self) {
                    $0.frame(in: .named(PostDetailView.mastheadSpace))
                } action: {
                    MastheadGeometry.recordTitle($0, in: session.debugProbeScope)
                }
                #endif
                .overlay(alignment: .leading) { face }
                // **Act 10 ledger row 93 (13u2 UNIT D, item 13's second
                // half) — THE OPEN MARK.** The round's walk recorded it as
                // an observation: on a note named by its DAY, clicking the
                // title opens a rename field whose PROMPT is that same day,
                // in the title's own font, in the label's own place — so the
                // click reads as *"nothing happened"* although the door
                // worked. (The prompt is deliberate: 13g batch 7's R6-3
                // rides the date there so the line still reads as it did,
                // and the DRAFT is the stored name, so typing NAMES the note
                // rather than renaming it after itself.) Row 93's own nit
                // named the remedy — *"a field border, or the caret placed"*
                // — and the caret is already placed, so this is the border:
                // a 1-pt ACCENT RULE under the band while the field is open,
                // the tag field's own open-state vocabulary
                // (`TagInlineField` strokes in the accent while focused) at
                // a masthead's restraint, instead of a box around a 585-pt
                // title.
                //
                // It hangs on the BAND, beside the face rather than inside
                // it, so it cannot resize anything: row 12's "one box,
                // nothing shifts on click" is untouched and the words do not
                // move by a point when the mark appears.
                .overlay(alignment: .bottom) {
                    if editing {
                        Rectangle()
                            .fill(tokens.accent)
                            .frame(height: 1)
                            .accessibilityHidden(true)
                            #if DEBUG
                            // The oracle is PRESENCE, not a rectangle, and
                            // that is measured rather than preferred:
                            // `onGeometryChange` was tried here first and
                            // never fired for this leaf in three shapes
                            // (a filled `Rectangle`, a `Color`, either
                            // inside the overlay or on the band), while
                            // `onAppear` fires every time — so the pin asks
                            // the question the oracle can actually answer,
                            // and the VISUAL half is the walk's (item 13's
                            // capture).
                            .onAppear {
                                MastheadGeometry.noteTitleOpenMark(
                                    in: session.debugProbeScope)
                            }
                            #endif
                    }
                }
                .task(id: postID) { await watch() }
                #if DEBUG
                .onAppear {
                    PostDetailOracle.publishTitleDoor(owner: oracleOwner) { beginEditing() }
                }
                // 18k C4: a title leaving takes its door and words, and no
                // other window's (the door used to be cleared by nobody, so
                // a closed window's title answered the next reader).
                .onDisappear { PostDetailOracle.release(owner: oracleOwner) }
                #endif
        }

        @ViewBuilder
        private var face: some View {
            Group {
                if editing {
                    // **17y B2 (n) — the words STAY when the field opens.** On
                    // a note named by its day the draft is the stored name,
                    // "", so the open field used to show the date as its OWN
                    // prompt — and SwiftUI's field editor lays a prompt out
                    // against the field's top, not on the label's baseline:
                    // in Study (Iowan's ascender is taller than its size) the
                    // date rode 6.5 pt up and was clipped at the field's top,
                    // "the chrome is still shifted up". Row 12's one box held
                    // (the frames agree); the words inside it did not. So the
                    // field carries NO prompt, and while the draft is empty
                    // the date is drawn by the resting face's own `Text` —
                    // same font, same frame, same place — behind the field.
                    // Typed text already lands on the label's line (measured
                    // within half a point), so nothing moves either way.
                    // (The same shape the 2026-09-06 round's row 10 named as
                    // the API-free road for the digit prompt.)
                    // VX-569: the faint words are the OFFER — her first
                    // line, or (a note with no words) the date — in this
                    // same place and font; Tab takes them.
                    if draft.isEmpty {
                        Text(offer ?? displayed)
                            .font(tokens.title)
                            .foregroundStyle(tokens.faint)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    }
                    TextField("", text: $draft)
                        .accessibilityLabel(Text(displayed))
                        .textFieldStyle(.plain)
                        .font(tokens.title)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                        .focused($fieldFocused)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        // VX-569 (her 10-20: "maybe just tab to complete it
                        // and enter"): Tab on an empty field TAKES the offer
                        // — the field then holds it, ⏎ files it; any other
                        // Tab (a typed name, nothing offered) is Tab.
                        .onKeyPress(.tab) {
                            guard draft.isEmpty, let offer else { return .ignored }
                            draft = offer
                            return .handled
                        }
                        .onSubmit { rename() }
                        .onExitCommand { cancel() }
                        .onChange(of: fieldFocused) { _, focused in
                            // Clicking away commits what she typed rather
                            // than dropping it (the standing "nothing typed
                            // is lost" posture, at chrome scale).
                            if !focused, editing { rename() }
                        }
                        #if DEBUG
                        // Row 12's oracle: the EDITING face's frame, in the
                        // same space the resting face reports in.
                        .onGeometryChange(for: CGRect.self) {
                            $0.frame(in: .named(PostDetailView.mastheadSpace))
                        } action: {
                            MastheadGeometry.recordTitleField($0, in: session.debugProbeScope)
                        }
                        #endif
                        .task { fieldFocused = true }
                } else {
                    Text(displayed)
                        .font(tokens.title)
                        .foregroundStyle(title.isEmpty ? tokens.muted : tokens.ink)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        #if DEBUG
                        // Row 12's other half: the RESTING face's own frame,
                        // to compare against the editing face's.
                        .onGeometryChange(for: CGRect.self) {
                            $0.frame(in: .named(PostDetailView.mastheadSpace))
                        } action: {
                            MastheadGeometry.recordTitleLabel($0, in: session.debugProbeScope)
                        }
                        #endif
                        // U-8: it LEADS, and fills the band it is given.
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        // Row 93's oracle is cleared HERE, by the face whose
                        // presence means the field is closed — never by the
                        // mark's own `onDisappear`, which SwiftUI does not
                        // order against a successor's appearance
                        // (KnownIssues row 55's `CatalogStampOracle` class,
                        // met here: the mark published and was then wiped by
                        // the departing instance of itself).
                        .onTapGesture { beginEditing() }
                        .help("The note's name — click to rename it right here")
                }
            }
        }

        private func beginEditing() {
            // The DRAFT is the stored name, never the shown date: clicking a
            // date and typing must name the note, not rename it after
            // itself (13g batch 7, R6-3). While the draft is empty the date
            // is drawn BEHIND the open field by the resting face's own `Text`
            // (17y B2 (n) — the field carries no prompt), so the line still
            // reads as it did.
            draft = title
            editing = true
            // VX-569: the offer, read once as the field opens (the note's
            // opening — one bounded read — or its shown date), and adopted only
            // while the field is still open and still empty.
            offer = nil
            guard DisplayTitle.isAbsent(title) else { return }
            let shown = displayed
            Task {
                let opening = (try? await session.database.read { [postID] db in
                    try TitleQuickfill.opening(db, postID: postID)
                }) ?? []
                guard editing, draft.isEmpty else { return }
                offer = TitleQuickfill.offer(storedTitle: title, openingTexts: opening, shownName: shown)
            }
        }

        private func cancel() {
            editing = false
            draft = title
            offer = nil
        }

        /// What the masthead reads: the STORED title (what the rename field
        /// edits and what a no-op rename compares against) and the DISPLAY
        /// name (the stored title, else the note's date, from core's one
        /// display brain).
        nonisolated struct TitleRead: Equatable, Sendable {
            let stored: String
            let shown: String
        }

        /// **Row 19 (17o batch d): the title is a HELD read, not a one-shot.**
        /// Her words: *"changing the date of a note doesn't change its auto
        /// display name."* `refresh()` ran once per note (`.task(id: postID)`)
        /// and never again, so `setEntryDate` — which is what the derived name
        /// is BUILT from — moved the store and left the words alone until the
        /// note was re-opened. Row 18's fix, one note wide: the same read,
        /// held, so every door that writes this note's name (the field here,
        /// the sidebar's rename, the date picker, a sync pull) moves the
        /// masthead by itself. The fetch is one indexed row; `removeDuplicates`
        /// keeps the view still while nothing shown has changed.
        private func watch() async {
            do {
                for try await read in session.database.observe({ [postID] db in
                    TitleRead(
                        stored: try Queries.containerTitle(db, id: postID) ?? "",
                        // A note that is gone keeps the placeholder rather
                        // than going blank — the chrome's own fallback.
                        shown: try Queries.noteDisplayTitle(db, id: postID)
                            ?? DisplayTitle.placeholder)
                }) {
                    title = read.stored
                    displayed = read.shown
                    #if DEBUG
                    PostDetailOracle.recordTitleShown(displayed, owner: oracleOwner)
                    #endif
                }
            } catch is CancellationError {
            } catch {
                // The last name stands; the chrome never blanks on a failed
                // read (the strip's posture, one note wide).
            }
        }

        private func rename() {
            guard editing else { return }
            editing = false
            offer = nil
            let name = draft.trimmingCharacters(in: .whitespaces)
            guard name != title else { return }
            Task {
                // No re-read here: the held observation (row 19) delivers the
                // committed name, so the field's own write and every other
                // door move the masthead by exactly one road.
                try? await session.runner.run { [postID] ops in
                    try ops.renameContainer(postID, title: name.isEmpty ? nil : name)
                }
            }
        }
    }

    /// **THE mode-switch door** (13u2b UNIT 3): ask the mounted surface where
    /// the carried block sits, then change the mode — so the arriving surface
    /// can put that block at the same viewport fraction it had (the
    /// architectural trace's §6; the rule is the pure `ViewportCarry`).
    ///
    /// The capture is HERE, at the act, and not in `onChange(of: mode)`,
    /// because by then the outgoing surface may already be torn down and its
    /// geometry gone — and because the distinction this unit rests on is
    /// "this entry is a mode switch", which has to be a fact about the call
    /// site rather than a guess from timing.
    ///
    /// **Which roads deliberately do NOT come through here**, each because it
    /// names its own block and carries its own standing landing: `jump(to:)`
    /// below (Blocks' *open in write*, the index column's jump, Read's
    /// `onJump`, the canvas card — a click-through to a DIFFERENT block, where
    /// carrying the height of the one she was looking at would be meaningless);
    /// `onAppear`'s remembered mode (a mount, not a switch); and the blockless
    /// guard's `mode = .write` (a correction, with nothing on screen to carry).
    ///
    /// Of those, the BLOCKLESS GUARD is the one road covered by NEITHER rule —
    /// no re-decide here, no `dropCarriedPlace` like `jump(to:)`'s — and that
    /// is safe by construction rather than by luck (ladder round 1's sanity
    /// note): it fires only when the note has no blocks, a capture needs an
    /// on-screen block of THIS note, and the slot is note-scoped and cleared
    /// on a note change — so no carry can exist for the state that road runs
    /// in. If the guard ever grows a second trigger, it joins one of the two
    /// rules rather than staying bare.
    private func switchMode(to new: Mode) {
        guard new != mode else { return }
        session.commandRouter.carryPlaceAcrossModeSwitch()
        mode = new
    }

    /// `find` (13o U2, D6): a search passage's landing seeds the match too;
    /// every other road names none, which also clears a seed left standing.
    ///
    /// `offsetInBlock` (VX-303): a book's open door lands at her CARET inside
    /// the block, not its first character. Clamped to the block's length as
    /// the store holds it now — the doors flush her pending typing first, and
    /// a block that shrank since must never push the caret into the next one
    /// (`EditorViewModel.rememberedArrivalLanding`'s own clamp, one road over).
    /// nil — every other road — is the block's start, as before.
    nonisolated static func landingOffset(blockRange: NSRange, offsetInBlock: Int?) -> Int {
        blockRange.location + min(max(0, offsetInBlock ?? 0), blockRange.length)
    }

    private func jump(
        to blockID: String, offsetInBlock: Int? = nil, find: EditorFindSeed? = nil
    ) {
        Task {
            let offset: Int? = try? await session.database.read { [postID] db in
                let slots = try Queries.renderPost(db, containerID: postID)
                guard let i = slots.firstIndex(where: { $0.blockID == blockID }) else {
                    return nil
                }
                return Self.landingOffset(
                    blockRange: BlockRangeIndex(slots: slots, tail: nil).range(ofEntryAt: i),
                    offsetInBlock: offsetInBlock)
            }
            // Set BEFORE the caret: the caret is what re-keys the editor, and
            // the new editor must be born holding both seeds.
            pendingFind = find
            pendingCaret = offset ?? 0
            // 13u2b ladder round 1 (MINOR 1's second door): this road names
            // its own block and keeps its standing landing — and it changes
            // the mode OUTSIDE `switchMode`'s re-decide, so any place parked
            // by an earlier switch is dropped here rather than left for this
            // arrival to consume.
            session.commandRouter.dropCarriedPlace()
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
    /// 18h batch 1 (her R-Q7): the note's time stamp at row two's trailing
    /// end — **keyed by the NOTE** (the ladder's R1-14 and the brief's own
    /// row-53 rule, "keyed by subject"): two note windows write this oracle
    /// from two mastheads, and an unkeyed slot lets the last one mounted
    /// answer for both.
    case stamp(String)
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

    /// **U-8 (17o batch d, row 11): the title LEADS**, so there is no
    /// leading inset left to compute — its band starts at the masthead's own
    /// leading edge, which is where row two's path chip starts.
    ///
    /// Row 80's rule outlives the centering it was written for: the trailing
    /// inset ALWAYS keeps the icon row clear, gap included. A title under
    /// the icons was the defect then and would be the defect now; what the
    /// ruling changed is where the title spends the room it has.
    ///
    /// The 240-pt line floor retires WITH the centering. It existed to stop
    /// a centered band collapsing between two symmetric insets; a leading
    /// title has no second inset to be squeezed by, and at a narrow masthead
    /// it simply truncates at the icons — which is the same yield row 80
    /// already ruled legal.
    static func trailingInset(iconRowWidth: CGFloat) -> CGFloat {
        iconRowWidth + gap
    }
}

#if DEBUG
/// The probe, as a modifier rather than a bare `onGeometryChange`, because it
/// must READ the environment for its scope (13u2 UNIT E — row 50).
private struct MastheadGeometryProbe: ViewModifier {
    let slot: MastheadProbeSlot
    let space: String
    @Environment(\.debugProbeScope) private var scope

    func body(content: Content) -> some View {
        content.onGeometryChange(for: CGRect.self) {
            $0.frame(in: .named(space))
        } action: { MastheadGeometry.record(slot, $0, in: scope) }
    }
}
#endif

extension View {
    /// Row 58's DEBUG oracle write: report this view's frame, in the named
    /// coordinate space `space` (the masthead's own), under `slot`. A no-op
    /// outside DEBUG, and with no space (a standalone host).
    @ViewBuilder
    func mastheadGeometryProbe(_ slot: MastheadProbeSlot, in space: String?) -> some View {
        #if DEBUG
        if let space {
            self.modifier(MastheadGeometryProbe(slot: slot, space: space))
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
    // **18k UNIT C4 — THE FOUR SINGLETONS NAME THEIR OWNER** (the rule and
    // its reasons: `Core/Views/DebugOracleOwnership.swift`; the stamps below
    // were the same idea hand-rolled at 13u4 UNIT S2). They were bare
    // statics every mounted detail overwrote, and the title door was cleared
    // by nobody — so after one window closed, the title, the panel and the
    // divider were ITS, and the door drove a title that no longer existed.
    // Measured red, `DebugOracleTwoWindowTests`. Read names and shapes
    // unchanged; the one pin door that used to be an assignment is
    // `forgetSideColumnDivider()`.
    private static var inspectorPanelSlot = OwnedSlot<PostDetailView.InspectorPanel?>()
    private static var titleDoorSlot = OwnedSlot<@MainActor () -> Void>()
    private static var titleShownSlot = OwnedSlot<String>()
    private static var dividerSlot = OwnedSlot<CGRect?>()

    /// The detail's inspector occupant — the newest detail's, and nil when
    /// that detail holds no panel (a REGISTERED nil: "no panel" is a fact
    /// about a detail on screen, distinct from no detail at all).
    static var inspectorPanel: PostDetailView.InspectorPanel? { inspectorPanelSlot.value ?? nil }
    /// Row 12 (17o batch d): the title's own "click to rename" door, so a
    /// pin can put the masthead into its editing face and read both frames
    /// without simulating an AppKit click into a hosted `TextField`.
    static var beginTitleEditing: (@MainActor () -> Void)? { titleDoorSlot.value }
    /// Row 19 (17o batch d): the words the masthead is SHOWING — so "a date
    /// change doesn't change the auto display name" is a claim about the
    /// rendered title rather than about the store it is derived from.
    static var titleShown: String? { titleShownSlot.value }
    /// Row 74: OUR divider's frame in the side column's space — reported in
    /// every window state, nil while no panel stands (the column REPORTS that
    /// nil, so it is registered like `inspectorPanel`'s).
    static var sideColumnDividerFrame: CGRect? { dividerSlot.value ?? nil }

    static func recordInspectorPanel(_ panel: PostDetailView.InspectorPanel?, owner: UUID) {
        inspectorPanelSlot.publish(panel, owner: owner)
    }

    static func publishTitleDoor(owner: UUID, _ door: @escaping @MainActor () -> Void) {
        titleDoorSlot.publish(door, owner: owner)
    }

    static func recordTitleShown(_ words: String, owner: UUID) {
        titleShownSlot.publish(words, owner: owner)
    }

    static func recordSideColumnDivider(_ frame: CGRect?, owner: UUID) {
        dividerSlot.publish(frame, owner: owner)
    }

    /// A detail (or its title) leaving: its own registrations among the
    /// four, and nothing another window's detail still answers for.
    static func release(owner: UUID) {
        inspectorPanelSlot.release(owner: owner)
        titleDoorSlot.release(owner: owner)
        titleShownSlot.release(owner: owner)
        dividerSlot.release(owner: owner)
    }

    /// A PIN's door (it used to be `sideColumnDividerFrame = nil`):
    /// unconditional — a pin owns nothing.
    static func forgetSideColumnDivider() { dividerSlot.forget() }
    /// 18h batch 1 (row 9): the WORDS the masthead's time stamp is showing,
    /// and the edited stamp its HELD read last delivered — so "an autosave
    /// moves it" is a claim about the observation rather than about the
    /// store it reads (the row-19 lesson, pinned).
    ///
    /// **Keyed by note since the ladder's R1-14.** The brief asked for the
    /// row-53 rule ("keyed by subject") and the batch applied it to none of
    /// the four oracles it added — including `MastheadGeometry.stampFrame`,
    /// which the finding believed was keyed and was not. With two note
    /// windows open in a DEBUG build the last `onAppear` won, for all of
    /// them. DEBUG-only either way; keyed now, so a pin can name its note.
    ///
    /// **…AND KEYED BY THE MASTHEAD THAT REGISTERED THEM since 13u4 UNIT S2**
    /// (`KnownIssuesAndTechDebt` row 51's first edge, which 17q recorded and
    /// left: *"`PostDetailOracle.resetStamp` with the SAME note open in two
    /// windows (closing either clears the other masthead's oracle entries;
    /// needs ownership tracking)"*). The keying by note was necessary and
    /// not sufficient: two windows on ONE note share the key, so a teardown
    /// in either emptied the row while the other masthead was still drawn —
    /// measured red before this fix (`StampOracleOwnershipTests`). Now every
    /// masthead registers under its OWN token, the reads answer from the
    /// most recent registrant, and a teardown removes only that masthead's
    /// entry. The public read shape is unchanged, so every pin reads as it
    /// did.
    private struct StampEntry {
        var words: String?
        var editedAt: Date?
        var flip: (@MainActor () -> Void)?
        /// **Which of her three faces the masthead is resting in** (13u4
        /// UNIT S2, item 1). The words go silent in the collapsed face, so
        /// without this a pin could not tell *"she is in clock mode"* from
        /// *"the read has not landed yet"* — the two states a nil `words`
        /// would otherwise share.
        var face: String?
    }

    /// postID → the mastheads standing on it, oldest first (the last one is
    /// what the reads answer from — the most recently mounted masthead is
    /// the one a pin means).
    private static var stampOwners: [String: [UUID]] = [:]
    private static var stampEntries: [String: [UUID: StampEntry]] = [:]

    static var stampShown: [String: String] { current(\.words) }
    static var stampEditedAt: [String: Date] { current(\.editedAt) }
    /// …and its click, so a pin flips it without simulating an AppKit click
    /// into hosted chrome (`beginTitleEditing`'s own pattern).
    static var flipStamp: [String: @MainActor () -> Void] { current(\.flip) }
    static var stampFace: [String: String] { current(\.face) }

    private static func current<V>(_ field: KeyPath<StampEntry, V?>) -> [String: V] {
        var answer: [String: V] = [:]
        for (postID, owners) in stampOwners {
            guard let owner = owners.last,
                  let value = stampEntries[postID]?[owner]?[keyPath: field] else { continue }
            answer[postID] = value
        }
        return answer
    }

    /// The one-window reads, for a pin that mounted exactly one detail.
    static var stampShownAnywhere: String? { stampShown.values.first }
    static var stampEditedAtAnywhere: Date? { stampEditedAt.values.first }

    // MARK: - The masthead's registrations (each names itself)

    /// A masthead takes this note's stamp row: its click door, and its place
    /// at the end of the note's owner list.
    static func claimStamp(
        _ postID: String, owner: UUID, flip: @escaping @MainActor () -> Void
    ) {
        note(postID, owner: owner)
        stampEntries[postID, default: [:]][owner, default: StampEntry()].flip = flip
    }

    /// The words this masthead is SHOWING (nil clears its own words only).
    static func recordStamp(_ postID: String, words: String?, owner: UUID) {
        note(postID, owner: owner)
        stampEntries[postID, default: [:]][owner, default: StampEntry()].words = words
    }

    /// The face this masthead is RESTING in (item 1's cycle).
    static func recordStampFace(_ postID: String, face: String, owner: UUID) {
        note(postID, owner: owner)
        stampEntries[postID, default: [:]][owner, default: StampEntry()].face = face
    }

    /// The edit stamp this masthead's held read last delivered.
    static func recordStampEdited(_ postID: String, at date: Date?, owner: UUID) {
        note(postID, owner: owner)
        stampEntries[postID, default: [:]][owner, default: StampEntry()].editedAt = date
    }

    /// A masthead leaves (its window closed, or its `.task(id:)` swapped to
    /// another note). It takes ITS OWN entry and nothing else — which is the
    /// whole of row 51's first edge. The geometry row goes only when the
    /// last masthead on the note has gone, for the same reason.
    static func releaseStamp(_ postID: String, owner: UUID, in scope: String) {
        guard var owners = stampOwners[postID], owners.contains(owner) else { return }
        owners.removeAll { $0 == owner }
        stampEntries[postID]?[owner] = nil
        if owners.isEmpty {
            stampOwners[postID] = nil
            stampEntries[postID] = nil
            MastheadGeometry.forgetStamp(postID, in: scope)
        } else {
            stampOwners[postID] = owners
        }
    }

    /// Forget this note's stamp oracles WHOLESALE — a PIN's door, called
    /// before its mount so a stale report cannot satisfy it (the ladder's
    /// R2-9). Deliberately unconditional: a pin owns nothing, and "start
    /// from empty" is exactly what it is asking for.
    static func resetStamp(_ postID: String, in scope: String) {
        stampOwners[postID] = nil
        stampEntries[postID] = nil
        // …and the GEOMETRY oracle clears its own row (the ladder's R3-10):
        // one call site for a pin, but neither oracle reaches into the
        // other's storage.
        MastheadGeometry.forgetStamp(postID, in: scope)
    }

    private static func note(_ postID: String, owner: UUID) {
        var owners = stampOwners[postID] ?? []
        guard !owners.contains(owner) else { return }
        owners.append(owner)
        stampOwners[postID] = owners
    }
}

/// The correction round's masthead oracle (rows 4/19 — the `BookOutlineGeometry`
/// pattern): where the title block's midX sits against the masthead's own
/// midX, in the masthead's coordinate space — so a pin asserts the centering
/// she sees, per mode, not a layout the code merely intends. Row 58 adds
/// the second row's frames — the path chip, each tag card by tag id, the
/// open field — so a pin asserts "these never intersect" as rectangles.
@MainActor
enum MastheadGeometry {
    /// **SCOPED BY THE MOUNTING SESSION** (13u2 UNIT E — KnownIssues row 50).
    /// Swift Testing runs SUITES IN PARALLEL, so a process-global static here
    /// let another suite's mounted masthead answer this pin's question — a
    /// green pin that proved nothing. The scope travels by environment
    /// (`DebugProbeScope.swift`); a pin reads its own session's. The
    /// per-subject keys (tag cards, per-note stamps) ride UNDER it, so a
    /// mount holding several of a thing still says which one it means.
    private struct World {
        var titleMidX: CGFloat?
        var contentMidX: CGFloat?
        var pathChipFrame: CGRect?
        var cardFrames: [String: CGRect] = [:]
        var fieldFrame: CGRect?
        /// Row 80: the title TEXT's frame and the icon row's, both in the
        /// masthead's space — "the title never runs under the icons" is a
        /// claim about two rectangles.
        var titleFrame: CGRect?
        /// Row 12 (17o batch d): the EDITING face's frame, in the same space
        /// — "the placeholder shifts upwards when you click the title" is a
        /// claim about two rectangles, exactly as row 80's is.
        var titleFieldFrame: CGRect?
        /// …and the RESTING face's, so row 12 compares like with like.
        var titleLabelFrame: CGRect?
        /// **Act 10 row 93 (13u2 UNIT D):** whether the OPEN MARK under the
        /// title band is drawn. "A click on a nameless note's title looks
        /// like nothing happened" is a claim about whether ANYTHING is drawn,
        /// so the oracle COUNTS APPEARANCES; the mark's look is the walk's
        /// evidence.
        ///
        /// Appearances rather than presence, and the reason is measured:
        /// under the mounted harness the rename field opens and then closes
        /// again on its own (the hosted `TextField` never holds the key
        /// window's focus, so `onChange(of: fieldFocused)` commits and closes
        /// it). A presence flag therefore read FALSE by the time a pin could
        /// look — while the frame oracles beside it kept their last values
        /// and read as though the field were still open. A monotonic count
        /// says the true thing: the mark WAS drawn when the field opened.
        var titleOpenMarkAppearances = 0
        var iconRowFrame: CGRect?
        /// Row 59: the ＃ door's frame — its hit target.
        var doorFrame: CGRect?
        /// 18h batch 1: the time stamp's frame, so "it sits at the row's
        /// trailing end and covers nothing" is a claim about rectangles —
        /// **per note** since the ladder's R1-14.
        var stampFrames: [String: CGRect] = [:]
        /// **A MONOTONIC COUNT OF EVERY MASTHEAD GEOMETRY REPORT** (13u2
        /// UNIT E — KnownIssues row 59's fix).
        ///
        /// The flake it exists to end: a pin opened the tag field, waited for
        /// the FIELD's frame, then pumped a fixed number of run-loop turns
        /// and read the row's rectangles — which, under full-suite load, were
        /// not all from the same layout pass. The comparison grazed by
        /// ~1.5 pt and the app was right in both voices.
        ///
        /// A count makes the honest predicate expressible: *the masthead's
        /// geometry has stopped moving*, so every rectangle a pin then reads
        /// comes from ONE layout state. It is falsifiable in the way a blind
        /// pump is not — a real overlap survives quiescence and fails loudly,
        /// and a masthead that never goes quiet fails with its own sentence
        /// instead of silently handing over stale frames.
        ///
        /// `&+` because it is a tripwire, not an arithmetic fact: a DEBUG
        /// process that somehow reported `Int.max` times should wrap, never
        /// trap.
        var reports = 0
    }

    private static var worlds: [String: World] = [:]

    // MARK: - The writes (each one bumps `reports`, so quiescence is readable)

    static func record(_ slot: MastheadProbeSlot, _ frame: CGRect, in scope: String) {
        worlds[scope, default: World()].reports &+= 1
        switch slot {
        case .pathChip: worlds[scope]?.pathChipFrame = frame
        case .card(let id): worlds[scope]?.cardFrames[id] = frame
        case .field: worlds[scope]?.fieldFrame = frame
        case .iconRow: worlds[scope]?.iconRowFrame = frame
        case .door: worlds[scope]?.doorFrame = frame
        case .stamp(let postID): worlds[scope]?.stampFrames[postID] = frame
        }
    }

    static func recordTitle(_ frame: CGRect, in scope: String) {
        worlds[scope, default: World()].reports &+= 1
        worlds[scope]?.titleMidX = frame.midX
        worlds[scope]?.titleFrame = frame
    }

    static func recordContentMidX(_ midX: CGFloat, in scope: String) {
        worlds[scope, default: World()].contentMidX = midX
    }

    static func recordTitleField(_ frame: CGRect, in scope: String) {
        worlds[scope, default: World()].titleFieldFrame = frame
    }

    static func recordTitleLabel(_ frame: CGRect, in scope: String) {
        worlds[scope, default: World()].titleLabelFrame = frame
    }

    static func noteTitleOpenMark(in scope: String) {
        worlds[scope, default: World()].titleOpenMarkAppearances += 1
    }

    /// Forget ONE note's stamp frame — this oracle's own door, called by
    /// `PostDetailOracle.resetStamp` when a masthead's note goes away (the
    /// 18h ladder's R3-10: that function used to assign into `stampFrames`
    /// directly, so one oracle owned another's storage lifetime).
    static func forgetStamp(_ postID: String, in scope: String) {
        worlds[scope]?.stampFrames[postID] = nil
    }

    // MARK: - The reads

    /// A pin's OWN masthead — every read below is this session's mount.
    @MainActor
    struct Reader {
        let scope: String

        var titleMidX: CGFloat? { MastheadGeometry.worlds[scope]?.titleMidX }
        var contentMidX: CGFloat? { MastheadGeometry.worlds[scope]?.contentMidX }
        var pathChipFrame: CGRect? { MastheadGeometry.worlds[scope]?.pathChipFrame }
        var cardFrames: [String: CGRect] { MastheadGeometry.worlds[scope]?.cardFrames ?? [:] }
        var fieldFrame: CGRect? { MastheadGeometry.worlds[scope]?.fieldFrame }
        var titleFrame: CGRect? { MastheadGeometry.worlds[scope]?.titleFrame }
        var titleFieldFrame: CGRect? { MastheadGeometry.worlds[scope]?.titleFieldFrame }
        var titleLabelFrame: CGRect? { MastheadGeometry.worlds[scope]?.titleLabelFrame }
        var titleOpenMarkAppearances: Int {
            MastheadGeometry.worlds[scope]?.titleOpenMarkAppearances ?? 0
        }
        var iconRowFrame: CGRect? { MastheadGeometry.worlds[scope]?.iconRowFrame }
        var doorFrame: CGRect? { MastheadGeometry.worlds[scope]?.doorFrame }
        var stampFrames: [String: CGRect] { MastheadGeometry.worlds[scope]?.stampFrames ?? [:] }
        var reports: Int { MastheadGeometry.worlds[scope]?.reports ?? 0 }

        /// The one-window read, for a pin that mounted exactly one detail.
        var stampFrame: CGRect? { stampFrames.values.first }

        /// A pin resets the second row's frames before its mount, so a stale
        /// report from an earlier mount can never satisfy it — ITS OWN scope
        /// and no other.
        func resetRowTwo() {
            MastheadGeometry.worlds[scope]?.pathChipFrame = nil
            MastheadGeometry.worlds[scope]?.cardFrames = [:]
            MastheadGeometry.worlds[scope]?.fieldFrame = nil
            MastheadGeometry.worlds[scope]?.doorFrame = nil
            MastheadGeometry.worlds[scope]?.stampFrames = [:]
        }

        /// Row 80's pin resets the title row's frames the same way.
        func resetTitleRow() {
            MastheadGeometry.worlds[scope]?.titleMidX = nil
            MastheadGeometry.worlds[scope]?.titleFrame = nil
            MastheadGeometry.worlds[scope]?.titleFieldFrame = nil
            MastheadGeometry.worlds[scope]?.titleLabelFrame = nil
            MastheadGeometry.worlds[scope]?.titleOpenMarkAppearances = 0
            MastheadGeometry.worlds[scope]?.iconRowFrame = nil
        }

        /// Row 12's pin clears the two TITLE FACE frames alone, so the
        /// editing face's arrival is a fact rather than a leftover.
        func forgetTitleFaces() {
            MastheadGeometry.worlds[scope]?.titleFrame = nil
            MastheadGeometry.worlds[scope]?.titleFieldFrame = nil
        }
    }

    static func reader(_ scope: String) -> Reader { Reader(scope: scope) }
}
#endif
