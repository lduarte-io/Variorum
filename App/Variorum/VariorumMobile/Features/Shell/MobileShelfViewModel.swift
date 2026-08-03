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
    @ObservationIgnored private let session: AppSession

    private(set) var books: [Queries.ShelfBook] = []
    private(set) var pins: [String] = []
    private(set) var dailyBookID: String?
    private(set) var bookTags: [String: [String]] = [:]
    private(set) var lastError: String?
    /// The Today door's shelving note (not an error — rendered muted).
    private(set) var lastReport: String?

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
            bookTags = try await session.database.read { try Queries.shelfBookTags($0) }
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

    func rowMeta(for book: Queries.ShelfBook) -> String {
        MobileShelfFaces.meta(
            for: book,
            tagPaths: MobileShelfFaces.tagPaths(for: book, curatedTags: bookTags),
            isDaily: book.reading.id == dailyBookID)
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
