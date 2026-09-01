//
//  BookIndexView.swift
//  Variorum
//
//  pre-13u Act 10 wave 2c — **the INDEX-LIKE BOOK VIEW** (item 18, W8-5;
//  her ruling: "there should ALSO be an index like view" — the note Index
//  mode's sibling at book scale, and the answer to her reconciliation
//  question: while Index is active the minimal navigator steps aside,
//  because the index IS the outline pane grown up; the minimal pane stays
//  beside the other modes — two grains, deliberately).
//
//  Structure: a standing column — chapters as foldable sections, notes
//  under them, filter over titles — beside a scroll-synced rendered pane
//  (the whole book as read-cheap prose, virtualized per note; P3/P1). The
//  brain is NOT `NoteIndexOutline`, deliberately: a note's sections are
//  DERIVED from markdown headings, a book's chapters are REAL
//  `reading_section` rows — deriving them again would be a second brain
//  over facts `BookStructureModel.grouped` already owns. What IS shared is
//  the grammar (column + synced pane) and the one markdown transform
//  (`FlowParagraph`).
//
//  Liveness: NONE — the index is a projection tier end to end (P-3 holds
//  by construction). Editing goes where editing lives: a double-click (or
//  the row's edit door) lands the note focused in OUTLINE — the same
//  scrolled-open-door shape the note Read mode uses.
//

import SwiftUI
import VariorumCore

// MARK: - The pure column brain

/// The index column's flattening — groups (real chapters, tag-path runs,
/// or one flat run) folded and filtered into the rows the column draws.
/// Pure so the fold/filter behavior is pinned, not observed
/// (`BookIndexColumnTests`).
nonisolated enum BookIndexColumn {
    struct Group: Equatable {
        /// Stable fold identity: the chapter's row id, `"path:" + path`
        /// for a tag-grouping run, `"unfiled"` for the trailing strays.
        var id: String
        /// nil ⇒ a flat run — no heading row, nothing to fold.
        var title: String?
        var entries: [Queries.ReadingEntry]
    }

    enum RowKind: Equatable {
        case chapter(title: String, count: Int, folded: Bool)
        case note(Queries.ReadingEntry, nested: Bool)
    }

    struct Row: Equatable, Identifiable {
        var id: String
        var groupID: String?
        var kind: RowKind
    }

    /// Groups from REAL chapters (`BookStructureModel.grouped`'s shape —
    /// curated books with live sections; the nil-section group is the
    /// ratified trailing "unfiled").
    static func groups(
        chapters: [(section: ReadingSection?, entries: [Queries.ReadingEntry])]
    ) -> [Group] {
        chapters.map { group in
            if let section = group.section {
                return Group(id: section.id, title: section.name, entries: group.entries)
            }
            return Group(id: "unfiled", title: "unfiled", entries: group.entries)
        }
    }

    /// Groups from the tag-path sectioning (smart books / stamp sorts):
    /// consecutive runs of one `sectionPath` become a titled group; a run
    /// with none is a flat, unfoldable stretch — a headingless book reads
    /// honestly flat (the `NoteIndexOutline` posture, same reason).
    static func groups(flat entries: [Queries.ReadingEntry]) -> [Group] {
        var result: [Group] = []
        for entry in entries {
            let path = entry.sectionPath
            if !result.isEmpty, result[result.count - 1].title == path {
                result[result.count - 1].entries.append(entry)
            } else {
                // The index prefix keeps ids unique when the same path
                // recurs after a break (X · unsectioned · X) — fold state
                // is session view state, so positional identity is enough.
                let id = path.map { "path:\(result.count):\($0)" }
                    ?? "run:\(result.count)"
                result.append(Group(id: id, title: path, entries: [entry]))
            }
        }
        return result
    }

    /// Does this entry answer the filter? Titles and dates — the column
    /// indexes what it shows; body-text search is 13o's, deliberately.
    static func matches(_ entry: Queries.ReadingEntry, filter: String) -> Bool {
        let needle = filter.trimmingCharacters(in: .whitespaces)
        guard !needle.isEmpty else { return true }
        if entry.displayTitle.localizedCaseInsensitiveContains(needle) { return true }
        return entry.entryDate?.localizedCaseInsensitiveContains(needle) ?? false
    }

    /// The flattened column (the note Index's fold/filter grammar — a
    /// group survives when its title or any member matches; folding hides
    /// members even mid-filter — with ONE deliberate divergence: a
    /// matching CHAPTER title keeps ALL its notes, where the note Index
    /// shows a matching heading alone. A chapter's name is how a book's
    /// notes are FOUND — "memoirs" showing an empty-looking chapter would
    /// read as a chapter with nothing in it. A note's heading matching is
    /// about that heading's own words. Pinned both ways.
    static func rows(
        groups: [Group], collapsed: Set<String>, filter: String
    ) -> [Row] {
        let needle = filter.trimmingCharacters(in: .whitespaces)
        var result: [Row] = []
        for group in groups {
            let hits = group.entries.filter { matches($0, filter: needle) }
            if let title = group.title {
                let titleMatches = needle.isEmpty
                    || title.localizedCaseInsensitiveContains(needle)
                guard titleMatches || !hits.isEmpty else { continue }
                let folded = collapsed.contains(group.id)
                result.append(Row(
                    id: "sec-\(group.id)", groupID: group.id,
                    kind: .chapter(
                        title: title, count: group.entries.count, folded: folded)))
                if !folded {
                    let kids = (needle.isEmpty || titleMatches) ? group.entries : hits
                    result.append(contentsOf: kids.map {
                        Row(id: $0.postID, groupID: group.id,
                            kind: .note($0, nested: true))
                    })
                }
            } else {
                result.append(contentsOf: hits.map {
                    Row(id: $0.postID, groupID: group.id,
                        kind: .note($0, nested: false))
                })
            }
        }
        return result
    }
}

