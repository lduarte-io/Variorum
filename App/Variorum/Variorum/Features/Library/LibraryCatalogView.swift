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

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import UniformTypeIdentifiers
import VariorumCore

@MainActor
@Observable
final class LibraryCatalogModel {
    enum Scope: String, CaseIterable { case all, books, posts, blocks }
    /// 13g batch 6 (R5-6): `notes` joins as a THIRD view mode — her
    /// Apple-Notes-shaped list (title · date · the first bit of text · the
    /// book it's in). A mode beside the others, never a replacement.
    enum Mode: String, CaseIterable { case list, notes, timeline }

    @ObservationIgnored let session: AppSession
    var scope: Scope = .all
    var mode: Mode = .list
    /// Set by the view's binding, which also spawns `search()` — no hidden
    /// didSet task (deterministic under test; the generation guard orders
    /// the UI's unordered spawns).
    var query = ""
    private(set) var hits: [Queries.CatalogHit] = []
    /// 13e E8: the listed notes' live tags (whole rows — see `TagChips`).
    private(set) var postTags: [String: [Tag]] = [:]
    /// 13g R5-6: postID → the note card's read-time extras (snippet +
    /// books). Loaded ONLY in `.notes` mode and only for the hits on
    /// screen — the same bounded-to-what-is-listed discipline as
    /// `postTags`.
    private(set) var noteCards: [String: NoteCards.Card] = [:]
    private(set) var lastError: String?
    /// Generation-stamped adoption (round 2, MINOR — the Phase 8 ruling):
    /// per-keystroke tasks are unordered; only the NEWEST read may land.
    private var searchGeneration = 0

    // MARK: - The ⌘-click pick (P-0, 13l's end-of-phase ladder)

    /// The notes she has picked. **Model state, not the view's `@State`** —
    /// the defect P-0 names was a routing decision buried in a gesture
    /// closure, and the fix is only worth anything if the decision can be
    /// driven. It lives here so it can be.
    var selectedPosts: Set<String> = []
    /// The last row a ⌘/⇧-click named — a ⇧-range's other end.
    private(set) var selectionAnchor: String?

    /// The note ids **as this list is showing them**. Both ordered answers
    /// (the ⇧-range, and the confirm's list) come from here, because a `Set`
    /// has none.
    var listedNoteIDs: [String] {
        hits.filter { $0.kind == .post }.map(\.id)
    }

    /// The pick in list order — what the confirm and the receipt name.
    var selectedNotesInListOrder: [String] {
        listedNoteIDs.filter { selectedPosts.contains($0) }
    }

    /// **The info panel's subject** (Act 10 item 10 — her ruled click
    /// model): the row a body click selected, note or book. The panel
    /// renders while this is set; navigation, a mode switch and a listing
    /// that no longer shows the row all clear it.
    var infoHit: Queries.CatalogHit?

    /// **A click on a note row's BODY.** Her ruled model: a plain click
    /// SELECTS and shows the info panel (never opens — the title and a
    /// double-click are the opening clicks, routed at the view); ⌘ toggles
    /// the pick; ⇧ extends the range. The modifiers decide,
    /// `NoteRowSelection` says what the pick becomes, and the panel follows
    /// the row she last touched.
    func clickNoteRow(_ postID: String, modifiers: NoteRowClickModifiers) {
        let intent = NoteRowSelection.intent(for: modifiers)
        let next = NoteRowSelection.apply(
            intent, row: postID, to: selectedPosts,
            anchor: selectionAnchor, order: listedNoteIDs)
        selectedPosts = next.selection
        selectionAnchor = next.anchor
        infoHit = hits.first { $0.id == postID && $0.kind == .post }
    }

    /// A click on a BOOK row's body — same ruling, the book's facts.
    func selectBook(_ hit: Queries.CatalogHit) {
        selectedPosts = []
        selectionAnchor = nil
        infoHit = hit
    }

    /// The panel's own close door.
    func closeInfo() {
        infoHit = nil
    }

    /// Drop the pick. Called when the list stops being the surface showing it
    /// — a mode switch, or a delete that consumed it. A bar offering to delete
    /// notes she cannot see highlighted is the invisible-selection hazard the
    /// walk's own standard forbids.
    func clearSelection() {
        selectedPosts = []
        selectionAnchor = nil
        infoHit = nil
    }

    func deselect(_ postIDs: [String]) {
        selectedPosts.subtract(postIDs)
        if let anchor = selectionAnchor, postIDs.contains(anchor) { selectionAnchor = nil }
    }

