//
//  LibraryInfoPanel.swift
//  Variorum (Mac)
//
//  pre-13u Act 10, item 10 — **THE CONTEXT-AWARE RIGHT PANEL (ruled in).**
//  Her sitting ruling gave the library an "extra information" panel on the
//  right, fed by her click model: a click on the ROW BODY selects and shows
//  it (the old dead highlight becomes a meaning), the TITLE still opens
//  instantly, a DOUBLE-CLICK anywhere opens. Content latitude is the
//  implementer's — her direction: *"if it's locked, associated tag… # of
//  words? notes? last edited? the type of thing people want in a library"*
//  — per kind (note vs book).
//
//  The panel is the note-side inspector's SIBLING: same column widths as
//  the tray/versions/history panes, so moving between a note and the
//  library keeps the right region one steady thing (the act's principle:
//  regions visibly become things or visibly leave — never teleport).
//
//  Reads are ONE-SHOT per selection (the `NoteCards` discipline): a click
//  loads a bounded set of facts about ONE item; nothing is held at write
//  rate. Word counting is the one shared rule (`Queries.wordCount`).
//

import GRDB
import SwiftUI
import VariorumCore

/// The facts the panel shows — loaded in one read, per kind.
nonisolated enum LibraryInfoFacts {
    struct NoteFacts: Equatable, Sendable {
        var words = 0
        var blocks = 0
        /// Blocks carrying more than one live take — "fanned" is the fact a
        /// library reader wants, not the raw take total.
        var fannedBlocks = 0
        var comments = 0
        var sealed = false
        var archived = false
        var entryDate: String?
        var created: String?
        var lastEdited: String?
        var books: [String] = []
        var tags: [Tag] = []
    }

    struct BookFacts: Equatable, Sendable {
        var kind: ReadingKind = .curated
        var finished = false
        var notes = 0
        var chapters = 0
        var wordTarget: Int?
        var maxPosts: Int?
        var created: String?
    }

    /// A day out of a stored stamp — the panel's dates are glanceable, not
    /// forensic.
    static func day(_ date: Date?) -> String? {
        guard let date else { return nil }
        return JournalDay.dayString(from: date)
    }

    static func note(_ db: Database, id: String) throws -> NoteFacts? {
        guard let container = try Container.fetchOne(db, key: id) else { return nil }
        var facts = NoteFacts()
        let slots = try Queries.renderPost(db, containerID: id)
        facts.blocks = slots.count
        facts.words = slots.compactMap(\.text).reduce(0) { $0 + Queries.wordCount($1) }
        facts.fannedBlocks = slots.filter { $0.activeVariantCount > 1 }.count
        facts.comments = slots.reduce(0) { $0 + $1.commentCount }
        facts.sealed = container.locked
        facts.archived = container.archivedAt != nil
        facts.entryDate = container.entryDate
        facts.created = day(container.createdAt)
        facts.lastEdited = day(container.lastMajorRevisionAt ?? container.lastTouchedAt)
        facts.books = try Queries.readingsContaining(db, postID: id).map(\.name)
        facts.tags = try Queries.postTags(db, postID: id)
        return facts
    }

    static func book(_ db: Database, id: String) throws -> BookFacts? {
        guard let reading = try Reading.fetchOne(db, key: id) else { return nil }
        var facts = BookFacts()
        facts.kind = reading.kind
        facts.finished = reading.locked
        facts.wordTarget = reading.wordTarget
        facts.maxPosts = reading.maxPosts
        facts.created = day(reading.createdAt)
        // The assembly handles both kinds (smart membership is derived) and
        // honors a cap exactly as the book view renders it.
        facts.notes = try Queries.assembleReading(db, readingID: id).count
        facts.chapters = try Int.fetchOne(
            db,
            sql: """
                SELECT COUNT(*) FROM reading_section
                WHERE reading_id = ? AND deleted_at IS NULL
                """,
            arguments: [id]) ?? 0
        return facts
    }
}

/// The panel itself — calm cards on the W8-2 grammar, one generous Open
/// door, facts in a quiet grid.
struct LibraryInfoPanel: View {
    let session: AppSession
    let hit: Queries.CatalogHit
    /// The ⌘-click pick's size — past one, the panel summarizes the pick
    /// (the bulk doors live in the header bar, and the panel says so).
    var multiCount: Int = 0
    let onOpen: () -> Void
    let onClose: () -> Void

