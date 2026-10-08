//
//  LibrarySearchModel.swift
//  Variorum (Mac)
//
//  **13o U2 — THE LIBRARY'S SEARCH STATE, its own brain** (P-9; the plan's
//  U2 RECORD, D1–D8). Her rulings: the Library field IS the one finder
//  ("library field should be one giant finder — no new search mode",
//  R-13o-7), and the search state is DIRECTION C, the answer sheet ("I like
//  direction C, the answer sheet, the best", R-13o-15): ONE results band
//  (the query's echo, honest counts, the filters as quiet chips) over the
//  passages GROUPED under their notes, every "all N ›" a real road
//  (R-13o-9 — "the 40 cap with no escape is terrible").
//
//  What lives here: the QUESTION (the field's text read into the one AST —
//  `SearchQueryParser`, R-13o-8 — plus the day range and the archived
//  facet), the ANSWER (the band's counts, the Books section's rows, the
//  ranked groups and their road to the next page), and each group's
//  "all N ›" expansion. What does NOT: the read's generation guard and the
//  landing into the List's own rows — the catalog's (`LibraryCatalogModel`
//  owns this model the way it owns `bookRowDoors`, and routes the field's
//  question here; `LibrarySearchRouting.swift` is that seam).
//
//  Every read is ONE composer road (`Queries.searchGroups` / `searchCounts`
//  / `searchPassages`) — no search SQL is composed here (R-13o-8's rule).
//

import Foundation
import GRDB
import Observation
import VariorumCore

// MARK: - The question (pure)

