//
//  ShelfViewModel.swift
//  Variorum
//
//  Phase 13, B2 — the shelf's model; REBUILT at 13i-d U1 as **THE
//  BOOKCASE'S** (the sitting record §7, §19–§24; mockup v5). Two cost tiers
//  by contract, unchanged in kind: the HELD half (one wing's shelves + books
//  with their cheap counts — `Queries.bookcase`, whose tracked region never
//  includes `container`, so typing never wakes it: pinned
//  `theHeldSnapshotsRegionIsBlindToAutosave`) and the ONE-SHOT half (word
//  counts, the tags column, rule paths, and — new — last-edited + each
//  gathering's shown count), refreshed on appearance and after the board's
//  own acts.
//
//  Everything the board DECIDES is `BookcaseBoard` (Shared, pure); the view
//  preferences are `BookcasePrefs` (local, injected defaults). This model
//  holds the projections, the view state, and the acts — and SPEAKS through
//  the one status seam (18i: refusals toast, receipts take the quiet slot),
//  which retires the old bottom-left overlay that drew over the ⌘K hint
//  (KnownIssues rows 103's Bookcase half and 108).
//

import Foundation
import GRDB // AsyncValueObservation iteration
import Observation
import VariorumCore

@MainActor
@Observable
final class ShelfViewModel {
    @ObservationIgnored let session: AppSession
    /// The wing this Bookcase shows — Home ('') until 13i-d U5's switcher
    /// (PROVISIONAL P-13id-U1-7: the board is one wing's surface, §9).
    let wingID: String
    @ObservationIgnored private let prefs: BookcasePrefs

    // MARK: The held snapshot

    private(set) var books: [Queries.ShelfBook] = []
    private(set) var shelves: [Shelf] = []

    // MARK: The one-shot aggregates

    private(set) var wordCounts: [String: Int] = [:]
    private(set) var bookTags: [String: [String]] = [:]
    var ruleTags: [String: [String]] = [:]
    /// DERIVED last-edited stamps (§22 — never a synced column).
    private(set) var lastEdited: [String: String] = [:]
    /// How many notes each gathering shows.
    private(set) var gatheringCounts: [String: Int] = [:]
    /// 13i-d U4 — HONEST COUNTS (her #169(a)(1)): each book's ARCHIVED
    /// members (one-shot — the read touches `container`, so it never rides
    /// the held snapshot; U1's P1 pin).
    private(set) var archivedCounts: [String: Int] = [:]

    // MARK: What the board said last (kept for the pins; also spoken)

    private(set) var lastError: String?
    /// R98: apply-and-report's REPORT half — not an error.
    private(set) var lastReport: String?

    // MARK: View state (local; the remembered ones write through)

    /// All, or one shelf solo'd. Opens on the DEFAULT shelf (§7), All when
    /// none is chosen (P-13id-U1-1).
    var scope: BookcaseScope
    /// The № census's active solo (one at a time; session-scoped — P-13id-U1-6).
    var solo: BookcaseSolo?
    var orderMode: BookcaseOrderMode { didSet { prefs.orderMode = orderMode } }
    var detailsShown: Bool { didSet { prefs.detailsShown = detailsShown } }
    var censusOpen: Bool { didSet { prefs.censusOpen = censusOpen } }

    /// **17y B-WALK W-3 — a masthead menu or popover opened: the № float
    /// goes** (her ruling: the float must never cover an open masthead menu —
    /// "unexcusable UI. not good at all"). Every masthead menu/popover door
    /// reports here (order ▾, the wing switcher ▾, the ⋯ shelf panel, a shelf
    /// name's right-click menu); № itself stays the float's own toggle. The
    /// close is the remembered one (the float stays closed until № opens it
    /// again — PROVISIONAL, #188). A closed float stays closed (no write).
    func mastheadDoorOpened() {
        if censusOpen { censusOpen = false }
        orderOpen = false
    }

    // MARK: The two droppers (librarywalkpolish VR-115 — one popover idiom)

    /// The order popover is open (a menu's life: never remembered).
    var orderOpen = false

