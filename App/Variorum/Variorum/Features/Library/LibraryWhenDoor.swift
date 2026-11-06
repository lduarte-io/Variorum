//
//  LibraryWhenDoor.swift
//  Variorum (Mac)
//
//  **VX-87 — the `when ▾` door rebuilt to her DIRECTION 1** (R-VX83-2, the
//  2026-10-07 sitting: *"I choose direction 1 on the calendar - but make sure
//  that the popover looks good"*; the mockup `notes/plans/mockups/
//  when-door.html` is the visual record). Her report, verbatim: *"I think
//  that the date selector is ugly and it's very unclear if there's
//  confirmation. the nested drop downs where a new dropdown appears is also a
//  big of an ugly ux experience."*
//
//  The cure is one surface: the press opens ONE popover — a mode row (on a
//  day · between days), a month grid, and the ARMED SENTENCE at its foot
//  ("Showing notes edited on Oct 6.") — so the confirmation sits under the
//  hand that made it. Nothing arms until a day is pressed (it superseded
//  P-13o-U2-9's arm-at-once FOR THIS DOOR — her "unclear if there's
//  confirmation" is the reason); Esc or a click outside keeps whatever the
//  sentence last said, because every press has already armed exactly that.
//
//  This file holds the door's BRAIN — pure, so the pins read the rule and the
//  face only renders it (P-9) — the DOOR (the `when ▾` press), and the
//  POPOVER's face; the month grid is its own file (`LibraryWhenMonthGrid` —
//  the orchestrator's §P1 ruling: A, a custom grid in the voice's tokens).
//  Every act a pin needs is a member of the popover (`press`, `ask`, `step`,
//  `clear`) — the closures its cells, mode row and words run — so a pin
//  drives the door's own road, never a hand-fed value (the 18h ladder's
//  R1-9).
//

import AppKit
import SwiftUI
import VariorumCore

// MARK: - The brain

