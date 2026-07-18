//
//  ThemeTests.swift
//  VariorumTests
//
//  Phase 13, B1 — the token layer's behavioral pins: the resolve mapping,
//  the R51 black-dark rule, and the idiom slots (a voice is tokens AND
//  idioms — R1; the slots are load-bearing, not decoration).
//

import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("Voice tokens (Phase 13, B1)")
struct ThemeTokenTests {
    @Test func resolveMapsVoiceAndSchemeToTheFourSets() {
        #expect(VoiceTokens.resolve(voice: .terminal, dark: false).pathPrefix == "~/")
        #expect(VoiceTokens.resolve(voice: .study, dark: false).pathPrefix == "")
        #expect(VoiceTokens.resolve(voice: .terminal, dark: true).showsBlockCursor)
        #expect(!VoiceTokens.resolve(voice: .study, dark: true).showsBlockCursor)
    }

    @Test func darkIsFullyBlackInBothVoices() {
        // R51 (her direct edit — supersedes the grey): dark mode = a FULLY
        // BLACK background, both voices.
        #expect(VoiceTokens.terminalDark.room == Color.black)
        #expect(VoiceTokens.studyDark.room == Color.black)
    }

    @Test func terminalIdiomsAreCarried() {
        // R1's letter: "the little › on what's selected, the slashes,
        // the ~/shelf, the blinking cursor" — idiom SLOTS, not styling.
        let terminal = VoiceTokens.terminalLight
        #expect(terminal.selectionMarker == "› ")
        #expect(terminal.path(["Shelf"]) == "~/shelf")
        #expect(terminal.path(["Orbit", "II", "Weeks"]) == "~/orbit/ii/weeks")
        #expect(terminal.commentPrefix == "# ")
        #expect(terminal.showsBlockCursor)
        #expect(terminal.chromeLabel("6 Books") == "6 books")
    }

    @Test func studyCarriesItsOwnQuietGrammar() {
        let study = VoiceTokens.studyLight
        #expect(study.selectionMarker.isEmpty)
        #expect(study.path(["Orbit", "II"]) == "Orbit · II")
        #expect(!study.lowercasesChrome)
    }
}
