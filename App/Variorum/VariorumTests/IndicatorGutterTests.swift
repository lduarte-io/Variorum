//
//  IndicatorGutterTests.swift
//  VariorumTests
//
//  13u4 UNIT S3 — **KnownIssues row 63: the editing indicator's ring
//  overhangs the prose column by 8 pt and therefore CROSSES the gutter's
//  callout glyph and comment badge**, both of which stop 4 pt short of the
//  prose. Pre-existing geometry (`indicatorRect`, unchanged since 13 C1)
//  made newly visible when 13u3 UNIT A1 moved the decorations into the
//  gutter at the block's first line.
//
//  **THE DEFECT, in numbers, on the shipped functions** (re-runnable on any
//  tree — both are pure): at `textLeft = 200` the glyph box is
//  `[178, 196]` (`textLeft − calloutGlyphAir − calloutGlyphBox.width` …
//  `textLeft − calloutGlyphAir`) and the shipped ring began at
//  `textLeft − 8 = 192` — **4 pt inside the glyph**, drawn straight
//  through it. The comment BADGE ends at the same 196 and had the same
//  4 pt of the ring across it. A margin CARD ends at `textLeft − 28 = 172`
//  and was never crossed, which is why the commonest commented block
//  looked fine and the callout did not.
//
//  **THE GUTTER LAW is the fence on the fix** (13u3's R-13u-9 reversal):
//  the prose column's measure and left edge never move for a decoration.
//  So the ring YIELDS — its leading edge stops at the gutter face's
//  trailing edge — and nothing about `textLeft`/`textRight` moves. Pinned
//  below, both halves.
//

import AppKit
import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("The editing ring respects the gutter (13u4 UNIT S3, row 63)")
struct IndicatorGutterTests {
    private static let textLeft: CGFloat = 200
    private static let textRight: CGFloat = 640
    private static let block = CGRect(x: 200, y: 120, width: 440, height: 34)

    private func decorState(
        glyph: Bool = false, comments: Int = 0, inlineComments: Bool = false,
        textLeft: CGFloat = IndicatorGutterTests.textLeft
    ) -> BlockDecor.State {
        var state = BlockDecor.State()
        state.frames = [
            BlockDecor.Frame(entryIndex: 0, blockID: "b1", frame: Self.block)
        ]
        state.textLeft = textLeft
        state.textRight = Self.textRight
        state.caretBlockID = "b1"
        state.appearance.indicator = .outline
        state.appearance.inlineComments = inlineComments
        if glyph {
            state.presentations["b1"] = BlockPresentation(
                kind: BlockPresentation.calloutKind, color: "accent", emoji: "📌")
        }
        if comments > 0 {
            state.comments["b1"] = (0..<comments).map {
                BlockDecor.CommentBrief(id: "c\($0)", text: "a note")
            }
        }
        return state
    }

    private func ring(_ state: BlockDecor.State) -> CGRect {
        let faces = BlockDecor.commentGutterFaces(state)
        return BlockDecor.indicatorRect(
            block: Self.block, textLeft: state.textLeft, textRight: state.textRight,
            gutterTrailingX: BlockDecor.gutterTrailingX(
                blockID: "b1", blockTop: Self.block.minY,
                in: state, commentFaces: faces))
    }

