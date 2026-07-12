import Testing
@testable import VariorumCore

@Suite("Segmentation rules (Phase 2, Step 3)")
struct SegmentationRulesTests {
    // MARK: Bulk entry

    @Test func oneBlockPassesTextThroughVerbatim() {
        let text = "First paragraph.\n\nSecond paragraph.\nThird."
        #expect(SegmentationRules.bulkSegments(text, mode: .oneBlock) == [text])
    }

    @Test func paragraphModeSplitsOnNewlineRunsPreservingSpacing() {
        // Author ruling 2026-07-12 (QUESTIONS #12, option (a)): the run
        // BETWEEN pieces becomes trailing content on the preceding piece —
        // k newlines store k−1; the editor separator re-creates the last.
        let text = "First paragraph.\nSecond paragraph.\n\n\nThird."
        #expect(SegmentationRules.bulkSegments(text, mode: .paragraph) == [
            "First paragraph.", "Second paragraph.\n\n", "Third.",
        ])
    }

    @Test func paragraphModeTrimsPiecesAndPreservesBetweenSpacing() {
        // Horizontal whitespace still trims off piece edges; the blank-line
        // run between the pieces (2 blank lines ⇒ k=3 ⇒ 2 trailing
        // newlines) persists; the trailing edge run still drops.
        let text = "  Leading spaces kept off.  \n   \n\nReal content.\n"
        #expect(SegmentationRules.bulkSegments(text, mode: .paragraph) == [
            "Leading spaces kept off.\n\n", "Real content.",
        ])
    }

    @Test func bulkSpacingRoundTripsThroughTheEditorSeparator() {
        // The ruling's surface promise: segments joined by the editor's
        // single-"\n" separator reproduce the paste EXACTLY (unspaced text
        // segments identically to the pre-ruling behavior).
        for paste in [
            "A\nB", "A\n\nB", "A\n\n\nB",
            "One.\n\nTwo.\n\n\n\nThree.",
        ] {
            let blocks = SegmentationRules.bulkSegments(paste, mode: .paragraph)
            #expect(blocks.joined(separator: "\n") == paste,
                    "surface must reproduce the paste: \(paste.debugDescription)")
        }
        // Edge runs drop (no adjacent piece to separate) — as before.
        #expect(SegmentationRules.bulkSegments("\n\nA\n\n", mode: .paragraph) == ["A"])
    }

    @Test func sentenceModePreservesBetweenLineSpacingToo() {
        // The run attaches to the LAST sentence before it; intra-line
        // sentence splits keep today's behavior (space separators drop).
        let text = "One. Two.\n\nThree."
        #expect(SegmentationRules.bulkSegments(text, mode: .sentence) == [
            "One.", "Two.\n", "Three.",
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

    @Test func aTrailingNewlineAloneNoLongerCompletesTheParagraph() {
        // Author ruling 2026-07-12 (the newline-ENTRY half): a paragraph
        // completes when the NEXT non-blank segment exists — until then
        // the trailing newline run is still growing (its width is what the
        // spacing ruling preserves). Durability rides the idle-mint (2 s)
        // and teardown backstops, unchanged.
        #expect(SegmentationRules.crystallizedBoundary(openTail: "A finished paragraph.\n") == nil)
        #expect(SegmentationRules.crystallizedBoundary(openTail: "A finished paragraph.\n\n") == nil)
    }

    @Test func typedBlankLinesPersistAsTrailingContent() {
        // "A ⏎ ⏎ B" — the run completes when B begins: k=2 newlines
        // between the pieces ⇒ "A" keeps 1 trailing newline; the editor
        // separator re-creates the other, so the surface stays exactly
        // what was typed.
        let result = SegmentationRules.crystallizedBoundary(openTail: "A\n\nB")
        #expect(result == .init(blockText: "A\n", remainingTail: "B"))
        // Excision arithmetic: blockText + one separator is the exact
        // consumed prefix.
        #expect("A\n\nB".hasSuffix(result!.remainingTail))

        // Three newlines ⇒ two trailing; still an exact suffix.
        let wide = SegmentationRules.crystallizedBoundary(openTail: "A\n\n\nB still typ")
        #expect(wide == .init(blockText: "A\n\n", remainingTail: "B still typ"))
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
