//
//  PaletteReachTests.swift
//  VariorumTests
//
//  18g ladder, round 1 — R1-1 (MAJOR): the palette must reach the two
//  AppKit text-surface hosts. `EditorSurfaceChrome` (the Write editor's and
//  the read tier's paper/ink/caret + the markdown palette's second writer)
//  and `EditorAppearance` (the decoration layer: the selected-block wash
//  and its accent border, the `.background` editing indicator) are built
//  from the store's SETTINGS, and each resolved its tokens for itself
//  through the two-parameter forwarder — so under every palette the caret,
//  the selection wash, the indicator and (in dark) the paper stayed the
//  voice's, and the markdown link colour flipped back to the voice's accent
//  at every surface mount. RED on `f97188d1`: both `tokens` equal the
//  voice's static set, never the palette's family.
//
//  The rule these pin: there is ONE settings → tokens road, and every host
//  that holds a settings value resolves through it.
//

import AppKit
import SwiftUI
import Testing
import VariorumCore
@testable import Variorum

@Suite("The palette reaches the AppKit text surfaces (18g ladder R1-1)")
@MainActor
struct PaletteReachTests {
    private func settings(
        _ palette: ThemePalette, voice: ThemeVoice = .terminal,
        room: String? = nil, accent: String? = nil
    ) -> Queries.ThemeSettings {
        var settings = Queries.ThemeSettings()
        settings.voice = voice
        settings.palette = palette
        settings.customRoom = room
        settings.customAccent = accent
        return settings
    }

