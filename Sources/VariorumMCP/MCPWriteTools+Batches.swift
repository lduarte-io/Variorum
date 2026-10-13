import Foundation
import GRDB
import MCP
import VariorumCore

/// **THE SUGGEST RUNG's BATCH DOORS** (VX-184 U3 — VX-173, the door half):
/// `add_takes` and `add_comments`, thin projections of `Operations+MCPBatches`
/// — `add_take` and `add_comment` made ONE act for one note: one decision, one
/// transaction, one client-named undo entry, one receipt, one Activity line.
///
/// **The edit-act pattern (VX-168 U2's), carried to these new acts:** the
/// snapshot decides the note at SUGGEST (`onNote`, `spendsAfter: false`) and
/// speaks the refusal or raises the ask; the act's `WriteGuard` re-decides
/// inside the act's own transaction and spends any once grant there, atomic
/// with the act — the single suggest doors' decide-then-act gap (P-13nb-U2-8)
/// is not inherited.
///
/// **All-or-nothing, naming the item:** an argument fault is refused at the
/// parse (`takes[3].text is required.`); an item whose block is not a live
/// block of the note is refused naming it, in the SAME words whether the id
/// names a block of another note or nothing at all (no oracle); an op refusal
/// inside the transaction rolls every item back and names the item it met.
///
/// **THE CAP — `batchCap` (200), stated in each tool's description; an
/// over-cap call is refused naming it.** Measured (the run record's piece 4):
/// ≈1 ms per item on an encrypted on-disk store in a Debug build — and the
/// batch runs on HER runner (AF-8), so its transaction holds her gestures for
/// its whole length; 200 keeps that under a fifth of a second, and is the
/// house's per-call bound (`list_notes`' page, `read_note`'s carriage cap).
extension MCPWriteTools {
    enum BatchJob: Sendable {
        case takes(noteID: String, items: [Operations.MCPTakeItem])
        case comments(noteID: String, items: [Operations.MCPCommentItem])

        var tool: String {
            switch self {
            case .takes: MCPToolCatalog.addTakes.name
            case .comments: MCPToolCatalog.addComments.name
            }
        }
    }

    /// The most items one batch carries (argued above).
    static let batchCap = 200

    /// The over-cap refusal — the cap named, the road said.
    static func overCapWords(tool: String, noun: String, count: Int) -> String {
        "\(tool) takes at most \(batchCap) \(noun) in one call; this call has \(count). "
            + "Split it into calls of \(batchCap) or fewer."
    }

    /// An item whose block is not a live block of the note — one sentence for
    /// "elsewhere" and "nowhere" alike.
    static func notThisNotesBlockWords(_ path: String) -> String {
        "\(path).block_id isn't a block of this note — read_note with with_ids: true gives its block ids."
    }

    // MARK: - Arguments (parsed BEFORE the executor)

    func parseBatch(_ name: String, _ args: [String: Value]) throws -> BatchJob? {
        switch name {
        case MCPToolCatalog.addTakes.name:
            let noteID = try requiredString(args, "note_id")
            let items = try batchItems(args, key: "takes", noun: "takes", tool: name)
            return .takes(noteID: noteID, items: try items.enumerated().map { index, fields in
                let path = "takes[\(index)]"
                // A blank take is a legal take (R-VX171-2): the text must be
                // SAID — no text at all is no take — and may be empty.
                guard let value = fields["text"], value != .null else {
                    throw ArgumentFailure(message: "\(path).text is required.")
                }
                guard let text = value.stringValue else { throw ArgumentFailure(message: "\(path).text must be a string.") }
                var label: String?
                if let value = fields["label"], value != .null {
                    guard let string = value.stringValue else {
                        throw ArgumentFailure(message: "\(path).label must be a string.")
                    }
                    label = string
                }
                return Operations.MCPTakeItem(blockID: try itemBlockID(fields, path), text: text, label: label)
            })
        case MCPToolCatalog.addComments.name:
            let noteID = try requiredString(args, "note_id")
            let items = try batchItems(args, key: "comments", noun: "comments", tool: name)
            return .comments(noteID: noteID, items: try items.enumerated().map { index, fields in
                let path = "comments[\(index)]"
                if let value = fields["text"], value != .null, value.stringValue == nil {
                    throw ArgumentFailure(message: "\(path).text must be a string.")
                }
                guard let text = fields["text"]?.stringValue,
                      !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                else { throw ArgumentFailure(message: "\(path).text is required — a comment can't be blank.") }
                return Operations.MCPCommentItem(blockID: try itemBlockID(fields, path), text: text)
            })
        default:
            return nil
        }
    }

