//
//  MobileTodayDoor.swift
//  VariorumMobile
//
//  Mobile Stage 3, batch 1 — Today's Entry (M7): create-or-open THE day's
//  entry (the notebook rule, `createOrOpenJournalEntry`) plus the SHARED
//  daily-book shelving half (`Operations.shelveInDailyJournalBook` — the
//  one implementation all four doors share since 13c batch 1D + the 13d
//  #37(iii) ruling: it CREATES AND PINS the Journal book when none is
//  designated, never blocks the mint, and never re-shelves a membership
//  she removed). Both halves run in ONE runner closure — the Mac
//  `JournalBooks.openToday` composition, the phone's edition.
//
//  Carried verbatim from the retired Phase 8 capture door: the phone's
//  WORDINGS point at the Mac, where books are managed — every outcome the
//  shared helper can report speaks, and a clean shelving says nothing
//  (P-2: the door acts; where it cannot, it speaks honestly). The Phase 8
//  A1-class pins re-point here (`MobileShellTests`).
//

import Foundation
import VariorumCore

@MainActor
enum MobileTodayDoor {
    struct Outcome: Equatable {
        let postID: String
        /// nil when there is nothing to say (shelved / already decided).
        let note: String?
    }

    /// Opens (or mints) the day's entry and shelves it into the daily
    /// journal book. `day` is injectable for tests; nil = the user's
    /// calendar day now.
    static func open(
        session: AppSession, day: String? = nil, calendar: Calendar = .current
    ) async throws -> Outcome {
        let entryDay = day ?? JournalDay.dayString(from: Date(), calendar: calendar)
        let opened: (postID: String, shelving: Operations.DailyBookShelving) =
            try await session.runner.run { ops in
                let entry = try ops.createOrOpenJournalEntry(entryDate: entryDay)
                return (entry.container.id,
                        ops.shelveInDailyJournalBook(entry.container.id))
            }
        return Outcome(postID: opened.postID, note: shelvingNote(opened.shelving))
    }

    /// The phone's wording for a shelving outcome — nil when there is
    /// nothing to say. Books are managed on the Mac, so every note points
    /// there rather than offering a door the phone does not have.
    /// (Carried byte-for-byte from the retired Phase 8 capture surface.)
    static func shelvingNote(_ shelving: Operations.DailyBookShelving) -> String? {
        switch shelving {
        case .shelved, .alreadyDecided:
            return nil
        case .bookFinished:
            return "Entry saved. Your daily journal book is finished, so it wasn't added — reopen it on the Mac."
        case .bookAtCapacity:
            return "Entry saved. Your daily journal book is full, so it wasn't added — extend it on the Mac."
        case .wrongKind:
            return "Entry saved. Your daily journal is a smart book, which can't hold entries — pick a curated one on the Mac."
        case .refused(let reason):
            return "Entry saved, but it wasn't added to your daily journal book: \(reason)"
        }
    }
}
