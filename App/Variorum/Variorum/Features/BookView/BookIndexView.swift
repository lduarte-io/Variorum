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
    /// **13u2 UNIT B (her item 19): the rectangle the SELECTED note's wash
    /// actually covers, and the note's own height beside it.** *"I don't want
    /// the whole note i'm editing to be that color"* is a claim about two
    /// rectangles, so the pin reads the rectangles. Keyed by the NOTE's id
    /// (the subject-keyed rule, KnownIssues row 50).
    static var paneSelectionWashHeights: [String: CGFloat] = [:]
    static var paneNoteHeights: [String: CGFloat] = [:]
    /// **13u2 UNIT B (her item 19): where a block's PROSE starts, per tier.**
    /// *"the text indents in index mode where you're editing it"* is a claim
    /// about one x, measured the same way in both tiers: the read tier reports
    /// its text column's own leading edge, the live tier its pane's plus the
    /// pane's MEASURED internal inset (`PaneTextView.proseLeadingInset`).
    /// Keyed by the BLOCK's id (the subject-keyed rule).
    static var paneProseLeading: [String: CGFloat] = [:]
    /// **13u4 UNIT F1 (her item 10): where every PANE ROW's top sits**, in the
    /// pane scroll's own space — visible-relative, so a row landed at the top
    /// reads ≈ 0 and a landing that missed reads the distance it missed by.
    /// Keyed by the row's anchor (`PaneRow.id`, the subject-keyed rule).
    /// The claim *"clicking a chapter brings you to that chapter"* is a claim
    /// about one number, so the pin reads that number.
    static var paneAnchorTops: [String: CGFloat] = [:]
    /// **13u4 UNIT F1: the landing's own story**, the Outline's
    /// `BookOutlineGeometry.trace` on this surface — the LAND line, the
    /// hops, the content moves and the sentence it ended on. DEBUG only; the
    /// shipping build carries the content-free `LandingSignpost` line instead.
    static var trace: [String] = []
    /// **13u4 UNIT F3: how far the whole COLUMN moved while it was loading** —
    /// the lowest and the highest content height the pane ever reported, and
    /// how many times it reported. F1's stop-and-reported residual IS this
    /// span: on a cold column it measured 39k → 56k → 143k → 80k → 115k points
    /// inside six seconds, because a pane row is a whole NOTE standing at
    /// ~40 pt until `observeBlockTOC` returns and at thousands afterwards. So
    /// *"the column's geometry is approximately honest before any text
    /// arrives"* is a claim about this span, and the pin reads this span.
    /// Keyed by the BOOK's id (the subject-keyed rule, KnownIssues row 50 —
    /// suites run in parallel, so a pin must read ITS book's column).
    static var paneContentSpans: [String: BookIndexContentSpan] = [:]

    static func reset() {
        trace = []
        chapterCountFrame = nil
        noteMenuFrame = nil
        columnFrames = [:]
        paneProseLeading = [:]
        paneSelectionWashHeights = [:]
        paneNoteHeights = [:]
        paneAnchorTops = [:]
        paneContentSpans = [:]
    }
}

/// 13u4 UNIT F3: one column's reported-height span (see `paneContentSpans`).
nonisolated struct BookIndexContentSpan: Equatable, Sendable {
    var low: CGFloat
    var high: CGFloat
    var reports: Int

    /// How many times taller the column ever got than the smallest it ever
    /// said it was — the oscillation as ONE number. 1 would be a column that
    /// never moved; F1 measured this surface's cold column in the tens.
    var growth: CGFloat { low > 0 ? high / low : .greatestFiniteMagnitude }
}
#endif

