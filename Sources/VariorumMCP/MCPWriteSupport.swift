import Foundation
import GRDB
import VariorumCore

/// **WHERE MCP WRITES RUN** (13n-b U2 — the orchestrator's concurrence, AF-8:
/// R-13n-6's letter, "MCP writes ARE ordinary operations"). Every write tool
/// runs its whole body — the per-call decision, the act, the once stamp, the
/// activity line — through ONE serial executor holding the SESSION's
/// `Operations` (and so its `UndoStack`). In the app that executor is the
/// session's `OperationsRunner`, the road her own gestures take: the undo
/// stack's compound collector is single (an MCP compound collecting beside one
/// of her gestures would swallow her entry), and the runner is the
/// serialization the stack requires. Reads never come here — they stay on the
/// reader pool (U1's F3).
public protocol MCPWriteExecutor: Sendable {
    func run<T: Sendable>(_ body: @Sendable (Operations) throws -> T) async throws -> T
}

/// A serial executor for a host with no app around it (tests, a headless
/// host): one body at a time over the given `Operations`.
public actor MCPSerialExecutor: MCPWriteExecutor {
    private let operations: Operations

    public init(operations: Operations) {
        self.operations = operations
    }

    public func run<T: Sendable>(_ body: @Sendable (Operations) throws -> T) throws -> T {
        try body(operations)
    }
}

/// **A JUST-IN-TIME ASK** (AF-6 — the mockup §4 sheet's input): an APPROVED
/// client asked past its grant on a target that EXISTS. The call has already
/// answered (an ask never blocks); this value is the app's to queue — deduped
/// by `id` (client · target · rung) — and to put to her one at a time. Her
/// answer mints a grant through the ordinary ops (rung = `rung`, scope =
/// `scopeKind`/`scopeID`). Never raised for a missing target (no existence
/// oracle), a fenced BOOK (never a grant scope), or a client not approved.
public struct MCPAsk: Sendable, Equatable, Identifiable {
    public let clientName: String
    public let scopeKind: MCPGrantRule.ScopeKind
    public let scopeID: String
    /// The note's title, the book's name, the wing's name.
    public let title: String
    public let rung: MCPGrantRule.Rung
    /// Why it is fenced, when it is (the sheet names the reason).
    public let fence: MCPGrantRule.Fence?

    public init(
        clientName: String, scopeKind: MCPGrantRule.ScopeKind, scopeID: String, title: String,
        rung: MCPGrantRule.Rung, fence: MCPGrantRule.Fence?
    ) {
        self.clientName = clientName
        self.scopeKind = scopeKind
        self.scopeID = scopeID
        self.title = title
        self.rung = rung
        self.fence = fence
    }

    /// A fenced target's ask never offers "always" (R-13n-4; R2-1's fix).
    public var offersAlways: Bool { fence == nil }

    public var id: String {
        [clientName, scopeKind.rawValue, scopeID, rung.rawValue].joined(separator: "\u{1F}")
    }
}

/// **What one landed MCP write did** — the app's receipt is composed from it
/// in the app's own voice (P-13n-1's boundary); a SIGNAL, never a decision
/// (P-4).
public struct MCPWriteReceipt: Sendable, Equatable {
    public let clientName: String
    public let act: Operations.MCPWriteAct
    /// The note (or book) the act landed in, for coalescing a run of acts.
    public let targetID: String?
    /// That note's title / that book's name.
    public let targetTitle: String?
    /// The lens's name, the tag's path, the new book's name.
    public let detail: String?
    /// How many rows the act minted where it is more than one (an imported
    /// book's notes).
    public let count: Int
    /// 13n-b U4 (R-13nb-23 (a), AF-11 F-2): where the receipt's "Open ›"
    /// takes her — the act's landing, a state her own doors reach.
    public var show: MCPShowTarget?
    /// 13n-c U6: how many books a WING MOVE took the note out of (her own
    /// door's receipt says it — "it left 2 books"); nil for every other act.
    public var leftBooks: Int?
    /// **VX-275 — the notes this act left DEAD** (a FACT, never a decision —
    /// P-4): the app posts them on THE ONE navigate-away road
    /// (`.variorumNotesDeleted` → every window's `WorkspaceModel.notesDeleted`),
    /// exactly as her own Delete door posts the notes it tombstoned, so no
    /// pane and no Open row is left standing on a tombstone. Empty for every
    /// act that kills no note.
    public var notesLeftDead: [String]
    /// **VX-812 — the list call this receipt's act belongs to** (A-809-19): one
    /// key for every landed item of ONE list call, so the app's run machinery
    /// coalesces them into one line (its key is `runKey ?? targetID`) and a
    /// later single act never joins them. nil for every single act.
    public var runKey: String?
    /// VX-812: `replace_tag`'s new tag path (`detail` carries the old one).
    public var replacementPath: String?

