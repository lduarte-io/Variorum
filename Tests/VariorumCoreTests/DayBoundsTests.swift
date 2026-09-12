import Foundation
import Testing

@testable import VariorumCore

/// **18h batch 2 — the day search's conversion rule** (the 2026-09-12
/// use-report round, her ledger row 11; ruling R-Q8).
///
/// She picks a day in HER calendar; the store holds UTC ISO text. Everything
/// the day search's correctness rests on is in that sentence, so this suite
/// holds the conversion to the two shapes that actually break it — a day
/// whose bounds straddle two UTC dates, and a day that is not 24 hours long.
///
/// RED ON OLD — a PRODUCT row: `DayBounds` does not exist on the pre-change
/// tree, so these pins do not compile there (the recorded compile errors are
/// the batch record's red-on-old evidence).
@Suite("One local day, in the store's own UTC text (18h batch 2)")
struct DayBoundsTests {
    private func calendar(_ zone: String) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: zone)!
        return calendar
    }

    private func hours(_ bounds: DayBounds) -> Double {
        let start = DateFormatter.variorumISO8601.date(from: bounds.start)!
        let end = DateFormatter.variorumISO8601.date(from: bounds.end)!
        return end.timeIntervalSince(start) / 3600
    }

    @Test func aDayInUTCIsMidnightToMidnight() throws {
        let bounds = try #require(DayBounds(day: "2026-09-09", calendar: calendar("UTC")))
        #expect(bounds.day == "2026-09-09")
        #expect(bounds.start == "2026-09-09T00:00:00.000Z")
        #expect(bounds.end == "2026-09-10T00:00:00.000Z")
        #expect(hours(bounds) == 24)
    }

    /// THE MIDNIGHT PIN. Her Tuesday in Los Angeles is not the UTC Tuesday:
    /// it begins at 07:00Z and ends at 07:00Z the next date. A query that
    /// compared the stored text against the bare day key would answer with
    /// the wrong seven hours at each end — which is the bug this type exists
    /// to make impossible.
    @Test func aWesternDayStraddlesTwoUTCDates() throws {
        let la = calendar("America/Los_Angeles")
        let bounds = try #require(DayBounds(day: "2026-09-09", calendar: la))
        #expect(bounds.start == "2026-09-09T07:00:00.000Z")
        #expect(bounds.end == "2026-09-10T07:00:00.000Z")

        // 06:59Z is still Sep 8 in her calendar — outside the window, and
        // the naive "starts with 2026-09-09" test would have taken it.
        let lateOnTheEighth = "2026-09-09T06:59:00.000Z"
        #expect(lateOnTheEighth < bounds.start)
        #expect(lateOnTheEighth.hasPrefix(bounds.day))
        // …and 07:30Z on the TENTH is still Sep 9 for her, which that same
        // naive test would have missed.
        let earlyOnTheTenth = "2026-09-10T01:30:00.000Z"
        #expect(earlyOnTheTenth >= bounds.start && earlyOnTheTenth < bounds.end)
    }

    /// THE DST PINS. A local day is 23 or 25 hours twice a year, so neither
    /// end may be arithmetic on the other.
    @Test func aSpringForwardDayIsTwentyThreeHoursLong() throws {
        let ny = calendar("America/New_York")
        let bounds = try #require(DayBounds(day: "2026-03-08", calendar: ny))
        #expect(bounds.start == "2026-03-08T05:00:00.000Z")  // 00:00 EST
        #expect(bounds.end == "2026-03-09T04:00:00.000Z")    // 00:00 EDT
        #expect(hours(bounds) == 23)
    }

    @Test func aFallBackDayIsTwentyFiveHoursLong() throws {
        let ny = calendar("America/New_York")
        let bounds = try #require(DayBounds(day: "2026-11-01", calendar: ny))
        #expect(bounds.start == "2026-11-01T04:00:00.000Z")  // 00:00 EDT
        #expect(bounds.end == "2026-11-02T05:00:00.000Z")    // 00:00 EST
        #expect(hours(bounds) == 25)
    }

    /// The sharpest case: a day whose MIDNIGHT never happened. Brazil moved
    /// its clocks forward at 00:00, so 2018-11-04T00:00 does not exist in São
    /// Paulo and the day begins at 01:00 local. The noon anchor plus
    /// `startOfDay` answers that; a `DateComponents` with `hour = 0` does
    /// not.
    @Test func aDayWhoseMidnightNeverHappenedBeginsWhenTheClocksMoved() throws {
        let saoPaulo = calendar("America/Sao_Paulo")
        let bounds = try #require(DayBounds(day: "2018-11-04", calendar: saoPaulo))
        let start = try #require(DateFormatter.variorumISO8601.date(from: bounds.start))
        #expect(saoPaulo.component(.hour, from: start) == 1,
                "the day's first instant is 01:00 local — 00:00 did not exist")
        #expect(bounds.start == "2018-11-04T03:00:00.000Z")
        #expect(bounds.end == "2018-11-05T02:00:00.000Z")
        #expect(hours(bounds) == 23)
    }

    /// Half-open bounds TILE: no gap, no overlap, whatever a day's length.
    @Test func consecutiveDaysTileAcrossADSTBoundary() throws {
        let ny = calendar("America/New_York")
        let saturday = try #require(DayBounds(day: "2026-03-07", calendar: ny))
        let sunday = try #require(DayBounds(day: "2026-03-08", calendar: ny))
        let monday = try #require(DayBounds(day: "2026-03-09", calendar: ny))
        #expect(saturday.end == sunday.start)
        #expect(sunday.end == monday.start)
    }

    @Test func aKeyThatIsNotADayHasNoBounds() {
        let utc = calendar("UTC")
        #expect(DayBounds(day: "2026-02-30", calendar: utc) == nil)
        #expect(DayBounds(day: "2026-9-9", calendar: utc) == nil)
        #expect(DayBounds(day: "yesterday", calendar: utc) == nil)
        #expect(DayBounds(day: "", calendar: utc) == nil)
    }

    /// The noon anchor round-trips every day of a year in a zone that shifts
    /// twice — which is what lets a caller name a day with
    /// `JournalDay.dayString` and get bounds back for exactly that day.
    /// *(This was `init(containing:)`'s force-unwrap proof until the
    /// ladder's R1-8 retired that initializer: the proof holds for a
    /// GREGORIAN calendar and the initializer's signature promised any.)*
    @Test func everyDayOfAYearRoundTripsThroughItsOwnKey() throws {
        let ny = calendar("America/New_York")
        var day = try #require(JournalDay.date(from: "2026-01-01", calendar: ny))
        for _ in 0..<365 {
            let key = JournalDay.dayString(from: day, calendar: ny)
            let bounds = try #require(DayBounds(day: key, calendar: ny),
                                      "\(key) has no bounds")
            #expect(bounds.day == key)
            let start = try #require(DateFormatter.variorumISO8601.date(from: bounds.start))
            #expect(JournalDay.dayString(from: start, calendar: ny) == key,
                    "\(key)'s first instant belongs to another day")
            day = try #require(ny.date(byAdding: .day, value: 1, to: day))
        }
    }
}
