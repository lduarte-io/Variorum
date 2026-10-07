import Foundation

/// A calendar day as a query NAMES it — maybe without a year ("september 14"
/// is every September 14th she ever wrote on). Month 1–12, day 1–31, already
/// validated against the month (Feb 29 is legal year-less; with a year, only
/// in a leap year).
public struct SearchDayPattern: Equatable, Sendable {
    public let year: Int?
    public let month: Int
    public let day: Int

    public init?(year: Int?, month: Int, day: Int) {
        guard (1...12).contains(month), day >= 1,
              day <= SearchDateParse.daysIn(month: month, year: year)
        else { return nil }
        self.year = year
        self.month = month
        self.day = day
    }

    /// The canonical day key ("yyyy-MM-dd" — `JournalDay`'s letter) for one
    /// year: the year-specific pattern's own year, or the given one.
    public func dayKey(inYear year: Int) -> String? {
        let y = self.year ?? year
        guard self.year == nil || self.year == year,
              day <= SearchDateParse.daysIn(month: month, year: y)
        else { return nil }
        return String(format: "%04d-%02d-%02d", y, month, day)
    }

    /// Does a stored day key ("yyyy-MM-dd") wear THIS day?
    public func matches(dayKey: String) -> Bool {
        let parts = dayKey.split(separator: "-")
        guard parts.count == 3, let y = Int(parts[0]), let m = Int(parts[1]), let d = Int(parts[2])
        else { return false }
        return m == month && d == day && (year == nil || year == y)
    }
}

/// **THE DATE-PARSE PREDICATE** (R-13o-6 — the display-name half: a nameless
/// note wears its day everywhere — `DisplayTitle.note` — so typing the day
/// should find it). A pure reader of DAY-SHAPED query text:
///
/// - ISO: `2026-09-14`, `2026-9-4`
/// - month name + day (+ year): `september 14`, `Sep 14`, `sept. 14th`,
///   `September 14, 2026`, `sep 14 2026`
/// - day + month name (+ year): `14 september`, `14th of sep 2026`
/// - numeric `a/b` (+ `/year`): `9/14`, `14/9`, `9/14/26` — and `14.9.2026`
///   where the locale itself writes days with dots (so "1.5" in en_US stays a
///   number); the LOCALE decides the order (month-first for en_US, day-first
///   for en_GB/de/fr …: "locale-honest"); a reading invalid in the locale's order
///   but valid the other way round is accepted (PROVISIONAL — discovery is
///   forgiving: autocorrect and habit both type the other order).
///
/// Month names are matched case- and diacritic-insensitively against English
/// AND the locale's own month symbols (full, short, stand-alone), a trailing
/// "." tolerated — so `févr. 3` reads in fr_FR. Two-digit years are 20yy.
///
/// The WHOLE text must be the day (surrounding whitespace aside): "trip to
/// sep 14" is words, not a day (PROVISIONAL — the narrowest honest reading;
/// a day inside a sentence of words is the power grammar's).
public enum SearchDateParse {
    public static func parse(
        _ text: String, locale: Locale = .current, calendar: Calendar = JournalDay.storeCalendar
    ) -> SearchDayPattern? {
        let folded = fold(text)
        guard !folded.isEmpty else { return nil }
        if let iso = parseISO(folded) { return iso }
        if let named = parseNamed(folded, locale: locale) { return named }
        return parseNumeric(folded, locale: locale)
    }

    /// Days in a month; a year-less February answers 29 (the pattern may
    /// name a leap day; matching then finds only the leap years' notes).
    public static func daysIn(month: Int, year: Int?) -> Int {
        switch month {
        case 1, 3, 5, 7, 8, 10, 12: return 31
        case 4, 6, 9, 11: return 30
        case 2:
            guard let year else { return 29 }
            let leap = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0
            return leap ? 29 : 28
        default: return 0
        }
    }

    // MARK: - Forms

    private static func parseISO(_ s: String) -> SearchDayPattern? {
        let parts = s.split(separator: "-", omittingEmptySubsequences: false)
        guard parts.count == 3, parts[0].count == 4,
              let y = Int(parts[0]), let m = Int(parts[1]), let d = Int(parts[2]),
              (1...2).contains(parts[1].count), (1...2).contains(parts[2].count)
        else { return nil }
        return SearchDayPattern(year: y, month: m, day: d)
    }

    /// `<month> <day>[,] [<year>]` or `<day> [of] <month>[,] [<year>]`.
    private static func parseNamed(_ s: String, locale: Locale) -> SearchDayPattern? {
        var words = s.replacingOccurrences(of: ",", with: " ")
            .split(whereSeparator: { $0 == " " }).map(String.init)
        words.removeAll { $0 == "of" }
        guard (2...3).contains(words.count) else { return nil }
        let months = monthTable(locale: locale)
        var month: Int?
        var day: Int?
        if let m = months[stripDot(words[0])], let d = dayNumber(words[1]) {
            (month, day) = (m, d)
        } else if let d = dayNumber(words[0]), let m = months[stripDot(words[1])] {
            (month, day) = (m, d)
        }
        guard let month, let day else { return nil }
        var year: Int?
        if words.count == 3 {
            guard let y = yearNumber(words[2]) else { return nil }
            year = y
        }
        return SearchDayPattern(year: year, month: month, day: day)
    }