    public init(
        clientName: String, act: Operations.MCPWriteAct, targetID: String?, targetTitle: String?,
        detail: String? = nil, count: Int = 1, show: MCPShowTarget? = nil, leftBooks: Int? = nil,
        notesLeftDead: [String] = []
    ) {
        self.clientName = clientName
        self.act = act
        self.targetID = targetID
        self.targetTitle = targetTitle
        self.detail = detail
        self.count = count
        self.show = show
        self.leftBooks = leftBooks
        self.notesLeftDead = notesLeftDead
    }
}

/// **VX-775 — a landed act whose Activity line could not be written** (her
/// ruling at the #267 sitting: "the error goes to her, the truth goes to the
/// client"; this run's kickoff: a REFUSAL-kind line on her status seam). The
/// act is in her store and its client was answered the act's own answer; only
/// the log's write failed — this value says so to the APP, never on the wire
/// (R-825: an answer is a pure function of the client's reachable state). A
/// SIGNAL (P-4); the app composes her words from it.
public struct MCPActivityLogFailure: Sendable, Equatable {
    public let clientName: String
    /// The tool the client called (a list call's tool, once).
    public let tool: String
    /// How many of the call's landed acts lack their Activity line — one for a
    /// single act; a list call's items coalesce into one value.
    public let unrecorded: Int
    /// The store's own words in VX-369's form — SQLite's code and its message
    /// ("SQLite error 13: database or disk is full"), never the executed SQL;
    /// "the library is locked" for the lock; nil where the store says nothing
    /// safe to show (a keyed connection's redacted error).
    public let storeWords: String?

    public init(clientName: String, tool: String, unrecorded: Int, storeWords: String?) {
        self.clientName = clientName
        self.tool = tool
        self.unrecorded = unrecorded
        self.storeWords = storeWords
    }
}

