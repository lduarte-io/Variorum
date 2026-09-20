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

    /// **The sanity pass's observation on R1-5, pinned (red-on-old):** a
    /// block that is nothing but whitespace — ⏎, two spaces, ⏎ — has no text
    /// to stand before, so past its first offset the key makes the block
    /// BELOW, exactly as before R1-5; the prefix rule alone had flipped every
    /// caret of it to `.above`. Its first offset still pushes down (U-1's
    /// letter for a block's start).
    @Test func aWhitespaceOnlyBlockStillMakesTheBlockBelow() {
        let index = BlockRangeIndex(slots: [slot("a", text: "   ")], tail: nil)
        for caret in 1...3 {
            #expect(act(index, caret: caret, texts: ["   "])
                == .emptyBlock(edge: .below, entryIndex: 0, blockID: "a",
                               closingEmptyTail: false))
        }
        #expect(act(index, caret: 0, texts: ["   "])
            == .emptyBlock(edge: .above, entryIndex: 0, blockID: "a",
                           closingEmptyTail: false))
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

    // MARK: - The empty block CHAINS (R-13u4-2 — her ruling change, 13u4 E1)

    /// **HER RULING CHANGE (R-13u4-2, the 13u4 sizing-and-rulings sitting,
    /// 2026-09-20), verbatim:** *"This is driving me insane - on an empty
    /// block, you can't keep making new lines and spawning more empty blocks.
    /// Direct violation of 'works how you'd expect a text editor to work'…
    /// You should be able to go down the list typing whatever you want in a
    /// series of empty blocks."*
    ///
    /// So an empty block's Return is now the SAME verdict a block's end
    /// gives — an empty block below, the caret in it — and it chains.
    /// **SUPERSEDES U-1's "nothing in an empty block" arm**, which this pin
    /// held as `aReturnInAnEmptyBlockDoesNothing` (`== .nothing`). A ruled
    /// change, not a defect: the pin is rewritten to the ruling, and no
    /// red-on-old is owed (13u4 CAST & DISCIPLINE). What U-19 (2) still says
    /// is untouched — nothing vanishes; the empties she leaves behind STAY.
    @Test func aReturnInAnEmptyBlockMintsAnotherBelowIt() {
        let index = BlockRangeIndex(
            slots: [slot("a", text: "alpha"), slot("b", text: ""), slot("c", text: "delta")],
            tail: nil)
        #expect(act(index, caret: 6, texts: ["alpha", "", "delta"])
            == .emptyBlock(edge: .below, entryIndex: 1, blockID: "b",
                           closingEmptyTail: false))
    }

    /// …and it chains at the caret's OWN empty block, never at the run's
    /// first one: consecutive empty entries carry distinct offsets (the
    /// separator between two of them belongs to neither), so the caret one
    /// character along answers with the next block's mint. This is what makes
    /// ⏎⏎⏎ a run rather than three mints in one place.
    @Test func theChainAnswersAtTheCaretsOwnEmptyBlock() {
        let index = BlockRangeIndex(
            slots: [slot("a", text: "alpha"), slot("b", text: ""),
                    slot("c", text: ""), slot("d", text: "delta")],
            tail: nil)
        let texts = ["alpha", "", "", "delta"]
        #expect(act(index, caret: 6, texts: texts)
            == .emptyBlock(edge: .below, entryIndex: 1, blockID: "b",
                           closingEmptyTail: false))
        #expect(act(index, caret: 7, texts: texts)
            == .emptyBlock(edge: .below, entryIndex: 2, blockID: "c",
                           closingEmptyTail: false))
    }

    /// The chip OFF is still the whole note's answer, the empty block
    /// included (U-19 (3)): R-13u4-2 changes what the key does when it ACTS,
    /// never whether it acts at all.
    @Test func theChipOffKeepsAnEmptyBlocksReturnAsContent() {
        let index = BlockRangeIndex(
            slots: [slot("a", text: "alpha"), slot("b", text: ""), slot("c", text: "delta")],
            tail: nil)
        #expect(act(index, caret: 6, mode: .oneBlock, texts: ["alpha", "", "delta"])
            == .content)
    }

    /// **#92(c) composes AHEAD of the chain** (R-13u4-2's own sentence). With
    /// an EMPTY TAIL open below an empty last block the two caret positions
    /// are one apart and answer differently, deliberately: in the BLOCK it is
    /// the chain (nothing to close — the tail is not where she is), in the
    /// TAIL it is the trap's close-and-mint, which was never the empty
    /// block's arm and is untouched by this ruling.
    @Test func theEmptyTailClosesAndMintsAheadOfTheChain() {
        let index = BlockRangeIndex(
            slots: [slot("a", text: "alpha"), slot("b", text: "")], tail: "")
        #expect(act(index, caret: 6, texts: ["alpha", ""])
            == .emptyBlock(edge: .below, entryIndex: 1, blockID: "b",
                           closingEmptyTail: false),
                "the caret is in the empty BLOCK: the chain")
        #expect(act(index, caret: 7, texts: ["alpha", ""])
            == .emptyBlock(edge: .below, entryIndex: 1, blockID: "b",
                           closingEmptyTail: true),
                "the caret is in the empty TAIL: #92(c)'s close-and-mint")
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