    /// **№** — the census popover; opening it closes the order popover
    /// (opening either dismisses the other — R-LWP-1 amended).
    func toggleCensus() {
        censusOpen.toggle()
        if censusOpen { orderOpen = false }
    }

    /// **order ▾** — the order popover; opening it closes the census.
    func toggleOrder() {
        orderOpen.toggle()
        if orderOpen, censusOpen { censusOpen = false }
    }

    /// An order row picked: the order is hers, the popover closes.
    func pickOrder(_ mode: BookcaseOrderMode) {
        orderMode = mode
        orderOpen = false
    }

    // MARK: "My order" steps back for 0.9.2 (librarywalkpolish VR-118)

    /// **Her ruling R-LWP-4:** "let's just hide 'my order' from the user,
    /// hide the send to top and bottom options, and add it next week or
    /// something as a post release update". OFF for this release: the order
    /// popover offers a–z · last edited, and every hand-placing door (the
    /// grips, the row drops, Send to Top/Bottom — all `placesByHand`'s) is
    /// gone. The MACHINERY stays (`shelf_position`, `placeReading`, the
    /// placement arithmetic) for its return (VR-120) — which is this one
    /// value, and which the machinery's own pins turn on per model.
    nonisolated static let handPlacingOfferedThisRelease = false
    var handPlacingOffered = ShelfViewModel.handPlacingOfferedThisRelease

    /// **The order the board DRAWS.** A stored "my order" (a preference she
    /// set before this release) reads as A–Z while hand placing is not
    /// offered — and is NEVER rewritten, so the return finds it where she
    /// left it (PROVISIONAL, QUESTIONS #188).
    nonisolated static func effectiveOrder(
        _ stored: BookcaseOrderMode, handPlacingOffered: Bool
    ) -> BookcaseOrderMode {
        stored == .mine && !handPlacingOffered ? .alphabetical : stored
    }

    var effectiveOrderMode: BookcaseOrderMode {
        Self.effectiveOrder(orderMode, handPlacingOffered: handPlacingOffered)
    }

    /// The order popover's rows.
    var offeredOrderModes: [BookcaseOrderMode] {
        BookcaseOrderMode.allCases.filter { $0 != .mine || handPlacingOffered }
    }
    private(set) var collapsed: Set<String>
    private(set) var defaultShelfID: String?

    /// 13i-c U3: the book's STATE doors — the shared brain the settings
    /// sheet also holds one of; the board presents its confirms.
    @ObservationIgnored let stateDoors: BookStateDoors
    /// 13i-c U4 (§4 row 17): the row drop's ownership CHOICE.
    @ObservationIgnored let membershipDoors: MembershipDoors

    init(session: AppSession, wingID: String = "", defaults: UserDefaults = .standard) {
        self.session = session
        self.wingID = wingID
        let prefs = BookcasePrefs(defaults: defaults, wingID: wingID)
        self.prefs = prefs
        self.orderMode = prefs.orderMode
        self.detailsShown = prefs.detailsShown
        self.censusOpen = prefs.censusOpen
        self.collapsed = prefs.collapsed
        self.defaultShelfID = prefs.defaultShelfID
        self.scope = prefs.defaultShelfID.map(BookcaseScope.shelf) ?? .all
        self.stateDoors = BookStateDoors(session: session)
        self.membershipDoors = MembershipDoors(session: session)
    }

    /// The observed snapshot (Equatable for the observe seam; crosses off
    /// the main actor inside the observation).
    nonisolated struct ShelfSnapshot: Equatable, Sendable {
        var bookcase: Queries.BookcaseSnapshot
    }

    /// The held half: one wing's shelves + books (author-scale).
    func start() async {
        let wing = wingID
        do {
            for try await value in session.database.observe({ db in
                ShelfSnapshot(bookcase: try Queries.bookcase(db, wingID: wing))
            }) {
                books = value.bookcase.books
                shelves = value.bookcase.shelves
            }
        } catch is CancellationError {
        } catch {
            lastError = String(describing: error)
        }
    }

