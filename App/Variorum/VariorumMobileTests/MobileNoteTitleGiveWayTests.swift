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
//  red-on-old burden).
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
}
