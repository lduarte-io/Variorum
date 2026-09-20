import Testing
@testable import VariorumCore

@Suite("MergeJoin (13b Stage 4, Batch 4B — the one join brain; R-13u4-3's two rules)")
struct MergeJoinTests {
    // MARK: - The DOORS rule (R-13u4-3, 2026-09-20 — 13u4 UNIT E3)

    @Test func everyDoorJoinsWithExactlyOneNewline() {
        // Her ruling: the RENDERING join, so the page reads byte-identical
        // before and after the merge. SUPERSEDES the 2026-07-06 single space
        // (this pin read `== .space` until E3 rewrote it to the ruling).
        #expect(MergeJoinRule.door.join(head: "First half.", tail: "Second half.") == .newline)
        #expect(MergeJoinRule.door.join(head: "First half.", tail: "Second half.")
            .joined("First half.", "Second half.") == "First half.\nSecond half.")
    }

    @Test func theDoorRuleHasNoConditionalsLeftToDrift() {
        // "byte-exact, no trimming, no conditionals" — her words. Every
        // shape the old rule forked on answers the same way now: edges that
        // already carry whitespace, a newline-ended head, an empty side.
        #expect(MergeJoinRule.door.join(head: "Trailing space ", tail: "next") == .newline)
        #expect(MergeJoinRule.door.join(head: "head", tail: " leading space") == .newline)
        #expect(MergeJoinRule.door.join(head: "line one\n", tail: "line two") == .newline)
        #expect(MergeJoinRule.door.join(head: "", tail: "tail") == .newline)
        #expect(MergeJoinRule.door.join(head: "head", tail: "") == .newline)
        #expect(MergeJoinRule.door.join(head: "", tail: "") == .newline)
        // And nothing is trimmed: a head that already ends in a newline
        // gains a second one, because the page showed two lines there.
        #expect(MergeJoinRule.door.join(head: "line one\n", tail: "line two")
            .joined("line one\n", "line two") == "line one\n\nline two")
    }

    // MARK: - The DELETES rule (the shipped join, kept byte-exact)

    @Test func aDeleteKeystrokeStillPutsASingleSpaceBetweenBareEdges() {
        // A delete that produced the newline it just removed would visibly
        // do nothing — so the seam carve and the cross-block compound keep
        // the pre-ruling rule VERBATIM (these three pins are the old
        // `canon` suite's, moved to the rule that still owns them).
        #expect(MergeJoinRule.deleteKeystroke.join(head: "First half.", tail: "Second half.")
            == .space)
        #expect(MergeJoinRule.deleteKeystroke.join(head: "First half.", tail: "Second half.")
            .joined("First half.", "Second half.") == "First half. Second half.")
    }

    @Test func aDeleteKeystrokeNeverDoublesExistingEdgeWhitespace() {
        #expect(MergeJoinRule.deleteKeystroke.join(head: "Trailing space ", tail: "next")
            == .nothing)
        #expect(MergeJoinRule.deleteKeystroke.join(head: "head", tail: " leading space")
            == .nothing)
        #expect(MergeJoinRule.deleteKeystroke.join(head: "line one\n", tail: "line two")
            == .nothing)
        #expect(MergeJoinRule.deleteKeystroke.join(head: "Trailing space ", tail: "next")
            .joined("Trailing space ", "next") == "Trailing space next")
    }

    @Test func aDeleteKeystrokeAddsNothingWhenASideIsEmpty() {
        #expect(MergeJoinRule.deleteKeystroke.join(head: "", tail: "tail") == .nothing)
        #expect(MergeJoinRule.deleteKeystroke.join(head: "head", tail: "") == .nothing)
        #expect(MergeJoinRule.deleteKeystroke.join(head: "", tail: "") == .nothing)
    }

    // MARK: - The three explicit joins (the ceremony's per-pairing control)

    @Test func explicitJoinsAreExactlyTheirSeparator() {
        #expect(MergeJoin.space.joined("a", "b") == "a b")
        #expect(MergeJoin.newline.joined("a", "b") == "a\nb")
        #expect(MergeJoin.nothing.joined("a", "b") == "ab")
        // Explicit means explicit: a chosen space is one space even when an
        // edge already carries whitespace — the preview shows the result.
        #expect(MergeJoin.space.joined("a ", "b") == "a  b")
    }

    @Test func theDoorRuleIsTheEditorSurfacesOwnSeparator() {
        // The load-bearing equality of the whole ruling: "the page reads
        // byte-identical" is true only because the door's separator IS the
        // one the editor joins blocks with (`EditorDocument.separator`,
        // author-confirmed interpretation 2a). Core cannot import the app's
        // brain, so the byte is asserted here and the app-side twin
        // (`SeamMergeTests`) asserts the identity against the constant.
        #expect(MergeJoinRule.door.join(head: "a", tail: "b").separator == "\n")
    }
}
