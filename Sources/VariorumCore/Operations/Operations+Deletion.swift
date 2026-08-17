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

    /// An authorization `deleteBlock` re-checks **inside the tombstone's own
    /// transaction** (13c Stage 1 ladder, R3-1/R3-3).
    ///
    /// **Why this exists at all, because the history is the argument.** The
    /// A7 seam-backspace carve is a deliberate, narrow exception to the
    /// ratified cross-block destructive-edit refusal, and its ONLY
    /// authorization is *"there is no text to lose"*. Three review rounds
    /// found three ways that authorization could fail while the gesture
    /// still fired — an archived take (R1-1), a block comment (R2-1), and
    /// finally the one that ended the pattern: the guards were reading the
    /// editor's PROJECTION, which is deliberately held stale while the
    /// buffer is dirty or a flight is up (R3-1). A guard list cannot fix
    /// that; a guard list read from a frozen array is exactly as stale as
    /// the array. **A precondition evaluated in the same transaction as the
    /// tombstone cannot be read stale**, which is why the authorization
    /// moved here rather than growing a sixth entry.
    ///
    /// It also makes the carve's long-documented compare-and-set claim TRUE
    /// (R3-3): the check and the act are now ONE transaction, where before
    /// they were two (`editTakesAtomically`'s write, then `deleteBlock`'s).
    public enum BlockDeletionPrecondition: Sendable, Equatable {
        /// The ordinary delete door: the block goes, whatever it holds. The
        /// author asked for an unrestricted delete (QUESTIONS #33(a)), and
        /// the block is undoable, redoable and tray-recoverable.
        case none
        /// **The A7 carve's authorization.** The block must still hold
        /// nothing but one empty take: `variantID` is its ONE live variant
        /// (so no fan and no archived take), it is active, unlocked, under
        /// an unsealed post, its buffer is empty, and the block carries no
        /// live comment. Anything else refuses the whole gesture — the
        /// keystroke deletes nothing rather than deleting text nobody saw.
        case emptyWithNothingUnshown(variantID: String)
    }

    /// Tombstones the block; the trigger chain cascades to its variants,
    /// placement, edges, and block tags, all stamped with the block's exact
    /// `deleted_at` so `restoreBlock` can identify its cascade victims.
    /// `last_container_id` is recorded first — it feeds the per-post
    /// "deleted blocks" tray.
    ///
    /// `precondition` defaults to `.none` (the ordinary door). A caller
    /// whose authorization to delete depends on what the block currently
    /// HOLDS must pass one instead of checking beforehand: a check made
    /// outside this transaction is a check made against a snapshot, and
    /// `BlockDeletionPrecondition`'s doc comment records what that cost.
    public func deleteBlock(
        _ id: String, requiring precondition: BlockDeletionPrecondition = .none
    ) throws {
        try performDeleteBlock(id, quietWhenGone: false, requiring: precondition)
        undoStack?.register(
            label: "Delete Block",
            inverse: { try $0.revertDeleteBlock(id) },
            // 13c 1B (A10): re-tombstone the same block row — the cascade
            // triggers re-stamp its children exactly as the first delete
            // did, so `revertDeleteBlock` still finds them next undo.
            //
            // 13c R3-1: the redo carries the SAME precondition. A redo
            // lands a tombstone, so it needs the same authorization the
            // first delete needed — and the window is real, because a
            // comment written between the undo and the redo is not a
            // structural act and therefore never cleared the redo future.
            // A refused redo keeps its entry for retry (the resolvable
            // bucket), which is the existing, pinned posture.
            redo: {
                try $0.performDeleteBlock(
                    id, quietWhenGone: true, requiring: precondition)
            })
    }

    /// The row work behind `deleteBlock`, shared with structural REDO
    /// (13c 1B — A10; `quietWhenGone` per `performArchiveVariant`).
    private func performDeleteBlock(
        _ id: String, quietWhenGone: Bool, requiring precondition: BlockDeletionPrecondition
    ) throws {
        try database.write { db in
            let existing = try Block.fetchOne(db, key: id)
            guard let existing, existing.deletedAt == nil else {
                if quietWhenGone { return }
                throw OperationError.blockNotFound(id: id)
            }
            var block = existing
            try ensurePlacementUnlocked(db, blockID: id)
            // The authorization, re-read from the rows this transaction is
            // about to tombstone — never from a caller's snapshot.
            try enforce(precondition, db, blockID: id)
            let now = date.now
            if let placement = try livePlacement(db, blockID: id) {
                block.lastContainerId = placement.containerId
            }
            block.deletedAt = now
            block.updatedAt = now
            try block.update(db)
        }
    }

    /// `BlockDeletionPrecondition`, enforced. The counted reads mirror
    /// `Queries.RenderedBlock.liveVariantCount` and `.commentCount` exactly
    /// — the same two facts the projection reports, read fresh here so the
    /// answer cannot be a snapshot's.
    private func enforce(
        _ precondition: BlockDeletionPrecondition, _ db: Database, blockID: String
    ) throws {
        guard case .emptyWithNothingUnshown(let variantID) = precondition else { return }
        // Live, active, unlocked, unsealed — exactly `editTakesAtomically`'s
        // guard set, which is what the carve used to borrow by writing an
        // unchanged text through it.
        let variant = try editableVariant(db, variantID)
        guard variant.blockId == blockID else {
            throw OperationError.variantNotFound(id: variantID)
        }
        guard variant.workingText.isEmpty else {
            // The carve's compare-and-set, now genuinely inside the
            // tombstone's transaction (R3-3).
            throw OperationError.bufferChangedSinceGesture(variantID: variantID)
        }
        let liveVariants = try Int.fetchOne(
            db,
            sql: "SELECT COUNT(*) FROM variant WHERE block_id = ? AND deleted_at IS NULL",
            arguments: [blockID]) ?? 0
        let liveComments = try Int.fetchOne(
            db,
            sql: "SELECT COUNT(*) FROM block_comment WHERE block_id = ? AND deleted_at IS NULL",
            arguments: [blockID]) ?? 0
        guard liveVariants == 1, liveComments == 0 else {
            throw OperationError.blockCarriesUnshownText(id: blockID)
        }
    }

    // MARK: - Shared guards

    /// I10: a live block keeps at least one live active variant. Removing
    /// the last one is not a variant operation — it is deleting the block.
    /// Internal (was private) since 13e batch 3: the take↔block doors archive
    /// a take inside their OWN transaction, and they owe I10 the same guard
    /// this file's doors owe it — one rule, not a second copy of it.
    func ensureNotLastActive(_ db: Database, _ variant: Variant) throws {
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
    /// jointly by the I10 guard above and this reassignment. Internal since
    /// 13e batch 3 for the take↔block doors' inline archive (same reason as
    /// the guard above — one rule, not a second copy).
    func reassignDefaultIfNeeded(
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
