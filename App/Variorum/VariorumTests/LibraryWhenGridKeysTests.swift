//
//  LibraryWhenGridKeysTests.swift
//  VariorumTests
//
//  **VX-98 (the VX-819 run, batch 3) — the `when` popover's month grid takes
//  the arrow keys** (P-VX83-B3's deferral, R-VX83-8: *"yeah no arrow key day
//  navigation in v1 is fine - make a linear ticket for that item"*). An
//  Improvement: these are BUILD pins (the keys did not exist — nothing to be
//  red against). What they hold:
//
//  - THE RULE (pure): ← → a day, ↑ ↓ a week, ⏎ / the keypad's enter presses;
//    chords and every other key are someone else's, and nothing is the grid's
//    while a text field holds the keyboard;
//  - THE KEYBOARD'S DAY: the first arrow lands ON the anchor (the armed day
//    when shown, else today, else the month's first) — every later one moves
//    it; past the month's edge the shown month follows (the system picker's
//    crossing, PROVISIONAL P-819-B3b); ‹ › carry it into the month shown;
//  - THE ARMED-SENTENCE LAW, untouched: no move arms anything — only ⏎ on a
//    focused day, through `press`'s own road; ⏎ on an untouched grid is not
//    taken and arms nothing;
//  - THE DOOR, mounted: the popover's face WITH its keys (`keyed`, what the
//    door presents) answers keys sent to its window, swallows only its own,
//    and yields every key to a text field in charge.
//

import AppKit
import Foundation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@Suite("VX-98 — the when grid's keys: the rule")
struct LibraryWhenGridKeysRuleTests {
    private typealias Keys = LibraryWhenGridKeys

    @Test func theKeysAreThePlainArrowsAndReturnAndNothingElse() {
        #expect(Keys.key(keyCode: 123, modifiers: [], textIsFirstResponder: false) == .move(-1))
        #expect(Keys.key(keyCode: 124, modifiers: [], textIsFirstResponder: false) == .move(1))
        #expect(Keys.key(keyCode: 126, modifiers: [], textIsFirstResponder: false) == .move(-7))
        #expect(Keys.key(keyCode: 125, modifiers: [], textIsFirstResponder: false) == .move(7))
        #expect(Keys.key(keyCode: 36, modifiers: [], textIsFirstResponder: false) == .press)
        #expect(Keys.key(keyCode: 76, modifiers: [], textIsFirstResponder: false) == .press)
        // An arrow's own flags are not a chord.
        #expect(Keys.key(keyCode: 124, modifiers: [.numericPad, .function], textIsFirstResponder: false)
                == .move(1))
        // A chord is never the grid's.
        for chord: NSEvent.ModifierFlags in [.command, .option, .control, .shift] {
            #expect(Keys.key(keyCode: 124, modifiers: chord, textIsFirstResponder: false) == nil)
            #expect(Keys.key(keyCode: 36, modifiers: chord, textIsFirstResponder: false) == nil)
        }
        // Esc (the popover's close), space, tab, a letter: someone else's.
        for other: UInt16 in [53, 49, 48, 0] {
            #expect(Keys.key(keyCode: other, modifiers: [], textIsFirstResponder: false) == nil)
        }
        // A text field in charge owns every key.
        #expect(Keys.key(keyCode: 124, modifiers: [], textIsFirstResponder: true) == nil)
        #expect(Keys.key(keyCode: 36, modifiers: [], textIsFirstResponder: true) == nil)
    }

    @Test func theKeyboardFirstLandsOnTheArmedDayThenTodayThenTheMonthsFirst() throws {
        let october = LibraryWhenMonth(year: 2026, month: 10)
        let today = "2026-10-07"
        #expect(Keys.anchor(in: october, range: try #require(LibraryDayRange(day: "2026-10-20")), today: today)
                == "2026-10-20", "the armed day, when the grid shows it")
        #expect(Keys.anchor(
            in: october, range: try #require(LibraryDayRange(first: "2026-10-03", last: "2026-11-02")),
            today: today) == "2026-10-03", "a run's first day")
        #expect(Keys.anchor(in: october, range: nil, today: today) == today, "nothing armed: today")
        #expect(Keys.anchor(in: october, range: try #require(LibraryDayRange(day: "2026-09-20")), today: today)
                == today, "an armed day in another month: today")
        #expect(Keys.anchor(in: LibraryWhenMonth(year: 2026, month: 12), range: nil, today: today)
                == "2026-12-01", "neither shown: the month's first day")
    }

    @Test func theSameDayInAnotherMonthClampsToItsLength() {
        #expect(Keys.sameDay("2026-01-31", in: LibraryWhenMonth(year: 2026, month: 2)) == "2026-02-28")
        #expect(Keys.sameDay("2028-01-31", in: LibraryWhenMonth(year: 2028, month: 2)) == "2028-02-29")
        #expect(Keys.sameDay("2026-05-31", in: LibraryWhenMonth(year: 2026, month: 6)) == "2026-06-30")
        #expect(Keys.sameDay("2026-03-15", in: LibraryWhenMonth(year: 2026, month: 4)) == "2026-04-15")
    }
}