/// **What a press inside the `when` popover DOES** (VX-87, direction 1).
///
/// The armed range itself is NOT here: it is the catalog model's
/// (`LibraryCatalogModel.editedRange`), and the popover reads it through the
/// door's `range` — so the sentence and the band's chip can never say two
/// different things. The brain holds only what the popover is in the middle
/// of: which question the mode row is asking, and — between days — the first
/// day of a run waiting for its last.
///
/// **The no-silent-arm rule is structural:** opening (`opening`) and the mode
/// row (`ask`) RETURN NOTHING a caller could arm; the one member that yields
/// a range is `press(_:)`, the act of touching a day — and `pressKey()`, the
/// same act on the day the keyboard stands on (VX-98). The keyboard's own
/// moves (`moveKey`, `followMonth`) yield no range either: a focused day is
/// never an armed one.
nonisolated struct LibraryWhenDoorBrain: Equatable, Sendable {
    /// The mode row's two questions.
    enum Mode: Hashable, CaseIterable, Sendable {
        /// **on a day** — a press arms that one day.
        case oneDay
        /// **between days** — the first press arms its day and waits; the
        /// second makes the run, first through last (any order).
        case between
    }

    private(set) var mode: Mode
    /// Between days: the day the last press began a run on, waiting for the
    /// run's last day. nil = the next press begins (or, on a day, picks).
    private(set) var runStart: String?
    /// **VX-98 — the day the KEYBOARD stands on** (the grid draws its mark),
    /// nil until an arrow is pressed: nothing reads as focused before the keys
    /// are used, and a mouse press hands the keys back to the anchor
    /// (PROVISIONAL P-819-B3a). Never armed — only `pressKey()` arms it.
    private(set) var keyDay: String?

    /// Whether the popover is waiting for a run's last day (the foot's hint
    /// says so).
    var waitsForRunEnd: Bool { mode == .between && runStart != nil }

    /// **Opening** — the mode the ARMED state reads in (a run opens on
    /// between days; one day, or nothing, on a day), and nothing arms: the
    /// shipped door's arm-at-once (P-13o-U2-9 — "today" armed by merely
    /// choosing a menu item) is exactly the silent arming her report names.
    static func opening(range: LibraryDayRange?) -> Self {
        LibraryWhenDoorBrain(mode: range.map { $0.isOneDay ? .oneDay : .between } ?? .oneDay)
    }

    private init(mode: Mode) {
        self.mode = mode
        self.runStart = nil
        self.keyDay = nil
    }

    /// **The mode row** — changes what the NEXT press means and arms
    /// nothing; a run waiting for its end forgets its start (the armed day
    /// that start already armed stays armed, and the sentence keeps saying
    /// it).
    mutating func ask(_ mode: Mode) {
        self.mode = mode
        runStart = nil
    }

    /// **A day pressed** — the ONE act that arms. Returns the range the door
    /// hands its `onPick`: on a day, that day; between days, the first press
    /// arms its own day (so Esc right after keeps exactly what the sentence
    /// says) and waits, the second arms the run from the waiting day to this
    /// one, put in order — and a third begins a fresh run. nil only for a key
    /// that is not a real day (a face draws what it has, never a guess).
    mutating func press(_ day: String) -> LibraryDayRange? {
        guard JournalDay.isValid(day) else { return nil }
        // VX-98: a press is the mouse's — the keyboard's mark goes, and its
        // next arrow lands on the anchor (the day just armed, when shown).
        keyDay = nil
        switch mode {
        case .oneDay:
            runStart = nil
            return LibraryDayRange(day: day)
        case .between:
            if let start = runStart {
                runStart = nil
                return LibraryDayRange(first: start, last: day)
            }
            runStart = day
            return LibraryDayRange(day: day)
        }
    }

    // MARK: VX-98 — the grid's keys (the rule: `LibraryWhenGridKeys`)

    /// **An arrow.** The FIRST lands the keyboard ON the anchor — the armed
    /// day when the grid shows it, else today when shown, else the shown
    /// month's first day — so she sees where the keys stand before they move
    /// (PROVISIONAL P-819-B3a); every later one moves it `days` calendar
    /// days. Returns the month the grid must show: the month FOLLOWS the
    /// keyboard past its edge, the system picker's way (PROVISIONAL
    /// P-819-B3b). Arms nothing.
    mutating func moveKey(
        by days: Int, showing month: LibraryWhenMonth, range: LibraryDayRange?, today: String
    ) -> LibraryWhenMonth {
        guard let current = keyDay else {
            keyDay = LibraryWhenGridKeys.anchor(in: month, range: range, today: today)
            return month
        }
        guard let moved = JournalDay.shifted(current, byDays: days),
              let movedMonth = LibraryWhenMonth(dayKey: moved)
        else { return month }
        keyDay = moved
        return movedMonth
    }

    /// **‹ / › moved the shown month** — a keyboard day left behind follows
    /// into it, on the same day of the month (clamped to its length: Jan 31 →
    /// Feb 28). No keyboard day, nothing to follow. Arms nothing.
    mutating func followMonth(_ month: LibraryWhenMonth) {
        guard let keyDay, LibraryWhenMonth(dayKey: keyDay) != month else { return }
        self.keyDay = LibraryWhenGridKeys.sameDay(keyDay, in: month)
    }

    /// **⏎ — the keyboard's PRESS:** `press(_:)` on the day the keys stand
    /// on (on a day: that day; between days: the run's first, then its last),
    /// and the keys stay where they are (the mouse's press hands them back;
    /// the keyboard's own never does). nil — and nothing armed — while no day
    /// is focused: ⏎ on an untouched grid is not a pick.
    mutating func pressKey() -> LibraryDayRange? {
        guard let day = keyDay else { return nil }
        let picked = press(day)
        keyDay = day
        return picked
    }
}