    /// The one-shot half (on appearance and after the board's own acts — a
    /// deliberate fetch, never a held observation). Said honestly (ladder A
    /// round 1, MINOR 2's re-word): `bookWordCounts`, `shelfBookTags` and
    /// `ruleTagPaths` are STORE-WIDE one-shots (the 13 B2 shapes, keyed per
    /// reading and consulted per wing row); `bookcaseAggregates` is the
    /// wing's own. All one-shot — none rides the held snapshot.
    func refreshAggregates() async {
        let wing = wingID
        do {
            let (words, tags, rules, aggregates) = try await session.database.read { db in
                (try Queries.bookWordCounts(db), try Queries.shelfBookTags(db),
                 try Queries.ruleTagPaths(db), try Queries.bookcaseAggregates(db, wingID: wing))
            }
            wordCounts = words
            bookTags = tags
            ruleTags = rules
            lastEdited = aggregates.lastEdited
            gatheringCounts = aggregates.gatheringCounts
            archivedCounts = aggregates.archivedCounts
        } catch {
            lastError = String(describing: error)
        }
    }

    // MARK: - What the board draws (BookcaseBoard's answers)

    /// The scope as drawable (a dead solo'd shelf reads as All).
    var effectiveScope: BookcaseScope {
        BookcaseBoard.effectiveScope(scope, shelves: shelves)
    }

    var sections: [BookcaseBoard.Section] {
        BookcaseBoard.sections(
            books: books, shelves: shelves, scope: scope, solo: solo,
            mode: effectiveOrderMode, lastEdited: lastEdited)
    }

    /// The № census over what is in scope (a count never promises books a
    /// solo could not show — P-13id-U1-6).
    var census: [BookcaseSolo: Int] {
        BookcaseBoard.census(BookcaseBoard.booksInScope(books, shelves: shelves, scope: scope))
    }

    /// The strip's hover counts, keyed by shelf id.
    var shelfCounts: [String: Int] { BookcaseBoard.shelfCounts(books, shelves: shelves) }

    /// Where + New Book lands (§19.1/§24 — the solo'd shelf, else unshelved).
    var mintShelfID: String? { BookcaseBoard.mintShelf(for: scope, shelves: shelves) }

    /// Whether the rows are placed by hand HERE (17y (s): never on the
    /// starred shelf — a filter, whose rows live on other shelves).
    var placesByHand: Bool { BookcaseBoard.placesByHand(effectiveOrderMode, in: effectiveScope) }

    /// Each book's resolved shelf key (`BookcaseBoard.unshelvedKey` for none).
    func shelfKey(of readingID: String) -> String? {
        BookcaseBoard.resolvedShelves(books, shelves: shelves)[readingID]
    }

    func isCollapsed(_ sectionID: String) -> Bool { collapsed.contains(sectionID) }

    func toggleCollapsed(_ sectionID: String) {
        if collapsed.contains(sectionID) { collapsed.remove(sectionID) } else { collapsed.insert(sectionID) }
        prefs.collapsed = collapsed
    }

    /// The census row's click: solo it, or clear it if it is the active one.
    func toggleSolo(_ solo: BookcaseSolo) {
        self.solo = self.solo == solo ? nil : solo
    }

    /// The tags column's content for one book: a gathering shows its own
    /// rule tags (the rule IS its identity); a book shows its members'
    /// most-applied paths (the core aggregate).
    func tagsColumn(for book: Queries.ShelfBook) -> [String] {
        ShelfOrder.smartQueryTagPaths(of: book.reading, rulePaths: ruleTags)
            ?? bookTags[book.reading.id] ?? []
    }

    /// Bounded progress for the meta column ("62% of 10,000w").
    func progress(for book: Queries.ShelfBook) -> (percent: Int, target: Int)? {
        guard let target = book.reading.wordTarget, target > 0 else { return nil }
        let words = wordCounts[book.reading.id] ?? 0
        return (Int((Double(words) / Double(target) * 100).rounded()), target)
    }

    // MARK: - Shelf acts (the strip's doors)

    @discardableResult
    func createShelf(named name: String) async -> String? {
        let wing = wingID
        do {
            let shelf = try await session.runner.run { ops in
                try ops.createShelf(name: name, wingID: wing)
            }
            receipt("Made the shelf \u{201C}\(shelf.name)\u{201D}.")
            return shelf.id
        } catch {
            refuse(error)
            return nil
        }
    }

