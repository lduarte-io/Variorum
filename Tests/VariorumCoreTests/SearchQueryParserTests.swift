import Foundation
import Testing

@testable import VariorumCore

/// 13o U1 P2 — the v1 grammar (`SearchQueryParser`) and the date-parse
/// predicate (`SearchDateParse`, R-13o-6's display-name half). Pure rules,
/// exhaustive little tests.
@Suite("13o — the v1 search grammar")
struct SearchQueryParserTests {
    private let us = Locale(identifier: "en_US")

    private func parse(_ s: String, typeAhead: Bool = true) -> SearchQuery {
        SearchQueryParser.parse(s, typeAhead: typeAhead, locale: us)
    }

    @Test func emptyAndWhitespaceAreTheEmptyQuery() {
        #expect(parse("").isEmpty)
        #expect(parse("   \n\t ").isEmpty)
        #expect(parse("").visibility == .living)
    }

    @Test func wordsAreAnImplicitAndAndTheTailIsAPrefix() {
        #expect(parse("dream journal").text == .all([.word("dream"), .prefix("journal")]))
        #expect(parse("dream journal ").text == .all([.word("dream"), .word("journal")]),
                "a trailing space finishes the word")
        #expect(parse("dream journal", typeAhead: false).text == .all([.word("dream"), .word("journal")]))
    }

    @Test func aOneCharacterTailIsNeverAPrefix() {
        #expect(parse("a").text == .word("a"))
        #expect(parse("dream a").text == .all([.word("dream"), .word("a")]))
        #expect(parse("tr").text == .prefix("tr"))
    }

    @Test func phrasesKeepTheirWordsTogether() {
        #expect(parse("\"the old house\"").text == .phrase("the old house"))
        #expect(parse("rain \"the  old\thouse\" roof").text
                == .all([.word("rain"), .phrase("the old house"), .prefix("roof")]))
        // Curly quotes (autocorrect) are quotes too.
        #expect(parse("\u{201C}old house\u{201D}").text == .phrase("old house"))
        // Unterminated: runs to the end, and is never a prefix.
        #expect(parse("\"old hou").text == .phrase("old hou"))
        // An empty phrase vanishes.
        #expect(parse("\"\" rain ").text == .word("rain"))
    }

    @Test func aWordRightAfterAPhraseIsStillTheTail() {
        #expect(parse("\"old house\" ro").text == .all([.phrase("old house"), .prefix("ro")]))
        #expect(parse("ro \"old house\"").text == .all([.word("ro"), .phrase("old house")]),
                "the tail is the LAST term, and a phrase ends it")
    }

    @Test func tagsAreFiltersNeverText() {
        let q = parse("#life/goals dream")
        #expect(q.filter == .tagPath("life/goals"))
        #expect(q.text == .prefix("dream"))
        let two = parse("#a #b/c/ ")
        #expect(two.filter == .all([.tagPath("a"), .tagPath("b/c")]), "a trailing slash is trimmed")
        #expect(two.text == nil)
        #expect(parse("# rain ").text == .all([.word("#"), .word("rain")]), "a lone # is a word")
        #expect(parse("#travel").text == nil && parse("#travel").filter == .tagPath("travel"),
                "a tag being typed is never a prefix word")
    }

    /// Ladder round 1, MINOR-2 (red-on-old): the type-ahead tail is the word
    /// STILL BEING TYPED — it must END the input. A `#tag` typed after the
    /// word (the empty-path `#/` included — the implementer's extension)
    /// means the word is finished; the old check read the TAG's last
    /// character and widened the finished word to a prefix.
    @Test func aTagTypedAfterAWordLeavesTheWordWhole() {
        #expect(parse("dream #lucid").text == .word("dream"),
                "the word does not end the input — it is not being typed")
        #expect(parse("dream #lucid").filter == .tagPath("lucid"))
        #expect(parse("dream #/").text == .word("dream"),
                "an empty-path tag (dropped by the tag branch) still ends the word")
        #expect(parse("#life dream").text == .prefix("dream"),
                "a word typed AFTER a tag is still the tail")
    }

    @Test func punctuationRidesTheWordForTheTokenizerToSplit() {
        // The index's own tokenizer splits "don't" — the parser never does.
        #expect(parse("don't stop ").text == .all([.word("don't"), .word("stop")]))
        #expect(parse("e-mail").text == .prefix("e-mail"))
    }

    @Test func aDayShapedQueryCarriesItsWornDay() {
        #expect(parse("september 14").wornDay == SearchDayPattern(year: nil, month: 9, day: 14))
        #expect(parse("september 14").text == .all([.word("september"), .prefix("14")]),
                "the words still search as words")
        #expect(parse("#journal sep 14 ").wornDay == SearchDayPattern(year: nil, month: 9, day: 14),
                "tags aside, the text IS a day")
        #expect(parse("\"sep 14\"").wornDay == SearchDayPattern(year: nil, month: 9, day: 14))
        #expect(parse("trip to sep 14").wornDay == nil, "a day inside a sentence is words")
        #expect(parse("rain").wornDay == nil)
    }

    @Test func visibilityRidesThrough() {
        #expect(SearchQueryParser.parse("x", visibility: .includingArchived).visibility == .includingArchived)
    }
}

