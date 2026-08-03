//
//  MobileVoicePreference.swift
//  VariorumMobile
//
//  Mobile Stage 1, batch 3 — **LK2, the phone-local voice switch** (her
//  round-1 ruling, verbatim: "keep both with its own switch"): the phone
//  keeps BOTH voices behind its OWN stored preference — deliberately NOT
//  the Mac's synced `setting` row ('theme_voice'), and never synced at
//  all. UserDefaults is the recorded precedent for exactly this class
//  (the Mac's ⌘⇧I context-bar fold — "a this-Mac preference, never
//  synced"; `ContextBarDoors.folded` is the house pattern this follows).
//
//  The DEFAULT is the terminal voice — the leading voice everywhere else
//  (R1's letter; `VoiceTokens.fallback` leads with it too). PROVISIONAL
//  like every look default: her feel round may re-rule it.
//
//  PROVISIONAL placement (recorded per the batch brief): the switch DOOR
//  currently rides the Write masthead; its real Settings home is S3's.
//

import Foundation
import VariorumCore

enum MobileVoicePreference {
    static let key = "io.lduarte.variorum.mobile.themeVoice"

    /// The stored phone voice; absent/unreadable reads as terminal.
    static func current(_ defaults: UserDefaults = .standard) -> ThemeVoice {
        defaults.string(forKey: key).flatMap(ThemeVoice.init(rawValue:)) ?? .terminal
    }

    static func set(_ voice: ThemeVoice, _ defaults: UserDefaults = .standard) {
        defaults.set(voice.rawValue, forKey: key)
    }
}
