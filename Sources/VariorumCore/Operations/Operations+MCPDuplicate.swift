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
    ///
    /// This spelling files nothing and answers her door's result — the
    /// filing-less road (VX-371's book road is the overload below, which this
    /// one calls, so the two are one act).
    @discardableResult
    public func duplicateNoteForClient(
        _ postID: String, tags: DuplicateTags = .applied, undoLabel: String,
        guardedBy guardian: WriteGuard? = nil
    ) throws -> PostCopyResult {
        try duplicateNoteForClient(
            postID, tags: tags, filing: nil, undoLabel: undoLabel, guardedBy: guardian
        ).copy
    }

    /// **What `duplicate_note` minted** (VX-371, VX-383 U2 — D-C-4): her
    /// door's copy, and what the wire says about it — every fact read INSIDE
    /// the act's transaction (U5b's D1: never a read after the commit, so no
    /// race with her next act).
    public struct MCPDuplicate: Equatable, Sendable {
        /// Her door's result (the copy, its block copies, the version anchor,
        /// VX-252's records).
        public let copy: PostCopyResult
        /// EVERY tag the copy wears once the act lands (P-VX361-1's shape —
        /// `mintedNoteTags`): the tags it was APPLIED from the source, in the
        /// source's application order, then the destination book's OUTFLOW in
        /// its order, each listed once; `tagPaths` parallel.
        public let tagIDs: [String]
        public let tagPaths: [String]
        /// Every live BOOK the copy is a MEMBER of once the act lands (an
        /// arrival is no membership): the filing's book first, then any a
        /// living book's intake SEATED it in, in seating order.
        public let memberBookIDs: [String]
    }

    /// **`duplicate_note`'s act, with its book road** (VX-371, VX-383 U2 —
    /// D-C-4). Her Duplicate's body (`duplicateAsVersionBody` — the one body,
    /// so her doors and the wire never drift), the caller's guard FIRST inside
    /// the transaction, `filing` threading the copy into a book in the body's
    /// order (the book's gates and the chapter, the copy, the membership with
    /// the outflow, then the `tags` applications), then — still inside the
    /// transaction — the answered facts (`MCPDuplicate`). ONE undo entry
    /// (`registerMintedContainerEntry`): its inverse tombstones the copy and
    /// the container trigger takes the membership, the applications and any
    /// seats or bells with it on that one stamp; the redo's exact-stamp
    /// revival returns exactly those (a row she judged between keeps her
    /// judgment — U1's pins).
    @discardableResult
    public func duplicateNoteForClient(
        _ postID: String, tags: DuplicateTags = .applied, filing: DuplicateFiling?, undoLabel: String,
        guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPDuplicate {
        let result: MCPDuplicate = try database.write { db in
            try guardian?(db)
            let copy = try duplicateAsVersionBody(db, postID, tags: tags, filing: filing)
            let applied = tags == .applied ? try liveTagIDs(db, of: postID, inWing: copy.post.wingId) : []
            let outflow = try filing.map { try liveReading(db, $0.bookID).autoTagIDs } ?? []
            let worn = try mintedNoteTags(db, postID: copy.post.id, header: applied, outflow: outflow)
            let seated = try String.fetchAll(
                db,
                sql: """
                    SELECT rp.reading_id FROM reading_post rp
                    JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL AND r.kind = 'book'
                    WHERE rp.post_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                    ORDER BY rp.created_at, rp.id
                    """,
                arguments: [copy.post.id])
            let books = (filing.map { [$0.bookID] } ?? []) + seated.filter { $0 != filing?.bookID }
            return MCPDuplicate(
                copy: copy, tagIDs: worn.map(\.id), tagPaths: worn.map(\.path), memberBookIDs: books)
        }
        registerMintedContainerEntry(label: undoLabel, result.copy.post.id)
        return result
    }
}
