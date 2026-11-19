//
//  MobileLibraryViewModel.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — the Library tab's model (M7: Library =
//  everything + search; bookless notes as a filter — the Pool's phone
//  home, R29's letter).
//
//  · The listing is the STANDING sort vocabulary (last-touched, newest
//    first, by default). **VM-68 — a page, never a cap:** both note
//    listings (All/Notes, and Bookless) are keyset pages through the Mac's
//    own read (`Queries.catalogNotesPage`), the next page asked for as she
//    nears the end; Bookless is that read over the Pool's LOOSE class
//    (`poolLoose` — `poolPosts`' rows: derived smart membership counts as
//    being in a book — the core query's own rule). **Held only while the
//    Library is on screen** (the shell's fact): then ONE observation holds the
//    shown listing's FIRST page (P1 — a held fetch is a bounded keyset page),
//    and a deeper listing is re-asked in place when that page moves (the
//    Mac's `followListingMove`). Hidden, nothing is held; the return re-asks.
//
//  · Search is `Queries.searchCatalog`'s EXISTING scope — titles, names,
//    entry dates, named blocks, pool-scrap prefixes. Body-text search is
//    the whole-library-search roadmap row's, deliberately NOT invented
//    here (pinned by `MobileLibraryTests`). ONE-SHOT per typed query, the
//    Mac ⌘K discipline.
//
//  Chrome only — no business rules.
//

import Foundation
import GRDB // AsyncValueObservation iteration (member import visibility)
import Observation
import VariorumCore

/// **ONE ROW OF THE LIBRARY'S LISTING** (her #93(b): *"All should be a book +
/// notes union"*).
///
/// Two kinds, never a third: the Library lists notes and books, and scraps
/// keep their own section (`MobileScrapsSection`) because a scrap is a BLOCK
/// with its own row grammar, not a listing row. The enum is exhaustive on
/// purpose — a kind that ever joins the union has to be answered at the
/// renderer rather than falling through to a row that is quietly wrong.
nonisolated enum MobileLibraryRow: Identifiable, Sendable {
    case note(Queries.TimelineItem)
    case book(Queries.ShelfBook)

    /// Kind-prefixed so a note and a book can never collide on a raw UUID.
    var id: String {
        switch self {
        case .note(let item): return "note:\(item.postID)"
        case .book(let book): return "book:\(book.reading.id)"
        }
    }
}

@MainActor
@Observable
final class MobileLibraryViewModel {
    /// **THE ONE FILTER VOCABULARY** (the filter batch, her #85/#92) — the
    /// declaration moved to `MobileListingFilter` when the Archive room grew
    /// the same row, and this name stays as its handle so no call site had to
    /// learn a second word for the same thing. `.books` and `.notes` are her
    /// #92(a) additions; `.bookless` and `.scraps` are untouched.
    typealias Filter = MobileListingFilter

    @ObservationIgnored private let session: AppSession
    /// **One PAGE of a note listing** (VM-68 — the held first page and each
    /// page after it), and the books listing's render window. 200, the
    /// phone's window before paging, so the resting listing is unchanged.
    @ObservationIgnored private let listingLimit: Int

    var filter: Filter = .all
    /// The listing's sort (parity C3 — her sitting ruling 9: "Library
    /// sort picker → ADD"). The standing default stays last-touched,
    /// newest first; the view restarts the listing observation on a
    /// change (`.task(id:)` — nothing is written, a way of LOOKING).
    private(set) var sort: Queries.LibrarySort = .lastTouched
    private(set) var all: [Queries.TimelineItem] = []
    private(set) var bookless: [Queries.TimelineItem] = []
    /// nil = no search active (the listing shows); [] = a query with no
    /// hits (the empty state speaks).
    private(set) var hits: [Queries.CatalogHit]?
    private(set) var lastError: String?

    init(session: AppSession, listingLimit: Int = 200) {
        self.session = session
        self.listingLimit = listingLimit
    }

    /// The NOTE half of the listing. `.all` and `.notes` deliver the same
    /// notes; what distinguishes them since her #93(b) is that `.all` also
    /// carries the BOOKS — see `rows(books:)`, which is what the surface
    /// renders.
    var visible: [Queries.TimelineItem] {
        switch filter {
        case .all, .notes: return all
        case .bookless: return bookless
        // Books are readings and scraps are blocks — neither is a note, so
        // this note listing is empty under both. Their rows come from the
        // shelf model and `MobileScrapsModel` respectively.
        case .books, .scraps: return []
        }
    }

