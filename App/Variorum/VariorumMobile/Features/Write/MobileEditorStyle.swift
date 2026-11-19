//
//  MobileEditorStyle.swift
//  VariorumMobile
//
//  The phone's base attributes for the Write surface — the platform half
//  `EditorDocument.materializeCore` asks its caller for (the Mac's is
//  `EditorDocument.baseAttributes` in Features/Editor/EditorDocument.swift).
//
//  **Since S1 batch 3 this is the LOOK CANON's editor half** (L13 ruled at
//  the look sittings): the VALUES resolve from the shared `VoiceTokens`
//  layer — the ONE canon both platforms carry (Shared/Theme). **Since VM-51
//  (the VM-47 run, batch 3 — her LK-1/LK-2) they are the LIBRARY's voice
//  and palette**, the synced settings the shell's theme store lands
//  (`MobileShellRouter`), no longer a phone-local preference (retired).
//  Feature code still never holds a literal color (P-8): every UIColor here
//  is a dynamic derivation of a token, and DARK is the token layer's own
//  dark values riding the system scheme — light or dark stays the device's
//  (R51's fully black rooms — pinned by `MobileVoiceTests`).
//
//  Concurrency (QUESTIONS #195 MINOR 3, closed at VM-51): the live look is
//  MAIN-ACTOR state — the compiler now enforces what the old comment only
//  claimed ("main-thread written, main-thread read") — and the app has ONE
//  writer, `adopt(_:)`, called where the library's settings LAND (the shell
//  router's theme seam). The two other writers (the Write screen's init and
//  the router's init) are gone. `voice`'s setter survives as the harness
//  door the suites drive one voice through. The per-voice faces are cached
//  `static let`s, and a palette face is built once per landed palette and
//  shares every voice-owned colour object with them, so every read returns
//  the SAME color/font objects (attribute equality in tests, zero rebuild
//  cost per keystroke).
//
//  Typography values are the phone layer's `noteBody` role (VM-48: study
//  Iowan Old Style 17 / terminal mono 15 — the sizing sheet's note body),
//  wrapped in `UIFontMetrics(.body)` so Dynamic Type scales them
//  (identity at the default content size, so byte/attribute tests stay
//  deterministic). PROVISIONAL sizes like everything visual: the mockup's
//  phone frames hint slightly larger — her on-device feel round rules.
//
//  The uniform paragraph gap keeps the 2026-07-12 rule (spacing after
//  EVERY paragraph — intra-block newlines and seams alike, so boundaries
//  stay invisible at rest) at the Mac's OWN constant since this batch:
//  0.5 × pointSize (EditorTypography's gap; batch 1's 0.35 stood in).
//  The dotted-seam toggle is deliberately ABSENT — unruled for mobile.
//

import SwiftUI
import UIKit
import VariorumCore