    /// The row, answered: a callout block's ring no longer draws through the
    /// glyph in its gutter.
    @Test func theRingStopsAtTheCalloutGlyphItUsedToCrossBy4Points() throws {
        let state = decorState(glyph: true)
        let glyph = try #require(
            BlockDecor.calloutGlyphRect(textLeft: state.textLeft, blockTop: Self.block.minY))
        let rect = ring(state)
        #expect(rect.minX >= glyph.maxX,
                "the ring's leading edge stops at the glyph's trailing edge")
        // The number, so a future change that "fixes" this by a point is
        // visible as a change rather than as a pass.
        #expect(rect.minX == glyph.maxX)
        #expect(glyph.maxX - (state.textLeft - BlockDecor.indicatorOverhang) == 4,
                "the shipped overhang stood 4 pt inside the glyph — the defect's size")
    }

    /// The badge is the glyph's twin at a narrow gutter: same trailing edge,
    /// same 4 pt of ring across it.
    @Test func theRingStopsAtTheCommentBadgeToo() {
        // A gutter too narrow for cards (`gutterFitsCards` wants ≥ 150) but
        // wide enough for the badge — the shape the row's "comment face"
        // half names.
        let state = decorState(comments: 2, textLeft: 60)
        let faces = BlockDecor.commentGutterFaces(state)
        guard case .badge(let badge) = faces["b1"] else {
            Issue.record("this gutter should hold a badge, not \(String(describing: faces["b1"]))")
            return
        }
        #expect(ring(state).minX >= badge.maxX)
    }

    /// The common commented block: a margin CARD stops 28 pt short of the
    /// prose, so the ring keeps every point of its shipped overhang. Green
    /// on both sides by construction — a guard, stated as one.
    @Test func aMarginCardNeverMovesTheRing() {
        let state = decorState(comments: 1)
        let faces = BlockDecor.commentGutterFaces(state)
        guard case .card = faces["b1"] else {
            Issue.record("a 200-pt gutter holds a card")
            return
        }
        #expect(ring(state) == BlockDecor.indicatorRect(
            block: Self.block, textLeft: state.textLeft, textRight: state.textRight))
    }

    /// An EMPTY gutter is byte-identical to what shipped — the claim that
    /// lets every pre-existing `indicatorRect` pin ride unmodified.
    @Test func anEmptyGutterLeavesTheShippedRectByteIdentical() {
        #expect(ring(decorState()) == CGRect(
            x: Self.textLeft - 8, y: Self.block.minY - 3,
            width: (Self.textRight + 8) - (Self.textLeft - 8),
            height: Self.block.height + 6))
    }

    /// **THE GUTTER LAW at this line.** The ring can only ever give room
    /// back: the trailing edge never moves, the leading edge never passes
    /// `textLeft`, and the widest the rect can be is the one it has with an
    /// empty gutter.
    @Test func theRingOnlyEverYieldsAndNeverReachesTheProse() {
        for state in [decorState(glyph: true), decorState(comments: 1),
                      decorState(comments: 3, textLeft: 60)] {
            // The comparison is against the SAME surface's empty-gutter ring:
            // a narrower page has a narrower gutter, so its shipped overhang
            // is its own number and not the 200-pt page's.
            let empty = BlockDecor.indicatorRect(
                block: Self.block, textLeft: state.textLeft, textRight: state.textRight)
            let rect = ring(state)
            #expect(rect.maxX == empty.maxX, "the trailing edge is untouched")
            #expect(rect.minX >= empty.minX, "the ring only ever yields")
            #expect(rect.minX <= state.textLeft, "and never stands on her words")
            #expect(rect.minY == empty.minY && rect.height == empty.height,
                    "the vertical air is untouched")
        }
        // Absurd input: a face claiming to reach past the prose is clamped at
        // the prose's own edge rather than drawing over it.
        let clamped = BlockDecor.indicatorRect(
            block: Self.block, textLeft: Self.textLeft, textRight: Self.textRight,
            gutterTrailingX: Self.textLeft + 999)
        #expect(clamped.minX == Self.textLeft)
    }

    /// The INLINE-comments setting (R7) puts the strip inside the prose
    /// column, so the gutter holds nothing and the ring keeps its overhang.
    @Test func inlineCommentsLeaveTheGutterEmpty() {
        let state = decorState(comments: 2, inlineComments: true)
        #expect(BlockDecor.commentGutterFaces(state).isEmpty)
        #expect(ring(state) == ring(decorState()))
    }

    /// The block HIGHLIGHT shares the rect rule, so it shares this — the
    /// same geometry note `renderSelection` has carried since 13e E2.
    @Test func theBlockHighlightTakesTheSameGutterEdge() {
        var picked = decorState(glyph: true)
        picked.selectedBlockIDs = ["b1"]
        let faces = BlockDecor.commentGutterFaces(picked)
        let trailing = BlockDecor.gutterTrailingX(
            blockID: "b1", blockTop: Self.block.minY, in: picked, commentFaces: faces)
        #expect(trailing != nil)
        #expect(BlockDecor.indicatorRect(
            block: Self.block, textLeft: picked.textLeft, textRight: picked.textRight,
            gutterTrailingX: trailing) == ring(picked))
    }

    /// `commentGutterFaces` is the SAME decision the renderer draws from —
    /// so the two cannot drift. The card/badge/yields ladder, in one place.
    @Test func theGutterDecisionIsOneRuleWithThreeAnswers() {
        // Wide gutter → card.
        if case .card = BlockDecor.commentGutterFaces(decorState(comments: 1))["b1"] {} else {
            Issue.record("a 200-pt gutter holds a card")
        }
        // Narrow → badge.
        if case .badge = BlockDecor.commentGutterFaces(decorState(comments: 1, textLeft: 60))["b1"] {
        } else {
            Issue.record("a 60-pt gutter holds a badge")
        }
        // Too narrow for even a badge → the decoration yields, and the ring
        // is untouched because there is nothing in the gutter to cross.
        let cramped = decorState(comments: 1, textLeft: 18)
        #expect(BlockDecor.commentGutterFaces(cramped)["b1"] == .yields)
        #expect(BlockDecor.gutterTrailingX(
            blockID: "b1", blockTop: Self.block.minY, in: cramped,
            commentFaces: BlockDecor.commentGutterFaces(cramped)) == nil)
    }
}
