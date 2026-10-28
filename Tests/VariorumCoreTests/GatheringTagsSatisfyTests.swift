import Foundation
import Testing

@testable import VariorumCore

// VX-549 (VX-548 batch 3) — WHAT TAGS ALONE CAN DO, a pure function on the rule
// grammar. Her sitting (2026-10-27, RATIFIED): "Starring is not on the wire …
// so write_new on a rule tagging can't satisfy (star terms) refuses honestly
// and the grant sheet presents such a grant as read/suggest-shaped." The ONE
// planner (`GatheringMint.outcome` — her own gathering doors' authority) is
// asked with the star forbidden (`starrable: false`): a plan means tags can
// satisfy; a block the same planner WITH the star would plan is `needsStar`.
// NOT terms count as tag-satisfiable — a fresh note meets `NOT #x` (and
// `NOT ★`) by not wearing it.

@Suite("VX-549 — tags-can-satisfy and needs-a-star, on the rule grammar")
struct GatheringTagsSatisfyTests {
    private let a = RuleTerm.tag("a")
    private let b = RuleTerm.tag("b")

    /// The unit table: rule → (tags alone can satisfy, needs a star).
    @Test func theTable() {
        let rows: [(String, RuleTerm, Bool, Bool)] = [
            ("#a", a, true, false),
            ("#a AND #b", .and([a, b]), true, false),
            ("#a OR #b", .or([a, b]), true, false),
            ("★", .star, false, true),
            ("#a AND ★", .and([a, .star]), false, true),
            ("★ AND #a", .and([.star, a]), false, true),
            ("★ OR #a — a tag option is taken", .or([.star, a]), true, false),
            ("#a OR ★", .or([a, .star]), true, false),
            ("NOT #a — met by not wearing it", .not(a), true, false),
            ("#a AND NOT #b", .and([a, .not(b)]), true, false),
            ("NOT ★ — met by not being starred", .not(.star), true, false),
            ("#a AND NOT ★", .and([a, .not(.star)]), true, false),
            ("#a OR NOT #b (a NOT option)", .or([a, .not(b)]), true, false),
            ("(★ OR #a) AND NOT #a — only the star gets in", .and([.or([.star, a]), .not(a)]), false, true),
            ("#a AND NOT #a — nothing gets in", .and([a, .not(a)]), false, false),
            ("★ AND NOT ★ — nothing gets in", .and([.star, .not(.star)]), false, false),
            ("the dead term", .tag(""), false, false),
            ("the dead term AND ★", .and([.tag(""), .star]), false, false),
            ("a legacy profile term", .legacyProfile("journal"), false, false),
            ("a legacy date term AND ★", .and([.legacyEntryDateFrom("2026-01-01"), .star]), false, false),
            ("an empty any-of group", .or([]), false, false),
            ("a nested group inside an any-of", .or([.and([a, b]), .star]), false, false),
        ]
        for (name, term, tags, star) in rows {
            #expect(GatheringMint.tagsCanSatisfy(term) == tags, "\(name): tags can satisfy")
            #expect(GatheringMint.needsStar(term) == star, "\(name): needs a star")
            // The two are never both true: a star is "the" gap only where tags fall short.
            #expect(!(GatheringMint.tagsCanSatisfy(term) && GatheringMint.needsStar(term)), "\(name)")
        }
        #expect(!GatheringMint.needsStar(nil), "no rule is no star question")
    }

    /// Her own doors are untouched: the default (`starrable: true`) planner
    /// stars where it did, and never answers `.needsStar`.
    @Test func herDoorsStillStarAndNeverSayNeedsStar() {
        for term in [RuleTerm.star, .and([a, .star]), .or([.star, a]), .and([.or([.star, a]), .not(a)])] {
            let outcome = GatheringMint.outcome(
                archived: false, finished: false, rule: .rule(term), tagIsLive: { _ in true })
            guard case .plan(let plan) = outcome else {
                Issue.record("her door plans \(term): \(outcome)")
                continue
            }
            #expect(plan.star, "her door stars for \(term)")
        }
    }

