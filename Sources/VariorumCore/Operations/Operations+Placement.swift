import Dependencies
import Foundation
import GRDB

// Placement: where a block's single live pointer lives (I2) and which variant
// it shows (I3). `placeBlock` is the W-reversibility primitive — the op that
// makes "re-point at A" a real operation instead of a promise.
extension Operations {
    /// Point the block's live slot at a different variant (I3: the choice
    /// lives on the pointer, never the block).
    public func chooseVariant(_ blockID: String, variantID: String) throws {
        try database.write { db in
            _ = try liveBlock(db, blockID)
            guard var placement = try livePlacement(db, blockID: blockID) else {
                throw OperationError.blockNotPlaced(id: blockID)
            }
            try ensureUnlocked(try liveContainer(db, placement.containerId))
            let variant = try liveVariant(db, variantID)
            guard variant.blockId == blockID else {
                throw OperationError.variantNotFound(id: variantID)
            }
            guard variant.status == .active else {
                throw OperationError.archivedVariant(id: variantID)
            }
            placement.chosenVariantId = variantID
            placement.updatedAt = date.now
            try placement.update(db)
        }
    }

    /// Insert a placement for a live block with NO live placement — a
    /// released-to-lineage block after divide-W/merge, or a tray restoree.
    /// Structural undo emits this. The chosen variant starts NULL: the slot
    /// renders the block's default until a choice is made.
    @discardableResult
    public func placeBlock(
        _ blockID: String, in containerID: String, at insert: InsertPosition = .end
    ) throws -> ContainerBlock {
        try database.write { db in
            try insertPlacement(db, blockID: blockID, containerID: containerID, at: insert)
        }
    }

    /// Undo a `deleteBlock` from the tray: clear the block's tombstone and
    /// those of children stamped with the block's exact `deleted_at`
    /// (cascade victims) — independently-deleted rows keep their different
    /// stamps and stay dead. The old placement row stays tombstoned; a fresh
    /// placement lands at the end of `last_container_id`, when that container
    /// still lives (otherwise the block returns live but unplaced).
    public func restoreBlock(_ blockID: String) throws {
        try database.write { db in
            guard var block = try Block.fetchOne(db, key: blockID) else {
                throw OperationError.blockNotFound(id: blockID)
            }
            guard let deletedAt = block.deletedAt else {
                throw OperationError.blockNotDeleted(id: blockID)
            }
            let stamp = DateFormatter.variorumISO8601.string(from: deletedAt)
            let now = date.now

            block.deletedAt = nil
            block.updatedAt = now
            try block.update(db)
            try flipBlockCascadeTombstones(db, blockID: blockID, stamp: stamp, now: now)

            if let lastContainerID = block.lastContainerId,
               let container = try Container.fetchOne(db, key: lastContainerID),
               container.deletedAt == nil {
                _ = try insertPlacement(db, blockID: blockID, containerID: lastContainerID, at: .end)
            }
        }
    }

    /// Move the block's single live placement to another container (or spot).
    /// Both the source and target posts must be unsealed; ownership stays
    /// single because the one pointer row moves (I2).
    public func moveBlock(
        _ blockID: String, to containerID: String, at insert: InsertPosition = .end
    ) throws {
        // Pre-image captured at do-time: the undo inverse restores the exact
        // prior container and position string, never re-derives them.
        let previous: (container: String, position: String) = try database.write { db in
            _ = try liveBlock(db, blockID)
            guard var placement = try livePlacement(db, blockID: blockID) else {
                throw OperationError.blockNotPlaced(id: blockID)
            }
            try ensureUnlocked(try liveContainer(db, placement.containerId))
            let target = try liveContainer(db, containerID)
            try ensureUnlocked(target)
            let previous = (placement.containerId, placement.position)
            placement.containerId = containerID
            placement.position = try containerPosition(db, containerID: containerID, at: insert)
            placement.updatedAt = date.now
            try placement.update(db)
            return previous
        }
        undoStack?.register(label: "Move Block") {
            try $0.restorePlacementLocation(
                blockID, containerID: previous.container, position: previous.position)
        }
    }

