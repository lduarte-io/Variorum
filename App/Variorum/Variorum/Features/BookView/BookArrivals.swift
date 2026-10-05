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

    /// The door's hover (wording PROVISIONAL — 13s re-voices).
    static func doorHelp(count: Int) -> String {
        count == 0
            ? "\(word) \u{2014} nothing waiting"
            : "\(word) \u{2014} \(count) waiting: notes this book's rule brought in. "
                + "Open one to read it; add it to the book, or dismiss it."
    }

    /// The popover's head line.
    static func header(count: Int) -> String {
        count == 0 ? word : "\(word) \u{00B7} \(count) waiting"
    }

    /// The popover's calm answer when nothing waits.
    static let nothingWaiting =
        "Nothing is waiting. When this book's rule brings in a note and its dial says "
        + "\u{201C}wait at \(word),\u{201D} the note waits here for you."

    /// A waiting row's NAME is a door to the note itself (17y (h), her
    /// "you should be able to click on the note to see what it is").
    static let openHelp = "Open this note to read it \u{2014} opening never adds it to the book"

    static let addHelp = "Add this note to the book — it lands at the end"
    static let dismissHelp = "Dismiss — don't add this note to the book"

    /// When a row arrived, in the app's ONE stamp vocabulary
    /// (`TimeStampFace.relative` — *today 1:33 AM* · *yesterday* · *Sep 9*),
    /// labelled with this row's own verb. nil when the stamp is unreadable —
    /// the face draws nothing rather than a lie (TimeStampFace's own rule).
    static func arrived(_ iso: String, now: Date) -> String? {
        guard let date = DateFormatter.variorumISO8601.date(from: iso) else { return nil }
        return "arrived " + TimeStampFace.relative(date, now: now)
    }

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
    /// Open = the expansion lists the rows. COLLAPSED by default and after
    /// every emptying (her clutter mandate): a line that reopened itself
    /// expanded would be the persistent panel the ruling forbids.
    private(set) var expanded = false
    /// Rows whose judgment is in flight — their doors grey until the store
    /// answers, so a double click cannot fire one act twice.
    private(set) var judging: Set<String> = []
    /// 13i-c U4: the ownership facts of the LISTED rows' notes (note id →
    /// facts; an ordinary free note is absent — "silence the common case"),
    /// read once per delivered listing, ∝ the listed rows (P1).
    private(set) var facts: [String: Queries.OwnershipFacts] = [:]

    /// 17y B3 (h): whether the masthead door's popover is open — it lists
    /// the rows while it is (the door hosts the observation).
    private(set) var doorOpen = false

    /// How many rows the open line lists (the count is never windowed).
    static let window = 30

    init(session: AppSession, readingID: String) {
        self.session = session
        self.readingID = readingID
    }

    /// What the observation asks for: the count alone while collapsed (the
    /// common occupied state pays for no listing), the window while open.
    var listingLimit: Int { (expanded || doorOpen) ? Self.window : 0 }

    /// The door opened or closed its popover (17y (h)). Unlike `toggle`, it
    /// opens on an EMPTY door too — the calm door answers "nothing waiting".
    func setDoorOpen(_ open: Bool) { doorOpen = open }

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
        judging.formIntersection(value.rows.map(\.id))
        if value.count == 0 { expanded = false }
    }

    /// 13i-c U4: read the listed rows' ownership facts — ONE page-driven
    /// statement (`Queries.ownershipFacts`), so each row draws its arms.
    func loadFacts() async {
        let ids = door.rows.map(\.postID)
        guard !ids.isEmpty else {
            facts = [:]
            return
        }
        facts = (try? await session.database.read { [readingID] db in
            try Queries.ownershipFacts(db, postIDs: ids, inBook: readingID)
        }) ?? [:]
    }

    /// The row's arms, given whether this book owns its notes.
    func arms(for arrival: Queries.BookArrival, bookOwned: Bool) -> ArrivalArms {
        ArrivalArms.of(bookOwned: bookOwned, facts: facts[arrival.postID])
    }

    /// The line's own click: open to the rows, or fold back to the line.
    func toggle() {
        guard ArrivalsLineFace.isShown(door) else { return }
        expanded.toggle()
    }

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
                arrival.title, chaptered: chaptered, archived: arrival.archived))
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
            session.status.receipt(ArrivalsCopy.copiedIn(arrival.title))
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
            session.status.receipt(ArrivalsCopy.movedIn(arrival.title, left: left))
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
            session.status.receipt(ArrivalsCopy.dismissed(arrival.title))
        } catch {
            session.status.refuse(ArrivalsCopy.refusal(
                for: error, book: book?.name, cap: book?.maxPosts,
                sealed: book?.sealedAt != nil))
        }
    }
}

