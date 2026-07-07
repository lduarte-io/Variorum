//
//  StructuralGesturePlannerTests.swift
//  VariorumTests
//
//  Phase 9 Step 1 — the planner's exhaustive pure suite (this phase's
//  BlockRangeIndex-class suite): every selection topology × block topology,
//  every refusal reachable, snap correctness on the grapheme corpus,
//  degradation and precedence rules. Pure: worlds are literal, no store.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

private typealias Planner = StructuralGesturePlanner

/// A block spec for literal worlds.
private struct B {
    var text: String
    var arity: Int = 1
    var locked: Bool = false
    var gap: Bool = false

    init(_ text: String, arity: Int = 1, locked: Bool = false, gap: Bool = false) {
        self.text = text
        self.arity = arity
        self.locked = locked
        self.gap = gap
    }
}

private func makeWorld(
    _ blocks: [B], tail: String? = nil, sealed: Bool = false
) -> Planner.World {
    let entries = blocks.enumerated().map { i, b in
        BlockRangeIndex.Entry(
            blockID: "b\(i)", variantID: b.gap ? nil : "v\(i)",
            length: b.text.utf16.count, editable: !b.gap && !b.locked)
    }
    let index = BlockRangeIndex(entries: entries, tailLength: tail.map { $0.utf16.count })
    let texts = blocks.map(\.text)
    return .init(
        index: index, fanArities: blocks.map(\.arity), sealed: sealed,
        textAt: { texts[$0] })
}

/// Document offset of entry i's start.
private func start(_ world: Planner.World, _ i: Int) -> Int {
    world.index.range(ofEntryAt: i).location
}

private func caret(_ offset: Int) -> NSRange { NSRange(location: offset, length: 0) }

// Fixtures. UTF-16 landmarks are asserted in the first test so every
// hand-computed offset below is pinned, not hoped.
private let twoSentences = "First sentence. Second one."       // boundary at 16
private let threeSentences = "Intro clause. Middle stays here. Tail sentence."
// boundaries at 14 and 33
private let twoParas = "Para one.\n\nPara two."                // boundary at 11
private let oneSentence = "Only one sentence here."            // no interior boundary

@Suite("StructuralGesturePlanner — fixtures")
struct PlannerFixtureTests {
    @Test func fixtureLandmarksAreWhatTheSuiteAssumes() {
        #expect(BoundarySnapping.boundaries(in: twoSentences, granularity: .sentence)
            == [0, 16, 27])
        #expect(BoundarySnapping.boundaries(in: threeSentences, granularity: .sentence)
            == [0, 14, 33, 47])
        #expect(BoundarySnapping.boundaries(in: twoParas, granularity: .sentence)
            == [0, 11, 20])
        #expect(BoundarySnapping.boundaries(in: oneSentence, granularity: .sentence)
            == [0, 23])
    }
}

// MARK: - Divide at Cursor

@Suite("StructuralGesturePlanner — divide")
struct PlannerDivideTests {
    @Test func caretMidBlockSnapsToTheNearestInteriorBoundary() {
        let world = makeWorld([B(twoSentences)])
        let plan = Planner.plan(.divideAtCursor, selection: caret(18), world: world)
        #expect(plan == .divide(entryIndex: 0, blockID: "b0", snappedCut: 16))
    }

    @Test func caretNearTheStartStillSnapsInterior_neverToZero() {
        // Raw snap would choose 0 (distance 2 < 14) — divide's legal cuts
        // are interior, so the one interior boundary wins.
        let world = makeWorld([B(twoSentences)])
        let plan = Planner.plan(.divideAtCursor, selection: caret(2), world: world)
        #expect(plan == .divide(entryIndex: 0, blockID: "b0", snappedCut: 16))
    }

    @Test func paragraphMarksAreLegalCutsToo() {
        let world = makeWorld([B(twoParas)])
        let plan = Planner.plan(.divideAtCursor, selection: caret(3), world: world)
        #expect(plan == .divide(entryIndex: 0, blockID: "b0", snappedCut: 11))
    }

