//
//  MobileShelfViewModel.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — the shelf home's model (M7: shelf-first).
//  Mirrors the Mac `ShelfViewModel`'s cost tiers exactly (the P1
//  discipline the core query documents): the book list + the daily
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
    private(set) var dailyBookID: String?
    private(set) var bookTags: [String: [String]] = [:]
    /// 13i-a: gatherings' rule tags as live paths (rules hold IDs now).
    private(set) var ruleTags: [String: [String]] = [:]
    /// VM-61: every value this slot holds is a refusal, so it speaks on the
    /// phone's one line as it is set (nil says nothing); no screen draws it.
    private(set) var lastError: String? {
        didSet { MobileLine.refuse(lastError, session: session) }
    }
    /// The Today door's shelving note (not an error — rendered muted), and
    /// the book doors' receipts. VM-61: each write below speaks on the one
    /// line with its own class.
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
        var dailyBookID: String?
    }

    /// The held half: books + the daily designation (all tiny). VM-83: the
    /// pin list left with the Pin door — each `ShelfBook` carries the UNION
    /// star (`starred`), which is what the order floats.
    ///
    /// VM-57: the books of the wing the phone stands in (the Shelf AND the
    /// Library's Books filter, which wears this same model), re-read for
    /// each wing.
    func start() async {
        await MobileWingScope.follow(session.wing) { [self] wing in
            do {
                for try await value in session.database.observe({ db in
                    Snapshot(
                        books: try Queries.bookshelf(db, wingID: wing),
                        dailyBookID: try Queries.dailyJournalBookID(db))
                }) {
                    observationTicks += 1
                    books = value.books
                    dailyBookID = value.dailyBookID
                }
            } catch is CancellationError {
            } catch {
                lastError = OpsRefusalCopy.sentence(for: error, roads: .phone)
            }
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
            lastError = OpsRefusalCopy.sentence(for: error, roads: .phone)
        }
    }

    /// **Shelf order — the Mac Bookcase's own rule** (VM-83, W-068; her
    /// ruling 2026-11-19: "book order - that's fine to leave it for wave 3"):
    /// the shared `BookcaseBoard.ordered` — STARRED books float first, then
    /// a–z by Finder's comparison (case-blind, digit-aware: "apple" before
    /// "Zebra", "Book 2" before "Book 10"), journal books among the rest. The
    /// retired `ShelfOrder` rule (pins, then journal-trait books, then
    /// case-sensitive `<`) is gone. A–Z only: the visible "a–z or last
    /// edited" choice is the Bookcase's real chrome, wave 3 (VM-113). The
    /// Library's book rows read this order too.
    var orderedBooks: [Queries.ShelfBook] {
        BookcaseBoard.ordered(books, mode: .alphabetical, lastEdited: [:])
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

    /// **The row's long-press menu, as data** (VM-83, W-071): the acts in the
    /// order the view draws them. `starred` is the stars model's answer (the
    /// Star door's own state source).
    func rowActs(for book: Queries.ShelfBook, starred: Bool) -> [MobileShelfRowAct] {
        [
            .star(starred: starred),
            MobileShelfFaces.offersArchiveInsteadOfDelete(book.reading)
                ? .archiveDailyJournal : .delete(book.reading.kind),
        ]
    }

    // (VM-83, W-071: `setPinned` — the row's "Pin to Shelf Top" — RETIRED.
    // Since 13i-d `setShelfPinned` IS `setStarred`, so Pin and Star were two
    // doors writing one star, and pressing Pin flipped Star's label too. The
    // Star door is the one door, as on the Mac: SurfaceContracts, The
    // Bookcase — "the Mac's Pin door is retired into Star".)

    /// + New Note (P33, parity A3 — Library's twin through the ONE
    /// shared mint): a nameless bookless note, opened for writing.
    func newNote() async -> String? {
        do {
            return try await MobileNewNoteDoor.mint(session: session)
        } catch {
            lastError = OpsRefusalCopy.sentence(for: error, roads: .phone)
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
            // VM-83 (W-073): a gathering's receipt names a gathering.
            lastReport = RecoveryCopy.movedToTrashReceipt(
                .book, isGathering: book.reading.kind == .gathering)
            MobileLine.say(
                lastReport, as: .removal(.putBackBook(book.reading.id)), session: session)
            return true
        } catch {
            lastReport = nil
            // The ONE deletion-refusal home (A1-18) — this door used to
            // borrow the book-details table, which covered a different subset
            // of `OperationError` than the Trash's did.
            lastError = DeletionRefusal.sentence(error, roads: .phone)
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
            MobileLine.say(
                lastReport, as: .removal(.unarchiveBook(book.reading.id)), session: session)
        } catch {
            lastReport = nil
            lastError = OpsRefusalCopy.words(for: error, roads: .phone) ?? DeletionRefusal.sentence(error, roads: .phone)
        }
    }

    /// Today's Entry (M7's button): create-or-open + the shared shelving
    /// door, in one composition. The entry ALWAYS opens; only the note
    /// changes. Returns the entry to navigate to.
    func openToday(day: String? = nil) async -> String? {
        do {
            let outcome = try await MobileTodayDoor.open(session: session, day: day)
            lastReport = outcome.note
            // The entry opened but was NOT filed — a direction she must see
            // (the Mac ⌘J door's own class: `status.refuse(note)`).
            MobileLine.say(outcome.note, as: .direction, session: session)
            return outcome.postID
        } catch {
            lastError = OpsRefusalCopy.sentence(for: error, roads: .phone)
            return nil
        }
    }
}
