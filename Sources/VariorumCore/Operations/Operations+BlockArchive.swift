import Dependencies
import Foundation
import GRDB

// **BLOCK-LEVEL ARCHIVE** (Phase 13j, her round-7 ruling — her own question:
// *"do you think that we should add block level archive? I think that it
// might be worthwhile"*).
//
// ── WHY IT EXISTS NOW ────────────────────────────────────────────────────
// `block.archived_at` has been in the schema since v1 and NO operation ever
// wrote it (batch 2's VERIFY-1 sweep). J1's clock is what made the gap
// matter: once deleting means a 30-day countdown, a block she wants OUT of a
// note but KEPT has no road — delete starts a clock, and moving it to the
// scraps pool cuts the tie to the note it came from. Archive is the third
// verb the tutorial will teach beside them (batch 7): **Archive — kept
// forever, in this note's tray · Delete — 30 days · Move to scraps —
// material for anywhere.** ZERO schema, zero lockstep: the column is there.
//
// ── THE SHAPE SHE RULED ──────────────────────────────────────────────────
// Archiving RELEASES the placement (the row tombstones, stamp-matched to
// `archived_at`) and stamps the block. The note renders on with NO
// view-level filtering — rendering walks live placements, so a released
// block simply is not in the walk; nothing anywhere has to learn a new rule.
// The block appears in the tray's first section, **"Deleted & archived"**,
// wearing no countdown, and Put back is `unarchiveBlock`: clear the stamp,
// revive the exact placement row (the ratified F2 road, fresh-at-end as its
// fallback).
//
// ── WHY THE STAMP-MATCHED RELEASE, precisely ─────────────────────────────
// `restoreBlock` proved the pattern: a block's history can hold SEVERAL
// tombstoned placement rows (older notes, older deletions), and reviving the
// wrong one moves the block somewhere she never put it. Matching the release
// row by `deleted_at == archived_at` names THIS archive's row exactly, the
// same discriminator the whole restore family uses.
extension Operations {
    /// Where `unarchiveBlock` put the block back — the `BlockRestoreLanding`
    /// vocabulary, reused rather than re-invented so the two Put backs in one
    /// tray cannot describe their landings differently.
    public typealias BlockUnarchiveLanding = BlockRestoreLanding

    /// Set a block aside, kept: release its placement and stamp
    /// `archived_at`. Refuses a dead block (`blockNotFound`), one already
    /// archived (`blockAlreadyArchived`), and one under a sealed note
    /// (`lockedPost` — a placement release is a pointer change, and the seal
    /// freezes pointer order; AppSpec §9's letter).
    ///
    /// Structural undo AND redo (the `archiveVariant` class): both halves are
    /// exact-row work over the same block id.
    public func archiveBlock(_ id: String) throws {
        _ = try performArchiveBlock(id, quietWhenGone: false)
        undoStack?.register(
            label: "Archive Block",
            inverse: { try $0.revertArchiveBlock(id) },
            redo: { try $0.performArchiveBlock(id, quietWhenGone: true) })
    }

    /// The row work behind `archiveBlock`, shared with structural REDO
    /// (`performArchiveVariant`'s shape; `quietWhenGone` is the divergence
    /// bucket — a block that has since died or been archived another way
    /// means the world moved past that entry, so redo pops quietly instead of
    /// wedging the stack).
    /// Returns whether it archived the block (`false` only on the quiet road).
    @discardableResult
    func performArchiveBlock(_ id: String, quietWhenGone: Bool) throws -> Bool {
        try database.write { db in
            let existing = try Block.fetchOne(db, key: id)
            guard let existing, existing.deletedAt == nil else {
                if quietWhenGone { return false }
                throw OperationError.blockNotFound(id: id)
            }
            var block = existing
            guard block.archivedAt == nil else {
                if quietWhenGone { return false }
                throw OperationError.blockAlreadyArchived(id: id)
            }
            try ensurePlacementUnlocked(db, blockID: id)
            let now = date.now
            if var placement = try livePlacement(db, blockID: id) {
                block.lastContainerId = placement.containerId
                placement.deletedAt = now
                placement.updatedAt = now
                try placement.update(db)
            }
            block.archivedAt = now
            block.updatedAt = now
            try block.update(db)
            return true
        }
    }

