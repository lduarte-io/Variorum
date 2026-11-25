//
//  MobileKeyboardFloorTests.swift
//  VariorumMobileTests
//
//  VM-260 F-1a-W1 (the batch-1a walk's s9) — **THE BAND'S FOOT NEVER STANDS
//  BELOW THE KEYBOARD.** The defect itself — the band's SwiftUI keyboard
//  avoidance coming out 52 pt short on the keyboard after a note's, whose
//  editor wears its 52-pt bar — needs a real keyboard after a real keyboard,
//  so its red-on-old pin is the UI test
//  (`MobileKeyboardRevealUITests.testTheBarRidesAboveTheLibrarySearchKeyboard`).
//  These two suites pin the fix's own parts, which the in-process harness can
//  reach: the pure rule (`MobileKeyboardFloor.lift`), and the shell answering a
//  keyboard reading handed in through its test seam (`heldKeyboard`) — the bar
//  and the pages rise to it together while the top line stays put. Guards: the
//  types are the fix's, so neither is a red-on-old claim.
//

import Foundation
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@Suite("F-1a-W1 — the keyboard floor's rule")
struct MobileKeyboardFloorRuleTests {
    /// The walk's phone: the band rests at 840 with no keyboard.
    private static func reading(_ top: CGFloat) -> MobileKeyboardFloor.Reading {
        MobileKeyboardFloor.Reading(top: top, restingFoot: 840)
    }

    /// No keyboard up: nothing to meet.
    @Test func noKeyboardNoLift() {
        #expect(MobileKeyboardFloor.lift(bandFoot: 840, reading: nil, noteShowing: false) == 0)
    }

    /// The walk's s9: the band's foot on the keys (591), the keyboard's top at
    /// the glass (539) — the band rises the 52.
    @Test func aShortAvoidanceRisesByItsShortfall() {
        #expect(MobileKeyboardFloor.lift(bandFoot: 591, reading: Self.reading(539), noteShowing: false) == 52)
    }

    /// SwiftUI's avoidance already reaching the keyboard (every other case) —
    /// or standing above it — moves nothing: the floor never lowers the band.
    @Test func anAvoidanceThatReachesTheKeyboardMovesNothing() {
        #expect(MobileKeyboardFloor.lift(bandFoot: 539, reading: Self.reading(539), noteShowing: false) == 0)
        #expect(MobileKeyboardFloor.lift(bandFoot: 487, reading: Self.reading(539), noteShowing: false) == 0)
    }

    /// A keyboard LEAVING: SwiftUI's avoidance drops first — the band back at
    /// its resting foot — while the probe's reading still stands at the old
    /// top for a turn. The band must follow its own avoidance down, never be
    /// held at the old keyboard.
    @Test func aBandAtRestMeetsNoFloor() {
        #expect(MobileKeyboardFloor.lift(bandFoot: 840, reading: Self.reading(539), noteShowing: false) == 0)
        #expect(MobileKeyboardFloor.lift(bandFoot: 840 - MobileKeyboardFloor.tolerance,
                                         reading: Self.reading(539), noteShowing: false) == 0)
    }

    /// Rounding between the two readings is not a shortfall.
    @Test func roundingIsNotAShortfall() {
        let tolerance = MobileKeyboardFloor.tolerance
        #expect(MobileKeyboardFloor.lift(bandFoot: 539 + tolerance, reading: Self.reading(539), noteShowing: false) == 0)
        #expect(MobileKeyboardFloor.lift(bandFoot: 539 + tolerance + 1, reading: Self.reading(539), noteShowing: false)
                == tolerance + 1)
    }

    /// A note is left alone — its text view rides the keyboard guide itself.
    @Test func aNoteIsLeftAlone() {
        #expect(MobileKeyboardFloor.lift(bandFoot: 591, reading: Self.reading(539), noteShowing: true) == 0)
    }
}

@MainActor
@Suite("F-1a-W1 — the shell meets a keyboard top", .serialized)
struct MobileKeyboardFloorShellTests {
    /// Each bar door's frame on the window, by word (exactly one each).
    private func barFrames<V: View>(
        _ surface: HostedSurface<V>, sourceLocation: SourceLocation = #_sourceLocation
    ) -> [String: CGRect] {
        let window = surface.window.bounds.insetBy(dx: 1, dy: 1)
        var frames: [String: CGRect] = [:]
        for page in MobileShellBand.pages {
            let word = MobileTabBar.word(page)
            let shown = surface.visibleElements.filter {
                $0.accessibilityLabel == word && $0.accessibilityTraits.contains(.button)
                    && window.intersects($0.accessibilityFrame)
            }
            #expect(shown.count == 1, "\(word) on the window \(shown.count) times", sourceLocation: sourceLocation)
            if let frame = shown.first?.accessibilityFrame { frames[word] = frame }
        }
        return frames
    }

