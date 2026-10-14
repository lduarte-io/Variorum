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
        /// **18j (the 18g ladder's R2-1):** the surface's CURRENT prose ink,
        /// so clearing a face restores the ink that is there NOW rather than
        /// the one captured when the face was written — see
        /// `MarkdownFace.Palette.prose`. **Required, never defaulted** (the
        /// shared core says why): the two builders below are the only
        /// constructions in the app, and a third that forgot would put a
        /// stale ink back under every face it cleared.
        let prose: NSColor

        init(marker: NSColor, link: NSColor, codeTint: NSColor, prose: NSColor) {
            self.marker = marker
            self.link = link
            self.codeTint = codeTint
            self.prose = prose
        }

        /// **The prose is the voice's ONE DYNAMIC ink** (18j ladder round 1,
        /// R1-1) — the same object `EditorDocument.baseAttributes` carries —
        /// never `NSColor(tokens.ink)`, which is one appearance's answer
        /// frozen. The clear loop writes `prose` over every run it clears; a
        /// run that STAYS faced is re-cleared on every appearance change and
        /// so hid the mismatch, but a run whose face is REMOVED (a marker
        /// deleted, ⌘B/⌘I toggled off) is cleared once and never revisited,
        /// and with a frozen prose it read in the OLD ink after the next
        /// light/dark change — reproduced on the Debug build at the ladder.
        /// The voice rides the tokens (`VoiceTokens.voice`) so all three
        /// writers of the global palette supply the same ink by construction.
        @MainActor
        init(tokens: VoiceTokens) {
            self.init(
                marker: NSColor(tokens.muted), link: NSColor(tokens.accent),
                codeTint: NSColor(tokens.codeTint),
                prose: EditorTypography.ink(for: tokens.voice))
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
                codeTint: .unemphasizedSelectedTextBackgroundColor,
                prose: .textColor)
        }

        /// This Mac palette in the shared core's shape.
        var face: MarkdownFace.Palette {
            MarkdownFace.Palette(
                marker: marker, link: link, codeTint: codeTint, prose: prose)
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
    ///
    /// **ITS WRITERS — EXACTLY THREE — AND THE INVARIANT THAT MAKES ONE
    /// GLOBAL SAFE** (18k UNIT C4, the post-13u health review §5.2's one
    /// non-DEBUG guard):
    ///   1. `RootView.adoptMarkdownPalette()` — `Palette(tokens:
    ///      theme.tokens(for: scheme))`, on a window's theme or scheme change;
    ///   2. `NSTextView.applyVoiceChrome(_:previous:)` (`EditorTypography.swift`)
    ///      — the full-document editor's chrome application —
    ///      `Palette(tokens: chrome.tokens)`;
    ///   3. `PaneSurface.applyFace` — a pane's `updateNSView` writing the
    ///      face its host pushed, built at the one construction site as
    ///      `tokens.map { MarkdownStyling.Palette(tokens: $0) }`.
    /// All three resolve from the ONE settings → tokens road, so at any
    /// moment they write the same value — **because appearance is app-wide**:
    /// the voice and the palette are synced settings, and the light/dark
    /// choice is applied once as `NSApp.appearance` (`AppearanceChoice`),
    /// never per window or per view. That is what makes "the last writer
    /// wins" harmless here. **The day anything about the face becomes
    /// per-window, the three become a race** — a pane's `updateNSView` in
    /// one window restyling in another window's colours — and this global
    /// must become per-surface state instead. `MarkdownPaletteWritersTests`
    /// fails if a fourth writer appears, if a writer stops resolving from
    /// the tokens, or if the app-wide appearance precondition breaks.
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
    /// written (false = the zero-write fast path). `caret` — the live
    /// editor's selection, nil everywhere but the caret settle (VX-296; the
    /// shared core says what it changes).
    @discardableResult
    static func restyle(
        _ storage: NSMutableAttributedString, range: NSRange, caret: NSRange? = nil
    ) -> Bool {
        MarkdownFace.restyle(
            storage, range: range, base: EditorDocument.baseFont, palette: palette.face,
            caret: caret)
    }

    /// **VX-296 — a live Mac surface's caret has settled** (the Write editor
    /// and the book's inline editor through `EditorViewModel`, every live
    /// pane through `PaneSurfaceView.Coordinator`). The shared core's
    /// `settleCaret`, with this Mac's values.
    @discardableResult
    static func settleCaret(
        _ ledger: inout MarkdownCaretRescue.Ledger, selection: NSRange?,
        in storage: NSMutableAttributedString
    ) -> Bool {
        MarkdownFace.settleCaret(
            &ledger, selection: selection, in: storage,
            base: EditorDocument.baseFont, palette: palette.face)
    }

    /// **Re-derives the face on every line that already wears one — one
    /// line-scoped edit per line** (18g ladder, the R1-1 walk). The colour-
    /// only road of `applyVoiceChrome` (a palette, a seed, the appearance):
    /// the link and marker colours live in the storage and must follow the
    /// palette, but the whole-document `style(_:)` coalesces every face into
    /// ONE edited range — the union, which on a long note with faces near
    /// both ends is the document, and TextKit 2 invalidates everything
    /// between. Here each faced line is its own `restyle`, so the storage
    /// reports one edit per line, ∝ the faced lines, and a note without a
    /// face writes nothing. Returns the number of lines re-styled.
    @discardableResult
    static func restyleFacedLines(_ storage: NSMutableAttributedString) -> Int {
        let length = storage.length
        guard length > 0 else { return 0 }
        let string = storage.string as NSString
        var lines: [NSRange] = []
        storage.enumerateAttribute(
            faceAttribute, in: NSRange(location: 0, length: length), options: []
        ) { value, range, _ in
            guard value != nil else { return }
            let line = string.lineRange(for: range)
            if lines.last != line { lines.append(line) }
        }
        for line in lines { restyle(storage, range: line) }
        return lines.count
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