    @Test func singleSentenceBlockHasNoLegalCut() {
        let world = makeWorld([B(oneSentence)])
        #expect(Planner.plan(.divideAtCursor, selection: caret(10), world: world)
            == .refusal(.nothingToDo))
    }

    @Test func secondBlockCutsAreEntryLocal() {
        let world = makeWorld([B(oneSentence), B(twoSentences)])
        let base = start(world, 1)
        let plan = Planner.plan(.divideAtCursor, selection: caret(base + 20), world: world)
        #expect(plan == .divide(entryIndex: 1, blockID: "b1", snappedCut: 16))
    }

    @Test func aFannedBlockRoutesToTheWCeremony() {
        let world = makeWorld([B(twoSentences, arity: 3)])
        let plan = Planner.plan(.divideAtCursor, selection: caret(18), world: world)
        #expect(plan == .divideW(entryIndex: 0, blockID: "b0", activeCut: 16))
    }

    @Test func aFannedBlockWithALockedRenderedTakeStillRoutesToW() {
        // W copies marked variants; it never edits a buffer — the lock
        // doesn't refuse (Phase 3 op semantics).
        let world = makeWorld([B(twoSentences, arity: 2, locked: true)])
        let plan = Planner.plan(.divideAtCursor, selection: caret(18), world: world)
        #expect(plan == .divideW(entryIndex: 0, blockID: "b0", activeCut: 16))
    }

    @Test func aLockedSingleVariantBlockRefuses() {
        let world = makeWorld([B(twoSentences, locked: true)])
        #expect(Planner.plan(.divideAtCursor, selection: caret(18), world: world)
            == .refusal(.lockedVariant))
    }

    @Test func aGapSlotRefuses() {
        let world = makeWorld([B(twoSentences, gap: true)])
        #expect(Planner.plan(.divideAtCursor, selection: caret(18), world: world)
            == .refusal(.gapSlot))
    }

    @Test func aNonEmptySelectionDividesAtItsStart() {
        let world = makeWorld([B(twoSentences)])
        let plan = Planner.plan(
            .divideAtCursor, selection: NSRange(location: 18, length: 6), world: world)
        #expect(plan == .divide(entryIndex: 0, blockID: "b0", snappedCut: 16))
    }

    @Test func emptyBlocksHaveNothingToCut() {
        let world = makeWorld([B(""), B(oneSentence)])
        #expect(Planner.plan(.divideAtCursor, selection: caret(0), world: world)
            == .refusal(.nothingToDo))
    }
}

// MARK: - Extract Selection