@MainActor
@Suite("VX-98 — the when grid's keys: the popover's own road", .serialized)
struct LibraryWhenGridKeysPopoverTests {
    final class Box<Value> {
        var value: Value
        init(_ value: Value) { self.value = value }
    }

    private static var utc: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    /// 2026-10-07, noon UTC — the when-door suite's own "now".
    private static func now() throws -> Date {
        try #require(DateFormatter.variorumISO8601.date(from: "2026-10-07T12:00:00.000Z"))
    }

    struct Built {
        let view: LibraryWhenPopover
        let brain: Box<LibraryWhenDoorBrain>
        let month: Box<LibraryWhenMonth>
        var keyDay: String? { brain.value.keyDay }
        var shown: LibraryWhenMonth { month.value }
    }

    /// The popover as the door builds it (`openingState`), its two bindings
    /// boxed so the pins read what its acts did.
    private static func popover(
        range: LibraryDayRange?, now: Date, onPick: @escaping (LibraryDayRange) -> Void = { _ in }
    ) -> Built {
        let opening = LibraryWhenDoor.openingState(
            range: range, today: JournalDay.dayString(from: now, calendar: utc))
        let brain = Box(opening.brain)
        let month = Box(opening.month ?? LibraryWhenMonth(year: 2026, month: 10))
        let view = LibraryWhenPopover(
            tokens: .resolve(voice: .terminal, dark: false), range: range, now: now, calendar: utc,
            firstWeekday: 2, locale: Locale(identifier: "en_US"),
            brain: Binding(get: { brain.value }, set: { brain.value = $0 }),
            month: Binding(get: { month.value }, set: { month.value = $0 }),
            onPick: onPick, onClear: {})
        return Built(view: view, brain: brain, month: month)
    }

    @Test func theFirstArrowLandsOnTodayAndEveryLaterOneMovesTheKeyboardsDay() throws {
        var picked: [LibraryDayRange] = []
        let open = Self.popover(range: nil, now: try Self.now(), onPick: { picked.append($0) })
        #expect(open.keyDay == nil, "nothing is focused before the keys are used")

        open.view.moveKey(by: 1)
        #expect(open.keyDay == "2026-10-07", "the first arrow shows where the keys stand: today")
        open.view.moveKey(by: 1)
        #expect(open.keyDay == "2026-10-08")
        open.view.moveKey(by: 7)
        #expect(open.keyDay == "2026-10-15")
        open.view.moveKey(by: -7)
        open.view.moveKey(by: -1)
        #expect(open.keyDay == "2026-10-07")
        #expect(open.shown == LibraryWhenMonth(year: 2026, month: 10))
        #expect(picked.isEmpty, "the armed-sentence law: no move arms anything")
    }

    @Test func anArrowPastTheMonthsEdgeShowsTheNextMonth() throws {
        let open = Self.popover(range: LibraryDayRange(day: "2026-10-31"), now: try Self.now())
        open.view.moveKey(by: 1)
        #expect(open.keyDay == "2026-10-31", "the first arrow lands on the armed day")
        open.view.moveKey(by: 1)
        #expect(open.keyDay == "2026-11-01")
        #expect(open.shown == LibraryWhenMonth(year: 2026, month: 11), "the month follows the keyboard")
        open.view.moveKey(by: -1)
        #expect(open.shown == LibraryWhenMonth(year: 2026, month: 10), "and back")
        // A week down across the year's end.
        let december = Self.popover(range: LibraryDayRange(day: "2026-12-28"), now: try Self.now())
        december.view.moveKey(by: 7)
        december.view.moveKey(by: 7)
        #expect(december.keyDay == "2027-01-04")
        #expect(december.shown == LibraryWhenMonth(year: 2027, month: 1))
        // A week up across a month's start.
        let early = Self.popover(range: LibraryDayRange(day: "2026-10-03"), now: try Self.now())
        early.view.moveKey(by: -7)
        early.view.moveKey(by: -7)
        #expect(early.keyDay == "2026-09-26")
        #expect(early.shown == LibraryWhenMonth(year: 2026, month: 9))
    }

