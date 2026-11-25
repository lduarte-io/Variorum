//
//  MobileLook.swift
//  VariorumMobile
//
//  VM-247 (the VM-260 run, batch 3) — **THIS PHONE'S OWN LOOK.** Her words: "I
//  don't like that the theme syncs between mac and phone either it's annoying." ·
//  "the voice should also be per device." · "I also did like the cream background
//  color option. that should stay as an option for the phone". So the whole of
//  Settings ▸ Look is the device's — the voice, the colour palette, the note's
//  background, her words' size (VM-254) and (VM-53, unchanged) light · dark ·
//  follow the system — kept in
//  THIS device's defaults the way the appearance already is
//  (`AppearanceChoiceRule`'s road: one key per choice, a strange value reads as the
//  default), never the synced `setting` table. The phone stops taking its look from
//  the library and never writes one; the Mac is untouched, and so are the synced
//  rows (the library keeps its own look for the Mac).
//
//  WHAT A PHONE WEARS BEFORE SHE PICKS (her R-260-3, "Sea-glass default"): the
//  app's own fresh default — Study under the sea-glass, what a library that has
//  chosen nothing reads (`Queries.ThemeSettings.unsetStoreVoice/Palette`) — on the
//  paper. No seed is copied from the library, so a library's synced look simply
//  stops being worn here.
//
//  THE ROAD: the shell router lays this choice OVER the library's landed settings
//  (`MobileLookChoice.over(_:)`) — the voice and the palette replaced, everything
//  else the library's — and that composed value is what every chrome token, the
//  lobby, the editor face and every open editor wear (`MobileShellRouter`).
//

import Foundation
import Observation
import SwiftUI
import VariorumCore

// MARK: - The note's background

/// **The note's ground in Write** — P-47-16's two roads, now her choice: the paper
/// (road (a), as built since the VM-47 run's piece 3.10: `tokens.surface` — the
/// voice's own paper in light, the palette's hued paper in dark), or the cream
/// (road (b): the VOICE's own room under every palette — Study's warm `#FAF8F3`
/// in light, R51's black in dark — the room the Read page's cream page sits in,
/// through the same palette-less road, `ReadingPageTokens.room`). Either way never
/// the palette's room under her words (R-47-1).
nonisolated enum MobileNoteGround: String, CaseIterable, Sendable {
    case paper
    case cream

    /// The ground as SwiftUI draws it — the Write screen, its masthead and its edge
    /// strips (the editor's own ground is the face's `paper`, the same rule in
    /// UIKit: `MobileEditorStyle.Face.paper`).
    @MainActor
    func color(tokens: VoiceTokens, dark: Bool) -> Color {
        switch self {
        case .paper: tokens.surface
        case .cream: ReadingPageTokens.room(voice: tokens.voice, dark: dark)
        }
    }
}

// MARK: - Her words' size

/// **VM-254 — her words' size on this phone** (her pick R-260-2, "Setting +
/// smaller default"): five steps around the default, scaling her words only —
/// the note's body, the titles, a row's title and its preview (`PhoneTypeRole
/// .followsTextSize`) — on top of the system's text size; the chrome, the twelve
/// words and the 13 pt floor never move with it. The steps are the note's body
/// in Study at the system's default size, 14 · 15 · 16 · 17 · 18: the default is
/// the type table itself (one notch under wave 1's set), "Large" is wave 1's set
/// back (17), each step one point on the body; every other role takes the same
/// share, rounded to a whole point (`PhoneType.spec` — the batch-3 reconcile),
/// and Terminal's prose is Study's step two under (ladder round 1, R1-9).
/// PROVISIONAL as a set (P-260-3a).
nonisolated enum MobileTextSize: String, CaseIterable, Sendable {
    case smaller
    case small
    case standard = "default"
    case large
    case larger

    /// The factor her words' roles take at this step (the default: 1).
    var wordsScale: CGFloat {
        switch self {
        case .smaller: 14.0 / 16
        case .small: 15.0 / 16
        case .standard: 1
        case .large: 17.0 / 16
        case .larger: 18.0 / 16
        }
    }
}

// MARK: - The choice

