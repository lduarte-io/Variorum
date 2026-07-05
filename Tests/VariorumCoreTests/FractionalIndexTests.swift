import Dependencies
import Foundation
import Testing
@testable import VariorumCore

@Suite("FractionalIndex (Phase 2, Step 1)")
struct FractionalIndexTests {
    /// Shorthand: run `between` with a seeded generator.
    private func between(_ a: String?, _ b: String?, seed: UInt64) -> String {
        var rng: any RandomNumberGenerator & Sendable = SeededGenerator(seed: seed)
        return FractionalIndex.between(a, b, using: &rng)
    }

    // MARK: Strict betweenness

    @Test func openEnds() {
        let first = between(nil, nil, seed: 1)
        #expect(!first.isEmpty)

        let before = between(nil, first, seed: 2)
        #expect(before < first)

        let after = between(first, nil, seed: 3)
        #expect(first < after)
    }

    @Test func strictlyBetweenManyRandomPairs() {
        var rng: any RandomNumberGenerator & Sendable = SeededGenerator(seed: 42)
        // Grow a sorted key set by bisecting random gaps (including both open
        // ends); every insertion must land strictly inside its gap and the
        // whole set must stay strictly ordered. This exercises shared
        // prefixes, adjacent digits, and multi-digit descent organically.
        var keys = [FractionalIndex.between(nil, nil, using: &rng)]
        for _ in 0..<500 {
            let gap = Int.random(in: 0...keys.count, using: &rng)
            let lower = gap == 0 ? nil : keys[gap - 1]
            let upper = gap == keys.count ? nil : keys[gap]
            let minted = FractionalIndex.between(lower, upper, using: &rng)
            if let lower { #expect(lower < minted) }
            if let upper { #expect(minted < upper) }
            keys.insert(minted, at: gap)
        }
        #expect(keys == keys.sorted())
        #expect(Set(keys).count == keys.count)
    }

    @Test func repeatedBisectionNeverExhausts() {
        var rng: any RandomNumberGenerator & Sendable = SeededGenerator(seed: 7)
        // Always split the same (shrinking) gap — the worst case that
        // bankrupted REAL midpoints after ~50 splits. Strings grow instead.
        var lower = FractionalIndex.between(nil, nil, using: &rng)
        var upper = FractionalIndex.between(lower, nil, using: &rng)
        for i in 0..<250 {
            let mid = FractionalIndex.between(lower, upper, using: &rng)
            #expect(lower < mid && mid < upper, "exhausted at depth \(i)")
            if i.isMultiple(of: 2) { lower = mid } else { upper = mid }
        }
    }

    @Test func degenerateAdjacentKeysStillBisect() {
        // "a" and "a1" differ only by the smallest possible tail — the minted
        // key must extend "a0…" and stay below "a1".
        let mid = between("a", "a1", seed: 5)
        #expect("a" < mid && mid < "a1")
        #expect(mid.hasPrefix("a0"))

        // Adjacent single digits: nothing fits between 'V' and 'W' at depth
        // one, so the key must descend.
        let mid2 = between("V", "W", seed: 6)
        #expect("V" < mid2 && mid2 < "W")

        // Upper key descending through minimum digits below an empty lower.
        let mid3 = between(nil, "001", seed: 8)
        #expect(mid3 < "001")
    }

    // MARK: Key hygiene

    @Test func outputAlphabetIsBase62Only() {
        var rng: any RandomNumberGenerator & Sendable = SeededGenerator(seed: 9)
        let allowed = Set(FractionalIndex.alphabet)
        var previous: String? = nil
        for _ in 0..<200 {
            let key = FractionalIndex.between(previous, nil, using: &rng)
            #expect(key.allSatisfy { allowed.contains($0) })
            previous = key
        }
    }

    @Test func keysNeverEndInMinimumDigit() {
        // A trailing '0' would make the key un-bisectable from below
        // (nothing sorts between "a" and "a0") — banned by construction.
        var rng: any RandomNumberGenerator & Sendable = SeededGenerator(seed: 10)
        var keys = [FractionalIndex.between(nil, nil, using: &rng)]
        for _ in 0..<300 {
            let gap = Int.random(in: 0...keys.count, using: &rng)
            let minted = FractionalIndex.between(
                gap == 0 ? nil : keys[gap - 1],
                gap == keys.count ? nil : keys[gap],
                using: &rng)
            #expect(minted.last != "0")
            keys.insert(minted, at: gap)
        }
    }

    // MARK: Jitter

    @Test func sameNeighborsDifferentSeedsMintDifferentKeys() {
        // The offline-collision scenario: two devices insert between the same
        // neighbors. Jitter makes the keys differ.
        let a = between("G", "p", seed: 100)
        let b = between("G", "p", seed: 200)
        #expect(a != b)
        #expect("G" < a && a < "p")
        #expect("G" < b && b < "p")
    }

    @Test func dependencyPathIsDeterministicUnderSeededGenerator() {
        // The convenience overload routes through
        // @Dependency(\.withRandomNumberGenerator).
        let first = withDependencies {
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 42))
        } operation: {
            FractionalIndex.initial()
        }
        let second = withDependencies {
            $0.withRandomNumberGenerator = WithRandomNumberGenerator(SeededGenerator(seed: 42))
        } operation: {
            FractionalIndex.initial()
        }
        #expect(first == second)
        #expect(!first.isEmpty)
    }
}
