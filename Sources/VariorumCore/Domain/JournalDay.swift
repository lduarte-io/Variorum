import Foundation

/// The journal's calendar-day key (Phase 8; AppSpec §14, author 2026-07-07):
/// `entry_date` is the USER'S stated day — "yyyy-MM-dd" in her calendar and
/// timezone — defaulting to the local date at creation and user-settable to
/// any date, past or future. It was also the join key the Fragments bridge
/// (Phase 9b; retired 2026-09-04) rode: both apps agreed the user's stated
/// day IS the key.
///
/// Pure functions (CLAUDE.md: domain rules are pure, tested independently).
/// Wall-clock/timezone inputs are explicit parameters; `@Dependency(\.date)`
/// stays the caller's job.
public enum JournalDay {
    /// The canonical day string for a moment in a calendar: zero-padded
    /// "yyyy-MM-dd". Lexicographic order == chronological order, which is
    /// what `entry_date`'s TEXT sorting rides.
    public static func dayString(from date: Date, calendar: Calendar = .current) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year!, parts.month!, parts.day!)
    }

    /// Strict shape check for user-entered or bridged day keys:
    /// exactly "yyyy-MM-dd", digits in place, a real calendar date
    /// (proleptic Gregorian; "2026-02-30" is invalid).
    public static func isValid(_ string: String) -> Bool {
        let parts = string.split(separator: "-", omittingEmptySubsequences: false)
        guard parts.count == 3,
              parts[0].count == 4, parts[1].count == 2, parts[2].count == 2,
              parts.allSatisfy({ $0.allSatisfy(\.isASCII) && $0.allSatisfy(\.isNumber) }),
              let year = Int(parts[0]), let month = Int(parts[1]), let day = Int(parts[2])
        else { return false }
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return components.isValidDate(in: calendar)
    }

    /// **A day key back to an instant, anchored at NOON** in the given
    /// calendar — the inverse of `dayString(from:)` for every purpose this
    /// app has, which is always "which calendar day is this" and never "what
    /// time was it".
    ///
    /// Noon, not midnight, deliberately: midnight is the one instant a DST
    /// transition can DELETE (Brazil used to spring forward at 00:00, so
    /// `2018-11-04T00:00` simply did not exist in São Paulo, and a formatter
    /// asked for it answers the day before or after). Noon exists on every
    /// day in every zone, so `dayString(from: date(from: d)!) == d` always.
    ///
    /// nil for anything that is not a real day (`isValid`'s own rule).
    ///
    /// *(18h batch 2: this was written twice — `TimeStampFace.parse` carried
    /// its own copy of the noon rule. Two copies of one rule are the drift
    /// class (MobileSoul §3), so it lives here once, beside the function it
    /// inverts, and both callers read it.)*
    /// *(The default is `storeCalendar`, not `.current` — the 18h ladder's
    /// R3-5, the same correction R2-8 made to this function's own inverse,
    /// `DayBounds.init?(day:calendar:)`. A type whose doc explains why the
    /// system calendar is unsafe for a day KEY must not hand it out as the
    /// default: under a Hebrew `Calendar.current` a valid Gregorian key
    /// passes `isValid` — which is proleptic Gregorian — and then builds
    /// year/month/day as a HEBREW date, returning a silently wrong instant
    /// that is non-nil, so no caller can notice. Every production caller
    /// already passes a calendar explicitly; this is the safe answer for the
    /// next one.)*
    public static func date(
        from day: String, calendar: Calendar = JournalDay.storeCalendar
    ) -> Date? {
        guard isValid(day) else { return nil }
        let parts = day.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        var components = DateComponents()
        components.year = parts[0]
        components.month = parts[1]
        components.day = parts[2]
        components.hour = 12
        return calendar.date(from: components)
    }
}

extension JournalDay {
    /// **THE CALENDAR THE STORE'S DAYS ARE WRITTEN IN — Gregorian, in HER
    /// time zone** (the 18h ladder, 2026-09-13: "one calendar per letter").
    ///
    /// The store's day grammar is Gregorian ISO by this type's own
    /// definition: `isValid` validates against proleptic Gregorian, and
    /// `entry_date` is that shape everywhere. But `Calendar.current` is
    /// whatever macOS Language & Region says, and it can be Hebrew, Islamic
    /// or Japanese — in which case `dayString(from:)` emits the CURRENT
    /// calendar's own components (`"5786-13-05"`), `isValid` refuses them,
    /// and any door built on the pair silently stops working. The 18h day
    /// filter met exactly that (the ladder's R1-8).
    ///
    /// So the surfaces that speak the store's days name the calendar they
    /// mean, and this is it. **The TIME ZONE stays hers** — that is what
    /// makes a day boundary her day's, and it is the half `Calendar.current`
    /// gets right.
    ///
    /// **What it is NOT:** a change to `dayString(from:calendar:)`'s own
    /// default, which stays `.current`. That parameter mints `entry_date`
    /// values all over Phase 8's operations, and re-pointing it is a wider
    /// change than any one letter should make from the side.
    ///
    /// Read by: `TimeStampFace`'s public entry points (so every stamp in the
    /// Library and the masthead words itself here), 18d's note-box facts line
    /// through them, and the Library's day filter (`LibraryDayFace.calendar`,
    /// which forwards). Pinned:
    /// `TimeStampFaceTests.theStampsSpeakTheStoresOwnCalendarNotTheSystems`
    /// and `LibraryDayFilterTests.theFiltersCalendarIsGregorianAndKeepsHerTimeZone`.
    public static var storeCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = Calendar.current.timeZone
        return calendar
    }
}
