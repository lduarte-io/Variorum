//
//  SidebarView.swift
//  Variorum
//
//  Phase 13, B2 — THE SIDEBAR, FINAL (R44, sitting 6): **Shelf · Library ·
//  Pool · Blocks.** The Journal folded INTO the shelf (R38); the Tags tab
//  DROPPED (R39/R45 — hierarchy stays surfaced in context + the Settings
//  manager, R52); Canvas off the sidebar (R40 — a view on a post/scraps);
//  Timeline folded into Library as a view mode (sitting 1). The Blocks
//  section keeps its scrap ROWS (drag-into-draft needs scrap and draft
//  visible together — the ratified Phase 10 reason survives the rename;
//  recorded build-time call). Voiced through the token layer.
//
//  ── THE ACT 10 CORRECTION ROUND, BATCH A (rows 2 · 3 · 24) — ONE FLAT
//     COLUMN, THE MOCKUP'S GRAMMAR ────────────────────────────────────────
//  The `List` is gone. W8-3 ruled the floating glass pane out and W8-2 made
//  `blocks-and-snippets.html` the style guide; Act 10 painted the List's
//  interior flat and moved the Open strip out of it to a bottom rail, and
//  she reported both halves of what that left: the pane's edge still
//  floated, and *"the tabs used to be right below the modes, and the tab
//  spacing has gotten less generous"*. So the column is now the mockup's
//  `.sidebar`: groups of rows at ONE pitch (`SidebarLayout` — generous at
//  ordinary heights, compact only when the generous layout would not fit),
//  a header where a group needs one, a 1 pt separator between groups, the
//  Starred rows at the top, the five areas, the "this note" rail — and
//  directly under the rail, the OPEN strip, back where her tabs were, with
//  every Act 10 mechanic intact: every open note shown, the section
//  scrolling in place past ~7 with the newcomer revealed, ⌘⇧1–9 badges, ✕
//  closes a row, drag to reorder, the model's 20-tab cap. The rail's
//  arrival and departure FADE (row 24's sidebar half — *"the appearance of
//  the 'this note' modes is just as jarring as it has been"*); nothing new
//  appears on the left (R-cor-3).
//
//  What the List gave and this does not: arrow-key row navigation inside
//  the sidebar. Recorded in the batch record rather than papered over.
//

import SwiftUI
import UniformTypeIdentifiers
import VariorumCore

/// What the shell can show; the detail pane switches on it.
///
/// **`nonisolated` (13f batch 3):** the target defaults to MainActor
/// isolation, which isolates a plain value enum's synthesized `Equatable`
/// too — and the navigation core's pure types (`NavigationHistory`,
/// `WorkspaceNaming`) compare destinations away from any actor, so they can
/// be pinned as the arithmetic they are. Nothing about a pair of strings
/// needs the main thread; the registry layer's own value types
/// (`CapabilityID` and friends) are declared exactly this way.
nonisolated enum SidebarSelection: Hashable {
    /// Home — the bookshelf (R38/R44).
    case shelf
    /// Everything, sortable and searchable (R32); timeline is a view mode.
    case library
    /// The bookless-posts surface (R29/R44).
    case poolPosts
    /// Batch 12 (her ruling — supersedes the rows-in-sidebar build-time
    /// call): Blocks is a 4TH AREA, not inline sidebar rows ("way too
    /// crowded"); standalone blocks are made THERE.
    case blocks
    /// **The FIFTH area** (the post-13l polish round, ledger row 8 — her B2
    /// direction: *"archived should be a different item on the left (like
    /// where library is, but it says archived)"*). Archived NOTES, kept
    /// forever, with their own search — deliberately apart from the Trash's
    /// countdown, which is R44's sidebar meeting the model's own
    /// archive/tombstone distinction (OverallModel §6) at last.
    case archived
    case post(String)
    case tag(String)
    case reading(String)
    /// A scraps container ("Blocks"), opened in the detail editor.
    case pool(String)
    /// The archived + deleted recovery surfaces (⌘K / Library-reachable).
    case recovery

    /// The container this destination OPENS IN A DETAIL SURFACE, if any —
    /// the thing her same-note rule is about (13f batch 4, round 7.3).
    ///
    /// A scraps container counts alongside a post deliberately: `.pool`
    /// opens `PoolDetailView`, so two panes on one pool would be two detail
    /// hosts on one container — the exact shape the rule forbids. The Open
    /// STRIP still tracks `.post` only (ratified round 7.2); that is a
    /// different question from what may be shown twice.
    var noteID: String? {
        switch self {
        case .post(let id), .pool(let id): return id
        case .shelf, .library, .poolPosts, .blocks, .archived, .recovery, .tag, .reading:
            return nil
        }
    }
}

struct SidebarView: View {
    /// The NOTE-ROW context menu's declared acts (P-1's walk). One grammar,
    /// three surfaces render it — the Open strip's rows here, the Library
    /// catalog's post rows, and the Pool's — all through the same shell
    /// callback, so one declaration covers the family.
    static let contextMenuCapabilities: [CapabilityID] = [
        .openBeside, .openInNewWindow,
        // 13f batch 6 (W4): the star door joins the note-row grammar, so
        // all three renderers get it from ONE declaration.
        .toggleStar,
        // 13l Act 2 (item 3): DELETE NOTE joins it — the Library's row and
        // the Pool's, which is where her ruling put the confirmation ("add a
        // confirmation for the library door of deletion"), and where the door
        // already lived without one.
        //
        // **The OPEN STRIP deliberately does not render it**, and that is a
        // decision rather than an omission: the strip is pure view state and
        // its own copy promises exactly that — "Close this row — the note
        // itself is untouched" — so putting a tombstoning act one row above
        // "Close" is the confusion that sentence exists to prevent. Her
        // ruling named the note menu and the library door; a third door is
        // hers to ask for.
        .deleteNote,
        // The post-13l polish round (ledger row 25): ARCHIVE joins the same
        // grammar and the same two renderers — the Library's rows and the
        // Pool's. The Open strip does not render it, for `.deleteNote`'s
        // reason written out above: the strip is pure view state, and a verb
        // that removes the note from her Library does not belong one row
        // above "Close".
        .archiveNote,
        // 13i-d U5: the cross-wing NOTE doors join the same grammar and the
        // same two renderers (the Library's rows and the Pool's) — Move to
        // Wing ▸ / Copy to Wing ▸ (the sitting record §9's "explicit move/copy
        // doors"). The Open strip does not render them (`.deleteNote`'s
        // reason above).
        .moveNoteToWing, .copyNoteToWing,
    ]

    /// **The OPEN LIST's own right-click acts** (VX-289, the VX-283 run) —
    /// beyond the shared note-row grammar above, which the Library's and the
    /// Pool's rows render too. Close All Notes is about the LIST, so only the
    /// list renders it (the walk's union carries this as its own line).
    static let openListMenuCapabilities: [CapabilityID] = [.closeAllNotes]

    /// The five areas, in R44's ruled order (+ Archived at the end, the
    /// post-13l polish round's addition). ONE table the column iterates —
    /// the row count the fit test reads is this table's count.
    struct Area: Hashable {
        let title: String
        let symbol: String
        let destination: SidebarSelection
    }