    // MARK: - What an empty note listing SAYS (VM-5 whole-round pass, MINOR 2)

    /// The two things an empty note listing can honestly say.
    nonisolated enum EmptyListing: Equatable, Sendable {
        /// The store holds no notes: the fresh-install trio
        /// (`MobileEmptyStoreCopy` — no notes yet · the New Note door · the
        /// sign-in road), every sentence of which is true then.
        case storeEmpty
        /// The Bookless door found nothing while the store HAS notes — they
        /// are all in books (`MobileListingFilter.noBooklessLine`).
        case noBookless
    }

    /// **WHICH EMPTY LINE, IF ANY — decided by what is TRUE, not by which
    /// door's listing happens to be empty.**
    ///
    /// The old guard asked only whether the DOOR's listing was empty, so the
    /// Bookless door over a store whose notes are all in books said *"No notes
    /// yet."* — false there — plus a sign-in line that read as "your writing
    /// hasn't arrived" (the cold read's MINOR 2). The fresh-install trio is a
    /// claim about the STORE, so it now needs the store's note listing empty:
    ///
    /// | door | rows to show | store's notes | says |
    /// |---|---|---|---|
    /// | all / notes | none, and (all) no books either | — (the listing IS the store's) | the trio |
    /// | bookless | none | none | the trio — true here too |
    /// | bookless | none | some | the Bookless door's own line |
    /// | books / scraps | — | — | nothing here: their sections speak for themselves |
    ///
    /// `.notes` was checked for the same class and is honest: its listing IS
    /// the store's whole live note listing, so *"No notes yet."* is true
    /// whenever it renders. `notesInStore` is the bounded `all` listing —
    /// non-empty exactly when one live note exists, which is all this asks.
    /// PURE, so the table above is pinned rather than promised.
    nonisolated static func emptyListing(
        filter: Filter, doorNotes: Int, storeNotes: Int, booksShown: Int
    ) -> EmptyListing? {
        guard doorNotes == 0, booksShown == 0 else { return nil }
        switch filter {
        case .all, .notes: return .storeEmpty
        case .bookless: return storeNotes == 0 ? .storeEmpty : .noBookless
        case .books, .scraps: return nil
        }
    }

    /// The surface's question, answered from this model's own listings.
    /// `booksShown` is the books half the surface is rendering (non-zero only
    /// under `.all`'s union).
    ///
    /// **VM-68:** the Bookless listing is read only while it is shown, so
    /// until its first answer lands it says NOTHING (no false empty line on
    /// the first switch to the door); its store fact is the read's own
    /// (`ListingPage.wingHasNotes` — asked in the same read when the loose
    /// class is empty), never a note listing read at another moment.
    func emptyListing(booksShown: Int) -> EmptyListing? {
        if filter == .bookless, !booklessLoaded { return nil }
        let storeNotes = filter == .bookless ? (booklessWingHasNotes ? 1 : 0) : all.count
        return Self.emptyListing(
            filter: filter, doorNotes: visible.count, storeNotes: storeNotes,
            booksShown: booksShown)
    }

    // MARK: - THE UNION (#93(b))

    /// **`All` IS THE BOOKS + NOTES UNION** — her ruling, verbatim: *"All
    /// should be a book + notes union - otherwise it just doesn't make
    /// sense."* It OVERTURNS the batch's shipped PROVISIONAL 3, which built
    /// `.all` as the note listing on the ground that it changed nothing at
    /// rest; the union is the app's own kind-filter grammar (the Trash room's
    /// `All` is the union of its kinds), and it is what the door's word
    /// promises.
    ///
    /// **The LIBRARY only.** The Archive room's `.all` is untouched: there,
    /// the coincidence with `.notes` holds TODAY because the phone's
    /// archived-BOOKS face is still owed — not because the model forbids it
    /// (since 13i-e `Reading.archivedAt` is real; the VM-5 round-1 review's
    /// MINOR 1 corrected this comment). The owed face: MobileSoul 13i-e row /
    /// VM-6 (4d); `MobileListingFilter.archiveDoors` carries the fuller note.
    ///
    /// The books passed in are the SURFACE's windowed set — the `.books`
    /// filter's own rows and its own window, so a book reads identically
    /// under either door and neither listing invents a second row rule.
    func rows(books: [Queries.ShelfBook]) -> [MobileLibraryRow] {
        Self.union(
            notes: visible, books: filter == .all ? books : [], sort: sort,
            notesComplete: !allHasMore)
    }

