//
//  LibraryInfoPanel.swift
//  Variorum (Mac)
//
//  pre-13u Act 10, item 10 gave the library a context-aware right panel fed
//  by her click model (a click on the ROW BODY selects and shows it, the
//  TITLE opens, a DOUBLE-CLICK anywhere opens). It shipped as a FACTS panel.
//
//  **The Act 10 correction round, batch E — THE SIMPLE READ PREVIEW (rows 1,
//  33; R-cor-3 as ratified at R-cor-10(1)).** Her words: *"the library peek
//  should be quite simple, with an easy way to go into the note and have the
//  place where your cursor was saved at any point (no need to render a whole
//  write surface with takes, blocks, everything). Or we can make it so that
//  the library just has a view and you have to click into it to edit it -
//  that's the safer choice, and the read view + metadata still has value."*
//  And: *"when I click on a book, i just still see the last note i clicked
//  on - obviously bad. a book could show the outline that it has."*
//
//  So the panel is exactly that: a NOTE shows its title, ONE calm facts line
//  (words · blocks · last edited — nothing more, C-6), ONE generous **Open**
//  door that lands where the caret last was (batch C's `CurrentBlockMemory`,
//  read by the mounting detail — no door of its own here; since 18l U0c her
//  R-18l-1 supersedes that for the session's FIRST open, which shows the
//  note's start, while a re-open this session lands where she was), and the note's
//  RENDERED TEXT, read-cheap: a lazy stack of per-block rows on the
//  `FlowParagraph` tier (the same SwiftUI `Text` tier the note's Read page
//  uses — never the TK2 `ReadPostView`, so row 54's provisional-width first
//  measure does not reach this panel). A BOOK shows its name, a facts line,
//  **Open Book**, and its OUTLINE in the navigator's own grammar (chapters,
//  notes; row 8's one-note-chapter collapse); a note row opens the book AT
//  that note through batch B's reveal road. Nothing in the panel is editable.
//
//  Reads are ONE-SHOT per selection (the `NoteCards` discipline): a click
//  loads ONE item's blocks (or one book's rows) in one read — ∝ the item,
//  once; the rows then render lazily (P1: what is on screen). Nothing is
//  held at write rate. The brain (`LibraryPreview`) is pure and pinned; the
//  view renders it.
//

import GRDB
import SwiftUI
import VariorumCore

// MARK: - The brain

