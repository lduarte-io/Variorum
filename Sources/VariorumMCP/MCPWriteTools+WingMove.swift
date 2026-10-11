import Foundation
import GRDB
import MCP
import VariorumCore

/// **`move_note_to_wing`** (13n-c U6 — VX-160; R-AIR-2 ratified, R-AIR-9's R1;
/// the brief §10 · mockup §9). The author's own Move to Wing on the wire: her
/// op (`Operations.mcpMoveNoteToWing` wraps `moveNoteToWing` — her severed
/// books, her tag adoption by path, her refusals), ONE client-named undo entry
/// with an exact-row inverse.
///
/// **R1 — two decisions, each on its own side:**
/// - the SOURCE: the NOTE at EDIT through the ordinary rule (any note, book or
///   wing grant reaching it — leaving its books reorganizes what exists,
///   P-13nb-U3-4's reading of `move_block`); a fenced note only through a
///   per-ask grant on that note (the rule's own fence);
/// - the DESTINATION: the WING at WRITE NEW through `decideWing` — a wing
///   grant on THAT wing; a book grant there can never name where a bookless
///   note lands, and the open book is read only.
///
/// The snapshot decides both first and raises ONE ask, the source's first;
/// then the act runs behind a guard that decides both AGAIN inside its own
/// write transaction on one standing read and stamps the once grants of both
/// sides there as one union — so both spend or neither, and a refused act
/// spends nothing (AF-10 (a)'s seam; `guardBookAndNote`'s shape).
/// `move_block` keeps refusing a cross-wing move (P-13nb-U3-5): blocks never
/// walk between libraries; a whole note does, by this one door.
extension MCPWriteTools {
    func performWingMove(
        noteID: String, wingID: String, job: Job, ops: Operations, clientName: String
    ) throws -> Result<Landed, Refused> {
        let (standing, noteFacts, title, wingName) = try database.read { db in
            let facts = try Queries.mcpNoteFacts(db, noteID: noteID)
            return (try MCPGrantAuthority.standing(db, clientName: clientName), facts,
                    facts == nil ? nil : try Queries.mcpScopeTitle(db, kind: .note, id: noteID, calendar: calendar),
                    try Queries.mcpScopeTitle(db, kind: .wing, id: wingID, calendar: calendar))
        }
        let onNote = MCPGrantAuthority.decide(standing, note: noteFacts, rung: .edit, consumes: true)
        guard onNote.isAllowed else {
            try log(clientName, job.tool, "note", noteID, title, allowed: false)
            let ask = noteFacts.map { MCPAsk(clientName: clientName, scopeKind: .note, scopeID: noteID,
                                             title: title ?? "", rung: .edit, fence: $0.fence) }
            return .failure(Refused(outcome: MCPAsking(onAsk: hooks.onAsk)
                .refusal(onNote, .note, standing: standing, ask: ask)))
        }
        let onWing = MCPGrantAuthority.decideWing(standing, wingID: wingID, rung: .writeNew, consumes: true)
        guard onWing.isAllowed else {
            try log(clientName, job.tool, "wing", wingID, wingName, allowed: false)
            let ask = wingName.map { MCPAsk(clientName: clientName, scopeKind: .wing, scopeID: wingID,
                                            title: $0, rung: .writeNew, fence: nil) }
            return .failure(Refused(outcome: MCPAsking(onAsk: hooks.onAsk)
                .refusal(onWing, .wing, standing: standing, ask: ask)))
        }
        return try land(job, clientName: clientName, kind: "note", id: noteID, title: title) {
            let moved: Operations.MCPWingMove
            do {
                moved = try ops.mcpMoveNoteToWing(
                    noteID, to: wingID, undoLabel: Operations.MCPWriteAct.wingMove.undoLabel(client: clientName),
                    guardedBy: guardWingMove(clientName, noteID: noteID, wingID: wingID))
            } catch let error as OperationError {
                if let words = try frozenWords(error, noteTitle: title, standing: standing) {
                    throw Refused(outcome: Outcome(text: words, isError: true))
                }
                throw error
            }
            // The books it left — each by id (list_notes' book_ids already
            // carry them), NAMED only where the client can read that book
            // (names stay with grants, AF-10 (f); the standing that authorized
            // this act). PROVISIONAL P-13nc-U6-2.
            let leftBooks: [[String: Any]] = try database.read { db in
                try moved.leftBookIDs.map { bookID in
                    var entry: [String: Any] = ["book_id": bookID]
                    let facts = try Queries.mcpBookFacts(db, readingID: bookID)
                    if MCPGrantAuthority.decide(standing, book: facts, rung: .read).isAllowed,
                       let name = try Queries.mcpScopeTitle(db, kind: .book, id: bookID, calendar: calendar) {
                        entry["name"] = name
                    }
                    return entry
                }
            }
            let wingTitle = wingName ?? Queries.mcpHomeWingName
            let answer: [String: Any] = [
                "moved": true, "note_id": noteID, "wing_id": wingID,
                "landed": Self.landedWords(wingTitle: wingTitle, isHome: wingID.isEmpty),
                "left_books": leftBooks,
                "tags": ["adopted": moved.move.adoptedTags, "made": moved.move.mintedTags],
            ]
            // The receipt's target is the DESTINATION wing, so a sweep's run
            // of moves to one wing coalesces into one line ("moved 14 notes to
            // “variorum”"); "Open ›" opens the note (the wing follows it).
            return (answer, MCPWriteReceipt(
                clientName: clientName, act: .wingMove, targetID: wingID, targetTitle: wingTitle,
                detail: title, show: .note(noteID: noteID, blockID: nil, select: nil),
                leftBooks: moved.leftBookIDs.count))
        }
    }

