//
//  TakesPagerAfterCloseTests.swift
//  VariorumTests
//
//  VX-638 (Run VX-770, batch 5) — A FAN THAT CLOSES TAKES ITS PAGE WITH IT.
//  The sighting (the VX-601 batch B walk, O-BW-2): slot split, a 3-take
//  block's split paged with ▶ to "2–3 of 3"; close all; expand all → the
//  split read "2–3 of 3" while showing cards 1–2; a mode round trip read
//  "1–2 of 3" over the same cards.
//
//  The traced mechanism (`notes/plans/fixes/vx-770-takes-compare-window.md`,
//  BATCH 5 › C): the pager's caption is a pure function of the layout's
//  per-key page table (`TakesBoardLayout.pageOffsets`, keyed by the block for
//  slot split and carousel, `rail-<block>` for the margin grid), while the
//  cards are wherever the strip's own `ScrollView` sits. Every strip mounts
//  only while its block is bloomed, so a close tears it down and a re-open
//  builds a NEW strip, born at its leading edge — but nothing in close all
//  (or a fan's own close) touched the page table, so the re-born strip's
//  caption read the old page. A mode round trip builds a fresh layout (an
//  empty table) — hence "corrected".
//
//  Pure state transitions on the layout (no mount): RED on the pre-fix tree
//  on each "back to page 1" line (the old page survives the close);
//  PREDICTED (this batch is headless). The guards are green on both trees.
//

import Foundation
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("A fan that closes takes its page with it (VX-638)")
struct TakesPagerAfterCloseTests {
    /// Her road: a 3-take split paged to "2–3 of 3" (offset 1 of limit 1),
    /// close all, expand all → the split starts at page 1 again, its caption
    /// "1–2 of 3" over the re-born strip's cards 1–2.
    @Test func closeAllThenExpandAllStartsTheSplitAtItsFirstPage() {
        let layout = TakesBoardLayout()
        layout.expandAll(fannedBlockIDs: ["a", "b"])
        layout.stepPage("a", by: 1, limit: 1)
        #expect(layout.pageOffset("a", limit: 1) == 1, "premise: the split paged to 2–3 of 3")

        layout.closeAllFans()
        layout.expandAll(fannedBlockIDs: ["a", "b"])
        #expect(layout.pageOffset("a", limit: 1) == 0,
                "the re-opened split is a new strip at its leading edge — its caption says 1–2 of 3")
    }

    /// The same for the margin grid's rail (its own key) and the carousel
    /// (the block's key) — every strip that mounts only while bloomed.
    @Test func closeAllForgetsTheRailsPageToo() {
        let layout = TakesBoardLayout()
        layout.expandAll(fannedBlockIDs: ["a"])
        let rail = TakesBoardLayout.railPageKey("a")
        layout.setPage(rail, to: 2, limit: 3)
        #expect(layout.pageOffset(rail, limit: 3) == 2, "premise: the rail paged")
        layout.closeAllFans()
        layout.expandAll(fannedBlockIDs: ["a"])
        #expect(layout.pageOffset(rail, limit: 3) == 0, "the re-opened rail starts at its first column")
    }

    /// A fan's OWN close (the ⑂ toggle, the split's close line) — the same
    /// teardown, the same rule; another open fan's page is untouched.
    @Test func closingOneFanForgetsOnlyItsOwnPage() {
        let layout = TakesBoardLayout()
        layout.expandAll(fannedBlockIDs: ["a", "b"])
        layout.stepPage("a", by: 1, limit: 1)
        layout.stepPage("b", by: 1, limit: 1)

        layout.toggleExpanded("a")  // close a
        #expect(layout.pageOffset("b", limit: 1) == 1, "GUARD: b stays open, its page stays")
        layout.toggleExpanded("a")  // re-open a
        #expect(layout.pageOffset("a", limit: 1) == 0, "a's re-born strip starts at page 1")
    }

    /// A fan that collapses to one take closes (VX-733's door) — its page
    /// goes with it, so a fan that grows back pages from 1.
    @Test func aCollapsedFanForgetsItsPage() {
        let layout = TakesBoardLayout()
        layout.expandAll(fannedBlockIDs: ["a"])
        layout.stepPage("a", by: 1, limit: 1)
        layout.closeCollapsedFans(["a"])
        layout.bloom("a")
        #expect(layout.pageOffset("a", limit: 1) == 0)
    }

    /// **RED ON OLD — the ladder's round 1, F2: the collapse door forgets
    /// even while the row is on screen.** Follow-the-scroll's bloom (R25)
    /// holds a block that is fanned AND on screen; a collapsed fan holds one
    /// take, so the scroll's arm no longer holds it — its strip unmounts with
    /// the close whether or not the row is visible, and a fan that grows back
    /// (⇧⌥⌘Z re-adding the takes, a new second take) re-blooms as a NEW strip
    /// born at its leading edge. The old rule kept a visible block's page on
    /// every close door, so that strip's caption read the page its
    /// predecessor left. The visibility exception is the hand-close doors'
    /// only (their block still holds its fan, so the scroll keeps the strip —
    /// `aFanFollowTheScrollKeepsBloomedKeepsItsPage`).
    @Test func aCollapsedFanForgetsItsPageEvenWhileFollowTheScrollShowsItsRow() {
        let layout = TakesBoardLayout()
        layout.followTheScroll = true
        layout.rowAppeared("a")
        layout.expandAll(fannedBlockIDs: ["a"])
        let rail = TakesBoardLayout.railPageKey("a")
        layout.stepPage("a", by: 1, limit: 1)
        layout.setPage(rail, to: 2, limit: 3)
        #expect(layout.isRowVisible("a"), "premise: the row is on screen")
        #expect(layout.pageOffset("a", limit: 1) == 1 && layout.pageOffset(rail, limit: 3) == 2,
                "premise: the split and the rail are paged")

        layout.closeCollapsedFans(["a"])
        #expect(!layout.expandedBlocks.contains("a"), "premise: the collapse closed it")
        #expect(layout.pageOffset("a", limit: 1) == 0,
                "a collapsed fan's split page goes with it, on screen or not")
        #expect(layout.pageOffset(rail, limit: 3) == 0,
                "…and its rail's page too")
    }

    /// GUARD — a page on a fan that stays open is the strip's live state:
    /// paging, an unrelated expand all, nothing else resets it.
    @Test func aFanThatStaysOpenKeepsItsPage() {
        let layout = TakesBoardLayout()
        layout.expandAll(fannedBlockIDs: ["a"])
        layout.stepPage("a", by: 1, limit: 1)
        layout.expandAll(fannedBlockIDs: ["a", "b"])  // a new fan joins; a never closed
        #expect(layout.pageOffset("a", limit: 1) == 1)
    }

    /// GUARD — under follow-the-scroll a closed block that is ON SCREEN stays
    /// bloomed (R25), so its strip never unmounts and its page is still its
    /// strip's: close all must not reset it (that would make the caption lie
    /// the other way).
    @Test func aFanFollowTheScrollKeepsBloomedKeepsItsPage() {
        let layout = TakesBoardLayout()
        layout.followTheScroll = true
        layout.rowAppeared("a")
        layout.expandAll(fannedBlockIDs: ["a"])
        layout.stepPage("a", by: 1, limit: 1)
        layout.closeAllFans()
        #expect(layout.pageOffset("a", limit: 1) == 1,
                "a is still bloomed by the scroll — its strip and page stand")
    }
}
