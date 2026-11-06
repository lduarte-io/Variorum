//
//  BookArrivals.swift
//  Variorum
//
//  13i-b U2 — THE ARRIVALS FACE (the 13i-b plan §3; the sitting record §4).
//
//  Her clutter mandate is this file's law: *"it's important to me that the UI
//  of a book not start to feel excessively cluttered."* So the face is:
//
//  · INVISIBLE when nothing waits — the common case draws nothing at all, not
//    an empty line, not a hairline;
//  · ONE muted line atop the book's Index and Book surfaces when something
//    does — "2 at the door";
//  · expanding INLINE, on her click, to the waiting rows (which note, when it
//    arrived) with the two judgment doors per row: **Add** (`seatArrival` —
//    the note lands at the END, unsectioned) and **Dismiss**
//    (`dismissArrival`). Never a persistent panel. The copy-in arm is
//    13i-c's and is neither built nor hinted here.
//
//  13i-c U4 — THE OWNERSHIP ARMS (the 13i-c plan §4 row 19; the sitting record
//  §4 "copy in / dismiss" and "claim-move / copy in / leave", §18.4). Which
//  doors a waiting row draws is DATA, decided per row by the one ownership
//  table (`ArrivalArms` over `OwnershipDecision`): a note membered elsewhere
//  at an OWNED book's door draws **Copy In · Move In · Dismiss** (no Add — a
//  plain seat would break the book's promise); a note another book OWNS at a
//  PLAIN book's door draws **Copy In · Dismiss**; everything else keeps
//  **Add · Dismiss**. The row says why in one quiet line — "owned by “X”"
//  (§18.4's competing-owned-books face, "claimed by" in the record's words) or
//  "also in “X”". The facts are ONE page-driven read over the listed rows
//  (`Queries.ownershipFacts`), never the corpus.
//
//  Three pieces, split by concern (P-9): the WORDS (`ArrivalsCopy` — pure,
//  pinned), the MODEL (`BookArrivalsModel` — the observed door and the two
//  acts, speaking on the one status seam), and the FACE
//  (`BookArrivalsDoor` + `BookArrivalsList` since 17y (h) — the door renders
//  the count, its popover the rows; the list the four acts' one renderer and
//  so their `.surface` declaration's home).
//
//  17y B3 item (h) — THE DOOR MOVES TO THE MODE ROW, AND THE ONE WORD WINS
//  (R-17y-1 / R-17y-2, her pre-answered rulings; her walk: "I also have no
//  idea where arrivals are… I don't see it anywhere" and "I don't like it
//  being there"). The "N at the door" line LEAVES the top of the book's
//  content: the door is now a small ICON in the book's masthead beside the
//  settings gear (`BookArrivalsDoor`) — CALM when nothing waits (a faint
//  icon, no count), PRESENCE when something does (the accent, the count) —
//  and its popover is the rows' home (`BookArrivalsList`, the old line's
//  expansion). A waiting row's NAME OPENS the note, read-normal (the
//  ordinary note-open broadcast); opening never seats — only Add does. The
//  one word is "Arrivals" — the dial's own ("wait at Arrivals"), now the
//  door's, the popover's, the refusals' and the finish confirm's.
//
//  §23 (her overrule — "details off hides arrivals too"): the details toggle
//  is 13i-d's and does not exist yet. Nothing here fights it — whether the
//  line shows is ONE value (`ArrivalsLineFace.isShown`), so the toggle
//  composes at that one place when it lands.
//
//  VX-821 (the VX-808 run, Unit B3) — THE REVIEW AREA, ONE HOME (R-808-5, her
//  pick "Full book area, one home"; her bar: "the UX should be clear,
//  spacious, not cluttered, buttons should be a good size … i think the
//  seating area probably needs more space"). THE POPOVER RETIRES: the
//  masthead door (calm/presence unchanged) now OPENS the review area in the
//  book's content area (`BookArrivalsReview` — drawn OVER the mode's body,
//  the book search answer's precedent, so Done returns the mode exactly as
//  she left it). The rows (`BookArrivalsList`) carry the popover's semantics
//  whole — the ownership arms (`ArrivalArms`), the never-seats open, the
//  archived mark, the owned-by / also-in line — and gain the pick (click,
//  ⇧/⌘, ⌘A), the walked row, WHY each waits and since when. The bulk doors
//  (Add all · Dismiss all · Add N · Dismiss N) are per-row acts with one
//  message per press (A-808-11 — `BookArrivalsModel+Bulk.swift`).
//

import GRDB // AsyncValueObservation iteration
import SwiftUI
import VariorumCore

// MARK: - The words

