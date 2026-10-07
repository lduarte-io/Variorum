//
//  BookSearchModel.swift
//  Variorum (Mac)
//
//  **13o U3 — SEARCH WITHIN A BOOK, its own brain** (P-9). Her rulings: the
//  face — *"I like search this book to the right (option 1), but collapse it
//  into a magnifying glass and only expand it when clicked on"* (R-13o-14);
//  her standing want — *"maybe add a very capable search within a book if
//  needed"* (the 13i sitting record's third pass); and the architect's F1:
//  *"the answer sheet's small sibling in place of the book's content while
//  the field holds words"* — one search idiom in the whole app, landing
//  identical to the Library's.
//
//  The SAME engine as the Library's (R-13o-8 — every read is the one
//  composer's road): `Queries.searchGroups` / `searchCounts` /
//  `searchPassages` with the scope `.book(id)` — a BOOK's membership rows, or
//  a GATHERING's assembled members through the one membership function (the
//  architect's ruling B). The wing is the book's own (books never span wings).
//
//  What lives here: the field (open or resting as the glyph), its text read
//  into the one AST, the archived facet, the answer (counts, groups, their
//  road to the next page) and each group's "all N ›" expansion. What does
//  NOT: where a passage lands (the shell's road — `BookView` hands it on).
//

import Foundation
import GRDB
import Observation
import VariorumCore

@MainActor
@Observable
final class BookSearchModel {
    /// A group page (the Library's own size — one composer statement).
    nonisolated static let groupPageSize = 25
    /// Each group's top passages (Direction C's "top 3").
    nonisolated static let linesPerGroup = 3
    /// An "all N ›" page of one group's passages.
    nonisolated static let linePageSize = 50

    @ObservationIgnored let session: AppSession
    let readingID: String

    /// **The field is open** (R-13o-14: the glyph expands to the field on
    /// click; Esc, the glyph again, or leaving it empty collapses it).
    private(set) var isOpen = false
    /// The field's text, as typed.
    private(set) var text = ""
    /// The archived facet (D4's twin): never remembered, cleared with the
    /// field. Inside a GATHERING it can add nothing (an archived note is not
    /// an assembled member — the architect's ruling B's consequence), and the
    /// counts say so: its chip is offered only where the archive holds
    /// matches (`offersArchived`).
    private(set) var visibility: SearchVisibility = .living

    /// The question the LISTED answer answers (nil while the field asks
    /// nothing with words).
    private(set) var question: SearchQuery?
    /// The words as typed, the `#tags` aside — the band's echo.
    private(set) var words = ""
    private(set) var counts: SearchCounts?
    private(set) var groups: [SearchGroup] = []
    private(set) var next: SearchComposer.GroupCursor?
    private(set) var loadingMore = false
    /// The groups opened to "all N ›" — each its own paged road.
    private(set) var expansions: [String: Expansion] = [:]
    /// A failed read, said where the book says its other failures (the
    /// book view's bottom line) — never a silently empty answer.
    private(set) var lastError: String?

    /// What one opened group lists: its passages, page by page.
    struct Expansion: Equatable {
        var lines: [SearchPassage] = []
        var next: SearchComposer.Cursor?
        var loading = false
    }

    /// Only the NEWEST read may land (the catalog's generation guard).
    @ObservationIgnored private var generation = 0

    init(session: AppSession, readingID: String) {
        self.session = session
        self.readingID = readingID
    }

    /// **The answer shows in place of the book's content** (F1) — the field
    /// holds WORDS the index can be asked about.
    var isAnswering: Bool { question?.text != nil }

    var hasMoreGroups: Bool { next != nil }

    /// The archived chip is offered where it can act: the facet is on, or
    /// the archive holds matches it would add (P-2).
    var offersArchived: Bool {
        visibility != .living || (counts?.archivedPlaces ?? 0) > 0
    }

    // MARK: - The field (R-13o-14)

    /// The glyph was clicked: the field opens (the view focuses it).
    func open() { isOpen = true }

    /// Esc, the glyph again, or an empty field left: the field rests as the
    /// glyph and the book's content returns exactly as it was — the answer
    /// was drawn OVER it, never instead of it (F1).
    func close() {
        isOpen = false
        lastError = nil
        generation += 1
        text = ""
        words = ""
        question = nil
        visibility = .living
        clearAnswer()
    }

    /// **A keystroke** — the text is written AT ONCE (the field's binding
    /// reads it back on the same turn; a write deferred into the read's task
    /// would hand the field stale text and drop keys, the Library field's own
    /// convention); the caller spawns `search()`.
    func edit(_ value: String) {
        text = value
    }

    /// The field's text changed: read it into the one AST and ask (`edit` +
    /// `search`, the pins' one-step road).
    func setText(_ value: String) async {
        edit(value)
        await search()
    }

    /// The archived chip / the foot's word: the facet flips; a new question.
    func toggleArchived() async {
        visibility = visibility == .living ? .includingArchived : .living
        await search()
    }

