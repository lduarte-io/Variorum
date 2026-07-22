//
//  CompareBoardTests.swift
//  VariorumTests
//
//  Phase 13b, Stage 4 (4C): the compare rework's pins — the pure
//  composition brain (N29's honesty rule as code), and the cross-post
//  board model (one authority spanning post contexts, per-post edit
//  routing, per-post reorder isolation, relationship detection).
//

import Dependencies
import Foundation
import GRDB
import Testing
import VariorumCore
@testable import Variorum

// MARK: - The composition brain (pure)

@Suite("Compare composition (13b 4C — N29/S4-12)")
struct CompareCompositionTests {
    /// ZERO lineage ⇒ ONE free segment: the posts sit plainly side by
    /// side, each in its own order — no blank parade, nothing aligned.
    @Test func zeroLineagePacksOneFreeSegment() {
        let segments = CompareComposition.segments(
            anchorBlocks: ["A1", "A2", "A3"],
            peerBlocks: [["B1", "B2"]],
            kinships: [[:]],
            followAnchorOrder: true)
        #expect(segments == [.free(anchor: ["A1", "A2", "A3"], peers: [["B1", "B2"]])])
        #expect(CompareComposition.railedAnchors(kinships: [[:]]).isEmpty,
                "no rails where no lineage speaks")
    }

    /// A partial relationship aligns ONLY the kin rows; the unrelated
    /// stretches between them pack side by side in their own orders —
    /// no blanks between unrelated rows (the S4-12 agreed nuance).
    @Test func partialRelationshipAlignsOnlyWhereLineageSpeaks() {
        // Anchor: A B C D — peer: A' (kin A), X, Y (unrelated), C' (kin C).
        let segments = CompareComposition.segments(
            anchorBlocks: ["A", "B", "C", "D"],
            peerBlocks: [["A'", "X", "Y", "C'"]],
            kinships: [["A'": "A", "C'": "C"]],
            followAnchorOrder: true)
        #expect(segments.count == 4)
        #expect(segments[0] == .aligned(.init(
            anchorBlockID: "A", peerKin: [["A'"]], peerMoved: [false])))
        // B (kin-less) and the peer's X,Y pack ONE free stretch, own orders.
        #expect(segments[1] == .free(anchor: ["B"], peers: [["X", "Y"]]))
        #expect(segments[2] == .aligned(.init(
            anchorBlockID: "C", peerKin: [["C'"]], peerMoved: [false])))
        // D trails kin-less — a free tail, peer side simply empty.
        #expect(segments[3] == .free(anchor: ["D"], peers: [[]]))
        #expect(CompareComposition.railedAnchors(kinships: [["A'": "A", "C'": "C"]])
                == ["A", "C"])
    }

    /// A divide's span shares its anchor's row (the 11a lineage-keyed
    /// registration, carried through), and a cross-version reorder is
    /// MARKED, never guessed at — PostAlignment's semantics survive the
    /// segment layer verbatim.
    @Test func spansShareARowAndMovesStayMarked() {
        let spans = CompareComposition.segments(
            anchorBlocks: ["A", "B"],
            peerBlocks: [["B1'", "B2'", "A'"]],
            kinships: [["B1'": "B", "B2'": "B", "A'": "A"]],
            followAnchorOrder: true)
        #expect(spans == [
            .aligned(.init(anchorBlockID: "A", peerKin: [["A'"]], peerMoved: [true])),
            .aligned(.init(anchorBlockID: "B", peerKin: [["B1'", "B2'"]], peerMoved: [false])),
        ])
    }

    /// Multi-peer (up to the anchor + three): each peer registers against
    /// the anchor independently; a kin row carries every peer's cells (an
    /// uninvolved peer's cell is EMPTY, never a "—" blank), and each
    /// peer's kin-less blocks pack into the free stretches in their own
    /// orders.
    @Test func multiPeerRowsMergeOnTheAnchorSpine() {
        let segments = CompareComposition.segments(
            anchorBlocks: ["A", "B"],
            peerBlocks: [["A'", "P1x"], ["B''", "P2x"]],
            kinships: [["A'": "A"], ["B''": "B"]],
            followAnchorOrder: true)
        #expect(segments == [
            .aligned(.init(anchorBlockID: "A", peerKin: [["A'"], []], peerMoved: [false, false])),
            .aligned(.init(anchorBlockID: "B", peerKin: [[], ["B''"]], peerMoved: [false, false])),
            .free(anchor: [], peers: [["P1x"], ["P2x"]]),
        ])
    }

    /// The follow-order toggle OFF is the display-only escape (S4-3's
    /// shape): every column flows whole, in its own order — even where
    /// kinship exists. Rails stay a separate channel (the lineage-color
    /// toggle), so the composition carries no color decisions.
    @Test func followOrderOffFlowsEveryColumnWhole() {
        let segments = CompareComposition.segments(
            anchorBlocks: ["A", "B"],
            peerBlocks: [["A'", "B'"]],
            kinships: [["A'": "A", "B'": "B"]],
            followAnchorOrder: false)
        #expect(segments == [.free(anchor: ["A", "B"], peers: [["A'", "B'"]])])
    }

    /// Peer blocks arriving BEFORE any kin (an opening the anchor lacks)
    /// pack a leading free stretch; empty inputs compose to nothing.
    @Test func leadingOrphansAndEmptyInputs() {
        let leading = CompareComposition.segments(
            anchorBlocks: ["A"],
            peerBlocks: [["X", "A'"]],
            kinships: [["A'": "A"]],
            followAnchorOrder: true)
        #expect(leading == [
            .free(anchor: [], peers: [["X"]]),
            .aligned(.init(anchorBlockID: "A", peerKin: [["A'"]], peerMoved: [false])),
        ])
        #expect(CompareComposition.segments(
            anchorBlocks: [], peerBlocks: [[]], kinships: [[:]],
            followAnchorOrder: true).isEmpty)
    }
}