@Suite("13o — the date-parse predicate")
struct SearchDateParseTests {
    private let us = Locale(identifier: "en_US")
    private let gb = Locale(identifier: "en_GB")
    private let de = Locale(identifier: "de_DE")
    private let fr = Locale(identifier: "fr_FR")

    private func day(_ s: String, _ locale: Locale? = nil) -> SearchDayPattern? {
        SearchDateParse.parse(s, locale: locale ?? us)
    }
    private func p(_ y: Int?, _ m: Int, _ d: Int) -> SearchDayPattern? {
        SearchDayPattern(year: y, month: m, day: d)
    }

    @Test func isoDays() {
        #expect(day("2026-09-14") == p(2026, 9, 14))
        #expect(day("2026-9-4") == p(2026, 9, 4))
        #expect(day("  2026-09-14 ") == p(2026, 9, 14))
        #expect(day("2026-13-01") == nil)
        #expect(day("2026-02-30") == nil)
        #expect(day("2024-02-29") == p(2024, 2, 29))
        #expect(day("2026-02-29") == nil, "not a leap year")
        #expect(day("26-09-14") == nil, "ISO wants a four-digit year")
        #expect(day("2026-09") == nil)
    }

    @Test func monthNameThenDay() {
        #expect(day("september 14") == p(nil, 9, 14))
        #expect(day("September 14") == p(nil, 9, 14))
        #expect(day("SEP 14") == p(nil, 9, 14))
        #expect(day("sept 14") == p(nil, 9, 14))
        #expect(day("sept. 14th") == p(nil, 9, 14))
        #expect(day("september 1st") == p(nil, 9, 1))
        #expect(day("may 2nd") == p(nil, 5, 2))
        #expect(day("march 3rd") == p(nil, 3, 3))
        #expect(day("September 14, 2026") == p(2026, 9, 14))
        #expect(day("sep 14 2026") == p(2026, 9, 14))
        #expect(day("sep 14 26") == p(2026, 9, 14), "two-digit years are 20yy")
        #expect(day("sep  14") == p(nil, 9, 14), "runs of whitespace collapse")
    }

    @Test func dayThenMonthName() {
        #expect(day("14 september") == p(nil, 9, 14))
        #expect(day("14th of sep 2026") == p(2026, 9, 14))
        #expect(day("1 jan") == p(nil, 1, 1))
    }

    @Test func impossibleOrPartialNamedDaysAreNotDays() {
        #expect(day("september 31") == nil)
        #expect(day("feb 30") == nil)
        #expect(day("feb 29") == p(nil, 2, 29), "a year-less leap day is a legal pattern")
        #expect(day("feb 29 2026") == nil)
        #expect(day("september") == nil)
        #expect(day("14") == nil)
        #expect(day("sep 14 2026 rain") == nil)
        #expect(day("sep 14 abc") == nil)
        #expect(day("sep 0") == nil)
        #expect(day("sep 123") == nil)
        #expect(day("septembre 14") == nil, "not English, not the en_US locale's")
    }

