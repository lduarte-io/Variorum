//
//  ShelfViewModel.swift
//  Variorum
//
//  Phase 13, B2 — the shelf's model (the sitting-1 books reversal + R4's
//  terminal list + R38's pinning). Two cost tiers by contract: the book
//  list + pins ride a held observation (author-scale); word counts and the
//  tags column are ONE-SHOT loads on appearance/refresh (corpus-scale
//  aggregates must never re-run at autosave rate — the P1 discipline the
//  core query documents).
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import VariorumCore

@MainActor
@Observable
final class ShelfViewModel {
    @ObservationIgnored let session: AppSession

    private(set) var books: [Queries.ShelfBook] = []
    private(set) var pins: [String] = []
    private(set) var wordCounts: [String: Int] = [:]
    private(set) var bookTags: [String: [String]] = [:]
    private(set) var lastError: String?
    /// R98: apply-and-report's REPORT half — not an error, rendered muted.
    private(set) var lastReport: String?

    init(session: AppSession) {
        self.session = session
    }

    /// The observed snapshot (a struct — the observe seam wants Equatable;
    /// nonisolated: it crosses off the main actor inside the observation).
    nonisolated struct ShelfSnapshot: Equatable, Sendable {
        var books: [Queries.ShelfBook]
        var pins: [String]
    }

