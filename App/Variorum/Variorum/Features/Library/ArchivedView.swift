//
//  ArchivedView.swift
//  Variorum
//
//  **ARCHIVE GETS ITS OWN ROOM** (the post-13l polish round, ledger row 8 —
//  her B2 direction, verbatim):
//
//    *"archived should be a different item on the left (like where library
//    is, but it says archived)… separating archive and trash more makes
//    sense - archive is available forever and maybe still valuable even if
//    you don't want it in your current library, and it would be nice to be
//    able to search it separately."*
//
//  Until now Archived was a section stacked above the Trash inside ONE
//  surface called "Archived & Deleted", which put a forever-list and a
//  30-day countdown on the same screen and asked her to hold the difference
//  herself. They are different ideas — the model's own archive/tombstone
//  distinction (OverallModel §6) — and the sidebar now says so.
//
//  ── ARCHIVED **NOTES** ONLY (her Q-answer) ───────────────────────────────
//  Archived BLOCKS stay in their note's tray; archived TAKES stay in the
//  takes strip. Each archived thing lives where its context is — a block
//  alone in a global list is the same "hard without context" problem her D1
//  ruling named for takes. This surface is whole notes she set aside.
//
//  ── AND VERSION HISTORY IS NOT AN ARCHIVED NOTE ──────────────────────────
//  Saved versions of a note are born archived (batch 5 mints them), and
//  their one home is that note's Versions listing — otherwise a note with
//  fifteen saved moments would drown the notes she actually set aside. The
//  classifier is a QUERY, not a column (`Queries.archivedPosts`'s
//  `excludingVersionHistory`), and it is built here BEFORE the versions
//  exist so the surface is right on the day they arrive.
//
//  ── AND, SINCE 13i-e, ARCHIVED BOOKS (her R-13ie-1) ────────────────────
//  *"it should be under archived — … a book is a set of rules + ordering now
//  so it makes sense to archive it."* A BOOKS group sits ABOVE the notes:
//  each archived book or gathering of this wing, its honest facts, and its
//  doors — Open (the book view), Unarchive, Delete Book… (never on the daily
//  Journal — `BookArchiveDoorSet`). With no archived book the surface reads
//  exactly as it always did (no section labels). Kept forever, no countdown.
//
//  ── SEARCH ───────────────────────────────────────────────────────────────
//  Her "search it separately" half is a NAME filter over this listing —
//  which is what the Library's catalog search does for live notes today
//  (titles, names, scrap prefixes). BODY-TEXT search is 13o's, on both
//  surfaces at once, and this surface's scope note is written into that
//  phase's inheritance rather than half-built here.
//

import Foundation
import GRDB // AsyncValueObservation iteration
import SwiftUI
import VariorumCore

struct ArchivedView: View {
    let session: AppSession
    let library: LibraryViewModel
    var openPost: (String) -> Void
    /// 13i-e U2: a book row's Open — composition decides what opening a book
    /// means (the shell's `.reading` route). Defaults to nothing (a pin's mount).
    var openBook: (String) -> Void = { _ in }
    /// 17y B3 item (l): the star door for the BOOKS group's row menu (nil in
    /// a harness mount — the menu then draws no star).
    var starDoor: StarDoor? = nil
    @State private var model: RecoveryViewModel
    /// 13i-e U2 — the BOOKS group's brain and the shared state doors (the
    /// Unarchive/Delete acts, their confirms and receipts).
    @State private var books: ArchivedBooksModel
    @State private var doors: BookStateDoors
    /// 17y B3 item (l): the book rows' context menu (`BookRowMenu`) — over
    /// THIS surface's state doors, whose confirms it already hosts.
    @State private var rowDoors: BookRowDoors
    @State private var query = ""
    /// The Trash road out (N3: Archive → Unarchive → Library, or Delete →
    /// the Trash). One confirm host, the shared wording.
    @State private var pendingDelete: NoteDeleteConfirm?

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    init(
        session: AppSession, library: LibraryViewModel,
        openPost: @escaping (String) -> Void,
        openBook: @escaping (String) -> Void = { _ in },
        starDoor: StarDoor? = nil,
        books: ArchivedBooksModel? = nil
    ) {
        self.session = session
        self.library = library
        self.openPost = openPost
        self.openBook = openBook
        self.starDoor = starDoor
        _model = State(initialValue: RecoveryViewModel(session: session))
        _books = State(initialValue: books ?? ArchivedBooksModel(session: session))
        let doors = BookStateDoors(session: session)
        _doors = State(initialValue: doors)
        _rowDoors = State(initialValue: BookRowDoors(session: session, stateDoors: doors))
    }

