import Foundation
import GRDB
import MCP
import VariorumCore

/// **`set_starred` — her star on the wire** (VX-596 — her ruling 2026-10-27,
/// verbatim: "let's add the star over the wire, it might as well be included";
/// the run record `notes/plans/fixes/vx-620-run-mcp-umbrella-remainder.md`,
/// BATCH 1). Stars are not in the hers-alone trio (Private · Seal · Own —
/// R-VX184-2), so the EDIT rung stars and un-stars as she does at the keyboard
/// (R-VX184-1): a NOTE or a BOOK, one tool, `starred` saying which way.
///
/// **The two decisions, AF-10 (a)'s shape** (`archive_note`'s, `archive_book`'s):
/// the SNAPSHOT speaks the refusal and raises the just-in-time ask — a note
/// decided at EDIT through the one `decide` (a note, book, gathering or wing
/// grant reaching it; the fence first — a Private note or a daily-Journal entry
/// only through a per-ask grant on that note), a book at EDIT on the book (the
/// daily Journal and a Private book are never a grant's reach — the ONE
/// not-shared shape, byte-identical to a missing id); a GATHERING id the client
/// can read hears the gathering sentence (P-VX196-2's posture: read, never
/// changed through this door — PROVISIONAL, the record's bundle) — then the
/// act's guard re-decides INSIDE its own transaction and spends any once grant
/// there (`spendsAfter: false`).
///
/// **The act** is `Operations.setStarredForClient` — her `writeStar`: the cap of
/// fifteen refusing in her words (`starLimitReached` through the ONE refusal
/// chain, her `OpsRefusalCopy`), intake hearing a note's star exactly as hers
/// (a living ★-rule book seats or bells by its dial), un-starring a non-event.
/// A star already as asked writes nothing: `changed: false`, no undo entry, no
/// receipt, the landed Activity line (VX-362's `apply_tag` shape). Otherwise
/// ONE client-named ⌥⌘Z entry, compare-and-set, the star back at its place.
extension MCPWriteTools {
    /// `set_starred`'s arguments: exactly one of `note_id` / `book_id`, and
    /// `starred` — said, never defaulted (a star toggled by an absent key would
    /// be a magic word).
    func parseSetStarred(_ args: [String: Value]) throws -> Job {
        guard let value = args["starred"], value != .null else {
            throw ArgumentFailure(message: "starred is required: true stars it, false un-stars it.")
        }
        guard let starred = value.boolValue else { throw ArgumentFailure(message: "starred must be true or false.") }
        switch (try optionalString(args, "note_id"), try optionalString(args, "book_id")) {
        case (let note?, nil): return .setStarred(target: .post(note), starred: starred)
        case (nil, let book?): return .setStarred(target: .reading(book), starred: starred)
        case (.some, .some): throw ArgumentFailure(message: "Pass note_id or book_id, not both.")
        case (nil, nil): throw ArgumentFailure(message: "Pass note_id (a note) or book_id (a book).")
        }
    }

    func performSetStarred(
        _ target: StarTarget, starred: Bool, job: Job, ops: Operations, clientName: String
    ) throws -> Result<Landed, Refused> {
        let act: Operations.MCPWriteAct = starred ? .star : .unstar
        let undoLabel = act.undoLabel(client: clientName)
        switch target.kind {
        case .post:
            let noteID = target.id
            return try onNote(noteID, rung: .edit, job: job, clientName: clientName, spendsAfter: false) { title in
                let change = try ops.setStarredForClient(
                    target, starred: starred, undoLabel: undoLabel,
                    guardedBy: guardEdit(clientName) { _ in [noteID] })
                return (["note_id": noteID, "starred": starred, "changed": change.changed],
                        change.changed
                        ? MCPWriteReceipt(clientName: clientName, act: act, targetID: noteID, targetTitle: title,
                                          show: .note(noteID: noteID, blockID: nil, select: nil))
                        : nil)
            }
        case .reading:
            let bookID = target.id
            return try onBook(bookID, rung: .edit, job: job, clientName: clientName, spendsAfter: false) { name in
                let change = try ops.setStarredForClient(
                    target, starred: starred, undoLabel: undoLabel,
                    guardedBy: guardBooks(clientName, .edit) { _ in [bookID] })
                return (["book_id": bookID, "starred": starred, "changed": change.changed],
                        change.changed
                        ? MCPWriteReceipt(clientName: clientName, act: act, targetID: bookID, targetTitle: name,
                                          show: .book(bookID: bookID, sectionID: nil))
                        : nil)
            }
        }
    }
}
