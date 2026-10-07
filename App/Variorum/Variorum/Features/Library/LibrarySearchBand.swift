//
//  LibrarySearchBand.swift
//  Variorum (Mac)
//
//  **13o U2 — THE RESULTS BAND** (Direction C, R-13o-15 — her words: *"I like
//  direction C, the answer sheet, the best. i feel like it could also grow a
//  more advanced mode easily - an extra dropdown for a more full search if we
//  want to add that later"*). The search state earns exactly ONE piece of
//  furniture: this band under the controls — the query's echo, the honest
//  counts, and the filters as quiet chips (`in: <wing>` · a typed `#tag ✕` ·
//  the armed `when` range ✕ · `+ archived`).
//
//  It shows whenever the field asks anything — words, a typed tag, or an
//  armed day (PROVISIONAL P-13o-U2-1: an armed filter is never invisible
//  state). Its TRAILING end is deliberately left open: R-13o-15's growth
//  note puts a later advanced-search dropdown there (VX-73); nothing of it is
//  built, and nothing here would need to move for it to join.
//

import SwiftUI
import VariorumCore

struct LibrarySearchBand: View {
    let tokens: VoiceTokens
    /// The field's question (nil while only a day is armed).
    let question: LibrarySearchQuestion?
    /// The band's numbers under the facet she is looking at.
    let counts: SearchCounts.Kinds?
    let visibility: SearchVisibility
    let wingName: String
    /// The armed `when` range's chip: its words and its ✕.
    var dayChip: (label: String, help: String, onClear: () -> Void)?
    let onRemoveTag: (String) -> Void
    let onToggleArchived: () -> Void
    /// **The mode facet** (13o U3): the armed state, whether the chip is
    /// offered at all (`LibraryCatalogModel.offersBookState` — never under a
    /// day), and its door (nil clears).
    var bookState: SearchBookState? = nil
    var offersBookState = false
    var onPickBookState: (SearchBookState?) -> Void = { _ in }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            if let question, !question.words.isEmpty {
                Text(LibrarySearchCopy.echo(question.words))
                    .font(tokens.small.weight(.semibold))
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            if let line = countsLine {
                Text(tokens.chromeLabel(line))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                    .layoutPriority(1)
            }
            LibrarySearchChip(tokens: tokens, label: tokens.chromeLabel(
                LibrarySearchCopy.wingChip(wingName)))
            ForEach(question?.tagPaths ?? [], id: \.self) { path in
                LibrarySearchChip(
                    tokens: tokens, label: LibrarySearchCopy.tagChip(path),
                    help: LibrarySearchCopy.removeTagHelp(path),
                    onClear: { onRemoveTag(path) })
            }
            if let dayChip {
                LibrarySearchChip(
                    tokens: tokens, label: tokens.chromeLabel(dayChip.label),
                    help: dayChip.help, onClear: dayChip.onClear)
            }
            // 13o U3 — the MODE FACET: an invitation that opens the five
            // states, or the armed state with its ✕.
            if let bookState {
                LibrarySearchChip(
                    tokens: tokens, label: tokens.chromeLabel(LibrarySearchCopy.bookStateChip(bookState)),
                    help: LibrarySearchCopy.bookStateOnHelp, onClear: { onPickBookState(nil) })
            } else if offersBookState {
                LibrarySearchBookStateMenu(tokens: tokens, onPick: onPickBookState)
            }
            // The facet applies to an answer — words, or a typed tag whose
            // books (living or archived) are counted (P-2: never a chip that
            // could not act).
            if let question, question.hasWords || (question.answers && counts != nil) {
                if visibility == .living {
                    LibrarySearchChip(
                        tokens: tokens, label: tokens.chromeLabel(LibrarySearchCopy.archivedOff),
                        help: LibrarySearchCopy.archivedOffHelp, invitation: true,
                        onTap: onToggleArchived)
                } else {
                    LibrarySearchChip(
                        tokens: tokens, label: tokens.chromeLabel(LibrarySearchCopy.archivedOn),
                        help: LibrarySearchCopy.archivedOnHelp, onClear: onToggleArchived)
                }
            }
            // R-13o-15's growth note: the trailing end stays open for a later
            // advanced-search dropdown (VX-73). Nothing is built there.
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tokens.wash.opacity(0.5))
    }

    /// "— 3 books · 29 notes …" with words, or for a typed tag's books (13o
    /// U3); nothing for a day alone (the listing below says what it means).
    private var countsLine: String? {
        guard let question, question.answers else { return nil }
        guard question.hasWords || counts != nil else { return nil }
        let words = counts.map(LibrarySearchCopy.counts) ?? LibrarySearchCopy.nothingFound
        return "\u{2014} " + words
    }
}

/// **The `+ book state` invitation** (13o U3 — the mockup's chip; the 13i
/// sitting record §12's mode facets): a quiet dashed chip that opens the five
/// states, each a FACT on the book's row, never a tag.
struct LibrarySearchBookStateMenu: View {
    let tokens: VoiceTokens
    let onPick: (SearchBookState?) -> Void

    var body: some View {
        Menu {
            ForEach(SearchBookState.allCases, id: \.self) { state in
                Button(tokens.chromeLabel(LibrarySearchCopy.bookStateChoice(state))) { onPick(state) }
            }
        } label: {
            LibrarySearchChip(
                tokens: tokens, label: tokens.chromeLabel(LibrarySearchCopy.bookStateOff), invitation: true)
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .lineLimit(1)
        .fixedSize()
        .help(LibrarySearchCopy.bookStateOffHelp)
    }
}

// (13o U3: `LibrarySearchChip` MOVED to `Core/Views/SearchAnswerFaces.swift` —
// the book's band is its second consumer; name preserved.)