/// What a selected note or book SHOWS — loaded in one read, per kind.
nonisolated enum LibraryPreview {
    /// One block of the note's rendered text, in placement order.
    struct Block: Equatable, Sendable, Identifiable {
        /// The placement's id — unique per note by construction (I2).
        let id: String
        let blockID: String
        let text: String
    }

    struct NotePreview: Equatable, Sendable {
        var words = 0
        var blocks: [Block] = []
        /// **When the note was last edited** — the SAME fact the Library's row
        /// beside it says (`container.last_touched_at`, falling back to the
        /// mint: `Queries.noteStamps`' rule). VX-351 (the VX-348 run, U4 —
        /// PROVISIONAL P-VX351-2): it was the last MAJOR revision, a second
        /// fact under the same verb, so the row and the panel could name two
        /// different times as "edited" for one note on one screen.
        var editedAt: Date?
        var sealed = false
        var archived = false

        /// The calm facts line — the ONE line the panel shows under the title.
        var factsLine: String { factsLine(now: Date()) }

        /// The facts line, worded by the ONE stamp brain (VX-351, her
        /// R-VX348-1/3: *edited today 1:33 AM* · *edited yesterday* · *edited
        /// Sep 9* — the List row's own words; the raw day key this line used
        /// to print, `edited 2026-10-13`, was a second wording rule).
        func factsLine(
            now: Date, calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
        ) -> String {
            LibraryPreview.factsLine(
                words: words, blocks: blocks.count,
                edited: editedAt.map {
                    TimeStampFace.relative($0, now: now, calendar: calendar, locale: locale)
                },
                sealed: sealed, archived: archived)
        }

        /// **The line's hover — the whole fact** (VX-351): *Edited Oct 13,
        /// 2026 at 4:02 PM*. nil when the note has no stamp to spell.
        func factsHelp(
            calendar: Calendar = JournalDay.storeCalendar, locale: Locale = .current
        ) -> String? {
            editedAt.map { TimeStampFace.tooltip(.edited, date: $0, calendar: calendar, locale: locale) }
        }
    }

    /// One row of a book's outline in the panel — the navigator's rows,
    /// flattened for the panel's one lazy stack. Strings only, so the state
    /// carries nothing heavier than what it draws.
    enum OutlineRow: Equatable, Sendable, Identifiable {
        /// A chapter. `opensPostID` is the note a click lands on: the
        /// chapter's ONE same-named note when the line collapses into the
        /// chapter (row 8's rule — `collapsed`), else the chapter's first
        /// note; nil for an empty chapter (the click opens the book plainly).
        case chapter(id: String, name: String, opensPostID: String?, collapsed: Bool)
        /// The trailing "unfiled" heading, or a smart book's tag-path heading.
        case heading(id: String, name: String)
        /// A note; `indented` under a chapter.
        case note(postID: String, title: String, indented: Bool)

        var id: String {
            switch self {
            case .chapter(let id, _, _, _): "chapter-\(id)"
            case .heading(let id, _): "heading-\(id)"
            case .note(let postID, _, _): "note-\(postID)"
            }
        }
    }

    struct BookPreview: Equatable, Sendable {
        var kind: ReadingKind = .book
        var finished = false
        var chapters = 0
        var notes = 0
        var rows: [OutlineRow] = []

        var factsLine: String {
            LibraryPreview.bookFactsLine(
                kind: kind, finished: finished, chapters: chapters, notes: notes)
        }
    }

    /// `N words · N blocks · edited <when>` — and the quiet state words only
    /// when they are true. Nothing else (C-6: no metric without a reason; the
    /// row already wears the tags, the masthead the books).
    static func factsLine(
        words: Int, blocks: Int, edited: String?, sealed: Bool, archived: Bool
    ) -> String {
        var pieces = [
            "\(words.formatted()) word\(words == 1 ? "" : "s")",
            "\(blocks) block\(blocks == 1 ? "" : "s")",
        ]
        if let edited { pieces.append("edited \(edited)") }
        if sealed { pieces.append("sealed") }
        if archived { pieces.append("archived") }
        return pieces.joined(separator: " \u{B7} ")
    }

    /// `book · N chapters · N notes` (`gathering`; `finished` when so).
    /// 13i-d U6 (a): "gathering", never "smart book" (the sitting record §1 —
    /// "smart" retired app-wide, §14).
    static func bookFactsLine(kind: ReadingKind, finished: Bool, chapters: Int, notes: Int) -> String {
        var pieces = [kind == .gathering ? "gathering" : "book"]
        if chapters > 0 { pieces.append("\(chapters) chapter\(chapters == 1 ? "" : "s")") }
        pieces.append("\(notes) note\(notes == 1 ? "" : "s")")
        if finished { pieces.append("finished") }
        return pieces.joined(separator: " \u{B7} ")
    }

    static func note(_ db: Database, id: String) throws -> NotePreview? {
        guard let container = try Container.fetchOne(db, key: id) else { return nil }
        var preview = NotePreview()
        let slots = try Queries.renderPost(db, containerID: id)
        // A gap slot (a sync-race state, SyncSpec §5) renders as an empty
        // row rather than vanishing — the panel shows the note's SHAPE.
        preview.blocks = slots.map {
            Block(id: $0.placementID, blockID: $0.blockID, text: $0.text ?? "")
        }
        preview.words = slots.compactMap(\.text).reduce(0) { $0 + Queries.wordCount($1) }
        preview.sealed = container.locked
        preview.archived = container.archivedAt != nil
        preview.editedAt = container.lastTouchedAt ?? container.createdAt
        return preview
    }

    static func book(_ db: Database, id: String) throws -> BookPreview? {
        guard let reading = try Reading.fetchOne(db, key: id) else { return nil }
        var preview = BookPreview()
        preview.kind = reading.kind
        preview.finished = reading.locked
        // The book's OWN three reads (`BookStructureModel` + `BookViewModel`),
        // grouped by the book's own rule — the panel invents no order.
        let entries = try Queries.assembleReading(db, readingID: id)
        let sections = try Queries.readingSections(db, readingID: id)
        preview.notes = entries.count
        preview.chapters = sections.count
        let rows: [BookOutlineRows.Row]
        if reading.kind == .book, !sections.isEmpty {
            let assignments = try Queries.sectionAssignments(db, readingID: id)
            rows = BookOutlineRows.rows(grouped: BookStructureModel.grouped(
                entries: entries, sections: sections, assignments: assignments))
        } else {
            rows = BookOutlineRows.rows(flat: entries)
        }
        preview.rows = outline(rows: rows)
        return preview
    }

    /// The navigator's rows → the panel's rows. Pure: row 8's collapse (a
    /// chapter whose ONE note says its name shows ONE row that opens the
    /// note) and the chapter's first-note door are decided here, pinned.
    static func outline(rows: [BookOutlineRows.Row]) -> [OutlineRow] {
        var result: [OutlineRow] = []
        var i = 0
        while i < rows.count {
            switch rows[i] {
            case .chapter(let section):
                // The chapter's notes are the `.note` rows that follow it.
                var notes: [Queries.ReadingEntry] = []
                var j = i + 1
                while j < rows.count, case .note(let entry) = rows[j] {
                    notes.append(entry)
                    j += 1
                }
                let collapsed = BookOutlineRows.noteLineCollapsesIntoChapter(
                    section: section, entries: notes)
                result.append(.chapter(
                    id: section.id, name: section.name,
                    opensPostID: notes.first?.postID, collapsed: collapsed))
                if !collapsed {
                    for entry in notes {
                        result.append(.note(
                            postID: entry.postID, title: entry.displayTitle, indented: true))
                    }
                }
                i = j
            case .unfiledHeading:
                result.append(.heading(id: "unfiled", name: "unfiled"))
                i += 1
            case .tagHeading(let path, let ordinal):
                result.append(.heading(id: "path-\(ordinal)", name: path))
                i += 1
            case .note(let entry):
                // A note under a heading (unfiled / a tag path) or in a flat
                // book: indented under a heading, flush in a flat book.
                let underHeading: Bool = {
                    guard let last = result.last else { return false }
                    switch last {
                    case .heading, .chapter: return true
                    case .note(_, _, let indented): return indented
                    }
                }()
                result.append(.note(
                    postID: entry.postID, title: entry.displayTitle, indented: underHeading))
                i += 1
            }
        }
        return result
    }
}

