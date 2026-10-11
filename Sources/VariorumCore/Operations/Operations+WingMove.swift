import Dependencies
import Foundation
import GRDB

// THE CROSS-WING DOORS — the per-item NOTE move and copy (13i-d U5; the sitting
// record §9: "the ONLY crossings are the explicit move/copy doors"; her
// 2026-08-25 ruling: "cross library move should be possible, but make a copy
// and put it in the other library should also be an option"; R-13ia-1's
// adoption rider: "if I move something tagged writing to a different wing
// that already has a 'writing' tag, it should probably convert to being that
// ID").
//
// THE BOOK-MOVE HALF (13i-d U5b — the per-item book move and the bulk "Move
// everything to another wing…", R-13id-6: the U5 RECORD's proposal RULED
// whole) lives in `Operations+WingBookMove.swift`; both compose the ONE
// relocation primitive below (`relocateNote`) over a book's members / a whole
// wing.
//
// Tag ADOPTION, the one rule (R-13ia-1): a carried tag resolves BY PATH in the
// destination — its live same-path tag adopts the application; a missing path
// is MINTED there (its missing ancestors too). The re-pointed applications are
// ROW COPIES, never applying acts: no intake fires (the ceremony copy's
// P-13ic-U2-1 letter — a move must not quietly seat a note in the
// destination's living books; she adds it where she wants it).
extension Operations {
    /// What a note move did — what the receipt says.
    public struct NoteWingMove: Equatable, Sendable {
        /// The books the note LEFT (a book never spans wings), by name,
        /// earliest membership first — the confirm listed exactly these.
        public let leftBooks: [String]
        /// Carried tags that ADOPTED a same-path tag already in the
        /// destination / that were MINTED there.
        public let adoptedTags: Int
        public let mintedTags: Int
    }

    /// **MOVE TO WING** (PROVISIONAL P-13id-U5-7 — her move door; the edges
    /// are this unit's provisional calls, numbered in the record). ONE
    /// transaction:
    ///
    /// 1. **Memberships** — every live membership row of the note in its
    ///    source wing's books (members AND waiting arrivals) is SEVERED: a
    ///    book never spans wings (§9). The confirm lists them
    ///    (`Queries.wingMovePreview`). A MEMBER row in a FINISHED or SEALED
    ///    book refuses the move (`lockedReading` / `readingSealed` — reopen or
    ///    unseal first; move-in's P-13ic-U2-4 precedent: a frozen table of
    ///    contents is not changed by a side door). A waiting arrival there is
    ///    dismissed like any other (dismissal stays legal on a finished book).
    /// 2. **Tags** — every live application on the note, and on its placed
    ///    blocks, re-points BY PATH into the destination (adopt, else mint).
    ///    The source wing's tags themselves stay (they are that library's
    ///    vocabulary — the BULK move is the act that would retire them).
    /// 3. **The note** — `wing_id` := the destination, for the note AND its
    ///    saved VERSIONS (they ride the note: "a thing's past goes where the
    ///    thing goes", the post-13l V2 doctrine). Stars, archive state, the
    ///    seal, comments, lenses, references and canvas ride untouched (no
    ///    wing of their own).
    ///
    /// Refuses: the note's own wing (`postAlreadyInWing`), a destination that
    /// is not live (`wingNotFound`). No structural-undo entry (moving back is
    /// the symmetric door).
    @discardableResult
    public func moveNoteToWing(_ postID: String, to wingID: String) throws -> NoteWingMove {
        try database.write { db in try moveNoteToWing(db, postID, to: wingID).move }
    }

