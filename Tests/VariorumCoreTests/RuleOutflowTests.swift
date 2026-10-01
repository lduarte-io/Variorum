import Testing

@testable import VariorumCore

/// 13i-b ladder F-R1-2 — `RuleGrammar.soleOutflowTagID`, the SPAWN door's
/// pure outflow derivation (her morning ruling's "exactly ONE distinct tag",
/// sharpened by the ladder: the sole reference must be POSITIVE — `NOT #a`
/// must never become the outflow of a book whose rule excludes it).
///
/// The broken cell's red-on-old is BEHAVIOURAL, through the Mac spawn door
/// (`BindDoorTests.spawnFromANegatedRuleLeavesTheOutflowUnset` — watched red
/// on the pre-fix `ShelfViewModel`); these pin the pure table every arm.
@Suite("13i-b F-R1-2 — the spawn outflow's sole-positive-tag rule")
struct RuleOutflowTests {
    @Test func aBareTagIsTheOutflow() {
        #expect(RuleGrammar.soleOutflowTagID(of: .tag("a")) == "a")
    }

    @Test func aNegatedSoleTagIsNever() {
        #expect(RuleGrammar.soleOutflowTagID(of: .not(.tag("a"))) == nil)
        #expect(RuleGrammar.soleOutflowTagID(of: .and([.not(.tag("a")), .star])) == nil,
                "★ ∧ NOT #a — the implementer's named same-cell")
    }

    @Test func doubleNegationIsPositiveParityNotPresence() {
        #expect(RuleGrammar.soleOutflowTagID(of: .not(.not(.tag("a")))) == "a")
    }

    @Test func twoDistinctTagsHaveNoSingleHonestOutflow() {
        // Her letter: "references exactly ONE distinct tag" — #a ∧ NOT #b
        // references two, so it stays unset (the bundled PROVISIONAL's
        // ambiguous arm; the editor's row is one click).
        #expect(RuleGrammar.soleOutflowTagID(of: .and([.tag("a"), .not(.tag("b"))])) == nil)
        #expect(RuleGrammar.soleOutflowTagID(of: .or([.tag("a"), .tag("b")])) == nil)
    }

    @Test func aTagBesideAStarIsStillSole() {
        #expect(RuleGrammar.soleOutflowTagID(of: .and([.tag("a"), .star])) == "a")
    }

    @Test func mixedPolarityOfOneTagCountsItsPositiveReference() {
        #expect(RuleGrammar.soleOutflowTagID(of: .or([.tag("a"), .not(.tag("a"))])) == "a")
    }

    @Test func noRuleStarOnlyAndTheDeadTermAnswerNil() {
        #expect(RuleGrammar.soleOutflowTagID(of: nil) == nil)
        #expect(RuleGrammar.soleOutflowTagID(of: .star) == nil)
        // `tagIDs` already drops the deliberate dead term (`""`), so an
        // empty-id rule can never nominate an outflow.
        #expect(RuleGrammar.soleOutflowTagID(of: .tag("")) == nil)
    }
}