/// **What the Library field asks** — its text read once into the one AST,
/// with the day range and the archived facet. Pure, so a pin holds the rule.
nonisolated struct LibrarySearchQuestion: Equatable, Sendable {
    /// The whole question — words, typed `#tags`, the day range, the facet —
    /// and NO scope: the band's counts read this (D3 — the counts tell her
    /// what every scope holds, PROVISIONAL P-13o-U2-2).
    let query: SearchQuery
    /// The words as typed, the `#tags` aside — the band's echo.
    let words: String
    /// The typed `#tag` paths, in the order typed — the band's chips.
    let tagPaths: [String]

    /// **The answer sheet's state** (D1): the question has WORDS the index
    /// can be asked about. A `#tag` alone, or a day alone, is a question
    /// without words — the band says it; a `#tag` alone is answered by the
    /// books it is ASSOCIATED with (13o U3, the tag-association join) and,
    /// since VX-84a (D-1, superseding P-13o-U2-6), by the catalog's own
    /// listing NARROWED to the notes (and, in the Blocks scope, the blocks)
    /// it tags; a day alone by the shipped day listing (D5).
    var hasWords: Bool { query.text != nil }

    /// **The field asks something answerable** (13o U3; VX-84a): words, or a
    /// typed `#tag` — its associated books and the notes it narrows to.
    var answers: Bool { hasWords || !tagPaths.isEmpty }

    /// The field's text as a question — nil when the field holds nothing to
    /// ask (blank). `range` is the armed `when` range: with words it joins
    /// the filter half (D5 — `Queries.editedOnSQL`'s rule, unchanged).
    /// `bookState` is the armed MODE FACET (13o U3 — the sitting record
    /// §12's "mode facets as search filters"), a leaf of the same filter half.
    ///
    /// `savepoints` is the COMMITS facet (VX-72 — her R-VX83-5, "search what
    /// you saved"; the chip `+ commits`, R-VX83-9): savepoint history joins
    /// the answer. Off, the one composer's fence keeps every savepoint out.
    static func read(
        _ text: String, range: SearchDayRange? = nil, visibility: SearchVisibility = .living,
        bookState: SearchBookState? = nil, savepoints: Bool = false,
        locale: Locale = .current, calendar: Calendar = JournalDay.storeCalendar
    ) -> LibrarySearchQuestion? {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        var query = SearchQueryParser.parse(
            text, typeAhead: true, visibility: visibility, locale: locale, calendar: calendar)
        query.includesSavepoints = savepoints
        if let range {
            query.filter = query.filter.map { .all([$0, .days(range)]) } ?? .days(range)
        }
        if let bookState {
            query.filter = query.filter.map { .all([$0, .bookState(bookState)]) } ?? .bookState(bookState)
        }
        // NIT-1 (round 1): the words/tag reading is the ONE shared rule
        // (`SearchFieldWords`, the parser's letter — `#/` is neither).
        return LibrarySearchQuestion(
            query: query,
            words: SearchFieldWords.words(of: text),
            tagPaths: SearchFieldWords.tagPaths(of: text))
    }

    /// The question narrowed to a scope picker's choice (D3) — what the
    /// groups and the Books section read.
    func scoped(_ scope: LibraryCatalogModel.Scope) -> SearchQuery {
        guard let narrow = Self.scopeFilter(scope) else { return query }
        var scoped = query
        scoped.filter = query.filter.map { .all([$0, narrow]) } ?? narrow
        return scoped
    }

    /// The scope picker's four answers (D3): All · Notes · Books · Blocks —
    /// Blocks is the scraps family beside block NAMES (the `.docKind` leaf).
    static func scopeFilter(_ scope: LibraryCatalogModel.Scope) -> SearchFilter? {
        switch scope {
        case .all: nil
        case .posts: .family(.notes)
        case .books: .family(.books)
        case .blocks: .any([.family(.scraps), .docKind(.blockName)])
        }
    }

    /// **The field's text without one typed `#tag`** — the band chip's ✕.
    /// Rebuilt token by token (single spaces); a text that ended in space
    /// still does, and so does one whose LAST token was the tag — so the
    /// type-ahead tail never changes under the ✕ (a word that was whole
    /// stays whole).
    static func removingTag(_ path: String, from text: String) -> String {
        let all = SearchFieldWords.tokens(of: text)
        let key = path.lowercased()
        func isThisTag(_ token: String) -> Bool {
            SearchFieldWords.isTag(token) && SearchFieldWords.tagPath(token).lowercased() == key
        }
        let kept = all.filter { !isThisTag($0) }
        guard kept.count != all.count else { return text }
        let endsOpen = text.last.map { !$0.isWhitespace } ?? false
        let lastWasTag = all.last.map(isThisTag) ?? false
        let joined = kept.joined(separator: " ")
        return joined.isEmpty ? "" : joined + ((endsOpen && !lastWasTag) ? "" : " ")
    }

    /// **The field's text with an offered tag ACCEPTED** (VX-84b — D-2,
    /// ratified R-VX83-1: a plain word naming a tag offers it; the press is
    /// the explicit act). The word that named the tag BECOMES `#path` — so a
    /// lone word turns into a tag alone (D-1's narrowed listing) and a word
    /// beside others narrows the ranked sheet — every other token as typed,
    /// single-spaced, ending in a space (the tag is complete; nothing is left
    /// a type-ahead tail). A word no longer in the field (she typed on) adds
    /// the tag beside what is there.
    static func acceptingTagOffer(_ offer: SearchTagOffer.Offer, in text: String) -> String {
        var tokens = SearchFieldWords.tokens(of: text)
        let tag = "#" + offer.path
        func unquoted(_ token: String) -> String {
            token.trimmingCharacters(in: CharacterSet(charactersIn: "\"\u{201C}\u{201D}"))
        }
        if let i = tokens.firstIndex(where: { !SearchFieldWords.isTagShaped($0) && unquoted($0) == offer.word }) {
            tokens[i] = tag
        } else {
            tokens.append(tag)
        }
        return tokens.joined(separator: " ") + " "
    }

    // (NIT-1, round 1: the token/words/tag reading MOVED to the shared home
    // — `SearchFieldWords`, `Core/Views/SearchAnswerFaces.swift` — the book's
    // band is its second consumer; the rule is the PARSER's letter.)
}

/// **One read of the answer sheet** — the band's numbers, the Books
/// section, the first page of groups and the road to the next.
nonisolated struct LibrarySearchListing: Equatable, Sendable {
    var counts: SearchCounts?
    var books: [Queries.CatalogHit] = []
    /// **Why each ASSOCIATED book is listed** (13o U3, the tag-association
    /// join — the row says why: the mockup's "#dream flows here"); a book a
    /// name hit lists has no entry.
    var bookReasons: [String: SearchTagAssociation.Reason] = [:]
    /// The listed books that are ARCHIVED (13o U3 — under the archived
    /// facet the rows say which they are).
    var archivedBooks: Set<String> = []
    var groups: [SearchGroup] = []
    var next: SearchComposer.GroupCursor?
    /// VX-84b (D-2, ratified R-VX83-1): the tags the question's WORDS name —
    /// the band's `tag: #path ›` invitations.
    var tagOffers: [SearchTagOffer.Offer] = []
}

// MARK: - The model