    /// **Her door's body, inside the caller's transaction** (13n-c U6 — moved
    /// here VERBATIM so the MCP door's `move_note_to_wing` wraps the very same
    /// act and its refusals; her public door above calls it and is
    /// byte-identical). Returns her answer and the clock read the act stamped
    /// its tombstones with (`date.now`, read at the same point as before).
    func moveNoteToWing(
        _ db: Database, _ postID: String, to wingID: String
    ) throws -> (move: NoteWingMove, now: Date) {
        let post = try livePost(db, postID)
        try requireLiveWing(db, wingID)
        guard try !sameEffectiveWing(db, post.wingId, wingID) else {
            throw OperationError.postAlreadyInWing(postID: postID, wingID: wingID)
        }
        var adoption = TagAdoption(wing: wingID)
        let now = date.now
        let severed = try relocateNote(
            db, postID: postID, to: wingID, keeping: [], adoption: &adoption, now: now)
        var left: [String] = []
        for reading in severed where !left.contains(reading.name) {
            left.append(reading.name)
        }
        return (NoteWingMove(
            leftBooks: left, adoptedTags: adoption.adopted, mintedTags: adoption.minted), now)
    }

    /// **THE ONE RELOCATION** (13i-d U5b — U5's note move, extracted so the
    /// book and bulk moves compose it; `moveNoteToWing` is `keeping: []`,
    /// byte-identical in behaviour). Inside the caller's transaction:
    ///
    /// 1. **Memberships** — every live row of the note in a live reading NOT
    ///    in `keeping` (members AND waiting arrivals) is SEVERED: a book never
    ///    spans wings (§9). A MEMBER row there in a FINISHED or SEALED book
    ///    REFUSES (`lockedReading` / `readingSealed` — reopen or unseal first;
    ///    move-in's P-13ic-U2-4 precedent), checked before any write; a
    ///    waiting arrival there is dismissed like any other. `keeping` is the
    ///    book move's own book (it moves WITH the note, R-13id-6 item 3(a)) or
    ///    the bulk move's every reading (they all move).
    /// 2. **Tags** — the note's post tags and its placed blocks' tags re-point
    ///    BY PATH into the adoption's wing (adopt, else mint) — row copies, no
    ///    intake.
    /// 3. **The note** — `wing_id` := the destination, for it AND its saved
    ///    versions (they ride it). Stars, archive state, the seal, comments,
    ///    lenses, references and canvas ride untouched.
    ///
    /// Returns the readings whose MEMBER row it severed, earliest first (one
    /// entry per row — the callers name or dedupe them).
    func relocateNote(
        _ db: Database, postID: String, to wingID: String, keeping: Set<String>,
        adoption: inout TagAdoption, now: Date
    ) throws -> [Reading] {
        var post = try livePost(db, postID)

        // 1. Memberships — refuse a frozen book's member row FIRST.
        let rows = try wingMoveMemberships(db, postID: postID)
            .filter { !keeping.contains($0.reading.id) }
        for (row, reading) in rows where row.status == .member {
            if reading.sealedAt != nil {
                throw OperationError.readingSealed(id: reading.id)
            }
            if reading.locked {
                throw OperationError.lockedReading(id: reading.id)
            }
        }
        var severedMembers: [Reading] = []
        for (row, reading) in rows {
            var severed = row
            severed.deletedAt = now
            try severed.update(db)
            if row.status == .member { severedMembers.append(reading) }
        }

        // 2. Tags, re-pointed by path.
        try repointPostTags(db, postID: postID, adoption: &adoption, now: now)
        let blockIDs = try String.fetchAll(
            db,
            sql: """
                SELECT cb.block_id FROM container_block cb
                WHERE cb.container_id = ? AND cb.deleted_at IS NULL
                """,
            arguments: [postID])
        for blockID in blockIDs {
            try repointBlockTags(db, blockID: blockID, adoption: &adoption, now: now)
        }

        // 3. The note and its versions.
        post.wingId = wingID
        post.updatedAt = now
        try post.update(db)
        for versionID in try Queries.noteVersionIDs(db, of: postID) {
            guard var version = try Container.fetchOne(db, key: versionID),
                  version.deletedAt == nil
            else { continue }
            version.wingId = wingID
            version.updatedAt = now
            try version.update(db)
        }
        return severedMembers
    }

