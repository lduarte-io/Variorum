import Foundation

/// **THE v1 GRAMMAR** (Phase 13o, R-13o-8) — what she types into the one
/// finder, read into a `SearchQuery`. Deliberately small; the power grammar
/// (boolean words, `in:`/`not in:`, word counts — VX-73) is a later parser
/// over the same AST, never a second query shape.
///
/// - **words** — whitespace-separated; every word must match (implicit AND).
/// - **"a phrase"** — double quotes (straight or curly) keep the words
///   together and in order; an unterminated quote runs to the end.
/// - **`#tag/path`** — a tag FILTER (subtree), never text. A lone `#` is a
///   word.
/// - **the type-ahead tail** — while typing (`typeAhead`, the default), the
///   LAST bare word, when the text does not end in whitespace and the word is
///   at least two characters, matches as a PREFIX (`trav` finds "travel").
///   One character is never a prefix (it would be most of the corpus — the
///   P1 bench's measurement); it stays an exact word.
/// - **the worn day** — when the text, tags aside, IS a day
///   (`SearchDateParse`), the query also carries it as `wornDay`; the words
///   still search as words.
///
/// Facets, day RANGES and scopes are faces (chips, the day picker, where the
/// field sits) that build the filter half directly — they have no typed
/// syntax in v1.
public enum SearchQueryParser {
    public static func parse(
        _ input: String,
        typeAhead: Bool = true,
        visibility: SearchVisibility = .living,
        locale: Locale = .current,
        calendar: Calendar = JournalDay.storeCalendar
    ) -> SearchQuery {
        var terms: [SearchText] = []
        var tags: [SearchFilter] = []
        var freeWords: [String] = []          // the text the worn-day reader sees
        // The last bare word and where it ENDS in the input: the type-ahead
        // tail is the word STILL BEING TYPED, which means it must end the
        // input (ladder round 1, MINOR-2 — a `#tag`, the dropped `#/`
        // included, typed after a word means that word is finished; the old
        // last-character check read the TAG's final character and widened
        // the finished word to a prefix).
        var lastBareWord: (index: Int, end: String.Index)?

        var index = input.startIndex
        while index < input.endIndex {
            let ch = input[index]
            if ch.isWhitespace {
                index = input.index(after: index)
                continue
            }
            if isQuote(ch) {
                // A phrase: up to the next quote, or the end.
                var end = input.index(after: index)
                while end < input.endIndex, !isQuote(input[end]) { end = input.index(after: end) }
                let body = String(input[input.index(after: index)..<end])
                    .split(whereSeparator: \.isWhitespace).joined(separator: " ")
                if !body.isEmpty {
                    terms.append(.phrase(body))
                    freeWords.append(body)
                }
                index = end < input.endIndex ? input.index(after: end) : end
                continue
            }
            // A bare token: up to whitespace or a quote.
            var end = index
            while end < input.endIndex, !input[end].isWhitespace, !isQuote(input[end]) {
                end = input.index(after: end)
            }
            let token = String(input[index..<end])
            if token.hasPrefix("#"), token.count > 1 {
                var path = String(token.dropFirst())
                while path.hasSuffix("/") { path.removeLast() }
                if !path.isEmpty { tags.append(.tagPath(path)) }
            } else {
                terms.append(.word(token))
                freeWords.append(token)
                lastBareWord = (terms.count - 1, end)
            }
            index = end
        }

        // The type-ahead tail: the last bare word, still being typed — so it
        // must END the input (nothing follows it, not even whitespace).
        if typeAhead, let last = lastBareWord, last.end == input.endIndex,
           last.index == terms.count - 1,
           case .word(let word) = terms[last.index], word.count >= 2 {
            terms[last.index] = .prefix(word)
        }

        let text: SearchText? = switch terms.count {
        case 0: nil
        case 1: terms[0]
        default: .all(terms)
        }
        let filter: SearchFilter? = switch tags.count {
        case 0: nil
        case 1: tags[0]
        default: .all(tags)
        }
        let wornDay = freeWords.isEmpty ? nil
            : SearchDateParse.parse(freeWords.joined(separator: " "), locale: locale, calendar: calendar)
        return SearchQuery(text: text, filter: filter, wornDay: wornDay, visibility: visibility)
    }

    private static func isQuote(_ ch: Character) -> Bool {
        ch == "\"" || ch == "\u{201C}" || ch == "\u{201D}"
    }
}
