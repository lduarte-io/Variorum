//
//  LibraryListHeaderDarkFaceTests.swift
//  VariorumTests
//
//  VX-20 (the VX-283 run, U3) — her #188(m) ruling, "the bands match": in
//  DARK the Library List's pinned "books"/"notes" heading drew a warm grey
//  band (#2F2D29) across the black room in both voices, where the old List's
//  own heading sits almost on the room (`notes/plans/librarywalkpolish-ladder-
//  round1.md` § THE ONE FINDING). The face drew its pinned background from
//  the system's `.headerView` material in every appearance — the light
//  parity, true in light, broken in dark.
//
//  THE COLOUR SOURCE, pinned: `LibraryListHeader.pinnedFace(tokens:dark:)` —
//  in dark the voice's own paper (the colour the List draws on) and its
//  hairline; in light the material, unchanged. RED ON OLD by behavioural
//  revert **R-D** (the function answering `.material` in every appearance —
//  the old face): the dark cells. The light cells are guards. The pixels
//  themselves are the List-face rig's dark pass
//  (`TEST_RUNNER_VARIORUM_LIBRARY_LIST_FACE=1` +
//  `…_APPEARANCE=dark`), run before and after in the stage window.
//

import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@MainActor
@Suite("VX-20 — the List's pinned heading in dark draws from the voice (the bands match)")
struct LibraryListHeaderDarkFaceTests {
    @Test(arguments: [ThemeVoice.terminal, .study])
    func inDarkThePinnedHeadingIsTheListsOwnPaperAndHairline(voice: ThemeVoice) {
        let tokens = VoiceTokens.resolve(voice: voice, dark: true)
        #expect(LibraryListHeader.pinnedFace(tokens: tokens, dark: true)
                == .voice(fill: tokens.surface, hairline: tokens.line),
                "\(voice) dark: the voice's paper and hairline, never the grey material band")
    }

    /// Under a palette the dark paper carries the palette's hue (18g), so the
    /// heading follows the paper the List actually draws on.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func underAPaletteTheDarkHeadingFollowsThePalettesPaper(voice: ThemeVoice) {
        let tokens = VoiceTokens.resolve(voice: voice, palette: .lavender, tint: .none, dark: true)
        #expect(LibraryListHeader.pinnedFace(tokens: tokens, dark: true)
                == .voice(fill: tokens.surface, hairline: tokens.line))
    }

    /// GUARD (green on both sides): light keeps the table's material — the
    /// batch-1 parity, true in light.
    @Test(arguments: [ThemeVoice.terminal, .study])
    func inLightThePinnedHeadingKeepsTheMaterial(voice: ThemeVoice) {
        let tokens = VoiceTokens.resolve(voice: voice, dark: false)
        #expect(LibraryListHeader.pinnedFace(tokens: tokens, dark: false) == .material)
    }
}
