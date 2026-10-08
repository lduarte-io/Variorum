import Foundation
import GRDB

/// One search hit — a PASSAGE: the field that matched, where it lives, and
/// the words around the match (13o U1, the plan's item 5).
public struct SearchPassage: Equatable, Sendable, Identifiable {
    public enum Kind: String, Equatable, Sendable, CaseIterable {
        case take
        case takeLabel = "take_label"
        case blockName = "block_name"
        case comment
        case title
        case noteMeta = "note_meta"
        case book
        case chapter
        /// A nameless note WEARING the day the query names (R-13o-6) — a
        /// name-level hit with no index doc behind it.
        case wornDay = "worn_day"
        /// A SAVEPOINT's text (VX-72 — only under the commits facet): the
        /// words a take held when it was saved. `sourceID` is the commit,
        /// `blockID` its take's block; `isRenderedTake` says whether its TAKE
        /// renders (the landing's step rule, P-VX83-C4).
        case savepoint
    }

    /// "kind:sourceID" — stable across pages and rebuilds.
    public var id: String { "\(kind.rawValue):\(sourceID)" }
    public let kind: Kind
    /// The source row: a variant, block, comment, container or reading
    /// (section) id, by `kind`.
    public let sourceID: String
    public let family: SearchFamily
    /// The home note or pool (nil for a book or chapter hit).
    public let noteID: String?
    /// The block a take / label / name / comment hit lives on.
    public let blockID: String?
    /// The book a book or chapter hit names.
    public let readingID: String?
    /// The home's name as every surface shows it — `DisplayTitle`'s answer
    /// for a note or pool, the book's name for a book or chapter hit.
    public let homeTitle: String
    /// Any archived fact touches this hit (its own row, its block, its note,
    /// its book) — only ever true under the archived facet.
    public let isArchived: Bool
    /// A take that is its block's RENDERED take (`PostRender`'s rule).
    public let isRenderedTake: Bool
    /// The words around the match, matched runs flagged (empty for a worn-day
    /// hit — the whole name matched).
    public let snippet: [SearchSnippetSegment]
    /// A savepoint hit's moment — its commit's `created_at`, the store's ISO
    /// text (VX-72: the line says the day it was saved, P-VX83-C6). nil for
    /// every other kind.
    public let savedAt: String?
}

/// One page of passages and the road to the next (R-13o-9 — no capped
/// listing without a road to the rest).
public struct SearchPage: Equatable, Sendable {
    public let passages: [SearchPassage]
    /// nil when this page holds the last passage.
    public let next: SearchComposer.Cursor?
}

/// **One group of the answer sheet** (13o U2, Direction C): a home — a note,
/// or a scraps group — and its best passages.
public struct SearchGroup: Equatable, Sendable, Identifiable {
    public var id: String { homeID }
    public let homeID: String
    /// A scraps group (a pool container), not a note.
    public let isPool: Bool
    /// The home's name as every surface shows it (`DisplayTitle`).
    public let homeTitle: String
    /// A NOTE group's head as the catalog's own hit (nil for a scraps group).
    public let note: Queries.CatalogHit?
    /// The home itself is archived (only ever true under the facet).
    public let isArchived: Bool
    /// The group's best hit's score (nil for a worn-day-only group).
    public let bestScore: Double?
    /// Every hit of the group (its title hit included).
    public let hitCount: Int
    /// Its PASSAGES — the hits that are not the title ("N passages").
    public let lineCount: Int
    /// The group's name matched (a title hit, or the day a nameless note
    /// wears).
    public let titleMatched: Bool
    /// Its best passages, in rank order (at most the page's `perGroup`).
    public let lines: [SearchPassage]

    public init(
        homeID: String, isPool: Bool, homeTitle: String, note: Queries.CatalogHit?,
        isArchived: Bool, bestScore: Double?, hitCount: Int, lineCount: Int,
        titleMatched: Bool, lines: [SearchPassage]
    ) {
        self.homeID = homeID
        self.isPool = isPool
        self.homeTitle = homeTitle
        self.note = note
        self.isArchived = isArchived
        self.bestScore = bestScore
        self.hitCount = hitCount
        self.lineCount = lineCount
        self.titleMatched = titleMatched
        self.lines = lines
    }
}