    /// The listing this surface shows, narrowed by the name filter. A pure
    /// read over what is already observed — the filter is hers to type and
    /// the observation never restarts for it (unlike the Trash's kind filter,
    /// which is applied IN SQL because it changes which rows the WINDOW
    /// should hold).
    static func matches(_ items: [Queries.TimelineItem], query: String) -> [Queries.TimelineItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return items }
        return items.filter {
            $0.displayTitle.localizedCaseInsensitiveContains(trimmed)
                || ($0.entryDate ?? "").localizedCaseInsensitiveContains(trimmed)
        }
    }

    private var shown: [Queries.TimelineItem] {
        Self.matches(model.archived, query: query)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().overlay(tokens.line)
            list
        }
        .background(tokens.surface)
        .task(id: session.wing.currentID) { await model.startArchived() }
        .task(id: session.wing.currentID) { await books.start() }
        // The state doors' ONE confirm road (Delete Book's three confirms).
        .bookStateConfirms(doors)
        // 17y B3 item (l): the row menus' settings sheet (their state doors
        // are `doors`, confirmed just above — never hosted twice).
        .bookRowDoors(rowDoors, hostsStateConfirms: false)
        .onChange(of: books.books, initial: true) { _, now in rowDoors.adopt(now) }
        .deleteNoteConfirmDialog($pendingDelete) { confirm in
            NoteDeletion.fire(session: session, postIDs: confirm.postIDs)
        }
        .overlay(alignment: .bottom) {
            if let error = model.lastError ?? library.lastError {
                Text(error)
                    .font(tokens.small)
                    .alarmVoice()
                    .textSelection(.enabled)
                    .padding(4)
            } else if let receipt = library.receipt {
                Text(receipt)
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .textSelection(.enabled)
                    .padding(4)
            } else {
                // 13i-e U2 (the walk's W-1): the BOOKS group's acts speak on
                // the one status seam (18i), and a quiet receipt needs a host
                // on the surface that spoke it (KnownIssues row 103's class) —
                // without this line an Unarchive here said nothing at all.
                QuietReceiptLine(status: session.status, tokens: tokens)
                    .padding(4)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(tokens.path([RecoveryPath.archivedSurface]))
                    .font(tokens.heading)
                    .foregroundStyle(tokens.accent)
                Text(tokens.chromeLabel(Self.subtitle))
                    .font(tokens.small)
                    .foregroundStyle(tokens.muted)
                    .lineLimit(1)
                Spacer()
            }
            TextField(tokens.chromeLabel(Self.searchPrompt), text: $query)
                .textFieldStyle(.roundedBorder)
                .font(tokens.small)
                .frame(maxWidth: 320)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    /// The room's own promise, said where she can read it — the `windowNote`
    /// shape one surface over, and its exact opposite in content: no clock.
    /// 13i-e U2: books live here too now (R-13ie-1) — and kept means forever.
    static let subtitle = "notes and books you set aside — kept, with no countdown"
    static let searchPrompt = "Search archived notes and books…"
    /// 13i-e U2 — the two groups' labels (drawn only when a book is archived).
    static let booksSection = "Books"
    static let notesSection = "Notes"

    /// The `.surface` acts this view renders (P-1's declared ⇔ rendered walk):
    /// each row's inline Unarchive is `.unarchiveNote` — its second renderer
    /// beside a book's archived line (13i-d U6 (h) — F-U4-4, routed here) —
    /// and its inline Delete Note… is `.deleteNote` (13i-d U7 rider, F-U6-4).
    static let surfaceCapabilities: [CapabilityID] = [.unarchiveNote, .deleteNote]
        // 13i-e U2 — the BOOKS group's rows (R-13ie-1): Unarchive, and the
        // shared Delete Book… road (never on the daily Journal — the table).
        + [.unarchiveBook, .deleteBook]
    static let emptyLine = "Nothing archived."
    static let noMatchesLine = "No archived note matches that."

    /// Act 10 wave 2a (item 4): the hairline-row grammar retires for the
    /// W8-2 calm cards — a `List` still carries the rows (the window is
    /// 500; virtualization stays), the separators go, and each note is one
    /// card with generous doors. Every door survives byte-identical.
    private var list: some View {
        List {
            // 13i-e U2 — THE BOOKS GROUP, above the notes (R-13ie-1).
            let shownBooks = ArchivedBooksModel.matches(books.books, query: query)
            if !books.books.isEmpty {
                sectionLabel(Self.booksSection)
                if shownBooks.isEmpty {
                    Text(ArchivedBookCopy.noMatchesLine).foregroundStyle(.secondary)
                        .listRowSeparator(.hidden)
                }
                ForEach(shownBooks, id: \.id) { reading in
                    bookRow(reading)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(
                            top: 3, leading: 12, bottom: 3, trailing: 12))
                }
                if books.truncated {
                    Text(ArchivedBookCopy.windowed(ArchivedBooksModel.window))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .listRowSeparator(.hidden)
                }
                sectionLabel(Self.notesSection)
            }
            if model.archived.isEmpty {
                Text(books.books.isEmpty ? Self.emptyLine : ArchivedBookCopy.noNotesLine)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
            } else if shown.isEmpty {
                Text(Self.noMatchesLine).foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
            }
            ForEach(shown, id: \.postID) { item in
                row(item)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(
                        top: 3, leading: 12, bottom: 3, trailing: 12))
            }
            if model.archivedTruncated {
                Text("Showing the \(RecoveryViewModel.window) most recently archived — older ones aren't listed.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    /// A group's quiet label (the Library's gray section-label grammar).
    private func sectionLabel(_ words: String) -> some View {
        Text(tokens.chromeLabel(words))
            .font(tokens.small)
            .foregroundStyle(tokens.faint)
            .lineLimit(1)
            .listRowSeparator(.hidden)
            .padding(.top, 6)
    }

    /// One archived book or gathering: its name, its honest facts, when it was
    /// archived — and its doors, from the archive table (P-1): Open (the book
    /// view; navigation, never an act), Unarchive, Delete Book… (not drawn on
    /// the daily Journal — P-2).
    private func bookRow(_ reading: Reading) -> some View {
        CalmCard(tokens: tokens) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(reading.name)
                        .font(tokens.body)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        Text(tokens.chromeLabel(ArchivedBookCopy.facts(
                            reading, notes: books.noteCounts[reading.id])))
                            .font(tokens.small).foregroundStyle(tokens.muted)
                        if let stamp = ArchivedBookCopy.stamp(reading) {
                            Text(stamp).font(tokens.small).foregroundStyle(tokens.faint)
                        }
                    }
                    .lineLimit(1)
                }
                Spacer(minLength: 8)
                Button(ArchivedBookCopy.openVerb) { openBook(reading.id) }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
                ForEach(BookArchiveDoorSet.rendered(for: BookArchiveFacts(reading))
                    .filter { $0 != .archiveBook }, id: \.self) { act in
                    if act == .deleteBook {
                        Button(CapabilityRegistry.capability(.deleteBook).verb + "\u{2026}") {
                            Task { await doors.open(.deleteBook, readingID: reading.id) }
                        }
                        .buttonStyle(CalmButtonStyle(tokens: tokens, role: .danger, compact: true))
                    } else {
                        Button(CapabilityRegistry.capability(act).verb) {
                            Task { await doors.open(act, readingID: reading.id) }
                        }
                        .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary, compact: true))
                        .help(ArchivedBookCopy.unarchiveHelp)
                    }
                }
            }
        }
        // 17y B3 item (l): the book row menu (the Bookcase's, trimmed of
        // position) — this row's buttons' twins, plus star and settings.
        .contextMenu {
            BookRowMenu(
                readingID: reading.id, doors: rowDoors, starDoor: starDoor,
                open: { openBook(reading.id) })
        }
    }

    private func row(_ item: Queries.TimelineItem) -> some View {
        CalmCard(tokens: tokens) {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(item.displayTitle)
                        .font(tokens.body)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        if let date = item.entryDate {
                            Text(date).font(tokens.small).foregroundStyle(tokens.muted)
                        }
                        if let stamp = TrayRowPreview.stampText(item.stamp, verb: "archived") {
                            Text(stamp).font(tokens.small).foregroundStyle(tokens.faint)
                        }
                    }
                    .lineLimit(1)
                }
                Spacer(minLength: 8)
                Button("Open") { openPost(item.postID) }
                    .buttonStyle(CalmButtonStyle(tokens: tokens, compact: true))
                Button(CapabilityRegistry.capability(.unarchiveNote).verb) {
                    Task { await library.unarchive(postID: item.postID) }
                }
                .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary, compact: true))
                .help("Puts it back in the Library")
                // N3's last road: Delete → the Trash, 30 days, one shared
                // wording with every other note-delete door.
                // 13i-d U7 rider (F-U6-4): spelled from the registry — the act
                // this button renders is declared (`.deleteNote`, `.surface`).
                Button(CapabilityRegistry.capability(.deleteNote).verb) {
                    Task { pendingDelete = await NoteDeletion.ask(
                        session: session, postIDs: [item.postID]) }
                }
                .buttonStyle(CalmButtonStyle(tokens: tokens, role: .danger, compact: true))
            }
        }
    }
}

