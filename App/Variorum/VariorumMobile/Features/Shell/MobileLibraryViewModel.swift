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
    }

    @ObservationIgnored private let session: AppSession
    /// Bounded on purpose (P1) — `observeLibrary` requires a limit.
    @ObservationIgnored private let listingLimit: Int

    var filter: Filter = .all
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
        filter == .all ? all : bookless
    }

    /// Everything, newest first — the standing sort (the Mac library's
    /// own observation shape).
    func startAll() async {
        do {
            for try await items in session.database.observeLibrary(
                sort: .lastTouched, direction: .desc, limit: listingLimit
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

    /// A listing row's display name — the ONE display brain (13k K1).
    nonisolated static func rowTitle(_ item: Queries.TimelineItem) -> String {
        DisplayTitle.note(
            title: item.title, entryDate: item.entryDate, createdAt: item.createdAt)
    }
}
