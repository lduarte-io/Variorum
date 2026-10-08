//
//  BookWindowLine.swift
//  Variorum (Mac)
//
//  **13o U3 — the book's window gets a ROAD** (the brief's item 8,
//  PROVISIONAL P-13o-U3-8; U2's close named it: the book Index's "showing the
//  first N notes" was a cap with no road to the rest — her ruled-against
//  class, R-13o-9's own words: *"the 40 cap with no escape is terrible"*).
//  One line, two renderers (the Index column and the Outline's flow): it says
//  how much of the book is read and offers the next window. The window grows
//  only at her press (`BookViewModel.showMore` — the deliberate widening the
//  model's own doc names, never a default; P1).
//

import SwiftUI

nonisolated enum BookWindowCopy {
    /// "showing the first 300 notes —" (the shipped words, kept).
    static func showing(_ n: Int) -> String { "showing the first \(n) notes \u{2014}" }
    /// The road: "show 300 more ›".
    static func showMore(_ n: Int) -> String { "show \(n) more \u{203A}" }
}

/// **The window's line** — drawn only while the window hides later notes.
struct BookWindowLine: View {
    let tokens: VoiceTokens
    let model: BookViewModel

    var body: some View {
        if model.truncated {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(tokens.chromeLabel(BookWindowCopy.showing(model.window)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                Button(tokens.chromeLabel(BookWindowCopy.showMore(BookViewModel.entryWindow))) {
                    model.showMore()
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .font(tokens.small)
            }
            .padding(.vertical, 8)
        }
    }
}
