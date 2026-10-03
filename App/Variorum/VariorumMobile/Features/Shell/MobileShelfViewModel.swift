//
//  MobileShelfViewModel.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — the shelf home's model (M7: shelf-first).
//  Mirrors the Mac `ShelfViewModel`'s cost tiers exactly (the P1
//  discipline the core query documents): the book list + pins + the daily
//  designation ride ONE held observation (author-scale rows); the tags
//  column is a ONE-SHOT load on appearance/refresh — corpus-adjacent
//  aggregates never re-run at autosave rate. Word counts (the Mac's other
//  one-shot) are deliberately NOT fetched: LK5 ranks word progress behind
//  the phone's faces and v1 ships without it (recorded).
//
//  Chrome only — no business rules; the operations layer enforces.
//

import Foundation
import GRDB // AsyncValueObservation iteration (member import visibility)
import Observation
import VariorumCore

@MainActor
@Observable
final class MobileShelfViewModel {
    /// Non-private for the same reason the Mac `ShelfViewModel`'s is: the
    /// shelf's sheets (create book) build their own models on the session.
    @ObservationIgnored let session: AppSession

    private(set) var books: [Queries.ShelfBook] = []
    private(set) var pins: [String] = []
    private(set) var dailyBookID: String?
    private(set) var bookTags: [String: [String]] = [:]
    /// 13i-a: gatherings' rule tags as live paths (rules hold IDs now).
    private(set) var ruleTags: [String: [String]] = [:]
    private(set) var lastError: String?
    /// The Today door's shelving note (not an error — rendered muted).
    private(set) var lastReport: String?

    /// How many values the HELD books observation has delivered. Test
    /// observability only — nothing renders it — and it exists because
    /// §53 row 7's real hazard is structural rather than temporal: the
    /// shelf is now a typing surface, so a capture that woke this
    /// observation would re-run a books query at autosave rate. A tick
    /// count is a fact about what the store notifies; a timing could pass
    /// merely by being fast. (`@ObservationIgnored` deliberately: a
    /// counter that itself invalidated the view would be its own defect.)
    @ObservationIgnored private(set) var observationTicks = 0

    init(session: AppSession) {
        self.session = session
    }

    /// The observed snapshot (nonisolated: it crosses off the main actor
    /// inside the observation).
    nonisolated struct Snapshot: Equatable, Sendable {
        var books: [Queries.ShelfBook]
        var pins: [String]
        var dailyBookID: String?
    }