    /// The Bookcase's wing door — the top line's first door (it must not move).
    private func topLine<V: View>(_ surface: HostedSurface<V>) -> CGRect? {
        surface.visibleElements.first {
            $0.accessibilityTraits.contains(.button)
                && surface.window.bounds.intersects($0.accessibilityFrame)
                && $0.accessibilityFrame.minY < surface.window.bounds.height * 0.25
        }?.accessibilityFrame
    }

    /// A keyboard top above a band whose avoidance fell short: the one bar's
    /// doors END at it — the bar rides on the keyboard — and the top line has
    /// not moved (the band is lifted from below, never shifted). **MOVED at the
    /// VM-260 merge gate's G-3:** a band at REST under a keyboard reading — one
    /// SwiftUI's avoidance never met (the harness raises no keyboard, so it never
    /// does) — rides to the keyboard the same; it used to be read as a keyboard
    /// leaving and given nothing, which is G-3's defect (the Library's search
    /// taking its keyboard back during a pop: the bar at rest under the keys).
    /// RED on the pre-fix tree (this clause's commit), GREEN on the fix. The
    /// leaving case — SwiftUI HAD met the keyboard — is the pure rule's pin.
    @Test func theBarRidesOnTheKeyboardTopHandedIn() async throws {
        try await withEditorWorld { session, _ in
            let (atRest, restTop): ([String: CGRect], CGRect?) = await withHostedSurface(
                MobileShellView(session: session, services: nil, router: MobileShellRouter())
            ) { surface in
                await surface.settle(30)
                return (barFrames(surface), topLine(surface))
            }
            #expect(atRest.count == MobileShellBand.pages.count)
            let foot = try #require(atRest.values.map(\.maxY).max(), "the bar at rest")
            print("PERF[sim] F-1a-W1 the bar at rest — foot \(foot), top line \(String(describing: restTop))")

            let keyboardTop: CGFloat = 600
            #expect(keyboardTop < foot - 100, "PREMISE: the handed-in top stands well above the foot (\(foot))")
            // The harness raises no keyboard, so SwiftUI's band stands at its
            // own foot; the reading's resting foot says where a band with NO
            // keyboard would stand — below it — so this band reads as one whose
            // avoidance fell short (the walk's s9), and the floor answers.
            try await withHostedSurface(
                MobileShellView(
                    session: session, services: nil, router: MobileShellRouter(),
                    heldKeyboard: MobileKeyboardFloor.Reading(top: keyboardTop, restingFoot: foot + 60))
            ) { surface in
                await surface.settle(30)
                let lifted = barFrames(surface)
                print("PERF[sim] F-1a-W1 a keyboard at \(keyboardTop) — the bar \(lifted)")
                for (word, frame) in lifted {
                    #expect(abs(frame.maxY - keyboardTop) <= 0.5,
                            "\(word) ends at \(frame.maxY), on the keyboard's top \(keyboardTop)")
                    if let rest = atRest[word] {
                        #expect(abs(frame.height - rest.height) <= 0.5 && abs(frame.minX - rest.minX) <= 0.5,
                                "\(word) is the same door, only lifted: \(frame) vs \(rest)")
                    }
                }
                if let restTop {
                    let nowTop = try #require(topLine(surface), "the top line")
                    #expect(abs(nowTop.minY - restTop.minY) <= 0.5, "the top line stays: \(nowTop) vs \(restTop)")
                }
            }

            // G-3 — a band at REST (its foot the resting foot) under a keyboard
            // SwiftUI never avoided: the bar rides to the keyboard's top all the
            // same (it stayed at rest under the keys before the fix).
            await withHostedSurface(
                MobileShellView(
                    session: session, services: nil, router: MobileShellRouter(),
                    heldKeyboard: MobileKeyboardFloor.Reading(top: keyboardTop, restingFoot: foot))
            ) { surface in
                await surface.settle(30)
                let lifted = barFrames(surface)
                print("PERF[sim] VM-260 G-3 a keyboard at \(keyboardTop) over a band at rest — the bar \(lifted)")
                #expect(lifted.count == MobileShellBand.pages.count)
                for (word, frame) in lifted {
                    #expect(abs(frame.maxY - keyboardTop) <= 0.5,
                            "\(word) ends at \(frame.maxY): a band SwiftUI never lifted rides on the keyboard's top \(keyboardTop)")
                }
            }
        }
    }
}