    /// Put an archived block back: clear the stamp and revive the placement
    /// row this archive released (exact-row, stamp-matched), falling back to
    /// a fresh placement at the note's end when no revivable row survives —
    /// `restoreBlock`'s own two roads, for its own reason.
    ///
    /// Refuses a dead block, one that is not archived (`blockNotArchived` —
    /// the `variantNotDeleted` class: a recovery door that silently succeeded
    /// would teach that Put back did something), and a sealed note.
    @discardableResult
    public func unarchiveBlock(_ id: String) throws -> BlockUnarchiveLanding {
        // Never nil here: the loud road throws where the quiet one is nil.
        let landing = try performUnarchiveBlock(id, quietWhenGone: false) ?? .unplaced(home: nil)
        undoStack?.register(
            label: "Unarchive Block",
            inverse: { try $0.performArchiveBlock(id, quietWhenGone: true) },
            redo: { try $0.performUnarchiveBlock(id, quietWhenGone: true) != nil })
        return landing
    }

    /// nil on the quiet road (VX-246 U2: the block already gone or already
    /// unarchived — nothing written).
    @discardableResult
    func performUnarchiveBlock(
        _ id: String, quietWhenGone: Bool
    ) throws -> BlockUnarchiveLanding? {
        try database.write { db in
            let existing = try Block.fetchOne(db, key: id)
            guard let existing, existing.deletedAt == nil else {
                if quietWhenGone { return nil }
                throw OperationError.blockNotFound(id: id)
            }
            var block = existing
            guard let archivedAt = block.archivedAt else {
                if quietWhenGone { return nil }
                throw OperationError.blockNotArchived(id: id)
            }
            let stamp = DateFormatter.variorumISO8601.string(from: archivedAt)
            let now = date.now

            block.archivedAt = nil
            block.updatedAt = now
            try block.update(db)

            // 13l row 26: the home's KIND rides the answer here too — a scrap
            // can be archived exactly as a note's block can, and the tray's
            // receipt reads this landing.
            let remembered = try block.lastContainerId
                .flatMap { try Container.fetchOne(db, key: $0) }
            guard let lastContainerID = block.lastContainerId,
                  let container = remembered,
                  container.deletedAt == nil
            else { return .unplaced(home: remembered?.kind) }

            if let revivable = try ContainerBlock.fetchOne(
                db,
                sql: """
                    SELECT * FROM container_block
                    WHERE block_id = ? AND container_id = ? AND deleted_at = ?
                    ORDER BY id LIMIT 1
                    """,
                arguments: [id, lastContainerID, stamp]),
               try livePlacement(db, blockID: id) == nil {
                try ensureUnlocked(container)
                var revived = revivable
                revived.deletedAt = nil
                revived.updatedAt = now
                try revived.update(db)
                return .itsOldPlace(home: container.kind)
            }
            guard try livePlacement(db, blockID: id) == nil else {
                return .itsOldPlace(home: container.kind)
            }
            try ensureUnlocked(container)
            _ = try insertPlacementForUnarchive(db, blockID: id, containerID: lastContainerID)
            return .endOfNote(home: container.kind)
        }
    }

    /// The inverse structural undo emits for `archiveBlock` — the same body
    /// as the public door minus its own registration (the `revert…` family's
    /// rule: an inverse never registers, so undo never clears the redo stack
    /// from under itself).
    @discardableResult
    func revertArchiveBlock(_ id: String) throws -> Bool {
        try performUnarchiveBlock(id, quietWhenGone: true) != nil
    }

    private func insertPlacementForUnarchive(
        _ db: Database, blockID: String, containerID: String
    ) throws -> ContainerBlock {
        let now = date.now
        let placement = ContainerBlock(
            id: newID(), containerId: containerID, blockId: blockID,
            position: try containerPosition(db, containerID: containerID, at: .end),
            chosenVariantId: nil, createdAt: now, updatedAt: now)
        try placement.insert(db)
        return placement
    }
}
