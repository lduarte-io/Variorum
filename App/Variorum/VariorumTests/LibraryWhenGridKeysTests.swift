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
import Observation
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

/// The real presenter's driver (VX-98's walk W10): SwiftUI's own `.popover`.
@MainActor
@Observable
final class WhenPopoverDriver {
    var shown = false
}

/// **The door's real shape:** an anchor in the PARENT window presenting the
/// face WITH its keys (`keyed`) through SwiftUI's `.popover` — whose window
/// AppKit makes a CHILD of the parent, the parent keeping key status (VX-179's
/// F-W-4 measurement, `notes/plans/fixes/vx-179-comment-polish.md`).
private struct WhenPopoverAnchor: View {
    @Bindable var driver: WhenPopoverDriver
    let face: LibraryWhenPopover

    var body: some View {
        Text("when").frame(width: 120, height: 40)
            .popover(isPresented: $driver.shown, arrowEdge: .bottom) { face.keyed }
            .frame(width: 300, height: 200)
    }
}

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

    /// The press → anchor seam, at the brain: a mouse press hands the keys
    /// back, and the next arrow lands on the anchor the door hands in — the
    /// ARMED range it now reads (the door passes `model.editedRange`, re-read
    /// on every render), not the range the popover opened with.
    @Test func afterAClickTheNextArrowLandsOnTheArmedDayTheDoorHandsIn() throws {
        let october = LibraryWhenMonth(year: 2026, month: 10)
        let today = "2026-10-07"
        var brain = LibraryWhenDoorBrain.opening(range: nil)
        _ = brain.moveKey(by: 1, showing: october, range: nil, today: today)
        _ = brain.moveKey(by: 5, showing: october, range: nil, today: today)
        #expect(brain.keyDay == "2026-10-12")
        // (Mutating calls stay OUT of the expectation macros — their
        // expansion takes the value immutably.)
        let pressed = brain.press("2026-10-20")
        let armed = try #require(pressed)
        #expect(brain.keyDay == nil, "the mouse's press hands the keys back")

        var fresh = brain
        let shown = fresh.moveKey(by: -1, showing: october, range: armed, today: today)
        #expect(shown == october)
        #expect(fresh.keyDay == "2026-10-20", "the next arrow lands on the armed day")
        // The anchor is the range HANDED IN: a stale nil would land on today.
        var stale = brain
        _ = stale.moveKey(by: -1, showing: october, range: nil, today: today)
        #expect(stale.keyDay == today)
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
        let now: Date
        let onPick: (LibraryDayRange) -> Void
        var keyDay: String? { brain.value.keyDay }
        var shown: LibraryWhenMonth { month.value }

        /// **The door's re-render after a pick:** the face is built again with
        /// the armed `range` (the door hands it `model.editedRange`, which
        /// `onPick` just set) over the SAME two bindings — the road the app's
        /// popover content takes, and the key monitor's `updateNSView` with it.
        @MainActor
        func rendered(range: LibraryDayRange?) -> Built {
            LibraryWhenGridKeysPopoverTests.built(
                range: range, now: now, brain: brain, month: month, onPick: onPick)
        }
    }

    /// The face over the given boxed bindings.
    fileprivate static func built(
        range: LibraryDayRange?, now: Date, brain: Box<LibraryWhenDoorBrain>,
        month: Box<LibraryWhenMonth>, onPick: @escaping (LibraryDayRange) -> Void
    ) -> Built {
        let view = LibraryWhenPopover(
            tokens: .resolve(voice: .terminal, dark: false), range: range, now: now, calendar: utc,
            firstWeekday: 2, locale: Locale(identifier: "en_US"),
            brain: Binding(get: { brain.value }, set: { brain.value = $0 }),
            month: Binding(get: { month.value }, set: { month.value = $0 }),
            onPick: onPick, onClear: {})
        return Built(view: view, brain: brain, month: month, now: now, onPick: onPick)
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
        return built(range: range, now: now, brain: brain, month: month, onPick: onPick)
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
        // on the day it armed — once the door has re-rendered the face with
        // the armed range (`onPick` → `model.editedRange` → the presented
        // content again). The face built before the pick still holds the range
        // it opened with (nil); asking IT would anchor on today, which is what
        // this cell measured before the harness took the door's road.
        open.view.press("2026-10-12")
        #expect(open.keyDay == nil, "the mouse's press hands the keys back")
        #expect(picked == [try #require(LibraryDayRange(day: "2026-10-12"))])
        let armed = open.rendered(range: picked.last)
        armed.view.moveKey(by: -1)
        #expect(armed.keyDay == "2026-10-12", "the next arrow lands on the armed day")
        #expect(armed.shown == LibraryWhenMonth(year: 2026, month: 10))
    }

    // MARK: - The door, in its REAL presentation (the walk's W10)

    /// The comment panel's proven key road (`CommentTextAreaTests`): post,
    /// then let the app's own dispatch run (local monitors see the key in
    /// `sendEvent`).
    private static func turns(_ count: Int = 20) async {
        for _ in 0..<count {
            while let event = NSApp.nextEvent(
                matching: [.keyDown, .leftMouseDown, .leftMouseUp], until: nil,
                inMode: .default, dequeue: true)
            {
                NSApp.sendEvent(event)
            }
            await Task.yield()
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    private static func post(_ keyCode: UInt16, _ characters: String, to window: NSWindow) async {
        if let event = NSEvent.keyEvent(
            with: .keyDown, location: .zero, modifierFlags: [],
            timestamp: ProcessInfo.processInfo.systemUptime, windowNumber: window.windowNumber,
            context: nil, characters: characters, charactersIgnoringModifiers: characters,
            isARepeat: false, keyCode: keyCode)
        {
            NSApp.postEvent(event, atStart: false)
        }
        await turns()
    }

    /// **W10's state, modelled (RED ON OLD — VX-98's walk).** The Library's
    /// search field holds the caret in the MAIN window; `when ▾` opens the
    /// face in SwiftUI's own `.popover`, whose window is a child of the main
    /// one — and the main window stays KEY, so the keyboard's events are
    /// ADDRESSED TO THE PARENT (VX-179's F-W-4). Keys posted to the parent:
    /// → shows the keyboard's day, → moves it, ⏎ presses it — and the field
    /// keeps the parent's keyboard throughout (the grid never takes the caret).
    /// RED ON OLD: the monitor claimed only keys addressed to its OWN window,
    /// so it never saw one of these (exactly the walk: no ring, no movement,
    /// the sentence unchanged) — three issues, the first three expectations
    /// after the premises. The earlier mounted pin passed because its rig made
    /// the face's own window key, which the live popover never is.
    /// The dismissal leg is a GUARD (green on both trees): a dismissed
    /// popover's face is never torn down, and it must never claim the main
    /// window's keys afterwards — the arrow is the field's again.
    @Test func keysAddressedToTheKeyParentReachTheGridAndTheFieldKeepsTheCaret() async throws {
        var picked: [LibraryDayRange] = []
        let open = Self.popover(range: nil, now: try Self.now(), onPick: { picked.append($0) })
        let driver = WhenPopoverDriver()
        let parent = NSWindow(
            contentRect: NSRect(x: -20_000, y: -20_000, width: 320, height: 240),
            styleMask: [.titled], backing: .buffered, defer: false)
        parent.isReleasedWhenClosed = false
        parent.alphaValue = 0
        // A plain container — the anchor's host and the field side by side
        // (never a subview added into a hosting view).
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 320, height: 240))
        let hosting = NSHostingView(rootView: WhenPopoverAnchor(driver: driver, face: open.view))
        hosting.frame = NSRect(x: 0, y: 40, width: 320, height: 200)
        let field = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        field.stringValue = "harbour"
        container.addSubview(hosting)
        container.addSubview(field)
        parent.contentView = container
        let before = Set(NSApp.windows.map(ObjectIdentifier.init))
        parent.orderFront(nil)  // off every display
        defer {
            driver.shown = false
            parent.orderOut(nil)
            parent.contentView = nil
            parent.close()
        }
        parent.makeFirstResponder(field)
        await Self.turns()
        let editor = try #require(parent.firstResponder as? NSTextView,
                                  "premise: the search field's stand-in holds the parent's keyboard")
        editor.setSelectedRange(NSRange(location: 7, length: 0))

        driver.shown = true
        await Self.turns(60)
        let popoverWindow = try #require(NSApp.windows.first {
            !before.contains(ObjectIdentifier($0)) && $0 !== parent && $0.isVisible
        }, "premise: the popover is up")
        popoverWindow.alphaValue = 0
        try #require(popoverWindow.parent === parent,
                     "premise: the popover's window is a CHILD of the window it hangs from")
        try #require(NSApp.keyWindow == nil || NSApp.keyWindow === parent,
                     "premise: the parent is key (or the inactive host has none) — never the popover's own window")

        await Self.post(LibraryWhenGridKeys.rightArrowKeyCode, "\u{F703}", to: parent)
        #expect(open.keyDay == "2026-10-07", "→ addressed to the key parent reached the grid: today's ring")
        await Self.post(LibraryWhenGridKeys.rightArrowKeyCode, "\u{F703}", to: parent)
        #expect(open.keyDay == "2026-10-08", "→ again moved it")
        await Self.post(LibraryWhenGridKeys.returnKeyCode, "\r", to: parent)
        #expect(picked == [try #require(LibraryDayRange(day: "2026-10-08"))], "⏎ pressed the keyboard's day")
        #expect(parent.firstResponder === editor, "the grid never took the keyboard: the field keeps the caret")
        #expect(field.stringValue == "harbour", "…and its words")

        // GUARD — the dismissed popover's face stays alive, and listens no more.
        let held = open.keyDay
        driver.shown = false
        await Self.turns(40)
        let caret = editor.selectedRange().location
        try #require(caret > 0, "premise: the caret can move left")
        await Self.post(LibraryWhenGridKeys.leftArrowKeyCode, "\u{F702}", to: parent)
        #expect(open.keyDay == held, "a dismissed popover's grid takes no key")
        #expect(parent.firstResponder === editor && editor.selectedRange().location == caret - 1,
                "…the arrow is the field's again")
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