/// The panel column's width — the note-side inspector's own ideal (the
/// panel is that column's sibling: same widths at a roomy window, so moving
/// between a note and the library keeps the right region one steady thing),
/// a third of the library between, clamped to the room the library has.
/// Pure, pinned.
///
/// **VX-350 (the VX-348 run, U3) — it adjusts as the window narrows.** Her
/// words: *"the library's side pane is not adjusting, as you make the window
/// smaller it just gets steadily cut off"* (its Close button gone past the
/// window's edge). It held the note-side column's 280-pt minimum while the
/// list column beside it could not shrink below its controls row, so the two
/// together overflowed the window and the panel was pushed off. Now its
/// floor is 200 pt (the third keeps shrinking it until then — PROVISIONAL
/// P-VX350-4) and it is never wider than the library itself; the catalog
/// gives it its width FIRST and the list column takes the rest (the list,
/// never the panel, yields when the window is narrower than both can hold).
nonisolated enum LibraryPanelLayout {
    static let ideal: CGFloat = 420
    /// The narrowest the third takes the panel (VX-350 — was the note-side
    /// column's 280).
    static let minimum: CGFloat = 200
    /// The share of the library's width the panel takes when the ideal does
    /// not fit beside a usable list.
    static let share: CGFloat = 0.34

    static func width(total: CGFloat) -> CGFloat {
        guard total > 0 else { return ideal }   // unmeasured: the ideal
        let wanted = min(ideal, max(minimum, (total * share).rounded(.down)))
        // Never wider than the library (the 1-pt divider beside it): the
        // panel stays whole on screen at any width.
        return min(wanted, max(0, total - 1))
    }
}

// MARK: - The panel

/// The panel itself: title · the facts line · the one Open door · the
/// preview (the note's text, or the book's outline). Calm, read-only.
struct LibraryInfoPanel: View {
    let session: AppSession
    let hit: Queries.CatalogHit
    /// The ⌘-click pick's size — past one, the panel says the bulk doors
    /// above act on all of them.
    var multiCount: Int = 0
    /// The one door: open this note (landing where the caret last was) or
    /// this book.
    let onOpen: () -> Void
    /// A book outline's row: open the book AT this note (batch B's reveal).
    var onOpenBookAt: ((String) -> Void)? = nil
    let onClose: () -> Void

