import Dependencies
import Foundation
import GRDB

// Readings: books/chapters/on-demand collections — ordered, non-exclusive
// pointer lists over posts (the deliberate asymmetry with blocks).
extension Operations {
    @discardableResult
    public func createReading(
        name: String,
        kind: ReadingKind,
        profile: String? = nil,
        sortField: SortField = .manual,
        sortDir: SortDirection = .asc,
        groupingTagId: String? = nil,
        querySpec: String? = nil,
        maxPosts: Int? = nil,
        wordTarget: Int? = nil
    ) throws -> Reading {
        let now = date.now
        let reading = Reading(
            id: newID(), ownerId: currentOwnerID(), name: name, kind: kind,
            profile: profile, sortField: sortField, sortDir: sortDir,
            groupingTagId: groupingTagId, querySpec: querySpec, maxPosts: maxPosts,
            wordTarget: wordTarget,
            createdAt: now, updatedAt: now)
        try database.write { db in try reading.insert(db) }
        return reading
    }

    // MARK: - Extent faces (Phase 13, A1/A2 — the bounded-notebook thread)

    /// Sets (or clears, with nil) the words-based extent TARGET (v1_11).
    /// A display/progress semantic, never an add-time refusal — word counts
    /// change with every edit, so membership can't enforce them; the shelf
    /// face shows progress and the boundary offers extend-or-start-new.
    /// Non-positive targets refuse; a LOCKED (finished) reading refuses —
    /// extending a bounded notebook is un-finishing it first (the
    /// setReadingSort parallel; PROVISIONAL, QUESTIONS bundle).
    public func setReadingWordTarget(_ id: String, wordTarget: Int?) throws {
        try database.write { db in
            var reading = try liveReading(db, id)
            guard !reading.locked else {
                throw OperationError.lockedReading(id: id)
            }
            if let wordTarget, wordTarget <= 0 {
                throw OperationError.invalidExtent(value: wordTarget)
            }
            guard reading.wordTarget != wordTarget else { return }
            reading.wordTarget = wordTarget
            reading.updatedAt = date.now
            try reading.update(db)
        }
    }

    /// Sets (or clears) the post-count extent — `max_posts` has had NO
    /// setter since v1 (the brief's "no UI face at all" finding starts
    /// here). Same guards as the word target. Lowering the cap below the
    /// current live membership is legal: existing memberships stand;
    /// further adds refuse at the standing `readingAtCapacity` gate.
    public func setReadingMaxPosts(_ id: String, maxPosts: Int?) throws {
        try database.write { db in
            var reading = try liveReading(db, id)
            guard !reading.locked else {
                throw OperationError.lockedReading(id: id)
            }
            if let maxPosts, maxPosts <= 0 {
                throw OperationError.invalidExtent(value: maxPosts)
            }
            guard reading.maxPosts != maxPosts else { return }
            reading.maxPosts = maxPosts
            reading.updatedAt = date.now
            try reading.update(db)
        }
    }

    public func renameReading(_ id: String, name: String) throws {
        try updateLiveReading(id) { $0.name = name }
    }

    /// For non-manual readings the sort field IS the order, so a locked
    /// reading ("declared done" — order frozen) refuses this too (review
    /// finding 2026-07-05).
    public func setReadingSort(_ id: String, field: SortField, direction: SortDirection) throws {
        try database.write { db in
            var reading = try liveReading(db, id)
            guard !reading.locked else {
                throw OperationError.lockedReading(id: id)
            }
            reading.sortField = field
            reading.sortDir = direction
            reading.updatedAt = date.now
            try reading.update(db)
        }
    }

    public func setReadingQuerySpec(_ id: String, querySpec: String?) throws {
        try updateLiveReading(id) { $0.querySpec = querySpec }
    }

    /// "Declared done" — freezes membership and order below; reversible.
    public func lockReading(_ id: String) throws {
        try updateLiveReading(id) { $0.locked = true }
    }

    public func unlockReading(_ id: String) throws {
        try updateLiveReading(id) { $0.locked = false }
    }

    /// Tombstone; the reading trigger cascades to its memberships.
    public func deleteReading(_ id: String) throws {
        let now = date.now
        try updateLiveReading(id, now: now) { $0.deletedAt = now }
    }

    // MARK: - Curated membership

    @discardableResult
    public func addPostToReading(
        _ postID: String, to readingID: String, at insert: InsertPosition = .end
    ) throws -> ReadingPost {
        try database.write { db in
            let reading = try liveReading(db, readingID)
            guard reading.kind == .curated else {
                throw OperationError.wrongReadingKind(id: readingID, expected: .curated)
            }
            guard !reading.locked else {
                throw OperationError.lockedReading(id: readingID)
            }
            _ = try livePost(db, postID)

            let liveCount = try Int.fetchOne(
                db,
                sql: "SELECT COUNT(*) FROM reading_post WHERE reading_id = ? AND deleted_at IS NULL",
                arguments: [readingID]) ?? 0
            if try liveMembership(db, postID: postID, readingID: readingID) != nil {
                throw OperationError.alreadyInReading(postID: postID, readingID: readingID)
            }
            // The extent constraint (fixed-length journals).
            if let maxPosts = reading.maxPosts, liveCount >= maxPosts {
                throw OperationError.readingAtCapacity(id: readingID)
            }

            let membership = ReadingPost(
                id: newID(), readingId: readingID, postId: postID,
                position: try readingPosition(db, readingID: readingID, at: insert),
                createdAt: date.now)
            try membership.insert(db)
            return membership
        }
    }

    public func removePostFromReading(_ postID: String, from readingID: String) throws {
        try database.write { db in
            let reading = try liveReading(db, readingID)
            guard !reading.locked else {
                throw OperationError.lockedReading(id: readingID)
            }
            guard var membership = try liveMembership(db, postID: postID, readingID: readingID) else {
                throw OperationError.postNotInReading(postID: postID, readingID: readingID)
            }
            membership.deletedAt = date.now
            try membership.update(db)
        }
    }

    public func reorderReadingPost(
        _ postID: String, in readingID: String, to insert: InsertPosition
    ) throws {
        try database.write { db in
            let reading = try liveReading(db, readingID)
            guard !reading.locked else {
                throw OperationError.lockedReading(id: readingID)
            }
            guard var membership = try liveMembership(db, postID: postID, readingID: readingID) else {
                throw OperationError.postNotInReading(postID: postID, readingID: readingID)
            }
            membership.position = try readingPosition(db, readingID: readingID, at: insert)
            try membership.update(db)
        }
    }

    private func updateLiveReading(
        _ id: String, now: Date? = nil, _ mutate: (inout Reading) -> Void
    ) throws {
        try database.write { db in
            var reading = try liveReading(db, id)
            mutate(&reading)
            reading.updatedAt = now ?? date.now
            try reading.update(db)
        }
    }

    private func liveMembership(
        _ db: Database, postID: String, readingID: String
    ) throws -> ReadingPost? {
        try ReadingPost
            .filter(Column("reading_id") == readingID && Column("post_id") == postID
                && Column("deleted_at") == nil)
            .fetchOne(db)
    }
}
