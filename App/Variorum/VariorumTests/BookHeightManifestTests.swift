//
//  BookHeightManifestTests.swift
//  VariorumTests
//
//  Phase 13u2b UNIT 1 — the height manifest's PURE half, pinned without a
//  window: the precedence between the three sources, the cumulative-offset
//  arithmetic a landing reads, the width gate, and the derived arm's model.
//
//  Why these are worth pins: the manifest is the reason a landed page stops
//  moving, and every one of its claims is arithmetic. The mounted half — the
//  column really standing still — is `BookOutlineLandingTests`' far-below
//  arm, which this unit unwraps.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@Suite("The book height manifest (13u2b UNIT 1)")
struct BookHeightManifestTests {
    private func manifest(
        _ inputs: [BookHeightManifest.Input],
        width: CGFloat = 700, spacing: CGFloat = 10, leading: CGFloat = 100
    ) -> BookHeightManifest {
        BookHeightManifest(width: width, spacing: spacing, leading: leading, inputs: inputs)
    }

    // MARK: - Precedence

    @Test func aMeasuredHeightOutranksARememberedOneAndARememberedOneOutranksTheModel() {
        let all = manifest([
            .init(id: "a", measured: 120, remembered: 200, derived: 300),
            .init(id: "b", remembered: 200, derived: 300),
            .init(id: "c", derived: 300),
        ])
        #expect(all.height(of: "a") == 120)
        #expect(all.source(of: "a") == .measured)
        #expect(all.height(of: "b") == 200)
        #expect(all.source(of: "b") == .remembered)
        #expect(all.height(of: "c") == 300)
        #expect(all.source(of: "c") == .derived)
    }

    /// A source that answers with nothing usable has not answered. (The
    /// column really produces these: a row reports 0 on the frame before it
    /// has laid out, and a persisted record can be anything a previous
    /// version wrote.)
    @Test func aZeroOrNegativeOrInfiniteAnswerFallsThroughToTheNextSource() {
        let all = manifest([
            .init(id: "zero", measured: 0, remembered: 55, derived: 300),
            .init(id: "negative", measured: -40, derived: 300),
            .init(id: "infinite", measured: .infinity, remembered: .nan, derived: 42),
        ])
        #expect(all.height(of: "zero") == 55)
        #expect(all.source(of: "zero") == .remembered)
        #expect(all.height(of: "negative") == 300)
        #expect(all.height(of: "infinite") == 42)
        #expect(all.source(of: "infinite") == .derived)
    }

    @Test func anUnusableModelClampsToZeroRatherThanPoisoningEveryOffsetBelowIt() {
        let all = manifest([
            .init(id: "bad", derived: -10),
            .init(id: "next", derived: 50),
        ], leading: 0)
        #expect(all.height(of: "bad") == 0)
        #expect(all.offset(of: "next") == 10)  // 0 + the spacing
    }

    // MARK: - The offsets a landing reads

    @Test func offsetsAreCumulativeOverHeightsAndSpacingFromTheColumnsLead() {
        let all = manifest([
            .init(id: "a", derived: 51),
            .init(id: "b", derived: 103),
            .init(id: "c", derived: 20_000),
            .init(id: "d", derived: 103),
        ], spacing: 10, leading: 100)
        #expect(all.offset(of: "a") == 100)
        #expect(all.offset(of: "b") == 161)          // 100 + 51 + 10
        #expect(all.offset(of: "c") == 274)          // + 103 + 10
        #expect(all.offset(of: "d") == 20_284)       // + 20000 + 10
        #expect(all.totalHeight == 20_387)           // the last row's bottom
        #expect(all.offset(of: "nobody") == nil)
        #expect(all.height(of: "nobody") == nil)
    }

    @Test func anEmptyColumnIsItsLeadAndNothingElse() {
        let all = manifest([], leading: 100)
        #expect(all.totalHeight == 100)
        #expect(all.rows.isEmpty)
    }

    /// The anchors are unique by construction; a duplicate would be a bug in
    /// the row list, and answering it twice would make `offset(of:)`
    /// ambiguous exactly where a landing reads it.
    @Test func aDuplicateAnchorIsTakenOnceAndTheFirstOneWins() {
        let all = manifest([
            .init(id: "a", derived: 50),
            .init(id: "a", derived: 999),
            .init(id: "b", derived: 50),
        ], leading: 0)
        #expect(all.rows.count == 2)
        #expect(all.height(of: "a") == 50)
        #expect(all.offset(of: "b") == 60)
    }

    // MARK: - The width gate

    @Test func aManifestAppliesOnlyAtTheWidthItWasBuiltAt() {
        let all = manifest([.init(id: "a", derived: 50)], width: 700)
        #expect(all.appliesAt(700))
        #expect(all.appliesAt(700.5))           // inside `stableSurfaceWidthTolerance`
        #expect(!all.appliesAt(690))
        #expect(!all.appliesAt(500))
    }

    // MARK: - Has the compensator anything to do?

    @Test func aColumnIsExactAboveARowWhenEveryRowAboveItIsAFact() {
        let all = manifest([
            .init(id: "a", measured: 51, derived: 40),
            .init(id: "b", remembered: 20_000, derived: 800),
            .init(id: "target", derived: 103),
            .init(id: "below", derived: 103),
        ])
        #expect(all.isExactAbove("target"))
        // The target's OWN source does not matter — a row cannot push itself
        // off the top of the page — and neither does anything below it.
        #expect(all.source(of: "target") == .derived)
        #expect(all.derivedCount == 2)
        #expect(!all.isExactAbove("nobody"))
    }

