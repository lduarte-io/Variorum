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

@MainActor
@Observable
final class MobileLibraryViewModel {
    enum Filter: String, CaseIterable, Sendable {
        case all
        case bookless
        /// The scraps area (parity C3 — her "view your pool of scraps …
        /// and maybe add to it"): standalone blocks, not notes — the
        /// listing is `MobileScrapsModel`'s, not this model's.
        case scraps
    }

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

    var visible: [Queries.TimelineItem] {
        switch filter {
        case .all: return all
        case .bookless: return bookless
        // Scraps are blocks, not notes — their listing is the scraps
        // model's; this note listing is empty under that filter.
        case .scraps: return []
        }
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
    func setSort(_ next: Queries.LibrarySort) {
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
