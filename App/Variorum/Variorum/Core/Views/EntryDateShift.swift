//
//  EntryDateShift.swift
//  Variorum (Mac)
//
//  VX-587 (the VX-805 run, Unit A; R-805-3 — "chord + menu act") — "Shift
//  date a day earlier": ONE registry capability (`.shiftEntryDateEarlier`)
//  on any note with an entry date. Her 10-20 note: "shortcut to make a dated
//  entry one day earlier would be nice" — late-night journaling backfill.
//
//  This file is the ONE act every door runs (the `note ▾` menus of both bars,
//  ⌘K, and — once her chord is ruled — the menu bar's key) and its words:
//  the op (`Operations.shiftEntryDate`, one transaction over the stored
//  day), then a receipt naming the new date; nothing to shift speaks the
//  registry's note. The door rule is `doorShows` — the bars carry their own
//  note and read it on that note's date; the routed doors (⌘K, the menu bar)
//  read the same rule through the router's `noteHasEntryDate` fact.
//

import Foundation
import VariorumCore

/// The act's words (PROVISIONAL — her wording pass).
nonisolated enum EntryDateShiftCopy {
    /// Her own words for the act (R-805-3), as the `note ▾` menu's sentence-case
    /// date door beside it reads ("Set date…").
    static let verb = "Shift date a day earlier"

    static let unavailableNote =
        "Shift date a day earlier needs a dated note \u{2014} open one, or set its date "
        + "first (note \u{25BE} \u{25B8} Set date\u{2026})."

    /// The receipt names the new date in the app's ONE day voice
    /// (`TimeStampFace.day` — *Nov 3*, the year riding when it is not this
    /// one: the note box's and the Library's day words), never the raw key —
    /// the stage walk's P-805-A3 nit ("Now dated 2026-11-03."). A key that
    /// will not parse (never, from the op) is said as stored.
    static func receipt(
        _ day: String, now: Date,
        calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> String {
        guard let date = JournalDay.date(from: day, calendar: calendar) else {
            return "Now dated \(day)."
        }
        return "Now dated \(TimeStampFace.day(date, now: now, calendar: calendar, locale: locale))."
    }
}

@MainActor
enum EntryDateShift {
    /// **The door rule**: a note whose stored date is a valid day key has
    /// something to shift (P-2 — a door that can never act is not drawn).
    nonisolated static func doorShows(entryDate: String?) -> Bool {
        entryDate.map(JournalDay.isValid) ?? false
    }

    /// **The act**: one day earlier, then the receipt naming the new date.
    /// The op reads the STORED day in its own transaction, so a door rendered
    /// a moment ago cannot shift from a stale one; a note found undated (a
    /// race past the door) speaks the registry's note and writes nothing.
    static func shiftEarlier(postID: String, session: AppSession) async {
        do {
            let shifted = try await session.runner.run { ops in
                try ops.shiftEntryDate(postID, byDays: -1)
            }
            guard let shifted else {
                session.status.refuse(
                    CapabilityRegistry.capability(.shiftEntryDateEarlier).unavailableNote)
                return
            }
            session.status.receipt(EntryDateShiftCopy.receipt(shifted, now: session.now))
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
        }
    }
}
