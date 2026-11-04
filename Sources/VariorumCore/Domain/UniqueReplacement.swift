import Foundation

/// **ONE PASSAGE, REPLACED WHERE IT STANDS** — VX-761 (the VX-771 run, batch 2;
/// PROVISIONAL P-771-10, QUESTIONS #258's bundle): the rule under `edit_take`'s
/// replace form (`old_str` → `new_str`), run by the operation INSIDE its own
/// transaction over the take's stored text (`Operations.editTakeUnderInsurance`'s
/// `.replacing` arm), so the read, the replacement and the write are one act.
///
/// - **Exactly once.** The passage must occur exactly once in the text; zero or
///   two-or-more occurrences replace nothing and say how many there are, so the
///   caller can name the one place it means.
/// - **Byte for byte.** Matching is over the UTF-8 bytes — never canonical
///   equivalence: a passage is the stored bytes a client read back, and the
///   take's other bytes are kept exactly. Both strings are valid UTF-8, so a match
///   starts on a lead byte and ends where a scalar ends: the splice is valid text.
/// - **Overlaps count.** `"aa"` occurs twice in `"aaa"` (at 0 and 1), so an
///   ambiguous place refuses rather than guessing which one was meant.
/// - **An empty passage matches nowhere** (0) — a caller refuses it before asking.
///
/// Pure and dependency-free; ∝ the text (the take is the edit unit, P1).
public enum UniqueReplacement {
    public enum Outcome: Equatable, Sendable {
        /// The text with its one occurrence replaced.
        case replaced(String)
        /// The passage occurs this many times (0, or 2 or more) — nothing replaced.
        case notUnique(occurrences: Int)
    }

    public static func apply(_ old: String, with new: String, in text: String) -> Outcome {
        let haystack = Array(text.utf8), needle = Array(old.utf8)
        guard !needle.isEmpty, needle.count <= haystack.count else { return .notUnique(occurrences: 0) }
        let starts = occurrences(of: needle, in: haystack)
        guard starts.count == 1, let start = starts.first else { return .notUnique(occurrences: starts.count) }
        let replaced = haystack[..<start] + Array(new.utf8) + haystack[(start + needle.count)...]
        return .replaced(String(decoding: replaced, as: UTF8.self))
    }

    /// Every start offset of `needle` in `haystack`, overlapping ones included
    /// — Knuth–Morris–Pratt, so the cost is linear in the two lengths whatever
    /// the bytes (a naive scan is quadratic on a repetitive take).
    static func occurrences(of needle: [UInt8], in haystack: [UInt8]) -> [Int] {
        var failure = [Int](repeating: 0, count: needle.count)
        var k = 0
        for i in needle.indices.dropFirst() {
            while k > 0, needle[i] != needle[k] { k = failure[k - 1] }
            if needle[i] == needle[k] { k += 1 }
            failure[i] = k
        }
        var starts: [Int] = []
        var matched = 0
        for (i, byte) in haystack.enumerated() {
            while matched > 0, byte != needle[matched] { matched = failure[matched - 1] }
            if byte == needle[matched] { matched += 1 }
            if matched == needle.count {
                starts.append(i - needle.count + 1)
                matched = failure[matched - 1]
            }
        }
        return starts
    }
}
