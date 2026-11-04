import Dependencies
import Foundation
import GRDB

// THE MCP DOOR's COPY TO WING (VX-765 — the VX-771 run, batch 1; VX-368's
// parity class: her ⇧⌥⌘L Copy to Wing, VX-632, on the wire). Like every act
// the door takes, an ORDINARY OPERATION: HER door's body (`copyNoteToWing(_:_:to:)`
// — `copyPost`'s family born in the destination wing, the note's live tags
// ADOPTED there by path, R-13ia-1, as row copies that no intake hears; bookless,
// so it lands in the destination's Pool; her refusals), run inside ONE
// transaction behind the caller's `WriteGuard`, plus the ONE thing her door
// deliberately lacks and every MCP write carries (P-13nb-U2-4): a client-named
// structural-undo entry — the `move_note_to_wing` wrap's precedent, so her own
// door stays undo-less ("the copy is a real note — the Trash is the road").
extension Operations {
    /// What `copy_note_to_wing` minted, every fact read inside the act's
    /// transaction: the copy, VX-252's records of its blocks, and the tags it
    /// wears in the destination (ids and paths, application order, each once).
    public struct MCPWingCopy: Equatable, Sendable {
        public let copy: Container
        public let blocks: [MintedBlockTakes]
        public let tagIDs: [String]
        public let tagPaths: [String]
    }

    /// **`copy_note_to_wing`'s act** — her Copy to Wing exactly, the caller's
    /// guard FIRST inside the transaction (the wire's two decisions re-made on
    /// the act's own facts, once grants stamped there — AF-10 (a)'s seam). Her
    /// refusals are hers, unchanged: `postAlreadyInWing`, `wingNotFound`,
    /// `postNotFound` — each rolls the whole act back.
    ///
    /// ONE undo entry (`registerMintedContainerEntry`, the VX-119 single-
    /// container pair the duplicate uses): ⌥⌘Z tombstones the copy — the
    /// container trigger takes its placements, blocks, takes, comments, edges
    /// and tag applications on that one stamp — into the Trash, recoverable; a
    /// copy already dead changes nothing and retires the entry; the redo
    /// revives exactly those rows on the stamp its own undo wrote. Tags the act
    /// MINTED in the destination stay, as vocabulary (P-13nb-U2-6's precedent,
    /// the wing move's).
    @discardableResult
    public func mcpCopyNoteToWing(
        _ postID: String, to wingID: String, undoLabel: String, guardedBy guardian: WriteGuard? = nil
    ) throws -> MCPWingCopy {
        let made: MCPWingCopy = try database.write { db in
            try guardian?(db)
            let body = try copyNoteToWing(db, postID, to: wingID)
            return MCPWingCopy(
                copy: body.copy, blocks: body.blocks, tagIDs: body.tags.map(\.id), tagPaths: body.tags.map(\.path))
        }
        registerMintedContainerEntry(label: undoLabel, made.copy.id)
        return made
    }
}