    /// The wire's plan, star forbidden: an any-of group's TAG option is taken
    /// (her door would star — the first satisfiable option), and the blockers
    /// her door speaks stay hers (an archived gathering is archived first).
    @Test func theWirePlanTakesATagWhereHerDoorWouldStar() {
        let wire = GatheringMint.outcome(
            archived: false, finished: false, rule: .rule(.or([.star, a])), tagIsLive: { _ in true },
            starrable: false)
        #expect(wire == .plan(.init(tagIDs: ["a"], star: false)))
        let archived = GatheringMint.outcome(
            archived: true, finished: false, rule: .rule(.star), tagIsLive: { _ in true }, starrable: false)
        #expect(archived == .blocked(.archived), "the gathering's own state speaks first")
        let dead = GatheringMint.outcome(
            archived: false, finished: false, rule: .rule(.and([a, .star])), tagIsLive: { _ in false },
            starrable: false)
        #expect(dead == .blocked(.deadTag(path: nil)), "a dead tag the star could not fix is the dead tag")
        // A DELIBERATE FLIP (VX-596 — her ruling 2026-10-27, "let's add the star
        // over the wire"; the ticket's wording point 3): the case's words were
        // "Its rule needs a starred note, and only the author can star one." — a
        // premise `set_starred` made false. No door speaks the case now (the
        // wire stars where it is the block — `starringOnlyWhereNeeded`), so it
        // keeps only the fact.
        #expect(GatheringMint.Blocker.needsStar.reason == "Its rule needs a starred note.")
        #expect(!GatheringMint.Blocker.needsStar.reason.contains("only the author"))
    }

    /// **VX-596 — the wire's write new: tags first, the star only where it is
    /// the only way in** (RB-1, PROVISIONAL — `starringOnlyWhereNeeded`). Every
    /// rule the star-forbidden walk plans keeps VX-549's plan exactly; every
    /// rule it refused for want of a star (`needsStar`) takes her door's own
    /// plan, starred; every other block stays the block. RED ON OLD by
    /// construction (the composition did not exist; the wire refused the star
    /// rows — `MCPGatheringGrantServerTests`' red run).
    @Test func theWirePlansTagsFirstAndStarsOnlyWhereAStarIsTheOnlyWayIn() {
        let rows: [(String, RuleTerm, GatheringMint.Outcome)] = [
            ("#a", a, .plan(.init(tagIDs: ["a"], star: false))),
            ("★ OR #a — the tag, where her door stars", .or([.star, a]), .plan(.init(tagIDs: ["a"], star: false))),
            ("#a OR ★", .or([a, .star]), .plan(.init(tagIDs: ["a"], star: false))),
            ("★", .star, .plan(.init(tagIDs: [], star: true))),
            ("#a AND ★", .and([a, .star]), .plan(.init(tagIDs: ["a"], star: true))),
            ("(★ OR #a) AND NOT #a — only the star gets in", .and([.or([.star, a]), .not(a)]),
             .plan(.init(tagIDs: [], star: true))),
            ("#a AND NOT ★ — never starred", .and([a, .not(.star)]), .plan(.init(tagIDs: ["a"], star: false))),
            ("#a AND NOT #a — nothing gets in", .and([a, .not(a)]), .blocked(.unreachableTerm)),
            ("★ AND NOT ★ — nothing gets in", .and([.star, .not(.star)]), .blocked(.unreachableTerm)),
            ("a legacy date term AND ★", .and([.legacyEntryDateFrom("2026-01-01"), .star]), .blocked(.datedRule)),
        ]
        for (name, term, expected) in rows {
            let wire = GatheringMint.wireGrammarOutcome(term)
            #expect(wire == expected, "\(name): \(wire)")
            #expect(wire != .blocked(.needsStar), "\(name): the wire never answers needs-a-star")
            // Where the star-forbidden walk planned, the wire's plan IS that plan
            // (VX-549's behaviour byte-unchanged); where it needed the star, the
            // wire's plan is her door's.
            if GatheringMint.tagsCanSatisfy(term) {
                #expect(wire == GatheringMint.grammarOutcome(term, starrable: false), "\(name)")
            }
            if GatheringMint.needsStar(term) {
                #expect(wire == GatheringMint.grammarOutcome(term, starrable: true), "\(name)")
            }
        }
        // The gathering's own state still speaks first.
        let archived = GatheringMint.starringOnlyWhereNeeded { starrable in
            GatheringMint.outcome(
                archived: true, finished: false, rule: .rule(.star), tagIsLive: { _ in true }, starrable: starrable)
        }
        #expect(archived == .blocked(.archived))
    }
}