/// One page of groups and the road to the next.
public struct SearchGroupPage: Equatable, Sendable {
    public let groups: [SearchGroup]
    /// nil when this page holds the last group.
    public let next: SearchComposer.GroupCursor?
}

/// **The band's numbers** (13o U2): what the whole question finds, per kind,
/// living and with the archived facet on.
public struct SearchCounts: Equatable, Sendable {
    public struct Kinds: Equatable, Sendable {
        /// Distinct books (a book's own name, or one of its chapters).
        public let books: Int
        /// Distinct notes (a hit inside, its title, or the day it wears).
        public let notes: Int
        /// The notes' non-title hits.
        public let passages: Int
        /// The scraps groups' non-title hits.
        public let scraps: Int
        /// The BLOCKS a text-less tag question names by their own (block-
        /// level) tags (VX-84a — the Blocks scope's listing under a tag
        /// alone); always 0 when the question has words (the passages and
        /// scraps above count those).
        public let blocks: Int
        /// The SAVEPOINTS the words find (VX-72 — under the commits facet
        /// only, P-VX83-C3: their own kind beside the living passages and
        /// scraps); always 0 off the facet.
        public let savepoints: Int

        public init(
            books: Int, notes: Int, passages: Int, scraps: Int, blocks: Int = 0, savepoints: Int = 0
        ) {
            self.books = books
            self.notes = notes
            self.passages = passages
            self.scraps = scraps
            self.blocks = blocks
            self.savepoints = savepoints
        }

        public var isEmpty: Bool {
            books == 0 && notes == 0 && passages == 0 && scraps == 0 && blocks == 0 && savepoints == 0
        }
    }

    /// The living corpus (the default).
    public let living: Kinds
    /// Living and archived (the facet on).
    public let all: Kinds
    /// Distinct places (notes, scraps groups, books) an ARCHIVED hit lands
    /// in — what the facet would add.
    public let archivedPlaces: Int

    public init(living: Kinds, all: Kinds, archivedPlaces: Int) {
        self.living = living
        self.all = all
        self.archivedPlaces = archivedPlaces
    }

    /// The numbers under a visibility.
    public func kinds(_ visibility: SearchVisibility) -> Kinds {
        visibility == .living ? living : all
    }
}

extension Queries {
    /// **THE SEARCH** (13o U1 — R-13o-2's bar: any words she ever wrote,
    /// findable from the place she would ask). `query` is the AST (R-13o-8 —
    /// `SearchQueryParser` reads the v1 grammar into it); `scope` is the wing
    /// (ALWAYS) and the library / a book / a note; `after` resumes a page.
    ///
    /// Ranked by bm25 × the kind's weight × the rendered-take boost
    /// (`SearchComposer`), keyset-paged on (score, doc id). The FIRST page
    /// (`after == nil`) also leads with the nameless notes WEARING the day
    /// the query names (`SearchQuery.wornDay`), confirmed by the one display
    /// brain (`DisplayTitle`).
    ///
    /// P1: the index does the text work; every other predicate is a seek per
    /// examined match; snippets are cut for the page rows only — cost ∝ the
    /// matches, never the corpus (pinned in `SearchP1Tests`). A query with no
    /// text the index can serve returns no passages (filter-only browsing is
    /// the Library's listing, not this road — PROVISIONAL P-13o-U1-7).
    public static func searchPassages(
        _ db: Database, query: SearchQuery, scope: SearchScope,
        after cursor: SearchComposer.Cursor? = nil, limit: Int = 50,
        calendar: Calendar = JournalDay.storeCalendar
    ) throws -> SearchPage {
        let environment = try searchEnvironment(db, scope: scope)
        var passages: [SearchPassage] = []
        if cursor == nil, let day = query.wornDay {
            passages += try wornDayPassages(
                db, query: query, scope: scope, day: day, calendar: calendar, environment: environment)
        }
        guard let statement = try SearchComposer.passages(
            query, scope: scope, after: cursor, limit: limit, environment: environment)
        else { return SearchPage(passages: passages, next: nil) }
        let rows = try Row.fetchAll(db, sql: statement.sql, arguments: arguments(statement.arguments))
        for row in rows {
            if let passage = passage(from: row, calendar: calendar) { passages.append(passage) }
        }
        let next: SearchComposer.Cursor? = rows.count == limit
            ? rows.last.map { SearchComposer.Cursor(score: $0["score"], docID: $0["doc_id"]) }
            : nil
        return SearchPage(passages: passages, next: next)
    }