/// **VX-98 — the month grid's KEYS, as a pure rule** (her R-VX83-8 deferral,
/// now built): ← → move the keyboard's day by one, ↑ ↓ by a week, ⏎ (or the
/// keypad's enter) presses it. A chord is never the grid's, and nothing is
/// while a text field holds the keyboard (none lives in the popover today —
/// the guard keeps it so). The door is `LibraryWhenKeyMonitor`, scoped to the
/// popover's own window.
nonisolated enum LibraryWhenGridKeys {
    enum Key: Equatable, Sendable {
        /// Move the keyboard's day by this many calendar days.
        case move(Int)
        /// Press the keyboard's day.
        case press
    }

    static let leftArrowKeyCode: UInt16 = 123
    static let rightArrowKeyCode: UInt16 = 124
    static let downArrowKeyCode: UInt16 = 125
    static let upArrowKeyCode: UInt16 = 126
    static let returnKeyCode: UInt16 = 36
    static let keypadEnterKeyCode: UInt16 = 76

    static func key(
        keyCode: UInt16, modifiers: NSEvent.ModifierFlags, textIsFirstResponder: Bool
    ) -> Key? {
        guard !textIsFirstResponder else { return nil }
        // Arrows carry `.numericPad`/`.function` in their flags — only the
        // four chord modifiers make a key someone else's.
        guard modifiers.intersection([.command, .option, .control, .shift]).isEmpty else { return nil }
        switch keyCode {
        case leftArrowKeyCode: return .move(-1)
        case rightArrowKeyCode: return .move(1)
        case upArrowKeyCode: return .move(-7)
        case downArrowKeyCode: return .move(7)
        case returnKeyCode, keypadEnterKeyCode: return .press
        default: return nil
        }
    }

    /// Where the keyboard first lands in `month`: the armed day (a run's
    /// first) when the grid shows its month, else today when shown, else the
    /// month's first day.
    static func anchor(in month: LibraryWhenMonth, range: LibraryDayRange?, today: String) -> String {
        if let first = range?.first, LibraryWhenMonth(dayKey: first) == month { return first }
        if LibraryWhenMonth(dayKey: today) == month { return today }
        return month.firstDayKey
    }

    /// `day`'s day of the month in `month`, clamped to the month's length.
    static func sameDay(_ day: String, in month: LibraryWhenMonth) -> String {
        let number = Int(day.split(separator: "-").last ?? "") ?? 1
        for candidate in stride(from: min(max(number, 1), 31), through: 1, by: -1) {
            let key = String(format: "%04d-%02d-%02d", month.year, month.month, candidate)
            if JournalDay.isValid(key) { return key }
        }
        return month.firstDayKey
    }
}

// MARK: - The door

/// **THE `when ▾` DOOR** (VX-87 — direction 1). At rest it reads `when ▾`
/// exactly as the 13o menu did (the band's chip still carries the armed
/// state outside it); the press opens ONE popover — never a menu first (her
/// "nested drop downs").
struct LibraryWhenDoor: View {
    let tokens: VoiceTokens
    /// The armed range; nil = any day.
    let range: LibraryDayRange?
    /// "now" — defaulted for the app, injected by a pin.
    var now: Date = Date()
    var calendar: Calendar = LibraryDayFace.calendar
    /// HER week order, for display only (the §P1 ruling's condition 4).
    var firstWeekday: Int = Calendar.current.firstWeekday
    let onPick: (LibraryDayRange) -> Void
    let onClear: () -> Void

    @State private var shown = false
    @State private var brain = LibraryWhenDoorBrain.opening(range: nil)
    @State private var month: LibraryWhenMonth?
    @State private var hovering = false

    private var today: String { JournalDay.dayString(from: now, calendar: calendar) }

    /// **What opening sets up — and only that** (the no-silent-arm rule):
    /// the brain in the armed state's mode and the month to show. Nothing
    /// here can reach `onPick`.
    static func openingState(
        range: LibraryDayRange?, today: String
    ) -> (brain: LibraryWhenDoorBrain, month: LibraryWhenMonth?) {
        (LibraryWhenDoorBrain.opening(range: range), LibraryWhenMonth.opening(range: range, today: today))
    }