    /// `a/b[/y]` everywhere; `a.b[.y][.]` only where the locale itself writes
    /// days with dots (de, fr-CH … — so "1.5" in en_US stays a number);
    /// `a-b` is NOT read (ISO's separator — a two-part dash is a word like
    /// "9-5").
    private static func parseNumeric(_ s: String, locale: Locale) -> SearchDayPattern? {
        let separator: Character
        if s.contains("/") {
            separator = "/"
        } else if s.contains("."), localeWritesDottedDays(locale) {
            separator = "."
        } else {
            return nil
        }
        var body = Substring(s)
        if separator == ".", body.hasSuffix(".") { body = body.dropLast() } // German "14.9."
        let parts = body.split(separator: separator, omittingEmptySubsequences: false)
        guard (2...3).contains(parts.count),
              parts.allSatisfy({ !$0.isEmpty && $0.allSatisfy(\.isASCII) && $0.allSatisfy(\.isNumber) }),
              parts[0].count <= 2, parts[1].count <= 2,
              let a = Int(parts[0]), let b = Int(parts[1])
        else { return nil }
        var year: Int?
        if parts.count == 3 {
            guard let y = yearNumber(String(parts[2])) else { return nil }
            year = y
        }
        let monthFirst = localeIsMonthFirst(locale)
        let (firstMonth, firstDay) = monthFirst ? (a, b) : (b, a)
        if let pattern = SearchDayPattern(year: year, month: firstMonth, day: firstDay) {
            return pattern
        }
        // The locale's order is impossible ("14/9" under en_US): the only
        // valid reading wins (PROVISIONAL, discovery is forgiving).
        return SearchDayPattern(year: year, month: firstDay, day: firstMonth)
    }

    // MARK: - Pieces

    /// Lowercased, diacritic-folded, whitespace-collapsed.
    static func fold(_ s: String) -> String {
        s.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }

    private static func stripDot(_ s: String) -> String {
        s.hasSuffix(".") ? String(s.dropLast()) : s
    }

    /// "14", "14th", "1st", "2nd", "3rd" → the number (1–31 checked later).
    private static func dayNumber(_ s: String) -> Int? {
        var digits = Substring(s)
        for suffix in ["st", "nd", "rd", "th"] where digits.hasSuffix(suffix) {
            digits = digits.dropLast(suffix.count)
            break
        }
        guard (1...2).contains(digits.count), digits.allSatisfy({ $0.isASCII && $0.isNumber }) else { return nil }
        return Int(digits)
    }

    /// "2026" or "26" (→ 2026).
    private static func yearNumber(_ s: String) -> Int? {
        guard s.allSatisfy({ $0.isASCII && $0.isNumber }) else { return nil }
        switch s.count {
        case 4: return Int(s)
        case 2: return Int(s).map { 2000 + $0 }
        default: return nil
        }
    }

    /// Month names → 1…12: English full + short (+ "sept"), and the locale's
    /// own full / short / stand-alone symbols, folded and dot-stripped.
    static func monthTable(locale: Locale) -> [String: Int] {
        var table: [String: Int] = [:]
        let english = ["january", "february", "march", "april", "may", "june", "july",
                       "august", "september", "october", "november", "december"]
        for (index, name) in english.enumerated() {
            table[name] = index + 1
            table[String(name.prefix(3))] = index + 1
        }
        table["sept"] = 9
        let formatter = DateFormatter()
        formatter.locale = locale
        for symbols in [formatter.monthSymbols, formatter.shortMonthSymbols,
                        formatter.standaloneMonthSymbols, formatter.shortStandaloneMonthSymbols] {
            for (index, name) in (symbols ?? []).enumerated() where index < 12 {
                let key = stripDot(fold(name))
                if !key.isEmpty, table[key] == nil { table[key] = index + 1 }
            }
        }
        return table
    }

    /// Does this locale write a numeric month-day as month first? Read from
    /// the locale's own "Md" template ("M/d" en_US · "d/M" en_GB · "d.M." de).
    static func localeIsMonthFirst(_ locale: Locale) -> Bool {
        let format = DateFormatter.dateFormat(fromTemplate: "Md", options: 0, locale: locale) ?? "M/d"
        guard let m = format.firstIndex(of: "M"), let d = format.firstIndex(of: "d") else { return true }
        return m < d
    }

    /// Does this locale's own numeric month-day use dots ("d.M." in de)?
    static func localeWritesDottedDays(_ locale: Locale) -> Bool {
        (DateFormatter.dateFormat(fromTemplate: "Md", options: 0, locale: locale) ?? "").contains(".")
    }
}
