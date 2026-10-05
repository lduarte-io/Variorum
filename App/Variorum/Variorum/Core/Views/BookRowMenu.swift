//
//  BookRowMenu.swift
//  Variorum (Mac) — Core/Views (the shared home: three features render it)
//
//  17y item (l) — CONTEXT-MENU PARITY FOR BOOK ROWS BEYOND THE BOOKCASE (her
//  walk close, with the capture: "it's really weird that you get the menu of
//  things to do when you two finger press on a note from within library, but
//  don't get a book's options (maybe not all of them, like the move up and
//  down, and the move to shelf, but at least the basic ones like star)").
//
//  THE SURFACES (enumerated in the B3 RECORD — every surface that renders a
//  book or gathering ROW outside the Bookcase; pickers aside): the Library's
//  List mode, its Books section · the sidebar's Starred section, its book
//  rows · the Archived surface's BOOKS group. Each renders THIS menu — one
//  door table, no per-view ifs (P-1).
//
//  THE TABLE (her carve-out applied, the basics proposed — PROVISIONAL
//  P-17y-B3-l1): Open · Star/Unstar · Book/Gathering Settings… · Export
//  Markdown… · Export PDF… · Archive (or Unarchive) · Delete Book… (never on
//  the daily Journal — `BookArchiveDoorSet`, the op's own guard). The
//  Bookcase menu's POSITIONAL doors drop (Move to Shelf ▸, Send to Top /
//  Bottom — position means nothing off the Bookcase), and so do the
//  Bookcase-local ceremonies whose home is the board or the book (Move to
//  Wing ▸, Duplicate Book…, Manage Notes…, Bind / Make a Book, Use as Daily
//  Journal); Rename, the rule, the word target/cap and the state doors are
//  one click further — inside Book Settings, the menu's hub.
//
//  The acts are the registry's (P-1): `.toggleStar`, `.openBookSettings`,
//  `.archiveBook`, `.unarchiveBook`, `.deleteBook` — one declaration each,
//  this menu a further renderer (`contextMenuCapabilities`, the walk's
//  union). The state doors run through the surface's `BookStateDoors` (its
//  confirms — the owned book's archive ask, every delete — on the one
//  presentation road, `.bookStateConfirms`).
//

import SwiftUI
import VariorumCore

/// One door of a book row's menu beyond the Bookcase.
nonisolated enum BookRowDoor: Hashable, Sendable {
    case open
    case star
    case settings
    case exportMarkdown
    case exportPDF
    /// A state door from the archive table (Archive · Unarchive · Delete).
    case state(CapabilityID)
}

/// **THE TABLE** — which doors a book row draws off the Bookcase (pure,
/// pinned). nil facts (a row whose reading has not been read yet) draw the
/// doors that need none; the state doors wait for the facts (P-2: a door
/// whose truth is unknown is not drawn).
nonisolated enum BookRowMenuTable {
    static func doors(for reading: Reading?) -> [BookRowDoor] {
        var out: [BookRowDoor] = [.open, .star, .settings, .exportMarkdown, .exportPDF]
        if let reading {
            out += BookArchiveDoorSet.rendered(for: BookArchiveFacts(reading)).map { .state($0) }
        }
        return out
    }

    /// The Bookcase doors this table deliberately leaves off (her carve-out:
    /// position means nothing here; plus the board's own ceremonies).
    static let bookcaseOnly: [CapabilityID] = [
        .moveBookToShelf, .sendBookToTop, .sendBookToBottom, .moveBookToWing,
        .duplicateBook, .bindIntoBook, .makeBookFromGathering, .editRule,
    ]
}

/// **The surface's brain for the menu** — the facts its rows need (a
/// one-shot read of the LISTED books, ∝ the rows, P1), the state doors it
/// presents through, and the settings sheet it opens (the Bookcase row's
/// own road, `BookSettingsTarget.load` → `BookSettingsHost`, its Edit… handed
/// back and opened after the sheet is gone — W-1's rule).
@MainActor
@Observable
final class BookRowDoors {
    @ObservationIgnored let session: AppSession
    let stateDoors: BookStateDoors
    /// The listed books' rows, by id.
    private(set) var facts: [String: Reading] = [:]
    var settingsTarget: BookSettingsTarget?
    var pendingRuleEditor: RuleEditorModel?
    var ruleEditor: RuleEditorModel?
    /// Raised after a state door ran (acted at once, or a confirm landed) —
    /// a surface whose listing is a ONE-SHOT read re-asks it here (the
    /// Library's catalog; the walk's W-2: a book deleted from its row menu
    /// stayed listed). Held listings (Starred, Archived) need nothing.
    @ObservationIgnored var onLanded: () -> Void = {}

    init(session: AppSession, stateDoors: BookStateDoors? = nil) {
        self.session = session
        self.stateDoors = stateDoors ?? BookStateDoors(session: session)
    }

