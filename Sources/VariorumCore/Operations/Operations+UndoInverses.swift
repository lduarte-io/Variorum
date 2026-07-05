import Dependencies
import Foundation
import GRDB

// The internal revert operations structural undo emits (AppSpec §9). Each is
// an ordinary single-transaction operation — outbox capture and cascade
// rules apply like anywhere else, so sync never knows undo exists. They are
// exact-row inverses: tombstone/status flips plus pre-image restores, never
// fresh rows — which is why do → undo round-trips to row equality. They are
// internal (never registered, never public): only the undo stack calls them.
extension Operations {
    /// Inverse of `deleteBlock`: flip the block, its cascade victims, AND the
    /// original placement row (position + chosen variant intact). Differs
    /// from the public `restoreBlock` tray gesture, which re-places fresh at
    /// the end. The placement stays dead if its container has since died;
    /// a since-locked container refuses (resolve, then retry the undo).
    /// A block already alive (restored from the tray meanwhile) makes this
    /// entry obsolete — a quiet no-op success, so the pop happens and the
    /// stack never wedges on an unresolvable refusal.
    func revertDeleteBlock(_ blockID: String) throws {
        try database.write { db in
            guard var block = try Block.fetchOne(db, key: blockID) else {
                throw OperationError.blockNotFound(id: blockID)
            }
            guard let deletedAt = block.deletedAt else { return }
            let stamp = DateFormatter.variorumISO8601.string(from: deletedAt)
            let now = date.now

            if let placementRow = try Row.fetchOne(
                db,
                sql: "SELECT id, container_id FROM container_block WHERE block_id = ? AND deleted_at = ?",
                arguments: [blockID, stamp]),
               let container = try Container.fetchOne(db, key: placementRow["container_id"] as String),
               container.deletedAt == nil {
                try ensureUnlocked(container)
                try db.execute(
                    sql: "UPDATE container_block SET deleted_at = NULL, updated_at = ? WHERE id = ?",
                    arguments: [
                        DateFormatter.variorumISO8601.string(from: now),
                        placementRow["id"] as String,
                    ])
            }

            block.deletedAt = nil
            block.updatedAt = now
            try block.update(db)
            try flipBlockCascadeTombstones(db, blockID: blockID, stamp: stamp, now: now)
        }
    }

    /// Inverse of `deleteVariant`: flip the tombstone and, when the variant
    /// had been the block default, point the default back at it. The block
    /// must still be live (its own deletion supersedes this entry — undoing
    /// would strand a live variant under a dead block) and its post unsealed
    /// (the seal refuses everything under the post, undo included); either
    /// refusal leaves the entry on the stack for retry.
    func revertDeleteVariant(_ variantID: String, wasDefault: Bool) throws {
        try database.write { db in
            guard var variant = try Variant.fetchOne(db, key: variantID) else {
                throw OperationError.variantNotFound(id: variantID)
            }
            _ = try liveBlock(db, variant.blockId)
            try ensurePlacementUnlocked(db, blockID: variant.blockId)
            let now = date.now
            if variant.deletedAt != nil {
                variant.deletedAt = nil
                variant.updatedAt = now
                try variant.update(db)
            }
            if wasDefault {
                try restoreDefaultVariant(db, blockID: variant.blockId, to: variantID, now: now)
            }
        }
    }

    /// Inverse of `archiveVariant`: back to active, default pointer
    /// restored. Same seal guard as every other write under a post.
    func revertArchiveVariant(_ variantID: String, wasDefault: Bool) throws {
        try database.write { db in
            var variant = try liveVariant(db, variantID)
            try ensurePlacementUnlocked(db, blockID: variant.blockId)
            let now = date.now
            if variant.status == .archived {
                variant.status = .active
                variant.updatedAt = now
                try variant.update(db)
            }
            if wasDefault {
                try restoreDefaultVariant(db, blockID: variant.blockId, to: variantID, now: now)
            }
        }
    }

    /// Inverse of `moveBlock` and `reorder`: put the live placement back at
    /// its exact pre-image location — same container, same position string.
    func restorePlacementLocation(
        _ blockID: String, containerID: String, position: String
    ) throws {
        try database.write { db in
            guard var placement = try livePlacement(db, blockID: blockID) else {
                throw OperationError.blockNotPlaced(id: blockID)
            }
            try ensureUnlocked(try liveContainer(db, placement.containerId))
            if placement.containerId != containerID {
                try ensureUnlocked(try liveContainer(db, containerID))
            }
            placement.containerId = containerID
            placement.position = position
            placement.updatedAt = date.now
            try placement.update(db)
        }
    }

    /// One buffer's do-time pre-image, for `revertStructural`.
    struct TextPreImage: Sendable {
        let variantID: String
        let text: String
    }

    /// Inverse of the block-minting structural ops (extract, divide,
    /// divide-W, merge, poolDragCopy): restore edited buffers to their
    /// pre-image text, tombstone the freshly minted blocks (the trigger
    /// chain cascades to their variants, placements, and edges — fresh rows
    /// by construction, so nothing else carries their stamp), and flip
    /// released placement rows back live, exact position and chosen variant
    /// intact.
    ///
    /// Refusal buckets per the Phase 2 rule: **resolvable refusals throw**
    /// and keep the entry — a sealed container (unlock, retry), a dead,
    /// archived, or locked buffer-restore target (restore/unarchive/unlock,
    /// retry). **Divergence is left alone quietly** — a minted block already
    /// deleted stays deleted; a released block re-homed meanwhile keeps its
    /// new placement (I2) and one whose block or container died stays
    /// released. `lastContainerId` is deliberately not stamped on the minted
    /// blocks: an undone mint vanishes as if never made, and must not haunt
    /// the deleted-blocks tray.
    func revertStructural(
        restoringTexts: [TextPreImage],
        tombstoningBlocks: [String],
        revivingPlacementRows: [String]
    ) throws {
        try database.write { db in
            let now = date.now

            for preImage in restoringTexts {
                var variant = try liveVariant(db, preImage.variantID)
                _ = try liveBlock(db, variant.blockId)
                try ensurePlacementUnlocked(db, blockID: variant.blockId)
                try ensureEditable(variant)
                guard variant.workingText != preImage.text else { continue }
                variant.workingText = preImage.text
                variant.updatedAt = now
                try variant.update(db)
            }

            for blockID in tombstoningBlocks {
                guard var block = try Block.fetchOne(db, key: blockID),
                      block.deletedAt == nil
                else { continue }  // already gone — the world moved past this
                try ensurePlacementUnlocked(db, blockID: blockID)
                block.deletedAt = now
                block.updatedAt = now
                try block.update(db)
            }

            for rowID in revivingPlacementRows {
                guard let row = try ContainerBlock.fetchOne(db, key: rowID),
                      row.deletedAt != nil,
                      let block = try Block.fetchOne(db, key: row.blockId),
                      block.deletedAt == nil,
                      let container = try Container.fetchOne(db, key: row.containerId),
                      container.deletedAt == nil
                else { continue }
                try ensureUnlocked(container)
                guard try livePlacement(db, blockID: row.blockId) == nil else { continue }
                var revived = row
                revived.deletedAt = nil
                revived.updatedAt = now
                try revived.update(db)
            }
        }
    }

    private func restoreDefaultVariant(
        _ db: Database, blockID: String, to variantID: String, now: Date
    ) throws {
        var block = try liveBlock(db, blockID)
        guard block.defaultVariantId != variantID else { return }
        block.defaultVariantId = variantID
        block.updatedAt = now
        try block.update(db)
    }
}
