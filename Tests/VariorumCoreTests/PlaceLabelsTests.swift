import Foundation
import Testing
@testable import VariorumCore

// 13n-c U2 — PLACE LABELS (VX-156 items 1 + 6; brief §2 option A; mockup §1b):
// the context line in its fixed order and the collision ladder (wing → shelf →
// note count → state → made day → made time), per place, never an ordinal.
// Every clock, calendar and locale is fixed, so the pins hold the rule rather
// than the machine.

@Suite("13n-c U2 — place labels: the context line and the collision ladder")
struct PlaceLabelsTests {
    private typealias Place = PlaceLabels.Place
    private typealias Marks = PlaceLabels.Marks

    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()
    private static let locale = Locale(identifier: "en_US")
    /// 2026-10-11 12:00 UTC.
    private static let now = Date(timeIntervalSince1970: 1_791_720_000)

    private static func day(_ d: Int, _ hour: Int = 12, _ minute: Int = 0, _ second: Int = 0, month: Int = 10) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: d, hour: hour, minute: minute, second: second))!
    }

    private func book(
        _ id: String, _ name: String = "the adventures of sherlock holmes", wing: String = "Home",
        shelf: String? = "Welcome", notes: Int = 12, marks: Marks = Marks(owned: true),
        made: Date = PlaceLabelsTests.day(9), edited: Date? = nil
    ) -> Place {
        Place(id: id, name: name, wing: wing, inHome: wing == "Home", shelf: shelf, noteCount: notes,
              marks: marks, madeAt: made, lastEdited: edited)
    }

    private func labels(_ places: [Place]) -> [String: String] {
        PlaceLabels.disambiguate(places, now: Self.now, calendar: Self.calendar, locale: Self.locale)
    }

    private func context(_ place: Place) -> String {
        PlaceLabels.context(place, now: Self.now, calendar: Self.calendar, locale: Self.locale)
    }

    // MARK: - The context line

    @Test func theContextLineSaysTheBookcasesFactsInOneFixedOrder() {
        #expect(context(book("a", edited: Self.day(10))) == "Welcome · 12 notes · owned · edited yesterday",
                "shelf · N notes · state marks · last edited (mockup §1b + her round-2 last edited)")
        #expect(context(book("a", shelf: nil, notes: 1, marks: Marks())) == "1 note",
                "unshelved says no shelf; one note is singular; an open book says no state")
        #expect(context(book("a", wing: "variorum", shelf: nil, notes: 3, marks: Marks()))
                == "variorum wing · 3 notes", "a non-Home book names its wing first (mockup §1b's percy row)")
        #expect(context(book("a", marks: Marks(living: true, finished: true, owned: true, archived: true)))
                == "Welcome · 12 notes · living · finished · owned · archived")
        #expect(context(book("a", marks: Marks(finished: true, sealed: true))) == "Welcome · 12 notes · sealed",
                "sealed implies finished and says only sealed (the Bookcase's rule)")
        #expect(context(.wing(id: "w", name: "variorum", madeAt: Self.day(1))) == "", "a wing has no context line")
        #expect(context(book("a", edited: Self.day(11, 9, 5))).hasSuffix("edited today 9:05\u{202F}AM"),
                "last edited in TimeStampFace's own words")
    }

    // MARK: - The ladder, rung by rung (pairs)

    @Test func aNameNoOtherOfferedPlaceSharesNeedsNoDistinguisher() {
        #expect(labels([book("a", "a letter"), book("b", "o ladrão de raios"), book("c", "percy")]).isEmpty)
        #expect(labels([book("a")]).isEmpty, "one place is never compared with itself")
    }

    @Test func theFirstRungThatSeparatesAPairIsTheOneEachWears() {
        // wing
        #expect(labels([book("a"), book("b", wing: "variorum")]) == ["a": "Home wing", "b": "variorum wing"])
        // shelf
        #expect(labels([book("a"), book("b", shelf: "research")]) == ["a": "Welcome", "b": "research"])
        #expect(labels([book("a"), book("b", shelf: nil)]) == ["a": "Welcome", "b": "unshelved"])
        // note count
        #expect(labels([book("a"), book("b", notes: 4)]) == ["a": "12 notes", "b": "4 notes"])
        // state
        #expect(labels([book("a"), book("b", marks: Marks(finished: true, owned: true))])
                == ["a": "owned", "b": "finished · owned"])
        // made day — the mockup §1b pair, exactly
        #expect(labels([book("a", made: Self.day(9)), book("b", made: Self.day(11))])
                == ["a": "made Oct 9", "b": "made Oct 11"])
        // made time
        #expect(labels([book("a", made: Self.day(9, 21, 14)), book("b", made: Self.day(9, 8, 2))])
                == ["a": "made Oct 9, 9:14\u{202F}PM", "b": "made Oct 9, 8:02\u{202F}AM"])
        // made second (two minted inside one minute)
        #expect(labels([book("a", made: Self.day(9, 21, 14, 5)), book("b", made: Self.day(9, 21, 14, 41))])
                == ["a": "made Oct 9, 9:14:05\u{202F}PM", "b": "made Oct 9, 9:14:41\u{202F}PM"])
        // a made day in another year carries it (TimeStampFace's honesty)
        #expect(labels([book("a", made: Self.day(9)), book("b", made: Self.calendar.date(
            from: DateComponents(year: 2025, month: 10, day: 9, hour: 12))!)])
                == ["a": "made Oct 9", "b": "made Oct 9, 2025"])
    }

    @Test func aRungAPlaceHasNoValueForIsSkippedForIt() {
        // b is open (no marks): its state rung is skipped, so it falls to the
        // made day; a is the only owned one, so "owned" is its own.
        #expect(labels([book("a", made: Self.day(9)), book("b", marks: Marks(), made: Self.day(11))])
                == ["a": "owned", "b": "made Oct 11"])
    }

    // MARK: - Sameness (the picker brain's own)

    @Test func samenessIsCaseAndDiacriticInsensitive() {
        #expect(PlaceLabels.sameName("Café", "cafe"))
        #expect(PlaceLabels.sameName("  The Adventures of Sherlock Holmes ", "the adventures of sherlock holmes"))
        #expect(!PlaceLabels.sameName("sherlock", "sherlock holmes"))
        #expect(labels([book("a", "Café"), book("b", "cafe", shelf: "other")]) == ["a": "Welcome", "b": "other"])
    }

    // MARK: - Sets larger than two

    @Test func everyLabelInALargerSetIsItsOwn() {
        // c alone is on "research"; a and b share Welcome AND c's made day
        // differs from b's but equals a's — so a must go down to the time.
        let a = book("a", made: Self.day(9, 21, 14))
        let b = book("b", made: Self.day(11))
        let c = book("c", shelf: "research", made: Self.day(9, 8, 0))
        let answer = labels([a, b, c])
        #expect(answer == ["a": "made Oct 9, 9:14\u{202F}PM", "b": "made Oct 11", "c": "research"])
        #expect(Set(answer.values).count == 3, "no two places in the set wear the same distinguisher")
    }

    @Test func twoCollisionSetsAreJudgedSeparately() {
        let answer = labels([
            book("s1", made: Self.day(9)), book("s2", made: Self.day(11)),
            book("p1", "percy", notes: 3), book("p2", "Percy", notes: 5),
            book("solo", "a letter"),
        ])
        #expect(answer == ["s1": "made Oct 9", "s2": "made Oct 11", "p1": "3 notes", "p2": "5 notes"])
    }

    // MARK: - Never an ordinal

    @Test func identicalPlacesSayTheSameHonestFactNeverAnOrdinal() {
        let instant = Self.day(9, 21, 14, 5)
        let answer = labels([book("a", made: instant), book("b", made: instant)])
        #expect(answer["a"] == "made Oct 9, 9:14:05\u{202F}PM" && answer["b"] == answer["a"],
                "two books minted in one second say the same fact — never “(2)”")
        let ordinal = try! Regex(#"\(\d+\)|#\d+|\b\d+(st|nd|rd|th)\b"#)
        for value in answer.values { #expect(value.firstMatch(of: ordinal) == nil) }
    }

    @Test func wingsCollideOnTheirMadeStampAlone() {
        let answer = labels([
            .wing(id: "w1", name: "studio", madeAt: Self.day(2)),
            .wing(id: "w2", name: "Studio", madeAt: Self.day(5)),
            .wing(id: "home", name: "Home", madeAt: Self.day(1)),
        ])
        #expect(answer == ["w1": "made Oct 2", "w2": "made Oct 5"])
    }

    @Test func aQuotedNameCarriesItsDistinguisher() {
        #expect(PlaceLabels.quoted("the adventures of sherlock holmes", distinguisher: "made Oct 9")
                == "\u{201C}the adventures of sherlock holmes\u{201D} (made Oct 9)")
        #expect(PlaceLabels.quoted("dream journal", distinguisher: nil) == "\u{201C}dream journal\u{201D}")
        #expect(PlaceLabels.quoted("dream journal", distinguisher: "") == "\u{201C}dream journal\u{201D}")
    }
}