#if DEBUG
/// Virtualization pin support (the `ReadingFlowMaterialization` shape): the
/// pane's per-note bodies must materialize near the viewport only — a 105k
/// book realizing every note on open is exactly the P1 shape this counter
/// exists to catch.
@MainActor
enum BookIndexMaterialization {
    static var count = 0
}
#endif

// MARK: - The view

struct BookIndexView<Masthead: View>: View {
    let session: AppSession
    let model: BookViewModel
    let structure: BookStructureModel
    /// The book's masthead chrome (title · mode tabs · settings · order),
    /// composed by `BookView` so the index column and the navigator can
    /// never disagree about what the book's header says.
    @ViewBuilder var masthead: () -> Masthead
    /// Land this note focused in OUTLINE — editing lives where editing
    /// lives (`structure.mode = .outline; model.focus`), the note Read
    /// mode's own click-through shape.
    let onEditInOutline: (String) -> Void

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    @State private var selectedPostID: String?
    @State private var collapsed: Set<String> = []
    @State private var filter = ""
    /// Two one-shot scroll channels, one consumer each (the wave's own
    /// lesson from the note Index: two consumers of one nil-after-scroll
    /// request race each other).
    @State private var paneTarget: String?
    @State private var columnTarget: String?
    @State private var seeded = false

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    private var groups: [BookIndexColumn.Group] {
        structure.chaptersActive
            ? BookIndexColumn.groups(chapters: structure.grouped(entries: model.entries))
            : BookIndexColumn.groups(flat: model.entries)
    }

    var body: some View {
        HStack(spacing: 0) {
            column
                .frame(width: 300)
            Divider().overlay(tokens.line)
            pane
        }
        .background(tokens.surface)
        .onAppear { landOrSeed() }
        .onChange(of: model.pendingReveal) { _, _ in landOrSeed() }
        .onChange(of: model.entries) { _, _ in landOrSeed() }
    }

    /// Arrive where she was: the carry's parked reveal wins; else the
    /// book's standing place; else the first note. One-shot.
    private func landOrSeed() {
        if let reveal = model.pendingReveal,
           model.entries.contains(where: { $0.postID == reveal }) {
            model.consumeReveal()
            seeded = true
            select(reveal, scrollPane: true, report: false)
            return
        }
        guard !seeded, !model.entries.isEmpty else { return }
        seeded = true
        let landing = [model.focusedPostID, model.standingAnchorPostID]
            .compactMap { $0 }
            .first { id in model.entries.contains { $0.postID == id } }
        select(landing ?? model.entries[0].postID, scrollPane: true, report: false)
    }

    private func select(_ postID: String, scrollPane: Bool, report: Bool = true) {
        selectedPostID = postID
        if scrollPane {
            paneTarget = postID
            columnTarget = postID
        }
        if report { model.noteIndexAnchor(postID) }
    }

    // MARK: The column

