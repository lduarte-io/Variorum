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

    /// **THE ERROR/DANGER SLOT, IN BOTH VOICES** (the post-13l polish round,
    /// ledger row 29 — her mid-round ruling: *"Add it this round"*).
    ///
    /// The mechanism this closes, traced rather than assumed: with no alarm
    /// token, a themed surface that wanted one reached for `accent` — and in
    /// the TERMINAL voice `accent` and `chosen` are literally the same green
    /// (`0x2F7D5F`), the colour the "✓ chosen" mark wears. So the tray's
    /// refusal slot painted *"This note is sealed…"* in the app's own success
    /// colour, and it was the closest thing to right that existed. Every voice
    /// now names an alarm, and it is nobody else's colour.
    @Test func everyVoiceNamesAnAlarmThatIsNobodyElsesColour() {
        for tokens in [
            VoiceTokens.terminalLight, .terminalDark, .studyLight, .studyDark,
        ] {
            #expect(tokens.alarm != tokens.accent,
                    "a refusal must not wear the voice's emphasis")
            #expect(tokens.alarm != tokens.chosen,
                    "…nor the mark that means a take is CHOSEN")
            #expect(tokens.alarm != tokens.ink)
            #expect(tokens.alarm != tokens.muted)
            // Row 31's quiet positive is its own slot, and the settled state
            // must never be readable as the alarm.
            #expect(tokens.positive != tokens.alarm)
        }
        // The two voices really differ — this is a VOICE token, not one
        // colour wearing two names (R1: never a palette swap).
        #expect(VoiceTokens.terminalLight.alarm != VoiceTokens.studyLight.alarm)
        // …and dark is its own register in both, per R51's discipline.
        #expect(VoiceTokens.terminalLight.alarm != VoiceTokens.terminalDark.alarm)
        #expect(VoiceTokens.studyLight.alarm != VoiceTokens.studyDark.alarm)
    }

    @Test func terminalIdiomsAreCarried() {
        // R1's letter: "the little › on what's selected, the slashes,
        // the ~/shelf, the blinking cursor" — idiom SLOTS, not styling.
        let terminal = VoiceTokens.terminalLight
        #expect(terminal.selectionMarker == "› ")
        #expect(terminal.path(["Shelf"]) == "~/shelf")
        #expect(terminal.path(["Orbit", "II", "Weeks"]) == "~/orbit/ii/weeks")
        #expect(terminal.commentPrefix == "// ")  // R100, batch 10: her "probably switch to //" — PROVISIONAL until she sees comments live
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
