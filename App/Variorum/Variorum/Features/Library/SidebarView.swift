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
    ]

    /// The five areas, in R44's ruled order (+ Archived at the end, the
    /// post-13l polish round's addition). ONE table the column iterates —
    /// the row count the fit test reads is this table's count.
    struct Area: Hashable {
        let title: String
        let symbol: String
        let destination: SidebarSelection
    }

    static let areas: [Area] = [
        Area(title: "Shelf", symbol: "books.vertical", destination: .shelf),
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

    /// Every row the column is about to draw, for the fit test.
    private var rowCount: Int {
        SidebarLayout.rowCount(
            starred: stars.items.count, areas: Self.areas.count,
            rail: railPostID == nil ? 0 : PostDetailView.Mode.allCases.count,
            openNotes: workspace.openNotes.shown.count)
    }

    /// The headed groups the column is about to draw (ladder R1-12: the
    /// fit test counts the chrome actually present).
    private var headedGroupCount: Int {
        (stars.items.isEmpty ? 0 : 1) + (railPostID == nil ? 0 : 1)
            + (workspace.openNotes.shown.isEmpty ? 0 : 1)
    }

    private var rowHeight: CGFloat {
        SidebarLayout.rowHeight(
            columnHeight: columnHeight, rows: rowCount, headedGroups: headedGroupCount)
    }

    var body: some View {
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
                    }
                    openGroup
                }
                .padding(.top, 14)
                .padding(.bottom, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollBounceBehavior(.basedOnSize)
            if let bottom {
                Divider().overlay(tokens.line)
                bottom
            }
        }
        .background(tokens.room)
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { columnHeight = $0 }
        // Row 24 (the sidebar half): the rail fades in and out with the
        // note — the groups below it slide, nothing snaps.
        .animation(.easeInOut(duration: 0.22), value: railPostID)
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

    /// The mockup's `.sb-group`: 12 pt of side padding around its rows.
    private static let groupPadding: CGFloat = 12
    /// The mockup's `.sb-row`: 8 pt of side padding inside the row.
    private static let rowPadding: CGFloat = 8

    /// A group header — small, in the accent (the voice's own header
    /// register, kept from the List), sitting on the rows' text edge.
    private func header(_ title: String) -> some View {
        Text(tokens.chromeLabel(title))
            .font(tokens.small)
            .foregroundStyle(tokens.accent)
            .lineLimit(1)
            .padding(.horizontal, Self.groupPadding + Self.rowPadding)
            .frame(height: 22, alignment: .bottomLeading)
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
    @ViewBuilder
    private var starredGroup: some View {
        if !stars.items.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                header(StarCopy.sectionHeader)
                ForEach(stars.items, id: \.target) { item in
                    starredRow(item)
                }
            }
            .padding(.horizontal, Self.groupPadding)
            separator
        }
    }

    private func starredRow(_ item: Queries.StarredItem) -> some View {
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
        .onTapGesture { selection = destination }
        .contextMenu {
            if let starDoor {
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
            }
        }
        .padding(.horizontal, Self.groupPadding)
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
                        }
                    }
                    .buttonStyle(.plain)
                    .help("\(m.rawValue) (⌘\((PostDetailView.Mode.allCases.firstIndex(of: m) ?? 0) + 1))")
                }
            }
            .padding(.horizontal, Self.groupPadding)
            #if DEBUG
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height in
                SidebarGeometry.railGroupHeight = height
            }
            #endif
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
    /// deletes — pure view state); drag a row to reorder (her session-only
    /// ruling, via the strip's own transfer type). **The correction round
    /// (row 3) moved it back UNDER THE RAIL** — its rows at the column's one
    /// pitch — where her tabs were before Act 10 sent them to the bottom.
    @ViewBuilder
    private var openGroup: some View {
        let shown = workspace.openNotes.shown
        if !shown.isEmpty {
            separator
            VStack(alignment: .leading, spacing: 0) {
                header(WorkspaceNaming.openSectionHeader)
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(shown, id: \.self) { noteID in
                                openRow(noteID, ordinal: (shown.firstIndex(of: noteID) ?? 99) + 1)
                                    .id(noteID)
                            }
                        }
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .frame(maxHeight: SidebarLayout.openStripMaxHeight(rowHeight: rowHeight))
                    .fixedSize(
                        horizontal: false, vertical: shown.count <= SidebarLayout.openStripWindow)
                    // The newcomer reveal: the most-recently-opened note
                    // scrolls into view the moment it joins — "a newly
                    // opened note never lands hidden", made literal.
                    .onChange(of: workspace.openNotes.recency.first) { _, newest in
                        if let newest { proxy.scrollTo(newest) }
                    }
                }
            }
            .padding(.horizontal, Self.groupPadding)
        }
    }

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
                Button("\u{2715}") { workspace.closeNote(noteID) }
                    .buttonStyle(.plain)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .help("Close this row — the note itself is untouched")
            }
        }
        #if DEBUG
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height in
            SidebarGeometry.openRowHeight = height
        }
        #endif
        .onTapGesture { selection = destination }
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
            Button("Close") { workspace.closeNote(noteID) }
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
    static var openRowHeight: CGFloat?
    static var railGroupHeight: CGFloat?
}
#endif