    static let areas: [Area] = [
        // 13i-d U1 — the section renamed BOOKCASE (the sitting record §7:
        // *"lets call that section bookcase and a shelf can stay shelves"*).
        Area(title: "Bookcase", symbol: "books.vertical", destination: .shelf),
        Area(title: "Library", symbol: "text.book.closed", destination: .library),
        Area(title: "Pool", symbol: "tray", destination: .poolPosts),
        // Batch 12: Blocks joins as the FOURTH AREA — R44's sidebar,
        // finally literal. The inline scrap rows are gone ("way too
        // crowded"); the area page holds them.
        Area(title: "Snippets", symbol: "square.on.square", destination: .blocks),
        // Ledger row 8 (B2): ARCHIVED, after the four — her direction's
        // letter ("a different item on the left, like where library is").
        // It sits at the END of the standing group deliberately: Shelf ·
        // Library · Pool · Snippets is R44's ruled order and this is an
        // addition to it, not a re-ranking of it.
        Area(title: RecoveryPath.archivedSurface, symbol: "archivebox", destination: .archived),
    ]

    let session: AppSession
    let model: LibraryViewModel
    let pool: PoolViewModel
    /// 13f batch 3 (W3/A27, her ruling: *"i'd use the free space that's
    /// underneath 'library / shelf / pool / blocks' for now"*) — the
    /// window's OPEN notes render as their own group, directly under the
    /// contextual "this note" rail (the correction round put them back
    /// there — her "tabs used to be right below the modes").
    let workspace: WorkspaceModel
    /// 13f batch 6 (W4, her round-3 ruling): the STARRED section at the
    /// sidebar's top. Store state, not window state — it is synced and both
    /// windows show the same five.
    let stars: StarsModel
    /// The star door, for this view's note rows AND its Starred rows.
    var starDoor: StarDoor?
    /// 17y B3 item (l): the Starred section's BOOK rows render the book row
    /// menu (`BookRowMenu`); the composition root owns its brain. nil (a
    /// harness mount) keeps the plain Star/Unstar menu.
    var bookRowDoors: BookRowDoors? = nil
    @Binding var selection: SidebarSelection?
    /// 13f batch 4 (W1/A25): "Open Beside" on an Open-strip row — the
    /// split's door where the window's open notes already live.
    var onOpenBeside: ((String) -> Void)?
    /// 13f batch 5b (W2/A26): "Open in New Window" — the lightweight
    /// note-only window, from the same note-row menu as Open Beside.
    var onOpenInNewWindow: ((String) -> Void)?
    /// Batch 14: the open post's current mode (the rail's › marker) —
    /// broadcast by PostDetailView, tracked by the shell.
    var postMode: String = PostDetailView.Mode.takes.rawValue
    /// **THE NOTE BOX** (18d batch 1, her U-10) — built by `RootView` from
    /// the book's published ids and the registered live editor, and handed
    /// here as a view to RENDER. The sidebar never constructs or holds the
    /// book's `EditorViewModel`; rendering a sibling's view is legal
    /// composition (CLAUDE.md's P39 refinement), and this parameter is the
    /// seam that keeps it so. nil ⇒ no book in an editing mode: the column
    /// is exactly what it was.
    var noteBox: AnyView? = nil
    /// The column's BOTTOM — the protection/sync status rows, which
    /// `RootView` composes (they read services it owns) and hands in. They
    /// were the split view's `safeAreaInset`; with the flat `ShellSplit`
    /// they are the column's own last region, above nothing.
    var bottom: AnyView? = nil
    @Environment(ThemeStore.self) private var theme
    @Environment(\.colorScheme) private var scheme
    /// Phase 11b (B2): the drop-in import model, created on first drop.
    @State private var importer: ImportModel?
    /// The column's height, as laid out — the fit test's input
    /// (`SidebarLayout`). Zero on the first pass, which never compresses.
    @State private var columnHeight: CGFloat = 0
    /// **VX-285's two measurements** — the Open list's height is a pure
    /// function of them (`SidebarLayout.openListMaxHeight`): the outer
    /// scroll's VISIBLE height (the column above the sync footer) and where
    /// the list's top sits in the column's content. Both zero until geometry
    /// lands, which answers the list's floor.
    @State private var columnScrollHeight: CGFloat = 0
    @State private var openListTop: CGFloat = 0
    /// The column content's named space (VX-285): where `openListTop` is read.
    private nonisolated static let columnContentSpace = "sidebar.column.content"
    /// 17y B3 item (f): the Open rows living in ANOTHER wing → that wing's
    /// name (the indicator). Read once per (rows, current wing) — bounded by
    /// the Open list.
    @State private var openRowWings: [String: String] = [:]
    #if DEBUG
    /// **This column's own name in the DEBUG oracle** (18k UNIT C4 — the
    /// `MastheadStamp.oracleOwner` shape): it owns the rail's drawn height.
    @State private var oracleOwner = UUID()
    #endif

    struct TagSheetTarget: Identifiable {
        let id: String
        let title: String?
    }

    private var tokens: VoiceTokens { theme.tokens(for: scheme) }

    /// The note whose rail is showing, if any — the rail's presence AND the
    /// value the fade animates on.
    private var railPostID: String? {
        if case .post(let postID) = selection { return postID }
        return nil
    }

    /// The rail's rows — and, for a book, the note BOX's, because the box
    /// stands in the rail's place AT the rail's height (18d batch 1). The
    /// column must budget it identically or it would fail to compress with a
    /// book open exactly where it compresses with a note open, and the drift
    /// would be silent (row 13's own lesson).
    private var railEquivalentRows: Int {
        railPostID == nil && noteBox == nil ? 0 : PostDetailView.Mode.allCases.count
    }

    /// The height the rail group draws at — and the frame the box takes.
    private var railGroupHeight: CGFloat {
        SidebarLayout.railGroupHeight(
            rowHeight: rowHeight, railRows: PostDetailView.Mode.allCases.count)
    }

    /// Every row the column is about to draw, for the fit test.
    private var rowCount: Int {
        SidebarLayout.rowCount(
            starred: stars.items.count, areas: Self.areas.count,
            rail: railEquivalentRows,
            openNotes: workspace.openNotes.shown.count)
    }

    /// The headed groups the column is about to draw (ladder R1-12: the
    /// fit test counts the chrome actually present).
    private var headedGroupCount: Int {
        (stars.items.isEmpty ? 0 : 1) + (railEquivalentRows == 0 ? 0 : 1)
            + (workspace.openNotes.shown.isEmpty ? 0 : 1)
    }

    private var rowHeight: CGFloat {
        SidebarLayout.rowHeight(
            columnHeight: columnHeight, rows: rowCount, headedGroups: headedGroupCount)
    }

    /// VX-285: the Open list's tallest form — the room down to the sync
    /// footer, from the two measurements above.
    private var openListMaxHeight: CGFloat {
        SidebarLayout.openListMaxHeight(
            visibleHeight: columnScrollHeight, listTop: openListTop,
            bottomPadding: SidebarLayout.contentBottomPadding, rowHeight: rowHeight)
    }

