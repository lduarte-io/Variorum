//
//  LibraryWhenRangeTests.swift
//  VariorumTests
//
//  **13o U2 — the `when ▾` door and its RANGE** (her R-13o-13: *"I like
//  'when' for the day door"* — the mockup's wording 2: on a day… · between
//  days… · any day, the armed state a clearable chip in the band; §21 item 3
//  — the day filter grows a range). The pins drive the door's OWN closures
//  (the 18h ladder's R1-9 — never a hand-fed value) and the model's own
//  `search()`, then read what the model landed:
//
//  - the door: `between days…` arms, and each end of the range carries the
//    other along rather than ever making an empty run;
//  - with no words the range is the unpaged SET (the day's answer, grown) —
//    a note edited on ANY day of the run answers, through the one
//    `Queries.editedOnSQL` rule, unchanged;
//  - with words, the range is the search AST's `.days` filter on the answer
//    sheet (D5);
//  - the words: the chip, the empty answer between two days.
//
//  New road, new pins (her design row): on the pre-change tree they do not
//  compile (`LibraryWhenDoor`, `LibraryDayRange`, `setEditedRange` did not
//  exist; the door armed exactly one day). VX-87 (her direction 1, R-VX83-2)
//  rebuilt the door as ONE popover with a month grid; the door's-closures pin
//  and the run's SET pin drive the popover's own `ask`/`press` now (JUSTIFIED
//  EDITS, labelled in place), and the wording pin reads the mode row.
//

import Dependencies
import Foundation
import GRDB
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("13o U2 — the when ▾ door and its range", .serialized)
struct LibraryWhenRangeTests {
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