@MainActor
@Observable
final class LibrarySearchModel {
    /// A group page — the composer's own default (one statement ∝ the
    /// matches, pinned flat in core's `SearchP1Tests`).
    nonisolated static let groupPageSize = 25
    /// Each group's top passages (Direction C's "top 3").
    nonisolated static let linesPerGroup = 3
    /// An "all N ›" page of one group's passages.
    nonisolated static let linePageSize = 50
    /// How many groups before the end of the listed ones ask for the next
    /// page (the notes' `prefetchMargin`, at the groups' own scale).
    nonisolated static let prefetchMargin = 8

    @ObservationIgnored let session: AppSession

    /// **The archived facet** (D4 — R-13o-6: archived matches are indexed
    /// but out of the default results behind one facet). A question she
    /// asks, never remembered (the day filter's own reason: a Library that
    /// reopened still showing the archive is the invisible-state hazard).
    private(set) var visibility: SearchVisibility = .living
    /// **The armed MODE FACET** (13o U3 — the sitting record §12: gathering ·
    /// living · owned · finished · sealed, facts never tags): the band's
    /// `+ book state` chip. A question she asks, never remembered (the
    /// facet's own reason above). nil = none.
    private(set) var bookState: SearchBookState?
    /// **The COMMITS facet** (VX-72 — her R-VX83-5: *"do the savepoints …
    /// it's the most important product story (anything you've saved)"*; the
    /// chip `+ commits`, her R-VX83-9): savepoint history joins the answer.
    /// A question she asks, never remembered (the archived facet's reason).
    private(set) var includesSavepoints = false

    /// The question the LISTED answer answers — nil when the Library is not
    /// searching. The band reads it whenever it is non-nil (P-13o-U2-1).
    private(set) var question: LibrarySearchQuestion?
    /// The band's numbers (nil without words).
    private(set) var counts: SearchCounts?
    /// The Books section: the books a typed `#tag` is ASSOCIATED with first
    /// (13o U3 — the join, top-ranked), then every book a book or chapter
    /// hit names, ranked by its best hit (∝ the wing's books — the
    /// Bookcase's own class).
    private(set) var books: [Queries.CatalogHit] = []
    /// Why each associated book is listed (13o U3 — its row's words).
    private(set) var bookReasons: [String: SearchTagAssociation.Reason] = [:]
    /// The listed books that are archived (13o U3 — only under the facet).
    private(set) var archivedBooks: Set<String> = []
    /// The answer sheet's groups — notes and scraps groups, best first.
    private(set) var groups: [SearchGroup] = []
    /// **The tags the words name** (VX-84b — D-2, ratified R-VX83-1): the
    /// band offers each as `tag: #path ›`; the press is the explicit act
    /// (`LibraryCatalogModel.acceptTagOffer`). Empty without words.
    private(set) var tagOffers: [SearchTagOffer.Offer] = []
    /// Where the next page of groups starts; nil when none follows.
    private(set) var next: SearchComposer.GroupCursor?
    /// A next page is in flight (one at a time).
    private(set) var loadingMore = false
    /// The groups opened to "all N ›" — each its own paged road.
    private(set) var expansions: [String: Expansion] = [:]

    /// What one opened group lists: its passages, page by page.
    struct Expansion: Equatable {
        var lines: [SearchPassage] = []
        var next: SearchComposer.Cursor?
        var loading = false
    }

    /// The scope and wing the listed answer was read under (the paging and
    /// the expansions ask the same question).
    @ObservationIgnored private(set) var scope: LibraryCatalogModel.Scope = .all
    @ObservationIgnored private(set) var wing = ""
    /// The catalog generation the listed answer belongs to.
    @ObservationIgnored private(set) var generation = 0
    /// Each listed group's position (the paging's arithmetic).
    @ObservationIgnored private(set) var groupIndex: [String: Int] = [:]

    init(session: AppSession) {
        self.session = session
    }

    /// **The answer sheet is showing** (D1) — the question has words.
    var isAnswering: Bool { question?.hasWords == true }

    /// The band shows whenever the field asks anything (P-13o-U2-1); the
    /// catalog also shows it for an armed day.
    var asksAnything: Bool { question != nil }

    /// The sheet answers something (13o U3): words, or a typed tag that HAS
    /// associated books (counted — living or archived). A tag with none
    /// answers nothing, so no facet is offered over it (P-2).
    var answersAnything: Bool {
        guard let question else { return false }
        return question.hasWords || (!question.tagPaths.isEmpty && counts != nil)
    }

