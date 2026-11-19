//
//  PhoneInks.swift
//  Variorum (Shared — the phone layer's two corrected inks)
//
//  VM-48 (the VM-47 run, batch 1), the sizing sheet's §D. Ink and accent
//  read fine on the phone; `muted` and `faint` do not — in light they sit
//  near 3:1 and 2:1 on the room, mostly on small text. They are the VOICE's
//  own slots and the Mac reads them too, so the Mac's values are untouched
//  (`VoiceTokens.swift` is not edited) and the phone gets two inks of its
//  own: **the voice's own hue, taken darker until `muted` clears 4.5:1 and
//  `faint` 3:1 on every ground the app ships** — the sixteen palettes and
//  the Classic rooms, in both voices. In dark the room is black and only
//  `faint` needs lifting; the same rule finds that by itself.
//
//  The rule is the palette layer's accent correction applied to the two
//  small inks: the same HSL hue and saturation, the lightness stepped away
//  from the grounds by 0.005 until the floor clears, bounded, deterministic.
//  It reproduces the sheet's Study light inks exactly (#6A6359, #8B7F6A —
//  `PhoneInkTests` pins both). The sheet's dark faint (#736C5D) was
//  measured against the sea-glass family only and falls to 2.91:1 on teal &
//  rust's dark card; the every-palette floor lands one step lighter
//  (#766F5F) — recorded in the run's §5.
//
//  Values are 24-bit sRGB, so the whole rule is arithmetic a unit pin can
//  measure; the colours are built from them in one place below.
//

import SwiftUI
import VariorumCore
#if os(iOS)
import UIKit
#endif

enum PhoneInks {
    enum Ink: CaseIterable, Sendable {
        /// Meta lines, paths, explainers, previews — words she reads.
        case muted
        /// Glyphs, placeholders, disabled words — never a sentence.
        case faint

        /// WCAG 2: 4.5:1 for words under 17 pt; 3:1 for glyphs, placeholders
        /// and 17 pt semibold words (the sheet's rule).
        var floor: Double {
            switch self {
            case .muted: 4.5
            case .faint: 3.0
            }
        }
    }

    /// One voice's own values in one appearance — the source hue of each ink
    /// and the voice's Classic grounds. **A copy of `VoiceTokens`' values,
    /// held as numbers so the rule is arithmetic;** `PhoneInkTests` resolves
    /// the token layer's colours and fails if a copy drifts.
    struct Source: Equatable, Sendable {
        let muted: UInt32
        let faint: UInt32
        let room: UInt32
        let surface: UInt32
        let card: UInt32
    }

    static func source(_ voice: ThemeVoice, dark: Bool) -> Source {
        switch (voice, dark) {
        case (.terminal, false):
            Source(muted: 0x8B9088, faint: 0xB3B6AE, room: 0xF6F6F1, surface: 0xFBFBF7, card: 0xFDFDFA)
        case (.terminal, true):
            Source(muted: 0x8B9088, faint: 0x5B6058, room: 0x000000, surface: 0x0C0D0C, card: 0x161816)
        case (.study, false):
            Source(muted: 0x8D8578, faint: 0xB5AD9E, room: 0xFAF8F3, surface: 0xFFFFFF, card: 0xFFFFFF)
        case (.study, true):
            Source(muted: 0x948C7C, faint: 0x6B6456, room: 0x000000, surface: 0x14120F, card: 0x1C1915)
        }
    }

    /// **Every ground the app ships, for one voice in one appearance:** the
    /// Classic rooms of both voices (the sheet's "the two Classic rooms"),
    /// the voice's own paper and card, and every shipped palette's room,
    /// paper and card (a palette replaces paper and card in dark only — in
    /// light the voice keeps its own, as `VoiceTokens.applying` does).
    static func grounds(_ voice: ThemeVoice, dark: Bool) -> [UInt32] {
        let own = source(voice, dark: dark)
        var grounds = ThemeVoice.allCases.map { source($0, dark: dark).room }
        grounds += [own.surface, own.card]
        for preset in PalettePreset.all.values {
            let family = PaletteDerivation.derive(preset, dark: dark)
            grounds += [family.room, family.surface ?? own.surface, family.card ?? own.card]
        }
        return grounds
    }

