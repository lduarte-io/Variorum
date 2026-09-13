//
//  VoiceTokens.swift
//  Variorum
//
//  Phase 13, B1 — the token/voice layer (R1: TWO first-class voices,
//  tokens AND idioms, never a palette swap; R12: hold at exactly two).
//  The TERMINAL voice leads (anchor: Spikes/Phase13Mockups/direction-b +
//  round-2); the STUDY voice is the Phase 11 mockups' look (anchor:
//  Spikes/Phase11Mockups/mockups.html + mockups-v2.html). Dark mode is a
//  FULLY BLACK background in both voices (R51 — supersedes the early grey).
//  Fonts are all macOS system-shipped (R49): SF Mono for the terminal
//  voice, Iowan Old Style/New York for the study voice — nothing bundled,
//  nothing licensed.
//

import SwiftUI
import VariorumCore

/// One voice's resolved design tokens + idiom slots. Everything a Stage
/// B/C surface styles with comes through here — feature code never holds
/// a literal color (the one-module rule for the design layer).
///
/// **THE EIGHT `var`s ARE THE PALETTE'S SLOTS** (18g — her R-Q6/R-Q11/R-Q13).
/// A palette layered under a voice replaces exactly `room`, `surface`,
/// `card`, `accent`, `line`, `wash`, `takeTint` and `takeLine` — and nothing
/// else, which is why they and only they are settable (`applying(_:)` below
/// is the one writer). Everything else is `let` because it is what makes a
/// voice a voice: its type, its idioms, and the slots the ruling does not
/// name (`ink`/`muted`/`faint`, `chosen`, `ring`, `star`, `alarm`,
/// `positive`, the comment pair, the code chip, the block seam).
struct VoiceTokens: Equatable {
    // MARK: Surfaces
    /// The room — the window/sidebar background. (Her "tan panels".)
    var room: Color
    /// The paper — content panes, cards, rows. A palette replaces it in
    /// DARK only: there the room is black (R51), so the paper carries the
    /// hue. In light the voice keeps its own paper, as the mockup shows.
    var surface: Color
    /// Elevated cards (takes, palette rows). The paper's sibling — a
    /// palette replaces it under the same dark-only rule.
    var card: Color

    // MARK: Ink
    let ink: Color
    let muted: Color
    let faint: Color
    /// The coloured chrome words — her *"lightly colored text like (this
    /// note) and commit"*. A palette's accent.
    var accent: Color
    /// **THE ERROR/DANGER SLOT** (the post-13l polish round, ledger row 29 —
    /// her mid-round ruling: *"Add it this round"*).
    ///
    /// One named alarm per voice, so a refusal is a refusal in the app's own
    /// register rather than the system red. It exists because the round kept
    /// meeting the same two shapes of the same defect: a literal
    /// `.foregroundStyle(.red)` in a themed surface (the tray's status slot,
    /// the origin peek's, and ~30 error lines across both platforms), and —
    /// where a surface DID reach for a token — `accent`, the app's own
    /// positive colour, standing in for alarm because there was nothing else
    /// (batch 1 shipped exactly that as a recorded PROVISIONAL).
    ///
    /// Deliberately QUIET rather than a stoplight: this is a calm-default
    /// writing app, and the sentence carries the alarm — the colour only has
    /// to say "this one is different". **The hues are placeholders revisable
    /// at 13s's design review** (her ruling), and 13u's dark mode inherits
    /// the slot by construction.
    let alarm: Color
    /// **THE QUIET POSITIVE SLOT** (ledger row 31 — her words on the sync
    /// line: *"a gentle green on fully synced might look nice"*).
    ///
    /// A slot of its OWN, saying *nothing is outstanding* — a state, not an
    /// emphasis. Gentle in both voices on purpose: a settled state should be
    /// readable at a glance and forgettable the moment after (her #75(d)
    /// ratification: signed-out stays quiet, so only THIS state wears it).
    ///
    /// **Where it currently RESOLVES, said plainly for ALL FOUR VOICES** (the
    /// ladder's LR1-9 caught this doc claiming a distinctness the leading
    /// voice does not have; LR2-2 caught the correction stopping one voice
    /// short): **`positive` equals `chosen` in every voice today** — Terminal
    /// light and dark, Study light and dark all wear the "✓ chosen" green on
    /// the settled line. Where the voices differ is `accent`: Terminal's is
    /// that SAME green (it has ONE green on purpose — a second beside it would
    /// read as a different signal rather than a gentler one), while Study's is
    /// blue, so there the slot is at least visibly not the emphasis colour.
    ///
    /// The slot exists so the three can move independently WITHOUT a sweep:
    /// hues are placeholders revisable at 13s's design review (her ruling on
    /// `alarm`, and it governs this one too), and 13u's dark mode inherits
    /// them by construction. **PROVISIONAL:** whether a settled sync line
    /// should wear a hue apart from "✓ chosen" — in ANY voice — is a taste
    /// call, hers.
    let positive: Color

