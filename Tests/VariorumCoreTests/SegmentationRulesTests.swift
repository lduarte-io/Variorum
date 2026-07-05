import Testing
@testable import VariorumCore

@Suite("Segmentation rules (Phase 2, Step 3)")
struct SegmentationRulesTests {
    // MARK: Bulk entry

    @Test func oneBlockPassesTextThroughVerbatim() {
        let text = "First paragraph.\n\nSecond paragraph.\nThird."
        #expect(SegmentationRules.bulkSegments(text, mode: .oneBlock) == [text])
    }

    @Test func paragraphModeSplitsOnNewlineRuns() {
        let text = "First paragraph.\nSecond paragraph.\n\n\nThird."
        #expect(SegmentationRules.bulkSegments(text, mode: .paragraph) == [
            "First paragraph.", "Second paragraph.", "Third.",
        ])
    }

    @Test func paragraphModeTrimsAndDropsBlankSegments() {
        let text = "  Leading spaces kept off.  \n   \n\nReal content.\n"
        #expect(SegmentationRules.bulkSegments(text, mode: .paragraph) == [
            "Leading spaces kept off.", "Real content.",
        ])
    }

    @Test func sentenceModeSplitsOnTerminators() {
        let text = "One sentence. Another one! A third? Yes."
        #expect(SegmentationRules.bulkSegments(text, mode: .sentence) == [
            "One sentence.", "Another one!", "A third?", "Yes.",
        ])
    }

    @Test func sentenceModeKeepsTerminatorRunsAndClosersWithTheSentence() {
        let text = "He said \"Stop!\" and left. Really?! Fine (sort of.) Then quiet."
        #expect(SegmentationRules.bulkSegments(text, mode: .sentence) == [
            "He said \"Stop!\"", "and left.", "Really?!", "Fine (sort of.)", "Then quiet.",
        ])
    }

    @Test func sentenceModeDoesNotSplitInsideNumbers() {
        let text = "Pi is 3.14 roughly. True."
        #expect(SegmentationRules.bulkSegments(text, mode: .sentence) == [
            "Pi is 3.14 roughly.", "True.",
        ])
    }

    @Test func sentenceModeNewlineAlwaysEndsASentence() {
        let text = "No terminator here\nNext line."
        #expect(SegmentationRules.bulkSegments(text, mode: .sentence) == [
            "No terminator here", "Next line.",
        ])
    }

    @Test func emptyAndWhitespaceOnlyInputYieldNoBlocks() {
        for mode in [Segmentation.oneBlock, .paragraph, .sentence] {
            #expect(SegmentationRules.bulkSegments("", mode: mode) == [])
            #expect(SegmentationRules.bulkSegments("   \n\n  \t", mode: mode) == [])
        }
    }

    // MARK: Type-time crystallization

    @Test func openTailWithNoNewlineHasNoBoundary() {
        #expect(SegmentationRules.crystallizedBoundary(openTail: "still typing this paragra") == nil)
    }

    @Test func typingPastAParagraphCrystallizesIt() {
        let result = SegmentationRules.crystallizedBoundary(
            openTail: "A finished paragraph.\nAnd now typing the nex")
        #expect(result == .init(
            blockText: "A finished paragraph.",
            remainingTail: "And now typing the nex"))
    }

    @Test func trailingNewlineCompletesTheParagraphWithEmptyTail() {
        let result = SegmentationRules.crystallizedBoundary(openTail: "A finished paragraph.\n")
        #expect(result == .init(blockText: "A finished paragraph.", remainingTail: ""))
    }

    @Test func blankLinesAloneNeverCrystallize() {
        #expect(SegmentationRules.crystallizedBoundary(openTail: "\n\n   \n") == nil)
    }

    @Test func leadingBlankLinesAreSkippedNotMinted() {
        let result = SegmentationRules.crystallizedBoundary(
            openTail: "\n\nReal paragraph.\nstill typ")
        #expect(result == .init(blockText: "Real paragraph.", remainingTail: "still typ"))
    }

    @Test func remainingTailIsAnExactSuffixSoCallersCanLoop() {
        // Two completed paragraphs in one tail: the first call reports the
        // first; looping on remainingTail reports the second; then nil.
        let first = SegmentationRules.crystallizedBoundary(
            openTail: "Alpha.\nBeta.\nGamma still goi")
        #expect(first == .init(blockText: "Alpha.", remainingTail: "Beta.\nGamma still goi"))
        #expect("Alpha.\nBeta.\nGamma still goi".hasSuffix(first!.remainingTail))

        let second = SegmentationRules.crystallizedBoundary(openTail: first!.remainingTail)
        #expect(second == .init(blockText: "Beta.", remainingTail: "Gamma still goi"))

        #expect(SegmentationRules.crystallizedBoundary(openTail: second!.remainingTail) == nil)
    }

    @Test func crystallizationTrimsTheMintedTextButPreservesTheTailVerbatim() {
        let result = SegmentationRules.crystallizedBoundary(
            openTail: "  Padded paragraph.  \n  next with leading spaces")
        #expect(result == .init(
            blockText: "Padded paragraph.",
            remainingTail: "  next with leading spaces"))
    }
}
