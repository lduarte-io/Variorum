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
    /// never become blocks; segment texts are trimmed (the separators they
    /// lose are re-created by the rendering join, never stored — AppSpec
    /// denormalization rule). `one_block` passes the text through verbatim.
    public static func bulkSegments(_ text: String, mode: Segmentation) -> [String] {
        guard !isBlank(text) else { return [] }
        switch mode {
        case .oneBlock:
            return [text]
        case .paragraph:
            return text
                .split(separator: "\n", omittingEmptySubsequences: true)
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        case .sentence:
            return sentences(in: text)
        }
    }

    // MARK: - Type-time crystallization

    /// Reports the first completed paragraph in the open tail, if any: text
    /// followed by a typed newline is "typed past". Blank line-segments are
    /// skipped (they crystallize into nothing) but remain accounted for —
    /// `remainingTail` is always an exact suffix of `openTail`, so the editor
    /// can excise `blockText` + separator without guessing.
    public static func crystallizedBoundary(openTail: String) -> Crystallization? {
        let segments = openTail.split(separator: "\n", omittingEmptySubsequences: false)
        // The last segment is the paragraph still being typed — never a block.
        guard segments.count > 1 else { return nil }
        for (index, segment) in segments.dropLast().enumerated() where !isBlank(String(segment)) {
            return Crystallization(
                blockText: segment.trimmingCharacters(in: .whitespaces),
                remainingTail: segments[(index + 1)...].joined(separator: "\n"))
        }
        return nil
    }

    // MARK: - Sentence scanning

    /// Characters that end a sentence.
    private static let terminators: Set<Character> = [".", "!", "?"]
    /// Closing punctuation that may trail a terminator and still belong to
    /// the sentence: `He said "Stop!" and left.`
    private static let closers: Set<Character> = ["\"", "'", "\u{201D}", "\u{2019}", ")", "]"]

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
