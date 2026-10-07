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

    /// The query's echo — the words, as typed, in quotes (the mockup's
    /// `“dream”`).
    static func echo(_ words: String) -> String {
        "\u{201C}\(words)\u{201D}"
    }

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

    /// The archived facet's chip (D4): an invitation at rest, the armed word
    /// with its ✕ when on.
    static let archivedOff = "+ archived"
    static let archivedOn = "archived"
    static let archivedOffHelp = "Include archived notes, books and takes"
    static let archivedOnHelp = "Back to the living library \u{2014} leave the archive out"

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

    /// **A tag typed without words** (PROVISIONAL P-13o-U2-6): the band
    /// names the tag; the sheet asks for the words.
    static func tagAlone(_ paths: [String]) -> String {
        "Type a word to search inside " + paths.map(tagChip).joined(separator: " ") + "."
    }

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

    /// "all N ›" — the group's whole road (R-13o-9).
    static func allLines(_ n: Int) -> String { "all \(n) \u{203A}" }
    /// The open group's road closed again.
    static let fewerLines = "fewer \u{2039}"
    /// The next page of an open group's passages.
    static let moreLines = "more \u{203A}"
    static let loadingMore = "loading more\u{2026}"

    /// The badge a hit in an UNRENDERED take wears (the mockup's own).
    static let inAnotherTake = "in another take"

    /// What a non-prose passage IS — said before its words, so a block's
    /// name never reads as its prose (PROVISIONAL P-13o-U2-8). Takes and
    /// titles say nothing (the line is prose; the head is the title).
    static func kindWord(_ kind: SearchPassage.Kind) -> String? {
        switch kind {
        case .take, .title, .wornDay: nil
        case .takeLabel: "take label"
        case .blockName: "block name"
        case .comment: "comment"
        case .noteMeta: "floating notes"
        case .book: "book"
        case .chapter: "chapter"
        }
    }

    /// An archived group's mark (only ever drawn under the facet) — and,
    /// since 13o U3, the badge an archived passage wears.
    static let archivedMark = "archived"

    /// **An archived NOTE's line under its head** (13o U3 — under the facet
    /// the rows say which they are; PROVISIONAL P-13o-U3-5's words).
    static let archivedNote = "archived note \u{2014} kept out of the Library"

    /// An archived BOOK's row detail ("book · archived").
    static func archivedBookDetail(_ detail: String?) -> String {
        (detail.map { $0 + " \u{00B7} " } ?? "") + archivedMark
    }

    /// **The archived foot** (D4 — PROVISIONAL P-13o-U2-3's wording): with
    /// the facet off and archived matches present, the sheet's last line
    /// says how many places they would add, with the door.
    static func archivedFoot(_ places: Int) -> String {
        "\(places) more in the archive \u{2014}"
    }

    static let showArchived = "show archived"
}
