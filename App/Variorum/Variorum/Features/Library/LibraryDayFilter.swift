//
//  LibraryDayFilter.swift
//  Variorum (Mac)
//
//  **18h batch 2 — THE DAY SEARCH** (the 2026-09-12 use-report round, her
//  ledger row 11; ruling R-Q8: *"Build now, small filter in the Library"*).
//  Her words: *"how difficult it would be to implement being able to search
//  for any note edited on a particular day."*
//
//  Two things of one theme live here, and deliberately NOT inside
//  `LibraryCatalogView.swift` (1,300 lines already — P-9 / review focus
//  F-0), nor inside `LibraryTimeFace.swift`, which is batch 1's sort-and-
//  stamp file and has its own job:
//
//  1. `LibraryDayFace` — the WORDS: the door's label, and the honest empty
//     answer, said in ONE place so the List mode and the Notes mode can
//     never word the same silence differently.
//  2. `LibraryDayRange` — the armed run of days, and the empty answer's
//     face. The door itself — **when ▾** since 13o U2 (her R-13o-13, *"I
//     like 'when' for the day door"*) — lives in `LibraryWhenDoor.swift`
//     since VX-87 rebuilt it to her direction 1 (R-VX83-2: one popover, a
//     month grid, the armed sentence). (It was `LibraryDayField`, the
//     `edited on…` field with its ✕, from 18h batch 2 to 13o; a menu that
//     opened a date-field popover from 13o to VX-87.)
//
//  The day itself is a canonical `yyyy-MM-dd` key in HER calendar; the
//  conversion to the UTC window the stored stamps compare against is core's
//  one pure rule (`DayBounds`), never done here.
//

import Foundation
import SwiftUI
import VariorumCore

// MARK: - The words