/// Every sentence the door says, in one home — the line, the rows, the two
/// receipts and the refusals (the `SplitAtNewlinesCopy` reason: a receipt
/// worded at two sites is how copy drifts). Wording PROVISIONAL —
/// 13s re-voices the app; this is the plan §3's "N at the door", quiet.
nonisolated enum ArrivalsCopy {
    /// The judgment doors' verbs (the registry's `verb`; the face renders
    /// them through `chromeLabel`, so the Terminal voice lowercases them).
    static let addVerb = "Add"
    static let dismissVerb = "Dismiss"

    /// **THE ONE WORD** (17y B3 item (h) — R-17y-2, her pick): the dial's
    /// "wait at Arrivals", the door, the popover, the refusals and the
    /// finish confirm all say it. 13s may re-voice sentences; the WORD is
    /// settled.
    static let word = "Arrivals"

    /// What the door draws beside its icon: the count when something waits
    /// (PRESENCE), nothing when nothing does (CALM — her "calm when nothing
    /// is there and has presence when something is there").
    static func doorCount(_ count: Int) -> String? { count > 0 ? "\(count)" : nil }

    /// The door's hover (wording PROVISIONAL — VX-821 re-cut it for the
    /// review area and the proposals that wait there too).
    static func doorHelp(count: Int) -> String {
        count == 0
            ? "\(word) \u{2014} nothing waiting"
            : "\(word) \u{2014} \(count) waiting: notes this book\u{2019}s rule brought in, or an AI "
                + "proposed. Open \(word) to add them to the book or dismiss them."
    }

    /// **The head line** — the review area's header and the door's spoken
    /// name, ONE home (VX-821, her picked preview: "Arrivals — N waiting").
    static func header(count: Int) -> String {
        count == 0 ? word : "\(word) \u{2014} \(count) waiting"
    }

    /// A waiting row's NAME is a door to the note itself (17y (h), her
    /// "you should be able to click on the note to see what it is").
    static let openHelp = "Open this note to read it \u{2014} opening never adds it to the book"

    static let addHelp = "Add this note to the book — it lands at the end"
    static let dismissHelp = "Dismiss — don't add this note to the book"

    // (VX-821: `arrived` / `arrivedHelp` — the popover row's "arrived …"
    // stamp — RETIRED with the popover. The review's rows say since when they
    // WAIT (`ArrivalsReviewCopy.since` — a demotion's own moment, never the
    // original filing's), and the popover's empty sentence moved there too.)

    /// The expansion's tail when more wait than the window lists — the count
    /// is the door's whole answer, so the listing never pretends to be all.
    static func more(_ hidden: Int) -> String { "and \(hidden) more waiting" }

    // MARK: Receipts (it landed — her receipt setting governs where they show)

    /// Add landed. Says WHERE, because "at the end" is the ruled placement
    /// (§4) — and in a chaptered book the end is outside every chapter (the
    /// unsectioned bin renders last).
    static func added(_ title: String, chaptered: Bool, archived: Bool = false) -> String {
        // 13i-d U4 (#169(a)(2)): an ARCHIVED waiter seats as an archived
        // member — the Index never shows it, so the receipt says where it is.
        if archived {
            return "\u{201C}\(title)\u{201D} added to the book \u{2014} it\u{2019}s archived, "
                + "so it waits in the book\u{2019}s archived line."
        }
        // 17y item (i) — R-17y-4: the chapterless state's ONE word, the
        // headers' own ("unfiled"), in the receipt too.
        return chaptered
            ? "\u{201C}\(title)\u{201D} added at the end of the book, "
                + "\(BookPanelCopy.unfiled)."
            : "\u{201C}\(title)\u{201D} added at the end of the book."
    }

    /// 13i-d U4 (#169(a)(2) — P-13ib-U2-2 reversed): the quiet mark an
    /// ARCHIVED waiter's row wears. Its doors are the same.
    static let archivedMark = "archived"
    static let archivedMarkHelp =
        "This note is archived \u{2014} add it and it joins the book still archived, kept "
        + "in the book\u{2019}s archived line rather than its Index"

    /// Dismiss landed — and it TEACHES the road back (13i-d U6 (f), the plan's
    /// item 10, her question "can you simply add the note to that book
    /// directly if you regret saying no?"): a dismissal decides INTAKE only,
    /// so the book never adds it again by itself, while every hand door (the
    /// chip's Add, a drag, Manage Notes) still can — they check live rows
    /// alone. The ruled sentence, verbatim (the app's typographic apostrophe).
    static func dismissed(_ title: String) -> String {
        "Dismissed \u{201C}\(title)\u{201D} \u{2014} it won\u{2019}t come back on its own; "
            + "add it by hand any time."
    }

    // MARK: The ownership arms (13i-c U4 — §4 row 19)

    static let copyInHelp =
        "Copy this note in \u{2014} a linked copy joins the book at the end; the original stays "
        + "where it lives"
    static let moveInHelp =
        "Move this note in \u{2014} it leaves its other books and lives only here, at the end"

    /// The row's one quiet line: who OWNS it (§18.4 — "claimed by [Book]" in
    /// the record's words; "owned by" at the face), or where else it lives.
    static func ownedBy(_ book: String) -> String { "owned by \u{201C}\(book)\u{201D}" }
    static func alsoIn(_ books: [String]) -> String {
        "also in " + MembershipChoiceCopy.list(books)
    }

    /// Copy In landed (at the END — the arrival's own placement, §4).
    static func copiedIn(_ title: String) -> String {
        "Copied \u{201C}\(title)\u{201D} in at the end of the book \u{2014} a linked copy; the "
            + "original stays where it was."
    }

    /// Move In landed — it names the books the note LEFT.
    static func movedIn(_ title: String, left: [String]) -> String {
        left.isEmpty
            ? "Moved \u{201C}\(title)\u{201D} in at the end of the book."
            : "Moved \u{201C}\(title)\u{201D} in at the end of the book \u{2014} it left "
                + MembershipChoiceCopy.list(left) + "."
    }

    // MARK: Refusals (nothing happened — always shown, P-2)

    /// The operations layer's REAL refusal, in words that name the road.
    /// `book` is the book's name; `cap` its note cap when it has one;
    /// `sealed` (13i-d U6 — KnownIssues row 106) whether it is SEALED, whose
    /// road out is Unseal — Reopen refuses there (`readingSealed`, R-13ic-3).
    static func refusal(
        for error: Error, book: String?, cap: Int?, sealed: Bool = false
    ) -> String {
        let name = book.map { "\u{201C}\($0)\u{201D}" } ?? "This book"
        guard let op = error as? OperationError else {
            return OpsRefusalCopy.message(for: error)
        }
        switch op {
        case .readingAtCapacity:
            let full = cap.map { "\(name) is full \u{2014} its cap is \($0) notes." }
                ?? "\(name) is at its note cap."
            return full + " Raise the note cap in the book\u{2019}s settings (the gear), "
                + "then add it."
        case .lockedReading:
            return sealed
                ? "\(name) is sealed \u{2014} the book is done, so nothing new joins. Unseal it "
                    + "in the book\u{2019}s settings (that reopens it too) to add notes."
                : "\(name) is finished \u{2014} its table of contents is done, so nothing "
                    + "new joins. Reopen it in the book\u{2019}s settings to add notes."
        case .arrivalNotFound:
            return "That note isn\u{2019}t waiting at \(word) any more \u{2014} "
                + "it was already judged."
        case .containerNotFound:
            return "That note is gone \u{2014} it was deleted, so there\u{2019}s nothing to add."
        case .readingNotFound:
            return "This book is gone \u{2014} it was deleted."
        case .wrongReadingKind:
            return "Only a book has a door \u{2014} a gathering shows its matches "
                + "without holding them."
        default:
            return OpsRefusalCopy.message(for: error)
        }
    }

    /// The registry's honest note for a dispatch nothing renders.
    static let unavailableNote =
        "\(word) wait behind the tray icon beside a book\u{2019}s settings gear \u{2014} "
        + "open the book to judge them."
}

// MARK: - Whether the line shows (one value — §23's composition point)

nonisolated enum ArrivalsLineFace {
    /// The line exists only when something waits. ONE place, so 13i-d's
    /// details toggle (§23 — "details off hides arrivals too") composes here
    /// rather than at each host.
    static func isShown(_ door: Queries.BookArrivals) -> Bool { door.count > 0 }

    /// How many waiting notes the expansion does NOT list.
    static func hidden(_ door: Queries.BookArrivals) -> Int {
        max(0, door.count - door.rows.count)
    }
}

// MARK: - Which doors a waiting row draws (data — 13i-c U4, §4 row 19)

/// **The judgment arms of ONE waiting row**, decided by the one ownership
/// table (`OwnershipDecision` — the same verdict `seatArrival` consults, so a
/// row never offers Add where the seat would refuse). Pure, so pins read it.
nonisolated struct ArrivalArms: Equatable, Sendable {
    /// The acts the row draws, in order (each a declared `.surface` act).
    let acts: [CapabilityID]
    /// The row's one quiet line, or nil for an ordinary note.
    let line: String?

    static func of(bookOwned: Bool, facts: Queries.OwnershipFacts?) -> ArrivalArms {
        of(bookOwned: bookOwned, ownedBy: facts?.ownedBy, otherBooks: facts?.otherBooks ?? [])
    }

    /// The table over the facts themselves (the note's owner, if any, and
    /// the OTHER books it is a member of).
    static func of(
        bookOwned: Bool, ownedBy: Queries.BookRef?, otherBooks: [Queries.BookRef]
    ) -> ArrivalArms {
        let note = OwnershipDecision.NoteFacts(
            memberedElsewhere: !otherBooks.isEmpty, ownedElsewhere: ownedBy != nil)
        let line: String? = if let ownedBy {
            ArrivalsCopy.ownedBy(ownedBy.name)
        } else if !otherBooks.isEmpty, bookOwned {
            ArrivalsCopy.alsoIn(otherBooks.map(\.name))
        } else {
            nil
        }
        switch OwnershipDecision.verdict(targetOwned: bookOwned, note: note) {
        case .add:
            return ArrivalArms(acts: [.seatArrival, .dismissArrival], line: nil)
        case .needsChoice(.copyOrMove):
            return ArrivalArms(acts: [.copyIn, .moveIn, .dismissArrival], line: line)
        case .needsChoice(.copyOnly):
            return ArrivalArms(acts: [.copyIn, .dismissArrival], line: line)
        }
    }

    /// Each act's word on the row (the registry's verbs).
    static func verb(_ act: CapabilityID) -> String {
        CapabilityRegistry.capability(act).verb
    }
}

