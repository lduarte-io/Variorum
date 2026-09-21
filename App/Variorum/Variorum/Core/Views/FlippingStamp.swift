//
//  FlippingStamp.swift
//  Variorum (Mac)
//
//  **THE ONE FLIPPING-STAMP BUTTON** — hoisted at 13u4 UNIT S2
//  (`KnownIssuesAndTechDebt` row 51, named at 17q's R-8: *"the card's
//  flipping stamp and the masthead's flip are two twelve-line buttons over
//  one words brain"*, deliberately not forced through `MastheadStamp`
//  mid-entry). Two features render it — the Library's note cards
//  (`CatalogCardStamps`) and the note masthead (`MastheadStamp`) — so
//  CLAUDE.md's placement rule sends it to the shared Mac-chrome home at the
//  next touch of work on it, which is this unit.
//
//  What is genuinely shared, and all that is:
//
//    · the BUTTON — a quiet voiced button, `fixedSize`, with the whole fact
//      on hover. Both call sites had those four lines, byte for byte;
//    · the HINT VOCABULARY (`StampFlipHint`) — what a click will show NEXT.
//      The masthead spelled it inline and the Library spelled it in
//      `LibrarySortFace.flipHint`, in the same words; now there is one
//      table and `flipHint` forwards to it (the 3C parity pattern —
//      pre-move names forwarded, zero test edits).
//
//  What is deliberately NOT shared, because the two are not the same thing:
//  the masthead flips between two SUBJECTS of a held `noteStamps`
//  observation and carries the masthead's geometry probe; the card flips
//  between two already-computed `RowStamp`s a catalog hit carries. Their
//  DEBUG doors are different oracles too (`PostDetailOracle.flipStamp` /
//  `CatalogStampOracle.flip`), and an oracle belongs to the surface it
//  reports on — so both stay at their call sites.
//
//  The WORDS in every state are `TimeStampFace`'s (core `Domain`), which is
//  the brain this component exists to keep singular.
//

import SwiftUI
import VariorumCore

/// A quiet stamp you can click to see the other fact.
///
/// `help` is the whole sentence — the caller composes it, because the two
/// surfaces hold their fact differently (the masthead has a `Date`, the
/// card a stored ISO string) and a component that guessed would be a second
/// wording rule. Pass nil where the LABEL already carries the tooltip (the
/// Library card's `CatalogRowStamp` does).
struct FlippingStamp<Label: View>: View {
    let tokens: VoiceTokens
    var help: String?
    let flip: () -> Void
    @ViewBuilder var label: () -> Label

    /// **P-8, and the one line of it this component owns:** the button is
    /// `fixedSize`, so its LABEL must carry a `lineLimit` — both call sites'
    /// do (`Text(...).lineLimit(1)` and `CatalogRowStamp`, which is
    /// `lineLimit(1)` + `fixedSize` for exactly this reason). A nil `help`
    /// means the label carries the tooltip; an EMPTY `.help("")` is not the
    /// same thing (it hangs a blank tooltip on hover), so the branch is
    /// real.
    @ViewBuilder var body: some View {
        let button = Button(action: flip) { label() }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            .fixedSize()
        if let help {
            button.help(help)
        } else {
            button
        }
    }
}

/// **What a click on a flipping stamp will SHOW NEXT** — one vocabulary, so
/// the Library's cards and the note's masthead cannot word one gesture two
/// ways. The subject named is the one the click REVEALS, never the one on
/// screen.
nonisolated enum StampFlipHint {
    static func toSee(_ subject: TimeStampFace.Subject) -> String {
        switch subject {
        case .created: "click to see when it was created"
        case .edited: "click to see when it was last edited"
        case .dated: "click to see the day this note is about"
        }
    }
}