    var body: some View {
        Button {
            let opening = Self.openingState(range: range, today: today)
            brain = opening.brain
            month = opening.month
            shown = true
        } label: {
            // The 13o `VoicedMenu` label, unchanged in face: the small face,
            // the ink, the ▾, the hover wash.
            Text(tokens.chromeLabel(LibraryDayFace.closedLabel) + " \u{25BE}")
                .font(tokens.small)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
                .fixedSize()
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(hovering ? tokens.wash : Color.clear, in: RoundedRectangle(cornerRadius: 4))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .help(range == nil ? LibraryDayFace.closedDoorHelp : LibraryDayFace.caveat)
        .popover(isPresented: $shown, arrowEdge: .bottom) {
            // VX-98: presented WITH its keys (`keyed`).
            LibraryWhenPopover(
                tokens: tokens, range: range, now: now, calendar: calendar,
                firstWeekday: firstWeekday,
                brain: $brain,
                month: Binding(
                    get: { month ?? LibraryWhenMonth.opening(range: range, today: today)
                        // The last-resort floor (ladder R1 NIT-2): structurally
                        // unreachable — the press seeds `month` before `shown` —
                        // but if a future road ever reaches it, NOW's month in
                        // the filter's own calendar, never a dated constant
                        // (the failable `opening` closes only on a bad key;
                        // the components form cannot fail).
                        ?? LibraryWhenMonth(
                            year: calendar.component(.year, from: now),
                            month: calendar.component(.month, from: now)) },
                    set: { month = $0 }),
                onPick: onPick, onClear: onClear)
            .keyed
        }
    }
}

// MARK: - The popover

/// **The popover's face** (the mockup's direction 1): the mode row, the month
/// grid, a hairline, the ARMED SENTENCE, and the foot — *any day* (the
/// clearing word, quiet; faint and inert when nothing is armed — P-2) and the
/// quiet hint (*esc closes*, or — while a run waits — *then the last
/// day*). Width is the grid's; the sentence wraps inside it. Tokens only, so
/// both voices, light and dark (the fully black room, R51), come from the
/// voice itself.
struct LibraryWhenPopover: View {
    let tokens: VoiceTokens
    let range: LibraryDayRange?
    var now: Date = Date()
    var calendar: Calendar = LibraryDayFace.calendar
    var firstWeekday: Int = Calendar.current.firstWeekday
    var locale: Locale = .current
    @Binding var brain: LibraryWhenDoorBrain
    @Binding var month: LibraryWhenMonth
    let onPick: (LibraryDayRange) -> Void
    let onClear: () -> Void

    /// The card's inner margin.
    static let padding: CGFloat = 14

    private var today: String { JournalDay.dayString(from: now, calendar: calendar) }

    // MARK: The acts (what the face's controls run — the pins drive these)

    /// A day's cell: the ONE act that arms.
    func press(_ day: String) {
        if let picked = brain.press(day) { onPick(picked) }
    }

    /// The mode row: arms nothing.
    func ask(_ mode: LibraryWhenDoorBrain.Mode) {
        brain.ask(mode)
    }

    /// ‹ / ›: shows another month; arms nothing. VX-98: a keyboard day left
    /// behind follows into the month shown.
    func step(_ months: Int) {
        month = month.adding(months: months)
        brain.followMonth(month)
    }

    /// **VX-98 — an arrow:** the keyboard's day moves (the first lands on the
    /// anchor), and the month follows it past the grid's edge. Arms nothing.
    func moveKey(by days: Int) {
        month = brain.moveKey(by: days, showing: month, range: range, today: today)
    }

    /// **VX-98 — ⏎:** the keyboard's press — `press`'s own road on the day the
    /// keys stand on. False (the key not taken, nothing armed) while no day
    /// is focused.
    @discardableResult
    func pressKey() -> Bool {
        guard brain.keyDay != nil else { return false }
        if let picked = brain.pressKey() { onPick(picked) }
        return true
    }

    /// The key monitor's one answer: whether the key was the grid's.
    func handle(_ key: LibraryWhenGridKeys.Key) -> Bool {
        switch key {
        case .move(let days):
            moveKey(by: days)
            return true
        case .press:
            return pressKey()
        }
    }

    /// *any day*: clears, and forgets a run's waiting start.
    func clear() {
        brain.ask(brain.mode)
        onClear()
    }

