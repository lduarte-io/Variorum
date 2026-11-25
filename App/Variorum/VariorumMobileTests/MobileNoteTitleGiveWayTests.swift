//
//  MobileNoteTitleGiveWayTests.swift
//  VariorumMobileTests
//
//  VM-260 batch 4b (R-260-13) — **the note's title gives way: the rule and its
//  tracker.** The rule is pure (`MobileNoteTitleGiveWay`): the title leaves once
//  the page stands past a wobble from its rest, is back within the rest, and
//  holds between the two; unlike the roots' tops an upward nudge mid-note never
//  brings it back (the title is the top of her text). The tracker publishes only
//  the flip (P3 — a scrolled frame never asks the screen's body again).
//
//  New behaviour's pins — the types did not exist before the batch, so these
//  run on the tip only (the mounted pins in `MobileNoteTopRowTests` carry the
//  red-on-old burden). Ladder round 1's R1-1 adds the leave decided on the
//  geometry after the flip (`reachAfter`, the tracker's measured title row) —
//  tip-only too (the parameter is new); its red-on-old burden is
//  `MobileNoteTopRowTests.aShortPageAtItsFootNeverUndoesItsOwnTop`.
//

import Foundation
import Observation
import Testing
import UIKit
@testable import VariorumMobile

@Suite("VM-260 4b — the note's title gives way (the rule)")
struct MobileNoteTitleGiveWayRuleTests {
    @Test func theNumbersAreTheRootsOwnSet() {
        #expect(MobileNoteTitleGiveWay.leave == MobileTopGiveWay.wobble)
        #expect(MobileNoteTitleGiveWay.rest == MobileTopGiveWay.rest)
        #expect(MobileNoteTitleGiveWay.leave == 24 && MobileNoteTitleGiveWay.rest == 8)
    }

    @Test func atRestTheTitleStays() {
        for travel: CGFloat in [0, 4, 8] {
            #expect(!MobileNoteTitleGiveWay.gone(false, travel: travel), "\(travel)")
            #expect(!MobileNoteTitleGiveWay.gone(true, travel: travel), "back at rest from gone: \(travel)")
        }
    }

    @Test func aRealScrollTakesTheTitleAway() {
        #expect(MobileNoteTitleGiveWay.gone(false, travel: 24.5))
        #expect(MobileNoteTitleGiveWay.gone(false, travel: 300))
        #expect(MobileNoteTitleGiveWay.gone(false, travel: 5_000))
    }

    @Test func betweenTheTwoNothingChanges() {
        for travel: CGFloat in [8.5, 12, 20, 24] {
            #expect(!MobileNoteTitleGiveWay.gone(false, travel: travel), "a wobble keeps the title: \(travel)")
            #expect(MobileNoteTitleGiveWay.gone(true, travel: travel), "a wobble keeps it gone: \(travel)")
        }
    }

    /// The roots re-open on an upward nudge; the note's title does not — it is
    /// the top of her text, back only with the top.
    @Test func anUpwardNudgeMidNoteNeverBringsItBack() {
        var gone = false
        for travel: CGFloat in [100, 300, 290, 260, 200, 120, 60, 25] {
            gone = MobileNoteTitleGiveWay.gone(gone, travel: travel)
            #expect(gone, "mid-note at \(travel), the title stays gone")
        }
        gone = MobileNoteTitleGiveWay.gone(gone, travel: 8)
        #expect(!gone, "at rest it is back")
    }

    /// The travel is batch 4a's clamp: a pull past the top is no travel (the
    /// title stays), a bounce past the foot is the reach (it stays gone).
    @Test func theTravelIsTheRootsClamp() {
        let pull = MobileTopGiveWay.travel(offset: -60, insetTop: 0, insetBottom: 0, content: 2_000, container: 700)
        #expect(!MobileNoteTitleGiveWay.gone(false, travel: pull))
        let bounce = MobileTopGiveWay.travel(offset: 1_400, insetTop: 0, insetBottom: 0, content: 2_000, container: 700)
        #expect(bounce == 1_300)
        #expect(MobileNoteTitleGiveWay.gone(true, travel: bounce))
    }

    // MARK: R1-1 (ladder round 1) — the leave is decided on the geometry after the flip

    /// **The reviewer's pure pin**: a page 40 pt past its rest whose whole reach
    /// is 40, under a 52 pt title row — the flip would leave it a reach of −12,
    /// so the title does not leave (it would come straight back).
    @Test func aLeaveThatWouldUndoItselfIsNotTaken() {
        #expect(MobileNoteTitleGiveWay.gone(false, travel: 40, reachAfter: 40 - 52) == false)
    }

    /// The edge is the rest: the title leaves only while the reach the page keeps
    /// stays PAST it (the rule's own "back within 8").
    @Test func theTitleLeavesOnlyWhileThePageKeepsAReachPastTheRest() {
        #expect(!MobileNoteTitleGiveWay.gone(false, travel: 40, reachAfter: MobileNoteTitleGiveWay.rest))
        #expect(MobileNoteTitleGiveWay.gone(false, travel: 40, reachAfter: MobileNoteTitleGiveWay.rest + 0.5))
        #expect(MobileNoteTitleGiveWay.gone(false, travel: 300, reachAfter: 1_948))
        // Under the wobble nothing leaves, whatever the reach.
        #expect(!MobileNoteTitleGiveWay.gone(false, travel: 20, reachAfter: 1_000))
    }

