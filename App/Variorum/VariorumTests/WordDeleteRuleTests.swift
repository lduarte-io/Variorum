//
//  WordDeleteRuleTests.swift
//  VariorumTests
//
//  VX-1076 — `WordDelete`'s rule, pure (`Surface/WordDelete.swift`). The
//  system's own boundary is read the way the wire reads it —
//  `nextWord(from:forward:)` on a text storage — so each case here is the
//  question the live press asks, minus the view. The key-path pins are
//  `WordDeleteKeyTests`.
//

import AppKit
import Foundation
import Testing
@testable import Variorum

@MainActor
@Suite("VX-1076 — WordDelete's rule")
struct WordDeleteRuleTests {
    private typealias F = WordDeleteFixture

    /// The rule's answer at `caret` (nil = the end), the boundary read off a
    /// real text storage; `seams` are the line-break offsets that are block
    /// separators.
    private func answer(
        _ text: String, caret: Int? = nil, _ direction: WordDelete.Direction = .backward,
        seams: Set<Int> = []
    ) -> WordDelete.Outcome {
        let ns = text as NSString
        let at = caret ?? ns.length
        let boundary = NSTextStorage(string: text).nextWord(
            from: at, forward: direction == .forward)
        return WordDelete.outcome(
            direction, caret: at, systemBoundary: boundary, text: ns,
            isBlockSeam: { seams.contains($0.location) })
    }

    /// The range one press removes, as text (nil = the system's own / nothing).
    private func taken(_ text: String, _ outcome: WordDelete.Outcome) -> String? {
        guard case .delete(let range) = outcome else { return nil }
        return (text as NSString).substring(with: range)
    }

    private var secondLine: Int { (F.above as NSString).length + 1 }

    // MARK: Backward — the probe's cases

    @Test func anEmptyListItemTakesItsMarker() {
        let text = F.above + "\n- [ ] "
        #expect(answer(text) == .delete(NSRange(location: secondLine, length: 6)))
        #expect(taken(text, answer(text)) == "- [ ] ")
    }

    @Test func aDashAloneTakesTheDash() {
        let text = F.above + "\n- "
        #expect(taken(text, answer(text)) == "- ")
    }

    @Test func anEmptyLineTakesItsLineBreakAlone() {
        let text = F.above + "\n"
        #expect(answer(text) == .delete(NSRange(location: secondLine - 1, length: 1)))
    }

    @Test func spacesOrPunctuationAloneAreTakenAndNothingMore() {
        #expect(taken(F.above + "\n   ", answer(F.above + "\n   ")) == "   ")
        #expect(taken(F.above + "\n...", answer(F.above + "\n...")) == "...")
        // A glyph the word walk does not count as a word (measured: it
        // crossed the break) is the line's own, too.
        #expect(taken("x\n🎉", answer("x\n🎉")) == "🎉")
    }

    @Test func aWordOnTheLineLeavesThePressToTheSystem() {
        #expect(answer(F.above + "\n- [ ] make") == .system)
        #expect(answer(F.above + "\n- [ ] make", caret: secondLine + 8) == .system)  // mid-word
        #expect(answer(F.above + "\n- [ ] make ") == .system)
        #expect(answer(F.above + "\n- [x] ") == .system, "the ticked box's x is a word")
        #expect(answer(F.above, caret: 17) == .system)
    }

    @Test func theDocumentsEdgesAreTheSystems() {
        #expect(answer("", caret: 0) == .system)
        #expect(answer("abc", caret: 0) == .system)
        #expect(answer("...", caret: 3) == .system, "a first line never crosses anything")
        #expect(answer("abc", caret: 3, .forward) == .system)
    }

    // MARK: Backward — the seam (P-1076-1) and other line breaks

    @Test func aBlockSeamIsNeverTakenTheLineBreakInsideABlockIs() {
        let text = "first\nsecond"
        #expect(answer(text, caret: 6, seams: [5]) == .nothing)
        #expect(answer(text, caret: 6) == .delete(NSRange(location: 5, length: 1)))
    }

