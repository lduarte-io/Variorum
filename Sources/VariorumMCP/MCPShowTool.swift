import Foundation
import GRDB
import MCP
import VariorumCore

/// **WHERE `show_in_app` (and a receipt's "Open ›") takes her** (13n-b U4 —
/// R-13nb-23 + R-13nb-26 (g), AF-11 F-3): the v1 targets, each a state her own
/// doors reach (the ceiling rule) — a note (at a block, with words selected
/// and the find bar armed: the 13o landing road verbatim), a note's Takes at
/// a block (her "see takes" road), a saved lens on the Lenses board, a book
/// (at a chapter: Outline's chapter landing). A SIGNAL value carrying no
/// decision (P-4): the app's delivery performs it through those roads.
public enum MCPShowTarget: Sendable, Equatable {
    case note(noteID: String, blockID: String?, select: String?)
    case takes(noteID: String, blockID: String)
    case lens(noteID: String, lensID: String)
    case book(bookID: String, sectionID: String?)
    /// 13n-c U6 (VX-158 — the brief §8's A, mockup §7): the app's ONE wing,
    /// switched as her own switcher switches it — carrying the wing's name and
    /// the client's, so the receipt can say who moved her ("Now in “X” —
    /// claude-code showed you this wing."). `wingID` '' is Home.
    case wing(wingID: String, name: String, shownBy: String)
    /// VX-336 U6a (VX-298 — her answers 2026-10-13): her Compare with `noteID`
    /// as the first column and each of `peerIDs` (one to three, in column order)
    /// beside it, REPLACING the columns open (answer (4)). Any notes her picker
    /// would offer — no link required (1). A SIGNAL with no posture (P-4): the
    /// board decides "related blocks only" from its own projection (F-8 (a)).
    case compare(noteID: String, peerIDs: [String])
    /// **VX-675 (#249's open item, her word 2026-10-28):** one of `noteID`'s
    /// SAVED VERSIONS, full size — the VX-440 page (R-440-2: the identity band
    /// "A saved version of ‹title› · ‹date›", Back to the note · Promote;
    /// read-only, opening at its start, no per-note memory written — P-440-1).
    /// `read_note`'s own pair (`note_id` + `version_id`), so the decision is
    /// the NOTE's read decision, as `read_note`'s version road is.
    case version(noteID: String, versionID: String)
}

/// **One `show_in_app` call, as the app is handed it** (VX-676): the target,
/// who asked, the titles the decision read (so the ask can say what it would
/// show, and Activity can log her take on the row the ask was logged on), and
/// the dial the store held in the decision's own read. A SIGNAL with no
/// decision (P-4): the app applies `MCPShowRule` to it, on the main actor, in
/// the hop that would move anything.
public struct MCPShowRequest: Sendable, Equatable {
    public let target: MCPShowTarget
    public let clientName: String
    /// The title the decision read for the target's place — the note's (for a
    /// version, its note's; for compare, the anchor's), the book's, the wing's;
    /// nil when none resolved.
    public let title: String?
    /// Compare's peers' titles, in column order (empty for every other target).
    public let peerTitles: [String?]
    /// How the author set `show_in_app` to land (Settings ▸ MCP), read with the
    /// decision.
    public let dial: MCPShowDial
    /// The Activity row's target the call was logged on — her take of an ask
    /// is logged on the same one.
    public let activityKind: String
    public let activityID: String

    public init(
        target: MCPShowTarget, clientName: String, title: String? = nil, peerTitles: [String?] = [],
        dial: MCPShowDial, activityKind: String = "note", activityID: String = ""
    ) {
        self.target = target
        self.clientName = clientName
        self.title = title
        self.peerTitles = peerTitles
        self.dial = dial
        self.activityKind = activityKind
        self.activityID = activityID
    }
}

