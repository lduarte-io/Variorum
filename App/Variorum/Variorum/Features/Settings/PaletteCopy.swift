//
//  PaletteCopy.swift
//  Variorum (Mac)
//
//  18g — the words of THE COLOUR PALETTE (her rulings R-Q6 · R-Q11 ·
//  R-Q13, from the 2026-09-12 report: *"I need basic color themes that also
//  update the lightly colored text like (this note) and commit. I want at
//  least lavender, mint green, pink, blue, a pastel set. and maybe the
//  ability to choose the hex code of your default theme (should recolor the
//  tan panels basically) and the text that is going on top of those
//  panels."*).
//
//  **The help copy's job is to not overclaim** — the `ReceiptStyleCopy` /
//  `SavepointCadenceCopy` bar. A palette changes COLOURS and nothing else:
//  saying so is what keeps "palette" from reading as "a third voice", which
//  is the one thing R1/R12 forbid.
//

import Foundation
import VariorumCore

nonisolated enum PaletteCopy {
    static let title = "Colour palette"

    /// The three batches she ruled, plus the two that are not builds: the
    /// shipped default and her own hex. The GROUPING is presentation — the
    /// brain knows seeds and intensity, not headings — so it lives here,
    /// and a pin asserts it covers every case exactly once.
    enum Group: String, CaseIterable {
        case shipped
        case pastels
        case twoTone
        case bold
        case own

        var title: String {
            switch self {
            case .shipped: return "Default"
            case .pastels: return "Pastels"
            case .twoTone: return "Two-tone"
            case .bold: return "Bold"
            case .own: return "Your own"
            }
        }

        var palettes: [ThemePalette] {
            switch self {
            case .shipped: return [.default]
            case .pastels: return [.lavender, .mint, .pink, .blue]
            case .twoTone:
                return [.goldAndBlack, .sageAndTerracotta, .slateAndAmber,
                        .plumAndCream, .inkAndCoral, .greyAndGreen]
            case .bold:
                return [.cobaltAndTangerine, .peachAndIndigo, .butterAndCobalt,
                        .roseAndMoss, .tealAndRust]
            case .own: return [.custom]
            }
        }
    }

    static func label(_ palette: ThemePalette) -> String {
        switch palette {
        case .default: return "Default"
        case .lavender: return "Lavender"
        case .mint: return "Mint"
        case .pink: return "Pink"
        case .blue: return "Blue"
        case .goldAndBlack: return "Gold & black"
        case .sageAndTerracotta: return "Sage & terracotta"
        case .slateAndAmber: return "Slate & amber"
        case .plumAndCream: return "Plum & cream"
        case .inkAndCoral: return "Ink & coral"
        case .greyAndGreen: return "Grey & green"
        case .cobaltAndTangerine: return "Cobalt & tangerine"
        case .peachAndIndigo: return "Peach & indigo"
        case .butterAndCobalt: return "Butter & cobalt"
        case .roseAndMoss: return "Rose & moss"
        case .tealAndRust: return "Teal & rust"
        case .custom: return "Custom"
        }
    }

    static let help =
        "A palette recolours the panels, the selected-row wash, the coloured chrome "
        + "words (\u{201C}this note\u{201D}, \u{201C}commit \u{2318}S\u{201D}), the take "
        + "cards and the hairlines. Everything else stays the voice's \u{2014} its type, "
        + "its marks and its habits \u{2014} and dark mode stays fully black whichever "
        + "you pick."

    /// The sentence the setting must never leave out: a palette is not a
    /// voice, and nothing about the voice moves when one is chosen.
    static let notAVoiceNote =
        "Two voices, many palettes: the palette is only colour, so Terminal stays "
        + "Terminal and Study stays Study under every one of them."

    // MARK: Her own hex (R-Q13)

    static let roomFieldLabel = "Your colour"
    static let accentFieldLabel = "Accent, optional"
    static let hexPrompt = "B9A7E6"

    static let customHelp =
        "Six hex digits \u{2014} with or without the #. Variorum derives the rest: the "
        + "panels, the wash, the take tints, the hairlines, and an accent deep enough "
        + "to read on them. Type a second colour if you want the chrome words in a "
        + "different hue; leave it empty and they take your colour, deepened."

    static let needsASeedNote =
        "Type a colour above to see it \u{2014} until then this looks like the default."

    /// The receipt-shaped line the pane shows after a colour lands. Not a
    /// `StatusCenter` receipt: the Settings scene mounts no status toast
    /// and no bottom bar, so a receipt spoken there would be invisible
    /// under her default (QUESTIONS #106's class). The real confirmation is
    /// the window itself, which recolours as she clicks.
    static func landed(_ room: String, accent: String?) -> String {
        accent.map { "Using #\(room) with #\($0) for the chrome words." }
            ?? "Using #\(room)."
    }
}