    // MARK: - The answer sheet's groups (13o U2 — Direction C, R-13o-15)

    /// **One page of the answer sheet** — the matches grouped by their home
    /// (a note or a scraps group), the best-ranked groups first, each with
    /// its top `perGroup` passages (`SearchComposer.groups`). The FIRST page
    /// (`after == nil`) leads with the nameless notes WEARING the day the
    /// query names (R-13o-6), merged with their own group where they also
    /// have hits. Each NOTE group carries its head as the catalog's own hit
    /// (`CatalogHit` — the same display name, stamps and profile a Library
    /// row reads), read for the page's homes only.
    ///
    /// P1: one composer statement (∝ the matches) + one bounded read of the
    /// page's homes.
    public static func searchGroups(
        _ db: Database, query: SearchQuery, scope: SearchScope,
        after cursor: SearchComposer.GroupCursor? = nil, limit: Int = 25, perGroup: Int = 3,
        calendar: Calendar = JournalDay.storeCalendar
    ) throws -> SearchGroupPage {
        let environment = try searchEnvironment(db, scope: scope)
        var worn: [SearchPassage] = []
        if cursor == nil, let day = query.wornDay {
            worn = try wornDayPassages(
                db, query: query, scope: scope, day: day, calendar: calendar, environment: environment)
        }
        var built: [(homeID: String, best: Double?, hits: Int, lines: Int, rows: [SearchPassage])] = []
        var next: SearchComposer.GroupCursor?
        if let statement = try SearchComposer.groups(
            query, scope: scope, after: cursor, limit: limit, perGroup: perGroup, environment: environment) {
            let rows = try Row.fetchAll(db, sql: statement.sql, arguments: arguments(statement.arguments))
            for row in rows {
                let homeID: String = row["home_id"]
                let passage = passage(from: row, calendar: calendar)
                if built.last?.homeID == homeID {
                    if let passage { built[built.count - 1].rows.append(passage) }
                } else {
                    built.append((homeID, row["g_best"], row["g_hits"], row["g_lines"], passage.map { [$0] } ?? []))
                }
            }
            if built.count == limit, let last = built.last, let best = last.best {
                next = SearchComposer.GroupCursor(best: best, homeID: last.homeID)
            }
        }
        // The worn day leads the first page; a worn note that also has hits
        // keeps ONE group, in the lead.
        let wornIDs = worn.compactMap(\.noteID)
        // Ladder round 1, MINOR-1: a worn note whose group ranks BEYOND this
        // page would otherwise lead as a fabricated 1/0 stub — no lines, no
        // "all N ›" road, and the model's dedupe later drops its ranked
        // group (R-13o-9's road lost). ONE counts-style statement over
        // exactly the missing worn ids reads the TRUE facts; the next-page
        // cursor above stays sourced from `built` alone, and the dedupe
        // stays (the lead group now IS the road).
        var wornFacts: [String: (best: Double, hits: Int, lines: Int)] = [:]
        let missing = wornIDs.filter { id in !built.contains { $0.homeID == id } }
        if !missing.isEmpty,
           let statement = try SearchComposer.wornGroupFacts(
               query, scope: scope,
               homeIDsJSON: String(decoding: try JSONEncoder().encode(missing), as: UTF8.self),
               environment: environment) {
            for row in try Row.fetchAll(db, sql: statement.sql, arguments: arguments(statement.arguments)) {
                wornFacts[row["g_home"]] = (row["g_best"], row["g_hits"], row["g_lines"])
            }
        }
        var ordered = wornIDs.map { id in
            built.first { $0.homeID == id }
                ?? wornFacts[id].map { (homeID: id, best: Optional($0.best), hits: $0.hits, lines: $0.lines, rows: []) }
                ?? (homeID: id, best: nil, hits: 1, lines: 0, rows: [])
        }
        ordered += built.filter { !wornIDs.contains($0.homeID) }

        let homes = try searchGroupHomes(db, ids: ordered.map(\.homeID), calendar: calendar)
        let groups = ordered.compactMap { group -> SearchGroup? in
            guard let home = homes[group.homeID] else { return nil }
            return SearchGroup(
                homeID: group.homeID, isPool: home.isPool, homeTitle: home.title,
                note: home.note, isArchived: home.isArchived, bestScore: group.best,
                hitCount: group.hits, lineCount: group.lines,
                titleMatched: wornIDs.contains(group.homeID) || group.hits > group.lines,
                lines: group.rows.filter { $0.kind != .title })
        }
        return SearchGroupPage(groups: groups, next: next)
    }