@Suite("StructuralGesturePlanner — extract")
struct PlannerExtractTests {
    @Test func sloppySuffixSelectionSnapsToTheBoundaryAdjacentSpan() {
        let world = makeWorld([B(threeSentences)])
        let plan = Planner.plan(
            .extractSelection, selection: NSRange(location: 35, length: 9), world: world)
        #expect(plan == .extract(
            entryIndex: 0, blockID: "b0", snappedSpan: 33..<47, edge: .suffix, otherTakes: 0))
    }

    @Test func sloppyPrefixSelectionSnapsToThePrefixSpan() {
        let world = makeWorld([B(threeSentences)])
        let plan = Planner.plan(
            .extractSelection, selection: NSRange(location: 2, length: 8), world: world)
        #expect(plan == .extract(
            entryIndex: 0, blockID: "b0", snappedSpan: 0..<14, edge: .prefix, otherTakes: 0))
    }

    @Test func aMiddleSpanRefusesTowardMakeBlock() {
        let world = makeWorld([B(threeSentences)])
        #expect(Planner.plan(
            .extractSelection, selection: NSRange(location: 15, length: 15), world: world)
            == .refusal(.middleSpanNeedsMakeBlock))
    }

    @Test func theWholeBlockRefuses_alreadyABlock() {
        let world = makeWorld([B(threeSentences)])
        #expect(Planner.plan(
            .extractSelection, selection: NSRange(location: 0, length: 47), world: world)
            == .refusal(.wholeBlockSpan))
    }

    @Test func aFannedBlockExtractCarriesTheHintCount() {
        // Contract item 8: extract from a fanned block is legal — the plan
        // carries the other-takes count for the passive hint.
        let world = makeWorld([B(threeSentences, arity: 4)])
        let plan = Planner.plan(
            .extractSelection, selection: NSRange(location: 35, length: 9), world: world)
        #expect(plan == .extract(
            entryIndex: 0, blockID: "b0", snappedSpan: 33..<47, edge: .suffix, otherTakes: 3))
    }

    @Test func lockedAndGapSlotsRefuse() {
        let locked = makeWorld([B(threeSentences, locked: true)])
        #expect(Planner.plan(
            .extractSelection, selection: NSRange(location: 35, length: 9), world: locked)
            == .refusal(.lockedVariant))
        let gap = makeWorld([B(threeSentences, gap: true)])
        #expect(Planner.plan(
            .extractSelection, selection: NSRange(location: 35, length: 9), world: gap)
            == .refusal(.gapSlot))
    }

    @Test func anEmptySelectionIsNothingToExtract() {
        let world = makeWorld([B(threeSentences)])
        #expect(Planner.plan(.extractSelection, selection: caret(20), world: world)
            == .refusal(.nothingToDo))
    }

    @Test func aCrossBlockSpanRefusesWithTheRatifiedReason() {
        let world = makeWorld([B(twoSentences), B(oneSentence)])
        let plan = Planner.plan(
            .extractSelection,
            selection: NSRange(location: 20, length: 12),  // mid-b0 into b1
            world: world)
        #expect(plan == .refusal(.crossBlockSpan))
    }

    @Test func separatorOverhangIsShrunkNotMisreadAsCrossBlock() {
        // A shift-End selection routinely swallows the trailing separator —
        // the intent is the block-side suffix (TEXTKIT2_NOTES §3 discipline:
        // normalize, never trust the raw boundary selection).
        let world = makeWorld([B("First block one. Two.", arity: 1), B("Second.")])
        let plan = Planner.plan(
            .extractSelection,
            selection: NSRange(location: 17, length: 5),  // "Two." + the separator
            world: world)
        #expect(plan == .extract(
            entryIndex: 0, blockID: "b0", snappedSpan: 17..<21, edge: .suffix, otherTakes: 0))
    }

    @Test func aSelectionStartingOnTheSeparatorBelongsToTheTrailingBlock() {
        let world = makeWorld([B(oneSentence), B("One. Two more words.")])
        let base = start(world, 1)
        let plan = Planner.plan(
            .extractSelection,
            selection: NSRange(location: base - 1, length: 5),  // separator + "One."
            world: world)
        #expect(plan == .extract(
            entryIndex: 1, blockID: "b1", snappedSpan: 0..<5, edge: .prefix, otherTakes: 0))
    }

    @Test func aTinySpanThatSnapsClosedIsNothingToDo() {
        let world = makeWorld([B(threeSentences)])
        #expect(Planner.plan(
            .extractSelection, selection: NSRange(location: 15, length: 1), world: world)
            == .refusal(.nothingToDo))
    }
}

// MARK: - Make Block from Selection (the composed middle-span gesture)

@Suite("StructuralGesturePlanner — make block")
struct PlannerMakeBlockTests {
    @Test func aMiddleSpanOnASingleVariantBlockPlansTheComposedGesture() {
        let world = makeWorld([B(threeSentences)])
        let plan = Planner.plan(
            .makeBlockFromSelection, selection: NSRange(location: 15, length: 15), world: world)
        #expect(plan == .makeBlock(entryIndex: 0, blockID: "b0", snappedSpan: 14..<33))
    }

    @Test func aFannedBlockRefusesTowardTheWCeremony() {
        let world = makeWorld([B(threeSentences, arity: 2)])
        #expect(Planner.plan(
            .makeBlockFromSelection, selection: NSRange(location: 15, length: 15), world: world)
            == .refusal(.fannedMiddleSpan))
    }

    @Test func aBoundaryTouchingSpanDegradesToExtract_oneOpBeatsTwo() {
        let world = makeWorld([B(threeSentences)])
        let prefix = Planner.plan(
            .makeBlockFromSelection, selection: NSRange(location: 2, length: 8), world: world)
        #expect(prefix == .extract(
            entryIndex: 0, blockID: "b0", snappedSpan: 0..<14, edge: .prefix, otherTakes: 0))
        let suffix = Planner.plan(
            .makeBlockFromSelection, selection: NSRange(location: 35, length: 9), world: world)
        #expect(suffix == .extract(
            entryIndex: 0, blockID: "b0", snappedSpan: 33..<47, edge: .suffix, otherTakes: 0))
    }

    @Test func theDegradedExtractOnAFannedBlockIsLegalAndHinted() {
        // Degradation happens BEFORE the fan check: extract works on fans.
        let world = makeWorld([B(threeSentences, arity: 2)])
        let plan = Planner.plan(
            .makeBlockFromSelection, selection: NSRange(location: 2, length: 8), world: world)
        #expect(plan == .extract(
            entryIndex: 0, blockID: "b0", snappedSpan: 0..<14, edge: .prefix, otherTakes: 1))
    }

    @Test func crossBlockWholeBlockLockedAndEmptyRefuse() {
        let world = makeWorld([B(twoSentences), B(oneSentence)])
        #expect(Planner.plan(
            .makeBlockFromSelection, selection: NSRange(location: 20, length: 12), world: world)
            == .refusal(.crossBlockSpan))
        #expect(Planner.plan(
            .makeBlockFromSelection, selection: NSRange(location: 0, length: 27), world: world)
            == .refusal(.wholeBlockSpan))
        let locked = makeWorld([B(threeSentences, locked: true)])
        #expect(Planner.plan(
            .makeBlockFromSelection, selection: NSRange(location: 15, length: 15), world: locked)
            == .refusal(.lockedVariant))
        #expect(Planner.plan(
            .makeBlockFromSelection, selection: caret(15), world: makeWorld([B(threeSentences)]))
            == .refusal(.nothingToDo))
    }
}

