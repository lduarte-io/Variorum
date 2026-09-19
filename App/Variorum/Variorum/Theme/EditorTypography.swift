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
        /// **18j:** which voice this resolution IS, so the prose INK can be
        /// read from the same one-source place the FONT is. It is the same
        /// fact the font already encodes (one font per voice) — named rather
        /// than derived, because deriving a voice from a font name is the
        /// guess this module exists to avoid. It does not reach
        /// `fingerprint` (the font name and the spacing already say
        /// everything a stamp compares) and `resolve` below is its ONE
        /// constructor, so nothing else had to change.
        let voice: ThemeVoice
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

    // MARK: - The prose ink (18j — her R-Q12)

    /// **THE PROSE INK, as ONE DYNAMIC COLOUR PER VOICE** — the phone's own
    /// pattern ported (`MobileEditorStyle.Face`, whose every colour is a
    /// `UIColor` with a provider, cached one face per voice).
    ///
    /// **Why the ink had to come here at all** (18j's dark walk, the first
    /// thing it found): `EditorDocument.baseAttributes` carried the font and
    /// the paragraph style and NO colour, so a materialized document's prose
    /// had no `.foregroundColor` at all. The Write editor's chrome is applied
    /// at `makeNSView` — on an EMPTY storage — so `textColor`'s setter had no
    /// characters to write and left only the typing attributes; the document
    /// then arrived through `setAttributedString` and drew in AppKit's own
    /// default. In LIGHT that default is near-black and the voice's ink is
    /// near-black, so the defect hid for the editor's whole life. In DARK
    /// every note in Write was black on black. (The read tier and the panes
    /// were always right: they set the colour and THEN the string, so the
    /// typing attributes carry it into every character.)
    ///
    /// **Why DYNAMIC and not "resolve it for the current appearance"**: a
    /// static colour would have to be re-written over the whole storage every
    /// time the appearance moved — `NSTextView.textColor`'s setter
    /// re-attributes every character, which on a long note invalidates the
    /// document and jumps the viewport (the 18g ladder's R2-5, the second
    /// item this batch inherited). One colour object that answers per
    /// appearance costs NO storage write at all: AppKit resolves it against
    /// the drawing view's `effectiveAppearance` at draw time. That is why
    /// `inkChanged(from:)` below is keyed on the VOICE alone.
    ///
    /// One instance per voice, held. **The provider is NOT cached by AppKit
    /// — it runs on EVERY resolution** (18j ladder round 1, R1-3, measured on
    /// a standalone TK2 probe: 250 provider calls per draw of 200 lines at
    /// steady state, ~1.25 per line fragment, 500 on the first draw after an
    /// appearance flip, 63 per 40-line viewport draw). The cost is ∝ the
    /// visible line fragments — never the document — and today it is a
    /// `switch` over four static sets plus one `NSColor(Color)` bridge at
    /// ~0.6 µs, which a 40-line viewport draw showed as 1.61 ms against
    /// 1.51 ms with a static colour. **That is the rule this design now
    /// rests on: the provider must stay a table lookup.** Anything that
    /// wants to COMPUTE a colour belongs in the token layer, where it is
    /// computed once — which is one more reason a palette is not an input
    /// here: it deliberately does not move `ink` (18g's derivation table —
    /// prose is the voice's register), and routed through this provider its
    /// derivation would run per line fragment per draw.
    nonisolated(unsafe) private static let terminalInk = dynamicInk(.terminal)
    nonisolated(unsafe) private static let studyInk = dynamicInk(.study)

    /// The ink for a NAMED voice — what a surface's own chrome asks for.
    static func ink(for voice: ThemeVoice) -> NSColor {
        switch voice {
        case .terminal: terminalInk
        case .study: studyInk
        }
    }

    /// The ink of the ADOPTED voice — what `EditorDocument.baseAttributes`
    /// asks for, beside `baseFont`, from the same `current`.
    static var ink: NSColor { ink(for: current.voice) }

    private static func dynamicInk(_ voice: ThemeVoice) -> NSColor {
        NSColor(name: NSColor.Name("variorum.prose.ink.\(voice.rawValue)")) { appearance in
            let dark = appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            return NSColor(VoiceTokens.resolve(voice: voice, dark: dark).ink)
        }
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
        return Resolved(font: font, paragraphSpacing: gap, voice: voice)
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

    // (**THE DECORATION LANE is RETIRED** — 13u3 UNIT A1. 17p batch b's
    //  `commentLane` (64) and `inlineInset(needsLane:)` made a CONTAINED
    //  surface's prose start 72 pt in whenever the note carried a comment or
    //  a callout glyph, which is the measure-moving she reversed on
    //  2026-09-14 (the master plan's item 20 / R-13u-9; QUESTIONS #102's
    //  whole option space went with it). The room a decoration needs is the
    //  page's own whitespace now, reached by growing the surface's FRAME
    //  rather than by narrowing her text — `Surface/ProseGutter.swift`.)

    /// The horizontal text-container inset that centers a `maxColumn`-wide
    /// prose column in `viewWidth`, never dropping below `minGutter`.
    ///
    /// 13u3 UNIT A1: the arithmetic moved to `ProseGutter` (the one rule for
    /// every surface); this stays as the name Write's own geometry has been
    /// called by since Phase 13 C1, and forwards.
    static func gutterInset(
        viewWidth: CGFloat,
        maxColumn: CGFloat = maxColumnWidth,
        minGutter: CGFloat = minGutter
    ) -> CGFloat {
        ProseGutter(maxColumn: maxColumn, minGutter: minGutter, centred: true)
            .insets(viewWidth: viewWidth).leading
    }
}

