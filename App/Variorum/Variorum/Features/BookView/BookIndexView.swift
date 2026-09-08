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
//  Liveness (the Act 10 correction round, row 22 — her R-cor-7 ruling:
//  "book will also have the same thing for index"): the pane is a
//  projection tier (SwiftUI `Text` per block, virtualized per note) and
//  upgrades ONLY the clicked block to THE one live pane — the TOC's
//  read-cheap→live split through `BookIndexEditModel`'s single
//  `PaneTextAuthority` (P-3; one ring across every note the pane realizes).
//  The double-click handoff to Outline is retired; "Show in Outline" stays
//  a navigation in the row menu. A Read ▸ Scroll click lands HERE at its
//  block (row 38's door — `LandingTarget`).
//

import GRDB // AsyncValueObservation iteration
import SwiftUI
import VariorumCore

// MARK: - The pure column brain

/// The index column's flattening — groups (real chapters, tag-path runs,
/// or one flat run) folded and filtered into the rows the column draws.
/// Pure so the fold/filter behavior is pinned, not observed
/// (`BookIndexColumnTests`).
#if DEBUG
/// Row 21's oracle (17o batch d): the two trailing glyphs' frames, in the
/// window's own space — "the chapter count lines up with the ⋯" is a claim
/// about two rectangles, held the way rows 58/80 hold the masthead's.
@MainActor
enum BookIndexGeometry {
    static var chapterCountFrame: CGRect?
    static var noteMenuFrame: CGRect?
    /// 18d batch 3 (her U-13): what the CHAPTER PANEL drew — the rectangle,
    /// never `idealWidth`. Keyed by the BOOK's id: suites run in parallel,
    /// so a pin must read ITS book's panel, not the last one drawn anywhere.
    static var columnFrames: [String: CGRect] = [:]

    static func reset() {
        chapterCountFrame = nil
        noteMenuFrame = nil
        columnFrames = [:]
    }
}
#endif