    var body: some View {
#if DEBUG
        // The round-end Fable pass, MAJOR-1's oracle: how many times THIS
        // column's body has run, keyed by the workspace it renders (a pin's
        // window has its own). Counted INSIDE the evaluation — `.onAppear`
        // or a geometry report would count mounts and layouts, not bodies.
        let _ = SidebarGeometry.noteBodyEvaluation(for: workspace)
        // VX-141's oracle: what the rail's SLOT holds on this pass.
        let _ = SidebarGeometry.noteSlotOccupant(
            railPostID != nil ? .rail : (noteBox != nil ? .box : .empty), for: workspace)
#endif
        VStack(spacing: 0) {
            // The groups. An outer scroll is the LAST resort for a window
            // shorter than even the compact layout — inert at ordinary
            // sizes (`basedOnSize`), so the column reads as one flat room
            // and the Open strip's own scroll is the only one that moves.
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    starredGroup
                    areasGroup
                    if let railPostID {
                        railGroup(railPostID)
                            .transition(.opacity)
                    } else if let noteBox {
                        // 18d batch 1: a BOOK in an editing mode stands the
                        // note box exactly where the rail stands, at the
                        // rail's height — so the Open strip below never moves
                        // between a note and a book (her U-10's "measured to
                        // take up the same amount of room"). It fades in and
                        // out on the rail's own beat, `SidebarLayout.
                        // railTransition` (row 24's sidebar half: nothing on
                        // the left ever snaps).
                        noteBoxGroup(noteBox)
                            .transition(.opacity)
                    }
                    openGroup
                }
                .padding(.top, SidebarLayout.topPadding)
                .padding(.bottom, SidebarLayout.contentBottomPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                // VX-285: the column content's own space — the Open list's
                // top is read here, unmoved by the outer scroll's offset.
                .coordinateSpace(.named(Self.columnContentSpace))
            }
            .scrollBounceBehavior(.basedOnSize)
            // VX-285's first measurement: the outer scroll's VISIBLE height —
            // everything above the sync footer (which sits outside it, below).
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: {
                columnScrollHeight = $0
            }
            #if DEBUG
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { frame in
                SidebarGeometry.columnScrollFrames[SidebarGeometry.bodyKey(for: workspace)] = frame
            }
            #endif
            if let bottom {
                Divider().overlay(tokens.line)
                bottom
            }
        }
        .background(tokens.room)
        // 13s-b U2 (A2): the tour's cards never cover the sidebar's navigation.
        .tourKeepClear()
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { columnHeight = $0 }
        #if DEBUG
        // 18k C4: this column's rail, and no other window's.
        .onDisappear { SidebarGeometry.release(owner: oracleOwner) }
        #endif
        // Row 24 (the sidebar half): the rail fades in and out with the
        // note — the groups below it slide, nothing snaps.
        .animation(.easeInOut(duration: SidebarLayout.railTransition), value: railPostID)
        // …and on the box's arrival and departure, for the same reason.
        .animation(.easeInOut(duration: SidebarLayout.railTransition), value: noteBox == nil)
        // The strip's names, HELD for exactly what is on screen (17o batch
        // d, ledger row 18 — her *"renaming a note won't rename it on the
        // sidebar until you click on something else"*). The key still names
        // the subjects, so the observation restarts on every navigation; a
        // RENAME changes no key, which is precisely why the one-shot could
        // not see it. The fetch is bounded by the subjects, so this stays a
        // viewport-shaped observation and not a corpus-shaped one.
        .task(id: workspace.titleSubjectsKey) {
            await workspace.observeTitles(session: session)
        }
        // The library import door (Phase 11b, B2): drop `.md`/plain text
        // anywhere on the sidebar → new post(s). The Blocks rows carry
        // their own, deeper drop target, so a drop there lands as scraps.
        // (The Open strip's row reorder rides its OWN transfer type, so a
        // dragged row can never be mistaken for droppable text.)
        .onDrop(of: [.fileURL, .plainText], isTargeted: nil) { providers in
            let model = importer ?? ImportModel(session: session)
            importer = model
            return model.handleDrop(providers, into: .library)
        }
        .overlay(alignment: .bottom) {
            if let error = model.lastError ?? importer?.lastError {
                Text(error)
                    .font(tokens.small)
                    .alarmVoice()
                    .textSelection(.enabled)
                    .padding(4)
            } else if let status = importer?.lastReport {
                Text(status)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .textSelection(.enabled)
                    .padding(4)
            }
        }
    }

    // MARK: - The grammar (the mockup's `.sb-group` / `.sb-head` / `.sb-row` / `.sb-sep`)

    // (The three grammar numbers — `groupPadding`, `rowPadding` and
    //  `headerAir` — moved to `SidebarLayout` at the 18d ladder's MINOR-7,
    //  where the fit math already lives, so the note box in `Core/Views/`
    //  reads the layout BRAIN rather than this feature's view. These are
    //  private aliases: this file's own call sites keep reading two words.)
    private static var groupPadding: CGFloat { SidebarLayout.groupPadding }
    private static var rowPadding: CGFloat { SidebarLayout.rowPadding }

    /// **VX-286 — where a scrolling section's side margin lives: INSIDE its
    /// scroll view.** Her words (2026-10-13): *"the scroll bar on there goes
    /// over the x out button"* · *"the tab close x gets hidden behind the
    /// scroll"*. The traced mechanism: macOS draws an OVERLAY scroll bar over
    /// the scroll view's own trailing edge, and both scrolling sections
    /// (Starred, the Open list) took the group's `groupPadding` OUTSIDE their
    /// scroll view — so the scroll view's trailing edge was the rows' own,
    /// and the bar landed on the last thing in each row: the Open list's ✕
    /// (8 pt in) and Starred's ★. With the margin as the scroll CONTENT's
    /// padding, the scroll view spans the column and the bar rides in the
    /// margin beside the rows. The rows land exactly where they did — same
    /// edge, same width — which is why this is the group's own number.
    private static var scrollingSectionMargin: CGFloat { SidebarLayout.groupPadding }

    /// Row 13 (17o batch d): the header ROW's pitch, and the air between the
    /// words and the first row's wash. Her punchlist 3 and its follow-up:
    /// *"the highlight on the mode you're in and the words 'this note' or
    /// 'open' is very close to touching and the items in that pane should
    /// all be aligned."*
    /// ONE truth with the fit math: the column budgets `groupHeaderHeight`
    /// for each headed group, so the header draws exactly that.
    private static var headerHeight: CGFloat { SidebarLayout.groupHeaderHeight }
    private static var headerAir: CGFloat { SidebarLayout.headerAir }

    /// A group header — small, in the accent (the voice's own header
    /// register, kept from the List), sitting on the rows' text edge.
    ///
    /// **Row 13, both halves.** The header padded `groupPadding + rowPadding`
    /// while sitting INSIDE `railGroup`/`openGroup`/`starredGroup`, which
    /// already pad `groupPadding` — so its words landed 12 pt inboard of the
    /// row text beside them ("this note" adrift from Write · Takes …, "Open"
    /// from the tabs). A header inside a padded group pads `rowPadding`
    /// ONLY, which puts it on exactly the edge `rowChrome` gives its
    /// content. And its 22-pt box, with the text bottom-aligned and nothing
    /// under it, left the words touching the first row's wash; the row is
    /// now the column's own 30-pt pitch with `headerAir` below the words.
    private func header(_ title: String) -> some View {
        Text(tokens.chromeLabel(title))
            .font(tokens.small)
            .foregroundStyle(tokens.accent)
            .lineLimit(1)
            #if DEBUG
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                SidebarGeometry.recordHeaderText(title, $0, in: session.debugProbeScope)
            }
            #endif
            .padding(.horizontal, Self.rowPadding)
            .padding(.bottom, Self.headerAir)
            .frame(height: Self.headerHeight, alignment: .bottomLeading)
    }

    /// The mockup's `.sb-sep`: one 1 pt line with side margins and air.
    private var separator: some View {
        Rectangle()
            .fill(tokens.line)
            .frame(height: 1)
            .padding(.horizontal, 20)
            .padding(.vertical, 9)
    }

    /// The `›` idiom (R1): the selected row's label wears the voice's
    /// marker in the ACCENT color; unselected rows carry none. Study's
    /// marker is empty, so this is Terminal's alone.
    @ViewBuilder
    private var marker: some View {
        if !tokens.selectionMarker.isEmpty {
            Text(tokens.selectionMarker.trimmingCharacters(in: .whitespaces))
                .font(tokens.navigation)
                .fontWeight(.bold)
                .foregroundStyle(tokens.accent)
        }
    }

    /// One row's chrome: the row's padding, ONE height for the whole
    /// column, the wash when selected (the `.sb-row.sel` grammar — never a
    /// hairline highlight), the whole row a target.
    private func rowChrome<Content: View>(
        selected: Bool, @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(.horizontal, Self.rowPadding)
            .frame(height: rowHeight)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                selected ? AnyShapeStyle(tokens.wash) : AnyShapeStyle(Color.clear),
                in: RoundedRectangle(cornerRadius: 6))
            .contentShape(Rectangle())
    }

    /// A row's title, in the column's one register: ink + semibold when
    /// selected, muted otherwise.
    private func rowTitle(_ title: String, selected: Bool) -> some View {
        Text(tokens.chromeLabel(title))
            .font(tokens.navigation)
            .fontWeight(selected ? .semibold : .regular)
            .foregroundStyle(selected ? tokens.ink : tokens.muted)
            .lineLimit(1)
            .truncationMode(.tail)
    }

    // MARK: - Starred (13f batch 6, W4)

    /// 13f batch 6 (W4) — the STARRED section, at the sidebar's TOP (her
    /// ruling's placement). A click navigates through the shell's own
    /// selection and the `›` marker lands on the current one. It renders
    /// only when something is starred, so an unused feature costs no chrome.
    ///
    /// **Act 10 item 13 (her screenshot showed TWO stars, one each side):
    /// exactly ONE star — the blue one, on the RIGHT** (her lean, confirmed
    /// in place: the right star is also the un-star door, so the mark and
    /// the act live in one spot). Long titles show an ellipsis at rest and
    /// marquee-scroll on hover ("stereo style" — `MarqueeText`).
    /// **13u2 item 10 — her words, verbatim:** *"I'm fine with where starred
    /// items are on the mac but make sure in 13u that it says that starred
    /// items should only show up to like 7 items and then it should start
    /// scrolling."* PLACEMENT IS UNCHANGED (she said so); what changes is
    /// that past the ruled window the SECTION scrolls in place instead of
    /// growing without bound — the Open strip's shape exactly, through the
    /// same `SidebarLayout.scrollingSectionWindow`. (Act 10 item 9 already
    /// called that window "the starred precedent's ~7"; the precedent did
    /// not exist until now, which is what she noticed.)
    ///
    /// The CURRENT row is revealed when the selection lands on a starred
    /// target, so navigating to an eighth starred note never leaves its row
    /// hidden — the strip's own newcomer-reveal reasoning. **Since U1b (the
    /// VX-283 run)** that reveal is the shared `SidebarSectionWindow`'s: clear
    /// of the edge fades both sections now draw (F-2), and again whenever the
    /// section's height changes (F-1's mechanism).
    @ViewBuilder
    private var starredGroup: some View {
        let items = stars.items
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                header(StarCopy.sectionHeader)
                    // VX-286: the group's side margin moved off the group (see
                    // `scrollingSectionMargin`), so the header carries its own.
                    .padding(.horizontal, Self.groupPadding)
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(items, id: \.target) { item in
                            starredRow(item, first: item.target == items.first?.target)
                                .id(item.target)
                        }
                    }
                    .padding(.horizontal, Self.scrollingSectionMargin)
                }
                .scrollBounceBehavior(.basedOnSize)
                #if DEBUG
                // U1b's oracle: the section's window over its rows.
                .onScrollGeometryChange(for: SidebarLayout.ScrollWindow.self) {
                    SidebarLayout.ScrollWindow($0)
                } action: { _, window in
                    SidebarGeometry.recordSection(.starred, window: window, for: workspace)
                }
                #endif
                // U1b (F-2, P-U1-6; F-1's reveal, P-U1b-6): the section's
                // window — the edges fade where more lies beyond them, and the
                // CURRENT row is revealed clear of the fades at an exact
                // offset on every input that moves its place. It replaces the
                // minimal `scrollTo` on a selection change that stood here
                // (inside a `ScrollViewReader`, now gone — nothing else used
                // the proxy).
                .modifier(SidebarSectionWindow(
                    rows: items.map(\.target),
                    current: items.first {
                        StarTargeting.selection(for: $0.target) == selection
                    }?.target,
                    rowHeight: rowHeight, room: tokens.room,
                    report: sectionReport(.starred)))
                .frame(maxHeight: SidebarLayout.scrollingSectionMaxHeight(rowHeight: rowHeight))
                .fixedSize(
                    horizontal: false,
                    vertical: items.count <= SidebarLayout.scrollingSectionWindow)
                #if DEBUG
                // Item 10's oracle: what the SECTION actually drew,
                // keyed by the column's own workspace (the DEBUG-oracle
                // keying rule — suites run in parallel, and a singleton
                // here would let another suite's column answer the pin).
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height in
                    SidebarGeometry.starredSectionHeights[
                        SidebarGeometry.bodyKey(for: workspace)] = height
                }
                // VX-286's oracle: the section's scroll view as drawn —
                // where its overlay scroll bar rides.
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { frame in
                    SidebarGeometry.recordSection(.starred, scroll: frame, for: workspace)
                }
                #endif
            }
            // (VX-286: the `.padding(.horizontal, groupPadding)` that stood
            //  here put the margin OUTSIDE the scroll view — it moved inside.)
            // 17y B3 item (l): the starred books' facts (≤ the star cap) and
            // what their row menus present.
            .task(id: starredBookIDs) { await bookRowDoors?.load(starredBookIDs) }
            .modifier(OptionalBookRowDoorsHost(doors: bookRowDoors))
            separator
        }
    }

    /// The Starred section's BOOK ids, in star order (≤ the cap — P1).
    private var starredBookIDs: [String] {
        stars.items.filter { $0.target.kind == .reading }.map(\.target.id)
    }

    private func starredRow(_ item: Queries.StarredItem, first: Bool) -> some View {
        let destination = StarTargeting.selection(for: item.target)
        let current = selection == destination
        return rowChrome(selected: current) {
            HStack(spacing: 4) {
                if current { marker }
                MarqueeText(
                    text: tokens.chromeLabel(WorkspaceNaming.label(
                        for: destination, titles: stars.titles)),
                    font: tokens.navigation,
                    color: current ? tokens.ink : tokens.muted,
                    weight: current ? .semibold : .regular)
                if let starDoor {
                    // THE one star: blue, on the right — and it is the
                    // un-star door (her ruling: "un-star anywhere").
                    Button(StarCopy.glyph) { starDoor.toggle(item.target) }
                        .buttonStyle(.plain)
                        .font(tokens.small)
                        .foregroundStyle(tokens.star)
                        .help(StarCopy.rowHelp)
                } else {
                    Text(StarCopy.glyph)
                        .font(tokens.small)
                        .foregroundStyle(tokens.star)
                }
            }
        }
        #if DEBUG
        // VX-286's oracle: the first row's box — the ★ sits at its trailing end.
        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { box in
            if first { SidebarGeometry.recordSection(.starred, firstRow: box, for: workspace) }
        }
        #endif
        .onTapGesture { selection = destination }
        .contextMenu {
            // 17y B3 item (l): a starred BOOK's row carries the book row menu
            // (the Bookcase's, trimmed of position); a note keeps its star.
            if item.target.kind == .reading, let bookRowDoors {
                BookRowMenu(
                    readingID: item.target.id, doors: bookRowDoors, starDoor: starDoor,
                    open: { selection = destination })
            } else if let starDoor {
                Button(starDoor.title(for: item.target)) {
                    starDoor.toggle(item.target)
                }
            }
        }
    }

    // MARK: - The five areas (R44)

    private var areasGroup: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Self.areas, id: \.self) { area in
                let current = selection == area.destination
                Button {
                    selection = area.destination
                } label: {
                    rowChrome(selected: current) {
                        HStack(spacing: 6) {
                            Image(systemName: area.symbol)
                                .font(tokens.navigation)
                                .foregroundStyle(current ? tokens.accent : tokens.muted)
                                .frame(width: 18)
                            // Batch 7/8 (her audit: "there's no little › to
                            // show the way … it being a color ›") — the R1
                            // selection-marker idiom: the selected row alone
                            // wears the voice's marker, in the ACCENT color.
                            if current { marker }
                            rowTitle(area.title, selected: current)
                        }
                    }
                }
                .buttonStyle(.plain)
                // 13s-b U2: each place is a door the tour can point at (step
                // 10's "Bookcase in the sidebar heads home", and the road back
                // whenever she wanders off).
                .tourAnchor(.sidebarArea(Self.tourArea(area.destination)), cornerRadius: 6)
            }
        }
        // 13s-b U2: step 1 rings the five places as one group.
        .tourAnchor(.sidebarAreas)
        .padding(.horizontal, Self.groupPadding)
    }

    /// 13s-b U2: a place's name in the tour's vocabulary (the five areas
    /// only — the table above is all this is ever asked about).
    static func tourArea(_ destination: SidebarSelection) -> Tour.Area {
        switch destination {
        case .library: .library
        case .poolPosts: .pool
        case .blocks: .snippets
        case .archived: .archived
        default: .bookcase
        }
    }

    // MARK: - "this note" — the mode rail (batch 14's ruling)

    /// Batch 14 (her ruling — supersedes the bottom mode line): the post
    /// MODES live here, "in the same verticle pane as shelf / library /
    /// pools, but with a separator so it's clear that it's only for when
    /// you're within a post." The separator is the mockup's `.sb-sep`.
    private func railGroup(_ postID: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            separator
            VStack(alignment: .leading, spacing: 0) {
                header("this note")
                ForEach(PostDetailView.Mode.allCases, id: \.self) { m in
                    let current = m.rawValue == postMode
                    Button {
                        // 13b 1b (P-4): composed routing — the rail asks
                        // the router, which reaches the mounted detail (or
                        // speaks; never a dropped broadcast).
                        session.commandRouter.requestMode(m, postID: postID)
                    } label: {
                        rowChrome(selected: current) {
                            HStack(spacing: 4) {
                                if current { marker }
                                Text(tokens.chromeLabel(m.rawValue))
                                    .font(tokens.navigation)
                                    .fontWeight(current ? .semibold : .regular)
                                    .foregroundStyle(current ? tokens.accent : tokens.muted)
                                    .lineLimit(1)
                            }
                            #if DEBUG
                            // Row 13's oracle: the FIRST row's content edge —
                            // what the header above it must sit on.
                            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                                if m == PostDetailView.Mode.allCases.first {
                                    SidebarGeometry.recordFirstRowContent(
                                        "this note", $0, in: session.debugProbeScope)
                                }
                            }
                            #endif
                        }
                        #if DEBUG
                        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { box in
                            if m == PostDetailView.Mode.allCases.first {
                                SidebarGeometry.recordFirstRowBox(
                                    "this note", box, in: session.debugProbeScope)
                            }
                        }
                        #endif
                    }
                    .buttonStyle(.plain)
                    .help("\(m.rawValue) (⌘\((PostDetailView.Mode.allCases.firstIndex(of: m) ?? 0) + 1))")
                    // 13s-b U2: step 8 points at Lenses; steps 4–5 at Write.
                    .tourAnchor(.sidebarMode(TourPlaces.mode(m)), cornerRadius: 6)
                }
            }
            .padding(.horizontal, Self.groupPadding)
            #if DEBUG
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height in
                SidebarGeometry.recordRail(postID, height, owner: oracleOwner)
            }
            #endif
        }
    }

    // MARK: - "this note" — the BOX (18d batch 1, her U-10)

    /// The box's group: the rail's separator, then the box at the rail's
    /// height, inside the same `groupPadding` the rail's rows sit in. The
    /// box carries its own header (mockup figure C), which is why nothing
    /// draws one here — and why the column's chrome budget counts this group
    /// as a headed one exactly as it counts the rail.
    private func noteBoxGroup(_ box: AnyView) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            separator
            box
                .frame(height: railGroupHeight)
                .padding(.horizontal, Self.groupPadding)
        }
    }

    // MARK: - The OPEN strip (13f batch 3, W3/A27; rebuilt Act 10 item 9; placed back here by the correction round)

    /// **The reorder payload** — its own transfer type, deliberately not a
    /// plain String: the sidebar's whole surface is a `.plainText` import
    /// drop target, and a dragged row's id must never be importable as a
    /// note's text.
    struct OpenNoteDragToken: Codable, Transferable {
        let noteID: String
        static var transferRepresentation: some TransferRepresentation {
            CodableRepresentation(
                contentType: UTType(exportedAs: "io.lduarte.variorum.open-note-row"))
        }
    }

    /// 13f batch 3 (W3/A27) — the OPEN strip. **Act 10 item 9 rebuilt it:**
    /// it shows EVERY open note (the model's prefix window is gone — a newly
    /// opened note can no longer land hidden), and past ~7 rows the SECTION
    /// scrolls in place (her ruled shape, the starred precedent) with the
    /// newcomer auto-revealed. ⌘⇧1…9 still reach the first nine rows, whose
    /// badges say so; the ✕ closes a ROW and nothing else (closing never
    /// deletes — pure view state); drag a row to reorder (her round-7.1
    /// ruling — a gesture, never a setting; since VX-139 the arrangement
    /// rides the remembered strip across launches — via the strip's own
    /// transfer type). **The correction round
    /// (row 3) moved it back UNDER THE RAIL** — its rows at the column's one
    /// pitch — where her tabs were before Act 10 sent them to the bottom.
    @ViewBuilder
    private var openGroup: some View {
        let shown = workspace.openNotes.shown
        if !shown.isEmpty {
            separator
            // VX-285: the list's tallest form is the room left above the sync
            // footer (`SidebarLayout.openListMaxHeight`), read once per pass.
            let maxHeight = openListMaxHeight
            VStack(alignment: .leading, spacing: 0) {
                header(WorkspaceNaming.openSectionHeader)
                    // VX-286: the header carries the group's margin itself now.
                    .padding(.horizontal, Self.groupPadding)
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(shown, id: \.self) { noteID in
                            openRow(noteID, ordinal: (shown.firstIndex(of: noteID) ?? 99) + 1)
                                .id(noteID)
                        }
                    }
                    // VX-286: the margin INSIDE the scroll, so the overlay
                    // scroll bar rides beside the ✕, never over it.
                    .padding(.horizontal, Self.scrollingSectionMargin)
                }
                .scrollBounceBehavior(.basedOnSize)
                #if DEBUG
                // U1b's oracle: the list's window over its rows.
                .onScrollGeometryChange(for: SidebarLayout.ScrollWindow.self) {
                    SidebarLayout.ScrollWindow($0)
                } action: { _, window in
                    SidebarGeometry.recordSection(.open, window: window, for: workspace)
                }
                #endif
                // U1b (F-1 + F-2): the list's window — the CURRENT row
                // wholly in view, clear of the fades, after an open, a
                // ⌘⇧W/✕ landing, a return from a place, and every change
                // of the viewport, the content height or the pitch (the
                // traced cut: the old reveal ran once, against a viewport
                // that settled a pass later); the edges fade where more lies
                // beyond them. (The `ScrollViewReader` that held the old
                // reveal's proxy is gone — nothing else used it.)
                .modifier(SidebarSectionWindow(
                    rows: shown, current: currentOpenRow,
                    rowHeight: rowHeight, room: tokens.room,
                    report: sectionReport(.open)))
                .frame(maxHeight: maxHeight)
                // VX-285: hug the rows while they FIT the room; past it,
                // take the room and scroll in place (the `count <= 7`
                // switch asked only about the old window).
                .fixedSize(
                    horizontal: false,
                    vertical: SidebarLayout.openListRowsFit(
                        rows: shown.count, rowHeight: rowHeight, maxHeight: maxHeight))
                // VX-285's second measurement: where the list STARTS in
                // the column's content. Nothing above it depends on the
                // list's own height, so this can never feed back.
                .onGeometryChange(for: CGFloat.self) {
                    $0.frame(in: .named(Self.columnContentSpace)).minY
                } action: { openListTop = $0 }
                #if DEBUG
                // VX-285/286's oracle: the list's scroll view as drawn.
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { frame in
                    SidebarGeometry.recordSection(.open, scroll: frame, for: workspace)
                }
                #endif
                // (U1b: the newcomer reveal that stood here — one minimal
                //  `scrollTo` when `recency.first` changed — is the
                //  section window's current-row reveal above. Every open
                //  takes the pane's focus, so the newcomer IS the current
                //  row; and a return to the note already newest, which
                //  never changed `recency.first`, now reveals too.)
            }
            // (VX-286: the `.padding(.horizontal, groupPadding)` that stood
            //  here put the margin OUTSIDE the scroll view — it moved inside.)
            // 17y (f): which open notes live in another wing (the indicator).
            .task(id: openWingsKey) {
                let ids = workspace.openNotes.shown
                let current = session.wing.currentID
                openRowWings = (try? await session.database.read { db in
                    try WingFollow.crossWingNames(db, noteIDs: ids, current: current)
                }) ?? [:]
            }
        }
    }

    /// **The ✕'s and right-click ▸ Close's ONE act** (VX-287 — her ruling at
    /// U1's READY, *"Yes, same as ⇧⌘W"*). The workspace closes the row and
    /// names where the FOCUSED pane lands when it was showing that note
    /// (`WorkspaceModel.closeRow`); the landing enters the shell through the
    /// column's own navigation road — the selection binding, whose setter is
    /// `RootView.adopt(_, in: focusedPane)`, the very call `pendingSelection`'s
    /// adoption makes (⌘⇧W's road) — so no new landing authority and no
    /// `ShellRouter.swift` edit. A row no pane shows just closes, as before.
    /// Static so a pin drives exactly what the two doors run.
    static func closeRow(
        _ noteID: String, in workspace: WorkspaceModel, selection: Binding<SidebarSelection?>
    ) {
        if let landing = workspace.closeRow(noteID) { selection.wrappedValue = landing }
    }

    /// The ✕'s help: still view-only, and now says where closing the note
    /// you're in takes you.
    static let closeRowHelp =
        "Close this row — the note itself is untouched (closing the note you're in moves you on to the next)"

    /// The indicator's read key: the rows shown and the wing she stands in.
    private var openWingsKey: String {
        workspace.openNotes.shown.joined(separator: ",") + "|" + session.wing.currentID
    }

    /// U1b (F-1): the Open row of the note the pane shows — the highlighted
    /// row, which the list keeps wholly in view. nil on a place, a book, a
    /// scraps container, or a note shown without a row.
    private var currentOpenRow: String? {
        guard case .post(let noteID) = selection,
              workspace.openNotes.shown.contains(noteID) else { return nil }
        return noteID
    }

    /// U1b: the DEBUG oracle's tap for the fades a scrolling section drew (nil
    /// in a shipping build).
    private func sectionReport(_ section: SectionName) -> SidebarSectionWindowReport? {
        #if DEBUG
        let workspace = workspace
        let named: SidebarGeometry.ScrollingSection = section == .open ? .open : .starred
        return { fades in SidebarGeometry.recordSection(named, fades: fades, for: workspace) }
        #else
        return nil
        #endif
    }

    /// The two scrolling sections, by name (the oracle's own enum is DEBUG-only).
    private enum SectionName { case starred, open }

    private func openRow(_ noteID: String, ordinal: Int) -> some View {
        let destination = SidebarSelection.post(noteID)
        let current = selection == destination
        return rowChrome(selected: current) {
            HStack(spacing: 4) {
                if current { marker }
                MarqueeText(
                    text: tokens.chromeLabel(workspace.label(for: destination)),
                    font: tokens.navigation,
                    color: current ? tokens.ink : tokens.muted,
                    weight: current ? .semibold : .regular)
                // 17y B3 item (f) — THE WING INDICATOR (her ruled shape): a
                // row whose note lives in ANOTHER wing names that wing,
                // faint (her name for it — never chrome); opening it takes
                // the app there (`WingFollow`). PROVISIONAL P-17y-B3-f4.
                if let wing = openRowWings[noteID] {
                    Text(wing)
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .help(WingFollow.indicatorHelp(wing))
                }
                // The ordinal its key carries — so ⌘⇧n is legible without
                // opening a menu. Insertion-ordered (her round-7 ruling), so
                // the number is a STABLE address; rows past nine are
                // click/scroll rows and carry none.
                if ordinal <= OpenNotes.ordinalCap {
                    Text(tokens.chromeLabel("\u{2318}\u{21e7}\(ordinal)"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                        .lineLimit(1)
                }
                // Her ruling at U1's READY: on the note you're looking at, the
                // ✕ behaves like ⌘⇧W (the pane moves on) — `Self.closeRow`.
                Button("\u{2715}") { Self.closeRow(noteID, in: workspace, selection: $selection) }
                    .buttonStyle(.plain)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .help(Self.closeRowHelp)
            }
            #if DEBUG
            // Row 13's oracle: the FIRST strip row's content edge — what the
            // "Open" header above it must sit on.
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                if ordinal == 1 {
                    SidebarGeometry.recordFirstRowContent(
                        WorkspaceNaming.openSectionHeader, $0, in: session.debugProbeScope)
                }
            }
            #endif
        }
        #if DEBUG
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height in
            SidebarGeometry.recordOpenRowHeight(height, in: session.debugProbeScope)
        }
        .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { box in
            if ordinal == 1 {
                SidebarGeometry.recordFirstRowBox(
                    WorkspaceNaming.openSectionHeader, box, in: session.debugProbeScope)
                // VX-286's oracle: the ✕ sits at this box's trailing end.
                SidebarGeometry.recordSection(.open, firstRow: box, for: workspace)
            }
        }
        #endif
        .onTapGesture { selection = destination }
        // 13s-b U2: the leg's first stop points at her note's row (its
        // right-click carries Star). Inside the strip's own scroll, so the
        // ring sits on the row's edge rather than outside it.
        .tourAnchor(.sidebarOpenRow(noteID), cornerRadius: 6, outset: 0)
        .draggable(OpenNoteDragToken(noteID: noteID))
        .dropDestination(for: OpenNoteDragToken.self) { tokens, _ in
            guard let dragged = tokens.first?.noteID, dragged != noteID,
                  let source = workspace.openNotes.shown.firstIndex(of: dragged),
                  let target = workspace.openNotes.shown.firstIndex(of: noteID)
            else { return false }
            // Drop-before-target, in the onMove convention (pre-move index).
            workspace.moveOpenNotes(fromOffsets: IndexSet(integer: source), toOffset: target)
            return true
        }
        .contextMenu {
            if let onOpenBeside {
                Button(WorkspaceNaming.openBesideVerb) { onOpenBeside(noteID) }
            }
            if let onOpenInNewWindow {
                Button(CapabilityRegistry.capability(.openInNewWindow).verb) {
                    onOpenInNewWindow(noteID)
                }
            }
            if let starDoor {
                Button(starDoor.title(for: .post(noteID))) {
                    starDoor.toggle(.post(noteID))
                }
            }
            Button("Close") { Self.closeRow(noteID, in: workspace, selection: $selection) }
            // VX-289 (the VX-283 run): Close All Notes — every row closes; a
            // pane showing a note lands by ⌘⇧W's rule (the list empty: the
            // Library), through the column's own navigation road (the
            // selection binding the shell adopts). Declared in
            // `openListMenuCapabilities`; the View menu carries its twin.
            Button(CapabilityRegistry.capability(.closeAllNotes).verb) {
                if let landing = workspace.closeAllNotes() { selection = landing }
            }
        }
    }
}

