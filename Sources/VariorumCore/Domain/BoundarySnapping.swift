import Foundation

/// Boundary detection and cutting for the structural operations (AppSpec §9,
/// OverallModel §7) — pure functions over one variant's text, no GRDB.
///
/// **Offset convention: UTF-16 code units.** TextKit 2 reports ranges as
/// `NSRange` (UTF-16), so the editor (Phases 7/9) hands offsets straight to
/// these functions and to the operations layer without translation. Every
/// offset is validated to land on a grapheme-cluster boundary — a cut can
/// never split an emoji, a flag, or a combining sequence; an unaligned offset
/// is answered with `nil`, never a guess.
///
/// **Where a boundary sits:** at the START of the following unit — after the
/// separator run, not before it. The raw first half of a boundary cut
/// therefore carries the seam whitespace, and `seamTrimmedHalves` drops it:
/// separators are re-created by the rendering join, never stored (the
/// SegmentationRules doctrine). `0` and the text's end are always boundaries;
/// internal boundaries require content on both sides.
///
/// Sentence detection mirrors `SegmentationRules`' coarse scanner exactly
/// (terminator run + trailing closers + whitespace; a newline always ends a
/// sentence): deliberately not smarter — coarse, not forensic.
///
/// **The word rule (13b Stage 4, the ruled cut redesign — S4-22):** cuts may
/// land between ANY two words and at newlines. `.word` granularity is the
/// legal-cut set (a superset of `.sentence`, which supersets `.paragraph`),
/// and `settle(_:in:among:)` is the one snap brain: word edges are free,
/// sentence ends and newlines pull a little (GENTLE SETTLE — ruling 1). The
/// word-edge floor (ruling 3) holds by construction: candidates only ever
/// sit at word starts, so a cut can never land mid-word, and a one-word
/// half stays legal.
public enum BoundarySnapping {
    public enum Granularity: Sendable {
        case sentence, paragraph
        /// Every legal cut under the ruled rule: word starts (after any
        /// whitespace run), which subsume sentence and paragraph starts.
        case word
    }

    /// How an extract span sits against its text: a prefix (leading span,
    /// source keeps the tail) or a suffix (trailing span, source keeps the
    /// head). Middle spans are not extractable — that's a divide.
    public enum ExtractableSpan: Equatable, Sendable {
        case prefix, suffix
    }

    // MARK: - Boundaries

    /// All valid cut offsets (UTF-16) for a granularity, ascending. Always
    /// contains 0 and the end; each granularity is a superset of the one
    /// below it: word ⊇ sentence ⊇ paragraph (a paragraph break also ends a
    /// sentence; a sentence or paragraph start is always a word start). The
    /// unions are kept explicit so the containment holds by construction,
    /// never by hoping the scanners agree.
    public static func boundaries(in text: String, granularity: Granularity) -> [Int] {
        var set: Set<Int> = [0, text.utf16.count]
        set.formUnion(paragraphBoundaries(in: text))
        if granularity == .sentence || granularity == .word {
            set.formUnion(sentenceBoundaries(in: text))
        }
        if granularity == .word {
            set.formUnion(wordBoundaries(in: text))
        }
        return set.sorted()
    }

    /// The nearest boundary to `cut` (clamped into the text); a distance tie
    /// snaps to the earlier boundary.
    public static func snap(_ cut: Int, in text: String, granularity: Granularity) -> Int {
        let clamped = min(max(cut, 0), text.utf16.count)
        let candidates = boundaries(in: text, granularity: granularity)
        return candidates.min { a, b in
            let (da, db) = (abs(a - clamped), abs(b - clamped))
            return da == db ? a < b : da < db
        } ?? clamped
    }

    // MARK: - The gentle settle (13b Stage 4, S4-22 ruling 1)

    /// How many UTF-16 units of extra reach a sentence end or newline gets
    /// when a cut settles ("pull a little" — deliberately small: about a
    /// terminator-plus-space's width, so the common landings stay easy
    /// without ever overriding a deliberate exact placement, which always
    /// wins at distance zero).
    public static let settlePull = 2

    /// The ruled snap: the nearest of `candidates` wins, except that a
    /// STRONG candidate (a sentence/paragraph boundary of `text`, or either
    /// text edge) may catch the cut from up to `settlePull` units further
    /// away than a plain word edge. Distance ties — after the pull — go to
    /// the earlier position (the standing convention). `candidates` is any
    /// subset of the word-rule set (callers filter the interior for divide,
    /// keep the ends for parking/spans); empty candidates answer `nil`.
    public static func settle(_ cut: Int, in text: String, among candidates: [Int]) -> Int? {
        guard !candidates.isEmpty else { return nil }
        let clamped = min(max(cut, 0), text.utf16.count)
        let strong = Set(boundaries(in: text, granularity: .sentence))
        func effectiveDistance(_ candidate: Int) -> Int {
            let raw = abs(candidate - clamped)
            return strong.contains(candidate) ? max(0, raw - settlePull) : raw
        }
        return candidates.min { a, b in
            let (da, db) = (effectiveDistance(a), effectiveDistance(b))
            return da == db ? a < b : da < db
        }
    }

    // MARK: - Extract classification

    /// Classifies a span for extract: `.prefix`/`.suffix` when it is
    /// boundary-adjacent (whitespace between the span and the text's edge is
    /// tolerated), `nil` for a middle span (that's a divide), an offset that
    /// splits a grapheme, a blank span, or a span that leaves no content
    /// behind (extracting everything is not an extract — the source must
    /// survive).
    public static func extractableSpan(_ range: Range<Int>, in text: String) -> ExtractableSpan? {
        guard !range.isEmpty, let indices = graphemeRange(range, in: text) else { return nil }
        guard text[indices].contains(where: { !$0.isWhitespace }) else { return nil }
        let headBlank = text[..<indices.lowerBound].allSatisfy(\.isWhitespace)
        let tailBlank = text[indices.upperBound...].allSatisfy(\.isWhitespace)
        switch (headBlank, tailBlank) {
        case (true, false): return .prefix
        case (false, true): return .suffix
        // (true, true) is the whole text; (false, false) is a middle span.
        default: return nil
        }
    }