    // MARK: Lines & marks
    /// Hairline separators. A palette's hairline.
    var line: Color
    /// The dotted block seam (R6 — THE boundary mechanism). Deliberately
    /// NOT a palette slot: the seam is the boundary MECHANISM, and her
    /// ruling names the hairline, not it.
    let seam: Color
    /// Selected rows / the changing-block wash (R13). A palette's wash.
    var wash: Color
    /// The takes register's tint (takes read differently than prose — R13).
    /// A palette's take tint…
    var takeTint: Color
    /// …and its line.
    var takeLine: Color
    /// The chosen take's mark.
    let chosen: Color
    /// The editing ring (R6/R22 — the outline form).
    let ring: Color
    /// **The star (pre-13u Act 10, item 13 — her call: "i like the blue
    /// star").** A slot of its own so the star is BLUE in every voice (the
    /// mockup's sidebar draws it so, W8-2): Terminal reuses its blue ring
    /// hue, Study its blue accent — neither could serve directly (Terminal's
    /// accent is green, Study's ring is orange). Hues are placeholders
    /// revisable at 13s, like `alarm`'s.
    let star: Color
    /// Comment surfaces (R7).
    let commentTint: Color
    let commentInk: Color
    /// **13k K10 — the inline-code chip.** Her ruling (sitting round 2, Q2):
    /// a faint per-voice TINTED CHIP hugging exactly the `` `code` `` span,
    /// never block-wide — the geometry is what keeps it visibly distinct
    /// from a callout frame, and the colour is deliberately NEUTRAL to the
    /// voice's own room rather than a member of the callout palette's five
    /// pastels. (It also fixes a batch-2 look finding: in the TERMINAL voice
    /// the prose is already monospaced, so before this only the dimmed
    /// backticks distinguished code at all.)
    let codeTint: Color

    // MARK: Type
    let body: Font
    let title: Font
    let heading: Font
    let small: Font
    let mono: Font
    /// **The sidebar's row register** (the Act 10 correction round, batch A —
    /// rows 2/3): the 13 pt line the List's sidebar rows always had, in the
    /// voice's own chrome family — monospaced in Terminal, the system face in
    /// Study. One slot so the areas, the "this note" rail, the Starred rows
    /// and the Open strip's rows read at ONE size instead of three (13 mono ·
    /// 13 sans · 11.5 small, which is what the column had grown into).
    let navigation: Font

    // MARK: Idiom slots (R1 — "the special little ways")
    /// The selected-row marker ("› " in terminal; none in study).
    let selectionMarker: String
    /// Path grammar: "~/shelf" vs "Shelf"; "orbit / II / post" vs "Orbit · II".
    let pathPrefix: String
    let pathSeparator: String
    /// The comment line's prefix glyph ("# " vs "").
    let commentPrefix: String
    /// The quick-entry bar's blinking block cursor (terminal's).
    let showsBlockCursor: Bool
    /// Terminal lowercases its chrome labels ("shelf", "6 books").
    let lowercasesChrome: Bool

