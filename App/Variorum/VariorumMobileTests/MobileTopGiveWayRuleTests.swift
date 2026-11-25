//
//  MobileTopGiveWayRuleTests.swift
//  VariorumMobileTests
//
//  VM-259 (the VM-260 run, batch 4a) — **THE GIVE-WAY RULE, its tracker, and
//  the same line on Bookcase and Starred.** The record:
//  `notes/plans/fixes/vm-260-phone-look.md`, BATCH 4a.
//
//  These pins are NEW BEHAVIOUR's, not red-on-old: the rule, the tracker and
//  the roots' test seam (`heldGiveWay`) did not exist before this batch, so
//  they cannot compile on the pre-fix tree. The Library's slim line — the
//  change she sees — is pinned red-on-old by `MobileRootTopGivesWayTests`; the
//  Bookcase's and Starred's line is the SAME line in both states (their top was
//  already one 44 pt line), so what scrolling changes there is the hairline,
//  which is the gate's captures, and what is pinnable is pinned here: the
//  scroll's own state flips with the scroll, the line stands still, and every
//  door answers across 44 × 44 in both states.
//

import Foundation
import Observation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@Suite("VM-259 — the give-way rule (pure)")
struct MobileTopGiveWayRuleTests {
    private typealias Rule = MobileTopGiveWay

    /// Walks the rule through a run of travels, from rest.
    private func walk(_ travels: [CGFloat], from start: Rule.State = .init(), holdOpen: Bool = false) -> [Bool] {
        var state = start
        return travels.map { travel in
            state = Rule.next(state, travel: travel, holdOpen: holdOpen)
            return state.slim
        }
    }

    @Test func theNumbersAreTheMockups() {
        #expect(Rule.wobble == 24)
        #expect(Rule.depth == 60)
        #expect(Rule.rest == 8)
    }

    /// At rest, and within the rest's 8 pt, the top is whole — whatever came before.
    @Test func atRestTheTopIsWhole() {
        #expect(walk([0, 4, 8]) == [false, false, false])
        let slim = Rule.State(slim: true, last: 400, run: 400)
        #expect(walk([8], from: slim) == [false], "back at the rest re-opens it")
    }

    /// A run down past the wobble condenses only once the list is past the
    /// depth: 30 pt is a run but not yet deep; 61 pt is both.
    @Test func aRealRunDownPastTheDepthCondenses() {
        #expect(walk([30, 61]) == [false, true])
        #expect(walk([300]) == [true], "one long scroll")
        #expect(walk([70, 80, 90]) == [true, true, true], "a first reading past both condenses at once")
        #expect(walk([20, 40, 61]) == [false, false, true], "the run accumulates across readings")
    }

    /// **The hysteresis** — a wobble either way never flips it: condensed at 300,
    /// 10 up, 6 down, 16 up stay condensed; a further 10 up (26 up since the
    /// turn) is a real nudge and re-opens it; re-opened, 10 down stays whole.
    @Test func aWobbleNeverFlipsIt() {
        #expect(walk([300, 290, 296, 280, 270, 280]) == [true, true, true, true, false, false])
    }

    /// Any real nudge up re-opens the top, however deep the list stands.
    @Test func aNudgeUpReopensAnywhere() {
        #expect(walk([5000, 4970]) == [true, false])
    }

    /// While the search field holds the keyboard the top stays whole, and a
    /// run down then condenses nothing.
    @Test func holdOpenKeepsTheTopWhole() {
        let slim = Rule.State(slim: true, last: 300, run: 300)
        #expect(walk([310, 500, 900], from: slim, holdOpen: true) == [false, false, false])
    }

    /// The search glyph's re-open starts a fresh run: 10 down stays whole, a
    /// real 30 condenses again.
    @Test func reopenedStartsAFreshRun() {
        let reopened = Rule.reopened(Rule.State(slim: true, last: 300, run: 300))
        #expect(!reopened.slim && reopened.run == 0 && reopened.last == 300)
        #expect(walk([310, 330], from: reopened) == [false, true])
    }

