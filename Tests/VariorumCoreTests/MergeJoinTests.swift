import Testing
@testable import VariorumCore

@Suite("MergeJoin (13b Stage 4, Batch 4B — the one join brain)")
struct MergeJoinTests {
    @Test func canonInsertsASingleSpaceBetweenBareEdges() {
        #expect(MergeJoin.canon(head: "First half.", tail: "Second half.") == .space)
        #expect(MergeJoin.canon(head: "First half.", tail: "Second half.")
            .joined("First half.", "Second half.") == "First half. Second half.")
    }

    @Test func canonNeverDoublesExistingEdgeWhitespace() {
        // Either side's edge bringing whitespace suppresses the space —
        // AppSpec §9's letter (author decision 2026-07-06).
        #expect(MergeJoin.canon(head: "Trailing space ", tail: "next") == .nothing)
        #expect(MergeJoin.canon(head: "head", tail: " leading space") == .nothing)
        #expect(MergeJoin.canon(head: "line one\n", tail: "line two") == .nothing)
        #expect(MergeJoin.canon(head: "Trailing space ", tail: "next")
            .joined("Trailing space ", "next") == "Trailing space next")
    }

    @Test func canonAddsNothingWhenASideIsEmpty() {
        #expect(MergeJoin.canon(head: "", tail: "tail") == .nothing)
        #expect(MergeJoin.canon(head: "head", tail: "") == .nothing)
        #expect(MergeJoin.canon(head: "", tail: "") == .nothing)
    }

    @Test func explicitJoinsAreExactlyTheirSeparator() {
        #expect(MergeJoin.space.joined("a", "b") == "a b")
        #expect(MergeJoin.newline.joined("a", "b") == "a\nb")
        #expect(MergeJoin.nothing.joined("a", "b") == "ab")
        // Explicit means explicit: a chosen space is one space even when an
        // edge already carries whitespace — the preview shows the result.
        #expect(MergeJoin.space.joined("a ", "b") == "a  b")
    }
}
