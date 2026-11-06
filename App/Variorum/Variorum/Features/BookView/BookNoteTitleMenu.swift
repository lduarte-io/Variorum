//
//  BookNoteTitleMenu.swift
//  Variorum
//
//  VX-802 (the VX-878 run, batch 1 — her 2026-11-04 ask, with a screenshot of
//  Outline's note-title right-click showing only "Move to Chapter ▸" and
//  "Remove from This Book": "when you right click on a note title, you should
//  be able to rename or delete it, at least"). The ruling is A-878-1 (the
//  VX-878 record): the proposal adopted as written, PROVISIONAL D-802-1.
//
//  THE BOOK VIEWS' NOTE-TITLE MENU — one builder, its four right-click sites
//  (Outline's expanded note header and its collapsed card; the navigator's
//  note rows in every book mode; the navigator's collapsed one-note chapter
//  row, after its chapter doors) — draws, in this order:
//
//  · the NOTE'S OWN doors, on a book's notes AND a gathering's (they are the
//    note's acts, never membership's): Open Beside · Open in New Window ·
//    Star / Unstar | Rename… · Move to Wing ▸ / Copy to Wing ▸ (while another
//    wing exists, from the note's own wing) · Export Note…;
//  · the BOOK'S STRUCTURE pair, books only, exactly as shipped: Move to
//    Chapter ▸ | Remove from This Book (Release on an owned book). A
//    gathering's membership row is untouched — no "remove #tag" here (A-878-1);
//  · set apart, LAST: Archive · Delete Note… (the one shared confirm).
//
//  Every word is its registry declaration's (the note rows' grammar —
//  `SidebarView.contextMenuCapabilities` + `noteRowMenuCapabilities`); every
//  act is the shared road the note rows already run (the one rename ask and
//  body, the one delete confirm and `NoteDeletion.fire`, `WingNoteDoors` and
//  its confirm, `NoteExport.export`, the archive op with its one receipt).
//  WHICH doors draw is DATA (`BookNoteTitleMenuTable`), pinned. Left off by
//  the ruling: Close / Close All (the Open list's own), an "Open" duplicating
//  the title's click, Duplicate, Share with AI…, Tags…, versions, Export ▸.
//

import SwiftUI
import VariorumCore

// MARK: - The roads in from composition

/// What the note-title menu reaches beyond the book — the composition root's
/// roads (the Library rows' own: the union star, Open Beside, Open in New
/// Window). nil members draw no door (a harness mount; P-2).
struct BookNoteRoads {
    var starDoor: StarDoor?
    var openBeside: ((String) -> Void)?
    var openInNewWindow: ((String) -> Void)?

    init(
        starDoor: StarDoor? = nil, openBeside: ((String) -> Void)? = nil,
        openInNewWindow: ((String) -> Void)? = nil
    ) {
        self.starDoor = starDoor
        self.openBeside = openBeside
        self.openInNewWindow = openInNewWindow
    }
}

// MARK: - The table (pure)

/// One door of the note-title menu.
nonisolated enum BookNoteTitleDoor: Hashable, Sendable {
    case openBeside, openInNewWindow, star
    case rename
    /// Move to Wing ▸ and Copy to Wing ▸ — one pair, drawn by the shared
    /// `WingNoteDoors` only while another wing exists.
    case wingDoors
    case export
    case moveToChapter, removeFromBook
    case archive, delete

    /// The registry acts the door draws.
    var capabilities: [CapabilityID] {
        switch self {
        case .openBeside: [.openBeside]
        case .openInNewWindow: [.openInNewWindow]
        case .star: [.toggleStar]
        case .rename: [.renameNote]
        case .wingDoors: [.moveNoteToWing, .copyNoteToWing]
        case .export: [.exportNote]
        case .moveToChapter: [.fileNoteInChapter]
        case .removeFromBook: [.removeFromBook]
        case .archive: [.archiveNote]
        case .delete: [.deleteNote]
        }
    }
}

