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
    ///
    /// **The day's entry belongs on the shelf** (Phase 13c, batch 1D —
    /// ledger A1, the class sweep's third instance): this door minted the
    /// entry and stopped, exactly as the Fragments bridge did, so an entry
    /// captured on the phone arrived on the Mac in NO book and showed up in
    /// the Pool. Nothing repaired it either — a phone-minted day she never
    /// touches in Fragments produces only a Variorum→Fragments push, never a
    /// landing, so it stayed bookless until she happened to open ⌘J on that
    /// exact day. It now runs the SAME shared second half the bridge does
    /// (`Operations.shelveInDailyJournalBook`: never throws, so it can never
    /// block the mint; a decided pair — live or tombstoned membership — is
    /// left exactly as she left it; a missing designation is reported, never
    /// invented). The entry ALWAYS opens; only the note changes.
    func open(on entryDate: String) async -> String? {
        do {
            let opened: (postID: String, shelving: Operations.DailyBookShelving) =
                try await session.runner.run { ops in
                    let entry = try ops.createOrOpenJournalEntry(entryDate: entryDate)
                    return (entry.container.id,
                            ops.shelveInDailyJournalBook(entry.container.id))
                }
            lastError = Self.shelvingNote(opened.shelving)
            return opened.postID
        } catch {
            lastError = String(describing: error)
            return nil
        }
    }

    /// The phone's wording for a shelving outcome — nil when there is
    /// nothing to say. The Mac is where books are managed, so every note
    /// points there rather than offering a door the capture surface does not
    /// have (P-2: the door acts, and where it cannot it speaks honestly).
    static func shelvingNote(_ shelving: Operations.DailyBookShelving) -> String? {
        switch shelving {
        case .shelved, .alreadyDecided:
            return nil
        case .noDailyBook:
            return "Entry saved. It isn't in a journal book yet — pick a daily journal on the Mac."
        case .bookFinished:
            return "Entry saved. Your daily journal book is finished, so it wasn't added — reopen it on the Mac."
        case .bookAtCapacity:
            return "Entry saved. Your daily journal book is full, so it wasn't added — extend it on the Mac."
        case .refused(let reason):
            return "Entry saved, but it wasn't added to your daily journal book: \(reason)"
        }
    }

    func dayString(for date: Date) -> String {
        JournalDay.dayString(from: date, calendar: calendar)
    }
}