    private func clearAnswer() {
        counts = nil
        groups = []
        next = nil
        loadingMore = false
        expansions = [:]
    }

    // MARK: - The reads (the one composer's roads)

    /// **A new question** — the first page of groups and the band's counts,
    /// under the book's own scope; a stale answer never lands.
    func search() async {
        generation += 1
        let asked = generation
        let parsed = Self.read(text, visibility: visibility)
        guard let parsed, parsed.query.text != nil else {
            question = parsed?.query
            words = parsed?.words ?? ""
            clearAnswer()
            return
        }
        let readingID = readingID
        do {
            let answer = try await session.database.read { db in
                try Self.answer(db, query: parsed.query, readingID: readingID, after: nil)
            }
            guard asked == generation else { return }
            lastError = nil
            question = parsed.query
            words = parsed.words
            counts = answer.counts
            groups = answer.page.groups
            next = answer.page.next
            loadingMore = false
            expansions = [:]
        } catch {
            guard asked == generation else { return }
            question = parsed.query
            words = parsed.words
            clearAnswer()
            lastError = String(describing: error)
        }
    }

    /// The next page of groups (as she nears the end of the listed ones).
    func loadMoreGroups() async {
        guard let question, let cursor = next, !loadingMore else { return }
        loadingMore = true
        let asked = generation
        let readingID = readingID
        let page = try? await session.database.read { db in
            try Self.page(db, query: question, readingID: readingID, after: cursor)
        }
        guard asked == generation else { return }
        loadingMore = false
        guard let page else { return }
        let listed = Set(groups.map(\.homeID))
        groups += page.groups.filter { !listed.contains($0.homeID) }
        next = page.next
    }

    /// Open a group to all its passages (its first page), or close it.
    func toggleExpansion(_ homeID: String) async {
        if expansions[homeID] != nil {
            expansions[homeID] = nil
            return
        }
        expansions[homeID] = Expansion(loading: true)
        await loadLines(homeID, after: nil)
    }

    /// The next page of an opened group's passages.
    func loadMoreLines(_ homeID: String) async {
        guard let open = expansions[homeID], !open.loading, let cursor = open.next else { return }
        expansions[homeID]?.loading = true
        await loadLines(homeID, after: cursor)
    }

    private func loadLines(_ homeID: String, after cursor: SearchComposer.Cursor?) async {
        guard let question else { return }
        let asked = generation
        let readingID = readingID
        let page = try? await session.database.read { db -> SearchPage in
            let wing = try Queries.reading(db, id: readingID)?.wingId ?? ""
            return try Queries.searchPassages(
                db, query: question, scope: SearchScope(wingID: wing, within: .note(id: homeID)),
                after: cursor, limit: Self.linePageSize)
        }
        guard asked == generation, expansions[homeID] != nil else { return }
        expansions[homeID]?.loading = false
        guard let page else { return }
        expansions[homeID]?.lines += SearchAnswerFace.lines(of: page.passages)
        expansions[homeID]?.next = page.next
    }

    // MARK: - Pure / over a Database

    /// The field's text as a question (the v1 grammar — words, "phrases",
    /// `#tags`, the worn day); nil for a blank field.
    nonisolated static func read(
        _ text: String, visibility: SearchVisibility,
        locale: Locale = .current, calendar: Calendar = JournalDay.storeCalendar
    ) -> (query: SearchQuery, words: String)? {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        let query = SearchQueryParser.parse(
            text, typeAhead: true, visibility: visibility, locale: locale, calendar: calendar)
        let words = text.split(whereSeparator: \.isWhitespace)
            .filter { !($0.hasPrefix("#") && $0.count > 1) }
            .joined(separator: " ")
        return (query, words)
    }

    /// The book's scope: its own wing, `.book(id)` (a book's rows or a
    /// gathering's assembled members — ruling B).
    nonisolated static func scope(_ db: Database, readingID: String) throws -> SearchScope {
        SearchScope(wingID: try Queries.reading(db, id: readingID)?.wingId ?? "", within: .book(id: readingID))
    }

    /// One read of the answer: the band's counts and a page of groups.
    nonisolated static func answer(
        _ db: Database, query: SearchQuery, readingID: String, after cursor: SearchComposer.GroupCursor?
    ) throws -> (counts: SearchCounts?, page: SearchGroupPage) {
        let scope = try scope(db, readingID: readingID)
        return (try Queries.searchCounts(db, query: query, scope: scope),
                try Queries.searchGroups(
                    db, query: query, scope: scope, after: cursor,
                    limit: groupPageSize, perGroup: linesPerGroup))
    }

    nonisolated static func page(
        _ db: Database, query: SearchQuery, readingID: String, after cursor: SearchComposer.GroupCursor
    ) throws -> SearchGroupPage {
        try Queries.searchGroups(
            db, query: query, scope: try scope(db, readingID: readingID), after: cursor,
            limit: groupPageSize, perGroup: linesPerGroup)
    }
}
