//
//  MobileLibraryLookTests.swift
//  VariorumMobileTests
//
//  VM-51 (the VM-47 run, batch 3) — the phone wears the LIBRARY's voice and
//  palette (her LK-1/LK-2: "follow the library but if the phone has dark mode
//  on, that shouldn't change what your mac is like"). The road: the shell
//  router holds the open library's theme store (the Mac's `ThemeStore`,
//  hoisted to `Shared/`), resolves every chrome token through the ONE
//  settings → tokens road, and adopts the landed settings into the UIKit
//  editor face (`MobileEditorStyle.adopt`, its one app writer — QUESTIONS
//  #195 MINOR 3) and every open editor.
//
//  What these pin: a fresh library reads Study under the sea-glass; a change
//  written to the library (from the Mac, or synced) re-resolves the phone;
//  light or dark is an argument the DEVICE supplies, never a setting; the
//  placeholder before a library answers is exactly what an empty library
//  reads; the editor face's adoption is object-stable and shares the voice's
//  own colour objects; the note in Write is on the paper (piece 3.10); the
//  retired phone preference is read nowhere.
//
//  **VM-247 (the VM-260 run, batch 3) MOVED what her ruling moved** ("I don't
//  like that the theme syncs between mac and phone either it's annoying" ·
//  "the voice should also be per device"): the look is now THIS PHONE's own,
//  laid over the library's landed settings — so a fresh phone still wears
//  Study under the sea-glass (her R-260-3, the same constants), a look chosen
//  ON THE PHONE re-resolves its chrome, its face and an open editor (the
//  library-written change's old pin, re-pointed), and a library-written change
//  moves nothing (its fence, `MobilePhoneOwnLookFenceTests`). The retired
//  VM-51-era phone key stays unread: the phone's look keys are new names.
//

import Foundation
import GRDB
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

/// Poll a main-actor condition until it holds (a landed observation arrives
/// a few milliseconds after the write that caused it), recording an issue if
/// it never does.
@MainActor
func untilLanded(
    within timeout: Duration = .seconds(5),
    _ condition: @MainActor () -> Bool
) async throws {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)
    while !condition() {
        guard clock.now < deadline else {
            Issue.record("the look never landed within \(timeout)")
            return
        }
        try await Task.sleep(for: .milliseconds(10))
    }
}

@MainActor
@Suite("VM-51 · VM-247 — the phone's look: its own, over the library's settings")
struct MobileLibraryLookTests {
    /// 24-bit sRGB of a colour as one appearance resolves it.
    private func rgb(_ color: UIColor, dark: Bool) -> UInt32 {
        let resolved = color.resolvedColor(
            with: UITraitCollection(userInterfaceStyle: dark ? .dark : .light))
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        _ = resolved.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        func byte(_ value: CGFloat) -> UInt32 { UInt32((min(max(value, 0), 1) * 255).rounded()) }
        return (byte(red) << 16) | (byte(green) << 8) | byte(blue)
    }

    private func rgb(_ color: Color, dark: Bool) -> UInt32 {
        rgb(UIColor(color), dark: dark)
    }

    /// A router bound to the world's library with its store running — the
    /// shell's own composition (`bindTheme` + the held `start`).
    private func boundRouter(_ session: AppSession) throws -> (MobileShellRouter, Task<Void, Never>) {
        let router = MobileShellRouter()
        router.bindTheme(session: session)
        let theme = try #require(router.theme)
        return (router, Task { await theme.start() })
    }

    // MARK: - The library's look, landed

