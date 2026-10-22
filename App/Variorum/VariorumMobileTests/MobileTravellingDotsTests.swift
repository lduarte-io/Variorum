//
//  MobileTravellingDotsTests.swift
//  VariorumMobileTests
//
//  pre-13x batch 5b, item 1 (ledger 32) — the phone's half of the original
//  animated indicator: the shared view hosted ALONE in a real key window
//  (the driver's mechanism-only shape), speaking *Working…*, and the phone's
//  protection surfaces composing it where they once spun.
//

import Foundation
import SwiftUI
import Testing
@testable import VariorumMobile

@MainActor
@Suite("pre-13x 5b — the travelling-dots indicator on the phone")
struct MobileTravellingDotsTests {
    private func composition<V: View>(of view: V) -> String {
        var out = ""
        dump(view, to: &out, maxDepth: 120)
        return out
    }

    @Test func theIndicatorHostsAloneOnThePhoneAndSpeaksWorking() async {
        let indicator = TravellingDotsIndicator(ink: VoiceTokens.terminalLight.muted)
        let host = HostedSurface(indicator, size: CGSize(width: 120, height: 40))
        await host.settle()
        let shown = composition(of: indicator.body)
        #expect(shown.contains(String(reflecting: TravellingDotsIndicator.accessibilityLabel)))
        #expect(TravellingDotsIndicator.dotPositions(phase: 0, reduceMotion: true, count: 3) == [0.25, 0.5, 0.75])
        _ = host
    }

    // (VX-329 U1: the pin over the phone's lobby — today's `MobileStoreLockView` over `StoreLobby` — was deleted with
    // it; the phone's road faces are in the Mac suite's no-spinner walk, `TravellingDotsIndicatorTests`.)
}
