//
//  MobilePhoneOwnLookTests.swift
//  VariorumMobileTests
//
//  VM-247 (the VM-260 run, batch 3) — **THIS PHONE'S OWN LOOK, as built.** The
//  fence's red-on-old pins are `MobilePhoneOwnLookFenceTests` (the voice door
//  writes no row; a library-written look moves the phone nothing). These pin the
//  new road itself — new behaviour, so GUARDS on the tip, not red-on-old pins
//  (the symbols are new):
//  · the choice is kept in THIS device's defaults, one key per choice, a strange
//    value reading as the fresh default (her R-260-3: Study under the sea-glass,
//    on the paper), the custom palette never offered, and nothing remembered
//    under a test host's inert owner;
//  · every Look choice — the palette, the background, the text size, the voice —
//    writes no `setting` row and no outbox row, and moves the face it names;
//  · the cream is the VOICE's own room under every palette, never the palette's
//    (the one rule, both forms), and a note opened in Write wears it from edge to
//    edge when she chose it — read as pixels off a real window;
//  · Settings ▸ Look offers the phone's own choices, a segment drives the phone's
//    owner and is remembered in its own defaults, and the palette's door answers
//    across 44 under the Mac's label;
//  · the palette menu speaks the Mac's own words (held to the Mac's source).
//

import Foundation
import GRDB
import SwiftUI
import Testing
import UIKit
import VariorumCore
@testable import VariorumMobile

@MainActor
@Suite("VM-247 — this phone's own look: the choice, its keys, the cream, Settings ▸ Look", .serialized)
struct MobilePhoneOwnLookTests {
    private static let appRoot = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()  // VariorumMobileTests
        .deletingLastPathComponent()  // App/Variorum

    private func scratch(_ name: String) -> UserDefaults {
        let suite = "vm247.look.\(name)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    private func settingRows(_ session: AppSession) async throws -> [String] {
        try await session.database.read { db in
            try Row.fetchAll(db, sql: "SELECT key, value FROM setting ORDER BY key")
                .map { "\($0["key"] as String)=\($0["value"] as String)" }
        }
    }

    private func settingOutbox(_ session: AppSession) async throws -> [String] {
        try await session.database.read { db in
            try String.fetchAll(
                db, sql: "SELECT row_id FROM sync_outbox WHERE table_name = 'setting' ORDER BY row_id")
        }
    }

    private func rgb(_ color: UIColor, dark: Bool) -> PixelColor {
        PixelColor(color, traits: UITraitCollection(userInterfaceStyle: dark ? .dark : .light))
    }

    /// The same colour, to well under one 8-bit step.
    private func same(_ a: PixelColor, _ b: PixelColor) -> Bool { a.distance(to: b) <= 0.002 }

    // MARK: - The choice and its keys

