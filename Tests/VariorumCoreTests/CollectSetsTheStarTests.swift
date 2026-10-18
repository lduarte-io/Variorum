import Foundation
import GRDB
import Testing
@testable import VariorumCore

// VX-249 — R98's collect-EXISTING door sets the star a gathering's rule needs
// (her answer to the star asymmetry, QUESTIONS #217: "the collect door sets
// the star too", and — her correction the same day — starring an existing
// note to collect it IGNORES the 15-star limit, like the mint). The door now
// plans through the mint's planner (`GatheringMint.outcome`, ONE authority),
// started from what the note already wears.
//
// RED ON OLD: every op pin below marked so refused on the pre-VX-249 tree
// (`smartFilterUnsatisfiable` — "tagging alone can't satisfy its filter"):
// R98's walk had no answer for a ★ term, and took an any-of group's FIRST
// tag even where the rule's NOT forbade it.

@Suite("VX-249 — the planner, started from the note as it stands")
struct CollectPlannerStartingStateTests {
    private func outcome(
        _ term: RuleTerm, wears: Set<String> = [], starred: Bool = false,
        legacy: Bool? = nil, dead: Set<String> = []
    ) -> GatheringMint.Outcome {
        GatheringMint.outcome(
            archived: false, finished: false, rule: .rule(term),
            tagIsLive: { !dead.contains($0) },
            deadTagPath: { "path-of-\($0)" },
            noteWears: { wears.contains($0) && !dead.contains($0) },
            noteStarred: starred,
            noteMeetsLegacy: { _ in legacy })
    }

    @Test func whatTheNoteAlreadyWearsIsNeverPlannedAgain() {
        #expect(outcome(.and([.tag("a"), .tag("b")]), wears: ["a"])
                == .plan(.init(tagIDs: ["b"], star: false)))
        #expect(outcome(.and([.tag("a"), .star]), starred: true)
                == .plan(.init(tagIDs: ["a"], star: false)),
                "an already-starred note is never starred again")
        #expect(outcome(.and([.tag("a"), .star]))
                == .plan(.init(tagIDs: ["a"], star: true)), "an unstarred one is")
        #expect(outcome(.or([.tag("a"), .tag("b")]), wears: ["b"])
                == .plan(.init(tagIDs: [], star: false)),
                "an any-of the note meets by what it wears takes no option")
    }

    /// A legacy term an existing note MEETS adds nothing; one it doesn't still
    /// blocks (R98's own descriptive refusals run before the planner).
    @Test func aLegacyTermTheNoteMeetsIsMet() {
        #expect(outcome(.and([.tag("a"), .legacyProfile("journal")]), legacy: true)
                == .plan(.init(tagIDs: ["a"], star: false)))
        #expect(outcome(.and([.tag("a"), .legacyProfile("journal")]), legacy: false)
                == .blocked(.kindRule))
        #expect(outcome(.and([.tag("a"), .legacyEntryDateFrom("2026-01-01")]), legacy: nil)
                == .blocked(.datedRule), "a NULL entry date is UNKNOWN, as in SQL")
        #expect(outcome(.and([.tag("x"), .or([.legacyProfile("journal"), .tag("a")])]), legacy: true)
                == .plan(.init(tagIDs: ["x"], star: false)),
                "a legacy option the note meets meets its group")
    }

    /// R98's mixed any-of (a nested option) the note already meets by what it
    /// wears never greys the door (the old walk skipped such a group and let
    /// its end probe decide).
    @Test func aNestedOptionTheNoteWearsMeetsItsGroup() {
        let rule: RuleTerm = .and([.tag("x"), .or([.tag("a"), .and([.tag("b"), .tag("c")])])])
        #expect(outcome(rule, wears: ["b", "c"]) == .plan(.init(tagIDs: ["x"], star: false)))
        #expect(outcome(rule, wears: ["b"]) == .blocked(.unreachableTerm),
                "half a nested option is not the option — still not a group a plan can aim at")
    }

    /// The NOT side, for a note that already wears things: a NOT over a tag it
    /// wears can't be met by adding (the door never removes a tag), and the
    /// any-of pick avoids what a NOT forbids exactly as the mint's does.
    @Test func theNotSemanticsReadTheNoteAsItStands() {
        #expect(outcome(.and([.tag("a"), .not(.tag("b"))]), wears: ["b"]) == .blocked(.unreachableTerm))
        #expect(outcome(.and([.star, .not(.tag("b"))]), wears: ["b"]) == .blocked(.unreachableTerm))
        #expect(outcome(.and([.or([.tag("a"), .tag("c")]), .not(.tag("a"))]))
                == .plan(.init(tagIDs: ["c"], star: false)))
        #expect(outcome(.or([.tag("a"), .not(.star)]), starred: true)
                == .plan(.init(tagIDs: ["a"], star: false)),
                "starred, so NOT ★ fails — the group takes #a")
    }
}