    /// **Keep the pick to what the list is SHOWING** (13l, the end-of-phase
    /// ladder's R2-2 — `clearSelection`'s own standard, applied on the other
    /// road that changes what is on screen).
    ///
    /// The pick outlived its listing: `search()` re-reads `hits` on every
    /// typed query and scope change, and nothing touched `selectedPosts`. A
    /// note picked under one query stayed picked under the next, where its
    /// row is not drawn — so the bulk bar (`selectedPosts.count > 1`) could
    /// stand over notes nothing on screen highlights, the Tag/Untag menus
    /// would act on `Array(selectedPosts)` including them, and the counts in
    /// all three labels could disagree with the delete button's own
    /// `selectedNotesInListOrder` ("Delete 5 notes…" deleting 2).
    ///
    /// **Pruned, not cleared.** Clearing on every `search()` would be the
    /// simpler line and the wrong one: `search()` also re-runs after a bulk
    /// tag apply/remove and after a delete, so a pick would evaporate under
    /// the very act it was made for. Intersecting drops exactly the rows that
    /// left, and leaves a pick whose rows are still drawn alone. The mode
    /// rule stays a CLEAR because leaving List mode draws no selection at all.
    private func pruneSelectionToListing() {
        // The info panel follows the listing exactly as the pick does: a
        // panel describing a row the list no longer draws is the same
        // invisible-state hazard.
        if let info = infoHit, !hits.contains(where: { $0.id == info.id }) {
            infoHit = nil
        }
        // The anchor is checked even with an empty pick: toggling the last
        // row off leaves an anchor behind, and a ⇧-click aimed from a row the
        // list no longer draws is the same invisible-state hazard.
        guard !selectedPosts.isEmpty || selectionAnchor != nil else { return }
        let listed = Set(listedNoteIDs)
        selectedPosts.formIntersection(listed)
        if let anchor = selectionAnchor, !listed.contains(anchor) { selectionAnchor = nil }
    }

    init(session: AppSession) {
        self.session = session
    }

    /// One-shot per typed query / scope change (the core query's contract);
    /// the resting state is books + recent posts.
    func search() async {
        searchGeneration += 1
        let generation = searchGeneration
        do {
            let query = query
            let all = try await session.database.read { db in
                try Queries.searchCatalog(db, query: query, limitPerKind: 40)
            }
            guard generation == searchGeneration else { return }  // stale
            hits = filtered(all)
            pruneSelectionToListing()   // R2-2: the pick follows the listing
            let postIDs = hits.filter { $0.kind == .post }.map(\.id)
            await loadTagChips(for: postIDs, generation: generation)
            await loadNoteCards(for: postIDs, generation: generation)
            lastError = nil
        } catch {
            guard generation == searchGeneration else { return }
            lastError = String(describing: error)
        }
    }

    func filtered(_ all: [Queries.CatalogHit]) -> [Queries.CatalogHit] {
        switch scope {
        case .all: return all
        case .books: return all.filter { $0.kind == .book }
        case .posts: return all.filter { $0.kind == .post }
        case .blocks: return all.filter { $0.kind == .block }
        }
    }

    /// The tags column's chips (bounded to the visible hits; ONE grouped
    /// query — round 2 NIT: the per-post loop was N round trips). The
    /// chips read is a SECOND suspension point, so it re-checks the
    /// generation before landing (round 3 MINOR: the round-2 guard
    /// covered `hits` but not `postTags` — gen 1's chips could resume
    /// last and describe the previous query's hits). Internal for the
    /// stale-generation pin.
    func loadTagChips(for postIDs: [String], generation: Int) async {
        guard !postIDs.isEmpty else {
            if generation == searchGeneration { postTags = [:] }
            return
        }
        do {
            let chips = try await session.database.read { db in
                try TagChips.load(db, postIDs: postIDs)
            }
            guard generation == searchGeneration else { return }  // stale chips never land
            postTags = chips
        } catch {
            guard generation == searchGeneration else { return }
            lastError = String(describing: error)
        }
    }

    /// 13g R5-6: the note cards' read-time extras. Costs NOTHING outside
    /// `.notes` mode (a mode she is not in must not pay for it), and inside
    /// it costs two grouped reads over the hits already on screen — the
    /// `loadTagChips` shape exactly, generation guard included, because a
    /// second suspension point can otherwise land a stale query's cards
    /// (the round-3 MINOR that taught this file the rule).
    func loadNoteCards(for postIDs: [String], generation: Int) async {
        guard mode == .notes, !postIDs.isEmpty else {
            if generation == searchGeneration, mode != .notes || postIDs.isEmpty {
                noteCards = [:]
            }
            return
        }
        do {
            let cards = try await session.database.read { db in
                try NoteCards.load(db, postIDs: postIDs)
            }
            guard generation == searchGeneration else { return }
            noteCards = cards
        } catch {
            guard generation == searchGeneration else { return }
            lastError = String(describing: error)
        }
    }

