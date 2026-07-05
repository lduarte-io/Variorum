import Dependencies
import Foundation
import GRDB

// Variant and block removal. The I10 and chosen-variant guards here are the
// ONLY live enforcement — under soft delete, tombstones are UPDATEs, so the
// schema's FK RESTRICT never fires (it guards the future physical-purge/GC
// path). The tests target this layer accordingly.
extension Operations {
    /// Out of the fan, kept in the block's history. A chosen variant may be
    /// archived — the read-time rule renders the block default in its place
    /// (AppSpec §7); deletion, by contrast, demands re-pointing first.
    public func archiveVariant(_ id: String) throws {
        try database.write { db in
            var variant = try liveVariant(db, id)
            guard variant.status != .archived else { return }
            try ensurePlacementUnlocked(db, blockID: variant.blockId)
            try ensureNotLastActive(db, variant)
            let now = date.now
            variant.status = .archived
            variant.updatedAt = now
            try variant.update(db)
            try reassignDefaultIfNeeded(db, blockID: variant.blockId, removing: id, now: now)
        }
    }

    /// Back into the fan.
    public func unarchiveVariant(_ id: String) throws {
        try database.write { db in
            var variant = try liveVariant(db, id)
            guard variant.status == .archived else { return }
            try ensurePlacementUnlocked(db, blockID: variant.blockId)
            variant.status = .active
            variant.updatedAt = date.now
            try variant.update(db)
        }
    }

    /// Tombstone. Refuses while any live slot shows this variant (re-point
    /// first), while it is its block's last live active variant (I10 — that
    /// is `deleteBlock`), and while locked (the guard means something).
    public func deleteVariant(_ id: String) throws {
        try database.write { db in
            var variant = try liveVariant(db, id)
            guard !variant.locked else {
                throw OperationError.lockedVariant(id: id)
            }
            try ensurePlacementUnlocked(db, blockID: variant.blockId)
            let chosenBy = try Int.fetchOne(
                db,
                sql: "SELECT COUNT(*) FROM container_block WHERE chosen_variant_id = ? AND deleted_at IS NULL",
                arguments: [id]) ?? 0
            guard chosenBy == 0 else {
                throw OperationError.variantIsChosen(id: id)
            }
            try ensureNotLastActive(db, variant)
            let now = date.now
            variant.deletedAt = now
            variant.updatedAt = now
            try variant.update(db)
            try reassignDefaultIfNeeded(db, blockID: variant.blockId, removing: id, now: now)
        }
    }

    /// Tombstones the block; the trigger chain cascades to its variants,
    /// placement, edges, and block tags, all stamped with the block's exact
    /// `deleted_at` so `restoreBlock` can identify its cascade victims.
    /// `last_container_id` is recorded first — it feeds the per-post
    /// "deleted blocks" tray.
    public func deleteBlock(_ id: String) throws {
        try database.write { db in
            var block = try liveBlock(db, id)
            try ensurePlacementUnlocked(db, blockID: id)
            let now = date.now
            if let placement = try livePlacement(db, blockID: id) {
                block.lastContainerId = placement.containerId
            }
            block.deletedAt = now
            block.updatedAt = now
            try block.update(db)
        }
    }

    // MARK: - Shared guards

    /// I10: a live block keeps at least one live active variant. Removing
    /// the last one is not a variant operation — it is deleting the block.
    private func ensureNotLastActive(_ db: Database, _ variant: Variant) throws {
        guard variant.status == .active else { return }
        let otherActive = try Int.fetchOne(
            db,
            sql: """
                SELECT COUNT(*) FROM variant
                WHERE block_id = ? AND id <> ? AND deleted_at IS NULL AND status = 'active'
                """,
            arguments: [variant.blockId, variant.id]) ?? 0
        guard otherActive > 0 else {
            throw OperationError.lastActiveVariant(id: variant.id)
        }
    }

    /// `default_variant_id` lifecycle (AppSpec §9): when the variant it names
    /// is removed from the active fan, reassign to the most recently updated
    /// live active variant. Never NULL while the block is live — guaranteed
    /// jointly by the I10 guard above and this reassignment.
    private func reassignDefaultIfNeeded(
        _ db: Database, blockID: String, removing variantID: String, now: Date
    ) throws {
        var block = try liveBlock(db, blockID)
        guard block.defaultVariantId == variantID else { return }
        let replacement = try String.fetchOne(
            db,
            sql: """
                SELECT id FROM variant
                WHERE block_id = ? AND id <> ? AND deleted_at IS NULL AND status = 'active'
                ORDER BY updated_at DESC, id DESC LIMIT 1
                """,
            arguments: [blockID, variantID])
        block.defaultVariantId = replacement
        block.updatedAt = now
        try block.update(db)
    }
}