// MARK: - 13i-e U2 — the BOOKS group's brain and words

/// **THE ARCHIVED BOOKS, held** (R-13ie-1): the current wing's archived
/// books and gatherings (`observeArchivedReadings` — the `reading` table
/// alone, so autosave never wakes it), newest archive first, windowed; and
/// each BOOK's member count as a one-shot read beside it (it reads
/// `container` — the 13i-d archived-counts rule keeps that out of the held
/// region). Holds projections and ids; every write is an operation's (the
/// state doors).
@MainActor
@Observable
final class ArchivedBooksModel {
    @ObservationIgnored private let session: AppSession
    nonisolated static let window = 200

    private(set) var books: [Reading] = []
    private(set) var truncated = false
    /// Live member notes per archived BOOK (a gathering holds none).
    private(set) var noteCounts: [String: Int] = [:]
    private(set) var lastError: String?

    init(session: AppSession) {
        self.session = session
    }

    func start() async {
        do {
            for try await value in session.database.observeArchivedReadings(
                limit: Self.window + 1, wingID: session.wing.currentID
            ) {
                await adopt(value)
            }
        } catch is CancellationError {
        } catch {
            lastError = DeletionRefusal.fallback(error)
        }
    }

    /// Tests drive the listing the `adopt` way (hosted `.task`s don't fire
    /// under the test host).
    func adopt(_ value: [Reading]) async {
        (books, truncated) = TrashListing.windowed(value, window: Self.window)
        let ids = books.filter { $0.kind == .book }.map(\.id)
        noteCounts = (try? await session.database.read { db in
            var counts: [String: Int] = [:]
            for id in ids { counts[id] = try Queries.liveMemberNoteCount(db, readingID: id) }
            return counts
        }) ?? [:]
    }

