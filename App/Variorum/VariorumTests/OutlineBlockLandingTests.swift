//
//  OutlineBlockLandingTests.swift
//  VariorumTests
//
//  VX-680 — Index → Outline lands block-precise: the PURE halves of the
//  block landing's home (`OutlineBlockLanding`), table-tested without a
//  window. The model's park and the mounted arrival live beside VX-630's
//  carry suites (`BookNoteBoxDoorsTests.swift`).
//

import CoreGraphics
import Testing
@testable import Variorum

@Suite("VX-680 — the block landing's home, pure")
struct OutlineBlockLandingTests {
    private let block = CGRect(x: 0, y: 1_800, width: 640, height: 120)

    /// **What the reveal brings into view**: the block when it fits the page;
    /// a block TALLER than the page reveals her caret's line inside it
    /// (PROVISIONAL P-680-1), else its top, one page tall.
    @Test func theTargetIsTheBlockOrInATallBlockHerCaretsLine() {
        #expect(OutlineBlockLanding.revealTarget(block: block, caretLine: nil, viewportHeight: 700) == block,
                "a block that fits the page is the target, whole")
        #expect(OutlineBlockLanding.revealTarget(
            block: block, caretLine: CGRect(x: 0, y: 1_840, width: 640, height: 22), viewportHeight: 700) == block,
                "…its caret line does not matter while the block fits")
        let tall = CGRect(x: 0, y: 1_800, width: 640, height: 2_000)
        let caret = CGRect(x: 0, y: 3_100, width: 640, height: 22)
        #expect(OutlineBlockLanding.revealTarget(block: tall, caretLine: caret, viewportHeight: 700) == caret,
                "a block taller than the page: her caret's line")
        #expect(OutlineBlockLanding.revealTarget(block: tall, caretLine: nil, viewportHeight: 700)
                == CGRect(x: 0, y: 1_800, width: 640, height: 700),
                "no caret line in hand: the block's top, one page tall")
        #expect(OutlineBlockLanding.revealTarget(
            block: tall, caretLine: CGRect(x: 0, y: 500, width: 640, height: 22), viewportHeight: 700)
                == CGRect(x: 0, y: 1_800, width: 640, height: 700),
                "a caret line outside the block is not the block's: its top")
        #expect(OutlineBlockLanding.revealTarget(block: tall, caretLine: caret, viewportHeight: 0) == tall,
                "an unmeasured page decides nothing: the block")
    }

    /// **The landing's number is the minimal reveal's residual** (her R-Q1
    /// through `LandingAim.MinimalReveal` — the Takes article's own rule): 0
    /// while the target is wholly on the page, never a forced top; below the
    /// page, how far its bottom sits past the foot; above, its top.
    @Test func theResidualIsTheMinimalReveal() {
        #expect(OutlineBlockLanding.residual(targetTop: 300, targetHeight: 120, viewportHeight: 700) == 0,
                "wholly on the page: home — the page does not move")
        #expect(OutlineBlockLanding.residual(targetTop: 0, targetHeight: 700, viewportHeight: 700) == 0,
                "flush with both edges: home")
        #expect(OutlineBlockLanding.residual(targetTop: 1_100, targetHeight: 120, viewportHeight: 700) == 520,
                "below the page: its bottom to the foot (1220 − 700) — the minimum, never the top")
        #expect(OutlineBlockLanding.residual(targetTop: 650, targetHeight: 120, viewportHeight: 700) == 70,
                "clipped at the foot: just enough to show it")
        #expect(OutlineBlockLanding.residual(targetTop: -300, targetHeight: 120, viewportHeight: 700) == -300,
                "above the page: its top to the head")
        #expect(OutlineBlockLanding.residual(targetTop: 900, targetHeight: 1_000, viewportHeight: 700) == 900,
                "a target taller than the page: its top to the head")
    }

    /// **The row first** (P-680-2(a)'s "the row first, the block within about
    /// a second"; the VX-677 dispositions record, D-2 — anomaly B): while the
    /// target would be wholly on the page with the note's ROW at the page's
    /// top, the landing's home is the row's top (its drift corrected, as every
    /// Outline landing's is); only a target that would not fit below the row
    /// homes on its own minimal reveal. Every value is bound to a local before
    /// an `#expect` reads it (VX-692).
    ///
    /// RED ON OLD (`vx677-b2/revB` — the rule answering "never the row", the
    /// as-built hand-over): the four "the row's top" lines.
    @Test func theRowComesFirstWhileTheBlockFitsBelowIt() {
        let page: CGFloat = 774
        // The guard's own shape (vx677-b2 post61: `block-home residual=0
        // row-top=97`): block 2 sits ~130 pt below its row's top, the row was
        // knocked 97 pt down by a content clamp, and the block is still on the
        // page — so the minimal reveal alone called it home and the row stayed
        // 97 pt low. With the row at the top it fits: the home is the row's top.
        let knockedDown = OutlineBlockLanding.homeIsTheRow(
            targetTop: 227, targetHeight: 70, rowTop: 97, viewportHeight: page)
        #expect(knockedDown, "the guard's shape: the row's top is the home — the 97 pt is corrected")
        let atHome = OutlineBlockLanding.homeIsTheRow(
            targetTop: 130, targetHeight: 70, rowTop: 0, viewportHeight: page)
        #expect(atHome, "the row at the top, the block below it on the page: home is the row (nothing moves)")
        let flushAtTheFoot = OutlineBlockLanding.homeIsTheRow(
            targetTop: 674, targetHeight: 100, rowTop: 0, viewportHeight: page)
        #expect(flushAtTheFoot, "the block's bottom exactly at the foot with the row at the top still fits")
        // Where the block sits inside the row decides — never where the page
        // stands: the same row and block scrolled 497 pt answer the same.
        let scrolled = OutlineBlockLanding.homeIsTheRow(
            targetTop: 227 - 497, targetHeight: 70, rowTop: 97 - 497, viewportHeight: page)
        #expect(scrolled, "a scroll never flips which home applies (the act cannot oscillate)")

        // A block that would NOT fit below the row homes on its own minimal
        // reveal — VX-680 as built (the far block's `residual=1660`).
        let pastTheFoot = OutlineBlockLanding.homeIsTheRow(
            targetTop: 675, targetHeight: 100, rowTop: 0, viewportHeight: page)
        #expect(!pastTheFoot, "one point past the foot with the row at the top: the block's own reveal")
        let farBlock = OutlineBlockLanding.homeIsTheRow(
            targetTop: 2_360, targetHeight: 74, rowTop: 97, viewportHeight: page)
        #expect(!farBlock, "the far block (2,263 pt below its row): the block's minimal reveal")
        let deepButVisible = OutlineBlockLanding.homeIsTheRow(
            targetTop: 300, targetHeight: 50, rowTop: -500, viewportHeight: page)
        #expect(!deepButVisible,
                "a block on the page only because the page stands deep in the note: its own reveal (residual 0 — nothing moves)")
        let farResidual = OutlineBlockLanding.residual(targetTop: 2_360, targetHeight: 74, viewportHeight: page)
        #expect(farResidual == 1_660, "…and that reveal's number is byte-unchanged (2,434 − 774)")
    }
}
