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
/// a range is `press(_:)`, the act of touching a day.
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

    /// ‹ / ›: shows another month; arms nothing.
    func step(_ months: Int) {
        month = month.adding(months: months)
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
