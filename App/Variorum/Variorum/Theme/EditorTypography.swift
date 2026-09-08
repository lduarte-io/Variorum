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

    /// **18d ladder round 1, MINOR-2: whether `current` is the STORE's answer
    /// or still the compile-time default above.** Until the appearance
    /// settings have landed, "the current typography" is a guess — the
    /// leading voice, which is right for a Terminal store by luck and wrong
    /// for a Study one. Nothing that only DRAWS needs to tell those apart (a
    /// surface materialized early re-styles when its chrome is applied), but
    /// anything that RECORDS the typography must, or it stamps a guess:
    /// `SurfaceSizeMemory.remember` writes no record while this is false, so
    /// a geometry report arriving in that window can never overwrite a
    /// record she measured in her own voice.
    ///
    /// Settable rather than `private(set)` so a pin can put the process
    /// global back where it found it — this value is shared across Swift
    /// Testing's parallel suites (batch 1's MINOR-3 class).
    nonisolated(unsafe) static var isAdopted = false

    /// The one adoption door: `ThemeStore` calls it where a settings value
    /// LANDS, and `applyVoiceChrome` calls it when a surface takes a real
    /// voice. Both were already writing `current`; what they now also say is
    /// that the answer is no longer a guess.
    static func adopt(_ resolved: Resolved) {
        current = resolved
        isAdopted = true
    }

    /// The same door from the settings themselves.
    static func adopt(_ settings: Queries.ThemeSettings) {
        adopt(resolve(voice: settings.voice, inlineComments: settings.inlineComments))
    }

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

    /// 18d batch 4 (U-12): the CURRENT text-surface typography as one short
    /// token — the stamp a remembered surface size carries
    /// (`SurfaceSizeMemory.Record`), so a height measured in Terminal's
    /// 14-pt monospace is never reserved for Study's 16-pt Iowan, and a
    /// height measured without inline comments is never reserved with them.
    ///
    /// Derived from `Resolved` itself rather than from the settings, so any
    /// future dial that reaches the surface through `resolve` moves the
    /// stamp for free — a dial that changes the type and not this string
    /// would leave stale reservations behind, which is the one failure this
    /// stamp exists to prevent. Never contains `|` (the record's separator):
    /// font names and integers do not.
    /// **nil until the voice is KNOWN** (18d ladder MINOR-2): a stamp is a
    /// claim about which type a height was measured in, and before the
    /// settings land this module has no such claim to make — only the
    /// default. A reader treats nil as "no stamp to compare" and a writer as
    /// "nothing to stamp"; neither invents one.
    static var fingerprint: String? {
        guard isAdopted else { return nil }
        let resolved = current
        return "\(resolved.font.fontName)-\(Int(resolved.font.pointSize.rounded()))"
            + "-\(Int(resolved.paragraphSpacing.rounded()))"
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
        // surface write (materialization, differential) agrees. Through
        // `adopt` since the 18d ladder's MINOR-2: a surface taking a real
        // voice is an adoption, not a guess.
        EditorTypography.adopt(chrome.typography)
        // 13g batch 2 (L7): the markdown face's two colors ride the same
        // resolution — one voice, one dimmed marker, everywhere.
        MarkdownStyling.palette = MarkdownStyling.Palette(tokens: chrome.tokens)
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
            // 13g batch 2 (L7): the base refresh above (and the `textColor`
            // write before it) flatten the markdown face — re-derive it in the
            // NEW voice, in the same transaction. Whole-document is right
            // here and only here: a voice switch is a rare, deliberate
            // gesture whose whole point is that everything re-fonts.
            MarkdownStyling.style(storage)
            storage.endEditing()
        }
    }
}
