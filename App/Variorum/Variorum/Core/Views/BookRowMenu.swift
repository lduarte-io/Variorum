//
//  BookRowMenu.swift
//  Variorum (Mac) — Core/Views (the shared home: four features render it)
//
//  17y item (l) — CONTEXT-MENU PARITY FOR BOOK ROWS BEYOND THE BOOKCASE (her
//  walk close, with the capture: "it's really weird that you get the menu of
//  things to do when you two finger press on a note from within library, but
//  don't get a book's options (maybe not all of them, like the move up and
//  down, and the move to shelf, but at least the basic ones like star)").
//
//  VX-829 (the VX-878 run, batch 1 — her 2026-11-04 ask, two screenshots: a
//  Library book row offered only "Ask Siri · Open · Star · Book Settings… ·
//  Export Markdown/PDF · Share with AI… · Archive · Delete Book…" — "the
//  options that are available in bookcase on a book should be available on
//  library (within reason, like the shelf options don't need to be there)").
//  17y's trimmed "basics" table (PROVISIONAL P-17y-B3-l1) is SUPERSEDED: there
//  is now ONE book-row menu table with TWO FACES —
//
//  · **the Bookcase** — the board's book row: every door, the shelf-placement
//    family included (Move to Shelf ▸, and my order's Send to Top / Bottom);
//  · **elsewhere** — every book row beyond the Bookcase (the Library's List
//    Books section, the sidebar's Starred book rows, the Archived surface's
//    books group): **the Bookcase's doors MINUS shelf placement, with Open
//    leading** — derived BY CONSTRUCTION from the Bookcase face
//    (`BookRowMenuTable.groups`), never a second hand-kept list, so the two
//    faces cannot drift (P-1).
//
//  ONE renderer draws both faces (`BookRowMenuItems` — the words, the roles,
//  the dividers live once), and ONE brain performs both faces' acts and hosts
//  their sheets (`BookRowDoors` — the Bookcase's own instance rides its model;
//  each surface beyond holds one). The Bookcase hands in only what no other
//  surface has: its shelf-placement doors (`placement:`).
//
//  The acts are the registry's (P-1) — `BookRowMenuTable.capabilities(face)`
//  is each face's walk line; four of the Bookcase's doors that were never
//  declared (Rename…, Manage Notes…, Length & Extent…, Use as Daily Journal)
//  are declared at this, their second renderer (`.renameNote`'s precedent).
//  The state doors run through the face's `BookStateDoors` (its confirms — the
//  owned book's archive ask, every delete — on the one presentation road,
//  `.bookStateConfirms`).
//

import SwiftUI
import VariorumCore

// MARK: - The words

/// The verbs of the four doors VX-829 declared (the Bookcase's own words,
/// byte-for-byte), and the note a door speaks where nothing can act.
nonisolated enum BookRowMenuCopy {
    static let renameVerb = "Rename\u{2026}"
    /// The rename ask's title (the board's shipped alert).
    static let renameAlertTitle = "Rename Book"
    static let manageNotesVerb = "Manage Notes\u{2026}"
    static let extentVerb = "Length & Extent\u{2026}"
    static let useAsDailyJournalVerb = "Use as Daily Journal"
    /// Every row renderer carries its book, so this is said only by a door
    /// asked to act with no row in hand.
    static let unavailableNote =
        "A book's own doors act on its row \u{2014} right-click a book on the Bookcase or in the "
        + "Library."
    /// The undeclared row doors' words (they were never registry acts).
    static let openVerb = "Open"
    static let exportMarkdownVerb = "Export Markdown\u{2026}"
    static let exportPDFVerb = "Export PDF\u{2026}"
}

// MARK: - The doors and the table (pure)

