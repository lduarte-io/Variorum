//
//  CrystallizationTests.swift
//  VariorumTests
//
//  Phase 7 Step 3: the pure crystallization plans (typing / bulk / one-block)
//  and the apply-time reconciler that heals in-flight-window drift through
//  ordinary operations.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("CrystallizationPlanner (Step 3)")
struct CrystallizationPlannerTests {
    @Test func typingPastOneParagraphPlansExactlyOneMint() {
        // Author ruling 2026-07-12: the newline alone no longer completes
        // the paragraph — the NEXT paragraph's first character does (until
        // then the trailing run is still growing; its width is the spacing
        // the ruling preserves).
        #expect(CrystallizationPlanner.plan(.typing, tail: "First paragraph.\n") == nil)
        let plan = CrystallizationPlanner.plan(.typing, tail: "First paragraph.\nN")
        #expect(plan?.mints == ["First paragraph."])
        #expect(plan?.remainingTail == "N")
        // Nothing trimmed: the view needs no programmatic edit.
        #expect(plan?.normalizedRegionText(applyingFirst: 1) == "First paragraph.\nN")
    }

    @Test func typedBlankLinesRideTheMintAsTrailingContent() {
        // The k−1 rule at crystallization (2026-07-12 ruling): two
        // newlines between the pieces ⇒ one stored; the region text is
        // byte-identical to the tail, so the view needs no edit.
        let plan = CrystallizationPlanner.plan(.typing, tail: "Alpha.\n\nBeta going")
        #expect(plan?.mints == ["Alpha.\n"])
        #expect(plan?.remainingTail == "Beta going")
        #expect(plan?.normalizedRegionText(applyingFirst: 1) == "Alpha.\n\nBeta going")
    }

    @Test func theOpenTailStaysUnminted() {
        #expect(CrystallizationPlanner.plan(.typing, tail: "still typing") == nil)
        #expect(CrystallizationPlanner.plan(.typing, tail: "") == nil)
        // Blank completed segments crystallize into nothing.
        #expect(CrystallizationPlanner.plan(.typing, tail: "\n\n") == nil)
    }

    @Test func multipleCompletedParagraphsPlanInOrderWithExactRemainders() {
        let plan = CrystallizationPlanner.plan(.typing, tail: "a\nb\ncursor")
        #expect(plan?.mints == ["a", "b"])
        #expect(plan?.remaindersAfter == ["b\ncursor", "cursor"])
        #expect(plan?.remainingTail == "cursor")
        #expect(plan?.normalizedRegionText(applyingFirst: 2) == "a\nb\ncursor")
        // Partial (prefix) application is exact for typing plans.
        #expect(plan?.normalizedRegionText(applyingFirst: 1) == "a\nb\ncursor")
        #expect(plan?.tailAfter(applyingFirst: 1) == "b\ncursor")
    }

    @Test func trimmingNormalizesTheView() {
        let plan = CrystallizationPlanner.plan(.typing, tail: "  padded  \nnext")
        #expect(plan?.mints == ["padded"])
        #expect(plan?.normalizedRegionText(applyingFirst: 1) == "padded\nnext")
    }

    @Test func blankLinesBeforeAParagraphAreExcised() {
        // A leading blank run has no preceding piece — it is consumed with
        // the excision, as before the ruling.
        let plan = CrystallizationPlanner.plan(.typing, tail: "\n\npara\nnext going")
        #expect(plan?.mints == ["para"])
        #expect(plan?.remainingTail == "next going")
        #expect(plan?.normalizedRegionText(applyingFirst: 1) == "para\nnext going")
    }

    @Test func bulkPlansSegmentEverythingAndCloseTheTail() {
        let plan = CrystallizationPlanner.plan(
            .bulk(.paragraph), tail: "One.\nTwo.\n\nThree unfinished")
        // 2026-07-12 ruling: the blank line between Two. and Three stores
        // as Two.'s trailing newline — and the normalized region is now
        // byte-identical to the pasted tail (no visible collapse at mint).
        #expect(plan?.mints == ["One.", "Two.\n", "Three unfinished"])
        #expect(plan?.remainingTail == nil)
        #expect(plan?.normalizedRegionText(applyingFirst: 3) == "One.\nTwo.\n\nThree unfinished")
    }

    @Test func idlePlansKeepThePendingTrailingRunOpen() {
        // Round 1, MAJOR 2: the idle/teardown kind never collapses a typed
        // pending gap — r trailing newlines keep r−1 as the open tail and
        // the region text is byte-identical (no visible collapse at mint).
        let plan = CrystallizationPlanner.plan(.idle(.paragraph), tail: "A\n\n")
        #expect(plan?.mints == ["A"])
        #expect(plan?.remainingTail == "\n")
        #expect(plan?.normalizedRegionText(applyingFirst: 1) == "A\n\n")
        // r=1: the run IS the separator; the tail stays open and empty.
        let single = CrystallizationPlanner.plan(.idle(.paragraph), tail: "A\n")
        #expect(single?.mints == ["A"])
        #expect(single?.remainingTail == "")
        #expect(single?.normalizedRegionText(applyingFirst: 1) == "A\n")
        // No trailing run: closes exactly like bulk.
        let closed = CrystallizationPlanner.plan(.idle(.paragraph), tail: "A\nB going")
        #expect(closed?.mints == ["A", "B going"])
        #expect(closed?.remainingTail == nil)
        // Between-piece spacing rides the pieces (the k−1 rule) either way.
        let spaced = CrystallizationPlanner.plan(.idle(.paragraph), tail: "A\n\nB\n\n")
        #expect(spaced?.mints == ["A\n", "B"])
        #expect(spaced?.remainingTail == "\n")
    }