    /// **Her R-260-3, and the appearance's road.** A phone that has chosen
    /// nothing wears Study under the sea-glass on the paper at the default size —
    /// the unset library's own constants. Each choice is kept under its own key
    /// in THIS device's defaults and read back by a fresh owner; a value that is
    /// not a choice — or the custom palette, which the phone does not offer —
    /// reads as the fresh default; the inert owner (no defaults) remembers
    /// nothing.
    @Test func theLookIsKeptInThisDevicesDefaults() {
        let defaults = scratch("keys")
        let owner = MobileLookController(defaults: defaults)
        #expect(owner.choice == MobileLookChoice.fresh)
        #expect(MobileLookChoice.fresh.voice == Queries.ThemeSettings.unsetStoreVoice
                && MobileLookChoice.fresh.voice == .study)
        #expect(MobileLookChoice.fresh.palette == Queries.ThemeSettings.unsetStorePalette
                && MobileLookChoice.fresh.palette == .seaglass)
        #expect(MobileLookChoice.fresh.ground == .paper && MobileLookChoice.fresh.textSize == .standard)

        var told = 0
        owner.onChange = { told += 1 }
        owner.setVoice(.terminal)
        owner.setPalette(.tealAndRust)
        owner.setGround(.cream)
        owner.setTextSize(.larger)
        #expect(told == 4, "every change tells the router once")
        owner.setGround(.cream)
        owner.setPalette(.custom)
        #expect(told == 4, "a choice already in force, or one the phone does not offer, changes nothing")
        #expect(owner.choice.palette == .tealAndRust)

        #expect(defaults.string(forKey: MobileLookChoice.Key.voice) == "terminal")
        #expect(defaults.string(forKey: MobileLookChoice.Key.palette) == "teal_rust")
        #expect(defaults.string(forKey: MobileLookChoice.Key.ground) == "cream")
        #expect(defaults.string(forKey: MobileLookChoice.Key.textSize) == "larger")
        let reread = MobileLookController(defaults: defaults).choice
        #expect(reread == MobileLookChoice(voice: .terminal, palette: .tealAndRust, ground: .cream, textSize: .larger),
                "a fresh owner reads the device's own choice back")

        for (key, strange) in [(MobileLookChoice.Key.voice, "serif"), (MobileLookChoice.Key.palette, "custom"),
                               (MobileLookChoice.Key.ground, "wallpaper"), (MobileLookChoice.Key.textSize, "huge")] {
            defaults.set(strange, forKey: key)
        }
        #expect(MobileLookChoice.remembered(defaults) == MobileLookChoice.fresh,
                "a value that is not a choice reads as the fresh default")
        #expect(!MobileLookChoice.palettes.contains(.custom))
        #expect(MobileLookChoice.palettes.count == ThemePalette.allCases.count - 1)

        let inert = MobileLookController(defaults: nil)
        inert.setVoice(.terminal)
        #expect(inert.choice.voice == .terminal)
        #expect(MobileLookController(defaults: nil).choice == MobileLookChoice.fresh,
                "the inert owner remembers nothing")
        // Never the retired VM-51 key (`MobileLibraryLookTests` scans the sources too).
        for key in [MobileLookChoice.Key.voice, MobileLookChoice.Key.palette,
                    MobileLookChoice.Key.ground, MobileLookChoice.Key.textSize] {
            #expect(!key.contains("mobile.themeVoice"))
        }
    }

    /// **The overlay** — the library's landed settings with the phone's voice and
    /// palette in place of the library's, the custom seeds cleared, every other
    /// setting the library's.
    @Test func theOverlayTakesOnlyTheLook() {
        var library = Queries.ThemeSettings()
        library.voice = .terminal
        library.palette = .custom
        library.customRoom = "B9A7E6"
        library.customAccent = "334455"
        library.seamsVisible = true
        library.arrivalFlash = false
        let choice = MobileLookChoice(voice: .study, palette: .mint, ground: .cream, textSize: .small)
        let worn = choice.over(library)
        #expect(worn.voice == .study && worn.palette == .mint)
        #expect(worn.customRoom == nil && worn.customAccent == nil)
        #expect(worn.seamsVisible && !worn.arrivalFlash, "the library's other settings stand")
    }

    // MARK: - Every choice: no row, and the face moves

    /// **No Look choice reaches the library** — the palette, the background, the
    /// text size and the voice, each through Settings ▸ Look's own doors: the
    /// `setting` table and its outbox are what they were, while the face each
    /// names moved at once (the palette's accent, the editor's ground, the note's
    /// body, the voice's face).
    @Test func everyLookChoiceWritesNoSettingRowAndMovesTheFace() async throws {
        try await withEditorWorld { session, _ in
            defer { MobileEditorStyle.adopt(Queries.ThemeSettings()) }
            let router = MobileShellRouter()
            router.bindTheme(session: session)
            let theme = try #require(router.theme)
            let held = Task { await theme.start() }
            defer { held.cancel() }
            try await untilLanded { MobileEditorStyle.settings.palette == .seaglass }
            let rows = try await settingRows(session)
            let outbox = try await settingOutbox(session)

            router.look.setPalette(.roseAndMoss)
            #expect(MobileEditorStyle.settings.palette == .roseAndMoss)
            let rose = VoiceTokens.resolve(voice: .study, palette: .roseAndMoss, tint: .none, dark: false)
            #expect(same(rgb(MobileEditorStyle.face.accent, dark: false),
                         PixelColor(UIColor(rose.accent), traits: UITraitCollection(userInterfaceStyle: .light))),
                    "the face wears the palette chosen on the phone")

            router.look.setGround(.cream)
            #expect(MobileEditorStyle.ground == .cream)
            #expect(MobileEditorStyle.face.paper === MobileEditorStyle.face.room, "the editor's ground is the cream")

            router.look.setTextSize(.larger)
            #expect(abs(MobileEditorStyle.baseFont.pointSize - 18) < 0.01,
                    "the note's body at Larger: \(MobileEditorStyle.baseFont.pointSize)")

            router.setVoice(.terminal)
            #expect(MobileEditorStyle.voice == .terminal)

            #expect(try await settingRows(session) == rows, "a Look choice wrote the library's settings")
            #expect(try await settingOutbox(session) == outbox, "a Look choice queued a synced row")
        }
    }

    // MARK: - The cream

    /// **The cream is the VOICE's own room under every palette** — P-47-16's road
    /// (b), her choice — **never the palette's room** (R-47-1): the SwiftUI rule
    /// (`MobileNoteGround.color`) and the editor face's `paper` agree, in both
    /// voices, light and dark, under the sea-glass and a bold palette; the paper
    /// stays `tokens.surface`.
    @Test func theCreamIsTheVoicesOwnRoomNeverThePalettes() {
        defer { MobileEditorStyle.adopt(Queries.ThemeSettings()) }
        for voice in ThemeVoice.allCases {
            for palette in [ThemePalette.seaglass, .tealAndRust] {
                var settings = Queries.ThemeSettings()
                settings.voice = voice
                settings.palette = palette
                for dark in [false, true] {
                    let label = "\(voice) \(palette) dark: \(dark)"
                    let traits = UITraitCollection(userInterfaceStyle: dark ? .dark : .light)
                    let tokens = VoiceTokens.resolve(settings: settings, dark: dark)
                    let own = PixelColor(UIColor(VoiceTokens.resolve(voice: voice, dark: dark).room), traits: traits)
                    let cream = PixelColor(UIColor(MobileNoteGround.cream.color(tokens: tokens, dark: dark)), traits: traits)
                    let paper = PixelColor(UIColor(MobileNoteGround.paper.color(tokens: tokens, dark: dark)), traits: traits)
                    #expect(same(cream, own), "the cream is the voice's own room — \(label)")
                    #expect(same(paper, PixelColor(UIColor(tokens.surface), traits: traits)), "the paper — \(label)")
                    if !dark {
                        #expect(!same(cream, PixelColor(UIColor(tokens.room), traits: traits)),
                                "never the palette's room under her words — \(label)")
                    }

                    MobileEditorStyle.adopt(settings, ground: .cream)
                    #expect(same(rgb(MobileEditorStyle.face.paper, dark: dark), own),
                            "the editor's cream is the same room — \(label)")
                    MobileEditorStyle.adopt(settings, ground: .paper)
                    #expect(same(rgb(MobileEditorStyle.face.paper, dark: dark),
                                 PixelColor(UIColor(tokens.surface), traits: traits)),
                            "the editor's paper — \(label)")
                }
            }
        }
        // A real text view takes it through its one ground line.
        var study = Queries.ThemeSettings()
        study.voice = .study
        study.palette = .seaglass
        MobileEditorStyle.adopt(study, ground: .cream)
        let view = MobileEditorTextView.make()
        view.applyVoiceChrome()
        let ground = view.backgroundColor ?? .clear
        #expect(same(rgb(ground, dark: false), rgb(MobileEditorStyle.face.room, dark: false)),
                "the text view's own ground is the cream")
    }

    /// **A note opened in Write wears the cream she chose, edge to edge** — the
    /// editor's margin (the face's ground) and the strips under the status bar and
    /// past the home indicator (the screen's declared grounds), read as pixels off
    /// a real window of the shell; and never the paper. (The paper's own pin is
    /// `MobileScreenEdgeGroundsTests.inANoteThePaperRunsToBothEdges`.)
    @Test(arguments: [false, true])
    func aNoteInWriteWearsTheCreamSheChose(dark: Bool) async throws {
        try await withEditorWorld { session, _ in
            defer { MobileEditorStyle.adopt(Queries.ThemeSettings()) }
            let router = MobileShellRouter()
            router.look.setGround(.cream)
            try await withSceneSurface(
                MobileShellView(session: session, services: nil, router: router), dark: dark
            ) { surface in
                await surface.settle(50)
                let door = try #require(surface.onScreen(MobileShelfFaces.todayDoorSpoken),
                                        "the Today door: \(surface.labels)")
                #expect(door.accessibilityActivate())
                #expect(await eventually { !router.editors.registeredPostIDs.isEmpty },
                        "a note opened in Write")
                await surface.settle(60)
                let tokens = router.tokens(dark: dark)
                let cream = PixelColor(
                    UIColor(ReadingPageTokens.room(voice: tokens.voice, dark: dark)), traits: surface.traits)
                let paper = PixelColor(UIColor(tokens.surface), traits: surface.traits)
                try #require(cream.distance(to: paper) > 0.02,
                             "the cream \(cream) and the paper \(paper) differ enough to tell apart")
                let pixels = try surface.render()
                let bounds = surface.window.bounds
                let insets = surface.host.view.safeAreaInsets
                let tolerance = 0.012
                let margin = pixels.color(at: CGPoint(x: 2, y: bounds.midY))
                #expect(margin.distance(to: cream) <= tolerance,
                        "dark \(dark): the note's margin reads \(margin), the cream is \(cream)")
                for point in [CGPoint(x: 2, y: insets.top / 2), CGPoint(x: bounds.midX, y: insets.top / 2),
                              CGPoint(x: 2, y: bounds.maxY - insets.bottom / 2),
                              CGPoint(x: bounds.maxX - 2, y: bounds.maxY - insets.bottom / 2)] {
                    let seen = pixels.color(at: point)
                    #expect(seen.distance(to: cream) <= tolerance,
                            "dark \(dark): at the screen's edge \(point) the note shows \(seen), not the cream \(cream)")
                }
            }
        }
    }

    // MARK: - Settings ▸ Look

    /// **Settings ▸ Look is the phone's own.** The voice, the background and the
    /// text size are the system's segmented control and drive THIS phone's owner
    /// (remembered in its own defaults); the colour palette's door — the system
    /// menu under the Mac's label, naming the chosen palette — answers across 44
    /// and the whole row's width.
    @Test func theLookGroupDrivesThePhonesOwnChoices() async throws {
        try await withEditorWorld { session, _ in
            defer { MobileEditorStyle.adopt(Queries.ThemeSettings()) }
            let defaults = scratch("settings")
            let router = MobileShellRouter(
                appearance: MobileAppearanceController(defaults: scratch("settings.appearance"), windows: { [] }),
                look: MobileLookController(defaults: defaults))
            let sheet = MobileSettingsView(session: session, router: router, services: nil)
            try await withHostedSurface(sheet, size: CGSize(width: 402, height: 1400)) { surface in
                await surface.settle(30)
                @MainActor func segment(_ word: String) -> NSObject? {
                    surface.visibleElements.first {
                        $0.accessibilityLabel == word && $0.accessibilityTraits.contains(.button)
                    }
                }
                for word in ["Paper", "Cream", "Smaller", "Small", "Default", "Large", "Larger"] {
                    #expect(segment(word) != nil, "\(word)'s segment — labels were \(surface.visibleLabels)")
                }
                #expect(segment("Paper")?.accessibilityTraits.contains(.selected) == true, "the fresh paper")
                #expect(segment("Default")?.accessibilityTraits.contains(.selected) == true, "the fresh size")
                #expect(segment("Study")?.accessibilityTraits.contains(.selected) == true, "the fresh voice")

                #expect(surface.activate("Cream"))
                await surface.settle(10)
                #expect(router.look.choice.ground == .cream, "the segment drove the phone's owner")
                #expect(defaults.string(forKey: MobileLookChoice.Key.ground) == "cream",
                        "remembered in this device's own defaults")
                #expect(surface.activate("Large"))
                await surface.settle(10)
                #expect(router.look.choice.textSize == .large)
                #expect(surface.activate("Terminal"))
                await surface.settle(10)
                #expect(router.look.choice.voice == .terminal && router.voice == .terminal)
                #expect(defaults.string(forKey: MobileLookChoice.Key.voice) == "terminal")

                // The door is the element under the label that carries the chosen
                // palette as its value (the row's own label line speaks the same
                // word, and carries no value).
                let palette = try #require(
                    surface.visibleElements.first {
                        $0.accessibilityLabel == MobileSettingsView.paletteLabel
                            && $0.accessibilityValue == MobileSettingsView.paletteWord(.seaglass)
                    },
                    "the palette's door, naming the chosen palette — labels were \(surface.visibleLabels)")
                let frame = palette.accessibilityFrame
                #expect(frame.height >= 43.5, "the palette's door answers across 44 tall: \(frame)")
                #expect(frame.width >= 402 - 2 * PhoneMetrics.gutter - 1,
                        "the palette's door is the row's whole width: \(frame)")
            }
        }
    }

    /// **The palette menu's sections** carry every palette the phone offers
    /// exactly once — the custom palette none — in the Mac's order.
    @Test func thePaletteMenuOffersEveryPresetOnce() {
        let listed = MobileSettingsView.paletteSections.flatMap(\.palettes)
        #expect(listed.count == Set(listed).count, "no palette twice")
        #expect(Set(listed) == Set(MobileLookChoice.palettes), "every offered palette, and only those")
        #expect(!listed.contains(.custom))
        #expect(listed.first == .seaglass, "the default first")
    }

    /// **The palette's words are the Mac's own** (`PaletteCopy`, the Mac's
    /// Settings ▸ General swatch strip) — the row's label, every palette's name
    /// and the section headings, held to the Mac's source so the two cannot drift
    /// (P-47-24's precedent, `theAppearanceWordsAreTheMacsOwn`).
    @Test func thePaletteWordsAreTheMacsOwn() throws {
        let mac = try String(
            contentsOf: Self.appRoot.appendingPathComponent("Variorum/Features/Settings/PaletteCopy.swift"),
            encoding: .utf8)
        #expect(mac.contains("static let title = \"\(MobileSettingsView.paletteLabel)\""), "the Mac's label")
        for palette in MobileLookChoice.palettes {
            let word = MobileSettingsView.paletteWord(palette)
            let caseName = String(describing: palette)
            #expect(mac.contains("case .\(caseName): return \"\(word)\""),
                    "the Mac's strip says \(word) for \(caseName)")
        }
        for section in MobileSettingsView.paletteSections {
            guard let title = section.title else { continue }
            #expect(mac.contains("return \"\(title)\""), "the Mac's heading \(title)")
        }
    }
}
