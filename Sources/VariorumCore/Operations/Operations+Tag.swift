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
    /// `wingID` (13i-d U5 — R-13ia-1: the vocabulary is PER-WING): the wing
    /// the tag is born in. nil = the PARENT's wing for a child, Home for a
    /// root (every existing caller). A child is always born in its parent's
    /// wing; naming a different wing for it refuses (`tagNotFound` — that
    /// parent does not exist in that library). Path uniqueness is per wing
    /// (`uq_tag_path_live` is `(wing_id, path)`), so a path another wing
    /// wears is a legal twin.
    @discardableResult
    public func createTag(
        parent parentID: String? = nil, name: String, wingID: String? = nil
    ) throws -> Tag {
        try database.write { db in
            try insertTag(db, parent: parentID, name: name, wingID: wingID)
        }
    }

    /// `createTag`'s body at db level — shared with the cross-wing doors'
    /// adoption, which mints a destination's missing path chain inside its
    /// own transaction (13i-d U5).
    func insertTag(
        _ db: Database, parent parentID: String?, name: String, wingID: String?
    ) throws -> Tag {
        guard !name.isEmpty, !name.contains("/") else {
            throw OperationError.invalidTagName(name: name)
        }
        var path = name
        var wing = wingID ?? ""
        if let parentID {
            let parent = try liveTag(db, parentID)
            if let wingID, wingID != parent.wingId {
                throw OperationError.tagNotFound(id: parentID)
            }
            path = parent.path + "/" + name
            wing = parent.wingId
        }
        try requireLiveWing(db, wing)
        try ensureNoLiveTagPath(db, path, wingID: wing)
        let now = date.now
        let tag = Tag(
            id: newID(), ownerId: currentOwnerID(), parentId: parentID,
            name: name, path: path, wingId: wing, createdAt: now, updatedAt: now)
        try tag.insert(db)
        return tag
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
            try ensureNoLiveTagPath(db, newPath, wingID: tag.wingId, excluding: id)

            let now = date.now
            tag.name = newName
            tag.path = newPath
            tag.updatedAt = now
            try tag.update(db)

            // Descendants: swap the old prefix for the new one. SQLite's
            // substr counts Unicode code points, so lengths are measured in
            // unicodeScalars, not Swift graphemes. 13i-d U5 (F-U5-2): the
            // subtree is the TAG's WING's — another wing's same-path tags are
            // another library's vocabulary (R-13ia-1) and stay as they are.
            let oldPrefix = oldPath + "/"
            try db.execute(
                sql: """
                    UPDATE tag SET path = ? || substr(path, ?), updated_at = ?
                    WHERE deleted_at IS NULL AND wing_id = ? AND substr(path, 1, ?) = ?
                    """,
                arguments: [
                    newPath,
                    oldPath.unicodeScalars.count + 1,
                    DateFormatter.variorumISO8601.string(from: now),
                    tag.wingId,
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
            // 13i-d U5 (F-U5-2): the subtree is the tag's own wing's.
            try db.execute(
                sql: """
                    UPDATE tag SET deleted_at = ?, updated_at = ?
                    WHERE deleted_at IS NULL
                      AND (id = ? OR (wing_id = ? AND substr(path, 1, ?) = ?))
                    """,
                arguments: [
                    nowStamp, nowStamp, id, tag.wingId, prefix.unicodeScalars.count, prefix,
                ])
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
            let tag = try liveTag(db, tagID)
            let post = try livePost(db, postID)
            // 13i-d U5 (F-U5-2): a tag of ANOTHER wing does not exist in this
            // note's library (§9; the outflow check's own answer). Compared
            // as surfaces READ the wings — a dangling pointer is Home's.
            guard try sameEffectiveWing(db, tag.wingId, post.wingId) else {
                throw OperationError.tagNotFound(id: tagID)
            }
            guard try liveApplication(db, table: "post_tag", tagID: tagID,
                                      targetColumn: "post_id", targetID: postID) == nil
            else { throw OperationError.alreadyTagged(tagID: tagID, targetID: postID) }
            return try insertPostTag(db, tagID: tagID, postID: postID, now: date.now)
        }
    }

    public func removeTag(_ tagID: String, fromPost postID: String) throws {
        try database.write { db in _ = try removePostTagApplication(db, tagID: tagID, postID: postID) }
    }

    /// `removeTag(_:fromPost:)`'s row body inside the caller's transaction
    /// (VX-184 U3 — extracted byte-for-byte so the MCP door's `remove_tag`
    /// takes HER road): the live application tombstoned — a NON-EVENT for
    /// intake (no living book hears an un-tag; §19) — or `tagNotApplied`.
    /// Returns the application's id (the door's undo restores that exact row).
    func removePostTagApplication(_ db: Database, tagID: String, postID: String) throws -> String {
        guard let id = try liveApplication(db, table: "post_tag", tagID: tagID,
                                           targetColumn: "post_id", targetID: postID)
        else { throw OperationError.tagNotApplied(tagID: tagID, targetID: postID) }
        try db.execute(
            sql: "UPDATE post_tag SET deleted_at = ? WHERE id = ?",
            arguments: [DateFormatter.variorumISO8601.string(from: date.now), id])
        return id
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

    /// Uniqueness is `(wing_id, path)` over live rows (R-13ia-1 — 13i-d U5
    /// F-U5-2: this probe was store-wide, so a path another wing wore refused
    /// a legal twin).
    private func ensureNoLiveTagPath(
        _ db: Database, _ path: String, wingID: String, excluding excludedID: String? = nil
    ) throws {
        let existing = try Int.fetchOne(
            db,
            sql: """
                SELECT COUNT(*) FROM tag
                WHERE path = ? AND wing_id = ? AND deleted_at IS NULL AND id <> ?
                """,
            arguments: [path, wingID, excludedID ?? ""]) ?? 0
        if existing > 0 {
            throw OperationError.duplicateTagPath(path: path)
        }
    }

    /// Do two stored wing pointers name the same library as surfaces READ
    /// them (a dangling pointer reads as Home — `Queries.wingScope`)?
    func sameEffectiveWing(_ db: Database, _ a: String, _ b: String) throws -> Bool {
        guard a != b else { return true }
        let ea = try Queries.wingIsLive(db, id: a) ? a : ""
        let eb = try Queries.wingIsLive(db, id: b) ? b : ""
        return ea == eb
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
