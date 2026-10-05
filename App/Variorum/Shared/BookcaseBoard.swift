//
//  BookcaseBoard.swift
//  Variorum — App/Variorum/Shared (BOTH platforms compile it; the Mac reads it first)
//
//  **THE BOOKCASE'S BOARD BRAIN** (13i-d U1 — the sitting record §7, §19–§24;
//  mockup v5 `notes/plans/mockups/13i-bookcase-shelves.html`, whose SHAPE
//  binds and whose incidentals do not, §22).
//
//  Everything the board DECIDES, as pure functions over the held snapshot —
//  which shelf a book sits on, the three orders and the starred float, the
//  № census and its six solos, the sections All and a solo'd shelf draw, and
//  where a context mint lands. A view renders these answers; it never
//  re-derives them (P-3's authority rule, one level up). Shared, because the
//  phone owes the same board (the sitting §18.5 — "the Bookcase/shelf strip
//  as a list"): the brain is shared, the chrome is not (the `ShelfOrder`
//  precedent beside it, which keeps the phone's shipped pin-then-journal
//  order until the phone's catch-up adopts this).
//
//  The rules that the OPERATIONS layer must agree with (A–Z, the my-order
//  sequence, the dangling-shelf rule) live in core `BookcaseOrdering`; this
//  file only composes them.
//

import Foundation
import VariorumCore

/// **The Bookcase's sort** (§24, ruled): `order ▾` = A–Z (the DEFAULT — her
/// words: *"the cleanest rule for all and makes it seem more neat and
/// serious"*) · last edited · my order (the PLACING mode). View-local and
/// remembered; applies WITHIN every shelf and the unshelved run; starred
/// books float first under any of them.
nonisolated enum BookcaseOrderMode: String, CaseIterable, Sendable {
    case alphabetical, lastEdited, mine

    /// The menu's words ("my order" is a 13s copy candidate — §24).
    var label: String {
        switch self {
        case .alphabetical: "A\u{2013}Z"
        case .lastEdited: "last edited"
        case .mine: "my order"
        }
    }
}

/// What the strip has selected: ALL (every shelf stacked, unshelved at the
/// top), ONE shelf solo'd — or the STARRED shelf (17y item (s), R-17y-9).
nonisolated enum BookcaseScope: Hashable, Sendable {
    case all
    case shelf(String)
    /// **THE STARRED SHELF** (17y item (s) — R-17y-9, her words: "in library,
    /// have an automatic 'starred' shelf that isn't deletable… it is the
    /// books only… i do think build now"). VIRTUAL by construction (the
    /// Home-wing precedent, R-13ia-2): no `shelf` row exists for it, so it
    /// is undeletable, unrenamable, convergence-proof and schema-free
    /// STRUCTURALLY — never by a guard. It is a FILTER, never a container:
    /// a book shown there still lives on its real shelf (the starred float's
    /// sibling, not its replacement). "Books only" = the Bookcase's readings
    /// (books and gatherings) wearing the union star — never notes (the
    /// sidebar's Starred section, untouched, lists both).
    case starred
}

/// **The № census's six SOLO filters** (§23: *"books · gatherings · finished
/// · owned · living · with arrivals"*). One at a time; again clears.
nonisolated enum BookcaseSolo: String, CaseIterable, Sendable {
    case books, gatherings, finished, owned, living, arrivals

    func matches(_ book: Queries.ShelfBook) -> Bool {
        let reading = book.reading
        switch self {
        case .books: return reading.kind == .book
        case .gatherings: return reading.kind == .gathering
        // Sealed is Finished + text immutability (§5), so it counts here.
        case .finished: return reading.locked
        case .owned: return reading.owned
        case .living: return BookcaseBoard.isLiving(reading)
        case .arrivals: return book.arrivalCount > 0
        }
    }

    /// The census row's words for a count ("8 books", "1 with arrivals").
    func label(count: Int) -> String {
        switch self {
        case .books: "\(count) \(count == 1 ? "book" : "books")"
        case .gatherings: "\(count) \(count == 1 ? "gathering" : "gatherings")"
        case .finished: "\(count) finished"
        case .owned: "\(count) owned"
        case .living: "\(count) living"
        case .arrivals: "\(count) with arrivals"
        }
    }
}