@Suite("VX-249 — R98's collect door sets the star")
struct CollectSetsTheStarTests {
    private func gathering(
        _ ops: Operations, _ term: RuleTerm, name: String = "the gathering"
    ) throws -> Reading {
        try ops.createReading(name: name, kind: .gathering, querySpec: try RuleGrammar.encode(term))
    }

    private func starredNotes(_ db: AppDatabase) throws -> [String] {
        try db.read { try Queries.starredNoteIDs($0) }
    }

    private func liveTagIDs(_ db: AppDatabase, _ postID: String) throws -> Set<String> {
        try db.read {
            Set(try String.fetchAll(
                $0, sql: "SELECT tag_id FROM post_tag WHERE post_id = ? AND deleted_at IS NULL",
                arguments: [postID]))
        }
    }

    private func shown(_ db: AppDatabase, _ readingID: String) throws -> [String] {
        try db.read { try Queries.assembleReading($0, readingID: readingID).map(\.postID) }
    }

    /// RED ON OLD. A ★ rule: the door stars the note, reports it, and the
    /// gathering shows it — no tag applied, nothing else written.
    @Test func aStarRuleCollectStarsTheNoteAndReportsIt() throws {
        try withOperations { ops, db in
            let g = try gathering(ops, .star)
            let note = try ops.createPost(title: "loose piece")
            let tagsBefore = try db.fetchInt("SELECT COUNT(*) FROM post_tag") ?? -1

            let result = try ops.collectPostIntoSmartReading(note.id, into: g.id)
            #expect(result == Operations.SmartCollectResult(
                appliedTagPaths: [], alreadyMatched: false, gatheringArchived: false, starred: true))
            #expect(try starredNotes(db) == [note.id], "the ONE star write: the list gains the note")
            #expect(try db.fetchInt("SELECT COUNT(*) FROM post_tag") == tagsBefore, "no tag applied")
            #expect(try shown(db, g.id) == [note.id], "the gathering shows it now")

