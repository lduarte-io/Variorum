//
//  LibraryCatalogView.swift
//  Variorum
//
//  Phase 13, B2 — LIBRARY = EVERYTHING (R32: "all books, posts, and
//  blocks. like literally everything, sortable and searchable") with the
//  timeline folded in as a VIEW MODE (sitting 1/R5) and the tags column as
//  an ADDABLE batch-tagging surface (R46). The old sidebar post pile and
//  its context menu live here now; recovery + tutorial stay reachable from
//  the toolbar (and ⌘K).
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import SwiftUI
import UniformTypeIdentifiers
import VariorumCore

@MainActor
@Observable
final class LibraryCatalogModel {
    enum Scope: String, CaseIterable { case all, books, posts, blocks }
    /// 13g batch 6 (R5-6): `notes` joins as a THIRD view mode — her
    /// Apple-Notes-shaped list (title · date · the first bit of text · the
    /// book it's in). A mode beside the others, never a replacement.
    enum Mode: String, CaseIterable { case list, notes, timeline }

    @ObservationIgnored let session: AppSession
    var scope: Scope = .all
    var mode: Mode = .list
    /// Set by the view's binding, which also spawns `search()` — no hidden
    /// didSet task (deterministic under test; the generation guard orders
    /// the UI's unordered spawns).
    var query = ""
    private(set) var hits: [Queries.CatalogHit] = []
    private(set) var postTags: [String: [String]] = [:]
    /// 13g R5-6: postID → the note card's read-time extras (snippet +
    /// books). Loaded ONLY in `.notes` mode and only for the hits on
    /// screen — the same bounded-to-what-is-listed discipline as
    /// `postTags`.
    private(set) var noteCards: [String: NoteCards.Card] = [:]
    private(set) var lastError: String?
    /// Generation-stamped adoption (round 2, MINOR — the Phase 8 ruling):
    /// per-keystroke tasks are unordered; only the NEWEST read may land.
    private var searchGeneration = 0

    init(session: AppSession) {
        self.session = session
    }

    /// One-shot per typed query / scope change (the core query's contract);
    /// the resting state is books + recent posts.
    func search() async {
        searchGeneration += 1
        let generation = searchGeneration
        do {
            let query = query
            let all = try await session.database.read { db in
                try Queries.searchCatalog(db, query: query, limitPerKind: 40)
            }
            guard generation == searchGeneration else { return }  // stale
            hits = filtered(all)
            let postIDs = hits.filter { $0.kind == .post }.map(\.id)
            await loadTagChips(for: postIDs, generation: generation)
            await loadNoteCards(for: postIDs, generation: generation)
            lastError = nil
        } catch {
            guard generation == searchGeneration else { return }
            lastError = String(describing: error)
        }
    }

    func filtered(_ all: [Queries.CatalogHit]) -> [Queries.CatalogHit] {
        switch scope {
        case .all: return all
        case .books: return all.filter { $0.kind == .book }
        case .posts: return all.filter { $0.kind == .post }
        case .blocks: return all.filter { $0.kind == .block }
        }
    }

    /// The tags column's chips (bounded to the visible hits; ONE grouped
    /// query — round 2 NIT: the per-post loop was N round trips). The
    /// chips read is a SECOND suspension point, so it re-checks the
    /// generation before landing (round 3 MINOR: the round-2 guard
    /// covered `hits` but not `postTags` — gen 1's chips could resume
    /// last and describe the previous query's hits). Internal for the
    /// stale-generation pin.
    func loadTagChips(for postIDs: [String], generation: Int) async {
        guard !postIDs.isEmpty else {
            if generation == searchGeneration { postTags = [:] }
            return
        }
        do {
            let chips = try await session.database.read { db in
                try TagChips.load(db, postIDs: postIDs)
            }
            guard generation == searchGeneration else { return }  // stale chips never land
            postTags = chips
        } catch {
            guard generation == searchGeneration else { return }
            lastError = String(describing: error)
        }
    }

