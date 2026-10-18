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
    ///
    /// **VX-247 — ONE structural-undo entry, "Delete Tag"** (her ruling
    /// 2026-10-13, QUESTIONS #217: "adding an undo to the tag delete could be
    /// a quick ticket before launch… that fits with being able to undo AI
    /// actions with one command"). AppSpec §9's contract: the inverse revives
    /// the subtree's tag rows AND their applications dead on the delete's
    /// EXACT stamp; the redo re-applies exactly what the undo revived and
    /// records its own stamp for the next undo; a half that finds nothing of
    /// its partner's result is QUIET and retires the entry (VX-246 U2). The
    /// registration lives HERE, so every door into the act — Settings ▸ Tags'
    /// trash and its context row on the Mac, the phone's tag manager — rides
    /// the one road (the MCP door has no tag-delete tool; one would too).
    /// The bigger recovery road (the Trash) stays VX-238.
    public func deleteTag(_ id: String) throws {
        let pass = try database.write { db in
            try tombstoneTagSubtree(
                db, try liveTag(db, id),
                stamp: DateFormatter.variorumISO8601.string(from: date.now))
        }
        registerTagDeletionEntry(pass)
    }

    /// The undo entry's words — "Undo Delete Tag" / "Redo Delete Tag", the
    /// act's own verb (`.deleteTag`'s "Delete Tag…", without the ellipsis).
    public static let deleteTagUndoLabel = "Delete Tag"

    /// What ONE tombstone pass over a tag subtree wrote (VX-247): the tag rows
    /// it tombstoned, parents before children (path order), and the stamp —
    /// the same stamp the cascade trigger gave each row's applications.
    struct TagDeletionPass: Equatable, Sendable {
        let tagIDs: [String]
        let stamp: String
    }

    /// The delete's row work: the tag and every LIVE tag under its CURRENT
    /// path in its own wing (13i-d U5, F-U5-2 — another wing's same-path tags
    /// are another library's vocabulary), tombstoned on one stamp; each
    /// row's trigger tombstones its live applications on that stamp.
    private func tombstoneTagSubtree(
        _ db: Database, _ tag: Tag, stamp nowStamp: String
    ) throws -> TagDeletionPass {
        let prefix = tag.path + "/"
        let subtree = """
            deleted_at IS NULL
              AND (id = ? OR (wing_id = ? AND substr(path, 1, ?) = ?))
            """
        let subtreeArguments: StatementArguments = [
            tag.id, tag.wingId, prefix.unicodeScalars.count, prefix,
        ]
        let ids = try String.fetchAll(
            db, sql: "SELECT id FROM tag WHERE \(subtree) ORDER BY path, id",
            arguments: subtreeArguments)
        try db.execute(
            sql: "UPDATE tag SET deleted_at = ?, updated_at = ? WHERE \(subtree)",
            arguments: [nowStamp, nowStamp] + subtreeArguments)
        return TagDeletionPass(tagIDs: ids, stamp: nowStamp)
    }

    /// ONE entry over the delete (VX-247): each half hands its partner
    /// exactly what it changed — the inverse the rows it revived, the redo
    /// the rows it tombstoned and their stamp — so a half never runs over a
    /// part its partner did not move (VX-246 U2's parts record).
    private func registerTagDeletionEntry(_ first: TagDeletionPass) {
        let lastDeletion = LockIsolated(first)
        let lastRevival = LockIsolated<[String]>([])
        undoStack?.register(
            label: Self.deleteTagUndoLabel,
            inverse: { ops in
                let revived = try ops.revertTagDeletion(lastDeletion.value)
                guard !revived.isEmpty else { return false }
                lastRevival.setValue(revived)
                return true
            },
            redo: { ops in
                guard let pass = try ops.reapplyTagDeletion(lastRevival.value) else { return false }
                lastDeletion.setValue(pass)
                return true
            })
    }

    /// **The INVERSE of a tag delete** (VX-247): revives, parents first, each
    /// tag the pass tombstoned that is STILL dead on the pass's stamp, with
    /// its applications dead on that same stamp — exact-row flips, never a
    /// fresh row, and no applying act (an exact-row revival seats nothing;
    /// the memberships intake seated when she tagged never left). Returns the
    /// tags it revived, path order; empty is the QUIET answer.
    ///
    /// Divergence is left alone quietly (the standing bucket): a tag alive
    /// again, or dead on another stamp, is not this act's result; one whose
    /// parent no longer stands, or whose wing is gone, stays dead (there is
    /// no road to bring those back, so a refusal would wedge the stack) —
    /// and so does everything under it. **A live tag holding the same path
    /// in the wing REFUSES** (`duplicateTagPath` — resolvable: rename that
    /// tag, then undo again): it is hers, made since, and the path is unique.
    /// An application revives only onto a live note or block, and never
    /// beside a live twin of itself (`uq_post_tag_live` / `uq_block_tag_live`).
    func revertTagDeletion(_ pass: TagDeletionPass) throws -> [String] {
        try database.write { db in
            let nowStamp = DateFormatter.variorumISO8601.string(from: date.now)
            var revived: [String] = []
            guard !pass.tagIDs.isEmpty else { return revived }
            let marks = Array(repeating: "?", count: pass.tagIDs.count).joined(separator: ",")
            let dead = try Tag.fetchAll(
                db,
                sql: "SELECT * FROM tag WHERE id IN (\(marks)) AND deleted_at = ? ORDER BY path, id",
                arguments: StatementArguments(pass.tagIDs + [pass.stamp]))
            for tag in dead {
                if let parentID = tag.parentId {
                    guard let parent = try Tag.fetchOne(db, key: parentID), parent.deletedAt == nil
                    else { continue }
                }
                let wingStands = try tag.wingId.isEmpty || Queries.wingIsLive(db, id: tag.wingId)
                guard wingStands else { continue }
                try ensureNoLiveTagPath(db, tag.path, wingID: tag.wingId, excluding: tag.id)
                try db.execute(
                    sql: "UPDATE tag SET deleted_at = NULL, updated_at = ? WHERE id = ?",
                    arguments: [nowStamp, tag.id])
                try db.execute(
                    sql: """
                        UPDATE post_tag SET deleted_at = NULL
                        WHERE tag_id = ? AND deleted_at = ?
                          AND post_id IN (SELECT id FROM container WHERE deleted_at IS NULL)
                          AND NOT EXISTS (SELECT 1 FROM post_tag twin
                                           WHERE twin.tag_id = post_tag.tag_id
                                             AND twin.post_id = post_tag.post_id
                                             AND twin.deleted_at IS NULL)
                        """,
                    arguments: [tag.id, pass.stamp])
                try db.execute(
                    sql: """
                        UPDATE block_tag SET deleted_at = NULL
                        WHERE tag_id = ? AND deleted_at = ?
                          AND block_id IN (SELECT id FROM block WHERE deleted_at IS NULL)
                          AND NOT EXISTS (SELECT 1 FROM block_tag twin
                                           WHERE twin.tag_id = block_tag.tag_id
                                             AND twin.block_id = block_tag.block_id
                                             AND twin.deleted_at IS NULL)
                        """,
                    arguments: [tag.id, pass.stamp])
                revived.append(tag.id)
            }
            return revived
        }
    }

    /// **The RE-APPLY** (VX-247): the delete again, over exactly the tags the
    /// undo revived that still stand — each through the delete's own subtree
    /// rule (so a child she made under a revived tag since goes with it, as a
    /// take branched since an undo goes with a re-deleted block — the
    /// cascade's precedent; the next undo brings it back on this stamp), on
    /// ONE fresh stamp. Returns that pass, or nil when every revived tag is
    /// already gone (QUIET).
    func reapplyTagDeletion(_ revivedIDs: [String]) throws -> TagDeletionPass? {
        try database.write { db in
            let stamp = DateFormatter.variorumISO8601.string(from: date.now)
            var tombstoned: [String] = []
            for id in revivedIDs {
                guard let tag = try Tag.fetchOne(db, key: id), tag.deletedAt == nil else { continue }
                tombstoned += try tombstoneTagSubtree(db, tag, stamp: stamp).tagIDs
            }
            return tombstoned.isEmpty ? nil : TagDeletionPass(tagIDs: tombstoned, stamp: stamp)
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