    @Test func returnPressesTheKeyboardsDayAndNothingWhileNoneIsFocused() throws {
        var picked: [LibraryDayRange] = []
        let open = Self.popover(range: nil, now: try Self.now(), onPick: { picked.append($0) })
        #expect(open.view.pressKey() == false, "⏎ on an untouched grid is not taken")
        #expect(picked.isEmpty, "…and arms nothing")

        open.view.moveKey(by: 1)
        open.view.moveKey(by: 1)
        #expect(open.view.pressKey() == true)
        #expect(picked == [try #require(LibraryDayRange(day: "2026-10-08"))], "on a day: that day")
        #expect(open.keyDay == "2026-10-08", "the keys stay where they pressed")

        // Between days: the keyboard's two presses make the run, as two clicks do.
        picked.removeAll()
        open.view.ask(.between)
        #expect(picked.isEmpty, "the mode row arms nothing")
        #expect(open.view.pressKey())
        open.view.moveKey(by: 7)
        open.view.moveKey(by: 1)
        #expect(open.view.pressKey())
        #expect(picked == [
            try #require(LibraryDayRange(day: "2026-10-08")),
            try #require(LibraryDayRange(first: "2026-10-08", last: "2026-10-16")),
        ])
        #expect(open.keyDay == "2026-10-16", "after the run, the keys are where the run ended")
    }

    @Test func theMonthStepsCarryTheKeysAndAClickHandsThemBack() throws {
        var picked: [LibraryDayRange] = []
        let open = Self.popover(range: nil, now: try Self.now(), onPick: { picked.append($0) })
        open.view.step(1)
        #expect(open.keyDay == nil, "no keyboard day: a step carries nothing")
        open.view.step(-1)

        open.view.moveKey(by: 1)  // today, Oct 7
        for _ in 0..<24 { open.view.moveKey(by: 1) }
        #expect(open.keyDay == "2026-10-31")
        open.view.step(1)
        #expect(open.shown == LibraryWhenMonth(year: 2026, month: 11))
        #expect(open.keyDay == "2026-11-30", "› carries the keys into November, clamped")
        open.view.step(-1)
        #expect(open.keyDay == "2026-10-30", "‹ carries them back on the same day of the month")
        #expect(picked.isEmpty, "the month steps arm nothing")

        // A click is the mouse's: it arms, and the keyboard's next arrow lands
        // on the day it armed.
        open.view.press("2026-10-12")
        #expect(open.keyDay == nil, "the mouse's press hands the keys back")
        #expect(picked == [try #require(LibraryDayRange(day: "2026-10-12"))])
        open.view.moveKey(by: -1)
        #expect(open.keyDay == "2026-10-12", "the next arrow lands on the armed day")
    }

    // MARK: - The door, mounted

    private static func key(_ keyCode: UInt16, _ characters: String, window: NSWindow,
                            modifiers: NSEvent.ModifierFlags = []) -> NSEvent? {
        NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: modifiers,
            timestamp: ProcessInfo.processInfo.systemUptime,
            windowNumber: window.windowNumber, context: nil,
            characters: characters, charactersIgnoringModifiers: characters,
            isARepeat: false, keyCode: keyCode)
    }

    /// The face WITH its keys — what the door presents — in a window of its
    /// own: an arrow and ⏎ sent to that window move and press the keyboard's
    /// day; a chord passes; with a text field in charge, no key is the grid's.
    @Test func thePresentedFaceAnswersItsWindowsKeysAndYieldsThemToAField() async throws {
        var picked: [LibraryDayRange] = []
        let open = Self.popover(range: nil, now: try Self.now(), onPick: { picked.append($0) })
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 80, height: 22))
        let rig = BlocksWorkbenchFaceTests.Rig(open.view.keyed, width: 320, height: 420)
        defer { rig.close() }
        rig.hosting.addSubview(field)
        rig.window.makeFirstResponder(nil)
        await rig.turn()

        let right = try #require(Self.key(LibraryWhenGridKeys.rightArrowKeyCode, "\u{F703}", window: rig.window))
        NSApp.sendEvent(right)
        await rig.turn()
        #expect(open.keyDay == "2026-10-07", "→ sent to the popover's window reached the grid")
        NSApp.sendEvent(right)
        await rig.turn()
        #expect(open.keyDay == "2026-10-08")

        let chord = try #require(Self.key(
            LibraryWhenGridKeys.rightArrowKeyCode, "\u{F703}", window: rig.window, modifiers: .command))
        NSApp.sendEvent(chord)
        await rig.turn()
        #expect(open.keyDay == "2026-10-08", "a chord is not the grid's")

        let enter = try #require(Self.key(LibraryWhenGridKeys.returnKeyCode, "\r", window: rig.window))
        NSApp.sendEvent(enter)
        await rig.turn()
        #expect(picked == [try #require(LibraryDayRange(day: "2026-10-08"))], "⏎ pressed the keyboard's day")

        // A text field in charge: the arrow is the field's.
        rig.window.makeFirstResponder(field)
        _ = await rig.poll(timeout: 2) { rig.window.firstResponder is NSTextView }
        NSApp.sendEvent(right)
        await rig.turn()
        #expect(open.keyDay == "2026-10-08", "with a text field holding the keyboard the grid takes no key")
        #expect(picked.count == 1)
    }
}