    /// Path line for navigation chrome ("~/shelf" / "Shelf").
    func path(_ components: [String]) -> String {
        let joined = components
            .map { lowercasesChrome ? $0.lowercased() : $0 }
            .joined(separator: pathSeparator)
        return pathPrefix + joined
    }

    func chromeLabel(_ text: String) -> String {
        lowercasesChrome ? text.lowercased() : text
    }
}

extension VoiceTokens {
    /// **The resolver: voice + palette + light/dark → tokens** (18g — her
    /// R-Q6: *"a palette layered on a VOICE"*).
    ///
    /// `.default` returns the voice's shipped set BYTE-IDENTICALLY — not
    /// "the same numbers computed another way", literally the same static
    /// value, because `PalettePreset.resolved` hands back nil for it and
    /// this function returns `base` untouched. That is the parity proof the
    /// token pins ride, and it is also why a `custom` palette with no valid
    /// seed is safe: it takes the same road.
    ///
    /// Dark is FULLY BLACK in both voices and under every palette (R51) —
    /// pinned here for the voices and in `PaletteDerivationTests` for the
    /// families.
    static func resolve(
        voice: ThemeVoice, palette: ThemePalette, tint: PaletteTint, dark: Bool
    ) -> VoiceTokens {
        let base = resolve(voice: voice, dark: dark)
        guard let preset = PalettePreset.resolved(palette, tint: tint) else { return base }
        return base.applying(PaletteDerivation.derive(preset, dark: dark))
    }

    /// The shipped two-parameter resolver, unchanged in behaviour and
    /// signature — every existing call site (67 of them, and the phone's
    /// `MobileEditorStyle`) compiles and behaves exactly as before.
    static func resolve(voice: ThemeVoice, dark: Bool) -> VoiceTokens {
        switch (voice, dark) {
        case (.terminal, false): return .terminalLight
        case (.terminal, true): return .terminalDark
        case (.study, false): return .studyLight
        case (.study, true): return .studyDark
        }
    }

    /// The ONE writer of the palette's eight slots. Everything else is the
    /// voice's and is copied through untouched; `surface`/`card` are
    /// replaced only where the family names them (dark).
    private func applying(_ family: PaletteFamily) -> VoiceTokens {
        var tokens = self
        tokens.room = Color(hex: family.room)
        if let surface = family.surface { tokens.surface = Color(hex: surface) }
        if let card = family.card { tokens.card = Color(hex: card) }
        tokens.accent = Color(hex: family.accent)
        tokens.wash = Color(hex: family.wash)
        tokens.takeTint = Color(hex: family.takeTint)
        tokens.takeLine = Color(hex: family.takeLine)
        tokens.line = Color(hex: family.line)
        return tokens
    }

    /// The environment-missing fallback (test hosts, future embeddings):
    /// the leading voice at the ambient scheme. One name so the per-view
    /// boilerplate reads as one idea (round 2 NIT).
    static func fallback(for scheme: ColorScheme) -> VoiceTokens {
        resolve(voice: .terminal, dark: scheme == .dark)
    }

    // MARK: - Terminal (direction B / round 2)