    /// The homes a group page names — note heads as the catalog's hit.
    private static func searchGroupHomes(
        _ db: Database, ids: [String], calendar: Calendar
    ) throws -> [String: (isPool: Bool, title: String, note: CatalogHit?, isArchived: Bool)] {
        guard !ids.isEmpty else { return [:] }
        let json = String(decoding: try JSONEncoder().encode(ids), as: UTF8.self)
        var homes: [String: (isPool: Bool, title: String, note: CatalogHit?, isArchived: Bool)] = [:]
        for row in try Row.fetchAll(
            db,
            sql: """
                SELECT c.id, c.kind, c.title, c.entry_date, c.created_at, c.profile,
                       COALESCE(c.last_touched_at, c.created_at) AS touched_at,
                       (c.archived_at IS NOT NULL) AS archived
                FROM json_each(?) j CROSS JOIN container c ON c.id = j.value
                """,
            arguments: [json]) {
            let id: String = row["id"]
            let isPool = (row["kind"] as String) == "pool"
            let title: String = isPool
                ? DisplayTitle.pool(title: row["title"], createdAtStamp: row["created_at"], calendar: calendar)
                : DisplayTitle.note(
                    title: row["title"], entryDate: row["entry_date"], createdAt: row["created_at"],
                    calendar: calendar)
            let note: CatalogHit? = isPool ? nil : CatalogHit(
                kind: .post, id: id, title: title, detail: row["entry_date"],
                storedTitle: DisplayTitle.isAbsent(row["title"]) ? nil : row["title"],
                createdAt: row["created_at"], lastTouchedAt: row["touched_at"], profile: row["profile"])
            homes[id] = (isPool, title, note, row["archived"])
        }
        return homes
    }

    /// One composed hit row → a passage (nil for an unknown kind).
    static func passage(from row: Row, calendar: Calendar) -> SearchPassage? {
        let kindRaw: String = row["kind"]
        guard let kind = SearchPassage.Kind(rawValue: kindRaw) else { return nil }
        let readingID: String? = row["reading_id"]
        let homeKind: String? = row["home_kind"]
        let family: SearchFamily = readingID != nil ? .books : (homeKind == "pool" ? .scraps : .notes)
        let homeTitle: String
        if readingID != nil {
            homeTitle = row["reading_name"] ?? ""
        } else if homeKind == "pool" {
            homeTitle = DisplayTitle.pool(
                title: row["home_title"], createdAtStamp: row["home_created_at"], calendar: calendar)
        } else {
            homeTitle = DisplayTitle.note(
                title: row["home_title"], entryDate: row["home_entry_date"],
                createdAt: row["home_created_at"], calendar: calendar)
        }
        return SearchPassage(
            kind: kind, sourceID: row["src_id"], family: family,
            noteID: row["home_id"], blockID: row["block_id"], readingID: readingID,
            homeTitle: homeTitle, isArchived: row["archived"], isRenderedTake: row["rendered"],
            snippet: SearchComposer.snippetSegments(row["snippet"] ?? ""),
            // Only the commits facet's statements carry the column (VX-72).
            savedAt: row.hasColumn("saved_at") ? row["saved_at"] : nil)
    }

    // MARK: - The band's counts (13o U2)

