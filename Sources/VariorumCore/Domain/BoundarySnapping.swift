import Foundation
#if DEBUG
/// **DEBUG-only: how many full-text boundary scans have run ON THIS THREAD**
/// (QoL round 2026-07-29, L1 — her report: *"the take divider isn't working
/// properly — on a long block, i get the spinning rainbow circle"*).
///
/// A scan is O(the take's text) and allocates: `sentenceBoundaries` builds an
/// `Array(text)` plus an offsets array before walking it. The divide
/// ceremony's sheet was running one PER SLOT per body pass, and ~2 per
/// candidate per drag sample, which is the beachball. The bound is pinned by
/// test now.
///
/// **Two design points, both learned by being wrong first.**
///
/// 1. The counter lives HERE, on the scanner, not on an app-side wrapper —
///    the shipped code calls `boundaries` directly, so a wrapper's counter
///    would read zero on the pre-fix code and every bound pin would be hollow.
/// 2. It is THREAD-LOCAL, not global. A global counter was written first and
///    its own instrument pin caught it immediately: suites run in parallel and
///    other tests scan on other threads, so the count was already wrong by 1
///    within three calls. Thread-local also sharpens what the pins can claim —
///    "the render path performs no scans" becomes literally checkable on the
///    thread the render happens on, and work deliberately moved OFF the main
///    thread is visibly not counted there.
///
/// Standing environment law: DEBUG oracles exist only under the configuration
/// named exactly "Debug" — never add a custom one.
public enum BoundaryScanCount {
    private static let key = "io.lduarte.variorum.boundaryScanCount"

    /// Scans on the CALLING thread since its last `reset()`.
    public static var current: Int {
        (Thread.current.threadDictionary[key] as? Int) ?? 0
    }

    public static func reset() {
        Thread.current.threadDictionary[key] = 0
    }

    static func bump() {
        let dictionary = Thread.current.threadDictionary
        dictionary[key] = ((dictionary[key] as? Int) ?? 0) + 1
    }
}
#endif

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
        #if DEBUG
        BoundaryScanCount.bump()
        #endif
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

    // (17f/P45: a plain nearest-boundary `snap(_:in:granularity:)` lived here
    // until the S4-22 cut redesign replaced it with `settle` — and then
    // outlived it by two years' worth of phases with ZERO production callers
    // on either platform, kept green by its own tests alone while `divide`'s
    // op doc still named it as the boundary contract. The two genuinely
    // disagree wherever a strong boundary sits within `settlePull`, so a
    // session reading that doc learned a rule no door enforces. Removed with
    // the doc corrected; `settle` below is the one snap brain.)

    // MARK: - The gentle settle (13b Stage 4, S4-22 ruling 1)

    /// How many UTF-16 units of extra reach a sentence end or newline gets
    /// when a cut settles ("pull a little" — deliberately small: about a
    /// terminator-plus-space's width, so the common landings stay easy).
    ///
    /// **It CAN override an exact placement, in one configuration only**
    /// (18o U1, 17e P34 — this doc used to say an exact placement always
    /// wins): a strong boundary exactly `settlePull` units EARLIER than an
    /// exact word edge also scores zero after the pull, and `settle`'s tie
    /// goes to the earlier position — so a cut placed right after a
    /// one-letter word that opens a sentence or paragraph (". I ", ". A ",
    /// "\nI ") settles back to that sentence's start. A strong boundary
    /// LATER than the exact placement loses the same tie, and one farther
    /// than the pull never reaches it. Documented behaviour (the settle
    /// doing its job), pinned by `BoundarySnappingTests
    /// .aStrongBoundaryExactlySettlePullEarlierTakesAnExactPlacement`; the
    /// exact-wins alternative is QUESTIONS #161, the author's.
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
    ///
    /// **The blank line belongs to the FIRST half (author ruling, 13d
    /// sitting 2026-07-28 — ledger A11).** Her report: dividing on an empty
    /// line put the blank line NOWHERE. The seam run's newlines are not the
    /// separator alone — they are the author's spacing, and the standing
    /// ownership rule (the 2026-07-12 spacing ruling, QUESTIONS #12 option
    /// (a); `SegmentationRules.bulkSegments` / `crystallizedBoundary`) says
    /// where they live: **k newlines between two pieces store k−1 trailing
    /// newlines on the preceding piece**, because the editor's single-`"\n"`
    /// separator re-creates the last. So `"para1\n\npara2"` cut at the blank
    /// yields `("para1\n", "para2")` — the surface reproduces the blank line
    /// byte-for-byte and `renderedText` round-trips it (the conditional join:
    /// a left block already ending in a newline completes with ONE more).
    /// k = 1 (the ordinary paragraph cut) keeps 0 and is byte-unchanged, as
    /// is a seam with no newline at all (a mid-sentence cut).
    ///
    /// ONE rule everywhere: this is the only halving function the divide
    /// doors consult (plain `divide`, `divideW`'s per-take cuts), so the
    /// ceremony inherits it without a second implementation. A first half
    /// that trims to EMPTY gains nothing — an edge run has no preceding
    /// piece to own it (`bulkSegments`' own edge-run rule), and the ops
    /// layer's empty-half refusal must keep refusing exactly what it did.
    public static func seamTrimmedHalves(
        _ text: String, cutAtUTF16 cut: Int
    ) -> (first: String, second: String)? {
        guard cut > 0, cut < text.utf16.count,
              let index = graphemeIndex(atUTF16: cut, in: text)
        else { return nil }
        let head = text[..<index]
        let tail = text[index...]
        let first = trimTrailing(head)
        let second = trimLeading(tail)
        guard !first.isEmpty else { return (first, second) }
        // The seam run is everything both trims dropped, on both sides of
        // the cut — a cut placed before the newlines and one placed after
        // them describe the SAME seam and must own it identically.
        let droppedBefore = head.reversed().prefix { $0.isWhitespace }
        let droppedAfter = tail.prefix { $0.isWhitespace }
        let newlines = droppedBefore.count(where: \.isNewline)
            + droppedAfter.count(where: \.isNewline)
        return (first + String(repeating: "\n", count: max(0, newlines - 1)), second)
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