#if DEBUG
/// The correction round's sidebar oracle (the `BookOutlineGeometry`
/// pattern): what the column actually DREW — an Open-strip row's height and
/// the rail group's — so a pin asserts the pitch she sees, not a constant
/// the view might not consult.
@MainActor
enum SidebarGeometry {
    /// **THE HEADER ORACLES, SCOPED BY THEIR HOST** (13u2 UNIT E —
    /// KnownIssues row 50; the `resetHeaders` doc below named this exact
    /// remedy and this is it). These four are keyed by a TITLE every window
    /// shares — `"this note"`, the Open header, each group's words — so
    /// before the sweep a concurrent suite's mounted column answered this
    /// pin's question, and its `resetHeaders()` could wipe a frame another
    /// suite was polling for. The host's scope sits ABOVE the title now, so
    /// neither can happen; a pin reads its own session's.
    private struct HeaderWorld {
        var openRowHeight: CGFloat?
        var headerTextFrames: [String: CGRect] = [:]
        var firstRowContentFrames: [String: CGRect] = [:]
        var firstRowBoxFrames: [String: CGRect] = [:]
    }

    private static var headerWorlds: [String: HeaderWorld] = [:]

    static func recordOpenRowHeight(_ height: CGFloat, in scope: String) {
        headerWorlds[scope, default: HeaderWorld()].openRowHeight = height
    }