    @State private var noteFacts: LibraryInfoFacts.NoteFacts?
    @State private var bookFacts: LibraryInfoFacts.BookFacts?
    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(hit.title)
                    .font(tokens.heading)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(2)
                Spacer()
                Button("Close") { onClose() }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
            }
            Text(tokens.chromeLabel(kindLine))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
            if multiCount > 1 {
                CalmCard(tokens: tokens) {
                    Text(tokens.chromeLabel(
                        "\(multiCount) notes selected — the Tag, Untag and "
                        + "Delete doors above act on all of them."))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Button(hit.kind == .book ? "Open Book" : "Open Note") { onOpen() }
                .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
                .help("Open this — a double-click on the row does the same")
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if let noteFacts { noteGrid(noteFacts) }
                    if let bookFacts { bookGrid(bookFacts) }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(minWidth: 280, maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(tokens.surface)
        .task(id: hit.id) { await load() }
    }

    private var kindLine: String {
        switch hit.kind {
        case .book:
            if let bookFacts {
                let kind = bookFacts.kind == .smart ? "smart book" : "book"
                return bookFacts.finished ? "\(kind) · finished" : kind
            }
            return "book"
        case .post:
            var pieces = ["note"]
            if let noteFacts {
                if noteFacts.sealed { pieces.append("sealed") }
                if noteFacts.archived { pieces.append("archived") }
            }
            return pieces.joined(separator: " · ")
        case .block:
            return "block"
        }
    }

    @ViewBuilder private func noteGrid(_ facts: LibraryInfoFacts.NoteFacts) -> some View {
        CalmCard(tokens: tokens) {
            VStack(alignment: .leading, spacing: 5) {
                factRow("words", "\(facts.words.formatted())")
                factRow("blocks", "\(facts.blocks)")
                if facts.fannedBlocks > 0 {
                    factRow("with takes", "\(facts.fannedBlocks)")
                }
                if facts.comments > 0 {
                    factRow("comments", "\(facts.comments)")
                }
                if let entry = facts.entryDate { factRow("entry date", entry) }
                if let edited = facts.lastEdited { factRow("last edited", edited) }
                if let created = facts.created { factRow("created", created) }
            }
        }
        if !facts.books.isEmpty {
            CalmSectionHeader(tokens: tokens, title: "in books")
            CalmCard(tokens: tokens) {
                Text(tokens.chromeLabel(facts.books.joined(separator: " \u{B7} ")))
                    .font(tokens.small)
                    .foregroundStyle(tokens.accent)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        if !facts.tags.isEmpty {
            CalmSectionHeader(tokens: tokens, title: "tags")
            // The cards' read-only face: the panel shows; the row's own ＋/✕
            // and the masthead cluster stay the editing doors.
            CalmCard(tokens: tokens) {
                Text(tokens.chromeLabel(
                    facts.tags.map { TagChipLabel.leaf(of: $0.path) }
                        .joined(separator: " \u{B7} ")))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder private func bookGrid(_ facts: LibraryInfoFacts.BookFacts) -> some View {
        CalmCard(tokens: tokens) {
            VStack(alignment: .leading, spacing: 5) {
                factRow("notes", "\(facts.notes)")
                if facts.chapters > 0 { factRow("chapters", "\(facts.chapters)") }
                if let target = facts.wordTarget {
                    factRow("word target", "\(target.formatted())")
                }
                if let cap = facts.maxPosts { factRow("note cap", "\(cap)") }
                if let created = facts.created { factRow("created", created) }
            }
        }
    }

    private func factRow(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(tokens.chromeLabel(label))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .frame(width: 84, alignment: .leading)
                .lineLimit(1)
            Text(tokens.chromeLabel(value))
                .font(tokens.small)
                .foregroundStyle(tokens.ink)
                .lineLimit(2)
        }
    }

    private func load() async {
        noteFacts = nil
        bookFacts = nil
        switch hit.kind {
        case .post:
            noteFacts = try? await session.database.read { [id = hit.id] db in
                try LibraryInfoFacts.note(db, id: id)
            }
        case .book:
            bookFacts = try? await session.database.read { [id = hit.id] db in
                try LibraryInfoFacts.book(db, id: id)
            }
        case .block:
            break
        }
    }
}
