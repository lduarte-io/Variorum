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
                // VX-84a: the sheet shows only for a question WITH WORDS (the
                // catalog routes a tag typed alone to its own narrowed listing
                // — D-1), so the words-ask branch for a tag alone is gone.
                if !state.books.isEmpty {
                    booksSection
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
            .padding(.bottom, LibraryListFace.bottomInset)
        }
        // VX-349: the headers float only once the sheet has scrolled under them.
        .libraryListScrollReader()
        .background(tokens.surface)
    }

    /// The Books section: the associated books first (each row says why —
    /// the catalog's `bookRow` reads `bookReasons`), then the name hits.
    private var booksSection: some View {
        Section {
            LibraryListLead()
            ForEach(state.books, id: \.id) { hit in
                bookRow(hit)
            }
        } header: {
            LibraryListHeader(title: tokens.chromeLabel(LibrarySearchCopy.booksHeader))
        }
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
            // 13o U3 — the archived facet's face: under the facet a row says
            // which it is (R-13o-6). An archived NOTE says so once, under its
            // head; a passage archived on its own (its take or block) wears
            // the badge itself.
            if group.note != nil, group.isArchived {
                quiet(LibrarySearchCopy.archivedNote)
                    .padding(.leading, LibraryListFace.rowInsets.leading + 14)
                    .padding(.bottom, 2)
            }
            let open = state.expansions[group.homeID]
            let lines = open?.lines ?? group.lines
            ForEach(lines) { passage in
                LibrarySearchLine(
                    tokens: tokens, passage: passage,
                    archivedBadge: LibrarySearchFace.wearsArchivedBadge(
                        archived: passage.isArchived, inArchivedGroup: group.isArchived)
                ) { onOpenPassage(passage) }
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

// (13o U3: `LibrarySearchLine` and `LibrarySearchFace` MOVED to the shared home,
// `Core/Views/SearchAnswerFaces.swift` — the book's answer sheet is their second
// consumer, CLAUDE.md's shared-home rule; names preserved, the 3C parity pattern.)
