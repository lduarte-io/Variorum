import Foundation
import GRDB
import MCP
import VariorumCore

/// **`remove_tag` — un-tagging a note, at EDIT** (VX-184 U3 — VX-190). A thin
/// projection of `Operations.removeTagForClient`: §9's `removeTag` row body,
/// addressed by the tag's PATH (`apply_tag`'s address), behind the edit rung's
/// two decisions — the snapshot (`onNote`, `spendsAfter: false`) speaks the
/// refusal and raises the ask; the guard re-decides the note at EDIT inside the
/// act's transaction and spends any once grant there — and ONE client-named
/// undo entry. Un-tagging stays a NON-EVENT for intake (OverallModel §2;
/// §19): a book the tag brought the note into keeps it — and since VX-764
/// the answer says which (`stillInBooks`).
extension MCPWriteTools {
    /// The tag the note doesn't wear — one sentence for a tag of its library
    /// and a path naming nothing (the note's own header lists what it wears;
    /// a client that may edit the note can read it).
    static func notWornWords(_ path: String) -> String {
        "That note doesn't wear the tag \u{201C}\(path)\u{201D} \u{2014} read_note's header lists the tags it wears."
    }

    /// `tag`: a path, a leading `#` tolerated (`set_book_rule`'s outflow).
    func parseRemoveTag(_ args: [String: Value]) throws -> Job {
        let noteID = try requiredString(args, "note_id")
        let raw = try requiredText(args, "tag")
        let path = TagPath.segments(raw.hasPrefix("#") ? String(raw.dropFirst()) : raw).joined(separator: "/")
        guard !path.isEmpty else {
            throw ArgumentFailure(message: "tag must be a tag path \u{2014} names joined by /, e.g. \"percy/pt-en\".")
        }
        return .removeTag(noteID: noteID, path: path)
    }

    func performRemoveTag(
        noteID: String, path: String, job: Job, ops: Operations, clientName: String
    ) throws -> Result<Landed, Refused> {
        try onNote(noteID, rung: .edit, job: job, clientName: clientName, spendsAfter: false) { title in
            // VX-764: the standing that authorizes this act, read before it
            // (the `duplicate_note` `landed` precedent) — it decides which of
            // the books the note stays in may be NAMED.
            let standing = try database.read { try MCPGrantAuthority.standing($0, clientName: clientName) }
            let removal: Operations.MCPTagRemoval
            do {
                removal = try ops.removeTagForClient(
                    path: path, fromNote: noteID,
                    undoLabel: Operations.MCPWriteAct.untag.undoLabel(client: clientName),
                    guardedBy: guardEdit(clientName) { _ in [noteID] })
            } catch OperationError.tagNotApplied {
                throw Refused(outcome: Outcome(text: Self.notWornWords(path), isError: true))
            }
            var answer: [String: Any] = ["note_id": noteID, "tag_id": removal.tagID, "tag": removal.path, "removed": true]
            for (key, value) in try stillInBooks(removal.stillInBookIDs, standing: standing) { answer[key] = value }
            return (answer,
                    MCPWriteReceipt(clientName: clientName, act: .untag, targetID: noteID, targetTitle: title,
                                    detail: removal.path, show: .note(noteID: noteID, blockID: nil, select: nil)))
        }
    }

    /// **VX-764 (R-771-A (a) — the dial DECLINED): the books the un-tag left
    /// the note in, under the fence.** Each living book that collects by the
    /// tag and still holds the note (`Operations.livingBooksHolding`) is NAMED
    /// — `{book_id, name}` — only where this client can READ it (the one rule,
    /// `decide` at read, never consuming); every other one, a fenced book (a
    /// Private book, the daily Journal — it matches no grant) among them, is
    /// COUNTED only, with no id: hidden never differs from missing (the
    /// `duplicate_note` `landed` / `move_note_to_wing` `left_books`
    /// discipline). Nothing stranded answers NO key, so the answer is the
    /// pre-VX-764 answer byte for byte; something stranded always says
    /// `still_in_books` (`[]` when every one is hidden) and the count only
    /// when it is not 0. ∝ the note's books.
    private func stillInBooks(_ bookIDs: [String], standing: MCPGrantAuthority.Standing) throws -> [String: Any] {
        guard !bookIDs.isEmpty else { return [:] }
        let named: [[String: Any]] = try database.read { db in
            try bookIDs.compactMap { bookID in
                guard MCPGrantAuthority.decide(
                    standing, book: try Queries.mcpBookFacts(db, readingID: bookID), rung: .read).isAllowed,
                    let name = try Queries.mcpScopeTitle(db, kind: .book, id: bookID, calendar: calendar)
                else { return nil }
                return ["book_id": bookID, "name": name]
            }
        }
        var facts: [String: Any] = ["still_in_books": named]
        if bookIDs.count > named.count { facts["still_in_books_hidden_count"] = bookIDs.count - named.count }
        return facts
    }
}
