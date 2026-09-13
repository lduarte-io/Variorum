//
//  MarkdownFaceCore.swift
//  Variorum / VariorumMobile (Shared/MarkdownFace)
//
//  Mobile Stage 1, batch 2 — the markdown editing face's ALGORITHM, shared
//  by both app targets. Transplanted verbatim from the Mac's
//  `Theme/MarkdownStyling.swift` (Phase 13g L7 + 13k K10) at the parity
//  move: the Mac keeps every pre-move name as forwards there; the phone
//  calls this core with its own base font and palette. What stays
//  per-platform is exactly what the batch brief says should — the VALUES
//  (which font, which colors: the Mac's voice tokens, the phone's
//  `MobileEditorStyle`) — while the algorithm (line-scoped rescan, the
//  face-attribute clear/restore bookkeeping, chip-first application,
//  markers-then-content composition) exists ONCE.
//
//  **Why this folder and not `EditorBrain/`:** EditorBrain's charter is
//  platform-purity — no UI framework may live there. A styling face
//  necessarily traffics in fonts and colors, so it lives in its own shared
//  folder with conditional typealiases; both targets compile it (the
//  `Shared/` synchronized group), and the typealiases resolve per platform.
//
//  **The one invariant, unchanged from the Mac original: DISPLAY == STORED,
//  BYTE FOR BYTE.** This file only ever writes ATTRIBUTES — never a
//  character. That is what keeps block identity, crystallization, autosave,
//  and every gesture reading exactly the offsets they always read
//  (AppSpec §15 risk 1 untouched by formatting).
//
//  **Mechanism: real text-storage attributes, never TK2 rendering
//  attributes** (TEXTKIT2_NOTES §3 — rendering attributes draw unreliably,
//  with a reported crash in their draw path). `NSTextList` is never
//  invoked; a list is TEXT LINES (F-1's letter).
//
//  **P1: the rescan is ∝ the edited paragraph(s), never the document** —
//  `restyle(_:range:...)` expands to whole LINES and tokenizes only those;
//  `MarkdownScanCount` (DEBUG, on the shared scanner) pins it on both
//  platforms. The zero-write fast path: text with no markdown and no
//  previously applied face writes NOTHING.
//

import Foundation
import VariorumCore

#if canImport(UIKit)
import UIKit
typealias MarkdownFaceFont = UIFont
typealias MarkdownFaceColor = UIColor
typealias MarkdownFaceTraits = UIFontDescriptor.SymbolicTraits
#else
import AppKit
typealias MarkdownFaceFont = NSFont
typealias MarkdownFaceColor = NSColor
typealias MarkdownFaceTraits = NSFontDescriptor.SymbolicTraits
#endif

