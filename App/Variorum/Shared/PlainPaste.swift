//
//  PlainPaste.swift
//  Variorum — SHARED (both platforms)
//
//  **13u2 item 11 — "paste without newlines".** Her ask, verbatim (the
//  master plan's `### 13u` item 11): *"i want a way to paste without new
//  lines (some kind of command shift v or command option v or whatever isn't
//  taken, but it's a quality of life issue)."*
//
//  The master plan states the model angle and this file is the whole of it:
//  **a PASTE-TIME TRANSFORM on the text, never a change to segmentation.**
//  Stripping the newlines before the text reaches the editor means bulk
//  entry has nothing to split on, so the paste lands as ONE paragraph
//  through the machinery that already exists — `SegmentationRules` is not
//  touched, and nothing about how ordinary pastes segment changes.
//
//  **ONE RULE FOR BOTH PLATFORMS** (the master plan's platform call: *"the
//  phone's equivalent is a long-press/edit-menu item, not a chord, but the
//  RULE (what 'paste without newlines' does to a multi-paragraph clipboard)
//  should be one rule"*). It lives here, in `Shared/`, so the Mac's chord
//  and the phone's menu item consume the same function — the forked-brains
//  rule applied before the fork can happen.
//

import Foundation

nonisolated enum PlainPaste {
    /// The rule, stated so a reader never has to infer it from the code:
    ///
    /// 1. `\r\n` and a bare `\r` normalize to `\n` first — a clipboard from
    ///    Windows or a classic-Mac-era file is the same text, and a rule
    ///    that only knew `\n` would leave those line breaks standing.
    /// 2. The text splits on `\n`. Pieces that are entirely whitespace are
    ///    DROPPED — a blank line between paragraphs is a separator, not a
    ///    word, and keeping it would put two spaces in the joined line.
    /// 3. The join is exactly ONE SPACE: the left piece's trailing
    ///    horizontal whitespace and the right piece's leading horizontal
    ///    whitespace are trimmed at the seam, so a clipboard whose lines
    ///    already end in a space does not land a double one.
    /// 4. **The FIRST piece keeps its leading whitespace and the LAST keeps
    ///    its trailing whitespace.** What she copied at the EDGES is hers —
    ///    an indented first line stays indented, and a trailing space she
    ///    copied deliberately survives. (This is item 2's own doctrine, one
    ///    door over: the app does not tidy her whitespace for her.)
    /// 5. Text with no line break passes through BYTE-IDENTICAL, so the
    ///    chord over an ordinary clipboard is exactly an ordinary paste.
    ///
    /// Newlines → a single space is the natural reading of "without new
    /// lines"; joining with NOTHING would run the last word of one line into
    /// the first of the next, and keeping a blank line as a paragraph break
    /// would not be "without new lines" at all. Recorded as a PROVISIONAL
    /// (QUESTIONS #112(c)) because "what it does to a multi-paragraph
    /// clipboard" is a product call the plan's rulings do not make.
    static func flattened(_ text: String) -> String {
        let normalized = text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
        guard normalized.contains("\n") else { return text }

        let pieces = normalized.split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)
        // Rule 2: whitespace-only pieces are separators, not words.
        let kept = pieces.filter { !$0.allSatisfy(\.isWhitespace) }
        // Every line was blank: there is no word to join, so the clipboard
        // passes through as it came rather than becoming an invented space.
        guard !kept.isEmpty else { return text }

        var out = ""
        for (position, entry) in kept.enumerated() {
            var piece = entry
            // Rule 3 + rule 4: trim only at the SEAMS, never at the edges.
            if position > 0 { piece = String(piece.drop(while: isHorizontal)) }
            if position < kept.count - 1 {
                while let last = piece.last, isHorizontal(last) { piece.removeLast() }
            }
            if position > 0 { out += " " }
            out += piece
        }
        return out
    }

    private static func isHorizontal(_ character: Character) -> Bool {
        character != "\n"
            && character.unicodeScalars.allSatisfy(CharacterSet.whitespaces.contains)
    }
}