// MARK: - The face

/// **THE ARRIVALS DOOR** (17y B3 item (h) — R-17y-1: "the small icon in the
/// book's mode-row area beside the settings gear — calm when nothing waits,
/// presence when something does"). Drawn on a BOOK's masthead only (a
/// gathering has no door — it holds nothing; P-2). CALM: a faint tray icon,
/// no count. PRESENCE: the accent icon and the count. Its popover lists the
/// waiting rows (`BookArrivalsList`) — her clutter mandate kept: nothing
/// lists until she opens it, and the book's content carries no line at all.
/// It also HOSTS the door's observation (the retired line's job).
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
            model.setDoorOpen(!model.doorOpen)
        } label: {
            HStack(spacing: 2) {
                Image(systemName: "tray.and.arrow.down")
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
        .popover(
            isPresented: Binding(
                get: { model.doorOpen }, set: { model.setDoorOpen($0) }),
            arrowEdge: .bottom
        ) {
            VStack(alignment: .leading, spacing: 8) {
                Text(tokens.chromeLabel(ArrivalsCopy.header(count: model.door.count)))
                    .font(tokens.small.weight(.semibold))
                    .foregroundStyle(tokens.ink)
                    .lineLimit(1)
                if presence {
                    BookArrivalsList(
                        model: model, structure: structure,
                        onOpen: { model.setDoorOpen(false) })
                } else {
                    ChromeNotice(tokens: tokens, text: ArrivalsCopy.nothingWaiting, lines: 3)
                }
            }
            .padding(12)
            // 17y B3 (h) — the walk's W-1: at 460 pt an owned book's row (the
            // "also in …" line, the stamp, three arms) truncated "Copy In" to
            // "copy…" — a door word must never truncate (the arms are
            // fixed-size below; the room is here).
            .frame(width: 600, alignment: .leading)
            .background(tokens.surface)
        }
        // The door's observation — the count always, the rows while open.
        .task(id: model.listingLimit) { await model.start() }
        #if DEBUG
        .onAppear { recordDoor() }
        .onChange(of: model.door) { _, _ in recordDoor() }
        .onChange(of: model.doorOpen) { _, _ in recordDoor() }
        .onDisappear { ArrivalsDoorProbe.forget(model.readingID, owner: probeOwner) }
        #endif
    }

    #if DEBUG
    private func recordDoor() {
        ArrivalsDoorProbe.record(
            model.readingID, owner: probeOwner,
            count: model.door.count, presence: presence, open: model.doorOpen)
    }
    #endif
}

/// **The waiting rows** — the old line's expansion, now the door's popover
/// content (17y (h)). Each row: the note's NAME (a door to the note itself,
/// read-normal — opening never seats), the archived mark, the ownership line,
/// when it arrived, and its judgment arms (data — `ArrivalArms`).
struct BookArrivalsList: View {
    let model: BookArrivalsModel
    let structure: BookStructureModel
    /// Called after a row's name opened its note (the door closes its popover).
    var onOpen: () -> Void = {}

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

    private var tokens: VoiceTokens {
        themeStore?.tokens(for: scheme) ?? .fallback(for: scheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(model.door.rows) { arrival in
                row(arrival)
            }
            let hidden = ArrivalsLineFace.hidden(model.door)
            if hidden > 0 {
                Text(tokens.chromeLabel(ArrivalsCopy.more(hidden)))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
            }
        }
        #if DEBUG
        .onDisappear { ArrivalsLineProbe.forget(model.readingID, owner: probeOwner) }
        #endif
    }

