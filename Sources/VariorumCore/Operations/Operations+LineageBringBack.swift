import Foundation
import GRDB

// VX-801 (VX-827 U3b — `notes/plans/fixes/vx-827-lineage.md`, U3b-P and its
// ruling) — **BRING BACK AS TAKE, ACROSS LINEAGE.** Her sitting ruling,
// verbatim: *"mints the node's active text as a new take on the block you came
// from — the bringBackCommitAsTake shape, cross-block; parent lineage via the
// existing edge."*
extension Operations {
    /// What a lineage bring-back copies: a TAKE's text as it stands (the
    /// node's active text, or any take of a relative the face shows) or a
    /// COMMIT's immutable text (a relative's saved moment — her goal of
    /// finding commits on ancestor blocks' takes, recovery being the point).
    public enum LineageTakeSource: Equatable, Sendable {
        case take(String)
        case commit(String)
    }

    /// **A relative's text becomes a take on the block you came from**
    /// (U3b-P RULED — every lean sustained).
    ///
    /// The row: ONE `variant` on `blockID` — the source's text; NO parent
    /// (every parent pointer in the store is same-block; the
    /// `derived_from` / `version_of` edge that already joins the two blocks
    /// carries the lineage, and no edge is minted); active, never locked; the
    /// label the source's name when it has one (a commit's message, a take's
    /// label — `bringBackCommitAsTake`'s rule, through the same
    /// normalisation), else none; at the fan's END. Never chosen (no
    /// `container_block` write), never the block's default, and nothing else
    /// written — no edge, commit, comment or presentation.
    ///
    /// **Posture:** `branchVariant`'s, exactly as `bringBackCommitAsTake`'s —
    /// no `last_touched_at`, no churn, NO structural-undo entry (the road back
    /// is deleting the take). Archived and locked sources are allowed: the
    /// source is only read.
    ///
    /// **Refusals, in this order, inside one transaction:** the target missing
    /// or tombstoned (`blockNotFound`); the target under a sealed note
    /// (`lockedPost`); an unknown commit (`commitNotFound`); the source take
    /// missing or tombstoned (`variantNotFound`); the source's block
    /// tombstoned (`blockNotFound` — a Trash node; restoring from the Trash
    /// stays on its own surface); and **the lineage fence** (`notInLineage`):
    /// the source's block must be a node of the target's lineage tree
    /// (`Queries.lineageTree`, read in this transaction — admitted edges,
    /// ancestors, descendants and version siblings; cost ∝ that block's own
    /// lineage, P1), never the target itself, and never across wings — a node
    /// whose home is a note in another wing than the target's note (the
    /// scraps are the one shared room, so a pool home crosses nothing).
    @discardableResult
    public func bringBackFromLineage(
        _ source: LineageTakeSource, onto blockID: String
    ) throws -> Variant {
        try database.write { db in
            _ = try liveBlock(db, blockID)
            try ensurePlacementUnlocked(db, blockID: blockID)
            let text: String
            let name: String?
            let sourceTake: Variant
            switch source {
            case .commit(let commitID):
                guard let commit = try CommitPoint.fetchOne(db, key: commitID) else {
                    throw OperationError.commitNotFound(id: commitID)
                }
                sourceTake = try liveVariant(db, commit.variantId)
                text = commit.text
                name = commit.message
            case .take(let variantID):
                sourceTake = try liveVariant(db, variantID)
                text = sourceTake.workingText
                name = sourceTake.label
            }
            let sourceBlockID = sourceTake.blockId
            _ = try liveBlock(db, sourceBlockID)
            guard sourceBlockID != blockID,
                  let tree = try Queries.lineageTree(db, blockID: blockID),
                  let node = tree.nodes.first(where: { $0.blockID == sourceBlockID }),
                  !Self.lineageCrossesWing(tree.origin.home, node.home)
            else {
                throw OperationError.notInLineage(sourceBlockID: sourceBlockID, targetBlockID: blockID)
            }
            let last = try String.fetchOne(
                db,
                sql: "SELECT MAX(fan_position) FROM variant WHERE block_id = ? AND deleted_at IS NULL",
                arguments: [blockID])
            let trimmed = StoredText.stripped(name)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let now = date.now
            let variant = Variant(
                id: newID(), blockId: blockID, parentVariantId: nil,
                workingText: text,
                label: (trimmed?.isEmpty ?? true) ? nil : trimmed,
                fanPosition: FractionalIndex.between(last, nil),
                createdAt: now, updatedAt: now)
            try variant.insert(db)
            return variant
        }
    }

    /// **The wing fence's one rule** — two homes cross only when BOTH are
    /// notes and their wings differ; the scraps (a pool) are the one shared
    /// room, and a home that is not known crosses nothing.
    public static func lineageCrossesWing(
        _ target: Queries.LineageHome?, _ source: Queries.LineageHome?
    ) -> Bool {
        guard let target, let source, target.kind == .post, source.kind == .post else { return false }
        return target.wingID != source.wingID
    }
}
