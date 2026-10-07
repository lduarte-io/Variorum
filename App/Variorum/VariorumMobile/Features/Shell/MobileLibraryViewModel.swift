//
//  MobileLibraryViewModel.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — the Library tab's model (M7: Library =
//  everything + search; bookless notes as a filter — the Pool's phone
//  home, R29's letter).
//
//  · The listing is the STANDING sort vocabulary: `observeLibrary`
//    (last-touched, newest first), bounded on purpose (P1 — a held
//    observation's fetch is viewport-shaped). The bookless filter holds
//    `Queries.poolPosts` the same way (bounded; derived smart membership
//    counts as being in a book — the core query's own rule).
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
    /// Bounded on purpose (P1) — `observeLibrary` requires a limit.
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
        Self.union(notes: visible, books: filter == .all ? books : [], sort: sort)
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
    nonisolated static func union(
        notes: [Queries.TimelineItem], books: [Queries.ShelfBook],
        sort: Queries.LibrarySort
    ) -> [MobileLibraryRow] {
        struct Keyed {
            let stamp: String
            let kindRank: Int
            let index: Int
            let row: MobileLibraryRow
        }
        var keyed: [Keyed] = []
        keyed.reserveCapacity(notes.count + books.count)
        for (index, item) in notes.enumerated() {
            keyed.append(Keyed(stamp: item.stamp, kindRank: 0, index: index, row: .note(item)))
        }
        for (index, book) in books.enumerated() {
            keyed.append(
                Keyed(stamp: bookStamp(book, sort: sort), kindRank: 1, index: index,
                      row: .book(book)))
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

    /// Everything, newest first under the picked stamp (the Mac
    /// library's own observation shape; `.lastTouched` is the standing
    /// default).
    func startAll() async {
        do {
            for try await items in session.database.observeLibrary(
                sort: sort, direction: .desc, limit: listingLimit
            ) {
                all = items
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// The bookless filter — the Pool's phone home (`Queries.poolPosts`:
    /// no live curated membership AND no smart book collecting).
    func startBookless() async {
        do {
            let limit = listingLimit
            for try await items in session.database.observe({ db in
                try Queries.poolPosts(db, limit: limit)
            }) {
                bookless = items
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
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