    /// **The travel** — the offset from the list's rest, clamped: a rubber-band
    /// past either end is no travel (so the bounce at the foot never re-opens
    /// the top), the insets are the rest, and a list shorter than its viewport
    /// never travels at all.
    @Test func theTravelIsClampedToTheListsRange() {
        func travel(_ offset: CGFloat, top: CGFloat = 0, bottom: CGFloat = 0,
                    content: CGFloat = 2000, container: CGFloat = 600) -> CGFloat {
            Rule.travel(offset: offset, insetTop: top, insetBottom: bottom, content: content, container: container)
        }
        #expect(travel(-40) == 0, "a pull past the top is no travel")
        #expect(travel(1400) == 1400, "the last point the list can stand at")
        #expect(travel(1480) == 1400, "a pull past the foot is no travel")
        #expect(travel(-20, top: 20) == 0, "the inset is the rest")
        #expect(travel(100, top: 20) == 120)
        #expect(travel(1450, bottom: 50) == 1450, "a bottom inset lengthens the range")
        #expect(travel(50, content: 400) == 0, "a short list never travels")
        // The bounce at the foot: condensed at the end, the overshoot and its
        // spring back read as no travel — the top stays condensed.
        let atFoot = walk([1400, travel(1470), travel(1430), travel(1400)])
        #expect(atFoot == [true, true, true, true])
    }
}

@MainActor
@Suite("VM-259 — the tracker announces only a flip")
struct MobileTopGiveWayTrackerTests {
    /// **Only a flip asks the root's body again** (P3 — a scrolled frame must
    /// not re-evaluate a root whose listing is hundreds of rows). Readings that
    /// leave the fact where it was announce nothing to an observer of `slim`;
    /// the reading that flips it announces once.
    @Test func readingsThatDoNotFlipAnnounceNothing() {
        final class Count: @unchecked Sendable { var value = 0 }
        let tracker = MobileTopGiveWayTracker()
        let announced = Count()
        func track() {
            withObservationTracking { _ = tracker.slim } onChange: { announced.value += 1 }
        }
        track()
        for travel: CGFloat in [10, 20, 30, 40, 50] { tracker.observe(travel: travel, holdOpen: false) }
        #expect(announced.value == 0, "readings under the depth announced \(announced.value) changes")
        #expect(!tracker.slim)
        tracker.observe(travel: 100, holdOpen: false)
        #expect(announced.value == 1 && tracker.slim, "the flip announced once")
        track()
        for travel: CGFloat in [120, 140, 135, 160] { tracker.observe(travel: travel, holdOpen: false) }
        #expect(announced.value == 1, "condensed, further readings announced nothing")
        tracker.reopen()
        #expect(announced.value == 2 && !tracker.slim, "the re-open announced once")
        track()
        tracker.reopen()
        #expect(announced.value == 2, "re-opening a whole top announces nothing")
    }
}

/// The deepest-content `UIScrollView` under a view — the root's list.
@MainActor
private func deepestScroll(in view: UIView) -> UIScrollView? {
    var best: UIScrollView?
    func walk(_ node: UIView) {
        if let scroll = node as? UIScrollView,
           scroll.contentSize.height > (best?.contentSize.height ?? 0) {
            best = scroll
        }
        for sub in node.subviews { walk(sub) }
    }
    walk(view)
    return best
}

@MainActor
@Suite("VM-259 — Bookcase and Starred: the same line in both states", .serialized)
struct MobileRootTopLineStatesTests {
    static let size = CGSize(width: 402, height: 874)

    private func scroll<V: View>(_ surface: HostedSurface<V>, to travel: CGFloat) async throws {
        let scroll = try #require(deepestScroll(in: surface.host.view), "the root's list")
        scroll.setContentOffset(CGPoint(x: 0, y: travel - scroll.adjustedContentInset.top), animated: false)
        await surface.settle(12)
    }

