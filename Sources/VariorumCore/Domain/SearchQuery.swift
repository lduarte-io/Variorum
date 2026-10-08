import Foundation

/// **THE SEARCH QUERY — ONE AST UNDER EVERY GRAMMAR** (Phase 13o, R-13o-8).
///
/// Her direction, verbatim: *"I eventually hope to allow people to do more
/// complex searches … notes with 'dream' that aren't in the Journal book, over
/// 500 words in the note … I want to know if what we're building is working in
/// that direction."* The ruling made it binding on 13o's shape: the query is a
/// pure value — **a TEXT half** (what the full-text index matches) **and a
/// FILTER half** (a boolean tree over row facts) — and the SQL is composed from
/// it in exactly one place (`SearchComposer`, the one Domain composer). v1's
/// grammar (words, "phrases", `#tag`, the day a nameless note wears) parses into
/// it (`SearchQueryParser`); the future power grammar (boolean operators,
/// `in:`/`not in:` a book, word-count thresholds, saved searches — VX-73) is a
/// later parser and face over THIS same value. Kin to `RuleTerm` (the gathering
/// rule's tree) by design: a saved search and a gathering rule are two readings
/// of one shape.
///
/// Pure and dependency-free — no GRDB, no AppKit.
public struct SearchQuery: Equatable, Sendable {
    /// What the index must match. nil = no text constraint (a query that is
    /// only filters, or only a worn day).
    public var text: SearchText?
    /// The row-fact constraints. nil = none.
    public var filter: SearchFilter?
    /// **The day the free text NAMES** (R-13o-6 — her *"the derived display
    /// name would be good to do"*): a nameless note wears its date on every
    /// surface (`DisplayTitle.note`), so a query that IS a day ("september 14",
    /// "sep 14", "9/14") also finds the notes wearing that day — OR'd into the
    /// note arm at query time, never a stored rendering that could go stale.
    public var wornDay: SearchDayPattern?
    /// The archived facet (R-13o-6: archived notes/books/takes are INDEXED but
    /// out of the default results behind one facet). Saved versions never
    /// list under any visibility (the ruled posture); savepoint history is
    /// its own facet (`includesSavepoints`, VX-72); the Trash is not search's
    /// (VX-93 — a search INSIDE the Trash, R-VX83-5).
    public var visibility: SearchVisibility
    /// **The commits facet** (VX-72 — her R-VX83-5, "search what you saved";
    /// the chip says `+ commits`, R-VX83-9): savepoint history joins the
    /// answer. OFF by default and in every road but the Library's facet — a
    /// savepoint NEVER lists without it (the composer's doc-row kind fence,
    /// the §U-C RULINGS' condition 2). Orthogonal to `visibility`: a
    /// savepoint of an archived take, block or note lists only with the
    /// archived facet too; saved versions stay fenced under both (P-VX83-C1).
    public var includesSavepoints: Bool

    public init(
        text: SearchText? = nil, filter: SearchFilter? = nil,
        wornDay: SearchDayPattern? = nil, visibility: SearchVisibility = .living,
        includesSavepoints: Bool = false
    ) {
        self.text = text
        self.filter = filter
        self.wornDay = wornDay
        self.visibility = visibility
        self.includesSavepoints = includesSavepoints
    }

    /// Nothing to search by: no text, no worn day, no filter.
    public var isEmpty: Bool { text == nil && wornDay == nil && filter == nil }
}

/// The TEXT half — a boolean tree over the user's words. v1 produces only
/// `.all` of words / phrases / one trailing prefix; `.any` and `.not` exist so
/// the power grammar (VX-73) parses into the same value. Every leaf is the
/// user's RAW text: the composer quotes it as an FTS5 string, so the index's
/// own tokenizer splits and folds it (R-13o-11 — one sameness rule) and no
/// user text can ever be read as FTS5 syntax.
public indirect enum SearchText: Equatable, Sendable {
    /// Every child matches (implicit AND — how words combine).
    case all([SearchText])
    /// Any child matches.
    case any([SearchText])
    /// The child does NOT match. Only meaningful beside a positive term (the
    /// index cannot enumerate "everything except"); a tree whose every leaf
    /// is negated composes to no text constraint the index can serve, and the
    /// composer refuses it (`SearchComposer.Refusal.negativeOnlyText`).
    case not(SearchText)
    /// One typed word. It may tokenize to several tokens ("don't", "e-mail"),
    /// which then match as an adjacent run.
    case word(String)
    /// A "quoted phrase" — its tokens adjacent and in order.
    case phrase(String)
    /// The type-ahead tail: the word still being typed, matched as a prefix
    /// of its LAST token.
    case prefix(String)
}

/// The FILTER half — a boolean tree over row FACTS (never over text).
public indirect enum SearchFilter: Equatable, Sendable {
    case all([SearchFilter])
    case any([SearchFilter])
    case not(SearchFilter)
    /// A typed `#path` — resolved inside the scope's wing at compose time and
    /// matched as a SUBTREE (`#life` matches `life/goals`), the gathering
    /// rule's own subtree reading. A note matches by its own tags, a block by
    /// its own tags OR its note's ("everything tagged X UNIONs the two",
    /// AppSpec §7).
    case tagPath(String)
    /// A tag by ID (saved searches and programmatic callers — `renameTag`-
    /// proof, the `RuleTerm.tag` letter). Subtree, same reading as `.tagPath`.
    case tag(id: String)
    /// The note is starred.
    case starred
    /// A day RANGE over one of a note's time facts (the Library's day filter
    /// grown to a range — §21 item 3).
    case days(SearchDayRange)
    /// Narrow to one result family (the facet chips).
    case family(SearchFamily)
    /// Narrow to one doc KIND (13o U2 — the Library's Blocks scope reads
    /// block NAMES beside the scraps family). A kind is a fact of the hit,
    /// never of a note, so a note-level arm (the worn day) reads it as
    /// "only a name-level kind" — `.title` — and nothing else.
    case docKind(SearchDocKind)
    /// **A MODE FACET** (13o U3 — the 13i sitting record §12 item 2: *"mode
    /// facets as search filters — gathering · living · owned · finished ·
    /// sealed (facts on the row, NEVER tags)"*): a FACT of the READING row a
    /// book or chapter hit names. A note, a scrap and a worn-day hit carry no
    /// reading row, so a facet narrows the answer to BOOKS — the mirror of an
    /// armed day, which narrows it to notes (PROVISIONAL P-13o-U3-3).
    case bookState(SearchBookState)
}