/// The host's seams to the app around it — set before `start()`.
public struct MCPHostHooks: Sendable {
    /// The operations layer's refusal in the app's own words (the Mac's
    /// `OpsRefusalCopy`) — "every refusal speaks to the client exactly as it
    /// speaks to her". Nil words fall back to the error's description.
    public var refusalWords: @Sendable (Error) -> String?
    /// A just-in-time ask to put to her (AF-6).
    public var onAsk: (@Sendable (MCPAsk) -> Void)?
    /// A write landed (the receipt's signal).
    public var onWrite: (@Sendable (MCPWriteReceipt) -> Void)?
    /// 13n-b U4: the clock the tray's 30-day window reads (the app's is the
    /// wall clock; a test's is its world's).
    public var now: @Sendable () -> Date
    /// 13n-b U4 (AF-11 F-3): `show_in_app`'s delivery. The app reads where it
    /// stands ON THE MAIN ACTOR, asks `MCPShowRule.verdict` with the request's
    /// dial, delivers ONLY on `.navigate` (in that same hop — nothing can move
    /// between the look and the move), OFFERS on `.offer` (VX-676 — on her
    /// status seam, never raising a window), and answers the verdict it
    /// applied. Nil = no app around the host (a headless host shows nothing).
    public var show: (@Sendable (MCPShowRequest) async -> MCPShowRule.Verdict)?
    /// 13n-c U6: her Move to Wing door's OWN sentence for a note held by a
    /// finished or sealed book (`WingCopy.frozen(title, book:)` on the Mac —
    /// the mockup §9's "in her own words"), so `move_note_to_wing` refuses
    /// exactly as her door does. Spoken only where the client can READ that
    /// book (names stay with grants — AF-10 (f)); otherwise, and with no app
    /// around the host, the op's own refusal speaks through `refusalWords`.
    public var wingMoveFrozenWords: (@Sendable (_ noteTitle: String, _ bookName: String) -> String)?
    /// VX-807 (the VX-809 run, batch 2): her Move to Wing ▸ door's OWN sentence
    /// for a BOOK whose member is also in a finished or sealed book that stays
    /// behind (`WingCopy.bookFrozen` on the Mac), so `move_book_to_wing`
    /// refuses exactly as her door does — spoken only where the client can READ
    /// both that note and that book (A-809-4); otherwise the book move's one
    /// hidden-cause sentence, and with no app around the host the op's own
    /// refusal through `refusalWords`.
    public var bookMoveFrozenWords: (@Sendable (_ bookName: String, _ noteTitle: String, _ frozenBook: String) -> String)?
    /// **VX-275 — HER EDITOR FIRST** (her ruling (a), 2026-10-13: before a
    /// wire delete lands, the app saves what she has typed, exactly as her
    /// own Delete door does). Awaited by `MCPWriteTools.call` AFTER the
    /// arguments parse and BEFORE the act's turn on the executor — its own
    /// turn, never inside the act's — for every act that tombstones,
    /// freezes, rewrites, restructures or copies a take her open editor may
    /// hold unflushed (`MCPWriteTools.Job.flushesHerEditorFirst`, argued in
    /// the VX-246 record's U3 trace). The app's answer is her own flush (the
    /// Mac's `AppSession.flushEveryOpenPost`); its outcome is not consulted —
    /// a refused write keeps its bytes pending, as her Delete door's does —
    /// and the act lands after it. `tool` is the act's tool name. Nil = no
    /// app around the host (a headless host has no editor to flush).
    public var beforeWrite: (@Sendable (_ tool: String) async -> Void)?
    /// **VX-775 — a landed act's Activity line could not be written**: the
    /// call answered its client the act's own answer, and THIS tells her
    /// (`MCPActivityLogFailure`). Called by `MCPWriteTools.call` once per call.
    /// **It carries the call's receipts too** (the VX-913 ladder round 1, F1 —
    /// the reviewer's final call): when it is set and the call's line failed,
    /// the call's receipts ride THIS hook and never also `onWrite`, so the app
    /// lands them and then the failure in ONE hop — her status seam holds one
    /// message, and a receipt landing after the failure would erase it. A call
    /// whose lines landed, and a host without this hook, send their receipts
    /// through `onWrite` exactly as before. A no-op landing hands `[]`. Nil = no
    /// app around the host.
    public var onActivityLogFailure: (@Sendable (MCPActivityLogFailure, _ receipts: [MCPWriteReceipt]) -> Void)?

    public init(
        refusalWords: @escaping @Sendable (Error) -> String? = { _ in nil },
        onAsk: (@Sendable (MCPAsk) -> Void)? = nil,
        onWrite: (@Sendable (MCPWriteReceipt) -> Void)? = nil,
        now: @escaping @Sendable () -> Date = { Date() },
        show: (@Sendable (MCPShowRequest) async -> MCPShowRule.Verdict)? = nil,
        wingMoveFrozenWords: (@Sendable (_ noteTitle: String, _ bookName: String) -> String)? = nil,
        beforeWrite: (@Sendable (_ tool: String) async -> Void)? = nil,
        bookMoveFrozenWords: (@Sendable (_ bookName: String, _ noteTitle: String, _ frozenBook: String) -> String)? = nil,
        onActivityLogFailure: (@Sendable (MCPActivityLogFailure, _ receipts: [MCPWriteReceipt]) -> Void)? = nil
    ) {
        self.refusalWords = refusalWords
        self.onAsk = onAsk
        self.onWrite = onWrite
        self.now = now
        self.show = show
        self.wingMoveFrozenWords = wingMoveFrozenWords
        self.beforeWrite = beforeWrite
        self.bookMoveFrozenWords = bookMoveFrozenWords
        self.onActivityLogFailure = onActivityLogFailure
    }
}

