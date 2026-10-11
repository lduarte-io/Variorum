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
}

/// **THE MOVE DIAL's ETIQUETTE — her law, as one pure decision** (R-13nb-23,
/// her words: *"moving should not be done while you aren't at the app, should
/// not be done automatically"*; AF-11 F-3). The app reads where it stands —
/// ON THE MAIN ACTOR, in the same hop as any delivery — and asks this; only
/// `.navigate` may move anything. Never queued: a refusal is the whole answer
/// (the offer door and "Show the AI's last change" are her deliberate roads
/// back).
public enum MCPShowRule {
    /// Where the app stands at the moment of the call.
    public enum Standing: Sendable, Equatable {
        /// Variorum is the frontmost app AND its key window is a FULL window
        /// (the only window kind that navigates).
        case frontmostMainWindow
        /// Variorum is frontmost but its key window is a note-only or quick-
        /// note window — moving would mean raising ANOTHER window, which her
        /// etiquette rules out.
        case frontmostOtherWindow
        /// Another app is frontmost (or Variorum has no window at all).
        case notFrontmost
    }

    public enum Verdict: Sendable, Equatable {
        case navigate
        case refuse(String)
    }

    public static func verdict(_ standing: Standing) -> Verdict {
        switch standing {
        case .frontmostMainWindow: .navigate
        case .frontmostOtherWindow: .refuse(otherWindowWords)
        case .notFrontmost: .refuse(notFrontmostWords)
        }
    }

    /// The words (technical register — the MCP room's, P-13n-1; 13s-a
    /// sweepable).
    public static let notFrontmostWords =
        "The author isn't at Variorum right now, so nothing was moved — showing happens only while "
        + "Variorum is the app in front. Ask them to switch to it, then call again."
    public static let otherWindowWords =
        "Variorum's main window isn't the one in front, so nothing was moved — ask the author to "
        + "bring it forward, then call again."
    public static let unavailableWords =
        "This Variorum can't show things — there is no app window to move."
    /// Ladder round 1, F-4: a delivery that could not FINISH (the note opened
    /// but the takes/lens landing never arrived, or the author left the app
    /// mid-delivery) answers honestly instead of claiming shown. 13s-a
    /// sweepable.
    public static let partialShowWords =
        "Variorum opened the note, but the rest of the show didn't land — nothing more was moved. "
        + "Call again while the author is at the app."
}

/// **`show_in_app`** — the READ rung's one navigation tool (AF-11 F-3):
/// decided at READ on the TARGET (a client shows only what it may read),
/// never spending a once grant (a show discloses and changes nothing), then
/// handed to the app's `show` hook — which applies `MCPShowRule` on the main
/// actor and delivers only on `.navigate`. A target the client cannot read
/// answers the ONE `notShared` (no existence oracle); an address that does
/// not belong to its note (a block, a lens, a chapter) answers after the
/// decision, so it discloses nothing the client could not already read.
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
            let decided = try await database.read { db in try decide(db, parsed, clientName: clientName) }
            var target = parsed
            // The wing's name and who asked ride the target (the decision
            // read the name; the client is this session's).
            if case .wing(let wingID, _, _) = target, case .allowed(_, _, let title) = decided {
                target = .wing(wingID: wingID, name: title ?? Queries.mcpHomeWingName, shownBy: clientName)
            }
            switch decided {
            case .refused(let outcome, let kind, let id, let title):
                try log(clientName, kind, id, title, allowed: false)
                return outcome
            case .allowed(let kind, let id, let title):
                guard let show = hooks.show else {
                    try log(clientName, kind, id, title, allowed: false)
                    return Outcome(text: MCPShowRule.unavailableWords, isError: true)
                }
                switch await show(target) {
                case .navigate:
                    try log(clientName, kind, id, title, allowed: true)
                    return Outcome(text: try encode(["shown": true]), isError: false)
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
        default:
            throw ArgumentFailure(message: "target must be \"note\", \"takes\", \"lens\", \"book\" or \"wing\".")
        }
    }

    // MARK: - The decision (read, on the target, never spending)

    private enum Decided {
        case allowed(kind: String, id: String, title: String?)
        case refused(Outcome, kind: String, id: String, title: String?)
    }

    private func decide(_ db: Database, _ target: MCPShowTarget, clientName: String) throws -> Decided {
        let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
        switch target {
        case .note(let noteID, _, _), .takes(let noteID, _), .lens(let noteID, _):
            return try decideNote(db, target, noteID: noteID, standing: standing)
        case .book(let bookID, let sectionID):
            let facts = try Queries.mcpBookFacts(db, readingID: bookID)
            let title = facts == nil ? nil : try Queries.mcpScopeTitle(db, kind: .book, id: bookID, calendar: calendar)
            let decision = MCPGrantAuthority.decide(standing, book: facts, rung: .read)
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

    private func refusal(_ decision: MCPGrantRule.Decision, _ target: MCPRefusalCopy.Target) -> Outcome {
        let reason = MCPRefusalCopy.reason(of: decision) ?? .notShared
        return Outcome(text: MCPRefusalCopy.words(reason, target), isError: true)
    }

    private func log(_ clientName: String, _ kind: String, _ id: String, _ title: String?, allowed: Bool) throws {
        try database.write { db in
            try operations.recordMCPActivity(
                db, clientName: clientName, act: MCPToolCatalog.showInApp.name, targetKind: kind, targetID: id,
                targetTitle: title, allowed: allowed)
        }
    }

    private func encode(_ object: [String: Any]) throws -> String {
        guard JSONSerialization.isValidJSONObject(object) else { throw MCPAnswerEncodingFailure() }
        return String(decoding: try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys]), as: UTF8.self)
    }
}
