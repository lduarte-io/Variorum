import Foundation
import GRDB
import Testing

@testable import VariorumCore

/// 13i-b U3 — the rule editor's brain (`Domain/RuleEditing`) and the auto-tag
/// offer's count (`Queries.membersMissingTag`).
///
/// New surface (structural red-on-old: neither existed). What the suite pins
/// is the plan §4's contract for the face that replaces the v1 draft vehicle:
///
/// - **saving never silently drops a term** — the editor's state IS the
///   stored grammar, so every shape round-trips, and every edit touches only
///   the node it addresses (a property over a corpus of shapes, below);
/// - an UNEDITED save writes nothing (structural equality, never bytes);
/// - grandfathered legacy terms are read-only (no edit removes one, through
///   any parent) and are never minted;
/// - the editor never mints an empty group.
@Suite("The rule editor's brain (13i-b U3)")
struct RuleEditingTests {
    // MARK: - The corpus: every shape the grammar can store

    private static let a = RuleTerm.tag("tag-a")
    private static let b = RuleTerm.tag("tag-b")
    private static let c = RuleTerm.tag("tag-c")
    private static let dead = RuleTerm.tag("")

    static let corpus: [RuleTerm] = [
        a,
        .star,
        dead,
        .not(a),
        .not(.not(a)),
        .and([a, .star]),
        .or([a, b, c]),
        .and([a, .or([b, .not(.star)]), .not(.and([c, dead]))]),
        .not(.or([a, b])),
        .and([]),  // a STORED empty group (only a hand-written value can carry one)
        .or([.and([]), a]),
        .and([.legacyProfile("journal"), .legacyEntryDateFrom("2026-01-01"), a]),
        .and([.or([.legacyEntryDateTo("2026-12-31"), b]), .not(.star)]),
        .legacyProfile("blog"),
        .or([.not(.not(.and([a, .or([b, .star])]))), .legacyProfile("generic")]),
    ]

    /// Every leaf of a tree, in order (the multiset an edit must preserve).
    private static func leaves(_ term: RuleTerm?) -> [RuleTerm] {
        guard let term else { return [] }
        switch term {
        case .and(let ts), .or(let ts): return ts.flatMap { leaves($0) }
        case .not(let t): return leaves(t)
        default: return [term]
        }
    }

    private static func node(at path: RuleEditing.Path, in term: RuleTerm) -> RuleTerm? {
        guard let index = path.first else { return term }
        let rest = Array(path.dropFirst())
        switch term {
        case .and(let ts), .or(let ts):
            return ts.indices.contains(index) ? node(at: rest, in: ts[index]) : nil
        case .not(let t):
            return index == 0 ? node(at: rest, in: t) : nil
        default:
            return nil
        }
    }

    private static func removing(_ removed: [RuleTerm], from all: [RuleTerm]) -> [RuleTerm] {
        var rest = all
        for leaf in removed {
            if let i = rest.firstIndex(of: leaf) { rest.remove(at: i) }
        }
        return rest
    }

    // MARK: - Saving never silently drops a term