nonisolated enum BookcaseBoard {
    /// One drawn section: the UNSHELVED run or a shelf, with its books in
    /// display order (starred first, then the chosen order).
    struct Section: Equatable, Identifiable, Sendable {
        enum Kind: Equatable, Sendable {
            case unshelved
            case shelf(Shelf)
            /// 17y (s): the starred shelf's one section (a filter — its books
            /// keep their real shelves).
            case starred
        }

        let kind: Kind
        let books: [Queries.ShelfBook]

        /// The collapse memory's key (and the view's identity).
        var id: String {
            switch kind {
            case .unshelved: "unshelved"
            case .shelf(let shelf): shelf.id
            case .starred: BookcaseBoard.starredSectionID
            }
        }

        /// The resolved shelf this section IS (nil = unshelved) — the target
        /// a drop onto its header re-shelves to.
        var shelfID: String? {
            if case .shelf(let shelf) = kind { return shelf.id }
            return nil
        }
    }

    /// **LIVING** (the sitting record §1: *"any book whose intake is on"*):
    /// a live BOOK, not finished, whose rule reads — the intake's own
    /// candidate predicate (`Operations.livingBooks`), stated once for faces.
    static func isLiving(_ reading: Reading) -> Bool {
        guard reading.kind == .book, !reading.locked else { return false }
        if case .rule = RuleGrammar.read(reading.querySpec) { return true }
        return false
    }

    /// The scope as it can be drawn: a solo'd shelf that died (deleted here
    /// or by a sync) reads as ALL — the dangling class, never an empty
    /// board that names nothing.
    static func effectiveScope(_ scope: BookcaseScope, shelves: [Shelf]) -> BookcaseScope {
        if case .shelf(let id) = scope, !shelves.contains(where: { $0.id == id }) { return .all }
        return scope
    }

    /// **THE CONTEXT MINT** (§19.1, ratified §24): + New Book while a shelf
    /// is solo'd lands ON that shelf (*"you're looking at where you're
    /// filing"*); from All it lands UNSHELVED (§19's ruling).
    static func mintShelf(for scope: BookcaseScope, shelves: [Shelf]) -> String? {
        if case .shelf(let id) = effectiveScope(scope, shelves: shelves) { return id }
        // 17y (s): the starred shelf is a FILTER, never a place a book can be
        // put — a mint there lands unshelved, born unstarred (PROVISIONAL
        // P-17y-B3-s4; one line to flip to "born starred").
        return nil
    }

    /// The key of the UNSHELVED run wherever a shelf id is a dictionary key.
    static let unshelvedKey = ""

    /// The starred shelf's section id (17y (s)) — never a stored shelf's id
    /// (those are UUIDs), so it can collide with none.
    static let starredSectionID = "starred"

    /// **The starred shelf's books** (17y (s)): every reading on the board
    /// wearing the UNION star (`ShelfBook.starred` — the column OR the 13f
    /// list, 13i-d U2 ACT 0), from every shelf and the unshelved run.
    static func starredBooks(_ books: [Queries.ShelfBook]) -> [Queries.ShelfBook] {
        books.filter(\.starred)
    }

    /// Each book's resolved shelf — its id, or `unshelvedKey` (the dangling
    /// rule: a nil pointer, or one naming no live shelf of this wing).
    static func resolvedShelves(
        _ books: [Queries.ShelfBook], shelves: [Shelf]
    ) -> [String: String] {
        let live = Set(shelves.map(\.id))
        var out: [String: String] = [:]
        for book in books {
            out[book.reading.id] = BookcaseOrdering.resolvedShelf(
                of: book.reading, liveShelfIDs: live) ?? unshelvedKey
        }
        return out
    }

    /// How many books sit on each shelf (the strip's HOVER count, §21) —
    /// keyed by shelf id, `unshelvedKey` for the unshelved run.
    static func shelfCounts(_ books: [Queries.ShelfBook], shelves: [Shelf]) -> [String: Int] {
        var counts: [String: Int] = [:]
        for (_, key) in resolvedShelves(books, shelves: shelves) {
            counts[key, default: 0] += 1
        }
        return counts
    }

    /// **THE DISPLAY ORDER** for one run of books: STARRED first, then the
    /// chosen order inside each half (§24 — *"starred books float first
    /// under any order"*; §20 — the star is never a position).
    static func ordered(
        _ books: [Queries.ShelfBook], mode: BookcaseOrderMode, lastEdited: [String: String]
    ) -> [Queries.ShelfBook] {
        func sorted(_ run: [Queries.ShelfBook]) -> [Queries.ShelfBook] {
            switch mode {
            case .alphabetical:
                return run.sorted {
                    BookcaseOrdering.nameAscending(
                        ($0.reading.name, $0.reading.id), ($1.reading.name, $1.reading.id))
                }
            case .lastEdited:
                func stamp(_ book: Queries.ShelfBook) -> String {
                    lastEdited[book.reading.id]
                        ?? DateFormatter.variorumISO8601.string(from: book.reading.createdAt)
                }
                return run.sorted {
                    let (a, b) = (stamp($0), stamp($1))
                    if a != b { return a > b }  // newest first
                    return BookcaseOrdering.nameAscending(
                        ($0.reading.name, $0.reading.id), ($1.reading.name, $1.reading.id))
                }
            case .mine:
                let byID = Dictionary(uniqueKeysWithValues: run.map { ($0.reading.id, $0) })
                return BookcaseOrdering.placementSequence(run.map(\.reading))
                    .compactMap { byID[$0.id] }
            }
        }
        // 13i-d U2 ACT 0: `starred` is the UNION of the two stores (the
        // column and the 13f list — `ShelfBook.starred`), never the column.
        return sorted(books.filter(\.starred)) + sorted(books.filter { !$0.starred })
    }

    /// **Whether the book row's "Move to Shelf ▸" submenu can act** (P-2 —
    /// ladder A round 1, NIT 3: a shelf-less wing's unshelved book rendered
    /// an EMPTY submenu): there must be a shelf to move TO, or the book must
    /// be ON one so Unshelved is a destination. `here` is the book's resolved
    /// shelf key (`unshelvedKey` = the unshelved run).
    static func moveToShelfCanAct(shelfCount: Int, here: String?) -> Bool {
        shelfCount > 0 || here != unshelvedKey
    }

    /// **Whether the board's rows are PLACED BY HAND** (17y B2, item (b)):
    /// the ONE value the book row's drop site (a book dropped on a row lands
    /// right above it — P-13id-U1-12), its ⠿ grip (her drag-bars ask) and my
    /// order's Send to Top / Bottom all read — so the handle is drawn exactly
    /// where a drag can place (P-2; her "a handle that cannot drag must not
    /// render"). Under A–Z or last edited a hand position would not show.
    static func placesByHand(_ mode: BookcaseOrderMode) -> Bool {
        mode == .mine
    }

    /// **…and in a SCOPE** (17y (s)): the starred shelf is a filter over
    /// books from many shelves, and a hand position belongs to a REAL shelf —
    /// a row drop there would silently re-shelve the dropped book onto the
    /// target's shelf (`dropBook`'s first half). So placing by hand is off on
    /// the starred shelf: no grip, no row drop, no Send to Top/Bottom
    /// (PROVISIONAL P-17y-B3-s3). Every other scope reads the mode alone.
    static func placesByHand(_ mode: BookcaseOrderMode, in scope: BookcaseScope) -> Bool {
        scope != .starred && placesByHand(mode)
    }

    /// The № census over a set of books — every solo's count.
    static func census(_ books: [Queries.ShelfBook]) -> [BookcaseSolo: Int] {
        var counts: [BookcaseSolo: Int] = [:]
        for solo in BookcaseSolo.allCases {
            counts[solo] = books.filter(solo.matches).count
        }
        return counts
    }

    /// The books IN SCOPE before any solo (the census counts these — a
    /// count that promised books a solo could not show would be a lie).
    static func booksInScope(
        _ books: [Queries.ShelfBook], shelves: [Shelf], scope: BookcaseScope
    ) -> [Queries.ShelfBook] {
        switch effectiveScope(scope, shelves: shelves) {
        case .all:
            return books
        case .starred:
            return starredBooks(books)
        case .shelf(let id):
            let resolved = resolvedShelves(books, shelves: shelves)
            return books.filter { resolved[$0.reading.id] == id }
        }
    }

    /// **THE SECTIONS** the board draws.
    /// - A solo'd shelf: exactly one section, that shelf (empty or not).
    /// - ALL: UNSHELVED first, under its own header (§24's overrule — *"they're
    ///   the least convenient to find elsewhere"*), drawn only when it holds
    ///   something; then every shelf in STRIP ORDER (§24 — *"that will make it
    ///   clearer for people how the reordering works"*). An empty shelf still
    ///   draws its header (a new shelf must be visible), unless a SOLO is
    ///   active — then a shelf with no matches folds away (§22).
    static func sections(
        books: [Queries.ShelfBook], shelves: [Shelf], scope: BookcaseScope,
        solo: BookcaseSolo?, mode: BookcaseOrderMode, lastEdited: [String: String]
    ) -> [Section] {
        let resolved = resolvedShelves(books, shelves: shelves)
        let visible = solo.map { solo in books.filter(solo.matches) } ?? books
        func run(_ key: String) -> [Queries.ShelfBook] {
            ordered(
                visible.filter { resolved[$0.reading.id] == key },
                mode: mode, lastEdited: lastEdited)
        }
        switch effectiveScope(scope, shelves: shelves) {
        case .starred:
            // 17y (s): ONE section, every starred book from any shelf, in the
            // chosen order (all starred, so the float is moot), any solo
            // applied on top.
            return [Section(
                kind: .starred,
                books: ordered(starredBooks(visible), mode: mode, lastEdited: lastEdited))]
        case .shelf(let id):
            guard let shelf = shelves.first(where: { $0.id == id }) else { return [] }
            return [Section(kind: .shelf(shelf), books: run(id))]
        case .all:
            var out: [Section] = []
            let unshelved = run(unshelvedKey)
            if !unshelved.isEmpty { out.append(Section(kind: .unshelved, books: unshelved)) }
            for shelf in shelves {
                let onShelf = run(shelf.id)
                if solo != nil, onShelf.isEmpty { continue }
                out.append(Section(kind: .shelf(shelf), books: onShelf))
            }
            return out
        }
    }
}
