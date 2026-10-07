//
//  LibrarySearchSheet.swift
//  Variorum (Mac)
//
//  **13o U2 — THE ANSWER SHEET** (Direction C, R-13o-15): the Books section
//  (every book a book or chapter hit names), then ONE ranked stream of
//  GROUPS — a note, or a scraps group, per head — each with its best
//  passages and an "all N ›" that opens it in place and pages through the
//  rest (R-13o-9: every "all N ›" a real road; the groups themselves page as
//  she scrolls). So two hundred matches read as a dozen notes.
//
//  A NOTE group's head IS the List's own note row (the catalog hands it in:
//  click selects and shows the panel, ⌘/⇧ pick, the menu, the tags, the
//  owned-by badge — R-13o-10's badge rides it unchanged), so nothing she
//  does to a note in the List stops working while she searches. The sheet
//  draws in the List's face (`LibraryListFace`), in every mode that lists
//  notes — the passages need the room a card does not have.
//
//  The brain is `LibrarySearchModel` (P-9); this view renders its state and
//  sends the catalog's acts.
//

import SwiftUI
import VariorumCore

struct LibrarySearchSheet<NoteHead: View, BookRow: View>: View {
    let model: LibraryCatalogModel
    let tokens: VoiceTokens
    /// The archived word's door (D4).
    let onShowArchived: () -> Void
    /// A passage line was clicked — the catalog lands it (D6).
    let onOpenPassage: (SearchPassage) -> Void
    /// A scraps group's head was clicked — the scraps area opens.
    let onOpenPool: (String) -> Void
    /// A note group's head: the List's own row, built by the catalog.
    @ViewBuilder let noteHead: (Queries.CatalogHit) -> NoteHead
    /// A Books-section row, built by the catalog.
    @ViewBuilder let bookRow: (Queries.CatalogHit) -> BookRow