/// **HOW A SHOW LANDS — her law, as one pure decision** (R-13nb-23's etiquette,
/// her words: *"moving should not be done while you aren't at the app, should
/// not be done automatically"*; AF-11 F-3 — AMENDED by VX-676, her sitting and
/// her mid-run ruling of 2026-10-28). The app reads where it stands — ON THE
/// MAIN ACTOR, in the same hop as any delivery — and asks this with the dial;
/// only `.navigate` may move anything, and nothing ever raises a window.
///
/// - **never** — nothing is shown or offered (the call answers in words).
/// - **ask** (the default) — OFFERED on her status seam: the toast at its full
///   prominence, then the standing quiet line, taken by her one press.
/// - **move at once** — moves her view ONLY while Variorum is in front in a
///   full window; anywhere else it is the ask. The frontmost-only REFUSAL is
///   retired into the ask (her amendment), and a background arrival is the ask
///   under every dial value but never — RATIFIED: *"I agree with doing the ask,
///   even if you've approved auto move. if you've been out of the screen it
///   would be weird to suddenly be looking at something new."*
public enum MCPShowRule {
    /// Where the app stands at the moment of the call.
    public enum Standing: Sendable, Equatable {
        /// Variorum is the frontmost app AND its key window is a FULL window
        /// (the only window kind that navigates).
        case frontmostMainWindow
        /// Variorum is frontmost but its key window is a note-only or quick-
        /// note window — moving would mean raising ANOTHER window, which her
        /// etiquette rules out, so it is the ask.
        case frontmostOtherWindow
        /// Another app is frontmost (or Variorum has no window at all): the ask.
        case notFrontmost
    }

    /// What the app DID with the call — the answer the wire speaks.
    public enum Verdict: Sendable, Equatable {
        /// Her view moved.
        case navigate
        /// It is offered on her status seam; nothing moved.
        case offer
        /// Nothing was shown or offered, and this says why.
        case refuse(String)
    }

    public static func verdict(_ standing: Standing, dial: MCPShowDial) -> Verdict {
        switch dial {
        case .never: .refuse(neverWords)
        case .ask: .offer
        case .moveAtOnce: standing == .frontmostMainWindow ? .navigate : .offer
        }
    }

    // The words (technical register — the MCP room's, P-13n-1; PROVISIONAL,
    // her copy pass — VX-234).

    /// VX-676 ruling (4) — the offered answer's words: answered at once,
    /// fire-and-forget, nothing told later.
    public static let offeredWords =
        "Offered \u{2014} the author can open it with one press, whenever they like. Nothing moved, "
        + "and nothing follows when they open it."
    /// VX-676 — the never dial's answer (PROVISIONAL P-676-2).
    public static let neverWords =
        "The author has set Variorum never to show things for an AI (Settings \u{25B8} MCP), so nothing "
        + "was shown or offered \u{2014} tell them where it is instead."
    public static let unavailableWords =
        "This Variorum can't show things \u{2014} there is no app window to move."
    /// Ladder round 1, F-4: a delivery that could not FINISH while she was at
    /// the app (the note opened but the takes/lens/compare landing never
    /// arrived) answers honestly instead of claiming shown. VX-676: no longer
    /// coaches "while the author is at the app" (her amendment — a call again
    /// is offered, never raced); a delivery she LEFT mid-way lands as the ask.
    public static let partialShowWords =
        "Variorum opened the note, but the rest of the show didn't land \u{2014} nothing more was moved."
}

/// **`show_in_app`** — the READ rung's one navigation tool (AF-11 F-3):
/// decided at READ on the TARGET (a client shows only what it may read),
/// never spending a once grant (a show discloses and changes nothing), then
/// handed to the app's `show` hook as an `MCPShowRequest` carrying the dial
/// read in the SAME read — the app applies `MCPShowRule` on the main actor,
/// moves only on `.navigate`, offers on `.offer`. A target the client cannot
/// read answers the ONE `notShared` (no existence oracle); an address that
/// does not belong to its note (a block, a lens, a chapter) answers after the
/// decision, so it discloses nothing the client could not already read — and
/// a `version_id` that is not one of the note's saved versions answers the ONE
/// not-shared shape too (VX-675: hidden = missing, no version-existence oracle).
///
/// **VX-676 ruling (4) — answered at once, fire-and-forget:** `{"shown": true}`
/// when her view moved, `{"offered": true, "shown": false, "landed": …}` when it
/// is offered — and nothing ever follows (no callback on a later take). The ask
/// is logged as its own Activity row (`MCPShowActivity.offeredAct`); a move
/// keeps `show_in_app`'s row; her take is the app's to log.
struct MCPShowTool: Sendable {
    let database: AppDatabase
    let operations: Operations
    var hooks = MCPHostHooks()
    var calendar: Calendar = JournalDay.storeCalendar

