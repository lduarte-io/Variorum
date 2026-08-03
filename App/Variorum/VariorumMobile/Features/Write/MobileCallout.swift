//
//  MobileCallout.swift
//  VariorumMobile
//
//  Mobile Stage 4, batch 1 (M12) — the callout vocabulary on the phone: a
//  deliberate MIRROR of the Mac's `CalloutPalette` + `CalloutEditRule`
//  (Features/Editor/BlockDecor.swift) — the `MobileShelfFaces` precedent:
//  mirror the SEMANTICS (the ONE callout transform, the five token names,
//  the exact light/dark washes), never port the AppKit chrome. Drift risk
//  recorded for the ladder; the pins hold the mirror to the stored-JSON
//  outcomes (`BlockPresentation` is core — shared law either way).
//
//  Colors are THEME-TOKEN NAMES in the store (R1 — never a literal); the
//  UIColor resolution here is dynamic (light/dark per trait — R51's rooms
//  stay readable), value-mirroring the Mac palette's hexes.
//

import UIKit
import VariorumCore

nonisolated enum MobileCallout {
    /// The Mac `CalloutPalette.names`, mirrored (one vocabulary).
    static let names = ["blue", "green", "sand", "violet", "rose"]
    static let defaultName = "blue"

    /// One edit to a block's stored frame — the Mac `CalloutEdit`'s cases
    /// (`.toggle` / `.color(name-or-nil-removes)` / `.emoji`).
    enum Edit: Equatable {
        case toggle
        case color(String?)
        case emoji(String?)
    }

    /// THE one callout transform — `CalloutEditRule.apply`, mirrored
    /// byte-for-byte: color keeps the emoji, nil color removes the frame;
    /// emoji keeps (or defaults) the color, empty trims to none; toggle is
    /// have/have-not. Every caller passes this straight to
    /// `Operations.updateBlockPresentation`, whose transform runs INSIDE
    /// the write transaction — partial edits read the STORED frame, never
    /// a projection cache (the Mac's own discipline).
    static func apply(_ edit: Edit, to existing: BlockPresentation?) -> BlockPresentation? {
        switch edit {
        case .color(let name):
            return name.map { BlockPresentation(color: $0, emoji: existing?.emoji) }
        case .emoji(let raw):
            let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines)
            return BlockPresentation(
                color: existing?.color ?? defaultName,
                emoji: (trimmed?.isEmpty == false) ? trimmed : nil)
        case .toggle:
            return existing == nil
                ? BlockPresentation(color: defaultName, emoji: nil)
                : nil
        }
    }

    /// The wash for a named color — the Mac palette's exact hexes, dynamic
    /// per trait (unknown names fail-open to blue, the Mac's rule).
    static func color(_ name: String?) -> UIColor {
        UIColor { traits in
            let dark = traits.userInterfaceStyle == .dark
            let hex: UInt32
            switch (name ?? defaultName, dark) {
            case ("green", false): hex = 0xEAF3E7
            case ("green", true): hex = 0x17251A
            case ("sand", false): hex = 0xF7F1DE
            case ("sand", true): hex = 0x262012
            case ("violet", false): hex = 0xEFEAF6
            case ("violet", true): hex = 0x1F1A2A
            case ("rose", false): hex = 0xF8ECEC
            case ("rose", true): hex = 0x2A1A1C
            case (_, false): hex = 0xE8F1F8
            case (_, true): hex = 0x14202B
            }
            return UIColor(
                red: CGFloat((hex >> 16) & 0xFF) / 255,
                green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255, alpha: 1)
        }
    }
}
