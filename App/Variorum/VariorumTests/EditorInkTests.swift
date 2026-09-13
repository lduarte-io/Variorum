//
//  EditorInkTests.swift
//  VariorumTests
//
//  18j (her R-Q12) — THE DARK WALK'S FIRST FIND, and the 18g ladder's R2-5
//  closed by the same change.
//
//  What the walk saw: every note in the full-document Write editor drew its
//  prose in AppKit's own near-black default rather than the voice's ink. In
//  LIGHT that default sits a few values from `terminalLight.ink`, so nobody
//  had ever seen it; in DARK it is black on black and the note is gone.
//  Captures: `13-write-existing-note-T-dark.png` (unreadable) beside
//  `14-read-edit-T-dark.png` (the read tier, always right) and
//  `15-write-after-voice-switch-S-dark.png` (a voice switch repairs it,
//  because THAT write lands on a non-empty storage).
//
//  The mechanism, traced: `EditorDocument.baseAttributes` carried the font
//  and the paragraph style and no colour; the Write editor applies its
//  chrome at `makeNSView`, on an EMPTY storage, so `textColor`'s setter had
//  no characters to write and left only the typing attributes; the document
//  arrived a line later through `setAttributedString` with no
//  `.foregroundColor` anywhere. (The read tier and the panes set the colour
//  and THEN the string, which is why they were never wrong.)
//

import AppKit
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("The editor's prose ink (18j)")
struct EditorInkTests {
    /// Resolve a (possibly dynamic) colour the way the text system will —
    /// against a drawing appearance (the ONE helper, `ResolvedInk`, since the
    /// ladder's R1-1 gave `MarkdownFaceTests` and `PaneSurfaceTests` the same
    /// need).
    private func resolved(_ colour: NSColor, dark: Bool) -> NSColor {
        ResolvedInk.resolved(colour, dark: dark)
    }

    private func matches(_ colour: NSColor, _ expected: Color) -> Bool {
        ResolvedInk.matches(colour, expected)
    }

    private func withVoice<T>(_ voice: ThemeVoice, _ body: () throws -> T) rethrows -> T {
        let saved = EditorTypography.current
        defer { EditorTypography.current = saved }
        EditorTypography.current = EditorTypography.resolve(
            voice: voice, inlineComments: false)
        return try body()
    }

    /// **RED ON OLD:** before this batch `baseAttributes` had no
    /// `.foregroundColor` key at all, so this `#require` fails outright.
    @Test func theBaseAttributesCarryTheVoicesInkInBothAppearances() throws {
        for voice in ThemeVoice.allCases {
            try withVoice(voice) {
                let ink = try #require(
                    EditorDocument.baseAttributes[.foregroundColor] as? NSColor,
                    "\(voice.rawValue): the one source every surface write goes through")
                #expect(matches(resolved(ink, dark: false),
                                VoiceTokens.resolve(voice: voice, dark: false).ink),
                        "\(voice.rawValue) light")
                #expect(matches(resolved(ink, dark: true),
                                VoiceTokens.resolve(voice: voice, dark: true).ink),
                        "\(voice.rawValue) dark — the black-on-black case")
            }
        }
    }

    /// The whole point of ONE object rather than two resolutions: the same
    /// colour serves both appearances, which is what makes an appearance
    /// change free of any storage write (R2-5, below).
    @Test func theInkIsOneObjectPerVoiceAndNotPerAppearance() {
        #expect(EditorTypography.ink(for: .terminal) === EditorTypography.ink(for: .terminal))
        #expect(EditorTypography.ink(for: .terminal) !== EditorTypography.ink(for: .study))
    }

    /// **A MATERIALIZED DOCUMENT carries it** — the road the defect took.
    /// Red on old: the materialized string had no foreground attribute.
    @Test func aMaterializedDocumentsProseCarriesTheInk() throws {
        try withVoice(.terminal) {
            let (text, _) = EditorDocument.materialize(
                [slot("b1", text: "plain prose, no markdown at all")])
            let ink = text.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? NSColor
            let resolvedDark = resolved(try #require(ink), dark: true)
            #expect(matches(resolvedDark, VoiceTokens.terminalDark.ink),
                    "in dark the prose is the voice's light ink, not AppKit's near-black default")
        }
    }

    /// **THE 18g LADDER'S R2-5, CLOSED.** An appearance change used to move
    /// `inkChanged`, and `NSTextView.textColor`'s setter re-attributes the
    /// ENTIRE storage — a full-range edit that invalidates a long note's
    /// layout and jumps its viewport (the same class as the re-font road,
    /// KnownIssues). With one dynamic ink per voice the appearance is not an
    /// input any more: a light/dark change writes NOTHING full-range.
    /// RED ON OLD (`previous.dark != dark` was an arm of `inkChanged`).
    @Test func anAppearanceChangeWritesNothingOverTheWholeStorage() {
        let light = EditorSurfaceChrome(voice: .terminal, dark: false, inlineComments: false)
        let dark = EditorSurfaceChrome(voice: .terminal, dark: true, inlineComments: false)
        #expect(light != dark, "the chrome still MOVES — the face and the paper follow")
        #expect(!dark.inkChanged(from: light),
                "…but the ink is the same object, so no whole-storage write")
        #expect(!dark.needsStorageRefresh(from: light),
                "and no base-attribute refresh either — the re-font road stays the voice's")

        // A VOICE change still writes: a different voice is a different ink.
        let study = EditorSurfaceChrome(voice: .study, dark: true, inlineComments: false)
        #expect(study.inkChanged(from: dark))
        #expect(study.needsStorageRefresh(from: dark))
        // And the first application is still everything.
        #expect(light.inkChanged(from: nil))
    }

    /// A palette never moved the ink and still does not (18g's derivation
    /// table — prose is the voice's register) — stated here because
    /// `inkChanged` now names only the voice, and a reader should see that
    /// the palette's absence is a decision rather than an omission.
    @Test func aPaletteNeverMovesTheInk() {
        let plain = EditorSurfaceChrome(voice: .terminal, dark: true, inlineComments: false)
        let lavender = EditorSurfaceChrome(
            voice: .terminal, dark: true, inlineComments: false, palette: .lavender)
        #expect(plain != lavender, "the chrome moves — the paper, the caret and the face do")
        #expect(!lavender.inkChanged(from: plain))
        #expect(lavender.ink === plain.ink)
    }
}