// MARK: - Merge Blocks

@Suite("StructuralGesturePlanner — merge")
struct PlannerMergeTests {
    // ["Aa.", "Bb.", "Cc."]: separators at 3 and 7; starts 0, 4, 8.
    private var world: Planner.World { makeWorld([B("Aa."), B("Bb."), B("Cc.")]) }

    @Test func caretAtEitherSideOfASeamNamesThePair() {
        for offset in [3, 4] {
            #expect(Planner.plan(.mergeBlocks, selection: caret(offset), world: world)
                == .merge(leadingIndex: 0, trailingIndex: 1,
                          leadingBlockID: "b0", trailingBlockID: "b1"),
                    "caret at \(offset)")
        }
        #expect(Planner.plan(.mergeBlocks, selection: caret(7), world: world)
            == .merge(leadingIndex: 1, trailingIndex: 2,
                      leadingBlockID: "b1", trailingBlockID: "b2"))
    }

    @Test func caretMidBlockIsNotASeam() {
        #expect(Planner.plan(.mergeBlocks, selection: caret(1), world: world)
            == .refusal(.notASeam))
    }

    @Test func caretAtTheDocumentEdgesIsNotASeam() {
        #expect(Planner.plan(.mergeBlocks, selection: caret(0), world: world)
            == .refusal(.notASeam))
        #expect(Planner.plan(.mergeBlocks, selection: caret(11), world: world)
            == .refusal(.notASeam))
    }

    @Test func aSelectionSpanningExactlyTwoAdjacentBlocksEnables() {
        let plan = Planner.plan(
            .mergeBlocks, selection: NSRange(location: 2, length: 3), world: world)
        #expect(plan == .merge(leadingIndex: 0, trailingIndex: 1,
                               leadingBlockID: "b0", trailingBlockID: "b1"))
    }

    @Test func selectingJustTheSeparatorNamesItsPair() {
        let plan = Planner.plan(
            .mergeBlocks, selection: NSRange(location: 7, length: 1), world: world)
        #expect(plan == .merge(leadingIndex: 1, trailingIndex: 2,
                               leadingBlockID: "b1", trailingBlockID: "b2"))
    }

    @Test func threeBlocksRefuseWithTheBinaryRule() {
        #expect(Planner.plan(
            .mergeBlocks, selection: NSRange(location: 1, length: 9), world: world)
            == .refusal(.tooManyBlocksForMerge))
    }

    @Test func aSelectionInsideOneBlockIsNotASeam() {
        #expect(Planner.plan(
            .mergeBlocks, selection: NSRange(location: 0, length: 3), world: world)
            == .refusal(.notASeam))
    }

    @Test func anEndpointGrazeOfAThirdBlockDoesNotCountIt() {
        // Gate-review observation, pinned: a selection ending EXACTLY at the
        // third block's start (zero of its characters selected) means the
        // two blocks whose text is selected — selected characters decide.
        let plan = Planner.plan(
            .mergeBlocks, selection: NSRange(location: 1, length: 7), world: world)
        #expect(plan == .merge(leadingIndex: 0, trailingIndex: 1,
                               leadingBlockID: "b0", trailingBlockID: "b1"))
    }

    @Test func lastCharPlusTheSeparatorIsNotASeamSelection() {
        // The consistent line (recorded in the closeout): a separator names
        // a pair only when it is selected ALONE; with block characters in
        // the selection, the characters decide — here only b0's are.
        #expect(Planner.plan(
            .mergeBlocks, selection: NSRange(location: 2, length: 2), world: world)
            == .refusal(.notASeam))
    }

    @Test func anEmptyBlockBetweenRefusesTheBinaryRule() {
        // ["Aa.", "", "Cc."]: the empty middle block has no characters to
        // select, but three blocks are involved — the binary rule refuses.
        let gapped = makeWorld([B("Aa."), B(""), B("Cc.")])
        #expect(Planner.plan(
            .mergeBlocks, selection: NSRange(location: 1, length: 5), world: gapped)
            == .refusal(.tooManyBlocksForMerge))
    }

    @Test func aGapNeighborRefuses() {
        let gappy = makeWorld([B("Aa."), B("Bb.", gap: true)])
        #expect(Planner.plan(.mergeBlocks, selection: caret(3), world: gappy)
            == .refusal(.gapSlot))
    }

    @Test func lockedNeighborsStillMerge_copiesNotEdits() {
        let locked = makeWorld([B("Aa.", locked: true), B("Bb.", locked: true)])
        #expect(Planner.plan(.mergeBlocks, selection: caret(3), world: locked)
            == .merge(leadingIndex: 0, trailingIndex: 1,
                      leadingBlockID: "b0", trailingBlockID: "b1"))
    }

    @Test func aOneBlockDocumentHasNoSeam() {
        let single = makeWorld([B(oneSentence)])
        #expect(Planner.plan(.mergeBlocks, selection: caret(5), world: single)
            == .refusal(.notASeam))
    }
}