    /// **What the whole question finds, per kind** — living and with the
    /// archived facet on, from ONE walk of the matches (`SearchComposer
    /// .counts`), the worn-day notes folded into the notes (R-13o-6). nil
    /// when the query has no words the index can serve.
    public static func searchCounts(
        _ db: Database, query: SearchQuery, scope: SearchScope,
        calendar: Calendar = JournalDay.storeCalendar
    ) throws -> SearchCounts? {
        let environment = try searchEnvironment(db, scope: scope)
        var everything = query
        everything.visibility = .includingArchived
        var worn: [SearchPassage] = []
        if let day = query.wornDay {
            worn = try wornDayPassages(
                db, query: everything, scope: scope, day: day, calendar: calendar, environment: environment)
        }
        // 13o U3: the books a typed tag is ASSOCIATED with count as books
        // (the Books section lists them) — living, and with the facet on.
        let associated = try searchTagAssociations(db, query: everything, scope: scope)
        func json(_ ids: [String]) throws -> String {
            String(decoding: try JSONEncoder().encode(ids), as: UTF8.self)
        }
        guard let statement = try SearchComposer.counts(
            query, scope: scope,
            wornLivingNoteIDs: try json(worn.filter { !$0.isArchived }.compactMap(\.noteID)),
            wornAllNoteIDs: try json(worn.compactMap(\.noteID)),
            wornArchivedNoteIDs: try json(worn.filter(\.isArchived).compactMap(\.noteID)),
            associatedLivingBookIDs: try json(associated.filter { !$0.isArchived }.map(\.readingID)),
            associatedAllBookIDs: try json(associated.map(\.readingID)),
            associatedArchivedBookIDs: try json(associated.filter(\.isArchived).map(\.readingID)),
            environment: environment)
        else {
            // No words — a worn day alone still names its notes, and a typed
            // tag alone its associated books (13o U3) AND, since VX-84a (D-1),
            // the notes and blocks it TAGS: the listing's own narrowing,
            // counted by the one composer (Library scope only — a book's
            // search keeps its own words-only road).
            var tagged = (notes: 0, allNotes: 0, blocks: 0, allBlocks: 0)
            if case .library = scope.within,
               let listing = SearchComposer.listingCounts(query, wingID: scope.wingID, environment: environment),
               let row = try Row.fetchOne(db, sql: listing.sql, arguments: arguments(listing.arguments)) {
                tagged = (row["notes"], row["all_notes"], row["blocks"], row["all_blocks"])
            }
            guard !worn.isEmpty || !associated.isEmpty || tagged.allNotes > 0 || tagged.allBlocks > 0
            else { return nil }
            let livingNotes = worn.filter { !$0.isArchived }.count
            let livingBooks = associated.filter { !$0.isArchived }.count
            return SearchCounts(
                living: .init(books: livingBooks, notes: livingNotes + tagged.notes, passages: 0, scraps: 0,
                              blocks: tagged.blocks),
                all: .init(books: associated.count, notes: worn.count + tagged.allNotes, passages: 0, scraps: 0,
                           blocks: tagged.allBlocks),
                archivedPlaces: (worn.count - livingNotes) + (associated.count - livingBooks)
                    + (tagged.allNotes - tagged.notes) + (tagged.allBlocks - tagged.blocks))
        }
        guard let row = try Row.fetchOne(db, sql: statement.sql, arguments: arguments(statement.arguments))
        else { return nil }
        // VX-72: the commits facet's statement says its savepoints (P-VX83-C3).
        let saved = row.hasColumn("savepoints") ? (living: row["savepoints"] as Int, all: row["all_savepoints"] as Int)
            : (living: 0, all: 0)
        return SearchCounts(
            living: .init(books: row["books"], notes: row["notes"], passages: row["passages"], scraps: row["scraps"],
                          savepoints: saved.living),
            all: .init(books: row["all_books"], notes: row["all_notes"],
                       passages: row["all_passages"], scraps: row["all_scraps"], savepoints: saved.all),
            archivedPlaces: row["archived_places"])
    }

    // MARK: - The tag-association join (13o U3 — the 13i sitting record §12)

