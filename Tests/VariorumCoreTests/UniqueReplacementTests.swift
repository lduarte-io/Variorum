import Foundation
import Testing

@testable import VariorumCore

// VX-761 (the VX-771 run, batch 2 — PROVISIONAL P-771-10): the pure rule under
// edit_take's replace form. Exactly once, byte for byte, overlaps counted.

@Suite("VX-761 — one passage, replaced where it stands (UniqueReplacement)")
struct UniqueReplacementTests {
    @Test func aUniquePassageIsReplacedAndEverythingElseKeptExactly() {
        #expect(UniqueReplacement.apply("second", with: "last", in: "the first, the second, the third")
                == .replaced("the first, the last, the third"))
        #expect(UniqueReplacement.apply("the first, ", with: "", in: "the first, the second")
                == .replaced("the second"), "an empty replacement removes the passage")
        #expect(UniqueReplacement.apply("line.", with: "line.\nAnd more.", in: "Her line.")
                == .replaced("Her line.\nAnd more."))
    }

    @Test func zeroOrSeveralOccurrencesReplaceNothingAndSayHowMany() {
        #expect(UniqueReplacement.apply("fourth", with: "x", in: "first, second") == .notUnique(occurrences: 0))
        #expect(UniqueReplacement.apply("the", with: "a", in: "the cat, the hat, the mat") == .notUnique(occurrences: 3))
        #expect(UniqueReplacement.apply("longer than the text", with: "x", in: "short") == .notUnique(occurrences: 0))
        #expect(UniqueReplacement.apply("", with: "x", in: "anything") == .notUnique(occurrences: 0),
                "an empty passage matches nowhere")
    }

    /// An ambiguous place refuses: "aa" stands twice in "aaa" (at 0 and at 1).
    @Test func overlappingOccurrencesCount() {
        #expect(UniqueReplacement.apply("aa", with: "b", in: "aaa") == .notUnique(occurrences: 2))
        #expect(UniqueReplacement.apply("abab", with: "x", in: "ababab") == .notUnique(occurrences: 2))
        #expect(UniqueReplacement.apply("aab", with: "x", in: "aaab") == .replaced("ax"))
    }

    /// Byte for byte — never canonical equivalence: an NFC passage does not
    /// find an NFD take, and the take's other bytes are kept exactly.
    @Test func matchingIsByteLevelNeverCanonical() {
        let nfd = "Um cafe\u{0301} forte."
        #expect(UniqueReplacement.apply("caf\u{00E9}", with: "ch\u{00E1}", in: nfd) == .notUnique(occurrences: 0))
        guard case .replaced(let text) = UniqueReplacement.apply("forte", with: "fraco", in: nfd) else {
            Issue.record("forte stands once")
            return
        }
        #expect(Array(text.utf8) == Array("Um cafe\u{0301} fraco.".utf8), "the NFD bytes kept exactly")
    }

    /// A match of valid UTF-8 starts on a lead byte and ends where a scalar
    /// ends, so the splice is valid text around emoji and accents alike.
    @Test func theSpliceIsValidTextAroundMultiByteCharacters() {
        #expect(UniqueReplacement.apply("\u{1F30A}", with: "\u{1F33F}", in: "sea \u{1F30A} glass")
                == .replaced("sea \u{1F33F} glass"))
        #expect(UniqueReplacement.apply("\u{00E9}", with: "e", in: "caf\u{00E9}") == .replaced("cafe"))
    }

    /// Linear in the two lengths: a repetitive take and passage stay cheap.
    @Test func aRepetitiveTakeIsLinear() {
        let take = String(repeating: "a", count: 200_000) + "b"
        let passage = String(repeating: "a", count: 50_000) + "b"
        #expect(UniqueReplacement.apply(passage, with: "c", in: take)
                == .replaced(String(repeating: "a", count: 150_000) + "c"))
    }
}