/// 13u2 UNIT B: what the selection probe observes. The observed value carries
/// the SELECTION as well as the height, because a geometry action fires on a
/// VALUE change and the header's height is the same before and after the wash
/// appears — a height-only probe would never write while `selected` is true.
#if DEBUG
nonisolated struct BookIndexWashReport: Equatable, Sendable {
    var height: CGFloat
    var selected: Bool
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
    /// **The PANE scroll's named space** (13u4 UNIT F1; the Outline's
    /// `outlineSpace`): a row's frame read in it is VISIBLE-relative, so "this
    /// anchor is at the top of the page" is `minY ≈ 0` and nothing has to know
    /// the content's own offset. It lives here rather than on the view because
    /// `BookIndexView` is generic in its masthead and a generic type holds no
    /// static storage.
    static let paneSpace = "book-index-pane-scroll"
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

    /// **THE ONE LANDING AUTHORITY** (13u4 UNIT F1 — `Surface/LandingAuthority.swift`).
    /// The aim/hold/quiet/hop discipline that the book Outline and the reading
    /// flow adopted at 13u2b; this surface is the third adopter and the reason
    /// is her item 10 — the pane used to aim ONCE, at whatever a lazy column's
    /// estimate said, and never look again (measured: 11 of 20 chapter clicks
    /// landed in a different story; one left the page blank; none corrected
    /// itself in six seconds). What this surface keeps is its own ACT (the
    /// scroll) and its own facts; the watching is the authority's.
    #if DEBUG
    @State private var landing = LandingAuthority(
        policy: .bookIndex,
        storyboard: LandingStoryboard(
            note: { BookIndexGeometry.trace.append($0) },
            dump: {
                // A landing's story is only this landing's — print from the
                // last line that ENDS in " LAND" (the Outline's own lesson,
                // met on its walk when every landing printed the session).
                let start = BookIndexGeometry.trace
                    .lastIndex(where: { $0.hasSuffix(" LAND") }) ?? 0
                return BookIndexGeometry.trace[start...].joined(separator: " | ")
            }))
    #else
    @State private var landing = LandingAuthority(policy: .bookIndex)
    #endif

    /// The pane's own page bookkeeping — NOT render state, so it lives in a
    /// reference box a `@State` merely holds and its mutations invalidate
    /// nothing (the Outline's `OutlineLandingBox` rule, and the reason for it:
    /// a `@State` write on every content report re-lays the lazy column out,
    /// which is one more content report — a loop of the landing's own making).
    @MainActor private final class PaneLandingBox {
        /// The column's last reported content height — the signpost's `total`.
        var contentHeight: CGFloat = 0
    }
    @State private var paneBox = PaneLandingBox()

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
            subjectKey: model.readingID,
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
            // **13u4 UNIT F3: the lengths, before the first landing.** ONE
            // bounded statement for the book, shared through the book's cache
            // with the Outline and the reading flow — so a mode switch
            // re-reads nothing, and nothing at autosave rate reaches it.
            model.ensureIndexExtents()
            landOrSeed()
            // 18d batch 1: the index's LIVE note reaches the book the same
            // way its selection does — the sidebar's note box needs an
            // answer in every editing mode, and this mode's liveness is its
            // own pane's, never the book's focus (P-3).
            model.noteIndexLive(edit.livePostID)
        }
        .onChange(of: model.pendingReveal) { _, _ in landOrSeed() }
        .onChange(of: model.entries) { _, _ in
            // A changed membership is a changed entry set, which is the one
            // key the lengths cache compares on.
            model.ensureIndexExtents()
            landOrSeed()
        }
        // **NO SELECTION-FOLLOW HERE, and the reason is measured** (13u2
        // UNIT B, her item 19). The note surface's column needed one — its
        // rows are BLOCKS and a ring could move without the column hearing.
        // This column's rows are NOTES, and every road that makes a note's
        // block live already selects that note: the row's own tap does, and a
        // landing runs through `landOrSeed`, which selects the revealed note
        // before the pane makes its block live. A follow added here was
        // therefore HOLLOW — and worse than hollow: writing the selection from
        // inside the observation update that made the pane live tore the
        // index's own state down and the live pane vanished
        // (`theReadClickLandsInIndexAtThatBlock` read ZERO editable panes,
        // isolated and reproducible, with and without a next-turn deferral).
        .onChange(of: edit.livePostID) { _, live in model.noteIndexLive(live) }
        // Leaving the index releases its ring (the one live pane), flushing
        // whatever it held — the same discipline every pane host follows.
        .onDisappear {
            edit.teardown()
            model.noteIndexLive(nil)
            model.noteIndexSelection(nil)
            // 13u4 UNIT F1: a landing in flight ends with the surface rather
            // than re-arming its check against a dead proxy (the 13u2b
            // ladder's R2-12 class). Silent by the authority's own rule —
            // nothing landed and the surface is gone.
            landing.end()
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

    /// A pane ROW reported where its top sits — the landing's own evidence,
    /// and the seed that makes a landing on the row the page is ALREADY at
    /// terminate (`LandingAuthority.tops`: `onGeometryChange` reports a
    /// CHANGE, so a scroll that moves nothing says nothing, and without the
    /// seed that reads as "the target never realized").
    private func paneAnchorMoved(_ anchorID: String, top: CGFloat) {
        #if DEBUG
        BookIndexGeometry.paneAnchorTops[anchorID] = top
        if landing.anchor == anchorID {
            BookIndexGeometry.trace.append("\(anchorID) top=\(top) hops=\(landing.corrections)")
        } else if landing.isPending {
            // Every OTHER row that moves while a landing is in flight, short
            // form. This is the line that showed the column thrashing under
            // the landing — the target silent while its neighbours slid by
            // thousands of points — and without it the residual below would
            // have been a guess instead of a measurement.
            BookIndexGeometry.trace.append("row \(anchorID.suffix(4)) top=\(Int(top))")
        }
        #endif
        landing.noteTop(anchorID, top)
    }

    /// A BLOCK inside a realized note reported where it sits — the third kind
    /// of pane anchor (the Read ▸ Scroll click-through's target, row 38).
    ///
    /// **Gated on the pending landing, deliberately**, where a ROW's report is
    /// not: a realized story is hundreds of blocks and every one of them
    /// reports on every layout change, so recording them all would grow the
    /// authority's seed by the corpus rather than by the rows it lands on.
    /// What the gate keeps is exactly what is needed — a block that was landed
    /// on once keeps its seed afterwards, because the authority records the
    /// top it is handed.
    private func paneBlockAnchorMoved(_ anchorID: String, top: CGFloat) {
        guard landing.anchor == anchorID else { return }
        #if DEBUG
        BookIndexGeometry.paneAnchorTops[anchorID] = top
        BookIndexGeometry.trace.append("\(anchorID) top=\(top) hops=\(landing.corrections)")
        #endif
        landing.noteTop(anchorID, top)
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
            onSelect: {
                // **A COLUMN CLICK IS NAVIGATION** (13u2 UNIT B, her item 19 —
                // PROVISIONAL, QUESTIONS #110; the note surface's twin rule).
                // A row naming a DIFFERENT note than the live pane's releases
                // the ring, so the column's mark and the editing cursor can
                // never point at two different notes.
                if let live = edit.livePostID, live != entry.postID { edit.blur() }
                select(entry.postID, scrollPane: true)
            },
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

        /// 13u4 UNIT F3: whose LENGTHS answer this row's height — nil for a
        /// chapter heading, whose height is a constant per voice and width.
        var postID: String? {
            switch self {
            case .heading: nil
            case .note(let entry): entry.postID
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
                // **13u4 UNIT F3: a plain `VStack`, and each row virtualizes
                // ITSELF at a height the manifest knows** — 13u2b UNIT 1's
                // shape (AR-1's ruling) on this surface, which is the other
                // half of the answer UNIT F1 adopted only the first half of.
                // A lazy container answers "how tall is a row I have not
                // realized" with the AVERAGE of the ones it has, and here a
                // row is a whole NOTE standing at ~40 pt until its text
                // arrives — so the column's own height oscillated by tens of
                // thousands of points while a landing was in flight and
                // 6 of 6 cold chapter clicks gave up. A height the column
                // ASSERTS cannot do that.
                VStack(alignment: .leading, spacing: BookIndexPaneHeights.rowSpacing) {
                    ForEach(paneRows) { row in
                        IndexPaneRow(
                            anchorID: row.id, postID: row.postID, model: model,
                            armed: row.postID == nil || model.indexExtentsKnown,
                            onTop: { top in paneAnchorMoved(row.id, top: top) }
                        ) {
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
                                    reserved: model.indexPaneRowHeight(
                                        row.id, postID: entry.postID),
                                    onTap: { select(entry.postID, scrollPane: false) },
                                    onLandedBlock: { blockID in paneTarget = blockID },
                                    onBlockTop: paneBlockAnchorMoved,
                                    onMeasured: { height in
                                        model.learnIndexPaneRowHeight(
                                            row.id, height: height, isHeading: false)
                                    })
                            }
                        }
                    }
                }
                .frame(maxWidth: 640, alignment: .leading)
                // **13u4 UNIT F3: the pane's own measure**, so the heights are
                // derived at the width the prose really wraps at. Written only
                // when it moves (the model's 1-pt tolerance).
                .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width in
                    model.reportIndexContentWidth(width)
                }
                .padding(.horizontal, 34)
                .padding(.vertical, 26)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .coordinateSpace(name: BookIndexColumn.paneSpace)
            .background(tokens.surface)
            // **13u4 UNIT F1: the landing listens to the WHOLE column.** Any
            // change in the content's height re-arms the quiet interval — on
            // this surface that is a note's text arriving from the store, which
            // is the single biggest thing that can move a target (a row is ~40
            // pt until its blocks land and thousands afterwards) — and a scroll
            // by HER ends the landing where she put the page.
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentSize.height
            } action: { _, height in
                paneBox.contentHeight = height
                #if DEBUG
                // 13u4 UNIT F3's probe: behaviour-free — it reads the value the
                // line above already wrote, and writes only to the oracle.
                if height > 1 {
                    var span = BookIndexGeometry.paneContentSpans[model.readingID]
                        ?? BookIndexContentSpan(low: height, high: height, reports: 0)
                    span.low = min(span.low, height)
                    span.high = max(span.high, height)
                    span.reports += 1
                    BookIndexGeometry.paneContentSpans[model.readingID] = span
                }
                #endif
                landing.contentChanged(height)
            }
            // **The DEBUG story's second reading, and it earned its place:** the
            // OFFSET beside the reports. A landing that ends wrong looks the
            // same in the story whether its corrections moved the page or did
            // nothing at all, and telling those two apart is what decided this
            // unit's policy (the corrections DO move it — 45k → 95k — which is
            // why the shipped policy refuses to make them blind). Never in
            // Release: one more observer on a scroll is not a thing to ship for
            // a story nobody reads there, and the content-free signpost is.
            #if DEBUG
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                geometry.contentOffset.y
            } action: { _, offset in
                if landing.isPending {
                    BookIndexGeometry.trace.append("offset=\(Int(offset))")
                }
            }
            #endif
            .onScrollPhaseChange { _, phase in
                if phase == .interacting { landing.userTookOver() }
            }
            .onChange(of: paneTarget) { _, target in
                // One address grammar: a note target is its postID, a
                // chapter target arrives as "sec-<group id>", a landed
                // BLOCK as its blockID — all under the pane's "bip-" prefix.
                // No animation (the Outline lesson: an animated scrollTo
                // toward lazy estimates travels wrong).
                guard let target else { return }
                paneTarget = nil
                land("bip-\(target)", proxy)
            }
        }
    }

    /// **Put a pane anchor at the top of the page, and watch it settle**
    /// (13u4 UNIT F1). What stays here is this surface's own act — the one
    /// unanimated `scrollTo` — and the facts only this surface knows; the
    /// hold, the quiet interval, the corrections, the watchdog and the
    /// content-free signpost are the authority's.
    private func land(_ anchorID: String, _ proxy: ScrollViewProxy) {
        landing.land(anchorID, facts: paneFacts(anchorID)) { id in
            proxy.scrollTo(id, anchor: .top)
        }
    }

    /// What this column can honestly say about a landing, as numbers.
    ///
    /// **13u4 UNIT F3: it can now say all of it.** UNIT F1 had to answer
    /// `offset=-1 derived=<every row> exact=0`, because this pane had no
    /// height manifest and not one row's height was known before it was
    /// realized. The rows stand at known heights now, so the facts come from
    /// the manifest exactly as the Outline's and the flow's do — and the
    /// signpost in her own Console says how much of the geometry above the
    /// thing she clicked was still arithmetic.
    ///
    /// The BLOCK road keeps the honest unknown: a landing whose target is a
    /// block INSIDE a note is not a row of this manifest, so its `offset` is
    /// −1 and its target index is the note's row. Stated rather than faked.
    private func paneFacts(_ anchorID: String) -> LandingFacts {
        let rows = paneRows
        let manifest = model.indexPaneManifest(
            rows: rows.map { (id: $0.id, postID: $0.postID) })
        if manifest.offset(of: anchorID) != nil {
            return LandingFacts(manifest: manifest, anchor: anchorID)
        }
        return LandingFacts(
            rows: rows.count,
            targetIndex: rows.firstIndex { $0.id == anchorID } ?? -1,
            offset: -1,
            total: manifest.totalHeight,
            derived: manifest.derivedCount,
            exactAbove: false)
    }
}