    var hasMoreGroups: Bool { next != nil }

    /// The facet's door (D4): living ↔ including archived. The caller
    /// re-reads (this file's convention — a facet is a new question).
    func toggleArchived() {
        visibility = visibility == .living ? .includingArchived : .living
    }

    /// The commits facet's door (VX-72): on ↔ off. The caller re-reads.
    func toggleSavepoints() {
        includesSavepoints.toggle()
    }

    /// The mode facet's door (13o U3): arm one state, or clear (nil). The
    /// caller re-reads; the scope it moves is the catalog's
    /// (`LibraryCatalogModel.armBookState`).
    func setBookState(_ state: SearchBookState?) {
        bookState = state
    }

    /// Put the facets back (a cleared field): the living corpus, no state,
    /// no savepoints.
    func resetFacet() {
        visibility = .living
        bookState = nil
        includesSavepoints = false
    }

    // MARK: - Landing (the catalog's road — `LibrarySearchRouting.swift`)

    /// A question's answer lands — a NEW question replaces everything
    /// (expansions included); the same question re-asked in place keeps the
    /// groups she opened.
    func land(
        _ listing: LibrarySearchListing?, question: LibrarySearchQuestion?,
        scope: LibraryCatalogModel.Scope, wing: String, generation: Int, startingOver: Bool
    ) {
        let sameQuestion = question == self.question && scope == self.scope && wing == self.wing
        self.question = question
        self.scope = scope
        self.wing = wing
        self.generation = generation
        counts = listing?.counts
        books = listing?.books ?? []
        bookReasons = listing?.bookReasons ?? [:]
        archivedBooks = listing?.archivedBooks ?? []
        groups = listing?.groups ?? []
        tagOffers = listing?.tagOffers ?? []
        next = listing?.next
        loadingMore = false
        reindexGroups()
        if startingOver || !sameQuestion || listing == nil {
            expansions = [:]
        } else {
            // In place (an act on the listing's own rows): an opened group
            // that is still listed STAYS open — the catalog re-reads its
            // lines from the start (`reloadExpansions`), so nothing she is
            // reading closes under her and nothing open is stale.
            let listed = Set(groups.map(\.homeID))
            expansions = expansions.filter { listed.contains($0.key) }
                .mapValues { _ in Expansion(loading: true) }
        }
    }

    /// Re-read every open group from its first page (an in-place landing).
    func reloadExpansions() async {
        for homeID in expansions.keys.sorted() {
            await loadLines(homeID, after: nil)
        }
    }

    private func reindexGroups() {
        var index: [String: Int] = [:]
        for (position, group) in groups.enumerated() { index[group.homeID] = position }
        groupIndex = index
    }

    /// The next page of groups arrived — appended, each home ONCE (a worn
    /// note leads page one and may rank again further down).
    /// Answers the groups that were new.
    @discardableResult
    func append(_ page: SearchGroupPage, generation: Int) -> [SearchGroup] {
        guard generation == self.generation else { return [] }
        let fresh = page.groups.filter { groupIndex[$0.homeID] == nil }
        let start = groups.count
        groups += fresh
        for (offset, group) in fresh.enumerated() { groupIndex[group.homeID] = start + offset }
        next = page.next
        loadingMore = false
        return fresh
    }

    /// How many listed groups lie below `homeID` (nil if it is not listed).
    func groupsAhead(of homeID: String) -> Int? {
        groupIndex[homeID].map { groups.count - 1 - $0 }
    }

    func beginLoadingMore() { loadingMore = true }
    func endLoadingMore() { loadingMore = false }

    // MARK: - "all N ›" — one group's whole road (R-13o-9)

