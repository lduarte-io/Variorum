//
//  ShortcutsTab.swift
//  Variorum
//
//  **VX-572 (the VX-677 run, batch 4) — THE ⌘/ HELPER'S SHORTCUTS TAB.**
//  Her wants, both passes (the ticket carries them verbatim): search; helpful
//  headings, COLLAPSED by default; corrected spacing; the description in the
//  voice's face (Study's face in Study; the chord column may stay mono); no
//  mid-name breaks in the chord column; long descriptions must not wrap into
//  the neighbouring rhythm; easy to see which chord does what.
//
//  The face, piece by piece (PROVISIONAL P-572-2, the layout and its words):
//  · a search field pinned above the list, the caret in it on arrival —
//    the filter is `ShortcutCatalogFilter` (pure, pinned);
//  · every heading a press that folds and unfolds its group (▸ / ▾), its
//    title in the voice's heading face, one muted line of what it holds and
//    its count; at rest every group is folded; a search opens the groups it
//    matches;
//  · each row two columns: the chord column a FIXED width every token fits
//    on one line (`chordColumn` — pinned against every token the catalog
//    shows, both voices), each token drawn WHOLE in the voice's mono and its
//    accent ink, never broken; the description in the voice's own face
//    (`tokens.body` — Iowan Old Style in Study, the mono in Terminal), its
//    wrapped lines hanging in their own column, never under the chords;
//  · a hairline between rows and between groups, so a long description can
//    never read as the next row's.
//
//  Rendered from the registry (P-1): the rows are `ShortcutCatalog`'s, whose
//  chords are read from their acts' declarations.
//

import SwiftUI

// MARK: - The tab's state

/// The tab's session state — the query and which groups SHE opened.
/// Collapsed by default (her "default to not being expanded"). A heading
/// folded while searching folds for that query only (`searchCollapsed`,
/// emptied by every new query), so her own folding is never overwritten by
/// a search.
@MainActor @Observable
final class ShortcutsTabModel {
    private(set) var query: String
    private(set) var expanded: Set<ShortcutCatalog.Group>
    private(set) var searchCollapsed: Set<ShortcutCatalog.Group> = []

    init(query: String = "", expanded: Set<ShortcutCatalog.Group> = []) {
        self.query = query
        self.expanded = expanded
    }

    var isSearching: Bool { ShortcutCatalogFilter.isSearching(query) }

    var sections: [ShortcutCatalogFilter.Section] {
        ShortcutCatalogFilter.sections(
            query: query, expanded: expanded, searchCollapsed: searchCollapsed)
    }

    func setQuery(_ text: String) {
        guard text != query else { return }
        query = text
        searchCollapsed = []
    }

    /// A heading's press: her own folding at rest; this query's while
    /// searching.
    func toggle(_ group: ShortcutCatalog.Group) {
        if isSearching {
            searchCollapsed.formSymmetricDifference([group])
        } else {
            expanded.formSymmetricDifference([group])
        }
    }
}

// MARK: - Metrics and words

enum ShortcutsTabMetrics {
    /// The chord column's width: the widest token the catalog shows
    /// ("Format ▸ Strikethrough", "View ▸ Close All Notes" — 177 pt in
    /// Terminal's 13-pt mono, 170 pt in Study's 12.5) plus air. Pinned:
    /// every row's chord cell fits on ONE line inside it, both voices
    /// (`ShortcutsTabFaceTests`) — a token that would not is a token to
    /// shorten, never a column to break.
    static let chordColumn: CGFloat = 190
    /// The gap between the chord column and the description.
    static let columnGap: CGFloat = 16
    /// A row's own vertical padding — the space that keeps rows apart.
    static let rowPadding: CGFloat = 7
    /// Rows sit under the heading's title (the chevron's width + its gap).
    static let rowIndent: CGFloat = 20
    /// The description's line bound (P-8) — past the longest description's
    /// lines at the window's minimum width (pinned).
    static let descriptionLines = 12
    static let outerPadding: CGFloat = 20
}

/// The tab's own words (PROVISIONAL P-572-2 — VX-234's copy pass).
nonisolated enum ShortcutsCopy {
    static let framing = "Every shortcut here is also a menu item \u{2014} the menus are the map."
    static let searchLabel = "Search shortcuts"
    static let searchPrompt = "Search shortcuts \u{2014} what it does, or keys like cmd shift d"
    static let clearHelp = "Clear the search"
    static func noMatch(_ query: String) -> String {
        "No shortcut matches \u{201C}\(query.trimmingCharacters(in: .whitespacesAndNewlines))\u{201D} "
            + "\u{2014} try a word for what it does, or keys like cmd shift d."
    }
    /// The heading's count: the group's size at rest; "3 of 11" searching.
    static func count(_ section: ShortcutCatalogFilter.Section) -> String {
        section.isSearching ? "\(section.rows.count) of \(section.total)" : "\(section.total)"
    }
    static func headingHelp(_ group: ShortcutCatalog.Group, expanded: Bool) -> String {
        expanded ? "Fold \(group.title)" : "Show \(group.title)"
    }
}

// MARK: - The tab

