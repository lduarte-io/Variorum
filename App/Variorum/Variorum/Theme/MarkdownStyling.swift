//
//  MarkdownStyling.swift
//  Variorum
//
//  Phase 13g, batch 2 (L7) — the EDITING FACE for markdown-as-content, per
//  the author's rulings F-1/F-2/F-5; **since the mobile project's Stage 1
//  batch 2 (the parity move), the ALGORITHM lives in
//  `Shared/MarkdownFace/MarkdownFaceCore.swift`** — one face both app
//  targets compile — and this file keeps everything Mac-flavored: the
//  voice-token palette, its storage, and every pre-move name as a forward
//  (`style`/`restyle`/`faceAttribute`/`adding`/`headingFont` — byte-identical
//  behavior, existing pins pass unmodified).
//
//  The invariants ride the shared core and are documented there: DISPLAY ==
//  STORED byte for byte (attributes only, never a character); storage
//  attributes, never TK2 rendering attributes (TEXTKIT2_NOTES §3); the
//  rescan ∝ the edited paragraph(s) (P1, pinned by `MarkdownScanCount`);
//  the zero-write fast path for markdown-free text.
//

import AppKit
import Foundation
import SwiftUI
import VariorumCore

nonisolated enum MarkdownStyling {
    /// The two colors the face needs beyond the prose ink, resolved from the
    /// voice tokens (P-8 — feature code never holds a literal color).
    struct Palette: Equatable {
        /// Syntax characters and a link's `(url)` — "faint markers" (F-2).
        let marker: NSColor
        /// A link's TEXT (F-5: "text link-colored, the `(url)` dimmed").
        let link: NSColor
        /// **13k K10 — the inline-code CHIP** (her ruling: a faint per-voice
        /// tint hugging exactly the span, never block-wide).
        let codeTint: NSColor

        init(marker: NSColor, link: NSColor, codeTint: NSColor) {
            self.marker = marker
            self.link = link
            self.codeTint = codeTint
        }

        @MainActor
        init(tokens: VoiceTokens) {
            self.init(
                marker: NSColor(tokens.muted), link: NSColor(tokens.accent),
                codeTint: NSColor(tokens.codeTint))
        }

        /// Before any voice has been applied (a bare test host, a surface
        /// materialized in the first frame). The system's own secondary and
        /// link colors — deliberately NOT a copied token literal, which would
        /// be the duplicate-palette class P-8 forbids; the real values arrive
        /// with the first chrome application, which is the same posture
        /// `VoiceTokens.fallback(for:)` already takes.
        static var systemFallback: Palette {
            Palette(
                marker: .secondaryLabelColor, link: .linkColor,
                // A real system faint fill, for the same reason the other two
                // are system colours here: a copied token literal would be
                // the duplicate-palette class P-8 forbids.
                codeTint: .unemphasizedSelectedTextBackgroundColor)
        }

        /// This Mac palette in the shared core's shape.
        var face: MarkdownFace.Palette {
            MarkdownFace.Palette(marker: marker, link: link, codeTint: codeTint)
        }
    }

    /// The live palette every surface write reads.
    ///
    /// Same shape, same reasoning, and the same concurrency note as
    /// `EditorTypography.current`: written ONLY on the main thread (the
    /// editor's chrome application + the root's theme adoption) and read by
    /// main-thread surface writes. One global means no surface can disagree
    /// about what a dimmed marker looks like; the alternative — threading a
    /// palette through `EditorDocument.materialize`, both surface kinds and
    /// every pane composer — is the divergent-private-copy class this app has
    /// already paid for twice.
    nonisolated(unsafe) private static var storedPalette: Palette?

    static var palette: Palette {
        get { storedPalette ?? .systemFallback }
        set { storedPalette = newValue }
    }

    /// The face-bookkeeping attribute key — ONE key across both platforms
    /// (the shared core owns it; this forward keeps the pre-move name).
    static let faceAttribute = MarkdownFace.faceAttribute

    // MARK: - Doors (forwards to the shared core, with this Mac's values)

    /// Styles a freshly materialized surface string (the full-render door).
    @discardableResult
    static func style(_ attributed: NSMutableAttributedString) -> Bool {
        MarkdownFace.style(attributed, base: EditorDocument.baseFont, palette: palette.face)
    }

    /// Re-styles the LINES that `range` touches. Returns whether anything was
    /// written (false = the zero-write fast path).
    @discardableResult
    static func restyle(_ storage: NSMutableAttributedString, range: NSRange) -> Bool {
        MarkdownFace.restyle(
            storage, range: range, base: EditorDocument.baseFont, palette: palette.face)
    }

    // MARK: - Fonts (forwards)

    /// The bold/italic face of `font`, or `font` itself when the family ships
    /// no such variant — the honest fallback (both voices' fonts do ship
    /// both, R49; a future voice that doesn't simply loses the trait rather
    /// than the text).
    static func adding(_ traits: NSFontDescriptor.SymbolicTraits, to font: NSFont) -> NSFont {
        MarkdownFace.adding(traits, to: font)
    }

    /// Headings are SIZES (F-3: "headings-as-sizes"; arbitrary per-span sizes
    /// are not markdown-expressible and are deliberately absent). Bold, and
    /// scaled off the voice's own base size so both voices stay in proportion.
    static func headingFont(level: Int) -> NSFont {
        MarkdownFace.headingFont(level: level, base: EditorDocument.baseFont)
    }
}