    /// **The books and gatherings a typed `#tag` is ASSOCIATED with** —
    /// through their intake rule (the tag flows there) or their outflow (their
    /// writing carries it) — ranked as `SearchTagAssociation` decides, ahead
    /// of every name hit (her §12 ruling: *"a tag's results surface the
    /// books/gatherings associated with it … top-ranked"*). Wing-scoped
    /// always; under the query's archived facet; the query's filter half
    /// composes at reading level (the mode facets narrow it). Library scope
    /// only (a book's own search has none). Empty when no tag is typed.
    ///
    /// P1: ∝ the wing's readings (the Bookcase's class — one candidates
    /// statement) + the typed tags' path lookups + one bounded path read.
    public static func searchTagAssociations(
        _ db: Database, query: SearchQuery, scope: SearchScope
    ) throws -> [SearchTagAssociation.Association] {
        let typed = SearchTagAssociation.typedPaths(of: query.filter)
        guard !typed.isEmpty else { return [] }
        let environment = try searchEnvironment(db, scope: scope)
        guard let candidates = SearchComposer.associationCandidates(
            query, scope: scope, environment: environment) else { return [] }
        var stored: [String] = []
        for path in typed {
            let lookup = SearchComposer.typedTagPaths(path, wingID: scope.wingID, environment: environment)
            for found in try String.fetchAll(db, sql: lookup.sql, arguments: arguments(lookup.arguments))
            where !stored.contains(found) {
                stored.append(found)
            }
        }
        guard !stored.isEmpty else { return [] }
        let rows = try Row.fetchAll(db, sql: candidates.sql, arguments: arguments(candidates.arguments))
        let read = rows.map { row in
            SearchTagAssociation.Candidate(
                readingID: row["id"], name: row["name"], ruleSpec: row["query_spec"],
                outflowTagIDs: Reading.decodeOutflow(row["auto_tag_ids"]), isArchived: row["archived"])
        }
        var referenced: [String] = []
        var seen: Set<String> = []
        for candidate in read {
            var ids = candidate.outflowTagIDs
            if case .rule(let term) = RuleGrammar.read(candidate.ruleSpec) {
                ids += RuleGrammar.positiveTagIDs(of: term)
            }
            for id in ids where seen.insert(id).inserted { referenced.append(id) }
        }
        guard !referenced.isEmpty else { return [] }
        let json = String(decoding: try JSONEncoder().encode(referenced), as: UTF8.self)
        let pathsStatement = SearchComposer.tagPaths(idsJSON: json, wingID: scope.wingID, environment: environment)
        var paths: [String: String] = [:]
        for row in try Row.fetchAll(db, sql: pathsStatement.sql, arguments: arguments(pathsStatement.arguments)) {
            paths[row["id"]] = row["path"]
        }
        return SearchTagAssociation.associate(candidates: read, typedPaths: stored, tagPaths: paths)
    }

    /// The fragments the composer reads from their one home. `scope` (13o
    /// U3): a `.book(id)` scope naming a GATHERING carries its membership —
    /// the ONE function its assembly reads (`gatheringMembership`, the
    /// architect's ruling B).
    static func searchEnvironment(
        _ db: Database, scope: SearchScope? = nil
    ) throws -> SearchComposer.Environment {
        SearchComposer.Environment(
            versionPredicate: { alias in versionHistoryPredicate(alias: alias, of: .anyLiveNote) },
            wingScope: { column, wingID in
                let scope = wingScope(column: column, wingID: wingID)
                return (scope.sql, wingID.isEmpty ? [] : [.text(wingID)])
            },
            editedOn: { alias in editedOnSQL(alias: alias) },
            starredNoteIDs: try starredNoteIDs(db),
            livingBook: { alias in livingBookSQL(alias: alias) },
            gathering: try scope.flatMap { try searchGathering(db, scope: $0) })
    }

    /// A `.book(id)` scope's gathering membership (nil when the scope names
    /// no live gathering — a BOOK's members are its rows). A dead or missing
    /// reading is no gathering: the membership-row arm answers it (nothing).
    static func searchGathering(
        _ db: Database, scope: SearchScope
    ) throws -> SearchComposer.GatheringMembership? {
        guard case .book(let id) = scope.within,
              let reading = try Queries.reading(db, id: id), reading.kind == .gathering
        else { return nil }
        guard let membership = try gatheringMembership(db, reading) else { return .assemblesNothing }
        return .members(
            conditions: membership.conditions,
            arguments: membership.arguments.map { value -> SearchComposer.Value in
                switch value?.databaseValue.storage {
                case .string(let s): .text(s)
                case .int64(let i): .integer(i)
                case .double(let d): .real(d)
                // The membership's arguments are ids and stored text; a NULL
                // or a blob never reaches it (pinned by the parity cells).
                case .null, .blob, nil: .text("")
                }
            })
    }