// MARK: - The open tail, the seal, and precedence

@Suite("StructuralGesturePlanner — tail, seal, precedence")
struct PlannerPrecedenceTests {
    @Test func everyCommandRefusesInTheTailRegion() {
        let world = makeWorld([B(twoSentences)], tail: "still being typed")
        let tailStart = world.index.tailRange!.location
        for command in Planner.Command.allCases {
            #expect(Planner.plan(
                command, selection: NSRange(location: tailStart + 2, length: 3), world: world)
                == .refusal(.openTailTarget), "\(command)")
        }
    }

    @Test func aSpanCrossingIntoTheTailIsATailRefusalNotACrossBlockOne() {
        let world = makeWorld([B(twoSentences)], tail: "open tail text")
        let plan = Planner.plan(
            .extractSelection, selection: NSRange(location: 20, length: 12), world: world)
        #expect(plan == .refusal(.openTailTarget))
    }

    @Test func aFreshPostIsAllTail() {
        let world = makeWorld([], tail: "first words, no blocks yet")
        for command in Planner.Command.allCases {
            #expect(Planner.plan(command, selection: caret(3), world: world)
                == .refusal(.openTailTarget), "\(command)")
        }
    }

    @Test func theCaretAtTheLastBlocksEndIsBlockSideNotTailSide() {
        // With a tail open, the last block's exact end (== the tail
        // separator offset) still belongs to the block: divide there is a
        // nothingToDo (no interior cut at the very end), never a tail refusal.
        let world = makeWorld([B(oneSentence)], tail: "typing")
        let end = world.index.range(ofEntryAt: 0).upperBound
        #expect(Planner.plan(.divideAtCursor, selection: caret(end), world: world)
            == .refusal(.nothingToDo))
    }

    @Test func theSealOutranksEverything() {
        let world = makeWorld(
            [B(twoSentences, gap: true)], tail: "tail", sealed: true)
        for command in Planner.Command.allCases {
            #expect(Planner.plan(command, selection: caret(2), world: world)
                == .refusal(.sealed), "\(command)")
        }
    }

    @Test func selectionsOutsideTheTilingRefuseAsInvalid_neverCrash() {
        let world = makeWorld([B(oneSentence)])
        for command in Planner.Command.allCases {
            #expect(Planner.plan(
                command, selection: NSRange(location: 5, length: 500), world: world)
                == .refusal(.invalidSelection), "\(command)")
            #expect(Planner.plan(
                command, selection: NSRange(location: -2, length: 1), world: world)
                == .refusal(.invalidSelection), "\(command)")
        }
    }

    @Test func everyRefusalReasonIsReachable() {
        // The closed enum's cases, each produced by at least one topology
        // above — this test pins the map so a new case must land with a
        // producing topology (and copy, via RefusalCopy's exhaustive switch).
        var reached: Set<Planner.Refusal> = []
        func note(_ plan: Planner.Plan) {
            if case .refusal(let r) = plan { reached.insert(r) }
        }
        let plain = makeWorld([B(threeSentences), B(oneSentence)])
        note(Planner.plan(.divideAtCursor, selection: caret(2),
                          world: makeWorld([B(threeSentences)], sealed: true)))      // sealed
        note(Planner.plan(.divideAtCursor, selection: caret(2),
                          world: makeWorld([B(threeSentences, gap: true)])))         // gapSlot
        note(Planner.plan(.divideAtCursor, selection: caret(20),
                          world: makeWorld([B(threeSentences, locked: true)])))      // lockedVariant
        note(Planner.plan(.divideAtCursor, selection: caret(2),
                          world: makeWorld([], tail: "tail text")))                  // openTailTarget
        note(Planner.plan(.extractSelection,
                          selection: NSRange(location: 40, length: 10), world: plain)) // crossBlockSpan
        note(Planner.plan(.extractSelection,
                          selection: NSRange(location: 0, length: 47), world: plain)) // wholeBlockSpan
        note(Planner.plan(.extractSelection,
                          selection: NSRange(location: 15, length: 15), world: plain)) // middleSpanNeedsMakeBlock
        note(Planner.plan(.makeBlockFromSelection,
                          selection: NSRange(location: 15, length: 15),
                          world: makeWorld([B(threeSentences, arity: 2)])))          // fannedMiddleSpan
        note(Planner.plan(.mergeBlocks, selection: NSRange(location: 1, length: 9),
                          world: makeWorld([B("Aa."), B("Bb."), B("Cc.")])))         // tooManyBlocks
        note(Planner.plan(.mergeBlocks, selection: caret(1),
                          world: makeWorld([B("Aa."), B("Bb.")])))                   // notASeam
        note(Planner.plan(.divideAtCursor, selection: caret(5),
                          world: makeWorld([B(oneSentence)])))                       // nothingToDo
        note(Planner.plan(.divideAtCursor, selection: NSRange(location: 0, length: 999),
                          world: plain))                                             // invalidSelection
        #expect(reached == Set(Planner.Refusal.allCases))
    }
}

