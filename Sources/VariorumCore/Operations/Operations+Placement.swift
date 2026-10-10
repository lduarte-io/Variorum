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

    /// Where a `restoreBlock` put the block back — so the door that raised it
    /// can say the true thing (13j batch 3, the F2 rider).
    ///
    /// **AND WHAT IT WENT BACK INTO** (13l Act 2, ledger row 26). A block does
    /// not only come out of a NOTE: the scraps area is a `kind='pool'`
    /// container carrying ordinary blocks, and its blocks reach the Trash by
    /// exactly the same road. The landing used to say only *where*, so every
    /// receipt reading it had to guess the *what* — and both shared sentences
    /// guessed "note" (*"Put back at the end of this note."*, *"…its note is
    /// gone…"*), which is a lie for a scrap and the one kind of lie the
    /// recovery story cannot afford (§8d: the story must be intuitive from
    /// every door). The kind is a fact this transaction already holds — it
    /// fetches the container to decide the landing at all — so it is reported
    /// rather than re-derived by a face reading a projection.
    ///
    /// `home` is optional on `.unplaced` alone, and only there because the
    /// case genuinely covers a block that remembers no container at all
    /// (`last_container_id` unset). A container that has since DIED still
    /// answers what kind it was.
    public enum BlockRestoreLanding: Sendable, Equatable {
        /// Its OWN place: the placement row this deletion tombstoned came
        /// back live, fractional position and chosen variant intact.
        case itsOldPlace(home: ContainerKind)
        /// The end of `last_container_id` — the fallback, when no revivable
        /// row exists (a block released to lineage and deleted later has no
        /// placement row carrying its tombstone's stamp).
        case endOfNote(home: ContainerKind)
        /// Live again, but with nowhere to go: `last_container_id` is unset
        /// or its container has since died.
        case unplaced(home: ContainerKind?)

        /// What it went back into — a note (`.post`) or the scraps area
        /// (`.pool`); nil only where the block remembers no home at all.
        public var home: ContainerKind? {
            switch self {
            case .itsOldPlace(let home), .endOfNote(let home): return home
            case .unplaced(let home): return home
            }
        }
    }

    /// Undo a `deleteBlock` from the tray: clear the block's tombstone and
    /// those of children stamped with the block's exact `deleted_at`
    /// (cascade victims) — independently-deleted rows keep their different
    /// stamps and stay dead.
    ///
    /// **THE PLACEMENT (13j batch 3 — the architect's F2 ruling; PROVISIONAL,
    /// her ratify at QUESTIONS #67 F2).** This op used to leave the old
    /// placement row tombstoned and mint a FRESH one at the note's end, which
    /// meant Put back and ⌥⌘Z — the two doors onto one gesture — landed a
    /// block in two different places, and the tray's receipt had to say so.
    /// It now flips the row this deletion took down (stamp-matched, exactly
    /// as `revertDeleteBlock` does), so the old fractional position revives
    /// and the two doors agree. The exact-row shape is the restore family's
    /// rule everywhere else — `restoreContainer`, `restoreReading`,
    /// `restoreSection` and `revertDeleteBlock` all flip exact rows rather
    /// than minting replacements.
    ///
    /// Fresh-at-end SURVIVES as the fallback, because a released-then-deleted
    /// block genuinely has no row to revive: divide-W/merge tombstone the
    /// placement at RELEASE time (its own stamp), and the later `deleteBlock`
    /// finds no live placement to stamp, so nothing carries the block's
    /// tombstone. Same for a container that has since died — the block
    /// returns live but unplaced.
    ///
    /// A sealed container refuses on BOTH roads (`ensureUnlocked`), exactly
    /// as it did when the only road was `insertPlacement`.
    @discardableResult
    public func restoreBlock(_ blockID: String) throws -> BlockRestoreLanding {
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
            // 13j ladder B (B1): a restored row voids any live intent
            // naming it — a leftover intent must never claim it later.
            try voidPurgeIntents(db, table: "block", rowID: blockID)

            // 13l row 26: the remembered home's KIND rides every answer —
            // read once, from the row this transaction already needs. A dead
            // container still says what kind it was; only a block that
            // remembers none at all lands with nil.
            let remembered = try block.lastContainerId
                .flatMap { try Container.fetchOne(db, key: $0) }
            guard let lastContainerID = block.lastContainerId,
                  let container = remembered,
                  container.deletedAt == nil
            else { return .unplaced(home: remembered?.kind) }

            // The row this deletion took down, in the container the block
            // was deleted FROM. Both halves of the key matter: the stamp
            // says "this deletion", the container says "this note" — a
            // block that lived elsewhere earlier carries older tombstoned
            // rows there, and reviving one of those would move it.
            if let revivable = try ContainerBlock.fetchOne(
                db,
                sql: """
                    SELECT * FROM container_block
                    WHERE block_id = ? AND container_id = ? AND deleted_at = ?
                    ORDER BY id LIMIT 1
                    """,
                arguments: [blockID, lastContainerID, stamp]),
               try livePlacement(db, blockID: blockID) == nil {
                try ensureUnlocked(container)
                var revived = revivable
                revived.deletedAt = nil
                revived.updatedAt = now
                try revived.update(db)
                return .itsOldPlace(home: container.kind)
            }
            _ = try insertPlacement(db, blockID: blockID, containerID: lastContainerID, at: .end)
            return .endOfNote(home: container.kind)
        }
    }

    /// Move the block's single live placement to another container (or spot).
    /// Both the source and target posts must be unsealed; ownership stays
    /// single because the one pointer row moves (I2).
    /// `guardedBy` (13n-b U3): the caller's in-transaction precondition
    /// (`WriteGuard`); nil on her doors, never on the redo.
    public func moveBlock(
        _ blockID: String, to containerID: String, at insert: InsertPosition = .end,
        guardedBy guardian: WriteGuard? = nil
    ) throws {
        // Pre-image captured at do-time: the undo inverse restores the exact
        // prior container and position string, never re-derives them. The
        // POST-image rides along for structural REDO (13c 1B — A10): the
        // minted position string is captured too, so redo restores the
        // exact spot the move produced rather than re-deriving a fresh
        // jittered key (which would drift on every ping-pong).
        let images: (
            previous: (container: String, position: String),
            landed: (container: String, position: String)
        ) = try database.write { db in
            try guardian?(db)
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
            return (previous, (placement.containerId, placement.position))
        }
        undoStack?.register(
            label: "Move Block",
            inverse: {
                try $0.restorePlacementLocation(
                    blockID, containerID: images.previous.container,
                    position: images.previous.position)
            },
            redo: {
                try $0.restorePlacementLocation(
                    blockID, containerID: images.landed.container,
                    position: images.landed.position)
            })
    }

    /// Reposition within the current container.
    public func reorder(
        _ blockID: String, to insert: InsertPosition, guardedBy guardian: WriteGuard? = nil
    ) throws {
        let images: (
            previous: (container: String, position: String),
            landed: (container: String, position: String)
        ) = try database.write { db in
            try guardian?(db)
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
            return (previous, (placement.containerId, placement.position))
        }
        undoStack?.register(
            label: "Reorder",
            inverse: {
                try $0.restorePlacementLocation(
                    blockID, containerID: images.previous.container,
                    position: images.previous.position)
            },
            // 13c 1B (A10): the exact landed position string, not a fresh
            // `containerPosition` derivation.
            redo: {
                try $0.restorePlacementLocation(
                    blockID, containerID: images.landed.container,
                    position: images.landed.position)
            })
    }

    // MARK: - Shared internals

    /// Un-tombstones the block-cascade children (variants, edges, block
    /// tags) that carry the block's exact deletion stamp. The placement row
    /// is deliberately the caller's decision: both `restoreBlock` (13j F2)
    /// and undo's `revertDeleteBlock` flip the stamp-matched original row;
    /// `restoreBlock` alone falls back to a fresh end-of-note placement
    /// when no revivable row survives.
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
        // Phase 13 (v1_8): the block's comments revive by the same
        // exact-stamp contract. No extra live-parent guard — the parent IS
        // the block being restored; an independently-deleted comment keeps
        // its different stamp and stays dead (its own resurrection door is
        // `restoreBlockComment`).
        try db.execute(
            sql: """
                UPDATE block_comment SET deleted_at = NULL, updated_at = ?
                WHERE block_id = ? AND deleted_at = ?
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
