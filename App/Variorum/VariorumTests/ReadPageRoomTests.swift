//
//  ReadPageRoomTests.swift
//  VariorumTests
//
//  **13u2 UNIT B — her item 19 (R-13u-10), verbatim:** *"I also don't want
//  the color background behind the cream read page - leave that white so that
//  the cream read page isn't on a colorful background."*
//
//  It REFINES #107/R-Q26 (*"Keep the page cream"*) rather than reversing it:
//  the page stays cream under every palette, AND the room it sits in stays
//  the voice's own quiet near-white. R2's sentence — *"only the ROOM around
//  the page follows the voice"* — is what `ReadingPageTokens.room` returns.
//
//  Two pins, because the rule has two halves: WHAT the room is (the
//  palette-less road), and WHO draws it (the four hosts that put a cream page
//  on screen). The second is a source walk in the `NoLiteralColourTests`
//  idiom — a host that goes back to `tokens.room` behind a page fails the
//  suite instead of being noticed at a walk six weeks later.
//
//  RED ON OLD: all four hosts drew `tokens.room`, so under the Rose & moss
//  bold palette the note's Read page sat on a saturated pink field — the walk
//  capture `33-b-before-read-page-on-palette-room.png` is the before.
//

import Foundation
import SwiftUI
import Testing
import VariorumCore

@testable import Variorum

@Suite("The cream page's room is the voice's, never a palette's (13u2 UNIT B)")
struct ReadPageRoomTests {
    /// The room is the voice's own — the same colour a default palette gives,
    /// and NOT the colour the palette gives the rest of the app's panels.
    @MainActor
    @Test func aPaletteRecoloursTheRoomButNotTheRoomAroundThePage() {
        for voice in [ThemeVoice.terminal, ThemeVoice.study] {
            for dark in [false, true] {
                let plain = VoiceTokens.resolve(voice: voice, dark: dark)
                let page = ReadingPageTokens.room(voice: voice, dark: dark)
                #expect(page == plain.room,
                        "the page's room IS the voice's own room")

                for palette in [ThemePalette.roseAndMoss, .lavender, .goldAndBlack] {
                    var settings = Queries.ThemeSettings()
                    settings.voice = voice
                    settings.palette = palette
                    let washed = VoiceTokens.resolve(settings: settings, dark: dark)
                    #expect(ReadingPageTokens.room(voice: voice, dark: dark) == plain.room,
                            "a palette never reaches the page's room")
                    if !dark {
                        // In LIGHT a palette really does move the room, so the
                        // pin has teeth: the two differ, and the page keeps the
                        // quiet one. (In dark both are black by R51, which is
                        // its own promise and is pinned in PaletteDerivationTests.)
                        #expect(washed.room != plain.room,
                                "…and the palette moved the app's room, so this is a real difference")
                    }
                }
            }
        }
    }

    /// **WHO DRAWS IT.** The four hosts that put a cream `ReadingPageTokens`
    /// page on screen — the note's Read (continuous and pages) and the book's
    /// Read (Scroll and Pages) — must take the page's room. A `tokens.room`
    /// backdrop in any of them is the defect coming back.
    @Test func everyHostThatDrawsACreamPageTakesThePagesRoom() throws {
        let appRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumTests
            .deletingLastPathComponent()  // App/Variorum
            .appendingPathComponent("Variorum")
        // The three files whose whole body IS a cream page: no `tokens.room`
        // may appear in them at all.
        let pageOnly = [
            "Features/ReadMode/NotePagesView.swift",     // the note's leaves
            "Features/BookView/ReadingFlowView.swift",   // the book's Read ▸ Scroll
            "Features/BookView/PagedReadView.swift",     // the book's Read ▸ Pages
        ]
        for host in pageOnly {
            let source = try String(
                contentsOf: appRoot.appendingPathComponent(host), encoding: .utf8)
            #expect(source.contains("ReadingPageTokens.room("),
                    "\(host) must take the page's own room")
            #expect(!source.contains(".background(tokens.room)"),
                    "\(host) draws a cream page — its backdrop must not be the palette's room")
        }
        // `ReadModeView` hosts BOTH faces: its `edit` face is an editing
        // surface and keeps the palette's room (which its column and pane
        // cover anyway), while the `read` face's page column takes the page's.
        // So the positive half only — the negative one would forbid a room
        // that is correct.
        let twoFaced = try String(
            contentsOf: appRoot.appendingPathComponent("Features/ReadMode/ReadModeView.swift"),
            encoding: .utf8)
        #expect(twoFaced.contains("ReadingPageTokens.room("),
                "the note's read page takes the page's own room")
    }
}
