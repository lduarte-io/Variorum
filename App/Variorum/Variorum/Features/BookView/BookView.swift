//
//  BookView.swift
//  Variorum
//
//  The continuous book view (Phase 10 Step 4; reworked Phase 13 B3): the
//  reading's posts in ONE continuous scroll with REAL CHAPTERS (R28/R50 —
//  reading_section rows, movable, superseding tag-path headers for curated
//  books), the terminal BOOK NAVIGATOR (R43: chapters · outline · settings;
//  clicking a post opens it IN the current editor — the inline focus, no
//  context jump; NO separate chapter view), and the READING FLOW mode
//  (R2 — direction C; a finished book opens into it). Unfocused posts
//  render read-cheap; exactly one upgrades to the live inline editor (P3).
//

import SwiftUI
import VariorumCore

struct BookView: View {
    let session: AppSession
    let readingID: String
    var readingName: String?
    @State private var model: BookViewModel
    @State private var structure: BookStructureModel

    /// `model` is injectable for tests (hosted `.task` appearance callbacks
    /// don't fire under the test host — tests drive `adopt` by hand).
    /// `initiallyExpanded`: an explicit un-collapse seed. Since 13c 2A a
    /// post reads OPEN by default in Outline (the model tracks the
    /// COLLAPSED set), so this is now a no-op for posts nobody collapsed —
    /// kept because it still says exactly what it does, and because a
    /// caller that seeds a collapsed set will want its twin.
    init(
        session: AppSession, readingID: String, readingName: String? = nil,
        model: BookViewModel? = nil,
        structure: BookStructureModel? = nil,
        initiallyExpanded: Set<String> = []
    ) {
        self.session = session
        self.readingID = readingID
        self.readingName = readingName
        let resolved = model ?? BookViewModel(session: session, readingID: readingID)
        for postID in initiallyExpanded { resolved.expand(postID) }
        _model = State(initialValue: resolved)
        // `structure` is injectable for the same reason `model` is (13c 2C):
        // a hosted test drives the view MODE from outside, and hosted
        // `.task` appearance callbacks don't fire under the test host.
        _structure = State(
            initialValue: structure
                ?? BookStructureModel(session: session, readingID: readingID))
    }

    // Optional: test hosts (and future embeddings) may lack the
    // environment — fall back to the leading voice's tokens.
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @State private var newChapterPresented = false
    @State private var chapterNameField = ""
    @State private var renameChapterTarget: ReadingSection?
    @State private var settingsShown = false

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// Outline's prose column (13c 2A): Write's own measure. The contained
    /// text surfaces carry `inlineSurfaceInset` on each side, so the text
    /// itself lands on exactly `EditorTypography.maxColumnWidth`.
    static let proseColumn =
        EditorTypography.maxColumnWidth + 2 * EditorTypography.inlineSurfaceInset