    static func recordHeaderText(_ title: String, _ frame: CGRect, in scope: String) {
        headerWorlds[scope, default: HeaderWorld()].headerTextFrames[title] = frame
    }

    static func recordFirstRowContent(_ title: String, _ frame: CGRect, in scope: String) {
        headerWorlds[scope, default: HeaderWorld()].firstRowContentFrames[title] = frame
    }

    static func recordFirstRowBox(_ title: String, _ frame: CGRect, in scope: String) {
        headerWorlds[scope, default: HeaderWorld()].firstRowBoxFrames[title] = frame
    }

    /// A pin's OWN column — every read below is this session's mount.
    @MainActor
    struct HeaderReader {
        let scope: String

        var openRowHeight: CGFloat? { SidebarGeometry.headerWorlds[scope]?.openRowHeight }
        var headerTextFrames: [String: CGRect] {
            SidebarGeometry.headerWorlds[scope]?.headerTextFrames ?? [:]
        }
        var firstRowContentFrames: [String: CGRect] {
            SidebarGeometry.headerWorlds[scope]?.firstRowContentFrames ?? [:]
        }
        var firstRowBoxFrames: [String: CGRect] {
            SidebarGeometry.headerWorlds[scope]?.firstRowBoxFrames ?? [:]
        }

        /// A pin resets before its mount — ITS OWN scope and no other, which
        /// is what the round-end Fable pass's MINOR-2 learned about
        /// whole-oracle wipes and what the shared TITLE key made impossible
        /// until the scope went above it.
        func resetHeaders() { SidebarGeometry.headerWorlds[scope] = nil }
    }

