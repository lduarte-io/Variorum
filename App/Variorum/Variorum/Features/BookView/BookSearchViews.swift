//
//  BookSearchViews.swift
//  Variorum (Mac)
//
//  **13o U3 — SEARCH WITHIN A BOOK, its faces.** The masthead DOOR (her
//  R-13o-14: *"collapse it into a magnifying glass and only expand it when
//  clicked on"* — option 1's placement, the book masthead's right) and the
//  ANSWER (the architect's F1: *"the answer sheet's small sibling in place of
//  the book's content while the field holds words"*): a band — the echo, the
//  honest counts, `in: this book`, the archived chip where it can act — over
//  the passages GROUPED under their notes, every "all N ›" a real road. The
//  answer is drawn OVER the mode's own body, never instead of it, so clearing
//  the field returns the mode exactly as it was (scroll, focus, editor).
//
//  The line, the chip and the sheet's pure rules are the Library's own
//  (`Core/Views/SearchAnswerFaces.swift` — one search idiom in the app). The
//  brain is `BookSearchModel` (P-9); a passage lands through the shell's road
//  exactly as the Library's does (`BookView.onOpenSearchHit`).
//

import SwiftUI
import VariorumCore

// MARK: - The words

nonisolated enum BookSearchCopy {
    /// The glyph's help and the field's placeholder (the mockup's own
    /// "search this book…").
    static let door = "Search this book"
    static let placeholder = "search this book\u{2026}"
    /// The scope chip (the Library's `in: <wing>` twin).
    static let scopeChip = "in: this book"
    /// **The honest counts** at book scale — "14 passages in 5 notes"
    /// (the mockup's option-2 line, "14 passages in this book", with the
    /// notes the passages group under). PROVISIONAL P-13o-U3-6.
    ///
    /// **VX-1074 (D-1082-S1):** the book's own chapters found by name lead,
    /// as their own kind — "1 chapter · 14 passages in 5 notes" (the chapter
    /// word PROVISIONAL, for her wording pass); `chapters` 0 says exactly
    /// what it always said.
    static func counts(_ kinds: SearchCounts.Kinds, chapters: Int = 0) -> String {
        var parts: [String] = []
        if chapters > 0 { parts.append(chapterCount(chapters)) }
        if kinds.passages > 0 {
            parts.append(passages(kinds.passages) + " in " + notes(kinds.notes))
        } else if kinds.notes > 0 {
            parts.append(notes(kinds.notes))
        }
        return parts.isEmpty ? nothing : parts.joined(separator: " \u{00B7} ")
    }

    /// "1 chapter" · "2 chapters" — the book's own chapters its words found
    /// by name (VX-1074, D-1082-S1; PROVISIONAL wording).
    static func chapterCount(_ n: Int) -> String { "\(n) \(n == 1 ? "chapter" : "chapters")" }

    /// "1 passage" · "7 passages" (a group head's own count, too).
    static func passages(_ n: Int) -> String { "\(n) \(n == 1 ? "passage" : "passages")" }
    static func notes(_ n: Int) -> String { "\(n) \(n == 1 ? "note" : "notes")" }

    static let nothing = "nothing in this book matches"
    static let nothingRow = "Nothing in this book matches."
}

// MARK: - The masthead door (R-13o-14)

/// **The 🔍 at the masthead's right** — the glyph at rest; a click opens the
/// field beside it (focused); Esc, the glyph again, or leaving it empty
/// collapses it back to the glyph.
struct BookSearchDoor: View {
    let tokens: VoiceTokens
    let model: BookSearchModel
    @FocusState private var focused: Bool

    var body: some View {
        HStack(spacing: 4) {
            if model.isOpen {
                TextField(tokens.chromeLabel(BookSearchCopy.placeholder), text: Binding(
                    get: { model.text },
                    set: { value in
                        model.edit(value)
                        Task { await model.search() }
                    }))
                    .textFieldStyle(.roundedBorder)
                    .font(tokens.small)
                    // VX-1014: the field's 90-pt FLOOR lives in the masthead's
                    // title line now (`BookMastheadTitleLineRule.fieldFloor`),
                    // which keeps it whenever the column can and gives way
                    // only where it cannot — a frame floor here pushed the
                    // masthead past a narrow column.
                    .frame(minWidth: 0, idealWidth: 160, maxWidth: 180)
                    .focused($focused)
                    .onExitCommand { model.close() }
                    .onAppear { focused = true }
                    .onChange(of: focused) { _, now in
                        // An empty field she left rests as the glyph again.
                        if !now, model.text.isEmpty { model.close() }
                    }
            }
            Button {
                if model.isOpen { model.close() } else { model.open() }
            } label: {
                Image(systemName: "magnifyingglass")
            }
            .buttonStyle(.borderless)
            .help(CapabilityRegistry.capability(.searchThisBook).verb)
            .accessibilityLabel(BookSearchCopy.door)
        }
    }
}

// MARK: - The answer (F1)

/// **The book's answer sheet** — drawn over the mode's body while the field
/// holds words.
struct BookSearchSheet: View {
    let tokens: VoiceTokens
    let model: BookSearchModel
    /// A passage (or a note's head) lands — the shell's road (D6's).
    let onOpen: (_ postID: String, _ blockID: String?, _ find: EditorFindSeed?) -> Void
    /// **VX-1074 (D-1082-S1) — a chapter row lands**: the book closes the
    /// field and takes its own chapter road (Outline, the chapter at the top).
    var onOpenChapter: (_ sectionID: String) -> Void = { _ in }

