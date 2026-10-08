import Foundation

/// **A word that NAMES a tag offers the tag** (VX-84b — the 13o follow-up
/// run; her report: the plain word `exampletag` answered "nothing found"
/// though a note is tagged `exampletag`. The provisional call D-2 in
/// `notes/plans/fixes/vx-83-search-followup.md`: the ranked stream stays
/// text-honest — nothing in the index carries tag paths, by design (a
/// tag-application doc would need a cross-table read in a trigger, the
/// R-13o-4 fence) — and the band OFFERS the tag instead, one press away).
///
/// RATIFIED at the run's sitting (R-VX83-1 — her words: *"i do support
/// needing to say it's a tag explicitly"*; the fold-in alternative is dead):
/// the offer is the explicit act. THE ONE PURE HOME of the offer rule:
///
/// - a typed WORD (or a quoted phrase) offers every live tag of the wing
///   whose LEAF — the path's last segment — it IS;
/// - the type-ahead TAIL (the parser's `.prefix`, already ≥ 2 characters by
///   the parser's own rule) offers every tag whose leaf it BEGINS;
/// - sameness is the index's own (R-13o-11): case AND diacritics folded, so
///   "cafe" offers `#café` exactly as it finds "Café";
/// - a tag the question already TYPES is never offered (it is already
///   asked);
/// - ordered: exact leaves before prefix leaves, then the shallower path,
///   then the path (digit-aware) — at most `limit` offers.
///
/// Pure: the vocabulary comes in (`Queries.searchTagOffers` reads the wing's
/// live tags through the one composer).
public enum SearchTagOffer {
    /// One offer: the tag's stored path, and the word as she typed it that
    /// named it (the field's rewrite replaces exactly that word).
    public struct Offer: Equatable, Sendable {
        public let path: String
        public let word: String
        public init(path: String, word: String) {
            self.path = path
            self.word = word
        }
    }

    /// At most this many offers ride the band (PROVISIONAL P-VX83-6).
    public static let limit = 3

    /// The question's offer words: its positive text leaves, each with
    /// whether it is the still-typed tail (`.prefix`). Negated leaves name
    /// nothing she wants (v1's field cannot type them; the AST can).
    static func words(of text: SearchText?) -> [(word: String, isTail: Bool)] {
        var out: [(String, Bool)] = []
        func walk(_ text: SearchText, negated: Bool) {
            switch text {
            case .all(let children), .any(let children):
                for child in children { walk(child, negated: negated) }
            case .not(let inner):
                walk(inner, negated: !negated)
            case .word(let w), .phrase(let w):
                if !negated { out.append((w, false)) }
            case .prefix(let w):
                if !negated { out.append((w, true)) }
            }
        }
        if let text { walk(text, negated: false) }
        return out
    }

    /// **The decision.** `vocabulary` is the wing's live tag paths.
    public static func offers(for query: SearchQuery, vocabulary: [String]) -> [Offer] {
        let words = words(of: query.text)
        guard !words.isEmpty, !vocabulary.isEmpty else { return [] }
        let typed = Set(SearchTagAssociation.typedPaths(of: query.filter).map(fold))
        var found: [(offer: Offer, exact: Bool, depth: Int)] = []
        var seen: Set<String> = []
        for path in vocabulary {
            let key = fold(path)
            guard !typed.contains(key), !seen.contains(key) else { continue }
            let leaf = fold(String(path.split(separator: "/").last ?? Substring(path)))
            guard !leaf.isEmpty else { continue }
            // The first word that names it (exact before prefix).
            var hit: (word: String, exact: Bool)?
            for (word, isTail) in words {
                let w = fold(word)
                if w == leaf { hit = (word, true); break }
                if isTail, w.count >= 2, leaf.hasPrefix(w), hit == nil { hit = (word, false) }
            }
            guard let hit else { continue }
            seen.insert(key)
            found.append((Offer(path: path, word: hit.word), hit.exact, path.split(separator: "/").count))
        }
        found.sort { a, b in
            if a.exact != b.exact { return a.exact }
            if a.depth != b.depth { return a.depth < b.depth }
            return a.offer.path.localizedStandardCompare(b.offer.path) == .orderedAscending
        }
        return Array(found.prefix(limit).map(\.offer))
    }

    /// The index's own sameness (R-13o-11): case and diacritics folded.
    static func fold(_ s: String) -> String {
        s.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
    }
}