    // MARK: The face

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            modeRow
            LibraryWhenMonthGrid(
                tokens: tokens, month: month, range: range, today: today,
                calendar: calendar, firstWeekday: firstWeekday, locale: locale,
                keyDay: brain.keyDay,
                onPress: press, onStep: step)
            VStack(alignment: .leading, spacing: 8) {
                Rectangle()
                    .fill(tokens.line)
                    .frame(height: 1)
                // The sentence sits over a hidden two-line strut in its own
                // emphasized weight, so the card never changes height as the
                // sentence grows from one day to a run (the grid's six fixed
                // rows hold the same promise; `reservesSpace` alone measured
                // 2 pt short of a real second semibold line in Terminal).
                ZStack(alignment: .topLeading) {
                    Text("M\nM")
                        .font(tokens.small)
                        .fontWeight(.semibold)
                        .hidden()
                        .accessibilityHidden(true)
                    Text(sentence)
                        .font(tokens.small)
                        // Chrome law (P-8): a wrapping chrome text states its limit.
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityAddTraits(.updatesFrequently)
                }
                LibraryWhenFoot(
                    tokens: tokens, armed: range != nil, waitsForRunEnd: brain.waitsForRunEnd,
                    onClear: clear)
            }
        }
        .padding(Self.padding)
        .frame(width: LibraryWhenMonthGrid.width + 2 * Self.padding)
        .background(tokens.surface)
        .presentationBackground(tokens.surface)
    }

    /// **VX-98 — the face WITH its keys:** the grid's key monitor, scoped to
    /// the window the face lives in — the popover's own (the app's key-monitor
    /// shape: no SwiftUI focus to lose to a click). Kept off `body` so the
    /// face itself stays pure SwiftUI (the offscreen renders draw it whole);
    /// the door presents THIS, and the mounted pin mounts it.
    var keyed: some View {
        background(LibraryWhenKeyMonitor(onKey: handle))
    }

    /// The sentence, its armed words emphasized in the ink.
    private var sentence: AttributedString {
        let words = LibraryDayFace.sentence(range: range, now: now, calendar: calendar, locale: locale)
        var lead = AttributedString(tokens.chromeLabel(words.lead))
        lead.foregroundColor = tokens.muted
        // The armed words wrap as ONE unit — no-break spaces, and a word
        // joiner after the run's dash (a dash is a break opportunity of its
        // own) — so a run never splits across the sentence's two lines.
        var armed = AttributedString(
            tokens.chromeLabel(words.emphasis)
                .replacingOccurrences(of: " ", with: "\u{00A0}")
                .replacingOccurrences(of: "\u{2013}", with: "\u{2013}\u{2060}"))
        armed.foregroundColor = tokens.ink
        armed.inlinePresentationIntent = .stronglyEmphasized
        var tail = AttributedString(words.tail)
        tail.foregroundColor = tokens.muted
        return lead + armed + tail
    }

    private var modeRow: some View {
        HStack(spacing: 0) {
            ForEach(LibraryWhenDoorBrain.Mode.allCases, id: \.self) { mode in
                let chosen = brain.mode == mode
                Button { ask(mode) } label: {
                    Text(tokens.chromeLabel(Self.word(mode)))
                        .font(tokens.small)
                        .fontWeight(chosen ? .semibold : .regular)
                        .foregroundStyle(chosen ? tokens.ink : tokens.muted)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .background(chosen ? QuietFill.chosen(tokens) : Color.clear)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(chosen ? .isSelected : [])
                if mode != LibraryWhenDoorBrain.Mode.allCases.last {
                    Rectangle()
                        .fill(tokens.line)
                        .frame(width: 1)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .clipShape(RoundedRectangle(cornerRadius: QuietFill.corner))
        .overlay(RoundedRectangle(cornerRadius: QuietFill.corner).stroke(tokens.line, lineWidth: 1))
    }

    static func word(_ mode: LibraryWhenDoorBrain.Mode) -> String {
        switch mode {
        case .oneDay: LibraryDayFace.onADay
        case .between: LibraryDayFace.betweenDays
        }
    }
}

/// **The card's foot** — *any day* (the clearing word: the accent while a day
/// is armed, faint and inert when nothing is — P-2) and the quiet hint (*esc
/// closes*, or — while a run waits for its last day — *then the last day*).
/// Its own view so its ideal width is pinned against the grid's
/// (`LibraryWhenDoorTests`): a hint that outgrew the card would be clipped by
/// the card's fixed width, never seen by any size check of the card.
struct LibraryWhenFoot: View {
    let tokens: VoiceTokens
    let armed: Bool
    let waitsForRunEnd: Bool
    let onClear: () -> Void

    /// The least air between the clearing word and the hint.
    static let gap: CGFloat = 12

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Button(action: onClear) {
                Text(tokens.chromeLabel(LibraryDayFace.anyDay))
                    .font(tokens.small)
                    .foregroundStyle(armed ? tokens.accent : tokens.faint)
                    .lineLimit(1)
                    .fixedSize()
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!armed)
            .help(LibraryDayFace.clearDoorHelp)
            Spacer(minLength: Self.gap)
            Text(tokens.chromeLabel(waitsForRunEnd ? LibraryDayFace.runEndHint : LibraryDayFace.escHint))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .lineLimit(1)
                .fixedSize()
        }
    }
}

/// **VX-98 — the grid's key door:** a zero-size view owning a local `keyDown`
/// monitor while its face is up (`PageTurnKeyMonitor`'s shape). It asks the
/// pure rule and swallows a key only when the grid took it, so Esc (the
/// popover's close), a chord, a letter and ⏎ on an untouched grid pass on
/// exactly as before.
///
/// **WHOSE key (the walk's W10 — VX-179's F-W-4 class, its rule reused):** the
/// face lives in SwiftUI's `.popover`, whose window is a CHILD of the main
/// window — and the main window stays KEY, so the keyboard's events are
/// addressed to the PARENT and AppKit delivers them in (measured at VX-179,
/// `notes/plans/fixes/vx-179-comment-polish.md`). The first build guarded
/// `event.window === its own window` and never saw one arrow with the Library's
/// search field holding the caret. A key is the grid's where it is DELIVERED
/// (`CommentPanelKeys.delivers`: the key window is the face's own, or the
/// face's VISIBLE window is a child of it), never while that window is
/// hidden — SwiftUI never tears a dismissed popover's content down — and the
/// monitor is released when its popover closes. The field's caret is never
/// taken: the grid claims its keys, it never becomes first responder.
struct LibraryWhenKeyMonitor: NSViewRepresentable {
    let onKey: (LibraryWhenGridKeys.Key) -> Bool

    func makeNSView(context: Context) -> MonitorView {
        let view = MonitorView()
        view.onKey = onKey
        return view
    }

    func updateNSView(_ nsView: MonitorView, context: Context) {
        nsView.onKey = onKey
    }

    final class MonitorView: NSView {
        var onKey: ((LibraryWhenGridKeys.Key) -> Bool)?
        private var monitor: Any?
        private var hostClosing: NSObjectProtocol?

        /// Never takes a click — the cells above it do.
        override func hitTest(_ point: NSPoint) -> NSView? { nil }

        private func release() {
            if let monitor {
                NSEvent.removeMonitor(monitor)
                self.monitor = nil
            }
            if let hostClosing {
                NotificationCenter.default.removeObserver(hostClosing)
                self.hostClosing = nil
            }
        }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            release()
            guard window != nil else { return }
            // A dismissed popover's face is never torn down: its closing ends
            // the listening (the comment panel's FIX LEG 3 road).
            hostClosing = NotificationCenter.default.addObserver(
                forName: NSPopover.willCloseNotification, object: nil, queue: .main
            ) { [weak self] note in
                let closing = note.object as? NSPopover
                MainActor.assumeIsolated {
                    guard let self, let window = self.window,
                          CommentPanelHostWatcher.isHost(closing, ofPanelIn: window)
                    else { return }
                    self.release()
                }
            }
            monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard let self, let window = self.window,
                      CommentPanelKeys.delivers(
                          toPanelIn: window, keyWindow: NSApp.keyWindow, eventWindow: event.window)
                else { return event }
                guard let key = LibraryWhenGridKeys.key(
                    keyCode: event.keyCode, modifiers: event.modifierFlags,
                    textIsFirstResponder: PageTurnKeys.textIsFirstResponder(in: window)),
                    self.onKey?(key) == true
                else { return event }
                return nil  // the grid's key, taken
            }
        }
        // (No `deinit`: the view leaves its window before it dies, and
        // `viewDidMoveToWindow` — called then with a nil window — releases
        // both; a nonisolated deinit may not touch them.)
    }
}
