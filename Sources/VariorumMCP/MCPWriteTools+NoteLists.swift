import Foundation
import MCP
import VariorumCore

/// **THE LIST FORMS** (VX-812 — the VX-809 run, batch 3; her R-812: "list
/// arguments on the acts that already exist (delete_note, move, tag/untag — each
/// item still its own operation, grant-checked and ⌥⌘Z-entried per the door's
/// rules; one call, N receipts)"; the tool set ruled A-809-18 = F-12 (a)).
///
/// `delete_note`, `move_note_to_wing`, `apply_tag` and `remove_tag` take
/// `note_ids` (1–200 ids, no repeats) EXCLUSIVE with `note_id`; every other
/// argument means what it means on the single form (one `wing_id`, one `tag`).
/// The parse builds each item as THE SINGLE CALL'S OWN JOB (the single parse,
/// `note_id` set to the item's id), so an item IS the single act — its own
/// decision and ask, its own guard re-deciding inside its own transaction and
/// stamping a once grant there (A-809-18 a.1, PROVISIONAL P-809-12: a once grant
/// covers ONE item), its own Activity line, its own client-named ⌥⌘Z entry —
/// and per-item independence is by construction: one item refusing never stops
/// the rest; nothing is all-or-nothing.
///
/// The answer: `results`, one per id in the order given — the single call's
/// answer object for a landed item (byte for byte, its keys and words), or
/// `{note_id, refused}` with the single call's refusal text for a refused one —
/// plus `landed_count` and `refused_count`. Purity is inherited item by item:
/// each item answers exactly what the single call would, so the list can never
/// tell hidden from missing (the catalog's list arms pin it).
///
/// The receipts (A-809-19 = F-13 (A) + (i)): every LANDED item sends its single
/// act's receipt, all stamped with ONE call-scoped `runKey`, so the app's
/// shipped run machinery coalesces them into ONE line naming the count; a
/// refused item sends none. The line's Open › is the last landed item's own
/// landing (the run's newest `show`); `delete_note` has none.
///
/// All items run in the call's ONE serial turn on the executor (AF-8): nothing
/// of hers interleaves, so the call's one flush ahead of the turn (VX-275, for
/// `delete_note`) covers every item.
extension MCPWriteTools {
    /// The tools that take `note_ids` (A-809-18).
    static let listFormTools: Set<String> = [
        MCPToolCatalog.deleteNote.name, MCPToolCatalog.moveNoteToWing.name,
        MCPToolCatalog.applyTag.name, MCPToolCatalog.removeTag.name,
    ]

    /// The door's batch cap (the `add_takes` precedent), stated in each
    /// description.
    static let listCap = 200

    /// The list form's description sentence, shared by the four tools
    /// (PROVISIONAL — the VX-809 bundle's wording list).
    static let listFormSentence = """
        note_ids (1 to \(listCap) notes, instead of note_id) does the same to each note in turn: each \
        its own act with its own undo for the author, one refusing never stopping the rest (a once \
        grant covers one item). It returns results — one per note, in the order given: that note's \
        answer, or note_id with refused — and landed_count and refused_count.
        """

    /// The `note_ids` property every list-form schema declares.
    static let noteIDsProperty: Value = .object([
        "type": "array",
        "description": "Up to \(listCap) notes, instead of note_id — each its own act.",
        "items": .object(["type": "string"]),
    ])

    /// **The list parse** — nil when the call is not a list form (the single
    /// parse runs). Each item is the single parse's own job.
    func parseNoteList(_ name: String, _ args: [String: Value]) throws -> Job? {
        guard Self.listFormTools.contains(name), let value = args["note_ids"], value != .null else { return nil }
        if let single = args["note_id"], single != .null {
            throw ArgumentFailure(message: "Pass note_id or note_ids, not both.")
        }
        let ids = try validatedNoteIDs(value)
        var single = args
        single["note_ids"] = nil
        return .noteList(tool: name, items: try ids.map { id in
            single["note_id"] = .string(id)
            return NoteListItem(noteID: id, job: try parse(name, single))
        })
    }

    /// The `note_ids` value's own checks — an array of 1 to `listCap` distinct
    /// strings — shared by the four list forms and (VX-811) `propose_notes_to_book`.
    func validatedNoteIDs(_ value: Value) throws -> [String] {
        guard let items = value.arrayValue else { throw ArgumentFailure(message: "note_ids must be an array.") }
        let ids = try items.map { item -> String in
            guard let id = item.stringValue else { throw ArgumentFailure(message: "note_ids must hold strings.") }
            return id
        }
        guard !ids.isEmpty else { throw ArgumentFailure(message: "note_ids lists no note.") }
        guard ids.count <= Self.listCap else {
            throw ArgumentFailure(message: Self.listCapWords(ids.count))
        }
        guard Set(ids).count == ids.count else { throw ArgumentFailure(message: "note_ids lists a note twice.") }
        return ids
    }

    /// PROVISIONAL (the VX-809 bundle's wording list).
    static func listCapWords(_ count: Int) -> String {
        "note_ids holds at most \(listCap) notes (this call named \(count)) — send the rest in another call."
    }

    /// One item of a list call: the id and the single call's own job for it.
    struct NoteListItem: Sendable {
        let noteID: String
        let job: Job
    }

    /// **The list's serial body** — each item through the SINGLE call's own
    /// road (`perform`), in the order given; the results gathered; every landed
    /// item's receipt stamped with the call's one run key.
    /// `always`: keys every answer of this tool carries, landed or refused
    /// (VX-811's fixed `waits` sentence — never conditional on any state).
    func performNoteList(
        _ items: [NoteListItem], tool: String, ops: Operations, clientName: String,
        always: [String: Any] = [:]
    ) throws -> Result<Landed, Refused> {
        let runKey = "\(tool)·\(UUID().uuidString)"
        var results: [Any] = []
        var receipts: [MCPWriteReceipt] = []
        var landed = 0
        for item in items {
            let outcome: Result<Landed, Refused>
            do {
                outcome = try perform(item.job, ops: ops, clientName: clientName)
            } catch {
                // An item's unexpected failure is THAT item's refusal, in the
                // one chain's words (VX-369) — the rest still run.
                outcome = .failure(Refused(outcome: Outcome(
                    text: MCPWireRefusalCopy.unexpected(error, tool: tool, appWords: hooks.refusalWords),
                    isError: true)))
            }
            switch outcome {
            case .success(let one):
                landed += 1
                results.append(try JSONSerialization.jsonObject(with: Data(one.answer.utf8)))
                receipts += one.receipts.map { receipt in
                    var stamped = receipt
                    stamped.runKey = runKey
                    return stamped
                }
            case .failure(let refused):
                results.append(["note_id": item.noteID, "refused": refused.outcome.text] as [String: Any])
            }
        }
        var answer: [String: Any] = [
            "results": results, "landed_count": landed, "refused_count": items.count - landed,
        ]
        answer.merge(always) { kept, _ in kept }
        // A call that landed NOTHING is an error answer (the same body — every
        // item's refusal — so the client's error branch fires exactly when
        // nothing happened); any landed item makes it a success (PROVISIONAL,
        // the VX-809 bundle).
        guard landed > 0 else {
            return .failure(Refused(outcome: Outcome(text: try encode(answer), isError: true)))
        }
        return .success(Landed(answer: try encode(answer), receipts: receipts))
    }
}
