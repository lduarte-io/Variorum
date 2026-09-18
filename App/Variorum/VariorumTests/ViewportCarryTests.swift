//
//  ViewportCarryTests.swift
//  VariorumTests
//
//  **Phase 13u2b UNIT 3 — the pure rule, pinned from both ends.** The carry
//  is "the block's own f-point sits at the viewport's f-point"; these pins
//  hold the capture, both applies, the ROUND TRIP (capture → apply → the
//  place it started from) and every clamp the file names with its reason.
//

import CoreGraphics
import Foundation
import SwiftUI
import Testing
@testable import Variorum

@Suite("The mode-switch viewport fraction (13u2b UNIT 3)")
struct ViewportCarryTests {
    // MARK: - CAPTURE

    @Test func aBlockFlushWithTheTopIsZeroAndOneFlushWithTheBottomIsOne() {
        #expect(ViewportCarry.fraction(blockTop: 0, blockHeight: 100, viewportHeight: 800) == 0)
        #expect(ViewportCarry.fraction(blockTop: 700, blockHeight: 100, viewportHeight: 800) == 1)
    }

    @Test func aCentredBlockIsAHalfWhateverItsHeight() {
        // (800 − 100) / 2 = 350 above it; (800 − 300) / 2 = 250 above a tall one.
        #expect(ViewportCarry.fraction(blockTop: 350, blockHeight: 100, viewportHeight: 800) == 0.5)
        #expect(ViewportCarry.fraction(blockTop: 250, blockHeight: 300, viewportHeight: 800) == 0.5)
    }

    @Test func theFractionIsTheAnchorNotTheDistanceFromTheTop() {
        // A 120-pt block whose top sits 300 pt down a 800-pt viewport: the
        // distance-from-the-top reading would be 0.375; the anchor reading —
        // the one both surfaces can honour — is 300 / (800 − 120).
        let f = ViewportCarry.fraction(blockTop: 300, blockHeight: 120, viewportHeight: 800)
        #expect(f != nil)
        #expect(abs((f ?? 0) - (300.0 / 680.0)) < 1e-12)
    }

    // MARK: - APPLY (both halves) and the ROUND TRIP

    @Test func theAppKitApplyPutsTheBlockBackWhereItWas() throws {
        for top in [0.0, 37.0, 300.0, 699.0] {
            let f = ViewportCarry.fraction(blockTop: top, blockHeight: 100, viewportHeight: 800)
            let back = ViewportCarry.topInset(
                fraction: try #require(f), blockHeight: 100, viewportHeight: 800)
            #expect(abs(back - top) < 1e-9, "round trip at \(top): \(back)")
        }
    }

    @Test func theSameFractionInASurfaceWhoseBlockIsTallerLandsCloseNotExactly() throws {
        // The tolerance she pre-accepted, stated as arithmetic: a block that
        // renders 30 pt taller in the arriving surface lands at most f·30 away
        // from where it was — under a line at any fraction.
        let f = try #require(
            ViewportCarry.fraction(blockTop: 300, blockHeight: 120, viewportHeight: 800))
        let landed = ViewportCarry.topInset(fraction: f, blockHeight: 150, viewportHeight: 800)
        #expect(abs(landed - 300) <= 0.5 * 30 + 0.001, "landed at \(landed)")
        #expect(landed < 300, "a taller block lands a little higher, never lower")
    }

    @Test func theSwiftUIApplyIsTheAnchorItself() {
        #expect(ViewportCarry.anchor(0) == UnitPoint(x: 0.5, y: 0))
        #expect(ViewportCarry.anchor(0.5) == UnitPoint(x: 0.5, y: 0.5))
        #expect(ViewportCarry.anchor(1) == UnitPoint(x: 0.5, y: 1))
        // …and it can never hand SwiftUI a point outside the viewport.
        #expect(ViewportCarry.anchor(-3) == UnitPoint(x: 0.5, y: 0))
        #expect(ViewportCarry.anchor(9) == UnitPoint(x: 0.5, y: 1))
    }

    // MARK: - THE CLAMPS, each with the reason the file states

    @Test func noGeometryCarriesNothing() {
        #expect(ViewportCarry.fraction(blockTop: 10, blockHeight: 100, viewportHeight: 0) == nil)
        #expect(ViewportCarry.fraction(blockTop: 10, blockHeight: 0, viewportHeight: 800) == nil)
        #expect(ViewportCarry.fraction(
            blockTop: .nan, blockHeight: 100, viewportHeight: 800) == nil)
        #expect(ViewportCarry.fraction(
            blockTop: 10, blockHeight: 100, viewportHeight: .infinity) == nil)
    }

    @Test func aBlockWhollyOffScreenCarriesNothing() {
        // Above the fold entirely, and below it entirely: the arriving surface
        // keeps its own reveal, which at least shows her the block.
        #expect(ViewportCarry.fraction(
            blockTop: -400, blockHeight: 100, viewportHeight: 800) == nil)
        #expect(ViewportCarry.fraction(
            blockTop: 800, blockHeight: 100, viewportHeight: 800) == nil)
        // The boundary cases are still ON screen by a point.
        #expect(ViewportCarry.fraction(blockTop: -99, blockHeight: 100, viewportHeight: 800) == 0)
        #expect(ViewportCarry.fraction(blockTop: 799, blockHeight: 100, viewportHeight: 800) == 1)
    }

    @Test func aBlockPartlyOffScreenClampsToThatEdge() {
        #expect(ViewportCarry.fraction(blockTop: -40, blockHeight: 100, viewportHeight: 800) == 0)
        #expect(ViewportCarry.fraction(blockTop: 760, blockHeight: 100, viewportHeight: 800) == 1)
    }

    @Test func aBlockExactlyAsTallAsTheViewportIsAHalfBecauseEveryAnchorAgrees() {
        #expect(ViewportCarry.fraction(blockTop: 0, blockHeight: 800, viewportHeight: 800) == 0.5)
        #expect(ViewportCarry.fraction(
            blockTop: -0.4, blockHeight: 800.2, viewportHeight: 800) == 0.5)
        // And the apply moves nothing there, whatever the fraction says.
        #expect(abs(ViewportCarry.topInset(
            fraction: 0.5, blockHeight: 800, viewportHeight: 800)) < 1e-9)
    }

    @Test func aBlockTallerThanTheViewportNeedsNoSpecialCase() {
        // It covers the viewport: the top is above the fold, the bottom below.
        // 0.25 of the way through a 1,200-pt block in an 800-pt viewport.
        let f = ViewportCarry.fraction(blockTop: -100, blockHeight: 1200, viewportHeight: 800)
        #expect(abs((f ?? -1) - 0.25) < 1e-12)
        // …and the apply scrolls PAST the block's top, which is what that means.
        let inset = ViewportCarry.topInset(
            fraction: 0.25, blockHeight: 1200, viewportHeight: 800)
        #expect(abs(inset - -100) < 1e-9, "inset \(inset)")
    }
}