    /// **The rule.** Start at the voice's own ink; while it misses the floor
    /// on any ground, step its HSL lightness away from the grounds (darker in
    /// light, lighter in dark), hue and saturation held. An ink that already
    /// clears is returned unchanged — which is why dark `muted` stays the
    /// voice's.
    static func derive(_ ink: Ink, voice: ThemeVoice, dark: Bool) -> UInt32 {
        let own = source(voice, dark: dark)
        let start = ink == .muted ? own.muted : own.faint
        let grounds = grounds(voice, dark: dark)
        func worst(_ candidate: UInt32) -> Double {
            grounds.map { PaletteDerivation.contrast(candidate, $0) }.min() ?? 0
        }
        var candidate = start
        guard worst(candidate) < ink.floor else { return candidate }
        let hsl = HSL(start)
        var lightness = hsl.lightness
        let step = dark ? 0.005 : -0.005
        for _ in 0..<200 {
            lightness += step
            if lightness <= 0 || lightness >= 1 { break }
            candidate = hsl.at(lightness: lightness, saturationCap: 1)
            if worst(candidate) >= ink.floor { return candidate }
        }
        return candidate
    }

    /// The eight values, computed once.
    private static let table: [String: UInt32] = {
        var table: [String: UInt32] = [:]
        for voice in ThemeVoice.allCases {
            for dark in [false, true] {
                for ink in Ink.allCases {
                    table[key(ink, voice, dark)] = derive(ink, voice: voice, dark: dark)
                }
            }
        }
        return table
    }()

    private static func key(_ ink: Ink, _ voice: ThemeVoice, _ dark: Bool) -> String {
        "\(ink)·\(voice.rawValue)·\(dark)"
    }

    /// The phone's ink for a voice in one appearance.
    static func value(_ ink: Ink, voice: ThemeVoice, dark: Bool) -> UInt32 {
        table[key(ink, voice, dark)] ?? derive(ink, voice: voice, dark: dark)
    }
}

#if os(iOS)
extension PhoneInks {
    /// The ink as a DYNAMIC colour: light and dark resolve per the trait, as
    /// every colour of the phone's UIKit face does. Cached per voice, so a
    /// read hands back the same object every time.
    static func uiColor(_ ink: Ink, voice: ThemeVoice) -> UIColor {
        switch (ink, voice) {
        case (.muted, .terminal): terminalMuted
        case (.faint, .terminal): terminalFaint
        case (.muted, .study): studyMuted
        case (.faint, .study): studyFaint
        }
    }

    private static func dynamic(_ ink: Ink, _ voice: ThemeVoice) -> UIColor {
        let light = UIColor(Color(hex: value(ink, voice: voice, dark: false)))
        let dark = UIColor(Color(hex: value(ink, voice: voice, dark: true)))
        return UIColor { traits in traits.userInterfaceStyle == .dark ? dark : light }
    }

    private static let terminalMuted = dynamic(.muted, .terminal)
    private static let terminalFaint = dynamic(.faint, .terminal)
    private static let studyMuted = dynamic(.muted, .study)
    private static let studyFaint = dynamic(.faint, .study)
}

/// **The phone layer's colours, reached from the tokens a view already
/// holds** — `tokens.phone.muted` where the Mac reads `tokens.muted`. The
/// SwiftUI colours are the dynamic UIKit ones, so they resolve with the
/// environment's appearance exactly as the tokens the shell resolved do.
struct PhoneLayer {
    let muted: Color
    let faint: Color

    fileprivate init(voice: ThemeVoice) {
        muted = Color(uiColor: PhoneInks.uiColor(.muted, voice: voice))
        faint = Color(uiColor: PhoneInks.uiColor(.faint, voice: voice))
    }

    fileprivate static let terminal = PhoneLayer(voice: .terminal)
    fileprivate static let study = PhoneLayer(voice: .study)
}

extension VoiceTokens {
    /// The phone's layer over these tokens (VM-48): its two corrected inks.
    /// The type roles are read with `.phoneType(_:_:)`.
    var phone: PhoneLayer {
        voice == .terminal ? .terminal : .study
    }
}
#endif