    /// **"A LIVING book" — intake is on** (13o U3, the mode facet's one
    /// home in SQL; the 13i sitting record §1: *"any book whose intake is
    /// on"*). EXACTLY the SQL half of intake's own candidate predicate
    /// (`Operations.livingBooks`: a live BOOK, not finished, not archived —
    /// an archived book's intake is paused, R-13ie-4 — with a rule) and of
    /// the census's `BookcaseBoard.isLiving`. The one residual, recorded: a
    /// MALFORMED stored rule (reachable only by a hand edit or a corrupt
    /// row) reads here as a rule — intake and the census decode it and fail
    /// it closed; a facet cannot decode JSON in SQL (P-13o-U3-4).
    public static func livingBookSQL(alias r: String) -> String {
        "(\(r).kind = 'book' AND \(r).locked = 0 AND \(r).archived_at IS NULL AND \(r).query_spec IS NOT NULL)"
    }

    static func arguments(_ values: [SearchComposer.Value]) -> StatementArguments {
        StatementArguments(values.map(databaseValue))
    }

    /// One composer argument as GRDB binds it (VX-84a: the catalog's own
    /// listing statements bind the composer's narrowing through this too).
    static func databaseValue(_ value: SearchComposer.Value) -> DatabaseValue {
        switch value {
        case .text(let s): s.databaseValue
        case .integer(let i): i.databaseValue
        case .real(let d): d.databaseValue
        }
    }

    /// The worn-day arm: candidate notes by their day key (dated) and their
    /// creation window (undated), every year the store spans for a year-less
    /// day — the spans read by four MIN/MAX seeks on the two indexes — then
    /// confirmed by `DisplayTitle` (nameless, and the day it shows IS this
    /// day). Bounded by the day's own notes.
    static func wornDayPassages(
        _ db: Database, query: SearchQuery, scope: SearchScope, day: SearchDayPattern,
        calendar: Calendar, environment: SearchComposer.Environment
    ) throws -> [SearchPassage] {
        func year(_ stamp: String?) -> Int? {
            guard let stamp, stamp.count >= 4 else { return nil }
            return Int(stamp.prefix(4))
        }
        var dayKeys: [String] = []
        var windows: [(start: String, end: String)] = []
        // Four single-aggregate reads: SQLite's min/max shortcut (one index
        // seek) applies only to a statement with ONE min() or max().
        func one(_ sql: String) throws -> String? { try String.fetchOne(db, sql: sql) }
        let datedFilter = "FROM container WHERE deleted_at IS NULL AND entry_date > ''"
        if let lo = year(try one("SELECT min(entry_date) \(datedFilter)")),
           let hi = year(try one("SELECT max(entry_date) \(datedFilter)")), lo <= hi {
            let years = day.year.map { [$0] } ?? Array(lo...hi)
            dayKeys = years.compactMap { day.dayKey(inYear: $0) }
        }
        let undatedFilter = "FROM container WHERE deleted_at IS NULL AND (entry_date IS NULL OR entry_date = '')"
        // ±1 year: a local day near New Year can sit in the neighbouring UTC year.
        if let lo = year(try one("SELECT min(created_at) \(undatedFilter)")),
           let hi = year(try one("SELECT max(created_at) \(undatedFilter)")), lo <= hi {
            let years = day.year.map { [$0] } ?? Array((lo - 1)...(hi + 1))
            windows = years.compactMap { day.dayKey(inYear: $0) }
                .compactMap { DayBounds(day: $0, calendar: calendar) }
                .map { (start: $0.start, end: $0.end) }
        }
        var seen: Set<String> = []
        var passages: [SearchPassage] = []
        for statement in SearchComposer.wornDay(
            query, scope: scope, dayKeys: dayKeys, createdWindows: windows, environment: environment) {
            for row in try Row.fetchAll(db, sql: statement.sql, arguments: arguments(statement.arguments)) {
                let id: String = row["id"]
                let title: String? = row["title"]
                let entryDate: String? = row["entry_date"]
                let createdAt: String? = row["created_at"]
                guard DisplayTitle.isAbsent(title), seen.insert(id).inserted else { continue }
                let shown = DisplayTitle.note(
                    title: title, entryDate: entryDate, createdAt: createdAt, calendar: calendar)
                guard day.matches(dayKey: shown) else { continue }
                passages.append(SearchPassage(
                    kind: .wornDay, sourceID: id, family: .notes, noteID: id, blockID: nil,
                    readingID: nil, homeTitle: shown, isArchived: row["archived"],
                    isRenderedTake: false, snippet: [], savedAt: nil))
            }
        }
        return passages.sorted { $0.homeTitle > $1.homeTitle || ($0.homeTitle == $1.homeTitle && $0.sourceID < $1.sourceID) }
    }
}
