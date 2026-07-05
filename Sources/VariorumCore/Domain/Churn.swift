import Foundation

/// The "80%-edited" sort math (AppSpec §10): a post accumulates churn — chars
/// inserted + chars deleted, equal weight — against a baseline length. When
/// `churn / max(baseline, 1) ≥ threshold`, the edit is a *major revision*:
/// the caller stamps `last_major_revision_at`, resets the accumulator, and
/// rebaselines to the post's current rendered length. Fixing one typo must
/// never reshuffle the library; rewriting most of a post must.
///
/// Pure math only. Reading the `major_revision_threshold` setting, stamping,
/// and rebaselining are the operations layer's job.
public enum Churn {
    public struct Outcome: Equatable, Sendable {
        /// The accumulator to persist: grown by the edit, or reset to 0 when
        /// the edit crossed the threshold.
        public let accumulator: Double
        /// Crossed ⇒ the caller stamps `last_major_revision_at` and
        /// rebaselines `baseline_length` to the current rendered length.
        public let didCrossThreshold: Bool

        public init(accumulator: Double, didCrossThreshold: Bool) {
            self.accumulator = accumulator
            self.didCrossThreshold = didCrossThreshold
        }
    }

    /// Folds one edit into the accumulator. `charDelta` is the edit's signed
    /// character delta; inserts and deletes weigh equally, so only the
    /// magnitude counts (a replacement should be reported as its full
    /// insert + delete cost by the editor, not a net).
    public static func accumulate(
        accumulator: Double,
        baselineLength: Int,
        charDelta: Int,
        threshold: Double
    ) -> Outcome {
        let grown = accumulator + Double(abs(charDelta))
        // max(baseline, 1): an empty post must not divide by zero — its first
        // real content is trivially a major revision.
        let crossed = grown / Double(max(baselineLength, 1)) >= threshold
        return Outcome(accumulator: crossed ? 0 : grown, didCrossThreshold: crossed)
    }
}
