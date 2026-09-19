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
        VoicedChip(
            tokens: tokens, text: label, on: adopted, action: onToggle,
            content: Self.voiced(segments, tokens: tokens),
            // ONE line, for THIS chip only (the chrome class rule, scoped):
            // a 48-character name in a 300 pt pad truncates rather than
            // wrapping, and what she adopts is the whole name whatever the
            // chip had room to draw. `VoicedChip.lines` carries why it is not
            // the family's rule.
            lines: 1)
            .help(adopted ? Self.adoptedHelp : Self.offerHelp)
            .accessibilityLabel(label)
    }

    // MARK: - The words

    /// **One piece of the chip's label, and whose words it is.**
    ///
    /// The walk found this: the chip drew its whole label through
    /// `chromeLabel`, which LOWERCASES in the Terminal voice — so the offer
    /// read *name it “garden plans for the spring…”* over a note that would
    /// be titled *“Garden plans…”*. The voice's rule is right for the app's
    /// own words and wrong for hers, and a chip that shows a different name
    /// from the one it will apply is worse than no chip.
    ///
    /// Split as data rather than assembled inline so the rule is pinnable: a
    /// `Text` built by `+` is not something a test can read back.
    struct Segment: Equatable {
        let text: String
        /// True ⇒ the app's own words, which the voice may case-fold.
        let voiced: Bool
    }

    var segments: [Segment] { Self.segments(suggestion: suggestion, adopted: adopted) }

    static func segments(suggestion: String, adopted: Bool) -> [Segment] {
        let name = Segment(text: "\u{201C}\(suggestion)\u{201D}", voiced: false)
        return adopted
            ? [Segment(text: adoptedLead, voiced: true), name]
            : [Segment(text: offerLead, voiced: true), name,
               Segment(text: offerTrail, voiced: true)]
    }

    /// What the chip actually DRAWS, as a string — the app's half through the
    /// voice, hers untouched. (The `Text` the view uses is the same walk over
    /// the same segments.)
    static func rendered(_ segments: [Segment], tokens: VoiceTokens) -> String {
        segments.map { $0.voiced ? tokens.chromeLabel($0.text) : $0.text }.joined()
    }

    private static func voiced(_ segments: [Segment], tokens: VoiceTokens) -> Text {
        segments.reduce(Text("")) { whole, segment in
            whole + Text(segment.voiced ? tokens.chromeLabel(segment.text) : segment.text)
        }
    }

    /// The plain-string answer, unvoiced — the tooltip's and the
    /// accessibility label's. The name is in her own quotation marks so a
    /// multi-word suggestion reads as one thing; the chip's line truncates
    /// rather than wrapping (the chrome class rule), and what she adopts is
    /// the whole name whatever it had room to draw.
    var label: String { segments.map(\.text).joined() }

    static let offerLead = "name it "
    static let offerTrail = "?"
    static let adoptedLead = "\u{2713} title: "

    static let offerHelp =
        "Use these first words as the note's title. Nothing is applied unless you click \u{2014} "
        + "an untitled note still shows its first words in the Library."
    static let adoptedHelp = "This will be the note's title \u{2014} click to leave it untitled."
}
