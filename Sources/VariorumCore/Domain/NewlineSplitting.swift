import Foundation

/// **Where a block's text breaks into paragraphs** — the pure brain behind
/// `Operations.splitBlockAtNewlines`, her ruling **U-6** (2026-09-06, the
/// use-report round): *"a 'make all newlines blocks' button… that
/// automatically just leaves any take at the top paragraph of its block."*
/// Her reason: a note written with the newlines chip OFF is one block per
/// several paragraphs, and repairing it by hand *"[was] a lot of divides to
/// run."*
///
/// This function answers only the *where*: given one take's stored text, the
/// separator runs that become block boundaries. It never cuts and never
/// trims — the ONE cut brain (`BoundarySnapping.seamTrimmedHalves`, which
/// every divide door consults) owns both, so this repair produces exactly
/// what dividing by hand at each of those seams would produce, byte for byte.
/// Two behaviors for one gesture is the confusion class S4-22 closed.
///
/// **The rule.** A break sits between two consecutive CONTENT lines (a line
/// that is not all-whitespace), **except** when the two lines are adjacent —
/// exactly one newline between them — and BOTH read as list leads
/// (`MarkdownSyntax.isListLead`, the K8 law's own predicate). That exception
/// is her U-19 (4), confirmed at the third message: *"lists stay whole under
/// 'make every newline a block' — confirmed."* It is PROVISIONAL in the
/// design's own words and carries `notes/QUESTIONS.md` #93.
///
/// Consequences worth stating, each pinned:
///
/// - **A blank line is always a break**, list or not: the exception is
///   "exactly one newline", and a blank line inside a list is two. A blank
///   line is how a paragraph ends everywhere else in this app.
/// - **Leading and trailing blank lines are not breaks** — there is no piece
///   on one side of them (`SegmentationRules.bulkSegments`' own edge-run
///   rule).
/// - **A break's own bytes are the separator run** and the cut may be placed
///   anywhere in it: `seamTrimmedHalves` counts the newlines on BOTH sides of
///   the cut, so before, inside and after describe the same seam. The
///   operation cuts at the run's start.
/// - **The k−1 spacing rule rides for free** (her A11 ruling, 13d): a run of
///   k newlines leaves k−1 on the preceding half as content and the editor's
///   separator re-creates the last, so `"one\n\ntwo"` becomes the blocks
///   `"one\n"` and `"two"` and the page reads byte-identically. Nothing she
///   typed disappears — U-19 (2)'s standing instruction.
public enum NewlineSplitting {
    /// The separator runs, ascending, that `splitBlockAtNewlines` cuts at.
    /// Offsets are UTF-16 (the app's one offset unit); each range spans from
    /// the end of the preceding content line to the start of the following
    /// one, so it carries the whole run — newlines and any blank lines
    /// between them. Empty when the text is already one paragraph, which is
    /// the operation's own no-op condition.
    public static func breaks(in text: String) -> [Range<Int>] {
        var result: [Range<Int>] = []
        var previous: LineSpan?
        for line in lineSpans(of: text) where !isBlank(line.text) {
            defer { previous = line }
            guard let prior = previous else { continue }
            // Adjacent = exactly one newline between them (no blank line was
            // skipped, since `where` only ever lets content lines through).
            let adjacent = prior.index + 1 == line.index
            if adjacent,
               MarkdownSyntax.isListLead(prior.text),
               MarkdownSyntax.isListLead(line.text) {
                continue  // U-19 (4): lists stay whole
            }
            result.append(prior.range.upperBound..<line.range.lowerBound)
        }
        return result
    }

    // MARK: - Lines

    private struct LineSpan {
        let index: Int
        /// The line's own UTF-16 span, terminator excluded.
        let range: Range<Int>
        let text: String
    }

    /// One pass, UTF-16 offsets carried along — never `String.Index`
    /// distance arithmetic per line (that is O(n²) on a long block, and P1
    /// binds a repair that runs over every block of a note).
    private static func lineSpans(of text: String) -> [LineSpan] {
        var spans: [LineSpan] = []
        var start = 0
        var offset = 0
        var current = ""
        for character in text {
            if character == "\n" {
                spans.append(LineSpan(index: spans.count, range: start..<offset, text: current))
                offset += 1
                start = offset
                current = ""
            } else {
                offset += character.utf16Width
                current.append(character)
            }
        }
        spans.append(LineSpan(index: spans.count, range: start..<offset, text: current))
        return spans
    }

    private static func isBlank(_ text: String) -> Bool {
        text.allSatisfy(\.isWhitespace)
    }
}
