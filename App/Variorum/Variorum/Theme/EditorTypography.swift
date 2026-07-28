//
//  EditorTypography.swift
//  Variorum
//
//  Phase 13, C1 — the voice's TEXT-SURFACE half (B1 voiced the chrome; "the
//  editor surfaces get theirs in Stage C"). One resolved typography feeds
//  EVERY TK2 surface write through `EditorDocument.baseAttributes` — the
//  detail editor, the inline book editor, the read tier, the take panes —
//  so no path can disagree about the prose's font (the one-source doctrine
//  EditorDocument already states). The voice carries the FONT (R1's letter:
//  "terminal should be an option for the font / styling / colors"): SF Mono
//  for the terminal voice, Iowan Old Style for the study voice — both
//  macOS-shipped (R49, zero dependencies).
//
//  The uniform per-PARAGRAPH gap (the 2026-07-12 ruling's presentation
//  half) rides the font size as before — and widens uniformly when INLINE
//  comments are on (R7's offered setting): the widened gap is where the
//  tinted comment strips render, and because it applies to EVERY paragraph
//  (intra-block newlines and seams alike), §12's boundaries-invisible-at-
//  rest holds exactly as the ruling reasoned. PROVISIONAL (QUESTIONS #27):
//  inline comments = a uniformly airier layout that leaves room for the
//  notes.
//
//  Concurrency: `current` is written ONLY on the main thread (RootView's
//  theme adoption + the surface coordinators' voice application) and read
//  by main-thread surface writes; tests that read it concurrently never
//  race a write (no writer exists off the app's main-thread paths).
//

import AppKit
import SwiftUI
import VariorumCore

nonisolated enum EditorTypography {
    /// One voice's resolved text-surface typography.
    struct Resolved: Equatable {
        let font: NSFont
        /// The uniform per-paragraph gap (points).
        let paragraphSpacing: CGFloat
    }

    /// Extra uniform paragraph room when inline comments are ON — one
    /// comment strip's height (small font + padding).
    static let inlineCommentSpacing: CGFloat = 22

    /// The live resolution every surface write reads (see the concurrency
    /// note above). Defaults to the leading voice (terminal — R1).
    nonisolated(unsafe) static var current: Resolved =
        EditorTypography.resolve(voice: .terminal, inlineComments: false)

    static func resolve(voice: ThemeVoice, inlineComments: Bool) -> Resolved {
        let font: NSFont
        switch voice {
        case .terminal:
            font = .monospacedSystemFont(ofSize: 14, weight: .regular)
        case .study:
            // Iowan Old Style ships with macOS (R49); the serif system
            // design is the never-reached safety net.
            font = NSFont(name: "Iowan Old Style", size: 16)
                ?? NSFont(descriptor: NSFont.systemFont(ofSize: 16).fontDescriptor
                    .withDesign(.serif) ?? NSFont.systemFont(ofSize: 16).fontDescriptor,
                    size: 16)
                ?? .systemFont(ofSize: 16)
        }
        let gap = (font.pointSize * 0.5).rounded()
            + (inlineComments ? inlineCommentSpacing : 0)
        return Resolved(font: font, paragraphSpacing: gap)
    }

    // MARK: - Margins (R9 — sacred; "text never runs near the window edge")

    /// The prose column's maximum width on the detail editor (≈68ch of
    /// body prose — the mockups' measure).
    static let maxColumnWidth: CGFloat = 680
    /// The floor gutter: even a narrow window keeps real air (the TextEdit
    /// anti-pattern, named in R9).
    static let minGutter: CGFloat = 28
    /// The text-container inset carried by the CONTAINED text surfaces —
    /// the inline (book) editor and the read tier — whose prose column is
    /// bounded by their SwiftUI frame rather than by their own gutter rule.
    /// Named (13c 2A) because a composer that wants Write's exact measure
    /// must size its column to `maxColumnWidth + 2 * inlineSurfaceInset`,
    /// and that arithmetic was previously a literal in three places.
    static let inlineSurfaceInset: CGFloat = 8

    /// The horizontal text-container inset that centers a `maxColumn`-wide
    /// prose column in `viewWidth`, never dropping below `minGutter`.
    static func gutterInset(
        viewWidth: CGFloat,
        maxColumn: CGFloat = maxColumnWidth,
        minGutter: CGFloat = minGutter
    ) -> CGFloat {
        max(minGutter, ((viewWidth - maxColumn) / 2).rounded(.down))
    }
}

