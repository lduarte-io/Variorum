import Foundation

/// **THE LIBRARY'S FACETS** — the scope picker of the Library's search state
/// (13o U2's D3): All · Notes · Books · Blocks, each a NARROWING of the one
/// question (R-13o-8: one AST; a facet composes into its FILTER half and
/// never into SQL of its own).
///
/// Core-side since VX-819 (batch 1) so the rule a facet reads — and the
/// numbers its band says (`Queries.searchCounts(_:query:facet:scope:calendar:)`)
/// — are pure, pinned headless, and shared by any face that offers the same
/// picker. The Mac's `LibraryCatalogModel.Scope` maps onto it one to one
/// (`posts` is `notes` — the model term and the noun she uses).
///
/// Pure and dependency-free — no GRDB, no AppKit.
public enum SearchFacet: String, Equatable, Sendable, CaseIterable {
    /// The whole question.
    case all
    /// Hits inside notes (their titles, floating notes, takes, labels,
    /// block names, comments) and the notes a worn day names.
    case notes
    /// Books, gatherings and chapters by name.
    case books
    /// **Every BLOCK-LEVEL hit** (VX-734 — her R-819-1, *"Widen Blocks"*:
    /// *"it's weird and doesn't make sense to not have blocks in there when
    /// it's called blocks"*; the set is the architect's, A-819-B1): a hit on
    /// a block's own content — a take's words, a take's label, a block's
    /// name, a block's comment, a take's commit — in notes AND in Snippets
    /// (the scraps family rides as before, its pools' own names included).
    /// Never a note's title or floating notes (the NOTE's fields), never a
    /// book or chapter, never the worn day. A commit lists only behind the
    /// `+ commits` facet — the composer's fence is the one gate, upstream of
    /// every scope.
    case blocks

    /// What the facet narrows the question to; nil = the whole question.
    public var filter: SearchFilter? {
        switch self {
        case .all: nil
        case .notes: .family(.notes)
        case .books: .family(.books)
        case .blocks: .any([
            .family(.scraps), .docKind(.take), .docKind(.takeLabel), .docKind(.blockName),
            .docKind(.comment), .docKind(.savepoint),
        ])
        }
    }

    /// **The question as this facet asks it** — the facet's filter ANDed
    /// into the filter half (the scope a group page, an "all N ›" road and
    /// the Books section read).
    public func narrowing(_ query: SearchQuery) -> SearchQuery {
        guard let narrow = filter else { return query }
        var scoped = query
        scoped.filter = query.filter.map { .all([$0, narrow]) } ?? narrow
        return scoped
    }
}