    @State private var note: LibraryPreview.NotePreview?
    @State private var book: LibraryPreview.BookPreview?
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
                // VX-350: the Close door keeps its word at any panel width —
                // the title gives way (its two lines), never the door.
                Button("Close") { onClose() }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
                    .lineLimit(1)
                    .fixedSize()
            }
            Text(tokens.chromeLabel(factsLine))
                .font(tokens.small)
                .foregroundStyle(tokens.muted)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                // VX-351: the whole fact on hover (the List row's own rule).
                .help(factsHelp ?? "")
            if multiCount > 1 {
                CalmCard(tokens: tokens) {
                    // 13n-c UX walk W-UX-3 / T-12: the doors are named by
                    // where they are, so a fourth (Share) is never left out.
                    Text(tokens.chromeLabel(LibraryCopy.pickedPanelLine(multiCount)))
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            // ONE generous door (C-7's "generous targets"): the whole width.
            Button {
                onOpen()
            } label: {
                Text(hit.kind == .book ? "Open Book" : "Open")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
            .help(hit.kind == .book
                  ? "Open this book — a double-click on the row does the same"
                  : "Open this note where you left off — a double-click on the row does the same")
            preview
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(tokens.room)
        .task(id: hit.id) { await load() }
    }

    private var factsLine: String {
        switch hit.kind {
        case .post: note?.factsLine ?? "note"
        case .book: book?.factsLine ?? "book"
        case .block: "block"
        }
    }

    /// VX-351: a note's line hovers its whole edit fact; a book's and a
    /// block's say no stamp, so they hover nothing.
    private var factsHelp: String? {
        hit.kind == .post ? note?.factsHelp() : nil
    }

    /// The subject swap FADES (row 24's panel half — the column's presence
    /// slides in the host; the content never teleports).
    @ViewBuilder private var preview: some View {
        Group {
            switch hit.kind {
            case .post:
                if let note {
                    LibraryNotePreview(tokens: tokens, blocks: note.blocks)
                }
            case .book:
                if let book {
                    LibraryBookOutline(
                        tokens: tokens, rows: book.rows,
                        onOpenAt: { postID in onOpenBookAt?(postID) ?? onOpen() },
                        onOpenBook: onOpen)
                }
            case .block:
                EmptyView()
            }
        }
        .id(hit.id)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.18), value: hit.id)
    }

    private func load() async {
        // The old subject stays until the new one is read (no flash of an
        // empty panel between two rows); a read that fails leaves a calm
        // nothing rather than a stale subject.
        switch hit.kind {
        case .post:
            let read = try? await session.database.read { [id = hit.id] db in
                try LibraryPreview.note(db, id: id)
            }
            book = nil
            note = read
        case .book:
            let read = try? await session.database.read { [id = hit.id] db in
                try LibraryPreview.book(db, id: id)
            }
            note = nil
            book = read
        case .block:
            note = nil
            book = nil
        }
    }
}

// MARK: - The note's text (read-cheap, lazy)

/// The note's rendered text: a lazy stack of per-block rows, each block
/// through the one markdown transform (`FlowParagraph`) in the voice's own
/// type. The SwiftUI `Text` tier — what the note's Read page and the book's
/// flow use — never the TK2 read tier (row 54's jump stays out of here).
private struct LibraryNotePreview: View {
    let tokens: VoiceTokens
    let blocks: [LibraryPreview.Block]

    var body: some View {
        if blocks.isEmpty {
            Text(tokens.chromeLabel("No text yet."))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .padding(.top, 4)
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(blocks) { block in
                        LibraryPreviewBlock(tokens: tokens, block: block)
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.automatic)
        }
    }
}

/// One block's paragraphs. Rendered on realization (`task(id:)`), reported
/// to the DEBUG oracle on appearance so a pin can see WHAT the panel shows.
private struct LibraryPreviewBlock: View {
    let tokens: VoiceTokens
    let block: LibraryPreview.Block

    @State private var paragraphs: [FlowParagraph] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { _, paragraph in
                Text(paragraph.text)
                    .font(font(paragraph))
                    .foregroundStyle(tokens.ink)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, paragraph.indent)
            }
            if paragraphs.isEmpty {
                // An empty block keeps its row (the note's shape), quietly.
                Text(" ").font(tokens.body)
            }
        }
        .textSelection(.enabled)
        .environment(\.openURL, OpenURLAction { url in
            MarkdownLink.open(url.absoluteString) ? .handled : .discarded
        })
        .task(id: block.text) {
            paragraphs = FlowParagraph.paragraphs(of: block.text, codeTint: tokens.codeTint)
        }
        .onAppear {
            #if DEBUG
            LibraryPanelOracle.shownBlockIDs.append(block.blockID)
            #endif
        }
    }

    /// The voice's own type: the body for prose and lists, the heading
    /// register for a level-1 heading, a semibold body for the rest.
    private func font(_ paragraph: FlowParagraph) -> Font {
        switch paragraph.style {
        case .heading(let level):
            level == 1 ? tokens.heading : tokens.body.weight(.semibold)
        case .body, .bullet, .checkbox:
            tokens.body
        }
    }
}