    private func withTravellingLibrary<T>(
        _ body: @MainActor (AppSession, TravellingClock, LibraryCatalogModel) async throws -> T
    ) async throws -> T {
        let db = try AppDatabase.inMemory()
        let clock = TravellingClock()
        clock.set(Date(timeIntervalSince1970: 1_789_646_400))  // 2026-09-17T12:00:00Z
        return try await withDependencies {
            $0.database = db
            $0.uuid = .incrementing
            $0.date = DateGenerator { clock.next() }
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 37))
        } operation: { @MainActor in
            let session = AppSession(database: db)
            let suite = "13o-u2-when-\(UUID().uuidString)"
            let defaults = try #require(UserDefaults(suiteName: suite))
            defaults.removePersistentDomain(forName: suite)
            return try await body(session, clock, LibraryCatalogModel(session: session, defaults: defaults))
        }
    }

    private func day(of date: Date) -> String { JournalDay.dayString(from: date) }
    private let tokens = VoiceTokens.resolve(voice: .terminal, dark: false)

    /// VX-87: the `when` popover as its door opens it, its brain and month in
    /// boxes so its acts persist across calls as the door's `@State` does.
    private final class Box<Value> {
        var value: Value
        init(_ value: Value) { self.value = value }
    }

    private func popover(
        range: LibraryDayRange?, now: Date, calendar: Calendar = LibraryDayFace.calendar,
        onPick: @escaping (LibraryDayRange) -> Void
    ) -> LibraryWhenPopover {
        let opening = LibraryWhenDoor.openingState(
            range: range, today: JournalDay.dayString(from: now, calendar: calendar))
        let brain = Box(opening.brain)
        let month = Box(opening.month ?? LibraryWhenMonth(year: 2026, month: 9))
        return LibraryWhenPopover(
            tokens: tokens, range: range, now: now, calendar: calendar,
            brain: Binding(get: { brain.value }, set: { brain.value = $0 }),
            month: Binding(get: { month.value }, set: { month.value = $0 }),
            onPick: onPick, onClear: {})
    }

    // MARK: - The range itself

    @Test func aRangeIsASetOfRealDaysInOrder() {
        #expect(LibraryDayRange(first: "2026-09-14", last: "2026-09-01")
                == LibraryDayRange(first: "2026-09-01", last: "2026-09-14"),
                "two days out of order are put in order")
        #expect(LibraryDayRange(first: "2026-02-30", last: "2026-03-01") == nil)
        #expect(LibraryDayRange(day: "2026-09-14")?.isOneDay == true)
    }

    // MARK: - The door's own closures

    /// JUSTIFIED EDIT (VX-87 — her direction 1, R-VX83-2): this pin drove the
    /// 13o door's `between days…` (which ARMED today–today at once) and its
    /// FROM/TO date fields (each end carrying the other along). Direction 1
    /// retired all three: between days is a mode of ONE popover, nothing arms
    /// until a day is pressed, and a run is two presses on the month grid. The
    /// subject stands — the door's own acts make a run of days and never an
    /// empty one — driven through the popover's own `ask`/`press`, the
    /// closures its mode row and cells run.
    @Test func betweenDaysTwoPressesMakeTheRunAndNeverAnEmptyOne() throws {
        let now = try #require(DateFormatter.variorumISO8601.date(from: "2026-09-17T12:00:00.000Z"))
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        var picked: [LibraryDayRange] = []
        let closed = popover(range: nil, now: now, calendar: calendar, onPick: { picked.append($0) })
        closed.ask(.between)
        #expect(picked.isEmpty, "between days arms nothing by itself (it armed today at once on 13o)")
        closed.press("2026-09-01")
        closed.press("2026-09-14")
        #expect(picked == [LibraryDayRange(day: "2026-09-01"),
                           LibraryDayRange(first: "2026-09-01", last: "2026-09-14")],
                "the first press arms its day, the second the run")

        let armed = popover(
            range: LibraryDayRange(first: "2026-09-10", last: "2026-09-14"), now: now,
            calendar: calendar, onPick: { picked.append($0) })
        picked = []
        armed.press("2026-09-20")
        armed.press("2026-09-05")
        #expect(picked.last == LibraryDayRange(first: "2026-09-05", last: "2026-09-20"),
                "pressed backwards, the run is put in order — never empty")
        armed.ask(.oneDay)
        armed.press("2026-09-10")
        #expect(picked.last == LibraryDayRange(day: "2026-09-10"), "on a day narrows to one pressed day")
    }

    // MARK: - The range reaches the listing

    @Test func aRangeWithNoWordsIsTheWholeSetOfItsDays() async throws {
        try await withTravellingLibrary { session, clock, model in
            let today = clock.current
            var made: [String] = []
            for back in [4, 3, 1, 0] {
                clock.set(today.addingTimeInterval(-Double(back) * 86_400))
                let note = try session.operations.createPost(title: "note \(back)")
                _ = try session.operations.newBlock(in: note.id, text: "words")
                made.append(note.id)
            }
            clock.set(today)
            let from = day(of: today.addingTimeInterval(-3 * 86_400))
            let to = day(of: today.addingTimeInterval(-1 * 86_400))
            // JUSTIFIED EDIT (VX-87, direction 1): the run is made by the
            // popover's two presses (it was the 13o TO field's binding).
            var picked: LibraryDayRange?
            let door = popover(range: nil, now: today, onPick: { picked = $0 })
            door.ask(.between)
            door.press(from)
            door.press(to)
            model.setEditedRange(try #require(picked))
            await model.search()
            #expect(Set(model.noteHits.map(\.id)) == [made[1], made[2]],
                    "the notes edited on ANY day of the run — and only them")
            #expect(!model.notesHaveMore, "a day's answer is a SET — never a page")
            #expect(model.rangeForEmptyAnswer == picked)

            model.setEditedRange(nil)
            await model.search()
            #expect(model.noteHits.count == 4, "any day lists every note again")
        }
    }

    @Test func withWordsTheRangeNarrowsTheAnswerSheet() async throws {
        try await withTravellingLibrary { session, clock, model in
            let today = clock.current
            clock.set(today.addingTimeInterval(-5 * 86_400))
            let old = try session.operations.createPost(title: "harbor old")
            _ = try session.operations.newBlock(in: old.id, text: "the harbor lights")
            clock.set(today)
            let fresh = try session.operations.createPost(title: "harbor fresh")
            _ = try session.operations.newBlock(in: fresh.id, text: "the harbor fog")

            model.query = "harbor "
            await model.search()
            #expect(Set(model.searchState.groups.map(\.homeID)) == [old.id, fresh.id])

            model.setEditedRange(LibraryDayRange(
                first: day(of: today.addingTimeInterval(-1 * 86_400)), last: day(of: today)))
            await model.search()
            #expect(model.isSearching, "words keep the answer sheet")
            #expect(model.searchState.groups.map(\.homeID) == [fresh.id],
                    "the range is the AST's day filter (D5)")
            #expect(model.searchState.counts?.living.notes == 1,
                    "the band's numbers are the whole question's — the range included")
        }
    }

    // MARK: - The words

    @Test func theChipAndTheEmptyAnswerSayTheRun() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let now = try #require(DateFormatter.variorumISO8601.date(from: "2026-09-17T12:00:00.000Z"))
        let one = try #require(LibraryDayRange(day: "2026-09-09"))
        let run = try #require(LibraryDayRange(first: "2026-09-01", last: "2026-09-14"))
        #expect(LibraryDayFace.chipLabel(one, now: now, calendar: calendar) == "edited on Sep 9")
        #expect(LibraryDayFace.chipLabel(run, now: now, calendar: calendar)
                == "edited Sep 1 \u{2013} Sep 14")
        #expect(LibraryDayFace.emptyAnswer(range: run, now: now, calendar: calendar).headline
                == "No note's last edit or savepoint falls between Sep 1 and Sep 14.")
        #expect(LibraryDayFace.emptyAnswer(range: one, now: now, calendar: calendar)
                == LibraryDayFace.emptyAnswer(day: "2026-09-09", now: now, calendar: calendar),
                "one day says exactly what it always said")
        // JUSTIFIED EDIT (VX-87): R-13o-13's "when" and "any day" stand; the
        // menu's "on a day… · between days…" became direction 1's MODE ROW
        // (R-VX83-2, the mockup's own words), and a mode opens nothing more,
        // so the ellipses left with the menu.
        #expect(LibraryDayFace.closedLabel == "when" && LibraryDayFace.anyDay == "any day"
                && LibraryDayFace.onADay == "on a day"
                && LibraryDayFace.betweenDays == "between days",
                "her wording: R-13o-13's door, direction 1's mode row")
    }
}
