//
//  WCutPlacementTests.swift
//  VariorumTests
//
//  13b Stage 4, Batch 4A — the ceremony sheet's pure keyboard-placement
//  brain (←/→ by word, ⌥←/→ by sentence, ⇥ between takes) and the token
//  flow builder. Pure: no windows, no store.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("WCutPlacement (13b 4A — the ceremony keyboard + flow)")
struct WCutPlacementTests {
    // "One. Two three." — word-rule boundaries [0, 5, 9, 15]; strong
    // (sentence) set [0, 5, 15].
    private let text = "One. Two three."
    private let boundaries = [0, 5, 9, 15]

    @Test func fixtureLandmarks() {
        #expect(BoundarySnapping.boundaries(in: text, granularity: .word) == boundaries)
        #expect(BoundarySnapping.boundaries(in: text, granularity: .sentence) == [0, 5, 15])
    }

    @Test func wordStepsWalkTheBoundaryListAndParkAtTheEnds() {
        #expect(WCutPlacement.wordStep(from: 5, boundaries: boundaries, forward: true) == 9)
        #expect(WCutPlacement.wordStep(from: 9, boundaries: boundaries, forward: true) == 15)
        // Parked at the end: stepping further stays parked (no wraparound).
        #expect(WCutPlacement.wordStep(from: 15, boundaries: boundaries, forward: true) == 15)
        #expect(WCutPlacement.wordStep(from: 5, boundaries: boundaries, forward: false) == 0)
        #expect(WCutPlacement.wordStep(from: 0, boundaries: boundaries, forward: false) == 0)
    }

    @Test func anUnplacedCutEntersFromTheSteppedSide() {
        #expect(WCutPlacement.wordStep(from: nil, boundaries: boundaries, forward: true) == 0)
        #expect(WCutPlacement.wordStep(from: nil, boundaries: boundaries, forward: false) == 15)
        #expect(WCutPlacement.wordStep(from: nil, boundaries: [], forward: true) == nil)
    }

    @Test func sentenceStepsJumpBetweenStrongBoundaries() {
        // From the plain word edge 9: ⌥→ jumps to the end (15), ⌥← to the
        // sentence start 5 — the word edge itself is skipped.
        #expect(WCutPlacement.sentenceStep(
            from: 9, in: text, boundaries: boundaries, forward: true) == 15)
        #expect(WCutPlacement.sentenceStep(
            from: 9, in: text, boundaries: boundaries, forward: false) == 5)
        #expect(WCutPlacement.sentenceStep(
            from: 5, in: text, boundaries: boundaries, forward: false) == 0)
    }

    @Test func tabCyclesTheCheckedTakesAndWraps() {
        let marked = ["a", "b", "c"]
        #expect(WCutPlacement.nextTake(after: "a", in: marked, forward: true) == "b")
        #expect(WCutPlacement.nextTake(after: "c", in: marked, forward: true) == "a")
        #expect(WCutPlacement.nextTake(after: "a", in: marked, forward: false) == "c")
        #expect(WCutPlacement.nextTake(after: nil, in: marked, forward: true) == "a")
        #expect(WCutPlacement.nextTake(after: "gone", in: marked, forward: false) == "c")
        #expect(WCutPlacement.nextTake(after: "a", in: [], forward: true) == nil)
    }

    // MARK: The token flow builder

    @Test func flowItemsAlternateSlotsAndTokens() {
        let items = WCutPlacement.flowItems(text: text, boundaries: boundaries)
        #expect(items == [
            .slot(0), .token(text: "One.", breaksLineAfter: false),
            .slot(5), .token(text: "Two", breaksLineAfter: false),
            .slot(9), .token(text: "three.", breaksLineAfter: false),
            .slot(15),
        ])
    }

    @Test func newlineSegmentsFlagTheLineBreak() {
        // "point one\npoint two" — boundaries [0, 6, 10, 16, 19]; the
        // segment "one\n" carries the break so the flow keeps the take's
        // visible line structure (the outline case).
        let outline = "point one\npoint two"
        let items = WCutPlacement.flowItems(
            text: outline,
            boundaries: BoundarySnapping.boundaries(in: outline, granularity: .word))
        #expect(items == [
            .slot(0), .token(text: "point", breaksLineAfter: false),
            .slot(6), .token(text: "one", breaksLineAfter: true),
            .slot(10), .token(text: "point", breaksLineAfter: false),
            .slot(16), .token(text: "two", breaksLineAfter: false),
            .slot(19),
        ])
    }

    @Test func emptyBoundariesBuildNoFlow() {
        #expect(WCutPlacement.flowItems(text: "", boundaries: []) == [])
        #expect(WCutPlacement.flowItems(text: "x", boundaries: [0]) == [])
    }

    @Test func legalCutPositionsIncludeTheParkingEndsAndRefuseEmptyText() {
        #expect(EditorSurfaceController.legalCutPositions(of: text) == boundaries)
        #expect(EditorSurfaceController.legalCutPositions(of: "") == [],
                "an empty take has nothing to place — its ends coincide")
        #expect(EditorSurfaceController.legalCutPositions(of: "word") == [0, 4],
                "a one-word take offers exactly the two parking ends")
    }
}