    /// 13g R5-6: the note cards' read-time extras. Costs NOTHING outside
    /// `.notes` mode (a mode she is not in must not pay for it), and inside
    /// it costs two grouped reads over the hits already on screen — the
    /// `loadTagChips` shape exactly, generation guard included, because a
    /// second suspension point can otherwise land a stale query's cards
    /// (the round-3 MINOR that taught this file the rule).
    func loadNoteCards(for postIDs: [String], generation: Int) async {
        guard mode == .notes, !postIDs.isEmpty else {
            if generation == searchGeneration, mode != .notes || postIDs.isEmpty {
                noteCards = [:]
            }
            return
        }
        do {
            let cards = try await session.database.read { db in
                try NoteCards.load(db, postIDs: postIDs)
            }
            guard generation == searchGeneration else { return }
            noteCards = cards
        } catch {
            guard generation == searchGeneration else { return }
            lastError = String(describing: error)
        }
    }

    /// The view calls this when the MODE changes (a mode switch does not
    /// re-run the search, and switching INTO notes must fill the cards).
    func refreshNoteCards() async {
        await loadNoteCards(
            for: hits.filter { $0.kind == .post }.map(\.id),
            generation: searchGeneration)
    }

    /// R46: the addable tags surface — apply one tag to MANY posts inline.
    func applyTag(_ tagID: String, to postIDs: [String]) async {
        do {
            try await session.runner.run { ops in
                for postID in postIDs {
                    do {
                        try ops.applyTag(tagID, toPost: postID)
                    } catch OperationError.alreadyTagged {
                        // Batch semantics: already-tagged is a no-op.
                    }
                }
            }
            await search()
        } catch {
            lastError = TagsViewModel.message(error)
        }
    }
}

struct LibraryCatalogView: View {
    let session: AppSession
    let model: LibraryCatalogModel
    let library: LibraryViewModel
    let tags: TagsViewModel
    let onOpen: (SidebarSelection) -> Void
    /// Stage C: block hits land caret-precise when the shell provides the
    /// door (nil falls back to plain navigation).
    var onOpenBlock: ((SidebarSelection, String) -> Void)? = nil
    /// 13f batch 4 (W1/A25): the split's row door.
    var onOpenBeside: ((String) -> Void)? = nil
    /// 13f batch 5b (W2/A26): the note-only window's row door.
    var onOpenInNewWindow: ((String) -> Void)? = nil
    /// 13f batch 6 (W4): the star door, from the one note-row grammar.
    var starDoor: StarDoor? = nil
    /// 13b Stage 2 ladder, MINOR-D6: the tutorial door routes through the
    /// shell's fire-and-DO act (`ShellActions.openTutorial` — failures
    /// speak; the old inline `try?` swallowed them silently while the
    /// ShellActions sibling spoke).
    let onOpenTutorial: () -> Void