    /// The view calls this when the MODE changes (a mode switch does not
    /// re-run the search, and switching INTO notes must fill the cards).
    func refreshNoteCards() async {
        await loadNoteCards(
            for: hits.filter { $0.kind == .post }.map(\.id),
            generation: searchGeneration)
    }

    /// R46: the addable tags surface — apply one tag to MANY posts inline.
    func applyTag(_ tagID: String, to postIDs: [String]) async {
        do {
            try await session.runner.run { ops in
                for postID in postIDs {
                    do {
                        try ops.applyTag(tagID, toPost: postID)
                    } catch OperationError.alreadyTagged {
                        // Batch semantics: already-tagged is a no-op.
                    }
                }
            }
            await search()
        } catch {
            lastError = TagsViewModel.message(error)
        }
    }

    /// 13e E8 — the ADD half of her round-11 ask, through the SHIPPED
    /// type-to-create door (`TagAssignmentViewModel.applyTypedPath`, 13b
    /// 3D's N24 — the same door the context bar's `＋` uses, R6-1). So the
    /// hierarchy walk, the per-segment creation and the
    /// already-applied-is-a-no-op rule are one implementation with one set
    /// of semantics; this surface adds no tag rules of its own.
    ///
    /// The first post's turn creates whatever segments are missing and the
    /// rest find them existing, so a typed path applied to a selection
    /// mints the tag ONCE.
    func applyTypedPath(_ raw: String, to postIDs: [String]) async {
        // Ladder round B (B-2): the batch used to BREAK on the first
        // refusal in Set order — a vanished post's turn silently cost every
        // post after it, and WHICH posts got the tag depended on iteration
        // order. Now: deterministic order, every post gets its turn (the
        // REMOVE sibling's recorded forgiving-batch semantics — tagging is
        // idempotent and re-runnable; contrast the multi-delete door, whose
        // destructive act refuses whole), and partiality is REPORTED. A
        // path-shaped refusal simply fails every turn and reads as itself.
        var failed = 0
        var lastRefusal: String?
        for postID in postIDs.sorted() {
            let door = TagAssignmentViewModel(session: session, postID: postID)
            if await door.applyTypedPath(raw) == nil {
                failed += 1
                lastRefusal = door.lastError
            }
        }
        let report: String?
        if failed == 0 {
            report = nil
        } else if failed == postIDs.count {
            report = lastRefusal
        } else {
            report = "Tagged \(postIDs.count - failed) of \(postIDs.count) notes — "
                + "\(failed) refused (\(lastRefusal ?? "a note may be gone")). "
                + "The tagged ones keep the tag."
        }
        // The refresh AFTER, the report LAST — a successful `search()`
        // clears `lastError`, and the partiality report must survive it.
        await search()
        if let report { lastError = report }
    }

    /// 13e E8 — the REMOVE half (*"see the posts at a high level and remove
    /// / add them"*). Keyed on the TAG the row is showing: it is drawn from
    /// the same rows this reads, and the operations layer refuses anything
    /// that changed underneath (`tagNotApplied` for a tag already taken off,
    /// which batch semantics treat as done rather than as an error — the
    /// `applyTag` mirror).
    func removeTag(_ tagID: String, from postIDs: [String]) async {
        do {
            try await session.runner.run { ops in
                for postID in postIDs {
                    do {
                        try ops.removeTag(tagID, fromPost: postID)
                    } catch OperationError.tagNotApplied {
                        // Batch semantics: already off is a no-op.
                    }
                }
            }
            await search()
        } catch {
            lastError = TagsViewModel.message(error)
        }
    }