            let again = try ops.collectPostIntoSmartReading(note.id, into: g.id)
            #expect(again.alreadyMatched && !again.starred, "a second press is a reported no-op")
        }
    }

    /// RED ON OLD. `tag ∧ ★`: both in ONE act — the tag through the one
    /// application road, the star through the one star write.
    @Test func aTagAndStarRuleTagsAndStarsInOneAct() throws {
        try withOperations { ops, db in
            let drafts = try ops.createTag(name: "drafts")
            let g = try gathering(ops, .and([.tag(drafts.id), .star]))
            let note = try ops.createPost(title: "a piece")

            let result = try ops.collectPostIntoSmartReading(note.id, into: g.id)
            #expect(result.appliedTagPaths == ["drafts"])
            #expect(result.starred)
            #expect(try liveTagIDs(db, note.id) == [drafts.id])
            #expect(try starredNotes(db) == [note.id])
            #expect(try shown(db, g.id) == [note.id])
        }
    }

    /// RED ON OLD. Her ruling: the 15-star limit never blocks the collect —
    /// the note always joins. Her own Star door still meets the cap.
    @Test func theCollectsStarIsCapExempt() throws {
        try withOperations { ops, db in
            for index in 0..<Operations.starLimit {
                let other = try ops.createPost(title: "starred \(index)")
                try ops.setStarred(.post(other.id), starred: true)
            }
            let g = try gathering(ops, .star)
            let note = try ops.createPost(title: "one more")

            let result = try ops.collectPostIntoSmartReading(note.id, into: g.id)
            #expect(result.starred)
            #expect(try starredNotes(db).count == Operations.starLimit + 1)
            #expect(try shown(db, g.id).contains(note.id))

            let mine = try ops.createPost(title: "by hand")
            #expect(throws: OperationError.starLimitReached(limit: Operations.starLimit)) {
                try ops.setStarred(.post(mine.id), starred: true)
            }
        }
    }

    /// RED ON OLD. Starring is an APPLYING act (13i-b U1): a living book on a
    /// ★ rule hears the collect's star and seats the note.
    @Test func theCollectsStarIsAnApplyingActALivingBookHears() throws {
        try withOperations { ops, db in
            let book = try ops.createReading(
                name: "living", kind: .book, querySpec: try RuleGrammar.encode(.star))
            let g = try gathering(ops, .star)
            let note = try ops.createPost(title: "heard")

            _ = try ops.collectPostIntoSmartReading(note.id, into: g.id)
            #expect(try shown(db, book.id) == [note.id], "the living ★ book seats it")
        }
    }

    /// The unwind, exactly: a collect whose writes the belt refuses (a note of
    /// ANOTHER wing — no door offers this; the fixture is the raw row) leaves
    /// the note's star and tags as they were.
    @Test func aRefusedCollectUnwindsTheStarAndTheTags() throws {
        try withOperations { ops, db in
            let drafts = try ops.createTag(name: "drafts")
            let g = try gathering(ops, .and([.tag(drafts.id), .star]))
            let note = try ops.createPost(title: "elsewhere")
            let far = try ops.createWing(name: "far")
            try db.write { db in
                try db.execute(
                    sql: "UPDATE container SET wing_id = ? WHERE id = ?", arguments: [far.id, note.id])
            }
            let settingBefore = try db.fetchString("SELECT value FROM setting WHERE key = 'starred'")

            #expect(throws: OperationError.self) {
                try ops.collectPostIntoSmartReading(note.id, into: g.id)
            }
            #expect(try starredNotes(db).isEmpty, "the star write unwound")
            #expect(try db.fetchString("SELECT value FROM setting WHERE key = 'starred'") == settingBefore)
            #expect(try liveTagIDs(db, note.id).isEmpty, "the tag application unwound")
        }
    }

    /// RED ON OLD — the ONE authority's any-of pick: R98 took the group's
    /// FIRST tag even where the rule's NOT forbade it, then refused at its
    /// probe; the planner takes the option the NOT allows.
    @Test func theAnyOfPickKeepsTheRulesNot() throws {
        try withOperations { ops, db in
            let a = try ops.createTag(name: "a")
            let c = try ops.createTag(name: "c")
            let g = try gathering(ops, .and([.or([.tag(a.id), .tag(c.id)]), .not(.tag(a.id))]))
            let note = try ops.createPost(title: "n")

            let result = try ops.collectPostIntoSmartReading(note.id, into: g.id)
            #expect(result.appliedTagPaths == ["c"])
            #expect(!result.starred)
            #expect(try shown(db, g.id) == [note.id])
        }
    }

    /// A guard (green on both trees): an any-of the note already meets by a
    /// NESTED option still lets the door apply the rest — the old walk's
    /// skip-and-probe, kept by the planner's `alreadyMet`.
    @Test func anAnyOfMetByANestedOptionStillCollects() throws {
        try withOperations { ops, db in
            let tags = try ["x", "a", "b", "c"].map { try ops.createTag(name: $0) }
            let (x, a, b, c) = (tags[0], tags[1], tags[2], tags[3])
            let g = try gathering(
                ops, .and([.tag(x.id), .or([.tag(a.id), .and([.tag(b.id), .tag(c.id)])])]))
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(b.id, toPost: note.id)
            _ = try ops.applyTag(c.id, toPost: note.id)

            let result = try ops.collectPostIntoSmartReading(note.id, into: g.id)
            #expect(result.appliedTagPaths == ["x"])
            #expect(try shown(db, g.id) == [note.id])
        }
    }

    /// A guard: a NOT over a tag the note wears can't be met by adding — the
    /// standing refusal, and nothing written (no star either).
    @Test func aNotTheNoteBreaksRefusesAndWritesNothing() throws {
        try withOperations { ops, db in
            let b = try ops.createTag(name: "b")
            let g = try gathering(ops, .and([.star, .not(.tag(b.id))]))
            let note = try ops.createPost(title: "n")
            _ = try ops.applyTag(b.id, toPost: note.id)

            #expect {
                try ops.collectPostIntoSmartReading(note.id, into: g.id)
            } throws: { error in
                guard case .smartFilterUnsatisfiable(_, let reason) = (error as? OperationError)
                else { return false }
                return reason == "tagging alone can't satisfy its filter"
            }
            #expect(try starredNotes(db).isEmpty)
        }
    }
}
