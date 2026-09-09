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
    ///
    /// It is false in a host that never starts a `ThemeStore` (a preview, a
    /// mounted pin), and that is correct rather than unfortunate: such a host
    /// has no voice of hers to be right about, so its surface sizes are not
    /// worth recording either. The memory is simply inert there.
    nonisolated(unsafe) static var isAdopted = false

    /// **The one adoption door, and it has exactly one caller:
    /// `ThemeStore.start`, where a settings value LANDS.** Round 2's MAJOR-1
    /// is why that is stated as a rule rather than left as a fact: for one
    /// round `applyVoiceChrome` called this too, with a chrome its hosts had
    /// built from the store's un-answered placeholder, and the latch made the
    /// guess indistinguishable from her answer. Anything that only DRAWS
    /// writes `current` directly; only the settings' authority adopts.
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

    /// **The paragraph gap a surface LAYS OUT with** — the voice's resolved
    /// spacing PLUS this Mac's `ParagraphGap` dial (A23). ONE arithmetic,
    /// read by `EditorDocument.baseParagraphStyle` (the layout) and by
    /// `fingerprint` (the stamp) — the round-end Fable pass's round 2,
    /// MINOR-1: the two used to be one arithmetic and one omission, and a
    /// stamp that does not move with the layout is the stale-reservation
    /// failure the stamp exists to prevent. The dial deliberately stays OUT
    /// of `current`/`Resolved` (its own doc at `ParagraphGap.current`): it is
    /// app-local `UserDefaults`, not the synced `setting` row `ThemeStore`
    /// observes, so a copy cached in `current` would never be re-resolved
    /// when she moves it — and since round 1's fix `adopt` is `current`'s
    /// only writer past adoption, that stale copy would be the LAYOUT's, not
    /// only the stamp's. Read at every call, as `baseParagraphStyle` always
    /// has: one cached defaults string, constant, never ∝ document.
    static func laidOutParagraphSpacing(_ resolved: Resolved) -> CGFloat {
        resolved.paragraphSpacing + ParagraphGap.current.extraSpacing(for: resolved.font)
    }

    /// 18d batch 4 (U-12): the CURRENT text-surface typography as one short
    /// token — the stamp a remembered surface size carries
    /// (`SurfaceSizeMemory.Record`), so a height measured in Terminal's
    /// 14-pt monospace is never reserved for Study's 16-pt Iowan, a height
    /// measured without inline comments is never reserved with them, and —
    /// since the round-end Fable pass's round 2 (MINOR-1) — a height measured
    /// under the standard paragraph gap is never reserved under the tall one.
    ///
    /// **THE MAINTENANCE RULE, keyed on what the surface lays out with:** a
    /// dial that changes what `EditorDocument.baseAttributes` produces must
    /// be added to this stamp in the same edit, whether or not it passes
    /// through `resolve`. The font and the resolved spacing arrive through
    /// `Resolved` for free; the paragraph-gap dial does NOT pass through
    /// `resolve` (see `laidOutParagraphSpacing`) and was missed for exactly
    /// that reason — she flips it in Settings, every mounted surface
    /// re-styles at once (the chrome's `Equatable` gate carries it), and
    /// every stored record kept the old stamp, so each remembered note stood
    /// at the wrong height for one settle on its next realization. The grep
    /// that finds the next such dial: `@AppStorage` on the surfaces
    /// `SurfaceSizeMemory(.outline)` measures (`EditorView`, `ReadPostView`
    /// — today `ParagraphGap`, `SpellcheckLevel` and `writeHoverHandles`, of
    /// which only the first moves laid-out height). The `.flow` key space
    /// needs none of this: its page is a SwiftUI `Text` with its own
    /// constants (`FlowHeightEstimate.fingerprint`), untouched by the dial.
    /// Never contains `|` (the record's separator): font names and integers
    /// do not.
    /// **nil until the voice is KNOWN** (18d ladder MINOR-2): a stamp is a
    /// claim about which type a height was measured in, and before the
    /// settings land this module has no such claim to make — only the
    /// default. A reader treats nil as "no stamp to compare" and a writer as
    /// "nothing to stamp"; neither invents one.
    static var fingerprint: String? {
        guard isAdopted else { return nil }
        let resolved = current
        return "\(resolved.font.fontName)-\(Int(resolved.font.pointSize.rounded()))"
            + "-\(Int(laidOutParagraphSpacing(resolved).rounded()))"
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
        //
        // **It writes `current` only while the voice is NOT YET ADOPTED, and
        // it never adopts** (18d ladder round 2, MAJOR-1 closed the latch;
        // the round-end Fable pass's MINOR-1 closed the value). Both hosts
        // build this chrome from `themeStore?.settings ?? Queries.ThemeSettings()`,
        // and a `ThemeStore` that has not answered yet HOLDS that same
        // placeholder — the app mints one store per window kind, so a NOTE
        // WINDOW opened in a Study session hands this door the compile-time
        // Terminal guess while the main window is long adopted. Written
        // unconditionally, that guess replaced `current` for the whole
        // process: `fingerprint` (derived from `current` once adopted) became
        // the monospace stamp, the main window's Outline REFUSED her
        // Study-stamped lengths, and a settle in that window wrote a
        // Study-measured height under the Terminal stamp over her record.
        // After adoption `adopt` is `current`'s ONLY writer — which is what
        // "only the settings' authority adopts" has to mean for the stamp to
        // be structurally hers. Before adoption the write stands: the
        // placeholder is the best guess there is, and `SurfaceSizeMemory`
        // refuses to record under it either way (`fingerprint` is nil).
        //
        // Strictly better for drawing too: `EditorDocument.baseFont` and its
        // siblings read `current`, so a surface materializing in a window
        // whose store has not landed now materializes in the ADOPTED voice
        // instead of Terminal-then-flip. Every `EditorSurfaceChrome` is built
        // from a `ThemeSettings` and there is no per-surface voice override,
        // so a landed host's chrome is exactly the adopted resolution — nothing
        // a host draws changes on the normal path, and a voice SWITCH still
        // re-fonts because `ThemeStore.start` adopts before any surface
        // re-applies.
        if !EditorTypography.isAdopted {
            EditorTypography.current = chrome.typography
        }
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
