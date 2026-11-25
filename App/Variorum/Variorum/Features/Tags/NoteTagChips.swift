//
//  NoteTagChips.swift
//  Variorum (Mac)
//
//  **The tag's colour** — what stays at this address since VX-1036 batch 2
//  moved the chip itself (and its rows and adder) to the shared home,
//  `Core/Views/TagChips.swift`, when a fourth feature (the book Outline's card
//  headers) began to render it. This type stays because the literal-colour
//  pin (`NoLiteralColourTests`) allows its one form, `Color(hue:`, in THIS
//  file by path — an identity hue derived from the tag's path, never a chosen
//  colour — and a move would be an edit to that pin.
//
//  ── THE COLOUR IS THE TAG'S, FOREVER ────────────────────────────────────
//  Derived from the tag's PATH through `BlockTint.stableHash` — the 9d
//  stable-colour family, chosen deliberately over an index into a palette:
//  the same tag is the same colour in every note, across launches and across
//  devices, and applying a new tag never re-ripples the colours of the ones
//  already there (the never-re-ripple rule the tint mode was built on).
//

import SwiftUI

/// The stable per-tag colour (the `LineageStripe` rule, keyed on path).
nonisolated enum TagChipColor {
    /// Hue in 0..<1 from the tag's path. Same path, same hue, always.
    static func hue(forPath path: String) -> Double {
        Double(BlockTint.stableHash(path) % 360) / 360.0
    }

    static func color(forPath path: String, dark: Bool) -> Color {
        Color(
            hue: hue(forPath: path),
            saturation: dark ? 0.45 : 0.55,
            brightness: dark ? 0.72 : 0.86)
    }
}