    private var column: some View {
        VStack(alignment: .leading, spacing: 0) {
            masthead()
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 8)
            columnHeader
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 1) {
                        ForEach(BookIndexColumn.rows(
                            groups: groups, collapsed: collapsed, filter: filter)
                        ) { row in
                            switch row.kind {
                            case let .chapter(title, count, folded):
                                chapterRow(
                                    row, title: title, count: count, folded: folded)
                            case let .note(entry, nested):
                                noteRow(entry, nested: nested)
                            }
                        }
                        if model.truncated {
                            Text(tokens.chromeLabel(
                                "showing the first \(BookViewModel.entryWindow) notes"))
                                .font(tokens.small)
                                .foregroundStyle(tokens.muted)
                                .padding(.vertical, 8)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                }
                .onChange(of: columnTarget) { _, target in
                    guard let target else { return }
                    proxy.scrollTo("bix-\(target)", anchor: .center)
                    columnTarget = nil
                }
            }
            columnFooter
        }
        .background(tokens.surface)
    }

    private var columnHeader: some View {
        HStack(spacing: 8) {
            HStack(spacing: 6) {
                Text("⌕")
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                TextField(tokens.chromeLabel("filter this book"), text: $filter)
                    .textFieldStyle(.plain)
                    .font(tokens.small)
                    .foregroundStyle(tokens.ink)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tokens.card, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1))
            let foldable = groups.filter { $0.title != nil }
            if !foldable.isEmpty {
                Button(tokens.chromeLabel(collapsed.isEmpty ? "fold all" : "unfold")) {
                    collapsed = collapsed.isEmpty ? Set(foldable.map(\.id)) : []
                }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .help("Fold every chapter down to its heading — and back")
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 9)
    }

    private func chapterRow(
        _ row: BookIndexColumn.Row, title: String, count: Int, folded: Bool
    ) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Button(folded ? "▸" : "▾") {
                guard let groupID = row.groupID else { return }
                if folded { collapsed.remove(groupID) } else { collapsed.insert(groupID) }
            }
            .buttonStyle(.plain)
            .font(tokens.small)
            .foregroundStyle(tokens.faint)
            .help(folded ? "Unfold this chapter" : "Fold this chapter to its heading")
            Text(tokens.chromeLabel(title))
                .font(tokens.small.weight(.semibold))
                .foregroundStyle(tokens.accent)
                .lineLimit(1)
            Spacer(minLength: 4)
            Text("\(count)")
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 3)
        .contentShape(Rectangle())
        .onTapGesture {
            // A chapter click shows the chapter: the pane lands on its
            // heading; the selection stays a note-level fact.
            guard let groupID = row.groupID else { return }
            paneTarget = "sec-\(groupID)"
        }
        .id("bix-sec-\(row.groupID ?? row.id)")
    }

    private func noteRow(_ entry: Queries.ReadingEntry, nested: Bool) -> some View {
        BookIndexNoteRow(
            tokens: tokens,
            entry: entry,
            nested: nested,
            selected: selectedPostID == entry.postID,
            onSelect: { select(entry.postID, scrollPane: true) },
            onEdit: { onEditInOutline(entry.postID) },
            menu: { AnyView(chapterFilingMenu(entry.postID)) })
            .id("bix-\(entry.postID)")
    }

    /// The chapter-filing menu — the same doors the outline rows carry
    /// (curated books only; QUESTIONS #25(a)).
    @ViewBuilder
    private func chapterFilingMenu(_ postID: String) -> some View {
        Button("Edit here in the book (Outline)") { onEditInOutline(postID) }
        Button("Open in the full editor") {
            NotificationCenter.default.post(
                name: .variorumOpenPost, object: nil, userInfo: ["postID": postID])
        }
        if structure.reading?.kind == .curated {
            Divider()
            Menu("Chapter") {
                ForEach(structure.sections, id: \.id) { section in
                    Button(section.name) {
                        Task { await structure.assign(postID, to: section.id) }
                    }
                }
                Divider()
                Button("None") {
                    Task { await structure.assign(postID, to: nil) }
                }
            }
        }
    }

    private var columnFooter: some View {
        HStack(spacing: 10) {
            Spacer(minLength: 4)
            let chapters = structure.chaptersActive ? structure.sections.count : 0
            Text(tokens.chromeLabel(
                chapters > 0
                    ? "\(chapters) chapters · \(model.entries.count) notes"
                    : "\(model.entries.count) notes"))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(tokens.card)
        .overlay(alignment: .top) { Divider().overlay(tokens.line) }
    }

    // MARK: The pane (projection tier — P3, zero TK2 geometry)

    private var pane: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    ForEach(groups, id: \.id) { group in
                        if let title = group.title {
                            Text(tokens.chromeLabel(title))
                                .font(tokens.title)
                                .foregroundStyle(tokens.accent)
                                .padding(.top, 26)
                                .id("bip-sec-\(group.id)")
                        }
                        ForEach(group.entries, id: \.postID) { entry in
                            BookIndexPaneNote(
                                session: session, tokens: tokens, entry: entry,
                                selected: selectedPostID == entry.postID,
                                onTap: { select(entry.postID, scrollPane: false) },
                                onEdit: { onEditInOutline(entry.postID) })
                                .id("bip-\(entry.postID)")
                        }
                    }
                }
                .frame(maxWidth: 640, alignment: .leading)
                .padding(.horizontal, 34)
                .padding(.vertical, 26)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .background(tokens.surface)
            .onChange(of: paneTarget) { _, target in
                // One address grammar: a note target is its postID, a
                // chapter target arrives as "sec-<group id>" — both land
                // under the pane's "bip-" prefix.
                guard let target else { return }
                withAnimation { proxy.scrollTo("bip-\(target)", anchor: .top) }
                paneTarget = nil
            }
        }
    }
}

