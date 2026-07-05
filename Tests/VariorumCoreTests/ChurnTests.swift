import Testing
@testable import VariorumCore

@Suite("Churn math (Phase 2, Step 2)")
struct ChurnTests {
    @Test func fixingATypoInALongPostNeverCrosses() {
        // The anti-reshuffle guarantee: a couple of characters against a
        // 10k-char baseline is noise.
        var accumulator = 0.0
        for _ in 0..<10 {
            let outcome = Churn.accumulate(
                accumulator: accumulator, baselineLength: 10_000, charDelta: 2, threshold: 0.8)
            #expect(!outcome.didCrossThreshold)
            accumulator = outcome.accumulator
        }
        #expect(accumulator == 20)
    }

    @Test func steadyAccumulationCrossesExactlyAtTheThreshold() {
        // baseline 100, threshold 0.8: 79 accumulated chars is under;
        // the 80th crosses (≥, not >).
        let under = Churn.accumulate(
            accumulator: 78, baselineLength: 100, charDelta: 1, threshold: 0.8)
        #expect(!under.didCrossThreshold)
        #expect(under.accumulator == 79)

        let crossing = Churn.accumulate(
            accumulator: 79, baselineLength: 100, charDelta: 1, threshold: 0.8)
        #expect(crossing.didCrossThreshold)
    }

    @Test func deletesWeighTheSameAsInserts() {
        let inserted = Churn.accumulate(
            accumulator: 0, baselineLength: 100, charDelta: 50, threshold: 0.8)
        let deleted = Churn.accumulate(
            accumulator: 0, baselineLength: 100, charDelta: -50, threshold: 0.8)
        #expect(inserted == deleted)
        #expect(inserted.accumulator == 50)
    }

    @Test func emptyPostDoesNotDivideByZero() {
        // baseline 0 → max(baseline, 1): the first real content of an empty
        // post is trivially a major revision.
        let outcome = Churn.accumulate(
            accumulator: 0, baselineLength: 0, charDelta: 5, threshold: 0.8)
        #expect(outcome.didCrossThreshold)
    }

    @Test func crossingResetsTheAccumulator() {
        let outcome = Churn.accumulate(
            accumulator: 90, baselineLength: 100, charDelta: 10, threshold: 0.8)
        #expect(outcome.didCrossThreshold)
        #expect(outcome.accumulator == 0)
    }

    @Test func thresholdIsConfigurable() {
        // The same edit crosses at 0.1 and not at 0.9.
        let loose = Churn.accumulate(
            accumulator: 0, baselineLength: 100, charDelta: 20, threshold: 0.1)
        #expect(loose.didCrossThreshold)

        let strict = Churn.accumulate(
            accumulator: 0, baselineLength: 100, charDelta: 20, threshold: 0.9)
        #expect(!strict.didCrossThreshold)
        #expect(strict.accumulator == 20)
    }

    @Test func zeroDeltaAccumulatesNothing() {
        let outcome = Churn.accumulate(
            accumulator: 5, baselineLength: 100, charDelta: 0, threshold: 0.8)
        #expect(!outcome.didCrossThreshold)
        #expect(outcome.accumulator == 5)
    }
}
