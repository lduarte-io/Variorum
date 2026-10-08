//
//  LibraryWhenDoorTests.swift
//  VariorumTests
//
//  **VX-87 — the `when ▾` door rebuilt to her direction 1** (R-VX83-2: *"I
//  choose direction 1 on the calendar"*; her report: *"it's very unclear if
//  there's confirmation. the nested drop downs where a new dropdown appears
//  is also a big of an ugly ux experience."*). A DESIGN row, so these are
//  NEW-BEHAVIOR pins (they do not compile on the pre-change tree — the brain
//  and the sentence did not exist; the shipped door armed today the moment a
//  menu item was chosen, P-13o-U2-9):
//
//  - THE SENTENCE says exactly what is armed, in the chip's own day words;
//  - THE NO-SILENT-ARM RULE: opening and the mode row arm nothing — only a
//    pressed day does;
//  - THE TWO-PRESS RUN: between days, the first press arms its day and waits,
//    the second makes the run (any order), a third begins afresh;
//  - and the presses reach the listing through the model's own road.
//

import Dependencies
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-87 — the when door, direction 1 (the sentence, no silent arm, the two-press run)", .serialized)
struct LibraryWhenDoorTests {
    private var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private func now() throws -> Date {
        try #require(DateFormatter.variorumISO8601.date(from: "2026-10-07T12:00:00.000Z"))
    }

    // MARK: - The sentence

    /// The mockup's two sentences, verbatim in shape — and the emphasized
    /// words are the band chip's own, so the confirmation inside the popover
    /// and the chip outside it say the same day.
    @Test func theSentenceSaysWhatIsArmedInTheChipsOwnWords() throws {
        let now = try now()
        let one = try #require(LibraryDayRange(day: "2026-10-06"))
        let run = try #require(LibraryDayRange(first: "2026-10-01", last: "2026-10-06"))

        let onDay = LibraryDayFace.sentence(range: one, now: now, calendar: utc)
        #expect(onDay.plain == "Showing notes edited on Oct 6.")
        #expect(onDay.emphasis == "on Oct 6", "the armed words are the emphasized part")
        #expect(LibraryDayFace.chipLabel(one, now: now, calendar: utc) == "edited " + onDay.emphasis,
                "the chip says the same day")

        let between = LibraryDayFace.sentence(range: run, now: now, calendar: utc)
        #expect(between.plain == "Showing notes edited Oct 1 \u{2013} Oct 6.")
        #expect(between.emphasis == "Oct 1 \u{2013} Oct 6")
        #expect(LibraryDayFace.chipLabel(run, now: now, calendar: utc) == "edited " + between.emphasis)