/// **One row of the Index PANE (13u4 UNIT F3): real near the viewport, a
/// manifest-height placeholder far from it — and its landing anchor either
/// way.**
///
/// This is `OutlineRunRow`'s shape (13u2b UNIT 1, AR-1's ruling) on this
/// surface, and it is here for a measured reason rather than for symmetry: the
/// pane's rows used to sit in a `LazyVStack`, which answers *"how tall is a
/// row I have not realized"* with the AVERAGE of the ones it has — and a row
/// here is a whole NOTE, ~40 pt until `observeBlockTOC` returns and thousands
/// afterwards. The column's own height therefore moved by tens of thousands of
/// points while a landing was in flight (measured: 39k → 143k → 80k in six
/// seconds), and the landing could only give up. A height the column ASSERTS
/// cannot do that.
///
/// **What it is NOT:** it is not the closed "one row scale per lazy run"
/// road, and it does not touch any liveness mechanism — the pane's ONE live
/// block is `BookIndexEditModel`'s (P-3), unchanged, and a note near the
/// viewport renders exactly what it rendered before. Anchors are kept on every
/// row, realized or not, so `scrollTo(id:)` is unchanged and no landing pin's
/// mechanism moves.
private struct IndexPaneRow<Content: View>: View {
    let anchorID: String
    /// nil ⇒ a chapter heading.
    let postID: String?
    let model: BookViewModel
    /// **May this row decide near or far yet?** (The flow's ladder R2-5, whose
    /// lesson this unit met the hard way: without it, EVERY row of a 24-note
    /// fixture decided "near" on the layout pass before any height was real
    /// and the whole book materialized — 20 of 24 notes, measured, which is
    /// the P3 shape `BookIndexMaterialization` exists to catch.) A heading is
    /// always honest; a NOTE is honest only once the book's lengths have
    /// landed, because before that it stands on the never-measured prior.
    let armed: Bool
    let onTop: (CGFloat) -> Void
    @ViewBuilder let content: () -> Content