    @Test func bulkSentenceModeSegmentsBySentence() {
        let plan = CrystallizationPlanner.plan(.bulk(.sentence), tail: "One. Two! Three")
        #expect(plan?.mints == ["One.", "Two!", "Three"])
    }

    @Test func oneBlockPlansMintTheTailVerbatim() {
        let plan = CrystallizationPlanner.plan(.oneBlock, tail: "line one\nline two")
        #expect(plan?.mints == ["line one\nline two"])
        #expect(plan?.remainingTail == nil)
        #expect(CrystallizationPlanner.plan(.oneBlock, tail: "  \n ") == nil)
    }
}

@MainActor
@Suite("CrystallizationReconciler (Step 3)")
struct CrystallizationReconcilerTests {
    private func minted(_ pairs: [(String, String)]) -> [CrystallizationReconciler.MintedBlock] {
        pairs.enumerated().map { i, pair in
            .init(blockID: "b\(i)", variantID: pair.0, text: pair.1)
        }
    }

    @Test func cleanPathAppliesEverythingUntouched() {
        let outcome = CrystallizationReconciler.reconcile(
            minted: minted([("v0", "para")]),
            currentTail: "para\nnext",  // the successor's start completed it (2026-07-12 timing)
            kind: .typing)
        #expect(outcome.corrections.isEmpty)
        #expect(outcome.deletions.isEmpty)
        #expect(outcome.applied.map(\.text) == ["para"])
        #expect(outcome.newTail == "next")
        #expect(!outcome.needsFullRerender)
    }

    @Test func textDriftBecomesAnAutosaveCorrection() {
        // The author kept typing INSIDE the completed paragraph during the
        // in-flight window (one-block first-keystroke case, notably).
        let outcome = CrystallizationReconciler.reconcile(
            minted: minted([("v0", "a")]),
            currentTail: "abcde",
            kind: .oneBlock)
        #expect(outcome.corrections.map(\.variantID) == ["v0"])
        #expect(outcome.corrections.map(\.text) == ["abcde"])
        #expect(outcome.applied.map(\.text) == ["abcde"])
        #expect(outcome.newTail == nil)
        #expect(!outcome.needsFullRerender)
    }

    @Test func unTypedParagraphsBecomeDeletions() {
        // The newline was deleted before the mint landed: nothing mintable
        // remains, so the minted block is removed (tray-recoverable).
        let outcome = CrystallizationReconciler.reconcile(
            minted: minted([("v0", "para")]),
            currentTail: "par",
            kind: .typing)
        #expect(outcome.deletions == ["b0"])
        #expect(outcome.applied.isEmpty)
        #expect(outcome.newTail == "par")
    }

    @Test func extraCompletedParagraphsWaitForTheNextMint() {
        // Two more paragraphs completed during the flight: the minted one
        // applies; the rest stay in the tail for the next round.
        let outcome = CrystallizationReconciler.reconcile(
            minted: minted([("v0", "a")]),
            currentTail: "a\nb\nc\n",
            kind: .typing)
        #expect(outcome.applied.map(\.text) == ["a"])
        #expect(outcome.newTail == "b\nc\n")
        #expect(!outcome.needsFullRerender)
    }

    @Test func partialBulkApplicationFallsBackToRerender() {
        let outcome = CrystallizationReconciler.reconcile(
            minted: minted([("v0", "One.")]),
            currentTail: "One.\nTwo.",
            kind: .bulk(.paragraph))
        #expect(outcome.needsFullRerender)
    }

    @Test func partialBulkApplyCarriesTheUnappliedSegments() {
        // Review round 2: a second bulk-class event lands during a bulk
        // mint's flight. The beyond-prefix segments are the author's text —
        // they survive as the open tail (the chained crystallize pass mints
        // them next), never vanish with the closed-tail nil.
        let outcome = CrystallizationReconciler.reconcile(
            minted: minted([("v0", "a"), ("v1", "b")]),
            currentTail: "a\nb\nc\nd",
            kind: .bulk(.paragraph))
        #expect(outcome.applied.map(\.text) == ["a", "b"])
        #expect(outcome.deletions.isEmpty)
        #expect(outcome.newTail == "c\nd")
        #expect(outcome.needsFullRerender)
    }

    @Test func enterDuringAnIdleMintFlightKeepsTheNewParagraph() {
        // The idle-mint's paragraph-bulk plan covered "alpha beta"; the
        // author typed Enter + "gamma" inside the flight window.
        let outcome = CrystallizationReconciler.reconcile(
            minted: minted([("v0", "alpha beta")]),
            currentTail: "alpha beta\ngamma",
            kind: .bulk(.paragraph))
        #expect(outcome.applied.map(\.text) == ["alpha beta"])
        #expect(outcome.newTail == "gamma")
    }
}