    var body: some View {
        HStack(spacing: 0) {
            navigator
            Divider().overlay(tokens.line)
            switch structure.mode {
            case .outline:
                outlineBody
            case .spread:
                // The picker's "Book" (13c 2A's rename, 2B's build): the
                // TWO-UP spread — each page a whole scrollable post, the
                // active one editable in Write or the takes stack (A43/A44).
                SpreadBookView(session: session, model: model, structure: structure)
            case .read:
                // READ is a PAIR (13c 2C, her direction): the vertical
                // infinite scroll, and true book pagination. Neither is
                // editable — her A43 ruling, which is what keeps Read a
                // place to read rather than a third editor.
                switch structure.readForm {
                case .flow:
                    ReadingFlowView(
                        session: session,
                        readingName: readingName ?? model.readingName,
                        grouped: structure.chaptersActive
                            ? structure.grouped(entries: model.entries)
                            : [(nil, model.entries)],
                        onWake: { postID in
                            structure.mode = .outline
                            model.focus(postID)
                        })
                case .pages:
                    PagedReadView(session: session, model: model, structure: structure)
                }
            }
        }
        .background(tokens.surface)
        .task { await model.start() }
        .task { await structure.start() }
        .overlay(alignment: .bottom) {
            if let error = model.lastError ?? structure.lastError {
                Text(error)
                    .font(tokens.small)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
                    .padding(4)
            }
        }
        .alert("New Chapter", isPresented: $newChapterPresented) {
            TextField("Name", text: $chapterNameField)
            Button("Create") {
                let name = chapterNameField
                Task { await structure.createChapter(named: name) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert(
            "Rename Chapter",
            isPresented: Binding(
                get: { renameChapterTarget != nil },
                set: { if !$0 { renameChapterTarget = nil } }),
            presenting: renameChapterTarget
        ) { section in
            TextField("Name", text: $chapterNameField)
            Button("Rename") {
                let name = chapterNameField
                Task { await structure.renameChapter(section.id, to: name) }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $settingsShown) {
            BookSettingsSheet(structure: structure)
        }
    }

    // MARK: - The navigator (R43: chapters · outline · settings)

    private var navigator: some View {
        ScrollViewReader { proxy in
            VStack(alignment: .leading, spacing: 6) {
                Text(tokens.path([readingName ?? model.readingName ?? "book"]))
                    .font(tokens.heading)
                    .foregroundStyle(tokens.accent)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    // 13c 2A (her 2026-07-23/24 direction): the three modes
                    // read OUTLINE · BOOK · READ — outline is where the book
                    // is written (A39), book is the post-per-page spread,
                    // read is the reading flow.
                    Picker("", selection: Binding(
                        get: { structure.mode },
                        set: { structure.mode = $0 })) {
                        Text(tokens.chromeLabel("Outline")).tag(BookStructureModel.ViewMode.outline)
                        Text(tokens.chromeLabel("Book")).tag(BookStructureModel.ViewMode.spread)
                        Text(tokens.chromeLabel("Read")).tag(BookStructureModel.ViewMode.read)
                    }
                    .pickerStyle(.segmented)
                    Button {
                        settingsShown = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .buttonStyle(.borderless)
                    .help("Book settings — finish, length, rename")
                }
                // 13c 2C: READ's pair of faces (her direction — "the
                // Apple-Books/Kindle PAIR of modes"). It sits UNDER the mode
                // picker rather than in a bottom bar, because one of the two
                // faces (the flow) is a vertical scroll and carries no bottom
                // chrome at all — the A6 argument. Surface-local, so
                // recorded rather than declared (Stage 4 lesson 10).
                if structure.mode == .read {
                    Picker("", selection: Binding(
                        get: { structure.readForm },
                        set: { structure.readForm = $0 })) {
                        Text(tokens.chromeLabel("Scroll")).tag(BookStructureModel.ReadForm.flow)
                        Text(tokens.chromeLabel("Pages")).tag(BookStructureModel.ReadForm.pages)
                    }
                    .pickerStyle(.segmented)
                    .help("Read the book as one continuous scroll, or as real pages "
                        + "with the text flowing across them")
                }
                if let reading = structure.reading, reading.locked {
                    Text(tokens.chromeLabel("✓ finished"))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                }
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(structure.grouped(entries: model.entries), id: \.section?.id) { group in
                            if let section = group.section {
                                // R19's insertion bar: the drop target
                                // shows exactly where the chapter lands.
                                if chapterDropTarget == section.id {
                                    Rectangle()
                                        .fill(tokens.ring)
                                        .frame(height: 2)
                                }
                                Button {
                                    // Navigate: land the book scroll at the
                                    // chapter (the flow view shows it too);
                                    // in the SPREAD, show the chapter's
                                    // first page (13b 4F; 13c 2B).
                                    let first = structure
                                        .grouped(entries: model.entries)
                                        .first(where: { $0.section?.id == section.id })?
                                        .entries.first
                                    if structure.mode == .spread {
                                        if let first { model.showPost(first.postID) }
                                    } else if structure.mode == .read,
                                              structure.readForm == .pages {
                                        // 13c 2C: a chapter opens at its
                                        // first PAGE, without leaving Read.
                                        if let first { model.focus(first.postID) }
                                    } else {
                                        scrollTarget = "chapter-\(section.id)"
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text("⠿")
                                            .font(tokens.small)
                                            .foregroundStyle(tokens.faint)
                                        Text(tokens.chromeLabel(section.name))
                                            .font(tokens.small.weight(.semibold))
                                            .foregroundStyle(tokens.accent)
                                            .lineLimit(1)
                                    }
                                }
                                .buttonStyle(.plain)
                                .contextMenu { chapterMenu(section) }
                                .draggable(section.id)
                                .dropDestination(for: String.self) { items, _ in
                                    guard let dragged = items.first else { return false }
                                    Task {
                                        await structure.moveChapter(dragged, before: section.id)
                                    }
                                    return true
                                } isTargeted: { targeted in
                                    if targeted {
                                        chapterDropTarget = section.id
                                    } else if chapterDropTarget == section.id {
                                        chapterDropTarget = nil
                                    }
                                }
                            } else if structure.chaptersActive {
                                Text(tokens.chromeLabel("unfiled"))
                                    .font(tokens.small.weight(.semibold))
                                    .foregroundStyle(tokens.muted)
                            }
                            // The top-level outline: posts; clicking one
                            // opens it in the CURRENT editor (R43 — no
                            // context jump).
                            ForEach(group.entries, id: \.postID) { entry in
                                Button {
                                    // In the SPREAD the navigator is a
                                    // page-jump: show the post, read-cheap
                                    // (13b 4F — the calm default; a click in
                                    // the page upgrades it to the live
                                    // editor). A post already on the spread
                                    // stays where it is (13c 2B).
                                    if structure.mode == .spread {
                                        model.showPost(entry.postID)
                                    } else if structure.mode == .read,
                                              structure.readForm == .pages {
                                        // 13c 2C: in paginated Read the
                                        // navigator is a PAGE jump — it must
                                        // not throw her out of the reading
                                        // surface into the editor (the 4F
                                        // no-context-jump rule, R43).
                                        model.focus(entry.postID)
                                    } else {
                                        structure.mode = .outline
                                        model.focus(entry.postID)
                                        scrollTarget = "page-\(entry.postID)"
                                    }
                                } label: {
                                    HStack(spacing: 2) {
                                        // Batch 9 (R100's continuation): the
                                        // focused post wears the color › in
                                        // the navigator too — and while
                                        // PAGING, the current page does
                                        // (13b 4F).
                                        if navigatorMarks(entry),
                                           !tokens.selectionMarker.isEmpty {
                                            Text(tokens.selectionMarker
                                                .trimmingCharacters(in: .whitespaces))
                                                .font(tokens.small.weight(.bold))
                                                .foregroundStyle(tokens.accent)
                                        }
                                        Text(outlineEntryTitle(entry))
                                            .font(tokens.small)
                                            .foregroundStyle(
                                                navigatorMarks(entry)
                                                    ? tokens.ink : tokens.muted)
                                            .lineLimit(1)
                                    }
                                    .padding(.leading, group.section != nil ? 10 : 0)
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    outlineChapterMenu(
                                        structure: structure, postID: entry.postID)
                                }
                            }
                        }
                        // The end drop zone: drag a chapter past the last
                        // one to land it at the end (R19).
                        if structure.chaptersActive, structure.reading?.kind == .curated {
                            if chapterDropAtEnd {
                                Rectangle()
                                    .fill(tokens.ring)
                                    .frame(height: 2)
                            }
                            Color.clear
                                .frame(height: 14)
                                .contentShape(Rectangle())
                                .dropDestination(for: String.self) { items, _ in
                                    guard let dragged = items.first else { return false }
                                    Task {
                                        await structure.moveChapter(dragged, before: nil)
                                    }
                                    return true
                                } isTargeted: { chapterDropAtEnd = $0 }
                        }
                    }
                    .id("nav-noop")
                }
                Spacer(minLength: 4)
                if structure.reading?.kind == .curated {
                    Button(tokens.chromeLabel("+ new chapter")) {
                        chapterNameField = ""
                        newChapterPresented = true
                    }
                    .buttonStyle(.borderless)
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    // Round 2, MINOR: the recovery door lives HERE too —
                    // deleting the ONLY chapter leaves no section row to
                    // hang the context menu off.
                    if !structure.deletedSections.isEmpty {
                        Button(tokens.chromeLabel("restore deleted chapter")) {
                            Task { await structure.restoreLastDeletedChapter() }
                        }
                        .buttonStyle(.borderless)
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                    }
                    // Round 3, MINOR: no entry door on a FINISHED book
                    // (additive — the model's in-closure gate covers the
                    // concurrent-lock race the hidden button can't).
                    if structure.reading?.profile == "journal",
                       structure.reading?.locked != true {
                        Button(tokens.chromeLabel("+ new entry")) {
                            Task {
                                if let id = await structure.newEntry() {
                                    model.focus(id)
                                }
                            }
                        }
                        .buttonStyle(.borderless)
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                    } else if structure.reading?.kind == .curated,
                              structure.reading?.locked != true {
                        // Sitting 9 (R62/R75): "it needs to be easy to make
                        // a post inside of a book" — the non-journal door.
                        Button(tokens.chromeLabel("+ new post")) {
                            Task {
                                if let id = await structure.newPost() {
                                    model.focus(id)
                                }
                            }
                        }
                        .buttonStyle(.borderless)
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                        .help("A new post born inside this book — no drag needed")
                    }
                }
                if structure.reading?.kind == .smart {
                    // Batch 6 legibility: a smart book's missing add/chapter
                    // doors are DESIGNED (#25a — membership is derived) —
                    // but absent-and-silent read as broken. Say so.
                    // (ChromeNotice: navigator = non-scrolling chrome — the
                    // window-min class; batch 12 sweep.)
                    ChromeNotice(
                        tokens: tokens,
                        text: "smart book — it collects posts by its tags. Tag a post "
                            + "anywhere and it appears here; chapters and direct adds "
                            + "are for hand-picked books.",
                        lines: 6)
                }
            }
            .padding(12)
            .frame(width: 190)
            .background(tokens.room)
        }
    }

    /// The book scroll's pending landing (chapter/outline clicks).
    @State private var scrollTarget: String?
    /// R19 drag state: the chapter the dragged one would land BEFORE, and
    /// the end zone's highlight.
    @State private var chapterDropTarget: String?
    @State private var chapterDropAtEnd = false

    @ViewBuilder
    private func chapterMenu(_ section: ReadingSection) -> some View {
        Button("Rename…") {
            chapterNameField = section.name
            renameChapterTarget = section
        }
        Button("Move Up") { Task { await structure.moveChapter(section.id, up: true) } }
        Button("Move Down") { Task { await structure.moveChapter(section.id, up: false) } }
        Divider()
        Button("Delete Chapter", role: .destructive) {
            Task { await structure.deleteChapter(section.id) }
        }
        Button("Restore Last Deleted Chapter") {
            Task { await structure.restoreLastDeletedChapter() }
        }
    }


    // MARK: - OUTLINE: the book's writing surface (13c 2A — A39)
    //
    // Her words: *"i also feel like I need more of a proper 'write' mode for
    // the whole book - like literally looks like write mode but has the
    // chapter headings and the posts are collapsible."* And the finding that
    // gives it weight (A45): she wanted sub-takes, refused the idea herself,
    // and diagnosed the cause — the BOOK level had never been a writing
    // surface, so the only natural place to compose was inside one post.
    // So this is not a decorated list: it is Write's measure, Write's
    // typography, chapter headings inline, and one live editor that migrates
    // exactly as it does everywhere else (P3).
    //
    // What is NOT here, deliberately: no second liveness mechanism (the
    // focused post mounts the ONE full-document editor, `BookViewModel` is
    // the single focus authority — 13b 3E's fold), no in-place TK2 text
    // folding (collapse is view state — TEXTKIT2 §3; AppSpec §12), and no
    // bottom chrome (A6).

    private var outlineBody: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    // Batch 12 (her mockup reference): the book's TITLE
                    // heads the content column, aligned with the posts —
                    // never floating in rail-side dead space.
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tokens.chromeLabel(readingName ?? model.readingName ?? "book"))
                            .font(tokens.title)
                            .foregroundStyle(tokens.ink)
                        HStack(spacing: 8) {
                            Text(tokens.chromeLabel(bookMetaLine))
                                .font(tokens.small)
                                .foregroundStyle(tokens.muted)
                            // 13c 2A: posts read OPEN here — this is where
                            // the book is written. "collapse all" folds the
                            // whole book back to cards in one click (13b 3E
                            // D1: it releases the focused post's editor too).
                            Button(tokens.chromeLabel("expand all")) {
                                model.expandAll()
                            }
                            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                            Button(tokens.chromeLabel("collapse all")) {
                                model.collapseAll()
                            }
                            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                        }
                    }
                    .padding(.bottom, 18)
                    if model.entries.isEmpty {
                        Text("This book has no posts yet.")
                            .foregroundStyle(tokens.muted)
                    }
                    if structure.chaptersActive {
                        ForEach(structure.grouped(entries: model.entries), id: \.section?.id) { group in
                            if let section = group.section {
                                chapterHeader(section)
                            } else {
                                // UNFILED trails the chapters (ratified,
                                // QUESTIONS #26(b)) — the grouping brain's
                                // order, rendered, never re-decided here.
                                Text(tokens.chromeLabel("unfiled"))
                                    .font(tokens.heading)
                                    .foregroundStyle(tokens.muted)
                                    .padding(.top, 28)
                            }
                            ForEach(group.entries, id: \.postID) { entry in
                                postRow(entry)
                            }
                        }
                        bodyChapterEndZone  // N21: drag a chapter past the last
                    } else {
                        ForEach(Array(model.entries.enumerated()), id: \.element.postID) { i, entry in
                            if let section = model.sectionHeader(at: i) {
                                // Smart books keep tag-path sectioning
                                // (`grouping_tag_id`) — same heading voice.
                                Text(section)
                                    .font(tokens.title)
                                    .foregroundStyle(tokens.accent)
                                    .padding(.top, 28)
                            }
                            postRow(entry)
                        }
                    }
                    if model.truncated {
                        Text("Showing the first \(BookViewModel.entryWindow) posts — "
                            + "the rest of this book isn't loaded yet "
                            + "(windowing arrives with Phase 12).")
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .padding(.vertical, 8)
                    }
                    // Sitting 9 batch 6: the add-post door lives IN the
                    // book's flow too, where writing ends — the navigator
                    // rail's twin (R62/R75; discoverability is the point).
                    if structure.reading?.locked != true {
                        if structure.reading?.profile == "journal" {
                            Button(tokens.chromeLabel("+ new entry")) {
                                Task {
                                    if let id = await structure.newEntry() {
                                        model.focus(id)
                                        scrollTarget = "page-\(id)"
                                    }
                                }
                            }
                            .buttonStyle(.borderless)
                            .font(tokens.small)
                            .foregroundStyle(tokens.accent)
                            .padding(.top, 12)
                        } else if structure.reading?.kind == .curated {
                            Button(tokens.chromeLabel("+ new post in this book")) {
                                Task {
                                    if let id = await structure.newPost() {
                                        model.focus(id)
                                        scrollTarget = "page-\(id)"
                                    }
                                }
                            }
                            .buttonStyle(.borderless)
                            .font(tokens.small)
                            .foregroundStyle(tokens.accent)
                            .padding(.top, 12)
                            .help("A new post born inside this book — no drag needed")
                        }
                    }
                }
                // 13c 2A: WRITE'S OWN MEASURE, at book scale (A39's
                // "literally looks like write mode"; R9 — margins are
                // sacred). The detail editor centers an
                // `EditorTypography.maxColumnWidth` prose column; both text
                // tiers in this column (the inline editor and the read
                // surface) carry the same 8pt container inset, so a column
                // of maxColumn + 2×inset puts this book's prose on exactly
                // the measure Write puts a post's on. It stays LEFT-ANCHORED
                // beside the navigator (batch 12, her mockup reference:
                // "there shouldn't be so much open space to the left").
                .frame(maxWidth: Self.proseColumn, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
            }
            .onChange(of: scrollTarget) { _, target in
                guard let target else { return }
                withAnimation { proxy.scrollTo(target, anchor: .top) }
                scrollTarget = nil
            }
            // 13c 2A (her item A6, RULED 2026-07-24): Outline's ENTIRE
            // bottom inset is gone — the `Slider` jump control ("it makes
            // no sense to have a horizontal scrollbar on a vertical page")
            // AND the progress bar above it ("it seems a bit buggy… remove
            // it fully for now, I'll add it later if I feel inclined").
            // If it is ever re-added, the bugginess she saw is investigated
            // FIRST — an observed defect parked by removal, not chased.
            // Outline ends as a clean vertical scroll + the navigator.
            // The model's scrub/progress brains stay (pure, pinned): the
            // Book spread and Read's paginated sub-mode both KEEP a bottom
            // bar, and 2B/2C are their owners.
        }
    }

    /// 13b 3E (N21 — her "the dots … make me feel like it should be
    /// draggable and it isn't"): the body's chapter header now DRAGS. The
    /// dots are honest — same insert-before semantics, same indicator
    /// grammar, and the same model door (`moveChapter(before:)`) as the
    /// navigator; the end zone below the last group lands a chapter last.
    @ViewBuilder
    private func chapterHeader(_ section: ReadingSection) -> some View {
        if bodyChapterDropTarget == section.id {
            Rectangle()
                .fill(tokens.ring)
                .frame(height: 2)
        }
        HStack(spacing: 6) {
            Text("⠿")
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .help("Drag to reorder this chapter — here or in the navigator "
                    + "(right-click for Move Up / Move Down)")
            // 13c 2A (A39: "has the chapter headings"): a chapter reads as
            // a HEADING in the book's own voice — the title face, with real
            // air above it — not as a chrome row above a list.
            Text(tokens.chromeLabel(section.name))
                .font(tokens.title)
                .foregroundStyle(tokens.accent)
        }
        .padding(.top, 28)
        .id("chapter-\(section.id)")
        .contextMenu { chapterMenu(section) }
        .draggable(section.id)
        .dropDestination(for: String.self) { items, _ in
            guard let dragged = items.first else { return false }
            Task {
                await structure.moveChapter(dragged, before: section.id)
            }
            return true
        } isTargeted: { targeted in
            if targeted {
                bodyChapterDropTarget = section.id
            } else if bodyChapterDropTarget == section.id {
                bodyChapterDropTarget = nil
            }
        }
    }

    /// The body's end drop zone (N21's twin of the navigator's R19 zone).
    @ViewBuilder
    private var bodyChapterEndZone: some View {
        if structure.chaptersActive, structure.reading?.kind == .curated {
            if bodyChapterDropAtEnd {
                Rectangle()
                    .fill(tokens.ring)
                    .frame(height: 2)
            }
            Color.clear
                .frame(height: 14)
                .contentShape(Rectangle())
                .dropDestination(for: String.self) { items, _ in
                    guard let dragged = items.first else { return false }
                    Task {
                        await structure.moveChapter(dragged, before: nil)
                    }
                    return true
                } isTargeted: { bodyChapterDropAtEnd = $0 }
        }
    }

    @State private var bodyChapterDropTarget: String?
    @State private var bodyChapterDropAtEnd = false

    /// The navigator's "you are here": the focused post — and, in the
    /// SPREAD, BOTH pages on screen (13b 4F; 13c 2B — a spread shows two
    /// posts, so two rows are honestly "here").
    private func navigatorMarks(_ entry: Queries.ReadingEntry) -> Bool {
        model.focusedPostID == entry.postID
            || (structure.mode == .spread && model.isOnSpread(entry.postID))
    }

    /// Batch 12: kind + extent at a glance under the title.
    private var bookMetaLine: String {
        var parts: [String] = [structure.reading?.kind == .smart ? "smart book" : "book"]
        if structure.sections.count > 0 { parts.append("\(structure.sections.count) chapters") }
        parts.append("\(model.entries.count) posts")
        return parts.joined(separator: " · ")
    }

    /// One post in the outline (13c 2A — extracted from four inline
    /// builders so the row has an INIT the virtualization counter can ride,
    /// the `ReadingFlowView` precedent; P-9's split rides along).
    private func postRow(_ entry: Queries.ReadingEntry) -> some View {
        OutlinePostRow(
            session: session, model: model, structure: structure,
            entry: entry, tokens: tokens)
    }
}