/// **The mode facets' vocabulary** (13o U3) — each a fact on the `reading`
/// row, read exactly as the Bookcase's № census reads it (`BookcaseSolo`).
public enum SearchBookState: String, Equatable, Sendable, CaseIterable {
    /// A gathering (a saved rule, assembled at read).
    case gathering
    /// A LIVING book — intake is on (the sitting record §1: *"any book whose
    /// intake is on"*): a book, not finished, not archived (an archived
    /// book's intake is paused, R-13ie-4), with a rule
    /// (`Queries.livingBookSQL` — intake's own candidate predicate).
    case living
    /// An OWNED book (§6).
    case owned
    /// A FINISHED book — sealed books count too (Sealed is Finished + text
    /// immutability, §5; the census's own reading).
    case finished
    /// A SEALED book.
    case sealed
}

/// **The index's doc KINDS** (F2 — one doc per source text field, a closed
/// and additive vocabulary; VX-72's savepoint text joined as the ninth at
/// `v1_23`). The raw values ARE the stored `search_doc.kind` (pinned against
/// `SearchIndex.sources`).
public enum SearchDocKind: String, Equatable, Sendable, CaseIterable {
    case take
    case takeLabel = "take_label"
    case blockName = "block_name"
    case comment
    case title
    case noteMeta = "note_meta"
    case book
    case chapter
    /// A savepoint's immutable text (`commit_point.text`, VX-72) — listed
    /// only under the savepoints facet.
    case savepoint
}

/// The archived facet (R-13o-6).
public enum SearchVisibility: String, Equatable, Sendable, CaseIterable {
    /// The DEFAULT: the living corpus only — no archived take, block, note or
    /// book (and never a saved version).
    case living
    /// Living AND archived (the facet on). Rows say which they are.
    case includingArchived
    /// Archived only.
    case archivedOnly
}

/// A result FAMILY — what a hit is, for the facet chips. Derived at query
/// time from the hit's kind and its home (a take is a SCRAP when its home
/// container is a pool — F2's ruling-in-waiting: never a stored kind).
public enum SearchFamily: String, Equatable, Sendable, CaseIterable {
    /// Hits inside notes: their titles, floating notes, takes, take labels,
    /// block names, comments.
    case notes
    /// Hits inside the scraps area (Snippets): takes and names of blocks whose
    /// home is a pool, and the pools' own names.
    case scraps
    /// Books, gatherings and chapters by name.
    case books
}

/// One local-day-anchored window over a note's time fact, as the store's own
/// canonical UTC ISO-8601 text — `[start, end)`, the `DayBounds` letter
/// (callers build it from `DayBounds(day:)` of the first and last day, so the
/// timezone stays the caller's and SQL never knows what one is).
public struct SearchDayRange: Equatable, Sendable {
    public enum Field: String, Equatable, Sendable, CaseIterable {
        /// "Edited in this range" — the Library day search's UNION (the
        /// note's last-edit stamp, or any savepoint written in the window —
        /// `Queries.editedOnClause`'s rule, the honest reading of the
        /// one-stamp design).
        case edited
        /// The note was created in the range.
        case created
    }

    public let field: Field
    /// INCLUSIVE lower bound (canonical UTC ISO-8601 text).
    public let start: String
    /// EXCLUSIVE upper bound.
    public let end: String

    public init(field: Field, start: String, end: String) {
        self.field = field
        self.start = start
        self.end = end
    }

    /// The range covering local days `first` through `last` inclusive (each a
    /// canonical "yyyy-MM-dd" key); nil when either is not a real day or the
    /// two are out of order. One day is `first == last`.
    public init?(
        field: Field, firstDay: String, lastDay: String,
        calendar: Calendar = JournalDay.storeCalendar
    ) {
        guard let first = DayBounds(day: firstDay, calendar: calendar),
              let last = DayBounds(day: lastDay, calendar: calendar),
              first.start < last.end
        else { return nil }
        self.init(field: field, start: first.start, end: last.end)
    }
}

/// **WHERE A SEARCH LOOKS** — the scope is not part of the query (a saved
/// search runs in whatever place she asks it from); the WING is never
/// optional: search scopes by wing, period (the 13i sitting record §12 —
/// "nothing should cross wings").
public struct SearchScope: Equatable, Sendable {
    public enum Within: Equatable, Sendable {
        /// The whole library of the wing (the Library field, ⌘K).
        case library
        /// One book's (or gathering's materialized) member notes.
        case book(id: String)
        /// One note.
        case note(id: String)
    }

    /// '' = the virtual Home wing (R-13ia-2) — a dangling wing pointer reads
    /// as Home, the `Queries.wingScope` rule.
    public let wingID: String
    public let within: Within

    public init(wingID: String, within: Within = .library) {
        self.wingID = wingID
        self.within = within
    }
}
