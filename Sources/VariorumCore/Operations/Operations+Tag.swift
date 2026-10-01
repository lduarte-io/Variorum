import Dependencies
import Foundation
import GRDB

// Hierarchical tags. `path` is the ONE deliberate denormalization in the
// model (parent names copied downward), so the two ops that touch names —
// renameTag and deleteTag — own keeping the subtree coherent, each in one
// transaction. Subtree deletion is an ops-layer loop by design: recursive
// triggers stay off, and each tag row's own trigger tombstones its
// applications.
extension Operations {
    @discardableResult
    public func createTag(parent parentID: String? = nil, name: String) throws -> Tag {
        try database.write { db in
            guard !name.isEmpty, !name.contains("/") else {
                throw OperationError.invalidTagName(name: name)
            }
            var path = name
            if let parentID {
                path = try liveTag(db, parentID).path + "/" + name
            }
            try ensureNoLiveTagPath(db, path)
            let now = date.now
            let tag = Tag(
                id: newID(), ownerId: currentOwnerID(), parentId: parentID,
                name: name, path: path, createdAt: now, updatedAt: now)
            try tag.insert(db)
            return tag
        }
    }

    /// Rewrites `name` plus the materialized `path` of the tag AND its whole
    /// live subtree, in one transaction. Bounded by subtree size — fine
    /// locally; under sync it is plain metadata CAS per row (AppSpec §9).
    public func renameTag(_ id: String, newName: String) throws {
        try database.write { db in
            guard !newName.isEmpty, !newName.contains("/") else {
                throw OperationError.invalidTagName(name: newName)
            }
            var tag = try liveTag(db, id)
            guard tag.name != newName else { return }
            // path always ends with the tag's own name (path = parent path
            // + "/" + name), so the rename swaps just that suffix.
            let oldPath = tag.path
            let newPath = String(oldPath.dropLast(tag.name.count)) + newName
            try ensureNoLiveTagPath(db, newPath, excluding: id)

            let now = date.now
            tag.name = newName
            tag.path = newPath
            tag.updatedAt = now
            try tag.update(db)

            // Descendants: swap the old prefix for the new one. SQLite's
            // substr counts Unicode code points, so lengths are measured in
            // unicodeScalars, not Swift graphemes.
            let oldPrefix = oldPath + "/"
            try db.execute(
                sql: """
                    UPDATE tag SET path = ? || substr(path, ?), updated_at = ?
                    WHERE deleted_at IS NULL AND substr(path, 1, ?) = ?
                    """,
                arguments: [
                    newPath,
                    oldPath.unicodeScalars.count + 1,
                    DateFormatter.variorumISO8601.string(from: now),
                    oldPrefix.unicodeScalars.count,
                    oldPrefix,
                ])
        }
    }

    /// Tombstones the tag and its entire live subtree (ops-layer loop; the
    /// per-tag trigger tombstones each tag's applications).
    public func deleteTag(_ id: String) throws {
        try database.write { db in
            let tag = try liveTag(db, id)
            let now = date.now
            let nowStamp = DateFormatter.variorumISO8601.string(from: now)
            let prefix = tag.path + "/"
            try db.execute(
                sql: """
                    UPDATE tag SET deleted_at = ?, updated_at = ?
                    WHERE deleted_at IS NULL AND (id = ? OR substr(path, 1, ?) = ?)
                    """,
                arguments: [nowStamp, nowStamp, id, prefix.unicodeScalars.count, prefix])
        }
    }

    // MARK: - Application

    /// Applying a tag to a note is an APPLYING ACT (13i-b U1): it fires
    /// intake on every living book whose rule hears the tag, in this same
    /// transaction (`insertPostTag` — the one application road). Removing a
    /// tag is a non-event: it never evicts a member (§19, ratified §24).
    @discardableResult
    public func applyTag(_ tagID: String, toPost postID: String) throws -> PostTag {
        try database.write { db in
            _ = try liveTag(db, tagID)
            _ = try livePost(db, postID)
            guard try liveApplication(db, table: "post_tag", tagID: tagID,
                                      targetColumn: "post_id", targetID: postID) == nil
            else { throw OperationError.alreadyTagged(tagID: tagID, targetID: postID) }
            return try insertPostTag(db, tagID: tagID, postID: postID, now: date.now)
        }
    }

    public func removeTag(_ tagID: String, fromPost postID: String) throws {
        try database.write { db in
            guard let id = try liveApplication(db, table: "post_tag", tagID: tagID,
                                               targetColumn: "post_id", targetID: postID)
            else { throw OperationError.tagNotApplied(tagID: tagID, targetID: postID) }
            try db.execute(
                sql: "UPDATE post_tag SET deleted_at = ? WHERE id = ?",
                arguments: [DateFormatter.variorumISO8601.string(from: date.now), id])
        }
    }

    @discardableResult
    public func applyTag(_ tagID: String, toBlock blockID: String) throws -> BlockTag {
        try database.write { db in
            _ = try liveTag(db, tagID)
            _ = try liveBlock(db, blockID)
            guard try liveApplication(db, table: "block_tag", tagID: tagID,
                                      targetColumn: "block_id", targetID: blockID) == nil
            else { throw OperationError.alreadyTagged(tagID: tagID, targetID: blockID) }
            let application = BlockTag(id: newID(), tagId: tagID, blockId: blockID, createdAt: date.now)
            try application.insert(db)
            return application
        }
    }

    public func removeTag(_ tagID: String, fromBlock blockID: String) throws {
        try database.write { db in
            guard let id = try liveApplication(db, table: "block_tag", tagID: tagID,
                                               targetColumn: "block_id", targetID: blockID)
            else { throw OperationError.tagNotApplied(tagID: tagID, targetID: blockID) }
            try db.execute(
                sql: "UPDATE block_tag SET deleted_at = ? WHERE id = ?",
                arguments: [DateFormatter.variorumISO8601.string(from: date.now), id])
        }
    }

    // MARK: - Internals

    private func ensureNoLiveTagPath(
        _ db: Database, _ path: String, excluding excludedID: String? = nil
    ) throws {
        let existing = try Int.fetchOne(
            db,
            sql: "SELECT COUNT(*) FROM tag WHERE path = ? AND deleted_at IS NULL AND id <> ?",
            arguments: [path, excludedID ?? ""]) ?? 0
        if existing > 0 {
            throw OperationError.duplicateTagPath(path: path)
        }
    }

    func liveApplication(
        _ db: Database, table: String, tagID: String, targetColumn: String, targetID: String
    ) throws -> String? {
        try String.fetchOne(
            db,
            sql: "SELECT id FROM \(table) WHERE tag_id = ? AND \(targetColumn) = ? AND deleted_at IS NULL",
            arguments: [tagID, targetID])
    }
}