    /// The name filter (the notes' own rule — a pure read over what is held).
    nonisolated static func matches(_ books: [Reading], query: String) -> [Reading] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return books }
        return books.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
    }
}

/// Every word the BOOKS group says. Wording PROVISIONAL (13s re-voices); the
/// facts are honest counts (her #169(a)(1) precedent).
nonisolated enum ArchivedBookCopy {
    static let openVerb = "Open"
    static let noMatchesLine = "No archived book matches that."
    static let noNotesLine = "No archived notes."
    static let unarchiveHelp = "Puts it back on the Bookcase"

    static func windowed(_ window: Int) -> String {
        "Showing the \(window) most recently archived books \u{2014} older ones aren't listed."
    }

    /// "book · 5 notes · owned · finished", "daily Journal · 12 notes", or
    /// "gathering · shows nothing while archived" (R-13ie-3 — its assembly
    /// is empty until unarchived, so it has no count to state).
    static func facts(_ reading: Reading, notes: Int?) -> String {
        guard reading.kind == .book else { return "gathering \u{00B7} shows nothing while archived" }
        var parts = [Queries.isDailyJournalMintShape(reading) ? "daily Journal" : "book"]
        if let notes { parts.append(notes == 1 ? "1 note" : "\(notes) notes") }
        if reading.owned { parts.append("owned") }
        if reading.sealedAt != nil {
            parts.append("sealed")
        } else if reading.locked {
            parts.append("finished")
        }
        return parts.joined(separator: " \u{00B7} ")
    }

    static func stamp(_ reading: Reading) -> String? {
        guard let archivedAt = reading.archivedAt else { return nil }
        return TrayRowPreview.stampText(
            DateFormatter.variorumISO8601.string(from: archivedAt), verb: "archived")
    }
}
