//
//  PassphraseStrengthTests.swift
//  VariorumCoreTests — VX-309 U2 piece 6: VX-211's estimator, exact (her "Floor + quiet hint": advice, never a block).
//

import Foundation
import Testing

@testable import VariorumCore

@Suite("VX-309 U2 — VX-211: the passphrase strength estimator (pure)")
struct PassphraseStrengthTests {
    @Test func anEmptyFieldSaysNothing() {
        #expect(PassphraseStrength.advice("") == .none)
    }

    /// Length: under twenty characters is short — at the floor (12) and just below twenty alike; twenty is long enough.
    @Test func lengthIsWhatAPhraseAdds() {
        #expect(PassphraseStrength.advice("Tr0ub4dor&3x") == .short, "the floor's length")
        #expect(PassphraseStrength.advice("correct horse batt") == .short, "18")
        #expect(PassphraseStrength.advice("correct horse batter") == .none, "20 — long enough")
        #expect(PassphraseStrength.advice("the lamp by the north window") == .none)
        #expect(PassphraseStrength.longEnough == 20)
    }

    /// Repetition outranks length: too few different characters is the first guess, however long.
    @Test func repetitionOutranksLength() {
        #expect(PassphraseStrength.advice("aaaaaaaaaaaaaaaaaaaaaaaa") == .repetitive)
        #expect(PassphraseStrength.advice("121212121212121212121212") == .repetitive)
        #expect(PassphraseStrength.advice("abcabc abcabc abcabc abcabc") == .repetitive, "spaces aside")
        #expect(PassphraseStrength.advice("AbCdEaBcDe") == .repetitive, "case folded — five different")
        #expect(PassphraseStrength.advice("abcdef") == .short, "six different — not repetitive, but short")
        #expect(PassphraseStrength.fewestDistinct == 6)
    }

    /// Grapheme clusters, as the floor counts them (`String.count`).
    @Test func charactersAreCountedAsTheFloorCountsThem() {
        let accented = String(repeating: "é", count: 10) + "abcdefghij"
        #expect(accented.count == 20)
        #expect(PassphraseStrength.advice(accented) == .none)
    }
}
