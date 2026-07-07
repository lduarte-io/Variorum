//
//  EntryListViewModel.swift
//  VariorumMobile
//
//  Phase 8, Step 4 — the past-entries list: a bounded live listing (P1: a
//  held observation's fetch is viewport-shaped) over the journal profile,
//  newest day first, plus the whole-library scope so any post's text can be
//  opened for editing (pillar 8's second capability). Chrome only — the
//  operations layer enforces everything.
//

import Foundation
import GRDB // AsyncValueObservation iteration (member import visibility)
import Observation
import VariorumCore

@Observable
@MainActor
final class EntryListViewModel {
    enum Scope: String, CaseIterable, Sendable {
        case journal = "Journal"
        case all = "All posts"
    }

    private let session: AppSession
    /// Bounded on purpose (P1) — `observeLibrary` requires a limit.
    private let listingLimit: Int
    /// Injectable clock/calendar: "today" is the USER'S calendar day.
    private let now: @Sendable () -> Date
    private let calendar: Calendar

    var scope: Scope = .journal
    private(set) var journalEntries: [Queries.TimelineItem] = []
    private(set) var allPosts: [Queries.TimelineItem] = []
    private(set) var lastError: String?

    var visible: [Queries.TimelineItem] {
        scope == .journal ? journalEntries : allPosts
    }

    init(
        session: AppSession,
        listingLimit: Int = 200,
        now: @escaping @Sendable () -> Date = { Date() },
        calendar: Calendar = .current
    ) {
        self.session = session
        self.listingLimit = listingLimit
        self.now = now
        self.calendar = calendar
    }

    /// The journal listing: journal-profile posts, newest `entry_date` first.
    func startJournal() async {
        do {
            for try await items in session.database.observeLibrary(
                sort: .entryDate, direction: .desc, limit: listingLimit, profile: .journal
            ) {
                journalEntries = items
            }
        } catch is CancellationError {
            // View went away; nothing to do.
        } catch {
            lastError = String(describing: error)
        }
    }

    /// The whole library (bounded), so any post's block text is reachable
    /// for editing.
    func startAll() async {
        do {
            for try await items in session.database.observeLibrary(
                sort: .lastTouched, direction: .desc, limit: listingLimit
            ) {
                allPosts = items
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// "New entry" for today — create-or-open (the notebook rule; Step 3).
    /// Returns the entry to navigate to.
    func openToday() async -> String? {
        await open(on: JournalDay.dayString(from: now(), calendar: calendar))
    }

    /// "New entry" for any chosen day, past or future (author 2026-07-07:
    /// backfilling is legitimate; future allowed).
    func open(on entryDate: String) async -> String? {
        do {
            let result = try await session.runner.run { ops in
                try ops.createOrOpenJournalEntry(entryDate: entryDate)
            }
            return result.container.id
        } catch {
            lastError = String(describing: error)
            return nil
        }
    }

    func dayString(for date: Date) -> String {
        JournalDay.dayString(from: date, calendar: calendar)
    }
}
