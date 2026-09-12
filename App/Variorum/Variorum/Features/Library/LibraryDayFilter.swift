//
//  LibraryDayFilter.swift
//  Variorum (Mac)
//
//  **18h batch 2 — THE DAY SEARCH** (the 2026-09-12 use-report round, her
//  ledger row 11; ruling R-Q8: *"Build now, small filter in the Library"*).
//  Her words: *"how difficult it would be to implement being able to search
//  for any note edited on a particular day."*
//
//  Two things of one theme live here, and deliberately NOT inside
//  `LibraryCatalogView.swift` (1,300 lines already — P-9 / review focus
//  F-0), nor inside `LibraryTimeFace.swift`, which is batch 1's sort-and-
//  stamp file and has its own job:
//
//  1. `LibraryDayFace` — the WORDS: the door's label, and the honest empty
//     answer, said in ONE place so the List mode and the Notes mode can
//     never word the same silence differently.
//  2. `LibraryDayField` — the door: the `on day…` field with its ✕.
//
//  The day itself is a canonical `yyyy-MM-dd` key in HER calendar; the
//  conversion to the UTC window the stored stamps compare against is core's
//  one pure rule (`DayBounds`), never done here.
//

import Foundation
import SwiftUI
import VariorumCore

// MARK: - The words

/// What the day filter SAYS — including the one thing it must say out loud.
///
/// **The caveat is the product's honesty, not a footnote.** The store keeps
/// ONE edit stamp per note (AppSpec §10 — *coarse, not forensic*; a per-day
/// edit log is the forensic tracking CoreDescription rules out by
/// definition), so a note written on Monday and again on Tuesday answers for
/// Tuesday by its stamp. What rescues Monday is a savepoint: since 13j one
/// lands per changed take when she leaves a note, with the idle timer behind
/// it. The search unions the two — and where the union still finds nothing,
/// the face says exactly why rather than implying the day was empty.
nonisolated enum LibraryDayFace {
    /// The door, closed: *on day…* — an invitation, in the chrome's own
    /// ellipsis grammar.
    static let closedLabel = "on day\u{2026}"

    /// The door, open: *on Sep 9* — the same day words every stamp in the
    /// Library uses (`TimeStampFace.day`, core `Domain`).
    static func openLabel(
        day: String, now: Date, calendar: Calendar = .current, locale: Locale = .current
    ) -> String {
        "on \(dayWords(day: day, now: now, calendar: calendar, locale: locale))"
    }

    /// A day key in her own reading — *Sep 9*, or *Sep 9, 2025* when it is
    /// not from this year. Falls back to the raw key if a caller ever hands
    /// it something that is not a day (a face draws what it has, never a
    /// crash).
    static func dayWords(
        day: String, now: Date, calendar: Calendar = .current, locale: Locale = .current
    ) -> String {
        guard let date = JournalDay.date(from: day, calendar: calendar) else { return day }
        return TimeStampFace.day(date, now: now, calendar: calendar, locale: locale)
    }

    /// The caveat, in one sentence — on the door's hover whenever the filter
    /// is armed, and under the empty answer when it finds nothing.
    static let caveat =
        "A note keeps one edit stamp, so a note edited on two days answers for the later one "
        + "\u{2014} earlier days show up where a savepoint landed."

    /// What an empty answer says: the fact, then the reason.
    struct EmptyAnswer: Equatable {
        let headline: String
        let caveat: String
    }

    /// **The headline names every narrowing, not just the day** (the ladder's
    /// R1-3(a)). The unqualified sentence asserts a fact about the DAY, and
    /// the search field sits two controls from the day door — so with a query
    /// typed beside it, *"No note's last edit or savepoint falls on Sep 9"*
    /// is confidently false whenever notes WERE edited that day and merely
    /// did not match the words. The caveat rides either way: it is still the
    /// reason a note she remembers writing that day can be missing.
    static func emptyAnswer(
        day: String, query: String = "", now: Date,
        calendar: Calendar = .current, locale: Locale = .current
    ) -> EmptyAnswer {
        let words = dayWords(day: day, now: now, calendar: calendar, locale: locale)
        let typed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return EmptyAnswer(
            headline: typed.isEmpty
                ? "No note's last edit or savepoint falls on \(words)."
                : "No note matching \u{201C}\(typed)\u{201D} was edited on \(words).",
            caveat: caveat)
    }
}