// MARK: - The book's outline

/// The navigator's grammar, in the panel: chapters small-semibold-accent,
/// notes muted and indented, headings quiet; every row a generous
/// full-width door with a calm hover wash.
private struct LibraryBookOutline: View {
    let tokens: VoiceTokens
    let rows: [LibraryPreview.OutlineRow]
    /// A row that names a note: open the book AT it.
    let onOpenAt: (String) -> Void
    /// A row that names none (an empty chapter): open the book plainly.
    let onOpenBook: () -> Void

    var body: some View {
        if rows.isEmpty {
            Text(tokens.chromeLabel("No notes in this book yet."))
                .font(tokens.small)
                .foregroundStyle(tokens.faint)
                .padding(.top, 4)
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(rows) { row in
                        LibraryOutlineRowView(
                            tokens: tokens, row: row,
                            onOpenAt: onOpenAt, onOpenBook: onOpenBook)
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.automatic)
        }
    }
}

private struct LibraryOutlineRowView: View {
    let tokens: VoiceTokens
    let row: LibraryPreview.OutlineRow
    let onOpenAt: (String) -> Void
    let onOpenBook: () -> Void

    @State private var hovering = false

    var body: some View {
        switch row {
        case .chapter(_, let name, let opensPostID, _):
            door(opensPostID: opensPostID) {
                Text(tokens.chromeLabel(name))
                    .font(tokens.small.weight(.semibold))
                    .foregroundStyle(tokens.accent)
                    .lineLimit(1)
            }
        case .heading(_, let name):
            Text(tokens.chromeLabel(name))
                .font(tokens.small.weight(.semibold))
                .foregroundStyle(tokens.muted)
                .lineLimit(1)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
        case .note(let postID, let title, let indented):
            door(opensPostID: postID) {
                Text(title)
                    .font(tokens.small)
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                    .padding(.leading, indented ? 12 : 0)
            }
        }
    }

    /// The whole row is the target — inside the label (batch B's row-48
    /// lesson: a plain button acts on its label's shape).
    private func door<Label: View>(
        opensPostID: String?, @ViewBuilder label: () -> Label
    ) -> some View {
        Button {
            if let opensPostID { onOpenAt(opensPostID) } else { onOpenBook() }
        } label: {
            label()
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .frame(maxWidth: .infinity, minHeight: 24, alignment: .leading)
                .background(
                    hovering ? AnyShapeStyle(tokens.wash) : AnyShapeStyle(.clear),
                    in: RoundedRectangle(cornerRadius: 6))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
        .onAppear {
            #if DEBUG
            LibraryPanelOracle.shownOutlineRowIDs.append(row.id)
            #endif
        }
        .help(opensPostID == nil
              ? "Open the book"
              : "Open the book at this note")
    }
}

// MARK: - The DEBUG oracle (what the pins read)

#if DEBUG
/// What the library's panel and its host actually laid out — frames in the
/// catalog view's own named space (`LibraryCatalogView.probeSpace`; a
/// `.global` read inside a macOS `ScrollView` answers in the scroll view's
/// space — batch C's lesson), and what the preview rendered.
@MainActor
enum LibraryPanelOracle {
    // **18k UNIT C4 — the frames NAME THEIR OWNER** (the rule and its
    // reasons: `Core/Views/DebugOracleOwnership.swift`): the mounted
    // catalog's `oracleOwner`, which its probes read by environment and which
    // the catalog releases when it leaves. The six were bare statics every
    // mounted catalog overwrote — after one window closed they were ITS
    // rectangles (measured red, `DebugOracleTwoWindowTests`). Read names and
    // shapes unchanged.
    private static var frameStore = OwnedRegistrations<LibraryProbeSlot, CGRect>()

