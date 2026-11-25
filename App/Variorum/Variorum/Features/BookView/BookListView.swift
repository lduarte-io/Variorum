//
//  BookListView.swift
//  Variorum (Mac)
//
//  **VX-1084 — the book's List mode** (the VX-1036 run, batch 3). Her words
//  (sitting 2): *"the library already has a nice setup for looking what notes
//  are present and being able to add tags. maybe we just need to bring this
//  library esque view into book somehow?"* — then R-1036-29 ("List as a fifth
//  mode") and R-1036-38 ("List is rows only; outline is the cards"). The face
//  is the round-2 mockup's frame 9 (9a the weekly gathering, 9c a chaptered
//  book).
//
//  What lives here (P-9 — the List's own concerns, never more of the book's
//  view model):
//  - `BookListRows` (its own file) — the List's groups, PURE: the Outline's own row assembly
//    (`BookOutlineRows` — chapters in order, empty ones kept, "unfiled" last;
//    a gathering's tag-path headings) regrouped under headings with counts.
//    The ENTRIES are the book's (`BookViewModel.entries`): its order — the
//    dial's look or the book's own, pinned notes floating within their chapter
//    — its members only, its 300-note window. Nothing is re-decided here.
//  - `BookListModel` — the rows' edited stamps: ONE held read over the
//    window's notes (`Queries.noteEditedStamps`), and only while List shows.
//  - `BookListView` — the face: the Library's own List face and note row
//    (`LibraryListFace`, `CatalogNoteLine` — one shared row, never a copy, in
//    `Core/Views`), on the Library's lazy-column engine (rows realized ∝ the
//    viewport — P1/P3), the headings with their counts and the chapter's own
//    "+ new note" (the declared `.newNoteInChapter`, handed in by the book).
//
//  NOT taken from the Library (BL-2): its search field (the book's 🔍
//  stays), its scope and view pickers, its own sort (the book's dial governs).
//

import GRDB
import SwiftUI
import VariorumCore

// (The rows' pure assembly, `BookListRows`, is its own file — `BookListRows.swift`.)

// MARK: - The rows' stamps (the List's one held read)

@MainActor
@Observable
final class BookListModel {
    /// Each listed note's EDITED stamp (stored ISO), by note id — the
    /// Library row's own stamp (`COALESCE(last_touched_at, created_at)`).
    private(set) var edited: [String: String] = [:]

    /// The read, HELD while the List shows (its `.task(id:)` runs it and
    /// cancels it when the window's notes change or the List leaves). ∝ the
    /// window's notes; it wakes on a write to those notes' rows (a keystroke
    /// in another pane moves a stamp — that is the point of the stamp).
    func track(session: AppSession, postIDs: [String]) async {
        guard !postIDs.isEmpty else {
            adopt([:])
            return
        }
        do {
            for try await stamps in session.database.observe({ db in
                try Queries.noteEditedStamps(db, noteIDs: postIDs)
            }) {
                adopt(stamps)
            }
        } catch {
            // Cancellation (the window moved, the List left) or a refusal: the
            // stamps in hand stay until the next read.
        }
    }

    /// Internal so a pin drives it by hand. A superseded read's late delivery
    /// never lands.
    func adopt(_ stamps: [String: String]) {
        guard !Task.isCancelled else { return }
        if stamps != edited { edited = stamps }
    }
}

// MARK: - The face

/// The words the List's own chrome says (public copy).
nonisolated enum BookListCopy {
    static let rowHelp = "Click to select this note; double-click or \u{23CE} opens it in the full editor"
}

struct BookListView<ChapterDoor: View>: View {
    let session: AppSession
    let model: BookViewModel
    let structure: BookStructureModel
    let tags: BookCardTagsModel
    let list: BookListModel
    let tokens: VoiceTokens
    /// The note-title menu's asks and roads (VX-802 — the book views' one menu).
    let noteDoors: BookNoteTitleDoors
    let noteRoads: BookNoteRoads
    /// The row's badge — the book's own badge family (`BookView.ownershipBadge`).
    let badge: (String) -> OwnershipBadgeFace.Badge?
    /// The book's ONE open door (`BookView.openInWrite` — Write at her block).
    let onOpen: (String) -> Void
    /// A chapter's own "+ new note" — the declared `.newNoteInChapter`'s
    /// renderer, built by the book (its fences and words are the book's).
    @ViewBuilder let chapterDoor: (ReadingSection) -> ChapterDoor