    /// Reposition within the current container.
    public func reorder(_ blockID: String, to insert: InsertPosition) throws {
        let previous: (container: String, position: String) = try database.write { db in
            _ = try liveBlock(db, blockID)
            guard var placement = try livePlacement(db, blockID: blockID) else {
                throw OperationError.blockNotPlaced(id: blockID)
            }
            try ensureUnlocked(try liveContainer(db, placement.containerId))
            let previous = (placement.containerId, placement.position)
            placement.position = try containerPosition(
                db, containerID: placement.containerId, at: insert)
            placement.updatedAt = date.now
            try placement.update(db)
            return previous
        }
        undoStack?.register(label: "Reorder") {
            try $0.restorePlacementLocation(
                blockID, containerID: previous.container, position: previous.position)
        }
    }

    // MARK: - Shared internals

    /// Un-tombstones the block-cascade children (variants, edges, block
    /// tags) that carry the block's exact deletion stamp. The placement row
    /// is deliberately the caller's decision: `restoreBlock` re-places
    /// fresh; undo's `revertDeleteBlock` flips the original row.
    func flipBlockCascadeTombstones(
        _ db: Database, blockID: String, stamp: String, now: Date
    ) throws {
        let nowStamp = DateFormatter.variorumISO8601.string(from: now)
        try db.execute(
            sql: """
                UPDATE variant SET deleted_at = NULL, updated_at = ?
                WHERE block_id = ? AND deleted_at = ?
                """,
            arguments: [nowStamp, blockID, stamp])
        try db.execute(
            sql: """
                UPDATE edge SET deleted_at = NULL
                WHERE (source_block_id = ? OR target_block_id = ?) AND deleted_at = ?
                """,
            arguments: [blockID, blockID, stamp])
        // A tag application only revives if its tag is still live — a tag
        // deleted AFTER the block left this row carrying the block's stamp,
        // and resurrecting it would put a live application under a dead tag.
        try db.execute(
            sql: """
                UPDATE block_tag SET deleted_at = NULL
                WHERE block_id = ? AND deleted_at = ?
                  AND tag_id IN (SELECT id FROM tag WHERE deleted_at IS NULL)
                """,
            arguments: [blockID, stamp])
        // Phase 11 (review round 1, MAJOR): the v1_5/v1_7 cascade children
        // revive by the same exact-stamp contract (AppSpec §9's letter —
        // the SYNC side kept this discipline from day one, per
        // Repairs.swift's own comment; the local doors were never
        // extended). Same live-parent guards as the tag flip: a canvas row
        // under a dead container, or a pick under a dead lens, stays dead.
        try db.execute(
            sql: """
                UPDATE canvas_layout SET deleted_at = NULL, updated_at = ?
                WHERE block_id = ? AND deleted_at = ?
                  AND container_id IN (SELECT id FROM container WHERE deleted_at IS NULL)
                """,
            arguments: [nowStamp, blockID, stamp])
        try db.execute(
            sql: """
                UPDATE lens_choice SET deleted_at = NULL, updated_at = ?
                WHERE block_id = ? AND deleted_at = ?
                  AND lens_id IN (SELECT id FROM lens WHERE deleted_at IS NULL)
                """,
            arguments: [nowStamp, blockID, stamp])
    }

    @discardableResult
    private func insertPlacement(
        _ db: Database, blockID: String, containerID: String, at insert: InsertPosition
    ) throws -> ContainerBlock {
        _ = try liveBlock(db, blockID)
        let container = try liveContainer(db, containerID)
        try ensureUnlocked(container)
        guard try livePlacement(db, blockID: blockID) == nil else {
            throw OperationError.blockAlreadyPlaced(id: blockID)
        }
        let now = date.now
        let placement = ContainerBlock(
            id: newID(), containerId: containerID, blockId: blockID,
            position: try containerPosition(db, containerID: containerID, at: insert),
            chosenVariantId: nil, createdAt: now, updatedAt: now)
        try placement.insert(db)
        return placement
    }
}
