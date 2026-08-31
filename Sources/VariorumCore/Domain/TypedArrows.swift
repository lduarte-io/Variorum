//
//  TypedArrows.swift
//  VariorumCore
//
//  pre-13u Act 10 wave 1, item 12 (ruled) — **typed-arrow substitution**:
//  `->` becomes → and `<-` becomes ← as you type.
//
//  ── THE RULED CONSTRAINTS ────────────────────────────────────────────────
//  · A pure TYPE-TIME text transform: the substitution is content-level —
//    the arrow is stored and rendered as itself (markdown-as-content is
//    untouched as a doctrine; nothing here is display-time).
//  · NEVER inside a code span — arrows are syntax there. The shipped
//    markdown vocabulary (F-3, `MarkdownSyntax`) has inline code only —
//    fenced code blocks are not a concept the app has — so the code-span
//    guard is the whole code guard.
//  · Ordinary text undo reverts it (the smart-quotes convention): the FACE
//    applies this as its own undo step, so ⌘Z restores the typed `->`.
//  · ONE brain, shareable with the phone: this file is pure and platform-
//    free; each platform's face extracts the caret's line and applies the
//    returned edit through its ordinary input path.
//
//  ── SCOPE DISCIPLINE (P1) ────────────────────────────────────────────────
//  The brain scans exactly ONE line (the caret's), so a keystroke's cost is
//  proportional to the line, never the document — the `MarkdownActs`
//  line-extraction idiom (`checkboxToggleEdit`'s shape).
//
//  ── DELIBERATE NON-MATCHES (recorded, not accidental) ────────────────────
//  · `-->` does not substitute (the pair is preceded by another `-`: a
//    longer dash-run is its own idiom, and `-→` would be worse than
//    leaving it alone). `<<-` mirrors.
//  · Up/down arrows are NOT built — her word: wanted, typed form undecided.
//    Candidates are PROPOSED in the wave record only.
//

public enum TypedArrows {
    /// One substitution, in UTF-16 offsets **within the scanned line**.
    public struct Substitution: Equatable, Sendable {
        /// The two typed characters to replace (`->` or `<-`).
        public let range: Range<Int>
        /// The arrow ("→" or "←").
        public let replacement: String

        public init(range: Range<Int>, replacement: String) {
            self.range = range
            self.replacement = replacement
        }
    }

    /// The substitution a just-landed keystroke earns, or nil.
    ///
    /// - Parameters:
    ///   - line: the caret's whole line (no trailing newline required; one
    ///     is tolerated — spans never match across it).
    ///   - caret: the insertion point's UTF-16 offset WITHIN the line,
    ///     immediately AFTER the typed character.
    public static func substitution(line: String, caret: Int) -> Substitution? {
        let units = Array(line.utf16)
        guard caret >= 2, caret <= units.count else { return nil }

        let dash: UInt16 = 0x2D  // -
        let gt: UInt16 = 0x3E    // >
        let lt: UInt16 = 0x3C    // <

        let first = units[caret - 2]
        let second = units[caret - 1]
        let replacement: String
        if first == dash, second == gt {
            // `-->` (and any longer dash run) stays literal.
            if caret >= 3, units[caret - 3] == dash { return nil }
            replacement = "\u{2192}"  // →
        } else if first == lt, second == dash {
            // `<<-` stays literal, mirroring the dash-run rule.
            if caret >= 3, units[caret - 3] == lt { return nil }
            replacement = "\u{2190}"  // ←
        } else {
            return nil
        }

        // Never inside a code span (arrows are syntax there). The pair is
        // "inside" when any part of it overlaps a code span's range —
        // markers included, so `` `a->` `` refuses even at the closing tick.
        let pair = (caret - 2)..<caret
        for span in MarkdownSyntax.spans(in: line) {
            if case .code = span.kind, span.range.overlaps(pair) { return nil }
        }

        return Substitution(range: pair, replacement: replacement)
    }
}