/// What the day filter SAYS — including the one thing it must say out loud.
///
/// **The caveat is the product's honesty, not a footnote.** The store keeps
/// ONE edit stamp per note (AppSpec §10 — *coarse, not forensic*; a per-day
/// edit log is the forensic tracking CoreDescription rules out by
/// definition), so a note written on Monday and again on Tuesday answers for
/// Tuesday by its stamp. What rescues Monday is a savepoint: since 13j one
/// lands per changed take when she leaves a note, with the idle timer behind
/// it. The search unions the two — and where the union still finds nothing,
/// the face says exactly why rather than implying the day was empty.
nonisolated enum LibraryDayFace {
    /// **THE FILTER'S CALENDAR — one construction site** (the ladder's
    /// R1-8): GREGORIAN, carrying HER time zone.
    ///
    /// Not `Calendar.current` whole, because the two halves of a day KEY
    /// disagree under a non-Gregorian one: `JournalDay.dayString` emits the
    /// current calendar's components while `JournalDay.isValid` validates
    /// proleptic Gregorian, so under a Hebrew calendar (macOS Language &
    /// Region offers it) the field would produce `"5786-13-05"`,
    /// `setEditedOn` would refuse it, and the filter would silently never
    /// arm. The store's day grammar IS Gregorian ISO by `JournalDay`'s own
    /// definition — `entry_date` everywhere — so the filter names the
    /// calendar it means. The TIME ZONE stays hers: that is what makes the
    /// day boundaries her day's. Pinned:
    /// `LibraryDayFilterTests.theFiltersCalendarIsGregorianAndKeepsHerTimeZone`.
    /// **A forwarder since the 18h ladder's calendar ruling** (2026-09-13,
    /// "one calendar per letter"): the constructor moved to core `Domain` as
    /// `JournalDay.storeCalendar`, beside the day grammar it belongs to, so
    /// the row STAMPS could read the same one — until then the filter spoke
    /// Gregorian-in-her-zone while every stamp beside it spoke
    /// `Calendar.current`, and a non-Gregorian user would have read two
    /// calendars on one screen. The name stays so this file's own pin and
    /// call sites read unchanged.
    static var calendar: Calendar { JournalDay.storeCalendar }

    /// **The door: `when ▾`** (13o U2 — her R-13o-13, *"I like 'when' for
    /// the day door"*, the mockup's wording 2). It was *edited on…* from 13i-d
    /// U6 (c) — her §21 note, "'on day…' wants clearer wording" — to 13o,
    /// where the door grew its RANGE.
    static let closedLabel = "when"

    /// **The popover's mode row and its clearing word** (VX-87 — her
    /// direction 1, R-VX83-2: *on a day · between days*, with *any day* at the
    /// card's foot). R-13o-13's menu read "on a day… · between days…"; the
    /// ellipses meant "this opens something more", and they left with the
    /// menu — on a mode row the words open nothing (the mockup draws them
    /// bare).
    static let onADay = "on a day"
    static let betweenDays = "between days"
    static let anyDay = "any day"

    /// **What VoiceOver says** (the §P1 ruling's condition 1 — written by
    /// hand at this landing): the month steps, and a day's standing after its
    /// full date (`LibraryWhenGrid.spoken`).
    static let previousMonth = "Previous month"
    static let nextMonth = "Next month"
    static let spokenChosenDay = "chosen day"
    static let spokenRunStart = "first day of the run"
    static let spokenRunEnd = "last day of the run"
    static let spokenInRun = "in the run"
    static let spokenToday = "today"

    /// One armed day: *edited on Sep 9* — the same day words every stamp in
    /// the Library uses (`TimeStampFace.day`, core `Domain`). The band's
    /// chip says it.
    static func openLabel(
        day: String, now: Date, calendar: Calendar = LibraryDayFace.calendar,
        locale: Locale = .current
    ) -> String {
        "edited on \(dayWords(day: day, now: now, calendar: calendar, locale: locale))"
    }

    /// **The armed range's chip** (13o U2, R-13o-13 — the band carries the
    /// armed state): one day reads `openLabel`'s *edited on Sep 9*; a run of
    /// days *edited Sep 1 – Sep 14*.
    static func chipLabel(
        _ range: LibraryDayRange, now: Date, calendar: Calendar = LibraryDayFace.calendar,
        locale: Locale = .current
    ) -> String {
        range.isOneDay
            ? openLabel(day: range.first, now: now, calendar: calendar, locale: locale)
            : "edited \(rangeWords(range, now: now, calendar: calendar, locale: locale))"
    }

    /// *Sep 1 – Sep 14* — each end in the one brain's day words.
    static func rangeWords(
        _ range: LibraryDayRange, now: Date, calendar: Calendar = LibraryDayFace.calendar,
        locale: Locale = .current
    ) -> String {
        dayWords(day: range.first, now: now, calendar: calendar, locale: locale) + " \u{2013} "
            + dayWords(day: range.last, now: now, calendar: calendar, locale: locale)
    }

    /// A day key in her own reading — *Sep 9*, or *Sep 9, 2025* when it is
    /// not from this year. Falls back to the raw key if a caller ever hands
    /// it something that is not a day (a face draws what it has, never a
    /// crash).
    static func dayWords(
        day: String, now: Date, calendar: Calendar = LibraryDayFace.calendar,
        locale: Locale = .current
    ) -> String {
        guard let date = JournalDay.date(from: day, calendar: calendar) else { return day }
        return TimeStampFace.day(date, now: now, calendar: calendar, locale: locale)
    }

    // MARK: VX-87 — the popover's words (direction 1, R-VX83-2)

    /// **The armed SENTENCE** — the popover's confirmation, at its foot (the
    /// mockup's direction 1, verbatim in shape): *Showing notes edited **on
    /// Oct 6**.* · *Showing notes edited **Oct 1 – Oct 6**.* With nothing armed
    /// it says the clearing word's own state the same way — *…edited **on any
    /// day**.* (PROVISIONAL P-VX83-B1: the mockup draws only armed states).
    /// The emphasized part is built from the same day words the band's chip
    /// uses (`dayWords` / `rangeWords`), so the sentence inside the popover and
    /// the chip outside it cannot disagree.
    struct Sentence: Equatable {
        let lead: String
        /// The armed words — drawn emphasized.
        let emphasis: String
        let tail: String
        var plain: String { lead + emphasis + tail }
    }

    static func sentence(
        range: LibraryDayRange?, now: Date, calendar: Calendar = LibraryDayFace.calendar,
        locale: Locale = .current
    ) -> Sentence {
        let armed: String
        if let range {
            armed = range.isOneDay
                ? "on " + dayWords(day: range.first, now: now, calendar: calendar, locale: locale)
                : rangeWords(range, now: now, calendar: calendar, locale: locale)
        } else {
            armed = "on " + anyDay
        }
        return Sentence(lead: "Showing notes edited ", emphasis: armed, tail: ".")
    }

    /// The foot's quiet hint at rest (the mockup's "esc closes") — and, while
    /// a run waits for its last day, what the next press does (PROVISIONAL
    /// P-VX83-B1's sibling: the mockup's reading, "click the first day, click
    /// the last", said at the moment it matters).
    static let escHint = "esc closes"
    static let runEndHint = "then the last day"

    /// The door's own two hovers (the 18h ladder's R3-8 — they were literals
    /// in the view's body, two rows from the sentences this type already
    /// owns; F-0's "no string-as-rule in a view", applied to the copy beside
    /// the rule).
    static let closedDoorHelp = "Show only the notes edited on a day, or between two days"
    static let clearDoorHelp = "Clear the day \u{2014} list every note again"

    /// The caveat, in one sentence — on the door's hover whenever the filter
    /// is armed, and under the empty answer when it finds nothing.
    static let caveat =
        "A note keeps one edit stamp, so a note edited on two days answers for the later one "
        + "\u{2014} earlier days show up where a commit landed."

    /// What an empty answer says: the fact, then the reason.
    struct EmptyAnswer: Equatable {
        let headline: String
        let caveat: String
    }

    /// **The headline names every narrowing, not just the day** (the ladder's
    /// R1-3(a)). The unqualified sentence asserts a fact about the DAY, and
    /// the search field sits two controls from the day door — so with a query
    /// typed beside it, *"No note's last edit or savepoint falls on Sep 9"*
    /// is confidently false whenever notes WERE edited that day and merely
    /// did not match the words. The caveat rides either way: it is still the
    /// reason a note she remembers writing that day can be missing.
    static func emptyAnswer(
        day: String, query: String = "", now: Date,
        calendar: Calendar = LibraryDayFace.calendar, locale: Locale = .current
    ) -> EmptyAnswer {
        let words = dayWords(day: day, now: now, calendar: calendar, locale: locale)
        let typed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return EmptyAnswer(
            headline: typed.isEmpty
                ? "No note's last edit or commit falls on \(words)."
                : "No note matching \u{201C}\(typed)\u{201D} was edited on \(words).",
            caveat: caveat)
    }

    /// The empty answer for an armed RANGE (13o U2): one day is exactly
    /// `emptyAnswer(day:)`; a run of days says *between Sep 1 and Sep 14*.
    static func emptyAnswer(
        range: LibraryDayRange, query: String = "", now: Date,
        calendar: Calendar = LibraryDayFace.calendar, locale: Locale = .current
    ) -> EmptyAnswer {
        guard !range.isOneDay else {
            return emptyAnswer(day: range.first, query: query, now: now, calendar: calendar, locale: locale)
        }
        let from = dayWords(day: range.first, now: now, calendar: calendar, locale: locale)
        let to = dayWords(day: range.last, now: now, calendar: calendar, locale: locale)
        let typed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return EmptyAnswer(
            headline: typed.isEmpty
                ? "No note's last edit or commit falls between \(from) and \(to)."
                : "No note matching \u{201C}\(typed)\u{201D} was edited between \(from) and \(to).",
            caveat: caveat)
    }
}

