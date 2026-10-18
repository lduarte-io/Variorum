import Foundation
import GRDB
import Testing
@testable import VariorumCore

// VX-217 — a new note born inside a gathering (option (A) as ruled, her
// R-VX214-3/4; the run record `notes/plans/fixes/vx-214-settings-launch-polish.md`).
// The planner is pure and the op's transitions are exact: the note is born
// in the gathering's wing wearing what the rule needs, the gathering shows
// it, no membership row exists, and every refusal leaves nothing behind.

@Suite("Gathering mint — the planner (VX-217)")
struct GatheringMintPlannerTests {
    private func outcome(
        _ term: RuleTerm?, archived: Bool = false, finished: Bool = false,
        dead: Set<String> = []
    ) -> GatheringMint.Outcome {
        GatheringMint.outcome(
            archived: archived, finished: finished,
            rule: term.map { .rule($0) } ?? .none,
            tagIsLive: { !dead.contains($0) },
            deadTagPath: { "path-of-\($0)" })
    }

    @Test func aTagRulePlansItsTagsInRuleOrderOnce() {
        #expect(outcome(.and([.tag("b"), .tag("a"), .tag("b")]))
                == .plan(.init(tagIDs: ["b", "a"], star: false)))
        #expect(outcome(.tag("a")) == .plan(.init(tagIDs: ["a"], star: false)))
    }

    /// R-VX214-4 — her "autostar a note at creation".
    @Test func aStarTermIsSatisfiableAtMint() {
        #expect(outcome(.star) == .plan(.init(tagIDs: [], star: true)))
        #expect(outcome(.and([.tag("a"), .star])) == .plan(.init(tagIDs: ["a"], star: true)))
    }

    @Test func anAnyOfGroupTakesItsFirstSatisfiableOption() {
        #expect(outcome(.or([.tag("a"), .tag("b")])) == .plan(.init(tagIDs: ["a"], star: false)))
        #expect(outcome(.or([.tag("a"), .tag("b")]), dead: ["a"])
                == .plan(.init(tagIDs: ["b"], star: false)),
                "a dead first option need not grey a door another option opens")
        #expect(outcome(.or([.star, .tag("b")])) == .plan(.init(tagIDs: [], star: true)))
        #expect(outcome(.and([.tag("b"), .or([.tag("a"), .tag("b")])]))
                == .plan(.init(tagIDs: ["b"], star: false)),
                "a group another conjunct already meets adds nothing")
    }

    @Test func nestedConjunctionsFlatten() {
        #expect(outcome(.and([.tag("a"), .and([.star, .tag("c")])]))
                == .plan(.init(tagIDs: ["a", "c"], star: true)))
    }

    /// Her ruling's unsatisfiable class: NOT terms, legacy date/profile
    /// terms, no rule / malformed rule, dead tags — plus the shapes a mint
    /// cannot aim at (an empty or mixed any-of group).
    @Test func theUnsatisfiableClassBlocks() {
        #expect(outcome(nil) == .blocked(.noRule))
        #expect(GatheringMint.outcome(
            archived: false, finished: false, rule: .malformed, tagIsLive: { _ in true })
                == .blocked(.malformedRule))
        #expect(outcome(.and([.tag("a"), .not(.tag("b"))])) == .blocked(.unreachableTerm))
        #expect(outcome(.legacyEntryDateFrom("2026-01-01")) == .blocked(.datedRule))
        #expect(outcome(.legacyEntryDateTo("2026-01-01")) == .blocked(.datedRule))
        #expect(outcome(.legacyProfile("journal")) == .blocked(.kindRule))
        #expect(outcome(.tag("a"), dead: ["a"]) == .blocked(.deadTag(path: "path-of-a")))
        #expect(outcome(.or([.tag("a"), .tag("b")]), dead: ["a", "b"])
                == .blocked(.deadTag(path: "path-of-a")))
        #expect(outcome(.or([])) == .blocked(.unreachableTerm))
        #expect(outcome(.or([.tag("a"), .not(.star)])) == .blocked(.unreachableTerm))
    }

    @Test func theGatheringsOwnStateBlocksFirst() {
        #expect(outcome(.tag("a"), archived: true) == .blocked(.archived))
        #expect(outcome(nil, archived: true) == .blocked(.archived))
        #expect(outcome(.tag("a"), finished: true) == .blocked(.finished))
    }

    /// VX-250 (2) — her SHORTER hovers (QUESTIONS #217), byte for byte, and
    /// her fallback for a dead tag no row remembers. (A JUSTIFIED EDIT: this
    /// slot pinned the long lowercase fragments that followed "This gathering
    /// can't take a new note: " — her answer retired both.)
    @Test func herShorterHoversLandVerbatim() {
        #expect(GatheringMint.Blocker.archived.reason
                == "Archived \u{2014} unarchive it to add notes.")
        #expect(GatheringMint.Blocker.deadTag(path: "essays").reason
                == "Its rule needs #essays, which no longer exists.")
        #expect(GatheringMint.Blocker.unreachableTerm.reason == "Its rule can't match a new note.")
        #expect(GatheringMint.Blocker.deadTag(path: nil).reason
                == "Its rule needs a tag that no longer exists.")
        #expect(GatheringMint.unmatchedReason == GatheringMint.Blocker.unreachableTerm.reason,
                "the belt says what the greyed door would have")
    }

    /// The rest, drafted into her register: one terse sentence each —
    /// capitalized, closed with a period, no shouting (no all-caps word).
    @Test func everyReasonIsATerseSentenceInHerRegister() {
        let all: [GatheringMint.Blocker] = [
            .archived, .finished, .noRule, .malformedRule, .deadTag(path: "x/y"),
            .deadTag(path: nil), .datedRule, .kindRule, .unreachableTerm,
        ]
        for blocker in all {
            let reason = blocker.reason
            #expect(reason.first?.isUppercase == true, "\(blocker): \(reason)")
            #expect(reason.hasSuffix("."), "\(blocker): \(reason)")
            #expect(reason.count <= 64, "terse: \(blocker): \(reason)")
            let shouted = reason.split(whereSeparator: { !$0.isLetter })
                .filter { $0.count > 1 && $0.allSatisfy(\.isUppercase) }
            #expect(shouted.isEmpty, "\(blocker): \(reason)")
        }
        #expect(Set(all.map(\.reason)).count == all.count, "each says its own thing")
    }
}

