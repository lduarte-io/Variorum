import Foundation

/// Fresh-text segmentation rules (AppSpec §7 segmentation note; author
/// decision 2026-07-04). Two entry points:
///
/// - `bulkSegments` — bulk entry (paste, import, pool-drop, mobile capture)
///   segments on entry, by the effective mode.
/// - `crystallizedBoundary` — type-time crystallization: while typing brand-new
///   text at the end of a post, each completed paragraph becomes a block as
///   you type past it; the trailing paragraph still being typed is an *open
///   tail*, not yet a block.
///
/// Crystallization only ever sees text that has not yet become a block, so I4
/// (newlines inside an existing block are content, never structure) holds by
/// construction. The editor (Phases 7/9) owns *when* to call these; Phase 2
/// proves the rules.
///
/// The spec defines crystallization in terms of completed *paragraphs*
/// specifically, so `crystallizedBoundary` takes no mode: `one_block` posts
/// simply never call it, and how sentence mode interacts with live typing is
/// an editor-phase question (flagged at Phase 2 closeout, not invented here).
public enum SegmentationRules {
    /// One crystallization step: the completed paragraph to mint as a block,
    /// and the still-open remainder of the tail.
    public struct Crystallization: Equatable, Sendable {
        /// Trimmed text of the completed paragraph — the new block's text.
        public let blockText: String
        /// The suffix of the open tail after the paragraph's terminating
        /// newline; still not a block. May itself contain further completed
        /// paragraphs — callers loop until `nil`.
        public let remainingTail: String

        public init(blockText: String, remainingTail: String) {
            self.blockText = blockText
            self.remainingTail = remainingTail
        }
    }

    // MARK: - Bulk entry

    /// Splits bulk-entered text into block texts. Whitespace-only segments
    /// never become blocks on their own; `one_block` passes the text
    /// through verbatim.
    ///
    /// **Spacing preservation (author ruling 2026-07-12, QUESTIONS #12,
    /// option (a)):** the newline run BETWEEN pieces becomes block CONTENT —
    /// k newlines between two pieces store k−1 trailing newlines on the
    /// preceding piece, and the editor's single-`"\n"` separator re-creates
    /// the last, so the surface reproduces the paste exactly. Newlines are
    /// content (I4); this stores the ones the author pasted, nothing
    /// invented. Edge runs (leading/trailing whitespace-only lines of the
    /// whole text) drop as before — there is no adjacent piece for them to
    /// separate. Unspaced text segments identically to the pre-ruling
    /// behavior.
    public static func bulkSegments(_ text: String, mode: Segmentation) -> [String] {
        guard !isBlank(text) else { return [] }
        switch mode {
        case .oneBlock:
            return [text]
        case .paragraph, .sentence:
            var blocks: [String] = []
            var blankRun = 0
            for line in text.split(separator: "\n", omittingEmptySubsequences: false) {
                if isBlank(String(line)) {
                    // A blank line counts only between pieces (a leading
                    // run has no preceding piece; a trailing run never
                    // meets a following one).
                    if !blocks.isEmpty { blankRun += 1 }
                    continue
                }
                if blankRun > 0, !blocks.isEmpty {
                    // k newlines between the pieces = blankRun + 1; the
                    // preceding piece keeps k−1 = blankRun as content.
                    blocks[blocks.count - 1] += String(repeating: "\n", count: blankRun)
                }
                blankRun = 0
                switch mode {
                case .sentence:
                    blocks.append(contentsOf: sentences(in: String(line)))
                default:
                    let trimmed = line.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty { blocks.append(trimmed) }
                }
            }
            return blocks
        }
    }

    // MARK: - Type-time crystallization

    /// Reports the first completed paragraph in the open tail, if any.
    ///
    /// **Timing (author ruling 2026-07-12, the newline-ENTRY half of
    /// QUESTIONS #12):** a paragraph completes when the NEXT non-blank
    /// segment exists — you have "typed past" it when the next paragraph
    /// begins, not at its own terminating newline. Until then the trailing
    /// newline run is still growing, and its width is what the spacing
    /// ruling preserves: k newlines between the pieces → the completed
    /// paragraph carries k−1 trailing newlines as content (the editor
    /// separator re-creates the last), so typed blank lines persist
    /// exactly like pasted ones. Durability is unchanged — the idle-mint
    /// (2 s) and teardown backstops mint pending text regardless.
    /// `remainingTail` is always an exact suffix of `openTail`, so the
    /// editor can excise the consumed prefix without guessing; a leading
    /// blank run before the first piece is consumed with it (as before).
    public static func crystallizedBoundary(openTail: String) -> Crystallization? {
        let segments = openTail.split(separator: "\n", omittingEmptySubsequences: false)
        guard segments.count > 1 else { return nil }
        // The candidate: the first non-blank segment (never the last — the
        // last is the paragraph still being typed).
        guard let first = segments.dropLast().enumerated()
            .first(where: { !isBlank(String($0.element)) })?.offset
        else { return nil }
        // Completion: a LATER non-blank segment exists (it may be the
        // still-being-typed last one — its existence fixes the run width).
        guard let next = segments.indices.dropFirst(first + 1)
            .first(where: { !isBlank(String(segments[$0])) })
        else { return nil }
        let trailingRun = next - first - 1  // blank segments between = k−1 newlines
        return Crystallization(
            blockText: segments[first].trimmingCharacters(in: .whitespaces)
                + String(repeating: "\n", count: trailingRun),
            remainingTail: segments[next...].joined(separator: "\n"))
    }

    // MARK: - Sentence scanning

    /// Characters that end a sentence. Internal: `BoundarySnapping` shares
    /// these exact sets so the two scanners can never drift apart.
    static let terminators: Set<Character> = [".", "!", "?"]
    /// Closing punctuation that may trail a terminator and still belong to
    /// the sentence: `He said "Stop!" and left.`
    static let closers: Set<Character> = ["\"", "'", "\u{201D}", "\u{2019}", ")", "]"]

    /// Coarse sentence splitting: a terminator run (plus trailing closers)
    /// followed by whitespace ends a sentence; a newline always does.
    /// Deliberately not smarter (abbreviations, initials): the floor is a
    /// sentence and the system is coarse, not forensic — the author can merge.
    private static func sentences(in text: String) -> [String] {
        var results: [String] = []
        var current = ""
        var characters = Array(text)
        var index = 0
        while index < characters.count {
            let char = characters[index]
            if char == "\n" {
                flush(&current, into: &results)
                index += 1
                continue
            }
            current.append(char)
            if terminators.contains(char) {
                // Absorb further terminators ("?!", "...") and closing quotes.
                var lookahead = index + 1
                while lookahead < characters.count,
                      terminators.contains(characters[lookahead]) || closers.contains(characters[lookahead]) {
                    current.append(characters[lookahead])
                    lookahead += 1
                }
                if lookahead >= characters.count || characters[lookahead].isWhitespace {
                    flush(&current, into: &results)
                }
                index = lookahead
                continue
            }
            index += 1
        }
        flush(&current, into: &results)
        return results
    }

    private static func flush(_ current: inout String, into results: inout [String]) {
        let trimmed = current.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { results.append(trimmed) }
        current = ""
    }

    private static func isBlank(_ text: String) -> Bool {
        text.allSatisfy(\.isWhitespace)
    }
}