    static func headers(_ scope: String) -> HeaderReader { HeaderReader(scope: scope) }
    /// KEPT AND PUBLISHED for 18d batch 1, which puts a note BOX where the
    /// rail stands, at the rail's height — the header rule this batch settles
    /// (row 13) is the one that box inherits. **Keyed by the note the rail
    /// draws for** (the round-end Fable pass, MINOR-2 (a)): the box pins take
    /// their REFERENCE height from here, and an unkeyed number let a rail
    /// drawn concurrently by another suite supply it — spuriously red at a
    /// compressed pitch, meaninglessly green at the generous one.
    static var railGroupHeights: [String: CGFloat] { railStore.current }
    /// 13u2 item 10: the STARRED section's drawn height, keyed by the
    /// column's workspace. Her ask is about what the section does when the
    /// list outgrows the window, which is a claim about a rectangle — and
    /// the section's own scroll view is the only thing that can answer it.
    static var starredSectionHeights: [String: CGFloat] = [:]

    /// **VX-285 / VX-286 (the VX-283 run, U1) — the two SCROLLING sections
    /// as drawn**, keyed by the column's workspace (an owner already, the
    /// `starredSectionHeights` key). Her two asks are claims about
    /// rectangles: the scroll bar rides in the margin BESIDE the rows (the
    /// section's scroll view reaches past its first row's trailing edge),
    /// and the Open list runs down to the sync footer and stops there (its
    /// bottom against the column scroll's bottom, `columnScrollFrames`).
    enum ScrollingSection: String, Sendable {
        case starred, open
    }