    typealias Outcome = MCPReadTools.Outcome
    typealias ArgumentFailure = MCPReadTools.ArgumentFailure

    static let handledToolNames: Set<String> = [MCPToolCatalog.showInApp.name]

    func call(_ name: String, arguments: [String: Value]?, clientName: String) async -> Outcome {
        let args = arguments ?? [:]
        do {
            let parsed = try parse(args)
            // VX-676: the dial is read in the decision's own read — the store's
            // truth at wire time, handed to the app with the call.
            let (decided, dial) = try await database.read { db in
                (try decide(db, parsed, clientName: clientName), try Queries.mcpShowDial(db))
            }
            var target = parsed
            // The wing's name and who asked ride the target (the decision
            // read the name; the client is this session's).
            if case .wing(let wingID, _, _) = target, case .allowed(_, _, let title, _) = decided {
                target = .wing(wingID: wingID, name: title ?? Queries.mcpHomeWingName, shownBy: clientName)
            }
            switch decided {
            case .refused(let outcome, let kind, let id, let title):
                try log(clientName, kind, id, title, allowed: false)
                return outcome
            case .allowed(let kind, let id, let title, let peerTitles):
                guard let show = hooks.show else {
                    try log(clientName, kind, id, title, allowed: false)
                    return Outcome(text: MCPShowRule.unavailableWords, isError: true)
                }
                let request = MCPShowRequest(
                    target: target, clientName: clientName, title: title, peerTitles: peerTitles, dial: dial,
                    activityKind: kind, activityID: id)
                switch await show(request) {
                case .navigate:
                    try log(clientName, kind, id, title, allowed: true)
                    return Outcome(text: try encode(["shown": true]), isError: false)
                case .offer:
                    // VX-676 (4): the ask is its own Activity row — the client's
                    // call, allowed, nothing moved — and the answer is at once.
                    try log(clientName, kind, id, title, allowed: true, act: MCPShowActivity.offeredAct)
                    return Outcome(
                        text: try encode(["shown": false, "offered": true, "landed": MCPShowRule.offeredWords]),
                        isError: false)
                case .refuse(let words):
                    try log(clientName, kind, id, title, allowed: false)
                    return Outcome(text: words, isError: true)
                }
            }
        } catch let failure as ArgumentFailure {
            return Outcome(text: failure.message, isError: true)
        } catch {
            return Outcome(text: "Variorum couldn't complete \(name): \(error)", isError: true)
        }
    }

    // MARK: - Arguments

    private func parse(_ args: [String: Value]) throws -> MCPShowTarget {
        func string(_ key: String) throws -> String? {
            guard let value = args[key], value != .null else { return nil }
            guard let text = value.stringValue, !text.isEmpty else {
                throw ArgumentFailure(message: "\(key) must be a non-empty string.")
            }
            return text
        }
        let target = try string("target") ?? "note"
        // VX-675: a saved version is its own target — `version_id` with any other
        // (the default note included) would silently show the live note, so it
        // refuses here, before any read (independent of any target — no oracle).
        if target != "version", let value = args["version_id"], value != .null {
            throw ArgumentFailure(message: Self.versionNeedsItsTargetWords)
        }
        switch target {
        case "note":
            guard let note = try string("note_id") else { throw ArgumentFailure(message: "note_id is required.") }
            let select = try string("select")
            let block = try string("block_id")
            if select != nil, block == nil {
                throw ArgumentFailure(message: "select goes with block_id (the words are found from that block on).")
            }
            return .note(noteID: note, blockID: block, select: select)
        case "takes":
            guard let note = try string("note_id"), let block = try string("block_id") else {
                throw ArgumentFailure(message: "target takes needs note_id and block_id.")
            }
            return .takes(noteID: note, blockID: block)
        case "lens":
            guard let note = try string("note_id"), let lens = try string("lens_id") else {
                throw ArgumentFailure(message: "target lens needs note_id and lens_id.")
            }
            return .lens(noteID: note, lensID: lens)
        case "book":
            guard let book = try string("book_id") else { throw ArgumentFailure(message: "target book needs book_id.") }
            return .book(bookID: book, sectionID: try string("section_id"))
        case "wing":
            // "" is Home — the one legal empty id, so not `string(_:)`.
            guard let value = args["wing_id"], value != .null, let wing = value.stringValue else {
                throw ArgumentFailure(message: "target wing needs wing_id (\"\" is Home).")
            }
            return .wing(wingID: wing, name: "", shownBy: "")
        case "compare":
            return try parseCompare(args, string)
        case "version":
            // VX-675: `read_note`'s own pair — the note, and one of its saved
            // versions (its `with_versions` lists them).
            guard let note = try string("note_id"), let version = try string("version_id") else {
                throw ArgumentFailure(message: Self.versionNeedsWords)
            }
            return .version(noteID: note, versionID: version)
        default:
            throw ArgumentFailure(
                message: "target must be \"note\", \"takes\", \"lens\", \"book\", \"wing\", \"compare\" or \"version\".")
        }
    }