nonisolated enum BookIndexColumn {
    /// **The ONE trailing column both row kinds end in** (17o batch d,
    /// ledger row 21; her punchlist 5, image 7). The chapter row's count was
    /// a bare `Text` flush against the row's padding while the note row's
    /// `Menu` reserved room for a disclosure chevron, so the two glyphs
    /// ended at different x. A shared column is the calm fix: neither row
    /// has to know what the other draws.
    static let trailingColumn: CGFloat = 22

    /// **The column's room** (18d batch 3, her U-13 — the twin of
    /// `BookNavigatorLayout`'s). Its OWN remembered width: this panel and
    /// the navigator stand in the same slot but are not the same panel (a
    /// filter field and a per-row count live here), so each remembers where
    /// she left it and dragging one never moves the other.
    static let widthKey = "bookIndexColumnWidth"
    /// Where it starts — exactly the shipped 300, so nothing moves until
    /// she drags.
    static let idealWidth: CGFloat = 300
    static let minimumWidth: CGFloat = 240
    static let maximumWidth: CGFloat = 460

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
    /// Show this note focused in OUTLINE (a navigation door in the row
    /// menu since the correction round — editing happens HERE now).
    let onEditInOutline: (String) -> Void

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    /// The pane's ONE liveness authority (row 22).
    @State private var edit: BookIndexEditModel
    @State private var selectedPostID: String?
    @State private var collapsed: Set<String> = []
    @State private var filter = ""
    /// Two one-shot scroll channels, one consumer each (the wave's own
    /// lesson from the note Index: two consumers of one nil-after-scroll
    /// request race each other).
    @State private var paneTarget: String?
    @State private var columnTarget: String?
    @State private var seeded = false

    init(
        session: AppSession, model: BookViewModel, structure: BookStructureModel,
        @ViewBuilder masthead: @escaping () -> Masthead,
        onEditInOutline: @escaping (String) -> Void
    ) {
        self.session = session
        self.model = model
        self.structure = structure
        self.masthead = masthead
        self.onEditInOutline = onEditInOutline
        _edit = State(initialValue: BookIndexEditModel(session: session))
    }

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }
    /// 17o batch c (her U-7): the editing indicator this surface pushes
    /// into every pane it composes — ONE resolution, in `ThemeStore`.
    private var indicator: EditingIndicatorStyle {
        ThemeStore.editingIndicator(of: themeStore)
    }

    private var groups: [BookIndexColumn.Group] {
        structure.chaptersActive
            ? BookIndexColumn.groups(chapters: structure.grouped(entries: model.entries))
            : BookIndexColumn.groups(flat: model.entries)
    }

    var body: some View {
        // **18d batch 3 (her U-13): the index's chapter panel is the same
        // leading side column.** Her ruling is about *"the panel with the
        // chapter names"*, and the book has that panel in TWO places: the
        // navigator in every other mode, and — by wave 2c's own rule, where
        // *"the index column IS the outline pane grown up"* and the minimal
        // navigator steps aside — this column in Index. Leaving one
        // draggable and its twin a fixed slab would make one tab row behave
        // two ways, and this column truncates the same chapter names hers
        // did (*"The Adventure of the Engineer's T…"*, measured at the walk).
        // Its own key and its own ideal, not the navigator's: it starts
        // wider (300) because it carries a filter field and a count beside
        // every row, and dragging one panel must not move the other.
        SideColumn(
            tokens: tokens,
            shown: true,
            widthKey: BookIndexColumn.widthKey,
            edge: .leading,
            ideal: BookIndexColumn.idealWidth,
            minimum: BookIndexColumn.minimumWidth,
            maximum: BookIndexColumn.maximumWidth
        ) {
            pane
        } panel: {
            column
                .onGeometryChange(for: CGSize.self) { $0.size } action: { size in
                    #if DEBUG
                    BookIndexGeometry.columnFrames[model.readingID] =
                        CGRect(origin: .zero, size: size)
                    #endif
                }
        }
        .background(tokens.surface)
        .onAppear {
            landOrSeed()
            // 18d batch 1: the index's LIVE note reaches the book the same
            // way its selection does — the sidebar's note box needs an
            // answer in every editing mode, and this mode's liveness is its
            // own pane's, never the book's focus (P-3).
            model.noteIndexLive(edit.livePostID)
        }
        .onChange(of: model.pendingReveal) { _, _ in landOrSeed() }
        .onChange(of: model.entries) { _, _ in landOrSeed() }
        .onChange(of: edit.livePostID) { _, live in model.noteIndexLive(live) }
        // Leaving the index releases its ring (the one live pane), flushing
        // whatever it held — the same discipline every pane host follows.
        .onDisappear {
            edit.teardown()
            model.noteIndexLive(nil)
            model.noteIndexSelection(nil)
        }
    }

    /// Arrive where she was: the carry's parked reveal wins; else the
    /// book's standing place; else the first note. One-shot. A
    /// BLOCK-precise landing (row 38 — the Read click) rides the reveal:
    /// the note is selected and shown, and its block goes live once the
    /// note's rows are in hand.
    private func landOrSeed() {
        if let reveal = model.pendingReveal,
           model.entries.contains(where: { $0.postID == reveal }) {
            let landing = model.pendingLanding
            model.consumeReveal()
            seeded = true
            if let landing { edit.requestLiveBlock(landing) }
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
        // 18d batch 1: the sidebar note box's question is a different one —
        // "is a note selected right now" — and the ARRIVAL's own seed
        // answers it yes while deliberately writing no carry anchor. So the
        // selection is reported every time, `report` or not.
        model.noteIndexSelection(postID)
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
                // Row 21 (her punchlist 5, image 7): the count and the note
                // rows' ⋯ end in ONE trailing column, so the two line up.
                .frame(width: BookIndexColumn.trailingColumn, alignment: .trailing)
                #if DEBUG
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                    BookIndexGeometry.chapterCountFrame = $0
                }
                #endif
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
            menu: { AnyView(chapterFilingMenu(entry.postID)) })
            .id("bix-\(entry.postID)")
    }

    /// The row menu — a navigation to Outline, the full editor, and the
    /// chapter-filing doors the outline rows carry (curated books only;
    /// QUESTIONS #25(a)).
    @ViewBuilder
    private func chapterFilingMenu(_ postID: String) -> some View {
        Button("Show in Outline") { onEditInOutline(postID) }
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

    // MARK: The pane (projection tier — P3; ONE live block on click)

    /// One lazy item of the pane — a heading or a note — whose identity IS
    /// its landing anchor (the Outline lesson of this round: `scrollTo`
    /// reaches an unrealized lazy row only through the ForEach identity).
    private enum PaneRow: Identifiable {
        case heading(BookIndexColumn.Group)
        case note(Queries.ReadingEntry)

        var id: String {
            switch self {
            case .heading(let group): "bip-sec-\(group.id)"
            case .note(let entry): "bip-\(entry.postID)"
            }
        }
    }

    private var paneRows: [PaneRow] {
        var rows: [PaneRow] = []
        for group in groups {
            if group.title != nil { rows.append(.heading(group)) }
            rows.append(contentsOf: group.entries.map { .note($0) })
        }
        return rows
    }

    private var pane: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6) {
                    ForEach(paneRows) { row in
                        switch row {
                        case .heading(let group):
                            Text(tokens.chromeLabel(group.title ?? ""))
                                .font(tokens.title)
                                .foregroundStyle(tokens.accent)
                                .padding(.top, 26)
                        case .note(let entry):
                            BookIndexPaneNote(
                                session: session, tokens: tokens,
                                indicator: indicator, entry: entry,
                                edit: edit,
                                selected: selectedPostID == entry.postID,
                                onTap: { select(entry.postID, scrollPane: false) },
                                onLandedBlock: { blockID in paneTarget = blockID })
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
                // chapter target arrives as "sec-<group id>", a landed
                // BLOCK as its blockID — all under the pane's "bip-" prefix.
                // No animation (the Outline lesson: an animated scrollTo
                // toward lazy estimates travels wrong).
                guard let target else { return }
                proxy.scrollTo("bip-\(target)", anchor: .top)
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
                // Row 21, THE mechanism: a borderless menu draws a disclosure
                // chevron and reserves room for it INSIDE its own control, so
                // the ⋯ sat several points inboard of the chapter count above
                // it while the two boxes ended at the same x — which is why
                // her eye saw it and a frame comparison could not. Hidden
                // here, the control is the glyph alone (measured: 28.0 pt →
                // 15.0 pt, inside a 22-pt column).
                .menuIndicator(.hidden)
                .fixedSize()
                .controlSize(.mini)
                .opacity(hovering || selected ? 1 : 0.25)
                #if DEBUG
                // Probed on the NATURAL control, before the shared column,
                // because its WIDTH is the claim: the chevron's reserved room
                // is what moved the glyph.
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: {
                    BookIndexGeometry.noteMenuFrame = $0
                }
                #endif
                .frame(width: BookIndexColumn.trailingColumn, alignment: .trailing)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .padding(.leading, nested ? 14 : 0)
        .background(
            selected ? AnyShapeStyle(tokens.wash) : AnyShapeStyle(.clear),
            in: RoundedRectangle(cornerRadius: 8))
        .contentShape(Rectangle())
        .onTapGesture { onSelect() }
        .onHover { hovering = $0 }
        .help("Click to show this note in the pane — then click into any of "
            + "its blocks to write")
    }
}

// MARK: - One rendered note of the pane

/// A note as read-cheap prose in the VOICE (the note Index pane's grammar —
/// the paper look stays Read's). Lazy: the rows load when the LazyVStack
/// realizes the note (cost ∝ viewport, the FlowPostView shape) — and they
/// are OBSERVED, because since the correction round (row 22) any block
/// here can be written in: a click makes that block THE live pane
/// (`BookIndexEditModel`, one authority for the whole book), every other
/// block stays `Text`. Locked takes stay read.
private struct BookIndexPaneNote: View {
    let session: AppSession
    let tokens: VoiceTokens
    /// 17o batch c (her U-7): carried to the note's live pane.
    let indicator: EditingIndicatorStyle
    let entry: Queries.ReadingEntry
    let edit: BookIndexEditModel
    let selected: Bool
    let onTap: () -> Void
    /// A landing made a block live here — the pane may scroll to it.
    let onLandedBlock: (String) -> Void

    @State private var rows: [Queries.TOCRow] = []

    init(
        session: AppSession, tokens: VoiceTokens,
        indicator: EditingIndicatorStyle, entry: Queries.ReadingEntry,
        edit: BookIndexEditModel, selected: Bool,
        onTap: @escaping () -> Void, onLandedBlock: @escaping (String) -> Void
    ) {
        self.session = session
        self.tokens = tokens
        self.indicator = indicator
        self.entry = entry
        self.edit = edit
        self.selected = selected
        self.onTap = onTap
        self.onLandedBlock = onLandedBlock
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
            .contentShape(Rectangle())
            .onTapGesture { onTap() }
            ForEach(rows, id: \.blockID) { row in
                blockView(row)
                    .id("bip-\(row.blockID)")
            }
            if rows.isEmpty {
                Text(" ").font(tokens.body)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            selected ? AnyShapeStyle(tokens.wash) : AnyShapeStyle(.clear),
            in: RoundedRectangle(cornerRadius: 8))
        .environment(\.openURL, OpenURLAction { url in
            MarkdownLink.open(url.absoluteString) ? .handled : .discarded
        })
        .help("Click a block to write in it right here — one block is live at a time")
        // A landing that arrives while this note is already realized (its
        // rows long loaded) is taken here — the observation below takes the
        // one that arrives BEFORE the rows.
        .onChange(of: edit.pendingLiveBlock) { _, pending in
            guard pending?.postID == entry.postID, !rows.isEmpty else { return }
            if let landed = edit.takePendingLiveBlock(postID: entry.postID, rows: rows) {
                onLandedBlock(landed)
            }
        }
        .task(id: entry.postID) {
            do {
                for try await value in session.database.observeBlockTOC(entry.postID) {
                    rows = value
                    edit.settle()
                    if let landed = edit.takePendingLiveBlock(postID: entry.postID, rows: value) {
                        onLandedBlock(landed)
                    }
                }
            } catch is CancellationError {
            } catch {
                session.status.speak(OpsRefusalCopy.message(for: error))
            }
        }
    }

    /// One block: THE live pane when it is the clicked one, else its
    /// rendered paragraphs (a click on them is the upgrade).
    @ViewBuilder
    private func blockView(_ row: Queries.TOCRow) -> some View {
        let text = edit.displayText(variantID: row.variantID, storeText: row.text)
        if let variantID = row.variantID,
           edit.isLive(postID: entry.postID, blockID: row.blockID, variantID: variantID),
           !row.variantLocked {
            PaneSurfaceView(
                text: text,
                isLive: true,
                tokens: tokens,
                indicator: indicator,
                role: BookIndexEditModel.columnID, variantID: variantID,
                onFocusRequest: {
                    edit.makeLive(postID: entry.postID, blockID: row.blockID, variantID: variantID)
                },
                onEdit: { newText in
                    edit.paneEdited(
                        postID: entry.postID, variantID: variantID,
                        oldText: row.text ?? "", newText: newText)
                })
                .padding(6)
                // 17o batch c (row 6): the book index's own live frame
                // consumes the ONE rule (see `ReadEditPane`).
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(
                            PaneDecoration.hostRing(
                                indicator: indicator, tokens: tokens) ?? .clear,
                            lineWidth: 1))
        } else {
            let paragraphs = FlowParagraph.paragraphs(of: text, codeTint: tokens.codeTint)
            VStack(alignment: .leading, spacing: 8) {
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
            .padding(6)
            .contentShape(Rectangle())
            .onTapGesture {
                guard let variantID = row.variantID, !row.variantLocked else { return }
                onTap()
                edit.makeLive(postID: entry.postID, blockID: row.blockID, variantID: variantID)
            }
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
