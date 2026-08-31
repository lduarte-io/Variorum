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

    let session: AppSession
    let model: LibraryViewModel
    let pool: PoolViewModel
    /// 13f batch 3 (W3/A27, her ruling: *"i'd use the free space that's
    /// underneath 'library / shelf / pool / blocks' for now"*) — the
    /// window's OPEN notes render as a fifth section, below the standing
    /// four and below the contextual "this post" rail.
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
    @Environment(ThemeStore.self) private var theme
    @Environment(\.colorScheme) private var scheme
    /// Phase 11b (B2): the drop-in import model, created on first drop.
    @State private var importer: ImportModel?

    struct TagSheetTarget: Identifiable {
        let id: String
        let title: String?
    }

    private var tokens: VoiceTokens { theme.tokens(for: scheme) }

    /// The `›` idiom (R1): the selected row's label wears the voice's
    /// marker in the ACCENT color; unselected rows carry none. Study's
    /// marker is empty, so this is Terminal's alone.
    @ViewBuilder
    private func markedTitle(_ title: String, _ target: SidebarSelection) -> some View {
        HStack(spacing: 2) {
            if selection == target, !tokens.selectionMarker.isEmpty {
                Text(tokens.selectionMarker.trimmingCharacters(in: .whitespaces))
                    .foregroundStyle(tokens.accent)
                    .fontWeight(.bold)
            }
            Text(tokens.chromeLabel(title))
        }
    }

    /// 13f batch 6 (W4) — the STARRED section, at the sidebar's TOP (her
    /// ruling's placement). Rows are ordinary tagged List rows, so a click
    /// navigates through the shell's own selection and the `›` marker lands
    /// on the current one for free. It renders only when something is
    /// starred, so an unused feature costs no chrome.
    ///
    /// **Act 10 item 13 (her screenshot showed TWO stars, one each side):
    /// exactly ONE star — the blue one, on the RIGHT** (her lean, confirmed
    /// in place: the right star is also the un-star door, so the mark and
    /// the act live in one spot). Long titles show an ellipsis at rest and
    /// marquee-scroll on hover ("stereo style" — `MarqueeText`); the
    /// section carries more air above it (her third clause).
    @ViewBuilder
    private var starredSection: some View {
        if !stars.items.isEmpty {
            Section {
                ForEach(stars.items, id: \.target) { item in
                    let destination = StarTargeting.selection(for: item.target)
                    HStack(spacing: 4) {
                        if selection == destination, !tokens.selectionMarker.isEmpty {
                            Text(tokens.selectionMarker.trimmingCharacters(in: .whitespaces))
                                .foregroundStyle(tokens.accent)
                                .fontWeight(.bold)
                        }
                        MarqueeText(
                            text: tokens.chromeLabel(WorkspaceNaming.label(
                                for: destination, titles: stars.titles)),
                            font: tokens.small,
                            color: selection == destination ? tokens.ink : tokens.muted,
                            weight: selection == destination ? .semibold : .regular)
                        if let starDoor {
                            // THE one star: blue, on the right — and it is
                            // the un-star door (her ruling: "un-star
                            // anywhere").
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
                    .tag(destination)
                    .contextMenu {
                        if let starDoor {
                            Button(starDoor.title(for: item.target)) {
                                starDoor.toggle(item.target)
                            }
                        }
                    }
                }
            } header: {
                Text(tokens.chromeLabel(StarCopy.sectionHeader))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .padding(.top, 14)
            }
        }
    }

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

    /// About how tall one strip row runs (small type + padding) — the
    /// section's ~7-row window is measured in these.
    private static let openRowHeight: CGFloat = 24

    /// 13f batch 3 (W3/A27) — the OPEN strip. **Act 10 item 9 rebuilt it:**
    /// it left the List for the sidebar's bottom rail, shows EVERY open
    /// note (the model's prefix window is gone — a newly opened note can no
    /// longer land hidden), and past ~7 rows the SECTION scrolls in place
    /// (her ruled shape, the starred precedent) with the newcomer auto-
    /// revealed. The dead "…N more open" label died with the hidden set —
    /// every open note is now its own clickable row, which is strictly more
    /// door than the label ever was. ⌘⇧1…9 still reach the first nine rows,
    /// whose badges say so; the ✕ closes a ROW and nothing else (closing
    /// never deletes — pure view state); drag a row to reorder (her
    /// session-only ruling, now via the strip's own transfer type).
    @ViewBuilder
    private var openStrip: some View {
        let shown = workspace.openNotes.shown
        if !shown.isEmpty {
            VStack(alignment: .leading, spacing: 3) {
                Text(tokens.chromeLabel(WorkspaceNaming.openSectionHeader))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .lineLimit(1)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 1) {
                            ForEach(shown, id: \.self) { noteID in
                                openRow(noteID, ordinal: (shown.firstIndex(of: noteID) ?? 99) + 1)
                                    .id(noteID)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 6)
                    }
                    .frame(maxHeight: Self.openRowHeight * 7.5)
                    .fixedSize(horizontal: false, vertical: shown.count <= 7)
                    // The newcomer reveal: the most-recently-opened note
                    // scrolls into view the moment it joins — "a newly
                    // opened note never lands hidden", made literal.
                    .onChange(of: workspace.openNotes.recency.first) { _, newest in
                        if let newest { proxy.scrollTo(newest) }
                    }
                }
            }
        }
    }

    private func openRow(_ noteID: String, ordinal: Int) -> some View {
        let destination = SidebarSelection.post(noteID)
        let current = selection == destination
        return HStack(spacing: 4) {
            if current, !tokens.selectionMarker.isEmpty {
                Text(tokens.selectionMarker.trimmingCharacters(in: .whitespaces))
                    .foregroundStyle(tokens.accent)
                    .fontWeight(.bold)
            }
            MarqueeText(
                text: tokens.chromeLabel(workspace.label(for: destination)),
                font: tokens.small,
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
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .frame(minHeight: Self.openRowHeight - 5)
        .background(
            current ? AnyShapeStyle(tokens.wash) : AnyShapeStyle(Color.clear),
            in: RoundedRectangle(cornerRadius: 6))
        .contentShape(Rectangle())
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

    var body: some View {
        // Act 10 item 9: the Open strip lives BELOW the List as the
        // sidebar's bottom rail — always in reach, its own ~7-row scroll —
        // and W8-3's solid grammar paints the whole column one flat room.
        VStack(spacing: 0) {
            sidebarList
            openStrip
        }
        .background(tokens.room)
        // The strip's names, resolved for exactly what is on screen and
        // re-read whenever that set or its ORDER changes — which is every
        // navigation (the shipped `PostTitleLabel` precedent: chrome titles
        // are one-shot reads keyed on what they show, never a held
        // observation per row).
        .task(id: workspace.titleSubjectsKey) {
            await workspace.resolveTitles(session: session)
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
        .toolbar {
            ToolbarItem {
                Button("New Note", systemImage: "square.and.pencil") {
                    Task {
                        if let id = await model.createPost() {
                            selection = .post(id)
                        }
                    }
                }
            }
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

    private var sidebarList: some View {
        List(selection: $selection) {
            starredSection
            Section {
                // Batch 7/8 (her audit: "there's no little › to show the
                // way … it being a color ›") — the R1 selection-marker
                // idiom, wired: the selected row alone wears the voice's
                // marker, in the ACCENT color.
                Label {
                    markedTitle("Shelf", .shelf)
                } icon: {
                    Image(systemName: "books.vertical")
                }
                .tag(SidebarSelection.shelf)
                Label {
                    markedTitle("Library", .library)
                } icon: {
                    Image(systemName: "text.book.closed")
                }
                .tag(SidebarSelection.library)
                Label {
                    markedTitle("Pool", .poolPosts)
                } icon: {
                    Image(systemName: "tray")
                }
                .tag(SidebarSelection.poolPosts)
                // Batch 12: Blocks joins as the FOURTH AREA — R44's
                // sidebar, finally literal. The inline scrap rows are
                // gone ("way too crowded"); the area page holds them.
                Label {
                    markedTitle("Snippets", .blocks)
                } icon: {
                    Image(systemName: "square.on.square")
                }
                .tag(SidebarSelection.blocks)
                // Ledger row 8 (B2): ARCHIVED, after the four — her
                // direction's letter ("a different item on the left, like
                // where library is"). It sits at the END of the standing
                // group deliberately: Shelf · Library · Pool · Snippets is
                // R44's ruled order and this is an addition to it, not a
                // re-ranking of it.
                Label {
                    markedTitle(RecoveryPath.archivedSurface, .archived)
                } icon: {
                    Image(systemName: "archivebox")
                }
                .tag(SidebarSelection.archived)
            }
            // 13g L4 (WT-4), her walkthrough: *"i don't even konw if we need
            // that empty whitespace that says Variorum at the top - let's
            // try getting rid of it."* Shipped as a TRY — she keeps it or
            // asks for it back on sight. It was a plain `Section` HEADER
            // inside the List (never the window's drag area and never the
            // traffic lights' clearance — those live in the title bar above
            // this List), so removing it is a header removal and nothing
            // else: the four areas keep their section, and the two headers
            // that mean something (Starred, Open) still read as headers
            // because they now name the only named sections there are.
            // Batch 14 (her ruling — supersedes the bottom mode line):
            // the post MODES live here, "in the same verticle pane as
            // shelf / library / pools, but with a separator so it's clear
            // that it's only for when you're within a post."
            if case .post(let postID) = selection {
                Section {
                    ForEach(PostDetailView.Mode.allCases, id: \.self) { m in
                        Button {
                            // 13b 1b (P-4): composed routing — the rail
                            // asks the router, which reaches the mounted
                            // detail (or speaks; never a dropped
                            // broadcast).
                            session.commandRouter.requestMode(m, postID: postID)
                        } label: {
                            HStack(spacing: 2) {
                                if m.rawValue == postMode, !tokens.selectionMarker.isEmpty {
                                    Text(tokens.selectionMarker
                                        .trimmingCharacters(in: .whitespaces))
                                        .fontWeight(.bold)
                                        .foregroundStyle(tokens.accent)
                                }
                                Text(tokens.chromeLabel(m.rawValue))
                                    .font(tokens.mono)
                                    .fontWeight(m.rawValue == postMode ? .semibold : .regular)
                                    .foregroundStyle(
                                        m.rawValue == postMode ? tokens.accent : tokens.muted)
                            }
                        }
                        .buttonStyle(.plain)
                        .help("\(m.rawValue) (⌘\((PostDetailView.Mode.allCases.firstIndex(of: m) ?? 0) + 1))")
                    }
                } header: {
                    Text(tokens.chromeLabel("this note"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
}
