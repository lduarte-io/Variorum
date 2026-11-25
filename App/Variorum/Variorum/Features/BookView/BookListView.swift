//
//  BookListView.swift
//  Variorum (Mac)
//
//  **VX-1084 — the book's List mode** (her R-1036-29 "List as a fifth mode";
//  R-1036-38 "List is rows only; outline is the cards"). WIP at the VX-1036
//  run's batch 3, piece P1: the mode exists and draws the book's notes in its
//  order; the face — the Library's own row, the headings with their counts and
//  the chapter door — is piece P3.
//

import SwiftUI
import VariorumCore

struct BookListView: View {
    let model: BookViewModel
    let tokens: VoiceTokens

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 4) {
                ForEach(model.entries, id: \.postID) { entry in
                    Text(entry.displayTitle)
                        .font(tokens.body)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(1)
                }
            }
            .padding(20)
        }
    }
}
