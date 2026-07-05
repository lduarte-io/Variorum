import Dependencies
import Foundation
import GRDB

// Container CRUD: posts and pools. Deleting a container tombstones one row
// here — the trigger chain owns the cascade (placements → blocks → variants,
// edges, tags, references, memberships).
extension Operations {
    @discardableResult
    public func createPost(
        title: String? = nil,
        profile: Profile? = nil,
        entryDate: String? = nil
    ) throws -> Container {
        let now = date.now
        var post = Container(
            id: newID(), kind: .post, title: title, profile: profile,
            entryDate: entryDate, createdAt: now, updatedAt: now)
        // A journal post defaults to one-block-per-entry (AppSpec §7): the
        // journal restriction is a profile seed, never a data-model split.
        if profile == .journal {
            post.segmentationDefault = .oneBlock
        }
        try database.write { db in try post.insert(db) }
        return post
    }

    @discardableResult
    public func createPool(title: String? = nil) throws -> Container {
        let now = date.now
        let pool = Container(
            id: newID(), kind: .pool, title: title, profile: .pool,
            createdAt: now, updatedAt: now)
        try database.write { db in try pool.insert(db) }
        return pool
    }

    public func renameContainer(_ id: String, title: String?) throws {
        try updateLiveContainer(id) { $0.title = title }
    }

    public func setEntryDate(_ id: String, entryDate: String?) throws {
        try updateLiveContainer(id) { $0.entryDate = entryDate }
    }

    public func setProfile(_ id: String, profile: Profile?) throws {
        try updateLiveContainer(id) { $0.profile = profile }
    }

    public func setSegmentationDefault(_ id: String, segmentation: Segmentation?) throws {
        try updateLiveContainer(id) { $0.segmentationDefault = segmentation }
    }

    /// Floating notes are post *content*, so a locked post refuses the edit
    /// (title/date/profile above are library metadata and stay editable —
    /// the lock freezes edits, commits, order, and chosen variants).
    public func updateFloatingNotes(_ id: String, notes: String?) throws {
        try database.write { db in
            var container = try liveContainer(db, id)
            try ensureUnlocked(container)
            container.floatingNotes = notes
            container.updatedAt = date.now
            try container.update(db)
        }
    }

    /// Domain archive (kept, out of view) — NOT a sync tombstone.
    public func archiveContainer(_ id: String) throws {
        let now = date.now
        try updateLiveContainer(id, now: now) { $0.archivedAt = now }
    }

    public func unarchiveContainer(_ id: String) throws {
        try updateLiveContainer(id) { $0.archivedAt = nil }
    }

    /// Tombstone (S2). The trigger chain cascades: placements and their
    /// singly-owned blocks, those blocks' variants/edges/block_tags, plus the
    /// container's reading memberships, post tags, and references.
    public func deleteContainer(_ id: String) throws {
        let now = date.now
        try updateLiveContainer(id, now: now) { $0.deletedAt = now }
    }

    /// Undo a `deleteContainer` (author decision 2026-07-05: deleted posts
    /// must be recoverable): clear the container's tombstone and every
    /// cascade victim stamped with its exact `deleted_at` — placements,
    /// their singly-owned blocks (and those blocks' variants/edges/tags via
    /// the shared flip helper), reading memberships, post tags, references.
    /// Independently-deleted rows carry different stamps and stay dead, as
    /// do memberships/applications whose reading or tag died in the
    /// meantime (a live pointer under a dead parent helps nobody).
    public func restoreContainer(_ id: String) throws {
        try database.write { db in
            guard var container = try Container.fetchOne(db, key: id) else {
                throw OperationError.containerNotFound(id: id)
            }
            guard let deletedAt = container.deletedAt else {
                throw OperationError.containerNotDeleted(id: id)
            }
            let stamp = DateFormatter.variorumISO8601.string(from: deletedAt)
            let now = date.now
            let nowStamp = DateFormatter.variorumISO8601.string(from: now)

            // The blocks this cascade took down: reachable through this
            // container's same-stamp placements AND themselves same-stamped.
            let blockIDs = try String.fetchAll(
                db,
                sql: """
                    SELECT b.id FROM block b
                    JOIN container_block cb ON cb.block_id = b.id
                    WHERE cb.container_id = ? AND cb.deleted_at = ? AND b.deleted_at = ?
                    """,
                arguments: [id, stamp, stamp])

            container.deletedAt = nil
            container.updatedAt = now
            try container.update(db)

            // A placement revives only when its block will be live after
            // this restore (dying with us, or independently restored) AND
            // has no live placement meanwhile — a block that was restored
            // and re-placed elsewhere keeps its new home (I2), and one that
            // was restored then re-deleted (different stamp) stays dead.
            // Must run before the block flips below, while `deleted_at =
            // stamp` still identifies "dying with us".
            try db.execute(
                sql: """
                    UPDATE container_block SET deleted_at = NULL, updated_at = ?
                    WHERE container_id = ? AND deleted_at = ?
                      AND block_id IN
                          (SELECT id FROM block WHERE deleted_at IS NULL OR deleted_at = ?)
                      AND block_id NOT IN
                          (SELECT block_id FROM container_block WHERE deleted_at IS NULL)
                    """,
                arguments: [nowStamp, id, stamp, stamp])
            for blockID in blockIDs {
                try db.execute(
                    sql: "UPDATE block SET deleted_at = NULL, updated_at = ? WHERE id = ?",
                    arguments: [nowStamp, blockID])
                try flipBlockCascadeTombstones(db, blockID: blockID, stamp: stamp, now: now)
            }
            try db.execute(
                sql: """
                    UPDATE reading_post SET deleted_at = NULL
                    WHERE post_id = ? AND deleted_at = ?
                      AND reading_id IN (SELECT id FROM reading WHERE deleted_at IS NULL)
                    """,
                arguments: [id, stamp])
            try db.execute(
                sql: """
                    UPDATE post_tag SET deleted_at = NULL
                    WHERE post_id = ? AND deleted_at = ?
                      AND tag_id IN (SELECT id FROM tag WHERE deleted_at IS NULL)
                    """,
                arguments: [id, stamp])
            try db.execute(
                sql: """
                    UPDATE reference SET deleted_at = NULL, updated_at = ?
                    WHERE container_id = ? AND deleted_at = ?
                    """,
                arguments: [nowStamp, id, stamp])
        }
    }

    private func updateLiveContainer(
        _ id: String, now: Date? = nil, _ mutate: (inout Container) -> Void
    ) throws {
        try database.write { db in
            var container = try liveContainer(db, id)
            mutate(&container)
            container.updatedAt = now ?? date.now
            try container.update(db)
        }
    }
}