    func renameShelf(_ id: String, to name: String) async {
        await run { try $0.renameShelf(id, to: name) }
    }

    func setGlyph(_ id: String, glyph: String?) async {
        await run { try $0.setShelfGlyph(id, glyph: glyph) }
    }

    /// Deleting a shelf returns its books to UNSHELVED and never touches a
    /// book (§19). The receipt says the one consequence.
    func deleteShelf(_ id: String) async {
        let name = shelves.first { $0.id == id }?.name ?? "shelf"
        let count = shelfCounts[id] ?? 0
        do {
            try await session.runner.run { try $0.deleteShelf(id) }
            if case .shelf(id) = scope { scope = .all }
            if defaultShelfID == id { makeDefault(nil) }
            receipt(BookcaseCopy.deletedShelf(name, books: count))
        } catch {
            refuse(error)
        }
    }

    func moveShelf(_ id: String, to insert: Operations.InsertPosition) async {
        await run { try $0.moveShelf(id, to: insert) }
    }

    /// Make Default — the shelf the Bookcase opens on (nil = All). LOCAL
    /// (P-13id-U1-1).
    func makeDefault(_ shelfID: String?) {
        defaultShelfID = shelfID
        prefs.defaultShelfID = shelfID
    }

    // MARK: - Book placement acts

    /// Re-shelve (a drop onto a shelf's name or header, or Move to Shelf ▸).
    /// nil = unshelved. Lands never-placed (the end of "my order" there).
    func reshelve(_ readingID: String, to shelfID: String?) async {
        guard shelfKey(of: readingID) != (shelfID ?? BookcaseBoard.unshelvedKey) else { return }
        let bookName = books.first { $0.reading.id == readingID }?.reading.name ?? "book"
        let shelfName = shelfID.flatMap { id in shelves.first { $0.id == id }?.name }
        do {
            try await session.runner.run { try $0.setReadingShelf(readingID, shelf: shelfID) }
            receipt(BookcaseCopy.reshelved(bookName, onto: shelfName))
        } catch {
            refuse(error)
        }
    }

    /// **A book dropped on the strip's "starred" row STARS it** (17y item
    /// (s), R-17y-9 — the strip's drop grammar; its menu twin is the row's
    /// own Star/Unstar). One-way: an already-starred book is a quiet
    /// nothing (the drop asked for what is already true). The write is the
    /// union star's one road (`setStarred(.reading)` — both stores, the cap
    /// counted over the union), and the cap's refusal speaks exactly as at
    /// every star door (`OpsRefusalCopy` — `StarsModel.toggle`'s words).
    /// Silent on success, like every star door: the ★ and the starred
    /// shelf's row are the answer (PROVISIONAL P-17y-B3-s5).
    func starBook(_ readingID: String) async {
        guard let book = books.first(where: { $0.reading.id == readingID }),
              !book.starred
        else { return }
        do {
            try await session.runner.run { ops in
                try ops.setStarred(.reading(readingID), starred: true)
            }
            lastError = nil
        } catch {
            refuse(error)
        }
    }

    /// Send to Top / Send to Bottom (my order's own doors, §20).
    func place(_ readingID: String, at placement: BookcaseOrdering.Placement) async {
        await run { try $0.placeReading(readingID, at: placement) }
    }

    /// A BOOK dropped onto a book row in "my order": land immediately before
    /// it — re-shelving first when the row sits on another shelf (one
    /// runner turn, two operations; the drag is the gesture).
    func dropBook(_ readingID: String, before targetID: String) async {
        guard readingID != targetID, let targetKey = shelfKey(of: targetID) else { return }
        let destination: String? = targetKey == BookcaseBoard.unshelvedKey ? nil : targetKey
        let moving = shelfKey(of: readingID) != targetKey
        do {
            try await session.runner.run { ops in
                if moving { try ops.setReadingShelf(readingID, shelf: destination) }
                try ops.placeReading(readingID, at: .before(targetID))
            }
            lastError = nil
        } catch {
            refuse(error)
        }
    }

