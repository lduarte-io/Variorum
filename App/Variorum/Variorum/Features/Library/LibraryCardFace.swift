//
//  LibraryCardFace.swift
//  Variorum (Mac)
//
//  **librarywalkpolish VR-117 — TERMINAL'S CARDS, MADE READABLE** (R-LWP-5,
//  her words at the walk: "let's fix terminal looking so impossible to read
//  on the cards somehow (we can change the font size or spacing to make it
//  more readable)"). Study's Cards are hers as they are ("she likes them") —
//  untouched, byte for byte; only the TERMINAL idiom of the card changes,
//  conservatively and from the voice's own type slots (no new literal):
//
//  - the preview lines move from the voice's 11.5-pt small mono to its 13-pt
//    `navigation` mono (the sidebar's row register — the voice's own
//    "readable small"), with 3 pt between the two lines;
//  - a little more air: 5 pt between the lead and the preview (was 2), 12 pt
//    above and below the card (was 9).
//
//  One table, keyed on the voice, so the change is one place to tune or
//  revert at her re-walk.
//

import SwiftUI
import VariorumCore

struct LibraryCardFace {
    let previewFont: Font
    let previewLineSpacing: CGFloat
    let leadToPreview: CGFloat
    let verticalPadding: CGFloat

    /// The SHIPPED face (13g R5-6 · 13u3 UNIT B) — Study keeps exactly this.
    static func shipped(_ tokens: VoiceTokens) -> LibraryCardFace {
        LibraryCardFace(
            previewFont: tokens.small, previewLineSpacing: 0, leadToPreview: 2, verticalPadding: 9)
    }

    static func of(_ tokens: VoiceTokens) -> LibraryCardFace {
        switch tokens.voice {
        case .study:
            return shipped(tokens)
        case .terminal:
            return LibraryCardFace(
                previewFont: tokens.navigation, previewLineSpacing: 3,
                leadToPreview: 5, verticalPadding: 12)
        }
    }
}