    /// **THE BOOK'S STAMP UNDER THE ACTIVE SORT — PROVISIONAL** (her ruling
    /// left the interleaving detail unspecified, and it is recorded rather
    /// than quietly chosen).
    ///
    /// A note is ordered by the stamp its sort names (`Queries.LibrarySort`'s
    /// own COALESCE expression); a book carries only `created_at` and
    /// `updated_at`, so each sort maps to the NEAREST of the two:
    ///
    /// | sort | the note's stamp | the book's |
    /// |---|---|---|
    /// | created | `created_at` | **`created_at`** |
    /// | entry date | `COALESCE(entry_date, created_at)` | **`created_at`** — a book has no entry date, so it behaves exactly as an undated note does under that sort |
    /// | last touched | `COALESCE(last_touched_at, created_at)` | **`updated_at`** |
    /// | last meaningful edit | `COALESCE(last_major_revision_at, created_at)` | **`updated_at`** — a book has no churn stamp; `updated_at` is the nearest thing it has to "when this last changed" |
    ///
    /// **The one wart, stated:** under ENTRY DATE a note's stamp may be a bare
    /// day (`2026-12-01`) while a book's is a full ISO instant
    /// (`2026-12-01T…`), so a book created on a day sorts just above a note
    /// dated that day. That is the SAME lexicographic wart the core's own
    /// COALESCE already has between dated and undated notes — inherited, not
    /// introduced.
    nonisolated static func bookStamp(
        _ book: Queries.ShelfBook, sort: Queries.LibrarySort
    ) -> String {
        let date: Date
        switch sort {
        case .createdAt, .entryDate: date = book.reading.createdAt
        case .lastTouched, .lastMajorRevision: date = book.reading.updatedAt
        // 18h added `.title` (A–Z on the displayed name — a NAME sort, not a
        // stamp), and the phone's `setSort` REFUSES it until the phone offers
        // it (PL-22's 18h note), so this arm is unreachable today. If the
        // phone ever offers title sort, the union's interleave needs its own
        // rule (names, not stamps) — this stamp is only the exhaustiveness
        // answer, not a design.
        case .title: date = book.reading.createdAt
        }
        // The canonical encoding — byte-identical to what the container rows
        // carry, so the two kinds' stamps really are comparable strings
        // (`DateFormatter.variorumISO8601`, AppSpec §6).
        return DateFormatter.variorumISO8601.string(from: date)
    }

    /// The interleave itself — PURE, so the rule is pinned rather than
    /// promised. Newest first, matching the listing's own `direction: .desc`.
    ///
    /// **Ties are broken deterministically** (they are near-impossible at
    /// millisecond precision, but a listing whose order depends on sort
    /// stability is a listing that can flicker): equal stamps put the NOTE
    /// first — the resting surface keeps its shape — and equal stamps within
    /// one kind keep their source order, which for notes is the query's own
    /// `(stamp, id)` total order and for books is the Shelf's order.
    ///
    /// **VM-68 — the union of a PAGED listing.** While more notes remain to
    /// be read (`notesComplete` false), a book whose stamp is not newer than
    /// the last listed note is WITHHELD: it belongs among notes not yet read,
    /// so drawing it now would put it at the listing's end and then move it
    /// up as pages land. The rows are always the true head of the whole
    /// union; once every note is listed, every book is too.
    nonisolated static func union(
        notes: [Queries.TimelineItem], books: [Queries.ShelfBook],
        sort: Queries.LibrarySort, notesComplete: Bool = true
    ) -> [MobileLibraryRow] {
        struct Keyed {
            let stamp: String
            let kindRank: Int
            let index: Int
            let row: MobileLibraryRow
        }
        let floor = notesComplete ? nil : notes.last?.stamp
        var keyed: [Keyed] = []
        keyed.reserveCapacity(notes.count + books.count)
        for (index, item) in notes.enumerated() {
            keyed.append(Keyed(stamp: item.stamp, kindRank: 0, index: index, row: .note(item)))
        }
        for (index, book) in books.enumerated() {
            let stamp = bookStamp(book, sort: sort)
            if let floor, stamp <= floor { continue }
            keyed.append(Keyed(stamp: stamp, kindRank: 1, index: index, row: .book(book)))
        }
        return keyed.sorted { left, right in
            if left.stamp != right.stamp { return left.stamp > right.stamp }
            if left.kindRank != right.kindRank { return left.kindRank < right.kindRank }
            return left.index < right.index
        }.map(\.row)
    }

