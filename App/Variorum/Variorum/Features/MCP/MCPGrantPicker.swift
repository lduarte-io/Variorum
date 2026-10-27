//
//  MCPGrantPicker.swift
//  Variorum (MAC ONLY)
//
//  13n-c U2 — THE GRANT SHEET's BRAIN (VX-156 items 1 + 6; her kickoff's
//  "keep in mind a user might have hundreds of books and notes. perhaps a sort
//  by shelf would also be helpful, ability to see favorites"; round 2's
//  "recently edited … that's often what I want"). Pure, so the pins read it
//  without a window (P-9: the sheet renders and sends; this decides):
//
//  - the BOOK picker's two layouts over the ONE read (`MCPGrantPlaces`):
//    **by shelf** — Recently edited → Starred (both QUICK: they repeat rows and
//    show only before typing) → one section per shelf in the Bookcase's strip
//    order, per wing (Home first, then the wings in switcher order; a wing
//    other than Home names itself in its sections) → Unshelved; and **a–z** —
//    the same quick sections, then every book in one list ("All books"). Inside a section,
//    the Bookcase's own a–z (digit-aware). Each row: the name, the
//    distinguisher (accent) when its name collides, and the context line
//    (`PlaceLabels`) under it.
//  - the WING and WHO pickers' rows;
//  - the NOTE feed's rows (the bounded `corpusNotes` road, fence-marked);
//  - the DURATIONS a target can take and the one-line WHY when one is
//    withheld (U1's while-connected rule + the fence's never-always).
//

import Foundation
import VariorumCore

