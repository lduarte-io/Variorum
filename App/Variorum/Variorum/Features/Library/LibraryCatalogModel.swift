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
    enum Scope: String, CaseIterable { case all, books, posts, blocks }
    /// 13g batch 6 (R5-6): `notes` joins as a THIRD view mode — her
    /// Apple-Notes-shaped list (title · date · the first bit of text · the
    /// book it's in). A mode beside the others, never a replacement.
    enum Mode: String, CaseIterable { case list, notes, timeline }

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
    var showsCatalogControls: Bool { mode != .timeline }
    /// 18h batch 1's name for the same rule, kept so its pin reads unchanged
    /// (the 3C parity pattern).
    var showsSortDoor: Bool { showsCatalogControls }

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
    func setEditedOn(_ day: String?) {
        // A key that is not a real day would filter by a guess; refusing it
        // leaves the Library as it was (`DayBounds`' own nil rule, one layer
        // up so the model never holds a value the query would drop).
        guard let day else { editedOn = nil; return }
        guard JournalDay.isValid(day) else { return }
        editedOn = day
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

    init(session: AppSession, defaults: UserDefaults = .standard) {
        self.session = session
        self.defaults = defaults
        // A remembered value the app does not recognise (a hand-edited
        // plist, an older build's key) reads as the shipped default rather
        // than leaving the list in a shape no menu row matches.
        sort = defaults.string(forKey: Self.sortKey)
            .flatMap(Queries.LibrarySort.init(rawValue:)) ?? .lastTouched
        direction = defaults.string(forKey: Self.directionKey)
            .flatMap(SortDirection.init(rawValue:)) ?? .desc
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
            let day = editedOn.flatMap { DayBounds(day: $0) }
            let all = try await session.database.read { db in
                try Queries.searchCatalog(
                    db, query: query, limitPerKind: 40, sort: sort, direction: direction,
                    editedOn: day)
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
