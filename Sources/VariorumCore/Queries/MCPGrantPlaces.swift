import Foundation

/// **WHAT THE GRANT SHEET'S PICKERS SHOW** (13n-c U2 — VX-156 items 1 + 6;
/// her kickoff's "sort by shelf … favorites"): the offered books with their
/// facts, the shelves they sit on (every wing's, in strip order) and the
/// additional wings — read once by `Queries.mcpGrantPlaces`, then answered
/// here purely: each book as a `PlaceLabels.Place` (its context line and its
/// distinguisher), the "Recently edited" quick section, and the wings as
/// places. The arrangement into picker SECTIONS is the sheet's (it owns the
/// picker's words); every FACT is decided here, once.
public struct MCPGrantPlaces: Equatable, Sendable {
    public var books: [Queries.MCPGrantableBook]
    /// Every live shelf of every wing, in strip order (`position`, `id`).
    public var shelves: [Shelf]
    /// The live additional wings, in switcher order (Home is virtual — '').
    public var wings: [Wing]
    /// VX-549: the offered gatherings (`Queries.mcpGrantableGatherings`).
    public var gatherings: [Queries.MCPGrantableGathering]

    public init(
        books: [Queries.MCPGrantableBook] = [], shelves: [Shelf] = [], wings: [Wing] = [],
        gatherings: [Queries.MCPGrantableGathering] = []
    ) {
        self.books = books
        self.shelves = shelves
        self.wings = wings
        self.gatherings = gatherings
    }

    /// A wing's name — "Home" for the virtual Home wing and for a dangling id
    /// (`mcpResolvedWing`'s reading).
    public func wingName(_ id: String) -> String {
        guard !id.isEmpty, let wing = wings.first(where: { $0.id == id }) else {
            return Queries.mcpHomeWingName
        }
        return wing.name
    }

    /// One wing's shelves in strip order.
    public func shelves(inWing wingID: String) -> [Shelf] {
        shelves.filter { $0.wingId == wingID }
    }

    /// The book as `PlaceLabels` reads it.
    public func place(_ book: Queries.MCPGrantableBook) -> PlaceLabels.Place {
        PlaceLabels.Place(
            id: book.id, name: book.name, wing: wingName(book.wingID), inHome: book.wingID.isEmpty,
            shelf: book.shelfID.flatMap { id in shelves.first { $0.id == id }?.name },
            noteCount: book.noteCount, marks: book.marks,
            madeAt: Self.date(book.createdAt), lastEdited: Self.date(book.lastEdited))
    }

    /// VX-549: a gathering as `PlaceLabels` reads it — its wing, shelf and
    /// archived state (no count: that would be an assembly).
    public func place(_ gathering: Queries.MCPGrantableGathering) -> PlaceLabels.Place {
        PlaceLabels.Place(
            id: gathering.id, name: gathering.name, wing: wingName(gathering.wingID),
            inHome: gathering.wingID.isEmpty,
            shelf: gathering.shelfID.flatMap { id in shelves.first { $0.id == id }?.name },
            marks: PlaceLabels.Marks(archived: gathering.archived), madeAt: Self.date(gathering.createdAt))
    }

    /// VX-549: the distinguisher of every offered gathering that shares its
    /// name with another offered gathering (the same ladder).
    public func gatheringDistinguishers(
        now: Date, calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> [String: String] {
        PlaceLabels.disambiguate(gatherings.map(place), now: now, calendar: calendar, locale: locale)
    }

    /// **The distinguisher of every offered book that shares its name with
    /// another** — the ladder over the OFFERED rows (`PlaceLabels`).
    public func bookDistinguishers(
        now: Date, calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> [String: String] {
        PlaceLabels.disambiguate(books.map(place), now: now, calendar: calendar, locale: locale)
    }

    /// **"Recently edited"** — the books most recently edited (their derived
    /// stamp, newest first; ties by id), at most `limit`.
    public func recentlyEdited(limit: Int = Queries.mcpRecentlyEditedCount) -> [Queries.MCPGrantableBook] {
        Array(books.sorted { lhs, rhs in
            lhs.lastEdited != rhs.lastEdited ? lhs.lastEdited > rhs.lastEdited : lhs.id < rhs.id
        }.prefix(max(0, limit)))
    }

    /// Home first, then every live wing in switcher order: (id, name).
    public var wingChoices: [(id: String, name: String)] {
        [("", Queries.mcpHomeWingName)] + wings.map { ($0.id, $0.name) }
    }

    /// **The wings' distinguishers** — two ADDITIONAL wings sharing a name
    /// tell apart by when each was made. The virtual Home has no made stamp,
    /// so it never joins a collision set (a wing she named "Home" collides
    /// only with another such wing — recorded edge, P-13nc-U2-5).
    public func wingDistinguishers(
        now: Date, calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
    ) -> [String: String] {
        PlaceLabels.disambiguate(
            wings.map { .wing(id: $0.id, name: $0.name, madeAt: $0.createdAt) },
            now: now, calendar: calendar, locale: locale)
    }

    static func date(_ stamp: String) -> Date {
        DateFormatter.variorumISO8601.date(from: stamp) ?? .distantPast
    }
}