    /// **COPY TO WING** (PROVISIONAL P-13id-U5-8). The ceremony copy (§2.3 —
    /// "copies are always ceremonies … always lineage-edged"): `copyPost`'s
    /// family — whole live fans, archived takes riding, block names,
    /// presentations and comments, per-block `derived_from` edges plus ONE
    /// `version_of` anchor — born IN the destination wing, with the note's
    /// live tags ADOPTED there by path. It joins NO book ("adding never
    /// copies", §2.2 — a copy lands in the destination's Pool; she files it).
    /// The lineage edges cross wings as ROWS — the one data-level exception
    /// (§9, #166(e)): surfaces stay wing-scoped and the lineage line only
    /// names the other wing. An EMPTY note copies as a bare note (the
    /// ceremony copy's P-13ic-U2-2 — no blocks, no edge). The source is never
    /// touched. No structural-undo entry (the ceremony class; the copy is a
    /// real note — the Trash is the road).
    @discardableResult
    public func copyNoteToWing(_ postID: String, to wingID: String) throws -> Container {
        try database.write { db in
            let source = try livePost(db, postID)
            try requireLiveWing(db, wingID)
            guard try !sameEffectiveWing(db, source.wingId, wingID) else {
                throw OperationError.postAlreadyInWing(postID: postID, wingID: wingID)
            }
            let now = date.now
            let copy: Container
            let copyable = try Bool.fetchOne(
                db,
                sql: """
                    SELECT EXISTS (SELECT 1 FROM container_block cb
                      JOIN block b ON b.id = cb.block_id AND b.deleted_at IS NULL
                      JOIN variant v ON v.block_id = b.id AND v.deleted_at IS NULL
                     WHERE cb.container_id = ? AND cb.deleted_at IS NULL)
                    """,
                arguments: [postID]) ?? false
            if copyable {
                copy = try copyPost(
                    db, sourceID: postID, chosenPicks: nil, carryFans: true,
                    intoWing: wingID
                ).post
            } else {
                let bare = Container(
                    id: newID(), ownerId: currentOwnerID(), kind: .post,
                    title: source.title, profile: source.profile, entryDate: source.entryDate,
                    locked: false, floatingNotes: source.floatingNotes,
                    segmentationDefault: source.segmentationDefault,
                    lastTouchedAt: now, wingId: wingID,
                    createdAt: now, updatedAt: now)
                try bare.insert(db)
                copy = bare
            }
            var adoption = TagAdoption(wing: wingID)
            for tag in try liveTagsWorn(db, postID: postID) {
                let target = try adopt(db, tag, &adoption)
                guard try liveApplication(db, table: "post_tag", tagID: target.id,
                                          targetColumn: "post_id", targetID: copy.id) == nil
                else { continue }
                try PostTag(id: newID(), tagId: target.id, postId: copy.id, createdAt: now)
                    .insert(db)
            }
            return copy
        }
    }

    // MARK: - Internals (shared with the stopped book-move half when it lands)

    /// The adoption tally of one act, and the resolved targets (a path is
    /// resolved once per act).
    struct TagAdoption {
        let wing: String
        var resolved: [String: Tag] = [:]
        var adopted = 0
        var minted = 0
    }

    /// Resolve `tag` BY PATH in the adoption's wing: the live same-path tag
    /// adopts; a missing path mints its missing chain (ancestors first, each
    /// counted as minted).
    func adopt(_ db: Database, _ tag: Tag, _ adoption: inout TagAdoption) throws -> Tag {
        guard let resolved = try adoptPath(db, tag.path, &adoption) else {
            throw OperationError.tagNotFound(id: tag.id)
        }
        return resolved
    }

