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
    static let surfaceCapabilities: [CapabilityID] = [.tagNote, .deleteSelectedNotes, .mcpShareNotes]

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
    /// door (nil falls back to plain navigation). 13o U2 (D6): a search
    /// passage's landing carries its find seed beside the block.
    var onOpenBlock: ((SidebarSelection, String, EditorFindSeed?) -> Void)? = nil
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
    /// 13i-d U5: the cross-wing note doors' brain (owned by the composition
    /// root); nil in harness mounts — the doors are then not drawn.
    var wings: WingsModel? = nil
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
    /// 13n-c U3: the window's road to the MCP door (nil in harness mounts —
    /// no share door; R-AIR-8 — none without an approved client).
    @Environment(\.mcpShareRoad) private var mcpShareRoad
    @State private var tagSheetTarget: SidebarView.TagSheetTarget?
    /// 13i-d U5: the move's confirm (the books the note would leave).
    @State private var wingMove: WingsModel.MoveAsk?
    /// 13i-c U4 — THE BADGE FAMILY outside a book (§6): the listed notes'
    /// owned-by facts, ONE page-driven observation (P1 — ∝ the hits).
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
    /// 17y B1 (k) — the List area's height and the books List's measured row
    /// pitch / lead (the rider's split threshold, read off what the List drew).
    @State private var listAreaHeight: CGFloat = 0
    @State private var bookRowPitch: CGFloat = LibraryBooksRegion.defaultPitch
    @State private var bookRowTops: [Int: CGFloat] = [:]
    #if DEBUG
    /// **This catalog's own name in the DEBUG oracle** (18k UNIT C4 — the
    /// `MastheadStamp.oracleOwner` shape): its probes read it by environment,
    /// and the catalog takes exactly its own frames with it when it leaves.
    @State private var oracleOwner = UUID()
    #endif

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
                // 13o U2 (Direction C, R-13o-15): the search state's ONE
                // piece of furniture — the band — whenever the field asks
                // anything or a day is armed (P-13o-U2-1).
                if showsBand {
                    searchBand
                    Divider().overlay(tokens.line)
                }
                switch model.mode {
                case .list where model.isSearching,
                     .notes where model.isSearching:
                    // The answer sheet, in every mode that lists notes (D2) —
                    // a question WITH WORDS. VX-84a (D-1): a `#tag` typed
                    // alone is the Library's OWN listing, narrowed (the band
                    // above it still says the question).
                    searchSheet
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
        #if DEBUG
        .environment(\.debugOracleOwner, oracleOwner)
        .onDisappear { LibraryPanelOracle.release(owner: oracleOwner) }
        #endif
        // 13i-d U5: a wing switch re-asks the catalog (the wing is part of
        // the question).
        .task(id: session.wing.currentID) { await model.search() }
        // 17y B3 item (l): the book rows' menu facts — the listed books only.
        .task(id: model.listedBookIDs) { await model.bookRowDoors.load(model.listedBookIDs) }
        .bookRowDoors(model.bookRowDoors)
        .wingMoveConfirm($wingMove, wings: wings) { Task { await model.refresh() } }
        // 13i-c U4: the owned-by badge's facts — 17y B1 (k): the MODEL holds
        // them for the NEAR WINDOW only (the pages around what is on screen),
        // so the held region stays a few pages however deep she scrolls; the
        // hold ends with the listing.
        .onAppear { model.holdNearFacts() }
        .onDisappear { model.stopHoldingFacts() }
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
                    await model.refresh()
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
            Task { await model.refresh() }
        }
    }

    // MARK: - The search state's faces (13o U2 — Direction C, R-13o-15)

    /// The band shows whenever the field asks anything, or a day is armed —
    /// never in the Timeline, which runs its own listing.
    private var showsBand: Bool {
        model.showsCatalogControls && (model.searchState.asksAnything || model.editedOn != nil)
    }

    private var searchBand: some View {
        let state = model.searchState
        return LibrarySearchBand(
            tokens: tokens, question: state.question,
            counts: state.counts?.kinds(state.visibility),
            visibility: state.visibility,
            wingName: wings?.currentName ?? WingWords.home,
            dayChip: model.editedRange.map { range in
                (label: LibraryDayFace.chipLabel(range, now: Date()),
                 help: LibraryDayFace.caveat,
                 onClear: {
                     model.setEditedRange(nil)
                     Task { await model.search() }
                 })
            },
            onRemoveTag: { path in
                model.removeTypedTag(path)
                Task { await model.search() }
            },
            onToggleArchived: {
                model.toggleArchivedFacet()
                Task { await model.search() }
            },
            // 13o U3 — the mode facet: arming moves a notes/blocks scope to
            // Books (the day's mirror); the ✕ clears it.
            bookState: state.bookState,
            offersBookState: model.offersBookState,
            onPickBookState: { picked in
                model.armBookState(picked)
                Task { await model.search() }
            },
            // VX-84b (D-2): the press is the explicit act — fire-and-DO.
            tagOffers: state.tagOffers,
            onAcceptTagOffer: { offer in
                model.acceptTagOffer(offer)
                Task { await model.search() }
            },
            // VX-72 — the commits facet (a new question: the caller re-reads).
            includesSavepoints: state.includesSavepoints,
            onToggleSavepoints: {
                model.toggleSavepointsFacet()
                Task { await model.search() }
            })
    }

    private var searchSheet: some View {
        LibrarySearchSheet(
            model: model, tokens: tokens,
            onShowArchived: {
                model.toggleArchivedFacet()
                Task { await model.search() }
            },
            onOpenPassage: { openPassage($0) },
            onOpenPool: { onOpen(.pool($0)) },
            noteHead: { hit in
                LibraryListRow {
                    postRow(hit)
                } background: {
                    rowBackground(
                        picked: model.selectedPosts.contains(hit.id),
                        subject: model.infoHit?.id == hit.id)
                }
            },
            bookRow: { hit in
                LibraryListRow {
                    bookLine(hit)
                } background: {
                    rowBackground(picked: false, subject: model.infoHit?.id == hit.id)
                }
            })
    }

    /// **A passage was clicked — LAND AT THE MATCH** (13o U2, D6 — her
    /// land-at-match): its note (or scraps group) opens IN WRITE AT ITS
    /// BLOCK through the shell's caret-precise landing road (Stage C), with
    /// the passage's matched words as the find seed — the arriving editor
    /// selects the match and arms the find bar, so ⌘G steps onward. A
    /// name-level hit with no block opens the note.
    private func openPassage(_ passage: SearchPassage) {
        guard let home = passage.noteID else { return }
        withAnimation(Self.panelAnimation) { model.closeInfo() }
        let selection: SidebarSelection = passage.family == .scraps ? .pool(home) : .post(home)
        if let block = passage.blockID, let onOpenBlock {
            onOpenBlock(selection, block, SearchLanding.findSeed(
                kind: passage.kind, rendered: passage.isRenderedTake, snippet: passage.snippet))
        } else {
            onOpen(selection)
        }
    }

    /// Open a hit at its own kind's destination — the one opening road the
    /// title click, the double-click, the context menu and the panel's Open
    /// door all take. Where a NOTE lands is the note-open door's one rule (18l
    /// U0c, her R-18l-1 — `CommandRouter.registerDetail`): the session's first
    /// open of a note shows its START; a re-open this session restores the
    /// page she left. (Batch E's "lands where the caret last was" — her R-cor-3
    /// — is superseded for the session's first open by that ruling.)
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
        switch Self.messageSlot(
            error: model.lastError ?? library.lastError, receipt: library.receipt,
            quietReceipt: session.status.quietLine != nil) {
        case .quiet:
            // 13i-d U6 (j) — KnownIssues row 103's LIBRARY half (F-U5-8: the
            // move/copy-to-wing receipts, the row menus' Remove/Release, every
            // status-seam receipt spoken here landed nowhere visible under
            // her default QUIET style). The one slot this surface already
            // lays out for its words — above the bottom divider — hosts the
            // seam's quiet line when nothing of its own speaks.
            QuietReceiptLine(status: session.status, tokens: tokens)
                .padding(.horizontal, 24)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .libraryGeometryProbe(.message)
        case .error, .receipt, .none:
            ownMessageRow
        }
    }

    /// **The Library's one message slot, decided** (13i-d U6 (j)): its own
    /// error first (always shown — a refusal), then its own receipt (the
    /// archive door's sentence), then the status seam's QUIET receipt; else
    /// nothing (no reserved blank line).
    enum MessageSlot: Equatable { case error, receipt, quiet, none }

    /// How far the native segmented controls draw their labels below the
    /// text controls' shared line (13i-d U6 (c) — measured, both voices).
    static let segmentedLabelDrop: CGFloat = 1
    static func messageSlot(error: String?, receipt: String?, quietReceipt: Bool) -> MessageSlot {
        if error != nil { return .error }
        if receipt != nil { return .receipt }
        return quietReceipt ? .quiet : .none
    }

    @ViewBuilder private var ownMessageRow: some View {
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
                // 17y B-WALK W-2 (her ruling): picking All while in Cards
                // moves the view to List — the model's door decides.
                Picker("", selection: Binding(get: { model.scope }, set: { model.pickScope($0); Task { await model.search() } })) {
                    ForEach(LibraryCatalogModel.Scope.allCases, id: \.self) { scope in
                        Text(tokens.chromeLabel(scope.label)).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 280)
                // 18h batch 2: a day names NOTES — books and blocks carry no
                // edit stamp and stand down while one is armed, so the scope
                // stands down with them rather than offering picks that
                // would list nothing (P-2).
                // 13o U3: an armed MODE FACET names BOOKS the same way, so
                // the scope stands down under it too (PROVISIONAL P-13o-U3-3).
                .disabled(model.editedOn != nil || model.searchState.bookState != nil)
                .help(model.editedOn != nil ? LibraryCopy.scopeDoorUnderADay
                      : (model.searchState.bookState != nil
                         ? LibrarySearchCopy.scopeDoorUnderABookState : LibraryCopy.scopeDoor))
                // 17y B-WALK W-2 (her ruling): picking Cards moves the scope
                // All → Notes (Cards shows notes only); a moved scope is a
                // new question, so it re-reads.
                Picker("", selection: Binding(get: { model.mode }, set: {
                    if model.pickMode($0) { Task { await model.search() } }
                })) {
                    // 17y (d): each mode's word from its one home — "Cards".
                    ForEach(LibraryCatalogModel.Mode.allCases, id: \.self) { mode in
                        Text(tokens.chromeLabel(mode.label)).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 230)
                // 18h batch 1 (her row 10): the notes' order, hers to
                // choose. The Timeline mode is its own order by definition,
                // so the door stands down there rather than lying.
                if model.showsCatalogControls {
                    // 13i-d U6 (c) — her §21 note, "the 'edited · newest first'
                    // dropdown is slightly misaligned", MEASURED on the walk in
                    // both voices: the native segmented controls draw their
                    // labels 1 pt BELOW the line the text controls share
                    // (Terminal: label bottoms 238 px vs 236; Study: 244 vs
                    // 242, @2×), and the menu sits right beside a segmented
                    // control. First-text-baseline alignment changed nothing
                    // (the control reports a baseline its label does not
                    // draw on), so the menu and the day door meet the
                    // segmented line by `segmentedLabelDrop`.
                    if model.isSearching {
                        // 13o U2 (PROVISIONAL P-13o-U2-7): the answer sheet is
                        // ranked by relevance (D2), so the sort door — which
                        // could not change that order — stands down for the
                        // mockup's own words, a label (P-2: a door that
                        // cannot act is not drawn).
                        Text(tokens.chromeLabel(LibrarySearchCopy.relevance))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .help(LibrarySearchCopy.relevanceHelp)
                            .offset(y: Self.segmentedLabelDrop)
                    } else {
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
                        .offset(y: Self.segmentedLabelDrop)
                    }
                    // 18h batch 2 (her row 11): *"search for any note edited
                    // on a particular day."* 13o U2 (her R-13o-13): the door
                    // reads `when ▾` and grows its range; the armed state is
                    // the band's chip.
                    LibraryWhenDoor(
                        tokens: tokens, range: model.editedRange,
                        onPick: { range in
                            model.setEditedRange(range)
                            Task { await model.search() }
                        },
                        onClear: {
                            model.setEditedRange(nil)
                            Task { await model.search() }
                        })
                    .offset(y: Self.segmentedLabelDrop)
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
                    // 13n-c U3 (VX-156 item 2; mockup §2) — SHARE THE PICK: THE
                    // grant sheet pre-filled with these notes, in the listing's
                    // order; ONE act mints them on one stamp (one row in Shared
                    // places). R-AIR-8: only while an approved client exists.
                    if let road = mcpShareRoad, road.canShare {
                        Button(tokens.chromeLabel(MCPShareCopy.shareNotes(selectedPosts.count))) {
                            road.open(MCPGrantOpening(
                                place: .notes(selectedNotesInListOrder), origin: .place))
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
        // **17y B1 (k) — her rider, verbatim: "once books hit ~half of the
        // vertical area, books start to scroll within their own little view,
        // so that many books won't mean you see no notes."** Under "All", a
        // wing whose books would take more than HALF the listing's height
        // gets them in their OWN list, capped at half and scrolling inside
        // it; the notes keep the rest. Fewer books stay one list, exactly as
        // before (`LibraryBooksRegion.capsBooks` — the measured row pitch
        // decides, never a guessed count).
        let capped = LibraryBooksRegion.capsBooks(
            scope: model.scope, books: model.bookHits.count,
            showsMore: model.hasNoteRows,
            pitch: bookRowPitch, lead: LibraryBooksRegion.defaultLead, height: listAreaHeight)
        return VStack(spacing: 0) {
            if capped {
                // The capped books region keeps its construction (the brief:
                // "books region + section headers keep their construction
                // unless the seam forces otherwise") — a native List of its
                // own, scrolling inside its half.
                List { booksSection }
                    .scrollContentBackground(.hidden)
                    .background(tokens.surface)
                    .frame(height: LibraryBooksRegion.cappedHeight(listAreaHeight))
                    .libraryGeometryProbe(.booksRegion)
                Divider().overlay(tokens.line)
            }
            listColumn(includesBooks: !capped)
                .libraryGeometryProbe(.notesRegion)
        }
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { listAreaHeight = $0 }
    }

    /// **librarywalkpolish VR-113 (17y B-WALK W-1) — the List mode's ONE
    /// column, on the lazy engine Cards uses** (her answered #187(i): "the
    /// hit is too big... not in our app"): the books (when the region is not
    /// split off), the PAGED notes, the block hits — every row wearing the
    /// List's own face (`LibraryListFace`, measured off the table it
    /// replaces). THE SEAM, recorded: a `List` and a `LazyVStack` cannot
    /// share one scroll, so the books that scroll WITH the notes (the
    /// one-list shape, under the rider's threshold) and the three section
    /// headers render here in the List's face — the capped books region alone
    /// keeps its native List.
    private func listColumn(includesBooks: Bool) -> some View {
        let showsBooks = includesBooks && !model.bookHits.isEmpty
        let showsNotes = model.hasNoteRows
        // Row 56: the List draws NO selection of its own — the pick and the
        // panel's subject render through `rowBackground` (the wash + a tinted
        // border), on note and book rows alike; the model owns the pick.
        return ScrollView {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                if showsBooks {
                    Section {
                        LibraryListLead()
                        ForEach(Array(model.bookHits.enumerated()), id: \.element.id) { index, hit in
                            LibraryListRow {
                                bookLine(hit)
                            } background: {
                                rowBackground(picked: false, subject: model.infoHit?.id == hit.id)
                            }
                            .modifier(BookRowPitchProbe(index: index) { measuredBookRow(index, $0) })
                        }
                    } header: {
                        LibraryListHeader(title: tokens.chromeLabel("Books"))
                    }
                    if showsNotes { sectionGap }
                }
                if showsNotes {
                    Section {
                        if !showsBooks { LibraryListLead() }
                        // 17y B1 (k): the PAGED rows live in their own view, so a
                        // page landing re-draws the rows' list — never this whole
                        // catalog (measured: a page's stall was the catalog body).
                        LibraryPagedNotes(model: model, tokens: tokens, listFace: true) { hit in
                            LibraryListRow {
                                postRow(hit)
                            } background: {
                                rowBackground(
                                    picked: model.selectedPosts.contains(hit.id),
                                    subject: model.infoHit?.id == hit.id)
                            }
                        }
                    } header: {
                        LibraryListHeader(title: tokens.chromeLabel("Notes"))
                    }
                }
                if !model.blockHits.isEmpty {
                    // VX-84a (D-1): a `#tag` typed alone in the Blocks scope
                    // lists the blocks it names by their own tags — the
                    // catalog's own block rows (handle · its home), landing at
                    // the block.
                    if showsBooks || showsNotes { sectionGap }
                    Section {
                        if !showsBooks, !showsNotes { LibraryListLead() }
                        ForEach(model.blockHits, id: \.id) { hit in
                            LibraryListRow { blockLine(hit) }
                        }
                    } header: {
                        LibraryListHeader(title: tokens.chromeLabel(LibrarySearchCopy.blocksHeader))
                    }
                }
                if model.bookHits.isEmpty, !showsNotes, model.blockHits.isEmpty {
                    // 18h batch 2: a day that finds nothing says WHY — the one
                    // wording, shared with the Notes mode below.
                    LibraryListLead()
                    LibraryListRow {
                        if let range = model.rangeForEmptyAnswer {
                            LibraryDayEmptyAnswer(tokens: tokens, range: range, query: model.query)
                        } else {
                            Text(tokens.chromeLabel(LibraryCopy.nothingMatches))
                                .font(tokens.small)
                                .foregroundStyle(tokens.muted)
                        }
                    }
                }
                // (13o U2, R-13o-9: the truncation line LEFT with the block
                // cap — no Library listing is capped any more.)
                // VX-84a: under a tag typed alone the archive's matches are
                // offered at the foot, as the answer sheet's foot offers them.
                if let places = tagListingArchivedPlaces {
                    LibraryListRow { tagListingArchivedFoot(places) }
                }
            }
            .padding(.bottom, LibraryListFace.bottomInset)
        }
        .background(tokens.surface)
    }

    /// VX-84a: a tag typed alone (no words), the archived facet off, and the
    /// archive holding matches — the answer sheet's foot rule, on the listing.
    private var tagListingArchivedPlaces: Int? {
        let state = model.searchState
        guard state.question != nil, !model.isSearching, state.visibility == .living,
              let places = state.counts?.archivedPlaces, places > 0 else { return nil }
        return places
    }

    private func tagListingArchivedFoot(_ places: Int) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(tokens.chromeLabel(LibrarySearchCopy.archivedFoot(places)))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            Button(tokens.chromeLabel(LibrarySearchCopy.showArchived)) {
                model.toggleArchivedFacet()
                Task { await model.search() }
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            .font(tokens.small)
        }
    }

    /// **A listed BLOCK's line** (VX-84a — the Blocks scope under a tag typed
    /// alone; the pre-U2 block row's face): its handle, its home, a click
    /// lands at the block through the shell's caret-precise road (no find
    /// seed — nothing was searched as text).
    private func blockLine(_ hit: Queries.CatalogHit) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(Image(systemName: "square.on.square"))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            Text(hit.title)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
            if let home = hit.detail {
                Text(tokens.chromeLabel(LibrarySearchCopy.blockHome(home)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
            }
            if hit.isArchived {
                // Ladder R1 MINOR: a block the archived facet brought in says
                // so, exactly as the note rows do (R-13o-6, P-VX83-3).
                CatalogArchivedMark(tokens: tokens)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            guard let home = hit.homeContainerID else { return }
            withAnimation(Self.panelAnimation) { model.closeInfo() }
            let selection: SidebarSelection = hit.homeIsPool ? .pool(home) : .post(home)
            if let onOpenBlock {
                onOpenBlock(selection, hit.id, nil)
            } else {
                onOpen(selection)
            }
        }
    }

    /// The List's air between a section's last row and the next header.
    private var sectionGap: some View {
        Color.clear.frame(height: LibraryListFace.sectionGap)
    }

    /// The books, as one native List section — the CAPPED region's (the one
    /// place the books keep the table; the one-list shape draws them in the
    /// lazy column above, one row grammar).
    @ViewBuilder
    private var booksSection: some View {
        if !model.bookHits.isEmpty {
            Section(tokens.chromeLabel("Books")) {
                ForEach(Array(model.bookHits.enumerated()), id: \.element.id) { index, hit in
                    bookLine(hit)
                        .listRowBackground(
                            rowBackground(picked: false, subject: model.infoHit?.id == hit.id))
                        .modifier(BookRowPitchProbe(index: index) { measuredBookRow(index, $0) })
                }
            }
        }
    }

    /// 17y B1 (k): the first two book rows measure the row pitch (voice-proof
    /// — the rider's split threshold), whichever engine draws them (the
    /// List's face and the List give one pitch).
    private func measuredBookRow(_ index: Int, _ y: CGFloat) {
        guard index < 2 else { return }
        bookRowTops[index] = y
        if let first = bookRowTops[0], let second = bookRowTops[1],
           second - first > 8, second - first < 120 {
            bookRowPitch = second - first
        }
    }

    /// A BOOK row's line and its acts — one builder for both engines.
    private func bookLine(_ hit: Queries.CatalogHit) -> some View {
        // The TITLE opens instantly, as today (her click model — the body
        // selects, the words open).
        CatalogBookLine(
            tokens: tokens, title: hit.title,
            // 13o U3: under the archived facet an archived book says so.
            detail: model.searchState.archivedBooks.contains(hit.id)
                ? LibrarySearchCopy.archivedBookDetail(hit.detail) : hit.detail,
            // 13o U3: an ASSOCIATED book's row says why it is listed (the
            // tag-association join — the mockup's "#dream flows here").
            association: model.searchState.bookReasons[hit.id].map(LibrarySearchCopy.association),
            onTitleTap: { openHit(hit) })
        // Row 33 (a): the WHOLE row is the target — the line used to be only
        // as wide as its words, so a click right of "book" was a dead click
        // and the panel kept whatever it was showing.
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        // A body click selects AT ONCE and shows the book's OUTLINE in the
        // panel (her ruled model, row 33's shape); a double-click anywhere
        // opens. ONE shared tap brain (`rowClick`, ladder R1-2).
        .rowClick(
            onClick: { _ in
                withAnimation(Self.panelAnimation) { model.selectBook(hit) }
            },
            onDoubleClick: { openHit(hit) })
        // 17y B3 item (l): a BOOK row's menu — the Bookcase's trimmed of
        // position (`BookRowMenu`, one table).
        .contextMenu {
            BookRowMenu(
                readingID: hit.id, doors: model.bookRowDoors,
                starDoor: starDoor, open: { openHit(hit) })
        }
    }

    // (13o U2: the BLOCK hit's line LEFT with the block arm — a named block
    // or a scrap is a passage of its group on the answer sheet now, and lands
    // through `openPassage`, the same caret-precise road it used. VX-84a
    // brought a block line back for ONE listing — `blockLine`, above.)

    /// 13g batch 6 (R5-6) — the Apple-Notes-shaped list: title · date ·
    /// the first bit of text · the book it's in, per her screenshot. NOTES
    /// ONLY (books and blocks have no snippet to show and belong to the
    /// List mode's sections); a `LazyVStack` so the rows cost what is drawn.
    /// 17y B1 (k): PAGED like the List — the rows on screen ask for the next
    /// page and move the near window.
    private var notesBody: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                LibraryPagedNotes(model: model, tokens: tokens) { hit in
                    VStack(spacing: 0) {
                        noteCard(hit)
                        Divider().overlay(tokens.line.opacity(0.6))
                    }
                }
                if !model.hasNoteRows {
                    if let range = model.rangeForEmptyAnswer {
                        LibraryDayEmptyAnswer(tokens: tokens, range: range, query: model.query)
                            .padding(24)
                    } else {
                        Text(tokens.chromeLabel(LibraryCopy.noNotesMatch))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .padding(24)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .background(tokens.surface)
    }


    /// 13i-c U4 (§6): the owned-by badge a listed note wears (the Library is
    /// OUTSIDE every book), or nil — the setting silences the set.
    /// 17y B1 (k): read from the row's OWN slice (`rowExtras(for:)`), so
    /// another note's badge never re-draws this row.
    private func ownedByBadge(_ extras: LibraryNoteRowExtras) -> OwnershipBadgeFace.Badge? {
        OwnershipBadgeFace.badge(
            extras.facts, placement: .outside,
            badgesOn: themeStore?.settings.ownershipBadges ?? true)
    }

    private func noteCard(_ hit: Queries.CatalogHit) -> some View {
        // 17y B1 (k): the card reads its own slice of the extras — never the
        // whole listing's dictionaries (the measured page-landing stall).
        let extras = model.rowExtras(for: hit.id)
        let card = extras.card ?? NoteCards.Card()
        // 13u3 UNIT B (her item 4): what the card LEADS with — her title
        // where she typed one, a daily entry's day, else the note's own
        // first words. Derived at read time, never stored, nothing renamed.
        let name = LibraryCardName.card(for: hit, leadingTexts: card.leadingTexts)
        // librarywalkpolish VR-117: the card's metrics by voice — Terminal's
        // readability pass; Study's the shipped face, untouched.
        let face = LibraryCardFace.of(tokens)
        return VStack(alignment: .leading, spacing: face.leadToPreview) {
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
                // 13i-c U4 (§6): the owned-by badge — the note's owner,
                // clickable (the ascent), before the books line.
                if let badge = ownedByBadge(extras) {
                    OwnershipBadgeView(tokens: tokens, badge: badge, postID: hit.id)
                }
                if hit.isArchived {
                    CatalogArchivedMark(tokens: tokens)   // VX-84a
                }
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
                    .font(face.previewFont)
                    .lineSpacing(face.previewLineSpacing)
                    .foregroundStyle(empty ? tokens.faint : tokens.muted)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            // 13e E8: the same tags face the List row wears. Quiet on an
            // untagged card until the pointer arrives, so her
            // Apple-Notes-shaped list stays what it is at rest.
            tagsRow(hit, tags: extras.tags, revealsOnHover: true)
        }
        .padding(.vertical, face.verticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture { onOpen(.post(hit.id)) }
        .contextMenu { postRowMenu(hit) }
        // 13i-c U4 walk (W-2): the card's hover carries its badge's sentence.
        .help(OwnershipBadgeCopy.rowHelp("Open this note", badge: ownedByBadge(extras)))
    }

    /// 13e E8: ONE tags face, both note renderers — the `postRowMenu`
    /// pattern (13g R5-6), applied to the row's tags so the List row and
    /// the note card can never offer different tag doors on the same note.
    /// Every write goes through the model, which owns the ops calls and the
    /// re-read.
    private func tagsRow(
        _ hit: Queries.CatalogHit, tags rowTags: [Tag], revealsOnHover: Bool = false
    ) -> some View {
        NoteTagsRow(
            tokens: tokens,
            tags: rowTags,
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
            // 17y B1 (k): the row's OWN slice of the extras, never the whole
            // listing's dictionaries (the measured page-landing stall).
            let extras = model.rowExtras(for: hit.id)
            // 13u3 UNIT B: the row leads with the same answer the card does —
            // ONE composition, so the two modes can never call a note two
            // different things (`LibrarySortFace`'s own reason, applied to
            // the name).
            let name = LibraryCardName.card(
                for: hit, leadingTexts: extras.card?.leadingTexts ?? [])
            CatalogNoteLine(
                tokens: tokens, title: name.lead.text,
                date: stamps.listDay,
                tags: extras.tags, allTags: tags.tags,
                onTitleTap: { openHit(hit) },
                onApply: { path in Task { await model.applyTypedPath(path, to: [hit.id]) } },
                onRemove: { tag in Task { await model.removeTag(tag.id, from: [hit.id]) } },
                stamp: stamps.sorted,
                oracleKey: hit.id,
                badge: ownedByBadge(extras),
                badgePostID: hit.id,
                archived: hit.isArchived)
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
        // 13n-c U3 (VX-156 item 2; mockup §2): THE grant sheet pre-filled on
        // this note — only while an approved client exists (R-AIR-8).
        if let road = mcpShareRoad, road.canShare {
            Divider()
            Button(CapabilityRegistry.capability(.mcpShareHere).verb) {
                road.open(MCPGrantOpening(place: .note(hit.id), origin: .place))
            }
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
        // 13i-d U5 — the explicit cross-wing doors (the sitting record §9).
        if let wings {
            WingNoteDoors(
                wings: wings, postID: hit.id, title: hit.title,
                onAsk: { wingMove = $0 },
                onDone: { Task { await model.refresh() } })
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
                await model.refresh()
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
    /// 13o U3 — why an associated book is listed ("#dream flows here"),
    /// beside its name in the accent (the mockup's own); nil elsewhere.
    var association: String? = nil
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
            if let association {
                Text(tokens.chromeLabel(association))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .lineLimit(1)
            }
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
    /// 13i-c U4 (§6): the owned-by badge, or nil (the common case draws
    /// nothing, so the shipped alignment pins measure exactly what they did).
    var badge: OwnershipBadgeFace.Badge? = nil
    var badgePostID: String = ""
    /// VX-84a: the note is archived — only ever on the tag-alone listing
    /// under the archived facet (R-13o-6, "rows say which they are"); false
    /// draws nothing, so the shipped alignment pins measure what they did.
    var archived = false

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
            if let badge {
                OwnershipBadgeView(tokens: tokens, badge: badge, postID: badgePostID)
            }
            if archived {
                CatalogArchivedMark(tokens: tokens)
            }
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

/// **The quiet "archived" mark a listed note wears** (VX-84a — a `#tag`
/// typed alone with the archived facet on lists the tag's archived notes, and
/// each says so: R-13o-6's letter, the answer sheet's own badge word and
/// shape — `SearchAnswerCopy.archivedMark`).
struct CatalogArchivedMark: View {
    let tokens: VoiceTokens

    var body: some View {
        Text(tokens.chromeLabel(SearchAnswerCopy.archivedMark))
            .font(tokens.small)
            .foregroundStyle(tokens.muted)
            .padding(.horizontal, 5)
            .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(tokens.line))
            .lineLimit(1)
            .fixedSize()
            .help(SearchAnswerCopy.archivedNote)
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

/// 17y B1 (k) — a book row reports its top in the catalog's own space (the
/// rider's pitch measurement), on either engine.
private struct BookRowPitchProbe: ViewModifier {
    let index: Int
    let report: (CGFloat) -> Void

    func body(content: Content) -> some View {
        content.onGeometryChange(for: CGFloat.self) {
            $0.frame(in: .named(LibraryCatalogView.probeSpace)).minY
        } action: { report($0) }
    }
}
