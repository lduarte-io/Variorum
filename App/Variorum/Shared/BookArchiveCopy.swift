//
//  BookArchiveCopy.swift
//  Variorum (shared: Mac + Mobile)
//
//  13i-e U2 — BOOK ARCHIVE's platform-neutral words (her kickoff rulings
//  R-13ie-1…4; the binding record is the 13i-e plan's U2 RECORD,
//  `notes/plans/phase-13i-e-daily-journal.md`). Hoisted from birth so the
//  phone's catch-up speaks the SAME mark and sentences (MobileSoul §3 — a
//  brain built Mac-side in app-local code is a parity defect at birth). No
//  sentence here names a Mac door. All 13s-revoicable.
//

import Foundation
import VariorumCore

nonisolated enum BookArchiveCopy {
    /// Her second rider (R-13ie-4), the lighter of her two roads: *"either
    /// in the selector it being clear that it is archived or a 'confirm add to
    /// archived book?' but archived isn't supposed to be too onerous"* — every
    /// book SELECTOR and every MEMBERSHIP face names an archived book with
    /// this word, and the add lands on a plain click (the confirm is the
    /// recorded alternative, PROVISIONAL #179).
    static let word = "archived"

    /// "Name (archived)" for an archived reading; the bare name otherwise.
    static func name(_ reading: Reading) -> String {
        name(reading.name, archived: reading.archivedAt != nil)
    }

    static func name(_ name: String, archived: Bool) -> String {
        archived ? "\(name) (\(word))" : name
    }

    /// **THE VISIBLE PAUSE** (R-13ie-4 — "every method of auto ingestion
    /// should pause, which should be clear to users"). A BOOK whose rule
    /// reads says the ruled sentence; a GATHERING (her "I think that's fine
    /// to pause too") says what its pause means — it shows nothing. nil where
    /// nothing auto-ingests to pause: a live book with no rule, or any
    /// reading that is not archived.
    static let pausedBook = "Collecting is paused while this book is archived."
    static let pausedGathering =
        "Collecting is paused while this gathering is archived \u{2014} it shows nothing "
        + "until you unarchive it."

    static func pausedSentence(for reading: Reading) -> String? {
        guard reading.archivedAt != nil else { return nil }
        if reading.kind == .gathering { return pausedGathering }
        if case .rule = RuleGrammar.read(reading.querySpec) { return pausedBook }
        return nil
    }

    /// The sitting record §10's own wording — the daily Journal's archive
    /// caption: "the daily Journal can be archived, never deleted; it returns
    /// when a day arrives."
    static let dailyJournalCaption =
        "The daily Journal can be archived, never deleted; it returns when a day arrives."

    /// The delete guard's refusal (`dailyJournalCannotBeDeleted`) — ONE
    /// sentence for the shared refusal table and the deletion table (the
    /// phone's delete road), naming the road the op leaves open.
    static let cannotDeleteDailyJournal =
        "The daily Journal can't be deleted \u{2014} archive it instead; it comes back when a "
        + "day arrives."

    /// The comes-back RECEIPT (the architect's F-U1-6 ruling, its words): the
    /// day's filing brought an archived daily Journal back.
    static let journalCameBack = "The Journal is back on the Bookcase."
}
