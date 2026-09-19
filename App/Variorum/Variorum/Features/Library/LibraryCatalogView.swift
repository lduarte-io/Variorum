//
//  LibraryCatalogView.swift
//  Variorum
//
//  Phase 13, B2 — LIBRARY = EVERYTHING (R32: "all books, posts, and
//  blocks. like literally everything, sortable and searchable") with the
//  timeline folded in as a VIEW MODE (sitting 1/R5) and the tags column as
//  an ADDABLE batch-tagging surface (R46). The old sidebar post pile and
//  its context menu live here now; recovery + tutorial stay reachable from
//  the toolbar (and ⌘K).
//
//  The MODEL moved out at the 18h ladder's R1-6 — `LibraryCatalogModel.swift`
//  beside this file. This one is the VIEW.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import UniformTypeIdentifiers
import VariorumCore

struct LibraryCatalogView: View {
    /// 13e E8: the note rows' tag doors (`＋` / `✕`) — the SECOND renderer
    /// of the one `.tagNote` act (the context bar's cards are the first),
    /// declared so the `.surface` walk covers them.
    ///
    /// 13l Act 2 (item 3): the BULK delete's banner joins it — her ruling's
    /// third clause, on the ⌘-click selection this list already had (the bulk
    /// TAG menu has used it since 13e E8; what was missing was the act, never
    /// the selection).
    static let surfaceCapabilities: [CapabilityID] = [.tagNote, .deleteSelectedNotes]

    /// **THE MASTHEAD'S DOORS — AND THE ⋯ MENU IS GONE** (the post-13l polish
    /// round, ledger row 7 — her B1 ruling, verbatim: *"I want the ... menu in
    /// the upper right of the library to be replaced with a trash icon"* and
    /// *"open tutorial doesn't need to be under the ... menu, it could be
    /// under help if anything"*).
    ///
    /// Both halves are honest. The Trash is a PLACE, and a place behind a ⋯ is
    /// a place nobody finds, so it gets the clear icon. The tutorial door was
    /// a DUPLICATE all along — **Help ▸ Open the Tutorial** has carried it
    /// since 13b Stage 2 (`EditorCommands`' Help group) — so this is a
    /// removal rather than a move: nothing to re-home, one door fewer for one
    /// act, and ⌘K still types both by name. The view no longer takes an
    /// `onOpenTutorial` callback at all, which is the compiler's own record
    /// that the door left.
    ///
    /// **This array IS what the header renders** (the `showsEmptyTrashDoor`
    /// precedent, one surface over): the masthead iterates it, so a pin over
    /// it drives the decision the view makes rather than standing beside it.
    /// These are NAVIGATION doors, which is why they are not registry
    /// capabilities — the same rule `RootView.wirePaletteCommands` states for
    /// the palette's Go-to rows.
    enum MastheadDoor: Hashable, CaseIterable {
        case trash

        var destination: SidebarSelection {
            switch self { case .trash: return .recovery }
        }

        /// 13f W10a's rule, kept: the label reads from `RecoveryPath`, which
        /// is also what the copy pointing here says — one name, so the
        /// sentence and the door can never drift apart.
        var label: String {
            switch self { case .trash: return RecoveryPath.menuLabel }
        }

        var icon: String {
            switch self { case .trash: return "trash" }
        }
    }

    static let mastheadDoors: [MastheadDoor] = MastheadDoor.allCases

    /// Item 14: which note a version door was opened FOR, and which act it
    /// fires. A value the sheet presents (the `presenting:` doctrine's
    /// cousin — never a flag read back).
    struct VersionPickTarget: Identifiable, Equatable {
        enum Act { case mark, unmark }
        let postID: String
        let act: Act
        var id: String { "\(postID)-\(act)" }
    }

    let session: AppSession
    let model: LibraryCatalogModel
    let library: LibraryViewModel
    let tags: TagsViewModel
    let onOpen: (SidebarSelection) -> Void
    /// Stage C: block hits land caret-precise when the shell provides the
    /// door (nil falls back to plain navigation).
    var onOpenBlock: ((SidebarSelection, String) -> Void)? = nil
    /// 13f batch 4 (W1/A25): the split's row door.
    var onOpenBeside: ((String) -> Void)? = nil
    /// 13f batch 5b (W2/A26): the note-only window's row door.
    var onOpenInNewWindow: ((String) -> Void)? = nil
    /// The Act 10 correction round, batch E (row 33): the panel's book
    /// outline opens the book AT a note — batch B's reveal road, through the
    /// shell (`RootView.openBook(_:at:in:)`). nil falls back to opening the
    /// book plainly.
    var onOpenBook: ((String, String) -> Void)? = nil
    /// 13f batch 6 (W4): the star door, from the one note-row grammar.
    var starDoor: StarDoor? = nil
    // The tutorial door's property LEFT with the \u{22EF} menu (the post-13l
    // polish round, ledger row 7). It routed through the shell's fire-and-DO
    // act (`ShellActions.openTutorial`) — and still does, from Help \u{25B8}
    // Open the Tutorial, which is where her B1 ruling put it and where
    // `EditorCommands` has rendered it since 13b Stage 2. A view that no
    // longer renders a door does not carry its callback.

    // Optional: test hosts (and future embeddings) may lack the
    // environment — fall back to the leading voice's tokens.
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @State private var tagSheetTarget: SidebarView.TagSheetTarget?
    @State private var renameTarget: String?
    @State private var renameTitle = ""
    /// Item 14: the version doors' picker target — which note, which act.
    @State private var versionPickTarget: VersionPickTarget?
    /// 13l Act 2 (item 3): the pending delete ask — one row's, or the whole
    /// ⌘-click selection's. One piece of state for both, because it is one
    /// act with one wording and one host.
    @State private var pendingDelete: NoteDeleteConfirm?
    /// Row 34: the library's measured width — the panel column's width is
    /// derived from it (`LibraryPanelLayout`), never from an inspector.
    @State private var libraryWidth: CGFloat = 0

    /// The catalog's own coordinate space — the DEBUG oracle's frames are
    /// read here (a `.global` read inside a macOS `ScrollView` answers in
    /// the scroll view's space — batch C's lesson).
    static let probeSpace = "library-catalog"

