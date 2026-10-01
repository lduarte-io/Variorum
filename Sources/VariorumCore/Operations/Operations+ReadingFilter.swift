import Foundation
import GRDB

// THE IN-BOOK FILTER — mechanics (13i-b U4; the sitting record §18.1, her
// ORIGINAL sitting ask: "being able to either filter a book within itself for
// a subset of the tags, or make a new book to look at just the tags, is
// important"). The filter itself is a READ (`Queries.assembleReading(…,
// filter:)` — view-local, never membership); this file is its one write:
// "Save this filter as a gathering" — rule = the book's tag association ∧ the
// filter, "where the boolean grammar earns its keep". Headless at U4; the
// filter bar and this door's face are 13i-d's.
extension Operations {
    /// What "the book's tag association" was read as (PROVISIONAL P-13ib-U4-6
    /// — the record carries the options).
    public enum FilterAssociation: Equatable, Sendable {
        /// The reading's own RULE — a gathering's, or a living book's (its
        /// rule IS what it gathers from: "Gathers from: …", §4).
        case rule
        /// A book with no readable rule, through its live AUTO-TAG (what notes
        /// written there are tagged — the book's outflow, §4).
        case autoTag
        /// Neither: the filter alone (a hand-made book has no tag to gather
        /// by). The minted gathering then shows every matching note in the
        /// wing, not only this book's — the door's face must say so.
        case none
    }

    public struct SavedFilterGathering: Equatable, Sendable {
        public let reading: Reading
        public let association: FilterAssociation
    }

    /// Mints a GATHERING whose rule is `association ∧ filter`, beside the
    /// reading it was filtered on (same wing; unshelved, unstarred — a new
    /// working object, §19.3). ONE transaction. The reading is untouched — a
    /// filter never mutates membership, and saving one never edits the book.
    ///
    /// No name guard here: `assertBookNameIsFree` is the DOOR's (E13's ruled
    /// shape — "refuse at the door"; the ops stay name-agnostic so the
    /// seeders and sync never refuse for a name). No undo entry —
    /// `createReading`'s class (deleting the gathering is the road back).
    ///
    /// Refuses: a dead reading (`readingNotFound`); a GATHERING whose own rule
    /// is MALFORMED (`smartFilterUnsatisfiable` — the association cannot be
    /// read, and the collect door's wording for the same state is reused). A
    /// BOOK with a malformed rule falls through to its auto-tag (its intake
    /// runs nothing — P-13ib-5 — so the rule is not what it gathers from).
    @discardableResult
    public func saveFilterAsGathering(
        _ readingID: String, filter: RuleTerm, name: String
    ) throws -> SavedFilterGathering {
        let now = date.now
        return try database.write { db in
            let source = try liveReading(db, readingID)
            let association: RuleTerm?
            let kind: FilterAssociation
            switch (source.kind, RuleGrammar.read(source.querySpec)) {
            case (_, .rule(let rule)):
                association = rule
                kind = .rule
            case (.gathering, .malformed):
                throw OperationError.smartFilterUnsatisfiable(
                    readingID: readingID,
                    reason: "its rule is unreadable (malformed) — edit the rule first")
            case (.gathering, .none):
                // A rule-less gathering shows every note in its wing, so
                // "everything ∧ filter" IS the filter — exact, not a fallback.
                association = nil
                kind = .rule
            case (.book, _):
                if let tagID = source.autoTagId,
                   let tag = try Tag.fetchOne(db, key: tagID),
                   tag.deletedAt == nil, tag.wingId == source.wingId {
                    association = .tag(tagID)
                    kind = .autoTag
                } else {
                    association = nil
                    kind = .none
                }
            }
            let gathering = Reading(
                id: newID(), ownerId: currentOwnerID(), name: name, kind: .gathering,
                querySpec: try RuleGrammar.encode(RuleGrammar.conjoin(association, filter)),
                wingId: source.wingId,
                createdAt: now, updatedAt: now)
            try gathering.insert(db)
            return SavedFilterGathering(reading: gathering, association: kind)
        }
    }
}
