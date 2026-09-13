//
//  ResolvedInk.swift
//  VariorumTests
//
//  18j — comparing a (possibly DYNAMIC) `NSColor` the way the text system
//  will: resolved against a drawing appearance. One helper for every pin
//  that reads an ink off a storage, because the prose ink is ONE dynamic
//  object per voice since 18j (`EditorTypography.ink(for:)`) and a static
//  `==` against `NSColor(tokens.ink)` compares kinds, not colours (the
//  ladder's R1-1 conversion of the R2-1 pin).
//

import AppKit
import SwiftUI

enum ResolvedInk {
    /// The colour as it draws under `.aqua` / `.darkAqua`.
    static func resolved(_ colour: NSColor, dark: Bool) -> NSColor {
        let appearance = NSAppearance(named: dark ? .darkAqua : .aqua)!
        var answer = colour
        appearance.performAsCurrentDrawingAppearance {
            answer = colour.usingColorSpace(.sRGB) ?? colour
        }
        return answer
    }

    /// Component-wise match of a resolved colour against a token.
    static func matches(_ colour: NSColor?, _ expected: Color) -> Bool {
        guard let colour = colour?.usingColorSpace(.sRGB),
              let want = NSColor(expected).usingColorSpace(.sRGB) else { return false }
        return abs(colour.redComponent - want.redComponent) < 0.002
            && abs(colour.greenComponent - want.greenComponent) < 0.002
            && abs(colour.blueComponent - want.blueComponent) < 0.002
    }

    /// `colour` drawn under the appearance reads as `expected`.
    static func reads(_ colour: NSColor?, as expected: Color, dark: Bool) -> Bool {
        guard let colour else { return false }
        return matches(resolved(colour, dark: dark), expected)
    }
}
