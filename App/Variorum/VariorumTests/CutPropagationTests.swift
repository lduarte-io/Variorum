//
//  CutPropagationTests.swift
//  VariorumTests
//
//  Phase 9 Step 6 — the W ceremony's pure cut proposals: unique
//  string-context match or nothing, always snapped to a legal interior
//  boundary of the target, grapheme-safe.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("CutPropagation (Phase 9, Step 6)")
struct CutPropagationTests {
    @Test func aUniqueMatchProposesTheCorrespondingSnappedCut() {
        let active = "First alpha. First omega."   // cut 13 = before "First omega."
        let target = "Intro pad. First alpha. First omega."
        let proposal = CutPropagation.propose(
            activeCut: 13, activeText: active, targetText: target)
        #expect(proposal == 24)  // the same seam, shifted by the prefix
    }

    @Test func zeroMatchesProposeNothing() {
        let proposal = CutPropagation.propose(
            activeCut: 13,
            activeText: "First alpha. First omega.",
            targetText: "Wholly different words. Nothing shared.")
        #expect(proposal == nil)
    }

    @Test func multipleMatchesProposeNothing_neverAGuess() {
        // The context around the cut appears twice in the target.
        let active = "Alpha one. Beta two."
        let target = "Alpha one. Beta two. Filler. Alpha one. Beta two."
        let proposal = CutPropagation.propose(
            activeCut: 11, activeText: active, targetText: target, window: 6)
        #expect(proposal == nil)
    }

    @Test func proposalsAlwaysLandOnALegalInteriorBoundary() {
        let active = "One two. Three four."
        let target = "Pad sentence. One two. Three four. Tail bit."
        guard let proposal = CutPropagation.propose(
            activeCut: 9, activeText: active, targetText: target) else {
            Issue.record("expected a proposal")
            return
        }
        let end = target.utf16.count
        let interior = BoundarySnapping.boundaries(in: target, granularity: .sentence)
            .filter { $0 != 0 && $0 != end }
        #expect(interior.contains(proposal))
    }

    @Test func aBlankContextWindowProposesNothing() {
        // With a 1-unit window around a cut flanked by whitespace, the
        // needle is all-whitespace — matching it would be meaningless.
        let active = "A.  \n  B."
        let proposal = CutPropagation.propose(
            activeCut: 4, activeText: active, targetText: "A.  \n  B.", window: 1)
        #expect(proposal == nil)
    }

    @Test func aMisalignedActiveCutProposesNothing() {
        let active = "Family 👨‍👩‍👧‍👦 here. Next one."
        // Offset 9 splits the ZWJ family — no proposal, never a crash.
        #expect(CutPropagation.propose(
            activeCut: 9, activeText: active, targetText: active) == nil)
    }

    @Test func theWindowClampsToGraphemesAndTextEdges() {
        // The emoji sits just inside the window: the window must clamp to
        // whole graphemes (never splitting the cluster) and the match still
        // resolves. Cut after "here. " (18 + 6 = offset 25... computed from
        // the boundary list to stay honest).
        let active = "Hi 👨‍👩‍👧‍👦 here. Next one."
        let cut = BoundarySnapping.boundaries(in: active, granularity: .sentence)
            .first { $0 != 0 && $0 != active.utf16.count }!
        let target = "Padding words. Hi 👨‍👩‍👧‍👦 here. Next one."
        guard let proposal = CutPropagation.propose(
            activeCut: cut, activeText: active, targetText: target, window: 12) else {
            Issue.record("expected a proposal")
            return
        }
        #expect(BoundarySnapping.graphemeIndex(atUTF16: proposal, in: target) != nil)
    }

    @Test func aTargetWithoutALegalCutProposesNothing() {
        // The context matches, but the target (one unterminated clause) has
        // no interior boundary to snap to — nothing legal to propose.
        let proposal = CutPropagation.propose(
            activeCut: 3, activeText: "abc def", targetText: "xx abc def yy", window: 3)
        #expect(proposal == nil)
    }
}