    /// The reach after the flip weighs only a LEAVE: a title already gone stays
    /// gone past the rest and returns within it, as before; and with no reading
    /// the rule is the one it was.
    @Test func theReachAfterTheFlipWeighsOnlyTheLeave() {
        #expect(MobileNoteTitleGiveWay.gone(true, travel: 40, reachAfter: -12), "gone stays gone")
        #expect(MobileNoteTitleGiveWay.gone(true, travel: 12, reachAfter: -12), "the hysteresis holds")
        #expect(!MobileNoteTitleGiveWay.gone(true, travel: 8, reachAfter: 5_000), "back at rest")
        for travel: CGFloat in [0, 8, 12, 24, 24.5, 300] {
            for wasGone in [false, true] {
                #expect(MobileNoteTitleGiveWay.gone(wasGone, travel: travel)
                        == MobileNoteTitleGiveWay.gone(wasGone, travel: travel, reachAfter: .infinity),
                        "no reading is the old rule (\(wasGone), \(travel))")
            }
        }
    }

    /// The reach is the travel's own range, batch 4a's arithmetic unchanged: the
    /// clamp's ceiling, never negative.
    @Test func theReachIsTheTravelsOwnRange() {
        #expect(MobileTopGiveWay.reach(insetTop: 0, insetBottom: 0, content: 2_000, container: 700) == 1_300)
        #expect(MobileTopGiveWay.reach(insetTop: 10, insetBottom: 30, content: 700, container: 700) == 40)
        #expect(MobileTopGiveWay.reach(insetTop: 0, insetBottom: 0, content: 300, container: 700) == 0)
        #expect(MobileTopGiveWay.travel(offset: 5_000, insetTop: 0, insetBottom: 0, content: 2_000, container: 700)
                == MobileTopGiveWay.reach(insetTop: 0, insetBottom: 0, content: 2_000, container: 700))
    }
}

@MainActor
@Suite("VM-260 4b — the note's title gives way (the tracker)", .serialized)
struct MobileNoteTitleTrackerTests {
    /// Lets the tracker's one-turn publish land.
    private func turns(_ count: Int = 10) async {
        for _ in 0..<count { await Task.yield() }
    }

    @Test func readingsPublishOnlyTheFlips() async {
        final class Count: @unchecked Sendable { var value = 0 }
        let tracker = MobileNoteTitleTracker()
        let announced = Count()
        var announcements: Int { announced.value }
        func arm() {
            withObservationTracking { _ = tracker.gone } onChange: { announced.value += 1 }
        }
        arm()
        for travel: CGFloat in [0, 4, 12, 20] { tracker.observe(travel: travel) }
        await turns()
        #expect(!tracker.gone)
        #expect(announcements == 0, "readings under the wobble announce nothing")

        tracker.observe(travel: 40)
        tracker.observe(travel: 120)
        tracker.observe(travel: 300)
        await turns()
        #expect(tracker.gone)
        #expect(announcements == 1, "one flip, one announcement")

        arm()
        tracker.observe(travel: 500)
        tracker.observe(travel: 30)
        await turns()
        #expect(tracker.gone)
        #expect(announcements == 1, "further readings while gone announce nothing")

        tracker.observe(travel: 6)
        await turns()
        #expect(!tracker.gone)
        #expect(announcements == 2, "back at rest: one announcement")
    }

    /// The tracker reads a real scroll view's offset by key-value observation —
    /// every set, programmatic or hers, reaches the rule.
    @Test func itReadsAScrollViewsOwnOffset() async {
        let scroll = UIScrollView(frame: CGRect(x: 0, y: 0, width: 402, height: 700))
        scroll.contentSize = CGSize(width: 402, height: 3_000)
        let tracker = MobileNoteTitleTracker()
        tracker.watch(scroll)
        await turns()
        #expect(!tracker.gone, "at rest")
        scroll.setContentOffset(CGPoint(x: 0, y: 300), animated: false)
        await turns()
        #expect(tracker.gone, "a scroll past the wobble takes the title")
        scroll.setContentOffset(.zero, animated: false)
        await turns()
        #expect(!tracker.gone, "back at the top it returns")
    }

    /// **R1-1 — the tracker reads the reach after the flip off the real view**:
    /// a page whose whole reach is 40 under a measured 52 pt title row keeps its
    /// title at its very foot (the flip would leave it no range); the same page
    /// before the row is measured (zero — the rule as it was) lets it go; and a
    /// long page under the same row lets it go as ever.
    @Test func aMeasuredTitleRowKeepsAShortPagesTitle() async {
        @MainActor func standsGone(content: CGFloat, titleHeight: CGFloat, at offset: CGFloat) async -> Bool {
            let scroll = UIScrollView(frame: CGRect(x: 0, y: 0, width: 402, height: 700))
            scroll.contentSize = CGSize(width: 402, height: content)
            let tracker = MobileNoteTitleTracker()
            tracker.titleHeight = titleHeight
            tracker.watch(scroll)
            await turns()
            scroll.setContentOffset(CGPoint(x: 0, y: offset), animated: false)
            await turns()
            return tracker.gone
        }
        let short = await standsGone(content: 740, titleHeight: 52, at: 40)
        let unmeasured = await standsGone(content: 740, titleHeight: 0, at: 40)
        let long = await standsGone(content: 3_000, titleHeight: 52, at: 300)
        let roomy = await standsGone(content: 770, titleHeight: 52, at: 70)
        #expect(short == false, "a reach of 40 under a 52 pt row: the title stays")
        #expect(unmeasured == true, "unmeasured, the rule as it was: the title goes")
        #expect(long == true, "a long page: the title goes as ever")
        #expect(roomy == true, "a reach of 70 keeps 18 past the flip: the title goes")
    }
}