    /// The held half: books + pins + the daily designation (all tiny).
    func start() async {
        do {
            for try await value in session.database.observe({ db in
                Snapshot(
                    books: try Queries.bookshelf(db),
                    pins: try Queries.shelfPins(db),
                    dailyBookID: try Queries.dailyJournalBookID(db))
            }) {
                observationTicks += 1
                books = value.books
                pins = value.pins
                dailyBookID = value.dailyBookID
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// The one-shot half: the tags column (refresh on appearance — a
    /// deliberate fetch, never a held observation).
    func refreshTags() async {
        do {
            (bookTags, ruleTags) = try await session.database.read {
                (try Queries.shelfBookTags($0), try Queries.ruleTagPaths($0))
            }
        } catch {
            lastError = String(describing: error)
        }
    }

    /// Shelf order — the Mac semantics via the pure face brain.
    var orderedBooks: [Queries.ShelfBook] {
        MobileShelfFaces.ordered(books: books, pins: pins)
    }

    /// One row's faces (LK5): name-with-state, and the meta line.
    func rowName(for book: Queries.ShelfBook) -> String {
        MobileShelfFaces.name(for: book)
    }

    /// `showingDailyMarker` (round 2, batch 5 — R26.2): the shelf row that
    /// wears the Today BADGE suppresses the word, because the badge is a
    /// better daily marker than the word and phone width is scarce. Every
    /// other caller keeps the marker by default, and the face BRAIN is
    /// untouched — this is a per-row presentation call, not a rule change.
    func rowMeta(
        for book: Queries.ShelfBook, showingDailyMarker: Bool = true
    ) -> String {
        MobileShelfFaces.meta(
            for: book,
            tagPaths: MobileShelfFaces.tagPaths(
                for: book, curatedTags: bookTags, ruleTags: ruleTags),
            isDaily: showingDailyMarker && book.reading.id == dailyBookID)
    }

    /// Pin / unpin (parity C2 — the [B1] record's deliberately-deferred
    /// ACT; the phone has RENDERED pin order since S3): one reversible
    /// toggle through the core's own `setShelfPinned` (append-to-pin-order
    /// semantics, idempotent both ways — R38's letter).
    func setPinned(_ readingID: String, pinned: Bool) async {
        do {
            try await session.runner.run { ops in
                try ops.setShelfPinned(readingID, pinned: pinned)
            }
            lastError = nil
        } catch {
            lastError = String(describing: error)
        }
    }

    /// + New Note (P33, parity A3 — Library's twin through the ONE
    /// shared mint): a nameless bookless note, opened for writing.
    func newNote() async -> String? {
        do {
            return try await MobileNewNoteDoor.mint(session: session)
        } catch {
            lastError = String(describing: error)
            return nil
        }
    }

    // MARK: - Delete a book (round 2, batch 4 — PR4)

    /// **The phone could not delete a book either** — `deleteReading`
    /// appeared in `VariorumMobile/` exactly once, in the tutorial seeder's
    /// own cleanup (the parity inventory's R4; its tell is that the core's
    /// Trash listing defines a `.book` kind the phone could never populate).
    ///
    /// Move to Trash, like every other deletion door outside the Trash
    /// itself: `deleteReading` tombstones the reading and its chapters and
    /// memberships by cascade, and `restoreReading` (S4-28.2, her reversal
    /// of the no-restore-door boundary) is waiting on the other side for
    /// `TrashWindow.days`.
    ///
    /// **The wording carries the 13j books lesson, which she had to teach
    /// once already: deleting a book does NOT delete its notes.** The notes
    /// keep living in the library; only the ordered collection goes.
    var pendingDeleteBook: Queries.ShelfBook?

    /// The alert host's binding.
    ///
    /// **THE RULE (batch 4.5b's confirm BLOCKER): a binding setter must never
    /// clear state that an action's continuation will read back.** SwiftUI
    /// sets `isPresented` to `false` synchronously inside tap handling while
    /// an action's `Task { … }` waits for that handling to yield, so a
    /// `confirmDeleteBook()` that opened by reading `pendingDeleteBook` back
    /// found `nil` and **the book was never deleted.** This site obeyed the
    /// round's stated rule (*never a computed `Binding(get:set:)` over an
    /// `@Observable` property*) exactly and was dead anyway — that rule names
    /// a SYNTAX, this one names the property that matters. The host rides
    /// `presenting:` and the act takes its subject as a parameter.
    var deleteBookPresented: Bool {
        get { pendingDeleteBook != nil }
        set { if !newValue { pendingDeleteBook = nil } }
    }

    func requestDeleteBook(_ book: Queries.ShelfBook) {
        pendingDeleteBook = book
    }

    /// The confirmed act. Returns whether it went, for the callers that
    /// need to navigate away from it. **The book is PASSED IN, never read
    /// back** — see the rule at `deleteBookPresented`.
    @discardableResult
    func confirmDeleteBook(_ book: Queries.ShelfBook) async -> Bool {
        pendingDeleteBook = nil
        do {
            try await session.runner.run { ops in
                try ops.deleteReading(book.reading.id)
            }
            lastError = nil
            lastReport = RecoveryCopy.movedToTrashReceipt(.book)
            return true
        } catch {
            lastReport = nil
            // The ONE deletion-refusal home (A1-18) — this door used to
            // borrow the book-details table, which covered a different subset
            // of `OperationError` than the Trash's did.
            lastError = DeletionRefusal.words(error)
            return false
        }
    }

    /// **13i-e U2 — ARCHIVE the daily Journal** (its delete door's place, P-2):
    /// the op, then a receipt naming the road back. The book is passed in
    /// (`confirmDeleteBook`'s rule).
    func archiveDailyJournal(_ book: Queries.ShelfBook) async {
        do {
            try await session.runner.run { ops in try ops.archiveReading(book.reading.id) }
            lastError = nil
            lastReport = MobileShelfFaces.archivedDailyJournalReceipt(name: book.reading.name)
        } catch {
            lastReport = nil
            lastError = OpsRefusalCopy.words(for: error, roads: .phone) ?? DeletionRefusal.words(error)
        }
    }

    /// Today's Entry (M7's button): create-or-open + the shared shelving
    /// door, in one composition. The entry ALWAYS opens; only the note
    /// changes. Returns the entry to navigate to.
    func openToday(day: String? = nil) async -> String? {
        do {
            let outcome = try await MobileTodayDoor.open(session: session, day: day)
            lastReport = outcome.note
            return outcome.postID
        } catch {
            lastError = String(describing: error)
            return nil
        }
    }
}