    struct SectionDraw: Equatable, Sendable {
        /// The section's scroll view, in global coordinates.
        var scroll: CGRect?
        /// Its FIRST row's box (the wash's rectangle), in global coordinates.
        var firstRow: CGRect?
        /// U1b: the section's window over its rows as its scroll view last
        /// reported it (F-1's reveal reads it), and the fades it drew (F-2).
        var window: SidebarLayout.ScrollWindow?
        var fades: SidebarLayout.EdgeFades?
    }

    static var sectionDraws: [String: [ScrollingSection: SectionDraw]] = [:]
    /// The column's outer scroll — the visible column ABOVE the sync footer.
    static var columnScrollFrames: [String: CGRect] = [:]

    static func recordSection(
        _ section: ScrollingSection, scroll: CGRect, for workspace: WorkspaceModel
    ) {
        sectionDraws[bodyKey(for: workspace), default: [:]][section, default: SectionDraw()]
            .scroll = scroll
    }

    static func recordSection(
        _ section: ScrollingSection, firstRow: CGRect, for workspace: WorkspaceModel
    ) {
        sectionDraws[bodyKey(for: workspace), default: [:]][section, default: SectionDraw()]
            .firstRow = firstRow
    }

    /// U1b: the section's window as its scroll view reads it — recorded by
    /// its OWN oracle in the view, apart from `SidebarSectionWindow`, so a pin
    /// measures where a row sits whether or not the window logic is there.
    static func recordSection(
        _ section: ScrollingSection, window: SidebarLayout.ScrollWindow, for workspace: WorkspaceModel
    ) {
        sectionDraws[bodyKey(for: workspace), default: [:]][section, default: SectionDraw()]
            .window = window
    }

    /// U1b: the fades `SidebarSectionWindow` drew (F-2).
    static func recordSection(
        _ section: ScrollingSection, fades: SidebarLayout.EdgeFades, for workspace: WorkspaceModel
    ) {
        sectionDraws[bodyKey(for: workspace), default: [:]][section, default: SectionDraw()]
            .fades = fades
    }