    /// Read the listed books' rows (one statement per call, the listing's
    /// ids only). Called by each host's `.task(id:)` over its book ids.
    func load(_ readingIDs: [String]) async {
        guard !readingIDs.isEmpty else {
            facts = [:]
            return
        }
        let rows: [Reading] = (try? await session.database.read { db in
            try readingIDs.compactMap { try Queries.reading(db, id: $0) }
        }) ?? []
        facts = Dictionary(rows.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    }

    /// Internal so pins can hand the facts in (hosted `.task` callbacks
    /// don't fire under the test host — the `BookArrivalsModel.adopt` rule).
    func adopt(_ readings: [Reading]) {
        facts = Dictionary(readings.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
    }

    func openSettings(_ readingID: String) async {
        if let target = await BookSettingsTarget.load(session: session, readingID: readingID) {
            settingsTarget = target
        } else {
            session.status.refuse(
                OpsRefusalCopy.message(for: OperationError.readingNotFound(id: readingID)))
        }
    }

    func open(_ act: CapabilityID, readingID: String) async {
        await stateDoors.open(act, readingID: readingID)
        // An act that asked first lands later, through the host's confirm
        // (which raises it again) — re-asking a one-shot listing twice is
        // harmless.
        onLanded()
    }
}

/// **The menu itself** — the table's doors, each its registry act's word.
struct BookRowMenu: View {
    /// P-1's walk: the registry acts this renderer draws.
    static let contextMenuCapabilities: [CapabilityID] = [
        .toggleStar, .openBookSettings, .archiveBook, .unarchiveBook, .deleteBook,
    ]

    let readingID: String
    let doors: BookRowDoors
    var starDoor: StarDoor?
    let open: () -> Void

    var body: some View {
        let reading = doors.facts[readingID]
        ForEach(BookRowMenuTable.doors(for: reading), id: \.self) { door in
            switch door {
            case .open:
                Button("Open") { open() }
            case .star:
                if let starDoor {
                    Button(starDoor.title(for: .reading(readingID))) {
                        starDoor.toggle(.reading(readingID))
                    }
                }
            case .settings:
                Button(CollectingCopy.openVerb(isBook: reading?.kind != .gathering)) {
                    Task { await doors.openSettings(readingID) }
                }
            case .exportMarkdown:
                if let reading {
                    Button("Export Markdown\u{2026}") {
                        ReadingExport.export(session: doors.session, reading: reading, asPDF: false)
                    }
                }
            case .exportPDF:
                if let reading {
                    Button("Export PDF\u{2026}") {
                        ReadingExport.export(session: doors.session, reading: reading, asPDF: true)
                    }
                }
            case .state(let act):
                if act == .deleteBook {
                    Button(CapabilityRegistry.capability(.deleteBook).verb + "\u{2026}",
                           role: .destructive) {
                        Task { await doors.open(.deleteBook, readingID: readingID) }
                    }
                } else if act == .archiveBook, let reading {
                    Button(BookStateCopy.archiveDoorLabel(asks: BookStateCopy.archiveAsks(reading))) {
                        Task { await doors.open(.archiveBook, readingID: readingID) }
                    }
                } else {
                    Button(CapabilityRegistry.capability(act).verb) {
                        Task { await doors.open(act, readingID: readingID) }
                    }
                }
            }
        }
    }
}

extension View {
    /// Hosts what a book row's menu presents: the settings sheet (and the
    /// rule editor its Edit… hands back, opened once the sheet is gone), and
    /// — unless the surface already hosts them for the same doors — the
    /// state doors' confirms.
    func bookRowDoors(_ doors: BookRowDoors, hostsStateConfirms: Bool = true) -> some View {
        modifier(BookRowDoorsHost(doors: doors, hostsStateConfirms: hostsStateConfirms))
    }
}

private struct BookRowDoorsHost: ViewModifier {
    let doors: BookRowDoors
    let hostsStateConfirms: Bool

    func body(content: Content) -> some View {
        let hosted = content
            .sheet(item: Bindable(doors).settingsTarget, onDismiss: {
                if let next = doors.pendingRuleEditor {
                    doors.pendingRuleEditor = nil
                    doors.ruleEditor = next
                }
            }) { target in
                BookSettingsHost(target: target) { editor in doors.pendingRuleEditor = editor }
            }
            .sheet(item: Bindable(doors).ruleEditor) { editor in
                RuleEditorSheet(model: editor)
            }
        if hostsStateConfirms {
            hosted.bookStateConfirms(doors.stateDoors) { _ in doors.onLanded() }
        } else {
            hosted
        }
    }
}

/// The host for a surface whose doors are optional (the sidebar's harness
/// mounts carry none — nothing is presented then).
struct OptionalBookRowDoorsHost: ViewModifier {
    let doors: BookRowDoors?

    func body(content: Content) -> some View {
        if let doors {
            content.bookRowDoors(doors)
        } else {
            content
        }
    }
}