        let none = LibraryDayFace.sentence(range: nil, now: now, calendar: utc)
        #expect(none.plain == "Showing notes edited on any day.",
                "nothing armed says the clearing word's own state (PROVISIONAL P-VX83-B1)")
        #expect(none.emphasis.hasSuffix(LibraryDayFace.anyDay))

        let lastYear = try #require(LibraryDayRange(day: "2025-12-31"))
        #expect(LibraryDayFace.sentence(range: lastYear, now: now, calendar: utc).emphasis
                == "on Dec 31, 2025", "a day from another year names its year, as every stamp does")
    }

    // MARK: - Nothing arms until a day is pressed

    /// Her report's "unclear if there's confirmation" — the shipped door armed
    /// TODAY the moment `on a day…` was chosen, before she had touched a date.
    /// Opening and the mode row now yield nothing to arm; the one member that
    /// yields a range is `press(_:)`.
    @Test func nothingArmsUntilADayIsPressed() throws {
        var fresh = LibraryWhenDoorBrain.opening(range: nil)
        #expect(fresh.mode == .oneDay && !fresh.waitsForRunEnd, "a fresh door opens asking for a day")
        fresh.ask(.between)
        #expect(fresh.mode == .between && !fresh.waitsForRunEnd, "the mode row arms nothing and waits for nothing")
        fresh.ask(.oneDay)
        #expect(fresh == LibraryWhenDoorBrain.opening(range: nil), "…and leaves no trace")

        let run = try #require(LibraryDayRange(first: "2026-10-01", last: "2026-10-06"))
        let armed = LibraryWhenDoorBrain.opening(range: run)
        #expect(armed.mode == .between && !armed.waitsForRunEnd,
                "an armed run reopens on between days, re-arming nothing")
        let oneDay = try #require(LibraryDayRange(day: "2026-10-06"))
        #expect(LibraryWhenDoorBrain.opening(range: oneDay).mode == .oneDay)

        var brain = LibraryWhenDoorBrain.opening(range: nil)
        #expect(brain.press("not a day") == nil, "a key that is not a day arms nothing")
        #expect(brain.press("2026-10-06") == oneDay, "a pressed day is the one act that arms")
    }

    // MARK: - The two-press run

    @Test func betweenDaysTheFirstPressArmsItsDayAndTheSecondMakesTheRun() throws {
        var brain = LibraryWhenDoorBrain.opening(range: nil)
        brain.ask(.between)

        #expect(brain.press("2026-10-01") == LibraryDayRange(day: "2026-10-01"),
                "the first press arms its own day — Esc now keeps exactly what the sentence says")
        #expect(brain.waitsForRunEnd && brain.runStart == "2026-10-01", "…and waits for the last day")

        #expect(brain.press("2026-10-06") == LibraryDayRange(first: "2026-10-01", last: "2026-10-06"),
                "the second press makes the run, first through last")
        #expect(!brain.waitsForRunEnd)

        #expect(brain.press("2026-10-09") == LibraryDayRange(day: "2026-10-09"),
                "a third press begins a fresh run")
        #expect(brain.press("2026-09-28") == LibraryDayRange(first: "2026-09-28", last: "2026-10-09"),
                "pressed backwards, the run is put in order — and it crosses a month")

        brain.ask(.between)
        #expect(brain.press("2026-10-14") == LibraryDayRange(day: "2026-10-14"))
        brain.ask(.oneDay)
        #expect(!brain.waitsForRunEnd, "changing the question forgets a run's waiting start")
        #expect(brain.press("2026-10-20") == LibraryDayRange(day: "2026-10-20"))
    }

    @Test func onADayEveryPressArmsThatDayAlone() throws {
        var brain = LibraryWhenDoorBrain.opening(range: nil)
        #expect(brain.press("2026-10-06") == LibraryDayRange(day: "2026-10-06"))
        #expect(!brain.waitsForRunEnd, "on a day never waits")
        #expect(brain.press("2026-10-02") == LibraryDayRange(day: "2026-10-02"), "a second press moves the day")
    }

    // MARK: - The presses reach the listing

    private final class TravellingClock: @unchecked Sendable {
        private let state = LockIsolated(Date(timeIntervalSince1970: 0))
        var current: Date { state.value }
        func set(_ date: Date) { state.setValue(date) }
        func next() -> Date {
            state.withValue { value in
                defer { value = value.addingTimeInterval(0.001) }
                return value
            }
        }
    }

    /// Two presses between days arm the run that answers — through the
    /// model's own `setEditedRange` + `search()`, the two steps the door's
    /// `onPick` runs in `LibraryCatalogView`.
    @Test func twoPressesNarrowTheLibraryToTheRun() async throws {
        let db = try AppDatabase.inMemory()
        let clock = TravellingClock()
        clock.set(Date(timeIntervalSince1970: 1_789_646_400))  // 2026-09-17T12:00:00Z
        try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 87))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let suite = "vx87-when-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defaults.removePersistentDomain(forName: suite)
            let model = LibraryCatalogModel(session: session, defaults: defaults)

            let today = clock.current
            var made: [String] = []
            for back in [4, 3, 1, 0] {
                clock.set(today.addingTimeInterval(-Double(back) * 86_400))
                let note = try session.operations.createPost(title: "note \(back)")
                _ = try session.operations.newBlock(in: note.id, text: "words")
                made.append(note.id)
            }
            clock.set(today)
            func day(_ back: Double) -> String {
                JournalDay.dayString(from: today.addingTimeInterval(-back * 86_400))
            }

            var brain = LibraryWhenDoorBrain.opening(range: model.editedRange)
            brain.ask(.between)
            #expect(model.editedRange == nil, "opening and the mode row armed nothing")

            let first = brain.press(day(1))
            model.setEditedRange(try #require(first))
            await model.search()
            #expect(model.noteHits.map(\.id) == [made[2]], "the first press: its own day, already armed")

            let second = brain.press(day(3))
            model.setEditedRange(try #require(second))
            await model.search()
            #expect(Set(model.noteHits.map(\.id)) == [made[1], made[2]],
                    "the second press (backwards): the run, and only its days")
            #expect(model.editedRange == LibraryDayRange(first: day(3), last: day(1)))
        }
    }
}