    /// **The books listing's WINDOW** (#92(a) — books as rows).
    ///
    /// The FETCH is author-scale by core's own contract: `Queries.bookshelf`
    /// takes no limit and `ShelfQueries`' header says why (*"reading rows +
    /// counted joins — author-scale"*), which is exactly why the Shelf holds
    /// it unbounded. So what this bounds is what the SURFACE BUILDS — the
    /// scraps area's own shape (`MobileScrapsModel`'s window over a whole
    /// delivery), and `count > window` is exact truth rather than a probe
    /// approximation, so an exact-window shelf can never false-positive the
    /// marker.
    func windowedBooks(
        _ books: [Queries.ShelfBook]
    ) -> (rows: [Queries.ShelfBook], truncated: Bool) {
        TrashListing.windowed(books, window: listingLimit)
    }

    // MARK: - The sort picker (parity C3 — ruling 9)

    /// The picker's vocabulary — the C3 brief's four words over the
    /// core's own `LibrarySort` (the standing sort stamps, AppSpec §10:
    /// "last meaningful edit" is the 80%-sort's stamp).
    nonisolated static let sortOptions: [Queries.LibrarySort] =
        [.entryDate, .createdAt, .lastTouched, .lastMajorRevision]

    /// **A forwarder since the 18h ladder (R1-7):** the words are
    /// `LibrarySortWords` in `Shared/`, the same table the Mac's `sort ▾`
    /// reads. Until then this switch was a SECOND wording over one core
    /// vocabulary (*last touched* / *entry date* against the Mac's *edited* /
    /// *date*), which is MobileSoul §3's drift class; her R-Q8 names the four
    /// words herself, so the phone adopts them. What stays the phone's is
    /// which cases it OFFERS — `sortOptions` above, still the four stamps.
    nonisolated static func sortWord(_ sort: Queries.LibrarySort) -> String {
        LibrarySortWords.label(sort)
    }

    /// Flips the way of looking; the view's `.task(id: sort)` restarts
    /// the observation. Never a write — sorting reshuffles nothing
    /// (CoreDescription pillar 7 is about the STAMPS; the picker only
    /// chooses which one orders the list).
    ///
    /// **It refuses `.title`** (the 18h ladder, R2-5). This model's listing is
    /// `observeLibrary` → `Queries.library`, which reports its ordering value
    /// as `TimelineItem.stamp` and therefore **refuses `.title` by
    /// precondition — a trap, live in release**. 18h gave `.title` a word in
    /// the shared table so a picker could say it, and this round's parity row
    /// invites the phone to grow the sort; so the very next touch that adds
    /// `.title` to `sortOptions` would turn a picker tap into a crash rather
    /// than a degraded order. The guard is here, at the door, so that touch
    /// is a no-op it can notice instead of a trap it discovers.
    ///
    /// A word without an offer is the state this leaves: the phone can NAME
    /// `.title` (the shared table) and cannot BE it (this guard) until its
    /// listing can serve it — which is `searchCatalog`'s road, not
    /// `library`'s, and a mobile decision either way.
    func setSort(_ next: Queries.LibrarySort) {
        guard next != .title else { return }
        guard next != sort else { return }
        sort = next
    }

    // MARK: - The listings: pages, held only while shown (VM-68)

    /// **Which note listing a filter shows** — Books and Scraps show none.
    nonisolated enum Listing: Hashable, Sendable {
        /// All and Notes: every note, under the picked sort.
        case notes
        /// The Pool's phone home: the LOOSE class (`poolPosts`' rows).
        case bookless
    }

    /// **What a listing's rows answer.** A change is a NEW question, and the
    /// listing starts over at its first page.
    nonisolated struct Question: Hashable, Sendable {
        let listing: Listing
        /// The note listing's sort; Bookless keeps the Pool's own order
        /// (edited, newest first — `poolPosts`' `stamp DESC, id DESC`).
        let sort: Queries.LibrarySort
        /// The wing the reads are scoped to: `WingState.readScope`, the one
        /// seam every shared read takes its wing from (nil = every wing).
        let wing: String?
    }

