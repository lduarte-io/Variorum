import Testing
@testable import VariorumCore

@Suite("Boundary snapping (Phase 3, Step 1)")
struct BoundarySnappingTests {
    // MARK: Boundaries — sentence granularity

    @Test func sentenceBoundariesSitAtTheStartOfTheNextSentence() {
        // "One." ends at 4, next sentence starts at 5; "Two!" → next at 10.
        #expect(BoundarySnapping.boundaries(in: "One. Two! Three?", granularity: .sentence)
            == [0, 5, 10, 16])
    }

    @Test func terminatorRunsAndClosersStayWithTheirSentence() {
        let text = #"He said "Stop!" and left. Really?! Fine."#
        // Boundaries after «Stop!"», after «left.», after «Really?!»; the
        // final «Fine.» ends at the text's end boundary.
        #expect(BoundarySnapping.boundaries(in: text, granularity: .sentence)
            == [0, 16, 26, 35, 40])
    }

    @Test func decimalNumbersDoNotEndSentences() {
        #expect(BoundarySnapping.boundaries(in: "Pi is 3.14 roughly. True.", granularity: .sentence)
            == [0, 20, 25])
    }

    @Test func newlineEndsASentenceEvenWithoutATerminator() {
        // The paragraph break doubles as a sentence boundary.
        #expect(BoundarySnapping.boundaries(in: "No terminator\nNext line.", granularity: .sentence)
            == [0, 14, 24])
    }

    // MARK: Boundaries — paragraph granularity

    @Test func paragraphBoundariesSitAfterNewlineRuns() {
        let text = "Para one.\n\nPara two.\nPara three."
        #expect(BoundarySnapping.boundaries(in: text, granularity: .paragraph)
            == [0, 11, 21, 32])
        // Sentence granularity is a superset: it adds nothing here (each
        // paragraph is one sentence, terminators sit against the newlines).
        #expect(BoundarySnapping.boundaries(in: text, granularity: .sentence)
            == [0, 11, 21, 32])
    }

    @Test func separatorRunsMayMixSpacesAndNewlines() {
        // "text. \nNext": the run « \n» contains a newline → one boundary.
        #expect(BoundarySnapping.boundaries(in: "text. \nNext", granularity: .paragraph)
            == [0, 7, 11])
    }

    @Test func sentenceBreaksAreInvisibleToParagraphGranularity() {
        #expect(BoundarySnapping.boundaries(in: "One. Two! Three?", granularity: .paragraph)
            == [0, 16])
    }

    @Test func leadingAndTrailingSeparatorsProduceNoInternalBoundaries() {
        // No content before the leading run / after the trailing run.
        #expect(BoundarySnapping.boundaries(in: "\n\nOnly paragraph\n\n", granularity: .paragraph)
            == [0, 18])
    }

    @Test func emptyTextHasOneBoundary() {
        #expect(BoundarySnapping.boundaries(in: "", granularity: .sentence) == [0])
        #expect(BoundarySnapping.boundaries(in: "", granularity: .paragraph) == [0])
    }

    // MARK: Snap

    @Test func snapPicksTheNearestBoundary() {
        let text = "One. Two! Three?"  // boundaries [0, 5, 10, 16]
        #expect(BoundarySnapping.snap(3, in: text, granularity: .sentence) == 5)
        #expect(BoundarySnapping.snap(2, in: text, granularity: .sentence) == 0)
        #expect(BoundarySnapping.snap(7, in: text, granularity: .sentence) == 5)
        #expect(BoundarySnapping.snap(13, in: text, granularity: .sentence) == 10)  // 13 ties 10/16 → earlier
        #expect(BoundarySnapping.snap(14, in: text, granularity: .sentence) == 16)
    }

    @Test func snapTieBreaksTowardTheEarlierBoundary() {
        // "ab. cd." boundaries [0, 4, 7]; cut 2 is equidistant from 0 and 4.
        #expect(BoundarySnapping.snap(2, in: "ab. cd.", granularity: .sentence) == 0)
    }

    @Test func snapClampsOutOfRangeCuts() {
        let text = "One. Two."
        #expect(BoundarySnapping.snap(-5, in: text, granularity: .sentence) == 0)
        #expect(BoundarySnapping.snap(99, in: text, granularity: .sentence) == text.utf16.count)
        #expect(BoundarySnapping.snap(3, in: "", granularity: .paragraph) == 0)
    }

    @Test func snapAtParagraphGranularityOnMultiParagraphBlocks() {
        let text = "Para one.\n\nPara two.\nPara three."  // [0, 11, 21, 32]
        #expect(BoundarySnapping.snap(9, in: text, granularity: .paragraph) == 11)
        #expect(BoundarySnapping.snap(17, in: text, granularity: .paragraph) == 21)
        #expect(BoundarySnapping.snap(30, in: text, granularity: .paragraph) == 32)
    }

    // MARK: UTF-16 convention (TextKit 2's unit) on multi-scalar graphemes

    @Test func offsetsCountUTF16CodeUnitsAcrossEmoji() {
        // 👩‍👩‍👧‍👦 = four surrogate pairs + three ZWJs = 11 UTF-16 units, offsets 3–13.
        let text = "Hi 👩‍👩‍👧‍👦. Done."
        #expect(text.utf16.count == 21)
        #expect(BoundarySnapping.boundaries(in: text, granularity: .sentence) == [0, 16, 21])
        #expect(BoundarySnapping.snap(10, in: text, granularity: .sentence) == 16)
    }

    @Test func offsetsInsideAGraphemeAreRejected() {
        let emoji = "Hi 👩‍👩‍👧‍👦. Done."
        #expect(BoundarySnapping.graphemeIndex(atUTF16: 3, in: emoji) != nil)
        #expect(BoundarySnapping.graphemeIndex(atUTF16: 4, in: emoji) == nil)   // mid surrogate pair
        #expect(BoundarySnapping.graphemeIndex(atUTF16: 5, in: emoji) == nil)   // scalar-aligned, mid cluster
        #expect(BoundarySnapping.graphemeIndex(atUTF16: 14, in: emoji) != nil)

        // Combining mark: "é" as e + U+0301 is one grapheme, two UTF-16 units.
        let combining = "Cafe\u{301}. More."
        #expect(BoundarySnapping.graphemeIndex(atUTF16: 4, in: combining) == nil)
        #expect(BoundarySnapping.boundaries(in: combining, granularity: .sentence) == [0, 7, 12])
    }

    @Test func graphemeIndexBoundsChecks() {
        #expect(BoundarySnapping.graphemeIndex(atUTF16: -1, in: "ab") == nil)
        #expect(BoundarySnapping.graphemeIndex(atUTF16: 3, in: "ab") == nil)
        #expect(BoundarySnapping.graphemeIndex(atUTF16: 0, in: "") != nil)
        #expect(BoundarySnapping.graphemeRange(0..<5, in: "Hi 👩‍👩‍👧‍👦") == nil)
    }

    // MARK: Extract classification

    @Test func prefixAndSuffixSpansClassifyExactly() {
        let text = "First sentence. Second sentence."  // end = 32
        #expect(BoundarySnapping.extractableSpan(0..<15, in: text) == .prefix)
        #expect(BoundarySnapping.extractableSpan(0..<16, in: text) == .prefix)  // span may carry the seam
        #expect(BoundarySnapping.extractableSpan(16..<32, in: text) == .suffix)
        #expect(BoundarySnapping.extractableSpan(15..<32, in: text) == .suffix)
    }

    @Test func middleSpansAreNotExtractable() {
        let text = "First sentence. Second sentence."
        #expect(BoundarySnapping.extractableSpan(6..<15, in: text) == nil)
    }

    @Test func wholeTextAndDegenerateSpansAreNotExtractable() {
        let text = "First sentence. Second sentence."
        #expect(BoundarySnapping.extractableSpan(0..<32, in: text) == nil)   // nothing would survive
        #expect(BoundarySnapping.extractableSpan(5..<5, in: text) == nil)    // empty
        #expect(BoundarySnapping.extractableSpan(1..<3, in: "A  B") == nil)  // blank span
        #expect(BoundarySnapping.extractableSpan(0..<40, in: text) == nil)   // out of bounds
    }

    @Test func outerEdgeWhitespaceIsTolerated() {
        // Trailing newline between the span and the text's end: still a suffix.
        #expect(BoundarySnapping.extractableSpan(7..<13, in: "Hello. World.\n") == .suffix)
        // Leading spaces before a prefix span: still a prefix.
        #expect(BoundarySnapping.extractableSpan(2..<8, in: "  Hello. World.") == .prefix)
    }

    @Test func graphemeSplittingSpansAreNotExtractable() {
        #expect(BoundarySnapping.extractableSpan(0..<5, in: "Hi 👩‍👩‍👧‍👦. Done.") == nil)
    }

    // MARK: Seam-trimmed halves

    @Test func seamTrimmingDropsTheSeparatorFromBothHalves() {
        let halves = BoundarySnapping.seamTrimmedHalves("Para one.\n\nPara two.", cutAtUTF16: 11)
        #expect(halves?.first == "Para one.")
        #expect(halves?.second == "Para two.")

        let sentence = BoundarySnapping.seamTrimmedHalves("One. Two.", cutAtUTF16: 5)
        #expect(sentence?.first == "One.")
        #expect(sentence?.second == "Two.")
    }

    @Test func seamTrimmingTouchesOnlyTheSeam() {
        let halves = BoundarySnapping.seamTrimmedHalves("  head mid  tail  ", cutAtUTF16: 11)
        #expect(halves?.first == "  head mid")
        #expect(halves?.second == "tail  ")
    }

    @Test func edgeAndUnalignedCutsProduceNoHalves() {
        #expect(BoundarySnapping.seamTrimmedHalves("abc", cutAtUTF16: 0) == nil)
        #expect(BoundarySnapping.seamTrimmedHalves("abc", cutAtUTF16: 3) == nil)
        #expect(BoundarySnapping.seamTrimmedHalves("", cutAtUTF16: 0) == nil)
        #expect(BoundarySnapping.seamTrimmedHalves("Hi 👩‍👩‍👧‍👦. Done.", cutAtUTF16: 4) == nil)
    }

    @Test func aCutInsideEdgeWhitespaceLeavesAnEmptyHalf() {
        // The ops layer must refuse these — documented here, enforced there.
        let halves = BoundarySnapping.seamTrimmedHalves("   Hello", cutAtUTF16: 2)
        #expect(halves?.first == "")
        #expect(halves?.second == "Hello")
    }
}