    /// `adopt`'s rule over a PATH (13n-a: the document format's `{#a/b}`
    /// tokens name tags by path, never by id — R-13ia-1's adopt-else-mint,
    /// the one rule): the live same-path tag in the adoption's wing, else the
    /// missing chain minted there. Nil only for a path with no segment.
    func adoptPath(_ db: Database, _ path: String, _ adoption: inout TagAdoption) throws -> Tag? {
        if let known = adoption.resolved[path] { return known }
        if let existing = try liveTag(db, path: path, wing: adoption.wing) {
            adoption.resolved[path] = existing
            adoption.adopted += 1
            return existing
        }
        var parent: Tag?
        var prefix = ""
        for segment in path.split(separator: "/").map(String.init) {
            prefix = prefix.isEmpty ? segment : prefix + "/" + segment
            if let existing = try liveTag(db, path: prefix, wing: adoption.wing) {
                parent = existing
                continue
            }
            let minted = try insertTag(
                db, parent: parent?.id, name: segment,
                wingID: parent == nil ? adoption.wing : nil)
            adoption.minted += 1
            parent = minted
        }
        guard let resolved = parent else { return nil }
        adoption.resolved[path] = resolved
        return resolved
    }

    private func liveTag(_ db: Database, path: String, wing: String) throws -> Tag? {
        try Tag.fetchOne(
            db,
            sql: "SELECT * FROM tag WHERE path = ? AND wing_id = ? AND deleted_at IS NULL",
            arguments: [path, wing])
    }

    /// The note's live applications of live tags, application order.
    private func liveTagsWorn(_ db: Database, postID: String) throws -> [Tag] {
        try Tag.fetchAll(
            db,
            sql: """
                SELECT t.* FROM post_tag pt
                JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                WHERE pt.post_id = ? AND pt.deleted_at IS NULL
                ORDER BY pt.created_at, pt.id
                """,
            arguments: [postID])
    }