    // The version target's words (the MCP room's technical register, P-13n-1;
    // PROVISIONAL, her copy pass — VX-234).
    static let versionNeedsWords =
        "target version needs note_id and version_id (read_note's with_versions lists a note's saved versions)."
    static let versionNeedsItsTargetWords =
        "version_id goes with target \"version\" (note_id + version_id: that saved version, full size)."

    /// VX-298 (P-VX298-3, F-6 (a)): `note_id` + `peer_ids` — one to three OTHER
    /// notes (her board holds four columns, `addPeerSlot`'s cap), in column
    /// order. Every malformed form refuses here, before any read, naming what is
    /// wrong (independent of any target — no oracle).
    private func parseCompare(_ args: [String: Value], _ string: (String) throws -> String?) throws -> MCPShowTarget {
        guard let note = try string("note_id"), let value = args["peer_ids"], value != .null else {
            throw ArgumentFailure(message: Self.compareNeedsWords)
        }
        guard let items = value.arrayValue else { throw ArgumentFailure(message: "peer_ids must be an array of note ids.") }
        guard (1...Self.comparePeerCap).contains(items.count) else { throw ArgumentFailure(message: Self.comparePeerCountWords) }
        let peers = try items.map { item -> String in
            guard let id = item.stringValue, !id.isEmpty else {
                throw ArgumentFailure(message: "peer_ids must hold note ids (strings).")
            }
            return id
        }
        guard Set(peers).count == peers.count else { throw ArgumentFailure(message: "peer_ids names a note twice.") }
        guard !peers.contains(note) else {
            throw ArgumentFailure(message: "peer_ids can't include note_id \u{2014} it is the first column already.")
        }
        return .compare(noteID: note, peerIDs: peers)
    }

    /// Her board's peer columns beside the anchor (`CompareViewModel.addPeerSlot`).
    static let comparePeerCap = 3

    // The compare target's words (the MCP room's technical register, P-13n-1;
    // PROVISIONAL, her copy pass — VX-234).
    static let compareNeedsWords = "target compare needs note_id and peer_ids (one to three other notes)."
    static let comparePeerCountWords =
        "peer_ids must name one to three other notes \u{2014} Compare shows a note and up to three beside it."
    static let compareDifferentWingsWords =
        "Those notes are in different wings \u{2014} each wing is a separate library, so Compare can't show them "
        + "side by side."
    static func compareArchivedWords(_ title: String?) -> String {
        "\(title.map { "\u{201C}\($0)\u{201D}" } ?? "That note") is archived \u{2014} Compare offers only notes in "
            + "the library (unarchive_note first)."
    }

    // MARK: - The decision (read, on the target, never spending)

    private enum Decided {
        /// `peerTitles`: compare's peers, in column order (empty otherwise).
        case allowed(kind: String, id: String, title: String?, peerTitles: [String?] = [])
        case refused(Outcome, kind: String, id: String, title: String?)
    }

