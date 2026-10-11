import Foundation

/// **THE ONE STAMP-WORDING BRAIN** (18h batch 1, the 2026-09-12 use-report
/// round — her ledger row 9, ruling R-Q7).
///
/// Her words: *"I need to be able to see the created time and last edited
/// time easily on the library and within the note itself… I like how apple
/// notes does it where you can see the time it was last edited and if you
/// click on it you see when it was created."*
///
/// Three surfaces say a stamp out loud — a Library List row, the Notes
/// card's line, and the note masthead's quiet trailing stamp — and a fourth
/// (18d's note-box facts line) already shipped its own day words. One
/// wording rule for all of them, pure and pinned, is the whole point:
/// **two copies of one rule anywhere are the drift class** (MobileSoul §3),
/// and a view that spells its own date format is a rule hidden in a body
/// (P-8). `NoteBoxCopy.day` forwards here rather than keeping its copy.
///
/// It lives in `Domain` beside `DisplayTitle` — the same kind of thing: a
/// pure answer to *"what does this stored value read as on screen"*, asked
/// by chrome on both platforms, pinned by `swift test` without a window.
///
/// ── THE THRESHOLDS (the batch's numbers, recorded — not asked of her) ────
///
/// | the stamp | reads as |
/// |---|---|
/// | the same calendar day as `now` | `today 1:33 AM` |
/// | the calendar day before | `yesterday` |
/// | any other day this calendar year | `Sep 9` |
/// | any other year | `Sep 9, 2025` |
///
/// The asymmetry is deliberate: TODAY is the case where the time is the
/// useful half (she saved this note four minutes ago), and by yesterday the
/// day is the useful half. A FUTURE stamp (a store copied off a machine
/// whose clock ran ahead, a sync arrival) reads as its day — never as
/// "today", never as an error. The year rides whenever the stamp is not
/// from this one, because *"Sep 9"* for something written two years ago is a
/// lie told by omission (18d's own rule, kept).
///
/// ── TWO PRECISIONS ──────────────────────────────────────────────────────
///
/// `created_at` / `last_touched_at` are instants; `entry_date` is a DAY she
/// stated (`JournalDay`'s "yyyy-MM-dd"). A day stamp never prints a time —
/// inventing "12:00 PM" for it would be the app claiming a fact it does not
/// hold. Both shapes arrive through one ISO door (`iso:`), because the
/// Library's row holds one of each and should not have to guess which.
///
/// Every entry point takes its `now`, `calendar` and `locale`, so a pin
/// holds the rule rather than the machine.
///
/// ── ONE MEASURED FACT, so the next reader is not caught by it ────────────
///
/// The time comes from ICU's own localised template (`jmm`), and on this
/// SDK it separates the minutes from AM/PM with a NARROW NO-BREAK SPACE
/// (U+202F), not a plain space: `1:33\u{202F}PM`. That is correct
/// typography and deliberately not fought — but a pin comparing against a
/// literal must spell the scalar, and anything MATCHING these words (a
/// future search, a snapshot) must not assume ASCII spacing. Likewise
/// `MMMdyyyyjmm` renders as *Sep 9, 2026 at 4:02 PM* — the "at" is the
/// locale's, not ours.
public enum TimeStampFace {
    /// Which stamp is being said — the verb is the brain's, so no view
    /// spells it (F-0: no string-as-rule in a view).
    public enum Subject: String, Sendable, CaseIterable {
        /// `container.last_touched_at` (falling back to the mint) — AppSpec §10's
        /// noisy stamp: every keystroke.
        case edited
        /// `container.created_at` — the mint.
        case created
        /// `container.entry_date` — the day she stated. Day-precision.
        case dated

        /// Lower case, for a stamp inside a sentence-ish line: *edited today*.
        public var verb: String { rawValue }

        /// Capitalised, for the tooltip's own sentence: *Edited Sep 9, 2026*.
        public var titleCased: String { rawValue.capitalized }

        /// A day-precision subject never carries a time.
        var isDayPrecision: Bool { self == .dated }
    }

    // MARK: - The words

