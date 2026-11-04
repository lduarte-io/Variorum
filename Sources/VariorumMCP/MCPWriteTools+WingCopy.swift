import Foundation
import GRDB
import MCP
import VariorumCore

/// **`copy_note_to_wing` — her Copy to Wing on the wire** (VX-765, the VX-771
/// run's batch 1; her ⇧⌥⌘L, VX-632; VX-368's parity class). The field report's
/// #11: copying a note into another wing took `duplicate_note` +
/// `move_note_to_wing` — two calls, two undo entries, and the duplicate's whole
/// per-block answer in between. A thin projection of
/// `Operations.mcpCopyNoteToWing` (her door's body, one transaction, ONE
/// client-named undo entry).
///
/// **The reach — `duplicate_note`'s two-sided shape, the landing in another
/// wing:**
/// - the SOURCE: the note at READ through the ordinary rule (any note, book or
///   wing grant reaching it, or the open book) — a copy reads its content, so a
///   once READ grant is spent by it (AF-7 as amended);
/// - the LANDING: the destination wing at WRITE NEW through `decideWing` — a
///   wing grant on THAT wing (a book or note grant never names where a bookless
///   note lands; the open book is read only).
///
/// **The fence FIRST, then the wing it already lives in:** a fenced source the
/// client CAN read (its own live per-ask grant) refuses in ONE sentence naming
/// no leg (P-VX311-1's shape — a copy would keep the journal profile but shed
/// the daily Journal's membership, a Private book's and the note's own Private
/// mark, so it would reach further than the note does); an UNREACHED fenced
/// note never gets past the rule (the one not-shared shape). A note asked into
/// the wing it already lives in refuses in words that name the road that does
/// copy within a wing (`duplicate_note`) — her door never offers that wing
/// (`WingsModel.destinations(from:)` lists only the others). Both are decided
/// BEFORE the landing, so no wing ask is raised for an act that can never land;
/// a reader of the note already sees its `wing_id` (`list_notes`), so the
/// same-wing sentence tells it nothing new.
///
/// The snapshot decides both sides (the source first) and raises ONE ask; the
/// act runs behind a guard that decides both AGAIN — the fence included — on one
/// standing read inside its own write transaction and stamps the once grants of
/// both sides there as ONE union (both spend or neither; a refused act spends
/// nothing) — `guardDuplicate`'s shape.
///
/// **The answer:** VX-766's brief record (`briefCopyAnswer` — ids and counts,
/// no per-block records: the ticket's point) plus `wing_id`. Activity logs the
/// SOURCE note (the side the client named first — `move_note_to_wing`'s row);
/// the receipt's target is the DESTINATION wing (a run of copies to one wing
/// coalesces into one line, the wing move's precedent), its detail the note's
/// title, and its Open › opens the COPY. P1: the decisions ∝ one note + one
/// wing; the write and its answer ∝ the copied note.
extension MCPWriteTools {
    /// THE FENCE's one sentence — no leg named (technical register, the MCP
    /// room's; PROVISIONAL words, her copy pass — VX-234).
    static let wingCopyFencedWords =
        "This note is shared with you only per ask, so it can't be copied to another wing \u{2014} a copy would "
        + "reach further than the note does. The author can copy it in Variorum."

    /// The wing it already lives in (PROVISIONAL words, her copy pass).
    static let wingCopySameWingWords =
        "That note is already in that wing, and copy_note_to_wing copies a note into another wing \u{2014} "
        + "to copy it within its own wing, use duplicate_note."

    // MARK: - The parse

    /// `note_id` and `wing_id` — "" is Home, present but empty the one legal
    /// empty id (`move_note_to_wing`'s rule and sentence).
    func parseCopyNoteToWing(_ args: [String: Value]) throws -> Job {
        let noteID = try requiredString(args, "note_id")
        guard let wingID = try optionalString(args, "wing_id") else {
            throw ArgumentFailure(message: "wing_id is required (\"\" is Home).")
        }
        return .copyNoteToWing(noteID: noteID, wingID: wingID)
    }

    // MARK: - The serial body

