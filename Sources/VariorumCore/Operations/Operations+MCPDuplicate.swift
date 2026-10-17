import Dependencies
import Foundation
import GRDB

// THE MCP DOOR's DUPLICATE (VX-311, VX-336 U6a — the run record
// `notes/plans/fixes/vx-336-mcp-wire-tools-ai-docs.md`, U6a D-311-1…8 and THE
// ORCHESTRATOR'S RULINGS ON U6a's FORKS). Her words: *"if you save the note as a
// version and immediately promote the version it duplicates the note."* The
// effect she names is her own Duplicate as Version — the door whose copy
// machine Compare's kinship reads (one `derived_from` edge per copied block, so
// the copy lines up with its source row for row). Save-then-promote is NOT the
// same result (no tags, no date, sealed commits, two acts and no undo for the
// second — D-311-1, CONFIRMED), so the wire wraps HER op: its body
// (`duplicateAsVersionBody`, extracted once so the two doors can never drift),
// run inside ONE transaction behind the caller's `WriteGuard`, with ONE
// client-named undo entry. Where the copy lands and what reach decides it are
// the wire's (`MCPWriteTools+DuplicateNote`).
extension Operations {
    /// **`duplicate_note`'s act** — her Duplicate as Version exactly
    /// (`duplicateAsVersionBody`: the note's container row copied — title,
    /// profile, entry date, notes, segmentation — never born locked; every live
    /// slot with its whole live fan, archived takes riding with their statuses,
    /// commits never copied, parent trees remapped, comments, presentation and
    /// block names riding; one `derived_from` edge per copied block and ONE
    /// `version_of` anchor; the note's live tags by `tags` — `.applied` (the
    /// default, P-C-3) APPLIES each through the one road so intake hears it
    /// (VX-372, D-C-1 — a living book may seat or bell the copy in this same
    /// transaction), `.none` leaves them; BOOKLESS in the source's wing (unless
    /// intake took it in) — reading memberships,
    /// references and lenses never ride), the caller's guard FIRST inside the
    /// transaction (the wire's two decisions, re-made on the act's own facts,
    /// once grants stamped there — AF-10 (a)'s seam). A sealed source is legal
    /// (reading isn't authoring; the source is never touched); a blockless one
    /// refuses `postHasNoBlocks` (her door's own refusal).
    ///
    /// **ONE undo entry, her door's own helper** (`registerMintedContainerEntry`,
    /// the VX-119 single-container pair — D-311-5): ⌥⌘Z tombstones the copy
    /// (into the Trash, recoverable — nothing typed becomes unreachable); a copy
    /// already dead (her Delete since, a sync tombstone) changes nothing and
    /// RETIRES the entry (§9's quiet-half rule); the redo revives the copy only
    /// while it is dead on the stamp its own undo wrote. The label is the
    /// client's (`MCPWriteAct.duplicate` — "claude-code's duplicate").
    ///
    /// Returns her door's result with `blocks` — what the copy minted, per
    /// block (VX-252's records, `sourceBlockID` set), from the copy machine's
    /// own rows (∝ the copy, no second read).
    ///
    /// **`tags`** (VX-372, VX-383 U1): the SAME choice as her door's, through
    /// the same body, so the two can never drift (D-C-1). Defaulted to her
    /// door's `.applied` — the ruled wire default (P-C-3); the wire's
    /// `with_tags` argument is VX-371's (U2, D-C-4).
    @discardableResult
    public func duplicateNoteForClient(
        _ postID: String, tags: DuplicateTags = .applied, undoLabel: String,
        guardedBy guardian: WriteGuard? = nil
    ) throws -> PostCopyResult {
        let result: PostCopyResult = try database.write { db in
            try guardian?(db)
            return try duplicateAsVersionBody(db, postID, tags: tags)
        }
        registerMintedContainerEntry(label: undoLabel, result.post.id)
        return result
    }
}
