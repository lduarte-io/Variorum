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
    @State private var focus = BookFocusState()

    /// `model` is injectable for tests (hosted `.task` appearance callbacks
    /// don't fire under the test host — tests drive `adopt` by hand).
    init(
        session: AppSession, readingID: String, readingName: String? = nil,
        model: BookViewModel? = nil
    ) {
        self.session = session
        self.readingID = readingID
        self.readingName = readingName
        _model = State(initialValue: model ?? BookViewModel(session: session, readingID: readingID))
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
            case .read:
                ReadingFlowView(
                    session: session,
                    readingName: readingName ?? model.readingName,
                    grouped: structure.chaptersActive
                        ? structure.grouped(entries: model.entries)
                        : [(nil, model.entries)],
                    onWake: { postID in
                        structure.mode = .book
                        focus.focus(postID)
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
                    Picker("", selection: Binding(
                        get: { structure.mode == .read },
                        set: { structure.mode = $0 ? .read : .book })) {
                        Text(tokens.chromeLabel("Book")).tag(false)
                        Text(tokens.chromeLabel("Read")).tag(true)
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
                                    // chapter (the flow view shows it too).
                                    scrollTarget = "chapter-\(section.id)"
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
                                    structure.mode = .book
                                    focus.focus(entry.postID)
                                    scrollTarget = "page-\(entry.postID)"
                                } label: {
                                    Text(entryTitle(entry))
                                        .font(tokens.small)
                                        .foregroundStyle(
                                            focus.focusedPostID == entry.postID
                                                ? tokens.ink : tokens.muted)
                                        .lineLimit(1)
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
                                    focus.focus(id)
                                }
                            }
                        }
                        .buttonStyle(.borderless)
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent)
                    }
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
                                postHeader(entry)
                                postBody(entry)
                                    .padding(.bottom, 16)
                            }
                        }
                    } else {
                        ForEach(Array(model.entries.enumerated()), id: \.element.postID) { i, entry in
                            if let section = model.sectionHeader(at: i) {
                                Text(section)
                                    .font(tokens.heading)
                                    .padding(.top, 12)
                            }
                            postHeader(entry)
                            postBody(entry)
                                .padding(.bottom, 16)
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
                }
                // R9 (Phase 13 C1): the book page is a bounded, centered
                // prose column — text never runs near the window edge.
                .frame(maxWidth: 760, alignment: .leading)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
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

    private func chapterHeader(_ section: ReadingSection) -> some View {
        HStack(spacing: 6) {
            Text("⠿")
                .foregroundStyle(tokens.faint)
                .help("Chapters reorder from the navigator (Move Up / Move Down)")
            Text(tokens.chromeLabel(section.name))
                .font(tokens.heading)
                .foregroundStyle(tokens.accent)
        }
        .padding(.top, 16)
        .id("chapter-\(section.id)")
        .contextMenu { chapterMenu(section) }
    }

    private func entryTitle(_ entry: Queries.ReadingEntry) -> String {
        entry.title?.isEmpty == false ? entry.title! : (entry.entryDate ?? "Untitled")
    }

    private func scrubTitle(_ entry: Queries.ReadingEntry) -> String {
        let index = model.entries.firstIndex { $0.postID == entry.postID } ?? 0
        return "Page \(index + 1) of \(model.entries.count) — \(entryTitle(entry))"
    }

    private func postHeader(_ entry: Queries.ReadingEntry) -> some View {
        HStack(spacing: 6) {
            Text(entryTitle(entry))
                .font(tokens.body.weight(.semibold))
            if let date = entry.entryDate {
                Text(date)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
            }
        }
        .padding(.top, 4)
        .id("page-\(entry.postID)")  // the scrubber's landing anchor
        .contextMenu { postChapterMenu(entry) }
    }

    @ViewBuilder
    private func postBody(_ entry: Queries.ReadingEntry) -> some View {
        if focus.focusedPostID == entry.postID {
            // The ONE live editor (P3 by construction: a single focused id).
            EditorView(
                session: session, postID: entry.postID, inline: true,
                caretSeed: focus.caretSeed, fanSeed: focus.fanSeed)
                .id(entry.postID)
        } else {
            ReadPostView(
                session: session, postID: entry.postID,
                onFocusRequest: { offset in
                    focus.focus(entry.postID, caret: offset)
                },
                onBadgeTap: { blockID in
                    // Interpretation 1 (PROVISIONAL): focus FIRST, then the
                    // fan panel opens on the one live surface.
                    focus.focus(entry.postID, fanBlock: blockID)
                })
                .id("read-\(entry.postID)")
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