    /// **The view's hold** — its `.task(id:)`: the question the shown filter
    /// asks, and whether the Library is on screen (the shell's fact).
    nonisolated struct Hold: Hashable, Sendable {
        let question: Question?
        let onScreen: Bool
    }

    /// **One page of a listing, as its rows** (the read's whole answer).
    nonisolated struct ListingPage: Equatable, Sendable {
        let items: [Queries.TimelineItem]
        let next: Queries.CatalogCursor?
        /// The Bookless door's store fact: does the wing hold ANY live note?
        /// Asked inside the same read only when the loose class's first page
        /// is empty (one index seek); true otherwise.
        let wingHasNotes: Bool
    }

    /// A listing's paging state — never observed (the rows are).
    @MainActor
    private final class Paging {
        /// The question the listed rows answer (nil before the first landing).
        var question: Question?
        /// Where the next page starts (nil: nothing follows).
        var next: Queries.CatalogCursor?
        /// Bumped by every landing that REPLACES the rows: a page read before
        /// it never lands after it.
        var generation = 0
        var loadingMore = false
        /// The last listed rows' ids: one coming on screen asks for the next page.
        var tail: Set<String> = []
        /// She came near the end and wants the next page — kept until a page
        /// APPENDS, so a page read that a landing superseded is asked for
        /// again, rather than lost under rows already on screen (whose
        /// `onAppear` will not fire twice). A new question clears it.
        var wantsMore = false
        /// The in-place re-ask of a deeper listing, single-flight.
        var follow: Task<Void, Never>?
        var followAgain = false
    }

    @ObservationIgnored private let notesPaging = Paging()
    @ObservationIgnored private let booklessPaging = Paging()

    private func paging(_ listing: Listing) -> Paging {
        listing == .notes ? notesPaging : booklessPaging
    }

    /// Whether another page of the note listing exists (the union withholds
    /// older books until it is read).
    private(set) var allHasMore = false
    /// The Bookless listing has answered once (its empty line waits for it).
    private(set) var booklessLoaded = false
    /// The Bookless read's store fact (`ListingPage.wingHasNotes`).
    private(set) var booklessWingHasNotes = true
    /// "The library ready" is the note listing's FIRST landing (VM-65).
    @ObservationIgnored private var notesLandedOnce = false

    /// How near the end a row must come on screen for the next page to be
    /// asked for — about two screens of rows, so a page is in hand before she
    /// gets there (the Mac's `prefetchMargin`).
    nonisolated static let prefetchMargin = 30

    /// The listing the current filter shows.
    var shownListing: Listing? {
        switch filter {
        case .all, .notes: return .notes
        case .bookless: return .bookless
        case .books, .scraps: return nil
        }
    }

    /// The question `listing` asks right now.
    func question(_ listing: Listing) -> Question {
        Question(
            listing: listing, sort: listing == .notes ? sort : .lastTouched,
            wing: session.wing.readScope)
    }

    /// The view's hold key, read in its body.
    func hold(onScreen: Bool) -> Hold {
        Hold(question: shownListing.map(question), onScreen: onScreen)
    }

    /// **THE VIEW'S ONE TASK** (`.task(id: hold)`). The note listing is read
    /// ONCE per question whatever shows — the Library is ready before she
    /// arrives (the "Library ready" mark keeps its meaning), and nothing is
    /// read again until it is on screen. On screen, the shown listing's first
    /// page is HELD; hidden — a neighbouring page of the band, or covered by
    /// a note on its own stack — nothing is held, so a write anywhere sets off
    /// no Library read and no landing. Becoming on screen re-runs this task:
    /// the held page's first fetch is the return's re-ask.
    func hold(_ hold: Hold) async {
        let notes = question(.notes)
        if !(hold.onScreen && hold.question == notes) {
            await prime(notes)
        }
        guard hold.onScreen, let shown = hold.question else { return }
        await holdFirstPage(shown)
    }

    /// The note listing, held (the shell's own road is `hold(_:)`; this is
    /// its on-screen half, which the pins drive directly).
    func startAll() async { await holdFirstPage(question(.notes)) }

    /// The Bookless listing, held — the Pool's phone home.
    func startBookless() async { await holdFirstPage(question(.bookless)) }