    @Test func aSeamOnlyMattersWhereTheBreakWouldBeTaken() {
        // A marker on a block's first line: the marker goes, the seam above
        // it is never asked about.
        let text = "first\n- [ ] "
        #expect(answer(text, seams: [5]) == .delete(NSRange(location: 6, length: 6)))
    }

    @Test func aCRLFBreakIsTakenWhole() {
        #expect(answer("a\r\nb", caret: 3) == .delete(NSRange(location: 1, length: 2)))
        #expect(answer("a\r\nb", caret: 1, .forward) == .delete(NSRange(location: 1, length: 2)))
    }

    @Test func aLineSeparatorIsALineBreak() {
        #expect(answer("word\u{2028}") == .delete(NSRange(location: 4, length: 1)))
    }

    // MARK: Forward — the mirror

    @Test func forwardAtALinesEndTakesTheBreakAlone() {
        #expect(answer("first line\nsecond", caret: 10, .forward)
                == .delete(NSRange(location: 10, length: 1)))
    }

    @Test func forwardOverTrailingSpacesTakesThemAlone() {
        #expect(answer("foo  \nbar", caret: 3, .forward) == .delete(NSRange(location: 3, length: 2)))
        #expect(taken("foo  \n- [ ] bar", answer("foo  \n- [ ] bar", caret: 3, .forward)) == "  ")
    }

    @Test func forwardWithAWordOnTheLineIsTheSystems() {
        #expect(answer("foo bar\nbaz", caret: 3, .forward) == .system)
        #expect(answer(F.above + "\n- [ ] make", caret: secondLine + 6, .forward) == .system)
    }

    @Test func forwardAtABlocksEndDoesNothing() {
        #expect(answer("first\nsecond", caret: 5, .forward, seams: [5]) == .nothing)
    }

    // MARK: The property — a press never leaves the caret's line

    /// Over a battery of texts and EVERY legal caret, both directions: what
    /// the press removes stays on the caret's line, or is exactly the one
    /// line break at its edge — and where the rule hands the press to the
    /// system, the system's own range already stays on the line.
    @Test func aPressNeverReachesAnotherLinesCharacters() {
        let texts = [
            F.checklist, F.above + "\n- [ ] ", F.above + "\n\n\n- \n...",
            "don't stop\n— an em dash —\n…", "see https://example.com/a-b_c?d=1 now\n\n",
            "emoji 🎉🎉 here\n🎉\nx", "日本語のテキスト\n  \t\nend", "a\r\nb\u{2028}c\n",
        ]
        for text in texts {
            let ns = text as NSString
            var caret = 0
            while caret <= ns.length {
                for direction in [WordDelete.Direction.backward, .forward] {
                    let line = WordDelete.lineBounds(at: caret, in: ns)
                    let boundary = NSTextStorage(string: text).nextWord(
                        from: caret, forward: direction == .forward)
                    let range: NSRange
                    switch answer(text, caret: caret, direction) {
                    case .system:
                        range = direction == .backward
                            ? NSRange(location: boundary, length: caret - boundary)
                            : NSRange(location: caret, length: boundary - caret)
                    case .delete(let r):
                        range = r
                    case .nothing:
                        continue
                    }
                    let onLine = range.location >= line.start && range.upperBound <= line.contentsEnd
                    let previous = line.start > 0 ? WordDelete.lineBounds(at: line.start - 1, in: ns) : nil
                    let breakBefore = previous.map {
                        NSRange(location: $0.contentsEnd, length: line.start - $0.contentsEnd)
                    }
                    let breakAfter = NSRange(location: line.contentsEnd, length: line.end - line.contentsEnd)
                    #expect(onLine || range == breakBefore || range == breakAfter,
                            "\(text.debugDescription) @\(caret) \(direction): \(range)")
                }
                // The next LEGAL caret: never inside a composed sequence, and
                // never between a CRLF's two halves (`NSString` does not
                // compose them; a text view never parks a caret there).
                guard caret < ns.length else { break }
                let isCRLF = ns.character(at: caret) == 0x0D
                    && caret + 1 < ns.length && ns.character(at: caret + 1) == 0x0A
                caret = isCRLF ? caret + 2 : NSMaxRange(ns.rangeOfComposedCharacterSequence(at: caret))
            }
        }
    }
}
