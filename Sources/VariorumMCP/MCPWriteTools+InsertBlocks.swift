import Foundation
import GRDB
import MCP
import VariorumCore

/// **`insert_blocks` — blocks added to a note that exists** (VX-255, VX-336
/// U5b — the run record's D4–D10 and the orchestrator's rulings on the forks).
/// Her ruling: *write new lets them add blocks at the end, edit lets them write
/// blocks anywhere.* A thin projection of `Operations.insertBlocks` (newBlock's
/// road: one transaction, one client-named undo).
///
/// **The rung is read from the call's ARGUMENTS alone** (P-VX255-1, P-VX255-2):
/// no anchor (or `at: "end"`) lands at the note's END at WRITE NEW; ANY
/// `after_block_id` — the note's last block included — or `at: "start"` needs
/// EDIT. One legible rule, decided before any read of the note's order, so it
/// never flips rung under her typing (crystallization mints her paragraphs at
/// the end as she types past them) and an anchorless call always lands at the
/// current end. A write-new holder passing an anchor is decided on the note at
/// EDIT and hears the rungTooLow family's sentence, with the ask queued quietly
/// for her — never the not-shared shape for a note it can read.
///
/// **The edit-act pattern** (`+Batches`, `+Edit`): the snapshot decides the
/// note at the call's rung (`onNote`, `spendsAfter: false`) and speaks the
/// refusal or raises the ask; the act's guard re-decides inside the act's own
/// transaction and spends any once grant there. The anchor is looked at only
/// AFTER the note's decision (an unreachable note never reveals a block): a
/// block live-placed in THIS note (`placedBlocks`, ∝ the one id), else ONE
/// sentence for a block of another note and for nothing alike; the act
/// re-resolves it inside its transaction, and a block that left in between is
/// said in the same words.
///
/// **THE CAP** (P-VX255-4): at most `batchCap` (200) blocks a call, stated in
/// the description and refused naming it — the act runs on her runner while
/// her note may be open (the takes batch's argument), and the tool exists
/// partly to write big documents in chunks.
extension MCPWriteTools {
    /// Where the run lands.
    enum BlockInsertPlace: Sendable, Equatable {
        /// The note's end — write new.
        case end
        /// Before the note's first block — edit (`move_block`'s word).
        case start
        /// Right after this block of the note — edit.
        case after(String)

        /// The rung the call needs, read from its arguments alone.
        var rung: MCPGrantRule.Rung {
            switch self {
            case .end: .writeNew
            case .start, .after: .edit
            }
        }

        var insert: Operations.InsertPosition {
            switch self {
            case .end: .end
            case .start: .start
            case .after(let blockID): .after(blockID)
            }
        }
    }

    /// The anchor that isn't a block of this note — one sentence for a block
    /// of another note and for nothing at all (no oracle).
    static let anchorNotThisNotesWords =
        "after_block_id isn't a block of this note — read_note with with_ids: true gives its block ids."

    // MARK: - Arguments (parsed BEFORE the executor — independent of any target)

    func parseInsertBlocks(_ args: [String: Value]) throws -> Job {
        let noteID = try requiredString(args, "note_id")
        let anchor = try optionalString(args, "after_block_id")
        if let anchor, anchor.isEmpty { throw ArgumentFailure(message: "after_block_id must be a block id.") }
        let at = try optionalString(args, "at")
        if let at, at != "start", at != "end" { throw ArgumentFailure(message: "at must be \"start\" or \"end\".") }
        if anchor != nil, at != nil { throw ArgumentFailure(message: "Pass after_block_id or at, not both.") }
        guard let value = args["blocks"], value != .null else { throw ArgumentFailure(message: "blocks is required.") }
        guard let list = value.arrayValue else { throw ArgumentFailure(message: "blocks must be an array.") }
        guard !list.isEmpty else { throw ArgumentFailure(message: "blocks must list at least one block.") }
        guard list.count <= Self.batchCap else {
            throw ArgumentFailure(message: Self.overCapWords(
                tool: MCPToolCatalog.insertBlocks.name, noun: "blocks", count: list.count))
        }
        let place: BlockInsertPlace = if let anchor { .after(anchor) } else if at == "start" { .start } else { .end }
        return .insertBlocks(noteID: noteID, place: place, blocks: try noteBlocks(value))
    }

    // MARK: - The serial body

    func performInsertBlocks(
        noteID: String, place: BlockInsertPlace, blocks: [Operations.MCPNoteBlock], job: Job, ops: Operations,
        clientName: String
    ) throws -> Result<Landed, Refused> {
        try onNote(noteID, rung: place.rung, job: job, clientName: clientName, spendsAfter: false) { title in
            var anchorID: String?
            if case .after(let anchor) = place {
                anchorID = anchor
                let placed = try database.read { db in try Self.placedBlocks(db, among: [anchor], in: noteID) }
                guard placed.contains(anchor) else { throw ArgumentFailure(message: Self.anchorNotThisNotesWords) }
            }
            let minted: [Operations.MintedBlockTakes]
            do {
                minted = try ops.insertBlocks(
                    blocks, intoNote: noteID, at: place.insert,
                    undoLabel: Operations.MCPWriteAct.blocks.undoLabel(client: clientName),
                    guardedBy: guardNotes(clientName, rung: place.rung) { _ in [noteID] })
            } catch OperationError.blockNotPlaced(let id) where id == anchorID {
                // The anchor left this note between the look and the act.
                throw ArgumentFailure(message: Self.anchorNotThisNotesWords)
            }
            return (["note_id": noteID, "block_ids": minted.map(\.blockID), "blocks": MCPMintedBlocks.records(minted)],
                    MCPWriteReceipt(clientName: clientName, act: .blocks, targetID: noteID, targetTitle: title,
                                    count: minted.count,
                                    show: .note(noteID: noteID, blockID: minted.first?.blockID, select: nil)))
        }
    }
}