/// The view-level (non-attribute) chrome a voice applies to a TK2 surface:
/// paper, ink, caret. Colors stay in the token layer; this is the NSColor
/// bridge the AppKit surfaces consume.
struct EditorSurfaceChrome: Equatable {
    let voice: ThemeVoice
    let dark: Bool
    let inlineComments: Bool
    /// **The palette and its custom seeds RIDE THE CHROME VALUE** (18g
    /// ladder, R1-1) for the same reason the two settings below do: this
    /// value's `Equatable` gate is the app's ONE "this surface's
    /// presentation moved, re-apply it" mechanism (P-3), and a palette
    /// click that left the value equal would change nothing on screen
    /// until some unrelated re-apply. They are STORED, not merely resolved,
    /// so the gate sees them; `tokens` below resolves through the one
    /// settings → tokens road, never the palette-less forwarder. A palette
    /// click therefore takes the voice-switch road — `applyVoiceChrome`'s
    /// whole-document refresh on every mounted surface — the same rare,
    /// deliberate gesture, and the A47c guard already rides it.
    let palette: ThemePalette
    let tint: PaletteTint
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
        palette: ThemePalette = .default, tint: PaletteTint = .none,
        paragraphGap: ParagraphGap = .standard,
        spellcheck: SpellcheckLevel = .off
    ) {
        self.voice = voice
        self.dark = dark
        self.inlineComments = inlineComments
        self.palette = palette
        self.tint = tint
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
            palette: settings.palette, tint: PaletteTint(settings),
            paragraphGap: paragraphGap, spellcheck: spellcheck)
    }

    /// The four-parameter resolver — the palette-aware road. A default
    /// palette returns the voice's static set byte-identically.
    var tokens: VoiceTokens {
        .resolve(voice: voice, palette: palette, tint: tint, dark: dark)
    }
    var typography: EditorTypography.Resolved {
        EditorTypography.resolve(voice: voice, inlineComments: inlineComments)
    }

    var paper: NSColor { NSColor(tokens.surface) }
    /// **18j:** the ONE dynamic ink for this chrome's voice — not
    /// `NSColor(tokens.ink)`, which is this appearance's answer frozen. The
    /// same object serves both appearances, so writing it once is writing it
    /// for good (`EditorTypography.ink(for:)` says why at length). A palette
    /// never moves the ink (18g's derivation table), so the voice is its
    /// only input.
    var ink: NSColor { EditorTypography.ink(for: voice) }
    var caret: NSColor { NSColor(tokens.accent) }

    // MARK: What a chrome change has to touch (18g ladder, the R1-1 walk)

    /// **Whether this chrome, applied after `previous`, must re-write the
    /// STORAGE's base attributes** — the font and the paragraph style, a
    /// full-range write that invalidates the whole document's layout (the
    /// voice-switch road: a rare, deliberate re-font). Only the inputs of
    /// `EditorDocument.baseAttributes` decide it: the voice (the font),
    /// inline comments and the paragraph gap (the paragraph style). A
    /// PALETTE, a custom seed or the appearance moves no base attribute, so
    /// a colour-only change takes the cheap road — the walk of the R1-1 fix
    /// caught a palette click on a 262-block note taking the full refresh
    /// and jumping the viewport (18g's `write-long-note-*-JUMP-*` captures).
    /// Nil previous means "first application": everything.
    func needsStorageRefresh(from previous: EditorSurfaceChrome?) -> Bool {
        guard let previous else { return true }
        return previous.voice != voice
            || previous.inlineComments != inlineComments
            || previous.paragraphGap != paragraphGap
    }

    /// Whether the INK moved — `NSTextView.textColor`'s setter writes the
    /// colour over the entire storage, so it is set as rarely as it can be.
    ///
    /// **18j — the APPEARANCE is no longer an input** (the 18g ladder's R2-5,
    /// the second item this batch inherited). The ink is now ONE dynamic
    /// colour per voice (`EditorTypography.ink(for:)`): the very same object
    /// answers light and dark, so a light/dark change needs no write at all —
    /// AppKit re-resolves it against the drawing view's appearance. Before
    /// this, `dark` moving meant a full-range `textColor` write, which on the
    /// 262-block story invalidated the document and jumped the viewport
    /// exactly as the re-font road does. A palette never moved the ink and
    /// still does not, so the VOICE is the only input left.
    func inkChanged(from previous: EditorSurfaceChrome?) -> Bool {
        guard let previous else { return true }
        return previous.voice != voice
    }
}

