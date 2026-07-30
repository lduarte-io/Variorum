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

    // MARK: Boundaries — word granularity (13b Stage 4, the ruled cut rule)

    @Test func wordBoundariesSitAtEveryWordStart() {
        // "One two three": word starts at 4 and 8, plus the standing 0/end.
        #expect(BoundarySnapping.boundaries(in: "One two three", granularity: .word)
            == [0, 4, 8, 13])
    }

    @Test func multiSpaceRunsYieldOneBoundaryAtTheNextWord() {
        // The run is the separator; the boundary is the following word's
        // start (the standing after-the-separator convention).
        #expect(BoundarySnapping.boundaries(in: "One   two", granularity: .word)
            == [0, 6, 9])
    }

    @Test func newlinesAreWordBoundariesToo() {
        // The outline case (the addendum's driver): no terminators at all,
        // every line start is a legal cut.
        #expect(BoundarySnapping.boundaries(in: "point one\npoint two", granularity: .word)
            == [0, 6, 10, 16, 19])
    }

    @Test func wordGranularityIsASupersetOfSentenceGranularity() {
        let fixtures = [
            "One. Two! Three?",
            "Para one.\n\nPara two.\nPara three.",
            #"He said "Stop!" and left. Really?! Fine."#,
            "No terminator\nNext line.",
            "Hi 👩‍👩‍👧‍👦. Done.",
            "", "   ", "single",
        ]
        for text in fixtures {
            let word = Set(BoundarySnapping.boundaries(in: text, granularity: .word))
            let sentence = Set(BoundarySnapping.boundaries(in: text, granularity: .sentence))
            #expect(word.isSuperset(of: sentence), "not a superset for \(text)")
        }
    }

    @Test func edgeWhitespaceProducesNoInternalWordBoundaries() {
        // No content before the leading run / after the trailing run — a
        // one-word text has NO interior cut (the word-edge floor's other
        // face: nothing to divide).
        #expect(BoundarySnapping.boundaries(in: "  hello  ", granularity: .word)
            == [0, 9])
        #expect(BoundarySnapping.boundaries(in: "hello", granularity: .word)
            == [0, 5])
        #expect(BoundarySnapping.boundaries(in: "", granularity: .word) == [0])
    }

    @Test func wordBoundariesAreGraphemeAligned() {
        // Each emoji cluster is one "word"; boundaries sit at cluster
        // starts, never inside surrogate pairs or ZWJ sequences.
        let text = "Hi 👩‍👩‍👧‍👦 done"
        #expect(BoundarySnapping.boundaries(in: text, granularity: .word)
            == [0, 3, 15, 19])
        for boundary in BoundarySnapping.boundaries(in: text, granularity: .word) {
            #expect(BoundarySnapping.graphemeIndex(atUTF16: boundary, in: text) != nil)
        }
    }

    // MARK: The gentle settle (S4-22 ruling 1)

    @Test func settlePicksTheNearestWordEdgeWhenNoStrongBoundaryIsNear() {
        // "alpha beta gamma delta": word edges 6, 11, 17 — none strong
        // (no terminators, no newlines). Plain nearest wins.
        let text = "alpha beta gamma delta"
        let interior = [6, 11, 17]
        #expect(BoundarySnapping.settle(8, in: text, among: interior) == 6)
        #expect(BoundarySnapping.settle(10, in: text, among: interior) == 11)
        #expect(BoundarySnapping.settle(16, in: text, among: interior) == 17)
    }

    @Test func sentenceEndsPullALittle() {
        // "One. Two three": word edges 5 (strong — sentence start) and 9
        // (plain). Cut 7 is equidistant-raw (2/2): the pull decides for 5.
        // Cut 8 is raw 3-vs-1 for 9; the pull (3−2=1 vs 1) TIES effective
        // distance and the earlier boundary wins — still 5. Cut 9 is exact:
        // the deliberate placement always wins.
        let text = "One. Two three"
        let interior = [5, 9]
        #expect(BoundarySnapping.settle(7, in: text, among: interior) == 5)
        #expect(BoundarySnapping.settle(8, in: text, among: interior) == 5)
        #expect(BoundarySnapping.settle(9, in: text, among: interior) == 9)
    }

    @Test func newlinesPullLikeSentenceEnds() {
        // "one\ntwo three": 4 is a paragraph (⊂ sentence) boundary, 8 plain.
        let text = "one\ntwo three"
        let interior = [4, 8]
        #expect(BoundarySnapping.settle(6, in: text, among: interior) == 4)
        #expect(BoundarySnapping.settle(8, in: text, among: interior) == 8)
    }

    @Test func settleRespectsTheCandidateSubset() {
        // Callers filter (interior-only for divide; ends kept for parking):
        // the settle never answers outside what it was given.
        let text = "One. Two three"
        #expect(BoundarySnapping.settle(1, in: text, among: [5, 9]) == 5)
        #expect(BoundarySnapping.settle(0, in: text, among: [0, 5, 9, 14]) == 0)
        #expect(BoundarySnapping.settle(13, in: text, among: [0, 5, 9, 14]) == 14)
        #expect(BoundarySnapping.settle(7, in: text, among: []) == nil)
    }

    @Test func settleClampsOutOfRangeCuts() {
        let text = "One. Two three"
        #expect(BoundarySnapping.settle(-9, in: text, among: [5, 9]) == 5)
        #expect(BoundarySnapping.settle(99, in: text, among: [5, 9]) == 9)
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

    /// 13d batch 5 (A11 — a RULED FLIP, not a bug fix): the seam's newlines
    /// are the author's spacing, and the standing k−1 ownership rule gives
    /// them to the FIRST half. `"Para one.\n\nPara two."` is k = 2, so one
    /// newline stays behind — and the editor's single-`"\n"` separator
    /// re-creates the other, which is why her blank line survives the cut.
    @Test func seamTrimmingGivesTheBlankLineToTheFirstHalf() {
        let halves = BoundarySnapping.seamTrimmedHalves("Para one.\n\nPara two.", cutAtUTF16: 11)
        #expect(halves?.first == "Para one.\n")
        #expect(halves?.second == "Para two.")

        // k = 1 (the ordinary paragraph cut) keeps NOTHING — byte-unchanged
        // from the pre-ruling behaviour, because the separator is the whole
        // of that seam.
        let single = BoundarySnapping.seamTrimmedHalves("Para one.\nPara two.", cutAtUTF16: 10)
        #expect(single?.first == "Para one.")
        #expect(single?.second == "Para two.")

        // k = 3 → two stay; k = 0 (a mid-sentence cut) → nothing changes.
        let triple = BoundarySnapping.seamTrimmedHalves("A\n\n\nB", cutAtUTF16: 4)
        #expect(triple?.first == "A\n\n")
        #expect(triple?.second == "B")

        let sentence = BoundarySnapping.seamTrimmedHalves("One. Two.", cutAtUTF16: 5)
        #expect(sentence?.first == "One.")
        #expect(sentence?.second == "Two.")
    }

    /// The seam is what BOTH trims drop, so a cut placed before the newlines
    /// and one placed after them describe the same seam and own it the same
    /// way — otherwise "where exactly you clicked in the blank line" would
    /// change what the halves hold.
    @Test func theSeamRunIsOwnedTheSameFromEitherSideOfTheCut() {
        for cut in [9, 10, 11] {  // before the run, inside it, after it
            let halves = BoundarySnapping.seamTrimmedHalves(
                "Para one.\n\nPara two.", cutAtUTF16: cut)
            #expect(halves?.first == "Para one.\n")
            #expect(halves?.second == "Para two.")
        }
        // Mixed whitespace normalizes to pure newlines, exactly as
        // `bulkSegments` normalizes a blank line carrying stray spaces.
        let mixed = BoundarySnapping.seamTrimmedHalves("A \n \n B", cutAtUTF16: 6)
        #expect(mixed?.first == "A\n")
        #expect(mixed?.second == "B")
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

        // A11's cannot-widen edge: an EMPTY first half gains no newline, so
        // a cut the ops layer refuses today still trims to nothing and is
        // still refused. An edge run has no preceding piece to own it —
        // `bulkSegments`' own rule.
        let leadingRun = BoundarySnapping.seamTrimmedHalves("\n\nHello", cutAtUTF16: 2)
        #expect(leadingRun?.first == "")
        #expect(leadingRun?.second == "Hello")
    }
}

