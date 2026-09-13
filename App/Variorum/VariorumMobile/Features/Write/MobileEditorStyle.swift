//
//  MobileEditorStyle.swift
//  VariorumMobile
//
//  The phone's base attributes for the Write surface — the platform half
//  `EditorDocument.materializeCore` asks its caller for (the Mac's is
//  `EditorDocument.baseAttributes` in Features/Editor/EditorDocument.swift).
//
//  **Since S1 batch 3 this is the LOOK CANON's editor half** (L13 ruled at
//  the look sittings; LK2's both-voices switch): the VALUES resolve from
//  the shared `VoiceTokens` layer — the ONE canon both platforms carry
//  (Shared/Theme) — per the phone's OWN stored voice
//  (`MobileVoicePreference`). Feature code still never holds a literal
//  color (P-8): every UIColor here is a dynamic derivation of a token, and
//  DARK is the token layer's own dark values riding the system scheme
//  (R51's fully black rooms — pinned by `MobileVoiceTests`).
//
//  Concurrency: `voice` follows the Mac `MarkdownStyling.palette` pattern
//  exactly — written ONLY on the main thread (screen init + the switch
//  door; tests pin it explicitly), read by main-thread surface writes.
//  The per-voice faces are cached `static let`s so every read returns the
//  SAME color/font objects (attribute equality in tests, zero rebuild
//  cost per keystroke).
//
//  Typography values are the token layer's own (terminal mono 14 / study
//  Iowan Old Style 16 — the Mac `EditorTypography.resolve` numbers),
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
    // MARK: - The live voice

    /// The phone's live voice — LK2's preference, applied. Main-thread
    /// written (screen init, the switch door, tests), main-thread read.
    nonisolated(unsafe) private static var storedVoice: ThemeVoice = .terminal
    static var voice: ThemeVoice {
        get { storedVoice }
        set { storedVoice = newValue }
    }

    // MARK: - One voice's resolved editor face

    /// The UIKit face of one voice: what the TK2 surface, the markdown
    /// face, and the keyboard bar style with. Colors are DYNAMIC (light +
    /// dark resolve from the token layer per the current trait — R51's
    /// black rooms ride the system scheme with no re-render needed).
    struct Face {
        let body: UIFont
        /// Chrome type (the keyboard bar's act titles): mono in the
        /// terminal voice, the system sans in study — the mockups' own
        /// chrome rule (`.s .chrome` is sans even though study prose is
        /// serif).
        let chrome: UIFont
        let ink: UIColor
        let muted: UIColor
        let room: UIColor
        let surface: UIColor
        let line: UIColor
        let accent: UIColor
        /// Elevated cards — the peek pill's ground (S2: the LK6 pill).
        let card: UIColor
        /// The takes register's tint + line (R13's "takes read differently
        /// than prose") — the peek marker's wash and edge bar (S2). The
        /// ratified v1 mockup's `.peeked` values are exactly `takeTint`;
        /// its edge bar is `takeLine` in terminal and the seam in study —
        /// shipped as takeLine in BOTH voices (one token, the closest
        /// reading; a look-round line to change if she wants the study
        /// seam).
        let takeTint: UIColor
        let takeLine: UIColor
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
        /// codeTint (13k K10's per-voice tint).
        let palette: MarkdownFace.Palette

        init(voice: ThemeVoice) {
            func dynamic(_ key: KeyPath<VoiceTokens, Color>) -> UIColor {
                UIColor { traits in
                    UIColor(VoiceTokens.resolve(
                        voice: voice,
                        dark: traits.userInterfaceStyle == .dark)[keyPath: key])
                }
            }
            let metrics = UIFontMetrics(forTextStyle: .body)
            switch voice {
            case .terminal:
                body = metrics.scaledFont(
                    for: .monospacedSystemFont(ofSize: 14, weight: .regular))
                chrome = .monospacedSystemFont(ofSize: 14, weight: .regular)
            case .study:
                // Iowan Old Style ships on iOS (pinned by
                // `MobileVoiceTests`); the serif system design is the
                // never-reached safety net — the Mac resolver's exact
                // posture (R49: nothing bundled).
                let serif = UIFont(name: "IowanOldStyle-Roman", size: 16)
                    ?? UIFont(name: "Iowan Old Style", size: 16)
                    ?? UIFont(
                        descriptor: UIFont.systemFont(ofSize: 16).fontDescriptor
                            .withDesign(.serif)
                            ?? UIFont.systemFont(ofSize: 16).fontDescriptor,
                        size: 16)
                body = metrics.scaledFont(for: serif)
                chrome = .systemFont(ofSize: 14)
            }
            ink = dynamic(\.ink)
            muted = dynamic(\.muted)
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
    }

    /// Cached once per voice — object-stable colors/fonts (see header).
    static let terminalFace = Face(voice: .terminal)
    static let studyFace = Face(voice: .study)

    static var face: Face {
        switch voice {
        case .terminal: terminalFace
        case .study: studyFace
        }
    }

    /// P26/P43 (parity A3, her ruled flip — "the phone's menus
    /// VOICE-CASE … one register, hers"): every UIKit-rendered menu row
    /// and chrome door routes through THIS ONE helper (terminal
    /// lowercases its chrome; study keeps normal case) — the exact rule
    /// `VoiceTokens.chromeLabel` applies on the SwiftUI surfaces, so the
    /// two halves of the app cannot fork registers. Accessibility labels
    /// stay plain (VoiceOver reads words, not chrome styling).
    static func chromeCase(_ text: String) -> String {
        voice == .terminal ? text.lowercased() : text
    }

    // MARK: - The surface-write values (the pre-batch-3 names, kept)

    static var baseFont: UIFont { face.body }

    static var markdownPalette: MarkdownFace.Palette { face.palette }

    static var baseParagraphStyle: NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        // Uniform per-PARAGRAPH gap (the 2026-07-12 rule's letter —
        // intra-block newlines and seams alike, boundaries invisible at
        // rest). PHONE VALUE since the parity A3 spacing floor: the LK
        // canon's own block gap (mockup `.block margin-bottom:14px` =
        // 1.0 × the terminal point size; her finding "the spacing needs
        // to be fixed" — more air generally). The Mac keeps its
        // EditorTypography 0.5 × constant — this file is the phone's
        // look half, deliberately phone-local.
        style.paragraphSpacing = baseFont.pointSize.rounded()
        // Line air to the canon's prose line-height (~1.62 terminal /
        // ~1.6 study — one 0.4 × rule lands both voices' numbers over
        // the fonts' natural boxes).
        style.lineSpacing = (baseFont.pointSize * 0.4).rounded()
        return style
    }

    /// The base attributes EVERY mobile surface write uses —
    /// materialization and programmatic replaces. One source so no path
    /// can drop the paragraph style (the Mac's exact doctrine).
    static var baseAttributes: [NSAttributedString.Key: Any] {
        [
            .font: baseFont,
            .foregroundColor: face.ink,
            .paragraphStyle: baseParagraphStyle,
        ]
    }
}