/// The facts the table reads: the book's kind (nil — not read yet) and which
/// composition roads arrived.
nonisolated struct BookNoteTitleFacts: Equatable, Sendable {
    var bookKind: ReadingKind?
    var canOpenBeside = false
    var canOpenInNewWindow = false
    var canStar = false

    init(
        bookKind: ReadingKind?, canOpenBeside: Bool = false, canOpenInNewWindow: Bool = false,
        canStar: Bool = false
    ) {
        self.bookKind = bookKind
        self.canOpenBeside = canOpenBeside
        self.canOpenInNewWindow = canOpenInNewWindow
        self.canStar = canStar
    }
}

/// **WHICH doors the note-title menu draws, in its groups** (a divider
/// between groups) — pure, pinned.
nonisolated enum BookNoteTitleMenuTable {
    /// The note's OWN doors (every one in the note rows' grammar).
    static let noteDoors: [BookNoteTitleDoor] = [
        .openBeside, .openInNewWindow, .star, .rename, .wingDoors, .export, .archive, .delete,
    ]
    /// The book's structure pair — a BOOK's notes only (a gathering holds no
    /// membership; chapters are a book's — QUESTIONS #25(a)).
    static let structureDoors: [BookNoteTitleDoor] = [.moveToChapter, .removeFromBook]

    static func groups(_ facts: BookNoteTitleFacts) -> [[BookNoteTitleDoor]] {
        var opening: [BookNoteTitleDoor] = []
        if facts.canOpenBeside { opening.append(.openBeside) }
        if facts.canOpenInNewWindow { opening.append(.openInNewWindow) }
        if facts.canStar { opening.append(.star) }
        var groups: [[BookNoteTitleDoor]] = [opening, [.rename, .wingDoors, .export]]
        if facts.bookKind == .book {
            // As shipped: Move to Chapter ▸, a divider, Remove / Release.
            groups += [[.moveToChapter], [.removeFromBook]]
        }
        // Set apart, LAST — Delete the very last (the Open list's rule).
        groups.append([.archive, .delete])
        return groups.filter { !$0.isEmpty }
    }

    static func doors(_ facts: BookNoteTitleFacts) -> [BookNoteTitleDoor] {
        groups(facts).flatMap { $0 }
    }

    /// P-1's walk line: every act the menu can draw.
    static var capabilities: [CapabilityID] {
        (noteDoors + structureDoors).flatMap(\.capabilities)
    }
}

// MARK: - The asks (the menu's state, hosted by the book)

/// **The note-title menu's asks** — the rename field, the delete confirm and
/// the cross-wing move confirm (an alert cannot hang off a menu item, so the
/// book hosts them — `.bookNoteTitleAsks`). Holds ids and items, never text
/// of hers beyond the rename field she is typing; every write is a shared
/// road's.
@MainActor
@Observable
final class BookNoteTitleDoors {
    var renameTarget: String?
    var renameTitle = ""
    var pendingDelete: NoteDeleteConfirm?
    var wingMove: WingsModel.MoveAsk?

    init() {}

    /// Rename… — the ONE ask, seeded with the STORED title (never the display
    /// answer — 13g R6-3).
    func beginRename(session: AppSession, postID: String) async {
        renameTitle = await NoteRename.storedTitle(session: session, postID: postID)
        renameTarget = postID
    }

    /// The rename's act — the one body (`NoteRename.rename`); a refusal SPEAKS.
    func rename(session: AppSession, postID: String, title: String) async {
        do {
            try await NoteRename.rename(session: session, postID: postID, title: title)
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
        }
    }

    /// Delete Note… — the one shared ask (its version count read now).
    func askDelete(session: AppSession, postID: String) async {
        pendingDelete = await NoteDeletion.ask(session: session, postIDs: [postID])
    }

    /// Archive — `archiveContainer`, and the receipt that says where the note
    /// went (ledger row 25 — an archive must never read as a deletion). In a
    /// book the note stays a member, on the book's archived line.
    func archive(session: AppSession, postID: String) async {
        do {
            try await session.runner.run { try $0.archiveContainer(postID) }
            session.status.receipt(RecoveryCopy.archivedNoteReceipt)
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
        }
    }
}

// MARK: - The menu

