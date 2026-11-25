//
//  MobileWalkLaunch.swift
//  VariorumMobile
//
//  DEBUG ONLY — the walk's palette seam (VM-51, the VM-47 run's batch 3). A walk
//  that must see the phone under a SECOND palette sets it at launch, and only when
//  the UI-test driver hands `VARIORUM_WALK_PALETTE` in the launch environment.
//  Since VM-247 (the VM-260 run, batch 3) the palette is THIS PHONE's own, so the
//  seam takes the road her press takes — the device's look owner
//  (`MobileLookController.setPalette`, remembered in the walk device's own
//  defaults) — and no longer writes the library's palette (which the phone no
//  longer wears). Compiled out of Release; no words, no key of its own.
//

#if DEBUG
import Foundation
import VariorumCore

enum MobileWalkLaunch {
    static let paletteKey = "VARIORUM_WALK_PALETTE"

    /// Chooses the named palette on this phone (an unknown or absent value, or a
    /// palette the phone does not offer, chooses nothing).
    @MainActor
    static func applyPalette(
        to look: MobileLookController,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) {
        guard let raw = environment[paletteKey], let palette = ThemePalette(rawValue: raw)
        else { return }
        look.setPalette(palette)
    }
}
#endif