    // MARK: - The book doors carried over (13i-b/13i-c)

    // (13i-d U2 ACT 0: `setPinned` RETIRED with the Mac's "Pin to Shelf Top"
    // door — the row's ★ door is the one star, `StarsModel.toggle`.)

    func setWordTarget(_ readingID: String, target: Int?) async {
        await run { try $0.setReadingWordTarget(readingID, wordTarget: target) }
        await refreshAggregates()
    }

    func setMaxPosts(_ readingID: String, maxPosts: Int?) async {
        await run { try $0.setReadingMaxPosts(readingID, maxPosts: maxPosts) }
    }

    /// The re-designation door (round 2, MAJOR 2): point Today's Entry at
    /// a new daily journal book.
    func designateDailyJournal(_ readingID: String) async {
        await run { try $0.setDailyJournalBook(readingID) }
    }

    /// **BIND INTO A BOOK** (13i-b U3 — the sitting record §3, §14.6). The
    /// SAME row becomes the book (§19.6) and it keeps collecting. Reports
    /// what happened rather than going quiet: binding changes what a row IS.
    func bind(
        _ readingID: String, ownedNotes: Operations.BindOwnedNotes = .leaveOut
    ) async {
        do {
            let result = try await session.runner.run { ops in
                try ops.convertSmartReadingToCurated(readingID, ownedNotes: ownedNotes)
            }
            // 13i-c U3: the receipt names the owned-notes limb's outcome.
            receipt(BindCopy.bound(
                result.reading.name, count: result.membershipIDs.count,
                copied: result.copied.count, leftOut: result.leftOut.count,
                hearsActs: BindCopy.hearsActs(result.reading)))
        } catch let error as OperationError {
            refuse(bookRefusal(error, readingID: readingID))
        } catch {
            refuse(String(describing: error))
        }
        await refreshAggregates()
    }

    /// **The spawn's PREFILL** (13i-c — R-13ic-1 and her item (i)): the
    /// rule's POSITIVE tags, each a LIVE tag of the gathering's wing.
    nonisolated static func spawnPrefill(_ db: Database, gathering: Reading) throws -> [String] {
        try RuleGrammar.positiveTagIDs(of: RuleGrammar.decode(gathering.querySpec))
            .filter { try Queries.tagIsLive(db, id: $0, wingID: gathering.wingId) }
    }

    /// **MAKE A BOOK FROM THIS GATHERING** (13i-b U3 — the spawn): a SIBLING
    /// book carrying the gathering's rule, in its wing, intake on;
    /// `createReading`'s creation-time backfill seats the current matches.
    /// `outflow` is the spawn sheet's CHOSEN set; nil = the prefill. The
    /// sibling lands where every non-context mint lands — unshelved (§19).
    @discardableResult
    func spawnBook(
        from gatheringID: String, named name: String, outflow chosen: [String]? = nil
    ) async -> String? {
        let database = session.database
        do {
            let (book, seated, ruleState) = try await session.runner.run {
                ops -> (Reading, Int, RuleGrammar.ReadResult) in
                guard let gathering = try database.read({
                    try Queries.reading($0, id: gatheringID)
                }) else { throw OperationError.readingNotFound(id: gatheringID) }
                guard gathering.kind == .gathering else {
                    throw OperationError.wrongReadingKind(id: gatheringID, expected: .gathering)
                }
                try ops.assertBookNameIsFree(name)
                let ruleState = RuleGrammar.read(gathering.querySpec)
                let outflow = try database.read { db in
                    try chosen.map { ids in
                        try ids.filter { try Queries.tagIsLive(db, id: $0, wingID: gathering.wingId) }
                    } ?? Self.spawnPrefill(db, gathering: gathering)
                }
                let book = try ops.createReading(
                    name: name, kind: .book,
                    querySpec: gathering.querySpec, wingId: gathering.wingId,
                    autoTagIDs: outflow)
                let seated = try database.read {
                    try Queries.assembleReading($0, readingID: book.id).count
                }
                return (book, seated, ruleState)
            }
            receipt(BindCopy.spawned(book.name, count: seated, rule: ruleState))
            await refreshAggregates()
            return book.id
        } catch let error as OperationError {
            refuse(ReadingsViewModel.message(error))
        } catch {
            refuse(String(describing: error))
        }
        return nil
    }

