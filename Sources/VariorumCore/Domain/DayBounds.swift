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
    ///
    /// The default is `JournalDay.storeCalendar` — Gregorian in the device's
    /// zone — and not `Calendar.current` (the ladder's R2-8): a type whose
    /// own doc explains why the system calendar is unsafe for a day KEY
    /// should not hand it out as the default. Both production callers name
    /// their calendar anyway; this is the safe answer for the next one.
    public init?(day: String, calendar: Calendar = JournalDay.storeCalendar) {
        guard let noon = JournalDay.date(from: day, calendar: calendar),
              let nextNoon = calendar.date(byAdding: .day, value: 1, to: noon)
        else { return nil }
        self.day = day
        start = DateFormatter.variorumISO8601.string(from: calendar.startOfDay(for: noon))
        end = DateFormatter.variorumISO8601.string(from: calendar.startOfDay(for: nextNoon))
    }

    /// **A RUN of local days, first through last INCLUSIVE** (13o U2 — the
    /// Library's `when ▾` door grows its range, R-13o-13): `[first's start,
    /// last's end)`, each end the calendar's own (the same noon-anchored rule
    /// as one day, so a range across a DST change tiles exactly). `day` names
    /// the FIRST day. nil when either key is not a real day or the two are
    /// out of order; `first == last` is exactly `init?(day:)`.
    public init?(
        firstDay: String, lastDay: String, calendar: Calendar = JournalDay.storeCalendar
    ) {
        guard let first = DayBounds(day: firstDay, calendar: calendar),
              let last = DayBounds(day: lastDay, calendar: calendar),
              first.start < last.end
        else { return nil }
        day = firstDay
        start = first.start
        end = last.end
    }

    // **There is deliberately no `init(containing: Date)`** (the ladder's
    // R1-8). One shipped briefly, force-unwrapping its own failable sibling
    // on the grounds that `dayString` and `date(from:)` are inverses — true
    // only in a GREGORIAN calendar: `dayString` emits the CURRENT calendar's
    // components while `JournalDay.isValid` validates proleptic Gregorian, so
    // under a Hebrew `Calendar.current` a leap year's month 13 yields
    // "5786-13-05", `isValid` refuses it, and the `!` traps. It had no
    // production caller — a public force-unwrap kept alive by its own test is
    // the thing a later batch adopts innocently. Callers name the day they
    // mean (`JournalDay.dayString`) and go through `init?(day:)`.
}
