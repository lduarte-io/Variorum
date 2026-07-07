import Foundation

/// The journal's calendar-day key (Phase 8; AppSpec §14, author 2026-07-07):
/// `entry_date` is the USER'S stated day — "yyyy-MM-dd" in her calendar and
/// timezone — defaulting to the local date at creation and user-settable to
/// any date, past or future. It is also the join key the Fragments bridge
/// (Phase 9b) rides: both apps agree the user's stated day IS the key.
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
}