    /// The held half: books + pins (both tiny).
    func start() async {
        do {
            for try await value in session.database.observe({ db in
                ShelfSnapshot(
                    books: try Queries.bookshelf(db),
                    pins: try Queries.shelfPins(db))
            }) {
                books = value.books
                pins = value.pins
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// The one-shot half: word counts + the tags column (refresh on
    /// appearance and after membership edits — a deliberate fetch, never a
    /// held observation).
    func refreshAggregates() async {
        do {
            let (words, tags) = try await session.database.read { db in
                (try Queries.bookWordCounts(db), try Queries.shelfBookTags(db))
            }
            wordCounts = words
            bookTags = tags
        } catch {
            lastError = String(describing: error)
        }
    }

    /// Shelf order (presentation, pinned by test): pinned books first in
    /// pin order (R38), then journal-profile books (the journal lives on
    /// the shelf), then the rest by name.
    var orderedBooks: [Queries.ShelfBook] {
        Self.ordered(books: books, pins: pins)
    }

    /// 13u1 UNIT 1 (the sweep's P40): the RULE moved to
    /// `Shared/ShelfOrder.swift` — the phone carried a byte-identical copy.
    /// A forwarder, so every Mac caller and pin reads as it did.
    nonisolated static func ordered(
        books: [Queries.ShelfBook], pins: [String]
    ) -> [Queries.ShelfBook] {
        ShelfOrder.ordered(books: books, pins: pins)
    }

    /// The ls-line's numbers ("~/shelf · 6 books · 2 finished").
    var finishedCount: Int { books.filter(\.reading.locked).count }

    /// The tags column's content for one book: a smart book shows its own
    /// query tags (the spec IS its identity); a curated book shows its
    /// member posts' most-applied paths (the core aggregate).
    func tagsColumn(for book: Queries.ShelfBook) -> [String] {
        // 13u1 UNIT 1 (P40): the smart-book half is `ShelfOrder`'s now — the
        // phone asked the identical question of the identical spec.
        ShelfOrder.smartQueryTagPaths(of: book.reading) ?? bookTags[book.reading.id] ?? []
    }

    /// Bounded progress for the meta column ("62% of 10,000w" — the
    /// word-target face, R38's bounded thread).
    func progress(for book: Queries.ShelfBook) -> (percent: Int, target: Int)? {
        guard let target = book.reading.wordTarget, target > 0 else { return nil }
        let words = wordCounts[book.reading.id] ?? 0
        return (Int((Double(words) / Double(target) * 100).rounded()), target)
    }

    // MARK: - Actions

    /// The quick-entry bar (R3): typed text becomes a WHOLE post — bulk
    /// entry through the import pipeline (segmentation + the spacing
    /// ruling ride free). Returns the new post's id for selection.
    func quickEntry(_ text: String) async -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        do {
            let result = try await session.runner.run { ops in
                try ops.importPost(title: nil, text: text)
            }
            return result.container.id
        } catch {
            lastError = String(describing: error)
            return nil
        }
    }

    func setPinned(_ readingID: String, pinned: Bool) async {
        await run { try $0.setShelfPinned(readingID, pinned: pinned) }
    }

    /// Finish / reopen (the `reading.locked` face — §14 item 10's missing
    /// UI, finally).
    func setFinished(_ readingID: String, finished: Bool) async {
        await run { finished ? try $0.lockReading(readingID) : try $0.unlockReading(readingID) }
    }

    func setWordTarget(_ readingID: String, target: Int?) async {
        await run { try $0.setReadingWordTarget(readingID, wordTarget: target) }
        await refreshAggregates()
    }

    func setMaxPosts(_ readingID: String, maxPosts: Int?) async {
        await run { try $0.setReadingMaxPosts(readingID, maxPosts: maxPosts) }
    }

    /// The re-designation door (round 2, MAJOR 2): point Today's Entry at
    /// a new daily journal book.
    func designateDailyJournal(_ readingID: String) async {
        await run { try $0.setDailyJournalBook(readingID) }
    }

    /// SMART → CURATED (13c 2D — C2/N38). Reports what happened rather than
    /// going quiet: the conversion changes what a book IS, so a silent
    /// success on a list of book names would be the least legible outcome
    /// on the shelf.
    func convertToCurated(
        _ readingID: String, keepCollecting: Bool, collectingName: String?
    ) async {
        do {
            let result = try await session.runner.run { ops in
                // 13e E13 — the typed fresh-collector name only (the shelf
                // half of the same guard the navigator's door carries; a
                // derived name is never refused).
                if let collectingName { try ops.assertBookNameIsFree(collectingName) }
                return try ops.convertSmartReadingToCurated(
                    readingID, keepCollecting: keepCollecting,
                    collectingName: collectingName)
            }
            lastError = nil
            let posts = result.membershipIDs.count
            var report = "“\(result.reading.name)” is a hand-shaped book now — "
                + "\(posts) note\(posts == 1 ? "" : "s") kept, in the order you had them."
            if let fresh = result.collectingReading {
                report += " “\(fresh.name)” keeps collecting the filter."
            }
            lastReport = report
        } catch let error as OperationError {
            lastReport = nil
            lastError = ReadingsViewModel.message(error)
        } catch {
            lastReport = nil
            lastError = String(describing: error)
        }
        await refreshAggregates()
    }

    /// Drag a post ONTO a book row (sitting 1: "drag posts onto a book").
    /// Tolerant of the already-in case — a drop is a gesture, not a form.
    /// R98 (batch 10): a SMART book accepts the drop BY TAGGING —
    /// apply-and-report; a filter tagging can't satisfy refuses
    /// descriptively (the op's reason reaches the shelf's status line).
    func addPost(_ postID: String, to readingID: String) async {
        do {
            let kind = books.first { $0.reading.id == readingID }?.reading.kind
            if kind == .smart {
                let result = try await session.runner.run { ops in
                    try ops.collectPostIntoSmartReading(postID, into: readingID)
                }
                lastError = nil
                lastReport = result.alreadyMatched
                    ? "Already collected — it matches this book's filter."
                    : "Added by tagging \(result.appliedTagPaths.map { "#\($0)" }.joined(separator: " ")) — smart books collect by filter."
            } else {
                try await session.runner.run { ops in
                    _ = try ops.addPostToReading(postID, to: readingID)
                }
                lastError = nil
            }
        } catch let error as OperationError {
            if case .alreadyInReading = error { return }
            if case .smartFilterUnsatisfiable(_, let reason) = error {
                lastError = "That book can't take this note: \(reason)"
            } else {
                lastError = ReadingsViewModel.message(error)
            }
        } catch {
            lastError = String(describing: error)
        }
        await refreshAggregates()
    }

    private func run(_ body: @escaping @Sendable (Operations) throws -> Void) async {
        do {
            try await session.runner.run(body)
            lastError = nil
        } catch let error as OperationError {
            lastError = ReadingsViewModel.message(error)
        } catch {
            lastError = String(describing: error)
        }
    }
}