    static let terminalLight = VoiceTokens(
        room: Color(hex: 0xF6F6F1),
        surface: Color(hex: 0xFBFBF7),
        card: Color(hex: 0xFDFDFA),
        ink: Color(hex: 0x23272B),
        muted: Color(hex: 0x8B9088),
        faint: Color(hex: 0xB3B6AE),
        accent: Color(hex: 0x2F7D5F),
        alarm: Color(hex: 0xA33A2E),
        positive: Color(hex: 0x2F7D5F),
        line: Color(hex: 0xE4E4DC),
        seam: Color(hex: 0xCFCFC5),
        wash: Color(hex: 0xEEF0EA),
        takeTint: Color(hex: 0xF2F4EE),
        takeLine: Color(hex: 0xD6DCD0),
        chosen: Color(hex: 0x2F7D5F),
        ring: Color(hex: 0x3F7FD6),
        star: Color(hex: 0x3F7FD6),
        commentTint: Color(hex: 0xF6F3E2),
        commentInk: Color(hex: 0x7A6F45),
        codeTint: Color(hex: 0xE9EBE2),
        body: .system(size: 14, design: .monospaced),
        title: .system(size: 19, weight: .semibold, design: .monospaced),
        heading: .system(size: 15, weight: .semibold, design: .monospaced),
        small: .system(size: 11.5, design: .monospaced),
        mono: .system(size: 13, design: .monospaced),
        navigation: .system(size: 13, design: .monospaced),
        selectionMarker: "› ",
        pathPrefix: "~/",
        pathSeparator: "/",
        commentPrefix: "// ",
        showsBlockCursor: true,
        lowercasesChrome: true)

    /// Terminal dark: direction B's register on a FULLY BLACK room (R51).
    static let terminalDark = VoiceTokens(
        room: .black,
        surface: Color(hex: 0x0C0D0C),
        card: Color(hex: 0x161816),
        ink: Color(hex: 0xD6DAD2),
        muted: Color(hex: 0x8B9088),
        faint: Color(hex: 0x5B6058),
        accent: Color(hex: 0x6FBF94),
        alarm: Color(hex: 0xE08A7C),
        positive: Color(hex: 0x6FBF94),
        line: Color(hex: 0x242624),
        seam: Color(hex: 0x4A4D4A),
        wash: Color(hex: 0x1A211C),
        takeTint: Color(hex: 0x161A17),
        takeLine: Color(hex: 0x2C312C),
        chosen: Color(hex: 0x6FBF94),
        ring: Color(hex: 0x5B93DE),
        star: Color(hex: 0x5B93DE),
        commentTint: Color(hex: 0x1C1910),
        commentInk: Color(hex: 0xB3A25F),
        codeTint: Color(hex: 0x1E211E),
        body: .system(size: 14, design: .monospaced),
        title: .system(size: 19, weight: .semibold, design: .monospaced),
        heading: .system(size: 15, weight: .semibold, design: .monospaced),
        small: .system(size: 11.5, design: .monospaced),
        mono: .system(size: 13, design: .monospaced),
        navigation: .system(size: 13, design: .monospaced),
        selectionMarker: "› ",
        pathPrefix: "~/",
        pathSeparator: "/",
        commentPrefix: "// ",
        showsBlockCursor: true,
        lowercasesChrome: true)

    // MARK: - Study (the Phase 11 mockups' look — HER favorite look, R1)

    static let studyLight = VoiceTokens(
        room: Color(hex: 0xFAF8F3),
        surface: Color(hex: 0xFFFFFF),
        card: Color(hex: 0xFFFFFF),
        ink: Color(hex: 0x29241C),
        muted: Color(hex: 0x8D8578),
        faint: Color(hex: 0xB5AD9E),
        accent: Color(hex: 0x3D6B8E),
        alarm: Color(hex: 0x9B3B2F),
        positive: Color(hex: 0x5A7D46),
        line: Color(hex: 0xE4DDD0),
        seam: Color(hex: 0xC9B998),
        wash: Color(hex: 0x3D6B8E).opacity(0.12),
        takeTint: Color(hex: 0xF4F2EC),
        takeLine: Color(hex: 0xE4DDD0),
        chosen: Color(hex: 0x5A7D46),
        ring: Color(hex: 0xB0713A),
        star: Color(hex: 0x3D6B8E),
        commentTint: Color(hex: 0xFBF5E2),
        commentInk: Color(hex: 0x6D5F3E),
        codeTint: Color(hex: 0xF2EDE1),
        body: .custom("Iowan Old Style", size: 16, relativeTo: .body),
        title: .custom("Iowan Old Style", size: 21, relativeTo: .title2).weight(.semibold),
        heading: .custom("Iowan Old Style", size: 16, relativeTo: .headline).weight(.semibold),
        small: .system(size: 11.5),
        mono: .system(size: 12.5, design: .monospaced),
        navigation: .system(size: 13),
        selectionMarker: "",
        pathPrefix: "",
        pathSeparator: " · ",
        commentPrefix: "",
        showsBlockCursor: false,
        lowercasesChrome: false)