struct ShortcutsTab: View {
    let tokens: VoiceTokens
    let model: ShortcutsTabModel
    @FocusState private var searchFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ShortcutSearchField(
                tokens: tokens,
                query: Binding(get: { model.query }, set: { model.setQuery($0) }),
                focused: $searchFocused)
                .padding(.horizontal, ShortcutsTabMetrics.outerPadding)
                .padding(.top, 14)
                .padding(.bottom, 10)
            ShortcutRule(tokens: tokens)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(ShortcutsCopy.framing)
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.bottom, 6)
                    let sections = model.sections
                    if sections.isEmpty {
                        Text(ShortcutsCopy.noMatch(model.query))
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.vertical, 10)
                    }
                    ForEach(sections) { section in
                        ShortcutGroupSection(section: section, tokens: tokens) {
                            model.toggle(section.group)
                        }
                    }
                }
                .padding(.horizontal, ShortcutsTabMetrics.outerPadding)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .onAppear { searchFocused = true }
    }
}

/// One group: its heading, and — open — its rows, a hairline between each.
struct ShortcutGroupSection: View {
    let section: ShortcutCatalogFilter.Section
    let tokens: VoiceTokens
    let toggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ShortcutRule(tokens: tokens)
            ShortcutGroupHeader(
                group: section.group, isExpanded: section.isExpanded,
                count: ShortcutsCopy.count(section), tokens: tokens, toggle: toggle)
            if section.isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(section.rows) { row in
                        ShortcutRule(tokens: tokens)
                        ShortcutRowView(row: row, tokens: tokens)
                    }
                }
                .padding(.leading, ShortcutsTabMetrics.rowIndent)
                .padding(.bottom, 6)
            }
        }
    }
}

/// The heading — the whole line is the press (▸ folded, ▾ open). It holds
/// only what it draws (never the group's rows), so a folded group's
/// composition carries no row at all — what the face pins read.
struct ShortcutGroupHeader: View {
    let group: ShortcutCatalog.Group
    let isExpanded: Bool
    let count: String
    let tokens: VoiceTokens
    let toggle: () -> Void

    var body: some View {
        Button(action: toggle) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(isExpanded ? "\u{25BE}" : "\u{25B8}")
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                    .frame(width: ShortcutsTabMetrics.rowIndent - 8, alignment: .leading)
                Text(tokens.chromeLabel(group.title))
                    .font(tokens.heading)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                    .fixedSize()
                Text(tokens.chromeLabel(group.line))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer(minLength: 8)
                Text(count)
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
                    .fixedSize()
            }
            .padding(.vertical, 9)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(ShortcutsCopy.headingHelp(group, expanded: isExpanded))
    }
}

/// One shortcut: the chords, then what they do.
struct ShortcutRowView: View {
    let row: ShortcutCatalog.Row
    let tokens: VoiceTokens

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: ShortcutsTabMetrics.columnGap) {
            ShortcutChordCell(chords: row.tokens, tokens: tokens)
                .frame(width: ShortcutsTabMetrics.chordColumn, alignment: .leading)
            Text(row.words)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
                .lineLimit(ShortcutsTabMetrics.descriptionLines)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, ShortcutsTabMetrics.rowPadding)
    }
}

/// The chord column: ONE text, one line, never broken, never truncated —
/// each chord WHOLE in the voice's mono and its accent ink, two chords as
/// "a / b" with the slash faint. `lineLimit(1)` + `fixedSize()` is the
/// no-mid-name-break rule; the column's width is pinned to hold every row's
/// cell (`ShortcutsTabMetrics.chordColumn`).
struct ShortcutChordCell: View {
    let chords: [String]
    let tokens: VoiceTokens

    var body: some View {
        Self.composed(chords, tokens: tokens)
            .font(tokens.mono)
            .lineLimit(1)
            .fixedSize()
    }

    static func composed(_ chords: [String], tokens: VoiceTokens) -> Text {
        var text = Text("")
        for (index, chord) in chords.enumerated() {
            if index > 0 { text = text + Text(" / ").foregroundStyle(tokens.faint) }
            text = text + Text(chord).foregroundStyle(tokens.accent)
        }
        return text
    }
}

/// The voice's hairline (Block History's `CommitRowRule` idiom).
struct ShortcutRule: View {
    let tokens: VoiceTokens

    var body: some View {
        Rectangle()
            .fill(tokens.line)
            .frame(height: 1)
            .frame(maxWidth: .infinity)
    }
}

/// The search field — the voiced field's idiom (`VoicedField`): a plain
/// field in the voice's card box with a hairline; ⎋ clears it.
struct ShortcutSearchField: View {
    let tokens: VoiceTokens
    @Binding var query: String
    var focused: FocusState<Bool>.Binding

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
            TextField(
                ShortcutsCopy.searchLabel, text: $query,
                prompt: Text(ShortcutsCopy.searchPrompt).foregroundStyle(tokens.faint))
                .labelsHidden()
                .textFieldStyle(.plain)
                .font(tokens.navigation)
                .foregroundStyle(tokens.ink)
                .focused(focused)
                .onExitCommand { query = "" }
            if !query.isEmpty {
                Button { query = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(tokens.small)
                        .foregroundStyle(tokens.faint)
                }
                .buttonStyle(.plain)
                .help(ShortcutsCopy.clearHelp)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(tokens.card, in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1))
    }
}