#if DEBUG
/// **The INSTRUMENT'S OWN PIN** (QoL round 2026-07-29, L1). The ceremony's
/// scan bound is asserted with `BoundaryScanCount`, so a green bound pin could
/// just as easily mean the counter is broken. This is what makes the other
/// pins mean something.
@Suite("BoundaryScanCount — the L1 bound's instrument", .serialized)
struct BoundaryScanCountTests {
    /// Thread-local by design: a GLOBAL counter was written first and this
    /// very pin caught it — suites run in parallel, so other tests' scans on
    /// other threads had already miscounted it by one within three calls.
    @Test func theCounterCountsEveryScanAndResets() {
        BoundaryScanCount.reset()
        #expect(BoundaryScanCount.current == 0)
        _ = BoundarySnapping.boundaries(in: "One. Two three.", granularity: .word)
        #expect(BoundaryScanCount.current == 1)
        _ = BoundarySnapping.boundaries(in: "One. Two three.", granularity: .sentence)
        _ = BoundarySnapping.boundaries(in: "", granularity: .paragraph)
        #expect(BoundaryScanCount.current == 3, "every granularity is a full walk")
        BoundaryScanCount.reset()
        #expect(BoundaryScanCount.current == 0)
    }

    /// `settle` scans too (it needs the strong set) — stated, because the
    /// ceremony's own budget has to account for the snapping it does at open.
    @Test func settlingAlsoCostsAScan() {
        let text = "One. Two three."
        let interior = BoundarySnapping.boundaries(in: text, granularity: .word)
            .filter { $0 != 0 && $0 != text.utf16.count }
        BoundaryScanCount.reset()
        _ = BoundarySnapping.settle(5, in: text, among: interior)
        #expect(BoundaryScanCount.current == 1)
    }
}
#endif