/// **A STORE FAILURE's own words, named once** (VX-369's three store types —
/// the VX-771 run's SWEEP TABLE, rows 1, 3 and 4's lock road): SQLite's code
/// and its message for GRDB's `DatabaseError` (never the executed SQL its
/// description carries); nothing for a keyed connection's redacted error; the
/// lock's detail for a call the lock overtook. The wire's chain words them
/// (`MCPWireRefusalCopy.words`); VX-775's signal to her carries the same
/// detail (`MCPActivityLogFailure.storeWords`). No value for any error that is
/// not a store failure.
struct MCPStoreFailure: Equatable {
    let detail: String?

    init?(_ error: Error) {
        if let failure = error as? DatabaseError {
            detail = "SQLite error \(failure.resultCode.rawValue)" + (failure.message.map { ": \($0)" } ?? "")
        } else if error is RedactedKeyedStatementError {
            detail = nil
        } else if error is StoreLockedError {
            // VX-818 (A-809-20): an act may have landed before a later write of
            // the same call — never "ask again".
            detail = MCPLockedLibrary.overtakenDetail
        } else {
            return nil
        }
    }
}

/// An answer that could not be written as JSON (13n-b U4 — the guard in
/// front of `JSONSerialization`, whose failure is an uncatchable exception).
struct MCPAnswerEncodingFailure: Error, CustomStringConvertible {
    var description: String { "the answer could not be encoded" }
}

/// **The op refusals only the WIRE can meet, in words** (13n-b U4): errors
/// whose doors exist only on the connected road — an address a client typed
/// (a chapter id, a tag path, a note that is not in the book) — said in the
/// MCP room's technical register (P-13n-1) instead of the raw enum the app's
/// table would fall back to (the J8 class). The op still decides; this only
/// words it. Nil = the app's own table speaks (`MCPHostHooks.refusalWords`).
enum MCPWireRefusalCopy {
    /// **THE WIRE'S ONE REFUSAL CHAIN** (VX-362 — the VX-336 run record's U9,
    /// piece 1; named once so the door and its sweep pin read the same road):
    /// the wire's own words first, then the app's table (`appWords` — the
    /// host's `MCPHostHooks.refusalWords`; the Mac's `OpsRefusalCopy`), then
    /// the error's description. `MCPWriteTools.land` (every write act) and
    /// `itemized` (a batch's item) speak through it.
    static func spoken(_ error: Error, appWords: (Error) -> String?) -> String {
        words(error) ?? appWords(error) ?? String(describing: error)
    }

    /// **A call's error that left its tool's body** (VX-369 — the VX-771 run's
    /// SWEEP TABLE): each tool family's catch-all (`MCPWriteTools.call`,
    /// `MCPReadTools.call`, `MCPShowTool.call`) speaks through THE ONE CHAIN —
    /// the wire's words alone where it has them, otherwise the family's own
    /// "Variorum couldn't complete ‹tool›:" before the app's words or, last,
    /// the description. It used to interpolate the raw error: a store failure
    /// in a refusal's own log write reached the client as GRDB's text.
    static func unexpected(_ error: Error, tool: String, appWords: (Error) -> String?) -> String {
        words(error) ?? "Variorum couldn't complete \(tool): \(appWords(error) ?? String(describing: error))"
    }

    /// **A STORE FAILURE, said** (VX-369 — PROVISIONAL P-771-11): the store
    /// refused the work under the call — a full disk, a read-only volume, an
    /// I/O error, a keyed connection that would not open. SQLite's code and its
    /// own message, never the executed SQL GRDB's description carries; and no
    /// claim about what landed, because a failure in the refusal's own log
    /// write can follow an act that did.
    static func storeFailureWords(_ detail: String?) -> String {
        "Variorum's library store refused the work" + (detail.map { " (\($0))" } ?? "")
            + ", so this call may not have landed — read what it touches before trying again."
    }

    /// R-805-5 — the move fence's sentence (P-805-B5).
    static let dailyJournalMoveWords =
        "The daily Journal can't be moved to another wing over this connection \u{2014} only the "
        + "author moves it, in Variorum."

