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
}

/// One page of passages and the road to the next (R-13o-9 — no capped
/// listing without a road to the rest).
public struct SearchPage: Equatable, Sendable {
    public let passages: [SearchPassage]
    /// nil when this page holds the last passage.
    public let next: SearchComposer.Cursor?
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
        let environment = try searchEnvironment(db)
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
            let kindRaw: String = row["kind"]
            guard let kind = SearchPassage.Kind(rawValue: kindRaw) else { continue }
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
            passages.append(SearchPassage(
                kind: kind, sourceID: row["src_id"], family: family,
                noteID: row["home_id"], blockID: row["block_id"], readingID: readingID,
                homeTitle: homeTitle, isArchived: row["archived"], isRenderedTake: row["rendered"],
                snippet: SearchComposer.snippetSegments(row["snippet"] ?? "")))
        }
        let next: SearchComposer.Cursor? = rows.count == limit
            ? rows.last.map { SearchComposer.Cursor(score: $0["score"], docID: $0["doc_id"]) }
            : nil
        return SearchPage(passages: passages, next: next)
    }

    /// The fragments the composer reads from their one home.
    static func searchEnvironment(_ db: Database) throws -> SearchComposer.Environment {
        SearchComposer.Environment(
            versionPredicate: { alias in versionHistoryPredicate(alias: alias, of: .anyLiveNote) },
            wingScope: { column, wingID in
                let scope = wingScope(column: column, wingID: wingID)
                return (scope.sql, wingID.isEmpty ? [] : [.text(wingID)])
            },
            editedOn: { alias in editedOnSQL(alias: alias) },
            starredNoteIDs: try starredNoteIDs(db))
    }

    static func arguments(_ values: [SearchComposer.Value]) -> StatementArguments {
        StatementArguments(values.map { value -> DatabaseValue in
            switch value {
            case .text(let s): return s.databaseValue
            case .integer(let i): return i.databaseValue
            case .real(let d): return d.databaseValue
            }
        })
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
                    isRenderedTake: false, snippet: []))
            }
        }
        return passages.sorted { $0.homeTitle > $1.homeTitle || ($0.homeTitle == $1.homeTitle && $0.sourceID < $1.sourceID) }
    }
}