    private func row(_ arrival: Queries.BookArrival) -> some View {
        let busy = model.judging.contains(arrival.id)
        let arms = model.arms(for: arrival, bookOwned: structure.reading?.owned ?? false)
        return HStack(alignment: .firstTextBaseline, spacing: 8) {
            // The note's NAME is her prose, never chrome — no `chromeLabel`
            // (the 13u3 UNIT B lesson: the Terminal voice would lowercase it).
            // 17y (h): it OPENS the note — the ordinary note-open broadcast,
            // read-normal; opening never seats (only Add does).
            Button {
                Self.openNote(arrival.postID)
                onOpen()
            } label: {
                Text(arrival.title)
                    .font(tokens.small)
                    .foregroundStyle(tokens.ink)
                    .underline()
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .buttonStyle(.plain)
            .help(ArrivalsCopy.openHelp)
            // 13i-d U4 (#169(a)(2) — P-13ib-U2-2 reversed): an ARCHIVED
            // waiter stays at the door, marked; the same doors follow.
            if arrival.archived {
                Text(tokens.chromeLabel(ArrivalsCopy.archivedMark))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
                    .fixedSize()
                    .help(ArrivalsCopy.archivedMarkHelp)
            }
            // 13i-c U4 (§18.4): why this row is not an ordinary Add — who owns
            // it, or where else it lives. Book names are hers, never chrome.
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
            Spacer(minLength: 8)
            if let stamp = ArrivalsCopy.arrived(arrival.arrivedAt, now: Date()) {
                Text(tokens.chromeLabel(stamp))
                    .font(tokens.small)
                    .foregroundStyle(tokens.faint)
                    .lineLimit(1)
                    .fixedSize()
            }
            // 13i-c U4: the row's arms are DATA (`ArrivalArms`) — one
            // renderer per act, in the table's order.
            ForEach(arms.acts, id: \.self) { act in
                armButton(act, arrival: arrival)
                    .disabled(busy)
                    // W-1: a door's word is never truncated — the ownership
                    // line yields (it truncates in the middle, whole on hover).
                    .lineLimit(1)
                    .fixedSize()
            }
        }
        #if DEBUG
        .onAppear {
            ArrivalsLineProbe.recordRow(
                model.readingID, owner: probeOwner, arrival.id,
                arms.acts.map(ArrivalArms.verb), archived: arrival.archived)
        }
        .onChange(of: arms) { _, now in
            ArrivalsLineProbe.recordRow(
                model.readingID, owner: probeOwner, arrival.id,
                now.acts.map(ArrivalArms.verb), archived: arrival.archived)
        }
        .onDisappear {
            ArrivalsLineProbe.forgetRow(model.readingID, owner: probeOwner, arrival.id)
        }
        #endif
    }

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
                Task {
                    await model.seat(
                        arrival, book: structure.reading,
                        chaptered: structure.chaptersActive)
                }
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
            .help(ArrivalsCopy.addHelp)
        case .copyIn:
            Button(tokens.chromeLabel(MembershipChoiceCopy.copyInVerb)) {
                Task { await model.copyIn(arrival, book: structure.reading) }
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .primary))
            .help(ArrivalsCopy.copyInHelp)
        case .moveIn:
            Button(tokens.chromeLabel(MembershipChoiceCopy.moveInVerb)) {
                Task { await model.moveIn(arrival, book: structure.reading) }
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .secondary))
            .help(ArrivalsCopy.moveInHelp)
        default:
            Button(tokens.chromeLabel(ArrivalsCopy.dismissVerb)) {
                Task { await model.dismiss(arrival, book: structure.reading) }
            }
            .buttonStyle(VoicedButtonStyle(tokens: tokens, role: .quiet))
            .help(ArrivalsCopy.dismissHelp)
        }
    }
}

#if DEBUG
/// **WHAT THE MOUNTED ROWS DREW, AS A TEST ORACLE** (the `TrayRowDoorProbe`
/// pattern, for its measured reason: a hosted SwiftUI tree exposes no
/// accessibility children in this test host, and a composition dump does not
/// evaluate a `ForEach`'s content). Recorded from each row's own `onAppear`
/// (`BookArrivalsList` — since 17y (h) the masthead door's popover content,
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
    }

    private(set) static var drawn: [String: Drawn] = [:]

    static func reset() { drawn = [:] }

    private static func claim(_ readingID: String, _ owner: UUID) -> Drawn {
        if let entry = drawn[readingID], entry.owner == owner { return entry }
        return Drawn(owner: owner)
    }

    static func recordRow(
        _ readingID: String, owner: UUID, _ rowID: String, _ verbs: [String],
        archived: Bool = false
    ) {
        var entry = claim(readingID, owner)
        entry.rows[rowID] = verbs
        if archived { entry.archivedRows.insert(rowID) } else { entry.archivedRows.remove(rowID) }
        drawn[readingID] = entry
    }

    static func forgetRow(_ readingID: String, owner: UUID, _ rowID: String) {
        guard drawn[readingID]?.owner == owner else { return }
        drawn[readingID]?.rows[rowID] = nil
        drawn[readingID]?.archivedRows.remove(rowID)
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
