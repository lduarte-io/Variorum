import Dependencies
import Foundation
import GRDB

// The inspiration pool's one export gesture: copy + lineage, never shared
// ownership (CoreDescription pillar 6 — reuse is a deliberate operation, not
// transclusion).
extension Operations {
    public struct PoolDragCopyResult: Equatable, Sendable {
        public let block: Block
        /// Fan order; a single element unless `includeFan`.
        public let variants: [Variant]
        public let placement: ContainerBlock
        public let edge: Edge
    }

    /// AppSpec §9: copy a pool block into a draft at the drop point. By
    /// default the copy carries only the rendered variant's text; with
    /// `includeFan` the whole live fan comes along — texts, statuses,
    /// labels, and fan positions copied, the parent tree remapped inside the
    /// copied set. Commits are never copied and copies are not born locked —
    /// lineage is coarse, and the guard belongs to the original. The
    /// placement's chosen (and the block default) is the copy of the
    /// rendered variant. The source must live in a pool and stays untouched;
    /// the target must be an unsealed post (the spec names pool→draft; other
    /// copies stay out of scope until the author asks).
    @discardableResult
    public func poolDragCopy(
        _ poolBlockID: String, to postID: String, at insert: InsertPosition = .end,
        includeFan: Bool = false
    ) throws -> PoolDragCopyResult {
        let result: PoolDragCopyResult = try database.write { db in
            let source = try liveBlock(db, poolBlockID)
            guard let sourcePlacement = try livePlacement(db, blockID: poolBlockID),
                  try liveContainer(db, sourcePlacement.containerId).kind == .pool
            else { throw OperationError.blockNotInPool(id: poolBlockID) }
            let target = try livePost(db, postID)
            try ensureUnlocked(target)
            let rendered = try renderedVariant(db, block: source, placement: sourcePlacement)

            let now = date.now
            // Phase 13 (A2): the copy is a copy — the callout frame rides
            // (identity-level metadata, the block-name/copyPost family).
            // 13b Stage 4 (4D — S4-27e, her ruling): the NAME rides too. The
            // recorded pre-13 asymmetry dies: a named scrap dragged into a
            // draft keeps its name, consistent with duplicateAsVersion /
            // promoteLens (identity-level metadata travels with the copy).
            var copy = Block(
                id: newID(), ownerId: currentOwnerID(),
                name: source.name,
                presentation: source.presentation, createdAt: now, updatedAt: now)
            try copy.insert(db)

            var variants: [Variant] = []
            let renderedCopyID: String
            if includeFan {
                let fan = try Variant.fetchAll(
                    db,
                    sql: """
                        SELECT * FROM variant
                        WHERE block_id = ? AND deleted_at IS NULL
                        ORDER BY fan_position, id
                        """,
                    arguments: [poolBlockID])
                // 13e E4's rider: THE one fan-copy machine
                // (`copyFan`), whose second pass lands a parent that sits
                // LATER in fan order — reachable since reorder-takes made
                // `fan_position` mutable (the KnownIssues row's FIX-2).
                let copied = try copyFan(db, takes: fan, toBlock: copy.id, now: now)
                variants = copied.variants
                // The rendered variant is live, so its copy always exists.
                renderedCopyID = copied.copyIDs[rendered.id] ?? variants[0].id
            } else {
                let variant = Variant(
                    id: newID(), blockId: copy.id,
                    workingText: rendered.workingText, label: rendered.label,
                    fanPosition: FractionalIndex.initial(),
                    createdAt: now, updatedAt: now)
                try variant.insert(db)
                variants = [variant]
                renderedCopyID = variant.id
            }

            copy.defaultVariantId = renderedCopyID
            try copy.update(db)

            let placement = ContainerBlock(
                id: newID(), containerId: postID, blockId: copy.id,
                position: try containerPosition(db, containerID: postID, at: insert),
                chosenVariantId: renderedCopyID,
                createdAt: now, updatedAt: now)
            try placement.insert(db)

            let edge = try insertLineageEdge(
                db, from: copy.id, to: poolBlockID, originOp: "pool_copy", now: now)
            // Phase 13 (A2) travel: the scrap's working notes ride the copy
            // (the plan's letter: pool-copy carries them); the pool original
            // keeps its own.
            try copyLiveComments(db, from: poolBlockID, to: copy.id, now: now)
            try touchContainer(db, postID, now: now)
            return PoolDragCopyResult(
                block: copy, variants: variants, placement: placement, edge: edge)
        }
        registerStructuralEntry(
            label: "Pool Copy",
            minting: [.init(result.block.id, result.variants)])
        return result
    }
}