/// One door of a book row's menu, on either face.
nonisolated enum BookRowDoor: Hashable, Sendable {
    /// Elsewhere only: the Bookcase row's click opens the book.
    case open
    case star
    /// THE SHELF-PLACEMENT FAMILY — the Bookcase's alone (her carve-out:
    /// "like the shelf options don't need to be there").
    case moveToShelf, sendToTop, sendToBottom
    case moveToWing
    case rename
    case settings
    /// 13n-c U3 (VX-156 item 2): "Share with AI…" — THE grant sheet
    /// pre-filled on this book. Drawn only when an approved client exists
    /// (VX-272) and the reading can take a grant (never the daily Journal or a
    /// Private book — the op refuses those, P-2). VX-189: a gathering's too.
    case share
    case duplicate
    case editRule
    case manageNotes
    /// A gathering's two strengthening doors (13i-b U3).
    case bind, makeBook
    case extent
    case useAsDailyJournal
    case exportMarkdown, exportPDF
    /// A state door from the state table (Finish · Reopen · Seal… · Unseal ·
    /// Own Its Notes… · Stop Owning) or the archive table (Archive ·
    /// Unarchive · Delete).
    case state(CapabilityID)

    /// The shelf-placement family — the doors the Bookcase alone draws.
    var isShelfPlacement: Bool {
        switch self {
        case .moveToShelf, .sendToTop, .sendToBottom: true
        default: false
        }
    }

    /// The registry act this door draws (nil: a door that was never a
    /// registry act — Open and the two exports).
    var capability: CapabilityID? {
        switch self {
        case .open, .exportMarkdown, .exportPDF: nil
        case .star: .toggleStar
        case .moveToShelf: .moveBookToShelf
        case .sendToTop: .sendBookToTop
        case .sendToBottom: .sendBookToBottom
        case .moveToWing: .moveBookToWing
        case .rename: .renameBook
        case .settings: .openBookSettings
        case .share: .mcpShareHere
        case .duplicate: .duplicateBook
        case .editRule: .editRule
        case .manageNotes: .manageBookNotes
        case .bind: .bindIntoBook
        case .makeBook: .makeBookFromGathering
        case .extent: .setBookExtent
        case .useAsDailyJournal: .useAsDailyJournal
        case .state(let act): act
        }
    }
}

/// Which face of the one menu a host draws.
nonisolated enum BookMenuFace: Sendable {
    /// The Bookcase's book row — the shelf-placement family included.
    case bookcase
    /// Every book row beyond the Bookcase.
    case elsewhere
}

/// The facts the table reads — the book, and the per-host truths a door's
/// drawing rule needs (P-2: a door that cannot act is not drawn).
nonisolated struct BookMenuFacts: Equatable, Sendable {
    /// nil: the row's reading is not read yet — only the doors that need no
    /// facts draw.
    var reading: Reading?
    /// VX-272 (an approved client exists) ∧ the book can take a grant.
    var shareable = false
    /// How many OTHER wings the book could move to (`WingsModel.destinations`
    /// from its own wing; 0 in a harness mount with no wings brain).
    var wingDestinations = 0
    /// The Bookcase's own facts (the elsewhere face never draws their doors):
    /// whether Move to Shelf ▸ has somewhere to go
    /// (`BookcaseBoard.moveToShelfCanAct`), and whether the board is in the
    /// placing mode (my order's Send to Top / Bottom — §20, §24).
    var shelfMoveCanAct = false
    var placesByHand = false

    init(
        reading: Reading?, shareable: Bool = false, wingDestinations: Int = 0,
        shelfMoveCanAct: Bool = false, placesByHand: Bool = false
    ) {
        self.reading = reading
        self.shareable = shareable
        self.wingDestinations = wingDestinations
        self.shelfMoveCanAct = shelfMoveCanAct
        self.placesByHand = placesByHand
    }
}