#if DEBUG
/// 13c 2A's virtualization pin support (the `ReadingFlowMaterialization`
/// precedent): counts `OutlinePostRow` materializations so the P3 pin can
/// assert the `LazyVStack` defers off-viewport rows. Load-bearing HERE in a
/// way it was not before: posts render OPEN by default now, so an
/// unvirtualized outline would realize a text surface per post in the book.
@MainActor
enum BookOutlineMaterialization {
    static var count = 0
}
#endif

/// One post in Outline: its heading, and either its prose (read-cheap, or
/// THE one live editor when focused) or — when deliberately collapsed —
/// batch 12's card.
///
/// 13c 2A: posts render OPEN by default here (`BookViewModel` tracks the
/// COLLAPSED set), because this is the book's writing surface. Collapse is
/// the deliberate act, and it is pure view state — never in-place text
/// folding inside a live TK2 editor (TEXTKIT2 §3; AppSpec §12).
///
/// 13b 3E (D1): expansion + focus live on the MODEL — ONE authority. The
/// focused post is expanded because `focus` insists, and `collapse`
/// releases focus, so the old force-expand disjunct is gone.
private struct OutlinePostRow: View {
    let session: AppSession
    let model: BookViewModel
    let structure: BookStructureModel
    let entry: Queries.ReadingEntry
    let tokens: VoiceTokens