    @Test func theLocaleOwnMonthNamesRead() {
        #expect(day("14 septembre", fr) == p(nil, 9, 14))
        #expect(day("3 févr.", fr) == p(nil, 2, 3))
        #expect(day("3 fevr", fr) == p(nil, 2, 3), "diacritics fold")
        #expect(day("14. September", de) == nil, "a day with a trailing dot is not read (PROVISIONAL)")
        #expect(day("14 März", de) == p(nil, 3, 14))
        #expect(day("14 sep", fr) == p(nil, 9, 14), "English always reads")
    }

    @Test func numericDaysFollowTheLocale() {
        #expect(SearchDateParse.localeIsMonthFirst(us))
        #expect(!SearchDateParse.localeIsMonthFirst(gb))
        #expect(!SearchDateParse.localeIsMonthFirst(de))
        #expect(day("9/14") == p(nil, 9, 14))
        #expect(day("3/4") == p(nil, 3, 4), "US: month first")
        #expect(day("3/4", gb) == p(nil, 4, 3), "GB: day first")
        #expect(day("14.9.", de) == p(nil, 9, 14))
        #expect(day("14.9.2026", de) == p(2026, 9, 14))
        #expect(day("9/14/26") == p(2026, 9, 14))
        #expect(day("9/14/2026") == p(2026, 9, 14))
    }

    @Test func theOnlyValidReadingWinsWhenTheLocaleOrderIsImpossible() {
        #expect(day("14/9") == p(nil, 9, 14), "US order impossible → the other order (PROVISIONAL)")
        #expect(day("9/14", gb) == p(nil, 9, 14))
        #expect(day("13/13") == nil)
        #expect(day("31/31") == nil)
    }

    @Test func notNumericDays() {
        #expect(day("9-14") == nil, "a two-part dash is a word")
        #expect(day("9/") == nil)
        #expect(day("/14") == nil)
        #expect(day("9/14/2") == nil)
        #expect(day("123/4") == nil)
        #expect(day("a/b") == nil)
        #expect(day("1.5") == nil, "en_US never writes days with dots — 1.5 is a number")
        #expect(day("1.5", de) == p(nil, 5, 1), "de does")
        #expect(day("") == nil)
    }

    @Test func patternsMatchStoredDayKeys() throws {
        let yearless = try #require(p(nil, 9, 14))
        #expect(yearless.matches(dayKey: "2026-09-14"))
        #expect(yearless.matches(dayKey: "2019-09-14"))
        #expect(!yearless.matches(dayKey: "2026-09-15"))
        #expect(!yearless.matches(dayKey: "garbage"))
        let dated = try #require(p(2026, 9, 14))
        #expect(dated.matches(dayKey: "2026-09-14"))
        #expect(!dated.matches(dayKey: "2025-09-14"))
        #expect(yearless.dayKey(inYear: 2025) == "2025-09-14")
        #expect(dated.dayKey(inYear: 2025) == nil)
        #expect(dated.dayKey(inYear: 2026) == "2026-09-14")
        let leap = try #require(p(nil, 2, 29))
        #expect(leap.dayKey(inYear: 2024) == "2024-02-29")
        #expect(leap.dayKey(inYear: 2026) == nil)
    }

    @Test func dayRangesAreLocalDaysAsUTCWindows() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = try #require(TimeZone(identifier: "America/New_York"))
        let one = try #require(SearchDayRange(field: .edited, firstDay: "2026-09-14", lastDay: "2026-09-14", calendar: calendar))
        #expect(one.start == "2026-09-14T04:00:00.000Z")
        #expect(one.end == "2026-09-15T04:00:00.000Z")
        let span = try #require(SearchDayRange(field: .created, firstDay: "2026-11-01", lastDay: "2026-11-02", calendar: calendar))
        #expect(span.start == "2026-11-01T04:00:00.000Z", "EDT")
        #expect(span.end == "2026-11-03T05:00:00.000Z", "EST — the fall-back day is 25 hours")
        #expect(SearchDayRange(field: .edited, firstDay: "2026-09-15", lastDay: "2026-09-14", calendar: calendar) == nil)
        #expect(SearchDayRange(field: .edited, firstDay: "nope", lastDay: "2026-09-14", calendar: calendar) == nil)
    }
}
