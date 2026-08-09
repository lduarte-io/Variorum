//
//  SharedPageStyleTests.swift
//  VariorumTests
//
//  Mobile parity round, Stage D batch D1 — the one-seam law's Mac pin:
//  the shared account/encryption/tier pages restyle ON THE PHONE through
//  an optional environment style, and on macOS that environment accessor
//  is compiled to always-nil (getter nil, setter inert). This pin holds
//  the law's letter: the Mac cannot be handed a SharedPageStyle even
//  deliberately, so every styled arm in the shared views is unreachable
//  here and the Mac's rendering is the pre-D1 construction by
//  construction.
//

import SwiftUI
import Testing
@testable import Variorum

@MainActor
@Suite("SharedPageStyle — the one-seam law (D1)")
struct SharedPageStyleTests {
    @Test func theMacCanNeverBeHandedASharedPageStyle() {
        var environment = EnvironmentValues()
        environment.sharedPageStyle = SharedPageStyle(tokens: .terminalLight)
        #expect(environment.sharedPageStyle == nil,
                "macOS compiles the shared-page style away — the styled arms are unreachable on the Mac")
    }
}