// MARK: - The model

/// The door of ONE book, observed, and its two acts. Holds projections and
/// ids only (the arrival rows' ids, the note titles to say) and calls the
/// operations — no business rule lives here: what may be seated, and when, is
/// `seatArrival`'s, and its refusal is what she hears.
@MainActor
@Observable
final class BookArrivalsModel {
    @ObservationIgnored let session: AppSession
    let readingID: String

    /// The door's answer — the count and (while open) the first rows.
    private(set) var door: Queries.BookArrivals = .none
    /// Rows whose judgment is in flight — their doors grey until the store
    /// answers, so a double click cannot fire one act twice.
    private(set) var judging: Set<String> = []
    /// 13i-c U4: the ownership facts of the LISTED rows' notes (note id →
    /// facts; an ordinary free note is absent — "silence the common case"),
    /// read once per delivered listing, ∝ the listed rows (P1).
    private(set) var facts: [String: Queries.OwnershipFacts] = [:]
    /// VX-821: the listed untitled notes' FIRST WORDS — the Library's one
    /// derivation (`SidebarRowLeads`, read flat in each note's length), read
    /// with the facts, ∝ the listed rows. A named note (or a daily entry) is
    /// absent and keeps its display title.
    private(set) var leads: [String: String] = [:]

    /// **VX-821 (R-808-5): whether the REVIEW AREA is open** — the masthead
    /// door's press opens it in the book's content area (the popover it
    /// replaced retired); Done, esc, a mode tab or any navigation the book
    /// takes closes it. It lists the rows while it is (the door hosts the
    /// observation). It opens on an EMPTY door too — the calm answer says
    /// "nothing is waiting" — and judging the last row leaves it open with
    /// that answer: she leaves by Done (her ruling's door), never by surprise.
    private(set) var reviewOpen = false
    /// VX-821: the pick and the walked row (pure — `ArrivalsSelection`).
    private(set) var selection = ArrivalsSelection()
    /// VX-821 (A-808-11 F-7(a)): Dismiss all's ask, carrying the rows it names
    /// — the confirm acts on exactly those (the RecoveryView rule: the value
    /// rides into the action, so no binding setter can clear it first).
    var pendingDismissAll: [ArrivalsBulk.Row]?
    /// VX-821 (F-8): a bulk press is in flight — a second waits for nothing
    /// (it does nothing).
    private(set) var bulkInFlight = false

    /// How many rows the open review lists (the count is never windowed). The
    /// full book area has room: rows realize lazily (P3), and the listing,
    /// its facts and its first words are ∝ this bound, never the corpus.
    static let window = 100

    init(session: AppSession, readingID: String) {
        self.session = session
        self.readingID = readingID
    }

    /// What the observation asks for: the count alone while the review is
    /// closed (the common occupied state pays for no listing), the window
    /// while it is open.
    var listingLimit: Int { reviewOpen ? Self.window : 0 }

    /// The door's press, Done, esc, a navigation: open or close the review.
    /// Closing forgets the pick (a fresh open starts clean, its keyboard on
    /// the first row).
    func setReviewOpen(_ open: Bool) {
        guard reviewOpen != open else { return }
        reviewOpen = open
        if !open {
            selection = ArrivalsSelection()
            pendingDismissAll = nil
        }
    }

    /// The listed rows' ids, in the listing's order (the pick's order).
    var order: [String] { door.rows.map(\.id) }

    /// **What a row is called** — its first words when it leads with them
    /// (the Library's one derivation), else its display title. The row, its
    /// receipts and the bulk refusals all read this one answer.
    func label(for arrival: Queries.BookArrival) -> String {
        leads[arrival.postID] ?? arrival.title
    }

    // MARK: The pick (VX-821 — the rules are `ArrivalsSelection`'s)

    func click(_ id: String, modifiers: NoteRowClickModifiers) {
        selection.click(id, modifiers: modifiers, order: order)
    }

    func togglePick(_ id: String) { selection.toggle(id, order: order) }

    func selectAll() { selection.selectAll(order) }

    func walk(_ direction: ArrivalsSelection.Direction, extend: Bool) {
        selection.walk(direction, extend: extend, order: order)
    }

    /// The listed rows ⏎ / ⌫ act on (the pick, else the walked row).
    var keyTargets: [Queries.BookArrival] {
        let ids = Set(selection.targets(in: order))
        return door.rows.filter { ids.contains($0.id) }
    }

    /// The picked listed rows, in listing order.
    var pickedRows: [Queries.BookArrival] {
        door.rows.filter { selection.isPicked($0.id) }
    }

    /// Observe the door. Hosted by the masthead door with `.task(id:
    /// listingLimit)` (17y (h) — the line's host retired), so opening the
    /// popover restarts the observation with its listing, and the
    /// observation lives exactly as long as the book shows its door (P3).
    func start() async {
        do {
            for try await value in session.database.observeBookArrivals(
                readingID, limit: listingLimit) {
                adopt(value)
                await loadFacts()
            }
        } catch is CancellationError {
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
        }
    }

    /// Internal so pins drive the door deterministically (hosted `.task`
    /// callbacks don't fire under the test host — the `BookViewModel.adopt`
    /// precedent).
    func adopt(_ value: Queries.BookArrivals) {
        door = value
        // A bulk press greys its rows until it answers — its own rows stay
        // judging even while the listing re-delivers mid-run.
        if !bulkInFlight { judging.formIntersection(value.rows.map(\.id)) }
        // VX-821: the pick follows what is listed; the walked row keeps its
        // place (the next row slides under the keyboard).
        selection.prune(toVisible: value.rows.map(\.id))
    }

    /// 13i-c U4: read the listed rows' ownership facts — ONE page-driven
    /// statement (`Queries.ownershipFacts`), so each row draws its arms.
    /// VX-821: and their first words (`SidebarRowLeads` — the Library's one
    /// derivation, flat in each note's length), in the same read.
    func loadFacts() async {
        let ids = door.rows.map(\.postID)
        guard !ids.isEmpty else {
            facts = [:]
            leads = [:]
            return
        }
        let read = try? await session.database.read { [readingID] db in
            (facts: try Queries.ownershipFacts(db, postIDs: ids, inBook: readingID),
             leads: try SidebarRowLeads.read(db, noteIDs: ids))
        }
        facts = read?.facts ?? [:]
        leads = read?.leads ?? [:]
    }

    /// The row's arms, given whether this book owns its notes.
    func arms(for arrival: Queries.BookArrival, bookOwned: Bool) -> ArrivalArms {
        ArrivalArms.of(bookOwned: bookOwned, facts: facts[arrival.postID])
    }

    // (VX-821: `expanded` and `toggle()` — the 13i-b inline line's fold,
    // kept since 17y moved the rows into the popover — RETIRED with the
    // popover. The review's one open/close is `setReviewOpen`.)

    /// **Add** — seat the arrival: the note lands at the END, unsectioned
    /// (§4). The receipt says where; a refusal is the operation's own, in
    /// words that name the road (capacity → raise the cap; finished →
    /// reopen).
    func seat(_ arrival: Queries.BookArrival, book: Reading?, chaptered: Bool) async {
        guard judging.insert(arrival.id).inserted else { return }
        defer { judging.remove(arrival.id) }
        do {
            try await session.runner.run { ops in try ops.seatArrival(arrival.id) }
            session.status.receipt(ArrivalsCopy.added(
                label(for: arrival), chaptered: chaptered, archived: arrival.archived))
        } catch {
            session.status.refuse(ArrivalsCopy.refusal(
                for: error, book: book?.name, cap: book?.maxPosts,
                sealed: book?.sealedAt != nil))
        }
    }

