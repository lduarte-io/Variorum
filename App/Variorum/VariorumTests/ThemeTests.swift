//
//  ThemeTests.swift
//  VariorumTests
//
//  Phase 13, B1 — the token layer's behavioral pins: the resolve mapping,
//  the R51 black-dark rule, and the idiom slots (a voice is tokens AND
//  idioms — R1; the slots are load-bearing, not decoration).
//

import AppKit
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

    /// **THE PARITY PROOF** (18g — her R-Q6: *"default keeps each voice's
    /// shipped colours byte-identical"*). The palette resolver's `.default`
    /// arm returns the SAME VALUE the two-parameter resolver does, in all
    /// four voice/scheme combinations — so every pin above and below this
    /// one, and all 67 token-consuming surfaces, are untouched by 18g
    /// unless she picks a palette.
    ///
    /// The `custom`-with-no-seed row is the second half of the same
    /// promise: a palette that cannot be derived falls back to the voice
    /// rather than to half a palette.
    @Test func theDefaultPaletteIsEachVoicesShippedColoursByteIdentically() {
        for voice in ThemeVoice.allCases {
            for dark in [false, true] {
                let shipped = VoiceTokens.resolve(voice: voice, dark: dark)
                #expect(VoiceTokens.resolve(
                    voice: voice, palette: .default, tint: .none, dark: dark) == shipped)
                #expect(VoiceTokens.resolve(
                    voice: voice, palette: .custom, tint: .none, dark: dark) == shipped,
                        "a custom palette with no seed is not a palette")
                #expect(VoiceTokens.resolve(
                    voice: voice, palette: .custom,
                    tint: PaletteTint(room: "not a colour"), dark: dark) == shipped)
                // …and a real palette DOES move the slots it owns, while
                // leaving the voice's own alone (the other half of R1).
                let lavender = VoiceTokens.resolve(
                    voice: voice, palette: .lavender, tint: .none, dark: dark)
                #expect(lavender.accent != shipped.accent)
                #expect(lavender.wash != shipped.wash)
                #expect(lavender.ink == shipped.ink)
                #expect(lavender.chosen == shipped.chosen)
                #expect(lavender.alarm == shipped.alarm)
                #expect(lavender.star == shipped.star)
                #expect(lavender.seam == shipped.seam)
                #expect(lavender.selectionMarker == shipped.selectionMarker)
                #expect(lavender.pathPrefix == shipped.pathPrefix)
                #expect(lavender.lowercasesChrome == shipped.lowercasesChrome)
                // In LIGHT the voice keeps its own paper; in DARK the
                // palette carries it, because the room is black.
                #expect((lavender.surface == shipped.surface) == !dark)
            }
        }
    }

    @Test func darkIsFullyBlackInBothVoices() {
        // R51 (her direct edit — supersedes the grey): dark mode = a FULLY
        // BLACK background, both voices.
        #expect(VoiceTokens.terminalDark.room == Color.black)
        #expect(VoiceTokens.studyDark.room == Color.black)
    }

    /// **R51 AT THE TOKEN A VIEW ACTUALLY CONSUMES** (18j — her R-Q12).
    ///
    /// `PaletteDerivationTests.theDarkRoomStaysFullyBlackUnderEveryPalette`
    /// pins the FAMILY the brain derives; this pins what comes out of the
    /// RESOLVER, which is the only value a surface ever sees — and it is the
    /// arm the family pin structurally cannot reach, because `.default` and
    /// a seedless `custom` have no family at all (the resolver returns the
    /// voice's own set). Every preset, her own hex included, both voices:
    /// the dark room is BLACK, and nothing else in the app can make it
    /// otherwise.
    @Test func theDarkRoomIsBlackUnderEveryPaletteInBothVoices() {
        var checked = 0
        for voice in ThemeVoice.allCases {
            for palette in ThemePalette.allCases {
                // Her own hex, including deliberately hostile ones.
                for tint in [PaletteTint.none,
                             PaletteTint(room: "FFFFFF", accent: nil),
                             PaletteTint(room: "FFFF00", accent: "FF00FF")] {
                    let tokens = VoiceTokens.resolve(
                        voice: voice, palette: palette, tint: tint, dark: true)
                    #expect(tokens.room == Color.black,
                            "R51: \(voice.rawValue) · \(palette.rawValue)")
                    checked += 1
                }
            }
        }
        #expect(checked == ThemeVoice.allCases.count * ThemePalette.allCases.count * 3)
    }

    /// **The paper stays a WHISPER of the room** (18j; 18g's J52 handed the
    /// dark readings here). With the room black, a palette carries the hue
    /// on `surface`/`card` — but a paper that drifted bright would make the
    /// black room a frame around a light page, which is not the composition
    /// R51's "fully black" names. The band holds both voices' own dark
    /// papers (Terminal's `0C0D0C`, Study's `14120F`) and the derived ones
    /// the mockup drew, and is tight enough that a future seed table cannot
    /// quietly light the page up.
    @Test func theDarkPaperStaysAWhisperOfTheRoomUnderEveryPalette() {
        var brightest = (name: "", value: 0.0)
        for voice in ThemeVoice.allCases {
            for palette in ThemePalette.allCases {
                let tokens = VoiceTokens.resolve(
                    voice: voice, palette: palette,
                    tint: PaletteTint(room: "FFFF00", accent: nil), dark: true)
                for (slot, colour) in [("surface", tokens.surface), ("card", tokens.card)] {
                    let level = Self.luminance(colour)
                    // Measured max today: 0.0192 (terminal/teal_rust/card).
                    // The ceiling leaves real headroom and still catches a
                    // paper that drifted toward a page.
                    #expect(level < 0.05,
                            "\(voice.rawValue) · \(palette.rawValue) · \(slot) is not a whisper of a black room (luminance \(level))")
                    if level > brightest.value {
                        brightest = ("\(voice.rawValue)/\(palette.rawValue)/\(slot)", level)
                    }
                }
            }
        }
        print("[18j] the brightest dark paper: \(brightest.name) at \(brightest.value)")
    }

    /// WCAG relative luminance of a resolved SwiftUI colour.
    private static func luminance(_ colour: Color) -> Double {
        let native = NSColor(colour).usingColorSpace(.sRGB) ?? .black
        func channel(_ value: Double) -> Double {
            value <= 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * channel(native.redComponent)
            + 0.7152 * channel(native.greenComponent)
            + 0.0722 * channel(native.blueComponent)
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

    /// **THE POSITIVE SLOT SAYS WHAT IT REALLY IS** (the ladder's LR1-9, and
    /// LR2-2 which caught the correction stopping one voice short). Its doc
    /// claimed distinctness from `accent` and `chosen`; the truth is that
    /// **`positive == chosen` in ALL FOUR voices** — every settled line wears
    /// the "✓ chosen" hue — and only `accent` separates the voices, Terminal
    /// sharing its one green while Study's accent is blue.
    ///
    /// The hues are NOT nudged: Terminal has one green on purpose, hues are
    /// 13s's by her ruling, and a second green would read as a different
    /// signal rather than a gentler one. What is fixed is the honesty — and
    /// this pin asserts the `chosen` relation the LR1-9 pin never did, so the
    /// doc stays checkable against the app rather than against itself.
    @Test func theQuietPositiveIsItsOwnSlotEvenWhereItSharesTheVoicesGreen() {
        // The relation the doc now states for every voice — the one LR1-9's
        // pin left unasserted, which is how the doc drifted a second time.
        for tokens in [
            VoiceTokens.terminalLight, .terminalDark, .studyLight, .studyDark,
        ] {
            #expect(tokens.positive == tokens.chosen,
                    "today the settled state wears the chosen mark's hue — in EVERY voice")
            // And in every voice it stays the settled state, never the alarm.
            #expect(tokens.positive != tokens.alarm)
        }
        // Terminal: deliberately the voice's one green (the doc says so).
        #expect(VoiceTokens.terminalLight.positive == VoiceTokens.terminalLight.accent)
        #expect(VoiceTokens.terminalDark.positive == VoiceTokens.terminalDark.accent)
        // Study: not the emphasis colour, which is where the separate slot is
        // at least visible today — its accent is blue.
        #expect(VoiceTokens.studyLight.positive != VoiceTokens.studyLight.accent)
        #expect(VoiceTokens.studyDark.positive != VoiceTokens.studyDark.accent)
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
