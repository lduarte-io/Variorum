//
//  ContextBar.swift
//  Variorum (Mac)
//
//  Phase 13f, batch 5 (W20 b) — ONE bar above the pane saying WHERE YOU ARE,
//  in both senses, folding as ONE thing.
//
//  It began as batch 3's back chip (W16, her ruling: *"right now when you're
//  in write, there's no easy way to get back to the book you were in that
//  you just clicked in from"* … *"you should be able to collapse the named
//  back chip if you want - I like how clean the editor looks right now"*).
//  Round 8 added the second half — the ASCENT — in her words: *"even if you
//  navigated there some other way, there's gotta be a way from a post/note
//  to see what books it is present in and see it in the full context of any
//  of those books"*, and *"i think that chip + visible in line is good, but
//  I think that you should be able to hide it somehow (even if just with a
//  keyboard command). i love our uncluttered interface"*.
//
//  So the two halves share ONE bar, ONE collapse state and ONE fold —
//  **never two hiding mechanisms**, which is the whole point of the ruling.
//
//  ── WHY BOTH HALVES BELONG TO THE PANE ───────────────────────────────────
//  "Where did I come from" is the PANE's fact (batch 3's reason for putting
//  the chip in the shell rather than in `PostDetailView`), and so is "what
//  is this pane's note inside of". One bar per pane therefore serves a post,
//  a book, a folder and the recovery surface alike, and Write's masthead
//  stays untouched.
//
//  Collapsed, BOTH halves stay doors — a small arrow and a small book glyph
//  — because a fold that removes the road back is a one-way door, and her
//  ruling asked for tidiness, not for loss.
//

import SwiftUI
import VariorumCore

struct ContextBar: View {
    let tokens: VoiceTokens
    /// Where this pane arrived from — nil at a cold launch, and then the
    /// back half renders nothing at all.
    let originLabel: String?
    /// The pane's note's books, already ORDERED (`BookChooserOrder`) — the
    /// in-line names the top pick and counts the rest, so the sentence and
    /// the chip's list cannot disagree about which book comes first.
    let books: [Reading]
    let collapsed: Bool
    let onBack: () -> Void
    /// The ascent: open the top book, revealed at this note.
    let onOpenTopBook: () -> Void
    let onToggleCollapse: () -> Void

    /// Nothing to say ⇒ no bar. A pane at the shelf, or a note in no book
    /// reached directly, keeps exactly the chrome it had before this existed.
    var hasContent: Bool { originLabel != nil || !books.isEmpty }

    var body: some View {
        if hasContent {
            HStack(spacing: 6) {
                if let originLabel { backHalf(originLabel) }
                if let line = BookChooserOrder.inLine(books) { booksHalf(line) }
                fold
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 3)
            .background(tokens.room)
        }
    }

    private func backHalf(_ label: String) -> some View {
        Button(action: onBack) {
            HStack(spacing: 4) {
                Text("\u{2190}")
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                if !collapsed {
                    Text(tokens.chromeLabel(label))
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
        .help(WorkspaceNaming.backHelp(origin: label))
    }

    /// The ASCENT, in line. Collapsed it keeps a glyph — still a door.
    private func booksHalf(_ line: String) -> some View {
        Button(action: onOpenTopBook) {
            HStack(spacing: 4) {
                Image(systemName: "book")
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                if !collapsed {
                    Text(tokens.chromeLabel(line))
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
        .help(WorkspaceNaming.ascentHelp(
            topBook: books.first?.name ?? "", count: books.count))
    }

    /// ONE fold for the whole bar (her ruling). Present in BOTH states, so
    /// collapsing is never a one-way door.
    private var fold: some View {
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
            ? "Show where you are (\u{2318}\u{21e7}I)"
            : "Fold this bar down to its glyphs (\u{2318}\u{21e7}I)")
    }
}
