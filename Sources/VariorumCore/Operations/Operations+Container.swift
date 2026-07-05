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