    /// The batch's list: present, an array, at least one item, at most the
    /// cap, every item an object.
    private func batchItems(
        _ args: [String: Value], key: String, noun: String, tool: String
    ) throws -> [[String: Value]] {
        guard let value = args[key], value != .null else { throw ArgumentFailure(message: "\(key) is required.") }
        guard let list = value.arrayValue else { throw ArgumentFailure(message: "\(key) must be an array.") }
        guard !list.isEmpty else {
            throw ArgumentFailure(message: "\(key) must list at least one \(noun == "takes" ? "take" : "comment").")
        }
        guard list.count <= Self.batchCap else {
            throw ArgumentFailure(message: Self.overCapWords(tool: tool, noun: noun, count: list.count))
        }
        return try list.enumerated().map { index, item in
            guard let fields = item.objectValue else { throw ArgumentFailure(message: "\(key)[\(index)] must be an object.") }
            return fields
        }
    }

    private func itemBlockID(_ fields: [String: Value], _ path: String) throws -> String {
        guard let value = fields["block_id"], value != .null else {
            throw ArgumentFailure(message: "\(path).block_id is required.")
        }
        guard let id = value.stringValue, !id.isEmpty else {
            throw ArgumentFailure(message: "\(path).block_id must be a block id.")
        }
        return id
    }

    // MARK: - The serial body

    func performBatch(_ batch: BatchJob, job: Job, ops: Operations, clientName: String) throws -> Result<Landed, Refused> {
        let label = { (act: Operations.MCPWriteAct) in act.undoLabel(client: clientName) }
        switch batch {
        case .takes(let noteID, let items):
            return try onNote(noteID, rung: .suggest, job: job, clientName: clientName, spendsAfter: false) { title in
                try requireBlocks(items.map(\.blockID), of: noteID, key: "takes")
                let labeled = items.map { item in
                    Operations.MCPTakeItem(
                        blockID: item.blockID, text: item.text, label: Self.aiLabel(client: clientName, own: item.label))
                }
                let takes = try itemized("takes") {
                    try ops.addTakes(
                        labeled, inNote: noteID, undoLabel: label(.takes),
                        guardedBy: guardNotes(clientName, rung: .suggest) { _ in [noteID] })
                }
                return (["note_id": noteID, "take_ids": takes.map(\.id)],
                        MCPWriteReceipt(clientName: clientName, act: .takes, targetID: noteID, targetTitle: title,
                                        count: takes.count,
                                        show: .takes(noteID: noteID, blockID: items[0].blockID)))
            }
        case .comments(let noteID, let items):
            return try onNote(noteID, rung: .suggest, job: job, clientName: clientName, spendsAfter: false) { title in
                try requireBlocks(items.map(\.blockID), of: noteID, key: "comments")
                let comments = try itemized("comments") {
                    try ops.addComments(
                        items, inNote: noteID, author: clientName, undoLabel: label(.comments),
                        guardedBy: guardNotes(clientName, rung: .suggest) { _ in [noteID] })
                }
                return (["note_id": noteID, "comment_ids": comments.map(\.id)],
                        MCPWriteReceipt(clientName: clientName, act: .comments, targetID: noteID, targetTitle: title,
                                        count: comments.count,
                                        show: .note(noteID: noteID, blockID: items[0].blockID, select: nil)))
            }
        }
    }

    /// Every item's block must be a live block of the note — checked on the
    /// snapshot AFTER the note's decision (so a client that cannot reach the
    /// note learns nothing of its blocks) and again inside the act.
    private func requireBlocks(_ blockIDs: [String], of noteID: String, key: String) throws {
        let placed = Set(try database.read { db in
            try String.fetchAll(
                db,
                sql: """
                    SELECT cb.block_id FROM container_block cb
                    JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                    WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                    """,
                arguments: [noteID])
        })
        if let index = blockIDs.firstIndex(where: { !placed.contains($0) }) {
            throw ArgumentFailure(message: Self.notThisNotesBlockWords("\(key)[\(index)]"))
        }
    }

    /// The op's item refusal, said as the item's: a block that left the note
    /// between the snapshot and the act in the snapshot's own words, anything
    /// else in the room's words prefixed by the item.
    private func itemized<T>(_ key: String, _ act: () throws -> T) throws -> T {
        do {
            return try act()
        } catch let refusal as Operations.MCPBatchItemRefusal {
            let path = "\(key)[\(refusal.index)]"
            switch refusal.underlying as? OperationError {
            case .blockNotFound?, .blockNotInContainer?:
                throw ArgumentFailure(message: Self.notThisNotesBlockWords(path))
            default:
                let words = MCPWireRefusalCopy.words(refusal.underlying) ?? hooks.refusalWords(refusal.underlying)
                    ?? String(describing: refusal.underlying)
                throw ArgumentFailure(message: "\(path): \(words)")
            }
        }
    }
}
