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
        // nil = no-op (already archived); nothing to undo then.
        let wasDefault = try performArchiveVariant(id, quietWhenGone: false)
        if let wasDefault {
            undoStack?.register(
                label: "Archive Variant",
                inverse: { try $0.revertArchiveVariant(id, wasDefault: wasDefault) },
                // 13c 1B (A10): re-archive — the same row transition, run
                // again from the same captured id.
                redo: { _ = try $0.performArchiveVariant(id, quietWhenGone: true) })
        }
    }

    /// The row work behind `archiveVariant`, shared with structural REDO
    /// (13c 1B — A10). `quietWhenGone` is the redo path's divergence
    /// bucket, mirroring the inverses' rule: a variant that died or
    /// archived another way means the world moved past that entry, so redo
    /// pops quietly instead of wedging the stack. Returns nil when nothing
    /// changed.
    @discardableResult
    private func performArchiveVariant(_ id: String, quietWhenGone: Bool) throws -> Bool? {
        try database.write { db in
            let existing = try Variant.fetchOne(db, key: id)
            guard let existing, existing.deletedAt == nil else {
                if quietWhenGone { return nil }
                throw OperationError.variantNotFound(id: id)
            }
            var variant = existing
            guard variant.status != .archived else { return nil }
            try ensurePlacementUnlocked(db, blockID: variant.blockId)
            try ensureNotLastActive(db, variant)
            let now = date.now
            let wasDefault = try liveBlock(db, variant.blockId).defaultVariantId == id
            variant.status = .archived
            variant.updatedAt = now
            try variant.update(db)
            try reassignDefaultIfNeeded(db, blockID: variant.blockId, removing: id, now: now)
            return wasDefault
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
        let wasDefault = try performDeleteVariant(id, quietWhenGone: false) ?? false
        undoStack?.register(
            label: "Delete Variant",
            inverse: { try $0.revertDeleteVariant(id, wasDefault: wasDefault) },
            // 13c 1B (A10): re-tombstone the same variant row.
            redo: { _ = try $0.performDeleteVariant(id, quietWhenGone: true) })
    }

    /// The row work behind `deleteVariant`, shared with structural REDO
    /// (13c 1B — A10; `quietWhenGone` per `performArchiveVariant`).
    @discardableResult
    private func performDeleteVariant(_ id: String, quietWhenGone: Bool) throws -> Bool? {
        try database.write { db in
            let existing = try Variant.fetchOne(db, key: id)
            guard let existing, existing.deletedAt == nil else {
                if quietWhenGone { return nil }
                throw OperationError.variantNotFound(id: id)
            }
            var variant = existing
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
            let wasDefault = try liveBlock(db, variant.blockId).defaultVariantId == id
            variant.deletedAt = now
            variant.updatedAt = now
            try variant.update(db)
            try reassignDefaultIfNeeded(db, blockID: variant.blockId, removing: id, now: now)
            return wasDefault
        }
    }

    /// Tombstones the block; the trigger chain cascades to its variants,
    /// placement, edges, and block tags, all stamped with the block's exact
    /// `deleted_at` so `restoreBlock` can identify its cascade victims.
    /// `last_container_id` is recorded first — it feeds the per-post
    /// "deleted blocks" tray.
    public func deleteBlock(_ id: String) throws {
        try performDeleteBlock(id, quietWhenGone: false)
        undoStack?.register(
            label: "Delete Block",
            inverse: { try $0.revertDeleteBlock(id) },
            // 13c 1B (A10): re-tombstone the same block row — the cascade
            // triggers re-stamp its children exactly as the first delete
            // did, so `revertDeleteBlock` still finds them next undo.
            redo: { try $0.performDeleteBlock(id, quietWhenGone: true) })
    }

    /// The row work behind `deleteBlock`, shared with structural REDO
    /// (13c 1B — A10; `quietWhenGone` per `performArchiveVariant`).
    private func performDeleteBlock(_ id: String, quietWhenGone: Bool) throws {
        try database.write { db in
            let existing = try Block.fetchOne(db, key: id)
            guard let existing, existing.deletedAt == nil else {
                if quietWhenGone { return }
                throw OperationError.blockNotFound(id: id)
            }
            var block = existing
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