    /// A soft preset, a bold preset and a two-hex custom, in both voices
    /// and both appearances: the chrome's tokens and the appearance's
    /// tokens are the SAME family the store resolves — so the caret (the
    /// accent), the selection wash and the dark paper are the palette's.
    @Test func theEditorChromeAndTheDecorAppearanceResolveThePalette() {
        let cases: [(ThemePalette, String?, String?)] = [
            (.lavender, nil, nil), (.roseAndMoss, nil, nil), (.custom, "E07A5F", "3D5A80"),
        ]
        for (palette, room, accent) in cases {
            for voice in ThemeVoice.allCases {
                for dark in [false, true] {
                    let settings = settings(palette, voice: voice, room: room, accent: accent)
                    let expected = VoiceTokens.resolve(
                        voice: voice, palette: palette,
                        tint: PaletteTint(room: room, accent: accent), dark: dark)
                    let chrome = EditorSurfaceChrome(tokens: settings, dark: dark)
                    let where_ = "\(palette.rawValue) · \(voice.rawValue) · \(dark ? "dark" : "light")"
                    #expect(chrome.tokens == expected, "the chrome's tokens: \(where_)")
                    #expect(chrome.tokens.accent == expected.accent,
                            "the caret is the palette's accent: \(where_)")
                    #expect(chrome.tokens.surface == expected.surface,
                            "the paper follows the family (dark) or stays the voice's (light): \(where_)")
                    let appearance = EditorAppearance(settings, dark: dark)
                    #expect(appearance.tokens == expected, "the decor's tokens: \(where_)")
                    #expect(appearance.tokens.wash == expected.wash,
                            "the selection wash and the background indicator: \(where_)")
                }
            }
        }
    }

    /// The other half of the parity promise: a settings value that names
    /// NO palette still hands both hosts the voice's shipped set — the same
    /// value `resolve(voice:dark:)` returns — so nothing moves for a user
    /// who picks no palette.
    @Test func defaultSettingsStillGiveBothHostsTheShippedSet() {
        for voice in ThemeVoice.allCases {
            for dark in [false, true] {
                var settings = Queries.ThemeSettings()
                settings.voice = voice
                let shipped = VoiceTokens.resolve(voice: voice, dark: dark)
                #expect(EditorSurfaceChrome(tokens: settings, dark: dark).tokens == shipped)
                #expect(EditorAppearance(settings, dark: dark).tokens == shipped)
                // A custom with no seed is no palette either.
                settings.palette = .custom
                #expect(EditorSurfaceChrome(tokens: settings, dark: dark).tokens == shipped)
                #expect(EditorAppearance(settings, dark: dark).tokens == shipped)
            }
        }
    }

    /// The two `Equatable` gates are the app's ONLY re-apply mechanisms
    /// (`appliedChrome != chrome`; `oldValue != appearance`). A palette
    /// flip — or a custom seed change — must MOVE both values, or the
    /// surface keeps its old colours until some unrelated re-apply.
    @Test func aPaletteChangeMovesTheChromeGateAndTheAppearanceGate() {
        #expect(EditorSurfaceChrome(tokens: settings(.default), dark: false)
            != EditorSurfaceChrome(tokens: settings(.mint), dark: false))
        #expect(EditorAppearance(settings(.default), dark: false)
            != EditorAppearance(settings(.mint), dark: false))
        #expect(EditorSurfaceChrome(tokens: settings(.custom, room: "E07A5F"), dark: false)
            != EditorSurfaceChrome(tokens: settings(.custom, room: "3D5A80"), dark: false))
        #expect(EditorAppearance(settings(.custom, room: "E07A5F"), dark: false)
            != EditorAppearance(settings(.custom, room: "E07A5F", accent: "3D5A80"), dark: false))
    }

    /// The ONE settings → tokens road (added with the fix, not part of the
    /// red run): the store, the chrome and the appearance all say what it
    /// says, and for a default palette it IS the shipped static set.
    @Test func theOneSettingsRoadIsWhatEveryHostResolves() {
        for voice in ThemeVoice.allCases {
            for dark in [false, true] {
                let plain = settings(.default, voice: voice)
                #expect(VoiceTokens.resolve(settings: plain, dark: dark)
                    == VoiceTokens.resolve(voice: voice, dark: dark))
                let custom = settings(.custom, voice: voice, room: "E07A5F", accent: "3D5A80")
                let road = VoiceTokens.resolve(settings: custom, dark: dark)
                #expect(road == VoiceTokens.resolve(
                    voice: voice, palette: .custom,
                    tint: PaletteTint(room: "E07A5F", accent: "3D5A80"), dark: dark))
                #expect(EditorSurfaceChrome(tokens: custom, dark: dark).tokens == road)
                #expect(EditorAppearance(custom, dark: dark).tokens == road)
            }
        }
    }

    // MARK: The cost of a palette click on a mounted surface (the R1-1 walk)

    /// **The decision is pure:** a colour-only chrome change — a palette, a
    /// custom seed, the appearance — never re-writes the storage's base
    /// attributes; only the inputs of `EditorDocument.baseAttributes` do
    /// (the voice, inline comments, the paragraph gap). The ink moves with
    /// the voice or the appearance, never with a palette.
    @Test func aColourOnlyChromeChangeNeedsNoStorageRefresh() {
        let plain = EditorSurfaceChrome(tokens: settings(.default), dark: false)
        let lavender = EditorSurfaceChrome(tokens: settings(.lavender), dark: false)
        let custom = EditorSurfaceChrome(tokens: settings(.custom, room: "E07A5F"), dark: false)
        let dark = EditorSurfaceChrome(tokens: settings(.lavender), dark: true)
        #expect(plain.needsStorageRefresh(from: nil), "the first application is the full road")
        #expect(!lavender.needsStorageRefresh(from: plain), "a palette moves no base attribute")
        #expect(!custom.needsStorageRefresh(from: lavender), "nor does a seed")
        #expect(!dark.needsStorageRefresh(from: lavender), "nor the appearance")
        #expect(!lavender.inkChanged(from: plain), "a palette never recolours the ink")
        #expect(dark.inkChanged(from: lavender), "the appearance does")
        let study = EditorSurfaceChrome(tokens: settings(.lavender, voice: .study), dark: false)
        #expect(study.needsStorageRefresh(from: lavender), "the voice is the font")
        #expect(study.inkChanged(from: lavender))
        var inline = settings(.lavender)
        inline.inlineComments = true
        #expect(EditorSurfaceChrome(tokens: inline, dark: false).needsStorageRefresh(from: lavender),
                "inline comments are paragraph room")
        let otherGap = ParagraphGap.allCases.first { $0 != .standard }!
        let gap = EditorSurfaceChrome(
            voice: .terminal, dark: false, inlineComments: false,
            palette: .lavender, paragraphGap: otherGap)
        #expect(gap.needsStorageRefresh(from: lavender), "the gap is paragraph style")
    }

    /// **The behaviour, on a mounted TK2 surface:** after the first (full)
    /// application, a palette-only re-apply writes NOTHING to a plain note's
    /// storage — no full-range base refresh, no ink write — while the caret
    /// takes the palette's accent; a paragraph-gap change still takes the
    /// full road and writes the whole storage. The walk of the R1-1 fix
    /// caught the full road jumping a 262-block note's viewport on a palette
    /// click; this is what keeps that road for the re-font it was built for.
    @Test func aPaletteClickWritesNothingToAPlainNotesStorage() throws {
        let view = EditorTextView.makeEditor().textView
        let text = (1...200)
            .map { "Paragraph \($0) of a plain note, with no markdown anywhere in it." }
            .joined(separator: "\n")
        view.textStorage?.setAttributedString(NSAttributedString(string: text))
        let wasAdopted = EditorTypography.isAdopted
        defer { EditorTypography.isAdopted = wasAdopted }

        let plain = EditorSurfaceChrome(tokens: settings(.default), dark: false)
        view.applyVoiceChrome(plain)
        let storage = try #require(view.textStorage)
        let counter = StorageEditCounter()
        let previousDelegate = storage.delegate
        storage.delegate = counter
        defer { storage.delegate = previousDelegate }

        let lavender = EditorSurfaceChrome(tokens: settings(.lavender), dark: false)
        view.applyVoiceChrome(lavender, previous: plain)
        #expect(counter.edits.isEmpty, "a palette click must not touch the storage: \(counter.edits)")
        let caret = view.insertionPointColor.usingColorSpace(.sRGB)
        let accent = NSColor(lavender.tokens.accent).usingColorSpace(.sRGB)
        #expect(caret != nil && accent != nil)
        if let caret, let accent {
            #expect(abs(caret.redComponent - accent.redComponent) < 0.002)
            #expect(abs(caret.greenComponent - accent.greenComponent) < 0.002)
            #expect(abs(caret.blueComponent - accent.blueComponent) < 0.002)
        }

        let otherGap = ParagraphGap.allCases.first { $0 != .standard }!
        let gap = EditorSurfaceChrome(
            voice: .terminal, dark: false, inlineComments: false,
            palette: .lavender, paragraphGap: otherGap)
        view.applyVoiceChrome(gap, previous: lavender)
        #expect(counter.edits.contains { $0.length == storage.length },
                "the re-font road still refreshes the whole storage")
    }

    /// **A note WITH markdown faces near both ends** — the 262-block story's
    /// shape, `_the_` italics in its first paragraph and a link in its last.
    /// A palette-only re-apply must re-derive the faces (the link takes the
    /// palette's accent) as LINE-SCOPED edits — never one edit spanning the
    /// document, which is what the whole-document `style` reports (the
    /// union of every face inside one begin/endEditing) and what jumped the
    /// walk's viewport a second time. RED before `restyleFacedLines`: one
    /// edit of length ≈ the whole storage.
    @Test func aPaletteClickOnAFacedNoteEditsOnlyTheFacedLines() throws {
        let view = EditorTextView.makeEditor().textView
        var paragraphs = (1...200).map { "Paragraph \($0) of a long note, plain prose." }
        paragraphs[0] = "To Sherlock Holmes she is always _the_ woman."
        paragraphs[199] = "See [the walk](https://example.com/walk) for the rest."
        let text = paragraphs.joined(separator: "\n")
        view.textStorage?.setAttributedString(NSAttributedString(string: text))
        let wasAdopted = EditorTypography.isAdopted
        defer { EditorTypography.isAdopted = wasAdopted }

        let plain = EditorSurfaceChrome(tokens: settings(.default), dark: false)
        view.applyVoiceChrome(plain)
        let storage = try #require(view.textStorage)
        let counter = StorageEditCounter()
        let previousDelegate = storage.delegate
        storage.delegate = counter
        defer { storage.delegate = previousDelegate }

        let lavender = EditorSurfaceChrome(tokens: settings(.lavender), dark: false)
        view.applyVoiceChrome(lavender, previous: plain)
        let longestLine = paragraphs.map(\.utf16.count).max()! + 1
        #expect(!counter.edits.isEmpty, "the faces must re-derive")
        #expect(counter.edits.allSatisfy { $0.length <= longestLine },
                "every edit is line-scoped, never the document: \(counter.edits)")
        // …and the link now wears the palette's accent.
        let linkAt = (text as NSString).range(of: "the walk").location
        let linkColour = (storage.attribute(.foregroundColor, at: linkAt, effectiveRange: nil)
            as? NSColor)?.usingColorSpace(.sRGB)
        let accent = NSColor(lavender.tokens.accent).usingColorSpace(.sRGB)
        #expect(linkColour != nil && accent != nil)
        if let linkColour, let accent {
            #expect(abs(linkColour.redComponent - accent.redComponent) < 0.002)
            #expect(abs(linkColour.greenComponent - accent.greenComponent) < 0.002)
            #expect(abs(linkColour.blueComponent - accent.blueComponent) < 0.002)
        }
    }

    /// `MarkdownStyling.palette` has two writers — `RootView` from the
    /// store's tokens and `applyVoiceChrome` from the chrome's. They must
    /// agree, or the link colour flips at every surface mount.
    @Test func theMarkdownLinkColourFromTheChromeIsTheStoresLinkColour() {
        let chrome = EditorSurfaceChrome(tokens: settings(.lavender), dark: false)
        let store = VoiceTokens.resolve(
            voice: .terminal, palette: .lavender, tint: .none, dark: false)
        let fromChrome = MarkdownStyling.Palette(tokens: chrome.tokens).link
            .usingColorSpace(.sRGB)
        let fromStore = MarkdownStyling.Palette(tokens: store).link
            .usingColorSpace(.sRGB)
        #expect(fromChrome != nil && fromStore != nil)
        if let fromChrome, let fromStore {
            #expect(abs(fromChrome.redComponent - fromStore.redComponent) < 0.002)
            #expect(abs(fromChrome.greenComponent - fromStore.greenComponent) < 0.002)
            #expect(abs(fromChrome.blueComponent - fromStore.blueComponent) < 0.002)
        }
    }
}

/// Counts the storage's processed edits — the honest measure of "did this
/// touch the document": every `beginEditing`/attribute write lands here
/// with the range it edited.
private final class StorageEditCounter: NSObject, NSTextStorageDelegate {
    nonisolated(unsafe) var edits: [NSRange] = []

    nonisolated func textStorage(
        _ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions,
        range editedRange: NSRange, changeInLength delta: Int
    ) {
        edits.append(editedRange)
    }
}