    /// Open a group to all its passages (the first page), or close it.
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
        let askedGeneration = generation
        let query = question.scoped(scope)
        let within = SearchScope(wingID: wing, within: .note(id: homeID))
        do {
            let page = try await session.database.read { db in
                try Queries.searchPassages(
                    db, query: query, scope: within, after: cursor, limit: Self.linePageSize)
            }
            // A newer answer (or the same group closed) owns the sheet now.
            guard askedGeneration == generation, self.question == question,
                  expansions[homeID] != nil else { return }
            expansions[homeID]?.lines += Self.lines(of: page.passages)
            expansions[homeID]?.next = page.next
            expansions[homeID]?.loading = false
        } catch {
            guard expansions[homeID] != nil else { return }
            expansions[homeID]?.loading = false
        }
    }

    /// A group's LINES are its passages that are not its name (the head
    /// already says the name — `SearchGroup.lines`' own rule).
    nonisolated static func lines(of passages: [SearchPassage]) -> [SearchPassage] {
        SearchAnswerFace.lines(of: passages)  // 13o U3: the shared rule, both sheets
    }

    // MARK: - The reads (pure, over a Database)

    /// **The answer sheet, read once** (D2): the band's counts (the whole
    /// question, no scope — D3), the Books section (scopes All and Books),
    /// and `groupDepth` groups (every scope but Books). Each is one
    /// composer statement; the Books section pages the books family to its
    /// end (∝ the wing's books).
    nonisolated static func listing(
        _ db: Database, question: LibrarySearchQuestion, scope: LibraryCatalogModel.Scope,
        wing: String, groupDepth: Int, calendar: Calendar = JournalDay.storeCalendar
    ) throws -> LibrarySearchListing {
        var listing = LibrarySearchListing()
        let where_ = SearchScope(wingID: wing)
        listing.counts = try Queries.searchCounts(
            db, query: question.query, scope: where_, calendar: calendar)
        if scope == .all || scope == .books {
            let section = try books(db, question: question, wing: wing, calendar: calendar)
            listing.books = section.hits
            listing.bookReasons = section.reasons
            listing.archivedBooks = section.archived
        }
        // The ranked groups need WORDS; a typed tag alone is the catalog's
        // own narrowed listing (VX-84a, D-1 — `LibraryCatalogModel.listing`).
        // VX-84b (D-2): the tags the words name, offered in the band (the
        // whole question's, never the scope's — like the counts, D3).
        listing.tagOffers = try Queries.searchTagOffers(db, query: question.query, scope: where_)
        if scope != .books, question.hasWords {
            let page = try Queries.searchGroups(
                db, query: question.scoped(scope), scope: where_, limit: groupDepth,
                perGroup: linesPerGroup, calendar: calendar)
            listing.groups = page.groups
            listing.next = page.next
        }
        return listing
    }

    /// The next page of groups after `cursor`.
    nonisolated static func groupPage(
        _ db: Database, question: LibrarySearchQuestion, scope: LibraryCatalogModel.Scope,
        wing: String, after cursor: SearchComposer.GroupCursor,
        calendar: Calendar = JournalDay.storeCalendar
    ) throws -> SearchGroupPage {
        try Queries.searchGroups(
            db, query: question.scoped(scope), scope: SearchScope(wingID: wing), after: cursor,
            limit: groupPageSize, perGroup: linesPerGroup, calendar: calendar)
    }

    /// **The Books section** (13o U3): the books a typed `#tag` is
    /// ASSOCIATED with first — top-ranked, each with its reason (the 13i
    /// sitting record §12: *"a tag's results surface the books/gatherings
    /// associated with it … top-ranked"*; `Queries.searchTagAssociations`) —
    /// then every book the books family names, best hit first, each once; as
    /// the catalog's own rows (`Queries.catalogBookHits`).
    nonisolated static func books(
        _ db: Database, question: LibrarySearchQuestion, wing: String, calendar: Calendar
    ) throws -> (
        hits: [Queries.CatalogHit], reasons: [String: SearchTagAssociation.Reason], archived: Set<String>
    ) {
        let query = question.scoped(.books)
        let scope = SearchScope(wingID: wing)
        var ids: [String] = []
        var seen: Set<String> = []
        var reasons: [String: SearchTagAssociation.Reason] = [:]
        var archived: Set<String> = []
        for association in try Queries.searchTagAssociations(db, query: query, scope: scope)
        where seen.insert(association.readingID).inserted {
            ids.append(association.readingID)
            reasons[association.readingID] = association.reason
            if association.isArchived { archived.insert(association.readingID) }
        }
        if question.hasWords {
            var cursor: SearchComposer.Cursor?
            repeat {
                let page = try Queries.searchPassages(
                    db, query: query, scope: scope, after: cursor, limit: 200, calendar: calendar)
                for passage in page.passages {
                    guard let id = passage.readingID else { continue }
                    // The BOOK's own archived fact (its name hit's; a chapter
                    // hit wears its book's).
                    if passage.isArchived, passage.kind == .book || passage.kind == .chapter {
                        archived.insert(id)
                    }
                    if seen.insert(id).inserted { ids.append(id) }
                }
                cursor = page.next
            } while cursor != nil
        }
        return (try Queries.catalogBookHits(db, ids: ids), reasons, archived)
    }
}
