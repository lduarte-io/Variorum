import Dependencies
import Foundation

/// Fractional-index ordering keys (SyncSpec §8): base-62 strings whose
/// *lexicographic* order is the list order, so SQLite's BINARY collation on a
/// TEXT column sorts them with no help. `between` mints a key strictly between
/// two neighbors in O(key length); depth is unlimited, so **no rebalance
/// operation exists** — REAL midpoints + mass renumber were a sync bomb.
///
/// Every call appends random jitter digits so two offline devices minting
/// between the same neighbors collide with vanishing probability. Randomness
/// flows through `@Dependency(\.withRandomNumberGenerator)` (or an explicit
/// generator) so tests are deterministic.
///
/// A key is a base-62 fraction in (0, 1): `"U"` ≈ 30/62, `"U7"` ≈ 30/62 + 7/62².
/// Keys never end in the minimum digit `'0'` — a trailing `'0'` adds no value
/// but destroys betweenness: no base-62 string sorts strictly between `"a"`
/// and `"a0"`, because every candidate suffix sorts ≥ `"0"`. `between` never
/// generates such a key and rejects one as input.
public enum FractionalIndex {
    /// ASCII-ordered, so byte comparison == digit-value comparison.
    public static let alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

    private static let base = 62
    private static let digitValues: [Character: Int] = Dictionary(
        uniqueKeysWithValues: alphabet.enumerated().map { ($1, $0) })
    private static let digitCharacters = Array(alphabet)

    /// How many random digits each call appends after the deciding digit.
    /// Two digits ≈ 1/(62·61) residual collision odds per identical
    /// deciding digit — vanishing, and three total random digits in the
    /// common case.
    private static let jitterDigits = 2

    // MARK: - API

    /// The key for the first element of an empty list.
    public static func initial() -> String {
        between(nil, nil)
    }

    /// A key strictly between `a` and `b` (nil = open end: `a == nil` means
    /// "before everything", `b == nil` means "after everything").
    /// Requires `a < b` when both are present.
    public static func between(_ a: String?, _ b: String?) -> String {
        @Dependency(\.withRandomNumberGenerator) var withRandomNumberGenerator
        return withRandomNumberGenerator { rng in
            between(a, b, using: &rng)
        }
    }

    /// Core, generator-explicit form (tests pass a seeded generator).
    /// `& Sendable` matches what `WithRandomNumberGenerator` vends.
    public static func between(
        _ a: String?, _ b: String?, using rng: inout any RandomNumberGenerator & Sendable
    ) -> String {
        if let a, let b {
            precondition(a < b, "FractionalIndex.between requires a < b, got \(a) ≥ \(b)")
        }
        let result = midpoint(a.map(digits(of:)) ?? [], b.map(digits(of:)), using: &rng)
        return String(result.map { digitCharacters[$0] })
    }

    // MARK: - Implementation

    private static func digits(of key: String) -> [Int] {
        precondition(!key.isEmpty, "empty string is not a valid fractional-index key")
        let values = key.map { char -> Int in
            guard let value = digitValues[char] else {
                preconditionFailure("non-base-62 character '\(char)' in fractional-index key \(key)")
            }
            return value
        }
        precondition(values.last != 0, "fractional-index key \(key) may not end in '0' (no key can sort between it and its trailing-zero-stripped form)")
        return values
    }

    /// Digit-wise midpoint: walk the keys, copy the shared prefix, and at the
    /// first digit with room emit a random digit in the gap plus jitter.
    /// `upper == nil` means no upper bound (treat as an infinite digit).
    private static func midpoint(
        _ lower: [Int], _ upper: [Int]?, using rng: inout any RandomNumberGenerator & Sendable
    ) -> [Int] {
        var result: [Int] = []
        var lower = lower[...]
        var upper = upper?[...]

        // Shared prefix is copied verbatim; the keys first diverge after it.
        if upper != nil {
            while let lo = lower.first, let hi = upper?.first, lo == hi {
                result.append(lo)
                lower = lower.dropFirst()
                upper = upper?.dropFirst()
            }
        }

        while true {
            let lo = lower.first ?? 0
            let hi = upper?.first ?? base
            if hi - lo > 1 {
                // Room at this digit: pick randomly in the open interval, then
                // jitter. Strictly > lower (digit > lo) and < upper (digit < hi)
                // no matter what follows.
                result.append(Int.random(in: (lo + 1)...(hi - 1), using: &rng))
                for i in 0..<jitterDigits {
                    let isLast = i == jitterDigits - 1
                    result.append(Int.random(in: (isLast ? 1 : 0)..<base, using: &rng))
                }
                return result
            } else if hi == lo + 1 {
                // Adjacent digits: keep the lower digit, discard the upper
                // bound (anything above lower's remainder stays below it),
                // and continue into lower's remainder.
                result.append(lo)
                lower = lower.dropFirst()
                upper = nil
            } else {
                // hi == lo: only when lower is exhausted and upper continues
                // with '0' digits — descend until upper offers room. (upper
                // cannot run out first: that would mean upper ≤ lower.)
                result.append(lo)
                lower = lower.dropFirst()
                upper = upper?.dropFirst()
            }
        }
    }
}
