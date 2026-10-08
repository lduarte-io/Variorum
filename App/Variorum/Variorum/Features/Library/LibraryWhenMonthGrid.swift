//
//  LibraryWhenMonthGrid.swift
//  Variorum (Mac)
//
//  **VX-87 — the `when` popover's month grid** (her direction 1, R-VX83-2;
//  the orchestrator's §P1 ruling: A, a custom grid drawn ENTIRELY from the
//  voice's tokens). Measured first (the U-B record's §P1 FORK): SwiftUI's
//  `.graphical` `DatePicker` has no range on the Mac and takes no voice
//  treatment at all, and the AppKit range picker ignores the voice's type and
//  ink — so a run that "washes in as she clicks", in the room's own colours,
//  is a small view of the app's own.
//
//  Two halves, one file:
//  1. THE PURE RULES (the ruling's condition 3) — the month, the six-row
//     layout in HER week order, a day's mark against the armed range, and the
//     VoiceOver words each cell speaks (condition 1 — hand-written, at this
//     landing). Pinned in `LibraryWhenDoorTests`.
//  2. THE FACE — header, weekday initials, the 6×7 cells; every cell's press
//     is the one closure the popover hands it (`onPress` → the popover's
//     `press(_:)`), so the pins walk the door's own road.
//
//  Day KEYS are the filter's one calendar's (`LibraryDayFace.calendar` —
//  Gregorian, her zone); only the DISPLAY week order is hers
//  (`Calendar.current.firstWeekday` — condition 4). No arrow-key day
//  navigation in this landing (PROVISIONAL P-VX83-B3 — condition 2).
//

import SwiftUI
import VariorumCore

// MARK: - The pure rules

/// **A month the grid shows** — a year and a month, normalized (month 13 is
/// next January).
nonisolated struct LibraryWhenMonth: Hashable, Sendable {
    let year: Int
    /// 1…12.
    let month: Int

    init(year: Int, month: Int) {
        let index = year * 12 + (month - 1)
        self.year = index >= 0 ? index / 12 : (index - 11) / 12
        self.month = index - self.year * 12 + 1
    }

    /// The month a day key falls in; nil for a key that is not a day.
    init?(dayKey: String) {
        guard JournalDay.isValid(dayKey) else { return nil }
        let parts = dayKey.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        self.init(year: parts[0], month: parts[1])
    }

    func adding(months: Int) -> LibraryWhenMonth {
        LibraryWhenMonth(year: year, month: month + months)
    }

    /// `yyyy-MM-01`.
    var firstDayKey: String { String(format: "%04d-%02d-01", year, month) }

    /// **The month the popover opens on** — the armed range's FIRST day's (a
    /// run is read from its start, the way it was pressed), else today's.
    static func opening(range: LibraryDayRange?, today: String) -> LibraryWhenMonth? {
        LibraryWhenMonth(dayKey: range?.first ?? today)
    }
}