nonisolated enum MobileEditorStyle {
    // MARK: - The live look (the library's — VM-51)

    /// The library's look as the editor wears it — voice, palette and the
    /// custom seeds — the last value `adopt(_:)` took (before any library has
    /// landed: R1's placeholder, Terminal in the voice's own colours, which is
    /// what the suites' editor worlds assume). MAIN-ACTOR state (MINOR 3).
    @MainActor private static var stored = Queries.ThemeSettings()
    /// The face `stored` names, rebuilt only when the look moves.
    @MainActor private static var current: Face = terminalFace

    /// The library's settings the editor wears now.
    @MainActor static var settings: Queries.ThemeSettings { stored }

    /// The live voice. Its SETTER is the harness door (the suites drive one
    /// voice through it, the palette left as it stands); the app writes only
    /// through `adopt(_:)`.
    @MainActor static var voice: ThemeVoice {
        get { stored.voice }
        set {
            stored.voice = newValue
            current = makeFace(stored)
        }
    }

    /// **THE ONE APP WRITER** (VM-51): the library's landed settings, adopted
    /// where they land (`MobileShellRouter`'s theme seam). Answers whether the
    /// FACE moved — the voice, the palette or the custom seeds — so the caller
    /// restyles the open editors only when there is something to restyle.
    @MainActor
    @discardableResult
    static func adopt(_ settings: Queries.ThemeSettings) -> Bool {
        let moved = settings.voice != stored.voice
            || settings.palette != stored.palette
            || PaletteTint(settings) != PaletteTint(stored)
        stored = settings
        if moved { current = makeFace(settings) }
        return moved
    }

    /// The voice's own face, with the palette laid over the slots a palette
    /// replaces; a settings value that names no palette (`.default`, or a
    /// `custom` with no valid seed) is the voice's static face itself.
    @MainActor
    private static func makeFace(_ settings: Queries.ThemeSettings) -> Face {
        let voiceFace = settings.voice == .terminal ? terminalFace : studyFace
        return voiceFace.applying(palette: settings.palette, tint: PaletteTint(settings))
    }

    // MARK: - One voice's resolved editor face

    /// The UIKit face of one voice: what the TK2 surface, the markdown
    /// face, and the keyboard bar style with. Colors are DYNAMIC (light +
    /// dark resolve from the token layer per the current trait — R51's
    /// black rooms ride the system scheme with no re-render needed).
    struct Face {
        /// Which voice this face is (VM-48: its type roles resolve from it).
        let voice: ThemeVoice
        let body: UIFont
        /// Chrome type (the keyboard bar's act titles): mono in the
        /// terminal voice, the system sans in study — the mockups' own
        /// chrome rule (`.s .chrome` is sans even though study prose is
        /// serif).
        let chrome: UIFont
        let ink: UIColor
        let muted: UIColor
        /// The VOICE's own room — a palette never replaces it here
        /// (`applying(palette:tint:)` carries it through). Since the VM-47
        /// run's piece 3.10 it is no longer the editor's ground (that is
        /// `paper`, below); no editor view reads it.
        let room: UIColor
        // The six colours below — with the markdown palette's `link` — are
        // the ones a palette replaces (`applying(palette:tint:)`; in light the
        // resolver keeps the voice's own paper and card, as
        // `VoiceTokens.applying` does). Everything else in a face is the voice's.
        /// The paper: `tokens.surface` as the settings road resolves it — the
        /// voice's own paper in light, the palette's hued paper in dark (R51's
        /// room stays black). The overlays' sheets and the keyboard bar read it.
        private(set) var surface: UIColor
        private(set) var line: UIColor
        private(set) var accent: UIColor
        /// Elevated cards — the peek pill's ground (S2: the LK6 pill).
        private(set) var card: UIColor
        /// The takes register's tint + line (R13's "takes read differently
        /// than prose") — the peek marker's wash and edge bar (S2). The
        /// ratified v1 mockup's `.peeked` values are exactly `takeTint`;
        /// its edge bar is `takeLine` in terminal and the seam in study —
        /// shipped as takeLine in BOTH voices (one token, the closest
        /// reading; a look-round line to change if she wants the study
        /// seam).
        private(set) var takeTint: UIColor
        private(set) var takeLine: UIColor
        /// The chosen take's mark — the pill's ✓ (the Mac card grammar's
        /// "✓ chosen" color).
        let chosenMark: UIColor
        /// Comment ink (R7's register) — the ●n marker's color (S4).
        let commentInk: UIColor
        /// The one named alarm per voice (`VoiceTokens.alarm`) — a refusal
        /// reads as a refusal in the app's own colours, never a literal red
        /// (P-8). Added at mobile round 2 batch 6a, when the Block History
        /// face gained a status line that can carry either kind.
        let alarm: UIColor
        /// The markdown face's palette — the Mac `Palette(tokens:)`
        /// mapping verbatim: marker = muted, link = accent, chip =
        /// codeTint (13k K10's per-voice tint). Under a palette only its
        /// `link` (the accent) changes.
        private(set) var palette: MarkdownFace.Palette

        /// The VOICE's own face — its shipped colours, the base a palette is
        /// laid over (`applying(palette:tint:)`), exactly as the four-parameter
        /// resolver lays a palette over the voice's static set. The palette-less
        /// read below is that base, by definition.
        init(voice: ThemeVoice) {
            self.voice = voice
            func dynamic(_ key: KeyPath<VoiceTokens, Color>) -> UIColor {
                UIColor { traits in
                    UIColor(VoiceTokens.resolve(
                        voice: voice,
                        dark: traits.userInterfaceStyle == .dark)[keyPath: key])
                }
            }
            let metrics = UIFontMetrics(forTextStyle: .body)
            // VM-48: the note body is the phone layer's `noteBody` role —
            // Study Iowan 17, Terminal SF Mono 15 (two under) — still
            // through `UIFontMetrics(.body)`, so it scales across the whole
            // range and is exact at the default size.
            let size = PhoneType.spec(.noteBody, voice: voice).size
            switch voice {
            case .terminal:
                body = metrics.scaledFont(
                    for: .monospacedSystemFont(ofSize: size, weight: .regular))
                chrome = .monospacedSystemFont(ofSize: 14, weight: .regular)
            case .study:
                // Iowan Old Style ships on iOS (pinned by
                // `MobileVoiceTests`); the serif system design is the
                // never-reached safety net — the Mac resolver's exact
                // posture (R49: nothing bundled).
                let serif = UIFont(name: "IowanOldStyle-Roman", size: size)
                    ?? UIFont(name: "Iowan Old Style", size: size)
                    ?? UIFont(
                        descriptor: UIFont.systemFont(ofSize: size).fontDescriptor
                            .withDesign(.serif)
                            ?? UIFont.systemFont(ofSize: size).fontDescriptor,
                        size: size)
                body = metrics.scaledFont(for: serif)
                chrome = .systemFont(ofSize: 14)
            }
            ink = dynamic(\.ink)
            // VM-48: the phone layer's corrected muted (sheet §D) — the
            // voice's own hue, darker, clearing 4.5:1 on every shipped
            // ground. The markdown marker below keeps the voice's own muted
            // (the editor's markdown face is VM-137's).
            muted = PhoneInks.uiColor(.muted, voice: voice)
            room = dynamic(\.room)
            surface = dynamic(\.surface)
            line = dynamic(\.line)
            accent = dynamic(\.accent)
            card = dynamic(\.card)
            takeTint = dynamic(\.takeTint)
            takeLine = dynamic(\.takeLine)
            chosenMark = dynamic(\.chosen)
            commentInk = dynamic(\.commentInk)
            alarm = dynamic(\.alarm)
            palette = MarkdownFace.Palette(
                marker: dynamic(\.muted),
                link: dynamic(\.accent),
                codeTint: dynamic(\.codeTint),
                // 18j (the 18g ladder's R2-1): the prose ink a cleared face
                // returns to. Dynamic like every colour here, so it is right
                // in both appearances with no storage write at all — which
                // is why the phone never showed this defect.
                prose: dynamic(\.ink))
        }

        /// **The editor's ground — the paper** (the VM-47 run, piece 3.10; her
        /// R-47-1, "prose should not be on the tint", whose test is the paper
        /// wherever her words are written). The Mac's editor reads exactly this
        /// (`EditorSurfaceChrome.paper` = `NSColor(tokens.surface)`, its scroll
        /// view's background); its one reader here is the text view's
        /// background (`MobileEditorTextView.applyVoiceChrome`). The same
        /// object as `surface`, so a palette's landing moves it with the rest.
        var paper: UIColor { surface }

        /// VM-48: the phone layer's UIKit type — a role in this face's voice
        /// (`PhoneType.uiFont`: scaled with the text size, chrome held at
        /// xxxLarge). The UIKit chrome reads its type through here.
        @MainActor
        func font(_ role: PhoneTypeRole) -> UIFont {
            PhoneType.uiFont(role, voice: voice)
        }

        /// **This voice's face under a palette** (VM-51): the seven palette
        /// slots re-derived through the ONE palette-aware resolver
        /// (`VoiceTokens.resolve(voice:palette:tint:dark:)` — the four-parameter
        /// road the settings road calls), resolved for both appearances once,
        /// here, so the colours stay dynamic (light or dark rides the device)
        /// and are built once per landed palette, never per read. Every other
        /// slot — the type, the inks, the chosen mark, the comment ink, the
        /// alarm, the markdown marker, chip and prose ink, the room — is THIS
        /// face's own object, carried through untouched. A palette that
        /// names nothing returns this face itself (the byte-identical road).
        @MainActor
        func applying(palette: ThemePalette, tint: PaletteTint) -> Face {
            guard PalettePreset.resolved(palette, tint: tint) != nil else { return self }
            let light = VoiceTokens.resolve(voice: voice, palette: palette, tint: tint, dark: false)
            let dark = VoiceTokens.resolve(voice: voice, palette: palette, tint: tint, dark: true)
            func dynamic(_ key: KeyPath<VoiceTokens, Color>) -> UIColor {
                Face.pair(light: UIColor(light[keyPath: key]), dark: UIColor(dark[keyPath: key]))
            }
            var face = self
            face.surface = dynamic(\.surface)
            face.line = dynamic(\.line)
            face.accent = dynamic(\.accent)
            face.card = dynamic(\.card)
            face.takeTint = dynamic(\.takeTint)
            face.takeLine = dynamic(\.takeLine)
            face.palette = MarkdownFace.Palette(
                marker: self.palette.marker, link: face.accent,
                codeTint: self.palette.codeTint, prose: self.palette.prose)
            return face
        }

        /// A dynamic colour from its two resolved values, built OFF the main
        /// actor's isolation so UIKit may resolve it from any thread (the
        /// `PhoneInks.dynamic` shape — no actor-isolated call inside).
        nonisolated private static func pair(light: UIColor, dark: UIColor) -> UIColor {
            UIColor { traits in traits.userInterfaceStyle == .dark ? dark : light }
        }
    }

    /// Cached once per voice — object-stable colors/fonts (see header). The
    /// voice's own colours (no palette): the faces a palette is laid over.
    static let terminalFace = Face(voice: .terminal)
    static let studyFace = Face(voice: .study)

    /// The face the editor wears now — the library's voice under its
    /// palette (`adopt(_:)`).
    @MainActor static var face: Face { current }

    /// P26/P43 (parity A3, her ruled flip — "the phone's menus
    /// VOICE-CASE … one register, hers"): every UIKit-rendered menu row
    /// and chrome door routes through THIS ONE helper (terminal
    /// lowercases its chrome; study keeps normal case) — the exact rule
    /// `VoiceTokens.chromeLabel` applies on the SwiftUI surfaces, so the
    /// two halves of the app cannot fork registers. Accessibility labels
    /// stay plain (VoiceOver reads words, not chrome styling).
    @MainActor
    static func chromeCase(_ text: String) -> String {
        voice == .terminal ? text.lowercased() : text
    }

    // MARK: - The surface-write values (the pre-batch-3 names, kept)

    @MainActor static var baseFont: UIFont { face.body }

    @MainActor static var markdownPalette: MarkdownFace.Palette { face.palette }

    /// The note body's paragraph gap at the default text size — the sizing
    /// sheet's 14 for Study, and Terminal's two under (VM-48).
    static func paragraphGap(_ voice: ThemeVoice) -> CGFloat {
        voice == .study ? 14 : 12
    }

    @MainActor static var baseParagraphStyle: NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        let note = PhoneType.spec(.noteBody, voice: voice)
        // The body's scale against its default size (1 at Large): the gap
        // and the line pitch take the body's size AT LAUNCH (the faces are
        // resolved once per process). A mid-run text-size change re-scales
        // the drawn body through the text view, not this gap — VM-137, the
        // editor's text-size road (the VM-47 midway review's m-1).
        let scale = baseFont.pointSize / note.size
        // Uniform per-PARAGRAPH gap (the 2026-07-12 rule's letter —
        // intra-block newlines and seams alike, boundaries invisible at
        // rest). PHONE VALUE: the sizing sheet's note body (VM-48 — "Iowan
        // 17 · line 27 · gutter 20 · paragraph gap 14"; Terminal two
        // under). The Mac keeps its EditorTypography 0.5 × constant — this
        // file is the phone's look half, deliberately phone-local.
        style.paragraphSpacing = (paragraphGap(voice) * scale).rounded()
        // Line air to the role's line pitch (Study 27, Terminal 25) over the
        // font's own line box.
        style.lineSpacing = max(0, (note.lineHeight * scale - baseFont.lineHeight).rounded())
        return style
    }

    /// The base attributes EVERY mobile surface write uses —
    /// materialization and programmatic replaces. One source so no path
    /// can drop the paragraph style (the Mac's exact doctrine).
    @MainActor static var baseAttributes: [NSAttributedString.Key: Any] {
        [
            .font: baseFont,
            .foregroundColor: face.ink,
            .paragraphStyle: baseParagraphStyle,
        ]
    }
}