    /// How far beyond the viewport a row still counts as near — generous, so
    /// a note is realized before it scrolls into view and released well after
    /// it leaves. The Outline's own number for its small rows; a pane row is
    /// heavier (it opens a TOC observation), so it is not made larger.
    static var nearMargin: CGFloat { 2000 }

    /// Starts false so a far row never renders real content for one frame;
    /// the row's own first geometry report decides (`OutlinePostRow`'s rule).
    @State private var near = false

    var body: some View {
        Group {
            if near {
                content()
            } else {
                Color.clear.frame(height: model.indexPaneRowHeight(anchorID, postID: postID))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .id(anchorID)
        // ONE geometry report, three readers — the landing converges on the
        // top, the column learns the height, and the row decides near or far.
        // The band's rule is `NearBand`'s, shared rather than copied (P-8):
        // at the window's 300-note cap a second observer per row would be
        // hundreds more of them.
        .onGeometryChange(for: IndexPaneRowGeometry.self) { geometry in
            let frame = geometry.frame(in: .named(BookIndexColumn.paneSpace))
            return IndexPaneRowGeometry(top: frame.minY, height: frame.height, armed: armed)
        } action: { geometry in
            // **Learn only from REAL content.** A near HEADING always renders
            // real content, so its report is a measurement. A near NOTE may
            // still be standing at its reservation while `observeBlockTOC` is
            // in flight, and learning THAT would promote arithmetic to a
            // measurement — the manifest's whole precedence, inverted — so a
            // note learns through its own door instead, which knows whether
            // its text has arrived.
            if near, postID == nil {
                model.learnIndexPaneRowHeight(anchorID, height: geometry.height, isHeading: true)
            }
            onTop(geometry.top)
            // A row whose height is not yet honest decides nothing — and
            // neither does one that has not been laid out at all (a zero-height
            // report reads as distance 0, which is "near", for every row in
            // the book at once).
            guard geometry.armed, geometry.height > 0 else { return }
            let distance = NearBand.distance(
                top: geometry.top, height: geometry.height, margin: Self.nearMargin)
            guard let becomesNear = NearBand.decide(
                distance: distance, near: near, margin: Self.nearMargin)
            else { return }
            // Never inside the layout pass that reported (the
            // state-during-update class — `NearViewportObserver`'s own rule).
            DispatchQueue.main.async { near = becomesNear }
        }
    }
}

/// What a pane row reports: where its top sits in the scroll's visible space,
/// and how tall it is. (The Outline's `OutlineAnchorGeometry` is the same pair,
/// file-private to its own; restated rather than hoisted because two
/// two-`CGFloat` structs are not a shared brain — what IS shared is the rule
/// that reads them, `NearBand`.)
nonisolated private struct IndexPaneRowGeometry: Equatable, Sendable {
    var top: CGFloat
    var height: CGFloat
    /// Ladder R2-5's rule on this surface (`NearViewportObserver.armed`): may
    /// this geometry be DECIDED on? It rides inside the observed value rather
    /// than beside it, so the moment arming flips the current distance is
    /// decided at once even though the geometry itself did not move.
    var armed: Bool
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
                // P-8 (R-13u4-5's sweep, 13u4 UNIT S3): a `fixedSize` chrome label
                // states its own line policy, so its IDEAL width can never be a
                // wrapped one (the b6dae25 class's window-sizing hazard).
                .lineLimit(1)
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
    /// This surface's resting padding (13u2 UNIT B) — what both tiers used to
    /// pad on every side, and still the trailing/bottom measure.
    static let resting = IndexProseColumn.bookIndexResting
    static let restingTop = IndexProseColumn.bookIndexRestingTop
    @MainActor static var readTierLeading: CGFloat {
        IndexProseColumn.readTierLeading(
            resting: resting, paneInset: PaneTextView.proseLeadingInset)
    }
    @MainActor static var livePaneLeading: CGFloat {
        IndexProseColumn.livePaneLeading(
            resting: resting, paneInset: PaneTextView.proseLeadingInset)
    }
    @MainActor static var readTierTop: CGFloat {
        IndexProseColumn.readTierTop(resting: restingTop, paneInset: PaneTextView.proseTopInset)
    }
    @MainActor static var livePaneTop: CGFloat {
        IndexProseColumn.livePaneTop(resting: restingTop, paneInset: PaneTextView.proseTopInset)
    }
    /// 13u4 UNIT F3: everything of this row that is NOT the block column — the
    /// title/date header with its padding, the body `VStack`'s gap under it,
    /// and the note's own vertical padding. The reservation is a whole-ROW
    /// height, so the placeholder that stands in for the prose owes this back.
    /// It is the model's `noteChrome` seen from the other side, and the two
    /// are the same measurement of the same surface.
    static let chromeAroundProse: CGFloat = 60

    let session: AppSession
    let tokens: VoiceTokens
    /// 17o batch c (her U-7): carried to the note's live pane.
    let indicator: EditingIndicatorStyle
    let entry: Queries.ReadingEntry
    let edit: BookIndexEditModel
    let selected: Bool
    /// **13u4 UNIT F3: what this note STANDS AT until its text arrives** — the
    /// manifest's answer for this row. Without it a realized-but-unloaded note
    /// is a title and a blank line (~40 pt) where a Sherlock story is nine
    /// thousand points, which is the whole of F1's residual: the column
    /// collapses under the rows it is realizing and the landing chases it.
    let reserved: CGFloat
    let onTap: () -> Void
    /// A landing made a block live here — the pane may scroll to it.
    let onLandedBlock: (String) -> Void
    /// 13u4 UNIT F1: where one of this note's BLOCKS sits, for a landing whose
    /// target is that block (the pane gates the report on its pending anchor).
    let onBlockTop: (String, CGFloat) -> Void
    /// 13u4 UNIT F3: this note reported its REAL height (its text has
    /// arrived). The row itself cannot tell a real report from a reservation,
    /// so the note that knows says so.
    let onMeasured: (CGFloat) -> Void

    @State private var rows: [Queries.TOCRow] = []
    /// Has `observeBlockTOC` come back at all? Distinguishes "not yet loaded"
    /// (stand at the reservation) from "loaded and genuinely empty" (stand at
    /// the blank line the body renders).
    @State private var loaded = false

    init(
        session: AppSession, tokens: VoiceTokens,
        indicator: EditingIndicatorStyle, entry: Queries.ReadingEntry,
        edit: BookIndexEditModel, selected: Bool, reserved: CGFloat,
        onTap: @escaping () -> Void, onLandedBlock: @escaping (String) -> Void,
        onBlockTop: @escaping (String, CGFloat) -> Void,
        onMeasured: @escaping (CGFloat) -> Void
    ) {
        self.session = session
        self.tokens = tokens
        self.indicator = indicator
        self.entry = entry
        self.edit = edit
        self.selected = selected
        self.reserved = reserved
        self.onTap = onTap
        self.onLandedBlock = onLandedBlock
        self.onBlockTop = onBlockTop
        self.onMeasured = onMeasured
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
            // **THE SELECTED NOTE'S MARK — its HEADER, never its body**
            // (13u2 UNIT B, her item 19, verbatim: *"in index, even when I
            // have a color mode on I don't want the whole note i'm editing to
            // be that color, it's too much."*)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                selected ? AnyShapeStyle(tokens.wash) : AnyShapeStyle(.clear),
                in: RoundedRectangle(cornerRadius: 6))
            #if DEBUG
            .onGeometryChange(for: BookIndexWashReport.self) {
                BookIndexWashReport(height: $0.size.height, selected: selected)
            } action: { report in
                if report.selected {
                    BookIndexGeometry.paneSelectionWashHeights[entry.postID] = report.height
                }
            }
            #endif
            .contentShape(Rectangle())
            .onTapGesture { onTap() }
            ForEach(rows, id: \.blockID) { row in
                // The anchor is built ONCE per row render, never inside the
                // geometry closure — that closure runs per realized block per
                // layout pass, and a string built there would be allocation
                // churn at scroll rate (P1's letter: cost ∝ realized rows, and
                // nothing per-row may be more than it has to be).
                let anchor = "bip-\(row.blockID)"
                blockView(row)
                    .id(anchor)
                    .onGeometryChange(for: CGFloat.self) { geometry in
                        geometry.frame(in: .named(BookIndexColumn.paneSpace)).minY
                    } action: { top in
                        onBlockTop(anchor, top)
                    }
            }
            if rows.isEmpty {
                // 13u4 UNIT F3: until the text arrives this note stands at
                // what the column says it is tall, not at one blank line. A
                // note that has LOADED and is genuinely empty keeps the blank
                // line — the reservation is for the waiting, never a floor.
                if loaded {
                    Text(" ").font(tokens.body)
                } else {
                    Color.clear.frame(height: max(0, reserved - Self.chromeAroundProse))
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height in
            #if DEBUG
            BookIndexGeometry.paneNoteHeights[entry.postID] = height
            #endif
            // 13u4 UNIT F3: a MEASUREMENT is what this note drew with its own
            // text in it. While it stands at the reservation it is reporting
            // the column's guess back to the column, so it says nothing.
            if loaded { onMeasured(height) }
        }
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
                    loaded = true
                    edit.settle()
                    if let landed = edit.takePendingLiveBlock(postID: entry.postID, rows: value) {
                        onLandedBlock(landed)
                    }
                }
            } catch is CancellationError {
            } catch {
                session.status.refuse(OpsRefusalCopy.message(for: error))
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
                #if DEBUG
                .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { frame in
                    BookIndexGeometry.paneProseLeading[row.blockID] =
                        frame.minX + PaneTextView.proseLeadingInset
                }
                #endif
                // 13u2 UNIT B (her item 19): the live pane's PROSE lands where
                // the read tier's did — the host pays back only the remainder
                // of the pane's own inset, so clicking into a block does not
                // step the text sideways (it stepped ~11 pt here, measured).
                .padding(.leading, Self.livePaneLeading)
                .padding(.trailing, Self.resting)
                .padding(.top, Self.livePaneTop)
                .padding(.bottom, Self.restingTop)
                // (17o batch c's host ring RETIRED at 13u2 UNIT B — the pane
                //  draws the indicator itself, so this was a second ring.)
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
            #if DEBUG
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .global) } action: { frame in
                BookIndexGeometry.paneProseLeading[row.blockID] = frame.minX
            }
            #endif
            // 13u2 UNIT B: the read tier's prose sits at the SAME column as
            // the live pane's (`IndexProseColumn`).
            .padding(.leading, Self.readTierLeading)
            .padding(.trailing, Self.resting)
            .padding(.top, Self.readTierTop)
            .padding(.bottom, Self.restingTop)
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