/// **The note-title menu** — the table's doors, each its registry act's word.
struct BookNoteTitleMenu: View {
    let structure: BookStructureModel
    let postID: String
    /// The note's name as the book shows it (the cross-wing confirm's words).
    let title: String
    let doors: BookNoteTitleDoors
    var roads = BookNoteRoads()
    /// The window's wings brain (nil in a harness mount — no wing doors, P-2).
    @Environment(WingsModel.self) private var wings: WingsModel?

    private var session: AppSession { structure.session }

    var body: some View {
        let groups = BookNoteTitleMenuTable.groups(BookNoteTitleFacts(
            bookKind: structure.reading?.kind,
            canOpenBeside: roads.openBeside != nil,
            canOpenInNewWindow: roads.openInNewWindow != nil,
            canStar: roads.starDoor != nil))
        ForEach(Array(groups.enumerated()), id: \.offset) { index, group in
            if index > 0 { Divider() }
            ForEach(group, id: \.self) { door in
                item(door)
            }
        }
    }

    private func verb(_ act: CapabilityID) -> String { CapabilityRegistry.capability(act).verb }

    @ViewBuilder
    private func item(_ door: BookNoteTitleDoor) -> some View {
        switch door {
        case .openBeside:
            if let open = roads.openBeside { Button(verb(.openBeside)) { open(postID) } }
        case .openInNewWindow:
            if let open = roads.openInNewWindow { Button(verb(.openInNewWindow)) { open(postID) } }
        case .star:
            if let starDoor = roads.starDoor {
                Button(starDoor.title(for: .post(postID))) { starDoor.toggle(.post(postID)) }
            }
        case .rename:
            Button(verb(.renameNote)) {
                Task { await doors.beginRename(session: session, postID: postID) }
            }
        case .wingDoors:
            // From the note's OWN wing — a book's notes live in the book's.
            if let wings {
                WingNoteDoors(
                    wings: wings, postID: postID, title: title,
                    fromWing: structure.reading?.wingId, onAsk: { doors.wingMove = $0 })
            }
        case .export:
            Button(verb(.exportNote)) {
                Task { await NoteExport.export(postID: postID, session: session) }
            }
        case .moveToChapter:
            // 13i-d U3 (F-U2-3): the Book Panel's act, spelled from the
            // registry — "Move to Chapter ▸" with the headers' "unfiled".
            Menu(verb(.fileNoteInChapter)) {
                ForEach(structure.sections, id: \.id) { section in
                    Button(section.name) {
                        Task { await structure.assign(postID, to: section.id) }
                    }
                }
                Divider()
                Button(BookPanelCopy.noChapter) {
                    Task { await structure.assign(postID, to: nil) }
                }
            }
        case .removeFromBook:
            // 13i-c U4 (§20): one act, its word the book's ("Release from This
            // Book" on an owned book: the note goes back to the Pool, whole).
            if let book = structure.reading {
                Button(RemoveFromBookCopy.verb(owned: book.owned)) {
                    Task {
                        await RemoveFromBookDoor.remove(session: session, postID: postID, book: book)
                    }
                }
            }
        case .archive:
            Button(verb(.archiveNote)) {
                Task { await doors.archive(session: session, postID: postID) }
            }
        case .delete:
            Button(RecoveryCopy.deleteNoteTitle, role: .destructive) {
                Task { await doors.askDelete(session: session, postID: postID) }
            }
        }
    }
}

// MARK: - The host

extension View {
    /// Hosts the note-title menu's asks on the book (an alert cannot hang off
    /// a menu item): the ONE rename ask, the ONE delete confirm (whose
    /// `NoteDeletion.fire` moves every pane off the tombstone), the ONE
    /// cross-wing move confirm.
    func bookNoteTitleAsks(
        _ doors: BookNoteTitleDoors, session: AppSession, wings: WingsModel?
    ) -> some View {
        self
            .noteRenameAlert(
                target: Bindable(doors).renameTarget, title: Bindable(doors).renameTitle
            ) { postID, title in
                Task { await doors.rename(session: session, postID: postID, title: title) }
            }
            .deleteNoteConfirmDialog(Bindable(doors).pendingDelete) { confirm in
                NoteDeletion.fire(session: session, postIDs: confirm.postIDs)
            }
            .wingMoveConfirm(Bindable(doors).wingMove, wings: wings)
    }
}
