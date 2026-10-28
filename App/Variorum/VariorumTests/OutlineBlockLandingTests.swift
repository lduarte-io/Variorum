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
}
