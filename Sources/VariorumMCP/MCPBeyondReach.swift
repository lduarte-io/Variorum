import Foundation

/// **THE FIXED SCOPE WORDS** (VX-825 — the VX-809 run, batch 1; her ruling
/// R-825, 2026-11-04: "every MCP answer is a PURE FUNCTION OF THE CLIENT'S
/// REACHABLE STATE — nothing on the wire may vary with what the client cannot
/// reach"; PROVISIONAL P-809-1 for the sentence).
///
/// An answer that lists the books an act touched names only the books this
/// client can READ, and says — in ONE fixed sentence, byte-identical whether
/// any book beyond its reach exists or not — that the list is scoped. The
/// counted-not-named class (`still_in_books_hidden_count`, `landed`'s "a book
/// not shared with you", `left_books`' name-less ids) retired with it: a count
/// rides a subject the client knows, so it leaked what the hidden books are
/// about. Honesty by humility: the client never claims totality, so it never
/// reports an act's consequences falsely, and nothing hidden crosses.
///
/// The key is ALWAYS present on the tools that carry it (never conditional —
/// a key that appears only when something is hidden is itself the oracle).
extension MCPWriteTools {
    /// The one key every book-listing answer carries.
    static let beyondReachKey = "beyond_reach"

    /// The one sentence (PROVISIONAL P-809-1 — her sketch, made a sentence).
    static let beyondReachWords = "Books beyond your reach, if any, are not listed."

    /// The same humility for an answer that COUNTS NOTES (VX-812's
    /// `replace_tag` — R-812: hidden wearers "untouched, unmentioned and
    /// uncounted"), under the same always-present key. PROVISIONAL (P-809-1's
    /// family — her sketch's construction, its noun the answer's).
    static let beyondReachNotesWords = "Notes beyond your reach, if any, are not counted."
}