    /// Re-point the note's live post tags into the adoption's wing: the old
    /// application tombstones, a fresh one lands on the resolved tag (a row
    /// copy — no intake).
    private func repointPostTags(
        _ db: Database, postID: String, adoption: inout TagAdoption, now: Date
    ) throws {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT pt.id AS application, t.* FROM post_tag pt
                JOIN tag t ON t.id = pt.tag_id AND t.deleted_at IS NULL
                WHERE pt.post_id = ? AND pt.deleted_at IS NULL
                ORDER BY pt.created_at, pt.id
                """,
            arguments: [postID])
        let stamp = DateFormatter.variorumISO8601.string(from: now)
        for row in rows {
            let tag = try Tag(row: row)
            let target = try adopt(db, tag, &adoption)
            try db.execute(
                sql: "UPDATE post_tag SET deleted_at = ? WHERE id = ?",
                arguments: [stamp, row["application"] as String])
            guard try liveApplication(db, table: "post_tag", tagID: target.id,
                                      targetColumn: "post_id", targetID: postID) == nil
            else { continue }
            try PostTag(id: newID(), tagId: target.id, postId: postID, createdAt: now).insert(db)
        }
    }

    /// The block twin of `repointPostTags` (block tags ride their block).
    private func repointBlockTags(
        _ db: Database, blockID: String, adoption: inout TagAdoption, now: Date
    ) throws {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT bt.id AS application, t.* FROM block_tag bt
                JOIN tag t ON t.id = bt.tag_id AND t.deleted_at IS NULL
                WHERE bt.block_id = ? AND bt.deleted_at IS NULL
                ORDER BY bt.created_at, bt.id
                """,
            arguments: [blockID])
        let stamp = DateFormatter.variorumISO8601.string(from: now)
        for row in rows {
            let tag = try Tag(row: row)
            let target = try adopt(db, tag, &adoption)
            try db.execute(
                sql: "UPDATE block_tag SET deleted_at = ? WHERE id = ?",
                arguments: [stamp, row["application"] as String])
            guard try liveApplication(db, table: "block_tag", tagID: target.id,
                                      targetColumn: "block_id", targetID: blockID) == nil
            else { continue }
            try BlockTag(id: newID(), tagId: target.id, blockId: blockID, createdAt: now)
                .insert(db)
        }
    }

    /// **The bulk move's STRAYS** (13i-d U5b — R-13id-6 item 8, "every tag
    /// application re-points by path", read literally so the wing ends
    /// EMPTY; PROVISIONAL P-13id-U5b-7): every REMAINING live application of
    /// a live tag of `wing` — after the notes' own applications have moved
    /// with them, what is left is a snippet block (snippets are one shared
    /// room, P-13id-U5-4) or a saved version's block wearing one — re-points
    /// BY PATH into the adoption's wing, the same row copy. Without it those
    /// tags keep a live application, so the act could not retire them and
    /// Delete Wing would still refuse.
    func repointStrayApplications(
        _ db: Database, ofWing wing: String, adoption: inout TagAdoption, now: Date
    ) throws {
        let stamp = DateFormatter.variorumISO8601.string(from: now)
        for (table, column, model) in [("post_tag", "post_id", "post"), ("block_tag", "block_id", "block")] {
            let rows = try Row.fetchAll(
                db,
                sql: """
                    SELECT a.id AS application, a.\(column) AS target, t.* FROM \(table) a
                    JOIN tag t ON t.id = a.tag_id AND t.deleted_at IS NULL
                    WHERE t.wing_id = ? AND a.deleted_at IS NULL
                    ORDER BY a.created_at, a.id
                    """,
                arguments: [wing])
            for row in rows {
                let tag = try Tag(row: row)
                let target = try adopt(db, tag, &adoption)
                let targetID: String = row["target"]
                try db.execute(
                    sql: "UPDATE \(table) SET deleted_at = ? WHERE id = ?",
                    arguments: [stamp, row["application"] as String])
                guard try liveApplication(db, table: table, tagID: target.id,
                                          targetColumn: column, targetID: targetID) == nil
                else { continue }
                if model == "post" {
                    try PostTag(id: newID(), tagId: target.id, postId: targetID, createdAt: now)
                        .insert(db)
                } else {
                    try BlockTag(id: newID(), tagId: target.id, blockId: targetID, createdAt: now)
                        .insert(db)
                }
            }
        }
    }

    /// The note's live membership rows (members AND arrivals) in LIVE
    /// readings, earliest first — what a move severs.
    func wingMoveMemberships(
        _ db: Database, postID: String
    ) throws -> [(row: ReadingPost, reading: Reading)] {
        let rows = try ReadingPost.fetchAll(
            db,
            sql: """
                SELECT rp.* FROM reading_post rp
                JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL
                WHERE rp.post_id = ? AND rp.deleted_at IS NULL
                ORDER BY rp.created_at, rp.id
                """,
            arguments: [postID])
        return try rows.map { row in (row, try liveReading(db, row.readingId)) }
    }
}

extension Queries {
    /// **What a note move would do — the confirm's read** (the act's own
    /// predicate, `Operations.wingMoveMemberships`' twin, so the list and the
    /// act agree): the books the note would leave (members, earliest first),
    /// and the first FROZEN one that would refuse it (finished or sealed),
    /// if any.
    public struct WingMovePreview: Equatable, Sendable {
        public let leaves: [String]
        public let frozenBook: String?
    }

    public static func wingMovePreview(_ db: Database, postID: String) throws -> WingMovePreview {
        let rows = try Row.fetchAll(
            db,
            sql: """
                SELECT r.name AS name, r.locked AS locked, r.sealed_at AS sealed
                FROM reading_post rp
                JOIN reading r ON r.id = rp.reading_id AND r.deleted_at IS NULL
                WHERE rp.post_id = ? AND rp.deleted_at IS NULL AND rp.status = 'member'
                ORDER BY rp.created_at, rp.id
                """,
            arguments: [postID])
        var leaves: [String] = []
        var frozen: String?
        for row in rows {
            let name: String = row["name"]
            if !leaves.contains(name) { leaves.append(name) }
            let locked = (row["locked"] as Int?) == 1
            let sealed = (row["sealed"] as String?) != nil
            if frozen == nil, locked || sealed { frozen = name }
        }
        return WingMovePreview(leaves: leaves, frozenBook: frozen)
    }
}
