//
//  MobileSharedPageStyleTests.swift
//  VariorumMobileTests
//
//  Mobile parity round, Stage D batch D1 — the one-seam law's phone pin:
//  the seam is LIVE on iOS (the environment carries the injected style),
//  and the chrome casing routes through the ONE voice rule
//  (`VoiceTokens.chromeLabel` — the P26/P43 one-register discipline), so
//  the styled pages can never fork a second register.
//

import SwiftUI
import Testing
@testable import VariorumMobile

@MainActor
@Suite("SharedPageStyle — the phone seam (D1)")
struct MobileSharedPageStyleTests {
    @Test func thePhoneSeamCarriesTheInjectedStyle() {
        var environment = EnvironmentValues()
        environment.sharedPageStyle = SharedPageStyle(tokens: .terminalLight)
        #expect(environment.sharedPageStyle != nil,
                "iOS carries the injected style — the Settings sheet's injection reaches the pages")
    }

    @Test func chromeCasingIsTheOneVoiceRule() {
        let terminal = SharedPageStyle(tokens: .terminalLight)
        let study = SharedPageStyle(tokens: .studyLight)
        #expect(terminal.chrome("Close") == "close",
                "terminal lowercases chrome — the voice's own idiom")
        #expect(study.chrome("Close") == "Close",
                "study keeps written case")
        #expect(terminal.chrome("Encryption") == VoiceTokens.terminalLight.chromeLabel("Encryption"),
                "the casing IS chromeLabel's — one rule, no second register")
    }
}