/// **THE TABLE** — which doors a book row draws, on either face, in its
/// groups (a divider between groups). Pure, pinned.
nonisolated enum BookRowMenuTable {
    /// The shelf-placement family's acts — the Bookcase face's alone.
    static let shelfPlacementCapabilities: [CapabilityID] = [
        .moveBookToShelf, .sendBookToTop, .sendBookToBottom,
    ]

    /// The groups a face draws, in order. **The elsewhere face is DERIVED from
    /// the Bookcase face** — its groups with the shelf-placement family
    /// removed and Open leading — so a door added to the Bookcase row comes
    /// over by construction (VX-829's "declared once … so the two faces can't
    /// drift").
    static func groups(_ facts: BookMenuFacts, face: BookMenuFace) -> [[BookRowDoor]] {
        let board = bookcaseGroups(facts)
        switch face {
        case .bookcase:
            return board
        case .elsewhere:
            var derived = board.map { $0.filter { !$0.isShelfPlacement } }
            if derived.isEmpty { derived = [[]] }
            derived[0].insert(.open, at: 0)
            return derived.filter { !$0.isEmpty }
        }
    }

    /// The doors a face draws, flat (the pins' and the walk's reading).
    static func doors(_ facts: BookMenuFacts, face: BookMenuFace) -> [BookRowDoor] {
        groups(facts, face: face).flatMap { $0 }
    }

    /// The elsewhere face for a row's reading (17y's signature, kept for its
    /// pins): the doors beyond the Bookcase.
    static func doors(for reading: Reading?, shareable: Bool = false) -> [BookRowDoor] {
        doors(BookMenuFacts(reading: reading, shareable: shareable), face: .elsewhere)
    }

    /// **The Bookcase row's groups** — the source face, in the board's
    /// shipped order (13f W4 → 13i-e U2 → 13n-c U3).
    private static func bookcaseGroups(_ facts: BookMenuFacts) -> [[BookRowDoor]] {
        guard let reading = facts.reading else {
            // Facts unknown: only the doors that need none (the star acts by
            // id; the settings sheet loads its own book).
            return [[.star], [.settings]]
        }
        let isBook = reading.kind == .book
        // Where it lives — and, on the Bookcase, where it sits.
        var placing: [BookRowDoor] = [.star]
        if facts.shelfMoveCanAct { placing.append(.moveToShelf) }
        // 13i-d U5b: Move to Wing ▸ — books AND gatherings, the daily Journal
        // too since VX-435, never while one library stands alone.
        if WingBookMoveDoor.drawn(reading: reading, destinations: facts.wingDestinations) {
            placing.append(.moveToWing)
        }
        if facts.placesByHand { placing += [.sendToTop, .sendToBottom] }

        // What it is — its name, its settings, its sharing, its configuration.
        var configure: [BookRowDoor] = [.rename, .settings]
        if facts.shareable { configure.append(.share) }
        // 13i-c U4: Duplicate — books only (a gathering has no duplicate op).
        if isBook { configure.append(.duplicate) }
        // 13i-b U3: the rule editor, for gatherings AND books.
        configure.append(.editRule)
        if isBook {
            configure.append(.manageNotes)
        } else {
            // 13i-b U3 — the two strengthening doors: Bind hides on a finished
            // gathering, both on a rule-less one (P-2 — the op refuses).
            let hasRule = RuleGrammar.read(reading.querySpec) != .none
            if !reading.locked, hasRule { configure.append(.bind) }
            if hasRule { configure.append(.makeBook) }
        }
        // 13i-d U1 (row 107's shelf half): a gathering has no word target or
        // capacity — Length & Extent… is a BOOK's door only.
        if isBook { configure.append(.extent) }
        // The designation door — a journal-trait book of ANY wing (VX-435).
        if isBook, Queries.hasJournalTrait(reading.profile) {
            configure.append(.useAsDailyJournal)
        }

        // 13i-c U3 — the state doors, from the one table (a gathering has no
        // finish; Reopen stays only on a legacy-finished one, its way out).
        let state = BookStateDoorSet.rendered(for: BookStateFacts(reading)).map(BookRowDoor.state)
        // 13i-e U2 — Archive (or Unarchive) beside the ONE delete road, from
        // the archive table (Delete on every reading since VX-436 — the daily
        // Journal included, N-1 of the VX-878 record). The Bookcase never
        // lists an archived book, so its rows meet Unarchive only elsewhere.
        let archive = BookArchiveDoorSet.rendered(for: BookArchiveFacts(reading)).map(BookRowDoor.state)
        // A group with nothing in it draws nothing — never two dividers in a
        // row (an open gathering has no state door).
        return [placing, configure, state, [.exportMarkdown, .exportPDF], archive]
            .filter { !$0.isEmpty }
    }

    /// **Every registry act a face can draw** (P-1's walk lines). The
    /// Bookcase's never includes Unarchive (an archived book is never on the
    /// board); elsewhere is the Bookcase's minus the shelf-placement family,
    /// plus Unarchive (the Archived surface's rows, a starred archived book).
    static func capabilities(_ face: BookMenuFace) -> [CapabilityID] {
        let board: [CapabilityID] = [
            .toggleStar, .moveBookToShelf, .moveBookToWing, .sendBookToTop, .sendBookToBottom,
            .renameBook, .openBookSettings, .mcpShareHere, .duplicateBook, .editRule,
            .manageBookNotes, .bindIntoBook, .makeBookFromGathering, .setBookExtent,
            .useAsDailyJournal,
        ] + BookStateDoorSet.all + [.archiveBook, .deleteBook]
        switch face {
        case .bookcase:
            return board
        case .elsewhere:
            return board.filter { !shelfPlacementCapabilities.contains($0) } + [.unarchiveBook]
        }
    }
}