    /// **Copy In** (13i-c U4) — answer the arrival with a linked copy at the
    /// END (`copyPostIntoReading(answering:)` — the pair decided for good,
    /// P-13ic-3). The original stays where it lives.
    func copyIn(_ arrival: Queries.BookArrival, book: Reading?) async {
        guard judging.insert(arrival.id).inserted else { return }
        defer { judging.remove(arrival.id) }
        do {
            _ = try await session.runner.run { ops in
                try ops.copyPostIntoReading(answering: arrival.id)
            }
            session.status.receipt(ArrivalsCopy.copiedIn(label(for: arrival)))
        } catch {
            session.status.refuse(ArrivalsCopy.refusal(
                for: error, book: book?.name, cap: book?.maxPosts,
                sealed: book?.sealedAt != nil))
        }
    }

    /// **Move In** (13i-c U4) — the owned book's claim-move on its own bell
    /// (`movePostIntoReading(answering:)`): the note leaves every other book
    /// and joins here at the END. The receipt names the books it left; a
    /// finished book among them refuses with THAT book's road.
    func moveIn(_ arrival: Queries.BookArrival, book: Reading?) async {
        guard judging.insert(arrival.id).inserted else { return }
        defer { judging.remove(arrival.id) }
        let database = session.database
        do {
            let left: [String] = try await session.runner.run { ops in
                let result = try ops.movePostIntoReading(answering: arrival.id)
                let leftIDs = result.severed.filter { $0.status == .member }.map(\.readingId)
                return try database.read { db in
                    try leftIDs.compactMap { try Queries.reading(db, id: $0)?.name }
                }
            }
            session.status.receipt(ArrivalsCopy.movedIn(label(for: arrival), left: left))
        } catch {
            if case OperationError.lockedReading(let id) = error, id != readingID {
                // 13i-c ladder round 1: the blocking book's OWN road (reopen ·
                // unseal); a book that cannot be read falls back to the shared
                // words, never to "“” is finished".
                let blocking = (try? await session.database.read { db in
                    try Queries.reading(db, id: id)
                }) ?? nil
                if let blocking {
                    session.status.refuse(MembershipChoiceCopy.moveRefusedFinished(
                        blocking.name, sealed: blocking.sealedAt != nil))
                } else {
                    // The sanity pass's concern 1: the shared table has no
                    // lockedReading words, so the generic road would speak
                    // the R93-banned "Refused: error(…)" dump — the
                    // book-less sentence instead.
                    session.status.refuse(MembershipChoiceCopy.moveRefusedUnnamed)
                }
            } else {
                session.status.refuse(ArrivalsCopy.refusal(
                    for: error, book: book?.name, cap: book?.maxPosts,
                    sealed: book?.sealedAt != nil))
            }
        }
    }

    /// **Dismiss** — tombstone the arrival row: the decision record (§4).
    func dismiss(_ arrival: Queries.BookArrival, book: Reading?) async {
        guard judging.insert(arrival.id).inserted else { return }
        defer { judging.remove(arrival.id) }
        do {
            try await session.runner.run { ops in try ops.dismissArrival(arrival.id) }
            session.status.receipt(ArrivalsCopy.dismissed(label(for: arrival)))
        } catch {
            session.status.refuse(ArrivalsCopy.refusal(
                for: error, book: book?.name, cap: book?.maxPosts,
                sealed: book?.sealedAt != nil))
        }
    }
}

// MARK: - The bulk doors (VX-821 — A-808-11)

/// **Add all · Dismiss all · Add N · Dismiss N**, built to the orchestrator's
/// ruling A-808-11 (the run record, Unit B3): PER-ROW acts in listing order —
/// `seatArrival` / `dismissArrival` once per row, each its own transaction
/// and its own refusal, no new operation (the Trash bulk precedent) — and NO
/// undo entry, the single acts' own posture (neither registers one; the
/// guard where undo is absent is Dismiss all's one confirm, F-7(a)). ONE
/// message per press (`ArrivalsBulk.words`). A row whose arms need her
/// choice is never run by Add — named, kept waiting, kept picked (F-4); a
/// BOOK-level refusal ends the run and counts the rest as still waiting, a
/// row's own refusal skips the row (F-5); "all" is the header's N read at
/// the press, in one read with its facts (F-6). One flight at a time (F-8).
extension BookArrivalsModel {
    /// A listed row, as a press reads it (its name, its arms' verdict).
    func bulkRow(_ arrival: Queries.BookArrival, bookOwned: Bool) -> ArrivalsBulk.Row {
        ArrivalsBulk.Row(
            id: arrival.id, name: label(for: arrival), archived: arrival.archived,
            needsChoice: !arms(for: arrival, bookOwned: bookOwned).acts.contains(.seatArrival))
    }

    /// **Add N** — the picked rows.
    func addSelected(book: Reading?, chaptered: Bool) async {
        let rows = pickedRows.map { bulkRow($0, bookOwned: book?.owned ?? false) }
        guard !rows.isEmpty else {
            session.status.refuse(ArrivalsReviewCopy.nothingSelected)
            return
        }
        await runBulk(.add, rows: rows, book: book, chaptered: chaptered)
    }

    /// **Dismiss N** — the picked rows (no confirm: the pick is exactly what
    /// she chose — F-7(a)).
    func dismissSelected(book: Reading?) async {
        let rows = pickedRows.map { bulkRow($0, bookOwned: book?.owned ?? false) }
        guard !rows.isEmpty else {
            session.status.refuse(ArrivalsReviewCopy.nothingSelected)
            return
        }
        await runBulk(.dismiss, rows: rows, book: book, chaptered: false)
    }

    /// **Add all** — every row the header counts, read at the press (F-6).
    func addAll(book: Reading?, chaptered: Bool) async {
        guard let rows = await everyWaitingRow(bookOwned: book?.owned ?? false) else { return }
        guard !rows.isEmpty else {
            session.status.refuse(ArrivalsReviewCopy.nothingWaitingToJudge)
            return
        }
        await runBulk(.add, rows: rows, book: book, chaptered: chaptered)
    }

    /// **Dismiss all** — ASKS FIRST (F-7(a)): the rows the header counts are
    /// read at the press and carried by the ask, and the confirm dismisses
    /// exactly those (a note that rang after the ask was never asked about).
    func requestDismissAll(book: Reading?) async {
        guard let rows = await everyWaitingRow(bookOwned: book?.owned ?? false) else { return }
        guard !rows.isEmpty else {
            session.status.refuse(ArrivalsReviewCopy.nothingWaitingToJudge)
            return
        }
        pendingDismissAll = rows
    }

    /// The confirm's press — the rows ride INTO the act (the RecoveryView
    /// rule), so no dialog write-back can clear them first.
    func confirmDismissAll(_ rows: [ArrivalsBulk.Row], book: Reading?) async {
        pendingDismissAll = nil
        await runBulk(.dismiss, rows: rows, book: book, chaptered: false)
    }

    func cancelDismissAll() { pendingDismissAll = nil }

    /// **⏎** — the pick's Add N when something is picked, else the walked
    /// row's single Add (one row through the same road speaks the single
    /// act's own words; a choice row hears that it waits on her choice).
    func addKeyTargets(book: Reading?, chaptered: Bool) async {
        let rows = keyTargets.map { bulkRow($0, bookOwned: book?.owned ?? false) }
        guard !rows.isEmpty else { return }
        await runBulk(.add, rows: rows, book: book, chaptered: chaptered)
    }