    /// Drag a NOTE onto a book row (sitting 1). Tolerant of the already-in
    /// case — a drop is a gesture, not a form. R98: a GATHERING accepts the
    /// drop BY TAGGING (apply-and-report).
    func addPost(_ postID: String, to readingID: String) async {
        do {
            let kind = books.first { $0.reading.id == readingID }?.reading.kind
            if kind == .gathering {
                let result = try await session.runner.run { ops in
                    try ops.collectPostIntoSmartReading(postID, into: readingID)
                }
                receipt(result.alreadyMatched
                    ? BookcaseCopy.alreadyShowing
                    : BookcaseCopy.shownByTagging(result.appliedTagPaths))
            } else {
                // 13i-c U4 (§4 row 17): the one membership road — an
                // ownership refusal OPENS the choice sheet (P-2).
                try await membershipDoors.addOrOffer(postID, to: readingID)
                lastError = nil
            }
        } catch let error as OperationError {
            if case .alreadyInReading = error { return }
            if case .smartFilterUnsatisfiable(_, let reason) = error {
                refuse("That book can't take this note: \(reason)")
            } else {
                refuse(bookRefusal(error, readingID: readingID))
            }
        } catch {
            refuse(String(describing: error))
        }
        await refreshAggregates()
    }

    // MARK: - Speaking (the one status seam — 18i)

    /// A refusal: always the toast (18i), and kept for the pins.
    func refuse(_ text: String) {
        lastReport = nil
        lastError = text
        session.status.refuse(text)
    }

    private func refuse(_ error: Error) {
        refuse(OpsRefusalCopy.message(for: error))
    }

    /// **A refusal about ONE book on the board** (13i-d U6 — KnownIssues row
    /// 106): the board holds the row, so a finished book names Reopen and a
    /// SEALED one Unseal (Reopen refuses there, R-13ic-3) — the book's own
    /// words through `BookStateCopy.refusal`. Every other refusal keeps the
    /// shelf's shipped words.
    func bookRefusal(_ error: OperationError, readingID: String) -> String {
        if case .lockedReading = error,
           let row = books.first(where: { $0.reading.id == readingID }) {
            return BookStateCopy.refusal(
                for: error, name: row.reading.name, sealed: row.reading.sealedAt != nil)
        }
        return ReadingsViewModel.message(error)
    }

    /// A receipt: the quiet slot under her default (18i), the toast under
    /// `.toast`, nothing under `.off`.
    func receipt(_ text: String) {
        lastError = nil
        lastReport = text
        session.status.receipt(text)
    }

    private func run(_ body: @escaping @Sendable (Operations) throws -> Void) async {
        do {
            try await session.runner.run(body)
            lastError = nil
        } catch let error as OperationError {
            switch error {
            // The shelf family's words live in the shared refusal table.
            case .shelfNotFound, .invalidShelfName, .invalidShelfGlyph, .wingNotFound,
                 .placementAnchorNotOnShelf:
                refuse(OpsRefusalCopy.message(for: error))
            default:
                refuse(ReadingsViewModel.message(error))
            }
        } catch {
            refuse(String(describing: error))
        }
    }
}