// MARK: - The brain

/// **The book rows' one brain** — the facts a surface's rows need (a one-shot
/// read of the LISTED books, ∝ the rows, P1), the state doors it presents
/// through, and every row door's act and sheet (VX-829: the Bookcase holds an
/// instance on its model; each surface beyond holds its own). Holds
/// projections and items; every write is an operation's; every outcome speaks
/// on the status seam.
@MainActor
@Observable
final class BookRowDoors {
    @ObservationIgnored let session: AppSession
    let stateDoors: BookStateDoors
    /// The listed books' rows, by id (the surfaces beyond the Bookcase; the
    /// board hands its own rows to the renderer).
    private(set) var facts: [String: Reading] = [:]
    /// 13n-c U3: the live books a grant may NOT name (THE daily Journal,
    /// Private books — `Queries.mcpFencedBookIDs`, the one fence's own
    /// fragments): their row draws no "Share with AI…" (P-2). VX-189: and the
    /// fenced gatherings (a stale synced stamp — the same fragments).
    private(set) var fencedBooks: Set<String> = []
    var settingsTarget: BookSettingsTarget?
    var pendingRuleEditor: RuleEditorModel?
    var ruleEditor: RuleEditorModel?
    // VX-829 — the Bookcase row's sheets, now every face's (each item IS its
    // sheet's input — the `BindOffer` lesson).
    var renameTarget: Reading?
    var renameField = ""
    var manageTarget: Reading?
    var extentTarget: Reading?
    var duplicateOffer: DuplicateBookOffer?
    var bindOffer: BindOffer?
    var spawnOffer: SpawnOffer?
    /// 13i-d U5b — the book move's counting confirm (its item IS the act's
    /// preview), and the wings brain that asked (the confirm acts through it).
    var bookMoveAsk: WingsModel.BookMoveAsk?
    @ObservationIgnored private(set) var moveWings: WingsModel?
    /// Manage Notes…'s and Rename…'s acts are the Readings feature's own
    /// (`ManageReadingPostsSheet` takes this model; `rename` holds E13's
    /// guard) — one instance for the brain's life, never started (no listing).
    @ObservationIgnored let readings: ReadingsViewModel
    /// Raised after a row act LANDED (acted at once, a confirm landed, or one
    /// of its sheets closed) — a surface whose listing is a ONE-SHOT read
    /// re-asks it here (the Library's catalog; the walk's W-2: a book deleted
    /// from its row menu stayed listed; the board's aggregates).
    @ObservationIgnored var onLanded: () -> Void = {}

    init(session: AppSession, stateDoors: BookStateDoors? = nil) {
        self.session = session
        self.stateDoors = stateDoors ?? BookStateDoors(session: session)
        self.readings = ReadingsViewModel(session: session)
    }