/// **The grid's layout and marks** — pure (the ruling's condition 3).
nonisolated enum LibraryWhenGrid {
    /// SIX rows, always: the popover never changes height between months.
    static let rows = 6
    static let columns = 7

    struct Cell: Hashable, Sendable {
        /// The day's key in the filter's calendar.
        let day: String
        /// The digit drawn.
        let number: Int
        /// False for the leading/trailing days of the neighbouring months
        /// (drawn faint; still real days a press arms).
        let inMonth: Bool
    }

    /// The 42 cells for a month: from the week-start on or before its first
    /// day, in HER week order (`firstWeekday`, 1 = Sunday … 7 = Saturday — a
    /// value outside that reads as Sunday). Day arithmetic in `calendar` (the
    /// filter's: Gregorian, her zone), from each day's NOON so no daylight-
    /// saving shift can skip or double a day.
    static func cells(
        of month: LibraryWhenMonth, firstWeekday: Int, calendar: Calendar
    ) -> [Cell] {
        guard let first = JournalDay.date(from: month.firstDayKey, calendar: calendar) else { return [] }
        let start = (1...7).contains(firstWeekday) ? firstWeekday : 1
        let lead = (calendar.component(.weekday, from: first) - start + 7) % 7
        return (0..<(rows * columns)).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset - lead, to: first) else {
                return nil
            }
            let parts = calendar.dateComponents([.year, .month, .day], from: date)
            return Cell(
                day: JournalDay.dayString(from: date, calendar: calendar),
                number: parts.day ?? 0,
                inMonth: parts.year == month.year && parts.month == month.month)
        }
    }

    /// The weekday initials over the columns, in her week order (the locale's
    /// very-short standalone symbols — "M T W T F S S" for a Monday week in
    /// English).
    static func weekdayInitials(firstWeekday: Int, calendar: Calendar, locale: Locale) -> [String] {
        var named = calendar
        named.locale = locale
        let symbols = named.veryShortStandaloneWeekdaySymbols  // Sunday first
        let start = (1...7).contains(firstWeekday) ? firstWeekday : 1
        guard symbols.count == 7 else { return [] }
        return (0..<7).map { symbols[(start - 1 + $0) % 7] }
    }

    /// *October 2026* — the header's words.
    static func monthTitle(_ month: LibraryWhenMonth, calendar: Calendar, locale: Locale) -> String {
        guard let date = JournalDay.date(from: month.firstDayKey, calendar: calendar) else {
            return month.firstDayKey
        }
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.locale = locale
        formatter.setLocalizedDateFormatFromTemplate("MMMMyyyy")
        return formatter.string(from: date)
    }

    /// **How a day reads against the armed range** — the run's two ends
    /// carry the "this one" fill, the days between it the band.
    enum Mark: Hashable, Sendable {
        case none
        /// The one armed day.
        case single
        case runStart
        case runEnd
        /// Strictly between the run's ends.
        case inRun

        var isArmed: Bool { self != .none }
        var isEnd: Bool { self == .single || self == .runStart || self == .runEnd }
    }

    static func mark(_ day: String, in range: LibraryDayRange?) -> Mark {
        guard let range else { return .none }
        if range.isOneDay { return day == range.first ? .single : .none }
        if day == range.first { return .runStart }
        if day == range.last { return .runEnd }
        // Canonical keys order lexicographically as they do in time.
        return day > range.first && day < range.last ? .inRun : .none
    }

    /// **What VoiceOver says for a cell** (the ruling's condition 1 — written
    /// by hand at this landing, never deferred): the day in full, then its
    /// standing — *Tuesday, October 6, 2026* · *first day of the run, today*.
    /// `selected` carries the selected trait for every armed day.
    struct Spoken: Equatable, Sendable {
        let label: String
        let value: String
        let selected: Bool
    }

    static func spoken(
        _ cell: Cell, range: LibraryDayRange?, today: String, calendar: Calendar, locale: Locale
    ) -> Spoken {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.locale = locale
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        let label = JournalDay.date(from: cell.day, calendar: calendar).map(formatter.string(from:))
            ?? cell.day
        let standingMark = Self.mark(cell.day, in: range)
        var standing: [String] = []
        switch standingMark {
        case .none: break
        case .single: standing.append(LibraryDayFace.spokenChosenDay)
        case .runStart: standing.append(LibraryDayFace.spokenRunStart)
        case .runEnd: standing.append(LibraryDayFace.spokenRunEnd)
        case .inRun: standing.append(LibraryDayFace.spokenInRun)
        }
        if cell.day == today { standing.append(LibraryDayFace.spokenToday) }
        return Spoken(
            label: label, value: standing.joined(separator: ", "), selected: standingMark.isArmed)
    }
}

// MARK: - The face

/// **The month grid** — the header (‹ October 2026 ›), the weekday initials
/// and six rows of days. The armed day, or the run's two ends, wear the
/// app's one "this one" fill (`QuietFill.chosen`, VR-119); the days between
/// wear the chip-at-rest fill as one band per row (`band`); today's digit is
/// the accent.
struct LibraryWhenMonthGrid: View {
    let tokens: VoiceTokens
    let month: LibraryWhenMonth
    let range: LibraryDayRange?
    let today: String
    let calendar: Calendar
    let firstWeekday: Int
    var locale: Locale = .current
    /// A day's press — the popover's `press(_:)`.
    let onPress: (String) -> Void
    /// ‹ / › — the popover's `step(_:)`.
    let onStep: (Int) -> Void

    /// One cell's room: wide enough for two digits with air either side,
    /// tall enough for the small face's line plus the fill's inset.
    static let cell = CGSize(width: 32, height: 26)
    static var width: CGFloat { cell.width * CGFloat(LibraryWhenGrid.columns) }

    /// **The run's band** — the strip's chip-at-rest fill (`QuietFill.rest`,
    /// VR-119: "in the set, not the chosen one"), so the run's two ENDS on
    /// the chosen fill stand out from the days between in BOTH voices (Study's
    /// wash is itself an accent tint, so a full-wash band read the same tone
    /// as the ends — measured on the spacing renders).
    static func band(_ tokens: VoiceTokens) -> Color { QuietFill.rest(tokens) }

