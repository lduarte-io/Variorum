import Foundation

/// **PLACE LABELS — what a place on the grant road is called, and how two of
/// the same name are told apart** (13n-c U2; VX-156 items 1 + 6 — the brief
/// `notes/plans/vx-156-grant-ux-brief.md` §2, option A; the approved mockup
/// §1b; her "last edited" joining the context line at the Air sitting).
///
/// Her screenshot is the reason this exists: two books called "the adventures
/// of sherlock holmes" were two IDENTICAL rows in the grant sheet's menu, and
/// nothing on screen could say which one a grant would name. Two answers, one
/// rule, pure and pinned:
///
/// 1. **The context line** — every row says what the Bookcase row would, in
///    ONE fixed order: (a non-Home book's wing) · shelf · N notes · state
///    marks · last edited. Quiet footing for a list of hundreds.
/// 2. **The distinguisher** — when two OFFERED places share a name (case- and
///    diacritic-insensitively — the picker brain's own sameness), each gains
///    the first fact from ONE fixed ladder that no other place of its name
///    shares: **wing → shelf → note count → state → made day → made time**
///    ("made Oct 9" → "made Oct 9, 9:14 PM"). **Never an invented ordinal** —
///    "(2)" would change meaning the moment one of them is deleted; every
///    distinguisher is a fact about the place itself.
///
/// The ladder is applied PER PLACE (the brief's "first fact that differs",
/// made exact for sets larger than two): a place takes the first rung whose
/// value is its own alone within its collision set, so every label the set
/// shows is unique. A rung a place has no value for (an open book's empty
/// state) is skipped for it. When two places agree on every rung to the
/// minute, the made time grows its seconds — still a fact; and if even that
/// agrees (two books minted in the same second), both say the same honest
/// fact rather than an invented one.
///
/// The SAME rule labels every face that names a place on the grant road: the
/// grant sheet's rows, its WHERE field and confirm, the ask sheet's title and
/// the pane's shared rows. Words are app voice, sentence case, 13s-a
/// sweepable. Pure: no GRDB, no AppKit; every clock and calendar is passed.
public enum PlaceLabels {
    /// A place's state marks, in the Bookcase row's own order
    /// (`BookcaseRowMeta.facts`: living · sealed|finished · owned), then archived
    /// (the pickers' "(archived)" mark).
    public struct Marks: Equatable, Sendable {
        public var living: Bool
        public var finished: Bool
        public var sealed: Bool
        public var owned: Bool
        public var archived: Bool

        public init(
            living: Bool = false, finished: Bool = false, sealed: Bool = false,
            owned: Bool = false, archived: Bool = false
        ) {
            self.living = living
            self.finished = finished
            self.sealed = sealed
            self.owned = owned
            self.archived = archived
        }

        /// The words, in order. Sealed implies finished and says only
        /// "sealed" (the Bookcase's rule).
        public var words: [String] {
            var words: [String] = []
            if living { words.append("living") }
            if sealed {
                words.append("sealed")
            } else if finished {
                words.append("finished")
            }
            if owned { words.append("owned") }
            if archived { words.append("archived") }
            return words
        }
    }

    /// One place the grant road can name: a BOOK (every fact) or a WING (a
    /// name and a made stamp — a wing has no shelf, count or state).
    public struct Place: Equatable, Sendable, Identifiable {
        public var id: String
        public var name: String
        /// A book's wing BY NAME ("Home" for the virtual Home wing); nil for
        /// a place that is itself a wing.
        public var wing: String?
        /// True when the book lives in Home — the context line names only
        /// the other wings (a single-wing library never reads "Home wing").
        public var inHome: Bool
        /// The book's shelf by name; nil = unshelved (a book) or none (a wing).
        public var shelf: String?
        /// The notes the book SHOWS (the Bookcase's honest "N notes"); nil
        /// for a wing.
        public var noteCount: Int?
        public var marks: Marks
        public var madeAt: Date
        /// The book's derived "last edited" (the Bookcase's own); nil = none
        /// said.
        public var lastEdited: Date?

        public init(
            id: String, name: String, wing: String? = nil, inHome: Bool = true,
            shelf: String? = nil, noteCount: Int? = nil, marks: Marks = Marks(),
            madeAt: Date, lastEdited: Date? = nil
        ) {
            self.id = id
            self.name = name
            self.wing = wing
            self.inHome = inHome
            self.shelf = shelf
            self.noteCount = noteCount
            self.marks = marks
            self.madeAt = madeAt
            self.lastEdited = lastEdited
        }

