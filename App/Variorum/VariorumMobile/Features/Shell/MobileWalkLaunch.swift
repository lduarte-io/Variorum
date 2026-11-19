//
//  MobileWalkLaunch.swift
//  VariorumMobile
//
//  DEBUG ONLY — the VM-47 walk's palette seam (VM-51, the run's batch 3). The
//  phone has no palette door (a library's palette is chosen on the Mac,
//  Settings ▸ Appearance) and a walk's simulator library syncs with nothing, so
//  a walk that must see the phone under a SECOND palette sets it the one way a
//  library's palette is ever set — the operation — at launch, and only when the
//  UI-test driver hands `VARIORUM_WALK_PALETTE` in the launch environment.
//  Compiled out of Release; no words, no setting key of its own.
//

#if DEBUG
import Foundation
import VariorumCore

enum MobileWalkLaunch {
    static let paletteKey = "VARIORUM_WALK_PALETTE"

    /// Writes the named palette into the open library (an unknown or absent
    /// value writes nothing).
    static func applyPalette(
        _ session: AppSession,
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) async {
        guard let raw = environment[paletteKey], let palette = ThemePalette(rawValue: raw)
        else { return }
        _ = try? await session.runner.run { ops in try ops.setThemePalette(palette) }
    }
}
#endif