    func performCopyNoteToWing(
        noteID: String, wingID: String, job: Job, ops: Operations, clientName: String
    ) throws -> Result<Landed, Refused> {
        let (standing, facts, title, wingName) = try database.read { db in
            let facts = try Queries.mcpNoteFacts(db, noteID: noteID)
            return (try MCPGrantAuthority.standing(db, clientName: clientName), facts,
                    facts == nil ? nil : try Queries.mcpScopeTitle(db, kind: .note, id: noteID, calendar: calendar),
                    try Queries.mcpScopeTitle(db, kind: .wing, id: wingID, calendar: calendar))
        }
        let onNote = MCPGrantAuthority.decide(standing, note: facts, rung: .read, consumes: true)
        guard onNote.isAllowed, let facts else {
            try log(clientName, job.tool, "note", noteID, title, allowed: false)
            let ask = facts.map { MCPAsk(clientName: clientName, scopeKind: .note, scopeID: noteID,
                                         title: title ?? "", rung: .read, fence: $0.fence) }
            return .failure(Refused(outcome: MCPAsking(onAsk: hooks.onAsk)
                .refusal(onNote, .note, standing: standing, ask: ask)))
        }
        guard facts.fence == nil else {
            try log(clientName, job.tool, "note", noteID, title, allowed: false)
            return .failure(Refused(outcome: Outcome(text: Self.wingCopyFencedWords, isError: true)))
        }
        guard facts.wingID != wingID else {
            try log(clientName, job.tool, "note", noteID, title, allowed: false)
            return .failure(Refused(outcome: Outcome(text: Self.wingCopySameWingWords, isError: true)))
        }
        let onWing = MCPGrantAuthority.decideWing(standing, wingID: wingID, rung: .writeNew, consumes: true)
        guard onWing.isAllowed else {
            try log(clientName, job.tool, "wing", wingID, wingName, allowed: false)
            let ask = wingName.map { MCPAsk(clientName: clientName, scopeKind: .wing, scopeID: wingID,
                                            title: $0, rung: .writeNew, fence: nil) }
            return .failure(Refused(outcome: MCPAsking(onAsk: hooks.onAsk)
                .refusal(onWing, .wing, standing: standing, ask: ask)))
        }
        return try land(job, clientName: clientName, kind: "note", id: noteID, title: title, logsReceiptTitle: false) {
            let made = try ops.mcpCopyNoteToWing(
                noteID, to: wingID, undoLabel: Operations.MCPWriteAct.wingCopy.undoLabel(client: clientName),
                guardedBy: guardWingCopy(clientName, noteID: noteID, wingID: wingID))
            let wingTitle = wingName ?? Queries.mcpHomeWingName
            var answer = Self.briefCopyAnswer(
                noteID: made.copy.id, sourceID: noteID, blocks: made.blocks, tagIDs: made.tagIDs,
                tagPaths: made.tagPaths, landed: Self.landedWords(wingTitle: wingTitle, isHome: wingID.isEmpty))
            answer["wing_id"] = wingID
            return (answer, MCPWriteReceipt(
                clientName: clientName, act: .wingCopy, targetID: wingID, targetTitle: wingTitle,
                detail: title, show: .note(noteID: made.copy.id, blockID: nil, select: nil)))
        }
    }

    /// The guard: the source at READ (and unfenced) and the destination wing
    /// at WRITE NEW, decided again on ONE standing read inside the act's
    /// transaction; the once grants of both sides stamped as one union, there
    /// and only there. (The same-wing belt is her op's own `postAlreadyInWing`.)
    func guardWingCopy(_ clientName: String, noteID: String, wingID: String) -> Operations.WriteGuard {
        { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            let facts = try Queries.mcpNoteFacts(db, noteID: noteID)
            let onNote = MCPGrantAuthority.decide(standing, note: facts, rung: .read, consumes: true)
            guard case .allow(let noteGrant, let spendNote) = onNote, let facts else {
                throw Self.refused(onNote, .note)
            }
            guard facts.fence == nil else {
                throw Refused(outcome: Outcome(text: Self.wingCopyFencedWords, isError: true))
            }
            let onWing = MCPGrantAuthority.decideWing(standing, wingID: wingID, rung: .writeNew, consumes: true)
            guard case .allow(let wingGrant, let spendWing) = onWing else { throw Self.refused(onWing, .wing) }
            let spend = Set([spendNote ? noteGrant : nil, spendWing ? wingGrant : nil].compactMap { $0 })
            for grantID in spend.sorted() { try grants.consumeMCPOnceGrant(db, grantID) }
        }
    }
}
