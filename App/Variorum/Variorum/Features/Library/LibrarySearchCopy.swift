//
//  LibrarySearchCopy.swift
//  Variorum (Mac)
//
//  **13o U2 — what the search state SAYS** (Direction C, R-13o-15): the
//  band's echo, its honest counts and its chips; the answer sheet's section
//  words, its "all N ›" road, its kind words and its archived foot. One
//  place, so no sentence lives as a literal in a view body (review focus
//  F-0), and 13s may re-voice every one of them from here. Each is
//  PROVISIONAL where the mockup did not already say it (P-13o-U2-3/7/8).
//

import Foundation
import VariorumCore

nonisolated enum LibrarySearchCopy {
    // MARK: - The band

    // 13o U3: the words BOTH answer sheets say moved to their shared home
    // (`SearchAnswerCopy`, `Core/Views/SearchAnswerFaces.swift`); the names
    // below FORWARD, so every pre-move reader and pin reads unchanged.

    static func echo(_ words: String) -> String { SearchAnswerCopy.echo(words) }

    /// **The honest counts** (D3): what the WHOLE question finds, per kind —
    /// "3 books · 29 notes · 118 passages · 6 scraps", a kind with nothing
    /// left out; nothing at all is said as such.
    static func counts(_ kinds: SearchCounts.Kinds) -> String {
        var parts: [String] = []
        func add(_ n: Int, _ one: String, _ many: String) {
            if n > 0 { parts.append("\(n) \(n == 1 ? one : many)") }
        }
        add(kinds.books, "book", "books")
        add(kinds.notes, "note", "notes")
        add(kinds.passages, "passage", "passages")
        add(kinds.scraps, "scrap", "scraps")
        // VX-84a: a tag typed alone names BLOCKS by their own tags too.
        add(kinds.blocks, "block", "blocks")
        return parts.isEmpty ? nothingFound : parts.joined(separator: " \u{00B7} ")
    }

    static let nothingFound = "nothing found"

    /// The wing chip — "search scopes by wing, period" (the 13i sitting
    /// record §12), said where she can see it.
    static func wingChip(_ name: String) -> String { "in: \(name)" }

    /// A typed tag's chip (the capture-microsyntax feel — typed things
    /// become chips); its ✕ takes the tag out of the field.
    static func tagChip(_ path: String) -> String { "#\(path)" }
    static func removeTagHelp(_ path: String) -> String { "Stop narrowing to #\(path)" }

    static var archivedOff: String { SearchAnswerCopy.archivedOff }
    static var archivedOn: String { SearchAnswerCopy.archivedOn }
    static var archivedOffHelp: String { SearchAnswerCopy.archivedOffHelp }
    static var archivedOnHelp: String { SearchAnswerCopy.archivedOnHelp }

    /// **The mode facet's chip** (13o U3 — the mockup's `+ book state`; the
    /// 13i sitting record §12's mode facets, facts never tags). The
    /// invitation, its five choices (the mockup's own words — Direction B's
    /// "Books that are: gathering · living · owned · finished · sealed"), and
    /// the armed chip's noun (PROVISIONAL P-13o-U3-2: a state alone in a
    /// chip reads as a noun of books, so it says so).
    static let bookStateOff = "+ book state"
    static let bookStateOffHelp = "Narrow the books to one state \u{2014} "
        + "gatherings, living, owned, finished or sealed"
    static let bookStateOnHelp = "Back to every book, whatever its state"

    /// The scope picker's help while a facet is armed (it stands down, as
    /// under a day — a facet names books).
    static let scopeDoorUnderABookState = "A book state names books \u{2014} "
        + "clear it in the band to search notes and blocks again"

    static func bookStateChoice(_ state: SearchBookState) -> String {
        switch state {
        case .gathering: "gathering"
        case .living: "living"
        case .owned: "owned"
        case .finished: "finished"
        case .sealed: "sealed"
        }
    }

    static func bookStateChip(_ state: SearchBookState) -> String {
        switch state {
        case .gathering: "gatherings"
        case .living: "living books"
        case .owned: "owned books"
        case .finished: "finished books"
        case .sealed: "sealed books"
        }
    }

    /// **Why an ASSOCIATED book is listed** (13o U3 — the tag-association
    /// join; the mockup's own "#dream flows here"). Notes carrying the typed
    /// tag flow into it, or its writing carries the tag (the outflow — the
    /// Collecting pane's "Notes written here are tagged"). PROVISIONAL
    /// P-13o-U3-2 for the second's words.
    static func association(_ reason: SearchTagAssociation.Reason) -> String {
        switch reason {
        case .flowsIn(let path): "#\(path) flows here"
        case .taggedHere(let path): "notes here are tagged #\(path)"
        }
    }

    // (VX-84a: `tagAlone` — "Type a word to search inside #tag." — DIED with
    // P-13o-U2-6. A tag typed alone narrows the Library's own listing now
    // (D-1), so nothing asks for words.)

    /// The listing's section for a tag's blocks (VX-84a — the Blocks scope
    /// under a tag typed alone).
    static let blocksHeader = "Blocks"

    /// A listed block's home, beside its handle (the pre-U2 block row's
    /// words).
    static func blockHome(_ home: String) -> String { "in \(home)" }

    /// **The sort door, while the answer sheet shows** (PROVISIONAL
    /// P-13o-U2-7): the sheet is ranked by relevance (D2) — the mockup's own
    /// words, as a label, because a menu that could not change the order
    /// would be a door that cannot act (P-2).
    static let relevance = "relevance \u{00B7} best first"
    static let relevanceHelp = "Search results are ranked by how well they match \u{2014} "
        + "the best match first"

    // MARK: - The sheet

    static let booksHeader = "Books"

    /// The groups' section word, by scope (the mockup's "Notes, with their
    /// passages"; the Blocks scope's groups are named blocks and scraps).
    static func groupsHeader(_ scope: LibraryCatalogModel.Scope) -> String {
        scope == .blocks ? "Blocks & scraps" : "Notes, with their passages"
    }

    /// A scraps group's home word (the mockup's "· in Snippets").
    static let inSnippets = "in Snippets"

    static func allLines(_ n: Int) -> String { SearchAnswerCopy.allLines(n) }
    static var fewerLines: String { SearchAnswerCopy.fewerLines }
    static var moreLines: String { SearchAnswerCopy.moreLines }
    static var loadingMore: String { SearchAnswerCopy.loadingMore }
    static var inAnotherTake: String { SearchAnswerCopy.inAnotherTake }
    static func kindWord(_ kind: SearchPassage.Kind) -> String? { SearchAnswerCopy.kindWord(kind) }
    static var archivedMark: String { SearchAnswerCopy.archivedMark }
    static var archivedNote: String { SearchAnswerCopy.archivedNote }

    /// An archived BOOK's row detail ("book · archived").
    static func archivedBookDetail(_ detail: String?) -> String {
        (detail.map { $0 + " \u{00B7} " } ?? "") + archivedMark
    }

    static func archivedFoot(_ places: Int) -> String { SearchAnswerCopy.archivedFoot(places) }
    static var showArchived: String { SearchAnswerCopy.showArchived }
}