    /// The line's doors, by name: each a button, 44 × 44, on the wing door's line.
    private func lineFrames<V: View>(
        _ labels: [String], on surface: HostedSurface<V>, _ moment: String,
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws -> [String: CGRect] {
        var frames: [String: CGRect] = [:]
        for label in [WingWords.home] + labels {
            let found = surface.visibleElements.filter {
                $0.accessibilityLabel == label && $0.accessibilityTraits.contains(.button)
            }
            #expect(found.count == 1, "\(moment): one \(label) door, not \(found.count) — \(surface.visibleLabels)",
                    sourceLocation: sourceLocation)
            let frame = try #require(found.first?.accessibilityFrame, sourceLocation: sourceLocation)
            #expect(frame.width >= 43.5 && frame.height >= 43.5, "\(moment): \(label) answers across 44 × 44: \(frame)",
                    sourceLocation: sourceLocation)
            frames[label] = frame
        }
        for (label, frame) in frames where label != WingWords.home {
            #expect(abs(frame.midY - frames[WingWords.home]!.midY) <= 2,
                    "\(moment): \(label) is off the wing door's line", sourceLocation: sourceLocation)
        }
        return frames
    }

    /// Condensed and whole, the line's frames agree to the half point — the
    /// line never grows, shrinks or moves as the list scrolls under it.
    private func expectStill(_ rest: [String: CGRect], _ other: [String: CGRect], _ moment: String) {
        for (label, frame) in rest {
            guard let moved = other[label] else { continue }
            #expect(abs(moved.minY - frame.minY) <= 0.5 && abs(moved.minX - frame.minX) <= 0.5
                        && abs(moved.height - frame.height) <= 0.5,
                    "\(moment): \(label) moved from \(frame) to \(moved)")
        }
    }

    /// **Starred** — forty starred notes: the list's scroll condenses the line
    /// (the scroll's own state, read through the seam) and a nudge re-opens it;
    /// the wing door and the gear answer across 44 × 44 in both states, and
    /// the line stands still.
    @Test func starredsLineStandsStillAndAnswersInBothStates() async throws {
        try await withEditorWorld { session, _ in
            try await session.runner.run { ops in
                for index in 0..<40 {
                    let post = try ops.createPost(title: String(format: "Starred %02d", index))
                    try ops.setStarred(.post(post.id), starred: true)
                }
            }
            let stars = MobileStarsModel(session: session)
            let observing = Task { await stars.start() }
            defer { observing.cancel() }
            let tracker = MobileTopGiveWayTracker()
            try await withHostedSurface(
                MobileStarredView(
                    stars: stars, tokens: .studyLight, wingName: WingWords.home, onWingDoor: {},
                    tabBar: { EmptyView() }, onOpen: { _ in }, heldGiveWay: tracker)
                    .environment(\.mobileSettingsDoor, MobileSettingsDoor {}),
                size: Self.size
            ) { surface in
                await surface.settle(40)
                #expect(!tracker.slim, "at rest the line is whole")
                let rest = try lineFrames([MobileSettingsGear.spokenLabel], on: surface, "at rest")
                try await scroll(surface, to: 300)
                #expect(tracker.slim, "300 pt down, the line is the slim line")
                let slim = try lineFrames([MobileSettingsGear.spokenLabel], on: surface, "slim")
                expectStill(rest, slim, "slim")
                try await scroll(surface, to: 260)
                #expect(!tracker.slim, "a 40 pt nudge up re-opens it")
            }
        }
    }

    /// **The Bookcase** — thirty books, so the bounded books region scrolls:
    /// its scroll condenses the line and a nudge re-opens it; the wing door, New
    /// Note and the gear answer across 44 × 44 in both states; the line stands
    /// still; and no count is drawn under the name (R-260-11).
    @Test func theBookcasesLineStandsStillAndAnswersInBothStates() async throws {
        try await withEditorWorld { session, _ in
            for index in 0..<30 {
                _ = try await session.runner.run { ops in
                    try ops.createReading(name: String(format: "Volume %02d", index), kind: .book)
                }
            }
            let tracker = MobileTopGiveWayTracker()
            try await withHostedSurface(
                MobileShelfView(
                    model: MobileShelfViewModel(session: session),
                    stars: MobileStarsModel(session: session),
                    quickNote: MobileQuickNoteModel(session: session),
                    tokens: .terminalLight, wingName: WingWords.home, onWingDoor: {}, tabBar: { EmptyView() },
                    onOpenBook: { _ in }, onOpenForWriting: { _ in }, heldGiveWay: tracker)
                    .environment(\.mobileSettingsDoor, MobileSettingsDoor {}),
                size: Self.size
            ) { surface in
                await surface.settle(40)
                #expect(!tracker.slim, "at rest the line is whole")
                let doors = [MobileNewNoteDoor.spokenName, MobileSettingsGear.spokenLabel]
                let rest = try lineFrames(doors, on: surface, "at rest")
                try await scroll(surface, to: 300)
                #expect(tracker.slim, "300 pt down the books, the line is the slim line")
                let slim = try lineFrames(doors, on: surface, "slim")
                expectStill(rest, slim, "slim")
                try await scroll(surface, to: 260)
                #expect(!tracker.slim, "a 40 pt nudge up re-opens it")
                let wing = try #require(surface.visibleElements.first {
                    $0.accessibilityLabel == WingWords.home && $0.accessibilityTraits.contains(.button)
                })
                #expect((wing.accessibilityValue ?? "") == "", "no count under the name (R-260-11)")
            }
        }
    }
}