    /// **⌫** — the pick's Dismiss N, else the walked row's single Dismiss.
    func dismissKeyTargets(book: Reading?) async {
        let rows = keyTargets.map { bulkRow($0, bookOwned: book?.owned ?? false) }
        guard !rows.isEmpty else { return }
        await runBulk(.dismiss, rows: rows, book: book, chaptered: false)
    }

    /// Every row the door counts, with its arms' verdict — ONE read (the
    /// listing's own predicate, so "all" is the header's N; its facts in the
    /// same pass). nil after a refused read (said on the seam).
    func everyWaitingRow(bookOwned: Bool) async -> [ArrivalsBulk.Row]? {
        do {
            let read = try await session.database.read { [readingID] db in
                let all = try Queries.bookArrivals(db, readingID: readingID, limit: Int(Int32.max))
                return (all.rows, try Queries.ownershipFacts(
                    db, postIDs: all.rows.map(\.postID), inBook: readingID))
            }
            return read.0.map { arrival in
                ArrivalsBulk.Row(
                    id: arrival.id, name: label(for: arrival), archived: arrival.archived,
                    needsChoice: !ArrivalArms.of(bookOwned: bookOwned, facts: read.1[arrival.postID])
                        .acts.contains(.seatArrival))
            }
        } catch {
            session.status.refuse(OpsRefusalCopy.message(for: error))
            return nil
        }
    }

    /// **The run** — per row, in order; one message at the end.
    func runBulk(
        _ act: ArrivalsBulk.Act, rows: [ArrivalsBulk.Row], book: Reading?, chaptered: Bool
    ) async {
        guard !bulkInFlight, !rows.isEmpty else { return }
        bulkInFlight = true
        let ids = rows.map(\.id)
        judging.formUnion(ids)
        defer {
            bulkInFlight = false
            judging.subtract(ids)
        }
        var outcomes: [(row: ArrivalsBulk.Row, outcome: ArrivalsBulk.Outcome)] = []
        var bookRefusal: String?
        for row in rows {
            if bookRefusal != nil {
                outcomes.append((row, .stillWaiting))
                continue
            }
            if act == .add, row.needsChoice {
                outcomes.append((row, .waitsOnChoice))
                continue
            }
            let id = row.id
            do {
                switch act {
                case .add: _ = try await session.runner.run { ops in try ops.seatArrival(id) }
                case .dismiss: try await session.runner.run { ops in try ops.dismissArrival(id) }
                }
                outcomes.append((row, .landed))
            } catch {
                let words = ArrivalsCopy.refusal(
                    for: error, book: book?.name, cap: book?.maxPosts, sealed: book?.sealedAt != nil)
                if act == .add, ArrivalsBulk.needsChoice(error) {
                    outcomes.append((row, .waitsOnChoice))
                } else if ArrivalsBulk.endsTheRun(error) {
                    bookRefusal = words
                    outcomes.append((row, .stillWaiting))
                } else {
                    outcomes.append((row, .refused(words)))
                }
            }
        }
        let words = ArrivalsBulk.words(
            act, outcomes: outcomes, bookRefusal: bookRefusal, chaptered: chaptered)
        if let receipt = words.receipt {
            session.status.receipt(receipt)
        } else if let refusal = words.refusal {
            session.status.refuse(refusal)
        }
    }
}

// MARK: - The face

/// **THE ARRIVALS DOOR** (17y B3 item (h) — R-17y-1: "the small icon in the
/// book's mode-row area beside the settings gear — calm when nothing waits,
/// presence when something does"). Drawn on a BOOK's masthead only (a
/// gathering has no door — it holds nothing; P-2). CALM: a faint tray icon,
/// no count. PRESENCE: the accent icon and the count. It also HOSTS the
/// door's observation (the retired line's job).
///
/// **VX-821 (R-808-5): its press OPENS THE REVIEW AREA** in the book's content
/// area (`BookArrivalsReview` — the book composes it over the mode's body);
/// a second press closes it, as Done does. THE POPOVER RETIRED. Her clutter
/// mandate kept: nothing lists until she opens it. While the review is open
/// the glyph is filled — the door says where she is.
struct BookArrivalsDoor: View {
    let model: BookArrivalsModel
    let structure: BookStructureModel

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    #if DEBUG
    @State private var probeOwner = UUID()
    #endif

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    /// The one PRESENCE value (§23's composition point, kept).
    private var presence: Bool { ArrivalsLineFace.isShown(model.door) }

    /// **Whether a book's masthead draws the door at all** — a BOOK's only (a
    /// gathering holds nothing, so it has no door — P-2). The masthead's one
    /// condition, named so it is pinnable without mounting a book view.
    nonisolated static func isDrawn(for reading: Reading?) -> Bool {
        reading?.kind == .book
    }

    var body: some View {
        Button {
            model.setReviewOpen(!model.reviewOpen)
        } label: {
            HStack(spacing: 2) {
                Image(systemName: model.reviewOpen ? "tray.and.arrow.down.fill" : "tray.and.arrow.down")
                if let count = ArrivalsCopy.doorCount(model.door.count) {
                    Text(count)
                        .font(tokens.small.weight(.semibold))
                        .lineLimit(1)
                        .fixedSize()
                }
            }
            .foregroundStyle(presence ? tokens.accent : tokens.faint)
        }
        .buttonStyle(.borderless)
        .help(ArrivalsCopy.doorHelp(count: model.door.count))
        .accessibilityLabel(ArrivalsCopy.header(count: model.door.count))
        // The door's observation — the count always, the rows while open.
        .task(id: model.listingLimit) { await model.start() }
        #if DEBUG
        .onAppear { recordDoor() }
        .onChange(of: model.door) { _, _ in recordDoor() }
        .onChange(of: model.reviewOpen) { _, _ in recordDoor() }
        .onDisappear { ArrivalsDoorProbe.forget(model.readingID, owner: probeOwner) }
        #endif
    }

    #if DEBUG
    private func recordDoor() {
        ArrivalsDoorProbe.record(
            model.readingID, owner: probeOwner,
            count: model.door.count, presence: presence, open: model.reviewOpen)
    }
    #endif
}

/// **ONE WAITING ROW'S TWO SHAPES** (VX-821 — the leg-2 walk's W-2/W-3).
/// Three subviews: the checkbox, the text column, the arms. INLINE while the
/// row holds the checkbox, the text column's floor and the arms whole beside
/// each other — the arms at the trailing edge; else STACKED — the arms wrap
/// under the text, at the text's left edge (or the row's, when even that
/// indent cannot hold them). The class is `ArrivalRowFit`'s pure rule over
/// the row's width and the arms' own ideal width — never the text's — so a
/// title, a why line or a sort can never change a row's shape (the Library
/// controls-row law: wrap only by stable widths, never `ViewThatFits`).
///
/// `measuredWidth` is the list's measured width less the row's padding — an
/// INPUT of the layout (W-3: a changed input re-runs the layout of every
/// realized row on every width change), and the width it answers with when
/// a parent asks its ideal (a nil proposal).
struct ArrivalRowLayout: Layout {
    var measuredWidth: CGFloat

    private struct Plan {
        var width: CGFloat
        var stacked: Bool
        var box: CGSize
        var arms: CGSize
        var textWidth: CGFloat
        var text: CGSize
    }