    private var state: LibrarySearchModel { model.searchState }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                if let question = state.question, !question.hasWords {
                    // PROVISIONAL P-13o-U2-6: a tag alone asks for words.
                    LibraryListLead()
                    LibraryListRow {
                        Text(tokens.chromeLabel(LibrarySearchCopy.tagAlone(question.tagPaths)))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                    }
                } else {
                    if !state.books.isEmpty {
                        Section {
                            LibraryListLead()
                            ForEach(state.books, id: \.id) { hit in
                                bookRow(hit)
                            }
                        } header: {
                            LibraryListHeader(title: tokens.chromeLabel(LibrarySearchCopy.booksHeader))
                        }
                        if !state.groups.isEmpty {
                            Color.clear.frame(height: LibraryListFace.sectionGap)
                        }
                    }
                    if !state.groups.isEmpty {
                        Section {
                            if state.books.isEmpty { LibraryListLead() }
                            ForEach(state.groups) { group in
                                groupView(group)
                                    .onAppear { model.searchGroupAppeared(group) }
                                    .onDisappear { model.searchGroupDisappeared(group) }
                            }
                            if state.hasMoreGroups {
                                LibraryListRow {
                                    Text(tokens.chromeLabel(
                                        state.loadingMore ? LibrarySearchCopy.loadingMore : ""))
                                        .font(tokens.small)
                                        .foregroundStyle(tokens.faint)
                                        .frame(maxWidth: .infinity, minHeight: 18, alignment: .leading)
                                }
                                .onAppear { Task { await model.loadMoreSearchGroups() } }
                            }
                        } header: {
                            LibraryListHeader(title: tokens.chromeLabel(
                                LibrarySearchCopy.groupsHeader(state.scope)))
                        }
                    }
                    if state.books.isEmpty, state.groups.isEmpty {
                        LibraryListLead()
                        LibraryListRow {
                            Text(tokens.chromeLabel(LibraryCopy.nothingMatches))
                                .font(tokens.small)
                                .foregroundStyle(tokens.muted)
                        }
                    }
                    if let places = archivedFootPlaces {
                        LibraryListRow { archivedFoot(places) }
                    }
                }
            }
            .padding(.bottom, LibraryListFace.bottomInset)
        }
        .background(tokens.surface)
    }

    /// The archived foot (D4): the facet is off and the archive holds
    /// matches.
    private var archivedFootPlaces: Int? {
        guard state.visibility == .living, let places = state.counts?.archivedPlaces,
              places > 0 else { return nil }
        return places
    }

    private func archivedFoot(_ places: Int) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(tokens.chromeLabel(LibrarySearchCopy.archivedFoot(places)))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            Button(tokens.chromeLabel(LibrarySearchCopy.showArchived), action: onShowArchived)
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .font(tokens.small)
        }
    }

    // MARK: - One group

    @ViewBuilder
    private func groupView(_ group: SearchGroup) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if let note = group.note {
                noteHead(note)
            } else {
                LibraryListRow { poolHead(group) }
            }
            let open = state.expansions[group.homeID]
            let lines = open?.lines ?? group.lines
            ForEach(lines) { passage in
                LibrarySearchLine(tokens: tokens, passage: passage) { onOpenPassage(passage) }
                    .padding(.leading, LibraryListFace.rowInsets.leading + 14)
                    .padding(.trailing, LibraryListFace.rowInsets.trailing)
                    .padding(.vertical, 2)
            }
            road(group, open: open)
                .padding(.leading, LibraryListFace.rowInsets.leading + 14)
                .padding(.bottom, 6)
        }
        .overlay(alignment: .bottom) { LibraryListSeparator() }
    }

    /// "all N ›" (closed, more than shown) · "more ›" / "fewer ‹" (open).
    @ViewBuilder
    private func road(_ group: SearchGroup, open: LibrarySearchModel.Expansion?) -> some View {
        HStack(spacing: 12) {
            if let open {
                if open.loading {
                    quiet(LibrarySearchCopy.loadingMore)
                } else if open.next != nil {
                    roadButton(LibrarySearchCopy.moreLines) {
                        Task { await state.loadMoreLines(group.homeID) }
                    }
                }
                roadButton(LibrarySearchCopy.fewerLines) {
                    Task { await state.toggleExpansion(group.homeID) }
                }
            } else if group.lineCount > group.lines.count {
                roadButton(LibrarySearchCopy.allLines(group.lineCount)) {
                    Task { await state.toggleExpansion(group.homeID) }
                }
            }
        }
    }

    private func roadButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(tokens.chromeLabel(label), action: action)
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            .font(tokens.small)
    }

    private func quiet(_ text: String) -> some View {
        Text(tokens.chromeLabel(text))
            .font(tokens.small)
            .foregroundStyle(tokens.faint)
    }

    /// A scraps group's head — its Snippets group, opening the scraps area.
    private func poolHead(_ group: SearchGroup) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(Image(systemName: "square.on.square"))
                .font(tokens.body)
                .foregroundStyle(tokens.muted)
            Text(group.homeTitle)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
            Text(tokens.chromeLabel(LibrarySearchCopy.inSnippets))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            if group.isArchived {
                Text(tokens.chromeLabel(LibrarySearchCopy.archivedMark))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
            }
            Spacer(minLength: 0)
        }
        .contentShape(Rectangle())
        .onTapGesture { onOpenPool(group.homeID) }
    }
}

/// **One passage line** — its kind word where it is not prose, its snippet
/// with the matched words marked in the index's own folding (what matched
/// IS what is marked — F1), and the "in another take" badge where the hit's
/// take is not the one the note shows. A click lands it (D6).
struct LibrarySearchLine: View {
    let tokens: VoiceTokens
    let passage: SearchPassage
    let onOpen: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            if let word = LibrarySearchCopy.kindWord(passage.kind) {
                Text(tokens.chromeLabel(word))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .fixedSize()
            }
            Text(LibrarySearchFace.snippet(passage.snippet, tokens: tokens))
                .font(tokens.small)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            if LibrarySearchFace.isInAnotherTake(kind: passage.kind, rendered: passage.isRenderedTake) {
                Text(tokens.chromeLabel(LibrarySearchCopy.inAnotherTake))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .padding(.horizontal, 5)
                    .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(tokens.line))
                    .fixedSize()
            }
            Spacer(minLength: 0)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onOpen)
    }
}

/// The sheet's pure rules (pinned).
enum LibrarySearchFace {
    /// The snippet's runs as one attributed line — the matched runs on the
    /// wash in the ink, the rest muted (the mockup's `<mark>`).
    static func snippet(_ segments: [SearchSnippetSegment], tokens: VoiceTokens) -> AttributedString {
        var line = AttributedString()
        for segment in segments {
            var run = AttributedString(segment.text)
            if segment.isMatch {
                run.foregroundColor = tokens.ink
                run.backgroundColor = tokens.wash
            } else {
                run.foregroundColor = tokens.muted
            }
            line += run
        }
        return line
    }

    /// A take hit the note does not render (the mockup's badge).
    static func isInAnotherTake(kind: SearchPassage.Kind, rendered: Bool) -> Bool {
        kind == .take && !rendered
    }
}
