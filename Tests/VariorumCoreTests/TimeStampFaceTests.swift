import Foundation
import Testing
@testable import VariorumCore

/// **18h batch 1 — the ONE stamp-wording brain** (review focus F-5: *"the
/// relative-time wording is ONE pure brain (`TimeStampFace`) used by every
/// row and the masthead"*).
///
/// Her ruling R-Q7 names the words: *edited today 1:33 AM* / *edited Sep 9*,
/// flipping to *created …* on a click. Every threshold below is the BATCH'S
/// number, recorded in `TimeStampFace`'s own doc rather than asked of her.
///
/// RED ON OLD: `TimeStampFace` did not exist. The nearest thing was
/// `NoteBoxCopy.day` (18d's *"edited Sep 4 · saved Sep 2"*), which knows
/// only the day form and nothing of today/yesterday or a time — so the pins
/// here do not compile on the pre-change tree.
@Suite("The stamp's words (18h batch 1 — TimeStampFace)")
struct TimeStampFaceTests {
    /// A fixed world: UTC, en_US, and a "now" of 2026-09-12 at 13:33 — so
    /// the words are the rule's, never the machine's clock or locale.
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private let locale = Locale(identifier: "en_US")

    private func date(_ iso: String) -> Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter.date(from: iso)!
    }

    private var now: Date { date("2026-09-12T13:33:00") }

    private func words(_ iso: String) -> String {
        TimeStampFace.relative(date(iso), now: now, calendar: calendar, locale: locale)
    }

    @Test func todayCarriesTheTimeAndYesterdayIsJustTheWord() {
        #expect(words("2026-09-12T01:33:00") == "today 1:33\u{202F}AM")
        #expect(words("2026-09-12T13:33:00") == "today 1:33\u{202F}PM", "the same minute as now")
        #expect(words("2026-09-12T00:00:00") == "today 12:00\u{202F}AM", "midnight is still today")
        // Yesterday is the DAY before in the calendar, not 24 hours back:
        // 23:59 last night is yesterday even though it is minutes away.
        #expect(words("2026-09-11T23:59:00") == "yesterday")
        #expect(words("2026-09-11T00:01:00") == "yesterday")
    }

    @Test func thisYearIsTheDayAndAnyOtherYearCarriesIt() {
        #expect(words("2026-09-09T16:02:00") == "Sep 9")
        #expect(words("2026-01-01T16:02:00") == "Jan 1")
        #expect(words("2025-09-09T16:02:00") == "Sep 9, 2025",
                "a year omitted would be a lie told by omission (18d's own rule)")
        #expect(words("2024-12-31T23:00:00") == "Dec 31, 2024")
    }

    /// A stamp from the FUTURE is a real shape — a store copied from a
    /// machine whose clock ran ahead, or a sync arrival. It reads as a day,
    /// never as "today" and never as an error.
    @Test func aFutureStampReadsAsItsDay() {
        #expect(words("2026-09-13T09:00:00") == "Sep 13")
        #expect(words("2027-01-04T09:00:00") == "Jan 4, 2027")
        #expect(words("2026-09-12T23:59:00") == "today 11:59\u{202F}PM",
                "later TODAY is still today")
    }

    /// The verb is the brain's too, so no view spells it (P-8/F-0: no
    /// string-as-rule in a view).
    @Test func theLabelledFormCarriesTheVerb() {
        #expect(TimeStampFace.stamp(
            .edited, date: date("2026-09-12T01:33:00"), now: now,
            calendar: calendar, locale: locale) == "edited today 1:33\u{202F}AM")
        #expect(TimeStampFace.stamp(
            .created, date: date("2026-09-09T01:33:00"), now: now,
            calendar: calendar, locale: locale) == "created Sep 9")
    }

    /// **A DAY-precision stamp never prints a time** — `entry_date` is a day
    /// she stated, and inventing "12:00 PM" for it would be the app claiming
    /// a fact it does not hold.
    @Test func aDayStampSaysTheDayAndNoTime() {
        #expect(TimeStampFace.stamp(
            .dated, day: "2026-09-12", now: now,
            calendar: calendar, locale: locale) == "dated today")
        #expect(TimeStampFace.stamp(
            .dated, day: "2026-09-11", now: now,
            calendar: calendar, locale: locale) == "dated yesterday")
        #expect(TimeStampFace.stamp(
            .dated, day: "2026-09-09", now: now,
            calendar: calendar, locale: locale) == "dated Sep 9")
        #expect(TimeStampFace.stamp(
            .dated, day: "2025-09-09", now: now,
            calendar: calendar, locale: locale) == "dated Sep 9, 2025")
    }

    /// The ISO door: the store's canonical stamp text in, words out — and
    /// nil for anything that is not a stamp, so a face draws nothing rather
    /// than a lie.
    @Test func theISODoorParsesTheStoresOwnStampAndRefusesTheRest() {
        let stored = DateFormatter.variorumISO8601.string(from: date("2026-09-09T16:02:00"))
        #expect(TimeStampFace.stamp(
            .edited, iso: stored, now: now, calendar: calendar, locale: locale)
            == "edited Sep 9")
        #expect(TimeStampFace.stamp(
            .edited, iso: nil, now: now, calendar: calendar, locale: locale) == nil)
        #expect(TimeStampFace.stamp(
            .edited, iso: "", now: now, calendar: calendar, locale: locale) == nil)
        #expect(TimeStampFace.stamp(
            .edited, iso: "not a stamp", now: now, calendar: calendar, locale: locale) == nil)
        #expect(TimeStampFace.stamp(
            .dated, day: "2026-13-40", now: now, calendar: calendar, locale: locale) == nil,
            "an impossible day is refused, never rendered")
        // A day key arriving at the ISO door still reads (the Library's
        // `detail` column is a day, and one door tolerating both is why the
        // face never has to guess which shape it holds).
        #expect(TimeStampFace.stamp(
            .dated, iso: "2026-09-09", now: now, calendar: calendar, locale: locale)
            == "dated Sep 9")
    }

    /// The tooltip is the WHOLE fact — the glanceable words are a summary,
    /// and hovering must never leave her guessing which year "Sep 9" was.
    @Test func theTooltipSpellsTheWholeFact() {
        #expect(TimeStampFace.tooltip(
            .edited, date: date("2026-09-09T16:02:00"),
            calendar: calendar, locale: locale) == "Edited Sep 9, 2026 at 4:02\u{202F}PM")
        #expect(TimeStampFace.tooltip(
            .created, date: date("2026-09-12T01:33:00"),
            calendar: calendar, locale: locale) == "Created Sep 12, 2026 at 1:33\u{202F}AM")
        #expect(TimeStampFace.tooltip(
            .dated, day: "2026-09-09", calendar: calendar, locale: locale)
            == "Dated Sep 9, 2026", "a day has no time to spell")
    }

    /// **ONE CALENDAR PER LETTER** (the 18h ladder's calendar ruling,
    /// 2026-09-13 — the cousin batch 2's R1-8 fix left standing).
    ///
    /// The day filter learned to name its calendar (Gregorian, her zone)
    /// because `JournalDay.dayString` emits the CURRENT calendar's components
    /// while `JournalDay.isValid` validates proleptic Gregorian — so under a
    /// Hebrew `Calendar.current` the filter's own key would be refused. The
    /// STAMPS beside it still defaulted to `Calendar.current`, which meant a
    /// non-Gregorian user would read one calendar in the Library's rows and
    /// another in the day door, on one screen. Now both read
    /// `JournalDay.storeCalendar`.
    ///
    /// A test cannot change `Calendar.current`, so the Hebrew half is pinned
    /// the way batch 2 pinned its own: the trap is demonstrated on the road
    /// the defaults no longer take.
    @Test func theStampsSpeakTheStoresOwnCalendarNotTheSystems() throws {
        #expect(JournalDay.storeCalendar.identifier == .gregorian)
        #expect(JournalDay.storeCalendar.timeZone == Calendar.current.timeZone,
                "her day boundaries stay her zone's — that half of Calendar.current is right")

        let instant = try #require(
            DateFormatter.variorumISO8601.date(from: "2026-09-09T18:00:00.000Z"))
        let asOf = try #require(
            DateFormatter.variorumISO8601.date(from: "2026-09-12T18:00:00.000Z"))

        // The road the stamps no longer take: a Hebrew calendar words the
        // same instant as a different day entirely.
        var hebrew = Calendar(identifier: .hebrew)
        hebrew.timeZone = Calendar.current.timeZone
        let hebrewWords = TimeStampFace.day(
            instant, now: asOf, calendar: hebrew, locale: locale)

        // The road they take: the defaults are the store's calendar, and they
        // answer as the explicit Gregorian one does.
        let defaulted = TimeStampFace.day(instant, now: asOf, locale: locale)
        let explicit = TimeStampFace.day(
            instant, now: asOf, calendar: JournalDay.storeCalendar, locale: locale)
        #expect(defaulted == explicit, "the default IS the store's calendar")
        #expect(defaulted != hebrewWords,
                "…and it is not the system's, whatever the system is: \(hebrewWords)")

        // The same for the labelled form every row and the masthead draw.
        #expect(TimeStampFace.stamp(.edited, date: instant, now: asOf, locale: locale)
                == TimeStampFace.stamp(
                    .edited, date: instant, now: asOf,
                    calendar: JournalDay.storeCalendar, locale: locale))

        // And the day KEY the filter compares against is one this store can
        // name — the whole reason the calendar is named at all.
        let key = JournalDay.dayString(from: instant, calendar: JournalDay.storeCalendar)
        #expect(JournalDay.isValid(key), "\(key) is a day the store can name")
    }

    /// **The formatter cache's own risk, pinned** (the 18h ladder, R1-5).
    /// The fix is a performance fix and the arbitration owed it no pin — but
    /// a CACHE introduces a failure the slow code could not have: a key that
    /// forgets part of the shape hands back a formatter speaking the wrong
    /// locale, calendar or zone, turning a slow-but-correct answer into a
    /// fast lie. So the words are asked for through the SAME template under
    /// four different shapes, and each must answer as itself.
    @Test func theFormatterCacheAnswersPerLocaleCalendarAndZone() {
        let instant = date("2026-09-09T23:30:00")

        // Same template, two LOCALES.
        let american = TimeStampFace.day(
            instant, now: now, calendar: calendar, locale: Locale(identifier: "en_US"))
        let french = TimeStampFace.day(
            instant, now: now, calendar: calendar, locale: Locale(identifier: "fr_FR"))
        #expect(american == "Sep 9")
        #expect(french != american, "a second locale is not served the first's formatter: \(french)")

        // Same template and locale, two ZONES — and the zone is what decides
        // which DAY 23:30 UTC belongs to.
        var tokyo = Calendar(identifier: .gregorian)
        tokyo.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        #expect(TimeStampFace.day(instant, now: now, calendar: tokyo, locale: locale) == "Sep 10",
                "Tokyo is already on the 10th; a zone-blind cache would say Sep 9")
        #expect(TimeStampFace.day(instant, now: now, calendar: calendar, locale: locale) == "Sep 9",
                "…and UTC still says Sep 9 afterwards — neither poisoned the other")

        // Same template, locale and zone, two CALENDARS.
        var hebrew = Calendar(identifier: .hebrew)
        hebrew.timeZone = TimeZone(identifier: "UTC")!
        let hebrewDay = TimeStampFace.day(instant, now: now, calendar: hebrew, locale: locale)
        #expect(hebrewDay != "Sep 9", "a calendar-blind cache would answer Gregorian: \(hebrewDay)")

        // …and the first answer is still the first answer, asked again.
        #expect(TimeStampFace.day(
            instant, now: now, calendar: calendar,
            locale: Locale(identifier: "en_US")) == "Sep 9")
    }

    /// **VX-351 (the VX-348 run, U4 — her R-VX348-1/3): the whole fact for
    /// EVERY speaker.** The verbless body has the year always and the minute
    /// whenever the stamp holds one; a speaker's own verb leads it; the three
    /// subjects' tooltips are the same door, byte for byte; a stored day key
    /// spells its day and never an invented noon. New API (fixed-only): the
    /// red-on-old proof of the hover lives at the speakers (the Mac pins).
    @Test func everySpeakerSaysTheWholeFactInOneRule() {
        let instant = date("2026-09-09T16:02:00")
        #expect(TimeStampFace.whole(instant, calendar: calendar, locale: locale)
                == "Sep 9, 2026 at 4:02\u{202F}PM")
        #expect(TimeStampFace.whole(instant, dayPrecision: true, calendar: calendar, locale: locale)
                == "Sep 9, 2026", "a day has no time to spell")
        #expect(TimeStampFace.whole(date("2026-09-12T01:33:00"), calendar: calendar, locale: locale)
                == "Sep 12, 2026 at 1:33\u{202F}AM", "TODAY spells its year too — the hover is the whole fact")
        #expect(TimeStampFace.tooltip(labelled: "Arrived", date: instant, calendar: calendar, locale: locale)
                == "Arrived Sep 9, 2026 at 4:02\u{202F}PM")
        for subject in TimeStampFace.Subject.allCases {
            #expect(TimeStampFace.tooltip(subject, date: instant, calendar: calendar, locale: locale)
                    == TimeStampFace.tooltip(
                        labelled: subject.titleCased, date: instant,
                        dayPrecision: subject == .dated, calendar: calendar, locale: locale),
                    "\(subject): one door, byte for byte")
        }
        // The ISO door: an instant spells its minute; a DAY KEY its day alone.
        let iso = DateFormatter.variorumISO8601.string(from: instant)
        #expect(TimeStampFace.tooltip(labelled: "Saved", iso: iso, calendar: calendar, locale: locale)
                == "Saved Sep 9, 2026 at 4:02\u{202F}PM")
        #expect(TimeStampFace.tooltip(labelled: "Dated", iso: "2026-09-09", calendar: calendar, locale: locale)
                == "Dated Sep 9, 2026", "never an invented 12:00 PM")
        #expect(TimeStampFace.tooltip(labelled: "Saved", iso: nil, calendar: calendar, locale: locale) == nil)
        #expect(TimeStampFace.tooltip(labelled: "Saved", iso: "", calendar: calendar, locale: locale) == nil)
        #expect(TimeStampFace.tooltip(labelled: "Saved", iso: "soon", calendar: calendar, locale: locale) == nil,
                "text that is not a stamp says nothing rather than a lie")
    }

    /// The day form on its own — the shape 18d's facts line already ships
    /// (`NoteBoxCopy.day` forwards here, so the two can never drift).
    @Test func theDayFormIsTheOneTheFactsLineAlreadyShips() {
        #expect(TimeStampFace.day(date("2026-09-09T16:02:00"), now: now,
                                  calendar: calendar, locale: locale) == "Sep 9")
        #expect(TimeStampFace.day(date("2025-09-09T16:02:00"), now: now,
                                  calendar: calendar, locale: locale) == "Sep 9, 2025")
        #expect(TimeStampFace.day(date("2026-09-12T16:02:00"), now: now,
                                  calendar: calendar, locale: locale) == "Sep 12",
                "the DAY form knows nothing of today — that is the relative form's job")
    }
}