/// **What Settings ▸ Look holds on this phone** (the appearance — light, dark,
/// follow the system — keeps its own owner, `MobileAppearanceController`, VM-53).
nonisolated struct MobileLookChoice: Equatable, Sendable {
    var voice: ThemeVoice
    var palette: ThemePalette
    var ground: MobileNoteGround
    /// VM-254 — her words' size.
    var textSize: MobileTextSize

    /// **Her R-260-3** — a phone that has chosen nothing: Study under the
    /// sea-glass (the unset library's own read — the same constants, so the two
    /// can never drift), on the paper, her words at the default size (R-260-2's
    /// smaller default is the type table itself).
    static let fresh = MobileLookChoice(
        voice: Queries.ThemeSettings.unsetStoreVoice,
        palette: Queries.ThemeSettings.unsetStorePalette,
        ground: .paper,
        textSize: .standard)

    /// **The palettes the phone offers**: every preset the Mac's swatch strip
    /// offers but her own hex — `custom` needs the seed fields the phone does not
    /// have (a custom with no seed would read as Classic; recorded).
    static let palettes: [ThemePalette] = ThemePalette.allCases.filter { $0 != .custom }

    /// This device's defaults keys — one per choice, beside `appearanceChoice`
    /// (VM-53). Deliberately NOT the retired VM-51 key: an old phone-local voice
    /// is never read (R-260-3: no seed).
    enum Key {
        static let voice = "phoneLookVoice"
        static let palette = "phoneLookPalette"
        static let ground = "phoneLookBackground"
        static let textSize = "phoneLookTextSize"
    }

    /// The remembered choice — `AppearanceChoice.remembered`'s posture: a value
    /// that is not one of the choices (absent, unknown, or a palette the phone
    /// does not offer) reads as the fresh default for THAT choice. Nil defaults
    /// (a test host) remember nothing.
    static func remembered(_ defaults: UserDefaults?) -> MobileLookChoice {
        guard let defaults else { return fresh }
        var choice = fresh
        if let voice = defaults.string(forKey: Key.voice).flatMap(ThemeVoice.init(rawValue:)) {
            choice.voice = voice
        }
        if let palette = defaults.string(forKey: Key.palette).flatMap(ThemePalette.init(rawValue:)),
           palettes.contains(palette) {
            choice.palette = palette
        }
        if let ground = defaults.string(forKey: Key.ground).flatMap(MobileNoteGround.init(rawValue:)) {
            choice.ground = ground
        }
        if let size = defaults.string(forKey: Key.textSize).flatMap(MobileTextSize.init(rawValue:)) {
            choice.textSize = size
        }
        return choice
    }

    /// Kept in this device's defaults — never the `setting` table.
    func remember(in defaults: UserDefaults?) {
        guard let defaults else { return }
        defaults.set(voice.rawValue, forKey: Key.voice)
        defaults.set(palette.rawValue, forKey: Key.palette)
        defaults.set(ground.rawValue, forKey: Key.ground)
        defaults.set(textSize.rawValue, forKey: Key.textSize)
    }

    /// **THE OVERLAY** — the library's landed settings with this phone's look in
    /// place of the library's: the voice and the palette replaced, the custom
    /// seeds cleared (the phone offers no custom palette, and a seed changed on
    /// the Mac must never read as a look that moved here); every other setting —
    /// none of which the phone reads today — stays the library's.
    func over(_ library: Queries.ThemeSettings) -> Queries.ThemeSettings {
        var settings = library
        settings.voice = voice
        settings.palette = palette
        settings.customRoom = nil
        settings.customAccent = nil
        return settings
    }
}

// MARK: - The owner

/// **The ONE owner of this phone's look** — `MobileAppearanceController`'s twin: it
/// holds the choice, remembers it in THIS device's defaults (never the `setting`
/// table — nothing here can reach a store), and tells the shell router when it
/// moved, so the editor face and every open editor restyle at once
/// (`MobileShellRouter.lookMoved`).
///
/// **Inert in a test runner's host** (VX-604's posture — `AppBootstrap.Launch`):
/// there it remembers NOTHING (no defaults at all — the suites share the dev-store
/// app's `.standard`, and a choice one suite made must never reach the next); a
/// pin that wants the remembering hands its own scratch domain.
@MainActor
@Observable
final class MobileLookController {
    /// The look in force on this phone.
    private(set) var choice: MobileLookChoice
    /// This device's defaults; nil remembers nothing (the inert host).
    @ObservationIgnored private let defaults: UserDefaults?
    /// Called after every change — the router's restyle (set once by its owner).
    @ObservationIgnored var onChange: (@MainActor () -> Void)?

    /// The app's owner: this phone's own defaults — memory only under a test
    /// runner's host (see the type's doc).
    convenience init(launch: AppBootstrap.Launch = .thisProcess) {
        self.init(defaults: launch == .hostingTests ? nil : .standard)
    }

    init(defaults: UserDefaults?) {
        self.defaults = defaults
        choice = MobileLookChoice.remembered(defaults)
    }

    func setVoice(_ voice: ThemeVoice) { update { $0.voice = voice } }

    /// A palette the phone does not offer (`custom`) changes nothing.
    func setPalette(_ palette: ThemePalette) {
        guard MobileLookChoice.palettes.contains(palette) else { return }
        update { $0.palette = palette }
    }

    func setGround(_ ground: MobileNoteGround) { update { $0.ground = ground } }

    func setTextSize(_ size: MobileTextSize) { update { $0.textSize = size } }

    /// One write: the choice, remembered, then the router told — only when
    /// something moved.
    private func update(_ change: (inout MobileLookChoice) -> Void) {
        var next = choice
        change(&next)
        guard next != choice else { return }
        choice = next
        next.remember(in: defaults)
        onChange?()
    }
}
