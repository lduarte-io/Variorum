//
//  LibraryCatalogModel.swift
//  Variorum
//
//  The Library catalog's MODEL, extracted from `LibraryCatalogView.swift`
//  (18h ladder round 1, R1-6 — the letter's own review focus F-0 / the
//  constitution's P-9, applied to the letter itself: the view file had
//  reached 1,509 lines with ~250 of them this model, and both 18h batches
//  grew it while their file headers said the opposite).
//
//  A MECHANICAL move, byte-identical: not one line of this body changed in
//  the extraction, and no test changed either — which is the parity proof
//  (the 3C pattern). What it holds is unchanged too: the listing's query
//  state (scope · mode · sort · the day), the ⌘-click pick and its ordering,
//  the info panel's subject, and the bounded per-listing reads (tag chips,
//  note cards). The VIEW is `LibraryCatalogView.swift`; the sort's and the
//  day's own faces are `LibraryTimeFace.swift` and `LibraryDayFilter.swift`.
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
    enum Scope: String, CaseIterable {
        case all, books, posts, blocks

        /// The segment's word (13i-d U6 (c) — her §21 ruling: the Library's
        /// segmented control said "Posts" and "must say Notes"). The case
        /// keeps the model term; the face says the noun she uses.
        var label: String {
            switch self {
            case .all: "All"
            case .books: "Books"
            case .posts: "Notes"
            case .blocks: "Blocks"
            }
        }
    }
    /// 13g batch 6 (R5-6): `notes` joins as a THIRD view mode — her
    /// Apple-Notes-shaped list (title · date · the first bit of text · the
    /// book it's in). A mode beside the others, never a replacement.
    enum Mode: String, CaseIterable {
        case list, notes, timeline

        /// The segment's word, in ONE home (the `Scope.label` precedent).
        /// 17y item (d) — F-U6-5, her pick (QUESTIONS #176): the cards view
        /// is "Cards" (two "Notes" sat side by side at the Library's top —
        /// the scope's kind and this mode). The case keeps its model name;
        /// 13s may re-voice the word.
        var label: String {
            switch self {
            case .list: "List"
            case .notes: "Cards"
            case .timeline: "Timeline"
            }
        }
    }

    @ObservationIgnored let session: AppSession
    var scope: Scope = .all
    var mode: Mode = .list

    // MARK: - The sort (18h batch 1, her row 10 — ruling R-Q8's first half)

    /// **What the notes are ordered by**, and which way. Her words: *"i need
    /// to be able to sort the library by time."*
    ///
    /// Written through `setSort`/`setDirection` (which remember it) and read
    /// by `search()`, which hands both to `Queries.searchCatalog` — a
    /// PARAMETER of the one catalog query, never a second listing (review
    /// focus F-5). The `.timeline` mode keeps its own order: it IS the
    /// timeline.
    private(set) var sort: Queries.LibrarySort
    private(set) var direction: SortDirection

    /// Remembered LOCALLY — the `readModeOutlineShown` class: a posture of
    /// this machine's Library, never a synced `setting` (nothing about how
    /// she is looking at a list is document semantics).
    static let sortKey = "libraryCatalogSort"
    static let directionKey = "libraryCatalogSortDirection"
    /// **Injected** (KnownIssues R1-7): the suites and her hand walks share
    /// the dev-store app's `.standard`, so a pin that read the real store
    /// would be reading whatever a walk left behind. `.standard` in the app,
    /// a scrubbed suite in the pins.
    @ObservationIgnored private let defaults: UserDefaults

    /// Her pick from the `sort ▾` door. It takes the sort's NATURAL
    /// direction (newest-first for a stamp, A–Z for a name — the reading
    /// every list-sorting control gives), which an explicit direction pick
    /// then overrides until the next sort pick.
    ///
    /// Deliberately no `didSet` task: this writes and remembers, and the
    /// caller spawns `search()` — the convention `query`/`scope` already
    /// follow in this file, so a pin drives exactly the two steps the menu
    /// does.
    func setSort(_ sort: Queries.LibrarySort) {
        self.sort = sort
        direction = LibrarySortFace.naturalDirection(for: sort)
        defaults.set(sort.rawValue, forKey: Self.sortKey)
        defaults.set(direction.rawValue, forKey: Self.directionKey)
    }

    func setDirection(_ direction: SortDirection) {
        self.direction = direction
        defaults.set(direction.rawValue, forKey: Self.directionKey)
    }

    /// Where the catalog's own controls stand. The Timeline mode runs its
    /// OWN listing with its own order, so neither the sort door nor the day
    /// field can act there — a door that cannot act is not rendered (P-2).
    /// A rule on the model rather than an `if` buried in the header, so a
    /// pin can hold it (P-1's own doctrine: gating is data).
    ///
    /// *(It was minted as `showsSortDoor` in 18h batch 1 and kept as a
    /// forwarder when batch 2 widened it. The ladder's R1-13 retired that:
    /// the 3C parity pattern exists for pins a batch must not touch, and both
    /// names were minted by the SAME letter — two names for one rule with no
    /// distinction between them is the drift the letter should not ship.)*
    var showsCatalogControls: Bool { mode != .timeline }

    // MARK: - The day filter (18h batch 2, her row 11 — ruling R-Q8)

    /// **"Notes edited on this day"**, or nil for the whole Library. A
    /// canonical `yyyy-MM-dd` key in HER calendar; `search()` converts it to
    /// the store's UTC window through core's one pure rule (`DayBounds`).
    ///
    /// Deliberately NOT remembered: the sort is a posture of how she likes
    /// her Library, and a filter is a question she asked once. A Library that
    /// reopened tomorrow still narrowed to yesterday — with most of her notes
    /// invisible — is the invisible-state hazard, not a convenience.
    private(set) var editedOn: String?

    /// nil clears. Same convention as `setSort`: this writes, and the caller
    /// spawns `search()`, so a pin drives exactly the two steps the field
    /// does.
    ///
    /// **Arming a day moves a books/blocks scope to Notes** (the ladder's
    /// R1-3(b); QUESTIONS #104 gains the clause). A day names notes — the
    /// books and blocks arms stand down while one is armed — so a scope still
    /// pointing at a kind the day cannot answer leaves an EMPTY listing under
    /// a disabled picker, with ✕ the only escape. Moving the value is the
    /// smaller harm than that dead end; the shipped arm of #104 said the
    /// picker stands down and never said what happens to a value already set.
    func setEditedOn(_ day: String?) {
        // A key that is not a real day would filter by a guess; refusing it
        // leaves the Library as it was (`DayBounds`' own nil rule, one layer
        // up so the model never holds a value the query would drop).
        guard let day else { editedOn = nil; return }
        guard JournalDay.isValid(day) else { return }
        editedOn = day
        if scope == .books || scope == .blocks { scope = .posts }
    }

    /// **The day the empty answer may speak about** — nil when something the
    /// day's sentence cannot honestly describe is also narrowing the listing.
    ///
    /// The sentence asserts a fact about the DAY (*"No note's last edit or
    /// savepoint falls on Sep 9."*), so it may only be spoken when the day is
    /// what emptied the listing. A typed query is handled by the WORDING (the
    /// face names the query too); a scope the day cannot answer is handled
    /// here, by silence — the plain `Nothing matches.` is honest where the
    /// day's sentence would not be. `setEditedOn` makes that case unreachable
    /// by moving the scope, so this is the guard that keeps it unreachable
    /// rather than a path she can walk.
    var dayForEmptyAnswer: String? {
        guard let editedOn else { return nil }
        switch scope {
        case .all, .posts: return editedOn
        case .books, .blocks: return nil
        }
    }
    /// Set by the view's binding, which also spawns `search()` — no hidden
    /// didSet task (deterministic under test; the generation guard orders
    /// the UI's unordered spawns).
    var query = ""
    /// **The listing, by kind** (17y B1 (k) — her launch blocker: the Library
    /// showed the 40 newest notes and stopped). Every book of the wing; the
    /// NOTES paged in as she scrolls (`LibraryCatalogPaging.swift` — keyset
    /// pages, never a cap); the block hits of a typed query, still capped and
    /// said so. Written only by this file's reads and the paging extension.
    var bookHits: [Queries.CatalogHit] = []
    var noteHits: [Queries.CatalogHit] = [] {
        // The one flag the catalog's own body reads (17y B1 (k)): a page
        // landing changes `noteHits` but never this, so the catalog does not
        // re-evaluate per page — only the paged list does.
        didSet { if hasNoteRows == noteHits.isEmpty { hasNoteRows = !noteHits.isEmpty } }
    }
    /// The listing has note rows at all (the section and the empty answer).
    private(set) var hasNoteRows = false
    var blockHits: [Queries.CatalogHit] = []
    /// Everything listed, in the listing's order (books · notes · blocks).
    var hits: [Queries.CatalogHit] { bookHits + noteHits + blockHits }

    // MARK: - The notes' paging state (17y B1 (k) — the extension is the brain)

    /// Where the next page of notes starts; nil when none follows.
    var notesCursor: Queries.CatalogCursor?
    /// Another page of notes exists beyond what is listed (the probe row's
    /// answer — never a count). The listing asks for it as she nears the end.
    var notesHaveMore = false
    /// A next page is in flight (one at a time) — read, or read and waiting
    /// to land.
    var loadingMoreNotes = false
    /// A page read while she was scrolling, waiting for her to stop (or to
    /// near the end) before it lands (`LibraryCatalogPaging.swift`).
    @ObservationIgnored var pendingLanding: PendingNotesPage?
    /// The listing is moving under her hand (rows coming and going on
    /// screen), and when a row last did; the watch that notices the rest.
    @ObservationIgnored var listMoving = false
    @ObservationIgnored var lastRowMotion = ContinuousClock.now
    @ObservationIgnored var restWatch: Task<Void, Never>?
    /// The last row position a view said was on screen (when the visible set
    /// is momentarily empty between two rows' callbacks).
    @ObservationIgnored var lastSeenPosition = 0
    /// The question the LISTED rows answer. While a newer question is being
    /// read, no page is asked for: its cursor would be the old listing's,
    /// read under the new question's query and sort, and could land after
    /// the new listing — rows out of order, rows skipped.
    @ObservationIgnored var listedGeneration = 0
    /// Each listed note's position (the visible window's arithmetic).
    @ObservationIgnored var noteIndex: [String: Int] = [:]
    /// The listed notes' positions the views say are on screen.
    @ObservationIgnored var visibleNoteIndices: Set<Int> = []
    /// The pages near what is on screen — the window whose extras (chips,
    /// card words) are kept loaded and whose ownership facts are OBSERVED.
    /// UNOBSERVED on purpose: the rows report what is on screen while SwiftUI
    /// lays them out, and a window the views READ would feed back into that
    /// very layout (measured: the Cards view's lazy column looped). The
    /// window acts on the extras and the held facts, never on the views.
    @ObservationIgnored var nearPages: ClosedRange<Int> = 0...0
    /// A window check is queued (the rows' callbacks coalesce into one per
    /// turn, run AFTER the layout that reported them).
    @ObservationIgnored var windowCheckQueued = false
    /// **The owned-by badge facts — HELD for the near window only** (13i-c
    /// U4's one page-driven observation, owned here since 17y B1 (k) so the
    /// window, not the whole listing, is what it observes). The last answer
    /// each note had; the rows read theirs through their own slice
    /// (`rowExtras(for:)`), never this dictionary.
    @ObservationIgnored var heldFacts: [String: Queries.OwnershipFacts] = [:]
    @ObservationIgnored var ownershipHold: Task<Void, Never>?
    @ObservationIgnored var heldNoteIDs: [String] = []
    /// **Each built row's own observable slice** (17y B1 (k), measured — the
    /// `LibraryNoteRowExtras` reason). Made on a row's first build and kept:
    /// a row SwiftUI keeps alive holds its slice, so a slice is never
    /// replaced under it.
    @ObservationIgnored private var rowSlices: [String: LibraryNoteRowExtras] = [:]
    /// The extras as last written, readable WITHOUT observing them (a row's
    /// slice is seeded from these inside the row's own build).
    @ObservationIgnored private var tagsAsWritten: [String: [Tag]] = [:]
    @ObservationIgnored private var cardsAsWritten: [String: NoteCards.Card] = [:]
    /// A merge pushes its own ids into the slices (∝ the page); any other
    /// write pushes every built slice (∝ the rows built — once per act or
    /// question, never per page).
    @ObservationIgnored private var mergingExtras = false
    /// Pages whose chips are loaded for the current listing; pages whose card
    /// words are loaded for the current mode.
    @ObservationIgnored var chipPages: Set<Int> = []
    @ObservationIgnored var cardPages: Set<Int> = []
    /// 13e E8: the listed notes' live tags (whole rows — see `TagChips`).
    /// The ROWS read their own slice (`rowExtras(for:)`); this dictionary
    /// stays observed for every other reader (the bulk bar's untag menu).
    private(set) var postTags: [String: [Tag]] = [:] {
        didSet {
            tagsAsWritten = postTags
            if !mergingExtras {
                for (id, slice) in rowSlices { slice.setTags(postTags[id] ?? []) }
            }
        }
    }
    /// 13g R5-6: postID → the note card's read-time extras (snippet +
    /// books). Loaded ONLY in `.notes` mode and only for the hits on
    /// screen — the same bounded-to-what-is-listed discipline as
    /// `postTags`. Rows read their slice, as for `postTags`.
    private(set) var noteCards: [String: NoteCards.Card] = [:] {
        didSet {
            cardsAsWritten = noteCards
            if !mergingExtras {
                for (id, slice) in rowSlices { slice.setCard(noteCards[id]) }
            }
        }
    }
    private(set) var lastError: String?
    /// Generation-stamped adoption (round 2, MINOR — the Phase 8 ruling):
    /// per-keystroke tasks are unordered; only the NEWEST read may land.
    private(set) var searchGeneration = 0

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
        noteHits.map(\.id)
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
        infoHit = noteHits.first { $0.id == postID }
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

    /// **The view mode changed** — everything the LISTING owns that the new
    /// mode cannot show goes with it. The pick, as it always has (a mode that
    /// draws no selection must not hold one), and now the DAY: the Timeline
    /// runs its own listing, so its door is not drawn, and an armed day left
    /// behind there kept the scope picker disabled with the only control that
    /// could clear it off screen (the ladder's R1-11).
    ///
    /// One door the view calls, rather than two calls a future mode could
    /// forget one of.
    ///
    /// **And the caller RE-READS when it cleared the day** (the ladder's
    /// R2-1 — a regression of the first version of this fix): clearing
    /// `editedOn` changes what the listing should show, and nothing else on a
    /// mode change re-runs `search()`. Without the re-read, coming back to
    /// List drew the DAY's notes under a header reading `on day…` with the
    /// scope picker live again — the same invisible-state hazard one step
    /// down, and the kind that repairs itself on the next keystroke so it
    /// reads as "notes went missing" rather than as a filter.
    ///
    /// **SYNCHRONOUS, and it RETURNS whether a re-read is owed** (the 18h
    /// ladder's R3-1, 17q): making this `async` to fold the re-read in also
    /// deferred `clearSelection()` off the update in which the mode changed
    /// — a `Task {}` body cannot run before the current synchronous update
    /// completes — so the destructive bulk bar and the info panel, neither of
    /// them mode-gated, could draw for a frame in a mode that shows no
    /// selection: exactly what `clearSelection`'s own doc forbids. The
    /// model's convention (write here, the caller spawns the read) therefore
    /// does NOT bend: the answer tells the caller whether to spawn it, which
    /// is the one thing an `onChange` could not work out for itself.
    func modeChanged() -> Bool {
        clearSelection()
        guard !showsCatalogControls, editedOn != nil else { return false }
        // R3-6: through the one door the field's `private(set)` exists to
        // force — nil takes the same path today, but two writers of one field
        // is how a future clause in that door (QUESTIONS #104's option (c),
        // say) gets skipped on one of the two roads.
        setEditedOn(nil)
        return true
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

    /// 17y B3 item (l): the book rows' context menu brain (the Bookcase's
    /// menu trimmed of position — `BookRowMenu`, the shared home). Its facts
    /// are the LISTED book hits' rows, read once per listing.
    @ObservationIgnored let bookRowDoors: BookRowDoors

    /// The book hits' ids, in listing order — what the row menus' facts read.
    var listedBookIDs: [String] { bookHits.map(\.id) }

    init(session: AppSession, defaults: UserDefaults = .standard) {
        self.session = session
        self.defaults = defaults
        self.bookRowDoors = BookRowDoors(session: session)
        // A remembered value the enum does not PARSE (a hand-edited plist,
        // an older build's key) reads as the shipped default.
        //
        // Narrowed at the ladder's R2-10, because the sentence used to claim
        // more than the code does: it promised the list could never be "in a
        // shape no menu row matches", and `"last_major_revision"` parses
        // fine while `LibrarySortFace.offered` does not list it — so a plist
        // carrying it would leave the door reading *last meaningful edit ·
        // newest first* with no ✓ on any row (that word changed at R2-4,
        // which restored the phone's own for the case no ruling names). Only a hand edit reaches that (nothing in the
        // app writes it), which is why this is a sentence and not a guard;
        // validating against `offered` on read is the one line if it ever
        // stops being hypothetical.
        sort = defaults.string(forKey: Self.sortKey)
            .flatMap(Queries.LibrarySort.init(rawValue:)) ?? .lastTouched
        direction = defaults.string(forKey: Self.directionKey)
            .flatMap(SortDirection.init(rawValue:)) ?? .desc
        // 17y B3 (l) — the walk's W-2: the listing is a ONE-SHOT read, so a
        // book archived or deleted from its row menu must re-ask it.
        bookRowDoors.onLanded = { [weak self] in
            Task { await self?.refresh() }
        }
    }

    /// **A NEW QUESTION** (a typed query, a scope, a sort, a direction, a day,
    /// a wing): the listing starts over — every book, the FIRST page of notes,
    /// the capped block hits. The notes beyond the page arrive as she scrolls
    /// (`loadMoreNotes`, 17y B1 (k)).
    func search() async {
        await read(noteDepth: Self.pageSize, startingOver: true)
    }

    /// **The SAME question, re-asked IN PLACE** after an act on the listing's
    /// own rows (a rename, a tag, an archive, a delete, a wing move, a book's
    /// row menu): every note she has scrolled through is re-read in ONE
    /// statement (∝ what is listed, once per act — never per scroll), so the
    /// list she is halfway down stays where it is instead of snapping back to
    /// its first page.
    func refresh() async {
        await read(noteDepth: max(Self.pageSize, noteHits.count), startingOver: false)
    }

    /// The one read behind both doors.
    private func read(noteDepth: Int, startingOver: Bool) async {
        searchGeneration += 1
        let generation = searchGeneration
        do {
            let query = query
            let (sort, direction, scope) = (sort, direction, scope)
            // Her day, in her calendar, converted once — the query compares
            // the store's own UTC text (18h batch 2).
            let day = editedOn.flatMap { DayBounds(day: $0, calendar: LibraryDayFace.calendar) }
            // 13i-d U5: the CURRENT WING's catalog (§9 — search scopes by
            // wing; the Library is "everything" in THIS library).
            let wing = session.wing.currentID
            let listing = try await session.database.read { db in
                try Self.listing(
                    db, query: query, scope: scope, sort: sort, direction: direction,
                    day: day, wing: wing, noteDepth: noteDepth)
            }
            guard generation == searchGeneration else { return }  // stale
            listedGeneration = generation
            bookHits = listing.books
            noteHits = listing.notes
            blockHits = listing.blocks
            notesCursor = listing.next
            notesHaveMore = listing.next != nil
            truncatedKinds = listing.blocksOver ? [.block] : []
            reindexNotes()
            if startingOver {
                visibleNoteIndices = []
                lastSeenPosition = 0
                // The B1 ladder's NIT-4: a NEW question drops the slices of
                // notes it does not list, so the dictionary — and the
                // per-write loops over it — stay ∝ the listing, never ∝
                // every note ever listed this session. A still-listed id
                // KEEPS its slice OBJECT (the implementer's caveat: a live
                // row whose body the Equatable host skips holds its slice,
                // and a replaced one would go stale under it); `filter`
                // keeps the same instances. `refresh` never prunes — it
                // re-reads the same listing in place.
                rowSlices = rowSlices.filter { noteIndex[$0.key] != nil }
            }
            // Whatever page was in hand answered the question before this one.
            pendingLanding = nil
            loadingMoreNotes = false
            pruneSelectionToListing()   // R2-2: the pick follows the listing
            // The extras (chips, card words) are the NEAR pages' only — and a
            // re-asked listing's are all stale, so the window re-reads.
            chipPages = []
            cardPages = []
            nearPages = Self.window(visible: visibleNoteIndices, count: noteHits.count)
            holdNearFacts()
            await loadNearExtras(generation: generation, replacing: true)
            lastError = nil
        } catch {
            guard generation == searchGeneration else { return }
            lastError = String(describing: error)
        }
    }

    /// What one read returns (the listing's three arms).
    struct Listing {
        var books: [Queries.CatalogHit] = []
        var notes: [Queries.CatalogHit] = []
        var blocks: [Queries.CatalogHit] = []
        var next: Queries.CatalogCursor?
        var blocksOver = false
    }

    /// **One read, every arm the scope shows** — and only those: a scope
    /// that draws no notes reads none.
    nonisolated static func listing(
        _ db: Database, query: String, scope: Scope, sort: Queries.LibrarySort,
        direction: SortDirection, day: DayBounds?, wing: String, noteDepth: Int
    ) throws -> Listing {
        var listing = Listing()
        // **The day's answer is a SET, so it is not paged** (18h ladder
        // R1-4): "which notes did I edit on Sep 8" is answered whole, and the
        // books and blocks stand down (they carry no edit stamp).
        if let day {
            guard scope == .all || scope == .posts else { return listing }
            listing.notes = try Queries.searchCatalog(
                db, query: query, limitPerKind: nil, sort: sort, direction: direction,
                editedOn: day, wingID: wing)
            .filter { $0.kind == .post }
            return listing
        }
        if scope == .all || scope == .books {
            // Every book of the wing (∝ the wing's books — the Bookcase's own
            // class): a book listing is never a page.
            listing.books = try Queries.catalogBooks(db, query: query, limit: nil, wingID: wing)
        }
        if scope == .all || scope == .posts {
            let page = try Queries.catalogNotesPage(
                db, query: query, sort: sort, direction: direction,
                limit: noteDepth, wingID: wing)
            listing.notes = page.hits
            listing.next = page.next
        }
        if scope == .all || scope == .blocks {
            // The block hits of a typed query — named blocks and scraps —
            // stay capped and SAY so (one more than drawn is the proof).
            let blocks = try Queries.catalogBlocks(
                db, query: query, limit: blockCap + 1, wingID: wing)
            listing.blocksOver = blocks.count > blockCap
            listing.blocks = Array(blocks.prefix(blockCap))
        }
        return listing
    }

    /// **The notes' FIRST page** — a page, never a cap (17y B1 (k)): the
    /// listing reads this many first; each next page doubles what is listed
    /// up to `maxPageSize` (`nextPageSize`) and is asked for as she nears the
    /// end. Large enough that a page outruns a fast scroll (two screens
    /// of List rows, four of cards), small enough that a page is one quick
    /// statement (measured: ~2 ms at 20,000 notes in the edited sort).
    nonisolated static let pageSize = 80
    /// How many rows before the end of the listed notes ask for the next page.
    nonisolated static let prefetchMargin = 30
    /// Within this many rows of the end a page in hand lands at once, scroll
    /// or no scroll (she must never reach an end that is not the Library's).
    nonisolated static let landNowMargin = 40
    /// How long the rows must be still before a waiting page lands.
    nonisolated static let restInterval = Duration.milliseconds(200)
    /// The largest page the listing grows to (`nextPageSize`).
    nonisolated static let maxPageSize = 1_280
    /// The block hits' cap (a search's named blocks and scraps) — the one
    /// listing still capped, and the one the truncation line now speaks for.
    nonisolated static let blockCap = 40

    /// **Which KINDS are showing fewer rows than the store holds** — since
    /// 17y B1 (k) only ever the block hits (books are all listed; notes page).
    private(set) var truncatedKinds: Set<Queries.CatalogHit.Kind> = []

    /// The List body draws the block hits, so their cap is its to say.
    var listingIsTruncated: Bool { truncatedKinds.contains(.block) }

    /// Trim each kind to the page and say WHICH kinds were over.
    /// `nil` = uncapped (the day's answer), which is never truncated.
    static func capped(
        _ hits: [Queries.CatalogHit], to page: Int?
    ) -> (hits: [Queries.CatalogHit], truncated: Set<Queries.CatalogHit.Kind>) {
        guard let page else { return (hits, []) }
        var seen: [Queries.CatalogHit.Kind: Int] = [:]
        var kept: [Queries.CatalogHit] = []
        var over: Set<Queries.CatalogHit.Kind> = []
        for hit in hits {
            let n = (seen[hit.kind] ?? 0) + 1
            seen[hit.kind] = n
            if n <= page { kept.append(hit) } else { over.insert(hit.kind) }
        }
        return (kept, over)
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
    /// **13u3 UNIT B widened it to the List mode** — her item 4: an untitled
    /// row leads with the note's own first words, so the List mode needs
    /// those words too. It asks for LESS than the Notes mode does, and the
    /// plan says how much (`LibraryCardRead.plan`): only the rows that would
    /// otherwise be a bare date, and never the book memberships, which that
    /// row does not draw. A library of named notes pays nothing.
    func loadNoteCards(for postIDs: [String], generation: Int) async {
        let plan = LibraryCardRead.plan(mode: mode, hits: noteHits)
        // The passed ids remain the listing's own (the generation's subject);
        // the plan narrows them, and can never widen past them.
        let wanted = plan.ids.filter(Set(postIDs).contains)
        guard !wanted.isEmpty else {
            if generation == searchGeneration { noteCards = [:] }
            return
        }
        do {
            let books = plan.books
            let cards = try await session.database.read { db in
                try NoteCards.load(db, postIDs: wanted, includingBooks: books)
            }
            guard generation == searchGeneration else { return }
            noteCards = cards
        } catch {
            guard generation == searchGeneration else { return }
            lastError = String(describing: error)
        }
    }

    /// The view calls this when the MODE changes (a mode switch does not
    /// re-run the search, and switching INTO a mode that draws words must
    /// fill them) — the NEAR pages' words (17y B1 (k)); farther pages fill as
    /// she scrolls to them. The words REPLACE what the old mode held: a mode
    /// keeps only what it draws (`LibraryCardRead.plan` — the List keeps the
    /// bare rows' words and no books; the Timeline keeps nothing).
    func refreshNoteCards() async {
        cardPages = []
        await loadNearExtras(generation: searchGeneration, replacing: true, cardsOnly: true)
    }

    /// **The extras of the pages near what is on screen** (17y B1 (k)): the
    /// tag chips and the card words of every near page not yet loaded — ONE
    /// read for both, bounded by the window (a few pages), never by how far
    /// she has scrolled. `replacing` drops what other pages held (a new or
    /// re-asked listing's extras are stale); otherwise the near pages' merge
    /// in. Pages are marked BEFORE the read, so a window that moves again
    /// mid-read never asks twice.
    func loadNearExtras(generation: Int, replacing: Bool, cardsOnly: Bool = false) async {
        let pages = Array(nearPages)
        let chipWanted = cardsOnly ? [] : pages.filter { !chipPages.contains($0) }
        let cardWanted = pages.filter { !cardPages.contains($0) }
        chipPages.formUnion(chipWanted)
        cardPages.formUnion(cardWanted)
        let chipIDs = chipWanted.flatMap { notesOfPage($0) }.map(\.id)
        let plan = LibraryCardRead.plan(
            mode: mode, hits: cardWanted.flatMap { notesOfPage($0) })
        let (cardIDs, books) = (plan.ids, plan.books)
        // The B1 ladder's MINOR-1 (the implementer's sharper guard — on the
        // IDS, not the pages): nothing wanted means no read is dispatched.
        // The window Task runs at row-callback rate while she scrolls, and
        // an empty read per turn was a reader-pool round-trip serving
        // nothing; gating on the ids also covers wanted pages that yield no
        // id (a List page of all-titled notes plans zero card reads). The
        // REPLACING path stays unguarded: its empty assignment is the mode
        // switch's clearing (`eachModeReadsWhatItDraws` pins it).
        if !replacing, chipIDs.isEmpty, cardIDs.isEmpty { return }
        do {
            let (chips, cards) = try await session.database.read { db in
                (chipIDs.isEmpty ? [:] : try TagChips.load(db, postIDs: chipIDs),
                 cardIDs.isEmpty ? [:] : try NoteCards.load(db, postIDs: cardIDs, includingBooks: books))
            }
            guard generation == searchGeneration else { return }  // stale extras never land
            if replacing {
                if !cardsOnly { postTags = chips }
                noteCards = cards
            } else {
                mergeExtras(chipIDs: chipIDs, chips: chips, cardIDs: cardIDs, cards: cards)
            }
        } catch {
            chipPages.subtract(chipWanted)
            cardPages.subtract(cardWanted)
            guard generation == searchGeneration else { return }
            lastError = String(describing: error)
        }
    }

    /// **Merge one read's extras in ONE assignment per dictionary** (17y B1
    /// (k), measured): every row reads these dictionaries, so each assignment
    /// re-draws every row on screen — a per-id loop of assignments paid that
    /// once per id. A page whose ids carry no tag still OWES its entries'
    /// removal (a chip taken off since the last read): the ids read here are
    /// the truth for those rows.
    func mergeExtras(
        chipIDs: [String], chips: [String: [Tag]],
        cardIDs: [String], cards: [String: NoteCards.Card]
    ) {
        mergingExtras = true
        defer { mergingExtras = false }
        if !chipIDs.isEmpty {
            var merged = tagsAsWritten
            var changed = false
            for id in chipIDs where merged[id] != chips[id] {
                merged[id] = chips[id]
                changed = true
            }
            if changed { postTags = merged }
            // ONLY these ids' rows hear it (the measured reason).
            for id in chipIDs { rowSlices[id]?.setTags(chips[id] ?? []) }
        }
        if !cardIDs.isEmpty {
            var merged = cardsAsWritten
            var changed = false
            for id in cardIDs where merged[id] != cards[id] {
                merged[id] = cards[id]
                changed = true
            }
            if changed { noteCards = merged }
            for id in cardIDs { rowSlices[id]?.setCard(cards[id]) }
        }
    }

    /// **A row's own slice of the extras** (17y B1 (k)): the row reads its
    /// tags, card words and owned-by facts HERE, so a write for other rows
    /// (a page landing, a window's extras, another note's badge) never
    /// re-draws it. Seeded from what is written, without observing it.
    func rowExtras(for id: String) -> LibraryNoteRowExtras {
        if let slice = rowSlices[id] { return slice }
        let slice = LibraryNoteRowExtras(
            tags: tagsAsWritten[id] ?? [], card: cardsAsWritten[id], facts: heldFacts[id])
        rowSlices[id] = slice
        return slice
    }

    /// The held observation's answer for `ids` lands in their slices — only
    /// the notes whose facts changed hear it.
    func landFacts(_ value: [String: Queries.OwnershipFacts], for ids: [String]) {
        for id in ids where heldFacts[id] != value[id] {
            heldFacts[id] = value[id]
            rowSlices[id]?.setFacts(value[id])
        }
    }

    /// The notes of one page of the listing (positions `page × pageSize ..<`).
    func notesOfPage(_ page: Int) -> ArraySlice<Queries.CatalogHit> {
        let start = page * Self.pageSize
        guard start < noteHits.count, start >= 0 else { return [] }
        return noteHits[start..<min(noteHits.count, start + Self.pageSize)]
    }

    /// **The tag acts' one report door** (13u4 UNIT S2 — row 50's second
    /// mechanical move). Those four acts now live in
    /// `LibraryCatalogTagActs.swift`, and `private(set)` scopes a setter to
    /// its declaring FILE — so the split either widens `lastError` to the
    /// whole module or names ONE door for the one other writer. One door:
    /// the property stays this file's to write, and the only other writer
    /// says out loud what it is. Behaviour-identical — the four acts wrote
    /// exactly this, in exactly these places.
    func report(_ message: String?) { lastError = message }
}

/// **A page of notes read and waiting to land** (17y B1 (k)): the rows, their
/// chips and card words, and the question they answer.
struct PendingNotesPage {
    let page: Queries.CatalogNotesPage
    let chips: [String: [Tag]]
    let cards: [String: NoteCards.Card]
    let cardIDs: [String]
    let generation: Int
}

/// **One listed note's own observable slice** (17y B1 (k), measured on the
/// 822-note fixture): every row used to read the WHOLE extras dictionaries
/// (`postTags`, `noteCards`) and the whole owned-by facts, so every write —
/// a page landing its chips, a window loading its extras, a badge for some
/// other note — re-drew every row SwiftUI held alive: 105–159 card rows per
/// page landing (the Cards' lazy column keeps far more than the screen),
/// 36–86 List rows, a 100–270 ms frame each time. A row reads only its own
/// slice; a write reaches only the rows whose values changed.
@MainActor @Observable
final class LibraryNoteRowExtras {
    private(set) var tags: [Tag]
    private(set) var card: NoteCards.Card?
    private(set) var facts: Queries.OwnershipFacts?

    init(tags: [Tag], card: NoteCards.Card?, facts: Queries.OwnershipFacts?) {
        self.tags = tags
        self.card = card
        self.facts = facts
    }

    // Equal writes never notify (an @Observable setter always would).
    func setTags(_ value: [Tag]) { if value != tags { tags = value } }
    func setCard(_ value: NoteCards.Card?) { if value != card { card = value } }
    func setFacts(_ value: Queries.OwnershipFacts?) { if value != facts { facts = value } }
}
