import Foundation
import GRDB
import MCP
import VariorumCore

/// **`duplicate_note` — her Duplicate as Version on the wire** (VX-311, VX-336
/// U6a — the run record's D-311-1…8 and the orchestrator's rulings on the
/// forks). A thin projection of `Operations.duplicateNoteForClient` (her op's
/// body, one transaction, ONE client-named undo entry). Why it exists: Compare
/// lines its rows up by shared `derived_from` lineage, and a `create_note` draft
/// shares none — a duplicate keeps block-by-block lineage, so Compare aligns.
///
/// **Where the copy lands, and what reach decides it (P-VX311-2, F-1 (a)):**
/// her door's copy lands BOOKLESS in the source's wing (that wing's Pool), so
/// the reach is `move_note_to_wing`'s two-sided shape, applied:
/// - the SOURCE: the note at READ through the ordinary rule (any note, book or
///   wing grant reaching it, or the open book) — a copy reads its content, so a
///   once READ grant is spent by it (AF-7 as amended);
/// - the LANDING: the source's (resolved) wing at WRITE NEW through
///   `decideWing` — a wing grant on THAT wing. A book grant can never name where
///   a bookless note lands, and the open book is read only: a client whose
///   write new is only a book hears the wing's refusal and the wing's ask.
///
/// **The fence (P-VX311-1, F-2 (a)):** a fenced source the client CAN read (its
/// own live per-ask grant) refuses in ONE sentence that names no leg, minting
/// nothing — the copy would keep the journal-profile leg but shed the daily
/// Journal's membership, a Private book's membership and the note's own
/// Private mark (no MCP road writes `ai_private_at` — R-VX184-2), so the copy
/// would reach further than the note does (P-13nb-U4-16's principle). An
/// UNREACHED fenced note never gets past the rule: the one not-shared shape.
///
/// The snapshot decides both sides (the source first) and raises ONE ask; the
/// act runs behind a guard that decides both AGAIN — the fence included — on
/// one standing read inside its own write transaction and stamps the once
/// grants of both sides there as ONE union (both spend or neither; a refused
/// act spends nothing) — `guardWingMove`'s shape.
///
/// **The answer (P-VX311-3, F-3/F-4 (a)):** VX-252's records of what the copy
/// MINTED (`MCPMintedBlocks` — the copy's active takes in fan order, the shown
/// take, and each block's `source_block_id`), `block_ids` beside them (F-6),
/// and where it landed in `move_note_to_wing`'s words. The receipt's Open ›
/// opens the COPY, like every note-minting act (F-5 (a)). P1: the decisions ∝
/// one note + one wing; the write and its answer ∝ the copied note.
extension MCPWriteTools {
    /// THE FENCE's one sentence (D-311-3) — no leg named (technical register,
    /// the MCP room's; PROVISIONAL words, her copy pass — VX-234).
    static let duplicateFencedWords =
        "This note is shared with you only per ask, so it can't be duplicated \u{2014} a copy would reach further "
        + "than the note does. The author can duplicate it in Variorum."

    // MARK: - The serial body

    func performDuplicateNote(
        noteID: String, job: Job, ops: Operations, clientName: String
    ) throws -> Result<Landed, Refused> {
        let (standing, facts, title, wingName) = try database.read { db in
            let facts = try Queries.mcpNoteFacts(db, noteID: noteID)
            return (try MCPGrantAuthority.standing(db, clientName: clientName), facts,
                    facts == nil ? nil : try Queries.mcpScopeTitle(db, kind: .note, id: noteID, calendar: calendar),
                    try facts.flatMap { try Queries.mcpScopeTitle(db, kind: .wing, id: $0.wingID, calendar: calendar) })
        }
        let onNote = MCPGrantAuthority.decide(standing, note: facts, rung: .read, consumes: true)
        guard onNote.isAllowed, let facts else {
            try log(clientName, job.tool, "note", noteID, title, allowed: false)
            let ask = facts.map { MCPAsk(clientName: clientName, scopeKind: .note, scopeID: noteID,
                                         title: title ?? "", rung: .read, fence: $0.fence) }
            return .failure(Refused(outcome: MCPAsking(onAsk: hooks.onAsk)
                .refusal(onNote, .note, standing: standing, ask: ask)))
        }
        // The fence BEFORE the wing: a fenced copy refuses whatever the wing
        // allows, so no wing ask is raised for an act that can never land.
        guard facts.fence == nil else {
            try log(clientName, job.tool, "note", noteID, title, allowed: false)
            return .failure(Refused(outcome: Outcome(text: Self.duplicateFencedWords, isError: true)))
        }
        let wingID = facts.wingID
        let onWing = MCPGrantAuthority.decideWing(standing, wingID: wingID, rung: .writeNew, consumes: true)
        guard onWing.isAllowed else {
            try log(clientName, job.tool, "wing", wingID, wingName, allowed: false)
            let ask = wingName.map { MCPAsk(clientName: clientName, scopeKind: .wing, scopeID: wingID,
                                            title: $0, rung: .writeNew, fence: nil) }
            return .failure(Refused(outcome: MCPAsking(onAsk: hooks.onAsk)
                .refusal(onWing, .wing, standing: standing, ask: ask)))
        }
        return try land(job, clientName: clientName, kind: "note", id: noteID, title: title, logsReceiptTitle: false) {
            let copy = try ops.duplicateNoteForClient(
                noteID, undoLabel: Operations.MCPWriteAct.duplicate.undoLabel(client: clientName),
                guardedBy: guardDuplicate(clientName, noteID: noteID))
            let copyTitle = try database.read { db in
                try Queries.mcpScopeTitle(db, kind: .note, id: copy.post.id, calendar: calendar)
            }
            let answer: [String: Any] = [
                "note_id": copy.post.id, "source_note_id": noteID,
                "block_ids": copy.blocks.map(\.blockID), "blocks": MCPMintedBlocks.records(copy.blocks),
                "landed": Self.landedWords(wingTitle: wingName ?? Queries.mcpHomeWingName, isHome: wingID.isEmpty),
            ]
            return (answer, MCPWriteReceipt(
                clientName: clientName, act: .duplicate, targetID: copy.post.id, targetTitle: copyTitle,
                show: .note(noteID: copy.post.id, blockID: nil, select: nil)))
        }
    }

    /// The guard: the source at READ (and unfenced) and its wing at WRITE NEW,
    /// decided again on ONE standing read inside the act's transaction; the
    /// once grants of both sides stamped as one union, there and only there.
    func guardDuplicate(_ clientName: String, noteID: String) -> Operations.WriteGuard {
        { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            let facts = try Queries.mcpNoteFacts(db, noteID: noteID)
            let onNote = MCPGrantAuthority.decide(standing, note: facts, rung: .read, consumes: true)
            guard case .allow(let noteGrant, let spendNote) = onNote, let facts else {
                throw Self.refused(onNote, .note)
            }
            guard facts.fence == nil else {
                throw Refused(outcome: Outcome(text: Self.duplicateFencedWords, isError: true))
            }
            let onWing = MCPGrantAuthority.decideWing(standing, wingID: facts.wingID, rung: .writeNew, consumes: true)
            guard case .allow(let wingGrant, let spendWing) = onWing else { throw Self.refused(onWing, .wing) }
            let spend = Set([spendNote ? noteGrant : nil, spendWing ? wingGrant : nil].compactMap { $0 })
            for grantID in spend.sorted() { try grants.consumeMCPOnceGrant(db, grantID) }
        }
    }
}