    /// R-805-5's sibling — the delete fence's sentence (MCPSpec: "the daily
    /// Journal never deletes" on the wire; P-805-B5).
    static let dailyJournalDeleteWords =
        "The daily Journal can't be deleted over this connection \u{2014} only the author deletes "
        + "it, in Variorum. archive_book puts it away; it comes back when a day arrives."

    static func words(_ error: Error) -> String? {
        // VX-396 (the VX-912 run, B4): an identifier holding U+0000 — the
        // door's own parse refusal (a client name at naming, an id at the call
        // door), worded once in its type.
        if let null = error as? MCPNullIdentifier { return null.words }
        // VX-369: a store failure (GRDB's `DatabaseError`; a keyed store's
        // sanitized connection error) — the one non-`OperationError` class the
        // sweep found reachable on the wire — and VX-818 (the VX-809 run,
        // A-809-20): a call the LOCK overtook — past the call door when the
        // store shut, so a read or write met the typed refusal. The
        // store-failure sentence's honest form for all three, never "ask
        // again": an act may have landed before a later write of the same
        // call. Their words are named once (`MCPStoreFailure` — VX-775 reads
        // the same detail for her).
        if let store = MCPStoreFailure(error) { return storeFailureWords(store.detail) }
        // VX-760 (the VX-771 run, batch 2): edit_take's mismatch, said as the
        // fact pattern its door PROVED from the sent and stored texts — the
        // door's richer answer, first in the chain (the app's table would read
        // every mismatch as a race with the author).
        if let mismatch = error as? MCPExpectedTextMismatch { return mismatch.words }
        // VX-761: edit_take's replace form — the passage's count, or the blank
        // result (never an `OperationError`: no door of hers replaces a passage).
        if let refusal = error as? Operations.MCPTakeReplacementRefusal {
            return MCPWriteTools.replacementWords(refusal)
        }
        guard let error = error as? OperationError else { return nil }
        switch error {
        case .postNotInReading:
            return "That note isn't in this book — add it first (add_note_to_book), then file it."
        case .sectionNotFound, .sectionNotInReading:
            return "section_id isn't a chapter of this book (list_notes or create_section gives chapter ids)."
        case .invalidTagName(let name):
            return "\u{201C}\(name)\u{201D} isn't a tag path — a path is names joined by /, e.g. \"percy/pt-en\"."
        // VX-362 (the run record's U9 SWEEP TABLE, the E/belt row): the wire
        // parses `entry_date` with its own formatter and the op checks it with
        // `JournalDay.isValid` — two validators are not one, so should the op
        // ever refuse a day the parse passed, the client hears the parse's own
        // sentence. Only a client types this field.
        case .invalidEntryDate:
            return MCPWriteTools.entryDateWords
        // VX-549 — a new note written INTO a gathering its rule can't take
        // (`create_note` / `import_document` with a gathering's id): her own
        // door's sentence, word for word (`GatheringMint.Blocker.reason` — R-13n-4,
        // "refusals speak to the client exactly as they speak to you"), e.g.
        // "Its rule can't match a new note." or "Archived — unarchive it to add
        // notes." (VX-596 retired the star refusal: the wire stars such a note.)
        // A client meets it only on a gathering it can write into (decided
        // first), so it is never the not-shared shape and tells nothing hidden.
        case .smartFilterUnsatisfiable(_, let reason):
            return reason
        // R-805-5 (the VX-805 run) — THE WIRE'S JOURNAL FENCE: her own doors
        // move and delete the daily Journal like any book since VX-435/436,
        // so these two refusals are the WIRE's alone now
        // (`Operations.refuseMovingTheDailyJournalOnTheWire` /
        // `refuseDeletingTheDailyJournalOnTheWire`) and are worded here, in
        // the room's register — the app's table keeps no sentence a door of
        // hers could meet. Wording PROVISIONAL (P-805-B5).
        case .dailyJournalMovesOnlyByHand:
            return Self.dailyJournalMoveWords
        case .dailyJournalCannotBeDeleted:
            return Self.dailyJournalDeleteWords
        default:
            return nil
        }
    }
}