// MARK: - Grapheme corpus (the Phase 3 unit decision, upheld at the gesture layer)

@Suite("StructuralGesturePlanner — graphemes")
struct PlannerGraphemeTests {
    @Test func aCaretInsideAZWJFamilySnapsToAGraphemeAlignedBoundary() {
        let text = "Family 👨‍👩‍👧‍👦 here. Next sentence."
        let boundary = BoundarySnapping.boundaries(in: text, granularity: .sentence)
            .first { $0 != 0 && $0 != text.utf16.count }!
        let world = makeWorld([B(text)])
        // Caret INSIDE the 11-unit emoji cluster (offset 9 splits it).
        let plan = Planner.plan(.divideAtCursor, selection: caret(9), world: world)
        #expect(plan == .divide(entryIndex: 0, blockID: "b0", snappedCut: boundary))
        #expect(BoundarySnapping.graphemeIndex(atUTF16: boundary, in: text) != nil,
                "the planner only ever hands out grapheme-aligned cuts")
    }

    @Test func combiningMarksNeverLeakUnalignedOffsets() {
        let text = "Cafe\u{301} noir. Deux mots."
        let world = makeWorld([B(text)])
        // Caret between the base 'e' and its combining accent (offset 4).
        let plan = Planner.plan(.divideAtCursor, selection: caret(4), world: world)
        guard case .divide(_, _, let cut) = plan else {
            Issue.record("expected a divide, got \(plan)")
            return
        }
        #expect(BoundarySnapping.graphemeIndex(atUTF16: cut, in: text) != nil)
    }

    @Test func spanSnappingIsGraphemeSafeToo() {
        let text = "Start 👩‍🚀 one. End two."
        let world = makeWorld([B(text)])
        let plan = Planner.plan(
            .extractSelection,
            selection: NSRange(location: 7, length: 3),  // splits the astronaut
            world: world)
        if case .extract(_, _, let span, _, _) = plan {
            #expect(BoundarySnapping.graphemeRange(span, in: text) != nil)
        } else if case .refusal(let r) = plan {
            #expect(r == .nothingToDo)  // collapsed snap is also legal here
        }
    }
}