    /// A pin clears ITS OWN column's rows and no other (the keying rule).
    static func forgetSections(for workspace: WorkspaceModel) {
        let key = bodyKey(for: workspace)
        sectionDraws[key] = nil
        columnScrollFrames[key] = nil
    }
    /// 18d batch 1: what the NOTE BOX drew — the whole box, and its header's
    /// words. The geometry oracle compares these two rectangles against the
    /// rail's, because "the box is measured to take up the same amount of
    /// room" is a claim about rectangles, not about a constant.
    ///
    /// **KEYED BY THE BOX'S SUBJECT** (the 18d ladder's MINOR-3, batch 3's
    /// own lesson one letter over): `.serialized` orders tests WITHIN a
    /// suite, and Swift Testing runs SUITES in parallel — a singleton here
    /// lets another suite's mounted sidebar answer this pin's question, and
    /// a pin that reads someone else's rectangle is a green pin that proved
    /// nothing. The key is the book the box belongs to (`RootView` passes
    /// the report's `readingID`); the suites mint LIVE uuids so two worlds
    /// cannot share one.
    static var noteBoxFrames: [String: CGRect] { boxFrameStore.current }
    static var noteBoxHeaderFrames: [String: CGRect] { boxHeaderStore.current }
    /// WHICH FACE the box is showing right now — `"empty"` (state 1) and
    /// `"door"` (state 2's one door), per subject. The state a view was
    /// HANDED is not what it DREW, and the pin's whole job is the second;
    /// the bar's own mount oracle (`CommitBarGeometry.mounted`) answers for
    /// state 3.
    static var noteBoxFaces: [String: [String: Int]] = [:]
    /// Row 13 (17o batch d): per headed group, the header's words, and the
    /// first row's content edge and box under it — "the header sits on its
    /// rows' text edge, with air before the first wash" is a claim about
    /// rectangles, keyed by the header's own title.

    /// **The round-end Fable pass, MAJOR-1:** how many times a column's
    /// `body` has been evaluated, keyed by the workspace it renders — so a
    /// pin can assert that typing in a book note does NOT re-render the
    /// shell (the box's caret label used to be read as a value inside the
    /// shell's sidebar closure, and Observation registered every keystroke
    /// against it). Keyed, because suites run in parallel and each pin
    /// mounts its own shell with its own router.
    static var bodyEvaluations: [String: Int] = [:]
    /// …and what the note box's where-line SAYS, per subject — the second
    /// arm of the same pin: the count must fall AND the label must still
    /// follow the caret, or the pin is satisfied by deleting the label.
    static var noteBoxWhereLines: [String: String] { whereLineStore.current }

    static func bodyKey(for workspace: WorkspaceModel) -> String {
        "\(ObjectIdentifier(workspace))"
    }

    static func noteBodyEvaluation(for workspace: WorkspaceModel) {
        bodyEvaluations[bodyKey(for: workspace), default: 0] += 1
    }

    /// **VX-141 (the VX-143 run) — what the rail's SLOT held, pass by pass.**
    /// Her report is a MOVEMENT (*"the this note section briefly starts to
    /// minimize and then snaps back"*), and a movement is a sequence: going
    /// note → book, a pass that holds NEITHER the rail nor the box is the
    /// collapse she saw begin. Keyed by the workspace like `bodyEvaluations`
    /// (an owner already), and bounded — the newest passes are the question.
    enum SlotOccupant: String, Sendable {
        case rail, box, empty
    }

    static var slotOccupants: [String: [SlotOccupant]] = [:]
    static let slotOccupantLimit = 256

    static func noteSlotOccupant(_ occupant: SlotOccupant, for workspace: WorkspaceModel) {
        let key = bodyKey(for: workspace)
        var row = slotOccupants[key, default: []]
        row.append(occupant)
        if row.count > slotOccupantLimit { row.removeFirst(row.count - slotOccupantLimit) }
        slotOccupants[key] = row
    }

    // **18k UNIT C4 — the rail and the box NAME THEIR OWNER** (the rule and
    // its reasons: `Core/Views/DebugOracleOwnership.swift`). Keyed by their
    // SUBJECT (the rail's note, the box's book), the same subject in two
    // windows shared one row — after one window closed, the rail and the box
    // were ITS (measured red, `DebugOracleTwoWindowTests`). The registrant is
    // the drawing view: the column (`SidebarView`) for the rail, the box
    // (`SidebarNoteBox`) for its frame, header and where-line. The faces
    // beside them are +1/−1 REFCOUNTS, `bodyEvaluations` and
    // `starredSectionHeights` are keyed by the WORKSPACE (an owner already),
    // and the header worlds are SESSION-SCOPED — all SAFE-AS-IS, untouched.
    private static var railStore = OwnedRegistrations<String, CGFloat>()
    private static var boxFrameStore = OwnedRegistrations<String, CGRect>()
    private static var boxHeaderStore = OwnedRegistrations<String, CGRect>()
    private static var whereLineStore = OwnedRegistrations<String, String>()

    static func recordRail(_ postID: String, _ height: CGFloat, owner: UUID) {
        railStore.publish(height, for: postID, owner: owner)
    }

    static func recordBoxFrame(_ subject: String, _ frame: CGRect, owner: UUID) {
        boxFrameStore.publish(frame, for: subject, owner: owner)
    }

    static func recordBoxHeader(_ subject: String, _ frame: CGRect, owner: UUID) {
        boxHeaderStore.publish(frame, for: subject, owner: owner)
    }

    static func recordWhereLine(_ line: String, for subject: String, owner: UUID) {
        whereLineStore.publish(line, for: subject, owner: owner)
    }

    /// A column or a box leaving: its own rows among the four, and nothing
    /// another window's column or box still answers for.
    static func release(owner: UUID) {
        railStore.release(owner: owner)
        boxFrameStore.release(owner: owner)
        boxHeaderStore.release(owner: owner)
        whereLineStore.release(owner: owner)
    }

    /// A PIN's doors (they used to be `railGroupHeights[post] = nil` and
    /// `noteBoxFrames[book] = nil`): unconditional — a pin owns nothing.
    static func forgetRail(_ postID: String) { railStore.forget(postID) }

    static func forgetBoxFrame(_ subject: String) { boxFrameStore.forget(subject) }

    /// **A pin clears ITS OWN box and no other** (the round-end Fable pass's
    /// round 2, MINOR-2 — the (c) class round 1 closed for `SeamGeometry`,
    /// one door over). The four subject-keyed statics — the box's frame, its
    /// header's frame, its faces and its where-line — are published
    /// change-only (`onGeometryChange`) or mount-only (`onAppear`/`onDisappear`
    /// counters), so an entry wiped from under a still-mounted box is never
    /// republished, and a wiped COUNTER goes negative when that box finally
    /// disappears. A whole-oracle wipe from one suite therefore turned another
    /// suite's poll red with no defect behind it (`@MainActor` suites
    /// interleave at every settle's `await`). Not a correctness fix for any
    /// caller — every keyed read is under a live uuid — but the removal of
    /// the whole-wipe DOOR from the box's statics, which is the class itself.
    /// Named for the BOX's subject: the rails' key space (`railGroupHeights`,
    /// keyed by the rail's POST) is a different thing and stays per-key at
    /// its own callers.
    static func forgetBox(subject: String) {
        boxFrameStore.forget(subject)
        boxHeaderStore.forget(subject)
        noteBoxFaces[subject] = nil
        whereLineStore.forget(subject)
    }

    // (`resetHeaders()` RETIRED at 13u2 UNIT E — the whole-oracle wipe it
    //  was is now `HeaderReader.resetHeaders()`, which clears one scope. The
    //  door the round-end Fable pass's MINOR-2 removed from the box's
    //  statics is removed from these four the same way, and for the same
    //  reason: a suite must not be able to wipe what another is polling.)
}
#endif