    private func decide(_ db: Database, _ target: MCPShowTarget, clientName: String) throws -> Decided {
        let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
        switch target {
        case .note(let noteID, _, _), .takes(let noteID, _), .lens(let noteID, _):
            return try decideNote(db, target, noteID: noteID, standing: standing)
        case .version(let noteID, let versionID):
            // VX-675: the NOTE's read decision (a saved version is that note's
            // past — the note is the disclosure unit, R-13nb-12; `read_note`'s
            // `version_id` road decides exactly so), never spending. Only once
            // the note is allowed is the version asked — and an id that is not
            // one of THIS note's saved versions (nothing, a live note, another
            // note's version, a promoted or deleted one) answers the ONE
            // not-shared shape, decided over no facts: byte-identical to an
            // unreadable note's answer (hidden = missing; `read_note`'s lens_id
            // precedent), logged refused on the note.
            let decided = try decideNote(db, target, noteID: noteID, standing: standing)
            guard case .allowed(_, _, let title, _) = decided else { return decided }
            guard try Queries.isVersionHistory(db, versionID, of: noteID) else {
                let none = MCPGrantAuthority.decide(standing, note: nil, rung: .read, consumes: false)
                return .refused(refusal(none, .note), kind: "note", id: noteID, title: title)
            }
            return decided
        case .compare(let noteID, let peerIDs):
            return try decideCompare(db, noteID: noteID, peerIDs: peerIDs, standing: standing)
        case .book(let bookID, let sectionID):
            // 13n-c VX-273: a book OR a gathering (read facts under
            // wing-level reach — her doors open one like a book; it has no
            // chapters, so a section_id answers as a stranger's).
            let place = try MCPGrantAuthority.readPlace(db, readingID: bookID)
            let facts = place.facts
            let title = facts == nil ? nil : try Queries.mcpScopeTitle(db, kind: .book, id: bookID, calendar: calendar)
            let decision = MCPGrantAuthority.decide(standing, reading: place)
            guard decision.isAllowed else {
                return .refused(refusal(decision, .book), kind: "book", id: bookID, title: title)
            }
            if let sectionID, try String.fetchOne(
                db, sql: "SELECT id FROM reading_section WHERE id = ? AND reading_id = ? AND deleted_at IS NULL",
                arguments: [sectionID, bookID]) == nil {
                return .refused(Outcome(text: "section_id isn't a chapter of this book.", isError: true),
                                kind: "book", id: bookID, title: title)
            }
            return .allowed(kind: "book", id: bookID, title: title)
        case .wing(let wingID, _, _):
            // 13n-c U6 (VX-158): decided at READ on the wing with WING-LEVEL
            // reach (`decideWing` — a wing grant on it, or the open book),
            // never spending. A wing that is not live answers the one answer
            // after an allowed decision (the decision already implied reach,
            // so the answer discloses nothing).
            let title = try Queries.mcpScopeTitle(db, kind: .wing, id: wingID, calendar: calendar)
            let decision = MCPGrantAuthority.decideWing(standing, wingID: wingID, rung: .read)
            guard decision.isAllowed, title != nil else {
                return .refused(refusal(decision.isAllowed ? .ask(.notShared, offersAlways: true) : decision, .wing),
                                kind: "wing", id: wingID, title: title)
            }
            return .allowed(kind: "wing", id: wingID, title: title)
        }
    }

    private func decideNote(
        _ db: Database, _ target: MCPShowTarget, noteID: String, standing: MCPGrantAuthority.Standing
    ) throws -> Decided {
        let facts = try Queries.mcpNoteFacts(db, noteID: noteID)
        let title = facts == nil ? nil : try Queries.mcpScopeTitle(db, kind: .note, id: noteID, calendar: calendar)
        let decision = MCPGrantAuthority.decide(standing, note: facts, rung: .read, consumes: false)
        guard decision.isAllowed else {
            return .refused(refusal(decision, .note), kind: "note", id: noteID, title: title)
        }
        let misaddressed: String? = switch target {
        case .note(_, let blockID?, _), .takes(_, let blockID):
            try Queries.mcpContainerOf(block: blockID, db) == noteID ? nil : "block_id isn't a block of this note."
        case .lens(_, let lensID):
            try Queries.lens(db, id: lensID)?.containerId == noteID ? nil : "lens_id isn't a lens of this note."
        default:
            nil
        }
        if let misaddressed {
            return .refused(Outcome(text: misaddressed, isError: true), kind: "note", id: noteID, title: title)
        }
        return .allowed(kind: "note", id: noteID, title: title)
    }