// MARK: - The door

/// The Library header's day filter: `on day…` until she names one, then the
/// date field itself with a ✕ that clears it.
///
/// Two states rather than a permanently-open field: an always-armed date
/// control would filter the Library the moment the page drew, and a listing
/// silently narrowed by a control she never touched is the invisible-state
/// hazard this app's own walk standard forbids. Opening it picks TODAY —
/// what a date field does everywhere, and the answer she most often wants.
struct LibraryDayField: View {
    /// The date control's reserved width in points — enough for
    /// `9/12/2026` PLUS the stepper the field grows when it takes focus
    /// (measured on the walk at ~88 pt focused; the slack keeps a wider
    /// locale's date from clipping).
    static let fieldWidth: CGFloat = 108

    let tokens: VoiceTokens
    /// The armed day, canonical `yyyy-MM-dd` in her calendar; nil = closed.
    let day: String?
    /// "now" — defaulted for the app, injected by a pin so the pin holds the
    /// rule and not the machine (the `CatalogRowStamp` convention).
    var now: Date = Date()
    var calendar: Calendar = .current
    let onPick: (String) -> Void
    let onClear: () -> Void

    /// The date control's own binding — the exact closure the `DatePicker`
    /// drives, exposed so a pin can drive it too (never a hand-fed value).
    var dateBinding: Binding<Date> {
        Binding(
            get: { day.flatMap { JournalDay.date(from: $0, calendar: calendar) } ?? now },
            set: { onPick(JournalDay.dayString(from: $0, calendar: calendar)) })
    }

    var body: some View {
        HStack(spacing: 4) {
            if let day {
                Text(tokens.chromeLabel(
                    LibraryDayFace.openLabel(day: day, now: now, calendar: calendar)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .lineLimit(1)
                    .fixedSize()
                DatePicker("", selection: dateBinding, displayedComponents: .date)
                    .datePickerStyle(.field)
                    .labelsHidden()
                    .font(tokens.small)
                    // A MEASURED width, not `fixedSize` (found on the walk):
                    // the field grows a stepper the moment it takes focus,
                    // and an ideal-width control sized while unfocused then
                    // overflows — the digits printed THROUGH the ✕ beside
                    // it. The room is reserved for the focused shape, which
                    // is the wider of the two.
                    .frame(width: Self.fieldWidth)
                Button {
                    onClear()
                } label: {
                    Text("\u{2715}")
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .help("Clear the day — list every note again")
                .accessibilityLabel("Clear the day filter")
            } else {
                Button {
                    onPick(JournalDay.dayString(from: now, calendar: calendar))
                } label: {
                    Text(tokens.chromeLabel(LibraryDayFace.closedLabel))
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .accessibilityLabel("Filter by the day a note was edited")
            }
        }
        .help(day == nil
              ? "Show only the notes edited on one day"
              : LibraryDayFace.caveat)
    }
}

/// The empty answer, drawn the same way wherever the listing is empty while
/// a day is armed (the List mode's section and the Notes mode's column).
struct LibraryDayEmptyAnswer: View {
    let tokens: VoiceTokens
    let day: String
    /// What else is narrowing the listing, so the headline can name it
    /// (R1-3(a)) — empty when the day is the only narrowing.
    var query: String = ""
    var now: Date = Date()
    var calendar: Calendar = .current

    var body: some View {
        let answer = LibraryDayFace.emptyAnswer(
            day: day, query: query, now: now, calendar: calendar)
        VStack(alignment: .leading, spacing: 4) {
            Text(tokens.chromeLabel(answer.headline))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            Text(tokens.chromeLabel(answer.caveat))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                // Chrome law (P-8, the wedged-window class): a wrapping
                // chrome text states its own limit.
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: 520, alignment: .leading)
    }
}
