//
//  LandingAimTests.swift
//  VariorumTests
//
//  **18l-b UNIT U2 — the AIM KIND, pinned without a window.** The authority
//  converges ONE number to zero: the target's distance from where its landing
//  puts it. Three surfaces answer "where" three ways, so the policy says which
//  (`LandingPolicy.aim`) and `Surface/LandingAim.swift` holds the three
//  arithmetics. Two of them were HOISTED there from their surfaces (note
//  Read's fraction residual, the Takes article's reveal) — that half is a
//  MOVE, and its proof is the old pins riding unmodified
//  (`ReadNoteLandingArithmeticTests`, `TakesArticleScrollTests`); what this
//  file pins is what is NEW: the kind as data, the one dispatcher, the
//  minimal-reveal kind's residual (the reveal decision restated as the number
//  the authority converges), and the one vocabulary door.
//
//  These are new-API pins (the compile-red class on the pre-U2 tree: none of
//  these names exist there).
//

import CoreGraphics
import Foundation
import SwiftUI
import Testing
@testable import Variorum

@Suite("The landing aim kind (18l-b U2)")
struct LandingAimTests {
    /// **The kinds are the shipped aims, stated as data.** The three book
    /// adopters aim `scrollTo(id, anchor: .top)`; note Read's faces rest a
    /// block at a viewport fraction; the takes article reveals minimally.
    /// Nothing about where any of them PUTS a block moved (that is product).
    @Test func everyShippedPolicyNamesTheAimItAlreadyHad() {
        #expect(LandingPolicy.bookOutline.aim == .top)
        #expect(LandingPolicy.readingFlow.aim == .top)
        #expect(LandingPolicy.bookIndex.aim == .top)
        #expect(LandingPolicy.readNote.aim == .viewportFraction)
        #expect(LandingPolicy.readNoteEdit.aim == .viewportFraction)
        #expect(LandingAimKind.allCases.count == 3,
                "top · minimal-reveal · viewport-fraction — the charter's three")
    }

    /// **One vocabulary door** (`ViewportCarry.anchor`): a fraction becomes a
    /// `UnitPoint` there and nowhere else — and the reveal's two edges are the
    /// exact `.top` / `.bottom` values the Takes article always passed.
    @Test func theVocabularyIsViewportCarrysAnchor() {
        for f in [-1.0, 0, 0.08, 0.5, 1, 3] {
            #expect(LandingAim.anchor(fraction: f) == ViewportCarry.anchor(f))
        }
        #expect(LandingAim.MinimalReveal.anchor(.head) == UnitPoint.top)
        #expect(LandingAim.MinimalReveal.anchor(.foot) == UnitPoint.bottom)
    }

    /// **The minimal-reveal kind's residual IS the reveal decision** — 0
    /// exactly when the decision says the row is on screen, and otherwise a
    /// signed distance larger than the decision's half-point slack, so the
    /// policy's 0.5 tolerance and "on screen" are one statement. Swept over a
    /// grid of short and tall rows around both edges.
    @Test func theRevealResidualIsZeroExactlyWhenTheDecisionSaysOnScreen() {
        let viewport: CGFloat = 700
        var disagreements: [String] = []
        var onScreen = 0, offScreen = 0
        for height in [CGFloat(40), 60, 300, 699.6, 700, 900] {
            for top in stride(from: CGFloat(-1000), through: 1000, by: 0.25) {
                let frame = CGRect(x: 0, y: top, width: 680, height: height)
                let decision = LandingAim.MinimalReveal.decision(rowFrame: frame, viewportHeight: viewport)
                let residual = LandingAim.MinimalReveal.residual(rowFrame: frame, viewportHeight: viewport)
                if decision == .none {
                    onScreen += 1
                    if residual != 0 { disagreements.append("on screen, residual \(residual) (top \(top), h \(height))") }
                } else {
                    offScreen += 1
                    if abs(residual) <= 0.5 { disagreements.append("off screen, residual \(residual) (top \(top), h \(height))") }
                }
            }
        }
        #expect(onScreen > 0 && offScreen > 0, "non-vacuity: the sweep crossed both edges")
        #expect(disagreements.isEmpty, "\(disagreements.prefix(8))")
        // The signs: above the fold ⇒ negative (the page scrolls UP to the
        // head); below ⇒ positive (DOWN to the foot); the magnitudes are the
        // minimal scrolls.
        let above = CGRect(x: 0, y: -80, width: 680, height: 60)
        #expect(LandingAim.MinimalReveal.residual(rowFrame: above, viewportHeight: viewport) == -80)
        let below = CGRect(x: 0, y: 680, width: 680, height: 60)
        #expect(LandingAim.MinimalReveal.residual(rowFrame: below, viewportHeight: viewport) == 40,
                "its bottom 40 pt past the foot")
        let tallBelow = CGRect(x: 0, y: 750, width: 680, height: 900)
        #expect(LandingAim.MinimalReveal.residual(rowFrame: tallBelow, viewportHeight: viewport) == 750,
                "a tall row is revealed by its top (the decision's own tall-row rule)")
    }

    /// **The ONE dispatcher** answers per kind from one sighting — and says
    /// "unknown" (nil) when the row is not realized or the viewport not yet
    /// measured, which the authority reads as unreported.
    @Test func theDispatcherAnswersPerKindAndSaysUnknownHonestly() {
        let row = CGRect(x: 0, y: 330, width: 680, height: 100)
        var sighting = LandingAim.Sighting(rowFrame: row, viewportHeight: 700)
        #expect(LandingAim.residual(.top, sighting) == 330, "the row's top IS the top kind's residual")
        #expect(LandingAim.residual(.minimalReveal, sighting) == 0, "fully on screen ⇒ home")
        sighting.fraction = 0.5
        sighting.offset = 500
        sighting.maxOffset = 5000
        #expect(LandingAim.residual(.viewportFraction, sighting)
                == LandingAim.ViewportFraction.residual(
                    blockTop: 330, blockHeight: 100, viewportHeight: 700, anchorY: 0.5,
                    offset: 500, minOffset: 0, maxOffset: 5000),
                "the fraction arm is the hoisted arithmetic, nothing else")
        #expect(LandingAim.residual(.viewportFraction, sighting) == 30, "(700 − 100)·0.5 = 300 ⇒ 30 below home")
        for kind in LandingAimKind.allCases {
            #expect(LandingAim.residual(kind, .init(rowFrame: nil, viewportHeight: 700)) == nil,
                    "\(kind): a row not realized is unreported")
            #expect(LandingAim.residual(kind, .init(rowFrame: row, viewportHeight: 0)) == nil,
                    "\(kind): a viewport not measured decides nothing")
        }
    }

    /// **The hoist is a MOVE — the old names ARE the new types** (the 3C
    /// parity pattern's address proof; the behaviour proof is the old pins
    /// riding unmodified).
    @Test func theOldNamesAreTheHoistedTypes() {
        #expect(ReadLandingResidual.self == LandingAim.ViewportFraction.self)
        #expect(TakesBoardLayout.ArticleReveal.self == LandingAim.MinimalReveal.Decision.self)
        #expect(TakesBoardLayout.ArticleRevealAim.self == LandingAim.MinimalReveal.Edge.self)
        let frame = CGRect(x: 0, y: 900, width: 680, height: 60)
        #expect(TakesBoardLayout.revealDecision(rowFrame: frame, viewportHeight: 700)
                == LandingAim.MinimalReveal.decision(rowFrame: frame, viewportHeight: 700))
        #expect(TakesBoardLayout.revealAnchor(
            for: "far", rowFrame: nil, order: ["a", "far"], realizedRows: ["a"])
                == LandingAim.MinimalReveal.edge(
                    for: "far", rowFrame: nil, order: ["a", "far"], realizedRows: ["a"]))
    }
}