    @Test func everyStoredShapeIsAStateOfTheEditorAndAnUneditedSaveWritesNothing() throws {
        for term in Self.corpus {
            let stored = try RuleGrammar.encode(term)
            #expect(RuleGrammar.decode(stored) == term, "\(term) round-trips the grammar")
            #expect(RuleEditing.needsWrite(draft: term, stored: stored) == false,
                    "an unedited save of \(term) writes nothing")
        }
    }

    @Test func aNonCanonicalStoredSpellingIsStillAnUneditedSave() {
        // Same rule, different bytes: a re-encode would differ — and on a BOOK
        // a "changed" rule is a catch-up occasion. Structural equality only.
        let spaced = #"{ "and" : [ {"tag":"tag-a"}, {"star":true} ] }"#
        #expect(RuleEditing.needsWrite(draft: .and([Self.a, .star]), stored: spaced) == false)
        #expect(RuleEditing.needsWrite(draft: .and([Self.a]), stored: spaced) == true)
    }

    @Test func noRuleAndAMalformedRuleAnswerHonestly() {
        #expect(RuleEditing.needsWrite(draft: nil, stored: nil) == false)
        #expect(RuleEditing.needsWrite(draft: Self.a, stored: nil) == true)
        #expect(RuleEditing.needsWrite(draft: nil, stored: #"{"tag":"tag-a"}"#) == true)
        // The face refuses to edit what it cannot read: never overwritten here.
        #expect(RuleEditing.needsWrite(draft: Self.a, stored: "{not json") == false)
        #expect(RuleEditing.needsWrite(draft: nil, stored: #"{"tag":1}"#) == false)
    }

    /// THE property: over every shape and every row with a remove door, the
    /// removal takes EXACTLY the leaves under that row — nothing else moves.
    /// Negation and combinator flips take no leaf at all.
    @Test func everyEditTouchesOnlyTheNodeItAddresses() throws {
        for term in Self.corpus {
            let before = Self.leaves(term)
            for row in RuleEditing.rows(of: term) {
                if row.isRemovable {
                    let target = try #require(Self.node(at: row.path, in: term))
                    let after = RuleEditing.remove(at: row.path, of: term)
                    #expect(Self.leaves(after) == Self.removing(Self.leaves(target), from: before),
                            "removing \(row.kind) from \(term) took only its own leaves")
                }
                if row.isEditable {
                    let negated = RuleEditing.toggleNegation(at: row.path, of: term)
                    #expect(Self.leaves(negated) == before, "not keeps every leaf of \(term)")
                    // …and toggling again restores the exact tree.
                    #expect(RuleEditing.toggleNegation(at: row.path, of: negated) == term
                            || row.negations > 0,
                            "a fresh not toggles back to \(term)")
                }
                if case .group(let combinator, _) = row.kind {
                    let flipped = RuleEditing.setCombinator(
                        combinator == .all ? .any : .all, at: row.nodePath, of: term)
                    #expect(Self.leaves(flipped) == before)
                    #expect(RuleEditing.setCombinator(combinator, at: row.nodePath, of: flipped) == term)
                }
            }
        }
    }

    @Test func aGrandfatheredTermCanNeverBeRemovedThroughAnyParent() throws {
        for term in Self.corpus where RuleEditing.carriesLegacy(term) {
            let legacyBefore = Self.leaves(term).filter {
                if case .tag = $0 { return false }
                if case .star = $0 { return false }
                return true
            }
            for row in RuleEditing.rows(of: term) where row.isRemovable {
                let after = Self.leaves(RuleEditing.remove(at: row.path, of: term))
                for legacy in legacyBefore {
                    #expect(after.contains(legacy), "\(legacy) survives removing \(row.kind)")
                }
            }
            for row in RuleEditing.rows(of: term) {
                if case .legacy = row.kind {
                    #expect(!row.isEditable && !row.isRemovable, "a legacy row is read-only")
                }
            }
        }
    }

    // MARK: - The edits, exactly

    @Test func addingBuildsTheRuleItNames() {
        // From no rule: the term IS the rule.
        #expect(RuleEditing.add(Self.a, into: nil, of: nil) == Self.a)
        // At the root beside a lone term: the two become "all of".
        #expect(RuleEditing.add(.star, into: nil, of: Self.a) == .and([Self.a, .star]))
        // At the root of an un-negated group: appended.
        #expect(RuleEditing.add(Self.c, into: nil, of: .or([Self.a, Self.b]))
                == .or([Self.a, Self.b, Self.c]))
        // Beside a negated root: wrapped, the negation untouched.
        #expect(RuleEditing.add(Self.c, into: nil, of: .not(.or([Self.a, Self.b])))
                == .and([.not(.or([Self.a, Self.b])), Self.c]))
        // Into a nested group by its node path (through a not).
        let tree = RuleTerm.and([Self.a, .not(.or([Self.b]))])
        #expect(RuleEditing.add(.star, into: [1, 0], of: tree)
                == .and([Self.a, .not(.or([Self.b, .star]))]))
        // An invalid address changes nothing.
        #expect(RuleEditing.add(.star, into: [0], of: tree) == tree)
        #expect(RuleEditing.add(.star, into: [9], of: tree) == tree)
    }

    @Test func aNewGroupIsBornSeededNeverEmpty() {
        let built = RuleEditing.addGroup(.any, seededWith: Self.b, into: nil, of: Self.a)
        #expect(built == .and([Self.a, .or([Self.b])]))
        let first = RuleEditing.addGroup(.all, seededWith: .star, into: nil, of: nil)
        #expect(first == .and([.star]))
    }

    @Test func removingAGroupsLastTermRemovesTheGroupAndItsNotUpward() {
        // The nested group empties → it goes, its `not` with it.
        let tree = RuleTerm.and([Self.a, .not(.or([Self.b]))])
        #expect(RuleEditing.remove(at: [1, 0, 0], of: tree) == .and([Self.a]))
        // The root's last term clears the rule.
        #expect(RuleEditing.remove(at: [0], of: .and([Self.a])) == nil)
        #expect(RuleEditing.remove(at: [], of: Self.a) == nil)
        // A chain of single-child groups prunes all the way to no rule.
        #expect(RuleEditing.remove(at: [0, 0, 0], of: .and([.or([.not(Self.a)])])) == nil)
        // A STORED empty group is not hers to lose: an unrelated edit keeps it.
        #expect(RuleEditing.remove(at: [1], of: .or([.and([]), Self.a])) == .or([.and([])]))
    }

    @Test func notWrapsAndUnwrapsExactlyOneLayer() {
        #expect(RuleEditing.toggleNegation(at: [0], of: .and([Self.a])) == .and([.not(Self.a)]))
        #expect(RuleEditing.toggleNegation(at: [0], of: .and([.not(Self.a)])) == .and([Self.a]))
        #expect(RuleEditing.toggleNegation(at: [], of: .not(.not(Self.a))) == .not(Self.a))
    }

    @Test func theCombinatorFlipKeepsTheChildren() {
        #expect(RuleEditing.setCombinator(.any, at: [], of: .and([Self.a, .star]))
                == .or([Self.a, .star]))
        #expect(RuleEditing.setCombinator(.all, at: [1, 0], of: .and([Self.a, .not(.or([Self.b]))]))
                == .and([Self.a, .not(.and([Self.b]))]))
    }

    // MARK: - The rows the face draws

    @Test func theRowsSayEveryNodeWithItsDepthNegationAndAddDoors() {
        let tree = RuleTerm.and([Self.a, .not(.or([Self.b, Self.dead])), .legacyProfile("journal")])
        let rows = RuleEditing.rows(of: tree)
        #expect(rows.map(\.kind) == [
            .group(.all, childCount: 3),
            .tag("tag-a"),
            .group(.any, childCount: 2),
            .tag("tag-b"),
            .tag(""),
            .adder(target: [1, 0]),
            .legacy(.legacyProfile("journal")),
            .adder(target: []),
        ])
        #expect(rows.map(\.depth) == [0, 1, 1, 2, 2, 2, 1, 1])
        #expect(rows[2].negations == 1)
        #expect(rows[2].path == [1])
        #expect(rows[2].nodePath == [1, 0])
        #expect(rows[0].isRemovable == false, "the root holds a legacy term")
        #expect(rows[2].isRemovable == true)
        #expect(rows[6].isEditable == false)
    }

    @Test func aLoneRootTermGetsTheWrappingAddDoor() {
        #expect(RuleEditing.rows(of: .star).map(\.kind) == [.star, .adder(target: nil)])
        #expect(RuleEditing.rows(of: .not(.or([Self.a]))).map(\.kind) == [
            .group(.any, childCount: 1), .tag("tag-a"), .adder(target: [0]), .adder(target: nil),
        ])
        #expect(RuleEditing.rows(of: nil).isEmpty)
    }

    // MARK: - The auto-tag offer's count

    @Test func theOffersCountIsExactlyWhatTagAllMembersTags() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(name: "book", kind: .book)
            let outflow = try ops.createTag(name: "out")
            let wearing = try ops.createPost(title: "wears it")
            let bare = try ops.createPost(title: "bare")
            let archived = try ops.createPost(title: "archived")
            let removed = try ops.createPost(title: "removed")
            for post in [wearing, bare, archived, removed] {
                try ops.addPostToReading(post.id, to: book.id)
            }
            _ = try ops.applyTag(outflow.id, toPost: wearing.id)
            try ops.archiveContainer(archived.id)
            try ops.removePostFromReading(removed.id, from: book.id)
            // A waiting arrival is never a member and is never counted.
            let waiting = try ops.createPost(title: "waiting")
            try db.write { db in
                try ReadingPost(
                    id: "arrival-1", readingId: book.id, postId: waiting.id,
                    position: "z", status: .arrival, createdAt: Date()
                ).insert(db)
            }

            let promised = try db.read {
                try Queries.membersMissingTag($0, readingID: book.id, tagID: outflow.id)
            }
            #expect(promised == 2, "bare + archived — never the wearer, the removed, the arrival")
            let tagged = try ops.tagAllMembers(book.id, tagID: outflow.id)
            #expect(tagged == promised)
            #expect(try db.read {
                try Queries.membersMissingTag($0, readingID: book.id, tagID: outflow.id)
            } == 0)
            // A dead tag can tag nothing.
            try ops.deleteTag(outflow.id)
            #expect(try db.read {
                try Queries.membersMissingTag($0, readingID: book.id, tagID: outflow.id)
            } == 0)
        }
    }
}