    /// ⏎ opens the selected note while the List holds the keyboard.
    @FocusState private var holdsKeys: Bool

    private var groups: [BookListRows.Group] {
        BookListRows.groups(rows: BookView.outlineRows(structure: structure, entries: model.entries))
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    controls
                    if model.entries.isEmpty {
                        LibraryListRow {
                            // VX-45: the one empty-state home.
                            Text(BookEmptyStateCopy.line(for: structure.reading))
                                .font(tokens.small)
                                .foregroundStyle(tokens.muted)
                        }
                    }
                    ForEach(groups) { group in
                        Section {
                            ForEach(group.entries, id: \.postID) { entry in
                                row(entry)
                            }
                            // The Library's 20 pt between a group's last row
                            // and the next heading.
                            Color.clear.frame(height: LibraryListFace.sectionGap)
                        } header: {
                            if let heading = group.heading {
                                header(heading)
                                    .id(group.id)
                            }
                        }
                    }
                    // The window's road ("show 300 more ›"), as the book's
                    // other modes draw it.
                    BookWindowLine(tokens: tokens, model: model)
                        .padding(.horizontal, LibraryListFace.rowInsets.leading)
                }
                .padding(.bottom, LibraryListFace.bottomInset)
            }
            .libraryListScrollReader()
            .background(tokens.surface)
            .focusable()
            .focusEffectDisabled()
            .focused($holdsKeys)
            .onKeyPress(.return) {
                guard let selected = model.listSelectedPostID,
                      model.entries.contains(where: { $0.postID == selected })
                else { return .ignored }
                onOpen(selected)
                return .handled
            }
            .onAppear {
                // The keyboard is the List's (for ⏎) only in the focused pane
                // — a split's other book never takes it.
                if model.paneFocused { holdsKeys = true }
                takeReveal(proxy)
                takeChapterReveal(proxy)
            }
            .onChange(of: model.pendingReveal) { _, _ in takeReveal(proxy) }
            // A reveal that arrived before the book's first rows waits for them.
            .onChange(of: model.entries.isEmpty) { _, _ in takeReveal(proxy) }
            .onChange(of: model.pendingChapterReveal) { _, _ in takeChapterReveal(proxy) }
        }
        // The rows' edited stamps — held only while the List shows.
        .task(id: model.entries.map(\.postID)) {
            await list.track(session: session, postIDs: model.entries.map(\.postID))
        }
        // VX-576: the rows' ＋ popovers order their suggestions most-used
        // first — the counts read once whenever the List starts showing tags.
        .task(id: tags.position != .hidden) {
            guard tags.position != .hidden else { return }
            tags.readUses(session: session, wingID: structure.reading?.wingId ?? "")
        }
    }

    /// The List's one line of its own chrome: the book's tags switch (the
    /// same three positions as the Outline's — R-1036-39), at the trailing end.
    private var controls: some View {
        HStack(spacing: 8) {
            Spacer(minLength: 0)
            BookTagsSwitch(
                tokens: tokens, position: tags.position,
                choose: { tags.setPosition($0) })
        }
        .padding(.horizontal, LibraryListFace.rowInsets.leading)
        .padding(.top, LibraryListFace.topInset)
        .padding(.bottom, 4)
    }

    private func header(_ heading: BookListRows.Heading) -> some View {
        let title: String
        var door: AnyView?
        switch heading.kind {
        case .chapter(let section):
            title = tokens.chromeLabel(section.name)
            door = AnyView(chapterDoor(section))
        case .unfiled:
            title = tokens.chromeLabel(BookPanelCopy.unfiled)
        case .tagPath(let path):
            title = tokens.chromeLabel(path)
        }
        return LibraryListHeader(title: title, count: heading.count, trailing: door)
    }

    private func row(_ entry: Queries.ReadingEntry) -> some View {
        BookListNoteRow(
            session: session, entry: entry, tokens: tokens, tags: tags, list: list,
            selected: model.listSelectedPostID == entry.postID,
            badge: badge(entry.postID), structure: structure,
            noteDoors: noteDoors, noteRoads: noteRoads,
            onSelect: {
                holdsKeys = true
                model.noteListSelection(entry.postID)
            },
            onOpen: {
                model.noteListSelection(entry.postID)
                onOpen(entry.postID)
            })
            .id(BookListRows.noteAnchor(entry.postID))
    }

    /// **A note the book was asked to land on** (a click-over carried here, a
    /// navigator note row, a reveal from outside): once the List's entries
    /// hold it, it is SELECTED and brought into view, and the request is
    /// spent. A note the List does not hold (outside its window) drops the
    /// request once the entries have arrived; before they do, it waits.
    private func takeReveal(_ proxy: ScrollViewProxy) {
        guard let postID = model.pendingReveal, !model.entries.isEmpty else { return }
        model.consumeReveal()
        guard model.entries.contains(where: { $0.postID == postID }) else { return }
        model.noteListSelection(postID)
        withAnimation(.easeInOut(duration: 0.2)) {
            proxy.scrollTo(BookListRows.noteAnchor(postID), anchor: .center)
        }
    }

    /// A navigator chapter row: the chapter's heading at the top.
    private func takeChapterReveal(_ proxy: ScrollViewProxy) {
        guard let sectionID = model.pendingChapterReveal else { return }
        model.consumeChapterReveal()
        withAnimation(.easeInOut(duration: 0.2)) {
            proxy.scrollTo(BookOutlineRows.Row.chapterAnchor(sectionID), anchor: .top)
        }
    }
}

