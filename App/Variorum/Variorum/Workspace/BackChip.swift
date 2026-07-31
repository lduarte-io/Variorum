//
//  BackChip.swift
//  Variorum (Mac)
//
//  Phase 13f, batch 3 (W16) — the named back chip, her ruling:
//
//  > *"right now when you're in write, there's no easy way to get back to
//  > the book you were in that you just clicked in from"* … *"I think that
//  > you should be able to collapse the named back chip if you want - I
//  > like how clean the editor looks right now."*
//
//  So: it names where you came from, it is one click home, and it folds to
//  a single glyph that is STILL A DOOR — never zero door. It renders in the
//  shell above the detail, not inside any surface, because the road back is
//  the PANE's fact and not the post's (which is also why a book, a folder
//  and the shelf all get the same chip for free).
//
//  It renders at all only when the pane arrived from somewhere: at the
//  shelf, on a cold launch, there is nothing above the detail.
//

import SwiftUI

struct BackChip: View {
    let tokens: VoiceTokens
    /// The origin's name, already resolved (P-8: chrome text carries a
    /// `lineLimit` — the b6dae25 class, where an unbounded chrome `Text`
    /// inflated the window's min-height probe).
    let originLabel: String
    let collapsed: Bool
    let onBack: () -> Void
    let onToggleCollapse: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Button(action: onBack) {
                HStack(spacing: 4) {
                    Text("\u{2190}")
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                    if !collapsed {
                        Text(tokens.chromeLabel(originLabel))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: 280, alignment: .leading)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .overlay(Capsule().stroke(tokens.line, lineWidth: 1))
                .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .help(WorkspaceNaming.backHelp(origin: originLabel))

            // The fold. Present in BOTH states, so collapsing is never a
            // one-way door — collapsed reads "← ›", two small glyphs, and
            // the arrow still goes back.
            Button(action: onToggleCollapse) {
                Image(systemName: collapsed ? "chevron.right" : "chevron.left")
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .padding(.vertical, 2)
                    .padding(.horizontal, 2)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help(collapsed
                ? "Show where you came from"
                : "Fold this down to just the arrow")

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 3)
        .background(tokens.room)
    }
}