    private func plan(width proposed: CGFloat?, subviews: Subviews) -> Plan? {
        guard subviews.count == 3 else { return nil }
        let box = subviews[0].sizeThatFits(.unspecified)
        let arms = subviews[2].sizeThatFits(.unspecified)
        let width = proposed ?? (measuredWidth > 0
            ? measuredWidth
            : ArrivalRowFit.inlineWidth(
                boxWidth: box.width, textWidth: subviews[1].sizeThatFits(.unspecified).width,
                armsWidth: arms.width))
        let stacked = ArrivalRowFit.stacked(rowWidth: width, boxWidth: box.width, armsWidth: arms.width)
        let textWidth = ArrivalRowFit.textWidth(
            rowWidth: width, boxWidth: box.width, armsWidth: arms.width, stacked: stacked)
        let text = subviews[1].sizeThatFits(ProposedViewSize(width: textWidth, height: nil))
        return Plan(width: width, stacked: stacked, box: box, arms: arms, textWidth: textWidth, text: text)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let plan = plan(width: proposal.width, subviews: subviews) else { return .zero }
        let height = plan.stacked
            ? max(plan.box.height, plan.text.height + ArrivalRowFit.stackGap + plan.arms.height)
            : max(plan.box.height, plan.text.height, plan.arms.height)
        return CGSize(width: plan.width, height: height)
    }

    func placeSubviews(
        in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) {
        guard let plan = plan(width: bounds.width, subviews: subviews) else { return }
        subviews[0].place(
            at: CGPoint(x: bounds.minX, y: bounds.minY + ArrivalRowFit.boxDrop),
            anchor: .topLeading, proposal: .unspecified)
        let textX = bounds.minX + plan.box.width + ArrivalRowFit.spacing
        subviews[1].place(
            at: CGPoint(x: textX, y: bounds.minY), anchor: .topLeading,
            proposal: ProposedViewSize(width: plan.textWidth, height: nil))
        if plan.stacked {
            let x = ArrivalRowFit.stackedArmsIndented(
                rowWidth: bounds.width, boxWidth: plan.box.width, armsWidth: plan.arms.width)
                ? textX : bounds.minX
            subviews[2].place(
                at: CGPoint(x: x, y: bounds.minY + plan.text.height + ArrivalRowFit.stackGap),
                anchor: .topLeading, proposal: .unspecified)
        } else {
            subviews[2].place(
                at: CGPoint(x: bounds.maxX - plan.arms.width, y: bounds.minY),
                anchor: .topLeading, proposal: .unspecified)
        }
    }
}

/// **A WAITING ROW'S WHY · SINCE LINE** (F-2 — the ladder's round 1). Its
/// subviews carry a ROLE: the why, the dot, and the since's two forms (whole
/// and short). They are laid out at the widths `ArrivalMetaFit.plan` gives
/// them from each part's own ideal width, so the arithmetic the pin reads IS
/// the arithmetic the row lays out (the `TakeLabelLayout` precedent). A part
/// the plan does not draw (the form it did not choose, or the dot beside a
/// dropped since) is placed with a zero proposal: a `Text` offered nothing
/// draws nothing and takes no room. Every part is one line in the same font,
/// so aligning their tops aligns their baselines.
struct ArrivalMetaLayout: Layout {
    typealias Role = ArrivalMetaRole

    private func role(_ subview: LayoutSubview) -> Role { subview[ArrivalMetaRoleKey.self] }

    private func plan(width: CGFloat?, subviews: Subviews) -> ArrivalMetaFit.Plan {
        func ideal(_ wanted: Role) -> CGFloat? {
            subviews.first { role($0) == wanted }.map { $0.sizeThatFits(.unspecified).width }
        }
        let whole = ideal(.sinceWhole)
        let since = whole.map { (whole: $0, short: ideal(.sinceShort) ?? $0) }
        return ArrivalMetaFit.plan(width: width, why: ideal(.why), dot: ideal(.dot) ?? 0, since: since)
    }

    /// Where a part sits and how wide it is, or nil when the plan does not
    /// draw it.
    private func frame(_ role: Role, in plan: ArrivalMetaFit.Plan) -> (x: CGFloat, width: CGFloat)? {
        let drawn: (x: CGFloat, width: CGFloat)
        switch role {
        case .why: drawn = (0, plan.why)
        case .dot: drawn = (plan.dotOffset, plan.dot)
        case .sinceWhole:
            guard plan.form == .whole else { return nil }
            drawn = (plan.sinceOffset, plan.since)
        case .sinceShort:
            guard plan.form == .short else { return nil }
            drawn = (plan.sinceOffset, plan.since)
        }
        return drawn.width > 0 ? drawn : nil
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let plan = plan(width: proposal.width, subviews: subviews)
        var height: CGFloat = 0
        for subview in subviews {
            guard let frame = frame(role(subview), in: plan) else { continue }
            height = max(height, subview.sizeThatFits(ProposedViewSize(width: frame.width, height: nil)).height)
        }
        return CGSize(width: plan.width, height: height)
    }

    func placeSubviews(
        in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) {
        // R2-1: plan from the PROPOSAL, exactly as sizeThatFits does — nil
        // included (the plan's nil is every part at its ideal). bounds.width is
        // the chosen form's own threshold, where a re-plan must not flip, so
        // it is never the fallback: under a nil proposal it is the ideal width,
        // the whole form's threshold to the point (reconcile 2's sanity pass).
        let plan = plan(width: proposal.width, subviews: subviews)
        for subview in subviews {
            guard let frame = frame(role(subview), in: plan) else {
                subview.place(at: bounds.origin, anchor: .topLeading, proposal: .zero)
                continue
            }
            subview.place(
                at: CGPoint(x: bounds.minX + frame.x, y: bounds.minY), anchor: .topLeading,
                proposal: ProposedViewSize(width: frame.width, height: nil))
        }
    }
}

/// A subview's role in `ArrivalMetaLayout`.
nonisolated enum ArrivalMetaRole: Equatable, Sendable { case why, dot, sinceWhole, sinceShort }

/// The role's layout value (default: the why).
private nonisolated struct ArrivalMetaRoleKey: LayoutValueKey {
    static let defaultValue: ArrivalMetaRole = .why
}

extension View {
    /// Tag a subview of `ArrivalMetaLayout` with its role.
    func arrivalMetaRole(_ role: ArrivalMetaRole) -> some View {
        layoutValue(key: ArrivalMetaRoleKey.self, value: role)
    }
}

/// **The waiting rows** — the review area's list (VX-821; the popover's
/// rows, carried whole). Each row: its checkbox (the pick), the note's NAME
/// (its first words where it leads with them — a door to the note itself,
/// read-normal; opening never seats), the archived mark, WHY it waits and
/// since when, a proposal's own reason, the ownership line, and its judgment
/// arms (data — `ArrivalArms`). A click on the row's body picks (⌘ toggles,
/// ⇧ ranges); the keyboard's walked row wears the ring. Read-only text
/// throughout — no editor (P3); rows realize lazily.
struct BookArrivalsList: View {
    let model: BookArrivalsModel
    let structure: BookStructureModel
    /// Called after any row interaction — the review takes the keyboard back
    /// so ⏎ / ⌫ / the arrows keep working after a click.
    var onInteract: () -> Void = {}

    /// The judgment doors this face renders — the four acts' ONLY renderer,
    /// so the declaration lives with the builder (the `MarkdownActs` /
    /// `BlockHistoryPane` precedent), and the registry walk asserts it.
    static let surfaceCapabilities: [CapabilityID] = [
        .seatArrival, .dismissArrival,
        // 13i-c U4 (§4 row 19): the ownership arms — Copy In / Move In.
        .copyIn, .moveIn,
    ]