nonisolated enum MarkdownFace {
    /// The two colors the face needs beyond the prose ink, plus the 13k K10
    /// code-chip tint. The platform supplies the VALUES (the Mac maps its
    /// voice-token palette; the phone maps `MobileEditorStyle`'s).
    struct Palette: Equatable {
        let marker: MarkdownFaceColor
        let link: MarkdownFaceColor
        let codeTint: MarkdownFaceColor
        /// **The surface's CURRENT prose ink** (18j — the 18g ladder's R2-1,
        /// a pre-existing MAJOR from 13g L7). A faced run is cleared back to
        /// THIS, never to the ink that happened to be under the face when it
        /// was written: an ink MOVE (a live dark/light toggle, a voice
        /// switch) writes the new colour over the whole storage and then
        /// re-derives the face, and a restore from a captured colour puts
        /// the stale one straight back over it — bold, italic, heading and
        /// code came back in the OLD ink while only the link (which
        /// re-derives from `link`) was right.
        ///
        /// The face-attribute value still records PRESENCE (a run that had
        /// no colour ends with none — `NSNull`); what it no longer decides
        /// is WHICH colour, because the host knows that and the face does
        /// not. **Required, never defaulted** — the structural-redo
        /// `register(redo:)` posture: a future host must DECIDE what its
        /// prose ink is rather than silently inherit a stand-in that would
        /// put the wrong colour back under every face it clears. Both
        /// platforms' one builder supplies it
        /// (`MarkdownStyling.Palette(tokens:)`, `MobileEditorStyle.Face`).
        let prose: MarkdownFaceColor

        init(
            marker: MarkdownFaceColor, link: MarkdownFaceColor,
            codeTint: MarkdownFaceColor, prose: MarkdownFaceColor
        ) {
            self.marker = marker
            self.link = link
            self.codeTint = codeTint
            self.prose = prose
        }
    }

    /// The bold/italic symbolic traits, named per platform (UIKit spells
    /// them `.traitBold`/`.traitItalic`; AppKit `.bold`/`.italic`).
    #if canImport(UIKit)
    static let boldTrait: MarkdownFaceTraits = .traitBold
    static let italicTrait: MarkdownFaceTraits = .traitItalic
    #else
    static let boldTrait: MarkdownFaceTraits = .bold
    static let italicTrait: MarkdownFaceTraits = .italic
    #endif

    /// Marks a range this face has styled, and records WHETHER the prose
    /// carried a foreground color there — so clearing puts the surface's
    /// CURRENT ink back (`Palette.prose`) or removes the attribute again.
    /// `NSNull` records "there was no foreground attribute" (the state
    /// materialization produces).
    ///
    /// *(18j — R2-1: the value used to be the captured COLOR itself and the
    /// clear wrote it straight back, which is how an ink move left every
    /// non-link face in the old ink. It is kept as a color rather than a
    /// flag because a stored `NSColor` is what every surface already carries
    /// and reading it as "a color was here" costs nothing; what changed is
    /// that nothing restores FROM it.)* ONE key across both platforms — the
    /// Mac's `MarkdownStyling.faceAttribute` forwards here.
    static let faceAttribute = NSAttributedString.Key("io.lduarte.variorum.markdownFace")

    // MARK: - Doors

    /// Styles a freshly materialized surface string (the full-render door).
    @discardableResult
    static func style(
        _ attributed: NSMutableAttributedString,
        base: MarkdownFaceFont, palette: Palette
    ) -> Bool {
        restyle(
            attributed, range: NSRange(location: 0, length: attributed.length),
            base: base, palette: palette)
    }

    /// Re-styles the LINES that `range` touches. Returns whether anything
    /// was written (false = the zero-write fast path).
    ///
    /// The range is widened by one unit before the line lookup so that an
    /// edit ending exactly at a line's end restyles the FOLLOWING line too.
    /// Two lines is still ∝ the edit.
    @discardableResult
    static func restyle(
        _ storage: NSMutableAttributedString, range: NSRange,
        base: MarkdownFaceFont, palette: Palette
    ) -> Bool {
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
        // BEFORE mutating, because enumerating an attribute while removing
        // it is not a contract NSAttributedString makes.
        var applied: [(NSRange, Any)] = []
        storage.enumerateAttribute(faceAttribute, in: lines, options: []) { value, sub, _ in
            if let value { applied.append((sub, value)) }
        }

        guard !spans.isEmpty || !applied.isEmpty else { return false }

        storage.beginEditing()
        defer { storage.endEditing() }

        for (sub, value) in applied {
            storage.addAttribute(.font, value: base, range: sub)
            storage.removeAttribute(.strikethroughStyle, range: sub)
            // 13k K10: the code chip is written over the face's own ranges,
            // so the clear that owns those ranges owns the chip too — a
            // backtick deleted mid-word must not leave a tinted ghost.
            storage.removeAttribute(.backgroundColor, range: sub)
            // 18j (R2-1): the CURRENT ink, never the captured one. The value
            // decides only whether there WAS a colour here.
            if value is MarkdownFaceColor {
                storage.addAttribute(.foregroundColor, value: palette.prose, range: sub)
            } else {
                storage.removeAttribute(.foregroundColor, range: sub)
            }
            storage.removeAttribute(faceAttribute, range: sub)
        }

        guard !spans.isEmpty else { return true }

        // The prose ink over these lines, read AFTER the clear so it is the
        // surface's own color and not a marker's.
        let prose = storage.attribute(.foregroundColor, at: lines.location, effectiveRange: nil)
        let restore: Any = prose ?? NSNull()

        for span in spans {
            apply(span, to: storage, restore: restore, base: base, palette: palette)
        }
        return true
    }

    // MARK: - One span

    private static func apply(
        _ span: MarkdownSyntax.Span, to storage: NSMutableAttributedString,
        restore: Any, base: MarkdownFaceFont, palette: Palette
    ) {
        // 13k K10 — THE CODE CHIP, first, over the WHOLE span (backticks
        // included) so it reads as one object; hugging the span is what
        // keeps it distinguishable from a callout frame ("never
        // block-wide"). A background on the STORAGE like every other write
        // here — never a TK2 rendering attribute.
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
                font: base, color: palette.marker, strikethrough: false)
        }
        if let url = span.url {
            write(
                nsRange(url), in: storage, restore: restore,
                font: nil, color: palette.marker, strikethrough: false)
        }

        let content = nsRange(span.content)
        guard content.length > 0 else { return }
        let existing = storage.attribute(.font, at: content.location, effectiveRange: nil)
            as? MarkdownFaceFont ?? base

        switch span.kind {
        case .bold:
            write(content, in: storage, restore: restore,
                  font: adding(boldTrait, to: existing), color: nil, strikethrough: false)
        case .italic:
            write(content, in: storage, restore: restore,
                  font: adding(italicTrait, to: existing), color: nil, strikethrough: false)
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
                  font: headingFont(level: level, base: base), color: nil, strikethrough: false)
        case .bullet, .checkbox:
            // The lead is the whole face; the item's text reads as prose.
            break
        }
    }

    private static func write(
        _ range: NSRange, in storage: NSMutableAttributedString, restore: Any,
        font: MarkdownFaceFont?, color: MarkdownFaceColor?, strikethrough: Bool
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

    /// The bold/italic face of `font`, or `font` itself when the family
    /// ships no such variant — the honest fallback (a voice that doesn't
    /// simply loses the trait rather than the text).
    static func adding(_ traits: MarkdownFaceTraits, to font: MarkdownFaceFont) -> MarkdownFaceFont {
        #if canImport(UIKit)
        guard let descriptor = font.fontDescriptor.withSymbolicTraits(
            font.fontDescriptor.symbolicTraits.union(traits))
        else { return font }
        return MarkdownFaceFont(descriptor: descriptor, size: font.pointSize)
        #else
        let descriptor = font.fontDescriptor
            .withSymbolicTraits(font.fontDescriptor.symbolicTraits.union(traits))
        return MarkdownFaceFont(descriptor: descriptor, size: font.pointSize) ?? font
        #endif
    }

    /// Headings are SIZES (F-3's letter), bold, scaled off the surface's own
    /// base size so any voice stays in proportion.
    static func headingFont(level: Int, base: MarkdownFaceFont) -> MarkdownFaceFont {
        let scale: CGFloat
        switch level {
        case 1: scale = 1.6
        case 2: scale = 1.35
        default: scale = 1.15
        }
        let size = (base.pointSize * scale).rounded()
        #if canImport(UIKit)
        guard let descriptor = base.fontDescriptor.withSymbolicTraits(
            base.fontDescriptor.symbolicTraits.union(boldTrait))
        else { return MarkdownFaceFont(descriptor: base.fontDescriptor, size: size) }
        return MarkdownFaceFont(descriptor: descriptor, size: size)
        #else
        let descriptor = base.fontDescriptor
            .withSymbolicTraits(base.fontDescriptor.symbolicTraits.union(boldTrait))
        return MarkdownFaceFont(descriptor: descriptor, size: size)
            ?? MarkdownFaceFont(descriptor: base.fontDescriptor, size: size)
            ?? base
        #endif
    }
}
