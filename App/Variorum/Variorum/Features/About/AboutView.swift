//
//  AboutView.swift
//  Variorum
//
//  13s-b U1a, piece 4 — THE ABOUT WINDOW wears the logo (her rulings
//  R-13s-24/25: the faithful two-tone striped V; Q19 closed — "the app icon
//  + About + the welcome-line mark, nothing more").
//
//  The system's standard About panel cannot carry the wordmark: it sets the
//  app's name in the system's bold face, and TASTE.md's recorded lean is
//  "variorum" in a bookish serif, lowercase, SET IN REAL TYPE (never generated
//  lettering). So the app menu's About item opens this small window instead:
//  the mark, the word, the version. Calm — nothing else.
//

import AppKit
import SwiftUI

/// The About window's words and names, in one place so a pin reads them.
nonisolated enum AboutCopy {
    /// The app menu's item and the window's title — the platform's own words.
    static let menuTitle = "About Variorum"
    /// The window's scene id (`VariorumApp`'s `Window`).
    static let windowID = "variorum-about"
    /// The wordmark: lowercase, as TASTE.md's lean records it.
    static let wordmark = "variorum"
    /// Iowan Old Style — the bookish serif macOS ships (R49: nothing bundled,
    /// nothing licensed), the same face the Study voice reads in.
    static let wordmarkFontName = "Iowan Old Style"
    /// The mark's image asset (`notes/brand/tools/appicon.py` writes it).
    static let markAssetName = "VariorumMark"

    /// "Version 0.9.2 (1)" — the marketing version and the build.
    static func version(short: String, build: String) -> String {
        build.isEmpty ? "Version \(short)" : "Version \(short) (\(build))"
    }

    /// The running app's own version line.
    static var thisAppsVersion: String {
        let info = Bundle.main.infoDictionary ?? [:]
        return version(
            short: info["CFBundleShortVersionString"] as? String ?? "",
            build: info["CFBundleVersion"] as? String ?? "")
    }
}

/// The window's face: the mark, the wordmark, the version.
struct AboutView: View {
    /// The mark's size in the window (points).
    static let markSize: CGFloat = 112

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(spacing: 14) {
            Image(AboutCopy.markAssetName)
                .resizable()
                .interpolation(.high)
                .frame(width: Self.markSize, height: Self.markSize)
                // The word right under it says the name; the mark is art.
                .accessibilityHidden(true)
            Text(AboutCopy.wordmark)
                .font(.custom(AboutCopy.wordmarkFontName, size: 34))
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
            Text(AboutCopy.thisAppsVersion)
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
                .textSelection(.enabled)
        }
        .padding(.horizontal, 64)
        .padding(.top, 36)
        .padding(.bottom, 32)
        .fixedSize()
        .background(tokens.surface)
    }
}