    var body: some View {
        VStack(spacing: 0) {
            band
            Divider().overlay(tokens.line)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    // VX-1074 (D-1082-S1): the book's own chapters found by
                    // name, above the note groups.
                    ForEach(model.chapters) { chapter in
                        chapterRow(chapter)
                    }
                    ForEach(model.groups) { group in
                        groupView(group)
                    }
                    if model.hasMoreGroups {
                        Text(tokens.chromeLabel(model.loadingMore ? SearchAnswerCopy.loadingMore : ""))
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .frame(maxWidth: .infinity, minHeight: 18, alignment: .leading)
                            .padding(.horizontal, 24)
                            .onAppear { Task { await model.loadMoreGroups() } }
                    }
                    if model.groups.isEmpty, model.chapters.isEmpty {
                        // R-980-5: the one decision every answer sheet reads.
                        Text(tokens.chromeLabel(SearchAnswerCopy.emptyAnswer(
                            for: model.question, otherwise: BookSearchCopy.nothingRow)))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .padding(24)
                    }
                    if model.visibility == .living, let places = model.counts?.archivedPlaces, places > 0 {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(tokens.chromeLabel(SearchAnswerCopy.archivedFoot(places)))
                                .font(tokens.small)
                                .foregroundStyle(tokens.muted)
                            Button(tokens.chromeLabel(SearchAnswerCopy.showArchived)) {
                                Task { await model.toggleArchived() }
                            }
                            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                            .font(tokens.small)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(tokens.surface)
        // The answer covers the mode's body whole — no click falls through.
        .contentShape(Rectangle())
    }

    private var band: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            if !model.words.isEmpty {
                Text(SearchAnswerCopy.echo(model.words))
                    .font(tokens.small.weight(.semibold))
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            // VX-1074 (D-1082-S1): the band counts what the sheet lists — the
            // book's own chapters too (`BookSearchModel.bandCounts`).
            Text(tokens.chromeLabel("\u{2014} " + model.bandCounts))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
                .layoutPriority(1)
            LibrarySearchChip(tokens: tokens, label: tokens.chromeLabel(BookSearchCopy.scopeChip))
            if model.offersArchived {
                if model.visibility == .living {
                    LibrarySearchChip(
                        tokens: tokens, label: tokens.chromeLabel(SearchAnswerCopy.archivedOff),
                        help: SearchAnswerCopy.archivedOffHelp, invitation: true,
                        onTap: { Task { await model.toggleArchived() } })
                } else {
                    LibrarySearchChip(
                        tokens: tokens, label: tokens.chromeLabel(SearchAnswerCopy.archivedOn),
                        help: SearchAnswerCopy.archivedOnHelp,
                        onClear: { Task { await model.toggleArchived() } })
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tokens.wash.opacity(0.5))
    }

    /// **A chapter of this book found by its name** (VX-1074, D-1082-S1): the
    /// Library's chapter line without "in ‹book›" (it is this book); one
    /// click closes the field and lands the Outline at the chapter.
    private func chapterRow(_ chapter: SearchChapterHit) -> some View {
        let kind = SearchAnswerCopy.kindWord(.chapter) ?? ""
        let detail = chapter.isArchived ? "\(kind) \u{00B7} \(SearchAnswerCopy.archivedMark)" : kind
        return CatalogChapterLine(tokens: tokens, name: chapter.name, detail: detail)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture { onOpenChapter(chapter.sectionID) }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
            .padding(.horizontal, 24)
            .padding(.vertical, 8)
            .overlay(alignment: .bottom) {
                Rectangle().fill(tokens.line.opacity(0.5)).frame(height: 1).padding(.horizontal, 24)
            }
    }

    @ViewBuilder
    private func groupView(_ group: SearchGroup) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            // The head: the note as the book names it; a click opens it at
            // its start through the same landing road.
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(group.homeTitle)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                if group.lineCount > 0 {
                    Text(tokens.chromeLabel(BookSearchCopy.passages(group.lineCount)))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                }
                if group.isArchived {
                    Text(tokens.chromeLabel(SearchAnswerCopy.archivedMark))
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                }
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
            .onTapGesture { onOpen(group.homeID, nil, nil) }
            let open = model.expansions[group.homeID]
            ForEach(open?.lines ?? group.lines) { passage in
                LibrarySearchLine(
                    tokens: tokens, passage: passage,
                    archivedBadge: LibrarySearchFace.wearsArchivedBadge(
                        archived: passage.isArchived, inArchivedGroup: group.isArchived)
                ) {
                    guard let note = passage.noteID else { return }
                    onOpen(note, passage.blockID, SearchLanding.findSeed(
                        kind: passage.kind, rendered: passage.isRenderedTake, snippet: passage.snippet))
                }
                .padding(.leading, 14)
            }
            road(group, open: open)
                .padding(.leading, 14)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            Rectangle().fill(tokens.line.opacity(0.5)).frame(height: 1).padding(.horizontal, 24)
        }
    }

    @ViewBuilder
    private func road(_ group: SearchGroup, open: BookSearchModel.Expansion?) -> some View {
        HStack(spacing: 12) {
            if let open {
                if open.loading {
                    Text(tokens.chromeLabel(SearchAnswerCopy.loadingMore))
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                } else if open.next != nil {
                    roadButton(SearchAnswerCopy.moreLines) { await model.loadMoreLines(group.homeID) }
                }
                roadButton(SearchAnswerCopy.fewerLines) { await model.toggleExpansion(group.homeID) }
            } else if group.lineCount > group.lines.count {
                roadButton(SearchAnswerCopy.allLines(group.lineCount)) {
                    await model.toggleExpansion(group.homeID)
                }
            }
        }
    }

    private func roadButton(_ label: String, action: @escaping () async -> Void) -> some View {
        Button(tokens.chromeLabel(label)) { Task { await action() } }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            .font(tokens.small)
    }
}