/// The board's own words (the receipts it speaks; 13s may re-voice).
nonisolated enum BookcaseCopy {
    // 13i-d U6 (a) — the vocabulary sweep's words on the board ("smart"
    // retired app-wide — the sitting record §1, §14).

    /// The New Book prompt's message — the three kinds it mints, in lesson
    /// 1's terms (§25): a book HOLDS, a gathering SHOWS and holds nothing.
    static let newBookMessage =
        "A book holds the notes you put in it, in your order; a gathering shows every "
        + "note its rule matches and holds none of them; a journal book holds dated entries."

    /// A note dropped on a GATHERING's row (R98 — adding IS tagging): the
    /// receipts say what the act did — it tagged — and why the gathering now
    /// shows the note. Never "collected"/"added" (a gathering holds nothing).
    static let alreadyShowing = "Already showing \u{2014} it matches this gathering's rule."
    static func shownByTagging(_ paths: [String]) -> String {
        "Tagged " + paths.map { "#\($0)" }.joined(separator: " ")
            + " \u{2014} the gathering shows it now, as its rule matches."
    }

    // The registry's verbs (13i-d U1).
    static let newShelfVerb = "New Shelf"
    static let renameShelfVerb = "Rename\u{2026}"
    static let setGlyphVerb = "Set Glyph\u{2026}"
    static let makeDefaultVerb = "Make Default"
    /// `.makeDefaultShelf`'s other direction, on the shelf that IS the
    /// default (the `toggleStar` Star/Unstar shape — one act, two words).
    static let openOnAllVerb = "Open on All Instead"
    static let moveToStartVerb = "Move to Start"
    static let moveToEndVerb = "Move to End"
    static let deleteShelfVerb = "Delete Shelf\u{2026}"
    static let moveToShelfVerb = "Move to Shelf"
    static let sendToTopVerb = "Send to Top"
    static let sendToBottomVerb = "Send to Bottom"
    static let unshelvedName = "Unshelved"
    /// 17y (s) — the starred shelf's word (R-17y-9: lowercase, the strip's
    /// idiom — PROVISIONAL P-17y-B3-s2) and its hover (no count, no
    /// sentence INLINE — her second addendum: the row is the bare word).
    static let starredShelfName = "starred"
    static let starredShelfHelp =
        "Every starred book, wherever it\u{2019}s shelved \u{2014} drop a book here to star it"
    /// The one-liner, drawn ONLY in the solo'd board when nothing is starred
    /// (her addendum: "only give it the one liner when you click on it").
    static let starredShelfEmpty =
        "No starred books \u{2014} star one from its menu, or drop it on \u{201C}starred\u{201D}."
    static let unavailableNote = "Open the Bookcase to arrange shelves and books."
    static let placingUnavailableNote =
        "Switch the Bookcase's order to \u{201C}my order\u{201D} to place books by hand."
    /// 17y B2 (b) — my order's row grip (the app's one handle glyph, ⠿ —
    /// the Lenses rows', the book view's chapter headers', the Book Panel's).
    static let gripGlyph = "\u{283F}"
    /// The grip column's width — inside the row, pulled into the board's
    /// 28-pt gutter so the name column never moves between orders.
    static let gripColumn: CGFloat = 16
    /// Promises only what §20 delivers (the B2 ladder's NIT-6): a drop lands
    /// right above its row EXCEPT across the starred line — starred books
    /// always float first, so a book dropped across it settles in its own
    /// half (QUESTIONS #184(h)). Wording PROVISIONAL (13s re-voices).
    static let gripHelp =
        "Drag to place this book by hand, on any shelf. Dropped on a book, it lands right above "
        + "it \u{2014} except across the starred line: starred books always stay first."

    /// The shelf delete's confirm (P-13id-U1-4 — the one net for cheap
    /// metadata with no Trash and no undo).
    static func deleteShelfTitle(_ name: String) -> String {
        "Delete the shelf \u{201C}\(name)\u{201D}?"
    }

    static func deleteShelfMessage(books: Int) -> String {
        books == 0
            ? "It holds no books. No book is ever touched by deleting a shelf."
            : "Its \(books) \(books == 1 ? "book returns" : "books return") to Unshelved "
                + "— no book is touched."
    }

    static func deletedShelf(_ name: String, books: Int) -> String {
        books == 0
            ? "Deleted the shelf \u{201C}\(name)\u{201D}."
            : "Deleted the shelf \u{201C}\(name)\u{201D} — its \(books) "
                + "\(books == 1 ? "book is" : "books are") unshelved now."
    }

    static func reshelved(_ book: String, onto shelf: String?) -> String {
        if let shelf { return "Moved \u{201C}\(book)\u{201D} to \(shelf)." }
        return "\u{201C}\(book)\u{201D} is unshelved now."
    }
}
