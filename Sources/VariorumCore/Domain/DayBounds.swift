import Foundation

/// **ONE LOCAL CALENDAR DAY, AS THE STORE SEES IT** (18h batch 2, the
/// 2026-09-12 use-report round — her ledger row 11, ruling R-Q8).
///
/// Her words: *"how difficult it would be to implement being able to search
/// for any note edited on a particular day."* A day is something she picks
/// in HER calendar and HER timezone; the store's stamps (`created_at`,
/// `last_touched_at`, `commit_point.created_at`) are canonical UTC ISO-8601
/// text, fixed-width, so their lexicographic order IS their chronological
/// order. This type is the join between the two: the half-open UTC window
/// `[start, end)` that a local day covers, as the same ISO text the columns
/// hold — so the query is a plain TEXT range comparison and nothing in SQL
/// has to know what a timezone is.
///
/// ── WHY HALF-OPEN, AND WHY NOT "start + 86,400" ──────────────────────────
///
/// A local day is not 24 hours. It is 23 on a spring-forward day and 25 on a
/// fall-back one, and in a zone that shifted at midnight (Brazil, until
/// 2019) the day's first instant is 01:00, because 00:00 never happened.
/// Both ends are therefore derived from the CALENDAR (`startOfDay` of this
/// day's noon, and of the next day's noon), never by arithmetic on seconds —
/// which is the whole reason this is a pinned pure rule and not two lines at
/// a call site. Half-open `[start, end)` is what makes the two ends compose:
/// consecutive days tile the timeline with no gap and no double-count,
/// whatever their lengths.
///
/// ── THE NOON ANCHOR ──────────────────────────────────────────────────────
///
/// Both ends are found by taking NOON of a day and asking the calendar for
/// that day's first instant. Noon exists on every day in every zone; midnight
/// does not (see above), and `date(from:)` handed a nonexistent midnight
/// answers with a neighbouring day. `JournalDay.date(from:)` owns that
/// anchor — it is the same rule `TimeStampFace` reads a stored day key with.
///
/// Every entry point takes its `calendar` (which carries the timezone), so a
/// pin holds the rule rather than the machine.
public struct DayBounds: Equatable, Sendable {
    /// The local calendar day asked for, canonical "yyyy-MM-dd".
    public let day: String
    /// INCLUSIVE lower bound — canonical UTC ISO-8601 text, directly
    /// comparable against `created_at` / `last_touched_at`.
    public let start: String
    /// EXCLUSIVE upper bound — the next day's first instant.
    public let end: String

    /// nil when the key is not a real calendar day (`JournalDay.isValid`'s
    /// own rule) — a face draws nothing rather than filtering by a guess.
    public init?(day: String, calendar: Calendar = .current) {
        guard let noon = JournalDay.date(from: day, calendar: calendar),
              let nextNoon = calendar.date(byAdding: .day, value: 1, to: noon)
        else { return nil }
        self.day = day
        start = DateFormatter.variorumISO8601.string(from: calendar.startOfDay(for: noon))
        end = DateFormatter.variorumISO8601.string(from: calendar.startOfDay(for: nextNoon))
    }

    /// The day a given instant falls in — the door a "today" filter uses.
    public init(containing date: Date, calendar: Calendar = .current) {
        // `dayString` and `date(from:)` are inverses through the noon
        // anchor, so this cannot fail; the force-unwrap is the type system
        // asking for a proof the two functions already have (and the pin
        // `everyDayOfAYearRoundTripsThroughItsOwnKey` is that proof).
        self.init(day: JournalDay.dayString(from: date, calendar: calendar), calendar: calendar)!
    }
}