    @Test func oneArithmeticRowAboveTheTargetIsEnoughToKeepTheNetArmed() {
        let all = manifest([
            .init(id: "a", measured: 51, derived: 40),
            .init(id: "b", derived: 103),
            .init(id: "target", measured: 103, derived: 103),
        ])
        #expect(!all.isExactAbove("target"))
        #expect(all.isExactAbove("b") == true)
    }

    // MARK: - The derived arm's model

    @Test func anExcerptWrapsToItsCharacterCountOverTheMeasureCappedByTheCardsLineLimit() {
        var metrics = BookOutlineHeightModel.Metrics()
        metrics.cardCharsPerLine = 50
        metrics.cardLineLimit = 3
        #expect(BookOutlineHeightModel.excerptLines("", metrics: metrics) == 0)
        #expect(BookOutlineHeightModel.excerptLines(String(repeating: "x", count: 10), metrics: metrics) == 1)
        #expect(BookOutlineHeightModel.excerptLines(String(repeating: "x", count: 51), metrics: metrics) == 2)
        #expect(BookOutlineHeightModel.excerptLines(String(repeating: "x", count: 100), metrics: metrics) == 2)
        #expect(BookOutlineHeightModel.excerptLines(String(repeating: "x", count: 101), metrics: metrics) == 3)
        // The cap is the card's own `lineLimit(3)`: a 40-word preview can
        // never make a taller card than the card can draw.
        #expect(BookOutlineHeightModel.excerptLines(String(repeating: "x", count: 5_000), metrics: metrics) == 3)
    }

    /// The traces' own numbers: a card with no preview measured 46 pt on the
    /// real book and a three-line one measured 103 (13u2 UNIT A's TRACE 2),
    /// which is where the model's 46 + 19/line comes from.
    @Test func theModelledCardIsTheTracesOwnMeasurement() {
        let metrics = BookOutlineHeightModel.Metrics()
        #expect(BookOutlineHeightModel.modelled(.card(lines: 0), metrics: metrics) == 46)
        #expect(BookOutlineHeightModel.modelled(.card(lines: 3), metrics: metrics) == 103)
        #expect(BookOutlineHeightModel.modelled(.chapterHeading, metrics: metrics) == 51)
        // An expanded ROW is its unmeasured surface plus the header and the
        // padding around it.
        #expect(BookOutlineHeightModel.modelled(.expandedNote, metrics: metrics)
                == metrics.expandedUnknown + metrics.expandedChrome)
    }

    @Test func aCardsShapeIsItsWrappedLineCountSoOneMeasuredCardTeachesItsTwins() {
        var metrics = BookOutlineHeightModel.Metrics()
        metrics.cardCharsPerLine = 50
        let short = BookOutlineHeightModel.cardShape(
            excerpt: String(repeating: "x", count: 10), metrics: metrics)
        let alsoShort = BookOutlineHeightModel.cardShape(
            excerpt: String(repeating: "y", count: 40), metrics: metrics)
        let long = BookOutlineHeightModel.cardShape(
            excerpt: String(repeating: "x", count: 140), metrics: metrics)
        #expect(short == alsoShort)
        #expect(short != long)
    }

    // MARK: - The expanded note's estimate (lengths, never prose)

    @Test func anExpandedNoteIsEstimatedFromItsBlocksLengthsAndGrowsWithThem() {
        var metrics = BookOutlineHeightModel.Metrics()
        metrics.expandedChrome = 60
        metrics.prose = .init(charsPerLine: 80, linePitch: 20, lineSpacing: 0, paragraphGap: 7)
        func extent(_ characters: Int, newlines: Int = 1) -> Queries.BlockExtent {
            Queries.BlockExtent(
                containerID: "p", blockID: "b\(characters)-\(newlines)",
                characters: characters, newlines: newlines)
        }
        let one = BookOutlineHeightModel.expandedHeight(extents: [extent(800)], metrics: metrics)
        let two = BookOutlineHeightModel.expandedHeight(
            extents: [extent(800), extent(800, newlines: 2)], metrics: metrics)
        #expect(one > metrics.expandedEmpty)
        #expect(two > one)
        // A 215-block Sherlock story lands in the right order of magnitude —
        // thousands of points, not the 800-pt unmeasured stand-in it replaces.
        let story = (0..<215).map { extent(300 + $0 % 40) }
        let storyHeight = BookOutlineHeightModel.expandedHeight(extents: story, metrics: metrics)
        #expect(storyHeight > 15_000)
        #expect(storyHeight < 40_000)
    }

    /// The estimate answers the SURFACE's height (the row is this plus its
    /// chrome), and a note with nothing renderable is its one blank line —
    /// never zero, which would collapse the row it stands in.
    @Test func aNoteWithNothingRenderableIsOneBlankLineAndNeverZero() {
        let metrics = BookOutlineHeightModel.Metrics()
        let empty = BookOutlineHeightModel.expandedHeight(extents: [], metrics: metrics)
        let blank = BookOutlineHeightModel.expandedHeight(
            extents: [Queries.BlockExtent(containerID: "p", blockID: "b", characters: 0, newlines: 0)],
            metrics: metrics)
        #expect(empty == metrics.expandedEmpty)
        #expect(blank == metrics.expandedEmpty)
    }
}
