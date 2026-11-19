import Foundation

/// **THE TRASH'S OWN MATCH — "does this text hold these words?"** (VX-93, the
/// vx-980 run's batch 3; her rulings R-980-9 · R-980-10 · R-980-11, verbatim in
/// `notes/plans/fixes/vx-980-her-rulings.md`).
///
/// Her words at the VX-83 sitting set the shape: *"it might be better to just
/// add a search to trash later than add trash to the main search."* So this is
/// a search INSIDE the Trash and nothing of the finder's: no index exists over
/// deleted things (the index drops every tombstoned doc), so there are no
/// tokens here — the match is a plain text match over the text the Trash
/// already holds.
///
/// **The rule (R-980-10, "the simple match"):**
/// - **Words.** Whitespace separates words; nothing else is grammar — a `#`, a
///   quote, a dash or a `+` is a character like any other (the full grammar is
///   VX-1010, parked at her word).
/// - **Every word** must be found (the finder's implicit AND), each in the
///   row's name or in any one of its texts.
/// - **A contained run of characters**, so a partial word matches (`gard`
///   finds `garden`) and punctuation and symbols match as the characters they
///   are (`1 + 1` finds `1 + 1`; a straight `'` does not find a curly `’`).
/// - **Case and accents fold** — the finder's third sameness rule (R-13o-11),
///   in the app's own Swift statement of it: `SearchTagOffer.fold`'s options,
///   `[.caseInsensitive, .diacriticInsensitive]`, locale-free. The decision and
///   the passage's place are ONE primitive (Foundation's search under those
///   options), so a row is never listed for a word whose place cannot be found.
///
/// **The passage (R-980-11, "one passage line"):** the words around the first
/// occurrence, in the row's texts, of a typed word the row does not already
/// show — so she can see why it is listed — one line, whitespace collapsed,
/// an ellipsis where it is cut. A row whose shown text holds every word carries
/// none.
///
/// Pure and `Sendable`: it runs inside the Trash's read, on a reader, off the
/// main thread (P2). Its cost is ∝ the texts it is handed — the Trash's own
/// rows, never the living corpus (P1; the read that hands them over is
/// `Queries.trashSearch`).
public enum TrashTextMatch {
    /// The sameness the match folds by — the tag offer's (`SearchTagOffer.fold`),
    /// which is the app's Swift statement of the index's own (R-13o-11).
    public static let sameness: String.CompareOptions = [.caseInsensitive, .diacriticInsensitive]

    /// The sameness as a fold — what two texts equal under it reduce to. The
    /// match itself never builds a folded copy (Foundation's search folds as it
    /// goes, under the same options); this is the pins' handle on the rule
    /// (`TrashTextMatchTests` — its agreement with the tag offer's fold, and
    /// with the linked index's tokenizer, scalar by scalar).
    static func fold(_ text: String) -> String {
        text.folding(options: sameness, locale: nil)
    }

    /// **The field's words.** Whitespace (spaces, tabs, newlines — every
    /// `Character.isWhitespace`) separates; every other character belongs to a
    /// word. Duplicates collapse (asking `red red` asks `red`), first spelling
    /// kept, in the order typed. A field of only whitespace asks nothing.
    public static func words(_ field: String) -> [String] {
        var seen: Set<String> = []
        var out: [String] = []
        for piece in field.split(whereSeparator: \.isWhitespace) {
            let word = String(piece)
            if seen.insert(word).inserted { out.append(word) }
        }
        return out
    }

    /// Where `word` first occurs in `text`, folded — nil when it does not.
    public static func firstRange(of word: String, in text: String) -> Range<String.Index>? {
        guard !word.isEmpty, !text.isEmpty else { return nil }
        return text.range(of: word, options: sameness, range: nil, locale: nil)
    }

    /// Does `text` hold `word` as a contained run, folded?
    public static func holds(_ text: String, _ word: String) -> Bool {
        firstRange(of: word, in: text) != nil
    }