    /// Row 24 (the panel half): the panel's presence animates — the column
    /// slides and fades in and out with the row selection. The mutation
    /// sites wrap the model's change in this animation explicitly: an
    /// `.animation(value:)` on the container did NOT carry the transition
    /// through the `@Observable` model's change (the walk's burst capture
    /// saw the panel go from absent to settled between two frames 100 ms
    /// apart), so the transaction is made animated where the change is made.
    static let panelAnimation: Animation = .easeInOut(duration: 0.22)

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        // The Act 10 correction round, batch E — rows 34 + 24 (the panel
        // half): the right panel is a column of OUR OWN — the list, ONE 1 pt
        // `line` divider (the shell's grammar), the panel on the room — every
        // part drawn by us in every window state. It was a SwiftUI
        // `.inspector`, whose divider the system draws only in a KEY window:
        // tabbed out, the boundary between the library and the panel
        // vanished (her words: "the line between the 'note info' and the
        // library disappears when you're tabbed out"). The column's presence
        // slides and fades with the row selection; the subject swap fades
        // inside the panel — nothing teleports.
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                header
                Divider().overlay(tokens.line)
                switch model.mode {
                case .list: listBody
                case .notes: notesBody
                case .timeline:
                    TimelineView(session: session) { postID in
                        onOpen(.post(postID))
                    }
                }
                messageRow
                // Sitting 9 batch 8 (her directive): the round-2 mockup's
                // quick-entry bar rides the Library too — type, ⏎, and the
                // typed text IS a post, opened.
                Divider().overlay(tokens.line)
                QuickEntryBar(session: session, onOpen: onOpen)
                    .libraryGeometryProbe(.quickEntry)
            }
            .frame(maxWidth: .infinity)
            if let hit = model.infoHit {
                // Ladder R1-17: the divider and the panel are ONE transitioning
                // group, so the line slides in WITH the column. (A `.transition`
                // on the 1-pt line alone moved it by its own width — it faded in
                // place while the panel was still sliding from the right, a
                // frame ahead of the column it bounds; the fix session's burst
                // by window id caught exactly that.)
                HStack(spacing: 0) {
                    panelDivider
                    LibraryInfoPanel(
                        session: session, hit: hit,
                        multiCount: model.selectedPosts.count,
                        onOpen: { openHit(hit) },
                        onOpenBookAt: { postID in
                            withAnimation(Self.panelAnimation) { model.closeInfo() }
                            if let onOpenBook {
                                onOpenBook(hit.id, postID)
                            } else {
                                onOpen(.reading(hit.id))
                            }
                        },
                        onClose: { withAnimation(Self.panelAnimation) { model.closeInfo() } })
                        .frame(width: LibraryPanelLayout.width(total: libraryWidth))
                        .libraryGeometryProbe(.panel)
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .coordinateSpace(name: Self.probeSpace)
        .libraryGeometryProbe(.root)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { libraryWidth = $0 }
        .background(tokens.surface)
        .task { await model.search() }
        // 13g R5-6: switching INTO notes fills the cards; switching out
        // clears them, so a mode she is not in holds no derived text.
        .task(id: model.mode) { await model.refreshNoteCards() }
        // P-0 (13l, the ladder): the pick is the LIST's, and only the List
        // mode draws it. Carrying it into Notes or Timeline would leave the
        // bulk bar offering to delete notes nothing on screen shows as
        // picked — an invisible selection behind a destructive door.
        // …and the clear is SYNCHRONOUS (the 18h ladder's R3-1): a `Task {}`
        // body cannot run before this update completes, so an async clear
        // left the bulk bar's Delete and the info panel drawing for a frame
        // over a selection nothing on screen shows. The model answers whether
        // a re-read is owed; only the read is spawned.
        .onChange(of: model.mode) { _, _ in
            if model.modeChanged() { Task { await model.search() } }
        }
        .sheet(item: $tagSheetTarget) { target in
            TagAssignmentSheet(session: session, postID: target.id, postTitle: target.title)
        }
        // Item 14: the version doors' searchable picker (both acts, one
        // component — the seam wave 2c's Compare reuses).
        .sheet(item: $versionPickTarget) { target in
            NotePickerSheet(
                tokens: tokens,
                title: target.act == .mark
                    ? "Mark as Versions with" : "Unmark Versions with",
                emptyState: target.act == .mark
                    ? "Nothing matches."
                    : "No notes are marked as versions of this one.",
                source: target.act == .mark
                    ? .corpusNotes(
                        session: session, excluding: target.postID,
                        versionPeersOf: target.postID,
                        peerAnnotation: "already versions")
                    : .versionPeers(session: session, of: target.postID)
            ) { row in
                Task {
                    if target.act == .mark {
                        await library.markAsVersions(target.postID, row.id)
                    } else {
                        await library.unmarkVersions(target.postID, row.id)
                    }
                }
            }
        }
        .alert(
            "Rename Note",
            isPresented: Binding(
                get: { renameTarget != nil },
                set: { if !$0 { renameTarget = nil } }),
            presenting: renameTarget
        ) { postID in
            TextField("Title", text: $renameTitle)
            Button("Rename") {
                let title = renameTitle
                Task {
                    await library.rename(postID: postID, title: title)
                    await model.search()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        // 13l Act 2 (item 3): ONE host for both asks — a row's and the whole
        // selection's — so the wording cannot differ between them.
        .deleteNoteConfirmDialog($pendingDelete) { confirm in
            model.deselect(confirm.postIDs)
            NoteDeletion.fire(session: session, postIDs: confirm.postIDs)
        }
        // …and the listing catches up on the SIGNAL rather than after its own
        // door, because this list's contents are a one-shot `search()` while a
        // note can be deleted from the bar of a note open in another pane
        // entirely (P-4: the signal says what happened, this decides what it
        // means here — re-read).
        .onReceive(NotificationCenter.default.publisher(for: .variorumNotesDeleted)) { _ in
            Task { await model.search() }
        }
    }

    /// Open a hit at its own kind's destination — the one opening road the
    /// title click, the double-click, the context menu and the panel's Open
    /// door all take. A NOTE lands where the caret last was by construction:
    /// the mounting detail restores the note's current block from batch C's
    /// `CurrentBlockMemory` (`CommandRouter.registerDetail`) and Write's bare
    /// arrival lands there (else the document's start).
    private func openHit(_ hit: Queries.CatalogHit) {
        withAnimation(Self.panelAnimation) { model.closeInfo() }
        onOpen(hit.kind == .book ? .reading(hit.id) : .post(hit.id))
    }

    /// Row 56 — the pick's grammar (W8-2: the wash + a tinted border, never
    /// a system highlight): a picked row (⌘/⇧-click) wears the wash with a
    /// quiet border; the panel's SUBJECT wears the fuller border, so the row
    /// the panel describes reads as the one she last touched.
    @ViewBuilder
    private func rowBackground(picked: Bool, subject: Bool) -> some View {
        if picked || subject {
            RoundedRectangle(cornerRadius: 6)
                .fill(tokens.wash)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(tokens.accent.opacity(subject ? 0.42 : 0.22), lineWidth: 1))
                .padding(.horizontal, 6)
                .padding(.vertical, 1)
        } else {
            Color.clear
        }
    }

    /// Row 34 — OUR boundary between the list and the panel: the shell's
    /// one honest line, drawn whatever the window's state.
    private var panelDivider: some View {
        Rectangle()
            .fill(tokens.line)
            .frame(width: 1)
            .libraryGeometryProbe(.divider)
    }

    /// F's (a) — a receipt or an error is a LAID-OUT row above the bottom
    /// divider, in its own voice. It was an overlay pinned to the column's
    /// bottom-left, which put it ON the quick-entry bar at the window's edge
    /// with its descenders clipped (`seed-33`).
    @ViewBuilder private var messageRow: some View {
        if let error = model.lastError ?? library.lastError {
            Text(error)
                .font(tokens.small)
                .alarmVoice()
                .textSelection(.enabled)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .libraryGeometryProbe(.message)
        } else if let receipt = library.receipt {
            // Ledger row 25: the archive door's own sentence. Its own slot
            // and its own colour — a receipt in the red slot reads as a
            // failure (row 6's finding, one surface over).
            Text(receipt)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .textSelection(.enabled)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .libraryGeometryProbe(.message)
        }
    }

    /// The ⌘-click pick, in the order the LIST shows it (13l Act 2, item 3).
    /// `selectedPosts` is a `Set`, and a set has no order — so a receipt and
    /// a confirm built from it would name notes in whatever order the hash
    /// happened to give, which is the surface telling her a different story
    /// each time she looks. The list's own order is the one she is pointing at.
    ///
    /// *(P-0, the ladder: the pick and its ordering moved to the model, where
    /// the routing that fills it can be driven. This reads through.)*
    private var selectedPosts: Set<String> { model.selectedPosts }
    private var selectedNotesInListOrder: [String] { model.selectedNotesInListOrder }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(tokens.path(["Library"]))
                    .font(tokens.heading)
                    .foregroundStyle(tokens.accent)
                Text(tokens.chromeLabel("everything — sortable, searchable"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                Spacer()
                ForEach(Self.mastheadDoors, id: \.self) { door in
                    Button {
                        onOpen(door.destination)
                    } label: {
                        Image(systemName: door.icon)
                    }
                    .buttonStyle(.borderless)
                    .help(door.label)
                    .accessibilityLabel(door.label)
                    .frame(width: 28)
                }
            }
            HStack(spacing: 10) {
                TextField(tokens.chromeLabel("Search books, notes, blocks…"),
                          text: Binding(get: { model.query }, set: { value in
                              model.query = value
                              Task { await model.search() }
                          }))
                    .textFieldStyle(.roundedBorder)
                    .font(tokens.small)
                    .frame(maxWidth: 320)
                Picker("", selection: Binding(get: { model.scope }, set: { model.scope = $0; Task { await model.search() } })) {
                    ForEach(LibraryCatalogModel.Scope.allCases, id: \.self) { scope in
                        Text(tokens.chromeLabel(scope.rawValue.capitalized)).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 280)
                // 18h batch 2: a day names NOTES — books and blocks carry no
                // edit stamp and stand down while one is armed, so the scope
                // stands down with them rather than offering picks that
                // would list nothing (P-2).
                .disabled(model.editedOn != nil)
                .help(model.editedOn == nil
                      ? LibraryCopy.scopeDoor : LibraryCopy.scopeDoorUnderADay)
                Picker("", selection: Binding(get: { model.mode }, set: { model.mode = $0 })) {
                    Text(tokens.chromeLabel("List")).tag(LibraryCatalogModel.Mode.list)
                    Text(tokens.chromeLabel("Notes")).tag(LibraryCatalogModel.Mode.notes)
                    Text(tokens.chromeLabel("Timeline")).tag(LibraryCatalogModel.Mode.timeline)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 230)
                // 18h batch 1 (her row 10): the notes' order, hers to
                // choose. The Timeline mode is its own order by definition,
                // so the door stands down there rather than lying.
                if model.showsCatalogControls {
                    LibrarySortMenu(
                        tokens: tokens, sort: model.sort, direction: model.direction,
                        onPick: { pick in
                            model.setSort(pick)
                            Task { await model.search() }
                        },
                        onDirection: { pick in
                            model.setDirection(pick)
                            Task { await model.search() }
                        })
                    // 18h batch 2 (her row 11): *"search for any note edited
                    // on a particular day."*
                    LibraryDayField(
                        tokens: tokens, day: model.editedOn,
                        onPick: { day in
                            model.setEditedOn(day)
                            Task { await model.search() }
                        },
                        onClear: {
                            model.setEditedOn(nil)
                            Task { await model.search() }
                        })
                }
                if selectedPosts.count > 1 {
                    Menu(tokens.chromeLabel("Tag \(selectedPosts.count) notes")) {
                        ForEach(tags.tags, id: \.id) { tag in
                            Button(tag.path) {
                                let ids = Array(selectedPosts)
                                Task { await model.applyTag(tag.id, to: ids) }
                            }
                        }
                    }
                    .font(tokens.small)
                    // 13e E8 — the bulk half of *"remove / add them"*. The
                    // rows are the tags the SELECTION actually wears, so the
                    // menu never offers an act that would do nothing (P-2);
                    // with none, there is no menu at all.
                    let worn = model.tagsOn(selectedPosts)
                    if !worn.isEmpty {
                        Menu(tokens.chromeLabel("Untag \(selectedPosts.count) notes")) {
                            ForEach(worn, id: \.id) { tag in
                                Button(tag.path) {
                                    let ids = Array(selectedPosts)
                                    Task { await model.removeTag(tag.id, from: ids) }
                                }
                            }
                        }
                        .font(tokens.small)
                    }
                    // 13l Act 2 (item 3) — her ruling's third clause, built on
                    // the selection this bar already reads. ONE confirmation
                    // naming the count and ONE receipt, which is why the whole
                    // pick goes to the host as one ask rather than N asks.
                    Button(
                        tokens.chromeLabel(
                            "Delete \(selectedPosts.count) notes\u{2026}"),
                        role: .destructive
                    ) {
                        Task { pendingDelete = await NoteDeletion.ask(
                            session: session, postIDs: selectedNotesInListOrder) }
                    }
                    .font(tokens.small)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
    }

    private var listBody: some View {
        // Row 56: the List draws NO selection of its own — the old
        // `List(selection:)` binding painted the pick as the SYSTEM band
        // (grey while the list was not first responder, the blue accent when
        // it was), against W8-2's grammar. The pick and the panel's subject
        // render through `rowBackground` — the wash + a tinted border — on
        // note and book rows alike; the model still owns the pick.
        List {
            let grouped = Dictionary(grouping: model.hits, by: \.kind)
            if let books = grouped[.book], !books.isEmpty {
                Section(tokens.chromeLabel("Books")) {
                    ForEach(books, id: \.id) { hit in
                        // The TITLE opens instantly, as today (her click
                        // model — the body selects, the words open).
                        CatalogBookLine(
                            tokens: tokens, title: hit.title, detail: hit.detail,
                            onTitleTap: { openHit(hit) })
                        // Row 33 (a): the WHOLE row is the target — the line
                        // used to be only as wide as its words, so a click
                        // right of "book" was a dead click and the panel
                        // kept whatever it was showing.
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        // A body click selects AT ONCE and shows the book's
                        // OUTLINE in the panel (her ruled model, row 33's
                        // shape); a double-click anywhere opens. ONE shared
                        // tap brain (`rowClick`, ladder R1-2): the stacked
                        // count-2 + plain gestures held every single click
                        // for the double-click interval — batch C's row-25
                        // lag, alive on this surface until now.
                        .rowClick(
                            onClick: { _ in
                                withAnimation(Self.panelAnimation) { model.selectBook(hit) }
                            },
                            onDoubleClick: { openHit(hit) })
                        .listRowBackground(
                            rowBackground(picked: false, subject: model.infoHit?.id == hit.id))
                    }
                }
            }
            if let posts = grouped[.post], !posts.isEmpty {
                Section(tokens.chromeLabel("Notes")) {
                    ForEach(posts, id: \.id) { hit in
                        postRow(hit)
                            .listRowBackground(rowBackground(
                                picked: model.selectedPosts.contains(hit.id),
                                subject: model.infoHit?.id == hit.id))
                    }
                }
            }
            if let blocks = grouped[.block], !blocks.isEmpty {
                Section(tokens.chromeLabel("Blocks")) {
                    ForEach(blocks, id: \.id) { hit in
                        HStack {
                            Image(systemName: "square.on.square").foregroundStyle(tokens.muted)
                            Text(hit.title).font(tokens.small).lineLimit(1)
                            if let home = hit.detail {
                                Text(tokens.chromeLabel("in \(home)"))
                                    .font(tokens.small)
                                    .foregroundStyle(tokens.faint)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // A block hit opens its HOME surface (round 2,
                            // MINOR: dead rows violated fire-and-speak) —
                            // caret-precise where the shell offers the
                            // Stage C door.
                            if let home = hit.homeContainerID {
                                let selection: SidebarSelection =
                                    hit.homeIsPool ? .pool(home) : .post(home)
                                if let onOpenBlock {
                                    onOpenBlock(selection, hit.id)
                                } else {
                                    onOpen(selection)
                                }
                            }
                        }
                    }
                }
            }
            if model.hits.isEmpty {
                // 18h batch 2: a day that finds nothing says WHY — the one
                // wording, shared with the Notes mode below.
                if let day = model.dayForEmptyAnswer {
                    LibraryDayEmptyAnswer(tokens: tokens, day: day, query: model.query)
                } else {
                    Text(tokens.chromeLabel(LibraryCopy.nothingMatches))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                }
            }
            // R1-4: a capped listing says so rather than reading as the
            // library. The day's answer is uncapped, so this never draws
            // under one.
            if model.listingIsTruncated {
                LibraryTruncationLine(tokens: tokens)
            }
        }
        .scrollContentBackground(.hidden)
        .background(tokens.surface)
    }

    /// 13g batch 6 (R5-6) — the Apple-Notes-shaped list: title · date ·
    /// the first bit of text · the book it's in, per her screenshot. NOTES
    /// ONLY (books and blocks have no snippet to show and belong to the
    /// List mode's sections); a `LazyVStack` so the rows cost what is drawn.
    private var notesBody: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                let posts = model.hits.filter { $0.kind == .post }
                ForEach(posts, id: \.id) { hit in
                    noteCard(hit)
                    Divider().overlay(tokens.line.opacity(0.6))
                }
                if posts.isEmpty {
                    if let day = model.dayForEmptyAnswer {
                        LibraryDayEmptyAnswer(tokens: tokens, day: day, query: model.query)
                            .padding(24)
                    } else {
                        Text(tokens.chromeLabel(LibraryCopy.noNotesMatch))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .padding(24)
                    }
                }
                if model.notesAreTruncated {
                    LibraryTruncationLine(tokens: tokens)
                        .padding(.vertical, 10)
                }
            }
            .padding(.horizontal, 20)
        }
        .background(tokens.surface)
    }

    private func noteCard(_ hit: Queries.CatalogHit) -> some View {
        let card = model.noteCards[hit.id] ?? NoteCards.Card()
        // 13u3 UNIT B (her item 4): what the card LEADS with — her title
        // where she typed one, a daily entry's day, else the note's own
        // first words. Derived at read time, never stored, nothing renamed.
        let name = LibraryCardName.card(for: hit, leadingTexts: card.leadingTexts)
        return VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(name.lead.text)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                // 18h batch 1 (her row 9): the card's date slot is the SORT's
                // own stamp, in the one brain's words — *"edited today 1:33
                // AM"* where it used to print the raw stored day
                // ("2026-09-09"), which is the shape she asked to see
                // "easily" and the shape Apple Notes' own card wears.
                // 17q (her R-Q17 on #103): …and the day she STATED stands
                // beside it where the row has room, the two collapsing to
                // one click-flipping stamp where it does not.
                CatalogCardStamps(
                    tokens: tokens, postID: hit.id,
                    stamps: LibrarySortFace.rowStamps(model.sort, for: hit))
                Spacer(minLength: 0)
                if !card.books.isEmpty {
                    Text(tokens.chromeLabel(card.books.joined(separator: " · ")))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent.opacity(0.85))
                        .lineLimit(1)
                }
            }
            // The second line CARRIES ON from the lead (13u3 UNIT B): a card
            // that leads with the note's own words never repeats them here,
            // and never claims the note is empty when it has just said what
            // is in it.
            if let preview = LibraryCardName.previewLine(name) {
                let empty = preview == LibraryCopy.noTextYet
                Text(preview)
                    .font(tokens.small)
                    .foregroundStyle(empty ? tokens.faint : tokens.muted)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            // 13e E8: the same tags face the List row wears. Quiet on an
            // untagged card until the pointer arrives, so her
            // Apple-Notes-shaped list stays what it is at rest.
            tagsRow(hit, revealsOnHover: true)
        }
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture { onOpen(.post(hit.id)) }
        .contextMenu { postRowMenu(hit) }
        .help("Open this note")
    }

    /// 13e E8: ONE tags face, both note renderers — the `postRowMenu`
    /// pattern (13g R5-6), applied to the row's tags so the List row and
    /// the note card can never offer different tag doors on the same note.
    /// Every write goes through the model, which owns the ops calls and the
    /// re-read.
    private func tagsRow(_ hit: Queries.CatalogHit, revealsOnHover: Bool = false) -> some View {
        NoteTagsRow(
            tokens: tokens,
            tags: model.postTags[hit.id] ?? [],
            allTags: tags.tags,
            onApply: { path in
                Task { await model.applyTypedPath(path, to: [hit.id]) }
            },
            onRemove: { tag in
                Task { await model.removeTag(tag.id, from: [hit.id]) }
            },
            revealsOnHover: revealsOnHover)
    }

    private func postRow(_ hit: Queries.CatalogHit) -> some View {
        // The TITLE opens instantly, as today — her click model keeps this
        // road exactly. The tags column (R46) wears the note's OWN chip
        // grammar since 13e E8 — colour, leaf, ✕ off, ＋ types one on; the
        // sheet stays reachable from the row's context menu ("Tags…").
        // Act 10 item 10 — her click model, on P-0's reachable routing: a
        // DOUBLE-CLICK anywhere opens (it weirdly didn't); a single body
        // click routes through the model AT ONCE — select + info panel, or
        // the ⌘/⇧ pick. The title's own tap (in the line) still opens
        // instantly. The row's click SHELL is `CatalogNoteRowShell` (one
        // shared tap brain, `rowClick` — ladder R1-2: the stacked count-2 +
        // plain gestures held every single click for the double-click
        // interval, batch C's row-25 lag, alive here since batch E rebuilt
        // the panel behind this click).
        CatalogNoteRowShell(
            postID: hit.id,
            onClick: { modifiers in
                withAnimation(Self.panelAnimation) {
                    model.clickNoteRow(hit.id, modifiers: modifiers)
                }
            },
            onDoubleClick: { openHit(hit) }
        ) {
            // ONE rule, asked once (the 17q ladder's R1-7): the pair carries
            // both of this row's slots — the beside-the-title day (the 18h
            // ladder's R3-2: the one brain's words, standing down under the
            // `date` sort where the trailing stamp already says that day) and
            // the trailing stamp, which IS the sort's own (`sorted`).
            let stamps = LibrarySortFace.rowStamps(model.sort, for: hit)
            // 13u3 UNIT B: the row leads with the same answer the card does —
            // ONE composition, so the two modes can never call a note two
            // different things (`LibrarySortFace`'s own reason, applied to
            // the name).
            let name = LibraryCardName.card(
                for: hit, leadingTexts: model.noteCards[hit.id]?.leadingTexts ?? [])
            CatalogNoteLine(
                tokens: tokens, title: name.lead.text,
                date: stamps.listDay,
                tags: model.postTags[hit.id] ?? [], allTags: tags.tags,
                onTitleTap: { openHit(hit) },
                onApply: { path in Task { await model.applyTypedPath(path, to: [hit.id]) } },
                onRemove: { tag in Task { await model.removeTag(tag.id, from: [hit.id]) } },
                stamp: stamps.sorted,
                oracleKey: hit.id)
        }
        .draggable(hit.id)
        .contextMenu { postRowMenu(hit) }
    }

    /// 13g R5-6: ONE note-row menu, two renderers (the List mode's row and
    /// the Notes mode's card) — the `.openBeside` shape, so the two lists
    /// can never offer different doors on the same note.
    @ViewBuilder
    private func postRowMenu(_ hit: Queries.CatalogHit) -> some View {
        Button("Open") { onOpen(.post(hit.id)) }
        if let onOpenBeside {
            Button(WorkspaceNaming.openBesideVerb) { onOpenBeside(hit.id) }
        }
        if let starDoor {
            Button(starDoor.title(for: .post(hit.id))) { starDoor.toggle(.post(hit.id)) }
        }
        if let onOpenInNewWindow {
            Button(CapabilityRegistry.capability(.openInNewWindow).verb) {
                onOpenInNewWindow(hit.id)
            }
        }
        Button("Rename…") {
            // 13g batch 7 (R6-3): a hit's `title` is already the display
            // answer, so a note showing its DATE must not seed the field
            // with that date — she would be naming it after itself.
            renameTitle = hit.storedTitle ?? ""
            renameTarget = hit.id
        }
        Button("Tags…") {
            tagSheetTarget = .init(id: hit.id, title: hit.title)
        }
        Divider()
        // version_of DOOR 1 (Phase 11 A2's TWO-door ratification; the same
        // op door 2 emits). **pre-13u Act 10 wave 2b (item 14):** the flat
        // corpus-enumerating submenu retires (manifest row 06 — "this is a
        // disaster") for the ONE searchable note picker: bounded search,
        // version peers ranked first and annotated, snippet + day context
        // per row. The CAPABILITY is byte-identical — the pick still fires
        // `library.markAsVersions`, refusals still speak.
        Button("Mark as Versions with…") {
            versionPickTarget = VersionPickTarget(postID: hit.id, act: .mark)
        }
        // Sitting 9 (R60/R68): the inverse door beside the mark. The picker
        // edition offers EXACTLY the linked peers — the old "an unlinked
        // pick speaks its refusal" corner is now unreachable by
        // construction (nothing unlinked is offered), which is strictly
        // more honest than speaking after a bad offer.
        Button("Unmark Versions with…") {
            versionPickTarget = VersionPickTarget(postID: hit.id, act: .unmark)
        }
        Button("Duplicate as Version") {
            Task { await library.duplicateAsVersion(postID: hit.id) }
        }
        Divider()
        // The per-post export doors (Phase 11b B1's ratified context-
        // menu shapes — round 2, MAJOR 5: restored).
        Menu("Export") {
            Button("Markdown…") { exportPost(hit, includeVariants: false) }
            Button("Markdown with Takes…") { exportPost(hit, includeVariants: true) }
            Button("PDF…") { exportPostPDF(hit) }
        }
        Divider()
        // Ledger row 25 (FOUND-ITEM 2): the verb comes from its declaration
        // now, and the act says where the note went (`LibraryViewModel
        // .archive`'s receipt).
        Button(CapabilityRegistry.capability(.archiveNote).verb) {
            Task {
                await library.archive(postID: hit.id)
                await model.search()
            }
        }
        // 13l Act 2 (item 3) — HER RULING: *"add a confirmation for the
        // library door of deletion."* It shipped as a bare `Delete` that
        // tombstoned a whole note on one click, said nothing about where it
        // went, and left every pane showing it standing on the tombstone.
        // One wording with the note ▾ door, from the one shared host.
        Button(RecoveryCopy.deleteNoteTitle, role: .destructive) {
            Task { pendingDelete = await NoteDeletion.ask(
                session: session, postIDs: [hit.id]) }
        }
    }

    // MARK: - Export doors (Phase 11b B1's ratified shapes, restored —
    // round 2, MAJOR 5; the panel is the author-visible moment, the
    // projection shapes live in Queries)

    private func exportPost(_ hit: Queries.CatalogHit, includeVariants: Bool) {
        let name = exportFileName(hit)
        guard let url = ExportPanels.saveFile(
            defaultName: "\(name).md", type: .markdownFile) else { return }
        Task {
            let exporter = ExportModel(session: session)
            if let markdown = await exporter.markdown(
                forPost: hit.id, includeVariants: includeVariants) {
                exporter.writeMarkdown(markdown, to: url)
            }
        }
    }

    private func exportPostPDF(_ hit: Queries.CatalogHit) {
        let name = exportFileName(hit)
        guard let url = ExportPanels.saveFile(
            defaultName: "\(name).pdf", type: .pdf) else { return }
        Task {
            let exporter = ExportModel(session: session)
            if let data = await exporter.pdfData(forPost: hit.id) {
                exporter.writePDF(data, to: url)
            }
        }
    }

    private func exportFileName(_ hit: Queries.CatalogHit) -> String {
        // 13g batch 7 (R6-3): the hit's name is already the display brain's
        // answer, so the date case needs no second test here — a note with
        // no name exports as its date, which is what the bulk manifest has
        // named it since 11b.
        let title = Queries.sanitizedFilename(hit.title)
        return title.isEmpty ? DisplayTitle.placeholder : title
    }
}

/// One grouped tag-chip load shared by the Library and the Pool (round 2
/// NIT: the per-post loops were N round trips each).
/// 13g batch 6 (R5-6) — the Apple-Notes-shaped row's two read-time extras.
///
/// Her ask: *"I also want to make a different view in the library that is
/// more similar to the apple notes view where you can see the first little
/// bit of text."*
///
/// NOTHING IS STORED (the no-denormalization rule): the snippet is derived
/// on every read from the blocks themselves, and the books come from the
/// membership rows. Both are **bounded twice** — to the posts already
/// listed (the catalog's own limit), and, for the snippet, to each post's
/// FIRST FEW BLOCKS via a window function, so a 10,000-block note costs the
/// same as a three-block one (P1: cost ∝ what is listed, never ∝ the note).
///
/// Two honest simplifications, recorded rather than hidden:
///   · the snippet resolves `chosen → default` and requires that variant to
///     be live; the editor's full read-time rule ALSO falls back when the
///     chosen take is archived. A snippet that goes to the next block in
///     that corner is a display aid behaving conservatively, not a second
///     rendering brain — `renderPost` remains the one that matters;
///   · **the books are CURATED memberships PLUS the smart books that collect
///     the note** (13k K4 — her ruling reversing the shipped curated-only
///     card: *"the number of specifically defined smart books you have is
///     probably small, no? you still have to choose to deliberately create a
///     smart book"*). The earlier reading — that a smart walk "must not be
///     done for forty rows" — was right about the OBVIOUS query and wrong
///     about the necessary one: `Queries.smartBookMembership` drives from the
///     PAGE (a `CROSS JOIN` over its ids, one statement per smart book) and
///     is therefore ∝ books × THE ROWS IT IS HANDED and FLAT in corpus,
///     measured at 10× and pinned on the plan. A 200-row page costs 0.15 ms
///     at her one smart book, one-shot per listing load.
///
///     **What hands it those rows changed at 18h batch 2's ladder (R2-3):**
///     it used to be "rows on screen", which meant `limitPerKind` — a hard
///     40. With a DAY armed the listing is uncapped (the day's answer is a
///     SET, R1-4), so this runs over the day's whole answer. That is still
///     what P1 asks for — cost ∝ the answer the query returned, never ∝ the
///     corpus — and a day's answer is small by construction (her own walk
///     found "30-odd" for a busy day). The accepted ceiling, said plainly: a
///     day on which she edited a thousand notes would load a thousand cards
///     per keystroke. If that day ever exists, the fix is to bound these
///     derived reads to the DRAWN window rather than to the answer.
enum NoteCards {
    struct Card: Equatable {
        /// **The note's opening blocks' text, in order** (13u3 UNIT B): the
        /// ONE fact both of the card's lines are derived from — its LEAD
        /// (`NoteCardFace`, when the note has no name of its own) and the
        /// preview under it. Raw as the read returned them, because the
        /// rendering, the trimming and the cap are the brain's and a
        /// pre-chewed string would be a second rule.
        var leadingTexts: [String] = []
        var books: [String] = []

        /// **The first block with text in it** — the shape 13g shipped and
        /// what the 13g pins still hold. A computed answer now rather than a
        /// stored second fact, so the card's words and this one can never
        /// disagree.
        var snippet: String {
            leadingTexts.lazy
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .first { !$0.isEmpty } ?? ""
        }
    }

    /// How many leading blocks a snippet may consult before giving up.
    nonisolated static let blockWindow = 3
    /// How much text a snippet may carry (the row shows ~2 lines).
    nonisolated static let snippetLimit = 220

    /// `includingBooks: false` reads the WORDS only — the List mode's shape
    /// (13u3 UNIT B): its row has no book-names slot, so a listing that is
    /// not drawing one must not pay for the membership reads (the smart walk
    /// included). One flag rather than a second loader.
    nonisolated static func load(
        _ db: Database, postIDs: [String], includingBooks: Bool = true
    ) throws -> [String: Card] {
        let json = String(
            decoding: (try? JSONEncoder().encode(postIDs)) ?? Data("[]".utf8),
            as: UTF8.self)
        var result: [String: Card] = [:]

        let snippets = try Row.fetchAll(
            db,
            sql: """
                SELECT post_id, text FROM (
                  SELECT cb.container_id AS post_id,
                         substr(COALESCE(\(Queries.renderedTakeTextSQL), ''), 1, \(snippetLimit))
                           AS text,
                         ROW_NUMBER() OVER (
                           PARTITION BY cb.container_id ORDER BY cb.position, cb.id
                         ) AS n
                  FROM container_block cb
                  JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                  -- 13u3 UNIT G (UNIT B's hand-up): the ONE resolution the
                  -- note itself renders by. This read used to be a bare
                  -- `COALESCE(cb.chosen_variant_id, b.default_variant_id)`,
                  -- which previewed an ARCHIVED chosen take's words, blanked
                  -- the card on a TOMBSTONED one, and showed another block's
                  -- prose through a FOREIGN pointer.
                  \(Queries.renderedTakeJoinSQL)
                  WHERE cb.deleted_at IS NULL
                    AND cb.container_id IN (SELECT value FROM json_each(?))
                ) WHERE n <= \(blockWindow)
                ORDER BY post_id, n
                """,
            arguments: [json])
        for row in snippets {
            let postID: String = row["post_id"]
            // Every leading slot the window returned, in its own order — the
            // brain decides which of them is a name and which is the preview
            // (13u3 UNIT B; this used to keep the first non-empty one and
            // throw the rest away, which left a card that LEADS with a
            // heading nothing to say underneath it).
            result[postID, default: Card()].leadingTexts.append(row["text"] as String? ?? "")
        }

        guard includingBooks else { return result }

        let books = try Row.fetchAll(
            db,
            sql: """
                SELECT rp.post_id AS post_id, r.name AS name
                FROM reading_post rp
                JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL
                WHERE rp.deleted_at IS NULL
                  AND rp.post_id IN (SELECT value FROM json_each(?))
                ORDER BY rp.post_id, r.name
                """,
            arguments: [json])
        for row in books {
            result[row["post_id"] as String, default: Card()].books.append(row["name"])
        }

        // 13k K4: the smart half, through the ONE page-driven read. Curated
        // names come FIRST (a membership row is a decision she made; a smart
        // match is one the filter made), each half already in its own
        // alphabetical order, and a name appearing in both halves shows ONCE
        // — a card row reading "Ideas, Ideas" is worse than the rare
        // ambiguity of two same-named books (a build-time call, #53(l)).
        for (postID, names) in try Queries.smartBookMembership(db, postIDs: postIDs) {
            var merged = result[postID, default: Card()].books
            for name in names where !merged.contains(name) { merged.append(name) }
            result[postID, default: Card()].books = merged
        }
        return result
    }
}

enum TagChips {
    /// 13e E8: the chips load whole TAGS, not paths. Her round-11 ask was
    /// *"see the posts at a high level and remove / add them"*, and removing
    /// needs the tag's identity — resolving a path back to an id at click
    /// time would be a second lookup that can disagree with what is drawn.
    /// One grouped query still (the round-2 NIT's rule: never N round
    /// trips), bounded to the listed posts.
    nonisolated static func load(
        _ db: Database, postIDs: [String]
    ) throws -> [String: [Tag]] {
        let json = String(
            decoding: (try? JSONEncoder().encode(postIDs)) ?? Data("[]".utf8),
            as: UTF8.self)
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT pt.post_id AS chip_post_id, t.*
                FROM post_tag pt
                JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                WHERE pt.deleted_at IS NULL
                  AND pt.post_id IN (SELECT value FROM json_each(?))
                ORDER BY pt.post_id, t.path
                """,
            arguments: [json])
        var result: [String: [Tag]] = [:]
        for row in rows {
            // The join's own column is aliased so it can never collide with
            // a tag column; `Tag` decodes the rest and ignores it.
            result[row["chip_post_id"] as String, default: []].append(try Tag(row: row))
        }
        return result
    }
}


// MARK: - The two List-mode row LINES (the Act 10 correction round, rows 10 + 11)

/// **A book row's line** — icon · title · the kind label — on ONE text
/// baseline. Her report (image 5): *"the word book is misaligned"*. The
/// mechanism: the row's `HStack` had no alignment, so the smaller kind label
/// centered vertically against the body-size title and its baseline sat
/// below the title's. Extracted as its own view so a pin can mount the line
/// alone and read its baselines.
struct CatalogBookLine: View {
    let tokens: VoiceTokens
    let title: String
    let detail: String?
    let onTitleTap: () -> Void

    static let probeSpace = "catalog-book-line"

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            // A symbol in a `Text` carries the title's own baseline (a bare
            // `Image` would hand the stack its bottom edge).
            Text(Image(systemName: "book"))
                .font(tokens.body)
                .foregroundStyle(tokens.muted)
            Text(title)
                .font(tokens.body)
                .baselineProbe("book.title", in: Self.probeSpace)
                .onTapGesture(perform: onTitleTap)
            if let detail {
                Text(tokens.chromeLabel(detail))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .baselineProbe("book.kind", in: Self.probeSpace)
            }
            // Row 33 (a): the line spans its row, as the note line's does —
            // so the row's target is the row, never only its words.
            Spacer(minLength: 0)
        }
        .coordinateSpace(name: Self.probeSpace)
        .libraryGeometryProbe(.bookLine)
    }
}

/// **A note row's line** — title · date · the tag cards and their ＋ — on
/// ONE text baseline. Her report (image 4): *"the tags are also misaligned
/// from the text"*. The row already aligned on `.firstTextBaseline`; the
/// chips did not carry one (see `NoteTagChips.chip`), so the stack aligned
/// the title to a symbol's bottom edge instead. Extracted for the same pin.
struct CatalogNoteLine: View {
    let tokens: VoiceTokens
    let title: String
    /// **The day she STATED** (`container.entry_date`), or nothing. Worded
    /// by the one brain since 17q (the 18h ladder's R3-2 — this slot printed
    /// the RAW stored `2026-09-08` beside worded stamps, so the List row and
    /// the Notes card spoke one note's time in two grammars); the CALLER
    /// decides whether the row carries it at all
    /// (`LibrarySortFace.RowStamps.listDay` — nothing under the `date` sort,
    /// where the trailing stamp already says that day).
    let date: String?
    let tags: [Tag]
    let allTags: [Tag]
    let onTitleTap: () -> Void
    let onApply: (String) -> Void
    let onRemove: (Tag) -> Void
    /// **18h batch 1 (her row 9):** the muted trailing stamp — the SORT'S
    /// own (`LibrarySortFace.rowStamp`), worded by the one brain. Defaulted
    /// to nothing so the shipped alignment pins construct the line exactly as
    /// they did and keep measuring exactly what they measured.
    var stamp = LibrarySortFace.RowStamp(subject: .edited, stamp: nil)
    /// "now" for the stamp's words, injected by the pin that fixes the clock.
    var now: Date = Date()
    /// The note this row is about — the DEBUG words oracle's key (17q; nil
    /// off the pinned surfaces, and the oracle itself is DEBUG-only).
    var oracleKey: String?

    static let probeSpace = "catalog-note-line"

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                // ONE line, as the Notes card's title has always been (13u3
                // UNIT B): the row IS a single baseline — a title, a day, the
                // chips and the stamp all sit on it — so a wrapped name would
                // break the alignment those pins measure. It also makes the
                // two modes agree about a long name: both truncate.
                .lineLimit(1)
                .baselineProbe("note.title", in: Self.probeSpace)
                .onTapGesture(perform: onTitleTap)
            if let date {
                CatalogRowStamp(
                    tokens: tokens,
                    face: LibrarySortFace.RowStamp(subject: .dated, stamp: date), now: now,
                    baselineProbePrefix: "note", baselineProbeSpace: Self.probeSpace,
                    baselineProbeName: "date",
                    oracleKey: oracleKey, oracleSlot: "row.date")
            }
            NoteTagsRow(
                tokens: tokens, tags: tags, allTags: allTags,
                onApply: onApply, onRemove: onRemove,
                baselineProbePrefix: "note", baselineProbeSpace: Self.probeSpace)
            Spacer()
            // Her row 9: *"see the created time and last edited time easily
            // on the library."* At the row's trailing edge, muted, on the
            // title's own baseline, the whole fact on hover.
            CatalogRowStamp(
                tokens: tokens, face: stamp, now: now,
                baselineProbePrefix: "note", baselineProbeSpace: Self.probeSpace,
                oracleKey: oracleKey, oracleSlot: "row.stamp")
        }
        .coordinateSpace(name: Self.probeSpace)
    }
}

/// The note row's click SHELL (ladder R1-2): the whole row is the target,
/// the shared `rowClick` brain decides single vs double, and the modifiers
/// arrive as the click model's own `NoteRowClickModifiers`. Internal so the
/// pin can mount ONE row alone in a real window and click it for real (the
/// workbench shell's own pin shape — the whole catalog under the rig's
/// event pump hangs, as the whole workbench did in batch C).
struct CatalogNoteRowShell<Content: View>: View {
    let postID: String
    let onClick: (NoteRowClickModifiers) -> Void
    let onDoubleClick: () -> Void
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .contentShape(Rectangle())
            .libraryGeometryProbe(.noteRow(postID))
            .rowClick(
                onClick: { modifiers in
                    onClick(NoteRowClickModifiers(
                        command: modifiers.contains(.command), shift: modifiers.contains(.shift)))
                },
                onDoubleClick: onDoubleClick)
    }
}
