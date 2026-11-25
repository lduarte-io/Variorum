//
//  MobileSettingsGear.swift
//  VariorumMobile
//
//  VM-53 (the VM-47 run, batch 5) — **Settings' door from every root and from
//  a note.** The ticket: "only the Shelf has a door to it (Library, Starred and
//  Write have none). It becomes … reachable from every root and from a note."
//
//  VM-255 (the VM-260 run, batch 1a) — **THE GEAR, NOT A ⋯.** Her words
//  (2026-11-22): "a kebab menu for settings makes less sense than just showing
//  a settings gear." VM-53 built a system `Menu` behind a ⋯ that held ONE item
//  (Settings, PROVISIONAL P-47-22); wave 2's other home-page doors drawn behind
//  a ⋯ are a mockup, not built. So the gear replaces the ⋯ outright (S-260-1,
//  PROVISIONAL): one press opens Settings, no menu between. The glyph is the
//  system's settings gear, the one the Mac draws for its settings doors
//  (`gearshape` — the book's settings door, Settings ▸ General's pane icon) —
//  S-260-2: the Mac's symbol choices, never its views.
//
//  THE DOOR is the shell's (it owns the Settings sheet), handed down through the
//  environment — the `ProtectionPaneDoor` precedent — so each root draws the gear
//  in ONE line and a note's ⋯ sheet reaches the same door without a closure
//  threaded through the Write screen. nil (no shell above: a harness) ⇒ no gear
//  (P-2: a door that cannot act is not rendered).
//
//  A plain Button on the phone's icon-button control (the 44 × 44 target, the
//  glyph drawn at the layer's icon size), so — unlike the system `Menu` it
//  replaces — the pins drive it in process.
//

import SwiftUI

/// The shell's road to the Settings sheet, handed to every screen under it.
struct MobileSettingsDoor {
    let open: @MainActor () -> Void
}

private struct MobileSettingsDoorKey: EnvironmentKey {
    static let defaultValue: MobileSettingsDoor? = nil
}

extension EnvironmentValues {
    /// VM-53: the shell's Settings door (nil outside a shell — then no door
    /// renders: the roots' gear and the note's Settings row stand down).
    var mobileSettingsDoor: MobileSettingsDoor? {
        get { self[MobileSettingsDoorKey.self] }
        set { self[MobileSettingsDoorKey.self] = newValue }
    }
}

/// **The gear on a root's top line** — the Mac's settings glyph in the accent
/// (the ⋯'s tone, whose place it takes), in a 44 × 44 hit area; one press opens
/// Settings.
struct MobileSettingsGear: View {
    let tokens: VoiceTokens
    @Environment(\.mobileSettingsDoor) private var settingsDoor

    /// The door's name — spoken, and the word the pins drive it by.
    static let spokenLabel = "Settings"
    /// The Mac's settings gear (S-260-2).
    static let symbol = "gearshape"

    var body: some View {
        if let settingsDoor {
            Button {
                settingsDoor.open()
            } label: {
                Image(systemName: Self.symbol)
            }
            .buttonStyle(PhoneIconButtonStyle(tokens: tokens, tone: .accent))
            .accessibilityLabel(Self.spokenLabel)
        }
    }
}