// MARK: - The range

/// **The armed `when` range** (13o U2, R-13o-13): the first and last local
/// day it covers, INCLUSIVE, each a canonical `yyyy-MM-dd` key in her
/// calendar. One day is `first == last`. Core's `DayBounds(firstDay:lastDay:)`
/// turns it into the store's UTC window — the rule `Queries.editedOnSQL`
/// compares, unchanged (§21 item 3's range rides the shipped bounds).
nonisolated struct LibraryDayRange: Equatable, Sendable {
    let first: String
    let last: String

    var isOneDay: Bool { first == last }

    /// nil unless both keys are real days; two days given out of order are
    /// put in order (a range is a set of days, not a direction).
    init?(first: String, last: String) {
        guard JournalDay.isValid(first), JournalDay.isValid(last) else { return nil }
        // Canonical keys order lexicographically as they do in time.
        self.first = min(first, last)
        self.last = max(first, last)
    }

    init?(day: String) {
        self.init(first: day, last: day)
    }
}

/// The empty answer, drawn the same way wherever the listing is empty while
/// a day is armed (the List mode's section and the Notes mode's column).
struct LibraryDayEmptyAnswer: View {
    /// **The caveat's measure** (the ladder's R1-15 — a number in a view body
    /// is a rule with no name). Two sentences of explanation stay readable at
    /// roughly 60–70 characters of this chrome size; wider and the eye loses
    /// the line, which is the opposite of what an explanation is for. The
    /// empty answer is the only prose the Library speaks, so it is the only
    /// place that needs one.
    static let measure: CGFloat = 520

    let tokens: VoiceTokens
    /// The armed range (one day or a run of days — 13o U2).
    let range: LibraryDayRange
    /// What else is narrowing the listing, so the headline can name it
    /// (R1-3(a)) — empty when the day is the only narrowing.
    var query: String = ""
    var now: Date = Date()
    var calendar: Calendar = LibraryDayFace.calendar

    var body: some View {
        let answer = LibraryDayFace.emptyAnswer(
            range: range, query: query, now: now, calendar: calendar)
        VStack(alignment: .leading, spacing: 4) {
            Text(tokens.chromeLabel(answer.headline))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            Text(tokens.chromeLabel(answer.caveat))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                // Chrome law (P-8, the wedged-window class): a wrapping
                // chrome text states its own limit.
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: Self.measure, alignment: .leading)
    }
}