    init(
        session: AppSession, model: BookViewModel, structure: BookStructureModel,
        entry: Queries.ReadingEntry, tokens: VoiceTokens
    ) {
        self.session = session
        self.model = model
        self.structure = structure
        self.entry = entry
        self.tokens = tokens
        #if DEBUG
        BookOutlineMaterialization.count += 1
        #endif
    }

    var body: some View {
        if model.isExpanded(entry.postID) {
            VStack(alignment: .leading, spacing: 6) {
                postHeader
                postBody
            }
            .padding(.bottom, 22)
        } else {
            collapsedPostCard
                .padding(.bottom, 10)
        }
    }

    /// The post's heading in the book's own voice (13c 2A): the title reads
    /// as a title; the doors — collapse, and out into the full editor —
    /// recede to quiet chrome beside it, because this is a page she writes
    /// on, not a catalog row.
    private var postHeader: some View {
        HStack(spacing: 6) {
            // 13b 3E (D1): the ONE collapse door — it releases focus too,
            // so collapsing the post you're typing in actually collapses it.
            Button("▾") { model.collapse(entry.postID) }
                .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                .help("Collapse this post back to its card")
            Text(outlineEntryTitle(entry))
                .font(tokens.heading)
                .foregroundStyle(tokens.ink)
            if let date = entry.entryDate {
                Text(date)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
            }
            // Sitting 9 batch 7: the door OUT of the book into the post's
            // full editor (modes, takes, lenses — everything).
            Button(tokens.chromeLabel("open ↗")) {
                NotificationCenter.default.post(
                    name: .variorumOpenPost, object: nil,
                    userInfo: ["postID": entry.postID])
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            .help("Open this post in the full editor (Write · Takes · Lenses · …)")
        }
        .padding(.top, 10)
        .id("page-\(entry.postID)")  // the navigator's landing anchor
        .contextMenu { outlineChapterMenu(structure: structure, postID: entry.postID) }
    }

    @ViewBuilder
    private var postBody: some View {
        if model.focusedPostID == entry.postID {
            // THE one live editor (P3 by construction: a single focused id;
            // it is the full-document editor, so every routed act — ⌘S,
            // divide, callout, comments — reaches this surface through the
            // capability registry's attached-editor arm, exactly as in
            // Write. Stage 4 lesson 2 holds here without a second handler.)
            EditorView(
                session: session, postID: entry.postID, inline: true,
                caretSeed: model.caretSeed, fanSeed: model.fanSeed)
                .id(entry.postID)
        } else {
            ReadPostView(
                session: session, postID: entry.postID,
                onFocusRequest: { offset in
                    model.focus(entry.postID, caret: offset)
                },
                onBadgeTap: { blockID in
                    // Interpretation 1 (PROVISIONAL): focus FIRST, then the
                    // fan panel opens on the one live surface.
                    model.focus(entry.postID, fanBlock: blockID)
                })
                .id("read-\(entry.postID)")
        }
    }

    /// The collapsed card (batch 12's ruling, preserved as the COLLAPSED
    /// form — 13c 2A changed only which state is the default). 13b 3E
    /// (N22): the card BODY opens the post in the full editor; the ▸
    /// disclosure unfolds it in place. Each target does what it looks like.
    private var collapsedPostCard: some View {
        Button {
            NotificationCenter.default.post(
                name: .variorumOpenPost, object: nil,
                userInfo: ["postID": entry.postID])
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Button {
                        model.expand(entry.postID)
                    } label: {
                        Text("▸")
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .padding(.horizontal, 2)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .help("Unfold this post in place — write in it right here")
                    Text(outlineEntryTitle(entry))
                        .font(tokens.body.weight(.semibold))
                        .foregroundStyle(tokens.ink)
                    if let date = entry.entryDate {
                        Text(date)
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                    }
                    Spacer()
                    Button(tokens.chromeLabel("open ↗")) {
                        NotificationCenter.default.post(
                            name: .variorumOpenPost, object: nil,
                            userInfo: ["postID": entry.postID])
                    }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
                    .help("Open this post in the full editor (Write · Takes · Lenses · …)")
                }
                PostCardExcerpt(session: session, postID: entry.postID, tokens: tokens)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(tokens.card)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(tokens.line, lineWidth: 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help("Click to open this post in the full editor; ▸ unfolds it here")
        .id("page-\(entry.postID)")  // the navigator's landing anchor
        .contextMenu { outlineChapterMenu(structure: structure, postID: entry.postID) }
    }
}

/// A post's chapter-filing menu — ONE definition, two callers (the
/// navigator's rows and the outline's own rows). Curated books only:
/// chapters are a curated-reading concept (QUESTIONS #25(a)).
@MainActor
@ViewBuilder
private func outlineChapterMenu(
    structure: BookStructureModel, postID: String
) -> some View {
    if structure.reading?.kind == .curated {
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

/// A reading entry's display title — shared by every book surface's rows.
private func outlineEntryTitle(_ entry: Queries.ReadingEntry) -> String {
    entry.title?.isEmpty == false ? entry.title! : (entry.entryDate ?? "Untitled")
}

/// Batch 12 — the collapsed card's excerpt + meta line (her referenced
/// mockup: "2,140w · rev may 3" / "⑂ takes on 2 blocks"). Fetched per
/// visible card (LazyVStack realization — cost ∝ what's on screen, P1).
private struct PostCardExcerpt: View {
    let session: AppSession
    let postID: String
    let tokens: VoiceTokens
    @State private var excerpt = ""
    @State private var meta = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !excerpt.isEmpty {
                Text(excerpt)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            if !meta.isEmpty {
                Text(tokens.chromeLabel(meta))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
            }
        }
        .task(id: postID) {
            let slots = (try? await session.database.read { [postID] db in
                try Queries.renderPost(db, containerID: postID)
            }) ?? []
            let first = slots.compactMap(\.text).first { !$0.isEmpty } ?? ""
            excerpt = String(first.prefix(280))
            let words = slots.reduce(0) { $0 + TextMetrics.wordCount($1.text ?? "") }
            let fanned = slots.filter(\.hasFan).count
            var parts = ["\(words.formatted())w"]
            if fanned > 0 {
                parts.append("⑂ takes on \(fanned) block\(fanned == 1 ? "" : "s")")
            }
            meta = parts.joined(separator: " · ")
        }
    }
}

/// The navigator's settings leg (R43): finish, rename, extents — the book's
/// own faces, beside the shelf's.
struct BookSettingsSheet: View {
    let structure: BookStructureModel
    @State private var nameField = ""
    @State private var wordTargetField = ""
    @State private var maxPostsField = ""
    @State private var parseError: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Book Settings").font(.headline)
            Form {
                TextField("Name", text: $nameField)
                TextField("Word target (blank = none)", text: $wordTargetField)
                TextField("Post cap (blank = none)", text: $maxPostsField)
                if let reading = structure.reading {
                    Toggle("Finished", isOn: Binding(
                        get: { reading.locked },
                        set: { finished in Task { await structure.setFinished(finished) } }))
                }
            }
            Text("Finishing freezes the book's membership and order (reversible). A finished book opens as pure text.")
                .font(.caption)
                .foregroundStyle(.secondary)
            if let parseError {
                Text(parseError).font(.caption).foregroundStyle(.red)
            }
            HStack {
                Spacer()
                Button("Close") {
                    if save() { dismiss() }
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(16)
        .frame(minWidth: 380)
        .onAppear {
            nameField = structure.reading?.name ?? ""
            wordTargetField = structure.reading?.wordTarget.map(String.init) ?? ""
            maxPostsField = structure.reading?.maxPosts.map(String.init) ?? ""
        }
    }

    /// Round 2, MINOR: unparseable input REFUSES and keeps (ExtentInput —
    /// the one parse rule shared with the shelf's sheet).
    private func save() -> Bool {
        guard let target = ExtentInput.parse(wordTargetField),
              let cap = ExtentInput.parse(maxPostsField)
        else {
            parseError = "Extents are plain positive numbers (e.g. 10000) — nothing was changed."
            return false
        }
        let name = nameField.trimmingCharacters(in: .whitespaces)
        Task {
            if !name.isEmpty, name != structure.reading?.name {
                await structure.rename(to: name)
            }
            if target.intValue != structure.reading?.wordTarget {
                await structure.setWordTarget(target.intValue)
            }
            if cap.intValue != structure.reading?.maxPosts {
                await structure.setMaxPosts(cap.intValue)
            }
        }
        return true
    }
}