    /// A library that has chosen nothing reads STUDY under the SEA-GLASS
    /// (AppSpec §12; `Queries.ThemeSettings.unsetStoreVoice/Palette`) — and a
    /// phone that has chosen nothing wears exactly that too (VM-247, her R-260-3:
    /// the same constants): the chrome's tokens are the four-parameter
    /// resolver's for the composed settings, and the editor face adopted them at
    /// the library's first landing. Before VM-51 the phone wore its own Terminal
    /// in the Classic colours.
    @Test func aFreshLibraryWearsStudyUnderTheSeaGlass() async throws {
        try await withEditorWorld { session, _ in
            defer { MobileEditorStyle.adopt(Queries.ThemeSettings()) }
            let (router, held) = try boundRouter(session)
            defer { held.cancel() }
            try await untilLanded { MobileEditorStyle.settings.palette == .seaglass }

            #expect(router.voice == .study)
            #expect(router.settings.palette == .seaglass)
            for dark in [false, true] {
                #expect(router.tokens(dark: dark) == VoiceTokens.resolve(
                    voice: .study, palette: .seaglass, tint: .none, dark: dark),
                    "the chrome rides the ONE settings → tokens road (dark: \(dark))")
            }
            // The editor face took the same look: the voice's type, the
            // palette's accent in both appearances.
            #expect(MobileEditorStyle.voice == .study)
            #expect(MobileEditorStyle.baseFont == MobileEditorStyle.studyFace.body)
            for dark in [false, true] {
                let expected = VoiceTokens.resolve(
                    voice: .study, palette: .seaglass, tint: .none, dark: dark)
                #expect(rgb(MobileEditorStyle.face.accent, dark: dark) == rgb(expected.accent, dark: dark))
                #expect(rgb(MobileEditorStyle.face.takeLine, dark: dark) == rgb(expected.takeLine, dark: dark))
                #expect(rgb(MobileEditorStyle.face.card, dark: dark) == rgb(expected.card, dark: dark))
            }
        }
    }

    /// **A look chosen ON THE PHONE** (VM-247 — MOVED with her ruling: this pin
    /// was VM-51's "a look written elsewhere reaches the phone", whose road her
    /// ruling closed; the inverse is the fence, `MobilePhoneOwnLookFenceTests`)
    /// re-resolves the phone: the chrome, the editor face, and an OPEN editor's
    /// storage (the look seam's restyle) — and back to the voice's own colours,
    /// the byte-identical road.
    @Test func aLookChosenOnThePhoneReachesItsChromeItsFaceAndAnOpenEditor() async throws {
        try await withEditorWorld { session, _ in
            defer { MobileEditorStyle.adopt(Queries.ThemeSettings()) }
            let post = try await session.runner.run { ops in
                try ops.createPost(title: "looked", profile: .blog)
            }
            _ = try await session.runner.run { ops in
                try ops.newBlock(in: post.id, text: "Looked text.", at: .end)
            }
            let (model, storage) = makeEditor(session, postID: post.id)
            await model.loadOnce()
            let (router, held) = try boundRouter(session)
            defer { held.cancel() }
            await router.editors.register(model, tab: .shelf)
            try await untilLanded { MobileEditorStyle.settings.palette == .seaglass }

            // Settings ▸ Look's own doors.
            router.setVoice(.terminal)
            router.look.setPalette(.lavender)
            #expect(router.voice == .terminal && MobileEditorStyle.settings.palette == .lavender,
                    "the phone's look moved in the same turn")
            #expect(router.tokens(dark: false) == VoiceTokens.resolve(
                voice: .terminal, palette: .lavender, tint: .none, dark: false))
            let font = storage.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
            #expect(font == MobileEditorStyle.terminalFace.body,
                    "the OPEN editor re-based on the phone's voice")
            let lavender = VoiceTokens.resolve(
                voice: .terminal, palette: .lavender, tint: .none, dark: false)
            #expect(rgb(MobileEditorStyle.face.accent, dark: false) == rgb(lavender.accent, dark: false))
            #expect(MobileEditorStyle.markdownPalette.link == MobileEditorStyle.face.accent,
                    "the markdown link is the palette's accent")

            // And back to the voice's own colours — the byte-identical road.
            router.look.setPalette(.default)
            #expect(MobileEditorStyle.settings.palette == .default)
            #expect(MobileEditorStyle.face.accent == MobileEditorStyle.terminalFace.accent,
                    "`.default` is the voice's static face itself")
        }
    }

    /// LIGHT OR DARK IS THE DEVICE'S (LK-2): the appearance is an argument the
    /// device supplies to the road, never a setting the phone writes. The same
    /// landed settings give both appearances — black room in dark (R51), the
    /// palette's hue in light — and nothing the phone does with them touches
    /// the library's rows.
    @Test func lightOrDarkStaysTheDevicesOwn() async throws {
        try await withEditorWorld { session, _ in
            defer { MobileEditorStyle.adopt(Queries.ThemeSettings()) }
            let (router, held) = try boundRouter(session)
            defer { held.cancel() }
            try await untilLanded { MobileEditorStyle.settings.palette == .seaglass }
            let before = try await session.database.read { db in
                try Row.fetchAll(db, sql: "SELECT key, value FROM setting ORDER BY key")
                    .map { "\($0["key"] as String)=\($0["value"] as String)" }
            }

            let light = router.tokens(dark: false)
            let dark = router.tokens(dark: true)
            #expect(rgb(dark.room, dark: true) == 0x000000, "R51: the dark room is black")
            #expect(rgb(light.room, dark: false) != rgb(dark.room, dark: true))
            let seaglass = try #require(PalettePreset.all[.seaglass])
            #expect(rgb(light.room, dark: false) == PaletteDerivation.derive(seaglass, dark: false).room,
                    "light wears the sea-glass room")
            // The UIKit face's colours are dynamic: one object, both appearances.
            #expect(rgb(MobileEditorStyle.face.surface, dark: false)
                    != rgb(MobileEditorStyle.face.surface, dark: true))

            let after = try await session.database.read { db in
                try Row.fetchAll(db, sql: "SELECT key, value FROM setting ORDER BY key")
                    .map { "\($0["key"] as String)=\($0["value"] as String)" }
            }
            #expect(before == after, "resolving an appearance wrote nothing to the library")
        }
    }

    /// The placeholder (P-47-15) — what the library's store holds before it
    /// answers — IS what a library that has chosen nothing reads, computed by the
    /// store's own read over an empty table; under a phone that has chosen
    /// nothing (VM-247, R-260-3) the shell's first frame wears exactly it.
    @Test func thePlaceholderIsWhatAnEmptyLibraryReads() async throws {
        let db = try AppDatabase.inMemory()
        let empty = try await db.read { try Queries.themeSettings($0) }
        #expect(MobileShellRouter.placeholder == empty)
        try await withEditorWorld { session, _ in
            // A router BOUND to a library wears the placeholder until the
            // store's first landing (the shell's first frame).
            let router = MobileShellRouter()
            router.bindTheme(session: session)
            #expect(router.settings == empty)
            #expect(router.tokens(dark: false) == VoiceTokens.resolve(settings: empty, dark: false))
            // With NO library bound (the lobby; harness use), the router lays the
            // phone's own look over the editor face's settings (VM-247 — MOVED:
            // it reported the face's own look, the library's, before).
            #expect(MobileShellRouter().settings == MobileLookChoice.fresh.over(MobileEditorStyle.settings))
        }
    }

    // MARK: - The editor face's one writer

    /// `adopt` answers whether the FACE moved (voice, palette or seeds) — the
    /// router restyles the open editors only then — and a palette face is
    /// built once and SHARES the voice's own colour objects (the slots a
    /// palette does not name), so attribute equality holds across palettes.
    @Test func adoptionMovesTheFaceOnlyWhenTheLookMoves() {
        defer { MobileEditorStyle.adopt(Queries.ThemeSettings()) }
        var study = Queries.ThemeSettings()
        study.voice = .study
        MobileEditorStyle.adopt(study)

        var sameFaceOtherSetting = study
        sameFaceOtherSetting.seamsVisible.toggle()
        #expect(!MobileEditorStyle.adopt(sameFaceOtherSetting),
                "a setting the face does not wear moves nothing")

        var seaglass = study
        seaglass.palette = .seaglass
        #expect(MobileEditorStyle.adopt(seaglass), "a palette moves the face")
        let first = MobileEditorStyle.face
        let second = MobileEditorStyle.face
        #expect(first.accent === second.accent, "object-stable between reads")
        #expect(first.accent !== MobileEditorStyle.studyFace.accent, "the palette's accent")
        #expect(first.ink === MobileEditorStyle.studyFace.ink, "the voice's ink, shared")
        #expect(first.palette.marker === MobileEditorStyle.studyFace.palette.marker)
        #expect(first.palette.codeTint === MobileEditorStyle.studyFace.palette.codeTint)
        #expect(first.room === MobileEditorStyle.studyFace.room,
                "a palette never replaces the face's room slot")
        #expect(first.paper === first.surface, "the editor's ground IS the face's paper (piece 3.10)")
        #expect(first.body == MobileEditorStyle.studyFace.body)

        var custom = study
        custom.palette = .custom
        custom.customRoom = nil
        #expect(MobileEditorStyle.adopt(custom))
        #expect(MobileEditorStyle.face.accent === MobileEditorStyle.studyFace.accent,
                "a custom palette with no seed is the voice's own face (the resolver's nil road)")
    }

    /// **The note in Write is on the PAPER** (the VM-47 run, piece 3.10; her
    /// R-47-1, "prose should not be on the tint" — its test is the paper
    /// wherever her words are written; the Mac's editor reads `tokens.surface`).
    /// Read off a real editor text view's own background: in both voices, light
    /// and dark, under the sea-glass and a second palette, the ground is
    /// `tokens.surface` as the settings road resolves it — never the palette's
    /// room in light, never R51's black room in dark — and a look that lands on
    /// an open editor (`applyVoiceChrome`, the landing road) moves it. The
    /// face's `room` slot is untouched by the piece: still the voice's own.
    @Test func theEditorsGroundIsThePaper() throws {
        defer { MobileEditorStyle.adopt(Queries.ThemeSettings()) }
        let view = MobileEditorTextView.make()
        for voice in ThemeVoice.allCases {
            for palette in [ThemePalette.seaglass, .tealAndRust] {
                var settings = Queries.ThemeSettings()
                settings.voice = voice
                settings.palette = palette
                MobileEditorStyle.adopt(settings)
                view.applyVoiceChrome()
                let ground = try #require(view.backgroundColor)
                for dark in [false, true] {
                    let tokens = VoiceTokens.resolve(settings: settings, dark: dark)
                    let label = "\(voice) \(palette) dark: \(dark)"
                    #expect(rgb(ground, dark: dark) == rgb(tokens.surface, dark: dark),
                            "the editor's ground is the paper — \(label)")
                    #expect(rgb(ground, dark: dark) != rgb(tokens.room, dark: dark),
                            "never the room — \(label)")
                    let own = VoiceTokens.resolve(voice: voice, dark: dark).room
                    #expect(rgb(MobileEditorStyle.face.room, dark: dark) == rgb(own, dark: dark),
                            "the face's room slot stays the voice's own — \(label)")
                }
            }
        }
    }

    // MARK: - The retired preference

    /// LK2's phone-local voice preference RETIRED (VM-51): no phone source
    /// reads its key or names its type, so an old stored value is simply never
    /// read — nothing to crash on, nothing to obey. (A source pin, because the
    /// key lives in the test host's own defaults domain — the Debug app's —
    /// which a suite must never write.)
    @Test func theRetiredVoicePreferenceIsReadNowhere() throws {
        let phone = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()  // VariorumMobileTests
            .deletingLastPathComponent()  // App/Variorum
            .appendingPathComponent("VariorumMobile")
        let walker = try #require(FileManager.default.enumerator(at: phone, includingPropertiesForKeys: nil))
        var scanned = 0
        var offenders: [String] = []
        for case let file as URL in walker where file.pathExtension == "swift" {
            scanned += 1
            let source = try String(contentsOf: file, encoding: .utf8)
            for (index, line) in source.split(separator: "\n", omittingEmptySubsequences: false).enumerated() {
                let text = line.trimmingCharacters(in: .whitespaces)
                if text.hasPrefix("//") { continue }
                if text.contains("mobile.themeVoice") || text.contains("MobileVoicePreference") {
                    offenders.append("\(file.lastPathComponent):\(index + 1)")
                }
            }
        }
        #expect(scanned > 50, "the walk must reach the phone's sources (\(scanned) files)")
        #expect(offenders.isEmpty, "the retired preference is still read: \(offenders)")
    }
}
