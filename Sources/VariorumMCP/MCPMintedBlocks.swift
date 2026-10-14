import Foundation
import VariorumCore

/// **THE SHARED ANSWER SHAPE — what a write minted, block by block** (VX-252,
/// VX-336 U5b — the run record's D1, CONFIRMED by the orchestrator's ruling).
/// Named ONCE, so every tool that mints blocks answers in one vocabulary:
/// `create_note` and `import_document` (one document) since VX-252,
/// `insert_blocks` (VX-255) and U6's `duplicate_note` after it. Per block, in
/// note order:
///
/// ```json
/// {"block_id": "…", "shown_take_id": "…", "takes": [{"take_id": "…"}, {"take_id": "…", "label": "english"}]}
/// ```
///
/// read_note's own words (`block_id`, `shown_take_id`, `take_id`, `label` —
/// omitted when the take has none), no text. `takes` lists EVERY take in fan
/// order, the shown one included, each an OBJECT — so U7's VX-254 adds its
/// per-take digest as one more field, and nothing anywhere is positional.
/// Built from the core's record of what the act minted
/// (`Operations.MintedBlockTakes`), never a second read: ∝ the write.
///
/// VX-311 (VX-336 U6a — D-311-4, F-4 (a)): a COPIED block's record also names
/// the block it was copied from (`source_block_id` — `duplicate_note`'s), so a
/// client edits "the copy of block X" without guessing by position. Emitted
/// only when set, so every mint's answer is byte-unchanged.
enum MCPMintedBlocks {
    static func records(_ blocks: [Operations.MintedBlockTakes]) -> [[String: Any]] {
        blocks.map { block in
            var record: [String: Any] = [
                "block_id": block.blockID,
                "shown_take_id": block.shownTakeID,
                "takes": block.takes.map { take -> [String: Any] in
                    var record: [String: Any] = ["take_id": take.id]
                    if let label = take.label { record["label"] = label }
                    return record
                },
            ]
            if let source = block.sourceBlockID { record["source_block_id"] = source }
            return record
        }
    }
}