    /// Study dark: the v2 mockup's dark register on a FULLY BLACK room (R51
    /// — her direct edit removed the grey).
    static let studyDark = VoiceTokens(
        room: .black,
        surface: Color(hex: 0x14120F),
        card: Color(hex: 0x1C1915),
        ink: Color(hex: 0xE8E3D8),
        muted: Color(hex: 0x948C7C),
        faint: Color(hex: 0x6B6456),
        accent: Color(hex: 0x82ABCC),
        alarm: Color(hex: 0xD98A78),
        positive: Color(hex: 0x93B57E),
        line: Color(hex: 0x2C2822),
        seam: Color(hex: 0x57544A),
        wash: Color(hex: 0x82ABCC).opacity(0.13),
        takeTint: Color(hex: 0x1B1E19),
        takeLine: Color(hex: 0x38342C),
        chosen: Color(hex: 0x93B57E),
        ring: Color(hex: 0xD29A64),
        star: Color(hex: 0x82ABCC),
        commentTint: Color(hex: 0x201C12),
        commentInk: Color(hex: 0xB3A25F),
        codeTint: Color(hex: 0x241F18),
        body: .custom("Iowan Old Style", size: 16, relativeTo: .body),
        title: .custom("Iowan Old Style", size: 21, relativeTo: .title2).weight(.semibold),
        heading: .custom("Iowan Old Style", size: 16, relativeTo: .headline).weight(.semibold),
        small: .system(size: 11.5),
        mono: .system(size: 12.5, design: .monospaced),
        navigation: .system(size: 13),
        selectionMarker: "",
        pathPrefix: "",
        pathSeparator: " · ",
        commentPrefix: "",
        showsBlockCursor: false,
        lowercasesChrome: false)
}

/// Direction C's reading page (R2 — a VIEW MODE, not a theme: "the calm
/// page for reading or quiet editing, reachable from any book in either
/// voice"). Its paper/serif identity is deliberately voice-independent;
/// only the ROOM around the page follows the voice (and dark is black).
struct ReadingPageTokens {
    let paper: Color
    let ink: Color
    let chapterInk: Color
    let pageMeta: Color
    /// 13k K10: the reading page's inline-code chip. The page's identity is
    /// deliberately VOICE-INDEPENDENT (R2 — only the room around it follows
    /// the voice), so its chip is the paper's own warm neutral rather than
    /// either voice's.
    let codeTint: Color
    let serif: Font
    let serifTitle: Font

    static let light = ReadingPageTokens(
        paper: Color(hex: 0xFFFDF6),
        ink: Color(hex: 0x2A2620),
        chapterInk: Color(hex: 0xA49681),
        pageMeta: Color(hex: 0xC2BCB0),
        codeTint: Color(hex: 0xF3EEE0),
        serif: .system(size: 16, design: .serif),
        serifTitle: .system(size: 25, weight: .semibold, design: .serif))

    static let dark = ReadingPageTokens(
        paper: Color(hex: 0x171511),
        ink: Color(hex: 0xE3DCD0),
        chapterInk: Color(hex: 0x8D8371),
        pageMeta: Color(hex: 0x6B6456),
        codeTint: Color(hex: 0x241F18),
        serif: .system(size: 16, design: .serif),
        serifTitle: .system(size: 25, weight: .semibold, design: .serif))
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1)
    }
}