        /// A wing as a place (its name and when it was made).
        public static func wing(id: String, name: String, madeAt: Date) -> Place {
            Place(id: id, name: name, wing: nil, inHome: false, madeAt: madeAt)
        }

        var isBook: Bool { noteCount != nil }
    }

    // MARK: - The context line

    /// The quiet footing beside a place, in the ONE fixed order: (a non-Home
    /// book's wing) · shelf · N notes · state marks · last edited. Empty for
    /// a wing.
    public static func context(
        _ place: Place, now: Date,
        calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> String {
        guard place.isBook else { return "" }
        var parts: [String] = []
        if !place.inHome, let wing = place.wing { parts.append(wingWords(wing)) }
        if let shelf = place.shelf { parts.append(shelf) }
        if let count = place.noteCount { parts.append(notes(count)) }
        parts += place.marks.words
        if let edited = place.lastEdited {
            parts.append(TimeStampFace.stamp(.edited, date: edited, now: now, calendar: calendar, locale: locale))
        }
        return parts.joined(separator: separator)
    }

    /// "1 note" · "12 notes" — the Bookcase's own count words.
    public static func notes(_ count: Int) -> String {
        "\(count) \(count == 1 ? "note" : "notes")"
    }

    static func wingWords(_ name: String) -> String { "\(name) wing" }

    public static let separator = " \u{00B7} "
    /// A shelfless book's word on the shelf rung.
    public static let unshelved = "unshelved"

    // MARK: - The distinguisher

    /// **Two places, one name** — the picker brain's sameness: trimmed, case-
    /// and diacritic-insensitive ("Café" is "cafe"; "Sherlock" is "sherlock").
    public static func sameName(_ lhs: String, _ rhs: String) -> Bool {
        collisionKey(lhs) == collisionKey(rhs)
    }

    static func collisionKey(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
    }

    /// The rungs, in the ladder's fixed order. Each answers a place's value
    /// on that rung, or nil when the place has none (skipped for it).
    enum Rung: CaseIterable {
        case wing, shelf, noteCount, state, madeDay, madeTime, madeSecond
    }

    static func value(
        _ rung: Rung, of place: Place, now: Date, calendar: Calendar, locale: Locale
    ) -> String? {
        switch rung {
        case .wing:
            return place.wing.map(wingWords)
        case .shelf:
            guard place.isBook else { return nil }
            return place.shelf ?? unshelved
        case .noteCount:
            return place.noteCount.map(notes)
        case .state:
            let words = place.marks.words
            return words.isEmpty ? nil : words.joined(separator: separator)
        case .madeDay:
            return "made " + TimeStampFace.day(place.madeAt, now: now, calendar: calendar, locale: locale)
        case .madeTime, .madeSecond:
            let day = TimeStampFace.day(place.madeAt, now: now, calendar: calendar, locale: locale)
            let time = TimeStampFace.time(
                place.madeAt, seconds: rung == .madeSecond, calendar: calendar, locale: locale)
            return "made \(day), \(time)"
        }
    }

    /// **The distinguisher for every place that shares its name with another
    /// OFFERED place** — keyed by place id; a place whose name is its own
    /// has no entry (it needs none). See the type's header for the rule.
    public static func disambiguate(
        _ places: [Place], now: Date,
        calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> [String: String] {
        var groups: [String: [Place]] = [:]
        for place in places { groups[collisionKey(place.name), default: []].append(place) }
        var answer: [String: String] = [:]
        for group in groups.values where group.count > 1 {
            for place in group {
                answer[place.id] = distinguisher(
                    for: place, among: group, now: now, calendar: calendar, locale: locale)
            }
        }
        return answer
    }

    static func distinguisher(
        for place: Place, among group: [Place], now: Date, calendar: Calendar, locale: Locale
    ) -> String {
        let others = group.filter { $0.id != place.id }
        var last: String?
        for rung in Rung.allCases {
            guard let mine = value(rung, of: place, now: now, calendar: calendar, locale: locale) else {
                continue
            }
            last = mine
            let shared = others.contains {
                value(rung, of: $0, now: now, calendar: calendar, locale: locale) == mine
            }
            if !shared { return mine }
        }
        // Every rung agrees with someone — two places minted in the same
        // second. The finest fact, said honestly (never an ordinal).
        return last ?? ""
    }

    /// A name with its distinguisher, as a title reads it: `“name” (made
    /// Oct 9)` — the confirm, the ask sheet's title, the pane's rows.
    public static func quoted(_ name: String, distinguisher: String?) -> String {
        let quoted = "\u{201C}\(name)\u{201D}"
        guard let distinguisher, !distinguisher.isEmpty else { return quoted }
        return "\(quoted) (\(distinguisher))"
    }
}