    // Optional: test hosts (and future embeddings) may lack the
    // environment — fall back to the leading voice's tokens.
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    @State private var selectedPosts: Set<String> = []
    @State private var tagSheetTarget: SidebarView.TagSheetTarget?
    @State private var renameTarget: String?
    @State private var renameTitle = ""

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().overlay(tokens.line)
            switch model.mode {
            case .list: listBody
            case .notes: notesBody
            case .timeline:
                TimelineView(session: session) { postID in
                    onOpen(.post(postID))
                }
            }
            // Sitting 9 batch 8 (her directive): the round-2 mockup's
            // quick-entry bar rides the Library too — type, ⏎, and the
            // typed text IS a post, opened.
            Divider().overlay(tokens.line)
            QuickEntryBar(session: session, onOpen: onOpen)
        }
        .background(tokens.surface)
        .task { await model.search() }
        // 13g R5-6: switching INTO notes fills the cards; switching out
        // clears them, so a mode she is not in holds no derived text.
        .task(id: model.mode) { await model.refreshNoteCards() }
        .sheet(item: $tagSheetTarget) { target in
            TagAssignmentSheet(session: session, postID: target.id, postTitle: target.title)
        }
        .alert(
            "Rename Note",
            isPresented: Binding(
                get: { renameTarget != nil },
                set: { if !$0 { renameTarget = nil } }),
            presenting: renameTarget
        ) { postID in
            TextField("Title", text: $renameTitle)
            Button("Rename") {
                let title = renameTitle
                Task {
                    await library.rename(postID: postID, title: title)
                    await model.search()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .overlay(alignment: .bottomLeading) {
            if let error = model.lastError ?? library.lastError {
                Text(error)
                    .font(tokens.small)
                    .foregroundStyle(.red)
                    .textSelection(.enabled)
                    .padding(6)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(tokens.path(["Library"]))
                    .font(tokens.heading)
                    .foregroundStyle(tokens.accent)
                Text(tokens.chromeLabel("everything — sortable, searchable"))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                Spacer()
                Menu {
                    // 13f W10a: the label reads from `RecoveryPath`, which is
                    // also what the copy pointing here says — one name, so
                    // the sentence and the door can never drift apart.
                    Button(RecoveryPath.menuLabel) { onOpen(.recovery) }
                    // 13b Stage 2: the old entrance points at the tutorial
                    // BOOK (find-or-seed, then open) — via the shell's one
                    // fire-and-DO door (MINOR-D6: never a silent `try?`).
                    Button("Open the Tutorial") { onOpenTutorial() }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .menuStyle(.borderlessButton)
                .frame(width: 28)
            }
            HStack(spacing: 10) {
                TextField(tokens.chromeLabel("Search books, notes, blocks…"),
                          text: Binding(get: { model.query }, set: { value in
                              model.query = value
                              Task { await model.search() }
                          }))
                    .textFieldStyle(.roundedBorder)
                    .font(tokens.small)
                    .frame(maxWidth: 320)
                Picker("", selection: Binding(get: { model.scope }, set: { model.scope = $0; Task { await model.search() } })) {
                    ForEach(LibraryCatalogModel.Scope.allCases, id: \.self) { scope in
                        Text(tokens.chromeLabel(scope.rawValue.capitalized)).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 280)
                Picker("", selection: Binding(get: { model.mode }, set: { model.mode = $0 })) {
                    Text(tokens.chromeLabel("List")).tag(LibraryCatalogModel.Mode.list)
                    Text(tokens.chromeLabel("Notes")).tag(LibraryCatalogModel.Mode.notes)
                    Text(tokens.chromeLabel("Timeline")).tag(LibraryCatalogModel.Mode.timeline)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 230)
                if selectedPosts.count > 1 {
                    Menu(tokens.chromeLabel("Tag \(selectedPosts.count) notes")) {
                        ForEach(tags.tags, id: \.id) { tag in
                            Button(tag.path) {
                                let ids = Array(selectedPosts)
                                Task { await model.applyTag(tag.id, to: ids) }
                            }
                        }
                    }
                    .font(tokens.small)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 10)
    }

    private var listBody: some View {
        List(selection: $selectedPosts) {
            let grouped = Dictionary(grouping: model.hits, by: \.kind)
            if let books = grouped[.book], !books.isEmpty {
                Section(tokens.chromeLabel("Books")) {
                    ForEach(books, id: \.id) { hit in
                        HStack {
                            Image(systemName: "book").foregroundStyle(tokens.muted)
                            Text(hit.title).font(tokens.body)
                            if let detail = hit.detail {
                                Text(tokens.chromeLabel(detail))
                                    .font(tokens.small)
                                    .foregroundStyle(tokens.muted)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { onOpen(.reading(hit.id)) }
                    }
                }
            }
            if let posts = grouped[.post], !posts.isEmpty {
                Section(tokens.chromeLabel("Notes")) {
                    ForEach(posts, id: \.id) { hit in
                        postRow(hit)
                            .tag(hit.id)
                    }
                }
            }
            if let blocks = grouped[.block], !blocks.isEmpty {
                Section(tokens.chromeLabel("Blocks")) {
                    ForEach(blocks, id: \.id) { hit in
                        HStack {
                            Image(systemName: "square.on.square").foregroundStyle(tokens.muted)
                            Text(hit.title).font(tokens.small).lineLimit(1)
                            if let home = hit.detail {
                                Text(tokens.chromeLabel("in \(home)"))
                                    .font(tokens.small)
                                    .foregroundStyle(tokens.faint)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // A block hit opens its HOME surface (round 2,
                            // MINOR: dead rows violated fire-and-speak) —
                            // caret-precise where the shell offers the
                            // Stage C door.
                            if let home = hit.homeContainerID {
                                let selection: SidebarSelection =
                                    hit.homeIsPool ? .pool(home) : .post(home)
                                if let onOpenBlock {
                                    onOpenBlock(selection, hit.id)
                                } else {
                                    onOpen(selection)
                                }
                            }
                        }
                    }
                }
            }
            if model.hits.isEmpty {
                Text(tokens.chromeLabel("Nothing matches."))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
            }
        }
        .scrollContentBackground(.hidden)
        .background(tokens.surface)
    }

    /// 13g batch 6 (R5-6) — the Apple-Notes-shaped list: title · date ·
    /// the first bit of text · the book it's in, per her screenshot. NOTES
    /// ONLY (books and blocks have no snippet to show and belong to the
    /// List mode's sections); a `LazyVStack` so the rows cost what is drawn.
    private var notesBody: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                let posts = model.hits.filter { $0.kind == .post }
                ForEach(posts, id: \.id) { hit in
                    noteCard(hit)
                    Divider().overlay(tokens.line.opacity(0.6))
                }
                if posts.isEmpty {
                    Text(tokens.chromeLabel("No notes match."))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .padding(24)
                }
            }
            .padding(.horizontal, 20)
        }
        .background(tokens.surface)
    }

    private func noteCard(_ hit: Queries.CatalogHit) -> some View {
        let card = model.noteCards[hit.id] ?? NoteCards.Card()
        return VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(hit.title)
                    .font(tokens.body)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                if let date = hit.detail {
                    Text(tokens.chromeLabel(date))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                if !card.books.isEmpty {
                    Text(tokens.chromeLabel(card.books.joined(separator: " · ")))
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent.opacity(0.85))
                        .lineLimit(1)
                }
            }
            Text(card.snippet.isEmpty ? "No text yet" : card.snippet)
                .font(tokens.small)
                .foregroundStyle(card.snippet.isEmpty ? tokens.faint : tokens.muted)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture { onOpen(.post(hit.id)) }
        .contextMenu { postRowMenu(hit) }
        .help("Open this note")
    }

    private func postRow(_ hit: Queries.CatalogHit) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(hit.title)
                .font(tokens.body)
                .foregroundStyle(tokens.ink)
            if let date = hit.detail {
                Text(date).font(tokens.small).foregroundStyle(tokens.muted)
            }
            // The tags column (R46): chips + the addable "+".
            HStack(spacing: 4) {
                ForEach(model.postTags[hit.id] ?? [], id: \.self) { path in
                    Text("#\(path)")
                        .font(tokens.small)
                        .foregroundStyle(tokens.accent.opacity(0.85))
                }
                Menu {
                    ForEach(tags.tags, id: \.id) { tag in
                        Button(tag.path) {
                            Task { await model.applyTag(tag.id, to: [hit.id]) }
                        }
                    }
                    Divider()
                    Button("Tags…") {
                        tagSheetTarget = .init(id: hit.id, title: hit.title)
                    }
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 10))
                        .foregroundStyle(tokens.faint)
                }
                .menuStyle(.borderlessButton)
                .frame(width: 22)
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture { onOpen(.post(hit.id)) }
        .draggable(hit.id)
        .contextMenu { postRowMenu(hit) }
    }

    /// 13g R5-6: ONE note-row menu, two renderers (the List mode's row and
    /// the Notes mode's card) — the `.openBeside` shape, so the two lists
    /// can never offer different doors on the same note.
    @ViewBuilder
    private func postRowMenu(_ hit: Queries.CatalogHit) -> some View {
        Button("Open") { onOpen(.post(hit.id)) }
        if let onOpenBeside {
            Button(WorkspaceNaming.openBesideVerb) { onOpenBeside(hit.id) }
        }
        if let starDoor {
            Button(starDoor.title(for: .post(hit.id))) { starDoor.toggle(.post(hit.id)) }
        }
        if let onOpenInNewWindow {
            Button(CapabilityRegistry.capability(.openInNewWindow).verb) {
                onOpenInNewWindow(hit.id)
            }
        }
        Button("Rename…") {
            // 13g batch 7 (R6-3): a hit's `title` is already the display
            // answer, so a note showing its DATE must not seed the field
            // with that date — she would be naming it after itself.
            renameTitle = hit.storedTitle ?? ""
            renameTarget = hit.id
        }
        Button("Tags…") {
            tagSheetTarget = .init(id: hit.id, title: hit.title)
        }
        Divider()
        // version_of DOOR 1 (Phase 11 A2's TWO-door ratification —
        // round 2, MAJOR 5: dropped in the sidebar→Library move,
        // restored verbatim; the same op door 2 emits).
        Menu("Mark as Versions with") {
            ForEach(library.posts.filter { $0.postID != hit.id }, id: \.postID) { other in
                Button(other.displayTitle) {
                    Task { await library.markAsVersions(hit.id, other.postID) }
                }
            }
        }
        // Sitting 9 (R60/R68): the inverse door beside the mark — an
        // unlinked pick speaks its refusal instead of silently no-oping.
        Menu("Unmark Versions with") {
            ForEach(library.posts.filter { $0.postID != hit.id }, id: \.postID) { other in
                Button(other.displayTitle) {
                    Task { await library.unmarkVersions(hit.id, other.postID) }
                }
            }
        }
        Button("Duplicate as Version") {
            Task { await library.duplicateAsVersion(postID: hit.id) }
        }
        Divider()
        // The per-post export doors (Phase 11b B1's ratified context-
        // menu shapes — round 2, MAJOR 5: restored).
        Menu("Export") {
            Button("Markdown…") { exportPost(hit, includeVariants: false) }
            Button("Markdown with Takes…") { exportPost(hit, includeVariants: true) }
            Button("PDF…") { exportPostPDF(hit) }
        }
        Divider()
        Button("Archive") {
            Task {
                await library.archive(postID: hit.id)
                await model.search()
            }
        }
        Button("Delete", role: .destructive) {
            Task {
                await library.delete(postID: hit.id)
                await model.search()
            }
        }
    }

    // MARK: - Export doors (Phase 11b B1's ratified shapes, restored —
    // round 2, MAJOR 5; the panel is the author-visible moment, the
    // projection shapes live in Queries)

    private func exportPost(_ hit: Queries.CatalogHit, includeVariants: Bool) {
        let name = exportFileName(hit)
        guard let url = ExportPanels.saveFile(
            defaultName: "\(name).md", type: .markdownFile) else { return }
        Task {
            let exporter = ExportModel(session: session)
            if let markdown = await exporter.markdown(
                forPost: hit.id, includeVariants: includeVariants) {
                exporter.writeMarkdown(markdown, to: url)
            }
        }
    }

    private func exportPostPDF(_ hit: Queries.CatalogHit) {
        let name = exportFileName(hit)
        guard let url = ExportPanels.saveFile(
            defaultName: "\(name).pdf", type: .pdf) else { return }
        Task {
            let exporter = ExportModel(session: session)
            if let data = await exporter.pdfData(forPost: hit.id) {
                exporter.writePDF(data, to: url)
            }
        }
    }

    private func exportFileName(_ hit: Queries.CatalogHit) -> String {
        // 13g batch 7 (R6-3): the hit's name is already the display brain's
        // answer, so the date case needs no second test here — a note with
        // no name exports as its date, which is what the bulk manifest has
        // named it since 11b.
        let title = Queries.sanitizedFilename(hit.title)
        return title.isEmpty ? DisplayTitle.placeholder : title
    }
}

/// One grouped tag-chip load shared by the Library and the Pool (round 2
/// NIT: the per-post loops were N round trips each).
/// 13g batch 6 (R5-6) — the Apple-Notes-shaped row's two read-time extras.
///
/// Her ask: *"I also want to make a different view in the library that is
/// more similar to the apple notes view where you can see the first little
/// bit of text."*
///
/// NOTHING IS STORED (the no-denormalization rule): the snippet is derived
/// on every read from the blocks themselves, and the books come from the
/// membership rows. Both are **bounded twice** — to the posts already
/// listed (the catalog's own limit), and, for the snippet, to each post's
/// FIRST FEW BLOCKS via a window function, so a 10,000-block note costs the
/// same as a three-block one (P1: cost ∝ what is listed, never ∝ the note).
///
/// Two honest simplifications, recorded rather than hidden:
///   · the snippet resolves `chosen → default` and requires that variant to
///     be live; the editor's full read-time rule ALSO falls back when the
///     chosen take is archived. A snippet that goes to the next block in
///     that corner is a display aid behaving conservatively, not a second
///     rendering brain — `renderPost` remains the one that matters;
///   · the books are CURATED memberships. A smart book's membership is
///     derived by walking its filter, which is what the membership chip does
///     for ONE note and must not be done for forty rows (the `PaneHost`
///     one-shot's stated reason).
enum NoteCards {
    struct Card: Equatable {
        var snippet: String = ""
        var books: [String] = []
    }

    /// How many leading blocks a snippet may consult before giving up.
    nonisolated static let blockWindow = 3
    /// How much text a snippet may carry (the row shows ~2 lines).
    nonisolated static let snippetLimit = 220

    nonisolated static func load(
        _ db: Database, postIDs: [String]
    ) throws -> [String: Card] {
        let json = String(
            decoding: (try? JSONEncoder().encode(postIDs)) ?? Data("[]".utf8),
            as: UTF8.self)
        var result: [String: Card] = [:]

        let snippets = try Row.fetchAll(
            db,
            sql: """
                SELECT post_id, text FROM (
                  SELECT cb.container_id AS post_id,
                         substr(COALESCE(v.working_text, ''), 1, \(snippetLimit)) AS text,
                         ROW_NUMBER() OVER (
                           PARTITION BY cb.container_id ORDER BY cb.position, cb.id
                         ) AS n
                  FROM container_block cb
                  JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                  LEFT JOIN variant v
                    ON v.id = COALESCE(cb.chosen_variant_id, b.default_variant_id)
                   AND v.deleted_at IS NULL
                  WHERE cb.deleted_at IS NULL
                    AND cb.container_id IN (SELECT value FROM json_each(?))
                ) WHERE n <= \(blockWindow)
                ORDER BY post_id, n
                """,
            arguments: [json])
        for row in snippets {
            let postID: String = row["post_id"]
            guard result[postID]?.snippet.isEmpty ?? true else { continue }
            let text = (row["text"] as String? ?? "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else {
                result[postID, default: Card()].snippet = ""
                continue
            }
            result[postID, default: Card()].snippet = text
        }

        let books = try Row.fetchAll(
            db,
            sql: """
                SELECT rp.post_id AS post_id, r.name AS name
                FROM reading_post rp
                JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL
                WHERE rp.deleted_at IS NULL
                  AND rp.post_id IN (SELECT value FROM json_each(?))
                ORDER BY rp.post_id, r.name
                """,
            arguments: [json])
        for row in books {
            result[row["post_id"] as String, default: Card()].books.append(row["name"])
        }
        return result
    }
}

enum TagChips {
    nonisolated static func load(
        _ db: Database, postIDs: [String]
    ) throws -> [String: [String]] {
        let json = String(
            decoding: (try? JSONEncoder().encode(postIDs)) ?? Data("[]".utf8),
            as: UTF8.self)
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT pt.post_id AS post_id, t.path AS path
                FROM post_tag pt
                JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                WHERE pt.deleted_at IS NULL
                  AND pt.post_id IN (SELECT value FROM json_each(?))
                ORDER BY pt.post_id, t.path
                """,
            arguments: [json])
        var result: [String: [String]] = [:]
        for row in rows {
            result[row["post_id"] as String, default: []].append(row["path"])
        }
        return result
    }
}