@Suite("Gathering mint — newPostInGathering (VX-217)")
struct GatheringMintOperationTests {
    private func gathering(
        _ ops: Operations, _ term: RuleTerm, wingID: String = ""
    ) throws -> Reading {
        try ops.createReading(
            name: "the gathering", kind: .gathering,
            querySpec: try RuleGrammar.encode(term), wingId: wingID)
    }

    private func shown(_ db: AppDatabase, _ readingID: String) throws -> [String] {
        try db.read { try Queries.assembleReading($0, readingID: readingID).map(\.postID) }
    }

    private func liveNotes(_ db: AppDatabase) throws -> Int {
        try db.fetchInt(
            "SELECT COUNT(*) FROM container WHERE kind = 'post' AND deleted_at IS NULL") ?? -1
    }

    @Test func aTagRuleMintsATaggedNoteTheGatheringShows() throws {
        try withOperations { ops, db in
            let poems = try ops.createTag(name: "poems")
            let reading = try gathering(ops, .tag(poems.id))

            let result = try ops.newPostInGathering(reading.id)
            #expect(result.appliedTagPaths == ["poems"])
            #expect(result.starred == false)
            #expect(result.post.title == nil)
            #expect(try shown(db, reading.id) == [result.post.id],
                    "the gathering shows the new note — its rule matches")
            #expect(try db.fetchInt(
                "SELECT COUNT(*) FROM post_tag WHERE post_id = ? AND tag_id = ? AND deleted_at IS NULL",
                [result.post.id, poems.id]) == 1)
            #expect(try db.fetchInt("SELECT COUNT(*) FROM reading_post") == 0,
                    "a gathering holds nothing — no membership row is minted")
            let starred = try db.read { try Queries.starredNoteIDs($0) }
            #expect(!starred.contains(result.post.id), "a tag rule stars nothing")
        }
    }

    /// R-VX214-4 — the star arm: a star rule's new note is born starred.
    @Test func aStarRuleMintsAStarredNote() throws {
        try withOperations { ops, db in
            let reading = try gathering(ops, .star)

            let result = try ops.newPostInGathering(reading.id)
            #expect(result.starred)
            #expect(result.appliedTagPaths.isEmpty)
            let starred = try db.read { try Queries.starredNoteIDs($0) }
            #expect(starred.contains(result.post.id))
            #expect(try shown(db, reading.id) == [result.post.id])
        }
    }

    @Test func aTagAndStarRuleDoesBoth() throws {
        try withOperations { ops, db in
            let drafts = try ops.createTag(name: "drafts")
            let reading = try gathering(ops, .and([.tag(drafts.id), .star]))

            let result = try ops.newPostInGathering(reading.id)
            #expect(result.appliedTagPaths == ["drafts"])
            #expect(result.starred)
            #expect(try shown(db, reading.id) == [result.post.id])
        }
    }

    /// The born-starred mints' precedent (P-13id-U2-1 — PROVISIONAL here):
    /// a mint never fails on a star, so the cap does not refuse it.
    @Test func theStarIsCapExemptAtMint() throws {
        try withOperations { ops, db in
            for i in 0..<Operations.starLimit {
                let note = try ops.createPost(title: "starred \(i)")
                try ops.setStarred(.post(note.id), starred: true)
            }
            let reading = try gathering(ops, .star)
            let result = try ops.newPostInGathering(reading.id)
            #expect(result.starred)
            #expect(try shown(db, reading.id).contains(result.post.id))
        }
    }

    @Test func theNoteIsBornInTheGatheringsWing() throws {
        try withOperations { ops, db in
            let wing = try ops.createWing(name: "elsewhere")
            let tag = try ops.createTag(name: "letters", wingID: wing.id)
            let reading = try gathering(ops, .tag(tag.id), wingID: wing.id)

            let result = try ops.newPostInGathering(reading.id)
            #expect(result.post.wingId == wing.id)
            #expect(try shown(db, reading.id) == [result.post.id])
        }
    }

    /// The applying act is heard: a living book whose rule hears the tag
    /// seats the new note, exactly as R98's tagging would.
    @Test func theTaggingIsAnApplyingActEveryLivingBookHears() throws {
        try withOperations { ops, db in
            let poems = try ops.createTag(name: "poems")
            let living = try ops.createReading(
                name: "the living book", kind: .book,
                querySpec: try RuleGrammar.encode(.tag(poems.id)))
            let reading = try gathering(ops, .tag(poems.id))

            let result = try ops.newPostInGathering(reading.id)
            let members = try db.read {
                try Queries.assembleReading($0, readingID: living.id).map(\.postID)
            }
            #expect(members == [result.post.id])
        }
    }

    // MARK: - Refusals leave nothing behind

    private func expectRefusal(
        _ ops: Operations, _ db: AppDatabase, _ readingID: String,
        reasonContains needle: String
    ) throws {
        let notes = try liveNotes(db)
        let tags = try db.fetchInt("SELECT COUNT(*) FROM post_tag") ?? -1
        let stars = try db.read { try Queries.starredNoteIDs($0) }
        #expect {
            try ops.newPostInGathering(readingID)
        } throws: { error in
            guard case .smartFilterUnsatisfiable(_, let reason) = error as? OperationError
            else { return false }
            return reason.contains(needle)
        }
        #expect(try liveNotes(db) == notes, "a refusal mints no stray note")
        #expect(try db.fetchInt("SELECT COUNT(*) FROM post_tag") == tags)
        #expect(try db.read { try Queries.starredNoteIDs($0) } == stars)
    }

    @Test func aNotTermRefusesBeforeTheMint() throws {
        try withOperations { ops, db in
            let a = try ops.createTag(name: "a")
            let b = try ops.createTag(name: "b")
            let reading = try gathering(ops, .and([.tag(a.id), .not(.tag(b.id))]))
            try expectRefusal(
                ops, db, reading.id,
                reasonContains: GatheringMint.Blocker.unreachableTerm.reason)
        }
    }

    @Test func anArchivedGatheringRefuses() throws {
        try withOperations { ops, db in
            let a = try ops.createTag(name: "a")
            let reading = try gathering(ops, .and([.tag(a.id), .star]))
            try ops.archiveReading(reading.id)
            // (JUSTIFIED EDIT at VX-250 (2): her sentence, "Archived — …".)
            try expectRefusal(
                ops, db, reading.id, reasonContains: GatheringMint.Blocker.archived.reason)
        }
    }

    @Test func aDeadTagRefusesByName() throws {
        try withOperations { ops, db in
            let ghost = try ops.createTag(name: "ghost")
            let reading = try gathering(ops, .and([.star, .tag(ghost.id)]))
            try ops.deleteTag(ghost.id)
            try expectRefusal(ops, db, reading.id, reasonContains: "#ghost")
        }
    }

    @Test func aLegacyDateRuleRefuses() throws {
        try withOperations { ops, db in
            let reading = try gathering(ops, .legacyEntryDateFrom("2026-01-01"))
            try expectRefusal(ops, db, reading.id, reasonContains: "entry date")
        }
    }

    @Test func aBookIsTheWrongKind() throws {
        try withOperations { ops, _ in
            let book = try ops.createReading(name: "a book", kind: .book)
            #expect {
                try ops.newPostInGathering(book.id)
            } throws: { error in
                guard case .wrongReadingKind(_, let expected) = error as? OperationError
                else { return false }
                return expected == .gathering
            }
        }
    }

    /// The ONE authority: what the door reads is what the op does.
    @Test func theDoorsReadIsTheOpsPlan() throws {
        try withOperations { ops, db in
            let a = try ops.createTag(name: "a")
            let reading = try gathering(ops, .and([.tag(a.id), .star]))
            let read = try db.read { try Queries.gatheringMintOutcome($0, reading: reading) }
            #expect(read == .plan(.init(tagIDs: [a.id], star: true)))
            let result = try ops.newPostInGathering(reading.id)
            #expect(result.appliedTagPaths == ["a"] && result.starred)
        }
    }
}