    /// The tags carried by the given notes, each once, in path order — the
    /// bulk UNTAG menu's rows (a menu offering a tag nothing selected wears
    /// would be a door that cannot act, P-2).
    func tagsOn(_ postIDs: Set<String>) -> [Tag] {
        var seen: Set<String> = []
        var result: [Tag] = []
        for postID in postIDs.sorted() {
            for tag in postTags[postID] ?? [] where seen.insert(tag.id).inserted {
                result.append(tag)
            }
        }
        return result.sorted { $0.path < $1.path }
    }
}

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
        .onChange(of: model.mode) { _, _ in model.clearSelection() }
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
                Picker("", selection: Binding(get: { model.mode }, set: { model.mode = $0 })) {
                    Text(tokens.chromeLabel("List")).tag(LibraryCatalogModel.Mode.list)
                    Text(tokens.chromeLabel("Notes")).tag(LibraryCatalogModel.Mode.notes)
                    Text(tokens.chromeLabel("Timeline")).tag(LibraryCatalogModel.Mode.timeline)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 230)
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
                        // Double-click anywhere opens (before the single so
                        // the two disambiguate); a body click selects and
                        // shows the book's OUTLINE in the panel — her ruled
                        // model, row 33's shape.
                        .onTapGesture(count: 2) { openHit(hit) }
                        .onTapGesture {
                            withAnimation(Self.panelAnimation) { model.selectBook(hit) }
                        }
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
                Text(tokens.chromeLabel("Nothing matches."))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
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
                    Text(tokens.chromeLabel("No notes match."))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .padding(24)
                }
            }
            .padding(.horizontal, 20)
        }
        .background(tokens.surface)
    }

    private func noteCard(_ hit: Queries.CatalogHit) -> some View {
        let card = model.noteCards[hit.id] ?? NoteCards.Card()
        return VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(hit.title)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                if let date = hit.detail {
                    Text(tokens.chromeLabel(date))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                if !card.books.isEmpty {
                    Text(tokens.chromeLabel(card.books.joined(separator: " · ")))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent.opacity(0.85))
                        .lineLimit(1)
                }
            }
            Text(card.snippet.isEmpty ? "No text yet" : card.snippet)
                .font(tokens.small)
                .foregroundStyle(card.snippet.isEmpty ? tokens.faint : tokens.muted)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
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
        CatalogNoteLine(
            tokens: tokens, title: hit.title, date: hit.detail,
            tags: model.postTags[hit.id] ?? [], allTags: tags.tags,
            onTitleTap: { openHit(hit) },
            onApply: { path in Task { await model.applyTypedPath(path, to: [hit.id]) } },
            onRemove: { tag in Task { await model.removeTag(tag.id, from: [hit.id]) } })
        .contentShape(Rectangle())
        // Act 10 item 10 — her click model, on P-0's reachable routing: a
        // DOUBLE-CLICK anywhere opens (it weirdly didn't); a single body
        // click routes through the model — select + info panel, or the
        // ⌘/⇧ pick. The title's own tap (in the row above) still opens
        // instantly.
        .onTapGesture(count: 2) { openHit(hit) }
        .onTapGesture {
            withAnimation(Self.panelAnimation) {
                model.clickNoteRow(hit.id, modifiers: .current)
            }
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
///     is therefore ∝ books × rows on screen and FLAT in corpus, measured at
///     10× and pinned on the plan. A 200-row page costs 0.15 ms at her one
///     smart book, one-shot per listing load.
enum NoteCards {
    struct Card: Equatable {
        var snippet: String = ""
        var books: [String] = []
    }

    /// How many leading blocks a snippet may consult before giving up.
    nonisolated static let blockWindow = 3
    /// How much text a snippet may carry (the row shows ~2 lines).
    nonisolated static let snippetLimit = 220

    nonisolated static func load(
        _ db: Database, postIDs: [String]
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
                         substr(COALESCE(v.working_text, ''), 1, \(snippetLimit)) AS text,
                         ROW_NUMBER() OVER (
                           PARTITION BY cb.container_id ORDER BY cb.position, cb.id
                         ) AS n
                  FROM container_block cb
                  JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                  LEFT JOIN variant v
                    ON v.id = COALESCE(cb.chosen_variant_id, b.default_variant_id)
                   AND v.deleted_at IS NULL
                  WHERE cb.deleted_at IS NULL
                    AND cb.container_id IN (SELECT value FROM json_each(?))
                ) WHERE n <= \(blockWindow)
                ORDER BY post_id, n
                """,
            arguments: [json])
        for row in snippets {
            let postID: String = row["post_id"]
            guard result[postID]?.snippet.isEmpty ?? true else { continue }
            let text = (row["text"] as String? ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else {
                result[postID, default: Card()].snippet = ""
                continue
            }
            result[postID, default: Card()].snippet = text
        }

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
    let date: String?
    let tags: [Tag]
    let allTags: [Tag]
    let onTitleTap: () -> Void
    let onApply: (String) -> Void
    let onRemove: (Tag) -> Void

    static let probeSpace = "catalog-note-line"

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .baselineProbe("note.title", in: Self.probeSpace)
                .onTapGesture(perform: onTitleTap)
            if let date {
                Text(date).font(tokens.small).foregroundStyle(tokens.muted)
                    .baselineProbe("note.date", in: Self.probeSpace)
            }
            NoteTagsRow(
                tokens: tokens, tags: tags, allTags: allTags,
                onApply: onApply, onRemove: onRemove,
                baselineProbePrefix: "note", baselineProbeSpace: Self.probeSpace)
            Spacer()
        }
        .coordinateSpace(name: Self.probeSpace)
    }
}