    /// R1's guard: the note at EDIT and the destination wing at WRITE NEW,
    /// decided again on ONE standing read inside the act's transaction; the
    /// once grants of both sides stamped as one union, there and only there.
    func guardWingMove(_ clientName: String, noteID: String, wingID: String) -> Operations.WriteGuard {
        { db in
            let standing = try MCPGrantAuthority.standing(db, clientName: clientName)
            let onNote = MCPGrantAuthority.decide(
                standing, note: try Queries.mcpNoteFacts(db, noteID: noteID), rung: .edit, consumes: true)
            guard case .allow(let noteGrant, let spendNote) = onNote else { throw Self.refused(onNote, .note) }
            let onWing = MCPGrantAuthority.decideWing(standing, wingID: wingID, rung: .writeNew, consumes: true)
            guard case .allow(let wingGrant, let spendWing) = onWing else { throw Self.refused(onWing, .wing) }
            let spend = Set([spendNote ? noteGrant : nil, spendWing ? wingGrant : nil].compactMap { $0 })
            for grantID in spend.sorted() { try grants.consumeMCPOnceGrant(db, grantID) }
        }
    }

    /// Her door's own sentence for a note held by a finished or sealed book
    /// (`MCPHostHooks.wingMoveFrozenWords`), where the client can read that
    /// book; nil = the op's own refusal speaks (PROVISIONAL P-13nc-U6-4).
    private func frozenWords(
        _ error: OperationError, noteTitle: String?, standing: MCPGrantAuthority.Standing
    ) throws -> String? {
        let bookID: String
        switch error {
        case .lockedReading(let id), .readingSealed(let id): bookID = id
        default: return nil
        }
        guard let hook = hooks.wingMoveFrozenWords, let noteTitle else { return nil }
        let (facts, name) = try database.read { db in
            (try Queries.mcpBookFacts(db, readingID: bookID),
             try Queries.mcpScopeTitle(db, kind: .book, id: bookID, calendar: calendar))
        }
        guard let name, MCPGrantAuthority.decide(standing, book: facts, rung: .read).isAllowed else { return nil }
        return hook(noteTitle, name)
    }

    /// Where a moved note lands — bookless, in its new wing's Pool. Home is a
    /// place-name, never quoted (`WingFollow.nowIn`'s rule).
    static func landedWords(wingTitle: String, isHome: Bool) -> String {
        isHome ? "the Pool of Home" : "the Pool of \u{201C}\(wingTitle)\u{201D}"
    }
}
