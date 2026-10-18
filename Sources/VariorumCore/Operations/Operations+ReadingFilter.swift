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
            let (association, kind) = try Queries.filterAssociation(db, source: source)
            let spec = try RuleGrammar.encode(RuleGrammar.conjoin(association, filter))
            // 13i-c (R-13ic-4): the minted GATHERING needs a rule — an empty
            // filter over no association would mint a rule-less one.
            guard spec != nil else {
                throw OperationError.gatheringRequiresRule(id: readingID)
            }
            let gathering = Reading(
                id: newID(), ownerId: currentOwnerID(), name: StoredText.stripped(name), kind: .gathering,  // VX-357
                querySpec: spec,
                wingId: source.wingId,
                createdAt: now, updatedAt: now)
            try gathering.insert(db)
            return SavedFilterGathering(reading: gathering, association: kind)
        }
    }
}

extension Queries {
    /// **"The book's tag association"** — what a saved filter is conjoined
    /// with (PROVISIONAL P-13ib-U4-6). EXTRACTED at 13i-d U3, unchanged, from
    /// `Operations.saveFilterAsGathering` (which calls it inside its own
    /// transaction) so the filter bar's save door can SAY what the gathering
    /// will gather from BEFORE it mints — the op's instruction to the face
    /// ("the door's face must say so") made possible without a second copy of
    /// the rule.
    ///
    /// Refuses a GATHERING whose own rule is malformed
    /// (`smartFilterUnsatisfiable`); a BOOK with a malformed rule falls
    /// through to its outflow.
    public static func filterAssociation(
        _ db: Database, source: Reading
    ) throws -> (term: RuleTerm?, kind: Operations.FilterAssociation) {
        switch (source.kind, RuleGrammar.read(source.querySpec)) {
        case (_, .rule(let rule)):
            return (rule, .rule)
        case (.gathering, .malformed):
            throw OperationError.smartFilterUnsatisfiable(
                readingID: source.id,
                reason: "its rule is unreadable (malformed) — edit the rule first")
        case (.gathering, .none):
            // 13i-c (R-13ic-4): a rule-less gathering SHOWS NOTHING (it can
            // exist live only as a Trash restoree); its association is
            // nothing, so the saved rule is the filter alone — the face must
            // say so (the `.none` reading).
            return (nil, .none)
        case (.book, _):
            // 13i-c (R-13ic-1): the OUTFLOW is a set — every live tag of it
            // is what notes written there wear, so the association is their
            // conjunction (ALL of them ride each note).
            let live = try source.autoTagIDs.filter { tagID in
                guard let tag = try Tag.fetchOne(db, key: tagID) else { return false }
                return tag.deletedAt == nil && tag.wingId == source.wingId
            }
            if !live.isEmpty {
                return (live.count == 1 ? .tag(live[0]) : .and(live.map { .tag($0) }), .autoTag)
            }
            return (nil, .none)
        }
    }
}