    /// One read of a question's first page, unless the rows already answer it.
    private func prime(_ question: Question) async {
        guard paging(question.listing).question != question else { return }
        do {
            let limit = listingLimit
            let page = try await session.database.read { db in
                try Self.read(db, question, after: nil, limit: limit)
            }
            land(page, question)
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// **The held first page.** Its region is what the page reads, so it
    /// re-runs on every write to those tables — only while on screen, where
    /// nothing is typed. Each delivery lands directly while the listing is
    /// that page alone; a deeper listing is re-asked in place instead.
    private func holdFirstPage(_ question: Question) async {
        let state = paging(question.listing)
        defer {
            state.follow?.cancel()
            state.follow = nil
            state.followAgain = false
        }
        do {
            let limit = listingLimit
            for try await page in session.database.observe({ db in
                try Self.read(db, question, after: nil, limit: limit)
            }) {
                if state.question != question || rows(question.listing).count <= limit {
                    land(page, question)
                } else {
                    followFirstPage(question)
                }
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// **The deeper listing follows its first page** (the Mac's
    /// `followListingMove`): one statement to the depth she has scrolled to,
    /// single-flight — a move landing while a re-ask runs asks for exactly
    /// one more after it.
    private func followFirstPage(_ question: Question) {
        let state = paging(question.listing)
        guard state.follow == nil else {
            state.followAgain = true
            return
        }
        state.follow = Task { [weak self] in
            repeat {
                state.followAgain = false
                await self?.reread(question)
            } while state.followAgain && !Task.isCancelled
            guard !Task.isCancelled else { return }  // the hold ended (hidden): it cleared `follow`
            state.follow = nil
            self?.askForMore(question.listing)
        }
    }

    /// The listed depth, re-asked in place.
    private func reread(_ question: Question) async {
        let depth = max(listingLimit, rows(question.listing).count)
        do {
            let page = try await session.database.read { db in
                try Self.read(db, question, after: nil, limit: depth)
            }
            guard !Task.isCancelled, paging(question.listing).question == question else { return }
            land(page, question)
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// **The next page** — one keyset read after the cursor, appended. A
    /// landing that replaced the rows since it began supersedes it, and the
    /// page she still wants is asked for again from where the rows now end.
    func loadMore(_ listing: Listing) async {
        let state = paging(listing)
        guard let question = state.question, let cursor = state.next,
              !state.loadingMore, state.follow == nil else { return }
        state.loadingMore = true
        let generation = state.generation
        let page: ListingPage
        do {
            let limit = listingLimit
            page = try await session.database.read { db in
                try Self.read(db, question, after: cursor, limit: limit)
            }
        } catch is CancellationError {
            state.loadingMore = false
            return
        } catch {
            state.loadingMore = false
            if state.generation == generation { lastError = String(describing: error) }
            return
        }
        state.loadingMore = false
        guard state.generation == generation, state.question == question else {
            askForMore(listing)
            return
        }
        append(page, listing)
    }

    /// A row came on screen: near the end of what is listed, the next page
    /// is asked for (the note rows' `.onAppear`).
    func rowAppeared(_ postID: String, in listing: Listing) {
        let state = paging(listing)
        guard state.next != nil, state.tail.contains(postID) else { return }
        state.wantsMore = true
        askForMore(listing)
    }

    /// The next page's read starts when she wants it and nothing stands in
    /// its way (a read in flight, a re-ask in place, the end of the listing).
    private func askForMore(_ listing: Listing) {
        let state = paging(listing)
        guard state.wantsMore, state.next != nil, !state.loadingMore, state.follow == nil else {
            return
        }
        Task { await loadMore(listing) }
    }

    private func rows(_ listing: Listing) -> [Queries.TimelineItem] {
        listing == .notes ? all : bookless
    }

    /// The rows REPLACED by `page` (a first page, a held delivery, a re-ask).
    private func land(_ page: ListingPage, _ question: Question) {
        let state = paging(question.listing)
        if state.question != question { state.wantsMore = false }  // a new question starts at the top
        state.generation += 1
        state.question = question
        place(page.items, page: page, in: question.listing)
        askForMore(question.listing)
    }

    /// `page` APPENDED — a note already listed stays where it was first read
    /// (the Mac's landing rule).
    private func append(_ page: ListingPage, _ listing: Listing) {
        let listed = rows(listing)
        let seen = Set(listed.map(\.postID))
        paging(listing).wantsMore = false
        place(listed + page.items.filter { !seen.contains($0.postID) }, page: page, in: listing)
    }

    private func place(_ items: [Queries.TimelineItem], page: ListingPage, in listing: Listing) {
        let state = paging(listing)
        state.next = page.next
        state.tail = Set(items.suffix(Self.prefetchMargin).map(\.postID))
        let changed: Bool
        switch listing {
        case .notes:
            changed = all != items
            if changed { all = items }
            if allHasMore != (page.next != nil) { allHasMore = page.next != nil }
        case .bookless:
            changed = bookless != items
            if changed { bookless = items }
            if !booklessLoaded { booklessLoaded = true }
            if booklessWingHasNotes != page.wingHasNotes { booklessWingHasNotes = page.wingHasNotes }
        }
        // VM-65: a landing that changed the rows is a redraw; the note
        // listing's first is "the Library ready".
        let first = listing == .notes && !notesLandedOnce
        if listing == .notes { notesLandedOnce = true }
        if changed || first {
            AppTiming.libraryDelivered(bookless: listing == .bookless, first: first)
        }
    }

    /// **The read** — a page of `question`'s listing through the Mac's own
    /// paging read (`catalogNotesPage`; Bookless is its Pool-loose form), as
    /// the listing's rows. Counted for the timing layer (VM-65) on GRDB's
    /// queue. Row previews (wave 2) are NOT read here and never may be: they
    /// attach as a one-shot read over the LANDED rows' ids, beside `place` —
    /// the Mac's `loadNearExtras` — so the held page stays ∝ the page.
    nonisolated static func read(
        _ db: Database, _ question: Question, after cursor: Queries.CatalogCursor?, limit: Int
    ) throws -> ListingPage {
        let bookless = question.listing == .bookless
        AppTiming.libraryFetched(bookless: bookless)
        let page = try Queries.catalogNotesPage(
            db, query: "", sort: question.sort, direction: .desc, after: cursor, limit: limit,
            wingID: question.wing, poolLoose: bookless)
        let items = timelineItems(page)
        var wingHasNotes = true
        if bookless, cursor == nil, items.isEmpty {
            wingHasNotes = try !Queries.catalogNotesPage(
                db, query: "", limit: 1, wingID: question.wing).hits.isEmpty
        }
        return ListingPage(items: items, next: page.next, wingHasNotes: wingHasNotes)
    }

    /// **A page's hits as the listing's rows** (pure, pinned): the stored
    /// title (nil when absent), the stated day, the birth stamp, the profile,
    /// and the row's SORT KEY as its stamp — `Queries.library`'s own stamp,
    /// the value the union interleaves books by (pinned equal in Core,
    /// `LibraryPoolPagingTests`).
    nonisolated static func timelineItems(_ page: Queries.CatalogNotesPage) -> [Queries.TimelineItem] {
        zip(page.hits, page.keys).map { hit, key in
            Queries.TimelineItem(
                postID: hit.id, title: hit.storedTitle, entryDate: hit.detail,
                createdAt: hit.createdAt, stamp: key, profile: hit.profile)
        }
    }

    /// ONE-SHOT search over the standing catalog scope. An
    /// empty/whitespace query clears the search (the listing returns).
    /// Stale results are dropped (the latest typed query wins).
    private var activeQuery = ""
    func search(_ query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        activeQuery = trimmed
        guard !trimmed.isEmpty else {
            hits = nil
            return
        }
        do {
            let found = try await session.database.read { db in
                try Queries.searchCatalog(db, query: trimmed)
            }
            guard activeQuery == trimmed else { return }
            // Book and post hits navigate as themselves; block hits
            // navigate to their HOME NOTE — a pool-home block has no
            // phone door, so its row is not rendered (P-2).
            hits = found.filter { hit in
                hit.kind != .block || (hit.homeContainerID != nil && !hit.homeIsPool)
            }
            // A landed search clears any earlier error (the Mac catalog
            // catch's own success-clear — S3 ladder, MINOR 1).
            lastError = nil
        } catch is CancellationError {
            // `.task(id:)` cancels the in-flight search on every keystroke
            // and on the root's disappearance; GRDB's async read throws
            // CancellationError for it — never an error to show (the
            // sibling observation loops' own filter; S3 ladder, MINOR 1).
        } catch {
            // A superseded search's error never lands either (the Mac
            // catch's staleness guard).
            guard activeQuery == trimmed else { return }
            lastError = String(describing: error)
        }
    }

    /// Where a hit navigates — pure, pinned. nil = no phone door (the
    /// row was already filtered out of `hits`).
    nonisolated static func destination(for hit: Queries.CatalogHit) -> MobileRoute? {
        switch hit.kind {
        case .book:
            return .book(hit.id)
        case .post:
            return .note(hit.id, focus: false)
        case .block:
            guard let home = hit.homeContainerID, !hit.homeIsPool else { return nil }
            return .note(home, focus: false)
        }
    }

    /// "+ new note" — the phone's plain minting door, through the ONE
    /// shared mint (`MobileNewNoteDoor` — since P33 the shelf carries the
    /// twin, and the path cannot fork). Returns the note to open.
    func newNote() async -> String? {
        do {
            return try await MobileNewNoteDoor.mint(session: session)
        } catch {
            lastError = String(describing: error)
            return nil
        }
    }

    // MARK: - Delete a note (round 2, batch 4 — PR1)

    /// **The Library row's delete door.** The phone's OTHER note-delete
    /// door is the note's own ⋯ sheet; this is the one for a note she is
    /// not standing inside. Both move to Trash, both confirm, and both
    /// speak `RecoveryCopy`'s one wording.
    var pendingDeleteNote: Queries.TimelineItem?

    /// The alert host's binding.
    ///
    /// **THE RULE (batch 4.5b's confirm BLOCKER): a binding setter must never
    /// clear state that an action's continuation will read back.** SwiftUI
    /// sets `isPresented` to `false` synchronously inside tap handling, while
    /// an action's `Task { … }` cannot resume until that handling yields — so
    /// a `confirmDeleteNote()` that opened by reading `pendingDeleteNote` back
    /// found it already `nil` and **the note was never deleted.** The site
    /// obeyed this round's stated rule (*never a computed `Binding(get:set:)`
    /// over an `@Observable` property*) to the letter and was dead anyway:
    /// that rule names a SYNTAX, this one names the property that matters.
    /// The host therefore rides `presenting:` and the act takes its subject as
    /// a parameter, so no read-back survives for a setter to beat.
    var deleteNotePresented: Bool {
        get { pendingDeleteNote != nil }
        set { if !newValue { pendingDeleteNote = nil } }
    }

    func requestDeleteNote(_ item: Queries.TimelineItem) {
        pendingDeleteNote = item
    }

    /// The confirmed act. **The note is PASSED IN, never read back** — see
    /// the rule at `deleteNotePresented`.
    ///
    /// **It flushes first, and the shipped no-flush justification was false**
    /// (§49's MINOR). That justification read: *"this row deletes a note NO
    /// surface on this phone has open, so there is no pending buffer to
    /// land."* The shell's architecture falsifies it — BOTH tab stacks stay
    /// alive by design (`MobileLivenessAuthority`: "two `MobileWriteScreen`s
    /// can exist at once, and nothing about visibility ever fires
    /// `onDisappear`"), so the commonest road to this very door is *open a
    /// note → switch to Library → delete that row*, with the note's editor
    /// still mounted and its debounce possibly still holding keystrokes.
    /// `flushEveryOpenPost()` is the session's own door for exactly that and
    /// is a no-op when nothing is pending, so the guarantee costs nothing on
    /// the road the old comment described and saves the keystrokes on the one
    /// it forgot. (It lands text into a note that is about to be tombstoned —
    /// which is the point: a tombstone is recoverable for 30 days, and text
    /// that never reached the store is not.)
    @discardableResult
    func confirmDeleteNote(_ item: Queries.TimelineItem) async -> Bool {
        pendingDeleteNote = nil
        await session.flushEveryOpenPost()
        do {
            try await session.runner.run { ops in
                try ops.deleteContainer(item.postID)
            }
            lastError = nil
            receipt = RecoveryCopy.movedToTrashReceipt(.note)
            return true
        } catch {
            receipt = nil
            lastError = DeletionRefusal.words(error)
            return false
        }
    }

    /// A landed act's own words — kept apart from `lastError` so a success
    /// is never rendered in the red slot (the Mac recovery model's split).
    private(set) var receipt: String?

    /// A listing row's display name — the ONE display brain (13k K1).
    nonisolated static func rowTitle(_ item: Queries.TimelineItem) -> String {
        DisplayTitle.note(
            title: item.title, entryDate: item.entryDate, createdAt: item.createdAt)
    }
}