// MARK: - One column note row (selection wash, hover-waking doors)

private struct BookIndexNoteRow: View {
    let tokens: VoiceTokens
    let entry: Queries.ReadingEntry
    let nested: Bool
    let selected: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void
    let menu: () -> AnyView

    @State private var hovering = false

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            if selected, !tokens.selectionMarker.isEmpty {
                Text(tokens.selectionMarker.trimmingCharacters(in: .whitespaces))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
            }
            Text(entry.displayTitle)
                .font(tokens.small)
                .foregroundStyle(tokens.ink)
                .lineLimit(1)
            if let date = entry.entryDate {
                Text(date)
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
            }
            Spacer(minLength: 4)
            Menu("⋯") { menu() }
                .menuStyle(.borderlessButton)
                .fixedSize()
                .controlSize(.mini)
                .opacity(hovering || selected ? 1 : 0.25)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .padding(.leading, nested ? 14 : 0)
        .background(
            selected ? AnyShapeStyle(tokens.wash) : AnyShapeStyle(.clear),
            in: RoundedRectangle(cornerRadius: 8))
        .contentShape(Rectangle())
        .onTapGesture(count: 2) { onEdit() }
        .onTapGesture { onSelect() }
        .onHover { hovering = $0 }
        .help("Click to show this note in the pane; double-click to edit it "
            + "in Outline")
    }
}

// MARK: - One rendered note of the pane

/// A note as read-cheap prose in the VOICE (the note Index pane's grammar —
/// the paper look stays Read's). Lazy: the text loads when the LazyVStack
/// realizes the row (cost ∝ viewport, the FlowPostView shape).
private struct BookIndexPaneNote: View {
    let session: AppSession
    let tokens: VoiceTokens
    let entry: Queries.ReadingEntry
    let selected: Bool
    let onTap: () -> Void
    let onEdit: () -> Void

    @State private var paragraphs: [FlowParagraph] = []

    init(
        session: AppSession, tokens: VoiceTokens, entry: Queries.ReadingEntry,
        selected: Bool, onTap: @escaping () -> Void, onEdit: @escaping () -> Void
    ) {
        self.session = session
        self.tokens = tokens
        self.entry = entry
        self.selected = selected
        self.onTap = onTap
        self.onEdit = onEdit
        #if DEBUG
        BookIndexMaterialization.count += 1
        #endif
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(entry.displayTitle)
                    .font(tokens.heading)
                    .foregroundStyle(tokens.ink)
                if let date = entry.entryDate {
                    Text(date)
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                }
            }
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, paragraph in
                Text(paragraph.text)
                    .font(font(paragraph))
                    .foregroundStyle(tokens.ink)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, paragraph.indent)
            }
            if paragraphs.isEmpty {
                Text(" ").font(tokens.body)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            selected ? AnyShapeStyle(tokens.wash) : AnyShapeStyle(.clear),
            in: RoundedRectangle(cornerRadius: 8))
        .contentShape(Rectangle())
        .onTapGesture(count: 2) { onEdit() }
        .onTapGesture { onTap() }
        .environment(\.openURL, OpenURLAction { url in
            MarkdownLink.open(url.absoluteString) ? .handled : .discarded
        })
        .help("Click to select; double-click to edit this note in Outline")
        .task(id: entry.postID) {
            let text: String? = try? await session.database.read { [id = entry.postID] db in
                let slots = try Queries.renderPost(db, containerID: id)
                return Queries.joinRenderedTexts(slots.compactMap(\.text))
            }
            paragraphs = FlowParagraph.paragraphs(of: text ?? "", codeTint: tokens.codeTint)
        }
    }

    private func font(_ paragraph: FlowParagraph) -> Font {
        switch paragraph.style {
        case .heading(let level):
            level == 1 ? tokens.title : tokens.heading
        case .body, .bullet, .checkbox:
            tokens.body
        }
    }
}
