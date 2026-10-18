import Dependencies
import Foundation
import GRDB

// THE MCP DOOR's BLOCK INSERT (VX-255, VX-336 U5b — the run record
// `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`, U5b D4–D9 and the
// orchestrator's rulings on its forks). Her doors add a block anywhere — ⌘⇧⏎
// (`newBlock(at: .after(block))`), the Return key's act, paste (`importBlocks`)
// — and the wire could only mint a whole note or divide a block whose text
// already held the words (R-VX184-1's parity gap). Her ruling: *"write new
// lets them add blocks at the end, edit lets them write blocks anywhere."*
// Where the run lands and which rung it needs are the wire's
// (`MCPWriteTools+InsertBlocks`); this is the act, on §9 newBlock's road.
extension Operations {
    /// **`insert_blocks`' act** — each given block minted as ONE block (its
    /// text exactly: a blank line inside stays inside, I4 — create_note's
    /// structured rule, so there is no segmentation), in the given order,
    /// starting at `insert` and each next one right after the one before (the
    /// run keeps its order wherever it lands): its text the shown take, chosen
    /// AND default; its takes after it at the fan's end, unchosen, never
    /// locked, labels as given, a blank take kept (R-VX171-2); its name, when
    /// it has one. ONE transaction: the caller's guard FIRST (the wire's
    /// re-decision at the call's rung, spending a once grant atomically with
    /// the act); the note live, a post, not sealed (`lockedPost` — a sealed
    /// post refuses every authoring write under it); a LOCKED take anywhere,
    /// the anchor's included, never refuses — no take is touched (her ⌘⇧⏎
    /// below a locked take doesn't refuse either). An `.after` anchor is
    /// resolved INSIDE the transaction (`blockNotPlaced` when it is not live
    /// in this note — a block that left since never anchors). Minting text is
    /// working on the post (newBlock's stamp rule — touch + churn per block,
    /// `importBlocks`' precedent); fan growth never churns.
    ///
    /// **ONE undo entry, newBlock's own helper** (`registerStructuralEntry`
    /// with the minted pre-images — the VX-246 SWEEP TABLE rows 2–13's road):
    /// an untouched block vanishes on ⌥⌘Z, one she has worked on since lands in
    /// the note's tray (the insurance doctrine), a sealed note refuses the undo
    /// and keeps the entry; each half answers whether it changed anything (the
    /// quiet-half rule, §9), and the redo returns the very rows.
    ///
    /// Returns what it minted, per block, in order — VX-252's record
    /// (`MintedBlockTakes`), built from the mint's own rows, no second read.
    @discardableResult
    public func insertBlocks(
        _ blocks: [MCPNoteBlock], intoNote noteID: String, at insert: InsertPosition, undoLabel: String,
        guardedBy guardian: WriteGuard? = nil
    ) throws -> [MintedBlockTakes] {
        guard !blocks.isEmpty else { throw OperationError.emptyImport }
        let minted: [MintedFanBlock] = try database.write { db in
            try guardian?(db)
            try ensureUnlocked(try livePost(db, noteID))
            let now = date.now
            var at = insert
            var minted: [MintedFanBlock] = []
            for block in blocks {
                let position = try containerPosition(db, containerID: noteID, at: at)
                let fan = try mintFanBlock(
                    db, texts: [block.text] + block.takes.map(\.text), in: noteID, position: position,
                    defaultIndex: 0, chosenIndex: 0, labels: [nil] + block.takes.map(\.label), now: now)
                // `createStructuredNote`'s finish: a trimmed, non-empty name.
                // VX-357: U+0000 removed from the name first (`StoredText`);
                // the texts and labels at the row (`mintFanBlock`), and the
                // churn counts the shown text as stored.
                if let name = StoredText.stripped(block.name)?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !name.isEmpty {
                    try db.execute(sql: "UPDATE block SET name = ? WHERE id = ?", arguments: [name, fan.block.id])
                }
                try registerTextChange(
                    db, blockID: fan.block.id, charDelta: fan.variants[0].workingText.count,
                    forceMajorRevision: false, now: now)
                minted.append(fan)
                at = .after(fan.block.id)
            }
            return minted
        }
        registerStructuralEntry(
            label: undoLabel, minting: minted.map { MintedPreImage($0.block.id, $0.variants) })
        return minted.map { MintedBlockTakes($0) }
    }
}
