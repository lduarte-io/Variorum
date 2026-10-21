import Foundation

// VX-309 U2 — VX-211: THE QUIET STRENGTH HINT'S ESTIMATOR (her kickoff ruling, "Floor + quiet hint": the 12-character floor
// stays the ONLY refusal; a set/change passphrase field gains one honest, calm line — an estimator's verdict as advice,
// never a block, never a meter, no colour). Pure; no dependency, no word list, nothing stored or logged — the passphrase is
// read here and nowhere kept. Two shapes earn a word of advice, and only two:
//   - REPETITIVE — fewer than `fewestDistinct` different characters (spaces aside), whatever its length: "aaaaaaaaaaaaaa",
//     "121212121212", "abcabcabcabcabc" are the guesses an offline attacker tries first;
//   - SHORT — fewer than `longEnough` characters: a passphrase at the floor is the one secret a stolen copy of the server (or
//     a stolen key file) is guessed against, and length is what a phrase adds.
// Anything else — a phrase of `longEnough` characters with some variety — earns nothing, and an empty field says nothing.

/// What the field's quiet line advises.
public enum PassphraseAdvice: Equatable, Sendable {
    /// Nothing said.
    case none
    /// Fewer than `PassphraseStrength.longEnough` characters.
    case short
    /// Fewer than `PassphraseStrength.fewestDistinct` different characters.
    case repetitive
}

public enum PassphraseStrength {
    /// A phrase this long (in characters, as the floor counts them) earns no word about its length.
    public static let longEnough = 20
    /// Fewer different characters than this (case folded, spaces aside) is a repetition, whatever the length.
    public static let fewestDistinct = 6

    /// The advice for `passphrase` (pure; repetition outranks length — it is the weaker shape).
    public static func advice(_ passphrase: String) -> PassphraseAdvice {
        guard !passphrase.isEmpty else { return .none }
        let distinct = Set(passphrase.lowercased().filter { !$0.isWhitespace }).count
        if distinct < fewestDistinct { return .repetitive }
        if passphrase.count < longEnough { return .short }
        return .none
    }
}
