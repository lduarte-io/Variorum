//
//  TypedReturnTests.swift
//  VariorumTests
//
//  18c batch 2 (her U-1) — the pure half of "Return makes a block, anywhere
//  in Write": the DECISION, exhaustively, over a tiling index and a caret.
//  The real-key end of the same ruling is `ReturnKeyTraceTests`, which
//  drives NSEvents through AppKit's interpretation path; this suite exists
//  because the decision is consulted TWICE per keystroke (at the key, to
//  answer "is this mine?", and again at the act's own turn) and both
//  readings must be one rule.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("TypedReturn — the act of the Return key (18c/U-1)")
struct TypedReturnTests {
    /// "alpha" (0-5) · sep 5 · "beta gamma" (6-16) · sep 16 · "delta" (17-22)
    private func threeBlocks(tail: String? = nil) -> BlockRangeIndex {
        BlockRangeIndex(
            slots: [
                slot("a", text: "alpha"),
                slot("b", text: "beta gamma"),
                slot("c", text: "delta"),
            ],
            tail: tail)
    }

    private func act(
        _ index: BlockRangeIndex, caret: Int, length: Int = 0,
        mode: Segmentation = .paragraph,
        texts: [String] = ["alpha", "beta gamma", "delta"]
    ) -> TypedReturn.Act {
        TypedReturn.act(
            selection: NSRange(location: caret, length: length),
            index: index, segmentation: mode,
            textAt: { i in i < texts.count ? texts[i] : "" })
    }

    // MARK: - The three positions inside a block