    /// Read the listed books' rows: ONE read transaction, one row lookup per
    /// listed id — bounded by the listing (∝ the rows, P1). Called by each
    /// host's `.task(id:)` over its book ids. (The ladder's round-1 NIT-3:
    /// the old sentence claimed "one statement per call".)
    func load(_ readingIDs: [String]) async {
        guard !readingIDs.isEmpty else {
            facts = [:]
            return
        }
        let (rows, fenced): ([Reading], Set<String>) = (try? await session.database.read { db in
            (try readingIDs.compactMap { try Queries.reading(db, id: $0) }, try Queries.mcpFencedBookIDs(db))
        }) ?? ([], [])
        facts = Dictionary(rows.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        fencedBooks = fenced
    }

    /// Internal so pins can hand the facts in (hosted `.task` callbacks
    /// don't fire under the test host — the `BookArrivalsModel.adopt` rule).
    func adopt(_ readings: [Reading], fenced: Set<String> = []) {
        facts = Dictionary(readings.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        fencedBooks = fenced
    }

    /// **A row act LANDED** (VX-829): the listed rows' facts are re-read —
    /// the menu's doors read them, and a door's truth may have moved with the
    /// act (Finish ⇒ Reopen, a new name to seed Rename…, a book gone) — then
    /// the surface hears it (`onLanded`). ∝ the listed rows (P1). The
    /// Bookcase's brain holds no facts (the board hands its held rows in), so
    /// there it only signals.
    func landed() {
        onLanded()
        let ids = Array(facts.keys)
        guard !ids.isEmpty else { return }
        Task { await load(ids) }
    }

    func openSettings(_ readingID: String) async {
        if let target = await BookSettingsTarget.load(session: session, readingID: readingID) {
            settingsTarget = target
        } else {
            session.status.refuse(
                OpsRefusalCopy.message(for: OperationError.readingNotFound(id: readingID)))
        }
    }

    /// A state door (the state table's or the archive table's).
    func open(_ act: CapabilityID, readingID: String) async {
        await stateDoors.open(act, readingID: readingID)
        // An act that asked first lands later, through the host's confirm
        // (which raises it again) — re-asking a one-shot listing twice is
        // harmless.
        landed()
    }

    // MARK: VX-829 — the Bookcase row's doors, every face's

    /// Rename… — the ask, seeded with the book's stored name.
    func beginRename(_ reading: Reading) {
        renameField = reading.name
        renameTarget = reading
    }

    /// The rename's act: E13's guard and the op, through the Readings
    /// feature's one road (`ReadingsViewModel.rename` — the guard excludes
    /// this book's own row); its refusal SPOKEN.
    func rename(_ readingID: String, to name: String) async {
        await readings.rename(readingID, to: name)
        if let error = readings.lastError {
            session.status.refuse(error)
        } else {
            landed()
        }
    }

    func openRuleEditor(_ readingID: String) {
        ruleEditor = RuleEditorModel(session: session, readingID: readingID)
    }

    func openManage(_ reading: Reading) { manageTarget = reading }

    func openExtent(_ reading: Reading) { extentTarget = reading }

    /// Length & Extent…'s save: the word target, then the cap — each its own
    /// operation (the board's shipped order); a refusal SPEAKS and the second
    /// write still runs (as the board's did).
    func saveExtents(_ readingID: String, wordTarget: Int?, maxPosts: Int?) async {
        await run { try $0.setReadingWordTarget(readingID, wordTarget: wordTarget) }
        await run { try $0.setReadingMaxPosts(readingID, maxPosts: maxPosts) }
        landed()
    }

    func openDuplicate(_ reading: Reading) {
        duplicateOffer = DuplicateBookOffer(
            readingID: reading.id, name: reading.name, owned: reading.owned)
    }

    /// Bind into a Book…'s one road: load the offer (count included), then
    /// present it with ONE write — the sheet reads everything from its item.
    func openBind(_ reading: Reading) async {
        bindOffer = await BindOffer.load(session, reading: reading)
    }

    /// The bind's act — the ONE body (`BookRowActs.bind`), its receipt, or
    /// the op's own refusal named for the book (a finished gathering names
    /// Reopen — the board's `bookRefusal` words, read fresh here).
    func bind(_ readingID: String, ownedNotes: Operations.BindOwnedNotes) async {
        do {
            session.status.receipt(try await BookRowActs.bind(
                session: session, readingID: readingID, ownedNotes: ownedNotes))
        } catch {
            await refuse(error, readingID: readingID)
        }
        landed()
    }

    func openSpawn(_ reading: Reading) async {
        spawnOffer = await SpawnOffer.load(session, gathering: reading)
    }

    /// Make a Book…'s act — the ONE body (`BookRowActs.spawnBook`).
    func spawn(from gatheringID: String, named name: String, outflow: [String]) async {
        do {
            let made = try await BookRowActs.spawnBook(
                session: session, from: gatheringID, named: name, outflow: outflow)
            session.status.receipt(made.receipt)
        } catch let error as OperationError {
            session.status.refuse(ReadingsViewModel.message(error))
        } catch {
            session.status.refuse(String(describing: error))
        }
        landed()
    }

    /// Use as Daily Journal — the re-designation (round 2, MAJOR 2): point
    /// Today's Entry at this journal-trait book. Silent on success (the
    /// board's shipped posture); a refusal SPEAKS.
    func designateDailyJournal(_ readingID: String) async {
        await run { try $0.setDailyJournalBook(readingID) }
        landed()
    }

    /// Move to Wing ▸'s pick: the act's own preview as the confirm's item (or
    /// the door speaks a frozen stay-behind's refusal — `bookMoveAsk`).
    func askMove(_ reading: Reading, to wingID: String, wings: WingsModel) async {
        moveWings = wings
        bookMoveAsk = await wings.bookMoveAsk(reading: reading, to: wingID)
    }

    private func run(_ body: @escaping @Sendable (Operations) throws -> Void) async {
        do {
            try await session.runner.run(body)
        } catch let error as OperationError {
            session.status.refuse(ReadingsViewModel.message(error))
        } catch {
            session.status.refuse(String(describing: error))
        }
    }

    /// A refusal about ONE book: a finished (or sealed) book names its road
    /// back through `BookStateCopy.refusal`, read fresh; every other refusal
    /// keeps the books table's words (the board's `bookRefusal` shape).
    private func refuse(_ error: Error, readingID: String) async {
        guard let error = error as? OperationError else {
            session.status.refuse(String(describing: error))
            return
        }
        if case .lockedReading = error,
           let row = (try? await session.database.read({ try Queries.reading($0, id: readingID) })) ?? nil {
            session.status.refuse(BookStateCopy.refusal(
                for: error, name: row.name, sealed: row.sealedAt != nil))
            return
        }
        session.status.refuse(ReadingsViewModel.message(error))
    }
}

// MARK: - The renderer (ONE, both faces)

/// **The menu's items** — the table's groups, each door its registry act's
/// word, a divider between groups. Both faces render THIS (the Bookcase row
/// and every row beyond it), so the words, roles and order cannot drift. The
/// Bookcase hands in its shelf-placement doors (`placement`), which no other
/// surface has; elsewhere passes none.
struct BookRowMenuItems<Placement: View>: View {
    let face: BookMenuFace
    let readingID: String
    let facts: BookMenuFacts
    let doors: BookRowDoors
    var starDoor: StarDoor?
    var wings: WingsModel?
    /// Elsewhere: the row's own open road (the Bookcase row's click opens).
    var open: (() -> Void)?
    @ViewBuilder var placement: (BookRowDoor) -> Placement
    /// 13n-c U3: the window's road (nil in harness mounts — no share door).
    @Environment(\.mcpShareRoad) private var mcpShareRoad

    var body: some View {
        let groups = BookRowMenuTable.groups(facts, face: face)
        ForEach(Array(groups.enumerated()), id: \.offset) { index, group in
            if index > 0 { Divider() }
            ForEach(group, id: \.self) { door in
                item(door)
            }
        }
    }

    private func verb(_ act: CapabilityID) -> String { CapabilityRegistry.capability(act).verb }

    @ViewBuilder
    private func item(_ door: BookRowDoor) -> some View {
        let reading = facts.reading
        switch door {
        case .open:
            if let open { Button(BookRowMenuCopy.openVerb) { open() } }
        case .star:
            // 13f batch 6 (W4) → 13i-d U2 ACT 0: the row's ONE star door (the
            // union star — Starred and the shelf's float, one truth).
            if let starDoor {
                Button(starDoor.title(for: .reading(readingID))) {
                    starDoor.toggle(.reading(readingID))
                }
            }
        case .moveToShelf, .sendToTop, .sendToBottom:
            placement(door)
        case .moveToWing:
            // 13i-d U5b: the other wings from the book's OWN wing, Home first.
            if let wings, let reading {
                Menu(verb(.moveBookToWing)) {
                    ForEach(wings.destinations(from: reading.wingId)) { row in
                        Button(row.name) {
                            Task { await doors.askMove(reading, to: row.id, wings: wings) }
                        }
                    }
                }
            }
        case .rename:
            if let reading { Button(verb(.renameBook)) { doors.beginRename(reading) } }
        case .settings:
            // 13i-d U3 — the Collecting pane's door (§4).
            Button(CollectingCopy.openVerb(isBook: reading?.kind != .gathering)) {
                Task { await doors.openSettings(readingID) }
            }
        case .share:
            if let road = mcpShareRoad, let reading {
                Button(verb(.mcpShareHere)) {
                    // VX-189: the reading's OWN place — a gathering's row
                    // opens the sheet on the gathering.
                    road.open(MCPGrantOpening(place: .reading(reading), origin: .place))
                }
            }
        case .duplicate:
            if let reading {
                Button(DuplicateBookCopy.verb(owned: reading.owned)) { doors.openDuplicate(reading) }
            }
        case .editRule:
            Button(verb(.editRule)) { doors.openRuleEditor(readingID) }
        case .manageNotes:
            if let reading { Button(verb(.manageBookNotes)) { doors.openManage(reading) } }
        case .bind:
            if let reading { Button(verb(.bindIntoBook)) { Task { await doors.openBind(reading) } } }
        case .makeBook:
            if let reading {
                Button(verb(.makeBookFromGathering)) { Task { await doors.openSpawn(reading) } }
            }
        case .extent:
            if let reading { Button(verb(.setBookExtent)) { doors.openExtent(reading) } }
        case .useAsDailyJournal:
            Button(verb(.useAsDailyJournal)) {
                Task { await doors.designateDailyJournal(readingID) }
            }
        case .exportMarkdown:
            if let reading {
                Button(BookRowMenuCopy.exportMarkdownVerb) {
                    ReadingExport.export(session: doors.session, reading: reading, asPDF: false)
                }
            }
        case .exportPDF:
            if let reading {
                Button(BookRowMenuCopy.exportPDFVerb) {
                    ReadingExport.export(session: doors.session, reading: reading, asPDF: true)
                }
            }
        case .state(let act):
            if act == .deleteBook {
                // VX-611: the verb chosen by the kind (one capability).
                Button(BookStateCopy.deleteDoorLabel(reading?.kind ?? .book), role: .destructive) {
                    Task { await doors.open(.deleteBook, readingID: readingID) }
                }
            } else if act == .archiveBook, let reading {
                // An OWNED book's Archive asks (the delete confirm's twin).
                Button(BookStateCopy.archiveDoorLabel(asks: BookStateCopy.archiveAsks(reading))) {
                    Task { await doors.open(.archiveBook, readingID: readingID) }
                }
            } else {
                Button(verb(act)) {
                    Task { await doors.open(act, readingID: readingID) }
                }
            }
        }
    }
}

/// **The menu beyond the Bookcase** — the elsewhere face, its facts the
/// surface's brain's (the listed books' rows) and the window's.
struct BookRowMenu: View {
    /// P-1's walk: the registry acts this renderer draws — DERIVED from the
    /// Bookcase face (`BookRowMenuTable.capabilities(.elsewhere)`).
    static let contextMenuCapabilities: [CapabilityID] = BookRowMenuTable.capabilities(.elsewhere)

    let readingID: String
    let doors: BookRowDoors
    var starDoor: StarDoor?
    let open: () -> Void
    /// 13n-c U3: the window's road (nil in harness mounts — no share door).
    @Environment(\.mcpShareRoad) private var mcpShareRoad
    /// VX-829: the window's wings brain (nil in a harness mount — no Move to
    /// Wing ▸, P-2).
    @Environment(WingsModel.self) private var wings: WingsModel?

    var body: some View {
        let reading = doors.facts[readingID]
        BookRowMenuItems(
            face: .elsewhere, readingID: readingID,
            facts: BookMenuFacts(
                reading: reading,
                // VX-272 (an approved client exists) ∧ the book can take a grant.
                shareable: (mcpShareRoad?.canShare ?? false) && !doors.fencedBooks.contains(readingID),
                wingDestinations: reading.map { wings?.destinations(from: $0.wingId).count ?? 0 } ?? 0),
            doors: doors, starDoor: starDoor, wings: wings, open: open
        ) { _ in EmptyView() }
    }
}

// MARK: - The host

extension View {
    /// Hosts what a book row's menu presents — every row door's sheet (the
    /// settings sheet and the rule editor its Edit… hands back, opened once
    /// the sheet is gone; Rename; Manage Notes…; Length & Extent…; Duplicate
    /// Book…; the bind and spawn sheets; the book move's counting confirm) and
    /// — unless the surface already hosts them for the same doors — the state
    /// doors' confirms.
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
                doors.landed()
                if let next = doors.pendingRuleEditor {
                    doors.pendingRuleEditor = nil
                    doors.ruleEditor = next
                }
            }) { target in
                BookSettingsHost(target: target) { editor in doors.pendingRuleEditor = editor }
            }
            // 13i-b U3 walk finding F-U3-1: a saved rule changes what a
            // gathering shows, so a one-shot listing re-asks when it closes.
            .sheet(item: Bindable(doors).ruleEditor, onDismiss: { doors.landed() }) { editor in
                RuleEditorSheet(model: editor)
            }
            .bookRenameAlert(doors)
            .sheet(item: Bindable(doors).manageTarget, onDismiss: { doors.landed() }) { reading in
                ManageReadingPostsSheet(session: doors.session, model: doors.readings, reading: reading)
            }
            .sheet(item: Bindable(doors).extentTarget) { reading in
                BookExtentSheet(reading: reading) { target, cap in
                    await doors.saveExtents(reading.id, wordTarget: target, maxPosts: cap)
                }
            }
            // 13i-c U4 — DUPLICATE BOOK… (§6).
            .sheet(item: Bindable(doors).duplicateOffer, onDismiss: { doors.landed() }) { offer in
                DuplicateBookSheet(session: doors.session, offer: offer)
            }
            .sheet(item: Bindable(doors).bindOffer) { offer in
                BindIntoBookSheet(offer: offer) { ownedNotes in
                    Task { await doors.bind(offer.reading.id, ownedNotes: ownedNotes) }
                }
            }
            // 13i-c U3 — THE SPAWN SHEET.
            .sheet(item: Bindable(doors).spawnOffer) { offer in
                SpawnBookSheet(offer: offer) { name, outflow in
                    Task { await doors.spawn(from: offer.source.id, named: name, outflow: outflow) }
                }
            }
            // 13i-d U5b — the book move's counting confirm (R-13id-6).
            .wingBookMoveConfirm(Bindable(doors).bookMoveAsk, wings: doors.moveWings) {
                doors.landed()
            }
        if hostsStateConfirms {
            hosted.bookStateConfirms(doors.stateDoors) { _ in doors.landed() }
        } else {
            hosted
        }
    }
}

private extension View {
    /// Rename… — the board's shipped alert ("Rename Book", the name field, its
    /// Rename and Cancel), now every face's.
    func bookRenameAlert(_ doors: BookRowDoors) -> some View {
        alert(
            BookRowMenuCopy.renameAlertTitle,
            isPresented: Binding(
                get: { doors.renameTarget != nil },
                set: { if !$0 { doors.renameTarget = nil } }),
            presenting: doors.renameTarget
        ) { reading in
            TextField("Name", text: Bindable(doors).renameField)
            Button("Rename") {
                let name = doors.renameField
                Task { await doors.rename(reading.id, to: name) }
            }
            Button("Cancel", role: .cancel) {}
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