    @Environment(ThemeStore.self) private var themeStore: ThemeStore?
    @Environment(\.colorScheme) private var scheme
    #if DEBUG
    /// This list's own name in the DEBUG probe (DEBUG-only; see the probe).
    @State private var probeOwner = UUID()
    #endif
    /// **W-3 (the leg-2 walk) — the list's measured width, whole points**,
    /// written on a real change only. Every row's layout takes it as an INPUT
    /// (`ArrivalRowLayout.measuredWidth`), so a width change re-runs every
    /// realized row's layout: the lazy stack keeps a realized row's measured
    /// layout across a pure width change (the walk's crushed titles survived
    /// the window growing back, until the voice flip rebuilt every row), and a
    /// changed layout input is what makes it ask again.
    @State private var listWidth: CGFloat = 0

    /// The row's own horizontal padding (each side) — the layout's width is
    /// the list's less twice this.
    static let rowInset: CGFloat = 16

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 2) {
            ForEach(model.door.rows) { arrival in
                row(arrival)
            }
            let hidden = ArrivalsLineFace.hidden(model.door)
            if hidden > 0 {
                Text(tokens.chromeLabel(ArrivalsCopy.more(hidden)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
                    .padding(.horizontal, Self.rowInset)
                    .padding(.vertical, 10)
            }
        }
        .onGeometryChange(for: CGFloat.self) { $0.size.width.rounded() } action: { width in
            if width != listWidth { listWidth = width }
        }
        #if DEBUG
        .coordinateSpace(name: ArrivalsLineProbe.space)
        .onChange(of: listWidth) { _, width in
            ArrivalsLineProbe.recordWidth(model.readingID, owner: probeOwner, width)
        }
        .onDisappear { ArrivalsLineProbe.forget(model.readingID, owner: probeOwner) }
        #endif
    }

    private func row(_ arrival: Queries.BookArrival) -> some View {
        let busy = model.judging.contains(arrival.id)
        let arms = model.arms(for: arrival, bookOwned: structure.reading?.owned ?? false)
        let picked = model.selection.isPicked(arrival.id)
        let walked = model.selection.walked == arrival.id
        let why = ArrivalsReviewCopy.why(arrival)
        let now = Date()
        let since = ArrivalsReviewCopy.since(arrival.waitingSince, now: now)
        let sinceShort = ArrivalsReviewCopy.sinceShort(arrival.waitingSince, now: now)
        let sinceHelp = ArrivalsReviewCopy.sinceHelp(arrival.waitingSince)
        let reason = ArrivalsReviewCopy.reason(arrival)
        // W-2 / W-3 (the leg-2 walk): the row's TWO SHAPES by a stable width
        // class — the arms trailing while the row holds them beside the text's
        // floor, else under the text (`ArrivalRowFit`); never `ViewThatFits`,
        // never an overflow past the pane's edge.
        return ArrivalRowLayout(measuredWidth: max(0, listWidth - 2 * Self.rowInset)) {
            // The pick — ⌘-click's meaning, as a box (her picked preview).
            Button {
                model.togglePick(arrival.id)
                onInteract()
            } label: {
                Image(systemName: picked ? "checkmark.square.fill" : "square")
                    .font(tokens.body)
                    .foregroundStyle(picked ? tokens.accent : tokens.muted)
            }
            .buttonStyle(.plain)
            .help(ArrivalsReviewCopy.checkboxHelp)
            .accessibilityLabel(ArrivalsReviewCopy.checkboxHelp)
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    // The note's NAME is her prose, never chrome — no
                    // `chromeLabel` (the 13u3 UNIT B lesson: the Terminal
                    // voice would lowercase it). 17y (h): it OPENS the note —
                    // the ordinary note-open broadcast, read-normal; opening
                    // never seats (only Add does).
                    Button {
                        Self.openNote(arrival.postID)
                    } label: {
                        Text(model.label(for: arrival))
                            .font(tokens.body)
                            .foregroundStyle(tokens.ink)
                            .underline()
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .buttonStyle(.plain)
                    .help(ArrivalsCopy.openHelp)
                    // 13i-d U4 (#169(a)(2) — P-13ib-U2-2 reversed): an
                    // ARCHIVED waiter stays at the door, marked; the same
                    // doors follow.
                    if arrival.archived {
                        Text(tokens.chromeLabel(ArrivalsCopy.archivedMark))
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .lineLimit(1)
                            .fixedSize()
                            .help(ArrivalsCopy.archivedMarkHelp)
                    }
                }
                // VX-821: WHY it waits and since when. The why line carries
                // a client's name or a tag path — data, never chrome-cased.
                // F-2 (the ladder's round 1): the WHY gets the width first
                // and the SINCE gives way first, whole → short → nothing
                // (`ArrivalMetaFit`, laid out by `ArrivalMetaLayout`). The
                // since's whole fact is always on the why's hover too.
                ArrivalMetaLayout {
                    if let why {
                        Text(why)
                            .font(tokens.small)
                            .foregroundStyle(tokens.muted)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .help(ArrivalsReviewCopy.whyHelp(why, since: sinceHelp))
                            .arrivalMetaRole(.why)
                    }
                    if why != nil, since != nil {
                        Text("\u{00B7}")
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .lineLimit(1)
                            .arrivalMetaRole(.dot)
                    }
                    if let since {
                        Text(tokens.chromeLabel(since))
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .lineLimit(1)
                            .stampHelp(sinceHelp)
                            .arrivalMetaRole(.sinceWhole)
                    }
                    if let sinceShort {
                        // The short form is visual only: it is hidden from
                        // accessibility so the stamp is never announced
                        // twice. The whole form keeps its words, and the
                        // why's hover carries the whole fact at every width.
                        Text(tokens.chromeLabel(sinceShort))
                            .font(tokens.small)
                            .foregroundStyle(tokens.faint)
                            .lineLimit(1)
                            .stampHelp(sinceHelp)
                            .accessibilityHidden(true)
                            .arrivalMetaRole(.sinceShort)
                    }
                }
                // A proposal's reason — the client's own prose, quoted.
                if let reason {
                    Text(reason)
                        .font(tokens.small)
                        .foregroundStyle(tokens.ink)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .help(reason)
                }
                // 13i-c U4 (§18.4): why this row is not an ordinary Add —
                // who owns it, or where else it lives. Book names are hers,
                // never chrome.
                if let line = arms.line {
                    Text(line)
                        .font(tokens.small)
                        .foregroundStyle(tokens.muted)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        // The walk: a long "also in …" list truncates in the
                        // middle — the hover says it whole.
                        .help(line)
                }
            }
            // 13i-c U4: the row's arms are DATA (`ArrivalArms`) — one
            // renderer per act, in the table's order. VX-821: bordered and a
            // good size (her bar), the door's word never truncated (W-1); at
            // a narrow pane they wrap under the text whole (W-2).
            HStack(spacing: 8) {
                ForEach(arms.acts, id: \.self) { act in
                    armButton(act, arrival: arrival)
                        .disabled(busy)
                        .lineLimit(1)
                        .fixedSize()
                }
            }
            #if DEBUG
            .onGeometryChange(for: CGRect.self) { $0.frame(in: .named(ArrivalsLineProbe.space)) } action: { rect in
                ArrivalsLineProbe.recordArms(model.readingID, owner: probeOwner, arrival.id, rect)
            }
            #endif
        }
        .padding(.vertical, 12)
        .padding(.horizontal, Self.rowInset)
        .background(picked ? tokens.wash : Color.clear, in: RoundedRectangle(cornerRadius: 7))
        .overlay {
            if walked {
                RoundedRectangle(cornerRadius: 7).stroke(tokens.ring, lineWidth: 1)
            }
        }
        .contentShape(Rectangle())
        // The row's BODY picks — the Library's one brain over the click's
        // modifiers (`NoteRowClickModifiers.current`, its one impure read).
        .onTapGesture {
            model.click(arrival.id, modifiers: .current)
            onInteract()
        }
        #if DEBUG
        .onAppear { record(arrival, arms: arms, why: why) }
        .onChange(of: arms) { _, now in record(arrival, arms: now, why: why) }
        .onDisappear {
            ArrivalsLineProbe.forgetRow(model.readingID, owner: probeOwner, arrival.id)
        }
        #endif
    }

    #if DEBUG
    private func record(_ arrival: Queries.BookArrival, arms: ArrivalArms, why: String?) {
        ArrivalsLineProbe.recordRow(
            model.readingID, owner: probeOwner, arrival.id,
            arms.acts.map(ArrivalArms.verb), archived: arrival.archived, why: why)
    }
    #endif

    /// A waiting row's NAME opens the note itself — the app's ordinary
    /// note-open broadcast (the book view's "open ↗" road), read-normal. It
    /// writes NOTHING: opening never seats (only Add does) — a named call so
    /// the promise is pinnable (the `MembershipChip.ascend` reason).
    ///
    /// `post` is the broadcast's one seam — NotificationCenter in the app; a
    /// pin hands in a capture so no test posts an APP-WIDE navigation
    /// broadcast (F-B3-3: a broadcast from a test reaches whatever shell the
    /// test host has standing, outside the test's dependency scope).
    static func openNote(
        _ postID: String,
        post: (Notification.Name, [AnyHashable: Any]) -> Void = { name, info in
            NotificationCenter.default.post(name: name, object: nil, userInfo: info)
        }
    ) {
        post(.variorumOpenPost, ["postID": postID])
    }

    /// One judgment door — its act, its word, its weight.
    @ViewBuilder
    private func armButton(_ act: CapabilityID, arrival: Queries.BookArrival) -> some View {
        switch act {
        case .seatArrival:
            Button(tokens.chromeLabel(ArrivalsCopy.addVerb)) {
                onInteract()
                Task {
                    await model.seat(
                        arrival, book: structure.reading,
                        chaptered: structure.chaptersActive)
                }
            }
            .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
            .help(ArrivalsCopy.addHelp)
        case .copyIn:
            Button(tokens.chromeLabel(MembershipChoiceCopy.copyInVerb)) {
                onInteract()
                Task { await model.copyIn(arrival, book: structure.reading) }
            }
            .buttonStyle(CalmButtonStyle(tokens: tokens, role: .primary))
            .help(ArrivalsCopy.copyInHelp)
        case .moveIn:
            Button(tokens.chromeLabel(MembershipChoiceCopy.moveInVerb)) {
                onInteract()
                Task { await model.moveIn(arrival, book: structure.reading) }
            }
            .buttonStyle(CalmButtonStyle(tokens: tokens, role: .ordinary))
            .help(ArrivalsCopy.moveInHelp)
        default:
            Button(tokens.chromeLabel(ArrivalsCopy.dismissVerb)) {
                onInteract()
                Task { await model.dismiss(arrival, book: structure.reading) }
            }
            .buttonStyle(CalmButtonStyle(tokens: tokens, role: .ordinary))
            .help(ArrivalsCopy.dismissHelp)
        }
    }
}