    /// **Does a row match?** Every word is found in at least one of `texts`
    /// (the row's name and its deleted texts, each searched on its own — a word
    /// never spans two takes). No words matches nothing: an empty question is
    /// no search, and the caller lists the Trash as it stands.
    public static func matchesEvery(_ words: [String], in texts: [String]) -> Bool {
        guard !words.isEmpty else { return false }
        return words.allSatisfy { word in texts.contains { holds($0, word) } }
    }

    /// **The one passage line, or nil** (R-980-11). `shown` is what the row
    /// already shows (its name, or its first line); `texts` are its deleted
    /// texts in reading order. The passage is cut around the FIRST occurrence —
    /// earliest text first, earliest place within it — of any word `shown` does
    /// not hold. Nil when `shown` holds every word (the row explains itself) or
    /// when no such word occurs in `texts` (nothing more to say).
    public static func passage(
        words: [String], shown: String, texts: [String],
        lead: Int = Passage.lead, tail: Int = Passage.tail
    ) -> String? {
        let unexplained = words.filter { !holds(shown, $0) }
        guard !unexplained.isEmpty else { return nil }
        for text in texts {
            var first: Range<String.Index>?
            for word in unexplained {
                guard let range = firstRange(of: word, in: text) else { continue }
                if let current = first {
                    if range.lowerBound < current.lowerBound
                        || (range.lowerBound == current.lowerBound
                            && range.upperBound > current.upperBound)
                    {
                        first = range
                    }
                } else {
                    first = range
                }
            }
            if let first { return excerpt(text, around: first, lead: lead, tail: tail) }
        }
        return nil
    }

    /// The passage's measures, in characters: how much of the text before the
    /// match it keeps (a few words, so the match sits near the line's start and
    /// survives the row's tail truncation) and how much after.
    public enum Passage {
        public static let lead = 32
        public static let tail = 96
        public static let ellipsis = "\u{2026}"
    }

    /// **The words around `match`, as one line.** Up to `lead` characters before
    /// and `tail` after, each cut moved to a word's edge (never mid-word: a cut
    /// inside a word drops the partial word, unless that would drop everything
    /// on its side); whitespace runs (newlines included) collapse to one space;
    /// an ellipsis stands where the text was cut, none where the passage reaches
    /// the text's own start or end. The match itself is never cut.
    public static func excerpt(
        _ text: String, around match: Range<String.Index>,
        lead: Int = Passage.lead, tail: Int = Passage.tail
    ) -> String {
        var start = text.index(match.lowerBound, offsetBy: -max(lead, 0), limitedBy: text.startIndex)
            ?? text.startIndex
        var end = text.index(match.upperBound, offsetBy: max(tail, 0), limitedBy: text.endIndex)
            ?? text.endIndex
        // A cut inside a word moves to that word's edge, away from the match —
        // unless the side holds nothing but that one word, which is kept whole
        // rather than leaving the side empty.
        if start > text.startIndex, start < match.lowerBound,
           !text[text.index(before: start)].isWhitespace, !text[start].isWhitespace,
           let gap = text[start..<match.lowerBound].firstIndex(where: \.isWhitespace)
        {
            start = gap
        }
        if end < text.endIndex, end > match.upperBound,
           !text[end].isWhitespace, !text[text.index(before: end)].isWhitespace,
           let gap = text[match.upperBound..<end].lastIndex(where: \.isWhitespace)
        {
            end = gap
        }
        let cutBefore = !text[text.startIndex..<start].allSatisfy(\.isWhitespace)
        let cutAfter = !text[end..<text.endIndex].allSatisfy(\.isWhitespace)
        let body = collapsingWhitespace(text[start..<end])
        return (cutBefore ? Passage.ellipsis : "") + body + (cutAfter ? Passage.ellipsis : "")
    }

    /// Every whitespace run as one space, the ends trimmed.
    static func collapsingWhitespace(_ text: Substring) -> String {
        text.split(whereSeparator: \.isWhitespace).joined(separator: " ")
    }
}