/// The view-level (non-attribute) chrome a voice applies to a TK2 surface:
/// paper, ink, caret. Colors stay in the token layer; this is the NSColor
/// bridge the AppKit surfaces consume.
struct EditorSurfaceChrome: Equatable {
    let voice: ThemeVoice
    let dark: Bool
    let inlineComments: Bool
    /// 13d batch 4 (A23/A24): the two this-Mac editor-behaviour settings
    /// ride the chrome value NOT because they are "chrome" in the voice
    /// sense, but because the chrome's `Equatable` gate is the app's ONE
    /// "this surface's presentation moved, re-apply it" mechanism — and a
    /// second mechanism beside it is exactly what P-3 forbids. A gap change
    /// moves no font, so without this the gate would never notice it.
    let paragraphGap: ParagraphGap
    let spellcheck: SpellcheckLevel

    init(
        voice: ThemeVoice, dark: Bool, inlineComments: Bool,
        paragraphGap: ParagraphGap = .standard,
        spellcheck: SpellcheckLevel = .off
    ) {
        self.voice = voice
        self.dark = dark
        self.inlineComments = inlineComments
        self.paragraphGap = paragraphGap
        self.spellcheck = spellcheck
    }

    init(
        tokens settings: Queries.ThemeSettings, dark: Bool,
        paragraphGap: ParagraphGap = .standard,
        spellcheck: SpellcheckLevel = .off
    ) {
        self.init(
            voice: settings.voice, dark: dark,
            inlineComments: settings.inlineComments,
            paragraphGap: paragraphGap, spellcheck: spellcheck)
    }

    var tokens: VoiceTokens { .resolve(voice: voice, dark: dark) }
    var typography: EditorTypography.Resolved {
        EditorTypography.resolve(voice: voice, inlineComments: inlineComments)
    }

    var paper: NSColor { NSColor(tokens.surface) }
    var ink: NSColor { NSColor(tokens.ink) }
    var caret: NSColor { NSColor(tokens.accent) }
}

extension NSTextView {
    /// Applies a voice's chrome + typography to a live TK2 surface: colors,
    /// caret, base font, and a full-range base-attribute refresh that
    /// PRESERVES the block-ID bookkeeping attribute (addAttributes never
    /// removes keys it doesn't name). A whole-document font swap is an
    /// ordinary storage write on a rare, deliberate gesture (voice switch)
    /// — distinct from the per-range RENDERING attributes TEXTKIT2 §3
    /// warns about; decorations stay overlays.
    func applyVoiceChrome(_ chrome: EditorSurfaceChrome) {
        // The one global typography updates FIRST so every subsequent
        // surface write (materialization, differential) agrees.
        EditorTypography.current = chrome.typography
        backgroundColor = chrome.paper
        textColor = chrome.ink
        insertionPointColor = chrome.caret
        chrome.spellcheck.apply(to: self)  // A24 — write-gated inside
        font = EditorDocument.baseFont
        defaultParagraphStyle = EditorDocument.baseParagraphStyle
        typingAttributes = EditorDocument.baseAttributes
        if let storage = textStorage, storage.length > 0 {
            storage.beginEditing()
            storage.addAttributes(
                EditorDocument.baseAttributes,
                range: NSRange(location: 0, length: storage.length))
            storage.endEditing()
        }
    }
}