    /// The glanceable words for an instant: *today 1:33 AM* · *yesterday* ·
    /// *Sep 9* · *Sep 9, 2025*.
    public static func relative(
        _ date: Date, now: Date,
        calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> String {
        words(date, now: now, calendar: calendar, locale: locale, dayOnly: false)
    }

    /// A day, short: *Sep 4* — with the YEAR when the stamp is not from this
    /// one. **This is the shape 18d's facts line already ships**
    /// (`NoteBoxCopy.day` forwards here); it knows nothing of
    /// today/yesterday, which is `relative`'s job.
    public static func day(
        _ date: Date, now: Date,
        calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> String {
        let sameYear = calendar.component(.year, from: date)
            == calendar.component(.year, from: now)
        return formatted(date, template: sameYear ? "MMMd" : "MMMdyyyy",
                         calendar: calendar, locale: locale)
    }

    /// The time of day alone: *9:14 PM* (the locale's own `jmm`), or with
    /// its seconds (`jmmss`). 13n-c U2 — `PlaceLabels`' made-time rungs
    /// ("made Oct 9, 9:14 PM"); the same cached formatter as every other
    /// shape here, so the time reads exactly as the stamps' "today 1:33 AM".
    public static func time(
        _ date: Date, seconds: Bool = false,
        calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> String {
        formatted(date, template: seconds ? "jmmss" : "jmm", calendar: calendar, locale: locale)
    }

    /// The labelled form for an instant: *edited today 1:33 AM*.
    public static func stamp(
        _ subject: Subject, date: Date, now: Date,
        calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> String {
        let words = self.words(
            date, now: now, calendar: calendar, locale: locale,
            dayOnly: subject.isDayPrecision)
        return "\(subject.verb) \(words)"
    }

    /// The labelled form for a stored stamp — either shape: the canonical
    /// ISO-8601 instant (`created_at`, `last_touched_at`) or a day key
    /// (`entry_date`). **nil ⇒ nothing to say**, so a face draws nothing
    /// rather than a lie: a missing column, an empty string, or text that is
    /// not a stamp at all.
    public static func stamp(
        _ subject: Subject, iso: String?, now: Date,
        calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> String? {
        guard let date = parse(iso, calendar: calendar) else { return nil }
        return stamp(subject, date: date, now: now, calendar: calendar, locale: locale)
    }

    /// The labelled form for a day key (`entry_date`) — the same door, named
    /// for what the caller holds.
    public static func stamp(
        _ subject: Subject, day: String?, now: Date,
        calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> String? {
        stamp(subject, iso: day, now: now, calendar: calendar, locale: locale)
    }

    // MARK: - The whole fact (the hover)

    /// The tooltip: the WHOLE fact, spelled — *Edited Sep 9, 2026, 4:02 PM*.
    /// The glanceable words are a summary, and hovering must never leave her
    /// guessing which year *Sep 9* was. A day subject has no time to spell.
    public static func tooltip(
        _ subject: Subject, date: Date,
        calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> String {
        let template = subject.isDayPrecision ? "MMMdyyyy" : "MMMdyyyyjmm"
        return "\(subject.titleCased) "
            + formatted(date, template: template, calendar: calendar, locale: locale)
    }

    /// The tooltip for a stored stamp of either shape; nil on the same terms
    /// as `stamp(_:iso:now:)`.
    public static func tooltip(
        _ subject: Subject, iso: String?,
        calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> String? {
        guard let date = parse(iso, calendar: calendar) else { return nil }
        return tooltip(subject, date: date, calendar: calendar, locale: locale)
    }

    /// The tooltip for a day key.
    public static func tooltip(
        _ subject: Subject, day: String?,
        calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> String? {
        tooltip(subject, iso: day, calendar: calendar, locale: locale)
    }

    // MARK: - The rule, once

    private static func words(
        _ date: Date, now: Date, calendar: Calendar, locale: Locale, dayOnly: Bool
    ) -> String {
        if calendar.isDate(date, inSameDayAs: now) {
            guard !dayOnly else { return "today" }
            let time = formatted(date, template: "jmm", calendar: calendar, locale: locale)
            return "today \(time)"
        }
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
           calendar.isDate(date, inSameDayAs: yesterday) {
            return "yesterday"
        }
        return day(date, now: now, calendar: calendar, locale: locale)
    }

    /// The store's two stamp shapes, one door. A day key is resolved at NOON
    /// in the given calendar — only its calendar day is ever read, and noon
    /// cannot be shifted across a day boundary by a DST transition the way
    /// midnight can. *(18h batch 2: the noon rule itself moved to
    /// `JournalDay.date(from:calendar:)`, beside the function it inverts —
    /// this door had the only copy of it, and `DayBounds` needed the same
    /// answer.)*
    static func parse(_ text: String?, calendar: Calendar) -> Date? {
        guard let text, !text.isEmpty else { return nil }
        if let instant = DateFormatter.variorumISO8601.date(from: text) { return instant }
        return JournalDay.date(from: text, calendar: calendar)
    }

    private static func formatted(
        _ date: Date, template: String, calendar: Calendar, locale: Locale
    ) -> String {
        formatter(template: template, calendar: calendar, locale: locale).string(from: date)
    }

    // MARK: - The formatter cache (the 18h ladder, R1-5)

    /// **Build the formatter once per shape, not once per call.**
    ///
    /// The cold review measured what this function used to do: a
    /// `DateFormatter` allocated and `setLocalizedDateFormatFromTemplate`d on
    /// EVERY call — **71.8 µs** per call on this machine, against **0.54 µs**
    /// through the cache end to end, of which the lock and the hash are
    /// **0.15 µs** (the ladder's round-2 measurement, R2-11, over 200k
    /// iterations of the landed shapes; round 1's own probes read 72–76 µs
    /// built and 0.68–1.8 µs cached). A Library row asks for
    /// two of them (its words and its tooltip — `.help` takes a built
    /// `String`, so the tooltip is paid whether or not anyone hovers), so a
    /// 40-row list body paid **~5.8 ms of main-thread work** and re-paid it on
    /// every keystroke, selection change and row recycle. Viewport-bounded, so
    /// never a P1 breach — but it sat on the surface the project's first
    /// principle calls *snappy, always*.
    ///
    /// **The tooltip stays EAGER** (ruled at the ladder's arbitration): `.help`
    /// takes a value, not a closure, and a hover-deferred build (`onHover` +
    /// per-row `@State`) costs more on every pointer entry than the
    /// sub-microsecond it would save now that the formatter is cached.
    ///
    /// **The key is the whole shape** — template AND locale AND calendar AND
    /// time zone. A key that forgot any of them would hand back a formatter
    /// speaking the wrong calendar or zone, which is the one way a cache can
    /// turn a slow-but-correct answer into a fast lie; pinned by
    /// `TimeStampFaceTests.theFormatterCacheAnswersPerLocaleCalendarAndZone`.
    ///
    /// **Locked, not merely `nonisolated(unsafe)`** — this is a MUTABLE
    /// dictionary read and written from whatever thread renders, and the
    /// `variorumISO8601` precedent beside it is an immutable `let` that
    /// licenses nothing of the kind. The shape is `StoreKey.sweptAccounts` /
    /// `SyncSchema.columnCatalog`: an `NSLock` around a static store. Bounded
    /// by construction: four templates × the one locale/calendar/zone a
    /// process actually renders in. The lock covers the DICTIONARY; the
    /// formatter it hands back formats outside it, on the same documented
    /// thread-safety `DateFormatter.variorumISO8601` has relied on since
    /// Phase 1 (a shared formatter used from every layer).
    private struct FormatterShape: Hashable {
        let template: String
        let locale: String
        let calendar: Calendar.Identifier
        let timeZone: String
    }

    private static let formatterLock = NSLock()
    nonisolated(unsafe) private static var formatters: [FormatterShape: DateFormatter] = [:]

    private static func formatter(
        template: String, calendar: Calendar, locale: Locale
    ) -> DateFormatter {
        let shape = FormatterShape(
            template: template, locale: locale.identifier,
            calendar: calendar.identifier, timeZone: calendar.timeZone.identifier)
        formatterLock.lock()
        defer { formatterLock.unlock() }
        if let cached = formatters[shape] { return cached }
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.locale = locale
        formatter.setLocalizedDateFormatFromTemplate(template)
        formatters[shape] = formatter
        return formatter
    }
}
