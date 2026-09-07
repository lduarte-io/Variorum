import Foundation
import Testing

@testable import VariorumCore

/// The break rule (18c batch 3 — her U-6, with U-19 (4)'s list exception).
/// Pure: no store, no ops. What the OPERATION then does with these breaks is
/// `StructuralSplitAtNewlinesTests`'.
@Suite("Newline splitting — the break rule")
struct NewlineSplittingTests {
    /// The cut the operation places, per break — its start.
    private func cuts(_ text: String) -> [Int] {
        NewlineSplitting.breaks(in: text).map(\.lowerBound)
    }

    @Test func oneParagraphHasNoBreak() {
        #expect(NewlineSplitting.breaks(in: "Just the one paragraph.").isEmpty)
        #expect(NewlineSplitting.breaks(in: "").isEmpty)
        #expect(NewlineSplitting.breaks(in: "   ").isEmpty)
    }

    @Test func aSingleNewlineBetweenProseIsABreak() {
        // Her chip-off note's everyday shape: paragraphs typed with one
        // Return each.
        #expect(cuts("one\ntwo") == [3])
        #expect(cuts("one\ntwo\nthree") == [3, 7])
    }

    @Test func aRunOfNewlinesIsOneBreakAndCarriesItsWholeRun() {
        let breaks = NewlineSplitting.breaks(in: "one\n\ntwo")
        #expect(breaks.count == 1)
        #expect(breaks[0] == 3..<5)
        // Three newlines: still ONE break, the whole run.
        #expect(NewlineSplitting.breaks(in: "one\n\n\ntwo") == [3..<6])
    }

    @Test func aBlankLineCarryingSpacesIsStillOneBreak() {
        // `bulkSegments`' own normalization: a blank line with stray
        // horizontal whitespace is a blank line.
        #expect(NewlineSplitting.breaks(in: "one\n \ntwo") == [3..<6])
    }

    @Test func leadingAndTrailingBlankLinesAreNeverBreaks() {
        // There is no piece on one side of them (the edge-run rule).
        #expect(NewlineSplitting.breaks(in: "\n\none").isEmpty)
        #expect(NewlineSplitting.breaks(in: "one\n\n").isEmpty)
        #expect(NewlineSplitting.breaks(in: "\none\n").isEmpty)
        #expect(cuts("\n\none\n\ntwo\n\n") == [5])
    }

    // MARK: - U-19 (4): lists stay whole

    @Test func adjacentListLinesAreNotABreak() {
        #expect(NewlineSplitting.breaks(in: "- one\n- two\n- three").isEmpty)
        // Checkboxes are the bullet shape — the same lead.
        #expect(NewlineSplitting.breaks(in: "- [ ] one\n- [x] two").isEmpty)
    }

    @Test func aNestedListStaysWholeToo() {
        // K8's indent is nesting CONTENT, and `isListLead` reads past it.
        #expect(NewlineSplitting.breaks(in: "- one\n  - nested\n- two").isEmpty)
    }

    @Test func aListKeepsItsProseNeighboursAtArmsLength() {
        // Prose → list and list → prose are ordinary breaks; only
        // list-beside-list is spared.
        let text = "Intro line\n- one\n- two\nOutro line"
        #expect(cuts(text) == [10, 22])
    }

    @Test func aBlankLineInsideAListIsStillABreak() {
        // The exception is "exactly ONE newline". A blank line is how a
        // paragraph ends everywhere else in the app, list or not.
        #expect(cuts("- one\n\n- two") == [5])
    }

    @Test func aLineThatOnlyLooksLikeAListStillBreaks() {
        // The tokenizer's own law, mirrored: `-x` without the space is not
        // a lead, and neither is a bare dash.
        #expect(cuts("-one\n-two") == [4])
        #expect(cuts("- one\n-two") == [5])
    }

    // MARK: - Offsets

    @Test func offsetsAreUTF16AndSurviveAstralCharacters() {
        // The emoji is two UTF-16 units; the break must sit after both.
        let text = "a👍b\nnext"
        #expect(cuts(text) == [4])
        #expect(NewlineSplitting.breaks(in: text) == [4..<5])
    }

    @Test func everyBreakIsALegalCutForTheOneCutBrain() {
        // The operation hands these straight to `divide`, so each must be
        // interior and grapheme-aligned or the op would refuse.
        let text = "one\n\ntwo\nthree\n\n\nfour"
        for range in NewlineSplitting.breaks(in: text) {
            #expect(range.lowerBound > 0)
            #expect(range.lowerBound < text.utf16.count)
            #expect(BoundarySnapping.seamTrimmedHalves(
                text, cutAtUTF16: range.lowerBound) != nil)
        }
    }
}
