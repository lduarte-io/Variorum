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
    /// Block-level hits (D3): the scraps family beside block NAMES.
    case blocks

    /// What the facet narrows the question to; nil = the whole question.
    public var filter: SearchFilter? {
        switch self {
        case .all: nil
        case .notes: .family(.notes)
        case .books: .family(.books)
        case .blocks: .any([.family(.scraps), .docKind(.blockName)])
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
