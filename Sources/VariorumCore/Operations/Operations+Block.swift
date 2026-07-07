import Dependencies
import Foundation
import GRDB

extension Operations {
    /// Everything `newBlock` mints, for callers and state-transition tests.
    public struct NewBlockResult: Equatable, Sendable {
        public let block: Block
        public let variant: Variant
        public let placement: ContainerBlock
    }

    /// AppSpec §9: INSERT block; INSERT variant(working_text=text); set
    /// block.default_variant_id; INSERT container_block(chosen=variant).
    /// The block↔variant FK circle resolves by inserting the block with a
    /// NULL default first, then pointing it at the freshly inserted variant.
    ///
    /// Minting text is working on the post (author decision 2026-07-07,
    /// QUESTIONS #5 option (a) — AppSpec §14's Phase 8 checkpoint delta):
    /// the mint stamps `last_touched_at` and feeds churn with the minted
    /// text's length, exactly like the other text-changing ops (§10 applies
    /// a fortiori after the 2026-07-06 structural-stamp ruling). This also
    /// closes both of Phase 8's documented idle-sweep residual gaps: a
    /// mint-only burst and an idle-/teardown-minted tail now re-enter the
    /// sweep's touch window like any other edit.
    @discardableResult
    public func newBlock(
        in containerID: String, text: String, at insert: InsertPosition = .end
    ) throws -> NewBlockResult {
        try database.write { db in
            let container = try liveContainer(db, containerID)
            try ensureUnlocked(container)

            let now = date.now
            let minted = try mintBlock(db, text: text, in: containerID, at: insert, now: now)
            try registerTextChange(
                db, blockID: minted.block.id, charDelta: text.count,
                forceMajorRevision: false, now: now)
            return NewBlockResult(
                block: minted.block, variant: minted.variant, placement: minted.placement)
        }
    }
}