    /// HER ROW (ledger row 1): the caret at the end of a MIDDLE block —
    /// "paragraphs above and below" — makes a block, where the shipped
    /// model could only ever crystallize at the note's very end.
    @Test func theEndOfAMiddleBlockMakesABlockBelow() {
        #expect(act(threeBlocks(), caret: 16)
            == .emptyBlock(edge: .below, entryIndex: 1, blockID: "b",
                           closingEmptyTail: false))
    }

    @Test func insideABlocksTextDividesAtTheCaret() {
        #expect(act(threeBlocks(), caret: 10) == .divideAtCaret(entryIndex: 1, blockID: "b"))
    }

    /// Before any of the block's text: the empty block goes ABOVE and the
    /// caret stays in the text block — the everyday "push this paragraph
    /// down" (§5.1's first option, taken).
    @Test func theStartOfABlockMakesAnEmptyBlockAbove() {
        #expect(act(threeBlocks(), caret: 6)
            == .emptyBlock(edge: .above, entryIndex: 1, blockID: "b",
                           closingEmptyTail: false))
    }

    /// The LAST block's end is not special any more (it used to be the one
    /// place the machinery had: the open-tail gesture).
    @Test func theLastBlocksEndMakesABlockToo() {
        #expect(act(threeBlocks(), caret: 22)
            == .emptyBlock(edge: .below, entryIndex: 2, blockID: "c",
                           closingEmptyTail: false))
    }

    /// Trailing whitespace between the caret and the block's end is spacing,
    /// not a paragraph to cut off (§5.1).
    @Test func trailingWhitespaceStillCountsAsTheEnd() {
        let index = BlockRangeIndex(slots: [slot("a", text: "alpha  \n ")], tail: nil)
        for caret in 5...9 {
            #expect(act(index, caret: caret, texts: ["alpha  \n "])
                == .emptyBlock(edge: .below, entryIndex: 0, blockID: "a",
                               closingEmptyTail: false))
        }
        // …and one character earlier there IS text to cut off.
        #expect(act(index, caret: 4, texts: ["alpha  \n "])
            == .divideAtCaret(entryIndex: 0, blockID: "a"))
    }

    /// **18c ladder round 1, R1-5 (red-on-old):** leading whitespace is the
    /// mirror of trailing whitespace — a caret anywhere inside a block's
    /// leading run is "before any text" and pushes the paragraph down,
    /// exactly as the block's first offset does. Before the fix caret 1 and
    /// 2 answered `.divideAtCaret`, and the one cut brain then refused the
    /// cut whose first half trims to nothing.
    @Test func leadingWhitespaceStillCountsAsTheStart() {
        let index = BlockRangeIndex(slots: [slot("a", text: "  hello")], tail: nil)
        for caret in 0...2 {
            #expect(act(index, caret: caret, texts: ["  hello"])
                == .emptyBlock(edge: .above, entryIndex: 0, blockID: "a",
                               closingEmptyTail: false))
        }
        // …and one character later there IS text before the caret.
        #expect(act(index, caret: 3, texts: ["  hello"])
            == .divideAtCaret(entryIndex: 0, blockID: "a"))
    }

    /// **18c ladder round 1, R1-4 (red-on-old; PROVISIONAL, QUESTIONS #94):**
    /// a caret INSIDE a list item is the list door's, so the key stays
    /// content and the list block stays whole — the shipped K5 shape, which
    /// U-1's divide had silently replaced mid-item (the second half lost its
    /// bullet; one list became two blocks). The prose line of the same block
    /// still divides; the block's very start still pushes down.
    @Test func aCaretInsideAListLineIsTheListDoorsAndStaysContent() {
        let text = "- one two\nprose after"
        let index = BlockRangeIndex(slots: [slot("a", text: text)], tail: nil)
        #expect(act(index, caret: 5, texts: [text]) == .content, "mid-item: content")
        #expect(act(index, caret: 2, texts: [text]) == .content, "inside the lead: content")
        #expect(act(index, caret: 16, texts: [text])
            == .divideAtCaret(entryIndex: 0, blockID: "a"), "the prose line still divides")
        #expect(act(index, caret: 0, texts: [text])
            == .emptyBlock(edge: .above, entryIndex: 0, blockID: "a",
                           closingEmptyTail: false), "the block's start still pushes down")
        // The line's END is the list door's own position (continue / exit),
        // and the one way this act is reached there is the exit road with
        // the lead already gone (R1-3) — whose next word must be the block,
        // never a newline: with prose below it divides, at the block's end
        // it makes the block below.
        #expect(act(index, caret: 9, texts: [text])
            == .divideAtCaret(entryIndex: 0, blockID: "a"), "a list line's end is not content")
        let last = BlockRangeIndex(slots: [slot("a", text: "- one")], tail: nil)
        #expect(act(last, caret: 5, texts: ["- one"])
            == .emptyBlock(edge: .below, entryIndex: 0, blockID: "a",
                           closingEmptyTail: false))
    }

    // MARK: - The empty block (U-19 (2))

    /// An abandoned empty block STAYS, and a Return in it makes no second
    /// one: her *"we won't reintroduce it with paragraphs disappearing"*
    /// cuts both ways — nothing vanishes, and nothing piles up either.
    @Test func aReturnInAnEmptyBlockDoesNothing() {
        let index = BlockRangeIndex(
            slots: [slot("a", text: "alpha"), slot("b", text: ""), slot("c", text: "delta")],
            tail: nil)
        #expect(act(index, caret: 6, texts: ["alpha", "", "delta"]) == .nothing)
    }

    // MARK: - The cases that stay content

    @Test func theChipOffKeepsReturnAsContent() {
        #expect(act(threeBlocks(), caret: 16, mode: .oneBlock) == .content)
        #expect(act(threeBlocks(), caret: 10, mode: .oneBlock) == .content)
    }

    @Test func aSelectionIsNotThisGesture() {
        #expect(act(threeBlocks(), caret: 6, length: 4) == .content)
    }

    /// A note with no blocks yet IS the tail — its paragraphs are born by
    /// crystallization, the same promise by another road.
    @Test func aFreshPostIsAllTailAndStaysOnItsOwnRoad() {
        let index = BlockRangeIndex(slots: [], tail: "alpha")
        #expect(act(index, caret: 5, texts: []) == .content)
    }

    /// A tail with text in it still crystallizes; the key does not intercept
    /// the road that already makes the block.
    @Test func aTailWithTextKeepsTheCrystallizationRoad() {
        let index = threeBlocks(tail: "epsilon")
        #expect(act(index, caret: 26, texts: ["alpha", "beta gamma", "delta"]) == .content)
    }

    /// **THE TRAP (§4.1), closed.** An EMPTY open tail — what the idle mint
    /// leaves behind after ⏎-then-pause — plans nothing at all, so the key
    /// closes that render artifact and makes the block. Her S1 scenario.
    @Test func anEmptyTailClosesAndMakesABlock() {
        let index = threeBlocks(tail: "")
        #expect(act(index, caret: 23)
            == .emptyBlock(edge: .below, entryIndex: 2, blockID: "c",
                           closingEmptyTail: true))
    }

    /// The caret at the LAST BLOCK's end while an empty tail is open is
    /// still the block's own end (the seam belongs to neither region).
    @Test func theLastBlocksEndUnderAnOpenTailIsStillTheBlock() {
        let index = threeBlocks(tail: "")
        #expect(act(index, caret: 22)
            == .emptyBlock(edge: .below, entryIndex: 2, blockID: "c",
                           closingEmptyTail: false))
    }

    // MARK: - Desync-class inputs answer content, never a trap

    @Test func anOutOfBoundsCaretIsNotThisGesture() {
        #expect(act(threeBlocks(), caret: 999) == .content)
        #expect(act(threeBlocks(), caret: -1) == .content)
    }
}
