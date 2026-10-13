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
/// §19): a book the tag brought the note into keeps it.
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
            let removal: Operations.MCPTagRemoval
            do {
                removal = try ops.removeTagForClient(
                    path: path, fromNote: noteID,
                    undoLabel: Operations.MCPWriteAct.untag.undoLabel(client: clientName),
                    guardedBy: guardEdit(clientName) { _ in [noteID] })
            } catch OperationError.tagNotApplied {
                throw Refused(outcome: Outcome(text: Self.notWornWords(path), isError: true))
            }
            return (["note_id": noteID, "tag_id": removal.tagID, "tag": removal.path, "removed": true],
                    MCPWriteReceipt(clientName: clientName, act: .untag, targetID: noteID, targetTitle: title,
                                    detail: removal.path, show: .note(noteID: noteID, blockID: nil, select: nil)))
        }
    }
}
