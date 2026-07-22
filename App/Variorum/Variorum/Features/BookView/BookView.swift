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
    /// `initiallyExpanded` (batch 12, R106): posts render as collapsed
    /// CARDS by default; tests that assert on rendered post content seed
    /// the expansion set here (13b 3E: expansion lives on the MODEL now —
    /// the one focus authority; the seed lands there).
    init(
        session: AppSession, readingID: String, readingName: String? = nil,
        model: BookViewModel? = nil,
        initiallyExpanded: Set<String> = []
    ) {
        self.session = session
        self.readingID = readingID
        self.readingName = readingName
        let resolved = model ?? BookViewModel(session: session, readingID: readingID)
        for postID in initiallyExpanded { resolved.expand(postID) }
        _model = State(initialValue: resolved)
        _structure = State(initialValue: BookStructureModel(session: session, readingID: readingID))
    }

    // Optional: test hosts (and future embeddings) may lack the
    // environment — fall back to the leading voice's tokens.
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @State private var scrubFraction: Double = 0
    @State private var scrubLabel: String?
    @State private var newChapterPresented = false
    @State private var chapterNameField = ""
    @State private var renameChapterTarget: ReadingSection?
    @State private var settingsShown = false

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        HStack(spacing: 0) {
            navigator
            Divider().overlay(tokens.line)
            switch structure.mode {
            case .book:
                bookBody
            case .pages:
                // 13b 4F (S4-9(2), N31): the Kindle-style paged view —
                // page = a post, one page mounted at a time (P3), the
                // bottom scrub over the same model-driven post domain.
                PagedBookView(session: session, model: model, structure: structure)
            case .read:
                ReadingFlowView(
                    session: session,
                    readingName: readingName ?? model.readingName,
                    grouped: structure.chaptersActive
                        ? structure.grouped(entries: model.entries)
                        : [(nil, model.entries)],
                    onWake: { postID in
                        structure.mode = .book
                        model.focus(postID)
                    })
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
                    // 13b 4F (S4-9): three view modes now — the scroll
                    // book, the paged book, the reading flow.
                    Picker("", selection: Binding(
                        get: { structure.mode },
                        set: { structure.mode = $0 })) {
                        Text(tokens.chromeLabel("Book")).tag(BookStructureModel.ViewMode.book)
                        Text(tokens.chromeLabel("Pages")).tag(BookStructureModel.ViewMode.pages)
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
                                    // while PAGING, flip to the chapter's
                                    // first page (13b 4F).
                                    if structure.mode == .pages {
                                        if let first = structure
                                            .grouped(entries: model.entries)
                                            .first(where: { $0.section?.id == section.id })?
                                            .entries.first {
                                            model.openPage(post: first.postID)
                                        }
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
                                    // While PAGING the navigator is a
                                    // page-jump: land the post's page,
                                    // read-cheap (13b 4F — the calm
                                    // default; a click in the page
                                    // upgrades to the live editor).
                                    if structure.mode == .pages {
                                        model.openPage(post: entry.postID)
                                    } else {
                                        structure.mode = .book
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
                                        Text(entryTitle(entry))
                                            .font(tokens.small)
                                            .foregroundStyle(
                                                navigatorMarks(entry)
                                                    ? tokens.ink : tokens.muted)
                                            .lineLimit(1)
                                    }
                                    .padding(.leading, group.section != nil ? 10 : 0)
                                }
                                .buttonStyle(.plain)
                                .contextMenu { postChapterMenu(entry) }
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

    @ViewBuilder
    private func postChapterMenu(_ entry: Queries.ReadingEntry) -> some View {
        if structure.reading?.kind == .curated {
            Menu("Chapter") {
                ForEach(structure.sections, id: \.id) { section in
                    Button(section.name) {
                        Task { await structure.assign(entry.postID, to: section.id) }
                    }
                }
                Divider()
                Button("None") {
                    Task { await structure.assign(entry.postID, to: nil) }
                }
            }
        }
    }

    // MARK: - The book body (chapters + read-cheap posts + one live editor)

    private var bookBody: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    // Batch 12 (her mockup reference): the book's TITLE
                    // heads the content column, aligned with the post
                    // cards — never floating in rail-side dead space.
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tokens.chromeLabel(readingName ?? model.readingName ?? "book"))
                            .font(tokens.title)
                            .foregroundStyle(tokens.ink)
                        HStack(spacing: 8) {
                            Text(tokens.chromeLabel(bookMetaLine))
                                .font(tokens.small)
                                .foregroundStyle(tokens.muted)
                            // Batch 12: posts render COLLAPSED by default —
                            // cards, not content; these are the all-doors.
                            // 13b 3E (D1): collapse-all really collapses
                            // ALL — the focused post's editor releases too.
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
                    .padding(.bottom, 10)
                    if model.entries.isEmpty {
                        Text("This book has no posts yet.")
                            .foregroundStyle(tokens.muted)
                    }
                    if structure.chaptersActive {
                        ForEach(structure.grouped(entries: model.entries), id: \.section?.id) { group in
                            if let section = group.section {
                                chapterHeader(section)
                            } else {
                                Text(tokens.chromeLabel("unfiled"))
                                    .font(tokens.small)
                                    .foregroundStyle(tokens.muted)
                                    .padding(.top, 12)
                            }
                            ForEach(group.entries, id: \.postID) { entry in
                                postRow(entry)
                            }
                        }
                        bodyChapterEndZone  // N21: drag a chapter past the last
                    } else {
                        ForEach(Array(model.entries.enumerated()), id: \.element.postID) { i, entry in
                            if let section = model.sectionHeader(at: i) {
                                Text(section)
                                    .font(tokens.heading)
                                    .padding(.top, 12)
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
                // R9's measure holds (760pt) — but the column is LEFT-
                // ANCHORED beside the navigator now (batch 12, her mockup
                // reference: "there shouldn't be so much open space to the
                // left"; centering left a rail-to-title gulf on wide
                // windows).
                .frame(maxWidth: 760, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
                .padding(.vertical, 20)
            }
            .onChange(of: scrollTarget) { _, target in
                guard let target else { return }
                withAnimation { proxy.scrollTo(target, anchor: .top) }
                scrollTarget = nil
            }
            .safeAreaInset(edge: .bottom) {
                // BOOK-SCRUB (Phase 11, A5 — the Phase 6 memo's ruling):
                // MODEL-DRIVEN — the post list is the scrubber's domain.
                if model.entries.count > 1 {
                    VStack(spacing: 2) {
                        // 13b 4F (S4-9(1), N31): the PROGRESS BAR — where
                        // you are in the book, over the same post-list
                        // domain ("post 12 of 50 · 24%"); the slider
                        // below stays the JUMP control.
                        if let progress = model.readingProgress {
                            HStack(spacing: 8) {
                                ProgressView(value: progress.fraction)
                                    .progressViewStyle(.linear)
                                    .tint(tokens.accent)
                                Text(tokens.chromeLabel(
                                    "post \(progress.position) of \(progress.total) · \(Int((progress.fraction * 100).rounded()))%"))
                                    .font(tokens.small)
                                    .foregroundStyle(tokens.muted)
                                    .lineLimit(1)
                            }
                        }
                        Slider(value: Binding(
                            get: { scrubFraction },
                            set: { fraction in
                                scrubFraction = fraction
                                if let target = model.scrubTarget(fraction: fraction) {
                                    scrubLabel = scrubTitle(target)
                                    proxy.scrollTo("page-\(target.postID)", anchor: .top)
                                }
                            }), in: 0...1)
                        if let scrubLabel {
                            Text(scrubLabel)
                                .font(tokens.small)
                                .foregroundStyle(tokens.muted)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.bar)
                }
            }
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
                .foregroundStyle(tokens.faint)
                .help("Drag to reorder this chapter — here or in the navigator "
                    + "(right-click for Move Up / Move Down)")
            Text(tokens.chromeLabel(section.name))
                .font(tokens.heading)
                .foregroundStyle(tokens.accent)
        }
        .padding(.top, 16)
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

    private func entryTitle(_ entry: Queries.ReadingEntry) -> String {
        entry.title?.isEmpty == false ? entry.title! : (entry.entryDate ?? "Untitled")
    }

    /// The navigator's "you are here": the focused post — and, while
    /// paging, the current page (13b 4F).
    private func navigatorMarks(_ entry: Queries.ReadingEntry) -> Bool {
        model.focusedPostID == entry.postID
            || (structure.mode == .pages && model.currentPage?.postID == entry.postID)
    }

    private func scrubTitle(_ entry: Queries.ReadingEntry) -> String {
        let index = model.entries.firstIndex { $0.postID == entry.postID } ?? 0
        return "Page \(index + 1) of \(model.entries.count) — \(entryTitle(entry))"
    }

    /// Batch 12: kind + extent at a glance under the title.
    private var bookMetaLine: String {
        var parts: [String] = [structure.reading?.kind == .smart ? "smart book" : "book"]
        if structure.sections.count > 0 { parts.append("\(structure.sections.count) chapters") }
        parts.append("\(model.entries.count) posts")
        return parts.joined(separator: " · ")
    }

    /// Batch 12 (her ruling): a post shows as a collapsed CARD until
    /// expanded — "you shouldn't see the content within a post on the book
    /// screen unless you click something." 13b 3E (D1): expansion + focus
    /// live on the MODEL now, ONE authority — the focused post is expanded
    /// because `focus` insists, and `collapse` releases focus, so the old
    /// force-expand disjunct (the D1 mechanism) is gone.
    @ViewBuilder
    private func postRow(_ entry: Queries.ReadingEntry) -> some View {
        // 13b 4F (S4-9(1)): the row's CONTENT view (card, or expanded
        // body — exactly one tracked view per row) reports its scroll
        // visibility into the model's progress brain. Model-driven per
        // the Phase 6 ruling: the report is one boolean per realized row;
        // progress is derived from the POST LIST, never pixel geometry.
        if model.isExpanded(entry.postID) {
            postHeader(entry, expanded: true)
            postBody(entry)
                .padding(.bottom, 16)
                .onScrollVisibilityChange(threshold: 0.05) { visible in
                    model.noteVisible(entry.postID, visible)
                }
        } else {
            collapsedPostCard(entry)
                .padding(.bottom, 10)
                .onScrollVisibilityChange(threshold: 0.05) { visible in
                    model.noteVisible(entry.postID, visible)
                }
        }
    }

    /// The collapsed card (her referenced mockup: title, excerpt, meta —
    /// bordered, aligned with the book title). 13b 3E (N22 — her ruling:
    /// "clicking on the post should bring you to it, not just the smaller
    /// open button"): the card BODY opens the post in the full editor; the
    /// ▸ disclosure is the expand-in-place door. Each target does what it
    /// looks like.
    private func collapsedPostCard(_ entry: Queries.ReadingEntry) -> some View {
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
                    .help("Expand this post in place — read it right here")
                    Text(entryTitle(entry))
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
        .help("Click to open this post in the full editor; ▸ expands it in place")
        .id("page-\(entry.postID)")  // the scrubber's landing anchor
        .contextMenu { postChapterMenu(entry) }
    }

    private func postHeader(_ entry: Queries.ReadingEntry, expanded: Bool = false) -> some View {
        HStack(spacing: 6) {
            if expanded {
                // 13b 3E (D1): the ONE collapse door — releases focus too
                // (the model's rule), so collapsing the post you're typing
                // in actually collapses it.
                Button("▾") { model.collapse(entry.postID) }
                    .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
                    .help("Collapse this post back to its card")
            }
            Text(entryTitle(entry))
                .font(tokens.body.weight(.semibold))
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
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
            .help("Open this post in the full editor (Write · Takes · Lenses · …)")
        }
        .padding(.top, 4)
        .id("page-\(entry.postID)")  // the scrubber's landing anchor
        .contextMenu { postChapterMenu(entry) }
    }

    @ViewBuilder
    private func postBody(_ entry: Queries.ReadingEntry) -> some View {
        if model.focusedPostID == entry.postID {
            // The ONE live editor (P3 by construction: a single focused id).
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
            parseError = "Extents are plain numbers (e.g. 10000) — nothing was changed."
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