/// **One note's row** — the Library's own List row (`CatalogNoteLine` in its
/// click shell, on the List face's insets and separator), fed the book's facts:
/// the title the book gives the note, the day she stated, the tags behind the
/// book's switch (`BookCardTagsModel.pills(for:)` — THE read seam; hidden
/// draws no cards and no ＋), the edited stamp at the trailing edge, the book's
/// badge, and the pick's wash on the selected note.
private struct BookListNoteRow: View {
    let session: AppSession
    let entry: Queries.ReadingEntry
    let tokens: VoiceTokens
    let tags: BookCardTagsModel
    let list: BookListModel
    let selected: Bool
    let badge: OwnershipBadgeFace.Badge?
    let structure: BookStructureModel
    let noteDoors: BookNoteTitleDoors
    let noteRoads: BookNoteRoads
    let onSelect: () -> Void
    let onOpen: () -> Void

    var body: some View {
        #if DEBUG
        let _ = BookListProbe.rowBodies += 1
        #endif
        let pills = tags.pills(for: entry.postID)
        LibraryListRow {
            CatalogNoteRowShell(
                postID: entry.postID,
                onClick: { _ in onSelect() },
                onDoubleClick: onOpen,
                recordsLibraryProbe: false
            ) {
                CatalogNoteLine(
                    tokens: tokens, title: entry.displayTitle,
                    date: entry.entryDate,
                    tags: pills ?? [], allTags: tags.vocabulary,
                    onTitleTap: onOpen,
                    onApply: { tags.apply($0, to: entry.postID, session: session) },
                    onRemove: { tags.remove($0, from: entry.postID, session: session) },
                    stamp: LibrarySortFace.RowStamp(subject: .edited, stamp: list.edited[entry.postID]),
                    badge: badge, badgePostID: entry.postID,
                    showsTags: pills != nil,
                    tagUses: tags.uses)
            }
        } background: {
            LibraryListRowPick(tokens: tokens, picked: false, subject: selected)
        }
        .help(BookListCopy.rowHelp)
        // VX-802: the book views' one note-title menu.
        .contextMenu {
            BookNoteTitleMenu(
                structure: structure, postID: entry.postID, title: entry.displayTitle,
                pinned: entry.pinned, doors: noteDoors, roads: noteRoads)
        }
        #if DEBUG
        .onAppear { BookListProbe.appeared.insert(entry.postID) }
        .onDisappear { BookListProbe.appeared.remove(entry.postID) }
        #endif
    }
}

#if DEBUG
/// **The List's realization oracle** (the Library's `LibraryPagedNotesProbe`
/// pattern): how many note-row bodies were evaluated, and which rows stand
/// realized now — a pin holds both to the viewport, never the book (P1/P3).
@MainActor
enum BookListProbe {
    static var rowBodies = 0
    static var appeared: Set<String> = []

    static func reset() {
        rowBodies = 0
        appeared = []
    }
}
#endif