#if DEBUG
/// **WHAT THE MOUNTED ROWS DREW, AS A TEST ORACLE** (the `TrayRowDoorProbe`
/// pattern, for its measured reason: a hosted SwiftUI tree exposes no
/// accessibility children in this test host, and a composition dump does not
/// evaluate a `ForEach`'s content). Recorded from each row's own `onAppear`
/// (`BookArrivalsList` — since VX-821 the review area's rows (17y (h)'s popover
/// retired),
/// mountable on its own), keyed by the book; cleared on disappear — so
/// "absent" is an honest answer: nothing drew. DEBUG only.
///
/// **Owned per list instance** (the 18k C4 `oracleOwner` shape): a record
/// names its owner; a forget clears only its own.
@MainActor
enum ArrivalsLineProbe {
    struct Drawn: Equatable {
        var owner: UUID
        /// Arrival row id → the door verbs that row drew.
        var rows: [String: [String]] = [:]
        /// 13i-d U4: the rows that drew the "archived" mark.
        var archivedRows: Set<String> = []
        /// VX-821: arrival row id → the WHY line it drew ("" when it drew
        /// none — the since-when-only face).
        var why: [String: String] = [:]
        /// W-3: the list's measured width, as the rows' layouts last took it.
        var listWidth: CGFloat = 0
        /// W-2: arrival row id → its arms' frame in the list's own space.
        var arms: [String: CGRect] = [:]
    }

    /// The list's coordinate space (the arms' frames are measured in it).
    nonisolated static let space = "ArrivalsLineProbe.list"

    static func recordWidth(_ readingID: String, owner: UUID, _ width: CGFloat) {
        var entry = claim(readingID, owner)
        entry.listWidth = width
        drawn[readingID] = entry
    }

    static func recordArms(_ readingID: String, owner: UUID, _ rowID: String, _ frame: CGRect) {
        var entry = claim(readingID, owner)
        entry.arms[rowID] = frame
        drawn[readingID] = entry
    }

    private(set) static var drawn: [String: Drawn] = [:]

    static func reset() { drawn = [:] }

    private static func claim(_ readingID: String, _ owner: UUID) -> Drawn {
        if let entry = drawn[readingID], entry.owner == owner { return entry }
        return Drawn(owner: owner)
    }

    static func recordRow(
        _ readingID: String, owner: UUID, _ rowID: String, _ verbs: [String],
        archived: Bool = false, why: String? = nil
    ) {
        var entry = claim(readingID, owner)
        entry.rows[rowID] = verbs
        entry.why[rowID] = why ?? ""
        if archived { entry.archivedRows.insert(rowID) } else { entry.archivedRows.remove(rowID) }
        drawn[readingID] = entry
    }

    static func forgetRow(_ readingID: String, owner: UUID, _ rowID: String) {
        guard drawn[readingID]?.owner == owner else { return }
        drawn[readingID]?.rows[rowID] = nil
        drawn[readingID]?.archivedRows.remove(rowID)
        drawn[readingID]?.why[rowID] = nil
        drawn[readingID]?.arms[rowID] = nil
    }

    static func forget(_ readingID: String, owner: UUID) {
        guard drawn[readingID]?.owner == owner else { return }
        drawn[readingID] = nil
    }
}

/// **WHAT THE MASTHEAD DOOR DREW** (17y (h)): the count it shows, whether it
/// wears PRESENCE (the accent — something waits) or is CALM, and whether its
/// popover is open. Owned per door instance (the navigator's masthead and
/// the Index column's are each a door). DEBUG only.
@MainActor
enum ArrivalsDoorProbe {
    struct Drawn: Equatable {
        var owner: UUID
        var count: Int
        var presence: Bool
        var open: Bool
    }

    private(set) static var drawn: [String: Drawn] = [:]

    static func reset() { drawn = [:] }

    static func record(_ readingID: String, owner: UUID, count: Int, presence: Bool, open: Bool) {
        drawn[readingID] = Drawn(owner: owner, count: count, presence: presence, open: open)
    }

    static func forget(_ readingID: String, owner: UUID) {
        guard drawn[readingID]?.owner == owner else { return }
        drawn[readingID] = nil
    }
}
#endif