    // MARK: - Cutting

    /// The two halves of a boundary cut, whitespace trimmed at the seam only
    /// (outer edges untouched). `nil` when the cut is out of bounds, at an
    /// edge, or splits a grapheme. Either half may come back empty (the text
    /// around the cut was all whitespace) — the operations layer refuses
    /// those cuts.
    public static func seamTrimmedHalves(
        _ text: String, cutAtUTF16 cut: Int
    ) -> (first: String, second: String)? {
        guard cut > 0, cut < text.utf16.count,
              let index = graphemeIndex(atUTF16: cut, in: text)
        else { return nil }
        return (trimTrailing(text[..<index]), trimLeading(text[index...]))
    }

    // MARK: - UTF-16 ↔ String.Index (the one unit-conversion door)

    /// The `String.Index` for a UTF-16 offset, when that offset is a
    /// grapheme-cluster boundary of `text`; `nil` otherwise.
    public static func graphemeIndex(atUTF16 offset: Int, in text: String) -> String.Index? {
        guard offset >= 0, offset <= text.utf16.count else { return nil }
        var utf16Offset = 0
        var index = text.startIndex
        while utf16Offset < offset, index < text.endIndex {
            utf16Offset += text[index].utf16Width
            index = text.index(after: index)
        }
        return utf16Offset == offset ? index : nil
    }

    /// Both ends of a UTF-16 range as grapheme-aligned indices, or `nil`.
    public static func graphemeRange(_ range: Range<Int>, in text: String) -> Range<String.Index>? {
        guard let lower = graphemeIndex(atUTF16: range.lowerBound, in: text),
              let upper = graphemeIndex(atUTF16: range.upperBound, in: text)
        else { return nil }
        return lower..<upper
    }

    // MARK: - Seam trimming

    /// Full trim, both edges — extract's span text uses this so span and
    /// remainder trim by one implementation.
    static func trimmed(_ text: Substring) -> String {
        trimTrailing(Substring(trimLeading(text)))
    }

    static func trimTrailing(_ text: Substring) -> String {
        var text = text
        while let last = text.last, last.isWhitespace { text.removeLast() }
        return String(text)
    }

    static func trimLeading(_ text: Substring) -> String {
        var text = text
        while let first = text.first, first.isWhitespace { text.removeFirst() }
        return String(text)
    }

    // MARK: - Scanners

    /// Offsets where a paragraph starts after a separator run (a maximal
    /// whitespace run containing at least one newline) with content before it.
    private static func paragraphBoundaries(in text: String) -> [Int] {
        var result: [Int] = []
        var offset = 0
        var inSeparatorRun = false
        var seenContent = false
        for char in text {
            if char.isWhitespace {
                inSeparatorRun = inSeparatorRun || char.isNewline
            } else {
                if inSeparatorRun, seenContent { result.append(offset) }
                inSeparatorRun = false
                seenContent = true
            }
            offset += char.utf16Width
        }
        return result
    }

    /// Offsets where a word starts after ANY whitespace run with content
    /// before it — the ruled cut rule's grid (S4-22). The paragraph scanner
    /// generalized: the separator run no longer needs a newline. Offsets
    /// accumulate per grapheme cluster, so every boundary is grapheme-
    /// aligned by construction (the word-edge floor can never split an
    /// emoji any more than it splits a word).
    private static func wordBoundaries(in text: String) -> [Int] {
        var result: [Int] = []
        var offset = 0
        var inSeparatorRun = false
        var seenContent = false
        for char in text {
            if char.isWhitespace {
                inSeparatorRun = true
            } else {
                if inSeparatorRun, seenContent { result.append(offset) }
                inSeparatorRun = false
                seenContent = true
            }
            offset += char.utf16Width
        }
        return result
    }

    /// The sentence-mark vocabulary is `SegmentationRules`' — shared, not
    /// mirrored, so the two scanners cannot drift apart.
    private static let terminators = SegmentationRules.terminators
    private static let closers = SegmentationRules.closers

    /// Offsets where a sentence starts: after a terminator run (plus trailing
    /// closers) followed by whitespace, skipping that whitespace. Newline-only
    /// sentence ends are the paragraph scanner's — callers union the two.
    private static func sentenceBoundaries(in text: String) -> [Int] {
        var result: [Int] = []
        let characters = Array(text)
        var offsets: [Int] = [0]
        offsets.reserveCapacity(characters.count + 1)
        for char in characters { offsets.append(offsets[offsets.count - 1] + char.utf16Width) }

        var index = 0
        while index < characters.count {
            guard terminators.contains(characters[index]) else {
                index += 1
                continue
            }
            var lookahead = index + 1
            while lookahead < characters.count,
                  terminators.contains(characters[lookahead]) || closers.contains(characters[lookahead]) {
                lookahead += 1
            }
            if lookahead < characters.count, characters[lookahead].isWhitespace {
                var next = lookahead
                while next < characters.count, characters[next].isWhitespace { next += 1 }
                if next < characters.count { result.append(offsets[next]) }
            }
            index = lookahead
        }
        return result
    }
}

extension Character {
    /// This character's width in UTF-16 code units.
    var utf16Width: Int {
        unicodeScalars.reduce(0) { $0 + UTF16.width($1) }
    }
}
