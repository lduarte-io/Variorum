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
        let plan = CrystallizationPlanner.plan(.typing, tail: "First paragraph.\n")
        #expect(plan?.mints == ["First paragraph."])
        #expect(plan?.remainingTail == "")
        // Nothing trimmed: the view needs no programmatic edit.
        #expect(plan?.normalizedRegionText(applyingFirst: 1) == "First paragraph.\n")
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
        let plan = CrystallizationPlanner.plan(.typing, tail: "\n\npara\n")
        #expect(plan?.mints == ["para"])
        #expect(plan?.remainingTail == "")
        #expect(plan?.normalizedRegionText(applyingFirst: 1) == "para\n")
    }

    @Test func bulkPlansSegmentEverythingAndCloseTheTail() {
        let plan = CrystallizationPlanner.plan(
            .bulk(.paragraph), tail: "One.\nTwo.\n\nThree unfinished")
        #expect(plan?.mints == ["One.", "Two.", "Three unfinished"])
        #expect(plan?.remainingTail == nil)
        #expect(plan?.normalizedRegionText(applyingFirst: 3) == "One.\nTwo.\nThree unfinished")
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
            currentTail: "para\n",
            kind: .typing)
        #expect(outcome.corrections.isEmpty)
        #expect(outcome.deletions.isEmpty)
        #expect(outcome.applied.map(\.text) == ["para"])
        #expect(outcome.newTail == "")
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
}