    /// The catalog view's own frame (the host's size).
    static var rootFrame: CGRect? { frameStore[.root] }
    /// OUR divider between the list and the panel — the boundary that must
    /// hold when the window is inactive (row 34).
    static var dividerFrame: CGRect? { frameStore[.divider] }
    static var panelFrame: CGRect? { frameStore[.panel] }
    /// The message row (a receipt or an error) — laid out, never overlaid
    /// (F's (a)).
    static var messageFrame: CGRect? { frameStore[.message] }
    static var quickEntryFrame: CGRect? { frameStore[.quickEntry] }
    /// VX-175: the controls row (search · scope · mode · sort · when) and its
    /// search field — the row must fit the list column, the field never a
    /// sliver (`LibraryControlsGeometryTests`).
    static var controlsFrame: CGRect? { frameStore[.controls] }
    static var searchFieldFrame: CGRect? { frameStore[.searchField] }
    /// P-U3-5: the sort slot — never wider than the stable widest the row
    /// counts it at, and always one line.
    static var sortSlotFrame: CGRect? { frameStore[.sortSlot] }
    /// VX-350: the 🔍 door — inside the row only in its collapsed class.
    static var searchToggleFrame: CGRect? { frameStore[.searchToggle] }
    /// A book row's LINE — its width must span the row (row 33 (a)).
    static var bookLineFrame: CGRect? { frameStore[.bookLine] }
    /// 17y B1 (k): the capped books region (only when the books are split
    /// off) and the list that carries the notes.
    static var booksRegionFrame: CGRect? { frameStore[.booksRegion] }
    static var notesRegionFrame: CGRect? { frameStore[.notesRegion] }
    /// Each NOTE row's frame by post id — so a pin can click a row for
    /// real (ladder R1-2: the row-click brain's timing pin).
    static var noteRowFrames: [String: CGRect] {
        var rows: [String: CGRect] = [:]
        for (slot, frame) in frameStore.current {
            if case .noteRow(let id) = slot { rows[id] = frame }
        }
        return rows
    }
    /// The blocks the note preview realized, in appearance order — an
    /// append-only LOG, not a registration (18k C4 — SAFE-AS-IS (A)),
    /// bounded like every DEBUG log (`DebugOracleLog`).
    static var shownBlockIDs: [String] = [] {
        didSet { DebugOracleLog.bound(&shownBlockIDs) }
    }
    /// The outline rows the book preview realized (the same kind of log).
    static var shownOutlineRowIDs: [String] = [] {
        didSet { DebugOracleLog.bound(&shownOutlineRowIDs) }
    }

    static func record(_ slot: LibraryProbeSlot, _ frame: CGRect, owner: UUID) {
        frameStore.publish(frame, for: slot, owner: owner)
    }

    /// A catalog leaving: its own frames, and no other window's.
    static func release(owner: UUID) { frameStore.release(owner: owner) }

    /// A PIN's door, unconditional (a pin owns nothing).
    static func reset() {
        frameStore.forgetAll()
        shownBlockIDs = []
        shownOutlineRowIDs = []
    }
}
#endif

/// What a library geometry probe reports — the slot a frame belongs to.
/// Always compiled (the modifier's signature names it); the oracle that
/// stores the frames is DEBUG-only.
enum LibraryProbeSlot: Hashable {
    case root, divider, panel, message, quickEntry, bookLine
    /// VX-175: the controls row and its search field; P-U3-5: the sort slot
    /// (the `sort ▾` door, or the relevance label while she searches).
    case controls, searchField, sortSlot
    /// VX-350: the 🔍 door the field collapses to at a narrow width.
    case searchToggle
    case noteRow(String)
    /// 17y B1 (k): the capped books List and the list beside it.
    case booksRegion, notesRegion
}

extension View {
    /// Report this view's frame in the catalog's named space to the DEBUG
    /// oracle; a no-op outside DEBUG.
    @ViewBuilder
    func libraryGeometryProbe(_ slot: LibraryProbeSlot) -> some View {
        #if DEBUG
        self.modifier(LibraryGeometryProbe(slot: slot))
        #else
        self
        #endif
    }
}

#if DEBUG
/// 18k C4: a modifier rather than a bare `onGeometryChange`, because it must
/// READ its owning catalog from the environment (`TakeCardGeometryProbe`'s
/// own reason) — the rectangle is that catalog's, and goes when it does.
private struct LibraryGeometryProbe: ViewModifier {
    let slot: LibraryProbeSlot
    @Environment(\.debugOracleOwner) private var owner

    func body(content: Content) -> some View {
        content.onGeometryChange(for: CGRect.self) {
            $0.frame(in: .named(LibraryCatalogView.probeSpace))
        } action: { frame in
            LibraryPanelOracle.record(slot, frame, owner: owner ?? DebugOracleOwner.unowned)
        }
    }
}
#endif