    var body: some View {
        let cells = LibraryWhenGrid.cells(of: month, firstWeekday: firstWeekday, calendar: calendar)
        let initials = LibraryWhenGrid.weekdayInitials(
            firstWeekday: firstWeekday, calendar: calendar, locale: locale)
        VStack(spacing: 0) {
            header
                .padding(.bottom, 6)
            HStack(spacing: 0) {
                ForEach(initials.indices, id: \.self) { index in
                    Text(initials[index])
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                        .lineLimit(1)
                        .frame(width: Self.cell.width)
                }
            }
            .accessibilityHidden(true)
            .padding(.bottom, 3)
            VStack(spacing: 2) {
                ForEach(0..<LibraryWhenGrid.rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<LibraryWhenGrid.columns, id: \.self) { column in
                            let index = row * LibraryWhenGrid.columns + column
                            if index < cells.count {
                                LibraryWhenDayCell(
                                    tokens: tokens, cell: cells[index],
                                    mark: LibraryWhenGrid.mark(cells[index].day, in: range),
                                    isToday: cells[index].day == today,
                                    spoken: LibraryWhenGrid.spoken(
                                        cells[index], range: range, today: today,
                                        calendar: calendar, locale: locale),
                                    onPress: onPress)
                            }
                        }
                    }
                }
            }
        }
        .frame(width: Self.width)
    }

    private var header: some View {
        HStack(spacing: 0) {
            LibraryWhenStepButton(
                tokens: tokens, symbol: "chevron.left", spoken: LibraryDayFace.previousMonth
            ) { onStep(-1) }
            Spacer(minLength: 4)
            Text(tokens.chromeLabel(
                LibraryWhenGrid.monthTitle(month, calendar: calendar, locale: locale)))
                .font(tokens.small)
                .fontWeight(.semibold)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 4)
            LibraryWhenStepButton(
                tokens: tokens, symbol: "chevron.right", spoken: LibraryDayFace.nextMonth
            ) { onStep(1) }
        }
    }
}

/// One day: its digit, its fill, its hover, its spoken words.
private struct LibraryWhenDayCell: View {
    let tokens: VoiceTokens
    let cell: LibraryWhenGrid.Cell
    let mark: LibraryWhenGrid.Mark
    let isToday: Bool
    let spoken: LibraryWhenGrid.Spoken
    let onPress: (String) -> Void
    @State private var hovering = false

    private var ink: Color {
        if isToday { return tokens.accent }
        if mark.isEnd { return tokens.ink }
        return cell.inMonth ? tokens.ink : tokens.faint
    }

    var body: some View {
        Button { onPress(cell.day) } label: {
            Text("\(cell.number)")
                .font(tokens.small)
                .monospacedDigit()
                .fontWeight(mark.isEnd || isToday ? .semibold : .regular)
                .foregroundStyle(ink)
                .lineLimit(1)
                .frame(width: LibraryWhenMonthGrid.cell.width, height: LibraryWhenMonthGrid.cell.height)
                .background { fill }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .accessibilityLabel(spoken.label)
        .accessibilityValue(spoken.value)
        .accessibilityAddTraits(spoken.selected ? .isSelected : [])
    }

    /// The run's band joins across a row (cells sit edge to edge); its two
    /// ends sit on the chosen fill with the band reaching in from the inner
    /// side, so a run reads as one stroke from first to last.
    @ViewBuilder private var fill: some View {
        let inset: CGFloat = 1
        switch mark {
        case .none:
            if hovering {
                RoundedRectangle(cornerRadius: QuietFill.corner)
                    .fill(tokens.wash)
                    .padding(inset)
            }
        case .single:
            RoundedRectangle(cornerRadius: QuietFill.corner)
                .fill(QuietFill.chosen(tokens))
                .padding(inset)
        case .inRun:
            Rectangle()
                .fill(LibraryWhenMonthGrid.band(tokens))
                .padding(.vertical, inset)
        case .runStart, .runEnd:
            ZStack {
                HStack(spacing: 0) {
                    if mark == .runEnd { Rectangle().fill(LibraryWhenMonthGrid.band(tokens)) } else { Color.clear }
                    if mark == .runStart { Rectangle().fill(LibraryWhenMonthGrid.band(tokens)) } else { Color.clear }
                }
                .padding(.vertical, inset)
                // The end sits on the card's own paper first, so the band
                // reaching in from the inner side never shows through the
                // translucent fill as a two-tone cell.
                RoundedRectangle(cornerRadius: QuietFill.corner)
                    .fill(tokens.surface)
                    .padding(inset)
                RoundedRectangle(cornerRadius: QuietFill.corner)
                    .fill(QuietFill.chosen(tokens))
                    .padding(inset)
            }
        }
    }
}

/// ‹ / › — a quiet glyph with the `VoicedMenu` hover wash.
private struct LibraryWhenStepButton: View {
    let tokens: VoiceTokens
    let symbol: String
    let spoken: String
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .frame(width: 24, height: 20)
                .background(
                    hovering ? tokens.wash : Color.clear,
                    in: RoundedRectangle(cornerRadius: QuietFill.corner))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .help(spoken)
        .accessibilityLabel(spoken)
    }
}
