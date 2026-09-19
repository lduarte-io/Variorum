//
//  TitleSuggestionChip.swift
//  Variorum (Mac)
//
//  **13u3 UNIT B — the capture half of her item 4** (RULED 2026-08-21,
//  verbatim): *"the title-suggestion chip at quick-note/capture (first words
//  offered, one tap to adopt, ignorable forever — a suggestion, never an
//  action taken for her)"*, beside the half she ruled in the same breath:
//  *"STORED Apple-Notes-style auto-title DEFINITIVELY rejected — what I hate
//  is battling the apple notes title."*
//
//  So the shape is exactly: an OFFER that does nothing until it is clicked,
//  and that can be clicked back off. Nothing is applied for her, ever; a
//  capture she never touches this on files untitled exactly as it always did
//  — and the Library now shows its first words anyway, which is the whole
//  point of the pair.
//
//  Shared home because BOTH capture surfaces render it (the shelf/library
//  quick-entry bar and the floating quick note) — CLAUDE.md's hoist rule,
//  applied at the first touch rather than parked in whichever feature minted
//  it.
//

import SwiftUI
import VariorumCore

/// The offered name, as a voiced chip: quiet while it is only an offer,
/// accent-inked with a ✓ once she has taken it.
struct TitleSuggestionChip: View {
    let tokens: VoiceTokens
    /// The words themselves — `NoteCardFace.suggestedTitle`'s answer, the
    /// same brain the Library's cards lead with.
    let suggestion: String
    let adopted: Bool
    let onToggle: () -> Void

    var body: some View {
        VoicedChip(tokens: tokens, text: label, on: adopted, action: onToggle)
            .help(adopted ? Self.adoptedHelp : Self.offerHelp)
            .accessibilityLabel(label)
    }

    /// The chip's words. The name is shown in her own quotation marks so a
    /// multi-word suggestion reads as one thing; the line truncates rather
    /// than wrapping (the chrome class rule), and what she adopts is the
    /// whole name whatever the chip had room to draw.
    private var label: String {
        adopted
            ? "\u{2713} title: \u{201C}\(suggestion)\u{201D}"
            : "name it \u{201C}\(suggestion)\u{201D}?"
    }

    static let offerHelp =
        "Use these first words as the note's title. Nothing is applied unless you click \u{2014} "
        + "an untitled note still shows its first words in the Library."
    static let adoptedHelp = "This will be the note's title \u{2014} click to leave it untitled."
}
