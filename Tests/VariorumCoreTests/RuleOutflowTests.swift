import Testing

@testable import VariorumCore

/// 13i-c — `RuleGrammar.positiveTagIDs`, the SPAWN door's outflow PREFILL
/// (her 13i-b closing-sitting ruling: the outflow is a CHOSEN set the spawn
/// offers, prefilled with the rule's POSITIVE tags — her item (i): `#a AND
/// NOT #b` → `#a`; several tags legal). It REPLACES 13i-b's single-tag
/// `soleOutflowTagID` (F-R1-2's parity letter is kept inside it: a tag
/// counts only when some reference sits under an EVEN number of `not`s).
///
/// The behavioural pin is the Mac spawn door (`BindDoorTests`); these pin the
/// pure table every arm — an HONEST REWRITE of the 13i-b suite to the ruled
/// truth (the sole-tag letter was superseded, not broken).
@Suite("13i-c — the spawn prefill's positive-tags rule")
struct RuleOutflowTests {
    @Test func aBareTagIsTheOutflow() {
        #expect(RuleGrammar.positiveTagIDs(of: .tag("a")) == ["a"])
    }

    @Test func aNegatedTagIsNever() {
        #expect(RuleGrammar.positiveTagIDs(of: .not(.tag("a"))) == [])
        #expect(RuleGrammar.positiveTagIDs(of: .and([.not(.tag("a")), .star])) == [],
                "★ ∧ NOT #a — the implementer's named same-cell")
    }

    @Test func doubleNegationIsPositiveParityNotPresence() {
        #expect(RuleGrammar.positiveTagIDs(of: .not(.not(.tag("a")))) == ["a"])
    }

    @Test func herItemOneAAndNotBFlowsOutAOnly() {
        #expect(RuleGrammar.positiveTagIDs(of: .and([.tag("a"), .not(.tag("b"))])) == ["a"])
    }

    @Test func anOrFanPrefillsEveryTagInTreeOrder() {
        // Her ruling: several tags are legal ("my writing, poetry, and
        // horror … that's still two tags") — the prefill carries all of
        // them, in the order the rule names them.
        #expect(RuleGrammar.positiveTagIDs(of: .or([.tag("b"), .tag("a")])) == ["b", "a"])
    }

    @Test func aTagBesideAStarIsStillTheOutflow() {
        #expect(RuleGrammar.positiveTagIDs(of: .and([.tag("a"), .star])) == ["a"])
    }

    @Test func mixedPolarityOfOneTagCountsItsPositiveReferenceOnce() {
        #expect(RuleGrammar.positiveTagIDs(of: .or([.tag("a"), .not(.tag("a")), .tag("a")])) == ["a"])
    }

    @Test func noRuleStarOnlyAndTheDeadTermAnswerEmpty() {
        #expect(RuleGrammar.positiveTagIDs(of: nil) == [])
        #expect(RuleGrammar.positiveTagIDs(of: .star) == [])
        // The deliberate dead term (`""`) can never nominate an outflow.
        #expect(RuleGrammar.positiveTagIDs(of: .tag("")) == [])
    }
}