extension NSTextView {
    /// Applies a voice's chrome + typography to a live TK2 surface: colors,
    /// caret, base font, and a full-range base-attribute refresh that
    /// PRESERVES the block-ID bookkeeping attribute (addAttributes never
    /// removes keys it doesn't name). A whole-document font swap is an
    /// ordinary storage write on a rare, deliberate gesture (voice switch)
    /// — distinct from the per-range RENDERING attributes TEXTKIT2 §3
    /// warns about; decorations stay overlays.
    ///
    /// **`previous` is the chrome this surface last applied** (18g ladder,
    /// the R1-1 fix's walk): with it, a colour-only change — a palette, a
    /// custom seed, the appearance — sets the view-level colours and
    /// re-derives the markdown face's colours on the face's OWN ranges
    /// (∝ the markdown spans), and never re-writes the whole storage's base
    /// attributes or the ink; the full re-font road runs only when
    /// `needsStorageRefresh(from:)` says the font or the paragraph style
    /// moved. Nil (the default, and the first application) is the full
    /// road, exactly as before.
    func applyVoiceChrome(_ chrome: EditorSurfaceChrome, previous: EditorSurfaceChrome? = nil) {
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
        // `textColor`'s setter writes the colour over the ENTIRE storage —
        // only when the ink actually moved (the voice or the appearance).
        if chrome.inkChanged(from: previous) { textColor = chrome.ink }
        insertionPointColor = chrome.caret
        chrome.spellcheck.apply(to: self)  // A24 — write-gated inside
        let refresh = chrome.needsStorageRefresh(from: previous)
        if refresh {
            // The view-level half of the re-font — set whether or not the
            // view holds a storage (the old contract, kept: the sanity
            // pass's below-raise note).
            font = EditorDocument.baseFont
            defaultParagraphStyle = EditorDocument.baseParagraphStyle
            typingAttributes = EditorDocument.baseAttributes
        }
        guard let storage = textStorage, storage.length > 0 else { return }
        if refresh {
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
        } else {
            // A colour-only change (18g ladder, the R1-1 walk): the markdown
            // face's link and marker colours live IN the storage, so they
            // re-derive from the new palette — LINE BY LINE, each faced line
            // its own edit. NOT the whole-document `style(storage)`: that
            // pass wraps every face in ONE begin/endEditing, and the storage
            // reports the UNION as the edited range — on a note whose faces
            // sit near both ends (the 262-block story's `_the_` italics) that
            // is the document, and TextKit 2 invalidates everything between,
            // which is the very viewport jump the base refresh caused. A
            // line-scoped edit invalidates its line; a note with no faces is
            // a zero-write.
            MarkdownStyling.restyleFacedLines(storage)
        }
    }
}