    /// **VX-298 — the compare target's decision (D-298-2), on ONE read, never
    /// spending.** Every note at READ in column order — the anchor, then each
    /// peer — and the FIRST refusal answers with that note's refusal: the ONE
    /// not-shared shape for anything unreachable (a version, a scraps group, a
    /// stranger's id), byte-identical to an id naming nothing, logged on THAT
    /// note (`link_versions`' order; no ask — `show_in_app`'s own road). Only
    /// after every note is decided (so nothing is told about a note the client
    /// can't read): (1) the SAME WING — every peer's resolved wing equal to the
    /// anchor's, else one sentence; (2) only notes HER PICKER would offer
    /// (`Queries.notePickerNotes`' WHERE: a live, non-archived post of the
    /// anchor's wing, not the anchor) — an ARCHIVED peer refuses; the anchor may
    /// be archived (she can open one and press ⌘5 — P-VX298-2, F-7 (a)). Both
    /// logged on the refusing peer; an allowed show on the anchor. Cost ∝ the
    /// named notes (≤ 4 facts reads + one archived read), never the corpus.
    private func decideCompare(
        _ db: Database, noteID: String, peerIDs: [String], standing: MCPGrantAuthority.Standing
    ) throws -> Decided {
        var wings: [String: String] = [:]
        var titles: [String: String] = [:]
        for id in [noteID] + peerIDs {
            let facts = try Queries.mcpNoteFacts(db, noteID: id)
            let title = facts == nil ? nil : try Queries.mcpScopeTitle(db, kind: .note, id: id, calendar: calendar)
            let decision = MCPGrantAuthority.decide(standing, note: facts, rung: .read, consumes: false)
            guard decision.isAllowed, let facts else {
                return .refused(refusal(decision, .note), kind: "note", id: id, title: title)
            }
            wings[id] = facts.wingID
            titles[id] = title
        }
        if let peer = peerIDs.first(where: { wings[$0] != wings[noteID] }) {
            return .refused(Outcome(text: Self.compareDifferentWingsWords, isError: true),
                            kind: "note", id: peer, title: titles[peer])
        }
        let archived = Set(try String.fetchAll(
            db,
            sql: "SELECT c.id FROM json_each(?) j CROSS JOIN container c ON c.id = j.value WHERE c.archived_at IS NOT NULL",
            arguments: [String(decoding: try JSONEncoder().encode(peerIDs), as: UTF8.self)]))
        if let peer = peerIDs.first(where: archived.contains) {
            return .refused(Outcome(text: Self.compareArchivedWords(titles[peer]), isError: true),
                            kind: "note", id: peer, title: titles[peer])
        }
        // VX-676: the peers' titles ride along, so an ask can name what it
        // would line up (every one decided readable above).
        return .allowed(kind: "note", id: noteID, title: titles[noteID], peerTitles: peerIDs.map { titles[$0] })
    }

    private func refusal(_ decision: MCPGrantRule.Decision, _ target: MCPRefusalCopy.Target) -> Outcome {
        let reason = MCPRefusalCopy.reason(of: decision) ?? .notShared
        return Outcome(text: MCPRefusalCopy.words(reason, target), isError: true)
    }

    /// `act`: the tool's own (a move, a refusal) — or, VX-676, the ask's.
    private func log(
        _ clientName: String, _ kind: String, _ id: String, _ title: String?, allowed: Bool,
        act: String = MCPToolCatalog.showInApp.name
    ) throws {
        try database.write { db in
            try operations.recordMCPActivity(
                db, clientName: clientName, act: act, targetKind: kind, targetID: id,
                targetTitle: title, allowed: allowed)
        }
    }

    private func encode(_ object: [String: Any]) throws -> String {
        guard JSONSerialization.isValidJSONObject(object) else { throw MCPAnswerEncodingFailure() }
        return String(decoding: try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys]), as: UTF8.self)
    }
}
