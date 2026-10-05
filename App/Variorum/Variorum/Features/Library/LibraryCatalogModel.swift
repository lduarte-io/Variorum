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
    var listedBookIDs: [String] { hits.filter { $0.kind == .book }.map(\.id) }

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
            Task { await self?.search() }
        }
    }

    /// One-shot per typed query / scope / sort change (the core query's
    /// contract); the resting state is books + recent posts.
    func search() async {
        searchGeneration += 1
        let generation = searchGeneration
        do {
            let query = query
            let (sort, direction) = (sort, direction)
            // Her day, in her calendar, converted once — the query compares
            // the store's own UTC text (18h batch 2).
            let day = editedOn.flatMap { DayBounds(day: $0, calendar: LibraryDayFace.calendar) }
            // **The day's answer is a SET, so it is not capped** (the
            // ladder's R1-4): "which notes did I edit on Sep 8" answered with
            // the day's 40 newest and said nothing about the rest, which is a
            // WRONG answer rather than a short one. The day's own predicate
            // bounds the read. Everywhere else the cap stays and we ask for
            // ONE MORE than we show, so the listing can SAY it is truncated
            // without a second counting statement per keystroke.
            let cap: Int? = day == nil ? Self.pageSize + 1 : nil
            // 13i-d U5: the CURRENT WING's catalog (§9 — search scopes by
            // wing; the Library is "everything" in THIS library).
            let wing = session.wing.currentID
            let all = try await session.database.read { db in
                try Queries.searchCatalog(
                    db, query: query, limitPerKind: cap, sort: sort, direction: direction,
                    editedOn: day, wingID: wing)
            }
            guard generation == searchGeneration else { return }  // stale
            let capped = Self.capped(filtered(all), to: cap == nil ? nil : Self.pageSize)
            truncatedKinds = capped.truncated
            hits = capped.hits
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

    /// **The listing's page size** — the one place that knows the number, so
    /// the line that says it and the read that asks for one more can never
    /// disagree (18h ladder, R1-4).
    static let pageSize = 40

    /// **Which KINDS are showing fewer rows than the store holds** — set by
    /// the `+ 1` probe: we ask for 41 per kind, draw 40, and a 41st is the
    /// proof there are more, never a `COUNT(*)` (a second statement on every
    /// keystroke).
    ///
    /// Per KIND, not one flag (the ladder's R2-2): the Notes body draws notes
    /// only, and a whole-listing flag let it say *"showing the first 40"*
    /// over a complete list of notes because 41 BOOKS came back — a
    /// truncation of something that body does not draw.
    private(set) var truncatedKinds: Set<Queries.CatalogHit.Kind> = []

    /// The List body draws every kind, so any truncation is its own.
    var listingIsTruncated: Bool { !truncatedKinds.isEmpty }
    /// The Notes body draws notes.
    var notesAreTruncated: Bool { truncatedKinds.contains(.post) }

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
        let plan = LibraryCardRead.plan(mode: mode, hits: hits)
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
    /// fill them).
    func refreshNoteCards() async {
        await loadNoteCards(
            for: hits.filter { $0.kind == .post }.map(\.id),
            generation: searchGeneration)
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
