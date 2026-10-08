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
//  The §P1 ruling (A — the custom month grid) adds, by its conditions:
//  - THE GRID'S LAYOUT as a pure rule (six fixed rows, her week order, the
//    neighbouring months' days, the run's marks) and the HAND-WRITTEN
//    VoiceOver words each cell speaks;
//  - THE POPOVER'S OWN ROAD — its cells, mode row, ‹ › and `any day` run
//    `press` / `ask` / `step` / `clear`, which the pins drive;
//  - THE FACE'S GEOMETRY, rendered offscreen in both voices, light and dark
//    (one width, one height whatever is armed) — and written as PNGs for the
//    implementer's spacing check. Those renders are NOT the real-app captures
//    R-VX83-2 names (PENDING-on-grant — the U-B record).
//

import AppKit
import Dependencies
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-87 — the when door, direction 1 (the sentence, no silent arm, the two-press run, the grid)", .serialized)
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
            model.setEditedRange(first)  // nil would list every note — the next expectation says so
            await model.search()
            #expect(model.noteHits.map(\.id) == [made[2]], "the first press: its own day, already armed")

            let second = brain.press(day(3))
            model.setEditedRange(second)
            await model.search()
            #expect(Set(model.noteHits.map(\.id)) == [made[1], made[2]],
                    "the second press (backwards): the run, and only its days")
            #expect(model.editedRange == LibraryDayRange(first: day(3), last: day(1)))
        }
    }

    // MARK: - The grid's layout (the §P1 ruling's condition 3 — a pure rule)

    /// October 2026 begins on a Thursday. In a MONDAY week the grid starts on
    /// Mon Sep 28 — exactly the mockup's first row (28 29 30 · 1 2 3 4) — and
    /// in a Sunday week on Sun Sep 27; six rows of seven, always.
    @Test func theMonthIsSixRowsInHerWeekOrderWithTheNeighboursFaint() throws {
        let october = LibraryWhenMonth(year: 2026, month: 10)
        let monday = LibraryWhenGrid.cells(of: october, firstWeekday: 2, calendar: utc)
        #expect(monday.count == 42, "six rows of seven, always")
        #expect(monday.first == .init(day: "2026-09-28", number: 28, inMonth: false))
        #expect(monday[3] == .init(day: "2026-10-01", number: 1, inMonth: true))
        #expect(monday[33] == .init(day: "2026-10-31", number: 31, inMonth: true))
        #expect(monday[34] == .init(day: "2026-11-01", number: 1, inMonth: false))
        #expect(monday.last?.day == "2026-11-08")

        let sunday = LibraryWhenGrid.cells(of: october, firstWeekday: 1, calendar: utc)
        #expect(sunday.first?.day == "2026-09-27" && sunday[4].day == "2026-10-01")
        #expect(LibraryWhenGrid.cells(of: october, firstWeekday: 9, calendar: utc) == sunday,
                "a week start outside 1…7 reads as Sunday")

        let english = Locale(identifier: "en_US")
        #expect(LibraryWhenGrid.weekdayInitials(firstWeekday: 2, calendar: utc, locale: english)
                == ["M", "T", "W", "T", "F", "S", "S"], "the mockup's own row")
        #expect(LibraryWhenGrid.weekdayInitials(firstWeekday: 1, calendar: utc, locale: english)
                == ["S", "M", "T", "W", "T", "F", "S"])
        #expect(LibraryWhenGrid.monthTitle(october, calendar: utc, locale: english) == "October 2026")

        // February 2026 fills four rows from a Sunday — the grid still draws six.
        let february = LibraryWhenGrid.cells(
            of: LibraryWhenMonth(year: 2026, month: 2), firstWeekday: 1, calendar: utc)
        #expect(february.count == 42 && february.first?.day == "2026-02-01")
        #expect(february.filter(\.inMonth).count == 28)
    }

    /// The days are the filter's calendar's (Gregorian, her zone — condition
    /// 4), stepped from each day's NOON: across a daylight-saving change every
    /// key is there once, in order.
    @Test func everyDayAppearsOnceAcrossADaylightSavingChange() throws {
        var denver = Calendar(identifier: .gregorian)
        denver.timeZone = try #require(TimeZone(identifier: "America/Denver"))
        for month in [3, 11] {  // 2026-03-08 and 2026-11-01 are the changes
            let cells = LibraryWhenGrid.cells(
                of: LibraryWhenMonth(year: 2026, month: month), firstWeekday: 1, calendar: denver)
            let keys = cells.map(\.day)
            #expect(Set(keys).count == 42, "no day doubled or skipped (month \(month))")
            #expect(keys == keys.sorted(), "in order")
            #expect(keys.allSatisfy { JournalDay.isValid($0) })
        }
    }

    @Test func monthsNormalizeAndOpenOnTheArmedRunsStart() throws {
        #expect(LibraryWhenMonth(year: 2026, month: 13) == LibraryWhenMonth(year: 2027, month: 1))
        #expect(LibraryWhenMonth(year: 2026, month: 1).adding(months: -1) == LibraryWhenMonth(year: 2025, month: 12))
        #expect(LibraryWhenMonth(dayKey: "2026-02-30") == nil)
        let run = try #require(LibraryDayRange(first: "2026-09-28", last: "2026-10-03"))
        #expect(LibraryWhenMonth.opening(range: run, today: "2026-10-07") == LibraryWhenMonth(year: 2026, month: 9),
                "a run opens where it starts")
        #expect(LibraryWhenMonth.opening(range: nil, today: "2026-10-07") == LibraryWhenMonth(year: 2026, month: 10),
                "nothing armed opens on today's month")
    }

    @Test func aDayReadsAsTheRunsEndsOrItsBand() throws {
        let run = try #require(LibraryDayRange(first: "2026-10-01", last: "2026-10-06"))
        #expect(LibraryWhenGrid.mark("2026-10-01", in: run) == .runStart)
        #expect(LibraryWhenGrid.mark("2026-10-03", in: run) == .inRun)
        #expect(LibraryWhenGrid.mark("2026-10-06", in: run) == .runEnd)
        #expect(LibraryWhenGrid.mark("2026-10-07", in: run) == .none)
        #expect(LibraryWhenGrid.mark("2026-09-30", in: run) == .none)
        let one = try #require(LibraryDayRange(day: "2026-10-06"))
        #expect(LibraryWhenGrid.mark("2026-10-06", in: one) == .single)
        #expect(LibraryWhenGrid.mark("2026-10-05", in: one) == .none)
        #expect(LibraryWhenGrid.mark("2026-10-06", in: nil) == .none)
    }

    // MARK: - What VoiceOver says (the §P1 ruling's condition 1 — by hand, now)

    @Test func everyCellSpeaksItsDayInFullAndItsStanding() throws {
        let english = Locale(identifier: "en_US")
        let run = try #require(LibraryDayRange(first: "2026-10-01", last: "2026-10-06"))
        func spoken(_ day: String, _ range: LibraryDayRange?, today: String = "2026-10-07") throws
            -> LibraryWhenGrid.Spoken {
            let cell = try #require(LibraryWhenGrid.cells(
                of: LibraryWhenMonth(year: 2026, month: 10), firstWeekday: 1, calendar: utc)
                .first { $0.day == day })
            return LibraryWhenGrid.spoken(cell, range: range, today: today, calendar: utc, locale: english)
        }
        #expect(try spoken("2026-10-06", run, today: "2026-10-06")
                == .init(label: "Tuesday, October 6, 2026", value: "last day of the run, today", selected: true))
        #expect(try spoken("2026-10-01", run).value == "first day of the run")
        #expect(try spoken("2026-10-03", run) == .init(
            label: "Saturday, October 3, 2026", value: "in the run", selected: true))
        #expect(try spoken("2026-10-09", run) == .init(
            label: "Friday, October 9, 2026", value: "", selected: false))
        #expect(try spoken("2026-10-06", LibraryDayRange(day: "2026-10-06")).value == "chosen day")
        #expect(try spoken("2026-10-07", nil).value == "today")
    }

    // MARK: - The popover's own road

    private final class Box<Value> {
        var value: Value
        init(_ value: Value) { self.value = value }
    }

    private func popover(
        range: LibraryDayRange?, now: Date, tokens: VoiceTokens = .resolve(voice: .terminal, dark: false),
        month: Box<LibraryWhenMonth>? = nil,
        onPick: @escaping (LibraryDayRange) -> Void = { _ in }, onClear: @escaping () -> Void = {}
    ) -> (view: LibraryWhenPopover, brain: Box<LibraryWhenDoorBrain>, month: Box<LibraryWhenMonth>) {
        let opening = LibraryWhenDoor.openingState(
            range: range, today: JournalDay.dayString(from: now, calendar: utc))
        let brain = Box(opening.brain)
        let shown = month ?? Box(opening.month ?? LibraryWhenMonth(year: 2026, month: 10))
        let view = LibraryWhenPopover(
            tokens: tokens, range: range, now: now, calendar: utc, firstWeekday: 2,
            locale: Locale(identifier: "en_US"),
            brain: Binding(get: { brain.value }, set: { brain.value = $0 }),
            month: Binding(get: { shown.value }, set: { shown.value = $0 }),
            onPick: onPick, onClear: onClear)
        return (view, brain, shown)
    }

    /// The door's open computes its state and NOTHING else; the popover's
    /// mode row and ‹ › arm nothing; two presses between days arm the day,
    /// then the run; `any day` clears and forgets a waiting start.
    @Test func thePopoversOwnActsArmOnlyOnAPressedDay() throws {
        var picked: [LibraryDayRange] = []
        var cleared = 0
        let open = popover(
            range: nil, now: try now(), onPick: { picked.append($0) }, onClear: { cleared += 1 })
        #expect(open.month.value == LibraryWhenMonth(year: 2026, month: 10), "today's month")
        open.view.ask(.between)
        open.view.step(-1)
        open.view.step(1)
        #expect(picked.isEmpty && cleared == 0, "the mode row and the month steps arm nothing")
        #expect(open.month.value == LibraryWhenMonth(year: 2026, month: 10))

        open.view.press("2026-10-01")
        #expect(open.brain.value.waitsForRunEnd, "the foot's hint now asks for the last day")
        open.view.press("2026-10-06")
        #expect(picked == [LibraryDayRange(day: "2026-10-01"),
                           LibraryDayRange(first: "2026-10-01", last: "2026-10-06")])

        open.view.press("2026-10-09")
        open.view.clear()
        #expect(cleared == 1 && !open.brain.value.waitsForRunEnd,
                "any day clears, and the run's waiting start is forgotten")
    }

    // MARK: - The face's geometry, in every room (and the spacing renders)

    /// Where the renders land: the sandboxed test host's OWN temp directory
    /// (a write into the repo is denied — `ContextBarCaptureTests`' recorded
    /// lesson); the U-B record names the one `cp` that carries them out.
    private static let rendersDirectory = FileManager.default.temporaryDirectory
        .appendingPathComponent("vx83-when-face-renders")

    /// The card is ONE size whatever it says: the grid's width plus its
    /// margins, and the same height for nothing armed, one day and a run —
    /// in both voices, light and dark (six fixed rows, the sentence's two
    /// reserved lines). Each state is also written as a PNG for the
    /// implementer's spacing check (not the R-VX83-2 captures).
    @Test(arguments: [ThemeVoice.terminal, .study], [false, true])
    func theCardKeepsOneSizeInEveryRoom(voice: ThemeVoice, dark: Bool) throws {
        let tokens = VoiceTokens.resolve(voice: voice, dark: dark)
        let states: [(String, LibraryDayRange?, Bool)] = [
            ("nothing", nil, false),
            ("one-day", LibraryDayRange(day: "2026-10-06"), false),
            ("between", LibraryDayRange(first: "2026-10-01", last: "2026-10-06"), false),
            ("waiting", LibraryDayRange(day: "2026-10-01"), true),
        ]
        try FileManager.default.createDirectory(at: Self.rendersDirectory, withIntermediateDirectories: true)
        var sizes: [CGSize] = []
        for (name, range, waits) in states {
            let built = popover(range: range, now: try now(), tokens: tokens)
            if waits {
                built.view.ask(.between)
                built.view.press("2026-10-01")
            }
            let card = built.view
                .environment(\.colorScheme, dark ? .dark : .light)
                .padding(12)
                .background(tokens.room)
            let renderer = ImageRenderer(content: card)
            renderer.scale = 2
            let image = try #require(renderer.nsImage, "the face renders (\(name))")
            sizes.append(image.size)
            if let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff),
               let png = rep.representation(using: .png, properties: [:]) {
                let file = Self.rendersDirectory.appendingPathComponent(
                    "headless-\(voice)-\(dark ? "dark" : "light")-\(name).png")
                try png.write(to: file)
            }
        }
        let width = LibraryWhenMonthGrid.width + 2 * LibraryWhenPopover.padding + 24
        #expect(sizes.allSatisfy { abs($0.width - width) < 0.5 }, "one width: \(sizes)")

        // The card's width is FIXED, so a foot or a mode word that outgrew it
        // would be clipped, never widen the card — measured on their own
        // (the spacing renders caught a 22-letter hint overflowing Terminal's
        // card before it was shortened).
        for waits in [false, true] {
            let foot = ImageRenderer(content: LibraryWhenFoot(
                tokens: tokens, armed: true, waitsForRunEnd: waits, onClear: {}).fixedSize())
            let footWidth = try #require(foot.nsImage?.size.width)
            #expect(footWidth <= LibraryWhenMonthGrid.width,
                    "the foot fits the card (\(voice), waiting \(waits)): \(footWidth)")
        }
        for mode in LibraryWhenDoorBrain.Mode.allCases {
            let word = ImageRenderer(content: Text(tokens.chromeLabel(LibraryWhenPopover.word(mode)))
                .font(tokens.small).fontWeight(.semibold).fixedSize())
            let wordWidth = try #require(word.nsImage?.size.width)
            #expect(wordWidth <= LibraryWhenMonthGrid.width / 2 - 8,
                    "a mode word fits its half of the row (\(voice)): \(wordWidth)")
        }
        #expect(Set(sizes.map { $0.height.rounded() }).count == 1,
                "one height whatever is armed (\(voice), \(dark ? "dark" : "light")): \(sizes)")
        print("VX-87 face renders: \(Self.rendersDirectory.path)")
    }
}
