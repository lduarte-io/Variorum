//
//  ComfortBandAndFlashTests.swift
//  VariorumTests
//
//  **18l-c UNIT U8 — the two pure brains of the mode switch's feel**: the
//  COMFORT BAND (`Surface/ComfortBand.swift` — her *"an offset from the top /
//  bottom of the screen so a user isn't navigating to a different mode and
//  their text is on the extreme top or bottom"*) and the ARRIVAL FLASH's curve
//  (`Surface/ArrivalFlash.swift` — her *"a temporary highlight … on the line
//  your cursor is on after the transition. lasting a brief instant"*). Every
//  number is handed in, so the three arms the brief names — the top clamp,
//  the bottom clamp, mid-band EXACT — are arithmetic, and the surfaces' hosted
//  pins (`ModeSwitchFeelTests`) only have to show that each surface asks.
//

import CoreGraphics
import Foundation
import Testing
@testable import Variorum

@Suite("18l-c U8 — the comfort band and the flash's curve, pure")
struct ComfortBandAndFlashTests {
    /// A 700-pt viewport, the Takes article's 18-pt top air, two 17-pt lines.
    private let band = ComfortBand(topAir: 18, lineHeight: 17)

    // MARK: - The band: the named constant and its two edges

    @Test func theBandIsTheSurfacesTopAirAndTwoOfItsLines() {
        #expect(ComfortBand.bottomLines == 2, "the roster's 'about two lines' — ONE named constant")
        #expect(band.topAir == 18)
        #expect(band.bottomRoom == 34)
        #expect(ComfortBand(topAir: -3, bottomRoom: -1) == ComfortBand(topAir: 0, bottomRoom: 0),
                "no negative room")
    }

    // MARK: - The three arms (top clamp · bottom clamp · mid-band exact)

    @Test func theTopClampRestsATargetAtTheSurfacesTopAirNeverAtTheEdge() {
        // A reveal's shipped "line at the top" (0), a top in the air (7), and
        // one above the viewport (-40): all rest at the top air.
        #expect(band.clamp(top: 0, height: 17, viewport: 700) == 18)
        #expect(band.clamp(top: 7, height: 17, viewport: 700) == 18)
        #expect(band.clamp(top: -40, height: 60, viewport: 700) == 18)
    }

    @Test func theBottomClampKeepsTwoLinesOfRoomUnderTheTarget() {
        // The shipped foot reveal (the row's bottom AT the viewport's bottom),
        // a row half off the bottom, and a line one point in the room.
        #expect(band.clamp(top: 640, height: 60, viewport: 700) == 606, "700 − 34 − 60")
        #expect(band.clamp(top: 670, height: 60, viewport: 700) == 606)
        #expect(band.clamp(top: 650, height: 17, viewport: 700) == 649, "700 − 34 − 17")
    }

    @Test func aTargetMidBandStaysExactlyWhereItIs() {
        for top in stride(from: CGFloat(18), through: 606, by: 49.5) {
            #expect(band.clamp(top: top, height: 60, viewport: 700) == top,
                    "mid-band is EXACT: \(top)")
        }
        // …and in fraction space (the ruled carries): an interior fraction
        // comes back bit-for-bit.
        for fraction in [0.05, 0.25, 0.5, 0.6667, 0.9] {
            #expect(band.clamp(fraction: fraction, height: 60, viewport: 700) == fraction,
                    "a mid-band carry stays EXACT: \(fraction)")
        }
    }

    @Test func theFractionClampMovesOnlyTheExtremeCarries() {
        // f = 0 (flush with the top) → the top air: 18 / (700 − 60).
        let top = band.clamp(fraction: 0, height: 60, viewport: 700)
        #expect(abs(top - 18.0 / 640.0) < 1e-12)
        // f = 1 (flush with the bottom) → 34 pt of room: (640 − 34) / 640.
        let bottom = band.clamp(fraction: 1, height: 60, viewport: 700)
        #expect(abs(bottom - 606.0 / 640.0) < 1e-12)
    }

    @Test func aTargetTallerThanTheBandKeepsItsResolvedPlace() {
        // 700 − 18 − 34 = 648: a 660-pt block does not fit — the carry's
        // tall-block rule and R-Q1's tall-row rule stand (the named boundary).
        #expect(!band.fits(height: 660, viewport: 700))
        #expect(band.clamp(top: -300, height: 660, viewport: 700) == -300)
        #expect(band.clamp(fraction: 0.5, height: 900, viewport: 700) == 0.5)
        #expect(band.fits(height: 648, viewport: 700))
        #expect(!band.fits(height: 10, viewport: 0), "no viewport, no band")
    }

    // MARK: - The Takes article's minimal reveal, banded

    @Test func theBandedRevealIsHomeExactlyInsideTheBand() {
        let at = { (y: CGFloat) in CGRect(x: 0, y: y, width: 680, height: 60) }
        #expect(band.revealDecision(rowFrame: at(300), viewport: 700) == .none)
        #expect(band.revealResidual(rowFrame: at(300), viewport: 700) == 0)
        #expect(band.revealDecision(rowFrame: at(18), viewport: 700) == .none, "the top edge is home")
        #expect(band.revealDecision(rowFrame: at(606), viewport: 700) == .none, "the bottom edge is home")
        // R-Q1's own "fully on screen" rows that the band moves: flush at the
        // top (row 94's shape) and flush at the bottom.
        #expect(band.revealResidual(rowFrame: at(0), viewport: 700) == -18, "18 pt up")
        #expect(band.revealResidual(rowFrame: at(640), viewport: 700) == 34, "34 pt down")
        #expect(band.revealDecision(rowFrame: nil, viewport: 700) == .reveal, "unrealized reveals")
        // Half a point of slack: one rule with the article policy's tolerance.
        #expect(band.revealResidual(rowFrame: at(17.6), viewport: 700) == 0)
        // A row too tall for the band keeps R-Q1's rule (its top on screen).
        let tall = CGRect(x: 0, y: 40, width: 680, height: 900)
        #expect(band.revealResidual(rowFrame: tall, viewport: 700)
                == LandingAim.MinimalReveal.residual(rowFrame: tall, viewportHeight: 700))
    }

    @Test func theBandedAnchorRestsTheRowAtTheBandsEdge() throws {
        // `scrollTo(anchor: y)` puts the row's top at y · (V − h).
        let head = try #require(band.revealAnchorY(.head, rowHeight: 60, viewport: 700))
        #expect(abs(head * 640 - 18) < 1e-9, "head: the row's top at the top air")
        let foot = try #require(band.revealAnchorY(.foot, rowHeight: 60, viewport: 700))
        #expect(abs(foot * 640 + 60 - (700 - 34)) < 1e-9, "foot: two lines under the row")
        #expect(band.revealAnchorY(.foot, rowHeight: 690, viewport: 700) == nil,
                "a row too tall for the band keeps the shipped edge anchor")
    }

    // MARK: - The flash's curve

    @Test func theFlashHoldsThenFadesByOpacityAloneInAboutASecond() {
        #expect(ArrivalFlash.holdSeconds == 0.3, "the roster's ≈ 0.3 s hold — a NAMED constant")
        #expect(ArrivalFlash.fadeSeconds == 0.8, "the roster's ≈ 0.7–0.9 s fade — a NAMED constant")
        let plan = ArrivalFlash.plan(reduceMotion: false)
        #expect(plan.animated && abs(plan.total - 1.1) < 1e-9)
        #expect(plan.opacity(at: -0.01) == 0, "nothing before it begins")
        #expect(plan.opacity(at: 0) == 1 && plan.opacity(at: 0.29) == 1, "held at full strength")
        #expect(abs(plan.opacity(at: 0.7) - 0.5) < 1e-9, "half way down at the fade's midpoint")
        #expect(plan.opacity(at: 0.5) > plan.opacity(at: 0.9), "monotonic fade")
        #expect(plan.opacity(at: 1.1) == 0 && plan.opacity(at: 5) == 0, "gone at total")
    }

    @Test func reduceMotionIsTheDiscreetUnanimatedVariant() {
        let plan = ArrivalFlash.plan(reduceMotion: true)
        #expect(!plan.animated)
        #expect(plan.total == ArrivalFlash.holdSeconds + ArrivalFlash.fadeSeconds,
                "the same time on screen")
        for t in [0.0, 0.3, 0.7, 1.09] {
            #expect(plan.opacity(at: t) == 1, "no fade — nothing changes on its own (\(t))")
        }
        #expect(plan.opacity(at: 1.1) == 0, "then it goes")
    }
}