nonisolated enum MCPGrantPicker {
    // MARK: - Books

    /// The book picker's layouts (PROVISIONAL P-13nc-U2-3 — "by shelf" first,
    /// her ask; "a–z" beside it).
    static func bookArrangements(
        _ places: MCPGrantPlaces, now: Date,
        calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> [SearchPickerArrangement] {
        let distinguishers = places.bookDistinguishers(now: now, calendar: calendar, locale: locale)
        func option(_ book: Queries.MCPGrantableBook) -> SearchPickerOption {
            bookOption(book, places: places, distinguisher: distinguishers[book.id],
                       now: now, calendar: calendar, locale: locale)
        }
        let quick = quickSections(places, option: option)
        var byShelf = quick
        for wing in places.wingChoices {
            let wingLabel: String? = wing.id.isEmpty ? nil : wing.name
            let inWing = places.books.filter { $0.wingID == wing.id }
            for shelf in places.shelves(inWing: wing.id) {
                byShelf.append(SearchPickerSection(
                    id: "shelf:\(shelf.id)",
                    title: MCPPaneCopy.shelfSection(shelf.name, glyph: shelf.glyph, wing: wingLabel),
                    options: alphabetical(inWing.filter { $0.shelfID == shelf.id }).map(option)))
            }
            byShelf.append(SearchPickerSection(
                id: "unshelved:\(wing.id)",
                title: MCPPaneCopy.unshelvedSection(wing: wingLabel),
                options: alphabetical(inWing.filter { $0.shelfID == nil }).map(option)))
        }
        let az = quick + [SearchPickerSection(
            id: "all", title: MCPPaneCopy.allBooks, options: alphabetical(places.books).map(option))]
        return [
            SearchPickerArrangement(id: "shelf", label: MCPPaneCopy.byShelf, sections: byShelf),
            SearchPickerArrangement(id: "az", label: MCPPaneCopy.alphabetical, sections: az),
        ]
    }

    private static func quickSections(
        _ places: MCPGrantPlaces, option: (Queries.MCPGrantableBook) -> SearchPickerOption
    ) -> [SearchPickerSection] {
        [
            SearchPickerSection(
                id: "recent", title: MCPPaneCopy.recentlyEdited,
                options: places.recentlyEdited().map(option), isQuick: true),
            SearchPickerSection(
                id: "starred", title: MCPPaneCopy.starred,
                options: alphabetical(places.books.filter(\.starred)).map(option), isQuick: true),
        ]
    }

    /// The Bookcase's own a–z: digit-aware, then id.
    static func alphabetical(_ books: [Queries.MCPGrantableBook]) -> [Queries.MCPGrantableBook] {
        books.sorted { lhs, rhs in
            switch lhs.name.localizedStandardCompare(rhs.name) {
            case .orderedAscending: true
            case .orderedDescending: false
            case .orderedSame: lhs.id < rhs.id
            }
        }
    }

    static func bookOption(
        _ book: Queries.MCPGrantableBook, places: MCPGrantPlaces, distinguisher: String?, now: Date,
        calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> SearchPickerOption {
        var context = PlaceLabels.context(places.place(book), now: now, calendar: calendar, locale: locale)
        // 13n-c UX walk W-UX-16: the distinguisher is a FACT the context line
        // also says (its shelf, its wing, its count, its state) — said once, as
        // the distinguisher (emphasized), never twice on one row ("Welcome ·
        // 13 notes …" beside "Welcome").
        if let distinguisher {
            let echoed = Set(distinguisher.components(separatedBy: PlaceLabels.separator))
            context = context.components(separatedBy: PlaceLabels.separator)
                .filter { !echoed.contains($0) }
                .joined(separator: PlaceLabels.separator)
        }
        // VX-351 (her R-VX348-3): the context line's "edited …" hovers its
        // whole fact — the Bookcase's own derived last edit, to the minute.
        let edited = places.place(book).lastEdited.map {
            TimeStampFace.tooltip(.edited, date: $0, calendar: calendar, locale: locale)
        }
        return SearchPickerOption(
            id: book.id, label: book.name, annotation: distinguisher, searchText: book.name,
            detail: context.isEmpty ? nil : context, emphasized: distinguisher != nil, help: edited)
    }

    // MARK: - Gatherings (VX-549)

    /// **The gathering picker's layout** (VX-549 — her sitting: "Gathering
    /// joins the grant scopes"; the ONE picker control): Starred (quick, before
    /// typing — the union star the Bookcase floats first) → every offered
    /// gathering a–z, one section. Each row: the name, its distinguisher where
    /// the name collides, and its footing — a non-Home wing, its shelf, its
    /// archived state. (VX-596 retired VX-549's "read and suggest only" footing
    /// with the shaping it named — the ticket's wording point 2.)
    static func gatheringArrangements(
        _ places: MCPGrantPlaces, now: Date,
        calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> [SearchPickerArrangement] {
        let distinguishers = places.gatheringDistinguishers(now: now, calendar: calendar, locale: locale)
        func option(_ gathering: Queries.MCPGrantableGathering) -> SearchPickerOption {
            gatheringOption(gathering, places: places, distinguisher: distinguishers[gathering.id])
        }
        let ordered = places.gatherings.sorted { lhs, rhs in
            switch lhs.name.localizedStandardCompare(rhs.name) {
            case .orderedAscending: true
            case .orderedDescending: false
            case .orderedSame: lhs.id < rhs.id
            }
        }
        return [SearchPickerArrangement(id: "az", label: MCPPaneCopy.alphabetical, sections: [
            SearchPickerSection(
                id: "starred", title: MCPPaneCopy.starred, options: ordered.filter(\.starred).map(option),
                isQuick: true),
            SearchPickerSection(id: "all", title: MCPPaneCopy.allGatherings, options: ordered.map(option)),
        ])]
    }

    static func gatheringOption(
        _ gathering: Queries.MCPGrantableGathering, places: MCPGrantPlaces, distinguisher: String?
    ) -> SearchPickerOption {
        let place = places.place(gathering)
        var parts: [String] = []
        if !place.inHome, let wing = place.wing { parts.append("\(wing) wing") }
        parts.append(place.shelf ?? PlaceLabels.unshelved)
        parts += place.marks.words
        let echoed = Set((distinguisher ?? "").components(separatedBy: PlaceLabels.separator))
        let context = parts.filter { !echoed.contains($0) }.joined(separator: PlaceLabels.separator)
        return SearchPickerOption(
            id: gathering.id, label: gathering.name, annotation: distinguisher, searchText: gathering.name,
            detail: context.isEmpty ? nil : context, emphasized: distinguisher != nil)
    }

    /// **The heads-up a star-rule gathering's grant wears at write new or
    /// edit** (VX-596 — her ruling 2026-10-27, "let's add the star over the
    /// wire"; the ticket's wording point 1). VX-549 offered such a gathering
    /// read and suggest only (`offeredRungs(needsStar:)`, retired here): a
    /// client could never star, so it could never write a note in. Now the wire
    /// stars where the rule needs it, so every rung is offered, and at the rungs
    /// that write a new note (write new, and edit, which includes it) the sheet
    /// says the one consequence for her stars. Nil elsewhere — read and suggest
    /// write no note; a tag rule stars nothing.
    static func starHeadsUp(needsStar: Bool, rung: MCPGrantRule.Rung) -> String? {
        needsStar && rung >= .writeNew ? MCPPaneCopy.starHeadsUp : nil
    }

    // MARK: - Wings and clients

    static func wingOptions(
        _ places: MCPGrantPlaces, now: Date,
        calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> [SearchPickerOption] {
        let distinguishers = places.wingDistinguishers(now: now, calendar: calendar, locale: locale)
        return places.wingChoices.map { wing in
            SearchPickerOption(
                id: wing.id, label: wing.name, annotation: distinguishers[wing.id],
                emphasized: distinguishers[wing.id] != nil)
        }
    }

    /// WHO: the approved clients in the read's order (most recently granted
    /// first), each saying whether it is connected now.
    static func clientOptions(_ clients: [MCPClient], connected: Set<String>) -> [SearchPickerOption] {
        clients.map { client in
            SearchPickerOption(
                id: client.id, label: client.name,
                annotation: connected.contains(client.name) ? MCPPaneCopy.connectedNow : nil)
        }
    }

    // MARK: - Notes

    /// One row of the note leg: the bounded feed's hit, with its fence (read
    /// on the ONE derivation site — `mcpNoteFacts`).
    struct NoteRow: Equatable, Sendable, Identifiable {
        let id: String
        let title: String
        let snippet: String?
        /// The row's day words (the note picker's own detail), if any.
        let day: String?
        let fence: MCPGrantRule.Fence?
        /// Its wing (a pre-filled note sets the leg's wing to its own).
        var wingID: String? = nil
        /// VX-351 (the VX-348 run, U4 — her R-VX348-3, the grant picker
        /// named): the day's whole fact, the note picker's own
        /// (`NotePickerRow.detailHelp`); nil when the row says no day.
        var dayHelp: String? = nil
    }

    /// The note leg's sections: before typing, the feed's recent-first rows
    /// under "Recently edited" (the feed's resting state IS that); once
    /// typing, its matches, untitled. A fenced note stays pickable — a
    /// per-ask note grant is legal (mockup §1) — and wears its fence word.
    static func noteSections(
        _ rows: [NoteRow], query: String, now: Date = Date(),
        calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> [SearchPickerSection] {
        guard !rows.isEmpty else { return [] }
        let typing = !SearchPickerBrain.normalized(query).isEmpty
        return [SearchPickerSection(
            id: typing ? "matches" : "recent",
            title: typing ? nil : MCPPaneCopy.recentlyEdited,
            options: rows.map { row in
                SearchPickerOption(
                    id: row.id, label: row.title,
                    annotation: row.fence.map(MCPPaneCopy.noteFenceWord)
                        ?? row.day.map { dayWords($0, now: now, calendar: calendar, locale: locale) },
                    detail: row.snippet, emphasized: row.fence != nil,
                    // VX-351: the day's whole fact — only while the day is
                    // what the row says (a fence word stands in its place).
                    help: row.fence == nil ? row.dayHelp : nil)
            })]
    }

    /// The feed's day KEY ("2026-09-30") in the sheet's own day words ("Sep
    /// 30" — `TimeStampFace.day`, the words the book rows' "edited …" use;
    /// mockup §1's "3 Oct"). A value that is not a day key passes through.
    static func dayWords(
        _ day: String, now: Date, calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> String {
        guard let date = JournalDay.date(from: day, calendar: calendar) else { return day }
        return TimeStampFace.day(date, now: now, calendar: calendar, locale: locale)
    }

    // MARK: - How long

    /// **The durations every picked target can take** (her "durations shrunk
    /// to what every picked target can take"): "while connected" only while
    /// the client IS connected (U1's walk rule — `MCPGrantSheet.durations`),
    /// and never "always" on a fenced note (R-13n-4; the op refuses it).
    static func durations(connected: Bool, noteFence: MCPGrantRule.Fence?) -> [MCPGrantRule.Duration] {
        MCPGrantSheet.durations(connected: connected).filter { !(noteFence != nil && $0 == .always) }
    }

    /// The one-line WHYs for what is withheld, in the sheet's order.
    static func durationWhys(
        connected: Bool, clientChosen: Bool, note: (title: String, fence: MCPGrantRule.Fence)?,
        throughBooks: [String] = []
    ) -> [String] {
        var whys: [String] = []
        if let note { whys.append(MCPPaneCopy.alwaysWithheld(note.title, note.fence, throughBooks: throughBooks)) }
        if clientChosen, !connected { whys.append(MCPPaneCopy.whileConnectedNote) }
        return whys
    }
}
