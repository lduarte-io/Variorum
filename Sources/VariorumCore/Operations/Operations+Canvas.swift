import Dependencies
import Foundation
import GRDB

// Canvas layout (Phase 11, Step A1 — AppSpec §12's canvas view; the table
// is migration v1_5). Positions are plain metadata under sync: a two-device
// drag race converges by CAS to either position, never corruption
// (SyncSpec §6), which is why these ops are bare row upserts/tombstones.
//
// SEAL POSTURE (PROVISIONAL, Phase 11 — logged in notes/QUESTIONS.md with
// the block-name and lens postures): canvas arrangement is a way of VIEWING
// a container's blocks, not authoring (the 9d "viewing isn't authoring"
// doctrine — the seal freezes edits, commits, pointer order, and chosen
// variants; a card's x/y is none of those), so a locked container's canvas
// still rearranges. The conservative alternative (refuse under the
// everything-under-the-post letter) is recorded for the author.
extension Operations {
    /// Upserts the (container, block) card position. The block must be
    /// LIVE-PLACED in that container — the canvas shows exactly the
    /// container's own blocks. Re-positioning updates the existing live row
    /// in place (metadata CAS); a tombstoned pair re-creates freshly (the
    /// §6 live-row-index class).
    @discardableResult
    public func setCanvasPosition(
        container containerID: String, block blockID: String, x: Double, y: Double
    ) throws -> CanvasLayout {
        try database.write { db in
            _ = try liveContainer(db, containerID)
            _ = try liveBlock(db, blockID)
            guard let placement = try livePlacement(db, blockID: blockID),
                  placement.containerId == containerID
            else {
                throw OperationError.blockNotInContainer(
                    blockID: blockID, containerID: containerID)
            }
            let now = date.now
            if var existing = try liveLayout(db, containerID: containerID, blockID: blockID) {
                existing.x = x
                existing.y = y
                existing.updatedAt = now
                try existing.update(db)
                return existing
            }
            let layout = CanvasLayout(
                id: newID(), ownerId: currentOwnerID(),
                containerId: containerID, blockId: blockID,
                x: x, y: y, createdAt: now, updatedAt: now)
            try layout.insert(db)
            return layout
        }
    }

    /// Tombstones the live layout row for the pair (the card falls back to
    /// whatever un-positioned default the canvas view renders).
    public func removeCanvasPosition(
        container containerID: String, block blockID: String
    ) throws {
        try database.write { db in
            guard var layout = try liveLayout(db, containerID: containerID, blockID: blockID)
            else {
                throw OperationError.canvasPositionNotFound(
                    blockID: blockID, containerID: containerID)
            }
            let now = date.now
            layout.deletedAt = now
            layout.updatedAt = now
            try layout.update(db)
        }
    }

    private func liveLayout(
        _ db: Database, containerID: String, blockID: String
    ) throws -> CanvasLayout? {
        try CanvasLayout
            .filter(Column("container_id") == containerID
                    && Column("block_id") == blockID
                    && Column("deleted_at") == nil)
            .fetchOne(db)
    }
}
