//
//  MarkdownStyling.swift
//  Variorum
//
//  Phase 13g, batch 2 (L7) — the EDITING FACE for markdown-as-content, per
//  the author's rulings F-1/F-2/F-5.
//
//  **The one invariant, above everything else here: DISPLAY == STORED, BYTE
//  FOR BYTE.** This file only ever writes ATTRIBUTES. It never inserts,
//  removes, or replaces a character, on any surface, ever. That is what keeps
//  the app's riskiest machinery (AppSpec §15 risk 1 — live block identity
//  over `NSTextStorage`) untouched by formatting: `BlockRangeIndex`,
//  crystallization, the differential structural rewrite, autosave, find, and
//  every gesture keep reading exactly the offsets they always read. Full
//  marker HIDING (display ≠ stored) is her recorded LATER RATCHET precisely
//  because it would need an offset-translation layer through that machinery;
//  it is deliberately not v1.
//
//  **Mechanism: real text-storage attributes, never TK2 rendering
//  attributes** (`TEXTKIT2_NOTES` §3 — per-range rendering attributes "draw
//  unreliably … often don't appear, or appear once then stop updating when
//  the range changes", with a reported crash in their draw path). Fonts and
//  colors on the storage are the same class of write the voice switch and the
//  block-ID bookkeeping already make. `NSTextList` is never invoked (§1/§3:
//  broken since macOS 14, and the Tahoe `includesTextListMarkers` delta makes
//  it worse) — a list is TEXT LINES, which is exactly what F-1 buys.
//
//  **P1: the rescan is ∝ the edited paragraph(s), never the document.**
//  `restyle(_:range:)` expands its range to whole LINES and tokenizes only
//  those; `MarkdownScanCount` (DEBUG, on the scanner itself) pins it.
//
//  **The zero-write fast path.** Text with no markdown and no previously
//  applied face writes NOTHING — not one attribute call, and the storage is
//  never opened for editing. So prose that carries no syntax behaves
//  byte-identically to how it did before this batch: that is the honest
//  default, and it is what keeps the A47c full-range invalidation class (a
//  storage attribute WRITE destroying a scrolled pane's rendering surfaces)
//  away from ordinary typing, since ordinary typing performs no write at all.
//  Measured while pinning it, and recorded so the guard is not credited with
//  more than it does: an empty `beginEditing`/`endEditing` pair posts no
//  `processEditing` either, so what the guard actually saves is the scan and
//  the enumeration — about 16 µs on a 15k-character note — not a layout pass.
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

    /// Marks a range this file has styled, and REMEMBERS the prose foreground
    /// color that was there — so clearing the face restores exactly what the
    /// surface had, whatever ink that surface carries. (Reading the color back
    /// beats guessing it: panes take their ink per-view from tokens, the
    /// full-document editor takes it from its chrome, and the read tier may
    /// carry none at all. A value of `NSNull` means "there was no
    /// foreground attribute" — the state `materialize` produces.)
    static let faceAttribute = NSAttributedString.Key("io.lduarte.variorum.markdownFace")

    // MARK: - Doors

    /// Styles a freshly materialized surface string (the full-render door).
    /// Whole-string by definition — the string has no layout yet, so this is
    /// the cheapest moment there is.
    @discardableResult
    static func style(_ attributed: NSMutableAttributedString) -> Bool {
        restyle(attributed, range: NSRange(location: 0, length: attributed.length))
    }

    /// Re-styles the LINES that `range` touches. Returns whether anything was
    /// written (false = the zero-write fast path).
    ///
    /// The range is widened by one unit before the line lookup so that an edit
    /// ending exactly at a line's end — pressing Return in the middle of
    /// `**bold**`, or deleting the newline that joined two lines — restyles
    /// the FOLLOWING line too. Two lines is still ∝ the edit.
    @discardableResult
    static func restyle(_ storage: NSMutableAttributedString, range: NSRange) -> Bool {
        let length = storage.length
        guard length > 0 else { return false }
        let string = storage.string as NSString

        let start = min(max(range.location, 0), length)
        let probeLength = min(max(range.length, 0) + 1, length - start)
        let lines = string.lineRange(for: NSRange(location: start, length: probeLength))
        guard lines.length > 0 else { return false }

        let spans = MarkdownSyntax
            .spans(in: string.substring(with: lines))
            .map { $0.shifted(by: lines.location) }

        // The face already applied over these lines (if any) — collected
        // BEFORE mutating, because enumerating an attribute while removing it
        // is not a contract NSAttributedString makes.
        var applied: [(NSRange, Any)] = []
        storage.enumerateAttribute(faceAttribute, in: lines, options: []) { value, sub, _ in
            if let value { applied.append((sub, value)) }
        }

        guard !spans.isEmpty || !applied.isEmpty else { return false }

        storage.beginEditing()
        defer { storage.endEditing() }

        let base = EditorDocument.baseFont
        for (sub, value) in applied {
            storage.addAttribute(.font, value: base, range: sub)
            storage.removeAttribute(.strikethroughStyle, range: sub)
            // 13k K10: the code chip is written over the face's own ranges,
            // so the clear that owns those ranges owns the chip too — a
            // backtick deleted mid-word must not leave a tinted ghost.
            storage.removeAttribute(.backgroundColor, range: sub)
            if let color = value as? NSColor {
                storage.addAttribute(.foregroundColor, value: color, range: sub)
            } else {
                storage.removeAttribute(.foregroundColor, range: sub)
            }
            storage.removeAttribute(faceAttribute, range: sub)
        }

        guard !spans.isEmpty else { return true }

        // The prose ink over these lines, read AFTER the clear so it is the
        // surface's own color and not a marker's. `NSNull` records "no
        // foreground attribute here", which is a real and common state.
        let prose = storage.attribute(.foregroundColor, at: lines.location, effectiveRange: nil)
        let restore: Any = prose ?? NSNull()

        for span in spans {
            apply(span, to: storage, restore: restore)
        }
        return true
    }

    // MARK: - One span

    private static func apply(
        _ span: MarkdownSyntax.Span, to storage: NSMutableAttributedString, restore: Any
    ) {
        // 13k K10 — THE CODE CHIP, first, over the WHOLE span (backticks
        // included) so it reads as one object: the markers are part of the
        // thing she typed, and a chip that stopped at them would leave two
        // dimmed ticks floating outside their own tint. Hugging the span is
        // also exactly what keeps it distinguishable from a callout frame,
        // which wraps a whole block — her ruling's "never block-wide".
        //
        // A background is written on the STORAGE like every other attribute
        // this file writes (never a TK2 rendering attribute — TEXTKIT2 §3),
        // and it hugs the glyph run by construction: no geometry, nothing to
        // keep in sync with layout.
        if case .code = span.kind {
            let whole = nsRange(span.range)
            if whole.length > 0, whole.upperBound <= storage.length {
                storage.addAttribute(.backgroundColor, value: palette.codeTint, range: whole)
            }
        }
        // Markers first, so a later span's content can read the font a
        // line-leading span left behind (a bold inside a heading composes).
        for marker in span.markers {
            write(
                nsRange(marker), in: storage, restore: restore,
                font: EditorDocument.baseFont, color: palette.marker, strikethrough: false)
        }
        if let url = span.url {
            write(
                nsRange(url), in: storage, restore: restore,
                font: nil, color: palette.marker, strikethrough: false)
        }

        let content = nsRange(span.content)
        guard content.length > 0 else { return }
        let existing = storage.attribute(.font, at: content.location, effectiveRange: nil)
            as? NSFont ?? EditorDocument.baseFont

        switch span.kind {
        case .bold:
            write(content, in: storage, restore: restore,
                  font: adding(.bold, to: existing), color: nil, strikethrough: false)
        case .italic:
            write(content, in: storage, restore: restore,
                  font: adding(.italic, to: existing), color: nil, strikethrough: false)
        case .strikethrough:
            write(content, in: storage, restore: restore,
                  font: nil, color: nil, strikethrough: true)
        case .code:
            write(content, in: storage, restore: restore,
                  font: .monospacedSystemFont(ofSize: existing.pointSize, weight: .regular),
                  color: nil, strikethrough: false)
        case .link:
            write(content, in: storage, restore: restore,
                  font: nil, color: palette.link, strikethrough: false)
        case .heading(let level):
            write(content, in: storage, restore: restore,
                  font: headingFont(level: level), color: nil, strikethrough: false)
        case .bullet, .checkbox:
            // The lead is the whole face; the item's text reads as prose.
            break
        }
    }

    private static func write(
        _ range: NSRange, in storage: NSMutableAttributedString, restore: Any,
        font: NSFont?, color: NSColor?, strikethrough: Bool
    ) {
        guard range.length > 0, range.upperBound <= storage.length else { return }
        if let font { storage.addAttribute(.font, value: font, range: range) }
        if let color { storage.addAttribute(.foregroundColor, value: color, range: range) }
        if strikethrough {
            storage.addAttribute(
                .strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }
        storage.addAttribute(faceAttribute, value: restore, range: range)
    }

    private static func nsRange(_ range: Range<Int>) -> NSRange {
        NSRange(location: range.lowerBound, length: range.count)
    }

    // MARK: - Fonts

    /// The bold/italic face of `font`, or `font` itself when the family ships
    /// no such variant — the honest fallback (both voices' fonts do ship
    /// both, R49; a future voice that doesn't simply loses the trait rather
    /// than the text).
    static func adding(_ traits: NSFontDescriptor.SymbolicTraits, to font: NSFont) -> NSFont {
        let descriptor = font.fontDescriptor
            .withSymbolicTraits(font.fontDescriptor.symbolicTraits.union(traits))
        return NSFont(descriptor: descriptor, size: font.pointSize) ?? font
    }

    /// Headings are SIZES (F-3: "headings-as-sizes"; arbitrary per-span sizes
    /// are not markdown-expressible and are deliberately absent). Bold, and
    /// scaled off the voice's own base size so both voices stay in proportion.
    static func headingFont(level: Int) -> NSFont {
        let base = EditorDocument.baseFont
        let scale: CGFloat
        switch level {
        case 1: scale = 1.6
        case 2: scale = 1.35
        default: scale = 1.15
        }
        let size = (base.pointSize * scale).rounded()
        let descriptor = base.fontDescriptor
            .withSymbolicTraits(base.fontDescriptor.symbolicTraits.union(.bold))
        return NSFont(descriptor: descriptor, size: size)
            ?? NSFont(descriptor: base.fontDescriptor, size: size)
            ?? base
    }
}
